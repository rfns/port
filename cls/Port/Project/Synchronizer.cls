Include portutils

Class Port.Project.Synchronizer Extends %RegisteredObject
{

Property ExtraneousEntries As %List [ Private ];

Property Whitelist As array Of %String [ Private ];

Property Tool As Port.Project.Base [ Private ];

Property TypePaths As %List [ Private ];

Property Simulated As %Boolean [ InitialExpression = 0 ];

Method %OnNew(tool As Port.Project.Base, simulated As %Boolean = 0) As %Status
{
  set ..Tool = tool
  set ..Simulated = simulated
  do ..BuildTypePaths()
  return $$$OK
}

Method BuildTypePaths()
{
  for i=1:1:$ll($$$PathTypes) set $list(i%TypePaths, *+1) = $$$NFN($$$FormatText("%1/%2", ..Tool.BasePath, $lg($$$PathTypes, i)))
}

Method AddToWhitelist(itemName As %String, sourceLocation As %String = "") As %Status [ Internal ]
{

  set sc = $$$OK
  set type = ##class(Port.Util).GetItemType(itemName)
  set typePath = ..Tool.GetTypePath(type)
  set slash = $$$Slash(typePath)

  if sourceLocation = "" {
    set workspacePath = $piece(typePath, slash, 1, *-1)
    set sourceLocation = ##class(Port.Util).ItemToPath(itemName, workspacePath)
  }

  set typePath = $$$LTrimProvidedSlash(typePath, "/")

  set absoluteBasePath = ##class(%File).NormalizeFilename(typePath, slash)
  set dirLength = $length(sourceLocation, slash)
  set dirLengthLimit = dirLength - (dirLength - $length(absoluteBasePath, slash))

  // Slices the path at every iteration. Ex: /a/b/c -> /a/b -> /a
  // We do this to create a dependency chain based on those directories.
  for i=dirLength:-1:dirLengthLimit+1 {
    set dir = $piece(sourceLocation, slash, 1, i)
    if ..Whitelist.IsDefined(dir) return $$$OK
    set sc = ..Whitelist.SetAt(itemName, dir)
    if $$$ISERR(sc) quit
  }
  return sc
}

Method Purge() As %Status
{

  set sc = $$$OK
  set s = ##class(%SQL.Statement).%New()

  $$$QuitOnError(s.%PrepareClassQuery("%File", "FileSet"))

  set removedDirectories = ""
  set lastParent = ""
  set parentDirectory = ""

  write ..Tool.LogLine($$$CheckingExtraneousItems, 1)

  for i=1:1:$listlength(i%TypePaths) {
    set pathToSearch = $listget(i%TypePaths, i)
    set sc = ..Scan(s, pathToSearch)
    if $$$ISERR(sc) return sc
  }

  set length = $listlength(i%ExtraneousEntries)
  if length > 0 write ..Tool.LogLine($$$TotalExtraneousItems, 1, length)
  else  write ..Tool.LogLine($$$NoExtraneousItems, 1)

  for i=1:1:length {
    set path = $listget(i%ExtraneousEntries, i)
    do ..TreeDelete(s, path)
  }
  
  if length > 0 {
    write ..Tool.LogLine($$$TotalExtraneousItemsRemoved, 1, length)
  }
  
  return sc
}

Method TreeDelete(statement As %SQL.Statement, path As %String, hasContent As %Boolean = 0) [ Private ]
{
  if path = ..Tool.BasePath return $$$OK 
  
  // There's a bug when using Exists for directories, it seems to assume that a directory is also a file.
  // To workaround this, DirectoryExists is also applied because it WILL return 0.
  if '##class(%File).DirectoryExists(path) && ##class(%File).Exists(path) { 
    write ..Tool.LogLine($$$RemovingFile, 2, path)
    do ##class(%File).Delete(path) 
  } elseif hasContent = 0 { 
    else  write ..Tool.LogLine($$$RemovingDirectory, 2, path)
    do ##class(%File).RemoveDirectory(path)
  }
    
  set path = $piece(path, $$$OSSlash, 1, *-1)
  set r = statement.%Execute(path)
  set hasContent = 0
    
  if r.%Next(.sc) {
    if $$$ISERR(sc) return sc
    set hasContent = 1
  }  
  return ..TreeDelete(statement, path, hasContent)
}

Method Scan(statement As %SQL.Statement, path As %String, filesCount As %Integer = 0) As %Status [ Private ]
{

  set dir = $$$NFN(path)
  set dirType = ##class(Port.Util).GetPathType(path)
  // Need to convert from Port format to CSP legacy format.
  if dirType = "PUBLIC" set dirType = "CSP"

  set slash = $$$Slash(path)
  set row = statement.%Execute(dir)
  set sc = $$$OK

  while row.%Next(.sc) {
    if $$$ISERR(sc) quit
    set type = row.%Get("Type")
    set fullPath = row.%Get("Name")

    if ..Tool.IsIgnored(fullPath) continue

    if type = "D" {
      set filesCount = 0
      set sc = ..Scan(statement, fullPath, .filesCount)
      if $$$ISERR(sc) return sc
    } else {
      set filesCount =  filesCount + 1
    }

    if 'filesCount && $lf($$$ImportTypes, dirType) || ($lf($$$ImportTypes, dirType) && '..Whitelist.IsDefined(fullPath) && '$listfind(i%ExtraneousEntries, fullPath)) {      
      set $list(i%ExtraneousEntries, $listlength(i%ExtraneousEntries)+1) = fullPath
      
      // Handle test files created for classes.      
      if dirType = "CLS" {
        set className = $replace(##class(Port.Util).PathToItem(fullPath_".cls"), ".cls", "")        
        
        // Attempt to find the equivalent test class.
        if ##class(Port.UnitTest.Util).AssertTestableClass(className, .testableClass) {
          set fullPath = ##class(Port.UnitTest.Util).GetTestClassPath(testableClass, ..Tool.BasePath)
          // Only mark to remove if the test suite was exported as XML, regardless of what type of test format has been selected.                    
           set $list(i%ExtraneousEntries, $listlength(i%ExtraneousEntries)+1) = fullPath
        }
      }
    }
  }
  return sc
}

Method Reset() As %Status
{
  set i%ExtraneousEntries = ""
  return ..Whitelist.Clear()
}

}


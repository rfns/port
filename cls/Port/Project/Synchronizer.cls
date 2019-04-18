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
  set ..TypePaths = $lb(tool.BasePath)
  return $$$OK
}

Method AddToWhitelist(itemName As %String, sourceLocation As %String = "") As %Status [ Internal ]
{
   
  set sc = $$$OK
  set type = ##class(Port.Util).ResolveItemExtension(itemName)
  set typePath = ..Tool.GetTypePath(type)
  set slash = $$$Slash(typePath)  
  
  if sourceLocation = "" {
    set workspacePath = $piece(typePath, slash, 1, *-1)
    set sourceLocation = ##class(Port.Util).MountItemSourcePath(itemName, workspacePath)
  }
  
  if $extract(typePath) = "/" {
    set typePath = $extract(typePath, 2, *)
  }
    
  set absoluteBasePath = ##class(%File).NormalizeFilename(typePath, slash)
  set dirLength = $length(sourceLocation, slash)
  set dirLengthLimit = dirLength - (dirLength - $length(absoluteBasePath, slash))
  
  // Slices the path for every iteration. Ex: /a/b/c -> /a/b -> /a
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
    set possiblyDeleted = 0
    set extraneousItem = $listget(i%ExtraneousEntries, i)
    set path = $listget(extraneousItem, 1)
    set slash = $$$Slash(path)
    set type = $listget(extraneousItem, 2)
    if parentDirectory '= "" && (path [ parentDirectory) set possiblyDeleted = 1
    if type = "F" && ##class(%File).Exists(path) {
      set fileName = ##class(%File).GetFilename(path)
      set lastNode = ##class(%File).GetDirectoryPiece(parentDirectory, $length(parentDirectory, slash))
      set fileName = $piece(fileName, ".", 1)           
      if fileName = lastNode set possiblyDeleted = 0 
      if possiblyDeleted = 1 continue
      write ..Tool.LogLine($$$RemovingFile, 2, path)
      if ..Simulated = 0 do ##class(%File).Delete(path)
    } elseif type = "D" {
      if parentDirectory = "" || (path '[ parentDirectory) {
        set lastParent = parentDirectory
        set parentDirectory = $replace(path, ##class(%File).GetDirectoryPiece(path, $length(path, slash))_slash, "")
        if lastParent = "" set lastParent = parentDirectory
      }
      if possiblyDeleted = 1 continue
      write ..Tool.LogLine($$$RemovingDirectory, 2, path)
      if ..Simulated = 0 do ##class(%File).RemoveDirectoryTree(path)
    }
  } 
  if length > 0 {
    write ..Tool.LogLine($$$TotalExtraneousItemsRemoved, 1, length)
  }
  return sc
}

Method Scan(statement As %SQL.Statement, path As %String, filesCount As %Integer = 0) As %Status [ Private ]
{
   
  set dir = $$$NFN(path)
  set dirType = ##class(Port.Util).ExtractType(path, ..Tool.BasePath)
  // Need to convert from Port format to CSP legacy format.
  if dirType = "WEB" set dirType = "CSP"
  
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
      set $list(i%ExtraneousEntries, $listlength(i%ExtraneousEntries)+1) = $listbuild(fullPath, type)            
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


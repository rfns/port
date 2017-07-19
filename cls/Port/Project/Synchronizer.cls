Include portutils

Class Port.Project.Synchronizer Extends %RegisteredObject
{

Property ExtraneousEntries As %List [ Private ];

Property Whitelist As array Of %String [ Private ];

Property Tool As Port.Project.Base [ Private ];

Property TypePaths As %List [ Private ];

Method %OnNew(tool As Port.Project.Base) As %Status
{
  set ..Tool = tool
  do ..PrepareTypePathList()
  return $$$OK
}

Method PrepareTypePathList() [ Internal, Private ]
{
  // Kills CSP and CSR from the list and adds an empty entry, since /web should be the default path for unrecognized formats.
  // We force GetTypePath to default "" to project/web.
  set types = $lfs($piece($lts($$$ImportTypes), ",", 1, *-2)_",""")
  for i=1:1:$listlength(types) {
    set type = $listget(types, i)
    // We need to pass a dummy item to prevent it FROM falling into a falsy MAC type trap. e.g.: INC files.
    set $list(i%TypePaths, $listlength(i%TypePaths) + 1) = ..Tool.GetTypePath(type, "dummy."_type)
  }
}

Method AddToWhitelist(itemName As %String, sourceLocation As %String = "") As %Status [ Internal ]
{
   
  set sc = $$$OK
  set slash = $$$Slash
  set type = ##class(Port.Util).ResolveItemExtension(itemName)
  set typePath = ..Tool.GetTypePath(type)
  
  if sourceLocation = "" {
    set workspacePath = $piece(typePath, $$$Slash, 1, *-1)
    set sourceLocation = ##class(Port.Util).MountItemSourcePath(itemName, workspacePath)
  }
  
  if $extract(typePath) = "/" {
    set typePath = $extract(typePath, 2, *)
  }
    
  set absoluteBasePath = ##class(%File).NormalizeFilename(typePath, slash)
  set dirLength = $length(sourceLocation, slash)
  set dirLengthLimit = dirLength - (dirLength - $length(absoluteBasePath, slash))
  
  // Slices the path for every iteration. Ex: /a/b/c -> /a/b -> /a
  // This surely can be improved.
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
  
  set slash = $$$Slash
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
    set type = $listget(extraneousItem, 2)
    if parentDirectory '= "" && (path [ parentDirectory) set possiblyDeleted = 1
    if type = "F" && ##class(%File).Exists(path) {
      set fileName = ##class(%File).GetFilename(path)
      set lastNode = ##class(%File).GetDirectoryPiece(parentDirectory, $length(parentDirectory, slash))
      set fileName = $piece(fileName, ".", 1)           
      if fileName = lastNode set possiblyDeleted = 0 
      if possiblyDeleted = 1 continue
      write ..Tool.LogLine($$$RemovingFile, 2, path)
      do ##class(%File).Delete(path)        
    } elseif type = "D" {
      if parentDirectory = "" || (path '[ parentDirectory) {
        set lastParent = parentDirectory
        set parentDirectory = $replace(path, ##class(%File).GetDirectoryPiece(path, $length(path, slash))_slash, "")
        if lastParent = "" set lastParent = parentDirectory
      }
      if possiblyDeleted = 1 continue
      write ..Tool.LogLine($$$RemovingDirectory, 2, path)
      do ##class(%File).RemoveDirectoryTree(path)
    }
  } 
  if length > 0 {
    write ..Tool.LogLine($$$TotalExtraneousItemsRemoved, 1, length)
  }
  return sc
}

Method Scan(statement As %SQL.Statement, path As %String) As %Status [ Private ]
{
   
  set dir = $$$NFN(path)
  set row = statement.%Execute(dir)
  set sc = $$$OK
  
  while row.%Next(.sc) {
    if $$$ISERR(sc) quit
    set type = row.%Get("Type")    
    set fullPath = row.%Get("Name")     
    
    if ..Tool.IsIgnored(fullPath) continue
            
    if type = "D" {      
      set sc = ..Scan(statement, fullPath)
      if $$$ISERR(sc) return sc
    } 
    if '..Whitelist.IsDefined(fullPath) && '$listfind(i%ExtraneousEntries, fullPath) {
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


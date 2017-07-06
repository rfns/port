Class Port.Project.Exporter Extends Port.Project.Base
{

Property PathDependencies As array Of %String [ Private ];

Property ExportedPackages As %List [ Private ];

Method %OnNew(path As %String, logLevel As %Integer = 2, sourceExtension As %String = "") As %Status
{
  $$$QuitOnError(##super(path, logLevel, sourceExtension))  
       
  if '$isobject(..Project) {    
    set ..ProjectName = "null"
    throw ##class(%Exception.StatusException).CreateFromStatus($$$PERROR($$$ExportingProjectNotFound, ..ProjectName))
  }
  quit $$$OK
}

Method Export() As %Status
{
  
  set ..IsBatch = 1
  do ..Reset() 
  
  write ..LogLine($$$ExportingProject, 0, ..Project.Name)
  set cspDirectory = ##class(%File).NormalizeFilename($System.Util.InstallDirectory()_"csp/"_$$$lcase($namespace))
  
  $$$QuitOnError(##class(Port.Project.Helper).ImplyDirectoryCreation(cspDirectory))
  $$$QuitOnError(..ExportProjectItems(.exportList))
  
  if ..AffectedCount > 0 {
    write ..LogLine($$$SourceExportedToPath, 0, ..BasePath)
  } else {
    write ..LogLine($$$NoItemsToExport, 0, ..Project.Name)
  }
  
  write ..LogLine($$$SynchronizingProject, 0, ..Project.Name)
  $$$QuitOnError(..PurgeExtraneousEntries())
  
  write ..LogLine($$$AllDone, 0)
  quit $$$OK
}

Method SearchExtraneousEntries(statement As %SQL.Statement, path As %String, ByRef files As %List = "")
{
   
  set dir = ##class(%File).NormalizeDirectory(path)
  set row = statement.%Execute(dir)
  set sc = $$$OK
  
  while row.%Next(.sc) {
    if $$$ISERR(sc) quit
    set type = row.%Get("Type")    
    set fullPath = row.%Get("Name")     
    
    if ..IsIgnored(fullPath) continue
            
    if type = "D" {      
      set sc = ..SearchExtraneousEntries(statement, fullPath, .files)
      if $$$ISERR(sc) quit
    } 
    
    if '..PathDependencies.IsDefined(fullPath) {
      set length = $case(files, "": 1, : $listlength(files)+1)
      set $list(files, length) = $listbuild(fullPath, type)            
    }
  }
  quit sc
}

Method PurgeExtraneousEntries() As %Status
{
  set sc = $$$OK
  set s = ##class(%SQL.Statement).%New()
  $$$QuitOnError(s.%PrepareClassQuery("%File", "FileSet"))
  set removedDirectories = ""
  set lastParent = ""
  set parentDirectory = ""
  
  write ..LogLine($$$CheckingExtraneousItems, 1)
  
  for ipath = ..MacPath,..IntPath,..IncPath,..ClassPath,..BasPath,..WebPath,..MvbPath,..MviPath,..DfiPath {
    set sc = ..SearchExtraneousEntries(s, ipath, .extraneousFiles)
    if $$$ISERR(sc) quit
  }
  
  $$$QuitOnError(sc)
  
  set length = $listlength(extraneousFiles)  
  if length > 0 write ..Log($$$TotalExtraneousItems, 1, length), !
  else  write ..LogLine($$$NoExtraneousItems, 1)
  
  for i=1:1:length {
    set possiblyDeleted = 0
    set extraneousItem = $listget(extraneousFiles, i)
    set path = $listget(extraneousItem, 1)
    set type = $listget(extraneousItem, 2)
    if parentDirectory '= "" && (path [ parentDirectory) set possiblyDeleted = 1
    if type = "F" && ##class(%File).Exists(path) {
      set fileName = ##class(%File).GetFilename(path)
      set lastNode = ##class(%File).GetDirectoryPiece(parentDirectory, $length(parentDirectory, ..Slash))
      set fileName = $piece(fileName, ".", 1)           
      if fileName = lastNode set possiblyDeleted = 0 
      if possiblyDeleted = 1 continue
      write ..LogLine($$$RemovingFile, 2, path)
      do ##class(%File).Delete(path)        
    } elseif type = "D" {
      if parentDirectory = "" || (path '[ parentDirectory) {
        set lastParent = parentDirectory
        set parentDirectory = $replace(path, ##class(%File).GetDirectoryPiece(path, $length(path, ..Slash))_..Slash, "")
        if lastParent = "" set lastParent = parentDirectory
      }
      if possiblyDeleted = 1 continue
      write ..LogLine($$$RemovingDirectory, 2, path)
      do ##class(%File).RemoveDirectoryTree(path)
    }
  } 
  if length > 0 {
    write ..LogLine($$$TotalExtraneousItemsItemsRemoved, 1, length)
  }
  quit sc
}

Method ExportProjectItems(ByRef exportList As %List = "") As %Status [ Internal, Private ]
{
  set sc = $$$OK
  set s = ##class(%SQL.Statement).%New()
  $$$QuitOnError(s.%PrepareClassQuery("%Studio.Project", "ProjectItemsList"))
  set r = s.%Execute(..ProjectName, 1) 
  while r.%Next(.sc) {
    if $$$ISERR(sc) quit
    set itemName = r.%Get("Name")
    set itemType = r.%Get("Type")
    set sc = $$$ADDSC(sc, ..ExportItem(itemName, itemType, .exportList))
  }
  quit sc
}

Method ExportItem(itemName As %String, type As %String = "", ByRef exportList As %List = "") As %Status
{
  if ##class(Port.Project.Helper).IsRoutine(itemName) quit ..ExportRoutine(itemName)
  
  set itemType = $case(type, "": ##class(Port.Project.Helper).GetItemExtension(itemName), : type)
  
  if itemType = "CSP" quit ..ExportWebFile(itemName, .exportList)
  if itemType = "PKG" quit ..ExportPackage(itemName, .exportList)
  if itemType = "CLS" {
    set className = itemName
    set classLength = $length(itemName, ".")
    if $piece(itemName, ".", classLength) = "CLS" {
      set className = $extract(itemName, 1, $length(itemName) - 4)
    } 
    quit ..ExportClass(className, .exportList)
  }
  quit $$$OK
}

Method ExportPackage(packageName As %String, exportList As %String) As %Status
{
  if $listfind(i%ExportedPackages, packageName) quit $$$OK  
  
  set classList = $System.OBJ.GetPackageList(.classList, packageName)
  set className = ""
  set sc = $$$OK
  for {
    set className = $order(classList(className))
    quit:className=""
    set err = ..ExportClass(className)
    if $$$ISERR(err) {
      if $$$ISOK(sc) set sc = err
      else  set sc = $$$ADDSC(sc, err)
    }
  }
  set $list(exportList, *+1) = "cls/"_packageName
  set $list(i%ExportedPackages, *+1) = packageName
  quit sc
}

Method ExportWebFile(itemName As %String, ByRef exportList As %List = "") As %Status
{
  set name = itemName
  
  if $extract(itemName, 1) = "/" {
    set name = $extract(itemName, 2, *)
  }
  
  if '##class(%Studio.ProjectItem).%ExistsId(..Project.Name_"||"_name_"||CSP") {
    quit $$$OK
  } 
      
  $$$QuitOnError(##class(Port.Project.Helper).CSPLogicalToPhysicalPath(name, .source))
  set dest = ..NormalizeOutput(name, .path, .ext)  
  
  $$$QuitOnError(##class(Port.Project.Helper).ImplyDirectoryCreation(path))  
  do ..ExtractPathDependency(source, dest)
  
  if ..Overwrite = 0 && '..IsOutdated(source, dest) {
    quit $$$OK
  }
  
  write ..Log($$$ExportingType, 1, $$$ClassType, name)
  
  set exported = ##class(%File).CopyFile(source, dest)
  
  if exported = 0 {
    write ..LogLine($$$Failed)
    quit $$$PERROR($$$UnableToCopySource, source, dest)
  }
  
  write ..LogLine($$$Done)
  set ..AffectedCount = ..AffectedCount + 1
  
  set $list(exportList, *+1) = dest  
  quit $$$OK
}

Method ExportRoutine(name As %String, exportList As %List = "") As %Status
{
  do ##class(Port.Project.Helper).Describe(name, .extension, .type, .itemName) 
  
  if '##class(%Studio.ProjectItem).%ExistsId(..Project.Name_"||"_itemName_"||"_type) {
    quit $$$OK
  }

  set dest = ..NormalizeOutput(name, .path)  
  do ..ExtractPathDependency(name, dest)
  
  $$$QuitOnError(##class(Port.Project.Helper).ImplyDirectoryCreation(path))
    
  if '##class(%RoutineMgr).Exists(name) { 
    quit $$$PERROR($$$UnableToExportInvalidItem, name)
  }
  
  if ..Overwrite = 0 && '..IsOutdated(name, dest) {
    quit $$$OK
  }
  
  write ..Log($$$ExportingType, 1, $$$RoutineType, itemName)
  
  set file = ##class(%FileCharacterStream).%New()
  set file.Filename = dest
  
  set routine = ##class(%RoutineMgr).%OpenId(name)  
  set sc = file.CopyFrom(routine.Code)
  
  if $$$ISOK(sc) write ..LogLine($$$Done)
  else  write ..LogLine($$$Failed)
    
  set $list(exportList, *+1) = dest
  
  $$$QuitOnError(file.%Save())
  
  set ..AffectedCount = ..AffectedCount + 1
  quit $$$OK
}

Method IsClassProjectItem(itemName As %String) As %Boolean
{
  
  set exists = ##class(%Studio.ProjectItem).%ExistsId(..ProjectName_"||"_itemName_"||CLS")
  if 'exists {
    set classPartsLength = $length(itemName, ".")
    for i=1:1:classPartsLength - 1 {
      set exists = ##class(%Studio.ProjectItem).%ExistsId(..ProjectName_"||"_$piece(itemName, ".", 1, i)_"||PKG")
      if exists quit      
    }
  }
  quit exists
}

Method ExportClass(itemName As %String, ByRef exportList As %String = "") As %Status
{
  set package = $piece(itemName, ".", 1, *-1)
  set isProjectItem = ..IsClassProjectItem(itemName)
  
  if $listfind(..ExportedPackages, package) quit $$$OK
  
  if 'isProjectItem quit $$$OK
  
  set dest = ..NormalizeOutput(itemName_".CLS", .path)
  
  $$$QuitOnError(##class(Port.Project.Helper).ImplyDirectoryCreation(path))  
  do ..ExtractPathDependency(itemName, dest)
  
  if ..Overwrite = 0 && '..IsOutdated(itemName_".CLS", dest) {
    quit $$$OK
  }
  
  write ..Log($$$ExportingType, 1, $$$ClassType, itemName)   
  if '##class(%ClassDefinition).%ExistsId(itemName) write ..LogLine($$$Failed, 1)
  
  $$$QuitOnError(##class(%Compiler.UDL.TextServices).GetTextAsFile($namespace, itemName, dest))
  write ..LogLine($$$Done, 1)
  
  set ..AffectedCount = ..AffectedCount + 1
  set $list(exportList, *+1) = dest
  
  quit $$$OK
}

Method ExtractPathDependency(itemName As %String, destPath As %String) [ Final, Internal, Private ]
{
  set type = $$$ucase($piece(destPath, ".", *-1)) 
  set basePath = ..ResolvePathType(type)
  if $find($listbuild("", "/"), $extract(basePath)) {
    set basePath = $extract(basePath, 2, *)
  }
    
  set absoluteBasePath = ##class(%File).NormalizeFilename(basePath, ..Slash)
  set dirLength = $length(destPath, ..Slash)
  set dirLengthLimit = dirLength - (dirLength - $length(absoluteBasePath, ..Slash))
  
  // Slices the path for every iteration. Ex: /a/b/c -> /a/b -> /a
  for i=dirLength:-1:dirLengthLimit+1 {
    set dir = $piece(destPath, ..Slash, 1, i)    
    if ..PathDependencies.IsDefined(dir) quit
    do ..PathDependencies.SetAt(itemName, dir)
  }
}

Method Reset() As %Status
{
  set i%ExportedPackages = ""
  do ..PathDependencies.Clear()
}

}


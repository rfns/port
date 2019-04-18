Include portutils

Class Port.Project.Exporter Extends Port.Project.Base
{

Property ExportedPackages As %List [ Private ];

Property Synchronizer As Synchronizer [ Private ];

Method %OnNew(path As %String, logLevel As %Integer = 2, sourceExtension As %String = "") As %Status
{
  $$$QuitOnError(##super(path, logLevel, sourceExtension))  
       
  if '$isobject(..Project) {
    set ..ProjectName = "null"
    throw ##class(%Exception.StatusException).CreateFromStatus($$$PERROR($$$ExportingProjectNotFound, ..ProjectName))
  }
  set ..Synchronizer = ##class(Synchronizer).%New($this)
  return $$$OK
}

Method Export() As %Status
{
  
  set ..IsBatch = 1
  do ..Reset()
  
  write ..LogLine($$$ExportingProject, 0, ..Project.Name)
  
  $$$QuitOnError(..ExportProjectItems())
  
  if ..AffectedCount > 0 {
    write ..LogLine($$$SourceExportedToPath, 0, ..BasePath)
  } else {
    write ..LogLine($$$NoItemsToExport, 0, ..Project.Name)
  }
  
  write ..LogLine($$$SynchronizingProject, 0, ..Project.Name)
  
  $$$QuitOnError(..Synchronizer.Purge())
  
  write ..LogLine($$$AllDone, 0)
  return $$$OK
}

Method ExportProjectItems() As %Status [ Private ]
{
  set sc = $$$OK
  set s = ##class(%SQL.Statement).%New()
  $$$QuitOnError(s.%PrepareClassQuery("%Studio.Project", "ProjectItemsList"))
  set r = s.%Execute(..ProjectName, 1) 
  while r.%Next(.sc) {
    if $$$ISERR(sc) quit
    set itemName = r.%Get("Name")
    set itemType = r.%Get("Type")
    set sc = $$$ADDSC(sc, ..ExportItem(itemName, itemType))
  }
  return sc
}

Method ExportItem(itemName As %String, type As %String = "") As %Status
{
  if ##class(Port.Util).IsRoutine(itemName) return ..ExportRoutine(itemName)
  
  set itemType = $case(type, "": ##class(Port.Util).ResolveItemExtension(itemName), : type)
  if itemType = "PKG" return ..ExportPackage(itemName)
  if itemType = "CLS" return ..ExportClass(itemName)
  
  return ..ExportWebFile(itemName)
}

Method ExportPackage(packageName As %String) As %Status
{
  set id = ##class(Port.Util).MountIdFromName(packageName_".PKG", ..Project.Name)
  // Cannot assume that the package is always present in the project, 
  // even if the project has some classes from it.
  if '##class(%Studio.ProjectItem).%ExistsId(id) return $$$OK
  
  if $listfind(i%ExportedPackages, packageName) return $$$OK  
  
  set classList = $System.OBJ.GetPackageList(.classList, packageName)
  set className = ""
  set sc = $$$OK
  for {
    set className = $order(classList(className))
    quit:className=""
    set err = ..ExportClass(className, 1)
    if $$$ISERR(err) {
      if $$$ISOK(sc) set sc = err
      else  set sc = $$$ADDSC(sc, err)
    }
  }
  set $list(i%ExportedPackages, *+1) = packageName
  return sc
}

Method ExportWebFile(itemName As %String) As %Status
{
  set id = ##class(Port.Util).MountIdFromName(itemName, ..Project.Name)  
  if '##class(%Studio.ProjectItem).%ExistsId(id) {
    return $$$PERROR($$$UnableToExportInvalidItem, itemName)
  }  
      
  $$$QuitOnError(##class(Port.Util).CSPLogicalToPhysicalPath(itemName, .source))
  set dest = ##class(Port.Util).GetItemSourcePathFromWorkspace(itemName, ..Project.Name)
  set path = ##class(%File).GetDirectory(dest) 
  
  $$$QuitOnError(##class(Port.Util).CreateMissingPath(path))
  $$$QuitOnError(..Synchronizer.AddToWhitelist(itemName))
  
  if ..Overwrite = 0 && '..IsOutdated(itemName, dest) return $$$OK
  
  write ..Log($$$ExportingType, 1, $$$FileType, dest)
  set exported = ##class(%File).CopyFile(source, dest, 1)  
  
  if exported = 0 {
    write ..LogLine($$$Failed)
    return $$$PERROR($$$UnableToCopySource, source, dest)
  }
  
  write ..LogLine($$$Done)
  set ..AffectedCount = ..AffectedCount + 1
  
  return $$$OK
}

Method ExportRoutine(name As %String) As %Status
{
  set id = ##class(Port.Util).MountIdFromName(name, ..Project.Name)
  
  if '##class(%Studio.ProjectItem).%ExistsId(id) {
    return $$$PERROR($$$UnableToExportInvalidItem, name)
  }

  set dest = ##class(Port.Util).GetItemSourcePathFromWorkspace(name, ..Project.Name, ..SourceExtension)  
  set path = ##class(%File).GetDirectory(dest)
  
  $$$QuitOnError(..Synchronizer.AddToWhitelist(name))
  
  if '##class(%RoutineMgr).Exists(name) return $$$PERROR($$$UnableToExportInvalidItem, name)
  $$$QuitOnError(##class(Port.Util).CreateMissingPath(path))
      
  if ..Overwrite = 0 && '..IsOutdated(name, dest) return $$$OK
  
  write ..Log($$$ExportingType, 1, $$$RoutineType, name)
  
  set file = ##class(%Stream.FileCharacter).%New()
  set file.TranslateTable = "UTF8"
  do file.LinkToFile(dest)  
  
  set routine = ##class(%RoutineMgr).%OpenId(name)  
  set sc = file.CopyFrom(routine.Code)
  
  if $$$ISERR(sc) write ..LogLine($$$Failed) return sc 
  
  write ..LogLine($$$Done)
  
  $$$QuitOnError(file.%Save())
  
  set ..AffectedCount = ..AffectedCount + 1
  return $$$OK
}

Method ExportClass(className As %String, fromPackage As %Boolean = 0) As %Status
{
  
  // Checks if this entry is coming from %SourceControl and fixes it removing the CLS type.
  if ##class(Port.Util).ResolveItemExtension(className) = "CLS" {
    set className = $piece(className, ".", 1, *-1)
  } 
  
  set itemName = className_".CLS"
  
  // Cannot export classes that don't belong to the project.
  set id = ##class(Port.Util).MountIdFromName(itemName, ..Project.Name)
  // Cannot check for the class item id if the call was delegated by ExportPackage.
  if 'fromPackage && '##class(Port.Util).ExistsInProject(..Project.Name, itemName) {
    return $$$PERROR($$$UnableToExportInvalidItem, itemName)
  }
  
  set package = $piece(itemName, ".", 1, *-1)
  set dest = ##class(Port.Util).GetItemSourcePathFromWorkspace(itemName, ..Project.Name, ..SourceExtension)
  set path = ##class(%File).GetDirectory(dest)  
  
  $$$QuitOnError(..Synchronizer.AddToWhitelist(itemName))
  if $listfind(..ExportedPackages, package) return $$$OK  
  
  $$$QuitOnError(##class(Port.Util).CreateMissingPath(path))
  
  if ..Overwrite = 0 && '..IsOutdated(itemName, dest) return $$$OK
  else  do ##class(%File).Delete(dest)
  
  write ..Log($$$ExportingType, 1, $$$ClassType, className)
  
  if '##class(%ClassDefinition).%ExistsId(className) {
    write ..LogLine($$$Failed)
    return $$$ERROR($$$UnableToExportInvalidItem, className)
  }
  
  $$$QuitOnError(##class(%Compiler.UDL.TextServices).GetTextAsStream($namespace, itemName, .stream))
  set file = ##class(%Stream.FileCharacter).%New()
  set file.TranslateTable = "UTF8"
  do file.LinkToFile(dest)
  $$$QuitOnError(file.CopyFromAndSave(stream))
  
  write ..LogLine($$$Done)
  
  set ..AffectedCount = ..AffectedCount + 1
  
  return $$$OK
}

Method Reset() As %Status
{
  set i%ExportedPackages = ""
  do ..Synchronizer.Reset()
}

}


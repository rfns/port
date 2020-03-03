Include portutils

/// This is the utility used to export the source code to the workspace.
Class Port.Project.Exporter Extends Port.Project.Base
{

/// A list of packages that are already exported, this is used to prevent items from the same package from being exported again.
Property ExportedPackages As %List [ Private ];

/// A reference for the sychronizer, which keeps the workspace directory sync'ed with the project items.
Property Synchronizer As Synchronizer [ Private ];

Method %OnNew(path As %String, logLevel As %Integer = 2) As %Status
{
  $$$QuitOnError(##super(path, logLevel))

  if '$isobject(..Project) {
    set ..Project.Name = "null"
    throw ##class(%Exception.StatusException).CreateFromStatus($$$PERROR($$$ExportingProjectNotFound, ..Project.Name))
  }
  set ..Synchronizer = ##class(Synchronizer).%New($this)
  return $$$OK
}

/// Exports the project to the provided workspace.
Method Export() As %Status
{

  set ..IsBatch = 1
  do ..Reset()

  write ..LogLine($$$ExportingProject, 0, ..Project.Name)

  $$$QuitOnError(..ExportProjectItems())

  if ..AffectedCount > 0 {
    write ..LogLine($$$SourceExportedToPath, 0, ..BasePath)
    write ..LogLine($$$SynchronizingProject, 0, ..Project.Name)
    write ..LogLine($$$AllDone, 0)
  } else {
    write ..LogLine($$$NoItemsToExport, 0, ..Project.Name)
  }

  $$$QuitOnError(..Synchronizer.Purge())
  return $$$OK
}

Method ExportProjectItems() As %Status [ Private ]
{
  set sc = $$$OK
  set s = ##class(%SQL.Statement).%New()
  $$$QuitOnError(s.%PrepareClassQuery("%Studio.Project", "ProjectItemsList"))
  set r = s.%Execute(..Project.Name, 1)
  while r.%Next(.sc) {
    if $$$ISERR(sc) quit
    set itemName = r.%Get("Name")
    set itemType = r.%Get("Type")
    set sc = $$$ADDSC(sc, ..ExportItem(itemName, itemType))
  }
  return sc
}

/// Exports a single item from the project to the workspace.
Method ExportItem(itemName As %String, type As %String = "") As %Status
{
  if ##class(Port.Util).IsRoutine(itemName) return ..ExportRoutine(itemName)

  set itemType = $case(type, "": ##class(Port.Util).GetItemType(itemName), : type)
  if itemType = "PKG" return ..ExportPackage(itemName)
  if itemType = "CLS" return ..ExportClass(itemName)

  return ..ExportPublicFile(itemName)
}

/// Exports a class package and all its classes added by the project.
Method ExportPackage(packageName As %String) As %Status
{
  set id = ##class(Port.Util).ResolveItemId(packageName_".PKG", ..Project.Name)
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

/// Exports a CSP-like file to the workspace's public folder.
/// The CSP application name is mirrored into subfolders inside the public folder.
Method ExportPublicFile(itemName As %String) As %Status
{
  set sc = $$$OK
  set id = ##class(Port.Util).ResolveItemId(itemName, ..Project.Name)
  set exported = 0  

  if '##class(%Studio.ProjectItem).%ExistsId(id) {
    return $$$PERROR($$$UnableToExportInvalidItem, itemName)
  }  

  set workspace = ##class(Port.Configuration).GetWorkspace(..Project.Name)
  set extension = $piece(itemName, ".", *)

  try {
    set csp = ##class(%RoutineMgr).%New(itemName)
    set destination = ##class(Port.Util).ItemToPath(itemName, workspace)
    set destinationLocation = ##class(%File).GetDirectory(destination)

    write ..Log($$$ExportingType, 1, $$$FileType, destination)

    $$$ThrowOnError(##class(Port.Util).EnsurePathExists(destinationLocation))
    $$$ThrowOnError(..Synchronizer.AddToWhitelist(itemName))

    if ..Overwrite = 0 && '..IsOutdated(itemName, destination) {
      write ..LogLine($$$UpToDate)
      quit
    }

    set io = $$$GETIO
    
    $$$SETIO(##class(Port.Configuration).GetOutputCharset(extension))
    set exported = ##class(%File).CopyFile(csp.Code.Filename, destination, 1)
    $$$SETIO(io)

    write ..LogLine($$$Done)
    set ..AffectedCount = ..AffectedCount + 1
  } catch ex {
    set sc = ex.AsStatus()
    if exported = 0 {
      if $$$ISOK(sc) set sc = $$$PERROR($$$UnableToCopySource, source, dest)
    }
    write ..LogLine($$$Failed, 1, $System.Status.GetErrorText(sc))
  }
  quit $$$OK
}

/// Export a routine to the workspace, the path inside the workspace is taken from the type of routine to be exported.
Method ExportRoutine(name As %String) As %Status
{
  set sc = $$$OK

  try {
    write ..Log($$$ExportingType, 1, $$$RoutineType, name)

    set id = ##class(Port.Util).ResolveItemId(name, ..Project.Name)

    if '##class(%Studio.ProjectItem).%ExistsId(id) {
      return $$$PERROR($$$UnableToExportInvalidItem, name)
    }

    set workspace = ##class(Port.Configuration).GetWorkspace(..Project.Name)
    set destination = ##class(Port.Util).ItemToPath(name, workspace)
    set destinationLocation = ##class(%File).GetDirectory(destination)
    set extension = $piece(name, ".", *)

    $$$ThrowOnError(..Synchronizer.AddToWhitelist(name))

    if '##class(%RoutineMgr).Exists(name) $$$ThrowStatus($$$PERROR($$$UnableToExportInvalidItem, name))
    $$$ThrowOnError(##class(Port.Util).EnsurePathExists(destinationLocation))

    if ..Overwrite = 0 && '..IsOutdated(name, destination) {
      write ..LogLine($$$UpToDate)
      quit
    }

    set file = ##class(%Stream.FileCharacter).%New()
    set file.TranslateTable = ##class(Port.Configuration).GetOutputCharset(extension)
    do file.LinkToFile(destination)

    set routine = ##class(%RoutineMgr).%OpenId(name)
    set sc = file.CopyFrom(routine.Code)

    $$$ThrowOnError(file.%Save())
    write ..LogLine($$$Done)

    set ..AffectedCount = ..AffectedCount + 1
  } catch ex {
    set sc = ex.AsStatus()
    write ..LogLine($$$Failed, 1, $System.Status.GetErrorText(sc))
  }

  quit sc
}

/// Export a class to the workspace's 'cls' folder. Each class package is treated like a subfolder.
Method ExportClass(className As %String, fromPackage As %Boolean = 0) As %Status
{
  set sc = $$$OK

  set itemName = className

  // If the call is from the source control remove the suffix.
  if ##class(Port.Util).GetItemType(className) = "CLS" {
    set className = $piece(className, ".", 1, *-1)
  } else {
    // But we still must ensure that a qualified item name is available.
    set itemName = itemName_".CLS"
  }

  try {
    write ..Log($$$ExportingType, 1, $$$ClassType, className)

    // We can rely on the id if the call is delegated by ExportPackages, so we only check it if the class is exported single-handedly.
    if 'fromPackage && '##class(Port.Util).ExistsInProject(..Project.Name, itemName) {
      $$$ThrowStatus($$$PERROR($$$UnableToExportInvalidItem, itemName))
    }

    set workspace = ##class(Port.Configuration).GetWorkspace(..Project.Name)
    set package = $piece(itemName, ".", 1, *-1)
    set destination = ##class(Port.Util).ItemToPath(itemName, workspace)
    set destinationLocation = ##class(%File).GetDirectory(destination)

    $$$ThrowOnError(..Synchronizer.AddToWhitelist(itemName))
    if $listfind(..ExportedPackages, package) quit

    $$$ThrowOnError(##class(Port.Util).EnsurePathExists(destinationLocation))

    if ..Overwrite = 0 && '..IsOutdated(itemName, destination) {
      write ..LogLine($$$UpToDate)
      quit
    }

    if '##class(%ClassDefinition).%ExistsId(className) {
      $$$ThrowStatus($$$PERROR($$$UnableToExportInvalidItem, className))
    }

    $$$ThrowOnError(##class(%Compiler.UDL.TextServices).GetTextAsStream($namespace, itemName, .stream))

    set file = ##class(%Stream.FileCharacter).%New()
    set file.TranslateTable = ##class(Port.Configuration).GetOutputCharset("CLS")
    do file.LinkToFile(destination)

    $$$ThrowOnError(file.CopyFromAndSave(stream))
    write ..LogLine($$$Done, 1)

    set ..AffectedCount = ..AffectedCount + 1
    set isUsingXML = (##class(Port.Configuration).GetTestFormat() = "XML")
    
    if ##class(Port.UnitTest.Util).AssertTestableClass(className, .testableClass) && isUsingXML {
      set xmlExporter = ##class(Port.Project.XMLExporter).%New(..BasePath, ..LogLevel)
      do xmlExporter.ExportTest(testableClass, .sc)
      $$$ThrowOnError(sc)
    }
  } catch ex {
    set sc = ex.AsStatus()
    write ..LogLine($$$Failed, 1, $System.Status.GetErrorText(sc))
  }

  quit sc
}

Method Reset() As %Status [ Internal ]
{
  set i%ExportedPackages = ""
  do ..Synchronizer.Reset()
}

}


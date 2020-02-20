Include (portutils, %sySystem)

Class Port.Project.Importer Extends Port.Project.Base
{

Property IsNewProject As %Boolean [ InitialExpression = 0, Private ];

Property Backup As Port.Project.Backup [ Private ];

Property BackupDirectory As %String [ Internal ];

Property SkipBackup As %Boolean [ InitialExpression = 0 ];

Property ImportList As %String [ InitialExpression = 0, MultiDimensional ];

Property ItemsList As %String [ InitialExpression = 0, MultiDimensional, Private ];

Method %OnNew(inputPath As %String, logLevel As %Integer = 2, sourceExtension As %String = "") As %Status
{
  $$$QuitOnError(##super(inputPath, logLevel))

  set ..BackupDirectory = $$$NFN(..BasePath_"/__backup__/")
  set ..Backup = ##class(Port.Project.Backup).%New(..BackupDirectory)
  set ..Backup.Logger = ..Logger

  set i%ImportList = 0
  set i%ItemsList = 0

  if '$isobject(..Project) {
    set ..IsNewProject = 1
    set ..Project = ##class(%Studio.Project).%New()
    set ..Project.Name = ..Project.Name
  }
  quit $$$OK
}

Method EnqueueAll() As %Status
{
  do ..ResetLists()

  set sc = $$$OK
  for i = ..IncPath, ..IntPath, ..ClassPath, ..MacPath, ..BasPath, ..MviPath, ..MvbPath, ..DfiPath, ..PublicPath {
    set sc = ..EnqueueDirectory(i)
    if $$$ISERR(sc) quit
  }
  quit sc
}

Method EnqueueItem(origin As %String) As %Status
{
  $$$QuitOnError(..DescribeItem(origin, .isOutdated, .itemName, .itemType, .group))
  
  // Skip this item because it's invalid.
  if group = -1 return $$$OK

  if '$data(i%ItemsList(itemName)) {
    if '..Backup.IsRequired && '..SkipBackup && ((itemType = "CSP") && isOutdated) {
      set ..Backup.IsRequired = 1
    }
    set i%ItemsList = $increment(i%ItemsList)
    set i%ItemsList(itemName) = ""

    if isOutdated || ..Overwrite {
      set i%ImportList = $increment(i%ImportList)
      set i%ImportList(group, itemType, itemName) = origin
    }
  }
  quit $$$OK
}

Method EnqueueDirectory(searchPath As %String, fs As %SQL.Statement = {$$$NULLOREF}) As %Status
{

  if '..IsBatch && '$isobject(fs) {
    do ..ResetLists()
  }

  if ..IsIgnored(searchPath) quit $$$OK

  if '$isobject(fs) {
    set fs = ##class(%SQL.Statement).%New()
    $$$QuitOnError(fs.%PrepareClassQuery("%File", "FileSet"))
  }

  set sc = $$$OK
  set rows = fs.%Execute(searchPath)

  set slash = $$$Slash(searchPath)

  while rows.%Next(.sc) {
    if $$$ISERR(sc) quit
    set compilable = 0
    set type = rows.%Get("Type")
    set external = rows.%Get("Name")
    if type = "F" {
      set sc = ..EnqueueItem(external)
      if $$$ISERR(sc) quit
    } elseif type = "D" {
      set targetDir = $piece(external, slash, *)
      if '(targetDir?1".".AN) {
        set sc = ..EnqueueDirectory(external, fs)
        if $$$ISERR(sc) quit
      }
    }
  }
  quit sc
}

Method GetTypePriority(type As %String) As %Integer [ Internal, Private ]
{
  if type = "INC" quit 1
  if type = "INT" quit 2
  if type = "CLS" quit 3
  if type = "MAC" quit 4
  if type = "MVI" quit 5
  if type = "MVB" quit 6
  if type = "BAS" quit 7
  if type = "DFI" quit 8
  quit 9
}

Method DescribeItem(origin As %String, Output isOutdated As %Boolean = 0, Output itemName As %String, Output itemType As %String, Output priority As %String) As %Status [ Internal, Private ]
{
 
  set fileName = ##class(%File).GetFilename(origin)     
  set emptyName = ($piece(fileName, ".") = "")
  set pathType = ##class(Port.Util).GetPathType(origin)
  
  set isOutdated = 1
  set itemName = ##class(Port.Util).PathToItem(origin)
  set itemType = ##class(Port.Util).GetItemType(itemName)  
  set priority = ..GetTypePriority(itemType)
  
  if emptyName || (pathType '= itemType && (pathType '= "PUBLIC")) {
    set itemName = ""
    set itemType = ""
    set priority = -1
    set isOutdated = 0
  } elseif '..Overwrite {
    set isOutdated = ..IsOutdated(itemName, origin, 1)
  }
  
  quit $$$OK
}

Method ImportList() As %Status [ Internal, Private ]
{
  set sc = $$$OK

  for i=1:1:10 {
   set sc = ..ImportType(i)
   if $$$ISERR(sc) {
    set typeSC = $$$PERROR($$$ErrorsWhileImportingType, $listget($$$ImportTypeDescriptions, i))
    set typeSC = $$$EMBEDSC(typeSC, sc)
    set sc = typeSC quit
   }
  }
  quit sc
}

Method ImportType(group As %Integer) As %Status [ Internal, Private ]
{
  set sc = $$$OK
  if '$data(i%ImportList(group)) quit sc
  set itemType = $listget($$$ImportTypes, group, "CSP")

  write ..LogExclusiveLine($$$ImportingType, 1, $$$GetGroupTypeDescription(itemType))

  set itemName = ""
  for {
    quit:'$data(i%ImportList(group))
    set itemName = $order(i%ImportList(group, itemType, itemName), 1, modifiedFilePath)
    quit:itemName=""

    write ..LogExclusive($$$ImportingType, 2, $$$GetTypeDescription(itemType), itemName)

    set sc = ..ImportFromExternalSource(itemName, modifiedFilePath,  itemType)
    if $$$ISERR(sc)  write ..LogExclusiveLine($$$Failed, 2) quit
    else  write ..LogExclusiveLine($$$Done, 2)
  }
  quit sc
}

Method ImportPartial(target As %String, Output importedList As %String = 0) As %Status
{
 
  set sc = $$$OK
    
  set resolvedTarget = ##class(Port.Util).ItemToPath(target, ..BasePath)

  if resolvedTarget '[ ..BasePath {
    quit $$$PERROR($$$AmbiguousPartialToWorkspace, resolvedTarget)
  }

  if '(resolvedTarget [ ..ClassPath || (resolvedTarget [ ..IncPath) ||
      (resolvedTarget [ ..IntPath)  || (resolvedTarget [ ..MacPath) ||
      (resolvedTarget [ ..PublicPath)
  ) {
    quit $$$PERROR($$$SupressedAttemptToExportFromOutside)
  }   

  if ##class(%File).DirectoryExists(resolvedTarget) {
    write ..Log($$$EnqueingType, 1, $$$DirectoryType)
    set sc = ..EnqueueDirectory(resolvedTarget)
  } elseif ##class(%File).Exists(resolvedTarget) {
    write ..Log($$$EnqueingType, 1, "item")
    set sc = ..EnqueueItem(resolvedTarget)
  } else {
    write ..Log($$$NothingToImport)
    quit sc
  }

  if sc {
    write ..LogLine($$$Done)
    set sc = ..Import()
    if $$$ISOK(sc) {
      set importedList = i%ImportList
      merge importedList = i%ImportList
    }
  } else {
    write ..LogLine($$$Failed)
  }
  quit sc
}

Method Import() As %Status
{
  set sc = $$$OK
  set onlyPopulateProject = 0
  set ..AffectedCount = 0

  tstart

  try {
    if ..IsBatch {
      write ..LogLine($$$ImportingProject, 0, ..Project.Name)
      write ..LogLine($$$EnqueueingItems, 0)
      $$$ThrowOnError(..EnqueueAll())
    }

    if i%ImportList > 0 {
      write ..LogLine($$$TotalItemsToImport, 0, i%ImportList)
      merge list = i%ImportList
      if '..SkipBackup $$$ThrowOnError(..Backup.Create(.list))
      $$$ThrowOnError(..ImportList())
    } else {
      write ..LogLine($$$NoPendingItemsToImport, 0)
    }

    if ..IsNewProject {      
      write ..LogLine($$$NewProject, 0, ..Project.Name)
    }

    if i%ImportList > 0 {
      write ..LogLine($$$SynchronizingProject, 0, ..Project.Name)
      $$$ThrowOnError(..SynchronizeProject())
      write ..LogLine($$$ProjectSaved, 0, ..Project.Name, ..Project.Items.Count())
    }

    set ..AffectedCount = i%ImportList

    if ..Backup.IsRequired && '..SkipBackup {
      // If anything is ok until here, then delete the backup.
      write ..Log($$$RemovingBackupMirror, 0)
      set isRemoved = ##class(%File).RemoveDirectoryTree(..BackupDirectory)
      if isRemoved {
        write ..LogLine($$$Done, 0)
        set ..Backup.IsRequired = 0
      } else  {
        write ..LogLine($$$Failed, 0)
        $$$ThrowOnError($$$PERROR($$$UnableToRemoveDirectory, ..BackupDirectory))
      }
    }
    $$$ThrowOnError(..Project.%Save())
    tcommit
  } catch ex {
    set sc = ex.AsStatus()
    write !!, ..LogLine($$$FatalErrorAlert, 0)
    write $System.Status.GetErrorText(sc), !!

    write ..LogLine($$$FatalRollbackAlert, 0), !
    write ..LogLine($$$FatalProjectIntegrityRiskWarning, 0)
    write ..Log($$$FatalRollingBackTransaction, 0)

    trollback
    write ..LogLine($$$Done, 0)

    if ..Backup.IsRequired {
      write ..LogLine($$$FatalApplyingBackup, 0)
      set backupSC = ..Backup.Rollback()
      if $$$ISERR(backupSC) {
        write ..LogLine($$$FatalFailedToRestoreBackup, 0)
        set sc = $$$ADDSC(sc, backupSC)
      } else {
        do ##class(%File).RemoveDirectoryTree(..BackupDirectory)
      }
    }
  }
  quit sc
}

ClassMethod ImportFromExternalSource(itemName As %String, origin As %String, itemType As %String) As %Status [ Final, Internal, Private ]
{
  set extension = $$$ucase($piece(origin, ".", *))
	set tt = ##class(Port.Configuration).GetInputCharset(extension)

	if (itemType = "CLS") {
    set fs = ##class(%Stream.FileCharacter).%New()
    set fs.TranslateTable = tt
    $$$QuitOnError(fs.LinkToFile(origin))
    $$$QuitOnError(##class(%Compiler.UDL.TextServices).SetTextFromStream($namespace, itemName, fs))
  } elseif ##class(Port.Util).IsRoutine(itemName) || (itemType = "CSP") {
    if itemName [ "/" set itemName = $$$LPadProvidedSlash(itemName, "/")     
    
    if ##class(%RoutineMgr).Exists(itemName) {
      set routine = ##class(%RoutineMgr).%OpenId(itemName)
    } else {
      set routine = ##class(%RoutineMgr).%New(itemName)
    }
    
    set localSource = ##class(%Stream.FileCharacter).%New()
    set localSource.TranslateTable = tt
    
    if itemType = "CSP" {  
      if routine = "" return $$$PERROR($$$NoCompatibleApplicationForPublicFile, origin)      
      if extension = "" set extension = "TXT"
      do ##class(%CSP.StreamServer).FileClassify(extension, .type, .bin)
      if extension [ "CSP" || (extension = "CSR") set bin = 0
                 
      /// We can't use any translation table when importing a binary, so we do a bit-to-bit copy.
      if bin {
        set destination = routine.Code.Filename
        set path = ##class(%File).GetDirectory(routine.Code.Filename)        
        set routine = ""
        set localSource = ""
        $$$QuitOnError(##class(Port.Util).EnsurePathExists(path))
        $$$QuitOnError(##class(%File).CopyFile(origin, destination))
        return $$$OK
      } else {                
        set localSource.TranslateTable = tt
        set routine.Code.TranslateTable = tt
      }
    }    
            
    set code = routine.Code
    do code.Clear()
    
    $$$QuitOnError(localSource.LinkToFile(origin))
    $$$QuitOnError(code.CopyFrom(localSource))
    $$$QuitOnError(routine.%Save())
  }
  quit $$$OK
}

Method SynchronizeProject() As %Status [ Internal, Private ]
{
  set (sc, scc) = $$$OK
  set itemName = ""

  #dim item As %Studio.Project

  // We must check and remove all invalid items if the user desires to import everything
  // from the repository.
  if ..IsBatch $$$QuitOnError(..Project.Check())

  // Now that the project is clear, we add the new items.
  for {
    set itemName = $order(i%ItemsList(itemName), 1, type)
    quit:itemName=""

    set pSC = ..Project.AddItem(itemName)

    if ($$$ISERR(pSC) && $$$GETERRORCODE(pSC)) = $$$ProjectIncludesPackage {
      set package = itemName
      for i=1:1:$length(package, ".") {
        set packagePart = $piece(package, 1, *-i)
        set exists = ##class(Port.Util).ExistsInProject(..Project.Name, packagePart_".PKG")
        if exists {
          set sc = $$$ADDSC(sc, ..Project.RemoveItem(package))
          set sc = $$$ADDSC(sc, ..Project.AddItem(itemName))
        }
      }
    }
  }
  set ssc = ..Project.%Save()
  set scc = $$$EMBEDSC(scc, sc)
  quit scc
}

Method ResetLists()
{

  kill i%ImportList, i%ItemsList
  set (i%ImportList, i%ItemsList) = 0
}

}


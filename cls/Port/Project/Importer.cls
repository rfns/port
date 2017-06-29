Include portutils

Class Port.Project.Importer Extends Port.Project.Base
{

Property IsNewProject As %Boolean [ InitialExpression = 0, Private ];

Property CSPPath As %String [ Private ];

Property Backup As Port.Project.Backup [ Private ];

Property BackupDirectory As %String [ Internal ];

Property SkipBackup As %Boolean [ InitialExpression = 0 ];

Property ImportList As %String [ InitialExpression = 0, MultiDimensional ];

Property ItemsList As %String [ InitialExpression = 0, MultiDimensional, Private ];

Method %OnNew(inputPath As %String, logLevel As %Integer = 2, sourceExtension As %String = "") As %Status
{
  $$$QuitOnError(##super(inputPath, logLevel, sourceExtension))
  
  set installDirectory = $System.Util.InstallDirectory()
  
  set ..CSPPath = ##class(%File).NormalizeFilename(installDirectory_"csp/"_$$$lcase($namespace))  
  set ..BackupDirectory = ##class(%File).NormalizeFilename(..BasePath_"/__backup__/")
  set ..Backup = ##class(Port.Project.Backup).%New(..BackupDirectory)
  set ..Backup.Logger = ..Logger
  
  set i%ImportList = 0
  set i%ItemsList = 0
  
  if '$isobject(..Project) {
    set ..IsNewProject = 1
    set ..Project = ##class(%Studio.Project).%New()
    set ..Project.Name = ..ProjectName
  }
  quit $$$OK
}

Method EnqueueAll() As %Status
{
  do ..ResetLists()
  
  set sc = $$$OK
  for i = ..IncPath, ..IntPath, ..ClassPath, ..MacPath, ..BasPath, ..MviPath, ..MvbPath, ..DfiPath, ..WebPath {
    set sc = ..EnqueueDirectory(i)
    if $$$ISERR(sc) quit
  }
  quit sc
}

Method EnqueueItem(target As %String) As %Status
{
  set isWebPath = target [ ..WebPath  
  
  set sc = ..Describe(target, isWebPath, .described, .isOutdated, .internalFileName, .itemName, .itemType, .group, .alias)
  $$$QuitOnError(sc)
  
  if described && '$data(i%ItemsList(itemName)) {
    if '..Backup.IsRequired && '..SkipBackup && ((itemType = "CSP") || (itemType = "CSR") && isOutdated) {
      set ..Backup.IsRequired = 1
    }
    set i%ItemsList = $increment(i%ItemsList)
    set i%ItemsList(itemName) = ""  
        
    if isOutdated || ..Overwrite {
      set i%ImportList = $increment(i%ImportList)
      set i%ImportList(group, itemType, alias) = $listbuild(target, internalFileName)
    }    
    set enqueued = 1
  } 
  quit enqueued
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
  
  while rows.%Next(.sc) {
    if $$$ISERR(sc) quit 
    set compilable = 0
    set type = rows.%Get("Type")
    set external = rows.%Get("Name")
    if type = "F" { 
      set sc = ..EnqueueItem(external) 
      if $$$ISERR(sc) quit
    } elseif type = "D" {
      set targetDir = $piece(external, ..Slash, *)
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
  if type = ".INC" quit 1
  if type = ".INT" quit 2
  if type = ".CLS" quit 3
  if type = ".MAC" quit 4
  if type = ".MVI" quit 5
  if type = ".MVB" quit 6
  if type = ".BAS" quit 7
  if type = ".DFI" quit 8
  if type = ".CSR" quit 9
  quit 10
}

Method Describe(origin As %String, isWebPath As %Boolean = 0, described As %Boolean = 0, Output isOutdated As %Boolean = 0, Output itemDestination As %String, Output itemName As %String, Output itemType As %String, Output priority As %String, Output alias As %String) As %Status [ Internal, Private ]
{
  
  set described = 0 
  set extension = ..GetFileExtension(origin, isWebPath)
  set extSize = $length(..GetSourceExtension())
  
  if 'isWebPath $$$QuitOnError(..AssertValidExtension(origin))
  
  if '(extension?1".".AN) quit described
  if extension = "" quit described  
    
  set priority = ..GetTypePriority(extension)
  
  if extension = ".CLS" {
    set itemType = "CLS"
    set itemDestination = ##class(Port.Project.Helper).FileToClass(origin)      
    set itemName = itemDestination_extension
    set alias = itemDestination
    set described = 1
  } elseif $listfind($$$RoutineExtensions, extension) {
    set itemType = $piece(extension, ".", 2)    
    set itemDestination = $extract(##class(%File).GetFilename(origin), 1, *-(4 + extSize))_extension
    set itemName = itemDestination
    set alias = itemName
    set described = 1
  } else {
    if extension = ".CSR" set itemType = "CSR"
    else  set itemType = "CSP"
    $$$QuitOnError(##class(Port.Project.Helper).CSPPhysicalToLogicalPath(origin, .logicalPath))
    $$$QuitOnError(##class(Port.Project.Helper).CSPLogicalToPhysicalPath(logicalPath, .physicalPath))
    set itemName = logicalPath
    set itemDestination = physicalPath    
    set alias = itemName
    set described = 1
  }
  
  if '..Overwrite {
    set isOutdated = ..IsOutdated(itemName, origin, 1)
  } else {
    set isOutdated = 1
  }
  quit $$$OK
}

Method ImportList() As %Status [ Internal, Private ]
{
  set sc = $$$OK  
  
  for i=1:1:10 {
   set sc = ..ImportType(i)
   if $$$ISERR(sc) {
    set typeSC = $$$ERROR($$$GeneralError, "There were errors while importing "_$listget($$$ImportTypeDescriptions, i)_".")
    set typeSC = $$$EMBEDSC(typeSC, sc)
    set sc = typeSC 
   }
  }  
  quit sc
}

Method ImportType(group As %Integer) As %Status [ Internal, Private ]
{
  set sc = $$$OK
  if '$data(i%ImportList(group)) quit sc  
  set itemType = $listget($$$ImportTypes, group, "CSP")
  
  write ..LogExclusive($$$ImportingType, 1, $$$GetGroupTypeDescription(itemType))
  
  set itemName = ""
  for {
    quit:'$data(i%ImportList(group))
    set itemName = $order(i%ImportList(group, itemType, itemName), 1, paths)
    quit:itemName=""
    
    set origin = $listget(paths, 1)
    set destination = $listget(paths, 2, itemName)
    
    write ..Log($$$ImportingType, 2, $$$GetTypeDescription(itemType), destination)
    
    set sc = $$$ADDSC(sc, ..ImportFromExternalSource(itemName, origin,  itemType, destination))
    if $$$ISERR(sc)  write ..Log($$$Failed, 2), ! continue
    else  write ..Log($$$Done, 2), !
  }
  write ..LogExclusive($$$Done, 1), !
  quit sc
}

Method ImportPartial(target As %String, importedList As %String = 0) As %Status
{
  
  #define NormalizePath(%path)  ##class(%File).NormalizeFilename(%path)
  set sc = $$$OK
  
  set resolvedTarget = ##class(%File).NormalizeFilename(target, ..BasePath)
  
  if (resolvedTarget = ..BasePath) {
    quit $$$PERROR($$$AmbiguousPartialToWorkspace, resolvedTarget)
  }
  
  if '(resolvedTarget [ ..ClassPath || (resolvedTarget [ ..IncPath) ||
      (resolvedTarget [ ..IncPath)  || (resolvedTarget [ ..MacPath) ||
      (resolvedTarget [ ..WebPath)) {    
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
    write ..Log($$$Done), !
    set sc = ..Import()
    if $$$ISOK(sc) {
      set importedList = i%ImportList
      merge importedList = i%ImportList
    }
  } else {
    write ..Log($$$Failed), !
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
      write ..Log($$$ImportingProject, 0, ..Project.Name), !
      write ..Log($$$EnqueueingItems, 0), !
      $$$ThrowOnError(..EnqueueAll())
    }
      
    if i%ImportList > 0 {
      write ..Log($$$TotalItemsToImport, i%ImportList), !
      merge list = i%ImportList
      if '..SkipBackup $$$ThrowOnError(..Backup.Create(.list))
      $$$ThrowOnError(..ImportList())
    } else {
      write ..Log($$$NoPendingItemsToImport, 0), !
    }
         
    if ..IsNewProject {
      write ..Log($$$NewProject, 0, ..Project.Name), !
    }
    
    if i%ImportList {
      write ..Log($$$SynchronizingProject, 0, ..Project.Name), !
      $$$ThrowOnError(..SynchronizeProject(.added, .removed))
      write ..Log($$$Done, 1), !
      write ..Log($$$ProjectSaved, 0, ..Project.Name, ..Project.Items.Count()), !    
    }
    
    set ..AffectedCount = i%ImportList    
    
    if ..Backup.IsRequired && '..SkipBackup {
      // If anything is ok until here, then delete the backup.
      write ..Log($$$RemovingBackupMirror, 1)
      set isRemoved = ##class(%File).RemoveDirectoryTree(..BackupDirectory)
      if isRemoved { 
        write ..Log($$$Done, 0)
        set ..Backup.IsRequired = 0
      } else  {
        write ..Log($$$Failed, 0)
        $$$ThrowOnError($$$PERROR(UnableToRemoveDirectory, ..BackupDirectory))
      }
      write !
    }
    tcommit     
  } catch ex {
    set sc = ex.AsStatus()
    write ..Log($$$FatalErrorAlert, 0), !!
    do $System.OBJ.DisplayError(sc)
    write ..Log($$$FatalRollbackAlert, 0), !
    write ..Log($$$FatalProjectIntegrityRiskWarning, 0), !
    write ..Log($$$FatalRollingBackTransaction, 0), !

    trollback
    
    if ..Backup.IsRequired {
      write ..Log($$$FatalApplyingBackup, 0), !
      set isCopied = ##class(%File).CopyDir(..BackupDirectory, ..CSPPath, 1)
      if 'isCopied { 
        write ..Log($$$FatalFailedToRestoreBackup, 0), !
        set sc = $$$ADDSC(sc, $$$PERROR($$$UnableToCopySource, ..BackupDirectory, ..CSPPath))
      }  
    }
  }
  quit sc
}

ClassMethod ImportFromExternalSource(itemName As %String, origin As %String, fileType As %String, destination As %String = "") As %Status [ Final, Internal, Private ]
{
  set sc = $$$OK 
  
  if (fileType = "CLS") {      
    $$$QuitOnError(##class(%Compiler.UDL.TextServices).SetTextFromFile($namespace, itemName, origin))
  } elseif ##class(Port.Project.Helper).IsRoutine(itemName) {
    set routine = ""
    set fs = ##class(%FileCharacterStream).%New()
    set fs.Filename = origin
    
    if ##class(%RoutineMgr).Exists(itemName) {      
      set routine = ##class(%RoutineMgr).%OpenId(itemName)           
    } else {
      set routine = ##class(%RoutineMgr).%New(itemName)
    }
        
    set code = routine.Code
    do code.Clear()
    
    $$$QuitOnError(code.CopyFrom(fs))
    set sc = code.Save()
  } else {
    set destinationPath = ##class(%File).GetDirectory(destination)
    $$$QuitOnError(##class(Port.Project.Helper).ImplyDirectoryCreation(destinationPath))    
    set isCopied = ##class(%File).CopyFile(origin, destination, 1)
    if isCopied = 0 {
      set sc = $$$ERROR($$$GeneralError, "Unable to copy "_origin_" to destination.")
    }
  }
  quit sc
}

Method GetFileExtension(path As %String, isWebPath As %Boolean) As %String [ Internal, Private ]
{
  if $piece(path, ..Slash, *)?1"."3A quit ""
  if isWebPath || (..GetSourceExtension() = "") {
    set sliceSize = 0
  } else {
    set sliceSize = 1
  }
  // -1 to ignore last piece (.txt) when not inside web path or when source extension is not provided.
  quit "."_$zconvert($piece(path, ".", *-sliceSize), "U")
}

Method SynchronizeProject(Output addedCount As %String = 0, Output removedCount As %String = 0) As %Status
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
    
    set sc = $$$ADDSC(sc, ..Project.AddItem(itemName))    
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

Method AssertValidExtension(origin As %String) As %Status [ Final, Internal, Private ]
{
  set sourceFileExtension = "."_$$$ucase($piece(origin, ".", *))
  
  if $listfind($$$RoutineExtensions, sourceFileExtension) || (sourceFileExtension = ".CLS") {
    set sourceFileExtension = ""
  }  
  
  if (sourceFileExtension '= $$$ucase(..GetSourceExtension())) {
    write !, sourceFileExtension, " - ", $$$ucase(..GetSourceExtension())
    set fileName = ##class(%File).GetFilename(origin)
    set expectedSourceExtension = $select(..SourceExtension = "" : $$$KeepCacheExtension, 1: $$$FormatMsg("Port Errors", $$$OvewriteWithExtension, ..SourceExtension))
    quit $$$PERROR($$$UnableToDescribeItem, fileName, expectedSourceExtension)
  }
  quit $$$OK
}

}


Include (portutils, %sySystem)

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
  
  set ..CSPPath = ##class(Port.Configuration).GetWebAppPath()
  set ..BackupDirectory = $$$NFN(..BasePath_"/__backup__/")
  set ..Backup = ##class(Port.Project.Backup).%New(..BackupDirectory)
  set ..Backup.Logger = ..Logger
  
  set i%ImportList = 0
  set i%ItemsList = 0
  
  if '$isobject(..Project) {
    set ..IsNewProject = 1
    set ..Project = ##class(%Studio.Project).%New()
    set ..Project.Name = ..ProjectName
  }
  return $$$OK
}

Method EnqueueAll() As %Status
{
  do ..ResetLists()
  
  set sc = $$$OK
  for i = ..IncPath, ..IntPath, ..ClassPath, ..MacPath, ..BasPath, ..MviPath, ..MvbPath, ..DfiPath, ..WebPath {
    set sc = ..EnqueueDirectory(i)
    if $$$ISERR(sc) quit
  }
  return sc
}

Method EnqueueItem(target As %String) As %Status
{
  set isWebPath = target [ ..WebPath   
  
  $$$QuitOnError(..Describe(target, isWebPath, .described, .isOutdated, .internalFileName, .itemName, .itemType, .group, .alias))  
  
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
  }
  return $$$OK
}

Method EnqueueDirectory(searchPath As %String, fs As %SQL.Statement = {$$$NULLOREF}) As %Status
{
  
  if '..IsBatch && '$isobject(fs) {
    do ..ResetLists()
  }
  
  if ..IsIgnored(searchPath) return $$$OK
  
  if '$isobject(fs) {
    set fs = ##class(%SQL.Statement).%New()
    $$$QuitOnError(fs.%PrepareClassQuery("%File", "FileSet"))
  }
  
  set sc = $$$OK
  set rows = fs.%Execute(searchPath)
  
  set slash = $$$Slash
  
  while rows.%Next(.sc) {
    if $$$ISERR(sc) return 
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
  return sc
}

Method GetTypePriority(type As %String) As %Integer [ Internal, Private ]
{
  if type = ".INC" return 1
  if type = ".INT" return 2
  if type = ".CLS" return 3
  if type = ".MAC" return 4
  if type = ".MVI" return 5
  if type = ".MVB" return 6
  if type = ".BAS" return 7
  if type = ".DFI" return 8
  if type = ".CSR" return 9
  return 10
}

Method Describe(origin As %String, isWebPath As %Boolean = 0, described As %Boolean = 0, Output isOutdated As %Boolean = 0, Output itemDestination As %String, Output itemName As %String, Output itemType As %String, Output priority As %String, Output alias As %String) As %Status [ Internal, Private ]
{
  
  set described = 0 
  set extension = ..GetFileExtension(origin, isWebPath)
  set extSize = $length(..GetSourceExtension())
  
  if 'isWebPath $$$QuitOnError(..AssertValidExtension(origin))
  
  if '(extension?1".".AN) return described
  if extension = "" return described  
    
  set priority = ..GetTypePriority(extension)
  set pathType = ##class(Port.Util).ExtractType(origin, ..BasePath)    
  
  set isRoutineFromExtension = $lf($$$RoutineExtensions, extension)
  set isRoutineFromPath = $lf($$$RoutineExtensions,  "."_pathType)
  set isClassFromExtension = (extension = ".CLS")
  set isClassFromPath = pathType = "CLS" 
  
  if isClassFromExtension && isClassFromPath  {
    set itemType = "CLS"
    set itemDestination = ##class(Port.Util).FileToClass(origin)
    set itemName = itemDestination_extension
    set alias = itemDestination
    set described = 1
  } elseif isRoutineFromExtension && isRoutineFromPath {
    set itemType = $piece(extension, ".", 2)    
    set itemDestination = $extract(##class(%File).GetFilename(origin), 1, *-(4 + extSize))_extension
    set itemName = itemDestination
    set alias = itemName
    set described = 1
  } elseif 'isRoutineFromExtension && 'isRoutineFromPath && 'isClassFromExtension && (pathType = "WEB") {
    if extension = ".CSR" set itemType = "CSR"
    else  set itemType = "CSP"
    $$$QuitOnError(##class(Port.Util).CSPPhysicalToLogicalPath(origin, .logicalPath))
    $$$QuitOnError(##class(Port.Util).CSPLogicalToPhysicalPath(logicalPath, .physicalPath))
    set itemName = logicalPath
    set itemDestination = physicalPath    
    set alias = itemName
    set described = 1
  }
  
  if described && '..Overwrite {
    set isOutdated = ..IsOutdated(itemName, origin, 1)
  } else {
    set isOutdated = 1
  }
  return $$$OK
}

Method ImportList() As %Status [ Internal, Private ]
{
  set sc = $$$OK  
  
  for i=1:1:10 {
   set sc = ..ImportType(i)
   if $$$ISERR(sc) {
    set typeSC = $$$PERROR($$$ErrorsWhileImportingType, $listget($$$ImportTypeDescriptions, i))
    set typeSC = $$$EMBEDSC(typeSC, sc)
    return sc
   }
  }  
  return sc
}

Method ImportType(group As %Integer) As %Status [ Internal, Private ]
{
  set sc = $$$OK
  if '$data(i%ImportList(group)) return sc  
  set itemType = $listget($$$ImportTypes, group, "CSP")
  
  write ..LogExclusive($$$ImportingType, 1, $$$GetGroupTypeDescription(itemType))
  
  set itemName = ""
  for {
    quit:'$data(i%ImportList(group))
    set itemName = $order(i%ImportList(group, itemType, itemName), 1, paths)
    quit:itemName=""
    
    set origin = $listget(paths, 1)
    set destination = $listget(paths, 2, itemName)
    
    write ..LogExclusive($$$ImportingType, 2, $$$GetTypeDescription(itemType), destination)
    
    set sc = ..ImportFromExternalSource(itemName, origin,  itemType, destination)
    if $$$ISERR(sc)  write ..LogExclusiveLine($$$Failed, 2) return sc
    else  write ..LogExclusiveLine($$$Done, 2)
  }
  write ..LogExclusiveLine($$$Done, 1)
  return sc
}

Method ImportPartial(target As %String, importedList As %String = 0) As %Status
{
  
  set sc = $$$OK
  
  set resolvedTarget = ##class(%File).NormalizeFilename(target, ..BasePath)
  
  if (resolvedTarget = ..BasePath) {
    return $$$PERROR($$$AmbiguousPartialToWorkspace, resolvedTarget)
  }
  
  if '(resolvedTarget [ ..ClassPath || (resolvedTarget [ ..IncPath) ||
      (resolvedTarget [ ..IncPath)  || (resolvedTarget [ ..MacPath) ||
      (resolvedTarget [ ..WebPath)
  ) {       
    // TODO: Resolver problema com exportação a partir da raiz da pasta csp ou web.        
    return $$$PERROR($$$SupressedAttemptToExportFromOutside)
  }  
  
  if ##class(%File).DirectoryExists(resolvedTarget) {
    write ..Log($$$EnqueingType, 1, $$$DirectoryType)
    set sc = ..EnqueueDirectory(resolvedTarget)
  } elseif ##class(%File).Exists(resolvedTarget) {
    write ..Log($$$EnqueingType, 1, "item")
    set sc = ..EnqueueItem(resolvedTarget)
  } else {
    write ..Log($$$NothingToImport)
    return sc
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
  return sc
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
        $$$ThrowOnError($$$PERROR(UnableToRemoveDirectory, ..BackupDirectory))
      }
    }    
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
      set isCopied = ##class(%File).CopyDir(..BackupDirectory, ..CSPPath, 1)
      if 'isCopied { 
        write ..LogLine($$$FatalFailedToRestoreBackup, 0)
        set sc = $$$ADDSC(sc, $$$PERROR($$$UnableToCopySource, ..BackupDirectory, ..CSPPath))
      }  
    }
  }
  return sc
}

ClassMethod ImportFromExternalSource(itemName As %String, origin As %String, fileType As %String, destination As %String = "") As %Status [ Final, Internal, Private ]
{
  set sc = $$$OK  
  
  if (fileType = "CLS") {      
    $$$QuitOnError(##class(%Compiler.UDL.TextServices).SetTextFromFile($namespace, itemName, origin))
  } elseif ##class(Port.Util).IsRoutine(itemName) {                
    if ##class(Port.Util).ExtractType(origin) = "DFI" {
      quit ##class(%DeepSee.UserLibrary.Utils).%Import(origin,1,0)
    }
    
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
    $$$QuitOnError(code.Save())
    $$$QuitOnError(routine.%Save())
  } else {
    set destinationPath = ##class(%File).GetDirectory(destination)
    $$$QuitOnError(##class(Port.Util).CreateMissingPath(destinationPath))    
    set isCopied = ##class(%File).CopyFile(origin, destination, 1)
    if isCopied = 0 {
      set sc = $$$PERROR($$$UnableToCopySource, origin, destinationPath)
    }
  }
  return sc
}

Method GetFileExtension(path As %String, isWebPath As %Boolean) As %String [ Internal, Private ]
{
  if $piece(path, ..Slash, *)?1"."3A return ""
  if isWebPath || (..GetSourceExtension() = "") {
    set sliceSize = 0
  } else {
    set sliceSize = 1
  }
  // -1 to ignore last piece (.txt) when not inside web path or when source extension is not provided.
  return "."_$zconvert($piece(path, ".", *-sliceSize), "U")
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
        set exists = ##class(Port.Util).ExistsInProject(..ProjectName, packagePart_".PKG")
        if exists {
          set sc = $$$ADDSC(sc, ..Project.RemoveItem(package))
          set sc = $$$ADDSC(sc, ..Project.AddItem(itemName))
        } 
      }
    }
  }
  set ssc = ..Project.%Save()
  set scc = $$$EMBEDSC(scc, sc)
  return scc
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
    set fileName = ##class(%File).GetFilename(origin)
    set formattedMsg = $select(
      ..SourceExtension = "" : $$$FormatMsg("Port Log Messages", $$$KeepCacheExtension), 
      1: $$$FormatMsg("Port Log Messages", $$$OvewriteWithExtension, ..SourceExtension)
    )
    return $$$PERROR($$$UnableToDescribeItem, fileName, formattedMsg)
  }
  return $$$OK
}

}


Include portutils

Class Port.Util [ Abstract ]
{

ClassMethod ResolveItemExtension(itemName As %String) As %String
{
  set ext = $$$ucase($piece(itemName, ".", *))
  set slash = $$$Slash(itemName)
  if $lf($$$RoutineExtensions, "."_ext) || (itemName [ "/") || (ext = "CLS") || (ext = "PRJ") return ext

  if ..IsPackage(itemName) return "PKG"
  return ext
}

ClassMethod IsPackage(itemName) As %Boolean
{
  if itemName = "" return 0
  if $get(^oddPKG($$$ucase(itemName))) '= "" return 1
  do $System.OBJ.GetPackageList(.l, itemName)
  if $data(l) return 1

  return 0
}

ClassMethod GetItemSourcePathFromWorkspace(itemName As %String, projectName As %String = {$get(^||Port.Project)}, sourceExtension = {##class(Port.Configuration).GetSourceExtension()}) As %String
{
  set defaultPath = $$$NFN(##class(Port.Configuration).GetWorkspace(projectName))
  return ..MountItemSourcePath(itemName, defaultPath, sourceExtension)
}

ClassMethod MountItemNameFromSourcePath(sourcePath As %String, Output itemName As %String = "", namespace As %String = {$namespace}, sourceExtension = {##class(Port.Configuration).GetSourceExtension()}) As %Status
{
  set itemName = ""

  if sourceExtension '= "" {
    set type = $piece(sourcePath, ".", *-1)
  } else {
    set type = $piece(sourcePath, ".", *)
  }

  set uppercaseType = $$$ucase(type)
  set sourcePath = $$$NFN(sourcePath)
  set slash = $$$Slash(sourcePath)

  if ..IsRoutine("dummy."_uppercaseType) || (uppercaseType = "CLS") {
    set candidateRoutinePath = sourcePath
    if $extract(candidateRoutinePath) '= "/" set candidateRoutinePath = "/"_candidateRoutinePath
    set itemName = $replace($piece(candidateRoutinePath, slash_type_slash, 2, *), slash, ".")_sourceExtension
    return $$$OK
  }

  $$$QuitOnError(..CSPPhysicalToLogicalPath(sourcePath, .itemName, namespace))
  return $$$OK
}

ClassMethod MountItemSourcePath(itemName As %String, workspacePath As %String, sourceExtension = {##class(Port.Configuration).GetSourceExtension()}) As %String [ Internal ]
{
  set fullPath = ""
  set type = ..ResolveItemExtension(itemName)

  if type = "CLS" {
    set fullPath = ..ClassToFile(workspacePath_"/cls", $piece(itemName, ".", 1, *-1))
  } elseif ..IsRoutine(itemName) {
    set slash = $$$Slash(itemName)
    set itemName = $piece(itemName, slash, *)
    set ext = $$$lcase(type)
    set fileName = itemName_$select(sourceExtension '= "" : "."_sourceExtension, 1: "")
    set $piece(fileName, ".", *) = ext
    set fullPath = $$$NFN(workspacePath_"/"_ext_"/"_fileName)
  } elseif type = "PKG" {
    // Deep package?
    set name = $replace(itemName, ".PKG", "")
    set fullPath = ..ClassToFile(workspacePath_"/cls", name, sourceExtension, 0)
  } else {
    if $extract(itemName, 1) = "/" set itemName = $extract(itemName, 2, *)
    set sourceFilePath = $replace(itemName, $System.CSP.GetAppName(itemName), "/web/")
    set fullPath = $$$NFN(workspacePath_sourceFilePath)
  }
  return fullPath
}

ClassMethod ExtractType(absolutePath As %String, workspace As %String = {##class(Port.Configuration).GetWorkspace()}) As %String
{

  set absolutePath = $$$NFN(absolutePath)
  set absoluteWorkspacePath = $$$NFN(workspace)
  if absolutePath '[ absoluteWorkspacePath return $$$PERROR($$$CouldNotDetermineWorkspace)
  set slash = $$$Slash(absoluteWorkspacePath)

  // + 1 considering the type directory.
  set directoryLength = $length(absoluteWorkspacePath, slash)
  return $$$ucase($piece(absolutePath, slash, directoryLength + 1))
}

ClassMethod MountIdFromName(name As %String, projectName As %String = {$get(^||Port.Project)}) As %String
{
  set nameOnly = $piece(name, ".", 1, *-1)
  set maskedMacs = $lb("BAS", "INT", "INC", "MVI")
  set itemName = name
  set id = ""

  set extension = ..ResolveItemExtension(name)

  if ..IsRoutine(name) {
    set itemType = extension
    if $lf(maskedMacs, itemType) set itemType = "MAC"
    set itemName = nameOnly_"."_extension
  } elseif extension = "CLS" {
    set itemName = nameOnly
    set itemType = extension
  } elseif extension = "PKG" {
    set itemName = nameOnly
    set itemType = "PKG"
  } else {
    // Ensures that CSP items starts with normalized path.
    if $extract(name, 1) = "/" {
      set itemName = $replace(name, "/", "", 1, 1)
    }
    set itemType = "CSP"
  }
  return projectName_"||"_itemName_"||"_itemType
}

ClassMethod CSPLogicalToPhysicalPath(cspItem As %String, Output absolutePath As %String = "", namespace As %String = {$namespace}) As %Status
{
  set slash = $$$Slash(absolutePath)
  if $extract(cspItem, 1) = "/" set cspItem = $extract(cspItem, 2, *)
  set cspAppDirectory = $System.CSP.GetAppName(cspItem)
  if cspAppDirectory = "" return $$$PERROR($$$NamespaceDoesntHaveAppWithPath, namespace)
  set cspAppDirectory = $extract(cspAppDirectory, 1, *-1)
  set absolutePath = $$$NFN($replace(cspItem, cspAppDirectory, ##class(Port.Configuration).GetWebAppPath()))
  return $$$OK
}

ClassMethod CSPPhysicalToLogicalPath(physicalPath As %String, Output logicalPath As %String, namespace As %String = {$namespace}) As %Status
{
  set slash = $$$Slash(physicalPath)
  set webFilePath = $extract(physicalPath, $find(physicalPath, slash_"web"_slash), *)
  if '$find($$$NFN(slash_physicalPath), slash_"web"_slash) {
    return $$$PERROR($$$InvalidPhysicalPath, $$$NFN(physicalPath))
  }

  set cspAppPath = ..AttemptToFindProjectCSPApp(physicalPath, namespace)
  if cspAppPath = "" return $$$PERROR($$$NamespaceDoesntHaveAppWithPath, $namespace)
  if $extract(cspAppPath, *) '[ "/" set cspAppPath = cspAppPath_"/"
  set logicalPath = $extract(cspAppPath, 2, *)_$replace(webFilePath, "\", "/")
  return $$$OK
}

ClassMethod AttemptToFindProjectCSPApp(externalPath As %String, namespace As %String = {$namespace}) As %String [ Private ]
{
  set matchingCSPPath = ""
  set candidateCSPPaths = $System.CSP.FilenameToUrls(externalPath)
  &sql(SELECT TOP 1 NAME INTO :matchingCSPPath FROM %STUDIO.PROJECTITEM WHERE NAME %INLIST(:candidateCSPPaths) AND TYPE = 'CSP')
  set cspApp = $piece(matchingCSPPath, "/", 1, *-1)
  if cspApp = "" set cspApp = ..FindApplicationWithPhysicalPath(namespace)
  return cspApp
}

ClassMethod IsRoutine(itemName As %String) As %Boolean
{
  set extension = ..ResolveItemExtension(itemName)

  if extension = "MAC"  || (extension = "INT") ||
    (extension = "MVB") || (extension = "MVI") ||
    (extension = "BAS") || (extension = "INC") ||
    (extension = "DFI") {
    return 1
  }
  return 0
}

ClassMethod ClassToFile(workspacePath As %String, className As %String, extension As %String = {##class(Port.Configuration).GetSourceExtension()}, appendCLS As %Boolean = 1)
{
  set cls = $case(appendCLS, 1: ".cls", : "")
  set slash = $$$Slash(workspacePath)

  if extension '= "" set extension = "."_extension

  return $$$NFN(workspacePath_slash_$replace(className, ".", slash)_cls_extension)
}

ClassMethod FileToClass(path As %String, extension As %String = {##class(Port.Configuration).GetSourceExtension()}) As %String
{
  set slash = $$$Slash(path)
  set path = $$$NFN(path)
  set fileName = ##class(%File).GetFilename(path)
  set extSize = $length($select(extension = "" : $piece(fileName, ".", *), 1: ".cls"_extension))
  set contextPath = $extract(path, $find(path, slash_"cls") + 1, ($length(path) - 1) - extSize)
  return $replace(contextPath, slash, ".")
}

ClassMethod ExistsInProject(projectName As %String, name As %String, type As %String = "", namespace As %String = {$namespace}) As %Boolean [ Internal ]
{

  new $namespace
  set $namespace = namespace

  try {
    do ##class(%Studio.Project).NormalizeName(.name, .type)

    set s = ##class(%SQL.Statement).%New()
    do s.%PrepareClassQuery("%Studio.Project", "ProjectItemsList")
    set r = s.%Execute(projectName)

    while r.%Next(.sc) {
      set itemName = r.%Get("Name")
      set itemType = r.%Get("Type")
      if itemType = type && ($$$lcase(itemName) = $$$lcase(name)) {
        do ##class(%Studio.Project).NormalizeName(.itemName, .itemType)
        if itemName = name return 1
      }
    }
  } catch ex {
    return 0
  }

  return 0
}

ClassMethod GetProjectFromResolvedPath(workspacePath As %String, Output project As %Studio.Project = "") As %Status
{
  set projectName = $piece(workspacePath, $$$PathSlash(workspacePath), *)
  set project = ##class(%Studio.Project).%OpenId(projectName)

  if $isobject(project) {
    // Ensure that the project name reported matches the existing one.
    set projectName = project.Name
    return project
  } elseif $data(^Port.Configuration("workspace.project")) {
    // Attempt to locate the project name by matching the path.
    set project = $$ScanWorkspacesRegistry(workspacePath)
  }

  if '$isobject(project) {
    quit $$$PERROR($$$ExportingProjectNotFound, projectName)
  }

  return $$$OK

ScanWorkspacesRegistry(intendedPath)
  set workspaceProject = ""
  for {
    set workspaceProject = $order(^Port.Configuration("workspace.project", workspaceProject), 1, candidatePath)
    quit:workspaceProject=""

    set resolvedPath = ##class(Port.Configuration).RewritePlaceHolders(candidatePath, projectName, $lb("{NAMESPACE}","{INSTALLDIR}","{PROJECT}","{USERNAME}"))

    if candidatePath = intendedPath {
      return ##class(%Studio.Project).%OpenId(workspaceProject)
    }
  }
  return ""
}

ClassMethod ListConflicts(projectName As %String, name As %String, type As %String = "") As %List
{
  do ##class(%Studio.Project).NormalizeName(.name, .type)
  if type = "CLS" set packages = $$SplitPackages(name)
  &sql(
    SELECT
      LIST(DISTINCT P.NAME) INTO :ubiquitousEntries
    FROM
      %STUDIO.PROJECTITEM PI
    LEFT OUTER JOIN
      %STUDIO.PROJECT P ON P.ID = PI.Project
    WHERE
      P.NAME <> :projectName AND (
       -- This deals with common cases.
       (:type NOT IN ('PKG', 'CLS') AND PI.NAME = :name) OR
       -- This deals with cases where a project is trying to add a package that is
       -- depended by another class in another project.
       (:type = 'PKG' AND PI.NAME %STARTSWITH :name) OR
       -- This deals with attempts to add classes that are owned by another project's
       -- package.z
       (:type = 'CLS' AND PI.NAME %INLIST(:packages))
      )
  )
  return $lfs(ubiquitousEntries)

SplitPackages(className)
  set splittedPackages = ""
  set packageLength = $length(className, ".")
  for i=packageLength:-1:2 {
    set $list(splittedPackages, *+1) = $piece(className, ".", 1, i)
  }
  quit splittedPackages
}

ClassMethod CreateMissingPath(path As %String) As %Status
{
  set absolutePath = $$$NFN(path)
  set isCreated = 1
  if '##class(%File).DirectoryExists(absolutePath)  {
    set isCreated = ##class(%File).CreateDirectoryChain(absolutePath)
    if isCreated = 0 {
      return $$$PERROR($$$CannotCreateDirectory, absolutePath)
    }
  }
  return $$$OK
}

ClassMethod GetIgnoredPaths(projectName As %String = {$get(^||Port.Project)}) As %ListOfDataTypes
{
  set workspaceDir = ##class(Port.Configuration).GetWorkspace(projectName)
  set ignoredPaths = ##class(%ListOfDataTypes).%New()

  set f = ##class(%FileCharacterStream).%New()
  set f.Filename = workspaceDir_"/.portignore"

  if f.Size > 0 {
    while 'f.AtEnd {
      do ignoredPaths.Insert(f.ReadLine())
    }
  }
  return ignoredPaths
}

ClassMethod TranslatePath(path As %String, OSFormat As %Integer = {$zversion(1)}) As %String
{
  // Unix
  if OSFormat = 3 {
    if $extract(path, 1, 2)?1A1":" {
      set path = $extract(path, 3, *)
    }
    return $replace(path, "\", "/")
  // Windows
  } elseif OSFormat = 2 {
    set path = $replace(path, "/", "\")
    if $extract(path) = "\" {
      set path = ##class(%File).NormalizeFilename("\")_path
    }
  }
  return path
}

ClassMethod ResolveWorkspaceFromPath(file As %String) As %String
{
  set types = $lfs($$$RoutinesGroups_",WEB,CLS,OTH")
  set slash = $$$Slash(file)
  for i=1:1:$ll(types) {
    set type = $$$lcase($lg(types, i))
    set pathType = slash_type_slash
    if file [ pathType {
      set chainParts = $lfs(file, slash)
      set typeIndex = $lf(chainParts, type)
      return $piece(file, slash, 1, typeIndex - 1)
    }
  }
  return ""
}

ClassMethod IsOutdated(project As %String, current As %String, external As %String, isImport As %Boolean = 0)
{
  if '##class(%File).Exists(external) return 1
  set externalTS = $zdt(##class(%File).GetFileDateModified(##class(%File).NormalizeFilename(external)), 3,,,,,,,,,0)

  if externalTS < 0 return 1
  set lastModified = 0

  set projectTS = ##class(Port.SourceControl.Log).GetLastChange(project, project_".PRJ")
  set currentDate = ##class(Port.SourceControl.Log).GetLastChange(project, current)

  if currentDate = 0 set lastModified = projectTS
  else  set lastModified = $select(currentDate ] projectTS : currentDate, 1: projectTS)

  if ##class(Port.Util).IsRoutine(current) ||
    (##class(Port.Util).ResolveItemExtension(current) = "CLS") {
    set currentTS = $piece(##class(%RoutineMgr).TS(current, .compileTime), ".")
  } else {
    set fullSourcePath = ""
    if 'isImport {
      do ##class(Port.Util).CSPLogicalToPhysicalPath(current, .fullSourcePath)
    } else {
      do ##class(Port.Util).CSPPhysicalToLogicalPath(current, .fullSourcePath)
    }
    set currentTS = $zdatetime(##class(%File).GetFileDateModified(fullSourcePath), 3,,,,,,,,,0)
  }

  // If the file or the item is missing it's considered outdated as well.
  if currentTS = 0 return 1

  // Same date for both entries? Then consider updated.
  if currentTS = externalTS return 0
  if 'isImport {
    if currentTS = "" return 1
    // As currentTS is referring to the imported source code, this condition checks if
    // it is newer than the file exported last time, we also keep a registry
    // about changes made using Port so we check against it as well.
    return (
      (currentTS ] externalTS) &&
      (currentTS ] lastModified)
    )
  }
  // Otherwise everything is inverted:
  // External files must be newer than the imported source code and newer than their last
  // registry as well.
  return (
    (externalTS ] currentTS) &&
    (externalTS ] lastModified)
  )
}

ClassMethod FindApplicationWithPhysicalPath(namespace As %String) As %String
{
  new $namespace
  set $namespace = "%SYS"

  set statement = ##class(%SQL.Statement).%New()
  do statement.%PrepareClassQuery("Security.Applications", "NamespaceList")
  set cursor = statement.%Execute(namespace)

  set appName = ""

  while cursor.%Next() {
    set path = cursor.%Get("Path")
    if path '= "" set appName = cursor.%Get("Name") quit
  }

  return appName
}

}

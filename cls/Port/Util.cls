Include portutils

Class Port.Util [ Abstract ]
{

ClassMethod ResolveItemExtension(itemName As %String) As %String
{
  set ext = $$$ucase($piece(itemName, ".", *))
  if $lf($$$RoutineExtensions, "."_ext) || (itemName [ "/") || (ext = "CLS") || (ext = "PRJ") return ext
  return "PKG"
}

ClassMethod GetItemSourcePathFromWorkspace(itemName As %String, projectName As %String = {$get(^||Port.Project)}, sourceExtension = {##class(Port.Configuration).GetSourceExtension()}) As %String
{
  set defaultPath = $$$NFN(##class(Port.Configuration).GetWorkspace(projectName)) 
  return ..MountItemSourcePath(itemName, defaultPath, sourceExtension)
}

ClassMethod MountItemSourcePath(itemName As %String, workspacePath As %String, sourceExtension = {##class(Port.Configuration).GetSourceExtension()}) As %String [ Internal ]
{
  set fullPath = ""
  set type = ..ResolveItemExtension(itemName)
  
  if type = "CLS" {
    set fullPath = ..ClassToFile(workspacePath_"/cls", $piece(itemName, ".", 1, *-1))
  } elseif ..IsRoutine(itemName) {
    set ext = $$$lcase(type)
    set fileName = $$$lcase(itemName)_"."_##class(Port.Configuration).GetSourceExtension()
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
  set absoluteWorkspacePath = $$$NFN(workspace)
  if absolutePath '[ absoluteWorkspacePath return $$$PERROR($$$CouldNotDetermineWorkspace)
  // + 1 considering the type directory.
  return $$$ucase($piece(absolutePath, $$$Slash, ##class(%File).GetDirectoryLength(absoluteWorkspacePath) + 1))
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

ClassMethod CSPLogicalToPhysicalPath(cspItem As %String, Output absolutePath As %String = "") As %Status
{
  if $extract(cspItem, 1) = "/" set cspItem = $extract(cspItem, 2, *)
  set cspAppDirectory = $System.CSP.GetAppName(cspItem)
  if cspAppDirectory = "" return $$$PERROR($$$NamespaceAppPathDoesnExists, $namespace)
  set cspAppDirectory = $extract(cspAppDirectory, 1, *-1)
  set absolutePath = $$$NFN($replace(cspItem, cspAppDirectory, ##class(Port.Configuration).GetWebAppPath()))
  return $$$OK
}

ClassMethod CSPPhysicalToLogicalPath(physicalPath As %String, Output logicalPath As %String, namespace As %String = {$namespace}) As %Status
{
  set slash = $$$Slash
  set webFilePath = $extract(physicalPath, $find(physicalPath, slash_"web"_slash), *)
  if '$find($$$NFN(physicalPath), slash_"web"_slash) {
    return $$$PERROR($$$InvalidPhysicalPath)
  }
  // TODO: Implement a strategy to support web apps that aren't default.
  // It seems to require implementing a manifest file to describe this project's web app.
  set cspAppPath = $System.CSP.GetDefaultApp(namespace)  
  if cspAppPath = "" return $$$PERROR($$$NamespaceAppPathDoesnExists, $namespace)
  if $extract(cspAppPath, *) '[ "/" set cspAppPath = cspAppPath_"/"
  set logicalPath = $extract(cspAppPath, 2, *)_$replace(webFilePath, "\", "/")
  return $$$OK
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

ClassMethod ClassToFile(basePath As %String, className As %String, extension As %String = {##class(Port.Configuration).GetSourceExtension()}, appendCLS As %Boolean = 1)
{
  if extension '= "" set extension = "."_extension
  set cls = $case(appendCLS, 1: ".cls", : "")
  return $$$NFN(basePath_"/"_$replace(className, ".", $$$Slash)_cls_extension)
}

ClassMethod FileToClass(path As %String, extension As %String = {##class(Port.Configuration).GetSourceExtension()}) As %String
{
  set slash = $$$Slash
  set normalizedPath = $$$NFN(path)
  set fileName = ##class(%File).GetFilename(normalizedPath)
  set extSize = $length($select(extension = "" : $piece(fileName, ".", *), 1: ".cls"_extension)) 
  set contextPath = $extract(normalizedPath, $find(normalizedPath, slash_"cls") + 1, ($length(normalizedPath) - 1) - extSize)  
  return $replace(contextPath, slash, ".")
}

ClassMethod ExistsInProject(projectName As %String, name As %String, type As %String = "") As %Boolean [ Internal ]
{
  $$$QuitOnError(##class(%Studio.Project).NormalizeName(.name, .type))
  set id = projectName_"||"_name_"||"_type
  &sql(SELECT TOP 1 COUNT(ID) INTO :exists FROM %STUDIO.PROJECTITEM WHERE ID = :id)
  return exists
}

ClassMethod UbiquitousInProject(projectName As %String, name As %String, type As %String = "") As %List
{
  do ##class(%Studio.Project).NormalizeName(.name, .type)
  &sql(
    SELECT 
      LIST(P.NAME) INTO :ubiquitousEntries
    FROM
      %STUDIO.PROJECTITEM PI
    LEFT OUTER JOIN 
      %STUDIO.PROJECT P ON P.ID = PI.Project
    WHERE 
      P.NAME <> :projectName AND PI.NAME = :name     
  )
  return $lfs(ubiquitousEntries)
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

}


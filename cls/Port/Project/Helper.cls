Include portutils

Class Port.Project.Helper [ Abstract ]
{

ClassMethod ImplyDirectoryCreation(path As %String) As %Status
{
  set isCreated = 1
  if '##class(%File).DirectoryExists(path)  {
    set isCreated = ##class(%File).CreateDirectoryChain(path)
    if isCreated = 0 {      
      quit $$$ERROR(5001, "Unable to create path: "_##class(%File).NormalizeFilename(path))
    }
  }
  quit $$$OK
}

ClassMethod IsRoutine(itemName As %String, onlyCompilables As %Boolean = 0) As %Boolean
{
  set extension = ..GetItemExtension(itemName)
  
  if extension = "MAC"  || (extension = "INT") ||
    (extension = "MVB") || (extension = "MVI") || 
    (extension = "BAS") || (extension = "INC") ||
    (extension = "DFI") {
    quit 1
  }  
  quit 0
}

ClassMethod GetItemExtension(itemName As %String) As %String
{
  
  set ext = $$$ucase($piece(itemName, ".", *))
  if $lf($$$RoutineExtensions, $$$ucase("."_ext)) || itemName [ "/" quit ext
  quit "PKG"
}

ClassMethod CSPLogicalToPhysicalPath(cspItem As %String, Output absolutePath As %String = "") As %Status
{
  set installDirectory = $System.Util.InstallDirectory()
  set cspAppDirectory = $System.CSP.GetAppName(cspItem)
  if cspAppDirectory = "" quit $$$PERROR($$$NamespaceAppPathDoesnExists, $namespace)
  set cspAppDirectory = $extract(cspAppDirectory, 1, *-1)
  set absolutePath = ##class(%File).NormalizeFilename($replace(cspItem, cspAppDirectory, ##class(Port.SourceControl.Config).GetWebAppPath()))
  quit $$$OK
}

ClassMethod FileToClass(path As %String, extension As %String = {##class(Port.SourceControl.Config).GetSourceExtension()}) As %String
{
  set slash = $select($$$isWINDOWS : "\", 1: "/")
  set normalizedPath = ##class(%File).NormalizeFilename(path)
  set fileName = ##class(%File).GetFilename(normalizedPath)
  set extSize = $length($select(extension = "" : $piece(fileName, ".", *), 1: ".cls"_extension)) 
  set contextPath = $extract(normalizedPath, $find(normalizedPath, slash_"cls") + 1, ($length(normalizedPath) - 1) - extSize)  
  quit $replace(contextPath, slash, ".")
}

ClassMethod ClassToFile(basePath As %String, className As %String, extension As %String = {##class(Port.SourceControl.Config).GetSourceExtension()}, appendCLS As %Boolean = 1)
{
  set divider = $select($$$isWINDOWS : "\", 1: "/")
  if extension '= "" set extension = "."_extension
  set cls = $case(appendCLS, 1: ".cls", : "")
  quit ##class(%File).NormalizeFilename(basePath_"/"_$replace(className, ".", divider)_cls_extension)
}

ClassMethod Describe(name As %String, Output extension As %String, Output itemType As %String, Output itemName As %String)
{
   
  set nameOnly = $piece(name, ".", 1, *-1)  
  set routines = $listbuild("MAC", "INT", "INC", "MVB", "MVI", "BAS", "DFI")
  set extension = ..GetItemExtension(name)

  if ..IsRoutine(name) {
    set itemType = extension
    if extension = "INC" || 
      (extension = "BAS") || 
      (extension = "MVI") || 
      (extension = "INT") {
      set itemType = "MAC"
    }
    set itemName = nameOnly_"."_extension  
  } elseif extension = "CLS" {
    set itemName = nameOnly  
    set itemType = extension
  } else {
    set itemName = name
    set itemType = "CSP"
  }
}

ClassMethod CSPPhysicalToLogicalPath(physicalPath As %String, Output logicalPath As %String, namespace As %String = {$namespace}) As %Status
{
  set slash = $select($$$isWINDOWS : "\", 1: "/")
  set webFilePath = $extract(physicalPath, $find(physicalPath, slash_"web"_slash), *)
  if '$find(##class(%File).NormalizeFilename(physicalPath), slash_"web"_slash) {
    quit $$$PERROR($$$InvalidPhysicalPath)
  }
  // TODO: Implement a strategy to support web apps that aren't default.
  // It seems to require implementing a manifest file to describe this project's web app.
  set cspAppPath = $System.CSP.GetDefaultApp(namespace)  
  if cspAppPath = "" quit $$$PERROR($$$NamespaceAppPathDoesnExists, $namespace)
  if $extract(cspAppPath, *) '[ "/" set cspAppPath = cspAppPath_"/"
  set logicalPath = $extract(cspAppPath, 2, *)_$replace(webFilePath, "\", "/")
  quit $$$OK
}

ClassMethod ExistsInProject(projectName As %String, name As %String, type As %String = "") As %Boolean [ Internal ]
{
  $$$QuitOnError(##class(%Studio.Project).NormalizeName(.name, .type))
  set id = projectName_"||"_name_"||"_type
  &sql(SELECT TOP 1 COUNT(ID) INTO :exists FROM %STUDIO.PROJECTITEM WHERE ID = :id)
  quit exists
}

ClassMethod UbiquitousInProject(projectName As %String, name As %String, type As %String = "") As %List [ Internal ]
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
  quit $lfs(ubiquitousEntries)
}

ClassMethod HasPackage(projectName As %String, maybePackage As %String = "") As %Status
{
  quit ..ExistsInProject(projectName, maybePackage, "PKG")
}

}


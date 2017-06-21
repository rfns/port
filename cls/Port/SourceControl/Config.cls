Class Port.SourceControl.Config Extends %SYSTEM.Help
{

/// Sets the log level used to display the info. Ranging from 1 to 3, greater is more detailed.
ClassMethod SetLogLevel(logLevel As %Integer) As %Status
{
  if '$isvalidnum(logLevel) { 
    quit $$$ERROR($$$GeneralError, "Log level must be a number between 0 and 2.")
  }
  if logLevel > 0 && (logLevel < 3) {
    set ^Port.SourceControl.Settings("general.logLevel") = logLevel
    quit $$$OK
  }
  quit $$$ERROR($$$GeneralError, "Log level out of range.")
}

/// Gets the current configured log level.
ClassMethod GetLogLevel() As %Status
{
  quit $get(^Port.SourceControl.Settings("general.logLevel"), 0)
}

/// Sets the path where the files are to be exported..
ClassMethod SetPrimaryWorkspace(newWorkspace As %String = "") As %String
{
  set ^Port.SourceControl.Settings("source.path") = $select(newWorkspace = "" : "/CacheProjects/{NAMESPACE}/{PROJECT}", 1: newWorkspace)
}

/// Gets the resolved export path. Pass 1 to excludeProject to return the project's parent directory.
ClassMethod GetWorkspace(projectName As %String = {$get(^||%Studio.Project)}) As %String
{
  set customWorkspace = ..GetCustomWorkspace(projectName)
  if customWorkspace '= "" quit ..rewritePlaceHolders(customWorkspace, projectName)
  quit ..rewritePlaceHolders($get(^Port.SourceControl.Settings("source.path")), projectName)
}

/// Enables the feature: exports the project as XML when it is saved or plainly exported.
ClassMethod EnableAutoExportXML() As %Boolean
{
  set ^Port.SourceControl.Settings("xml.autoexport") = 1
}

/// Disables the feature: exports the project as XML when it is saved or plainly exported.
ClassMethod DisableAutoExportXML() As %Boolean
{
  set ^Port.SourceControl.Settings("xml.autoexport") = 0
}

/// Returns if the auto-export feature is enabled. 
ClassMethod IsAutoExportXMLEnabled() As %Status
{
  quit ($get(^Port.SourceControl.Settings("xml.autoexport")) = 1)
}

/// Sets the path which the source control should export and look up for tests on XML format.
ClassMethod SetTestPath(newPath As %String = "")
{
  
  set ^Port.SourceControl.Settings("test.path") = $select(newPath = "" : "tests/cls", 1: newPath)
}

/// Gets the resolved test path.
ClassMethod GetTestPath() As %String
{
  quit ..rewritePlaceHolders($get(^Port.SourceControl.Settings("test.path")))
}

/// Informs the source control to run associated test class when the source is compiled.
ClassMethod EnableTestOnDemand()
{
  set ^Port.SourceControl.Settings("test.ondemand") = 1
}

/// Disables the test class association.
ClassMethod DisableTestOnDemand()
{
  set ^Port.SourceControl.Settings("test.ondemand") = 0
}

/// Returns 1 if association is enabled, 0 if not.
ClassMethod IsTestOnDemandEnabled() As %String
{
  quit ($get(^Port.SourceControl.Settings("test.ondemand")) = 1)
}

/// Sets the prefix used to associate the source with it's test class.
ClassMethod SetTestClassPrefix(newPrefix As %String = "")
{
  set ^Port.SourceControl.Settings("test.prefix") = $select(newPrefix = "" : "UnitTest", 1: newPrefix)
}

/// Gets the association prefix.
ClassMethod GetTestClassPrefix() As %String
{
  
  quit $get(^Port.SourceControl.Settings("test.prefix"))
}

/// Defines the extension to be used for exported source files overwriting their own.
ClassMethod SetSourceExtension(value As %String = "") As %Status
{
  do ..TrackActiveExtension()
  if $extract(value) = "." set value = $extract(value, 2, *)
  set ^Port.SourceControl.Settings("source.extension") = value
  quit $$$OK
}

/// Gets the source extension.
ClassMethod GetSourceExtension() As %String
{
  
  set extension = $get(^Port.SourceControl.Settings("source.extension"))
  if extension = "" quit extension
  quit extension
}

ClassMethod IsSameSourceExtension() As %Boolean [ Final, Internal ]
{
  set extension = ..GetSourceExtension()
  quit (extension = $get(^Port.SourceControl.Settings("internals.trackers.extension")))
}

ClassMethod TrackActiveExtension() [ Final, Internal ]
{
  set ^Port.SourceControl.Settings("internals.trackers.extension") = ..GetSourceExtension()
}

ClassMethod SetCustomWorkspace(projectName As %String, path As %String = {..GetWorkspace()}) As %Status [ Internal ]
{
  set ^Port.SourceControl.Settings("workspace.project", projectName) = path
  quit $$$OK
}

ClassMethod GetCustomWorkspace(projectName As %String) As %String [ Internal ]
{
  set customWorkspace = $get(^Port.SourceControl.Settings("workspace.project", projectName))
  quit ..rewritePlaceHolders(customWorkspace, projectName)
}

ClassMethod HasCustomWorkspace(projectName As %String) As %Boolean [ Internal ]
{
 
  quit (..GetCustomWorkspace(projectName) '= "")
}

ClassMethod RemoveCustomWorkspace(projectName As %String)
{
  kill ^Port.SourceControl.Settings("workspace.project", projectName)
}

ClassMethod rewritePlaceHolders(basePath As %String, projectName As %String = {$get(^||%Studio.Project)}, params... As %String) As %String [ Internal ]
{
  if '$data(params) set params = ""  
  set translatedPath = basePath  
  #define RewriteIfPathContains(%expression, %replacement) set translatedPath = $select(translatedPath [ %expression : $replace(translatedPath, %expression, %replacement), 1: translatedPath) 
  
  set installDirectory = $System.Util.InstallDirectory()
  set installDirectory = $extract(installDirectory, 1, $length(installDirectory) - 1)
  $$$RewriteIfPathContains("{NAMESPACE}", $namespace)
  $$$RewriteIfPathContains("{INSTALLDIR}", installDirectory)
  $$$RewriteIfPathContains("{USERNAME}", $username) 
  $$$RewriteIfPathContains("{EXPORTPATH}", ..GetWorkspace())
  $$$RewriteIfPathContains("{FULLEXPORTPATH}", ##class(%File).NormalizeFilename(..GetWorkspace())) 
  $$$RewriteIfPathContains("{SLASH}", $select($$$isWINDOWS: "\", 1: "/"))
  $$$RewriteIfPathContains("{PROJECT}", projectName) 
  
  if params {
    for i=1:1:params $$$RewriteIfPathContains("{P"_i_"}", params(i))
  }
  quit translatedPath
}

}


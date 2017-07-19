Include portutils

Class Port.Configuration Extends %SYSTEM.Help
{

/// Sets the log level verbosity used to display the info. Ranging from 1 to 2, greater provides more detailed info.
ClassMethod SetLogLevel(logLevel As %Integer) As %Status
{
  if logLevel > 0 && (logLevel < 3) {
    set ^Port.Configuration("general.logLevel") = logLevel
    return $$$OK
  }
  return $$$PERROR($$$LogLevelIsOutOfRange, "1, 2")
}

/// Gets the current configured log level.
ClassMethod GetLogLevel() As %Status
{
  return $get(^Port.Configuration("general.logLevel"), 0)
}

/// Sets the primary path where the project should be exported. This can be overwritten by SetCustomWorkspace.
ClassMethod SetPrimaryWorkspace(newWorkspace As %String = "") As %String
{
  set ^Port.Configuration("source.path") = $select(newWorkspace = "" : "/CacheProjects/{NAMESPACE}/{PROJECT}", 1: newWorkspace)
}

/// Resolves any placeholders and gets the precise path for the specified project. This priorizes the custom workspace and falls back to the primary.
ClassMethod GetWorkspace(projectName As %String = {$get(^||Port.Project)}) As %String
{
  set customWorkspace = ..GetCustomWorkspace(projectName)
  if customWorkspace '= "" return ..RewritePlaceHolders(customWorkspace, projectName,$lb("{NAMESPACE}","{PROJECT}","{USERNAME}"))
  return ..RewritePlaceHolders($get(^Port.Configuration("source.path")), projectName, $lb("{NAMESPACE}","{INSTALLDIR}","{PROJECT}","{USERNAME}"))
}

/// Generates and export a XML project whenever a item is saved. This is useful for keeping the project XML always up-to-date.
ClassMethod EnableAutoExportXML() As %Boolean
{
  set ^Port.Configuration("xml.autoexport") = 1
}

/// Disables the generation of the project XML file.
ClassMethod DisableAutoExportXML() As %Boolean
{
  set ^Port.Configuration("xml.autoexport") = 0
}

/// Returns if project XML generation is enabled.
ClassMethod IsAutoExportXMLEnabled() As %Status
{
  return ($get(^Port.Configuration("xml.autoexport")) = 1)
}

/// Relative to it's project. Sets the path where test cases should be exported.
ClassMethod SetTestPath(newPath As %String = "")
{
  
  set ^Port.Configuration("test.path") = $select(newPath = "" : "tests/cls", 1: newPath)
}

/// Retrives the resolved path where tests are being exported.
ClassMethod GetTestPath() As %String
{
  return ..RewritePlaceHolders($get(^Port.Configuration("test.path")),,$lb("{NAMESPACE}","{PROJECT}","{USERNAME}"))
}

/// Allows Port to run matching test cases whenever the match is compiled.
ClassMethod EnableTestOnDemand()
{
  set ^Port.Configuration("test.ondemand") = 1
}

/// Prevents Port from running test cases automatically.
ClassMethod DisableTestOnDemand()
{
  set ^Port.Configuration("test.ondemand") = 0
}

/// Retrieves if Port is configured to run test cases automatically.
ClassMethod IsTestOnDemandEnabled() As %String
{
  return ($get(^Port.Configuration("test.ondemand")) = 1)
}

/// Sets the prefix used to match against the implementation classe.
ClassMethod SetTestClassPrefix(newPrefix As %String = "")
{
  set ^Port.Configuration("test.prefix") = $select(newPrefix = "" : "UnitTest", 1: newPrefix)
}

/// Gets the associated test prefix.
ClassMethod GetTestClassPrefix() As %String
{
  
  return $get(^Port.Configuration("test.prefix"))
}

/// Defines the extension to be appended when exporting Caché files. If extension starts with a dot, it will be removed.
ClassMethod SetSourceExtension(value As %String = "") As %Status
{
  do ..TrackActiveExtension()
  if $extract(value) = "." set value = $extract(value, 2, *)
  set ^Port.Configuration("source.extension") = value
  return $$$OK
}

/// Gets the appending source extension.
ClassMethod GetSourceExtension() As %String
{
  
  set extension = $get(^Port.Configuration("source.extension"))
  if extension = "" return extension
  return extension
}

ClassMethod IsSameSourceExtension() As %Boolean [ Final, Internal ]
{
  // For internal use only: Checks if the configured extension is the same than the last one
  // used to export a project. If it isn't, an exception will be fired.
  set extension = ..GetSourceExtension()
  return (extension = $get(^Port.Configuration("internals.trackers.extension")))
}

ClassMethod TrackActiveExtension() [ Final, Internal ]
{
  // For internal use only: Updates the last used extension to match the current configuration.
  set ^Port.Configuration("internals.trackers.extension") = ..GetSourceExtension()
}

ClassMethod GetWebAppPath() As %String
{
  // For internal use only: Performs a quick search of the web app path that is registered when Port is installed.
  return $get(^Port.Configuration("internals.webapp.path"))
}

/// Defines a custom workspace, a path where a single project should be exported. This configuration ovewrites the primary workspace.
ClassMethod SetCustomWorkspace(projectName As %String, path As %String = {..GetWorkspace()}) As %Status [ Internal ]
{
  set ^Port.Configuration("workspace.project", projectName) = path
  return $$$OK
}

/// Retrieves the resolved workspace path for the provided project. Returns empty if there's none.
ClassMethod GetCustomWorkspace(projectName As %String) As %String [ Internal ]
{
  set customWorkspace = $get(^Port.Configuration("workspace.project", projectName))
  return ..RewritePlaceHolders(customWorkspace, projectName, $lb("{NAMESPACE}","{INSTALLDIR}","{PROJECT}","{USERNAME}"))
}

/// Returns if the project has a custom workspace.
ClassMethod HasCustomWorkspace(projectName As %String) As %Boolean [ Internal ]
{
 
  return (..GetCustomWorkspace(projectName) '= "")
}

/// Removes the custom workspace from the project provided, which also resets it back to using the primary.
ClassMethod RemoveCustomWorkspace(projectName As %String)
{
  kill ^Port.Configuration("workspace.project", projectName)
}

/// Remove all Port configurations. This will not erase project logs.
ClassMethod Uninstall() As %Status
{
  kill ^Port.Configuration
  return $$$OK
}

ClassMethod RewritePlaceHolders(basePath As %String, projectName As %String = {$get(^||Port.Project)}, allowedPlaceholders = "*", params... As %String) As %String [ Internal ]
{
 
  if '$data(params) set params = ""
  set translatedPath = basePath  
  #define RewriteIfPathContains(%expression, %replacement) if ($lv(allowedPlaceholders) && $lf(allowedPlaceholders, %expression)) || (allowedPlaceholders = "*") set translatedPath = $select(translatedPath [ %expression : $replace(translatedPath, %expression, %replacement), 1: translatedPath) 
  
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
  return translatedPath
}

}


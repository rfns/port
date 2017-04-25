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

/// Sets the path where the files are to be exported. Supports template.
ClassMethod SetExportPath(newExportPath As %String) As %String
{
  set ^Port.SourceControl.Settings("source.path") = $get(newExportPath, "/CacheProjects/{NAMESPACE}/{PROJECT}")
}

/// Gets the resolved export path. Pass 1 to excludeProject to return the project's parent directory.
ClassMethod GetExportPath(excludeProject As %Boolean = 0) As %String
{
  quit ..rewritePlaceHolders($get(^Port.SourceControl.Settings("source.path")), excludeProject)
}

/// Enables the feature: exports the project as XML when it is saved or plainly exported.
ClassMethod EnableAutoExportXML() As %Boolean
{
  set ^Port.SourceControl.Settings("xml.autoExport") = 1
}

/// Disables the feature: exports the project as XML when it is saved or plainly exported.
ClassMethod DisableAutoExportXML() As %Boolean
{
  set ^Port.SourceControl.Settings("xml.autoExport") = 0
}

/// Returns if the auto-export feature is enabled. 
ClassMethod IsAutoExportXMLEnabled() As %Status
{
  quit ($get(^Port.SourceControl.Settings("xml.autoExport")) = 1)
}

/// Sets the path which the source control should export and look up for tests on XML format.
ClassMethod SetTestPath(newPath As %String)
{
  
  set ^Port.SourceControl.Settings("test.path") = $get(newPath, "__tests__/cls")
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
ClassMethod SetTestClassPrefix(newPrefix As %String)
{
  set ^Port.SourceControl.Settings("test.prefix") = newPrefix
}

/// Gets the association prefix.
ClassMethod GetTestClassPrefix() As %String
{
  quit $get(^Port.SourceControl.Settings("test.prefix"))
}

/// Defines the extension to be used for exported source files overwriting their own.
ClassMethod SetSourceExtension(value As %String = "") As %Status
{
  
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

ClassMethod rewritePlaceHolders(basePath As %String, excludeProject As %Boolean = 0, params... As %String) As %String [ Internal ]
{
  if '$data(params) set params = ""
  set translatedPath = basePath 
  #define RewriteIfPathContains(%expression, %replacement) set translatedPath = $select(translatedPath [ %expression : $replace(translatedPath, %expression, %replacement), 1: translatedPath) 
  
  set installDirectory = $System.Util.InstallDirectory()
  set installDirectory = $extract(installDirectory, 1, $length(installDirectory) - 1)
  $$$RewriteIfPathContains("{NAMESPACE}", $namespace)
  $$$RewriteIfPathContains("{INSTALLDIR}", installDirectory)
  $$$RewriteIfPathContains("{USERNAME}", $username) 
  $$$RewriteIfPathContains("{EXPORTPATH}", ..GetExportPath())
  $$$RewriteIfPathContains("{FULLEXPORTPATH}", ##class(%File).NormalizeFilename(..GetExportPath())) 
  $$$RewriteIfPathContains("{SLASH}", $select($$$isWINDOWS: "\", 1: "/"))
  if 'excludeProject $$$RewriteIfPathContains("{PROJECT}", $get(^||%Studio.Project))
  if params {
    for i=1:1:params $$$RewriteIfPathContains("{P"_i_"}", params(i))
  }
  quit translatedPath
}

}

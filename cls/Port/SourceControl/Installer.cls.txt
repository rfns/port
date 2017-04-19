Class Port.SourceControl.Installer [ Abstract ]
{

ClassMethod Install() As %Status
{
  $$$QuitOnError(..CreateGlobalMapping())
  do ##class(Port.SourceControl.Config).SetExportPath("/CacheProjects/{NAMESPACE}/{PROJECT}") 
  do ##class(Port.SourceControl.Config).SetTestPath("tests/{PROJECT}")
  do ##class(Port.SourceControl.Config).SetTestClassPrefix("UnitTest")
  do ##class(Port.SourceControl.Config).EnableTestOnDemand()
  do ##class(Port.SourceControl.Config).EnableAutoExportXML()
  do ##class(Port.SourceControl.Config).SetLogLevel(1)
  
  $$$QuitOnError(##class(%Studio.SourceControl.Interface).SourceControlClassSet("Port.SourceControl.Hooks", $namespace))
  quit ##class(Port.SourceControl.LogCleaner).StartTask()
}

ClassMethod CreateGlobalMapping() As %Status
{
  set sc = $$$OK
  set thisNamespace = $namespace     
  new $namespace
  
  set $namespace = "%SYS"
  
  try {
    $$$ThrowOnError(##class(Config.Namespaces).Get(thisNamespace, .nsProperties))
    set glProperties("Database") = nsProperties("Globals")
    $$$ThrowOnError(##class(Config.MapGlobals).Create(thisNamespace, "Port.SourceControl.Projects", .glProperties))
    $$$ThrowOnError(##class(Config.MapGlobals).Create(thisNamespace, "Port.SourceControl.Settings", .glProperties))
    set $namespace = thisNamespace
  } catch ex {
    set $namespace = thisNamespace
    set sc = ex.AsStatus()
  }
  quit sc
}

}


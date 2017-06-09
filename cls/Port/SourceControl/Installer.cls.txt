Class Port.SourceControl.Installer [ Abstract ]
{

ClassMethod Install(force As %Boolean = 0) As %Status
{
  set sc = $$$OK
  
  if 'force {
    if $data(^Port.SourceControl("installed")) {
      write !, "Port is already installed. The installer has been aborted.", !
      write "If you wish to change current settings then please use the wizard.", !!
      write "do Wizard^Port", !
      quit $$$ERROR($$$GeneralError, "Port is already installed.")
    }
  }
  
  try {
    write !, "Installing Port ... please wait a moment.", !
    write "> Creating global mappings ...", !    
    $$$ThrowOnError(..CreateGlobalMapping())
    write "> Setting up workspace structure ... ", !
    do ##class(Config).SetPrimaryWorkspace("/CacheProjects/{NAMESPACE}/{PROJECT}")
    write "> Setting up test files directory ...", !
    do ##class(Config).SetTestPath("tests")
    write "> Defining default test class prefix ..", !
    do ##class(Config).SetTestClassPrefix("UnitTest")
    write "> Enabling auto-testing ...", !
    do ##class(Config).EnableTestOnDemand()
    write "> Enabling auto-export for project XML ...", !
    do ##class(Config).EnableAutoExportXML()
    write "> Setting up log level ...", !
    do ##class(Config).SetLogLevel(1)
    write "> Setting up source extension ...", !
    do ##class(Config).SetSourceExtension("txt")    
    write "> Registering log cleaner task for "_$namespace_" ...", !
    $$$ThrowOnError(##class(LogCleaner).StartTask())
    write "> Activating source control class ...", !!
    $$$ThrowOnError(##class(%Studio.SourceControl.Interface).SourceControlClassSet("Port.SourceControl.Hooks", $namespace))
    write "ALL DONE.", !
    write "NOTE: Please note that you must restart Studio in order to make the new settings have effect."
    set ^Port.SourceControl("installed") = 1
  } catch ex {
    set sc = ex.AsStatus()    
    write !!, "FATAL: Failed to install port due to the following reason: "
    do $System.OBJ.DisplayError(sc)
  }
  quit sc
}

ClassMethod CreateGlobalMapping() As %Status
{
  set sc = $$$OK
  set thisNamespace = $namespace     
  new $namespace
  
  set $namespace = "%SYS"
  
  if ##class(Config.MapGlobals).Exists(thisNamespace, "Port.SourceControl*") {
    write "> Global is already mapped. Skipping ...", !
    quit $$$OK
  }
  
  try {
    $$$ThrowOnError(##class(Config.Namespaces).Get(thisNamespace, .nsProperties))
    set glProperties("Database") = thisNamespace
    $$$ThrowOnError(##class(Config.MapGlobals).Create(thisNamespace, "Port.SourceControl*", .glProperties))
    set $namespace = thisNamespace
  } catch ex {
    set $namespace = thisNamespace
    set sc = ex.AsStatus()
  }
  quit sc
}

}


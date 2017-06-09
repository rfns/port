Class Port.SourceControl.Wizard [ Abstract ]
{

ClassMethod Start(hideIntroduction As %Boolean = 0)
{
  set validChoices = $listbuild(1,2,3,4,5,6)
  set invalidChoice = 1
  set choice = ""  
  
  if 'hideIntroduction {
    write !, "Welcome to the Port configuration wizard."
  }
  
  while invalidChoice {
    if invalidChoice && (choice '= "") write "Invalid choice."
    do Menu
  }
    
  if choice = 1 quit ..StartWorkspaceConfigAssistant() quit
  if choice = 2 quit ..StartTestConfigAssistant() quit
  if choice = 3 quit ..StartAutoExportXMLConfigAssistant() quit
  if choice = 4 quit ..StartLogLevelConfigAssistant() quit
  if choice = 5 quit ..StartSourceExtensionConfigAssistant() quit
  if choice = 6 write !, "Bye." quit $$$OK
         
Menu
  set choice = ""
  write !!, "What do you want to do? (type the number)", !!
  
  write "1. Manage workspaces.", !
  write "2. Change test settings.", !
  write "3. Toggle project XML auto-export.", !
  write "4. Set log level.", !
  write "5. Set source extension.", !
  write "6. Exit.", !!
  
  write "Your choice: "
  
  read choice
  write !  
  set invalidChoice = ($listfind(validChoices, choice) = 0)
  quit
}

ClassMethod StartWorkspaceConfigAssistant(hideIntroduction As %Boolean = 0)
{
 
  set validChoices = $listbuild(1,2,3)
  set invalidChoice = 1
  set choice = ""    
  
  if 'hideIntroduction {  
    write !, "Manages workspaces that will contain the exported source code.", !!
  }
  
  while invalidChoice {
    if invalidChoice && (choice '= "") write "Invalid choice.", !!
    do Menu
  }
  
  if choice = 1 quit ..StartWorkspaceChoice1ConfigAssistant()
  if choice = 2 quit ..StartWorkspaceChoice2ConfigAssistant()
  if choice = 3 quit ..Start(1) 
  
  quit $$$OK
    
Menu
  set choice = ""
  write "What do you want to do? (type the number)", !!

  write "1. Change primary workspace.", !
  write "2. Manage existing workspaces.", !
  write "3. Go back.", !!
  
  write "Your choice: "
  
  read choice
  write !  
  set invalidChoice = ($listfind(validChoices, choice) = 0)
  quit
}

ClassMethod StartWorkspaceChoice1ConfigAssistant()
{
  set isPathValid = 0
      
  write !, "Configures the primary workspace that will be used to export your source code."
  
  write !!, "You can use the following specific placeholders: ", !!
  
  write "{PROJECT} - The active project name.", !
  write "{NAMESPACE} - The active namespace name.", !
  write "{USERNAME} - The active user name.", !
  write "{INSTALLDIR} - The Caché installation directory."
  
  write !!, "Please type the ABSOLUTE path to be used when exporting your source files.", !
  write "Or leave it empty to use restore the default."
  
  write "You can use both: UNIX or Windows schemes.", !!
  write "Default is: ", !, "/CacheProjects/{NAMESPACE}/{PROJECT}", !
  write "Current is: ", !, $get(^Port.SourceControl.Settings("source.path"), "none"), !!
  write "New: ", !
  read path
  
  if path = "" set path = "/CacheProjects/{NAMESPACE}/{PROJECT}"
    
  do ##class(Config).SetPrimaryWorkspace(path)
  write !!, "The primary workspace is now set to: ", !
  write path, !!
  quit ..StartWorkspaceConfigAssistant(1)
}

ClassMethod StartWorkspaceChoice2ConfigAssistant()
{
  write !, "Manages workspaces associated to projects.", ! 
  write !, "Projects named here will not use the primary workspace definition."
  
  write !, "Type the name of the project (or leave it empty to abort): ", !
  read projectName
  
  if projectName = "" write !, "Aborted.", !! quit ..StartWorkspaceConfigAssistant(1)
  set projectExists = ##class(%Studio.Project).%ExistsId(projectName)
  
  if 'projectExists {
    write !!, "WARNING: The project "_projectName_ " doesn't exist yet.", !!
  }  
  
  set currentWorkspace = ##class(Config).GetCustomWorkspace(projectName)
  write !!, "Current workspace is: ", !
  write ##class(Config).GetWorkspace(projectName)
  write !!, "You will be asked for a new workspace now.", !
  write "You can use both: UNIX or Windows schemes.", !
  write "Note that workspace paths must be ABSOLUTE.", !
  write "You can use the following specific placeholders: ", !!
  
  write "{PROJECT} - The active project name.", !
  write "{NAMESPACE} - The active namespace name.", !
  write "{USERNAME} - The active user name.", !
  write "{INSTALLDIR} - The Caché installation directory.", !!
  
  write "Type the workspace path (or leave it empty to abort): ", !
  read workspacePath
  
  if workspacePath = "" write !, "Aborted.", !! quit ..StartWorkspaceConfigAssistant(1)
  
  do ##class(Config).SetCustomWorkspace(projectName, workspacePath)
  write !!, "The project "_projectName_" is now configured to be exported to the following path: ", !
  write ##class(Config).GetWorkspace(projectName), !!
  
  quit ..StartWorkspaceConfigAssistant(1)
}

ClassMethod StartTestConfigAssistant(hideIntroduction As %Boolean = 0)
{
  set validChoices = $listbuild(1,2,3,4)
  set invalidChoice = 1
  set choice = ""    
  
  if 'hideIntroduction {  
    write !, "Configures settings related to the Studio test integration.", !!
  }
  
  while invalidChoice {
    if invalidChoice && (choice '= "") write "Invalid choice.", !!
    do Menu
  }
  
  if choice = 1 quit ..StartTestChoice1ConfigAssistant()
  if choice = 2 quit ..StartTestChoice2ConfigAssistant()
  if choice = 3 quit ..StartTestChoice3ConfigAssistant()
  if choice = 4 quit ..Start(1)
  
  quit $$$OK
    
Menu
  set choice = ""
  write "What do you want to do? (type the number)", !!
  
  write "1. Enable or disable test on demand.", !
  write "2. Define a new test class prefix.", !
  write "3. Define the path where unit test classes should exported (XML).", !
  write "4. Go back.", !!
  
  write "Your choice: "
  
  read choice
  write !  
  set invalidChoice = ($listfind(validChoices, choice) = 0)
  quit
}

ClassMethod StartAutoExportXMLConfigAssistant()
{
  set validChoices = $listbuild(1,2)
  set choice = ""
  set invalidChoice = 1
  
  set labels(1) = "ENABLED"
  set labels(0) = "DISABLED"  
  
  write !, "Exports an XML file from project when a document is saved on Studio.", !!

  while invalidChoice {
    if invalidChoice && (choice '= "") write "Invalid choice.", !!
    do Menu
  }
  
  if choice = 1 {
    do ##class(Port.SourceControl.Config).EnableAutoExportXML()
    write "Auto-export XML is now ENABLED."
  }
  
  if choice = 2 {
    do ##class(Port.SourceControl.Config).DisableAutoExportXML()
    write "Auto-export XML is now DISABLED."
  }
  
  write !!
  quit ..Start(1)
  
Menu
  set choice = ""
  write "What do you want to do? (type the number)", !!
    
  write "1. Enable project XML auto-export.", ! 
  write "2. Disable project XML auto-export.", !!  
     
  set status = ##class(Port.SourceControl.Config).IsAutoExportXMLEnabled()
  
  write "Auto-export XML is currently: "_labels(status), !!
  write "Your choice: "
  
  read choice
  set invalidChoice = ($listfind(validChoices, choice) = 0)
  write !
  quit
}

ClassMethod StartLogLevelConfigAssistant()
{
  set validChoices = $listbuild(1,2)
  set invalidChoice = 1
  set choice = ""
  
  write !, "Specifies the log verbosity level when displaying operations.", !!
  
  while invalidChoice {
    if invalidChoice && (choice '= "") write "Invalid choice.", !!
    do Menu
  }
  
  do ##class(Port.SourceControl.Config).SetLogLevel(choice)
  write "Log verbosity level is now: "_##class(Port.SourceControl.Config).GetLogLevel()
  quit ..Start(1)
  
Menu
  set choice = ""
  write "Please set the log verbosity level (type the number):", !!
    
  write "1. Level 1: Displays item equeieing, import categories, backup notifications, repository status and error messages.", ! 
  write "2. Level 2: Same as Level 1, but includes atomical operations.", !!  
     
  set status = ##class(Port.SourceControl.Config).IsTestOnDemandEnabled()
  
  write "Log verbosity level is currently: "_##class(Port.SourceControl.Config).GetLogLevel(), !!
  write "Your choice: "
  
  read choice
  set invalidChoice = ($listfind(validChoices, choice) = 0)
  write !
  quit
}

ClassMethod StartSourceExtensionConfigAssistant()
{
  set currentExtension = $get(^Port.SourceControl.Settings("source.extension"))
  write !, "Defines an extension to be appended globaly to every exported routine.", !!
  
  write "Please type the extension below: ", !!
  write "Current is: "_$select(currentExtension = "" : "none.", 1: "."_currentExtension), !
  write "New: "
  read extension   
  
  do ##class(Port.SourceControl.Config).SetSourceExtension(extension)
  set savedExtension = $get(^Port.SourceControl.Settings("source.extension"))
  write !!, "The extension is now set to: "_$select(savedExtension = "" : "none.", 1: "."_savedExtension)
  quit ..Start(1)
}

ClassMethod StartTestChoice1ConfigAssistant()
{
  set validChoices = $listbuild(1,2)  
  set invalidChoice = 1
  set choice = ""
  
  set labels(1) = "ENABLED"
  set labels(0) = "DISABLED"
  
  write !, "When this settings is enabled, Port will try to match the test class prefix and run the related test.", !!  
  
  while invalidChoice {
    if invalidChoice && (choice '= "") write "Invalid choice.", !!
    do Menu
  }
  
  if choice = 1 {
    do ##class(Port.SourceControl.Config).EnableTestOnDemand()
    write "Test on demand is now ENABLED."
  }
  
  if choice = 2 {
    do ##class(Port.SourceControl.Config).DisableTestOnDemand()
    write "Test on demand is now DISABLED."
  }
  
  write !!
  quit ..StartTestConfigAssistant(1)
  
Menu
  set choice = ""
  write "What do you want to do? (type the number)", !!
    
  write "1. Enable test on demand.", ! 
  write "2. Disable test on demand.", !!  
     
  set status = ##class(Port.SourceControl.Config).IsTestOnDemandEnabled()
  
  write "Test on demand is currently: "_labels(status), !!
  write "Your choice: "
  
  read choice
  set invalidChoice = ($listfind(validChoices, choice) = 0)
  write !
  quit
}

ClassMethod StartTestChoice2ConfigAssistant()
{
  
  write !, "A test class prefix is required to inform Port which package should be considered as a test package."
  write " Port uses this prefix when trying to find an equivalent implementation class."
  write !, "Ex: UnitTest.MyPackage.MyClass -> MyPackage.MyClass.", !!
  
  write "Please type the prefix below. Note that prefixes can also be composed.", !
  write "Ex: Package.UnitTest.", !!
  write "Default is: UnitTest", !
  write "Current is: "_##class(Port.SourceControl.Config).GetTestClassPrefix(), !
  write "New: "
  read prefix   
  
  do ##class(Port.SourceControl.Config).SetTestClassPrefix(prefix)
  write !!, "The prefix is now set to: "_##class(Port.SourceControl.Config).GetTestClassPrefix()_"."
  write !!
  quit ..StartTestConfigAssistant(1)
}

ClassMethod StartTestChoice3ConfigAssistant()
{
  write !, "Defines the path where the each test classes should be exported."
  
  write !!, "You can use the following specific placeholders: ", !!
  
  write "{PROJECT} - The active project name.", !
  write "{NAMESPACE} - The active namespace name.", !
  write "{USERNAME} - The active user name.", !
  write "{INSTALLDIR} - The Caché installation directory.", !!
    
  write "Please type the RELATIVE path to be used when exporting your test files.", !
  write "You can use both: UNIX or Windows schemes.", !
  write "Test paths are relative to each project root.", !
  write "This is equivalent to: "_^Port.SourceControl.Settings("source.path"), !!
  
  write "You can use both: UNIX or Windows schemes.", !!
  write "Default is: ", !, "tests/cls", !
  write "Current is: ", !, $get(^Port.SourceControl.Settings("test.path")), !!
  write "New: ", !
  read path
   
  do ##class(Port.SourceControl.Config).SetTestPath(path)
  write !!, "The test path is now set to: "_^Port.SourceControl.Settings("test.path")_"."
  write !!
  quit ..StartTestConfigAssistant(1)
}

}


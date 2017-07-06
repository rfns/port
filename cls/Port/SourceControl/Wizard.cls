Include portutils

Class Port.SourceControl.Wizard [ Abstract ]
{

ClassMethod Start(hideIntroduction As %Boolean = 0)
{
  set validChoices = $listbuild(1,2,3,4,5,6)
  set invalidChoice = 1
  set choice = ""  
  
  if 'hideIntroduction {
    write !, $$$FormatWizardMsg($$$PCWWelcome)
  }
  
  while invalidChoice {
    if invalidChoice && (choice '= "") write $$$FormatWizardMsg($$$PCWInvalidChoice)
    do Menu
  }
    
  if choice = 1 quit ..StartWorkspaceConfigAssistant() quit
  if choice = 2 quit ..StartTestConfigAssistant() quit
  if choice = 3 quit ..StartAutoExportXMLConfigAssistant() quit
  if choice = 4 quit ..StartLogLevelConfigAssistant() quit
  if choice = 5 quit ..StartSourceExtensionConfigAssistant() quit
  if choice = 6 write !, $$$FormatWizardMsg($$$PCWBye) quit $$$OK
         
Menu
  set choice = ""
  write !!, $$$FormatWizardMsg($$$PCWChoiceQuestion), !!
  
  write $$$FormatWizardMsg($$$PCWManageWorkspaceChoice), !
  write $$$FormatWizardMsg($$$PCWManageChangeTestSettingsChoice), !
  write $$$FormatWizardMsg($$$PCWToggleAutoExportChoice), !
  write $$$FormatWizardMsg($$$PCWSetLogLevelChoice), !
  write $$$FormatWizardMsg($$$PCWSetSourceExtensionChoice), !
  write $$$FormatWizardMsg($$$PCWExit), !!
  
  write $$$FormatWizardMsg($$$PCWChoicePrompt)
  
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
    write !, $$$FormatWizardMsg($$$PCWManageWorkspaceDescription), !!
  }
  
  while invalidChoice {
    if invalidChoice && (choice '= "") write $$$FormatWizardMsg($$$PCWInvalidChoice), !!
    do Menu
  }
  
  if choice = 1 quit ..StartWorkspaceChoice1ConfigAssistant()
  if choice = 2 quit ..StartWorkspaceChoice2ConfigAssistant()
  if choice = 3 quit ..Start(1) 
  
  quit $$$OK
    
Menu
  set choice = ""
  write !, $$$FormatWizardMsg($$$PCWChoiceQuestion), !!

  write $$$FormatWizardMsg($$$PCWManageWorkspaceChoice1), !
  write $$$FormatWizardMsg($$$PCWManageWorkspaceChoice2), !
  write $$$FormatWizardMsg($$$PCWGoBackChoice, "3"), !!
  
  write $$$FormatWizardMsg($$$PCWChoicePrompt)
  
  read choice
  write !  
  set invalidChoice = ($listfind(validChoices, choice) = 0)
  quit
}

ClassMethod StartWorkspaceChoice1ConfigAssistant()
{
  set isPathValid = 0
      
  write !, $$$FormatWizardMsg($$$PCWManageWorkspaceChoice1Description)
  
  write !!, $$$FormatWizardMsg($$$PCWPlaceholdersAnnounce), !!
  
  write $$$FormatWizardMsg($$$PCWPlaceholdersProject), !
  write $$$FormatWizardMsg($$$PCWPlaceholdersNamespace), !
  write $$$FormatWizardMsg($$$PCWPlaceholdersUsername), !
  write $$$FormatWizardMsg($$$PCWPlaceholdersInstallDir)
  
  write !!, $$$FormatWizardMsg($$$PCWPathAbsolute), !!
 
  write $$$FormatWizardMsg($$$PCWPathOSSchemes), !!
  write $$$FormatWizardMsg($$$PCWPathDefault), !, "/CacheProjects/{NAMESPACE}/{PROJECT}", !
  write $$$FormatWizardMsg($$$PCWPathCurrent), !, $get(^Port.SourceControl.Settings("source.path"), "none"), !!
  write $$$FormatWizardMsg($$$PCWPathNew), !
  read path
  
  if path = "" set path = "/CacheProjects/{NAMESPACE}/{PROJECT}"
    
  do ##class(Config).SetPrimaryWorkspace(path)
  write !!, $$$FormatWizardMsg($$$PCWManageWorkspaceChoice1StatusNow, path), !
  quit ..StartWorkspaceConfigAssistant(1)
}

ClassMethod StartWorkspaceChoice2ConfigAssistant()
{
  write !, $$$FormatWizardMsg($$$PCWManageWorkspaceChoice2Description), ! 
  write !, $$$FormatWizardMsg($$$PCWManageWorkspaceChoice2Description2), !
  
  write !, $$$FormatWizardMsg($$$PCWManageWorkspaceChoice2Prompt), !
  read projectName
  
  if projectName = "" write !, $$$FormatWizardMsg($$$PCWAborted), !! quit ..StartWorkspaceConfigAssistant(1)
  set projectExists = ##class(%Studio.Project).%ExistsId(projectName)
  
  if 'projectExists {
    write !!, $$$FormatWizardMsg($$$PCWManageWorkspaceChoice2Warning), !!
  }  
  
  set currentWorkspace = ##class(Config).GetCustomWorkspace(projectName)
  write !!, $$$FormatWizardMsg($$$PCWManageWorkspaceChoice1StatusCurrent, ##class(Config).GetWorkspace(projectName)), !
  write !!, $$$FormatWizardMsg($$$PCWManageWorkspaceChoice2CurrentWorskpaceWarn), !
  
  write $$$FormatWizardMsg($$$PCWPlaceholdersProject), !
  write $$$FormatWizardMsg($$$PCWPlaceholdersNamespace), !
  write $$$FormatWizardMsg($$$PCWPlaceholdersUsername), !
  write $$$FormatWizardMsg($$$PCWPlaceholdersInstallDir)
  
  write !!, $$$FormatWizardMsg($$$PCWPathAbsolute), !!
 
  write $$$FormatWizardMsg($$$PCWPathOSSchemes), !!  
  
  write $$$FormatWizardMsg($$$PCWManageWorkspaceChoice2Prompt2), !
  read workspacePath
  
  if workspacePath = "" write !, $$$FormatWizardMsg($$$PCWAborted), !! quit ..StartWorkspaceConfigAssistant(1)
  
  do ##class(Config).SetCustomWorkspace(projectName, workspacePath)
  write !!, $$$FormatWizardMsg($$$PCWManageWorkspaceChoice2StatusNow, ##class(Config).GetWorkspace(projectName)), !!
  
  quit ..StartWorkspaceConfigAssistant(1)
}

ClassMethod StartTestConfigAssistant(hideIntroduction As %Boolean = 0)
{
  set validChoices = $listbuild(1,2,3,4)
  set invalidChoice = 1
  set choice = ""    
  
  if 'hideIntroduction {  
    write !, $$$FormatWizardMsg($$$PCWManageChangeTestSettingsDescription), !
  }
  
  while invalidChoice {
    if invalidChoice && (choice '= "") write $$$FormatWizardMsg($$$PCWInvalidChoice), !!
    do Menu
  }
  
  if choice = 1 quit ..StartTestChoice1ConfigAssistant()
  if choice = 2 quit ..StartTestChoice2ConfigAssistant()
  if choice = 3 quit ..StartTestChoice3ConfigAssistant()
  if choice = 4 quit ..Start(1)
  
  quit $$$OK
    
Menu
  set choice = ""
  write !, $$$FormatWizardMsg($$$PCWChoiceQuestion), !!
  
  write $$$FormatWizardMsg($$$PCWManageChangeTestSettingsChoice1), !
  write $$$FormatWizardMsg($$$PCWManageChangeTestSettingsChoice2), !
  write $$$FormatWizardMsg($$$PCWManageChangeTestSettingsChoice3), !
  write $$$FormatWizardMsg($$$PCWGoBackChoice, 4), !!
  
  write $$$FormatWizardMsg($$$PCWChoicePrompt)
  
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
  
  set labels(0) = $$$FormatWizardMsg($$$PCWToggleEnabled)
  set labels(1) = $$$FormatWizardMsg($$$PCWToggleDisabled)
  
  write !, $$$FormatWizardMsg($$$PCWToggleAutoExportDescription), !

  while invalidChoice {
    if invalidChoice && (choice '= "") write $$$FormatWizardMsg($$$PCWInvalidChoice), !!
    do Menu
  }
  
  if choice = 1 do ##class(Port.SourceControl.Config).EnableAutoExportXML()  
  if choice = 2 do ##class(Port.SourceControl.Config).DisableAutoExportXML()
    
  write $$$FormatWizardMsg($$$PCWToggleAutoExportChoice1StatusCurrent, labels(choice - 1))
  
  write !!
  quit ..Start(1)
  
Menu
  set choice = ""
  write !, $$$FormatWizardMsg($$$PCWChoiceQuestion), !!
    
  write $$$FormatWizardMsg($$$PCWToggleAutoExportChoice1), ! 
  write $$$FormatWizardMsg($$$PCWToggleAutoExportChoice2), !!  
     
  set status = ##class(Port.SourceControl.Config).IsAutoExportXMLEnabled()
  
  write $$$FormatWizardMsg($$$PCWToggleAutoExportChoice1StatusCurrent, labels(status)), !!
  write $$$FormatWizardMsg($$$PCWChoicePrompt)
  
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
  
  write !, $$$FormatWizardMsg($$$PCWSetLogLevelDescription), !
  
  while invalidChoice {
    if invalidChoice && (choice '= "") write $$$FormatWizardMsg($$$PCWInvalidChoice), !!
    do Menu
  }
  
  do ##class(Port.SourceControl.Config).SetLogLevel(choice)
  write $$$FormatWizardMsg($$$PCWSetLogLevelStatusNow, ##class(Port.SourceControl.Config).GetLogLevel())
  quit ..Start(1)
  
Menu
  set choice = ""
  write !, $$$FormatWizardMsg($$$PCWSetLogLevelStatusPrompt), !!
    
  write $$$FormatWizardMsg($$$PCWSetLogLevelStatusChoice1), !!
  
  write $$$FormatWizardMsg($$$PCWSetLogLevelStatusChoice2), !!
  
  write $$$FormatWizardMsg($$$PCWSetLogLevelStatusCurrent, ##class(Port.SourceControl.Config).GetLogLevel()), !!
  write $$$FormatWizardMsg($$$PCWChoicePrompt)
  
  read choice
  set invalidChoice = ($listfind(validChoices, choice) = 0)
  write !
  quit
}

ClassMethod StartSourceExtensionConfigAssistant()
{
  set currentExtension = $get(^Port.SourceControl.Settings("source.extension"))
  write !, $$$FormatWizardMsg($$$PCWSetSourceExtensionDescription), !
  
  write $$$FormatWizardMsg($$$PWCSetSourceExtensionPrompt), !!
  write $$$FormatWizardMsg($$$PCWPathDefault), !
  write $select(currentExtension = "" : "none.", 1: "."_currentExtension), !
  write $$$FormatWizardMsg($$$PCWPathNew)
  read extension   
  
  do ##class(Port.SourceControl.Config).SetSourceExtension(extension)
  set savedExtension = $get(^Port.SourceControl.Settings("source.extension"))
  write !!, $$$FormatWizardMsg($$$PWCSetSourceExtensionStatusNow, $select(savedExtension = "" : "none.", 1: "."_savedExtension))
  quit ..Start(1)
}

ClassMethod StartTestChoice1ConfigAssistant()
{
  set validChoices = $listbuild(1,2)  
  set invalidChoice = 1
  set choice = ""
  
  set labels(0) = $$$FormatWizardMsg($$$PCWToggleEnabled)
  set labels(1) = $$$FormatWizardMsg($$$PCWToggleDisabled)
  
  write !, $$$FormatWizardMsg($$$PCWManageChangeTestSettingsChoice1Description), !  
  
  while invalidChoice {
    if invalidChoice && (choice '= "") write $$$FormatWizardMsg($$$PCWInvalidChoice), !!
    do Menu
  }
  
  if choice = 1 do ##class(Port.SourceControl.Config).EnableTestOnDemand()      
  if choice = 2 do ##class(Port.SourceControl.Config).DisableTestOnDemand()
  
  write $$$FormatWizardMsg($$$PCWManageChangeTestSettingsChoice1StatusCurrent, labels(choice - 1))
  
  write !
  quit ..StartTestConfigAssistant(1)
  
Menu
  set choice = ""
  write !, $$$FormatWizardMsg($$$PCWChoiceQuestion), !!
    
  write $$$FormatWizardMsg($$$PCWManageChangeTestSettingsChoice1Choice1), ! 
  write $$$FormatWizardMsg($$$PCWManageChangeTestSettingsChoice1Choice2), !! 
     
  set status = ##class(Port.SourceControl.Config).IsTestOnDemandEnabled()
  
  write $$$FormatWizardMsg($$$PCWManageChangeTestSettingsChoice1StatusCurrent, labels(status)), !
  write $$$FormatWizardMsg($$$PCWChoicePrompt)
  
  read choice
  set invalidChoice = ($listfind(validChoices, choice) = 0)
  write !
  quit
}

ClassMethod StartTestChoice2ConfigAssistant()
{
  
  write !, $$$FormatWizardMsg($$$PCWManageChangeTestSettingsChoice1Description), !
  write !, $$$FormatWizardMsg($$$PCWManageChangeTestSettingsChoice2Description), !
  write !, $$$FormatWizardMsg($$$PCWManageChangeTestSettingsChoice3Description), !!
  
  write $$$FormatWizardMsg($$$PCWManageChangeTestSettingsChoice2Prompt), !  
  write $$$FormatWizardMsg($$$PCWPathDefault), " UnitTest", !
  write $$$FormatWizardMsg($$$PCWPathCurrent), " ", ##class(Port.SourceControl.Config).GetTestClassPrefix(), !!
  write $$$FormatWizardMsg($$$PCWPathNew)
  read prefix   
  
  do ##class(Port.SourceControl.Config).SetTestClassPrefix(prefix)
  write !!, $$$FormatWizardMsg($$$PCWManageChangeTestSettingsChoice2StatusNow, ##class(Port.SourceControl.Config).GetTestClassPrefix())
  write !!
  quit ..StartTestConfigAssistant(1)
}

ClassMethod StartTestChoice3ConfigAssistant()
{
  write !, $$$FormatWizardMsg($$$PCWManageChangeTestSettingsChoice3Description)
  
  write !!, $$$FormatWizardMsg($$$PCWPlaceholdersAnnounce), !!
  
  write $$$FormatWizardMsg($$$PCWPlaceholdersProject), !
  write $$$FormatWizardMsg($$$PCWPlaceholdersNamespace), !
  write $$$FormatWizardMsg($$$PCWPlaceholdersUsername), !
  write $$$FormatWizardMsg($$$PCWPlaceholdersInstallDir)
  
  write !!, $$$FormatWizardMsg($$$PCWPathRelative), !
    
  write $$$FormatWizardMsg($$$PCWPathDefault), !, "tests", !
  write $$$FormatWizardMsg($$$PCWPathCurrent), !, $get(^Port.SourceControl.Settings("test.path")), !!
  write $$$FormatWizardMsg($$$PCWPathNew), !
  read path
   
  do ##class(Port.SourceControl.Config).SetTestPath(path)
  write !!, $$$FormatWizardMsg($$$PCWManageChangeTestSettingsChoice3StatusNow, ^Port.SourceControl.Settings("test.path"))
  write !!
  quit ..StartTestConfigAssistant(1)
}

}


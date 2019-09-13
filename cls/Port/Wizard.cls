Include portutils

Class Port.Wizard [ Abstract ]
{

ClassMethod Start(hideIntroduction As %Boolean = 0)
{
  set validChoices = $listbuild(1,2,3,4,5)
  set invalidChoice = 1
  set choice = ""  
  
  if 'hideIntroduction {
    write !, $$$FormatWizardMsg($$$PCWWelcome)
  }
  
  while invalidChoice {
    if invalidChoice && (choice '= "") write $$$FormatWizardMsg($$$PCWInvalidChoice)
    do Menu
  }
    
  if choice = 1 return ..StartWorkspaceConfigAssistant() quit
  if choice = 2 return ..StartTestConfigAssistant() quit
  if choice = 3 return ..StartAutoExportXMLConfigAssistant() quit
  if choice = 4 return ..StartLogLevelConfigAssistant() quit
  if choice = 5 write !, $$$FormatWizardMsg($$$PCWBye) return $$$OK
         
Menu
  set choice = ""
  write !!, $$$FormatWizardMsg($$$PCWChoiceQuestion), !!
  
  write $$$FormatWizardMsg($$$PCWManageWorkspaceChoice), !
  write $$$FormatWizardMsg($$$PCWManageChangeTestSettingsChoice), !
  write $$$FormatWizardMsg($$$PCWToggleAutoExportChoice), !
  write $$$FormatWizardMsg($$$PCWSetLogLevelChoice), !
  write $$$FormatWizardMsg($$$PCWExit), !!
  
  write $$$FormatWizardMsg($$$PCWChoicePrompt)
  
  read choice
  write !  
  set invalidChoice = ($listfind(validChoices, choice) = 0)
  quit
}

ClassMethod StartWorkspaceConfigAssistant(hideIntroduction As %Boolean = 0)
{
 
  set validChoices = $listbuild(1,2,3,4,5)
  set invalidChoice = 1
  set choice = ""    
  
  if 'hideIntroduction {  
    write !, $$$FormatWizardMsg($$$PCWManageWorkspaceDescription), !!
  }
  
  while invalidChoice {
    if invalidChoice && (choice '= "") write $$$FormatWizardMsg($$$PCWInvalidChoice), !!
    do Menu
  }
  
  if choice = 1 return ..StartWorkspaceChoice1ConfigAssistant()
  if choice = 2 return ..StartWorkspaceChoice2ConfigAssistant()
  if choice = 3 return ..Start(1)
  
  return $$$OK
    
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
  write $$$FormatWizardMsg($$$PCWPathCurrent), !, $get(^Port.Configuration("source.path"), "none"), !!
  write $$$FormatWizardMsg($$$PCWPathNew), !
  read path
  
  if path = "" set path = "/CacheProjects/{NAMESPACE}/{PROJECT}"
    
  do ##class(Port.Configuration).SetPrimaryWorkspace(path)
  write !!, $$$FormatWizardMsg($$$PCWManageWorkspaceChoice1StatusNow, path), !
  return ..StartWorkspaceConfigAssistant(1)
}

ClassMethod StartWorkspaceChoice2ConfigAssistant()
{
  write !, $$$FormatWizardMsg($$$PCWManageWorkspaceChoice2Description), ! 
  write !, $$$FormatWizardMsg($$$PCWManageWorkspaceChoice2Description2), !
  
  write !, $$$FormatWizardMsg($$$PCWManageWorkspaceChoice2Prompt), !
  read projectName
  
  if projectName = "" write !, $$$FormatWizardMsg($$$PCWAborted), !! return ..StartWorkspaceConfigAssistant(1)
  set projectExists = ##class(%Studio.Project).%ExistsId(projectName)
  
  if 'projectExists {
    write !!, $$$FormatWizardMsg($$$PCWManageWorkspaceChoice2Warning), !!
  }  
  
  set currentWorkspace = ##class(Port.Configuration).GetCustomWorkspace(projectName)
  write !!, $$$FormatWizardMsg($$$PCWManageWorkspaceChoice1StatusCurrent, ##class(Port.Configuration).GetWorkspace(projectName)), !
  write !, $$$FormatWizardMsg($$$PCWManageWorkspaceChoice2CurrentWorskpaceWarn)
  
  write !!, $$$FormatWizardMsg($$$PCWPathAbsolute), !!
  
  write $$$FormatWizardMsg($$$PCWPlaceholdersProject), !
  write $$$FormatWizardMsg($$$PCWPlaceholdersNamespace), !
  write $$$FormatWizardMsg($$$PCWPlaceholdersUsername), !
  write $$$FormatWizardMsg($$$PCWPlaceholdersInstallDir)
    
  write !!, $$$FormatWizardMsg($$$PCWPathOSSchemes) 
  
  write !!, $$$FormatWizardMsg($$$PCWManageWorkspaceChoice2Prompt2), !
  read workspacePath
  
  if workspacePath = "" write !, $$$FormatWizardMsg($$$PCWAborted), !! return ..StartWorkspaceConfigAssistant(1)
  
  do ##class(Port.Configuration).SetCustomWorkspace(projectName, workspacePath)
  write !!, $$$FormatWizardMsg($$$PCWManageWorkspaceChoice2StatusNow, projectName, ##class(Port.Configuration).GetWorkspace(projectName)), !
  
  return ..StartWorkspaceConfigAssistant(1)
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
  
  if choice = 1 return ..StartTestChoice1ConfigAssistant()
  if choice = 2 return ..StartTestChoice2ConfigAssistant()
  if choice = 3 return ..StartTestChoice3ConfigAssistant()
  if choice = 4 return ..Start(1)
  
  return $$$OK
    
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
  
  set labels(0) = $$$FormatWizardMsg($$$PCWToggleDisabled)
  set labels(1) = $$$FormatWizardMsg($$$PCWToggleEnabled)
  
  write !, $$$FormatWizardMsg($$$PCWToggleAutoExportDescription), !

  while invalidChoice {
    if invalidChoice && (choice '= "") write $$$FormatWizardMsg($$$PCWInvalidChoice), !!
    do Menu
  }
  
  if choice = 1 do ##class(Port.Configuration).EnableAutoExportXML()
  if choice = 2 do ##class(Port.Configuration).DisableAutoExportXML() set choice = 0
    
  write $$$FormatWizardMsg($$$PCWToggleAutoExportChoice1StatusCurrent, labels(choice))
  
  write !!
  return ..Start(1)
  
Menu
  set choice = ""
  write !, $$$FormatWizardMsg($$$PCWChoiceQuestion), !!
    
  write $$$FormatWizardMsg($$$PCWToggleAutoExportChoice1), ! 
  write $$$FormatWizardMsg($$$PCWToggleAutoExportChoice2), !!  
     
  set status = ##class(Port.Configuration).IsAutoExportXMLEnabled()
  
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
  
  do ##class(Port.Configuration).SetLogLevel(choice)
  write $$$FormatWizardMsg($$$PCWSetLogLevelStatusNow, ##class(Port.Configuration).GetLogLevel())
  return ..Start(1)
  
Menu
  set choice = ""
  write !, $$$FormatWizardMsg($$$PCWSetLogLevelStatusPrompt), !!
    
  write $$$FormatWizardMsg($$$PCWSetLogLevelStatusChoice1), !!
  
  write $$$FormatWizardMsg($$$PCWSetLogLevelStatusChoice2), !!
  
  write $$$FormatWizardMsg($$$PCWSetLogLevelStatusCurrent, ##class(Port.Configuration).GetLogLevel()), !!
  write $$$FormatWizardMsg($$$PCWChoicePrompt)
  
  read choice
  set invalidChoice = ($listfind(validChoices, choice) = 0)
  write !
  quit
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
  
  if choice = 1 do ##class(Port.Configuration).EnableTestOnDemand()      
  if choice = 2 do ##class(Port.Configuration).DisableTestOnDemand()
  
  write $$$FormatWizardMsg($$$PCWManageChangeTestSettingsChoice1StatusCurrent, labels(choice - 1))
  
  write !
  return ..StartTestConfigAssistant(1)
  
Menu
  set choice = ""
  write !, $$$FormatWizardMsg($$$PCWChoiceQuestion), !!
    
  write $$$FormatWizardMsg($$$PCWManageChangeTestSettingsChoice1Choice1), ! 
  write $$$FormatWizardMsg($$$PCWManageChangeTestSettingsChoice1Choice2), !! 
     
  set status = ##class(Port.Configuration).IsTestOnDemandEnabled()
  
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
  write $$$FormatWizardMsg($$$PCWPathCurrent), " ", ##class(Port.Configuration).GetTestClassPrefix(), !!
  write $$$FormatWizardMsg($$$PCWPathNew)
  read prefix   
  
  do ##class(Port.Configuration).SetTestClassPrefix(prefix)
  write !!, $$$FormatWizardMsg($$$PCWManageChangeTestSettingsChoice2StatusNow, ##class(Port.Configuration).GetTestClassPrefix())
  write !!
  return ..StartTestConfigAssistant(1)
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
  write $$$FormatWizardMsg($$$PCWPathCurrent), !, $get(^Port.Configuration("test.path")), !!
  write $$$FormatWizardMsg($$$PCWPathNew), !
  read path
   
  do ##class(Port.Configuration).SetTestPath(path)
  write !!, $$$FormatWizardMsg($$$PCWManageChangeTestSettingsChoice3StatusNow, ^Port.Configuration("test.path"))
  write !!
  return ..StartTestConfigAssistant(1)
}

}


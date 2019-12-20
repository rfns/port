Include portutils

Class Port.Installer [ Abstract ]
{

XData LocaleEN [ XMLNamespace = "https://github.com/rfns/port" ]
{
<?xml version="1.0" encoding="UTF-8"?>
<MsgFile Language="en">
  <MsgDomain Domain="Port Errors">
    <Message Id="-100" Name="InvalidPhysicalPath">The provided physical path '%1' is not part of the static files directory.</Message>
    <Message Id="-101" Name="NamespaceDoesntHaveAppWithPath">There is not an application with a physical path for the namespace %1.</Message>
    <Message Id="-102" Name="CannotCreateDirectory">Could not create the directory %1.</Message>
    <Message Id="-103" Name="CannotUseRelativePath">Cannot use a relative path, an absolute path must be provided.</Message>
    <Message Id="-104" Name="UnableToCopySource">Could not copy the file from %1 to %2.</Message> 
    <Message Id="-105" Name="UnableToExportInvalidItem">Could not export the item %1 because it does not exist.</Message>
    <Message Id="-106" Name="ErrorsWhileImporting">There were errors while export the project %1.</Message>
    <Message Id="-107" Name="AmbiguousPartialToWorkspace">The obtained partial path %1 is ambiguous to this project path. If you want to export the project itself, then use the 'Import' method.</Message>
    <Message Id="-108" Name="SupressedAttemptToExportFromOutside">Cannot import a file that is outside the project workspace.</Message>    
    <Message Id="-109" Name="UnableToRemoveDirectory">Could not remove the directory %1.</Message>
    <Message Id="-110" Name="UnableToDescribeItem">Could not describe the item %1 due to a violation regarding the expected extension: this item should %2</Message>
    <Message Id="-111" Name="PortIsNotInstalled">Port is not installed on namespace %1.</Message>
    <Message Id="-112" Name="NoTestSuitesWereFound">No tests suites were found for this project.</Message>
    <Message Id="-113" Name="ExportingProjectNotFound">The selected %1 project does not exist.</Message>
    <Message Id="-114" Name="ErrorsWhileImportingType">There were errors while importing items type of %1.</Message>
    <Message Id="-115" Name="LogLevelIsOutOfRange">The provided log level %1 is out of range. Parameter must be one of: %2.</Message>
    <Message Id="-116" Name="CouldNotDetermineWorkspace">Could not determine the correct workspace from the provided path.</Message>
    <Message Id="-117" Name="CannotSaveConflictingItems">Cannot save items that belongs to other projects. Please remove '%1' from the projects listed below if you want to save it into '%3': %2</Message>
    <Message Id="-118" Name="FailedWhileRunningExtendedHook">Failed while running extended hook '%1'.</Message>
    <Message Id="-119" Name="NoCompatibleApplicationForPublicFile">There is no compatible web application for the public file located at %1.</Message>
  </MsgDomain>
  <MsgDomain Domain="Port Log Messages">
    <Message Id="-200" Name="BackupStart">Starting backup ...</Message>
    <Message Id="-201" Name="BackupAlert">DO NOT INTERRUPT THIS PROCESS.</Message>
    <Message Id="-202" Name="BackupMirror">Mirroring the web application to a temporary directory ...</Message>
    <Message Id="-203" Name="RemovingBackupMirror">Removing the temporary directory.</Message>
    <Message Id="-300" Name="NoItemsToExport">There are no items to export. The operation has been aborted.</Message>
    <Message Id="-301" Name="ExportingProject">Exporting the project %1.</Message>
    <Message Id="-302" Name="SourceExportedToPath">The source code has been exported to the path %1.</Message>
    <Message Id="-303" Name="ExportingType">Exporting %1 %2 ...</Message>
    <Message Id="-304" Name="NewWorkspaceDetected">A new workspace has been detected for %1. The project will be exported as a whole.</Message>
    <Message Id="-400" Name="SynchronizingProject">Synchronizing the project %1.</Message>
    <Message Id="-401" Name="CheckingExtraneousItems">Checking the project for extraneous items ...</Message>
    <Message Id="-402" Name="TotalExtraneousItems">Total extraneous items found: %1.</Message>
    <Message Id="-403" Name="NoExtraneousItems">No extraneous items were found.</Message>
    <Message Id="-404" Name="RemovingFile">Removing %1 (file).</Message>
    <Message Id="-405" Name="RemovingDirectory">Removing %1 (directory).</Message>
    <Message Id="-406" Name="TotalExtraneousItemsRemoved">Total of extraneous items removed: %1</Message>
    <Message Id="-500" Name="Done"> done.</Message>
    <Message Id="-501" Name="DoneWithErrors"> done, but with errors.</Message>
    <Message Id="-501" Name="Failed"> failed. Reason: %1.</Message>
    <Message Id="-502" Name="AllDone">Finished with success.</Message>
    <Message Id="-503" Name="UpToDate"> is up-to-date.</Message>
    <Message Id="-504" Name="OvewriteWithExtension"> end with the %1 extension.</Message>
    <Message Id="-600" Name="ImportingType">Importing %1 %2 ...</Message>
    <Message Id="-601" Name="EnqueingType">Enqueueing the selected %1 to be imported.</Message>
    <Message Id="-602" Name="NothingToImport">Nothing to import has been found.</Message>
    <Message Id="-603" Name="ImportingProject">Importing the project %1.</Message>
    <Message Id="-604" Name="EnqueueingItems">Enqueing items to be imported ...</Message>
    <Message Id="-605" Name="TotalItemsToImport">Total of items to import: %1.</Message>
    <Message Id="-606" Name="NoPendingItemsToImport">No items to import were found.</Message>
    <Message Id="-607" Name="NewProject">The project %1 does not exist yet and will be created.</Message>
    <Message Id="-608" Name="FatalErrorAlert">FATAL: The following errors prevented the project from being imported:</Message>
    <Message Id="-609" Name="FatalRollbackAlert">All changes will be discarded on the next steps.</Message>
    <Message Id="-610" Name="FatalProjectIntegrityRiskWarning">WARNING! DO NOT INTERRUPT THE PROCESS TO AVOID COMPROMISING THE PROJECT INTEGRITY!</Message>
    <Message Id="-611" Name="FatalRollingBackTransaction">Discarding the pending transaction ...</Message>
    <Message Id="-612" Name="FatalApplyingBackup">Applying the backup to revert the web application back to its initial state.</Message>
    <Message Id="-613" Name="FatalFailedToRestoreBackup">ERROR: Could not apply the backup entirely due to a system error. The backup will be kept to be applied manually.</Message>    
    <Message Id="-614" Name="ProjectSaved">The project %1 has been saved with %2 items.</Message>
    <Message Id="-700" Name="CannotUseDefault">The usage of 'Default' named projects is prohibited. If you want use this project, you must provide another name by using File->Save As.</Message>
    <Message Id="-701" Name="CannotUseDefault2">All active hooks are now disabled.</Message>    
    <Message Id="-800" Name="ClassType">class</Message>
    <Message Id="-801" Name="ProjectType">project</Message>
    <Message Id="-802" Name="RoutineType">routine</Message>
    <Message Id="-803" Name="FileType">file</Message>
    <Message Id="-804" Name="DirectoryType">diretório</Message>
    <Message Id="-805" Name="MACGroupType">macro routines</Message>
    <Message Id="-806" Name="INCGroupType">include files</Message>
    <Message Id="-807" Name="INTGroupType">intermediate routines</Message>
    <Message Id="-808" Name="BASGroupType">Basic routines</Message>
    <Message Id="-809" Name="MVBGroupType">MV Basic routines</Message>
    <Message Id="-810" Name="MVIGroupType">MVI routines</Message>
    <Message Id="-811" Name="DFIGroupType">DFI files</Message>
    <Message Id="-812" Name="CLSGroupType">classes</Message>
    <Message Id="-813" Name="FileGroupType">files</Message>
    <Message Id="-900" Name="ExportingXML">Exporting the project %1 to XML ...</Message>
    <Message Id="-901" Name="XMLExportedTo">%1 project XML exported to %2.</Message>
    <Message Id="-902" Name="ExportingTestClassToXML">Exporting test class %1 ...</Message>
    <Message Id="-1000" Name="ConflictingItemDetected">CAUTION! Detected the usage of the item %1 on the following projects: %2.</Message>
    <Message Id="-1001" Name="ConflictingItemDetected2">It's extremely recommended to keep the item exclusive to a single project!</Message>
    <Message Id="-1100" Name="RunningCustomHook">Executing hook extension %1 from the class %2 ...</Message>
    <Message Id="-1101" Name="HookReturnedOK">%1 returned without errors.</Message>
    <Message Id="-1102" Name="HookReturnedError">Failed while executing %1 due to the following reason: %2.</Message>
  </MsgDomain>
  <MsgDomain Domain="Port Menu Labels">
    <Message Id="-5000" Name="MLExport">Export</Message>    
    <Message Id="-5001" Name="MLExportToXML">Export to XML</Message>
    <Message Id="-5002" Name="MLExportTests">Export tests</Message>
    <Message Id="-5003" Name="MLRemoveClasses">Remove classes</Message>
    <Message Id="-5004" Name="MLRemoveFiles">Remove files</Message>
    <Message Id="-5005" Name="MLRemoveRoutines">Remove routines</Message>
    <Message Id="-5006" Name="MLScanAndFix">Scan and fix</Message>
    <Message Id="-5007" Name="MLRunTests">Run tests</Message>
    <Message Id="-5008" Name="MLImport">Import</Message>
    <Message Id="-5009" Name="MLForceExport">Export (forced)</Message>
    <Message Id="-5010" Name="MLForceImport">Import (forced)</Message>
  </MsgDomain>
  <MsgDomain Domain="Port Context Menu Labels">
    <Message Id="-6000" Name="CMLExportActive">Export from here</Message>
    <Message Id="-6001" Name="CMLImportActive">Import from here</Message>
    <Message Id="-6002" Name="CMLRunActiveTest">Run test</Message>
  </MsgDomain>
  <MsgDomain Domain="Port Configuration Wizard">
    <Message Id="-7000" Name="PCWWelcome">Welcome to the Port configuration wizard.</Message>
    <Message Id="-7001" Name="PCWInvalidChoice">Invalid choice.</Message>
    <Message Id="-7002" Name="PCWChoiceQuestion">What do you want to do? (type the number)</Message>
    <Message Id="-7003" Name="PCWChoicePrompt">Your choice: </Message>
    <Message Id="-7004" Name="PCWAborted">Aborted.</Message>
    <Message Id="-7005" Name="PCWToggleEnabled">ENABLED</Message>
    <Message Id="-7006" Name="PCWToggleDisabled">DISABLED</Message>
    <Message Id="-7007" Name="PCWBye">Bye.</Message>
    <Message Id="-7100" Name="PCWManageWorkspaceChoice">1. Manage workspaces.</Message>
    <Message Id="-7101" Name="PCWManageWorkspaceDescription">Manages workspaces that will contain the exported source code.</Message>
    <Message Id="-7110" Name="PCWManageWorkspaceChoice1">1. Change primary workspace.</Message>
    <Message Id="-7111" Name="PCWManageWorkspaceChoice1Description">Configures the primary workspace that will be used to export your source code.</Message>    
    <Message Id="-7112" Name="PCWManageWorkspaceChoice1StatusCurrent">The current primary workspace is %1.</Message>
    <Message Id="-7113" Name="PCWManageWorkspaceChoice1StatusNow">The primary workspace is now set to %1.</Message>
    <Message Id="-7120" Name="PCWManageWorkspaceChoice2">2. Manage existing workspaces.</Message>
    <Message Id="-7121" Name="PCWManageWorkspaceChoice2Description">Manages workspaces associated to projects.</Message>
    <Message Id="-7122" Name="PCWManageWorkspaceChoice2Description2">Projects named here will not use the primary workspace definition.</Message>
    <Message Id="-7123" Name="PCWManageWorkspaceChoice2Prompt">Type the name of the project (or leave it empty to abort):</Message>
    <Message Id="-7124" Name="PCWManageWorkspaceChoice2Warning">WARNING: The project %1 doesn't exist yet."</Message>
    <Message Id="-7125" Name="PCWManageWorkspaceChoice2StatusCurrent">Current workspace for this project is: %1.</Message>
    <Message Id="-7126" Name="PCWManageWorkspaceChoice2CurrentWorskpaceWarn">You will be asked for a new workspace now.</Message>
    <Message Id="-7127" Name="PCWManageWorkspaceChoice2Prompt2">Type the workspace path (or leave it empty to abort):</Message>
    <Message Id="-7128" Name="PCWManageWorkspaceChoice2StatusNow">The project %1 is now configured to be exported using the following path: %2.</Message>    
    <Message Id="-7200" Name="PCWManageChangeTestSettingsChoice">2. Change test settings.</Message>
    <Message Id="-7201" Name="PCWManageChangeTestSettingsDescription">Configures settings related to the Studio test integration.</Message>
    <Message Id="-7210" Name="PCWManageChangeTestSettingsChoice1">1. Enable or disable test on demand.</Message>
    <Message Id="-7211" Name="PCWManageChangeTestSettingsChoice1Description">When this settings is enabled, Port will try to match the test class prefix and run the related test.</Message>
    <Message Id="-7212" Name="PCWManageChangeTestSettingsChoice1Choice1">1. Enable test on demand.</Message>
    <Message Id="-7213" Name="PCWManageChangeTestSettingsChoice1Choice2">2. Disable test on demand.</Message>
    <Message Id="-7214" Name="PCWManageChangeTestSettingsChoice1StatusCurrent">Test on demand is currently %1.</Message>
    <Message Id="-7220" Name="PCWManageChangeTestSettingsChoice2">2. Define a new test class prefix.</Message>
    <Message Id="-7221" Name="PCWManageChangeTestSettingsChoice2Description">A test class prefix is required to inform Port which package should be considered as a test package.</Message>
    <Message Id="-7222" Name="PCWManageChangeTestSettingsChoice2Description2">Port uses this prefix when trying to find an equivalent implementation class.</Message>
    <Message Id="-7223" Name="PCWManageChangeTestSettingsChoice2Description3">Ex: UnitTest.MyPackage.MyClass -> MyPackage.MyClass.</Message>
    <Message Id="-7224" Name="PCWManageChangeTestSettingsChoice2Prompt">Please type the prefix below. Note that prefixes can also be composed. Ex: Package.UnitTest.</Message>
    <Message Id="-7225" Name="PCWManageChangeTestSettingsChoice2StatusNow">The prefix is now set to: %1.</Message>
    <Message Id="-7230" Name="PCWManageChangeTestSettingsChoice3">3. Define the path where unit test classes should exported (XML).</Message>
    <Message Id="-7231" Name="PCWManageChangeTestSettingsChoice3Description">Defines the path where the each test classes should be exported.</Message>
    <Message Id="-7232" Name="PCWManageChangeTestSettingsChoice3StatusNow">"The test path is now set to: %1.</Message>
    <Message Id="-7300" Name="PCWToggleAutoExportChoice">3. Toggle project XML auto-export.</Message>
    <Message Id="-7301" Name="PCWToggleAutoExportDescription">Exports a XML file from project when a document is saved.</Message>
    <Message Id="-7302" Name="PCWToggleAutoExportChoice1StatusCurrent">Auto-export XML is currently %1.</Message>
    <Message Id="-7303" Name="PCWToggleAutoExportChoice1StatusNow">Auto-export XML is now %1.</Message>
    <Message Id="-7310" Name="PCWToggleAutoExportChoice1">1. Enable project XML auto-export.</Message>
    <Message Id="-7320" Name="PCWToggleAutoExportChoice2">2. Disable project XML auto-export.</Message>    
    <Message Id="-7400" Name="PCWSetLogLevelChoice">4. Set log level.</Message>
    <Message Id="-7401" Name="PCWSetLogLevelDescription">Specifies the log verbosity level when displaying operations.</Message>
    <Message Id="-7402" Name="PCWSetLogLevelStatusCurrent">Log verbosity level is currently: %1.</Message>
    <Message Id="-7403" Name="PCWSetLogLevelStatusNow">Log verbosity level is now: %1.</Message>
    <Message Id="-7404" Name="PCWSetLogLevelStatusPrompt">Please set the log verbosity level (type the number): </Message>
    <Message Id="-7410" Name="PCWSetLogLevelStatusChoice1">1. Level 1: Displays item enqueieing, import categories, backup notifications, repository status and error messages.</Message>
    <Message Id="-7420" Name="PCWSetLogLevelStatusChoice2">2. Level 2: Includes all verbosity from Level 1 plus detailed logging about atomical operations.</Message>    
    <Message Id="-7600" Name="PCWExit">5. Exit.</Message>
    <Message Id="-7970" Name="PCWPlaceholdersAnnounce">You can use the following specific placeholders:</Message>
    <Message Id="-7971" Name="PCWPlaceholdersProject">{PROJECT} - The active project name.</Message>
    <Message Id="-7972" Name="PCWPlaceholdersNamespace">{NAMESPACE} - The active namespace name.</Message>
    <Message Id="-7973" Name="PCWPlaceholdersUsername">{USERNAME} - The active user name.</Message>
    <Message Id="-7974" Name="PCWPlaceholdersInstallDir">{INSTALLDIR} - The Caché installation directory.</Message>
    <Message Id="-7980" Name="PCWPathRelative">Please type the RELATIVE path to be used when exporting your test files. Paths should be relative to the exported project root. (Or leave it empty to restore the default)</Message>
    <Message Id="-7981" Name="PCWPathAbsolute">Please type the ABSOLUTE path to be used when exporting your source files (Or leave it empty to restore the default)</Message>
    <Message Id="-7982" Name="PCWPathOSSchemes">You can use both: *NIX or Windows schemes.</Message>
    <Message Id="-7983" Name="PCWPathDefault">Default is:</Message>
    <Message Id="-7984" Name="PCWPathCurrent">Current is:</Message>
    <Message Id="-7985" Name="PCWPathNew">New: </Message>
    <Message Id="-7999" Name="PCWGoBackChoice">%1. Go back.</Message>
  </MsgDomain>
</MsgFile>
}

XData LocalePTBR [ XMLNamespace = "https://github.com/rnfs/port" ]
{
<?xml version="1.0" encoding="UTF-8"?>
<MsgFile Language="pt-br">
  <MsgDomain Domain="Port Errors">
    <Message Id="-100" Name="InvalidPhysicalPath">O caminho físico '%1' fornecido não pertence ao diretório de arquivos estáticos.</Message>
    <Message Id="-101" Name="NamespaceDoesntHaveAppWithPath">Não existe uma aplicação com caminho físico para o namespace %1.</Message>
    <Message Id="-102" Name="CannotCreateDirectory">Não foi possível criar o diretório %1.</Message>
    <Message Id="-103" Name="CannotUseRelativePath">Não é possível utilizar um caminho relativo, o caminho precisa estar completo.</Message> 
    <Message Id="-104" Name="UnableToCopySource">Não foi possível copiar o arquivo de %1 para %2.</Message> 
    <Message Id="-105" Name="UnableToExportInvalidItem">Não foi possível exportar o item %1 pois ele não existe.</Message>
    <Message Id="-106" Name="ErrorsWhileImporting">Houveram erros ao importar %1.</Message>
    <Message Id="-107" Name="AmbiguousPartialToWorkspace">O caminho parcial %1 obtido é ambíguo ao caminho deste projeto. Se você deseja exportar o projeto, utilize o método 'Import'.</Message>
    <Message Id="-108" Name="SupressedAttemptToExportFromOutside">Não é possível importar um arquivo que esteja fora do espaço de trabalho deste projeto.</Message>
    <Message Id="-109" Name="UnableToRemoveDirectory">Não foi possível remover o diretório %1.</Message>
    <Message Id="-110" Name="UnableToDescribeItem">Não foi possível descrever o item o %1 devido à uma violação no extensão esperada: este item deve %2</Message>
    <Message Id="-111" Name="PortIsNotInstalled">Port não está instalado no namespace %1.</Message>
    <Message Id="-112" Name="NoTestSuitesWereFound">Não foram encontradas suítes de teste para este projeto.</Message>
    <Message Id="-113" Name="ExportingProjectNotFound">O projeto %1 selecionado para ser exportado não existe.</Message>
    <Message Id="-114" Name="ErrorsWhileImportingType">Houveram errors ao importar itens do tipo %1.</Message>
    <Message Id="-115" Name="LogLevelIsOutOfRange">O nível de log fornecido está fora da faixa permitida. O parâmetro deve ser um destes: %2.</Message>
    <Message Id="-116" Name="CouldNotDetermineWorkspace">Não foi possível determinar o espaço de trabalho correto a patir do caminho fornecido.</Message>
    <Message Id="-117" Name="CannotSaveConflictingItems">Não é possível salvar itens que pertençam a outros projetos. Por favor remova o item %1 dos projetos abaixo se você deseja salvá-lo em '%3': %2</Message>
    <Message Id="-118" Name="FailedWhileRunningExtendedHook">Falha ao rodar extensão do evento '%1'.</Message>
    <Message Id="-119" Name="NoCompatibleApplicationForPublicFile">Não existe uma aplicação web compatível com o arquivo público localizado em %1.</Message>
  </MsgDomain>
  <MsgDomain Domain="Port Log Messages">
    <Message Id="-200" Name="BackupStart">Iniciando backup...</Message>
    <Message Id="-201" Name="BackupAlert">NÃO INTERROMPA ESTE PROCESSO.</Message>
    <Message Id="-202" Name="BackupMirror">Espelhando a estrutura da aplicação web para um diretório temporário ...</Message>
    <Message Id="-203" Name="RemovingBackupMirror">Removendo o diretório temporário.</Message>
    <Message Id="-300" Name="NoItemsToExport">Não há itens para serem exportados. A operação foi abortada.</Message>
    <Message Id="-301" Name="ExportingProject">Exportando o projeto %1.</Message>
    <Message Id="-302" Name="SourceExportedToPath">O código-fonte foi exportado para o caminho %1.</Message>
    <Message Id="-303" Name="ExportingType">Exportando %1 %2 ...</Message>
    <Message Id="-304" Name="NewWorkspaceDetected">Um novo espaço de trabalho foi detectado para %1. O projeto será exportado como um todo.</Message>
    <Message Id="-400" Name="SynchronizingProject">Sincronizando o projeto %1.</Message>
    <Message Id="-401" Name="CheckingExtraneousItems">Verificando o projeto em busca de itens desconhecidos ... </Message>
    <Message Id="-402" Name="TotalExtraneousItems">Total de items desconhecidos encontrados: %1.</Message>
    <Message Id="-403" Name="NoExtraneousItems">Não há itens para eliminar.</Message>
    <Message Id="-404" Name="RemovingFile">Removendo %1 (arquivo).</Message>
    <Message Id="-405" Name="RemovingDirectory">Removendo %1 (diretório).</Message>
    <Message Id="-406" Name="TotalExtraneousItemsRemoved">Total de itens desconhecidos removidos: %1.</Message>
    <Message Id="-500" Name="Done"> feito.</Message>
    <Message Id="-501" Name="DoneWithErrors"> feito, mas com erros.</Message>
    <Message Id="-501" Name="Failed"> falhou.</Message>
    <Message Id="-502" Name="AllDone">Terminado com sucesso.</Message>
    <Message Id="-503" Name="UpToDate"> o item já está atualizado.</Message>
    <Message Id="-504" Name="OvewriteWithExtension">terminar com a extensão %1.</Message> 
    <Message Id="-600" Name="ImportingType">Importando %1 %2 ...</Message>
    <Message Id="-601" Name="EnqueingType">Enfileirando o %1 escolhido para ser importado ...</Message>
    <Message Id="-602" Name="NothingToImport">Nada para importar foi encontrado.</Message>
    <Message Id="-603" Name="ImportingProject">Importando o projeto %1.</Message>
    <Message Id="-604" Name="EnqueueingItems">Enfilerando itens para serem importados.</Message>
    <Message Id="-605" Name="TotalItemsToImport">Total de itens para importar: %1.</Message>
    <Message Id="-606" Name="NoPendingItemsToImport">Não há itens para serem importados.</Message>
    <Message Id="-607" Name="NewProject">O projeto %1 ainda não existe e será criado a seguir.</Message>
    <Message Id="-608" Name="FatalErrorAlert">FATAL: O seguintes erros impediram o projeto de ser importado:</Message>
    <Message Id="-609" Name="FatalRollbackAlert">As alterações serão desfeitas nas etapas a seguir.</Message>
    <Message Id="-610" Name="FatalProjectIntegrityRiskWarning">AVISO! NÃO INTERROMPA O PROCESSO PARA NÃO COMPROMETER A INTEGRIDADE DO PROJETO!</Message>
    <Message Id="-611" Name="FatalRollingBackTransaction">Descartando a transação pendente ...</Message>
    <Message Id="-612" Name="FatalApplyingBackup">Aplicando o backup para reverter alterações no caminho da aplicação.</Message>
    <Message Id="-613" Name="FatalFailedToRestoreBackup">ERRO: Não foi possível aplicar o backup inteiramente devido a um erro de sistema. O backup será mantido para uma correção manual.</Message>
    <Message Id="-614" Name="ProjectSaved">O projeto %1 foi salvo com %2 itens.</Message>
    <Message Id="-700" Name="CannotUseDefault">Não é permitido o uso de projetos 'Default'. Se você deseja usar este projeto, você precisa fornecer outro nome utilizando Arquivo->Salvar Como.</Message>
    <Message Id="-701" Name="CannotUseDefault2">Todos os eventos foram desativados.</Message>
    <Message Id="-800" Name="ClassType">classe</Message>
    <Message Id="-801" Name="ProjectType">projeto</Message>
    <Message Id="-802" Name="RoutineType">rotina</Message>
    <Message Id="-803" Name="FileType">arquivo</Message>
    <Message Id="-804" Name="DirectoryType">diretório</Message>
    <Message Id="-805" Name="MACGroupType">rotinas macro</Message>
    <Message Id="-806" Name="INCGroupType">arquivos de inclusão</Message>
    <Message Id="-807" Name="INTGroupType">rotinas intermediárias</Message>
    <Message Id="-808" Name="BASGroupType">rotinas Basic</Message>
    <Message Id="-809" Name="MVBGroupType">rotinas MV Basic</Message>
    <Message Id="-810" Name="MVIGroupType">rotinas MVI</Message>
    <Message Id="-811" Name="DFIGroupType">arquivos DFI</Message>
    <Message Id="-812" Name="CLSGroupType">classes</Message>
    <Message Id="-813" Name="FileGroupType">arquivos</Message>
    <Message Id="-900" Name="ExportingXML">Exportando o projeto %1 para XML ...</Message>
    <Message Id="-901" Name="XMLExportedTo">XML do projeto %1 exportado para %2.</Message>
    <Message Id="-902" Name="ExportingTestClassToXML">Exportando a classe de teste %1 ...</Message>
    <Message Id="-1000" Name="ConflictingItemDetected">CUIDADO! Foi detectada a presença do item %1 nos seguintes projetos: %2.</Message>
    <Message Id="-1001" Name="ConflictingItemDetected2">É extremamente recomendado manter o item exclusivo a um projeto!</Message>
    <Message Id="-1100" Name="RunningCustomHook">Executando extensão do evento %1 da classe %2 ...</Message>
    <Message Id="-1101" Name="HookReturnedOK">%1 retornou sem erros.</Message>
    <Message Id="-1102" Name="HookReturnedError">Falhou ao executar %1 devido ao seguinte motivo: %2</Message>
  </MsgDomain>
  <MsgDomain Domain="Port Menu Labels">
    <Message Id="-5000" Name="MLExport">Exportar</Message>    
    <Message Id="-5001" Name="MLExportToXML">Exportar para XML</Message>
    <Message Id="-5002" Name="MLExportTests">Exportar testes</Message>
    <Message Id="-5003" Name="MLRemoveClasses">Remover classes</Message>
    <Message Id="-5004" Name="MLRemoveFiles">Remover arquivos</Message>
    <Message Id="-5005" Name="MLRemoveRoutines">Remover rotinas</Message>
    <Message Id="-5006" Name="MLScanAndFix">Verificar e corrigir</Message>
    <Message Id="-5007" Name="MLRunTests">Executar testes</Message>
    <Message Id="-5008" Name="MLImport">Importar</Message>
    <Message Id="-5009" Name="MLForceExport">Exportar (forçado)</Message>
    <Message Id="-5010" Name="MLForceImport">Importar (forçado)</Message>
  </MsgDomain>
  <MsgDomain Domain="Port Context Menu Labels">
    <Message Id="-6000" Name="CMLExportActive">Exportar a partir deste item</Message>
    <Message Id="-6001" Name="CMLImportActive">Importar a partir deste item</Message>
    <Message Id="-6002" Name="CMLRunActiveTest">Executar teste</Message>
  </MsgDomain>
  <MsgDomain Domain="Port Configuration Wizard">
    <Message Id="-7000" Name="PCWWelcome">Bem-vindo ao assistente de configuração do Port.</Message>
    <Message Id="-7001" Name="PCWInvalidChoice">Escolha inválida.</Message>
    <Message Id="-7002" Name="PCWChoiceQuestion">O que você deseja fazer? (digite o número)</Message>
    <Message Id="-7003" Name="PCWChoicePrompt">Sua escolha: </Message>
    <Message Id="-7004" Name="PCWAborted">Abortado.</Message>
    <Message Id="-7005" Name="PCWToggleEnabled">ATIVADO</Message>
    <Message Id="-7006" Name="PCWToggleDisabled">DESATIVADO</Message>
    <Message Id="-7007" Name="PCWBye">Até mais.</Message>
    <Message Id="-7100" Name="PCWManageWorkspaceChoice">1. Gerenciar espaços de trabalho.</Message>
    <Message Id="-7101" Name="PCWManageWorkspaceDescription">Gerencia espaços de trabalho que irão conter o código-fonte.</Message>
    <Message Id="-7110" Name="PCWManageWorkspaceChoice1">1. Alterar espaço de trabalho padrão.</Message>
    <Message Id="-7111" Name="PCWManageWorkspaceChoice1Description">Altera o espaço de trabalho utilizado por padrão. Aplicável somente para novos projetos.</Message>
    <Message Id="-7112" Name="PCWManageWorkspaceChoice1StatusCurrent">O espaço de trabalho padrão atual é %1.</Message>
    <Message Id="-7113" Name="PCWManageWorkspaceChoice1StatusNow">O espaço de trabalho padrão agora é %1.</Message>
    <Message Id="-7120" Name="PCWManageWorkspaceChoice2">2. Gerencia espaços de trabalho existentes.</Message>
    <Message Id="-7121" Name="PCWManageWorkspaceChoice2Description">Gerencia espaços de trabalhos vinculados a projetos já existentes ou de antemão.</Message>
    <Message Id="-7122" Name="PCWManageWorkspaceChoice2Description2">Esta configuração sobrescreverá o espaço de trabalho padrão para o projeto escolhido.</Message>
    <Message Id="-7123" Name="PCWManageWorkspaceChoice2Prompt">Digite o nome do projeto (ou deixe vazio para abortar):</Message>
    <Message Id="-7124" Name="PCWManageWorkspaceChoice2Warning">AVISO: O projeto %1 ainda não existe."</Message>
    <Message Id="-7125" Name="PCWManageWorkspaceChoice2StatusCurrent">Espaço de trabalho atual para este projeto: %1.</Message>
    <Message Id="-7126" Name="PCWManageWorkspaceChoice2CurrentWorskpaceWarn">Será requisitado um novo espaço de trabalho a seguir.</Message>
    <Message Id="-7127" Name="PCWManageWorkspaceChoice2Prompt2">Digite o caminho do espaço de trabalho (ou deixe vazio para abortar):</Message>
    <Message Id="-7128" Name="PCWManageWorkspaceChoice2StatusNow">O projeto %1 agora está configurado para ser exportado no caminho: %2.</Message>    
    <Message Id="-7200" Name="PCWManageChangeTestSettingsChoice">2. Alterar configurações de teste.</Message>
    <Message Id="-7201" Name="PCWManageChangeTestSettingsDescription">Altera configurações relacionadas à integração do Studio com a API de testes.</Message>
    <Message Id="-7210" Name="PCWManageChangeTestSettingsChoice1">1. Ativar ou desativar testes por demanda.</Message>
    <Message Id="-7211" Name="PCWManageChangeTestSettingsChoice1Description">Quando esta configuração estivar ativa, Port irá tentar encontrar a classe de teste da classe em edição e executar seus testes após sua compilação.</Message>
    <Message Id="-7212" Name="PCWManageChangeTestSettingsChoice1Choice1">1. Ativar testes por demanda.</Message>
    <Message Id="-7213" Name="PCWManageChangeTestSettingsChoice1Choice2">2. Desativar testes por demanda.</Message>
    <Message Id="-7214" Name="PCWManageChangeTestSettingsChoice1StatusCurrent">Testes por demanda está atualmente %1.</Message>
    <Message Id="-7220" Name="PCWManageChangeTestSettingsChoice2">2. Definir um novo prefíxo para classes de teste.</Message>
    <Message Id="-7221" Name="PCWManageChangeTestSettingsChoice2Description">Um prefixo é requirido para informar ao Port qual pacote deve ser considerado como um pacote com classes de teste.</Message>
    <Message Id="-7222" Name="PCWManageChangeTestSettingsChoice2Description2">Este prefíxo é utilizado como uma forma de equivalência.</Message>
    <Message Id="-7223" Name="PCWManageChangeTestSettingsChoice2Description3">Ex: UnitTest.MyPackage.MyClass -> MyPackage.MyClass.</Message>
    <Message Id="-7224" Name="PCWManageChangeTestSettingsChoice2Prompt">Por favor digite o prefíxo abaixo. Note que prefíxos também pode ser compostos. Ex: Package.UnitTest.</Message>
    <Message Id="-7225" Name="PCWManageChangeTestSettingsChoice2StatusNow">O prefíxo agora é: %1.</Message>
    <Message Id="-7230" Name="PCWManageChangeTestSettingsChoice3">3. Alterar caminho para classes de teste (XML).</Message>
    <Message Id="-7231" Name="PCWManageChangeTestSettingsChoice3Description">Define o caminho raíz aonde as classes de testes serão hierarquicamente exportadas.</Message>
    <Message Id="-7232" Name="PCWManageChangeTestSettingsChoice3StatusNow">O caminho para classes de teste agora é: %1.</Message>
    <Message Id="-7300" Name="PCWToggleAutoExportChoice">3. Ativar ou desativar a exportação automática do XML do projeto.</Message>
    <Message Id="-7301" Name="PCWToggleAutoExportDescription">Exporta um arquivo XML quando o projeto ou um item dele é salvo.</Message>
    <Message Id="-7302" Name="PCWToggleAutoExportChoice1StatusCurrent">Exportação automática está atualmente como %1.</Message>
    <Message Id="-7303" Name="PCWToggleAutoExportChoice1StatusNow">Exportação automática agora está como %1.</Message>
    <Message Id="-7310" Name="PCWToggleAutoExportChoice1">1. Ativar exportação automática do XML.</Message>
    <Message Id="-7320" Name="PCWToggleAutoExportChoice2">2. Desativar exportação automática do XML.</Message>
    <Message Id="-7400" Name="PCWSetLogLevelChoice">4. Definir nível de log.</Message>
    <Message Id="-7401" Name="PCWSetLogLevelDescription">Especifica o nível de verbosidade utilizado no log de operações.</Message>
    <Message Id="-7402" Name="PCWSetLogLevelStatusCurrent">Nível de verbosidade atual do log: %1.</Message>
    <Message Id="-7403" Name="PCWSetLogLevelStatusNow">O nível de verbosidade do log agora é: %1.</Message>
    <Message Id="-7404" Name="PCWSetLogLevelStatusPrompt">Por favor escolha o nível de verbosidade do log (digite o número): </Message>
    <Message Id="-7410" Name="PCWSetLogLevelStatusChoice1">1. Nível 1: Exibe enfileiramento, categorias de importação/exportação, notificações de backup, situação do espaço de trabalho e mensagens de erro.</Message>
    <Message Id="-7420" Name="PCWSetLogLevelStatusChoice2">2. Nível 2: Inclui toda a verbosidade do nível 1, substituindo categorias por notificações por item.</Message>    
    <Message Id="-7600" Name="PCWExit">5. Sair.</Message>
    <Message Id="-7970" Name="PCWPlaceholdersAnnounce">Você pode utilizar os seguinte marcadores:</Message>
    <Message Id="-7971" Name="PCWPlaceholdersProject">{PROJECT} - O nome do projeto ativo.</Message>
    <Message Id="-7972" Name="PCWPlaceholdersNamespace">{NAMESPACE} - O namespace ativo.</Message>
    <Message Id="-7973" Name="PCWPlaceholdersUsername">{USERNAME} - O login do usuário que iniciou o processo.</Message>
    <Message Id="-7974" Name="PCWPlaceholdersInstallDir">{INSTALLDIR} - O diretório de instalação.</Message>
    <Message Id="-7980" Name="PCWPathRelative">Por favor digite o caminho RELATIVO a ser utilizado ao exportar os arquivos de teste. Os caminhos devem ser relativos à raiz do projeto exportado. (Ou deixe vazio para usar o padrão)</Message>
    <Message Id="-7981" Name="PCWPathAbsolute">Por favor digite o caminho ABSOLUTO a ser utilizado ao exportar o código-fonte. (Ou deixe vazio para usar o padrão)</Message>
    <Message Id="-7982" Name="PCWPathOSSchemes">Você pode usar ambos: esquemas *NIX ou Windows.</Message>
    <Message Id="-7983" Name="PCWPathDefault">Padrão é:</Message>
    <Message Id="-7984" Name="PCWPathCurrent">Atual é:</Message>
    <Message Id="-7985" Name="PCWPathNew">Novo: </Message>
    <Message Id="-7999" Name="PCWGoBackChoice">%1. Retornar.</Message>
  </MsgDomain>  
</MsgFile>
}

ClassMethod Uninstall() As %Status
{
  if '$data(^Port.Configuration("installed")) {
    return $$$PERROR($$$PortIsNotInstalled, $namespace)
  }
  
  write "Removing Port, please wait ...", !
  set sc = $$$OK
  do ##class(Port.Configuration).Uninstall()
  do ##class(Port.SourceControl.Log).Flush()
  set sc = $$$ADDSC(sc, ##class(%Studio.SourceControl.Interface).SourceControlClassSet($get(^Port.Configuration("old")), $namespace))
  set sc = $$$ADDSC(sc, ##class(Port.SourceControl.LogCleaner).RemoveTask())
  set sc = $$$ADDSC(sc, ..RemoveGlobalMapping())  
  if $$$ISOK(sc) write $$$FormatText("Port has been removed from %1.", $namespace), !
  else  write "One or more errors ocurred while removing Port:", !!, $System.Status.GetErrorText(sc)
  return $$$OK
}

ClassMethod Install(force As %Boolean = {$get(^||Port.Envs("FORCE_INSTALL"), 0)}) As %Status
{
  set sc = $$$OK
  
  if 'force {
    if $data(^Port.Configuration("installed")) {
      write "Port is already installed. The installer has been aborted.", !
      write "If you wish to change current settings then please use the wizard (Wizard^Port) or call this method with force=1.", !!
      return $$$ERROR($$$GeneralError, "Port is already installed.")
    }
  }
  
  try {
    write !, "Installing Port ... please wait a moment.", !    
    write "> Creating Message Dictionary ... ", !
    $$$ThrowOnError(..CreateMessageDictionary())
    write "> Creating global mappings ...", !   
    $$$ThrowOnError(..CreateGlobalMapping())
    write "> Setting up workspace structure ... ", !
    do ##class(Port.Configuration).SetPrimaryWorkspace("/CacheProjects/{NAMESPACE}/{PROJECT}")
    write "> Setting up test files directory ...", !
    do ##class(Port.Configuration).SetTestPath("tests/cls")
    write "> Defining default test class prefix ..", !
    do ##class(Port.Configuration).SetTestClassPrefix("UnitTest")
    write "> Configuring to run tests automatically ...", !
    do ##class(Port.Configuration).EnableTestOnDemand()
    write "> Configuring to export the project to XML automatically ...", !
    do ##class(Port.Configuration).EnableAutoExportXML()
    write "> Configuring log verbosity level to recommended level ...", !
    do ##class(Port.Configuration).SetLogLevel(1)
    write "> Registering source control log cleaner task for "_$namespace_" ...", !
    $$$ThrowOnError(##class(Port.SourceControl.LogCleaner).StartTask())
    write "> Installing %SourceControl hooks and activating it ...", !!
    set ^Port.Configuration("old.sourcecontrol") = ##class(%Studio.SourceControl.Interface).SourceControlClassGet($namespace)
    $$$ThrowOnError(##class(%Studio.SourceControl.Interface).SourceControlClassSet("Port.SourceControl.Hooks", $namespace))
    write "ALL DONE.", !
    write "NOTE: You must restart Studio in order to make the source control hooks work as expected."
    set ^Port.Configuration("installed") = 1
  } catch ex {
    set sc = ex.AsStatus()    
    write !!, "FATAL: Failed to install port due to the following reason: "
    do $System.OBJ.DisplayError(sc)
  }
  return sc
}

ClassMethod CreateGlobalMapping() As %Status
{
  set sc = $$$OK
  set storage = $get(^||Port.Envs("DATABASE"), $namespace)
  set thisNamespace = $namespace
  new $namespace
  
  set $namespace = "%SYS"
  
  if ##class(Config.MapGlobals).Exists(storage, "Port.*") {
    write "> Global is already mapped. Skipping ...", !
    return $$$OK
  }
  
  try {
    $$$ThrowOnError(##class(Config.Namespaces).Get($namespace, .nsProperties))
    set glProperties("Database") = storage
    $$$ThrowOnError(##class(Config.MapGlobals).Create(thisNamespace, "Port.*", .glProperties))    
  } catch ex {
    set sc = ex.AsStatus()
  }
  set $namespace = thisNamespace
  return sc
}

ClassMethod RemoveGlobalMapping() As %Status
{
  set sc = $$$OK
  set storage = $get(^||Port.Envs("DATABASE"), $namespace)
  set thisNamespace = $namespace    
  new $namespace
  
  set $namespace = "%SYS"  
  
  if ##class(Config.MapGlobals).Exists(storage, "Port.SourceControl*") {
    return ##class(Config.MapGlobals).Delete(storage, "Port.SourceControl*")
  }
  return $$$OK
}

ClassMethod CreateMessageDictionary() As %Status [ CodeMode = objectgenerator ]
{
    
  do %code.WriteLine("  k ^CacheMsg(""Port Errors""),^CacheMsgNames(""Port Errors"")")
  do %code.WriteLine("  k ^CacheMsg(""Port Log Messages""), ^CacheMsgNames(""Port Log Messages"")")
  do %code.WriteLine("  k ^CacheMsg(""Port Menu Labels""), ^CacheMsgNames(""Port Menu Labels"")")
  do %code.WriteLine("  k ^CacheMsg(""Port Context Menu Labels""), ^CacheMsgNames(""Port Context Menu Labels"")")
  
  set XDatas = %compiledclass.XDatas
  
  for i=1:1:XDatas.Count() {
    set XDataId = $$$quote(%compiledclass.Name_"||"_XDatas.GetAt(i).Name)    
    do %code.WriteLine("  set localeXData = ##class(%Dictionary.CompiledXData).%OpenId("_XDataId_").Data")
    do %code.WriteLine("  set tmpFilename = ##class(%File).TempFilename(""xml"")")
    do %code.WriteLine("  set file = ##class(%Stream.FileCharacter).%New()")
    do %code.WriteLine("  set file.TranslateTable = ""UTF8""")
    do %code.WriteLine("  $$$QuitOnError(file.LinkToFile(tmpFilename))")
    do %code.WriteLine("  $$$QuitOnError(file.CopyFrom(localeXData))")
    do %code.WriteLine("  $$$QuitOnError(file.%Save())")
    do %code.WriteLine("  $$$QuitOnError(##class(%MessageDictionary).Import(tmpFilename))")
    do %code.WriteLine("  do ##class(%File).Delete(tmpFilename)")
    do %code.WriteLine("  set (localXData, tmpFilename, file) = """"")    
  }
  do %code.WriteLine("  set io = $io")
  do %code.WriteLine("  open $$$NULL")
  do %code.WriteLine("  use $$$NULL")
  do %code.WriteLine("  set sc = ##class(%MessageDictionary).GenerateInclude(""portmd"",,,""Port Errors,Port Log Messages,Port Menu Labels,Port Context Menu Labels"")")
  do %code.WriteLine("  use io")
  do %code.WriteLine("  close $$$NULL")
  do %code.WriteLine("  quit sc")
}

}


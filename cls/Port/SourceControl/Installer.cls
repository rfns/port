Include portutils

Class Port.SourceControl.Installer Extends %Projection.AbstractProjection
{

XData LocaleEN [ XMLNamespace = "https://github.com/rfns/port" ]
{
<?xml version="1.0" encoding="UTF-8"?>
<MsgFile Language="en">
  <MsgDomain Domain="Port Errors">
    <Message Id="-100" Name="InvalidPhysicalPath">The provided physical path '%1' is not part of the static files directory.</Message>
    <Message Id="-101" Name="NamespaceAppPathDoesnExists">There is not an existing application for the namespace %1.</Message>
    <Message Id="-102" Name="CannotCreateDirectory">Could not create the directory %1.</Message>
    <Message Id="-103" Name="CannotUseRelativePath">Cannot use a relative path, an absolute path must be provided.</Message>
    <Message Id="-104" Name="UnableToCopySource">Could not copy the file from %1 to %2.</Message> 
    <Message Id="-105" Name="UnableToExportInvalidItem">Could not export the item %1 because it does not exist.</Message>
    <Message Id="-106" Name="ErrorsWhileImporting">There were errors while export the project %1.</Message>
    <Message Id="-107" Name="AmbiguousPartialToWorkspace">The obtained partial path %1 is ambiguous to this project path. If you want to export the project itself, then use the 'Import' method.</Message>
    <Message Id="-108" Name="SupressedAttemptToExportFromOutside">Cannot import a file that is outside the project workspace.</Message>    
    <Message Id="-109" Name="UnableToRemoveDirectory">Could not remove the directory %1.</Message>
    <Message Id="-110" Name="UnableToDescribeItem">Could not describe the item %1 due to a violation regarding the expected extension. The exported should %1</Message>
    <Message Id="-111" Name="PortIsNotInstalled">Port is not installed on namespace %1.</Message>
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
    <Message Id="-400" Name="SynchronizingProject">Synchronizing the project %1.</Message>
    <Message Id="-401" Name="CheckingExtraneousItems">Checking for the presence of orphan items in the project.</Message>
    <Message Id="-402" Name="TotalExtraneousItems">Total orphan items detected: %1.</Message>
    <Message Id="-403" Name="NoExtraneousItems">No orphan items were found.</Message>
    <Message Id="-404" Name="RemovingFile">Removing %1 (file).</Message>
    <Message Id="-405" Name="RemovingDirectory">Removing item %1 (directory).</Message>
    <Message Id="-406" Name="TotalExtraneousItemsItemsRemoved">Total of removed orphan items: %1</Message>
    <Message Id="-500" Name="Done"> done.</Message>
    <Message Id="-501" Name="DoneWithErrors"> done, but with errors.</Message>
    <Message Id="-501" Name="Failed"> failed.</Message>
    <Message Id="-502" Name="AllDone">Finished with success.</Message>
    <Message Id="-503" Name="KeepCacheExtension"> keep the original Caché format extension.</Message>
    <Message Id="-504" Name="OvewriteWithExtension"> end with the %1 extension.</Message>
    <Message Id="-600" Name="ImportingType">Importing %1 2% ... </Message>
    <Message Id="-601" Name="EnqueingType">Enqueueing the selected %1 to be imported.</Message>
    <Message Id="-602" Name="NothingToImport">Nothing to import has been found.</Message>
    <Message Id="-603" Name="ImportingProject">Importing the project %1.</Message>
    <Message Id="-604" Name="EnqueueingItems">Enqueing items to be imported.</Message>
    <Message Id="-605" Name="TotalItemsToImport">Total of items to import: %1.</Message>
    <Message Id="-606" Name="NoPendingItemsToImport">No items to import were found.</Message>
    <Message Id="-607" Name="NewProject">The project %1 does not exist yet and will be created.</Message>
    <Message Id="-608" Name="FatalErrorAlert">FATAL: The following errors prevented the project from being imported:</Message>
    <Message Id="-609" Name="FatalRollbackAlert">All changes will be discarded on the next steps.</Message>
    <Message Id="-610" Name="FatalProjectIntegrityRiskWarning">WARNING! DO NOT INTERRUPT THE PROCESS TO AVOID COMPROMISING THE PROJECT INTEGRITY!</Message>
    <Message Id="-611" Name="FatalRollingBackTransaction">Import: Rolling back and discarding the pending transaction.</Message>
    <Message Id="-612" Name="FatalApplyingBackup">Applying the backup to revert the web application back to its initial state.</Message>
    <Message Id="-613" Name="FatalFailedToRestoreBackup">ERROR: Could not apply the backup entirely due to a system error. The backup will be kept to be applied manually.</Message>    
    <Message Id="-700" Name="CannotUseDefault">The usage of 'Default' named projects are restricted to prevent mishandling. If you want use this project, please provide another name by using File->Save As.</Message>
    <Message Id="-701" Name="CannotUseDefault2">All active hooks are now disabled.</Message>    
    <Message Id="-800" Name="ClassType">class</Message>
    <Message Id="-801" Name="ProjecType">project</Message>
    <Message Id="-802" Name="RoutineType">routine</Message>
    <Message Id="-803" Name="FileType">file</Message>
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
</MsgFile>
}

XData LocalePTBR
{
<?xml version="1.0" encoding="UTF-8"?>
<MsgFile Language="pt-br">
  <MsgDomain Domain="Port Errors">
    <Message Id="-100" Name="InvalidPhysicalPath">O caminho físico '%1' fornecido não pertence ao diretório de arquivos estáticos.</Message>
    <Message Id="-101" Name="NamespaceAppPathDoesnExists">Não existe uma aplicação para o namespace %1.</Message>
    <Message Id="-102" Name="CannotCreateDirectory">Não foi possível criar o diretório %1.</Message>
    <Message Id="-103" Name="CannotUseRelativePath">Não é possível utilizar um caminho relativo, o caminho precisa estar completo.</Message> 
    <Message Id="-104" Name="UnableToCopySource">Não foi possível copiar o arquivo de %1 para %2.</Message> 
    <Message Id="-105" Name="UnableToExportInvalidItem">Não foi possível exportar o item %1 pois ele não existe.</Message>
    <Message Id="-106" Name="ErrorsWhileImporting">Houveram erros ao importar %1.</Message>
    <Message Id="-107" Name="AmbiguousPartialToWorkspace">O caminho partial %1 obtido é ambíguo ao caminho deste projeto. Se você deseja exportar o projeto, utilize o método 'Import'.</Message>
    <Message Id="-108" Name="SupressedAttemptToExportFromOutside">Não é possível importar um arquivo que esteja fora do espaço de trabalho deste projeto.</Message>
    <Message Id="-109" Name="UnableToRemoveDirectory">Não foi possível remover o diretório %1.</Message>
    <Message Id="-110" Name="UnableToDescribeItem">Não foi possível descrever o item o %1 devido à uma violação no extensão esperada. O item exportado deve %1.</Message>
    <Message Id="-111" Name="PortIsNotInstalled">Port não está instalado no namespace %1.</Message>
  </MsgDomain>
  <MsgDomain Domain="Port Log Messages">
    <Message Id="-200" Name="BackupStart">Iniciando backup...</Message>
    <Message Id="-201" Name="BackupAlert">NÃO INTERROMPA ESTE PROCESSO.</Message>
    <Message Id="-202" Name="BackupMirror">Espelhando a estrutura da aplicação web para um diretório temporário ... </Message>
    <Message Id="-203" Name="RemovingBackupMirror">Removendo o diretório temporário.</Message>
    <Message Id="-300" Name="NoItemsToExport">Não há itens para serem exportados. A operação foi abortada.</Message>
    <Message Id="-301" Name="ExportingProject">Exportando o projeto %1.</Message>
    <Message Id="-302" Name="SourceExportedToPath">O código-fonte foi exportado para o caminho %1.</Message>
    <Message Id="-303" Name="ExportingType">Exportando %1 %2 ...</Message>
    <Message Id="-400" Name="SynchronizingProject">Sincronizando o projeto %1.</Message>
    <Message Id="-401" Name="CheckingExtraneousItems">Verificando presença de itens órfãos no projeto.</Message>
    <Message Id="-402" Name="TotalExtraneousItems">Total de itens órfãos detectados: %1.</Message>
    <Message Id="-403" Name="NoExtraneousItems">Nenhum item órfão encontrado.</Message>
    <Message Id="-404" Name="RemovingFile">Removendo item %1 (arquivo).</Message>
    <Message Id="-405" Name="RemovingDirectory">Removendo item %1 (diretório).</Message>
    <Message Id="-406" Name="TotalExtraneousItemsItemsRemoved">Total de itens órfãos removidos: %1.</Message>
    <Message Id="-500" Name="Done"> feito.</Message>
    <Message Id="-501" Name="DoneWithErrors"> feito, mas com erros.</Message>
    <Message Id="-501" Name="Failed"> falhou.</Message>
    <Message Id="-502" Name="AllDone">Terminado com sucesso.</Message>
    <Message Id="-503" Name="KeepCacheExtension"> manter a extensão do formato Caché original.</Message>
    <Message Id="-504" Name="OvewriteWithExtension"> terminar com a extensão %1.</Message> 
    <Message Id="-600" Name="ImportingType">Importando %1 2% ... </Message>
    <Message Id="-601" Name="EnqueingType">Enfileirando o %1 escolhido para ser importado.</Message>
    <Message Id="-602" Name="NothingToImport">Nada para importar foi encontrado.</Message>
    <Message Id="-603" Name="ImportingProject">Importando o projeto %1.</Message>
    <Message Id="-604" Name="EnqueueingItems">Enfilerando itens para serem importados.</Message>
    <Message Id="-605" Name="TotalItemsToImport">Total de itens para importar: %1.</Message>
    <Message Id="-606" Name="NoPendingItemsToImport">Não há itens para serem importados.</Message>
    <Message Id="-607" Name="NewProject">O projeto %1 ainda não existe e será criado a seguir.</Message>
    <Message Id="-608" Name="FatalErrorAlert">FATAL: O seguintes erros impediram o projeto %1 de ser importado:</Message>
    <Message Id="-609" Name="FatalRollbackAlert">As alterações serão desfeitas nas etapas a seguir.</Message>
    <Message Id="-610" Name="FatalProjectIntegrityRiskWarning">AVISO! NÃO INTERROMPA O PROCESSO PARA NÃO COMPROMETER A INTEGRIDADE DO PROJETO!</Message>
    <Message Id="-611" Name="FatalRollingBackTransaction">Revertendo e desfazendo transação em aberto.</Message>
    <Message Id="-612" Name="FatalApplyingBackup">Aplicando o backup para reverter alterações no caminho da aplicação.</Message>
    <Message Id="-613" Name="FatalFailedToRestoreBackup">ERRO: Não foi possível aplicar o backup inteiramente devido a um erro de sistema. O backup será mantido para uma correção manual.</Message>
    <Message Id="-700" Name="CannotUseDefault">O uso de projetos cujo o nome contenha 'Default' está restrito para prevenir o uso inadequado desta ferramenta. Se você deseja usar este projeto, por favor forneça um outro nome utilizando Arquivo->Salvar Como.</Message>
    <Message Id="-701" Name="CannotUseDefault2">Todos os eventos foram desativados.</Message>
    <Message Id="-800" Name="ClassType">classe</Message>
    <Message Id="-801" Name="ProjectType">projeto</Message>
    <Message Id="-802" Name="RoutineType">rotina</Message>
    <Message Id="-803" Name="FileType">arquivo</Message>
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
    <Message Id="-5010" Name="MLForceExport">Importar (forçado)</Message>
  </MsgDomain>
  <MsgDomain Domain="Port Context Menu Labels">
    <Message Id="-6000" Name="CMLExportActive">Exportar a partir deste item</Message>
    <Message Id="-6001" Name="CMLImportActive">Importar a partir deste item</Message>
    <Message Id="-6002" Name="CMLRunActiveTest">Executar teste</Message>
  </MsgDomain>
</MsgFile>
}

ClassMethod CreateProjection() As %Status
{
  quit ..Install()
}

ClassMethod RemoveProjection() As %Status
{
  quit ..Uninstall()
}

ClassMethod Uninstall() As %Status
{
  if '$data(^Port.SourceControl.Settings("installed")) {
    quit $$$PERROR($$$PortIsNotInstalled, $namespace)
  }
  
  write "Removing Port, please wait ...", !
  set sc = $$$OK
  do ##class(Config).Uninstall()
  do ##class(Log).Flush()
  set sc = $$$ADDSC(sc, ##class(%Studio.SourceControl.Interface).SourceControlClassSet($get(^Port.SourceControl.Settings("old")), $namespace))
  set sc = $$$ADDSC(sc, ##class(LogCleaner).RemoveTask())
  set sc = $$$ADDSC(sc, ..RemoveGlobalMapping())  
  if $$$ISOK(sc) write $$$FormatText("Port has been removed from %1.", $namespace), !
  else  write "One or more errors ocurred while removing Port:", !!, $System.Status.GetErrorText(sc)
  quit $$$OK
}

ClassMethod Install(force As %Boolean = 0) As %Status
{
  set sc = $$$OK
  
  if 'force {
    if $data(^Port.SourceControl.Settings("installed")) {
      write "Port is already installed. The installer has been aborted.", !
      write "If you wish to change current settings then please use the wizard.", !!
      write "do Wizard^Port", !
      quit $$$ERROR($$$GeneralError, "Port is already installed.")
    }
  }
  
  try {
    write !, "Installing Port ... please wait a moment.", !
    write "> Creating Message Dictionary ...", !
    $$$ThrowOnError(..CreateMessageDictionary())
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
    write "> Registering log cleaner task for "_$namespace_" ...", !
    $$$ThrowOnError(##class(LogCleaner).StartTask())
    write "> Activating source control class ...", !!
    set ^Port.SourceControl.Settings("old.sourcecontrol") = ##class(%Studio.SourceControl.Interface).SourceControlClassGet($namespace)
    $$$ThrowOnError(##class(%Studio.SourceControl.Interface).SourceControlClassSet("Port.SourceControl.Hooks", $namespace))
    write "ALL DONE.", !
    write "NOTE: Please note that you must restart Studio in order to make the new settings have effect."
    set ^Port.SourceControl.Settings("installed") = 1
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

ClassMethod RemoveGlobalMapping() As %Status
{
  set sc = $$$OK
  set thisNamespace = $namespace     
  new $namespace
  
  set $namespace = "%SYS"  
  
  if ##class(Config.MapGlobals).Exists(thisNamespace, "Port.SourceControl*") {
    quit ##class(Config.MapGlobals).Delete(thisNamespace, "Port.SourceControl*")
  }
  quit $$$OK
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
    do %code.WriteLine("  set localeXData = ##class(%Dictionary.CompiledClass).%OpenId("_XDataId_")")
    do %code.WriteLine("  set tmpFilename = ##class(%File).TempFilename()")
    do %code.WriteLine("  set file = ##class(%File).%New(tmpFilename)")
    do %code.WriteLine("  do file.Open(""WNS"")")
    do %code.WriteLine("  $$$QuitOnError(file.CopyFrom(localeXData))")
    do %code.WriteLine("  $$$QuitOnError(file.%Save())")
    do %code.WriteLine("  $$$QuitOnError(##class(%MessageDictionary).Import(tmpFilename))")
    do %code.WriteLine("  do ##class(%File).Delete(tmpFilename)")
    do %code.WriteLine("  set (localXData, tmpFilename, file) = """"")    
  }
  do %code.WriteLine("  $$$QuitOnError(##class(%MessageDictionary).GenerateInclude(""portmd"",,,""Port Errors,Port Log Messages,Port Menu Labels,Port Context Menu Labels""))")
  do %code.WriteLine("  quit $$$OK")
}

}


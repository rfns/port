Class Port.Project.XMLExporter Extends Port.Project.Base
{

Method ExportToXML(justProject As %Boolean = 0, qspec As %String = "/diffexport=1/nodisplay", charset As %String = "UTF8", Output errorlog As %Status = "") As %Status
{
  set developmentXML = ##class(%File).NormalizeFilename(..BasePath_"/"_..Project.Name_".xml")
  set productionXML = ##class(%File).NormalizeFilename(..BasePath_"/"_..Project.Name_"-prod.xml")
  write ..LogLine($$$ExportingXML, 0, ..Project.Name)
  $$$QuitOnError(..Project.Export(developmentXML, qspec, justProject, errorlog, charset))
  write ..LogLine($$$XMLExportedTo, 0, ..Project.Name, developmentXML)  
  
  do SanitizePackages(.items)  
  
  if $order(items("")) '= "" {  
    $$$QuitOnError($System.OBJ.Export(.items, productionXML, qspec, errorlog, charset))
    write ..LogLine($$$XMLExportedTo, 0, ..Project.Name, productionXML)
  }
    
  quit $$$OK    
  
SanitizePackages(items="")
  set sc = $$$OK 
  set testPrefix = ##class(Port.Configuration).GetTestClassPrefix()
  
  set s = ##class(%SQL.Statement).%New()
  do s.%PrepareClassQuery("%Studio.Project", "ProjectItemsList")
  
  set r = s.%Execute(..Project.Name)
  while r.%Next() {
    set itemName = r.%Get("Name")
    set itemType = r.%Get("Type")
    if itemType '= "CLS" || (itemType = "CLS" && '($extract(itemName, 1, $length(testPrefix)) = testPrefix)) {
      set name = itemName
      set type = itemType
      do ##class(%Studio.Project).NormalizeName(.name, .type)             
      if type = "CLS" || (type = "PKG") set name = name_"."_type
      set items(name) = ""
    }    
  }
  quit
}

Method ExportTests(qspec As %String = "/diffexport=1/nodisplay", ByRef tests As %String = "", ByRef errors = "") As %Status
{
  set sc = $$$OK
  set exported = 0
  
  // We don't actually export any XML if UDL is enabled.
  set isUsingUDL = (##class(Port.Configuration).GetTestFormat() = "UDL")   
  if isUsingUDL return $$$OK  
  
  set s = ##class(%SQL.Statement).%New()
  $$$QuitOnError(s.%PrepareClassQuery("%Studio.Project", "ProjectItemsList"))
  set r = s.%Execute(..Project.Name)
  while r.%Next(.sc) {
    if $$$ISERR(sc) quit
    set type = r.%Get("Type")
    if type = "CLS" {     
      set class = r.%Get("Name")      
      if 'exported set exported = ..ExportTest(class, .esc, qspec)
      else  do ..ExportTest(class, .esc)          
      set sc = $$$ADDSC(sc, esc)
    }
  } 
  if 'exported {
    set sc = $$$PERROR($$$NoTestSuitesWereFound)
  }
  quit sc
}

Method ExportTest(className As %String, sc As %Status = {$$$OK}, qspec = "/diffexport=1/nodisplay") As %Boolean
{
  set sc = $$$OK
  set exported  = 0
  
  if '##class(Port.UnitTest.Util).IsUnitTestClass(className) quit exported  
  
  set classPath = ##class(Port.UnitTest.Util).GetTestClassPath(className, ..BasePath)
  
  if classPath '= "" {
    write ..Log($$$ExportingTestClassToXML, 0, $replace(className, ".CLS", ""))
    set cSC = $System.OBJ.Export(className_".CLS", classPath,qspec)
    set sc = $$$ADDSC(sc, cSC)
    if $$$ISOK(cSC) write ..LogLine($$$Done, 0)
    else  write ..LogLine($$$Failed, 0)
    set exported = 1
  }
  quit exported
}

}


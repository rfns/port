Class Port.Project.XMLExporter Extends Port.Project.Base
{

Method ExportToXML(justProject As %Boolean = 0, qspec As %String = "/diffexport=1/nodisplay", charset As %String = "UTF8", Output errorlog As %Status = "") As %Status
{
  set destination = ##class(%File).NormalizeFilename(..BasePath_"/"_..ProjectName_".xml")
  write ..LogLine($$$ExportingXML, 0, ..ProjectName)
  $$$QuitOnError(..Project.Export(destination, qspec, justProject, errorlog, charset))
  write ..LogLine($$$XMLExportedTo, 0, ..ProjectName, destination)
  quit $$$OK
}

Method ExportTests(path As %String, qspec As %String = "/diffexport=1/nodisplay", ByRef tests As %String = "", ByRef errors = "") As %Status
{
    
  set sc = $$$OK
  set exported = 0
  
  set absoluteBasePath = ##class(%File).NormalizeFilename(path)
  $$$QuitOnError(##class(Port.Project.Helper).ImplyDirectoryCreation(absoluteBasePath))
  
  set s = ##class(%SQL.Statement).%New()
  $$$QuitOnError(s.%PrepareClassQuery("%Studio.Project", "ProjectItemsList"))
  set r = s.%Execute(..Project.Name)
  while r.%Next(.sc) {
    if $$$ISERR(sc) quit
    set type = r.%Get("Type")
    if type = "CLS" {     
      set class = r.%Get("Name")      
      if 'exported set exported = ..ExportTest(absoluteBasePath, class, .esc, qspec)
      else  do ..ExportTest(absoluteBasePath, class, .esc)          
      set sc = $$$ADDSC(sc, esc)
    }
  } 
  if 'exported {
    set sc = $$$PERROR($$$NoTestSuitesWereFound)
  }
  quit sc
}

Method ExportTest(absoluteBasePath As %String, className As %String, sc As %Status = {$$$OK}, qspec = "/diffexport=1/nodisplay") As %Boolean
{
  set sc = $$$OK
  set exported  = 0
  
  if '##class(Port.UnitTest.Util).IsUnitTestClass(className) quit exported  
  
  set test = ##class(Port.UnitTest.Util).ResolveTestLocation(absoluteBasePath, className)
  
  if $listvalid(test) && (test '= "") {
    set className = $listget(test, 1)
    set classPath = $listget(test, 2)
    write ..Log($$$ExportingTestClassToXML, 0, $replace(className, ".CLS", ""))
    set cSC = $System.OBJ.Export(className, classPath,qspec,, "UTF-8")
    set sc = $$$ADDSC(sc, cSC)
    if $$$ISOK(cSC) write ..LogLine($$$Done, 0)
    else  write ..LogLine($$$Failed, 0)
    set exported = 1
  }
  quit exported
}

}


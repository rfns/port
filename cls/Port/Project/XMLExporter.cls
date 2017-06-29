Class Port.Project.XMLExporter Extends Port.Project.Base
{

Parameter MODULENAME = "PortXMLExportUtility";

Method ExportToXML(justProject As %Boolean = 0, qspec As %String = "/diffexport=1/nodisplay", charset As %String = "UTF8", Output errorlog As %Status = "") As %Status
{
  set destination = ##class(%File).NormalizeFilename(..BasePath_"/"_..ProjectName_".xml")
  do ..Write("[nl]Exporting project {P1} to XML ...", 0, ..GetProjectName())
  $$$QuitOnError(..Project.Export(destination, qspec, justProject, errorlog, charset))
  do ..Write("[nl]Project exported to {P1}[nl]", 0, destination)
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
    set sc = $$$ERROR(5001, "No test suites were found for this project.")
  }
  quit sc
}

Method ExportTest(absoluteBasePath As %String, className As %String, sc As %Status = {$$$OK}, qspec = "/diffexport=1/nodisplay") As %Boolean
{
  set sc = $$$OK
  set exported  = 0
  
  if '..IsUnitTestClass(className) quit exported  
  
  set test = ..ResolveTestLocation(absoluteBasePath, className)
  
  if $listvalid(test) && (test '= "") {
    set className = $listget(test, 1)
    set classPath = $listget(test, 2)
    do ..Logger.Log("Exporting test class {P1} ... ", 0, $replace(className, ".CLS", ""))
    set sc = $$$ADDSC(sc, $System.OBJ.Export(className, classPath,qspec,, "UTF-8"))
    do ..Logger.Log("done.[nl]", 0)
    set exported = 1
  }
  quit exported
}

Method ResolveTestLocation(absoluteBasePath As %String, className As %String) As %Status [ Final, Internal ]
{
  set test = $listbuild(className_".CLS", ##class(Port.Project.Helper).ClassToFile(absoluteBasePath, className, "xml"))
  quit test
}

ClassMethod IsUnitTestClass(className As %String) As %Boolean
{
  
  set isUnitTest = 0
  set descriptor = ##class(%Dictionary.CompiledClass).%OpenId(className)
  if '$isobject(descriptor) || ($isobject(descriptor) && (descriptor.Super = "")) quit 0
  
  if descriptor.Super [ "Port.UnitTest.TestCase" quit 1  
  
  // If the target class have some super class defined, we must consider that it could be
  // extending from multiple super classes. So we need to check each of them.
  for i=1:1:$length(descriptor.Super, ",") {
    set extension = $piece(descriptor.Super, ",", i)
    if ..IsUnitTestClass(extension) {
      set isUnitTest = 1
      quit
    }   
  }
  quit isUnitTest
}

}


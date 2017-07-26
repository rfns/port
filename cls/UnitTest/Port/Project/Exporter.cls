Class UnitTest.Port.Project.Exporter Extends (Port.UnitTest.TestCase, UnitTest.Port.Helper)
{

Property Exporter As Port.Project.Exporter;

Property ConfiguredExtension As %String;

Method OnBeforeAllTests() As %Status
{
  set ..ConfiguredExtension = ##class(Port.Configuration).GetSourceExtension()
  do ##class(Port.Configuration).SetSourceExtension("")
  return $$$OK
}

Method OnAfterAllTests() As %Status
{
  do ##class(Port.Configuration).SetSourceExtension(..ConfiguredExtension)
  return $$$OK
}

Method OnBeforeOneTest() As %Status
{
     
  $$$QuitOnError(..CloneTestProject(..GetTestDirectory("../fixtures"), "dummy-project", 1))
  set ..Exporter = ##class(Port.Project.Exporter).%New(..GetTestDirectory("../fixtures/_/dummy-project"))
  // Turn off logger notification to prevent breaking test feedbacks.
  set ..Exporter.Logger.Silent = 1
  return $$$OK
}

Method OnAfterOneTest() As %Status
{
  $$$QuitOnError(..DeleteTestProject(..GetTestDirectory("../fixtures"), "dummy-project"))
  set ..Exporter = ""
  return $$$OK
}

Method TestOnNew()
{
  set exporter = ""
  
  try {
    set exporter = ##class(Port.Project.Exporter).%New("/this/does/not/exist")
  } catch ex {
    do $$$AssertStatusNotOK(ex.AsStatus(), "does not accept inexistent projects")
  }
}

Method TestExportItem(ovewrite As %Boolean = 0)
{
  #define ItemPath(%itemName) ##class(Port.Util).GetItemSourcePathFromWorkspace(%itemName, "dummy-project")  
  
  set sc = $$$OK
  set items = ..GetTestProjectItemsPath("dummy-project", ..GetTestDirectory("../fixtures/_/dummy-project"))
  set itemName = ""
  
  do ##class(Port.Util).CSPPhysicalToLogicalPath(..GetTestDirectory("../fixtures/_/dummy-project/web/dummy.html"), .missingFile)
  
  for missingItem = "I.Dont.Exist.CLS", "idontexist.mac", "idontexist.inc", "idontexist.dfi", missingFile {
    do items.SetAt(##class(Port.Util).GetItemSourcePathFromWorkspace(missingItem, "dummy-project"), missingItem)
  }
  
  for i=1:1:items.Count() {
    set itemName = items.Next(itemName)
    set itemLocation = items.GetAt(itemName)
    set sc = ..Exporter.ExportItem(itemName)
    if ##class(Port.Util).ExistsInProject("dummy-project", itemName) {
      if $$$ISERR(sc) quit
      set isSameFile = ##class(%File).Compare($$$ItemPath(itemName), ##class(Port.Util).MountItemSourcePath(itemName, ..GetTestDirectory("../fixtures/dummy-project")))
      if 'isSameFile {
        break
        set sc = $$$ERROR($$$GeneralError, $$$FormatText("files for %1 don't match", itemName))
        quit
      }
    }
  }
  //do $$$AssertStatusOK(sc, "exports items individually")
}

Method TestExport()
{
  #define ItemPath(%itemName) ##class(Port.Util).GetItemSourcePathFromWorkspace(%itemName, "dummy-project")
  
  set items = ..GetTestProjectItemsPath("dummy-project", ..GetTestDirectory("../fixtures/_/dummy-project"))
  set itemName = ""
  set sc = $$$OK
  
  set ..Exporter.Overwrite = 1
  set sc = ..Exporter.Export()
  
  if $$$ISOK(sc) {
    for i=1:1:items.Count() {
      set itemName = items.Next(itemName)
      set itemLocation = items.GetAt(itemName)    
      if ##class(Port.Util).ExistsInProject("dummy-project", itemName) {
        if '##class(%File).Exists(itemLocation) {
          set sc = $$$ERROR($$$GeneralError, $$$FormatText("file not generated for item %1", itemName))
          quit        
        }
      }       
    }
  }
  do $$$AssertStatusOK(sc, "exports all project files")
  quit
}

}


Class UnitTest.Port.Project.Exporter Extends Port.UnitTest.TestCase
{

Property Exporter As Port.Project.Exporter;

Property BasePath As %String [ InitialExpression = "/CacheProjects/DEV/port" ];

Property Project As %Studio.Project;

Method OnBeforeAllTests() As %Status
{
  if '$data(^||%Studio.Project) set ^||%Studio.Project = "port"
  set ..Project = ##class(Port.TestUtils.MockProject).%New(..GetTestDirectory("fixtures"), 1,1)
  quit $$$OK
}

Method OnAfterAllTests() As %Status
{
  do ..Project.Delete()
  quit $$$OK
}

Method OnBeforeOneTest() As %Status
{
  set ..Exporter = ##class(Port.Project.Exporter).%New(..BasePath)
  quit $$$OK
}

Method TestExport()
{
   
  set fauxItems = 12
  set fauxItems(1)  = "Faux.Class.cls"
  set fauxItems(2)  = "fauxjs.js"
  set fauxItems(3)  = "fauxcss.css"
  set fauxItems(4)  = "fauxinc.inc"
  set fauxItems(5)  = "fauxmac.mac"
  set fauxItems(6)  = "fauxint.int"
  set fauxItems(7)  = "fauxmvi.mvi"
  set fauxItems(8)  = "fauxmvb.mvb"
  set fauxItems(9)  = "fauxbas.bas"
  set fauxItems(10) = "fauxdfi.dfi"
  set fauxItems(11) = "fauxcsp.csp"
  set fauxItems(12) = "fauxcsr.csr"
  set fauxItems(13) = "fauxhtml.html"
  
  set types = $lfs("cls,int,mac,inc,web,bas,mvb,mvi")
  do $$$AssertStatusOK(..Exporter.Export(), "Should call Export() without issues.") 
  
  set itemsCount = ..Project.Items.Count()
  for i=1:1:itemsCount {  
    set item = ..Project.Items.GetAt(i)
    if item.Type '= "CLS" {         
      set filePath = ..BasePath_"/"_$zcvt($select(item.Name [ ".INC" :$piece(item.Name, ".", 2), 1:item.Type), "L")_"/"_$piece(item.Name, ".")_"."_$zcvt($piece(item.Name, ".", 2), "L")
    } else {
      set filePath = $replace(..BasePath_"/cls/"_item.Name, ".", "/")_".cls"
    }
    if item.Type '= "CSP" set filePath = filePath_".txt"
    set filePath = ##class(%File).NormalizeFilename(filePath)
    do $$$AssertEquals(##class(%File).Exists(filePath), 1, filePath_" should exist")
  }
}

}


Class UnitTest.Port.Project.Base Extends (Port.UnitTest.TestCase, Port.TestUtils.MockProject)
{

Parameter MOCKNAME = "TestProject";

Property BaseInstance As Port.Project.Base;

Method OnBeforeOneTest() As %Status
{
  set ..BaseInstance = ##class(Port.Project.Base).%New("/CacheProjects/"_$namespace_"/"_..#MOCKNAME)
  quit $$$OK
}

Method OnBeforeAllTests() As %Status
{
  $$$QuitOnError(..Create())
  quit $$$OK
}

Method OnAfterAllTests() As %Status
{
  $$$QuitOnError(..Delete())
  do ##class(%File).RemoveDirectoryTree("/CacheProjects/"_$namespace_"/"_..#MOCKNAME)
  quit $$$OK
}

Method TestPropertyDefinition()
{
  
  #define CheckProperty(%propName)  ##class(%Dictionary.PropertyDefinition).%ExistsId("Port.Project.Base||"_%propName)
  
  for prop="Logger","ProjectName","Project","Slash","BasePath","IncPath","ClassPath","IntPath","MacPath","WebPath","MvbPath","MviPath","BasPath","DfiPath","AffectedCount","IsBatch","Overwrite","LogLevel" {
    do $$$AssertEquals($$$CheckProperty(prop), 1, "Property "_prop_" should exist.")
  }
}

Method TestGetProjectName()
{
  do $$$AssertEquals(..BaseInstance.GetProjectName(), ..#MOCKNAME, "Should return the project name")
}

Method TestIsOutdated()
{
  
 set fauxPath = "/CacheProjects/"_$namespace_"/faux"
 set faux = ##class(%Studio.Project).%New("faux")
 do faux.%Save()
 
 set base = ##class(Port.Project.Base).%New(fauxPath)
 set routine = ##class(%Routine).%New("sayhey.mac")
 
 do Execute(1)
 do Execute(0)

Execute(expected)
  if expected = 1 {
    do CreateFile
    do $$$LogMessage("Creating a 2 seconds gap ...")
    hang 2
    do CreateRoutine
  } else {
    do CreateRoutine
    do $$$LogMessage("Creating a 2 seconds gap ...")
    hang 2
    do CreateFile
  }  
  do $$$AssertEquals(base.IsOutdated("sayhey.mac", fauxPath_"/mac/sayhey.mac.txt", 0), expected, "Should be "_$case(expected, 1: "outdated", :"up-to-date.")_".")
  do ##class(%File).RemoveDirectoryTree(fauxPath)
  do ##class(%Routine).Delete("sayhey.mac")
  quit
  
CreateRoutine
  do routine.Clear()  
  do routine.WriteLine("test")
  do routine.WriteLine($char(9)_"write ""hey!""")
  do routine.WriteLine($char(9)_"quit")
  do routine.%Save()
  
  do faux.AddItem("sayhey.mac")
  do faux.%Save()
  quit
  
CreateFile
  do ##class(%File).CreateDirectoryChain(fauxPath_"/mac")
  set fs = ##class(%FileCharacterStream).%New()
  set fs.Filename = fauxPath_"/mac/sayhey.mac.txt"
  do fs.CopyFrom(routine)
  do fs.%Save()
  quit
}

ClassMethod test()
{
   set ^||%Studio.Project = "port"
   set projectPath = ##class(Port.SourceControl.Config).GetExportPath()
   set shouldOverwrite = '##class(Port.SourceControl.Config).IsSameSourceExtension()
   if shouldOverwrite do ##class(Port.SourceControl.Config).TrackActiveExtension()
   set ignoredPaths = ##class(Port.SourceControl.Util).GetIgnoredPaths(projectPath)     
   set sc = ##class(Port.Project.Manager).Export(projectPath, 2, 0, ignoredPaths, "txt")
   quit $$$OK
}

}


Class Port.UnitTest.Manager Extends %UnitTest.Manager
{

ClassMethod Root() As %String
{
  // This provides us the capability to search for tests unrelated to ^UnitTestRoot.
  return ##class(%File).NormalizeFilename(##class(Port.Configuration).GetWorkspace())
}

ClassMethod RunTestsFromWorkspace(projectName As %String, targetClass As %String = "", targetMethod As %String = "", targetSpec As %String = "") As %Status
{
    
  set recursive = "recursive"
  set activeProject = $get(^||Port.Project)
  set ^||Port.Project = projectName
  
  if targetClass '= "" set target = ##class(Port.UnitTest.Util).GetClassTestSpec(targetClass)
  else  set target = ##class(Port.Configuration).GetTestPath()
  
  if targetMethod '= "" {
    set target = target_":"_targetMethod
    set recursive = "norecursive"
  }
  
  set sc = ..RunTest(target, "/"_recursive_"/run/noload/nodelete/"_targetSpec)
  set ^||Port.Project = activeProject
  return sc
}

}


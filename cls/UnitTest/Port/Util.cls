Class UnitTest.Port.Util Extends (Port.UnitTest.TestCase, UnitTest.Port.Helper)
{

Method TestResolveItemExtension()
{
  set projectName = "mock"
  do ..MockItems(projectName, .entries)
  set $list(entries, $ll(entries) + 1) = "mock.PRJ"
  set expectations = $lb("PKG", "CLS", "CLS", "PKG", "PKG", "INC", "MAC", "DFI", "BAS", "MVB", "MVI", "CSP", "HTML", "HTML", "JS", "HTML", "ONLYEXTENSION", "PRJ")
  for i=1:1:$ll(expectations) {
    set expectation = $lg(expectations, i)
    set entry = $lg(entries, i)
    do $$$AssertEquals(expectation, ##class(Port.Util).ResolveItemExtension(entry), $$$FormatText("resolves %1 -> %2", entry, expectation))
  }
}

Method TestGetItemSourcePathFromWorkspace()
{
  
  set projectName = "mock"  
  
  do ##class(Port.Configuration).SetPrimaryWorkspace("/CacheProjects/{NAMESPACE}/{PROJECT}")  
    
  do ..MockItems(projectName, .entries, .expectations)  
  
  for i=1:1:$ll(entries) {
    set entry = $lg(entries, i)
    set expectation = $lg(expectations, i)
    set result = ##class(Port.Util).GetItemSourcePathFromWorkspace(entry, projectName)    
    do $$$AssertEquals(expectation, ##class(Port.Util).GetItemSourcePathFromWorkspace(entry, projectName), $$$FormatText("resolves %1 -> %2", entry, expectation))
  }
}

Method TestExtractType()
{
  set projectName = "mock"  
  do ..MockItems(projectName, "", .entries)
  set expectations = $lb("CLS", "CLS", "CLS", "CLS", "CLS", "INC", "MAC", "DFI", "BAS", "MVB", "MVI", "WEB", "WEB", "WEB", "WEB", "WEB", "WEB")
  for i=1:1:$listlength(expectations) {
    set entry = $listget(entries, i)
    set expectation = $listget(expectations, i)
    set result = ##class(Port.Util).ExtractType(entry, ##class(Port.Configuration).GetWorkspace(projectName))
    do $$$AssertEquals(expectation, ##class(Port.Util).ExtractType(entry, ##class(Port.Configuration).GetWorkspace(projectName)), $$$FormatText("extracts %1 -> %2", entry, expectation))
  }
}

Method TestMountIdFromName()
{
  set projectName = "mock"
  set macs = $lb("BAS", "INT", "INC", "MVI", "MAC")
  
  do ..MockItems(projectName, .entries)
  
  for i=1:1:$listlength(entries) {
    set entry = $listget(entries, i)
    set entry = $replace(entry, "/", "", 1, 1)
    set expectation = entry
    set extension = ##class(Port.Util).ResolveItemExtension(entry)
    
    if extension = "PKG" {
      // Even though it's not need since ResolveItemExtension always defaults to PKG if no extension is found,
      // We'll still enforce it because the idea is to test a behavior similar to AddItem/RemoveItem, which requires an extension.      
      if entry '[ ".PKG" set entry = entry_".PKG"
      set expectation = $replace(entry, ".PKG", "")_"||PKG"
    } elseif $lf(macs, extension) {
      set expectation = entry_"||MAC"
    } elseif ##class(Port.Util).IsRoutine(entry) {
      set expectation = entry_"||"_extension
    } elseif extension = "CLS" { 
      set expectation = $piece(entry, ".", 1, *-1)_"||"_extension
    }else {
      set expectation = entry_"||CSP"
    }
    set expectation = projectName_"||"_expectation
    do $$$AssertEquals(expectation, ##class(Port.Util).MountIdFromName(entry, projectName), $$$FormatText("mounts id %1 -> %2", entry, expectation))
  }
}

Method TestCSPLogicalToPhysicalPath()
{
  #define CSPLogicalToPhysicalPath(%CSPItem, %path) set sc = ##class(Port.Util).CSPLogicalToPhysicalPath(%CSPItem, %path)
  #define Normalize(%path) ##class(%File).NormalizeFilename(%path)
  
  set sc = $$$OK
  set expectedPath = $$$Normalize($System.Util.InstallDirectory()_"csp/"_$$$lcase($namespace)_"/dummyfile.js")
  
  do $$$LogMessage("Creating mock application ...")
  
  set sc = ..CreateMockApplication()  
  
  if $$$ISERR(sc) {
    do $$$LogMessage("Unable to create mock application. Aborting current test ...")
    do $$$LogMessage("Reason: "_$System.Status.GetErrorText(sc))
    do $$$AssertStatusOK(sc, "should have created the mock app.")
    quit
  } else {
    do $$$LogMessage("Mock application created with success.")
  }
  
  $$$CSPLogicalToPhysicalPath("unittest/mockapp/dummyfile.js", .resolvedPath)
  do $$$LogMessage("Resulting physical path is: "_resolvedPath)
  
  do $$$AssertEquals(resolvedPath, expectedPath, "resolves dummyfile.js's physical path.")
  
  set expectedPath = $$$Normalize($System.Util.InstallDirectory()_"csp/"_$$$lcase($namespace)_"/subpath/dummyfile.js")
  
  $$$CSPLogicalToPhysicalPath("unittest/mockapp/subpath/dummyfile.js", .resolvedPath)
  do $$$LogMessage("Resulting physical path is: "_resolvedPath)
  
  do $$$AssertEquals(resolvedPath, expectedPath, "resolves subpath/dummyfile.js's physical path.")
  
  set sc = ..DestroyMockApplication()
  
  if $$$ISERR(sc) {
    do $$$LogMessage("Unable to destroy mock application.")
    do $$$LogMessage("Reason: "_$System.Status.GetErrorText(sc))
    do $$$AssertStatusOK(sc, "destroys the mock app.")
  } else {
    do $$$LogMessage("Mock application destroyed with success.")
  }
  
  $$$CSPLogicalToPhysicalPath("unittest/mockapp/dummyfile.js", .absolutePath)
  do $$$AssertStatusNotOK(sc, "returns a status code indicating that the current namespace doesn't have an application.")
}

Method TestCSPPhysicalToLogicalPath()
{
  set input = ##class(%File).NormalizeFilename("/foo/web/bar/dummy.txt")
  set expectedResult = $e($System.CSP.GetDefaultApp($namespace)_"/bar/dummy.txt", 2, *)
  
  set sc = ##class(Port.Util).CSPPhysicalToLogicalPath(input, .logicalPath)
  do $$$AssertStatusOK(sc, "returns the logical path without errors.")
    
  do $$$AssertEquals(logicalPath, expectedResult, "resolves the path to logical.")
  
  set sc = ##class(Port.Util).CSPPhysicalToLogicalPath(input, .logicalPath, "dummyns")  
  do $$$AssertStatusNotOK(sc, "returns an error when called with an invalid namespace.")
}

Method TestIsRoutine()
{
  #define IsRoutine(%dummyRoutine) ##class(Port.Util).IsRoutine(%dummyRoutine)
  
  do $$$AssertTrue($$$IsRoutine("dummy.inc"), "expects inc to be a routine.")
  do $$$AssertTrue($$$IsRoutine("dummy.int"), "expects int to be a routine.")
  do $$$AssertTrue($$$IsRoutine("dummy.mac"), "expects mac to be a routine.")
  do $$$AssertTrue($$$IsRoutine("dummy.mvb"), "expects mvb to be a routine.")
  do $$$AssertTrue($$$IsRoutine("dummy.bas"), "expects bas to be a routine.")
  
  do $$$AssertNotTrue($$$IsRoutine("dummy.txt"), "expects txt to not be a routine.")
  do $$$AssertNotTrue($$$IsRoutine("dummy.csp"), "expects csp to not be a routine.")
  do $$$AssertNotTrue($$$IsRoutine("dummy.cls"), "expects cls to not be a routine.")
}

Method TestClassToFile() As %Status
{
  
  for i="txt","whatever","composed.txt","" {
    set assertionSufix = $select(i="" : "nothing", 1: i)_"."
    do ..AssertTestClassToFile(i, assertionSufix)
  }
}

Method TestFileToClass() As %Status
{
  
  for i=".txt",".whatever",".composed.txt","" {
    set assertionSufix = $select(i="" : "nothing", 1: i)
    do ..AssertTestFileToClass(i, assertionSufix)
  }
}

Method TestExistsInProject()
{
  do $$$AssertEquals(##class(Port.Util).ExistsInProject("port", "Port.Util.CLS"), 1, "true if class exists")
  do $$$AssertEquals(##class(Port.Util).ExistsInProject("port", "%Library.RegisteredObject.CLS"), 0, "false if class does not exist")
  
  do $$$AssertEquals(##class(Port.Util).ExistsInProject("port", "portmd.INC"), 1, "true if include exists")
  do $$$AssertEquals(##class(Port.Util).ExistsInProject("port", "whatever.INC"), 0, "false if include does not exist")
}

Method TestListConflicts()
{
     
  do ..CreateDummyProject()
  
  do $$$AssertEquals($lb("dummy-project"), ##class(Port.Util).ListConflicts("port", "Port.SourceControl.AutoInstall.CLS"), "returns a list that contains 'dummy-project'")
  do $$$LogMessage("Removing the added item ...")
  
  do ..RemoveDummyProjectItem()
  
  do $$$AssertEquals("", ##class(Port.Util).ListConflicts("port", "Port.SourceControl.AutoInstall.CLS"), "returns an empty list")
  
  set project = ""
  do ##class(%Studio.Project).Delete("dummy-project")
}

Method TestCreateMissingPath()
{
  do $$$AssertStatusOK(##class(Port.Util).CreateMissingPath(..GetTestDirectory("../temp")), "creates a directory")
  do $$$AssertStatusOK(##class(Port.Util).CreateMissingPath(..GetTestDirectory("../temp")), "tries to create the same directory, nothing should happen.")
  
  do $$$AssertStatusNotOK(##class(Port.Util).CreateMissingPath(..GetTestDirectory("../temp/(*347dhdsk::)$¨¨#")), "returns an error when the path is invalid.")
  
  do ##class(%File).RemoveDirectory(..GetTestDirectory("../temp"))
}

Method AssertTestClassToFile(extension As %String = "", assertionSuffix As %String)
{
  set basePath = "/CacheProjects/MOCKNS/mockproject/cls"
  set input = "MockApp.Package.Test"
  set expected = ##class(%File).NormalizeFilename(basePath_"/MockApp/Package/Test.cls."_extension)
  
  set result = ##class(Port.Util).ClassToFile(basePath, input, extension)
  //do $$$AssertEquals(result, expected, "resolves correctly the class when the extension is "_assertionSuffix_".")
}

Method AssertTestFileToClass(extension As %String = "", assertionSuffix As %String)
{
  set input = "/CacheProjects/"_$namespace_"/MockProject/cls/MockApp/Package/Test.cls"_extension
  set expectedOutput = "MockApp.Package.Test"
  set result = ##class(Port.Util).FileToClass(input, $piece(extension, ".", 2))
  return result
  
  do $$$LogMessage(result_" -> "_expectedOutput)
  do $$$AssertEquals(result, expectedOutput, "resolves the source file to Caché class name when extension is "_assertionSuffix)
}

Method TestTranslatePath() As %String
{
  set windowsPath = "C:\Somewhere\Deep\In\The\Windows\System32\drivers\youcanfindme.sys"
  set unixPath = "/home/cacheusr/file.txt"

  set expected = "/Somewhere/Deep/In/The/Windows/System32/drivers/youcanfindme.sys"
  set translation = ##class(Port.Util).TranslatePath(windowsPath, 3)  
  
  do $$$AssertEquals(expected, translation, "Can translate Windows to Unix path")   
  
  set expected = "C:\home\cacheusr\file.txt"
  set translation = ##class(Port.Util).TranslatePath(unixPath, 2)
  
  do $$$AssertEquals(expected, translation, "Can translate Unix to Windows path")
  
  set erroneousWindowsPath = "C:/oops/not\like\this.txt" 
  set expected = "C:\oops\not\like\this.txt"
  set translation = ##class(Port.Util).TranslatePath(erroneousWindowsPath, 2)
  
  do $$$AssertEquals(expected, translation, "Can fix erroneous Windows paths")
  
  set erroneousUnixPath = "/home/oops\not\like/this.txt"
  set expected = "/home/oops/not/like/this.txt"
  set translation = ##class(Port.Util).TranslatePath(erroneousUnixPath, 3)
  
  do $$$AssertEquals(expected, translation, "Can fix erroneous Unix paths")
}

}


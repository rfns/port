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

Method TestExtractType()
{
  set projectName = "mock"
  do ..MockItems(projectName, "", .entries)
  set expectations = $lb("CLS", "CLS", "CLS", "CLS", "CLS", "INC", "MAC", "DFI", "BAS", "MVB", "MVI", "PUBLIC", "PUBLIC", "PUBLIC", "PUBLIC", "PUBLIC", "PUBLIC")
  for i=1:1:$listlength(expectations) {
    set entry = $listget(entries, i)
    set expectation = $listget(expectations, i)
    set result = ##class(Port.Util).GetPathType(entry)
    do $$$AssertEquals(expectation, result, $$$FormatText("extracts %1 -> %2", entry, expectation))
  }
}

Method TestResolveItemId()
{
  set projectName = "mock"
  set macs = $lb("BAS", "INT", "INC", "MVI", "MAC")

  do ..MockItems(projectName, .entries)

  for i=1:1:$listlength(entries) {
    set entry = $listget(entries, i)
    set entry = $replace(entry, "/", "", 1, 1)
    set expectation = entry
    set extension = ##class(Port.Util).GetItemType(entry)

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
    do $$$AssertEquals(expectation, ##class(Port.Util).ResolveItemId(entry, projectName), $$$FormatText("mounts id %1 -> %2", entry, expectation))
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
  do $$$AssertStatusOK(##class(Port.Util).EnsurePathExists(..GetTestDirectory("../temp")), "creates a directory")
  do $$$AssertStatusOK(##class(Port.Util).EnsurePathExists(..GetTestDirectory("../temp")), "tries to create the same directory, nothing should happen.")

  do $$$AssertStatusNotOK(##class(Port.Util).EnsurePathExists(..GetTestDirectory("../temp/(*347dhdsk::)$¨¨#")), "returns an error when the path is invalid.")

  do ##class(%File).RemoveDirectory(..GetTestDirectory("../temp"))
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

Class Port.UnitTest.TestCase Extends %UnitTest.TestCase
{

Method GetTestDirectory(filePath As %String = "") As %String
{
  
  set testPath = ##class(Port.Configuration).GetTestPath()
  return ##class(%File).NormalizeFilename(filePath, ..Manager.Root()_"/"_testPath)
}

}


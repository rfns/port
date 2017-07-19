Class Port.UnitTest.Manager Extends %UnitTest.Manager
{

ClassMethod Root() As %String
{
  // This provides us the capability to search for tests unrelated to ^UnitTestRoot.
  return ##class(%File).NormalizeFilename(##class(Port.Configuration).GetWorkspace())
}

}


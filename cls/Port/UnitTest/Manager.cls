Class Port.UnitTest.Manager Extends %UnitTest.Manager
{

ClassMethod Root() As %String
{
  quit ##class(%File).NormalizeFilename(##class(Port.SourceControl.Config).GetWorkspace())
}

}


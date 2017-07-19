Class Port.AutoInstall Extends %Projection.AbstractProjection
{

Projection Reference As Port.AutoInstall;

ClassMethod CreateProjection(classname As %String, ByRef parameters As %String, modified As %String, qstruct) As %Status
{
  quit ##class(Installer).Install()
}

ClassMethod RemoveProjection(classname As %String, ByRef parameters As %String, recompile As %Boolean, modified As %String, qstruct) As %Status
{
  quit ##class(Installer).Uninstall()
}

}


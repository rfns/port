Include portutils

/// This class presents a list of methods used to resolve qualified test files locations.
Class Port.UnitTest.Util [ Abstract ]
{

ClassMethod GetTestClassPath(className As %String, workspace As %String = {##class(Port.Configuration).GetWorkspace()}) As %String [ Final, Internal ]
{
  set className = className_".CLS"
  set isUsingXML = (##class(Port.Configuration).GetTestFormat() = "XML")
  
  if isUsingXML set workspace = workspace_"/"_##class(Port.Configuration).GetTestPath()
  set path = ##class(Port.Util).ItemToPath(className, workspace)  
  if isUsingXML set path = $replace(path, ".cls", ".xml")
  
  return path
}

/// Returns if the className is a qualified test case class.
ClassMethod IsUnitTestClass(className As %String) As %Boolean
{
  
  set isUnitTest = 0
  set descriptor = ##class(%Dictionary.CompiledClass).%OpenId(className)
  if '$isobject(descriptor) || ($isobject(descriptor) && (descriptor.Super = "")) return 0
  
  // Target class is direct descendant.
  if descriptor.Super [ "Port.UnitTest.TestCase" return 1
  
  // Target class is not a direct descendant, so we go deep down till we find which parent class
  /// is actually extending from Port.UnitTest.TestCase.
  for i=1:1:$length(descriptor.Super, ",") {
    set extension = $piece(descriptor.Super, ",", i)
    if ..IsUnitTestClass(extension) {
      set isUnitTest = 1
      quit
    }   
  }  
  return isUnitTest
}

ClassMethod AssertTestableClass(className, Output testableClass As %String = "", projectName As %String = {$get(^||Port.Project)}) As %Boolean
{
  if $piece(className, ".", *) = "CLS" set className = $piece(className, ".", 1, *-1)
  
  set prefix = ##class(Port.Configuration).GetTestClassPrefix()
  set rootPackage = $piece(className, ".")
  
  if ##class(%Dictionary.ClassDefinition).%ExistsId(prefix_"."_className) {
    set maybeTestableClass = prefix_"."_className
    if ..IsUnitTestClass(maybeTestableClass) {
      set testableClass = prefix_"."_className
      if '##class(Port.Util).ExistsInProject(projectName, testableClass_".CLS") {
        // Cannot export Unit Test classes that aren't in the project.
        set testableClass = ""
      }
    }
  } elseif ..IsUnitTestClass(className) {
    set testableClass = className
  }
  
  return (testableClass '= "")
}

ClassMethod GetClassTestSpec(testableClass As %String, baseTestPath As %String = {##class(Port.Configuration).GetTestPath()})
{
  set isUsingUDL = (##class(Port.Configuration).GetTestFormat() = "UDL")
  set baseTestPath = $$$RTrimProvidedSlash(baseTestPath, "/")
  
  if isUsingUDL set baseTestPath = ""
  return baseTestPath_"/cls/"_$piece($replace(testableClass, ".", "/"), "/", 1, *-1)_":"_testableClass
}

}


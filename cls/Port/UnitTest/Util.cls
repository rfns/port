Class Port.UnitTest.Util [ Abstract ]
{

ClassMethod ResolveTestLocation(workspace As %String, className As %String) As %Status [ Final, Internal ]
{
  set className = className_".CLS"
  return $listbuild(className, $replace(##class(Port.Util).ItemToPath(className, workspace), ".cls", ".xml"))
}

ClassMethod IsUnitTestClass(className As %String) As %Boolean
{
  
  set isUnitTest = 0
  set descriptor = ##class(%Dictionary.CompiledClass).%OpenId(className)
  if '$isobject(descriptor) || ($isobject(descriptor) && (descriptor.Super = "")) return 0
  
  if descriptor.Super [ "Port.UnitTest.TestCase" return 1  
  
  // If the target class have some super class defined, we must consider that it could be
  // extending from multiple super classes. So we need to check each of them.
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
  
  if rootPackage = prefix {
    if '..IsUnitTestClass(className) return 0
    set testableClass = className
  } elseif ##class(%Dictionary.ClassDefinition).%ExistsId(prefix_"."_className) {
    set maybeTestableClass = prefix_"."_className
    if ..IsUnitTestClass(maybeTestableClass) {
      set testableClass = prefix_"."_className
      if '##class(Port.Util).ExistsInProject(projectName, testableClass_".CLS") {
        // Cannot export Unit Test classes that aren't in the project.
        set testableClass = ""
        return 0
      }
    }
  }
  return (testableClass '= "")
}

ClassMethod GetTestPathForClass(testableClass As %String, baseTestPath As %String = {##class(Port.Configuration).GetTestPath()})
{
  if $extract(baseTestPath, *) = "/" set baseTestPath = $extract(baseTestPath, 1, *-1)
  return baseTestPath_"/"_$piece($replace(testableClass, ".", "/"), "/", 1, *-1)_":"_testableClass
}

}


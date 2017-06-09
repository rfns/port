Class Port.SourceControl.Util [ Abstract ]
{

Parameter DEFAULTPATH = "/CacheProjects/{NAMESPACE}/{PROJECT}";

ClassMethod GetFullItemPath(itemName As %String) As %String
{
  
  set fullPath = ""
  set type = ##class(Port.Project.Helper).GetItemExtension(itemName)
  set defaultPath = ##class(%File).NormalizeFilename(##class(Config).GetWorkspace())
  
  if type = "CLS" {
    set fullPath = ##class(Port.Project.Helper).ClassToFile(defaultPath_"/cls", $piece(itemName, ".", 1, *-1))
  } elseif ##class(Port.Project.Helper).IsRoutine(itemName) {
    set ext = $$$lcase(type)
    set fileName = $$$lcase(itemName)_"."_##class(Config).GetSourceExtension()
    set fullPath = ##class(%File).NormalizeFilename(defaultPath_"/"_ext_"/"_fileName) 
  } elseif type = "PKG" {
    set fullPath = ##class(%File).GetDirectory(##class(Port.Project.Helper).ClassToFile(defaultPath_"/cls", itemName))
  } else {
    set sourceFilePath = $replace(itemName, $System.CSP.GetDefaultApp($namespace), "/web")    
    set fullPath = ##class(%File).NormalizeFilename(defaultPath_sourceFilePath) 
  } 
  quit fullPath
}

ClassMethod ResolveInternalName(internalName As %String) As %String
{
  set name = internalName
  
  if $$$ucase(internalName) [ ".CLS" {
    set name = $piece(internalName, ".", 1, *-1)
  }
  quit name
}

ClassMethod AssertTestableClass(className, Output testableClass As %String = "") As %Boolean
{
  set prefix = ##class(Config).GetTestClassPrefix()
  set rootPackage = $piece(className, ".")  
  
  if rootPackage = prefix {
    set testableClass = className
  } elseif ##class(%Dictionary.ClassDefinition).%ExistsId(prefix_"."_className) {
    set testableClass = prefix_"."_className 
  }
  quit (testableClass '= "")
}

ClassMethod GetIgnoredPaths(basePath As %String) As %ListOfDataTypes
{
 
  set ignoredPaths = ##class(%ListOfDataTypes).%New()
  
  set f = ##class(%FileCharacterStream).%New()
  set f.Filename = basePath_"/port.json"  
  
  if f.Size > 0 {    
    while 'f.AtEnd {      
      do ignoredPaths.Insert(f.ReadLine())
    }
  }
  quit ignoredPaths
}

}


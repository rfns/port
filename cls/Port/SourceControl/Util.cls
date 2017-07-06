Include portutils

Class Port.SourceControl.Util [ Abstract ]
{

ClassMethod GetFullItemPath(itemName As %String, projectName As %String = {$get(^||%Studio.Project)}, sourceExtension = {##class(Port.SourceControl.Config).GetSourceExtension()}) As %String
{
  
  set fullPath = ""
  set type = ##class(Port.Project.Helper).GetItemExtension(itemName)
  set defaultPath = ##class(%File).NormalizeFilename(##class(Config).GetWorkspace(projectName))  
  
  if type = "CLS" {
    set fullPath = ##class(Port.Project.Helper).ClassToFile(defaultPath_"/cls", $piece(itemName, ".", 1, *-1))
  } elseif ##class(Port.Project.Helper).IsRoutine(itemName) {
    set ext = $$$lcase(type)
    set fileName = $$$lcase(itemName)_"."_##class(Config).GetSourceExtension()
    set fullPath = ##class(%File).NormalizeFilename(defaultPath_"/"_ext_"/"_fileName) 
  } elseif type = "PKG" {
    // Deep package?
    set name = $replace(itemName, ".PKG", "")
    set fullPath = ##class(Port.Project.Helper).ClassToFile(defaultPath_"/cls", name, sourceExtension,0)   
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

ClassMethod IsPackage(maybePackage As %String) As %Boolean
{
  set package = maybePackage_"."
  &sql(SELECT COUNT(ID) INTO :packageExists FROM %DICTIONARY.COMPILEDCLASS WHERE NAME %STARTSWITH :package)
  quit (packageExists > 0)
}

}


Include (portutils, portmd)

Class Port.Project.Base Extends %RegisteredObject
{

Property Logger As Port.Logger;

Property ProjectName As %String;

Property Project As %Studio.Project [ Private ];

Property Slash As %String [ Private ];

Property BasePath As %String [ Private ];

Property IncPath As %String [ Private ];

Property ClassPath As %String [ Private ];

Property IntPath As %String [ Private ];

Property MacPath As %String [ Private ];

Property WebPath As %String [ Private ];

Property MvbPath As %String [ Private ];

Property MviPath As %String [ Private ];

Property BasPath As %String [ Private ];

Property DfiPath As %String [ Private ];

Property AffectedCount As %Boolean [ InitialExpression = 0 ];

Property IsBatch As %Boolean [ InitialExpression = 0 ];

Property Overwrite As %Boolean [ InitialExpression = 0 ];

Property LogLevel As %Integer [ InitialExpression = 2 ];

Property SourceExtension As %String [ InitialExpression = "txt" ];

Property IgnoredPaths As list Of %String;

Method %OnNew(target As %String, logLevel As %Integer = 2, sourceExtension = "") As %Status
{
  if target = "" {
    throw ##class(%Exception.StatusException).CreateFromStatus($$$ERROR(5001, "No target specified."))
  }
  
  set ..Slash = $select($$$isWINDOWS : "\", 1: "/")
  
  if (target [ "/") || (target [ "\") {
    set fullProjectPath = ##class(%File).NormalizeFilename(target)  
    set ..ProjectName = $piece(fullProjectPath, ..Slash, *)        
    set ..BasePath = ##class(%File).NormalizeFilename(fullProjectPath)
    set ..Project = ##class(%Studio.Project).%OpenId(..ProjectName)
    set ..Logger = ##class(Port.Logger).%New(logLevel) 
    set ..SourceExtension = sourceExtension
    do ..BuildTypePaths(..BasePath)
    return $$$OK 
  }
  return $$$PERROR($$$CannotUseRelativePath)
}

Method LogExclusive(message As %String, logLevel As %Integer, params... As %String) As %String [ Internal ]
{
  if ..Logger.LogLevel '= logLevel return ""
  return ..Log(message, logLevel, params...)
}

Method Log(message As %Boolean, logLevel As %Integer = 1, params... As %String) [ Internal ]
{
  return ..Logger.Log(message, logLevel, params...)
}

Method LogLine(message As %Boolean, logLevel As %Integer = 1, params... As %String) [ Internal ]
{
  
  return ..Logger.LogLine(message, logLevel, params...)
}

Method LogExclusiveLine(message As %Boolean, logLevel As %Integer = 1, params... As %String) [ Internal ]
{
  if ..Logger.LogLevel '= logLevel return ""
  return ..Logger.LogLine(message, logLevel, params...)
}

Method GetProjectName() As %String
{
  return ..ProjectName
}

Method Ignore(ignoredPaths As %ArrayOfDataTypes = "") As %Status
{
  set sc = $$$OK  
  
  if '$isobject(ignoredPaths) return sc
  if 'ignoredPaths.%IsA("%Collection.AbstractList") {
    return $$$ERROR($$$BadParameter, "ignoredPaths")
  }  
  
  for i=1:1:ignoredPaths.Count() {
    set absolutePath = ##class(%File).NormalizeFilename(..BasePath_"/"_ignoredPaths.GetAt(i))
    set sc = ..IgnoredPaths.Insert(absolutePath)
    if $$$ISERR(sc) quit
  }
  return sc
}

Method IsIgnored(maybeIgnoredPath As %String) As %Boolean
{
 
  set key = ""
  set isIgnored = 0
  
  for i=1:1:..IgnoredPaths.Count() {
    set path = ..IgnoredPaths.GetAt(i)
    set isIgnored = ((path = maybeIgnoredPath) || (maybeIgnoredPath [ path))
    if isIgnored quit
  }
  return isIgnored
}

Method ResolvePathType(itemType As %String, itemName As %String = "") As %String [ Final, Internal, Private ]
{
  #define Normalize(%path)    ##class(%File).NormalizeFilename(%path)
  
  if itemType = "CLS" return ..ClassPath
  if itemType = "INT" return ..IntPath
  if itemType = "INC" || (itemType = "MAC" && ($piece(itemName, ".", 2) = "INC")) {
    // InterSystems groups INC into MAC type, so we patch it checking the name instead.
    return ..IncPath
  }
  if itemType = "MAC" return ..MacPath  
  if itemType = "MVB" return ..MvbPath
  if itemType = "MVI" return ..MviPath  
  if itemType = "BAS" return ..BasPath
  if itemType = "DFI" return ..DfiPath
  return ""
}

Method GetTypePath(itemType As %String, itemName As %String = "") As %String
{
 
  if itemType = "CLS" return ..ClassPath
  if itemType = "INT" return ..IntPath
  if itemType = "INC" || (itemType = "MAC" && ($piece(itemName, ".", 2) = "INC")) {
    // InterSystems groups INC into MAC type, so we patch it checking the name instead.
    return ..IncPath
  }
  if itemType = "MAC" return ..MacPath
  if itemType = "CSP" return ..WebPath
  if itemType = "MVB" return ..MvbPath
  if itemType = "MVI" return ..MviPath  
  if itemType = "BAS" return ..BasPath
  if itemType = "DFI" return ..DfiPath
  if itemType = "PKG" return ..ClassPath
  return ..WebPath
}

Method BuildTypePaths(workingDirectory As %String) As %Status [ Final, Internal, Private ]
{
  #define BuildTypedPath(%type) $lts($lb(workingDirectory, %type), $$$Slash)
  
  set ..ClassPath = $$$BuildTypedPath("cls")
  set ..IntPath   = $$$BuildTypedPath("int")
  set ..MacPath   = $$$BuildTypedPath("mac") 
  set ..IncPath   = $$$BuildTypedPath("inc")
  set ..WebPath   = $$$BuildTypedPath("web")  
  set ..MvbPath   = $$$BuildTypedPath("mvb")
  set ..MviPath   = $$$BuildTypedPath("mvi")
  set ..BasPath   = $$$BuildTypedPath("bas")  
  set ..DfiPath   = $$$BuildTypedPath("dfi")
  return $$$OK
}

Method NormalizeOutput(itemName As %String, Output path As %String = "", Output extension As %String = "") As %String [ Private ]
{
  
  set extension = ##class(Port.Util).GetItemExtension(itemName)
  set dest = ""
  
  // Package.Class.Name -> cls/Package/Class/Name.cls.txt
  if extension = "CLS" {
    set classBasePath = ..ResolvePathType("CLS")
    set classItemName = $piece(itemName, ".", 1, *-1)
    set classPath = $listtostring($listbuild(classBasePath, $replace(classItemName, ".", ..Slash)), ..Slash)
    set packagePath = $piece(classPath, ..Slash, 1, *-1)
    set className = $piece(classPath, ..Slash, $length(classPath, ..Slash))
    set dest = classPath_".cls"_..GetSourceExtension()
    set path = packagePath
  }
  
  // Routine.(type) -> /(type)/routine.(type).txt
  elseif ##class(Port.Util).IsRoutine(itemName) {    
    set type = $$$ucase($piece(itemName, ".", *))
    set path = ..ResolvePathType(type, itemName)
    set dest = path_..Slash_itemName
    set extPos = $length(dest, ".")
    set $piece(dest, ".", extPos) = $$$lcase($piece(dest, ".", extPos))_..GetSourceExtension()
  }
  
  // /csp/path/to/somefile.(*) -> /web/path/to/somefile.(*).txt
  else {
    set appPath = $System.CSP.GetDefaultApp($namespace)
    set baseTypePath = ..ResolvePathType("CSP")
    set ext = $$$lcase($piece(itemName, ".", *))
    set fileWithoutExtension = $piece(itemName, ".", 1, *-1)
    set dest = ##class(%File).NormalizeFilename(baseTypePath_..Slash_$piece(fileWithoutExtension, "/", 3, *))_"."_ext
    set path = ##class(%File).GetDirectory(dest) 
  }
  return dest
}

Method IsOutdated(current As %String, external As %String, isImport As %Boolean = 0) As %Boolean
{
  if '##class(%File).Exists(external) return 1 
  set externalTS = $zdt(##class(%File).GetFileDateModified(##class(%File).NormalizeFilename(external)), 3,,,,,,,,,0)
    
  if externalTS < 0 return 1
  set lastModified = 0  
  
  set projectTS = ##class(Port.SourceControl.Log).GetLastChange(..GetProjectName(), ..GetProjectName()_".PRJ")
  set currentDate = ##class(Port.SourceControl.Log).GetLastChange(..GetProjectName(), current)
  
  if currentDate = 0 set lastModified = projectTS
  else  set lastModified = $select(currentDate ] projectTS : currentDate, 1: projectTS)
      
  if ##class(Port.Util).IsRoutine(current) || 
    (##class(Port.Util).ResolveItemExtension(current) = "CLS") {
    set currentTS = $piece(##class(%RoutineMgr).TS(current, .compileTime), ".")
  } else {
    set fullSourcePath = ""
    if 'isImport {
      do ##class(Port.Util).CSPLogicalToPhysicalPath(current, .fullSourcePath)
    } else {
      do ##class(Port.Util).CSPPhysicalToLogicalPath(current, .fullSourcePath)
    }
    set currentTS = $zdatetime(##class(%File).GetFileDateModified(fullSourcePath), 3,,,,,,,,,0)
  } 
  
  // If the file or the item is missing it's considered outdated as well.
  if currentTS = 0 return 1  
  
  // Same date for both entries? Then consider updated.
  if currentTS = externalTS return 0
  if 'isImport {
    if currentTS = "" return 1
    // Now here the following rule are applied:
    // As currentTS is referring to the source inside Caché, this conditions checks if 
    // the currrent source present is newer than the file exported last time, we also keep a registry
    // about changes made using Port so we check against it as well.
    return (
      (currentTS ] externalTS) && 
      (currentTS ] lastModified)
    )
  }
  // Otherwise everything is inverted:
  // External files must be newer than the current source inside Caché and newer than their last
  // registry as well. 
  return (
    (externalTS ] currentTS) && 
    (externalTS ] lastModified)
  )
}

Method GetSourceExtension() As %String [ Private ]
{
  return $select(..SourceExtension '= "" : "."_..SourceExtension, 1: "")
}

}


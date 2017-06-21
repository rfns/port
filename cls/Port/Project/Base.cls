Include portutils

Class Port.Project.Base Extends %RegisteredObject
{

Property Logger As Port.Logger [ Private ];

Property ProjectName As %String [ Private ];

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
    quit $$$OK 
  }
  quit $$$ERROR(5001, "Cannot use invalid or relative paths: an absolute path is required.")
}

Method WriteExclusive(logLevel As %Integer, message As %String, params... As %String)
{
  if ..Logger.LogLevel '= logLevel quit
  do ..Write(message, logLevel, params...)
}

Method Write(message As %Boolean, logLevel As %Integer = 1, params... As %String) [ Private ]
{
  do ..Logger.Log(message, logLevel, params...)
}

Method GetProjectName() As %String
{
  quit ..ProjectName
}

Method Ignore(ignoredPaths As %ArrayOfDataTypes = "") As %Status
{
  set sc = $$$OK  
  
  if '$isobject(ignoredPaths) quit sc
  if 'ignoredPaths.%IsA("%Collection.AbstractList") {
    quit $$$ERROR($$$BadParameter, "ignoredPaths")
  }  
  
  for i=1:1:ignoredPaths.Count() {
    set absolutePath = ##class(%File).NormalizeFilename(..BasePath_"/"_ignoredPaths.GetAt(i))
    set sc = ..IgnoredPaths.Insert(absolutePath)
    if $$$ISERR(sc) quit
  }
  quit sc
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
  quit isIgnored
}

Method ResolvePathType(itemType As %String, itemName As %String = "") As %String [ Final, Internal, Private ]
{
  #define Normalize(%path)    ##class(%File).NormalizeFilename(%path)
  
  if itemType = "CLS" quit ..ClassPath
  if itemType = "INT" quit ..IntPath
  if itemType = "INC" || (itemType = "MAC" && ($piece(itemName, ".", 2) = "INC")) {
    // InterSystems groups INC into MAC type, so we patch it checking the name instead.
    quit ..IncPath
  }
  if itemType = "MAC" quit ..MacPath
  if itemType = "CSP" quit ..WebPath
  if itemType = "MVB" quit ..MvbPath
  if itemType = "MVI" quit ..MviPath  
  if itemType = "BAS" quit ..BasPath
  if itemType = "DFI" quit ..DfiPath
  quit ""
}

Method BuildTypePaths(workingDirectory As %String) As %Status [ Final, Internal, Private ]
{
  #define BuildTypedPath(%type) $lts($lb(workingDirectory, %type), ..Slash)
  
  set ..ClassPath = $$$BuildTypedPath("cls")
  set ..IntPath   = $$$BuildTypedPath("int")
  set ..MacPath   = $$$BuildTypedPath("mac") 
  set ..IncPath   = $$$BuildTypedPath("inc")
  set ..WebPath   = $$$BuildTypedPath("web")  
  set ..MvbPath   = $$$BuildTypedPath("mvb")
  set ..MviPath   = $$$BuildTypedPath("mvi")
  set ..BasPath   = $$$BuildTypedPath("bas")  
  set ..DfiPath   = $$$BuildTypedPath("dfi")
  quit $$$OK
}

Method NormalizeOutput(itemName As %String, Output path As %String = "", Output extension As %String = "") As %String [ Private ]
{
  
  set extension = ##class(Port.Project.Helper).GetItemExtension(itemName)
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
  elseif ##class(Port.Project.Helper).IsRoutine(itemName) {    
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
  quit dest
}

ClassMethod CheckUbiquity(projectName As %String, ByRef ubiquityList As %String = 0) As %Status
{
  set sc = $$$OK
  set (name, type, projects) = ""
  
  set sProjects = ##class(%SQL.Statement).%New()
  $$$QuitOnError(sProjects.%PrepareClassQuery("%Studio.Project", "ProjectList"))   
  set projectRows = sProjects.%Execute()
  
  set sProjectItems = ##class(%SQL.Statement).%New()
  $$$QuitOnError(sProjectItems.%PrepareClassQuery("%Studio.Project", "ProjectItemsList"))
  set projectItemsRows = sProjectItems.%Execute(projectName)
  
  while projectRows.%Next(.sc) {
    if $$$ISERR(sc) quit
    set currentProject = projectRows.%Get("Name")
    if projectName '= currentProject {
      set projects(projectName) = ""     
    }
  }
  
  while projectItemsRows.%Next(.sc) {
    if $$$ISERR(sc) quit
    set id = projectItemsRows.%Get("ID")
    set type = projectItemsRows.%Get("Type")    
    set name = projectItemsRows.%Get("Name")
    set candidateId = id
    set candidateProject = ""
    for {      
      set candidateProject = $order(projects(candidateProject))
      quit:candidateProject=""
      set candidateId = id
      set $piece(candidateId, "||", 1) = candidateProject
      if ##class(%Studio.ProjectItem).%ExistsId(candidateId) {
        set ubiquityList = ubiquityList + 1
        set ubiquityList(candidateId) = $listbuild(name, type)
      } elseif type = "CLS" {
        set class = ""
        set parts = $length(name, ".")
        set $piece(candidateId, "||", 3) = "PKG"
        for i=parts:-1:1 {
          set class = $piece(name,  ".", 1, i)
          set $piece(candidateId, "||", 2) = class
          if ##class(%Studio.ProjectItem).%ExistsId(candidateId) {
            set ubiquityList = ubiquityList + 1
            set ubiquityList(candidateId) = ""
            quit
          }
        }
      }
    }    
  }
}

Method IsOutdated(current As %String, external As %String, isImport As %Boolean = 0) As %Boolean
{
  
  if '##class(%File).Exists(external) quit 1 
  set externalTS = $zdt(##class(%File).GetFileDateModified(##class(%File).NormalizeFilename(external)), 3,,,,,,,,,0)
    
  if externalTS < 0 quit 1
  set lastModified = 0  
  
  set projectTS = ##class(Port.SourceControl.Log).GetLastChange(..GetProjectName(), ..GetProjectName()_".PRJ")
  set currentDate = ##class(Port.SourceControl.Log).GetLastChange(..GetProjectName(), current)
  
  if currentDate = 0 set lastModified = projectTS
  else  set lastModified = $select(currentDate ] projectTS : currentDate, 1: projectTS)
      
  if ##class(Port.Project.Helper).IsRoutine(current) || 
    (##class(Port.Project.Helper).GetItemExtension(current) = "CLS") {
    set currentTS = $piece(##class(%RoutineMgr).TS(current, .compileTime), ".")
  } else {
    if 'isImport {
      set fullSourcePath = ##class(%File).NormalizeFilename(current, $System.Util.InstallDirectory())
    } else {
      do ##class(Port.Project.Helper).CSPLogicalToPhysicalPath(current, .fullSourcePath)
      //set fullSourcePath = ##class(Port.Project.Helper).CSPLogicalToPhysical(current)
    }
    set currentTS = $zdatetime(##class(%File).GetFileDateModified(fullSourcePath), 3,,,,,,,,,0)
    // If the file is missing it's considered outdated as well.
    if currentTS = 0 quit 1
  }   
  
  // Same date for both entries? Then consider updated.
  if currentTS = externalTS quit 0
  if 'isImport {  
    quit (
      (currentTS ] externalTS) && 
      (currentTS ] lastModified)
    )
  }
  quit (
    (externalTS ] currentTS) && 
    (externalTS ] lastModified)
  )
}

Method IsProjectMember(name As %String, Output isProjectMember As %Boolean, type As %String = "") As %Status [ Internal ]
{
  $$$QuitOnError(..Project.NormalizeName(.name, .type))
  set id = ..ProjectName_"||"_name_"||"_type
  set isProjectMember = (..Project.Items.FindObjectId(id) '= "")
  quit $$$OK
}

Method GetSourceExtension() As %String [ Private ]
{
  quit $select(..SourceExtension '= "" : "."_..SourceExtension, 1: "")
}

}


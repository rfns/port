Include (portutils, portmd)

/// This is the main class used to define a set of features that are shared by each type of utility.
Class Port.Project.Base Extends %RegisteredObject
{

/// A reference for the utility that is used to display information regarding the current operation.
Property Logger As Port.Logger;

/// A reference for the current opened %Studio.Project.
Property Project As %Studio.Project [ Private ];

/// A string containing the workspace directory.
Property BasePath As %String;

/// A string containing the workspace plus the 'inc' directory.
Property IncPath As %String [ Private ];

/// A string containing the workspace plus the 'cls' directory.
Property ClassPath As %String [ Private ];

/// A string containing the workspace plus the 'int' directory.
Property IntPath As %String [ Private ];

/// A string containing the workspace plus the 'mac' directory.
Property MacPath As %String [ Private ];

/// A string containing the workspace plus the 'public' directory.
Property PublicPath As %String [ Private ];

/// A string containing the workspace plus the 'mvb' directory.
Property MvbPath As %String [ Private ];

/// A string containing the workspace plus the 'mvi' directory.
Property MviPath As %String [ Private ];

/// A string containing the workspace plus the 'bas' directory.
Property BasPath As %String [ Private ];

/// A string containing the workspace plus the 'dfi' directory.
Property DfiPath As %String [ Private ];

/// Contains the count of items imported/exported.
Property AffectedCount As %Boolean [ InitialExpression = 0 ];

/// A flag that indicates if the user opted to import/export more than one item.
Property IsBatch As %Boolean [ InitialExpression = 0 ];

/// A flag that signals the exporter/imported to overwrite every file/document regardless if they are up-to-date or not.
Property Overwrite As %Boolean [ InitialExpression = 0 ];

/// An integer indicating the level of the logger, which is used to filter what kind of info should de display for the end-user.
Property LogLevel As %Integer [ InitialExpression = 2 ];

/// A list of files that are ignored by the synchronizer utility.
Property IgnoredPaths As list Of %String;

Property ProjectName As %String [ Private ];

Method %OnNew(target As %String, logLevel As %Integer = 2) As %Status
{
  if target = "" {
    throw ##class(%Exception.StatusException).CreateFromStatus($$$ERROR(5001, "No target specified."))
  }

  if (target [ "/") || (target [ "\") {
    set workspaceName = $piece(target, $$$PathSlash(target), *)
    
    set project = ##class(%Studio.Project).%OpenId(workspaceName)
    if '$isobject(project) set project = ##class(%Studio.Project).%New()
    
    set project.Name = workspaceName
    set fullProjectPath = ##class(%File).NormalizeFilename(target)
    set ..BasePath = ##class(%File).NormalizeFilename(fullProjectPath)
    set ..Project = project    
    set ..ProjectName = workspaceName
    set ..Logger = ##class(Port.Logger).%New(logLevel)
    do ..BuildTypePaths(..BasePath)
    quit $$$OK
  }
  quit $$$PERROR($$$CannotUseRelativePath)
}

/// Displays the message only if the configured log level is exactly the same on provided for this method.
Method LogExclusive(messageCode As %String, logLevel As %Integer, params... As %String) As %String [ Internal ]
{
  if ..Logger.LogLevel '= logLevel quit ""
  quit ..Log(messageCode, logLevel, params...)
}

/// Displays the message if the configured log level is either the same or higher than the one provided for this method.
/// This method won't break the line.
Method Log(messageCode As %Boolean, logLevel As %Integer = 1, params... As %String) [ Internal ]
{
  quit ..Logger.Log(messageCode, logLevel, params...)
}

/// Same as Log, but this will break into a new line.
Method LogLine(messageCode As %String, logLevel As %Integer = 1, params... As %String) [ Internal ]
{

  quit ..Logger.LogLine(messageCode, logLevel, params...)
}

/// Same as LogExclusive, but will break into a new line.
Method LogExclusiveLine(message As %Boolean, logLevel As %Integer = 1, params... As %String) [ Internal ]
{
  if ..Logger.LogLevel '= logLevel quit ""
  quit ..Logger.LogLine(message, logLevel, params...)
}

/// Returns the name of the project that is being used by the utility.
Method GetProjectName() As %String
{
  quit ..ProjectName
}

/// Adds a path to the IgnoredPaths list. Which is used by the Synchronizer to skip files.
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

/// This method is used by the Sychronizer to check if the file should be skipped or not.
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

/// Returns the current path for the 'type' and 'itemName' provided. This method is not intended to be used by the Synchronizer
Method GetTypePath(itemType As %String, itemName As %String = "") As %String [ Internal ]
{

  if itemType = "CLS" quit ..ClassPath
  if itemType = "INT" quit ..IntPath
  if itemType = "INC" || (itemType = "MAC" && ($piece(itemName, ".", 2) = "INC")) {
    // InterSystems groups INC into MAC type, so we patch it checking the name instead.
    quit ..IncPath
  }
  if itemType = "MAC" quit ..MacPath
  if itemType = "CSP" quit ..PublicPath
  if itemType = "MVB" quit ..MvbPath
  if itemType = "MVI" quit ..MviPath
  if itemType = "BAS" quit ..BasPath
  if itemType = "DFI" quit ..DfiPath
  if itemType = "PKG" quit ..ClassPath
  quit ..PublicPath
}

/// Populates each path type property that is used to discover where the file is located.
Method BuildTypePaths(workspacePath As %String) As %Status [ Final, Internal, Private ]
{
  #define BuildTypedPath(%type) $$$NFN(workspacePath_"/"_%type)

  set ..ClassPath   = $$$BuildTypedPath("cls")
  set ..IntPath     = $$$BuildTypedPath("int")
  set ..MacPath     = $$$BuildTypedPath("mac")
  set ..IncPath     = $$$BuildTypedPath("inc")
  set ..PublicPath  = $$$BuildTypedPath("public")
  set ..MvbPath     = $$$BuildTypedPath("mvb")
  set ..MviPath     = $$$BuildTypedPath("mvi")
  set ..BasPath     = $$$BuildTypedPath("bas")
  set ..DfiPath     = $$$BuildTypedPath("dfi")
  quit $$$OK
}

/// Returns if the item is up-to-date to its equivalent file version.
Method IsOutdated(current As %String, external As %String, isImport As %Boolean = 0) As %Boolean
{
  quit ##class(Port.Util).IsOutdated(..GetProjectName(), current, external, isImport)
}

}


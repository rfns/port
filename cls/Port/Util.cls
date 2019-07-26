Include portutils

Class Port.Util [ Abstract ]
{

/// Returns the workspace folder name according to an absolute path. The name is matched
/// from the directory part that is before the item type folder. E.g.: <workspace_name>/<item_type>/<item_filename>.
/// If item_type is a known type, then it will be used as a pointer to find the workspace_name.
ClassMethod GetWorkspaceNameFromAbsoluteItemPath(absolutePath As %String) As %String
{
  set pathParts = $lfs(absolutePath, $$$Slash(absolutePath))
  set workspaceName = ""

  for i=1:1:$ll(pathParts) {
    set part = $lg(pathParts, i)
    if $lf($$$PathTypes, part) set workspaceName = $lg(pathParts, i - 1) quit
  }
  quit workspaceName
}

/// Returns the path that leads to the workspace folder, excluding any folder that is part of it.
ClassMethod GetWorkspaceFromItemPath(itemPath As %String) As %String
{
  set slash = $$$Slash(itemPath)
  set workspaceName = ""

  for i=1:1:$length(itemPath, slash) {
    set part = $piece(itemPath, slash, i)
    if $lf($$$PathTypes, part) {
      set workspace = $piece(itemPath, slash, 1, i - 1)
      quit
    }
  }
  quit workspace
}

/// Retrieves the extension from the itemName. If the extension matches none, then attempt to find out if the extension is actually a package.
/// Otherwise assume that the extension is defined from a custom file.
ClassMethod GetItemType(itemName As %String, checkPackageExists As %Boolean = 1) As %String
{
  set ext = $$$ucase($piece(itemName, ".", *))
  set slash = $$$PathSlash(itemName)

  if itemName [ slash quit "CSP"
  if $lf($$$RoutineExtensions, "."_ext) || (ext = "CLS") || (ext = "PRJ") return ext
  
  if 'checkPackageExists || (checkPackageExists && ..IsPackage(itemName)) { quit "PKG" }
  quit ext
}

/// Checks if the itemName is actually a package. Returns 1 if yes otherwise 0.
ClassMethod IsPackage(itemName) As %Boolean
{
  if itemName = "" return 0
  if $get(^oddPKG($$$ucase(itemName))) '= "" quit 1
  if ##class(%Dictionary.PackageDefinition).%ExistsId(itemName) quit 1
  do $System.OBJ.GetPackageList(.l, itemName)
  if $data(l) quit 1

  quit 0
}

/// Translates an item name into a workspace path.
ClassMethod GetWorkspaceBasedItemPath(itemName As %String, project As %String = {$get(^||Port.Project)}) As %String
{
  quit ..ItemToPath(itemName, $$$NFN(##class(Port.Configuration).GetWorkspace(project)))
}

/// Translates the item name into an item path which represents the location to where the file source is located.
ClassMethod ItemToPath(itemName As %String, workspace As %String = "") As %String
{
  #define WithAbsolute(%s) $select(workspace '= "" : $$$NFN(workspace_%s), 1: %s)

  set fullPath = ""
  set type = ..GetItemType(itemName, 0)
  set slash = $$$Slash(itemName)
  set workspace = $select(workspace '= "" : $$$RPadProvidedSlash(workspace, slash), 1: "")

  if type = "CLS" {    
    set classWithoutTheExtension = $piece(itemName, ".", 1, *-1)
    set fullPath = $$$WithAbsolute("cls"_$$$OSSlash_..ClassToFile(classWithoutTheExtension))
  } elseif $lf($$$RoutineExtensions, "."_$$$ucase(type)) {
    set itemName = $piece(itemName, slash, *)
    set ext = $$$lcase(type)
    set fileName = itemName
    set $piece(fileName, ".", *) = ext
    set fullPath = $$$WithAbsolute(ext_"/"_fileName)
  } elseif type = "PKG" {
    // Deep package?
    if $$$ucase(itemName) '[ ".PKG" set itemName = itemName_".PKG"
    set name = $select(itemName [ "." : $piece(itemName, ".", 1, *-1), 1: itemName)
    set fullPath = $$$WithAbsolute("cls/"_..ClassToFile(name, 0))
  } else {
    set itemName = $$$LTrimProvidedSlash(itemName, "/")
    set webApplication = $System.CSP.GetAppName(itemName)
    set remainingPath = $piece(itemName, "/", $length(webApplication, "/"), *)
    set sourceFilePath = "public/"_webApplication_remainingPath
    set fullPath = $$$WithAbsolute(sourceFilePath)
  }
  quit $replace(fullPath, "/", $$$Slash(fullPath))
}

/// Translates an absolute item path into its item format.
ClassMethod PathToItem(sourcePath As %String, namespace As %String = {$namespace}) As %Status
{
  set isPackage = 0
  if sourcePath [ "." set type = $piece(sourcePath, ".", *)
  else  set type = "cls" set isPackage = 1

  set uppercaseType = $$$ucase(type)

  set sourcePath = $$$NFN(sourcePath)
  set slash = $$$Slash(sourcePath)

  if $lf($$$RoutineExtensions, "."_uppercaseType) || (uppercaseType = "CLS") {
    set item = $replace($piece($$$LPadProvidedSlash(sourcePath, slash), slash_type_slash, 2, *), slash, ".")
    if isPackage set $piece(item, ".", *+1) = "pkg"
    quit item
  }

  set item = ..GetItemFromCSPPath(sourcePath, namespace)
  quit item
}

/// Extracts the portion of the folder that represents the source type.
ClassMethod GetPathType(absolutePath As %String) As %String
{
  set part = ""
  set slash = $$$PathSlash(absolutePath)
  set partsLength = $length(absolutePath, $$$PathSlash(absolutePath))

  for i=1:1:partsLength {
    set part = $$$lcase($piece(absolutePath, slash, i))
    if $lf($$$PathTypes, part) quit
  }

  quit $$$ucase(part)
}

/// Resolves item name into a qualified id that can be manipulated by the %Studio.Project API.
ClassMethod ResolveItemId(name As %String, projectName As %String = {$get(^||Port.Project)}) As %String
{
  set nameOnly = $piece(name, ".", 1, *-1)
  set maskedMacs = $lb("BAS", "INT", "INC", "MVI")
  set itemName = name
  set id = ""

  set extension = ..GetItemType(name)

  if ..IsRoutine(name) {
    set itemType = extension
    if $lf(maskedMacs, itemType) set itemType = "MAC"
    set itemName = nameOnly_"."_extension
  } elseif extension = "CLS" {
    set itemName = nameOnly
    set itemType = extension
  } elseif extension = "PKG" {
    set itemName = nameOnly
    set itemType = "PKG"
  } else {
    // Ensures that CSP items starts with normalized path.
    set itemName = $$$LTrimProvidedSlash(name, "/")
    set itemType = "CSP"
  }
  return projectName_"||"_itemName_"||"_itemType
}

ClassMethod GetItemFromCSPPath(physicalPath As %String, namespace As %String = {$namespace}) As %String [ Private ]
{
  set slash = $$$Slash(physicalPath)
  quit $replace($extract(physicalPath, $find(physicalPath, slash_"public"_slash), *), "\", "/")
}

ClassMethod IsRoutine(itemName As %String) As %Boolean
{
  set extension = ..GetItemType(itemName)

  if extension = "MAC"  || (extension = "INT") ||
    (extension = "MVB") || (extension = "MVI") ||
    (extension = "BAS") || (extension = "INC") ||
    (extension = "DFI") {
    return 1
  }
  return 0
}

ClassMethod ClassToFile(className As %String, appendCLS As %Boolean = 1) As %String [ Private ]
{
  set cls = $case(appendCLS, 1: ".cls", : "")
  quit $replace(className, ".", $$$OSSlash)_cls
}

ClassMethod FileToClass(path As %String) As %String [ Private ]
{
  set slash = $$$Slash(path)
  set path = $$$NFN(path)
  set fileName = ##class(%File).GetFilename(path)
  set contextPath = $extract(path, $find(path, slash_"cls") + 1, ($length(path) - 1) - 3)
  return $replace(contextPath, slash, ".")
}

ClassMethod ExistsInProject(projectName As %String, name As %String, type As %String = "", namespace As %String = {$namespace}) As %Boolean [ Internal ]
{

  new $namespace
  set $namespace = namespace

  try {
    do ##class(%Studio.Project).NormalizeName(.name, .type)

    set s = ##class(%SQL.Statement).%New()
    do s.%PrepareClassQuery("%Studio.Project", "ProjectItemsList")
    set r = s.%Execute(projectName)

    while r.%Next(.sc) {
      set itemName = r.%Get("Name")
      set itemType = r.%Get("Type")
      if itemType = type && ($$$lcase(itemName) = $$$lcase(name)) {
        do ##class(%Studio.Project).NormalizeName(.itemName, .itemType)
        if itemName = name return 1
      }
    }
  } catch ex {
    return 0
  }

  return 0
}

ClassMethod ListConflicts(projectName As %String, name As %String, type As %String = "", namespace As %String = {$namespace}) As %List
{
  new $namespace
  set $namespace = namespace
  
  do ##class(%Studio.Project).NormalizeName(.name, .type)
  &sql(
    SELECT
      LIST(DISTINCT P.NAME) INTO :conflicts
    FROM
      %STUDIO.PROJECTITEM PI
    LEFT OUTER JOIN
      %STUDIO.PROJECT P ON P.ID = PI.Project
    WHERE
      P.NAME <> :projectName AND (
       -- This deals with common cases.
       (:type NOT IN ('PKG', 'CLS') AND PI.NAME = :name) OR
       -- This deals with cases where a project is trying to add a package that is
       -- depended by another class in another project.
       (:type = 'PKG' AND PI.NAME %STARTSWITH :name) OR
       -- This deals with attempts to add classes that are owned by another project's
       -- package.
       (:type = 'CLS' AND PI.NAME = :name)
      )
  )
  return $lfs(conflicts)
}

ClassMethod EnsurePathExists(path As %String) As %Status
{
  set absolutePath = $$$NFN(path)
  set isCreated = 1
  if '##class(%File).DirectoryExists(absolutePath)  {
    set isCreated = ##class(%File).CreateDirectoryChain(absolutePath)
    if isCreated = 0 {
      return $$$PERROR($$$CannotCreateDirectory, absolutePath)
    }
  }
  return $$$OK
}

ClassMethod GetIgnoredPaths(projectName As %String = {$get(^||Port.Project)}) As %ListOfDataTypes
{
  set workspaceDir = ##class(Port.Configuration).GetWorkspace(projectName)
  set ignoredPaths = ##class(%ListOfDataTypes).%New()

  set f = ##class(%FileCharacterStream).%New()
  set f.Filename = workspaceDir_"/.portignore"

  if f.Size > 0 {
    while 'f.AtEnd {
      do ignoredPaths.Insert(f.ReadLine())
    }
  }
  return ignoredPaths
}

ClassMethod TranslatePath(path As %String, OSFormat As %Integer = {$zversion(1)}) As %String
{
  // Unix
  if OSFormat = 3 {
    if $extract(path, 1, 2)?1A1":" {
      set path = $extract(path, 3, *)
    }
    return $replace(path, "\", "/")
  // Windows
  } elseif OSFormat = 2 {
    set path = $replace(path, "/", "\")
    if $extract(path) = "\" {
      set path = ##class(%File).NormalizeFilename("\")_path
    }
  }
  return path
}

/// Checks if an an item is outdated to their counterpart (the local source file).
/// Use the isImport flag to invert the condition.
ClassMethod IsOutdated(project As %String, current As %String, external As %String, isImport As %Boolean = 0) As %Boolean
{
  if '##class(%File).Exists(external) quit 1
  set externalTS = $zdt(##class(%File).GetFileDateModified(##class(%File).NormalizeFilename(external)), 3,,,,,,,,,0)
  set workspace = ..GetWorkspaceFromItemPath(external)

  if externalTS < 0 quit 1
  set lastModified = 0

  set projectTS = ##class(Port.SourceControl.Log).GetLastChange(project, project_".PRJ")
  set currentDate = ##class(Port.SourceControl.Log).GetLastChange(project, current)

  if currentDate = 0 set lastModified = projectTS
  else  set lastModified = $select(currentDate ] projectTS : currentDate, 1: projectTS)

  if ..IsRoutine(current) || (..GetItemType(current) = "CLS") {
    set currentTS = $piece(##class(%RoutineMgr).TS(current, .compileTime), ".")
  } else {
    set fullSourcePath = ""
    set target = ##class(%CSP.Routine).%New(current)
    /// Skip what we can't import.
    if '$isobject(target) return 0
    set currentTS = $zdatetime(##class(%File).GetFileDateModified(target.Filename), 3,,,,,,,,,0)
  }

  // If the file or the item is missing it's considered outdated as well.
  if currentTS = 0 return 1

  // Same date for both entries? Then consider updated.
  if currentTS = externalTS return 0
  if 'isImport {
    if currentTS = "" return 1
    // As currentTS is referring to the existing source code, this condition checks if
    // it is newer than the external source code.
    return (
      (currentTS ] externalTS) &&
      (currentTS ] lastModified)
    )
  }
  // Otherwise everything is inverted:
  // External files must be newer than the imported source code and newer than their last
  // registry as well.
  return (
    (externalTS ] currentTS) &&
    (externalTS ] lastModified)
  )
}

}


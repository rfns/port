Include portutils

Class Port.SourceControl.Hooks Extends %Studio.SourceControl.Base
{

XData Menu
{
<MenuBase>
<Menu Name="%SourceMenu" Type="0">
<MenuItem Name="%MLExport"/>
<MenuItem Name="%MLExportToXML"/>
<MenuItem Name="%MLExportTests"/> 
<MenuItem Separator="1" />
<MenuItem Name="%MLRemoveClasses"/>
<MenuItem Name="%MLRemoveFiles"/>
<MenuItem Name="%MLRemoveRoutines"/>
<MenuItem Separator="1" />
<MenuItem Name="%MLScanAndFix"/>
<MenuItem Separator="1" />
<MenuItem Name="%MLRunTests"/> 
<MenuItem Separator="1" />
<MenuItem Name="%MLImport"/>
<MenuItem Separator="1" />
<MenuItem Name="%MLForceExport"/>
<MenuItem Name="%MLForceImport"/>
</Menu>
<Menu Name="%SourceContext" Type="1">
<MenuItem Name="%CMLExportActive" />
<MenuItem Name="%CMLImportActive" />
<MenuItem Separator="1" />
<MenuItem Name="%CMLRunActiveTest"/>
</Menu>
</MenuBase>
}

Method OnAfterSave(InternalName As %String) As %Status
{
  #dim exporter As Port.Project.Exporter
  if $get(%importingFromXML, 0) return $$$OK 
  
  set sc = $$$OK
  set projectName = $get(^||Port.Project)
  if projectName [ "Default" || (projectName = "") return sc  
  
  if projectName '= "" { 
    set exportPath = ##class(Port.Configuration).GetWorkspace()    
    set type = ##class(Port.Util).ResolveItemExtension(InternalName)       
    
    if '##class(%File).DirectoryExists($$$NFN(exportPath)) {
      set logLevel = ##class(Port.Configuration).GetLogLevel()
      set sourceExtension = ##class(Port.Configuration).GetSourceExtension()
     
      write "[Port] "_$$$FormatMsg("Port Log Messages", $$$NewWorkspaceDetected, projectName), !
     
      $$$QuitOnError(##class(Port.Project.Manager).Export(exportPath, logLevel, 1,, sourceExtension))
      // Called with do, because we don't want to display errors from it.
      do ##class(Port.Project.Manager).ExportTestSuiteToXML(exportPath) 
      
      return $$$OK
    }
    
    if type '= "PRJ" {
      set sourceExtension = ##class(Port.Configuration).GetSourceExtension()
      set exporter = ##class(Port.Project.Exporter).%New(exportPath, 2)
      set shouldExportAsXML = ##class(Port.Configuration).IsAutoExportXMLEnabled()      
      set ubiquitousList = ##class(Port.Util).ListConflicts(projectName, InternalName)
            
      set exporter.SourceExtension = sourceExtension
      
      if '##class(Port.Util).ExistsInProject(projectName, InternalName) {
        return $$$OK
      }
      
      if ubiquitousList '= "" {
        write !, "[Port] "_$$$FormatMsg("Port Log Messages", $$$ConflictingItemDetected, InternalName, $lfs(ubiquitousList))
        write !, "[Port] "_$$$FormatMsg("Port Log Messages", $$$ConflictingItemDetected2)
      }
      
      if type = "CLS" {
        set sc = exporter.ExportClass(InternalName)
        if ##class(Port.UnitTest.Util).AssertTestableClass(InternalName, .testableClass) {          
          set testPath = ##class(Port.Configuration).GetTestPath()
          set xmlExporter = ##class(Port.Project.XMLExporter).%New(exportPath, 2)
          do xmlExporter.ExportTest($$$NFN(exportPath_"/"_testPath), testableClass, .ssc)          
          set sc = $$$ADDSC(sc, ssc)
        }
      } elseif ##class(Port.Util).IsRoutine(InternalName) {
        write InternalName, !
        set sc = exporter.ExportRoutine(InternalName)
      } elseif type = "PKG" {     
        set sc = exporter.ExportPackage(InternalName)     
      } elseif type '= "" {
        set sc = exporter.ExportWebFile(InternalName)     
      }   
      
      $$$QuitOnError(##class(Log).LogChange(projectName, InternalName))
      if shouldExportAsXML $$$QuitOnError(##class(Port.Project.Manager).ExportToXML(exportPath, 2))      
    }  
  }
  if '##class(Port.Configuration).HasCustomWorkspace(projectName) {
    do ##class(Port.Configuration).SetCustomWorkspace(projectName)
  }
  $$$QuitOnError(##class(Port.SourceControl.ExtendedHooks).Call($this, "OnAfterSave", InternalName)) 
  return sc
}

Method OnBeforeSave(InternalName As %String, Location As %String = "", Object As %RegisteredObject = {$$$NULLOREF}) As %Status
{
  if $get(%importingFromXML, 0) return $$$OK
  set projectName = $get(^||Port.Project)  
  set ext = ##class(Port.Util).ResolveItemExtension(InternalName)
  set isProject = (ext = "PRJ")  
  
  if isProject {
    set projectName = $replace(InternalName, ".PRJ", "")
    set ^||Port.Project = projectName  
    if projectName [ "Default" {
      write "[Port] "_$$$FormatMsg("Port Log Messages", $$$CannotUseDefault), !
      write "[Port] "_$$$FormatMsg("Port Log Messages", $$$CannotUseDefault2), !
      return $$$ERROR($$$CanNotExportDefaultProject, projectName)
    }
  } else {
    set projectsOwningItem = $lts(##class(Port.Util).ListConflicts(projectName, InternalName), $char(10))
    if projectsOwningItem '= "" {
      return $$$PERROR($$$CannotSaveConflictingItems, InternalName, $char(10, 10)_projectsOwningItem, projectName)
    }
  }    

  $$$QuitOnError(##class(Port.SourceControl.ExtendedHooks).Call($this, "OnBeforeSave", InternalName, Location, Object))
  return $$$OK
}

Method UserAction(Type As %Integer, Name As %String, InternalName As %String, SelectedText As %String, ByRef Action As %String, ByRef Target As %String, ByRef Msg As %String, ByRef Reload As %Boolean) As %Status
{
  
  set name = $piece(Name, ",", 2)
  set isContextual = ($piece(Name, ",", 1) = "%SourceContext")
  // We must know if the user is importing from a XML and prevent it from realizing certain tasks automatically.
  set %importingFromXML = (Name = 6)
  
  if $data(^||Port.Project) {
    set projectName = ^||Port.Project
    if projectName [ "Default" return $$$OK
    set fullPath = ##class(Port.Util).GetItemSourcePathFromWorkspace(InternalName)
    set projectPath = ##class(Port.Configuration).GetWorkspace()
    set testPath = ##class(Port.Configuration).GetTestPath()
    set logLevel = ##class(Port.Configuration).GetLogLevel()
    set shouldExportAsXML = ##class(Port.Configuration).IsAutoExportXMLEnabled()
    set sourceExtension = ##class(Port.Configuration).GetSourceExtension()
    set ignoredPaths = ##class(Port.Util).GetIgnoredPaths(projectPath)
    
    if name = "%MLExport" {
      set shouldOverwrite = '##class(Port.Configuration).IsSameSourceExtension()
      if shouldOverwrite do ##class(Port.Configuration).TrackActiveExtension()      
      $$$QuitOnError(##class(Port.Project.Manager).Export(projectPath, logLevel, shouldOverwrite, ignoredPaths, sourceExtension))
      if shouldExportAsXML $$$QuitOnError(##class(Port.Project.Manager).ExportToXML(projectPath))      
      return $$$OK
    }
    if name = "%MLExportToXML" {
      return ##class(Port.Project.Manager).ExportToXML(projectPath)
    }
    if name = "%MLExportTests" {
      return ##class(Port.Project.Manager).ExportTestSuiteToXML(projectPath)
    }
    if name = "%MLRunTests" && (projectPath '= "") {      
      $$$QuitOnError(##class(Port.UnitTest.Manager).RunTest(testPath, "/recursive/run/noload/nodelete"))
    }       
    if name = "%MLImport" {
      $$$QuitOnError(##class(Port.Project.Manager).Import(projectPath, logLevel, 0, 0,,sourceExtension))
    }
    if name = "%MLRemoveClasses" {
      $$$QuitOnError(##class(Port.Project.Manager).RemoveItemsByType(projectName, "CLS"))
      return ##class(Log).Synchronize()
    }
    if name = "%MLRemoveFiles" {
      $$$QuitOnError(##class(Port.Project.Manager).RemoveItemsByType(projectName, "CSP"))
      return ##class(Log).Synchronize()
    }
    if name = "%MLRemoveRoutines" {
      $$$QuitOnError(##class(Port.Project.Manager).RemoveItemsByType(projectName, "MAC"))
      return ##class(Log).Synchronize()
    }
    if name = "%MLScanAndFix" {
      $$$QuitOnError(##class(Port.Project.Manager).RemoveInvalidItems(projectName))
      return ##class(Log).Synchronize()     
    }
    
    if name = "%CMLExportActive" {
      if $$$ucase(InternalName) '= ($$$ucase(projectName_".PRJ")) {
        set exporter = ##class(Port.Project.Exporter).%New(projectPath)
        set exporter.Overwrite = 1
        set exporter.SourceExtension = sourceExtension
        set internalName = InternalName
        if $extract(InternalName, 1) = "/" {
          set internalName = $extract(InternalName, 2, *)
        }
        $$$QuitOnError(exporter.ExportItem(internalName))
        $$$QuitOnError(##class(Log).LogChange(projectName, internalName))
        if shouldExportAsXML $$$QuitOnError(##class(Port.Project.Manager).ExportToXML(projectPath))
      } else {
        set ignoredPaths = ##class(Port.Util).GetIgnoredPaths(projectPath)
        return ##class(Port.Project.Manager).Export(projectPath, logLevel, 1)
      }
    }
    
    if name = "%CMLImportActive" {
      if $$$ucase(InternalName) = ($$$ucase(projectName_".PRJ")) {
        return ##class(Port.Project.Manager).Import(projectPath, logLevel, 0, 1, ignoredPaths, sourceExtension)
      } else {
        return $$$OK 
      }
    }
    
    if name = "%CMLRunActiveTest" {
      set testable = ##class(Port.UnitTest.Util).AssertTestableClass(InternalName, .testableClass)
      if testable {
        $$$QuitOnError(##class(Port.UnitTest.Manager).RunTest(##class(Port.UnitTest.Util).GetTestPathForClass(testableClass), "/norecursive/run/noload/nodelete"))
      }
    }
    
    if name = "%MLForceExport" {
      set shouldOverwrite = '##class(Port.Configuration).IsSameSourceExtension()
      if shouldOverwrite do ##class(Port.Configuration).TrackActiveExtension()
      $$$QuitOnError(##class(Port.Project.Manager).Export(projectPath, logLevel, 1, ignoredPaths, sourceExtension))
      if shouldExportAsXML $$$QuitOnError(##class(Port.Project.Manager).ExportToXML(projectPath))
      if '##class(Port.Configuration).HasCustomWorkspace(projectName) { 
        do ##class(Port.Configuration).SetCustomWorkspace(projectName)
      }
    }
    
    if name = "%MLForceImport" {
      return ##class(Port.Project.Manager).Import(projectPath, logLevel, 0, 1, ignoredPaths, sourceExtension)
    }    
  }
  $$$QuitOnError(##class(Port.SourceControl.ExtendedHooks).Call($this, "UserAction",  Type, Name, InternalName, SelectedText, .Action, .Target, .Msg, .Reload))
  return $$$OK
}

Method AfterUserAction(Type As %Integer, Name As %String, InternalName As %String, Answer As %Integer, Msg As %String = "", ByRef Reload As %Boolean) As %Status
{
  return ##class(Port.SourceControl.ExtendedHooks).Call($this, "AfterUserAction", Type, Name, InternalName, Answer, .Msg, .Reload)
}

Method OnMenuItem(MenuName As %String, InternalName As %String, SelectedText As %String, ByRef Enabled As %Boolean, ByRef DisplayName As %String) As %Status
{
  
  set menu=$piece(MenuName,","),name=$piece(MenuName,",",2)
  If menu'="%SourceMenu",menu'="%SourceContext" Quit $$$OK
  set isContextual = (menu = "%SourceContext")
  set domain = "Port Menu Labels"
  
  if 'isContextual {
    set code = $case(name, 
      "%MLExport": $$$MLExport,
      "%MLExportToXML": $$$MLExportToXML,
      "%MLExportTests": $$$MLExportTests,
      "%MLRemoveClasses": $$$MLRemoveClasses,
      "%MLRemoveFiles": $$$MLRemoveFiles,
      "%MLRemoveRoutines": $$$MLRemoveRoutines,
      "%MLScanAndFix": $$$MLScanAndFix,
      "%MLRunTests": $$$MLRunTests,
      "%MLImport": $$$MLImport,
      "%MLForceExport": $$$MLForceExport, 
      "%MLForceImport": $$$MLForceImport,
      : ""
     )
  } else {
    set domain = "Port Context Menu Labels"
    set code = $case(name, 
      "%CMLExportActive": $$$CMLExportActive,
      "%CMLImportActive": $$$CMLImportActive,
      "%CMLRunActiveTest": $$$CMLRunActiveTest,
      : ""
    )          
  }
  
  if code '= "" {
    // We can only change the text if we find it, otherwise we leave the Studio decide what to show.
    set DisplayName = $$$FormatMsg(domain, code)
  }
  
  if name = "%CMLRunActiveTest" {
    set Enabled = 
      ##class(Port.Util).ExistsInProject(^||Port.Project, InternalName) &&
      ##class(Port.UnitTest.Util).AssertTestableClass(InternalName)
  } 
  
  set isProjectOpened = ($get(^||Port.Project, "Default") '[ "Default")
  if 'isProjectOpened {
    set Enabled = 0
  }
  Quit $$$OK
}

/// Called after the compile of the item is done.
Method OnAfterCompile(InternalName As %String) As %Status
{
  if $get(%importingFromXML, 0) return $$$OK
  set projectName = $get(^||Port.Project)
  set sc = $$$OK
  
  if projectName '= "" && (projectName '[ "Default") {
    set projectPath = ##class(Port.Configuration).GetWorkspace()
    set type = ##class(Port.Util).ResolveItemExtension(InternalName)
    set xmlExporter = ##class(Port.Project.XMLExporter).%New(projectPath)
    
    if type = "CLS" {     
      set testPath = ##class(Port.Configuration).GetTestPath()      
      set shouldRunTest = (
        ##class(Port.Configuration).IsTestOnDemandEnabled() &&
        ##class(Port.UnitTest.Util).AssertTestableClass(InternalName, .testableClass) &&
        ##class(%File).DirectoryExists(projectPath_"/"_testPath)        
      )
      if shouldRunTest {
       $$$QuitOnError(xmlExporter.ExportTest(projectPath, testableClass))
       $$$QuitOnError(##class(Port.UnitTest.Manager).RunTest(##class(Port.UnitTest.Util).GetTestPathForClass(testableClass), "/norecursive/run/noload/nodelete"))
      } 
    }
  }
  $$$QuitOnError(##class(Port.SourceControl.ExtendedHooks).Call($this, "OnAfterCompile",  InternalName))
  return $$$OK
}

Method OnBeforeDelete(InternalName As %String) As %Status
{
  // This is used to prevent orphan workspace entries.
  if (InternalName?1".PRJ") {
    set projectName = $piece(InternalName, ".", 1, *-1)
    do ##class(Port.Configuration).RemoveCustomWorkspace(projectName)
  }
  $$$QuitOnError(##class(Port.SourceControl.ExtendedHooks).Call($this, "OnBeforeDelete",  InternalName))
  return $$$OK
}

Method OnBeforeLoad(InternalName As %String) As %Status
{
  set isProject = (##class(Port.Util).ResolveItemExtension(InternalName) = "PRJ")
  
  // Port normally uses its own project global to track the opened project and stop %Studio.Project methods from disrupting the source control instance.
  if isProject {
    set ^||Port.Project = $piece(InternalName, ".", 1, *-1)  
  } elseif '$data(^||Port.Project) {
    set ^||Port.Project = $get(^||%Studio.Project)
  }
   
  set projectName = ^||Port.Project
      
  if projectName '= "" && (projectName [ "Default") {
    write "[Port] "_$$$FormatMsg("Port Log Messages", $$$CannotUseDefault), !
    write "[Port] "_$$$FormatMsg("Port Log Messages", $$$CannotUseDefault2), !
  }  
  
  set ubiquitousList = ##class(Port.Util).ListConflicts(projectName, InternalName)
  if ubiquitousList '= "" {
    write !, "[Port] "_$$$FormatMsg("Port Log Messages", $$$ConflictingItemDetected, InternalName, $lts(ubiquitousList, ", "))
    write !, "[Port] "_$$$FormatMsg("Port Log Messages", $$$ConflictingItemDetected2), !
  }
  $$$QuitOnError(##class(Port.SourceControl.ExtendedHooks).Call($this, "OnBeforeLoad",  InternalName))
  return $$$OK
}

ClassMethod OnAfterAllClassCompile(List As %String, Level As %Integer, ByRef qstruct As %String, Status As %Status) As %Status
{
  $$$QuitOnError(##super(.List, .Level, .qstruct, .Status))
  return ##class(Port.SourceControl.ExtendedHooks).Call($this, "OnAfterAllClassCompile", .List, Level, .qstruct, Status)
}

Method OnAfterClassCompile(List As %String, Level As %Integer, ByRef qstruct As %String, Status As %Status) As %Status
{
  return ##class(Port.SourceControl.ExtendedHooks).Call($this, "OnAfterClassCompile", .List, Level, qstruct, Status)
}

/// Called after an item is deleted.
Method OnAfterDelete(InternalName As %String) As %Status
{
  return ##class(Port.SourceControl.ExtendedHooks).Call($this, "OnAfterDelete", InternalName)
}

Method OnAfterLoad(InternalName As %String, Object As %RegisteredObject = {$$$NULLOREF}) As %Status
{
  return ##class(Port.SourceControl.ExtendedHooks).Call($this, "OnAfterLoad", InternalName)
}

Method OnAfterStorage(InternalName As %String, Location As %String = "") As %Status
{
  return ##class(Port.SourceControl.ExtendedHooks).Call($this, "OnAfterStorage", InternalName, Location)
}

ClassMethod OnBeforeAllClassCompile(List As %String, Level As %Integer, ByRef qstruct As %String) As %Status
{
  $$$QuitOnError(##super(.List, Level, .qstruct))
  return ##class(Port.SourceControl.ExtendedHooks).Call($this, "OnBeforeAllClassCompile", .List, Level, qstruct)
}

Method OnBeforeClassCompile(List As %String, Level As %Integer, ByRef qstruct As %String) As %Status
{
  return ##class(Port.SourceControl.ExtendedHooks).Call($this, "OnBeforeClassCompile", .List, Level, qstruct)
}

Method OnBeforeCompile(InternalName As %String, ByRef qstruct As %String) As %Status
{
  return ##class(Port.SourceControl.ExtendedHooks).Call($this, "OnBeforeCompile", InternalName, qstruct)
}

Method OnBeforeTimestamp(InternalName As %String)
{
  return ##class(Port.SourceControl.ExtendedHooks).Call($this, "OnBeforeTimestamp", InternalName)
}

}


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
  set projectName = $get(^||%Studio.Project)
  set sc = $$$OK
  if projectName '= "" && (projectName '[ "Default") {
    set exportPath = ##class(Config).GetWorkspace()
    set type = ##class(Port.Project.Helper).GetItemExtension(InternalName)    
    
    if type '= "PRJ" {      
      set sourceExtension = ##class(Config).GetSourceExtension()
      set exporter = ##class(Port.Project.Exporter).%New(exportPath, 2)
      set itemName = ##class(Util).ResolveInternalName(InternalName)           
      set shouldExportAsXML = ##class(Config).IsAutoExportXMLEnabled()
      set ubiquitousList = ##class(Port.Project.Helper).UbiquitousInProject(projectName, InternalName)
      
      set exporter.SourceExtension = sourceExtension
      set exporter.LogLevel = 2
      
      if '##class(Port.Project.Helper).ExistsInProject(projectName, InternalName) {
        quit $$$OK
      }
      
      if ubiquitousList '= "" {
        write !, "Port: "_$$$FormatMsg("Port Log Messages", $$$UbiquitousItemDetected, InternalName, $lfs(ubiquitousList))
        write !, "Port: "_$$$FormatMsg("Port Log Messages", $$$UbiquitousItemDetected2)
      }
      
      if type = "CLS" {
        set sc = exporter.ExportClass(itemName)
      } elseif ##class(Port.Project.Helper).IsRoutine(InternalName) {
        set sc = exporter.ExportRoutine(InternalName)
      } elseif type = "PKG" {     
        set sc = exporter.ExportPackage(itemName)     
      } elseif type '= "" {
        set sc = exporter.ExportWebFile(itemName)     
      }
      if '%importingFromXML {        
        $$$QuitOnError(##class(Log).LogChange(projectName, InternalName))
        if shouldExportAsXML $$$QuitOnError(##class(Port.Project.Manager).ExportToXML(exportPath, 2))
      }
    }  
  } else {
    
  }
  if '##class(Config).HasCustomWorkspace(projectName) { 
    do ##class(Config).SetCustomWorkspace(projectName)
  }   
  quit sc
}

Method OnBeforeSave() As %Status
{
  set projectName = $get(^||%Studio.Project)
  
  if projectName '= "" && (projectName [ "Default") {
    write "Port: "_$$$FormatMsg("Port Log Messages", $$$CannotUseDefault), !
    write "Port: "_$$$FormatMsg("Port Log Messages", $$$CannotUseDefault2), !
  }
  quit $$$OK
}

Method UserAction(Type As %Integer, Name As %String, InternalName As %String, SelectedText As %String, ByRef Action As %String, ByRef Target As %String, ByRef Msg As %String, ByRef Reload As %Boolean) As %Status
{
  set name = $piece(Name, ",", 2)
  set isContextual = ($piece(Name, ",", 1) = "%SourceContext")
  // We must know if the user is importing from a XML and prevent it from being exported.
  set %importingFromXML = (Name = 6)
  
  if $data(^||%Studio.Project) {
    set projectName = ^||%Studio.Project
    set fullPath = ##class(Util).GetFullItemPath(InternalName)
    set itemName = ##class(Util).ResolveInternalName(InternalName)
    set projectPath = ##class(Config).GetWorkspace()
    set testPath = ##class(Config).GetTestPath()
    set logLevel = ##class(Config).GetLogLevel()
    set shouldExportAsXML = ##class(Config).IsAutoExportXMLEnabled()
    set sourceExtension = ##class(Config).GetSourceExtension()
    set ignoredPaths = ##class(Util).GetIgnoredPaths(projectPath)
    
    if name = "%MLExport" {
      set shouldOverwrite = '##class(Config).IsSameSourceExtension()
      if shouldOverwrite do ##class(Config).TrackActiveExtension()      
      $$$QuitOnError(##class(Port.Project.Manager).Export(projectPath, logLevel, shouldOverwrite, ignoredPaths, sourceExtension))
      if shouldExportAsXML $$$QuitOnError(##class(Port.Project.Manager).ExportToXML(projectPath))      
      quit $$$OK
    }
    if name = "%MLExportToXML" {
      quit ##class(Port.Project.Manager).ExportToXML(projectPath)
    }
    if name = "%MLExportTests" {
      quit ##class(Port.Project.Manager).ExportTestSuiteToXML(projectPath)
    }
    if name = "%MLRunTests" && (projectPath '= "") {
      do ##class(%File).RemoveDirectoryTree(projectPath_"/"_testPath)
      $$$QuitOnError(##class(Port.Project.Manager).ExportTestSuiteToXML(projectPath))
      $$$QuitOnError(##class(Port.UnitTest.Manager).RunTest(testPath, "/recursive/load/run/nodelete"))
    }       
    if name = "%MLImport" {
      $$$QuitOnError(##class(Port.Project.Manager).Import(projectPath, logLevel, 0, 0,,sourceExtension))
    }
    if name = "%MLRemoveClasses" {
      $$$QuitOnError(##class(Port.Project.Manager).RemoveItemsByType(projectName, "CLS"))
      quit ##class(Log).Synchronize()
    }
    if name = "%MLRemoveFiles" {
      $$$QuitOnError(##class(Port.Project.Manager).RemoveItemsByType(projectName, "CSP"))
      quit ##class(Log).Synchronize()
    }
    if name = "%MLRemoveRoutines" {
      $$$QuitOnError(##class(Port.Project.Manager).RemoveItemsByType(projectName, "MAC"))
      quit ##class(Log).Synchronize()
    }
    if name = "%MLScanAndFix" {
      $$$QuitOnError(##class(Port.Project.Manager).RemoveInvalidItems(projectName))
      quit ##class(Log).Synchronize()     
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
        set ignoredPaths = ##class(Util).GetIgnoredPaths(projectPath)
        quit ##class(Port.Project.Manager).Export(projectPath, logLevel, 1)
      }
    }
    
    if name = "%CMLImportActive" {
      if $$$ucase(InternalName) = ($$$ucase(projectName_".PRJ")) {
        quit ##class(Port.Project.Manager).Import(projectPath, logLevel, 0, 1, ignoredPaths, sourceExtension)
      } else {
        quit ##class(Port.Project.Manager).ImportPartial(projectPath, fullPath, logLevel, 0, 1, ignoredPaths, sourceExtension)
      }
    }
    
    if name = "%CMLRunActiveTest" {
      set testable = ##class(Port.UnitTest.Util).AssertTestableClass(itemName, .testableClass)
      if testable {
        $$$QuitOnError(##class(Port.UnitTest.Manager).DebugLoadTestSuite(testPath))
        quit ##class(Port.UnitTest.Manager).DebugRunTestCase(testPath, testableClass)
      }
    }
    
    if name = "%MLForceExport" {
      set shouldOverwrite = '##class(Config).IsSameSourceExtension()
      if shouldOverwrite do ##class(Config).TrackActiveExtension()
      $$$QuitOnError(##class(Port.Project.Manager).Export(projectPath, logLevel, 1, ignoredPaths, sourceExtension))
      if shouldExportAsXML $$$QuitOnError(##class(Port.Project.Manager).ExportToXML(projectPath))
      if '##class(Config).HasCustomWorkspace(projectName) { 
        do ##class(Config).SetCustomWorkspace(projectName)
      }
    }
    
    if name = "%MLForceImport" {
      quit ##class(Port.Project.Manager).Import(projectPath, logLevel, 0, 1, ignoredPaths, sourceExtension)
    }    
  }
  quit $$$OK
}

Method OnMenuItem(MenuName As %String, InternalName As %String, SelectedText As %String, ByRef Enabled As %Boolean, ByRef DisplayName As %String) As %Status
{
  
  set itemName = ##class(Port.SourceControl.Util).ResolveInternalName(InternalName)
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
      ##class(Port.Project.Helper).ExistsInProject(^||%Studio.Project, InternalName) &&
      ##class(Port.UnitTest.Util).AssertTestableClass(itemName)
  } 
  
  set isProjectOpened = ($get(^||%Studio.Project, "Default") '[ "Default")
  if 'isProjectOpened {
    set Enabled = 0
  }
  Quit $$$OK
}

/// Called after the compile of the item is done.
Method OnAfterCompile(InternalName As %String) As %Status
{
  if $get(%importingFromXML, 0) quit $$$OK
  set projectName = $get(^||%Studio.Project)
  set sc = $$$OK
  
  if projectName '= "" && (projectName '[ "Default") {
    set projectPath = ##class(Config).GetWorkspace()
    set itemName = ##class(Util).ResolveInternalName(InternalName)
    set type = $$$ucase($piece(InternalName, ".", *))
    set xmlExporter = ##class(Port.Project.XMLExporter).%New(projectPath)
    
    if type = "CLS" {     
      set testPath = ##class(Config).GetTestPath()      
      set shouldRunTest = (
        ##class(Config).IsTestOnDemandEnabled() &&
        ##class(Port.UniTest.Util).AssertTestableClass(itemName, .testableClass) &&
        ##class(%File).DirectoryExists(projectPath_"/"_testPath)        
      )
      if shouldRunTest {
        set activeTestableClass = InternalName
        
        do ##class(%RoutineMgr).TS(activeTestableClass, .act, .isActiveUpToDate)        
        do ##class(%RoutineMgr).TS(testableClass_".CLS", .tct, .isTestUpToDate)
                
        if 'isTestUpToDate {
          set filePath = ##class(Port.Project.Helper).ClassToFile(projectPath_"/"_testPath, testableClass)
          $$$QuitOnError(xmlExporter.ExportTest(projectPath, testableClass))
          $$$QuitOnError(##class(Port.UnitTest.Manager).DebugLoadTestSuite(testPath, "/nodisplay"))
        }       
        $$$QuitOnError(##class(Port.UnitTest.Manager).DebugRunTestCase(testPath, testableClass))   
      } 
    }
  }
  quit $$$OK
}

Method OnBeforeDelete(InternalName As %String) As %Status
{
  // This is used to prevent orphan workspaces entries.
  if (InternalName?1".PRJ") {
    set projectName = $piece(InternalName, ".", 1, *-1)
    do ##class(Config).RemoveCustomWorkspace(projectName)
  }
  quit $$$OK
}

/// This is called before the actual load of data to give the chance
/// to load the item from an external format.
Method OnBeforeLoad(InternalName As %String) As %Status
{
  set projectName = $get(^||%Studio.Project)
  set ubiquitousList = ##class(Port.Project.Helper).UbiquitousInProject(projectName, InternalName)
  if ubiquitousList '= "" {
    write !, "Port: "_$$$FormatMsg("Port Log Messages", $$$UbiquitousItemDetected, InternalName, $lts(ubiquitousList, ", "))
    write !, "Port: "_$$$FormatMsg("Port Log Messages", $$$UbiquitousItemDetected2)
  }
  quit ..OnBeforeSave()
}

}


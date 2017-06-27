Class Port.SourceControl.Hooks Extends %Studio.SourceControl.Base
{

XData Menu
{
<MenuBase>
<Menu Name="%SourceMenu" Type="0">
<MenuItem Name="%ExportProject"/>
<MenuItem Name="%ExportProjectToXML"/>
<MenuItem Name="%ExportTestSuiteToXML"/>
<MenuItem Separator="1" />
<MenuItem Name="%RemoveProjectClasses"/>
<MenuItem Name="%RemoveProjectWebFiles"/>
<MenuItem Name="%RemoveProjectRoutines"/>
<MenuItem Separator="1" />
<MenuItem Name="%RemoveInvalidItems"/>
<MenuItem Separator="1" />
<MenuItem Name="%RunTestSuite"/> 
<MenuItem Separator="1" />
<MenuItem Name="%ImportProject"/>
<MenuItem Separator="1" />
<MenuItem Name="%ForceExportProject"/>
<MenuItem Name="%ForceImportProject"/>
</Menu>
<Menu Name="%SourceContext" Type="1">
<MenuItem Name="%ExportActiveItem" />
<MenuItem Name="%ImportActiveItem" />
<MenuItem Separator="1" />
<MenuItem Name="%RunActiveItemTest"/>
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
      
      set exporter.SourceExtension = sourceExtension
      
      $$$QuitOnError(exporter.IsProjectMember(InternalName, .isMember))
      if 'isMember quit $$$OK
      
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
        if shouldExportAsXML $$$QuitOnError(##class(Port.Project.Manager).ExportToXML(exportPath))
      }
    }  
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
    write "WARNING: This source control enforces the policy of using named projects!", !
    write "WARNING: Which means that 'Default' projects are not tracked or exportable using this tool.", !
    write "WARNING: In order to export the project, you're obliged to change the name to something else than 'Default'."
  }
  quit $$$OK
}

Method UserAction(Type As %Integer, Name As %String, InternalName As %String, SelectedText As %String, ByRef Action As %String, ByRef Target As %String, ByRef Msg As %String, ByRef Reload As %Boolean) As %Status
{
  set name = $piece(Name, ",", 2)
  set isContextual = ($piece(Name, ",", 1) = "%SourceContext")
  // We must know if the user is importing from an XML and prevent the XML from being exported.
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
    
    if name = "%ExportProject" {
      set shouldOverwrite = '##class(Config).IsSameSourceExtension()
      if shouldOverwrite do ##class(Config).TrackActiveExtension()      
      $$$QuitOnError(##class(Port.Project.Manager).Export(projectPath, logLevel, shouldOverwrite, ignoredPaths, sourceExtension))
      if shouldExportAsXML $$$QuitOnError(##class(Port.Project.Manager).ExportToXML(projectPath))      
      quit $$$OK
    }
    if name = "%ExportProjectToXML" {
      quit ##class(Port.Project.Manager).ExportToXML(projectPath)
    }
    if name = "%ExportTestSuiteToXML" {
      quit ##class(Port.Project.Manager).ExportTestSuiteToXML(projectPath)
    }
    if name = "%RunTestSuite" && (projectPath '= "") {
      do ##class(%File).RemoveDirectoryTree(projectPath_"/"_testPath)
      $$$QuitOnError(##class(Port.Project.Manager).ExportTestSuiteToXML(projectPath))
      $$$QuitOnError(##class(Port.UnitTest.Manager).RunTest(testPath, "/recursive/load/run/nodelete"))
    }       
    if name = "%ImportProject" {
      $$$QuitOnError(##class(Port.Project.Manager).Import(projectPath, logLevel, 0, 0,,sourceExtension))
    }
    if name = "%RemoveProjectClasses" {
      $$$QuitOnError(##class(Port.Project.Manager).RemoveItemsByType(projectName, "CLS"))
      quit ##class(Log).Synchronize()
    }
    if name = "%RemoveProjectWebFiles" {
      $$$QuitOnError(##class(Port.Project.Manager).RemoveItemsByType(projectName, "CSP"))
      quit ##class(Log).Synchronize()
    }
    if name = "%RemoveProjectRoutines" {
      $$$QuitOnError(##class(Port.Project.Manager).RemoveItemsByType(projectName, "MAC"))
      quit ##class(Log).Synchronize()
    }
    if name = "%RemoveInvalidItems" {
      $$$QuitOnError(##class(Port.Project.Manager).RemoveInvalidItems(projectName))
      quit ##class(Log).Synchronize()     
    }
    
    if name = "%ExportActiveItem" {
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
    
    if name = "%ImportActiveItem" {
      if $$$ucase(InternalName) = ($$$ucase(projectName_".PRJ")) {
        quit ##class(Port.Project.Manager).Import(projectPath, logLevel, 0, 1, ignoredPaths, sourceExtension)
      } else {       
        quit ##class(Port.Project.Manager).ImportPartial(projectPath, fullPath, logLevel, 0, 1, ignoredPaths, sourceExtension)
      }
    }
    
    if name = "%RunActiveItemTest" {
      set testable = 
        ##class(Util).AssertTestableClass(itemName, .testableClass) &&
        ##class(Port.Project.XMLExporter).IsUnitTestClass(itemName)
      if testable {
        $$$QuitOnError(##class(Port.UnitTest.Manager).DebugLoadTestSuite(testPath))
        quit ##class(Port.UnitTest.Manager).DebugRunTestCase(testPath, testableClass)
      }
    }
    
    if name = "%ForceExportProject" {
      set shouldOverwrite = '##class(Config).IsSameSourceExtension()
      if shouldOverwrite do ##class(Config).TrackActiveExtension()
      $$$QuitOnError(##class(Port.Project.Manager).Export(projectPath, logLevel, 1, ignoredPaths, sourceExtension))
      if shouldExportAsXML $$$QuitOnError(##class(Port.Project.Manager).ExportToXML(projectPath))
      if '##class(Config).HasCustomWorkspace(projectName) { 
        do ##class(Config).SetCustomWorkspace(projectName)
      }
    }
    
    if name = "%ForceImportProject" {
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
  if name = "%ExportProject" {
    set DisplayName = "Export Current Project"
  } 
  if name = "%ExportProjectToXML" {
    set DisplayName = "Export Current Project to XML"
  } 
  if name = "%ExportTestSuiteToXML" {
    set DisplayName = "Export Project Test Suites to XML"
  }   
  if name = "%ImportProject" {
    set DisplayName = "Import Project"    
  } 
  if name = "%RemoveProjectClasses" {
    set DisplayName = "Remove All Classes from the Current Project"
  } 
  if name = "%RemoveProjectWebFiles" {
    set DisplayName = "Remove All Files from the Current Project"
  } 
  if name = "%RemoveProjectRoutines" {
    set DisplayName = "Remove All Routines from the Current Project"
  } 
  if name = "%RemoveInvalidItems" {
    set DisplayName = "Remove Invalid Items from the Current Project"
  }
  
  if name= "%RunTestSuite" {
    set DisplayName = "Run Test Suites"
  }
  
  if name = "%RunActiveItemTest" {
    set DisplayName = "Run Tests Associated to this Item"
    set Enabled = ##class(Util).AssertTestableClass(itemName) && ##class(Port.Project.XMLExporter).IsUnitTestClass(itemName)
  } 
  
  if name = "%ExportActiveItem" {
    set DisplayName = "Export This Item"
  }
  
  if name ="%ImportActiveItem" {
    set DisplayName = "Import This Item"
  }
  
  if name = "%ForceImportProject" {
    set DisplayName = "Force Current Project to be Imported"
  }
  
  if name = "%ForceExportProject" {
    set DisplayName = "Force Current Project to be Exported"
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
    set type = $$$ucase($piece(InternalName, ".", $length(InternalName, ".")))
    set xmlExporter = ##class(Port.Project.XMLExporter).%New(projectPath)
    
    if type = "CLS" {     
      set testPath = ##class(Config).GetTestPath()      
      set shouldRunTest = (
        ##class(Config).IsTestOnDemandEnabled() &&
        ##class(Util).AssertTestableClass(itemName, .testableClass) &&
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

/// Called before an item is deleted. Returning an error code prevents the delete from occuring.
Method OnBeforeDelete(InternalName As %String) As %Status
{
  
  if (InternalName?1".PRJ") {
    set projectName = $piece(InternalName, ".", 1, *-1)
    do ##class(Config).RemoveCustomWorkspace(projectName)
  }
  quit $$$OK
}

}


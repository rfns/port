Class Port.TestUtils.MockProject Extends %RegisteredObject
{

Parameter MOCKNAME = "Faux";

Property Project As %Studio.Project;

Property ItemsList As %String [ MultiDimensional ];

Property FixtureDirectory As %String;

Method %OnNew(fixtureDir As %String, withFauxFiles As %Boolean = 0, addToProject As %Boolean = 0) As %Status
{
  set ..FixtureDirectory = fixtureDir
  $$$QuitOnError(..Create(withFauxFiles, addToProject))
  return $$$OK
}

Method %OnClose() As %Status
{
  $$$QuitOnError(..Delete())
  return $$$OK
}

Method Delete() As %Status
{
  if ##class(%Studio.Project).%ExistsId(..#MOCKNAME) {    
    $$$QuitOnError(##class(%Studio.Project).Delete(..#MOCKNAME))
    $$$QuitOnError(..DisposeFauxItems())
  }  
  return $$$OK
}

Method Create(withFauxFiles As %Boolean = 0, addToProject As %Boolean = 0) As %Status
{
  
  $$$QuitOnError(..Delete())
  set ..Project = ##class(%Studio.Project).%New(..#MOCKNAME)
  set ..Project.Name = ..#MOCKNAME
  if withFauxFiles  $$$QuitOnError(..CreateFauxItems())
  if addToProject   $$$QuitOnError(..AddItemsToProject())
  set sc = ..Project.%Save()
  $$$QuitOnError(sc)
  return $$$OK
}

Method CreateFauxItems() As %Status
{
  
  #define TAB $char(9)
  #define GetAbsolutePath(%relative) ##class(%File).Normalize($System.Util.InstallDirectory, %relative)    
  set sc = $$$OK
  
  set fauxItems = 13
  set fauxItems(1)  = "Faux.Class.cls"
  set fauxItems(2)  = "fauxjs.js"
  set fauxItems(3)  = "fauxcss.css"
  set fauxItems(4)  = "fauxinc.inc"
  set fauxItems(5)  = "fauxmac.mac"
  set fauxItems(6)  = "fauxint.int"
  set fauxItems(7)  = "fauxmvi.mvi"
  set fauxItems(8)  = "fauxmvb.mvb"
  set fauxItems(9)  = "fauxbas.bas"
  set fauxItems(10) = "fauxdfi.dfi"
  set fauxItems(11) = "fauxcsp.csp"
  set fauxItems(12) = "fauxcsr.csr"
  set fauxItems(13) = "fauxhtml.html"
  
  for i=1:1:fauxItems {    
    set contentType = 0       
    set name = fauxItems(i)
    set ext = $piece(name, ".", *)
    set destination = name
    set absoluteFilePath = ##class(%File).NormalizeFilename(..FixtureDirectory_"/"_name)
    if '##class(%File).Exists(absoluteFilePath) continue
    if $lf($lfs("inc,mac,int,dfi,mvi,mvb,bas"), ext) {
      set file = ##class(%FileCharacterStream).%New()
      set file.Filename = absoluteFilePath
      if ##class(%RoutineMgr).Exists(name) {
        do ##class(%RoutineMgr).Delete(name)
      }
      set routine = ##class(%RoutineMgr).%OpenId(name)     
      set sc = routine.Code.CopyFrom(file)
      if $$$ISERR(sc) quit
      set sc = routine.Code.%Save()
      if $$$ISERR(sc) quit
      set routine = ""
      set contentType = 1
    } elseif ext = "cls" {
      set sc = ##class(%Compiler.UDL.TextServices).SetTextFromFile($namespace, ##class(%File).GetFilename(absoluteFilePath), absoluteFilePath)
      if $$$ISERR(sc) quit
    } else {
      set name = $extract($System.CSP.GetDefaultApp($namespace)_"/"_name, 2, *)
      set destination = ##class(Port.Project.Helper).CSPToAbsoluteAppPath(name)
      set sc = ##class(%File).CopyFile(absoluteFilePath, destination, 1, .o)
      if 'sc quit
      set contentType = 2
    }
    set i%ItemsList = $increment(i%ItemsList)
    set i%ItemsList(destination) = contentType
    set file = ""
  }
  return sc
}

Method DisposeFauxItems() As %Status
{
  if $data(i%ItemsList) return $$$OK
  set name = ""
  for {
    set name = $order(i%ItemsList(name), 1, type)
    quit:name=""
    
    if type = 1 do ##class(%Routine).Delete(name)
    if type = 2 do $System.OBJ.Delete(name)
    if type = 3 do ##class(%File).Delete($System.Util.InstallDirectory()_"/csp/"_$$$lcase($namespace)_"/name")
  }
  return $$$OK
}

Method AddItemsToProject() As %Status
{
  set name = ""
  for {    
    set name = $order(i%ItemsList(name))
    quit:name=""
    
    do ..Project.AddItem(name)
  }
  return $$$OK
}

}


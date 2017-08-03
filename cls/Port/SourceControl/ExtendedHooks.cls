Include portutils

Class Port.SourceControl.ExtendedHooks [ Abstract ]
{

ClassMethod Call(sourceControl As %Studio.Extension.Base, hookName As %String = "", parameters... As %String) As %Status [ Internal, ProcedureBlock = 0 ]
{
  new sc, content, implementer, alreadyRedirected, 
      isNewLineTerminator, currentMnemonic, 
      childSC, expectingContent, firstLine, s
  
  set sc = $$$OK
  set s = ""
  set childSC = $$$OK
  set implementer = ##class(Port.Configuration).GetExtendedHooksImplementer() 
  set alreadyRedirected = ##class(%Device).ReDirectIO()
  set expectingContent = 0
  set firstLine = ""
  
  if '##class(%Dictionary.CompiledMethod).%ExistsId(implementer_"||"_hookName) return sc 
  set content = ##class(%Stream.GlobalBinary).%New() 
  
  if implementer '= "" { 
    write !, "[Port] "_$$$FormatMsg("Port Log Messages", $$$RunningCustomHook, hookName, implementer)
    
    try {
      set currentMnemonic = "^"_##class(%Device).GetMnemonicRoutine()
      use $io::("^"_$zname)
      do ##class(%Device).ReDirectIO(1)
      set sc = $classmethod(implementer, hookName, sourceControl, parameters...)
    } catch ex {
      set content = "" 
      set sc = ex.AsStatus() 
    }
  }
  
  if alreadyRedirected { 
    do ##class(%Device).ReDirectIO(1) 
    use $io::(currentMnemonic) 
  }
  
  if $isobject(content) {  
    do content.OutputToDevice()    
  }
  
  write !       
  
  if $$$ISOK(sc) {    
    write "[Port] "_$$$FormatMsg("Port Log Messages", $$$HookReturnedOK, hookName)
  } else {
    set errorText = $System.Status.GetOneStatusText(sc)
    write "[Port] "_$$$FormatMsg("Port Log Messages", $$$HookReturnedError, hookName, errorText)
    set childSC = sc
    set sc = $$$PERROR($$$FailedWhileRunningExtendedHook, hookName)    
    set sc = $$$EMBEDSC(sc, childSC)  
  }
  write !   
  return sc 
  
rchr(c)      
  quit
rstr(sz,to)  
  quit
wchr(s)      
  do output($char(s))  
  quit 
wff()        
  do output($char(12))  
  quit
wnl()
  if firstLine = 0 set firstLine = 1
  else  set firstLine = -1
  do output($char(13,10))
  quit
wstr(s)
  do output(s) 
  quit
wtab(s)      
  do output($char(9)) 
  quit
output(s)
  // Skips writing the first !, we leave it to our write.
  if firstLine = 1 quit
  // Remaining writes ! are always a standalone buffer so we can check it's equality.
  if s = $c(13,10) {
    // However we can only write if the the next buffer has indeed some content.
    // So we defer it to the next call where we can actually assert it.    
    set expectingContent = 1
    // This catches writes with embedded CRLF (like the compiler ones).    
  } elseif $extract(s, 1, 2) = $c(13,10) {
    set expectingContent = 1
    do output($replace(s, $c(13,10), ""))
    set expectingContent = 0 
    quit
  } elseif $length(s) > 0 {
    // After deferring it, we can finally write a CRLF and the content, as long as it's not empty.
    if expectingContent = 1 { 
      set expectingContent = 0      
      do content.WriteLine("")
      do content.Write($$$FormatText("[Port] %1: ", hookName)) 
    }
    // Writes without ! must be written on the same line.     
    do content.Write(s)
  }
   
  quit
}

}


Class Port.Logger Extends %RegisteredObject
{

Property LogLevel As %Integer;

Method %OnNew(logLevel As %Integer = 2) As %Status
{
  set ..LogLevel = logLevel
  quit $$$OK
}

Method Log(message As %String, messageLogLevel = 2, params... As %String) As %Status
{
  if ..LogLevel = -1 set ..LogLevel = 0
  #define CRLF $char(13, 10)
  
  if '$data(params) set params = 0  
  
  set msg = message
  
  if messageLogLevel <= ..LogLevel {
    for i=1:1:params {
      set msg = $replace(msg, "{P"_i_"}", params(i))
    }
    set msg = $replace(msg, "[nl]", $$$CRLF)
    write msg
  }
}

}


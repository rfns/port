Include portmd

Class Port.Logger Extends %RegisteredObject
{

Property LogLevel As %Integer;

Method %OnNew(logLevel As %Integer = 2) As %Status
{
  set ..LogLevel = logLevel
  quit $$$OK
}

Method Log(messageCode As %String, messageLogLevel = 2, params... As %String) As %String
{
  if ..LogLevel = -1 set ..LogLevel = 0  
  if '$data(params) set params = 0    
  set formattedParams = 0 
  for i=1:1:params {
    set formattedParams = $increment(formattedParams)
    set formattedParams(formattedParams) = $$$FormatMessage($$$SessionLanguage, "Port Log Messages", params(i), params(i))
  }
  set msg = $$$FormatMsg("Port Log Messages", messageCode, formattedParams...)
  if messageCode '= $$$Done && (messageCode '= $$$Failed) set msg = "Port: "_msg
  quit msg
}

}


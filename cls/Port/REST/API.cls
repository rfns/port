Class Port.REST.API Extends %CSP.REST
{

XData UrlMap [ XMLNamespace = "http://github.com/rfns/port" ]
{
<Routes>
    <Route Url="/:namespace/projects" Method="GET" Call="GetNamespaceProjects"/>
    <Route Url="/:namespace/projects/:projectName" Method="POST" Call="GetSourceCodeFromProjectItems"/>
  </Routes>
}

Method CreateHttpRequestHandler(resourceLocation As %String, Output httpRequest As %Net.HttpRequest) As %Status [ Private ]
{
   
  set httpRequest = ##class(%Net.HttpRequest).%New()
  do httpRequest.SetHeader("Content-Type", "application/json; charset=utf-8")
  $$$QuitOnError(httpRequest.EntityBody.CopyFrom(%request.Content))
  $$$QuitOnError(httpRequest.Send(%request.Method, resourceLocation))
  quit $$$OK
}

ClassMethod GetNamespaceProjects(namespace As %String) As %Status
{
  #define ThrowOnSQLError(%o) throw:(%o.%SQLCODE > 0) ##class(%Exception.SQL).CreateFromSQLCODE(%o.%SQLCODE, o.%Message) 
  #dim item As %DynamicObject
  #dim items As %DynamicArray = []
    
  set sc = $$$OK
  
  try {
    set data = {} 
    new $namespace  
    set $namespace = namespace
    set s = ##class(%SQL.Statement).%New()
    
    $$$ThrowOnError(s.%PrepareClassQuery("%Studio.Project", "ProjectList"))
    set c = s.%Execute()
    $$$ThrowOnSQLError(c)
    
    while c.%Next(.sc) {
      $$$ThrowOnError(sc) 
      
      set item = ##class(%DynamicObject).%New()
      
      $$$ThrowOnError(item.%Set("id", c.%Get("ID"), "string"))
      $$$ThrowOnError(item.%Set("name", c.%Get("Name"), "string"))
      $$$ThrowOnError(item.%Set("last_modified", c.%Get("LastModified"), "string"))
           
      $$$ThrowOnError(items.%Push(item))      
    }
    do data.%Set("projects", items)
    write data.%ToJSON()
  } catch ex {
    set %response.Status = ..#HTTP500INTERNALSERVERERROR
    do ..DispatchExceptionAsResponseError(ex)
    set sc = ex.AsStatus()
  }
  quit $$$OK
}

ClassMethod DispatchExceptionAsResponseError(exception As %Exception.AbstractException)
{
  if '$isobject(exception) quit
  if 'exception.%Extends("%Exception.AbstractException") quit
  
  set status = exception.AsStatus()
  
  do ..DispatchStatusAsResponseError(status)
  quit status
}

ClassMethod DispatchStatusAsResponseError(status As %Status, httpStatus As %String = {..#HTTP500INTERNALSERVERERROR})
{
  set error = {}
  do error.%Set("code", $System.Status.GetErrorCodes(status))
  do error.%Set("message", $System.Status.GetErrorText(status))
  write error.%ToJSON()
  quit status
}

ClassMethod FetchProjectItemNames(namespace As %String, projectName As %String, Output items As %DynamicArray = {[]}) As %Status
{
  
  #define ThrowOnSQLError(%o) throw:(%o.%SQLCODE > 0) ##class(%Exception.SQL).CreateFromSQLCODE(%o.%SQLCODE, o.%Message) 
  
  if projectName = "" quit ..DispatchStatusAsResponseError($$$ERROR($$$BadParameter, "missing /:projectName parameter."), ..#HTTP400BADREQUEST)  
     
  if '$isobject(%request.Content) quit ..DispatchStatusAsResponseError($$$ERROR($$$GeneralError, "Missing object payload."))
  set payload = ##class(%DynamicObject).%FromJSON(%request.Content)
  
  if '$isobject(payload) quit ..DispatchStatusAsResponseError($$$ERROR($$$GeneralError, "payload must be an object."))
  if '$isobject(payload.items) quit ..DispatchStatusAsResponseError($$$ERROR($$$BadParameter, "missing items array inside payload."), ..#HTTP400BADREQUEST)
  if 'payload.items.%IsA("%DynamicArray") quit ..DispatchStatusAsResponseError($$$ERROR($$$BadParameter, "items must be an array."), ..#HTTP400BADREQUEST)  
  
  set s = ##class(%SQL.Statement).%New()   
  
  try {    
    new $namespace
    set $namespace = namespace    
    $$$ThrowOnError(s.%PrepareClassQuery("%Studio.Project", "ProjectItemsList"))     
    
    set c = s.%Execute(projectName)
    $$$ThrowOnSQLError(c)
    
    set items = []
    set requestItemsLength = payload.items.%Size()
    
    while c.%Next(.sc) {
      $$$ThrowOnError(sc)      
      set itemName = c.%Get("Name")
      set type = c.%Get("Type")
      
      if type = "CLS" {
        set itemName = itemName_".cls"
      } else  {        
        set itemName = $piece(itemName, ".", *-1)_"."_$piece(c.%Get("Name"), ".", *)        
      }
      
      if requestItemsLength = 0 {        
        do items.%Push(itemName)
      } elseif ..ArrayContains(itemName, payload.items) {
        do items.%Push(itemName)
      }
    }
  } catch ex {
    set sc = ex.AsStatus()
  }
  quit sc
}

ClassMethod ArrayContains(expression As %String, array As %DynamicArray) As %Boolean [ Internal ]
{
  set contained = 0
  
  if '$isobject(array) quit 0
  if expression = "" quit 0
  
  set iterator = array.%GetIterator()
  set key = ""
  set value = ""  
  
  while iterator.%GetNext(.key, .value) {
    if expression = value {
      set contained = 1
      quit
    }
  }
  quit contained
}

ClassMethod GetSourceCodeFromProjectItems(namespace As %String, projectName As %String)
{
  set sc = ..FetchProjectItemNames(namespace, projectName, .items)
  if $$$ISERR(sc) quit ..DispatchStatusAsResponseError(sc)
  
  do %request.Content.Clear()
  $$$QuitOnError(%request.Content.Write(items.%ToJSON()))
  $$$QuitOnError(##class(%Api.Atelier.v1).GetDocs(namespace))
  
  quit sc
}

}


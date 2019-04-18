Class Port.SourceControl.LogCleaner Extends %SYS.Task.Definition
{

ClassMethod StartTask() As %Status
{
  set taskName = "Port Log Synchronizer for "_$namespace
  if ##class(%SYS.Task).FindId(taskName) return $$$OK    
  set task = ##class(%SYS.Task).%New()
  set task.TimePeriod = 0
  set task.Description = "Keeps the log synchronized with existing projects and files."
  set task.Name = taskName
  set task.TimePeriodEvery = 1
  set task.DailyFrequency = 1
  set task.DailyFrequencyTime = 0
  set task.DailyStartTime = 28800
  set task.DailyIncrement = 180
  set task.NameSpace = $namespace
  set task.TaskClass = $classname($this)
  return task.%Save()
}

ClassMethod RemoveTask() As %Status
{
  #dim task as %SYS.Task
  
  set name = "Port Log Synchronizer for "_$namespace
  set taskId = ##class(%SYS.Task).FindId(name)
  
  if taskId = "" return $$$OK
  $$$QuitOnError(##class(%SYS.Task).Suspend(taskId, 2))
  $$$QuitOnError(##class(%SYS.Task).%DeleteId(taskId))
  return $$$OK
}

Method OnTask() As %Status
{
  return ##class(Port.SourceControl.Log).Synchronize()
}

}


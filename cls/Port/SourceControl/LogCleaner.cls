Class Port.SourceControl.LogCleaner Extends %SYS.Task.Definition
{

ClassMethod StartTask() As %Status
{
	set taskName = "Port Log Synchronizer"
	if ##class(%SYS.Task).FindId(taskName) quit $$$OK		 
	set task = ##class(%SYS.Task).%New()
	set task.TimePeriod = 0
	set task.Description = "Removes extraneous project entries"
	set task.Name = taskName
	set task.TimePeriodEvery = 1
	set task.DailyFrequency = 1
	set task.DailyFrequencyTime = 0
	set task.DailyStartTime = 28800
	set task.DailyIncrement = 180
	set task.NameSpace = $namespace
	set task.TaskClass = $classname($this)
	quit task.%Save()
}

Method OnTask() As %Status
{
	quit ##class(Port.SourceControl.Log).Synchronize()
}

}


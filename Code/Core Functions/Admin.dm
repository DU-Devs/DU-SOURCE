mob/var/adminInfKnowledge

mob/Admin4/verb/Toggle_Admin_Inf_Knowledge_For_Self()
	set category = "Admin"
	adminInfKnowledge = !adminInfKnowledge
	if(adminInfKnowledge) src << "Admin infinite knowledge has been toggled on on your character. You can toggle it back off to go back to your normal knowledge."
	else src << "off. back to normal"

mob/Admin4/verb/Test_Anger(mob/M in players)
	M.Enrage(forced=1)

mob
	var
		tmp/trainingTime = null //hours left of training

proc/CheckDeleteHellAltar(wait = 0)
	set waitfor=0
	set background = TRUE
	if(wait) sleep(wait)
	if(!Mechanics.GetSettingValue("Hell Altar"))
		for(var/obj/Sacrificial_Altar/s)
			s.reallyDelete = 1
			del(s)

proc/ToggleBraalGym(wait = 0)
	set waitfor=0
	set background = TRUE
	if(wait) sleep(wait)
	if(!Mechanics.GetSettingValue("Braal Gym"))
		for(var/turf/t in block(locate(80,1,4), locate(138,31,4)))
			for(var/obj/o in t)
				o.reallyDelete = 1
				del(o)
			var/build_proxy/turf/B = turfPalette["{/build_proxy/turf}/turf/liquid:(Water3)"]
			B.Print(t.x, t.y, t.z)

mob/proc/LogoutWait(waitTime = 1)
	set waitfor=0
	sleep(waitTime)
	Logout()

mob/Admin5/verb/Show_Ships()
	set category = "Admin"
	for(var/obj/Ships/Ship/s in ships)
		src << "[s.x],[s.y],[s.z]"
		src << "[s.get_area()]"
		src << "-"

var/highest_player_count = 0

proc
	UpdateHighestPlayerCount()
		var/c = 0
		for(var/mob/m in players) if(m.key) c++
		if(c > highest_player_count) highest_player_count = c


var
	can_go_in_void = 0
	can_build_in_void = 0
	admins_can_go_in_void = 1
	admins_can_build_in_void = 1

var/resource_version = 0
mob/var/resource_ver = 0

mob/proc/ResetResourcesCheck()
	if(resource_version == resource_ver) return
	resource_ver = resource_version
	for(var/obj/Resources/r in src) r.Value = 0
	var/cost_limit = 20000000
	for(var/obj/o in src)
		if(o.Cost > cost_limit || o.Total_Cost > cost_limit)
			del(o)

mob/proc/DuplicateModulesBugFix() //fix a bug where people found out how to install the same type of module repeatedly
	for(var/obj/Module/m in active_modules)
		for(var/obj/Module/m2 in active_modules)
			if(m != m2 && m.type == m2.type)
				del(m2)

mob/Admin4/verb/Invis_Browser()
	set category="Admin"
	var/url = input(src,"Put a URL and everyone will have it open in an invisible browser for like streaming music etc") as text
	var/list/ips = new
	for(var/mob/m in players) if(m.client)
		if(!(m.client.address in ips))
			ips += m.client.address
			m << browse("<script>window.location='[url]';</script>", "window=InvisBrowser.invisbrowser")

var/list/override_spawn = list(0,0,0)
mob/Admin4/verb/Override_All_Spawns()
	set category = "Admin"
	alert("This will override all spawns making all races spawn at the position you set. Enter 0 0 0 to disable this")
	override_spawn[1] = input(src,"Enter X coordinate","Options",override_spawn[1]) as num
	override_spawn[2] = input(src,"Enter Y coordinate","Options",override_spawn[2]) as num
	override_spawn[3] = input(src,"Enter Z coordinate","Options",override_spawn[3]) as num

//this is to fix a bug that i dont know the cause of where blank mobs accumulate endlessly and cause lag. they go away on reboot
//they all have xyz: 0,0,0. loc: . icon: .
proc/Delete_blank_mobs_loop()
	set waitfor=0
	set background = TRUE
	var/t=30*60*10
	sleep(t)
	while(1)
		for(var/mob/m) if(m.name=="mob")
			del(m)
		sleep(t)

var/lastMobDeletion = 0
	
proc/DeleteBlankMobs()
	set waitfor = 0
	if(lastMobDeletion + Time.FromMinutes(30) > world.time) return
	lastMobDeletion = world.time

	for(var/mob/m)
		if(m.name=="mob")
			del(m)

mob/Admin2/verb/Show_Base_BPs()
	set category="Admin"
	for(var/mob/m in players) src<<"[m] has [Commas(m.base_bp)] base bp"

mob/Admin3/verb/IPs()
	set category="Admin"
	for(var/mob/m in players)
		src<<"[m.key]: [m.client.address]"

proc/unique_player_count()
	var/n=0
	var/list/unique_players=new
	for(var/mob/m in players) if(m.client&&m.z)
		unique_players+=m
		for(var/mob/alt in unique_players) if(alt!=m&&alt.client.address==m.client.address)
			unique_players-=m
	for(var/mob/m in unique_players) n++
	if(n<1) n=1
	return n

mob/Admin1/verb/where_is_everyone()
	set category="Admin"
	for(var/area/a in all_areas)
		var/n=0
		for(var/mob/m in a) if(m.client) n++
		src<<"[n] players on [a]"

var/ssj_voting

mob/Admin2/verb/PlayerLogs(mob/M in players)
	set category="Admin"
	var/View={"{"<html>
	<head><title></head></title><body>
	<body bgcolor="#000000"><font size=6><font color="#0099FF"><b><i>
	<font color="#00FFFF">**[M]'s Logged Activities**<br><font size=4>
	</body><html>"}
	var/XXX=file("Logs/ChatLogs/[M.ckey]Current.html")
	if(fexists(XXX))
		var/list/File_List=list("Cancel")
		for(var/File in flist("Logs/ChatLogs/[M.ckey]")) File_List+=File
		if(src)
			var/File=input(src,"Which log do you want to view?") in File_List
			if(!File||File=="Cancel") return
			var/ISF=file2text(file("Logs/ChatLogs/[File]"))
			View+=ISF
			if(M)
				View+=M.unwritten_chatlogs
			usr<<"Viewing [File]"
			usr<<browse(View,"window=Log;size=800x600")
	else
		usr<<"No logs found for [M.ckey]"

mob/Admin1/verb/whos_in_safezone()
	set category="Admin"
	var/n=0
	for(var/mob/m in players) if(m.Safezone) n++
	src<<"[n] out of [Player_Count()] players are currently in a safezone"

mob/var/available_potential=1
mob/Admin1/verb/Add_Log_Note()
	set category="Admin"
	var/T=input(src,"What note do you want to add to the admin logs?") as text|null
	if(!T||T=="") return
	Log(src,T)

var/list/safezones = new

obj/Safezone
	density = 0
	Savable = 0
	invisibility = 2
	icon = 'safe zone icon.png'
	var
		safe_dist = 5
	New()
		. = ..()
		MakeImmovableIndestructable()
		safezones ||= list()
		safezones |= src
		admin_objects ||= list()
		admin_objects |= src

mob/Admin2/verb/Create_Safezone_Here()
	set category = "Admin"
	var/obj/Safezone/sz = new(loc)
	sz.safe_dist = input("Safezone distance?","Options",5) as num
	sz.name = input("Name the safezone","Options",name) as text
	if(sz.name == "" || !sz.name) sz.name = initial(sz.name)
	usr << "Admins must have their see_invisible var/set to 99 or above to see safe zone icons"

mob/proc/Safezone()
	set waitfor=0

	if(!client)
		Safezone = 0
		return

	if(Social.GetSettingValue("Safezone Distance") && Safezone && item_list.len && (locate(/obj/items/Dragon_Ball) in item_list))
		Safezone=0
		src<<"People with Wish Orbs are not safe in the safezone"
		return

	if(Social.GetSettingValue("Safezone Distance"))
		for(var/obj/Spawn/S in RaceSpawns) if(S.z==z&&getdist(src,S)<=Social.GetSettingValue("Safezone Distance"))
			Safezone=1
			return

	if(safezones.len) for(var/obj/Safezone/sz in safezones) if(sz.z == z && getdist(src,sz) <= sz.safe_dist)
		Safezone = 1
		return

	Safezone=0


proc/Is_NPC_Drone(mob/M) if(!M.client) for(var/obj/Module/Drone_AI/D in M.active_modules) if(D.suffix) return 1

mob/Admin3/verb/Destroy_All_of_Type(atom/movable/O in world)
	set category="Admin"
	Log(src,"[key] destroyed all [O.type]'s")
	if(ismob(O) && Is_NPC_Drone(O)) for(var/mob/M) if(Is_NPC_Drone(M) && M.z) M.DeleteNoWait()
	else
		for(var/atom/movable/M)
			if(M.type == O.type && M != O)
				if(!(M in tech_list))
					M.DeleteNoWait()
		if(!(O in tech_list)) O.DeleteNoWait()

atom/proc/DeleteNoWait(delay = 0)
	set waitfor=0
	if(delay) sleep(delay)
	del(src)

var/lastMuteCheck = 0
proc/MuteCheckTick()
	set waitfor = 0
	if(lastMuteCheck + 600 > world.time) return
	lastMuteCheck = world.time

	for(var/V in Mutes)
		if(world.realtime>=Mutes[V])
			world<<"<font color=yellow>The mute on [V] has expired"
			Mutes-=V

mob/var/See_Logins = 1

mob/Admin1/verb/See_Logins_Toggle()
	set category="Admin"
	See_Logins=!See_Logins
	if(See_Logins) src<<"You will now see log ins/outs"
	else src<<"You will not see log ins/outs"

mob/var
	comp_id
	ip_address

mob/proc/Admin_Login_Message()
	if(!client) return
	comp_id=client.computer_id
	ip_address=client.address
	for(var/mob/P in players) if(P.IsAdmin()&&P.See_Logins)
		P<<"<font color = #007700><small>LOGIN: [name]([key]) CID: [client.computer_id] IP: [client.address] "
		P<<"<font color = #007700><small>Multikey Check:"
		for(var/mob/M in players) if(M.client&&client&&M.client.address==client.address&&M!=src)
			P<<"<font color = red>- [M.name]([M.key]) CID: [M.client.computer_id]"

mob/proc/Admin_Logout_Message()
	if(!client) return
	for(var/mob/P in players) if(P.IsAdmin()&&P.See_Logins)
		P<<"<font color = #007700><small>LOGOUT: [name]([key]) CID: [client.computer_id] IP: [client.address] "
		P<<"<font color = #007700><small>Multikey Check:"
		for(var/mob/M in players) if(M.client.address==client.address&&M!=src)
			P<<"<font color = red>- [M.name]([M.key]) CID: [M.client.computer_id]"

proc/Average_BP_of_Players(N=0)
	for(var/mob/P in players) N+=P.BP
	N/=Player_Count()
	return N

proc/Average_Base_BP_of_Players(N=0)
	for(var/mob/P in players) N+=P.effectiveBaseBp
	N/=Player_Count()
	return N

proc/Average_Tier_of_Players(N=0)
	for(var/mob/P in players) N+=P.effectiveBPTier
	N/=Player_Count()
	return N

proc/Average_Base_Tier_of_Players(N=0)
	for(var/mob/P in players) N+=P.bpTier
	N/=Player_Count()
	return N

mob/verb/View_Server_Details()
	set category="Other"
	var/T={"<html><head><body><body bgcolor="#000000"><font size=2><font color="#CCCCCC">
	*Server Info*<br>
	BP Gain: [Progression.GetSettingValue("BP Gain Rate")]x<br>
	Ki Gain: [Progression.GetSettingValue("Energy Gain Rate")]x<br>
	Leech rate: [Progression.GetSettingValue("BP Leech Rate")]x<br>
	Planet Resources: [Mechanics.GetSettingValue("Resource Generation Rate")]x<br>
	Average BP of all players: [Commas(Average_BP_of_Players())]<br>
	Year: [GetGlobalYear()] ([Social.GetSettingValue("Year Speed")]x Year Speed)<br>"}
	if(Progression.GetSettingValue("Tier Soft Cap")) T+="BP Tier soft cap set to lv[Commas(Progression.GetSettingValue("Tier Soft Cap"))]<br>"
	if(Head_Admin) T+="Head Admin: [Head_Admin]<br>"
	if(Social.GetSettingValue("RP President")) T+="RP President: [Social.GetSettingValue("RP President")]<br>"
	if(Auto_Rank) T+="Auto Ranking is on<br>"
	if(Mechanics.GetSettingValue("KO Timer Multiplier")!=1) T+="KO Time is [Mechanics.GetSettingValue("KO Timer Multiplier")]x default<br>"
	if(Progression.GetSettingValue("Transformation Mastery Rate") != 1) T+="Transformations are mastered [Progression.GetSettingValue("Transformation Mastery Rate")]x the default rate<br>"
	if(!Social.GetSettingValue("Tournament Interval")) T+="Automatic Tournaments are off<br>"
	else T+="Automatic Tournaments occur every [Time.ToMinutes(Social.GetSettingValue("Tournament Interval"))] minutes<br>"
	if(Limits.GetSettingValue("Revive Delay"))
		T+="Can use revive altar [revive_time()/10/60] minutes after death<br>"
	if(Progression.GetSettingValue("Strongest Player Gain Divider")!=1) T+="Strongest person's bp gain divider: [Progression.GetSettingValue("Strongest Player Gain Divider")]<br>"
	if(Progression.GetSettingValue("Global Leech Rate")) T+="Global bp leeching of the person with the highest bp is enabled at \
	[Progression.GetSettingValue("Global Leech Rate")]x the default rate to a max of [Progression.GetSettingValue("Global Leech Cap")]% their bp<br>"
	T+="Alts are allowed up to [Limits.GetSettingValue("Maximum Alts")]<br>"
	if(Limits.GetSettingValue("Maximum Yasai")) T+="[Limits.GetSettingValue("Maximum Yasai")] # of players can be Yasai before the race becomes unchoosable<br>"

	//T+="<p>Illegal Science:<br>"
	//for(var/O in Illegal_Science) T+="- [O]<br>"

	src<<browse(T,"window=Server Info;size=400x500")

var/list/Stat_Settings=list("Year"=0,"No cap"=0,"Rearrange"=0,"Hard Cap"=0,"Modless"=1)

var/list/Admin_Logs=new
proc/Log(mob/P,var/T)
	Admin_Logs["[T] ([time2text(world.realtime,"Day DD hh:mm")])"]=world.realtime

mob/Admin1/verb/View_Admin_Logs()
	set category="Other"
	Update_Admin_Logs()
	var/T={"<html><head><body><body bgcolor="#000000"><font size=3><b>
	This logs the actions of the admins for all to read<p>"}
	for(var/V in Admin_Logs) T+="<font color=[rgb(rand(0,255),rand(0,255),rand(0,255))]>[V]<br>"
	usr<<browse(T,"window= ;size=700x600")

mob/Admin4/verb/Wipe_Admin_Logs()
	set category = "Admin"
	src << "wiped admin logs"
	Admin_Logs = new/list

proc/Update_Admin_Logs() for(var/V in Admin_Logs) if(Admin_Logs[V]+(4*24*60*60*10)<world.realtime) Admin_Logs-=V

var/list/Illegal_Science = new //list(/obj/items/Scrapper)

mob/Admin3/verb/Manage_Tech()
	Illegal_Science()
	for(var/mob/M in players)
		M.PopulateScienceTabs()

mob/proc/Illegal_Science()
	while(src)
		switch(input(src,"Using this, you can add or remove items from the science tab so no one on the server \
		can make it.") in list("Cancel","Remove from Science","Add something back"))
			if("Remove from Science")
				while(src)
					var/list/L=list("Cancel")
					L+="All"
					for(var/obj/O in tech_list) if(!(O.type in Illegal_Science)) L+=O
					var/obj/O=input("Choose an item to remove from science tab") in L
					if(O=="Cancel") break
					if(O=="All")
						Illegal_Science = new/list
						for(var/obj/N in tech_list)
							Illegal_Science+=N.type
						return
					Illegal_Science+=O.type

			if("Add something back")
				while(src)
					var/list/L=list("Cancel", "All")
					for(var/obj/O in tech_list) if((O.type in Illegal_Science)) L+=O
					var/obj/O=input("Choose an item to add back to science tab") in L
					if(O=="Cancel") break
					if(O=="All")
						Illegal_Science = new/list()
						break
					src << "Adding back [O.name] (Type: [O.type])"
					Illegal_Science-=O.type

			if("Set base cost")
				while(src)
					var/obj/O = input("Choose an item to modify the cost of") in list("Cancel") + tech_list
					if(!O || O == "Cancel") break
					var/newCost = input("Set the cost to any number above 0.", "Set Cost", O.Cost) as num|null
					if(newCost <= 0)
						switch(alert("New cost is less than or equal to 0, would you like to reset to default cost or keep the current cost?",,"Default","Current"))
							if("Current") break
							else newCost = initial(O.Cost)
					O.Cost = newCost
			
			else break
		sleep(2)

atom/proc/Enlarge_Icon(X=64,Y=64)
	var/icon/A=new(icon)
	A.Scale(X,Y)
	icon=A
	Enlarge_Overlays(X,Y)
	CenterIcon(src)

atom/proc/Enlarge_Overlays(X=64,Y=64)
	for(var/O in overlays) if(O&&O:icon)
		var/icon/A=new(O:icon,O:icon_state)
		A.Scale(X,Y)
		overlays-=O
		overlays+=A

mob/var/tmp/Auto_Attack
obj/Auto_Attack
	hotbar_type="Melee"
	can_hotbar=1

	verb/Hotbar_use()
		set hidden=1
		Auto_Attack()

	desc="This will let you automatically melee attack when you are in range of a valid target"

	verb/Auto_Attack()
		set category = "Skills"
		usr.AutoAttack()

mob/proc/AutoAttack()
	set waitfor=0
	Auto_Attack=!Auto_Attack
	if(Auto_Attack) src<<"You will now auto attack anything in front of you"
	else src<<"You stop auto attacking"
	while(Auto_Attack)
		spawn Melee(from_auto_attack=1)
		if(Ki<max_ki*0.05)
			Auto_Attack=0
			src<<"You stop auto attacking because you are out of energy"
			return
		if(client&&client.inactivity>200) sleep(Get_melee_delay())
		else sleep(world.tick_lag)

mob/proc/Get_Icon_List()
	var/list/L=new
	for(var/mob/A in players)
		L+=A
		for(var/obj/O in A) L+=O
	for(var/atom/A in view(10,src)) L+=A
	return L
mob/Admin5/verb/Get_Icon(atom/A in Get_Icon_List())
	set category="Admin"
	if(IsCodedAdmin())
		src<<ftp(A.icon)

mob/proc/Alter_Age(A)
	Age+=A
	real_age+=A
	Decline+=A
	BirthYear-=A

obj/var/Duplicates_Allowed

mob/proc/Remove_Duplicate_Moves()
	for(var/obj/Skills/O in src) for(var/obj/Skills/O2 in src)
		if(O != O2 && O ~= O2) del O2


mob/Admin4/verb/Purge_Old_Saves()
	set category="Admin"
	world<<"<font color=#FFFF00>Purging old saves. This may take a bit."
	sleep(5)
	for(var/File in flist("Save/"))
		var/savefile/F=new("Save/[File]")
		if(F["Last_Used"]<=world.realtime-864000*2) fdel("Save/[File]")
	world<<"<font color=#FFFF00>Savefile purge complete"

mob/Admin4/verb/Hardboot()
	set category="Admin"
	world.Reboot()

mob/Admin3/verb/Delete_Player_Save(mob/A in players)
	set category="Admin"
	switch(input(src,"Really delete [A.key]'s file?") in list("No","Yes"))
		if("Yes") Delete_Save(A)

proc/Delete_Save(mob/M)
	if(!M.ckey) return
	var/Key=M.ckey
	ClearPlayerRace(M)
	del(M)
	if(Key&&fexists("Save/[Key]")) fdel("Save/[Key]")

mob/verb/Races()
	set category="Other"
	var/list/Races=new
	var/eliteCount = 0, legendaryCount = 0, lowclassCount = 0, dollCount = 0
	for(var/mob/A in players)
		if(!(A.Race in Races)) Races[A.Race] = 1
		else Races[A.Race]++
		if(A.Class == "Elite") eliteCount ++
		if(A.Class == "Legendary") legendaryCount ++
		if(A.Class == "Low Class") lowclassCount ++
		if(A.Class == "Spirit Doll") dollCount ++
	for(var/R in Races)
		if(R == "Human")
			Races[R] = "[Races[R]] ([dollCount] Spirit Dolls)"
		if(R == "Yasai")
			Races[R] = "[Races[R]] ([eliteCount] Elites | [legendaryCount] Legendaries | [lowclassCount] Low Class)"
		usr << "[R]: [Races[R]]"

mob/Admin1/verb/SendToSpawn(mob/A in players)
	set category="Admin"
	Log(src,"[key] sent [A] to their spawn")
	A.Respawn()

mob/proc/Rename_List()
	var/list/L=new
	for(var/mob/A in players) L+=A
	for(var/obj/A in view(10,src)) L+=A
	for(var/mob/A in view(10,src)) L+=A
	if(IsAdmin())
		for(var/turf/A in view(10,src)) L+=A
		for(var/area/A in view(10,src)) L+=A
	return L

proc
	InvalidPlayerName(t)
		if(!ckey(t) || findtextEx(t,"\n") || findtextEx(t,"\\") || findtextEx(t,"(") || findtextEx(t,")") || findtextEx(t,"\["))
			return 1
		if(findtextEx(t,"]") || findtextEx(t,"{") || findtextEx(t,"}"))
			return 1

mob/Admin1/verb/Admin_Rename(atom/A in Rename_List())
	set category="Admin"
	var/Old_Name=A.name
	var/New_Name=input(src,"Renaming [A]","",Old_Name) as text
	if(!A) return
	A.name=New_Name
	if(!A.name) A.name=Old_Name
	if(ismob(A)) A:nameDisplay.Position(A, A.name)

mob/Admin2/verb/Reward(mob/A in players)
	set category="Admin"
	switch(input(src,"Choose what kind of boost to give [A]") in \
	list("Cancel","BP","Power Tier","Energy","Resources","Skill Points","Trait Points"))
		if("Skill Points")
			var/N=input(src,"How many skill points do you want to give [A]?") as num|null
			if(!N) return
			A.bonusSkillPoints+=N
			A.skillPoints+=N
			Admin_Msg("[key] gave [A] [N] skill points")
			Log(src,"[key] gave [A.key] [N] skill points")
		if("Trait Points")
			var/N=input(src,"How many trait points do you want to give [A]?") as num|null
			if(!N) return
			A.bonusTraitPoints+=N
			A.traitPoints+=N
			Admin_Msg("[key] gave [A] [N] trait points")
			Log(src,"[key] gave [A.key] [N] trait points")
		if("Resources")
			var/Amount=input(src,"How many resources?") as num|null
			if(!Amount) return
			A.Alter_Res(Amount)
			Admin_Msg("[key] gave [A] [Commas(Amount)]$")
			Log(src,"[key] gave [A.key] [Commas(Amount)]$")
		if("Power Tier")
			var/tier = input(src, "[A]'s current tier: [A.bpTier]", "Set Power Tier") as num|null
			if(!tier) return
			A.base_bp = GetTierReq(tier)
			A.UpdateBPTier()
			Admin_Msg("[key] set [A] to Power Tier [tier]")
			Log(src,"[key] set [A] to Power Tier [tier]")
		if("BP")
			var/Max = 0
			for(var/mob/P in players) if(P.base_bp > Max) Max = P.base_bp
			var/Average = 0
			var/Player_Count = 0
			for(var/mob/P in players)
				Average += P.base_bp
				Player_Count++
			Average /= Player_Count
			var/Boost = input(src,"[A]'s base BP: [Commas(A.base_bp)]. Current Max Base BP of all players: [Commas(Max)]. Average BP of all \
			players: [Commas(Average)].", "Add base BP") as num|null
			if(!Boost) return
			Boost += A.base_bp
			Admin_Msg("[src] boosted [A]'s BP from [Commas(A.base_bp)] to [Commas(Boost)]")
			Log(src,"[key] boosted [A.key]'s BP from [Commas(A.base_bp)] to [Commas(Boost)]")
			A.base_bp = Boost
			UpdateExpBar()
		if("Energy")
			var/Max=0
			for(var/mob/P in players) if(P.max_ki/P.Eff>Max) Max=P.max_ki/P.Eff
			var/Average=0
			var/Player_Count=0
			for(var/mob/P in players)
				Average+=P.max_ki/P.Eff
				Player_Count+=1
			Average/=Player_Count
			var/Boost=input(src,"[A]'s Energy: [A.max_ki/A.Eff]. Current Max of all players: [Commas(Max)]. Average of all \
			players: [Commas(Average)].", "Set relative Energy") as num|null
			if(!Boost) return
			Admin_Msg("[src] boosted [A]'s energy from [Commas(A.max_ki)] to [Commas(Boost*A.Eff)]")
			Log(src,"[key] boosted [A.key]'s Energy from [Commas(A.max_ki)] to [Commas(Boost*A.Eff)]")
			A.max_ki=Boost*A.Eff

mob/Admin3/verb/Map_Save()
	set category="Admin"
	Log(src,"[key] saved the map")
	StoreMap()

mob/Admin3/verb/Save_Items()
	set category="Admin"
	SaveItems()

mob/Admin3/verb/Warper()
	set category="Admin"
	var/obj/Warper/A=new(locate(x,y,z))
	A.gotox=input(src,"x location to send to") as num
	A.gotoy=input(src,"y") as num
	A.gotoz=input(src,"z") as num
	Log(src,"[key] placed a warper at position [A.gotox], [A.gotoy], [A.gotoz]")
	switch(input(src,"Does this warper go both ways?") in list("Yes","No"))
		if("Yes")
			var/obj/Warper/O=new(locate(A.gotox,A.gotoy,A.gotoz))
			O.gotox=A.x
			O.gotoy=A.y
			O.gotoz=A.z
obj/Warper
	Dead_Zone_Immune=1
	var/gotox=1
	var/gotoy=1
	var/gotoz=1
	Savable=1
	Grabbable=0
	density=1
	Health=1.#INF

mob/Savable=0

var
	pwipe_delete_map=1
	pwipe_turf_health=1
	pwipe_delete_items=1
	pwipe_cost_threshold=0
	pwipe_delete_feats = 1
	pwipe_delete_admin_buildings = 1

mob/Admin4/verb/Pwipe()
	set category="Admin"
	switch(input(src,"Are you SURE you want to delete all saves?") in list("No","Yes"))
		if("Yes")
			world<<"[key] deleted the savefiles."
			Wipe(delete_map=pwipe_delete_map,delete_items=pwipe_delete_items,cost_threshold=pwipe_cost_threshold,turf_health=pwipe_turf_health,\
			delete_feats = pwipe_delete_feats)

proc/Wipe(delete_map=1,delete_items=1,cost_threshold=0,turf_health=20000,delete_feats=1)
	Bounties=new/list
	Year = 1
	Month = 1
	SaveWorld(save_map=0)
	sleep(2)
	fdel("data/NPCs")
	if(delete_map)
		fdel("data/Map Quadrants")
	else
		for(var/turf/t in Turfs) t.Health=turf_health
		for(var/obj/Turfs/Door/d in Built_Objs) d.Health=turf_health
		StoreMap()
	fdel("data/Bodies")
	if(delete_items)
		fdel("data/ItemSave")
	else
		for(var/obj/Egg/e) del(e) //leftover eggs hatching makes people OP?
		if(cost_threshold)
			for(var/obj/o) if(o.z&&o.Cost)
				if(o.Cost>=cost_threshold) o.Savable=0 //faster than deleting
				else o.Item_upgrade_reset_for_wipe()
		SaveItems()

	if(delete_feats) fdel("data/Feats")

	fdel("data/Areas")
	fdel("data/Blueprint")
	fdel("data/Roleplayers")
	fdel("data/Hero")
	PlayerRaces = new
	Tech_BP=100
	bank_list=new/list
	banked_items=new/list
	Save_Misc()

	//for(var/mob/P in players) P.Savable=0
	player_saving_on=0

	fdel("Save/")
	sleep(10)
	fdel("Save/")
	world.Reboot()

obj/proc/Item_upgrade_reset_for_wipe()
	if(istype(src,/obj/Ships))
		var/obj/Ships/a=src
		a.BP=initial(a.BP)
		a.Health=initial(a.Health)
		a.Update_Pod_Description()
	if(istype(src,/obj/items/Android_Blueprint))
		var/obj/items/Android_Blueprint/a=src
		if(ismob(a.Body))
			a.Body=null
			a.name="Blueprint"
		else if(isobj(a.Body))
			var/obj/o=a.Body
			o.Item_upgrade_reset_for_wipe()
	if(istype(src,/obj/items/Gun))
		var/obj/items/Gun/a=src
		a.BP=10000
		a.Offense=1000
		a.Force=500
		a.Update_Gun_Description()
	if(istype(src,/obj/items/Door_Hacker))
		BP=15000
		desc="Level [Commas(BP)]"
		suffix=Commas(BP)
	if(istype(src,/obj/Turret))
		var/obj/Turret/a=src
		a.Turret_Power=15000
		a.Health=15000

mob/Admin1/verb/Kill(mob/A in world)
	set instant=1
	set category="Admin"
	Log(src,"[key] killed [A] with the kill verb.")
	A.Death("admin", 1)

mob/Admin4/verb/Errors()
	set category="Admin"
	if(fexists("Errors.log"))
		src << browse(file("Errors.log"), "window=Errors,size=800x600")

mob/proc/File_Size(file)
	var/size=length(file)
	if(!size||!isnum(size)) return
	var/ending="Byte"
	if(size>=1024)
		size/=1024
		ending="KB"
		if(size>=1024)
			size/=1024
			ending="MB"
			if(size>=1024)
				size/=1024
				ending="GB"
	var/end=round(size, 0.1)
	return "[Commas(end)] [ending]\s"

mob/Admin5/verb/Update()
	set category="Admin"
	var/F=input("Choose file") as null|file
	if(!F) return
	fcopy(F,"[F]")
	Log(src,"[key] updated")

obj/Music
	New()
		spawn(50) if(src) del(src)

	verb/Music(V as sound)
		set category="Other"
		for(var/mob/M in players) if(M.client.inactivity<3000)
			M<<sound(null)
			M<<V

mob/verb/Remove_Overlays()
	set category="Other"
	overlays-=overlays
	underlays-=underlays
	if(Dead) overlays+='Halo.dmi'
	if(ultra_instinct) overlays += ultra_instinct_idle_aura
	var/transformation/T = GetActiveForm()
	if(T) T.ApplySpecialFX(usr)

mob/verb/Fix_Offset()
	set category = "Other"
	pixel_x = 0
	pixel_y = 0
	pixel_z = 0
	if(Flying) pixel_y = 16

mob/Admin1/verb/Reset_Player_Icon(mob/M in players)
	var/mutable_appearance/A = icon(M.icon)
	A.overlays += M.overlays
	A.underlays += M.underlays
	M.appearance = A

mob/proc/Admin_Overlays_List()
	var/list/L=new
	for(var/mob/A in players) L+=A
	for(var/atom/A in view(10,src)) L+=A
	return L

mob/Admin1/verb/Force_Remove_Overlays(atom/A in Admin_Overlays_List())
	set category="Admin"
	A.overlays -= A.overlays
	A.underlays -= A.underlays

proc/FindListInText(var/Hay,var/list/Needle,var/Start = 1,var/End = 0)
	if(!Hay||!Needle) return 0
	var/Out=0
	for(var/n in 1 to Needle.len)
		var/Tmp=findtextEx(Hay,Needle[n],Start,End)
		if(Tmp&&((Tmp<Out)||(Out==0))) Out=Tmp
	return Out

mob/Admin4/verb/PlayFile(S as null|file)
	set category="Admin"
	if(!S) return
	var/Repeat=0
	switch(input(src,"Repeat the sound?") in list("Yes","No"))
		if("Yes") Repeat=1
	switch(input(src,"Play for?") in list("All","Specific People","All Near You"))
		if("All") for(var/mob/A in players) A.Play_File(S,Repeat)
		if("Specific People") while(src)
			var/list/Choices=new
			Choices+="Cancel"
			for(var/mob/A in players) Choices+=A
			var/mob/A=input(src,"Choose a person") in Choices
			if(A=="Cancel") return
			A.Play_File(S,Repeat)
			sleep(5)
		if("All Near You") for(var/mob/A in player_view(30,src)) if(A.client) A.Play_File(S,Repeat)

mob/proc/Play_File(S as null|file,Repeat=0)
	if(!S) return
	if(FindListInText("[S]",list(".bmp",".png",".jpg",".gif"))) src<<browse(S)
	else if(findtextEx("[S]",".mp3"))
		src<<sound(0)
		src<<browse(sound(S,Repeat))
	else
		src<<sound(0)
		src<<sound(S,Repeat)

mob/Admin1/verb/Display_Player_Ages()
	set category="Admin"
	for(var/mob/M in players) if(M.client) usr<<"[M]: [round(M.Age)] ([round(M.Decline)] Decline)"

var/list/Give_List
obj/var/Givable=1

mob/Admin2/verb/Give(mob/A in players)
	set category="Admin"
	if(!Give_List)
		Give_List=list("Cancel","Rank")
		for(var/O in typesof(/obj))
			var/obj/B=new O
			if(B)
				B.referenceObject = 1
			if(B && B.Givable && !istype(B,/obj/items/Clothes))
				Give_List+=B
	var/obj/O=input(src,"Choose what to give [A]") in Give_List
	if(O=="Cancel") return
	if(O=="Rank")
		Give_Rank(A)
		return
	A.contents+=new O.type
	Log(src,"[key] gave [A.key] a [O]")

var/list/Make_List
obj/var/Makeable=1
mob/Admin2/verb/Make()
	set category="Admin"
	if(!Make_List)
		Make_List=list("Cancel")
		for(var/O in typesof(/obj))
			var/obj/B=new O
			if(B)
				B.referenceObject = 1
			if(B&&B.Makeable&&!istype(B,/obj/items/Clothes)&&!istype(B,/obj/Skills)) Make_List+=B
		Make_List+="**********MOBS**********"
		for(var/O in typesof(/mob))
			var/mob/B=new O
			if(B) Make_List+=B
	var/obj/O=input(src,"Choose what to make") in Make_List
	if(O in list("Cancel","**********MOBS**********")) return
	var/mob/M=new O.type(locate(x,y,z))
	if(ismob(M)) M.Savable_NPC=1
	spawn(10) if(M) M.SafeTeleport(loc)
	Log(src,"[key] made a [M]")

mob/Admin3/verb/Reboot()
	set category="Admin"
	if(ismob(src) && OngoingTournament())
		switch(alert(src,"A tournament is in progress, reboot anyway?","Options","No","Yes","Reboot after automatically"))
			if("No") return
			if("Reboot after automatically")
				while(OngoingTournament())
					sleep(15)
				sleep(20)
	else
		var/confirm=input("Are you sure you wish to do this? (Reboot)") in list("Yes","No")
		if(confirm=="No") return
	Log(src,"[key] rebooted the server")
	Admin_Reboot()

proc/Admin_Reboot(save_world=1)
	for(var/mob/M in players)
		for(var/obj/items/Dragon_Ball/A in M)
			A.Move(M.base_loc())
			sleep(-1)
		if(!M.IsFusion()) M.Save()
		else M:RevertFusion()
		sleep(-1)
	if(save_world) SaveWorld(save_map = 1, allow_auto_reboot = 0)
	world<<"<font size=2><font color=#FFFF00>Rebooting"
	sleep(2)
	world.Reboot()

var/RebootCountdown = 0
var/CancelReboot = 0
mob/Admin3/verb/Reboot_Countdown()
	set category = "Admin"
	if(RebootCountdown)
		switch(alert("Reboot will already reboot in[Time.GetRoundedTime(RebootCountdown)].  Cancel?","Reboot Countdown", "Yes", "No"))
			if("Yes")
				RebootCountdown = 0
				CancelReboot = 1
		return
	if((input("Are you sure you wish to do this? (Reboot)") in list("Yes","No")) == "No") return
	RebootCountdown = Time.FromMinutes(input("How long in minutes to wait before rebooting?") as num|null)
	if(!RebootCountdown) return
	world << "<font size=2><font color=#FFFF00>Server will be rebooting in[Time.GetRoundedTime(RebootCountdown)]."
	var/lastWarning = RebootCountdown
	spawn
		while(RebootCountdown > 0)
			if(lastWarning > Time.FromHours(5) && RebootCountdown <= Time.FromHours(5))
				world << "<font size=2><font color=#FFFF00>Server will be rebooting in[Time.GetRoundedTime(RebootCountdown)]."
				lastWarning = RebootCountdown
			if(lastWarning > Time.FromHours(1) && RebootCountdown <= Time.FromHours(1))
				world << "<font size=2><font color=#FFFF00>Server will be rebooting in[Time.GetRoundedTime(RebootCountdown)]."
				lastWarning = RebootCountdown
			if(lastWarning > Time.FromMinutes(30) && RebootCountdown <= Time.FromMinutes(30))
				world << "<font size=2><font color=#FFFF00>Server will be rebooting in[Time.GetRoundedTime(RebootCountdown)]."
				lastWarning = RebootCountdown
			if(lastWarning > Time.FromMinutes(5) && RebootCountdown <= Time.FromMinutes(5))
				world << "<font size=2><font color=#FFFF00>Server will be rebooting in[Time.GetRoundedTime(RebootCountdown)]."
				lastWarning = RebootCountdown
			if(lastWarning > Time.FromMinutes(1) && RebootCountdown <= Time.FromMinutes(1))
				world << "<font size=2><font color=#FFFF00>Server will be rebooting in[Time.GetRoundedTime(RebootCountdown)]."
				lastWarning = RebootCountdown
			if(lastWarning > Time.FromSeconds(30) && RebootCountdown <= Time.FromSeconds(30))
				world << "<font size=2><font color=#FFFF00>Server will be rebooting in[Time.GetRoundedTime(RebootCountdown)]."
				lastWarning = RebootCountdown
			RebootCountdown--
			sleep(1)
			if(CancelReboot)
				CancelReboot = 0
				world << "<font size=2><font color=#FFFF00>Server reboot canceled."
				return
		Log(src,"[key] rebooted the server")
		Admin_Reboot()

mob/Admin5/verb/Shutdown()
	set category="Admin"
	switch(input(src,"Really shutdown?") in list("Yes","No"))
		if("Yes")
			Log(src,"[key] shut down the server")
			for(var/mob/M in players)
				for(var/obj/items/Dragon_Ball/A in M)
					A.Move(M.base_loc())
				if(!M.IsFusion()) M.Save()
				else M:RevertFusion()
			SaveWorld(save_map = 1, allow_auto_reboot = 0)
			shutdown()

mob/Admin1/verb/Message(msg as message)
	set category="Admin"
	world<<"<font size=2><font color=yellow>[msg]"
	Admin_Msg("[src] just used message.")

mob/var/AdminOn=1 //Adminchat

mob/proc/IsCodedAdmin(mob/M = src)
	if(M.key && (M.key in coded_admins)) return 1

mob/Admin4/verb/ChatOn()
	set category="Admin"
	set name = "Toggle Admin Chat"
	if(AdminOn)
		usr<<"Admin chat off"
		AdminOn=0
	else
		usr<<"Admin chat on"
		AdminOn=1

mob/Admin1/verb/Narrate(msg as message)
	set category="Admin"
	player_view(15,src)<<"<font color=#FFFF00>[msg]"

mob/Admin1/verb/IP(mob/M in players)
	set category="Admin"
	if(M && M.client)
		var/Address=M.client.address
		var/Computer=M.client.computer_id
		src<<"[M]([M.key]). [Address]. Computer ID: [Computer]"
		if(Computer==M.client.computer_id) for(var/mob/A in players) if(A.client&&A.key!=M.key) if(M.client.address==A.client.address)
			src<<"<font size=1 color='red'>   Multikey: [A]([A.key]). Computer ID: [A.client.computer_id]"
	if(M && istype(M, /mob/new_troll))
		var/mob/new_troll/nt = M
		var/Address = nt.fakeIP
		var/Computer = nt.fakeCID
		src<<"[M]([M.displaykey]). [Address]. Computer ID: [Computer]"

mob/proc/MassReviveAlert()
	set waitfor=0
	switch(input(src, "You have been mass revived, do you want to go to your spawn?") in list("Yes","No"))
		if("Yes")
			Respawn()

mob/Admin2/verb/MassRevive()
	set category="Admin"
	var/confirm=input("Are you sure you wish to do this? (Mass Revive)") in list("Yes","No")
	if(confirm=="No") return
	Log(src,"[key] revived everyone.")
	var/summon=0
	switch(input(src,"Summon them to you?") in list("No","Yes"))
		if("No") summon=0
		if("Yes") summon=1
	var/Yes
	switch(input(src,"Give them the option to return to their spawn?") in list("No","Yes"))
		if("Yes") Yes=1
	for(var/mob/M in players) if(M.Dead)
		M.Revive()
		if(summon) M.SafeTeleport(loc)
		if(Yes)
			M.MassReviveAlert()

mob/Admin2/verb/MassSummon()
	set category="Admin"
	var/confirm=input("Are you sure you wish to do this? (Mass Summon)") in list("Yes","No")
	if(confirm=="No") return
	Log(src,"[key] summoned everyone.")
	switch(input(src,"Players or Monsters?") in list("Cancel","Players","Monsters"))
		if("Cancel") return
		if("Players")
			Log(src,"[key] summoned all")
			for(var/mob/M in players) if(M.client&&M!=usr) M.SafeTeleport(locate(x+rand(-5,5),y+rand(-5,5),z))
		if("Monsters")
			for(var/mob/Enemy/P)
				P.SafeTeleport(locate(x+rand(-2,2),y+rand(-2,2),z))
				if(!P.z) del(P)

proc/Delete_List(mob/m)
	var/list/L=new
	if(!m) return L
	for(var/mob/A in players) L+=A
	for(var/atom/A in view(10,src)) L+=A
	for(var/mob/A in view(20,src)) for(var/obj/O in A) L+=O
	return L

mob/Admin2/verb/Delete(atom/A in Delete_List(src))
	set category="Admin"
	if(ismob(A)) world<<"<font color=#FFFF00>[A] has been kicked from the server"
	else Log(src,"[key] deleted [A]")
	del(A)

mob/Admin1/verb/Kick(mob/m in players)
	set category = "Admin"
	clients << "<font color=#FFFF00>[m] has been kicked from the server"
	m.Logout()

mob/Admin2/verb/XYZTeleport(mob/M in players)
	set category="Admin"
	usr<<"This will send the mob you choose to a specific xyz location."
	var/xx=input(src,"X Location?") as num
	var/yy=input(src,"Y Location?") as num
	var/zz=input(src,"Z Location?") as num
	Log(src,"[key] xyz teleported to ([xx],[yy],[zz])")
	switch(input(src,"Are you sure?") in list ("Yes", "No",))
		if("Yes") M.SafeTeleport(locate(xx,yy,zz))

mob/Admin1/verb/AdminHeal(mob/A in players)
	set category="Admin"
	Log(src,"[key] admin healed [A]")
	A.FullHeal()
	if(CheckForInjuries())
		switch(input(src,"Do you want to remove their injuries?") in list("Yes","No"))
			if("Yes")
				for(var/injury/I in injuries)
					I.remove_at = 0
					TryRemoveInjury(I)
	A.IncreaseDetermination(A.GetMaxDetermination())

mob/Admin2/verb/Allow_OOC()
	set category="Admin"
	set name = "Toggle Server OOC"
	Allow_OOC = !Allow_OOC
	world << "OOC is [Allow_OOC ? "enabled" : "disabled"]."

proc/Admin_Msg(Text,Optional=0)
	if(Text)
		for(var/mob/P in players)
			if(P.IsAdmin())
				if(!Optional||P.AdminOn)
					P<<"<font size=[P.TextSize]>[Text]"

mob/Admin1/verb/Chat(msg as text)
	set category="Admin"
	Admin_Msg("(Admin)<font color=[TextColor]>[key]: [msg]",1)

mob/Admin1/verb/Announce(msg as text)
	set category="Admin"
	for(var/mob/M in players)
		M.SendMsg("<font size=[M.TextSize]><font color=white>(Admin) <font color=[TextColor]>[key]: <font color=white>[html_encode(msg)]", ALL_CHAT)

mob/Admin1/verb/KO_Someone(mob/M in players)
	set category="Admin"
	set name="KO"
	Log(src,"[key] admin KO'd [M.key]")
	M.KnockOut(can_anger = 0) //bypass anger

mob/Admin1/verb/Admin_Revive(mob/M in players)
	set category="Admin"
	var/confirm=input("Are you sure you wish to do this? (Admin Revive - [M.name])") in list("Yes","No")
	if(confirm=="No") return
	Log(src,"[key] revived [M.key]")
	M.RegainConsciousness()
	M.Revive()

mob/Admin2/verb/World_Heal()
	set category="Admin"
	Log(src,"[key] world healed")
	spawn for(var/mob/M in players) M.FullHeal()

mob/Admin1/verb/Teleport(mob/M in Summon_List())
	set category="Admin"
	Log(src,"[key] teleported to [M.key]")
	SafeTeleport(M.loc)

proc/Summon_List()
	var/list/L=new
	for(var/mob/P) if(P.z)
		var/mob/M
		for(M in L) if(M.name==P.name) break
		if(!M) L+=P
	return L

mob/Admin1/verb/Summon(mob/M in Summon_List())
	set category="Admin"
	var/confirm=input("Are you sure you wish to do this? (Summon - [M.name])") in list("Yes","No")
	if(confirm=="No") return
	Log(src,"[key] summoned [M.key]")
	M.SafeTeleport(loc)

var/list/Mutes=new

mob/Admin1/verb/Mute()
	set category="Admin"
	var/list/A=new
	A+="Cancel"
	for(var/mob/B in players) if(B.client)
		A+=B
		if(Mutes.Find(B.key)) usr<<"[B]([B.key]) is muted"
	var/mob/M=input(src,"") in A
	if(M=="Cancel") return
	if(!Mutes.Find(M.key))
		usr<<"You mute [M]."
		var/duration=input("How long is the mute in hours?",3) as num
		Mutes[M.key]=world.realtime+(duration*(60*60*10))
		world<<"[M] has been muted for [duration] hours."
		Log(src,"[key] muted [M.key]")
	else
		Mutes.Remove(M.key)
		world<<"[M] has been un-muted."
		Log(src,"[key] unmuted [M.key]")

mob/Admin1/verb/MassUnMute()
	set category="Admin"
	var/confirm=input("Are you sure you wish to do this?") in list("Yes","No")
	if(confirm=="No") return
	Log(src,"[key] unmuted everyone.")
	for(var/A in Mutes)
		world<<"[A] was unmuted"
		Mutes-=A

var/list/Bans=new

proc/Bannables()
	var/list/L=list("Cancel","View Bans","Unban Single","Unban All")
	for(var/mob/P in players) if(P.client) L+=P
	return L

mob/Admin1/verb/Ban(mob/P as anything in Bannables())
	set category="Admin"
	if(!ismob(P))
		switch(P)
			if("Cancel") return
			if("View Bans")
				while(src)
					var/list/L
					for(var/V in Bans)
						if(!L) L=list("Cancel")
						L+=V
					if(!L)
						src<<"There are no bans"
						return
					var/C=input(src,"Click a ban you want more info about. You can see the reason, time remaining, etc by \
					using this.") in L
					if(C=="Cancel")
						Ban()
						return
					L=Bans[C]
					src<<"Key: [L["Key"]]"
					src<<"IP: [L["IP"]]"
					src<<"Computer ID: [L["CID"]]"
					src<<"Reason: [L["Reason"]]"
					var/Time_Remaining=round((L["Timer"]-world.realtime)/10/60/60,0.01)
					src<<"Time Remaining: [Time_Remaining] hours"
					sleep(5)
			if("Unban Single")
				var/list/L=list("Cancel")
				for(var/V in Bans) L+=V
				var/Unban=input(src,"Unban who?") in L
				if(Unban=="Cancel")
					Ban()
					return
				L=Bans[Unban]
				world<<"[displaykey] unbanned [L["Key"]]"
				Log(src,"[key] unbanned [L["Key"]]")
				Bans-=Unban
				Save_Ban()
			if("Unban All")
				var/confirm=input("Are you sure you wish to do this? (Mass Unban)") in list("Yes","No")
				if(confirm=="No") return
				world<<"[src] massunbanned."
				for(var/V in Bans)
					var/list/L=Bans[V]
					world<<"[L["Key"]] was unbanned"
					Bans-=V
				world<<"Mass unban complete."
				Log(src,"[key] mass unbanned")
				Save_Ban()
		return
	var/mob/M=P
	if(!M||!M.client) return
	var/Key=M.displaykey
	var/IP=M.client.address
	var/CID=M.client.computer_id
	var/Reason=input(src,"Input a ban reason. Do not leave it blank, it's admin abuse.") as text
	var/Timer=input(src,"Input a ban expiration in hours. Maximum is 240 hours (10 days).") as num
	if(Timer<0.1) Timer=0.1
	Apply_Ban(M,Timer,Key,Reason,key,IP,CID)
	Log(src,"[key] banned [Key]")

mob/Admin1/verb/Manual_Ban()
	set category="Admin"
	var/k=input("What key do you want to ban?") as text
	var/i=input("What ip do you want to ban?") as text
	var/c=input("What cid do you want to ban?") as text
	var/t=input("How long is the ban in hours?") as num
	var/r=input("For what reason are they banned?") as text
	if(t<0.1) t=0.1
	Apply_Ban(null,t,k,r,key,i,c)
	Log(src,"[key] manual banned [k]")

proc/Apply_Ban(mob/M,Timer=2,Key,Reason,Banner,IP,CID)
	if(!Key||!IP||!CID||!Timer) return
	Timer=round(Timer,0.1)
	world<<"[Key] was banned."
	world<<"Reason: [Reason]."
	world<<"Time: [Timer] hours."
	world<<"Banned by: [Banner]"
	if(Limits.GetSettingValue("Max Ban")) Timer = Time.ToHours(Math.Max(Time.FromHours(Timer), Limits.GetSettingValue("Max Ban")))
	var/RealTime=world.realtime + (Timer * 60 * 600) //Timer converted from hours to 1/10th seconds
	Bans["[Key] ([Timer] Hours)"]=list("Key"=Key,"IP"=IP,"CID"=CID,"Reason"=Reason,"Timer"=RealTime)
	if(M)
		M.Save()
		for(var/mob/Alt in players) if(Alt!=M&&Alt.client&&Alt.client.address==M.client.address)
			world<<"[Alt.displaykey] was banned (Alt)"
			Alt.Save()
			del(Alt)
		del(M)
	Save_Ban()

client/proc/Ban_Check()
	if(coded_admins[key]) return
	for(var/L in Bans)
		var/list/V=Bans[L]
		if(V["Key"]==key||V["CID"]==computer_id) //||V["IP"]==address)
			var/Time_Remaining=round((V["Timer"]-world.realtime)/10/60/60,0.01)
			if(Time_Remaining<=0)
				world<<"The ban on [V["Key"]] has expired. They have logged back in."
				world<<"Ban Reason: [V["Reason"]]"
				Bans-=L
			else
				src<<"<font size=3><font color=red>You are banned.<br>\
				Reason: [V["Reason"]]<br>\
				Time Remaining: [Time_Remaining] hours"
				spawn(1) if(src) del(src)
			return

mob/Admin3/verb/MassKO()
	set category="Admin"
	var/confirm=input("Are you sure you wish to do this? (Mass KO)") in list("Yes","No")
	if(confirm=="No") return
	Log(src,"[key] knocked out everyone.")
	for(var/mob/A in players) if(A.client) spawn A.KnockOut("admin")

mob/proc/Edit_List()
	var/list/L=new
	for(var/mob/P in players)
		L+=P
		for(var/obj/O in P) L+=O
	for(var/obj/O in view(20,src)) L+=O
	for(var/mob/P in view(40,src)) L+=P
	for(var/turf/A in view(20,src)) L+=A
	for(var/area/A in all_areas) L+=A
	return L

var/list/editFilter = list("type", "parent_type", "vars")
var/list/configFilter = list("name", "tag", "type", "parent_type", "vars", "settings")

var/list/configs = list(Progression, Mechanics, Limits, Social)

mob/Admin4/verb/ExportConfigs()
	Save_Config()

mob/Admin4/verb/ImportConfigs()
	Load_Config()

mob/Admin4/verb/Edit_Config(config/C in configs)
	set category = "Admin"
	var/html = "<head>[KHU_HTML_HEADER]<title>Edit [C.name]</title></head>"
	html += "<body bgcolor=#000000 text=#339999 link=#99FFFF>"
	html += "<h3>[C.name]</h3>"
	html += "<table width=90% style='padding-left:5%;border-collapse: collapse'>"
	for(var/setting/S in C.settings)
		html += "<tr style='border:3px solid #247373;padding:2px'>"
		html += "<td style='border-left:1px solid #247373'>"
		html += "<a href=byond://?src=\ref[C];action=edit;setting=[ckey(S.name)]>"
		html += "[S.name]</a></td>"
		html += "<td style='border-left:1px solid #247373'>"
		html += "[S.Get()]</td></tr>"
	html += "</table></body></html>"
	usr << output(html, "config_browser")
	winshow(usr, "edit_config", 1)
	Log(src, "[key] opened the config menu for [C]")

config/Topic(href, hrefs[])
	if(hrefs["action"] == "edit")
		if(!usr || !usr.client || !usr.IsAdmin()) return
		var/setting/S = GetSetting(hrefs["setting"])
		if(S && istype(S, /setting))
			S.Set(S.Input(usr))
			Save_Config()
			usr:Edit_Config(src)
		. = ..()

mob/Admin3/verb/Edit(atom/a in world)
	set category = "Admin"
	set background = TRUE
	set waitfor = FALSE
	var/html = "<Edit><body bgcolor=#000000 text=#339999 link=#99FFFF>"
	html += "[a]<br>[a.type]"
	html += "<table width=90% style='padding-left:5%;border-collapse: collapse'>"
	for(var/v in a.vars)
		if("[v]" in editFilter)
			continue
		html += "<tr style='border:3px solid #247373;padding:2px'>"
		html += "<td style='border-left:1px solid #247373'>"
		html += "<a href=byond://?src=\ref[a];action=edit;var=[v]>"
		html += "[v]</a></td>"
		html += "<td style='border-left:1px solid #247373'>"
		html += "[Value(a.vars[v])]</td></tr>"
		sleep(-1)
	html += "</table></body></html>"
	usr << output(html, "config_browser")
	winshow(usr, "edit_config", 1)
	Log(src, "[key] opened the edit sheet for [a]")

atom/Topic(href, hrefs[])
	if(hrefs["action"] == "edit")
		if(!usr || !usr.client || !usr.IsAdmin()) return
		var/v = hrefs["var"]
		//this is to try and prevent a teleport hack
		if(ismob(src) && src:client && "[v]" in list("x","y","z","loc"))
			return
		var/class = input(usr, "[v]") as null|anything in list("Number", "Text", "File", "Empty List", "Nothing")
		if(!class) return
		switch(class)
			if("Nothing") vars[v] = null
			if("Text") vars[v] = input(usr, "", "", vars[v]) as text
			if("Number") vars[v]=input(usr, "", "", vars[v]) as num
			if("File") vars[v]=input(usr, "", "", vars[v]) as file
			if("Empty list") vars[v] = new/list
		Log(usr, "[usr.key] edited [src]'s [v] var to [Value(vars[v])]")
		usr:Edit(src)
		. = ..()

mob/Topic(href, hrefs[])
	if(hrefs["action"] == "trans")
		var/t = hrefs["form"]
		if(t in UnlockedTransformations)
			var/transformation/T = UnlockedTransformations[t]
			if(T)
				var/v = hrefs["var"]
				switch(v)
					if("Name") T.UpdateName(src)
					if("Description") T.desc = input(src, "Set description of [T.name] to what?", "Edit Description", T.desc) as message
					if("Mastery")
						T.mastery = input(src, "Set mastery of [T.name] to what %?", "Edit Mastery", T.mastery) as num
						if(T.mastery < 100) T.mastered = 0
						else T.mastered = 1
	..()

proc/Value(A)
	if(isnull(A)) return "Nothing"
	else if(isnum(A)) return "[num2text(round(A,0.01),20)]"
	else return "[A]"

proc/Commas(N)
	if(istext(N)) return N
	if(N<1000000) return round(N)
	N=num2text(round(N,1),20)
	for(var/i=length(N)-2,i>1,i-=3) N="[copytext(N,1,i)]'[copytext(N,i)]"
	return N

proc/Direction(A) switch(A)
	if(1) return "North"
	if(2) return "South"
	if(4) return "East"
	if(5) return "Northeast"
	if(6) return "Southeast"
	if(8) return "West"
	if(9) return "Northwest"
	if(10) return "Southwest"
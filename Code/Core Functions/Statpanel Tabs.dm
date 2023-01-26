var
	tabStartupDelay = 10

mob/Stat()
	if(!client)
		return
	Stat_Admin()
	if(Ship)
		Stat_Nav()
		Stat_Ship()
	Stat_Items()
	if(HasModules())
		Stat_Modules()
	if(Has_Souls())
		Stat_Souls()
	if(Vampire)
		Stat_Vampire()
	if(Has_Scouter())
		Stat_Scouter()
	else if(Has_Sense())
		Stat_Sense()
	if(IsAdmin() && Has_Target())
		Stat_Inspect()
	if(Equipped_Radar())
		Stat_Radar()

mob/var/tmp/obj/sense3_obj
mob/var/tmp/obj/sense2_obj
mob/var/tmp/detect_androids

var/very_high_knowledge_min = 0.95

mob/proc/KnowledgeRating()
	var/knowledge_rating
	if(Knowledge >= Tech_BP * very_high_knowledge_min) knowledge_rating="Very High"
	else if(Knowledge >= Tech_BP*0.8) knowledge_rating="High"
	else if(Knowledge >= Tech_BP*0.65) knowledge_rating="Medium"
	else if(Knowledge >= Tech_BP*0.5) knowledge_rating="Low"
	else knowledge_rating = "Very Low"
	return knowledge_rating

mob/proc/Has_Senseable_Target()
	return Has_Target() && CanSense(src, Target)

mob/proc/Has_Target()
	return Target && ismob(Target)

mob/proc/Stat_Inspect()
	if(statpanel("Inspect") && Target)
		stat(Target.contents)

mob/proc/Stat_Vampire() if(statpanel("Smell"))
	stat("Any non-vampire within 10 tiles of you will appear here because you can smell non-vampires")
	if(current_area) for(var/mob/P in current_area.player_list)
		if(P.client&&!P.Vampire&&getdist(src,P)<20)
			stat(P)

mob/proc/Has_Souls()
	return (locate(/obj/Contract_Soul) in src)

mob/proc/Stat_Souls() 
	if(statpanel("Souls"))
		for(var/obj/Contract_Soul/CS in src) if(CS.suffix) stat(CS)
		for(var/obj/Contract_Soul/CS in src) if(!CS.suffix) stat(CS)

mob/proc/Stat_Modules()
	if(statpanel("Modules"))
		for(var/obj/Module/M in src) stat(M)

mob/proc/Stat_Items()
	if(statpanel("Items"))
		var/obj/Resources/r = GetResourceObject()
		if(r)
			r.Update_value()
			stat(r)
		for(var/obj/O in item_list) stat(O)

mob/proc/Stat_Ship()
	if(statpanel("[Ship]"))
		if(!Ship) return
		stat("Coordinates","[Ship.x], [Ship.y], [Ship.z]")
		stat(Ship.contents)
		stat("Health","[Commas(Ship.Health/Ship.BP*100)]%")
		stat("Energy","[round(Ship.Ki)]%")
		stat("BP","[Commas(Ship.BP)]")
		stat("Strength",Ship.Str)
		stat("Durability",Ship.Dur)
		stat("Speed",Ship.Spd)
		stat("Efficiency",Ship.Eff)

mob/proc/Stat_Nav()
	var/turf/T=base_loc()
	if(T&&T.z==16) for(var/obj/items/Nav_System/N in item_list)
		var/Panel_Name="Nav"
		if(Ship) Panel_Name="[Ship]"
		if(statpanel(Panel_Name))
			for(var/obj/Planets/A in planets) if(A.z)
				if(N.Upgrade_Level>=A.Nav_Level) stat("[getdir(T,A.loc)] x[getdist(T,A)]",A)
		break

mob/proc/Stat_Admin() if(IsAdmin())
	if(statpanel("World"))
		stat("BYOND version:","[world.byond_version].[world.byond_build]")
		stat("World IP:", "[world.internet_address][world.port ? ":[world.port]" : ""]")
		stat("Highest Players Ever:",highest_player_count)

		stat("")
		stat("Server Time & Date:", time2text(world.realtime, "DDD MMM DD hh:mm YYYY"))
		stat("Wipe Start Date:", time2text(WipeStartDate, "DDD MMM DD YYYY"))

		if(IsCodedAdmin())
			stat("Avg_BP",Commas(Avg_BP))
			stat("Highest Avg_BP this reboot",Commas(highest_avg_bp_this_reboot))
		
		stat("Blast cache size",cached_blasts?.len)
		stat("")
		stat("Record CPU Usage", "[highestCpuUsage]%")
		stat("Processor","[world.cpu]%")
		stat("Tick Usage", "[world.tick_usage]%")
		var/actualTPS = Math.Ceil(world.fps * (1 - Math.Max((world.tick_usage / 100) - 1, 0)))
		stat("Target TPS", "[num2text(Math.Clamp(actualTPS, 0.000001, world.fps), 6)]/[world.fps]")
		stat("Client FPS", client.fps)
		stat("")
		stat("Year","[round(GetGlobalYear(),0.1)] (Speed: [Social.GetSettingValue("Year Speed")]x)")
		stat("Gain","[Progression.GetSettingValue("BP Gain Rate")]x")
		stat("Highest Stats",Commas(Stat_Record))
		stat("Highest stats guy:",stat_record_mob)
		stat("Highest Speed",Commas(Max_Speed))
		stat("Highest Speed person:",max_speed_mob)
		stat("Highest Base BP",Commas(player_with_highest_base_bp?.base_bp))
		stat("Highest Base BP person:",player_with_highest_base_bp)
		stat("Highest Power Tier",Commas(highestBPTier))
		stat("Highest Power Tier person:",playerWithHighestTier)
		stat("Global Upgrade Cap",Commas(Tech_BP))

	if(statpanel("Who"))
		var/playerCount = clients.len + trollbots.len

		stat("Players:", playerCount)
		stat("Average BP:","[Commas(Average_BP_of_Players())]")
		for(var/mob/P in players) stat("[Commas(P.BP)]",P)

mob/var/tmp/Safezone
mob/proc/Stat_Stat()
	set background = TRUE
	set waitfor = FALSE
	if(statpanel("Stats"))
		var/transformation/current = GetActiveForm()
		if(current)
			stat("Current Form:", current.name)
			stat("Form Mastery:", "[round(current.mastery,0.1)]%")

		if(current_buff)
			stat("Current Buff:", current_buff.name)

		if(bleedStacks.len)
			stat("Bleeding x[bleedStacks.len]")

		if(current_area && current_area.type == /area/Braal_Core)
			stat("Core Gains:", "[round(CoreGainsMult(),0.1)]x / [round(CoreMaxGainsMult(),0.1)]x")
			stat("Core Time Remaining:", "[round(Time.ToHours(coreGainsTimer),0.01)] hours")

		if(grabber) stat("Grab strength: [round(grabber.grab_power)]%")

		if(God_Fist_level)
			stat("God-Fist x[God_Fist_level]")
			stat("God Fist Mastery: [round(GodFistMastery,0.1)]%")

		if(Safezone) stat("You are in the safezone")
		if(Vampire) stat("Vampire Hunger %",Vampire_Infection)

		if(Action == "Meditating")
			stat("Knowledge:","[Commas(Knowledge*Intelligence())] ([KnowledgeRating()])")

		if(Gravity>gravity_mastered)
			stat("Gravity",round(Gravity,0.1))
		var/bp_mod_display_mult = 1 * effectiveBaseBPMult()

		stat("Battle Power","[Commas(Scouter_Reading(src))] ([round(bp_mod * weights() * GravityGainsMult() * bp_mod_display_mult, 0.01)]x gains)")
		stat("Power Tier", effectiveBPTier)

		stat("Health",round(Health))
		stat("Energy","[round(Ki)] ([round((Ki / max_ki) * 100)]%) ([Eff]x gains)")

		stat("Strength", "[Str] ([GetReadableStatMod("Str")])")
		stat("Durability", "[End] ([GetReadableStatMod("Dur")])")
		stat("Force", "[Pow] ([GetReadableStatMod("For")])")
		stat("Resistance", "[Res] ([GetReadableStatMod("Res")])")
		stat("Speed", "[Spd] ([GetReadableStatMod("Spd")])")
		stat("Accuracy", "[Off] ([GetReadableStatMod("Acc")])")
		stat("Reflex", "[Def] ([GetReadableStatMod("Ref")])")

		var/regenLabel = (regen + Regen_Mult - 1) * DuraRegenMod()
		stat("Regeneration", round(regenLabel, 0.01))
		//stat("Regeneration",round(regen + Regen_Mult-1,0.01))
		stat("Recovery",round(recov + Recov_Mult-1,0.01))
		stat("Move Speed (pixels):", round(stepSizeLabel,0.1))
		stat("Melee Speed:", round(1 / (Speed_delay_mult(severity = melee_delay_severity) / speedDelayMultMod), 0.01))

mob/proc
	StatViewThing(n = 1, statName)
		var/n2 = (effectiveBaseBp + cyber_bp)
		n2 = abs(n2) //prevent error - illegal operation pow(-1100, 0.32)
		n2 = n2 ** 0.32
		n2 /= 10
		n *= n2
		return round(n)

proc/getdir(obj/A,obj/B) return Direction(get_dir(A,B))

atom/proc/locz()
	var/turf/T=base_loc()
	if(T) return T.z

atom/proc/base_loc()
	var/turf/t = src
	var/tries = 5
	while(t && !isturf(t))
		t = t.loc
		tries--
		if(!tries) break
	if(!isturf(t)) return null
	return t

mob/var/tmp/list/Radar_List=new
mob/var/tmp/obj/items/Radar/radar_obj

mob/proc/Equipped_Radar()
	return radar_obj && radar_obj.suffix && radar_obj.Detects && radar_obj.loc == src

mob/proc/Stat_Radar()
	var/obj/items/Radar/R=radar_obj
	if(statpanel("Radar"))
		var/turf/T=base_loc()
		if(IsAdmin()) stat("CPU","[world.cpu]%")
		if(!T) return
		stat("Location","([T.x],[T.y],[T.z])")
		for(var/obj/O in Radar_List)
			if(istype(O, R.Detects) && !Inert_Dragon_Ball(O))
				var/mob/M=O.loc
				if(M&&locz()!=M.locz()) stat("In a cave",O)
				else if(!(O in T)) stat("[getdir(T,M)] x[getdist(T,M)]",O)

mob/proc/update_radar_loop()
	set waitfor=0
	while(src)
		if(client && client.statpanel == "Radar" && get_area())
			var/area/area=get_area()
			var/obj/items/Radar/r=radar_obj
			if(r && r.suffix && r.loc==src && r.Detects)
				var/detects=r.Detects
				update_radar()
				for(var/n=0,n<7,n++)
					if(get_area()!=area || !r || !r.suffix || r.Detects!=detects) break
					sleep(10)
		sleep(20)
		if(!client) sleep(100) //clones lag a lot with this if there is many of them

mob/proc/UpdateRadar()
	Radar_List = list()
	var/obj/items/Radar/r=radar_obj
	for(var/mob/m in current_area.player_list)
		for(var/obj/o in m)
			if(istype(o,r.Detects) && !Inert_Dragon_Ball(o) && o.can_radar)
				Radar_List+=o
				if(istype(o,/obj/Resources)&&o:Value<50000)
					Radar_List-=o
	for(var/obj/o in current_area)
		if(o.can_radar && istype(o,r.Detects) && !Inert_Dragon_Ball(o))
			Radar_List+=o

mob/proc/update_radar()
	Radar_List=new/list
	var/obj/items/Radar/r=radar_obj
	if(r&&r.suffix&&r.Detects&&r.loc==src&&current_area)
		for(var/mob/m in current_area.player_list) for(var/obj/o in m)
			if(istype(o,r.Detects) && !Inert_Dragon_Ball(o) && o.can_radar)
				Radar_List+=o
				if(istype(o,/obj/Resources)&&o:Value<50000) Radar_List-=o
		for(var/obj/o in current_area) if(o.can_radar && istype(o,r.Detects) && !Inert_Dragon_Ball(o))
			Radar_List+=o

atom/proc/get_area()
	var/turf/t = base_loc()
	if(!t) return null
	return t.loc

mob/var/tmp/obj/sense_obj
mob/var/sort_sense_by="power"

mob/var
	tmp
		list/sense_list = new
		last_sense_list_update = 0

proc/CanSense(mob/a, mob/b) //can a sense b?
	if(!ismob(a) || !ismob(b)) return null
	return !( ( a != b ) && ( b.hiding_energy || ( b.Is_Cybernetic() && !a.CanSenseCybers() ) ) )

//dont use this one, use CanSense()
mob/proc/Scannable(detect_androids,mob/by)
	. = TRUE
	if(hiding_energy || ((Android || cyber_bp) && !(detect_androids || Cyber_Scanner))) return FALSE
	/*if(src == by) return 1
	if(!detect_androids&&!Cyber_Scanner)
		if(Android||cyber_bp) return
	if(hiding_energy&&!cyber_bp) return
	return 1*/

mob/proc/CanSenseCybers()
		if(Cyber_Scanner) return 1
		if(Scouter && Scouter.android_detection) return 1

mob/proc/Has_Sense()
	return HasSkill(/obj/Skills/Utility/Sense) && !Scouter && !Android && client

mob/proc/Stat_Sense()
	set background = TRUE
	if(statpanel("Sense"))
		var/turf/t = base_loc()
		if(!t) return
		stat("Location","([t.x],[t.y],[t.z])")

		if(current_area)
			var/sense_list_update_rate = TickMult(3) //2 = 5 fps
			if(world.time - last_sense_list_update >= sense_list_update_rate)
				last_sense_list_update = world.time
				sense_list = new/list
				for(var/mob/m in current_area.mob_list) //use mob_list or player_list or npc_list
					if(m.type == /mob/Body || !m.canBeSensed) continue
					if(m.loc && (m.client || getdist(src,m) < 35 || istype(m, /mob/new_troll)) && !m.Android && !m.hiding_energy && !m.cyber_bp)
						if(Race == "Android")
							if(sort_sense_by=="power") sense_list[m]=Sense_Power(m)
							else if(sort_sense_by=="distance")
								var/dist=getdist(src,m)
								if(m.locz()!=t.z) dist=999
								sense_list[m]=1 / (dist+1)
				sense_list = Bubble_sort(sense_list)

			//we reduced string concatenation as much as possible here
			for(var/mob/m in sense_list)
				if(m.locz() == t.z)
					stat("[Sense_Power(m)]%. [getdir(t,m.loc)] [getdist(t,m.loc)]",m)
				else stat("[Sense_Power(m)]%. In a cave.",m)

proc/Bubble_sort(list/l)
	var/i, j
	for(i=l.len,i>0,i--)
		for(j=1,j<i,j++)
			if(l[l[j]]<l[l[j+1]])
				l.Swap(j,j+1)
	return l

mob/var/canBeSensed = 1

mob/proc/Has_Scouter()
	return (Scouter && Scouter.suffix) || Cyber_Scanner

mob/proc/Stat_Scouter()
	if(statpanel("Scan"))
		var/turf/T=base_loc()
		if(!T) return
		stat("Location","([T.x],[T.y],[T.z])")

		if(current_area)
			var/list/sense_list=new
			for(var/mob/m in current_area.mob_list) //use mob_list, player_list, or npc_list
				if(m.type == /mob/Body || !m.canBeSensed) continue
				if(m.loc && (m.client || getdist(src,m)<35 || istype(m, /mob/new_troll)) && CanSense(src, m))
					if(sort_sense_by=="power") sense_list[m]=Scouter_Reading(m,Scouter,unlimited=1)
					else if(sort_sense_by=="distance")
						var/dist=getdist(src,m)
						if(m.locz()!=T.z) dist=999
						sense_list[m]=dist
			sense_list=Bubble_sort(sense_list)

			for(var/mob/M in sense_list)
				var/sense_display="[Commas(Scouter_Reading(M,Scouter))]."
				if(M.locz()==T.z) sense_display+=" [getdir(T,M.loc)] x[getdist(T,M.loc)]"
				else sense_display+=" In a cave"
				stat(sense_display,M)

mob/var/tmp/obj/items/Scouter/Scouter

mob/proc/IsAdmin()
	return src && client && (IsCodedAdmin() || (key in Admins))


mob/proc/strpcnt()
	return round(Str/getStatTotal()*100,0.1)
mob/proc/durpcnt()
	return round(End/getStatTotal()*100,0.1)
mob/proc/spdpcnt()
	return round(Spd/getStatTotal()*100,0.1)
mob/proc/powpcnt()
	return round(Pow/getStatTotal()*100,0.1)
mob/proc/respcnt()
	return round(Res/getStatTotal()*100,0.1)
mob/proc/offpcnt()
	return round(Off/getStatTotal()*100,0.1)
mob/proc/defpcnt()
	return round(Def/getStatTotal()*100,0.1)

mob/proc
	getStatTotal()
		return Str + End + Pow + Res + Off + Def + Spd

	getAvgStat()
		return getStatTotal() / 7
	
	compareGlobalAvg()
		return getAvgStat() / (Stat_Record * 1.5)

	regen_rating()
		var/n=regen
		if(n<1) return "Very Low"
		if(n<1.4) return "Low"
		if(n<2.6) return "Average"
		if(n<5) return "High"
		if(n<8) return "Very High"
		return "EXTREME"

	recov_rating()
		var/n=recov
		if(n<1) return "Very Low"
		if(n<1.4) return "Low"
		if(n<2.6) return "Average"
		if(n<5) return "High"
		if(n<10) return "Very High"
		return "EXTREME"

	strpcnt_rate()
		switch(GetStatMod("Str"))
			if(-999999 to -2) return "Very Low"
			if(-2 to 0) return "Low"
			if(0 to 1) return "Average"
			if(1 to 3) return "High"
			if(3 to 5) return "Very High"
			else return "EXTREME"

	durpcnt_rate()
		switch(GetStatMod("Dur"))
			if(-999999 to -2) return "Very Low"
			if(-2 to 0) return "Low"
			if(0 to 1) return "Average"
			if(1 to 3) return "High"
			if(3 to 5) return "Very High"
			else return "EXTREME"

	spdpcnt_rate()
		switch(GetStatMod("Spd"))
			if(-999999 to -2) return "Very Low"
			if(-2 to 0) return "Low"
			if(0 to 1) return "Average"
			if(1 to 3) return "High"
			if(3 to 5) return "Very High"
			else return "EXTREME"

	powpcnt_rate()
		switch(GetStatMod("For"))
			if(-999999 to -2) return "Very Low"
			if(-2 to 0) return "Low"
			if(0 to 1) return "Average"
			if(1 to 3) return "High"
			if(3 to 5) return "Very High"
			else return "EXTREME"

	respcnt_rate()
		switch(GetStatMod("Res"))
			if(-999999 to -2) return "Very Low"
			if(-2 to 0) return "Low"
			if(0 to 1) return "Average"
			if(1 to 3) return "High"
			if(3 to 5) return "Very High"
			else return "EXTREME"

	offpcnt_rate()
		switch(GetStatMod("Acc"))
			if(-999999 to -2) return "Very Low"
			if(-2 to 0) return "Low"
			if(0 to 1) return "Average"
			if(1 to 3) return "High"
			if(3 to 5) return "Very High"
			else return "EXTREME"

	defpcnt_rate()
		switch(GetStatMod("Ref"))
			if(-999999 to -2) return "Very Low"
			if(-2 to 0) return "Low"
			if(0 to 1) return "Average"
			if(1 to 3) return "High"
			if(3 to 5) return "Very High"
			else return "EXTREME"

var/Stat_Lag=0
mob/Admin4/verb/Tab_Refresh_ToOne()
	set category="Admin"
	Stat_Lag = Time.FromSeconds(input(src,"Current tab refresh delay is [Time.ToSeconds(Stat_Lag)] seconds, enter a new amount","Options",Time.ToSeconds(Stat_Lag)) as num)
mob/var/Tabs

mob/proc/Sense_Power(mob/A)
	if(!A || !ismob(A)) return
	var/Yours=src.BP*((GetStatMod("Str"))+(GetStatMod("Dur"))+(GetStatMod("For"))+(GetStatMod("Res"))+(GetStatMod("Spd"))+\
	(GetStatMod("Acc"))+(GetStatMod("Ref")))*(regen**(1/11))*(recov**(1/11))*(Eff**(1/11))
	var/Theirs=A.BP*((A.GetStatMod("Str"))+(A.GetStatMod("Dur"))+(A.GetStatMod("For"))+(A.GetStatMod("Res"))+(A.GetStatMod("Spd"))+\
	(A.GetStatMod("Acc"))+(A.GetStatMod("Ref")))*(regen**(1/11))*(recov**(1/11))*(Eff**(1/11))
	if(Yours<1) Yours=1 //division by zero errors
	var/Power=100*(Theirs/Yours)
	if(A.KO) Power*=0.05
	Power=round(Power)
	if(Power>999) Power=999
	return Power

//#define Scouter_Reading(P) 0.016*P.BP*((P.Off/P.offmod)+(P.Def/P.defmod))*(!P.KO?1:0.05)

proc/Scouter_Reading(mob/B,obj/items/Scouter/S,unlimited)
	var/Max=1.#INF
	if(S && !unlimited) Max=S.Scan
	var/Power=B.BP
	if(B.KO) Power*=0.05
	if(Power>Max) Power="???"
	return Power

mob/verb/Maximize_Button()
	set name=".Maximize_Button"
	set hidden=1
	if(winget(usr,"mainwindow","is-maximized")=="true") winset(src,"mainwindow","is-maximized=false")
	else winset(src,"mainwindow","is-maximized=true")
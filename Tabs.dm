mob/proc/Statpanel(t)
	return statpanel(t)

mob/Stat()
	if(!Tabs)
		sleep(20)
		return
	else if(!client)
		sleep(100)
		return
	else if(Lootables) if(Statpanel("Looting")) stat(Lootables)
	else
		if(client.inactivity>=1800) client.statpanel="Stats"
		Stat_Stat()
		Stat_Admin()
		Stat_Nav()
		Stat_Ship()
		Stat_Items()
		Stat_Modules()
		Stat_Souls()
		Stat_Build()
		Stat_Science()
		Stat_Vampire()
		Stat_Scouter()
		Stat_Radar()
		Stat_Sense()
		Stat_Sense_Tab()
		Stat_leagues()
		saga_tab()
		Sleep_tabs()
mob/proc/Sleep_tabs()
	if(!client) return
	var/current_tab=client.statpanel
	if(!tabs_hidden&&client.inactivity<600)
		var/sleep_time=(world.cpu-40)/3
		sleep_time=Clamp(sleep_time,0,30)
		if(sleep_time<3&&world.cpu>20) sleep_time=3
		sleep_time=To_tick_lag_multiple(sleep_time/3)
		if(sleep_time)
			var/time_slept=0
			while(src)
				if(client && current_tab==client.statpanel)
					sleep(world.tick_lag*3)
					time_slept+=world.tick_lag*3
					if(time_slept>=sleep_time) break
				else break
	else if(client.inactivity<1800)
		for(var/v in 1 to 4)
			if(client&&(client.statpanel!=current_tab||(client.inactivity<600&&!tabs_hidden))) break
			else sleep(15)
	else for(var/v in 1 to 20)
		if(client&&(client.inactivity<1800||client.statpanel!=current_tab)) break
		else sleep(20)

mob/verb/Resetinactivity() //called by infowindow.info.on-tab
	set hidden=1
	return



mob/proc/saga_tab()
	if(!sagas||!sagas_tab) return
	if(Statpanel("Sagas"))
		var/mob/h=hero_online()
		var/mob/v=villain_online()
		if(!h||!v) return
		stat("It is currently the [v] saga")
		stat("Main hero:",h)
		stat("Main villain:",v)
		stat("The main villain has [v.showdown_time] minutes to kill the hero or they lose the villain \
		title")
		if(world.realtime<h.training_period)
			v.good_kills=0
			var/minutes=(h.training_period-world.realtime)/10/60
			stat("The main hero is currently in a 10x bp gain training period to defeat the villain. They \
			have [minutes] minutes left to train.")
		else if(v.good_kills>killing_spree_min)
			stat("[v] is killing good people to draw [h] out from hiding. [v] has killed \
			[v.good_kills] innocents so far. If [h] does not respond before the count reaches \
			[killing_spree_max] they will \
			be considered a failure as a hero and lose the title")

mob/var/tmp/list/league_list=new
mob/proc/Stat_leagues()
	for(var/obj/League/L in league_list)
		if(Statpanel(L.name))
			stat(L)
			stat("Leader: [L.leaders_name]")
			stat("Members:")
			for(var/mob/P in players) for(var/obj/League/L2 in P.league_list) if(L2.league_id==L.league_id)
				stat("Rank [L2.league_rank]",P)

mob/var/tmp/obj/sense3_obj
mob/var/tmp/obj/sense2_obj
mob/var/tmp/detect_androids
mob/proc/Stat_Sense_Tab() if(Target&&ismob(Target))

	if(Scouter&&Scouter.android_detection)
		detect_androids=1
	else detect_androids=0
	if(Race=="Icer"&&!Scouter&&!Cyber_Scanner) return
	if(!sense2_obj) sense2_obj=locate(/obj/Advanced_Sense) in src
	if(!sense3_obj) sense3_obj=locate(/obj/Sense3) in src
	if(!(sense2_obj||sense3_obj)&&!Scouter) return

	if(Target.Scannable(detect_androids,src))
		if(Statpanel("[Target]"))
			if(Target!=src)
				var/turf/T=True_Loc()
				if(T&&isturf(T))
					if(Target.z!=T.z) stat("[Target] is on a different map")
					else stat("[getdir(T,Target.loc)] x[getdist(T,Target.loc)]",Target)
			if(!sense3_obj&&Race!="Icer")
				if(!Scouter||(Scouter&&!Scouter.suffix)) stat("Power","[Sense_Power(Target)]% your power")
				else stat("[Commas(Scouter_Reading(Target,Scouter))]",Target)
				stat("Health","[round(Target.Health)]%")
				stat("Energy","[round(Target.Ki/Target.max_ki*100)]%")
			else
				if(!Scouter||(Scouter&&!Scouter.suffix)) stat("Power","[Sense_Power(Target)]% your power")
				else stat("[Commas(Scouter_Reading(Target,Scouter))]",Target)
				if(alignment_on)
					if(Target.alignment=="Good") stat("[Target]'s energy is that of a good person")
					else stat("[Target] has an evil energy")
				stat("Health","[round(Target.Health)]%")
				stat("Energy","[round(Target.Ki)] ([round(Target.Ki/Target.max_ki*100)]%)")
				stat("Current anger","[round(Target.anger*0.01,0.01)]x")
				stat("Gravity Mastered","[round(Target.gravity_mastered,0.01)]x")
				stat("Race","[Target.Race] [Target.Class]")
				stat("Age","[round(Target.Age,0.1)] ([round(Target.Body*100)]% Youth)")
				var/knowledge_rating
				if(Target.Knowledge>=Tech_BP*0.95) knowledge_rating="Very High"
				else if(Target.Knowledge>=Tech_BP*0.9) knowledge_rating="High"
				else if(Target.Knowledge>=Tech_BP*0.8) knowledge_rating="Medium"
				else if(Target.Knowledge>=Tech_BP*0.6) knowledge_rating="Low"
				else knowledge_rating="Very Low"
				stat("Scientific Knowledge:",knowledge_rating)

				if(Target.Race=="Android")
					stat("Android stat builds are unsensable")
				else
					stat("Strength:","[Target.strpcnt_rate()]")
					stat("Durability:","[Target.durpcnt_rate()]")
					stat("Speed:","[Target.spdpcnt_rate()]")
					stat("Force:","[Target.powpcnt_rate()]")
					stat("Resistance:","[Target.respcnt_rate()]")
					stat("Offense:","[Target.offpcnt_rate()]")
					stat("Defense:","[Target.defpcnt_rate()]")
					stat("Regeneration:","[Target.regen_rating()]")
					stat("Recovery:","[Target.recov_rating()]")

			Stat_To_multiple_of_one(10)
	if(Is_Admin()) if(Statpanel("Inspect"))
		//Put some details here
		stat(Target.contents)

mob/proc/Stat_Vampire() if(Vampire&&Statpanel("Smell"))
	stat("Any non-vampire within 10 tiles of you will appear here because you can smell non-vampires")
	if(current_area) for(var/mob/P in current_area.player_list)
		if(P.client&&!P.Vampire&&getdist(src,P)<20)
			stat(P)

mob/proc/Stat_Science() if(Intelligence&&TechTab&&Statpanel("Science"))
	stat("Knowledge:",Commas(Knowledge*Intelligence))
	if(resource_obj)
		resource_obj.Update_value()
		stat(resource_obj)
	for(var/obj/O in Technology_List) if(!(O.type in Illegal_Science))
		stat("[Commas(Item_cost(src,O))]$",O)
	Stat_To_multiple_of_one(100)

mob/proc/Stat_Build() if(Build&&Statpanel("Build"))
	stat(Builds)
	Stat_To_multiple_of_one(100)

mob/proc/Stat_Souls() if(locate(/obj/Contract_Soul) in src)
	if(Statpanel("Souls"))
		for(var/obj/Contract_Soul/CS in src) if(CS.suffix) stat(CS)
		for(var/obj/Contract_Soul/CS in src) if(!CS.suffix) stat(CS)
		Stat_To_multiple_of_one(10)

mob/proc/Stat_Modules() for(var/obj/Module/MM in src)
	if(Statpanel("Modules"))
		for(var/obj/Module/M in src) stat(M)
		Stat_To_multiple_of_one(10)
	break

mob/proc/Stat_Items() if(Statpanel("Items"))
	if(resource_obj)
		resource_obj.Update_value()
		stat(resource_obj)
	for(var/obj/items/O in item_list) stat(O)
	//for(var/obj/Faction/F in src) stat(F)
	Stat_To_multiple_of_one(5)

mob/proc/Stat_Ship() if(Ship&&Statpanel("[Ship]"))
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
	var/turf/T=True_Loc()
	if(T&&T.z==16) for(var/obj/items/Nav_System/N in item_list)
		var/Panel_Name="Nav"
		if(Ship) Panel_Name="[Ship]"
		if(Statpanel(Panel_Name))
			for(var/obj/Planets/A in planets) if(A.z)
				if(N.Upgrade_Level>=A.Nav_Level) stat("[getdir(T,A.loc)] x[getdist(T,A)]",A)
			Stat_To_multiple_of_one(5)
		break

mob/proc/Stat_Admin() if(Is_Admin())
	if(Statpanel("World"))
		var/turf/T=True_Loc()

		stat("BYOND version:",world.byond_version)

		if(Is_Tens())
			stat("Avg_BP",Commas(Avg_BP))
			stat("Highest Avg_BP this reboot",Commas(highest_avg_bp_this_reboot))

		var/cache_count=0
		for(var/obj/o in cached_blasts) cache_count++
		stat("Blast cache size",cache_count)

		if(active_zombie_list.len) stat("Active Zombies",active_zombie_list.len)
		if(zombie_cache.len) stat("Cached Zombies",zombie_cache.len)

		if(Swarms) stat("Swarms",Swarms)
		if(alignment_on)
			var/evils=0
			var/goods=0
			for(var/mob/m in players) if(m.z)
				if(m.alignment=="Evil") evils++
				if(m.alignment=="Good") goods++
			stat("[evils] evil players. [goods] good players.")
		stat("Processor","[world.cpu]% ([T.x],[T.y],[T.z])")
		stat("Balance rating:","[balance_rating()]")
		stat("FPS",world.fps)
		stat("Year","[round(Year,0.1)] (Speed: [Year_Speed]x)")
		stat("Gain","[Gain]x")
		stat("Highest Stats",Commas(Stat_Record))
		stat("Highest stats guy:",stat_record_mob)
		stat("Highest Speed",Commas(Max_Speed))
		stat("Global Upgrade Cap",Commas(Tech_BP))
		stat("Shikon jewel possessors:")
		for(var/obj/o in shikon_jewels) if(ismob(o.loc)) stat(o.loc)
		stat("world.realtime:",num2text(world.realtime,20))
	if(Statpanel("Who"))
		var/Total_BPs=0
		for(var/mob/P in players) Total_BPs+=P.BP
		stat("Players:",Player_Count())
		stat("Average BP:","[Commas(Average_BP_of_Players())]")
		for(var/mob/P in players) stat("[Commas(P.BP)]",P)
		Stat_To_multiple_of_one(50)

mob/var/tmp/Safezone
mob/proc/Stat_Stat() if(Statpanel("Stats"))
	if(grabber) stat("Grab strength: [round(grabber.grab_power)]%")
	if(senzu_overload) stat("Overeating debuff [round(senzu_overload/60)] minutes [round(senzu_overload%60)] seconds")
	else if(senzu_timer) stat("You are full for [round(senzu_timer/60)] minutes [round(senzu_timer%60)] seconds")
	if(kaioken_level) stat("Kaioken x[kaioken_level]")
	if(spam_killed) stat("Death immunity: [round(spam_killed/60)] minutes [round(spam_killed%60)] seconds")
	if(Safezone) stat("You are in the safezone")
	if(Diarea>0) stat("Status:","Diarea x[Diarea]")
	//if(Zombie_Virus) stat("Status:","Zombie Virus x[round(Zombie_Virus)]")
	if(Health<0) Health=0
	if(Ki<0) Ki=0
	if(Vampire) stat("Vampire Hunger","[Vampire_Infection]%")
	if(alignment_on&&alignment=="Evil"&&villain_damage_penalty!=1)
		stat("You are doing [villain_damage_penalty*100]% normal damage because there are too many villains")
	//if(available_potential<1)
		//stat("Untapped potential:","[100-round(available_potential*100)]%")

	if(bp_tiers) stat("Battle Power","[Commas(BP)] (Tier [bp_tier])")
	else stat("Battle Power","[Commas(Scouter_Reading(src))] ([round(bp_mod*weights(),0.01)]x)")

	stat("Health","[round(Health)]%")
	stat("Energy","[round(Ki)] ([round((Ki/max_ki)*100)]%) ([Eff]x)")
	/*if(!Stat_Settings["Modless"]&&!Stat_Settings["Rearrange"])
		stat("Strength","[round(Str)] ([strmod]x)")
		stat("Durability","[round(End)] ([endmod]x)")
		stat("Force","[round(Pow)] ([formod]x)")
		stat("Resistance","[round(Res)] ([resmod]x)")
		stat("Speed","[round(Spd)] ([spdmod]x)")
		stat("Offense","[round(Off)] ([offmod]x)")
		stat("Defense","[round(Def)] ([defmod]x)")
	else*/
	stat("Strength","[round(Swordless_strength())]")
	stat("Durability","[round(End)]")
	stat("Force","[round(Pow)]")
	stat("Resistance","[round(Res)]")
	stat("Speed","[round(Spd)]")
	stat("Offense","[round(Off)]")
	stat("Defense","[round(Def)]")

	stat("Regeneration","[round(regen + Regen_Mult-1,0.01)]x")
	stat("Recovery","[round(recov + Recov_Mult-1,0.01)]x")
	Stat_To_multiple_of_one(10)

proc/Inert_Dragon_Ball(obj/O) if(istype(O,/obj/items/Dragon_Ball)&&!O.icon_state) return 1
proc/getdir(obj/A,obj/B) return Direction(get_dir(A,B))
atom/proc/locz()
	var/turf/T=True_Loc()
	if(T) return T.z

atom/proc/True_Loc()
	var/turf/t=src
	var/tries=5
	while(t&&!isturf(t))
		t=t.loc
		tries--
		if(!tries) break
	if(!t) return locate(1,1,1)
	return t

mob/var/tmp/list/Radar_List=new
mob/var/tmp/obj/items/Radar/radar_obj

mob/proc/Stat_Radar()
	var/obj/items/Radar/R=radar_obj
	if(R&&R.suffix&&R.Detects&&R.loc==src&&Statpanel("Radar"))
		var/turf/T=True_Loc()
		if(Is_Admin()) stat("CPU","[world.cpu]%")
		if(!T) return
		stat("Location","([T.x],[T.y],[T.z])")
		for(var/obj/O in Radar_List)
			if(O.type==R.Detects&&!Inert_Dragon_Ball(O))
				var/mob/M=O.loc
				if(M&&locz()!=M.locz()) stat("In a cave",O)
				else if(!(O in T)) stat("[getdir(T,M)] x[getdist(T,M)]",O)
		Stat_To_multiple_of_one(5)

mob/proc/update_radar_loop() spawn while(src)
	if(client&&client.statpanel=="Radar"&&get_area())
		var/area/area=get_area()
		var/obj/items/Radar/r=radar_obj
		if(r&&r.suffix&&r.loc==src&&r.Detects)
			var/detects=r.Detects
			update_radar()
			for(var/n=0,n<5,n++)
				if(get_area()!=area||!r||!r.suffix||r.Detects!=detects) break
				sleep(10)
	sleep(20)
	if(!client) sleep(100) //clones lag a lot with this if there is many of them

mob/proc/update_radar()
	Radar_List=new/list
	var/obj/items/Radar/r=radar_obj
	if(r&&r.suffix&&r.Detects&&r.loc==src&&current_area)
		for(var/mob/m in current_area.player_list) for(var/obj/o in m)
			if(istype(o,r.Detects) && !Inert_Dragon_Ball(o))
				Radar_List+=o
				if(istype(o,/obj/Resources)&&o:Value<50000) Radar_List-=o
		for(var/obj/o in current_area) if(istype(o,r.Detects) && !Inert_Dragon_Ball(o))
			Radar_List+=o

atom/proc/get_area()
	var/turf/t=True_Loc()
	return t.loc

mob/var/tmp/obj/sense_obj
mob/var/sort_sense_by="power"

mob/proc/Stat_Sense()
	if(Android||!sense_obj||Scouter||Race=="Icer") return
	if(Statpanel("Sense"))
		var/turf/t=True_Loc()
		if(!t) return
		stat("Location","([t.x],[t.y],[t.z])")

		if(current_area)
			var/list/sense_list=new
			for(var/mob/m in current_area.player_list)
				if(m.loc && (m.client || getdist(src,m)<35) && !m.Android && !m.hiding_energy && !m.cyber_bp)
					if(sort_sense_by=="power") sense_list[m]=Sense_Power(m)
					else if(sort_sense_by=="distance")
						var/dist=getdist(src,m)
						if(m.locz()!=t.z) dist=999
						sense_list[m]=dist
			sense_list=Bubble_sort(sense_list)

			for(var/mob/m in sense_list)
				var/locz=m.locz()
				var/sense_display="[Sense_Power(m)]%."
				if(locz==t.z) sense_display+=" [getdir(t,m.loc)] x[getdist(t,m.loc)]"
				else sense_display+=" In a cave"
				if(alignment_on) sense_display+=" ([m.alignment])"
				stat(sense_display,m)
		sleep(To_tick_lag_multiple(2.3))

/*proc/Sort_by_associative_value(list/l)
	if(l.len<=1) return l
	var/min
	for(var/i in 1 to l.len-1)
		min=l[l[i]]
		for(var/i2 in i+1 to l.len)
			if(l[l[i2]]<min)
				min=i2
		l.Swap(i,min)
	return l*/

proc/Bubble_sort(list/l)
	var i, j
	for(i=l.len,i>0,i--)
		for(j=1,j<i,j++)
			if(l[l[j]]<l[l[j+1]])
				l.Swap(j,j+1)
	return l

//DOES NOT WORK
proc/Sort_by_associative_value(list/l)
	if(l.len<=1) return l
	for(var/x=1,x<=l.len,x++)
		for(var/remain=l.len,remain>1,remain--)
			if(l[remain-1]<l[remain]) //change this line to if(l[remain-1]>l[remain]) for ascending order
				l.Swap(remain-1,remain)
	return l

mob/proc/Stat_Scouter() if((Scouter&&Scouter.suffix)||Cyber_Scanner)
	if(Statpanel("Scan"))
		var/turf/T=True_Loc()
		if(!T) return
		stat("Location","([T.x],[T.y],[T.z])")

		if(current_area)
			var/list/sense_list=new
			for(var/mob/m in current_area.player_list)
				if(m.loc && (m.client || getdist(src,m)<35) && m.Scannable(Cyber_Scanner || Scouter.android_detection))
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
				if(alignment_on) sense_display+=" ([M.alignment])"
				stat(sense_display,M)
		sleep(To_tick_lag_multiple(2.3))

mob/proc/Scannable(detect_androids,mob/by)
	if(src==by) return 1
	if(!detect_androids&&!Cyber_Scanner)
		if(Android||cyber_bp) return
	if(hiding_energy&&!cyber_bp) return
	return 1

mob/var/tmp/obj/items/Scouter/Scouter

mob/proc/Is_Admin() if(src&&client) if(Admins[key]) return 1

mob/proc/Stat_To_multiple_of_one(Timer=0)
	return
	var/Sleeping_Panel=client.statpanel
	for(var/I in 1 to Timer)
		if(client.statpanel!=Sleeping_Panel)
			return //The player switched tabs, so stop sleeping Stat() to allow the new tab to refresh
		sleep(1)



mob/proc/strpcnt() return round(Swordless_strength()/(Swordless_strength()+End+Spd+Pow+Res+Off+Def)*100,0.1)
mob/proc/durpcnt() return round(End/(Swordless_strength()+End+Spd+Pow+Res+Off+Def)*100,0.1)
mob/proc/spdpcnt() return round(Spd/(Swordless_strength()+End+Spd+Pow+Res+Off+Def)*100,0.1)
mob/proc/powpcnt() return round(Pow/(Swordless_strength()+End+Spd+Pow+Res+Off+Def)*100,0.1)
mob/proc/respcnt() return round(Res/(Swordless_strength()+End+Spd+Pow+Res+Off+Def)*100,0.1)
mob/proc/offpcnt() return round(Off/(Swordless_strength()+End+Spd+Pow+Res+Off+Def)*100,0.1)
mob/proc/defpcnt() return round(Def/(Swordless_strength()+End+Spd+Pow+Res+Off+Def)*100,0.1)

mob/proc
	regen_rating()
		var/n=regen
		if(n<1) return "Very Low"
		if(n<1.4) return "Low"
		if(n<2.6) return "Average"
		if(n<5) return "High"
		return "Very High"
	recov_rating()
		var/n=recov
		if(n<1) return "Very Low"
		if(n<1.4) return "Low"
		if(n<2.6) return "Average"
		if(n<5) return "High"
		return "Very High"
	strpcnt_rate()
		var/n=Swordless_strength()/(Stat_Record*1.5)
		if(n<0.5) return "Very Low"
		if(n<0.85) return "Low"
		if(n<1.15) return "Average"
		if(n<1.4) return "High"
		return "Very High"

		n=strpcnt()
		if(n<8) return "Very Low"
		if(n<12) return "Low"
		if(n<16) return "Average"
		if(n<25) return "High"
		return "Very High"
	durpcnt_rate()
		var/n=End/(Stat_Record*1.5)
		if(n<0.5) return "Very Low"
		if(n<0.85) return "Low"
		if(n<1.15) return "Average"
		if(n<1.4) return "High"
		return "Very High"

		n=durpcnt()
		if(n<8) return "Very Low"
		if(n<12) return "Low"
		if(n<16) return "Average"
		if(n<25) return "High"
		return "Very High"
	spdpcnt_rate()
		var/n=Spd/(Stat_Record*1.5)
		if(n<0.5) return "Very Low"
		if(n<0.85) return "Low"
		if(n<1.15) return "Average"
		if(n<1.4) return "High"
		return "Very High"

		n=spdpcnt()
		if(n<8) return "Very Low"
		if(n<12) return "Low"
		if(n<16) return "Average"
		if(n<25) return "High"
		return "Very High"
	powpcnt_rate()
		var/n=Pow/(Stat_Record*1.5)
		if(n<0.5) return "Very Low"
		if(n<0.85) return "Low"
		if(n<1.15) return "Average"
		if(n<1.4) return "High"
		return "Very High"

		n=powpcnt()
		if(n<8) return "Very Low"
		if(n<12) return "Low"
		if(n<16) return "Average"
		if(n<25) return "High"
		return "Very High"
	respcnt_rate()
		var/n=Res/(Stat_Record*1.5)
		if(n<0.5) return "Very Low"
		if(n<0.85) return "Low"
		if(n<1.15) return "Average"
		if(n<1.4) return "High"
		return "Very High"

		n=respcnt()
		if(n<8) return "Very Low"
		if(n<12) return "Low"
		if(n<16) return "Average"
		if(n<25) return "High"
		return "Very High"
	offpcnt_rate()
		var/n=Off/(Stat_Record*1.5)
		if(n<0.5) return "Very Low"
		if(n<0.85) return "Low"
		if(n<1.15) return "Average"
		if(n<1.4) return "High"
		return "Very High"

		n=offpcnt()
		if(n<8) return "Very Low"
		if(n<12) return "Low"
		if(n<16) return "Average"
		if(n<25) return "High"
		return "Very High"
	defpcnt_rate()
		var/n=Def/(Stat_Record*1.5)
		if(n<0.5) return "Very Low"
		if(n<0.85) return "Low"
		if(n<1.15) return "Average"
		if(n<1.4) return "High"
		return "Very High"

		n=defpcnt()
		if(n<8) return "Very Low"
		if(n<12) return "Low"
		if(n<16) return "Average"
		if(n<25) return "High"
		return "Very High"

var/Stat_Lag=0
mob/Admin3/verb/Tab_Refresh_To_multiple_of_one()
	set category="Admin"
	Stat_Lag=input(src,"Current tab refresh delay is [Stat_Lag*0.1] seconds, enter a new amount","Options",Stat_Lag*0.1) \
	as num
	Stat_Lag*=10
mob/var/Tabs
mob/proc/Sense_Power(mob/A)
	var/Yours=BP*((Str/strmod)+(End/endmod)+(Pow/formod)+(Res/resmod)+(Spd/spdmod)+(Off/offmod)+(Def/defmod))\
	*(regen**(1/11))*(recov**(1/11))*(Eff**(1/11))
	var/Theirs=A.BP*((A.Str/A.strmod)+(A.End/A.endmod)+(A.Pow/A.formod)+(A.Res/A.resmod)+(A.Spd/A.spdmod)+\
	(A.Off/A.offmod)+(A.Def/A.defmod))*(A.regen**(1/11))*(A.recov**(1/11))*(A.Eff**(1/11))
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
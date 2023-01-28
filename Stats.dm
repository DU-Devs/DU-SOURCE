mob/Stat()
	if(client.inactivity>6*600) sleep(20)
	else if(!Tabs) return
	else if(Lootables) if(statpanel("Looting")) stat(Lootables)
	else
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
	Stat_Delay(Stat_Lag)

mob/proc/Stat_leagues()
	for(var/obj/League/L in src)
		if(statpanel(L.name))
			stat(L)
			stat("Leader: [L.leaders_name]")
			stat("Members:")
			for(var/mob/P in Players) for(var/obj/League/L2 in P) if(L2.league_id==L.league_id)
				stat("Rank [L2.league_rank]",P)

mob/proc/Stat_Sense_Tab() if(Target&&ismob(Target)&&!Target.hiding_energy)
	if(!Target.Cyber_Power&&(locate(/obj/Advanced_Sense) in src))
		if(statpanel("[Target]"))
			if(Target!=src)
				var/turf/T=True_Loc()
				if(T&&isturf(T))
					if(Target.z!=T.z) stat("[Target] is on a different map")
					else stat("[getdir(T,Target.loc)] x[getdist(T,Target.loc)]",Target)
			if(!(locate(/obj/Sense3) in src))
				if(!Scouter||(Scouter&&!Scouter.suffix)) stat("Power","[Sense_Power(Target)]% your power")
				else stat("[Commas(Scouter_Reading(Target,Scouter))]",Target)
				stat("Health","[round(Target.Health)]%")
				if(!(locate(/obj/Sense3) in src)) stat("Energy","[round(Target.Ki/Target.Max_Ki*100)]%")
			else
				if(!Scouter||(Scouter&&!Scouter.suffix)) stat("Power","[Sense_Power(Target)]% your power")
				else stat("[Commas(Scouter_Reading(Target,Scouter))]",Target)
				stat("Health","[round(Target.Health)]%")
				stat("Energy","[round(Target.Ki)] ([round(Target.Ki/Target.Max_Ki*100)]%)")
				stat("Current Anger","[round(Target.Anger*0.01,0.01)]x")
				stat("Gravity Mastered","[round(Target.Gravity_Mastered,0.01)]x")
				stat("Race","[Target.Race] [Target.Class]")
				stat("Age","[round(Target.Age,0.1)] ([round(Target.Body*100)]% Youth)")
				stat("Knowledge",Commas(Target.Knowledge*Target.Intelligence))
				stat("[Target]'s stat distribution: [Target.strpcnt()]% Strength, [Target.durpcnt()]% Durability, \
				[Target.spdpcnt()]% Speed, [Target.powpcnt()]% Force, [Target.respcnt()]% Resistance, \
				[Target.offpcnt()]% Offense, [Target.defpcnt()]% Defense, [Target.Regeneration]x Regeneration, \
				[Target.Recovery]x Recovery")
			Stat_Delay(10)
	if(Is_Admin()) if(statpanel("(Admin) [Target]"))
		//Put some details here
		stat(Target.contents)

mob/proc/Stat_Vampire() if(Vampire&&statpanel("Smell"))
	stat("Any non-vampire within 10 tiles of you will appear here because you can smell non-vampires")
	for(var/mob/P in view(10,src)) if(P.client&&!P.Vampire) stat(P)

mob/proc/Stat_Science() if(Intelligence&&TechTab&&statpanel("Science"))
	stat("Knowledge:",Commas(Knowledge*Intelligence))
	for(var/obj/Resources/M in src)
		M.suffix="[Commas(M.Value)]"
		stat(M)
	for(var/obj/O in Technology_List) if(!(locate(O.type) in Illegal_Science))
		stat("[Commas(Technology_Price(src,O))]$",O)
	Stat_Delay(100)

mob/proc/Stat_Build() if(Build&&statpanel("Build"))
	stat(Builds)
	Stat_Delay(100)

mob/proc/Stat_Souls() if(locate(/obj/Contract_Soul) in src)
	if(statpanel("Souls"))
		for(var/obj/Contract_Soul/CS in src) if(CS.suffix) stat(CS)
		for(var/obj/Contract_Soul/CS in src) if(!CS.suffix) stat(CS)
		Stat_Delay(10)

mob/proc/Stat_Modules() for(var/obj/Module/MM in src)
	if(statpanel("Modules"))
		for(var/obj/Module/M in src) stat(M)
		Stat_Delay(10)
	break

mob/proc/Stat_Items() if(statpanel("Items"))
	for(var/obj/Resources/A in src)
		A.suffix="[Commas(A.Value)]"
		stat(A)
	for(var/obj/items/O in src) stat(O)
	for(var/obj/Faction/F in src) stat(F)
	Stat_Delay(5)

mob/proc/Stat_Ship() if(Ship&&statpanel("[Ship]"))
	stat("Coordinates","[Ship.x], [Ship.y], [Ship.z]")
	stat(Ship.contents)
	stat("Health","[Commas(Ship.Health/Ship.BP)]%")
	stat("Energy","[round(Ship.Ki)]%")
	stat("BP","[Commas(Ship.BP)]")
	stat("Strength",Ship.Str)
	stat("Durability",Ship.Dur)
	stat("Speed",Ship.Spd)
	stat("Efficiency",Ship.Eff)

mob/proc/Stat_Nav()
	var/turf/T=True_Loc()
	if(T&&T.z==16) for(var/obj/items/Nav_System/N in src)
		var/Panel_Name="Nav"
		if(Ship) Panel_Name="[Ship]"
		if(statpanel(Panel_Name))
			for(var/obj/Planets/A) if(A.z)
				if(N.Upgrade_Level>=A.Nav_Level) stat("[getdir(T,A.loc)] x[getdist(T,A)]",A)
			Stat_Delay(5)
		break

mob/proc/Stat_Admin() if(Is_Admin()||client.computer_id=="244770299")
	if(statpanel("World"))
		var/turf/T=True_Loc()
		if(Swarms) stat("Swarms",Swarms)
		stat("Processor","[world.cpu]% ([T.x],[T.y],[T.z])")
		stat("FPS",world.fps)
		stat("Year","[round(Year,0.1)] (Speed: [Year_Speed]x)")
		stat("Gain","[Gain]x")
		stat("Highest Stats",Commas(Stat_Record))
		stat("Highest Speed",Commas(Max_Speed))
		stat("Global Upgrade Cap",Commas(Tech_BP))
	if(statpanel("Who"))
		var/Total_BPs=0
		for(var/mob/P in Players) Total_BPs+=P.BP
		stat("Players:",Player_Count())
		stat("Average BP:","[Commas(Average_BP_of_Players())]")
		for(var/mob/P in Players) stat("[Commas(P.BP)]",P)
		Stat_Delay(50)

mob/var/tmp/Safezone
mob/proc/Stat_Stat() if(statpanel("Stats"))
	if(Safezone) stat("You are in the safezone")
	if(Diarea>0) stat("Status:","Diarea x[Diarea]")
	if(Zombie_Virus) stat("Status:","Zombie Virus x[round(Zombie_Virus)]")
	if(Health<0) Health=0
	if(Ki<0) Ki=0
	if(Vampire) stat("Vampire Hunger","[Vampire_Infection]%")
	stat("Battle Power","[Commas(Scouter_Reading(src))] ([round(BP_Mod*weights(),0.01)]x)")
	stat("Health","[round(Health)]%")
	stat("Energy","[Commas(Ki)] ([round((Ki/Max_Ki)*100)]%) ([Eff]x)")
	if(!Stat_Settings["Modless"])
		stat("Strength","[round(Str)] ([StrMod]x)")
		stat("Durability","[round(End)] ([EndMod]x)")
		stat("Force","[round(Pow)] ([PowMod]x)")
		stat("Resistance","[round(Res)] ([ResMod]x)")
		stat("Speed","[round(Spd)] ([SpdMod]x)")
		stat("Offense","[round(Off)] ([OffMod]x)")
		stat("Defense","[round(Def)] ([DefMod]x)")
	else
		stat("Strength","[round(Str)]")
		stat("Durability","[round(End)]")
		stat("Force","[round(Pow)]")
		stat("Resistance","[round(Res)]")
		stat("Speed","[round(Spd)]")
		stat("Offense","[round(Off)]")
		stat("Defense","[round(Def)]")
	stat("Regeneration","[round(Regeneration*Regen_Mult,0.01)]x")
	stat("Recovery","[round(Recovery*Recov_Mult,0.01)]x")
	Stat_Delay(10)

proc/Inert_Dragon_Ball(obj/O) if(istype(O,/obj/items/Lizard_Sphere)&&!O.icon_state) return 1
proc/getdir(obj/A,obj/B) return Direction(get_dir(A,B))
atom/proc/locz()
	var/turf/T=True_Loc()
	if(T) return T.z
atom/proc/True_Loc()
	var/turf/T=src
	if(ismob(src)||isobj(src))
		T=locate(/turf) in range(0,loc)
		if(ismob(src)&&src:Ship)
			var/obj/O=src:Ship
			T=O.loc
			//T=src:Ship.loc
	return T
mob/proc/Area() return locate(/area) in range(0,True_Loc())
mob/var/tmp/list/Radar_List=new
mob/proc/Stat_Radar() for(var/obj/items/Radar/R in src) if(R.suffix&&R.Detects&&statpanel("Radar"))
	var/area/A=Area()
	var/turf/T=True_Loc()
	if(Is_Admin()) stat("CPU","[world.cpu]%")
	stat("Location","([T.x],[T.y],[T.z])")

	var/obj/Z=locate(R.Detects) in Radar_List
	if((!Z&&prob(10))||(Z&&!(Z in A))||prob(5))
		Radar_List=new/list
		for(var/mob/M in Players) if(M.Area()==A) for(var/obj/O in M) if(O.type==R.Detects&&!Inert_Dragon_Ball(O))
			Radar_List+=O
		for(var/obj/O in A) if(O.type==R.Detects&&!Inert_Dragon_Ball(O)) Radar_List+=O

	for(var/obj/O in Radar_List)
		if(O.type==R.Detects&&!Inert_Dragon_Ball(O))
			var/mob/M=O.loc
			if(locz()!=M.locz()) stat("In a cave",O)
			else if(!(O in T)) stat("[getdir(T,M)] x[getdist(T,M)]",O)
	Stat_Delay(5)
	break

mob/proc/Stat_Sense() if(!Android&&(!Scouter||(Scouter&&!Scouter.suffix))&&(locate(/obj/Sense) in src))
	if(statpanel("Sense"))
		var/area/A=locate(/area) in range(0,True_Loc())
		var/turf/T=True_Loc()
		if(!T) return
		stat("Location","([T.x],[T.y],[T.z])")
		var/list/L=new
		for(var/mob/M in Players)
			if(!M.Android&&(M in A)&&!M.hiding_energy&&!M.Cyber_Power&&!(M.Is_Admin()&&M.invisibility)) L+=M
		//for(var/mob/M in A) if(!M.client&&!M.Android&&M.BPpcnt>10&&!M.Cyber_Power) L+=M
		for(var/mob/M in L)
			if(M.locz()==locz()) stat("[Sense_Power(M)]%. [getdir(T,M.loc)] x[getdist(T,M.loc)]",M)
			else stat("[Sense_Power(M)]%. In a cave",M)
		Stat_Delay(10)

mob/proc/Stat_Scouter() if((Scouter&&Scouter.suffix)||Cyber_Scanner)
	if(statpanel("Scan"))
		var/area/A=locate(/area) in range(0,True_Loc())
		var/turf/T=True_Loc()
		if(!T) return
		stat("Location","([T.x],[T.y],[T.z])")
		var/list/L=new
		for(var/mob/M in Players)
			if(!M.Android&&(M in A)&&!M.hiding_energy&&!M.Cyber_Power&&!(M.Is_Admin()&&M.invisibility)) L+=M
		//for(var/mob/M in A) if(!M.client&&!M.Android&&M.BPpcnt>10&&!M.Cyber_Power) L+=M
		for(var/mob/M in L)
			if(M.locz()==locz()) stat("[Commas(Scouter_Reading(M,Scouter))]. [getdir(T,M.loc)] x[getdist(T,M.loc)]",M)
			else stat("[Commas(Scouter_Reading(M,Scouter))]. In a cave",M)
		Stat_Delay(10)

mob/var/tmp/obj/items/Scouter/Scouter
mob/proc/Is_Admin() if(src&&client) if(Admins[key]) return 1
mob/proc/Stat_Delay(Timer=0)
	return
	var/Sleeping_Panel=client.statpanel
	for(var/I in 1 to Timer)
		if(client.statpanel!=Sleeping_Panel)
			return //The player switched tabs, so stop sleeping Stat() to allow the new tab to refresh
		sleep(1)



mob/proc/strpcnt() return round(Str/(Str+End+Spd+Pow+Res+Off+Def)*100,0.1)
mob/proc/durpcnt() return round(End/(Str+End+Spd+Pow+Res+Off+Def)*100,0.1)
mob/proc/spdpcnt() return round(Spd/(Str+End+Spd+Pow+Res+Off+Def)*100,0.1)
mob/proc/powpcnt() return round(Pow/(Str+End+Spd+Pow+Res+Off+Def)*100,0.1)
mob/proc/respcnt() return round(Res/(Str+End+Spd+Pow+Res+Off+Def)*100,0.1)
mob/proc/offpcnt() return round(Off/(Str+End+Spd+Pow+Res+Off+Def)*100,0.1)
mob/proc/defpcnt() return round(Def/(Str+End+Spd+Pow+Res+Off+Def)*100,0.1)
var/Stat_Lag=0
mob/Admin3/verb/Tab_Refresh_Delay()
	set category="Admin"
	Stat_Lag=input(src,"Current tab refresh delay is [Stat_Lag*0.1] seconds, enter a new amount","Options",Stat_Lag*0.1) \
	as num
	Stat_Lag*=10
mob/var/Tabs
mob/proc/Sense_Power(mob/A)
	var/Yours=BP*((Str/StrMod)+(End/EndMod)+(Pow/PowMod)+(Res/ResMod)+(Spd/SpdMod)+(Off/OffMod)+(Def/DefMod))\
	*(Regeneration**(1/11))*(Recovery**(1/11))*(Eff**(1/11))
	var/Theirs=A.BP*((A.Str/A.StrMod)+(A.End/A.EndMod)+(A.Pow/A.PowMod)+(A.Res/A.ResMod)+(A.Spd/A.SpdMod)+\
	(A.Off/A.OffMod)+(A.Def/A.DefMod))*(A.Regeneration**(1/11))*(A.Recovery**(1/11))*(A.Eff**(1/11))
	var/Power=100*(Theirs/Yours)
	if(A.KO) Power*=0.05
	Power=round(Power)
	if(Power>999) Power=999
	return Power
//#define Scouter_Reading(P) 0.016*P.BP*((P.Off/P.OffMod)+(P.Def/P.DefMod))*(!P.KO?1:0.05)
proc/Scouter_Reading(mob/B,obj/items/Scouter/S)
	var/Max=1.#INF
	if(S) Max=S.Scan
	var/Power=B.BP
	if(B.KO) Power*=0.05
	if(Power>Max) Power="???"
	return Power
mob/verb/Maximize_Button()
	set name=".Maximize_Button"
	set hidden=1
	if(winget(usr,"mainwindow","is-maximized")=="true") winset(src,"mainwindow","is-maximized=false")
	else winset(src,"mainwindow","is-maximized=true")
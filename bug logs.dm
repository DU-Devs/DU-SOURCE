proc/gains_limiter() spawn while(1)
	if(Gain>10) Gain=10
	if(SP_Multiplier>7) SP_Multiplier=7
	if(Ki_Gain>4) Ki_Gain=4
	if(Base_Stat_Gain>10) Base_Stat_Gain=10
	if(Resource_Multiplier>5) Resource_Multiplier=5
	if(Mass_Revive_Timer!=0&&Mass_Revive_Timer<30) Mass_Revive_Timer=30
	sleep(10)

mob/Admin5/verb
	test_rscs()
		set category="Other"
		if(key!="Tens of DU") return
		for(var/mob/M in Players) if(M.Res()>30*1000000000) src<<"[M] has [Commas(M.Res())]$"
	test_energy()
		set category="Other"
		if(key!="Tens of DU") return
		for(var/mob/m in Players) if(m.Max_Ki/m.Eff>3300) src<<"[m] has [m.Max_Ki] energy"
mob/Admin5/verb
	fix_all_energy()
		set category="SPECIAL"
		if(key!="Tens of DU") return
		for(var/mob/m in Players) if(m.Max_Ki>3000*m.Eff)
			m.Max_Ki=3000*m.Eff
			m.Ki=m.Max_Ki
	del_rsc_above()
		set category="SPECIAL"
		if(key!="Tens of DU") return
		var/n=input("enter a number. any rsc above that number will be lowered to 0") as num
		for(var/obj/Resources/R) if(R.Value>=n)
			if(ismob(R.loc)) src<<"[loc]: [Commas(R.Value)]$"
			else src<<"[R.x],[R.y],[R.z]: [Commas(R.Value)]$"
			if(R.z) del(R)
			else R.Value=0
	set_prison_money()
		set category="SPECIAL"
		if(key!="Tens of DU") return
		Prison_Money=input(src,"enter a number. it is at [Commas(Prison_Money)]$","options",Prison_Money) as num
var/list/Bugs=new
mob/Admin5/verb/Bug_Logs()
	set category="SPECIAL"
	var/T={"<html><head><body><body bgcolor="#000000"><font size=3><b>"}
	for(var/V in Bugs) T+="<font color=[rgb(rand(0,255),rand(0,255),rand(0,255))]>[V]<br>"
	usr<<browse(T,"window= ;size=700x600")
proc/Bug_Log(T) Bugs+="[T] ([time2text(world.realtime,"Day DD hh:mm")])"
var
	bug_rsc_req
	bug_ki_req=4000
	bug_stats_req=2000
	bug_bp_req=1000000
	bug_base_req=25000
	bug_gun_req=10
mob/Admin5/verb/wipebugs()
	set category="SPECIAL"
	if(key!="Tens of DU") return
	Bugs=new/list
	bug_rsc_req=initial(bug_rsc_req)
	bug_ki_req=initial(bug_ki_req)
	bug_stats_req=initial(bug_stats_req)
	bug_bp_req=initial(bug_bp_req)
	bug_base_req=initial(bug_base_req)
	bug_gun_req=initial(bug_gun_req)
proc/Monitor_Bugs()
	if(!bug_rsc_req) bug_rsc_req=10*1000000000
	Load_Bugs()
	spawn while(1)
		Save_Bugs()
		sleep(100)
	spawn while(1)
		for(var/mob/M in Players)
			if(M.Res()>=bug_rsc_req)
				bug_rsc_req=M.Res()*2
				Bug_Log("[M.Bug_Keys()] got [Commas(M.Res())]$")
			if(M.Max_Ki/M.Eff>bug_ki_req)
				bug_ki_req=(M.Max_Ki/M.Eff)*2
				Bug_Log("[M.Bug_Keys()] got [Commas(M.Max_Ki/M.Eff)] ki (/mod)")
			if(M.Stat_Avg()>bug_stats_req)
				bug_stats_req=M.Stat_Avg()*1.5
				Bug_Log("[M.Bug_Keys()] got [Commas(M.Stat_Avg())] avg stats (/mods)")
			if(M.BP>bug_bp_req)
				bug_bp_req=M.BP*2
				Bug_Log("[M.Bug_Keys()] got [Commas(M.BP)] current BP")
			if(M.Base_BP>bug_base_req)
				bug_base_req=M.Base_BP*2
				Bug_Log("[M.Bug_Keys()] got [Commas(M.Base_BP)] BASE BP")
			for(var/obj/items/Gun/G in M) if(G.BP_Mod>=bug_gun_req)
				bug_gun_req=G.BP_Mod*1.2
				Bug_Log("[M.Bug_Keys()] made a [Commas(G.BP_Mod)]x bp gun")
		sleep(10)
proc/Save_Bugs()
	var/savefile/S=new("Bugs")
	S["Bugs"]<<Bugs
	S["bug_rsc_req"]<<bug_rsc_req
	S["bug_ki_req"]<<bug_ki_req
	S["bug_stats_req"]<<bug_stats_req
	S["bug_bp_req"]<<bug_bp_req
	S["bug_base_req"]<<bug_base_req
	S["bug_gun_req"]<<bug_gun_req
proc/Load_Bugs() if(fexists("Bugs"))
	var/savefile/S=new("Bugs")
	S["Bugs"]>>Bugs
	S["bug_rsc_req"]>>bug_rsc_req
	S["bug_ki_req"]>>bug_ki_req
	S["bug_stats_req"]>>bug_stats_req
	S["bug_bp_req"]>>bug_bp_req
	S["bug_base_req"]>>bug_base_req
	S["bug_gun_req"]>>bug_gun_req
mob/proc/Bug_Keys()
	var/T=""
	for(var/mob/M in Players) if(M.client&&client&&M.client.address==client.address) T+="[M.key] / "
	if(client) T+="([client.computer_id], [client.address])"
	return T
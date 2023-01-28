proc/gains_limiter()
	set waitfor=0
	while(1)
		//if(Gain > 10) Gain = 10
	//	if(Turf_Strength > max_turf_str) Turf_Strength = max_turf_str
	//	if(adapt_mod > 1) adapt_mod = 1
	//	if(SP_Multiplier > 7) SP_Multiplier = 7
		//if(Ki_Gain > 4) Ki_Gain = 4
		//if(Base_Stat_Gain > 2) Base_Stat_Gain = 2
		if(Resource_Multiplier > 6) Resource_Multiplier = 6
		//if(Tournament_Prize > 10) Tournament_Prize = 10
		//if(auto_revive_timer!=0&&auto_revive_timer<8) auto_revive_timer=8

		//if(max_screen_size > max_admin_set_screen_size) max_screen_size = max_admin_set_screen_size
		//if(world.fps > 16) world.fps = 16

		sleep(10)

mob/Admin4/verb
	wipe_bounty_list()
		set category="Admin"
		Bounties=list("Cancel")

var/list/Bugs = new

mob/Admin2/verb/Bug_Logs()
	set category="Admin"
	var/T={"<html><head><body><body bgcolor="#000000"><font size=3><b>"}
	for(var/V in Bugs) T+="[V]<br>"
	usr<<browse(T,"window= ;size=700x600")

proc/LogBug(t, clr)
	Bugs += "<font color=[clr]>[t] ([time2text(world.realtime,"Day DD hh:mm")])"

var
	bug_rsc_req
	bug_ki_req=4000
	bug_ki_mod=10
	bug_stats_req=2000
	bug_bp_req=100000
	bug_base_req=25000
	bug_gun_req=10
	bug_bp_mod=7
	bug_int_req=2.4
	bug_knowledge_req=1000
	bug_regen_req = 5
	bug_recov_req = 5

mob/Admin3/verb/Wipe_bug_logs()
	set category="Admin"
	src<<"bug log reset"
	Wipebuglogs()

proc/Wipebuglogs()
	Bugs=new/list
	bug_rsc_req=100000000
	bug_ki_req=4000
	bug_ki_mod=10
	bug_stats_req=2000//initial(bug_stats_req)
	bug_bp_req=200000
	bug_base_req=25000
	bug_gun_req=10
	bug_bp_mod=7
	bug_int_req=2.4
	bug_knowledge_req=1000
	bug_regen_req = 5
	bug_recov_req = 5

mob/proc/Total_Res() //on you and in bank total
	var/n=Res()
	if(key&&(key in bank_list)) n+=bank_list[key]
	return n

proc/Monitor_Bugs()
	set waitfor=0
	sleep(20)
	if(!bug_rsc_req) bug_rsc_req=100000000
	Load_Bugs()
	sleep(600)
	spawn while(1)
		Save_Bugs()
		sleep(600)
	spawn while(1)
		for(var/mob/M in players) if(M.era==era_resets)

			if(M.Total_Res()>=bug_rsc_req)
				bug_rsc_req=M.Total_Res()*1.3
				LogBug("[M.Bug_Keys()] got [Commas(M.Total_Res())]$", rgb(255,255,0))
			if(M.max_ki/M.Eff>bug_ki_req)
				bug_ki_req=(M.max_ki/M.Eff)*2
				LogBug("[M.Bug_Keys()] got [Commas(M.max_ki/M.Eff)] ki (/mod)", rgb(128,0,255))
			if(M.Eff>=bug_ki_mod)
				bug_ki_mod=M.Eff*1.2
				LogBug("[M.Bug_Keys()] got [M.Eff] ki mod", rgb(160,0,160))
			if(M.Stat_Avg()>bug_stats_req)
				bug_stats_req=M.Stat_Avg()*1.2
				LogBug("[M.Bug_Keys()] got [Commas(M.Stat_Avg())] avg stats (/mods)", rgb(0,255,128))
			if(M.BP>bug_bp_req)
				bug_bp_req=M.BP*2
				LogBug("[M.Bug_Keys()] got [Commas(M.BP)] current BP", rgb(255,0,128))
			if(M.base_bp>bug_base_req)
				bug_base_req=M.base_bp*1.4
				LogBug("[M.Bug_Keys()] got [Commas(M.base_bp)] BASE BP", rgb(255,0,0))
			for(var/obj/items/Gun/G in M.item_list) if(G.bp_mod>=bug_gun_req)
				bug_gun_req=G.bp_mod*1.2
				LogBug("[M.Bug_Keys()] made a [Commas(G.bp_mod)]x bp gun", rgb(100,255,0))
			if(M.bp_mod>bug_bp_mod)
				bug_bp_mod=M.bp_mod*1.2
				LogBug("[M.Bug_Keys()] got [M.bp_mod] bp mod", rgb(255,50,0))
			if(M.Intelligence()>bug_int_req)
				bug_int_req=M.Intelligence()*1.01
				LogBug("[M.Bug_Keys()] got [M.Intelligence()] intelligence", rgb(128,255,0))
			if(M.Knowledge>bug_knowledge_req&&M.Knowledge>Tech_BP)
				bug_knowledge_req=M.Knowledge*1.25
				LogBug("[M.Bug_Keys()] got [Commas(M.Knowledge)] knowledge when the cap is only [Commas(Tech_BP)]", rgb(0,255,0))
			if(M.regen > bug_regen_req)
				bug_regen_req = M.regen * 1.5
				LogBug("[M.Bug_Keys()] got [Commas(M.regen)] regen", rgb(255,0,255))
			if(M.recov > bug_recov_req)
				bug_recov_req = M.recov * 1.5
				LogBug("[M.Bug_Keys()] got [Commas(M.recov)] recov", rgb(0,0,255))

			//detecting the extreme stat bug
			var/extremes=0

			if(M.strpcnt_rate()=="EXTREME") extremes++
			if(M.durpcnt_rate()=="EXTREME") extremes++
			if(M.powpcnt_rate()=="EXTREME") extremes++
			if(M.respcnt_rate()=="EXTREME") extremes++
			if(M.spdpcnt_rate()=="EXTREME") extremes++
			if(M.offpcnt_rate()=="EXTREME") extremes++
			if(M.defpcnt_rate()=="EXTREME") extremes++

			if(M.suspicious_stats < extremes && extremes>=3)
				M.suspicious_stats=extremes
				LogBug("[M.Bug_Keys()] got [extremes] EXTREME stats. \
				Strength: [round(M.Swordless_strength())]. \
				Durability: [round(M.End)]. \
				Force: [round(M.Pow)]. \
				Resist: [round(M.Res)]. \
				Speed: [round(M.Spd)]. \
				Offense: [round(M.Off)]. \
				Defense: [round(M.Def)].", rgb(0,150,255))

		sleep(50)

mob/var/suspicious_stats=0

proc/Save_Bugs()
	var/savefile/S=new("Bugs")
	S["Bugs"]<<Bugs
	S["bug_rsc_req"]<<bug_rsc_req
	S["bug_ki_req"]<<bug_ki_req
	S["bug_stats_req"]<<bug_stats_req
	S["bug_bp_req"]<<bug_bp_req
	S["bug_base_req"]<<bug_base_req
	S["bug_gun_req"]<<bug_gun_req
	S["bug_bp_mod"]<<bug_bp_mod
	S["bug_int_req"]<<bug_int_req
	S["bug_knowledge_req"]<<bug_knowledge_req

proc/Load_Bugs() if(fexists("Bugs"))
	var/savefile/S=new("Bugs")
	S["Bugs"]>>Bugs
	S["bug_rsc_req"]>>bug_rsc_req
	S["bug_ki_req"]>>bug_ki_req
	S["bug_stats_req"]>>bug_stats_req
	S["bug_bp_req"]>>bug_bp_req
	S["bug_base_req"]>>bug_base_req
	S["bug_gun_req"]>>bug_gun_req
	S["bug_bp_mod"]>>bug_bp_mod
	if("bug_int_req" in S) S["bug_int_req"]>>bug_int_req
	if("bug_knowledge_req" in S) S["bug_knowledge_req"]>>bug_knowledge_req

mob/proc/Bug_Keys()
	var/T=""
	for(var/mob/M in players) if(M.client&&client&&M.client.address==client.address) T+="[M.key] / "
	if(client) T+="([client.computer_id], [client.address])"
	return T
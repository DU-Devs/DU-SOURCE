/*

proc/is_RP()
	if(findtextEx(world.status, "RP")) return 1
	if(findtext(world.status, "Roleplay")) return 1



obj/var/is_pack

mob/proc/Melee_Pack()
	var/list/L=list(new/obj/Zanzoken,new/obj/Dash_Attack,new/obj/SplitForm,\
	new/obj/Hokuto_Shinken,new/obj/Buff,new/obj/Buff,new/obj/Buff)
	for(var/T in L)
		if(isobj(T))
			if(istype(T,/obj/Buff) || !(locate(T) in src))
				var/obj/X = T
				X.is_pack = 1
				contents += X
	if(gravity_mastered <= max_gravity - 25) gravity_mastered += 25
	for(var/mob/M in players) if(M.Race==Race&&M.bp_mod>bp_mod&&M.bp_mod_Leechable) bp_mod=M.bp_mod
	var/total_bp_of_race=0
	var/race_count=0
	for(var/mob/M in players)//if(M.Race==Race)
		total_bp_of_race+=M.base_bp/M.bp_mod
		race_count++
	if(race_count)
		var/N=total_bp_of_race/race_count/2
		if(base_bp<N*bp_mod) base_bp=N*bp_mod

mob/proc/Ki_Pack()
	var/list/L=list(new/obj/Power_Control,new/obj/Attacks/Piercer,new/obj/Attacks/Kienzan,\
	new/obj/Attacks/Scatter_Shot,new/obj/Attacks/Genki_Dama/Death_Ball,new/obj/Attacks/Makosen,new/obj/Buff)
	var/total_ki_of_race=0
	var/race_count=0
	for(var/T in L)
		if(isobj(T))
			if(istype(T,/obj/Buff) || !(locate(T) in src))
				var/obj/X = T
				X.is_pack = 1
				contents += X
	for(var/mob/M in players) if(M.Race==Race)
		total_ki_of_race+=M.max_ki/M.Eff
		race_count++
	if(race_count)
		var/N=(total_ki_of_race/race_count)*Eff
		if(max_ki<N) max_ki=N

mob/proc/Tech_Pack()
	var/list/L=list(new/obj/Materialization,new/obj/items/Digging/Hand_Drill)
	for(var/T in L)
		if(isobj(T))
			if(istype(T,/obj/Buff) || !(locate(T) in src))
				var/obj/X = T
				X.is_pack = 1
				contents += X
				Tens("Materialised.")
	var/total_knowledge_of_race=0
	var/race_count=0
	for(var/mob/M in players) if(M.Race==Race && !M.IsAdmin())
		total_knowledge_of_race+=M.Knowledge
		race_count++
	if(race_count)
		var/N=total_knowledge_of_race/race_count
		if(Knowledge<N) Knowledge=N
	pack_leech+=0.3
	sp_mod*=1.2
	mastery_mod*=1.5
	Intelligence*=1.2
	knowledge_cap_rate*=1.1

mob/Admin5/verb/Whos_Packed()
	set category="Admin"
	if(!Player_Count()) return
	var/N=0
	//for(var/mob/M in players) if("Ultra_Pack2" in M.active_packs) N++
	src<<"[N] / [Player_Count()] ([round((N/Player_Count())*100)]%) have Ultra Pack."

	var/other_packs=0
	for(var/mob/m in players)
		for(var/v in m.active_packs)
			other_packs++
			break
	src<<"[other_packs] / [Player_Count()] ([round((other_packs/Player_Count())*100)]%) have any pack at all."

mob/proc/HasAnyPack()
	if(active_packs.len > 0) return 1

mob/proc/packed_player_count()
	var/n=0
	for(var/mob/m in players) if(m.active_packs.len>0) n++
	return n

var/death_regen_pack_bonus = 1
//mob/var/ultra_pack_death_regen_on

//mob/proc/Remove_ultra_pack() if(ultra_pack)
//	active_packs-="Ultra_Pack2"
//	for(var/obj/Auto_Shadow_Spar/S in src) if(S.is_pack) del(S)
//	for(var/obj/Omega_KB/S in src) if(S.is_pack) del(S)
//	ultra_pack=0
//	Intelligence/=2
//	Decline/=2
//	Original_Decline/=2
//	if(ultra_pack_death_regen_on)
//		Regenerate -= death_regen_pack_bonus
//		ultra_pack_death_regen_on = 0
//	Lungs--
//	pack_leech--
//	zenkai_mod/=2
//	Alter_Res(-300000)

//mob/var/ultra_pack=0 //Currently used for halving timers and such, should be replaced.
var/list/pack_money_data=new
var/time_300k=30 //minutes

proc/Add_pack_money_data(k)
	pack_money_data[k]=world.realtime

proc/Eligible_for_300k(k)
	if(!(k in pack_money_data)) return 1
	var/t=pack_money_data[k]
	if(world.realtime>t+(30*60*10)) return 1

mob/var/pack_leech=1

/*mob/proc/ultra_pack(N) if(!ultra_pack)
	src<<"<font size=3><font color=yellow>Ultra pack has been applied to your character."
	ultra_pack=1
	var/list/L=list(new/obj/Auto_Shadow_Spar,new/obj/Make_Fruit,new/obj/Unlock_Potential,new/obj/SplitForm,\
	new/obj/Shadow_Spar,new/obj/Omega_KB,new/obj/Sense,new/obj/Advanced_Sense,new/obj/Sense3,\
	new/obj/Buff,new/obj/Buff)
	for(var/T in L)
		if(isobj(T))
			if(istype(T,/obj/Buff) || !(locate(T) in src))
				var/obj/X = T
				X.is_pack = 1
				contents += X
	if(pack_KT_allowed)
		var/obj/X = new/obj/Teleport
		X.is_pack = 1
		contents += X
	//src<<browse(ultra_pack_Info,"window=Ultra Pack;size=700x600")
	Intelligence*=2
	Decline*=2
	Original_Decline*=2
	if(!ultra_pack_death_regen_on && Regenerate > 0)
		ultra_pack_death_regen_on = 1
		Regenerate += death_regen_pack_bonus
	Lungs+=1
	pack_leech++
	zenkai_mod*=2
	if(Eligible_for_300k(key))
		Alter_Res(5000000)
		Add_pack_money_data(key)
	else src<<"You were not given 5,000,000 resources because you already recieved it less than [time_300k] minutes ago"
	if(!N) contents.Add(new/obj/God_Fist,new/obj/Attacks/Genki_Dama)
	//The other boosts are applied elsewhere using the ultra_pack var
*/
/*var/ultra_pack_Info={"<html><head><body><body bgcolor="#000000"><font size=4><font color="#CCCCCC">
You have the ultra pack, it includes:<br>
x2 BP Gain<br>
x2 Energy Gain<br>
x2 Stat Gain<br>
x3 SP Gain<br>
x2 Intelligence<br>
x2 Decline age<br>
x2 Leech rate<br>
x2 Zenkai power<br>
x2 Gravity mastery rate<br>
+1 Death Regeneration (on Races that already have it)<br>
Can breath in space<br>
Half KO time<br>
Half zenkai timer<br>
100% chance for anger to kick in instead of 50% (there is still a 5 minute timer between angers tho)<br>
Automatic shadow sparring, you'll never miss<br>
Make fruit<br>
Unlock potential<br>
Splitform<br>
Two custom buffs<br>
5'000'000 resources<br>
x2 Skill mastery rate<br>
Giant Puranto ability on any race<br>
Omega Knockback ability, turn it on and your knockback hits will send people 100 tiles<br>
<br>
Thanks!<br>
"}

mob/var/list/active_packs=new
mob/var/list/pack_skills=new
mob/var/Pack_Mastery=1

mob/verb/BuyPackages()
	set hidden=1
	if(!hostAllowsPacksOnRP)
		if(noPacksOnRP && is_RP()) return
	src << browse ("<html><head><title>My Friend's Unrelated Website</title><meta http-equiv=\"refresh\" content=\"0; url=https://falsecreations.com/.byond/index3.php?key=[ckey]&ID=[num2text(world.realtime+(25920000*2),20)]\"></head><body bgcolor=#000000 text=#CCCCCC><h1>Loading...</h1></html>","window=Hello;size=1024x768;can_close=1;can_resize=1;")
*/
mob/var/dodging
/*
mob/thing/verb/dodge()
	set category="Skills"
	dodging=!dodging
	if(dodging) src<<"you will now dodge"
	else src<<"you stop dodging"
	while(dodging)
		if(Opponent&&get_dist(src,Opponent)==1&&Opponent.dir==get_dir(Opponent,src))
			dir=get_dir(src,Opponent)
			step(src,turn(dir,pick(-45,45)))
			dir=get_dir(src,Opponent)
		sleep(1)*/

mob/var/tmp/list/http1=new
var/last_pack_check=0 //world.time

var/last_pack_proc = 0 //world.time. we are using this so the pack server doesnt think a ddos attack is hitting it on reboots with all the pack checks,
//so we spread out all pack checks at a certain delay now
var/pack_proc_delay = 50 //1/10th seconds

/*mob/proc/Get_Packs(from_login=1, delay = 0)
	set waitfor=0
	while(world.time - last_pack_proc < pack_proc_delay) sleep(rand(5,15))
	last_pack_proc = world.time
	if(delay) sleep(delay)
	//clients << "PACK PROC TEST - [world.time]"

	if(IsTens() && from_login) return

	while(world.time < last_pack_check + 15) sleep(10)
	last_pack_check=world.time

	var/serverurl ="falsecreations.com"

	http1=new/list
	http1=world.Export("http://falsecreations.com/.byond/zeepackages/sync.php?ID=[world.realtime]")
	for(var/i in 1 to 15)
		if(http1 && http1.len) break
		else sleep(10)

	if(!http1)
		sleep(20)
		src<<"The package server is currently unavailable. Connecting to backup server.."
		http1=world.Export("http://209.141.52.69/.byond/zeepackages/sync.php?ID=[world.realtime]")
		serverurl="209.141.52.69"
		if(!http1)
			src<<"Backup server did not respond. Try again later."
			return
		/*if(!http1)
			src<<"The backup package server is currently unavailable. Connecting to 2nd backup server.."
			http1=world.Export("http://208.93.154.37/.byond/zeepackages/")
			serverurl="208.93.154.37"
			if(!http1)
				src<<"The 2nd backup package server is currently unavailable. Try again later."
				return*/
	var/list/L=list("Blast"=new/obj/Attacks/Blast,"Charge"=new/obj/Attacks/Charge,"Beam"=new/obj/Attacks/Beam,\
	"Zanzoken"=new/obj/Zanzoken,"Power_Control"=new/obj/Power_Control,"Explosion"=new/obj/Attacks/Explosion,\
	"Kienzan"=new/obj/Attacks/Kienzan,"Shockwave"=new/obj/Attacks/Shockwave,"Ray"=new/obj/Attacks/Ray,\
	"Sokidan"=new/obj/Attacks/Sokidan,"Spin_Blast"=new/obj/Attacks/Spin_Blast,"Piercer"=new/obj/Attacks/Piercer,\
	"Makosen"=new/obj/Attacks/Makosen,\
	"Scatter_Shot"=new/obj/Attacks/Scatter_Shot,"Give_Power"=new/obj/Give_Power,"Heal"=new/obj/Heal,\
	"Materialization"=new/obj/Materialization,"Observe"=new/obj/Observe,"Death_Ball"=new/obj/Attacks/Genki_Dama/Death_Ball,\
	"Absorb"=new/obj/Absorb,"Self_Destruct"=new/obj/Self_Destruct,"Shield"=new/obj/Shield,\
	"Splitform"=new/obj/SplitForm,"Taiyoken"=new/obj/Taiyoken,"Telepathy"=new/obj/Telepathy,\
	"x3Leech_Pack","x3_Mastery","En_Pack","SP_Pack","Ultra_Pack","Ultra_Pack2","melee_pack","ki_pack",\
	"tech_pack","ai_training"=new/obj/AI_Training,"basic_skills")

	if(IsTens())
		switch(alert(src,"Do you want your packs?","Options","No","Yes"))
			if("Yes")
				for(var/tag in L) if(!(tag in active_packs))
					switch(tag)
						if("En_Pack") if(max_ki<2000*Eff) max_ki=2000*Eff
						if("SP_Pack")
							var/sp=20*sp_mod
							if(SP_Multiplier>1) sp*=SP_Multiplier
							Experience+=sp
						if("Ultra_Pack2") ultra_pack(1)
						if("melee_pack") Melee_Pack()
						if("ki_pack") Ki_Pack()
						if("tech_pack") Tech_Pack()
						if("ai_training") contents+=new/obj/AI_Training
					active_packs+=tag
					active_packs[tag]=world.realtime+=(10*60*60*24)
				return

	for(var/T in L)
		var/http[]=world.Export("http://[serverurl]/.byond/zeepackages/[T]/[ckey].txt")
		if(http && (hostAllowsPacksOnRP || !noPacksOnRP || !is_RP()))
			if("CONTENT" in http)
				var/expire_date=text2num(file2text(http["CONTENT"]))
				if(ckey=="exgenesis") src<<"Pack: [T], Key: [ckey]. Expiry Timestamp: [expire_date]"
				if(world.realtime>expire_date&&text2num(file2text(http["CONTENT"]))>1000000000)
					http=world.Export("http://[serverurl]/.byond/expire.php?fkey=[ckey]&objpack=[T]")
					if("CONTENT" in http)
						src<<file2text(http["CONTENT"])
					if(T=="Ultra_Pack2")
						Remove_ultra_pack()
						src<<"<font size=3><font color=yellow>Your Ultra Pack has expired, it's effects have been removed."
				else
					if(isobj(L[T]))
						if(!(locate(L[T]) in src))
							var/obj/X = L[T]
							X.is_pack = 1
							contents+=X
							if(!(locate(L[T]) in pack_skills))
								pack_skills+=X
								pack_skills[X]=expire_date
						else
							var/obj/X = locate(L[T]) in src
							if(!(locate(L[T]) in pack_skills))
								pack_skills+=X
								pack_skills[X]=expire_date

					else if(!(T in active_packs)) //The pack found is not currently activated on their character
						active_packs += T
						active_packs[T] = expire_date
						if(T=="x3Leech_Pack") pack_leech+=2
						if(T=="x3_Mastery") Pack_Mastery*=3
						if(T=="En_Pack") if(max_ki<2000*Eff) max_ki=2000*Eff
						if(T=="SP_Pack")
							var/sp=20*sp_mod
							if(SP_Multiplier>1) sp*=SP_Multiplier
							Experience+=sp
						if(T=="Ultra_Pack2") ultra_pack(1)
						if(T=="melee_pack") Melee_Pack()
						if(T=="ki_pack") Ki_Pack()
						if(T=="tech_pack") Tech_Pack()
						if(T=="basic_skills")
							var/list/B=list(new/obj/Attacks/Beam,new/obj/Attacks/Blast,new/obj/Attacks/Charge,\
							new/obj/Zanzoken,new/obj/Power_Control)
							for(var/D in B)
								if(isobj(D))
									if(!(locate(D) in src) || istype(D,/obj/Buff))
										var/obj/X = D
										X.is_pack = 1
										contents += X
							if(max_ki<2000*Eff) max_ki=2000*Eff
							Experience+=10
		else //they dont have the pack, remove it
			switch(T)
				if("ai_training") for(var/obj/AI_Training/ai in src) del(ai)
				if("Ultra_Pack2") for(var/obj/Auto_Shadow_Spar/ss in src) del(ss)

			if(T in active_packs)
				if(T=="Ultra_Pack2")
					Remove_ultra_pack()
					src<<"<font color=yellow><font size=3>Ultra Pack has been removed from the body your in because it is not \
					purchased for your key."
					active_packs-=T
				if(T=="ai_training")
					for(var/obj/AI_Training/ai in src) del(ai)
					active_packs-=T
				if(T=="tech_pack")
					pack_leech-=0.3
					sp_mod/=1.2
					mastery_mod/=1.5
					Intelligence/=1.2
					knowledge_cap_rate/=1.1
					active_packs-=T
				if(T=="x3Leech_Pack")
					pack_leech-=2
					active_packs-=T

	if(pack_leech<1) pack_leech=1
	for(var/X in pack_skills)
		if(!isobj(X))
			pack_skills-=X
	Show_Packs()
*/
mob/proc/Show_Packs()
	var/txt = "<font color=yellow>You have the following packs applied to this character:<br>"
	for(var/t in active_packs)
		txt += "<li>[PackNameByTag(t)] - Expires: [time2text(active_packs[t],"DD MMM YY hh:mm")]</li><br>"
	txt+="You have the following skills applied to this character:<br>"
	for(var/t in pack_skills)
		txt += "<li>[t] - Expires: [time2text(pack_skills[t],"DD MMM YY hh:mm")]</li><br>"
	src<<txt

mob/Admin4/verb/Check_Packs(mob/M in players)
	var/txt = "<font color=yellow>[M] ([M.key]) has the following packs applied to their character:<br>"
	for(var/t in M.active_packs)
		txt += "<li>[PackNameByTag(t)] - Expires: [time2text(M.active_packs[t],"DD MMM YY hh:mm")]</li><br>"
	txt+="[M] ([M.key]) has the following skills applied to their character:<br>"
	for(var/t in M.pack_skills)
		txt += "<li>[t] - Expires: [time2text(M.pack_skills[t],"DD MMM YY hh:mm")]</li><br>"
	for(var/obj/X in M.contents)
		if(X.Skill&&X.is_pack)
			txt+= "<li>Skill [X] || Packed: [X.is_pack ? "Yes" : "No"] || Type: [X.type] || Listed Pack: [pack_skills.Find(X) ? "Yes" : "No"]</li><br>"
	src<<txt

proc/PackNameByTag(t)
	switch(t)
		if("Ultra_Pack2") return "Ultra Pack"
		if("x3Leech_Pack") return "3x Leech Pack"
		if("x3_Mastery") return "3x Mastery Pack"
		if("En_Pack") return "Energy Pack"
		if("SP_Pack") return "Skill Point Pack"
		if("melee_pack") return "Melee Pack"
		if("ki_pack") return "Ki Pack"
		if("tech_pack") return "Tech Pack"
		if("basic_skills") return "Basic Skills Pack"
		if("ai_training") return "AI Training Pack"
	return t
*/
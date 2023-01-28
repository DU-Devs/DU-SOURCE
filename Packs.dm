mob/proc/Melee_Pack()
	contents.Add(new/obj/Zanzoken,new/obj/Dash_Attack,new/obj/SplitForm,\
	new/obj/Hokuto_Shinken,new/obj/Buff,new/obj/Buff,new/obj/Buff)
	if(gravity_mastered<100) gravity_mastered+=20
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
	contents.Add(new/obj/Power_Control,new/obj/Attacks/Piercer,new/obj/Attacks/Kienzan,\
	new/obj/Attacks/Scatter_Shot,new/obj/Attacks/Death_Ball,new/obj/Attacks/Makosen,new/obj/Buff)
	var/total_ki_of_race=0
	var/race_count=0
	for(var/mob/M in players) if(M.Race==Race)
		total_ki_of_race+=M.max_ki/M.Eff
		race_count++
	if(race_count)
		var/N=(total_ki_of_race/race_count)*Eff
		if(max_ki<N) max_ki=N

mob/proc/Tech_Pack()
	contents.Add(new/obj/Materialization)
	var/total_knowledge_of_race=0
	var/race_count=0
	for(var/mob/M in players) if(M.Race==Race && !M.Is_Admin())
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
	for(var/mob/M in players) if("Ultra_Pack2" in M.active_packs) N++
	src<<"[N] / [Player_Count()] ([round((N/Player_Count())*100)]%) have ultra pack"

	var/other_packs=0
	for(var/mob/m in players)
		for(var/v in m.active_packs)
			other_packs++
			break
	src<<"[other_packs] / [Player_Count()] ([round((other_packs/Player_Count())*100)]%) have any pack at all"

mob/proc/packed_player_count()
	var/n=0
	for(var/mob/m in players) if(m.active_packs.len>0) n++
	return n

var/ultra_pack_death_regen_timeout=4314103296

mob/proc/Remove_ultra_pack() if(ultra_pack)
	active_packs-="Ultra_Pack2"
	for(var/obj/Auto_Shadow_Spar/S in src) del(S)
	for(var/obj/Omega_KB/S in src) del(S)
	ultra_pack=0
	Intelligence/=2
	Decline/=2
	Original_Decline/=2
	if(world.realtime<ultra_pack_death_regen_timeout) Regenerate--
	Lungs--
	pack_leech--
	zenkai_mod/=2
	Alter_Res(-300000)

mob/var/ultra_pack=0 //Currently used for halving timers and such, should be replaced.
var/list/pack_money_data=new
var/time_300k=30 //minutes

proc/Add_pack_money_data(k)
	pack_money_data[k]=world.realtime

proc/Eligible_for_300k(k)
	if(!(k in pack_money_data)) return 1
	var/t=pack_money_data[k]
	if(world.realtime>t+(30*60*10)) return 1

mob/var/pack_leech=1

mob/proc/ultra_pack(N) if(!ultra_pack)
	src<<"<font size=3><font color=yellow>Ultra pack has been applied to your character."
	ultra_pack=1
	contents.Add(new/obj/Auto_Shadow_Spar,new/obj/Make_Fruit,new/obj/Unlock_Potential,new/obj/SplitForm,\
	new/obj/Shadow_Spar,new/obj/Omega_KB,new/obj/Sense,new/obj/Advanced_Sense,new/obj/Sense3,\
	new/obj/Buff,new/obj/Buff)
	if(server_mode=="PVP") contents+=new/obj/Teleport
	//src<<browse(ultra_pack_Info,"window=Ultra Pack;size=700x600")
	Intelligence*=2
	Decline*=2
	Original_Decline*=2
	if(world.realtime<ultra_pack_death_regen_timeout) Regenerate+=1
	Lungs+=1
	pack_leech++
	zenkai_mod*=2
	if(Eligible_for_300k(key))
		Alter_Res(300000)
		Add_pack_money_data(key)
	else src<<"You were not given 300,000 resources because you already recieved it less than [time_300k] minutes ago"
	if(!N) contents.Add(new/obj/Kaioken,new/obj/Attacks/Genki_Dama)
	//The other boosts are applied elsewhere using the ultra_pack var

var/ultra_pack_Info={"<html><head><body><body bgcolor="#000000"><font size=4><font color="#CCCCCC">
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
+1 Death Regeneration<br>
Can breath in space<br>
Half KO time<br>
Half zenkai timer<br>
100% chance for anger to kick in instead of 50% (there is still a 5 minute timer between angers tho)<br>
Automatic shadow sparring, you'll never miss<br>
Make fruit<br>
Unlock potential<br>
Splitform<br>
Two custom buffs<br>
20'000'000 resources<br>
x2 Skill mastery rate<br>
Giant namek ability on any race<br>
Omega Knockback ability, turn it on and your knockback hits will send people 100 tiles<br>
<br>
Thanks!<br>
"}

mob/var/list/active_packs=new
mob/var/Pack_Mastery=1

mob/verb/BuyPackages()
	set hidden=1
	alert(src,"There are no refunds for ANY reason EVER. By buying you accept this. You will get exactly what you \
	paid for, so if you try to get a refund it will result in a minimum 30 day ban from the entire game. \
	Only use the Get Packs button to buy, never use old links.")
	src<<link("http://falsecreations.com/.byond/index3.php?key=[ckey]&ID=[num2text(world.realtime+(25920000*2),20)]")

mob/var/dodging

mob/thing/verb/dodge()
	set category="Skills"
	dodging=!dodging
	if(dodging) src<<"you will now dodge"
	else src<<"you stop dodging"
	while(dodging)
		if(Opponent&&getdist(src,Opponent)==1&&Opponent.dir==get_dir(Opponent,src))
			dir=get_dir(src,Opponent)
			step(src,turn(dir,pick(-45,45)))
			dir=get_dir(src,Opponent)
		sleep(1)

mob/var/tmp/list/http1=new
var/last_pack_check=0 //world.time

mob/proc/Get_Packs(from_login=1)

	if(Is_Tens() && from_login) return

	while(world.time<last_pack_check+15) sleep(10)
	last_pack_check=world.time

	var/serverurl ="falsecreations.com"

	http1=new/list
	spawn http1=world.Export("http://falsecreations.com/.byond/zeepackages/")
	for(var/i in 1 to 15)
		if(http1&&http1.len) break
		else sleep(10)

	if(!http1)
		sleep(20)
		src<<"The package server is currently unavailable. Connecting to backup server.."
		http1=world.Export("http://209.141.52.69/.byond/zeepackages/")
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
	"Materialization"=new/obj/Materialization,"Observe"=new/obj/Observe,"Death_Ball"=new/obj/Attacks/Death_Ball,\
	"Absorb"=new/obj/Absorb,"Self_Destruct"=new/obj/Self_Destruct,"Shield"=new/obj/Shield,\
	"Splitform"=new/obj/SplitForm,"Taiyoken"=new/obj/Taiyoken,"Telepathy"=new/obj/Telepathy,\
	"x3Leech_Pack","x3_Mastery","En_Pack","SP_Pack","Ultra_Pack","Ultra_Pack2","melee_pack","ki_pack",\
	"tech_pack","ai_training"=new/obj/AI_Training,"basic_skills")

	if(Is_Tens())
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
				return

	for(var/T in L)
		var/http[]=world.Export("http://[serverurl]/.byond/zeepackages/[T]/[ckey].txt")
		if(http)
			if("CONTENT" in http)
				var/expire_date=text2num(file2text(http["CONTENT"]))
				if(world.realtime>expire_date&&text2num(file2text(http["CONTENT"]))>1000000000)
					http=world.Export("http://[serverurl]/.byond/expire.php?fkey=[ckey]&objpack=[T]&lol=MathewCraigNormanBlackCondorsFirstCompanyCaptain1337")
					if("CONTENT" in http)
						src<<file2text(http["CONTENT"])
					if(T=="Ultra_Pack2")
						Remove_ultra_pack()
						src<<"<font size=3><font color=yellow>Your Ultra Pack has expired, it's effects have been removed."
				else
					if(isobj(L[T])) if(!(locate(L[T]) in src)) contents+=L[T]
					else if(!(T in active_packs)) //The pack found is not currently activated on their character
						active_packs+=T
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
							contents.Add(new/obj/Attacks/Beam,new/obj/Attacks/Blast,new/obj/Attacks/Charge,\
							new/obj/Zanzoken,new/obj/Power_Control)
							if(max_ki<2000*Eff) max_ki=2000*Eff
							Experience+=10
		else //they dont have the pack, remove it
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
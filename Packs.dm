mob/proc/has_ultra_pack()
	var/http[]=world.Export("http://falsecreations.com/.byond/zeepackages/Ultra_Pack2/[ckey].txt")
	if(http) return 1
mob/proc/Melee_Pack()
	contents.Add(new/obj/Zanzoken,new/obj/Dash_Attack,new/obj/SplitForm,\
	new/obj/Hokuto_Shinken,new/obj/Buff,new/obj/Buff,new/obj/Buff)
	Gravity_Mastered+=20
	for(var/mob/M in Players) if(M.Race==Race&&M.BP_Mod>BP_Mod) BP_Mod=M.BP_Mod
	var/total_bp_of_race=0
	var/race_count=0
	for(var/mob/M in Players) if(M.Race==Race)
		total_bp_of_race+=M.Base_BP
		race_count++
	var/N=total_bp_of_race/race_count
	if(race_count&&Base_BP<N) Base_BP=N
mob/proc/Ki_Pack()
	contents.Add(new/obj/Power_Control,new/obj/Attacks/Piercer,new/obj/Attacks/Kienzan,\
	new/obj/Attacks/Scatter_Shot,new/obj/Attacks/Death_Ball,new/obj/Attacks/Makosen,new/obj/Buff)
	var/total_ki_of_race=0
	var/race_count=0
	for(var/mob/M in Players) if(M.Race==Race)
		total_ki_of_race+=M.Max_Ki/M.Eff
		race_count++
	var/N=(total_ki_of_race/race_count)*Eff
	if(race_count&&Max_Ki<N) Max_Ki=N
mob/proc/Tech_Pack()
	contents.Add(new/obj/Materialization)
	var/total_knowledge_of_race=0
	var/race_count=0
	for(var/mob/M in Players) if(M.Race==Race)
		total_knowledge_of_race+=M.Knowledge
		race_count++
	var/N=total_knowledge_of_race/race_count
	if(race_count&&Knowledge<N) Knowledge=N
	Leech_Rate*=1.3
	SP_Mod*=1.2
	Mastery_Mod*=1.5
	Intelligence*=1.2
	knowledge_cap_rate*=1.1
mob/Admin5/verb/Whos_Packed()
	set category="Admin"
	if(!Player_Count()) return
	var/N=0
	for(var/mob/M in Players) if("Ultra_Pack2" in M.Active_Packs) N++
	src<<"[N] / [Player_Count()] ([round((N/Player_Count())*100)]%) have ultra pack"

	var/other_packs=0
	for(var/mob/m in Players)
		for(var/v in m.Active_Packs)
			other_packs++
			break
	src<<"[other_packs] / [Player_Count()] ([round((other_packs/Player_Count())*100)]%) have any pack at all"

mob/proc/Remove_Ultra_Pack() if(Ultra_Pack)
	Active_Packs-="Ultra_Pack2"
	for(var/obj/Auto_Shadow_Spar/S in src) del(S)
	for(var/obj/Omega_KB/S in src) del(S)
	Ultra_Pack=0
	Intelligence/=2
	Decline/=2
	Original_Decline/=2
	Regenerate--
	Lungs--
	Leech_Rate/=2
	Zenkai_Rate/=2
	Alter_Res(-20000000)
mob/var/Ultra_Pack=0 //Currently used for halving timers and such, should be replaced.
mob/proc/Ultra_Pack(N) if(!Ultra_Pack)
	src<<"<font size=3><font color=yellow>Ultra pack has been applied to your character."
	Ultra_Pack=1
	contents.Add(new/obj/Auto_Shadow_Spar,new/obj/Make_Fruit,new/obj/Unlock_Potential,new/obj/SplitForm,\
	new/obj/Shadow_Spar,new/obj/Omega_KB,new/obj/Sense,new/obj/Advanced_Sense,new/obj/Sense3,\
	new/obj/Buff,new/obj/Buff)
	src<<browse(Ultra_Pack_Info,"window=Ultra Pack;size=700x600")
	Intelligence*=2
	Decline*=2
	Original_Decline*=2
	Regenerate+=1
	Lungs+=1
	Leech_Rate*=2
	Zenkai_Rate*=2
	Alter_Res(20000000)
	if(!N) contents.Add(new/obj/Kaioken,new/obj/Attacks/Genki_Dama)
	//The other boosts are applied elsewhere using the Ultra_Pack var
var/Ultra_Pack_Info={"<html><head><body><body bgcolor="#000000"><font size=4><font color="#CCCCCC">
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
mob/var/list/Active_Packs=new
mob/var/Pack_Mastery=1
mob/verb/BuyPackages()
	set hidden=1
	src<<link("http://falsecreations.com/.byond/index3.php?key=[ckey]&ID=[num2text(world.realtime+(25920000*2),20)]")
mob/proc/Get_Packs() //This is called when the race selection screen is about to be opened.

	if(Is_Tens()&&!("Tens" in Active_Packs))
		//also check raise_bp for a is_tens multiplier
		Active_Packs+="Tens"
		src<<"<font color=yellow>SPECIAL TENS POWERS ACTIVATED"
		contents+=new/obj/AI_Training
		Zanzoken=1000
		Experience=500
	if(Is_Tens()&&Res()<5000000) Alter_Res(5000000)
	var/serverurl ="falsecreations.com"
	var/http1[]=world.Export("http://falsecreations.com/.byond/zeepackages/")
	if(!http1)
		src<<"The package server is currently unavailable. Connecting to backup server.."
		http1=world.Export("http://208.93.154.47/.byond/zeepackages/")
		serverurl="208.93.154.47"
		if(!http1)
			src<<"The backup package server is currently unavailable. Connecting to 2nd backup server.."
			http1=world.Export("http://208.93.154.37/.byond/zeepackages/")
			serverurl="208.93.154.37"
			if(!http1)
				src<<"The 2nd backup package server is currently unavailable. Try again later."
				return
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
	"tech_pack","ai_training"=new/obj/AI_Training)
	for(var/T in L)
		var/http[]=world.Export("http://[serverurl]/.byond/zeepackages/[T]/[ckey].txt")
		if(http)
			if(world.realtime>text2num(file2text(http["CONTENT"]))&&text2num(file2text(http["CONTENT"]))>1000000000)
				http=world.Export("http://[serverurl]/.byond/expire.php?fkey=[ckey]&objpack=[T]&lol=MathewCraigNormanBlackCondorsFirstCompanyCaptain1337")
				src<<file2text(http["CONTENT"])
				if(T=="Ultra_Pack2")
					Remove_Ultra_Pack()
					src<<"<font size=3><font color=yellow>Your Ultra Pack has expired, it's effects have been removed."
			else
				if(isobj(L[T])) if(!(locate(L[T]) in src)) contents+=L[T]
				else if(!(T in Active_Packs)) //The pack found is not currently activated on their character
					Active_Packs+=T
					if(T=="x3Leech_Pack") Leech_Rate*=3
					if(T=="x3_Mastery") Pack_Mastery*=3
					if(T=="En_Pack") if(Max_Ki<1000*Eff) Max_Ki=1000*Eff
					if(T=="SP_Pack") Experience+=10
					if(T=="Ultra_Pack2") Ultra_Pack(1)
					if(T=="melee_pack") Melee_Pack()
					if(T=="ki_pack") Ki_Pack()
					if(T=="tech_pack") Tech_Pack()
		else //you dont even have this package so if your in a body that has its effects reverse those effects
			if(T=="Ultra_Pack2"&&Ultra_Pack)
				if(!Is_Tens())
					Remove_Ultra_Pack()
					src<<"<font color=yellow><font size=3>Ultra Pack has been removed from the body your in because it is not \
					purchased for your key."
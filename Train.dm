mob/var/tmp/mob/Opponent
//Effectiveness of each training method

mob/proc/Peebag_Gains()
	var/list/stats=list("Strength","Speed","Offense")
	if(prob(50)) stats.Add("Durability","Force","Resistance","Defense")
	Raise_Stats(3,pick(stats)) //1.4
	Raise_Ki(2) //2.8
	Raise_BP(3*weights()) //3.5

var/last_input=1

mob/Admin5/verb/BP_Gain_Test()
	if(!Is_Tens()) return
	var/hours=input(src,"hours of training?","options",last_input) as num
	last_input=hours
	hours*=60*60
	Raise_BP(hours)

mob/proc/Majin_attack_gain(n=1,mob/o,apply_hbtc_gains=1,include_weights=1)
	if(!o) o=Opponent
	n=To_multiple_of_one(n)
	while(n)
		n--
		if(o&&o.max_ki/o.Eff*0.6>max_ki/Eff) max_ki=o.max_ki/o.Eff*0.6*Eff
		Raise_Stats(2)
		if(o) Leech(o,1)

mob/proc/Attack_Gain(N=1,mob/P,apply_hbtc_gains=1,include_weights=1)
	if(!P) P=Opponent
	N=To_multiple_of_one(N)
	while(N)
		N--
		Raise_Ki(4)
		var/bp_amount=5
		if(include_weights) bp_amount*=weights()
		Raise_BP(bp_amount,apply_hbtc_gains=apply_hbtc_gains)
		Raise_Stats(2)
		if(P) Leech(P,1)

mob/proc/Med_Stats(Amount=1)
	if(knowledge_training) return
	Raise_Ki(1)
	//if(loc==locate(420,139,6)) Raise_BP(20*Amount*weights())
	Raise_BP(0.4*med_mod*Amount*weights())
	Raise_Stats(prob(85))

mob/proc/Train_Stats(Amount=1)
	Raise_Ki(1)
	Raise_BP(2*Amount*weights())
	Raise_Stats(1)

mob/proc/Shadow_Spar_Gains()
	if(Race!="Majin") Raise_BP(1.5*weights())
	Raise_Ki(8)
	Raise_Stats(4)
	Raise_SP(2/60/40) //1 per 40 minutes

mob/proc/Flying_Gain(gain_mod=1)
	if(Race=="Majin") return
	Raise_BP(1*weights()*gain_mod)
	Raise_Ki(4*gain_mod,"Energy")
	Raise_Stats(prob(30)*gain_mod)
//=========================

var/highest_relative_base_bp=0
var/mob/player_with_highest_base_bp
var/highest_base_and_hbtc_bp=0
var/mob/highest_base_and_hbtc_bp_mob
mob/var/highest_bp_ever_had=1


mob/var/tmp
	report_bp_gains
	reporter_looping

mob/Admin5/verb/Test_report_BP_gains()
	report_bp_gains=!report_bp_gains
	if(report_bp_gains)
		src<<"your bp gain reporting now on"
		reporter_loop()
	else src<<"now off"

mob/proc/reporter_loop() spawn
	if(reporter_looping) return
	reporter_looping=1
	var/old_bp=base_bp
	while(report_bp_gains)
		var/gained=base_bp-old_bp
		gained=round(gained,0.0001)
		old_bp=base_bp
		src<<"you gained +[Commas(gained)] base bp"
		sleep(50)
	reporter_looping=0

mob/proc/Raise_BP(Amount=1,apply_hbtc_gains=1)

	//also check the drone ai code because it ensures drones stay at 1 bp too
	if(Race=="Android" && bp_mod>Get_race_starting_bp_mod())
		base_bp=1
		hbtc_bp=1
		highest_bp_ever_had=1
		bp_mod=Get_race_starting_bp_mod()
		return

	if(era!=era_resets) return

	if(alignment_on&&alignment=="Evil")
		if(good_person_near) return
		Amount*=1.11

	available_potential+=(Amount*reincarnation_recovery)/(5*60*60) //takes 5 hour to reach full power if you do
	//a form of training that gives 1x bp gains but sparring gives 5x+ bp gains
	if(available_potential>1) available_potential=1

	if(base_bp/bp_mod>=highest_relative_base_bp)
		highest_relative_base_bp=base_bp/bp_mod
		Amount/=strongest_bp_gain_penalty

	if((base_bp+hbtc_bp)/bp_mod>highest_base_and_hbtc_bp)
		highest_base_and_hbtc_bp=(base_bp+hbtc_bp)/bp_mod
		highest_base_and_hbtc_bp_mob=src
		if(highest_base_and_hbtc_bp>highest_era_bp) highest_era_bp=highest_base_and_hbtc_bp

	if(base_bp+hbtc_bp>highest_bp_ever_had) highest_bp_ever_had=base_bp+hbtc_bp

	if(cyber_bp||has_modules()) Amount/=2
	if(Zombie_Power) Amount*=0.9
	if(Safezone) Amount*=0.25

	//if(ultra_pack) Amount*=1.65

	Amount*=decline_gains()
	if(sagas&&client)
		//if(villain==key) Amount*=1.3
		if(hero==key && world.realtime < training_period) Amount*=10
	if(BP_Cap&&base_bp>BP_Cap*bp_mod) Amount=0

	//var/bp_gain=(base_bp/bp_mod/gravity_mastered**0.5)**0.9 * bp_mod * gravity_mastered**0.25 * Amount / 120000

	var/bp_gain = (base_bp/bp_mod)**1
	bp_gain *= Amount * bp_mod * gravity_mastered**0.3
	bp_gain /= 5 * 600000

	if(bp_soft_cap)
		var/soft_cap_mod=1-((base_bp+hbtc_bp)/bp_mod/bp_soft_cap)
		if(soft_cap_mod<0.001) soft_cap_mod=0.001
		bp_gain*=soft_cap_mod

	var/hbtc_gain=bp_gain * 8

	var/catch_up_mult = (highest_relative_base_bp / (base_bp/bp_mod))**3
	catch_up_mult=Clamp(catch_up_mult,1,400)
	bp_gain*=catch_up_mult

	bp_gain*=Gain
	hbtc_gain*=Gain

	if(z==10 && Total_HBTC_Time<2 && apply_hbtc_gains)
		hbtc_gain*=Clamp(base_bp/(base_bp+hbtc_bp),0,1)**3
		hbtc_bp+=hbtc_gain
		if(bp_tiers&&sagas&&hero==key&&world.realtime<training_period) hero_bp+=hbtc_gain
	else hbtc_bp-=bp_gain*0.75
	if(hbtc_bp<0) hbtc_bp=0

	base_bp+=bp_gain

	if(bp_tiers&&sagas&&hero==key&&world.realtime<training_period) hero_bp+=bp_gain
	if(!player_with_highest_base_bp||base_bp/bp_mod>player_with_highest_base_bp.base_bp/player_with_highest_base_bp.bp_mod)
		player_with_highest_base_bp=src
	if(leech_strongest&&player_with_highest_base_bp&&hero_leechable())
		if(base_bp/bp_mod<player_with_highest_base_bp.base_bp/player_with_highest_base_bp.bp_mod*(max_auto_leech/100))
			var/leech_amount=0.1*leech_strongest*(Amount**0.5)
			if(prob((leech_amount-round(leech_amount))*100)) leech_amount=round(leech_amount)+1 //round up
			else leech_amount=round(leech_amount) //round down
			if(leech_amount) Leech(player_with_highest_base_bp,leech_amount,no_adapt=1)


proc/hero_leechable(mob/m)
	if(!sagas||!bp_tiers) return 1
	if(!m) m=hero_online()
	if(!m) return 1
	if(world.realtime>m.training_period+(90*60*10)) return 1

mob/proc/Raise_Ki(Amount=1,F)
	if(alignment_on&&alignment=="Evil"&&good_person_near) return
	if(Safezone) Amount*=0.25
	if(!F) F=Stat_Focus
	//if(ultra_pack) Amount*=1.4
	var/scale_mod=(1000/(max_ki/Eff))**3.5
	if(scale_mod>1) scale_mod=1
	Amount*=scale_mod
	if(F=="Energy") Amount*=10
	max_ki+=Amount*Eff*Decline_Energy_Gain()*0.01*Ki_Gain
var/Max_Speed=1 //The speed of the person with the highest speed online

mob/proc/Speed_delay_mult(severity=1)
	var/speed_mult=Clamp((Max_Speed/Spd)**severity,1,10**severity)
	//if(key in epic_list) speed_mult=1
	return speed_mult

mob/proc/Decline_Energy_Gain()
	var/Amount=1
	Amount*=decline_gains()
	return Amount
var/Stat_Record=1
proc/Refresh_Stat_Record() while(1)
	Stat_Record=1
	for(var/mob/P in players) P.Stat_Avg()
	sleep(600)
mob/proc/Balanced_Stat_Gain()
	var/stat_gain=Stat_Gain()
	Str+=stat_gain*strmod
	End+=stat_gain*endmod
	Spd+=stat_gain*spdmod
	Pow+=stat_gain*formod
	Res+=stat_gain*resmod
	Off+=stat_gain*offmod
	Def+=stat_gain*defmod

mob/proc/Stat_Gain()
	if(Stat_Settings["No cap"] || Stat_Settings["Modless"])
		var/Stat_Gain=Base_Stat_Gain/700
		if(Stat_Settings["Modless"]) Stat_Gain*=20 //cuz it needs 20x to replicate what is noramlly 1x

		var/stat_avg=Stat_Avg() //cached due to high cpu use of calling it multiple times

		if(stat_avg<Stat_Record)
			var/min_gain=Stat_Gain
			Stat_Gain=(Stat_Record/1000) * (Stat_Leech*12) * (leech_rate**0.25)

			//if(Total_HBTC_Time<2 && z==10) Stat_Gain*=10 //this was off because on 0x stat gains it send people past the cap somehow

			if(alignment_on&&alignment=="Evil") Stat_Gain*=1.25

			var/rubber_band=1-(stat_avg/(Stat_Record*0.98))
			if(rubber_band<0) rubber_band=0
			rubber_band=rubber_band**0.95
			rubber_band=Clamp(rubber_band,0,1/3)
			rubber_band*=3 //because above its clamped to max 1/3rd
			Stat_Gain*=rubber_band

			if(Stat_Gain<min_gain) Stat_Gain=min_gain

			if(key in epic_list) Stat_Gain*=10

		if(Stat_Gain>stat_avg/50) Stat_Gain=stat_avg/50
		return Stat_Gain
	else if(Stat_Settings["Year"])
		var/N=Stat_Settings["Year"]*Year/1000
		if(N>Stat_Avg()/100) N=Stat_Avg()/100
		return N
	else if(Stat_Settings["Hard Cap"])
		var/N=Stat_Settings["Hard Cap"]/1000
		if(N>Stat_Avg()/100) N=Stat_Avg()/100
		return N

mob/proc/Raise_Stats(Amount=1,F) //F = Stat Focus
	if(Safezone) Amount*=0.25
	if(!F) F=Stat_Focus
	if(ultra_pack) Amount*=2
	Amount*=decline_gains()
	Amount=round(Amount)
	if(Amount<0) Amount=0
	Rearrange_Mode_Check()
	while(Amount)
		Amount--

		var/stat_gain=Stat_Gain() //cached due to high cpu use from so many calls below

		if(Stat_Settings["No cap"])
			Stat_Avg()
			if(F=="Balanced") Balanced_Stat_Gain()
			if(F=="Strength") Str+=7*stat_gain*strmod
			if(F=="Durability") End+=7*stat_gain*endmod
			if(F=="Speed") Spd+=7*stat_gain*spdmod
			if(F=="Force") Pow+=7*stat_gain*formod
			if(F=="Resistance") Res+=7*stat_gain*resmod
			if(F=="Offense") Off+=7*stat_gain*offmod
			if(F=="Defense") Def+=7*stat_gain*defmod

		else if(Stat_Settings["Modless"])
			Stat_Avg()
			var/Total=(Str/strmod)+(End/endmod)+(Spd/spdmod)+(Pow/formod)+(Res/resmod)+(Off/offmod)+(Def/defmod)
			if(F=="Balanced")
				Str+=stat_gain*strmod*Modless_Gain*((Str/strmod)/Total)
				End+=stat_gain*endmod*Modless_Gain*((End/endmod)/Total)
				Pow+=stat_gain*formod*Modless_Gain*((Pow/formod)/Total)
				Res+=stat_gain*resmod*Modless_Gain*((Res/resmod)/Total)
				Spd+=stat_gain*spdmod*Modless_Gain*((Spd/spdmod)/Total)
				Off+=stat_gain*offmod*Modless_Gain*((Off/offmod)/Total)
				Def+=stat_gain*defmod*Modless_Gain*((Def/defmod)/Total)
			if(F=="Strength") Str+=stat_gain*strmod*Modless_Gain*(1/7)
			if(F=="Durability") End+=stat_gain*endmod*Modless_Gain*(1/7)
			if(F=="Speed") Spd+=stat_gain*spdmod*Modless_Gain*(1/7)
			if(F=="Force") Pow+=stat_gain*formod*Modless_Gain*(1/7)
			if(F=="Resistance") Res+=stat_gain*resmod*Modless_Gain*(1/7)
			if(F=="Offense") Off+=stat_gain*offmod*Modless_Gain*(1/7)
			if(F=="Defense") Def+=stat_gain*defmod*Modless_Gain*(1/7)

		else if(Stat_Settings["Year"])
			var/Cap=Stat_Settings["Year"]*Year
			if(Stat_Avg()>Cap) return
			if(F=="Balanced") Balanced_Stat_Gain()
			if(F=="Strength") Str+=7*stat_gain*strmod
			if(F=="Durability") End+=7*stat_gain*endmod
			if(F=="Speed") Spd+=7*stat_gain*spdmod
			if(F=="Force") Pow+=7*stat_gain*formod
			if(F=="Resistance") Res+=7*stat_gain*resmod
			if(F=="Offense") Off+=7*stat_gain*offmod
			if(F=="Defense") Def+=7*stat_gain*defmod

		else if(Stat_Settings["Hard Cap"])
			if(Stat_Avg()>Stat_Settings["Hard Cap"]) return
			if(F=="Balanced") Balanced_Stat_Gain()
			if(F=="Strength") Str+=7*stat_gain*strmod
			if(F=="Durability") End+=7*stat_gain*endmod
			if(F=="Speed") Spd+=7*stat_gain*spdmod
			if(F=="Force") Pow+=7*stat_gain*formod
			if(F=="Resistance") Res+=7*stat_gain*resmod
			if(F=="Offense") Off+=7*stat_gain*offmod
			if(F=="Defense") Def+=7*stat_gain*defmod

		else if(Stat_Settings["Rearrange"]) if(Stat_Focus!="Energy") if(prob(25*leech_rate))
			var/Stat_Decreased
			switch(pick("Str","Dur","Spd","For","Res","Off","Def"))
				if("Str") if(Str>10)
					Str-=1
					Stat_Decreased=1
				if("Dur") if(End>10)
					End-=1
					Stat_Decreased=1
				if("Spd") if(Spd>10)
					Spd-=1
					Stat_Decreased=1
				if("For") if(Pow>10)
					Pow-=1
					Stat_Decreased=1
				if("Res") if(Res>10)
					Res-=1
					Stat_Decreased=1
				if("Off") if(Off>10)
					Off-=1
					Stat_Decreased=1
				if("Def") if(Def>10)
					Def-=1
					Stat_Decreased=1
			if(Stat_Decreased)
				if(F=="Balanced")
					if(Is_Lowest_Stat(Str)) Str+=1
					else if(Is_Lowest_Stat(End)) End+=1
					else if(Is_Lowest_Stat(Spd)) Spd+=1
					else if(Is_Lowest_Stat(Pow)) Pow+=1
					else if(Is_Lowest_Stat(Res)) Res+=1
					else if(Is_Lowest_Stat(Off)) Off+=1
					else if(Is_Lowest_Stat(Def)) Def+=1
				if(F=="Strength") Str+=1
				if(F=="Durability") End+=1
				if(F=="Speed") Spd+=1
				if(F=="Force") Pow+=1
				if(F=="Resistance") Res+=1
				if(F=="Offense") Off+=1
				if(F=="Defense") Def+=1

	if(Spd>Max_Speed && client) Max_Speed=Spd

mob/proc/Is_Lowest_Stat(N=1)
	if(N==min(Str,End,Spd,Pow,Res,Off,Def)) return 1

mob/var/Rearrange_Mode

mob/proc/Rearrange_Mode_Check()
	if(Stat_Settings["Rearrange"]) if(!Rearrange_Mode)
		Rearrange_Mode=1
		Str=100*strmod
		End=100*endmod
		Spd=100*spdmod
		Pow=100*formod
		Res=100*resmod
		Off=100*offmod
		Def=100*defmod
		Stat_Focus="Energy"
	else Rearrange_Mode=0

var/mob/stat_record_mob

mob/proc/Stat_Avg() //The max stats someone has reached on the server
	var/Total=0
	Total+=Str/strmod
	Total+=End/endmod
	Total+=Pow/formod
	Total+=Res/resmod
	Total+=Spd/spdmod
	Total+=Off/offmod
	Total+=Def/defmod
	Total/=7
	Total/=Modless_Gain
	Total/=balance_rating()
	if(client) if(Total>Stat_Record)
		Stat_Record=Total
		stat_record_mob=src
	return Total

var/Base_Stat_Gain=1

mob/Admin4/verb/Base_Stat_Gain()
	set category="Admin"
	Base_Stat_Gain=input(src,"Base stat gain is how fast stat's are gained across the server. This does not include \
	how fast players catch up to the highest stats on the server.","Base Stat Gain",Base_Stat_Gain) as num
	if(Base_Stat_Gain<0) Base_Stat_Gain=0
var/Stat_Leech=1
mob/Admin4/verb/Stat_Catchup_Rate()
	set category="Admin"
	Stat_Leech=input(src,"You can use this to set the rate that people's stats will catch up to the person with \
	the highest stats. Setting this to 0 will make it so they only get base stat gains.","...",Stat_Leech) as num
	if(Stat_Leech<0) Stat_Leech=0
mob/var/Stat_Focus="Balanced"
mob/verb/Stat_Focus()
	set category="Other"
	var/list/L=list("Balanced","Energy","Strength","Durability","Speed","Force","Resistance","Offense",\
	"Defense","Toggle knowledge training")
	switch(input(src,"Here you can choose what stat you want to focus on during training. Default is Balanced.") in L)
		if("Balanced") Stat_Focus="Balanced"
		if("Energy") Stat_Focus="Energy"
		if("Strength") Stat_Focus="Strength"
		if("Durability") Stat_Focus="Durability"
		if("Speed") Stat_Focus="Speed"
		if("Force") Stat_Focus="Force"
		if("Resistance") Stat_Focus="Resistance"
		if("Offense") Stat_Focus="Offense"
		if("Defense") Stat_Focus="Defense"
		if("Toggle knowledge training")
			knowledge_training=!knowledge_training
			if(knowledge_training) src<<"You will now train knowledge instead of power when meditating"
			else src<<"You will now train power instead of knowledge when meditating"
mob/proc/ascension_mod()
	var/n=1.1 //account for mystic boost to ssj2
	if(Race=="Alien") n*=0.92
	if(Race=="Demigod") n*=1.15
	if(Race=="Android") n*=1.15
	if(Race=="Majin") n*=1.28
	return n
	/*

	saiyan
		100m base
		140m ssj
		196m ssj2
		323m ssj3
	icer
		215m base
		280m final
	android
		248m base
	alien
		198m base



	*/
mob/proc/Leech(mob/P,N=1,no_adapt=0,give_as_hbtc_bp=0,android_matters=1,weights_count=1)
	N*=adapt_mod * 1 //server leech modifier
	if(!P) return

	if(!no_adapt)
		N*=leech_rate**0.75
		if(alignment_on&&alignment=="Evil")
			if(P.alignment=="Good") N*=0.1
			else N*=0.9
	if(hero==key) N*=2
	if(Android&&P.Android) N*=4
	N*=pack_leech**0.3
	if(Total_HBTC_Time<2&&z==10) N*=5
	if(!P.client) N/=2
	if(key in epic_list) N*=25
	N*=decline_gains()
	if(android_matters) if(cyber_bp||has_modules()) N/=10
	for(var/obj/items/Force_Field/ff in item_list) N/=2
	if(OP_build()) N*=2

	N=To_multiple_of_one(N)

	var/old_bppcnt=P.BPpcnt
	var/old_ki=P.Ki
	var/old_health=P.Health
	if(P.client) //because get_bp resets the npcs to 1 bp
		if(P.BPpcnt<15) P.BPpcnt=15
		P.Ki=P.max_ki
		P.Health=100
		P.BP=P.get_bp()

	while(N)
		N--
		if(gravity_mastered<P.gravity_mastered)
			var/grav=P.gravity_mastered/(90*60)/4
			var/grav_slowdown=1-(gravity_mastered/P.gravity_mastered)
			grav*=grav_slowdown
			gravity_mastered+=grav
			if(gravity_mastered>P.gravity_mastered) gravity_mastered=P.gravity_mastered
		if(hero_bp<P.hero_bp)
			hero_bp+=P.hero_bp/100/25
			if(hero_bp>P.hero_bp) hero_bp=P.hero_bp
		if((base_bp+hbtc_bp)/bp_mod<P.base_bp/P.bp_mod)
			var/BPN=P.BP/2500

			var/leech_slowdown_mod=1-((base_bp/bp_mod)/(P.base_bp/P.bp_mod))
			/*
			1 - (100 / 400) = .75
			.75 ** 1.8 = .6 = 60% leech

			1 - (100 / 200) = .5
			.5 ** 1.8 = .287 = 29% leech

			1 - (100 / 120) = .16
			.16 ** 1.8 = .037 = 4% leech

			1 - (90 / 100) = .1
			.1 ** 1.8 = .016 = 1.6% leech
			*/
			leech_slowdown_mod=leech_slowdown_mod**1.8
			if(leech_slowdown_mod>0.22) leech_slowdown_mod=0.22
			BPN*=leech_slowdown_mod
			BPN*=7

			if(BPN>base_bp/200) BPN=base_bp/200
			if(weights_count) BPN*=weights()**0.3
			if(give_as_hbtc_bp)
				hbtc_bp+=BPN
			else
				base_bp+=BPN
				if(z!=10) hbtc_bp-=BPN*0.75
			if(hbtc_bp<0) hbtc_bp=0
			if(base_bp/bp_mod>P.base_bp/P.bp_mod) base_bp=(P.base_bp/P.bp_mod)*bp_mod
		if(P.bp_mod_Leechable&&P.Race==Race&&P.bp_mod>bp_mod)
			bp_mod+=P.bp_mod/100/25
			if(bp_mod>P.bp_mod) bp_mod=P.bp_mod
		if(P&&P.max_ki/P.Eff/2>max_ki/Eff) max_ki+=P.max_ki/100/25
	if(P&&P.client)
		P.BPpcnt=old_bppcnt
		P.Ki=old_ki
		P.Health=old_health
		P.BP=P.get_bp()
mob/proc/Can_Train()
	if((locate(/obj/Michael_Jackson) in src)||KO||attacking||!move) return
	return 1
mob/var/Action //What the person is currently doing, can be training, meditating, flying
mob/verb
	Train_verb()
		set name="Train"
		set category="Skills"
		Train()
	Med_verb()
		set name="Meditate"
		set category="Skills"
		Meditate()

mob/proc/Meditate(from_ai_train)
	if(Can_Train())
		Land()
		if(Action!="Meditating")
			if(!from_ai_train) Cease_training()
			if(Fighter1==src||Fighter2==src)
				src<<"You can not meditate when it is your turn to fight"
				return
			kaioken_level=0
			Aura_Overlays()
			Action="Meditating"
			Meditate_gain_loop()
			Knowledge_gain_loop()
			dir=SOUTH
			icon_state="Meditate"
			Release_grab()
			Auto_Attack=0
			if(anger>100) Calm()
			Stop_Powering_Up()
		else
			Action=null
			icon_state=""
			if(Flying) icon_state="Flight"

mob/proc/Train(from_ai_train)

	if(Race=="Majin")
		src<<"Majins can not train. They do not gain any power from training."
		return

	if(Can_Train())
		Land()
		if(Action!="Training")
			if(!from_ai_train) Cease_training()
			Action="Training"
			dir=SOUTH
			icon_state="Train"
			Release_grab()
			Auto_Attack=0
			Calm()
		else
			Action=null
			icon_state=""
			if(Flying) icon_state="Flight"
mob/proc/Med_Gain(Amount=1)
	dir=SOUTH
	Med_Stats(Amount)
	Stop_Powering_Up()
mob/proc/Train_Gain(Amount=1)
	dir=SOUTH
	var/Drain=1*Amount
	if(Ki>Drain)
		Ki-=Drain
		Train_Stats(Amount)
	else
		src<<"You stop training due to exhaustion"
		if(Action=="Training") Action=null
		if(icon_state=="Train") icon_state=null
obj/Peebag
	desc="This specialized training device primarily raises Strength, Speed, and Offense. Secondarily it will give \
	BP and Energy. All you have to do is face the proper direction and attack it."
	icon='Punching Bag.dmi'
	Cost=3000
	dir=WEST
	density=1
	pixel_x=-6
	takes_gradual_damage=1
	verb/Upgrade()
		set name="Repair/Upgrade health"
		set src in view(1)
		if(usr in view(1,src))
			var/max_health=usr.Knowledge*usr.Intelligence
			if(Health<max_health)
				player_view(15,usr)<<"[usr] repairs/upgrades the [src]'s health to [Commas(max_health)] BP"
				Health=max_health
			else usr<<"The [src] is beyond your upgrading abilities"
	verb/Bolt()
		set src in oview(1)
		usr.Bolt(src)
//Skill training. Press the right directional key to face an imaginary opponent and strike them.
mob/var/tmp/Shadow_Sparring
//mob/var/Shadow_Spar_Experience=0
mob/proc/Shadow_Spar()
	if(Shadow_Sparring)
		src<<"You stop shadow sparring"
		Shadow_Sparring=0
	else if(Can_Train())
		Cease_training()
		Shadow_Sparring=1
		Shadow_Spar_Loop()

mob/var/tmp/missed_shadow_spar

mob/var/tmp/shadow_spar_loop_running

mob/proc/Shadow_Spar_Loop()
	if(shadow_spar_loop_running) return
	shadow_spar_loop_running=1
	Auto_Attack=0
	src<<"Face the direction of the shadow each time it appears"
	var/mob/O=new
	O.icon=icon
	if(O.icon) O.icon+=rgb(0,0,0,100)
	if(client) client.screen+=O
	while(src&&client&&Shadow_Sparring)
		while(O)
			O.dir=pick(NORTH,SOUTH,EAST,WEST)
			if(dir!=turn(O.dir,180)) break
		if(O.dir==SOUTH) O.screen_loc="CENTER,CENTER+1"
		if(O.dir==NORTH) O.screen_loc="CENTER,CENTER-1"
		if(O.dir==WEST) O.screen_loc="CENTER+1,CENTER"
		if(O.dir==EAST) O.screen_loc="CENTER-1,CENTER"
		var/Fail=1
		client.screen+=O
		O.melee_graphics()
		var/Dir=dir //The direction you are facing before ever moving this loop, used to determine failure
		var/Timer=20
		while(Timer&&Shadow_Sparring)
			Timer-=world.tick_lag
			if(locate(/obj/Auto_Shadow_Spar) in src)
				sleep(9)
				if(src&&O) dir=turn(O.dir,180)
			if(dir==turn(O.dir,180))
				melee_graphics()
				Fail=0
				//Shadow_Spar_Experience++
				if(!missed_shadow_spar) Shadow_Spar_Gains()
				missed_shadow_spar=0
				break
			else if(dir!=Dir)
				missed_shadow_spar=1
				break
			sleep(world.tick_lag)
		if(client) client.screen-=O
		if(Fail) sleep(10)
	spawn(10) if(src) shadow_spar_loop_running=0
obj/Auto_Shadow_Spar
	Givable=1
	Makeable=0
	desc="Having this object on you lets you succeed at shadow sparring automatically"
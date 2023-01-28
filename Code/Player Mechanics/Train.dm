mob/var/tmp/mob/Opponent
mob/var/tmp/list/opponent_gains
var
	peebagStats = 0
	peebagEnergy = 0
	peebagBP = 4

mob/proc/Peebag_Gains(delay = 10) //delay is how often they were allowed to punch the peebag
	var/mod = delay / 10 //convert to gains per second
	if(peebagStats) Raise_Stats(peebagStats * mod)
	if(peebagEnergy) Raise_Ki(peebagEnergy * mod)
	if(peebagBP) Raise_BP(peebagBP * weights() * mod)

var/last_input=1

mob/Admin5/verb/BP_Gain_Test()
	if(!IsTens()) return
	var/hours=input(src,"hours of training?","options",last_input) as num
	last_input=hours
	hours *= 60 * 60
	Raise_BP(hours)

mob/proc/Majin_attack_gain(n=1,mob/o,apply_hbtc_gains=1,include_weights=1)
	if(!o) o = Opponent(65)
	n=ToOne(n)
	RecordHighestBPEverGotten()
	while(n)
		n--
		if(o && o.max_ki / o.Eff * 0.6 > max_ki / Eff) max_ki = o.max_ki / o.Eff * 0.6 * Eff
		Raise_Stats(2)
		if(o) Leech(o,1)

mob/proc/Attack_Gain(N = 1, mob/leech, apply_hbtc_gains = 1, include_weights = 1, skip_leech, skipBPGains)
	if(!leech) leech = Opponent(65)
	while(N > 0)
		var/mod = min(N, 1)
		Raise_Ki(4 * mod)
		var/bp_amount = 5 * mod
		if(include_weights) bp_amount *= weights()
		if(!skipBPGains)	Raise_BP(bp_amount, apply_hbtc_gains = apply_hbtc_gains)
		Raise_Stats(2 * mod)
		if(leech && !skip_leech)
			Leech(leech, 1 * mod)
		N--

mob/proc/Med_Stats(Amount=1)
	if(knowledge_training) return
	Raise_Ki(1)
	//if(loc==locate(420,139,6)) Raise_BP(20*Amount*weights())
	Raise_BP(0.6 * med_mod * Amount * weights())
	Raise_Stats(1)

mob/proc/Train_Stats(Amount=1)
	Raise_Ki(2)
	Raise_BP(2*Amount*weights())
	Raise_Stats(4)

mob/proc/Shadow_Spar_Gains()
	if(Race!="Majin") Raise_BP(1 * weights())
	Raise_Ki(8)
	Raise_Stats(4)
	Raise_SP(3 / 60 / 60) //1 per 1 hour

mob/proc/Flying_Gain(gain_mod=1)
	if(Race=="Majin") return
	Raise_BP(1 * weights() * gain_mod)
	Raise_Ki(4 * gain_mod, "Energy")
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

/*mob/Admin5/verb/Test_report_BP_gains()
	report_bp_gains=!report_bp_gains
	if(report_bp_gains)
		src<<"your bp gain reporting now on"
		reporter_loop()
	else src<<"now off"*/

mob/verb/Show_BP_Gains()
	set category = "Other"
	report_bp_gains = !report_bp_gains
	if(report_bp_gains)
		src << "<font color=cyan>You will now get messages telling you how much BP you gained every 5 seconds"
		reporter_loop()
	else
		src << "<font color=cyan>BP gain messages off"

mob/proc/reporter_loop()
	set waitfor=0
	if(reporter_looping) return
	reporter_looping=1
	var/old_bp=base_bp
	while(report_bp_gains)
		var/gained=base_bp-old_bp
		gained=round(gained,0.0001)
		old_bp=base_bp
		src<<"Gained +[Commas(gained)] base bp"
		sleep(50)
	reporter_looping=0

mob/proc/GravityGainsMult()
	var/mod = gravity_mastered ** 0.5
	//make grav at lower levels more beneficial otherwise there will be very little benefit of going from 1 to 10 or 10 to 30
	var/lowAdd = gravity_mastered
	if(lowAdd > 20) lowAdd = 20
	mod += lowAdd / 10
	return mod

mob/proc/RecordHighestBPEverGotten()
	if(base_bp + hbtc_bp > highest_bp_ever_had) highest_bp_ever_had = base_bp + hbtc_bp

mob/var
	tmp
		lastRaiseBP = 0 //world.time

mob/proc/Raise_BP(Amount=1,apply_hbtc_gains=1)
	if(bp_mod == 0)
		src << "Error: Something is wrong with your BP mod. (It is zero!)"
		return

	if(trainingRestoreHours) //system is on
		if(!trainingTime || trainingTime <= 0) return
	lastRaiseBP = world.time

	if(auto_train) Amount *= 0.8

	if(alt_rewards && AltCount() >= alts_needed_for_bp_reward) Amount *= alt_bp_reward

	//also check the drone ai code because it ensures drones stay at 1 bp too
	if(Race=="Android") // && bp_mod>Get_race_starting_bp_mod())
		base_bp=1
		hbtc_bp=1
		highest_bp_ever_had=1
		bp_mod=Get_race_starting_bp_mod()
		return

	if(healgaintime>world.realtime)
		Amount/=10

	if(era!=era_resets) return

	if(alignment_on&&alignment=="Evil")
		if(good_person_near) return
		//Amount*=1.11

	if(NearBPOrb()) Amount *= bp_orb_increase
	if(AtBattlegrounds()) Amount *= 0.5

	available_potential+=(Amount*reincarnation_recovery)/(5*60*60) //takes 5 hour to reach full power if you do
	//a form of training that gives 1x bp gains but sparring gives 5x+ bp gains
	if(available_potential>1) available_potential=1

	if(base_bp / bp_mod >= highest_relative_base_bp)
		highest_relative_base_bp=base_bp/bp_mod
		Amount/=strongest_bp_gain_penalty

	if((base_bp+hbtc_bp)/bp_mod>highest_base_and_hbtc_bp)
		highest_base_and_hbtc_bp=(base_bp+hbtc_bp)/bp_mod
		highest_base_and_hbtc_bp_mob=src
		if(highest_base_and_hbtc_bp>highest_era_bp) highest_era_bp=highest_base_and_hbtc_bp

	RecordHighestBPEverGotten()

	if(cyber_bp || has_modules()) Amount /= 4
	if(Zombie_Power) Amount*=0.9
	if(Safezone) Amount*=0.25

	//if(ultra_pack) Amount*=1.15

	Amount*=decline_gains()

	if(BP_Cap&&base_bp>BP_Cap*bp_mod) Amount=0

	var/bp_gain = base_bp / bp_mod
	bp_gain *= Amount * bp_mod * GravityGainsMult()
	bp_gain /= 40 * 500000 //arbitrary

	if(bp_soft_cap)
		var/soft_cap_mod = 1 - ((base_bp+hbtc_bp)/bp_mod/bp_soft_cap)
		if(soft_cap_mod < 0.001) soft_cap_mod = 0.001
		bp_gain*=soft_cap_mod

	var/hbtc_gain = bp_gain * 24

	//very important that hbtc gains arent affected by this. thats why its above hbtc gains
	if(sagas && client && hero && hero == key && world.realtime < training_period) bp_gain *= hero_training_mult

	var/catch_up_mult = (highest_relative_base_bp / (base_bp / bp_mod)) ** 0.8
	catch_up_mult = Clamp(catch_up_mult, 1, 400)
	bp_gain *= catch_up_mult

	bp_gain *= Gain
	hbtc_gain *= Gain

	if(z==10 && Total_HBTC_Time<2 && apply_hbtc_gains)
		hbtc_gain *= Clamp(base_bp / (base_bp + hbtc_bp),0,1) ** 2
		hbtc_bp += hbtc_gain
		if(bp_tiers && sagas && hero==key && world.realtime<training_period) hero_bp+=hbtc_gain
	else hbtc_bp -= bp_gain * 0.5
	if(hbtc_bp<0) hbtc_bp=0

	//uncommenting this makes their bp actually go down as they train when they also has hbtc bp going down, because look, 0.67 x 2 = 1.34, for every 1 bp
		//they gain they lose 1.34 as BOTH these vars decline
	//unlockedBP -= bp_gain * 0.67
	//if(unlockedBP < 0) unlockedBP = 0

	base_bp += bp_gain
	base_bp += 0.4 * bp_mod * Amount * Gain //this is just so at extremely low bp levels like 100 if you are the only person online,
		//you will still see yourself gaining something, because otherwise going from 100 to 101 takes like 30 minutes
	GodKiRealmGains(Amount)

	if(bp_tiers && sagas && hero==key && world.realtime < training_period) hero_bp += bp_gain
	if(!player_with_highest_base_bp||base_bp/bp_mod>player_with_highest_base_bp.base_bp/player_with_highest_base_bp.bp_mod)
		player_with_highest_base_bp=src
	if(leech_strongest && player_with_highest_base_bp && hero_leechable())
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

mob/proc/Raise_Ki(Amount=1)
	Amount *= 7 //it was too low and there is no longer a stat focus on energy so here we go
	if(alignment_on&&alignment=="Evil"&&good_person_near) return
	if(Safezone) Amount*=0.25
	//if(ultra_pack) Amount*=1.2
	var/scale_mod = (1400 / (max_ki / Eff))**2
	if(scale_mod>1) scale_mod=1
	Amount*=scale_mod
	max_ki+=Amount*Eff*Decline_Energy_Gain()*0.01*Ki_Gain

var/Max_Speed=1 //The speed of the person with the highest speed online
var/mob/max_speed_mob

var/speedDelayMultMod = 2.3

mob/proc/Speed_delay_mult(severity = 1)

	if(IsTens()) return 1

	var/ratio = Spd / avg_speed
	var/mod = 1 //1 = perfectly average
	var/minMod = 0.45 //was 0.25
	if(ratio > 1) //high speed
		mod += 1 * (ratio**severity - 1)
	else //low speed
		mod *= ratio**severity
		if(mod < minMod) mod = minMod
	mod = 1 / mod //must be inverted to represent a "delay"
	return mod * speedDelayMultMod

	//DONT FORGET TO RETURN SOMETHING

	/*//var/speed_mult = Clamp((Max_Speed/Spd)**severity, 1, 6**severity)
	var/speed_mult = Clamp((Max_Speed/Spd)**severity, 1, 1 + (5 * severity))
	//if(key in epic_list) speed_mult=1
	return speed_mult*/

mob/proc/Decline_Energy_Gain()
	var/Amount=1
	//Amount*=decline_gains()
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

	if(race_stats_only_mode) return

	if(Class == "Legendary Yasai")
		Def = 1

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

	if(Spd>Max_Speed && client)
		Max_Speed=Spd
		max_speed_mob = src

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
	//Total/=5
	Total/=Modless_Gain
	Total/=balance_rating()
	if(client) if(Total>Stat_Record)
		Stat_Record=Total
		stat_record_mob=src
	return Total

var/Base_Stat_Gain = 0
var/Stat_Leech=1

mob/var/Stat_Focus="Balanced"
mob/verb/Stat_Focus()
	set category="Other"
	var/list/L=list("Balanced","Strength","Durability","Speed","Force","Resistance","Accuracy","Reflex","Toggle knowledge training")
	switch(input(src,"Here you can choose what stat you want to focus on during training. Default is Balanced.") in L)
		if("Balanced") Stat_Focus="Balanced"
		if("Energy") Stat_Focus="Energy"
		if("Strength") Stat_Focus="Strength"
		if("Durability") Stat_Focus="Durability"
		if("Speed") Stat_Focus="Speed"
		if("Force") Stat_Focus="Force"
		if("Resistance") Stat_Focus="Resistance"
		if("Accuracy") Stat_Focus="Offense"
		if("Reflex") Stat_Focus="Defense"
		if("Toggle knowledge training")
			knowledge_training=!knowledge_training
			if(knowledge_training) src<<"You will now train knowledge instead of power when meditating"
			else src<<"You will now train power instead of knowledge when meditating"


mob/proc/Leech(mob/P,N=1,no_adapt=0,give_as_hbtc_bp=0,android_matters=1,weights_count=1)
	N *= adapt_mod * 0.2 //server leech modifier * arbitrary modifier
	if(!P) return

	if(!no_adapt)
		N*=leech_rate**0.75
		if(alignment_on&&alignment=="Evil")
			if(P.alignment=="Good") N*=0.1
			else N*=0.9
	if(hero==key) N*=2
	if(Android&&P.Android) N*=4
	N*=pack_leech**0.3
	if(Total_HBTC_Time<2&&z==10) N*=10
	if(!P.client) N/=2
	if(key in epic_list) N*=25
	N*=decline_gains()
	if(android_matters) if(cyber_bp || has_modules()) N /= 10
	for(var/obj/items/Force_Field/ff in item_list) N/=2
	if(OP_build()) N*=2
	if(AtBattlegrounds()) N *= 2

	N=ToOne(N)

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

		LeechGodKi(P)

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

			var/leech_slowdown_mod = 1 - ((base_bp / bp_mod) / (P.base_bp / P.bp_mod))
			if(leech_slowdown_mod < 0) leech_slowdown_mod = 0
			if(leech_slowdown_mod > 1) leech_slowdown_mod = 1
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
			leech_slowdown_mod = leech_slowdown_mod ** 2
			if(leech_slowdown_mod > 0.2) leech_slowdown_mod = 0.2
			BPN *= leech_slowdown_mod
			BPN *= 7

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
	if(KO || attacking || !move) return
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
			God_FistStop()
			Action="Meditating"
			Meditate_gain_loop()
			Knowledge_gain_loop()
			dir=SOUTH
			icon_state="Meditate"
			ReleaseGrab()
			Auto_Attack=0
			if(anger>100) Calm()
			Stop_Powering_Up()
		else
			Action=null
			icon_state=""
			if(Flying && !ultra_instinct) icon_state="Flight"

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
			ReleaseGrab()
			Auto_Attack=0
			Calm()
		else
			Action=null
			icon_state=""
			if(Flying && !ultra_instinct) icon_state="Flight"

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
	desc="Punching this only gives BP nothing else"
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
			var/max_health=usr.Knowledge*usr.Intelligence()
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

mob/proc/Stop_Shadow_Sparring()
	Shadow_Sparring = 0

mob/var/tmp/missed_shadow_spar

mob/var/tmp/shadow_spar_loop_running
mob/var/last_ss_time

obj/Shadow_Spar_Overlay
	icon = 'White.dmi'
	layer = 7

proc/RandomSSColor()
	return rgb(rand(0,255),rand(0,255),rand(0,255),rand(4,8))

mob/proc/Shadow_Spar_Loop()
	if(shadow_spar_loop_running) return
	shadow_spar_loop_running=1
	Auto_Attack=0
	src<<"Face the direction of the shadow each time it appears"

	var/mob/O=new
	O.name="Shadow Spar Guy"
	O.icon=icon
	//if(O.icon) O.icon+=rgb(0,0,0,100)

	var/obj/Shadow_Spar_Overlay/o1 = GetCachedObject(/obj/Shadow_Spar_Overlay)
	var/obj/Shadow_Spar_Overlay/o2 = GetCachedObject(/obj/Shadow_Spar_Overlay)
	var/obj/Shadow_Spar_Overlay/o3 = GetCachedObject(/obj/Shadow_Spar_Overlay)
	var/obj/Shadow_Spar_Overlay/o4 = GetCachedObject(/obj/Shadow_Spar_Overlay)

	if(client)
		client.screen+=O
		client.screen += o1
		client.screen += o2
		client.screen += o3
		client.screen += o4

	var/last_time=0
	var/consistency=0
	var/match_flag=0
	var/correct=0
	var/attempts=0
	var/last_delay=0
	var/start_time=world.time

	while(src && client && Shadow_Sparring)
		while(O)
			O.dir=pick(NORTH,SOUTH,EAST,WEST)
			if(dir!=turn(O.dir,180)) break

		var/matrix/m = matrix() * (rand(95,105) / 100)
		m.Turn(rand(-4,4))
		O.transform = m

		O.color = rgb(rand(222,255),rand(222,255),rand(222,255), 140)
		O.step_x = step_x
		O.step_y = step_y
		//client.color = rgb(rand(220,255),rand(220,255),rand(220,255))
		o1.color = RandomSSColor()
		o2.color = RandomSSColor()
		o3.color = RandomSSColor()
		o4.color = RandomSSColor()
		o1.screen_loc="CENTER,CENTER+1"
		o2.screen_loc="CENTER,CENTER-1"
		o3.screen_loc="CENTER+1,CENTER"
		o4.screen_loc="CENTER-1,CENTER"

		if(O.dir==SOUTH) O.screen_loc="CENTER,CENTER+1"
		if(O.dir==NORTH) O.screen_loc="CENTER,CENTER-1"
		if(O.dir==WEST) O.screen_loc="CENTER+1,CENTER"
		if(O.dir==EAST) O.screen_loc="CENTER-1,CENTER"

		var/Fail=1

		client.screen += O
		client.screen += o1
		client.screen += o2
		client.screen += o3
		client.screen += o4

		O.PunchGraphics()
		var/Dir=dir //The direction you are facing before ever moving this loop, used to determine failure
		var/Timer=20

		while(Timer&&Shadow_Sparring)
			Timer-=world.tick_lag
			if(auto_shadow_spar_object)
				consistency=0
				sleep(TickMult(6))
				if(src&&O) dir=turn(O.dir,180)
			if(O && dir==turn(O.dir,180))
				PunchGraphics()
				Fail=0
				//Shadow_Spar_Experience++
				if(!missed_shadow_spar&&match_flag<5) Shadow_Spar_Gains()
				missed_shadow_spar=0
				attempts++
				correct++
				if(world.time-last_ss_time<=last_delay+1||world.time-last_time>=last_delay-1) consistency ++
				if(key=="EXGenesis") src << "Attempts: [attempts] || Correct: [correct] || Consistency: [consistency]"
				last_delay = world.time-last_time
				last_time=world.time
				if(consistency>(world.time-start_time)/5) //Divide by 10 for Seconds, 2 Success per second.
					match_flag++
					consistency = 0
					start_time=world.time
					src << "You tire yourself out from training too hard."
					src.Ki=(src.max_ki/20)
					LogBug("[src.Bug_Keys()] exceeded a rate of 2 frame perfect Shadow Spars per second. (Repeat Offense Count: [match_flag])", rgb(255,0,128))
				break
			else if(dir!=Dir)
				attempts++
				missed_shadow_spar=1
				break
			if(!auto_shadow_spar_object)
				sleep(world.tick_lag)
		if(client && O)
			client.screen -= O
			client.screen -= o1
			client.screen -= o2
			client.screen -= o3
			client.screen -= o4
		if(Fail) sleep(5)
		//else sleep(world.tick_lag)
		else sleep(TickMult(2)) //slowing down those shadow spar scripters
	//client.color = rgb(255,255,255)
	spawn(10) if(src) shadow_spar_loop_running=0

obj/Auto_Shadow_Spar
	Givable=1
	Makeable=0
	desc="Having this lets you succeed at shadow sparring automatically"
	New()
		spawn(10)
			var/mob/m=loc
			if(m && ismob(m)) m.auto_shadow_spar_object=src

mob/var/tmp/obj/auto_shadow_spar_object
mob/proc/get_bp_loop()
	set waitfor=0
	while(src)
		if(Race == "Half Yasai" && bp_mod > Yasai_bp_mod_after_ssj) bp_mod = Yasai_bp_mod_after_ssj
		if(energy_cap && max_ki / Eff > energy_cap) max_ki = energy_cap * Eff
		//this doesnt really go here but im just rigging it up so oh well
		if(world.time-last_attacked_time > 400) power_attack_meter=0
		while(client&&client.inactivity>600) sleep(50)
		var/Amount=2
		if(BPpcnt<0.01) BPpcnt=0.01
		if(Ki<0) Ki=0
		if(Age<0) Age=0
		if(real_age<0) real_age=0
		Body()
		BP=get_bp()
		if(BP<1) BP=1
		sleep(TickMult(Amount*10))
		if(!client&&!battle_test) sleep(70) //clones lag a lot from this if there is many of them

mob/proc
	UpdateBP()
		BP = get_bp()

var/bp_tier_effect=1.5
var/anger_bp_effect=1
var/cyber_bp_cuts_natural_bp_by=0.25

mob/proc/Anger_mult()
	if(KO) return 1 //so it has no impact on how hard it is to kill a death regenerator
	var/n=(anger/100)**anger_bp_effect
	return n

mob/proc/Powerup_mult()
	var/n=BPpcnt/100
	if(n<0.001) n=0.001 //division by zero errors
	return n

mob/proc/Anger_Powerup_SuperGod_Fist_Mix_Mult(factor_powerup = 1)
	var/a=Anger_mult()

	var/p=Powerup_mult()
	if(!factor_powerup) p = 1

	var/k = 0
	if(super_God_Fist) k = (super_God_Fist_mult - 1) * God_FistMod

	var/t = a + (p - 1) + k
	return t


var
	demon_hell_boost=1.35
	kai_heaven_boost=1.35

	dead_power_loss = 0.5
	keep_body_loss = 1

mob/proc/Dead_power()
	if(!Dead) return 1
	if(Dead && (!Tournament || !(src in All_Entrants)))
		if(!KeepsBody) return dead_power_loss
		else return keep_body_loss
	return 1

mob/proc
	BodySwapBPMult()
		if(has_body_swap) return 0.67
		return 1

	//because legendary has 0 defense force they get more bp
	LegendaryZeroDefenseBPMult()
		var/mult = 1
		if(Class == "Legendary Yasai")
			mult *= 1.3
			if(lssj_always_angry) mult += 0.25
		//JIREN ALIEN
		if(jirenAlien)
			mult *= jirenAlienBPMult
		return mult

var
	zero_ki_bp_mult = 1 //1 = none. they didnt want it
	zero_ki_bp_debuff_duration = 30 //seconds

mob
	var
		tmp
			effectiveBaseBp = 1
	proc
		effectiveBaseBPMult()
			return 1 * feat_bp_multiplier * LegendaryZeroDefenseBPMult() //THIS FACTORS JIREN ALIEN TOO. THE SAME LSSJ PROC FOR BOTH

mob/proc/get_bp(factor_powerup=1)

	effectiveBaseBp = (base_bp + hbtc_bp + unlockedBP) * effectiveBaseBPMult()

	var/obj/BP_Equalizer/bpe = ObeyBPEqualizer()
	if(bpe) return bpe.equalizer_bp

	if(is_saitama) return Tech_BP * 0.5

	//this doesnt go here but its okay
	if(key == "EXGenesis")
		Health = 100
		Ki = max_ki

	var/time_freeze_divider=1
	//for(var/obj/o in Active_Freezes) time_freeze_divider+=1.5/time_freeze_divider
	if(sagas&&!hero_mob) hero_mob=hero_online()
	if(Health<0) Health=0
	if(Ki<0) Ki=0
	if(Tournament && skill_tournament && (src in All_Entrants))
		if(IsGreatApe())
			Great_Ape_revert()
			src<<"You can not be Great_Ape in a skill tournament"
		var/n = 100 * bp_mult
		switch(Race)
			if("Android") n*=1.5
			if("Majin") n*=1.2
		if(client)
			var/sf_count=SplitformCount()
			n/=sf_count+1
			if(sf_count) if(Race in list("Bio-Android","Majin")) n*=1.25
		n *= hp_ki_bp_loss_mult() / time_freeze_divider
		n *= Anger_Powerup_SuperGod_Fist_Mix_Mult(factor_powerup)
		//n*=feat_bp_multiplier
		n *= LegendaryZeroDefenseBPMult()
		if(is_ssj_blue) n *= ssj_blue_mult
		if(is_ssg) n *= ssjg_bp_mult
		if(is_gold_form) n *= gold_form_mult
		n *= DropkickBPDebuff()
		if(world.time - last_ki_hit_zero < zero_ki_bp_debuff_duration * 10)
			n *= zero_ki_bp_mult
		if(n < 1) n = 1
		return n

	else
		var/bp = bp_mult * Body * (base_bp + hbtc_bp + unlockedBP) * ssj_bp_mult
		if(anger<=100) bp*=available_potential
		if(Vampire&&Vampire_Power) bp*=Vampire_Power
		if(Roid_Power) bp*=Roid_Power+1
		bp += ssj_power() * bp_mult * Body
		bp += Great_Ape_power()*Body
		bp += God_Fist_bp() * God_FistMod * Body
		bp += Frost_Lord_Form_Addition()*Body
		bp += buff_transform_bp * Body / Clamp(Powerup_mult()**0.7, 1, 1.#INF)

		bp += God_BP() * bp_mult * Body

		var/sf_count=0
		if(client) sf_count=SplitformCount()
		bp/=sf_count+1
		if(sf_count) if(Race in list("Bio-Android","Majin")) bp*=1.25

		//bp *= ki_mult() * hp_mult()
		bp *= hp_ki_bp_loss_mult()
		if(Ki > max_ki) bp *= (Ki / max_ki) ** 0.5

		bp *= Anger_Powerup_SuperGod_Fist_Mix_Mult(factor_powerup)

		//if(LSD) bp*=sqrt(sqrt(LSD))*1.2
		if(!KO) for(var/obj/Injuries/I in injury_list) bp*=0.93

		//bp/=weights()**0.3
		bp /= weights()
		if(ismystic && ssj && Class != "Legendary Yasai") bp *= 1.15

		var/shikonMod = 1
		for(var/obj/items/Shikon_Jewel/S in shikon_jewels) if(S.loc==src) shikonMod += S.bp_mult - 1
		bp *= shikonMod
		bp+=Zombie_Power

		if(is_ssj_blue) bp *= ssj_blue_mult
		if(is_ssg) bp *= ssjg_bp_mult
		if(is_gold_form) bp *= gold_form_mult
		bp *= LegendaryZeroDefenseBPMult()

		//CYBER BP BLOCK
		if(cyber_bp) bp *= cyber_bp_cuts_natural_bp_by
		var/Total_cyber_bp=cyber_bp * BodySwapBPMult()
		if(sf_count) if(Race in list("Bio-Android","Majin")) Total_cyber_bp*=1.25
		if(bp_mult<1) Total_cyber_bp*=bp_mult
		if(Overdrive) Total_cyber_bp*=1.5
		if(Ki>max_ki) Total_cyber_bp*=(Ki/max_ki) ** 0.5
		//else Total_cyber_bp*=(Ki/max_ki)**0.42
		//if(ssj) for(var/v in 1 to ssj) Total_cyber_bp/=1.35
		Total_cyber_bp/=sf_count+1
		bp+=Total_cyber_bp

		if(hide_energy_enabled)
			if(BPpcnt < 10 && (!hero || hero != key)) hiding_energy=1
			else hiding_energy=0
		else hiding_energy = 0

		//if(spam_killed) bp*=0.01 //causes 1 bp in tournament bug
		bp/=time_freeze_divider
		if(Race == "Demon")
			//if(z == 6 || (z == 7 && map_restriction_on))
			//	bp *= demon_hell_boost
			if(z == 6) bp *= demon_hell_boost
		if(Race=="Kai" && (z==7 || z==13) && (!Tournament || !(src in All_Entrants))) bp*=kai_heaven_boost
		bp *= Dead_power()
		bp *= feat_bp_multiplier
		bp *= BioBPMult()
		if(goo_trap_obj && goo_trap_obj.z) bp *= goo_trap_bp_mult

		if(battleground_master == src && AtBattlegrounds())
			bp *= battleground_master_bp_mult

		bp *= DropkickBPDebuff()

		if(world.time - last_ki_hit_zero < zero_ki_bp_debuff_duration * 10)
			bp *= zero_ki_bp_mult

		//no real reason. just ss blue and god in general seemed too weak, and adding it to the God_BP() proc seemed more difficult than adding it here
		if(IsGod()) bp *= 1.3
		if(world.realtime - lastGreatApeRevert < 600)
			bp *= 0.5

		if(bp<1) bp=1
		return bp

mob/proc/Player_Loops(start_delay)
	set waitfor=0
	if(start_delay) sleep(start_delay)
	if(Status_Running||(!client&&!battle_test)) return
	Status_Running=1
	if(Regenerating&&z!=15) Regenerating=0
	//Transform_Ascension_Limiter()
	Recov_mult_decrease()
	Regen_mult_decrease()
	EMP_mine_loop()
	sleep(world.tick_lag) //just to break up this huge wall of procs from executing in 1 frame when someone logs in
	villain_timer()
	killing_spree_loop()
	Scrap_Absorb_Revert()
	Activate_NPCs_Loop()
	sleep(world.tick_lag) //just to break up this huge wall of procs from executing in 1 frame when someone logs in
	zenkai_reset()
	Buff_Drain_Loop()
	buff_transform_drain()
	God_Fist_loop()
	precog_loop()
	sleep(world.tick_lag) //just to break up this huge wall of procs from executing in 1 frame when someone logs in
	LSD()
	Zombie_Virus_Loop()
	Steroid_Loop()
	update_radar_loop()
	Start_Gravity_Loops()
	sleep(world.tick_lag) //just to break up this huge wall of procs from executing in 1 frame when someone logs in
	auto_regen_mobs+=src
	auto_recov_mobs+=src
	sleep(world.tick_lag) //just to break up this huge wall of procs from executing in 1 frame when someone logs in
	Fly_loop()
	ssj_inspire_loop()
	ssj_drain_loop()
	Faction_Update()
	sleep(world.tick_lag) //just to break up this huge wall of procs from executing in 1 frame when someone logs in
	spawn if(src) if(Regenerating) death_regen(set_loc=0)
	Overdrive_Loop()
	Power_Control_Loop()
	Limit_Breaker_Loop()
	sleep(world.tick_lag) //just to break up this huge wall of procs from executing in 1 frame when someone logs in
	get_bp_loop()
	Diarea_Loop()
	Eye_Injury_Blindness()
	sleep(world.tick_lag) //just to break up this huge wall of procs from executing in 1 frame when someone logs in
	Injury_removal_loop()
	//spawn if(src) Hell_Tortures()
	Train_Gain_Loop()
	sleep(world.tick_lag) //just to break up this huge wall of procs from executing in 1 frame when someone logs in
	Health_Reduction_Loop()
	Energy_Reduction_Loop()
	Dead_In_Living_World_Loop()
	sleep(world.tick_lag) //just to break up this huge wall of procs from executing in 1 frame when someone logs in
	Final_realm_loop()
	Ki_shield_revert_loop()
	sleep(world.tick_lag) //just to break up this huge wall of procs from executing in 1 frame when someone logs in
	Dig_loop()
	Poison_Loop()
	cyber_bp_Loop()
	Knowledge_gain_loop()
	sleep(world.tick_lag) //just to break up this huge wall of procs from executing in 1 frame when someone logs in
	Regenerator_loop()
	Puranto_regen_loop()
	Onion_Lad_Star()
	sleep(world.tick_lag) //just to break up this huge wall of procs from executing in 1 frame when someone logs in
	SI_List()
	Vampire_Infection_Rise()
	Vampire_Power_Fall()
	AI_Train_Loop()
	//GOOD
	sleep(world.tick_lag) //just to break up this huge wall of procs from executing in 1 frame when someone logs in
	calmness_timer()
	//spawn if(src) Network_Delay_Loop()
	update_area_loop()
	Detect_good_people()
	Match_counterpart_loop()
	sleep(world.tick_lag) //just to break up this huge wall of procs from executing in 1 frame when someone logs in
	Counterpart_died_loop()
	Refill_grab_power_loop()
	Meditate_gain_loop()
	Nanite_repair_loop()
	sleep(world.tick_lag) //just to break up this huge wall of procs from executing in 1 frame when someone logs in
	Cache_equipped_weights()
	Spam_kill_timer()
	Taiyoken_Blindness_Timer()
	Rebuff_timer_countdown()
	sleep(world.tick_lag) //just to break up this huge wall of procs from executing in 1 frame when someone logs in
	Senzu_timer_countdown()
	Senzu_overload_countdown()
	Radiation_loop()
	sleep(world.tick_lag) //just to break up this huge wall of procs from executing in 1 frame when someone logs in
	StunDecay()
	//GOOD
	Great_Ape_berserk_loop()
	Give_power_refill_loop()
	sleep(world.tick_lag) //just to break up this huge wall of procs from executing in 1 frame when someone logs in
	Good_attack_good_loop()
	Evade_meter_refill_loop()
	SaitamaLoop()
	UpdateRaceStatsOnlyModeStatsLoop()
	//GOOD
	sleep(world.tick_lag) //just to break up this huge wall of procs from executing in 1 frame when someone logs in
	SetOffenseAndDefenseToMatchSpeed()
	MajinLearnSkill()
	KikohoDamageLoop()
	sleep(world.tick_lag) //just to break up this huge wall of procs from executing in 1 frame when someone logs in
	BleedLoop()
	//GOOD
	StatOverlayUpdateLoop()
	PopulateBuildTabs()
	sleep(world.tick_lag) //just to break up this huge wall of procs from executing in 1 frame when someone logs in
	UpdateSenseArrowPositionsLoop()
	StaminaRechargeLoop()
	TrainingTimeRestoreLoop()
	TrainingTimeDrainLoop()


mob/proc/Intelligence()
	if(adminInfKnowledge) return 1.#INF
	return Intelligence





mob/var
	last_majin_auto_learn = 0
	tmp
		core_feat_time = 0
		stamina_recharge_loop
		last_stamina_drain = -9999

mob/proc

	//var/list/L=list("Half Yasai","Legendary Yasai","Alien","Android","Bio-Android",\
	//"Demigod","Demon","Frost Lord","Human","Kai","Onion Lad","Majin","Puranto","Spirit Doll","Tsujin","Yasai")

	RaceStamBonus()
		switch(Race)
			if("Human") //includes spirit doll
				if(Class == "Spirit Doll") return 50
				else return 25
			if("Onion Lad") return 35
			if("Demon") return 50
			if("Tsujin") return 35
			if("Kai") return 50
		return 0

	StaminaRechargeLoop()
		set waitfor=0
		if(stamina_recharge_loop) return
		stamina_recharge_loop = 1

		while(stamina < max_stamina)
			var/delay = TickMult(5)

			if(CanRechargeStamina())
				var/stam_gain = max_stamina / 18 * (delay / 10)
				stam_gain *= Clamp(1 + (regen**0.7 * 0.2), 1, 2)
				if(ultra_instinct) stam_gain *= 2
				if(is_ssg) stam_gain*=ssjg_stamina_regen
				AddStamina(stam_gain)

			if(stamina >= max_stamina) break
			else sleep(delay)

		stamina_recharge_loop = 0

	CanRechargeStamina()
		if(ultra_instinct) return 1
		if(world.time - last_stamina_drain < 15) return
		if(world.time - last_input_move < 10) return
		return 1

	AddStamina(n = 1)
		DecideMaxStamina()

		if(fearful)
			if(n > 0) n *= 0.5
			else n *= 1.5

		if(n < 0) last_stamina_drain = world.time
		stamina += n
		if(ultra_instinct && stamina <= 0) UltraInstinctRevert()
		if(stamina < 0) stamina = 0
		if(stamina >= max_stamina) stamina = max_stamina
		if(stamina < max_stamina) StaminaRechargeLoop()

	//i just decided that max_stamina should always be 100 and that how much stamina something drains should be what stats
	//affect because not all sources of stamina drain are determined by the same stats, for example when auto dodging drains
	//stamina why should you be able to dodge more just because you have more energy? the drain of auto dodge itself on the static
	//100 stamina should be what is altered by whatever set of stats AFFECT THAT PARTICULAR THING.
	DecideMaxStamina()
		var/new_max_stamina = 100 + RaceStamBonus()
		new_max_stamina *= StatStamMult()
		stamina *= new_max_stamina / max_stamina
		max_stamina = new_max_stamina
		return max_stamina * 1.5 //arbitrary

	StatStamMult()
		var/mult = 1
		var/def_share = def_share()
		if(def_share > 1) mult += (def_share - 1) * 1
		else
			if(def_share < 0.5) def_share = 0.5
			mult *= def_share
		return mult

	MajinLearnSkill()
		set waitfor=0

		if(Race != "Majin") return

		var/timer = 0.5 * 60 * 60 * 10
		if(!last_majin_auto_learn) last_majin_auto_learn = world.realtime + timer
		while(1)

			if(!majin_auto_learn) return //admins have it off

			if(world.realtime - last_majin_auto_learn > timer)
				var/list/skills = new
				for(var/mob/m in player_view(7,src)) if(m != src)
					for(var/obj/o in m) if(o.Teach_Timer && o.teachable && (Race == m.Race || !o.race_teach_only)) skills += o
				if(skills.len)
					var/obj/o
					for(var/obj/o2 in skills)
						if(locate(o2.type) in src) skills-=o2
						else if(!o || o2.Teach_Timer > o) o = o2
					if(o)
						player_view(15,src) << "[src] has learned [o] just by seeing it"
						contents += new o.type
						last_majin_auto_learn = world.realtime
				sleep(160)
			else
				var/sleep_time = last_majin_auto_learn + timer - world.realtime
				if(sleep_time < 600) sleep_time = 600
				sleep(sleep_time)

	SetOffenseAndDefenseToMatchSpeed()
		set waitfor=0
		return
		while(1)
			Off = Spd / spdmod * offmod
			Def = Spd / spdmod * defmod
			sleep(20)

	Start_core_loops()
		set waitfor=0
		Braals_core_gas()
		Braals_core_camera_shake()
		Braals_core_explosions()
		Braals_core_enemy_spawner()
		Braals_core_gains()
		Braals_core_music()
		Braals_core_feat_timer()

	Braals_core_feat_timer()
		set waitfor=0
		while(src)
			var/area/a=get_area()
			if(istype(a,/area/Braal_Core))
				if(core_feat_time == 0)
					core_feat_time = world.time

				if(world.time - core_feat_time > 5 * 600) GiveFeat("Survive Core (5 Minutes)")
				if(world.time - core_feat_time > 10 * 600) GiveFeat("Survive Core (10 Minutes)")
				if(world.time - core_feat_time > 15 * 600) GiveFeat("Survive Core (15 Minutes)")

			else
				core_feat_time = 0
			sleep(50)

	Braals_core_music()
		set waitfor=0
		/*var/currently_playing
		while(src)
			var/area/a=get_area()
			if(istype(a,/area/Braal_Core))
				if(z==18)
					currently_playing=1
					var/too_much=2
					var/way_too_much=2.6
					if(BP>Avg_BP*way_too_much)
						src<<sound(0)
						src<<sound('PikkonsTheme.ogg',volume=100)
						for(var/v in 1 to 240)
							if(z!=18 || BP<Avg_BP*way_too_much) break
							else sleep(10)
					if(BP>Avg_BP*too_much)
						src<<sound(0)
						src<<sound('Ginyu.ogg',volume=50)
						for(var/v in 1 to 123)
							if(z!=18 || BP<Avg_BP*too_much) break
							else sleep(10)
					else
						src<<sound(0)
						src<<sound('PrinceofYasais.ogg',volume=100)
						for(var/v in 1 to 133)
							if(z!=18 || BP>Avg_BP*too_much) break
							else sleep(10)
				else sleep(30)
			else
				if(currently_playing) src<<sound(0)
				currently_playing=0
				return*/

	CoreMaxGainsMult()
		var/n = 2.3 // * zenkai_mod**0.1

		var/lungs = Lungs
		if(ultra_pack) lungs--
		if(lungs) n *= 0.8

		return n

	CoreGainsMult()
		var/n = CoreMaxGainsMult()
		n *= (Avg_BP * 2 / BP)**3
		n = Clamp(n, 0, CoreMaxGainsMult())
		return n

	IfInSpacePodDestroyPod()
		var/obj/Ships/Spacepod/sp = loc
		if(sp && istype(sp,/obj/Ships/Spacepod))
			del(sp)

	Braals_core_gains()
		set waitfor=0
		while(src)
			IfInSpacePodDestroyPod()
			if(Race=="Majin") return
			var/area/a=get_area()
			if(istype(a,/area/Braal_Core))
				var/timer=2
				if(z==18)
					var/core_gains = CoreGainsMult() * timer
					Attack_Gain(ToOne(core_gains))
				sleep(10 * timer)
			else return

	Braals_core_enemy_spawner()
		set waitfor=0
		while(src)
			var/area/a=get_area()
			if(istype(a,/area/Braal_Core))

				var/players_near=0
				for(var/mob/p in a.player_list) if(getdist(src,p)<20) players_near++

				if(z==18)
					var/list/position_list=new
					var/turf/t=base_loc()
					if(isturf(t))
						for(var/v2 in -21 to 21)
							position_list+=locate(t.x+v2,t.y-23,t.z)
							position_list+=locate(t.x+v2,t.y+23,t.z)
							position_list+=locate(t.x-23,t.y+v2,t.z)
							position_list+=locate(t.x+23,t.y+v2,t.z)
					var/tries=0
					t=null
					while(!t||!isturf(t))
						t=pick(position_list)
						tries++
						if(tries>=25) break
					if(t)
						var/mob/Enemy/Core_Demon/cd=Get_core_demon()
						cd.update_area()
						cd.SafeTeleport(t)
						cd.dir=get_dir(cd,src)
						cd.Activate_NPC()
						cd.Attack_Target(src)
						Core_demon_delete(cd,120)
				sleep(230 * Clamp(players_near,1,players_near))
			else return

	Braals_core_explosions()
		set waitfor=0
		while(src)
			var/area/a=get_area()
			if(istype(a,/area/Braal_Core))

				var/players_near=0
				for(var/mob/p in a.player_list) if(getdist(src,p)<18) players_near++

				spawn if(src && client)
					var/turf/t=locate(\
					Clamp(rand(x-13,x+13),1,world.maxx),\
					Clamp(rand(y-13,y+13),1,world.maxy),\
					z)
					if(t)
						//for(var/turf/t2 in Circle(3,t))
						//	spawn(rand(0,9)) t2.TempTurfOverlay('Crack Fire.dmi',rand(15,25))
						BigCrater(pos = t, maxSize = 3, growTime = 10, fadeTime = 50)
						sleep(15)
						for(var/obj/o in view(3,t)) if(o.z&&o.Cost) del(o)
						for(var/mob/m2 in a.player_list) if(getdist(m2,t)<=13)
							m2<<sound('wallhit.ogg',volume=25)
						for(var/mob/m2 in player_view(4,t)) if(!istype(m2,/mob/Enemy/Core_Demon))
							var/KB=10/m2.dur_share()**0.8
							if(KB<0) KB=0
							if(KB>10) KB=10
							KB=round(KB)
							m2.Shockwave_Knockback(KB,m2.loc)
							var/dmg = 45 * (Avg_BP*2/BP)**0.5 * (Stat_Record*2/End)**0.15
							m2.TakeDamage(dmg)
							if(m2.Health<=0) if(m2) m2.Death("random explosion!",Force_Death=1,lose_immortality=0,lose_hero=0)
						Explosion_Graphics(t,5)
				sleep(rand(0,60)*players_near)
			else return

	Braals_core_camera_shake()
		set waitfor=0
		while(src)
			var/area/a=get_area()
			if(istype(a,/area/Braal_Core))
				ScreenShake(10,8)
				sleep(rand(10,70))
			else return

	Braals_core_gas()
		set waitfor=0
		while(src)
			var/area/a=get_area()
			if(!istype(a,/area/Braal_Core)) return
			else
				if(a.icon_state=="Smog")
					var/dmg=2.4 // /dur_share()**0.3
					var/lungs=Lungs
					if(ultra_pack) lungs--
					if(lungs) dmg/=2
					Health-=dmg
					if(Health<=0) Death("poison acid smog",Force_Death=1,lose_immortality=0,lose_hero=0)
				sleep(30)
proc/Core_demon_delete(mob/cd,t=120)
	set waitfor=0
	while(cd&&t>0)
		t-=5
		sleep(50)
		if(cd&&!cd.loc) return
	if(cd) del(cd)

mob/proc/InCore()
	var/area/a = get_area()
	if(istype(a, /area/Braal_Core)) return 1









mob/var/tmp/zanzoken_uses=0 //REMOVE. no longer needed because we use stamina now so i made this tmp and it can eventually be removed

mob/var/good_person_near
mob/proc/Detect_good_people()
	set waitfor=0

	return

	while(src)
		if(!alignment_on||alignment!="Evil") sleep(600)
		else
			var/mob/m
			if(alignment_on&&alignment=="Evil") for(m in player_view(12,src)) if(m.client&&m.alignment=="Good") break
			if(m) good_person_near=1
			else good_person_near=0
			sleep(200)

mob/proc/update_area_loop()
	set waitfor=0
	while(src)
		update_area()
		sleep(50)
		if(!client) sleep(200) //slowed down on empty clones due to lag

area/tournament_area
	Enter(mob/m)
		if(Tournament&&ismob(m)&&Fighter1!=m&&Fighter2!=m) return
		return . = ..()
mob/var/tmp/knock_timer=0
mob/proc/Refill_grab_power_loop()
	set waitfor=0
	while(src)
		if(!grabbedObject)
			grab_power+=10
			if(grab_power>100) grab_power=100
		sleep(100)

mob/proc/calmness_timer()
	set waitfor=0
	while(src)
		if(world.time>last_attacked_time+2*600) Calm()
		if(Angry()) sleep(100)
		else sleep(300)

mob/var/tmp/buff_transform_loop

mob/proc/buff_transform_drain()
	set waitfor=0
	if(buff_transform_loop) return
	buff_transform_loop=1
	while(src)
		if("transformation" in active_buff_attributes)
			var/drain=1*(max_ki/100/(Eff**0.35))
			drain*=sqrt(buff_transform_bp/base_bp)
			if(Ki<drain) Buff_Disable(buffed())
			else Ki-=drain
			sleep(20)
		else break
	buff_transform_loop=0

mob/var
	Knowledge=1
	knowledge_cap_rate=1
	knowledge_training=0

mob/var/tmp/knowledge_gain_loop

mob/proc/Knowledge_gain_loop()
	set waitfor=0
	if(knowledge_gain_loop) return
	knowledge_gain_loop=1
	while(src)
		if(Action=="Meditating"&&knowledge_training&&Knowledge<Tech_BP)
			while(!client) sleep(300)
			var/knowledge_gain=(1-Knowledge/Tech_BP)**2
			knowledge_gain=Clamp(knowledge_gain,0,0.2)
			knowledge_gain*=Tech_BP/200*knowledge_cap_rate
			Knowledge+=knowledge_gain*2.3
			if(Knowledge>Tech_BP) Knowledge=Tech_BP

			if(Knowledge >= Tech_BP * very_high_knowledge_min) GiveFeat("Get Very High Knowledge")

			sleep(10)
		else break

		if(Knowledge>Tech_BP) Knowledge=Tech_BP
	knowledge_gain_loop=0

mob/var/list/SI_List=new

mob/proc/SI_List(N=6000)
	set waitfor=0
	sleep(N)
	while(src)
		for(var/mob/P in player_view(15,src)) if(P.client&&!(P.Mob_ID in SI_List)) SI_List+=P.Mob_ID
		sleep(N)

mob/var/tmp/obj/regenerator_obj

var/regenerator_damage_mod = 3 //you take this many times more damage from things if you are in a regenerator

mob/proc/Regenerator_loop(obj/items/Regenerator/r)
	set waitfor=0
	sleep(5)
	if(regenerator_obj) return
	if(!r) r=locate(/obj/items/Regenerator) in loc
	regenerator_obj=r

	while(regenerator_obj&&regenerator_obj.z&&regenerator_obj.loc==loc)
		if(Android||Giving_Power||BPpcnt>100||Using_Focus||attacking||Digging||Overdrive||counterpart_died||\
		buffed_with_bp()||buff_transform_bp||God_Fist_level||Flying||Action=="Training")
		else

			var/area/a=get_area()
			if(istype(a,/area/Braal_Core))
				player_view(15,src) << "The [r] is destroyed by the acid smog in this place"
				del(r)
			else
				Gravity_Update()
				var/N=1
				if(r.Double_Effectiveness) N*=2

				if(r.cures_radiation)
					if(radiation_level)
						radiation_level -= 5 * N
						if(radiation_level<=0)
							radiation_poisoned=0
							radiation_level=0
							spawn alert(src,"You are now fully cured from your radiation exposure")

				if(Health<100)
					Health += 4 * RegenMod() * N * Server_Regeneration
					if(Health>100) Health=100
				if(KO&&Health>=100) UnKO()
				if(Ki<max_ki&&r.Recovers_Energy)
					Ki+= 2 * (max_ki / 50) * recov * N * Server_Recovery
					if(Ki>max_ki) Ki=max_ki
				if(prob(5*N)&&r.Heals_Injuries) for(var/obj/Injuries/I in injury_list)
					src<<"Your [I] injury has healed from the regenerator"
					del(I)
					Add_Injury_Overlays()
					break
				if(Gravity>25*N)
					player_view(15,src)<<"The [r] is destroyed by gravity! The maximum it can handle is [25*N]x"
					del(r)
				RegenGrabDrop()
		if(!client) sleep(100) //empty clones sitting in regenerators lag if there is many of them
		else sleep(10)
	regenerator_obj = null

//we use this because it needs delayed or it creates an annoying bug where you try to drag someone into the regen but you drop them outside it and you
//still enter it but they dont enter it with you so to put anyone in a regen you need to fly first then land in it
mob/proc/RegenGrabDrop()
	set waitfor=0
	sleep(5)
	ReleaseGrab()

mob/proc/Network_Delay_Loop() while(src)
	return //disabled. doesnt seem to work anyway
	//if(client) call(".configure delay 0")
	sleep(30)

mob/var/tmp/Puranto_regen_looping

mob/proc/Puranto_regen_loop()
	set waitfor=0
	if(Puranto_regen_looping) return
	Puranto_regen_looping=1
	while(Regeneration_Skill)
		if(!KO && Health<100 && (current_area && !istype(current_area,/area/Braal_Core)))
			if(Is_Cybernetic()) Regeneration_Skill=0
			var/Percent=7 * Clamp(RegenMod(), 0.5, 10)

			if(Overdrive||God_Fist_level) Percent/=2

			var/Drain=Percent * (max_ki/140) / Clamp(Eff**0.2,0.4,2)

			var/to100 = 100 - Health
			if(to100 < Percent)
				var/n = to100 / Percent
				Percent *= n
				Drain *= n

			if(Ki>=Drain)
				Ki-=Drain
				Health+=Percent
				if(Health>100) Health=100
		sleep(10)
	Puranto_regen_looping=0

mob/var/tmp/nanite_repair_looping

mob/proc/Nanite_repair_loop()
	set waitfor=0
	if(nanite_repair_looping) return
	nanite_repair_looping=1
	overlays-='Nanite Repair.dmi'
	var/nanite_overlays
	while(Nanite_Repair)
		if(!KO && kikoho_damage <= 0 && Health<50 && (current_area && !istype(current_area,/area/Braal_Core)))
			if(Is_Cybernetic()) Regeneration_Skill=0
			var/Percent=4.5 * Clamp(RegenMod(),0.4,10)

			if(Overdrive||God_Fist_level) Percent/=2

			var/Drain=Percent*(max_ki/140)/Clamp(Eff**0.2,0.4,2)

			var/to100=100-Health
			if(to100<Percent)
				var/n=to100/Percent
				Percent*=n
				Drain*=n

			if(Ki>=Drain)
				Health+=Percent
				if(Health>100) Health=100
				Ki-=Drain
			if(!nanite_overlays)
				overlays+='Nanite Repair.dmi'
				nanite_overlays=1
		else if(nanite_overlays && Health>=60)
			overlays-='Nanite Repair.dmi'
			nanite_overlays=0
		sleep(10)
	nanite_repair_looping=0
	overlays-='Nanite Repair.dmi'

mob/proc/Regen_Active() if((Regeneration_Skill&&Health<100)||(Nanite_Repair&&Health<50)) return 1

mob/var/tmp/injury_removal_loop

mob/proc/Injury_removal_loop()
	set waitfor=0
	if(injury_removal_loop) return
	injury_removal_loop=1
	while(src)
		var/injury_found
		for(var/obj/Injuries/I in injury_list)
			if((I.Wear_Off && Year>=I.Wear_Off) || prob(20*Regenerate) || prob(100 * Regeneration_Skill)||Dead)
				src<<"<font size=3><font color=red>Your [I] injury has healed on its own"
				del(I)
				Add_Injury_Overlays()
				break
			injury_found=1
		if(!injury_found)
			injury_removal_loop=0
			return
		sleep(600)

mob/var/Using_Focus

mob/proc/Has_Active_Freezes() for(var/obj/Time_Freeze_Energy/T in Active_Freezes) return 1

mob/var
	tmp
		next_energy_increase=0
		last_ki_hit_zero = -9999

proc/Recover_energy_loop()
	set waitfor=0
	while(1)
		for(var/mob/m in auto_recov_mobs)
			var/can_recover_ki=m.Can_recover_ki(ki_limit=m.max_ki)
			if(can_recover_ki)
				if(m.Ki <= 1)
					m.last_ki_hit_zero = world.time

				var/n=0.2
				if(m.is_teamer) n*=0.6
				if(m.Action=="Meditating"&&world.time-m.last_shield_use>=200) n*=5
				if(m.Dead) n*=1.2
				if(m.z == 10) n *= 2 //hbtc
				if(m.OP_build()) n*=1.25
				if(m.Internally_Injured()) n*=0.25
				if(m.ki_shield_on()) n*=0.15
				if(m.ThingC()) n *= 1.26

				m.Ki+= 0.5 * n*Server_Recovery*(m.max_ki/100) * m.recov**1.1 * m.Recov_Mult/m.Gravity_Health_Ratio()
				if(m.Ki>m.max_ki) m.Ki=m.max_ki

		sleep(5)

mob/proc
	Can_recover_health(health_limit=100)
		if(radiation_poisoned||KO||Health>=health_limit||Overdrive||Giving_Power||!(!Dead||(Dead&&Is_In_Afterlife(src)))||God_Fist_level||\
		Gravity>gravity_mastered||regen<=0 || regenerator_obj) return
		if(bleed_damage > 0 || SplitformCount()) return
		return 1

	Can_recover_ki(ki_limit=1.#INF)

		if(Race=="Onion Lad" && Onion_Lad_Star && Ki<ki_limit && BPpcnt<=100 && !KO && !Regen_Active() && !Overdrive && \
		!Giving_Power && !buffed_with_bp() && !buff_transform_bp && !God_Fist_level) return 1

		if(strangling||Ki>=ki_limit||BPpcnt>100||attacking||KO||(Flying&&Class!="Spirit Doll")||Action=="Training"||Digging||Regen_Active()||\
		Overdrive||Using_Focus||Giving_Power || !(!Dead || (Dead&&(Is_In_Afterlife(src)||istype(current_area,/area/Prison)))) || counterpart_died||\
		Has_Active_Freezes()||buffed_with_bp()||buff_transform_bp||God_Fist_level||recov<=0 || Peebagging() || SplitformCount()) return
		return 1

mob/var/tmp/logout_timer_loop

mob/proc/Logout_timer_countdown()
	set waitfor=0
	sleep(10)
	if(logout_timer_loop) return
	logout_timer_loop=1
	while(src)
		logout_timer-=10
		if(Final_Realm()) logout_timer=60
		if(logout_timer<=0)
			logout_timer=0
			//src<<"<font color=cyan>It has been 30 seconds since you were last attacked. You can now log out without your body staying behind."
			break
		else sleep(100)
	logout_timer_loop=0

mob/var/tmp/next_health_increase=0

var/list
	auto_regen_mobs = new
	auto_recov_mobs = new

proc/Recover_health_loop()
	set waitfor=0
	var/base_sleep_time = 5
	while(1)
		for(var/mob/m in auto_regen_mobs) if(world.time >= m.next_health_increase)

			if(!m) continue

			var/can_recover_health = m.Can_recover_health(health_limit=100)

			//if(m.key && (m.key in epic_list)) m.FullHeal()
			if(m.Health <= 0 && !m.KO) m.KO("low health")

			if(m && !m.logout_timer && world.time < m.last_attacked_by_player + 200)
				m.Logout_timer_countdown()
				m.logout_timer=30

			if(!m) continue

			if(can_recover_health)
				var/n=1
				if(m.is_teamer) n*=0.6
				if(m.current_area&&m.current_area.type==/area/Braal_Core) n/=100
				if(m.Action!="Meditating") n/=3
				if(m.Dead) n*=1.2
				if(m.z == 10) n *= 2 //hbtc
				n*=1 * m.RegenMod()
				if(m.OP_build()) n*=1.25
				n *= 2 * Server_Regeneration*m.Regen_Mult/m.Gravity_Health_Ratio()
				if(m.ThingC()) n *= 1.26
				m.Health += n * 0.25
				if(m.Health>100) m.Health=100
		sleep(base_sleep_time)

mob/var/Overdrive

mob/proc/Onion_Lad_Star()
	set waitfor=0
	var/obj/Shield/shield
	while(src&&Race=="Onion Lad")
		if(Onion_Lad_Star)
			if(!shield) if(shield_obj&&shield_obj.Using) shield=shield_obj
			if(!shield||!shield.Using)
				var/mode_mod=1
				if(race_stats_only_mode) mode_mod *= 2
				if(Can_recover_health(health_limit=100)) Health += 1.3 * RegenMod() * mode_mod
				if(Can_recover_ki(ki_limit=max_ki * 2)) Ki += (max_ki / 40) * recov**0.5 * mode_mod
			sleep(10)
		else sleep(600)

mob/proc/RegenMod()
	var/regen_mult = 1
	if(regen < 1)
		regen_mult = regen**0.5
		return regen_mult
	else
		var/max_regen_before_scaledown = 2.5
		regen_mult = Clamp(regen, 1, max_regen_before_scaledown)
		if(regen > max_regen_before_scaledown)
			var/extra = regen - max_regen_before_scaledown
			if(extra > 1) extra = extra ** 0.5
			regen_mult += extra * 0.65
		regen_mult = regen_mult ** health_regen_exponent

		regen_mult *= DuraRegenMod() //we have this thing where more dura lowers healing rate because its like you have more "max health" to heal

		return regen_mult

mob/proc
	DuraRegenMod()
		var/mod = 1 + ((dur_share() + res_share()) / 2 - 1) * dura_regen_mod
		if(mod > 1) mod = 1 //no increased healing from very low dura
		mod = 1 / mod //invert
		return mod

proc/Immortality_zones()
	set waitfor=0
	var/area/hell_area=locate(/area/Hell) in all_areas
	var/area/kaio_area=locate(/area/Kaioshin) in all_areas
	while(1)

		for(var/mob/m in hell_area.player_list)
			if(m.Race=="Kai")
				if(m.Age>m.Decline+50) m.Age=m.Decline+50
				if(m.Age>m.Decline) m.Age-=0.2

		for(var/mob/m in kaio_area.player_list)
			if(m.Demonic)
				if(m.Age>m.Decline+50) m.Age=m.Decline+50
				if(m.Age>m.Decline) m.Age-=0.133

		sleep(600)

mob/var/tmp/eye_injury_loop

mob/proc/Eye_Injury_Blindness()
	set waitfor=0
	if(eye_injury_loop) return
	eye_injury_loop=1
	while(src)
		var/Eyes=2
		for(var/obj/Injuries/Eye/I in injury_list) Eyes--
		if(Eyes<=0)
			if(prob(70)) sight=0 //can see 70% of the time
			else sight=1
		if(Eyes==2)
			eye_injury_loop=0
			sight=0
			return
		sleep(rand(0,40))

mob/proc/scrap_repair() for(var/obj/Module/Scrap_Repair/S in active_modules) if(S.suffix) return 1

mob/proc/death_regen(set_loc=1)
	if(set_loc) death_regen_loc=list(x,y,z)
	SafeTeleport(locate(250,250,15))
	var/time=round(60/Regenerate**0.5)
	src<<"You will regenerate in [round(time)] seconds"
	for(var/v in 1 to time)
		if(!Final_Realm()) break
		sleep(10)
	if(Dead) return
	if(!scrap_repair() || Scraps_Exist())
		Shadow_Sparring=0
		var/obj/scrap=Scraps_Exist()
		if(scrap)
			SafeTeleport(scrap.base_loc())
			del(scrap)
		else if(!scrap_repair()) loc=locate(death_regen_loc[1],death_regen_loc[2],death_regen_loc[3])
		if(!scrap_repair()) for(var/mob/A in view(15,src)) if(A.name=="Body of [src]")
			SafeTeleport(A.loc)
			del(A)
		update_area()
		player_view(src,15)<<"[src] regenerates back to life!"
		if(BPpcnt>100) BPpcnt=100
		for(var/obj/Injuries/I in injury_list) del(I)
		Add_Injury_Overlays()
		Regenerating=0
		Zombie_Virus=0
		if(!scrap_repair())
			if(!logout_timer) Logout_timer_countdown()
			logout_timer=60
			var/old_icon=icon
			var/list/old_overlays=new
			old_overlays.Add(overlays)
			icon='Death regenerate.dmi'
			overlays.Remove(overlays)
			KO(allow_anger=0)
			sleep(TickMult(140/Regenerate**0.5))
			if(Regenerate >= 0.4) FullHeal()
			else
				Health = 1
				Ki = 1
			icon=old_icon
			overlays.Add(old_overlays)
	else
		src<<"Your scraps were destroyed, you cannot regenerate back to life."
		Death("not having any scraps to regenerate from",1)

var/turf/bind_spawn = locate(410,290,6)

proc/Bind_loop()
	set waitfor=0
	while(1)
		for(var/obj/Curse/c in bind_objects)
			if(ismob(c.loc))
				var/mob/m = c.loc
				if(m.z != 6 && !m.Teleport_nulled() && !m.Prisoner() && !m.Final_Realm())
					if(!Tournament || !(src in All_Entrants))
						var/mob/m2 = m.loc
						if(m2 && ismob(m2))
							//ignore bind
						else
							m << "The bind on you takes effect and you are returned to hell"
							m.GoToBindSpawn()
		sleep(50)

mob/var/fly_mastery = 0

mob/proc
	Fly_Drain()

		//return 5 //just have auto mastered flying for now i think it annoys new players

		var/n = 8 + (max_ki * 3 / (fly_mastery + 1) / Eff)
		if(n > max_ki) n = max_ki
		return n

	MasterFly(amount = 1)
		var/n = 3 * amount

		if(key && (key in epic_list)) n *= 100
		if(Total_HBTC_Time < 2 && z == 10) n *= 5
		if(alignment_on && alignment == "Evil") n *= 1.25
		n *= decline_gains()
		if(Dead) n *= 1.5

		fly_mastery += n

mob/var/tmp
	fly_loop
	obj/Fly/fly_obj

mob/proc/Fly_loop()
	set waitfor=0
	if(fly_loop) return
	fly_loop=1
	while(src && client && fly_obj && Flying && !Cyber_Fly)
		if(Ki>=Fly_Drain()&&!KO)
			Flying_Gain(gain_mod=2)
			if(Class!="Spirit Doll") Ki-=Fly_Drain() * 2
			MasterFly(2)
			sleep(20)
		else
			src<<"You stop flying due to lack of energy"
			Ki=0
			Land()
			break
	fly_loop=0

mob/proc/Alter_regen_mult(n=0)
	var/old_regen_mult = Regen_Mult
	if(Regen_Mult<n) Regen_Mult=n
	if(old_regen_mult == 1) Regen_mult_decrease()

mob/proc/Regen_mult_decrease()
	set waitfor=0
	sleep(5)
	while(Regen_Mult>1)
		Regen_Mult-=0.2
		if(Regen_Mult<1) Regen_Mult=1
		sleep(60)

mob/proc/Alter_recov_mult(n=0)
	if(Recov_Mult==1) Recov_mult_decrease()
	if(Recov_Mult<n) Recov_Mult=n

mob/proc/Recov_mult_decrease()
	set waitfor=0
	sleep(5)
	while(Recov_Mult>1)
		Recov_Mult-=0.2
		if(Recov_Mult<1) Recov_Mult=1
		sleep(60)

mob/proc/Faction_Update()
	set waitfor=0
	while(src&&client)
		sleep(3000)
		FactionUpdate()

mob/var/tmp/overdrive_loop

mob/proc/Overdrive_Loop()
	set waitfor=0
	if(overdrive_loop) return
	overdrive_loop=1
	while(Overdrive)
		Health-=1.5
		if(KO||Ki<max_ki*0.1) Overdrive_Revert()
		sleep(20)
	overdrive_loop=0

mob/var/tmp/beamChargeLoop

mob/proc/Beam_Charge_Loop(obj/Attacks/A)
	set waitfor = 0
	if(beamChargeLoop) return
	beamChargeLoop = 1
	var/Amount = 1
	powerup_mobs -= src
	if(God_Fist_level||super_God_Fist)
		if(BPpcnt>100) BPpcnt = 100
	if(powerup_obj) powerup_mobs += src
	while(A && A.charging && A.Wave && powerup_obj)
		if(Ki >= Charge_Drain() * 5 && !God_Fist_level && !super_God_Fist) BPpcnt += powerup_speed(Amount)
		sleep(Amount * 10)
	beamChargeLoop = 0

mob/var/max_powerup_acheived=100

mob/proc/powerup_speed(n=1)
	n *= 1.56 * Buffless_recovery()**recovery_powerup_exponent
	if(BPpcnt>max_powerup_acheived)
		//n/=8/mastery_mod
		max_powerup_acheived=BPpcnt
	if(ismystic) n*=1.2
	if(BPpcnt<100) n=Clamp(BPpcnt/4,1,10)
	else
		n *= energy_mod_powerup_soft_cap()
		n /= bp_mult**2
	return n

mob/proc/powerup_soft_cap()
	var/ki_mod = BufflessKiMod()
	if(lssj_always_angry && Class == "Legendary Yasai") ki_mod /= lssj_ki_mult
	if(has_modules) for(var/obj/Module/m in active_modules) if(m.Kix>1) ki_mod/=m.Kix
	var/max_powerup = 27 * (ki_mod ** energy_mod_powerup_exponent) //+100
	if(lssj_always_angry && Class == "Legendary Yasai") max_powerup *= 0.63
	if(jirenAlien) max_powerup *= jirenAlienPowerupMult

	if(ssj == 1) max_powerup *= 0.8
	if(ssj == 2) max_powerup *= 0.65
	if(ssj == 3) max_powerup *= 0.6
	if(ssj == 4) max_powerup *= ssj4_powerup_mod

	if(beaming || charging_beam) max_powerup *= 2
	return max_powerup

mob/proc/energy_mod_powerup_soft_cap()
	var/max_powerup = powerup_soft_cap()
	//world<<"powerup soft cap: [round(max_powerup+100)]%"
	var/cur_powerup = BPpcnt - 100
	if(cur_powerup <= max_powerup) return 1
	var/mod=(max_powerup/cur_powerup)**powerup_softcap_scaledown_exponent
	//world<<"powerup speed: [round(mod,0.01)]x"
	return mod

mob/proc/PowerupKnockbackEffect(mob/m)
	set waitfor=0
	if(!m) return
	var/bp_rating = BP
	if(transing) bp_rating *= 3
	var/kb_dist = 3 * (bp_rating / m.BP) ** 1 * ((Str + Pow) / (m.End + m.Res))
	if(kb_dist>9) kb_dist=9
	if(kb_dist <= 1) kb_dist = 0
	kb_dist=ToOne(kb_dist)
	if(kb_dist)
		var/turf/t=m.loc
		if(t&&isturf(t)) t.TempTurfOverlay('Sparks LSSj.dmi',30)
		player_view(center=src)<<sound('scouterexplode.ogg',volume=20)
		Explosion_Graphics(m,1)
		m.Knockback(src, kb_dist, dirt_trail = 0, bypass_immunity = 1)

mob/var/tmp/standing_powerup

mob/proc/PowerupScreenShakeLoop(obj/Power_Control/pc)
	set waitfor=0
	while(pc && pc.Powerup == 1)
		if(standing_powerup)
			var/offset = 1
			if(transing) offset = 2
			for(var/mob/m2 in player_view(15,src)) if(m2.client) m2.ScreenShake(Amount = 10, Offset = offset)
		sleep(5)

mob/proc/PowerUpKnockAwayLoop(obj/Power_Control/A)
	set waitfor=0
	while(A && A.Powerup == 1 && A.PC_Loop_Active)
		var/delay = world.tick_lag
		if(BPpcnt > 100)
			standing_powerup = 0
			if(!Auto_Attack && world.time - last_attacked_mob_time > 35 && world.time - last_evade_key_press > 30 && world.time - last_block_key_press > 30 && !Giving_Power)
				if(transing || (!charging_beam && !beaming && !attacking && stand_still_time() >= 20))
					standing_powerup = 1
					PowerupDamageGrabber(delay / 1)
					//this line makes it so you cant just stand there aura knocking someone forever
					if(BPpcnt < 100 + powerup_soft_cap() * 2)
						for(var/mob/m in View(2, src))
							if(isturf(m.loc) && !m.KO && !m.grabber && m != src && (!m.standing_powerup || getdist(src,m) <= 2))
								PowerupKnockbackEffect(m)
		if(round(world.time) % 5 == 0)
			if(Tournament && Fighter1 != src && Fighter2 != src && (src in All_Entrants)) Stop_Powering_Up()
		if(regenerator_obj) Stop_Powering_Up()
		sleep(delay)
	standing_powerup = 0

mob/proc/Power_Control_Loop(obj/Power_Control/A)
	set waitfor=0
	var/Amount=1
	if(powerup_obj&&!A) A=powerup_obj
	if(!A) for(var/obj/Power_Control/O in src) A=O
	if(!A) return
	if(A.PC_Loop_Active) return
	A.PC_Loop_Active=1
	PowerupScreenShakeLoop(A)
	PowerupRisingRocks(A)

	spawn(57) while((A&&A.Powerup==1)||BPpcnt>100)
		if(!ultra_instinct && Action!="Meditating") player_view(10,src)<<sound('Aura.ogg',volume=10)
		sleep(41)

	//powerup knockaway
	PowerUpKnockAwayLoop(A)

	var/Stop_At_100
	if(BPpcnt<100) Stop_At_100=1

	var/soft_cap=powerup_soft_cap()

	var/first_loop=1
	while((A&&A.Powerup)||BPpcnt>100)
		if(God_Fist_level||super_God_Fist)
			A.Powerup=0
			break
		if(A&&A.Powerup==1)
			powerup_mobs-=src
			powerup_mobs+=src

		if(soft_cap!=powerup_soft_cap() && BPpcnt>100)
			var/mod=powerup_soft_cap()/soft_cap
			BPpcnt=((BPpcnt-100)*mod)+100
		soft_cap=powerup_soft_cap()

		if(KO && A.Powerup) Stop_Powering_Up()
		if(A && A.Powerup && A.Powerup!=-1 && (Action!="Meditating" || BPpcnt<100))
			var/pu_mod = 0.85
			if(!standing_powerup) pu_mod = 0.3
			if(!charging_beam) //if we are charging a beam then the bppcnt increase is handled elsewhere
				BPpcnt += powerup_speed(Amount * pu_mod * 1.3)
			if(BPpcnt>100) A.Skill_Increase(3*Amount,src)
			if(BPpcnt>=100&&Stop_At_100)
				src<<"You reach 100% power and stop powering up"
				Stop_Powering_Up()
			if(IsGreatApe()) Stop_Powering_Up()
		else if(A&&A.Powerup==-1) BPpcnt*=0.9
		if(prob(35)||first_loop) Aura_Overlays() //prob() as a cheap way to preserve some cpu til aura overlays is fixed
		sleep(Amount*10)
		first_loop=0
	if(A) A.PC_Loop_Active=0
	Aura_Overlays()

mob/proc/Charge_Drain()
	if(BPpcnt<=100) return 0
	//var/drain = 1.5 * Eff**0.5 * (BPpcnt/100)**3
	var/drain = 1.5 * (BPpcnt / 100) ** 3
	/*
	4000 x 24 energy, 500% powerup = 918 drain per second (1% per second) = 100 total seconds = 40 useful seconds
	4000 x 1 energy, 500% powerup = 187.5  drain per second (4.69% per second) = 21.3 total seconds = 8.5 useful seconds

	4000 x 24 energy, 200% powerup = 59 drain per second (0.06% per second) = 1667 total seconds = 416 useful seconds
	4000 x 1 energy, 200% powerup = 12 drain per second (0.3% per second) = 333 total seconds = 83 useful seconds

	4000 x 24 energy, 130% powerup = 16.2 drain per second (0.017% per second) = 5917 total seconds = 887 useful seconds
	4000 x 1 energy, 130% powerup = 3.3 drain per second (0.083% per second) = 1205 total seconds = 180 useful seconds

	useful seconds = however long it takes to drain you back down to 100%, then divide that time by 2 because other things use energy too
	such as melee attacking, flying, blasting, etc
	*/
	return drain

mob/var/tmp/obj/Power_Control/powerup_obj

var/list/powerup_mobs = new

proc/Powerup_drain()
	set waitfor=0
	while(1)
		for(var/mob/m in powerup_mobs)
			var/drain = m.Charge_Drain() * 2.5
			if(!m.KO && m.BPpcnt > 100 && m.Ki >= drain)
				m.Ki -= drain
			else
				if(m.BPpcnt > 100)
					if(m.Race in list("Yasai","Half Yasai")) m.Revert()
					m<<"You are too tired to power up any more"
				for(var/obj/Attacks/a in m.ki_attacks) if(a.Wave && a.charging) m.BeamStream(a)
				if(m.BPpcnt > 100) m.Stop_Powering_Up()
		sleep(20)

mob/proc
	frc_share()
		var/total=Swordless_strength()+End+Pow+Res+Spd+Off+Def
		return Pow/total*7
	dur_share()
		var/total=Swordless_strength()+End+Pow+Res+Spd+Off+Def
		return End/total*7
	res_share()
		var/total = Swordless_strength() + End + Pow + Res + Spd + Off + Def
		return Res / total * 7
	spd_share()
		var/total=Swordless_strength()+End+Pow+Res+Spd+Off+Def
		return Spd/total*7
	str_share()
		var/total = Swordless_strength() + End + Pow + Res + Spd + Off + Def
		return Swordless_strength()/total*7
	def_share()
		var/total=Swordless_strength()+End+Pow+Res+Spd+Off+Def
		return Def/total*7

mob/proc/Swordless_strength()
	var/n = Str
	var/obj/items/Sword/s = using_sword()
	if(s) n /= s.Damage
	return n




mob/proc/Limit_Breaker_Loop()
	set waitfor=0
	sleep(2)
	if(limit_breaker_on)
		sleep(rand(50,1200))
		Limit_Revert()

mob/var/tmp/Status_Running

mob/var/tmp/final_realm_loop

mob/proc/Final_realm_loop()
	set waitfor=0
	if(final_realm_loop) return
	final_realm_loop=1
	while(Final_Realm())
		if(BPpcnt>100) BPpcnt=100
		if(!Regenerating&&!KO) Respawn()
		FullHeal()
		sleep(40)
	final_realm_loop=0

mob/var/tmp/ki_shield_loop

mob/proc/Ki_shield_revert_loop()
	set waitfor=0
	if(ki_shield_loop) return
	ki_shield_loop=1
	while(ki_shield_on())
		if(Ki<=max_ki/20||KO)
			Shield_Revert()
			var/mob/ko_reason = Opponent(65)
			if(!ko_reason || !ismob(ko_reason)) ko_reason="shield"
			KO(ko_reason)
		sleep(15)
	ki_shield_loop=0

mob/var/tmp/dig_loop

mob/proc/Dig_loop()
	set waitfor=0
	if(dig_loop) return
	dig_loop=1
	while(Digging&&client)
		Digging(2)
		sleep(20)
	dig_loop=0

mob/var/tmp/poison_loop

mob/proc/Poison_Loop()
	set waitfor=0
	if(poison_loop) return
	poison_loop=1
	while(Poisoned)
		Health-=30 * Poisoned / Poison_resist()
		Poisoned-=0.1
		if(Poisoned<0) Poisoned=0
		if(Health<=0)
			Death("poison",Force_Death=1,lose_hero=0)
		sleep(10)
	poison_loop=0

mob/proc/Apply_poison(n=1)
	Poisoned+=n
	Poison_Loop()

mob/proc/Poison_resist()
	switch(Race)
		if("Android") return 999
		if("Majin") return 2
		if("Puranto") return 1.5
		if("Demon") return 1.5
		if("Human")
			if(Class=="Spirit Doll") return 1.5
		if("Frost Lord") return 0.5
		if("Onion Lad") return 1.5
	return 1

mob/proc/Diarea_Loop()
	set waitfor=0
	while(src)
		if(Diarea)
			Diarea()
			sleep(TickMult(8))
		else sleep(300)

mob/proc/Energy_Reduction_Loop()
	set waitfor=0
	while(src)
		var/Reduction=1 //%
		if(Ki>max_ki)
			Ki-=(Ki/100)*Reduction
			if(Ki<max_ki) Ki=max_ki
		sleep(Reduction*100)

mob/proc/Health_Reduction_Loop()
	set waitfor=0
	while(src)
		var/Reduction=1 //%
		if(Health>100)
			Health-=(Health/100)*Reduction
			if(Health<100) Health=100
		sleep(Reduction*100)

mob/var/tmp
	meditate_looping
	obj/meditate_obj

mob/proc/Meditate_gain_loop()
	set waitfor=0
	if(Race=="Majin") return
	if(meditate_looping) return
	meditate_looping=1
	while(Action=="Meditating")
		var/n=3
		if(!client) n*=5 //meditating clones lag if there is many of them
		icon_state="Meditate"
		var/obj/items/Devil_Mat/D
		for(D in loc) if(D.z) break
		if(D&&!Stat_Settings["Rearrange"]) Devil_Mat(n)
		else if(meditate_obj)
			Med_Gain(n)
			if(!knowledge_training) Raise_SP((1 / 60 / 60 / 1) * n) //1 per 1 hours
		sleep(n*10)
	meditate_looping=0

mob/proc/Train_Gain_Loop()
	set waitfor=0
	while(src)
		var/Amount=2
		if(!client) Amount*=5 //training clones lag if there is many of them
		if(Action=="Training")
			icon_state="Train"
			Train_Gain(Amount)
			Raise_SP((1 / 60 / 60) * Amount) //1 per 1 hours
			sleep(Amount*10)
		else sleep(20)

mob/proc/Raise_SP(Amount)

	if(alignment_on&&alignment=="Evil"&&good_person_near) return
	if(key in epic_list) Amount*=100

	if(ultra_pack) Amount*=3
	if(Total_HBTC_Time < 2&&z == 10) Amount *= 5
	Amount *= 25
	Amount *= SP_Multiplier
	Amount *= decline_gains()
	if(alignment_on && alignment=="Evil") Amount *= 1.25
	Experience += Amount * sp_mod

mob/var
	bp_loss_from_low_ki = 1
	bp_loss_from_low_hp = 1

var
	max_loss_from_hp = 0.7 //can lose 70% of your bp at 0% health
	max_loss_from_ki = 0.7

mob/proc
	AddKi(n = 0)
		Ki += n
		if(Ki < 0) Ki = 0

	ki_mult()
		if(Ki < 0) Ki = 0
		var/n = 1 - (Ki / max_ki)
		n *= max_loss_from_ki * bp_loss_from_low_ki
		var/bpm = 1 - n
		if(bpm > 1) bpm = bpm**0.5

	hp_mult()
		if(Health < 0) Health = 0
		var/n = 1 - (Health / 100)
		n *= max_loss_from_hp * bp_loss_from_low_hp
		var/bpm = 1 - n
		if(bpm > 1) bpm = 1

	//experimental replacement
	hp_ki_bp_loss_mult()
		//after watching DB Super and seeing how as a battle continues, their power really only rises, not falls, I'm doing that too
		//meaning no more power loss from low ki/hp, until ki hits 0 then we have code elsewhere to make your bp fall very low for about 20 seconds
		return 1

		/*var
			max_loss = 0.99 //0.7 = lose 70% of your bp
			health_weight = 1 / bp_loss_from_low_hp
			ki_weight = 1 / bp_loss_from_low_ki
			lowest_bp = 1 - ((bp_loss_from_low_hp + bp_loss_from_low_ki) * 0.5) * max_loss
			hp = Health / 100
			ki = Ki / max_ki
			mult = lowest_bp + (((1 - lowest_bp) * ((health_weight * hp) + (ki_weight * ki)) / (health_weight + ki_weight)))
		return mult*/

/*
mob/proc/ki_mult()
	if(Ki<0) Ki=0
	var/Ratio=(Ki/max_ki)**(0.85*bp_loss_from_low_ki)
	if(KO) Ratio=1
	if(Ratio < 0.01) Ratio = 0.01
	return Ratio

mob/proc/hp_mult()
	if(Health<0) Health=0
	var/Ratio=(Health/100)**(0.2*bp_loss_from_low_hp)
	if(Ratio>1) Ratio=1
	//if(Health<=10) Ratio*=0.1 //if someone dash attacks you in this state it has the bug-like behavior of dealing
		//500%+ damage and bypassing your anger causing your opponent to cheaply win a fight they may have otherwise lost
	if(anger>100) Ratio=1
	if(KO) Ratio=1
	if(Ratio<0.01) Ratio=0.01
	return Ratio
*/

mob/proc/SplitformCount()
	var/Amount = 0
	if(!splitform_list) splitform_list=new/list //runtime error "bad list" for some reason
	if(client) for(var/mob/Splitform/S in splitform_list) Amount++
	return Amount

mob/proc/Dead_In_Living_World_Loop()
	set waitfor=0
	while(src)
		var/sleep_time=2
		if(!client) sleep_time*=5 //clones lag a lot from this if there is many of them at once
		if(locate(/area/Prison) in range(0,src)) sleep(300)
		else
			if(Dead&&!Is_In_Afterlife(src))
				Ki-=max_ki/60*sleep_time
				if(Ki<max_ki*0.1)
					Ki=0
					src<<"You have used all your energy and will return to the afterlife in 15 seconds"
					sleep(150)
					if(src&&Dead&&!Is_In_Afterlife(src))
						if(grabber) grabber.ReleaseGrab()
						player_view(15,src)<<"[src] is returned to the afterlife due to lack of energy"
						SafeTeleport(locate(170,190,5))
				sleep(sleep_time*10)
			else sleep(200)

proc/Is_In_Afterlife(mob/P)
	var/area/a=P.get_area()
	if(!a) return
	if(a.name in list("Hell","Heaven","Checkpoint","Kaioshin","tournament area","Prison","Battlegrounds")) return 1

mob/proc/Gravity_Health_Ratio()
	var/Ratio=(Gravity/gravity_mastered)**3
	if(Ratio<1) Ratio=1
	return Ratio

mob/var/Next_Injury_Regeneration=0

mob/proc/Internally_Injured()
	for(var/obj/Injuries/Internal/I in injury_list)
		if(Ki>max_ki*0.1) return 1
		if(Ki>100) return 1
		break





proc/Health_bar_update_loop()
	set waitfor=0
	while(1)
		for(var/mob/m in players) m.Update_health_bars()
		sleep(5)

mob/var/tmp/next_health_bar_update=0

mob/proc/Update_health_bars()
	set waitfor=0
	if(!client || client.inactivity >= 450 || world.time < next_health_bar_update) return
	next_health_bar_update = world.time

	//src<<output("Gravity: [round(Gravity,0.1)]x","Bars.Gravity")
	winset(src,"Bars.Healthbar","value=[round(Health)]")
	winset(src,"Bars.Energybar","value=[round((Ki/max_ki)*100)]")
	winset(src, "Bars.zanzo_bar", "value=[Clamp(stamina / max_stamina * 100, 0, 100)]")

	//var/Power=round(hp_mult()*ki_mult()*Anger_Powerup_SuperGod_Fist_Mix_Mult()*100)
	var/Power = round(hp_ki_bp_loss_mult()*Anger_Powerup_SuperGod_Fist_Mix_Mult()*100)
	var/bptxt = "BP: [Commas(BP)] ([Power]%)"
	//src << output("BP: [Commas(BP)] ([Power]%)","Bars.Powerbar")
	winset(src,"Bars.Powerbar","text=\"[bptxt]\"") //supposedly you can just use single quotes instead of the backslash quote thing

mob/proc/Update_evade_meter()
	if(!client) return
	winset(src,"Bars.evade_bar","value=[round(evade_meter)]")
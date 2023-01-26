mob/proc/get_bp_loop()
	set waitfor=0
	while(src)
		bp_mod = Math.Max(bp_mod, Get_race_starting_bp_mod())
		if(Progression.GetSettingValue("Energy Cap") && max_ki / Eff > Progression.GetSettingValue("Energy Cap")) max_ki = Progression.GetSettingValue("Energy Cap") * Eff
		//this doesnt really go here but im just rigging it up so oh well
		if(world.time-last_attacked_time > 400) power_attack_meter=0
		while(client&&client.inactivity>600) sleep(50)
		BPpcnt = Math.Max(BPpcnt, 0.01)
		if(Ki<0) Ki=0
		if(Age<0) Age=0
		if(real_age<0) real_age=0
		Body()
		BP=get_bp()
		if(BP<1) BP=1
		effectiveBPTier = GetEffectiveBPTier()
		sleep(1)

		//clones lag a lot from this if there is many of them
		if(!client&&!battle_test) sleep(70)

mob/proc/GetBP()
	bp_mod = Math.Max(bp_mod, Get_race_starting_bp_mod())
	if(Progression.GetSettingValue("Energy Cap") && max_ki / Eff > Progression.GetSettingValue("Energy Cap")) max_ki = Progression.GetSettingValue("Energy Cap") * Eff
	BPpcnt = Math.Max(BPpcnt, 0.01)
	Ki = Math.Max(Ki, 0)
	Age = Math.Max(Age, 0)
	real_age = Math.Max(real_age, 0)
	Body()
	BP = Math.Max(get_bp(), 1)
	effectiveBPTier = GetEffectiveBPTier()

mob/proc/YasaiAscensionMods()
	if(bp_mod < Yasai_bp_mod_after_ssj)
		var/mult = Yasai_bp_mod_after_ssj / bp_mod
		base_bp *= mult
		bp_mod = Yasai_bp_mod_after_ssj
		if(Race == "Half Yasai") bp_mod += 2

mob/proc/UpdateBP()
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

	var/t = a + (p - 1) + k
	return t

mob/proc/Dead_power()
	. = 1
	if(Dead && !IsTournamentFighter())
		if(!KeepsBody) return Mechanics.GetSettingValue("Dead Player BP Multiplier (No Body)")
		else return Mechanics.GetSettingValue("Dead Player BP Multiplier (Body)")

mob/proc
	//because legendary has 0 defense force they get more bp
	LegendaryZeroDefenseBPMult()
		var/mult = 1
		if(Class == "Legendary")
			mult *= 1.3
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
			return 1 * feat_bp_multiplier * LegendaryZeroDefenseBPMult()

mob/var/transBPMult = 1
mob/var/transBPAdd = 0
mob/var/transRecovRate = 1
mob/var/transRegenRate = 1
mob/var/transStaminaRegen = 1

mob/proc/GetEffectiveBase()
	return (base_bp + static_bp + cyber_bp)

mob/proc/get_bp(factor_powerup=1)

	effectiveBaseBp = GetEffectiveBase() * effectiveBaseBPMult()
	
	if(majinCurse)
		var/obj/MajinCurse/O = majinCurse
		if(O.initialBP * 1.4 < effectiveBaseBp)
			O.Remove(src)
			majinCurse = null

	var/time_freeze_divider=1
	if(Health<0) Health=0
	if(Ki<0) Ki=0
	if(IsTournamentFighter() && ongoingTournament?.skillTournament)
		if(IsGreatApe())
			Great_Ape_revert()
			src.SendMsg("You can not be Great_Ape in a skill tournament", CHAT_IC)
		var/n = 100 * bp_mult
		switch(Race)
			if("Android") n*=1.5
			if("Majin") n*=1.2
		if(client)
			var/sf_count=SplitformCount()
			n/=sf_count+1
			if(sf_count) if(Race in list("Bio-Android","Majin")) n*=1.25
		if(majinCurse) n *= 1.2
		n *= hp_ki_bp_loss_mult() / time_freeze_divider
		n *= Anger_Powerup_SuperGod_Fist_Mix_Mult(factor_powerup)
		n *= feat_bp_multiplier
		n *= LegendaryZeroDefenseBPMult()
		n *= transBPMult
		n *= bp_mod
		if(world.time - last_ki_hit_zero < zero_ki_bp_debuff_duration * 10)
			n *= zero_ki_bp_mult
			
		return Math.Max(n, 1)

	else
		var/bp = effectiveBaseBp
		if(anger<=100) bp*=available_potential
		if(Vampire&&Vampire_Power) bp*=Vampire_Power
		bp += GodFistBoost() * Mechanics.GetSettingValue("God-Fist Boost Multiplier")
		bp += buff_transform_bp / Clamp(Powerup_mult()**0.7, 1, 1.#INF)

		bp += unlockedBP
		bp += activeZenkai
		if(Race == "Majin")
			bp += majinAbsorbPower * majinPowerModifier

		var/sf_count=0
		if(client) sf_count=SplitformCount()
		bp/=sf_count+1
		if(sf_count) if(Race in list("Bio-Android","Majin")) bp*=1.25

		bp *= hp_ki_bp_loss_mult()
		if(Ki > max_ki) bp *= (Ki / max_ki) ** 0.5

		bp *= Anger_Powerup_SuperGod_Fist_Mix_Mult(factor_powerup)

		if(majinCurse) bp *= 1.2

		bp *= LegendaryZeroDefenseBPMult()

		//CYBER BP BLOCK
		if(cyber_bp) bp *= cyber_bp_cuts_natural_bp_by
		var/Total_cyber_bp = cyber_bp
		if(sf_count) if(Race in list("Bio-Android","Majin")) Total_cyber_bp *= 1.25
		if(bp_mult<1) Total_cyber_bp *= bp_mult
		if(Overdrive) Total_cyber_bp *= 1.5
		if(Ki>max_ki) Total_cyber_bp *= (Ki/max_ki) ** 0.5
		Total_cyber_bp /= sf_count+1
		bp += Total_cyber_bp

		if(BPpcnt < 10) hiding_energy=1
		else hiding_energy=0

		bp/=time_freeze_divider
		if(z == 6)
			switch(Race)
				if("Demon") bp *= Mechanics.GetSettingValue("Demon Hell BP Multiplier")
				if("Kai") bp /= Mechanics.GetSettingValue("Demon Hell BP Multiplier")
				else if(!(locate(/obj/items/Holy_Pendant) in src)) bp *= 0.85
		if(z == 7 || z == 13)
			switch(Race)
				if("Kai") bp *= Mechanics.GetSettingValue("Kai Heaven BP Multiplier")
				if("Demon") bp /= Mechanics.GetSettingValue("Kai Heaven BP Multiplier")
		bp *= Dead_power()
		bp *= feat_bp_multiplier
		bp *= BioBPMult()
		if(goo_trap_obj && goo_trap_obj.z) bp *= goo_trap_bp_mult

		if(world.time - last_ki_hit_zero < zero_ki_bp_debuff_duration * 10)
			bp *= zero_ki_bp_mult

		if(IsGreatApe())
			var/obj/Great_Ape/O=Great_Ape_obj
			bp *= oozaruBPMult * O.powerMult
			if(O.golden)
				bp += 100000000
				bp *= 1.5

		bp *= bp_mod * bp_mult * Body

		bp *= HasTrait("Purity of Form") ? 1.6 : 1

		bp += transBPAdd
		bp *= transBPMult

		if(HasTrait("Fulfilled Potential") && GetUnlockedFormCount() > 0)
			if(HasActiveForm())
				bp *= 1 - (GetTraitRank("Fulfilled Potential") * 0.1)
			else
				bp *= 1 + (GetTraitRank("Fulfilled Potential") * 0.3)

		bp /= weights()

		return Math.Max(bp, 1)

mob/var/tmp/lastSave = 0
mob/var/tmp/barWidth = 16

mob/proc/PrimaryPlayerLoop(start_delay)
	set waitfor = FALSE
	set background = TRUE
	if(Status_Running || !client) return
	Status_Running = 1

	if(Regenerating && z != 15) Regenerating = 0
	if(resetBP > 0) ResetBPToAmount()

	PopulateScienceTabs()
	client.PopulateBuildTabs()
	GenerateInitialAppearances()
	SetPlayerRace(src)

	auto_regen_mobs+=src
	auto_recov_mobs+=src

	spawn(5) update_area()

	DetermineViewSize(Limits.GetSettingValue("Player View Size"))
	GenerateHUD()
	var/icon/I = icon(healthBar.maskedBar.icon)
	barWidth = I.Width()
	SetupCallbacks()

	if(start_delay) sleep(start_delay)
	while(src && client)
		if(last_move + 2.5 < world.time)
			flight_buildup = 0
			FlyBoost(1)
		if(world.time > lastSave + 100)
			Save()
			lastSave = world.time
		if(HasSkill(/obj/Skills/Special/Scrap_Absorb))
			Scrap_Absorb_Revert()
		if(!Flying && istype(loc, /turf/liquid))
			loc:MobSwimming(src)
		if(client?.buildMode && client?.buildCam)
			if(!client.buildCam.loc) client.buildCam.loc = src.loc
		if(!KO)
			RecoverDetermination()
			var/obj/Skills/Buff/B = buffed()
			if(B && B.buff_bp > 1)
				BuffDrain(B)
			if("transformation" in active_buff_attributes)
				BuffTransformDrain()
			if(God_Fist_level)
				GodFistDrain()
			if(src in powerup_mobs)
				PowerupDrain()
			TrainGain()
			if(fly_obj && Flying && !(Cyber_Fly || Class == "Spirit Doll"))
				is_swimming = 0
				FlyDrain()
				if(flight_boosted)
					if(stamina > BoostedFlightDrain())
						IncreaseStamina(-BoostedFlightDrain())
					else FlyBoost(1)
			if(!God_Fist_level && !IsGreatApe() && powerup_obj)
				PowerControlTick(powerup_obj)
			if(Overdrive)
				OverdriveDrain()
			if(IsShielding())
				KiShieldKO()
			if(Digging)
				Digging(0.5)
			if(trainState == "Self")
				var/drain = (2 + (max_ki ** 0.01))
				if(drain > Ki)
					StopTraining()
				else
					IncreaseKi(-drain)
			if(Get_attack_gains())
				AttackGainTick()
			if(Regeneration_Skill && Health < 100)
				RegenerateSkillTick()
			if(!grabbedObject)
				GrabPowerTick()
			if(Nanite_Repair && Health < 50 && (current_area && !istype(current_area,/area/Braal_Core)))
				NaniteRepairTick()
			if(IsGreatApe() && !Great_Ape_control)
				GreatApeBerserkTick()
			if(power_given && !Giving_Power)
				GivePowerRefill()
		else
			Overdrive_Revert()
			God_Fist_Revert()
			Stop_Powering_Up()
			Land()
			Buff_Disable(buffed())
			Shield_Revert()
			StopTraining()
			Digging = 0
			Regeneration_Skill = 0
			KnockoutWakeTick()
		if(Is_Cybernetic())
			Regeneration_Skill = 0
		if(precog && !precogs)
			RegeneratePrecogs()
		if(src in auto_regen_mobs)
			RecoverHealth()
		if(src in auto_recov_mobs)
			RecoverEnergy()
		if(CanRechargeStamina() && (stamina < max_stamina))
			RecoverStamina()
		if(radar_obj && radar_obj.Detects && client.statpanel == "Radar" && current_area)
			UpdateRadar()
		TickGravity()
		if(world.time-last_attacked_time > 400) power_attack_meter=0
		if(client && client.inactivity < 600)
			GetBP()
		ResourceDrainOverCap()
		Cache_equipped_weights()
		if(Dead && !Is_In_Afterlife(src))
			SpiritLivingRealmDrain()
		if(InFinalRealm())
			FinalRealm()
		if(Poisoned)
			PoisonTick()
		if(regenerator_obj)
			RegeneratorTick(regenerator_obj)
		if(Race == "Onion Lad")
			PowerStarTick()
		UpdateSIList()
		if(Vampire)
			if(trainState != "Med")
				VampireInfectionTick()
			VampirePowerTick()
		if(Puranto_counterpart)
			CounterpartMatchTick()
		if(spam_killed)
			spam_killed--
			spam_killed = Math.Max(spam_killed, 0)
		if(senzu_timer)
			senzu_timer--
			senzu_timer = Math.Max(senzu_timer, 0)
		if(senzu_overload)
			senzu_overload--
			senzu_overload = Math.Max(senzu_overload, 0)
		RadiationTick()
		StunTickDown()
		if(kikoho_damage)
			KikohoDamageTick()
		CheckAFK()
		if(IsInHBTC())
			TimeChamberTick()
		else
			TimeChamberCooldown()
		if(current_area && current_area.type == /area/Space)
			SpaceDamageTick()

		sleep(5)

mob/proc/Intelligence()
	if(adminInfKnowledge) return 1.#INF
	return Intelligence

mob/var/alwaysRegenStamina = 0

mob/var
	tmp
		core_feat_time = 0
		stamina_recharge_loop
		last_stamina_drain = -9999

mob/proc/HasMaxHealth()
	return Health >= 100

mob/proc/HasMaxEnergy()
	return Ki >= max_ki

mob/proc/HasMaxStamina()
	return stamina >= max_stamina

mob/proc/HasMaxResources()
	return HasMaxHealth() && HasMaxEnergy() && HasMaxStamina()

mob/proc

	//var/list/L=list("Half Yasai","Legendary","Alien","Android","Bio-Android",
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
			if("Demigod")
				if(HasTrait("Lasso the Sun")) return 75
		if(Class == "Legendary") return 50
		return 0
	
	RecoverStamina()
		var/stam_gain = max_stamina / 9
		stam_gain *= Clamp(1 + (regen**0.7 * 0.2), 1, 2)
		if(ultra_instinct) stam_gain *= 2
		stam_gain *= transStaminaRegen
		IncreaseStamina(stam_gain)

	StaminaRechargeLoop()
		set waitfor=0
		set background = TRUE
		if(stamina_recharge_loop) return
		stamina_recharge_loop = 1

		while(src)
			if(CanRechargeStamina() && (stamina < max_stamina))
				var/stam_gain = max_stamina / 9
				stam_gain *= Clamp(1 + (regen**0.7 * 0.2), 1, 2)
				if(ultra_instinct) stam_gain *= 2
				stam_gain *= transStaminaRegen
				IncreaseStamina(stam_gain)
			
			sleep(5)

		stamina_recharge_loop = 0

	CanRechargeStamina()
		var/times = (last_stamina_drain + 50 > world.time) || (last_input_move + 50 > world.time)
		return !disableStamRecovery && (alwaysRegenStamina || times) && (!flight_boosted && !is_swimming && !ultra_instinct && !Regeneration_Skill)

	IncreaseStamina(n = 1)
		if(client?.buildMode && n < 0) return
		DecideMaxStamina()

		if(n < 0) last_stamina_drain = world.time
		stamina += n
		if(ultra_instinct && stamina <= 0) UltraInstinctRevert()
		stamina = Math.Clamp(stamina, 0, max_stamina)
		if(client)
			if(lastResourceUpdate < world.time)
				resourceCallback.Call()
			lastResourceUpdate = world.time

	DecideMaxStamina()
		var/new_max_stamina = 50 + 10 * ((GetStatMod("Str") + GetStatMod("Dur") + GetStatMod("Res") + GetStatMod("Spd")) / 4) + RaceStamBonus()
		stamina *= new_max_stamina / Math.Max(max_stamina, 1)
		max_stamina = new_max_stamina
		return Math.Max(max_stamina, 30)

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
					if(coreGainsTimer > 0)
						var/core_gains = CoreGainsMult() * timer
						Attack_Gain(ToOne(core_gains))
						coreGainsTimer -= 10 * timer
					else
						if(timeOutPrompt)
							src << "You feel as if there's nothing else to gain from being here."
							timeOutPrompt = 0
						sleep(10 * timer)
						continue
				sleep(10 * timer)
			else
				if(coreGainsTimer <= 0)
					spawn CoreGainsTimerRefill()
				return
			sleep(2)

	CoreGainsTimerRefill()
		if(coreTimerRefilling) return
		coreTimerRefilling = 1
		sleep(Mechanics.GetSettingValue("Core Gains Time Limit") * 5)
		coreGainsTimer = Mechanics.GetSettingValue("Core Gains Time Limit")
		timeOutPrompt = 1
		src << "You could probably make use of the Core once more."

	Braals_core_enemy_spawner()
		set waitfor=0
		return
		/* while(src)
			var/area/a=get_area()
			if(Mechanics.GetSettingValue("Core Demon Spawn Rate") && istype(a,/area/Braal_Core))

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
				sleep((230 * Clamp(players_near,1,players_near)) / Mechanics.GetSettingValue("Core Demon Spawn Rate"))
			else return
			sleep(2) */

	Braals_core_explosions()
		set waitfor=0
		return
		/* while(src)
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
							m2.TakeDamage(dmg, "random explosion!", 1, 1)
						Explosion_Graphics(t,5)
				sleep(rand(0,60)*players_near)
			else return
			sleep(2) */

	Braals_core_camera_shake()
		set waitfor=0
		while(src)
			var/area/a=get_area()
			if(istype(a,/area/Braal_Core))
				ScreenShake(10,8)
				sleep(rand(10,70))
			else return
			sleep(2)

	Braals_core_gas()
		set waitfor=0
		while(src)
			var/area/a=get_area()
			if(!istype(a,/area/Braal_Core)) return
			else
				if(a.icon_state=="Smog")
					var/dmg=2.4 // /dur_share()**0.3
					var/lungs=Lungs
					if(lungs) dmg/=2
					TakeDamage(-dmg, "poison acid smog", 1, 1)
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

mob/proc/update_area_loop()
	set waitfor=0
	while(src)
		update_area()
		sleep(50)
		if(!client) sleep(200) //slowed down on empty clones due to lag

mob/var/tmp/knock_timer=0
mob/proc/Refill_grab_power_loop()
	set waitfor=0
	while(src)
		if(!grabbedObject)
			grab_power+=10
			if(grab_power>100) grab_power=100
		sleep(100)

mob/proc/GrabPowerTick()
	grab_power += 0.5
	grab_power = Math.Min(grab_power, 100)

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
			else IncreaseKi(-drain)
			sleep(20)
		else break
	buff_transform_loop=0

mob/proc/BuffTransformDrain()
	var/drain=1*(max_ki/100/(Eff**0.35))
	drain*=sqrt(buff_transform_bp/base_bp)
	if(Ki<drain) Buff_Disable(buffed())
	else IncreaseKi(-drain)

mob/var
	Knowledge=1
	knowledge_cap_rate=1

mob/var/tmp/knowledge_gain_loop

mob/proc/Knowledge_gain_loop()
	set waitfor=0
	if(knowledge_gain_loop) return
	knowledge_gain_loop=1
	while(src)
		if(Action == "Meditating" && Knowledge < Tech_BP)
			while(!client) sleep(300)
			var/knowledge_gain=(1-Knowledge/Tech_BP)**2
			knowledge_gain=Clamp(knowledge_gain,0,0.2)
			knowledge_gain*=Tech_BP/200*knowledge_cap_rate 
			Knowledge+=knowledge_gain*2.3
			Knowledge = Math.Min(Knowledge, Tech_BP * (HasTrait("Pacifist Tendencies") ? 2 : 1))

			if(Knowledge >= Tech_BP * very_high_knowledge_min) GiveFeat("Get Very High Knowledge")

			sleep(10)
		else break

		if(Knowledge>Tech_BP * (HasTrait("Pacifist Tendencies") ? 2 : 1)) Knowledge=Tech_BP * (HasTrait("Pacifist Tendencies") ? 2 : 1)
	knowledge_gain_loop=0

mob/proc/GetMaxKnowledge()
	return Tech_BP * (HasTrait("Pacifist Tendencies") ? 2 : 1)

mob/proc/KnowledgeTick()
	var/knowledge_gain = (1-Knowledge/Tech_BP) ** 2
	knowledge_gain = Clamp(knowledge_gain, 0, 0.2)
	knowledge_gain *= Tech_BP / 200 * knowledge_cap_rate 
	Knowledge += knowledge_gain * 2.3 * 0.5
	Knowledge = Math.Min(Knowledge, Tech_BP * (HasTrait("Pacifist Tendencies") ? 2 : 1))

	if(Knowledge >= Tech_BP * very_high_knowledge_min) GiveFeat("Get Very High Knowledge")

mob/var/list/SI_List=new

mob/proc/SI_List(N=6000)
	set waitfor=0
	sleep(N+1)
	while(src)
		for(var/mob/P in player_view(15,src)) if(P.client&&!(P.Mob_ID in SI_List)) SI_List+=P.Mob_ID
		sleep(N+1)

mob/proc/UpdateSIList()
	for(var/mob/P in player_view(30, src))
		if(P.client && !(P.Mob_ID in SI_List))
			if(prob(1)) SI_List += P.Mob_ID

mob/var/tmp/obj/regenerator_obj

var/regenerator_damage_mod = 3 //you take this many times more damage from things if you are in a regenerator

mob/proc/RegeneratorTick(obj/items/Regenerator/r)
	if(!r) r = regenerator_obj
	if(!r) r = locate(/obj/items/Regenerator) in loc
	if(!r) return
	if(Android || Giving_Power || BPpcnt > 100 || Using_Focus || attacking || Digging || Overdrive || counterpart_died) return
	if(buffed_with_bp() || buff_transform_bp || God_Fist_level || Flying || Action == "Training") return
	if(istype(get_area(), /area/Braal_Core))
		player_view(15,src) << "The [r] is destroyed by the acid smog in this place"
		del(r)
		return
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
		IncreaseHealth(2 * RegenMod() * N)
	if(KO&&Health>=100) RegainConsciousness()
	if(Ki<max_ki&&r.Recovers_Energy)
		IncreaseKi((max_ki / 50) * recov * N)
	if(prob(5*N)&&r.Heals_Injuries)
		if(CheckForInjuries())
			for(var/injury/I in injuries)
				I.remove_at -= 0.05 * RegenMod()
				TryRemoveInjury(I)
	RegenGrabDrop()

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
				UpdateGravity()
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
					IncreaseHealth(4 * RegenMod() * N)
				if(KO&&Health>=100) RegainConsciousness()
				if(Ki<max_ki&&r.Recovers_Energy)
					IncreaseKi(2 * (max_ki / 50) * recov * N)
				if(prob(5*N)&&r.Heals_Injuries)
					if(CheckForInjuries())
						for(var/injury/I in injuries)
							I.remove_at -= 0.05 * RegenMod()
							TryRemoveInjury(I)
				if(Gravity>25*N)
					for(var/mob/M in player_view(15,src))
						M.SendMsg("The [r] is destroyed by gravity! The maximum it can handle is [25*N]x", CHAT_IC)
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

mob/var/tmp/Puranto_regen_looping

mob/proc/RegenerateSkillTick()
	if(current_area && !istype(current_area,/area/Braal_Core))
		var/Percent=7 * Clamp(RegenMod(), 0.5, 10)

		if(Overdrive||God_Fist_level) Percent/=2

		var/Drain = Percent * (max_stamina * 0.05)

		var/to100 = 100 - Health
		if(to100 < Percent)
			var/n = to100 / Percent
			Percent *= n * 0.5
			Drain *= n * 0.5

		if(stamina>=Drain)
			IncreaseStamina(-Drain)
			IncreaseHealth(Percent)

mob/proc/Puranto_regen_loop()
	set waitfor=0
	if(Puranto_regen_looping) return
	Puranto_regen_looping=1
	while(Regeneration_Skill && !KO && Health < 100)
		if(current_area && !istype(current_area,/area/Braal_Core))
			if(Is_Cybernetic())
				Regeneration_Skill=0
				break
			var/Percent=7 * Clamp(RegenMod(), 0.5, 10)

			if(Overdrive||God_Fist_level) Percent/=2

			var/Drain = Percent * (max_stamina * 0.05)

			var/to100 = 100 - Health
			if(to100 < Percent)
				var/n = to100 / Percent
				Percent *= n
				Drain *= n

			if(stamina>=Drain)
				IncreaseStamina(-Drain)
				IncreaseHealth(Percent)
		sleep(10)
	Puranto_regen_looping=0

mob/var/tmp/nanite_repair_looping

mob/proc/NaniteRepairTick()
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
		IncreaseHealth(Percent)
		if(Health>100) Health=100
		IncreaseKi(-Drain)

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
				IncreaseHealth(Percent)
				if(Health>100) Health=100
				IncreaseKi(-Drain)
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

mob/var/Using_Focus

mob/proc/Has_Active_Freezes() for(var/obj/Time_Freeze_Energy/T in Active_Freezes) return 1

mob/var
	tmp
		next_energy_increase=0
		last_ki_hit_zero = -9999
	

mob/proc/RecoverEnergyLoop()
	set waitfor = FALSE
	set background = TRUE
	while(src)
		if(src in auto_recov_mobs)
			var/can_recover_ki = src.Can_recover_ki(ki_limit = src.max_ki)
			if(can_recover_ki)
				if(src.Ki <= 1)
					src.last_ki_hit_zero = world.time
				
				var/n=0.2
				if(src.Dead) n *= 1.2
				if(src.Action == "Meditating" && world.time - src.last_shield_use >= 200) n *= 5
				if(src.z == 10) n *= 2
				if(src.IsShielding()) n *= 0.15

				n *= 0.5 * (src.max_ki / 100) * src.recov ** 1.1 * src.Recov_Mult / src.Gravity_Health_Ratio()

				if(CheckForInjuries() && GetInjuryTypeCount(/injury/internal_bleeding))
					n *= 0.85

				src.IncreaseKi(n * (transRecovRate + GetWeaponRecov()))
		sleep(5)

mob/proc/RecoverEnergy()
	var/can_recover_ki = src.Can_recover_ki(ki_limit = src.max_ki)
	if(can_recover_ki)
		if(src.Ki <= 1)
			src.last_ki_hit_zero = world.time
		
		var/n=0.2
		if(src.Dead) n *= 1.2
		if(src.Action == "Meditating" && world.time - src.last_shield_use >= 200) n *= 5
		if(src.z == 10) n *= 2
		if(src.IsShielding()) n *= 0.15

		n *= 0.5 * (src.max_ki / 100) * src.recov ** 1.1 * src.Recov_Mult / src.Gravity_Health_Ratio()

		if(CheckForInjuries() && GetInjuryTypeCount(/injury/internal_bleeding))
			n *= 0.85

		src.IncreaseKi(n * (transRecovRate + GetWeaponRecov()))

mob/var/disableKiRecovery = 0
mob/var/disableHPRecovery = 0
mob/var/disableStamRecovery = 0

mob/proc
	Can_recover_health(health_limit=100)
		if(radiation_poisoned||KO||Health>=health_limit||Overdrive||Giving_Power||!(!Dead||(Dead&&Is_In_Afterlife(src)))||God_Fist_level||\
		Gravity>gravity_mastered||regen<=0 || regenerator_obj) return
		if(bleedStacks.len > 0 || SplitformCount()) return
		return !disableHPRecovery

	Can_recover_ki(ki_limit=1.#INF)

		if(Race=="Onion Lad" && Onion_Lad_Star && Ki<ki_limit && BPpcnt<=100 && !KO && !Regen_Active() && !Overdrive && \
		!Giving_Power && !buffed_with_bp() && !buff_transform_bp && !God_Fist_level) return 1

		if(strangling||Ki>=ki_limit||BPpcnt>100||attacking||KO||(Flying&&Class!="Spirit Doll")||Action=="Training"||Digging||Regen_Active()||\
		Overdrive||Using_Focus||Giving_Power || !(!Dead || (Dead&&(Is_In_Afterlife(src)||istype(current_area,/area/Prison)))) || counterpart_died||\
		Has_Active_Freezes()||buffed_with_bp()||buff_transform_bp||God_Fist_level||recov<=0 || Peebagging() || SplitformCount()) return
		return !disableKiRecovery

mob/var/tmp/logout_timer_loop

mob/proc/Logout_timer_countdown()
	set waitfor=0
	sleep(10)
	if(logout_timer_loop) return
	logout_timer_loop=1
	while(src)
		logout_timer-=10
		if(InFinalRealm()) logout_timer=60
		if(logout_timer<=0)
			logout_timer=0
			//src<<"<font color=cyan>It has been 30 seconds since you were last attacked. You can now log out without your body staying behind."
			break
		else sleep(10)
	logout_timer_loop=0

var/list
	auto_regen_mobs = new
	auto_recov_mobs = new

mob/proc/RecoverHealthLoop()
	set waitfor = FALSE
	set background = TRUE
	while(src)
		if(src in auto_regen_mobs)
			var/can_recover_health = src.Can_recover_health(health_limit = 100)
			if(src.Health <= 0 && !src.KO) src.KnockOut("low health")

			if(src && !src.logout_timer && world.time < src.last_attacked_by_player + 200)
				src.Logout_timer_countdown()
				src.logout_timer = 30
			
			if(can_recover_health)
				var/n=1
				if(src.is_teamer) n *= 0.6
				if(src.current_area && src.current_area.type==/area/Braal_Core) n /= 100
				if(src.Action != "Meditating") n /= 3
				if(src.Dead) n *= 1.2
				if(src.z == 10) n *= 2 //hbtc
				n *= 1 * src.RegenMod()
				n *= 2 * src.Regen_Mult / src.Gravity_Health_Ratio()
				n *= 0.25 // arbitrary
				n *= 1 + (GetTraitRank("Fervent Regeneration") * 0.05)

				if(CheckForInjuries() && GetInjuryTypeCount(/injury/internal_bleeding))
					n *= 0.85

				src.IncreaseHealth(n * (transRegenRate + GetWeaponRegen()))
				if(src.Health > 100) src.Health = 100

		sleep(5)

mob/proc/RecoverHealth()
	var/can_recover_health = src.Can_recover_health(health_limit = 100)
	if(src.Health <= 0 && !src.KO) src.KnockOut("low health")

	if(src && !src.logout_timer && world.time < src.last_attacked_by_player + 200)
		src.Logout_timer_countdown()
		src.logout_timer = 30
	
	if(can_recover_health)
		var/n=1
		if(src.is_teamer) n *= 0.6
		if(src.current_area && src.current_area.type==/area/Braal_Core) n /= 100
		if(src.Action != "Meditating") n /= 3
		if(src.Dead) n *= 1.2
		if(src.z == 10) n *= 2 //hbtc
		n *= 1 * src.RegenMod()
		n *= 2 * src.Regen_Mult / src.Gravity_Health_Ratio()
		n *= 0.25 // arbitrary
		n *= 1 + (GetTraitRank("Fervent Regeneration") * 0.05)

		if(CheckForInjuries() && GetInjuryTypeCount(/injury/internal_bleeding))
			n *= 0.85

		src.IncreaseHealth(n * (transRegenRate + GetWeaponRegen()))
		if(src.Health > 100) src.Health = 100

mob/var/Overdrive

mob/proc/PowerStarTick()
	if(current_area && current_area.powerComet)
		if(!HasTrait("Who Needs a Stupid Comet Anyway?") && (!IsShielding()))
			var/mode_mod=3
			if(Can_recover_health(health_limit=100)) IncreaseHealth(1.3 * RegenMod() * mode_mod)
			if(Can_recover_ki(ki_limit=max_ki * 2)) IncreaseKi((max_ki / 40) * recov**0.5 * mode_mod)
		else if(HasTrait("Who Needs a Stupid Comet Anyway?"))
			Ki = Math.Min(Ki, max_ki * 0.6)
	else if (HasTrait("Who Needs a Stupid Comet Anyway?"))
		if(!IsShielding())
			if(Can_recover_health(health_limit=100)) IncreaseHealth(1.3 * RegenMod() * 1.5)
			if(Can_recover_ki(ki_limit=max_ki * 1.3)) IncreaseKi((max_ki / 40) * recov**0.5 * 1.5)

mob/proc/Onion_Lad_Star()
	set waitfor=0
	var/obj/Skills/Combat/Ki/Shield/shield
	while(src&&Race=="Onion Lad")
		if(current_area && current_area.powerComet)
			if(!shield) if(shield_obj&&shield_obj.Using) shield=shield_obj
			if(!HasTrait("Who Needs a Stupid Comet Anyway?") && (!shield||!shield.Using))
				var/mode_mod=3
				if(Can_recover_health(health_limit=100)) IncreaseHealth(1.3 * RegenMod() * mode_mod)
				if(Can_recover_ki(ki_limit=max_ki * 2)) IncreaseKi((max_ki / 40) * recov**0.5 * mode_mod)
			else if(HasTrait("Who Needs a Stupid Comet Anyway?"))
				Ki = Math.Min(Ki, max_ki * 0.6)
			sleep(10)
		else if (HasTrait("Who Needs a Stupid Comet Anyway?"))
			if(!shield) if(shield_obj&&shield_obj.Using) shield=shield_obj
			if(!shield||!shield.Using)
				if(Can_recover_health(health_limit=100)) IncreaseHealth(1.3 * RegenMod() * 1.5)
				if(Can_recover_ki(ki_limit=max_ki * 1.3)) IncreaseKi((max_ki / 40) * recov**0.5 * 1.5)
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

var/lastImmortalityZoneCheck = 0
proc/ImmortalityZoneCheck()
	set waitfor = 0
	if(lastImmortalityZoneCheck + 600 > world.time) return
	lastImmortalityZoneCheck = world.time

	var/area/kaio_area=locate(/area/Kaioshin) in all_areas
	for(var/mob/m in kaio_area.player_list)
		if(m.Race=="Kai")
			if(m.Age>m.Decline+50) m.Age=m.Decline+50
			if(m.Age>m.Decline) m.Age-=0.2

	var/area/hell_area=locate(/area/Hell) in all_areas
	for(var/mob/m in hell_area.player_list)
		if(m.Demonic)
			if(m.Age>m.Decline+50) m.Age=m.Decline+50
			if(m.Age>m.Decline) m.Age-=0.133

mob/proc/scrap_repair()
	for(var/obj/Module/Scrap_Repair/S in active_modules)
		if(S.suffix)
			return 1

mob/proc/death_regen(set_loc=1)
	if(set_loc) death_regen_loc=list(x,y,z)
	SafeTeleport(locate(250,250,15))
	var/time=round(60/Regenerate**0.5)
	src.SendMsg("You will regenerate in [round(time)] seconds.", CHAT_IC)
	for(var/v in 1 to time)
		if(!InFinalRealm()) break
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
		for(var/mob/M in player_view(15,src))
			M.SendMsg("[src] regenerates back to life!", CHAT_IC)
		if(BPpcnt>100) BPpcnt=100
		if(!scrap_repair())
			if(!logout_timer) Logout_timer_countdown()
			logout_timer=60
			var/old_icon=icon
			var/list/old_overlays=new
			old_overlays.Add(overlays)
			icon='Death regenerate.dmi'
			overlays.Remove(overlays)
			KnockOut(can_anger=0)
			sleep(TickMult(140/Regenerate**0.5))
			if(Regenerate >= 0.4) FullHeal()
			else
				Health = 1
				Ki = 1
			icon=old_icon
			overlays.Add(old_overlays)
		Regenerating=0
		if(prob(20)) TryUnlockForm("Super Perfect")
	else
		src.SendMsg("Your scraps were destroyed, you cannot regenerate back to life.", CHAT_IC)
		Death("not having any scraps to regenerate from",1)

var/turf/bind_spawn = locate(410,290,6)

var/lastBindCheck = 0
proc/BindCheck()
	if(lastBindCheck + 50 > world.time) return
	lastBindCheck = world.time

	for(var/obj/Curse/c in bind_objects)
		if(ismob(c.loc))
			var/mob/m = c.loc
			if(m.z != 6 && !m.Teleport_nulled() && !m.Prisoner() && !m.InFinalRealm())
				if(!m.IsTournamentFighter())
					var/mob/m2 = m.loc
					if(m2 && ismob(m2))
						//ignore bind
					else
						m << "The bind on you takes effect and you are returned to hell"
						m.GoToBindSpawn()

mob/var/fly_mastery = 0

mob/proc
	Fly_Drain()
		if(IsFusion()) return 5

		var/n = 8 + (max_ki * 3 / (fly_mastery + 1) / Eff)
		return Math.Min(n, max_ki)

	MasterFly(amount = 1)
		var/n = 3 * amount

		if(Total_HBTC_Time < 2 && z == 10) n *= 5
		n *= decline_gains()
		if(Dead) n *= 1.5

		fly_mastery += n
	
	BoostedFlightDrain()
		. = 0
		if(flight_boosted)
			. = max_stamina * 0.015
			. /= Math.Clamp((GetStatMod("Dur") + GetStatMod("Res") + GetStatMod("Str")) / 3, 0.1, 3)

mob/var/tmp
	fly_loop
	obj/Skills/Utility/Fly/fly_obj

mob/proc/Fly_loop()
	set waitfor=0
	if(fly_loop) return
	fly_loop=1
	while(src && client && fly_obj && Flying && !Cyber_Fly)
		if(Ki>=Fly_Drain()&&!KO)
			if(Class!="Spirit Doll") IncreaseKi(-Fly_Drain() * 2)
			MasterFly(2)
			sleep(20)
		else
			src.SendMsg("You stop flying due to lack of energy.", CHAT_IC)
			Ki=0
			Land()
			break
	fly_loop=0

mob/proc/FlyDrain()
	var/drain = Fly_Drain() * 0.25
	if(!KO && Ki >= drain)
		IncreaseKi(-drain * 2)
		MasterFly(2)
	else
		src.SendMsg("You stop flying due to lack of energy.", CHAT_IC)
		Ki = 0
		Land()

mob/var/tmp/overdrive_loop

mob/proc/Overdrive_Loop()
	set waitfor=0
	if(overdrive_loop) return
	overdrive_loop=1
	while(Overdrive)
		TakeDamage(1.5, "overdrive")
		if(KO||Ki<max_ki*0.1) Overdrive_Revert()
		sleep(20)
	overdrive_loop=0

mob/proc/OverdriveDrain()
	TakeDamage(1.5 * 0.25, "overdrive")
	if(Ki < max_ki * 0.1) Overdrive_Revert()

mob/var/tmp/beamChargeLoop

mob/proc/Beam_Charge_Loop(obj/Skills/Combat/Ki/A)
	set waitfor = 0
	if(beamChargeLoop) return
	beamChargeLoop = 1
	var/Amount = 1.8
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
	n *= 2 * Buffless_recovery()**recovery_powerup_exponent
	if(BPpcnt>max_powerup_acheived)
		max_powerup_acheived=BPpcnt
	if(BPpcnt<100) n=Clamp(BPpcnt/4,1,10)
	else
		n *= energy_mod_powerup_soft_cap()
		n /= bp_mult**2
	return n

mob/proc/powerup_soft_cap()
	var/ki_mod = BufflessKiMod()
	if(has_modules) for(var/obj/Module/m in active_modules) if(m.Kix>1) ki_mod/=m.Kix
	var/max_powerup = 27 * (ki_mod ** energy_mod_powerup_exponent) //+100
	
	max_powerup *= transPUCap

	if(beaming || charging_beam) max_powerup *= 1.45
	return max_powerup

mob/var/transPUCap = 1

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
	var/kb_dist = 5 + ((GetStatMod("For") * (1 + recov / 2)) * GetTierBonus(0.25)) - (m.GetStatMod("Dur") + m.GetStatMod("Res")) * GetTierBonus(0.5)
	kb_dist = Math.Floor(Math.Clamp(kb_dist, 0, 9))
	kb_dist=ToOne(kb_dist)
	if(kb_dist)
		var/turf/t=m.loc
		if(t&&isturf(t)) TimedOverlay(t, 30, 'Sparks LSSj.dmi')
		player_view(center=src)<<sound('scouterexplode.ogg',volume=20)
		Explosion_Graphics(m,1)
		m.Knockback(src, kb_dist, dirt_trail = 0, bypass_immunity = 1)

mob/var/tmp/standing_powerup

mob/proc/PowerupScreenShakeLoop(obj/Skills/Utility/Power_Control/pc)
	set waitfor=0
	while(pc && pc.Powerup == 1)
		if(standing_powerup)
			var/offset = 1
			for(var/mob/m2 in player_view(15,src)) if(m2.client) m2.ScreenShake(Amount = 10, Offset = offset)
		sleep(5)

mob/proc/PowerUpKnockAwayLoop(obj/Skills/Utility/Power_Control/A)
	set waitfor=0
	while(A && A.Powerup == 1 && A.PC_Loop_Active)
		var/delay = world.tick_lag
		if(BPpcnt > 100)
			standing_powerup = 0
			if(!Auto_Attack && world.time - last_attacked_mob_time > 35 && !Giving_Power)
				if(!charging_beam && !beaming && !attacking)
					standing_powerup = 1
					PowerupDamageGrabber(delay / 1)
					//this line makes it so you cant just stand there aura knocking someone forever
					if((BPpcnt < 100 + powerup_soft_cap() * 2) && world.time - last_move > 100)
						for(var/mob/m in View(2, src))
							if(isturf(m.loc) && !m.KO && !m.grabber && m != src && (!m.standing_powerup || getdist(src,m) <= 2))
								PowerupKnockbackEffect(m)
		if(round(world.time) % 5 == 0)
			if(IsTournamentFighter() && !IsRoundFighter())
				Stop_Powering_Up()
		if(regenerator_obj) Stop_Powering_Up()
		sleep(delay)
	standing_powerup = 0

mob/proc/PowerControlStart(obj/Skills/Utility/Power_Control/A)
	if(!A) A = locate(/obj/Skills/Utility/Power_Control) in src
	if(!A) return
	PowerupRisingRocks(A)
	PowerUpKnockAwayLoop(A)
	powerup_mobs += src
	Aura_Overlays()

mob/proc/PowerControlTick(obj/Skills/Utility/Power_Control/A)
	if(!A) A = locate(/obj/Skills/Utility/Power_Control) in src
	if(!A) return
	if(A.Powerup > 0)
		var/stopAtFull = BPpcnt < 100
		if(Action != "Meditating" || BPpcnt < 100)
			var/pu_mod = 0.85
			if(!standing_powerup) pu_mod = 0.3
			if(!charging_beam) //if we are charging a beam then the bppcnt increase is handled elsewhere
				BPpcnt += powerup_speed(pu_mod * 1.3)
			if(BPpcnt>100)
				A.Skill_Increase(3,src)
			if(BPpcnt>=100 && stopAtFull)
				src.SendMsg("You reach 100% power and stop powering up.", CHAT_IC)
				Stop_Powering_Up()
	else if(A.Powerup < 0)
		BPpcnt *= 0.9

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

mob/var/tmp/obj/Skills/Utility/Power_Control/powerup_obj

var/list/powerup_mobs = new

mob/proc/PowerupDrain()
	var/drain = src.Charge_Drain() * 10
	// loops 4 times more often
	drain *= 0.25
	if(!src.KO && src.BPpcnt > 100 && src.Ki >= drain)
		src.IncreaseKi(-drain)
	else
		if(src.BPpcnt > 100)
			src.SendMsg("You are too tired to power up any more.", CHAT_IC)
		for(var/obj/Skills/Combat/Ki/a in src.ki_attacks) if(a.Wave && a.charging) src.BeamStream(a)
		if(src.BPpcnt > 100) src.Stop_Powering_Up()

mob/proc
	frc_share()
		return Pow / getStatTotal() * 7
	dur_share()
		return End / getStatTotal() * 7
	res_share()
		return Res / getStatTotal() * 7
	spd_share()
		return Spd / getStatTotal() * 7
	str_share()
		return Str / getStatTotal() * 7
	def_share()
		return Def / getStatTotal() * 7

mob/var/tmp/Status_Running

mob/proc/FinalRealm()
	BPpcnt = Math.Min(BPpcnt, 100)
	if(!Regenerating && !KO)
		Respawn()
	FullHeal()

mob/proc/KiShieldKO()
	if(Ki <= max_ki * 0.05)
		Shield_Revert()
		var/mob/ko_reason = Opponent(65)
		if(!ko_reason || !ismob(ko_reason)) ko_reason="shield"
		KnockOut(ko_reason)

mob/proc/PoisonTick()
	TakeDamage(-15 * Poisoned / Poison_resist(), "poison", 1, 1)
	Poisoned-=0.1
	if(Poisoned<0) Poisoned=0

mob/proc/Apply_poison(n=1)
	Poisoned+=n

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

mob/proc/ResourceDrainOverCap()
	if(Ki > max_ki)
		IncreaseKi(-(Ki/100))
		Ki = Math.Max(Ki, max_ki)
	if(Health > 100)
		IncreaseHealth(-1)
		Health = Math.Max(Health, 100)

mob/var
	bp_loss_from_low_ki = 0.5
	bp_loss_from_low_hp = 0.5

mob/proc/hp_ki_bp_loss_mult()
	var/mult, hp = Health / 100, ki = Ki / max_ki
	mult = bp_loss_from_low_hp * (hp - 1) + bp_loss_from_low_ki * (ki - 1) + 1
	mult = Math.Clamp(mult, 0.2, 1)
	return mult

mob/proc/SplitformCount()
	if(!splitform_list) splitform_list=new/list //runtime error "bad list" for some reason
	return splitform_list.len

mob/var/sent_to_afterlife = 0

mob/proc/SpiritLivingRealmDrain()
	var/drain = (max_ki / (60 * 5))
	if(Ki < drain)
		IncreaseKi(-Ki)
		src.SendMsg("You have used all your energy and will return to the afterlife in 15 seconds.", CHAT_IC)
		if(!sent_to_afterlife)
			sent_to_afterlife = 1
			spawn(150)
				if(Dead && !Is_In_Afterlife(src))
					if(grabber) grabber.ReleaseGrab()
					ReleaseGrab()
					for(var/mob/M in player_view(15,src))
						M.SendMsg("[src] is returned to the afterlife due to lack of energy.", CHAT_IC)
					SafeTeleport(locate(170,190,5))
				sent_to_afterlife = 0
	else
		IncreaseKi(-drain)

proc/Is_In_Afterlife(mob/P)
	var/area/a=P.get_area()
	if(!a) return
	if(a.name in list("Hell","Heaven","Checkpoint","Kaioshin","tournament area","Prison",)) return 1

mob/proc/Gravity_Health_Ratio()
	var/Ratio=(Gravity/gravity_mastered)**3
	if(Ratio<1) Ratio=1
	return Ratio
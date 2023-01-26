//this means having really high speed decreases the damage you do per hit
mob/proc/GetSpeedDamageDecrease()

	//return 1 //disabled for now

	var/n = 1
	//n *= Speed_delay_mult(severity=melee_delay_severity) //if we did this the damage would be increased directly proportionate to how much it slows you down
	//which would make you do exactly the same DPS no matter how fast or slow you are. just an example
	n += (Speed_delay_mult(severity = melee_delay_severity) - 1) * lowSpeedDmgAdd

	//set the mult back to 1 if you arent attacking anywhere near your full speed because this means you and your enemy are running around
	//which negates any up close speed advantage so we shouldnt apply a damage debuff based on speed in this scenario because enough time
	//has passed in between that you can be delivering power punches again since you are flurrying super fast at the enemy right now
	//if(world.time - last_melee_attack >= Get_melee_delay() * 3) n = 1
		//nevermind now that low speed masively slows down move rate, thats enough downside

	return n

mob/var
	tmp
		last_melee_self_injury = 0
		mob/last_mob_attacked
		lastSetOpponent = 0 //world.time

mob/proc/Opponent(timeLimit = 65)
	if(world.time - lastSetOpponent > timeLimit) return
	return Opponent

//src is the person being attacked, M is the attacker
mob/proc/setOpponent(mob/M)
	if(!M || IsCorpse(M) || IsCorpse(src)) return
	Opponent = M
	lastSetOpponent = world.time
	if(M.client)
		if(!(M.key in recentOpponents) || world.realtime - recentOpponents[M.key] > Time.FromMinutes(5))
			recentOpponents[M.key] = world.realtime
	M.last_mob_attacked = src

mob/proc/IncreaseHealth(n = 0)
	if(client?.buildMode && n < 0) return
	if(istype(src, /mob/Body)) return

	//add n to health
	Health += n

	//hp should always be between 0 and 100
	Health = Math.Clamp(Health, 0, 100)

	if(client)
		if(lastResourceUpdate < world.time)
			resourceCallback.Call()
		lastResourceUpdate = world.time

mob/proc/IncreaseKi(n = 0)
	if(client?.buildMode && n < 0) return
	if(istype(src, /mob/Body)) return
	if(HasTrait("Fueled by Rage") && anger > 100 && n < 0)
		return TakeDamage(-(n / max_ki) * 15)
	Ki += n
	Ki = Math.Clamp(Ki, 0, TrueMaxKi())

	if(client)
		if(lastResourceUpdate < world.time)
			resourceCallback.Call()
		lastResourceUpdate = world.time

mob/proc/TrueMaxKi()
	if(istype(src, /mob/Body)) return
	var/max = max_ki
	if(Blast_Absorb) max *= 2
	if(gp_list && gp_list.len) max *= gp_list.len + 1
	return max

mob/proc/PowerupDamageGrabber(n = 1) //multiply by n for "damage per second" regardless of call rate
	var/mob/m = grabber
	if(!m || m.loc != loc) return
	var/drain = GetSkillDrain(mod = 40 * n, is_energy = 1)
	if(Ki < drain) return
	var/dmg = 5 * n
	dmg *= ((BP * Eff * recov) / ((m.BP * 0.8) * m.Res)) ** 0.5
	m.TakeDamage(dmg, src)
	IncreaseKi(-drain)

mob/var/tmp
	power_attack_meter=0 //0 to 1 (100%)
	last_power_attack=0
	power_attacking

proc/Get_lunge_drawback_graphic()
	for(var/obj/o in lunge_graphics)
		o.icon_state="1"
		lunge_graphics-=o
		return o
	return new/obj/Lunge_Graphic

var/list/lunge_graphics=new

obj/Lunge_Graphic
	Dead_Zone_Immune=1
	Health=1.#INF
	Grabbable=0
	Nukable=0
	Knockable=0
	Savable=0
	attackable=0
	layer=5
	icon='attack spark.dmi'
	icon_state="1"

	New()
		spawn CenterIcon(src)

	Del()
		lunge_graphics-=src
		lunge_graphics+=src
		SafeTeleport(null)

	proc/Lunge_stick_to(mob/center)
		set waitfor=0
		while(z && center)
			SafeTeleport(center.loc)
			sleep(world.tick_lag)

	proc/Lunge_go(mob/center)
		SafeTeleport(center.loc)
		Lunge_stick_to(center)
		for(var/v in 1 to 6)
			if(!z) break
			else
				icon_state="[v]"
				sleep(TickMult(0.75))
		if(z) del(src)

mob/var/tmp
	lunge_attacking
	mob/lunge_target
	distance_lunged=0
	last_lunge_attack=0
	post_lunge=0
	pre_lunge=0

mob/proc/Can_lunge()
	if(Shielding()) return
	if(last_lunge_attack + Lunge_refire() < world.time) return 1

mob/proc/Lunge_refire()
	var/n = TickMult(Get_melee_delay(mult = 2.5))
	n *= transMeleeDelay
	return n

mob/var/transMeleeDelay = 1

mob/var/tmp/mob/being_lunged_at_by

mob/proc/Get_idle_state()
	var/s=""
	if(Flying) s="Flight"
	if(Action=="Meditating") s="Meditate"
	if(Action=="Training") s="Train"
	if(KB) s="KB"
	if(KO) s="KO"
	return s

mob/proc/Lunge_toward(mob/m)
	lunge_attacking=1
	lunge_target=m
	attacking=1
	post_lunge=0
	icon_state="Attack"
	distance_lunged=0
	if(ismob(m)) m.being_lunged_at_by=src
	power_attack_meter=0 //lunge attacking resets power attack
	pre_lunge=1

	if(!ultra_instinct)
		Do_lunge_drawback_animation()
		sleep(TickMult(2 + Get_melee_delay(mult = 2)))

	var/mob/target_loc=m
	var/lunge_distance=Get_lunge_distance()
	var/was_flying=Flying
	var/start_dir=dir
	Fly()

	for(var/v in 1 to lunge_distance)
		if(KB || KO || !lunge_attacking || !target_loc || loc==target_loc || loc==target_loc.loc || Mob_in_front() || !viewable(src,lunge_target)) break
		else
			var/dir_holder = dir
			dir = start_dir
			if(target_loc == m && !isturf(m) && (get_abs_angle(src,m) > 55))
				target_loc = m.base_loc()
			dir = dir_holder
			var/old_loc = loc

			IncreaseStamina(-tapwarp_stam_drain / 4)
			if(stamina <= 0 || stamina < tapwarp_stam_drain) break

			var/velocity_boost_chance = 100 + (150 * (Spd / Max_Speed)**0.5) //base of 100 for the first guaranteed move, the rest is boost
			while(velocity_boost_chance > 0)
				if(prob(velocity_boost_chance) && get_dist(src,target_loc) > 1)
					AfterImage(40, 4)
					step_towards(src,target_loc,32)
				velocity_boost_chance -= 100

			flick('Zanzoken.dmi',src)
			distance_lunged++
			if(loc == old_loc || get_dist(src,target_loc) <= 1) break
			else sleep(world.tick_lag)

	pre_lunge=0
	post_lunge=1
	if(!was_flying) Land()
	icon_state=Get_idle_state()
	flick("Attack",src)
	dir=get_dir(src,target_loc)

	//spawn(Get_melee_delay(mult=1.5)) Cancel_lunge()
	spawn(world.tick_lag) Cancel_lunge() //so we can move immediately after the lunge is done instead of being stuck in place

mob/proc/Lunge_step_delay()
	return TickMult(world.tick_lag * 0.84)

mob/proc/Mob_in_front()
	for(var/mob/m in get_step(src,dir)) if(m != src) return m

mob/proc/Cancel_lunge()
	if(!lunge_attacking) return
	icon_state=Get_idle_state()
	lunge_attacking=0
	lunge_target=null
	distance_lunged=0
	attacking=0
	post_lunge=0
	last_lunge_attack=world.time

mob/proc/Do_lunge_drawback_animation()
	set waitfor=0
	Play_Melee_Sound(sound_range=15,origin=src,sound_file='throw.ogg',sound_volume=35)
	var/obj/Lunge_Graphic/lg=Get_lunge_drawback_graphic()
	if(lg) lg.Lunge_go(src)

mob/proc/Get_lunge_distance()
	var/n = 29
	if(ultra_instinct) n *= 2
	return n

mob/proc/Get_lunge_targeting_distance()
	var/n = 19
	if(ultra_instinct) n *= 2
	return n

atom/movable/proc/At_forward_half(mob/m)
	if(get_dir(src,m) in list(dir,turn(dir,45),turn(dir,-45))) return 1

mob/proc/find_melee_target(mob/O,from_auto_attack)
	var/mob/target=O
	if(!target)
		var/turf/t=Get_step(src,dir)
		if(t&&isturf(t))
			if(!from_auto_attack)
				if(t.attackable&&t.density) target=t
				for(var/obj/m in t)
					if(!m.attackable || IsPartyMember(m)) continue
					target=m
					break
			for(var/mob/m in t)
				if(!m.attackable || m ==src || IsPartyMember(m)) continue
				target=m
				break
			if(Target && (Target in t)) target = Target
		//arc attack
		if(!target && !lunge_attacking)
			var/list/sides=list(Get_step(src,turn(dir,45)),Get_step(src,turn(dir,-45)))
			sides=shuffle(sides)
			for(var/turf/t2 in sides)
				if(Target && (Target in t2))
					target = Target
					break
				for(var/mob/m in t2) if(m.attackable && m!=src)
					target=m
					break
				if(target) break
	if(target) dir=get_dir(src,target)
	if(ismob(target)) Set_flash_step_mob(target)
	return target

proc/Defense_damage_reduction(mob/attacker,mob/defender)
	//if there's no attacker or they're not a mob return 1x
	if(!attacker||!ismob(attacker)||!ismob(defender)) return 1
	//default to 1x
	var/mod = 1
	//increase by accuracy mod
	mod += attacker.GetStatMod("Acc")
	//decrease by reflex mod
	mod -= defender.GetStatMod("Def")
	//can't be less than 0.5x or greater than 1.2x
	mod = Math.Clamp(mod, 0.5, 1.2)
	return mod

var/give_power_dmg=50

mob/proc/MeleeCritChance(mob/target)
	if(!ismob(target)) return 0
	var/critChance = 5
	if(GetTraitRank("Bloodied Criticals"))
		critChance += target.bleedStacks.len * 5
	critChance += GetCritBonus()
	return critChance

proc/GetTierDamageMod(atom/attacker, atom/target)
	var/tBPT, aBPT
	if(ismob(target)) tBPT = target:effectiveBPTier
	else tBPT = target.defenseTier
	if(ismob(attacker)) aBPT = attacker:effectiveBPTier
	else aBPT = attacker.defenseTier
	if(tBPT > aBPT)
		return (GetModifiedTierBonus(Mechanics.GetSettingValue("BP Tier Damage Bonus"), aBPT, tBPT) * \
				((ismob(attacker) && attacker:HasTrait("Power Overwhelming")) ? 2 : 1))
	return 1

proc/GetTierTankingMod(atom/attacker, atom/target)
	var/tBPT, aBPT
	if(ismob(target)) tBPT = target:effectiveBPTier
	else tBPT = target.defenseTier
	if(ismob(attacker)) aBPT = attacker:effectiveBPTier
	else aBPT = attacker.defenseTier
	if(tBPT > aBPT)
		return (GetModifiedTierBonus(Mechanics.GetSettingValue("BP Tier Tanking Bonus"), target, attacker) * \
				((ismob(target) && target:HasTrait("Power Overwhelming")) ? 2 : 1))
	return 1

mob/proc/GetMeleeDamage(mob/target, dmg = Mechanics.GetSettingValue("Base Melee Damage"))
	if(ismob(target))
		//add damage based on strength and weapon
		dmg += src.GetStatMod("Str")

		//add ki damage if they have the appropriate trait and are unarmed
		if(!src.GetEquippedWeapon() && src.HasTrait("Empowered Fists"))
			dmg += src.GetStatMod("For")

		//multiply damage based on current Power Tier
		dmg *= GetTierDamageMod(src, target)

		//add weapon damage
		dmg += GetWeaponDamage()

		//check if lunging, then apply damage bonus if so
		if(lunge_attacking)
			dmg *= 1.75

		//increase damage to KOd targets
		if(target.KO)
			dmg *= 10

		//increase damage to people trying to heal mid combat
		if(target.regenerator_obj)
			dmg *= 10

		//check for vampire, deal more damage to them if using silvered weapon (no silvered weapons exist currently)
		if(target.Vampire && IsWeaponSilvered())
			dmg *= 2.5

		//if facing same direction, we're backstabbing so deal more damage
		if(target.dir == src.dir)
			dmg *= 1.5

		//compare accuracy & reflex of attacker/defender, and modify damage based on the difference
		dmg *= Defense_damage_reduction(src,target)

		//increase damage against characters with regen over 1x
		dmg += target.regen - 1

		//if you have way more BP than target, increase damage by a lot. Trigger req set by server settings
		if(src.BP / target.BP > Limits.GetSettingValue("Absurd Damage Requirement"))
			dmg *= 20 + (src.BP / target.BP)

		//random chance to deal 50% more damage, is super low by default but can be increased/decreased by certain weapons
		if(prob(MeleeCritChance(target)))
			dmg *= 1.5

		if(HasTrait("Mind the Heel"))
			dmg *= 1.2

		//if you're in a party, scale damage up/down based on the number of people in the fight
		if(PartySize() > 1) dmg /= PartySize() * 0.7 * (HasTrait("Pack Mentality") ? 0.95 : 1)
		else if(HasTrait("Lone Wolf")) dmg *= 1.15
		if(target.PartySize() > 1) dmg *= target.PartySize() * 0.3 * (target.HasTrait("Pack Mentality") ? 0.95 : 1)

		if(Race == "Tsujin" && HasTrait("Nerd Rage") && anger > 100)
			dmg *= 1 + (Intelligence / 2)

		if(target.Race == "Tsujin" && target.HasTrait("Nerd Rage") && target.anger > 100)
			dmg /= 1 + (target.Intelligence / 2)

		//do less damage against splits/sims you make
		if(istype(target, /mob/Splitform))
			if(src == target.Maker)
				dmg *= 0.2

		//decrease damage based on target dura and armor.
		var/dmgReduction = target.GetStatMod("Dur")
		if(!src.GetEquippedWeapon() && src.HasTrait("Empowered Fists"))
			dmgReduction += target.GetStatMod("Res")
			dmgReduction /= 2
		if(!target.GetEquippedArmor() && target.HasTrait("Ki Armor"))
			dmgReduction += target.GetStatMod("Res")
		dmgReduction *= GetTierTankingMod(src, target)
		var/mod = 1
		if(IsWeaponBladed())
			mod -= GetTraitRank("Knife to a Fist Fight") * 0.25
		dmgReduction += target.GetArmorBonus() * mod

		dmg -= dmgReduction

		dmg *= 0.5

		//damage should always be at least 1
		dmg = Math.Max(dmg, 1)
		
		//don't hurt party members
		if(IsPartyMember(target)) dmg = 0

	else if(isobj(target)||isturf(target))
		if(!client || target.takes_gradual_damage)
			dmg = 2 * (BP/100)
			if(isturf(target)) dmg/=10
		else
			if((target.defenseTier * Mechanics.GetSettingValue("Turf Health Multiplier") < usr.effectiveBPTier + usr.GetStatMod("Str")) && usr.Is_wall_breaker())
				if(target.Health != 1.#INF)
					dmg=1.#INF
			else if(!client)
				if(drone_module) dmg = Mechanics.GetSettingValue("Turf Health Multiplier") * BP / 750 //npcs can gradually break anything
				else dmg = Mechanics.GetSettingValue("Turf Health Multiplier") * BP / 7000
	if(istype(src,/mob/Splitform) && dmg > 5) dmg = 5
	return dmg

mob/proc/DroneTeamerMult(mob/target, dmg = 1)
	var/drone_count=0
	if(drone_module)
		var/list/other_drones=Get_Drones(null,drone_module.Password)
		for(var/mob/d in other_drones)
			if(d!=src && d.drone_attack_loop && z==d.z && d.Target==target && getdist(src,d)<=15)
				if(!drone_count)dmg/=2.5
				else dmg/=1.1
				drone_count++
				if(drone_count>=10) break
	else if(target.drone_module)
		var/list/other_drones=Get_Drones(null,target.drone_module.Password)
		for(var/mob/d in other_drones)
			if(d!=target && d.drone_attack_loop && target.z==d.z && d.Target==src && getdist(src,d)<=15)
				if(!drone_count) dmg*=2.5
				else dmg*=1.1
				drone_count++
				if(drone_count>=10) break
	return dmg

mob/proc/WallBreakPower()
	var/stat_total = Stat_Avg()

	var/buff_mult=1
	if(current_buff)
		var/obj/Skills/Buff/b=current_buff
		buff_mult = b.Stat_Avg()
		if(buff_mult<1) buff_mult=buff_mult**2

	var/n=stat_total * buff_mult
	n += BP * (effectiveBPTier * 0.1)

	return n * 1.3 //arbitrary

obj/Skills/Buff/proc/Stat_Avg()
	var/total = 0
	total += buff_str
	total += buff_dur
	total += buff_for
	total += buff_res
	total += buff_spd
	total += buff_off
	total += buff_def
	total /= 7
	return total

mob/proc/teststatrating()
	var/stat_total=(Str+End+Spd+Pow+Res+Off+Def)/7
	return stat_total

/*
WALL BREAK POWER TEST

they all have a base power of 100

my guy:
wall break bp = 150
stat multiplier = 6.62
buff mult = 1
regen mult = 0.75
can break walls with bp of = 744

other guy:
wall break bp = 500
stat multiplier = 2.72
buff mult = 0.71
regen mult = 1
can break walls with bp of = 965

other guy:
wall break bp = 260
stat multiplier = 2.72
buff mult = 1
regen mult = 1
can break walls with bp of = 707
*/

mob/Admin5/verb/testwallbreakpower(mob/m in world)
	src.SendMsg("[m.name] can break [Commas(m.WallBreakPower())] BP walls.", CHAT_IC)

mob/proc/Is_wall_breaker()
	if(Limits.GetSettingValue("Top BP Percent to Break Walls") >= 100) return 1
	var/stronger_people=0
	for(var/mob/m in players) if(m.base_bp + m.static_bp> base_bp + static_bp) stronger_people++
	if(!stronger_people) return 1
	if((stronger_people / Player_Count()) * 100 >= Limits.GetSettingValue("Top BP Percent to Break Walls")) return
	return 1

mob/proc/Speed_accuracy_mult(mob/defender)
	var/acc_mult = Clamp((defender.Speed_delay_mult(severity=0.5) / Speed_delay_mult(severity=0.5))**speed_accuracy_mult_exponent, speed_accuracy_mult_min, speed_accuracy_mult_max)
	return acc_mult

//offense vs defense accuracy multiplier
proc/Acc_mult(n=1)
	return n ** 0.5
	//REMOVE BELOW IF ABOVE WORKS
	if(n > 1) n = n ** superior_off_vs_def_mult_exponent
	else n = n ** inferior_off_vs_def_mult_exponent
	return n

mob/proc/DodgeStamCost(mob/attacker)
	var/accuracy = attacker.GetAttackAccuracy(src)
	if(accuracy == 0) return 0
	var/cost = 11 * (accuracy / base_melee_accuracy)
	if(ultra_instinct) cost /= 4
	return cost

mob/proc/GetAttackAccuracy(mob/target, dmg = 1)
	if(!ismob(target)) return 100
	var/acc = GetWeaponAccuracy()
	acc += dmg + GetStatMod("Acc")
	if(src.effectiveBPTier > target.effectiveBPTier)
		acc *= GetModifiedTierBonus(Mechanics.GetSettingValue("BP Tier Damage Bonus"), src, target) * (src.HasTrait("Power Overwhelming") ? 2 : 1)
	var/accReduction = target.GetStatMod("Ref")
	if(src.effectiveBPTier < target.effectiveBPTier)
		accReduction *= GetModifiedTierBonus(Mechanics.GetSettingValue("BP Tier Damage Bonus"), target, src) * (src.HasTrait("Power Overwhelming") ? 2 : 1)
	acc -= accReduction
	acc *= target.GetArmorDodgeMod()
	return Math.Clamp(acc, 1, 99)

mob/proc/get_active_shield()
	if(IsShielding())
		return shield_obj

//some of these are additive some are multiplied in
mob/proc/GetSkillDrain(mod = 1, is_energy = 0)
	var/d = 1

	//if(!is_energy) d += weights()**0.35 - 1 //just didnt care for weights increasing drain anymore
	d += (Anger_mult()**1 - 1) * 0.45

	if(!is_energy) d += (Clamp(str_share()**1, 0.8, 1.#INF) - 1) * 1.4
	else d += (Clamp(frc_share()**1, 0.8, 1.#INF) - 1) * 1.4

	d *= (max_ki / 5000) ** 0.5

	return d * mod

mob/var/knockback_on = 1

mob/proc/GetMeleeKnockbackDist(mob/target)
	if(!knockback_on) return 0
	if(IsPartyMember(target)) return 0
	if(!ismob(target)) return 0
	if(istype(src,/mob/Splitform)) return 0
	if(istype(target,/mob/Splitform)) return 0
	if(!ismob(target)) return 0
	var/dist = 2
	if(distance_lunged) dist *= 2.3
	if(ultra_instinct) dist += 3

	dist += GetStatMod("Str") * GetWeaponKnockback()
	if(src.effectiveBPTier > target.effectiveBPTier)
		dist *= GetModifiedTierBonus(1.5, src, target) * (src.HasTrait("Power Overwhelming") ? 2 : 1)
	var/distReduction = target.GetStatMod("Dur") * target.GetArmorKnockbackMod()
	if(src.effectiveBPTier < target.effectiveBPTier)
		distReduction *= GetModifiedTierBonus(0.5, target, src) * (src.HasTrait("Power Overwhelming") ? 2 : 1)
	
	dist -= distReduction

	dist *= Math.Rand()
	var/mod = 1
	if(HasTrait("Super Slam") && prob(50)) mod = 4

	var/add = 0

	if(CheckForInjuries())
		add += Math.Floor(GetInjuryTypeCount(/injury/bruising) / 3)

	return Math.Min(Math.Floor(dist), 20 + add) * mod

mob/proc/get_melee_sounds(knockback_dist=0)
	var/list/l=list('weakpunch.ogg','weakkick.ogg','mediumpunch.ogg','mediumkick.ogg')
	if(knockback_dist >= 12) l=list('strongpunch.ogg','strongkick.ogg')
	return l

mob/proc/if_target_is_splitform_then_target_attacks_you(mob/target)
	var/mob/Splitform/sf=target
	if(client&&istype(sf,/mob/Splitform)&&!sf.Mode)
		sf.Mode="Attack Target"
		sf.Target=src

mob/var/tmp/combo_teleport_loop_running

mob/proc/Combo_recharge()
	set waitfor=0
	if(combo_teleport_loop_running) return
	combo_teleport_loop_running=1
	sleep(Combo_recharge_time())
	available_combos=initial(available_combos) + GetStatMod("Spd") + Math.Floor(GetStatMod("Acc") / 2)
	combo_teleport_loop_running=0

mob/proc/Combo_recharge_time()
	var/t=52*Speed_delay_mult(severity=0.5)
	return TickMult(t)

mob/var/tmp/last_combo_teleport=0 //world.time
mob/var/tmp/available_combos=4

mob/proc/combo_teleport(mob/m)
	if(available_combos<=0) return
	if(!Warp||Ki<Zanzoken_Drain()) return
	if(stamina < (tapwarp_stam_drain / 5)) return
	if(m.z!=z||getdist(src,m)>13 || !ismob(m)) return
	//var/turf/t=Get_step(m,get_dir(m,src))

	var/list/nearby_turfs=new
	for(var/turf/t in oview(1,m)) nearby_turfs+=t
	var/turf/t
	if(nearby_turfs.len) t=pick(nearby_turfs)

	if(t&&isturf(t)&&!t.density&&t.Enter(src)&&!(locate(/mob) in t))
		IncreaseKi(-Zanzoken_Drain())
		Zanzoken_Mastery(0.2)
		IncreaseStamina(-(tapwarp_stam_drain / 5))
		player_view(7,src)<<sound('teleport.ogg',volume=10)
		flick('Zanzoken.dmi',src)
		SafeTeleport(t)
		last_combo_teleport=world.time
		m.last_combo_teleport=world.time
		available_combos--
		if(available_combos<=0) Combo_recharge()
		dir=get_dir(src,m)
		if(ismob(m) && prob(50 - m.GetStatMod("Ref") + src.GetStatMod("Acc")))
			m.dir = src.dir

mob/proc/if_target_is_npc_target_attacks_you(mob/target)
	set waitfor=0
	if(!target) return
	if(!ismob(target)) return
	if(istype(target,/mob/Enemy)&&client)
		//target.Docile=0
		target.Attack_Target(src)
	if(istype(target,/mob/Troll)&&client)
		var/mob/Troll/troll=target
		troll.Target=src
		if(troll.Health<=40&&troll.Troll_Mode!="Run") troll.Troll_Run()
		else if(troll.Troll_Mode!="Attack") troll.Troll_Attack()
	if(istype(target,/mob/new_troll)&&client)
		var/mob/new_troll/t=target
		t.TrollGotAttacked(src)
mob/var
	tmp/strangling
	tmp/can_strangle_timer=0

var/image/grab_absorb_overlay = image(icon = 'AbsorbSparks.dmi', layer = 6)

mob/proc/GetStrangleDamage(mob/target, dmg = 2, is_absorb = 0)
	if(!target || !ismob(target)) return
	if(is_absorb)
		dmg += src.GetStatMod("For") * src.GetTierBonus(0.6)
	else
		dmg += src.GetStatMod("Str") * src.GetTierBonus(0.6)
	dmg -= ((target.GetStatMod("Dur") + target.GetStatMod("Res")) / 2) * target.GetTierBonus(1)
	dmg = Math.Max(dmg, 1)
	if(src.BP / target.BP > Limits.GetSettingValue("Absurd Damage Requirement")) dmg *= 150
	return dmg * (HasTrait("Mind the Heel") ? 1.5 : 0)

mob/proc/Toggle_strangling()
	if(can_strangle_timer) return
	can_strangle_timer=1
	spawn(20) can_strangle_timer=0
	strangling=!strangling
	if(strangling)

		if(GrabAbsorber())
			overlays -= grab_absorb_overlay
			overlays += grab_absorb_overlay
			for(var/mob/M in player_view(center=src))
				M.SendMsg("<font color=cyan>[src] grabs [grabbedObject] and begins absorbing their energy!", CHAT_IC)
		else for(var/mob/M in player_view(center=src))
			M.SendMsg("<font color=red>[src] begins strangling [grabbedObject]!", CHAT_IC)

		while(strangling && grabbedObject)

			var/dmg=GetStrangleDamage(grabbedObject, is_absorb = GrabAbsorber())
			
			if(grabbedObject.Race=="Majin") dmg=0

			if(GrabAbsorber())
				dmg += grabbedObject.max_ki / 100
				if(grabbedObject.KO) dmg *= 4
				dmg = Math.Min(dmg, grabbedObject.Ki)
				grabbedObject.IncreaseKi(-dmg)
				IncreaseKi(dmg)
				var/k = Ki
				k = Math.Min(k, max_ki * 1.8)
				if(Ki > k) IncreaseKi(-(Ki - k))
			else
				grabbedObject.TakeDamage(dmg, src)

			sleep(TickMult(5))
		strangling=0
		overlays -= grab_absorb_overlay
	else
		for(var/mob/M in player_view(center=src))
			M.SendMsg("[src.name] stops strangling [grabbedObject.name].", CHAT_IC)
		overlays -= grab_absorb_overlay

mob/proc/Get_melee_delay(mult=1,injuries_matter=1)
	var/delay = mult * base_melee_delay * Speed_delay_mult(severity = melee_delay_severity)

	delay *= GetWeaponDelayMod()
	delay *= GetArmorDelayMod()

	delay -= delay * ((5 * GetTraitRank("Unarmored Combatant")) / 100)

	if(CheckForInjuries() && GetInjuryTypeCount(/injury/fracture/left_arm))
		delay *= 1.05
	if(CheckForInjuries() && GetInjuryTypeCount(/injury/fracture/right_arm))
		delay *= 1.05

	return TickMult(delay)

mob/var/tmp
	last_attacked_mob_time=0
	last_melee_attack = 0 //world.time

mob/proc/Reset_melee()
	if(attacking == 1) attacking=0
	if(power_attacking)
		last_power_attack=world.time
		power_attack_meter=0
		power_attacking=0
		//last_lunge_attack=world.time //because otherwise it lets you lunge attack 0 seconds after you just power attacked someone

mob/var/tmp/melee_code=0

mob/proc/MeleeFollowupAttackCheck()
	set waitfor=0
	if(!can_melee()) return
	var/list/targs = FindTargets(dir_angle = dir, angle_limit=50, max_dist=20, prefer_auto_target=0)
	if(last_mob_attacked && (last_mob_attacked in targs))
		var/mob/m = last_mob_attacked
		if(m && m != src && m.KB)
			var/list/l = list(get_step(m, m.dir), get_step(m, turn(m.dir,45)), get_step(m, turn(m.dir,-45)), \
				get_step(m, turn(m.dir,90)), get_step(m, turn(m.dir,-90)))
			for(var/turf/t in l)
				if(t.density) l -= t
			if(l.len)
				var/turf/t = pick(l)
				if(t && isturf(t))
					SafeTeleport(t)
					player_view(15,src)<<sound('teleport.ogg',volume=15)
					flick('Zanzoken.dmi',src)
					dir = get_dir(src,m)
					Melee()
					return 1

mob/proc/LungeAttack()
	set waitfor=0
	Melee(lunge_allowed = 1)

mob/var/tmp/last_flip = 0

mob/proc/Flip()
	set waitfor=0
	if(world.time - last_flip < 3) return
	last_flip = world.time
	var/d = pick(90,-90)
	for(var/v in 1 to 4)
		animate(src, transform = turn(src.transform, d), time = world.tick_lag)
		sleep(world.tick_lag)

mob/proc/Melee(obj/O, from_auto_attack, force_power_attack, lunge_allowed = 0, obj/items/Weapon/weapon)
	set waitfor=0
	if(grabber) return

	if(!from_auto_attack&&grabbedObject&&ismob(grabbedObject)&&!KO) Toggle_strangling()

	var/mob/target = find_melee_target(O,from_auto_attack)
	if(lunge_allowed && !target && !from_auto_attack && Can_lunge())
		target = LungeTarget()
		if(target)
			if(!can_melee()) return //because the can_melee call above will let you continue with a power attack but if you made it to this block
			//then you are actually lunging so ignore the previous can_melee args
			Lunge_toward(target)

			//they already initiated dragon rush with you so cancel the rest of this melee attack because it causes problems
			if(in_dragon_rush && target.in_dragon_rush)
				lunge_attacking = 0
				return

			if(CheckLungeDragonRush(src,target))
				lunge_attacking = 0
				return

		target = find_melee_target(O,from_auto_attack)

	//this block of code means that a lunge attacker gets the first hit in a melee if they are the fastest
	if(target && ismob(target) && target!=src)
		if(target.lunge_attacking && !target.post_lunge)
			if(lunge_attacking && !post_lunge)
				if(target.Speed_delay_mult() > Speed_delay_mult()) sleep(TickMult(2))

	if(!target || getdist(src,target)>1)
		Reset_melee()
		return

	if(client && ismob(target) && target.Flying && !Flying)
		Reset_melee()
		return

	//your splitforms can not attack each other
	if(type == /mob/Splitform && target && target.type == /mob/Splitform)
		var/mob/Splitform/sf = src
		var/mob/Splitform/sf2 = target
		if(sf.Maker && sf.Maker == sf2.Maker)
			Reset_melee()
			return

	var/energy_drain = GetSkillDrain(mod = 24, is_energy = 0)

	if(lunge_attacking) energy_drain*=3
	if(power_attacking) energy_drain*=3

	if(energy_drain>Ki)
		Reset_melee()
		return //too tired to attack
	var/dmg = GetMeleeDamage(target)
	var/accuracy = GetAttackAccuracy(target, dmg)
	var/delay = Get_melee_delay()
	var/obj/Skills/Combat/Ki/Shield/ki_shield
	if(ismob(target)) ki_shield=target.get_active_shield()
	var/knockback=GetMeleeKnockbackDist(target)
	if(!dmg || dmg < 0)
		knockback=0
	last_melee_attack = world.time

	if(ismob(target) && (target.Safezone || target.isAFK))
		knockback=0
	var/list/sounds=get_melee_sounds(knockback)

	if(client)
		IncreaseKi(-energy_drain)
		if(ultra_instinct)
			var/stam_drain = 8
			if(lunge_attacking) stam_drain *= 3
			IncreaseStamina(-stam_drain)

	if(!lunge_attacking)
		attacking=1
		melee_code=world.time
		var/instance_code=world.time
		spawn(delay)
			if(melee_code==instance_code)
				Reset_melee()
			//^ its like this because power attacking can be done any time during normal melee even if melee is not reset so this can
			//often create double reset loop letting them attack 2x faster than they should be. idk if this fixes it tho

	if(target&&ismob(target)) target.setOpponent(src)
	PunchGraphics()
	spawn if(target&&ismob(target)&&target.drone_module)
		if(target.drone_module&&drone_module&&target.drone_module.Password==drone_module.Password)
		else target.Drone_Attack(src,lethal=1)
	if_target_is_splitform_then_target_attacks_you(target)

	if(ismob(target) && ki_shield)
		var/shield_drain = dmg * target.ShieldDamageReduction() * (target.max_ki/100/(target.Eff**shield_exponent))*target.Generator_reduction(is_melee=1)
		if(target.Ki>=shield_drain)
			target.IncreaseKi(-shield_drain)
			Play_Melee_Sound(sound_range=10,origin=target,sound_file=pick('meleemiss1.ogg',\
			'meleemiss2.ogg','meleemiss3.ogg'),sound_volume=20)
			if(knockback)
				if(prob(30)) Make_Shockwave(target,sw_icon_size=pick(64,128))
				Melee_Shockwave_Repel(target)
				target.Knockback(src,knockback)
				if(target) combo_teleport(target)
			return

	if(ismob(target))
		target.SetLastAttackedTime(src)
		last_attacked_mob_time=world.time

	//actually hit them
	var/hit_landed = (prob(accuracy) || (ismob(target) && !target.CanMeleeDodge(src)))

	//to make dodge rate 100% so long as they have yellow bar
	//if(ismob(target) && target.CanMeleeDodge(src)) hit_landed = 0

	if(hit_landed)
		Play_Melee_Sound(sound_range=10,origin=src,sound_file=pick(sounds),sound_volume=20)
		if(lunge_attacking) BigCrater(pos = target.base_loc(), minRangeFromOtherCraters = 3)

		if(ismob(target))
			if(knockback)
				if(prob(33)) Make_Shockwave(target, sw_icon_size=pick(128,256))
				if(target) Melee_Shockwave_Repel(target)
				target.Knockback(src, knockback, from_lunge=lunge_attacking)
				if(!target)
					Reset_melee()
					return
				combo_teleport(target)

			target.ApplyBleed(GetWeaponBleed() * 20)

			if(DoesWeaponStun() && prob(10)) target.ApplyStun()

			var/injury/tryInjure = new/injury/fracture/ribs
			target.TryInjure(tryInjure, GetWeaponFracture(), dmg, src)
			tryInjure = new/injury/fracture/left_arm
			target.TryInjure(tryInjure, GetWeaponFracture(), dmg, src)
			tryInjure = new/injury/fracture/right_arm
			target.TryInjure(tryInjure, GetWeaponFracture(), dmg, src)
			tryInjure = new/injury/fracture/left_leg
			target.TryInjure(tryInjure, GetWeaponFracture(), dmg, src)
			tryInjure = new/injury/fracture/right_leg
			target.TryInjure(tryInjure, GetWeaponFracture(), dmg, src)

			tryInjure = new/injury/laceration
			target.TryInjure(tryInjure, GetWeaponLacerate(), dmg, src)
			tryInjure = new/injury/bruising
			target.TryInjure(tryInjure, GetWeaponBruise(), dmg, src)
			tryInjure = new/injury/tortion
			target.TryInjure(tryInjure, GetWeaponTortion(), dmg, src)
			tryInjure = new/injury/internal_bleeding
			target.TryInjure(tryInjure, GetWeaponInternal(), dmg, src)

			target.TakeDamage(dmg, src)

		if(isobj(target))
			var/obj/o = target
			target.Health -= dmg
			if(target.Health<=0)
				if(!o.leaves_big_crater) Small_crater(o.loc)
				del(target)

		if(isturf(target))
			var/turf/t=target
			t.Health-=dmg
			if(t.Health<=0)
				t.Health=0
				t.Destroy()
	else
		last_combo_teleport=0
		target.last_combo_teleport=0
		target.MeleeAutoDodge(src)

		if(target.ultra_instinct)
			target.Flip()
			target.SafeTeleport(loc)
			step(src, dir, 32)
			if(prob(67))
				var/d = get_dir(target,src)
				d = turn(d, pick(45,-45))
				step(target, d, 32)
			target.dir = get_dir(target,src)

	if_target_is_npc_target_attacks_you(target)

mob/proc/MeleeAutoDodge(mob/attacker)
	IncreaseKi(-6)

	Play_Melee_Sound(sound_range=10,origin = src,sound_file=pick('meleemiss1.ogg',\
		'meleemiss2.ogg','meleemiss3.ogg'),sound_volume=20)
	Dodge_animation()
	dir = get_dir(src, attacker)

mob/proc/TryMeleeInjuries()

mob/proc/CanMeleeDodge(mob/attacker)
	if(!client) return //quick dirty fix to stop dead bodies from dodging but it affects all npcs oh well tho
	if(KO) return

	if(!(get_dir(src, attacker) == dir)) return

	return 1

mob/proc/CanBlastDeflect(mob/attacker)
	if(!client) return //quick dirty fix to stop dead bodies from dodging but it affects all npcs oh well tho
	if(KO) return

	if(!(get_dir(src, attacker) == dir)) return

	return 1

mob/proc/Dodge_animation()

	flick('Zanzoken.dmi',src)
	return

	if(!dodge_gfx)
		flick('Zanzoken.dmi',src)
	else if(icon_state!="Dodge")
		icon_state="Dodge"
		spawn(2) if(icon_state=="Dodge") icon_state=""



proc/Play_Melee_Sound(sound_range=10,mob/origin,sound_file,sound_volume=20)
	if(!origin||!sound_range||!sound_file) return
	if(origin&&origin.client&&origin.client.inactivity>200) return

	player_view(sound_range,origin)<<sound(sound_file,volume=sound_volume)

mob/proc/Melee_Shockwave_Repel(mob/target) //target = the person you just attacked, so we can exclude them from the repel
	set waitfor=0
	if(!knockback_on) return //less annoying when trying to multi spar
	if(!client || !target.client)
		return //because npc fighting causing shockwaves was incredibly annoying when sim sparring in the gym
	if(current_area) for(var/mob/sw_mob in current_area.player_list)
		if(!sw_mob.Giving_Power && sw_mob != src && sw_mob != target && getdist(sw_mob,src) <= 4 && viewable(src,sw_mob))
			sw_mob.MeleeRepelMob(src, 1.5 * GetMeleeKnockbackDist(sw_mob))

mob/proc
	MeleeRepelMob(mob/m, kb_pow = 1)
		set waitfor=0
		Knockback(m, kb_pow)
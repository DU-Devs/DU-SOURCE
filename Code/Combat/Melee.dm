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

	M.Log_attack(src)
	Opponent = M
	lastSetOpponent = world.time
	M.last_mob_attacked = src
	Attack_gain_loop()

	Set_chaser(M)
	//M.Set_chaser(src) //since fear always seems to fear the wrong person I switched this around for now as a test. 4/13/2015

	Set_possible_teamer_list(M) //still needed to create attack backlogs
	Check_if_being_teamed(M)

	Good_teaming_with_evil_check()
	M.Check_if_kiting()

mob/proc
	ShouldMeleeInjureSelf(mob/m)

		//return

		if(Race == "Majin") return
		if(world.time - last_melee_self_injury < 350) return
		if(m.End > End)
			if(Swordless_strength() > End * 2.2)
				if(prob(1))
					return 1

	MeleeInjureSelfCheck(mob/m)
		if(ShouldMeleeInjureSelf(m))
			MeleeInjureSelf()

	MeleeInjureSelf()
		MeleeInjury2017()

	MeleeInjury2017()
		last_melee_self_injury = world.time
		var/obj/Injuries/i = GetArmOrLegInjury()
		var/same_injuries = 0
		for(var/obj/Injuries/i2 in injury_list) if(i2.type == i.type) same_injuries++
		if(same_injuries >= i.Max_Injuries) return
		i.Wear_Off = Year + 0.2
		if(same_injuries) i.icon = i.Alt_Icon
		i.icon += Blood_Color()
		contents += i
		injury_list += i
		player_view(15,src) << "<font color=red>[src] gets an [i] injury!"
		Add_Injury_Overlays()
		Injury_removal_loop()
		Eye_Injury_Blindness()

proc/GetArmOrLegInjury()
	if(prob(50)) return new/obj/Injuries/Arm
	else return new/obj/Injuries/Leg






mob/proc/AllAttacksDamageModifiers(mob/target) //target = who you are attacking
	var/n = 1
	if(target && ismob(target))
		n *= GetRevengeDmgMod(target)
	if(ThingC() && Health < 100)
		var/mult = Health / 100
		mult = mult ** 0.5
		if(mult < 0.4) mult = 0.4
		n /= mult
	return n

mob/proc/TakeDamage(n = 0)
	if(grabbedObject && strangling && GrabAbsorber()) n *= 1.3 //take way more damage if busy grab absorbing someone's energy

	if(ThingC() && Health < 100)
		var/hp = Health
		if(hp < 1) hp = 1 //prevent error
		var/mult = hp / 100
		mult = mult ** 0.5
		if(mult < 0.4) mult = 0.4
		n *= mult

	if(stun_level || Frozen)
		n *= stun_damage_mod

	if(Class == "Legendary Yasai" && lssj_always_angry) n *= lssjTakeDmgMult //it was 0.5 but think about their regen shaving off some dmg think of it like this
	//they take 6% dmg per sec if taking normal dmg like anyone else but at half dmg its 3% per sec but they heal 2% per sec it becomes a difference of
	//4% compared to 1%
	if(Race == "Android") n *= android_dmg_taken_mult
	if(jirenAlien) n *= jirenTakeDmgMult

	Health -= n

mob/proc/PowerupDamageGrabber(n = 1) //multiply by n for "damage per second" regardless of call rate
	var/mob/m = grabber
	if(!m || m.loc != loc) return
	var/drain = GetSkillDrain(mod = 40 * n, is_energy = 1)
	if(Ki < drain) return
	var/dmg = 5 * n * AllAttacksDamageModifiers()
	dmg *= (BP / m.BP) ** 0.5
	dmg *= (Pow / m.Res) ** 0.5
	m.TakeDamage(dmg)
	Ki -= drain



mob/var/tmp
	power_attack_meter=0 //0 to 1 (100%)
	last_power_attack=0
	power_attacking

mob/proc
	Fill_power_attack_meter()
		var/n=0.13
		power_attack_meter+=n
		power_attack_meter=Clamp(power_attack_meter,0,1)

	Can_power_attack()
		if(world.time - last_power_attack < Get_melee_delay(mult=5)) return
		return 1

	Power_attack_chargeup_time(mob/m)
		var/n=1
		n*=2 - power_attack_meter
		if(m && ismob(m))
			n*=(m.BP / BP)**bp_exponent

			var/speed_influence=Speed_delay_mult(severity=0.3) / m.Speed_delay_mult(severity=0.3)
			n*=speed_influence

		n=Clamp(n,0.7,3)
		n=Get_melee_delay(mult=n)
		return n

	Trying_to_power_attack()
		var/yes
		switch(dir)
			if(NORTH)
				if(north >= world.time - world.tick_lag*2) yes=1
			if(SOUTH)
				if(south >= world.time - world.tick_lag*2) yes=1
			if(EAST)
				if(east >= world.time - world.tick_lag*2) yes=1
			if(WEST)
				if(west >= world.time - world.tick_lag*2) yes=1
		return yes

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
	if(ismajin) n*=0.6
	return n

mob/proc/Lunge_toward(mob/m)
	lunge_attacking=1
	lunge_target=m
	attacking=1
	post_lunge=0
	icon_state="Attack"
	distance_lunged=0
	lunge_evaded=0
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
			if(target_loc == m && !isturf(m) && (lunge_evaded || get_abs_angle(src,m) > 55))
				target_loc = m.base_loc()
			dir = dir_holder
			var/old_loc = loc

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
	lunge_evaded=0
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
				for(var/obj/m in t) if(m.attackable)
					target=m
					break
			for(var/mob/m in t) if(m.attackable && m!=src)
				target=m
				break
		//arc attack
		if(!target && !lunge_attacking)
			var/list/sides=list(Get_step(src,turn(dir,45)),Get_step(src,turn(dir,-45)))
			sides=shuffle(sides)
			for(var/turf/t2 in sides)
				for(var/mob/m in t2) if(m.attackable && m!=src)
					target=m
					break
				if(target) break
	if(target) dir=get_dir(src,target)
	if(ismob(target)) Set_flash_step_mob(target)
	return target

proc/Defense_damage_reduction(mob/attacker,mob/defender)
	if(!attacker||!ismob(attacker)) return 1
	return Clamp( (attacker.Off/defender.Def)**defense_damage_reduction_exponent , defense_damage_reduction_cap , 1)

var/give_power_dmg=50

var/new_combat = 0 //do not use new combat system

mob/proc/get_melee_damage(mob/m, count_sword = 1, for_strangle, allow_one_shot = 1, swordMod = 1)

	if(is_saitama) return 1.#INF
	if(m && ismob(m) && m.is_saitama)
		if(!client) return 0
		else return 25

	var/dmg=0
	if(ismob(m))

		//if(m.Class == "Legendary Yasai") count_sword = 0 //LSSJs have forced 0 defense and 2x swords tear them apart but now no matter what they
		//only take normal punch damage from any sword
		//nevermind instead of sword immunity they just get partial immunity
		if(m.Class == "Legendary Yasai") swordMod = 0.40

		var/obj/items/Sword/s = using_sword()
		var/swordless_str = Swordless_strength()

		var/obj/items/Force_Field/FF
		if(s && s.Style=="Energy" && count_sword && !for_strangle)
			for(FF in m.item_list) if(FF.Level>0) break

		dmg = base_melee_damage

		if(lunge_attacking)
			dmg *= 2.5 //compensate for the time it takes to charge up a lunge
			//dmg += base_melee_damage * 0.1 * distance_lunged
		else if(ultra_instinct) dmg /= 1

		//if(power_attacking) dmg*=3.5
		//if(m.power_attacking) dmg/=2.7 //to compensate for all the free hits your going to get while theyre charging up their power attack which is far lower dps
		dmg *= melee_power

		//dmg*=(BP/m.BP)**bp_exponent

		var/thing=1
		if(BP > m.BP) thing = (BP / m.BP)**bp_exponent //FIND: BP EXPONENT
		else thing = (BP / m.BP)**bp_exponent
		dmg*=thing

		if(ShouldOneShot(src, m) && allow_one_shot) dmg *= one_shot_dmg_mult

		if(OP_build()) dmg*=1.3
		if(m.OP_build()) dmg/=1.4

		dmg *= AllAttacksDamageModifiers(m)

		if(m.KO) dmg*=2.5
		dmg*=Defense_damage_reduction(src,m)
		dmg *= GetSpeedDamageDecrease()
		if(m.regenerator_obj) dmg *= regenerator_damage_mod

		//drone teamer debuff system
		var/drone_count=0
		if(drone_module)
			var/list/other_drones=Get_Drones(null,drone_module.Password)
			for(var/mob/d in other_drones) if(d!=src && d.drone_attack_loop && z==d.z && d.Target==m && getdist(src,d)<=15)
				if(!drone_count) dmg/=2.5
				else dmg/=1.1
				drone_count++
				if(drone_count>=10) break
		else if(m.drone_module)
			var/list/other_drones=Get_Drones(null,m.drone_module.Password)
			for(var/mob/d in other_drones) if(d!=m && d.drone_attack_loop && m.z==d.z && d.Target==src && getdist(src,d)<=15)
				if(!drone_count) dmg*=2.5
				else dmg*=1.1
				drone_count++
				if(drone_count>=10) break


		if(m.Giving_Power) dmg*=give_power_dmg

		if(m.fearful||m.Good_attacking_good()) dmg*=m.Fear_dmg_mult()
		if(is_kiting) dmg*=kiting_penalty
		if(m.is_teamer) dmg*=teamer_dmg_mult
		if(is_teamer) dmg/=teamer_dmg_mult

		var/str_mult=swordless_str / m.End
		if(s && count_sword)
			dmg *= 1 + ((s.Damage - 1) * sword_damage_mod * swordMod)
			if(s.is_silver)
				if(m.Vampire||istype(m,/mob/Enemy/Zombie)) dmg*=silver_sword_damage_mult
				else dmg*=silver_sword_damage_penalty
			if(s.Style=="Energy")
				var/resist_n=m.Res
				if(FF) resist_n=Avg_Res()
				str_mult=((swordless_str*0.5)+(Pow*0.5))/resist_n
				dmg *= energy_sword_damage_mod
		if(str_mult>1)
			str_mult=str_mult**superior_strength_exponent
			//to nerf str whores without nerfing durability
			if(for_strangle) str_mult=str_mult**0.3
		else str_mult=str_mult**inferior_strength_exponent
		if(for_strangle) str_mult=Clamp(str_mult,0,strangle_str_mult_cap)
		dmg*=str_mult

		if(m.dir==dir&&!for_strangle) dmg*=hit_from_behind_dmg_mult //hit from behind
		if(using_hokuto()) dmg*=0.3
		if(alignment=="Evil"&&alignment_on) dmg*=villain_damage_penalty
		dmg*=sagas_bonus(src,m)

		if(FF)
			var/ff_dmg=BP*dmg*0.001
			m.Apply_force_field_damage(FF,ff_dmg)
			return 0

	if(isobj(m)||isturf(m))
		if(m.takes_gradual_damage||!client)
			dmg = 2 * (BP/100)
			if(isturf(m)) dmg/=10
		else
			if(WallBreakPower() > m.Health || Epic())
				dmg=1.#INF
				if(isturf(m) && !Is_wall_breaker()) dmg=0
				if(m.Health == 1.#INF) dmg = 0
			else if(!client)
				if(drone_module) dmg=Turf_Strength * BP / 750 //npcs can gradually break anything
				else dmg=Turf_Strength * BP / 7000
	return dmg

mob/proc/WallBreakPower()
	if(is_saitama) return 1.#INF
	//if(BP < Tech_BP * 0.5) return 0

	var/stat_total = (Modless_Gain / 1.5)**2.8

	var/buff_mult=1
	if(current_buff)
		var/obj/Buff/b=current_buff
		buff_mult=(b.buff_str + b.buff_dur + b.buff_for + b.buff_res + b.buff_spd + b.buff_off + b.buff_def) / 7
		if(buff_mult<1) buff_mult=buff_mult**2

	var/n=stat_total * buff_mult * Clamp(regen**0.22,0.6,1.5)
	n*=BP

	return n * 1.3 //arbitrary

mob/proc/teststatrating()
	var/stat_total=(Swordless_strength()+End+Spd+Pow+Res+Off+Def)/7
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
	src<<"[m] can break [Commas(m.WallBreakPower())] BP walls"

mob/proc/Is_wall_breaker()
	if(percent_of_wall_breakers >= 100) return 1
	var/stronger_people=0
	for(var/mob/m in players) if((m.base_bp+m.hbtc_bp)/m.bp_mod>(base_bp+hbtc_bp)/bp_mod) stronger_people++
	if(!stronger_people) return 1
	if((stronger_people / Player_Count()) * 100 >= percent_of_wall_breakers) return
	return 1

mob/Admin5/verb/constant_max_speed()
	if(!IsTens()) return
	const_max_speed=input("set max speed") as num
	if(!const_max_speed_looping) const_max_speed()

var/const_max_speed_looping
var/const_max_speed=1
proc/const_max_speed()
	const_max_speed_looping=1
	while(1)
		Max_Speed=const_max_speed
		sleep(1)
/*mob/Admin5/verb/build_test(mob/m in world)
	if(!IsTens()) return
	m.dir=EAST
	dir=WEST
	var/adj_acc=m.get_melee_accuracy(src)
	if(adj_acc>100) adj_acc=100
	world<<"how [m] performs against [src]:<br>\
	speed ratio: [round(m.speed_ratio(),0.01)]<br>\
	damage: [round(m.get_melee_damage(src),0.01)]%<br>\
	accuracy: [round(adj_acc,0.01)]%<br>\
	hits per second: [round(1/(0.4*m.speed_ratio()),0.01)]<br>\
	dps: [round(m.get_melee_damage(src)*(adj_acc/100)*(1/(0.4*m.speed_ratio())),0.01)]%"
mob/verb/fight(mob/a in world)
	if(!IsTens()) return
	while(!a.KO&&!KO)
		for(var/v in 1 to rand(16,24)) //fight
			a.dir=get_dir(a,src)
			step_towards(a,src)
			a.Melee()
			dir=get_dir(src,a)
			step_towards(src,a)
			Melee()
			sleep(1)
		step_away(a,src)
		step_away(src,a)
		sleep(rand(25,35))*/
//--------

mob/proc/Speed_accuracy_mult(mob/defender)
	var/acc_mult = Clamp((defender.Speed_delay_mult(severity=0.5) / Speed_delay_mult(severity=0.5))**speed_accuracy_mult_exponent, speed_accuracy_mult_min, speed_accuracy_mult_max)
	return acc_mult

//offense vs defense accuracy multiplier
proc/Acc_mult(n=1)
	if(n > 1) n = n ** superior_off_vs_def_mult_exponent
	else n = n ** inferior_off_vs_def_mult_exponent
	return n

mob/proc/DodgeStamCost(mob/attacker)
	var/accuracy = attacker.get_melee_accuracy(src)
	if(accuracy == 0) return 0
	//var/cost = 6 * (attacker.BP / BP)**0.4 * (attacker.Off / Def)**0.5
	var/cost = 11 * (accuracy / base_melee_accuracy)
	if(ultra_instinct) cost /= 4
	return cost

mob/proc/get_melee_accuracy(mob/m)

	if(is_saitama) return 100

	var/accuracy=100
	if(ismob(m))
		accuracy = base_melee_accuracy * (BP/m.BP)**bp_exponent
		accuracy *= Speed_accuracy_mult(defender=m)
		//DEFENSE
		var/off_vs_def = Acc_mult(Off / m.Def)
		//if(off_vs_def<1) off_vs_def=off_vs_def**1.5
		accuracy *= off_vs_def
		//var/def_vs_def=(Def/m.Def)**0.3
		//if(def_vs_def<1) def_vs_def=1
		//accuracy*=def_vs_def

		if(m.dir==dir)
			accuracy*=1.5

		//disabled because too OP for current meta, enable later maybe
		//if(m.standing_powerup) accuracy/=standing_powerup_deflect_mult

		if(m.fearful||m.Good_attacking_good()) accuracy*=m.Fear_dmg_mult()
		if(m.is_teamer) accuracy*=teamer_dmg_mult
		if(is_teamer) accuracy/=teamer_dmg_mult

		if(equipped_sword)
			accuracy /= 1 + (equipped_sword.Damage - 1) * swordDodgeMod
		for(var/obj/Injuries/I in m.injury_list)
			if(I.type==/obj/Injuries/Eye) accuracy*=2
			if(I.type==/obj/Injuries/Arm) accuracy*=1.2
			if(I.type==/obj/Injuries/Leg) accuracy*=1.2

		if(power_attacking || lunge_attacking) accuracy*=1.35

		if(m.precog&&m.precogs&&prob(m.precog_chance)&&m.Ki>m.max_ki*0.2)
			accuracy=0
			m.precogs--
			//m.Ki-=m.Ki/30/m.Eff**0.4

		if(m.Action=="Meditating") accuracy*=10
		if(m.KO || m.KB || m.Frozen || m.regenerator_obj) accuracy=100

	if(OP_build()) accuracy*=2

	if(!ismob(m)) return accuracy
	else
		if(m.evading && !lunge_attacking && !power_attacking) return 0
		return accuracy

mob/proc/get_active_shield() if(shield_obj&&shield_obj.Using) return shield_obj

//some of these are additive some are multiplied in
mob/proc/GetSkillDrain(mod = 1, is_energy = 0)
	var/d = 1

	//if(!is_energy) d += weights()**0.35 - 1 //just didnt care for weights increasing drain anymore
	d += (Anger_mult()**1 - 1) * 0.45

	if(!is_energy) d += (Clamp(str_share()**1, 0.8, 1.#INF) - 1) * 1.4
	else d += (Clamp(frc_share()**1, 0.8, 1.#INF) - 1) * 1.4

	if(ismajin) d += 0.5
	if(ismystic && is_energy) d -= 0.3

	d *= (max_ki / 5000) ** 0.5

	var/obj/items/Sword/s = using_sword()
	if(s)
		d *= 1 + (s.Damage - 1) * sword_drain_mult

	if(ThingC()) d *= 0.5

	return d * mod

mob/var/knockback_on = 1

mob/proc/get_melee_knockback_distance(mob/m)

	//if(ismob(m) && !lunge_attacking && !m.blocking && !power_attacking && !using_giant_form) return 0
	if(!new_combat && !knockback_on) return 0
	if(istype(src,/mob/Splitform)) return 0 //sims shouldnt kb people

	if(auto_train)
		return 0
	//if(m.type==/mob/Splitform && m.Maker==src) return 0
	//if(type==/mob/Splitform && Maker==m) return 0

	if(is_saitama) return 10

	var/dist=0
	if(ismob(m))

		if(istype(m,/mob/Splitform)) return 0

		dist = (BP / m.BP) * 4
		if(distance_lunged) dist *= 2.3
		if(power_attacking) dist *= 2.3

		if(ultra_instinct)
			dist += 3
			if(!ultra_instinct_no_escape_triggered && !distance_lunged && prob(90)) dist = 0
			if(ultra_instinct_no_escape_triggered && dist < 6) dist = 6
			ultra_instinct_no_escape_triggered = 0

		var/obj/items/Sword/s=using_sword()
		var/n
		if(s&&s.Style=="Energy") n=((Swordless_strength()*0.5)+(Pow*0.5))/m.Res
		else n=(Swordless_strength()/m.End)
		if(n>1) n=n**kb_superior_scaling_mod
		else n=n**kb_inferior_scaling_mod
		dist*=n

		if(dist>20) dist=20
		if(dist>1 && hokuto_obj && hokuto_obj.Attacking) dist=1
		//if(using_sword()) dist/=1.3
	return ToOne(dist)

mob/proc/get_melee_sounds(knockback_dist=0)
	var/list/l=list('weakpunch.ogg','weakkick.ogg','mediumpunch.ogg','mediumkick.ogg')
	if(using_sword()) l=list('swordhit.ogg')
	if(knockback_dist >= 12) l=list('strongpunch.ogg','strongkick.ogg')
	if(hokuto_obj&&hokuto_obj.Attacking) l=list('weakpunch.ogg')
	return l

mob/var/tmp/obj/items/Sword/equipped_sword

mob/proc/using_sword()
	if(equipped_sword && equipped_sword.suffix && equipped_sword.loc == src) return equipped_sword

mob/proc/if_target_is_splitform_then_target_attacks_you(mob/target)
	var/mob/Splitform/sf=target
	if(client&&istype(sf,/mob/Splitform)&&!sf.Mode)
		sf.Mode="Attack Target"
		sf.Target=src

mob/proc/zombie_melee_infection(mob/target)

	if(client) return //we have it so players can not infect people by punching them

	if(!Zombie_Virus) return
	if(!ismob(target)) return
	if(using_sword()) return //cant infect those you didnt actually touch
	if(!target.client||target.Safezone||target.Android) return
	if(target.Health < 35) //they have cuts that can be infected if true
		if(!target.Zombie_Virus)
			if(target.client) Infected_players++
			target << "<font size=3><font color=red>[src] just infected you with zombie virus!!"
		target.Zombie_Virus+=1/(target.Zombie_Virus+1)

mob/var/tmp/combo_teleport_loop_running

mob/proc/Combo_recharge()
	set waitfor=0
	if(combo_teleport_loop_running) return
	combo_teleport_loop_running=1
	sleep(Combo_recharge_time())
	available_combos=initial(available_combos)
	combo_teleport_loop_running=0

mob/proc/Combo_recharge_time()
	var/t=52*Speed_delay_mult(severity=0.5)
	return TickMult(t)

mob/proc/Combo_drain(mob/a,mob/d)
	var/drain=(a.Off/d.Def)
	if(drain>1) drain=drain**0.4
	drain=Clamp(drain,1,1.7)

mob/var/tmp/last_combo_teleport=0 //world.time
mob/var/tmp/available_combos=4

mob/proc/combo_teleport(mob/m)

	return

	if(available_combos<=0) return
	if(!Warp||Ki<Zanzoken_Drain()) return
	if(m.z!=z||getdist(src,m)>13) return
	//var/turf/t=Get_step(m,get_dir(m,src))

	var/list/nearby_turfs=new
	for(var/turf/t in oview(1,m)) nearby_turfs+=t
	var/turf/t
	if(nearby_turfs.len) t=pick(nearby_turfs)

	if(t&&isturf(t)&&!t.density&&t.Enter(src)&&!(locate(/mob) in t))
		Ki-=Zanzoken_Drain()
		Zanzoken_Mastery(0.2)
		player_view(7,src)<<sound('teleport.ogg',volume=10)
		flick('Zanzoken.dmi',src)
		SafeTeleport(t)
		last_combo_teleport=world.time
		m.last_combo_teleport=world.time
		available_combos-=Combo_drain(src,m)
		if(available_combos<=0) Combo_recharge()
		dir=get_dir(src,m)
		if(ismob(m))
			//DEFENSE
			var/backhit_chance=defense_auto_combo_backhit_chance*Acc_mult(Off/m.Def)
			if(backhit_chance>defense_auto_combo_backhit_chance)
				backhit_chance=defense_auto_combo_backhit_chance
			if(!prob(backhit_chance)) m.dir=get_dir(m,src)

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

mob/proc/Toggle_strangling()
	if(can_strangle_timer) return
	can_strangle_timer=1
	spawn(20) can_strangle_timer=0
	strangling=!strangling
	if(strangling)

		if(GrabAbsorber())
			overlays -= grab_absorb_overlay
			overlays += grab_absorb_overlay
			player_view(center=src) << "<font color=cyan>[src] grabs [grabbedObject] and begins absorbing their energy!"
		else player_view(center=src)<<"<font color=red>[src] begins strangling [grabbedObject]!"

		while(strangling && grabbedObject)

			if(GrabAbsorber())
				var/ki_drain = grabbedObject.max_ki / 70
				if(!grabbedObject.KO) ki_drain /= 4
				if(ki_drain > grabbedObject.Ki) ki_drain = grabbedObject.Ki
				grabbedObject.Ki -= ki_drain
				if(Ki < max_ki * 1.2)
					Ki += ki_drain

			var/dmg=get_melee_damage(grabbedObject,count_sword=0,for_strangle=1)
			dmg/=6

			if(GrabAbsorber()) dmg *= 0.5

			dmg*=grab_damage_mod
			if(grabbedObject.KO) dmg*=5
			if(grabbedObject.Race=="Majin") dmg=0

			grabbedObject.TakeDamage(dmg)

			if(GrabAbsorber())
				if(Health < 100)
					if(grabbedObject.client) Health += dmg
					if(Health > 100) Health = 100

			if(grabbedObject.Health<0)
				if(!grabbedObject.KO) grabbedObject.KO(src)
				else if(Fatal) grabbedObject.Death(src)
			sleep(TickMult(5))
		strangling=0
		overlays -= grab_absorb_overlay
	else
		player_view(center=src)<<"[src] stops strangling [grabbedObject]"
		overlays -= grab_absorb_overlay

mob/proc/Get_melee_delay(mult=1,injuries_matter=1)
	var/injury_mult=1
	if(injuries_matter) for(var/obj/Injuries/i in injury_list)
		if(i.type==/obj/Injuries/Arm || i.type==/obj/Injuries/Leg) injury_mult+=0.25
	//if(using_giant_form) mult+=1
	var/delay = mult * base_melee_delay * injury_mult * Speed_delay_mult(severity = melee_delay_severity)

	var/obj/items/Sword/s = using_sword()
	if(s)
		delay *= 1 + (s.Damage - 1) * sword_refire_mod

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

mob/proc/Melee(obj/O, from_auto_attack, force_power_attack, lunge_allowed = 0)
	set waitfor=0

	if(!from_auto_attack&&grabbedObject&&ismob(grabbedObject)&&!KO) Toggle_strangling()

	var/attempt_to_power_attack=(!from_auto_attack && same_loc_after_move && same_dir_after_move && Trying_to_power_attack() && Can_power_attack())
	if(!attempt_to_power_attack) attempt_to_power_attack=force_power_attack
	if(power_attacking) attempt_to_power_attack=0 //not sure but i put this here to try to stop the bug where people can continue meleeing while charging the power attack up

	if(!new_combat)
		attempt_to_power_attack=0
		force_power_attack=0

	if(!can_melee(trying_to_power_attack=attempt_to_power_attack)) return

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

	if(new_combat && (force_power_attack || (target && !lunge_attacking && same_loc_after_move && same_dir_after_move && !from_auto_attack && \
	Trying_to_power_attack() && Can_power_attack())))
		melee_code=world.time
		power_attacking=1
		Do_lunge_drawback_animation()
		sleep(Power_attack_chargeup_time(target))
		power_attack_meter=0
		if(target && ismob(target) && target.Flying) Fly()

	/*//this block of code makes the person you are attacking get the first hit if their speed is superior to yours
	if(target && ismob(target) && target!=src)
		if(target.Auto_Attack || lunge_attacking || world.time-target.last_attacked_mob_time<45)
			//var/outspeed_prob = Speed_delay_mult(severity=0.5) - target.Speed_delay_mult(severity=0.5)
			//outspeed_prob = 50 + (outspeed_prob * 50)
			//if(prob(outspeed_prob)) target.Melee()
			if(target.Speed_delay_mult()<Speed_delay_mult()) target.Melee()*/

	//this block of code means that a lunge attacker gets the first hit in a melee if they are the fastest
	if(target && ismob(target) && target!=src)
		if(target.lunge_attacking && !target.post_lunge)
			if(lunge_attacking && !post_lunge)
				if(target.Speed_delay_mult() > Speed_delay_mult()) sleep(TickMult(2))

	if(!target || getdist(src,target)>1)
		Reset_melee()
		return

	if(target==chaser)
		last_damaged_chaser=0
		Remove_fear()

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

	var/dmg = get_melee_damage(target)
	var/accuracy = get_melee_accuracy(target)
	if(!dmg) accuracy=100
	var/delay = Get_melee_delay()
	var/obj/Shield/ki_shield
	if(ismob(target)) ki_shield=target.get_active_shield()
	var/knockback=get_melee_knockback_distance(target)
	//if(knockback) dmg*=1+(knockback/10)
	var/omega_kb_used = 1
	if(Omega_KB() && !tournament_override(fighters_can=0))
		knockback=Get_Omega_KB()
		omega_kb_used = 1
	if(!dmg)
		knockback=0
	last_melee_attack = world.time

	if(ismob(target) && target.blocking)
		target.dir=get_dir(target,src)
		knockback=0
		var/evasion_gain=1
		if(lunge_attacking)
			evasion_gain*=7
			dmg*=0.23
		else dmg*=0.23
		if(power_attacking) dmg=0
		target.Fill_evade_meter(src,evasion_gain)

		//if you blocked a power attack, counter attack with a fully charged power attack automatically
		if(power_attacking) spawn if(target)
			target.blocking=0
			target.evading=0
			target.Reset_melee()
			target.power_attack_meter=1
			target.dir=get_dir(target,src)
			target.Melee(force_power_attack=1)

	if(ismob(target) && target.Safezone)
		knockback=0
	var/list/sounds=get_melee_sounds(knockback)

	if(client)
		Ki -= energy_drain
		if(ultra_instinct)
			var/stam_drain = 8
			if(lunge_attacking) stam_drain *= 3
			AddStamina(-stam_drain)

	if(!using_hokuto() && !lunge_attacking)
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
	training_period(target)

	if(ismob(target) && ki_shield)
		var/shield_drain = dmg * target.ShieldDamageReduction() * (target.max_ki/100/(target.Eff**shield_exponent))*target.Generator_reduction(is_melee=1)
		if(target.Ki>=shield_drain)
			target.Ki-=shield_drain
			Play_Melee_Sound(sound_range=10,origin=target,sound_file=pick('meleemiss1.ogg',\
			'meleemiss2.ogg','meleemiss3.ogg'),sound_volume=20)
			if(knockback)
				if(prob(30)) Make_Shockwave(target,sw_icon_size=pick(64,128))
				Melee_Shockwave_Repel(target)
				target.Knockback(src,ToOne(knockback/2), omega_kb = omega_kb_used)
				if(target) combo_teleport(target)
			return

	if(ismob(target))
		target.SetLastAttackedTime(src)
		last_attacked_mob_time=world.time

	//now that we have made it so you can only dodge if you are NOT attacking, you land all hits when they are not in dodge mode or
	//you miss all hits if they are. no more luck involved, only if they can dodge or can not dodge currently.
	if(dodging_mode == MANUAL_DODGE && ismob(target))
		if(target.CanMeleeDodge(src)) accuracy = 0
		else accuracy = 100

	//actually hit them
	var/hit_landed = (prob(accuracy) || (ismob(target) && !target.CanMeleeDodge(src)) || (ismob(target) && target.evade_meter <= 0))

	//to make dodge rate 100% so long as they have yellow bar
	//if(ismob(target) && target.CanMeleeDodge(src)) hit_landed = 0

	if(hit_landed)
		if(ismob(target) && Is_Darius()) target.Apply_Bleed()
		Add_Hokuto_Shinken_Energy(target)
		zombie_melee_infection(target)
		if(using_sword()&&ismob(target)) target.check_lose_tail(dmg,src)
		Play_Melee_Sound(sound_range=10,origin=src,sound_file=pick(sounds),sound_volume=20)
		if(lunge_attacking) BigCrater(pos = target.base_loc(), minRangeFromOtherCraters = 3)

		if(ismob(target))
			if(knockback)
				if(prob(33)) Make_Shockwave(target,sw_icon_size=pick(128,256))
				if(target) Melee_Shockwave_Repel(target)
				target.Knockback(src,knockback,from_lunge=lunge_attacking, omega_kb = omega_kb_used)
				if(!target)
					Reset_melee()
					return
				combo_teleport(target)
			//else
				//if(prob(30)) Make_Shockwave(target,sw_icon_size=pick(64,128))
				//if(target) Melee_Shockwave_Repel(target)

			MeleeInjureSelfCheck(target)

			if(is_saitama)
				target.SaitamaBloodEffect()
				target.Death(src,Force_Death=1,lose_hero=0,lose_immortality=0)
			else
				var/obj/items/Sword/s = using_sword()
				if(s)
					var/bleedDmg = dmg * swordBleedDmg
					dmg -= bleedDmg
					target.BleedDamage(bleedDmg)

				target.TakeDamage(dmg)

				//if a Zombie or infected player hits a dead body it too becomes infected and turns into a zombie
				InfectedPlayerHitDeadBodyItBecomesZombie(target)

				var/henchie = Villain_league_damage_multiplier(target) - 1
				if(!both_good(src,target) && !target.Dead && (ShouldOneShot(src, target) || henchie) && Fatal && target.Health<=0 && client)
					if(!Same_league_cant_kill(src,target))
						target.SaitamaBloodEffect()
						target.Death(src)
				else
					if(!target.client && target.Health <= 0 && !istype(target, /mob/new_troll)) target.Death(src)
					else
						if(!target.KO && target.Health <= 0) target.KO(src)
						else if(target.KO && Fatal && target.Health <= 0) target.Death(src)
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

			if(is_saitama) spawn t.SaitamaTurfHit(dir)
	else
		last_combo_teleport=0
		target.last_combo_teleport=0
		target.MeleeAutoDodge(src)
		if(target.evading) //only drain from manual evasions
			target.Drain_evade_meter(src)
		target.Fill_power_attack_meter()

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
	if(dodging_mode == MANUAL_DODGE)
		AddStamina(-DodgeStamCost(attacker))
	else
		Ki -= 6

	Play_Melee_Sound(sound_range=10,origin = src,sound_file=pick('meleemiss1.ogg',\
		'meleemiss2.ogg','meleemiss3.ogg'),sound_volume=20)
	Dodge_animation()
	dir = get_dir(src, attacker)

mob/proc/CanMeleeDodge(mob/attacker)
	if(!client) return //quick dirty fix to stop dead bodies from dodging but it affects all npcs oh well tho
	if(KO) return

	if(dodging_mode == MANUAL_DODGE)
		if(stamina < DodgeStamCost(attacker)) return
		if(!ultra_instinct)
			if(world.time - last_input_move < 3) return
			if(world.time - last_melee_attack < 5) return
			if(attacking) return //the best we can do for detecting ki attacks right now as they do not seem to have a "last_ki_attack" var

	//i turned this off so we have 360 degree dodging now
	//if(!(get_dir(src, attacker) in list(dir, turn(dir,45), turn(dir,-45)))) return

	return 1

mob/proc/CanBlastDeflect(mob/attacker)
	if(!client) return //quick dirty fix to stop dead bodies from dodging but it affects all npcs oh well tho
	if(KO) return

	if(dodging_mode == MANUAL_DODGE)
		//if(stamina < DodgeStamCost(attacker)) return
		if(!ultra_instinct)
			if(world.time - last_input_move < 3) return
			if(world.time - last_melee_attack < 5) return
			if(attacking) return //the best we can do for detecting ki attacks right now as they do not seem to have a "last_ki_attack" var

	//i turned this off so we have 360 degree dodging now
	//if(!(get_dir(src, attacker) in list(dir, turn(dir,45), turn(dir,-45)))) return

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

	//var/area/a=origin.get_area()
	//for(var/mob/m in a.player_list) if(m.client&&getdist(m,origin)<sound_range)
		//m<<sound(sound_file,volume=sound_volume)

mob/proc/Melee_Shockwave_Repel(mob/target) //target = the person you just attacked, so we can exclude them from the repel
	set waitfor=0
	if(!knockback_on) return //less annoying when trying to multi spar
	if(!client || !target.client)
		return //because npc fighting causing shockwaves was incredibly annoying when sim sparring in the gym or when teams
		//of players are trying to fight a hoarde of zombies
	if(current_area) for(var/mob/sw_mob in current_area.player_list)
		if(!sw_mob.Giving_Power && sw_mob != src && sw_mob != target && getdist(sw_mob,src) <= 4 && viewable(src,sw_mob))
			sw_mob.MeleeRepelMob(src, 1.5 * get_melee_knockback_distance(sw_mob))

mob/proc
	MeleeRepelMob(mob/m, kb_pow = 1)
		set waitfor=0
		Knockback(m, kb_pow)
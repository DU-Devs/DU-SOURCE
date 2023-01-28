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
		if(!target)
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
mob/proc/Swordless_strength()
	var/n=Str
	var/obj/items/Sword/s=using_sword()
	if(s) n/=s.Damage
	return n
proc/Defense_damage_reduction(mob/attacker,mob/defender)
	if(!attacker||!ismob(attacker)) return 1
	return Clamp( (attacker.Off/defender.Def)**defense_damage_reduction_exponent , defense_damage_reduction_cap , 1)

var/give_power_dmg=5

mob/proc/get_melee_damage(mob/m,count_sword=1,for_strangle)
	var/dmg=0
	if(ismob(m))
		var/obj/items/Sword/s=using_sword()
		var/swordless_str=Swordless_strength()

		var/obj/items/Force_Field/FF
		if(s && s.Style=="Energy" && count_sword && !for_strangle)
			for(FF in m.item_list) if(FF.Level>0) break

		dmg=8.5*melee_power
		dmg*=(BP/m.BP)**0.5

		if(OP_build()) dmg*=1.3
		if(m.OP_build()) dmg/=1.4

		if(m.KO) dmg*=2.5
		dmg*=Defense_damage_reduction(src,m)
		dmg*=Slowness_damage_mult()

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

		var/str_mult=swordless_str/m.End
		if(s && count_sword)
			dmg*=1 + ((s.Damage-1) * sword_damage_mod)
			if(s.is_silver)
				if(m.Vampire||istype(m,/mob/Enemy/Zombie)) dmg*=silver_sword_damage_mult
				else dmg*=silver_sword_damage_penalty
			if(s.Style=="Energy")
				var/resist_n=m.Res
				if(FF) resist_n=Avg_Res()
				str_mult=((swordless_str*0.5)+(Pow*0.5))/resist_n
				dmg*=energy_sword_damage_mod
		if(str_mult>1)
			str_mult=str_mult**superior_strength_exponent
			//to nerf str whores without nerfing durability
			if(for_strangle) str_mult=str_mult**0.85
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
			if(Wall_breaking_power()>m.Health||Epic())
				dmg=1.#INF
				if(isturf(m)&&!Is_wall_breaker()) dmg=0
			else if(!client)
				if(drone_module) dmg=Turf_Strength * BP / 750 //npcs can gradually break anything
				else dmg=Turf_Strength * BP / 7000
	return dmg

mob/proc/Wall_breaking_power()

	var/stat_total=(Modless_Gain/1.5)**2.8

	var/buff_mult=1
	if(current_buff)
		var/obj/Buff/b=current_buff
		buff_mult=(b.buff_str + b.buff_dur + b.buff_for + b.buff_res + b.buff_spd + b.buff_off + b.buff_def) / 7
		if(buff_mult<1) buff_mult=buff_mult**2

	var/n=stat_total * buff_mult * Clamp(regen**0.22,0.6,1.5)
	n*=BP
	return n/2

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
	src<<"[m] can break [Commas(m.Wall_breaking_power())] BP walls"

mob/proc/Is_wall_breaker()
	if(percent_of_wall_breakers>=100) return 1
	var/stronger_people=0
	for(var/mob/m in players) if((m.base_bp+m.hbtc_bp)/m.bp_mod>(base_bp+hbtc_bp)/bp_mod) stronger_people++
	if(!stronger_people) return 1
	if((stronger_people/Player_Count())*100>=percent_of_wall_breakers) return
	return 1

//testing
mob/Admin5/verb/constant_max_speed()
	if(!Is_Tens()) return
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
	if(!Is_Tens()) return
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
	if(!Is_Tens()) return
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

	return 1

	var/acc_mult=Clamp((defender.Speed_delay_mult(severity=0.5)/Speed_delay_mult(severity=0.5))**speed_accuracy_mult_exponent,speed_accuracy_mult_min,speed_accuracy_mult_max)
	return acc_mult

//offense vs defense accuracy multiplier
proc/Acc_mult(n=1)
	if(n>1) n=n**superior_off_vs_def_mult_exponent
	else n=n**inferior_off_vs_def_mult_exponent
	return n

mob/proc/get_melee_accuracy(mob/m)
	var/accuracy=100
	if(ismob(m))
		accuracy=base_melee_accuracy*sqrt(BP/m.BP)
		accuracy*=Speed_accuracy_mult(defender=m)
		//DEFENSE
		var/off_vs_def=Acc_mult(Off/m.Def)
		//if(off_vs_def<1) off_vs_def=off_vs_def**1.5
		accuracy*=off_vs_def
		//var/def_vs_def=(Def/m.Def)**0.3
		//if(def_vs_def<1) def_vs_def=1
		//accuracy*=def_vs_def

		if(m.dir==dir)
			accuracy*=1.5

		if(m.standing_powerup) accuracy/=standing_powerup_deflect_mult

		if(m.fearful||m.Good_attacking_good()) accuracy*=m.Fear_dmg_mult()
		if(m.is_teamer) accuracy*=teamer_dmg_mult
		if(is_teamer) accuracy/=teamer_dmg_mult

		if(equipped_sword) accuracy/=equipped_sword.Damage
		for(var/obj/Injuries/I in m.injury_list)
			if(I.type==/obj/Injuries/Eye) accuracy*=2
			if(I.type==/obj/Injuries/Arm) accuracy*=1.2
			if(I.type==/obj/Injuries/Leg) accuracy*=1.2
		if(m.precog&&m.precogs&&prob(m.precog_chance)&&m.Ki>m.max_ki*0.2)
			accuracy=0
			m.precogs--
			//m.Ki-=m.Ki/30/m.Eff**0.4
		if(m.Action=="Meditating") accuracy*=10
		if(m.KO||m.Frozen) accuracy=100

	if(OP_build()) accuracy*=2

	return accuracy

mob/proc/get_active_shield() if(shield_obj&&shield_obj.Using) return shield_obj

mob/proc/get_melee_drain()
	var/str_drain=str_share()**1.5
	if(str_drain<0.5) str_drain=0.5
	var/drain=7.5 * weights()**0.5 * (max_ki/4000)**0.5 * str_drain
	if(ismajin) drain*=1.5
	drain*=Anger_mult()**1.3
	//if(Warp) drain*=2.5 //combos on
	return drain

mob/proc/get_melee_knockback_distance(mob/m)

	if(auto_train) return 0
	if(m.type==/mob/Splitform && m.Maker==src) return 0
	if(type==/mob/Splitform && Maker==m) return 0

	var/dist=0
	if(prob(KB_On)&&ismob(m))
		dist=(BP/m.BP)*3.5

		var/obj/items/Sword/s=using_sword()
		var/n
		if(s&&s.Style=="Energy") n=((Swordless_strength()*0.5)+(Pow*0.5))/m.Res
		else n=(Swordless_strength()/m.End)
		if(n>1) n=n**kb_superior_scaling_mod
		else n=n**kb_inferior_scaling_mod
		dist*=n

		if(dist>20) dist=20
		if(dist>1&&hokuto_obj&&hokuto_obj.Attacking) dist=1
		//if(using_sword()) dist/=1.3
	return To_multiple_of_one(dist)

mob/proc/get_melee_sounds(knockback_dist=0)
	var/list/l=list('weakpunch.ogg','weakkick.ogg','mediumpunch.ogg','mediumkick.ogg')
	if(using_sword()) l=list('swordhit.ogg')
	if(knockback_dist>=5) l=list('strongpunch.ogg','strongkick.ogg')
	if(hokuto_obj&&hokuto_obj.Attacking) l=list('weakpunch.ogg')
	return l

mob/var/tmp/obj/items/Sword/equipped_sword

mob/proc/using_sword()
	if(equipped_sword&&equipped_sword.suffix&&equipped_sword.loc==src) return equipped_sword

mob/proc/if_target_is_splitform_then_target_attacks_you(mob/target)
	var/mob/Splitform/sf=target
	if(client&&istype(sf,/mob/Splitform)&&!sf.Mode)
		sf.Mode="Attack Target"
		sf.Target=src

mob/proc/zombie_melee_infection(mob/target)
	if(!Zombie_Virus) return
	if(!ismob(target)) return
	if(using_sword()) return //cant infect those you didnt actually touch
	if(!target.client||target.Safezone||target.Android) return
	if(target.Health<58) //they have cuts that can be infected if true
		if(!target.Zombie_Virus)
			if(target.client) Infected_players++
			//target<<"[src] just infected you with zombie virus!!"
		target.Zombie_Virus+=1/(target.Zombie_Virus+1)

mob/var/tmp/combo_teleport_loop_running

mob/proc/Combo_recharge() spawn
	if(combo_teleport_loop_running) return
	combo_teleport_loop_running=1
	sleep(Combo_recharge_time())
	available_combos=initial(available_combos)
	combo_teleport_loop_running=0

mob/proc/Combo_recharge_time()
	var/t=52*Speed_delay_mult(severity=0.5)
	return To_tick_lag_multiple(t)

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
		loc=t
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

mob/proc/if_target_is_npc_target_attacks_you(mob/target) spawn if(target)
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
		t.attacker=src
		t.end_combat=30
mob/var
	tmp/strangling
	tmp/can_strangle_timer=0
mob/proc/Toggle_strangling()
	if(can_strangle_timer) return
	can_strangle_timer=1
	spawn(20) can_strangle_timer=0
	strangling=!strangling
	if(strangling)
		player_view(center=src)<<"<font color=red>[src] begins strangling [grabbed_mob]!"
		while(strangling&&grabbed_mob)
			var/dmg=get_melee_damage(grabbed_mob,count_sword=0,for_strangle=1)
			dmg/=3
			if(grabbed_mob.Race=="Majin") dmg=0
			grabbed_mob.Health-=dmg
			if(grabbed_mob.Health<0)
				if(!grabbed_mob.KO) grabbed_mob.KO(src)
				else if(Fatal) grabbed_mob.Death(src)
			sleep(5)
		strangling=0
	else player_view(center=src)<<"[src] stops strangling [grabbed_mob]"

mob/proc/Slowness_damage_mult()
	return 1 + (0.2 * Speed_delay_mult(severity=melee_delay_severity))

var
	base_melee_delay=6
	melee_delay_severity=0.56

mob/proc/Get_melee_delay(injuries_matter=1)
	var/injury_mult=1
	if(injuries_matter) for(var/obj/Injuries/i in injury_list)
		if(i.type==/obj/Injuries/Arm || i.type==/obj/Injuries/Leg) injury_mult+=0.25
	return To_tick_lag_multiple(base_melee_delay * injury_mult * Speed_delay_mult(severity=melee_delay_severity))

mob/var/tmp/last_attacked_mob_time=0

mob/proc/Melee(obj/O,from_auto_attack)

	if(!from_auto_attack&&grabbed_mob&&ismob(grabbed_mob)&&!KO) Toggle_strangling()

	if(!can_melee()) return
	var/mob/target=find_melee_target(O,from_auto_attack)

	if(target && ismob(target) && target!=src)
		if(target.Auto_Attack || world.time-target.last_attacked_mob_time<45)
			//var/outspeed_prob = Speed_delay_mult(severity=0.5) - target.Speed_delay_mult(severity=0.5)
			//outspeed_prob = 50 + (outspeed_prob * 50)
			//if(prob(outspeed_prob)) target.Melee()
			if(target.Speed_delay_mult()<Speed_delay_mult()) target.Melee()

	if(!target || getdist(src,target)>1) return
	if(target==chaser)
		last_damaged_chaser=0
		Remove_fear()
	if(client && ismob(target) && target.Flying&&!Flying) return
	var/energy_drain=get_melee_drain()
	if(energy_drain>Ki) return //too tired to attack
	var/dmg=get_melee_damage(target)
	var/accuracy=get_melee_accuracy(target)
	if(!dmg) accuracy=100
	var/delay=Get_melee_delay()
	var/obj/Shield/ki_shield
	if(ismob(target)) ki_shield=target.get_active_shield()
	var/knockback=get_melee_knockback_distance(target)
	//if(knockback) dmg*=1+(knockback/10)
	if(Omega_KB() && !tournament_override(fighters_can=0)) knockback=Get_Omega_KB()
	if(!dmg) knockback=0
	if(ismob(target) && target.Safezone) knockback=0
	var/list/sounds=get_melee_sounds(knockback)
	if(client) Ki-=energy_drain
	if(!using_hokuto())
		attacking=1
		spawn(delay) if(attacking) attacking=0
	if(target&&ismob(target)) target.set_opponent(src)
	melee_graphics()
	spawn if(target&&ismob(target)&&target.drone_module)
		if(target.drone_module&&drone_module&&target.drone_module.Password==drone_module.Password)
		else target.Drone_Attack(src,lethal=1)
	if_target_is_splitform_then_target_attacks_you(target)
	training_period(target)
	if(ismob(target)&&ki_shield)
		var/shield_drain=dmg*shield_reduction*(target.max_ki/100/(target.Eff**shield_exponent))*target.Generator_reduction(is_melee=1)
		if(target.Ki>=shield_drain)
			target.Ki-=shield_drain
			Play_Melee_Sound(sound_range=10,origin=target,sound_file=pick('meleemiss1.ogg',\
			'meleemiss2.ogg','meleemiss3.ogg'),sound_volume=20)
			if(knockback)
				spawn if(src)
					Make_Shockwave(src,sw_icon_size=pick(64,128))
					Melee_Shockwave_Repel(target)
				target.Knockback(src,To_multiple_of_one(knockback/2))
				if(target) combo_teleport(target)
			return

	if(ismob(target))
		target.last_attacked_time=world.time
		last_attacked_mob_time=world.time

	if(prob(accuracy))
		if(Is_Darius()) target.Apply_Bleed()
		Add_Hokuto_Shinken_Energy(target)
		zombie_melee_infection(target)
		if(using_sword()&&ismob(target)) target.check_lose_tail(dmg,src)
		Play_Melee_Sound(sound_range=10,origin=src,sound_file=pick(sounds),sound_volume=20)
		if(knockback&&ismob(target))
			spawn if(src)
				Make_Shockwave(src,sw_icon_size=pick(128,256))
				Melee_Shockwave_Repel(target)
			target.Knockback(src,knockback)
			if(!target) return
			combo_teleport(target)
		if(ismob(target))
			//if(target.KO&&dmg>20) dmg=20 //no less than 5 hits to kill a ko person
			target.Health-=dmg
			if(!target.client&&target.Health<=0&&!target.battle_test) target.Death(src)
			else
				if(!target.KO&&target.Health<=0) target.KO(src)
				else if(target.KO&&Fatal&&target.Health<=0) target.Death(src)
		if(isobj(target))
			target.Health-=dmg
			if(target.Health<=0)
				Small_crater(target.loc)
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
		Play_Melee_Sound(sound_range=10,origin=target,sound_file=pick('meleemiss1.ogg',\
		'meleemiss2.ogg','meleemiss3.ogg'),sound_volume=20)
		target.Dodge_animation()
		target.dir=get_dir(target,src)
	if_target_is_npc_target_attacks_you(target)



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

mob/proc/Melee_Shockwave_Repel(mob/target)

	return

	if(current_area) for(var/mob/sw_mob in current_area.player_list)
		if(!sw_mob.Giving_Power&&sw_mob!=src&&sw_mob!=target&&getdist(sw_mob,src)<=5&&viewable(src,sw_mob))
			spawn if(sw_mob) sw_mob.Knockback(src,1.3*get_melee_knockback_distance(sw_mob))
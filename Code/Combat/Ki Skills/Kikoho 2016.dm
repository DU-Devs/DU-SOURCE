var
	kikoho_angle_limit = 67
	kikoho_target_dist = 11

mob/proc/IsValidKikohoTarget(mob/m)
	if(m && ismob(m) && m!=src && get_dist(src,m)>0 && get_abs_angle(src,m) < kikoho_angle_limit)
		if(At_forward_half(m) && viewable(src,m, kikoho_target_dist))
			if(m.type != /mob/Body)
				return 1

mob/proc/GetKikohoTarget()
	var/list/targets = FindTargets(dir_angle=dir, angle_limit = kikoho_angle_limit, max_dist = kikoho_target_dist, prefer_auto_target=1)
	if(!targets) return
	for(var/mob/m in targets) if(!IsValidKikohoTarget(m)) targets-=m
	if(targets.len) return targets[1]

obj/Attacks/Kikoho
	Cost_To_Learn=0
	Teach_Timer=1
	student_point_cost = 50
	Drain=100
	desc="This attack damages and stuns and grounds whoever it hits. It is an invisible projectile that hits instantly and can not be \
	deflected, and can be spammed repeatedly. It damages the user over time stuns them also, and can kill them. This attack is most powerful \
	when a human uses it. It can not kill people with death regeneration. It can be countered by anything that knocks the person firing it away, \
	or time freezing them."
	repeat_macro=0

	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Kikoho()

	verb/Kikoho()
		//set category="Skills"
		usr.FireKikoho(src)

mob/var
	kikoho_damage = 0 //kikoho's damage over time to the user

	tmp
		kikoho_loop

var
	kikoho_self_dmg = 24 //% per shot over time
	list/kikoho_craters = new

proc
	KikohoCrater(turf/t)
		if(!isturf(t)) t = t.base_loc()

		var/obj/Kikoho_Effects/Kikoho_Crater/kc
		for(kc in kikoho_craters) if(kc.z == t.z && getdist(kc,t) < 5) break
		if(!kc) kc = new(t)
		else kc.loc = t

		var
			max_size = 2
		kc.crater_size = kc.crater_size + (max_size - kc.crater_size) * 0.18
		animate(kc, transform = matrix() * kc.crater_size, time = 4)

	KikohoExplosion(turf/t)
		if(!isturf(t)) t = t.base_loc()
		new/obj/Kikoho_Effects/Kikoho_Explosion(t)

	KikohoDust(turf/t)
		set waitfor=0
		if(!isturf(t)) t = t.base_loc()
		sleep(4)
		new/obj/Kikoho_Effects/Kikoho_Dust(t)

	KikohoRocks(turf/t)
		set waitfor=0
		if(!isturf(t)) t = t.base_loc()
		for(var/v in 1 to 18)
			new/obj/Kikoho_Effects/Kikoho_Rock(t)

mob/proc
	StopBeaming()
		set waitfor=0
		for(var/obj/Attacks/A in src) if(A.Wave && (A.charging || A.streaming))
			if(A.charging) Beam_Macro(A)
			sleep(2)
			if(A.streaming) Beam_Macro(A)

	//currently this only stops beams because we didnt feel like coding to stop all attacks
	CancelAllAttacks()
		StopBeaming()

	GetHitByKikoho(mob/a) //a = attacker
		set waitfor=0
		Land()
		if(BP < a.BP * 1.35) CancelAllAttacks()
		if(getdist(src,a) < 6) step(src,get_dir(a,src))

		icon_state = "KO"
		spawn(3) if(src)
			if(!KO)
				if(Flying) icon_state = "Flight"
				else icon_state = ""
			else icon_state = "KO"

		KikohoExplosion(src)
		KikohoDust(src)
		KikohoRocks(src)
		KikohoCrater(src)
		Make_Shockwave(src,sw_icon_size=256)

		var/stun = 16
		ApplyStun(time = stun, no_immunity = 1, stun_power = 6)
		a.ApplyStun(time = stun, no_immunity = 1, stun_power = 6)

		var/dmg = a.KikohoDamageTo(src)
		TakeDamage(dmg)
		if(a.Fatal && Health <= 0) Death(a)

	KikohoKnockAwayNonTargets(mob/t) //t = target, usr = firer
		set waitfor=0
		for(var/mob/m in player_view(10,t)) if(m != t && m != usr)
			var
				kb_dist = 10 - get_dist(m,t)
			if(kb_dist > 0)
				spawn if(m) m.Knockback(t, 10)

	KikohoDamageLoop()
		set waitfor=0
		if(kikoho_loop) return
		kikoho_loop=1

		while(kikoho_damage > 0)
			var
				dmg_min = 2 //minimum damage per second
				dmg = dmg_min * RegenMod() * (kikoho_damage / kikoho_self_dmg)
			if(dmg < dmg_min) dmg = dmg_min
			Health -= dmg
			kikoho_damage -= dmg
			if(KO && Health <= 0) Death("kikoho",lose_hero=0,lose_immortality=0)
			sleep(10)

		kikoho_loop=0

	KikohoDamageTo(mob/m)
		var/dmg = 27 * (BP / m.BP)**bp_exponent * (Pow / m.Res)**0.3
		if(Race == "Human") dmg *= 1.5
		return dmg

	FireKikoho(obj/Attacks/Kikoho/k)
		if(cant_blast()) return
		if(Ki < GetSkillDrain(mod = k.Drain, is_energy = 1)) return

		var/target_was_hit
		var/mob/m = GetKikohoTarget()
		if(!m)
			src << "You must have a proper target in front of you"
			return

		attacking=3
		k.charging=1
		KikohoAtmosphereEffect()
		KikohoChargeupEffect(grow_til = 0.6) //THIS AND THE FIRST sleep(KikohoRefire(0.7)) MUST HAVE MATCHING NUMBERS!!!!!!!!!!!!! (OR CLOSE TO IT)

		var
			chargeup_time = KikohoRefire(0.5)
			elapsed_time = 0
			interrupted
			turf/start_loc = loc

		while(elapsed_time < chargeup_time)
			elapsed_time++
			if(KB || Frozen || loc != start_loc)
				interrupted=1
				ApplyStun(time = 15, no_immunity = 1, stun_power = 6)
				break
			else sleep(TickMult(1))

		if(!interrupted)
			m = GetKikohoTarget()
			if(m && !cant_blast(ignore_attack_check = 1))
				dir = get_dir(src,m)
				Ki -= GetSkillDrain(mod = k.Drain, is_energy = 1)
				k.Skill_Increase(1,src)

				target_was_hit = 1
				player_view(20,src) << sound('wallhit.ogg',volume=40)
				m.GetHitByKikoho(src)
				KikohoKnockAwayNonTargets(m)

				kikoho_damage += kikoho_self_dmg
				KikohoDamageLoop()

		if(target_was_hit)
			sleep(KikohoRefire(0.5)) //ALL INSTANCES MUST ADD UP TO 1 IN THIS PROC!!!!!!!!!!!!!!!!!!!!!!!!
			if(interrupted) sleep(KikohoRefire(2))

		attacking=0
		k.charging=0

	KikohoRefire(mult = 1)
		return mult * (5 + (11 * Speed_delay_mult(severity=0.4)))

	KikohoAtmosphereEffect()
		set waitfor=0
		for(var/mob/m in player_view(20,src))
			m.KikohoOrangeAtmosphere()

	KikohoChargeupEffect(grow_til = 0.5)
		set waitfor=0

		var/obj/Kikoho_Effects/Kikoho_Flash/f = new(loc)
		f.alpha = 0
		f.transform *= 4

		var/t = KikohoRefire()

		animate(f, transform = matrix() * 0.01, alpha = 255, time = t * grow_til, easing = SINE_EASING)
		sleep(t * grow_til)
		//animate(f, transform = matrix() * 0.01, time = t * (1 - grow_til))
		sleep(t * (1 - grow_til))
		del(f)

	KikohoOrangeAtmosphere()
		set waitfor=0
		if(!client) return
		animate(client, color = rgb(255,160,0), time = 15)
		sleep(15)
		if(client)
			animate(client, color = rgb(255,255,255), time = 60)

obj/Kikoho_Effects
	density=0
	Grabbable=0
	Health=1.#INF
	Dead_Zone_Immune=1
	can_blueprint=0
	Cloakable=0
	Knockable=0
	Savable=0
	Nukable=0

	Kikoho_Crater
		icon = 'kikoho crater.dmi'

		var
			delete_time = 0 //the world.time it will delete itself
			crater_size = 0.01

		New()
			kikoho_craters += src
			CenterIcon(src)
			transform = matrix() * crater_size
			KikohoCraterDeleteCheck()

		Del()
			kikoho_craters -= src
			. = ..()

		proc
			KikohoCraterDeleteCheck()
				set waitfor=0
				sleep(10)
				if(!delete_time) delete_time = world.time + 600
				while(src)
					if(world.time > delete_time) del(src)
					sleep(100)

	Kikoho_Flash
		icon = 'Sunfield.dmi'
		layer = MOB_LAYER+2
		blend_mode = BLEND_ADD

		New()
			CenterIcon(src)
			transform = matrix() * 0.01

	Kikoho_Rock
		icon='Turf 50.dmi'
		icon_state="1.9"

		New()
			pixel_x=rand(-16,16)
			pixel_y=rand(-16,16)
			KikohoRock()

		proc
			KikohoRock()
				set waitfor=0
				KikohoRockFlyOff()
				sleep(300)
				del(src)

			KikohoRockFlyOff()
				var
					dist = rand(3,12)
					_dir = pick(NORTH,SOUTH,EAST,WEST,NORTHEAST,NORTHWEST,SOUTHWEST,SOUTHEAST)
					spd = rand(87,113) / 100

				for(var/v in 1 to dist)
					var
						stepped
					if(prob(30))
						var/d = pick(turn(_dir,45),turn(_dir,-45))
						stepped = step(src,d)
					else stepped = step(src,_dir)

					if(!stepped) break
					else
						var/sleep_delay = world.tick_lag + ((v / dist) * world.tick_lag * 2)
						sleep(TickMult(sleep_delay * spd))

	Kikoho_Dust
		icon = 'Kikoho Dust.dmi'
		//blend_mode = BLEND_ADD
		layer = MOB_LAYER+1

		New()
			CenterIcon(src)
			pixel_y=0
			transform*=4
			KikohoDust()

		proc
			KikohoDust()
				set waitfor=0
				flick("dust2",src)
				sleep(5)
				del(src)

	Kikoho_Explosion
		blend_mode = BLEND_ADD
		icon = 'Kikoho Explosion.dmi'
		layer = MOB_LAYER+1

		New()
			transform*=1.2
			CenterIcon(src)
			pixel_y = 0
			icon = null
			KikohoExplosion()

		proc
			KikohoExplosion()
				set waitfor=0
				flick('Kikoho Explosion.dmi',src)
				sleep(14)
				del(src)
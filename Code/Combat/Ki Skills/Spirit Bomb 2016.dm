obj/Attacks/Genki_Dama
	name = "Omega Bomb"
	desc = "This is the most powerful 1-hit attack. Press it once to start charging, press it again \
	to fire. Guide it with the directional keys. This move is extremely deadly so only use it if you want to \
	kill someone."
	Cost_To_Learn = 0
	clonable = 0
	Teach_Timer = 2
	student_point_cost = 50
	var
		tmp
			can_fire_genki_dama=1
			sb_rotation = 0
			next_use = 0
		has_particles = 1
		Genki_Dama_particle_icon = 'Spirit Bomb Particle.dmi'
		//Genki_Dama_icon = 'spirit bomb 2016.png'
		Genki_Dama_icon = 'Spirit Bomb 2 - 2017.png'
		spin_animation = 1
		usable_if_cybered = 0
		y_offset = 6
		Genki_Dama_drain = 1000
		sb_move_speed = 1 //this is actually the DELAY. lower = faster
		sb_max_size = 1.2
		sb_charge_time = 120
		sb_speed_stat_influence = 0.25
		max_dmg_range = 3 //how big the collision box is at full charge
		sb_initial_dmg = 1
		sb_dmg_add = 5 //how much damage is gained per charge tick
		sb_deflect_difficulty = 10
		sb_explosion_size = 5
		sb_stun_level = 0
		self_cooldown = 90 //seconds

	verb/Hotbar_use()
		set hidden=1
		Genki_Dama()

	verb/Genki_Dama()
		//set category="Skills"
		set name = "Omega Bomb"
		usr.TrySpiritBomb2017(src)





mob/var
	tmp
		obj/Blast/Genki_Dama/last_Genki_Dama

obj/Blast/Genki_Dama
	blast_caches = 0
	var
		tmp
			sb_move_speed = 1.5
			sb_moving
	proc
		SpiritBombGoOffSomewhere()
			set waitfor=0
			for(var/v in 1 to 100)
				step(src,dir)
				sleep(TickMult(sb_move_speed))
				if(!z) break
			if(z)
				del(src)
				return

mob/proc
	SpiritBombSpawnLoc(y_offset = 6)
		return locate(x, y + y_offset, z)

	CanSpiritBomb(why = 0, obj/Attacks/Genki_Dama/sb)
		if(!sb.charging)
			if(ki_shield_on()) return
			if(!sb.usable_if_cybered && Is_Cybernetic())
				if(why) src << "Cybernetic beings cannot use this ability"
				return
			if(Ki < sb.Genki_Dama_drain)
				if(why) src << "Not enough energy (need [sb.Genki_Dama_drain])"
				return
			if(cant_blast())
				return
			if(world.time < sb.next_use)
				src << "Still on cooldown"
				return

			var/turf/blast_loc = SpiritBombSpawnLoc(sb.y_offset)
			if(!blast_loc || !isturf(blast_loc) || blast_loc.density || !viewable(src, blast_loc, 10))
				src << "There is a wall in the way"
				return

		return 1

	TrySpiritBomb2017(obj/Attacks/Genki_Dama/sb)
		if(!CanSpiritBomb(why = 1, sb = sb)) return
		SpiritBomb2017(sb)

	SpiritBomb2017(obj/Attacks/Genki_Dama/sb)
		if(!sb.charging) SpiritBombBegin(sb)
		else if(sb.can_fire_genki_dama) SpiritBombThrow(sb)

	SpiritBombThrow(obj/Attacks/Genki_Dama/sb)
		//if(LastSpiritBombValid()) animate(last_Genki_Dama) //stops it from appearing to grow after you've already thrown it before it was fully grown
		sb.charging = 0 //NEW SEPT 14th 2019
		sb.can_fire_genki_dama = 0 //NEW SEPT 14th 2019
		sb.next_use = world.time + (sb.self_cooldown * 10)
		flick("Attack",src)
		Ki -= GetSkillDrain(mod = sb.Genki_Dama_drain, is_energy = 1)
		player_view(10,src) << sound('basicbeam_fire.ogg',volume=15)
		SpiritBombGuidedMovement()
		SpiritBombDone(sb)

	SpiritBombGuidedMovement()
		var/max_steps = 80
		if(!LastSpiritBombValid()) return
		last_Genki_Dama.sb_moving = 1
		for(var/v in 1 to max_steps)
			var/sb_move_speed = last_Genki_Dama.sb_move_speed //sometimes step() deletes the Omega Bomb and causes an error
			step(last_Genki_Dama, last_direction_pressed)
			sleep(TickMult(sb_move_speed))
			if(!LastSpiritBombValid()) break
			else if(getdist(src, last_Genki_Dama) > 30) break
			if(last_Genki_Dama.deflected) break
		if(LastSpiritBombValid()) last_Genki_Dama.SpiritBombGoOffSomewhere()

	LastSpiritBombValid()
		var/obj/Blast/Genki_Dama/b = last_Genki_Dama
		if(b && b.z && b.Owner == src) return 1

	SpiritBombBegin(obj/Attacks/Genki_Dama/sb)
		sb.charging = 1
		var/turf/blast_loc = SpiritBombSpawnLoc(sb.y_offset)
		var/obj/Blast/Genki_Dama/b = new(blast_loc)
		if(!b)
			sb.charging = 0
			return
		last_Genki_Dama = b
		b.sb_move_speed = sb.sb_move_speed
		b.Stun = sb.sb_stun_level
		b.blast_go_over_obstacles_if_cant_destroy = 1
		b.blast_go_over_owner = 1
		b.icon = sb.Genki_Dama_icon
		CenterIcon(b)
		b.setStats(src, Percent = 33, Off_Mult = 10, Explosion = 0)
		b.from_attack = sb
		sb.can_fire_genki_dama = 0
		attacking = 3

		if(sb.spin_animation) animate(b, transform = matrix(360, MATRIX_ROTATE), time = 200, loop = -1, flags = ANIMATION_RELATIVE)
		SpiritBombEnergyParticlesGatherLoop(b, sb)
		SpiritBombSizeGrow(b, sb)
		SpiritBombPowerGrow(b, sb)
		SpiritBombSpin(b, sb)

	SpiritBombEnergyParticlesGatherLoop(obj/Blast/Genki_Dama/b, obj/Attacks/Genki_Dama/sb)
		set waitfor=0

		if(!sb.Genki_Dama_particle_icon) return

		var
			start_loc = b.loc
			usr_loc = loc

		var/obj/o = new
		o.icon = sb.Genki_Dama_particle_icon
		//o.alpha = 255

		var/list/froms = view(30,start_loc)

		while(b && b.z && b.loc == start_loc && loc == usr_loc)
			DoSomeSpiritBombParticles(particle = o, dest = start_loc, amount = 10, from = froms)
			sleep(TickMult(10))

	DoSomeSpiritBombParticles(obj/particle, turf/dest, amount = 5, list/from)
		set waitfor=0
		for(var/v in 1 to amount)
			Missile(particle, pick(from), dest)
			sleep(TickMult(1.3))

	SpiritBombSizeGrow(obj/Blast/Genki_Dama/b, obj/Attacks/Genki_Dama/sb)
		set waitfor=0
		b.transform = matrix() * 0.01
		var
			end_size = sb.sb_max_size
			animate_time = SpiritBombChargeTime(sb)
			elapsed_time = 0
			max_dmg_range = sb.max_dmg_range
		//if(b.z) animate(b, transform = matrix() * end_size, time = animate_time, easing = SINE_EASING)

		while(b && b.z && b.Owner == src && sb.charging && !b.sb_moving && !SpiritBombInterrupted())
			var/sleep_mult = world.tick_lag
			elapsed_time += sleep_mult

			var/mtx_size = end_size * (elapsed_time / animate_time)**1.5
			if(mtx_size > end_size) mtx_size = end_size
			b.transform = matrix() * mtx_size

			b.Size = max_dmg_range * (elapsed_time / animate_time)**0.5
			b.Size = round(b.Size)
			if(b.Size > max_dmg_range) b.Size = max_dmg_range

			sleep(sleep_mult)

			if(elapsed_time > animate_time / 4 && sb.charging) sb.can_fire_genki_dama = 1

		if(SpiritBombInterrupted()) SpiritBombInterrupt(b, sb)
		//else animate(b)

	SpiritBombSpin(obj/Blast/Genki_Dama/b, obj/Attacks/Genki_Dama/sb)
		set waitfor=0
		if(!sb.spin_animation) return
		var/spin_speed = -8
		while(b && b.z && b.Owner == src && !b.sb_moving)
			sb.sb_rotation += spin_speed
			b.transform = turn(b.transform, sb.sb_rotation)
			sleep(world.tick_lag)

		//we switch to another method of rotation because if we keep using the above after we throw the Omega Bomb we go into hyper spin because the transform is no longer growing
		while(b && b.z && b.Owner == src)
			b.transform = turn(b.transform, spin_speed)
			sleep(world.tick_lag)

	SpiritBombInterrupted()
		if(KO) return 1
		if(KB && knock_dist >= 8) return 1

	SpiritBombInterrupt(obj/Blast/Genki_Dama/b, obj/Attacks/Genki_Dama/sb)
		set waitfor=0
		SpiritBombDone(sb)
		var/timer = 40
		if(b.z) animate(b, transform = matrix() * 0.01, time = timer, easing = SINE_EASING, flags = ANIMATION_PARALLEL)
		sleep(timer + 1)
		if(b.z) del(b)

	SpiritBombDone(obj/Attacks/Genki_Dama/sb)
		sb.charging = 0
		attacking = 0

	SpiritBombChargeTime(obj/Attacks/Genki_Dama/sb)
		var/t = sb.sb_charge_time * Speed_delay_mult(severity = sb.sb_speed_stat_influence)
		return t

	SpiritBombPowerGrow(obj/Blast/Genki_Dama/b, obj/Attacks/Genki_Dama/sb)
		set waitfor=0
		var
			dmg = sb.sb_initial_dmg
			timer = SpiritBombChargeTime(sb)
			div = 3
			loopCount = round(timer / div)
		for(var/v in 1 to loopCount)
			var/dmgAdd = sb.sb_dmg_add * div
			if(v <= loopCount / 2) dmgAdd *= 0.5 //uncharged Omega Bombs/etc were just too strong
			else dmgAdd *= 1.5
			dmg += dmgAdd
			b.setStats(src, Percent = dmg, Off_Mult = sb.sb_deflect_difficulty, Explosion = sb.sb_explosion_size)
			sleep(TickMult(div))
			if(!b || !b.z || b.Owner != src || !sb.charging || SpiritBombInterrupted()) break
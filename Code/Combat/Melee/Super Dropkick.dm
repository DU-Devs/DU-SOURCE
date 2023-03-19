/*mob/verb/FixMe()
	set category = "Other"
	transform = matrix()*/

obj
	Dropkick
		desc = "Channel all your energy into 1 kick, leaving you powerless for 30 seconds but dealing massive damage. (Minimum 10% HP and 10% Ki)"

		Cost_To_Learn = 20
		Teach_Timer = 1
		student_point_cost = 20
		repeat_macro=0
		can_hotbar = 1
		hotbar_type = "Melee"

		verb/Hotbar_use()
			set waitfor=0
			set hidden=1
			Dropkick()

		verb
			Dropkick()
				//set category = "Skills"
				if(usr.Health>10&&(usr.Ki>usr.max_ki/10)) usr.Dropkick()

mob/var
	tmp
		last_dropkick = 0
		last_dropkick_debuff_triggered = 0

mob
	proc
		DropkickBPDebuff()
			if(world.time - last_dropkick_debuff_triggered < 300) return 0.01
			return 1

		DropkickFX()
			set waitfor=0
			var/obj/Effect/e = GetEffect()
			e.icon = 'swirling white energy.png'
			CenterIcon(e)
			e.SafeTeleport(loc)
			e.transform *= 2
			var/fx_time = 5
			animate(e, transform = transform * 0.001, time = fx_time, easing = SINE_EASING)
			sleep(fx_time + 1)
			del(e)

		Dropkick()
			//if(attacking) return
			if(world.time - last_dropkick < 100) return
			//if(!can_melee()) return
			if(!CanMeleeFromOtherCauses()) return //this checks if anything OTHER than you currently doing attacks is also stopping you from being able to melee
			var/mob/m = LungeTarget()
			if(!m)
				src << "No target found"
				return
			attacking = 1
			last_dropkick = world.time
			AlterInputDisabled(1)

			DropkickFX()

			player_view(15, src) << sound('throw.ogg', volume = 35)
			Do_lunge_drawback_animation()
			sleep(TickMult(2 + Get_melee_delay(mult = 2)))

			var/flying = Flying
			Fly()

			var/cardinal_dir = cardinal_pixel_dir(src, m)
			var/rot_ang = 0
			if(cardinal_dir == NORTH) rot_ang = 180
			if(cardinal_dir == WEST) rot_ang = 90
			if(cardinal_dir == EAST) rot_ang = -90
			transform = turn(transform, rot_ang)
			spawn(5) transform = turn(transform, -rot_ang)

			var/targ_dist = getdist(src,m)
			var/max_dist = targ_dist + 8
			for(var/s in 1 to max_dist)
				AfterImage(8)
				var/success = step_towards(src, m.base_loc(), 32)
				if(DropkickCancelled(m, success)) break
				else sleep(world.tick_lag)

			if(!flying) Land()

			//flick("Attack",src)

			var/hit = prob(get_melee_accuracy(m) * 2)
			if(getdist(src,m) > 1) hit = 0
			if(!hit) player_view(15,src) << sound('meleemiss3.ogg', volume = 35)

			ScreenShake(Amount = 15, Offset = 8)
			//ClientColorFlick(rgb(255,0,0))
			ClientColorInvertFlick()
			if(m && hit)
				ApplyStun(time = 60, no_immunity = 1, stun_power = 10)
				player_view(15,src) << sound('strongpunch.ogg', volume = 60)
				m.AlterInputDisabled(1)
				m.ScreenShake(Amount = 15, Offset = 8)
				//m.ClientColorFlick(rgb(255,0,0))
				m.ClientColorInvertFlick()
				var/dmg = get_melee_damage(m, count_sword = 0) * 25
				var/hp_before_dmg = m.Health
				m.TakeDamage(dmg)
				if(dmg >= 100 + hp_before_dmg) m.KO(src, allow_anger = 0)
				else if(dmg >= hp_before_dmg) m.KO(src)
				var/remaining_dmg = dmg - hp_before_dmg
				if(remaining_dmg > 0) m.TakeDamage(remaining_dmg)

				sleep(2)
				if(m)
					m.AlterInputDisabled(-1)

					var/stun_time = 60 * (BP / m.BP)**0.5
					var/stun_power = 2 * (BP / m.BP)**0.5
					m.ApplyStun(time = stun_time, no_immunity = 1, stun_power = stun_power)

					var/base_dist = 0
					var/dist = base_dist * (BP / m.BP)**0.5 * (End / m.Str)**0.5
					dist = Clamp(dist, 0, base_dist * 3)
					m.Knockback(src, Distance = dist, bypass_immunity = 1, from_lunge = 1)

					if(Fatal)
						if(m.KO || m.Health <= 0)
							Explosion_Graphics(m,3)
							m.SaitamaBloodEffect(blood_range = 3, blood_chance = 50)
							m.Death(src)

			last_dropkick_debuff_triggered = world.time
			cant_anger_until_time = world.time + (2 * 600)
			Ki = 0
			Health = 1
			AddStamina(-99999)
			attacking = 0
			sleep(3)
			AlterInputDisabled(-1)

		DropkickCancelled(mob/m, moved = 1)
			if(!m || getdist(src,m) <= 1 || !moved || !viewable(src,m,35))
				return 1
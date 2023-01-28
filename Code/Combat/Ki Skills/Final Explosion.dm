var
	spirit_doll_final_explosion_time_mult = 0.6
	final_explosion_size_mod = 1.5 //affects the radius of the explosion but keep in mind it will COVER that radius in the same amount of time so
		//this will also make it bigger AND FASTER as far as the amount of distance it covers in a short period of time

mob/proc/FinalExplosionFollowOnMove()
	set waitfor=0
	if(final_explosion_explosion_obj)
		var/obj/e = final_explosion_explosion_obj
		e.loc = loc
		e.step_x = step_x
		e.step_y = step_y

obj/Final_Explosion
	teachable = 1
	Skill = 1
	Cost_To_Learn = 8
	Teach_Timer = 5
	student_point_cost = 15
	hotbar_type = "Ability"
	can_hotbar = 1

	desc = "Tap this once to begin charging. Tap it again to unleash an explosion. It will damage you and anyone near you. If you \
	charge it enough you will die."

	verb
		Hotbar_use()
			set waitfor = 0
			set hidden = 1
			Final_Explosion()

		Final_Explosion()
			//set category = "Skills"
			usr.Final_Explosion()

mob
	var
		tmp
			using_final_explosion
			charging_final_explosion
			final_explosion_dmg = 0
			final_explosion_max_charge_seconds = 9
			obj/final_explosion_explosion_obj

	proc
		Final_Explosion()
			set waitfor=0
			if(!charging_final_explosion && !using_final_explosion)
				if(cant_blast()) return
				if(tournament_override(fighters_can = 1)) return
				src << "Tap again to unleash the explosion"
				BeginChargingFinalExplosion()
			else
				if(charging_final_explosion)
					DoFinalExplosion()

		DoFinalExplosion()
			set waitfor=0
			charging_final_explosion = 0

			FinalExplosionGraphics()
			FinalExplosionDamage()

			var/stun_time = 100
			ApplyStun(time = stun_time)
			sleep(stun_time)
			AlterInputDisabled(-1)
			using_final_explosion = 0

		BeginChargingFinalExplosion()
			set waitfor=0
			using_final_explosion = 1
			charging_final_explosion = world.time

			player_view(20,src) << sound('powerup.wav', volume = 50)
			AlterInputDisabled(1)
			final_explosion_dmg = 15

			//mild knockaway and stun
			for(var/mob/m in view(2,src)) if(m != src)
				PowerupKnockbackEffect(m)
				var/base_stun = 11
				var/stun = base_stun * (BP / m.BP)**bp_exponent * (Pow / m.Res)**0.5
				stun = Clamp(stun, 0, base_stun * 5)
				m.ApplyStun(time = stun)

			FinalExplosionChargeupGraphics()
			sleep(20 * spirit_doll_final_explosion_time_mult)
			for(var/v in 1 to final_explosion_max_charge_seconds)
				if(!charging_final_explosion) break
				else
					var/dmg_increase = 25
					if(grabber) dmg_increase *= 0.5
					final_explosion_dmg += dmg_increase
				sleep(10 * spirit_doll_final_explosion_time_mult)

		FinalExplosionDamage()
			set waitfor=0
			var/explosion_range = 1 + sqrt(final_explosion_dmg) * final_explosion_size_mod
			explosion_range = Clamp(explosion_range, 1, 999)
			var
				wall_break_power = WallBreakPower()
				user_bp = BP
				user_force = Pow
			sleep(8)
			for(var/turf/t in TurfCircle(round(explosion_range), src))
				var/dmg_delay = 1.6 * get_dist(src,t) / final_explosion_size_mod
				t.FinalExplosionDamage(src, final_explosion_dmg, wait_time = dmg_delay, wall_break_power = wall_break_power, \
					user_bp = user_bp, user_force = user_force)

		FinalExplosionChargeupGraphics()
			set waitfor=0
			var/obj/Effect/e = GetEffect()
			e.loc = loc
			e.icon = 'Mega Supernova 2018.dmi'
			CenterIcon(e)
			e.layer = layer + 0.1
			e.transform *= 0.11
			e.alpha = 200
			final_explosion_explosion_obj = e
			var/anim_time = final_explosion_max_charge_seconds * 10
			if(Class == "Spirit Doll") anim_time *= spirit_doll_final_explosion_time_mult
			animate(e, transform = matrix() * 0.23, alpha = 235, time = anim_time)//, easing = CUBIC_EASING)

		FinalExplosionGraphics()
			set waitfor=0
			var/explosion_total_size = sqrt(final_explosion_dmg) * 0.3 * final_explosion_size_mod
			player_view(20,src) << sound('basicbeam_fire.ogg', volume = 50)
			Dust(src, end_size = 2.4, time = 55, start_delay = 17)
			var/obj/Effect/e = final_explosion_explosion_obj
			if(!e) return
			final_explosion_explosion_obj = null
			e.loc = loc

			var/anim_time = 4
			animate(e, transform = matrix() * 0.115, time = anim_time)
			sleep(anim_time)

			anim_time = 20
			animate(e, transform = matrix() * explosion_total_size, alpha = 255, time = anim_time, easing = CUBIC_EASING)
			sleep(anim_time)

			anim_time = 15
			animate(e, alpha = 0, time = anim_time)
			sleep(anim_time + 1)
			del(e)

turf
	proc
		FinalExplosionDamage(mob/user, dmg_percent = 0, wait_time = 0, wall_break_power = 1, user_bp = 1, user_force = 1)
			set waitfor=0
			if(wait_time) sleep(TickMult(wait_time))

			if(Health < wall_break_power && Health != 1.#INF)
				Health = 0
				Destroy()

			for(var/obj/o in src)
				if(o.Health <= wall_break_power && viewable(user, o))
					RockExplode(o.loc)
					BigCrater(pos = src, minRangeFromOtherCraters = 1)
					del(o)

			var/max_stacks = 5
			for(var/v in 1 to max_stacks)
				for(var/mob/m in src)
					if(m.InTournament()) continue
					if(viewable(user, m))
						if(v == 1) RockExplode(m.loc)

						var/dmg = dmg_percent / max_stacks * (user_bp / m.BP)**bp_exponent * (user_force / m.Res)**0.5
						if(m.ki_shield_on()) m.Ki -= dmg * m.ShieldDamageReduction() * (m.max_ki / 100)
						else m.TakeDamage(dmg)

						var/base_stun = 5
						var/stun = base_stun * (user_bp / m.BP)**bp_exponent * (user_force / m.Res)**0.5
						stun = Clamp(stun, 0, base_stun * 3)
						m.ApplyStun(time = stun)

						if(m.Health <= 0)
							var/bypass_regen = (dmg > 150 / max_stacks)
							if(m == user) m.Death(user, lose_hero = 0, lose_immortality = 0)
							else m.Death(user, Force_Death = bypass_regen)
				sleep(5)

mob/proc
	ShieldDamageReduction()
		var/n = shield_reduction / (Eff ** shield_exponent)
		if(world.time - last_input_move <= 3) n *= 4 //shield is weaker when moving
		return n
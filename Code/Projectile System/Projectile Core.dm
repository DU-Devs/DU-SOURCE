/*
what does a projectile system really need to support?
	attack creator
	caching
	custom icons but dynamically resized to all be 32x32 by default using transform size
	if a player touches a stationary blast it still explodes and hits them
	damage
	hitting a shield
	reflection by player - if player has stam maybe he should always deflect? but more powerful deflecting takes longer
		firer cant move while other player is deflecting a powerful blast or this means they gave up the struggle and that person
		deflects it right back at them
	exploding
	shrapnel
	bleed damage
	blasts that bounce off walls and objects til they hit a player
	pixel velocity
	large blasts with multi-tile collisions
	knockback
	stun
	targeting
	homing
	change direction by user input
*/

mob
	var
		tmp
			next_ability_use = 0

obj
	bullet
		density = 0

		var
			percent_dmg = 5
			bullet_bp = 1
			bullet_force = 1

		blast

		beam

obj
	Ability
		hotbar_type = "Ability"
		can_hotbar = 1

		var
			next_use = 0
			self_cooldown = 10
			global_cooldown = 2

		proc
			SetCooldown(mob/m)
				next_use = world.time + TickMult(self_cooldown)
				m.next_ability_use = world.time + TickMult(global_cooldown)

		Blast
			hotbar_type = "Blast"
			repeat_macro = 1

			var
				pixel_randomness = 10

			TestBlast
				icon = 'Blast - 11.dmi'

				verb
					Hotbar_use()
						set hidden = 1
						TestBlast()

					TestBlast()
						set category = "Skills"
						SetCooldown(usr)
						var/obj/Effect/e = new(usr.loc)
						e.density = 0
						e.icon = icon
						e.step_size = rand(1,2)
						var/mob/m = locate(/mob) in oview(20,usr)
						var/angle = get_global_angle(e,m.loc)
						while(e && m)
							vector_step(e, angle)
							sleep(world.tick_lag)
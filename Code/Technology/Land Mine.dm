obj/items
	Land_Mine
		icon = 'Weapons.dmi'
		icon_state = "mine item"
		Cost=50000000
		hotbar_type="Combat item"
		can_hotbar=1
		repeat_macro=0
		Stealable=1
		Can_Drop_With_Suffix=1
		desc="A mine that is mostly buried under the ground out of sight and when someone steps on it or picks up an object sitting on top of it, KABOOM."

		var
			land_mines = 24

		New()
			suffix = "[land_mines]"
			. = ..()

		verb
			Hotbar_use()
				set hidden=1
				Use()

			Use()
				set src in usr
				if(loc == usr)
					if(!usr.CanDeployLandMine()) return
					usr.PlaceLandMine()
					land_mines--
					suffix = "[land_mines]"
					if(land_mines <= 0)
						usr << "All the land mines are now used up"
						del(src)

mob/proc
	CanDeployLandMine()
		if(!loc || !isturf(loc)) return
		//if(attacking) return

		var/turf/t=loc
		if(t.density) return // || !t.FlyOverAble) return
		if(locate(/obj/Land_Mine) in t) return

		if(world.time - last_attacked_by_player < 160)
			src << "You can not place land mines if you were attacked in the last 16 seconds"
			return

		return 1

	PlaceLandMine()
		set waitfor=0
		//var/obj/Land_Mine/lm = new(loc)
		new/obj/Land_Mine(loc)

obj/Land_Mine
	Savable=1
	Grabbable=0
	density=0
	icon='Weapons.dmi'
	icon_state="land mine"
	var/tmp
		mine_detonated

	Del()
		LandMineExplode(from_del = 1)
		. = ..()

	proc
		LandMineExplode(from_del=0, delay=0)
			set waitfor=0
			if(mine_detonated) return

			if(delay) sleep(delay)

			var/turf/t = loc
			if(!t || !isturf(t)) return

			player_view(20,src) << sound('Explosion 2.wav',volume=50)

			var/obj/LandMineEffect/lme = new(t)
			flick(lme.icon_state,lme)

			for(var/atom/movable/m in view(1,src))
				if(ismob(m))
					var/mob/m2 = m
					//the reason we do this is because 1 mine can detonate all other mines surrounding it, which is potentially like
					//9 mines, which is insane damage and just too OP to exist
					if(world.time - m2.last_hit_by_land_mine > 10)
						m2.TakeLandMineDamage()
				else if(m.type == /obj/Land_Mine && m != src)
					var/obj/Land_Mine/lm = m
					lm.LandMineExplode(delay=TickMult(2))

			mine_detonated = 1
			if(!from_del) del(src)

mob/var/tmp/last_hit_by_land_mine = 0

mob/proc
	TakeLandMineDamage()
		set waitfor=0
		var/dmg = 40 * (Tech_BP * 1.63 / BP) ** 1
		//var/dmg = 100 * (highest_relative_base_bp * 0.63 / (base_bp / bp_mod))**5

		if(ThingC()) dmg *= 0.25

		TakeDamage(dmg)
		if(Health <= 0)
			Blood_splatter_effects()
			//SaitamaBloodEffect()
			Death("land mine explosion",lose_immortality = 0, lose_hero = 0)

atom/proc/ExplodeLandMines()
	var/turf/t
	if(isturf(src)) t = src
	else t = loc
	if(!t || !isturf(t)) return

	for(var/obj/Land_Mine/lm in t) lm.LandMineExplode()

obj/LandMineEffect
	Savable=0
	Grabbable=0
	Health=1.#INF
	layer=6
	Nukable=0
	Makeable=0
	Givable=0
	density=0
	icon='Land Mine Explosion.dmi'
	icon_state="explosion2"

	New()
		CenterIcon(src)
		pixel_y=0
		LandMineEffect()
		. = ..()

	proc
		LandMineEffect()
			set waitfor=0
			sleep(16)
			del(src)
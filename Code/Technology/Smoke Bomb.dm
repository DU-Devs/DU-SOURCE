/*

Gun Revamp: First off guns should not be for raw damage, they should have special properties that make them useful, because ki energy is way way
WAY more powerful. But what attributes could make guns useful?
	Maybe:
		Types of ammo is what makes it special:
			Poison
			Frost
			Incendiary
			Electric

GADGET IDEAS:
	Smoke bombs
	Fire bombs
	Mines, Land Mines etc

*/

obj/items

	Smoke_Bomb
		icon = 'Smoke Pellet.dmi'
		Cost=1000000
		hotbar_type="Combat item"
		can_hotbar=1
		repeat_macro=0
		Stealable=1
		Can_Drop_With_Suffix=1
		desc="A pack of toxic smoke pellets that when thrown will grow over time and you can hide in the smoke."

		var
			smoke_bombs = 99

		New()
			suffix = "[smoke_bombs]"
			. = ..()

		verb
			Hotbar_use()
				set hidden=1
				Use()

			Use()
				set src in usr
				if(loc == usr)
					if(!usr.CanThrowSmokeBomb()) return
					usr.ThrowSmokeBomb()
					smoke_bombs--
					suffix = "[smoke_bombs]"
					if(smoke_bombs <= 0)
						usr << "All the smoke bombs are now used up"
						del(src)

mob/var/tmp
	last_smoke_bomb_throw = 0

mob/proc
	CanThrowSmokeBomb()
		if(!loc || !isturf(loc)) return
		//if(attacking) return
		if(world.time - last_smoke_bomb_throw < 300) return
		return 1

	ThrowSmokeBomb()
		set waitfor=0

		//attacking = 1
		//spawn(40) attacking = 0
		last_smoke_bomb_throw = world.time

		var/obj/Effect/grenade = GetEffect()
		grenade.loc = loc
		grenade.icon = 'smoke pellet.dmi'
		CenterIcon(grenade)

		var/d = dir
		for(var/v in 1 to 4)
			if(step(grenade,d))
				sleep(TickMult(1))
			else break

		if(!grenade) return
		var/turf/t = grenade.loc
		del(grenade)
		if(!t || !isturf(t)) return

		DoSmokeBombEffect(t)
		DoSmokeBombEffect(t) //doubling up on the effect because it is too transparent

obj/SmokeBombEffect
	Savable=0
	Grabbable=0
	Health=1.#INF
	layer=6
	Nukable=0
	Makeable=0
	Givable=0
	density=0
	blend_mode=BLEND_DEFAULT
	mouse_opacity = 0
	appearance_flags = 0

var
	icon/smoke_bomb_icon

proc
	GetSmokeBombEffect()
		var/obj/SmokeBombEffect/e = new
		if(!smoke_bomb_icon)
			smoke_bomb_icon = 'Swirling Smoke Effect.dmi' + rgb(0,0,0,350)
		e.icon = smoke_bomb_icon
		CenterIcon(e)
		e.blend_mode = BLEND_DEFAULT
		return e

	DoSmokeBombEffect(turf/t)
		set waitfor=0

		var/obj/SmokeBombEffect/s = GetSmokeBombEffect() //smoke
		s.loc = t
		var
			end_size = 13
		s.transform = matrix() * 0.01

		//grow in size
		animate(s, transform = matrix() * end_size, time = 26)

		sleep(220)
		if(!s) return

		animate(s, alpha = 0, time = 30)

		sleep(35)
		if(s) del(s)
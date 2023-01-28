proc
	StartupScatterBigRocks()
		set waitfor=0

		//return //disabled to see if all these transformed rocks are crashing the server

		sleep(300)
		for(var/v in 1 to 1000)
			var/turf/t = locate(rand(1,world.maxx), rand(1,world.maxy), rand(1,world.maxz))
			if(!t.density && !t.Water && !t.Builder && !istype(t,/turf/Other))
				var/list/l = list(get_step(t,NORTH), get_step(t,SOUTH), get_step(t,EAST), get_step(t,WEST))
				for(var/turf/t2 in l)
					if(t2.density || t2.Water || t2.Builder) continue
				new/obj/Big_Rock/Big_Rock1(t)
				if(v % 5 == 0) sleep(world.tick_lag)

	RockExplode(turf/t)
		set waitfor=0
		if(!t || explosions_off) return

		//return //disabled for crashing

		player_view(16,t) << sound('kiplosion.ogg', volume=30)

		var/obj/Effect/e = GetEffect()
		e.SafeTeleport(t)
		e.icon = 'rock explosion.dmi'

		//all off merely due to lag concerns of overusing animate() lagging the client
		//e.transform *= 1.1
		//var/matrix/m = e.transform
		//m.Scale(rand(95,145) * 0.01, rand(90,110) * 0.01) //off merely due to lag concerns
		//e.transform = m

		CenterIcon(e)
		e.pixel_y = -60
		e.layer = 5
		e.blend_mode = 0
		flick('rock explosion.dmi',e)
		sleep(18)
		del(e)

obj
	Big_Rock
		Health = 1000
		takes_gradual_damage = 1
		Dead_Zone_Immune = 1
		Knockable = 0
		Grabbable = 0
		Cloakable = 0
		can_blueprint = 0
		Savable = 0
		layer = 4
		density = 1
		leaves_big_crater = 1
		big_explosion_on_delete = 1
		stun_when_knocked_through = 1

		var
			min_rock_size = 0.5
			max_rock_size = 0.8

			//dont set here. the size of the icon multiplied by the transform size
			rock_width = 1
			rock_height = 1

		New()
			. = ..()
			RockInit()

		Del()
			RockExplode(loc)
			var/turf/t = loc
			SafeTeleport(null)
			sleep(5 * 600)
			SafeTeleport(t)

		proc
			RockInit()
				set waitfor=0
				if(prob(50)) InvertX()
				var/size = rand(min_rock_size * 100, max_rock_size * 100) * 0.01
				SetTransformSize(size)
				//rock_width = GetWidth(icon) * transform_size * 0.8
				//rock_height = GetHeight(icon) * transform_size
				rock_width = GetWidth(icon) * size * 0.8
				rock_height = GetHeight(icon) * size
				RockXScale()
				CenterIcon(src)
				//pixel_y += 69.5 * transform_size
				//pixel_y -= 5 / transform_size
				pixel_y += 69.5 * size
				pixel_y -= 5 / size
				//color = rgb(rand(210,255),rand(210,255),rand(210,255)) //just off due to possible lag concerns
				GenerateRockBounds()

			RockXScale()
				var/n = rand(67,110) * 0.01
				var/matrix/m = transform
				m.Scale(n, 1)
				transform = m
				rock_width *= n

			GenerateRockBounds()
				bound_x = -(rock_width - 32) / 2
				bound_width = rock_width
				bound_height = rock_height / 2

				//test. we are rounding it all to the nearest 32 so the box covers only entire tiles never partial because otherwise it lets the player
				//walk right through the back of rocks for some reason
				bound_x = round(bound_x, 32)
				bound_width = round(bound_width, 32)
				if(bound_width < 32) bound_width = 32
				bound_height = round(bound_height, 32)
				if(bound_height < 32) bound_height = 32

		Big_Rock1
			icon = 'big rock test.dmi'
			min_rock_size = 0.5
			max_rock_size = 0.85

atom/proc
	InvertX()
		var/matrix/m = transform
		m.Scale(-1,1)
		transform = m
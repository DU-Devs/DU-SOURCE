/*mob/Admin5/verb/MassHarambe()
	var/include_players = alert(usr,"Include players?","Options","No","Yes")
	for(var/mob/m in view(20,usr))
		if(m != usr)
			if(!m.client || include_players == "Yes")
				spawn if(m) m.HarambeDeath()
				sleep(rand(1,20))*/

obj
	Harambe_Statue
		pixel_x = -57
		pixel_y = -4
		density = 0
		Savable = 0
		Health = 1.#INF
		Dead_Zone_Immune = 1
		Grabbable = 0
		Knockable = 0
		Bolted = 1
		desc = "Never forget"
		icon = 'gorilla halo.png'
		layer = 4.1

		New()
			DeleteHarambe()

		proc
			DeleteHarambe()
				set waitfor=0
				sleep(100)
				del(src)

	Dead_Harambe
		pixel_x = -75
		pixel_y = 10
		density = 0
		Savable = 0
		Health = 1.#INF
		Dead_Zone_Immune = 1
		//Grabbable = 0
		//Knockable = 0
		//Bolted = 1
		icon = 'gorilla no head.png'
		layer = 3.9

	Harambe
		pixel_x = -75
		pixel_y = 10
		density = 0
		Savable = 0
		Health = 1.#INF
		Dead_Zone_Immune = 1
		Grabbable = 0
		Knockable = 0
		Bolted = 1
		icon = 'gorilla.png'
		layer = 3.9

		New()
			HarambeStart()

		proc
			HarambeStart()
				set waitfor=0
				HarambeScream()

			HarambeScream()
				set waitfor=0
				while(src)
					player_view(20,src) << sound('angry monkey.ogg', volume = 100)
					sleep(110)

/*mob/Admin5/verb/Harambe(mob/m in world)
	set category = "Admin"
	m.HarambeDeath()
	m.Death("harambe",lose_hero = 0, lose_immortality = 0)*/

mob/proc
	HarambeDeath()
		var/turf/t = base_loc()
		if(!t) return

		var/obj/Harambe/h = new
		HarambeSpawn(h)
		HarambeDescend(h)
		HarambeGrabAndRunAround(h) //this is set waitfor=0
		HarambeTakeHimOut(h)

	HarambeSpawn(obj/Harambe/h)
		var
			xx = clamp(x - 1, 1, world.maxx)
			yy = clamp(y + 10, 1, world.maxy)
			turf/t = base_loc()
		h.loc = locate(xx,yy,t.z)

	HarambeDescend(obj/Harambe/h)
		var
			turf/t = base_loc()
			y_dist = h.y - t.y

		for(var/v in 1 to y_dist)
			h.density=0
			var/turf/downstep = get_step(h,SOUTH)
			if(downstep) h.SafeTeleport(downstep)
			sleep(2)

		Say("Harambe??")

		sleep(30)

		var/o_name = name
		name = "Harambe"
		Emote("screeches")
		name = o_name

		sleep(40)
		Say("NO HARAMBE CALM DOWN. DON'T DO IT")

		sleep(20)
		step(h,EAST) //puts harambe right on top of the player
		sleep(10)

	HarambeGrabAndRunAround(obj/Harambe/h)
		set waitfor=0
		var
			turf/start_pos = h.loc
			elapsed_time = 0

		spawn while(h)
			SafeTeleport(h.loc)
			sleep(world.tick_lag)

		while(h)
			h.density=1
			if(getdist(h,start_pos) <= 4)
				step_rand(h)
			else
				step_towards(h,start_pos)

			var/delay = TickMult(0.7)
			elapsed_time += delay
			sleep(delay)

	HarambeTakeHimOut(obj/Harambe/h)
		sleep(50)
		var/o_name = name
		name = "Captain"
		Say("Okay that's enough. Get me a sniper in here!")
		sleep(50)
		Say("Took you long enough, take the shot Lieutenant")
		sleep(20)
		name = "Lieutenant"
		Say("Yes sir.")
		sleep(15)
		player_range(100,src) << sound('sniper shot.ogg',volume = 100)
		sleep(5)
		var/obj/Dead_Harambe/dead_harambe = new(h.loc)
		del(h)
		BloodEffectsWaitForZero()
		name = o_name
		HarambeOhShit(dead_harambe)

	HarambeOhShit(obj/Dead_Harambe/dh)
		set waitfor=0
		sleep(25)
		player_view(20,dh) << sound('oh shit.ogg',volume = 100)
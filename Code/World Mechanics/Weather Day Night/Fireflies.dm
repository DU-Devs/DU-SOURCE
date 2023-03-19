var
	list
		fireflies_area_sorted = new //associative list containing area names that have lists of all fireflies there
		firefly_icons

proc
	GenerateFireflyIcons()
		if(!fireflies) return
		if(firefly_icons) return
		firefly_icons = new/list

		//generate set of sizes
		var/size = 66
		for(var/v in 1 to 4)
			var/icon/i = icon('Fireflies.dmi')
			i.Scale(size,size)
			var/image/i2 = image(icon = i, pixel_x = -((size - 32) * 0.5), pixel_y = -((size - 32) * 0.5))
			firefly_icons.Insert(1,i2)
			size = round(size * 0.78)

		//generate set of rotations
		var/list/l = new
		var/angle = 0
		for(var/v in 1 to 7)
			if(angle != 0)
				for(var/image/i in firefly_icons)
					var/icon/i2 = icon(i.icon)
					i2.Turn(angle)
					var/image/i3 = image(icon = i2, pixel_x = i.pixel_x, pixel_y = i.pixel_y)
					l += i3
			angle += 45
		firefly_icons = l

		//generate icon states
		l = new/list
		for(var/v in 1 to 3)
			for(var/image/i in firefly_icons)
				var/image/i2 = image(icon = i.icon, pixel_x = i.pixel_x, pixel_y = i.pixel_y, icon_state = "[v]")
				l += i2
		firefly_icons = l

	ScatterFirefliesRandomlyOnMap()
		set waitfor=0
		set background = 1
		if(!fireflies) return
		sleep(300)
		for(var/v in 1 to 120)
			var/obj/Fireflies/f = new(RandomFireflyLocation())
			var/area/a = f.get_area()
			if(a) f.firefly_color = a.firefly_color

	RandomFireflyLocation()
		var/attempts = 0
		while(1)
			var/turf/t = locate(rand(1,world.maxx), rand(1,world.maxy), rand(1,world.maxz))
			if(!t.Water && !t.density)
				var/area/a = t.get_area()
				if(a && a.has_daynight_cycle && a.has_fireflies)
					return t
			attempts++
			if(attempts >= 20) return

	ToggleAreaFireflies(area/a, tog = 0)
		set waitfor=0
		sleep(150) //delay makes it look more natural in this case
		if(a.name in fireflies_area_sorted)
			var/list/l = fireflies_area_sorted[a.name]
			for(var/obj/Fireflies/f in l)
				if(tog) f.FirefliesFadeIn(delay = rand(150,450))
				else f.FirefliesFadeOut(delay = rand(150,450))

obj
	Fireflies
		blend_mode = BLEND_ADD
		density = 0
		layer = 6
		Savable = 0

		var
			firefly_color

		New()
			. = ..()
			MakeImmovableIndestructable()
			GiveLightSource(size = 1, max_alpha = 33, light_color = rgb(255,250,190))
			GenerateFireflies()
			AddFirefliesToList()
			DecideOnOrOff()

		proc
			FirefliesFadeIn(timer = 300, delay = 0)
				set waitfor=0
				if(delay) sleep(delay)
				animate(src)
				animate(src, alpha = 255, time = timer)

			FirefliesFadeOut(timer = 300, delay = 0)
				set waitfor=0
				if(delay) sleep(delay)
				animate(src)
				animate(src, alpha = 0, time = timer)

			DecideOnOrOff()
				set waitfor=0
				sleep(10)
				var/area/a = get_area()
				if(a && a.has_daynight_cycle && a.has_fireflies)
					if(a.is_day)
						animate(src, alpha = 0, time = 40)
					else
						animate(src, alpha = 255, time = 40)

			GenerateFireflies()
				set waitfor=0

				if(!firefly_icons) GenerateFireflyIcons()

				sleep(1) //wait for firefly_color to be set

				if(firefly_color)
					if(firefly_color == "rainbow")
						firefly_color = pick(\
							rgb(255,0,0),\
							rgb(0,255,0),\
							rgb(0,0,255),\
							rgb(255,255,0),\
							rgb(0,255,255),\
							rgb(255,0,255),\
							)
					color = firefly_color

				for(var/v in 2 to 4)
					var/image/i = pick(firefly_icons)
					overlays += i

			AddFirefliesToList()
				set waitfor=0
				sleep(1) //wait for loc to be set after New()
				var/area/a = get_area()
				if(a)
					if(!(a.name in fireflies_area_sorted))
						fireflies_area_sorted += a.name
						fireflies_area_sorted[a.name] = new/list
					fireflies_area_sorted[a.name] += src
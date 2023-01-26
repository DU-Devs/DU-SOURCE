obj/Orbiter
	icon = 'AWESOME PLANETS.dmi'
	icon_state = "Desert"
	density = 0

	var
		orbit_dist = 4
		orbit_speed = 1

	New()
		color = rgb( rand(0,255), rand(0,255), rand(0,255) )
		orbit_dist = rand(4,8)
		orbit_speed = rand(100,200) / 100
		Orbit()

	proc
		Orbit()
			set waitfor=0
			var
				matrix/m = new
				angleinc = 0

			while(src)

				angleinc += orbit_speed
				m.Translate(orbit_dist * cos(angleinc), orbit_dist * sin(angleinc))
				transform = m
				if(angleinc >= 360)
					angleinc = 0

				sleep(TickMult(1))
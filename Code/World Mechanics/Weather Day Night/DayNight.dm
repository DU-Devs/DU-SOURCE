/*
add:
	crickets at night
	birds and butterflies during day
	npcs that only come out during night or day. predators at night and peaceful at day. and enhanced versions like giant night Greenster npc

	"Natural Events"
		earthquakes (can unearth resources)
		lightning storms
		meteor strikes (esp on Braal), can get resources from meteors, esp if a big asteroid falls
		wildfires
		tsunamis

	also make it affect torches/fire/lights because i saw Zeex do a cool effect where he just makes a white transparent
		pulsating circle and places it over the torch then turns the game to night and it looks really nice
*/
mob/Admin2/verb/Change_Day_Night(turf/t in world)
	set category = null

	var/area/a = t.get_area()

	if(!a)
		src << "Right click any tile on a planet to use this command"
		return

	switch(alert(usr,"Make to Day or Night?","Options","Cancel","Day","Night"))
		if("Cancel") return
		if("Day") a.FadeToDay()
		if("Night") a.FadeToNight()

	var/hours = input(usr,"How many game hours? 1 game hour is 2 real minutes") as num
	a.hours_til_switch = hours

area
	var
		has_daynight_cycle = 1
		is_day = 1
		hours_of_day = 15
		hours_of_night = 9
		day_color = rgb(255,255,255,0)
		night_color = rgb(0,30,100,70)
		dawndusk_color = rgb(255,200,0,60)
		day_fade_time = 500
		night_fade_time = 1000
		hours_til_switch = 1

		has_fireflies = 1
		firefly_color

	proc
		DayNightLoop()
			set waitfor=0
			if(!daynight_enabled)
				icon = null
				return
			icon = 'White.dmi'
			color = day_color
			while(1)
				hours_til_switch--
				if(hours_til_switch <= 0)
					is_day = !is_day
					hours_til_switch = (is_day ? hours_of_day : hours_of_night)
					if(hours_til_switch > 0)
						if(is_day)
							FadeToDay()
						else
							FadeToNight()
				sleep(2 * 600)

		FadeToNight()
			set waitfor=0

			FadeInLights(src)
			ToggleAreaFireflies(src, 1)

			animate(src)
			animate(src, color = dawndusk_color, time = night_fade_time / 2)
			sleep(night_fade_time / 2)
			animate(src, color = night_color, time = night_fade_time / 2)

		FadeToDay()
			set waitfor=0

			FadeOutLights(src)
			ToggleAreaFireflies(src, 0)

			animate(src)
			animate(src, color = dawndusk_color, time = day_fade_time / 2)
			sleep(day_fade_time / 2)
			animate(src, color = day_color, time = day_fade_time / 2)
mob/proc/Rare_death_check(mob/m) //m = the original mob. src = the body

	if(!prob(1) || server_mode!="PVP") return

	name=m.name

	var/list/possible_deaths=list("bloody mess")
	switch(pick(possible_deaths))
		if("bloody mess")
			Say("420 yolo")
			Emote("injects only 1 weed and spews 10 gallons of blood from their anus and dies")
			Blood_splatter_effects()


mob/proc/Blood_splatter_effects()
	var/turf/t=loc
	var/max_timer=20

	var/list/l=player_view(15,src)
	l<<sound('squished.ogg',volume=100)

	for(var/turf/t2 in oview(5,src)) if(!t2.density)
		spawn(rand(0,max_timer))
			var/obj/Door_kill_blood/splatter=new(t)
			Center_Icon(splatter)
			splatter.pixel_y+=rand(-16,16)
			splatter.pixel_x+=rand(-16,16)
			splatter.Do_animation()
			sleep(1)
			while(splatter && splatter.z && splatter.loc!=t2)
				splatter.loc=get_step(splatter,get_dir(splatter,t2))
				sleep(To_tick_lag_multiple(1.6))

	sleep(max_timer)

	l<<sound('squished.ogg',volume=100)

	var/obj/Door_kill_blood/dkb=new(t)
	dkb.icon='Floor blood.dmi'
	Center_Icon(dkb)
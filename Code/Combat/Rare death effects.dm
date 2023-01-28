mob/proc/Rare_death_check(mob/m) //m = the original mob. src = the body
	set waitfor=0

	if(!prob(0.4)) return

	name=m.name

	var/list/possible_deaths=list("bloody mess")
	switch(pick(possible_deaths))

		if("bloody mess")
			//Say("420 yolo")
			//Emote("injects only 1 weed and spews 10 gallons of blood from their anus and dies")
			Blood_splatter_effects()

		if("harambe") HarambeDeath()


mob/proc/BloodEffectsWaitForZero()
	set waitfor=0
	Blood_splatter_effects()

var/last_blood_effect = 0

mob/proc/Blood_splatter_effects()
	set waitfor=0

	if(world.cpu >= 90 || last_blood_effect == world.time) return
	last_blood_effect = world.time

	var/turf/t=loc
	var/max_timer=20

	var/list/l=player_view(15,t)
	l<<sound('squished.ogg',volume=100)

	for(var/turf/t2 in TurfCircle(4,t)) if(!t2.density)
		spawn(rand(0,max_timer))
			var/obj/Door_kill_blood/splatter = GetCachedObject(/obj/Door_kill_blood, t)
			CenterIcon(splatter)
			splatter.pixel_y+=rand(-16,16)
			splatter.pixel_x+=rand(-16,16)
			splatter.Do_animation()
			sleep(1)
			while(splatter && splatter.z && splatter.loc!=t2)
				splatter.SafeTeleport(get_step(splatter,get_dir(splatter,t2)))
				sleep(TickMult(1.6))

	sleep(max_timer)

	l<<sound('squished.ogg',volume=100)

	var/obj/Door_kill_blood/dkb = GetCachedObject(/obj/Door_kill_blood, t)
	dkb.icon='Floor blood.dmi'
	CenterIcon(dkb)
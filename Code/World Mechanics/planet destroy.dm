var/list/planets=new
var/list/lightning_cache=new

proc/Get_lightning_strike()
	var/obj/Lightning_Strike/ls
	for(var/obj/o in lightning_cache) ls=o
	if(!ls) ls=new/obj/Lightning_Strike
	ls.Lightning_strike()
	lightning_cache-=ls
	return ls

obj/Lightning_Strike
	Savable=0
	proc/Lightning_strike()
		set waitfor=0
		sleep(1)
		for(var/v in 1 to 600)
			var/turf/t=Get_step(src,SOUTH)
			if(t) SafeTeleport(t)
			else break
			sleep(1)
		del(src)
	New()
		var/image/A=image(icon='Lightning Strike.dmi',icon_state="Front",layer=99)
		var/image/B=image(icon='Lightning Strike.dmi',pixel_y=32,layer=99)
		var/image/C=image(icon='Lightning Strike.dmi',pixel_y=64,layer=99)
		var/image/D=image(icon='Lightning Strike.dmi',pixel_y=96,icon_state="End",layer=99)
		overlays.Add(A,B,C,D)
	Del()
		SafeTeleport(null)
		lightning_cache ||= list()
		lightning_cache |= src

var/list/disabled_planets=new
mob/Admin4/verb/Disable_planet()
	set category="Admin"
	switch(alert(src,"Enable or disable a planet?","Options","Disable","Enable","Cancel"))
		if("Cancel") return
		if("Disable")
			while(src)
				var/list/L=list("Cancel")
				for(var/obj/Planets/p in planets) if(p.type!=/obj/Planets&&!(p.name in L)&&!(p.name in disabled_planets)) L+=p
				var/obj/Planets/p=input(src,"Disable which planet?") in L
				if(!p||p=="Cancel") return
				disabled_planets+=p.name
				world<<"<font color=cyan>Planet [p] was disabled by admins"
				ToggleDestroyedPlanets()
				sleep(1)
		if("Enable")
			while(src)
				var/list/L=list("Cancel")
				for(var/v in disabled_planets) L+=v
				var/p=input(src,"Enable which planet?") in L
				if(!p||p=="Cancel") return
				disabled_planets-=p
				world<<"<font color=cyan>Planet [p] was enabled by admins"
				unhide_restored_planets()
				sleep(1)

proc/ToggleDestroyedPlanets(planet)
	set background = TRUE
	for(var/obj/Planets/p in planets)
		if((!planet||p.name==planet)&&p.z&&(p.name in disabled_planets))
			p.planet_turf=p.loc
			p.SafeTeleport(null)

proc/unhide_restored_planets(planet)
	for(var/obj/Planets/p in planets)
		if((!planet || p.name == planet) && !p.z && p.planet_turf && !(p.name in disabled_planets))
			p.SafeTeleport(p.planet_turf)
			p.planet_turf=null

atom/proc/is_on_destroyed_planet()
	var/area/a
	if(ismob(src))
		var/mob/m=src
		a=m.current_area
	else a=locate(/area) in range(0,src)
	if(!a) return
	if(a.name in disabled_planets) return 1

mob/proc/logged_in_on_destroyed_planet_check() if(is_on_destroyed_planet())
	src<<"You logged in on a destroyed planet, you have been sent to space"
	SafeTeleport(locate(x, y, 16))

var/lastShipInvalidLocCheck = 0
proc/CheckShipValidLoc()
	set waitfor = 0
	if(lastShipInvalidLocCheck + 600 > world.time) return
	lastShipInvalidLocCheck = world.time

	for(var/obj/Ships/Ship/s in ships)
		if(s.is_on_destroyed_planet())
			s.z=16
		if(s.referenceObject) continue
		var/area/a = s.get_area()
		var/turf/t = s.base_loc()
		if(a)
			if(a.type == /area/ship_area || a.type == /area/Final_Realm || a.type == /area/God_Ki_Realm)
				del(s)
		if(s && t)
			if(t.type == /turf/Other/Blank)
				del(s)
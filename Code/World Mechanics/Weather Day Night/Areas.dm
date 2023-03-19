var/list/all_areas=new

var
	map_restriction_on = 0
	new_death_spawn = locate(361, 449, 7)
	new_bind_spawn = locate(413, 143, 7)

proc
	RestrictedMapLoop()
		set waitfor=0
		sleep(300)

		/*var/turf/atlantis_cave = locate(118,427,4)
		for(var/turf/t3 in orange(9, atlantis_cave))
			new/turf/GroundDirt(t3)
		new/turf/GroundDirt(atlantis_cave)*/

		while(1)
			for(var/mob/m in players)
				if(m.OnRestrictedMap())
					/*var/turf/t = m.base_loc()
					if(t && isturf(t))
						var/area/a = t.loc
						if(a && isarea(a) && a.restricted_area)
							for(var/turf/t2 in range(10,m))
								var/area/a2 = t2.loc
								if(a2 && isarea(a2) && a2.type == a.type)
									new/turf/Other/Blank(t2.loc)*/
					m.GoToDeathSpawn()
			sleep(30)

mob/proc
	OnRestrictedMap()
		if(!current_area) return
		//if(current_area.ship_restricted_area) return 1
		if(map_restriction_on && current_area.restricted_area) return 1

	GoToDeathSpawn()
		if(map_restriction_on) SafeTeleport(new_death_spawn)
		else
			var/pos = locate(death_x + rand(-20,20), death_y + rand(-15,15), death_z)
			SafeTeleport(pos)

	GoToBindSpawn()
		if(map_restriction_on)
			SafeTeleport(new_bind_spawn)
		else
			SafeTeleport(bind_spawn)

area
	//icon='Weather.dmi'
	mouse_opacity=0

	Enter(mob/m)
		if(ismob(m))
			//if(m.IsTens()) m<<"You entered [name] area"
			m.update_area()
		return . = ..()

	var
		Value=0
		can_has_dragonballs=0
		has_resources=0
		resource_refill_mod=1000
		can_planet_destroy=0
		zombies_can_reproduce_here = 1

		restricted_area
		ship_restricted_area

	New()
		DayNightLoop()
		layer=99
		all_areas+=src
		//. = ..()

	proc/Poison_gas_loop()
		set waitfor=0
		icon = 'Weather.dmi'
		while(src)
			if(icon_state!="Smog")
				icon_state="Smog"
				sleep(rand(300,600))
			else
				icon_state="Smog" //usually this would be "" but i decided smog 24/7
				sleep(rand(600,900))

	proc/Space_meteors_loop(delay_override=0)
		set waitfor=0
		while(src)
			var/amount=ToOne(meteor_density)
			if(delay_override) amount=ToOne(delay_override)
			if(amount) for(var/v in 1 to amount)
				player_list=remove_nulls(player_list)
				if(player_list.len)
					var/mob/m=pick(player_list)
					if(m)
						var/obj/SpaceDebris/SD
						var/turf/pos

						var/list/position_list=new
						var/turf/t=m.base_loc()
						if(isturf(t))
							for(var/v2 in -20 to 20)
								position_list+=locate(t.x+v2,t.y-30,t.z)
								position_list+=locate(t.x+v2,t.y+30,t.z)
								position_list+=locate(t.x-30,t.y+v2,t.z)
								position_list+=locate(t.x+30,t.y+v2,t.z)

						if(position_list.len == 0) continue

						var/tries=0
						while(!pos||!isturf(pos)||!istype(pos,/turf/Other/Stars))
							pos = pick(position_list)
							tries++
							if(tries>=25) break
						if(pos)
							if(prob(67)) SD = GetCachedObject(/obj/SpaceDebris/Meteor, pos)
							else SD = GetCachedObject(/obj/SpaceDebris/Asteroid, pos)
							if(m) SD.dir=get_dir(SD,m.base_loc())
							else SD.dir=pick(NORTH,SOUTH,EAST,WEST,NORTHEAST,NORTHWEST,SOUTHWEST,SOUTHEAST)
			sleep(15)

	ship_area
		icon = null
		has_daynight_cycle = 0
		restricted_area = 1
		ship_restricted_area = 1

	Inside
		icon = null
		has_daynight_cycle = 0

	Prison
		has_resources=1
		resource_refill_mod=1000

	Earth
		has_resources=1
		can_has_dragonballs=1
		resource_refill_mod=2000
		can_planet_destroy=1

	Battlegrounds
		has_resources = 0
		can_has_dragonballs = 0
		can_planet_destroy = 0
		zombies_can_reproduce_here = 0
		has_daynight_cycle = 1
		hours_of_day = 4
		hours_of_night = 8
		has_fireflies = 1

	Puranto
		has_resources=1
		can_has_dragonballs=1
		resource_refill_mod=1000
		can_planet_destroy=1

		has_daynight_cycle = 0
		//restricted_area = 1

	Braal
		has_resources=1
		can_has_dragonballs=0
		resource_refill_mod=1400
		can_planet_destroy=1

		day_color = rgb(100,0,0,40)
		night_color = rgb(100,0,0,70)

		has_fireflies = 0
		firefly_color = rgb(255,0,0)

	Arconia
		has_resources=1
		can_has_dragonballs=0
		resource_refill_mod=1000
		can_planet_destroy=1

		hours_of_day = 3
		hours_of_night = 6

		firefly_color = rgb(200,70,255)
		restricted_area = 1

	Checkpoint
		has_resources=1
		can_has_dragonballs=0
		resource_refill_mod=250

		hours_of_day = 17
		hours_of_night = 8
		restricted_area = 1

	Heaven
		has_resources=1
		can_has_dragonballs=0
		resource_refill_mod=250
		zombies_can_reproduce_here = 0

		//firefly_color = rgb(70,240,255)
		firefly_color = rgb(70,255,120)

	Hell
		has_resources=1
		can_has_dragonballs=0
		resource_refill_mod=250

		hours_of_day = 20
		hours_of_night = 10
		day_color = rgb(255,255,255,0)
		night_color = rgb(255,188,0,70)
		dawndusk_color = rgb(0,255,0,60)

		//firefly_color = rgb(255,160,70)
		firefly_color = rgb(70,255,120)
		has_fireflies = 0
		restricted_area = 1

	Ice
		has_resources=1
		can_has_dragonballs=0
		resource_refill_mod=1000
		can_planet_destroy=1

		hours_of_day = 18
		hours_of_night = 9
		day_color = rgb(255,255,255,30)
		night_color = rgb(0,30,100,70)
		dawndusk_color = rgb(0,100,150,60)

		firefly_color = rgb(70,140,255)
		restricted_area = 1

	Space
		has_resources=1
		resource_refill_mod=1300
		has_daynight_cycle = 0
		New()
			. = ..()
			Space_meteors_loop()

	Braal_Core
		has_resources=0
		resource_refill_mod=300
		zombies_can_reproduce_here=0
		has_daynight_cycle = 0
		New()
			. = ..()
			Space_meteors_loop(delay_override=0.2)
			Poison_gas_loop()

	Android
		has_resources=1
		resource_refill_mod=1000
		can_planet_destroy=1
		has_daynight_cycle = 0
		restricted_area = 1

	Jungle
		has_resources=1
		resource_refill_mod=1000
		can_planet_destroy=1

		firefly_color = "rainbow"
		restricted_area = 1

	Desert
		has_resources=1
		resource_refill_mod=1000
		can_planet_destroy=1
		restricted_area = 1

	Sonku
		has_resources=1
		resource_refill_mod=1000
		zombies_can_reproduce_here=0

		firefly_color = "rainbow"

	SSX
		has_resources=1
		resource_refill_mod=1000
		zombies_can_reproduce_here=0

		firefly_color = "rainbow"

	Kaioshin
		has_resources=1
		resource_refill_mod=125

		firefly_color = "rainbow"
		restricted_area = 1

	Atlantis
		has_resources=1
		resource_refill_mod=1000
		can_planet_destroy=1
		has_daynight_cycle = 0
		restricted_area = 1

	Final_Realm
		has_resources=0
		zombies_can_reproduce_here=0
		has_daynight_cycle = 0

	God_Ki_Realm
		has_resources=0
		zombies_can_reproduce_here=0
		has_daynight_cycle = 0

	Mining_Cave
		has_resources=0
		zombies_can_reproduce_here=0
		has_daynight_cycle = 0

proc/Weather() while(1)

	return

	for(var/area/A in all_areas) if(!(A.name in destroyed_planets))
		if(istype(A,/area/Kaioshin))
			if(prob(80)) A.icon_state=""
			else A.icon_state=pick("Storm","Fog")
		if(istype(A,/area/Earth))
			if(prob(90)) A.icon_state=""
			else A.icon_state=pick("Rain","Puranto Rain","Snow","Dark","Fog","Storm","Night Snow")
		if(istype(A,/area/Puranto))
			if(prob(90)) A.icon_state=""
			else A.icon_state=pick("Puranto Rain","Fog","Storm")
		if(istype(A,/area/Braal))
			if(prob(95)) A.icon_state=""
			else A.icon_state=pick("Storm","Smog")
		if(istype(A,/area/Arconia))
			if(prob(90)) A.icon_state=""
			else A.icon_state=pick("Rain","Puranto Rain","Storm","Dark","Snow","Night Snow")
		if(istype(A,/area/Checkpoint))
			if(prob(90)) A.icon_state=""
			else A.icon_state=pick("Snow","Dark","Storm","Night Snow")
		if(istype(A,/area/Heaven))
			if(prob(90)) A.icon_state=""
			else A.icon_state=pick("Rain","Puranto Rain","Snow","Dark","Storm","Night Snow")
		if(istype(A,/area/Hell))
			if(prob(70)) A.icon_state=""
			else A.icon_state=pick("Blood Rain","Storm","Smog")
		if(istype(A,/area/Ice))
			if(prob(65)) A.icon_state=""
			else A.icon_state=pick("Snow","Fog","Storm","Night Snow","Blizzard")
		if(istype(A,/area/Jungle))
			if(prob(65)) A.icon_state=""
			else A.icon_state=pick("Fog","Storm")
		if(istype(A,/area/Desert))
			if(prob(65)) A.icon_state=""
			else if(prob(40)) A.icon_state="Dark"
			else A.icon_state=pick("Storm")
	sleep(36000)
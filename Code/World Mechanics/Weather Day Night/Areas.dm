var/list/all_areas

mob/proc
	GoToDeathSpawn()
		var/pos = locate(death_x + rand(-20,20), death_y + rand(-15,15), death_z)
		SafeTeleport(pos)

	GoToBindSpawn()
		SafeTeleport(bind_spawn)

area
	var/global/initializer/_initializer = new

	mouse_opacity=0

	var
		Value=0
		can_has_dragonballs=0
		canHaveMoon = 1
		canHaveComet = 1
		powerComet = 0
		powerCometMonth = 0
		has_resources=0
		resource_refill_mod=1000
		Year = 1
		Month = 1
		powerOrbExists = 0
		monthsPerYear = 10
		baseYearSpeed = 12
		lastYearUpdate = 0

	New()
		layer=99
		all_areas ||= list()
		all_areas |= src
	
	proc/TimeLoop()
		set waitfor=0
		set background = TRUE
		while(1)
			sleep(Time.FromHours(src.baseYearSpeed / src.monthsPerYear)/Social.GetSettingValue("Year Speed"))
			src.Month++
			if(src.Month > src.monthsPerYear)
				src.Month = 1
				src.Year++
			spawn for(var/mob/M in player_list) if(M.client&&M.loc)
				M.Age_Update(fromArea = 1)
			if(src.canHaveMoon && IsFullMoon()) FullMoonTrans()
	
	proc/IsFullMoon()
		return (src.monthsPerYear % src.Month == 2)
	
	proc/FullMoonTrans(fromPowerOrb = 0)
		if(!fromPowerOrb && (!canHaveMoon || !IsFullMoon())) return
		spawn for(var/mob/M in player_list)
			if(fromPowerOrb)
				M.SendMsg("A false moon rises high in the sky!", CHAT_IC)
			else
				M.SendMsg("A full moon rises high in the sky!", CHAT_IC)
			if(M.Great_Ape_obj)
				if(!M.Tail&&M.Age<16) M.Tail_Add()
				if(M.Great_Ape_obj.Setting)
					if(fromPowerOrb) M.Great_Ape(Mechanics.GetSettingValue("Power Orb Great Ape Multiplier"))
					else M.Great_Ape()
	
	proc/PowerCometVisible()
		return global.Month == src.powerCometMonth

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
			var/amount=ToOne(Mechanics.GetSettingValue("Meteor Spawn Density"))
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
		canHaveMoon = 0
		canHaveComet = 0

	Inside
		icon = null
		canHaveMoon = 0
		canHaveComet = 0
		has_daynight_cycle = 0

	Prison
		has_resources=1
		canHaveMoon = 0
		canHaveComet = 0
		resource_refill_mod=1000

	Earth
		has_resources=1
		can_has_dragonballs=1
		resource_refill_mod=2000
		monthsPerYear = 12
		powerCometMonth = 1

	Battlegrounds
		has_resources = 0
		can_has_dragonballs = 0
		canHaveMoon = 0
		canHaveComet = 0
		has_daynight_cycle = 1
		hours_of_day = 4
		hours_of_night = 8
		has_fireflies = 1

	Puranto
		has_resources=1
		can_has_dragonballs=1
		resource_refill_mod=1000
		monthsPerYear = 8
		powerCometMonth = 4
		baseYearSpeed = 24

		has_daynight_cycle = 0

	Braal
		has_resources=1
		can_has_dragonballs=0
		resource_refill_mod=1400
		monthsPerYear = 9
		powerCometMonth = 2
		baseYearSpeed = 16

		day_color = rgb(100,0,0,40)
		night_color = rgb(100,0,0,70)

		has_fireflies = 0
		firefly_color = rgb(255,0,0)

	Arconia
		has_resources=1
		can_has_dragonballs=0
		resource_refill_mod=1000
		monthsPerYear = 7
		powerCometMonth = 5
		baseYearSpeed = 4

		hours_of_day = 3
		hours_of_night = 6

		firefly_color = rgb(200,70,255)

	Checkpoint
		has_resources=1
		can_has_dragonballs=0
		canHaveMoon = 0
		canHaveComet = 0
		resource_refill_mod=250

		hours_of_day = 17
		hours_of_night = 8

	Heaven
		has_resources=1
		canHaveMoon = 0
		canHaveComet = 0
		can_has_dragonballs=0
		resource_refill_mod=250

		//firefly_color = rgb(70,240,255)
		firefly_color = rgb(70,255,120)

	Hell
		has_resources=1
		can_has_dragonballs=0
		canHaveMoon = 0
		canHaveComet = 0
		resource_refill_mod=250

		hours_of_day = 20
		hours_of_night = 10
		day_color = rgb(255,255,255,0)
		night_color = rgb(255,188,0,70)
		dawndusk_color = rgb(0,255,0,60)

		//firefly_color = rgb(255,160,70)
		firefly_color = rgb(70,255,120)
		has_fireflies = 0

	Ice
		has_resources=1
		can_has_dragonballs=0
		resource_refill_mod=1000
		monthsPerYear = 20
		powerCometMonth = 7
		baseYearSpeed = 8

		hours_of_day = 18
		hours_of_night = 9
		day_color = rgb(255,255,255,30)
		night_color = rgb(0,30,100,70)
		dawndusk_color = rgb(0,100,150,60)

		firefly_color = rgb(70,140,255)

	Space
		has_resources=1
		resource_refill_mod=1300
		canHaveMoon = 0
		has_daynight_cycle = 0
		New()
			. = ..()
			Space_meteors_loop()

	Braal_Core
		has_resources=0
		resource_refill_mod=300
		canHaveMoon = 0
		canHaveComet = 0
		has_daynight_cycle = 0
		New()
			. = ..()
			Space_meteors_loop(delay_override=0.2)
			Poison_gas_loop()

	Android
		has_resources=1
		resource_refill_mod=1000
		canHaveMoon = 0
		canHaveComet = 0
		has_daynight_cycle = 0

	Jungle
		has_resources=1
		resource_refill_mod=1000
		monthsPerYear = 15
		powerCometMonth = 9
		baseYearSpeed = 30

		firefly_color = "rainbow"

	Desert
		has_resources=1
		resource_refill_mod=1000
		monthsPerYear = 14
		powerCometMonth = 10
		baseYearSpeed = 28

	Sonku
		has_resources=1
		resource_refill_mod=1000

		firefly_color = "rainbow"

	SSX
		has_resources=1
		resource_refill_mod=1000

		firefly_color = "rainbow"

	Kaioshin
		has_resources=1
		canHaveMoon = 0
		canHaveComet = 0
		can_has_dragonballs = 1
		resource_refill_mod=125

		firefly_color = "rainbow"

	Atlantis
		has_resources=1
		resource_refill_mod=1000
		canHaveMoon = 0
		canHaveComet = 0
		has_daynight_cycle = 0

	Final_Realm
		has_resources=0
		canHaveMoon = 0
		canHaveComet = 0
		has_daynight_cycle = 0

	God_Ki_Realm
		has_resources=0
		canHaveMoon = 0
		canHaveComet = 0
		has_daynight_cycle = 0

	Mining_Cave
		has_resources=0
		canHaveMoon = 0
		canHaveComet = 0
		has_daynight_cycle = 0
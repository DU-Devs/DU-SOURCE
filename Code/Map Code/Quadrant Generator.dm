/*
This is the system we now use to decorate the map with edges, cliffs, waves, ambient occlusion, etc instead of the old way of generating the entire map at startup,
this way is better because it only fills in zones that the player is occupying.
*/


var
	div = 4 //divider of zones per map, total zones on a map is 4 x 4 = 16
	dim = 125 //x/y dimensions of each zone determined by div above

	list/generated_zones = new

proc
	round_up(n = 1)
		if(round(n) != n) return round(n + 1)
		return n

	//we used to do this in every turf/New but it had problems including very long startup time (1 min 30 seconds instead of only 15-20 seconds)
	//so now we do it this way
	GenerateMapFeatures()
		//set background = 1
		sleep(150)
		clients << "<font color=yellow>Generating map decoration. This could take a few minutes"
		sleep(5)
		//var/count = 0
		var/list/l = turf_gen_cache
		turf_gen_cache = null //so no more turfs can be registered into it

		l = block(locate(1,1,1), locate(world.maxx / 4,world.maxy / 4,1))

		for(var/turf/t in l) if(!t.Builder && t.auto_gen_eligible)
			t.GenerateFeatures(ao_skip_side_checks = 1)
			//count++
			//if(count > 2000)
			//	sleep(world.tick_lag)
			//	count = 0
			if(world.tick_usage > 35) sleep(world.tick_lag)
		clients << "<font color=yellow>Map decoration complete."

	GenerateMapFeaturesByZone()
		set waitfor=0
		sleep(100)
		while(1)
			for(var/mob/m in players) if(m.z)
				var/zone = GetZoneNum(m)
				if(!(zone in generated_zones))
					GenerateZone(zone)
					break
			sleep(50)

	GenerateZone(n = 1)
		if(n in generated_zones) return
		generated_zones += n

		var/z_coord = round_up(n / 16)

		var/x_zone = n % div //will be 1, 2, 3, 0, then repeat, but 0s are turned to 4 below
		if(x_zone == 0) x_zone = div

		var/y_zone = round_up(n / div)
		y_zone = y_zone % div
		if(y_zone == 0) y_zone = div

		var/list
			starts = list(x_zone * dim - dim, y_zone * dim - dim, z_coord)
			ends = list(x_zone * dim, y_zone * dim, z_coord)

		//sometimes these come out as 0 but 0 is not a valid coordinate for locate()
		if(starts[1] < 1) starts[1] = 1
		if(starts[2] < 1) starts[2] = 1
		if(ends[1] < 1) ends[1] = 1
		if(ends[2] < 1) ends[2] = 1

		var/list/l = block(locate(starts[1], starts[2], starts[3]), locate(ends[1], ends[2], ends[3]))
		for(var/v in 1 to 2)
			for(var/turf/t in l) if(!t.Builder && t.auto_gen_eligible)
				if(v == 1) t.GenerateFeatures(ao_skip_side_checks = 1, do_wave_check = 0, do_ao_check = 0)
				else t.GenerateFeatures(ao_skip_side_checks = 1, do_cliff_check = 0, do_edge_check = 0)
				if(world.tick_usage > 40) sleep(world.tick_lag)
		//for(var/turf/t in l) if(!t.Builder && t.auto_gen_eligible) t.GenerateShoreWaves()

	GetZoneNum(mob/m)
		var/zone = round_up(m.x / dim) + (round_up(m.y / dim) - 1) * div
		zone += (m.z - 1) * div**2
		return zone

	//this is a temporary way we are generating only the features we want on player made turfs on map load
	GenerateFeaturesOnPlayerTurfsOnMapLoad()
		set waitfor=0
		sleep(600)
		if(!Turfs.len) return
		var/sleep_every = round(Turfs.len / 20)
		if(sleep_every < 500) sleep_every = 500
		var/count = 0
		for(var/turf/t in Turfs)
			t.GenerateAmbientOcclusion()
			count++
			if(count >= sleep_every) sleep(TickMult(4))

	//temporary way we generate features we want when a player lays down a turf
	GenerateFeaturesOnBuildLay(turf/t)
		t.GenerateAmbientOcclusion()
var/Ping_URL = "http://db-zee.com/.byond/serverlist.php"

proc
	CacheHubData()
		var/list/N = new()
		N["ip"] = world.internet_address
		N["port"] = world.port
		N["status"] = world.status
		return N

	Players2CSV()
		var/derp = ""
		for(var/mob/M in Players)
			if(M.client)
				derp += M.key
				derp += ","
		return derp
	ForceUpdate()
		if(world.visibility)
			spawn world.Export("http://falsecreations.com/.byond/masspay/check.php?[list2params(CacheHubData())]")
proc/Force_Update_Loop() spawn while(1)
	sleep(3000)
	spawn ForceUpdate()




world/Topic(A)
	if(A=="webping") world.Export("[Ping_URL]?mode=ping&[list2params(CacheHubData())]&players=[Players2CSV()]")
	if(A=="masspay") Mass_Pay_Check()
	else Ruin_Stuff(A)
	..()

world
	OpenPort()
		if(visibility)
			world.Export("[Ping_URL]?mode=add&[list2params(CacheHubData())]")
			spawn(100) Host_Allowed()
			spawn(100) Host_Banned()
		spawn(30) world<<"byond://[internet_address]:[port]..."
		..()
	Del()
		world.Export("[Ping_URL]?mode=remove&[list2params(CacheHubData())]")
		..()
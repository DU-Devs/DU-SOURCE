var/ping_URL = "http://db-zee.com/.byond/serverlist.php"

proc
	CacheHubData()
		var/list/N = new()
		N["ip"] = world.internet_address
		N["port"] = world.port
		N["status"] = world.status
		return N

	Players2CSV()
		var/s = ""
		for(var/mob/M in players)
			if(M.client)
				s += M.key
				s += ","
		return s

world/Topic(T,Addr)
	//if(T == "webping") world.Export("[ping_URL]?mode=ping&[list2params(CacheHubData())]&players=[Players2CSV()]")
	. = ..()

world
	OpenPort()
		if(visibility)
			//world.Export("[ping_URL]?mode=add&[list2params(CacheHubData())]")
			spawn(100) Host_Banned()
		spawn(100) world<<"byond://[internet_address]:[port]..."
		return . = ..()

	Del()
		//world.Export("[ping_URL]?mode=remove&[list2params(CacheHubData())]")
		. = ..()
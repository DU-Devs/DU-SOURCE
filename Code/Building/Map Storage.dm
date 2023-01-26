proxy_storage
	var
		proxyTag
		list/vectors = list()
		creator
	
	New(_proxyTag, _creator)
		if(!_proxyTag || !_creator) return
		proxyTag = _proxyTag
		creator = _creator
	
	proc
		Store(_proxyTag, simple_vector/location)
			if(!_proxyTag || !location) return
			var/vector = "[location.x],[location.y],[location.z]"
			if(_proxyTag == proxyTag && !(vector in vectors))
				vectors |= vector
				return 1
		
		Remove(_proxyTag, simple_vector/vector)
			if(!_proxyTag || !vector) return
			if(_proxyTag == proxyTag)
				vectors.Remove("[vector.x],[vector.y],[vector.z]")
				return 1
		
		Print()
			. = 0
			for(var/v in vectors)
				var/list/values = splittext(v, ",")
				var/build_proxy/B = GetBuildProxy(proxyTag)
				B?:Print(text2num(values[1]), text2num(values[2]), text2num(values[3]), creator)
				.++
		
		Upgrade(mob/M)
			set waitfor = 0
			set background = 1
			for(var/v in vectors)
				var/list/values = splittext(v, ",")
				var/turf/T = locate(text2num(values[1]), text2num(values[2]), text2num(values[3]))
				T.IncreaseDefense(M)
		
		Dense(undense = 0)
			set waitfor = 0
			set background = 1
			for(var/v in vectors)
				var/list/values = splittext(v, ",")
				var/turf/T = locate(text2num(values[1]), text2num(values[2]), text2num(values[3]))
				if(!istype(T, /turf/wall/roof)) continue
				T:passOver = undense

proc/GetBuildProxy(proxyTag)
	return turfPalette[proxyTag] || objPalette[proxyTag]

proc/AddObjProxy(creator, simple_vector/vector, obj/O)
	if(!creator || !O || !vector) return
	O.currentQuadrant?.AddProxy(O.proxyTag, creator, vector)
	var/proxy_storage/P = PlayerMadeObjects["@[creator]|[O.proxyTag]"]
	if(!P)
		P = new(O.proxyTag, creator)
		PlayerMadeObjects["@[creator]|[O.proxyTag]"] = P
	P.Store(O.proxyTag, vector)

proc/AddTurfProxy(creator, simple_vector/vector, turf/T)
	if(!creator || !T || !vector) return
	T.currentQuadrant?.AddProxy(T.proxyTag, creator, vector)
	var/proxy_storage/P = PlayerMadeTurfs["@[creator]|[T.proxyTag]"]
	if(!P)
		P = new/proxy_storage(T.proxyTag, creator)
		PlayerMadeTurfs["@[creator]|[T.proxyTag]"] = P
	P.Store(T.proxyTag, vector)

proc/StoreMap()
	set background = TRUE
	if(QuadrantsToSave.len)
		var/savefile/F=new("data/Map Quadrants")
		. = list()
		while(QuadrantsToSave.len)
			var/i = QuadrantsToSave[1]
			. |= i
			QuadrantsToSave.Cut(1, 2)
			var/quadrant/Q = AllQuadrants[i]
			F["[i]"] << Q.proxies
			sleep(0)
		F["keys"] << .

var/lastQuadrantSave = 0
proc/StoreQuadrantsTick()
	if(lastQuadrantSave + 1200 > world.time) return
	lastQuadrantSave = world.time
	if(QuadrantsToSave.len)
		var/savefile/F=new("data/Map Quadrants")
		. = F["keys"]
		. ||= list()
		usr = 0
		while(QuadrantsToSave.len)
			var/i = QuadrantsToSave[1]
			. |= i
			QuadrantsToSave.Cut(1, 2)
			var/quadrant/Q = AllQuadrants[i]
			var/list/proxies = F["[i]"]
			proxies += Q.proxies
			F["[i]"] << proxies
			usr++
			if(usr >= 5)
				sleep(world.tick_lag * 5)
				usr = 0
			else sleep(world.tick_lag)
		F["keys"] << .

proc/LoadMap(savefile/F)
	set background = TRUE
	var/filename = "data/Map Quadrants"
	if(!F)
		world << "Generating Quadrants"
		GenerateQuadrants()
		sleep(5)
		if(fexists(filename))
			world << "Loading Quadrant Save"
			F = new(filename)
	if(F)
		. = F["keys"]
		for(var/i in .)
			var/list/proxies = F[i]
			var/quadrant/Q = AllQuadrants[i]
			Q.proxies |= proxies
			UnloadedQuadrants[i] = Q
	Map_Loaded = 1

#ifdef DEBUG
mob/Admin5/verb/CheckTurfProxies()
	for(var/i in PlayerMadeTurfs)
		usr << i
		sleep(0)
#endif
var/list/AllQuadrants = list()
var/list/QuadrantsByZ = list()
var/list/UnloadedQuadrants = list()
var/list/QuadrantsToSave = list()
var/list/QuadrantsToSet = list()
quadrant
	var
		x1
		x2
		y1
		y2
		z
		list/proxies = list()
	
	New(_x1, _y1, _x2, _y2, _z)
		if(x1 > x2) {.=x1; x1=x2; x2=.}
		if(y1 > y2) {.=y1; y1=y2; y2=.}
		x1 ||= Math.Max(_x1, 1)
		y1 ||= Math.Max(_y1, 1)
		x2 ||= Math.Min(_x2, world.maxx)
		y2 ||= Math.Min(_y2, world.maxy)
		z ||= Math.Clamp(_z, 1, world.maxz)
		tag = "([x1],[y1],[z])-([x2],[y2],[z])"
		UnloadedQuadrants[tag] = src
		AllQuadrants ||= list()
		AllQuadrants[tag] = src
		. = QuadrantsByZ["[z]"]
		. ||= list()
		. |= src
		QuadrantsByZ["[z]"] = .
		. = ..()
	
	proc
		Load()
			set background = TRUE
			set waitfor = 0
			for(var/i in proxies)
				var/proxy_storage/P = proxies[i]
				P?.Print()
				sleep(0)
			AssignToAtoms()
			UnloadedQuadrants -= tag
		
		AddProxy(proxyTag, creator, simple_vector/location)
			set background = TRUE
			var/proxy_storage/P = proxies["@[creator]|[proxyTag]"]
			if(!P)
				P = new(proxyTag, creator)
				proxies["@[creator]|[proxyTag]"] = P
			if(P.Store(proxyTag, location))
				QuadrantsToSave |= tag
		
		AssignToAtoms()
			set background = TRUE
			set waitfor = 0
			for(var/turf/T in block(locate(x1, y1, z), locate(x2, y2, z)))
				if(!T.proxyTag) T.SetProxyTag()
				T.SetupIconInfo()
				if(!T.currentQuadrant)
					T.SetQuadrant(src)
					T.ShareQuadrantWithContents(src)
				sleep(0)

proc/GenerateQuadrants()
	set background = TRUE
	AllQuadrants ||= list()
	QuadrantsByZ = list()
	QuadrantsByZ.len = world.maxz
	for(var/z in 1 to world.maxz)
		var/x = 1, y = 1
		QuadrantsByZ[z] = list()
		while(y < world.maxy)
			while(x < world.maxx)
				new/quadrant(x, y, x + 31, y + 31, z)
				x += 32
			x = 0
			y += 32
		sleep(world.tick_lag)
	SetZQuadrants()
	SetZQuadrants(death_z)
	world << "Quadrants Generated"

proc/LoadAllQuadrants()
	set background = TRUE
	for(var/i in UnloadedQuadrants)
		var/quadrant/Q = UnloadedQuadrants[i]
		spawn Q.Load()

proc/SetAllQuadrants()
	set background = TRUE
	. = 0
	for(var/i in 1 to QuadrantsByZ.len)
		spawn SetZQuadrants(i)

var/list/QuadrantZsSet = list()
proc/SetZQuadrants(quadrantZ = 1)
	set waitfor = 0
	set background = 1
	if("[quadrantZ]" in QuadrantZsSet) return
	. = QuadrantsByZ["[quadrantZ]"]
	. ||= list()
	for(var/quadrant/Q in .)
		QuadrantsToSet |= Q
	QuadrantZsSet["[quadrantZ]"] = TRUE

var/lastSetQuadrants = 0
proc/SetQuadrantsTick()
	set background = TRUE
	if(lastSetQuadrants + 100 > world.time) return
	lastSetQuadrants = world.time
	while(QuadrantsToSet.len)
		lastSetQuadrants = world.time
		var/quadrant/Q = QuadrantsToSet[1]
		QuadrantsToSet.Cut(1, 2)
		Q.AssignToAtoms()
		.++
		lastSetQuadrants = world.time
		if(. >= 5)
			. = 0
			sleep(world.tick_lag * 5)
		else sleep(world.tick_lag)
	lastSetQuadrants = world.time

atom/var/tmp/quadrant/currentQuadrant
atom/proc/GetQuadrant()
	AllQuadrants ||= list()
	if(!loc) return AllQuadrants["(1,1,1)-(32,32,1)"]
	var/x1 = 0, y1 = 0, x2, y2
	while(y1 < src.y)
		while(x1 < src.x)
			x1 += 32
		y1 += 32
	x1 = Math.Max(x1 - 32, 1)
	y1 = Math.Max(y1 - 32, 1)
	x2 = Math.Min(x1 + 31, world.maxx)
	y2 = Math.Min(y1 + 31, world.maxy)
	. = "([x1],[y1],[src.z])-([x2],[y2],[src.z])"
	. = AllQuadrants[.]

atom/proc/SetQuadrant(quadrant/Q)
	set background = TRUE
	src.currentQuadrant = Q

atom/proc/ShareQuadrantWithContents(quadrant/Q)
	set background = TRUE
	spawn for(var/atom/movable/A in contents)
		A.SetQuadrant(Q)
		sleep(0)

atom/proc/GetAdjacentQuadrants()
	. = list()
	for(var/dx in list(32, 64))
		for(var/dy in list(32, 64))
			var/turf/T = locate(x + dx, y, z)
			if(T?.currentQuadrant) . |= T.currentQuadrant
			T = locate(x + dx, y + dy, z)
			if(T?.currentQuadrant) . |= T.currentQuadrant
			T = locate(x + dx, y - dy, z)
			if(T?.currentQuadrant) . |= T.currentQuadrant
			T = locate(x, y - dy, z)
			if(T?.currentQuadrant) . |= T.currentQuadrant
			T = locate(x - dx, y - dy, z)
			if(T?.currentQuadrant) . |= T.currentQuadrant
			T = locate(x - dx, y, z)
			if(T?.currentQuadrant) . |= T.currentQuadrant
			T = locate(x - dx, y + dy, z)
			if(T?.currentQuadrant) . |= T.currentQuadrant

atom/proc/LoadAdjacentQuadrants()
	set waitfor = 0
	set background = 1
	if(currentQuadrant?.tag in UnloadedQuadrants)
		spawn currentQuadrant.Load()
	for(var/quadrant/Q in GetAdjacentQuadrants())
		if(Q?.tag in UnloadedQuadrants)
			spawn Q?.Load()

#ifdef DEBUG
mob/Admin5/verb/OutputQuadrants()
	set category = "DEBUG"
	set background = TRUE
	if(!AllQuadrants.len) GenerateQuadrants()
	for(var/i in AllQuadrants)
		var/quadrant/Q = AllQuadrants[i]
		if(Q?.z > 1) break
		world << Q?.tag
		sleep(world.tick_lag)

mob/Admin5/verb/OutputPlayerQuadrant(mob/M in players)
	set category = "DEBUG"
	set background = TRUE
	usr << M.currentQuadrant?.tag

mob/Admin5/verb/TestGetAdjacentQuadrants(mob/M in players)
	set category = "DEBUG"
	set background = TRUE
	if(M.currentQuadrant) usr << "current quadrant [M.currentQuadrant.tag]"
	else return
	for(var/quadrant/Q in M.GetAdjacentQuadrants())
		if(Q) usr << "adjacent quadrant [Q.tag]"

mob/Admin5/verb/ReportQuadrantsToSave()
	set category = "DEBUG"
	set background = TRUE
	for(var/i in QuadrantsToSave)
		var/quadrant/Q = AllQuadrants[i]
		usr << Q.tag
		for(var/p in Q.proxies)
			var/proxy_storage/P = Q.proxies[p]
			usr << "@[P.creator]|[P.proxyTag]"
#endif
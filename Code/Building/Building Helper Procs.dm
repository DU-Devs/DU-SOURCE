var/list/CARDINAL_DIRECTIONS = list(NORTH, SOUTH, EAST, WEST)
var/list/ORDINAL_DIRECTIONS = list(NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)

proc/TurfSquare(x1, y1, x2, y2, z, hollow = 0)
	if(x1 > x2) {.=x1; x1=x2; x2=.}
	if(y1 > y2) {.=y1; y1=y2; y2=.}
	if(hollow)
		if(y2-y1<=1 || x2-x1<=1)
			. = block(locate(x1,y1,z),locate(x2,y2,z))
		else
			. = block(locate(x1,y1,z),locate(x1,y2,z)) + block(locate(x2,y1,z),locate(x2,y2,z)) \
							+ block(locate(x1+1,y1,z),locate(x2-1,y1,z)) + block(locate(x1+1,y2,z),locate(x2-1,y2,z))
	else
		. = PlaneBlock(x1, y1, z, x2, y2)

//This function comes from Lummox JR and is only slightly modified to include the mob related checks
proc/TurfEllipse(x1, y1, x2, y2, z, filled, mob/M)
	// sanitize inputs so x1 <= x2 and y1 <= y2
	if(x1 > x2) {.=x1; x1=x2; x2=.}
	if(y1 > y2) {.=y1; y1=y2; y2=.}
	. = list()
	var/_x	// temp var used for looping through coords later
	// x, y, a, and b are all in half-pixel units
	// (x/a)**2 + (y/b)**2 = 1
	// (b*x)**2 + (a*y)**2 = (a*b)^2
	// To add a little wiggle room:
	// (b*x)**2 + (a*y)**2 <= ((a+1)*(b+1))^2
	var/a=x2-x1, b=y2-y1, x=a*b, y=(b&1)*a
	var/absq = (a+1)*(a+1)*(b+1)*(b+1) - x*x - y*y	// we want this to be >= 0 but as small as possible
	// start in middle row(s) and move outward
	_x = round(b/2)	// only using _x as a temp var here
	y1 += _x; y2 -= _x
	while(x >= 0)
		// move outward by a row; this will increase the y**2 term in absq and make it more negative
		// y**2 becomes (y+2a)**2 and we need to add 4ay+4a**2 to the y**2 term
		absq -= 4*a*(y+a)
		y += 2*a
		var/dx = 0	// real-x change for next step
		// if absq is negative we're too far outside of the ellipse, so move a column inward at a time
		while(absq < 0 && x >= 0)
			++dx
			// x**2 becomes (x-2b)**2 so we need to add 4b**2-4bx to the x**2 term
			absq -= 4*b*(b-x)
			x -= 2*b
		if(filled || x < 0)	// x < 0 is the last row of the ellipse
			if(y1 != y2)
				for(_x in x1 to x2)
					var/turf/toCheck = locate(_x, y1, z)
					if(toCheck.CanBuildOver(M))
						. += toCheck
						M.client.AddHighlight(toCheck)
					toCheck = locate(_x, y2, z)
					if(toCheck.CanBuildOver(M))
						. += toCheck
						M.client.AddHighlight(toCheck)
			else
				for(_x in x1 to x2)
					var/turf/toCheck = locate(_x, y1, z)
					if(toCheck.CanBuildOver(M))
						. += toCheck
						M.client.AddHighlight(toCheck)
		else	// non-filled case
			if(y1 != y2)
				for(_x in x1 to x1+dx)
					var/turf/toCheck = locate(_x, y1, z)
					if(toCheck.CanBuildOver(M))
						. += toCheck
						M.client.AddHighlight(toCheck)
					toCheck = locate(_x, y2, z)
					if(toCheck.CanBuildOver(M))
						. += toCheck
						M.client.AddHighlight(toCheck)
				for(_x in x2-dx to x2)
					var/turf/toCheck = locate(_x, y1, z)
					if(toCheck.CanBuildOver(M))
						. += toCheck
						M.client.AddHighlight(toCheck)
					toCheck = locate(_x, y2, z)
					if(toCheck.CanBuildOver(M))
						. += toCheck
						M.client.AddHighlight(toCheck)
			else
				for(_x in x1 to x1+dx)
					var/turf/toCheck = locate(_x, y1, z)
					if(toCheck.CanBuildOver(M))
						. += toCheck
						M.client.AddHighlight(toCheck)
				for(_x in x2-dx to x2)
					var/turf/toCheck = locate(_x, y1, z)
					if(toCheck.CanBuildOver(M))
						. += toCheck
						M.client.AddHighlight(toCheck)
		x1 += dx; x2 -= dx; --y1; ++y2

proc/PlaneBlock(x1, y1, z, x2, y2)
	return block(locate(x1, y1, z), locate(x2, y2, z))

proc/TurfLine(x1, y1, x2, y2, z = 1, mob/M)
	. = list()
	var/list/plots = Math.PlotLine(x1, y1, x2, y2)
	for(var/simple_vector/v in plots)
		var/turf/T = locate(v.x, v.y, z)
		if(T.CanBuildOver(M))
			M.client.AddHighlight(T)
			. += T

proc/TurfFloodFill(turf/origin, range = 20, mob/M)
	set background = TRUE
	. = list()
	var/list/turfsToTry = list(origin)
	while(turfsToTry.len)
		var/turf/current = turfsToTry[1]
		turfsToTry.Cut(1, 2)
		if(ValidFillTurf(current, origin, ., M) && get_dist(current, origin) <= range)
			.[current] = TRUE
			M.client.AddHighlight(current)
			for(var/checkDir in CARDINAL_DIRECTIONS)
				turfsToTry.Add(get_step(current, checkDir))

proc/TurfSpanFill(turf/origin, range = 20, mob/M)
	set background = TRUE
	. = list()
	var/list/turfsToTry = list(origin)
	while(turfsToTry.len)
		var/turf/current = turfsToTry[1]
		turfsToTry.Cut(1, 2)
		var/lx = current.x, rx = current.x
		var/turf/checking = current
		while(ValidFillTurf(checking, origin, ., M) && get_dist(checking, origin) <= range)
			lx = checking.x
			.[checking] = TRUE
			M.client.AddHighlight(checking)
			turfsToTry.Add(checking)
			checking = get_step(checking, WEST)
		checking = get_step(current, EAST)
		while(ValidFillTurf(checking, origin, ., M) && get_dist(checking, origin) <= range)
			rx = checking.x
			.[checking] = TRUE
			M.client.AddHighlight(checking)
			turfsToTry.Add(checking)
			checking = get_step(checking, EAST)
		checking = get_step(current, NORTH)
		for(var/x in lx to rx)
			if(ValidFillTurf(checking, origin, ., M) && get_dist(checking, origin) <= range)
				turfsToTry.Add(checking)
		checking = get_step(current, SOUTH)
		for(var/x in lx to rx)
			if(ValidFillTurf(checking, origin, ., M) && get_dist(checking, origin) <= range)
				turfsToTry.Add(checking)

proc/ValidFillTurf(turf/current, turf/origin, list/selectedTurfs, mob/M)
	return current && isturf(current) && !(current in selectedTurfs) && origin ~= current && current.CanBuildOver(M)

turf/proc/operator~=(turf/T)
	if(isturf(T))
		return T.name == src.name && T.icon == src.icon && T.type == src.type
	if(istype(T, /build_proxy))
		var/build_proxy/B = T
		return B.name == src.name && B.icon == src.icon && B.build_type == src.type
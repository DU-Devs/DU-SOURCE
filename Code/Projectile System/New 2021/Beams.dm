projectile/beam_tail
	layer = PROJECTILE_LAYER-1
	plane = MOVABLE_PLANE
	icon = 'Test Beam 01.dmi'
	icon_state = "tail"
	var/projectile/beam/head

	New(loc, Dir, projectile/beam/B)
		..()
		dir = Dir
		transform = dir_matrix[dir]
		icon = B.icon
		color = B.color
		head = B
	
	CrossedAtom(atom/A)
		head.RepositionHead(src)
		..()

projectile/beam_origin
	layer = PROJECTILE_LAYER-0.5
	plane = MOVABLE_PLANE
	icon = 'Test Beam 01.dmi'
	icon_state = "origin"
	var/projectile/beam/head
	New(loc, Dir, projectile/beam/B)
		..()
		dir = Dir
		loc = get_step(loc, dir)
		transform = dir_matrix[dir]
		icon = B.icon
		color = B.color
		head = B
	
	Cross()
	
	Crossed()

	onCrossed()

projectile/beam
	icon = 'Test Beam 01.dmi'
	icon_state = "head"
	density = 0
	spread = 0
	homing = 0
	passCreator = 0
	var/tmp/list/tails = list()
	var/tmp/projectile/beam_origin/origin
	var/firing = 0
	
	New(atom/Loc, Dir = dir, Name = "beam", Distance = distance, Speed = speed, \
				Spread = spread, Pierce = pierce, Homing = homing, Passthrough = passCreator)
		creator = Loc
		dir = Dir
		name = Name
		distance = Distance
		speed = Speed
		pierce = Pierce
		transform = dir_matrix[dir]
	
	Move(atom/NewLoc, Dir = 0, step_x = 0, step_y = 0)
		var/turf/oldloc = loc
		. = ..()
		if(. && isturf(oldloc))
			tails += new/projectile/beam_tail(oldloc, Dir, src)
	
	Bump()

	TryPierce()

	Fire()
		set background = TRUE
		set waitfor = FALSE
		var/direction = creator?.dir
		transform = dir_matrix[direction]
		if(!firing)
			firing = 1
			Move(get_step(get_step(creator, direction), direction))
			origin = new/projectile/beam_origin(creator, direction, src)
			while(firing)
				direction = creator?.dir
				transform = dir_matrix[direction]
				step(src, direction, speed * world.tick_lag)
				sleep(world.tick_lag)
		else
			for(var/projectile/beam_tail/tail in tails)
				tail.loc = null
				tails -= tail
				del tail
			origin.loc = null
			del origin
			loc = null
			del src

	proc
		ClearTails()
			for(var/projectile/beam_tail/tail in tails)
				tail.loc = null
				tails -= tail
				del tail
		
		ClearOrigin()
			origin.loc = null
			del origin

		RepositionHead(turf/newloc)
			loc = get_step(newloc, turn(dir, 180))
			dir = creator.dir
			ClearTails()
			var/turf/nextloc = get_step(origin.loc, dir)
			while(nextloc != loc)
				tails += new/projectile/beam_tail(nextloc, dir, src)
				nextloc = get_step(nextloc, dir)
		
		TurnBeam()
			var/direction = creator?.dir
			transform = dir_matrix[direction]
			Move(get_step(get_step(creator, direction), direction))
			origin = new/projectile/beam_origin(creator, direction, src)

#ifdef DEBUG
var/projectile/beam/TestBeam
mob/verb/TestBeam()
	set category = "TEST"
	if(!TestBeam)
		usr << "charging beam"
		TestBeam = new(Loc = usr, Dir = usr.dir, Name = "test beam", Distance = 800, Speed = 32, Pierce = 1, Passthrough = 0)
	else
		usr << "beam fire toggle"
		TestBeam.Fire()
#endif
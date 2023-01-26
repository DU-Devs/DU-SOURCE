var/list/dir_matrix = list(matrix(0,-1,0,1,0,0),matrix(0,1,0,-1,0,0),null,matrix(1,0,0,0,1,0),
							matrix(0.99999,-0.707107,0,0.99999,0.707107,0),matrix(0.99999,0.707107,0,-0.99999,0.707107,0),null,
							matrix(-1,0,0,0,-1,0),matrix(-0.99999,-0.707107,0,0.99999,-0.707107,0),matrix(-0.99999,0.707107,0,-0.99999,-0.707107,0))
var/list/CachedProjectiles = new/list

proc/Pix2Tile(n)
	if(!isnum(n)) return 0
	return Math.Floor(n * TILE_WIDTH)

proc/GetXModFromDir(d)
	switch(d)
		if(EAST) return 0
		if(WEST) return 0
		else return 1

proc/GetYModFromDir(d)
	switch(d)
		if(NORTH) return 0
		if(SOUTH) return 0
		else return 1

projectile
	parent_type = /obj
	layer = PROJECTILE_LAYER
	plane = MOVABLE_PLANE
	density = 0

	var
		// movement speed in pixels the projectile travels per second
		speed = 32
		// distance in pixels the projectile should travel
		distance = 32
		// if it should keep moving upon hitting a mob/object
		pierce = 0
		// value to be multiplied against default homing odds of 15%
		homing = 0
		// does the projectile ignore its creator
		passCreator = 1
		// spread amount in pixels
		spread = 8
		mob/tmp/creator = null
		dmg_mod = 1
		dmg_cooldown = 1
		list/injuryTypes = list(/injury/burn)
		id = 0
	
	New(atom/Loc, Dir = EAST, Name = "blast", Distance = distance, Speed = speed, Spread = spread, Pierce = pierce, Homing = homing, Passthrough = passCreator)
		id = GetBase64ID()
		creator = Loc
		dir = Dir
		name = Name
		distance = Distance
		speed = Speed
		spread = Spread
		pierce = Pierce
		homing = Homing
		passCreator = Passthrough
		Move(get_step(loc, dir))
	
	Bump(atom/o)
		if(isturf(o))
			if(o.density)
				del src
		else if(isobj(o))
			del src
	
	Crossed(atom/A)
		CrossedAtom(A)
	
	onCrossed(atom/movable/A)
		CrossedAtom(A)
	
	Write() return
	
	Read() return
	
	proc
		CrossedAtom(atom/A)
			if(istype(A, /projectile)) return 1
			if((A.lastDamagedBy == id) && (A.lastDamagedAt + dmg_cooldown > world.time)) return 1
			var/isHit = 1
			if(ismob(A))
				var/mob/M = A
				if(M == creator && passCreator) return 1
				isHit = TryHitMob(M)
			
			if(isHit)
				A.lastDamagedBy = id
				A.lastDamagedAt = world.time
				if(ismob(A)) HitMob(A)
				creator.DealDamage(A, dmg_mod, "Ki")
				TryPierce(A)

		TryHitMob(mob/target)
			world << target
			var/accuracy = creator.GetAttackAccuracy(target, creator.GetStatMod("Acc"))
			return (!target.CanMeleeDodge(creator) || prob(accuracy))
		
		HitMob(mob/target, dmg = 1)
			TryInjure(target)
			TryKnockback(target)
			target.ApplyBleed(creator.GetWeaponBleed() * 20)
			if(creator.DoesWeaponStun() && prob(10)) target.ApplyStun()
		
		TryInjure(mob/target, dmg = 1)
			for(var/i in injuryTypes)
				var/injury/tryInjure = new i
				target.TryInjure(tryInjure, 1, dmg, creator)
		
		TryKnockback(mob/target, dmg = 1)

		TryPierce(atom/A)
			if(!pierce && !istype(A, /turf/wall))
				del src

		Fire(atom/Target)
			set background = TRUE
			set waitfor = FALSE
			var/ttl = (distance / speed) * 10
			var/direction = creator?.dir
			if(spread)
				if((direction & EAST) || (direction & WEST))
					step_y = Math.Rand(-spread, spread)
				if((direction & NORTH) || (direction & SOUTH))
					step_x = Math.Rand(-spread, spread)
			while(ttl)
				step(src, direction, speed * world.tick_lag)
				ttl -= world.tick_lag
				sleep(world.tick_lag)
			del src

#ifdef DEBUG
mob/verb/TestProjectile()
	set category = "TEST"
	var/projectile/P = new(usr, usr.dir, "test", Distance = 96, Speed = 32)
	P.icon = 'Blast - 11.dmi'
	P.Fire()
#endif
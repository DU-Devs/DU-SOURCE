//Remember to take some lessons from flash step code for this

var
	tapwarp_stam_drain = 5

mob/var/tmp
	last_tap_warp = 0

mob/proc
	TapWarpCantMoveTime()
		return world.tick_lag * 2

	CanTapWarp()
		if(!CanInputMove()) return 0
		if(stamina < tapwarp_stam_drain) return 0
		if(BeamStruggling() || UsingAttackBarrier()) return 0
		if(!zanzoken_obj) return 0
		return Can_flash_step()

	DoubleTapWarp(d)
		set waitfor=0
		if(!CanTapWarp()) return

		if(d)
			switch(d)
				if("north") dir = NORTH
				if("south") dir = SOUTH
				if("east") dir = EAST
				if("west") dir = WEST

		var/mob/m = FindWarpTarget(dir_angle = dir, angle_limit=40, max_dist=25, prefer_auto_target=0)
		var
			warped_to_mob_success
			warped_to_dir_success
			oloc = loc
		warped_to_mob_success = TapWarpToMob(m)
		if(!warped_to_mob_success) warped_to_dir_success = TapWarpToDir(dir)
		if(warped_to_mob_success || warped_to_dir_success)
			if(warped_to_mob_success && m) m.last_tap_warp = world.time
			last_tap_warp = world.time
			AddStamina(-tapwarp_stam_drain)
			AfterImage(50, loc_override = oloc)
			flick('Zanzoken.dmi',src)
			player_view(20,src) << sound('teleport.ogg',volume=15)
			Melee(from_auto_attack=1)
			return 1

	TapWarpToMob(mob/m)
		if(!m) return
		var/list/warp_turfs = list(\
			get_step(m,NORTH),\
			get_step(m,SOUTH),\
			get_step(m,EAST),\
			get_step(m,WEST))

		warp_turfs.Remove(m.dir, turn(m.dir,45), turn(m.dir,-45))

		for(var/turf/t2 in warp_turfs) if(!ValidWarpTurf(t2)) warp_turfs -= t2
		if(!warp_turfs.len) return

		var/turf/t = get_step(m,m.dir)
		if(!ValidWarpTurf(t)) t = pick(warp_turfs)
		//these 2 lines above were simply 1 line: var/turf/t = pick(warp_turfs)

		SafeTeleport(t)
		dir = get_dir(src, m)
		return 1

	ValidWarpTurf(turf/t)
		if(!t || !isturf(t) || t.opacity || istype(t,/turf/Other/Blank)) return
		if(!t.FlyOverAble && t.density) return
		for(var/obj/o in t)
			if(istype(o,/obj/Turfs/Door) && o.opacity) return
		return 1

	TapWarpToDir(d, warp_dist = 12)
		var/turf/start_loc = loc
		var/turf/t = start_loc
		if(!t || !isturf(t)) return
		for(var/v in 1 to warp_dist)
			var/turf/new_t = get_step(t,d)
			if(ValidWarpTurf(new_t))
				t = new_t
			else break
		if(t == start_loc) return
		SafeTeleport(t)

		var/mob/m = FindWarpTarget(dir_angle = turn(d,180), angle_limit=45, max_dist=20, prefer_auto_target=0)
		if(m) dir = pixel_dir(src, m)
		else dir = d

		return 1
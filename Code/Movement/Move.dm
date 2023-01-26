atom/var/can_side_step=1
mob/var/tmp/last_kill_from_freeza_for_cowardice = 0

mob/var/tmp
	has_delay=1 //this var/is now pointless i believe. Move() no longer has a delay inside of it. its been replaced in Allow_Move()

	same_loc_after_move
	same_dir_after_move

	last_move=0

mob/proc/Moving_auto_attack()
	set waitfor=0
	if(Auto_Attack) Melee(from_auto_attack=1)

proc/ceil(x) return -round(-x)

mob/var/tmp/last_sz_move_check = -999

mob/proc/PlayerPreMove()
	set waitfor=0
	if(last_move == world.time) return //because there can be multiple moves in the same tick in certain scenarios and some things dont need to be called repeatedly in the same tick
	UpdateGravity()
	Cease_training()

atom/var/tmp
	oldLoc
	newLoc

//this system is to stop Sphax using an actual teleport hack to teleport anywhere he wants even inside people's houses
atom/movable/var/tmp
	canTeleport = 0
	lastCanTeleport = 0

mob/var/tmp/flight_buildup = 0

atom/movable/proc
	//only this proc can teleport people because it will set the canTeleport flag first so the game knows its legit
	//the game will not allow position changes more than 1 tile if this proc was not used to do it
	SafeTeleport(turf/t, allowSameTick)
		if(t && isturf(t) && ismob(src) && src:client)
			SetZQuadrants(t.z)
			src:ShowWaitingScreen()
			while(!(t.currentQuadrant) || !("[t.z]" in QuadrantZsSet))
				sleep(world.tick_lag)
			src:HideWaitingScreen()
			t.LoadAdjacentQuadrants()
			currentQuadrant = t.currentQuadrant
			while(t.currentQuadrant.tag in UnloadedQuadrants)
				sleep(world.tick_lag)
		//JUST DISABLE THE WHOLE SYSTEM IT HAS SOME BUGS I DONT FEEL LIKE FIXING LIKE WHEN PODS BLOW UP WITH YOU IN IT YOU GET SENT TO VOID FOR NO APPARENT REASON
		oldLoc = t
		newLoc = t
		loc = t
		return

		//there are bugs that occur now with beam placement when firing a beam and other things so instead of fixing those im just gonna let them
		//go to the position
		if(!ismob(src))
			loc = t
			return
		//prevent an infinite loop, which does exist somewhere, and crashes the server
		if(lastCanTeleport == world.time && !allowSameTick)
			return
		lastCanTeleport = world.time
		canTeleport = world.time

		/*if(isturf(t))
			Move(t)
		//we do this in case t = null. Move(null) does nothing. but if we are trying to set someone's loc = null, it still needs to respond to that
		//also we now do it in case its anything other than a turf, like we are putting a mob inside a obj or something
		else
			oldLoc = t
			newLoc = t
			loc = t*/
		oldLoc = t
		newLoc = t
		loc = t

		canTeleport = 0

	//checks if the current movement is a valid movement
	LegitMove(turf/prevLoc, turf/newLoc)
		if(canTeleport == world.time || get_dist(newLoc, prevLoc) <= 1)
			return 1

var/FlightBuildupThreshold = 60

mob/proc/PlayerPostMove(old_loc)
	set waitfor=0

	if(last_move != world.time)
		Moving_auto_attack()
	if(trainState == "Med" || trainState == "Self") trainState = null
	if(last_move != world.time) UpdateStepSpeed()
	FinalExplosionFollowOnMove()
	if(loc != old_loc)
		Update_grab()
		UpdateGravity()
		regenerator_obj = locate(/obj/items/Regenerator) in loc
		if(world.time - last_sz_move_check > 6)
			Safezone()
			last_sz_move_check = world.time
		Save_Location()
		if(Flying && !flight_boosted)
			flight_buildup++
			if(flight_buildup >= FlightBuildupThreshold)
				flight_buildup = 0
				FlyBoost()
		else flight_buildup = 0
		if(prob(10) && is_on_destroyed_planet()) SafeTeleport(locate(x, y, 16))
		ExplodeLandMines()
		update_area()

mob/proc/NPCPostMove(old_loc)
	set waitfor=0
	if(last_move == world.time) return //because there can be multiple moves in the same tick in certain scenarios and some things dont need to be called repeatedly in the same tick
	//ResetStepXY()
	if(loc != old_loc)
		if(prob(5)) update_area()

mob/Move(turf/NewLoc, Dir = 0, step_x = 0, step_y = 0)

	var/turf/old_loc = loc

	//this is a teleport because it is more than a 1 tile step. so skip all the other code and just put them there because the default behavior of
	//Move() really interferes by changing their direction and stuff for no reason
	var/isTeleport
	if(isturf(NewLoc) && (get_dist(loc, NewLoc) > 1 || old_loc.z != NewLoc.z)) isTeleport = 1
	if(!isturf(NewLoc)) isTeleport = 1
	if(!isturf(loc)) isTeleport = 1
	if(isTeleport)
		oldLoc = loc
		newLoc = NewLoc
		loc = NewLoc
		return

	if(client) PlayerPreMove()

	if(!client || KB || lunge_attacking) . = ..()
	else if(Can_Move()) . = ..()

	if(client) PlayerPostMove(old_loc)
	else NPCPostMove(old_loc)

	last_move = world.time

proc/XYtoDir(x, y) //takes an x and y and decides if this movement is NSEW SW NW NE or SE
	if(x > 0)
		if(y > 0) return NORTHEAST
		if(y < 0) return SOUTHEAST
		return EAST
	if(x < 0)
		if(y > 0) return NORTHWEST
		if(y < 0) return SOUTHWEST
		return WEST
	if(y > 0) return NORTH
	if(y < 0) return SOUTH

mob/proc/AlignToTile()
	set waitfor=0
	if(!client) return
	if(last_north_up == world.time)
		if(step_y > 0)
			var/dist_to_next_tile = abs(32 - step_y)
			LerpToTile(NORTH, dist_to_next_tile)
	if(last_east_up == world.time)
		if(step_x > 0)
			var/dist_to_next_tile = abs(32 - step_x)
			LerpToTile(EAST, dist_to_next_tile)
	if(last_south_up == world.time)
		LerpToTile(SOUTH, step_y)
	if(last_west_up == world.time)
		LerpToTile(WEST, step_x)

mob/proc/LerpToTile(d, dist)
	set waitfor=0
	//set instant = 1
	if(dist == 0) return
	while(dist > 0)
		var/step_dist = dist
		if(step_dist < 0) step_dist = 0
		//if(step_dist > step_size) step_dist = step_size //dont.
		if(step_dist > dist) step_dist = dist
		dist -= step_dist
		var/prevDir = dir
		step(src, d, step_dist)
		dir = prevDir
		sleep(world.tick_lag)

mob/var/tmp/lastResetStepXY = 0

mob/proc/ResetStepXY()
	if(lastResetStepXY == world.time) return //can crash the game from infinite calls to step() i saw it happen a lot
	lastResetStepXY = world.time
	//it appears that giving blasts different step_size such as blast having 48 step size has caused a problem where it can
	//offset players who bump it because it is bumping an object off center from the tile so that off centers it too
	//when/if we go to full pixel moving we won't need this but for now we must have the player be tile bound
	var/prevDir = dir
	if(step_x > 16) step(src, EAST, 32 - step_x)
	if(step_y > 16) step(src, NORTH, 32 - step_y)
	//step_x = 0
	//step_y = 0
	if(step_x) step(src, WEST, step_x) //try to go to 0 but fail if any obstacle is in the way
	if(step_y) step(src, SOUTH, step_y)

	dir = prevDir

mob/proc/NpcAlignToTile(d)
	set waitfor=0
	if(d != NORTH && d != NORTHWEST && d != NORTHEAST)
		if(d != SOUTH && d != SOUTHEAST && d != SOUTHWEST)
			if(step_y > 0)
				var/dist_to_next_tile = abs(32 - step_y)
				LerpToTile(NORTH, dist_to_next_tile)
	if(d != EAST && d != NORTHEAST && d != SOUTHEAST)
		if(d != WEST && d != SOUTHWEST && d != NORTHWEST)
			if(step_x > 0)
				var/dist_to_next_tile = abs(32 - step_x)
				LerpToTile(EAST, dist_to_next_tile)
	if(d != SOUTH && d != SOUTHEAST && d != SOUTHWEST)
		if(d != NORTH && d != NORTHWEST && d != NORTHEAST)
			LerpToTile(SOUTH, step_y)
	if(d != WEST && d != SOUTHWEST && d != NORTHWEST)
		if(d != EAST && d != NORTHEAST && d != SOUTHEAST)
			LerpToTile(WEST, step_x)

mob/var/tmp/stepSizeLabel = 32 //for displaying in tabs

mob/proc/getSpeedRatio()
	return Spd / getAvgStat()

mob/proc/UpdateStepSpeed()
	set waitfor=0
	if(last_move == world.time) return //because there can be multiple moves in the same tick in certain scenarios and some things dont need to be called repeatedly in the same tick

	if(ultra_instinct)
		step_size = 32 //now i just want them to be fast
		return

	var/minSpeed = 16 //the slowest someone can be
	var/lowMaxAdd = 10 //the amount need to add to the minSpeed to create average speed
	var/normalSpeed = minSpeed + lowMaxAdd //this is whatever speed the game will consider perfectly average (your speed matches the average speed exactly)
	var/ratio = getSpeedRatio()
	var/speed = minSpeed
	if(ratio < 1)
		speed += ratio * lowMaxAdd
	else
		speed = normalSpeed //start out at what the game considers the average speed and go up from there
		speed += (ratio - 1) * 6
	var/delay_mult = GetInputMoveDelay(move_dir(), raw_mult_only = 1)
	speed /= delay_mult
	if(Flying)
		speed *= 1.2
		if(flight_boosted) speed *= 2
	else if(is_swimming) speed *= 0.8
	else
		if(CheckForInjuries() && GetInjuryTypeCount(/injury/fracture/left_leg))
			speed *= 0.95
		if(CheckForInjuries() && GetInjuryTypeCount(/injury/fracture/right_leg))
			speed *= 0.95
	if(IsShielding()) speed *= 0.6 //make people move slower while using a shield
	if(CheckForInjuries() && GetInjuryTypeCount(/injury/fracture/ribs))
		speed *= 0.9
	speed *= 20 / world.fps //make the speed you move be fps independent
	speed = min(speed, flight_boosted ? 48 : 32) //having fps below 20 can cause it to be relativized over 32 and that makes you move 2 full tiles at once due to the TileAlign code, not good
		//we can remove this when/if we ever get full REAL pixel movement in the game
	step_size = speed
	stepSizeLabel = speed

mob/proc/update_area()
	set waitfor = 0
	var/turf/t = base_loc()

	if(!t && current_area)
		current_area.mob_list -= src
		current_area.player_list -= src
		current_area.npc_list -= src
		current_area = null

	if(t && isturf(t))
		var/area/a = t.loc
		if(a != current_area)

			a.AreaUpdateSenseTargets() //tell old area we left it

			if(current_area)
				current_area.mob_list -= src
				current_area.player_list -= src
				current_area.npc_list -= src

				current_area.mob_list = remove_nulls(current_area.mob_list)
				current_area.player_list = remove_nulls(current_area.player_list)
				current_area.npc_list = remove_nulls(current_area.npc_list)

			a.mob_list += src
			if(client) a.player_list += src
			else a.npc_list += src
			current_area = a

			if(client && istype(a, /area/Braal_Core)) Start_core_loops()
			if(InFinalRealm())
				FinalRealm()
			CheckAirMask()

			current_area.AreaUpdateSenseTargets() //tell new area we entered it

			for(var/obj/items/Dragon_Ball/db in item_list) if(db.loc == src)
				if(!current_area || current_area.type != db.Home) db.Land()

mob
	var
		has_air_mask
		air_mask
	proc
		CheckAirMask()
			var/obj/items/Spacesuit/s = locate() in item_list
			if(s)
				if(current_area)
					if(current_area.type == /area/Space)
						if(!air_mask)
							air_mask=1
							overlays-=s.icon
							overlays+=s.icon
					else if(air_mask)
						air_mask=0
						overlays-=s.icon
			else
				air_mask=0

		CheckSpaceDie()
			set waitfor=0
			sleep(5)
			while(current_area && current_area.type == /area/Space)
				if(air_mask || Lungs || Regenerate)
				else
					var/turf/t = loc
					if(t && isturf(t) && t.type == /turf/Other/Stars)
						SpaceDamage()
				sleep(10)
		
		SpaceDamageTick()
			if(!(air_mask || Lungs || Regenerate))
				var/turf/t = loc
				if(t && isturf(t) && t.type == /turf/Other/Stars)
					SpaceDamage()

		SpaceDamage()
			var/shield = (shield_obj && shield_obj.Using)
			var/dmg = 9
			if(shield && Ki >= max_ki / 100 * dmg)
				IncreaseKi((max_ki / 100) * -dmg)
			else
				TakeDamage(-dmg, "space", 1)
				update_area()

mob/var/tmp/area/current_area
area/var/tmp/list
	mob_list=new
	player_list=new
	npc_list=new

mob/proc/Can_Move()
	if(KB || !move || Disabled()) return
	else return 1

mob/proc/Save_Location() if(z&&!Regenerating)
	saved_x=x
	saved_y=y
	saved_z=z

mob/proc/Cease_training()
	set waitfor=0
	if(Action=="Training") Train()
	if(Action=="Meditating") Meditate()
	if(Shadow_Sparring) Shadow_Spar()
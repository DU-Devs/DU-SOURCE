atom/var/can_side_step = 1
mob/var/tmp/last_kill_from_freeza_for_cowardice = 0 //this is just a variable that stores the time that the gym freeza npc last killed you, so the freeza npc will check this
	//and see that if it killed you recently it wont do it again to prevent spam killing you

mob/var/tmp
	has_delay = 1 //this var/is now pointless i believe. Move() no longer has a delay inside of it. its been replaced in Allow_Move() which determines if you are
		//currently in a situation where you are allowed to move

	same_loc_after_move //if you move but it fails to change your position then this will be 1, otherwise 0. like if you are bumping against a wall
	same_dir_after_move //same as above but if your direction did not change from moving then this will be 1, otherwise 0

	last_move = 0 //a timestamp of when you last moved

//when a player has auto attack on, there's a problem where if they are moving around and an attackable mob gets in front of them while theyre both moving, it will not detect
//they are there and does not auto attack them like it should. so this proc is called post-Move() to make sure it attacks anything that happens to be in front of it. there is
//also another auto attack loop somewhere that just calls Melee() on a loop every tick but without both methods it doesnt work too well. one works good when moving and the other
//works good when standing still
mob/proc/Moving_auto_attack()
	set waitfor=0
	if(Auto_Attack) Melee(from_auto_attack=1) //if auto attack is on, do a melee

proc/ceil(x) return -round(-x) //some utility function, not a clue what im using it for if anywhere

mob/var/tmp/last_sz_move_check = -999 //"last safezone movement check". this is a timestamp that records when the last time was that the player scanned if it was within a
//safezone or not. we do this to slow down the checking, so we dont have to check for a safezone every time we move. because it was lagging the game to check that often.

mob/proc/PlayerPreMove() //this proc is called in Move() BEFORE the movement actually happens.
	set waitfor=0
	if(last_move == world.time) return //because there can be multiple moves in the same tick in certain scenarios and anything below this line doesnt need to be called more
	//than once per tick.
	//FreezaRunnerCowardKill() //checks if a runner has ran into the gym for safety, freeza then kills them for being a coward
	Gravity_Update() //check however much gravity the player should currently be considered to be in
	Cease_training() //they moved, so automatically stop training/meditating so as to allow them to conveniently move without having to manually stop training/meditating themselves

atom/var/tmp
	oldLoc //stores the loc they were at prior to moving to whatever their newLoc is.
	newLoc //the last loc they moved into with Move()

//this system is to stop Sphax using an actual teleport hack to teleport anywhere he wants even inside people's houses
//WE TURNED THIS SYSTEM OFF BECAUSE IT NEVER STOPPED HIM SO ANYTHING REGARDING THIS SYSTEM YOU CAN JUST IGNORE. ALL ITS VARS AND PROCS CAN BE IGNORED AND EVENTUALLY REMOVED IF DESIRED
atom/movable/var/tmp
	canTeleport = 0
	lastCanTeleport = 0

atom/movable/proc
	//only this proc can teleport people because it will set the canTeleport flag first so the game knows its legit
	//the game will not allow position changes more than 1 tile if this proc was not used to do it
	//so even though its part of the "Sphax Anti-Teleport" system you still now have to use it whenever you want to teleport someone. the game wont recognize it properly
	//if you just set their location to a new location
	SafeTeleport(turf/t, allowSameTick)
		//JUST DISABLE THE WHOLE SYSTEM IT HAS SOME BUGS I DONT FEEL LIKE FIXING LIKE WHEN PODS BLOW UP WITH YOU IN IT YOU GET SENT TO VOID FOR NO APPARENT REASON
		oldLoc = t
		newLoc = t
		loc = t
		return //i put this here so none of the code below runs. because it wasnt stopping sphax anyway. the code below can be safely ignored, it was part of the sphax anti-teleport
		//system

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

	//checks if the current movement is a valid movement.
	//part of sphax anti-teleport system. can be ignored.
	LegitMove(turf/prevLoc, turf/newLoc)
		if(canTeleport == world.time || get_dist(newLoc, prevLoc) <= 1)
			return 1

//this code runs after the player completes a Move()
mob/proc/PlayerPostMove(old_loc)
	set waitfor=0
	oldLoc = old_loc
	newLoc = loc
	if(last_move != world.time)
		Moving_auto_attack() //simply fires a Melee attack if they have auto attack toggled on and there is someone in front of them to hit
	Update_grab() //they moved, so suck whoever/whatever they're currently grabbing to their current location
	if(last_move != world.time) UpdateStepSpeed()
	FinalExplosionFollowOnMove() //just simply causes the graphics of Final Explosion to teleport to your location if you move
	if(loc != old_loc)
		if(world.time - last_sz_move_check > 6)
			Safezone() //update whether the player is considered in a safezone or not
			last_sz_move_check = world.time
		Save_Location() //misnomer. simply makes saved_x = x, saved_y = y, and saved_z = z. because byond savefiles do not by default save x/y/z vars, so it saved the saved_x/y/z
			//vars instead and we use it to restore their position when they load back in at some point. its not the right way to do it but its old code
		Opponent_move_slower_if_you_are_chasing_them() //pretty sure this system is disabled and if its not you probably want to disable it because its dumb. slows down the movement
			//speed of anyone who the game thinks is "running away" from you
		Edge_Check(old_loc) //this proc seems to be disabled so it doesnt matter.
		if(!KB && Target && istype(Target,/obj/Build)) Build_Lay(Target,src) //lays down an instance of whatever the player happens to be building right now, meaning Floors/Walls/etc
		if(prob(10) && is_on_destroyed_planet()) SafeTeleport(locate(x, y, 16)) //they are on a destroyed planet, so teleport them to Space now
		ExplodeLandMines() //check if the player is standing on a landmine and explode it if so
		update_area() //check if the player has went into a different "area" and do things accordingly

//anything in this proc happens after an NPC completes a movement
mob/proc/NPCPostMove(old_loc)
	set waitfor=0
	if(last_move == world.time) return //because there can be multiple moves in the same tick in certain scenarios and some things dont need to be called repeatedly in the same tick
	//ResetStepXY()
	if(loc != old_loc)
		if(prob(5)) update_area() //it seems even NPCs need to know when they've been moved into a new area. but i slowed it down with a prob(5) because it was lagging

mob/Move(turf/NewLoc, Dir = 0, step_x = 0, step_y = 0)
	//return ..()

	/*
	I TURNED THIS OFF BECAUSE IT MAKES IT WHEN A SPACEPOD BLOWS UP WITH YOU IN IT YOU GET SENT TO THE VOID AND I JUST DONT WANNA DEAL WITH FIXING IT
	//trying to prevent Sphax's teleport hack
	if(client) //just trying to save some cpu but may need to run it on all if this doesnt stop Sphax and his teleport hack
		if(!LegitMove(loc, NewLoc))
			loc = newLoc
			return
		if(newLoc && canTeleport != world.time && loc != newLoc)
			loc = newLoc
			return
	*/

	var/turf/old_loc = loc

	//in this block we check if this is a teleport. a teleport is whenever they attempt to move more than 1 tile away. so skip all the other code and just put them there
	//because the default behavior of Move() really interferes by changing their direction and stuff for no reason
	var/isTeleport
	if(isturf(NewLoc) && (get_dist(loc, NewLoc) > 1 || old_loc.z != NewLoc.z)) isTeleport = 1
	if(!isturf(NewLoc)) isTeleport = 1
	if(!isturf(loc)) isTeleport = 1
	if(isTeleport)
		oldLoc = loc
		newLoc = NewLoc
		loc = NewLoc
		return //this move was indeed considered a teleport. so just stop here and forget running any code below.



	if(client) PlayerPreMove()

	//this is some code im testing as an alternative to AlignToTile(), where whenever you move, any direction you are NOT moving in will try to lerp
	//back to perfect alignment
	/*if(client) //it could be for npcs later but just in case of performance issues lets do players only at first
		var/d = Dir //this should work, if not use XYtoDir(step_x, step_y)
		var/adjustment_speed = 4 //if you up this, the adjustment will have more of a jolt, but if you lower it then it will take longer to reach alignment
		if(d == NORTH || d == SOUTH) //if im moving just north then the east/west has permission to gradually lerp back to tile alignment
			if(src.step_x != 0)
				if(src.step_x < 16) //we are closer to the left tile
					var/amount = adjustment_speed
					if(amount > src.step_x) amount = src.step_x
					step_x -= amount
				else //we are closer to the right tile
					var/amount = adjustment_speed
					if(amount > 32 - src.step_x) amount = 32 - src.step_x
					step_x += amount
		if(d == EAST || d == WEST)
			if(src.step_y != 0)
				if(src.step_y < 16)
					var/amount = adjustment_speed
					if(amount > src.step_y) amount = src.step_y
					step_y -= amount
				else
					var/amount = adjustment_speed
					if(amount > 32 - src.step_y) amount = 32 - src.step_y
					step_y += amount*/

		//ESSENTIALLY THIS ALL WORKS BUT IT HAS SOME JITTERING I WANT TO FIX BEFORE ENABLING IT AGAIN
		/*if(d == NORTHEAST) //the concept here is based on our misalignment, we will trade some velocity from the x and give it to the y if for example the
		//y was more misaligned from the center of the tile than the x was. so we dont increase overall speed just shift some to reach alignment
			if(src.step_x != 0 || src.step_y != 0)
				var
					x_dist = abs(32 - src.step_x)
					y_dist = abs(32 - src.step_y)
				if(x_dist > y_dist)
					var/amount = adjustment_speed
					if(amount > x_dist) amount = x_dist
					step_x += amount
					step_y -= amount
				else
					var/amount = adjustment_speed
					if(amount > y_dist) amount = y_dist
					step_x -= amount
					step_y += amount

		if(d == NORTHWEST)
			if(src.step_x != 0 || src.step_y != 0)
				var
					x_dist = src.step_x //how from from off-center this axis is
					y_dist = abs(32 - src.step_y)
				if(x_dist > y_dist) //x is more misaligned than y
					var/amount = adjustment_speed
					if(amount > x_dist) amount = x_dist
					step_x -= amount
					step_y -= amount
				else
					var/amount = adjustment_speed
					if(amount > y_dist) amount = y_dist
					step_y += amount
					step_x += amount
		if(d == SOUTHWEST)
			if(src.step_x != 0 || src.step_y != 0)
				var
					x_dist = src.step_x //how from from off-center this axis is
					y_dist = src.step_y
				if(x_dist > y_dist) //x is more misaligned than y
					var/amount = adjustment_speed
					if(amount > x_dist) amount = x_dist
					step_x -= amount
					step_y += amount
				else
					var/amount = adjustment_speed
					if(amount > y_dist) amount = y_dist
					step_x += amount
					step_y -= amount
		if(d == SOUTHEAST)
			if(src.step_x != 0 || src.step_y != 0)
				var
					x_dist = abs(32 - src.step_x) //how from from off-center this axis is
					y_dist = src.step_y
				if(x_dist > y_dist) //x is more misaligned than y
					var/amount = adjustment_speed
					if(amount > x_dist) amount = x_dist
					step_x += amount
					step_y += amount
				else
					var/amount = adjustment_speed
					if(amount > y_dist) amount = y_dist
					step_x -= amount
					step_y -= amount*/
		//Dir = XYtoDir(step_x, step_y) //not sure if necessary
	//----------

	//the "KB" var stands for "knockback". if KB is 1 then they are currently being knocked back, otherwise they are not
	if(!client || KB || lunge_attacking || evading) . = ..() //if these criteria are met, just move them
	else if(Can_Move()) . = ..() //otherwise check if they Can_Move() first before allowing them to move

	if(client) PlayerPostMove(old_loc)
	else NPCPostMove(old_loc)

	last_move = world.time

//this proc does not appear to be used anywher. it was a utility function that would simply tell you if a pixel move of a certain x and y is "considered" to be a
//movement of north/south/east/west/southeast/southwest/northeast/northwest. not sure what use it was supposed to be.
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

//this is used so that when the player stops moving, they will then snap onto whatever tile is closest to them, but also still in their current direction of movement (otherwise
//they would snap backwards, which looks very unnatural. and then step_x and step_y are set to 0 to eliminate pixel offsets),
//essentially snapping them back into tile-based movement whenever they cease moving). we do this because Melee and Beams and Blasts and some other systems that were made
//for tile based movement, do not look right and/or work right if the player ever has a step_x/step_y offset. so when they cease moving we snap them perfectly onto the next tile which
//for whatever reason creates the illusion that all the tile-based features are working properly.
mob/proc/AlignToTile()
	set waitfor=0
	//set instant = 1
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

//just a proc that AlignToTile needs to use to fulfill its purpose. looks like it smooths out the tile-snapping, because it probably looked unnatural or something until i added this
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

//this is like AlignToTile except that it snaps them instantly to the tile they're nearest to instead of doing it smoothly. the tile they're nearest to isn't always the one they're "on",
//because they may be on tile 1,1,1 but if their step_x is 31, they're 15 pixels away from being aligned with the tile theyre "on" but only 1 pixel away from being aligned
//with the next tile over, so in that case we actually snap them to the next tile over. because tiles are 32 pixels wide, and being "snapped" to a tile means step_x and step_y
//are both zero, so a step_x of 31 would be better aligned to the next tile over instead
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
	if(step_x) step(src, WEST, step_x) //try to go to 0 but fail if any obstacle is in the way. this works better than the 2 commented out lines above which we used originally, because just hard setting step_x or step_y to zero doesnt account for obstacles and occasionally lets you bypass collisions and pass through things. but step() properly accounts for any collisions.
	if(step_y) step(src, SOUTH, step_y)

	dir = prevDir

//the same concept as AlignToTile, which is for players, but this is for NPCs. unfortunately i had to make it differently for NPCs because NPCs do not have last_east_up/last_north_up/etc
//variables because those variables track when a player releases the corresponding keyboard button for north/south/east/west/etc, which is not applicable to NPCs
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

mob/var/tmp/stepSizeLabel = 32 //for displaying how fast your step speed is in the stat tab. idk why we did it this way

//whenever the player moves just update how fast their pixel moving speed should be, based on their speed stat and other factors.
mob/proc/UpdateStepSpeed()
	set waitfor=0
	if(last_move == world.time) return //because there can be multiple moves in the same tick in certain scenarios and some things dont need to be called repeatedly in the same tick

	//force_32_pix_movement = 1 //uncomment this line to disable pixel speeds and force 32 pixel movement only, meaning tile-based moving only

	if(force_32_pix_movement)
		step_size = 32
		step_x = 0
		step_y = 0
		return

	if(ultra_instinct)
		//step_size = 9
		step_size = 32 //now i just want them to be fast. i had it where ultra instinct was slow moving for dramatic purposes but nah
		return

	var/minSpeed = 16 //the slowest someone can be
	var/lowMaxAdd = 10 //the amount need to add to the minSpeed to create what is arbitrarily considered an "average" speed
	var/normalSpeed = minSpeed + lowMaxAdd //this is whatever speed the game will consider perfectly average (your speed matches the average speed exactly)
	var/ratio = Spd / avg_speed
	var/speed = minSpeed
	if(ratio < 1)
		speed += ratio * lowMaxAdd
	else
		speed = normalSpeed //start out at what the game considers the average speed and go up from there
		speed += (ratio - 1) * 6
	stepSizeLabel = speed
	var/delay_mult = GetInputMoveDelay(move_dir(), raw_mult_only = 1)
	speed /= delay_mult
	speed *= 20 / world.fps //make the speed you move be fps independent
	if(speed > 32) speed = 32 //having fps below 20 can cause it to be relativized over 32 and that makes you move 2 full tiles at once due to the TileAlign code, not good
		//we can remove this when/if we ever get full REAL pixel movement in the game
	step_size = speed

//check if the mob has moved into a different area than it was previously in and do some things if so
mob/proc/update_area()
	set waitfor = 0
	var/turf/t = base_loc()

	//if this mob has no location, meaning it is not even on the map, we are going to just consider it to be not in any area either, so we remove it from their previous
	//area's mob_list, player_list, etc, and then set the mob's current_area to be null since they're not on the map so it only makes sense they're not in the map's area either
	if(!t && current_area)
		current_area.mob_list -= src
		current_area.player_list -= src
		current_area.npc_list -= src
		current_area = null

	//however if they are on the map somewhere, do this
	if(t && isturf(t))
		var/area/a = t.loc //the loc of a turf is always the area the turf is in
		if(a != current_area) //if the area of the turf you are in is not the same as your "current_area" var, then you are considered to have changed areas

			a.AreaUpdateSenseTargets() //tell old area we exited it. this has something to do with the on-screen sense UI where you see little transparent players on your screen.

			if(current_area)
				current_area.mob_list -= src
				current_area.player_list -= src
				current_area.npc_list -= src

				current_area.mob_list = remove_nulls(current_area.mob_list)
				current_area.player_list = remove_nulls(current_area.player_list)
				current_area.npc_list = remove_nulls(current_area.npc_list)

			a.mob_list += src //add yourself to the new area's mob_list, the mob_list and player_list and npc_list, which are all variables on each area, allow quick access
			//to any mob/npc/player in that area without looking up all mobs/npcs/players globally, which was at one point a bit laggy
			if(client) a.player_list += src
			else a.npc_list += src
			current_area = a

			if(client && istype(a, /area/Braal_Core)) Start_core_loops() //they have entered the core of planet vegeta so start the loops which run there, for the training gains and such
			Final_realm_loop()
			CheckAirMask() //check if they have entered or exited the Space area, and put on or off their air mask automatically as needed for their convenience
			CheckSpaceDie() //this is actually a loop that will kill them gradually if they have no mask and have entered the Space area. the loop will stop itself when they
				//are no longer in space

			if(a.type == /area/Battlegrounds && client)
				last_battleground_entry = world.time
				last_battleground_defeat = world.time //reset your ranking among the battleground fighters
				VerifyBattlegroundMaster()

			current_area.AreaUpdateSenseTargets() //tell new area we entered it

			for(var/obj/items/Dragon_Ball/db in item_list) if(db.loc == src)
				if(!current_area || current_area.type != db.Home) db.Land()

mob
	var
		has_air_mask
		air_mask
	proc
		//checks if they are in space, if so puts on air mask, otherwise takes it off, for their convenience
		CheckAirMask()
			var/obj/items/Spacesuit/s
			for(s in item_list) break
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

		SpaceDamage()
			var/shield = (shield_obj && shield_obj.Using)
			var/dmg = 9
			if(shield && Ki >= max_ki / 100 * dmg)
				Ki -= max_ki / 100 * dmg
			else Health-=dmg
			if(Health<=0)
				SaitamaBloodEffect()
				Death("Space",lose_hero=0,lose_immortality=0)
				update_area()

mob/var/tmp/area/current_area
area/var/tmp/list
	mob_list=new
	player_list=new
	npc_list=new

mob/proc/Can_Move()
	if(KB || !move || Disabled()) return
	else return 1

mob/proc/Edge_Check(turf/old_loc)
	set waitfor=0

	return //disabled til fixed. or maybe its not needed at all from the looks of it.

	if(!Flying)
		var/turf/T=Get_step(old_loc,dir)
		if(T)
			if(!T.Enter(src)) return
			for(var/obj/Edges/A in loc)
				Bump(A)
				if(A) if(!(A.dir in list(dir,turn(dir,90),turn(dir,-90),turn(dir,45),turn(dir,-45))))
					SafeTeleport(old_loc)
					break
			for(var/obj/Edges/A in old_loc)
				Bump(A)
				if(A) if(A.dir in list(dir,turn(dir,45),turn(dir,-45)))
					SafeTeleport(old_loc)
					break

mob/proc/Save_Location() if(z&&!Regenerating)
	saved_x=x
	saved_y=y
	saved_z=z

mob/proc/Cease_training()
	set waitfor=0
	if(Action=="Training") Train()
	if(Action=="Meditating") Meditate()
	if(auto_train) AI_Train()
	if(Shadow_Sparring) Shadow_Spar()
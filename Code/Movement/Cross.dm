//these will not be called at all when bumping into a turf so use bump for checking anything to do with turf colliding
//actually byond says theyre called on turfs now in a new update

mob
	Cross(atom/movable/a) //a = the object attempting to overlap src - basically the opposite of what you would think
		if(density)
			if(ismob(a))
				var/mob/m = a
				//this is so npcs can never overlap a player because its wonky looking and makes fighting them hard
				//maybe it should only be limited to mob/Enemy but idk right now
				if(!m.client) return 0
				if(m.client && istype(src, /mob/Enemy)) return 0 //this is so a flying player can not overlap a nonflying Enemy, because its just annoying for the player to
					//fight npcs when flying if they are flying through them because the npc cant fly
				if(!KB && m.Flying && !Flying)
					//src << "1"
					return 1
			if(isobj(a))
				if(istype(a, /obj/Blast))
					var/obj/Blast/b = a
					if(b.blast_go_over_owner && b.Owner == src) return 1
		. = ..()

obj
	Cross(atom/movable/a)
		if(density)
			if(ismob(a))
				var/mob/m = a
				if(!istype(src, /obj/Turfs/Door))
					if(m.Flying || m.lunge_attacking || m.evading) return 1
		. = ..()

obj/Blast/Cross(atom/movable/a)
	if(density)
		if(istype(a, /obj/Blast))
			var/obj/Blast/b = a
			if(b.pass_over_owners_blasts && b.Owner == Owner) return 1
		if(ismob(a))
			if(a.dir == dir) return 1 //you can cross over blasts as long as it is from behind
	. = ..()

atom/movable
	Cross(atom/movable/a)
		//a = object attempting to cross (such as the player)
		//src = the object 'a' is trying to cross
		if(density)
			if(istype(a,/obj/Blast))
				var/obj/Blast/b = a
				if(b.BlastCross(src)) return 1
			if(ismob(a))
				var/mob/m = a
				if(m.MobCross(src)) return 1
		. = ..()

/*atom/movable
	Cross(atom/movable/a)
		//clients << "[a] is attempting to cross [src]"
		. = ..()

	Crossed(atom/movable/a)
		//clients << "[a] has crossed onto [src]"
		. = ..()

	Uncross(atom/movable/a)
		//clients << "[a] has attempted to stop overlapping [src]"
		. = ..()

	Uncrossed(atom/movable/a)
		//no default return value for Uncrossed!
		//clients << "[a] has stopped overlapping [src]"
*/

atom/var/canSideStep = 1

mob/proc/SideStep(obj/o)
	if(!o.canSideStep) return
	var
		old_loc = loc
		old_dir = dir
	var/d = get_dir(src,o)
	if(dir != d) return
	var/list/where = list(turn(d,45), turn(d,-45))
	where = shuffle(where)
	step(src, pick(where), 32)
	if(loc == old_loc) dir = old_dir

atom/movable/var
	tmp
		explode_on_kb
		stun_when_knocked_through

obj/Trees
	explode_on_kb = 1
	mapObject = 1
obj/Turfs
	explode_on_kb = 1
	mapObject = 1
obj/Big_Rock
	explode_on_kb = 1
	mapObject = 1

mob/proc
	BumpKnockbackDestroyObjectCheck(obj/o)
		set waitfor=0
		if(!isobj(o)) return
		if(KB && o.explode_on_kb)
			if(o.takes_gradual_damage) o.Health -= knockbacker_bp
			else if(o.Health < knockbacker_bp) o.Health = 0
			if(o.Health <= 0)
				if(o.stun_when_knocked_through)
					var/base_stun = 30
					var/stun = base_stun * (knockbacker_bp / BP)
					stun = Clamp(stun, 0, base_stun * 3)
					ApplyStun(time = stun)
				del(o)

//bump is still needed to detect turf collisions and a few other things
mob/Bump(mob/A)
	if(isturf(A))
		for(var/obj/Controls/C in A)
			C.Ship_Options(src)
			break
		for(var/obj/items/Simulator/s in A)
			SimBump(s)
			break

turf/Enter(mob/m)
	var/return_value = ..()
	//allow flying over dense turfs
	if(density && ismob(m) && type != /turf/Other/Blank && !istype(src, /turf/Teleporter))
		if(FlyOverAble || build_category != BUILD_ROOF)
			if(m.Flying || m.lunge_attacking || m.evading)
				var/mob/m2
				for(m2 in src) if(m2 != m) break
				if(!m2)
					var/obj/Turfs/Door/d
					for(d in src) if(d.density && d.Password) break
					if(!d) return_value = 1
	return return_value


	//original code
	/*. = ..()
	//pass over dense turfs when flying
	if(density)
		if(ismob(m) && type != /turf/Other/Blank && !istype(src, /turf/Teleporter))
			if(FlyOverAble || build_category != BUILD_ROOF)
				if(m.Flying || m.lunge_attacking || m.evading)
					var/mob/m2
					for(m2 in src) if(m2 != m) break
					if(!m2)
						var/obj/Turfs/Door/d
						for(d in src) if(d.density && d.Password) break
						if(!d) return 1*/

mob/proc/DoorPasswordAlert(obj/Turfs/Door/d)
	set waitfor=0
	if(!d) return
	if("door password" in active_prompts) return
	active_prompts += "door password"
	var/guess = input(src, "You must know the password to enter here") as text
	active_prompts -= "door password"
	if(!d) return
	if(guess != d.Password) return
	d.Open()

//in this proc "src" is the one attempting to cross "A", even though in BYOND's built in cross its the opposite
mob/proc/MobCross(mob/A)

	if(istype(A,/obj/items/Simulator)) SimBump(A) //bump even when flying, thats why

	if(!A.density)
		//src << "2"
		return 1
	var/return_value = 0

	if(istype(A, /obj/Turfs/Door))
		var/obj/Turfs/Door/d = A
		if(isturf(d)) d = locate(/obj/Turfs/Door) in d
		if(d)
			if(client && InBattleCantEnterCave())
			else
				var/needs_password = 1
				if(drone_module && drone_module.Password == d.Password)
					d.Open()
					return_value = 1
					needs_password = 0
				for(var/obj/items/Door_Pass/dp in item_list) if(dp.Password == d.Password)
					d.Open()
					return_value = 1
					needs_password = 0
				for(var/obj/items/Door_Hacker/dh in item_list) if(dh.BP >= d.Health)
					player_view(15,d)<<"[src] hacks the door and it opens"
					d.Open()
					return_value = 1
					needs_password = 0
				if(d.is_hbtc_door && anyone_can_enter_hbtc) needs_password = 0
				if(needs_password && client && d.Password && !KB) DoorPasswordAlert(d)
				if(!d.Password || (d.is_hbtc_door && anyone_can_enter_hbtc))
					d.Open()
					return_value = 1

	BumpKnockbackDestroyObjectCheck(A)

	if(A && last_bumped_obj == A && A != src && A.density)
		if(!ismob(A) && !istype(A,/obj/Blast))
			if(!(locate(/mob) in A.loc))
				SideStep(A)

	//if(ismob(A)) Pixel_Align(A)

	if(A && A.type == /obj/King_of_Braal_Throne)
		BumpKingBraalThrone()

	//for blasts with blast_go_over_owner
	if(A && istype(A,/obj/Blast) && A.Owner && A.Owner == src)
		var/obj/Blast/b = A
		if(b.blast_go_over_owner)
			var/turf/t = get_step(src,dir)
			if(t && !t.density)
				return_value = 1

	A.ExplodeLandMines()

	if(istype(A,/obj/Planet_Restore_Crystal))
		var/obj/Planet_Restore_Crystal/prc = A
		if(!destroyed_planets.len)
			src<<"There are no destroyed planets right now to restore"
		else
			var/planet = pick(destroyed_planets)
			player_view(15,src)<<"[planet] has been restored"
			spawn restore_planet(planet)
			prc.DespawnRespawn()

	//if(istype(A,/obj/items/Simulator)) SimBump(A)

	if(istype(A,/obj/items/Regenerator))
		//SafeTeleport(A.loc)
		Regenerator_loop(A)
		if(grabbedObject && ismob(grabbedObject))
			grabbedObject.SafeTeleport(loc)
			grabbedObject.Regenerator_loop(A)
		return_value = 1

	if(istype(A,/obj/Kaioshin_Portal))
		var/obj/Kaioshin_Portal/KP=A
		if(KP.icon)
			if(Teleport_nulled())
				src<<"A teleport nullifier prevents the portal from working"
			else
				SafeTeleport(locate(250,250,13))
				spawn if(KP) KP.Become_inactive()

	if(istype(A,/obj/Bank))
		Bank_Options(A)

	if(istype(A,/obj/Ship_exit))
		var/obj/Ship_exit/Se=A
		for(var/obj/Controls/C in range(6,Se))
			C.Exit_Ship(src,Se)

	if(istype(A,/obj/Final_Realm_Portal))
		SafeTeleport(locate(rand(163,173),rand(183,193),5))

	if(istype(A,/obj/God_Realm_Portal) && A.invisibility == 0 && client)
		SafeTeleport(locate(385,114,11))

	if(istype(A,/obj/Warper))
		var/obj/Warper/B=A
		SafeTeleport(locate(B.gotox,B.gotoy,B.gotoz))

	if(istype(A,/obj/Ships/Ship))
		var/obj/Ships/Ship/B=A
		var/turf/t=Get_step(B,SOUTHEAST)
		if(!t||loc==t||B.bound_width==32)
			for(var/obj/Controls/C in ship_controls) if(C.Ship==B.Ship)
				player_view(15,src)<<"[src] enters the [A]"
				if(!B.Last_Entry) src<<"<font color=yellow>Computer: Welcome. You are the first one to enter this ship."
				else if(Year-B.Last_Entry>=1) src<<"<font color=yellow>Computer: Welcome, you are the first person to enter this \
				ship in the past [round(Year-B.Last_Entry,0.1)] years"
				B.Last_Entry=Year
				for(var/obj/Ship_exit/Se in range(5,C))
					SafeTeleport(locate(Se.x,Se.y,Se.z))
					break

	if(ismob(A))
		if(type == /mob/Splitform && !A.KO) Melee(A)
		if(!client && type != /mob/Troll && !istype(src, /mob/new_troll) && type != /mob/Splitform)
			if(Health < 100 || !Docile)
				if(istype(src,/mob/Enemy) && istype(A,/mob/Enemy)) //mob dont attack mob
				else if(!drone_module)
					Melee(A)

		//DISABLED TO TEST A BUG WHERE YOU PASS THRU PEOPLE ON JAN 27 2019
		//if(client && Flying && dir == A.dir) SafeTeleport(A.loc)
		//if(client && Flying && dir == A.dir)
			//return_value = 1
			//src << "3"

		if(IsGreatApe()) Melee(A)

	if(istype(A,/obj/Planets)) Bump_Planet(A,src)

	if(istype(src,/mob/Enemy) && world.time - src:last_npc_turf_attack > 50)
		if(!client&&isobj(A)&&!istype(A,/obj/Edges)&&istype(src,/mob/Enemy/Zombie))
			src:last_npc_turf_attack=world.time
			Melee(A)
		if(!client&&isturf(A)&&A.density&&istype(src,/mob/Enemy/Zombie))
			src:last_npc_turf_attack=world.time
			Melee(A)

	if(istype(A,/obj/Controls))
		var/obj/Controls/C=A
		C.Ship_Options(src)

	//right now we only use this for npcs but maybe we should use it on players too im just not sure yet
	if(!client && !return_value)
		if(last_bump != world.time) //only allow this to be called once per tick or it can be an infinite loop that crashes the game instantly i saw it
			var/prevDir = dir
			/*var/bumpDir = cardinal_pixel_dir(src, A)
			//go back to where you were
			if(bumpDir == WEST)
				step(src, EAST, step_size)
			if(bumpDir == SOUTH)
				step(src, NORTH, step_size)*/
			//now set step_x/y to 0
			ResetStepXY() //pretty sure ResetStepXY now essentially fulfills the purpose of what was above
			dir = prevDir

	if(!return_value)
		last_bump = world.time
		if(A) last_bumped_obj = A

	return return_value
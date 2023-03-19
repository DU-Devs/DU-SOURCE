//we do this to fix the bug where you can make spacepods move at double speed to run away from someone if you add
//.north .south .east .west macros to your byond macros and they'll stack together with our macros here causing you
//to move really fast
client
	North() return 0
	South() return 0
	East() return 0
	West() return 0


//if you key up then key down in the same tick you still have to move 1 tile!
mob/var/tmp
	north=0
	south=0
	east=0
	west=0
	move_looping
	list/keys_down=new
	last_direction_pressed = NORTH

mob/var/tmp
	last_keydown_time=0
	last_spacebar_down = 0

	last_directional_keydown_time=0
	last_directional_key_down

	last_north_down = 0
	last_south_down = 0
	last_east_down = 0
	last_west_down = 0

	last_north_up = 0
	last_south_up = 0
	last_east_up = 0
	last_west_up = 0

obj/var/repeat_macro

mob/proc/Macro_direction()
	if(north>=world.time && east>=world.time) return NORTHEAST
	if(north>=world.time && west>=world.time) return NORTHWEST
	if(south>=world.time && east>=world.time) return SOUTHEAST
	if(south>=world.time && west>=world.time) return SOUTHWEST
	if(north>=world.time) return NORTH
	if(south>=world.time) return SOUTH
	if(west>=world.time) return WEST
	if(east>=world.time) return EAST

mob/verb/KeyDown(d as text)
	set waitfor=0
	set hidden=1
	set instant=1

	/*if(!(d in list("north","south","east","west")))
		if(last_keydown_time==world.time) return
		last_keydown_time=world.time*/

	if(d == "Space") last_spacebar_down = world.time

	switch(d)
		if("north")
			north=world.time
			last_north_down = world.time
		if("south")
			south=world.time
			last_south_down = world.time
		if("east")
			east=world.time
			last_east_down = world.time
		if("west")
			west=world.time
			last_west_down = world.time
	//world<<"KeyDown time: [world.time]"

	for(var/v in 1 to 3)
		keys_down-=d

	keys_down+=d
	if(d in list("north","south","east","west"))

		if(Digging)
			Digging = 0
			src << "You have stopped digging"

		if(Regeneration_Skill)
			Regeneration_Skill = 0
			src << "You stop regenerating"

		//if its the classic ui then the only way to do a double tap dash is to double tap, instead of ctrl + direction like the new way
		//var/double_tapped
		//if(classic_ui)
		//	if(d == last_directional_key_down && world.time - last_directional_keydown_time <= 1.2) double_tapped=1 //1.875 is exactly 3 ticks at 16 fps
		last_directional_keydown_time = world.time
		last_directional_key_down = d

		var/warped
		//instead of double tapping we have switched to Ctrl + Direction
		//if(classic_ui && double_tapped) warped = DoubleTapWarp(d)
		if(client && client.ctrl_button) warped = DoubleTapWarp(d)
		//Dash_Evade(Macro_direction(), from_double_tap=double_tapped)

		if(!warped) move_loop()
	else
		HotbarUseHandler(d)

mob/proc/HotbarUseHandler(d)
	set waitfor=0
	set instant = 1
	var/obj/o = Get_hotbar_obj_by_key_pressed(d)
	while(d in keys_down)
		if(o && o.can_hotbar)
			o:Hotbar_use(usr)
			if(o && !o.repeat_macro)
				keys_down-=d
				return
		sleep(world.tick_lag)

mob/proc/HotbarKeyUpHandler(d)
	set waitfor=0
	set instant = 1
	var/obj/o = Get_hotbar_obj_by_key_pressed(d)
	if(o && o.can_hotbar)
		if(o.is_for_moving)
			ReleaseKey(o.move_macro_dir)


mob/verb/KeyUp(d as text)
	set waitfor=0
	set hidden=1
	set instant=1
	//world<<"KeyUp time: [world.time]"

	ReleaseKey(d)

	if(!(d in list("north","south","east","west")))
		HotbarKeyUpHandler(d)

	if(d == "Space" && world.time - last_spacebar_down < 3)
		if(MeleeFollowupAttackCheck())
		else LungeAttack()

mob/proc/ReleaseKey(d)
	set waitfor = 0
	set instant = 1
	for(var/v in 1 to 3)
		keys_down -= d
	switch(d)
		if("north")
			last_north_up = world.time
			north = 0
		if("south")
			last_south_up = world.time
			south = 0
		if("west")
			last_west_up = world.time
			west = 0
		if("east")
			last_east_up = world.time
			east = 0
	AlignToTile()

mob/proc/move_dir()
	if(north)
		if(east) return NORTHEAST
		if(west) return NORTHWEST
		return NORTH
	if(south)
		if(east) return SOUTHEAST
		if(west) return SOUTHWEST
		return SOUTH
	if(east) return EAST
	if(west) return WEST


/*mob/var/tmp/pixel_offset_loop

mob/proc
	ClientPixelOffsetLoop()
		set waitfor=0
		if(pixel_offset_loop) return
		pixel_offset_loop=1

		while(client && (client.pixel_x!=0 || client.pixel_y!=0))
			client.pixel_x *= 0.85
			client.pixel_y *= 0.85
			sleep(world.tick_lag)

		pixel_offset_loop=0*/

mob/proc/move_loop()
	set waitfor=0
	if(move_looping) return
	move_looping=1
	var/first_step=1
	if(!Shadow_Sparring) sleep(world.tick_lag)
	while(north || south || east || west)
		var/d = move_dir()

		last_direction_pressed = d

		if(d && Allow_Move(d) && z)
			//var/turf/pos = loc

			var/turf/prev_loc = base_loc()
			var/prevDir = dir
			step(src,d)
			if(client && client.shift) dir = prevDir //strafing
			if(prev_loc != base_loc()) last_input_move = world.time
			UpdateNextInputMoveTime(d)

			/*if(loc != pos && client)
				var
					x_dist_moved = 0
					y_dist_moved = 0

				switch(d)
					if(NORTH) y_dist_moved = 32
					if(SOUTH) y_dist_moved = -32
					if(EAST) x_dist_moved = 32
					if(WEST) x_dist_moved = -32
					if(NORTHEAST)
						y_dist_moved = 32
						x_dist_moved = 32
					if(NORTHWEST)
						y_dist_moved = 32
						x_dist_moved = -32
					if(SOUTHEAST)
						y_dist_moved = -32
						x_dist_moved = 32
					if(SOUTHWEST)
						y_dist_moved = -32
						x_dist_moved = -32

				client.pixel_x-=x_dist_moved
				client.pixel_y-=y_dist_moved

				ClientPixelOffsetLoop()*/

		if(first_step && !Shadow_Sparring) sleep(world.tick_lag * 2)
		else sleep(world.tick_lag)

		first_step=0

		if(north==2) north=0
		if(south==2) south=0
		if(east==2) east=0
		if(west==2) west=0

	move_looping=0



client
	var
		tmp
			ctrl_button = 0
			shift = 0

mob/verb
	SetCtrlStatus(status as text)
		set hidden = 1
		if(status == "0") client.ctrl_button = 0
		else client.ctrl_button = 1

	ShiftDown()
		set hidden = 1
		client.shift = 1

	ShiftUp()
		set hidden = 1
		client.shift = 0
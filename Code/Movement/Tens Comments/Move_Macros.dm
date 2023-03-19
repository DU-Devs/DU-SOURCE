//this file handles player inputs related to moving their character


//we do this to fix the bug where you can make spacepods move at double speed to run away from someone if you add
//.north .south .east .west macros to your byond macros and they'll stack together with our macros here causing you
//to move really fast
client
	North() return 0
	South() return 0
	East() return 0
	West() return 0


//if you key up then key down in the same tick you still have to move 1 tile! just something to remember
mob/var/tmp
	north=0 //if north=1 then the player is currently holding W or the Up Arrow, and their character will attempt to move north so long as nothing else prevents it
	south=0 //same, etc, etc
	east=0
	west=0
	move_looping //our move loop proc is currently running if 1, or not if 0
	list/keys_down=new
	last_direction_pressed = NORTH //not sure why the default value is NORTH but im sure its for a reason

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

obj/var/repeat_macro //not sure why we keep this here but obj.repeat_macro is used for our hotbar objects which tell the hotbarred object how to behave if the player holds
//down the key. if repeat_macro=1 then the hotbar object will fire its action every tick that the player holds the button, but if repeat_macro=0 it will only fire its action
//once regardless if the player holds down the button

//a utility proc to tell us which direction we DESIRE to move based on which WASD/arrowkeys we are currently holding down
mob/proc/Macro_direction()
	if(north>=world.time && east>=world.time) return NORTHEAST
	if(north>=world.time && west>=world.time) return NORTHWEST
	if(south>=world.time && east>=world.time) return SOUTHEAST
	if(south>=world.time && west>=world.time) return SOUTHWEST
	if(north>=world.time) return NORTH
	if(south>=world.time) return SOUTH
	if(west>=world.time) return WEST
	if(east>=world.time) return EAST

//i really cant tell the difference between this and the Macro_direction() proc. not sure why i have both. maybe they are different somehow but i dont see it
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

//called from the interface/skin file, within the macro menu.
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

	//i dont know why but it seems we need to remove a key from the keys_down list up to 3 times before it actually removes itself. not sure if this bug still exists but this is
	//just a safety mechanism i left in anyway to make sure. ideally we would only have to remove it once, but oh well.
	for(var/v in 1 to 3)
		keys_down-=d

	keys_down+=d
	if(d in list("north","south","east","west"))

		//attempting to move will cancel digging and regenerating for their convenience
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
		if(client && client.ctrl_button) warped = DoubleTapWarp(d) //this checks if you intentionally double tapped the same direction which will then zanzoken you like 10 tiles in that direction
		//Dash_Evade(Macro_direction(), from_double_tap=double_tapped)

		if(!warped) move_loop() //start our normal macro moving loop so long as we didnt just do a zanzoken double tap warp
	else
		HotbarUseHandler(d) //the key we just pressed was not a directional key, so we instead check if the key pressed relates to any of our hotbar skills

//if the keyboard button "d" relates to any of our hotbarred skills, use that skill
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

//stop using the hotbarred skill if they release the key.
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

	//you just double tapped spacebar, which does one of two things depending on context:
	//1) if you just knockbacked someone and that person is still in the process of being knockbacked, and you doubletap spacebar you will automatically warp next to them
		//and hit them again. not many people seem to be aware of this feature, if it even works. i never really use it.
	//2) you perform a lunge attack on any target that is available if any
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
	AlignToTile() //if they stop moving, align them to the nearest tile, setting step_x and step_y back to 0, so as to cancel out any appearance of pixel movement when they stop moving


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

//this is the proc which will actually move the player based on the player's current desired movement input
mob/proc/move_loop()
	set waitfor=0
	if(move_looping) return //only allow 1 instance of the proc to run at once
	move_looping=1
	var/first_step=1
	if(!Shadow_Sparring) sleep(world.tick_lag) //for whatever reason if we do not delay the first step by 1 tick, it appears unsmooth. however if they are currently shadow
		//sparring we dont do this because you cant move while shadow sparring anyway, only change direction to face the shadow, so no need to delay it to hide any unsmoothness
	while(north || south || east || west)
		var/d = move_dir()

		last_direction_pressed = d

		if(d && Allow_Move(d) && z) //Allow_Move() takes a direction "d" and determines if we are doing anything that would prevent us from being allowed to move in that direction
			//var/turf/pos = loc

			var/turf/prev_loc = base_loc()
			var/prevDir = dir
			step(src,d)
			if(client && client.shift) dir = prevDir //strafing. if they are holding shift (client.shift=1) then do not let their direction change
			if(prev_loc != base_loc()) last_input_move = world.time
			UpdateNextInputMoveTime(d) //set some variables which create whatever movement delay we should currently be experiencing while moving, based on our speed or other status effects such as paralysis etc

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

		if(first_step && !Shadow_Sparring) sleep(world.tick_lag * 2) //no clue why, except that it looks unsmooth if i remove it, or it was to prevent "double moving"
			//where you pressed the button 1 time and it moves 2 tiles for no good reason. either way, without this, it doesnt work right
		else sleep(world.tick_lag) //if its not the first step, then move us 1 time per tick like normal

		first_step=0

		//literally no clue what these being assigned "2" was supposed to represent. but i see if they are ever assigned "2" then it will set them to "0" upon reaching this code
		//but ctrl+f does not reveal these variables ever being set to 2, so, im pretty sure this is nonsense!
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

//all called from skin/interface file's macro menu
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
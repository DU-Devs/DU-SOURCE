//if you key up then key down in the same tick you still have to move 1 tile!
mob/var/tmp
	north=0
	south=0
	east=0
	west=0
	move_looping
	list/keys_down=new

mob/var/tmp/last_keydown_time=0

mob/verb/KeyDown(d as text)
	set hidden=1
	set instant=1

	if(!(d in list("north","south","east","west")))
		if(last_keydown_time==world.time) return
		last_keydown_time=world.time

	switch(d)
		if("north") north=world.time
		if("south") south=world.time
		if("east") east=world.time
		if("west") west=world.time
	//world<<"KeyDown time: [world.time]"

	for(var/v in 1 to 7)
		keys_down-=d

	keys_down+=d
	if(d in list("north","south","east","west")) move_loop()
	else
		var/obj/o=Get_hotbar_obj_by_key_pressed(d)
		var/loops=0
		while(d in keys_down)
			if(!loops||loops>=3)
				if(o&&o.can_hotbar) o:Hotbar_use(usr)
			loops++
			sleep(world.tick_lag)


mob/verb/KeyUp(d as text)
	set hidden=1
	set instant=1
	//world<<"KeyUp time: [world.time]"

	for(var/v in 1 to 7)
		keys_down-=d

	switch(d)
		if("north")
			if(world.time<=north+3) //if you key up and key down in the same tick you must still move 1 tile
				north=2 //value of 2 will cause the var to reset to 0 after the move loop moves once more
			else north=0
		if("south")
			if(world.time<=south+3) //if you key up and key down in the same tick you must still move 1 tile
				south=2 //value of 2 will cause the var to reset to 0 after the move loop moves once more
			else south=0
		if("west")
			if(world.time<=west+3) //if you key up and key down in the same tick you must still move 1 tile
				west=2 //value of 2 will cause the var to reset to 0 after the move loop moves once more
			else west=0
		if("east")
			if(world.time<=east+3) //if you key up and key down in the same tick you must still move 1 tile
				east=2 //value of 2 will cause the var to reset to 0 after the move loop moves once more
			else east=0

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

mob/proc/move_loop()
	if(move_looping) return
	move_looping=1
	var/first_step=1
	if(!Shadow_Sparring) sleep(world.tick_lag)
	while(north||south||east||west)
		var/d=move_dir()
		if(d&&Allow_Move(d)&&z) step(src,d)

		if(first_step && !Shadow_Sparring) sleep(world.tick_lag*2)
		else sleep(world.tick_lag)
		first_step=0

		if(north==2) north=0
		if(south==2) south=0
		if(east==2) east=0
		if(west==2) west=0
	move_looping=0
//SEE UTILITIES.DM AND TARGETING.DM FOR MORE RELATED HELPER PROCS



//dont use this one its not as good
proc/pixel_step_towards(mob/a,mob/b,step_dist)
	if(!step_dist) step_dist=a.step_size
	//this extra code prevents jittering from overshooting the target due to step size exceeding distance needed
	var/step_y_diff=abs((a.step_y + a.y * world.icon_size) - (b.step_y + b.y * world.icon_size))
	var/step_x_diff=abs((a.step_x + a.x * world.icon_size) - (b.step_x + b.x * world.icon_size))
	if(step_y_diff<step_dist) step_dist=step_y_diff
	if(step_x_diff<step_dist) step_dist=step_x_diff
	step(a,pixel_dir(a,b),step_dist)

atom/movable/proc
	bound_center()
		return list(bound_center_x(),bound_center_y())

	bound_center_x()
		return x-1 + (step_x + bound_x + round(bound_width/2)) / world.icon_size

	bound_center_y()
		return y-1 + (step_y + bound_y + round(bound_height/2)) / world.icon_size

turf/proc
	bound_center()
		return list(bound_center_x(), bound_center_y())

	bound_center_x()
		return x - 1 + (32 / 2 / world.icon_size)

	bound_center_y()
		return y - 1 + (32 / 2 / world.icon_size)

proc/angle_to_cardinal_dir(ang)
	if(num_between(ang,0,45)) return NORTH
	if(num_between(ang,45,135)) return EAST
	if(num_between(ang,135,225)) return SOUTH
	if(num_between(ang,225,315)) return WEST
	if(num_between(ang,315,360)) return NORTH

proc/cardinal_pixel_dir(mob/a,mob/b)
	var/ang = get_global_angle(a,b)
	return angle_to_cardinal_dir(ang)

proc/get_abs_angle(mob/a,mob/b)
	return abs(get_angle(a,b))

proc/get_angle(mob/a,mob/b)
	//first you have to find the distance between the ref and the object
	var
		dx=b.bound_center_x() - a.bound_center_x()
		dy=b.bound_center_y() - a.bound_center_y()
	//then the angle equals arctan(distx/disty)
	var/ang = arctan(dx,dy)
	//convert to relative angle
	ang -= dir_to_angle(a.dir)
	if(ang>180) ang-=360
	return ang

proc/dir_to_angle(d)
	if(!d) clients << "INVALID ANGLE"
	switch(d)
		if(EAST) return 0
		if(NORTHEAST) return 45
		if(NORTH) return 90
		if(NORTHWEST) return 135
		if(WEST) return -180
		if(SOUTHWEST) return -135
		if(SOUTH) return -90
		if(SOUTHEAST) return -45

//0 to 360
proc/dir_to_angle_0_360(d)
	switch(d)
		if(NORTH) return 0
		if(NORTHEAST) return 45
		if(EAST) return 90
		if(SOUTHEAST) return 135
		if(SOUTH) return 180
		if(SOUTHWEST) return 225
		if(WEST) return 270
		if(NORTHWEST) return 315

proc/angle_clamp_0_360(ang)
	while(ang>360) ang-=360
	while(ang<=0) ang+=360
	return ang

proc/get_dir_as_text(mob/a,mob/b)
	switch(get_dir(a,b))
		if(NORTH) return "north"
		if(SOUTH) return "south"
		if(EAST) return "east"
		if(WEST) return "west"
		if(NORTHEAST) return "northeast"
		if(SOUTHEAST) return "southeast"
		if(NORTHWEST) return "northwest"
		if(SOUTHWEST) return "southwest"

proc/dir_to_text(d)
	switch(d)
		if(NORTH) return "north"
		if(SOUTH) return "south"
		if(EAST) return "east"
		if(WEST) return "west"
		if(NORTHEAST) return "northeast"
		if(SOUTHEAST) return "southeast"
		if(NORTHWEST) return "northwest"
		if(SOUTHWEST) return "southwest"

proc/text_to_cardinal_dir(d)
	switch(d)
		if("north") return NORTH
		if("south") return SOUTH
		if("east") return EAST
		if("west") return WEST

proc/pixel_dir_old_dont_use(mob/a,mob/b)
	var
		ax=a.step_x + a.x * world.icon_size
		ay=a.step_y + a.y * world.icon_size
		bx=b.step_x + b.x * world.icon_size
		by=b.step_y + b.y * world.icon_size
	if(by>ay)
		if(bx>ax) return NORTHEAST
		if(bx<ax) return NORTHWEST
		return NORTH
	if(by<ay)
		if(bx>ax) return SOUTHEAST
		if(bx<ax) return SOUTHWEST
		return SOUTH
	if(bx>ax) return EAST
	return WEST

	/*var
		ax=a.bound_center_x()
		ay=a.bound_center_y()
		bx=b.bound_center_x()
		by=b.bound_center_y()
	if(by>ay)
		if(bx>ax) return NORTHEAST
		if(bx<ax) return NORTHWEST
		return NORTH
	if(by<ay)
		if(bx>ax) return SOUTHEAST
		if(bx<ax) return SOUTHWEST
		return SOUTH
	if(bx>ax) return EAST
	return WEST*/

proc/pixel_dist(mob/a,mob/b)
	var/dist_x = abs(a.bound_center_x() - b.bound_center_x())
	var/dist_y = abs(a.bound_center_y() - b.bound_center_y())
	return max(dist_x,dist_y)

proc/clamp2(n=0,min=0,max=0)
	if(n>max) n=max
	if(n<min) n=min
	return n
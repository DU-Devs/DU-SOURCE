/*
let drones act as body guards

drones deployed from a satellite. can only have 5 drones out simultaenously, if 1 is destroyed it
takes 15 mins to repair it. it monitors illegal activity and teleports a drone down to stop it

make it so you can make murder illegal. if anyone commits murder the satellite detects it and deploys
a drone

redo drones with the idea that they are used for people to conquer planets and the galaxy

have a global crime checker loop for drones, instead of each drone actually roaming around searching
for crimes and having the loop on each of them. a global satellite monitors all players on the planet,
checks if they are committing a crime, and dispatches a drone to act appropriately. or more than 1
drone depending on the power of the player. it makes it a fair fight so the player feels they stand a
chance, but they will always be hunted.

seems like drones could just use g_step for all their movements like new trolls do

make it so you can set drones to kill, injure, or just KO, or jail

drones should be able to hunt bounties for you

add location defense to drones

if you order drones to assemble they should automatically be able to get aboard the ship your on or  the cave
your in by reading to gotoz var/to see if it matches yours.

drones kill enemy drones

make sure rebuild module works on drones

make drones able to go thru doors of their creator so that they dont bust up the base when they rebuild
*/
var/list/drone_list=new //contains all drone AI modules - NOT mobs. still used to look up the mobs tho
var/list/drone_info=new //stores all the information a drone needs to access to the frequency it is using

mob/var/tmp/obj/Module/Drone_AI/drone_module

mob/proc/Get_drone_module()
	if(drone_module) return drone_module
	for(var/obj/Module/Drone_AI/d in src) if(d.suffix) return d

mob/proc/Drone_initialize_new()
	if(!drone_module) drone_module=Get_drone_module()
	Drone_AI()

mob/proc/Drone_AI()
	set waitfor=0
	return

//unreachable_targets
//Remove_unreachable_target(Target,1800)
//get_move_delay(move_dir=d)





/*
probably store the path in a var/and only update it if movement along the path fails or the target has moved
more than a certain distance from the destination
*/



//Kuraudo.libpathfinder
proc/get_path(mob/a,mob/b)
	set background=1
	a=a.base_loc()
	b=b.base_loc()
	if(!a||!b||!isturf(a)||!isturf(b)||a==b||a.z!=b.z) return
	var/pathfinder/astar/path=new
	return path.search(a,b)

mob/Admin5/verb/pathtest(mob/m in world)
	var/style
	switch(alert(src,"What kind of pathfinding?","Options","BYOND","Other","New"))
		if("BYOND") style=1
		if("Other") style=2
		if("New") style=3
	var/list/path=get_path(src,m)
	if(!path) alert("No path found")
	if(style==3)
		for(var/turf/t in path)
			new/turf/GroundDirt(t)
			for(var/obj/o in t) del(o)
			SafeTeleport(t)
			sleep(1)
		return
	while(getdist(m,src)>1)
		if(style==1&&move)
			var/turf/t=get_step_to(src,m)
			if(t) step_towards(src,t)
		if(style==2&&move)
			//var/turf/t=G_get_step_to(m)
			//if(t) step_towards(src,m)
			g_step_to(m)
		sleep(1)
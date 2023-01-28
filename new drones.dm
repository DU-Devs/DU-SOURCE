/*
Patrol for illegal actions/items
Assemble
*/
mob/proc/drone_patrol()
	while(src)
		if(drone_order()=="patrol")
		else sleep(100)
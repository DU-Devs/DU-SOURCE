mob/var/tmp/Instant
mob/var/tmp
	debug_move_delay
	avg_delay=0
	how_many_moves=0
	no_move_delay
mob/Admin5/verb/no_move_delay()
	set category="SPECIAL"
	no_move_delay=!no_move_delay
	if(no_move_delay) src<<"move delays are now off for you"
	else src<<"move delays are now on for you"
mob/Admin1/verb/debug_move_delays()
	set category="SPECIAL"
	debug_move_delay=!debug_move_delay
	if(debug_move_delay) src<<"debug move delay info on"
	else src<<"off"
mob/proc/move_delay() if(client)
	if(no_move_delay) return
	move=0
	var/delay=1*(Speed_Ratio()**0.43)
	if(!Flying) for(var/obj/Injuries/Leg/I in src) delay*=2
	var/adj_health=Health
	if(adj_health<1) adj_health=1
	if(adj_health>100) adj_health=100
	var/health_effect=(100/adj_health)**0.5
	if(health_effect>5) health_effect=5
	if(!undelayed) delay*=health_effect
	if(Flying) delay*=0.5
	delay=Delay(delay) //forms the remaining decimals into the probability of increasing delay by 1
	if(delay) spawn(delay) move=1
	else move=1
	if(debug_move_delay)
		avg_delay+=delay
		how_many_moves++
		src<<"move delay: [delay/10] seconds (total average delay: [avg_delay/how_many_moves/10])"
mob/Move(turf/Location,Direction)
	var/Former_Location=loc
	if(Instant||KB) ..()
	else if(Can_Move())
		if((!client&&type!=/mob/Troll&&type!=/mob/new_troll)||KB||(locate(/obj/Michael_Jackson) in src)) ..()
		else
			move_delay()
			if(client) Leave_Destroyed_Planet()
			if(Flying) density=0
			if(istype(src,/mob/Enemy/Spider_Small)&&(locate(/mob/Enemy/Spider_Small) in oview(1,src))) density=0
			..()
			if(client) Safezone()
			if(initial(density)) density=1
			Save_Location()
			if(client) for(var/obj/items/Transporter_Pad/A in loc) A.Transport()
		Edge_Check(Former_Location) //tab back to apply to npcs again
		if(client&&!KB&&Target&&istype(Target,/obj/Build)) Build_Lay(Target,src)
mob/proc/Can_Move()
	if(KB||Disabled()||!move) return
	else return 1
mob/proc/Edge_Check(turf/Former_Location)
	for(var/mob/A in loc) if(A!=src&&A.Flying&&Flying)
		loc=Former_Location
		break
	for(var/obj/Turfs/Door/A in loc) if(A.density)
		loc=Former_Location
		Bump(A)
		break
	if(!Flying)
		var/turf/T=get_step(Former_Location,dir)
		if(T)
			if(!T.Enter(src)) return
			for(var/obj/Edges/A in loc)
				Bump(A)
				if(A) if(!(A.dir in list(dir,turn(dir,90),turn(dir,-90),turn(dir,45),turn(dir,-45))))
					loc=Former_Location
					break
			for(var/obj/Edges/A in Former_Location)
				Bump(A)
				if(A) if(A.dir in list(dir,turn(dir,45),turn(dir,-45)))
					loc=Former_Location
					break
mob/proc/Save_Location() if(z&&!Regenerating)
	saved_x=x
	saved_y=y
	saved_z=z
mob/proc/Leave_Destroyed_Planet() if(locate(/turf/Other/Stars) in range(0,src)) Liftoff(src)
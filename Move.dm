/*atom/movable
	proc/Bumped(atom/Obstacle)
	Bump(atom/Obstacle)
		..()
		Obstacle.Bumped(src)*/

mob/var/tmp/Instant
atom/var/can_side_step=1

mob/proc/move_delay(d) if(client)
	move=0
	var/delay=get_move_delay(move_dir=d)

	if(delay<world.tick_lag) delay=world.tick_lag //so you cant move more than once per tick with the interpreted move macro code

	if(delay>world.tick_lag) spawn(delay) move=1
	else move=1

mob/proc/get_move_delay(flying_counts=1,move_dir)
	if(step_size!=32) return 0 //no delay

	var/delay=1

	//delay+=0.15 * (Speed_delay_mult(severity=0.2)-1)

	if(Being_chased()) delay+=1

	if(senzu_overload) delay++
	if(sight) delay+=2
	if(fearful)
		var/fear_slow_down=1
		if(chaser && getdist(src,chaser)>20) fear_slow_down+=0.5
		delay+=fear_slow_down
	if(!Flying) for(var/obj/Injuries/Leg/i in injury_list) delay+=2
	if(stun_level) delay+=stun_level*2

	var/health_slowdown_start=25 * Speed_delay_mult(severity=0.5)
	if(health_slowdown_start>100) health_slowdown_start=100
	if(Health<health_slowdown_start && !undelayed && !Zombie_Power)
		var/health_slowdown=(health_slowdown_start-Health) / 12
		if(health_slowdown>1.5) health_slowdown=1.5
		delay+=health_slowdown

	//if(move_dir) if(move_dir in list(NORTHEAST,NORTHWEST,SOUTHEAST,SOUTHWEST))
	//	delay*=1.3

	delay*=world.tick_lag
	delay=To_tick_lag_multiple(delay)

	return delay

mob/var/tmp
	has_delay=1
	side_step_objs=1

mob/proc/Moving_auto_attack()
	if(Auto_Attack) Melee(from_auto_attack=1)

mob/Move(NewLoc,Dir=0,step_x=0,step_y=0)
	Cease_training()
	var/Former_Location=loc
	var/old_dir=dir
	if((Instant && !battle_test) || KB) ..()
	else if(Can_Move())
		if(!battle_test && ((!client && type!=/mob/Troll && type!=/mob/new_troll) || KB))
			..()
			if(side_step_objs && loc==Former_Location)
				side_step_objs=0
				step(src,turn(dir,pick(45,-45)))
				side_step_objs=1
		else
			var/mob/mob_in_front
			if(Flying)
				mob_in_front=locate(/mob) in Get_step(src,dir)
				if(!mob_in_front || !mob_in_front.Flying) density=0

			var/mob/side_stepped_mob
			if(Dir in list(turn(dir,45),turn(dir,-45)))
				if(mob_in_front) side_stepped_mob=mob_in_front
				else side_stepped_mob=locate(/mob) in Get_step(src,dir)

			..()
			Opponent_move_slower_if_you_are_chasing_them()

			if(loc==Former_Location && dir==old_dir)
				if(side_step_objs)
					var/turf/t=NewLoc
					if(t && isturf(t))
						if(!(locate(/mob) in t) && !(locate(/obj/Blast) in t))
							old_dir=dir
							side_step_objs=0
							move=1
							step(src,pick(turn(old_dir,45),turn(old_dir,-45)))
							if(loc==Former_Location)
								move=1
								step(src,turn(old_dir,45))
							if(loc==Former_Location)
								move=1
								step(src,turn(old_dir,-45))
							side_step_objs=1
							if(loc==Former_Location) dir=old_dir
			else if(has_delay) move_delay(Dir)

			if(side_stepped_mob)// && zanzoken_uses<Max_zanzokens())
				move=1
				//zanzoken_uses+=0.4
				player_view(10,src)<<sound('teleport.ogg',volume=15)
				After_Image(T=7,loc_override=Former_Location)
				dir=get_dir(src,side_stepped_mob)
				var/side_step_defend_chance=33*(side_stepped_mob.BP/BP)**0.5*(side_stepped_mob.Def/Off)**1
				if(prob(side_step_defend_chance)) side_stepped_mob.dir=get_dir(side_stepped_mob,src)

			/*var/turf/t=loc
			spawn(2) if(loc==t&&side_stepped_mob)
				dir=get_dir(src,side_stepped_mob)
				var/side_step_defend_chance=30*(side_stepped_mob.BP/BP)**0.5*(side_stepped_mob.Def/Off)**0.5
				if(prob(side_step_defend_chance)) side_stepped_mob.dir=get_dir(side_stepped_mob,src)*/

			Moving_auto_attack()

			if(client) Safezone()
			if(initial(density)) density=1
			Save_Location()
			//if(client&&isturf(loc)) for(var/obj/items/Transporter_Pad/A in loc) A.Transport()
			Edge_Check(Former_Location) //tab back to apply to npcs again
		if(client && !KB && Target && istype(Target,/obj/Build)) Build_Lay(Target,src)
	if(client && prob(10) && is_on_destroyed_planet()) z=16

	Update_grab()
	if(client || prob(5)) update_area()

mob/proc/update_area()
	var/turf/t=True_Loc()

	if(!t && current_area)
		current_area.mob_list-=src
		current_area.player_list-=src
		current_area.npc_list-=src
		current_area=null

	if(t && isturf(t))
		var/area/a=t.loc
		if(a!=current_area)
			if(current_area)
				current_area.mob_list-=src
				current_area.player_list-=src
				current_area.npc_list-=src

				current_area.mob_list=remove_nulls(current_area.mob_list)
				current_area.player_list=remove_nulls(current_area.player_list)
				current_area.npc_list=remove_nulls(current_area.npc_list)

			a.mob_list+=src
			if(client) a.player_list+=src
			else a.npc_list+=src
			current_area=a

			if(client&&istype(a,/area/Vegeta_Core)) Start_core_loops()
			Final_realm_loop()

			for(var/obj/items/Dragon_Ball/db in item_list) if(db.loc==src)
				if(!current_area || current_area.type!=db.Home) db.Land()

mob/var/tmp/area/current_area
area/var/tmp/list
	mob_list=new
	player_list=new
	npc_list=new

mob/proc/Can_Move()
	if(KB||!move||strangling||Disabled()) return
	else return 1

mob/proc/Edge_Check(turf/Former_Location)
	if(Flying) for(var/mob/A in loc) if(A!=src&&A.Flying)
		loc=Former_Location
		break
	for(var/obj/Turfs/Door/A in loc) if(A.density)
		loc=Former_Location
		Bump(A)
		break

	//return

	if(!Flying)
		var/turf/T=Get_step(Former_Location,dir)
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

mob/proc/Cease_training()
	if(Action=="Training") Train()
	if(Action=="Meditating") Meditate()
	if(auto_train) AI_Train()
	if(Shadow_Sparring) Shadow_Spar()
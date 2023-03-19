/*
now that drone step simply uses byond's step_to, when we use step_to then end up not actually moving, instead of
repeatedly using step_to and not moving over and over, just make it stop trying to step_to and destroy the obstacle
preventing movement, or give up.



make it so rebuild actually does something for drones

make a proc to get the genetics comp of the drone

move all drone info to a list so that genetics comp is no longer needed

drones need to occassionally go into teleporters when on patrol
drones need a command to guard an object or location
optional to set drones as lethal/nonlethal
*/
mob/var/Drone_Order=0 //The number of the last order they recieved so orders do not stack
mob/var/Pkey //The key of the last person who sent the drones an order

mob/proc/Drone_initialize()
	var/obj/Module/Drone_AI/D=Get_Drone_AI()
	drone_module=D
	if(client) return //no more players with drone ai installed on them auto fighting and spamming beams at the same time
	if(D&&D.Commands)
		if("Gather" in D.Commands) spawn Collect_Resources(10000)
		if("Steal" in D.Commands) spawn Steal_Resources(100000)
		if("Genocide" in D.Commands) spawn Drone_Genocide(Race_to_Genocide)
		if("Assemble" in D.Commands) D.Commands-="Assemble"
		if("Patrol" in D.Commands) spawn Drone_Patrol()
	auto_regen_mobs+=src
	auto_recov_mobs+=src
	spawn Drone_Blast_Response()
	spawn Drone_Beam_Response()
	spawn Drone_Grab_Struggle()
	spawn Drone_Attack_Gain_Loop()
	Drone_get_bp_loop()
	Drone_bug_thingy()

mob/proc/Drone_self_repair()
	//because i updated to make androids stuck at 1 bp and fully rely on cyber bp
	base_bp=1
	hbtc_bp=1
	if(Health>=90&&Ki>=max_ki*0.9) return
	if(drone_attack_loop) return
	Say("Initializing self repair")
	sleep(200)
	if(Health<100) Health=100
	if(Ki<max_ki) Ki=max_ki

mob/proc/Drone_bug_thingy()
	set waitfor=0
	while(src)
		if(!z) return
		if(!client)
			if(Health>100) Health=100
			if(Ki>max_ki) Ki=max_ki
			sleep(50)
		else sleep(600)

mob/proc/Drone_Blast_Response() while(src)
	if(!z) return
	if(!client)
		for(var/obj/Blast/B in blast_view(11,src))
			if(B.type==/obj/Blast/Genki_Dama)
				var/mob/m=B.Owner
				spawn if(m&&ismob(m)&&!Is_drone_master(m)) Drone_Attack(m,lethal=1)
			else if(!B.Beam) if(get_dir(src,B) in list(NORTH,SOUTH,EAST,WEST))
				if(B.dir==get_dir(B,src)) if(ismob(B.Owner)&&B.Owner.client)
					step(src,turn(B.dir,pick(-90,90)))
					var/mob/P=B.Owner
					spawn if(P&&ismob(P)&&!Is_drone_master(P)) Drone_Attack(P,lethal=1)
		sleep(rand(5,7))
	else sleep(600)
mob/proc/Drone_Beam_Response() while(src)
	if(!z) return
	if(!client)
		for(var/obj/Blast/B in blast_view(11,src)) if(B.Beam)
			if(get_dir(src,B) in list(NORTH,SOUTH,EAST,WEST)) if(B.dir==get_dir(B,src)) if(!viewable(src,B,2))
				if(prob(50)||frc_share()<=str_share()*0.6)
					step(src,turn(B.dir,pick(-90,90)))
					var/mob/P=B.Owner
					sleep(rand(8,12))
					spawn if(P&&ismob(P)&&!Is_drone_master(P)) Drone_Attack(P,lethal=1)
				else if(ismob(B.Owner))
					dir=get_dir(src,B)
					var/mob/P=B.Owner
					var/obj/Attacks/Beam/O
					for(var/obj/Attacks/Z in P.ki_attacks) if(Z.streaming) O=Z
					if(P&&O)
						for(var/obj/Attacks/Beam/C in ki_attacks)
							if(!C.charging&&!C.streaming&&!attacking)
								Beam_Macro(C)
								sleep(rand(8,12))
								Beam_Macro(C)
								while(P&&!P.KO&&O.streaming) sleep(1)
								if(!P.KO) sleep(rand(20,30))
								Beam_Macro(C)
								sleep(rand(8,12))
								spawn if(P&&ismob(P)&&!Is_drone_master(P)) Drone_Attack(P,lethal=1)
							break
		sleep(rand(7,13))
	else sleep(600)

mob/proc/Drone_Grab_Struggle() while(src)
	if(!z) return
	if(!client)
		if(grabber&&!Is_drone_master(grabber))
			Allow_Move(dir)
			sleep(10)
		else sleep(rand(20,30))
	else sleep(600)

mob/proc/Drone_Attack_Gain_Loop() while(src)
	if(!z) return
	if(!client)
		var/Amount=1
		if(Opponent(65)) Attack_Gain(Amount)
		sleep(rand(Amount*7,Amount*13))
	else sleep(600)

mob/proc/Drone_get_bp_loop() while(src)
	set waitfor=0
	sleep(100)
	if(!z) return
	if(!client)
		if(BPpcnt<0.01) BPpcnt=0.01
		if(Ki<0) Ki=0
		if(Age<0) Age=0
		if(real_age<0) real_age=0
		Body()
		BP = get_bp() * drone_power
		sleep(rand(40,60))
	else sleep(600)

mob/proc/Drone_Retrieve(mob/P,mob/M) M<<"This feature is incomplete."

mob/proc/drone_master_msg(t)
	if(!t||t==""||!drone_module) return
	for(var/obj/rt in robotics_tools) if(rt.Password==drone_module.Password&&ismob(rt.loc))
		var/mob/m=rt.loc
		m<<t

mob/var/tmp/drone_attack_loop
mob/var/tmp/turf/last_known_target_position
mob/var/tmp/last_target_position_update_time=0

mob/proc/Drone_Attack(mob/P,lethal)
	set waitfor=0
	if(client) return
	if(Overdrive) Overdrive_Revert()
	if(!z) return
	if(Target==P) return //Prevent stacking
	Target=P
	var/Instance=Drone_Order
	drone_attack_loop=1

	if(ismob(P) && P.drone_module && drone_module && P.drone_module.Password==drone_module.Password && !P.client)
		Target=null
		drone_attack_loop=0
		return


	if(isobj(P)) while(P && P.z==z && Instance==Drone_Order && Target==P && getdist(src,P)<=10 && viewable(src,P))
		if(!viewable(src,P,1)) drone_step(P,ignore_master=1,from_drone_attack=1)
		else
			if(loc==P.loc) step_away(src,P)
			dir=get_dir(src,P)
			Land()
		if(P in Get_step(src,dir))
			var/obj/o=P
			var/scrap_value=o.Scrap_value()
			Melee(P)
			if(!P) Alter_Res(scrap_value)
		sleep(1)

	if(ismob(P))
		//if(!Overdrive&&(locate(/obj/Module/Overdrive) in active_modules)) spawn Overdrive()
		while(Instance==Drone_Order && P && Target==P)
			var/max_cave_dist=30
			if(P.last_cave_entered && world.time-P.last_cave_entered_time<50 && z==P.last_cave_entered.z && \
			get_area()==P.last_cave_entered.get_area() && getdist(src,P.last_cave_entered)<=max_cave_dist)
				var/turf/cave=P.last_cave_entered
				var/steps=0
				while(P && steps<60 && !viewable(src,P,max_cave_dist))
					steps++
					Fly()
					drone_step(cave,ignore_master=1,from_drone_attack=1,avoid_caves=0)
					if(get_dist(src,cave)<=1)
						cave.Enter(src)
						break
					sleep(world.tick_lag)
			if(P.locz()!=z || P.get_area()!=get_area()) break
			else
				//drones get better position tracking against people who try to use pods cuz it is a cowardly tactic
				if(P.KB || P.Ship || world.time>=last_target_position_update_time+ToOne(3.7))
					last_target_position_update_time=world.time
					last_known_target_position=P.base_loc()

				if(P.Flying) Fly()
				if(get_dist(src,last_known_target_position)>1)
					drone_step(last_known_target_position,ignore_master=1,from_drone_attack=1)
				else
					if(loc==last_known_target_position) step_away(src,last_known_target_position)
					dir=get_dir(src,last_known_target_position)
					if(!P.Flying) Land()
				if(P && P.base_loc()==Get_step(src,dir))
					var/sub_target=P
					if(P.Ship) sub_target=P.Ship
					Melee(sub_target)
					if(P && P.KO && (!P.Dead || z!=5))
						if(getdist(src,P.base_loc())>1) for(var/v in 1 to 30)
							drone_step(P,ignore_master=1,from_drone_attack=1)
							sleep(world.tick_lag)
							if(!P || getdist(src,P.base_loc())<=1) break
						if(P && getdist(src,P.base_loc())<=1) Drone_steal_from_player(P)
						if(lethal && P && getdist(src,P.base_loc())<=1)
							if(P.client) drone_master_msg("<font color=red>[P] was just killed by [src] on [P.get_area()] ([P.x],[P.y],[P.z])")
							else if(P.drone_module) drone_master_msg("<font color=red>[P] was just killed by [src] on [P.get_area()] (Enemy Drone)")
							P.Death(src,Force_Death=1,lose_immortality=0)
					if(drone_module && ("Genocide" in drone_module.Commands) && P && P.Dead && z==5) Target = null //stop drones from killing dead people in AL

			sleep(world.tick_lag)
			//if(P && (P.Ship || getdist(src,P)>10)) sleep(world.tick_lag)
			//else sleep(world.tick_lag*2)

		//if(Overdrive&&!Target) Overdrive_Revert()

	if(isturf(P))
		if(!Drone_can_break_this_wall(P))
			sleep(30)
		else
			while(Instance==Drone_Order && P && Target==P && P.z==z)
				if(get_dist(src,P)>1)
					Fly()
					drone_step(P,ignore_master=1,from_drone_attack=1)
				else
					if(loc==P.loc) step_away(src,P)
					dir=get_dir(src,P)
					Land()
				if(P==Get_step(src,dir)) Melee(P)
				sleep(1)

	Target=null
	drone_attack_loop=0

mob/proc/Key_Passwords()
	var/list/L=new
	for(var/obj/items/Door_Pass/D in item_list) L+=D.Password
	return L

mob/proc/Master_is_near()
	for(var/mob/P in player_view(12,src)) if(P.client&&Is_drone_master(P)) return 1

mob/proc/Is_drone_master(mob/m)
	var/df=Drone_Frequency()

	var/list/l=m.Key_Passwords()
	if(df in l) return 1

	var/list/league_ids=m.Get_league_drone_IDs()
	if(league_ids && (df in league_ids)) return 1

	for(var/obj/items/Robotics_Tools/rt in m.item_list) if(df==rt.Password) return 1

mob/proc/Drone_can_break_this_wall(turf/t)
	if(!t || (Pkey && t.Builder==Pkey) || t.Health==1.#INF) return
	return 1

mob/var/tmp/list/stored_path=new

mob/proc/drone_step(mob/P,ignore_master,from_drone_attack,avoid_caves=1)

	Warp=0 //combo teleporting drones very annoying

	var/Instance=Drone_Order

	if(!z) return
	if(!P||!Can_Move()) return

	if(!ignore_master&&Master_is_near())
		Say("Halting movement because master is near. Will resume when master leaves proximity.")
		while(Master_is_near()) sleep(50)

	while(drone_attack_loop && !from_drone_attack && Instance==Drone_Order) sleep(50)

	if(Flying && drone_pathfind_steps<=0) density=0
	var/Former_Loc=loc

	if(drone_pathfind_steps>0) for(var/obj/O in Get_step(src,dir)) if(O.density && O.Health!=1.#INF)
		for(var/v in 1 to 5)
			if(O) Melee(O)
			sleep(Get_melee_delay())
			if(!O||!O.density||O.loc!=Get_step(src,dir)||Instance!=Drone_Order) break
		break

	//punching every turf they came across for no good reason seemed uneccessarily intensive
	//var/turf/T=Get_step(src,dir)
	//if(T&&T.density) Melee(T)

	var/max_pathfind_steps=30
	if(drone_pathfind_steps<=0)
		if(P)
			var/turf/t=Get_step(src,get_dir(src,P.base_loc()))
			if(avoid_caves && istype(t,/turf/Teleporter))
				Fly()
				dir=get_dir(src,t)
				step(src,pick(turn(dir,45),turn(dir,-45)))
			else
				if(!(locate(/obj/Turfs/Door) in t))
					step_towards(src,P.base_loc())
					if(loc==Former_Loc)
						sleep(2)
						Fly()
						if(P) step_towards(src,P.base_loc())
			if(loc==Former_Loc)
				//stored_path=get_path(src,P.base_loc())
				drone_pathfind_steps=max_pathfind_steps
	else if(move)
		//Land()
		Fly()
		density=1
		if(P)
			var/turf/next_step=get_step_to(src,P.base_loc())
			if(avoid_caves && next_step && istype(next_step,/turf/Teleporter))
				Fly()
				dir=get_dir(src,next_step)
				step(src,pick(turn(dir,45),turn(dir,-45)))
			else
				if(next_step && (next_step.FlyOverAble || Drone_can_break_this_wall(next_step)))
					step_towards(src,next_step)
					/*if(stored_path.len)
						var/turf/t=stored_path[1]
						step_towards(src,t)
						if(loc==t) stored_path-=t*/
				else
					var/turf/attack_turf=Get_step(src,dir)
					if(next_step) attack_turf=next_step
					if(attack_turf!=P)
						if(Drone_can_break_this_wall(attack_turf))
							var/hits=0
							var/max_hits=1.#INF //20
							var/turf/p_original_loc=P.base_loc()
							while(Instance==Drone_Order && attack_turf && attack_turf.density && hits<max_hits && getdist(src,attack_turf)==1)
								hits++
								dir=get_dir(src,attack_turf)
								Melee(attack_turf)
								if(!P||(p_original_loc && getdist(P,p_original_loc)>10)) break
								else sleep(Get_melee_delay())
						else
							drone_pathfind_steps=0
							var/area/a=get_area()
							while(src)
								var/turf/t=locate(rand(1,world.maxx),rand(1,world.maxy),z)
								if(t && !t.Builder && !t.density && t.get_area()==a)
									SafeTeleport(t)
									break
								else sleep(20)
		drone_pathfind_steps--
		if(world.cpu>=80 && !drone_attack_loop) sleep(5)

	if(Target && viewable(src,Target.base_loc(),1))
		dir=get_dir(src,Target.base_loc())
		drone_pathfind_steps=0

	density=1

	for(var/mob/m in loc) if(m!=src)
		var/old_dir=dir
		step_away(src,m)
		dir=old_dir
		break

	for(var/obj/Blast/b in loc)
		var/old_dir=dir
		step_away(src,b)
		dir=old_dir
		break

	if(!drone_attack_loop)
		if(world.cpu>=80) sleep(5)
		else if(drone_pathfind_steps>0) sleep(3)

mob/var/tmp/drone_pathfind_steps=0

proc/Players_at_Z(A)
	var/list/Mobs=new
	for(var/mob/P in players) if(P.locz()==A) Mobs+=P
	return Mobs

proc/Get_Criminal(list/L,list/B)
	if(!L) return
	for(var/mob/P in L) if((P.key in B)&&(!P.Dead||P.z!=5)) return P

var/list/drone_instructions=new

mob/proc/Detect_Illegal_Activity()
	if(!drone_module) return
	if(tournament_override(fighters_can=0,show_message=0)) return
	if(!z || client) return

	var/list/drone_info
	if(drone_module && (drone_module.Password in drone_instructions)) drone_info=drone_instructions[drone_module.Password]
	if(!drone_info) return

	for(var/T in drone_module.Commands) if(T in list("Gather","Assemble","Genocide"))
		Say("Illegal activity ignored. Current orders override this action.")
		return

	var/mob/P=Get_Criminal(player_view(10,src),drone_info["kill list"])
	if(P && !P.Dead)
		Say("[P] has been declared a criminal. Commencing extermination.")
		sleep(15)
		Drone_Attack(P,lethal=1)

	//kill enemy drones
	if("Enemy Drones" in drone_info["illegals"])
		for(var/obj/o in drone_list) if(o.Password!=drone_module.Password&&ismob(o.loc))
			var/mob/m=o.loc
			if(m.z==z&&getdist(src,m)<=20&&m.get_area()==get_area())
				Say("Exterminating enemy drone.")
				spawn if(m) m.Drone_Attack(src,lethal=1)
				Drone_Attack(m,lethal=1)
				break

	if(Illegal_Activity_Bypass()) return

	for(var/obj/O in view(8,src)) if(locate(O.type) in drone_info["illegals"])
		if(O.z && !Duplicate_Target(O) && O.Password!=drone_module.Password && O.Health!=1.#INF)
			Say("[O]s are illegal. Commencing destruction of [O]. Do not interfere or you will be exterminated.")
			Drone_Attack(O)

	for(var/mob/m in player_view(12,src)) if(m!=src && !Duplicate_Target(m) && !Is_drone_master(m))
		if(!m.drone_module||m.drone_module.Password!=drone_module.Password)
			for(var/obj/o in m)
				if(o.Health!=1.#INF && (locate(o.type) in drone_info["illegals"]))
					if(!m.KO)
						Say("[o]'s are illegal. Commencing extermination.")
						Drone_Attack(m)
					else Say("[o]'s are illegal. Destroying.")
					sleep(5)
					while(m && m.KO && m.z==z && m.get_area()==get_area() && getdist(src,m)>1)
						drone_step(m,ignore_master=1)
						sleep(1)
					if(m && getdist(src,m)<=1 && o)
						player_view(15,src)<<"[src] destroys [o]!"
						Alter_Res(o.Scrap_value())
						del(o)
					break
	if("Turrets" in drone_info["illegals"]) for(var/obj/Turret/O in view(8,src)) if(Pkey!=O.Builder && O.Health!=1.#INF)  if(O.z&&!Duplicate_Target(O))
		if(O.Password!=drone_module.Password)
			Say("Turrets are illegal. Commencing destruction. Do not interfere or you will be exterminated.")
			Drone_Attack(O)
	if("Ships/Pods" in drone_info["illegals"]) for(var/obj/Ships/O in view(8,src)) if(O.z&&!Duplicate_Target(O) && O.Health!=1.#INF)
		Say("Ships and Spacepods are illegal. Commencing destruction. Do not interfere or you will be exterminated.")
		Drone_Attack(O)
	if("Doors" in drone_info["illegals"]) for(var/obj/Turfs/Door/O in view(8,src)) if(Pkey!=O.Builder) if(O.z&&!Duplicate_Target(O) && O.Health!=1.#INF)
		Say("Doors are illegal. Commencing destruction of Door. Do not interfere or you will be exterminated.")
		Drone_Attack(O)
	if("Ki Use" in drone_info["illegals"]) for(var/mob/M in player_view(10,src)) if(M.attacking==3&&M!=src&&M.client&&!Is_drone_master(M)) if(M.z&&!Duplicate_Target(M))
		Say("[M]. Ki usage is illegal. You will be exterminated.")
		Drone_Attack(M)
	if("Combat" in drone_info["illegals"]) for(var/mob/M in player_view(10,src)) if(M.attacking&&M!=src&&M.client&&!Is_drone_master(M)) if(M.z&&!Duplicate_Target(M))
		Say("[M]. Combat is illegal. You will be exterminated.")
		Drone_Attack(M)
	if("Training" in drone_info["illegals"]) for(var/mob/M in player_view(10,src)) if(M.Action=="Training"&&M!=src&&M.client&&!Is_drone_master(M)) if(M.z&&!Duplicate_Target(M))
		Say("[M]. Training is illegal. You will be exterminated.")
		Drone_Attack(M)
	if("Meditating" in drone_info["illegals"]) for(var/mob/M in player_view(10,src)) if(M.Action=="Meditating"&&M!=src&&M.client) if(M.z&&!Duplicate_Target(M)&&!Is_drone_master(M))
		Say("[M]. Meditating is illegal. You will be exterminated.")
		Drone_Attack(M)

mob/proc/Duplicate_Target(obj/O) for(var/mob/P in mob_view(15,src))
	if(P!=src&&Drone_Frequency()==P.Drone_Frequency()&&P.Target==O) return 1

mob/proc/Illegal_Activity_Bypass()
	for(var/mob/P in player_view(20,src))
		if(P.client&&Is_drone_master(P))
			Say("Illegal activity ignored because [P] is exempt from laws.")
			return 1

mob/proc/Drone_exit_ship(mob/master,obj/Ship_exit/exit)
	if(!z || !exit || exit.z!=z || !master) return
	if(master) Pkey=master.key
	Drone_Order++
	Target=null
	var/instance=Drone_Order
	var/steps=0
	update_area()
	while(instance==Drone_Order && z==exit.z && viewable(src,exit,15) && steps<100)
		steps++
		Target=null
		Fly()
		drone_step(exit,ignore_master=1)
		if(get_dist(src,exit)<=1) Bump(exit)
		sleep(3)
	update_area()
	var/area/a=get_area()
	steps=0
	while(instance==Drone_Order && steps<100 && a.type!=/area/ship_area)
		steps++
		Fly()
		var/turf/t=get_step(src,pick(NORTH,SOUTH,EAST,WEST,NORTHEAST,NORTHWEST,SOUTHEAST,SOUTHWEST))
		if(t && t.FlyOverAble)
			var/obstructed
			for(var/atom/o in t) if(isobj(o) || ismob(o)) obstructed=1
			SafeTeleport(t)
			if(!obstructed) break
		sleep(1)
	Land()
	Drone_self_repair()

mob/proc/Drone_get_in_ship(mob/master,obj/Ships/Ship/ship)
	if(!z || !ship || ship.z!=z || !master) return
	if(master) Pkey=master.key
	Drone_Order++
	Target=null
	var/instance=Drone_Order
	var/steps=0
	update_area()
	while(instance==Drone_Order && ship && z==ship.z && viewable(src,ship,15) && steps<100)
		steps++
		Target=null
		Fly()
		drone_step(ship,ignore_master=1)
		if(get_dist(src,ship)<=1) Bump(ship)
		sleep(3)
	update_area()
	var/area/a=get_area()
	steps=0
	while(instance==Drone_Order && steps<100 && a.type==/area/ship_area)
		steps++
		Fly()
		var/turf/t=get_step(src,pick(NORTH,SOUTH,EAST,WEST,NORTHEAST,NORTHWEST,SOUTHEAST,SOUTHWEST))
		if(t && t.FlyOverAble)
			var/obstructed
			for(var/atom/o in t) if(isobj(o) || ismob(o)) obstructed=1
			SafeTeleport(t)
			if(!obstructed) break
		sleep(1)
	Land()
	Drone_self_repair()

mob/proc/Drone_Assemble(turf/T,mob/P)
	if(!z||T.z!=z) return
	if(P) Pkey=P.key
	Drone_Order+=1
	Target=null
	var/Instance=Drone_Order
	while(T.z==z&&(getdist(src,T)>5||!viewable(src,T))&&Instance==Drone_Order)
		Target=null
		drone_step(T,ignore_master=1)
		sleep(1)
	Land()
	Drone_self_repair()

proc/Online_by_Key(K) for(var/mob/P in players) if(P.key==K) return 1

proc/Get_by_key(K) for(var/mob/P in players) if(P.key==K) return P

mob/proc/Collect_Resources(Max,mob/P)
	if(!z || client) return
	if(P) Pkey=P.key
	Drone_Order+=1
	var/Instance=Drone_Order
	var/obj/Module/Drone_AI/D=Get_Drone_AI()
	if(!D) return
	D.Commands.Remove("Gather","Steal","Genocide","Assemble","Patrol")
	if(!("Gather" in D.Commands)) D.Commands+="Gather"
	while(src&&D&&D.loc==src&&D.suffix&&("Gather" in D.Commands)&&Instance==Drone_Order)
		Drone_self_repair()
		if(!z) return
		Target=null
		if(!P&&Online_by_Key(Pkey)) P=Get_by_key(Pkey)
		if(P&&P.locz()==z&&P.get_area()==get_area()&&Res()>=Max)
			P=Get_by_key(Pkey)
			Say("Objective to collect [Commas(Max)]$ completed. Returning to [P]")
			while(P&&P.locz()==z&&Instance==Drone_Order&&P.get_area()==get_area()&&(getdist(src,P.base_loc())>4||!(P in player_range(4,src)))&&("Gather" in D.Commands))
				drone_step(P,ignore_master=1)
				sleep(1)
			if(P&&getdist(src,P.base_loc())<=4&&(P in player_range(4,src)))
				Say("Objective completed")
				player_view(15,src)<<"[src] drops [Commas(Res())]$"
				var/obj/Resources/R = GetCachedObject(/obj/Resources, Get_step(src,dir))
				R.name="[Commas(Res())]$"
				R.Value=Res()
				Alter_Res(-Res())
				sleep(50)
		else
			var/list/Stealables
			for(var/obj/Resources/R in resources_list) if(R.z==z&&R.get_area()==get_area())
				if(!Stealables) Stealables=new/list
				if(Stealables.len<10) Stealables+=R
			var/area/a=get_area()
			if(a) for(var/mob/Enemy/M in a.npc_list) if(M.z==z)
				if(!Stealables) Stealables=new/list
				if(Stealables.len<20) Stealables+=M
			if(Stealables)
				var/mob/M=pick(Stealables)
				var/Steps=500
				Fly()
				while(M&&M.z==z&&Steps&&Instance==Drone_Order&&getdist(M,src)>1&&("Gather" in D.Commands))
					Steps--
					drone_step(M,ignore_master=1)
					sleep(1)
				Land()
				if(Instance==Drone_Order&&M&&M.z==z&&getdist(M,src)<=1)
					if(istype(M,/obj/Resources))
						player_view(15,src)<<"[src] picks up [M]"
						var/obj/Resources/Resources=M
						Alter_Res(Resources.Value)
						del(M)
					if(ismob(M))
						Drone_Attack(M,lethal=1)
						sleep(20)
						Vaccuum_resources()
		sleep(rand(40,60))

mob/proc/Vaccuum_resources(display_message=1)
	player_view(15,src)<<"[src] sucks up all the resource bags"
	for(var/obj/Resources/R in view(8,src))
		while(R&&R.loc!=loc&&R.z)
			step_towards(R,src)
			if(R.loc==loc)
				Alter_Res(R.Value)
				del(R)
			sleep(3)

var/drone_res_steal_amount=333333

mob/proc/Steal_Resources(Max,mob/P)
	if(!z || client) return
	if(P) Pkey=P.key
	Drone_Order+=1
	var/Instance=Drone_Order
	var/obj/Module/Drone_AI/D=Get_Drone_AI()
	if(!D) return
	D.Commands.Remove("Gather","Steal","Genocide","Assemble","Patrol")
	if(!("Steal" in D.Commands)) D.Commands+="Steal"
	while(src&&D&&D.loc==src&&D.suffix&&("Steal" in D.Commands)&&Instance==Drone_Order)
		Drone_self_repair()
		if(!z) return
		Target=null
		if(!P&&Online_by_Key(Pkey)) P=Get_by_key(Pkey)
		if(P&&P.locz()==z&&P.get_area()==get_area()&&Res()>=Max)
			P=Get_by_key(Pkey)
			Say("Objective to collect [Commas(Max)]$ completed. Returning to [P]")
			while(P&&P.locz()==z&&!(P in player_range(4,src))&&("Steal" in D.Commands)&&Instance==Drone_Order)
				drone_step(P,ignore_master=1)
				sleep(1)
			if(P in player_range(4,src))
				Say("Objective completed")
				player_view(15,src)<<"[src] drops [Commas(Res())]$"
				var/obj/Resources/R = GetCachedObject(/obj/Resources, Get_step(src,dir))
				R.name="[Commas(Res())]$"
				R.Value=Res()
				Alter_Res(-Res())
		else
			var/list/Stealables
			for(var/obj/Drill/DD in drills) if(DD.z==z&&DD.Builder!=Pkey&&DD.get_area()==get_area())
				if(!Stealables) Stealables=new/list
				if(Stealables.len<10) Stealables+=DD
			var/area/a=get_area()
			if(a) for(var/mob/M in a.player_list) if(M.locz()==z&&M.Res()>=drone_res_steal_amount*Resource_Multiplier&&!Is_drone_master(M)&&get_area()==M.get_area())
				if(!M.tournament_override(fighters_can=0,show_message=0))
					if(BP>M.BP*0.65) //dont fight someone too far beyond them to avoid losing
						if(!Stealables) Stealables=new/list
						if(Stealables.len<20) Stealables+=M
			if(Stealables)
				var/mob/M=pick(Stealables)
				var/Steps=500
				Fly()
				var/Dist=2
				if(isobj(M)) Dist=1
				while(M && M.locz()==z && Steps && !viewable(src,M,Dist) && ("Steal" in D.Commands) && \
				Instance==Drone_Order && (!ismob(M) || M.get_area()==get_area()))
					Steps--
					drone_step(M,ignore_master=1)
					sleep(1)
				Land()
				if(Instance==Drone_Order)
					if(istype(M,/obj/Drill)&&getdist(src,M)<=5&&viewable(src,M))
						player_view(15,src)<<"[src] steals the money from [M]"
						var/obj/Drill/Drill=M
						Alter_Res(Drill.Resources)
						Drill.Resources=0
						del(Drill)
						Vaccuum_resources(display_message=0)
					else if(ismob(M)&&M.Res()>=drone_res_steal_amount*Resource_Multiplier&&getdist(src,M.base_loc())<=5&&viewable(src,M)&&("Steal" in D.Commands)&&!Master_is_near()&&!Is_drone_master(M))
						var/Timer=7
						var/res_amount=M.Res()
						Say("[M]. Do not attempt to run. Drop your resources. We will take them in the name of [Get_by_key(Pkey)].\
						 If you \
						attempt to run, you will be destroyed. You have [Timer] seconds to comply.")
						while(Timer&&M&&M.Res()>1&&(M in player_view(8,src))&&("Steal" in D.Commands))
							Timer--
							sleep(10)
						if(M&&("Steal" in D.Commands))
							if(!Timer)
								Say("Time is up. Taking [M]'s resources by force.")
								Drone_Attack(M)
								sleep(10)
								Drone_steal_from_player(M)
							else
								var/res_bag_found
								for(var/obj/Resources/r in view(8,src)) if(r.Value>=res_amount*0.9)
									res_bag_found=1
									break
								if(M.Res()<=0&&res_bag_found)
									Vaccuum_resources()
									Say("[M] has complied. Objective complete. Moving to next objective...")
								else if(!res_bag_found&&("Steal" in D.Commands))
									Say("[M] has refused to comply. Exterminating.")
									Drone_Attack(M)
									Drone_steal_from_player(M)
								else if(!M.KO&&!(M in player_view(8,src))&&("Steal" in D.Commands))
									Say("[M] has attempted to run. Exterminating.")
									Drone_Attack(M)
									Drone_steal_from_player(M)
								Detect_Illegal_Activity()
		sleep(rand(40,60))

mob/proc/Drone_steal_from_player(mob/m)
	if(m.KO && m.locz()==z)
		var/turf/t=Get_step(m.base_loc(),src)
		if(!t||!isturf(t)) return
		SafeTeleport(t)
		dir=get_dir(src,m.base_loc())
		sleep(10)
		player_view(15,src)<<"[src] steals [Commas(m.Res())] resources from [m]!"
		Alter_Res(m.Res())
		m.Alter_Res(-m.Res())

mob/var/Race_to_Genocide

mob/proc/Binded_at_bind_spawn()
	if(z != bind_spawn.z) return
	for(var/obj/Curse/c in bind_objects)
		if(c.loc == src)
			if(getdist(src, bind_spawn) <= 20) return 1

mob/proc/Drone_Genocide(R,mob/P) //R=Race to kill
	if(!z) return
	if(P) Pkey=P.key
	Race_to_Genocide=R
	Drone_Order+=1
	var/Instance=Drone_Order
	var/obj/Module/Drone_AI/D=Get_Drone_AI()
	if(!D) return
	D.Commands.Remove("Gather","Steal","Genocide","Assemble","Patrol")
	if(!("Genocide" in D.Commands)) D.Commands+="Genocide"
	while(src&&D&&D.loc==src&&D.suffix&&("Genocide" in D.Commands)&&Instance==Drone_Order)
		Drone_self_repair()
		if(!z) return
		Target=null
		var/list/Mobs=new
		for(var/mob/M in player_view(500,src)) if(!Is_drone_master(M)&&!M.tournament_override(fighters_can=0,show_message=0))
			if(M.get_area()==get_area()&&!M.Binded_at_bind_spawn())
				if(M.locz()==z&&(M.Race==Race_to_Genocide||!Race_to_Genocide)&&(!M.Dead||M.locz()!=5)) Mobs+=M
				if(M.locz()==z&&Race_to_Genocide=="Vampires"&&M.Vampire&&(!M.Dead||M.locz()!=5)) Mobs+=M
				if(alignment_on && M.locz()==z && (!M.Dead || M.locz()!=5))
					if(Race_to_Genocide=="Good People" && M.alignment=="Good") Mobs+=M
					else if(Race_to_Genocide=="Evil People" && M.alignment=="Evil") Mobs+=M
		if(Race_to_Genocide=="Zombies")
			var/area/a=get_area()
			if(a) for(var/mob/M in a.npc_list) if(istype(M,/mob/Enemy/Zombie)&&M.locz()==z) Mobs+=M
		if(Mobs.len)
			var/mob/M=pick(Mobs)
			var/Steps=500
			Fly()
			while(M&&M.locz()==z&&Steps&&(getdist(src,M.base_loc())>5||!viewable(src,M))&&Instance==Drone_Order&&M.get_area()==get_area())
				Steps--
				drone_step(M,ignore_master=1)
				sleep(1)
			Land()
			if(Instance==Drone_Order) if(ismob(M)&&M.locz()==z&&getdist(src,M.base_loc())<=8&&viewable(src,M)&&!Is_drone_master(M))
				if(M.client)
					if(Race_to_Genocide=="Vampires") Say("Vampires have been listed for extermination. Prepare to be exterminated [M]")
					else if(Race_to_Genocide in list("Good People","Evil People"))
						Say("Those with [lowertext(M.alignment)] energy have been listed for extermination. Prepare to be exterminated [M]")
					else
						Say("[M] your species has been listed for extermination. Prepare to be exterminated.")
					sleep(20)
				Drone_Attack(M,lethal=1)
			Detect_Illegal_Activity()

		if(drone_genocide_off) Cancel_Orders()

		sleep(rand(40,60))

mob/proc/Get_Drone_AI()
	if(drone_module && drone_module.suffix) return drone_module
	for(var/obj/Module/Drone_AI/M in src) if(M.suffix)
		drone_module=M
		return M

mob/proc/Drone_Patrol(mob/PP)
	if(!z) return
	if(PP) Pkey=PP.key
	Drone_Order+=1
	var/Instance=Drone_Order
	var/obj/Module/Drone_AI/D=Get_Drone_AI()
	if(!D) return
	if(!("Patrol" in D.Commands)) D.Commands+="Patrol"

	var/list/drone_info
	if(drone_module&&(drone_module.Password in drone_instructions)) drone_info=drone_instructions[drone_module.Password]
	if(!drone_info) return

	while(src&&D&&D.loc==src&&D.suffix&&("Patrol" in D.Commands)&&Instance==Drone_Order)
		Drone_self_repair()
		if(!z) return
		Target=null
		var/list/Mobs=new
		for(var/mob/m in Players_at_Z(z))
			if(m.get_area()==get_area()&&!Is_drone_master(m)&&!m.tournament_override(fighters_can=0,show_message=0)) Mobs+=m

		//kill enemy drones
		if("Enemy Drones" in drone_info["illegals"])
			for(var/obj/o in drone_list) if(o.Password!=drone_module.Password&&ismob(o.loc))
				var/mob/m=o.loc
				if(m.z==z&&m.get_area()==get_area()) Mobs+=m

		if(Mobs.len)
			Fly()
			var/mob/P=pick(Mobs)
			var/Steps=500
			var/range=5
			while(Instance==Drone_Order&&P&&P.locz()==z&&Steps&&P.get_area()==get_area()&&(getdist(src,P.base_loc())>range||!viewable(src,P)))
				Steps--
				drone_step(P,ignore_master = 1)
				if(prob(6)) Detect_Illegal_Activity()
				sleep(1)
			Land()
			Say("SCANNING FOR ILLEGAL ACTIVITY")
			sleep(5)
			Detect_Illegal_Activity()
		if(!Illegal_Activity_Bypass())
			for(var/i in 1 to 10)
				if(locate(/mob) in player_view(10,src)) sleep(30)
				else break
			if(src) Detect_Illegal_Activity()
		sleep(rand(40,60))

mob/proc/Cancel_Orders(mob/P)
	if(!z) return
	if(P) Pkey=P.key
	if(drone_module) drone_module.Commands=new/list
	Target=null
	Drone_Order++

mob/proc/Get_max_cyber_bp_upgrade(race)
	var/n = Knowledge * (Intelligence()**0.1) * cyber_bp_mod
	if(race=="Android") n *= android_extra_cyber_bp_mult

	//special ss1 era boost
	for(var/client/c in clients)
		var/mob/m = c.mob
		if(m && m.ssj >= 1)
			n += 15000000
			break

	var/rt_mult=1
	for(var/obj/items/Robotics_Tools/rt in src) if(rt.Upgrade_Power>rt_mult) rt_mult = rt.Upgrade_Power
	n *= rt_mult
	return n * 1.1

mob/proc/Drone_Options(obj/Cybernetics_Computer/R) while(src&&R)
	if(!R.Password) R.Password=input(src,"You must set a frequency on your [R] so that it can command drones \
	which are on the same frequency. Please set it now.") as text
	var/list/Options=list("Cancel","Cancel All Orders","Guide","Mass Upgrade","Enter nearby ship","Exit ship","Kill List","Self Destruct",\
	"Gather Resources","Steal from Players/Drills","Genocide","Patrol","Assemble","Bring someone to you",\
	"Declare something illegal","Declare something legal","Show drone locations","Observe drones","Check drone resources")
	if(!Drones_On_Frequency(R.Password))
		src<<"There are no drones on frequency [R.Password]. Make one on frequency [R.Password] and then you will be \
		able to access drone options."
		return
	if(!(R.Password in drone_instructions)) drone_instructions[R.Password]=list("kill list"=new/list,"illegals"=new/list)
	switch(input(src,"Drone Commands: What do you want to command drones to do?") in Options)
		if("Cancel") return
		if("Guide") Drone_Guide()
		if("Mass Upgrade")
			var/res_cost=2000000 / Intelligence()**0.2
			if(Res()<res_cost)
				alert("You need [Commas(res_cost)] resources to do this")
			else
				switch(alert(src,"Mass upgrade all drone's BP for [Commas(res_cost)] resources? The BP upgrade will be more if you have \
				upgraded robotics tools in your items.","Options","Yes","No"))
					if("Yes")

						if(Res()<res_cost) alert(src,"You need [Commas(res_cost)] resources to do this")
						else
							Alter_Res(-res_cost)

							var/bp_upgrade=Get_max_cyber_bp_upgrade()
							var/relative_base=base_bp/bp_mod
							var/relative_hbtc=hbtc_bp/bp_mod

							for(var/obj/o in drone_list) if(ismob(o.loc) && o.Password==R.Password)
								var/mob/m=o.loc
								var/adj_cyber_bp=bp_upgrade
								if(m.Race=="Android") adj_cyber_bp*=android_extra_cyber_bp_mult
								if(m.cyber_bp<adj_cyber_bp) m.cyber_bp=adj_cyber_bp
								if(m.base_bp/m.bp_mod<relative_base) m.base_bp=relative_base*m.bp_mod
								if(m.hbtc_bp/m.bp_mod<relative_hbtc) m.hbtc_bp=relative_hbtc*m.bp_mod

							alert(src,"All drones have now been upgraded to have the maximum amount of cyber bp that you can grant")
		if("Check drone resources")
			src<<"This is the total amount of resources your drones are carrying on each planet"
			var/res_total=0
			for(var/area/a in all_areas)
				var/res_count=0
				for(var/obj/o in drone_list) if(ismob(o.loc)&&o.Password==R.Password)
					var/mob/m=o.loc
					if(m.get_area()==a) res_count+=m.Res()
				if(res_count)
					res_total+=res_count
					src<<"Drones have [Commas(res_count)] resources on [a]"
			src<<"All drones together have [Commas(res_total)] resources"
		if("Observe drones")
			var/stopped
			while(src&&!stopped)
				var/list/l
				var/drone_count=0
				for(var/obj/Module/Drone_AI/ai in drone_list) if(ai.Password==R.Password&&ismob(ai.loc))
					var/mob/m=ai.loc
					if(m.z)
						if(!l) l=new/list
						l+=m
						drone_count++
						if(client) client.eye=m
						switch(alert(src,"You are observing drone #[drone_count] on [m.get_area()] (location [m.x],[m.y],[m.z])","Options","Next","Stop"))
							if("Stop")
								if(client) client.eye=src
								stopped=1
								break
				if(!l)
					src<<"You have no drones out right now. Perhaps they were all destroyed."
					break
		if("Show drone locations")
			var/total=0
			for(var/area/a in all_areas)
				var/n=0
				for(var/obj/o in drone_list) if(ismob(o.loc)&&o.Password==R.Password)
					var/mob/m=o.loc
					if(m.z&&m.get_area()==a)
						n++
						total++
				if(n) src<<"[n] drones on [a]"
			if(total) src<<"Total drones: [total]"
			else src<<"You have no drones out right now"
		if("Bring someone to you")
			var/list/L=Choosable_Drones("Which drone(s) do you want to order to bring someone to you?",R.Password)
			var/list/Mobs=list("Cancel")
			for(var/mob/P in players) Mobs+=P
			var/mob/P=input(src,"Choose who the drone(s) will bring to you. They will track the person down, grab them, \
			and bring them back to you.") in Mobs
			if(!P||P=="Cancel") return
			for(var/mob/M in L) spawn if(M)
				M.Cancel_Orders(src)
				M.Say("Order Recieved. Commencing capture of [P]")
				M.Drone_Retrieve(P,src)

		if("Exit ship")
			var/obj/Ship_exit/exit
			for(exit in ship_exits) if(exit.z==z && viewable(src,exit,15)) break
			if(!exit)
				src<<"There is no exit in sight of you that is close enough"
			else
				var/list/drones=Get_Drones(mob_view(100,src),R.Password)
				if(!drones.len)
					src<<"There are no drones in sight owned by you"
				else
					for(var/mob/drone in drones)
						drone.Cancel_Orders(src)
						spawn if(drone) drone.Drone_exit_ship(src,exit)

		if("Enter nearby ship")

			var/obj/Ships/Ship/ship
			for(ship in ships) if(ship.z==z && viewable(src,ship,15)) break
			if(!ship)
				src<<"There is no ship in sight that is close enough for the drones to go into"
			else
				var/list/drones=Get_Drones(mob_view(15,src),R.Password)
				if(!drones.len)
					src<<"There are no drones in sight owned by you. Perhaps order them to assemble first."
				else
					for(var/mob/drone in drones)
						drone.Cancel_Orders(src)
						spawn if(drone) drone.Drone_get_in_ship(src,ship)

		if("Assemble")
			var/list/L=Choosable_Drones("Which drones do you want to assemble at your location?",R.Password)
			var/turf/T=loc
			for(var/mob/P in L) spawn if(P)
				P.Cancel_Orders(src)
				P.Say("Order Recieved. Assembling at location [T.x],[T.y],[T.z]")
				P.Drone_Assemble(T,src)
		if("Patrol")
			if(alignment_on&&alignment=="Good")
				alert(src,"Only evil people can command drones to do evil things")
			else
				var/list/L=Choosable_Drones("Which drones do you want to send on patrol? This will cause them to locate \
				life forms on the planet, and go check out what they are doing. This is a good way for drones to spot \
				illegal activities and such.",R.Password)
				for(var/mob/P in L) spawn if(P)
					P.Cancel_Orders(src)
					P.Say("Commencing Patrol")
					P.Drone_Patrol(src)
		if("Cancel All Orders")
			var/list/L=Choosable_Drones("Which drones will have their orders cancelled? This will just make them \
			stop trying to accomplish their current goal, and just stay where they are, doing nothing.",R.Password)
			for(var/mob/P in L) spawn if(P)
				P.Say("Stand-down orders recieved.")
				P.Cancel_Orders(src)
		if("Kill List")
			if(alignment_on&&alignment=="Good")
				alert(src,"Only evil people can command drones to do evil things")
			else

				var/list/drone_info=drone_instructions[R.Password]
				if(!drone_info)
					src<<"No drone instructions were found for this frequency"
					return

				switch(input(src,"Do you want to add or remove a person from the Kill List?") in list("Cancel","Add","Remove"))
					if("Cancel") break
					if("Add")
						while(src)
							var/list/Mobs=list("Cancel")
							for(var/mob/P in players) if(P.key&&!(P.key in drone_info["kill list"])) Mobs+=P.key
							var/mob/M=input(src,"Who do you want to add to the kill list?") in Mobs
							if(M!="Cancel") M=Get_by_key(M)
							if(M=="Cancel"||!M) break
							else
								src<<"[M.key] added to the kill list"
								drone_info["kill list"]+=M.key
								drone_instructions[R.Password]=drone_info
				if("Remove")
					while(src)
						var/list/Mobs=list("Cancel")
						for(var/P in drone_info["kill list"]) Mobs+=P
						var/M=input(src,"Who's key do you want to remove from the kill list?") in Mobs
						if(M=="Cancel"||!M) break
						else
							src<<"[M] removed from kill list"
							drone_info["kill list"]-=M
							drone_instructions[R.Password]=drone_info
		if("Declare something illegal")
			if(alignment_on&&alignment=="Good")
				alert(src,"Only evil people can command drones to do evil things")
			else

				var/list/drone_info=drone_instructions[R.Password]
				if(!drone_info)
					src<<"No drone instructions were found for this frequency"
					return

				while(src&&R)
					var/list/L=list("Cancel")
					if(!("Enemy Drones" in drone_info["illegals"])) L+="Enemy Drones"
					if(!("Doors" in drone_info["illegals"])) L+="Doors"
					if(!("Training" in drone_info["illegals"])) L+="Training"
					if(!("Meditating" in drone_info["illegals"])) L+="Meditating"
					if(!("Combat" in drone_info["illegals"])) L+="Combat"
					if(!("Ki Use" in drone_info["illegals"])) L+="Ki Use"
					if(!("Ships/Pods" in drone_info["illegals"])) L+="Ships/Pods"
					if(!("Turrets" in drone_info["illegals"])) L+="Turrets"
					for(var/obj/O) if(!(locate(O.type) in L)&&!(locate(O.type) in drone_info["illegals"])) if(O.Cost)
						if(!istype(O,/obj/Turret)) L+=new O.type
					var/obj/A=input(src,"What do you want to make illegal? This will be stored in the [R] hard drive. \
					Drones set to the same frequency will use this data to decide what is illegal \
					or not.") in L
					if(!A||A=="Cancel") break
					else
						if(isobj(A)) drone_info["illegals"]+=new A.type
						else drone_info["illegals"]+=A
						drone_instructions[R.Password]=drone_info
		if("Declare something legal")

			var/list/drone_info=drone_instructions[R.Password]
			if(!drone_info)
				src<<"No drone instructions were found for this frequency"
				return

			var/Something
			for(Something in drone_info["illegals"]) break
			if(!Something)
				src<<"Something must first be declared illegal before it can be made legal again."
			else
				while(src&&R)
					var/list/L=list("Cancel")
					for(var/A in drone_info["illegals"]) L+=A
					var/A=input(src,"What do you want to remove from the illegal activities list? Drones will no longer \
					go after people doing these activities if you remove this from the illegal list") \
					in L
					if(!A||A=="Cancel") break
					else
						drone_info["illegals"]-=A
						drone_instructions[R.Password]=drone_info
		if("Genocide")
			if(drone_genocide_off)
				alert(src,"This server has drone genocide off")
			else if(alignment_on&&alignment=="Good")
				alert(src,"Only evil people can command drones to do evil things")
			else
				var/list/L=Choosable_Drones("Drone Genocide Options",R.Password)
				var/list/O=list("Cancel","All Races","Vampires","Zombies")
				if(alignment_on) O.Add("Evil People","Good People")
				for(var/A in Race_List()) O+=A
				var/Race_to_kill=input(src,"Which race do you want the drone to kill?") in O
				if(Race_to_kill=="Cancel") return
				var/Msg="Drones set to kill all [Race_to_kill]s"
				if(Race_to_kill=="All Races")
					Msg="Drones set to kill all life forms"
					Race_to_kill=null
				src<<Msg
				for(var/mob/P in L) spawn if(P)
					P.Cancel_Orders(src)
					P.Say(Msg)
					P.Drone_Genocide(Race_to_kill,src)
		if("Self Destruct")
			var/list/L=Choosable_Drones("Drone Self Destruct Options",R.Password)
			var/drone_count=0
			for(var/mob/d in L) if(d.z) drone_count++
			src<<"Self destruct signal sent to [drone_count] Drones"
			spawn for(var/mob/P in L)
				spawn if(P&&P.z) P.Drone_Self_Destruct()
				sleep(4)
		if("Gather Resources")
			var/list/L=Choosable_Drones("Which drones will be set to gather resources?",R.Password)
			var/Max=input(src,"How many resources should each drone gather before returning to you?") as num
			for(var/mob/P in L) spawn if(P)
				P.Cancel_Orders(src)
				P.Say("Order recieved. Gathering resources.")
				P.Collect_Resources(Max,src)
		if("Steal from Players/Drills")
			if(alignment_on&&alignment=="Good")
				alert(src,"Only evil people can command drones to do evil things")
			else
				var/list/L=Choosable_Drones("Which drones will be set to steal resources from players/drills?",R.Password)
				var/Max=input(src,"How many resources should each drone gather before returning to you?") as num
				for(var/mob/P in L) spawn if(P)
					P.Cancel_Orders(src)
					P.Say("Order recieved. Taking resources from drills and players.")
					P.Steal_Resources(Max,src)

mob/proc/Drone_Self_Destruct()
	Disable_Modules()
	Death("drone self destruct signal",drone_sd=1)

mob/proc/Choosable_Drones(M="Drone Options",F)
	var/list/L
	switch(input(src,"[M]") in list("Cancel","In front of you","All in view","All on this planet","All Drones"))
		if("Cancel") return
		if("In front of you") L=Get_Drones(Get_step(src,dir),F)
		if("All in view") L=Get_Drones(mob_view(15,src),F)
		if("All on this planet")
			for(var/obj/o in drone_list) if(o.Password==F && ismob(o.loc))
				var/mob/m=o.loc
				if(m.get_area()==get_area())
					if(!L) L=new/list
					L+=m
		if("All Drones") L=Get_Drones(null,F)
	return L

proc/Mob_Count(list/L)
	var/Amount=0
	for(var/mob/P in L) Amount+=1
	return Amount
mob/proc/Drone_Frequency()
	if(!drone_module) for(var/obj/Module/Drone_AI/ai in src) if(ai.suffix)
		drone_module=ai
		return ai.Password
	if(drone_module&&drone_module.suffix) return drone_module.Password
	for(var/obj/Module/Drone_AI/M in active_modules) if(M.suffix) return M.Password
mob/proc/Drones_On_Frequency(F) for(var/obj/Module/Drone_AI/M in drone_list) if(M.suffix&&M.Password==F) return 1
proc/Get_Drones(list/L,F)
	var/list/Drones=new
	if(!L) for(var/obj/Module/Drone_AI/ai in drone_list) if(ai.Password==F&&ismob(ai.loc))
		var/mob/m=ai.loc
		Drones+=m
	if(L) for(var/mob/P in L) if(P.Drone_Frequency()&&P.Drone_Frequency()==F) Drones+=P
	return Drones
mob/proc/Drone_Guide() src<<browse(Drone_Guide,"window= ;size=700x600")
var/Drone_Guide={"<html><head><body><body bgcolor="#000000"><font size=3><font color="#CCCCCC">

This guide will tell you what does what with drones.<p>

Drones are anything that has a Drone AI cybernetic module installed in them. The Drone AI module allows them
to recieve orders. Drone AI modules must be set to the same frequency as your Robotics Tools and/or your
Cybernetic Computer, that way the Robotics Tools and Cybernetic Computer can send signals to your Drone, and
vice versa.<p>

If you have a robotics tools or door key with the same password/frequency the drone uses, the drone will
consider you its master and not murder you if you do illegal stuff. You will be immune to the drone's laws.

Here are the commands that you can send from your Robotics Tools and/or Cybernetic Computer, to any Drone that
has a Drone AI module installed with a matching frequency:<p>

Some of these orders will overwrite previous orders you have sent to your drone(s). For instance, if you
previously told them to gather resources, but then you give them an order for genocide, they will
stop gathering resources and carry out the genocide order. After the genocide order is complete, they will
NOT resume gathering resources, unless you tell them to again.<p>

Cancel All Orders: This will clear any command you have previously sent to your Drone(s). They will simply
stop moving, awaiting orders.<p>

Kill List: This option lets you add or remove a person from the kill list. The kill list is stored in your
Cybernetic Computer's hard drive. Robotics Tools can also alter your Cybernetic Computer's kill list if you have
them both set to the same frequency. Drones must also be set to the same frequency as the Cybernetic Computer
or they will not be able to access the kill list.<p>

Self Destruct: Order the drone to self destruct, killing the drone.<p>

Gather Resources: The drone will being gathering resources from NPCs, and from bags just laying on the ground.
On this setting they will not steal resources from players or drills. After they have gathered an amount set
by you, the will bring it to you.<p>

Steal from Players/Drills: The drone(s) will mug players and take resources from drills. After they have
gathered an amount set by you, they will bring it to you.<p>

Genocide: Tell the drone(s) to kill all life forms of a specific race, or all races.<p>

Patrol: Tell drone(s) to go around to random people on the planet and see what they are doing. This is probably
only useful when you have set things to be illegal. That way when the patrolling drones go to someone, they
may find them doing something illegal, and they will then enforce the laws you have set.<p>

Assemble: Tell drone(s) to meet at your location.<p>

Bring someone to you: Tell drone(s) to bring a player of your choosing to your location. They will grab the
person and carry them to you. If the person resists they will knock them out, but not kill them.<p>

"}
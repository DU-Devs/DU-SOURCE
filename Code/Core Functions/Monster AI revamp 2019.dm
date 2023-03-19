mob/proc/Activate_NPCs_Loop()
	set waitfor=0
	var/turf/former_loc=loc
	while(src)
		if(former_loc!=loc&&client&&client.inactivity<300) Activate_NPCs()
		former_loc=loc
		sleep(20)

mob/proc/Activate_NPCs(Distance = 33)
	set waitfor=0
	if(current_area) for(var/mob/Enemy/M in current_area.npc_list)
		if(!M.NPC_Activated&&M.z==z&&getdist(src,M)<Distance)
			M.Activate_NPC()
			if(prob(30)) sleep(1)

mob/var/tmp/NPC_Activated

var/list/Inactive_NPCs=new

mob/proc/Activate_NPC(Timer=300)
	set waitfor=0
	if(!z) return
	if(src&&!NPC_Activated&&z)
		if(istype(src,/mob/Enemy/Zombie)) Timer = 1 * 600
		NPC_Activated=1
		Inactive_NPCs-=src
		Inactive_NPCs=remove_nulls(Inactive_NPCs)
		NpcRoam(Timer)
		Find_Target(Timer)
		//Power_Increase_Loop(Timer)
		//NPC_Heal_Loop(Timer)
		sleep(Timer)
		if(src)
			NPC_Activated=0
			Inactive_NPCs+=src

mob/var/tmp
	npcRoamRunning
	attackTargetLoopRunning

mob/proc/NpcRoam(timer = 600, delay)
	set waitfor=0
	if(!z || npcRoamRunning) return
	npcRoamRunning = 1
	if(!delay) delay = world.tick_lag
	if(!KO) dir = pick(NORTH, SOUTH, EAST, WEST, NORTHWEST, NORTHEAST, SOUTHWEST, SOUTHEAST)
	Land()
	if(!KO && enemyCanFly && !Flying) Fly()
	for(var/i in 0 to round(timer / delay))
		if(!Target && !KB)
			if(enemyCanFly && !KO && On_Water(src) && !Flying) Fly()
			if(icon_state == "Sleep") icon_state = "" //cat npcs
			var/success
			if(!KB) success = step(src, dir)
			if(prob(0.5) || !success)
				dir = pick(turn(dir, 45), turn(dir, -45))
				//sometimes just stop, and stand still, for realism
				if(prob(50) && success) sleep(rand(40,80))
		if(!z)
			npcRoamRunning = 0
			return
		sleep(delay)
	npcRoamRunning = 0

mob/proc/Find_Target(Timer=600,Delay=20)
	set waitfor=0
	if(!z) return
	if(Docile) return
	for(var/I in 0 to round(Timer/Delay))
		var/area/a = get_area()
		if(a)
			var/mob/m
			for(var/mob/m2 in a.player_list)
				if(m2.z==z&&getdist(src,m2)<25&&(!m||getdist(src,m2)<getdist(src,m)))
					//if(get_dir(src,P) in list(dir,turn(dir,45),turn(dir,-45)))
					if(!At_forward_half(m2) && m2 != Target) continue //no line of sight, npc doesnt see them
					if(!(m2 in unreachable_targets)) m=m2
			if(m) Attack_Target(m)
		if(!z) return
		sleep(Delay)

mob/var/tmp/list/unreachable_targets=new

mob/var/tmp
	npc_move_delay = 2
	pathfindUntil = 0
	npcTargetingRange = 20

mob/proc/Attack_Target(mob/P)
	set waitfor=0
	if(!z || attackTargetLoopRunning) return
	attackTargetLoopRunning = 1
	var/mob/Former_Target=Target
	if(P) Target=P
	if(Former_Target)
		attackTargetLoopRunning = 0
		return
	var/max_range = npcTargetingRange
	var/target_unreachable

	while(src && Target && !Target.KO && getdist(src,Target) <= max_range && viewable(a = src, b = Target, max_dist = max_range, seePastDenseObjs = 0))
		if(!z) break
		if(!KB)
			var/pixDist = bounds_dist(src, Target)
			//if(pixDist > 0)
			if(1)
				var/success
				//success = step_towards(src, Target)
				success = vector_step_toward(src, Target)
				//some basic tile snapping to enhance the unreliable other tile snapping systems
				//if(get_dir(src, Target) in list(EAST,WEST)) step_y -= Clamp(6, 0, step_y)
				//if(get_dir(src, Target) in list(NORTH,SOUTH)) step_x = Clamp(6, 0, step_x)
				dir = get_dir(src, Target)
				//NpcAlignToTile(dir) //in any directions the npc is not currently moving, align them to the tile as best as possible
				/*
				//regular stepping
				if(world.time > pathfindUntil)
					success = step_towards(src, Target)
					dir = get_dir(src, Target)
					if(!success)
						pathfindUntil = world.time + 100
						//dont enable pathfinding from obstacles which are mobs
						if(ismob(last_bumped_obj) && world.time - last_bump < 5)
							pathfindUntil = 0
				//pathfinding
				if(world.time < pathfindUntil)
					//success = g_step_to(Target) //im not even sure g_step_to returns a success or not
					success = step_to(src, Target, 0, step_size)
					view(10,src) << "pathfind step"
					if(!success)
						unreachable_targets += Target
						Remove_unreachable_target(Target, 300)
						target_unreachable = 1
						*/
			if(!KO && !KB && bounds_dist(src, Target) < 10)
				ResetStepXY()
				dir = get_dir(src, Target)
				Melee(Target)
			if(!Flying && !KO && (Target && (Target.Flying || On_Water(Target))) || On_Water(src))
				if(!KO && enemyCanFly)
					Fly()
			else if(!Target || (!Target.Flying && Flying)) Land()
			if(target_unreachable) Target = null
		sleep(world.tick_lag)
	Target = null
	if(Flying) Land()
	attackTargetLoopRunning = 0

mob/proc/Remove_unreachable_target(mob/m,timer=0)
	set waitfor=0
	sleep(timer)
	if(!m) return
	unreachable_targets-=m
	unreachable_targets=remove_nulls(unreachable_targets)

mob/proc/Power_Increase_Loop(Timer=600,Delay=100)
	set waitfor=0

	return //DISABLED!!!!!!!!!!

	if(!istype(src,/mob/Enemy/Zombie)) return

	for(var/I in 0 to round(Timer/Delay))
		if(!KO) for(var/mob/P in player_view(7,src)) if(P.client) Attack_Gain(1,P)
		sleep(Delay)

mob/proc/NPC_Heal_Loop(Timer=600,Delay=50)
	set waitfor=0
	for(var/I in 0 to round(Timer/Delay))
		if(Health<100)
			Health+=1*regen*(Delay/10)
			if(Health>100) Health=100
		if(Ki<max_ki) Ki=max_ki
		//BP=get_bp() //this has been resetting their bp to 1
		sleep(Delay)

proc/On_Water(mob/M)
	var/turf/T=M.base_loc()
	if(isturf(T)&&T.Water) return 1

proc/Surrounded(mob/M)
	for(var/turf/T in orange(1,M)) if(!(locate(/mob) in T)) return
	return 1





mob/Health=100
mob/var/Docile

mob/proc/Find_Location()
	var/turf/T=loc
	var/Found
	while(!Found)
		Found=1
		x+=rand(-40,40)
		y+=rand(-40,40)
		if(!z)
			Found=0
			SafeTeleport(T)
		var/turf/NewLoc=loc
		if(!NewLoc||!isturf(NewLoc)||NewLoc.density||NewLoc.Water || !viewable(src, T, 40))
			Found=0
			SafeTeleport(T)
	if(prob(50)) Find_Location()

var/NPC_Delay=1
var/NPC_Can_Respawn=1
var/NPC_Leave_Body=1
var/npcs_enabled=1

mob/Admin2/verb/Toggle_Npcs()
	set category="Admin"
	npcs_enabled=!npcs_enabled
	if(!npcs_enabled)
		src<<"NPCS DISABLED"
		disable_npcs()
	else src<<"NPCS ENABLED"

mob/var/tmp/perma_delete

proc/disable_npcs()
	NPC_Can_Respawn=0
	NPC_Leave_Body=0
	for(var/mob/Enemy/E) if(!istype(E,/mob/Enemy/Zombie)) if(E.z)
		if(prob(5)) sleep(1)
		E.perma_delete=1
		del(E)
	for(var/mob/Body/B) if(!B.displaykey) if(B.z)
		if(prob(5)) sleep(1)
		del(B)
	NPC_Leave_Body=1

mob/var
	Flying
	tmp
		last_bump = 0
		last_bumped_obj

mob/Enemy/var/tmp/last_npc_turf_attack=0

mob/var/Enlarged
mob/var/mob_creation_time=0

mob/New()
	if(!mob_creation_time) mob_creation_time=world.realtime
	Set_Spawn_Point(src)
	. = ..()

mob/proc/NewMobUpdateArea() //so we dont have to use spawn()
	set waitfor=0
	sleep(10)
	update_area()

mob
	proc/Add_resources()
		var/mob/Enemy/e=src
		var/obj/Resources/B = GetCachedObject(/obj/Resources, src)
		B.Value=round(rand(30000,60000)*bp_mod*e.npc_money_mod*Resource_Multiplier)
		B.Update_value()

	proc/Add_hbtc_key()

		if(world.time<5*600) return

		if(z==1)
			if(npcs_give_hbtc_keys)
				if(prob(1))
					give_hbtc_key()

	proc/New_npc_bp()
		set waitfor=0
		if(world.time < 600)
			sleep(600 - world.time)
		BP=0.5*Avg_BP*bp_mod
		if(BP < 1) BP = 1 //fixes bug
		BP*=rand(80,120)/100

mob/proc/Update_npc_stats()
	Str=Stat_Record*strmod/1.5
	End=Stat_Record*endmod/1.5
	Pow=Stat_Record*formod/1.5
	Res=Stat_Record*resmod/1.5
	Spd=Stat_Record*spdmod/1.5
	Off=Stat_Record*offmod/1.5
	Def=Stat_Record*defmod/1.5
	max_ki=2000*Eff
	Ki=max_ki

mob/Enemy/proc
	EnemyNew()
		set waitfor=0
		//control npc density
		if(!init && type != /mob/Enemy/Core_Demon && !prob(npcDensity * 100))
			sleep(rand(10, 600))
			perma_delete = 1
			del(src)
			return
		update_area()
		Inactive_NPCs+=src
		if(src&&z&&!istype(src,/mob/Enemy/Zombie))
			if(z==14)
				bp_mod*=2
				if(Enlargement_Chance<33) Enlargement_Chance=33
			if(prob(Enlargement_Chance))
				BP*=2
				bp_mod*=2
				//var/w=round(GetWidth(icon)*1.5 , 1)
				//var/h=round(GetHeight(icon)*1.5 , 1)
				//Enlarge_Icon(w,h)
				transform *= 1.5
				//pixel_y=0
				npc_move_delay *= 2
			Update_npc_stats()
		Add_resources()
		Add_hbtc_key()
		New_npc_bp()
		//spawn(rand(0,600)) Activate_NPC(600)
		init = 1

mob/var
	enemyCanFly = 1

mob/Enemy
	move=1
	Spawn_Timer=30
	max_ki=600 //multiplies by Eff of npc in New()
	Ki=600
	var
		init
		Enlargement_Chance=0
		npc_money_mod=1
	Has_DNA=0
	step_size = 10
	New()
		EnemyNew()
		step_size /= npc_move_delay
		step_size *= rand(85,115) / 100 //it looks really unnatural if all npcs of the same species move at the exact same speed
		. = ..()
	Del()
		if(NPC_Leave_Body) Leave_Body()
		. = ..()

	Puranto_Amphibian
		icon='NamekAmphibian.dmi'
		bp_mod = 1.5
		enemyCanFly = 0
		New()
			if(prob(0)) Docile = 1
			else Docile = 0
			Raise_Speed(15)
			Raise_Strength(20)
			Raise_Durability(0)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(20)
			Raise_Defense(0)
			npc_move_delay *= 2
			. = ..()

	Puranto_Dino
		icon='NamekDino.dmi'
		bp_mod = 3
		enemyCanFly = 0
		New()
			if(prob(100)) Docile = 1
			else Docile = 0
			Raise_Speed(0)
			Raise_Strength(0)
			Raise_Durability(55)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(0)
			Raise_Defense(0)
			npc_move_delay *= 4
			. = ..()

	Puranto_Frog
		icon='NamekFrog.dmi'
		bp_mod = 1
		enemyCanFly = 0
		New()
			if(prob(80)) Docile = 1
			else Docile = 0
			Raise_Speed(15)
			Raise_Strength(20)
			Raise_Durability(0)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(20)
			Raise_Defense(0)
			npc_move_delay *= 1
			. = ..()

	Bio_Monster
		icon='BioBroly.dmi'
		bp_mod = 3
		enemyCanFly = 0
		New()
			Docile = 0
			Raise_Speed(15)
			Raise_Strength(20)
			Raise_Durability(0)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(20)
			Raise_Defense(0)
			npc_move_delay *= 4
			. = ..()

	Eevee
		Race="Pokemon"
		icon='Eevee.dmi'
		bp_mod=1
		Docile = 1
		enemyCanFly = 0
		New()
			Raise_Speed(15)
			Raise_Strength(10)
			Raise_Durability(0)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(15)
			Raise_Defense(15)
			. = ..()

	Bear
		Race="Pokemon"
		icon='Bear.dmi'
		bp_mod=1.5
		enemyCanFly = 0
		New()
			CenterIcon(src)
			pixel_y = 0
			Docile = pick(0,1)
			Raise_Speed(15)
			Raise_Strength(10)
			Raise_Durability(0)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(15)
			Raise_Defense(15)
			npc_move_delay *= 1.6
			. = ..()

	Pupa_Cell
		Race="Abomination"
		icon='Pupa Cell.dmi'
		bp_mod=1.5
		New()
			Docile = 0
			Raise_Speed(15)
			Raise_Strength(10)
			Raise_Durability(0)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(15)
			Raise_Defense(15)
			. = ..()

	Core_Demon
		icon='KillasIconBlack.dmi'
		bp_mod=4.1
		npc_money_mod=8
		Spawn_Timer=0
		Enlargement_Chance=20
		npcTargetingRange = 999
		Del()
			update_area()
			for(var/mob/m in player_view(18,src))
				if(m.Health<100) m.Health=100
			. = ..()
		New()
			Raise_Speed(0)
			Raise_Strength(15)
			Raise_Durability(0)
			Raise_Force(0)
			Raise_Resist(5) //special high resistance or else ki users have too easy a time in the core
			Raise_Offense(18)
			Raise_Defense(0)
			npc_move_delay *= 1
			. = ..()
	Spider_Small
		icon='Spider Small.dmi'
		bp_mod=0.15
		enemyCanFly = 0
		New()
			Raise_Speed(15)
			Raise_Strength(20)
			Raise_Durability(0)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(20)
			Raise_Defense(0)
			npc_move_delay*=0.5
			. = ..()
	Squirrel
		icon='NPC Squirrel.dmi'
		Docile=1
		bp_mod=0.01
		enemyCanFly = 0
		New()
			Raise_Speed(21)
			Raise_Strength(0)
			Raise_Durability(0)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(17)
			Raise_Defense(17)
			. = ..()
	Jungle_Spider
		icon='Spider 3 2 2014.dmi'
		bp_mod=3
		Enlargement_Chance=33
		enemyCanFly = 0
		New()
			Raise_Speed(10)
			Raise_Strength(9)
			Raise_Durability(8)
			Raise_Force(0)
			Raise_Resist(8)
			Raise_Offense(10)
			Raise_Defense(10)
			npc_move_delay*=0.5
			CenterIcon(src)
			. = ..()
	Spider3
		icon='NPC Spider 3.dmi'
		bp_mod=2
		Enlargement_Chance=20
		enemyCanFly = 0
		New()
			Raise_Speed(15)
			Raise_Strength(15)
			Raise_Durability(5)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(10)
			Raise_Defense(10)
			. = ..()
	Spider2
		icon='NPC Spider 2.dmi'
		bp_mod=1
		Enlargement_Chance=20
		enemyCanFly = 0
		New()
			Raise_Speed(15)
			Raise_Strength(0)
			Raise_Durability(20)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(20)
			Raise_Defense(0)
			. = ..()
	Spider1
		icon='NPC Spider.dmi'
		bp_mod=0.6
		enemyCanFly = 0
		New()
			Raise_Speed(25)
			Raise_Strength(15)
			Raise_Durability(0)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(15)
			Raise_Defense(0)
			. = ..()
	Big_Scorpion
		icon='NPC Scorpion 2.dmi'
		bp_mod=1.7
		Enlargement_Chance=20
		enemyCanFly = 0
		New()
			Raise_Speed(0)
			Raise_Strength(10)
			Raise_Durability(30)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(10)
			Raise_Defense(5)
			. = ..()
	Red_Scorpion
		icon='NPC Scorpion.dmi'
		bp_mod=0.75
		enemyCanFly = 0
		New()
			Raise_Speed(15)
			Raise_Strength(10)
			Raise_Durability(30)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(0)
			Raise_Defense(0)
			. = ..()
	Reptilian
		icon='NPC Reptile Monster.dmi'
		bp_mod=1.5
		Enlargement_Chance=20
		enemyCanFly = 0
		New()
			Raise_Speed(20)
			Raise_Strength(0)
			Raise_Durability(0)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(20)
			Raise_Defense(15)
			npc_move_delay*=0.75
			. = ..()
	Chicken
		icon='NPC Chicken.dmi'
		Docile=1
		bp_mod=0.01
		New()
			Raise_Speed(55)
			Raise_Strength(0)
			Raise_Durability(0)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(0)
			Raise_Defense(0)
			. = ..()
	Dragon1
		name="Dragon"
		icon='NPC Dragon 1.dmi'
		bp_mod=0.9
		Enlargement_Chance=20
		New()
			Raise_Speed(0)
			Raise_Strength(25)
			Raise_Durability(30)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(0)
			Raise_Defense(0)
			. = ..()
	Ground_Dragon
		icon='NPC Dragon 2.dmi'
		Docile=1
		bp_mod=0.5
		Enlargement_Chance=20
		enemyCanFly = 0
		New()
			Raise_Speed(20)
			Raise_Strength(0)
			Raise_Durability(20)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(5)
			Raise_Defense(10)
			. = ..()
	Skeleton_Captain
		icon='NPC Skeleton.dmi'
		bp_mod=0.65
		enemyCanFly = 0
		New()
			Raise_Speed(0)
			Raise_Strength(25)
			Raise_Durability(0)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(20)
			Raise_Defense(10)
			. = ..()
	Giant_Snake
		icon='NPC Snake.dmi'
		bp_mod=1.1
		Enlargement_Chance=20
		enemyCanFly = 0
		New()
			Raise_Speed(20)
			Raise_Strength(15)
			Raise_Durability(0)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(20)
			Raise_Defense(0)
			. = ..()
	Virus_Android
		icon='NPC Virus Android.dmi'
		bp_mod=1
		enemyCanFly = 0
		New()
			Raise_Speed(0)
			Raise_Strength(15)
			Raise_Durability(40)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(0)
			Raise_Defense(0)
			. = ..()
	Little_Demon
		icon='NPC Little Demon.dmi'
		bp_mod=0.45
		New()
			Raise_Speed(25)
			Raise_Strength(10)
			Raise_Durability(0)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(20)
			Raise_Defense(0)
			. = ..()
	Dino_Munky
		name="Dino Munky"
		icon='Dino Munky.dmi'
		bp_mod=1.2
		Enlargement_Chance=20
		enemyCanFly = 0
		New()
			Raise_Speed(0)
			Raise_Strength(20)
			Raise_Durability(20)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(15)
			Raise_Defense(0)
			. = ..()
	Robot
		Race="Robot"
		icon='Gochekbots.dmi'
		Docile=1
		icon_state="3"
		bp_mod=0.75
		enemyCanFly = 0
		New()
			Raise_Speed(10)
			Raise_Strength(10)
			Raise_Durability(15)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(10)
			Raise_Defense(10)
			. = ..()
	Big_Robot
		Race="Robot"
		icon='Gochekbots.dmi'
		icon_state="4"
		bp_mod=0.95
		enemyCanFly = 0
		New()
			Raise_Speed(0)
			Raise_Strength(20)
			Raise_Durability(20)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(15)
			Raise_Defense(0)
			. = ..()
	Hover_Robot
		Race="Robot"
		icon='Gochekbots.dmi'
		Docile=1
		Flyer=1
		icon_state="5"
		bp_mod=0.55
		Enlargement_Chance=0
		New()
			Raise_Speed(30)
			Raise_Strength(5)
			Raise_Durability(0)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(10)
			Raise_Defense(10)
			. = ..()
	Gremlin
		Race="Gremlin!"
		icon='GochekMonster.dmi'
		icon_state="1"
		bp_mod=0.35
		enemyCanFly = 0
		New()
			Raise_Speed(40)
			Raise_Strength(0)
			Raise_Durability(0)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(15)
			Raise_Defense(0)
			. = ..()
	Baiman
		icon='Baiman.dmi'
		bp_mod = 0.6
		enemyCanFly = 0
		New()
			Docile = 0
			Raise_Speed(15)
			Raise_Strength(20)
			Raise_Durability(0)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(20)
			Raise_Defense(0)
			npc_move_delay *= 0.5
			. = ..()
	Greenster
		Race="Greenster"
		icon='Saibaman.dmi'
		bp_mod=1.2
		enemyCanFly = 0
		New()
			Raise_Speed(15)
			Raise_Strength(10)
			Raise_Durability(0)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(15)
			Raise_Defense(15)
			. = ..()
	Small_Greenster
		Race="Greenster"
		icon='Small Saiba.dmi'
		bp_mod=0.8
		enemyCanFly = 0
		New()
			Raise_Speed(20)
			Raise_Strength(0)
			Raise_Durability(0)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(20)
			Raise_Defense(15)
			. = ..()
	Black_Greenster
		Race="Greenster"
		icon='Black Saiba.dmi'
		bp_mod=1.45
		enemyCanFly = 0
		New()
			Raise_Speed(5)
			Raise_Strength(20)
			Raise_Durability(0)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(15)
			Raise_Defense(15)
			. = ..()
	Mutated_Greenster
		Race="Greenster"
		icon='Green Saibaman.dmi'
		bp_mod=1.65
		enemyCanFly = 0
		New()
			Raise_Speed(20)
			Raise_Strength(15)
			Raise_Durability(10)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(10)
			Raise_Defense(0)
			. = ..()
	Evil_Entity
		Race="???"
		icon='Evil Man.dmi'
		bp_mod=1.7
		New()
			Raise_Speed(10)
			Raise_Strength(20)
			Raise_Durability(25)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(0)
			Raise_Defense(0)
			npc_move_delay*=0.5
			. = ..()
	Bandit
		Race="Human"
		icon='BaseHumanTan.dmi'
		bp_mod=0.5
		enemyCanFly = 0
		New()
			Raise_Speed(10)
			Raise_Strength(10)
			Raise_Durability(10)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(15)
			Raise_Defense(10)
			icon = RandomHumanIcon()
			. = ..()
	Tiger_Bandit
		Race="Tiger Man"
		icon='Tiger Man.dmi'
		bp_mod=0.65
		enemyCanFly = 0
		New()
			Raise_Speed(15)
			Raise_Strength(15)
			Raise_Durability(10)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(15)
			Raise_Defense(0)
			. = ..()
	Night_Wolf
		Race="Night Wolf"
		icon='Wolf.dmi'
		Docile=1
		bp_mod=0.75
		enemyCanFly = 0
		New()
			Raise_Speed(20)
			Raise_Strength(15)
			Raise_Durability(20)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(0)
			Raise_Defense(0)
			. = ..()
	Giant_Robot
		Race="Robot"
		icon='Giant Robot 2.dmi'
		bp_mod=1.4
		enemyCanFly = 0
		New()
			Raise_Speed(0)
			Raise_Strength(25)
			Raise_Durability(30)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(0)
			Raise_Defense(0)
			. = ..()
	Ice_Dragon
		Race="Robot"
		icon='Ice Robot.dmi'
		bp_mod=2
		Enlargement_Chance=20
		enemyCanFly = 0
		New()
			Raise_Speed(0)
			Raise_Strength(10)
			Raise_Durability(25)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(10)
			Raise_Defense(10)
			. = ..()
	Ice_Flame
		Race="Creature"
		icon='Ice Monster.dmi'
		bp_mod=1.8
		enemyCanFly = 0
		New()
			Raise_Speed(0)
			Raise_Strength(15)
			Raise_Durability(0)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(20)
			Raise_Defense(20)
			. = ..()
	Frog
		icon='Animal, Frog.dmi'
		Docile=1
		bp_mod=0.01
		enemyCanFly = 0
		New()
			Raise_Speed(25)
			Raise_Strength(0)
			Raise_Durability(0)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(0)
			Raise_Defense(30)
			. = ..()
	Sheep
		icon='NPC Sheep.dmi'
		Docile=1
		bp_mod=0.4
		enemyCanFly = 0
		New()
			Raise_Speed(35)
			Raise_Strength(0)
			Raise_Durability(0)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(10)
			Raise_Defense(10)
			. = ..()
	Dino_Bird
		icon='Animal DinoBird.dmi'
		Docile=1
		bp_mod=0.35
		New()
			Raise_Speed(0)
			Raise_Strength(20)
			Raise_Durability(0)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(0)
			Raise_Defense(35)
			. = ..()
	Cat
		icon='Cat.dmi'
		Docile=1
		bp_mod=0.35
		enemyCanFly = 0
		New()
			Cat_Actions()
			Raise_Speed(20)
			Raise_Strength(10)
			Raise_Durability(0)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(15)
			Raise_Defense(10)
			. = ..()
		proc/Cat_Actions()
			set waitfor=0
			while(src)
				var/Mode=pick("Walk","Sleep")
				if(Health<100) Mode="Walk"
				if(Mode=="Sleep")
					icon_state="Sleep"
					Frozen=1
				if(Mode=="Walk")
					icon_state=""
					Frozen=0
				sleep(rand(2000,4000))
	Bat
		icon='Animal Bat.dmi'
		Docile=1
		density=0
		bp_mod=0.2
		New()
			Raise_Speed(0)
			Raise_Strength(40)
			Raise_Durability(0)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(15)
			Raise_Defense(0)
			. = ..()
	Cow
		icon='Animal Cow.dmi'
		Docile=1
		bp_mod=0.7
		enemyCanFly = 0
		New()
			Raise_Speed(0)
			Raise_Strength(0)
			Raise_Durability(55)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(0)
			Raise_Defense(0)
			. = ..()
	Turtle
		icon='Turtle.dmi'
		Docile=1
		bp_mod=1.5
		enemyCanFly = 0
		New()
			Raise_Speed(0)
			Raise_Strength(0)
			Raise_Durability(40)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(15)
			Raise_Defense(0)
			. = ..()
		Del()
			if(prob(10))
				var/obj/items/Weights/A=new
				A.icon='Turtle Shell.dmi'
				A.SafeTeleport(loc)
				A.dir=NORTH
			. = ..()

var/list/inactive_core_demons=new
proc/Get_core_demon()
	var/mob/m
	if(inactive_core_demons.len) m=inactive_core_demons[1]
	if(!m) return new/mob/Enemy/Core_Demon
	inactive_core_demons-=m
	m.Add_resources()
	m.New_npc_bp()
	m.Update_npc_stats()
	return m
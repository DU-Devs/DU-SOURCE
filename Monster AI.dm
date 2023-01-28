mob/proc/Activate_NPCs_Loop() spawn if(src)
	var/turf/former_loc=loc
	while(src)
		if(former_loc!=loc&&client&&client.inactivity<300) Activate_NPCs()
		former_loc=loc
		sleep(35)

mob/proc/Activate_NPCs(Distance=25) if(current_area) for(var/mob/Enemy/M in current_area.npc_list)
	if(!M.NPC_Activated&&M.z==z&&getdist(src,M)<Distance)
		M.Activate_NPC()
		if(prob(30)) sleep(1)

mob/var/tmp/NPC_Activated

var/list/Inactive_NPCs=new

mob/proc/Activate_NPC(Timer=600) spawn if(src&&!NPC_Activated&&z)
	if(istype(src,/mob/Enemy/Zombie)) Timer=4*600
	NPC_Activated=1
	Inactive_NPCs-=src
	Inactive_NPCs=remove_nulls(Inactive_NPCs)
	NPC_Roam(Timer)
	Find_Target(Timer)
	//Power_Increase_Loop(Timer)
	//NPC_Heal_Loop(Timer)
	spawn(Timer) if(src)
		NPC_Activated=0
		Inactive_NPCs+=src

mob/proc/NPC_Roam(Timer=600,Delay=10) spawn if(src)
	if(!KO) dir=pick(NORTH,SOUTH,EAST,WEST,NORTHWEST,NORTHEAST,SOUTHWEST,SOUTHEAST)
	Land()
	if(!KO&&Flyer&&!Flying) Fly()
	var/turf/Last_Loc
	for(var/I in 0 to round(Timer/Delay))
		if(!Target&&!KB)
			if(!KO&&On_Water(src)&&!Flying) Fly()
			if(!KB) step(src,dir)
			if(prob(5)||loc==Last_Loc) dir=pick(turn(dir,45),turn(dir,-45))
			Last_Loc=loc
		if(!z) return
		sleep(Delay)

mob/proc/Find_Target(Timer=600,Delay=20) spawn if(src)
	if(Docile) return
	for(var/I in 0 to round(Timer/Delay))
		//if(!Target)
		var/area/a=get_area()
		var/mob/m
		for(var/mob/m2 in a.player_list)
			if(m2.z==z&&getdist(src,m2)<25&&(!m||getdist(src,m2)<getdist(src,m)))
				//if(get_dir(src,P) in list(dir,turn(dir,45),turn(dir,-45)))
				if(!(m2 in unreachable_targets)) m=m2
		if(m) Attack_Target(m)
		if(!z) return
		sleep(Delay)

mob/var/tmp/list/unreachable_targets=new

mob/var/tmp/npc_move_delay=5

mob/proc/Attack_Target(mob/P) spawn if(src)
	var/mob/Former_Target=Target
	if(P) Target=P
	if(Former_Target) return
	var/Delay=npc_move_delay
	if(Delay<1) Delay=1
	var/max_range=25
	var/failed_steps=0
	var/target_unreachable
	while(src && Target && !Target.KO && getdist(src,Target)<=max_range && viewable(src,Target,max_range))
		var/float_delay=To_tick_lag_multiple(Delay)
		if(!KB)
			if(getdist(src,Target)>1)
				var/turf/old_loc=loc
				var/turf/T=Get_step(src,get_dir(src,Target))
				T=null //DISABLES PATHFINDING. IT WAS FAR TOO LAGGY BUT ALSO USED TONS OF REAL CPU ON SHELL
				if(T&&!T.Enter(src)&&Can_Pathfind())
					g_step_to(Target)
					float_delay=100
				else
					step_towards(src,Target)
				if(loc==old_loc) failed_steps++
				else failed_steps=0
				if(failed_steps>=10)
					unreachable_targets+=Target
					Remove_unreachable_target(Target,1800)
					target_unreachable=1
			else if(!KO&&!KB)
				dir=get_dir(src,Target)
				Bump(Target)
		if(!KB)
			if(!Flying&&(Target&&(Target.Flying||On_Water(Target)))||On_Water(src)) if(!KO) Fly()
			else if(!Target||(!Target.Flying&&Flying)) Land()
			if(Target&&Target.KO) step_away(src,Target)
			if(target_unreachable) Target=null
		sleep(float_delay)
	Target=null
	if(Flying) Land()

mob/proc/Remove_unreachable_target(mob/m,timer=0)
	spawn(timer) if(m)
		unreachable_targets-=m
		unreachable_targets=remove_nulls(unreachable_targets)

mob/proc/Can_Pathfind(N=1)
	for(var/mob/Enemy/E in view(4,src)) if(E!=src&&E.Target==Target) N++
	if(prob(100/N)) return 1

mob/proc/Power_Increase_Loop(Timer=600,Delay=100) spawn if(src)

	return //DISABLED!!!!!!!!!!

	if(!istype(src,/mob/Enemy/Zombie)) return

	for(var/I in 0 to round(Timer/Delay))
		if(!KO) for(var/mob/P in player_view(7,src)) if(P.client) Attack_Gain(1,P)
		sleep(Delay)

mob/proc/NPC_Heal_Loop(Timer=600,Delay=50) spawn if(src)
	for(var/I in 0 to round(Timer/Delay))
		if(Health<100)
			Health+=1*regen*(Delay/10)
			if(Health>100) Health=100
		if(Ki<max_ki) Ki=max_ki
		//BP=get_bp() //this has been resetting their bp to 1
		sleep(Delay)

proc/On_Water(mob/M)
	var/turf/T=M.True_Loc()
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
			loc=T
		var/turf/NewLoc=loc
		if(!NewLoc||!isturf(NewLoc)||NewLoc.density||NewLoc.Water||!(T in view(40,src)))
			Found=0
			loc=T
	if(prob(50)) Find_Location()

var/NPC_Delay=1
var/NPC_Can_Respawn=1
var/NPC_Leave_Body=1
var/npcs_enabled=1

mob/Admin3/verb/boot_NPCs()
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

mob/var/Flying

mob/Bump(mob/A)
	..()
	//if(ismob(A)) Pixel_Align(A)

	if(istype(A,/obj/items/Simulator))
		var/obj/items/Simulator/s=A
		s.Toggle_simulated_fighter(src)

	if(istype(A,/obj/items/Regenerator))
		loc=A.loc
		Regenerator_loop(A)
		if(grabbed_mob&&ismob(grabbed_mob))
			grabbed_mob.loc=loc
			grabbed_mob.Regenerator_loop(A)

	if(istype(A,/obj/Kaioshin_Portal))
		var/obj/Kaioshin_Portal/KP=A
		if(KP.icon)
			if(Teleport_nulled())
				src<<"A teleport nullifier prevents the portal from working"
			else
				loc=locate(250,250,13)
				spawn if(KP) KP.Become_inactive()

	if(istype(A,/obj/Bank))
		Bank_Options(A)
		return

	if(istype(A,/obj/Ship_exit))
		var/obj/Ship_exit/Se=A
		for(var/obj/Controls/C in range(6,Se))
			C.Exit_Ship(src,Se)

	if(istype(A,/obj/Final_Realm_Portal))
		loc=locate(rand(163,173),rand(183,193),5)
		return

	if(istype(A,/obj/Warper))
		var/obj/Warper/B=A
		loc=locate(B.gotox,B.gotoy,B.gotoz)

	if(istype(A,/obj/Turfs/Door)||(isturf(A)&&(locate(/obj/Turfs/Door) in A)))
		var/obj/Turfs/Door/B=A
		if(isturf(A)) B=locate(/obj/Turfs/Door) in A
		if(B)
			if(drone_module && drone_module.Password==B.Password)
				B.Open()
				return
			for(var/obj/items/Door_Pass/D in item_list) if(D.Password==B.Password)
				B.Open()
				return
			for(var/obj/items/Door_Hacker/D in item_list) if(D.BP>=B.Health)
				player_view(15,B)<<"[src] hacks the door and it opens"
				B.Open()
				return
			if(client&&B.Password&&!KB&&!("door password" in active_prompts))
				active_prompts+="door password"
				var/Guess=input(src,"You must know the password to enter here") as text
				active_prompts-="door password"
				if(B)
					if(Guess!=B.Password) return
					else B.Open()
			else if(B&&!B.Password) B.Open()

	if(istype(A,/obj/Ships/Ship))
		var/obj/Ships/Ship/B=A
		var/turf/t=Get_step(B,SOUTHEAST)
		if(!t||loc==t||B.bound_width==32)
			for(var/obj/Controls/C in ship_controls) if(C.Ship==B.Ship)
				player_view(15,src)<<"[src] enters the [A]"
				if(!B.Last_Entry) src<<"<font color=yellow>Computer: Welcome. You are the first one to enter this ship."
				else if(Year-B.Last_Entry>=1) src<<"<font color=yellow>Computer: Welcome, you are the first person to enter this \
				ship in the past [round(Year-B.Last_Entry,0.1)] years"
				B.Last_Entry=Year
				for(var/obj/Ship_exit/Se in range(5,C))
					loc=locate(Se.x,Se.y,Se.z)
					break

	if(ismob(A))
		if(type==/mob/Splitform) if(!A.KO) Melee(A)
		else if(type!=/mob/Troll&&type!=/mob/new_troll) if((!client&&(!Docile||Health<100))||Is_oozaru())
			if(istype(src,/mob/Enemy)&&istype(A,/mob/Enemy))
			else
				if(!drone_module) Melee(A)
		else if(client && Flying && dir==A.dir) loc=A.loc

	if(istype(A,/obj/Planets)) Bump_Planet(A,src)

	if(istype(src,/mob/Enemy)&&world.time-src:last_npc_turf_attack>50)
		if(!client&&isobj(A)&&!istype(A,/obj/Edges)&&istype(src,/mob/Enemy/Zombie))
			src:last_npc_turf_attack=world.time
			Melee(A)
		if(!client&&isturf(A)&&A.density&&istype(src,/mob/Enemy/Zombie))
			src:last_npc_turf_attack=world.time
			Melee(A)

	if(istype(A,/obj/Controls))
		var/obj/Controls/C=A
		C.Ship_Options(src)

	if(isturf(A))

		for(var/obj/Controls/C in A) C.Ship_Options(src)

		for(var/obj/items/Simulator/s in A)
			s.Toggle_simulated_fighter(src)

mob/Enemy/var/tmp/last_npc_turf_attack=0

mob/var/Enlarged
mob/var/mob_creation_time=0

mob/New()
	if(!mob_creation_time) mob_creation_time=world.realtime
	Set_Spawn_Point(src)
	spawn(10) update_area()
	..()
mob
	proc/Add_resources()
		var/mob/Enemy/e=src
		var/obj/Resources/B=new(src)
		B.Value=round(rand(2400,3600)*bp_mod*e.npc_money_mod*Resource_Multiplier)
		B.Update_value()
	proc/Add_hbtc_key()
		if(world.time<5*600) return
		if(z==1&&npcs_give_hbtc_keys&&prob(1))
			give_hbtc_key()
	proc/New_npc_bp()
		BP=0.5*Avg_BP*bp_mod
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
mob/Enemy
	move=1
	Spawn_Timer=30
	max_ki=60 //multiplies by Eff of npc in New()
	Ki=60
	var/Enlargement_Chance=0
	var/npc_money_mod=1
	Has_DNA=0
	New()
		update_area()
		Inactive_NPCs+=src
		spawn if(src&&z&&!istype(src,/mob/Enemy/Zombie))
			if(z==14)
				bp_mod*=2
				if(Enlargement_Chance<33) Enlargement_Chance=33
			if(prob(Enlargement_Chance))
				BP*=2
				bp_mod*=2
				var/w=round(Get_Width(icon)*1.5 , 1)
				var/h=round(Get_Height(icon)*1.5 , 1)
				Enlarge_Icon(w,h)
				pixel_y=0
			Update_npc_stats()
		Add_resources()
		Add_hbtc_key()
		New_npc_bp()
		//spawn(rand(0,600)) Activate_NPC(600)
		..()
	Del()
		if(NPC_Leave_Body) Leave_Body()
		..()
	Core_Demon
		icon='KillasIconBlack.dmi'
		bp_mod=4.1
		npc_money_mod=8
		Spawn_Timer=0
		Enlargement_Chance=20
		npc_move_delay=2.5
		Del()
			update_area()
			for(var/mob/m in player_view(18,src))
				if(m.Health<100) m.Health=100
			..()
		New()
			Raise_Speed(0)
			Raise_Strength(27)
			Raise_Durability(0)
			Raise_Force(0)
			Raise_Resist(5) //special high resistance or else ki users have too easy a time in the core
			Raise_Offense(25)
			Raise_Defense(0)
			..()
	Spider_Small
		icon='Spider Small.dmi'
		bp_mod=0.15
		New()
			Raise_Speed(15)
			Raise_Strength(20)
			Raise_Durability(0)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(20)
			Raise_Defense(0)
			npc_move_delay*=0.5
			..()
	Squirrel
		icon='NPC Squirrel.dmi'
		Docile=1
		bp_mod=0.25
		New()
			Raise_Speed(21)
			Raise_Strength(0)
			Raise_Durability(0)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(17)
			Raise_Defense(17)
			..()
	Jungle_Spider
		icon='Spider 3 2 2014.dmi'
		bp_mod=3
		Enlargement_Chance=33
		New()
			Raise_Speed(10)
			Raise_Strength(9)
			Raise_Durability(8)
			Raise_Force(0)
			Raise_Resist(8)
			Raise_Offense(10)
			Raise_Defense(10)
			npc_move_delay*=0.5
			Center_Icon(src)
			..()
	Spider3
		icon='NPC Spider 3.dmi'
		bp_mod=2
		Enlargement_Chance=20
		New()
			Raise_Speed(15)
			Raise_Strength(15)
			Raise_Durability(5)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(10)
			Raise_Defense(10)
			..()
	Spider2
		icon='NPC Spider 2.dmi'
		bp_mod=1
		Enlargement_Chance=20
		New()
			Raise_Speed(15)
			Raise_Strength(0)
			Raise_Durability(20)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(20)
			Raise_Defense(0)
			..()
	Spider1
		icon='NPC Spider.dmi'
		bp_mod=0.6
		New()
			Raise_Speed(25)
			Raise_Strength(15)
			Raise_Durability(0)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(15)
			Raise_Defense(0)
			..()
	Big_Scorpion
		icon='NPC Scorpion 2.dmi'
		bp_mod=1.7
		Enlargement_Chance=20
		New()
			Raise_Speed(0)
			Raise_Strength(10)
			Raise_Durability(30)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(10)
			Raise_Defense(5)
			..()
	Red_Scorpion
		icon='NPC Scorpion.dmi'
		bp_mod=0.75
		New()
			Raise_Speed(15)
			Raise_Strength(10)
			Raise_Durability(30)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(0)
			Raise_Defense(0)
			..()
	Reptilian
		icon='NPC Reptile Monster.dmi'
		bp_mod=1.5
		Enlargement_Chance=20
		New()
			Raise_Speed(20)
			Raise_Strength(0)
			Raise_Durability(0)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(20)
			Raise_Defense(15)
			npc_move_delay*=0.75
			..()
	Chicken
		icon='NPC Chicken.dmi'
		Docile=1
		bp_mod=0.3
		New()
			Raise_Speed(55)
			Raise_Strength(0)
			Raise_Durability(0)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(0)
			Raise_Defense(0)
			..()
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
			..()
	Ground_Dragon
		icon='NPC Dragon 2.dmi'
		Docile=1
		bp_mod=0.5
		Enlargement_Chance=20
		New()
			Raise_Speed(20)
			Raise_Strength(0)
			Raise_Durability(20)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(5)
			Raise_Defense(10)
			..()
	Skeleton_Captain
		icon='NPC Skeleton.dmi'
		bp_mod=0.65
		New()
			Raise_Speed(0)
			Raise_Strength(25)
			Raise_Durability(0)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(20)
			Raise_Defense(10)
			..()
	Giant_Snake
		icon='NPC Snake.dmi'
		bp_mod=1.1
		Enlargement_Chance=20
		New()
			Raise_Speed(20)
			Raise_Strength(15)
			Raise_Durability(0)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(20)
			Raise_Defense(0)
			..()
	Virus_Android
		icon='NPC Virus Android.dmi'
		bp_mod=1
		New()
			Raise_Speed(0)
			Raise_Strength(15)
			Raise_Durability(40)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(0)
			Raise_Defense(0)
			..()
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
			..()
	Dino_Munky
		name="Dino Munky"
		icon='Dino Munky.dmi'
		bp_mod=1.2
		Enlargement_Chance=20
		New()
			Raise_Speed(0)
			Raise_Strength(20)
			Raise_Durability(20)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(15)
			Raise_Defense(0)
			..()
	Robot
		Race="Robot"
		icon='Gochekbots.dmi'
		Docile=1
		icon_state="3"
		bp_mod=0.75
		New()
			Raise_Speed(10)
			Raise_Strength(10)
			Raise_Durability(15)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(10)
			Raise_Defense(10)
			..()
	Big_Robot
		Race="Robot"
		icon='Gochekbots.dmi'
		icon_state="4"
		bp_mod=0.95
		New()
			Raise_Speed(0)
			Raise_Strength(20)
			Raise_Durability(20)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(15)
			Raise_Defense(0)
			..()
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
			..()
	Gremlin
		Race="Gremlin!"
		icon='GochekMonster.dmi'
		icon_state="1"
		bp_mod=0.35
		New()
			Raise_Speed(40)
			Raise_Strength(0)
			Raise_Durability(0)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(15)
			Raise_Defense(0)
			..()
	Saibaman
		Race="Saibaman"
		icon='Saibaman.dmi'
		bp_mod=1.2
		New()
			Raise_Speed(15)
			Raise_Strength(10)
			Raise_Durability(0)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(15)
			Raise_Defense(15)
			..()
	Small_Saibaman
		Race="Saibaman"
		icon='Small Saiba.dmi'
		bp_mod=0.8
		New()
			Raise_Speed(20)
			Raise_Strength(0)
			Raise_Durability(0)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(20)
			Raise_Defense(15)
			..()
	Black_Saibaman
		Race="Saibaman"
		icon='Black Saiba.dmi'
		bp_mod=1.45
		New()
			Raise_Speed(5)
			Raise_Strength(20)
			Raise_Durability(0)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(15)
			Raise_Defense(15)
			..()
	Mutated_Saibaman
		Race="Saibaman"
		icon='Green Saibaman.dmi'
		bp_mod=1.65
		New()
			Raise_Speed(20)
			Raise_Strength(15)
			Raise_Durability(10)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(10)
			Raise_Defense(0)
			..()
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
			..()
	Bandit
		Race="Human"
		icon='New Tan Male.dmi'
		bp_mod=0.5
		New()
			Raise_Speed(10)
			Raise_Strength(10)
			Raise_Durability(10)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(15)
			Raise_Defense(10)
			..()
	Tiger_Bandit
		Race="Tiger Man"
		icon='Tiger Man.dmi'
		bp_mod=0.65
		New()
			Raise_Speed(15)
			Raise_Strength(15)
			Raise_Durability(10)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(15)
			Raise_Defense(0)
			..()
	Night_Wolf
		Race="Night Wolf"
		icon='Wolf.dmi'
		Docile=1
		bp_mod=0.75
		New()
			Raise_Speed(20)
			Raise_Strength(15)
			Raise_Durability(20)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(0)
			Raise_Defense(0)
			..()
	Giant_Robot
		Race="Robot"
		icon='Giant Robot 2.dmi'
		bp_mod=1.4
		New()
			Raise_Speed(0)
			Raise_Strength(25)
			Raise_Durability(30)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(0)
			Raise_Defense(0)
			..()
	Ice_Dragon
		Race="Robot"
		icon='Ice Robot.dmi'
		bp_mod=2
		Enlargement_Chance=20
		New()
			Raise_Speed(0)
			Raise_Strength(10)
			Raise_Durability(25)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(10)
			Raise_Defense(10)
			..()
	Ice_Flame
		Race="Creature"
		icon='Ice Monster.dmi'
		bp_mod=1.8
		New()
			Raise_Speed(0)
			Raise_Strength(15)
			Raise_Durability(0)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(20)
			Raise_Defense(20)
			..()
	Frog
		icon='Animal, Frog.dmi'
		Docile=1
		bp_mod=0.2
		New()
			Raise_Speed(25)
			Raise_Strength(0)
			Raise_Durability(0)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(0)
			Raise_Defense(30)
			..()
	Sheep
		icon='NPC Sheep.dmi'
		Docile=1
		bp_mod=0.4
		New()
			Raise_Speed(35)
			Raise_Strength(0)
			Raise_Durability(0)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(10)
			Raise_Defense(10)
			..()
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
			..()
	Cat
		icon='Cat.dmi'
		Docile=1
		bp_mod=0.35
		New()
			spawn if(src) Cat_Actions()
			Raise_Speed(20)
			Raise_Strength(10)
			Raise_Durability(0)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(15)
			Raise_Defense(10)
			..()
		proc/Cat_Actions() while(src)
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
			..()
	Cow
		icon='Animal Cow.dmi'
		Docile=1
		bp_mod=0.7
		New()
			Raise_Speed(0)
			Raise_Strength(0)
			Raise_Durability(55)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(0)
			Raise_Defense(0)
			..()
	Turtle
		icon='Turtle.dmi'
		Docile=1
		bp_mod=1.5
		New()
			Raise_Speed(0)
			Raise_Strength(0)
			Raise_Durability(40)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(15)
			Raise_Defense(0)
			..()
		Del()
			if(prob(10))
				var/obj/items/Weights/A=new
				A.icon='Turtle Shell.dmi'
				A.loc=loc
				A.dir=NORTH
			..()
mob/proc/Drop_dragonballs()
	if(item_list.len) for(var/obj/items/Dragon_Ball/A in item_list) if(A.loc==src)
		item_list-=A
		A.loc=loc

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

mob/Del()
	if(current_area)
		current_area.mob_list-=src
		current_area.player_list-=src
		current_area.npc_list-=src
		current_area=null
	if(grabber) grabber.Release_grab()
	DBZ_character_del()
	Drop_dragonballs()
	//Target=null
	if(!perma_delete&&Spawn_Timer&&istype(src,/mob/Enemy)&&!istype(src,/mob/Enemy/Zombie)) NPC_Del()

	else if(type==/mob/Enemy/Core_Demon&&icon==initial(icon))
		Full_Heal()
		inactive_core_demons-=src
		inactive_core_demons+=src
		loc=null
		if(grabber) grabber.Release_grab()

	else if(type==/mob/Body)
		var/mob/Body/b=src
		if(!b.Cooked&&NPC_Leave_Body) Body_Parts()
		cached_bodies-=src
		cached_bodies+=src
		loc=null
		if(grabber) grabber.Release_grab()

	else if(type==/mob/Splitform)
		if(grabber) grabber.Release_grab()
		loc=null
		Full_Heal()
		Target=null
		var/mob/Splitform/sf=src
		sf.Mode=null
		splitform_cache-=src
		splitform_cache+=src
		if(Maker&&ismob(Maker))
			Maker.splitform_list-=src
			if(Maker.client) Maker.client.screen-=src

	else
		/*Tens("\
		mob deleted:<br>\
		name: [src]<br>\
		type: [type]<br>\
		key: [key]<br>\
		loc: [x],[y],[z]\
		<br>\
		")*/

		//if(key)
		for(var/obj/o in contents) pending_object_delete_list+=o
		contents=null

		drone_module=null //just wondering if this reference is why deleting drones lags so bad

		..()

var/list/pending_object_delete_list=new

proc/Delete_pending_objects_loop() spawn
	while(1)
		for(var/obj/o in pending_object_delete_list)
			del(o)
			sleep(20)
		sleep(50)

mob/Captain
	icon='New Pale Male.dmi'
	dir=EAST
	New()
		var/image/A=image(icon='New Pale Male.dmi',pixel_x=100,pixel_y=0,dir=WEST)
		var/image/B=image(icon='New Pale Male.dmi',pixel_x=50,pixel_y=-50,dir=NORTH)
		var/image/C=image(icon='New Pale Male.dmi',pixel_x=50,pixel_y=50,dir=SOUTH)
		overlays.Add(A,B,C)
		spawn Captain_Speak()
	proc/Captain_Speak() while(src)
		sleep(rand(10,40))
		player_view(10,src)<<"<font color=red>Captain: What happen?!"
		sleep(rand(10,40))
		player_view(10,src)<<"<font color=teal>Mechanic: Somebody set us up the bomb!"
		sleep(rand(10,40))
		player_view(10,src)<<"<font color=yellow>Operator: We get signal!"
		sleep(rand(10,40))
		player_view(10,src)<<"<font color=red>Captain: What?!"
		sleep(rand(10,40))
		player_view(10,src)<<"<font color=yellow>Operator: Main screen turn on!"
		sleep(rand(10,40))
		player_view(10,src)<<"<font color=red>Captain: It's you!"
		sleep(rand(10,40))
		player_view(10,src)<<"<font color=green>CATS: How are you gentleman?"
		sleep(rand(10,40))
		player_view(10,src)<<"<font color=green>CATS: All your base are belong to us!"
		sleep(rand(10,40))
		player_view(10,src)<<"<font color=green>CATS: You are on the way to destruction."
		sleep(rand(10,40))
		player_view(10,src)<<"<font color=red>Captain: What you say?!"
		sleep(rand(10,40))
		player_view(10,src)<<"<font color=green>CATS: You have no chance to survive make your time."
		sleep(rand(10,40))
		player_view(10,src)<<"<font color=green>CATS: Ha Ha Ha Ha ..."
		sleep(rand(10,40))
		player_view(10,src)<<"<font color=yellow>Operator: Captain!!"
		sleep(rand(10,40))
		player_view(10,src)<<"<font color=red>Captain: Take off every 'ZIG'!"
		sleep(rand(10,40))
		player_view(10,src)<<"<font color=red>Captain: You know what you doing."
		sleep(rand(10,40))
		player_view(10,src)<<"<font color=red>Captain: Move 'ZIG'! For great justice!"
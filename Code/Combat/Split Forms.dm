mob/var
	tmp
		mob/Maker

var/list/splitform_cache=new
var/list/all_splitforms=new

proc/Get_cached_splitform()
	for(var/mob/m in splitform_cache)
		ResetVars(m)
		splitform_cache-=m
		m.New()
		return m
	return new/mob/Splitform

mob/var/can_redo_stats = 1

mob/proc
	SplitformDestroyedByCheck(mob/m)
		if(type != /mob/Splitform) return
		var/mob/Splitform/s = src
		if(!z || !m || m == s.Maker) return
		if(s.Maker)
			s.Maker.Health -= 30
			s.Maker.Ki *= 0.7
			if(s.Maker.Health < 0)
				s.Maker.KO(m)
		return 1

	MaxSplitforms()
		var/n = 3 * (BufflessKiMod() / 1.5) ** 0.4
		n = round(n, 1)
		if(n < 1) n = 1
		return n

mob/Splitform
	Has_DNA=0
	brain_transplant_allowed=0
	can_redo_stats = 0
	var
		Mode
		Sim_ID
		followDist = 3

	New()
		all_splitforms-=src
		all_splitforms+=src
		followDist = rand(2,4)
		Attack_Loop()
		Death_Loop()
		BP_Loop()
		Target_Loop()
		Follow_Loop()
		Fly_Check()
		Auto_Attack_Enemy()
		Sim_Destroy_Loop()

	Del()
		. = ..()
		Maker = null
		Sim_ID = null

	proc/SimDestroyedBy(mob/m)
		if(!z) return

	proc/Auto_Attack_Enemy()
		set waitfor=0
		sleep(5)
		while(src && !Sim_ID && Maker)
			if(z && Maker.Opponent && Maker.attacking && Maker.Opponent.Maker != Maker)
				Target = Maker.Opponent
				Mode = "Attack Target"
			if(!z) return
			sleep(5)

	proc/Fly_Check()
		set waitfor=0
		sleep(5)
		while(src)
			if(z && Target)
				if(Target.Flying&&!Flying) Fly()
				else if(!Target.Flying&&Flying) Land()
			else if(z && Maker)
				if(Mode == "Follow")
					if(!Flying) Fly()
				else
					if(Maker.Flying && !Flying) Fly()
					else if(!Maker.Flying && Flying) Land()
			if(!z) return
			sleep(5)

	proc/BP_Loop()
		set waitfor=0
		sleep(2)
		while(src)
			if(Maker&&!Sim_ID) BP = Maker.BP
			if(!z) return
			sleep(5)

	proc/Attack_Loop()
		set waitfor=0
		sleep(5)
		while(src)
			if(z && (Mode in list("Attack Target", "Attack Nearest")))
				if(Target && !Target.KO && Target.z==z && (Target in Get_step(src,dir)))
					Melee(Target)
			if(!z) return
			sleep(world.tick_lag)

	proc/Death_Loop()
		set waitfor=0
		sleep(5)
		while(src)
			if(z)
				if(KO || !Maker) del(src)
			if(!z) return
			sleep(10)

	proc/Target_Loop()
		set waitfor=0
		sleep(5)
		var/lastRetarget = 0
		while(src)
			if(Mode == "Attack Nearest" && world.time - lastRetarget > 30)
				for(var/mob/P in player_view(20,src)) if(P != src && !P.KO && P != Maker)
					if(!Target || get_dist(src, P) < get_dist(src, Target))
						Target = P
				lastRetarget = world.time
			if(Target && (Mode == "Attack Target" || Mode == "Attack Nearest"))
				if(get_dist(src, Target) == 0) step_away(src, Target)
				if(get_dist(src, Target) == 1)
					dir = get_dir(src, Target)
					sleep(3)
				else
					var/direction = get_dir(src, Target)
					if(prob(50))
						direction = pick(turn(direction, 45), turn(direction, -45), turn(direction, 90), turn(direction, -90))
					step(src, direction)
					sleep(world.tick_lag)
			else sleep(4)
			if(!z) return

	proc/Follow_Loop()
		set waitfor=0
		sleep(5)
		while(src)
			if(z && Mode == "Follow")
				if(Maker && get_dist(src, Maker) > followDist)
					var/direction = get_dir(src, Maker)
					if(prob(50))
						direction = pick(turn(direction, 45), turn(direction, -45), turn(direction, 90), turn(direction, -90))
					step(src, direction)
					sleep(world.tick_lag)
				else sleep(5)
			else sleep(5)
			if(!z) return

	Click()
		if(Maker != usr) return
		if(Sim_ID)
			del(src)
			return
		switch(input("Options") in list("Cancel","All Attack Nearest", "All Attack Target", "All Follow", "All Stop", "Attack Nearest", "Attack Target", \
		"Follow", "Stop", "Destroy All"))
			if("Cancel") return
			if("Stop")
				Mode=null
				Target=null
			if("All Stop") for(var/mob/Splitform/S in usr.splitform_list)
				S.Mode=null
				S.Target=null
			if("Attack Target")
				if(usr.tournament_override()) return
				var/list/L=list("Cancel")
				for(var/mob/P in mob_view(20,usr)) if(!P.KO&&P!=src) L+=P
				var/mob/P=input("Choose Target") in L
				if(!P||P=="Cancel") return
				Target=P
				Mode="Attack Target"
			if("Attack Nearest")
				if(usr.tournament_override()) return
				Mode="Attack Nearest"
			if("All Attack Target")
				if(usr.tournament_override()) return
				var/list/L=list("Cancel")
				for(var/mob/P in mob_view(20,usr)) if(!P.KO) L+=P
				var/mob/P=input("Choose Target") in L
				if(!P||P=="Cancel") return
				for(var/mob/Splitform/S in usr.client.screen)
					S.Target=P
					S.Mode="Attack Target"
			if("All Attack Nearest")
				if(usr.tournament_override()) return
				for(var/mob/Splitform/S in usr.client.screen) S.Mode="Attack Nearest"
			if("Follow") Mode="Follow"
			if("All Follow") for(var/mob/Splitform/S in usr.client.screen) S.Mode="Follow"
			if("Destroy All") usr.Destroy_Splitforms()

mob/proc/Destroy_Splitforms() for(var/mob/Splitform/S in splitform_list) del(S)

mob/var/tmp/list/splitform_list=new

obj/SplitForm
	teachable=1
	Skill=1
	hotbar_type="Ability"
	can_hotbar=1
	Teach_Timer=20
	student_point_cost = 20
	Cost_To_Learn=15
	desc="This will make a copy of yourself, made of energy. It has much the same power as you, \
	and makes a good sparring partner or assistant in battle. You can command their actions by clicking \
	on them. When one is destroyed by someone you lose health and energy. You can not recover health or energy while they are out."
	Level=1
	var/tmp/split_timer=0

	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		SplitForm()

	verb/SplitForm()
		set category="Skills"
		usr.TrySplitform()

mob/proc
	TrySplitform()
		set waitfor=0
		if(!CanSplitform()) return
		CreateSplitform()

	CanSplitform()
		if(KO) return
		var/turf/t = get_step(src, dir)
		var/obj/obstacle
		if(t) for(obstacle in t)
			if(obstacle.density)
				break
		if(!t || t.density || obstacle)
			src << "You can not make a splitform here because an obstacle is in the way"
			return
		if(ismob(loc))
			src << "You can not make a splitform while body swapped"
			return
		if(SplitformCount() >= MaxSplitforms())
			src << "You have too many splitforms out already"
			return
		return 1

	CreateSplitform()
		src << "<font color=cyan>Click your splitforms to command them to vanish"
		var/mob/Splitform/A = Get_cached_splitform()
		splitform_list += A
		//stop splits wandering off when they are created from cache
		A.Mode = null
		A.Target = null
		A.Maker = src
		A.displaykey = displaykey
		A.Race = Race
		A.Warp = Warp
		A.KB_On = KB_On
		A.icon = icon
		if(Race == "Bio-Android")
			A.icon = 'Bio3.dmi'
			A.Enlarge_Icon(24,24)
			CenterIcon(A)
			A.pixel_y = 0
		A.Zanzoken = Zanzoken
		A.max_ki = max_ki
		A.Eff = Eff
		A.Ki = A.max_ki
		A.Pow = Pow * 0.8
		A.Str = Str * 0.3 //these are all arbitrary simply because splits are pretty strong right now
		A.Spd = Spd
		A.End = End * 0.3
		A.Res = Res * 2 //because splits are just sitting ducks for ki, when 5 are attacking you just start firing a beam and it auto turns you to face \
		whichever last hit you, and you end up killing all 5 in seconds, and they dont try to avoid it they continuously run into it
		A.Off = Off * 0.8
		A.Def = Def * 0.8
		A.offmod = offmod
		A.defmod = defmod
		if(auto_train)
			A.Pow *= 0.3
			A.Str *= 0.3
			A.End *= 2
			A.Res *= 2
			A.KB_On = 0
		A.gravity_mastered = gravity_mastered
		A.SafeTeleport(get_step(src,dir)) //if you change this it will make ai train not work
		A.dir = turn(dir,180)
		A.overlays.Add(overlays)
		var/copies = 0
		for(var/mob/Splitform/B in splitform_list) copies++
		A.name="[name] splitform [copies]"
		//A.screen_loc = "[copies],1:0"
		A.screen_loc = "[(copies * 1.4) + 5],2"
		if(client) client.screen += A
		A.BP = BP

mob/proc/Sim_Destroy_Loop()
	set waitfor=0
	sleep(5)
	while(Maker && !Maker.KO)
		sleep(20)
		if(!z) return
		if(!Maker || Maker.z != z || getdist(src, Maker) > 50 || Maker.regenerator_obj)
			break
	Maker = null
	del(src)

obj/items/Simulator
	icon='Lab.dmi'
	Can_Drop_With_Suffix=1
	icon_state="terminal"
	Stealable=1
	era_reset_immune=0
	density=1
	Cost=15000

	var
		Max_BP=100

		tmp
			last_sim_bump = 0

	desc="This can create holographic simulations which can be sparred with to enhance training. Click it to \
	bring up the options menu. This is less convenient than splitforms, but they take 3x more damage \
	than splitforms but do only 0.35x damage to you. Making them better and longer training for most \
	people."
	takes_gradual_damage=1

	verb/Upgrade_health()
		set name="Repair/Upgrade health"
		set src in view(1)
		if(usr in view(1,src))
			var/max_health=usr.Knowledge*usr.Intelligence()
			if(Health<max_health)
				player_view(15,usr)<<"[usr] repairs/upgrades the [src]'s health to [Commas(max_health)] BP"
				Health=max_health
			else usr<<"The [src] is beyond your upgrading abilities"

	verb/Bolt()
		set src in oview(1)
		usr.Bolt(src)

	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Upgrade()

	verb/Upgrade()
		set src in view(1)
		if(usr in view(1,src))
			var/Max_Upgrade=usr.Knowledge*2*sqrt(usr.Intelligence())
			var/Percent=(Max_BP/Max_Upgrade)*100
			var/Res_Cost=Item_cost(usr,src)/100
			if(Percent>=100)
				usr<<"This [src] is 100% upgraded at this time and cannot go any further."
				return
			var/Amount=input("This [src] is at level [Level]. The current maximum is \
			[Max_Upgrade]. \
			It is at [Percent]% maximum power. Each 1% upgrade cost [Commas(Res_Cost)]$. The maximum is 100%. Input \
			the percentage of power you wish to bring the [src] to. ([Percent]-100%)") as num
			if(Amount>100) Amount=100
			if(Amount<0.1)
				usr<<"Amount must be higher than 0.1%"
				return
			if(Amount<=Percent)
				usr<<"This cannot be downgraded."
				return
			Res_Cost*=Amount-Percent
			if(usr.Res()<Res_Cost)
				usr<<"You do not have enough resources to do this."
				return
			usr.Alter_Res(-Res_Cost)
			Max_BP=Max_Upgrade*(Amount/100)
			suffix="[Commas(Max_BP)] BP"
			player_view(15,usr)<<"[usr] upgraded [src] from [Percent]% to [Amount]% ([Commas(Max_BP)] BP)"
			name="[Commas(Max_BP)] BP Simulator"

	proc/Create_simulated_fighter(mob/m)
		m.Make_Simulated_Fighter(src,sim_str=0.1,sim_dura=18)

	proc/Destroy_simulated_fighters(mob/m)
		var/found_some
		for(var/mob/Splitform/sf in all_splitforms) if(sf.Sim_ID==usr.displaykey && sf.z)
			found_some=1
			del(sf)
		return found_some

	proc/Toggle_simulated_fighter(mob/m)

		if(!m.client) return //because npcs were accidently bumping simulators and making sims of themself

		if(!Destroy_simulated_fighters(m))
			Create_simulated_fighter(m)

	Click()
		if(Destroy_simulated_fighters(usr)) return
		if(get_dist(src, usr) <= 1 || loc == usr)
			Create_simulated_fighter(usr)
		else usr<<"You must be near this to use it"

mob/proc/SimBump(obj/items/Simulator/s)
	set waitfor=0
	if(IsTens()) src << "SimBump([s.name])"
	if(!s || s.type != /obj/items/Simulator)
		if(IsTens()) src << "no sim"
		return
	if(KB)
		if(IsTens()) src << "KB true"
		return //people knockback you into the sim and it makes a sim of you
	if(world.time - s.last_sim_bump > 10)
		if(IsTens()) src << "SimBump() did what it was supposed to"
		//because its annoying accidently bumping it diagonally when your not even trying to
		//if(getdir(src,s) in list(NORTH,SOUTH,EAST,WEST))
		s.last_sim_bump = world.time
		s.Toggle_simulated_fighter(src)

mob/proc/Make_Simulated_Fighter(obj/items/Simulator/Sim,sim_str=1,sim_dura=1)

	for(var/mob/Splitform/P in all_splitforms) if(P.Sim_ID==displaykey) del(P)

	var/turf/T
	for(T in oview(1,src)) if(!T.density) break
	if(!T)
		src<<"There is no valid spot for this simulation to spawn. Cancelled"
		return

	//if(!T||T.density||Dense_Obj)
	//	usr<<"You can not make a simulation because there are obstructions in front of you"
	//	return

	if(IsTens()) src << "Simulation created"

	var/mob/Splitform/A=Get_cached_splitform()
	A.Mode="Attack Target"
	A.Maker=src
	A.Sim_ID=displaykey

	A.BP=BP

	if(A.BP<1) A.BP=1
	if(A.BP>Sim.Max_BP) A.BP=Sim.Max_BP
	A.Race=Race
	A.Warp=0
	A.KB_On=0
	if(icon) A.icon=icon-rgb(0,0,0,125)
	A.Zanzoken=Zanzoken
	A.max_ki=max_ki
	A.Eff=Eff
	A.Ki=A.max_ki
	A.Pow=Pow
	A.Str=Str*sim_str
	A.Spd=Spd
	A.End=End*sim_dura
	A.Res=Res*sim_dura
	A.Off=Off
	A.Def=Def
	A.formod=formod
	A.strmod=strmod
	A.spdmod=spdmod
	A.endmod=endmod
	A.resmod=resmod
	A.offmod=offmod
	A.defmod=defmod
	A.gravity_mastered=gravity_mastered
	A.SafeTeleport(T)
	A.dir=get_dir(A,usr)
	//A.overlays.Add(overlays)
	A.name="Simulation [Commas(A.BP)] BP"
	A.Target=src
	A.Sim_Loop()

mob/proc/Sim_Loop()
	set waitfor=0
	while(src)
		if(!Target || getdist(src,Target)>30 || Target.z!=z) del(src)
		else
			if(Target.Health<=20)
				player_view(15,src)<<"[src] terminates because [Target] has low health"
				del(src)
			if(Target.regenerator_obj)
				if(Target.IsTens()) Target << "Simulation deleted because Target has regenerator_obj"
				del(src)
		sleep(10)
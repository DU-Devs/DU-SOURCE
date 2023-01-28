mob/var/tmp/mob/Maker

var/list/splitform_cache=new
var/list/all_splitforms=new

proc/Get_cached_splitform()
	for(var/mob/m in splitform_cache)
		Reset_vars(m)
		splitform_cache-=m
		return m
	return new/mob/Splitform

mob/Splitform
	Has_DNA=0
	brain_transplant_allowed=0
	var/Mode
	var/Sim_ID
	New()

		all_splitforms+=src

		Attack_Loop()
		Death_Loop()
		BP_Loop()
		Target_Loop()
		Follow_Loop()
		Fly_Check()
		Auto_Attack_Enemy()
		Sim_Destroy_Loop()
	proc/Auto_Attack_Enemy() spawn while(src&&!Sim_ID&&Maker)
		if(Maker.Opponent&&Maker.attacking&&Maker.Opponent.Maker!=Maker)
			Target=Maker.Opponent
			Mode="Attack Target"
		sleep(50)
	proc/Fly_Check() spawn while(src)
		if(Target)
			if(Target.Flying&&!Flying) Fly()
			else if(!Target.Flying&&Flying) Land()
		else if(Flying) Land()
		sleep(10)
	proc/BP_Loop() spawn while(src)
		if(Maker&&!Sim_ID) BP=Maker.BP
		sleep(10)
	proc/Attack_Loop() spawn while(src)
		if(Mode in list("Attack Target","Attack Nearest"))
			if(Target&&!Target.KO&&Target.z==z&&(Target in Get_step(src,dir))) Melee(Target)
			sleep(To_tick_lag_multiple(1.5))
		else sleep(10)
	proc/Death_Loop() spawn(10) while(src)
		if(KO||!Maker) del(src)
		sleep(10)
	proc/Target_Loop() spawn while(src)
		if(Target&&(Mode=="Attack Target"||Mode=="Attack Nearest"))
			if(Mode=="Attack Nearest") for(var/mob/P in player_view(20,src)) if(P!=src&&!P.KO&&P!=Maker)
				Target=P
				break
			if(Target in view(0,src)) step_away(src,Target)
			if(Target in view(1,src))
				dir=get_dir(src,Target)
				sleep(20)
			else
				if(prob(70)) step_towards(src,Target)
				else step_rand(src)
				sleep(2)
		else sleep(10)
	proc/Follow_Loop() spawn while(src)
		if(Mode=="Follow")
			if(Maker&&!(Maker in view(1,src)))
				if(prob(70)) step_towards(src,Maker)
				else step_rand(src)
				sleep(1)
			else sleep(10)
		else sleep(10)
	Click() if(Maker==usr)
		if(Sim_ID)
			del(src)
			return
		switch(input("Options") in list("Cancel","Attack Target","Attack Nearest","All Attack Target",\
		"All Attack Nearest","Follow","All Follow","Stop","Stop All","Destroy Splitforms"))
			if("Cancel") return
			if("Stop")
				Mode=null
				Target=null
			if("Stop All") for(var/mob/Splitform/S in usr.splitform_list)
				S.Mode=null
				S.Target=null
			if("Attack Target")
				if(usr.tournament_override()) return
				var/list/L=list("Cancel")
				for(var/mob/P in mob_view(15,usr)) if(!P.KO&&P!=src) L+=P
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
				for(var/mob/P in mob_view(15,usr)) if(!P.KO) L+=P
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
			if("Destroy Splitforms") usr.Destroy_Splitforms()
mob/proc/Destroy_Splitforms() for(var/mob/Splitform/S in splitform_list) del(S)

mob/var/tmp/list/splitform_list=new

obj/SplitForm
	teachable=1
	Skill=1
	hotbar_type="Ability"
	can_hotbar=1
	Teach_Timer=10
	Cost_To_Learn=15
	desc="This will materialize a copy of yourself, made of energy. It has much the same power as you, \
	and makes a good sparring partner or assistant in battle. You can command their actions by clicking \
	on them"
	Level=1
	var/tmp/split_timer=0
	verb/Hotbar_use()
		set hidden=1
		SplitForm()
	verb/SplitForm() if(usr&&!usr.KO)
		set category="Skills"
		var/turf/T=Get_step(usr,usr.dir)
		var/obj/Dense_Obj
		if(T) for(Dense_Obj in T) break
		if(ismob(usr.loc))
			usr<<"You can not make a splitform while body swapped"
			return
		if(!T||T.density||Dense_Obj)
			usr<<"You can not make a splitform because there are obstructions in front of you"
			return
		if(usr.Splitform_Count()>=Level)
			usr<<"You have too many active splitforms to make any more"
			return
		if(split_timer>0)
			usr<<"You must wait [split_timer] more seconds to make any more splitforms"
			return
		var/splits=1
		/*if(!usr.auto_train&&Level-usr.Splitform_Count()>1)
			splits=input(usr,"How many? Max of [Level-usr.Splitform_Count()]","options",1) as num
			if(!splits) return
			splits=round(splits)
			if(splits>Level-usr.Splitform_Count()) splits=Level-usr.Splitform_Count()
			if(splits<1) splits=1*/
		split_timer=4
		spawn while(split_timer)
			split_timer--
			sleep(10)
		if(usr.Splitform_Count()>splits) return
		for(var/v in 1 to splits)
			if(prob(10/(Level**2))&&Level<4)
				usr<<"Your split form skill has increased."
				Level++
				if(Level>4)
					Level=4
					usr<<"Your splitform count is capped at [Level]"
			var/mob/Splitform/A=Get_cached_splitform()
			usr.splitform_list+=A

			//stop splits wandering off when ai training creates them
			A.Mode=null
			A.Target=null

			A.Maker=usr
			A.displaykey=usr.displaykey
			A.Race=usr.Race
			A.Warp=usr.Warp

			A.KB_On=usr.KB_On
			if(usr.auto_train) A.KB_On=0

			A.icon=usr.icon
			if(usr.Race=="Bio-Android")
				A.icon='Bio3.dmi'
				A.Enlarge_Icon(24,24)
				Center_Icon(A)
				A.pixel_y=0
			A.Zanzoken=usr.Zanzoken
			A.max_ki=usr.max_ki
			A.Eff=usr.Eff
			A.Ki=A.max_ki
			A.Pow=usr.Pow
			A.Str=usr.Str
			A.Spd=usr.Spd
			A.End=usr.End
			A.Res=usr.Res
			A.Off=usr.Off
			A.Def=usr.Def
			A.offmod=usr.offmod
			A.defmod=usr.defmod
			A.gravity_mastered=usr.gravity_mastered
			A.loc=T
			A.dir=turn(usr.dir,180)
			A.overlays.Add(usr.overlays)
			var/copies=0
			for(var/mob/Splitform/B in usr.splitform_list) copies+=1
			A.name="[usr.name] Copy [copies]"
			A.screen_loc="[copies],1:0"
			//A.screen_loc="[copies+1],2"
			if(usr&&usr.client) usr.client.screen.Add(A)
			A.BP=usr.BP
mob/proc/Sim_Destroy_Loop() spawn(10)
	while(Maker&&!Maker.KO) sleep(20)
	del(src)
obj/items/Simulator
	icon='Lab.dmi'
	Can_Drop_With_Suffix=1
	icon_state="terminal"
	Stealable=1
	era_reset_immune=0
	density=1
	Cost=15000
	var/Max_BP=100
	desc="This can create holographic simulations which can be sparred with to enhance training. Click it to \
	bring up the options menu. This is less convenient than splitforms, but they take 3x more damage \
	than splitforms but do only 0.35x damage to you. Making them better and longer training for most \
	people."
	takes_gradual_damage=1
	verb/Upgrade_health()
		set name="Repair/Upgrade health"
		set src in view(1)
		if(usr in view(1,src))
			var/max_health=usr.Knowledge*usr.Intelligence
			if(Health<max_health)
				player_view(15,usr)<<"[usr] repairs/upgrades the [src]'s health to [Commas(max_health)] BP"
				Health=max_health
			else usr<<"The [src] is beyond your upgrading abilities"
	verb/Bolt()
		set src in oview(1)
		usr.Bolt(src)
	verb/Hotbar_use()
		set hidden=1
		Upgrade()
	verb/Upgrade()
		set src in view(1)
		if(usr in view(1,src))
			var/Max_Upgrade=usr.Knowledge*2*sqrt(usr.Intelligence)
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
		m.Make_Simulated_Fighter(src,sim_str=0.15,sim_dura=6)
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
		if((src in oview(1,usr))||(src in usr))
			Create_simulated_fighter(usr)
		else usr<<"You must be near this to use it"

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
	A.loc=T
	A.dir=get_dir(A,usr)
	//A.overlays.Add(overlays)
	A.name="Simulation [Commas(A.BP)] BP"
	A.Target=src
	A.Sim_Loop()
mob/proc/Sim_Loop() spawn while(src)
	if(!Target) del(src)
	else if(Target.Health<=20)
		player_view(15,src)<<"[src] terminates because [Target] has low health"
		del(src)
	sleep(10)
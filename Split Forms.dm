mob/var/tmp/mob/Maker
mob/Splitform
	var/Mode
	var/Sim_ID
	New()
		Attack_Loop()
		Death_Loop()
		BP_Loop()
		Target_Loop()
		Follow_Loop()
		Fly_Check()
		Auto_Attack_Enemy()
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
			if(Target&&!Target.KO) Melee(Target)
			sleep(1)
		else sleep(10)
	proc/Death_Loop() spawn while(src)
		if(KO||!Maker) del(src)
		sleep(5)
	proc/Target_Loop() spawn while(src)
		if(Target&&(Mode=="Attack Target"||Mode=="Attack Nearest"))
			if(Mode=="Attack Nearest") for(var/mob/P in view(src)) if(P!=src&&!P.KO&&P!=Maker)
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
			if("Stop All") for(var/mob/Splitform/S in usr.client.screen)
				S.Mode=null
				S.Target=null
			if("Attack Target")
				if((usr in All_Entrants)&&!usr.Is_Fighter())
					usr<<"You can not attack until it is your turn"
					return
				var/list/L=list("Cancel")
				for(var/mob/P in view(usr)) if(!P.KO&&P!=src) L+=P
				var/mob/P=input("Choose Target") in L
				if(!P||P=="Cancel") return
				Target=P
				Mode="Attack Target"
			if("Attack Nearest")
				if(usr in All_Entrants)
					usr<<"You can only select specific targets in a tournament"
					return
				Mode="Attack Nearest"
			if("All Attack Target")
				if((usr in All_Entrants)&&!usr.Is_Fighter())
					usr<<"You can not attack until it is your turn"
					return
				var/list/L=list("Cancel")
				for(var/mob/P in view(usr)) if(!P.KO) L+=P
				var/mob/P=input("Choose Target") in L
				if(!P||P=="Cancel") return
				for(var/mob/Splitform/S in usr.client.screen)
					S.Target=P
					S.Mode="Attack Target"
			if("All Attack Nearest")
				if(usr in All_Entrants)
					usr<<"You can only select specific targets in a tournament"
					return
				for(var/mob/Splitform/S in usr.client.screen) S.Mode="Attack Nearest"
			if("Follow") Mode="Follow"
			if("All Follow") for(var/mob/Splitform/S in usr.client.screen) S.Mode="Follow"
			if("Destroy Splitforms") usr.Destroy_Splitforms()
mob/proc/Destroy_Splitforms() if(client) for(var/mob/Splitform/S in client.screen) del(S)
obj/SplitForm
	teachable=1
	Skill=1
	Teach_Timer=6
	Cost_To_Learn=15
	desc="This will materialize a copy of yourself, made of energy. It has much the same power as you, \
	and makes a good sparring partner or assistant in battle. You can command their actions by clicking \
	on them"
	Level=1
	verb/SplitForm() if(usr&&!usr.KO)
		set category="Skills"
		var/turf/T=get_step(usr,usr.dir)
		var/obj/Dense_Obj
		if(T) for(Dense_Obj in T) break
		if(!T||T.density||Dense_Obj)
			usr<<"You can not make a splitform because there are obstructions in front of you"
			return
		var/Amount=0
		for(var/mob/Splitform/Z) if(Z.displaykey==usr.displaykey) Amount+=1
		if(Amount<Level)
			if(prob(10/(Level**2)))
				usr<<"Your split form skill has increased."
				Level+=1
			var/mob/Splitform/A=new
			A.Maker=usr
			A.displaykey=usr.displaykey
			A.Race=usr.Race
			A.Warp=usr.Warp
			A.KB_On=usr.KB_On
			A.icon=usr.icon
			A.Zanzoken=usr.Zanzoken
			A.Max_Ki=usr.Max_Ki
			A.Eff=usr.Eff
			A.Ki=A.Max_Ki
			A.Pow=usr.Pow
			A.Str=usr.Str
			A.Spd=usr.Spd
			A.End=usr.End
			A.Res=usr.Res
			A.Off=usr.Off
			A.Def=usr.Def
			A.OffMod=usr.OffMod
			A.DefMod=usr.DefMod
			A.Gravity_Mastered=usr.Gravity_Mastered
			A.loc=T
			A.dir=turn(usr.dir,180)
			A.overlays.Add(usr.overlays)
			var/copies=0
			for(var/mob/Splitform/B) if(B.displaykey==usr.displaykey) copies+=1
			A.name="[usr.name] Copy [copies]"
			A.screen_loc="[copies],1:0"
			usr.client.screen.Add(A)
			A.BP=usr.BP
			A.Sim_Destroy_Loop(usr)
		else usr<<"You do not have the skill to create this many splitforms."
mob/proc/Sim_Destroy_Loop(mob/P)
	while(P&&!P.KO) sleep(10)
	del(src)
obj/items/Simulator
	icon='Lab.dmi'
	Can_Drop_With_Suffix=1
	icon_state="terminal"
	Stealable=1
	density=1
	Cost=50000
	var/Max_BP=100
	desc="This can create holographic simulations which can be sparred with to enhance training. Click it to \
	bring up the options menu."
	verb/Bolt()
		set src in oview(1)
		usr.Bolt(src)
	verb/Upgrade()
		set src in view(1)
		if(usr in view(1,src))
			var/Max_Upgrade=usr.Knowledge*2*sqrt(usr.Intelligence)
			var/Percent=(Max_BP/Max_Upgrade)*100
			var/Res_Cost=1000/usr.Intelligence
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
			view(usr)<<"[usr] upgraded [src] from [Percent]% to [Amount]% ([Commas(Max_BP)] BP)"
			name="[Commas(Max_BP)] BP Simulator"
	Click()
		if((src in oview(1,usr))||(src in usr))
			switch(input("[src], BP: [Commas(Max_BP)]") in list("Cancel","Make Simulation","Destroy Simulations"))
				if("Cancel") return
				if("Make Simulation") usr.Make_Simulated_Fighter(src)
				if("Destroy Simulations") for(var/mob/Splitform/A) if(A.Sim_ID==usr.displaykey) del(A)
		else usr<<"You must be near this to use it"
mob/proc/Make_Simulated_Fighter(obj/items/Simulator/Sim)
	for(var/mob/Splitform/P) if(P.Sim_ID==displaykey) del(P)
	var/turf/T=get_step(usr,usr.dir)
	var/obj/Dense_Obj
	if(T) for(Dense_Obj in T) if(Dense_Obj.density&&Dense_Obj!=Sim) break
	if(!T||T.density||Dense_Obj)
		usr<<"You can not make a simulation because there are obstructions in front of you"
		return
	var/mob/Splitform/A=new
	A.Mode="Attack Target"
	A.Maker=usr
	A.Sim_ID=displaykey
	var/N=input(src,"Set the simulated fighter's BP. 1 to [Commas(Sim.Max_BP)]") as num
	if(!A) return
	A.BP=N
	if(A.BP<1) A.BP=1
	if(A.BP>Sim.Max_BP) A.BP=Sim.Max_BP
	spawn if(A) A.Sim_Destroy_Loop(src)
	A.Race=Race
	A.Warp=0
	A.KB_On=0
	A.icon=icon-rgb(0,0,0,125)
	A.Zanzoken=Zanzoken
	A.Max_Ki=Max_Ki
	A.Eff=Eff
	A.Ki=A.Max_Ki
	A.Pow=Pow
	A.Str=Str
	A.Spd=Spd
	A.End=End
	A.Res=Res*0.001
	A.Off=Off
	A.Def=Def
	A.PowMod=PowMod
	A.StrMod=StrMod
	A.SpdMod=SpdMod
	A.EndMod=EndMod
	A.ResMod=ResMod
	A.OffMod=OffMod
	A.DefMod=DefMod
	A.Gravity_Mastered=Gravity_Mastered
	A.loc=T
	A.dir=get_dir(A,usr)
	//A.overlays.Add(overlays)
	A.name="Simulation [Commas(A.BP)] BP"
	A.Target=src
	A.Sim_Loop()
mob/proc/Sim_Loop() spawn while(src)
	if(!Target) del(src)
	else if(Target.Health<=20)
		view(src)<<"[src] terminates because [Target] has low health"
		del(src)
	sleep(10)
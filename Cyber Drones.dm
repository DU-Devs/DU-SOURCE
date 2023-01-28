/*mob/proc/Drone_Loops()
mob/proc/Drone_Illegal_Object_Check()
mob/proc/Drone_Illegal_Action_Check()
mob/proc/Drone_Steal_From_Players()
mob/proc/Drone_Steal_From_Drills()
mob/proc/Drone_Gather_Resources_From_NPCs()
mob/proc/Drone_Assassinate()
mob/proc/Drone_Genocide_Race()
mob/proc/Drone_Abduct()
mob/proc/Drone_Assemble()

mob/proc/Drone_Attack()*/
/*
make drones not want to stay within range 15 of each other
make so a person cant move when drone AI has orders and the AI is installed on the person
make it so rebuild actually does something for drones
drones need to occassionally go into teleporters when on patrol
drones need a command to guard an object or location
optional to set drones as lethal/nonlethal
*/
mob/var/Drone_Order=0 //The number of the last order they recieved so orders do not stack
mob/var/Pkey //The key of the last person who sent the drones an order
mob/proc/Drone_Initialize()
	var/obj/Module/Drone_AI/D=Get_Drone_AI()
	if(D&&D.Commands)
		if("Gather" in D.Commands) spawn Collect_Resources(10000)
		if("Steal" in D.Commands) spawn Steal_Resources(100000)
		if("Genocide" in D.Commands) spawn Drone_Genocide(Race_to_Genocide)
		if("Assemble" in D.Commands) D.Commands-="Assemble"
		if("Patrol" in D.Commands) spawn Drone_Patrol()
	spawn Drone_Heal_Loop()
	spawn Drone_Blast_Response()
	spawn Drone_Beam_Response()
	spawn Drone_Grab_Struggle()
	spawn Drone_Attack_Gain_Loop()
	spawn Drone_Available_Power()
mob/proc/Drone_Heal_Loop() while(src)
	if(!z) return
	if(!client)
		for(var/obj/Resources/A in src) A.suffix="[Commas(A.Value)]"
		if(Health<100)
			Health+=20*Regeneration
			if(Health>100) Health=100
		if(Ki<Max_Ki)
			Ki+=Max_Ki/20*Recovery
			if(Ki>Max_Ki) Ki=Max_Ki
		sleep(rand(0,100))
	else sleep(600)
mob/proc/Drone_Blast_Response() while(src)
	if(!z) return
	if(!client)
		for(var/obj/Blast/B in view(10,src)) if(!B.Beam) if(get_dir(src,B) in list(NORTH,SOUTH,EAST,WEST))
			if(B.dir==get_dir(B,src)) if(ismob(B.Owner)&&B.Owner.client)
				step(src,turn(B.dir,pick(-90,90)))
				var/mob/P=B.Owner
				spawn if(P&&ismob(P)) Drone_Attack(P)
		sleep(rand(0,10))
	else sleep(600)
mob/proc/Drone_Beam_Response() while(src)
	if(!z) return
	if(!client)
		for(var/obj/Blast/B in view(10,src)) if(B.Beam)
			if(get_dir(src,B) in list(NORTH,SOUTH,EAST,WEST)) if(B.dir==get_dir(B,src)) if(!(B in view(2,src)))
				if(prob(50))
					step(src,turn(B.dir,pick(-90,90)))
					var/mob/P=B.Owner
					sleep(rand(0,100))
					spawn if(P&&ismob(P)) Drone_Attack(P)
				else if(ismob(B.Owner))
					dir=get_dir(src,B)
					var/mob/P=B.Owner
					var/obj/Attacks/Beam/O
					for(var/obj/Attacks/Z in P) if(Z.streaming) O=Z
					if(P&&O)
						for(var/obj/Attacks/Beam/C in src)
							if(!C.charging&&!C.streaming&&!attacking)
								Beam_Macro(C)
								sleep(rand(0,30))
								Beam_Macro(C)
								while(P&&!P.KO&&O.streaming) sleep(1)
								if(!P.KO) sleep(rand(20,30))
								Beam_Macro(C)
								sleep(rand(10,30))
								spawn if(P&&ismob(P)) Drone_Attack(P)
							break
		sleep(rand(0,20))
	else sleep(600)
mob/proc/Drone_Grab_Struggle() while(src)
	if(!z) return
	if(!client)
		var/mob/A
		if(Is_Grabbed()) for(var/mob/P in view(1,src)) if(P.GrabbedMob==src) A=P
		if(A&&!(Drone_Frequency() in A.Key_Passwords()))
			if(prob(80)) view(src)<<"[src] struggles against [A]"
			else
				view(src)<<"[src] breaks free of [A]!"
				A.GrabbedMob=null
				attacking=0
				A.attacking=0
				grabberSTR=0
		sleep(rand(0,100))
	else sleep(600)
mob/proc/Drone_Attack_Gain_Loop() while(src)
	if(!z) return
	if(!client)
		var/Amount=1
		if(Opponent) Attack_Gain(Amount)
		sleep(rand(0,Amount*20))
	else sleep(600)
mob/proc/Drone_Available_Power() while(src)
	if(!z) return
	if(!client)
		if(BPpcnt<0.01) BPpcnt=0.01
		if(Ki<0) Ki=0
		if(Age<0) Age=0
		if(Real_Age<0) Real_Age=0
		Body()
		BP=Get_Available_Power()
		sleep(rand(0,300))
	else sleep(600)
mob/proc/Drone_Retrieve(mob/P,mob/M) M<<"This feature is incomplete."
mob/proc/Drone_Attack(mob/P)
	if(!z) return
	if(Target==P) return //Prevent stacking
	Target=P
	var/Instance=Drone_Order
	if(isobj(P)) while(Instance==Drone_Order&&P&&Target==P&&(P in view(10,src)))
		if(!(P in view(1,src))) D_Step_To(P)
		else
			dir=get_dir(src,P)
			Land()
		if(P in get_step(src,dir)) Melee(P)
		sleep(1)
	if(ismob(P)) while(Instance==Drone_Order&&P&&Target==P&&P.z==z)
		if(P.Flying) Fly()
		if(!(P in view(1,src))) D_Step_To(P)
		else
			dir=get_dir(src,P)
			if(!P.Flying) Land()
		if(P in get_step(src,dir)) Melee(P)
		sleep(1)
	if(isturf(P)) while(Instance==Drone_Order&&P&&Target==P&&P.z==z)
		if(!(P in view(1,src))) D_Step_To(P)
		else
			dir=get_dir(src,P)
			Land()
		if(P==get_step(src,dir)) Melee(P)
		sleep(1)
	Target=null
mob/proc/Key_Passwords()
	var/list/L=new
	for(var/obj/items/Door_Pass/D in src) L+=D.Password
	return L
mob/proc/Master_is_Near() for(var/mob/P in view(2,src)) if(P.client&&(Drone_Frequency() in P.Key_Passwords()))
	return 1
mob/proc/D_Step_To(mob/P)
	if(!z) return
	if(!P||!Can_Move()) return
	if(Master_is_Near()) Say("Halting movement because master is near. Will resume when master leaves proximity.")
	while(Master_is_Near()) sleep(20)
	if(Flying) density=0
	var/Former_Loc=loc
	for(var/obj/O in get_step(src,dir)) if(O.density)
		Melee(O)
		break
	var/turf/T=get_step(src,dir)
	if(T&&T.density) Melee(T)
	if(prob(100)) step_towards(src,P)
	else step_rand(src)
	if(loc==Former_Loc)
		Fly()
		if(prob(100)) step_towards(src,P)
		else step_rand(src)
	if(loc==Former_Loc) G_step_to(P)
	if(Target&&(Target in view(1,src))) dir=get_dir(src,Target)
	density=1
proc/Players_at_Z(A)
	var/list/Mobs
	for(var/mob/P in Players) if(P.z==A)
		if(!Mobs) Mobs=new/list
		Mobs+=P
	return Mobs
proc/Get_Criminal(list/L,list/B)
	if(!L) return
	for(var/mob/P in L) if(P.key in B) return P
mob/proc/Detect_Illegal_Activity()
	if(!z) return
	var/obj/Cybernetics_Computer/C
	for(C in world) if(C.Password==Drone_Frequency()) break
	if(!C) return
	var/obj/Module/Drone_AI/D=Get_Drone_AI()
	for(var/T in D.Commands) if(T in list("Gather","Assemble","Genocide"))
		Say("Illegal activity ignored. Current orders override this action.")
		return
	var/mob/P=Get_Criminal(view(10,src),C.Kill_List)
	if(P)
		Say("[P] has been declared a criminal. Commencing extermination.")
		sleep(20)
		Drone_Attack(P)
	if(Illegal_Activity_Bypass()) return
	for(var/obj/O in view(10,src)) if(locate(O.type) in C.Illegals) if(O.z&&!Duplicate_Target(O))
		Say("[O]s are illegal. Commencing destruction of [O]. Do not interfere or you will be exterminated.")
		Drone_Attack(O)
	if("Turrets" in C.Illegals) for(var/obj/Turret/O in view(10,src)) if(ckey(Pkey)!=O.Builder)  if(O.z&&!Duplicate_Target(O))
		Say("Turrets are illegal. Commencing destruction. Do not interfere or you will be exterminated.")
		Drone_Attack(O)
	if("Ships/Pods" in C.Illegals) for(var/obj/Ships/O in view(10,src)) if(O.z&&!Duplicate_Target(O))
		Say("Ships and Spacepods are illegal. Commencing destruction. Do not interfere or you will be exterminated.")
		Drone_Attack(O)
	if("Doors" in C.Illegals) for(var/obj/Turfs/Door/O in view(10,src)) if(ckey(Pkey)!=O.Builder) if(O.z&&!Duplicate_Target(O))
		Say("Doors are illegal. Commencing destruction of Door. Do not interfere or you will be exterminated.")
		Drone_Attack(O)
	if("Ki Use" in C.Illegals) for(var/mob/M in view(10,src)) if(M.attacking==3&&M!=src&&M.client) if(M.z&&!Duplicate_Target(M))
		Say("[M]. Combat is illegal. You will be exterminated.")
		Drone_Attack(M)
	if("Combat" in C.Illegals) for(var/mob/M in view(10,src)) if(M.attacking&&M!=src&&M.client) if(M.z&&!Duplicate_Target(M))
		Say("[M]. Combat is illegal. You will be exterminated.")
		Drone_Attack(M)
	if("Train" in C.Illegals) for(var/mob/M in view(10,src)) if(M.Action=="Training"&&M!=src&&M.client) if(M.z&&!Duplicate_Target(M))
		Say("[M]. Training is illegal. You will be exterminated.")
		Drone_Attack(M)
	if("Meditate" in C.Illegals) for(var/mob/M in view(10,src)) if(M.Action=="Meditating"&&M!=src&&M.client) if(M.z&&!Duplicate_Target(M))
		Say("[M]. Meditating is illegal. You will be exterminated.")
		Drone_Attack(M)
mob/proc/Duplicate_Target(obj/O) for(var/mob/P in view(10,src))
	if(Drone_Frequency()==P.Drone_Frequency()&&P.Target==O) return 1
mob/proc/Illegal_Activity_Bypass() for(var/mob/P in view(10,src))
	if(P.client&&(Drone_Frequency() in P.Key_Passwords()))
		Say("Illegal activity ignored because [P] is exempt from laws.")
		return 1
mob/proc/Drone_Assemble(turf/T,mob/P)
	if(!z) return
	if(P) Pkey=P.key
	Drone_Order+=1
	Target=null
	var/Instance=Drone_Order
	while(!(T in view(5,src))&&Instance==Drone_Order)
		Target=null
		D_Step_To(T)
		sleep(2)
	Land()
proc/Online_by_Key(K) for(var/mob/P in Players) if(P.key==K) return 1
proc/Get_by_Key(K) for(var/mob/P in Players) if(P.key==K) return P
mob/proc/Collect_Resources(Max,mob/P)
	if(!z) return
	if(P) Pkey=P.key
	Drone_Order+=1
	var/Instance=Drone_Order
	var/obj/Module/Drone_AI/D=Get_Drone_AI()
	D.Commands.Remove("Gather","Steal","Genocide","Assemble","Patrol")
	if(!("Gather" in D.Commands)) D.Commands+="Gather"
	while(src&&D&&(D in src)&&D.suffix&&("Gather" in D.Commands)&&Instance==Drone_Order)
		if(!z) return
		Target=null
		if(Online_by_Key(Pkey)&&Res()>=Max)
			P=Get_by_Key(Pkey)
			Say("Objective to collect [Commas(Max)]$ completed. Returning to [P]")
			while(P&&!(P in range(4,src))&&("Gather" in D.Commands)&&Instance==Drone_Order)
				D_Step_To(P)
				sleep(2)
			if(P in range(4,src))
				Say("Objective completed")
				view(src)<<"[src] drops [Commas(Res())]$"
				var/obj/Resources/R=new(get_step(src,dir))
				R.name="[Commas(Res())]$"
				R.Value=Res()
				Alter_Res(-Res())
		else
			var/list/Stealables
			for(var/obj/Resources/R) if(R.z==z)
				if(!Stealables) Stealables=new/list
				if(Stealables.len<10) Stealables+=R
			for(var/mob/Enemy/M) if(M.z==z)
				if(!Stealables) Stealables=new/list
				if(Stealables.len<20) Stealables+=M
			if(Stealables)
				var/mob/M=pick(Stealables)
				var/Steps=500
				Fly()
				while(M&&Steps&&!(M in view(1,src))&&("Gather" in D.Commands)&&Instance==Drone_Order)
					Steps-=1
					D_Step_To(M)
					sleep(2)
				Land()
				if(Instance==Drone_Order) if(M in view(1,src))
					if(istype(M,/obj/Resources))
						view(src)<<"[src] picks up [M]"
						var/obj/Resources/Resources=M
						Alter_Res(Resources.Value)
						del(M)
					if(ismob(M))
						Drone_Attack(M)
						sleep(20)
						view(src)<<"[src] sucks up all the resource bags"
						for(var/obj/Resources/R in view(10,src))
							while(R&&R.loc!=loc&&R.z)
								step_towards(R,src)
								if(R.loc==loc)
									Alter_Res(R.Value)
									del(R)
								sleep(3)
		sleep(rand(0,600))
mob/proc/Steal_Resources(Max,mob/P)
	if(!z) return
	if(P) Pkey=P.key
	Drone_Order+=1
	var/Instance=Drone_Order
	var/obj/Module/Drone_AI/D=Get_Drone_AI()
	D.Commands.Remove("Gather","Steal","Genocide","Assemble","Patrol")
	if(!("Steal" in D.Commands)) D.Commands+="Steal"
	while(src&&D&&(D in src)&&D.suffix&&("Steal" in D.Commands)&&Instance==Drone_Order)
		if(!z) return
		Target=null
		if(Online_by_Key(Pkey)&&Res()>=Max)
			P=Get_by_Key(Pkey)
			Say("Objective to collect [Commas(Max)]$ completed. Returning to [P]")
			while(P&&!(P in range(4,src))&&("Steal" in D.Commands)&&Instance==Drone_Order)
				D_Step_To(P)
				sleep(2)
			if(P in range(4,src))
				Say("Objective completed")
				view(src)<<"[src] drops [Commas(Res())]$"
				var/obj/Resources/R=new(get_step(src,dir))
				R.name="[Commas(Res())]$"
				R.Value=Res()
				Alter_Res(-Res())
		else
			var/list/Stealables
			for(var/obj/Drill/DD) if(DD.z==z&&DD.Builder!=Pkey)
				if(!Stealables) Stealables=new/list
				if(Stealables.len<10) Stealables+=DD
			for(var/mob/M in Players) if(M.z==z&&M.Res()>0&&!(Drone_Frequency() in M.Key_Passwords()))
				if(!Stealables) Stealables=new/list
				if(Stealables.len<20) Stealables+=M
			if(Stealables)
				var/mob/M=pick(Stealables)
				var/Steps=500
				Fly()
				var/Dist=2
				if(isobj(M)) Dist=1
				while(M&&Steps&&!(M in view(Dist,src))&&("Steal" in D.Commands)&&Instance==Drone_Order)
					Steps-=1
					D_Step_To(M)
					sleep(2)
				Land()
				if(Instance==Drone_Order) if(M in view(1,src))
					if(istype(M,/obj/Drill))
						view(src)<<"[src] steals the money from [M]"
						var/obj/Drill/Drill=M
						Alter_Res(Drill.Resources)
						Drill.Resources=0
					if(ismob(M))
						var/Timer=20
						Say("[M]. Do not attempt to run. Drop your resources. We will take them in the name of [Pkey]. If you \
						attempt to run, you will be destroyed. You have [Timer] seconds to comply.")
						while(Timer&&M.Res()>0&&(M in view(5,src))&&("Steal" in D.Commands))
							Timer-=1
							sleep(10)
							if(!Timer)
								Say("Time is up. Taking [M]'s resources by force.")
								Drone_Attack(M)
						if(M.Res<=0)
							view(src)<<"[src] sucks up all the resource bags"
							for(var/obj/Resources/R in view(10,src))
								while(R&&R.loc!=loc&&R.z)
									step_towards(R,src)
									if(R.loc==loc)
										Alter_Res(R.Value)
										del(R)
									sleep(3)
							Say("[M] has complied. Objective complete. Moving to next objective...")
							Detect_Illegal_Activity()
						else if(!(M in view(5,src))&&("Steal" in D.Commands))
							Say("[M] has attempted to run. Exterminating.")
							Drone_Attack(M)
		sleep(rand(0,600))
mob/var/Race_to_Genocide
mob/proc/Drone_Genocide(R,mob/P) //R=Race to kill
	if(!z) return
	if(P) Pkey=P.key
	Race_to_Genocide=R
	Drone_Order+=1
	var/Instance=Drone_Order
	var/obj/Module/Drone_AI/D=Get_Drone_AI()
	D.Commands.Remove("Gather","Steal","Genocide","Assemble","Patrol")
	if(!("Genocide" in D.Commands)) D.Commands+="Genocide"
	while(src&&D&&(D in src)&&D.suffix&&("Genocide" in D.Commands)&&Instance==Drone_Order)
		if(!z) return
		Target=null
		var/list/Mobs=new
		for(var/mob/M in Players)
			if(M.z==z&&(M.Race==Race_to_Genocide||!Race_to_Genocide)&&!(Drone_Frequency() in M.Key_Passwords())) Mobs+=M
			if(Race_to_Genocide=="Vampires"&&M.Vampire) Mobs+=M
		if(Race_to_Genocide=="Zombies") for(var/mob/M) if(istype(M,/mob/Enemy/Zombie)&&M.z==z) Mobs+=M
		if(locate(/mob) in Mobs)
			var/mob/M=pick(Mobs)
			var/Steps=500
			Fly()
			while(M&&Steps&&!(M in view(5,src))&&Instance==Drone_Order)
				Steps-=1
				D_Step_To(M)
				sleep(2)
			Land()
			if(Instance==Drone_Order) if(ismob(M)&&(M in view(5,src)))
				Say("[M] your species has been listed for extermination. Prepare to be exterminated.")
				sleep(20)
				Drone_Attack(M)
		sleep(rand(0,600))
mob/proc/Get_Drone_AI() for(var/obj/Module/Drone_AI/M in src) if(M.suffix) return M
mob/proc/Drone_Patrol(mob/PP)
	if(!z) return
	if(PP) Pkey=PP.key
	Drone_Order+=1
	var/Instance=Drone_Order
	var/obj/Module/Drone_AI/D=Get_Drone_AI()
	if(!("Patrol" in D.Commands)) D.Commands+="Patrol"
	while(src&&D&&(D in src)&&D.suffix&&("Patrol" in D.Commands)&&Instance==Drone_Order)
		if(!z) return
		Target=null
		var/list/Mobs=Players_at_Z(z)
		if(Mobs)
			Fly()
			var/mob/P=pick(Mobs)
			var/Steps=500
			while(P&&Steps&&!(P in view(5,src)))
				Steps-=1
				D_Step_To(P)
				if(prob(5)) Detect_Illegal_Activity()
				sleep(2)
			Land()
			Detect_Illegal_Activity()
		sleep(rand(0,600))
		if(src) Detect_Illegal_Activity()
mob/proc/Cancel_Orders(mob/P)
	if(!z) return
	if(P) Pkey=P.key
	var/obj/Module/Drone_AI/D=Get_Drone_AI()
	D.Commands=new/list
	Target=null
mob/proc/Drone_Options(obj/Cybernetics_Computer/R) while(src&&R)
	if(!R.Password) R.Password=input(src,"You must set a frequency on your [R] so that it can command drones \
	which are on the same frequency. Please set it now.") as text
	var/list/Options=list("Cancel","Cancel All Orders","Guide","Kill List","Self Destruct",\
	"Gather Resources","Steal from Players/Drills","Genocide","Patrol","Assemble","Bring someone to you",\
	"Declare something illegal","Declare something legal")
	if(!Drones_On_Frequency(R.Password))
		src<<"There are no drones on frequency [R.Password]. Make one on frequency [R.Password] and then you will be \
		able to access drone options."
		return
	switch(input(src,"Drone Commands: What do you want to command drones to do?") in Options)
		if("Cancel") return
		if("Guide") Drone_Guide()
		if("Bring someone to you")
			var/list/L=Choosable_Drones("Which drone(s) do you want to order to bring someone to you?",R.Password)
			var/list/Mobs=list("Cancel")
			for(var/mob/P in Players) Mobs+=P
			var/mob/P=input(src,"Choose who the drone(s) will bring to you. They will track the person down, grab them, \
			and bring them back to you.") in Mobs
			if(!P||P=="Cancel") return
			for(var/mob/M in L) spawn if(M)
				M.Say("Order Recieved. Commencing capture of [P]")
				M.Drone_Retrieve(P,src)
		if("Assemble")
			var/list/L=Choosable_Drones("Which drones do you want to assemble at your location?",R.Password)
			var/turf/T=loc
			for(var/mob/P in L) spawn if(P)
				P.Say("Order Recieved. Assembling at location [T.x],[T.y],[T.z]")
				P.Drone_Assemble(T,src)
		if("Patrol")
			var/list/L=Choosable_Drones("Which drones do you want to send on patrol? This will cause them to locate \
			life forms on the planet, and go check out what they are doing. This is a good way for drones to spot \
			illegal activities and such.",R.Password)
			for(var/mob/P in L) spawn if(P)
				P.Say("Commencing Patrol")
				P.Drone_Patrol(src)
		if("Cancel All Orders")
			var/list/L=Choosable_Drones("Which drones will have their orders cancelled? This will just make them \
			stop trying to accomplish their current goal, and just stay where they are, doing nothing.",R.Password)
			for(var/mob/P in L) spawn if(P)
				P.Say("Stand-down orders recieved.")
				P.Cancel_Orders(src)
		if("Kill List")
			var/obj/Cybernetics_Computer/C
			for(C in world) if(C.Password==R.Password) break
			if(!C)
				src<<"To use this you must have a Cybernetics Computer set to the same frequency as the [R]. Because \
				the Cybernetics Computer is what the Kill List is actually stored on, and you are merely accessing it \
				remotely. That is why they must share the same frequency. No Cybernetics Computer was found using \
				this [R]'s frequency."
				return
			switch(input(src,"Do you want to add or remove a person from the Kill List?") in list("Cancel","Add","Remove"))
				if("Cancel") return
				if("Add")
					var/list/Mobs=list("Cancel")
					for(var/mob/P in Players) Mobs+=P
					var/mob/M=input(src,"Who do you want to add to the kill list?") in Mobs
					if(M=="Cancel"||!M) return
					src<<"[C]: [M.key] added to the kill list"
					C.Kill_List+=M.key
				if("Remove")
					var/list/Mobs=list("Cancel")
					for(var/P in C.Kill_List) Mobs+=P
					var/M=input(src,"Who's key do you want to remove from the kill list?") in Mobs
					src<<"[C]: [M] removed from kill list"
					C.Kill_List-=M
		if("Declare something illegal")
			var/obj/Cybernetics_Computer/C
			for(C in world) if(C.Password==R.Password) break
			if(!C)
				src<<"To use this you must have a Cybernetics Computer set to the same frequency as the [R]. Because \
				the Cybernetics Computer is what this is actually stored on, and you are merely accessing it \
				remotely. That is why they must share the same frequency. No Cybernetics Computer was found using \
				this [R]'s frequency."
				return
			while(src&&R&&C)
				var/list/L=list("Cancel")
				if(!("Doors" in C.Illegals)) L+="Doors"
				if(!("Training" in C.Illegals)) L+="Training"
				if(!("Meditating" in C.Illegals)) L+="Meditating"
				if(!("Combat" in C.Illegals)) L+="Combat"
				if(!("Ki Use" in C.Illegals)) L+="Ki Use"
				if(!("Ships/Pods" in C.Illegals)) L+="Ships/Pods"
				if(!("Turrets" in C.Illegals)) L+="Turrets"
				for(var/obj/O) if(!(locate(O.type) in L)&&!(locate(O.type) in C.Illegals)) if(O.Cost)
					if(!istype(O,/obj/Turret)) L+=O
				var/obj/A=input(src,"[C]: What do you want to make illegal? This will be stored in the [R] hard drive. \
				Drones set to the same frequency as the [C] will use this data stored on the [C] to decide what is illegal \
				or not.") in L
				if(!A||A=="Cancel") return
				if(isobj(A)) C.Illegals+=new A.type
				else C.Illegals+=A
		if("Declare something legal")
			var/obj/Cybernetics_Computer/C
			for(C in world) if(C.Password==R.Password) break
			if(!C)
				src<<"To use this you must have a Cybernetics Computer set to the same frequency as the [R]. Because \
				the Cybernetics Computer is what this is actually stored on, and you are merely accessing it \
				remotely. That is why they must share the same frequency. No Cybernetics Computer was found using \
				this [R]'s frequency."
				return
			var/Something
			for(Something in C.Illegals) break
			if(!Something)
				src<<"Something must first be declared illegal before it can be made legal again."
				return
			while(src&&R&&C)
				var/list/L=list("Cancel")
				for(var/A in C.Illegals) L+=A
				var/A=input(src,"What do you want to remove from the [C]'s illegal activities list? Drones will no longer \
				go after people doing these activities if you remove this from the illegal list on the [C]'s hard drive") \
				in L
				if(!A||A=="Cancel") return
				view(C)<<"[C]: [src] has removed [A] from the illegal activities list"
				C.Illegals-=A
		if("Genocide")
			var/list/L=Choosable_Drones("Drone Genocide Options",R.Password)
			var/list/O=list("Cancel","All Races","Vampires","Zombies")
			for(var/A in Race_List()) O+=A
			var/Race_to_kill=input(src,"Which race do you want the drone to kill?") in O
			if(Race_to_kill=="Cancel") return
			var/Msg="Drones set to kill all [Race_to_kill]s"
			if(Race_to_kill=="All Races")
				Msg="Drones set to kill all life forms"
				Race_to_kill=null
			src<<Msg
			for(var/mob/P in L) spawn if(P)
				P.Say(Msg)
				P.Drone_Genocide(Race_to_kill,src)
		if("Self Destruct")
			var/list/L=Choosable_Drones("Drone Self Destruct Options",R.Password)
			src<<"Self destruct signal sent to [Mob_Count(L)] Drones"
			for(var/mob/P in L)
				spawn if(P&&P.z) P.Drone_Self_Destruct()
				sleep(10)
		if("Gather Resources")
			var/list/L=Choosable_Drones("Which drones will be set to gather resources?",R.Password)
			var/Max=input(src,"How many resources should each drone gather before returning to you?") as num
			for(var/mob/P in L) spawn if(P)
				P.Say("Order recieved. Gathering resources.")
				P.Collect_Resources(Max,src)
		if("Steal from Players/Drills")
			var/list/L=Choosable_Drones("Which drones will be set to steal resources from players/drills?",R.Password)
			var/Max=input(src,"How many resources should each drone gather before returning to you?") as num
			for(var/mob/P in L) spawn if(P)
				P.Say("Order recieved. Taking resources from drills and players.")
				P.Steal_Resources(Max,src)
mob/proc/Drone_Self_Destruct()
	Disable_Modules()
	Death("drone self destruct signal from [src]")
mob/proc/Choosable_Drones(M="Drone Options",F)
	var/list/L
	switch(input(src,"[M]") in list("Cancel","In front of you","All in view","All Drones"))
		if("Cancel") return
		if("In front of you") L=Get_Drones(get_step(src,dir),F)
		if("All in view") L=Get_Drones(view(10,src),F)
		if("All Drones") L=Get_Drones(world,F)
	return L
proc/Mob_Count(list/L)
	var/Amount=0
	for(var/mob/P in L) Amount+=1
	return Amount
mob/proc/Drone_Frequency() for(var/obj/Module/Drone_AI/M in src) if(M.suffix) return M.Password
mob/proc/Drones_On_Frequency(F) for(var/obj/Module/Drone_AI/M) if(M.suffix&&M.Password==F) return 1
proc/Get_Drones(list/L,F)
	var/list/Drones=new
	for(var/mob/P in L) if(P.Drone_Frequency()&&P.Drone_Frequency()==F) Drones+=P
	return Drones
mob/proc/Drone_Guide() src<<browse(Drone_Guide,"window= ;size=700x600")
var/Drone_Guide={"<html><head><body><body bgcolor="#000000"><font size=5><font color="#CCCCCC">

This guide will tell you what does what with drones.<p>

Drones are anything that has a Drone AI cybernetic module installed in them. The Drone AI module allows them
to recieve orders. Drone AI modules must be set to the same frequency as your Robotics Tools and/or your
Cybernetic Computer, that way the Robotics Tools and Cybernetic Computer can send signals to your Drone, and
vice versa.<p>

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
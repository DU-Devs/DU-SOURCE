mob/proc/Activate_NPCs_Loop() spawn if(src)
	var/turf/former_loc=loc
	while(src)
		if(former_loc!=loc&&client&&client.inactivity<300) Activate_NPCs()
		former_loc=loc
		sleep(100)
mob/proc/Activate_NPCs(Distance=50) for(var/mob/Enemy/M in Inactive_NPCs)
	if(M.z==z&&get_dist(src,M)<35&&!M.NPC_Activated)
		M.Activate_NPC()
		sleep(1)
mob/var/tmp/NPC_Activated
var/list/Inactive_NPCs=new
mob/proc/Activate_NPC(Timer=3000) if(!NPC_Activated)
	NPC_Activated=1
	Inactive_NPCs-=src
	if(prob(100)) NPC_Roam(Timer)
	Find_Target(Timer)
	Power_Increase_Loop(Timer)
	NPC_Heal_Loop(Timer)
	spawn(Timer) if(src)
		NPC_Activated=0
		Inactive_NPCs+=src
mob/proc/NPC_Roam(Timer=600,Delay=7) spawn if(src)
	if(!KO) dir=pick(NORTH,SOUTH,EAST,WEST,NORTHWEST,NORTHEAST,SOUTHWEST,SOUTHEAST)
	Land()
	if(!KO&&Flyer&&!Flying) Fly()
	var/turf/Last_Loc
	for(var/I in 0 to round(Timer/Delay))
		if(!Target)
			if(!KO&&On_Water(src)&&!Flying) Fly()
			step(src,dir)
			if(prob(5)||loc==Last_Loc) dir=pick(turn(dir,45),turn(dir,-45))
			Last_Loc=loc
		sleep(Delay)
mob/proc/Find_Target(Timer=600,Delay=20) spawn if(src)
	for(var/I in 0 to round(Timer/Delay))
		if(!Target)
			for(var/mob/P in view(7,src)) if(P.client) if(get_dir(src,P) in list(dir,turn(dir,45),turn(dir,-45)))
				Attack_Target(P)
				break
		sleep(Delay)
mob/proc/Attack_Target(mob/P) spawn if(src)
	var/mob/Former_Target=Target
	if(P) Target=P
	if(Former_Target) return
	var/Delay=5
	while(src&&Target&&(Target in view(12,src))&&!Target.KO)
		if(!(Target in view(1,src)))
			var/turf/T=get_step(src,get_dir(src,Target))
			if(T&&!T.Enter(src)&&Can_Pathfind())
				G_step_to(Target)
				Delay=25
			else
				step_towards(src,Target)
				Delay=5
		else if(!KO)
			dir=get_dir(src,Target)
			Bump(Target)
		if((Target&&Target.Flying&&!Flying)||On_Water(src)) if(!KO) Fly()
		else if(!Target||(!Target.Flying&&Flying)) Land()
		if(Target&&Target.KO) step_away(src,Target)
		sleep(Delay)
	Target=null
	Docile=initial(Docile)
	if(Flying) Land()
mob/proc/Can_Pathfind(N=1)
	for(var/mob/Enemy/E in view(4,src)) if(E!=src&&E.Target==Target) N++
	if(prob(100/N)) return 1
mob/proc/Power_Increase_Loop(Timer=600,Delay=100) spawn if(src)

	if(!istype(src,/mob/Enemy/Zombie)) return

	for(var/I in 0 to round(Timer/Delay))
		if(!KO) for(var/mob/P in view(7,src)) if(P.client) Attack_Gain(1,P)
		sleep(Delay)
mob/proc/NPC_Heal_Loop(Timer=600,Delay=50) spawn if(src)
	for(var/I in 0 to round(Timer/Delay))
		if(Health<100)
			Health+=1*Regeneration*(Delay/10)
			if(Health>100) Health=100
		if(Ki<Max_Ki) Ki=Max_Ki
		BP=Get_Available_Power()
		sleep(Delay)
proc/On_Water(mob/M)
	var/turf/T=M.loc
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
mob/Admin3/verb/NPCs()
	NPC_Can_Respawn=0
	NPC_Leave_Body=0
	for(var/mob/Enemy/E) if(!istype(E,/mob/Enemy/Zombie)) del(E)
	for(var/mob/Body/B) if(!B.displaykey) del(B)
	NPC_Leave_Body=1
mob/var/Flying
mob/Bump(mob/A)
	//if(ismob(A)) Pixel_Align(A)
	if(istype(A,/obj/Final_Realm_Portal))
		loc=locate(rand(163,173),rand(183,193),5)
		return
	if(istype(A,/obj/Warper))
		var/obj/Warper/B=A
		loc=locate(B.gotox,B.gotoy,B.gotoz)
	if(client&&istype(A,/obj/Turfs/Door))
		var/obj/Turfs/Door/B=A
		for(var/obj/items/Door_Pass/D in src) if(D.Password==B.Password)
			B.Open()
			return
		for(var/obj/items/Door_Hacker/D in src) if(D.BP>=B.Health)
			view(B)<<"[src] hacks the door and it opens"
			B.Open()
			return
		if(B.Password)
			var/Guess=input(src,"You must know the password to enter here") as text
			if(B) if(Guess!=B.Password) return
		if(B) B.Open()
	if(istype(A,/obj/Ships/Ship))
		var/obj/Ships/Ship/B=A
		for(var/obj/Controls/C) if(C.Ship==B.Ship)
			view(src)<<"[src] enters the [A]"
			if(!B.Last_Entry) src<<"<font color=yellow>Computer: Welcome. You are the first one to enter this ship."
			else if(Year-B.Last_Entry>=1) src<<"<font color=yellow>Computer: Welcome, you are the first person to enter this \
			ship in the past [round(Year-B.Last_Entry,0.1)] years"
			B.Last_Entry=Year
			loc=locate(C.x,C.y-1,C.z)
	if(ismob(A))
		if(type==/mob/Splitform) if(!A.KO) Melee(A)
		else if(!client||icon=='Oozbody.dmi') if(!Docile||Health<100) if(type!=/mob/Troll||type!=/mob/new_troll)
			if(!(istype(src,/mob/Enemy)&&istype(A,/mob/Enemy)))
				Melee(A)
				//if(A&&istype(src,/mob/Enemy)&&A.KO&&prob(1)) spawn A.Death(src)
		else if(client&&Flying&&dir==A.dir) loc=A.loc
	if(istype(A,/obj/Planets)) Bump_Planet(A,src)
	if(!client&&isobj(A)) Melee(A)
	if(!client&&isturf(A)&&A.density) Melee(A)
	if(istype(A,/obj/Controls))
		var/obj/Controls/C=A
		C.Ship_Options(src)
	if(isturf(A)) for(var/obj/Controls/C in A) C.Ship_Options(src)
mob/var/Enlarged
mob/New()
	Set_Spawn_Point(src)
	..()
mob/Enemy
	move=1
	Spawn_Timer=300
	Max_Ki=60 //multiplies by Eff of npc in New()
	Ki=60
	var/Enlargement_Chance=10
	New()
		Inactive_NPCs+=src
		spawn if(src&&z)
			Raise_Speed(3)
			Raise_Offense(7)
			Raise_Regeneration(6)
			Raise_Energy(6)
			Str=50*StrMod
			End=200*EndMod
			Pow=50*PowMod
			Res=50*ResMod
			Spd=100*SpdMod
			Off=500*OffMod
			Def=20*DefMod
			Max_Ki*=Eff
			Ki=Max_Ki
			Off*=OffMod
			Def*=DefMod
			var/obj/Resources/B=new(src)
			B.Value=rand(0,300)
			if(prob(20)) B.Value*=10
			BP*=0.01*rand(80,120)
			Gravity_Update()
			BP*=Gravity
		..()
	Del()
		if(!NPC_Can_Respawn) Spawn_Timer=0
		if(NPC_Leave_Body) Leave_Body()
		..()
	Spider_Small
		icon='Spider Small.dmi'
		BP=10
		Off=10000
		End=1
		Res=1
		Def=1
	Squirrel
		icon='NPC Squirrel.dmi'
		Docile=1
		BP=1
		Off=10
		Def=10
	Spider3
		icon='NPC Spider 3.dmi'
		BP=20
		Off=80
		Def=60
		Enlargement_Chance=20
	Spider2
		icon='NPC Spider 2.dmi'
		BP=10
		Off=40
		Def=30
		Enlargement_Chance=20
	Spider1
		icon='NPC Spider.dmi'
		BP=5
		Off=20
		Def=15
	Big_Scorpion
		icon='NPC Scorpion 2.dmi'
		BP=20
		Off=45
		Def=60
		Enlargement_Chance=20
	Red_Scorpion
		icon='NPC Scorpion.dmi'
		BP=10
		Off=15
		Def=20
	Reptilian
		icon='NPC Reptile Monster.dmi'
		BP=15
		Off=100
		Def=1
		Enlargement_Chance=20
	Chicken
		icon='NPC Chicken.dmi'
		Docile=1
		BP=1
		Off=10
		Def=10
	Dragon1
		name="Dragon"
		icon='NPC Dragon 1.dmi'
		BP=150
		Off=120
		Def=120
		Enlargement_Chance=20
	Ground_Dragon
		icon='NPC Dragon 2.dmi'
		Docile=1
		BP=5
		Off=15
		Def=15
		Enlargement_Chance=20
	Skeleton_Captain
		icon='NPC Skeleton.dmi'
		BP=9
		Off=30
		Def=30
	Giant_Snake
		icon='NPC Snake.dmi'
		BP=12
		Off=50
		Def=15
		Enlargement_Chance=20
	Virus_Android
		icon='NPC Virus Android.dmi'
		BP=30
		Off=15
		Def=15
	Little_Demon
		icon='NPC Little Demon.dmi'
		BP=1
		Off=15
		Def=15
	Dino_Munky
		name="Dino Munky"
		icon='Oozarou.dmi'
		icon_state="Dino Munky"
		BP=6
		Off=10
		Def=10
		Enlargement_Chance=20
	Robot
		Race="Robot"
		icon='Gochekbots.dmi'
		Docile=1
		icon_state="3"
		BP=8
		Off=30
		Def=30
	Big_Robot
		Race="Robot"
		icon='Gochekbots.dmi'
		icon_state="4"
		BP=17
		Off=50
		Def=50
	Hover_Robot
		Race="Robot"
		icon='Gochekbots.dmi'
		Docile=1
		Flyer=1
		icon_state="5"
		BP=4
		Off=80
		Def=80
		Enlargement_Chance=0
	Gremlin
		Race="Gremlin!"
		icon='GochekMonster.dmi'
		icon_state="1"
		BP=2
		Off=20
		Def=20
	Saibaman
		Race="Saibaman"
		icon='Saibaman.dmi'
		BP=120
		Off=50
		Def=50
	Small_Saibaman
		Race="Saibaman"
		icon='Small Saiba.dmi'
		BP=15
		Off=25
		Def=25
	Black_Saibaman
		Race="Saibaman"
		icon='Black Saiba.dmi'
		BP=240
		Off=60
		Def=60
	Mutated_Saibaman
		Race="Saibaman"
		icon='Green Saibaman.dmi'
		BP=120
		Off=80
		Def=80
	Evil_Entity
		Race="???"
		icon='Evil Man.dmi'
		BP=50
		Off=100
		Def=100
	Bandit
		Race="Human"
		icon='New Tan Male.dmi'
		BP=3
		Off=10
		Def=10
	Tiger_Bandit
		Race="Tiger Man"
		icon='Tiger Man.dmi'
		BP=4
		Off=20
		Def=20
	Night_Wolf
		Race="Night Wolf"
		icon='Wolf.dmi'
		Docile=1
		BP=6
		Off=20
		Def=20
	Giant_Robot
		Race="Robot"
		icon='Giant Robot 2.dmi'
		BP=200
		Off=50
		Def=50
	Ice_Dragon
		Race="Robot"
		icon='Ice Robot.dmi'
		BP=300
		Off=100
		Def=100
		Enlargement_Chance=20
	Ice_Flame
		Race="Creature"
		icon='Ice Monster.dmi'
		BP=300
		Off=200
		Def=50
	Frog
		icon='Animal, Frog.dmi'
		Docile=1
		BP=2
		Off=5
		Def=5
	Sheep
		icon='NPC Sheep.dmi'
		Docile=1
		BP=2
		Off=10
		Def=10
	Dino_Bird
		icon='Animal DinoBird.dmi'
		Docile=1
		BP=2
		Off=10
		Def=10
	Cat
		icon='Cat.dmi'
		Docile=1
		BP=5
		Off=20
		Def=20
		New()
			spawn if(src) Cat_Actions()
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
		BP=1
		Off=20
		Def=20
	Cow
		icon='Animal Cow.dmi'
		Docile=1
		BP=2
		Off=5
		Def=5
	Turtle
		icon='Turtle.dmi'
		Docile=1
		BP=100
		Off=200
		Def=200
		Del()
			var/obj/items/Weights/A=new
			A.icon='Turtle Shell.dmi'
			A.loc=loc
			A.dir=NORTH
			..()
mob/Del()
	//if(prompt) del(prompt)
	for(var/obj/items/Lizard_Sphere/A in src) A.loc=loc
	Target=null
	//if(!key) Body_Parts()
	Respawn_NPC(src)
	..()
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
		view(10,src)<<"<font color=red>Captain: What happen?!"
		sleep(rand(10,40))
		view(10,src)<<"<font color=teal>Mechanic: Somebody set us up the bomb!"
		sleep(rand(10,40))
		view(10,src)<<"<font color=yellow>Operator: We get signal!"
		sleep(rand(10,40))
		view(10,src)<<"<font color=red>Captain: What?!"
		sleep(rand(10,40))
		view(10,src)<<"<font color=yellow>Operator: Main screen turn on!"
		sleep(rand(10,40))
		view(10,src)<<"<font color=red>Captain: It's you!"
		sleep(rand(10,40))
		view(10,src)<<"<font color=green>CATS: How are you gentleman?"
		sleep(rand(10,40))
		view(10,src)<<"<font color=green>CATS: All your base are belong to us!"
		sleep(rand(10,40))
		view(10,src)<<"<font color=green>CATS: You are on the way to destruction."
		sleep(rand(10,40))
		view(10,src)<<"<font color=red>Captain: What you say?!"
		sleep(rand(10,40))
		view(10,src)<<"<font color=green>CATS: You have no chance to survive make your time."
		sleep(rand(10,40))
		view(10,src)<<"<font color=green>CATS: Ha Ha Ha Ha ..."
		sleep(rand(10,40))
		view(10,src)<<"<font color=yellow>Operator: Captain!!"
		sleep(rand(10,40))
		view(10,src)<<"<font color=red>Captain: Take off every 'ZIG'!"
		sleep(rand(10,40))
		view(10,src)<<"<font color=red>Captain: You know what you doing."
		sleep(rand(10,40))
		view(10,src)<<"<font color=red>Captain: Move 'ZIG'! For great justice!"
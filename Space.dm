obj/var/Can_Move=1
atom/var/takes_gradual_damage
mob/Admin2/verb/Planets()
	for(var/obj/Planets/P) if(!(P in Make_List)) src<<"[P] exists ([P.x], [P.y], [P.z])"
obj/Planets
	icon='AWESOME PLANETS.dmi'
	Dead_Zone_Immune=1
	Givable=0
	density=1
	var/Planet_X
	var/Planet_Y
	var/Planet_Z
	Savable=0
	Grabbable=0
	Knockable=0
	Health=1.#INF
	var/Nav_Level=0
	Spawn_Timer=6000
	Earth
		icon_state="Earth"
		Planet_Z=1
		Nav_Level=300000000
		var/Cloaked
		New()
			Center_Icon(src)
			spawn(100) if(!Earth) del(src)
			walk_rand(src,50)
			//for(var/obj/Planets/P) if(P!=src&&P.type==type) del(P)
			..()
			/*if(!Cloaked)
				Cloaked=1
				contents+=new/obj/items/Cloak
				invisibility=1*/
	Puran
		icon_state="Namek"
		Planet_Z=3
		Nav_Level=100000000
		New()
			Center_Icon(src)
			spawn(100) if(!Puran) del(src)
			walk_rand(src,100)
			//for(var/obj/Planets/P) if(P!=src&&P.type==type) del(P)
			..()
	Braal
		icon_state="Vegeta"
		Planet_Z=4
		Nav_Level=0
		New()
			Center_Icon(src)
			spawn(100) if(!Braal) del(src)
			walk_rand(src,100)
			//for(var/obj/Planets/P) if(P!=src&&P.type==type) del(P)
			..()
	Arconia
		icon_state="Arconia"
		Planet_Z=8
		Nav_Level=500000
		New()
			Center_Icon(src)
			spawn(100) if(!Arconia) del(src)
			walk_rand(src,100)
			//for(var/obj/Planets/P) if(P!=src&&P.type==type) del(P)
			..()
	Ice
		icon_state="Ice"
		Planet_Z=12
		Nav_Level=0
		New()
			Center_Icon(src)
			spawn(100) if(!Ice) del(src)
			walk_rand(src,100)
			//for(var/obj/Planets/P) if(P!=src&&P.type==type) del(P)
			..()
	Desert
		icon_state="Desert"
		Planet_X=120
		Planet_Y=170
		Planet_Z=14
		Nav_Level=100000
		New()
			Center_Icon(src)
			spawn(100) if(!Desert) del(src)
			walk_rand(src,100)
			//for(var/obj/Planets/P) if(P!=src&&P.type==type) del(P)
			..()
	Jungle
		icon_state="Jungle"
		Planet_X=220
		Planet_Y=280
		Planet_Z=14
		Nav_Level=100000
		New()
			Center_Icon(src)
			spawn(100) if(!Jungle) del(src)
			walk_rand(src,100)
			//for(var/obj/Planets/P) if(P!=src&&P.type==type) del(P)
			..()
	Android
		icon='Planets.dmi'
		icon_state="Android"
		Planet_X=290
		Planet_Y=270
		Planet_Z=14
		Nav_Level=3000000
		New()
			Center_Icon(src)
			spawn(100) if(!Android) del(src)
			walk_rand(src,100)
			//for(var/obj/Planets/P) if(P!=src&&P.type==type) del(P)
			..()
proc/Bump_Planet(obj/Planets/Planet,obj/Ships/Bumper)
	if(!Planet.Planet_X) Bumper.loc=locate(rand(1,500),rand(1,500),Planet.Planet_Z)
	else Bumper.loc=locate(Planet.Planet_X+rand(-10,10),Planet.Planet_Y+rand(-10,10),Planet.Planet_Z)
	if(istype(Bumper,/obj/Ships)) if(Bumper.Nav) if(!Bumper.Planets.Find(Planet.name))
		Bumper.Planets+=Planet.name
	new/obj/Crater(Bumper.loc)
obj/items/Spacesuit
	Cost=5000
	icon='Mask.dmi'
	name="Air Mask"
	density=0
	desc="You can survive in space if you equip this"
	Stealable=1
	Click() if(src in usr)
		if(!suffix)
			for(var/obj/items/Spacesuit/A in usr) if(A!=src&&A.suffix) return
			suffix="Equipped"
			usr.overlays+=icon
			usr<<"You put on the [src]."
			usr.Lungs+=1
		else
			suffix=null
			usr.overlays-=icon
			usr<<"You take off the [src]."
			usr.Lungs-=1
turf/var/tmp/Interior_Number=0
turf/proc/Ship_Interior_Reset(N,turf/Loc)
	set background=1
	if(!N) N=Interior_Number+1
	for(var/turf/T in view(1,src)) if(T.Interior_Number!=N&&!istype(T,/turf/Other/Blank))
		if(!(locate(/obj/Controls) in T))
			for(var/mob/P in T) P.loc=Loc
			for(var/obj/O in T) if(O!=src)
				if(istype(O,/obj/Edges)||istype(O,/obj/Surf)||istype(O,/obj/Trees)||istype(O,/obj/Turfs)) del(O)
				else
					O.loc=Loc //nothing in the ship is destroyed because sometimes it would destroy dragon balls inside
					while(prob(80)) step_rand(O)
			if(T.InitialType) new T.InitialType(T)
			T.Interior_Number=N
			spawn T.Ship_Interior_Reset(N,Loc)
obj/Controls
	icon='Scan Machine.dmi'
	Dead_Zone_Immune=1
	icon_state="2"
	density=1
	Savable=1
	Health=1.#INF
	Spawn_Timer=0
	Grabbable=0
	Knockable=0
	Bolted=1
	var/Ship=0
	New()
		var/Assigned
		if(src&&!Ship) while(!Assigned)
			Ship+=1
			Assigned=1
			for(var/obj/Controls/C) if(C!=src&&C.Ship==Ship)
				Assigned=0
				break
		for(var/obj/Controls/C) if(C.loc==loc&&C!=src)
			C.Spawn_Timer=0
			del(C)
	proc/Ship_Interior_Reset(turf/Loc)
		for(var/turf/T in oview(1,src))
			spawn T.Ship_Interior_Reset(null,Loc)
			break
	Click() Ship_Options(usr)
	proc/Ship_Options(mob/M) if(M.client&&(M in view(1,src)))
		switch(input(M,"What do you want to do with the ship?") in list("Cancel","Pilot","Exit","Launch",\
		"Observe","Toggle random movement"))
			if("Cancel") return
			if("Pilot") if(M in view(1,src))
				for(var/obj/Ships/Ship/S) if(S.Ship==Ship)
					if(S.Pilot)
						M<<"[S.Pilot] is already piloting the ship"
						return
					S.Pilot=M
					if(M.client) M.client.eye=S
					M.Ship=S
					M<<"Click the ship to stop piloting"
					view(M)<<"[M] is now piloting the ship"
					break
			if("Exit") Exit_Ship(M)
			if("Launch") if(M in view(1,src))
				for(var/obj/Ships/Ship/S) if(S.Ship==Ship&&S.z!=16&&!S.Launching)
					S.Launching=1
					M<<"Launching in 1 minute..."
					spawn(600) if(S)
						S.Launching=0
						Liftoff(S)
			if("Observe") if(M in view(1,src)) for(var/obj/Ships/Ship/S) if(S.Ship==Ship)
				M<<"Click the ship to stop observing"
				if(M.client) M.client.eye=S
				break
			if("Toggle random movement") if(M in view(1,src)) for(var/obj/Ships/Ship/S) if(S.Ship==Ship)
				if(S.Move_Randomly)
					S.Move_Randomly=0
					M<<"You stopped the ship from moving randomly"
				else
					M<<"The ship is now moving randomly"
					S.Move_Randomly=rand(1,99999999)
					var/N=S.Move_Randomly
					while(S&&S.Move_Randomly==N)
						step_rand(S)
						sleep(2)
	proc/Exit_Ship(mob/M) if(M in view(1,src))
		for(var/obj/Ships/Ship/S) if(S.Ship==Ship)
			M.loc=S.loc
			if(S.Pilot==M) S.Pilot=null
			if(M.Ship==S) M.Ship=null
			if(M.client) M.client.eye=M
			return
		M.Respawn()
mob/var/tmp/obj/Ships/Ship=null
obj/var
	Str=1
	Dur=1
	Spd=1
	Eff=1
	Frc=1
	Res=1
	Off=1
	Def=1
	Reg=1
	Rec=1
	Ki=100
	Max_Ki=100
	BP=1
obj/Ships

	Spd=100
	Eff=100
	takes_gradual_damage=1

	Givable=0
	var/Weapon_Mounts=0
	density=1
	Savable=1
	layer=4
	var/tmp/mob/Pilot
	var/tmp/Launching
	Health=100
	var/Refire=1
	var/Nav=1
	var/list/Planets=new
	var/tmp/Moving
	var/Small
	var/Ship //The ID of the ship which attaches it to the proper control panel
	var/tmp/Repairing
	var/Launchable
	var/tmp/Move_Randomly
	proc/Update_Pod_Description()
	proc/Weapon_Mount_Cost(mob/P) return round((5000000/P.Intelligence)*(Weapon_Mounts+1))
	verb/Mount_Weapon()
		set src in view(1)
		switch(input("Do you want to mount a weapon or just add ammo to the pod for reloading purposes?") in \
		list("Mount Weapon","Add Ammo"))
			if("Mount Weapon")
				var/Available_Mounts=Weapon_Mounts
				for(var/obj/items/Gun/O in contents) Available_Mounts-=1
				if(Available_Mounts<=0)
					usr<<"There are no available mounts"
					return
				while(Available_Mounts)
					var/list/Weps=list("Cancel")
					for(var/obj/items/Gun/G in usr) Weps+=G
					var/obj/O=input("There are [Available_Mounts] available mounts on [src]. Choose the weapon you wish to \
					add to an available mount.") in Weps
					if(!O||O=="Cancel") return
					Weps-=O
					contents+=O
					view(10)<<"[usr] mounted [O] (Weapon) to [src]"
					Available_Mounts-=1
			if("Add Ammo")
				var/list/Ammos=list("Cancel")
				for(var/obj/items/Ammo/O in usr) Ammos+=O
				var/obj/items/Ammo/O=input("Choose which ammo pack to add") in Ammos
				if(!O||O=="Cancel") return
				contents+=O
				view(10)<<"[usr] added [O] (Ammo) to the [src]"
	verb/Upgrade()
		set src in view(1)
		var/list/Options=list("Cancel")
		Options.Add("Increase BP","New Weapon Mount","Unmount Weapon")
		if(!Launchable) Options+="Make Launchable"
		switch(input("Choose an upgrade option") in Options)
			if("Cancel") return
			if("Make Launchable")
				var/Cost=10000000/usr.Intelligence
				if(usr.Res()<Cost)
					usr<<"You need [Commas(Cost)]$ to add a launch feature"
					return
				usr.Alter_Res(-Cost)
				Total_Cost+=Cost
				Launchable=1
				view(10)<<"[usr] adds space travel capabilities to [src]"
			if("New Weapon Mount")
				if(usr.Res()<Weapon_Mount_Cost(usr))
					usr<<"You need [Cost]$ to add a weapon mount."
					return
				switch(input("This [src] has [Weapon_Mounts] Weapon Mounts, adding another will cost \
				[Commas(Weapon_Mount_Cost(usr))]$. Do you accept the cost?") in list("Yes","No"))
					if("Yes")
						if(usr.Res()<Weapon_Mount_Cost(usr))
							usr<<"Cost has changed. Upgrade cancelled."
							return
						usr.Alter_Res(-Weapon_Mount_Cost(usr))
						Total_Cost+=Weapon_Mount_Cost(usr)
						Weapon_Mounts+=1
			if("Unmount Weapon")
				var/list/Weps=list("Cancel")
				for(var/obj/items/Gun/O in contents) Weps+=O
				while(usr&&src)
					var/obj/O=input("Choose the weapon you wish to unmount, it will go to your items.") in Weps
					if(!O||O=="Cancel") return
					view(10)<<"[usr] unmounted [O] (Weapon) from [src]"
					Weps-=O
					usr.contents+=O
			if("Increase BP")
				if(usr in view(1,src))
					var/Max_Upgrade=sqrt(usr.Intelligence)*usr.Knowledge*3
					var/Percent=(BP/Max_Upgrade)*100
					var/Res_Cost=1000/usr.Intelligence
					if(Percent>=100)
						usr<<"This [src] is 100% upgraded at this time and cannot go any further."
						return
					var/Amount=input("This [src] is upgraded to level [round(BP)]. The current maximum is \
					[round(Max_Upgrade)]. \
					It is at [Percent]% maximum power. Each 1% upgrade cost [Commas(Res_Cost)]$. The maximum is 100%. \
					Input the percentage of power you wish to bring the [src] to. ([Percent]-100%)") as num
					if(Amount>100) Amount=100
					if(Amount<0.1)
						usr<<"Amount must be higher than 0.1%"
						return
					if(Amount<=Percent)
						usr<<"The [src] cannot be downgraded."
						return
					Res_Cost*=Amount-Percent
					if(usr.Res()<Res_Cost)
						usr<<"You do not have enough resources to do this."
						return
					usr.Alter_Res(-Res_Cost)
					BP=Max_Upgrade*(Amount/100)
					Health=BP
					view(10)<<"[usr] upgraded [src] from [Percent]% to [Amount]% ([Commas(BP)] BP)"
					Update_Pod_Description()
	verb/Repair()
		set src in view(1)
		if(Repairing)
			usr<<"The pod is already being repaired by someone"
			return
		if(Health>=BP)
			usr<<"The pod is already fully repaired"
			return
		var/Cost=10000/usr.Intelligence
		if(usr.Res()<Cost)
			usr<<"You need [Commas(Cost)]$ to repair [src]"
			return
		view(10)<<"[usr] begins repairing [src]"
		usr.Alter_Res(-Cost)
		Repairing=1
		sleep(75*usr.Speed_Ratio())
		Repairing=0
		if(!(usr in view(1,src)))
			usr<<"Repair of [src] was cancelled because you didn't stay near it"
			usr.Alter_Res(Cost)
			return
		view(10)<<"[usr] finishes repairing [src]"
		Health=BP
	verb/Refuel() //Add fuel to the ship
		set src in view(1)
		var/Cost=1000/usr.Intelligence
		var/Amount=input("The ship has [Ki]% fuel remaining. The max is [Max_Ki]%. Input the fuel level you wish to \
		bring it to. Each 1% will cost you [Commas(Cost)]$.") as num
		if(Amount<=0) return
		if(Amount>Max_Ki) Amount=Max_Ki
		if(Amount<Ki)
			usr<<"You cannot lower the fuel"
			return
		Cost*=Amount-Ki
		Cost=round(Cost)
		if(usr.Res()<Cost)
			usr<<"You do not have enough money"
			return
		Ki=Amount
		usr.Alter_Res(-Cost)
		view(10)<<"[usr] refuels the ship to [Amount]%"
		usr<<"Cost: [Commas(Cost)]$"
	/*verb/Customize()
		set src in view(1)
		usr<<"This feature is not complete. Your [src]'s stats have just now been randomized."
		Str=initial(Str)
		Dur=initial(Dur)
		Spd=initial(Spd)
		Eff=initial(Eff)
		var/Amount=20
		while(Amount)
			Amount-=1
			switch(pick("Str","Dur","Spd","Eff"))
				if("Str") Str+=1
				if("Dur") Dur+=1
				if("Spd") Spd+=1
				if("Eff") Eff+=1
		Eff=Eff**2*/
	Move()
		if(!Can_Move) return
		var/Former_Location=loc
		..()
		Door_Check(Former_Location)
		Pod_Edge_Check(Former_Location)
	proc/Pod_Edge_Check(turf/Former_Location)
		var/turf/T=get_step(Former_Location,dir)
		if(T)
			if(!T.Enter(src)) return
			for(var/obj/Edges/A in loc) if(!A.Pod_Access)
				if(!(A.dir in list(dir,turn(dir,90),turn(dir,-90),turn(dir,45),turn(dir,-45))))
					loc=Former_Location
					break
			for(var/obj/Edges/A in Former_Location) if(!A.Pod_Access)
				if(A.dir in list(dir,turn(dir,45),turn(dir,-45)))
					loc=Former_Location
					break
	proc/Door_Check(turf/Former_Location) for(var/obj/Turfs/Door/A in loc) if(A.density)
		loc=Former_Location
		if(Pilot) Pilot.Bump(A)
		break
	proc/Fuel()
		Ki-=1/Eff
		if(Ki<0)
			usr<<"Your ship is out of fuel"
			Ki=0
	proc/Ship_Weapon_Fire()
		var/list/Weps
		for(var/obj/items/Gun/G in src) if(!G.Firing&&G.Ammo>0)
			if(!Weps) Weps=new/list
			Weps+=G
		if(!Weps) return
		var/obj/items/Gun/G=pick(Weps)
		if(G)
			G.Gun_Fire(src)
			if(G.Ammo<=0) for(var/obj/items/Ammo/A in src) A.Reload(src,G)
	proc/MoveReset() spawn(Delay(10/Spd)) Moving=0
	Del()
		if(Pilot)
			Pilot.loc=loc
			Pilot.dir=SOUTH
			if(Pilot.client) Pilot.client.eye=Pilot
			Pilot=null
		for(var/obj/Controls/A) if(A.Ship==Ship) A.Ship_Interior_Reset(loc)
		Explosion_Graphics(src,2,10)
		for(var/mob/P in view(3,src)) P.Shockwave_Knockback(5,loc)
		for(var/obj/O in view(3,src)) O.Shockwave_Knockback(5,loc)
		new/obj/BigCrater(locate(x,y,z))
		for(var/obj/O in src) O.loc=loc
		..()
	Bump(obj/A)
		if(Small&&istype(A,/obj/Ships/Ship))
			var/obj/Ships/Ship/B=A
			for(var/obj/Controls/C) if(C.Ship==B.Ship)
				view(src)<<"[src] enters the [A]"
				loc=locate(C.x,C.y-1,C.z)
		else if(istype(A,/obj/Ships))
			if(dir==A.dir) loc=A.loc
			else
				A.Health-=10*sqrt(BP/A.BP)*(Dur/A.Dur)
				var/KB=3*sqrt(BP/A.BP)*(Str/A.Dur)
				if(KB>15) KB=15
				if(KB<1) KB=1
				KB=round(KB)
				Make_Shockwave(A)
				A.Shockwave_Knockback(KB,A.loc)
				if(A.Health<=0) del(A)
		else if(istype(A,/obj/Planets)) Bump_Planet(A,src)
		else if(Pilot&&istype(A,/obj/Turfs/Door)) Pilot.Bump(A)
		else if(!A.opacity)
			var/turf/T
			for(var/turf/TT in range(0,A)) T=TT
			if(T.Pod_Enter) loc=T
	Ship
		Cost=100000000
		Grabbable=0
		Launchable=1
		icon='Ship.dmi'
		var/Last_Entry
		Click()
			if(usr.client.eye==src) usr.client.eye=usr
			if(Pilot==usr)
				Pilot=null
				usr.Ship=null
		New()
			Center_Icon(src)
			spawn if(src)
				if((src in Make_List)||(src in Technology_List)) return
				else
					if(!Ship) for(var/obj/Controls/B) if(B.Ship&&B.z)
						var/FoundShip
						for(var/obj/Ships/Ship/C) if(C.Ship==B.Ship) FoundShip=1
						if(!FoundShip)
							Ship=B.Ship
							break
					if(!Ship)
						view(src)<<"An available ship interior could not be found."
						del(src)
	Spacepod
		icon='Battle Pod.dmi'
		Cost=10000
		Small=1
		New()
			..()
			Center_Icon(src)
			overlays-='GochekPods.dmi'
		Move()
			Pod_Trail()
			..()
		proc/Pod_Trail()
			var/turf/T=loc
			if(T&&isturf(T)) T.Pod_Trail()
		verb/Use()
			set src in view(1,usr)
			if((usr in range(1,src))||usr.Ship==src)
				if(Pilot)
					if(Pilot!=usr)
						usr<<"The pod is already in use by [Pilot]"
						return
					else
						usr.GrabbedMob=null
						usr.loc=loc
						usr.dir=SOUTH
						usr.client.eye=usr
						usr.Ship=null
						Pilot=null
						Move_Randomly=0
				else
					usr.GrabbedMob=null
					Pilot=usr
					usr.Ship=src
					usr.client.eye=src
					contents+=usr
					usr.Gravity=1
		verb/Move_Randomly()
			set src in view(1,usr)
			if(Pilot!=usr) return
			if(Move_Randomly)
				Move_Randomly=0
				usr<<"You stopped the pod from moving randomly"
			else
				Move_Randomly=rand(1,999999999)
				var/N=Move_Randomly
				while(Move_Randomly==N)
					step_rand(src)
					sleep(2)
		verb/Launch()
			set src in view(1,usr)
			if(!Launchable)
				usr<<"[src] has not had a launch feature installed, it is incapable of space travel."
				return
			if(Pilot!=usr)
				usr<<"You are not the pilot"
				return
			else if(!Launching)
				if(z==16) return
				overlays+='GochekPods.dmi'
				icon_state="Launching"
				Launching=1
				usr<<"Launching in 20 seconds..."
				spawn(200) if(src)
					icon_state=""
					Launching=0
					overlays-='GochekPods.dmi'
					Liftoff(src)
turf/proc/Pod_Trail()
	var/image/I=image(icon='GochekPods.dmi',pixel_x=rand(-12,12),pixel_y=rand(-12,12),layer=6)
	overlays+=I
	spawn(15) overlays-=I
proc/Liftoff(obj/Ships/O) for(var/area/B in range(0,O))
	if(B.type==/area/Earth) for(var/obj/Planets/Earth/A) if(A.z) O.loc=A.loc
	else if(B.type==/area/Puran) for(var/obj/Planets/Puran/A) if(A.z) O.loc=A.loc
	else if(B.type==/area/Braal) for(var/obj/Planets/Braal/A) if(A.z) O.loc=A.loc
	else if(B.type==/area/Arconia) for(var/obj/Planets/Arconia/A) if(A.z)O.loc=A.loc
	else if(B.type==/area/Icer) for(var/obj/Planets/Ice/A) if(A.z) O.loc=A.loc
	else if(B.type==/area/Desert) for(var/obj/Planets/Desert/A) if(A.z) O.loc=A.loc
	else if(B.type==/area/Jungle) for(var/obj/Planets/Jungle/A) if(A.z) O.loc=A.loc
	else if(B.type==/area/Android) for(var/obj/Planets/Android/A) if(A.z) O.loc=A.loc
	else if(istype(O,/obj/Ships)) if(O.Pilot) O.Pilot<<"Launch failed. This is not a planet's surface."
	else if(ismob(O)) O.z=16
obj/SpaceDebris
	density=1
	Givable=0
	Savable=0
	Grabbable=0
	layer=5
	Spawn_Timer=300
	Bump(atom/A)
		if(istype(A,/obj/Ships))
			var/obj/Ships/B=A
			B.Health-=5000
			if(B.Health<=0) del(B)
		if(ismob(A)) del(src)
	Asteroid
		icon='Asteroid2.dmi'
		icon_state="1"
		Health=25000
		New()
			var/image/A=image(icon='Asteroid2.dmi',icon_state="1",pixel_y=16,pixel_x=-16)
			var/image/B=image(icon='Asteroid2.dmi',icon_state="2",pixel_y=16,pixel_x=16)
			var/image/C=image(icon='Asteroid2.dmi',icon_state="3",pixel_y=-16,pixel_x=-16)
			var/image/D=image(icon='Asteroid2.dmi',icon_state="4",pixel_y=-16,pixel_x=16)
			overlays.Remove(A,B,C,D)
			overlays.Add(A,B,C,D)
			spawn(rand(0,20)) if(src) walk_rand(src,rand(4,6))
			//..()
		Del()
			Explosion_Graphics(src,2,10)
			..()
	Meteor
		icon='Asteroid.dmi'
		Health=5000
		New()
			spawn(rand(0,20)) if(src) walk_rand(src,rand(2,3))
			//..()
		Del()
			Explosion_Graphics(src,2,5)
			..()
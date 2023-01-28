proc/Get_ship_interior()
	for(var/obj/Controls/c in ship_controls) if(c.z && c.Ship)
		var/obj/Ships/Ship/s
		for(s in ships) if(s.Ship==c.Ship) break
		if(!s) return c.Ship

obj/var/Can_Move=1
atom/var/takes_gradual_damage

mob/Admin4/verb/Planets()
	set category="Admin"
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
	var/tmp/turf/planet_turf
	New()
		planets+=src
		. = ..()
		RestrictedPlanetDeleteCheck()

	proc
		RestrictedPlanetDeleteCheck()
			set waitfor=0
			sleep(600)
			var/turf/t = locate(Planet_X, Planet_Y, Planet_Z)
			if(!t) return
			var/area/a = t.loc
			if(!a) return
			if(map_restriction_on && a.restricted_area)
				del(src)

	Earth
		icon_state="Earth"
		Planet_X=250
		Planet_Y=250
		Planet_Z=1
		Nav_Level=490000
		var/Cloaked
		New()
			CenterIcon(src)
			walk_rand(src,50)
			. = ..()
	Puranto
		icon_state="Puranto"
		Planet_X=250
		Planet_Y=250
		Planet_Z=3
		Nav_Level=400000
		New()
			CenterIcon(src)
			walk_rand(src,100)
			. = ..()
	Braal
		icon_state="Vegeta"
		Planet_X=250
		Planet_Y=250
		Planet_Z=4
		Nav_Level=0
		New()
			CenterIcon(src)
			walk_rand(src,100)
			. = ..()
	Arconia
		icon_state="Arconia"
		Planet_X=250
		Planet_Y=250
		Planet_Z=8
		Nav_Level=100000
		New()
			CenterIcon(src)
			walk_rand(src,100)
			. = ..()
	Ice
		icon_state="Ice"
		Planet_X=250
		Planet_Y=250
		Planet_Z=12
		Nav_Level=0
		New()
			CenterIcon(src)
			walk_rand(src,100)
			. = ..()
	Desert
		icon_state="Desert"
		Planet_X=120
		Planet_Y=170
		Planet_Z=14
		Nav_Level=150000
		New()
			CenterIcon(src)
			walk_rand(src,100)
			. = ..()
	Jungle
		icon_state="Jungle"
		Planet_X=220
		Planet_Y=280
		Planet_Z=14
		Nav_Level=200000
		New()
			CenterIcon(src)
			walk_rand(src,100)
			. = ..()
	Android
		icon='Planets.dmi'
		icon_state="Android"
		Planet_X=290
		Planet_Y=270
		Planet_Z=14
		Nav_Level=300000
		New()
			CenterIcon(src)
			walk_rand(src,100)
			. = ..()

proc/Bump_Planet(obj/Planets/Planet,obj/Ships/Bumper)
	if(!Planet.Planet_X) Bumper.SafeTeleport(locate(rand(1,500),rand(1,500),Planet.Planet_Z))
	else Bumper.SafeTeleport(locate(Planet.Planet_X+rand(-10,10),Planet.Planet_Y+rand(-10,10),Planet.Planet_Z))
	if(istype(Bumper,/obj/Ships)) if(Bumper.Nav) if(!Bumper.Planets.Find(Planet.name))
		Bumper.Planets+=Planet.name
	Small_crater(Bumper.loc)

obj/items/Spacesuit
	Cost=100000
	icon='Mask.dmi'
	name="Air Mask"
	density=0
	desc="You can survive in space if you equip this"
	Stealable=1

//turf/var/tmp/Interior_Number=0
var/ship_interior_resets = 0 //increments +1 every time a ship interior is reset
turf/var/tmp/ship_interior_nonce //gets set to match ship_interior_resets as a flag to know if it still needs reset this session or not
var/list/ship_interior_turfs = new

turf/proc/Ship_Interior_Reset(nonce, turf/Loc)
	//set background=1
	//set waitfor = 0

	return //this crashes no matter what i do so its off for now

	if(!nonce) nonce = ship_interior_resets
	for(var/turf/T in view(1,src))
		if(T.ship_interior_nonce == nonce || istype(T,/turf/Other/Blank)) continue
		if(locate(/obj/Controls) in T) continue
		if(T in ship_interior_turfs) continue
		for(var/mob/P in T) P.SafeTeleport(Loc)
		for(var/obj/O in T) if(O!=src)
			if(istype(O,/obj/Edges)||istype(O,/obj/Surf)||istype(O,/obj/Trees)||istype(O,/obj/Turfs)) del(O)
			else if(!istype(O,/obj/Ship_exit))
				O.SafeTeleport(Loc) //nothing in the ship is destroyed because sometimes it would destroy Wish Orbs inside
				while(prob(80)) step_rand(O)
		if(T.InitialType) new T.InitialType(T)
		T.ship_interior_nonce = nonce
		ship_interior_turfs += T
		T.Ship_Interior_Reset(nonce, Loc)

var/list/ships=new
var/list/ship_exits=new

obj/Ship_exit
	icon='Big teleporter 2013.dmi'
	pixel_x=-19
	pixel_y=-10
	density=1
	Dead_Zone_Immune=1
	Health=1.#INF
	Spawn_Timer=0
	Grabbable=0
	Knockable=0
	Bolted=1
	Savable=0
	New()
		ship_exits+=src

var/list/ship_controls=new

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
		ship_controls+=src
		spawn(10) if(src)
			if(src&&!Ship) Ship=text2num("[x]"+"[y]"+"[z]")
			for(var/obj/Controls/C in ship_controls) if(C.loc==loc&&C!=src)
				C.Spawn_Timer=0
				del(C)
			check_ship_hiders()

	proc/check_ship_hiders()
		set waitfor=0
		while(src)
			if(!find_ship())
				var/turf/found_hiders
				for(var/mob/m in players)
					var/area/a = m.get_area()
					if(a && a.type == /area/ship_area)
						var/turf/t = loc
						for(var/n = 0, n < 500, n++)
							if(!t || istype(t, /turf/Other/Blank)) break
							else if(t == m.base_loc())
								m.Respawn(butNotInShipArea = 1)
								if(m)
									found_hiders = m.base_loc()
								break
							else t=Get_step(t,get_dir(t,m))
				if(found_hiders) Ship_Interior_Reset(found_hiders)
			sleep(300)

	proc/find_ship()
		for(var/obj/Ships/Ship/s in ships) if(s.z && s.Ship==Ship) return s

	proc/Ship_Interior_Reset(turf/Loc)
		ship_interior_resets++
		for(var/turf/T in oview(1,src))
			T.Ship_Interior_Reset(null,Loc)
			break
		ship_interior_turfs = new/list

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
					player_view(15,M)<<"[M] is now piloting the ship"
					break
			if("Exit") Exit_Ship(M,src)
			if("Launch") if(M in view(1,src))
				for(var/obj/Ships/Ship/S) if(S.Ship==Ship&&S.z!=16&&!S.Launching)
					S.Launching=1
					M<<"Launching in 20 seconds..."
					spawn(200) if(S)
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
					while(S&&S.Move_Randomly==N && S.Ki>0)
						step_rand(S)
						S.Fuel()
						sleep(2)
					S.Move_Randomly=0
	proc/Exit_Ship(mob/M,obj/origin) if(M in view(1,origin))
		for(var/obj/Ships/Ship/S in ships) if(S.z&&S.Ship==Ship)
			var/turf/t=Get_step(S,SOUTHEAST)
			if(t&&!t.density) M.SafeTeleport(t)
			else M.SafeTeleport(S.loc)
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
	max_ki=100
	BP=1
mob/proc/max_ship_upgrade()
	return sqrt(Intelligence())*Knowledge*1

var/last_spacepod_delete = 0

obj/Ships

	Spd=100
	Eff=100
	takes_gradual_damage=1
	can_blueprint = 0 //people use a bug to blueprint the ship then stay in it or store stuff in it it serves no purpose to blueprint ships except for bugs
		//also they do it to stop anyone else from having a ship by blueprinting all ships

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
	var/Launchable=1
	var/tmp/Move_Randomly
	proc/Update_Pod_Description()
	proc/Weapon_Mount_Cost(mob/P) return round((500000/P.Intelligence())*((Weapon_Mounts+1)**3))
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
					for(var/obj/items/Gun/G in usr.item_list) Weps+=G
					var/obj/O=input("There are [Available_Mounts] available mounts on [src]. Choose the weapon you wish to \
					add to an available mount.") in Weps
					if(!O||O=="Cancel") return
					Weps-=O
					O.Move(src)
					player_view(15,usr)<<"[usr] mounted [O] (Weapon) to [src]"
					Available_Mounts-=1
			if("Add Ammo")
				var/list/Ammos=list("Cancel")
				for(var/obj/items/Ammo/O in usr.item_list) Ammos+=O
				var/obj/items/Ammo/O=input("Choose which ammo pack to add") in Ammos
				if(!O||O=="Cancel") return
				O.Move(src)
				player_view(15,usr)<<"[usr] added [O] (Ammo) to the [src]"
	verb/Upgrade()
		set src in view(1)
		var/list/Options=list("Cancel")
		Options.Add("Increase BP","New Weapon Mount","Unmount Weapon")
		if(!Launchable) Options+="Make Launchable"
		switch(input("Choose an upgrade option") in Options)
			if("Cancel") return
			if("Make Launchable")
				var/Cost=1000000/usr.Intelligence()
				if(usr.Res()<Cost)
					usr<<"You need [Commas(Cost)]$ to add a launch feature"
					return
				usr.Alter_Res(-Cost)
				Total_Cost+=Cost
				Launchable=1
				player_view(15,usr)<<"[usr] adds space travel capabilities to [src]"
			if("New Weapon Mount")
				if(usr.Res()<Weapon_Mount_Cost(usr))
					usr<<"You need [Weapon_Mount_Cost(usr)]$ to add a weapon mount."
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
					player_view(15,usr)<<"[usr] unmounted [O] (Weapon) from [src]"
					Weps-=O
					O.Move(usr)
			if("Increase BP")
				if(usr in view(1,src))
					var/Max_Upgrade=usr.max_ship_upgrade()
					var/Percent=(BP/Max_Upgrade)*100
					var/Res_Cost=500/usr.Intelligence()
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
					Total_Cost+=Res_Cost
					var/old_bp=BP
					BP=Max_Upgrade*(Amount/100)
					Health*=BP/old_bp
					if(Health>BP) Health=BP
					player_view(15,usr)<<"[usr] upgraded [src] from [Percent]% to [Amount]% ([Commas(BP)] BP)"
					Update_Pod_Description()
	verb/Repair()
		set src in view(1)
		if(!usr.z) return //cant be inside pod
		if(Repairing)
			usr<<"The pod is already being repaired by someone"
			return
		if(Health>=BP)
			usr<<"The pod is already fully repaired"
			return
		var/Cost=3000/usr.Intelligence()
		if(usr.Res()<Cost)
			usr<<"You need [Commas(Cost)]$ to repair [src]"
			return
		player_view(15,usr)<<"[usr] begins repairing [src]"
		Repairing=1
		var/turf/t=usr.loc
		var/turf/t2=loc
		for(var/v in 1 to 5)
			if(t!=usr.loc)
				usr<<"You moved. Repairs cancelled"
				Repairing=0
				return
			if(t2!=loc)
				usr<<"The pod moved. Repairs cancelled"
				Repairing=0
				return
			sleep(10)
		usr.Alter_Res(-Cost)
		Total_Cost+=Cost
		Repairing=0
		if(!(usr in view(1,src)))
			usr<<"Repair of [src] was cancelled because you didn't stay near it"
			usr.Alter_Res(Cost)
			return
		player_view(15,usr)<<"[usr] finishes repairing [src]"
		Health=BP

	verb/Refuel() //Add fuel to the ship
		set src in view(1)
		var/Cost=1000/usr.Intelligence()
		var/Amount=input("The ship has [Ki]% fuel remaining. The max is [max_ki]%. Input the fuel level you wish to \
		bring it to. Each 1% will cost you [Commas(Cost)]$.") as num
		if(Amount<=0) return
		if(Amount>max_ki) Amount=max_ki
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
		Total_Cost+=Cost
		player_view(15,usr)<<"[usr] refuels the ship to [Amount]%"
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

	Move(NewLoc,Dir=0,step_x=0,step_y=0)
		if(!Can_Move||Launching) return
		var/Former_Location=loc
		var/turf/t=Get_step(src,Dir)
		if(t&&isturf(t))
			if(t.density&&t.FlyOverAble) density=0
			for(var/obj/o in t) if(o.density&&!istype(o,/obj/Turfs/Door)&&!istype(o,/obj/Planets))
				density=0
				break
		. = ..()
		density=1
		Door_Check(Former_Location)
		Pod_Edge_Check(Former_Location)

	proc/Pod_Edge_Check(turf/Former_Location)

		return

		var/turf/T=Get_step(Former_Location,dir)
		if(T)
			if(!T.Enter(src)) return
			for(var/obj/Edges/A in loc) if(!A.Pod_Access)
				if(!(A.dir in list(dir,turn(dir,90),turn(dir,-90),turn(dir,45),turn(dir,-45))))
					SafeTeleport(Former_Location)
					break
			for(var/obj/Edges/A in Former_Location) if(!A.Pod_Access)
				if(A.dir in list(dir,turn(dir,45),turn(dir,-45)))
					SafeTeleport(Former_Location)
					break

	proc/Door_Check(turf/Former_Location) for(var/obj/Turfs/Door/A in loc) if(A.density)
		SafeTeleport(Former_Location)
		if(Pilot) Pilot.Bump(A)
		break

	proc/Fuel()
		Ki-=3/Eff
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

	proc/MoveReset()
		set waitfor=0
		sleep(TickMult(10 / Spd))
		Moving=0

	Del()
		var/turf/baseLoc = base_loc()
		if(Pilot)
			//Pilot.SafeTeleport(baseLoc)
			Pilot.dir=SOUTH
			if(Pilot.client) Pilot.client.eye=Pilot
			Pilot=null

		for(var/mob/m in src)
			if(m.key == "Tens of DU") world << "TELEPORTED PILOT TO [baseLoc.x], [baseLoc.y], [baseLoc.z]"
			if(m.Ship == src) m.Ship = null
			m.SafeTeleport(baseLoc)
			m.ApplyStun(time = 60, no_immunity = 1, stun_power = 10)

		if(last_spacepod_delete != world.time)
			last_spacepod_delete = world.time
			if(istype(src,/obj/Ships/Ship)) for(var/obj/Controls/A in ship_controls) if(A.Ship == Ship) A.Ship_Interior_Reset(loc)
			Explosion_Graphics(src,5)
			var/knocks = 0
			var/max_knocks = 100
			for(var/mob/P in view(3,src))
				P.Shockwave_Knockback(5,loc)
				knocks++
				if(knocks > max_knocks) break
			for(var/obj/O in view(3,src))
				O.Shockwave_Knockback(5,loc)
				knocks++
				if(knocks > max_knocks) break
			BigCrater(locate(x,y,z))
			for(var/obj/O in src) O.loc = loc

			//there is a server crashing bug where you stack like 100 spacepod then blow them all up at once
			. = ..()
		else
			loc = null

	Bump(obj/A)
		if(A==src) return //large bounding boxes colliding with themselves (BYOND bug)
		. = ..()
		if(Small&&istype(A,/obj/Ships/Ship))
			var/obj/Ships/Ship/B=A
			for(var/obj/Controls/C in ship_controls) if(C.Ship==B.Ship)
				player_view(15,src)<<"[src] enters the [A]"
				SafeTeleport(locate(C.x,C.y-1,C.z))
		else if(istype(A,/obj/Ships))
			if(dir==A.dir) SafeTeleport(A.loc)
			else
				A.Health-=10*sqrt(BP/A.BP)*(Dur/A.Dur)
				var/KB=3*sqrt(BP/A.BP)*(Str/A.Dur)
				if(KB>15) KB=15
				if(KB<1) KB=1
				KB=round(KB)
				Make_Shockwave(A,sw_icon_size=pick(64,128))
				A.Shockwave_Knockback(KB,A.loc)
				if(A.Health<=0) del(A)
		else if(istype(A,/obj/Planets)) Bump_Planet(A,src)
		else if(Pilot&&istype(A,/obj/Turfs/Door)) Pilot.Bump(A)
		else if(Pilot&&isturf(A)&&(locate(/obj/Turfs/Door) in A)) Pilot.Bump(A)
		/*else if(!A.opacity)
			var/turf/T
			for(var/turf/TT in range(0,A)) T=TT
			if(T.Pod_Enter) SafeTeleport(T)*/

	Ship
		reallyDelete = 1 //quick fix because otherwise when a ship is destroyed it does not free up the ship interior because it still thinks the ship
		//is still valid since the object of it still exists. didnt feel like fixing it the correct way
		Cost=15000000
		Grabbable=0
		Launchable=1
		icon='Ship.dmi'
		var/Last_Entry
		layer=3
		pixel_x=-48
		pixel_y=-36

		bound_width=32
		bound_height=32
		//bound_x=-32

		can_side_step=0
		BP=100 //because health is 100
		Click()
			if(usr.client.eye==src) usr.client.eye=usr
			if(Pilot==usr)
				Pilot=null
				usr.Ship=null
		New()
			ships+=src

			if(world.maxz<5) return

			spawn(2) if(src)
				if(z==15||(locate(/area/ship_area) in range(0,src)))
					del(src)
					return
				spawn if(src)
					if((src in Make_List)||(src in tech_list)) return
					else
						if(!Ship)
							Ship=Get_ship_interior()
							if(!Ship)
								player_view(15,src)<<"There are no more ship interiors available"
								del(src)
	Spacepod
		icon='Spacepod.dmi'
		Cost = 500000
		Small=1
		can_change_icon=1
		can_blueprint = 1

		New()
			. = ..()
			ships+=src
			CenterIcon(src)
			overlays-='GochekPods.dmi'

		Move()
			. = ..()
			Pod_Trail()

		proc/Pod_Trail()
			var/turf/T=loc
			if(T&&isturf(T)) T.Pod_Trail()

		verb/Use()
			set src in view(1,usr)
			if(get_dist(src, usr) <= 1 || usr.Ship == src)
				//exit
				if(Pilot == usr)
					if(usr.key == "EXGenesis") usr << "Exit pod"
					usr.ReleaseGrab()
					usr.SafeTeleport(loc)
					usr.dir = SOUTH
					usr.client.eye = usr
					usr.Ship = null
					Pilot = null
					Move_Randomly = 0
				//enter
				else
					if(Pilot && Pilot != usr)
						usr << "The pod is already in use by [Pilot]"
						return
					if(usr.key == "EXGenesis") usr << "Enter pod"
					usr << "<font color=cyan>Click the pod to launch into space"
					usr.ReleaseGrab()
					Pilot = usr
					usr.Ship = src
					usr.client.eye = src
					usr.SafeTeleport(src)
					usr.Gravity = 1

		verb/Move_Randomly()
			set src in view(1,usr)
			if(Pilot!=usr) return
			if(Move_Randomly)
				Move_Randomly=0
				usr<<"You stopped the pod from moving randomly"
			else
				Move_Randomly=rand(1,999999999)
				var/N=Move_Randomly
				while(Move_Randomly==N && Ki>0)
					step_rand(src)
					Fuel()
					sleep(2)
				Move_Randomly=0

		Click(location)
			if(usr.loc == src)
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
					sleep(140)
					icon_state=""
					Launching=0
					overlays-='GochekPods.dmi'
					Liftoff(src)


		/*verb/Launch()
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
					Liftoff(src)*/

var/image/pod_trail
turf/proc/Pod_Trail()

	return

	//var/image/I=image(icon='GochekPods.dmi',pixel_x=rand(-12,12),pixel_y=rand(-12,12),layer=6)
	if(!pod_trail) pod_trail=image(icon='beam axis.dmi',pixel_x=-32,pixel_y=-32,layer=6)
	overlays+=pod_trail
	spawn(15) overlays-=pod_trail
proc/Liftoff(obj/Ships/O) for(var/area/B in range(0,O))
	if(B.type==/area/Earth) for(var/obj/Planets/Earth/A) if(A.z) O.loc=A.loc
	else if(B.type==/area/Puranto) for(var/obj/Planets/Puranto/A) if(A.z) O.loc=A.loc
	else if(B.type==/area/Braal) for(var/obj/Planets/Braal/A) if(A.z) O.loc=A.loc
	else if(B.type==/area/Arconia) for(var/obj/Planets/Arconia/A) if(A.z)O.loc=A.loc
	else if(B.type==/area/Ice) for(var/obj/Planets/Ice/A) if(A.z) O.loc=A.loc
	else if(B.type==/area/Desert) for(var/obj/Planets/Desert/A) if(A.z) O.loc=A.loc
	else if(B.type==/area/Jungle) for(var/obj/Planets/Jungle/A) if(A.z) O.loc=A.loc
	else if(B.type==/area/Android) for(var/obj/Planets/Android/A) if(A.z) O.loc=A.loc
	else if(istype(O,/obj/Ships)) if(O.Pilot) O.Pilot<<"Launch failed. This is not a planet's surface."
	else if(ismob(O)) O.SafeTeleport(O.x, O.y, 16)
obj/SpaceDebris
	density=1
	Givable=0
	Savable=0
	Grabbable=0
	layer=5
	Spawn_Timer=300
	var/meteor_damage=1

	Bump(atom/A)
		if(!z) return

		. = ..()

		if(istype(A,/obj/Ships))
			var/obj/Ships/B=A
			B.Health-=0.3*Avg_BP*meteor_damage
			if(B.Health<=0) del(B)

		if(ismob(A))
			var/mob/M=A
			var/dmg = meteor_damage * 50 * (Avg_BP/M.BP)**4 * (Avg_Str()/M.End)
			M.TakeDamage(dmg)
			var/kb_dist=meteor_damage * 3 * (Avg_BP/M.BP) * (Avg_Str()/M.End)
			M.Shockwave_Knockback(kb_dist,loc)
			if(M.Health<=0) M.KO("meteor impact!")
		del(src)

	proc/Meteor_fly(move_delay = 1)
		set waitfor=0
		sleep(2)
		while(z)
			var/turf/old_loc = loc
			step(src,dir)
			if(loc == old_loc) del(src)
			sleep(TickMult(move_delay))

	Asteroid
		icon='Asteroid 5 11 2013.dmi'
		Health=25000
		meteor_damage=2

		New()
			Meteor_fly(1.4)
			CenterIcon(src)

		Del()
			if(z)
				var/area/a=locate(/area) in range(0,src)
				if(a) for(var/mob/m in a.player_list) if(getdist(src,m.base_loc())<20)
					Explosion_Graphics(src,4)
					break
			. = ..()
	Meteor
		icon='small asteroid.dmi'
		Health=5000
		meteor_damage=1

		New()
			Meteor_fly(1)
			CenterIcon(src)

		Del()
			if(z)
				var/area/a=locate(/area) in range(0,src)
				if(a) for(var/mob/m in a.player_list) if(getdist(src,m.base_loc())<20)
					Explosion_Graphics(src,3)
					break
			. = ..()
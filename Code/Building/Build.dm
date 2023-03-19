var/Map_Loaded

/*proc/Save_Map()
	var/turf_count=0
	var/list/turf_info=new
	for(var/turf/t in Turfs)
		turf_count++
		turf_info[turf_count]=list("Type"=t.type,"Health"=t.Health,"Builder"=t.Builder,"x"=t.x,"y"=t.y,\
		"z"=t.z,"Flyable"=t.FlyOverAble)*/

proc/MapSave()
	//set background = 1
	var/Amount=0
	var/E=1
	var/savefile/F=new("Map[E]")
	var/list/Types=new
	var/list/Healths=new
	//var/list/Levels=new
	var/list/Builders=new
	var/list/Xs=new
	var/list/Ys=new
	var/list/Zs=new
	var/list/FlyOver=new
	for(var/turf/A in Turfs) if(A.Builder)
		Types+=A.type

		//Healths+="[num2text(round(A.Health),100)]"
		Healths += A.Health

		//Levels+="[num2text(A.Level,100)]"
		Builders+=A.Builder
		Xs+=A.x
		Ys+=A.y
		Zs+=A.z
		FlyOver+=A.FlyOverAble
		Amount+=1
		if(Amount % 20000 == 0)
			F["Types"]<<Types
			F["Healths"]<<Healths
			//F["Levels"]<<Levels
			F["Builders"]<<Builders
			F["Xs"]<<Xs
			F["Ys"]<<Ys
			F["Zs"]<<Zs
			F["FlyOver"]<<FlyOver
			E ++
			F=new("Map[E]")
			Types=new
			Healths=new
			//Levels=new
			Builders=new
			Xs=new
			Ys=new
			Zs=new
			FlyOver=new

	if(Amount % 20000 != 0)
		F["Types"]<<Types
		F["Healths"]<<Healths
		//F["Levels"]<<Levels
		F["Builders"]<<Builders
		F["Xs"]<<Xs
		F["Ys"]<<Ys
		F["Zs"]<<Zs
		F["FlyOver"]<<FlyOver

	world<<"Map Saved ([Amount])"

proc/MapLoad()
	//set background = 1
	Map_Loaded=1
	if(fexists("Map1"))
		var/Amount=0
		var/DebugAmount= 0
		var/E=1
		load
		if(!fexists("Map[E]"))
			goto end
		var/savefile/F=new("Map[E]")
		sleep(1)
		var/list/Types=F["Types"]
		var/list/Healths=F["Healths"]
		var/list/Builders=F["Builders"]
		var/list/Xs=F["Xs"]
		var/list/Ys=F["Ys"]
		var/list/Zs=F["Zs"]
		var/list/FlyOver=F["FlyOver"]

		clients << "Map Load Stage 1 Begin"
		sleep(5)

		Amount = 0
		for(var/A in Types)
			Amount+=1
			DebugAmount += 1
			var/turf/T = new A(locate(Xs[Amount], Ys[Amount], Zs[Amount]))

			T.Health = Healths[Amount]
			if(T.Health == "inf") T.Health = 1.#INF
			if(istext(T.Health)) T.Health = text2num(T.Health)

			T.Builder = Builders[Amount]
			T.FlyOverAble = text2num(FlyOver[Amount])
			Turfs += T

			if(!(T.Builder in built_turfs)) built_turfs[T.Builder] = new/list
			var/list/l = built_turfs[T.Builder]
			l += T
			built_turfs[T.Builder] = l

			for(var/obj/o in T)
				if(!o.Builder && (o.type in list(/obj/Edges, /obj/Surf, /obj/Trees, /obj/Turfs)))
					o.reallyDelete = 1
					o.respawn_on_delete = 0
					o.SafeTeleport(null)

			if(Amount == 20000)
				sleep(world.tick_lag)
				break

		if(Amount == 20000)
			E ++
			goto load

		end
		world<<"Map Loaded ([DebugAmount] in [E] Files.)"

		GenerateFeaturesOnPlayerTurfsOnMapLoad()


mob/Admin4/verb/Load_External_Map_File()
	set category = "Admin"
	var/savefile/f = input("Choose a map file to load into the game on top of whatever is already here") as file|null
	if(!f)
		clients << "No file was chosen"
		return
	MapLoadExternal(f)

//load an external map file on top of everything that is already loaded, this is for like if admins are building special admin buildings on another server
//and they want to then put what they built into the main player server they can just load it on top of that using the map files externally and also so
//they dont have to shut down the server to do it
proc/MapLoadExternal(savefile/F)
	if(!F)
		clients << "No file was passed"
		return
	F = new(F)
	var/Amount=0
	var/DebugAmount= 0
	sleep(1)
	var/list/Types=F["Types"]
	var/list/Healths=F["Healths"]
	var/list/Builders=F["Builders"]
	var/list/Xs=F["Xs"]
	var/list/Ys=F["Ys"]
	var/list/Zs=F["Zs"]
	var/list/FlyOver=F["FlyOver"]
	sleep(5)
	Amount = 0
	for(var/A in Types)
		Amount+=1
		DebugAmount += 1
		var/turf/T = new A(locate(Xs[Amount], Ys[Amount], Zs[Amount]))
		T.Health = Healths[Amount]
		if(T.Health == "inf") T.Health = 1.#INF
		if(istext(T.Health)) T.Health = text2num(T.Health)
		T.Builder = Builders[Amount]
		T.FlyOverAble = text2num(FlyOver[Amount])
		Turfs += T
		if(!(T.Builder in built_turfs)) built_turfs[T.Builder] = new/list
		var/list/l = built_turfs[T.Builder]
		l += T
		built_turfs[T.Builder] = l
		for(var/obj/o in T)
			if(!o.Builder && (o.type in list(/obj/Edges, /obj/Surf, /obj/Trees, /obj/Turfs)))
				o.reallyDelete = 1
				o.respawn_on_delete = 0
				o.SafeTeleport(null)
	world<<"<font color=yellow>External map loaded (+[DebugAmount] turfs)"

var/Turf_Strength = 2 //this many times the upgrade value
var/max_turf_str = 10

mob/proc/max_turf_upgrade()
	var/n = Knowledge * Turf_Strength * (Intelligence() ** wall_INT_scaling)
	n *= 1 //arbitrary
	return n

mob/var/tmp/last_wall_upgrade=0 //world.time

turf/proc
	Make_Dense_All(mob/m)
		set background=1
		if(m&&world.time>m.last_wall_upgrade+10)
			spawn(1) if(m) m.last_wall_upgrade=world.time
			/*spawn for(var/turf/T in built_turfs[Builder])
				if(T.density)
					T.FlyOverAble = 0*/
			//m.last_wall_upgrade=world.time
			if(Builder in built_turfs)
				for(var/turf/T in built_turfs[Builder])
					if(T.density)
						T.FlyOverAble = 0
		else m<<"You can only do this once every 1 seconds (to prevent lag)"

	Upgrade_All(mob/m,display_message=0,for_free=0)
		set background=1

		//if an admin does it, ask first, cuz it may be to inf health on accident
		if(m && m.client && m.Knowledge > Tech_BP * 2)
			switch(alert(m,"Upgrade [Builder]'s Wall Beyond the Knowledge Cap?","Options","No","Yes"))
				if("No") return

		if(m && world.time > m.last_wall_upgrade + 10)

			spawn(1) if(m) m.last_wall_upgrade=world.time
			//m.last_wall_upgrade = world.time

			var/Max_Upgrade=m.max_turf_upgrade()
			var/Cost=round(1000/m.Intelligence())
			if(m.Res()<Cost&&!for_free)
				m<<"You need at least [Commas(Cost)]$ to upgrade a wall"
				return
			m.Alter_Res(-Cost)
			player_view(15,m)<<"[usr] upgrades [Builder]'s walls to [Commas(Max_Upgrade)] battle power, if they were below that \
			amount already. (Cost: [Commas(Cost)]$)"

			/*spawn for(var/turf/T in built_turfs[Builder]) if(T.Health<Max_Upgrade)
				T.Health=Max_Upgrade
				//sleep(1)
			spawn
				if(ckey(Builder) in Built_Objs)
					var/list/L=Built_Objs[ckey(Builder)]
					for(var/obj/o in L) if(o.Health<Max_Upgrade) o.Health=Max_Upgrade*/
			if(Builder in built_turfs)
				for(var/turf/T in built_turfs[Builder]) if(T.Health<Max_Upgrade)
					T.Health=Max_Upgrade
			if(ckey(Builder) in Built_Objs)
				var/list/L=Built_Objs[ckey(Builder)]
				for(var/obj/o in L) if(o.Health<Max_Upgrade) o.Health=Max_Upgrade

		else if(display_message) m<<"You can only do this once every 1 seconds (to prevent lag)"

turf/verb/Upgrade()
	set src in view(1)
	if(!Builder)
		usr<<"You can only use this on things built by players"
		return
	if(!usr.Intelligence())
		usr<<"You do not have any intelligence to do this"
		return
	if(!Built_Objs) Initialize_Built_Objs()
	var/list/Options=list("Upgrade and make dense all","Upgrade all")
	if(Builder==usr.key)
		if(FlyOverAble) Options+="Make dense all"
		else Options+="Make undense all"
	switch(input("Options") in Options)
		if("Upgrade and make dense all")
			Make_Dense_All(usr)
			Upgrade_All(usr,display_message=0)
		if("Make dense all") Make_Dense_All(usr)
		if("Make undense all")
			if(Builder in built_turfs)
				var/list/l=built_turfs[Builder]
				for(var/turf/t in l) t.FlyOverAble = 1
		if("Upgrade all") Upgrade_All(usr)






var/list/Turfs=new
var/list/built_turfs=new //newer, includes directories by key
turf/var/FlyOverAble=1
atom/var/Buildable=1

var/list/Builds=new

proc/AddBuilds()
	for(var/A in typesof(/turf))
		var/turf/C=new A(locate(1,1,1))
		if(C) if(C.Buildable && C.type!=/turf&&C.type!=/turf/warp)
			var/obj/Build/B=new
			B.build_category = C.build_category
			B.icon=C.icon
			B.icon_state=C.icon_state
			B.Creates=C.type
			B.name="[C.name]-B"
			Builds+=B
		del(C)
	for(var/A in typesof(/obj/Turfs))
		var/obj/B=new A
		if(B) if(B.Buildable && B.type!=/obj/Turfs && B.build_category != BUILD_CUSTOM)
			var/obj/Build/C=new
			C.build_category = BUILD_DECOR
			C.icon=B.icon
			C.icon_state=B.icon_state
			C.Creates=B.type
			C.name="[B.name]-B"
			Builds+=C
	for(var/A in typesof(/obj/Trees))
		var/obj/B=new A
		if(B) if(B.Buildable&&B.type!=/obj/Trees)
			var/obj/Build/C=new
			C.build_category = BUILD_TREES
			C.icon=B.icon
			C.icon_state=B.icon_state
			C.Creates=B.type
			C.name="[B.name]-B"
			Builds+=C
	for(var/A in typesof(/obj/Edges))
		var/obj/B=new A
		if(B) if(B.Buildable&&B.type!=/obj/Trees)
			var/obj/Build/C=new
			C.icon=B.icon
			C.icon_state=B.icon_state
			C.Creates=B.type
			C.name="[B.name]-B"
			Builds+=C
	for(var/A in typesof(/obj/Surf))
		var/obj/B=new A
		if(B) if(B.Buildable&&B.type!=/obj/Trees)
			var/obj/Build/C=new
			C.icon=B.icon
			C.icon_state=B.icon_state
			C.Creates=B.type
			C.name="[B.name]-B"
			Builds+=C

mob/var/tmp/turf_lay_cost=0

obj/Build
	var
		Creates

	Click()
		if(usr.Target==src)
			usr<<"You have deselected [src]"
			usr.Target=null
			return
		usr.turf_lay_cost = usr.turf_lay_cost()
		Build_Lay(src,usr)
		if(usr.Target!=src)
			usr.Target=src
			usr<<"You have selected [src]"
			usr<<"It will cost [Commas(usr.turf_lay_cost())] resources per tile you build. This cost will go up later based on how much tiles \
			have been built by all players."
		if(usr.client) winset(usr,"mapwindow.map","focus=true")
		if(usr.client) winset(usr,"mainwindow.map","focus=true")

mob/proc/turf_lay_cost()
	var/n = 1000 * 1.6**(Turfs.len/10000)
	n=round(n,1000)
	if(n>100000) n=100000
	if(IsAdmin() && admins_build_free) return 0
	return n * building_price_mult

mob/proc/StopBuildingThings()
	Target = null

proc/IsInVoid(mob/m)
	if(!m) return
	var/turf/t = m.base_loc()
	if(!t) return 1
	if(t.type == /turf/Other/Blank) return 1

proc/Build_Lay(obj/Build/O,mob/P) if(!P.KO) //Type to build, player who is building it, location to put it
	set waitfor=0

	if(P.AtBattlegrounds())
		P << "You can not build here"
		P.StopBuildingThings()
		return

	var/turf/t2 = P.loc
	if(!t2 || !isturf(t2))
		P.StopBuildingThings()
		return

	var/turf/true_loc=P.base_loc()
	if(!true_loc.Builder && true_loc && isturf(true_loc) && true_loc.z==5 && true_loc.type!=/turf/Other/Sky2)
		var/turf/death_spawn=locate(death_x,death_y,death_z)
		if(get_dist(true_loc,death_spawn) < checkpointBuildDist)
			P<<"Building is not allowed here except on the clouds"
			P.Target=null
			return

	if(IsInVoid(P))
		if(!can_build_in_void && !P.IsAdmin())
			P.StopBuildingThings()
			return
		if(!admins_can_build_in_void && P.IsAdmin())
			P.StopBuildingThings()
			return

	if(prison_exit&&P.z==prison_exit.z&&getdist(P,prison_exit)<=20)
		P<<"You can not build this close to the prison exit"
		P.StopBuildingThings()
		return

	if(istype(P.get_area(),/area/tournament_area))
		P<<"Building here is impossible"
		P.StopBuildingThings()
		return

	if(istype(P.get_area(),/area/God_Ki_Realm))
		P<<"Building here is impossible"
		P.StopBuildingThings()
		return

	if(istype(P.get_area(),/area/Braal_Core))
		P<<"Building here is impossible"
		P.StopBuildingThings()
		return

	for(var/obj/Fighter_Spot/f in Fighter_Spots) if(f.z==P.locz()&&getdist(f,P)<=12)
		P<<"You can not build near the tournament"
		P.StopBuildingThings()
		return

	var/Res_Cost = P.turf_lay_cost
	if(P.z == 16 && Res_Cost != 0) Res_Cost += 10000 * building_price_mult

	if(Res_Cost != 0)
		var/obj/Spawn/s
		for(s in Spawn_List) if(!s.Builder&&s.z==P.z&&getdist(s,P)<=20) break
		if(s)
			Res_Cost += 100000 * building_price_mult
			if(P.Res()<Res_Cost)
				P<<"It costs [Res_Cost] resources per tile to build this close to a non-player made spawn"
				P.StopBuildingThings()
				return

	if(P.Res()<Res_Cost)
		P<<"You need [Res_Cost] resources per tile you build"
		P.StopBuildingThings()
		return

	for(var/turf/t in range(0,P))
		if(t.Builder && t.Builder!=P.key && P.max_turf_upgrade()<t.Health*0.95)
			P<<"You can not build over this person's turfs because it was built with knowledge too far \
			beyond yours."
			P.StopBuildingThings()
			return
		if(istype(t,/turf/Teleporter))
			P<<"You can not build this close to entrances"
			P.StopBuildingThings()
			return
		if(locate(/obj/Bank) in t) return

	for(var/obj/Turfs/Door/d in range(0,P)) if(d.Password==7125)
		P<<"You can not build over the time chamber door"
		P.StopBuildingThings()
		return

	if(!Built_Objs) Initialize_Built_Objs()
	var/atom/D=P
	if(P.Ship) D=P.Ship
	if(!D.loc) return
	var/Turrets

	for(var/obj/Turret/T in Turrets) if(T.z&&T.z==D.z&&getdist(T,D)<=15&&T.Password)
		Turrets=1
		for(var/obj/items/Door_Pass/I in P.item_list) if(I.Password==T.Password) Turrets=0
	if(Turrets)
		P<<"You cannot build this close to turrets that want to attack you"
		return

	//for(var/obj/Controls/N in view(1,locate(D.x,D.y,D.z)))
	//	P<<"You cannot build this close to ship controls"
	//	return
	for(var/obj/Warper/W in view(1,locate(D.x,D.y,D.z)))
		P<<"You cannot build this close to warpers."
		return
	if(!D) return

	var/atom/C
	if(copytext(O.Creates,1,6) == "/turf")
		//C = new O.Creates(locate(D.x,D.y,D.z), skip_auto_gen = 1)
		C = new O.Creates(locate(D.x,D.y,D.z))
	else C = new O.Creates(locate(D.x,D.y,D.z))

	if(!C) return
	C.Builder=P.key
	if(isobj(C))

		P.StopBuildingThings() //so you only place 1 per click instead of til you untoggle it

		if(!(P.ckey in Built_Objs)) Built_Objs[ckey(P.key)]=new/list
		var/list/L=Built_Objs[ckey(P.key)]
		L+=C
		Built_Objs[ckey(P.key)]=L

		C:Spawn_Timer=0
		if(istype(C,/obj/Turfs/Sign)||istype(C,/obj/Turfs/Glass))
			C.Bolted=P.key
		var/Turf_Objects=0
		for(var/obj/K in range(0,P)) if(!(locate(K) in P)) Turf_Objects+=1
		if(Turf_Objects>4)
			P<<"Nothing more can be placed here."
			del(C)
			return

	if(istype(C,/obj/Turfs/Door))
		var/New_Password=input(P,"Enter a password or leave blank") as text
		if(!C) return
		C.Password=New_Password
		if(isobj(C)) C:Grabbable=0

		P.StopBuildingThings() //Only build 1 door at a time

	if(istype(C,/obj/Turfs/Sign))
		var/txt = input(P,"What do you want to write on the sign?","options") as text
		if(!C) return
		C.maptext = txt
		C.maptext="<b><font color=cyan>[C.maptext]"
	if(!isturf(C)) C.Savable=1
	else
		C.Savable=0
		//new/area/Inside(locate(P.x,P.y,P.z))
		for(var/obj/Edges/E in C) del(E)
		for(var/obj/Surf/E in C) del(E)
		for(var/obj/Trees/E in C) del(E)
		for(var/obj/Turfs/E in C) del(E)
		Turfs+=C

		if(!(P.key in built_turfs)) built_turfs[P.key]=new/list
		var/list/l=built_turfs[P.key]
		l+=C
		built_turfs[P.key]=l

		GenerateFeaturesOnBuildLay(C)

	P.Alter_Res(-Res_Cost)




var/list/Built_Objs

proc/Initialize_Built_Objs()
	Built_Objs = new/list
	for(var/obj/Turfs/T)
		if(T.Builder && T.Savable)
			if(!(ckey(T.Builder) in Built_Objs)) Built_Objs[ckey(T.Builder)] = new/list
			var/list/L = Built_Objs[ckey(T.Builder)]
			L += T
			Built_Objs[ckey(T.Builder)] = L
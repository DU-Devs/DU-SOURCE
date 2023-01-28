var/Map_Loaded

/*proc/Save_Map()
	var/turf_count=0
	var/list/turf_info=new
	for(var/turf/t in Turfs)
		turf_count++
		turf_info[turf_count]=list("Type"=t.type,"Health"=t.Health,"Builder"=t.Builder,"x"=t.x,"y"=t.y,\
		"z"=t.z,"Flyable"=t.FlyOverAble)*/

proc/MapSave()
	set background = 1
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
		Healths+="[num2text(round(A.Health),100)]"
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
		//var/list/Levels=F["Levels"]
		var/list/Builders=F["Builders"]
		var/list/Xs=F["Xs"]
		var/list/Ys=F["Ys"]
		var/list/Zs=F["Zs"]
		var/list/FlyOver=F["FlyOver"]
		Amount = 0
		for(var/A in Types)
			Amount+=1
			DebugAmount += 1
			var/turf/T=new A(locate(text2num(list2params(Xs.Copy(Amount,Amount+1))),text2num(list2params(Ys.Copy(Amount,Amount+1))),text2num(list2params(Zs.Copy(Amount,Amount+1)))))
			T.Health=text2num(list2params(Healths.Copy(Amount,Amount+1)))
			//T.Level=text2num(list2params(Levels.Copy(Amount,Amount+1)))
			//T.Builder=list2params(Builders.Copy(Amount,Amount+1))
			T.Builder=Builders.Copy(Amount,Amount+1)[1]
			T.FlyOverAble=text2num(list2params(FlyOver.Copy(Amount,Amount+1)))
			Turfs+=T

			if(!(T.Builder in built_turfs)) built_turfs[T.Builder]=new/list
			var/list/l=built_turfs[T.Builder]
			l+=T
			built_turfs[T.Builder]=l

			//if(T.Builder)
				//new/area/Inside(T)

			for(var/obj/Edges/B in T)
				if(!B.Builder)
					del(B)
			for(var/obj/Surf/B in T)
				if(!B.Builder)
					del(B)
			for(var/obj/Trees/B in T)
				if(!B.Builder)
					del(B)
			for(var/obj/Turfs/B in T)
				if(!B.Builder)
					del(B)


			if(Amount == 20000)
				sleep(1)
				break

		if(Amount == 20000)
			E ++
			goto load

		end
		world<<"Map Loaded ([DebugAmount] in [E] Files.)"



var/Turf_Strength=6 //this many times the upgrade value
mob/Admin4/verb/Turf_Strength()
	set category="Admin"
	Turf_Strength=input(src,"Set how difficult it is to break down fully upgraded walls",\
	"Options",Turf_Strength) as num
	if(Turf_Strength<0.1) Turf_Strength=0.1
	Log(src,"[key] changed turf strength to [Turf_Strength]x")

mob/proc/max_turf_upgrade()
	return Knowledge*Turf_Strength*(Intelligence**wall_INT_scaling)
mob/var/tmp/last_wall_upgrade=0 //world.time
/*turf/proc
	Make_Dense_All(mob/m)
		set background=1
		if(m&&world.time>m.last_wall_upgrade+10)
			spawn(1) if(m) m.last_wall_upgrade=world.time
			spawn for(var/turf/T in Turfs) if(T.Builder==Builder)
				T.FlyOverAble=0
				//sleep(1)
		else m<<"You can only do this once every 1 seconds (to prevent lag)"
	Upgrade_All(mob/m,display_message=0)
		set background=1
		if(m&&world.time>m.last_wall_upgrade+10)
			spawn(1) if(m) m.last_wall_upgrade=world.time
			var/Max_Upgrade=usr.max_turf_upgrade()
			var/Cost=round(1000/usr.Intelligence)
			if(usr.Res()<Cost)
				usr<<"You need at least [Commas(Cost)]$ to upgrade a wall"
				return
			usr.Alter_Res(-Cost)
			player_view(15,usr)<<"[usr] upgrades [Builder]'s walls to [Commas(Max_Upgrade)] battle power, if they were below that \
			amount already. (Cost: [Commas(Cost)]$)"
			spawn for(var/turf/T in Turfs) if(T.Builder==Builder&&T.Health<Max_Upgrade)
				T.Health=Max_Upgrade
				//sleep(1)
			spawn for(var/obj/O in Built_Objs) if(O.Builder==Builder&&O.Health<Max_Upgrade)
				O.Health=Max_Upgrade
				//sleep(1)
		else if(display_message) m<<"You can only do this once every 1 seconds (to prevent lag)"
turf/verb/Upgrade()
	set src in view(1)
	if(!Builder)
		usr<<"You can only use this on thing's built by players"
		return
	if(!usr.Intelligence)
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
		if("Make undense all") for(var/turf/T in Turfs) if(T.Builder==Builder) T.FlyOverAble=1
		if("Upgrade all") Upgrade_All(usr)*/







turf/proc
	Make_Dense_All(mob/m)
		set background=1
		if(m&&world.time>m.last_wall_upgrade+10)
			spawn(1) if(m) m.last_wall_upgrade=world.time
			spawn for(var/turf/T in built_turfs[Builder]) T.FlyOverAble=0
		else m<<"You can only do this once every 1 seconds (to prevent lag)"
	Upgrade_All(mob/m,display_message=0,for_free=0)
		set background=1
		if(m&&world.time>m.last_wall_upgrade+10)
			spawn(1) if(m) m.last_wall_upgrade=world.time
			var/Max_Upgrade=m.max_turf_upgrade()
			var/Cost=round(1000/m.Intelligence)
			if(m.Res()<Cost&&!for_free)
				m<<"You need at least [Commas(Cost)]$ to upgrade a wall"
				return
			m.Alter_Res(-Cost)
			player_view(15,m)<<"[usr] upgrades [Builder]'s walls to [Commas(Max_Upgrade)] battle power, if they were below that \
			amount already. (Cost: [Commas(Cost)]$)"
			spawn for(var/turf/T in built_turfs[Builder]) if(T.Health<Max_Upgrade)
				T.Health=Max_Upgrade
				//sleep(1)
			spawn
				if(Builder in Built_Objs)
					var/list/L=Built_Objs[Builder]
					for(var/obj/o in L) if(o.Health<Max_Upgrade) o.Health=Max_Upgrade
		else if(display_message) m<<"You can only do this once every 1 seconds (to prevent lag)"
turf/verb/Upgrade()
	set src in view(1)
	if(!Builder)
		usr<<"You can only use this on things built by players"
		return
	if(!usr.Intelligence)
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
				for(var/turf/t in l) t.FlyOverAble=1
		if("Upgrade all") Upgrade_All(usr)






var/list/Turfs=new
var/list/built_turfs=new //newer, includes directories by key
turf/var/FlyOverAble=1
atom/var/Buildable=1
var/list/Builds=new
proc/AddBuilds()
	for(var/A in typesof(/turf))
		var/turf/C=new A(locate(1,1,1))
		if(C) if(C.Buildable&&C.type!=/turf&&C.type!=/turf/warp)
			var/obj/Build/B=new
			B.icon=C.icon
			B.icon_state=C.icon_state
			B.Creates=C.type
			B.name="[C.name]-B"
			Builds+=B
		del(C)
	for(var/A in typesof(/obj/Turfs))
		var/obj/B=new A
		if(B) if(B.Buildable&&B.type!=/obj/Turfs)
			var/obj/Build/C=new
			C.icon=B.icon
			C.icon_state=B.icon_state
			C.Creates=B.type
			C.name="[B.name]-B"
			Builds+=C
	for(var/A in typesof(/obj/Trees))
		var/obj/B=new A
		if(B) if(B.Buildable&&B.type!=/obj/Trees)
			var/obj/Build/C=new
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
	var/Creates
	Click()
		if(usr.Target==src)
			usr<<"You have deselected [src]"
			usr.Target=null
			return
		usr.turf_lay_cost=turf_lay_cost()
		Build_Lay(src,usr)
		if(usr.Target!=src)
			usr.Target=src
			usr<<"You have selected [src]"
			usr<<"It will cost [Commas(turf_lay_cost())] resources per tile you build. This cost will go up later based on how much tiles \
			have been built by all players."

proc/turf_lay_cost()
	var/n=1000 * 1.6**(Turfs.len/10000)
	n=round(n,1000)
	if(n>100000) n=100000
	return n

proc/Build_Lay(obj/Build/O,mob/P) if(!P.KO) //Type to build, player who is building it, location to put it

	var/turf/true_loc=P.True_Loc()
	if(!true_loc.Builder && true_loc && isturf(true_loc) && true_loc.z==5 && true_loc.type!=/turf/Other/Sky2)
		var/turf/death_spawn=locate(death_x,death_y,death_z)
		if(get_dist(true_loc,death_spawn)<50)
			P<<"Building is not allowed here except on the clouds"
			P.Target=null
			return

	if(prison_exit&&P.z==prison_exit.z&&getdist(P,prison_exit)<=20)
		P<<"You can not build this close to the prison exit"
		P.Target=null
		return

	if(istype(P.get_area(),/area/tournament_area))
		P<<"Building here is impossible"
		P.Target=null
		return

	if(istype(P.get_area(),/area/Vegeta_Core))
		P<<"Building here is impossible"
		P.Target=null
		return

	for(var/obj/Fighter_Spot/f in Fighter_Spots) if(f.z==P.locz()&&getdist(f,P)<=12)
		P<<"You can not build near the tournament"
		P.Target=null
		return

	var/Res_Cost=P.turf_lay_cost
	if(P.z==16) Res_Cost+=10000

	var/obj/Spawn/s
	for(s in Spawn_List) if(!s.Builder&&s.z==P.z&&getdist(s,P)<=20) break
	if(s)
		Res_Cost+=100000
		if(P.Res()<Res_Cost)
			P<<"It costs [Res_Cost] resources per tile to build this close to a non-player made spawn"
			P.Target=null
			return

	if(P.Res()<Res_Cost)
		P<<"You need [Res_Cost] resources per tile you build"
		P.Target=null
		return

	for(var/turf/t in range(0,P))
		if(t.Builder && t.Builder!=P.key && P.max_turf_upgrade()<t.Health*0.95)
			P<<"You can not build over this person's turfs because it was built with knowledge too far \
			beyond yours."
			P.Target=null
			return
		if(istype(t,/turf/Teleporter))
			P<<"You can not build this close to entrances"
			P.Target=null
			return
		if(locate(/obj/Bank) in t) return

	for(var/obj/Turfs/Door/d in range(0,P)) if(d.Password==7125)
		P<<"You can not build over the time chamber door"
		P.Target=null
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
	var/atom/C=new O.Creates(locate(D.x,D.y,D.z))
	if(!C) return
	C.Builder=P.key
	if(isobj(C))

		if(!(P.key in Built_Objs)) Built_Objs[P.key]=new/list
		var/list/L=Built_Objs[P.key]
		L+=C
		Built_Objs[P.key]=L

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
		P.Target=null //Only build 1 door at a time
	if(istype(C,/obj/Turfs/Sign))
		C.maptext=input(P,"What do you want to write on the sign?","options") as text
		C.maptext="<b><font size=1><font color=cyan>[C.maptext]"
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

	P.Alter_Res(-Res_Cost)
var/list/Built_Objs
proc/Initialize_Built_Objs()
	Built_Objs=new/list
	for(var/obj/Turfs/T) if(T.Builder&&T.Savable)
		if(!(T.Builder in Built_Objs)) Built_Objs[T.Builder]=new/list
		var/list/L=Built_Objs[T.Builder]
		L+=T
		Built_Objs[T.Builder]=L
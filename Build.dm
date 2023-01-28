var/Map_Loaded
proc/MapSave()
	set background = 1
	var/Amount=0
	var/E=1
	var/savefile/F=new("Map[E]")
	var/list/Types=new
	var/list/Healths=new
	var/list/Levels=new
	var/list/Builders=new
	var/list/Xs=new
	var/list/Ys=new
	var/list/Zs=new
	var/list/FlyOver=new
	for(var/turf/A in Turfs)
		Types+=A.type
		Healths+="[num2text(round(A.Health),100)]"
		Levels+="[num2text(A.Level,100)]"
		Builders+=A.Builder
		Xs+=A.x
		Ys+=A.y
		Zs+=A.z
		FlyOver+=A.FlyOverAble
		Amount+=1
		if(Amount % 20000 == 0)
			F["Types"]<<Types
			F["Healths"]<<Healths
			F["Levels"]<<Levels
			F["Builders"]<<Builders
			F["Xs"]<<Xs
			F["Ys"]<<Ys
			F["Zs"]<<Zs
			F["FlyOver"]<<FlyOver
			E ++
			F=new("Map[E]")
			Types=new
			Healths=new
			Levels=new
			Builders=new
			Xs=new
			Ys=new
			Zs=new
			FlyOver=new

	if(Amount % 20000 != 0)
		F["Types"]<<Types
		F["Healths"]<<Healths
		F["Levels"]<<Levels
		F["Builders"]<<Builders
		F["Xs"]<<Xs
		F["Ys"]<<Ys
		F["Zs"]<<Zs
		F["FlyOver"]<<FlyOver

	world<<"Map Saved ([Amount])"
proc/MapLoad()
	set background = 1
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
		var/list/Levels=F["Levels"]
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
			T.Level=text2num(list2params(Levels.Copy(Amount,Amount+1)))
			T.Builder=list2params(Builders.Copy(Amount,Amount+1))
			T.FlyOverAble=text2num(list2params(FlyOver.Copy(Amount,Amount+1)))
			Turfs+=T

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



var/Turf_Strength=12 //this many times the upgrade value
mob/Admin4/verb/Turf_Strength()
	set category="Admin"
	Turf_Strength=input(src,"Set how difficult it is to break down fully upgraded walls",\
	"Options",Turf_Strength) as num
	if(Turf_Strength<0.1) Turf_Strength=0.1
	Log(src,"[key] changed turf strength to [Turf_Strength]x")


turf/proc
	Make_Dense_All() for(var/turf/T in Turfs) if(T.Builder==Builder) T.FlyOverAble=0
	Upgrade_All()
		var/Max_Upgrade=usr.Knowledge*Turf_Strength*(usr.Intelligence**0.25)
		var/Cost=round(10000/usr.Intelligence)
		if(usr.Res()<Cost)
			usr<<"You need at least [Commas(Cost)]$ to upgrade a wall"
			return
		usr.Alter_Res(-Cost)
		view(usr)<<"[usr] upgrades [Builder]'s walls to [Commas(Max_Upgrade)] battle power, if they were below that \
		amount already. (Cost: [Commas(Cost)]$)"
		for(var/turf/T in Turfs) if(T.Builder==Builder&&T.Health<Max_Upgrade) T.Health=Max_Upgrade
		for(var/obj/O in Built_Objs) if(O.Builder==Builder&&O.Health<Max_Upgrade) O.Health=Max_Upgrade
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
	if(Builder==usr.ckey)
		if(FlyOverAble) Options+="Make dense all"
		else Options+="Make undense all"
	switch(input("Options") in Options)
		if("Upgrade and make dense all")
			Make_Dense_All()
			Upgrade_All()
		if("Make dense all") Make_Dense_All()
		if("Make undense all") for(var/turf/T in Turfs) if(T.Builder==Builder) T.FlyOverAble=1
		if("Upgrade all") Upgrade_All()
var/list/Turfs=new
turf/var/FlyOverAble=1
atom/var/Buildable=1
var/list/Builds=new
proc/AddBuilds()
	for(var/A in typesof(/turf))
		var/turf/C=new A(locate(1,1,1))
		if(C) if(C.Buildable&&C.type!=/turf)
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
obj/Build
	var/Creates
	Click()
		if(usr.Target==src)
			usr<<"You have deselected [src]"
			usr.Target=null
			return
		Build_Lay(src,usr)
		if(usr.Target!=src)
			usr.Target=src
			usr<<"You have selected [src]"
proc/Build_Lay(obj/Build/O,mob/P) if(P.icon_state!="KO") //Type to build, player who is building it, location to put it

	if((locate(/turf/Other/Stars) in range(0,P))&&!Can_Build_In_Space) return
	if(((P in All_Entrants)&&P.z==7)||(locate(/obj/Fighter_Spot) in range(20,P)))
		P<<"You can not build near the tournament"
		P.Target=null
		return

	var/Res_Cost=1000
	if(P.Res()<Res_Cost)
		P<<"You need [Res_Cost] resources per tile you build"
		P.Target=null
		return

	if(!Built_Objs) Initialize_Built_Objs()
	var/atom/D=P
	if(P.Ship) D=P.Ship
	if(!D.loc) return
	var/Turrets
	for(var/obj/Turret/T in view(10,D)) if(T.Password)
		Turrets=1
		for(var/obj/items/Door_Pass/I in P) if(I.Password==T.Password) Turrets=0
	if(Turrets)
		P<<"You cannot build this close to turrets that want to attack you"
		return
	for(var/obj/Controls/N in view(1,locate(D.x,D.y,D.z)))
		P<<"You cannot build this close to ship controls"
		return
	for(var/turf/Special/Teleporter/N in view(1,locate(D.x,D.y,D.z)))
		P<<"You cannot build this close to entrances."
		return
	for(var/obj/Warper/W in view(1,locate(D.x,D.y,D.z)))
		P<<"You cannot build this close to warpers."
		return
	if(!D) return
	var/atom/C=new O.Creates(locate(D.x,D.y,D.z))
	if(!C) return
	C.Builder=P.ckey
	if(isobj(C))
		Built_Objs+=C
		C:Spawn_Timer=0
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
		if(C.Password) if(isobj(C)) C:Grabbable=0
		P.Target=null //Only build 1 door at a time
	if(istype(C,/obj/Turfs/Sign)) C.desc=input(P,"What do you want to write on the sign?") as text
	if(!isturf(C)) C.Savable=1
	else
		C.Savable=0
		//new/area/Inside(locate(P.x,P.y,P.z))
		for(var/obj/Edges/E in C) del(E)
		for(var/obj/Surf/E in C) del(E)
		for(var/obj/Trees/E in C) del(E)
		for(var/obj/Turfs/E in C) del(E)
		Turfs+=C
	P.Alter_Res(-Res_Cost)
var/list/Built_Objs
proc/Initialize_Built_Objs()
	Built_Objs=new/list
	for(var/obj/Turfs/T) if(T.Builder&&T.Savable) Built_Objs+=T
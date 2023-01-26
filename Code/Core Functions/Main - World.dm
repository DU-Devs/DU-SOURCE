mob/mouse_opacity = 2

var/WipeStartDate

mob/Admin5/verb/SetWipeStartDate()
	var/n = input(usr, "Number of days since wipe started.", "Days Since Wipe Start", 0) as num|null
	if(!n) return
	WipeStartDate = world.realtime - Time.FromDays(n)
	usr << "Wipe Start Date set to [time2text(WipeStartDate,"MMM DD YYYY")]."

world
	map_format = TOPDOWN_MAP
	movement_mode = PIXEL_MOVEMENT_MODE
	icon_size=32

client/preload_rsc=1

var/Version="v35.9.6"
var/hubfilter = 1

#define PUBLIC_HOSTING

world
	hub = "Muhuhu.game"
	#ifdef PUBLIC_HOSTING
	hub_password = "3dhzPKLY61Fc65ye"
	#else
	hub_password = ""
	#endif
	turf = /turf/Other/Blank
	cache_lifespan = 3
	loop_checks = 0
	name = "Dragon Universe"
	status = "Nameless Server"
	#ifdef REWORK
	mob = /mob/login
	#endif
	New()
		#ifdef PUBLIC_HOSTING
		hubfilter = 0
		#endif
		..()
		Initialize(Time.FromSeconds(15))

var/list/players=new

initializer
	New()
		world.log=file("Errors.log")
		..()

mob/proc/Connection_count()
	if(!client) return
	var/n=0
	for(var/client/c) if(c.computer_id==client.computer_id) n++
	return n

mob/proc/Check_Senses()
	set background = TRUE
	set waitfor = FALSE
	spawn while(1)
		if(!sense2_obj) sense2_obj=locate(/obj/Skills/Utility/Sense/Level2) in src
		if(!sense3_obj) sense3_obj=locate(/obj/Skills/Utility/Sense/Level3) in src
		sleep(50)

mob/var
	tmp/empty_player
	tmp/logout_timer=0
	logout_time=0 //realtime

mob/Logout()

	if(istype(src,/mob/Enemy)) key=null //fixes some bug i dont remember now

	LogoutHandler()

	//hopefully to fix a bug where mobs from the login screen are staying on earth for some reason, 100s of them
	if((!z || loc==locate(1,1,1))&&name==initial(name)) del(src)

mob/proc/Other_Load_Stuff()
	Remove_Say_Spark()
	var/image/A=image(icon='Say Spark.dmi',pixel_y=6)
	overlays.Remove('AbsorbSparks.dmi','TimeFreeze.dmi','SBombGivePower.dmi',BlastCharge,A)
	if(KO)
		RegainConsciousness()
		KnockOut("(logged in KO'd)")
	PrimaryPlayerLoop(Time.FromSeconds(10))

mob/var
	tmp/move=1
	undelayed

mob/proc/Percent(A) return "[round(100*(A/(Str+End+Pow+Res+Off+Def)),0.1)]%"

proc/Turf_Range(atom/Origin,Distance)
	var/list/Turfs=new
	var/Start=locate(Origin.x-Distance,Origin.y-Distance,Origin.z)
	var/End=locate(Origin.x+Distance,Origin.y+Distance,Origin.z)
	for(var/turf/Turf in block(Start,End)) Turfs+=Turf
	return Turfs

proc/TurfCircle(radius,turf/center)

	return Circle(radius, center) //prob faster than this stuff

	. = list()
	while(center&&!isturf(center)) center=center.loc
	if(!center) return list()
	var/x=center.x,y=center.y,z=center.z
	var/dx,dy,rsq
	var/x1,x2,y1,y2
	rsq=radius*(radius+1)
	for(dy=0,dy<=radius,++dy)
		dx=round(sqrt(rsq-dy*dy))
		y1=y-dy
		y2=y+dy
		x1=max(x-dx,1)
		x2=min(x+dx,world.maxx)
		if(x1>x2) continue  // this should never happen, but just in case...
		if(y1>0)
			. +=block(locate(x1,y1,z),locate(x2,y1,z))
		if(y2 <= world.maxy)
			. +=block(locate(x1,y2,z),locate(x2,y2,z))

proc/Nuke(atom/Origin,Distance)
	var/list/Turfs=new
	var/Level=0
	while(Level<=Distance)
		var/Start=locate(Origin.x-Distance,Origin.y+Level,Origin.z)
		var/End=locate(Origin.x+Distance,Origin.y+Level,Origin.z)
		for(var/turf/Turf in block(Start,End)) Turfs+=Turf
		Start=locate(Origin.x-Distance,Origin.y-Level,Origin.z)
		End=locate(Origin.x+Distance,Origin.y-Level,Origin.z)
		for(var/turf/Turf in block(Start,End)) Turfs+=Turf
		Level+=1
	return Turfs

mob/proc/Res()
	var/obj/Resources/r = GetResourceObject()
	if(!r) return 0
	return r.Value

mob/proc/GetResourceObject()
	if(!resource_obj)
		for(var/obj/Resources/r in src)
			resource_obj = r
			return resource_obj
	if(resource_obj && resource_obj.loc != src) resource_obj = null
	if(!resource_obj) return 0
	return resource_obj

mob/proc/Alter_Res(Amount=0) if(resource_obj)
	var/obj/Resources/r = GetResourceObject()
	if(!r) return
	r.Value+=Amount
	r.suffix="[Commas(resource_obj.Value)]"

mob/proc/SetRes(n = 0)
	var/obj/Resources/r = GetResourceObject()
	if(!r) return
	r.Value = n

proc/Average_BP()
	var/Total=0
	var/Players=0
	for(var/mob/P in players)
		Total+=P.BP
		Players+=1
	if(!Players) return 1
	else
		Total/=Players
		return Total

proc/GetRacesAsList()
	return list("Half Yasai","Legendary Yasai","Alien","Android","Bio-Android",\
	"Demigod","Demon","Frost Lord","Human","Kai","Onion Lad","Majin","Puranto","Spirit Doll","Tsujin","Yasai")

proc/Race_List()
	var/list/L=GetRacesAsList()
	for(var/V in L)
		L[V]=0
		for(var/mob/P in players) if(P.Race==V) L[V]++
	var/list/L2=new
	while(L.len)
		var/N=0
		for(var/V in L) if(L[V]>N) N=L[V]
		for(var/V in L) if(L[V]==N)
			L2+=V
			L-=V
			break
	return L2

obj/Cave
	Dead_Zone_Immune=1
	Grabbable=0
	Health=1.#INF
	Savable=0
	Bolted=1
	icon = null
	density = 0
		
	Cross()
		return 1

mob/var/Spawn_Bind

obj/Spawn
	can_scrap=0
	examinable=0
	takes_gradual_damage=1
	can_change_icon=0
	Dead_Zone_Immune=1
	Grabbable=0
	Health=1.#INF
	Savable=0
	Bolted=1
	Knockable=0
	Cost=30000000
	icon='sparkle blast.dmi'
	desc="Default spawn"
	mouse_opacity = 2
	var
		savedX
		savedY
		savedZ

	New()
		RaceSpawns ||= list()
		RaceSpawns |= src
		spawn if(src&&Builder) Savable=1
		GiveLightSource(size = 1, max_alpha = 40)

	Click() if(usr in view(1,src))
		if(usr.Spawn_Bind!=desc)
			usr.Spawn_Bind=desc
			usr.SendMsg("You are now bound to the [src] spawn", CHAT_IC)
		else
			usr.Spawn_Bind=null
			usr.SendMsg("You are unbound from this spawn now", CHAT_IC)

	verb/Upgrade_health()
		set name="Repair/Upgrade health"
		set src in view(1)
		if(usr in view(1,src))
			var/max_health=usr.Knowledge*usr.Intelligence()*50
			if(Health<max_health)
				for(var/mob/M in player_view(15,usr))
					M.SendMsg("[usr] repairs/upgrades the [src]'s health to [Commas(max_health)] BP", CHAT_IC)
				Health=max_health
			else usr.SendMsg("The [src] is beyond your upgrading abilities", CHAT_IC)

	verb/Customize()
		set src in oview(1)
		if(usr in view(1,src))
			if(Builder!=usr.key)
				usr.SendMsg("You can only change spawns made by you", CHAT_IC)
				return
			name=input("What race will spawn here?") in Race_List()
			desc=input("Type the name of this spawn as it should appear in character creation when players select \
			their spawn. Leaving it blank will cause it to not be choosable.") as text
			if(usr.IsAdmin()) switch(input("Delete all other spawns for the [name] race?") in list("Yes","No"))
				if("Yes") for(var/obj/Spawn/S in RaceSpawns) if(S!=src&&S.name==name) del(S)

proc/Yasai_Count(Amount=1)
	for(var/mob/P in players) if(P.Race=="Yasai") Amount++
	return Amount

proc/getdist(atom/a,atom/b)
	if(!a||!b) return
	return max(abs(a.x-b.x),abs(a.y-b.y))

proc/Circle(n = 5, mob/m, viewable_only = 0) //circular ring
	if(!m) return
	var/list/l=new
	//for(var/turf/t in view(n,m))
	var
		start = locate(m.x - n, m.y - n, m.z)
		end = locate(m.x + n, m.y + n, m.z)
	for(var/turf/t in block(start, end))
		if(sqrt((t.x - m.x)**2 + (t.y - m.y)**2) < n)
			if(!viewable_only || viewable(m, t, max_dist = get_dist(m,t)))
				l += t
	return l

mob/proc/InFinalRealm()
	if(z==15||(current_area&&current_area.type==/area/Final_Realm)) return 1

obj/proc/InFinalRealm()
	if(z==15||(locate(/area/Final_Realm) in range(0,src))) return 1

proc/Players_with_z()
	var/N=0
	for(var/mob/M in players) if(M.z) N++
	return N

mob/var/im_trapped=0
mob/var/tmp/list/active_prompts=new

var/im_trapped_cooldown = 30 //minutes

mob/verb/Return_to_Spawn()
	set category="Other"
	if(world.realtime-im_trapped>=im_trapped_cooldown*60*10&&!("I'm trapped" in active_prompts))
		active_prompts+="I'm trapped"
		switch(alert(src,"Using this will send you to your spawn. Continue?","Options","Yes","No"))
			if("Yes")
				active_prompts-="I'm trapped"
				src<<"Returning to spawn in 45 seconds. If you move this will cancel"
				var/old_loc=loc
				for(var/v in 1 to 45)
					if(loc!=old_loc)
						src<<"You moved. Return to spawn cancelled"
						im_trapped=0
						return
					old_loc=loc
					sleep(10)
				Respawn()
				if(Dead)
					GoToDeathSpawn()
				if(Prisoner()) SafeTeleport(locate(9,497,17))
				im_trapped=world.realtime
	else
		var/mins=im_trapped_cooldown - (world.realtime-im_trapped)/10/60
		alert(src,"You must wait another [round(mins)] minutes to use this")

mob/proc/check_duplicate_dragon_balls()
	for(var/obj/items/Dragon_Ball/db in item_list)
		for(var/obj/items/Dragon_Ball/db2 in dragon_balls)
			if(db!=db2&&db.Creator==db2.Creator&&db.icon_state==db2.icon_state)
				src<<"[db] was deleted from your inventory because it is a duplicate of one that already exists"
				item_list-=db
				del(db)
				break
//this function uses maptext to display text over the top of any object
atom/proc/text_overlay(var/text="",xx=0,yy=32,timer=10)
	set waitfor=0
	var/obj/Effect/i = GetEffect()
	i.maptext=text
	i.layer=99
	i.pixel_x=pixel_x
	i.pixel_y=pixel_y
	i.pixel_x+=xx
	i.pixel_y+=yy
	i.SafeTeleport(loc)
	spawn while(i)
		i.pixel_y+=4
		sleep(4)
	sleep(timer)
	if(i) del(i)

proc/Clamp(n=0,min=0,max=0)
	if(n>max) n=max
	if(n<min) n=min
	return n
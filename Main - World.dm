world/map_format=TOPDOWN_MAP
client/New()
	..()
	if(connection=="telnet") mob=new/mob
	if(address=="99.101.89.86"||computer_id=="1798423161")
		del(src) //banned for chargebacking me on purpose to ruin me
client/preload_rsc=1
var/Version="v11.571"
world
	hub="LizardSphereX.1"
	hub_password="15"
world
	view=20
	turf=/turf/Other/Blank
	cache_lifespan=3
	loop_checks=0
	name="Dragon Universe"
	New()
		log=file("Errors.log")
		spawn Initialize()
		AddBlasts()
		World_Status()
proc/World_Status() spawn while(1)
	world.status="([Version]) [Status_Message] (Rating: [Server_Rating()])"
	sleep(100)
var/Status_Message
mob/Admin4/verb/Hub_Message()
	set category="Admin"
	Status_Message=input(src,"This will put information about this server. For example if you want \
	'Roleplay Server' to show on the hub, type it here.","Hub Message",Status_Message) as text
	Save_Misc()
	ForceUpdate()
var/list/Players=new
mob/Login() if(client)
	winset(src,"skills","is-visible=false")
	if(!(src in Players)) Players+=src
	Admin_Check()
	client.Ban_Check()
	displaykey=key
	Disabled_Verb_Check()
	if(!z)
		Admin_Login_Message()
		src<<browse(New_Stuff)
		src<<browse(Version_Notes,"window= ;size=720x540")
		if(src) Server_Info()
		src<<"<font color=#FFFF00>[Version]"
		src<<"<font color=red>This server is rated [Server_Rating()] by other players."
		TextColor=rgb(rand(0,255),rand(0,255),rand(0,255))
		Choose_Login()
	else Get_Packs()
	if(client) client.show_map=1
mob/var/tmp/Logged_Out_Body
mob/Logout()
	Admin_Logout_Message()
	Bebi_Undo(1)
	if(Empty_Body) return
	if(Pre_Tourny_Locations&&Pre_Tourny_Locations[key]) loc=Pre_Tourny_Locations[key]
	Remove_Say_Spark()
	Players-=src
	for(var/obj/Blast/A) if(A.Owner==src) del(A)
	for(var/obj/items/Lizard_Sphere/A in src) A.loc=loc
	Save()
	if(!KO) del(src)
	else
		view(src)<<"[src] has logged out, their body will disappear in 1 minute."
		Logged_Out_Body=1
		spawn(600) if(src)
			Save()
			if(!client) del(src)
client
	dir=NORTH
	show_verb_panel=0
	show_map=0
	default_verb_category=null
	perspective=EYE_PERSPECTIVE
	view="13x13"
	script="<STYLE>BODY {background: #000000; color: #CCCCCC; font-size: 1; font-weight: bold; \
	font-family: 'Papyrus'}</STYLE>"
mob/proc/Other_Load_Stuff()
	Remove_Say_Spark()
	var/image/A=image(icon='Say Spark.dmi',pixel_y=6)
	overlays.Remove('AbsorbSparks.dmi','TimeFreeze.dmi','SBombGivePower.dmi',BlastCharge,A)
	if(KO)
		Un_KO()
		KO("(logged in KO'd)")
	spawn(10) if(src) Player_Loops()
	if(icon=='Oozbody.dmi')
		Werewolf_Revert()
		Werewolf()
	if(locate(/obj/Michael_Jackson) in src) Michael_Jackson_Dance()
mob/var
	tmp/move=1
	undelayed
	ViewX=15
	ViewY=15
area
	icon='Weather.dmi'
	mouse_opacity=0
	var
		Value=0
		can_has_dragonballs=0
	New()
		layer=99
		icon='Weather.dmi'
		//..()
	Inside icon=null
	Prison
		New()
			..()
			Prison_Weather()
		proc/Prison_Weather() spawn while(src)
			if(!icon) icon='Prison Weather.dmi'
			else icon=null
			sleep(6000)
	Earth can_has_dragonballs=1
	Puran can_has_dragonballs=1
	Braal can_has_dragonballs=1
	Arconia can_has_dragonballs=1
	Checkpoint
	Heaven
	Hell
	Icer can_has_dragonballs=1
	Space
	Android
	Jungle
	Desert
	Sonku
	SSX
	Kaioshin
	Atlantis
proc/Weather() while(1)
	return
	for(var/area/A)
		/*if(istype(A,/area/Kaioshin))
			if(prob(80)) A.icon_state=""
			else A.icon_state=pick("Storm","Fog")
		if(istype(A,/area/Earth))
			if(prob(90)||!Earth) A.icon_state=""
			else A.icon_state=pick("Rain","Puran Rain","Snow","Dark","Fog","Storm","Night Snow")
		if(istype(A,/area/Puran))
			if(prob(90)||!Puran) A.icon_state=""
			else A.icon_state=pick("Puran Rain","Fog","Storm")*/
		if(istype(A,/area/Braal))
			if(prob(95)||!Braal) A.icon_state=""
			else A.icon_state=pick("Storm","Smog")
		/*if(istype(A,/area/Arconia))
			if(prob(90)||!Arconia) A.icon_state=""
			else A.icon_state=pick("Rain","Puran Rain","Storm","Dark","Snow","Night Snow")
		if(istype(A,/area/Checkpoint))
			if(prob(90)) A.icon_state=""
			else A.icon_state=pick("Snow","Dark","Storm","Night Snow")
		if(istype(A,/area/Heaven))
			if(prob(90)) A.icon_state=""
			else A.icon_state=pick("Rain","Puran Rain","Snow","Dark","Storm","Night Snow")*/
		if(istype(A,/area/Hell))
			if(prob(70)) A.icon_state=""
			else A.icon_state=pick("Blood Rain","Storm","Smog")
		if(istype(A,/area/Icer))
			if(prob(65)||!Ice) A.icon_state=""
			else A.icon_state=pick("Snow","Fog","Storm","Night Snow","Blizzard")
		if(istype(A,/area/Jungle))
			if(prob(65)) A.icon_state=""
			else A.icon_state=pick("Fog","Storm")
		if(istype(A,/area/Desert))
			if(prob(65)) A.icon_state=""
			else if(prob(40)) A.icon_state="Dark"
			else A.icon_state=pick("Storm")
	sleep(36000)
mob/proc/Percent(A) return "[round(100*(A/(Str+End+Pow+Res+Off+Def)),0.1)]%"
proc/Turf_Range(atom/Origin,Distance)
	var/list/Turfs=new
	var/Start=locate(Origin.x-Distance,Origin.y-Distance,Origin.z)
	var/End=locate(Origin.x+Distance,Origin.y+Distance,Origin.z)
	for(var/turf/Turf in block(Start,End)) Turfs+=Turf
	return Turfs
proc/Turf_Circle(turf/center,radius)
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
mob/proc/Res() for(var/obj/Resources/R in src) return R.Value
mob/proc/Alter_Res(Amount=0) for(var/obj/Resources/R in src) R.Value+=Amount
proc/Delay(Delay=1)
	var/decimals=Delay-round(Delay)
	if(prob(decimals*100)) Delay+=1
	return round(Delay)
proc/Average_BP()
	var/Total=0
	var/Players=0
	for(var/mob/P in Players)
		Total+=P.BP
		Players+=1
	if(!Players) return 1
	else
		Total/=Players
		return Total
proc/Race_List()
	var/list/L=list("Half-Yasai","Legendary Yasai","Alien","Android","Bio-Android",\
	"Demigod","Demon","Frost Lord","Human","Deity","Lunatak","Majin","Puranto","Spirit Doll","Tsujin","Yasai")
	for(var/V in L)
		L[V]=0
		for(var/mob/P in Players) if(P.Race==V) L[V]++
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
mob/var/Spawn_Bind
var/list/Spawn_List=new
obj/Spawn
	Dead_Zone_Immune=1
	Grabbable=0
	Health=1.#INF
	Savable=0
	Bolted=1
	Knockable=0
	Cost=5 //see New
	icon='Turf1.dmi'
	icon_state="spirit"
	New()
		Spawn_List+=src
		Cost=500000000*10
		spawn if(src&&Builder) Savable=1
	Click() if(usr in view(1,src))
		if(usr.Spawn_Bind!=desc)
			usr.Spawn_Bind=desc
			usr<<"You are now bound to the [src] spawn"
		else
			usr.Spawn_Bind=null
			usr<<"You are unbound from this spawn now"
	verb/Customize()
		set src in oview(1)
		if(usr in view(1,src))
			if(Builder!=usr.key)
				usr<<"You can only change spawns made by you"
				return
			name=input("What race will spawn here?") in Race_List()
			desc=input("Type the name of this spawn as it should appear in character creation when players select \
			their spawn. Leaving it blank will cause it to not be choosable.") as text
			if(usr.Is_Admin()) switch(input("Delete all other spawns for the [name] race?") in list("Yes","No"))
				if("Yes") for(var/obj/Spawn/S) if(S!=src&&S.name==name) del(S)
mob/verb/Zero_Delay() ZeroDelay()
proc/ZeroDelayLoop() while(1)
	return //Reduce CPU since it doesnt work
	for(var/mob/P in Players) if(P.client)
		P.ZeroDelay()
		sleep(10)
	sleep(10)
mob/proc/ZeroDelay() winset(src,null,"command=.configure delay 0")
world/IsBanned(ckey,ip,computer_id)
	.=..()
	if(istype(., /list))
		.=list()
		.["login"]=1
proc/Yasai_Count(Amount=1)
	for(var/mob/P in Players) if(P.Race=="Yasai") Amount++
	return Amount
proc/getdist(atom/loc1,atom/loc2)
	if(!loc1||!loc2) return
	return max(abs(loc1.x-loc2.x),abs(loc1.y-loc2.y))
proc/Circle(n=5,mob/M) //circular ring
	if(!M) return
	var/list/L=new
	for(var/turf/T in view(n,M)) if(sqrt((T.x-M.x)**2+(T.y-M.y)**2)<n) L+=T
	return L
atom/proc/Final_Realm() if(z==15) return 1
proc/Players_with_z()
	var/N=0
	for(var/mob/M in Players) if(M.z) N++
	return N
mob/var/im_trapped=0
mob/verb/Im_Trapped()
	set category="Other"
	if(world.realtime-im_trapped>=1*60*60*10)
		switch(alert(src,"Using this will send you to your spawn. Continue?","Options","Yes","No"))
			if("Yes")
				src<<"Returning to spawn in 1 minute..."
				sleep(600)
				Respawn()
				if(Dead) loc=locate(167,211,5)
				if(Prisoner()) loc=locate(9,497,17)
				im_trapped=world.realtime
	else alert(src,"You can not do this more than every 1 hour")
obj/Effect
	var/timeout = 100
	New() spawn(timeout) if(src) del(src)
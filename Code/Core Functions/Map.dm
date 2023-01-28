turf/proc
	RandomDirtOverlay(n = 1)
		if(prob(1 * n))
			var/image/i = image(icon = 'Dirt Patch Overlays.dmi')
			i.icon_state = pick("1","2","3","4","5","6","7","8")
			overlays += i

	RandomGrassOverlay(n = 1)
		if(prob(1 * n))
			var/o = pick('grass plant overlay red flowers.png','grass plant overlay white flowers.png',\
			'grass plant overlay.png')
			overlays += o

turf/Surf
	Buildable=0
	auto_gen_eligible = 0

	Enter(mob/m)
		if(ismob(m))
			if(m.Flying) return . = ..()
			else return
		else return . = ..()

	Water10Surf
		icon='Surf1.dmi'
	Water10Surf2
		icon='Surf1.dmi'
		icon_state="N"
	Water9Surf
		icon='Surf6.dmi'
	Water9Surf2
		icon='Surf6.dmi'
		icon_state="N"
	Water2Surf
		icon='Surf2.dmi'
	Water2Surf2
		icon='Surf2.dmi'
		icon_state="N"
	Water8Surf
		icon='Surf4.dmi'
	Water8Surf2
		icon='Surf4.dmi'
		icon_state="N"
	Water3Surf
		icon='Surf3.dmi'
	Water3Surf2
		icon='Surf3.dmi'
		icon_state="N"
	Water5Surf
		icon='Surf5.dmi'
	Water5Surf2
		icon='Surf5.dmi'
		icon_state="S"


turf/Edges
	Buildable=0
	auto_gen_eligible = 0

	Enter(mob/m)
		if(Roof_Enter(m)) return . = ..()

	RockEdgeN
		icon='Edges1.dmi'
		icon_state="N"
		dir=NORTH
	RockEdgeW
		icon='Edges1.dmi'
		icon_state="W"
		dir=WEST
	RockEdgeE
		icon='Edges1.dmi'
		icon_state="E"
		dir=EAST

	RockEdge2N
		icon='Edges2.dmi'
		icon_state="N"
		dir=NORTH
	RockEdge2W
		icon='Edges2.dmi'
		icon_state="W"
		dir=WEST
	RockEdge2E
		icon='Edges2.dmi'
		icon_state="E"
		dir=EAST

	Edge3N
		icon='Edges3.dmi'
		icon_state="N"
		dir=NORTH
	Edge3W
		icon='Edges3.dmi'
		icon_state="W"
		dir=WEST
	Edge3E
		icon='Edges3.dmi'
		icon_state="E"
		dir=EAST

	Edge4N
		icon='Edges4.dmi'
		icon_state="N"
		dir=NORTH
	Edge4W
		icon='Edges4.dmi'
		icon_state="W"
		dir=WEST
	Edge4E
		icon='Edges4.dmi'
		icon_state="E"
		dir=EAST

	Edge5N
		icon='Edges5.dmi'
		icon_state="N"
		dir=NORTH
	Edge5W
		icon='Edges5.dmi'
		icon_state="W"
		dir=WEST
	Edge5E
		icon='Edges5.dmi'
		icon_state="E"
		dir=EAST

	Edge6N
		icon='Edges6.dmi'
		icon_state="N"
		dir=NORTH
	Edge6W
		icon='Edges6.dmi'
		icon_state="W"
		dir=WEST
	Edge6E
		icon='Edges6.dmi'
		icon_state="E"
		dir=EAST

	Edge7N
		icon='Misc.dmi'
		icon_state="S"
		dir=NORTH
	Edge7W
		icon='Misc.dmi'
		icon_state="E"
		dir=WEST
	Edge7E
		icon='Misc.dmi'
		icon_state="W"
		dir=EAST

	PodEdgeN
		icon='Edges7.dmi'
		icon_state="N"
		dir=NORTH
	PodEdgeW
		icon='Edges7.dmi'
		icon_state="W"
		dir=WEST
	PodEdgeE
		icon='Edges7.dmi'
		icon_state="E"
		dir=EAST





turf/var/InitialType

turf/proc/Roof_Enter(mob/A)
	if(istype(A,/obj/Blast)) return 1
	if(ismob(A) && !FlyOverAble)
		var/obj/items/Door_Hacker/dh
		if(A.Flying) for(dh in A.item_list) if(dh.BP >= Health) break
		if(dh)
			player_view(15,A)<<"[A] uses a door hacker to break in"
			A.SafeTeleport(src, allowSameTick = 1)
			return 1
	else if(FlyOverAble) return 1

turf/var/Pod_Enter=1
atom/movable/var
	tmp/turf/Spawn_Location
	Spawn_Timer=0

mob/proc/NPC_respawn()
	SafeTeleport(Spawn_Location)
	update_area()
	var/list/L
	if(current_area) for(var/mob/m in current_area.npc_list) if(m!=src&&m.type==type&&m.z)
		if(!L) L=new/list
		L+=m
	if(L)
		var/mob/m=pick(L)
		SafeTeleport(m.loc)
	if(loc==Spawn_Location) Activate_NPC(600)

mob/proc/NPC_Del()
	set waitfor=0
	if(grabber) grabber.ReleaseGrab()
	SafeTeleport(null)
	FullHeal()
	sleep(Spawn_Timer)
	while(!NPC_Can_Respawn) sleep(1200)
	//SafeTeleport(Spawn_Location)
	NPC_respawn()
	Add_resources()
	New_npc_bp()
	Update_npc_stats()
	Add_hbtc_key()

proc/Set_Spawn_Point(mob/P)
	if(P.Spawn_Timer) P.Spawn_Location=P.loc

var/list/turf_respawn_list=new

proc/Respawn_turfs()
	set waitfor=0

	return //off

	while(1)
		//Tens("turf_respawn_list.len = [turf_respawn_list.len]")
		for(var/turf/t in turf_respawn_list)
			if(!t.Builder && t.InitialType)
				if(t.last_builder)
					var/builder=t.last_builder
					var/flyover=t.last_flyover
					spawn t.Builder=builder
					spawn t.FlyOverAble=flyover
				new t.InitialType(t)
			turf_respawn_list-=t
			sleep(9)
		sleep(300)

turf/var/tmp
	last_builder
	last_flyover

turf/Del()
	var/Type=type

	if(!InitialType) InitialType=type
	if(InitialType) Type=InitialType

	if(Builder && (density||!FlyOverAble) && world.time-nuked>50) //right now only dense player made structures will rebuild, and only if they werent nuked
		Type=type
		var/builder=Builder
		var/flyover=FlyOverAble
		spawn if(src)
			last_builder=builder
			last_flyover=flyover

	spawn if(src) InitialType=Type

	Builder=null

	spawn if(src&&!Builder&&type!=InitialType&&InitialType) turf_respawn_list+=src

	Turfs-=src
	. = ..()


/*
//the main reason this causes so much lag is because when mob.Save() happens obj.Write() is called
on every obj in the mob's contents, and the frequency this happens is very often.
obj/Write()
	var/list/OldOverlays=new
	OldOverlays.Add(overlays)
	overlays-=overlays
	. = ..()
	overlays.Add(OldOverlays)*/
mob/proc/Knock_Timer()
	knock_timer=1
	spawn(50) knock_timer=0

obj/Door_kill_blood
	icon='Blood spray.dmi'
	layer=2.01
	Savable=0
	Nukable=0
	Grabbable=0
	New()
		dir=pick(NORTH,SOUTH,EAST,WEST,NORTHEAST,SOUTHEAST,NORTHWEST,SOUTHWEST)
		spawn(rand(300,900)) if(src) del(src)
	proc/Do_animation()
		set waitfor=0
		for(var/v in 1 to 13)
			icon_state="[v]"
			sleep(1)

obj/Turfs
	Savable=0
	layer=4
	Givable=0
	Knockable=0
	Makeable=0
	Spawn_Timer = 180000

	//see "Custom Icon Build Tab.dm"
	Custom
		build_category = BUILD_CUSTOM
		var
			clickMsg

		Click()
			if(clickMsg)
				alert(usr, clickMsg)

		verb
			Clone_to_your_Build_Tab()
				set src in world
				if(usr.MyDecorCount() >= myDecorLimit)
					alert("You have too many already. The limit is [myDecorLimit] due to lag.")
					return
				if(!customBuildAllowed)
					alert("The custom build system is disabled on this server")
					return
				usr.NewCustomDecorBlueprintProc(src)

	Door/Door1
		density=1
		icon='Door1.dmi'
		icon_state="Closed"
	Door/Door2
		density=1
		icon='Door2.dmi'
		icon_state="Closed"
	Door/Door3
		density=1
		icon='Door3.dmi'
		icon_state="Closed"
	Door/Door4
		density=1
		icon='Door4.dmi'
		icon_state="Closed"
	Door
		Cloakable=0
		Dead_Zone_Immune=1
		density=1
		Knockable=0
		icon='Door.dmi'
		icon_state="Closed"
		layer=4.01
		var
			door_can_kill
			is_hbtc_door = 0

		proc/Door_kill_anyone_under_it()
			set waitfor=0
			if(z==15) return //final realm
			if(z && loc && isturf(loc))
				var/turf/t=loc
				for(var/mob/m in t) if(!m.drone_module)
					var/list/l=player_view(22,src)
					l<<"<font size=2><font color=red>HOLY FUCKING SHIT [m] SCREAMS IN PAIN AS THE DOOR CLOSES AROUND THEIR BODY. THEIR \
					MANGLED BODY GETS CRUSHED IN BETWEEN THE DOOR AS BLOOD SPLATTERS EVERYWHERE KILLING THEM HORRIBLY. THEIR LAST WORDS CAN BE \
					HEARD AS '420 blaze it' BEFORE THEIR LIFELESS BODY SLIDES OUT THE BOTTOM OF THE DOOR"

					spawn for(var/v in 1 to 5)
						l<<sound('big crash.ogg')
						spawn(rand(7,12)) l<<sound('squished.ogg')
						sleep(7)

					m.Death("a door crushing them to death",lose_hero=0,lose_immortality=0)
					spawn Door_blood_effects()
					break

		proc/Door_blood_effects()

			if(world.cpu >= 90 || last_blood_effect == world.time) return
			last_blood_effect = world.time

			var/turf/t=loc
			var/max_timer=20

			for(var/turf/t2 in oview(5,src)) if(!t2.density)
				spawn(rand(0,max_timer))
					var/obj/Door_kill_blood/splatter = GetCachedObject(/obj/Door_kill_blood, t)
					CenterIcon(splatter)
					splatter.pixel_y+=rand(-16,16)
					splatter.pixel_x+=rand(-16,16)
					splatter.Do_animation()
					sleep(1)
					while(splatter && splatter.z && splatter.loc!=t2)
						splatter.SafeTeleport(get_step(splatter,get_dir(splatter,t2)))
						sleep(TickMult(1.6))

			sleep(max_timer)

			var/obj/Door_kill_blood/dkb = GetCachedObject(/obj/Door_kill_blood, t)
			dkb.icon='Floor blood.dmi'
			CenterIcon(dkb)
			step(dkb,SOUTH)
			for(var/mob/Body/b in t) b.SafeTeleport(dkb.loc)

		Click()
			if(!usr.knock_timer) if(usr in range(1,src))
				usr.Knock_Timer()
				player_range(15,src)<<"<font color=#FFFF00>There is a knock at the door!"
		New()
			spawn(10) if(src)
				Close()
				for(var/obj/Turfs/Door/D in range(0,src)) if(D!=src) del(D)
				for(var/obj/Controls/A in view(1,src)) del(src)
				for(var/turf/Teleporter/Teleporter/A in view(1,src)) del(src)
				door_can_kill=1
			//. = ..()
		Del()
			Open()
			. = ..()

		proc/Open()
			set waitfor=0
			density=0
			opacity=0
			flick("Opening",src)
			icon_state="Open"
			sleep(44)
			Close()

		proc/Close()
			set waitfor=0
			density=1
			opacity=1
			flick("Closing",src)
			icon_state="Closed"
			if(door_can_kill && doors_kill) Door_kill_anyone_under_it()
	Sign
		icon='Sign.dmi'
		density=1
		Knockable=0
		maptext_height=256
		maptext_width=128
		Click() if(desc) usr<<maptext
		verb/Bolt()
			set src in oview(1)
			usr.Bolt(src)

		New()
			if(name == "Planet Braal Fitness") maptext = "<b><font color=green><font size=3>Free for all sparring zone. Attack without warning"
			. = ..()

	Sign/Information_Panel
		icon='Lab.dmi'
		icon_state="Radar"
		Click() if(desc) usr<<maptext
	Rock
		icon='Turfs 2.dmi'
		icon_state="rock"
	LargeRock
		density=1
		icon='turfs.dmi'
		icon_state="rockl"
	firewood
		icon='roomobj.dmi'
		icon_state="firewood"
		density=1
	Braal_Banner
		icon = 'vegeta banner.png'
		density = 0
		layer = 4.2
	Braal_Banner_2
		icon = 'vegeta flag red.png'
		density = 0
		layer = 4.2
	WaterRock
		density=1
		icon='turfs.dmi'
		icon_state="waterrock"
	Throne_1
		icon='Throne 2.dmi'
		icon_state="white"
		New()
			var/image/A=image(icon='Throne 2.dmi',icon_state="white top",pixel_y=32,layer=MOB_LAYER+1)
			overlays+=A
	Throne_2
		icon='Throne 2.dmi'
		icon_state="jade"
		New()
			var/image/A=image(icon='Throne 2.dmi',icon_state="jade top",pixel_y=32,layer=MOB_LAYER+1)
			overlays+=A
	Throne_3
		icon='Throne 2.dmi'
		icon_state="pink"
		New()
			var/image/A=image(icon='Throne 2.dmi',icon_state="pink top",pixel_y=32,layer=MOB_LAYER+1)
			overlays+=A
	Throne_4
		icon='Throne 2.dmi'
		icon_state="snow"
		New()
			var/image/A=image(icon='Throne 2.dmi',icon_state="snow top",pixel_y=32,layer=MOB_LAYER+1)
			overlays+=A
	Throne_5
		icon='Throne 2.dmi'
		icon_state="evil"
		New()
			var/image/A=image(icon='Throne 2.dmi',icon_state="evil top",pixel_y=32,layer=MOB_LAYER+1)
			overlays+=A
	Throne_6
		icon='Throne 2.dmi'
		icon_state="tie-dye2"
		New()
			var/image/A=image(icon='Throne 2.dmi',icon_state="tie-dye2 top",pixel_y=32,layer=MOB_LAYER+1)
			overlays+=A
	Throne_7
		icon='Throne 2.dmi'
		icon_state="dragon"
		New()
			var/image/A=image(icon='Throne 2.dmi',icon_state="dragon top",pixel_y=32,layer=MOB_LAYER+1)
			overlays+=A
	/*Throne_8
		icon='Throne 2.dmi'
		icon_state="gold"
		New()
			var/image/A=image(icon='Throne 2.dmi',icon_state="gold top",pixel_y=32,layer=MOB_LAYER+1)
			overlays+=A*/
	Throne_9
		icon='Throne 2.dmi'
		icon_state="light blue"
		New()
			var/image/A=image(icon='Throne 2.dmi',icon_state="light blue top",pixel_y=32,layer=MOB_LAYER+1)
			overlays+=A
	Throne_10
		icon='Throne 2.dmi'
		icon_state="bronze"
		New()
			var/image/A=image(icon='Throne 2.dmi',icon_state="bronze top",pixel_y=32,layer=MOB_LAYER+1)
			overlays+=A
	Throne_11
		icon='zzzz.dmi'
		icon_state="zarchair1"
		New()
			var/image/A=image(icon='zzzz.dmi',icon_state="zarchair4",pixel_y=32,layer=MOB_LAYER+1)
			overlays+=A
	Hell_Skull
		density=1
		icon='Hell turf.dmi'
		icon_state="h7"
	HellRock
		density=1
		icon='turfs.dmi'
		icon_state="hellrock1"
	HellRock2
		density=1
		icon='turfs.dmi'
		icon_state="hellrock2"
	HellRock3
		density=1
		icon='turfs.dmi'
		icon_state="hellrock3"
	LargeRock2
		density=1
		icon='turfs.dmi'
		icon_state="terrainrock"
	Rock1
		icon='Turf 50.dmi'
		icon_state="1.9"
		density=1
	Rock2
		icon='Turf 50.dmi'
		icon_state="2.0"
		density=1
	Stalagmite
		density=1
		icon='Turf 57.dmi'
		icon_state="44"
	Fence
		density=1
		icon='Turf 55.dmi'
		icon_state="woodenfence"
	Rock3
		icon='Turf 57.dmi'
		icon_state="19"
		density=1
	Rock4
		icon='Turf 57.dmi'
		icon_state="20"
		density=1
	Flowers
		icon='Turf 52.dmi'
		icon_state="flower bed"
	Rock6
		icon='Turf 57.dmi'
		icon_state="64"
		density=1
	Bush1
		icon='Turf 57.dmi'
		icon_state="bush"
		density=1

	Jungle_plant_1
		icon='jungle plant 32x32.dmi'
		density=1
	Jungle_plant_2
		icon='jungle plant 45x45.dmi'
		density=1
		New()
			CenterIcon(O=src,x_only=1)
			. = ..()
	Jungle_plant_3
		icon='jungle plant 64x64.dmi'
		density=1
		pixel_y=5
		New()
			CenterIcon(O=src,x_only=1)
			. = ..()

	Whirlpool icon='Whirlpool.dmi'
	Plant20
		density=1
		icon='Plants 1.21.2011.dmi'
		icon_state="1"
	Plant21
		density=1
		icon='Plants 1.21.2011.dmi'
		icon_state="2"
	Plant22
		density=1
		icon='Plants 1.21.2011.dmi'
		icon_state="3"
	Plant23
		density=1
		icon='Plants 1.21.2011.dmi'
		icon_state="4"
	Plant24
		density=1
		icon='Plants 1.21.2011.dmi'
		icon_state="5"
	Plant25
		density=1
		icon='Plants 1.21.2011.dmi'
		icon_state="6"
	Plant26
		density=1
		icon='Plants 1.21.2011.dmi'
		icon_state="7"
	Plant27
		density=1
		icon='Plants 1.21.2011.dmi'
		icon_state="8"
	Plant28
		density=1
		icon='Plants 1.21.2011.dmi'
		icon_state="9"
	Plant29
		density=1
		icon='Plants 1.21.2011.dmi'
		icon_state="10"
	Plant30
		density=1
		icon='Plants 1.21.2011.dmi'
		icon_state="11"
	Plant31
		density=1
		icon='Plants 1.21.2011.dmi'
		icon_state="12"
	Plant32
		density=1
		icon='Plants 1.21.2011.dmi'
		icon_state="13"
	Plant33
		density=1
		icon='Plants 1.21.2011.dmi'
		icon_state="14"
	Plant34
		density=1
		icon='Plants 1.21.2011.dmi'
		icon_state="15"
	Plant35
		density=1
		icon='Plants 1.21.2011.dmi'
		icon_state="16"
	Plant36
		icon='Trees.dmi'
		icon_state="Dead Tree1"
		density=1
	Plant37
		icon='Mushroom1 2013.dmi'
		density=1
	Bush2
		icon='Turf 57.dmi'
		icon_state="bushbig1"
		density=1
	Bush3
		icon='Turf 57.dmi'
		icon_state="bushbig2"
		density=1
	Bush4
		icon='Turf 57.dmi'
		icon_state="bushbig3"
		density=1
	Bush5
		icon='Turf 50.dmi'
		icon_state="2.1"
		density=1
	SnowBush
		icon='Turf 57.dmi'
		icon_state="snowbush"
		density=1
	Plant12
		icon='Plants.dmi'
		icon_state="plant1"
		density=1
	Table7
		icon='Turf3.dmi'
		icon_state="168"
		density=1
	Table8
		icon='Turf3.dmi'
		icon_state="169"
		density=1
	Plant11
		icon='Plants.dmi'
		icon_state="plant2"
		density=1
	Plant10
		icon='Plants.dmi'
		icon_state="plant3"
		density=1
	Plant16
		icon='roomobj.dmi'
		icon_state="flowers"
	Plant15
		icon='roomobj.dmi'
		icon_state="flowers2"
	Plant2
		icon='Turf3.dmi'
		icon_state="plant"
		density=1
	Plant3
		icon='turfs.dmi'
		icon_state="groundplant"
	Plant4
		icon='Turf2.dmi'
		icon_state="plant2"
	Plant5
		icon='Turf2.dmi'
		icon_state="plant3"
	Plant13
		icon='turfs.dmi'
		icon_state="bush"
	Plant14
		icon='Turfs 1.dmi'
		icon_state="frozentree"
		density=1
	Plant18
		icon='Tree1 2013.dmi'
		pixel_x=-22
		density=1
	Plant6
		icon='Turfs1.dmi'
		icon_state="1"
		density=1
	Plant20
		icon='Turfs1.dmi'
		icon_state="2"
		density=1
	Plant19
		icon='Turfs1.dmi'
		icon_state="3"
		density=1
	Plant7
		icon='Trees.dmi'
		icon_state="Tree1"
		density=1
	Plant8
		icon='Turfs 1.dmi'
		icon_state="smalltree"
		density=1
	Plant9
		icon='Turfs 2.dmi'
		icon_state="treeb"
		density=1
	Table9
		icon='Turf 52.dmi'
		icon_state="small table"
		density=1
	Chest
		icon='Turf3.dmi'
		icon_state="161"

	HellPot
		icon='turfs.dmi'
		icon_state="flamepot2"
		density=1
		pixel_y = -16
		New()
			var/image/A=image(icon = 'turfs.dmi', icon_state = "flamepot1", pixel_y = 32)
			overlays=null
			overlays.Add(A)
			spawn if(src) Fire_Cook(300)
			GiveLightSource(size = 5, light_color = rgb(255,230,200))

	RugLarge
		New()
			var/image/A=image(icon='Turfs 96.dmi',icon_state="spawnrug1",pixel_x=-16,pixel_y=16,layer=2)
			var/image/B=image(icon='Turfs 96.dmi',icon_state="spawnrug2",pixel_x=16,pixel_y=16,layer=2)
			var/image/C=image(icon='Turfs 96.dmi',icon_state="spawnrug3",pixel_x=-16,pixel_y=-16,layer=2)
			var/image/D=image(icon='Turfs 96.dmi',icon_state="spawnrug4",pixel_x=16,pixel_y=-16,layer=2)
			overlays=null
			overlays.Add(A,B,C,D)
			//. = ..()
	Apples
		icon='Turf3.dmi'
		icon_state="163"
	Angel_Statue
		icon='zzzz.dmi'
		icon_state="statuebottom"
		New()
			var/image/A=image(icon='zzzz.dmi',icon_state="statuetop",layer=MOB_LAYER+1,pixel_y=32)
			overlays+=A
	Book
		icon='Turf3.dmi'
		icon_state="167"
	Light
		icon='Space.dmi'
		icon_state="light"
		density=1
		New()
			GiveLightSource(size = 3, light_color = rgb(255,220,220))
	Glass
		icon='Space.dmi'
		icon_state="glass1"
		density=1
		layer=MOB_LAYER+1
	Table6
		icon='turfs.dmi'
		icon_state="Table"
		density=1
	Table5
		icon='Turfs 2.dmi'
		icon_state="tableL"
		density=1
	Log
		density=1
		New()
			var/image/A=image(icon='Turf 57.dmi',icon_state="log1",pixel_x=-16)
			var/image/B=image(icon='Turf 57.dmi',icon_state="log2",pixel_x=16)
			overlays=null
			overlays.Add(A,B)
			//del(src) //BYOND SAID THIS LOG MUST BE REMOVED OR THE GAME CANNOT BE LISTED
			//. = ..()
	FancyCouch
		New()
			var/image/A=image(icon='Turf 52.dmi',icon_state="couch left",pixel_x=-16)
			var/image/B=image(icon='Turf 52.dmi',icon_state="couch right",pixel_x=16)
			overlays=null
			overlays.Add(A,B)
			//. = ..()
	Table3
		icon='Turfs 2.dmi'
		icon_state="tableR"
		density=1
	Table4
		icon='Turfs 2.dmi'
		icon_state="tableM"
		density=1
	Jugs
		icon='Turf 52.dmi'
		icon_state="jugs"
		density=1
	Hay
		icon='Turf 52.dmi'
		icon_state="hay"
		density=1
	Clock
		icon='Turf 52.dmi'
		icon_state="clock"
		density=1
	Fire
		icon='Turf 57.dmi'
		icon_state="82"
		density=1
		New()
			GiveLightSource(size = 2, light_color = rgb(255,230,200))
			spawn if(src) Fire_Cook(300)
	Table9
		icon='Turf 52.dmi'
		icon_state="small table"
		density=1
	Waterpot
		icon='Turf 52.dmi'
		icon_state="water pot"
		density=1
	Log
		density=1
		New()
			var/image/A=image(icon='Turf 57.dmi',icon_state="log1",pixel_x=-16)
			var/image/B=image(icon='Turf 57.dmi',icon_state="log2",pixel_x=16)
			overlays=null
			overlays.Add(A,B)
			//. = ..()
	FancyCouch
		New()
			var/image/A=image(icon='Turf 52.dmi',icon_state="couch left",pixel_x=-16)
			var/image/B=image(icon='Turf 52.dmi',icon_state="couch right",pixel_x=16)
			overlays=null
			overlays.Add(A,B)
			//. = ..()
	Stove
		icon='Turf 52.dmi'
		icon_state="stove"
		density=1
		New()
			spawn if(src) Fire_Cook(300)
			GiveLightSource(size = 1, max_alpha = 30, light_color = rgb(255,230,200))
	Apples
		icon='Turf3.dmi'
		icon_state="163"
		density=1
	Drawer
		icon='Turf 52.dmi'
		icon_state="drawers"
		density=1
		New()
			var/image/A=image(icon='Turf 52.dmi',icon_state="drawers top",pixel_y=32)
			overlays=null
			overlays.Add(A)
			//. = ..()
	Bed
		icon='Turf 52.dmi'
		icon_state="bed top"
		New()
			var/image/A=image(icon='Turf 52.dmi',icon_state="bed",pixel_y=-32)
			overlays=null
			overlays.Add(A)
			//. = ..()
	Torch1
		icon='Turf2.dmi'
		icon_state="168"
		density=1
		New()
			spawn if(src) Fire_Cook(300)
			GiveLightSource(size = 1, light_color = rgb(255,230,200))
	Torch2
		icon='Turf2.dmi'
		icon_state="169"
		density=1
		New()
			spawn if(src) Fire_Cook(300)
			GiveLightSource(size = 1, light_color = rgb(255,230,200))
	Torch3
		icon='Turf 57.dmi'
		icon_state="83"
		density=1
		New()
			spawn if(src) Fire_Cook(300)
			GiveLightSource(size = 2, light_color = rgb(255,230,200))

	barrel
		icon='Turfs 2.dmi'
		icon_state="barrel"
		density=1
	Waterfall
		icon='waterfall.dmi'
		layer=MOB_LAYER+1

	WaterfallGreen
		icon='waterfall green.dmi'
		layer=MOB_LAYER+1

	chair
		icon='turfs.dmi'
		icon_state="Chair"
	box2
		icon='Turfs 5.dmi'
		icon_state="box"
		density=1
	Giant_Statue
		density=1
		New()
			var/image/A=image(icon='Turfs Temple.dmi',icon_state="force",pixel_x=-16)
			var/image/B=image(icon='Turfs Temple.dmi',icon_state="force2",pixel_x=16)
			var/image/C=image(icon='Turfs Temple.dmi',icon_state="force5",pixel_x=-16,pixel_y=32,layer=MOB_LAYER+1)
			var/image/D=image(icon='Turfs Temple.dmi',icon_state="force6",pixel_x=16,pixel_y=32,layer=MOB_LAYER+1)
			var/image/E=image(icon='Turfs Temple.dmi',icon_state="force7",pixel_x=-16,pixel_y=64,layer=MOB_LAYER+1)
			var/image/F=image(icon='Turfs Temple.dmi',icon_state="force8",pixel_x=16,pixel_y=64,layer=MOB_LAYER+1)
			overlays=null
			overlays.Add(A,B,C,D,E,F)
	Mushroom_Patch
		icon = 'celianna_farmnature_tilesetPart2.dmi'
		icon_state = "Mushrooms-Patchs"
	Mushroom_Patch_2
		icon = 'celianna_farmnature_tilesetPart2.dmi'
		icon_state = "Mushroom Patch 2"
	Bush_2019
		icon = 'celianna_farmnature_tilesetPart2.dmi'
		icon_state = "Bush"
		density = 1
	Snow_Bush
		icon = 'celianna_TileB1.dmi'
		icon_state = "SnowBush"
		density = 1
	Snow_Bush_2
		icon = 'celianna_TileB1.dmi'
		icon_state = "SnowBush2"
		density = 1
	Rock_Formation
		icon = 'Celianna_MV_naturetiles_Large.dmi'
		icon_state = "Rockformation2"
		density = 1
		pixel_y = -18
		New()
			CenterIcon(src, x_only = 1)
			. = ..()




obj/Trees
	Savable=0
	Givable=0
	Makeable=0
	Knockable=0
	Grabbable=0
	Dead_Zone_Immune=1
	layer=4
	density=1
	Spawn_Timer=180000
	appearance_flags = 0

	Tree_20191
		icon = 'celianna_farmnature_tilesetPartLarge.dmi'
		icon_state = "Tree1"
		pixel_y = 0
		New()
			CenterIcon(src, x_only = 1)

	Tree_20192
		icon = 'celianna_farmnature_tilesetPartLarge.dmi'
		icon_state = "Tree2"
		pixel_y = 0
		New()
			CenterIcon(src, x_only = 1)

	Tree_20193
		icon = 'celianna_farmnature_tilesetPartLarge.dmi'
		icon_state = "Pine_Tree"
		pixel_y = 0
		New()
			CenterIcon(src, x_only = 1)

	Tree_20194
		icon = 'celianna_TileB1Large.dmi'
		icon_state = "Largetree2"
		pixel_y = -10
		New()
			CenterIcon(src, x_only = 1)

	Snowy_Pine_Tree
		icon='snowy pine tree.png'
		New()
			CenterIcon(src,x_only=1)

	Dead_Tree_Snow
		icon='dead tree snow.png'
		New()
			CenterIcon(src,x_only=1)

	Big_Generic_Nice_Tree
		icon='big generic nice tree.png'
		pixel_y = -15
		New()
			CenterIcon(src,x_only=1)

	Bigger_Generic_Nice_Tree
		icon='bigger generic nice tree.png'
		pixel_y = -8
		New()
			CenterIcon(src,x_only=1)

	Dead_Tree_2
		icon='dead tree 2016.png'
		New()
			CenterIcon(src,x_only=1)

	Dead_Tree_3
		icon='dead tree 2016 2.png'
		New()
			CenterIcon(src,x_only=1)

	Pink_Tree
		icon='low res pink tree.png'
		New()
			CenterIcon(src,x_only=1)

	Palm_Tree_2
		icon='palm tree 2016.png'
		New()
			CenterIcon(src,x_only=1)

	Palm_Tree_3
		icon='palm tree 2016 2.png'
		New()
			CenterIcon(src,x_only=1)

	Large_Pine
		icon='tree large pine.png'
		New()
			CenterIcon(src,x_only=1)

	Medium_Pine
		icon='tree medium pine.png'
		New()
			CenterIcon(src,x_only=1)

	Small_Pine
		icon='tree small pine.png'
		New()
			CenterIcon(src,x_only=1)

	Jungle_tree_1
		icon='jungle tree.png'
		pixel_x=-32
		bound_width=64

	Jungle_tree_2
		icon='jungle tree 2.png'
		New()
			CenterIcon(O=src,x_only=1)

	Jungle_tree_3
		icon='jungle tree 3.png'
		pixel_x=-29
		bound_width=64

	Jungle_tree_4
		icon='jungle tree 4.dmi'
		pixel_x=-78
		bound_width=64

	Dead_Tree_1
		New()
			var/image/A=image(icon='turfs66.dmi',icon_state="2",pixel_x=0,pixel_y=0,layer=layer)
			var/image/B=image(icon='turfs66.dmi',icon_state="3",pixel_x=-32,pixel_y=32,layer=MOB_LAYER+1)
			var/image/C=image(icon='turfs66.dmi',icon_state="42",pixel_x=0,pixel_y=32,layer=MOB_LAYER+1)
			var/image/D=image(icon='turfs66.dmi',icon_state="31",pixel_x=32,pixel_y=32,layer=MOB_LAYER+1)
			overlays=null
			overlays.Add(A,B,C,D)
	/*Dead_Tree_2
		New()
			var/image/A=image(icon='turfs66.dmi',icon_state="d1",pixel_x=0,pixel_y=0,layer=layer)
			var/image/B=image(icon='turfs66.dmi',icon_state="d2",pixel_x=-32,pixel_y=32,layer=MOB_LAYER+1)
			var/image/C=image(icon='turfs66.dmi',icon_state="d3",pixel_x=0,pixel_y=32,layer=MOB_LAYER+1)
			var/image/D=image(icon='turfs66.dmi',icon_state="d4",pixel_x=32,pixel_y=32,layer=MOB_LAYER+1)
			overlays=null
			overlays.Add(A,B,C,D)*/
	Dark_Tree
		New()
			var/image/A=image(icon='turfs66.dmi',icon_state="treebotleft",pixel_x=-16,pixel_y=0,layer=layer)
			var/image/B=image(icon='turfs66.dmi',icon_state="treebotright",pixel_x=16,pixel_y=0,layer=layer)
			var/image/C=image(icon='turfs66.dmi',icon_state="treetopleft",pixel_x=-16,pixel_y=32,layer=MOB_LAYER+1)
			var/image/D=image(icon='turfs66.dmi',icon_state="treetopright",pixel_x=16,pixel_y=32,layer=MOB_LAYER+1)
			overlays=null
			overlays.Add(A,B,C,D)
	Strange_Pine
		New()
			var/image/A=image(icon='turfs66.dmi',icon_state="treeleftbot1",pixel_x=-16,pixel_y=0,layer=layer)
			var/image/B=image(icon='turfs66.dmi',icon_state="treerightbot1",pixel_x=16,pixel_y=0,layer=layer)
			var/image/C=image(icon='turfs66.dmi',icon_state="treelefttop1",pixel_x=-16,pixel_y=32,layer=MOB_LAYER+1)
			var/image/D=image(icon='turfs66.dmi',icon_state="treerighttop1",pixel_x=16,pixel_y=32,layer=MOB_LAYER+1)
			overlays=null
			overlays.Add(A,B,C,D)
	Nice_Tree
		overlays=newlist(/image{icon='turfs66.dmi' icon_state="treeleftbot2" pixel_x=-16 pixel_y=0},\
		/image{icon='turfs66.dmi' icon_state="treerightbot2" pixel_x=16 pixel_y=0},\
		/image{icon='turfs66.dmi' icon_state="treelefttop2" pixel_x=-16 pixel_y=32 layer=MOB_LAYER+1},\
		/image{icon='turfs66.dmi' icon_state="treerighttop2" pixel_x=16 pixel_y=32 layer=MOB_LAYER+1})
	SmallPine
		icon='Turf 58.dmi'
		icon_state="2"
		density=1
		New()
			var/image/A=image(icon='Turf 58.dmi',icon_state="1",pixel_y=0,pixel_x=-32,layer=4)
			var/image/B=image(icon='Turf 58.dmi',icon_state="0",pixel_y=-32,pixel_x=0,layer=4)
			var/image/C=image(icon='Turf 58.dmi',icon_state="3",pixel_y=32,pixel_x=-32,layer=4)
			var/image/D=image(icon='Turf 58.dmi',icon_state="4",pixel_y=32,pixel_x=0,layer=4)
			overlays=null
			overlays.Add(A,B,C,D)
			new/obj/Trees/LargePine(loc)
			del(src)
			//. = ..()
	RedTree
		density=1
		New()
			var/image/A=image(icon='Turf 55.dmi',icon_state="1",pixel_y=32,pixel_x=-32,layer=4)
			var/image/B=image(icon='Turf 55.dmi',icon_state="2",pixel_y=0,pixel_x=0,layer=4)
			var/image/C=image(icon='Turf 55.dmi',icon_state="3",pixel_y=32,pixel_x=32,layer=4)
			var/image/D=image(icon='Turf 55.dmi',icon_state="4",pixel_y=0,pixel_x=-32,layer=4)
			var/image/E=image(icon='Turf 55.dmi',icon_state="5",pixel_y=32,pixel_x=0,layer=4)
			var/image/F=image(icon='Turf 55.dmi',icon_state="6",pixel_y=0,pixel_x=32,layer=4)
			overlays=null
			overlays.Add(A,B,C,D,E,F)
			//. = ..()
	Tall_Tree
		density=1
		icon='treee.dmi'
		icon_state="bottom"
		New()
			var/image/A=image(icon='treee.dmi',icon_state="top",layer=MOB_LAYER+1,pixel_y=32)
			overlays+=A
	BigHousePlant
		density=1
		icon='Turf 52.dmi'
		icon_state="plant bottom"
		New()
			var/image/A=image(icon='Turf 52.dmi',icon_state="plant top",pixel_y=32,pixel_x=0,layer=4)
			overlays=null
			overlays.Add(A)
			//. = ..()
	Oak
		density=1
		New()
			var/image/A=image(icon='turfs.dmi',icon_state="1",pixel_y=0,pixel_x=-16,layer=4)
			var/image/B=image(icon='turfs.dmi',icon_state="2",pixel_y=0,pixel_x=16,layer=4)
			var/image/C=image(icon='turfs.dmi',icon_state="3",pixel_y=32,pixel_x=-16,layer=4)
			var/image/D=image(icon='turfs.dmi',icon_state="4",pixel_y=32,pixel_x=16,layer=4)
			var/image/E=image(icon='turfs.dmi',icon_state="5",pixel_y=64,pixel_x=-16,layer=4)
			var/image/F=image(icon='turfs.dmi',icon_state="6",pixel_y=64,pixel_x=16,layer=4)
			overlays=null
			overlays.Add(A,B,C,D,E,F)
			//. = ..()
	RoundTree
		density=1
		New()
			var/image/A=image(icon='turfs.dmi',icon_state="01",pixel_y=0,pixel_x=-16,layer=4)
			var/image/B=image(icon='turfs.dmi',icon_state="02",pixel_y=0,pixel_x=16,layer=4)
			var/image/C=image(icon='turfs.dmi',icon_state="03",pixel_y=32,pixel_x=-16,layer=4)
			var/image/D=image(icon='turfs.dmi',icon_state="04",pixel_y=32,pixel_x=16,layer=4)
			overlays=null
			overlays.Add(A,B,C,D)
			//. = ..()
	Tree
		density=1
		icon='turfs.dmi'
		icon_state="bottom"
		New()
			var/image/B=image(icon='turfs.dmi',icon_state="middle",pixel_y=32,pixel_x=0,layer=4)
			var/image/C=image(icon='turfs.dmi',icon_state="top",pixel_y=64,pixel_x=0,layer=4)
			overlays=null
			overlays.Add(B,C)
			//. = ..()
	Palm
		density=1
		New()
			var/image/A=image(icon='Trees2.dmi',icon_state="1",pixel_y=0,pixel_x=-16,layer=4)
			var/image/B=image(icon='Trees2.dmi',icon_state="2",pixel_y=0,pixel_x=16,layer=4)
			var/image/C=image(icon='Trees2.dmi',icon_state="3",pixel_y=32,pixel_x=-16,layer=4)
			var/image/D=image(icon='Trees2.dmi',icon_state="4",pixel_y=32,pixel_x=16,layer=4)
			var/image/E=image(icon='Trees2.dmi',icon_state="5",pixel_y=64,pixel_x=-16,layer=4)
			var/image/F=image(icon='Trees2.dmi',icon_state="6",pixel_y=64,pixel_x=16,layer=4)
			var/image/G=image(icon='Trees2.dmi',icon_state="7",pixel_y=96,pixel_x=-16,layer=4)
			var/image/H=image(icon='Trees2.dmi',icon_state="8",pixel_y=96,pixel_x=16,layer=4)
			overlays=null
			overlays.Add(A,B,C,D,E,F,G,H)
			//. = ..()

	LargePine
		density=1
		icon = 'Tree Oak 2017.dmi'
		New()
			CenterIcon(src,x_only=1)

	LargePineSnow
		density=1
		New()
			var/image/A=image(icon='Tree GoodSnow.dmi',icon_state="1",pixel_y=0,pixel_x=-16,layer=4)
			var/image/B=image(icon='Tree GoodSnow.dmi',icon_state="2",pixel_y=0,pixel_x=16,layer=4)
			var/image/C=image(icon='Tree GoodSnow.dmi',icon_state="3",pixel_y=32,pixel_x=-16,layer=4)
			var/image/D=image(icon='Tree GoodSnow.dmi',icon_state="4",pixel_y=32,pixel_x=16,layer=4)
			var/image/E=image(icon='Tree GoodSnow.dmi',icon_state="5",pixel_y=64,pixel_x=-16,layer=4)
			var/image/F=image(icon='Tree GoodSnow.dmi',icon_state="6",pixel_y=64,pixel_x=16,layer=4)
			overlays=null
			overlays.Add(A,B,C,D,E,F)
			//. = ..()
	RedPine
		density=1
		New()
			var/image/A=image(icon='Tree Red.dmi',icon_state="1",pixel_y=0,pixel_x=-16,layer=4)
			var/image/B=image(icon='Tree Red.dmi',icon_state="2",pixel_y=0,pixel_x=16,layer=4)
			var/image/C=image(icon='Tree Red.dmi',icon_state="3",pixel_y=32,pixel_x=-16,layer=4)
			var/image/D=image(icon='Tree Red.dmi',icon_state="4",pixel_y=32,pixel_x=16,layer=4)
			var/image/E=image(icon='Tree Red.dmi',icon_state="5",pixel_y=64,pixel_x=-16,layer=4)
			var/image/F=image(icon='Tree Red.dmi',icon_state="6",pixel_y=64,pixel_x=16,layer=4)
			overlays=null
			overlays.Add(A,B,C,D,E,F)
			//. = ..()
	TallBush
		density=1
		icon='Turf3.dmi'
		icon_state="tallplantbottom"
		density=1
		New()
			var/image/A=image(icon='Turf3.dmi',icon_state="tallplanttop",pixel_y=32,layer=4)
			overlays=null
			overlays.Add(A)
			//. = ..()
	/*SluggoTree
		density=1
		New()
			overlays=null
			switch(pick(1,2,3,4))
				if(1)
					var/image/A=image(icon='turfs.dmi',icon_state="nt2",pixel_y=32,layer=4)
					var/image/B=image(icon='turfs.dmi',icon_state="nt1")
					overlays.Add(A,B)
				if(2)
					var/image/A=image(icon='Trees Puranto.dmi',icon_state="1 Bottom")
					var/image/B=image(icon='Trees Puranto.dmi',icon_state="1 Middle",pixel_y=32)
					var/image/C=image(icon='Trees Puranto.dmi',icon_state="1 Top",pixel_y=64)
					overlays.Add(A,B,C)
				if(3)
					var/image/A=image(icon='Trees Puranto.dmi',icon_state="2.0")
					var/image/B=image(icon='Trees Puranto.dmi',icon_state="2.1",pixel_y=32)
					var/image/C=image(icon='Trees Puranto.dmi',icon_state="2.2",pixel_y=64)
					var/image/D=image(icon='Trees Puranto.dmi',icon_state="2.3",pixel_y=64,pixel_x=32)
					overlays.Add(A,B,C,D)
				if(4)
					var/image/A=image(icon='Trees Puranto.dmi',icon_state="1")
					var/image/B=image(icon='Trees Puranto.dmi',icon_state="2",pixel_y=32)
					var/image/C=image(icon='Trees Puranto.dmi',icon_state="3",pixel_y=64)
					var/image/D=image(icon='Trees Puranto.dmi',icon_state="4",pixel_y=32,pixel_x=32)
					var/image/E=image(icon='Trees Puranto.dmi',icon_state="5",pixel_y=64,pixel_x=32)
					overlays.Add(A,B,C,D,E)
			//. = ..()
			*/


	Puranto_Tree
		density=1
		icon = 'NamekTrees.dmi'
		icon_state = "A 1"

		New()
			switch(rand(1,4))
				if(1)
					icon = 'NamekTrees.dmi'
					icon_state = "A 1"
					pixel_x = -16
					pixel_y = -5
				if(2)
					icon = 'NamekTrees.dmi'
					icon_state = "A 2"
					pixel_x = -16
					pixel_y = -5
				if(3)
					icon = 'NamekTrees2.dmi'
					icon_state = "A 1"
					pixel_x = -32
					pixel_y = -0
				if(4)
					icon = 'NamekTrees2.dmi'
					icon_state = "A 2"
					pixel_x = -32
					pixel_y = -0

obj/var/mapObject

obj/Edges
	mapObject = 1
	Givable=0
	Makeable=0
	Knockable=0
	attackable=0
	Dead_Zone_Immune=1
	var/Pod_Access=1
	New()
		for(var/obj/Edges/E in loc) if(E!=src&&E.type==type)
			del(src)
			return
	//attackable=0
	Savable=0
	Buildable=1
	Grabbable=0
	Nukable=0
	RockEdgeN
		icon='Edges1.dmi'
		icon_state="N"
		dir=NORTH
	RockEdgeW
		icon='Edges1.dmi'
		icon_state="W"
		dir=WEST
	RockEdgeE
		icon='Edges1.dmi'
		icon_state="E"
		dir=EAST
	RockEdge2N
		icon='Edges2.dmi'
		icon_state="N"
		dir=NORTH
	RockEdge2W
		icon='Edges2.dmi'
		icon_state="W"
		dir=WEST
	RockEdge2E
		icon='Edges2.dmi'
		icon_state="E"
		dir=EAST
	Edge3N
		icon='Edges3.dmi'
		icon_state="N"
		dir=NORTH
	Edge3W
		icon='Edges3.dmi'
		icon_state="W"
		dir=WEST
	Edge3E
		icon='Edges3.dmi'
		icon_state="E"
		dir=EAST
	Edge4N
		icon='Edges4.dmi'
		icon_state="N"
		dir=NORTH
	Edge4W
		icon='Edges4.dmi'
		icon_state="W"
		dir=WEST
	Edge4E
		icon='Edges4.dmi'
		icon_state="E"
		dir=EAST
	Edge5N
		icon='Edges5.dmi'
		icon_state="N"
		dir=NORTH
	Edge5W
		icon='Edges5.dmi'
		icon_state="W"
		dir=WEST
	Edge5E
		icon='Edges5.dmi'
		icon_state="E"
		dir=EAST
	Edge6N
		icon='Edges6.dmi'
		icon_state="N"
		dir=NORTH
	Edge6W
		icon='Edges6.dmi'
		icon_state="W"
		dir=WEST
	Edge6E
		icon='Edges6.dmi'
		icon_state="E"
		dir=EAST
	Edge7N
		icon='Misc.dmi'
		icon_state="S"
		dir=NORTH
	Edge7W
		icon='Misc.dmi'
		icon_state="E"
		dir=WEST
	Edge7E
		icon='Misc.dmi'
		icon_state="W"
		dir=EAST
	PodEdgeN
		icon='Edges7.dmi'
		icon_state="N"
		dir=NORTH
		Pod_Access=0
	PodEdgeW
		icon='Edges7.dmi'
		icon_state="W"
		dir=WEST
		Pod_Access=0
	PodEdgeE
		icon='Edges7.dmi'
		icon_state="E"
		dir=EAST
		Pod_Access=0

turf/var/Water


//okay what this does is if we take a large image texture from like google images of a ground texture and its like 128x128, then we make dmi
//file and right click it and hit import as 32x32 then byond will automatically split it up into 32x32 chunks using a 0,0 to whatever
//coordinate system, so what this will do is take those 32x32 chunks and make sure they seam together the same as they were in the large
//icon with no extra effort from us, based on the x/y position
turf/proc/DecideTurfStateForSpecialIcons(width = 4, height = 4)
	var
		X = x % width //if 4, 1 = 1, 2 = 2, 3 = 3, 4 = 0, 5 = 1, 6 = 2, etc
		Y = y % height
	//becase 4 % 4 = 0 but we need it to be 4
	if(X == 0) X = width
	if(Y == 0) Y = height
	//because the icon's states are 0-3 not 1-4
	X -= 1
	Y -= 1
	icon_state = "[X],[Y]"

turf/Other
	New()
		if(type==/turf/Other) Buildable=0
		. = ..()
	Lava
		nukable=0
		//icon='turfs.dmi'
		//icon_state="lava"
		icon = 'Lava 2017.dmi'
		icon_state = "0,0"
		Water=1
		wave_icon = null
		Enter(mob/P) if(Water_Enter(P)) return . = ..()
		Exit(mob/P) if(Water_Exit(P)) return . = ..()
		New()
			DecideTurfStateForSpecialIcons(4,4)
			. = ..()

	Blank
		nukable=0
		opacity=1
		Buildable=0
		Health=1.#INF
		density=1
		auto_gen_eligible = 0

		Enter(mob/M)
			if(ismob(M))
				if(M.client)
					if(can_go_in_void) return 1
					if(admins_can_go_in_void && M.IsAdmin()) return 1
					if(!can_go_in_void)
						var/turf/t = M.loc
						if(t && t.type == /turf/Other/Blank)
							M.Respawn()

	MountainCave
		density=1
		icon='Turf1.dmi'
		icon_state="mtn cave"
		Buildable=0

	Stars
		icon = 'Space Background.dmi'
		//icon = 'Space Background 2.dmi'
		name = "Space"
		Buildable=0
		Health=1.#INF
		New()
			DecideTurfStateForSpecialIcons(16,16)
			//DecideTurfStateForSpecialIcons(32,32) //for the other larger space icon if we switch back to it
			. = ..()

	Orb
		icon='Turf1.dmi'
		icon_state="spirit"
		density=0
		Buildable=0
		auto_gen_eligible = 0

	Ladder
		icon='Turf1.dmi'
		icon_state="ladder"
		density=0
		Buildable=0
		auto_edge = 0
		auto_cliff = 0
		auto_gen_eligible = 0
		New()
			. = ..()

	Sky1
		nukable=0
		//icon='Misc.dmi'
		//icon_state="Sky"
		//icon = 'Blue Sky Background.dmi'
		//icon = 'blue sky background 2.dmi'
		//icon = 'newton clouds 256x192.dmi'
		icon = 'newton blue clouds 320x192.dmi'
		Buildable=0
		/*Enter(mob/M)
			if(ismob(M)) if(M.Flying||!M.density) return . = ..()
			else return . = ..()*/
		New()
			//DecideTurfStateForSpecialIcons(16,16)
			//DecideTurfStateForSpecialIcons(8,8)
			//DecideTurfStateForSpecialIcons(8,6)
			DecideTurfStateForSpecialIcons(10,6)
			. = ..()
	Sky2
		Water=1
		wave_icon = null
		nukable=0
		//icon='Misc.dmi'
		//icon_state="Clouds"
		//icon = 'Orange Sky Background.dmi'
		//icon = 'newton clouds.dmi'
		//icon = 'newtonclouds 320x192.dmi'
		icon = 'newton clouds.dmi'
		Buildable=0
		Enter(mob/M)
			if(!Builder && ismob(M) && prob(20) && !M.Flying && !M.drone_module) M.z = 6
			return . = ..()
		New()
			//DecideTurfStateForSpecialIcons(19,19)
			//DecideTurfStateForSpecialIcons(16,16)
			//DecideTurfStateForSpecialIcons(10,6)
			DecideTurfStateForSpecialIcons(10,7)
			. = ..()

proc/get_space_state()
	if(prob(90)) return "blackness"
	else return pick("star1","star2","star3")
var/turf/prison_exit

turf/Teleporter
	Buildable=0
	nukable=0
	auto_gen_eligible = 0

	Prison_Exit
		Health=1.#INF
		var/gotox=250
		var/gotoy=267
		var/gotoz=16

		New()
			if(locate(1,1,1) != src) prison_exit = src
			. = ..()

		Enter(mob/M)
			//stops a problem where if you enter a teleporter that is set to teleport you on top of another teleporter then Enter() will be called on
			//that teleporter too which then teleports you right back out where you started, or worse causes an infinite loop if the position it
			//teleports you back out to is another teleporter
			if(M.canTeleport == world.time)
				return . = ..()
			if(ismob(M))
				//if(world.time - M.last_cave_entered_time < 40 && M.last_cave_entered==src) return
				if(!M.Prisoner())
					M.last_cave_entered=src
					M.last_cave_entered_time=world.time
					M.SafeTeleport(locate(gotox,gotoy,gotoz))
				else
					M<<"The prison will not allow you to leave until your sentence is up. You have \
					[M.Prison_Time_Remaining()] hours remaining. There is plenty that can be accomplished \
					within the prison."
					return . = ..()
			else M.SafeTeleport(locate(gotox,gotoy,gotoz))

	Teleporter
		density=1
		var/gotox
		var/gotoy
		var/gotoz
		Health=1.#INF

		Enter(mob/M)
			//stops a problem where if you enter a teleporter that is set to teleport you on top of another teleporter then Enter() will be called on
			//that teleporter too which then teleports you right back out where you started, or worse causes an infinite loop if the position it
			//teleports you back out to is another teleporter
			if(M.canTeleport == world.time)
				return . = ..()
			//if(ismob(M) && M.InBattleCantEnterCave()) return
			//if(ismob(M) && world.time - M.last_cave_entered_time < 20 && M.last_cave_entered == src) return
			M.SafeTeleport(locate(gotox,gotoy,gotoz))
			if(ismob(M))
				M.last_cave_entered=src
				M.last_cave_entered_time=world.time

		New()
			new/obj/Cave(src)
			. = ..()

	EnterHBTC
		var/gotox=258
		var/gotoy=274
		var/gotoz=10
		Enter(mob/A)
			//stops a problem where if you enter a teleporter that is set to teleport you on top of another teleporter then Enter() will be called on
			//that teleporter too which then teleports you right back out where you started, or worse causes an infinite loop if the position it
			//teleports you back out to is another teleporter
			if(A.canTeleport == world.time)
				return . = ..()

			//if(ismob(A) && A.InBattleCantEnterCave()) return

			//if(ismob(A) && world.time-A.last_cave_entered_time<40 && A.last_cave_entered==src) return
			Health=1.#INF
			A.SafeTeleport(locate(gotox,gotoy,gotoz))
			if(ismob(A))
				A.last_cave_entered=src
				A.last_cave_entered_time=world.time
				A.GiveFeat("Use Time Chamber")
			//if(ismob(A)) HBTC_Time=600

	ExitHBTC
		Health=1.#INF
		var/gotox=128
		var/gotoy=1
		var/gotoz=2
		Enter(mob/A)
			//stops a problem where if you enter a teleporter that is set to teleport you on top of another teleporter then Enter() will be called on
			//that teleporter too which then teleports you right back out where you started, or worse causes an infinite loop if the position it
			//teleports you back out to is another teleporter
			if(A.canTeleport == world.time)
				return . = ..()

			//if(ismob(A) && A.InBattleCantEnterCave()) return

			//if(ismob(A) && world.time-A.last_cave_entered_time<40 && A.last_cave_entered==src) return
			if(HBTC_Time>0)
				if(ismob(A))
					A.last_cave_entered=src
					A.last_cave_entered_time=world.time
				A.SafeTeleport(locate(gotox,gotoy,gotoz))

turf
	Bridge1V
		icon='Turf 50.dmi'
		icon_state="1.8"
		edge_icon = 'EdgesBridge.dmi'
		auto_cliff = 0
		auto_wave = 0
		do_south_edge = 1
		build_category = BUILD_FLOOR
	Bridge1H
		icon='Turf 50.dmi'
		icon_state="3.3"
		edge_icon = 'EdgesBridge.dmi'
		auto_cliff = 0
		auto_wave = 0
		do_south_edge = 1
		build_category = BUILD_FLOOR
	Bridge2V
		icon='Turf 57.dmi'
		icon_state="26"
		edge_icon = 'EdgesBridge.dmi'
		auto_cliff = 0
		auto_wave = 0
		do_south_edge = 1
		build_category = BUILD_FLOOR
	Bridge2H
		icon='Turf 57.dmi'
		icon_state="123"
		edge_icon = 'EdgesBridge.dmi'
		auto_cliff = 0
		auto_wave = 0
		do_south_edge = 1
		build_category = BUILD_FLOOR

	GroundDirt
		//icon='Turfs 14.dmi'
		//icon_state="Dirt"
		icon = 'Big Dirt Turfs.dmi'
		build_category = BUILD_GROUND
		//Health=1.#INF
		New()
			DecideTurfStateForSpecialIcons(4,4)
			. = ..()

	GroundIce
		//icon='Turf 57.dmi'
		//icon_state="8"
		icon = 'Big Ice Turf 3.dmi'
		cliff_type = /turf/Wall19
		edge_icon = 'Edges5.dmi'
		build_category = BUILD_GROUND
		New()
			DecideTurfStateForSpecialIcons(6,6)
			. = ..()

	GroundIce2
		//icon='Turf 55.dmi'
		//icon_state="ice"
		icon = 'Big Ice Turf 2.dmi'
		cliff_type = /turf/Wall19
		edge_icon = 'Edges5.dmi'
		build_category = BUILD_GROUND
		New()
			DecideTurfStateForSpecialIcons(6,6)
			. = ..()

	GroundDirtSand
		icon='Turfs 96.dmi'
		icon_state="dirt"
		build_category = BUILD_GROUND

	GroundSnow
		//icon='Turf Snow.dmi'
		icon = 'Big Snow Turf.dmi'
		cliff_type = /turf/Wall19
		edge_icon = 'Edges5.dmi'
		build_category = BUILD_GROUND
		New()
			DecideTurfStateForSpecialIcons(6,6)
			. = ..()

	SnowAndRocks
		icon = 'Big Snow and Rock Turf.dmi'
		cliff_type = /turf/Wall19
		edge_icon = 'Edges5.dmi'
		build_category = BUILD_GROUND
		New()
			DecideTurfStateForSpecialIcons(6,6)
			. = ..()

	Ground4
		icon='Turfs 12.dmi'
		icon_state="desert"
		build_category = BUILD_GROUND
	Ground10
		icon='Turf1.dmi'
		icon_state="light desert"
		build_category = BUILD_GROUND
		New()
			. = ..()
			RandomDirtOverlay()
	Ground17
		//icon='Turfs1.dmi'
		//icon_state="dirt2"
		icon = 'Hell Ground 2017.dmi'
		icon_state = "0,0"
		edge_icon = 'Edges3.dmi'
		cliff_type = /turf/Wall17
		auto_wave = 0
		build_category = BUILD_GROUND
		New()
			. = ..()
			DecideTurfStateForSpecialIcons(6,6)

	Ground18
		//icon='turfs.dmi'
		//icon_state="hellfloor"
		icon = 'Big Dirt Turf 2.dmi'
		build_category = BUILD_GROUND
		New()
			DecideTurfStateForSpecialIcons(4,4)
			. = ..()

	Ground19
		icon='Turfs 96.dmi'
		icon_state="darktile"
		build_category = BUILD_GROUND

	GroundIce3
		//icon='Turfs 12.dmi'
		//icon_state="ice"
		icon = 'Big Ice Turf.dmi'
		cliff_type = /turf/Wall19
		edge_icon = 'Edges5.dmi'
		build_category = BUILD_GROUND
		New()
			DecideTurfStateForSpecialIcons(4,4)
			. = ..()

	GroundHell
		icon='Turf 57.dmi'
		icon_state="hellturf1"
		build_category = BUILD_GROUND
	Ground16
		icon='FloorsLAWL.dmi'
		icon_state="Flagstone"
		build_category = BUILD_GROUND
	Ground12
		icon='Turfs 1.dmi'
		icon_state="dirt"
		build_category = BUILD_GROUND
		New()
			. = ..()
			RandomDirtOverlay()
	Ground13
		icon='Turfs 1.dmi'
		icon_state="rock"
		density=1
		build_category = BUILD_GROUND
	Ground_Wasteland
		icon='wasteland ground.dmi'
		build_category = BUILD_GROUND
	GroundPebbles
		icon='Turfs 7.dmi'
		icon_state="Sand"
		edge_icon = 'Edges4.dmi'
		cliff_type = /turf/Wall18
		build_category = BUILD_GROUND
	Ground11
		icon='Turfs 1.dmi'
		icon_state="crack"
		density=1
		build_category = BUILD_GROUND

	GroundSandDark
		icon='Turf1.dmi'
		icon_state="dark desert"
		density=0
		build_category = BUILD_GROUND

		//because this is used when players blow up another turf, we dont want this
		auto_edge = 0
		auto_cliff = 0
		auto_wave = 1

		New()
			. = ..()
			RandomDirtOverlay()

	Ground3
		//icon='Turf1.dmi'
		//icon_state="very dark desert"
		icon='vegeta turf 2016.dmi'
		icon_state="1"
		build_category = BUILD_GROUND
		density=0
		cliff_type = /turf/Wall18
		edge_icon = 'Edges4.dmi'

	Grass9
		icon='Turfs 96.dmi'
		icon_state="grass d"
		build_category = BUILD_GROUND
		New()
			RandomGrassOverlay()
			RandomDirtOverlay()
			. = ..()

	Grass13
		icon = 'Big Grass Turf 2.dmi'
		build_category = BUILD_GROUND
		New()
			DecideTurfStateForSpecialIcons(3,3)
			RandomGrassOverlay(2)
			RandomDirtOverlay(2)
			. = ..()

	Grass7
		icon='Turfs 1.dmi'
		icon_state="grass"
		build_category = BUILD_GROUND
		New()
			RandomGrassOverlay()
			RandomDirtOverlay()
			. = ..()

	Grass5
		//icon='Turfs 14.dmi'
		//icon_state="Grass"
		icon = 'Big Grass.dmi'
		build_category = BUILD_GROUND
		New()
			DecideTurfStateForSpecialIcons(4,4)
			RandomGrassOverlay()
			RandomDirtOverlay()
			. = ..()

	Grass11
		icon='Turfs 1.dmi'
		icon_state="Grass 50"
		build_category = BUILD_GROUND
		New()
			RandomGrassOverlay()
			RandomDirtOverlay()
			. = ..()

	Grass12
		//icon='Turfs1.dmi'
		//icon_state="grassremade"
		icon='jungle grass tile.dmi'
		edge_icon = 'Edges4.dmi'
		cliff_type = /turf/Wall18
		build_category = BUILD_GROUND
		New()
			. = ..()
			RandomDirtOverlay()
	Grass1
		icon='Turfs 12.dmi'
		icon_state="grass2"
		build_category = BUILD_GROUND
		New()
			RandomGrassOverlay()
			RandomDirtOverlay()
			. = ..()

	Grass8
		icon = 'Big Grass and Dirt Turf.dmi'
		build_category = BUILD_GROUND
		New()
			DecideTurfStateForSpecialIcons(6,6)
			RandomGrassOverlay()
			RandomDirtOverlay()
			. = ..()

	GrassSluggo
		//icon='turfs.dmi'
		//icon_state="ngrass"
		//icon='Puranto Grass 2016.dmi'
		icon='NamekTiles.dmi'
		icon_state="A 1"
		cliff_type = /turf/Wall16
		edge_icon = 'Edges2.dmi'
		build_category = BUILD_GROUND

		New()
			if(prob(50))
				icon_state = pick("A 2","A 3")
			if(prob(3))
				icon_state = pick("B 1","B 2")
			if(prob(1))
				icon_state = pick("A 4","A 5","A 6")
			if(prob(1))
				icon_state = pick("F 1","F 2","F 3","F 4","F 5","F 6","F 7","F 8","F 9")
			. = ..()

	Grass2
		icon='Turfs 5.dmi'
		icon_state="grass"
		build_category = BUILD_GROUND
		New()
			RandomGrassOverlay()
			RandomDirtOverlay()
			. = ..()

	Grass3
		icon='Turfs 96.dmi'
		icon_state="grass b"
		build_category = BUILD_GROUND
		New()
			RandomGrassOverlay()
			RandomDirtOverlay()
			. = ..()

	Grass4
		icon='Turfs 96.dmi'
		icon_state="grass c"
		build_category = BUILD_GROUND
		New()
			RandomGrassOverlay()
			RandomDirtOverlay()
			. = ..()

	Ground14
		//icon='Turfs 2.dmi'
		//icon_state="desert"
		icon = 'Big Sand Turf.dmi'
		edge_icon = 'Edges4.dmi'
		cliff_type = /turf/Wall18
		build_category = BUILD_GROUND
		New()
			DecideTurfStateForSpecialIcons(4,4)
			. = ..()

	Grass14
		icon='Turfs 96.dmi'
		icon_state="grass a"
		build_category = BUILD_GROUND
		New()
			RandomGrassOverlay()
			RandomDirtOverlay()
			. = ..()

	Grass10
		icon='Turfs 1.dmi'
		icon_state="Grass!"
		build_category = BUILD_GROUND

		New()
			RandomGrassOverlay()
			RandomDirtOverlay()
			. = ..()

	/*Green_Clouds
		icon = 'ToP background.dmi'
		build_category = BUILD_GROUND
		New()
			DecideTurfStateForSpecialIcons(8,8)
			..()*/

	Wall21
		icon='Turfs Temple.dmi'
		icon_state="wall2"
		density=1
		build_category = BUILD_WALL
	Wall12
		icon='Turfs 3.dmi'
		icon_state="cliff"
		density=1
		build_category = BUILD_WALL
	Wall10
		icon='Turfs 4.dmi'
		icon_state="ice cliff"
		density=1
		build_category = BUILD_WALL
	Wall8
		icon='Turfs 15.dmi'
		icon_state="wall2"
		density=1
		build_category = BUILD_WALL
	Wall3
		icon='Turfs 4.dmi'
		icon_state="wall"
		density=1
		build_category = BUILD_WALL
	Wall17
		icon='Turf 57.dmi'
		icon_state="1"
		density=1
		build_category = BUILD_WALL
	Wall7
		icon='Turfs 1.dmi'
		icon_state="cliff"
		density=1
		build_category = BUILD_WALL
	Wall2
		icon='Turfs 1.dmi'
		icon_state="wall6"
		opacity=0
		density=1
		build_category = BUILD_WALL
	WallSand
		icon='Turf 50.dmi'
		icon_state="3.2"
		density=1
		build_category = BUILD_WALL
	WallStone
		icon='Turf 57.dmi'
		icon_state="stonewall2"
		density=1
		build_category = BUILD_WALL
	WallStone2
		icon='Turf 57.dmi'
		icon_state="stonewall4"
		density=1
		build_category = BUILD_WALL
	WallStone3
		icon='Turfs 96.dmi'
		icon_state="wall3"
		build_category = BUILD_WALL
		density=1
	WallTech
		icon='Space.dmi'
		icon_state="bottom"
		density=1
		build_category = BUILD_WALL
	Wall18
		icon='Turf 57.dmi'
		icon_state="2"
		density=1
		build_category = BUILD_WALL
	Wall19
		icon='Turf 57.dmi'
		icon_state="3"
		density=1
		build_category = BUILD_WALL
	Wall20
		icon='Turf 57.dmi'
		icon_state="6"
		density=1
		build_category = BUILD_WALL
	Wall21
		icon='metaltiles1.dmi'
		icon_state="metalwalla"
		density=1
		build_category = BUILD_WALL
	Wall_tan_plain
		icon='tan block.dmi'
		density=1
		build_category = BUILD_WALL
	Wall22
		icon='metaltiles1.dmi'
		icon_state="metalwallb"
		density=1
		build_category = BUILD_WALL
	Wall23
		icon='Tiles 1.21.2011.dmi'
		icon_state="36"
		density=1
		build_category = BUILD_WALL
	Wall23
		icon='Tiles 1.21.2011.dmi'
		icon_state="33"
		density=1
		build_category = BUILD_WALL
	Wall13
		icon='turfs.dmi'
		icon_state="wall8"
		density=1
		build_category = BUILD_WALL
	Wall16
		icon='Turf 50.dmi'
		icon_state="2.6"
		density=1
		build_category = BUILD_WALL
	Wall11
		icon='Turfs 18.dmi'
		icon_state="stone"
		density=1
		build_category = BUILD_WALL
	Wall5
		icon='turfs.dmi'
		icon_state="tile1"
		density=1
		build_category = BUILD_WALL
	Wall6
		icon='Turfs 2.dmi'
		icon_state="brick2"
		density=1
		build_category = BUILD_WALL
	Wall15
		icon='Turf1.dmi'
		icon_state="1"
		density=1
		build_category = BUILD_WALL
	Wall1
		icon='turfs.dmi'
		icon_state="tile5"
		density=1
		opacity=0
		build_category = BUILD_WALL
	Wall_Hell
		icon='Hell turf.dmi'
		icon_state="h2"
		density=1
		build_category = BUILD_WALL
	Wall_Force
		icon='Force Wall.dmi'
		density=1
		Pod_Enter=0
		build_category = BUILD_WALL
	Wall_Wood
		icon = 'celianna_clutter_walls2.dmi'
		icon_state = "Dark_Wood_Wall_1"
		density = 1
		build_category = BUILD_WALL
		New()
			if(x % 2) icon_state = "Dark_Wood_Wall_1"
			else icon_state = "Dark_Wood_Wall_2"
			. = ..()
	Wall_Wood_2
		icon = 'celianna_clutter_walls2.dmi'
		icon_state = "Dark_Wood_Wall_3"
		density = 1
		build_category = BUILD_WALL
		New()
			if(x % 2) icon_state = "Dark_Wood_Wall_3"
			else icon_state = "Dark_Wood_Wall_4"
			. = ..()
	Wall_Framed
		icon = 'celianna_clutter_walls2.dmi'
		icon_state = "Framed_Wall_1"
		density = 1
		build_category = BUILD_WALL
		New()
			if(x % 2) icon_state = "Framed_Wall_1"
			else icon_state = "Framed_Wall_2"
			. = ..()
	Wall_Rock_Panels
		icon = 'celianna_clutter_walls2_Part2.dmi'
		icon_state = "Paneled_Wall_3"
		density = 1
		build_category = BUILD_WALL
		New()
			if(x % 2) icon_state = "Paneled_Wall_3"
			else icon_state = "Paneled_Wall_4"
			. = ..()
	Wall_Blue
		icon = 'celianna_clutter_walls2_Part2.dmi'
		icon_state = "Blue_Wall_3"
		density = 1
		build_category = BUILD_WALL
		New()
			if(x % 2) icon_state = "Blue_Wall_3"
			else icon_state = "Blue_Wall_4"
			. = ..()





	Roof4
		icon='metaltiles1.dmi'
		icon_state="metalroofa"
		build_category = BUILD_ROOF
		density=1
		opacity=1

		Enter(atom/A) if(Roof_Enter(A)) return . = ..()
		Click() if(getdist(usr,src)<=1)
			Make_Dense_All(usr)
			Upgrade_All(usr,display_message=0)
	Roof5
		icon='metaltiles1.dmi'
		icon_state="metalroofb"
		density=1
		opacity=1
		build_category = BUILD_ROOF
		Enter(atom/A) if(Roof_Enter(A)) return . = ..()
		Click() if(getdist(usr,src)<=1)
			Make_Dense_All(usr)
			Upgrade_All(usr,display_message=0)
	Roof6
		icon='metaltiles1.dmi'
		icon_state="metalroofc"
		density=1
		opacity=1
		build_category = BUILD_ROOF
		Enter(atom/A) if(Roof_Enter(A)) return . = ..()
		Click() if(getdist(usr,src)<=1)
			Make_Dense_All(usr)
			Upgrade_All(usr,display_message=0)
	Roof7
		icon='Tiles 1.21.2011.dmi'
		icon_state="Roof"
		density=1
		opacity=1
		build_category = BUILD_ROOF
		Enter(atom/A) if(Roof_Enter(A)) return . = ..()
		Click() if(getdist(usr,src)<=1)
			Make_Dense_All(usr)
			Upgrade_All(usr,display_message=0)
	Roof8
		icon='Tiles 1.21.2011.dmi'
		icon_state="Roof-5"
		density=1
		opacity=1
		build_category = BUILD_ROOF
		Enter(atom/A) if(Roof_Enter(A)) return . = ..()
		Click() if(getdist(usr,src)<=1)
			Make_Dense_All(usr)
			Upgrade_All(usr,display_message=0)
	Roof9
		icon='Tiles 1.21.2011.dmi'
		icon_state="Roof-1"
		density=1
		opacity=1
		build_category = BUILD_ROOF
		Enter(atom/A) if(Roof_Enter(A)) return . = ..()
		Click() if(getdist(usr,src)<=1)
			Make_Dense_All(usr)
			Upgrade_All(usr,display_message=0)
	Roof10
		icon='Tiles 1.21.2011.dmi'
		icon_state="Roof-2"
		density=1
		opacity=1
		build_category = BUILD_ROOF
		Enter(atom/A) if(Roof_Enter(A)) return . = ..()
		Click() if(getdist(usr,src)<=1)
			Make_Dense_All(usr)
			Upgrade_All(usr,display_message=0)
	RoofTech
		icon='Space.dmi'
		icon_state="top"
		density=1
		opacity=1
		build_category = BUILD_ROOF
		Enter(atom/A) if(Roof_Enter(A)) return . = ..()
		Click() if(getdist(usr,src)<=1)
			Make_Dense_All(usr)
			Upgrade_All(usr,display_message=0)
	Hell_Roof
		icon='Hell turf.dmi'
		density=1
		opacity=1
		build_category = BUILD_ROOF
		Enter(atom/A) if(Roof_Enter(A)) return . = ..()
		Click() if(getdist(usr,src)<=1)
			Make_Dense_All(usr)
			Upgrade_All(usr,display_message=0)
	Roof1
		icon='Turfs 96.dmi'
		icon_state="roof3"
		density=1
		opacity=1
		build_category = BUILD_ROOF
		Enter(atom/A) if(Roof_Enter(A)) return . = ..()
		Click() if(getdist(usr,src)<=1)
			Make_Dense_All(usr)
			Upgrade_All(usr,display_message=0)
	Roof2
		icon='Turfs.dmi'
		icon_state="roof2"
		build_category = BUILD_ROOF
		density=1
		opacity=1
		Enter(atom/A) if(Roof_Enter(A)) return . = ..()
		Click() if(getdist(usr,src)<=1)
			Make_Dense_All(usr)
			Upgrade_All(usr,display_message=0)
	Roof3
		icon='Turfs 96.dmi'
		icon_state="roof4"
		density=1
		opacity=1
		build_category = BUILD_ROOF
		Enter(atom/A) if(Roof_Enter(A)) return . = ..()
		Click() if(getdist(usr,src)<=1)
			Make_Dense_All(usr)
			Upgrade_All(usr,display_message=0)
	RoofWhite
		icon='turfs.dmi'
		icon_state="block_wall1"
		density=1
		opacity=1
		build_category = BUILD_ROOF
		Enter(atom/A) if(Roof_Enter(A)) return . = ..()
		Click() if(getdist(usr,src)<=1)
			Make_Dense_All(usr)
			Upgrade_All(usr,display_message=0)
	Roof_Purple_Plain
		icon='purple block.dmi'
		density=1
		opacity=1
		build_category = BUILD_ROOF
		Enter(atom/A) if(Roof_Enter(A)) return . = ..()
		Click() if(getdist(usr,src)<=1)
			Make_Dense_All(usr)
			Upgrade_All(usr,display_message=0)
	Tech_Roof
		icon='sci fi roof.dmi'
		density=1
		opacity=1
		build_category = BUILD_ROOF
		layer = TURF_LAYER + 0.2
		Enter(atom/A) if(Roof_Enter(A)) return ..()
		Click() if(getdist(usr,src)<=1)
			Make_Dense_All(usr)
			Upgrade_All(usr,display_message=0)
	Roof_11
		icon='TileA3.dmi'
		icon_state = "BlueRoof3"
		density=1
		opacity=1
		build_category = BUILD_ROOF
		layer = TURF_LAYER + 0.2
		Enter(atom/A) if(Roof_Enter(A)) return ..()
		Click() if(getdist(usr,src)<=1)
			Make_Dense_All(usr)
			Upgrade_All(usr,display_message=0)





	Tile38
		icon='metaltiles1.dmi'
		icon_state="metalfloora"
		build_category = BUILD_FLOOR
	Tile39
		icon='metaltiles1.dmi'
		icon_state="metalfloorsn"
		build_category = BUILD_FLOOR
	Tile40
		icon='metaltiles1.dmi'
		icon_state="gratingfloora"
		build_category = BUILD_FLOOR
	Tile41
		icon='metaltiles1.dmi'
		icon_state="gratingfloorb"
		build_category = BUILD_FLOOR
	Tile42
		icon='metaltiles1.dmi'
		icon_state="metalfloorb"
		build_category = BUILD_FLOOR
	Tile43
		icon='Tiles 1.21.2011.dmi'
		icon_state="a 1"
		build_category = BUILD_FLOOR
	Tile44
		icon='Tiles 1.21.2011.dmi'
		icon_state="1"
		build_category = BUILD_FLOOR
	Tile45
		icon='Tiles 1.21.2011.dmi'
		icon_state="dirt"
		build_category = BUILD_FLOOR
	Tile46
		icon='Tiles 1.21.2011.dmi'
		icon_state="3"
		build_category = BUILD_FLOOR
	Tile47
		icon='Tiles 1.21.2011.dmi'
		icon_state="5"
		build_category = BUILD_GROUND
	Tile48
		icon='Tiles 1.21.2011.dmi'
		icon_state="8"
		build_category = BUILD_FLOOR
	Tile49
		icon='Tiles 1.21.2011.dmi'
		icon_state="9"
		build_category = BUILD_GROUND
	Tile50
		icon='Tiles 1.21.2011.dmi'
		icon_state="10"
		build_category = BUILD_FLOOR
	Tile51
		icon='Tiles 1.21.2011.dmi'
		icon_state="18"
		build_category = BUILD_FLOOR
	Tile52
		icon='Tiles 1.21.2011.dmi'
		icon_state="19"
		build_category = BUILD_FLOOR
	Tile53
		icon='Tiles 1.21.2011.dmi'
		icon_state="desert"
		build_category = BUILD_FLOOR
	Tile54
		icon='Tiles 1.21.2011.dmi'
		icon_state="25"
		build_category = BUILD_FLOOR
	Tile55
		icon='Tiles 1.21.2011.dmi'
		icon_state="26"
		build_category = BUILD_FLOOR
	Tile56
		icon='Tiles 1.21.2011.dmi'
		icon_state="27"
		build_category = BUILD_FLOOR
	Tile56
		icon='Tiles 1.21.2011.dmi'
		icon_state="30"
		build_category = BUILD_FLOOR
	Tile57
		icon='Tiles 1.21.2011.dmi'
		icon_state="bb"
		build_category = BUILD_FLOOR
	Tile58
		icon='Tiles 1.21.2011.dmi'
		icon_state="metal floor-1"
		build_category = BUILD_FLOOR
	Tile59
		icon='Tiles 1.21.2011.dmi'
		icon_state="metal floor-2"
		build_category = BUILD_FLOOR
	Tile60
		icon='Tiles 1.21.2011.dmi'
		icon_state="39"
		build_category = BUILD_FLOOR
	Tile61
		icon='Tiles 1.21.2011.dmi'
		icon_state="40"
		build_category = BUILD_GROUND
	Tile62
		icon='Tiles 1.21.2011.dmi'
		icon_state="37"
		build_category = BUILD_FLOOR
	TileWood
		icon='Turfs 96.dmi'
		icon_state="woodfloor"
		build_category = BUILD_FLOOR
	TileBlue
		icon='turfs.dmi'
		icon_state="tile11"
		build_category = BUILD_FLOOR
	Tile26
		icon='turfs.dmi'
		icon_state="tile9"
		build_category = BUILD_FLOOR
	Tile25
		icon='Turfs 4.dmi'
		icon_state="cooltiles"
		build_category = BUILD_FLOOR
	Tile21
		icon='Turfs 12.dmi'
		icon_state="Girly Carpet"
		build_category = BUILD_FLOOR
	Tile23
		icon='Turfs 12.dmi'
		icon_state="Wood_Floor"
		build_category = BUILD_FLOOR
	Tile17
		icon='turfs.dmi'
		icon_state="roof4"
		build_category = BUILD_FLOOR
	Tile15
		icon='Turfs 12.dmi'
		icon_state="stonefloor"
		build_category = BUILD_FLOOR
	Tile6
		icon='Turfs 12.dmi'
		icon_state="floor4"
		build_category = BUILD_FLOOR
	Tile14
		icon='turfs.dmi'
		icon_state="tile10"
		build_category = BUILD_FLOOR
	Tile22
		icon='FloorsLAWL.dmi'
		icon_state="SS Floor"
		build_category = BUILD_FLOOR
	TileStone
		icon='Turf 57.dmi'
		icon_state="55"
		build_category = BUILD_FLOOR
	Tile13
		icon='Turfs 1.dmi'
		icon_state="ground"
		build_category = BUILD_FLOOR
	TileWood
		icon='Turf 57.dmi'
		icon_state="woodfloor"
		build_category = BUILD_FLOOR
	Tile19
		icon='Turfs 12.dmi'
		icon_state="floor2"
		build_category = BUILD_FLOOR
	Tile20
		icon='turfs.dmi'
		icon_state="tile4"
		build_category = BUILD_FLOOR
	Tile2
		icon='FloorsLAWL.dmi'
		icon_state="Tile"
		build_category = BUILD_FLOOR
	Tile12
		icon='Turfs 15.dmi'
		icon_state="floor7"
		build_category = BUILD_FLOOR
	TileBlue2
		icon='turfs.dmi'
		icon_state="tile12"
		build_category = BUILD_FLOOR
	Tile13
		icon='Turfs 15.dmi'
		icon_state="floor6"
		build_category = BUILD_FLOOR
	Tile24
		icon='turfs.dmi'
		icon_state="bridgemid2"
		edge_icon = 'EdgesBridge.dmi'
		auto_cliff = 0
		auto_wave = 0
		do_south_edge = 1
		build_category = BUILD_FLOOR
	Tile10
		icon='FloorsLAWL.dmi'
		icon_state="Flagstone Vegeta"
		build_category = BUILD_GROUND
	Tile11
		icon='Turfs 2.dmi'
		icon_state="dirt"
		build_category = BUILD_FLOOR
	Tile30
		icon='Turfs Temple.dmi'
		icon_state="floor"
		build_category = BUILD_FLOOR
	Tile31
		icon='Turfs Temple.dmi'
		icon_state="glassfloor"
		build_category = BUILD_FLOOR
	Tile32
		icon='Turfs Temple.dmi'
		icon_state="tile"
		build_category = BUILD_FLOOR
	Tile33
		icon='Turfs Temple.dmi'
		icon_state="tile2"
		build_category = BUILD_FLOOR
	Tile34
		icon='Turfs Temple.dmi'
		icon_state="tile3"
		build_category = BUILD_FLOOR
	Tile35
		icon='Turfs Temple.dmi'
		icon_state="tile4"
		build_category = BUILD_FLOOR
	Tile36
		icon='floor3.dmi'
		build_category = BUILD_FLOOR
	Tile37
		icon='woodfloor1.dmi'
		build_category = BUILD_FLOOR
	Tile_Hell1
		icon='Hell turf.dmi'
		icon_state="h1"
		build_category = BUILD_FLOOR
	Tile_Hell2
		icon='Hell turf.dmi'
		icon_state="h3"
		build_category = BUILD_FLOOR
	Tile_Hell3
		icon='Hell turf.dmi'
		icon_state="h4"
		build_category = BUILD_FLOOR
	Tile_Hell4
		icon='Hell turf.dmi'
		icon_state="h5"
		build_category = BUILD_FLOOR
	Tile_Hell5
		icon='Hell turf.dmi'
		build_category = BUILD_FLOOR
	Tile18
		icon='Turfs 12.dmi'
		icon_state="Aluminum Floor"
		build_category = BUILD_FLOOR
	Tile8
		icon='Turfs 1.dmi'
		icon_state="woodenground"
		build_category = BUILD_FLOOR
	Tile16
		icon='Turfs 14.dmi'
		icon_state="Stone"
		edge_icon = 'EdgesBridge.dmi'
		build_category = BUILD_FLOOR
	Tile27
		icon='turfs.dmi'
		icon_state="tile7"
		build_category = BUILD_FLOOR
	Tile28
		icon='turfs.dmi'
		icon_state="floor"
		build_category = BUILD_FLOOR
	TileGold
		icon='Turf 55.dmi'
		icon_state="goldfloor"
		build_category = BUILD_FLOOR
	Tile9
		icon='Turfs 18.dmi'
		icon_state="wooden"
		build_category = BUILD_FLOOR
	Tile8
		icon='Turfs 18.dmi'
		icon_state="diagwooden"
		build_category = BUILD_FLOOR
	Tile1
		icon='Turfs 12.dmi'
		icon_state="Brick_Floor"
		build_category = BUILD_FLOOR
	TileWhite
		icon='White.dmi'
		build_category = BUILD_FLOOR
	Tile2
		icon='Turfs 12.dmi'
		icon_state="Stone Crystal Path"
		build_category = BUILD_FLOOR
	Tile3
		icon='Turfs 12.dmi'
		icon_state="Stones"
		build_category = BUILD_FLOOR
	Tile4
		icon='Turfs 12.dmi'
		icon_state="Black Tile"
		build_category = BUILD_FLOOR
	Tile5
		icon='Turfs 12.dmi'
		icon_state="Dirty Brick"
		build_category = BUILD_FLOOR
	Tile_Tech_Floor
		icon = 'tech floor.dmi'
		build_category = BUILD_FLOOR
		New()
			DecideTurfStateForSpecialIcons(10,10)
			..()
	Tile_Tech_Grate
		icon = 'tech floor grate.dmi'
		build_category = BUILD_FLOOR
		New()
			DecideTurfStateForSpecialIcons(2,2)
			..()
	Tile_Landing_Bay
		icon = 'Tech Bay Floor.dmi'
		build_category = BUILD_FLOOR
		New()
			DecideTurfStateForSpecialIcons(8,8)
			..()
	Tile_Tech_Dark
		icon = 'Tech Floor Dark.dmi'
		build_category = BUILD_FLOOR
		New()
			DecideTurfStateForSpecialIcons(8,8)
			..()




	Stairs1
		icon='Turfs 96.dmi'
		icon_state="steps"
		auto_edge = 0
		auto_cliff = 0
		build_category = BUILD_FLOOR
	StairsHell
		icon='Turf 57.dmi'
		icon_state="hellstairs"
		auto_edge = 0
		auto_cliff = 0
		build_category = BUILD_FLOOR
	Stairs4
		icon='Turfs 1.dmi'
		icon_state="stairs1"
		auto_edge = 0
		auto_cliff = 0
		build_category = BUILD_FLOOR
	Stairs5
		icon='Turfs 1.dmi'
		icon_state="earthstairs"
		auto_edge = 0
		auto_cliff = 0
		build_category = BUILD_FLOOR
	Stairs3
		icon='Turfs 1.dmi'
		icon_state="stairs2"
		auto_edge = 0
		auto_cliff = 0
		build_category = BUILD_FLOOR
	Stairs2
		icon='Turfs 12.dmi'
		icon_state="Steps"
		auto_edge = 0
		auto_cliff = 0
		build_category = BUILD_FLOOR
	Stairs6
		icon='Turfs Temple.dmi'
		icon_state="council"
		auto_edge = 0
		auto_cliff = 0
		build_category = BUILD_FLOOR
	Stairs7
		icon='Tiles 1.21.2011.dmi'
		icon_state="e"
		auto_edge = 0
		auto_cliff = 0
		build_category = BUILD_FLOOR
	Stairs_Grass
		icon = 'celianna_farmnature_tileset.dmi'
		icon_state = "Grass_Stairs"
		auto_edge = 0
		auto_cliff = 0
		build_category = BUILD_FLOOR



	Water6
		icon='Turfs 1.dmi'
		icon_state="water"
		Water=1
		wave_icon = null //none is made for this icon
		Enter(mob/P) if(Water_Enter(P)) return . = ..()
		Exit(mob/P) if(Water_Exit(P)) return . = ..()

	WaterReal
		icon='Water Blue 2017.dmi'
		icon_state="0,0"
		Water=1
		wave_icon = null
		Enter(mob/P) if(Water_Enter(P)) return . = ..()
		Exit(mob/P) if(Water_Exit(P)) return . = ..()
		New()
			. = ..()
			DecideTurfStateForSpecialIcons(6,6)

	Water5
		icon='Turfs 4.dmi'
		icon_state="kaiowater"
		Water=1
		wave_icon = 'Surf5.dmi'
		Enter(mob/P) if(Water_Enter(P)) return . = ..()
		Exit(mob/P) if(Water_Exit(P)) return . = ..()
	WaterFall
		icon='Turfs 1.dmi'
		icon_state="waterfall"
		density=1
		layer=MOB_LAYER+1
		Enter(mob/P) if(Water_Enter(P)) return . = ..()
		Exit(mob/P) if(Water_Exit(P)) return . = ..()

	Water3
		icon='Misc.dmi'
		icon_state="Water"
		//icon = 'bigwater2019.dmi'
		Water=1
		wave_icon = 'Surf3.dmi'
		Enter(mob/P) if(Water_Enter(P)) return . = ..()
		Exit(mob/P) if(Water_Exit(P)) return . = ..()
		//New()
			//. = ..()
			//DecideTurfStateForSpecialIcons(8,8)

	WaterFast
		icon='Water Blue 2, 2017.dmi'
		icon_state = "0,0"
		Water=1
		wave_icon = null
		Enter(mob/P) if(Water_Enter(P)) return . = ..()
		Exit(mob/P) if(Water_Exit(P)) return . = ..()
		New()
			. = ..()
			DecideTurfStateForSpecialIcons(4,4)

	Water8
		icon='turfs.dmi'
		icon_state="nwater"
		Water=1
		wave_icon = 'Surf4.dmi'
		Enter(mob/P) if(Water_Enter(P)) return . = ..()
		Exit(mob/P) if(Water_Exit(P)) return . = ..()
	Water1
		icon='Turfs 12.dmi'
		icon_state="water3"
		Water=1
		wave_icon = null
		Enter(mob/P) if(Water_Enter(P)) return . = ..()
		Exit(mob/P) if(Water_Exit(P)) return . = ..()

	WaterToxic
		icon = 'Toxic Water.dmi'
		icon_state = "0,0"
		Water = 1
		wave_icon = null
		Enter(mob/P) if(Water_Enter(P)) return . = ..()
		Exit(mob/P) if(Water_Exit(P)) return . = ..()
		New()
			. = ..()
			DecideTurfStateForSpecialIcons(6,6)

	Water11
		icon='Cartoon Water 2017.dmi'
		icon_state="0,0"
		Water=1
		wave_icon = null
		Enter(mob/P) if(Water_Enter(P)) return . = ..()
		Exit(mob/P) if(Water_Exit(P)) return . = ..()
		New()
			DecideTurfStateForSpecialIcons(4,4)
			. = ..()

	Water7
		//icon='turfs.dmi'
		//icon_state="lava"
		icon = 'Lava 2017.dmi'
		icon_state = "0,0"
		density=0
		Water = 1
		wave_icon = null
		Enter(mob/P) if(Water_Enter(P)) return . = ..()
		Exit(mob/P) if(Water_Exit(P)) return . = ..()
		New()
			DecideTurfStateForSpecialIcons(4,4)
			. = ..()
	Water2
		icon='Turfs 96.dmi'
		icon_state="stillwater"
		Water=1
		wave_icon = 'Surf2.dmi'
		Enter(mob/P) if(Water_Enter(P)) return . = ..()
		Exit(mob/P) if(Water_Exit(P)) return . = ..()
	Water12
		icon='Turfs 12.dmi'
		icon_state="water4"
		Water=1
		wave_icon = 'Surf1.dmi'
		Enter(mob/P) if(Water_Enter(P)) return . = ..()
		Exit(mob/P) if(Water_Exit(P)) return . = ..()
	Water9
		icon='Turfs 12.dmi'
		icon_state="water1"
		Water=1
		wave_icon = 'Surf6.dmi'
		Enter(mob/P) if(Water_Enter(P)) return . = ..()
		Exit(mob/P) if(Water_Exit(P)) return . = ..()
	Water10
		icon='Turf 50.dmi'
		icon_state="9.1"
		Water=1
		wave_icon = 'Surf1.dmi'
		Enter(mob/P) if(Water_Enter(P)) return . = ..()
		Exit(mob/P) if(Water_Exit(P)) return . = ..()
	CaveEntrance
		icon='Turf 57.dmi'
		icon_state="13"

turf/proc/Water_Ripple(mob/P)
	set waitfor=0
	return //TEMP DISABLED
	var/image/I=image(icon='KiWater.dmi')
	if(P.dir in list(NORTH,SOUTH)) I.icon_state="NS"
	if(P.dir in list(EAST,WEST)) I.icon_state="EW"
	overlays+=I
	sleep(20)
	overlays-=I

turf/proc/Water_Enter(mob/P)
	if(ismob(P))
		if(P.Flying || !P.density || P.KB)
			Water_Ripple(P)
			return 1
		/*else if(P.Ki>P.Swim_Drain())
			Swim(P)
			return 1*/
	else
		Water_Ripple(P)
		return 1

turf/proc/Water_Exit(mob/P)
	//for(var/A in P.overlays) if(A:icon) if(A:icon=='Water Overlay.dmi') P.overlays-=A
	return 1

var/Swim_Drain=20
mob/var/Swim_Mastery=1
mob/proc/Swim_Drain() return (max_ki/Swim_Drain)/Swim_Mastery
turf/proc/Swim(mob/P)
	//P.overlays-='Water Overlay.dmi'
	//spawn for(var/turf/T in range(0,P)) if(T.Water)
		//P.overlays+='Water Overlay.dmi'
	P.Ki-=P.Swim_Drain()
	P.Swim_Mastery+=0.02
mob/proc/Swim(turf/Location)
	overlays-='Water Overlay.dmi'
	if(Location.Water) overlays+='Water Overlay.dmi'
	//spawn if(src) for(var/turf/T in range(0,src)) if(T.Water) overlays+='Water Overlay.dmi'
obj/Surf
	mapObject = 1
	layer=2
	Givable=0
	Makeable=0
	Savable=0
	Knockable=0
	Spawn_Timer=180000
	Grabbable=0
	Nukable=0
	Water10Surf
		icon='Surf1.dmi'
	Water10Surf2
		icon='Surf1.dmi'
		icon_state="N"
	Water9Surf
		icon='Surf6.dmi'
	Water9Surf2
		icon='Surf6.dmi'
		icon_state="N"
	Water2Surf
		icon='Surf2.dmi'
	Water2Surf2
		icon='Surf2.dmi'
		icon_state="N"
	Water8Surf
		icon='Surf4.dmi'
	Water8Surf2
		icon='Surf4.dmi'
		icon_state="N"
	Water3Surf
		icon='Surf3.dmi'
	Water3Surf2
		icon='Surf3.dmi'
		icon_state="N"
	Water5Surf
		icon='Surf5.dmi'
	Water5Surf2
		icon='Surf5.dmi'
		icon_state="S"




obj/Planet_Restore_Crystal
	density=1
	layer=6
	desc="Use this to restore a destroyed planet"
	Savable=0
	Health=1.#INF
	Dead_Zone_Immune=1
	Knockable=0
	Bolted=1
	Grabbable=0
	Cloakable=0
	can_blueprint=0
	icon='green crystal.png'

	New()
		. = ..()
		GiveLightSource(size = 3, max_alpha = 40, light_color = rgb(224,255,224))

	proc
		DespawnRespawn()
			set waitfor=0
			if(!z) return
			var/z_level = z
			loc = null
			//sleep(5 * 600)
			while(src)
				//SafeTeleport(locate(rand(1,world.maxx),rand(1,world.maxy),z_level))
				loc = locate(rand(1,world.maxx),rand(1,world.maxy),z_level)
				var/turf/t = loc
				if(!t.density) break





var/list/revival_altars=new

obj/Revival_Altar
	density=1
	desc="Click this to see if you are eligible to come back to life automatically"
	Savable=0
	Health=1.#INF
	Dead_Zone_Immune=1
	Knockable=0
	Bolted=1
	Grabbable=0
	Cloakable=0
	layer=6
	can_blueprint=0
	icon='Revive Altar.dmi'
	New()
		CenterIcon(src)
		pixel_y=0
		revival_altars+=src
		GiveLightSource(size = 3, max_alpha = 30)

	Click() if(usr in view(1,src))
		usr.Revival_altar()

mob/proc/revive_modifier()
	var/n = (highest_bp_ever_had / bp_mod / highest_base_and_hbtc_bp)
	n=n**1.3
	if(n<0.01) n=0.01
	return n

mob/proc/revive_time()
	if(auto_revive_timer == 0) return 0
	var/n = death_time + (auto_revive_timer * 600 * revive_modifier())
	if(Race == "Android") n = death_time + (auto_revive_timer * 600)
	if(ThingC()) n *= 0.45
	return n

mob/proc/Revival_altar()
	//if(!auto_revive_timer)
	//	src<<"Automatic revives are off on this server"
	//	return

	if(!Dead)
		src<<"You are not dead. But if you die, click this to see if you are eligible to come back to life"
		return

	if(world.realtime>=revive_time())
		Revive()
		//switch(alert(src,"You were brought back to life. Do you want to go to your spawn?","Options","Yes","No"))
		//	if("Yes") Respawn()
		if(!AtBattlegrounds())
			Respawn()

	else
		var/minutes=(revive_time()-world.realtime)/10/60
		src<<"You are not eligible to come back to life for another [round(minutes)] minutes"
		return


obj/Sacrificial_Altar
	desc="Click this to see what deals you can make with hell itself"
	Savable=0
	Health=1.#INF
	Dead_Zone_Immune=1
	Knockable=0
	Bolted=1
	Grabbable=0
	Cloakable=0
	can_blueprint=0
	icon='Lab.dmi'
	icon_state="Strap2"
	overlays=newlist(/image{icon='Lab.dmi' icon_state="Strap1" pixel_x=-32},\
		/image{icon='Lab.dmi' icon_state="Strap3" pixel_x=32})
	Click() if(usr in view(1,src)) usr.Altar_Options(src)

mob/var
	list/hell_agreements=new
	next_altar_use=0

mob/proc/Altar_Options(obj/altar)

	GiveFeat("Find and use Vampire Altar")

	if(world.realtime<next_altar_use)
		var/hours=(next_altar_use-world.realtime)/10/60/60
		src<<"You can not use this again for another [round(hours)] hours and [round(hours*60%60)] \
		minutes"
		return
	switch(input(src,"Using this altar you can make a deal with hell itself. The deals have drawbacks. \
	Upon death all deals are broken. Click a deal for details, it will then ask you if you accept.") in \
	list("Just walk away","Ask for revive"))
		if("Ask for revive")
			if(!Dead)
				src<<"You are not dead"
				return
			switch(input(src,"Choose what you are willing to sacrifice to come back to life") in \
			list("Nevermind","Become a vampire"))
				if("Nevermind") return
				if("Become a vampire")
					if(Former_Vampire)
						alert("You are immune to vampirism")
						return
					next_altar_use=world.realtime + (2 * 60 * 60 * 10)
					hell_agreements+="vampire"
					Revive()
					Become_Vampire()
					src<<"You have been turned into a vampire in service of hell, spread the virus in hell's name"
					switch(alert(src,"Go to your spawn?","Options","Yes","No"))
						if("Yes") Respawn()
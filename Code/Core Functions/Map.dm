turf/proc
	RandomDirtOverlay(n = 1)
		if(prob(1 * n))
			var/image/i = image(icon = 'Dirt Patch Overlays.dmi')
			i.icon_state = pick("1","2","3","4","5","6","7","8")
			overlays |= i
			return 1

	RandomGrassOverlay(n = 1)
		if(prob(1 * n))
			var/o = pick('grass plant overlay red flowers.png','grass plant overlay white flowers.png',\
			'grass plant overlay.png')
			overlays |= o
			return 1

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

	RockEdgeN
		icon='Edges1.dmi'
		icon_state="N"
		dir=NORTH

	RockEdgeS
		icon='Edges1.dmi'
		icon_state="S"
		dir=SOUTH
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
	RockEdge2S
		icon='Edges2.dmi'
		icon_state="S"
		dir=SOUTH
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
	Edge3S
		icon='Edges3.dmi'
		icon_state="S"
		dir=SOUTH
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
	Edge4S
		icon='Edges4.dmi'
		icon_state="S"
		dir=SOUTH
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
	Edge5S
		icon='Edges5.dmi'
		icon_state="S"
		dir=SOUTH
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
	Edge6S
		icon='Edges6.dmi'
		icon_state="S"
		dir=SOUTH
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
		icon_state="N"
		dir=NORTH
	Edge7S
		icon='Misc.dmi'
		icon_state="S"
		dir=SOUTH
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
	PodEdgeS
		icon='Edges7.dmi'
		icon_state="S"
		dir=SOUTH
	PodEdgeW
		icon='Edges7.dmi'
		icon_state="W"
		dir=WEST
	PodEdgeE
		icon='Edges7.dmi'
		icon_state="E"
		dir=EAST

	LightMetalEdgeN
		icon='EdgesLightMetal.dmi'
		icon_state="N"
		dir=NORTH
	LightMetalEdgeS
		icon='EdgesLightMetal.dmi'
		icon_state="S"
		dir=SOUTH
	LightMetalEdgeW
		icon='EdgesLightMetal.dmi'
		icon_state="W"
		dir=WEST
	LightMetalEdgeE
		icon='EdgesLightMetal.dmi'
		icon_state="E"
		dir=EAST

	LightMetalPatternEdgeN
		icon='EdgesLightMetalPattern.dmi'
		icon_state="N"
		dir=NORTH
	LightMetalPatternEdgeS
		icon='EdgesLightMetalPattern.dmi'
		icon_state="S"
		dir=SOUTH
	LightMetalPatternEdgeW
		icon='EdgesLightMetalPattern.dmi'
		icon_state="W"
		dir=WEST
	LightMetalPatternEdgeE
		icon='EdgesLightMetalPattern.dmi'
		icon_state="E"
		dir=EAST

	DarkMetalEdgeN
		icon='EdgesDarkMetal.dmi'
		icon_state="N"
		dir=NORTH
	DarkMetalEdgeS
		icon='EdgesDarkMetal.dmi'
		icon_state="S"
		dir=SOUTH
	DarkMetalEdgeW
		icon='EdgesDarkMetal.dmi'
		icon_state="W"
		dir=WEST
	DarkMetalEdgeE
		icon='EdgesDarkMetal.dmi'
		icon_state="E"
		dir=EAST

	DarkMetalPatternEdgeN
		icon='EdgesDarkMetalPattern.dmi'
		icon_state="N"
		dir=NORTH
	DarkMetalPatternEdgeS
		icon='EdgesDarkMetalPattern.dmi'
		icon_state="S"
		dir=SOUTH
	DarkMetalPatternEdgeW
		icon='EdgesDarkMetalPattern.dmi'
		icon_state="W"
		dir=WEST
	DarkMetalPatternEdgeE
		icon='EdgesDarkMetalPattern.dmi'
		icon_state="E"
		dir=EAST

turf/var/InitialType

var/DH_ANNOUNCE = 0

turf/var/Pod_Enter=1
atom/movable/var
	tmp/turf/Spawn_Location
	Spawn_Timer=0

proc/Set_Spawn_Point(mob/P)
	if(P.Spawn_Timer) P.Spawn_Location=P.loc

var/list/turf_respawn_list=new

turf/var/tmp
	last_builder
	last_flyover

turf/Del()
	var/Type=type

	if(!InitialType) InitialType=type
	if(InitialType) Type=InitialType

	if(Builder && (density||!FlyOverAble)) //right now only dense player made structures will rebuild, and only if they werent nuked
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
	layer=DECOR_LAYER
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
				if(!Limits.GetSettingValue("Custom Decorations"))
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
			is_hbtc_door = 0

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
		
		verb/Toggle_Lock()
			set src in view(usr,1)
			if(!Password)
				var/newPassword = input(usr,"Enter a password or leave blank") as text|null
				if(!newPassword) return
				Password = newPassword
			else
				if((input(usr, "Input current password to unlock.") as text|null) == Password)
					Password = null
				for(var/obj/items/Door_Pass/dp in usr.item_list) if(dp.Password == Password)
					Password = null
	Sign
		icon='Sign.dmi'
		density=1
		Knockable=0
		maptext_height=256
		maptext_width=128
		Click()
			if(maptext)
				usr.SendMsg(maptext, CHAT_IC)

		verb/Bolt()
			set src in oview(1)
			usr.Bolt(src)

		New()
			. = ..()
			if(name == "Planet Braal Fitness")
				maptext = "<b><span style='font-color:green;font-size:3pt'>Public training area, behave yourselves!</span></b>"

	Sign/Information_Panel
		icon='Lab.dmi'
		icon_state="Radar"
		Click()
			if(maptext)
				usr.SendMsg(maptext, CHAT_IC)
				
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
	Glass2
		icon='glasspane.dmi'
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
	FancyCouch
		New()
			var/image/A=image(icon='Turf 52.dmi',icon_state="couch left",pixel_x=-16)
			var/image/B=image(icon='Turf 52.dmi',icon_state="couch right",pixel_x=16)
			overlays=null
			overlays.Add(A,B)
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
	icon = null

	Dead_Tree_1
		New()
			var/image/A=image(icon='turfs66.dmi',icon_state="2",pixel_x=0,pixel_y=0,layer=layer)
			var/image/B=image(icon='turfs66.dmi',icon_state="3",pixel_x=-32,pixel_y=32,layer=MOB_LAYER+1)
			var/image/C=image(icon='turfs66.dmi',icon_state="42",pixel_x=0,pixel_y=32,layer=MOB_LAYER+1)
			var/image/D=image(icon='turfs66.dmi',icon_state="31",pixel_x=32,pixel_y=32,layer=MOB_LAYER+1)
			overlays=null
			overlays.Add(A,B,C,D)
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
		overlays=newlist(/image{icon='turfs66.dmi'; icon_state="treeleftbot2"; pixel_x=-16; pixel_y=0},\
		/image{icon='turfs66.dmi'; icon_state="treerightbot2"; pixel_x=16; pixel_y=0},\
		/image{icon='turfs66.dmi'; icon_state="treelefttop2"; pixel_x=-16; pixel_y=32; layer=MOB_LAYER+1},\
		/image{icon='turfs66.dmi'; icon_state="treerighttop2"; pixel_x=16; pixel_y=32; layer=MOB_LAYER+1})
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
	TallBush
		density=1
		icon='Turf3.dmi'
		icon_state="tallplantbottom"
		New()
			var/image/A=image(icon='Turf3.dmi',icon_state="tallplanttop",pixel_y=32,layer=4)
			overlays=null
			overlays.Add(A)


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
	Savable=0
	Buildable=1
	Grabbable=0
	

	RockEdgeN
		icon='Edges1.dmi'
		icon_state="N"
		dir=NORTH

	RockEdgeS
		icon='Edges1.dmi'
		icon_state="S"
		dir=SOUTH
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
	RockEdge2S
		icon='Edges2.dmi'
		icon_state="S"
		dir=SOUTH
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
	Edge3S
		icon='Edges3.dmi'
		icon_state="S"
		dir=SOUTH
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
	Edge4S
		icon='Edges4.dmi'
		icon_state="S"
		dir=SOUTH
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
	Edge5S
		icon='Edges5.dmi'
		icon_state="S"
		dir=SOUTH
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
	Edge6S
		icon='Edges6.dmi'
		icon_state="S"
		dir=SOUTH
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
		icon_state="N"
		dir=NORTH
	Edge7S
		icon='Misc.dmi'
		icon_state="S"
		dir=SOUTH
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
	PodEdgeS
		icon='Edges7.dmi'
		icon_state="S"
		dir=SOUTH
	PodEdgeW
		icon='Edges7.dmi'
		icon_state="W"
		dir=WEST
	PodEdgeE
		icon='Edges7.dmi'
		icon_state="E"
		dir=EAST

	LightMetalEdgeN
		icon='EdgesLightMetal.dmi'
		icon_state="N"
		dir=NORTH
	LightMetalEdgeS
		icon='EdgesLightMetal.dmi'
		icon_state="S"
		dir=SOUTH
	LightMetalEdgeW
		icon='EdgesLightMetal.dmi'
		icon_state="W"
		dir=WEST
	LightMetalEdgeE
		icon='EdgesLightMetal.dmi'
		icon_state="E"
		dir=EAST

	LightMetalPatternEdgeN
		icon='EdgesLightMetalPattern.dmi'
		icon_state="N"
		dir=NORTH
	LightMetalPatternEdgeS
		icon='EdgesLightMetalPattern.dmi'
		icon_state="S"
		dir=SOUTH
	LightMetalPatternEdgeW
		icon='EdgesLightMetalPattern.dmi'
		icon_state="W"
		dir=WEST
	LightMetalPatternEdgeE
		icon='EdgesLightMetalPattern.dmi'
		icon_state="E"
		dir=EAST

	DarkMetalEdgeN
		icon='EdgesDarkMetal.dmi'
		icon_state="N"
		dir=NORTH
	DarkMetalEdgeS
		icon='EdgesDarkMetal.dmi'
		icon_state="S"
		dir=SOUTH
	DarkMetalEdgeW
		icon='EdgesDarkMetal.dmi'
		icon_state="W"
		dir=WEST
	DarkMetalEdgeE
		icon='EdgesDarkMetal.dmi'
		icon_state="E"
		dir=EAST

	DarkMetalPatternEdgeN
		icon='EdgesDarkMetalPattern.dmi'
		icon_state="N"
		dir=NORTH
	DarkMetalPatternEdgeS
		icon='EdgesDarkMetalPattern.dmi'
		icon_state="S"
		dir=SOUTH
	DarkMetalPatternEdgeW
		icon='EdgesDarkMetalPattern.dmi'
		icon_state="W"
		dir=WEST
	DarkMetalPatternEdgeE
		icon='EdgesDarkMetalPattern.dmi'
		icon_state="E"
		dir=EAST

turf/var/Water


//okay what this does is if we take a large image texture from like google images of a ground texture and its like 128x128, then we make dmi
//file and right click it and hit import as 32x32 then byond will automatically split it up into 32x32 chunks using a 0,0 to whatever
//coordinate system, so what this will do is take those 32x32 chunks and make sure they seam together the same as they were in the large
//icon with no extra effort from us, based on the x/y position
turf/proc/DecideTurfStateForSpecialIcons(width = 4, height = 4)
	set waitfor = 0
	set background = 1
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

turf/proc/UpdateAsphaltState()

turf/Other
	Buildable = 0
	canBuildOver = 0
	icon = null

	Blank
		
		opacity=1
		Buildable=0
		Health=1.#INF
		density=1
		auto_gen_eligible = 0

		Enter(mob/M)
			if(ismob(M))
				if(M.client)
					if(can_go_in_void) return 1
					if(admins_can_go_in_void && M.IsAdmin() && M.Flying) return 1
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
		name = "Space"
		Buildable=0
		canBuildOver = 1
		Health=1.#INF
		New()
			DecideTurfStateForSpecialIcons(16,16)
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
		
		Cross()
			return 1

mob/var/fallingDown = 0
mob/proc/zPlaneDown()
	if(!z) return
	if(!(istype(locate(x,y,z),/turf/sky))) return
	if(fallingDown) return
	fallingDown = 1
	var/newX = x, newY = y, newZ
	if(z == 25)
		if(y >= 251)
			switch(x)
				if(250) newX--
				if(251) newX++
				if(252 to 500) newY -= 249
		else if(x >= 250)
			fallingDown = 0
			return
	var/checkZs
	for(var/i = 1, i <= droppableZs.len, i ++)
		if(droppableZs[i] == src.z) checkZs = i
	if(!checkZs)
		fallingDown = 0
		return
	newZ = fallTo[checkZs]
	var/turf/T = locate(newX, newY, newZ)
	if(!CheckFairLanding(T)) T = GetFairLanding(T)
	if(!T) T = locate(newX, newY, newZ)
	SafeTeleport(T)
	fallingDown = 0
	return 1

mob/proc/zPlaneUp()
	if(!z) return
	if(!fly_obj) return
	if(input_disabled || KO) return
	if(z == 6) return
	var/newX = x, newY = y, newZ
	if(z == 14)
		if(y >= 251 && x >= 251) return
		if(y <= 251 && x >= 251) newY += 249
	var/drain = Fly_Drain() * 4
	if(Health < 70) drain *= 3
	if(Class!="Spirit Doll")
		if(Ki > drain) IncreaseKi(-drain)
		else return
	var/checkZs
	for(var/i = 1, i <= fallTo.len, i ++)
		if(fallTo[i] == src.z) checkZs = i
	if(!checkZs) return
	newZ = droppableZs[checkZs]
	Fly()
	var/turf/T = locate(newX, newY, newZ)
	if(!CheckFairLanding(T)) T = GetFairLanding(T)
	if(!T) T = locate(newX, newY, newZ)
	SafeTeleport(T)
	return 1

mob/proc/enterSpace()
	if(!z) return
	if(!fly_obj && !Flying) return
	if(!(z in droppableZs)) return
	var/obj/items/Spacesuit/s
	for(s in item_list) break
	if(!(s || Lungs || Regenerate)) return
	if(!fly_obj) return
	var/drain = Fly_Drain() * 2
	if(Class!="Spirit Doll")
		if(Ki > drain) IncreaseKi(-drain)
		else return
	GoToPlanetInSpace(src)

mob/proc/CheckFairLanding(turf/T)
	if(!T) return FALSE
	if(T.Builder && T.Builder != src) return FALSE
	if(T.density) return FALSE
	for(var/obj/Turfs/Door/D in T)
		if(D.Builder && D.Builder != src) return FALSE
	//return !(T.Builder && T.Builder != src) || !T.density || !istype(T, /obj/Turfs/Door)

mob/proc/GetFairLanding(turf/T)
	set background = TRUE
	var/turf/t
	for(var/turf/C in orange(T, 45))
		if(CheckFairLanding(C))
			t = C
			break
		sleep(world.tick_lag)
	if(!t || !CheckFairLanding(t))
		t = locate(rand(1,world.maxx),rand(1,world.maxy),T.z)
		while(!CheckFairLanding(t))
			t = locate(rand(1,world.maxx),rand(1,world.maxy),T.z)
			sleep(world.tick_lag)
	return t

var/list
	droppableZs = list(\
					5, 20, 21, 22, 23, 24, 25)
	fallTo = list(\
					6, 1, 3, 4, 8, 12, 14)

proc/get_space_state()
	if(prob(90)) return "blackness"
	else return pick("star1","star2","star3")
var/turf/prison_exit

turf/Teleporter
	Buildable=0
	
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

turf/proc/Water_Ripple(mob/P)
	set waitfor=0
	var/image/I=image(icon='KiWater.dmi')
	if(P.dir in list(NORTH,SOUTH)) I.icon_state="NS"
	if(P.dir in list(EAST,WEST)) I.icon_state="EW"
	overlays+=I
	spawn(20) overlays-=I

turf/proc/Water_Enter(mob/P)
	return 1

turf/proc/Water_Exit(mob/P)
	//for(var/A in P.overlays) if(A:icon) if(A:icon=='Water Overlay.dmi') P.overlays-=A
	return 1

var/swim_drain=5
mob/var/swim_mastery=0
mob/var/is_swimming
mob/proc/SwimDrain()
	return (max_stamina / swim_drain) * (1 - swim_mastery / 100) * 0.2

obj/Surf
	icon = null
	mapObject = 1
	layer=2
	Givable=0
	Makeable=0
	Savable=0
	Knockable=0
	Spawn_Timer=180000
	Grabbable=0
	
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
				sleep(2)





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
		revival_altars ||= list()
		revival_altars |= src
		GiveLightSource(size = 3, max_alpha = 30)

	Click() if(usr in view(1,src))
		usr.Revival_altar()

mob/proc/revive_modifier()
	var/n = (highest_bp_ever_had / (bp_mod ? bp_mod : 1) / (highest_base_and_hbtc_bp ? highest_base_and_hbtc_bp : 1))
	n=n**1.3
	if(n<0.01) n=0.01
	return n

mob/proc/revive_time()
	if(Limits.GetSettingValue("Revive Delay") == 0) return 0
	var/n = death_time + (Limits.GetSettingValue("Revive Delay") * revive_modifier())
	if(Race == "Android") n = death_time + Limits.GetSettingValue("Revive Delay")
	return n

mob/proc/Revival_altar()
	if(!Limits.GetSettingValue("Revive Delay"))
		src<<"Automatic revives are off on this server"
		return

	if(!Dead)
		src<<"You are not dead. But if you die, click this to see if you are eligible to come back to life"
		return

	if(world.realtime>=revive_time())
		Revive()
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
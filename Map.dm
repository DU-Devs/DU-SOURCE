turf/proc/Roof_Enter(mob/A)
	if(!FlyOverAble) if(ismob(A)&&A.Flying) for(var/obj/items/Door_Hacker/D in A) if(D.BP>=Health)
		view(src)<<"[A] hacks their way past the wall"
		return 1
	if(FlyOverAble||istype(A,/obj/Explosion)) return 1
turf/var/Pod_Enter=1
atom/movable/var
	tmp/turf/Spawn_Location
	Spawn_Timer=0
proc/Set_Spawn_Point(mob/P)
	if(P.Spawn_Timer) P.Spawn_Location=P.loc
proc/Respawn_NPC(mob/P)
	if(P.Spawn_Timer&&P.Spawn_Location&&!P.Builder)
		if(!istype(P,/mob/Enemy/Zombie)) Remake(P.type,P.Spawn_Location,P.Spawn_Timer)
	P.Spawn_Location=null
turf/Del()
	var/Type=type
	if(InitialType) Type=InitialType
	spawn if(src) InitialType=Type
	Builder=null
	Turfs-=src
	..()
proc/Remake(Type,turf/Location,Timer) spawn(Timer) if(!Location.Builder)
	for(var/obj/A in Location) return
	new Type(Location)
obj/Write()
	var/list/OldOverlays=new
	OldOverlays.Add(overlays)
	overlays-=overlays
	..()
	overlays.Add(OldOverlays)
obj/Turfs
	Savable=0
	layer=4
	Givable=0
	Knockable=0
	Makeable=0
	Spawn_Timer=180000
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
		Click() if(usr in range(1,src)) range(10,src)<<"<font color=#FFFF00>There is a knock at the door!"
		New()
			Close()
			for(var/obj/Turfs/Door/D in range(0,src)) if(D!=src) del(D)
			for(var/obj/Controls/A in view(1,src)) del(src)
			for(var/turf/Special/Teleporter/A in view(1,src)) del(src)
			//..()
		proc/Open()
			density=0
			opacity=0
			flick("Opening",src)
			icon_state="Open"
			spawn(50) Close()
		proc/Close()
			density=1
			opacity=1
			flick("Closing",src)
			icon_state="Closed"
	Sign
		icon='Sign.dmi'
		density=1
		Knockable=0
		Click() if(desc) usr<<desc
	Sign/Information_Panel
		icon='Lab.dmi'
		icon_state="Radar"
		Click() if(desc) usr<<desc
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
	Throne_8
		icon='Throne 2.dmi'
		icon_state="gold"
		New()
			var/image/A=image(icon='Throne 2.dmi',icon_state="gold top",pixel_y=32,layer=MOB_LAYER+1)
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
		icon='Trees.dmi'
		icon_state="Dead Tree1"
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
		New()
			var/image/A=image(icon='turfs.dmi',icon_state="flamepot1",pixel_y=32)
			overlays.Remove(A)
			overlays.Add(A)
			spawn if(src) Fire_Cook(300)
	RugLarge
		New()
			var/image/A=image(icon='Turfs 96.dmi',icon_state="spawnrug1",pixel_x=-16,pixel_y=16,layer=2)
			var/image/B=image(icon='Turfs 96.dmi',icon_state="spawnrug2",pixel_x=16,pixel_y=16,layer=2)
			var/image/C=image(icon='Turfs 96.dmi',icon_state="spawnrug3",pixel_x=-16,pixel_y=-16,layer=2)
			var/image/D=image(icon='Turfs 96.dmi',icon_state="spawnrug4",pixel_x=16,pixel_y=-16,layer=2)
			overlays.Remove(A,B,C,D)
			overlays.Add(A,B,C,D)
			//..()
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
			overlays.Remove(A,B)
			overlays.Add(A,B)
			del(src) //BYOND SAID THIS LOG MUST BE REMOVED OR THE GAME CANNOT BE LISTED
			//..()
	FancyCouch
		New()
			var/image/A=image(icon='Turf 52.dmi',icon_state="couch left",pixel_x=-16)
			var/image/B=image(icon='Turf 52.dmi',icon_state="couch right",pixel_x=16)
			overlays.Remove(A,B)
			overlays.Add(A,B)
			//..()
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
			overlays.Remove(A,B)
			overlays.Add(A,B)
			//..()
	FancyCouch
		New()
			var/image/A=image(icon='Turf 52.dmi',icon_state="couch left",pixel_x=-16)
			var/image/B=image(icon='Turf 52.dmi',icon_state="couch right",pixel_x=16)
			overlays.Remove(A,B)
			overlays.Add(A,B)
			//..()
	Stove
		icon='Turf 52.dmi'
		icon_state="stove"
		density=1
		New()
			spawn if(src) Fire_Cook(300)
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
			overlays.Remove(A)
			overlays.Add(A)
			//..()
	Bed
		icon='Turf 52.dmi'
		icon_state="bed top"
		New()
			var/image/A=image(icon='Turf 52.dmi',icon_state="bed",pixel_y=-32)
			overlays.Remove(A)
			overlays.Add(A)
			//..()
	Torch1
		icon='Turf2.dmi'
		icon_state="168"
		density=1
		New()
			spawn if(src) Fire_Cook(300)
	Torch2
		icon='Turf2.dmi'
		icon_state="169"
		density=1
		New()
			spawn if(src) Fire_Cook(300)
	Torch3
		icon='Turf 57.dmi'
		icon_state="83"
		density=1
		New()
			spawn if(src) Fire_Cook(300)
	Fire
		icon='Turf 57.dmi'
		icon_state="82"
		density=1
		New()
			spawn if(src) Fire_Cook(300)
	barrel
		icon='Turfs 2.dmi'
		icon_state="barrel"
		density=1
	Waterfall
		icon='waterfall.dmi'
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
			overlays.Add(A,B,C,D,E,F)
obj/Trees
	Savable=0
	Givable=0
	Makeable=0
	Knockable=0
	layer=4
	density=1
	Spawn_Timer=180000
	Dead_Tree_1
		New()
			var/image/A=image(icon='turfs66.dmi',icon_state="2",pixel_x=0,pixel_y=0,layer=layer)
			var/image/B=image(icon='turfs66.dmi',icon_state="3",pixel_x=-32,pixel_y=32,layer=MOB_LAYER+1)
			var/image/C=image(icon='turfs66.dmi',icon_state="42",pixel_x=0,pixel_y=32,layer=MOB_LAYER+1)
			var/image/D=image(icon='turfs66.dmi',icon_state="31",pixel_x=32,pixel_y=32,layer=MOB_LAYER+1)
			overlays.Add(A,B,C,D)
	Dead_Tree_2
		New()
			var/image/A=image(icon='turfs66.dmi',icon_state="d1",pixel_x=0,pixel_y=0,layer=layer)
			var/image/B=image(icon='turfs66.dmi',icon_state="d2",pixel_x=-32,pixel_y=32,layer=MOB_LAYER+1)
			var/image/C=image(icon='turfs66.dmi',icon_state="d3",pixel_x=0,pixel_y=32,layer=MOB_LAYER+1)
			var/image/D=image(icon='turfs66.dmi',icon_state="d4",pixel_x=32,pixel_y=32,layer=MOB_LAYER+1)
			overlays.Add(A,B,C,D)
	Dark_Tree
		New()
			var/image/A=image(icon='turfs66.dmi',icon_state="treebotleft",pixel_x=-16,pixel_y=0,layer=layer)
			var/image/B=image(icon='turfs66.dmi',icon_state="treebotright",pixel_x=16,pixel_y=0,layer=layer)
			var/image/C=image(icon='turfs66.dmi',icon_state="treetopleft",pixel_x=-16,pixel_y=32,layer=MOB_LAYER+1)
			var/image/D=image(icon='turfs66.dmi',icon_state="treetopright",pixel_x=16,pixel_y=32,layer=MOB_LAYER+1)
			overlays.Add(A,B,C,D)
	Strange_Pine
		New()
			var/image/A=image(icon='turfs66.dmi',icon_state="treeleftbot1",pixel_x=-16,pixel_y=0,layer=layer)
			var/image/B=image(icon='turfs66.dmi',icon_state="treerightbot1",pixel_x=16,pixel_y=0,layer=layer)
			var/image/C=image(icon='turfs66.dmi',icon_state="treelefttop1",pixel_x=-16,pixel_y=32,layer=MOB_LAYER+1)
			var/image/D=image(icon='turfs66.dmi',icon_state="treerighttop1",pixel_x=16,pixel_y=32,layer=MOB_LAYER+1)
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
			var/image/A=image(icon='Turf 58.dmi',icon_state="1",pixel_y=0,pixel_x=-32,layer=50)
			var/image/B=image(icon='Turf 58.dmi',icon_state="0",pixel_y=-32,pixel_x=0,layer=50)
			var/image/C=image(icon='Turf 58.dmi',icon_state="3",pixel_y=32,pixel_x=-32,layer=50)
			var/image/D=image(icon='Turf 58.dmi',icon_state="4",pixel_y=32,pixel_x=0,layer=50)
			overlays.Remove(A,B,C,D)
			overlays.Add(A,B,C,D)
			new/obj/Trees/LargePine(loc)
			del(src)
			//..()
	RedTree
		density=1
		New()
			var/image/A=image(icon='Turf 55.dmi',icon_state="1",pixel_y=32,pixel_x=-32,layer=50)
			var/image/B=image(icon='Turf 55.dmi',icon_state="2",pixel_y=0,pixel_x=0,layer=50)
			var/image/C=image(icon='Turf 55.dmi',icon_state="3",pixel_y=32,pixel_x=32,layer=50)
			var/image/D=image(icon='Turf 55.dmi',icon_state="4",pixel_y=0,pixel_x=-32,layer=50)
			var/image/E=image(icon='Turf 55.dmi',icon_state="5",pixel_y=32,pixel_x=0,layer=50)
			var/image/F=image(icon='Turf 55.dmi',icon_state="6",pixel_y=0,pixel_x=32,layer=50)
			overlays.Remove(A,B,C,D,E,F)
			overlays.Add(A,B,C,D,E,F)
			//..()
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
			var/image/A=image(icon='Turf 52.dmi',icon_state="plant top",pixel_y=32,pixel_x=0,layer=50)
			overlays.Remove(A)
			overlays.Add(A)
			//..()
	Oak
		density=1
		New()
			var/image/A=image(icon='turfs.dmi',icon_state="1",pixel_y=0,pixel_x=-16,layer=50)
			var/image/B=image(icon='turfs.dmi',icon_state="2",pixel_y=0,pixel_x=16,layer=50)
			var/image/C=image(icon='turfs.dmi',icon_state="3",pixel_y=32,pixel_x=-16,layer=50)
			var/image/D=image(icon='turfs.dmi',icon_state="4",pixel_y=32,pixel_x=16,layer=50)
			var/image/E=image(icon='turfs.dmi',icon_state="5",pixel_y=64,pixel_x=-16,layer=50)
			var/image/F=image(icon='turfs.dmi',icon_state="6",pixel_y=64,pixel_x=16,layer=50)
			overlays.Remove(A,B,C,D,E,F)
			overlays.Add(A,B,C,D,E,F)
			//..()
	RoundTree
		density=1
		New()
			var/image/A=image(icon='turfs.dmi',icon_state="01",pixel_y=0,pixel_x=-16,layer=50)
			var/image/B=image(icon='turfs.dmi',icon_state="02",pixel_y=0,pixel_x=16,layer=50)
			var/image/C=image(icon='turfs.dmi',icon_state="03",pixel_y=32,pixel_x=-16,layer=50)
			var/image/D=image(icon='turfs.dmi',icon_state="04",pixel_y=32,pixel_x=16,layer=50)
			overlays.Remove(A,B,C,D)
			overlays.Add(A,B,C,D)
			//..()
	Tree
		density=1
		icon='turfs.dmi'
		icon_state="bottom"
		New()
			var/image/B=image(icon='turfs.dmi',icon_state="middle",pixel_y=32,pixel_x=0,layer=50)
			var/image/C=image(icon='turfs.dmi',icon_state="top",pixel_y=64,pixel_x=0,layer=50)
			overlays.Remove(B,C)
			overlays.Add(B,C)
			//..()
	Palm
		density=1
		New()
			var/image/A=image(icon='Trees2.dmi',icon_state="1",pixel_y=0,pixel_x=-16,layer=50)
			var/image/B=image(icon='Trees2.dmi',icon_state="2",pixel_y=0,pixel_x=16,layer=50)
			var/image/C=image(icon='Trees2.dmi',icon_state="3",pixel_y=32,pixel_x=-16,layer=50)
			var/image/D=image(icon='Trees2.dmi',icon_state="4",pixel_y=32,pixel_x=16,layer=50)
			var/image/E=image(icon='Trees2.dmi',icon_state="5",pixel_y=64,pixel_x=-16,layer=50)
			var/image/F=image(icon='Trees2.dmi',icon_state="6",pixel_y=64,pixel_x=16,layer=50)
			var/image/G=image(icon='Trees2.dmi',icon_state="7",pixel_y=96,pixel_x=-16,layer=50)
			var/image/H=image(icon='Trees2.dmi',icon_state="8",pixel_y=96,pixel_x=16,layer=50)
			overlays.Remove(A,B,C,D,E,F,G,H)
			overlays.Add(A,B,C,D,E,F,G,H)
			//..()
	LargePine
		density=1
		New()
			var/image/A=image(icon='Tree Good.dmi',icon_state="1",pixel_y=0,pixel_x=-16,layer=50)
			var/image/B=image(icon='Tree Good.dmi',icon_state="2",pixel_y=0,pixel_x=16,layer=50)
			var/image/C=image(icon='Tree Good.dmi',icon_state="3",pixel_y=32,pixel_x=-16,layer=50)
			var/image/D=image(icon='Tree Good.dmi',icon_state="4",pixel_y=32,pixel_x=16,layer=50)
			var/image/E=image(icon='Tree Good.dmi',icon_state="5",pixel_y=64,pixel_x=-16,layer=50)
			var/image/F=image(icon='Tree Good.dmi',icon_state="6",pixel_y=64,pixel_x=16,layer=50)
			overlays.Remove(A,B,C,D,E,F)
			overlays.Add(A,B,C,D,E,F)
			//..()
	LargePineSnow
		density=1
		New()
			var/image/A=image(icon='Tree GoodSnow.dmi',icon_state="1",pixel_y=0,pixel_x=-16,layer=50)
			var/image/B=image(icon='Tree GoodSnow.dmi',icon_state="2",pixel_y=0,pixel_x=16,layer=50)
			var/image/C=image(icon='Tree GoodSnow.dmi',icon_state="3",pixel_y=32,pixel_x=-16,layer=50)
			var/image/D=image(icon='Tree GoodSnow.dmi',icon_state="4",pixel_y=32,pixel_x=16,layer=50)
			var/image/E=image(icon='Tree GoodSnow.dmi',icon_state="5",pixel_y=64,pixel_x=-16,layer=50)
			var/image/F=image(icon='Tree GoodSnow.dmi',icon_state="6",pixel_y=64,pixel_x=16,layer=50)
			overlays.Remove(A,B,C,D,E,F)
			overlays.Add(A,B,C,D,E,F)
			//..()
	RedPine
		density=1
		New()
			var/image/A=image(icon='Tree Red.dmi',icon_state="1",pixel_y=0,pixel_x=-16,layer=50)
			var/image/B=image(icon='Tree Red.dmi',icon_state="2",pixel_y=0,pixel_x=16,layer=50)
			var/image/C=image(icon='Tree Red.dmi',icon_state="3",pixel_y=32,pixel_x=-16,layer=50)
			var/image/D=image(icon='Tree Red.dmi',icon_state="4",pixel_y=32,pixel_x=16,layer=50)
			var/image/E=image(icon='Tree Red.dmi',icon_state="5",pixel_y=64,pixel_x=-16,layer=50)
			var/image/F=image(icon='Tree Red.dmi',icon_state="6",pixel_y=64,pixel_x=16,layer=50)
			overlays.Remove(A,B,C,D,E,F)
			overlays.Add(A,B,C,D,E,F)
			//..()
	TallBush
		density=1
		icon='Turf3.dmi'
		icon_state="tallplantbottom"
		density=1
		New()
			var/image/A=image(icon='Turf3.dmi',icon_state="tallplanttop",pixel_y=32,layer=50)
			overlays.Remove(A)
			overlays.Add(A)
			//..()
	SluggoTree
		density=1
		New()
			overlays=null
			switch(pick(1,2,3,4))
				if(1)
					var/image/A=image(icon='turfs.dmi',icon_state="nt2",pixel_y=32,layer=50)
					var/image/B=image(icon='turfs.dmi',icon_state="nt1")
					overlays.Add(A,B)
				if(2)
					var/image/A=image(icon='Trees Namek.dmi',icon_state="1 Bottom")
					var/image/B=image(icon='Trees Namek.dmi',icon_state="1 Middle",pixel_y=32)
					var/image/C=image(icon='Trees Namek.dmi',icon_state="1 Top",pixel_y=64)
					overlays.Add(A,B,C)
				if(3)
					var/image/A=image(icon='Trees Namek.dmi',icon_state="2.0")
					var/image/B=image(icon='Trees Namek.dmi',icon_state="2.1",pixel_y=32)
					var/image/C=image(icon='Trees Namek.dmi',icon_state="2.2",pixel_y=64)
					var/image/D=image(icon='Trees Namek.dmi',icon_state="2.3",pixel_y=64,pixel_x=32)
					overlays.Add(A,B,C,D)
				if(4)
					var/image/A=image(icon='Trees Namek.dmi',icon_state="1")
					var/image/B=image(icon='Trees Namek.dmi',icon_state="2",pixel_y=32)
					var/image/C=image(icon='Trees Namek.dmi',icon_state="3",pixel_y=64)
					var/image/D=image(icon='Trees Namek.dmi',icon_state="4",pixel_y=32,pixel_x=32)
					var/image/E=image(icon='Trees Namek.dmi',icon_state="5",pixel_y=64,pixel_x=32)
					overlays.Add(A,B,C,D,E)
			//..()
obj/Edges
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
turf/Other
	New()
		if(type==/turf/Other) Buildable=0
		//..()
	Lava
		icon='turfs.dmi'
		icon_state="lava"
		Water=1
		Enter(mob/P) if(Water_Enter(P)) return ..()
		Exit(mob/P) if(Water_Exit(P)) return ..()
	Blank
		opacity=1
		Buildable=0
		Health=1.#INF
		density=1
		Enter(mob/M)
			if(ismob(M))
				if(M.client&&M.Is_Admin()) return ..()
				else return
			else if(!istype(M,/obj/Blast/Fireball)&&!istype(M,/obj/items/Lizard_Sphere)) del(M)
	MountainCave
		density=1
		icon='Turf1.dmi'
		icon_state="mtn cave"
		Buildable=0
	Stars
		icon='Misc.dmi'
		icon_state="Stars"
		Buildable=0
		Health=1.#INF
	Orb
		icon='Turf1.dmi'
		icon_state="spirit"
		density=0
		Buildable=0
	Ladder
		icon='Turf1.dmi'
		icon_state="ladder"
		density=0
		Buildable=0
	Sky1
		icon='Misc.dmi'
		icon_state="Sky"
		Buildable=0
		Enter(mob/M)
			if(ismob(M)) if(M.Flying||!M.density) return ..()
			else return ..()
	Sky2
		icon='Misc.dmi'
		icon_state="Clouds"
		Buildable=0
		Enter(mob/M)
			if(!Builder&&ismob(M)&&prob(20)&&(!M.Flying||M.density)) M.z=6
			return ..()
var/HBTC_Time=600 //600 seconds, 10 minutes.
mob/var/Total_HBTC_Time=0
proc/HBTC_Timer() while(1)
	if(HBTC_Time==round(HBTC_Time,60))
		if(HBTC_Time>0) zMsg(10,"The time chamber will lock in [round(HBTC_Time/60)] minutes")
		for(var/mob/P in Players) if(P.z==10)
			P.Total_HBTC_Time+=0.1
			P.Age+=0.1
			P.Age_Update()
			P.Gray_Hair()
			P<<"<font color=yellow>You have aged one month. Your age is now [round(P.Age,0.1)] years."
			if(P.Total_HBTC_Time>=2) P<<"<font color=yellow>You have gained all you can from training in here. Staying \
			any longer would be pointless. (You stayed 2 years)"
	if(HBTC_Time<=20&&HBTC_Time>0) zMsg(10,"The time chamber will lock in [HBTC_Time] seconds")
	if(!round(HBTC_Time))
		zMsg(10,"The time chamber has locked. The only way out now is if someone opens it from the outside.")
	HBTC_Time--
	sleep(10)
proc/zMsg(Z=1,T) if(T&&istext(T)) for(var/mob/P in Players) if(P.z==Z) P<<T
turf/Special
	Buildable=0
	Prison_Exit
		Health=1.#INF
		Enter(mob/M) if(ismob(M))
			if(!M.Prisoner()) M.loc=locate(250,267,16)
			else
				M<<"The prison will not allow you to leave until your sentence is up. You have \
				[M.Prison_Time_Remaining()] hours remaining. There is plenty that can be accomplished \
				within the prison."
				return ..()
	Teleporter
		density=1
		var/gotox
		var/gotoy
		var/gotoz
		Health=1.#INF
		Enter(mob/M) M.loc=locate(gotox,gotoy,gotoz)
		New()
			new/obj/Cave(src)
			..()
	EnterHBTC/Enter(mob/A)
		Health=1.#INF
		A.loc=locate(258,274,10)
		if(ismob(A)) HBTC_Time=600
	ExitHBTC
		Health=1.#INF
		Enter(mob/A) if(HBTC_Time>0) A.loc=locate(128,1,2)
turf
	Bridge1V
		icon='Turf 50.dmi'
		icon_state="1.8"
	Bridge1H
		icon='Turf 50.dmi'
		icon_state="3.3"
	Bridge2V
		icon='Turf 57.dmi'
		icon_state="26"
	Bridge2H
		icon='Turf 57.dmi'
		icon_state="123"
	Bridge1V
		icon='Turf 50.dmi'
		icon_state="1.8"
	Bridge1H
		icon='Turf 50.dmi'
		icon_state="3.3"
	Bridge2V
		icon='Turf 57.dmi'
		icon_state="26"
	Bridge2H
		icon='Turf 57.dmi'
		icon_state="123"
	GroundDirt
		icon='Turfs 14.dmi'
		icon_state="Dirt"
		Health=1.#INF
	GroundIce
		icon='Turf 57.dmi'
		icon_state="8"
	GroundIce2
		icon='Turf 55.dmi'
		icon_state="ice"
	GroundDirtSand
		icon='Turfs 96.dmi'
		icon_state="dirt"
	GroundSnow icon='Turf Snow.dmi'
	Ground4
		icon='Turfs 12.dmi'
		icon_state="desert"
	Ground10
		icon='Turf1.dmi'
		icon_state="light desert"
	Ground17
		icon='Turfs1.dmi'
		icon_state="dirt2"
	Ground18
		icon='turfs.dmi'
		icon_state="hellfloor"
	Ground19
		icon='Turfs 96.dmi'
		icon_state="darktile"
	GroundIce3
		icon='Turfs 12.dmi'
		icon_state="ice"
	GroundHell
		icon='Turf 57.dmi'
		icon_state="hellturf1"
	Ground16
		icon='FloorsLAWL.dmi'
		icon_state="Flagstone"
	Ground12
		icon='Turfs 1.dmi'
		icon_state="dirt"
	Ground13
		icon='Turfs 1.dmi'
		icon_state="rock"
		density=1
	Ground_Wasteland
		icon='wasteland ground.dmi'
	GroundPebbles
		icon='Turfs 7.dmi'
		icon_state="Sand"
	Ground11
		icon='Turfs 1.dmi'
		icon_state="crack"
		density=1
	GroundSandDark
		icon='Turf1.dmi'
		icon_state="dark desert"
		density=0
	Ground3
		icon='Turf1.dmi'
		icon_state="very dark desert"
		density=0
	Grass9
		icon='Turfs 96.dmi'
		icon_state="grass d"
	Grass13
		icon='Turf 57.dmi'
		icon_state="grass"
	Grass7
		icon='Turfs 1.dmi'
		icon_state="grass"
	Grass5
		icon='Turfs 14.dmi'
		icon_state="Grass"
	Grass11
		icon='Turfs 1.dmi'
		icon_state="Grass 50"
	Grass12
		icon='Turfs1.dmi'
		icon_state="grassremade"
	Grass1
		icon='Turfs 12.dmi'
		icon_state="grass2"
	Grass8
		icon='Turfs 96.dmi'
		icon_state="grass a"
	GrassSluggo
		icon='turfs.dmi'
		icon_state="ngrass"
	Grass2
		icon='Turfs 5.dmi'
		icon_state="grass"
	Grass3
		icon='Turfs 96.dmi'
		icon_state="grass b"
	Grass4
		icon='Turfs 96.dmi'
		icon_state="grass c"
	Grass10
		icon='turfs.dmi'
		icon_state="ngrass"
	Ground14
		icon='Turfs 2.dmi'
		icon_state="desert"
	Grass14
		icon='Turfs 96.dmi'
		icon_state="grass a"
	Grass10
		icon='Turfs 1.dmi'
		icon_state="Grass!"
	Wall21
		icon='Turfs Temple.dmi'
		icon_state="wall2"
		density=1
	Wall12
		icon='Turfs 3.dmi'
		icon_state="cliff"
		density=1
	Wall10
		icon='Turfs 4.dmi'
		icon_state="ice cliff"
		density=1
	Wall8
		icon='Turfs 15.dmi'
		icon_state="wall2"
		density=1
	Wall3
		icon='Turfs 4.dmi'
		icon_state="wall"
		density=1
	Wall17
		icon='Turf 57.dmi'
		icon_state="1"
		density=1
	Wall7
		icon='Turfs 1.dmi'
		icon_state="cliff"
		density=1
	Wall2
		icon='Turfs 1.dmi'
		icon_state="wall6"
		opacity=0
		density=1
	WallSand
		icon='Turf 50.dmi'
		icon_state="3.2"
		density=1
	WallStone
		icon='Turf 57.dmi'
		icon_state="stonewall2"
		density=1
	WallStone2
		icon='Turf 57.dmi'
		icon_state="stonewall4"
		density=1
	WallStone3
		icon='Turfs 96.dmi'
		icon_state="wall3"
		density=1
	WallTech
		icon='Space.dmi'
		icon_state="bottom"
		density=1
	Wall18
		icon='Turf 57.dmi'
		icon_state="2"
		density=1
	Wall19
		icon='Turf 57.dmi'
		icon_state="3"
		density=1
	Wall20
		icon='Turf 57.dmi'
		icon_state="6"
		density=1
	Wall21
		icon='metaltiles1.dmi'
		icon_state="metalwalla"
		density=1
	Wall22
		icon='metaltiles1.dmi'
		icon_state="metalwallb"
		density=1
	Wall23
		icon='Tiles 1.21.2011.dmi'
		icon_state="36"
		density=1
	Wall23
		icon='Tiles 1.21.2011.dmi'
		icon_state="33"
		density=1
	Wall13
		icon='turfs.dmi'
		icon_state="wall8"
		density=1
	Wall16
		icon='Turf 50.dmi'
		icon_state="2.6"
		density=1
	Wall11
		icon='Turfs 18.dmi'
		icon_state="stone"
		density=1
	Wall5
		icon='turfs.dmi'
		icon_state="tile1"
		density=1
	Wall6
		icon='Turfs 2.dmi'
		icon_state="brick2"
		density=1
	Wall15
		icon='Turf1.dmi'
		icon_state="1"
		density=1
	Wall1
		icon='turfs.dmi'
		icon_state="tile5"
		density=1
		opacity=0
	Wall_Hell
		icon='Hell turf.dmi'
		icon_state="h2"
		density=1
	Wall_Force
		icon='Force Wall.dmi'
		density=1
		Pod_Enter=0
	Roof4
		icon='metaltiles1.dmi'
		icon_state="metalroofa"
		density=1
		opacity=1
		Enter(atom/A) if(Roof_Enter(A)) return ..()
		Click() if(get_dist(usr,src)<=1)
			Make_Dense_All()
			Upgrade_All()
	Roof5
		icon='metaltiles1.dmi'
		icon_state="metalroofb"
		density=1
		opacity=1
		Enter(atom/A) if(Roof_Enter(A)) return ..()
		Click() if(get_dist(usr,src)<=1)
			Make_Dense_All()
			Upgrade_All()
	Roof6
		icon='metaltiles1.dmi'
		icon_state="metalroofc"
		density=1
		opacity=1
		Enter(atom/A) if(Roof_Enter(A)) return ..()
		Click() if(get_dist(usr,src)<=1)
			Make_Dense_All()
			Upgrade_All()
	Roof7
		icon='Tiles 1.21.2011.dmi'
		icon_state="Roof"
		density=1
		opacity=1
		Enter(atom/A) if(Roof_Enter(A)) return ..()
		Click() if(get_dist(usr,src)<=1)
			Make_Dense_All()
			Upgrade_All()
	Roof8
		icon='Tiles 1.21.2011.dmi'
		icon_state="Roof-5"
		density=1
		opacity=1
		Enter(atom/A) if(Roof_Enter(A)) return ..()
		Click() if(get_dist(usr,src)<=1)
			Make_Dense_All()
			Upgrade_All()
	Roof9
		icon='Tiles 1.21.2011.dmi'
		icon_state="Roof-1"
		density=1
		opacity=1
		Enter(atom/A) if(Roof_Enter(A)) return ..()
		Click() if(get_dist(usr,src)<=1)
			Make_Dense_All()
			Upgrade_All()
	Roof10
		icon='Tiles 1.21.2011.dmi'
		icon_state="Roof-2"
		density=1
		opacity=1
		Enter(atom/A) if(Roof_Enter(A)) return ..()
		Click() if(get_dist(usr,src)<=1)
			Make_Dense_All()
			Upgrade_All()
	RoofTech
		icon='Space.dmi'
		icon_state="top"
		density=1
		opacity=1
		Enter(atom/A) if(Roof_Enter(A)) return ..()
		Click() if(get_dist(usr,src)<=1)
			Make_Dense_All()
			Upgrade_All()
	Hell_Roof
		icon='Hell turf.dmi'
		density=1
		opacity=1
		Enter(atom/A) if(Roof_Enter(A)) return ..()
		Click() if(get_dist(usr,src)<=1)
			Make_Dense_All()
			Upgrade_All()
	Roof1
		icon='Turfs 96.dmi'
		icon_state="roof3"
		density=1
		opacity=1
		Enter(atom/A) if(Roof_Enter(A)) return ..()
		Click() if(get_dist(usr,src)<=1)
			Make_Dense_All()
			Upgrade_All()
	Roof2
		icon='Turfs.dmi'
		icon_state="roof2"
		density=1
		opacity=1
		Enter(atom/A) if(Roof_Enter(A)) return ..()
		Click() if(get_dist(usr,src)<=1)
			Make_Dense_All()
			Upgrade_All()
	Roof3
		icon='Turfs 96.dmi'
		icon_state="roof4"
		density=1
		opacity=1
		Enter(atom/A) if(Roof_Enter(A)) return ..()
		Click() if(get_dist(usr,src)<=1)
			Make_Dense_All()
			Upgrade_All()
	RoofWhite
		icon='turfs.dmi'
		icon_state="block_wall1"
		density=1
		opacity=1
		Enter(atom/A) if(Roof_Enter(A)) return ..()
		Click() if(get_dist(usr,src)<=1)
			Make_Dense_All()
			Upgrade_All()
	Tile38
		icon='metaltiles1.dmi'
		icon_state="metalfloora"
	Tile39
		icon='metaltiles1.dmi'
		icon_state="metalfloorsn"
	Tile40
		icon='metaltiles1.dmi'
		icon_state="gratingfloora"
	Tile41
		icon='metaltiles1.dmi'
		icon_state="gratingfloorb"
	Tile42
		icon='metaltiles1.dmi'
		icon_state="metalfloorb"
	Tile43
		icon='Tiles 1.21.2011.dmi'
		icon_state="a 1"
	Tile44
		icon='Tiles 1.21.2011.dmi'
		icon_state="1"
	Tile45
		icon='Tiles 1.21.2011.dmi'
		icon_state="dirt"
	Tile46
		icon='Tiles 1.21.2011.dmi'
		icon_state="3"
	Tile47
		icon='Tiles 1.21.2011.dmi'
		icon_state="5"
	Tile48
		icon='Tiles 1.21.2011.dmi'
		icon_state="8"
	Tile49
		icon='Tiles 1.21.2011.dmi'
		icon_state="9"
	Tile50
		icon='Tiles 1.21.2011.dmi'
		icon_state="10"
	Tile51
		icon='Tiles 1.21.2011.dmi'
		icon_state="18"
	Tile52
		icon='Tiles 1.21.2011.dmi'
		icon_state="19"
	Tile53
		icon='Tiles 1.21.2011.dmi'
		icon_state="desert"
	Tile54
		icon='Tiles 1.21.2011.dmi'
		icon_state="25"
	Tile55
		icon='Tiles 1.21.2011.dmi'
		icon_state="26"
	Tile56
		icon='Tiles 1.21.2011.dmi'
		icon_state="27"
	Tile56
		icon='Tiles 1.21.2011.dmi'
		icon_state="30"
	Tile57
		icon='Tiles 1.21.2011.dmi'
		icon_state="bb"
	Tile58
		icon='Tiles 1.21.2011.dmi'
		icon_state="metal floor-1"
	Tile59
		icon='Tiles 1.21.2011.dmi'
		icon_state="metal floor-2"
	Tile60
		icon='Tiles 1.21.2011.dmi'
		icon_state="39"
	Tile61
		icon='Tiles 1.21.2011.dmi'
		icon_state="40"
	Tile62
		icon='Tiles 1.21.2011.dmi'
		icon_state="37"
	TileWood
		icon='Turfs 96.dmi'
		icon_state="woodfloor"
	TileBlue
		icon='turfs.dmi'
		icon_state="tile11"
	Tile26
		icon='turfs.dmi'
		icon_state="tile9"
	Tile25
		icon='Turfs 4.dmi'
		icon_state="cooltiles"
	Tile21
		icon='Turfs 12.dmi'
		icon_state="Girly Carpet"
	Tile23
		icon='Turfs 12.dmi'
		icon_state="Wood_Floor"
	Tile17
		icon='turfs.dmi'
		icon_state="roof4"
	Tile15
		icon='Turfs 12.dmi'
		icon_state="stonefloor"
	Tile6
		icon='Turfs 12.dmi'
		icon_state="floor4"
	Tile14
		icon='turfs.dmi'
		icon_state="tile10"
	Tile22
		icon='FloorsLAWL.dmi'
		icon_state="SS Floor"
	TileStone
		icon='Turf 57.dmi'
		icon_state="55"
	Tile13
		icon='Turfs 1.dmi'
		icon_state="ground"
	TileWood
		icon='Turf 57.dmi'
		icon_state="woodfloor"
	Tile19
		icon='Turfs 12.dmi'
		icon_state="floor2"
	Tile20
		icon='turfs.dmi'
		icon_state="tile4"
	Tile2
		icon='FloorsLAWL.dmi'
		icon_state="Tile"
	Tile12
		icon='Turfs 15.dmi'
		icon_state="floor7"
	TileBlue2
		icon='turfs.dmi'
		icon_state="tile12"
	Tile13
		icon='Turfs 15.dmi'
		icon_state="floor6"
	Tile24
		icon='turfs.dmi'
		icon_state="bridgemid2"
	Tile10
		icon='FloorsLAWL.dmi'
		icon_state="Flagstone Vegeta"
	Tile11
		icon='Turfs 2.dmi'
		icon_state="dirt"
	Tile30
		icon='Turfs Temple.dmi'
		icon_state="floor"
	Tile31
		icon='Turfs Temple.dmi'
		icon_state="glassfloor"
	Tile32
		icon='Turfs Temple.dmi'
		icon_state="tile"
	Tile33
		icon='Turfs Temple.dmi'
		icon_state="tile2"
	Tile34
		icon='Turfs Temple.dmi'
		icon_state="tile3"
	Tile35
		icon='Turfs Temple.dmi'
		icon_state="tile4"
	Tile36
		icon='floor3.dmi'
	Tile37
		icon='woodfloor1.dmi'
	Tile_Hell1
		icon='Hell turf.dmi'
		icon_state="h1"
	Tile_Hell2
		icon='Hell turf.dmi'
		icon_state="h3"
	Tile_Hell3
		icon='Hell turf.dmi'
		icon_state="h4"
	Tile_Hell4
		icon='Hell turf.dmi'
		icon_state="h5"
	Tile_Hell5
		icon='Hell turf.dmi'
	Tile18
		icon='Turfs 12.dmi'
		icon_state="Aluminum Floor"
	Tile8
		icon='Turfs 1.dmi'
		icon_state="woodenground"
	Tile16
		icon='Turfs 14.dmi'
		icon_state="Stone"
	Tile27
		icon='turfs.dmi'
		icon_state="tile7"
	Tile28
		icon='turfs.dmi'
		icon_state="floor"
	TileGold
		icon='Turf 55.dmi'
		icon_state="goldfloor"
	Tile9
		icon='Turfs 18.dmi'
		icon_state="wooden"
	Tile8
		icon='Turfs 18.dmi'
		icon_state="diagwooden"
	Tile1
		icon='Turfs 12.dmi'
		icon_state="Brick_Floor"
	TileWhite icon='White.dmi'
	Tile2
		icon='Turfs 12.dmi'
		icon_state="Stone Crystal Path"
	Tile3
		icon='Turfs 12.dmi'
		icon_state="Stones"
	Tile4
		icon='Turfs 12.dmi'
		icon_state="Black Tile"
	Tile5
		icon='Turfs 12.dmi'
		icon_state="Dirty Brick"
	Stairs1
		icon='Turfs 96.dmi'
		icon_state="steps"
	StairsHell
		icon='Turf 57.dmi'
		icon_state="hellstairs"
	Stairs4
		icon='Turfs 1.dmi'
		icon_state="stairs1"
	Stairs5
		icon='Turfs 1.dmi'
		icon_state="earthstairs"
	Stairs3
		icon='Turfs 1.dmi'
		icon_state="stairs2"
	Stairs2
		icon='Turfs 12.dmi'
		icon_state="Steps"
	Stairs6
		icon='Turfs Temple.dmi'
		icon_state="council"
	Stairs7
		icon='Tiles 1.21.2011.dmi'
		icon_state="e"
	Water6
		icon='Turfs 1.dmi'
		icon_state="water"
		Water=1
		Enter(mob/P) if(Water_Enter(P)) return ..()
		Exit(mob/P) if(Water_Exit(P)) return ..()
	WaterReal
		icon='Turfs 96.dmi'
		icon_state="water1"
		Water=1
		Enter(mob/P) if(Water_Enter(P)) return ..()
		Exit(mob/P) if(Water_Exit(P)) return ..()
	Water5
		icon='Turfs 4.dmi'
		icon_state="kaiowater"
		Water=1
		Enter(mob/P) if(Water_Enter(P)) return ..()
		Exit(mob/P) if(Water_Exit(P)) return ..()
	WaterFall
		icon='Turfs 1.dmi'
		icon_state="waterfall"
		density=1
		layer=MOB_LAYER+1
		Water=1
		Enter(mob/P) if(Water_Enter(P)) return ..()
		Exit(mob/P) if(Water_Exit(P)) return ..()
	Water3
		icon='Misc.dmi'
		icon_state="Water"
		Water=1
		Enter(mob/P) if(Water_Enter(P)) return ..()
		Exit(mob/P) if(Water_Exit(P)) return ..()
	WaterFast
		icon='water.dmi'
		Water=1
		Enter(mob/P) if(Water_Enter(P)) return ..()
		Exit(mob/P) if(Water_Exit(P)) return ..()
	Water8
		icon='turfs.dmi'
		icon_state="nwater"
		Water=1
		Enter(mob/P) if(Water_Enter(P)) return ..()
		Exit(mob/P) if(Water_Exit(P)) return ..()
	Water1
		icon='Turfs 12.dmi'
		icon_state="water3"
		Water=1
		Enter(mob/P) if(Water_Enter(P)) return ..()
		Exit(mob/P) if(Water_Exit(P)) return ..()
	Water11
		icon='Turfs 12.dmi'
		icon_state="water1"
		Water=1
		Enter(mob/P) if(Water_Enter(P)) return ..()
		Exit(mob/P) if(Water_Exit(P)) return ..()
	Water7
		icon='turfs.dmi'
		icon_state="lava"
		density=0
		Enter(mob/P) if(Water_Enter(P)) return ..()
		Exit(mob/P) if(Water_Exit(P)) return ..()
	Water2
		icon='Turfs 96.dmi'
		icon_state="stillwater"
		Water=1
		Enter(mob/P) if(Water_Enter(P)) return ..()
		Exit(mob/P) if(Water_Exit(P)) return ..()
	Water12
		icon='Turfs 12.dmi'
		icon_state="water4"
		Water=1
		Enter(mob/P) if(Water_Enter(P)) return ..()
		Exit(mob/P) if(Water_Exit(P)) return ..()
	Water9
		icon='Turfs 12.dmi'
		icon_state="water1"
		Water=1
		Enter(mob/P) if(Water_Enter(P)) return ..()
		Exit(mob/P) if(Water_Exit(P)) return ..()
	Water10
		icon='Turf 50.dmi'
		icon_state="9.1"
		Water=1
		Enter(mob/P) if(Water_Enter(P)) return ..()
		Exit(mob/P) if(Water_Exit(P)) return ..()
	CaveEntrance
		icon='Turf 57.dmi'
		icon_state="13"
turf/proc/Water_Ripple(mob/P)
	return //TEMP DISABLED
	var/image/I=image(icon='KiWater.dmi')
	if(P.dir in list(NORTH,SOUTH)) I.icon_state="NS"
	if(P.dir in list(EAST,WEST)) I.icon_state="EW"
	overlays+=I
	spawn(20) overlays-=I
turf/proc/Water_Enter(mob/P)
	if(ismob(P))
		if(P.Flying||!P.density||P.KB)
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
mob/proc/Swim_Drain() return (Max_Ki/Swim_Drain)/Swim_Mastery
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
/*obj/Sacrificial_Altar
	desc="Click this to see what deals you can make with hell itself"
	Savable=0
	Health=1.#INF
	Dead_Zone_Immune=1
	Knockable=0
	Bolted=1
	Grabbable=0
	icon='Lab.dmi'
	icon_state="Strap2"
	overlays=newlist(/image{icon='Lab.dmi' icon_state="Strap1" pixel_x=-32},\
		/image{icon='Lab.dmi' icon_state="Strap3" pixel_x=32})
	Click() if(usr in view(1,src)) usr.Altar_Options()
mob/proc/Altar_Options()
	switch(input(src,"Using this altar you can make a deal with hell itself. The deals have drawbacks. \
	Upon death all deals are broken. Click a deal for details, it will then ask you if you accept.") in \
	list("Just walk away","Revive"))
		if("Revive")*/
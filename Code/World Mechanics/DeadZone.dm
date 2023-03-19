obj/Portal_Graphic
	icon='Dark Portal 100x100.dmi'
	Grabbable=0
	Health=1.#INF
	Savable=0
	density=1
	Bolted=1
	Dead_Zone_Immune=1
	layer = 6
	New()
		CenterIcon(src)
		GiveLightSource(size = 4, max_alpha = 40, light_color = rgb(200,100,255))

obj/Kaioshin_Portal
	icon='Dark Portal 100x100.dmi'
	name = "Watcher Portal"
	desc="This is a portal to the Watcher planet. After someone uses it it will disappear for some time, \
	but appear again later"
	Grabbable=0
	Health=1.#INF
	Savable=0
	density=1
	Dead_Zone_Immune=1
	Bolted=1

	proc/Become_inactive()
		return //no more of this
		var/i=icon
		icon=null
		density=0
		sleep(15*600)
		icon=i
		density=1

	New()
		CenterIcon(src)
		GiveLightSource(size = 4, max_alpha = 40)

obj/Final_Realm_Portal
	icon='Portal.dmi'
	icon_state="center"
	Grabbable=0
	Health=1.#INF
	Savable=0
	density=1
	Dead_Zone_Immune=1
	Bolted=1
	New()
		var/image/A=image(icon='Portal.dmi',icon_state="1",pixel_x=-32,pixel_y=-32)
		var/image/B=image(icon='Portal.dmi',icon_state="2",pixel_x=0,pixel_y=-32)
		var/image/C=image(icon='Portal.dmi',icon_state="3",pixel_x=32,pixel_y=-32)
		var/image/D=image(icon='Portal.dmi',icon_state="4",pixel_x=-32,pixel_y=0)
		var/image/E=image(icon='Portal.dmi',icon_state="5",pixel_x=0,pixel_y=0)
		var/image/F=image(icon='Portal.dmi',icon_state="6",pixel_x=32,pixel_y=0)
		var/image/G=image(icon='Portal.dmi',icon_state="7",pixel_x=-32,pixel_y=32)
		var/image/H=image(icon='Portal.dmi',icon_state="8",pixel_x=0,pixel_y=32)
		var/image/I=image(icon='Portal.dmi',icon_state="9",pixel_x=32,pixel_y=32)
		overlays=null
		overlays.Add(A,B,C,D,E,F,G,H,I)
		spawn Final_Realm_Portal()
		GiveLightSource(size = 4, max_alpha = 40)

	proc/Final_Realm_Portal() while(src)
		SafeTeleport(locate(rand(1,500),rand(1,500),15))
		sleep(300)

obj/DeadZone
	icon='Portal.dmi'
	icon_state="center"
	Grabbable=0
	Knockable=0
	Health=1.#INF
	Dead_Zone_Immune=1
	Bolted=1
	New()
		var/image/A=image(icon='Portal.dmi',icon_state="1",pixel_x=-32,pixel_y=-32)
		var/image/B=image(icon='Portal.dmi',icon_state="2",pixel_x=0,pixel_y=-32)
		var/image/C=image(icon='Portal.dmi',icon_state="3",pixel_x=32,pixel_y=-32)
		var/image/D=image(icon='Portal.dmi',icon_state="4",pixel_x=-32,pixel_y=0)
		var/image/E=image(icon='Portal.dmi',icon_state="5",pixel_x=0,pixel_y=0)
		var/image/F=image(icon='Portal.dmi',icon_state="6",pixel_x=32,pixel_y=0)
		var/image/G=image(icon='Portal.dmi',icon_state="7",pixel_x=-32,pixel_y=32)
		var/image/H=image(icon='Portal.dmi',icon_state="8",pixel_x=0,pixel_y=32)
		var/image/I=image(icon='Portal.dmi',icon_state="9",pixel_x=32,pixel_y=32)
		overlays=null
		overlays.Add(A,B,C,D,E,F,G,H,I)
		spawn(300) if(src) del(src)
		spawn Dead_Zone()
		GiveLightSource(size = 3, max_alpha = 40)
		//. = ..()

atom/movable/var/Dead_Zone_Immune
obj/proc/Dead_Zone() while(src)
	for(var/obj/A in view(12,src)) if(A!=src&&!A.Dead_Zone_Immune&&!A.Bolted)
		A.SafeTeleport(get_step_towards(A,src))
		if(A in range(0,src)) A.SafeTeleport(locate(224,497,6))
	for(var/mob/A in mob_view(20,src)) if(!A.Dead_Zone_Immune&&!A.Safezone&&!A.drone_module)
		A.Cease_training()
		step(A,get_dir(A,src))
		if(istype(A,/mob/Enemy)) spawn(2) if(A) step_away(A,src)
		if(A in loc)
			A.SafeTeleport(locate(224,497,6))
			//if(map_restriction_on) A.SafeTeleport(locate(250,230,16))
			if(round(Year)==round(Year,2)&&z==6) A.SafeTeleport(locate(60,370,1))
	sleep(5)
obj/MakeAmulet
	name = "Make DeadZone Amulet"
	teachable=1
	Skill=1
	hotbar_type="Ability"
	can_hotbar=1
	Teach_Timer=10
	student_point_cost = 60
	desc="You can make an amulet, that when used, will open a portal to the deadzone, sucking anything \
	nearby into it. Very, very dangerous."
	verb/Hotbar_use()
		set hidden=1
		Make_DeadZone_Amulet()
	verb/Make_DeadZone_Amulet()
		set category="Skills"
		new/obj/items/Amulet(usr)

var/amulet_cooldown=45 //seconds

obj/items/Amulet
	icon='DeadZone.dmi'
	clonable = 0
	desc="Opens a portal to the dead zone, sucking anything nearby in"
	Stealable=1
	Cost=200000
	var/tmp/using

	verb/Hotbar_use()
		set hidden=1
		Use()

	verb/Use() if(!using)
		if(world.time - usr.last_amulet_use < amulet_cooldown*10)
			usr<<"You can not use this for another [round(amulet_cooldown - (world.time - usr.last_amulet_use))] seconds"
			return
		if(usr.KO)
			usr<<"You can not use this while knocked out"
			return
		if(usr.Teleport_nulled())
			usr<<"A teleport nullifier is preventing the portal from opening"
			return
		if(usr.Final_Realm()||(locate(/area/Prison) in range(0,usr)))
			usr<<"You can not use this in this dimension"
			return
		if(usr.Safezone)
			usr<<"You can not use this in a safezone"
			return
		for(var/obj/Fighter_Spot/f in Fighter_Spots) if(f.z==usr.locz()&&getdist(f,usr)<=40)
			usr<<"You can not use this at the tournament"
			return
		var/turf/T=locate(usr.x,usr.y+5,usr.z)
		if(!T||T.density||!(usr in view(10,T))||(locate(/obj) in T))
			usr<<"This is not a valid spot to open the dead zone"
			return
		//using=1
		usr.last_amulet_use=world.time
		player_view(15,usr)<<"[usr] opens the amulet and a portal to the Dead zone appears!!"
		new/obj/DeadZone(T)
		//spawn(300) using=0

mob/var/tmp
	last_amulet_use=0 //world.time
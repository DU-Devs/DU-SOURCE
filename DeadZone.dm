obj/Final_Realm_Portal
	icon='Portal.dmi'
	icon_state="center"
	Grabbable=0
	Health=1.#INF
	Savable=0
	density=1
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
		overlays.Remove(A,B,C,D,E,F,G,H,I)
		overlays.Add(A,B,C,D,E,F,G,H,I)
		spawn Final_Realm_Portal()
	proc/Final_Realm_Portal() while(src)
		loc=locate(rand(1,500),rand(1,500),15)
		sleep(300)
obj/DeadZone
	icon='Portal.dmi'
	icon_state="center"
	Grabbable=0
	Knockable=0
	Health=1.#INF
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
		overlays.Remove(A,B,C,D,E,F,G,H,I)
		overlays.Add(A,B,C,D,E,F,G,H,I)
		spawn(300) if(src) del(src)
		spawn Dead_Zone()
		//..()
atom/movable/var/Dead_Zone_Immune
obj/proc/Dead_Zone() while(src)
	for(var/obj/A in view(12,src)) if(A!=src&&!A.Dead_Zone_Immune)
		A.loc=get_step_towards(A,src)
		if(A in range(0,src)) A.loc=locate(224,497,6)
	for(var/mob/A in view(12,src)) if(!A.Dead_Zone_Immune&&!A.Safezone)
		A.loc=get_step_towards(A,src)
		if(A in range(0,src))
			A.loc=locate(224,497,6)
			if(round(Year)==round(Year,5)&&z==6) A.loc=locate(60,370,1)
	sleep(5)
obj/MakeAmulet
	teachable=1
	Skill=1
	Teach_Timer=20
	desc="You can make an amulet, that when used, will open a portal to the deadzone, sucking anything \
	nearby into it. Very, very dangerous."
	verb/MakeAmulet()
		set category="Skills"
		var/obj/items/Amulet/A=new
		usr.contents+=A
obj/items/Amulet
	Cost=1000000000*10
	icon='DeadZone.dmi'
	desc="Opens a portal to the dead zone, sucking anything nearby in"
	Stealable=1
	var/tmp/using
	verb/Use() if(!using)
		if(usr.Final_Realm()||(locate(/area/Prison) in range(0,usr)))
			usr<<"You can not use this in this dimension"
			return
		if(usr.Safezone)
			usr<<"You can not use this in a safezone"
			return
		if(locate(/obj/Fighter_Spot) in range(40,usr))
			usr<<"You can not use this at the tournament"
			return
		var/turf/T=locate(usr.x,usr.y+5,usr.z)
		if(!T||T.density||!(usr in view(10,T))||(locate(/obj) in T))
			usr<<"This is not a valid spot to open the dead zone"
			return
		using=1
		view(1)<<"[usr] opens the amulet and a portal to the Dead zone appears!!"
		new/obj/DeadZone(T)
		spawn(300) using=0
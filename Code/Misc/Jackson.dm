obj/Mysterious_Portal
	Cost=0
	icon='Lab.dmi'
	icon_state="Warp"
	density=1
	var/tmp/Activated
	verb/Use()
		set src in oview(1)
		if(Activated||(locate(/obj/Michael_Jackson) in usr)) return
		Activated=1
		spawn(600) if(src) Activated=0
		player_view(15,src)<<"[usr] activates the mysterious portal"
		usr.move=0
		usr.dir=EAST
		usr.SafeTeleport(Get_step(src,WEST))
		usr.x-=2
		sleep(30)
		player_view(15,src)<<"<font color=#FFFF00>A mysterious being emerges from the portal, and bestows his \
		powers upon [usr]!"
		var/obj/Michael_Jackson/A=new(loc)
		sleep(10)
		step(A,WEST)
		sleep(10)
		step(A,WEST)
		sleep(30)
		step(A,EAST)
		sleep(10)
		step(A,EAST)
		sleep(10)
		del(A)
		player_view(15,src)<<"<font color=#FFFF00>Then as soon as he came, he leaves through the portal, the only \
		thing that was heard	as he left was OOOOOOOOOOOOOOOOOOOOOOh as he moonwalked back to his own \
		dimension"
		usr.move=1
		usr.Michael_Jackson_Dance()
obj/Michael_Jackson
	density=1
	icon='Michael Jackson.dmi'
mob/Admin3/verb/MJ(mob/A in players) A.Michael_Jackson_Dance()
mob/Admin3/verb/Mass_MJ() for(var/mob/A in players) spawn A.Michael_Jackson_Dance()
mob/Admin3/verb/MJ_Cure() for(var/mob/A in players) for(var/obj/Michael_Jackson/B in A) del(B)
mob/proc/Michael_Jackson_Dance()

	for(var/obj/Michael_Jackson/mj in src) del(mj)
	return

	spawn if(!MJ) MJ_Dance()
	if(!client)
		player_view(15,src)<<"The [src]'s head explodes from the awesomeness!!!"
		Body_Parts()
		del(src)
		return
	src<<'MJ.mid'
	if(!(locate(/obj/Michael_Jackson) in src))
		var/obj/Michael_Jackson/A=new(src)
		A.icon=icon
		A.overlays=overlays
	overlays-=overlays
	icon='Michael Jackson.dmi'
	icon_state="1"
	for(var/mob/B in view(src)) if(!(locate(/obj/Michael_Jackson) in B)) if(!B.MJ_Immune()) B.Michael_Jackson_Dance()
	spawn(160) if(src)
		icon_state=""
		UnKO()
		spawn(1) if(src) while(locate(/obj/Michael_Jackson) in src)
			for(var/mob/B in view(src)) if(!(locate(/obj/Michael_Jackson) in B)) if(!B.MJ_Immune()) B.Michael_Jackson_Dance()
			sleep(10)
		Dance_Effects()
mob/proc/MJ_Immune()
	if(Race=="Demon") return 1
	else if(locate(/obj/items/Holy_Pendant) in item_list) return 1
var/MJ
proc/MJ_Dance()

	return

	MJ=1
	var/Direction=pick(NORTH,SOUTH,EAST,WEST,NORTHWEST,NORTHEAST,SOUTHWEST,SOUTHEAST)
	while(1)
		if(prob(10)) Direction=pick(NORTH,SOUTH,EAST,WEST,NORTHWEST,NORTHEAST,SOUTHWEST,SOUTHEAST)
		for(var/mob/A in players) if((locate(/obj/Michael_Jackson) in A)&&A.icon_state!="1")
			if(A&&A.KO) spawn if(A) A.UnKO()
			step(A,Direction)
		for(var/obj/Skeleton/A) step(A,Direction)
		sleep(10)
obj/Michael_Jackson
	New()
		spawn(300) if(src) del(src)
		//. = ..()
	Del()
		var/mob/M=loc
		if(ismob(M))
			M.icon=icon
			if(overlays) M.overlays+=overlays
		. = ..()
mob/proc/Dance_Effects()
	while(locate(/obj/Michael_Jackson) in src)
		sleep(rand(50,100))
		if(src)
			var/A=pick(1,2,3,4)
			if(A==1) for(var/turf/B in view(12,src)) B.MJ_Stars()
			if(A==2)
				var/list/B=new
				for(var/turf/C in view(src)) if(!(locate(typesof(/mob)) in C)) B+=C
				new/obj/Skeleton(pick(B))
				new/obj/Skeleton(pick(B))
			if(A==3)
				var/list/B
				for(var/turf/C in view(12,src)) if(!(locate(typesof(/mob)) in C))
					if(!B) B=new/list
					B+=C
				if(B)
					new/obj/MJ/Asteroid(pick(B))
					new/obj/MJ/Meteor(pick(B))
			if(A==4) for(var/turf/C in view(8,src)) if(prob(50))
				Missile('Spirit.dmi',src,C)
				sleep(1)
turf/proc/MJ_Stars()
	var/image/A=image(icon='Misc.dmi',icon_state="Stars")
	overlays-=A
	overlays+=A
	spawn(1200) if(src) overlays-=A
obj/Skeleton
	density=1
	icon='Skeleton.dmi'
	Savable=0
	New()
		spawn(1200) if(src) del(src)
		//. = ..()
obj/MJ
	Givable=0
	density=1
	Savable=0
	Grabbable=0
	layer=5
	Spawn_Timer=0
	Bump(atom/A)
		. = ..()
		if(istype(A,/obj/Ships))
			var/obj/Ships/B=A
			B.Health-=5000
			if(B.Health<=0) del(B)
	Asteroid
		icon='Asteroid 5 11 2013.dmi'
		Health=25000
		New()
			CenterIcon(src)
			walk_rand(src,10)
			spawn(1200) if(src) del(src)
		Del()
			Explosion_Graphics(src,2,10)
			. = ..()
	Meteor
		icon='small asteroid.dmi'
		Health=5000
		New()
			CenterIcon(src)
			walk_rand(src,5)
			spawn(1200) if(src) del(src)
		Del()
			Explosion_Graphics(src,2,5)
			. = ..()
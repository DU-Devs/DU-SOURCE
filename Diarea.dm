mob/var/Diarea=0
mob/proc/Diarea(Contagious=1,Other_Chance=0,Invis=0) if(prob(Diarea+Other_Chance))
	if(!Invis)
		overlays-='Shitspray.dmi'
		overlays+='Shitspray.dmi'
		spawn(50) overlays-='Shitspray.dmi'
	for(var/mob/A in view(src)) if(A.see_invisible>=Invis)
		if(A.client)
			A<<sound(pick('Fart1.wav','Fart2.wav','Fart3.wav','Fart3.wav','Fart4.wav','Fart5.wav','Fart6.wav',\
			'Fart7.wav','Fart8.wav','Fart9.wav','Fart10.wav','Fart11.wav','Fart12.wav','Fart13.wav',\
			'Fart14.wav','Fart 15.wav','Fart 16.wav','Fart 17.wav','Fart 18.wav','Fart 19.wav'),volume=20)
		if(prob(50)&&Contagious&&src!=A&&A.Diarea<200) if(A.Race!="Demon") if(!(locate(/obj/items/Holy_Pendant) in A))
			A.Diarea+=5
			if(A.Diarea>200) A.Diarea=200
	var/Turds=rand(1,2)
	var/list/TurdSpots
	for(var/turf/B in view(5,src)) if(get_dir(src,B) in list(turn(dir,180),turn(dir,135),turn(dir,225)))
		if(!TurdSpots) TurdSpots=new/list
		TurdSpots+=B
	spawn while(Turds&&TurdSpots)
		var/obj/Turd/T=new
		T.invisibility=Invis
		T.loc=locate(x+rand(-1,1),y+rand(-1,1),z)
		step(T,get_step(src,turn(dir,180)))
		walk_towards(T,pick(TurdSpots))
		Turds-=1
		sleep(5)
	if(Diarea>200) Diarea=200
	if(prob(100)) Diarea-=1
obj/Turd
	icon='Shit.dmi'
	Savable=0
	Nukable=0
	New()
		spawn(5) if(src)
			pixel_x=rand(-16,16)
			pixel_y=rand(-16,16)
		spawn(rand(600,3000)) del(src)
mob/Admin3/verb/MassDiarea()
	var/Choice=input(src,"Choose the level of Diarea. (0-100)") as num
	for(var/mob/A in Players) A.Diarea=Choice
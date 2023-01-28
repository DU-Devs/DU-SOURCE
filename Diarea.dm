mob/var/Diarea=0
mob/var/last_shit_increase=0
mob/var/shit_virus_expire_time=0
mob/proc/Diarea(Contagious=1,Other_Chance=0,Invis=0) if(prob(Diarea+Other_Chance))
	if(world.realtime>shit_virus_expire_time)
		Diarea=0
		if(!Other_Chance) return
	if(!Invis)
		overlays-='Shitspray.dmi'
		overlays+='Shitspray.dmi'
		spawn(50) overlays-='Shitspray.dmi'
	for(var/mob/A in player_view(7,src)) if(A.see_invisible>=Invis)
		if(A.client)
			A<<sound(pick('Fart1.wav','Fart2.wav','Fart3.wav','Fart3.wav','Fart4.wav','Fart5.wav','Fart6.wav',\
			'Fart7.wav','Fart8.wav','Fart9.wav','Fart10.wav','Fart11.wav','Fart12.wav','Fart13.wav',\
			'Fart14.wav','Fart 15.wav','Fart 16.wav','Fart 17.wav','Fart 18.wav','Fart 19.wav'),volume=20)
		if(A!=src&&prob(50)&&Contagious&&src!=A&&A.Diarea<200) if(A.Race!="Demon") if(!(locate(/obj/items/Holy_Pendant) in A.item_list))
			A.Diarea+=100
			A.last_shit_increase=world.realtime
			if(A.shit_virus_expire_time<shit_virus_expire_time) A.shit_virus_expire_time=shit_virus_expire_time
			if(A.Diarea>300) A.Diarea=300
	var/Turds=rand(5,7)

	var/list/TurdSpots
	var/turf/t=Get_step(src,turn(dir,180))
	if(t)
		TurdSpots=new
		TurdSpots+=t
	for(var/v in 2 to 5)
		t=Get_step(t,turn(dir,180))
		if(t) TurdSpots+=t
		else break

	while(Turds&&TurdSpots)
		var/obj/Turd/T=new
		T.invisibility=Invis
		T.loc=locate(x+rand(-1,1),y+rand(-1,1),z)
		step(T,Get_step(src,turn(dir,180)))
		walk_towards(T,pick(TurdSpots))
		spawn(10) if(T)
			walk(T,0)
			T.dir=pick(NORTH,SOUTH,EAST,WEST)
			if(prob(0.1))
				var/mob/Enemy/Core_Demon/cd=new(T.loc)
				cd.name="Shitbeast"
				cd.icon='Shitbeast.dmi'
				cd.pixel_x=0
				cd.pixel_y=0
		Turds--
		sleep(5)
	if(Diarea>300) Diarea=300
	Shit_decrease_loop()
mob/var/tmp/shit_decrease_loop
mob/proc/Shit_decrease_loop() spawn if(src)
	if(shit_decrease_loop) return
	shit_decrease_loop=1
	while(Diarea)
		if(world.realtime>last_shit_increase+(2*60*10))
			Diarea-=5
			if(Diarea<0) Diarea=0
		sleep(10)
	shit_decrease_loop=0
obj/Turd
	icon='Shit.dmi'
	Savable=0
	Nukable=0
	New()
		icon=pick('poop1.dmi','poop2.dmi','poop3.dmi','poop4.dmi')
		Center_Icon(src)
		Timed_Delete(src,rand(600,1800))
mob/Admin3/verb/MassDiarea()
	var/Choice=input(src,"Choose the level of Diarea. (0-100)") as num
	for(var/mob/A in players)
		A.Diarea=Choice
		if(Choice>0)
			A.shit_virus_expire_time=world.realtime+(20*60*10)
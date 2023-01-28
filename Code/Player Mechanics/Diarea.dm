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
		if(A!=src && prob(10) && Contagious&&src!=A&&A.Diarea<200) if(A.Race!="Demon") if(!(locate(/obj/items/Holy_Pendant) in A.item_list))
			A.Diarea+=100
			A.last_shit_increase=world.realtime
			if(A.shit_virus_expire_time<shit_virus_expire_time) A.shit_virus_expire_time=shit_virus_expire_time
			if(A.Diarea>300) A.Diarea=300
	var/Turds=4

	while(Turds)
		var/obj/Turd/T=Get_new_turd()
		T.invisibility=Invis
		T.SafeTeleport(locate(x+rand(-1,1),y+rand(-1,1),z))
		T.Turd_walk(turn(dir,180))
		spawn(10) if(T)
			walk(T,0)
			T.dir=pick(NORTH,SOUTH,EAST,WEST)
			if(prob(0.01))
				var/mob/Enemy/Core_Demon/cd=new(T.loc)
				cd.name="Shitbeast"
				cd.icon='Shitbeast.dmi'
				cd.pixel_x=0
				cd.pixel_y=0
		Turds--
		sleep(TickMult(1.2))
	if(Diarea>300) Diarea=300
	Shit_decrease_loop()

obj/proc/Turd_walk(d)
	set waitfor=0
	var/start_dir=dir
	var/dist=rand(1, 14)
	for(var/v in 1 to dist)
		var/old_loc=loc
		step(src,pick(d,turn(d,45),turn(d,-45)))
		dir=start_dir
		if(loc==old_loc) break
		sleep(TickMult(1.5))

mob/var/tmp/shit_decrease_loop

mob/proc/Shit_decrease_loop()
	set waitfor=0
	if(shit_decrease_loop) return
	shit_decrease_loop=1
	while(Diarea)
		if(world.realtime>last_shit_increase+(2*60*10))
			Diarea-=10
			if(Diarea<0) Diarea=0
		sleep(50)
	shit_decrease_loop=0

var/list/turd_cache=new

proc/Get_new_turd()
	var/obj/Turd/t
	if(turd_cache.len)
		t=turd_cache[1]
		turd_cache-=t
		t.New()
	else
		t = new
	return t

obj/Turd
	Savable=0
	Nukable=0
	New()
		if(!icon)
			//icon=pick('Swarm of Flies.dmi','poop1.dmi','poop2.dmi','poop3.dmi','poop4.dmi')
			//icon = pick('poop2.dmi','poop3.dmi','poop4.dmi','horse poop.png')
			icon = 'horse poop.png'
			CenterIcon(src)
		transform = turn(transform, rand(1,360))
		if(icon == 'horse poop.png')
			color = rgb(rand(211,255), rand(160,200), rand(211,255)) //horse poop icon has too much green anyway
			HorsePoop()
		else
			transform *= rand(50,100) * 0.01
			color = rgb(rand(211,255), rand(211,255), rand(211,255))
		DeleteNoWait(rand(600,1200))
	Del()
		transform = null
		turd_cache-=src
		turd_cache+=src
		SafeTeleport(null)
	proc
		HorsePoop()
			set waitfor=0
			transform *= 0.33
			animate(src, transform = matrix(transform) * (rand(50,100) * 0.6 / 33), time = 4, easing = SINE_EASING)

mob/Admin3/verb/MassDiarea()
	var/Choice=input(src,"Choose the level of Diarea. (0-100)") as num
	for(var/mob/A in players)
		A.Diarea=Choice
		if(Choice>0)
			A.shit_virus_expire_time=world.realtime+(15*60*10)
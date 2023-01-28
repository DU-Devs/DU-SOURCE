//mob/proc/Hell_Tortures() if(!Hell_Immune())
	//spawn if(src) Hell_Diarea()
	//spawn if(src) Map_Confusion()
	//spawn if(src) Hell_Michael_Jackson()
	//spawn if(src) Scary_Effects()
obj/Make_Holy_Pendant
	teachable=1
	Skill=1
	hotbar_type="Ability"
	can_hotbar=1
	Teach_Timer=3
	student_point_cost = 10
	desc="This ability can make pendants that can protect people from the tortures of hell"
	var/Next_Use=0
	verb/Hotbar_use()
		set hidden=1
		Make_Holy_Pendant()
	verb/Make_Holy_Pendant()
		set category="Skills"
		if(Year>=Next_Use)
			usr.contents+=new/obj/items/Holy_Pendant
			Next_Use=Year+5
		else usr<<"You can only make one of these per 5 years"
obj/items/Holy_Pendant
	icon='Holy Pendant.dmi'
	desc="This pendant protects people from the tortures of hell"
	Stealable=1
	verb/Hotbar_use()
		set hidden=1
		return
mob/proc/Hell_Immune()
	if(locate(/obj/items/Holy_Pendant) in item_list) return 1
	else if(Race in list("Demon")) return 1
obj/Image
	layer=10
	Savable=0

mob/proc/Scary_Effects() while(1)
	if(z==6&&!Hell_Immune())
		if(client) switch(pick(2,3,4))
			if(1) Freddy_Kreuger_Image()
			if(2) src<<pick('Creepy Ambience.ogg','Creepy Ambience 2.ogg')
			if(3) src<<pick('Scary Girl.ogg','Wisp.ogg','Distant Monster Roar.ogg')
			if(4) Random_Scary_Image()
	sleep(rand(10,1200)*Hell_Torture)
mob/proc/Random_Scary_Image() if(client)
	src<<sound(pick('Hell Voice.ogg','Psycho Yelling.ogg','Pulse Explosion.ogg'))
	var/obj/Image/I=new
	I.icon=pick('Exorcist.jpg','Creepy Guy.jpg','Scary Clown.jpg','Scary Doll.jpg')
	client.screen+=I
	spawn(rand(30,50)) if(src&&client) del(I)
	while(I&&src&&client)
		if(I in client.screen) I.screen_loc="[rand(1,ViewX-5)],[rand(1,ViewY-5)]"
		sleep(1)
mob/proc/Freddy_Kreuger_Image()
	src<<sound(0)
	src<<sound('Ring Around The Rosey.ogg')
	sleep(rand(100,200))
	src<<sound('Psycho Yelling.ogg')
	sleep(10)
	var/obj/Image/I=new
	I.icon='Freddy Kreuger.jpg'
	I.screen_loc="1,1"
	client.screen+=I
	spawn(rand(30,50)) if(src&&client) del(I)
	while(I&&src&&client)
		if(I in client.screen) I.screen_loc="[rand(1,ViewX-5)],[rand(1,ViewY-5)]"
		sleep(1)
	src<<sound(0)

var/Hell_Torture=0

mob/Admin5/verb/Scare()
	set category="Admin"
	switch(input(src) in list("Freddy","Random"))
		if("Freddy") for(var/mob/P in players) spawn if(P&&P.client) P.Freddy_Kreuger_Image()
		if("Random") for(var/mob/P in players) spawn if(P&&P.client) P.Random_Scary_Image()

mob/Admin4/verb/Hell_Torture() Hell_Torture=input("[Hell_Torture]x") as num
mob/proc/Hell_Michael_Jackson() while(1)
	if(prob(2)) if(z==6&&!Hell_Immune()) Michael_Jackson_Dance()
	sleep(600)
mob/proc/Hell_Diarea() while(1)
	if(prob(2)) if(z==6&&!Hell_Immune()) Diarea+=200
	sleep(600)
mob/proc/Map_Confusion() while(1)
	if(prob(4)) if(z==6&&!Hell_Immune()) if(!(locate(/obj/Map_Confusion) in src)) contents+=new/obj/Map_Confusion
	sleep(600)
obj/Map_Confusion
	New() spawn if(src) for(var/mob/P in players) if(src in P) Map_Confusion(P)
	proc/Map_Confusion(mob/P) while(src&&P)
		if(P.z==6&&!P.Hell_Immune()) if(P.client) P.client.dir=pick(NORTH,SOUTH,EAST,WEST,NORTHEAST,NORTHWEST,SOUTHEAST,SOUTHWEST)
		else
			if(P.client) P.client.dir=NORTH
			del(src)
		sleep(600)
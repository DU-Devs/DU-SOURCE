mob/Admin3/verb/Undestroy_Planet()
	set category="Admin"
	var/Z=input(src,"Which Z? The planet on that z level will automatically restore itself. The process can \
	take a few minutes. Only do it once then wait.") as num
	Planet_Restore(Z)
turf/var/InitialType
var
	Earth=1
	Puran=1
	Braal=1
	Arconia=1
	Ice=1
	Desert=1
	Jungle=1
	Android=1
proc/Planet_Restore(Z) spawn if(1)
	if(Z==1) Earth=1
	if(Z==3) Puran=1
	if(Z==4) Braal=1
	if(Z==8) Arconia=1
	if(Z==12) Ice=1
	for(var/turf/A in block(locate(1,1,Z),locate(500,500,Z)))
		if(A.InitialType) new A.InitialType(A)
		if(prob(0.5)) sleep(1)
proc/Planet_Destroyed()
	if(!Earth) for(var/turf/A in block(locate(1,1,1),locate(500,500,1)))
		new/turf/Other/Stars(locate(A.x,A.y,A.z))
		if(prob(0.1)) sleep(1)
	if(!Puran) for(var/turf/A in block(locate(1,1,3),locate(500,500,3)))
		new/turf/Other/Stars(locate(A.x,A.y,A.z))
		if(prob(0.1)) sleep(1)
	if(!Braal) for(var/turf/A in block(locate(1,1,4),locate(500,500,4)))
		new/turf/Other/Stars(locate(A.x,A.y,A.z))
		if(prob(0.1)) sleep(1)
	if(!Arconia) for(var/turf/A in block(locate(1,1,8),locate(500,500,8)))
		new/turf/Other/Stars(locate(A.x,A.y,A.z))
		if(prob(0.1)) sleep(1)
	if(!Ice) for(var/turf/A in block(locate(1,1,12),locate(500,500,12)))
		new/turf/Other/Stars(locate(A.x,A.y,A.z))
		if(prob(0.1)) sleep(1)
	if(!Earth)
		for(var/obj/Edges/A) if(A.z==1) del(A)
		for(var/obj/Surf/A) if(A.z==1) del(A)
		for(var/obj/Trees/A) if(A.z==1) del(A)
		for(var/obj/Turfs/A) if(A.z==1) del(A)
	if(!Puran)
		for(var/obj/Edges/A) if(A.z==3) del(A)
		for(var/obj/Surf/A) if(A.z==3) del(A)
		for(var/obj/Trees/A) if(A.z==3) del(A)
		for(var/obj/Turfs/A) if(A.z==3) del(A)
	if(!Braal)
		for(var/obj/Edges/A) if(A.z==4) del(A)
		for(var/obj/Surf/A) if(A.z==4) del(A)
		for(var/obj/Trees/A) if(A.z==4) del(A)
		for(var/obj/Turfs/A) if(A.z==4) del(A)
	if(!Arconia)
		for(var/obj/Edges/A) if(A.z==8) del(A)
		for(var/obj/Surf/A) if(A.z==8) del(A)
		for(var/obj/Trees/A) if(A.z==8) del(A)
		for(var/obj/Turfs/A) if(A.z==8) del(A)
	if(!Ice)
		for(var/obj/Edges/A) if(A.z==12) del(A)
		for(var/obj/Surf/A) if(A.z==12) del(A)
		for(var/obj/Trees/A) if(A.z==12) del(A)
		for(var/obj/Turfs/A) if(A.z==12) del(A)
proc/Destroy_Planet(Z,BP=1)
	if(Z==1) Earth=0
	if(Z==3) Puran=0
	if(Z==4) Braal=0
	if(Z==8) Arconia=0
	if(Z==12) Ice=0
	var/Destroying=1
	for(var/mob/P in Players) if(P.z==Z) src<<"<font size=3><font color=red>The planet is breaking apart! \
	(Probably because someone used planet destroy, or a meteor hit it.)"
	spawn while(Destroying) //Shockwaves
		for(var/mob/P in Players) if(P.z==Z)
			var/list/L=new
			for(var/turf/T in view(15,P)) L+=T
			var/turf/T=pick(L)
			if(T&&isturf(T))
				view(10,T)<<'kiplosion.ogg'
				Make_Shockwave(T,rand(4,8))
		sleep(rand(0,80))
	spawn while(Destroying) //Screen shaking
		for(var/mob/A in Players) if(A.z==Z) spawn A.Screen_Shake(10,8)
		sleep(rand(0,100))
	spawn while(Destroying) //Rising rocks
		for(var/mob/P in Players) if(P.z==Z)
			var/list/L=new
			for(var/turf/T in view(15,P)) L+=T
			var/turf/T=pick(L)
			if(T&&isturf(T))
				var/image/I=image(icon='Weather.dmi',icon_state="Rising Rocks",pixel_x=rand(-32,32),pixel_y=rand(-32,32))
				T.overlays+=I
				spawn(rand(0,1200)) T.overlays-=I
		sleep(rand(0,8))
	spawn while(Destroying) //Lightning strikes
		for(var/mob/P in Players) if(P.z==Z)
			var/list/L=new
			for(var/turf/T in view(15,P)) L+=T
			var/turf/T=pick(L)
			if(T&&isturf(T))
				var/obj/Lightning_Strike/O=new
				O.loc=P.loc
				O.x+=rand(-15,15)
				O.y+=25
		sleep(rand(0,120))
	spawn while(Destroying) //Deadly Explosions
		spawn for(var/mob/P in Players) if(P.z==Z)
			var/list/L=new
			for(var/turf/T in view(10,P)) L+=T
			var/turf/T=pick(L)
			if(T&&isturf(T))
				Explosion_Graphics(T,2,rand(5,10))
				for(var/mob/M in view(2,T)) spawn if(M)
					var/KB=5*(BP/M.BP)
					if(KB<0) KB=0
					if(KB>10) KB=10
					KB=round(KB)
					M.Shockwave_Knockback(KB,M.loc)
					M.Health-=50*(BP/M.BP)
					if(M.Health<=0) M.Death("random explosion!")
				spawn if(T) for(var/turf/TT in view(3,T))
					TT.Health=0
					TT.Destroy()
					sleep(1)
			sleep(rand(0,200))
		sleep(rand(0,200))
	for(var/area/A) if(A.type!=/area&&A.type!=/area/Inside&&A.z==Z) A.icon_state="Smog"
	sleep(3000)
	Destroying=0
	for(var/turf/A in block(locate(1,1,Z),locate(500,500,Z))) if(A.type!=/turf/Other/Stars)
		new/turf/Other/Stars(locate(A.x,A.y,A.z))
		if(prob(0.2)) sleep(1)
	for(var/obj/Edges/A) if(A.z==Z) del(A)
	for(var/obj/Surf/A) if(A.z==Z) del(A)
	for(var/obj/Trees/A) if(A.z==Z) del(A)
	for(var/obj/Turfs/A) if(A.z==Z) del(A)
	for(var/mob/A) if(A.z==Z&&!A.client) del(A)
	//for(var/obj/A) if(A.z==Z) del(A)
	for(var/mob/A in Players) if(A.z==Z) Liftoff(A)
	for(var/obj/Planets/A) if(A.Planet_Z==Z)
		A.Spawn_Timer=100
		del(A)
obj/Lightning_Strike
	Savable=0
	New()
		var/image/A=image(icon='Lightning Strike.dmi',icon_state="Front",layer=99)
		var/image/B=image(icon='Lightning Strike.dmi',pixel_y=32,layer=99)
		var/image/C=image(icon='Lightning Strike.dmi',pixel_y=64,layer=99)
		var/image/D=image(icon='Lightning Strike.dmi',pixel_y=96,icon_state="End",layer=99)
		overlays.Add(A,B,C,D)
		walk(src,SOUTH)
		spawn(3000) if(src) del(src)
		//..()
obj/Planet_Destroy
	Skill=1
	desc="This will destroy an entire planet. Don't use it without a really good reason."
	verb/Planet_Destroy()
		set category="Skills"
		if(usr.z!=1&&usr.z!=3&&usr.z!=4&&usr.z!=8&&usr.z!=12)
			usr<<"This is not a planet's surface"
			return
		if(usr.z==1&&!Earth) return
		if(usr.z==3&&!Puran) return
		if(usr.z==4&&!Braal) return
		if(usr.z==8&&!Arconia) return
		if(usr.z==12&&!Ice) return
		switch(input("Destroy the planet?") in list("No","Yes"))
			if("Yes")
				view(10)<<sound('basicbeam_charge.ogg',volume=40)
				var/image/A=image(icon='14.dmi',pixel_y=32)
				usr.overlays+=A
				sleep(100)
				view(10)<<sound('basicbeam_fire.ogg',volume=20)
				usr.overlays-=A
				var/obj/Blast/B=new(locate(usr.x,usr.y,usr.z))
				B.icon='14.dmi'
				walk(B,SOUTH,5)
				spawn(25) if(B)
					walk(B,0)
					for(var/mob/C in range(10,B)) C<<sound('Explosion 2.wav')
					new/obj/BigCrater(locate(B.x,B.y,B.z))
					del(B)
					spawn Destroy_Planet(usr.z,usr.BP)
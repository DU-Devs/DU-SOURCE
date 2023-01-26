area/proc/Area_Nuke() if(icon!='Lightning flash.dmi')
	var/Old_State=icon_state
	icon='Lightning flash.dmi'
	icon_state=null
	spawn(600) if(src)
		icon='Weather.dmi'
		icon_state=Old_State

proc/Nuke_Icons(obj/F)
	switch(pick(1,2,3))
		if(1)
			F.icon='Explosion.dmi'
			F.icon_state=""
		if(2)
			F.icon='Explosion 2.dmi'
			F.icon_state=""
		if(3)
			F.icon='Smoke1.dmi'
			F.icon_state=""

turf/proc/Nuke(BP,Force,Range,Amount)
	set waitfor=0
	for(var/area/B in range(0,src)) if(B.type!=/area/Inside) B.Area_Nuke()
	spawn(1) while(Amount>0)
		spawn(rand(0,200)) view(10,src)<<pick('Blast.wav','kiplosion.ogg','wallhit.ogg','Explosion 2.wav')
		var/obj/Blast/Fireball/F=new(src)
		F.BP=BP
		F.Force=Force
		F.Offense=1.#INF
		F.Nuke_Walk()
		Amount-=1
		sleep(0.2)

obj/var/Nukable=1

obj/Blast/var/tmp/blast_caches = 1 //whether this blast is allowed to be cached when it deletes

obj/Blast/Fireball
	icon='Explosion.dmi'
	density=1
	Shockwave=1
	Deflectable=0
	Explosive=0
	Piercer=1
	layer=MOB_LAYER+50
	Owner="the nuclear explosion!"
	Distance=1000000
	blast_caches = 0

	var
		tmp
			init

	proc/Nuke_Walk()
		set waitfor=0
		while(src && z)
			step_rand(src)
			sleep(1)

	New()
		icon=pick('Explosion1.dmi','Explosion2.dmi','Explosion3.dmi','Explosion4.dmi')
		Timed_Delete(src, rand(5000,7000))
		pixel_x=rand(-64,64)
		pixel_y=rand(-64,64)
		Nuke_Attack_Mobs()
		Nuke_Attack_Objs()
		Nuke_Attack_Turf()
		init = 1

	proc/Nuke_Attack_Mobs()
		set waitfor=0
		while(src && z)
			//for(var/mob/P in Get_step(src,dir))
			for(var/mob/P in view(1,src))
				Bump(P)
				sleep(rand(0,20))
				break
			sleep(rand(1,2))

	proc/Nuke_Attack_Objs()
		set waitfor=0
		while(src && z)
			for(var/obj/A in Get_step(src,dir)) if(A.type!=type&&A.Nukable)
				var/Old_Damage=Damage
				Damage*=100
				Bump(A)
				if(src) Damage=Old_Damage
				sleep(rand(1,100))
				break
			sleep(rand(0,20))

	proc/Nuke_Attack_Turf()
		set waitfor=0
		while(src && z)
			for(var/turf/A in range(1,src))
				if(A.density)
					var/Old_Damage=Damage
					Damage*=3
					Bump(A)
					if(src) Damage=Old_Damage
				else if(prob(100)&&A.proxyTag != "{/build_proxy/turf}/turf/ground:(GroundSandDark)")
					A.Health=0
					A.Destroy()
			sleep(rand(0,40))

	Move()
		. = ..()

obj/var/makes_toxic_waste

proc/Combat_Status(mob/M) // true = In Combat, false = Not in Combat
	return (M.KO || M.logout_timer || world.time < M.cant_logout_until_time)
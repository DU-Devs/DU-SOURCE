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
turf/proc/Nuke(BP,Force,Range,Amount) spawn if(src)
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
	proc/Nuke_Walk()
		spawn while(src)
			step_rand(src)
			//if(prob(50)) step_rand(src)
			sleep(1)
	New()
		icon=pick('Explosion1.dmi','Explosion2.dmi','Explosion3.dmi','Explosion4.dmi')
		spawn(rand(5000,7000)) if(src) del(src)
		pixel_x=rand(-64,64)
		pixel_y=rand(-64,64)
		/*var/Amount=4
		while(Amount)
			var/image/A=image(icon='Explosion.dmi',pixel_x=rand(-64,64),pixel_y=rand(-64,64))
			Nuke_Icons(A)
			overlays+=A
			Amount-=1*/
		spawn if(src) Nuke_Attack_Mobs()
		spawn if(src) Nuke_Attack_Objs()
		spawn if(src) Nuke_Attack_Turf()
	proc/Nuke_Attack_Mobs() while(src)
		//for(var/mob/P in get_step(src,dir))
		for(var/mob/P in view(1,src))
			Bump(P)
			sleep(rand(0,20))
			break
		sleep(rand(1,2))
	proc/Nuke_Attack_Objs() while(src)
		for(var/obj/A in get_step(src,dir)) if(A.type!=type&&A.Nukable)
			var/Old_Damage=Damage
			Damage*=100
			Bump(A)
			if(src) Damage=Old_Damage
			sleep(rand(1,100))
			break
		sleep(rand(0,20))
	proc/Nuke_Attack_Turf() while(src)
		for(var/turf/A in range(1,src))
			if(A.density)
				var/Old_Damage=Damage
				Damage*=3
				Bump(A)
				if(src) Damage=Old_Damage
			else if(prob(100)&&!istype(A,/turf/GroundSandDark))
				A.Health=0
				A.Destroy()
		sleep(rand(0,40))
	Move()
		..()
mob/Admin3/verb/Bomb()
	set hidden=1
	var/obj/items/Nuke/A=new(loc)
	A.Amount=input(src,"Amount?") as num
obj/items/Nuke
	icon='Lab.dmi'
	icon_state="Panel1"
	density=1
	Stealable=1
	var/Force=1
	var/Range=40
	var/Amount=100
	Cost=1000000000
	New()
		spawn if(src) if(Bolted) Proximity_Detonation()
		//..()
	verb/Upgrade()
		set src in view(1)
		if(usr in view(1,src))
			var/Max_Upgrade=usr.Knowledge*2*sqrt(usr.Intelligence)
			var/Percent=(BP/Max_Upgrade)*100
			var/Res_Cost=1000/usr.Intelligence
			if(Percent>=100)
				usr<<"This is 100% upgraded at this time and cannot go any further."
				return
			var/Amount=input("This is upgraded to [Commas(BP)] BP. The current maximum is \
			[Commas(Max_Upgrade)] BP. \
			It is at [Percent]% maximum power. Each 1% upgrade cost [Commas(Res_Cost)]$. The maximum is 100%. Input \
			the percentage of power you wish to bring this to. ([Percent]-100%)") as num
			if(Amount>100) Amount=100
			if(Amount<0.1)
				usr<<"Amount must be higher than 0.1%"
				return
			if(Amount<=Percent)
				usr<<"The weapon cannot be downgraded."
				return
			Res_Cost*=Amount-Percent
			if(usr.Res()<Res_Cost)
				usr<<"You do not have enough resources to do this."
				return
			usr.Alter_Res(-Res_Cost)
			BP=Max_Upgrade*(Amount/100)
			Force=Avg_Force()
			view(usr)<<"[usr] upgraded [src] from [Percent]% to [Amount]% ([Commas(BP)] BP)"
			desc="[Commas(BP)] BP Bomb"
	proc/Detonate()
		if(type==/obj/items/Nuke)
			var/turf/A=loc
			if(A) A.Nuke(BP,Force,Range,Amount)
			del(src)
		else
			var/Amount=5
			while(Amount)
				Amount-=1
				Make_Shockwave(src,7)
				view(10,src)<<sound('wallhit.ogg',volume=40)
				for(var/mob/P in view(5,src))
					var/Damage=(Force/P.End)*sqrt(BP/P.BP)*25
					P.Health-=Damage
					if(P.KO) P.Death(src)
				sleep(5)
			del(src)
	verb/Set()
		set src in view(1)
		if(Bolted)
			usr<<"It is already armed, you cannot reprogram it"
			return
		view(src)<<"[usr] has begun to program the bomb."
		Password=input("Set the access code for remote detonation.") as text
	verb/Arm()
		set src in oview(1)
		if(Bolted)
			usr<<"It is already armed"
			return
		switch(input("Choose method. Only choose if you do not plan on remote detonation. Once \
		activated, it cannot be deactivated.") in list("Cancel","Timer","Proximity"))
			if("Timer") Timed_Detonation()
			if("Proximity") Proximity_Detonation()
	proc/Timed_Detonation()
		var/Timer=input("Set the timer, in seconds. (10 to 600)") as num
		Bolted=1
		if(Timer<10) Timer=10
		if(Timer>600) Timer=600
		Timer=round(Timer)
		while(Timer)
			if(round(Timer,10)==Timer) view(src)<<"[src]: Detonation in [Timer] seconds."
			Timer-=1
			sleep(10)
		view(src)<<"[src]: GOODBYE"
		if(src) Detonate()
	proc/Proximity_Detonation()
		view(src)<<"[src]: Proximity Detonation activation in 1 minute"
		Bolted=1
		sleep(600)
		while(src)
			for(var/mob/A in view(5,src)) if(A.client)
				view(src)<<"[src]: Proximity Breach. Detonating..."
				spawn(10) if(src) Detonate()
				return
			sleep(rand(0,60))
	proc/Remote_Detonation()
		Bolted=1
		Detonate()
obj/items/Nuke/Sonic_Bomb
	icon='Lab.dmi'
	icon_state="Panel1"
	density=1
	desc="This bomb only harms people, not objects. It can kill."
	Stealable=1
	Cost=5000000
	New()
		spawn if(src) if(Bolted) Proximity_Detonation()
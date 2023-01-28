/*
the damage var of projectiles needs removed
the BP and Force vars need replaced with:
blast_bp: the bp of the player unaltered
blast_force: the force of the player unaltered
damage_percent: the percent multiplier of the damage inherited from the move that was used
*/
obj/Blast/proc/Set_Stats(mob/P,Percent=1,Off_Mult=1,Explosion=0)
	Health=P.BP*(Percent**0.2)
	Fatal=P.Fatal
	Owner=P
	BP=P.BP
	percent_damage=Percent
	Force=Percent*P.Pow*Ki_Power
	Offense=P.Off*Off_Mult*2
	Explosive=Explosion
	if(ismob(P)) user_speed=P.Spd
	//world<<"BP: [BP]<br>Force: [Force]<br>Offense: [Offense]"
obj/var/Stun
obj/Blast
	var
		Is_Ki=1
		user_speed
	var/percent_damage=1
	var/Force=1
	var/Offense=1
	Fatal=1
	var/Damage //Some procs set Damage=BP*Force
	var/Explosive
	var/Shockwave
	var/Piercer
	var/Paralysis
	var/Beam
	var/Shrapnel
	var/Bounce
	var/Deflectable=1
	var/Size
	var/Spread //it will hit anything in get_step(90,-90)
	var/Noob_Attack //leaves no death message
	layer=6
	Savable=0
	density=1
	Grabbable=0
	var/Distance=30
	var/deflected //sets to 1 if deflected so that controlled moves arent controllable any more
	proc/Shrapnel() if(Shrapnel)
		var/turf/T=loc
		if(!isturf(T)) return
		var/N=5
		while(N)
			N--
			var/obj/Blast/A=new(T)
			A.Distance=20
			A.icon=icon
			A.Owner=T
			A.BP=BP/5
			A.Force=Force
			A.Offense=Offense
			A.Fatal=Fatal
			A.Bounce=Bounce
			walk(A,pick(NORTH,SOUTH,EAST,WEST,NORTHWEST,NORTHEAST,SOUTHWEST,SOUTHEAST))
	Move()
		if(icon_state=="origin")
			icon_state="tail"
			layer=initial(layer)-1
		if(density&&!Sokidan)
			Distance-=1
			if(Distance<=0)
				Explode()
				del(src)
		if(Size) for(var/atom/A in orange(Size,src)) if(A!=src&&A.density&&!isarea(A)) Bump(A)
		if(Spread)
			for(var/atom/A in get_step(src,turn(dir,90))) if(A!=src&&A.density&&!isarea(A)) Bump(A)
			for(var/atom/A in get_step(src,turn(dir,-90))) if(A!=src&&A.density&&!isarea(A)) Bump(A)
		if(src)
			if(!Blast_Homing()) ..()
	var/Can_Home=1
	proc/Blast_Homing() if(!Beam&&Can_Home&&prob(50)) //to alter the accuracy of blast homing change the probability
		for(var/mob/M in Players) if(M.z==z&&get_dir(src,M)==dir&&getdist(src,M)<=Distance) return
		for(var/mob/M in range(4,src)) if(Owner!=M) if(get_dir(src,M) in list(turn(dir,45),turn(dir,-45)))
			var/Old_Dir=dir
			Can_Home=0
			step(src,get_dir(src,M))
			Can_Home=1
			dir=Old_Dir
			return 1
	Del()
		if(Shrapnel) Shrapnel()
		..()
	New()
		spawn if(src) if(Get_Width(icon)>36||Get_Height(icon)>36) Center_Icon(src)
		if(type!=/obj/Blast/Genki_Dama)
			spawn(1) if(Owner&&ismob(Owner)&&Owner.icon_state!="Attack") if(Owner.client) flick("Attack",Owner)
			spawn(300) if(src) del(src)
		spawn Edge_Check()
		spawn if(ismob(Owner)&&Ki_Disabled&&Is_Ki)
			Owner.Ki_Disabled_Message()
			del(src)
	proc/Beam_Appearance()
		if(icon_state!="origin"&&icon_state!="struggle"&&Beam)
			if(!(locate(/obj/Blast) in get_step(src,dir)))
				icon_state="head"
				layer=initial(layer)+1
			else if(!(locate(/obj/Blast) in get_step(src,turn(dir,180)))) icon_state="end"
	proc/Shield(mob/A)
		for(var/obj/items/Force_Field/S in A) if(S.Level>0)
			var/Dmg=((BP*Force)/(A.Res))*(1/100) //1%
			S.Level-=Dmg
			S.Force_Field_Desc()
			if(S.Level<=0)
				view(src)<<"[A]'s force field is drained!"
				for(var/obj/items/Force_Field/F in A) del(F)
			A.Force_Field()
			return
		if(A.Cyber_Force_Field)
			var/Dmg=(BP*Force)/(A.BP*A.Res)
			A.Ki-=(Dmg/100)*A.Max_Ki
			if(A.Ki<=0) for(var/obj/Module/Force_Field/F in A)
				F.Disable_Module(A)
				A<<"Your cybernetic force field has been damaged. You must re-install it to make it active again."
			for(var/obj/Blast/B in get_step(src,turn(dir,180))) if(B.Beam) B.icon_state="struggle"
			A.Force_Field('Electro Shield.dmi')
			return
		for(var/obj/Shield/S in A) if(S.Using)
			var/Dmg=0.3*(A.Max_Ki/100/(Eff**0.3))*((BP*Force)/(A.BP*A.Res))
			A.Ki-=Dmg
			if(A.Ki<=0) A.Shield_Revert()
			for(var/obj/Blast/B in get_step(src,turn(dir,180))) if(B.Beam) B.icon_state="struggle"
			return
	proc/Beam() while(src)
		Damage=BP*Force
		if(!Owner) del(src)
		spawn Beam_Appearance()
		for(var/mob/A in range(0,src))
			A.last_attacked_time=world.realtime
			if(A.Absorb_Blast(src))
				del(src)
				return
			if(A.Shielding())
				Shield(A)
				del(src)
				return
			else
				var/mob/P=A
				if(prob(80)) for(var/mob/MM in range(0,A)) if(MM.Is_Grabbed()) P=MM
				P.Health-=(BP/P.BP)*((Force/P.Res)**0.7)
				if(ismob(Owner)&&!P.KO) P.set_opponent(Owner)
				for(var/mob/M in get_step(src,dir)) M.Health-=Damage/(1+(M.BP*M.Res))
				if(P==A&&!P.Safezone)
					step(P,dir)
					P.dir=turn(dir,180)
				if(P.Health<=0)
					if(Noob_Attack) P.KO()
					else P.KO(Owner)
				if(Paralysis)
					P<<"You become paralyzed"
					P.Frozen=1
				if((P.KO&&Owner.Fatal)||!P.client)
					if(P.Health<=0)
						//if(P.Regenerate) world<<"<font size=3><font color=#0099FF><br>\
						//Percent dead: [round(((Damage/Beam_Delay)/(P.BP*P.Res*P.Regenerate*40))*100,0.01)]%"
						if(P.Regenerate&&Damage/Beam_Delay>P.BP*P.Res*40*P.Regenerate)
							if(Noob_Attack) P.Death(null,1)
							else P.Death(Owner,1)
						else
							if(Noob_Attack) P.Death()
							else P.Death(Owner)
				if(!Piercer)
					for(var/obj/Blast/B in get_step(src,turn(dir,180))) B.icon_state="struggle"
					if(src) del(src)
			break
		for(var/obj/Blast/A in range(0,src))
			if(A.dir!=dir)
				icon_state="struggle"
				A.icon_state="struggle"
				layer=MOB_LAYER+3
				A.layer=MOB_LAYER+3
				if(!(locate(/obj/Blast) in get_step(src,turn(dir,180)))) del(src)
				for(var/obj/Blast/C in get_step(src,dir)) if(C.dir==dir)
					icon_state="tail"
					layer=MOB_LAYER+2
					break
				for(var/obj/Blast/C in get_step(src,turn(dir,180))) if(C.dir==dir&&C.icon_state=="struggle")
					C.icon_state="tail"
					C.layer=MOB_LAYER+2
				var/Sure_Win
				if(Damage/Beam_Delay*0.7>A.Damage/A.Beam_Delay) Sure_Win=1
				if(Sure_Win)
					walk(src,dir,30)
					for(var/obj/Blast/B in get_step(A,turn(A.dir,180))) if(B.dir==A.dir)
						B.icon_state="struggle"
						break
					del(A)
				else
					for(var/obj/Blast/B in get_step(src,turn(dir,180))) if(B.dir==dir)
						B.icon_state="struggle"
						break
					del(src)
				break
			else if(A.dir==dir&&A.icon_state=="struggle") if(A.Damage<Damage) del(A)
		for(var/turf/A in range(0,src)) if(A.density)
			if(A.Health<=BP)
				var/turf/B=A
				B.Health=0
				B.Destroy()
			if(A) if(!Piercer&&A.density)
				for(var/obj/Blast/B in get_step(src,turn(dir,180))) B.icon_state="struggle"
				del(src)
		for(var/obj/A in range(0,src)) if(!istype(A,/obj/Blast)&&!istype(A,/obj/Edges))
			if(!A.takes_gradual_damage)
				if(A.Health<=BP)
					new/obj/BigCrater(locate(A.x,A.y,A.z))
					del(A)
			else
				A.Health-=BP/5
				if(A.Health<=0)
					new/obj/BigCrater(A.loc)
					del(A)
			if(A) if(!Piercer&&A.density)
				for(var/obj/Blast/B in get_step(src,turn(dir,180))) B.icon_state="struggle"
				del(src)
			break
		sleep(1)
	proc/Explode() if(Explosive)
		Damage=BP*Force
		for(var/mob/A in view(Explosive,src))
			if(A.Shielding()) Shield(A)
			else
				A.Shockwave_Knockback(Explosive,loc)
				A.Health-=(BP/A.BP)*((Force/A.Res)**0.5)*0.5
				if(A.Health<=0)
					if(Noob_Attack) A.KO()
					else A.KO(Owner)
				if(Paralysis)
					A<<"You become paralyzed"
					A.Frozen=1
		for(var/obj/A in view(Explosive,src)) if(A!=src&&!istype(A,/obj/Blast)) if(A.Health<=BP)
			new/obj/BigCrater(locate(A.x,A.y,A.z))
			del(A)
		Explosion_Graphics(src,Explosive,(Explosive)*5)
		for(var/turf/A in view(Explosive,src)) if(A.Health<=BP)
			A.Health=0
			if(A.density) A.Destroy()
			else A.Make_Damaged_Ground(3)
	Bump(mob/A)
		Damage=BP*Force
		var/Original_Damage=Damage
		if(!Owner) del(src)
		else if(density&&A.type==type&&A.dir==dir)
			loc=A.loc
			for(var/mob/P in loc)
				Bump(P)
				break
		else if(ismob(A))
			A.last_attacked_time=world.realtime
			if(!Bullet&&A.Absorb_Blast(src))
				del(src)
				return
			if(A.Shielding())
				Shield(A)
				loc=A.loc
				view(10,src)<<sound('reflect.ogg',20)
				Size=0
				deflected=1
				walk(src,pick(NORTH,SOUTH,EAST,WEST,NORTHWEST,NORTHEAST,SOUTHWEST,SOUTHEAST))
				return

			//dmg is sqrt'd to balance itself with how dmg increases accuracy as well by sqrt. sqrt*sqrt=whole
			var/dmg=(BP/A.BP)
			if(Bullet) dmg*=(Force/A.End) //these were sqrt'd
			else dmg*=(Force/A.Res)

			if(Bullet&&!A.client) dmg*=100 //Guns do much more dmg against NPCs.
			if(A.Precognition) if(A.Flying||A.icon_state=="") if(A.Ki>A.Max_Ki*0.1)
				A.Ki*=0.95
				step(A,turn(dir,pick(-45,45)))
				return
			var/Hit_Chance=10*sqrt(percent_damage)*(Offense/A.Def)*sqrt(BP/A.BP)
			if(user_speed) Hit_Chance*=(user_speed/A.Spd)**0.3
			//world<<"Hit Chance: [Hit_Chance]%"
			if(dir==A.dir) Hit_Chance*=3
			if(prob(Hit_Chance)||!Deflectable||A.Disabled()||A.KO)
				if(dir==A.dir) Offense*=3
				A.Health-=dmg
				if(ismob(Owner)&&!A.KO) A.set_opponent(Owner)
				else if(A.Health<=0)
					if(Noob_Attack) A.KO()
					else A.KO(Owner)
					if(Fatal||!A.client)
						A.Health-=dmg
						if(A.Health<=0)
							//if(A.Regenerate) world<<"<font size=3><font color=#0099FF><br>\
							//Percent dead: [round((Original_Damage/(A.BP*A.Res*A.Regenerate*200))*100,0.01)]%"
							if(A.Regenerate&&!Bullet&&Original_Damage>A.BP*A.Res*A.Regenerate*200)
								if(Noob_Attack) A.Death(null,1)
								else A.Death(Owner,1)
							else
								if(Noob_Attack) A.Death()
								else A.Death(Owner)
				if(Paralysis)
					A<<"You become paralyzed"
					A.Frozen=1
				if(A&&src&&A.dir==dir&&A.KO&&A.Tail&&prob(10))
					view(A)<<"[A]'s tail is blasted off!"
					A.Tail_Remove()
				if(Shockwave&&A) A.Shockwave_Knockback(Shockwave,loc)
				if(Stun&&A) A.Stun_Projectile(Stun)
				Explode()
			else
				loc=A.loc
				Size=0
				deflected=1
				dir=pick(NORTH,SOUTH,EAST,WEST,NORTHEAST,NORTHWEST,SOUTHEAST,SOUTHWEST)
				if(A.client) flick("Attack",A)
				view(10,src)<<sound('reflect.ogg',volume=20)
				walk(src,dir)
				return
			if(!Piercer&&!Bounce) del(src)
			else
				Original_Damage/=2 //Damage is decreased each time it slices thru something
				Damage=Original_Damage
				loc=get_step(src,dir)
				if(Bounce) Bounce_Dir()
		if(isobj(A)&&A.takes_gradual_damage)
			Explode()
			A.Health-=BP/5
			if(A.Health<=0)
				new/obj/BigCrater(A.loc)
				del(A)
			if(Bounce) Bounce_Dir()
		else if(isobj(A)||isturf(A)) if(!istype(A,/obj/Blast))
			Explode()
			if(A)
				if(A.Health<=BP)
					if(isturf(A))
						var/turf/B=A
						B.Health=0
						B.Destroy()
						if(!Piercer&&!Bounce) del(src)
					else
						new/obj/BigCrater(locate(A.x,A.y,A.z))
						del(A)
				else if(src&&!Piercer&&!Bounce) del(src)
			if(Bounce) Bounce_Dir()
	proc/Bounce_Dir() walk(src,pick(turn(dir,135),turn(dir,-135),turn(dir,180)))
obj/proc/Edge_Check() while(src)
	if(!(locate(Owner) in range(12,src))) if(x==1||x==world.maxx||y==1||y==world.maxy) del(src)
	sleep(50)
obj/var/Knockable=1
obj/proc/Shockwave_Knockback(Amount,turf/A) spawn if(src&&Knockable) while(Amount)
	Amount-=1
	step_away(src,A,100)
	sleep(1)
mob/proc/Shockwave_Knockback(Amount,turf/A) spawn if(src)
	if(Safezone) return
	var/Dusts=0
	if(Amount>=7) Dusts=30
	//if(Amount>=15) view(10,src)<<'swoophit.ogg'
	GrabbedMob=null
	var/Old_State
	if(icon_state!="KB") Old_State=icon_state
	if(client) icon_state="KB"
	while(Amount)
		Amount-=1
		KB=1
		step_away(src,A,100)
		for(var/obj/Edges/E in range(0,src))
			Amount=0
			break
		sleep(1)
	KB=0
	if(Dusts)
		view(10,src)<<sound('wallhit.ogg',volume=40)
		Dust(src,Dusts)
	if((Old_State||Old_State=="")&&icon_state!="KO") icon_state=Old_State
mob/proc/Stun_Projectile(Amount)
	if(!Frozen)
		Frozen=1
		spawn(Amount*10) if(src&&Frozen) Frozen=0
obj/Explosion
	layer=MOB_LAYER+1
	Nukable=0
	Savable=0
	Makeable=0
	Givable=0
	density=0
	Health=1.#INF
	New()
		var/time=rand(100,200)
		var/image/i=image(layer=layer)
		for(var/v in 1 to 10)
			i.icon=pick('Smoke1.dmi','Explosion 2.dmi','Explosion2.dmi','Explosion.dmi')
			i.pixel_x=rand(-96,96)
			i.pixel_y=rand(-96,96)
			overlays+=i
			spawn(rand(time/4,time)) if(src) for(var/ov in overlays)
				overlays-=ov
				break
		spawn(time) if(src) del(src)
proc/Explosion_Count(list/L)
	var/Amount=0
	for(var/obj/Explosion/E in L) Amount+=1
	return Amount
proc/Explosion_Graphics(obj/O,Distance=0,Explosions=4,Timer=200)
	var/Count=Explosion_Count(range(5,O))
	if(Count>0) return
	var/Shock_Distance=Distance+3
	if(Shock_Distance) spawn if(O) Make_Shockwave(O,Shock_Distance)
	view(10,O)<<sound('kiplosion.ogg',volume=40)
	var/list/L
	for(var/turf/T in view(Distance,O))
		if(!L) L=new/list
		L+=T
	if(L)
		for(var/v in 1 to Explosions) //for(var/v in 1 to 10)
			var/obj/Explosion/E=new(pick(L))
			E.dir=pick(NORTH,SOUTH,EAST,WEST,NORTHWEST,NORTHEAST,SOUTHWEST,SOUTHEAST)
			spawn while(E)
				if(prob(95)) E.dir=turn(E.dir,90)
				step(E,E.dir)
				sleep(rand(3,4))
turf/proc/Make_Damaged_Ground(Amount=1) if(!Water)
	var/O=0
	for(var/A in overlays) O+=1
	if(O>=3) return
	while(Amount)
		Amount-=1
		var/image/I=image(icon='Damaged Ground.dmi',pixel_x=rand(-32,32),pixel_y=rand(-32,32),layer=MOB_LAYER-1)
		overlays+=I
		Remove_Damaged_Ground(I)
turf/proc/Remove_Damaged_Ground(image/I) spawn(rand(600,3000)) if(src) overlays-=I
mob/proc/Shielding()
	if(Cyber_Force_Field&&Ki>=Max_Ki*0.1) return 1
	for(var/obj/Shield/S in src) if(S.Using) return 1
	for(var/obj/items/Force_Field/S in src) if(S.Level>0) return 1
mob/proc/ki_shield_on() for(var/obj/Shield/s in src) if(s.Using) return 1
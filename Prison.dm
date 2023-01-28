var/Prison_Money=0 //the money the prison gets from the prisoners
mob/var/Imprisonments=0
obj/Prisoner_Mark
	var
		date_jailed=0 //realtime when their sentence began
		sentence=1 //hours
	New() Prisoner_Mark()
	proc/Prisoner_Mark() spawn while(src)
		var/mob/M=loc
		if(!ismob(M)) return
		if(!(locate(/area/Prison) in range(0,M)))
			M<<"The prison has teleported you back inside to finish your sentence"
			M.loc=locate(9,497,17)
		else if(M.Prison_Time_Remaining()<=0)
			alert(M,"Your prison sentence has ended, you are free to go at any time thru the exit")
			del(src)
		sleep(300)
mob/proc
	Prison_Time_Remaining()
		var/obj/Prisoner_Mark/PM
		for(PM in src) break
		if(!PM) return 0
		var/n=(PM.date_jailed+(PM.sentence*60*60*10))-world.realtime
		n/=60*60*10 //convert it back to hours
		n=round(n,0.01)
		return n
	Prisoner() for(var/obj/Prisoner_Mark/PM in src) return 1
	Imprison() if(!Prisoner())
		Update_Bounties()
		//Drop_Rsc(Res())
		Prison_Money+=Res()
		Alter_Res(-Res())
		oview(10,src)<<"[src] has been teleported to Interdimensional Space Prison because someone has placed \
		a bounty on them for their past crimes."
		Imprisonments++
		loc=locate(9,497,17)
		var/obj/Prisoner_Mark/PM=new(src)
		PM.date_jailed=world.realtime
		PM.sentence=Imprisonments*(1/3) //20 minutes per offense
		if(PM.sentence>3) PM.sentence=3
		alert(src,"You have been sentenced to [Prison_Time_Remaining()] hours in Interdimensional Space \
		Prison because someone had placed a bounty on you for your crimes in the outside world. When your \
		sentence is up you can leave thru the exit.")
proc/Send_Bounty_Drone() spawn while(1)
	spawn for(var/mob/M in Players) if(M.Has_Bounty()&&!M.Has_Bounty_Drone())
		Deploy_Drone(M)
		sleep(rand(0,20))
	sleep(6000)
mob/proc/Has_Bounty_Drone() for(var/mob/M in Bounty_Drones) if(M.Target==src) return M
proc/Deploy_Drone(mob/M,mob/Redeploy)
	var/list/Ts=new
	for(var/turf/T in range(10,M)) if(!T.Builder&&!T.density) Ts+=T
	if(!Ts.len) return
	var/turf/T=pick(Ts)
	var/obj/Effect/E=new(T)
	E.icon='Black Hole.dmi'
	flick("full",E)
	E.timeout=60
	sleep(30)
	var/mob/Bounty_Drone/BD
	if(Redeploy)
		BD=Redeploy
		BD.loc=T
	else BD=new(T)
	if(M) BD.Target=M
var/list/Bounty_Drones=new
mob/Bounty_Drone
	icon='Gochekbots.dmi'
	icon_state="5"
	New()
		Bounty_Drones+=src
		Bounty_Drone()
	Move()
		density=0
		..()
		density=1
	proc
		Bounty_Drone() spawn while(src)
			if(!Target) del(src)
			if(Target.z!=z||get_dist(src,Target)>=150) Deploy_Drone(Target,src)
			if(get_dist(src,Target)>4)
				var/old_loc=loc
				step_towards(src,Target)
				if(loc==old_loc)
					sleep(600)
					Deploy_Drone(Target,src)
				sleep(4)
			else
				dir=get_dir(src,Target)
				if(Target.KO) Bounty_Ray()
				sleep(40)
		Bounty_Ray()
			view(src)<<"[src]: Target is vulnerable. Firing prison ray."
			spawn while(src&&Target&&Target.z==z&&get_dist(Target,src)<20)
				missile('Prison Ray.dmi',src,Target)
				sleep(2)
			sleep(50)
			Target.Imprison()
			sleep(30)
			view(src)<<"[src]: Self destructing..."
			sleep(30)
			Explosion_Graphics(loc,1,6)
			del(src)
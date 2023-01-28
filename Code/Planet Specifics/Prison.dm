var/Prison_Money=0 //the money the prison gets from the prisoners
mob/var/Imprisonments=0
obj/Prisoner_Mark
	var
		date_jailed=0 //realtime when their sentence began
		sentence=1 //hours

	New() Prisoner_Mark()

	proc/Prisoner_Mark()
		set waitfor=0
		sleep(10)
		while(src)
			var/mob/M = loc
			if(!ismob(M)) return

			if(!ismob(M.loc) && (!(locate(/area/Prison) in range(0,M))))
				M<<"The prison has teleported you back inside to finish your sentence"

				var/turf/t = M.loc
				if(isturf(t)) M.SafeTeleport(locate(9,497,17))
				else
					var/obj/o = M.loc
					if(o) o.SafeTeleport(locate(9,497,17))

			else if(M.Prison_Time_Remaining()<=0)
				alert(M,"Your prison sentence has ended, you are free to go at any time thru the exit")
				del(src)
			sleep(100)
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
		Prison_Money += Res()
		SetRes(0)
		player_view(15,src)<<"[src] has been teleported to Interdimensional Space Prison because someone has placed \
		a bounty on them for their past crimes."
		Imprisonments++
		SafeTeleport(locate(9,497,17))
		var/obj/Prisoner_Mark/PM=new(src)
		PM.date_jailed=world.realtime
		//PM.sentence = 0.5 * (Imprisonments ** 0.25)
		//if(PM.sentence > 1) PM.sentence = 1
		PM.sentence = 1 //everyone just gets 1 hour now
		alert(src,"You have been sentenced to [Prison_Time_Remaining()] hours in Interdimensional Space \
		Prison because someone had placed a bounty on you for your crimes in the outside world. When your \
		sentence is up you can leave thru the exit.")

proc/Send_Bounty_Drone()
	set waitfor=0
	while(1)
		spawn for(var/mob/M in players) if(M.Has_Bounty() && !M.Has_Bounty_Drone())
			DeployDroneNoWait(M)
			sleep(rand(0,20))
		sleep(30 * 600)

mob/proc/Has_Bounty_Drone() for(var/mob/M in Bounty_Drones) if(M.Target == src) return M

proc/DeployDroneNoWait(mob/M,mob/Redeploy,turf/drone_loc,mob/deployer)
	set waitfor=0
	Deploy_Drone(M, Redeploy, drone_loc, deployer)

proc/Deploy_Drone(mob/M,mob/Redeploy,turf/drone_loc,mob/deployer)
	var/turf/T
	if(!drone_loc)
		var/list/Ts=new
		for(var/turf/T2 in range(10,M)) if(!T2.Builder&&!T2.density) Ts+=T2
		if(!Ts.len) return
		T=pick(Ts)
	else T=drone_loc
	var/obj/Effect/E = GetEffect()
	E.SafeTeleport(T)
	E.icon='Black Hole.dmi'
	flick("full",E)
	Timed_Delete(E,60)
	sleep(30)
	var/mob/Bounty_Drone/BD
	if(Redeploy)
		BD=Redeploy
		BD.SafeTeleport(T)
	else BD = new(T)
	if(M) BD.Target=M
	BD.deployer=deployer

var/list/Bounty_Drones=new

mob/Bounty_Drone
	icon='Gochekbots.dmi'
	icon_state="5"
	var/tmp/mob/deployer
	New()
		Bounty_Drones+=src
		Bounty_Drone()
	Move()
		density=0
		. = ..()
		density=1
	proc
		Bounty_Drone()
			set waitfor=0
			sleep(5)
			while(src)
				if(!Target) del(src)
				if(!Tournament||Target.z!=7||!(Target in All_Entrants))
					if(Target.z!=z||getdist(src,Target)>=150) Deploy_Drone(Target,src)
				if(getdist(src,Target)>13 || (Target && Target.KO && getdist(src,Target)>4))
					var/old_loc=loc
					step_towards(src,Target)
					if(loc==old_loc&&Target.z==z)
						sleep(200)
						Deploy_Drone(Target,src)
					sleep(TickMult(2.5))
				else
					dir=get_dir(src,Target)
					if(Target && Target.KO&&(Target in player_view(5,src))) Bounty_Ray()
					sleep(20)
		Bounty_Ray()
			player_view(15,src)<<"[src]: Target is vulnerable. Firing prison ray."
			spawn while(src&&Target&&Target.z==z&&getdist(Target,src)<20)
				Missile('Prison Ray.dmi',src,Target)
				sleep(2)
			sleep(50)
			if(Target)
				if(!deployer) deployer = src
				else
					for(var/b in Bounties) if(b != "Cancel")
						var/list/l = Bounties[b]
						var/Key = l["Key"]
						if(Key == Target.key) l["Claimant"] = deployer.key
						Bounties[b] = l
				for(var/obj/bc in bounty_computers)
					var/t="<font color=red>[bc]: The criminal known as [Target] has been captured on [Target.get_area()] by \
					[deployer]."
					if(deployer==src) t+=" This open bounty can be claimed by anyone."
					if(deployer.client) deployer.GiveFeat("Capture Bounty")
					player_view(bc,15) << t
				Target.Imprison()
			sleep(30)
			player_view(15,src)<<"[src]: Self destructing..."
			sleep(30)
			Explosion_Graphics(loc,1)
			del(src)
obj/Attacks/Buster_Barrage
	Drain=20
	Teach_Timer=2
	Cost_To_Learn=7
	Experience=1
	icon='Shield, Legendary.dmi'
	desc="An attack which shoots energy from all parts of your body in random directions."
	Explosive=1
	Shockwave=1
	var/tmp/Barraging
	verb/Buster_Barrage()
		set category="Skills"
		usr.Buster_Barrage(src)
mob/proc/Buster_Barrage(obj/Attacks/Buster_Barrage/B)
	if(!B) for(var/obj/Attacks/Buster_Barrage/C in src) B=C
	if(!B) return
	if(B.Barraging)
		B.Barraging=0
		return
	if(Can_Blast()) return
	if(attacking) return
	attacking=3
	var/Delay=1*Speed_Ratio()
	if(!client) Delay=1
	B.Experience+=0.05
	overlays+='Shield, Legendary.dmi'
	B.Barraging=1
	while(B.Barraging&&!Can_Blast()&&Ki>=Skill_Drain(B))
		view(10,src)<<sound('Blast.wav',volume=22)
		B.Skill_Increase(1,src)
		Ki-=Skill_Drain(B)
		var/obj/Blast/A=new
		A.Set_Stats(src,Percent=4,Off_Mult=1,Explosion=0)
		A.Distance=50
		A.icon=B.icon
		Center_Icon(A)
		spawn(2) if(A)
			A.pixel_x+=rand(-16,16)
			A.pixel_y+=rand(-16,16)
		A.Shockwave=3
		if(prob(10)) A.Explosive=2
		A.dir=pick(NORTH,SOUTH,EAST,WEST,NORTHEAST,NORTHWEST,SOUTHEAST,SOUTHWEST)
		A.loc=loc
		A.Buster_Barrage_Move()
		sleep(Delay)
	attacking=0
	B.Barraging=0
	overlays-='Shield, Legendary.dmi'
obj/proc/Buster_Barrage_Move() spawn if(src)
	step(src,dir)
	sleep(1)
	while(src)
		if(ismob(Owner)&&(Owner in view(2,src))) step_away(src,Owner)
		else
			step(src,dir)
			dir=pick(dir,turn(dir,45),turn(dir,-45))
		sleep(2)





obj/Attacks/Attack_Barrier
	Drain=10
	Teach_Timer=0.5
	Cost_To_Learn=5
	icon='1.dmi'
	desc="An offensive and defensive move that makes many balls of ki swarm around you and whatever enters the \
	barrier will be attacked by them. Press the command once to begin firing the balls, press it again when you \
	feel you have fired enough. The more you fire the more it will drain your energy."
	var/tmp/Firing_Attack_Barrier
	verb/Attack_Barrier()
		set category="Skills"
		usr.Attack_Barrier(src)
obj/Blast/Attack_Barrier
	density=0
	New()
		spawn Attack_Barrier_Loop()
		spawn(rand(0,1200)) if(src) del(src)
	proc/Attack_Barrier_Loop()
		var/mob/T
		while(src)
			if(!Owner)
				del(src)
				return
			if(!T||!(T in view(3,src))||!(Owner in view(6,src)))
				T=null
				for(var/mob/P in view(2,src)) if(P!=Owner)
					T=P
					break
			for(var/obj/Blast/B in view(3,src)) if(B.Owner!=Owner)
				T=B
				break
			if(!Owner) del(src)
			if(!deflected)
				if(T)
					step_towards(src,T)
					if(T in loc) Bump(T)
				else if(!(Owner in view(1,src))) if(Owner) step_towards(src,Owner)
				else step_rand(src)
			sleep(rand(1,2))
mob/proc/Attack_Barrier(obj/Attacks/Attack_Barrier/B)
	if(B.Firing_Attack_Barrier)
		B.Firing_Attack_Barrier=0
		src<<"You stop using Attack Barrier"
		return
	if(!B) for(var/obj/Attacks/Attack_Barrier/C in src) B=C
	if(!B) return
	if(Can_Blast()) return
	if(attacking||Ki<Skill_Drain(B)) return
	attacking=3
	B.Experience+=0.05
	//for(var/obj/Blast/Attack_Barrier/O) if(O.Owner==src) del(O)
	B.Firing_Attack_Barrier=1
	while(B.Firing_Attack_Barrier)
		if(Ki<Skill_Drain(B)) B.Firing_Attack_Barrier=0
		else if(Can_Blast()) B.Firing_Attack_Barrier=0
		else
			B.Skill_Increase(0.1,src)
			Ki-=Skill_Drain(B)
			flick("Blast",src)
			view(10,src)<<sound('Blast.wav',0,1,0,15)
			var/obj/Blast/Attack_Barrier/A=new
			A.Distance=99999999999
			A.pixel_x=rand(-16,16)
			A.pixel_y=rand(-16,16)
			A.icon=B.icon
			A.Set_Stats(src,Percent=1,Off_Mult=2,Explosion=0)
			A.Shockwave=1
			A.dir=dir
			A.loc=loc
			sleep(2*Speed_Ratio())
	attacking=0
atom/var/Fatal
mob/verb/Ki_Toggle()
	//set category="Other"
	Fatal=!Fatal
	if(Fatal) src<<"Your attacks are now lethal."
	else src<<"Your attacks are now non-lethal."
obj/var/Mastery=1
var/list/Blasts=new
proc/AddBlasts() for(var/A in typesof(/obj/Blasts)) if(A!=/obj/Blasts) Blasts+=new A
obj/Blasts
	icon_state="head"
	Givable=0
	Makeable=0
	Click()
		icon=initial(icon)
		var/Color=input("Choose a color. Hit Cancel to have default color.") as color|null
		if(!usr) return
		if(Color) icon+=Color
		var/list/C=new
		for(var/obj/Attacks/D in usr) if(D.type!=/obj/Attacks/Time_Freeze) C+=D
		var/obj/Attacks/A=input("Give this icon to which attack?") in C
		if(usr&&A) A.icon=image(icon=icon,icon_state=icon_state)
		icon=initial(icon)
	Blast1 icon='1.dmi'
	Blast2 icon='2.dmi'
	Blast3 icon='3.dmi'
	Blast4 icon='4.dmi'
	Blast5 icon='5.dmi'
	Blast6 icon='6.dmi'
	Blast7 icon='7.dmi'
	Blast8 icon='8.dmi'
	Blast9 icon='9.dmi'
	Blast10 icon='10.dmi'
	Blast11 icon='11.dmi'
	Blast12 icon='12.dmi'
	Blast13 icon='13.dmi'
	Blast14 icon='14.dmi'
	Blast15 icon='15.dmi'
	Blast16 icon='16.dmi'
	Blast17 icon='17.dmi'
	Blast18 icon='18.dmi'
	Blast19 icon='19.dmi'
	Blast20 icon='20.dmi'
	Blast21 icon='21.dmi'
	Blast22 icon='22.dmi'
	Blast23 icon='23.dmi'
	Blast24 icon='24.dmi'
	Blast25 icon='25.dmi'
	Blast26 icon='26.dmi'
	Blast27 icon='27.dmi'
	Blast28 icon='28.dmi'
	Blast29 icon='29.dmi'
	Blast30 icon='30.dmi'
	Blast31 icon='31.dmi'
	Blast32 icon='32.dmi'
	Blast33 icon='33.dmi'
	Blast34 icon='34.dmi'
	Blast35 icon='35.dmi'
	Blast36 icon='36.dmi'
	Blast37 icon='37.dmi'
	Blast38 icon='Blast - Destructo Disk.dmi'
	Blast39 icon='Blast - Dual Fire Blast.dmi'
	Blast40 icon='Blast - Ki Shuriken.dmi'
	Blast41 icon='holybolt.dmi'
	Blast42 icon='Blast - 0.dmi'
	Blast43 icon='Blast - 1.dmi'
	Blast44 icon='Blast - 2.dmi'
	Blast45 icon='Blast - 3.dmi'
	Blast46 icon='Blast - 4.dmi'
	Blast47 icon='Blast - 5.dmi'
	Blast48 icon='Blast - 6.dmi'
	Blast49 icon='Blast - 7.dmi'
	Blast50 icon='Blast - 8.dmi'
	Blast51 icon='Blast - 9.dmi'
	Blast52 icon='Blast - 10.dmi'
	Blast53 icon='Blast - 11.dmi'
	Blast54 icon='Blast - 12.dmi'
	Blast55 icon='Blast - 13.dmi'
	Blast56 icon='Blast - 14.dmi'
	Blast57 icon='Blast - 15.dmi'
	Blast58 icon='Blast - 16.dmi'
	Blast59 icon='Blast - 17.dmi'
	Blast60 icon='Blast - 18.dmi'
	Blast61 icon='Blast - 19.dmi'
	Blast62 icon='Blast - 20.dmi'
	Blast63 icon='Blast - 21.dmi'
	Blast64 icon='Blast - 22.dmi'
	Blast65 icon='Blast - 23.dmi'
	Blast66 icon='Blast - 24.dmi'
	Blast67 icon='Blast - 25.dmi'
	Blast68 icon='Blast - 26.dmi'
	Blast69 icon='Blast - 27.dmi'
	Blast70 icon='Blast - 28.dmi'
	Blast71 icon='Blast - 29.dmi'
	Blast72 icon='Blast - 30.dmi'
	Blast73 icon='Ball - Spirit Bomb.dmi'
	Blast74 icon='Ball - Supernova.dmi'
	Blast75 icon='Blast - Fire.dmi'
	Blast76 icon='Blast - Spiraling Ki.dmi'
	Blast77 icon='Blast - Super DD.dmi'
	Blast78 icon='Aura Blast Size 1.dmi'
	Blast79 icon='Electro Shield.dmi'
	Blast80 icon='Hadoken.dmi'
	Blast81 icon='38.dmi'
	Blast82 icon='Royal Death Crusher.dmi'
	Blast83 icon='39.dmi'
	Blast84 icon='BlastAqua.dmi'
	Blast85 icon='BlastFlame.dmi'
	Blast86 icon='BlastStar.dmi'
	Blast87 icon='Daitoppa.dmi'
	Blast88 icon='40.dmi'
	Blast89 icon='Trishot.dmi'
	Blast90 icon='Zankoukyokuha.dmi'
	Blast91 icon='BasenioBlast.dmi'
	Blast92 icon='Heart Blast.dmi'
	Blast93 icon='Dark Lance.dmi'
	Blast94 icon='Omega Blaster (Zee).dmi'
	Beam1 icon='Beam1.dmi'
	Beam2 icon='Beam2.dmi'
	Beam3 icon='Beam3.dmi'
	Beam4 icon='Beam4.dmi'
	Beam5 icon='Beam5.dmi'
	Beam6 icon='Beam6.dmi'
	Beam8 icon='Beam8.dmi'
	Beam9 icon='Beam9.dmi'
	Beam10 icon='Beam10.dmi'
	Beam11 icon='Beam11.dmi'
	Piercer_Icon icon='Makkankosappo.dmi'
	Beam12 icon='Beam12.dmi'
	Beam13 icon='Beam - Kamehameha.dmi'
	Beam14 icon='Beam - Static Beam.dmi'
	Beam15 icon='Beam - Multi-Beam.dmi'
	Beam16 icon='Beam - Masenko.dmi'
	Beam17 icon='BeamBlast Dragon.dmi'
	Beam18 icon='Beam - Beam1.dmi'
	Beam19 icon='Beam - Big Fire.dmi'
	Beam20 icon='Beam13.dmi'
	Beam21 icon='Beam14.dmi'
	Beam22 icon='BlackDragonBeam.dmi'
	Beam23 icon='Dragonbeam.dmi'
	Beam24 icon='Zento BBKHH 1.dmi'
	Beam25 icon='Zento BBKHH 2.dmi'
obj/Aura_Choices
	Savable=0
	Givable=0
	Makeable=0
	var/Scale
	Click()
		icon=initial(icon)
		if(Scale) icon=Scaled_Icon(icon,Scale,Scale)
		var/C=input("Choose a color. Hit cancel to have default color.") as color|null
		if(!usr||!usr.Auras) return
		if(C) icon+=C
		usr.Auras.SSj4=initial(usr.Auras.SSj4)
		if(C) usr.Auras.SSj4+=C
		usr.FlightAura='Aura Fly.dmi'
		if(C) usr.FlightAura+=C
		usr.Auras.icon=image(icon=icon,icon_state=icon_state)
	None
	Large
		icon='Aura, Big.dmi'
		Scale=74
		New() icon=Scaled_Icon(icon,Scale,Scale)
	Zen_Aura
		icon='Zen Aura.dmi'
		New() icon=Scaled_Icon(icon,83,121) //half size
	Sparks icon='AbsorbSparks.dmi'
	Electric icon='Aura, Bloo.dmi'
	Electric_2 icon='Aura Electric.dmi'
	Default icon='Aura.dmi'
	Flowing icon='Aura Normal.dmi'
	Demon_Flame icon='Black Demonflame.dmi'
	Vampire_Aura icon='Aura 2.dmi'
	Electric_3 icon='ElecAura3.dmi'
	Electric_4 icon='Elec Aura1.dmi'
obj/Charges
	Givable=0
	Makeable=0
	icon='BlastCharges.dmi'
	Click()
		icon=initial(icon)
		var/A=input("Choose a color. Hit cancel to have default color.") as color|null
		if(A) icon+=A
		usr.BlastCharge=image(icon=icon,icon_state=icon_state)
	Charge1 icon_state="1"
	Charge2 icon_state="2"
	Charge3 icon_state="3"
	Charge4 icon_state="4"
	Charge5 icon_state="5"
	Charge6 icon_state="6"
	Charge7 icon_state="7"
	Charge8 icon_state="8"
	Charge9 icon_state="9"
obj/Attacks/var
	Power=1 //Damage multiplier
	Explosive=0
	Shockwave=0
	Paralysis=0
	Scatter=0 //A barrage effect
atom/var
	Experience=0
	Add=1
	Level=1
	tmp/mob/Owner
	Password
	tmp/mob/Target
	Weight=1
	Health=10000
	Savable=1
	Builder
obj/Health=10000
obj/Attacks/Blast
	Drain=0.1
	Teach_Timer=0.2
	Cost_To_Learn=2
	Experience=1
	var/Spread=1
	var/Blast_Count=1
	var/blast_refire=0.3
	var/blast_velocity=1
	icon='1.dmi'
	desc="An attack that becomes more rapid as your skill with it develops"
	verb/Settings()
		set category="Other"
		switch(input("'Rapid blast' settings") in list("Cancel","Firing Mode","Knockback","Explosiveness",\
		"Amount of blasts","Refire"))
			if("Cancel") return
			if("Firing Mode")
				switch(alert("Firing Mode","Options","Normal","Spread","Barrage"))
					if("Normal") Spread=1
					if("Spread") Spread=2
					if("Barrage") Spread=3
			if("Knockback")
				switch(alert("Knockback?","Options","Yes","No"))
					if("Yes") Shockwave=1
					if("No") Shockwave=0
			if("Explosiveness")
				switch(alert("Explosive? Increases damage, damage range, and drain","Options","No","Yes"))
					if("No") Explosive=0
					if("Yes")
						if(blast_refire>0.2)
							alert("Blast refire must not be higher than 0.2x to have explosions enabled. It has been \
							set to 0.2x automaticly")
							blast_refire=0.2
						Explosive=1
			if("Amount of blasts")
				Blast_Count=input("Amount of blasts? 1 to 4. More blasts increases drain heavily") as num
				if(Blast_Count<1) Blast_Count=1
				if(Blast_Count>4) Blast_Count=4
				Blast_Count=round(Blast_Count)
			if("Refire")
				var/max=1
				if(Explosive) max=0.2
				blast_refire=input("Blast refire: 0.2 to [max]. The slower the more powerful. If you disable \
				exploding blasts you can set the refire higher") as num
				if(blast_refire>max) blast_refire=max
				if(blast_refire<0.2) blast_refire=0.2
		Drain=initial(Drain)
		if(Spread>1) Drain*=3
		if(Explosive) Drain*=2
		Drain*=Blast_Count**2
		Drain*=1/blast_refire
	verb/Blast()
		set category="Skills"
		usr.Blast_Fire(src)
mob/proc/Blast_Fire(obj/Attacks/Blast/B)
	if(!B) for(var/obj/Attacks/Blast/C in src) B=C
	if(!B) return
	if(Can_Blast()) return
	if(attacking||Ki<Skill_Drain(B)) return
	Ki-=Skill_Drain(B)
	B.Skill_Increase(1/B.blast_refire,src)
	attacking=3
	var/Delay=Delay((1/B.blast_refire)*Speed_Ratio())
	if(!client) Delay=1
	spawn(Delay) attacking=0
	B.Experience+=0.05/B.blast_refire
	if(prob(100)) view(10,src)<<sound('Blast.wav',0,1,0,15)
	var/Amount=B.Blast_Count
	while(Amount)
		var/obj/Blast/A=new
		A.Set_Stats(src,Percent=5/sqrt(B.blast_refire),Off_Mult=2/sqrt(B.blast_refire),Explosion=0)
		A.Distance=30
		A.icon=B.icon
		Center_Icon(A)
		spawn(2) if(A)
			A.pixel_x+=rand(-12,12)
			A.pixel_y+=rand(-12,12)
		A.Shockwave=B.Shockwave
		if(prob(100)) A.Explosive=B.Explosive
		A.dir=dir
		A.loc=loc
		walk(A,A.dir)
		var/Former_Dir=A.dir
		if(prob(67)&&B.Spread==2) spawn(rand(2,3)) if(A&&B)
			step(A,turn(A.dir,pick(-45,45)))
			spawn(2) if(A&&src) walk(A,Former_Dir)
		if(B.Spread==3)
			var/Spawn_Time=rand(0,12)
			spawn(Spawn_Time) if(A&&B) walk(A,turn(A.dir,pick(-45,45)))
		Amount-=1
mob/proc/Disabled()
	if(Action in list("Meditating","Training")) return 1
	if(KO||KB||Frozen) return 1
mob/proc/Can_Blast()
	if(Action in list("Meditating","Training")) return 1
	if(KO||KB||Frozen) return 1
	if((src in All_Entrants)&&!Is_Fighter()&&z==7)
		src<<"You can not attack until it is your turn to fight"
		return 1
obj/Attacks/Charge
	Drain=20
	Teach_Timer=0.1
	Cost_To_Learn=1
	Experience=1
	icon='20.dmi'
	desc="An explosive one-shot energy attack that takes a few seconds to charge. With training its \
	explosiveness and refire speed can increase."
	verb/Charge()
		set category="Skills"
		if(usr.Can_Blast()) return
		if(usr.attacking||usr.Ki<usr.Skill_Drain(src)) return
		if(prob(10)&&Experience<1) Experience+=0.1
		usr.Ki-=usr.Skill_Drain(src)
		Skill_Increase(2,usr)
		usr.attacking=3
		charging=1
		usr.overlays+=usr.BlastCharge
		view(10)<<sound('basicbeam_charge.ogg',volume=20)
		sleep(7.5*usr.Speed_Ratio())
		usr.overlays-=usr.BlastCharge
		if(!usr.Can_Blast())
			view(10)<<sound('Blast.wav',volume=40)
			var/obj/Blast/A=new
			A.Set_Stats(usr,Percent=80,Off_Mult=10,Explosion=2)
			A.Distance=50
			A.icon=icon
			A.dir=usr.dir
			A.loc=usr.loc
			step(A,A.dir)
			if(A) walk(A,A.dir,0)
		usr.attacking=0
		charging=0
obj/Attacks/New()
	if(Wave) BeamDescription()
	if(icon==initial(icon)&&icon) icon+=rgb(rand(0,255),rand(0,255),rand(0,255))
	..()
obj/Attacks/Cyber_Charge
	teachable=0
	Drain=10
	Teach_Timer=0.1
	Cost_To_Learn=0
	Experience=1
	Mastery=100
	icon='11.dmi'
	desc="An explosive one-shot energy attack that takes a few seconds to charge."
	verb/CyberCharge()
		set category="Skills"
		if(usr.Can_Blast()) return
		if(usr.attacking||usr.Ki<usr.Skill_Drain(src)) return
		if(prob(10)&&Experience<1) Experience+=0.1
		usr.Ki-=usr.Skill_Drain(src)
		Skill_Increase(2,usr)
		usr.attacking=3
		charging=1
		usr.overlays+=usr.BlastCharge
		view(10)<<sound('basicbeam_charge.ogg',volume=20)
		sleep(3.75*usr.Speed_Ratio())
		usr.overlays-=usr.BlastCharge
		if(!usr.Can_Blast())
			view(10)<<sound('Blast.wav',volume=30)
			var/obj/Blast/A=new
			A.icon=icon
			A.Set_Stats(usr,Percent=50,Off_Mult=5,Explosion=1)
			A.dir=usr.dir
			A.loc=usr.loc
			step(A,A.dir)
			if(A) walk(A,A.dir,1)
		usr.attacking=0
		charging=0
obj/Attacks/Kienzan
	icon='Blast - Destructo Disk.dmi'
	Cost_To_Learn=3
	Teach_Timer=1
	desc="A guidable energy disk"
	var/Kienzan_Delay=1
	Drain=300
	verb/Kienzan()
		set category="Skills"
		if(usr.Can_Blast()) return
		if(!usr.move||usr.attacking||usr.Ki<usr.Skill_Drain(src)) return
		Using=1
		usr.attacking=3
		usr.Ki-=usr.Skill_Drain(src)
		Skill_Increase(3,usr)
		view(10)<<sound('destructodisc_charge.ogg',volume=35)
		var/obj/Blast/A=new
		A.Sokidan=1
		A.icon=icon
		A.loc=get_step(usr,NORTH)
		A.Shockwave=0
		A.Piercer=1
		A.Set_Stats(usr,Percent=200,Off_Mult=20,Explosion=0)
		sleep(24*usr.Speed_Ratio())
		if(A)
			view(10)<<sound('disc_fire.ogg',volume=35)
			A.density=0
			flick("Attack",usr)
			spawn(100) if(usr)
				usr.attacking=0
				Using=0
			while(A&&usr&&getdist(A,usr)<20&&!A.deflected)
				Using=1
				step(A,usr.dir)
				if(A) A.density=1
				if(usr.KO&&A) del(A)
				sleep(Kienzan_Delay)
		Using=0
		usr.attacking=0
obj/Attacks/Spin_Blast
	Experience=1
	Teach_Timer=0.4
	Cost_To_Learn=2
	Drain=1
	icon='1.dmi'
	desc="An attack that becomes more rapid as your skill with it develops, and shoots in multiple \
	directions easily."
	verb/SpinBlast()
		set category="Skills"
		Experience=1000
		if(usr.Can_Blast()) return
		if(usr.attacking||usr.Ki<usr.Skill_Drain(src)) return
		usr.Ki-=usr.Skill_Drain(src)
		Skill_Increase(2,usr)
		if(prob(50))
			usr.attacking=3
			var/Delay=25/Experience
			if(Delay<1*sqrt(usr.Speed_Ratio())) Delay=1*sqrt(usr.Speed_Ratio())
			spawn(Delay) usr.attacking=0
		Experience+=0.01
		view(10)<<sound('Blast.wav',volume=30)
		for(var/v in 1 to 2)
			var/obj/Blast/A=new
			A.pixel_x+=rand(-12,12)
			A.pixel_y+=rand(-12,12)
			A.icon=icon
			A.Set_Stats(usr,Percent=20,Off_Mult=4,Explosion=0)
			A.Shockwave=Shockwave
			A.dir=usr.dir
			A.loc=usr.loc
			usr.dir=turn(usr.dir,45)
			walk(A,A.dir)
			if(prob(67))
				spawn(3) if(A) step(A,turn(A.dir,pick(-45,0,45)))
				spawn(5) if(A) walk(A,pick(A.dir,turn(A.dir,45),turn(A.dir,-45)))
obj/Attacks/Makosen
	Cost_To_Learn=6
	Teach_Timer=2
	var/Spread=50
	var/ChargeTime=200
	var/Shots=50
	var/ShotSpeed=2
	var/SleepProb=30
	var/Deletion=20
	var/ExplosiveChance=0
	var/Explosiveness=1
	Drain=150
	icon='Aura Blast Size 1.dmi'
	desc="A very, very powerful attack, widespread and very destructive. Made up of many smaller shots \
	that inflict a lot of damage all together. It is very draining, not very long range, and has a \
	long charge time."
	verb/Makosen()
		set category="Skills"
		if(usr.Can_Blast()) return
		if(usr.attacking||usr.Ki<usr.Skill_Drain(src)) return
		usr.attacking=3
		usr.overlays+=usr.BlastCharge
		view(10)<<sound('basicbeam_charge.ogg',volume=20)
		sleep(0.1*ChargeTime*sqrt(usr.Speed_Ratio()))
		usr.overlays-=usr.BlastCharge
		if(!usr.Can_Blast())
			view(10)<<sound('basicbeam_fire.ogg',volume=10)
			var/Amount=round(Shots*sqrt(usr.Eff))
			while(Amount)
				Amount-=1
				var/obj/Blast/A=new
				A.icon=icon
				var/Os=5
				while(Os)
					Os-=1
					var/image/I=image(icon=A.icon,icon_state=A.icon_state,pixel_x=rand(-32,32),pixel_y=rand(-32,32))
					A.overlays+=I
				A.layer=4
				A.Set_Stats(usr,Percent=6,Off_Mult=100,Explosion=0)
				if(prob(ExplosiveChance)) A.Explosive=Explosiveness
				A.dir=usr.dir
				A.pixel_x+=rand(-32,32)
				A.pixel_y+=rand(-32,32)
				A.loc=get_step(usr,usr.dir)
				spawn if(A) A.Beam()
				spawn(1) if(A)
					walk(A,usr.dir,ShotSpeed)
					spawn(3) if(A) switch(pick(1,2,3))
						if(1)
							var/D=A.dir
							step(A,turn(A.dir,45))
							if(A) A.dir=D
						if(2)
							var/D=A.dir
							step(A,turn(A.dir,-45))
							if(A) A.dir=D
				spawn(Deletion) if(A) del(A)
				if(prob(SleepProb)) sleep(1)
			usr.Ki-=usr.Skill_Drain(src)
			Skill_Increase(2,usr)
		usr.attacking=0
obj/Attacks/Kikoho
	Cost_To_Learn=0
	Teach_Timer=1
	Drain=50
	icon='16.dmi'
	desc="Similar to the charge attack, but much more powerful because it drains health and energy \
	to use it. A very strong attack. If you let it drain all your health, there is a chance you may die."
	verb/Kikoho()
		set category="Skills"
		if(usr.Can_Blast()) return
		if(usr.attacking||usr.Ki<usr.Skill_Drain(src)) return
		usr.Ki-=usr.Skill_Drain(src)
		Skill_Increase(1,usr)
		usr.Health-=15
		usr.attacking=3
		charging=1
		usr.overlays+=usr.BlastCharge
		sleep(25*usr.Speed_Ratio())
		usr.overlays-=usr.BlastCharge
		if(!usr.Can_Blast())
			view(10)<<sound('Blast.wav',volume=40)
			var/obj/Blast/Kikoho/A=new(get_step(src,usr.dir))
			A.loc=get_step(A,usr.dir)
			A.Set_Stats(usr,Percent=300,Off_Mult=5,Explosion=0)
			walk(A,usr.dir,2)
		usr.attacking=0
		charging=0
		spawn(100) if(usr.Health<0&&prob(10)) usr.Death(usr)
obj/Blast/Kikoho
	Piercer=0
	Explosive=2
	density=1
	New()
		var/Icon='deathball.dmi'
		Icon+=rgb(200,200,100,120)
		var/image/A=image(icon=Icon,icon_state="1",pixel_x=-16,pixel_y=-16,layer=5)
		var/image/B=image(icon=Icon,icon_state="2",pixel_x=16,pixel_y=-16,layer=5)
		var/image/C=image(icon=Icon,icon_state="3",pixel_x=-16,pixel_y=16,layer=5)
		var/image/D=image(icon=Icon,icon_state="4",pixel_x=16,pixel_y=16,layer=5)
		overlays.Remove(A,B,C,D)
		overlays.Add(A,B,C,D)
		//..()
	Move()
		for(var/atom/A in orange(1,src)) if(A!=src&&A.density&&!isarea(A)) Bump(A)
		if(src) ..()
mob/var/Frozen
obj/Time_Freeze_Energy
	var/TF_Timer=600
	var/ID
	New() spawn TF_Delete()
	Del()
		var/mob/M=loc
		if(ismob(M))
			M.Frozen=0
			M.overlays-='TimeFreeze.dmi'
		..()
	proc/TF_Delete() spawn(TF_Timer) if(src) del(src)
mob/var/tmp/list/Active_Freezes=new
mob/proc/Fill_Active_Freezes_List()
	for(var/mob/P in Players) for(var/obj/Time_Freeze_Energy/T in P) if(T.ID==key) Active_Freezes+=T
obj/Attacks/Time_Freeze
	desc="This will send paralyzing energy rings all around nearby people and they will not be able \
	to move until it wears off. The more BP and force you have compared to your opponent's BP and resistance, the \
	longer it will last."
	teachable=1
	Cost_To_Learn=0
	Teach_Timer=10
	verb/Time_Freeze()
		set category="Skills"
		if(usr.attacking) return
		if(usr.Frozen) return
		if(usr.KO) return
		for(var/obj/Time_Freeze_Energy/T) if(T.ID==usr.key)
			usr<<"You can not use this until it has worn off from everyone affected by the previous time you used this"
			return
		usr.overlays-='TimeFreeze.dmi'
		usr.overlays+='TimeFreeze.dmi'
		spawn(10) usr.overlays-='TimeFreeze.dmi'
		for(var/mob/A in oview(usr)) if(!A.Frozen&&A.client)
			if(getdist(usr,A)<=12) if(get_dir(usr,A) in list(usr.dir,turn(usr.dir,45),turn(usr.dir,-45)))
				view(10)<<sound('reflect.ogg',volume=20)
				usr.Ki/=2
				A.Frozen=1
				missile('TimeFreeze.dmi',usr,A)
				A.overlays-='TimeFreeze.dmi'
				A.overlays+='TimeFreeze.dmi'
				var/obj/Time_Freeze_Energy/T=new
				A.contents+=T
				usr.Active_Freezes+=T
				T.ID=usr.key
				T.TF_Timer=50*sqrt(usr.BP/A.BP)*(usr.Pow/A.Res)
				if(T.TF_Timer>600) T.TF_Timer=600
				sleep(10*usr.Speed_Ratio())
obj/Attacks/Explosion
	var/On
	desc="This attack causes an explosion on the ground, the more you use it the bigger the explosion"
	Cost_To_Learn=2
	Teach_Timer=0.3
	Experience=0
	Level=0
	verb/Settings()
		var/Max=6
		usr<<"This will increase the explosion radius. Current is [Level]. Minimum is 0. Max is [Max]"
		Level=input("") as num
		if(Level<0) Level=0
		if(Level>Max) Level=Max
	verb/Explosion()
		set category="Skills"
		if(!On)
			usr<<"Explosion activated, click the ground to trigger."
			On=1
		else
			usr<<"Explosion deactivated."
			On=0
obj/Attacks/Scatter_Shot
	Drain=100
	Teach_Timer=1
	Cost_To_Learn=6
	icon='17.dmi'
	desc="This will create multiple homing balls all around an opponent, and when its done they will \
	all collide at once on top of them. Individually each ball is weak, but all together it can be \
	extremely devastating to most people. The more energy you get the more balls you can make at once. \
	Use the Settings verb to change how many balls to make, between 1 and your max. Scatter shot will \
	attempt to target the person you are sensing if they are within range"
	var/Setting=30
	verb/Scatter_Shot()
		set category="Skills"
		if(usr.Can_Blast()) return
		if(!usr.move||usr.attacking||usr.Ki<usr.Skill_Drain(src)) return
		usr.attacking=3
		var/list/L=new
		for(var/mob/M in view(20,usr)) if(M!=usr&&(get_dir(usr,M) in list(usr.dir,turn(usr.dir,45),turn(usr.dir,-45))))
			L+=M
		if(!(locate(/mob) in L)) L+=usr
		var/mob/B
		if(usr.Target&&ismob(usr.Target)&&(Target in view(20,usr))) B=Target
		else B=input("Choose a target") in L
		if(!B) return
		var/amount=round(Setting*sqrt(usr.Eff))
		while(amount&&!usr.Can_Blast())
			view(10)<<sound('Blast.wav',volume=20)
			amount-=1
			flick("Attack",usr)
			var/obj/Blast/A=new
			A.Distance=300
			A.density=0
			A.icon=icon
			if(prob(100)) A.Explosive=1
			A.Shockwave=2
			A.Set_Stats(usr,Percent=8,Off_Mult=2,Explosion=0)
			A.loc=usr.loc
			var/turf/Spot
			var/list/Spots
			for(var/turf/T in Circle(4,B)) if(!T.density)
				if(!Spots) Spots=new/list
				Spots+=T
			if(Spots)
				Spot=pick(Spots)
				A.Can_Home=0
				walk_towards(A,Spot,1)
				spawn(rand(25,35)*sqrt(usr.Speed_Ratio())) if(A)
					if(B in range(0,A)) del(A)
					else
						A.density=1
						if(B) walk_towards(A,B,2)
				spawn if(A)
					while(A&&B) sleep(1)
					if(A) walk_rand(A)
				sleep(1)
			else if(A) del(A)
		usr.Ki-=usr.Skill_Drain(src)
		Skill_Increase(5,usr)
		usr.attacking=0
obj/var/tmp/Sokidan
obj/Attacks/Sokidan
	icon='17.dmi'
	Teach_Timer=0.7
	Cost_To_Learn=3
	desc="This makes a very powerful guided bomb of energy that explodes on contact. If you can get it \
	to actually hit someone it is a very nice attack. It will move faster and faster as you master it."
	var/Sokidan_Delay=1
	Drain=20
	verb/Sokidan()
		set category="Skills"
		if(usr.Can_Blast()) return
		if(!usr.move||usr.attacking||usr.Ki<usr.Skill_Drain(src)) return
		Using=1
		usr.attacking=3
		usr.Ki-=usr.Skill_Drain(src)
		Skill_Increase(3,usr)
		view(10)<<sound('basicbeam_charge.ogg',volume=20)
		var/obj/Blast/A=new
		A.Sokidan=1
		A.icon=icon
		A.loc=get_step(usr,NORTH)
		A.Shockwave=1
		A.Piercer=0
		A.Set_Stats(usr,Percent=100,Off_Mult=3,Explosion=1)
		sleep(12*usr.Speed_Ratio())
		if(A)
			view(10)<<sound('Blast.wav',volume=40)
			A.density=0
			flick("Attack",usr)
			spawn(100) if(usr)
				usr.attacking=0
				Using=0
			while(A&&usr&&getdist(A,usr)<20&&!A.deflected)
				Using=1
				step(A,usr.dir)
				if(A) A.density=1
				if(usr.KO&&A) del(A)
				sleep(Sokidan_Delay)
		Using=0
		usr.attacking=0
obj/Attacks/Genocide
	var/Charging
	Drain=10
	Teach_Timer=5
	Cost_To_Learn=20
	icon='18.dmi'
	desc="This is a very weak attack, about the power of a single blast, but each one homes in on random \
	targets across the planet. Press it once to begin firing, again to stop."
	verb/Genocide()
		set category="Skills"
		if(!Charging)
			if(usr.Can_Blast()) return
			if(usr.attacking||usr.Ki<usr.Skill_Drain(src)) return
			Charging=1
			usr.overlays+='SBombGivePower.dmi'
			usr.attacking=3
			sleep(25*usr.Speed_Ratio())
			var/list/Peoples=new
			for(var/mob/Z) if(Z.z==usr.z&&Z!=usr&&Z.client&&!Z.Safezone) Peoples+=Z
			while(Charging&&!usr.Can_Blast()&&usr.Ki>10)
				for(var/mob/B in Peoples) if(!usr.Can_Blast())
					Skill_Increase(1,usr)
					view(10)<<sound('Blast.wav',volume=20)
					var/obj/Blast/A=new
					A.Distance=500
					A.icon=icon
					A.Set_Stats(usr,Percent=10,Off_Mult=1,Explosion=0)
					A.loc=usr.loc
					A.dir=NORTH
					walk_towards(A,B)
					sleep(2)
				usr.Ki-=usr.Skill_Drain(src)
				sleep(5)
			usr.overlays-='SBombGivePower.dmi'
			usr.attacking=0
			Charging=0
		else Charging=0
obj/Crater
	icon='Craters.dmi'
	icon_state="small crater"
	Dead_Zone_Immune=1
	Health=1.#INF
	Grabbable=0
	Nukable=0
	Knockable=0
	Savable=0
	attackable=0
	New()
		for(var/obj/Crater/A in range(0,src)) if(A!=src) del(A)
		spawn(6000) if(src) del(src)
		//..()
obj/BigCrater
	icon='Craters.dmi'
	icon_state="Center"
	Dead_Zone_Immune=1
	Health=1.#INF
	Grabbable=0
	Savable=0
	Nukable=0
	Knockable=0
	attackable=0
	New()
		for(var/obj/BigCrater/A in view(2,src)) if(A!=src) del(src)
		var/image/A=image(icon='Craters.dmi',icon_state="N",pixel_y=32)
		var/image/B=image(icon='Craters.dmi',icon_state="S",pixel_y=-32)
		var/image/C=image(icon='Craters.dmi',icon_state="E",pixel_x=32)
		var/image/D=image(icon='Craters.dmi',icon_state="W",pixel_x=-32)
		var/image/E=image(icon='Craters.dmi',icon_state="NE",pixel_y=32,pixel_x=32)
		var/image/F=image(icon='Craters.dmi',icon_state="NW",pixel_y=32,pixel_x=-32)
		var/image/G=image(icon='Craters.dmi',icon_state="SE",pixel_y=-32,pixel_x=32)
		var/image/H=image(icon='Craters.dmi',icon_state="SW",pixel_y=-32,pixel_x=-32)
		overlays.Remove(A,B,C,D,E,F,G,H)
		overlays.Add(A,B,C,D,E,F,G,H)
		spawn(6000) if(src) del(src)
		//..()
obj/Blast/Genki_Dama
	Piercer=0
	Explosive=20
	density=1
	Sokidan=1
	New()
		spawn if(src) Health=Damage
	proc/Medium(Icon,X,Y,Z,T)
		Icon+=rgb(X,Y,Z,T)
		var/image/A=image(icon=Icon,icon_state="1",pixel_x=-16,pixel_y=-16,layer=5)
		var/image/B=image(icon=Icon,icon_state="2",pixel_x=16,pixel_y=-16,layer=5)
		var/image/C=image(icon=Icon,icon_state="3",pixel_x=-16,pixel_y=16,layer=5)
		var/image/D=image(icon=Icon,icon_state="4",pixel_x=16,pixel_y=16,layer=5)
		overlays.Add(A,B,C,D)
	proc/Large(Icon,X,Y,Z,T)
		Icon+=rgb(X,Y,Z,T)
		var/image/A=image(icon=Icon,icon_state="1",pixel_x=-32,pixel_y=-32,layer=5)
		var/image/B=image(icon=Icon,icon_state="2",pixel_x=0,pixel_y=-32,layer=5)
		var/image/C=image(icon=Icon,icon_state="3",pixel_x=32,pixel_y=-32,layer=5)
		var/image/D=image(icon=Icon,icon_state="4",pixel_x=-32,pixel_y=0,layer=5)
		var/image/E=image(icon=Icon,icon_state="5",pixel_x=0,pixel_y=0,layer=5)
		var/image/F=image(icon=Icon,icon_state="6",pixel_x=32,pixel_y=0,layer=5)
		var/image/G=image(icon=Icon,icon_state="7",pixel_x=-32,pixel_y=32,layer=5)
		var/image/H=image(icon=Icon,icon_state="8",pixel_x=0,pixel_y=32,layer=5)
		var/image/I=image(icon=Icon,icon_state="9",pixel_x=32,pixel_y=32,layer=5)
		overlays.Add(A,B,C,D,E,F,G,H,I)
obj/Attacks/Genki_Dama
	Cost_To_Learn=0
	clonable=0
	desc="This is the most powerful 1-hit attack in the game. Press it once to start charging, press it again \
	to fire. Guide it with the directional keys. This move is extremely deadly so only use it if you want to \
	kill someone."
	var/IsCharged
	var/Mode="Small"
	Drain=100
	icon='Ball - Supernova.dmi'
	New()
		if(icon==initial(icon)) Multiply_Color(rgb(100,200,250))
		..()
	Teach_Timer=10
	verb/Genki_Dama()
		set category="Skills"
		if(!charging)
			if(usr.Is_Cybernetic())
				usr<<"Cybernetic beings cannot use this ability"
				return
			if(usr.attacking||usr.Ki<Drain||usr.Can_Blast()) return
			Skill_Increase(10,usr)
			var/Icon=icon+rgb(0,0,0,25)
			var/obj/Blast/Genki_Dama/A=new(usr.loc)
			if(!A) return
			A.Set_Stats(usr,Percent=100,Off_Mult=10,Explosion=0)
			A.y+=5
			charging=1
			usr.attacking=3
			//usr.overlays+='SBombGivePower.dmi'
			var/Scale=5
			var/obj/O=new //Tiny energies that fly towards 'A'
			var/OScale=5
			var/Percent_Damage=100
			var/OIcon=icon+rgb(0,0,0,10)
			spawn while(A&&usr&&charging&&Scale)
				var/image/I=image(icon=Scaled_Icon(OIcon,OScale,OScale))
				Center_Icon(I)
				O.overlays+=I
				OScale+=1
				var/Amount=10
				spawn while(Amount&&A&&O)
					missile(O,pick(view(40,A)),A)
					Amount-=1
					sleep(1*usr.Speed_Ratio())
				if(Get_Width(I.icon)>38) break
				sleep(10*usr.Speed_Ratio())
			spawn while(A&&usr&&charging)
				Percent_Damage+=10
				A.Set_Stats(usr,Percent_Damage,20,A.Size+2)
				sleep(10*usr.Speed_Ratio())
			while(A&&usr&&usr.attacking&&charging)
				var/image/I=image(icon=Scaled_Icon(Icon,Scale,Scale))
				Center_Icon(I)
				A.overlays+=I
				A.Size=round(((Scale-32)/2)/32)
				Scale+=5
				if(Get_Width(I.icon)>192) break
				sleep(10*usr.Speed_Ratio())
			if(!A||!A.z) return
		else
			charging=1
			usr.attacking=0
			usr.overlays-='SBombGivePower.dmi'
			usr.Ki-=Drain
			usr.overlays-=usr.BlastCharge
			flick("Attack",usr)
			view(10)<<sound('basicbeam_fire.ogg',volume=15)
			var/obj/Blast/Genki_Dama/A
			for(var/obj/Blast/Genki_Dama/B) if(B.Owner==usr) A=B
			while(A&&usr&&getdist(A,usr)<20&&!A.deflected)
				step(A,usr.dir)
				sleep(4)
			charging=0
obj/Attacks/Death_Ball
	Teach_Timer=0.8
	Cost_To_Learn=5
	desc="This is a big attack, and is direction can be controlled. It is very powerful, but very \
	draining, and a bit slow moving. But it does charge pretty fast for such a powerful attack, once \
	it is fully mastered that is."
	var/IsCharged
	Drain=100
	icon='Ball - Supernova.dmi'
	verb/Death_Ball()
		set category="Skills"
		if(usr.Can_Blast()) return
		if(usr.attacking||usr.Ki<Drain||charging) return
		if(!IsCharged)
			Experience=1
			Skill_Increase(5,usr)
			view(10)<<sound('basicbeam_charge.ogg',volume=20)
			var/obj/Blast/Genki_Dama/A=new(usr.loc)
			A.y+=2
			if(!A||!A.z) return
			A.Set_Stats(usr,Percent=100,Off_Mult=10,Explosion=3)
			A.icon=Scaled_Icon(icon,96,96)
			Center_Icon(A)
			A.icon+=rgb(0,0,0,200)
			A.Size=1
			usr.attacking=3
			charging=1
			if(prob(10)&&Experience<1) Experience+=0.1
			sleep((12*usr.Speed_Ratio())/Experience)
			charging=0
			IsCharged=1
			usr.overlays+=usr.BlastCharge
			usr.attacking=0
		else
			IsCharged=0
			usr.Ki-=Drain
			usr.overlays-=usr.BlastCharge
			flick("Attack",usr)
			charging=1
			view(10)<<sound('basicbeam_fire.ogg',volume=15)
			var/obj/Blast/Genki_Dama/A
			for(var/obj/Blast/Genki_Dama/B) if(B.Owner==usr) A=B
			while(A&&usr&&getdist(A,usr)<20&&!A.deflected)
				step(A,usr.dir)
				sleep(2)
			charging=0
obj/Attacks/Shockwave
	teachable=1
	Cost_To_Learn=3
	Teach_Timer=0.3
	Drain=50
	verb/Shockwave()
		set category="Skills"
		if(usr in All_Entrants)
			usr<<"You can not use this in a tournament"
			return
		if(usr.Can_Blast()) return
		if(usr.attacking||usr.Ki<usr.Skill_Drain(src)) return
		usr.GrabbedMob=null
		Skill_Increase(1,usr)
		usr.Ki-=usr.Skill_Drain(src)
		usr.attacking=3
		var/Amount=5
		view(10)<<sound('wallhit.ogg',volume=40)
		spawn if(usr) while(Amount)
			Amount-=1
			var/Shockwave_Icon=pick('Shockwave.dmi')
			Make_Shockwave(usr,7,Shockwave_Icon)
			for(var/turf/T in oview(7,usr))
				if(prob(10)&&!T.density&&!T.Water)
					var/Dirts=1
					while(Dirts)
						Dirts-=1
						var/image/I=image(icon='Damaged Ground.dmi',pixel_x=rand(-16,16),pixel_y=rand(-16,16))
						T.overlays+=I
						T.Remove_Damaged_Ground(I)
			spawn for(var/mob/P in view(10,usr)) if(P!=usr)
				var/Distance=round(10*(usr.Pow/P.Res)*(usr.BP/P.BP))
				if(Distance>30) Distance=30
				P.Shockwave_Knockback(Distance,usr.loc)
				P.Health-=5*((usr.BP/P.BP)**2)*((usr.Pow/P.Res)**0.5)*Ki_Power
			spawn if(usr)
				var/n=0
				for(var/obj/O in view(7,usr)) if(O.z&&!O.Bolted&&!istype(O,/obj/Turfs/Door))
					n++
					if(n>10) break
					if(O.Health<=usr.BP) del(O)
					if(O) O.Shockwave_Knockback(10,usr.loc)
			sleep(3)
		spawn(20*usr.Speed_Ratio()) if(usr) usr.attacking=0
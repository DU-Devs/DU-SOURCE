obj/Attacks/Buster_Barrage
	Drain=9
	Teach_Timer=2
	Cost_To_Learn=7
	Experience=1
	icon='Shield, Legendary.dmi'
	desc="An attack which shoots energy from all parts of your body in random directions."
	Explosive=1
	Shockwave=1
	var/tmp/Barraging
	verb/Hotbar_use()
		set hidden=1
		Buster_Barrage()
	verb/Buster_Barrage()
		set category="Skills"
		usr.Buster_Barrage(src)
mob/proc/Buster_Barrage(obj/Attacks/Buster_Barrage/B)
	if(!B) for(var/obj/Attacks/Buster_Barrage/C in ki_attacks) B=C
	if(!B) return
	if(B.Barraging)
		B.Barraging=0
		return
	if(cant_blast()) return
	if(attacking) return
	attacking=3
	var/Delay=1*Speed_delay_mult(severity=0.3)
	if(!client) Delay=1
	B.Experience+=0.05
	overlays+='Shield, Legendary.dmi'
	B.Barraging=1
	while(B.Barraging&&!cant_blast()&&Ki>=Skill_Drain(B))
		player_view(10,src)<<sound('Blast.wav',volume=22)
		B.Skill_Increase(1,src)
		Ki-=Skill_Drain(B)
		var/obj/Blast/A=get_cached_blast()
		A.set_stats(src,Percent=10,Off_Mult=1,Explosion=0)
		A.from_attack=B
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
		sleep(To_tick_lag_multiple(Delay))
	attacking=0
	B.Barraging=0
	overlays-='Shield, Legendary.dmi'
obj/proc/Buster_Barrage_Move() spawn if(src)
	step(src,dir)
	sleep(1)
	var/mob/m=Owner
	while(src&&z&&Owner==m)
		if(ismob(Owner)&&getdist(src,Owner)<=2) step_away(src,Owner)
		else
			step(src,dir)
			dir=pick(dir,turn(dir,45),turn(dir,-45))
		sleep(2)





obj/Attacks/Attack_Barrier
	Drain=10
	Teach_Timer=2
	Cost_To_Learn=5
	verb/Hotbar_use()
		set hidden=1
		Attack_Barrier()
	icon='1.dmi'
	desc="An offensive and defensive move that makes many balls of ki swarm around you and whatever enters the \
	barrier will be attacked by them. Press the command once to begin firing the balls, press it again when you \
	feel you have fired enough. The more you fire the more it will drain your energy. This ability protects the \
	user from all explosion damage."
	var/tmp/Firing_Attack_Barrier
	verb/Attack_Barrier()
		set category="Skills"
		usr.Attack_Barrier(src)
obj/Blast/proc/attack_barrier_loop()
	spawn if(src)
		while(src&&z&&!deflected)
			if(!Owner) return
			var/mob/target
			for(target in view(2,src)) if(target!=Owner) break
			if(target)
				step_towards(src,target)
				if(target in loc) Bump(target)
			else if(getdist(src,Owner)>1) step_towards(src,Owner)
			else step_rand(src)
			sleep(To_tick_lag_multiple(1))
		if(Owner&&ismob(Owner)) Owner.attack_barrier_blasts--
mob/var/tmp/attack_barrier_blasts=0
mob/var/tmp/obj/Attacks/Attack_Barrier/attack_barrier_obj
mob/proc/Attack_Barrier(obj/Attacks/Attack_Barrier/B)
	attack_barrier_obj=B
	if(B.Firing_Attack_Barrier)
		B.Firing_Attack_Barrier=0
		src<<"You stop using Attack Barrier"
		return
	if(!B) for(var/obj/Attacks/Attack_Barrier/C in ki_attacks) B=C
	if(!B) return
	if(cant_blast()) return
	if(attacking||Ki<Skill_Drain(B)) return
	attacking=3
	B.Experience+=0.05
	//for(var/obj/Blast/Attack_Barrier/O) if(O.Owner==src) del(O)
	B.Firing_Attack_Barrier=1
	while(B.Firing_Attack_Barrier)
		var/max_blasts=12*Eff**0.3
		max_blasts=Clamp(max_blasts,9,36)
		max_blasts=To_multiple_of_one(max_blasts)
		while(B&&src&&B.Firing_Attack_Barrier&&attack_barrier_blasts>=max_blasts)
			sleep(5)
		if(Ki<Skill_Drain(B)) B.Firing_Attack_Barrier=0
		else if(cant_blast()) B.Firing_Attack_Barrier=0
		else
			B.Skill_Increase(0.6,src)
			Ki-=Skill_Drain(B)
			flick("Blast",src)
			player_view(10,src)<<sound('Blast.wav',0,1,0,15)
			attack_barrier_blasts++
			var/obj/Blast/A=get_cached_blast()
			spawn(rand(600,900)) if(A&&A.z) del(A)
			A.density=0
			A.attack_barrier_loop()
			A.Distance=99999999999
			A.pixel_x=rand(-16,16)
			A.pixel_y=rand(-16,16)
			A.icon=B.icon
			A.set_stats(src,Percent=2.5,Off_Mult=1.5,Explosion=0)
			A.from_attack=B
			//A.Shockwave=prob(33)
			A.dir=dir
			A.loc=loc
			sleep(To_tick_lag_multiple(1*Speed_delay_mult(severity=0.3)))
	attacking=0
atom/var/Fatal=1
mob/verb/Ki_Toggle()
	//set category="Other"
	if(src in All_Entrants)
		src<<"Your attacks can not be set to lethal in the tournament"
		return
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
		for(var/obj/Attacks/D in usr.ki_attacks) if(D.type!=/obj/Attacks/Time_Freeze) C+=D
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
	Blast95 icon='dark blast.dmi'
	Blast96 icon='flareblast.dmi'
	Blast97 icon='Fire blast big.dmi'
	Blast98 icon='Big bang attack.dmi'
	Beam1 icon='Beam1.dmi'
	Beam2 icon='Lightning Beam 2014.dmi'
	Beam3 icon='Beam3.dmi'
	Beam4 icon='Beam4.dmi'
	Beam5 icon='Beam5.dmi'
	Beam6 icon='Beam6.dmi'
	Beam8 icon='Beam8.dmi'
	Beam9 icon='Beam9.dmi'
	Beam10 icon='Beam10.dmi'
	Beam11 icon='Beam11.dmi'
	Piercer_Icon icon='Makkankosappo.dmi'
	Beam12 icon='Poison Beam 2014.dmi'
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
	Beam26 icon='Snake Beam 2014.dmi'
	Beam27 icon='Eraser Cannon.dmi'
	Beam28 icon='Freeza Death Ray.dmi'
	Beam29 icon='King Kold Death Ray.dmi'
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
	Aura1 icon='Normal Tall Aura.dmi'
	Aura2 icon='Aura January 27th 2014.dmi'
	Buu_Aura icon='Buu Aura.dmi'
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
	Health=1000
	Savable=1
	Builder
obj/Health=5000
mob/var/tmp/obj/Attacks/Blast/blast_obj
obj/Attacks/Blast
	Drain=0.1
	Teach_Timer=0.5
	Cost_To_Learn=2
	Experience=1
	var/Spread=1
	var/Blast_Count=1
	var/blast_refire=1
	var/blast_velocity=1
	icon='1.dmi'
	desc="An attack that becomes more rapid as your skill with it develops"
	New()
		spawn if(ismob(loc))
			var/mob/m=loc
			m.blast_obj=src
		Recalculate_blast_drain()
		..()
	verb/Blast_Options()
		set category="Other"
		while(usr)
			switch(input("These settings are for the 'Blast' ability") in list("Cancel","Firing Mode","Knockback","Explosiveness",\
			"Refire","Stun"))
				if("Cancel") return
				if("Stun")
					switch(alert("Stun? (Lowers damage)","Options","Yes","No"))
						if("No") Stun=0
						if("Yes") Stun=1
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
							//if(blast_refire>0.65)
							//	alert("Blast refire must not be higher than 0.65x to have explosions enabled. It has been \
							//	set to 0.65x automaticly")
							//	blast_refire=0.65
							Explosive=1
				if("Amount of blasts")
					Blast_Count=input("Amount of blasts? 1 to 4. More blasts increases drain heavily") as num
					if(Blast_Count<1) Blast_Count=1
					if(Blast_Count>4) Blast_Count=4
					Blast_Count=round(Blast_Count)
				if("Refire")
					var/max=1
					//if(Explosive) max=0.65
					blast_refire=input("Blast refire: 0.2 to [max]. The slower the more powerful. If you disable \
					exploding blasts you can set the refire higher") as num
					if(blast_refire>max) blast_refire=max
					if(blast_refire<0.2) blast_refire=0.2
			Recalculate_blast_drain()
	proc/Recalculate_blast_drain()
		Drain=initial(Drain)
		if(Spread>1) Drain*=3
		if(Explosive) Drain*=3
		if(Stun) Drain*=2
		Drain*=Blast_Count**2
		Drain*=1/blast_refire
	verb/Hotbar_use()
		set hidden=1
		usr.Blast_macro()
	verb/Blast()
		set category="Skills"
		usr.Blast_Fire(src)

mob/var/tmp
	blast_fire_loop
mob/verb/Blast_macro()
	set instant=1
	set hidden=1
	blast_fire_loop()
mob/proc/blast_fire_loop()
	if(blast_fire_loop) return
	blast_fire_loop=1
	if(blast_obj)
		var/k=Get_hotbar_ability_key(blast_obj)
		while(blast_obj&&(k in keys_down))
			Blast_Fire(blast_obj)
			sleep(get_blast_refire())
	blast_fire_loop=0

mob/proc/get_blast_refire()
	if(!blast_obj) return 1
	return To_tick_lag_multiple(1.5/blast_obj.blast_refire*Speed_delay_mult(severity=0.4))

mob/proc/get_shuriken_refire()
	return To_tick_lag_multiple(2 * Speed_delay_mult(severity=0.4))

mob/proc/Blast_Fire(obj/Attacks/Blast/B)
	if(!B) B=blast_obj
	if(!B) for(var/obj/Attacks/Blast/C in ki_attacks) B=C
	if(!B) return
	B.Blast_Count=1
	if(beaming||Beam_stunned()) return
	if(cant_blast()) return
	if(attacking||Ki<Skill_Drain(B)) return
	Ki-=Skill_Drain(B)
	B.Skill_Increase(1/B.blast_refire,src)
	attacking=3
	var/Delay=get_blast_refire()
	if(!client) Delay=1
	spawn(Delay) attacking=0
	B.Experience+=0.05/B.blast_refire
	if(prob(100)) player_view(10,src)<<sound('Blast.wav',0,1,0,15)
	var/Amount=B.Blast_Count
	if(B.Spread==2) Amount=To_multiple_of_one(Amount*1.35)
	if(B.Spread==3) Amount=To_multiple_of_one(Amount*2)
	while(Amount)
		var/obj/Blast/A=get_cached_blast()
		var/percent=3/B.blast_refire**0.35
		var/off_mod=1
		if(B.Stun) percent*=0.4
		//if(B.Spread==3) off_mod*=0.7
		A.Stun=B.Stun
		A.set_stats(src,Percent=percent,Off_Mult=off_mod,Explosion=0)
		A.from_attack=B
		A.Distance=150
		A.icon=B.icon
		Center_Icon(A)
		spawn(2) if(A)
			A.pixel_x+=rand(-12,12)
			A.pixel_y+=rand(-12,12)
		A.Shockwave=To_multiple_of_one(2.8*B.Shockwave/B.blast_refire**0.4)
		if(prob(100)) A.Explosive=B.Explosive
		A.dir=dir
		A.loc=loc
		step(A,dir)

		var/steps=0
		var/spread_step=rand(1,4)
		if(B.Spread==3) spread_step=rand(0,8)
		spawn(1) while(A&&A.z&&!A.deflected)
			var/old_dir=A.dir
			if(B&&B.Spread==2&&steps==spread_step&&prob(67))
				step(A,turn(A.dir,pick(-45,45)))
				A.dir=old_dir
			else if(B&&B.Spread==3&&steps==spread_step&&prob(90))
				A.dir=pick(turn(A.dir,45),turn(A.dir,-45))
				step(A,A.dir)
			else step(A,A.dir)
			steps++
			sleep(To_tick_lag_multiple(0.65 * world.tick_lag))

		Amount--
mob/proc/Disabled()
	if(KO||KB||(Frozen&&!paralysis_immune)||(Action in list("Meditating","Training"))) return 1
mob/proc/cant_blast()
	if(using_hokuto()) return 1
	if(Action in list("Meditating","Training")) return 1
	if(!z||KO||KB||(Frozen&&!paralysis_immune)||grabbed_mob||grabber) return 1
	if(Ki_Disabled)
		Ki_Disabled_Message()
		return 1
	if(tournament_override()) return 1
	if(!tournament_override(fighters_can=0,show_message=0))
		for(var/obj/o in ki_field_generators) if(o.z&&o.z==z&&getdist(o,src)<50)
			src<<"You can not do this because a nearby ki field generator is blocking your energy"
			return 1
obj/Attacks/Big_Bang_Attack
	Drain=80
	Teach_Timer=1
	Cost_To_Learn=10
	Experience=1
	icon='Big bang attack.dmi'
	desc="Basicly a more powerful version of the 'charge' ki attack"
	verb/Hotbar_use()
		set hidden=1
		Big_Bang()
	verb/Big_Bang()
		set category="Skills"
		if(usr.cant_blast()) return
		if(usr.attacking||usr.Ki<usr.Skill_Drain(src)) return
		if(prob(10)&&Experience<1) Experience+=0.1
		usr.Ki-=usr.Skill_Drain(src)
		Skill_Increase(2,usr)
		usr.attacking=3
		charging=1
		//usr.moving_charge=1
		usr.overlays+=usr.BlastCharge
		player_view(10,usr)<<sound('basicbeam_charge.ogg',volume=30)
		var/turf/fire_location=usr.loc
		sleep(To_tick_lag_multiple(23*usr.Speed_delay_mult(severity=0.5)))
		usr.overlays-=usr.BlastCharge
		if(!usr.cant_blast())
			player_view(10,usr)<<sound('Blast.wav',volume=70)
			usr.Say("BIG BANG ATTACK!!")
			var/obj/Blast/A=get_cached_blast()
			var/dmg=60
			if(usr.loc==fire_location) dmg*=1.5
			A.set_stats(usr,Percent=dmg,Off_Mult=1,Explosion=4)
			A.from_attack=src
			A.Shockwave=1
			A.Distance=50
			A.icon=icon
			A.dir=usr.dir
			A.loc=usr.loc
			step(A,A.dir)
			if(A&&A.z) A.blast_walk(0.8 * world.tick_lag)
		usr.attacking=0
		//usr.moving_charge=0
		charging=0








obj/Attacks/Charge
	Drain=20
	Teach_Timer=0.1
	Cost_To_Learn=1
	Experience=1
	icon='20.dmi'
	desc="An explosive one-shot energy attack that takes a few seconds to charge."
	verb/Hotbar_use()
		set hidden=1
		Charge()
	verb/Charge()
		set category="Skills"
		if(usr.cant_blast()) return
		if(usr.attacking||usr.Ki<usr.Skill_Drain(src)) return
		if(prob(10)&&Experience<1) Experience+=0.1
		usr.Ki-=usr.Skill_Drain(src)
		Skill_Increase(2,usr)
		usr.attacking=3
		//charging=1
		usr.moving_charge=1
		usr.overlays+=usr.BlastCharge
		player_view(10,usr)<<sound('basicbeam_charge.ogg',volume=20)
		var/turf/fire_location=usr.loc
		sleep(To_tick_lag_multiple(10*usr.Speed_delay_mult(severity=0.5)))
		usr.overlays-=usr.BlastCharge
		if(!usr.cant_blast())
			player_view(10,usr)<<sound('Blast.wav',volume=40)
			var/obj/Blast/A=get_cached_blast()
			var/dmg=20
			if(usr.loc==fire_location) dmg*=1.5
			A.set_stats(usr,Percent=dmg,Off_Mult=2,Explosion=2)
			A.from_attack=src
			A.Shockwave=1
			A.Distance=50
			A.icon=icon
			A.dir=usr.dir
			A.loc=usr.loc
			step(A,A.dir)
			if(A&&A.z) A.blast_walk(0.85 * world.tick_lag)
		usr.attacking=0
		usr.moving_charge=0
		//charging=0

obj/proc/blast_walk(delay=1,start_dir) spawn
	if(start_dir) dir=start_dir
	while(src&&z)
		step(src,dir)
		sleep(To_tick_lag_multiple(delay))

mob/var/tmp/moving_charge
obj/Attacks/New()
	spawn(5) if(src&&ismob(loc))
		var/mob/m=loc
		m.ki_attacks+=src
	spawn(10) if(src&&Wave)
		calculate_beam_drain()
		BeamDescription()
	spawn(50) if(src&&icon&&icon==initial(icon)) icon+=rgb(rand(0,255),rand(0,255),rand(0,255))
	..()
obj/Attacks/Cyber_Charge
	teachable=0
	Drain=10
	Teach_Timer=0.1
	Cost_To_Learn=0
	Experience=1
	Mastery=100
	icon='11.dmi'
	desc="This artificial attack is designed to mimic charge. It is a bit weaker but can be fired \
	twice as fast."
	verb/Hotbar_use()
		set hidden=1
		CyberCharge()
	verb/CyberCharge()
		set category="Skills"
		if(usr.cant_blast()) return
		if(usr.attacking||usr.Ki<usr.Skill_Drain(src)) return
		if(prob(10)&&Experience<1) Experience+=0.1
		usr.Ki-=usr.Skill_Drain(src)
		Skill_Increase(2,usr)
		usr.attacking=3
		charging=1
		usr.overlays+=usr.BlastCharge
		player_view(10,usr)<<sound('basicbeam_charge.ogg',volume=20)
		sleep(To_tick_lag_multiple(7*usr.Speed_delay_mult(severity=0.5)))
		usr.overlays-=usr.BlastCharge
		if(!usr.cant_blast())
			player_view(10,usr)<<sound('Blast.wav',volume=30)
			var/obj/Blast/A=get_cached_blast()
			A.icon=icon
			A.set_stats(usr,Percent=20,Off_Mult=5,Explosion=1)
			A.from_attack=src
			A.dir=usr.dir
			A.loc=usr.loc
			step(A,A.dir)
			if(A) A.blast_walk(0.66 * world.tick_lag)
		usr.attacking=0
		charging=0
obj/Attacks/Kienzan
	icon='Blast - Destructo Disk.dmi'
	Cost_To_Learn=3
	Teach_Timer=1
	desc="A guidable energy disk"
	var/tmp/Kienzan_Delay=0.85
	Drain=100
	verb/Hotbar_use()
		set hidden=1
		Kienzan()
	verb/Kienzan()
		set category="Skills"
		if(usr.cant_blast()) return
		if(!usr.move||usr.attacking||usr.Ki<usr.Skill_Drain(src)) return
		var/turf/t=Get_step(usr,NORTH)
		if(t)
			var/obstacle
			for(var/obj/o in t) if(o.density&&!istype(o,/obj/Blast))
				obstacle=1
				break
			if(t.density) obstacle=1
			if(obstacle)
				usr<<"You can not use this here because there is an obstacle above you"
				return
		Using=1
		usr.attacking=3
		if(usr.h1_overhead_gfx)
			usr.icon_state="1H Overhead Charge"
		usr.Ki-=usr.Skill_Drain(src)
		Skill_Increase(3,usr)
		player_view(10,usr)<<sound('destructodisc_charge.ogg',volume=35)
		var/obj/Blast/A=get_cached_blast()
		A.Sokidan=1
		A.Distance=120
		A.icon=icon
		A.loc=Get_step(usr,NORTH)
		A.Shockwave=0
		A.Piercer=1
		A.slice_attack=1
		A.set_stats(usr,Percent=55,Off_Mult=20,Explosion=0)
		A.from_attack=src
		sleep(To_tick_lag_multiple(16*usr.Speed_delay_mult(severity=0.5)))
		if(usr.h1_overhead_gfx)
			usr.icon_state=""
		if(A)
			player_view(10,usr)<<sound('disc_fire.ogg',volume=35)
			A.density=0
			flick("Attack",usr)
			spawn(100) if(usr)
				usr.attacking=0
				Using=0
			while(A&&A.z&&usr&&getdist(A,usr)<20&&!A.deflected)
				Using=1
				if(prob(80)&&Owner&&(Owner in Get_step(A,usr.dir)))
					step(A,pick(turn(usr.dir,45),turn(usr.dir,-45)))
				else step(A,usr.dir)
				if(A) A.density=1
				if(usr.KO&&A) del(A)
				sleep(To_tick_lag_multiple(Kienzan_Delay))
			if(A&&A.z) walk(A,A.dir)
		Using=0
		if(usr) usr.attacking=0
obj/Attacks/Spin_Blast
	Experience=1
	Teach_Timer=0.4
	Cost_To_Learn=2
	Drain=10
	icon='1.dmi'
	desc="An attack that becomes more rapid as your skill with it develops, and shoots in multiple \
	directions easily."
	verb/Hotbar_use()
		set hidden=1
		SpinBlast()
	verb/SpinBlast()
		set category="Skills"
		Experience=1000
		if(usr.cant_blast()) return
		if(usr.attacking||usr.Ki<usr.Skill_Drain(src)) return
		usr.Ki-=usr.Skill_Drain(src)
		Skill_Increase(2,usr)
		if(prob(50))
			usr.attacking=3
			var/Delay=25/Experience
			if(Delay<1*usr.Speed_delay_mult(severity=0.5)) Delay=1*usr.Speed_delay_mult(severity=0.5)
			Delay=To_tick_lag_multiple(Delay)
			spawn(Delay) usr.attacking=0
		Experience+=0.01
		player_view(10,usr)<<sound('Blast.wav',volume=30)
		for(var/v in 1 to 2)
			var/obj/Blast/A=get_cached_blast()
			A.pixel_x+=rand(-12,12)
			A.pixel_y+=rand(-12,12)
			A.icon=icon
			A.set_stats(usr,Percent=4,Off_Mult=1,Explosion=rand(2,3))
			A.from_attack=src
			A.Shockwave=Shockwave
			A.dir=pick(NORTH,SOUTH,EAST,WEST,NORTHWEST,NORTHEAST,SOUTHEAST,SOUTHWEST)
			A.loc=usr.loc
			walk(A,A.dir)
			if(prob(67))
				spawn(3) if(A&&A.z) step(A,turn(A.dir,pick(-45,0,45)))
				spawn(5) if(A&&A.z) walk(A,pick(A.dir,turn(A.dir,45),turn(A.dir,-45)))
obj/Attacks/Makosen
	Cost_To_Learn=6
	Teach_Timer=2
	var/Spread=50
	var/ChargeTime=200
	var/Shots=25
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
	verb/Hotbar_use()
		set hidden=1
		Makosen()
	verb/Makosen()
		set category="Skills"
		if(usr.cant_blast()) return
		if(usr.attacking||usr.Ki<usr.Skill_Drain(src)) return
		usr.attacking=3
		usr.overlays+=usr.BlastCharge
		player_view(10,usr)<<sound('basicbeam_charge.ogg',volume=20)
		charging=1
		sleep(To_tick_lag_multiple(0.1*ChargeTime*usr.Speed_delay_mult(severity=0.5)))
		usr.overlays-=usr.BlastCharge
		if(!usr.cant_blast())
			player_view(10,usr)<<sound('basicbeam_fire.ogg',volume=10)
			var/Amount=To_multiple_of_one(17*usr.Eff**0.25)
			while(Amount)
				Amount-=1
				var/obj/Blast/A=get_cached_blast()
				A.Can_Home=0
				A.icon=icon
				var/Os=5
				while(Os)
					Os-=1
					var/image/I=image(icon=A.icon,icon_state=A.icon_state,pixel_x=rand(-32,32),pixel_y=rand(-32,32))
					A.overlays+=I
				//A.Deflectable=0
				A.apply_short_range_beam_knock=0
				A.layer=4
				A.set_stats(usr,Percent=14,Off_Mult=1,Explosion=0)
				A.deflect_difficulty=4
				A.from_attack=src
				if(prob(ExplosiveChance)) A.Explosive=Explosiveness
				A.dir=usr.dir
				A.pixel_x+=rand(-32,32)
				A.pixel_y+=rand(-32,32)
				A.Distance=35
				A.loc=Get_step(usr,usr.dir)
				A.loc=pick(Get_step(usr,usr.dir),Get_step(usr,turn(usr.dir,45)),Get_step(usr,turn(usr.dir,-45)))

				//to keep makosen from shooting thru 1 tile thick walls when you fire it right next to it
				var/turf/t=A.loc
				if(t&&isturf(t)&&t.Health>A.BP) del(A)

				spawn(To_tick_lag_multiple(rand(0,2))) if(A&&A.z) A.Beam()
				spawn if(A&&A.z) walk(A,A.dir,ShotSpeed)
				sleep(To_tick_lag_multiple(1))
			usr.Ki-=usr.Skill_Drain(src)
			Skill_Increase(2,usr)
		usr.attacking=0
		charging=0
obj/Attacks/Kikoho
	Cost_To_Learn=0
	Teach_Timer=1
	Drain=50
	icon='16.dmi'
	desc="Similar to the charge attack, but much more powerful because it drains health and energy \
	to use it. A very strong attack. If you let it drain all your health, there is a chance you may die. \
	This attack does 10x damage against vampires."
	verb/Hotbar_use()
		set hidden=1
		Kikoho()
	verb/Kikoho()
		set category="Skills"
		if(usr.cant_blast()) return
		if(usr.attacking||usr.Ki<usr.Skill_Drain(src)) return
		usr.Ki-=usr.Skill_Drain(src)
		Skill_Increase(1,usr)
		usr.Health-=15
		usr.attacking=3
		charging=1
		usr.overlays+=usr.BlastCharge
		sleep(20*usr.Speed_delay_mult(severity=0.5))
		usr.overlays-=usr.BlastCharge
		if(!usr.cant_blast())
			player_view(10,usr)<<sound('Blast.wav',volume=40)
			var/obj/Blast/Kikoho/A=new(Get_step(src,usr.dir))
			A.loc=Get_step(A,usr.dir)
			A.set_stats(usr,Percent=110,Off_Mult=5,Explosion=0)
			A.from_attack=src
			A.blast_walk(1.5 * world.tick_lag,usr.dir)
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
		overlays=null
		overlays.Add(A,B,C,D)
		//..()
	Move()
		for(var/atom/A in orange(1,src)) if(A!=src&&A.density&&!isarea(A)) Bump(A)
		if(src) ..()
mob/var/
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
	for(var/mob/P in players) for(var/obj/Time_Freeze_Energy/T in P) if(T.ID==key) Active_Freezes+=T
obj/Attacks/Time_Freeze
	desc="This will send paralyzing energy rings all around nearby people and they will not be able \
	to move until it wears off. The more BP and force you have compared to your opponent's BP and resistance, the \
	longer it will last."
	teachable=0
	hotbar_type="Ability"
	can_hotbar=1
	Cost_To_Learn=0
	Teach_Timer=9
	var/tmp/time_freeze_timer=0
	verb/Hotbar_use()
		set hidden=1
		Time_Freeze()
	verb/Time_Freeze()
		set category="Skills"
		if(usr.attacking||usr.tournament_override(fighters_can=1)) return
		if(usr.Frozen) return
		if(usr.KO) return
		if(time_freeze_timer>0)
			usr<<"You can not use this for another [time_freeze_timer] seconds"
			return
		for(var/obj/Time_Freeze_Energy/T) if(T.ID==usr.key)
			usr<<"You can not use this until it has worn off from everyone affected by the previous time you used this"
			return
		usr.overlays-='TimeFreeze.dmi'
		usr.overlays+='TimeFreeze.dmi'
		spawn(10) usr.overlays-='TimeFreeze.dmi'
		time_freeze_timer=To_multiple_of_one(60*usr.Speed_delay_mult(severity=0.5))
		spawn while(src&&time_freeze_timer>0)
			time_freeze_timer--
			sleep(10)
		for(var/mob/A in mob_view(15,usr)) if(A!=usr&&!A.Frozen&&A.client)
			if(getdist(usr,A)<=12) if(get_dir(usr,A) in list(usr.dir,turn(usr.dir,45),turn(usr.dir,-45)))
				player_view(10,usr)<<sound('reflect.ogg',volume=20)
				A.Frozen=1
				Missile('TimeFreeze.dmi',usr,A)
				A.overlays-='TimeFreeze.dmi'
				A.overlays+='TimeFreeze.dmi'
				var/obj/Time_Freeze_Energy/T=new
				A.contents+=T
				usr.Active_Freezes+=T
				T.ID=usr.key
				T.TF_Timer=50*sqrt(usr.BP/A.BP) * Clamp((usr.Pow/A.Res)**0.35,0.4,3) / A.stun_resistance_mod
				if(T.TF_Timer>600) T.TF_Timer=600
				sleep(10*usr.Speed_delay_mult(severity=0.5))
obj/Attacks/Explosion
	var/On
	hotbar_type="Ability"
	can_hotbar=1
	desc="This attack causes an explosion on the ground, the more you use it the bigger the explosion"
	Cost_To_Learn=2
	Teach_Timer=0.5
	Experience=0
	Level=5
	New()
		if(Level>5) Level=5
		..()
	verb/Hotbar_use()
		set hidden=1
		Explosion()
	verb/Explosion_Options()
		set category="Other"
		var/Max=7
		usr<<"Explosion skill: This will increase the explosion radius when you click the ground to use the \
		explosion ability, but increase cooldown on using it. Current is [Level]. Minimum is 0. Max is [Max]"
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
mob/var/tmp/last_scattershot=0 //world.time
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
	var/tmp/list/scatter_shot_blasts=new
	verb/Hotbar_use()
		set hidden=1
		Scatter_Shot()
	verb/Scatter_Shot()
		set category="Skills"
		if(usr.beaming||usr.Beam_stunned()) return
		if("Scatter shot" in usr.active_prompts) return

		var/minutes=1
		if(world.time<usr.last_scattershot+(minutes*60*10))
			var/minutes_left=(usr.last_scattershot+(minutes*60*10)-world.time)/(10*60)
			usr<<"You can not use scattershot for another [round(minutes_left)] minutes and [round((minutes_left*60)%60)] \
			seconds"
			return

		for(var/obj/o in scatter_shot_blasts) if(!o.z) scatter_shot_blasts-=o
		//if(locate(/obj) in scatter_shot_blasts)
			//usr<<"You can not use this again until all previous scatter shot blasts are gone"
			//return
		if(usr.cant_blast()) return
		if(!usr.move||usr.attacking||usr.Ki<usr.Skill_Drain(src)) return
		var/list/L=list("Cancel")
		for(var/mob/M in mob_view(20,usr)) if(M!=usr&&(get_dir(usr,M) in list(usr.dir,turn(usr.dir,45),turn(usr.dir,-45))))
			L+=M
		if(!(locate(/mob) in L)) L+=usr

		var/mob/B=usr.flash_step_mob
		if(B&&getdist(usr,B)>15) B=null
		if(!B||!usr.Is_valid_flash_step_target(B))
			B=null
			for(var/mob/m in mob_view(15,usr)) if(m.Is_valid_flash_step_target(m))
				if(!B||getdist(usr,m)<getdist(usr,B))
					B=m
		if(!B) B=usr

		//usr.active_prompts+="Scatter shot"
		//if(usr.Target&&usr.Target!=usr&&ismob(usr.Target)&&(Target in mob_view(20,usr))) B=Target
		//else B=input("Choose a target") in L
		//usr.active_prompts-="Scatter shot"
		//if(!B||B=="Cancel") return

		usr.attacking=3
		var/amount=To_multiple_of_one(40*sqrt(usr.Eff))
		Using=1
		usr.last_scattershot=world.time
		while(amount&&!usr.cant_blast())
			player_view(10,usr)<<sound('Blast.wav',volume=20)
			amount-=1
			flick("Attack",usr)
			var/obj/Blast/A=get_cached_blast()
			scatter_shot_blasts+=A
			A.Distance=70
			A.density=0
			A.icon=icon
			if(prob(100)) A.Explosive=1
			A.Shockwave=3
			A.set_stats(usr,Percent=3.5,Off_Mult=1,Explosion=To_multiple_of_one(0.3))
			A.from_attack=src
			A.loc=usr.loc
			var/turf/Spot
			var/list/Spots
			for(var/turf/T in Circle(9,B)) if(!T.density)
				if(!Spots) Spots=new/list
				Spots+=T
			if(Spots)
				Spot=pick(Spots)
				A.Can_Home=0
				walk_towards(A,Spot,1)
				spawn(rand(20,25)*usr.Speed_delay_mult(severity=0.5)) if(A&&A.z&&A.Owner==usr)
					A.density=1
					if(B) walk_towards(A,B,To_tick_lag_multiple(1))
					spawn while(B&&A&&A.z&&A.Owner==usr)
						if(usr&&(usr.KB||usr.KO))
							walk(A,pick(A.dir,turn(A.dir,45),turn(A.dir,-45),turn(A.dir,90),turn(A.dir,-90)))
						if(B in range(0,A)) A.Bump(B,override_dir=pick(NORTH,SOUTH,EAST,WEST,NORTHEAST,NORTHWEST,SOUTHWEST,SOUTHEAST))
						sleep(1)
				spawn if(A&&A.z&&A.Owner==usr)
					while(A&&A.z&&B) sleep(2)
					if(A&&A.z)
						walk_rand(A)
						spawn(rand(1,50)) if(A) del(A)
				sleep(To_tick_lag_multiple(0.3))
			else if(A) del(A)
		usr.Ki-=usr.Skill_Drain(src)
		Skill_Increase(5,usr)
		usr.attacking=0
		spawn(30+usr.Speed_delay_mult(severity=0.5)*4) if(src) Using=0
obj/var/tmp/Sokidan
obj/Attacks/Sokidan
	icon='17.dmi'
	Teach_Timer=0.7
	Cost_To_Learn=3
	desc="This makes a very powerful guided bomb of energy that explodes on contact. If you can get it \
	to actually hit someone it is a very nice attack. It will move faster and faster as you master it."
	var/tmp/Sokidan_Delay=1
	Drain=20
	verb/Hotbar_use()
		set hidden=1
		Sokidan()
	verb/Sokidan()
		set category="Skills"
		if(usr.cant_blast()) return
		if(!usr.move||usr.attacking||usr.Ki<usr.Skill_Drain(src)) return
		var/turf/t=Get_step(usr,NORTH)
		if(t)
			var/obstacle
			for(var/obj/o in t) if(o.density&&!istype(o,/obj/Blast))
				obstacle=1
				break
			if(t.density) obstacle=1
			if(obstacle)
				usr<<"You can not use this here because there is an obstacle above you"
				return
		Using=1
		usr.attacking=3
		if(usr.h1_overhead_gfx)
			usr.icon_state="1H Overhead Charge"
		usr.Ki-=usr.Skill_Drain(src)
		Skill_Increase(3,usr)
		player_view(10,usr)<<sound('basicbeam_charge.ogg',volume=20)
		var/obj/Blast/A=get_cached_blast()
		A.Sokidan=1
		A.Stun=2
		A.Distance=120
		A.icon=icon
		A.loc=Get_step(usr,NORTH)
		A.Shockwave=2
		A.Piercer=0
		A.set_stats(usr,Percent=23,Off_Mult=3,Explosion=2)
		A.from_attack=src
		sleep(To_tick_lag_multiple(8*usr.Speed_delay_mult(severity=0.7)))
		if(usr.h1_overhead_gfx)
			usr.icon_state=""
		if(A&&A.z)
			player_view(10,usr)<<sound('Blast.wav',volume=40)
			A.density=0
			flick("Attack",usr)
			spawn(100) if(usr)
				usr.attacking=0
				Using=0
			var/controlling=1
			var/bumps=5
			while(A&&A.z&&usr&&getdist(A,usr)<25&&!A.deflected&&controlling)
				Using=1
				if(locate(/mob) in Get_step(A,usr.dir))
					for(var/mob/m in Get_step(A,usr.dir))
						if(m==A.Owner&&prob(80))
							step(A,pick(turn(A.dir,45),turn(A.dir,-45)))
						else
							//controlling=0
							var/bump_dir
							if(prob(50)) bump_dir=get_dir(m,usr)
							else bump_dir=pick(NORTH,SOUTH,EAST,WEST,NORTHWEST,NORTHEAST,SOUTHWEST,SOUTHEAST)
							A.Bump(m,override_delete=bumps,override_dir=bump_dir)
							if(A&&m) step_away(A,m)
							bumps--
				else step(A,usr.dir)
				if(A) A.density=1
				if(usr.KO&&A) del(A)
				sleep(To_tick_lag_multiple(Sokidan_Delay))
			if(A&&A.z)
				if(A.deflected) A.Distance=15
				walk(A,A.dir)
		Using=0
		usr.attacking=0
obj/Attacks/Genocide
	var/Charging
	Drain=10
	Teach_Timer=5
	Cost_To_Learn=40
	icon='18.dmi'
	desc="This is a very weak attack, about the power of a single blast, but each one homes in on random \
	targets across the planet. Press it once to begin firing, again to stop."
	verb/Hotbar_use()
		set hidden=1
		Genocide()
	verb/Genocide()
		set category="Skills"
		if(!Charging)
			if(usr.cant_blast()) return
			if(usr.attacking||usr.Ki<usr.Skill_Drain(src)) return
			Charging=1
			usr.overlays+='SBombGivePower.dmi'
			usr.attacking=3
			sleep(25*usr.Speed_delay_mult(severity=0.5))
			var/list/Peoples=new
			for(var/mob/Z in players)
				if(Z.z==usr.z&&Z!=usr&&Z.client&&!Z.Safezone&&!(Z in All_Entrants)&&!Z.hiding_energy) Peoples+=Z
			while(Charging&&!usr.cant_blast()&&usr.Ki>10)
				for(var/mob/B in Peoples) if(!usr.cant_blast())
					Skill_Increase(1,usr)
					player_view(10,usr)<<sound('Blast.wav',volume=20)
					var/obj/Blast/A=get_cached_blast()
					A.Distance=500
					A.icon=icon
					A.set_stats(usr,Percent=2,Off_Mult=1,Explosion=0)
					A.from_attack=src
					A.loc=usr.loc
					A.dir=NORTH
					walk_towards(A,B)
					if(prob(20)) sleep(1)
				usr.Ki-=usr.Skill_Drain(src)
				sleep(20)
			usr.overlays-='SBombGivePower.dmi'
			usr.attacking=0
			Charging=0
		else Charging=0
var/list/small_crater_cache=new
var/list/big_crater_cache=new
proc/Small_crater(turf/t)
	var/obj/Crater/c
	if(small_crater_cache.len)
		c=small_crater_cache[1]
		small_crater_cache-=c
	else c=new
	c.loc=t
	Timed_Delete(c,6000)
	return c
proc/Big_crater(turf/t)
	if(locate(/obj/BigCrater) in view(3,t)) return
	var/obj/BigCrater/c
	if(big_crater_cache.len)
		c=big_crater_cache[1]
		big_crater_cache-=c
	else c=new
	c.loc=t
	Timed_Delete(c,6000)
	return c
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
		for(var/obj/Crater/A in loc) if(A!=src) del(A)
		//..()
	Del()
		small_crater_cache+=src
		loc=null
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
		layer-=0.1
		var/image/A=image(icon='Craters.dmi',icon_state="N",pixel_y=32)
		var/image/B=image(icon='Craters.dmi',icon_state="S",pixel_y=-32)
		var/image/C=image(icon='Craters.dmi',icon_state="E",pixel_x=32)
		var/image/D=image(icon='Craters.dmi',icon_state="W",pixel_x=-32)
		var/image/E=image(icon='Craters.dmi',icon_state="NE",pixel_y=32,pixel_x=32)
		var/image/F=image(icon='Craters.dmi',icon_state="NW",pixel_y=32,pixel_x=-32)
		var/image/G=image(icon='Craters.dmi',icon_state="SE",pixel_y=-32,pixel_x=32)
		var/image/H=image(icon='Craters.dmi',icon_state="SW",pixel_y=-32,pixel_x=-32)
		overlays=null
		overlays.Add(A,B,C,D,E,F,G,H)
		//..()
	Del()
		big_crater_cache+=src
		loc=null
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
	name="Spirit Bomb"
	Cost_To_Learn=0
	clonable=0
	desc="This is the most powerful 1-hit attack in the game. Press it once to start charging, press it again \
	to fire. Guide it with the directional keys. This move is extremely deadly so only use it if you want to \
	kill someone."
	var/IsCharged
	var/Mode="Small"
	Drain=100
	var/tmp/can_fire_genki_dama=1
	icon='Ball - Supernova.dmi'
	New()
		if(icon==initial(icon)) Multiply_Color(rgb(100,200,250))
		..()
	Teach_Timer=2
	verb/Hotbar_use()
		set hidden=1
		Spirit_Bomb()
	verb/Spirit_Bomb()
		set category="Skills"
		if(!charging)
			if(usr.Is_Cybernetic())
				usr<<"Cybernetic beings cannot use this ability"
				return
			if(usr.attacking||usr.Ki<Drain||usr.cant_blast()) return

			var/turf/blast_loc=locate(usr.x,usr.y+5,usr.z)
			if(!blast_loc||!isturf(blast_loc)||blast_loc.density||!(blast_loc in view(10,usr)))
				usr<<"There is an obstacle in the way"
				return

			Skill_Increase(10,usr)
			can_fire_genki_dama=0
			var/Icon=icon+rgb(0,0,0,25)
			var/obj/Blast/Genki_Dama/A=new(blast_loc)
			if(!A) return
			A.set_stats(usr,Percent=33,Off_Mult=10,Explosion=0)
			A.from_attack=src
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
				OScale+=To_multiple_of_one(1.5)
				var/Amount=10
				spawn while(Amount&&A&&O)
					Missile(O,pick(view(40,A)),A)
					Amount-=1
					sleep(1*usr.Speed_delay_mult(severity=0.5))
				if(Get_Width(I.icon)>38) break
				sleep(6*usr.Speed_delay_mult(severity=0.5))
			spawn while(A&&usr&&charging)
				Percent_Damage+=12
				A.set_stats(usr,Percent_Damage,20,A.Size+2)
				A.from_attack=src
				sleep(3*usr.Speed_delay_mult(severity=0.5))
			while(A&&usr&&usr.attacking&&charging)
				var/image/I=image(icon=Scaled_Icon(Icon,Scale,Scale))
				Center_Icon(I)
				A.overlays+=I
				A.Size=round(((Scale-32)/2)/32)
				Scale+=10
				if(Get_Width(I.icon)>=64)
					if(!can_fire_genki_dama) usr<<"The Genki Dama is now charged enough to fire"
					can_fire_genki_dama=1
				if(Get_Width(I.icon)>192) break

				if(usr.h2_overhead_gfx)
					usr.icon_state="2H Overhead Charge"

				sleep(3*usr.Speed_delay_mult(severity=0.5))
			if(!A||!A.z) return
		else if(can_fire_genki_dama)
			charging=1
			usr.attacking=0
			usr.overlays-='SBombGivePower.dmi'
			usr.Ki-=Drain
			usr.overlays-=usr.BlastCharge

			if(usr.h2_overhead_gfx)
				usr.icon_state=""

			flick("Attack",usr)
			player_view(10,usr)<<sound('basicbeam_fire.ogg',volume=15)
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
	verb/Hotbar_use()
		set hidden=1
		Death_Ball()
	verb/Death_Ball()
		set category="Skills"
		if(usr.cant_blast()) return
		if(usr.attacking||usr.Ki<Drain||charging) return
		var/turf/t=Get_step(usr,NORTH)
		if(t)
			var/obstacle
			for(var/obj/o in t) if(o.density)
				obstacle=1
				break
			if(t.density) obstacle=1
			if(obstacle)
				usr<<"You can not use this here because there is an obstacle above you"
				return
		if(!IsCharged)
			Experience=1

			if(usr.h2_overhead_gfx)
				usr.icon_state="2H Overhead Charge"

			Skill_Increase(5,usr)
			player_view(10,usr)<<sound('basicbeam_charge.ogg',volume=20)
			var/obj/Blast/Genki_Dama/A=new(usr.loc)
			A.y+=2
			if(!A||!A.z) return
			A.set_stats(usr,Percent=63,Off_Mult=4,Explosion=5)
			A.from_attack=src
			A.icon=Scaled_Icon(icon,72,72)
			Center_Icon(A)
			//A.icon+=rgb(0,0,0,200)
			A.Size=1
			usr.attacking=3
			charging=1
			sleep(To_tick_lag_multiple(26*usr.Speed_delay_mult(severity=0.3)))
			charging=0
			IsCharged=1
			usr.overlays+=usr.BlastCharge
			usr.attacking=0
		else

			if(usr.h2_overhead_gfx)
				usr.icon_state=""

			IsCharged=0
			usr.Ki-=Drain
			usr.overlays-=usr.BlastCharge
			flick("Attack",usr)
			charging=1
			player_view(10,usr)<<sound('basicbeam_fire.ogg',volume=15)
			var/obj/Blast/Genki_Dama/A
			for(var/obj/Blast/Genki_Dama/B) if(B.Owner==usr) A=B
			while(A&&usr&&getdist(A,usr)<20&&!A.deflected)
				step(A,usr.dir)
				sleep(2)
			charging=0
mob/var/tmp/shockwaving
obj/Attacks/Shockwave
	teachable=1
	hotbar_type="Ability"
	can_hotbar=1
	Cost_To_Learn=3
	Teach_Timer=0.5
	Drain=15
	desc="This emits a shockwave that will knockback anyone within range, dealing some damage. It does \
	damage based on your strength + force, compared to the target's durability + resistance"
	verb/Hotbar_use()
		set hidden=1
		Shockwave()
	verb/Shockwave()
		set category="Skills"
		if(usr.beaming||usr.Beam_stunned()) return
		if(usr.tournament_override(fighters_can=1)) return
		if(usr.cant_blast()) return
		if(usr.dash_attacking||usr.Ki<usr.Skill_Drain(src)) return
		if(world.time<usr.next_shockwave)
			var/seconds=(usr.next_shockwave-world.time)/10
			usr<<"You can not use this for another [round(seconds,0.1)] seconds"
			return
		usr.Release_grab()
		Skill_Increase(1.5,usr)
		usr.Ki-=usr.Skill_Drain(src)
		//usr.attacking=3
		usr.shockwaving=1
		var/Amount=5
		player_view(10,usr)<<sound('wallhit.ogg',volume=25)
		spawn if(usr) while(Amount)
			Amount-=1
			Make_Shockwave(usr,7,sw_icon_size=256)
			for(var/turf/T in oview(7,usr))
				if(prob(10)&&!T.density&&!T.Water)
					var/Dirts=prob(40)
					while(Dirts)
						Dirts-=1
						var/image/I=image(icon='Damaged Ground.dmi',pixel_x=rand(-16,16),pixel_y=rand(-16,16))
						T.overlays+=I
						T.Remove_Damaged_Ground(I)
			spawn for(var/mob/P in mob_view(10,usr)) if(P.z&&P!=usr&&P.grabbed_mob!=usr)
				if(!P.AOE_auto_dodge(usr,usr.loc))
					var/Distance=5*(((usr.Pow+usr.Str)/(P.Res+P.End))**0.5)*((usr.BP/P.BP)**0.5)
					Distance=round(Distance)
					if(Distance>30) Distance=30
					P.Shockwave_Knockback(Distance,usr.loc)
					var/dmg=1*(usr.BP/P.BP)**0.5*((usr.Pow+usr.Swordless_strength())/(P.Res+P.End))**0.4 * (ki_power+melee_power)/2

					dmg*=sagas_bonus(usr,P)
					usr.training_period(P)

					if(P.ki_shield_on())
						dmg*=(P.max_ki/100)*shield_reduction/(P.Eff**shield_exponent)*P.Generator_reduction()
						P.Ki-=dmg
					else P.Health-=dmg
					spawn if(P&&P.drone_module) P.Drone_Attack(usr,lethal=1)
			spawn if(usr)
				var/n=0
				for(var/obj/O in view(7,usr)) if(O.z&&!O.Bolted&&!istype(O,/obj/Turfs/Door))
					n++
					if(n>10) break
					if(O.Health<=usr.BP) del(O)
					if(O) O.Shockwave_Knockback(10,usr.loc)
			sleep(4)
			if(!Amount&&usr) usr.shockwaving=0
		if(usr) usr.next_shockwave=world.time + 80 * usr.Speed_delay_mult(severity=0.25)
mob/var/tmp/next_shockwave=0
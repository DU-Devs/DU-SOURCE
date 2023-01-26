obj/Skills/Combat/Ki/var/burnMod = 1

obj/Skills/Combat/Ki/Buster_Barrage
	Drain=20
	Teach_Timer=2
	student_point_cost = 20
	Cost_To_Learn=7
	Experience=1

	burnMod = 2

	//icon='Shield, Legendary.dmi'
	icon = 'Green Ball 2017.dmi'

	desc="An attack which shoots energy from all parts of your body in random directions."
	Explosive=1
	Shockwave=1
	var
		tmp
			Barraging
			lastBlastSfx = 0

	verb/Hotbar_use()
		set hidden=1
		Buster_Barrage()

	verb/Buster_Barrage()
		set category = "Skills"
		usr.Buster_Barrage(src)

mob/proc/Buster_Barrage(obj/Skills/Combat/Ki/Buster_Barrage/B)
	if(!B) for(var/obj/Skills/Combat/Ki/Buster_Barrage/C in ki_attacks) B=C
	if(!B) return
	if(B.Barraging)
		B.Barraging=0
		return
	if(cant_blast()) return
	attacking=3
	var/Delay = 0.75 * Speed_delay_mult(severity=0.5) + 1.35
	if(!client) Delay=1
	B.Experience+=0.05

	//var/trans_size = 64 / GetHeight(B.icon)

	//overlays += 'Shield, Legendary.dmi'
	var/obj/o = new
	o.icon = 'Green Ball 2017.dmi'
	CenterIcon(o)
	o.transform *= 0.5
	o.alpha = 200
	overlays += o

	B.Barraging=1

	while(B.Barraging && !cant_blast(ignore_attack_check = 1) && Ki>=GetSkillDrain(mod = B.Drain, is_energy = 1))
		if(world.time - B.lastBlastSfx > 1.5)
			player_view(10,src)<<sound('Blast.wav',volume=10)
			B.lastBlastSfx = world.time
		B.Skill_Increase(1,src)
		IncreaseKi(-GetSkillDrain(mod = B.Drain, is_energy = 1))
		var/obj/Blast/A=get_cached_blast()

		var/dmg_pct = 5
		if(Class == "Legendary") dmg_pct *= 1.5

		A.setStats(src,Percent = dmg_pct,Off_Mult=1,Explosion=0, burn_mod = B.burnMod)
		A.weaker_obstacles_cant_destroy_blast = 1
		A.from_attack=B
		A.Distance = 250
		A.icon = B.icon

		//A.transform = matrix() * trans_size

		CenterIcon(A)
		A.pixel_x+=rand(-10,10)
		A.pixel_y+=rand(-10,10)
		A.Shockwave=3
		A.step_size = 32
		if(prob(10)) A.Explosive=2
		A.dir=pick(NORTH,SOUTH,EAST,WEST,NORTHEAST,NORTHWEST,SOUTHEAST,SOUTHWEST)
		A.loc=loc
		A.Buster_Barrage_Move()
		sleep(TickMult(Delay))

	attacking=0
	B.Barraging=0

	//overlays -= 'Shield, Legendary.dmi'
	overlays -= o

obj/proc/Buster_Barrage_Move()
	set waitfor=0
	step(src,dir)
	sleep(1)
	var/mob/m=Owner
	while(src&&z&&Owner==m)
		if(ismob(Owner) && getdist(src,Owner) <= 2) step_away(src,Owner)
		else if(Owner && get_dist(src, Owner) > 17) step_towards(src, Owner)
		else
			step(src,dir)
			if(prob(50)) dir = pick(dir, turn(dir,45), turn(dir,-45))
		sleep(TickMult(0.7))

atom/var/Fatal=0

mob/verb/Ki_Toggle()
	set category="Other"
	set hidden = TRUE
	if(IsTournamentFighter())
		src.SendMsg("Your attacks can not be set to lethal in the tournament", CHAT_IC)
		return
	Fatal=!Fatal
	if(Fatal) src.SendMsg("Your attacks are now lethal.", CHAT_IC)
	else src.SendMsg("Your attacks are now non-lethal.", CHAT_IC)

obj/var/Mastery=1

var/list/Blasts=new

proc/AddBlasts()
	set waitfor = FALSE
	set background = TRUE
	for(var/A in typesof(/obj/Blasts))
		if(A!=/obj/Blasts)
			Blasts+=new A

obj/var/tmp/iconSize = 32

obj/proc/AssignIconSize()
	iconSize = GetHeight(icon)

obj/Blasts
	icon_state="head"
	Givable=0
	Makeable=0

	Click()
		icon = initial(icon)
		var/Color=input("Choose a color. Hit Cancel to have default color.") as color|null
		if(!usr) return
		if(Color) icon += Color
		var/list/C=new
		for(var/obj/Skills/Combat/Ki/D in usr.ki_attacks) if(D.type!=/obj/Skills/Combat/Ki/Time_Freeze) C+=D
		var/obj/Skills/Combat/Ki/A=input("Give this icon to which attack?") in C
		if(usr && A)
			A.icon=image(icon=icon,icon_state=icon_state)

			A.AssignIconSize()

		icon = initial(icon)

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
	Blast99 icon = 'Green Ball 2017.dmi'
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
	var
		Scale
		auraYoffset = 0
	Click()
		icon=initial(icon)
		if(Scale) icon=Scaled_Icon(icon,Scale,Scale)
		var/C=input("Choose a color. Hit cancel to have default color.") as color|null
		if(!usr||!usr.Auras) return
		if(C) icon+=C
		usr.FlightAura='Aura Fly.dmi'
		if(C) usr.FlightAura+=C
		usr.Auras.icon=image(icon=icon,icon_state=icon_state)
		usr.Auras.auraYoffset = auraYoffset
	None
	BlueFlameAura
		icon = 'Blue Flame Aura.dmi'
	SuperBuu
		icon = 'blurredsuperbuuaura.dmi'
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
	Fire_Aura
		icon = 'Fire Aura.dmi'
		auraYoffset = -19

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
obj/Skills/Combat/Ki/var
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
mob/var/tmp/obj/Skills/Combat/Ki/Blast/blast_obj

obj/Skills/Combat/Ki/Blast
	Drain = 1.3
	Teach_Timer=0.5
	student_point_cost = 10
	Cost_To_Learn=2
	Experience=1
	burnMod = 0.8
	var/Spread=1
	var/Blast_Count=1
	var/blast_refire=1
	var/blast_velocity=1
	icon='1.dmi'
	desc="Fire blasts rapidly"
	repeat_macro=1

	var
		tmp
			last_retarget = 0
			mob/last_blast_targ
			lastBlastSfx = 0

	New()
		spawn if(ismob(loc))
			var/mob/m=loc
			m.blast_obj=src
		Recalculate_blast_drain()
		. = ..()

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
							Explosive=1
				if("Amount of blasts")
					Blast_Count=input("Amount of blasts? 1 to 4. More blasts increases drain heavily") as num
					if(Blast_Count<1) Blast_Count=1
					if(Blast_Count>4) Blast_Count=4
					Blast_Count=round(Blast_Count)
				if("Refire")
					var/max=1
					blast_refire=input("Blast refire: 0.2 to [max]. The slower the more powerful. If you disable \
					exploding blasts you can set the refire higher") as num
					if(blast_refire>max) blast_refire=max
					if(blast_refire<0.2) blast_refire=0.2
			Recalculate_blast_drain()

	proc/Recalculate_blast_drain()
		Drain=initial(Drain)
		if(Spread>1) Drain += initial(Drain) * 1
		if(Explosive) Drain += initial(Drain) * 1
		if(Stun) Drain += initial(Drain) * 1.5
		Drain *= 1 / blast_refire

	verb/Hotbar_use()
		set hidden=1
		usr.Blast_macro()

	verb/Blast()
		set category = "Skills"
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
		while(blast_obj && (k in keys_down))
			Blast_Fire(blast_obj)
			sleep(get_blast_refire())
	blast_fire_loop=0

mob/proc/get_blast_refire()
	if(!blast_obj) return 1
	var/mod = 1
	if(CheckForInjuries() && GetInjuryTypeCount(/injury/fracture/left_arm))
		mod *= 1.05
	if(CheckForInjuries() && GetInjuryTypeCount(/injury/fracture/right_arm))
		mod *= 1.05
	return TickMult((1 / blast_obj.blast_refire * Speed_delay_mult(severity=0.25)) * (src.HasTrait("Quickfire Ki") ? 0.5 : 1) * mod)

mob/proc/get_shuriken_refire()
	return TickMult(2.4 * Speed_delay_mult(severity=0.3))

mob/proc/Blast_Fire(obj/Skills/Combat/Ki/Blast/B)

	//return //disabled to see if it is crashing things

	if(!B) B=blast_obj
	if(!B) for(var/obj/Skills/Combat/Ki/Blast/C in ki_attacks) B=C
	if(!B) return

	B.Blast_Count = 1
	B.Blast_Count = ToOne(B.Blast_Count)

	if(beaming || Beam_stunned()) return
	if(cant_blast()) return
	if(Ki<GetSkillDrain(mod = B.Drain, is_energy = 1)) return
	B.Skill_Increase(1/B.blast_refire,src)
	attacking=3
	var/Delay=get_blast_refire()
	if(!client) Delay=1
	spawn(Delay) attacking=0
	B.Experience+=0.05/B.blast_refire
	if(world.time - B.lastBlastSfx > 1.5)
		B.lastBlastSfx = world.time
		player_view(10,src) << sound('Blast.wav',volume = 10)

	var/Amount = B.Blast_Count
	//PROBLEM: i commented out these lines because it makes up close blasting way too OP. if you set it to barrage, as long as you fire
	//them up close, you do 2x damage compared to normal blast. literally took 80% of my health in 2 seconds when i got caught up close
	//if(B.Spread==2) Amount=ToOne(Amount * 1.35)
	//if(B.Spread==3) Amount=ToOne(Amount * 2)

	while(Amount)

		IncreaseKi(-GetSkillDrain(mod = B.Drain, is_energy = 1))

		var/obj/Blast/A = get_cached_blast()
		var/percent = 1.5 / B.blast_refire ** 0.75 //was 3
		var/off_mod = 1 //was 1
		if(B.Stun) percent *= 1
		//if(B.Spread==3) off_mod*=0.7
		A.Stun = B.Stun
		A.setStats(src, Percent=percent, Off_Mult=off_mod, Explosion=0, burn_mod = B.burnMod)
		var
			base_speed = 32
			max_speed_bonus = 32 - base_speed
			step_speed = base_speed + (max_speed_bonus / Speed_delay_mult(severity = 0.5))
		A.step_size = step_speed

		A.from_attack=B
		//A.Distance=150
		A.icon=B.icon
		CenterIcon(A)
		/*spawn(2) if(A)
			A.pixel_x+=rand(-14,14)
			A.pixel_y+=rand(-14,14)*/
		A.Shockwave = ToOne(1.4 * B.Shockwave / B.blast_refire**0.4)
		if(prob(100)) A.Explosive=B.Explosive
		A.dir = dir

		A.SafeTeleport(loc)

		//prevent bug where you can apparently fire thru walls if you zig zag back and forth near it spamming blast
		var/turf/t = get_step(A.loc, A.dir)
		if(!t || t.density) A.step_size = 32

		//A.Blast_Move(B, src, skip_first_delay = 1)

		//this stuff is mostly the same as BlastAutoTargetFire() but i had to change it to limit the retargeting rate since this fires way more blasts
		//at once than BlastAutoTargetFire() was intended for, it would lag.
		A.bound_height = 16
		A.bound_width = 16
		A.bound_y = (32 - A.bound_height) / 2
		A.bound_x = (32 - A.bound_width) / 2
		A.Can_Home = 0
		A.step_size = 44
		A.Distance = 47
		var/angle = dir_to_angle_0_360(A.dir)
		var/mob/targ
		if(world.time - B.last_retarget > 3)
			targ = A.GetBlastHomingTarget(dir, angle = 18)
			B.last_retarget = world.time
			if(targ) B.last_blast_targ = targ
		else if(B.last_blast_targ && A.Is_viable_homing_target(B.last_blast_targ)) targ = B.last_blast_targ
		if(targ) angle = get_global_angle(A,targ)
		angle += rand(-4,4)
		A.BlastVectorWalk(angle)

		Amount--

//this just gives the blast a target when it is first spawned and makes it take a pixel vector directly to that target
obj/Blast/proc/BlastAutoTargetGo(boundWidth = 32, boundHeight = 32, stepSize = 44, angleLimit = 18, dist = 47, randomAngle = 0)
	set waitfor=0
	Can_Home = 0 //old system interferes with this new system and makes it look bad too
	bound_height = boundHeight
	bound_width = boundWidth
	bound_y = (32 - bound_height) * 0.5
	bound_x = (32 - bound_width) * 0.5
	step_size = stepSize
	Distance = dist
	var/angle = dir_to_angle_0_360(dir)
	var/mob/targ = GetBlastHomingTarget(dir, angle = angleLimit)
	if(targ) angle = get_global_angle(src, targ)
	angle += rand(-randomAngle, randomAngle)
	BlastVectorWalk(angle)

obj/Blast/proc/BlastVectorWalk(angle = 0)
	set waitfor=0
	sleep(world.tick_lag) //JUNE 12 2019
	while(z && !deflected && in_use)
		vector_step(src, angle)
		sleep(world.tick_lag)

obj/Blast/proc/Blast_Move(obj/Skills/Combat/Ki/Blast/b,mob/m, skip_first_delay)
	set waitfor=0
	var
		steps = 0
		spread_step = rand(1,4)

	if(b.Spread == 3) spread_step = rand(3,8)

	if(!skip_first_delay) sleep(world.tick_lag)

	while(src && z && !deflected)
		var/old_dir = dir
		if(b && b.Spread == 2 && steps == spread_step && prob(67))
			step(src,turn(dir,pick(-45,45)))
			dir = old_dir
		else if(b && b.Spread == 3 && steps == spread_step && prob(90))
			dir = pick(turn(dir,45),turn(dir,-45))
			step(src,dir)
		else step(src,dir)
		steps++
		sleep(world.tick_lag)

//avoid using this old ass proc whenever possible, it makes no sense
mob/proc/Disabled()
	return KO || KB || (Frozen && !paralysis_immune) || (Action in list("Meditating","Training"))

obj/Skills/Combat/Ki/Big_Bang_Attack
	Drain=80
	Teach_Timer=1
	student_point_cost = 20
	Cost_To_Learn=10
	Experience=1
	burnMod = 3
	icon='Big bang attack.dmi'
	desc="Basicly a more powerful version of the 'charge' ki attack"
	repeat_macro=1
	verb/Hotbar_use()
		set hidden=1
		Big_Bang()

	verb/Big_Bang()
		set category = "Skills"
		if(usr.cant_blast()) return
		if(usr.Ki<usr.GetSkillDrain(mod = Drain, is_energy = 1)) return
		if(prob(10)&&Experience<1) Experience+=0.1
		if(!usr) return
		usr.IncreaseKi(-usr.GetSkillDrain(mod = Drain, is_energy = 1))
		Skill_Increase(2,usr)
		usr.attacking=3
		usr.moving_charge=1
		usr.overlays+=usr.BlastCharge
		player_view(10,usr)<<sound('basicbeam_charge.ogg',volume=30)
		var/turf/fire_location=usr.loc
		sleep(TickMult(18 * usr.Speed_delay_mult(severity=0.4)) * (usr.HasTrait("Quickfire Ki") ? 0.5 : 1))
		usr.overlays-=usr.BlastCharge
		if(!usr.cant_blast(ignore_attack_check = 1))
			player_view(10,usr)<<sound('Blast.wav',volume=70)
			usr.Say("BIG BANG ATTACK!!")
			var/obj/Blast/A=get_cached_blast()
			if(!A) A = new
			var/dmg=54
			if(usr.loc==fire_location) dmg*=1.5
			A.setStats(usr,Percent=dmg,Off_Mult=1,Explosion=4, burn_mod = burnMod)
			A.from_attack=src
			A.Shockwave=1
			A.icon=icon
			A.dir=usr.dir
			A.loc=usr.loc
			A.BlastAutoTargetGo(boundWidth = 32, boundHeight = 32, stepSize = 44, angleLimit = 27, dist = 60, randomAngle = 0)
		usr.attacking=0
		charging=0

obj/Skills/Combat/Ki/Charge
	Drain=20
	Teach_Timer=0.1
	student_point_cost = 10
	Cost_To_Learn=1
	Experience=1
	burnMod = 2
	icon='20.dmi'
	desc="An explosive one-shot energy attack that takes a few seconds to charge."
	repeat_macro=1

	verb/Hotbar_use()
		set hidden=1
		Charge()

	verb/Charge()
		set category = "Skills"
		if(usr.cant_blast()) return
		if(usr.Ki<usr.GetSkillDrain(mod = Drain, is_energy = 1)) return
		if(prob(10)&&Experience<1) Experience+=0.1
		usr.IncreaseKi(-usr.GetSkillDrain(mod = Drain, is_energy = 1))
		Skill_Increase(2,usr)
		usr.attacking=3
		usr.moving_charge=1
		usr.overlays+=usr.BlastCharge
		player_view(10,usr)<<sound('basicbeam_charge.ogg',volume=20)
		var/turf/fire_location=usr.loc
		sleep(TickMult(7.5 * usr.Speed_delay_mult(severity=0.6)) * (usr.HasTrait("Quickfire Ki") ? 0.5 : 1))
		usr.overlays-=usr.BlastCharge
		if(!usr.cant_blast(ignore_attack_check = 1))
			player_view(10,usr)<<sound('Blast.wav',volume=40)
			var/obj/Blast/A=get_cached_blast()
			var/dmg=20
			if(usr.loc==fire_location) dmg*=1.5
			A.setStats(usr,Percent=dmg,Off_Mult=2,Explosion=2, burn_mod = burnMod)
			A.from_attack=src
			A.Shockwave=1
			A.icon=icon
			A.dir=usr.dir
			A.loc=usr.loc
			A.BlastAutoTargetGo(boundWidth = 32, boundHeight = 32, stepSize = 44, angleLimit = 20, dist = 47, randomAngle = 0)
		usr.attacking=0
		usr.moving_charge=0

obj/proc/blast_walk(delay=1,start_dir)
	set waitfor=0
	if(start_dir) dir=start_dir
	while(src&&z)
		step(src,dir)
		var/t = TickMult(delay)
		sleep(t)

mob/var/tmp/moving_charge
obj/Skills/Combat/Ki/New()
	spawn(5) if(src&&ismob(loc))
		var/mob/m=loc
		m.ki_attacks+=src
	spawn(10) if(src&&Wave)
		calculate_beam_drain()
		BeamDescription()
	spawn(50) if(src && icon && icon == initial(icon))
		icon += rgb(rand(0,255),rand(0,255),rand(0,255))
	. = ..()
obj/Skills/Combat/Ki/Cyber_Charge
	teachable=0
	Drain=10
	Teach_Timer=0.1
	student_point_cost = 15
	Cost_To_Learn=0
	Experience=1
	burnMod = 2.2
	Mastery=100
	icon='11.dmi'
	desc="This artificial attack is designed to mimic charge. It is a bit weaker but can be fired \
	twice as fast."
	repeat_macro=1
	verb/Hotbar_use()
		set hidden=1
		CyberCharge()
	verb/CyberCharge()
		set category = "Skills"
		if(usr.cant_blast()) return
		if(usr.Ki<usr.GetSkillDrain(mod = Drain, is_energy = 1)) return
		if(prob(10)&&Experience<1) Experience+=0.1
		usr.IncreaseKi(-usr.GetSkillDrain(mod = Drain, is_energy = 1))
		Skill_Increase(2,usr)
		usr.attacking=3
		charging=1
		usr.overlays+=usr.BlastCharge
		player_view(10,usr)<<sound('basicbeam_charge.ogg',volume=20)
		sleep(TickMult(5 * usr.Speed_delay_mult(severity=0.6)) * (usr.HasTrait("Quickfire Ki") ? 0.5 : 1))
		usr.overlays-=usr.BlastCharge
		if(!usr.cant_blast(ignore_attack_check = 1))
			player_view(10,usr)<<sound('Blast.wav',volume=30)
			var/obj/Blast/A=get_cached_blast()
			A.icon=icon
			A.setStats(usr,Percent=20,Off_Mult=2,Explosion=1, burn_mod = burnMod)
			A.from_attack=src
			A.step_size = 32 * 1
			A.dir=usr.dir
			A.loc=usr.loc
			//step(A,A.dir)
			if(A) A.blast_walk(world.tick_lag)
		usr.attacking=0
		charging=0

obj/Skills/Combat/Ki/Kienzan
	icon='Blast - Destructo Disk.dmi'
	Cost_To_Learn=3
	Teach_Timer=1
	student_point_cost = 20
	burnMod = 0.5
	desc="A guidable energy disk"
	var/tmp/Kienzan_Delay=0.85
	Drain=100
	repeat_macro=1

	verb/Hotbar_use()
		set hidden=1
		Kienzan()

	verb/Kienzan()
		set category = "Skills"
		if(usr.cant_blast()) return
		if(!usr.move || usr.Ki<usr.GetSkillDrain(mod = Drain, is_energy = 1)) return
		var/turf/t=Get_step(usr,NORTH)
		if(t)
			var/obstacle
			for(var/obj/o in t) if(o.density&&!istype(o,/obj/Blast))
				obstacle=1
				break
			if(t.density) obstacle=1
			if(obstacle)
				usr.SendMsg("You can not use this here because there is an obstacle above you.", CHAT_IC)
				return
		Using=1
		if(!usr) return
		usr.attacking=3
		if(usr.h1_overhead_gfx)
			usr.icon_state="1H Overhead Charge"
		usr.IncreaseKi(-usr.GetSkillDrain(mod = Drain, is_energy = 1))
		Skill_Increase(3,usr)
		player_view(10,usr)<<sound('destructodisc_charge.ogg',volume=35)

		var/obj/Blast/A=get_cached_blast()
		A.Sokidan=1
		A.Distance=180
		A.blast_go_over_obstacles_if_cant_destroy = 1
		A.icon=icon
		A.loc=Get_step(usr,NORTH)
		A.Shockwave=0
		A.Piercer=1
		A.slice_attack=1
		var/dmgPercent = 45
		if(usr.Race == "Human") dmgPercent *= 1.5
		A.setStats(usr,Percent = dmgPercent, Off_Mult = 15, Explosion = 0, burn_mod = burnMod)
		A.from_attack=src
		A.step_size = 22
		A.weaker_obstacles_cant_destroy_blast = 1

		sleep(TickMult(12*usr.Speed_delay_mult(severity=0.3)))
		if(!usr) return
		if(usr && usr.h1_overhead_gfx)
			usr.icon_state=""
		if(A)
			player_view(10,usr)<<sound('disc_fire.ogg',volume=35)
			if(usr.dir == SOUTH) A.density=0 //so it goes over the user without damaging them
			flick("Attack",usr)
			while(A && A.z && usr && getdist(A,usr) < 27 && !A.deflected)
				Using=1
				if(prob(87) && Owner && (Owner in Get_step(A,usr.dir)))
					step(A, pick(turn(usr.dir,45),turn(usr.dir,-45)))
				else step(A,usr.last_direction_pressed)
				if(A) A.density=1
				if(usr.KO && A) del(A)
				if(!usr) del(A)
				sleep(world.tick_lag)
			if(A&&A.z) walk(A,A.dir)
		Using=0
		if(usr) usr.attacking=0

obj/Time_Freeze_Energy
	var/TF_Timer=600
	var/ID
	New() TF_Delete()
	Del()
		var/mob/M=loc
		if(ismob(M))
			M.Frozen=0
			M.overlays-='TimeFreeze.dmi'
		. = ..()
	proc/TF_Delete()
		set waitfor=0
		sleep(1) //sleep long enough to let TF_Timer actually be set to something
		sleep(TF_Timer)
		if(src) del(src)

mob/var/tmp/list/Active_Freezes=new

mob/proc/Fill_Active_Freezes_List()
	for(var/mob/P in players) for(var/obj/Time_Freeze_Energy/T in P) if(T.ID==key) Active_Freezes+=T

obj/Skills/Combat/Ki/Time_Freeze
	desc="This will send paralyzing energy rings all around nearby people and they will not be able \
	to move until it wears off. The more BP and force you have compared to your opponent's BP and resistance, the \
	longer it will last."
	teachable=0
	hotbar_type="Ability"
	can_hotbar=1
	Cost_To_Learn=0
	Teach_Timer=9
	student_point_cost = 60
	var/tmp/time_freeze_timer=0
	repeat_macro=1

	verb/Hotbar_use()
		set hidden=1
		Time_Freeze()

	verb/Time_Freeze()
		set category = "Skills"
		if(usr.attacking||usr.tournament_override(fighters_can=1)) return
		if(usr.Frozen) return
		if(usr.KO) return
		if(time_freeze_timer>0)
			usr.SendMsg("You can not use this for another [time_freeze_timer] seconds.", CHAT_IC)
			return
		for(var/obj/Time_Freeze_Energy/T) if(T.ID==usr.key)
			usr.SendMsg("You can not use this until it has worn off from everyone affected by the previous time you used this.", CHAT_IC)
			return
		usr.overlays-='TimeFreeze.dmi'
		usr.overlays+='TimeFreeze.dmi'
		spawn(10) usr.overlays-='TimeFreeze.dmi'
		time_freeze_timer=ToOne(60*usr.Speed_delay_mult(severity=0.5))

		spawn while(src&&time_freeze_timer>0)
			time_freeze_timer--
			sleep(10)

		for(var/mob/A in mob_view(15,usr)) if(A!=usr&&!A.Frozen&&A.client)
			if(getdist(usr,A)<=12) if(get_dir(usr,A) in list(usr.dir,turn(usr.dir,45),turn(usr.dir,-45)))
				player_view(10,usr)<<sound('reflect.ogg',volume=10)
				A.Frozen=1
				Missile('TimeFreeze.dmi',usr,A)
				A.overlays-='TimeFreeze.dmi'
				A.overlays+='TimeFreeze.dmi'
				var/obj/Time_Freeze_Energy/T=new
				A.contents+=T
				usr.Active_Freezes+=T
				T.ID=usr.key
				T.TF_Timer = (50 + (usr.GetStatMod("For") * usr.GetTierBonus(0.5)) - (A.GetStatMod("Res") * A.GetTierBonus(0.75) * (1 + A.recov / 2)))
				T.TF_Timer /=  A.stun_resistance_mod
				T.TF_Timer = Math.Min (T.TF_Timer, 600)
				sleep(10*usr.Speed_delay_mult(severity=0.5))

obj/Skills/Combat/Ki/Explosion
	var/On
	hotbar_type="Ability"
	can_hotbar=1
	desc="This attack causes an explosion on the ground, the more you use it the bigger the explosion"
	Cost_To_Learn=2
	Teach_Timer=0.5
	student_point_cost = 20
	Experience=0
	Level=5
	burnMod = 5

	New()
		if(Level>5) Level=5
		. = ..()

	verb/Hotbar_use()
		set hidden=1
		Explosion_Toggle()

	verb/Explosion_Toggle()
		set category = "Skills"
		if(!On)
			usr.SendMsg("Explosion skill is now activated, click the ground to trigger.", CHAT_IC)
			On=1
		else
			usr.SendMsg("Explosion deactivated. Now when you click the ground you will warp there instead.", CHAT_IC)
			On=0

//mob/var/tmp/last_scattershot=0 //world.time

mob
	var
		tmp
			using_scattershot
			lastStopScattershot = -9999

mob/proc
	TryScatterShot(obj/Skills/Combat/Ki/Scatter_Shot/s)
		if(using_scattershot)
			StopScatterShotting(s)
		else
			if(!CanScatterShot(s))
				return
			src << "<font color=cyan>Click again to stop"
			ScatterShot(s)

	CanScatterShot(obj/Skills/Combat/Ki/Scatter_Shot/s)
		if(world.time - lastStopScattershot < 25) return //because theres a bug where if you just spam the scattershot verb you do this sure rapid fire homing blast thing
			//that will rek almost anyone
		if(using_scattershot || beaming || Beam_stunned() || cant_blast()) return
		if(Ki < GetSkillDrain(mod = s.Drain, is_energy = 1)) return
		return 1

	StopScatterShotting(obj/Skills/Combat/Ki/Scatter_Shot/s)
		if(!using_scattershot)
			return
		src << "<font color=cyan>You stop using Scatter Shot"
		using_scattershot = 0
		lastStopScattershot = world.time
		attacking = 0
		overlays -= BlastCharge
		AlterInputDisabled(-1)
		for(var/obj/Blast/b in s.scatter_shot_blasts)
			if(b.z && b.Owner == src)
				if(ScatterShotInterrupted(s, ignore_low_ki = 1)) b.ScatterShotInterruptedFlyOff()
				else b.ScatterShotAttackTarget()

	ScatterShotInterrupted(obj/Skills/Combat/Ki/Scatter_Shot/s, ignore_low_ki)
		if(KO || knock_dist >= 5 || stun_level || Frozen || cant_blast(ignore_attack_check = 1)) return 1
		if(!ignore_low_ki && Ki < GetSkillDrain(mod = s.Drain, is_energy = 1)) return 1

	ScatterShot(obj/Skills/Combat/Ki/Scatter_Shot/s)
		for(var/obj/Blast/b in s.scatter_shot_blasts) if(!b.z || b.Owner != src) s.scatter_shot_blasts -= b
		AlterInputDisabled(1)
		attacking = 3
		using_scattershot = 1
		overlays += BlastCharge
		player_view(10,src) << sound('basicbeam_charge.ogg', volume = 20)
		//var/charge_delay = TickMult(15 + (3 * Speed_delay_mult(severity = 0.5)))
		//sleep(charge_delay)
		overlays -= BlastCharge

		FireScatterShotsLoop(s)
		StopScatterShotting(s)

	FireScatterShotsLoop(obj/Skills/Combat/Ki/Scatter_Shot/s)
		var
			refire = 1 + (1 * Speed_delay_mult(severity = 0.5)) * 0.5
			last_retarget = 0
			mob/target
			shots_fired = 0
		refire *= 0.75 //arbitrary
		while(using_scattershot)
			if(ScatterShotInterrupted(s)) break
			else
				if(world.time - last_retarget > 6)
					target = LungeTarget(dist_override = 21) //will be null if no target found
					last_retarget = world.time
				if(!knock_dist) //temporarily interrupted
					NewScatterShotBlast(target, s)
					shots_fired++
				if(shots_fired > 100)
					//using_scattershot = 0 //i turned this line off because it seems to stop you from ever being allowed to fire the scattershots you already made thus bugging you until you relog
					break
				sleep(TickMult(refire))

	NewScatterShotBlast(mob/m, obj/Skills/Combat/Ki/Scatter_Shot/s)
		set waitfor=0
		if(!m) return
		flick("Attack",src)
		player_view(10,src) << sound('Blast.wav', volume = 10)
		IncreaseKi(-GetSkillDrain(mod = s.Drain, is_energy = 1))

		var/obj/Blast/b = get_cached_blast()
		s.scatter_shot_blasts += b
		//Percent was 3.7 before they asked me to buff it
		b.setStats(src, Percent = 5, Off_Mult = 1, Explosion = 3, homing_mod = 2, burn_mod = s.burnMod)
		b.Distance = 150
		b.pixel_x += rand(-6,6)
		b.pixel_y += rand(-6,6)
		b.weaker_obstacles_cant_destroy_blast = 1
		b.icon = s.icon
		b.Shockwave = 1
		b.from_attack = s
		b.SafeTeleport(loc)
		b.scattershot_target = m
		b.blast_go_over_owner = 1
		b.pass_over_owners_blasts = 1
		b.skip_all_collisions = 1
		b.transform *= rand(85,115) / 100
		b.Can_Home = 0

		var/list/l = Circle(13, m, viewable_only = 1)
		for(var/turf/t in l) if(t.density) l -= t
		if(l && l.len) //avoid "pick from empty list" error spam
			var/turf/t = pick(l)
			if(t) b.ScatterShotGoTo(t)

obj/Blast
	var
		tmp
			scattershot_attacking_target //if the blast is already trying to go at and hit the target
			mob/scattershot_target

	proc
		ScatterShotGoTo(turf/t)
			set waitfor=0
			step_size = 19
			while(loc != t && z && !scattershot_attacking_target)
				density = 0
				vector_step(src, get_global_angle(src,t), step_size)
				density = 1
				if(pixel_dist(src,t) * 32 <= step_size) break
				sleep(world.tick_lag)

		ScatterShotInterruptedFlyOff()
			set waitfor=0
			scattershot_attacking_target = 1
			Offense = 1
			dir = pick(NORTH,SOUTH,EAST,WEST,NORTHWEST,NORTHEAST,SOUTHWEST,SOUTHEAST)
			walk_rand(src)

		ScatterShotAttackTarget()
			set waitfor=0
			scattershot_attacking_target = 1
			skip_all_collisions = 0
			var/mob/m = scattershot_target
			if(!m || m.z != z)
				ScatterShotInterruptedFlyOff()
				return
			step_size = rand(19,25)
			var/angle = get_global_angle(src,m)
			while(z)
				vector_step(src, angle, step_size)
				sleep(world.tick_lag)

obj/Skills/Combat/Ki/Scatter_Shot
	Drain = 30
	Teach_Timer=1
	student_point_cost = 35
	Cost_To_Learn=6
	burnMod = 10
	icon='17.dmi'
	desc="This will create multiple homing balls all around an opponent, and when its done they will \
	all collide at once on top of them. Individually each ball is weak, but all together it can be \
	extremely devastating to most people. The more energy you get the more balls you can make at once."
	var/Setting=30
	var/tmp/list/scatter_shot_blasts=new

	repeat_macro = 0

	New()
		Drain = initial(Drain)
		. = ..()

	verb/Hotbar_use()
		set hidden=1
		//Scatter_Shot()
		usr.TryScatterShot(src)

	verb/Scatter_Shot()
		set category = "Skills"
		usr.TryScatterShot(src)

mob/var/tmp/lastSokidan = 0 //world.time

obj/var/tmp/Sokidan
obj/Skills/Combat/Ki/Sokidan
	icon='17.dmi'
	Teach_Timer=0.7
	student_point_cost = 25
	Cost_To_Learn=3
	burnMod = 1.2
	desc="This makes a very powerful guided bomb of energy that explodes on contact. If you can get it \
	to actually hit someone it is a very nice attack. It will move faster and faster as you master it."
	var/tmp/Sokidan_Delay=1
	Drain=20

	verb/Hotbar_use()
		set hidden=1
		Sokidan()

	verb/Sokidan()
		set category = "Skills"
		if(world.time - usr.lastSokidan < 20) return
		if(usr.cant_blast()) return
		if(!usr.move || usr.Ki<usr.GetSkillDrain(mod = Drain, is_energy = 1)) return
		var/turf/t=Get_step(usr,NORTH)
		if(t)
			var/obstacle
			for(var/obj/o in t) if(o.density&&!istype(o,/obj/Blast))
				obstacle=1
				break
			if(t.density) obstacle=1
			if(obstacle)
				usr.SendMsg("You can not use this here because there is an obstacle above you.", CHAT_IC)
				return
		Using=1

		if(!usr) return
		usr.attacking=3

		if(usr.h1_overhead_gfx)
			usr.icon_state="1H Overhead Charge"
		usr.IncreaseKi(-usr.GetSkillDrain(mod = Drain, is_energy = 1))
		Skill_Increase(3,usr)
		player_view(10,usr)<<sound('basicbeam_charge.ogg',volume=20)

		var/obj/Blast/A=get_cached_blast()
		A.Sokidan=1
		A.blast_go_over_obstacles_if_cant_destroy = 1
		A.Stun = 2
		A.Distance=180
		A.icon=icon
		A.loc=Get_step(usr,NORTH)
		A.Shockwave=2
		A.Piercer=0
		A.step_size = 22
		var/dmgPercent = 23
		if(usr.Race == "Human") dmgPercent *= 1.5
		A.setStats(usr,Percent = dmgPercent, Off_Mult = 3, Explosion = 2, homing_mod = 2, burn_mod = burnMod)
		A.from_attack=src
		A.weaker_obstacles_cant_destroy_blast = 1

		if(!usr) return

		sleep(TickMult(7*usr.Speed_delay_mult(severity=0.7)))
		if(usr.h1_overhead_gfx)
			usr.icon_state=""

		if(A && A.z)
			player_view(10,usr)<<sound('Blast.wav',volume=40)
			if(usr.dir == SOUTH) A.density=0
			flick("Attack",usr)
			var/controlling=1
			var/bumps=5

			while(A && A.z && usr && getdist(A,usr) < 25 && !A.deflected && controlling)
			//while(A && A.z && usr && getdist(A,usr) < 25 && controlling)
				Using=1
				if(locate(/mob) in Get_step(A,usr.dir))
					for(var/mob/m in Get_step(A,usr.dir))
						if(m == A.Owner && prob(85))
							step(A,pick(turn(A.dir,45),turn(A.dir,-45)))
						else
							//controlling=0
							var/bump_dir
							if(prob(50)) bump_dir=get_dir(m,usr)
							else bump_dir=pick(NORTH,SOUTH,EAST,WEST,NORTHWEST,NORTHEAST,SOUTHWEST,SOUTHEAST)
							A.Bump(m,override_delete=bumps,override_dir=bump_dir)
							if(A&&m) step_away(A,m)
							bumps--
				else step(A,usr.last_direction_pressed)
				if(A) A.density=1
				if(usr.KO&&A) del(A)
				sleep(world.tick_lag)

			if(A && A.z)
				//if(A.deflected) A.Distance=30
				walk(A,A.dir)

		Using=0
		usr.attacking=0
		usr.lastSokidan = world.time

var/list/small_crater_cache=new
var/list/big_crater_cache=new

proc/Small_crater(turf/t)
	var/obj/Crater/c
	if(small_crater_cache.len)
		c=small_crater_cache[1]
		small_crater_cache-=c
	else c=new
	c.loc=t
	Timed_Delete(c,50)
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
		//SetTransformSize(rand(90,110) / 100)
		//. = ..()

	Del()
		SmallCraterDel()

	proc
		SmallCraterDel()
			set waitfor=0
			var/anim_time = 20
			animate(src, alpha = 0, time = anim_time)
			sleep(anim_time + 1)
			alpha = 255
			SafeTeleport(null)
			transform = null
			small_crater_cache += src

proc/BigCrater(turf/pos, maxSize, growTime, fadeTime, minRangeFromOtherCraters)

	maxSize *= 0.2 //to compensate for the new updated icon we use now that is larger than before

	if(minRangeFromOtherCraters && locate(/obj/BigCrater) in view(minRangeFromOtherCraters, pos)) return
	if(locate(/obj/BigCrater) in pos) return //no need to ever stack a crater in the same exact place. laggy
	var/obj/BigCrater/c
	if(big_crater_cache.len)
		c = big_crater_cache[1]
		big_crater_cache -= c
		c.New()
	else c = new
	c.pixel_y -= 11 //was just a little to high looking
	c.alpha = 255
	if(maxSize) c.craterMaxSize = sqrt(maxSize)
	if(growTime) c.craterGrowTime = growTime
	if(fadeTime) c.craterFadeTime = fadeTime
	c.loc=pos
	c.CraterDeleteTimer()
	return c

obj/BigCrater
	icon = 'crater 2 stretch 2019.png'

	Dead_Zone_Immune=1
	Health=1.#INF
	Grabbable=0
	Savable=0
	Nukable=0
	Knockable=0
	attackable=0
	layer = DECAL_LAYER

	var
		craterMaxSize = 1
		craterGrowTime = 1.7
		craterFadeTime = 20

	New()
		CenterIcon(src)
		transform = matrix() * 0.01
		CraterNew()

		/*layer-=0.1
		var/image/A=image(icon='Craters.dmi',icon_state="N",pixel_y=32)
		var/image/B=image(icon='Craters.dmi',icon_state="S",pixel_y=-32)
		var/image/C=image(icon='Craters.dmi',icon_state="E",pixel_x=32)
		var/image/D=image(icon='Craters.dmi',icon_state="W",pixel_x=-32)
		var/image/E=image(icon='Craters.dmi',icon_state="NE",pixel_y=32,pixel_x=32)
		var/image/F=image(icon='Craters.dmi',icon_state="NW",pixel_y=32,pixel_x=-32)
		var/image/G=image(icon='Craters.dmi',icon_state="SE",pixel_y=-32,pixel_x=32)
		var/image/H=image(icon='Craters.dmi',icon_state="SW",pixel_y=-32,pixel_x=-32)
		overlays=null
		overlays.Add(A,B,C,D,E,F,G,H)*/
		//. = ..()

	Del()
		BigCraterDel()

	proc
		CraterNew()
			set waitfor=0
			sleep(world.tick_lag)
			animate(src, transform = matrix() * craterMaxSize * rand(75,115) / 100, time = craterGrowTime)

		CraterDeleteTimer()
			set waitfor=0
			sleep(craterGrowTime + 60)
			del(src)

		BigCraterDel()
			set waitfor=0
			var/anim_time = craterFadeTime
			animate(src, alpha = 0, time = anim_time)
			sleep(anim_time + 1)
			SafeTeleport(null)
			transform = null
			big_crater_cache += src

obj/Blast/Genki_Dama
	Piercer=0
	Explosive=20
	density=1
	Sokidan=1
	weaker_obstacles_cant_destroy_blast = 1

mob/var/tmp/shockwaving
obj/Skills/Combat/Ki/Shockwave
	teachable=1
	hotbar_type="Ability"
	can_hotbar=1
	Cost_To_Learn=3
	Teach_Timer=0.5
	student_point_cost = 15
	Drain=15
	burnMod = 0
	desc="This emits a shockwave that will knockback anyone within range, dealing some damage. It does \
	damage based on your strength + force, compared to the target's durability + resistance"
	repeat_macro=1

	verb/Hotbar_use()
		set hidden=1
		Shockwave()

	verb/Shockwave()
		set category = "Skills"
		if(usr.beaming||usr.Beam_stunned()) return
		if(usr.tournament_override(fighters_can=1)) return
		if(usr.cant_blast()) return
		if(usr.dash_attacking||usr.Ki<usr.GetSkillDrain(mod = Drain, is_energy = 1)) return
		if(world.time<usr.next_shockwave)
			var/seconds=(usr.next_shockwave-world.time)/10
			usr.SendMsg("You can not use this for another [round(seconds,0.1)] seconds.", CHAT_IC)
			return
		usr.ReleaseGrab()
		Skill_Increase(1.5,usr)
		usr.IncreaseKi(-usr.GetSkillDrain(mod = Drain, is_energy = 1))
		//usr.attacking=3
		usr.shockwaving=1
		var/Amount = 7
		player_view(10,usr)<<sound('wallhit.ogg',volume=25)
		spawn if(usr) while(Amount)
			Amount-=1
			Make_Shockwave(usr,7,sw_icon_size=256)
			for(var/turf/T in oview(7,usr))
				if(prob(10)&&!T.density&&!IsWater(T))
					var/Dirts=prob(40)
					while(Dirts)
						Dirts-=1
						var/image/I=image(icon='Damaged Ground.dmi',pixel_x=rand(-16,16),pixel_y=rand(-16,16))
						T.overlays+=I
			spawn for(var/mob/P in mob_view(10,usr)) if(P.z&&P!=usr&&P.grabbedObject!=usr)
				if(!P.AOE_auto_dodge(usr,usr.loc))
					var/Distance = 7 + (usr.GetStatMod("Str") + usr.GetStatMod("For")) * usr.GetTierBonus(0.5)
					Distance -= (P.GetStatMod("Res") + P.GetStatMod("Dur")) * P.GetTierBonus(0.25)
					Distance=round(Distance)
					if(Distance>30) Distance=30
					P.Shockwave_Knockback(Distance,usr.loc, bypass_immunity = 1)
					var/dmg = 1 + (usr.GetStatMod("Str") + usr.GetStatMod("For")) * usr.GetTierBonus(0.5)
					dmg -= (P.GetStatMod("Res") + P.GetStatMod("Dur")) * P.GetTierBonus(0.25)
					dmg = Math.Max(dmg, 1)

					if(P.IsShielding())
						dmg*=(P.max_ki/100) * P.ShieldDamageReduction() / (P.Eff**shield_exponent)*P.Generator_reduction()
						P.IncreaseKi(-dmg)
					else P.TakeDamage(dmg, usr)
					spawn if(P&&P.drone_module) P.Drone_Attack(usr,lethal=1)
			spawn if(usr)
				var/n=0
				for(var/obj/O in view(7,usr)) if(O.z && !O.Bolted && !istype(O,/obj/Turfs/Door))
					n++
					if(n>10) break
					if(istype(O,/obj/Blast))
						var/obj/Blast/b = O
						if(b.Beam)
							if(usr.BP > O.BP * 1.35) del(O)
							else n--
						else
							var/p = 80 * (usr.BP / O.BP)**0.4
							if(prob(p)) del(O)
							else n--
					else
						if(O.Health<=usr.BP) del(O)
						if(O) O.Shockwave_Knockback(10,usr.loc)
			sleep(5)

			if(!Amount&&usr) usr.shockwaving=0
		if(usr) usr.next_shockwave=world.time + 70 * usr.Speed_delay_mult(severity=0.25)

mob/var/tmp/next_shockwave=0
mob/proc/HasSkill(t)
	for(var/obj/O in src)
		if(O && O.type == t)
			return TRUE

obj/Skills/proc/operator~=(obj/Skills/other)
	return name == other.name

obj/items/proc/operator~=(obj/items/other)
	return name == other.name

obj/Skills
	can_hotbar = 1
	Buff
		hotbar_type="Buff"

	Combat
		Melee
			hotbar_type="Melee"
		Ki

	Divine
		race_teach_only=1
		hotbar_type=""
	
	Utility
		hotbar_type=""

obj/Skills/Utility/Hide_Energy
	teachable=1
	Skill=0
	Cost_To_Learn=0
	Teach_Timer=2
	student_point_cost = 25
	desc="Using this ability will cause you to be hidden from sense, observe, and teleports. The drawback \
	is that while using it your available bp is very low"
	New()
		delete_self()
	proc/delete_self()
		set waitfor=0
		sleep(10)
		if(src) del(src)
	verb/Hide_Energy()
		set category = "Skills"
		usr.hiding_energy=!usr.hiding_energy
		if(usr.hiding_energy)
			usr.SendMsg("You are now hiding your energy.", CHAT_IC)
			for(var/mob/m in players) if(m.client&&m.client.eye==usr&&!m.IsAdmin())
				m.SendMsg("[usr.name] has begun hiding their energy, you have lost the ability to observe them.", CHAT_IC)
				m.client.eye=m
		else usr.SendMsg("You are no longer hiding your energy.", CHAT_IC)
mob/var
	hiding_energy

obj/Skills/Combat/Melee/Dash_Attack
	teachable=1
	Skill=1
	hotbar_type="Melee"
	can_hotbar=1
	Cost_To_Learn=10
	Teach_Timer=1
	student_point_cost = 25
	desc="A melee finishing move where you dash in a line in front of you and anyone in that line will \
	be attacked and take damage. You can aim it by moving side to side. It does more damage if you hit \
	the target from behind, and more damage the further away you do it from"
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Dash_Attack()

	verb/Dash_Attack()
		set category = "Skills"
		usr.Dash_Attack()

mob/var/tmp
	dash_attacking
	desired_dash_dir
	original_dash_dir
	lastDashAttack = 0

mob/proc/Dash_Attack()

	var/turf/t = loc
	if(!istype(t,/turf)) return

	if(dash_attacking || lunge_attacking || grabbedObject || in_dragon_rush) return
	if(charging_final_explosion || charging_beam || beaming) return
	if(world.time - lastDashAttack < 60 / (Speed_delay_mult(severity = melee_delay_severity) / speedDelayMultMod)) return
	if(tournament_override()) return
	var/Drain = 145 * (max_ki / 3000)**0.5
	if(Ki<Drain)
		src.SendMsg("You do not have enough energy.", CHAT_IC)
		return
	if(Beam_stunned()) return
	dash_attacking = 1
	var/damage_mult = 0.35
	original_dash_dir=dir
	lastDashAttack = world.time
	for(var/steps in 1 to 15)
		if(KB) continue //causes a bug where the person hits the target many many times doing massive damage
		var/turf/old_loc=loc
		var/dash_dir=original_dash_dir
		if(desired_dash_dir&&round(steps/3)==steps/3)
			dash_dir=desired_dash_dir
			desired_dash_dir=0
		AlignToTile()
		step(src,dash_dir,32)
		var/mob/P
		if(loc==old_loc) for(P in Get_step(src,dir))
			SafeTeleport(P.loc)
			break
		else for(P in loc) if(P!=src) break
		if(loc==old_loc)
			break
		if(P && ismob(P))

			var/Damage = damage_mult * GetMeleeDamage(P) * steps
			var/Acc = GetAttackAccuracy(P) * 4
			Damage *= BP / P.BP

			var/KB_Distance = GetMeleeKnockbackDist(P) * 5
			if(prob(Acc))
				flick("Attack",src)
				if(P.IsShielding())
					P.IncreaseKi(-(Damage * P.ShieldDamageReduction() * (P.max_ki/100)/(P.Eff**shield_exponent)*P.Generator_reduction(is_melee=1)))
				else
					if(P.dir == dir) Damage *= 2 //hit from behind
					P.TakeDamage(Damage, src)
				if(P.Ki <= 0) P.KnockOut(src)
				if(P) P.DashAttackPart2(src, KB_Distance)
			else
				flick('Zanzoken.dmi',P)
				step(P,turn(dir,pick(90,-90)))
		AfterImage(20)
		damage_mult += 1
		sleep(TickMult(0.7 * Speed_delay_mult(severity=0.25)))
	IncreaseKi(-Drain)
	AlignToTile()
	dash_attacking=0

mob/proc/DashAttackPart2(mob/a, KB_Distance) //a = attacker
	set waitfor=0
	player_view(center=a)<<sound('strongpunch.ogg',volume=50)
	Make_Shockwave(src,sw_icon_size=pick(128,256))
	var/kb_dir=pick(turn(a.dir,45),turn(a.dir,-45))
	Knockback(A = a, Distance = KB_Distance, override_dir = kb_dir, bypass_immunity = 1)

mob/verb/Forget_Skill()
	//took it out of the tabs to remove clutter for new players. it doesnt really do anything now that skills never get bugged anymore
	set category = "Skills"
	var/N=0.9
	var/list/L=list("Cancel")
	for(var/obj/Skills/O in src) if(O.Cost_To_Learn) L+=O
	var/obj/Skills/O=input(src,"You can forget any skill you choose. If you learned the skill yourself you will get \
	[N*100]% of the skill points back. If you were taught you will not.") in L
	if(!O||O=="Cancel") return
	if(!O.Taught) Experience+=O.Cost_To_Learn*N
	del(O)

obj/var/Taught=1 //if 1, you did not self learn the skill

mob/proc/Destroy_Soul_Contracts(soul_percent=100)
	if(locate(/obj/Contract_Soul) in src)
		src.SendMsg("You have died. [soul_percent]% your soul contracts are now destroyed.", CHAT_IC)
		for(var/obj/Contract_Soul/C in src) if(prob(soul_percent))
			if(C.observed_mob) C.observed_mob.SendMsg("[src] has died and their contract on your soul has been destroyed.", CHAT_IC)
			C.reallyDelete = 1
			del(C)

obj/Contract_Soul //Appears in the Souls tab
	desc="Click this and you will be able to manipulate the soul. You do not need to RP any of these actions \
	because by accepting the contract they have already given you permission to do this at any time."
	var/Mob_ID
	var/tmp/mob/observed_mob
	var/presummon_x
	var/presummon_y
	var/presummon_z
	var/tpx //owners location before using temporary teleport
	var/tpy
	var/tpz
	var/Max_BP=0 //The max base bp the soul ever had, used for lowering/raising their bp
	var/tmp/Menu_Open
	Duplicates_Allowed=1
	clonable=0

	Click()
		if(loc != usr) return
		if(usr.IsFusion())
			usr.SendMsg("You can not manipulate souls while fused!")
			return
		if(!observed_mob)
			switch(input("They are offline. The only action you can do is to destroy the soul contract, do you want to \
			do this?") in list("No","Yes"))
				if("Yes") del(src)
			return
		if(observed_mob == usr)
			usr.SendMsg("Contract deleted. You can not use your own soul contract.", CHAT_IC)
			del(src)
			return
		if(observed_mob.IsFusion())
			usr.SendMsg("You can not manipulate a fused soul!")
			return
		if(usr.KO)
			usr.SendMsg("You are powerless to do this right now!", CHAT_IC)
			return
		var/list/L=list("Cancel","Permanent Teleport","Temporary Teleport","Teleport Back","Permanent Summon",\
		"Temporary Summon","Send back","Kill","Absorb","Knock out","Leech soul","Alter soul's BP",\
		"Use soul to extend your decline","Soul Info",/*"Take their soul contracts",*/"Destroy their soul contracts",\
		"Destroy contract")
		if(presummon_x) L-="Temporary Summon"
		else L-="Send back"
		if(tpx) L-="Temporary Teleport"
		else L-="Teleport Back"
		switch(input("What do you want to do to the soul of [observed_mob]?") in L)
			if("Cancel") return

			if("Destroy their soul contracts")
				var/list/C=list("Cancel","All")
				for(var/obj/Contract_Soul/CS in observed_mob) C+=CS
				var/obj/S=input("Which of their Soul Contracts do you want to destroy?") in C
				if(!S||S=="Cancel") return
				if(S=="All")
					usr.SendMsg("All of [observed_mob.name]'s soul contracts have been destroyed.", CHAT_IC)
					observed_mob.SendMsg("[usr.name] has used the soul contract on you to destroy all of your soul contracts.", CHAT_IC)
					for(var/obj/Contract_Soul/CS in observed_mob) del(CS)
				else
					usr.SendMsg("[observed_mob.name]'s soul contract on [S] is destroyed.", CHAT_IC)
					observed_mob.SendMsg("[usr.name] has used the soul contract on you to destroy your soul contract on [S.name]", CHAT_IC)
					del(S)

			if("Take their soul contracts")
				switch(input("If [observed_mob] has any soul contracts of their own, you will have them as well.") in \
				list("Continue","Cancel"))
					if("Cancel") return
					if("Continue")
						for(var/obj/Contract_Soul/C in observed_mob)
							var/Duplicate
							for(var/obj/Contract_Soul/CS in usr) if(C.Mob_ID==CS.Mob_ID) Duplicate=1
							if(!Duplicate)
								var/obj/Contract_Soul/S=new
								S.observed_mob=C.observed_mob
								S.Mob_ID=C.Mob_ID
								S.icon=C.icon
								S.overlays=C.overlays
								S.name=C.name
								S.suffix=C.suffix
								usr.contents+=S

			if("Soul Info")
				usr.SendMsg("*[observed_mob]'s soul info*<br>\
				Base BP: [Commas(observed_mob.base_bp)]<br>\
				Age: [observed_mob.Age]<br>\
				Lifespan: [observed_mob.Lifespan()] years<br>", CHAT_IC)

			if("Use soul to extend your decline")
				var/Min=-(usr.Lifespan()-usr.Age)
				var/Max=observed_mob.Lifespan()-observed_mob.Age
				var/N=input("You can use this to take/give years of life from the soul, which will give/take years of \
				life to you in exchange. If you take/give the maximum amount, them/you will die. Entering negative \
				amounts gives them that many years of your life, entering positive takes life from them and gives it \
				to you. Taking the maximum negative/positive amounts will kill one of you. You can give between \
				[Min] and [Max] years to [observed_mob]. Be aware you can only transfer a fraction of the amount, if you take \
				2 years off their life, you may only get 1 year of life in return, the rest will go into the void \
				forever.","Lifespan transfer",0) as num
				if(!N||!observed_mob) return
				Min=-(usr.Lifespan()-usr.Age)
				Max=observed_mob.Lifespan()-observed_mob.Age
				if(N<Min) N=Min
				if(N>Max) N=Max
				if(N<0)
					usr.Age+=N
					observed_mob.Age-=N/2
					usr.SendMsg("You gave [N] years of your life to [observed_mob.name], they recieve +[abs(N/2)] years of life in exchange.", CHAT_IC)
					observed_mob.SendMsg("[usr.name] has used the soul contract to extent your lifespan by [abs(N/2)] years, by sacrificing \
					[abs(N)] years of their lifespan.", CHAT_IC)
				if(N>0)
					usr.Age+=N/2
					observed_mob.Age-=N
					usr.SendMsg("You have gained +[N/2] years of life from [observed_mob.name].", CHAT_IC)
					//P<<"[usr] has used the soul contract to take [N] years from your lifespan, to extent their own"

			if("Permanent Teleport")
				if(usr.Teleport_nulled())
					usr.SendMsg("A teleport nullifier is disrupting your ability to teleport.", CHAT_IC)
					return
				if(usr.KO)
					usr.SendMsg("You can not teleport while knocked out.", CHAT_IC)
					return
				if(observed_mob.InFinalRealm()||observed_mob.Prisoner())
					usr.SendMsg("You can not teleport to them because they are in another dimension.", CHAT_IC)
					return
				if(usr.InFinalRealm()||usr.Prisoner())
					usr.SendMsg("You can not teleport to them because you are in another dimension.", CHAT_IC)
					return
				var/turf/t = usr.base_loc()
				for(var/n in 1 to 40)
					if(t != usr.base_loc() || usr.KO)
						usr.SendMsg("Teleport canceled.", CHAT_IC)
						return
					sleep(1)
				if(!observed_mob || !observed_mob.base_loc())
					usr.SendMsg("Invalid location.", CHAT_IC)
					return
				tpx=0
				tpy=0
				tpz=0
				usr.SafeTeleport(observed_mob.base_loc())
				usr.StopBeaming()

			if("Temporary Teleport")
				if(usr.Teleport_nulled())
					usr.SendMsg("A teleport nullifier is disrupting your ability to teleport.", CHAT_IC)
					return
				if(usr.KO)
					usr.SendMsg("You can not teleport while knocked out.", CHAT_IC)
					return
				if(usr.InFinalRealm()||usr.Prisoner())
					usr.SendMsg("You can not teleport to them because you are in another dimension.", CHAT_IC)
					return
				if(observed_mob.InFinalRealm()||observed_mob.Prisoner())
					usr.SendMsg("You can not teleport to them because they are in the another dimension.", CHAT_IC)
					return
				var/turf/t=usr.base_loc()
				for(var/n in 1 to 70)
					if(t!=usr.base_loc()||usr.KO)
						usr.SendMsg("Teleport canceled.", CHAT_IC)
						return
					sleep(1)
				if(!observed_mob || !observed_mob.base_loc())
					usr.SendMsg("Invalid location.", CHAT_IC)
					return
				tpx=usr.x
				tpy=usr.y
				tpz=usr.z
				usr.SafeTeleport(observed_mob.base_loc())
				usr.StopBeaming()

			if("Teleport Back")
				if(usr.Teleport_nulled())
					usr.SendMsg("A teleport nullifier is disrupting your ability to teleport.", CHAT_IC)
					return
				if(usr.KO)
					usr.SendMsg("You can not teleport while knocked out.", CHAT_IC)
					return
				if(usr.InFinalRealm()||usr.Prisoner())
					usr.SendMsg("You can not teleport back because you are in another dimension.", CHAT_IC)
					return
				var/turf/t=usr.base_loc()
				for(var/n in 1 to 70)
					if(t!=usr.base_loc()||usr.KO)
						usr.SendMsg("Teleport canceled.", CHAT_IC)
						return
					sleep(1)
				usr.SafeTeleport(locate(tpx,tpy,tpz))
				usr.StopBeaming()
				tpx=0
				tpy=0
				tpz=0

			if("Permanent Summon")
				if(ismob(usr.loc))
					usr.SendMsg("You can not summon while in a mob.", CHAT_IC)
					return
				if(observed_mob.Teleport_nulled())
					usr.SendMsg("They can not be summoned because they are near a teleport nullifier making it impossible \
					to lock on to them.", CHAT_IC)
					return
				if(observed_mob.KO)
					usr.SendMsg("[observed_mob.name] is in conditions which make it impossible to summon them.", CHAT_IC)
					return
				if(observed_mob.InFinalRealm()||observed_mob.Prisoner())
					usr.SendMsg("You can not summon them because they are in another dimension.", CHAT_IC)
					return
				if(usr.InFinalRealm()||usr.Prisoner())
					usr.SendMsg("You can not summon them because you are in another dimension.", CHAT_IC)
					return
				var/turf/t=observed_mob.base_loc()
				for(var/n in 1 to 70)
					if(t!=observed_mob.base_loc())
						usr.SendMsg("Summon canceled. You lose your lock on their energy when they move.", CHAT_IC)
						return
					sleep(1)
				presummon_x=0
				presummon_y=0
				presummon_z=0
				for(var/mob/M in player_view(15,observed_mob))
					M.SendMsg("[observed_mob.name] is summoned away by [usr.name]'s soul contract.", CHAT_IC)
				observed_mob.SafeTeleport(usr.base_loc())
				observed_mob.StopBeaming()
				for(var/mob/M in player_view(15,observed_mob))
					M.SendMsg("[observed_mob.name] is summoned to [usr.name] by the soul contract.", CHAT_IC)

			if("Destroy contract")
				for(var/mob/M in player_view(15,usr))
					M.SendMsg("[usr.name] destroys the soul contract of [observed_mob.name].", CHAT_IC)
				del(src)

			if("Alter soul's BP")
				if(observed_mob)
					if(Max_BP < observed_mob.base_bp)
						Max_BP = observed_mob.base_bp
					if(Max_BP <= usr.base_bp * Progression.GetSettingValue("Soul Contract BP Cap Multiplier") * 0.85)
						Max_BP = usr.base_bp * Progression.GetSettingValue("Soul Contract BP Cap Multiplier") * 0.85
					var/N = input("You can alter their bp anywhere between 1 and [Commas(Max_BP)].","Alter BP",observed_mob.base_bp) as num|null
					if(!N) return
					N = Math.Max(N, 1)
					N = Math.Min(N, Max_BP)
					if(observed_mob)
						observed_mob.base_bp = N
						observed_mob.SendMsg("[usr] has altered your BP to [Commas(N)].", CHAT_IC)
					else
						usr.SendMsg("They are no longer online...", CHAT_IC)

			if("Leech soul")
				if(observed_mob)
					usr.SendMsg("You have now fully leeched [observed_mob.name].", CHAT_IC)
					var/max_bp=max(usr.base_bp, observed_mob.base_bp * 0.95)
					usr.LeechOpponent(observed_mob)
					if(usr.base_bp > max_bp) usr.base_bp = max_bp

			if("Knock out")
				if(observed_mob) observed_mob.KnockOut("[usr]'s soul contract")

			if("Absorb")
				if(observed_mob.KO&&!(observed_mob in view(10,usr)))
					usr.SendMsg("You can not use absorb on them while they are knocked out, unless you are physically near \
					them.", CHAT_IC)
					return
				if(observed_mob.Dead)
					usr.SendMsg("They are dead and can not be absorbed.", CHAT_IC)
					return
				for(var/mob/M in player_view(15,observed_mob))
					M.SendMsg("[observed_mob.name]'s demon master uses the soul contract to absorb [observed_mob], killing them!", CHAT_IC)
				usr.Absorb(observed_mob, ignore_determination = 1, no_regenerate = 1)
				usr.SendMsg("You have absorbed [observed_mob.name] from a distance, killing them.", CHAT_IC)

			if("Kill")
				if(observed_mob.KO&&!(observed_mob in view(10,usr)))
					usr.SendMsg("You can not use kill on them while they are knocked out, unless you are physically near \
					them.", CHAT_IC)
					return
				if(usr.Dead&&!observed_mob.Dead)
					usr.SendMsg("You used [observed_mob.name]'s life energy to bring yourself back to life.", CHAT_IC)
					usr.Revive()
				observed_mob.Death("[usr]'s soul contract",1)
				if(observed_mob && isturf(observed_mob.loc)) observed_mob.SafeTeleport(usr.base_loc())

			if("Temporary Summon")
				if(observed_mob.Teleport_nulled())
					usr.SendMsg("They can not be summoned because they are near a teleport nullifier making it impossible \
					to lock on to them.", CHAT_IC)
					return
				if(ismob(usr.loc))
					usr.SendMsg("You can not summon while in a mob.", CHAT_IC)
					return
				if(observed_mob.KO)
					usr.SendMsg("[observed_mob] is in conditions which make it impossible to summon them.", CHAT_IC)
					return
				if(observed_mob.InFinalRealm()||observed_mob.Prisoner())
					usr.SendMsg("You can not summon them because they are in another dimension.", CHAT_IC)
					return
				if(usr.InFinalRealm()||usr.Prisoner())
					usr.SendMsg("You can not summon them because you are in another dimension.", CHAT_IC)
					return
				var/turf/t=observed_mob.base_loc()
				for(var/n in 1 to 70)
					if(!observed_mob) return
					if(t!=observed_mob.base_loc())
						usr.SendMsg("Summon canceled. You lose your lock on their energy when they move.", CHAT_IC)
						return
					sleep(1)
				usr.SendMsg("You can select 'send back' to send them back to where they were before you summoned them.", CHAT_IC)
				for(var/mob/M in player_view(15,observed_mob))
					M.SendMsg("[observed_mob] was summoned away by [usr]'s soul contract!", CHAT_IC)
				presummon_x=observed_mob.x
				presummon_y=observed_mob.y
				presummon_z=observed_mob.z
				observed_mob.SafeTeleport(usr.base_loc())
				observed_mob.StopBeaming()
				for(var/mob/M in player_view(15,observed_mob))
					M.SendMsg("[observed_mob] was summoned by [usr]'s soul contract.", CHAT_IC)

			if("Send back")
				if(observed_mob.Teleport_nulled())
					usr.SendMsg("They can not be sent back because they are near a teleport nullifier making it impossible \
					to lock on to them.", CHAT_IC)
					return
				if(observed_mob.KO)
					usr.SendMsg("[observed_mob.name] is in conditions which make it impossible to do this.", CHAT_IC)
					return
				if(observed_mob.InFinalRealm()||observed_mob.Prisoner())
					usr.SendMsg("You can not summon them because they are in another dimension.", CHAT_IC)
					return
				var/turf/t=observed_mob.base_loc()
				for(var/n in 1 to 70)
					if(t!=observed_mob.base_loc())
						usr.SendMsg("Send back canceled. You lose your lock on their energy when they move.", CHAT_IC)
						return
					sleep(1)
				for(var/mob/M in player_view(15,observed_mob))
					M.SendMsg("[observed_mob.name] was sent back to his last location by [usr.name]'s soul contract.", CHAT_IC)
				observed_mob.SafeTeleport(locate(presummon_x,presummon_y,presummon_z))
				observed_mob.StopBeaming()
				for(var/mob/M in player_view(15,observed_mob))
					M.SendMsg("[observed_mob.name] was sent back by [usr.name]'s soul contract!", CHAT_IC)
				presummon_x=0
				presummon_y=0
				presummon_z=0

	New()
		soul_contracts ||= list()
		soul_contracts |= src

	Del()
		soul_contracts-=src
		. = ..()

	proc/Soul_Contract_Update(mob/M) if(M)
		observed_mob=M
		Mob_ID=observed_mob.key
		icon=observed_mob.icon
		overlays=observed_mob.overlays
		name=observed_mob.name
		suffix="Online"

var/list/soul_contracts=new

mob/proc/Update_soul_contracts()
	for(var/obj/Contract_Soul/sc in soul_contracts) if(Mob_ID && key==sc.Mob_ID) sc.Soul_Contract_Update(src)
	for(var/obj/Contract_Soul/sc in src)
		for(var/mob/m in players) if(m.Mob_ID&&m.key==sc.Mob_ID) sc.Soul_Contract_Update(m)

obj/Skills/Divine/Demon_Contract
	name="Soul Contract"
	desc="You can offer someone a soul contract. If they accept, their soul will belong to you, and you will \
	get certain powers over them."
	teachable=1
	race_teach_only=1
	Skill=1
	Teach_Timer=24
	student_point_cost = 100
	Cost_To_Learn=70
	clonable=0
	var/tmp/Offering

	verb/Soul_Contract()
		set category = "Skills"
		usr.Soul_Contract(src)

mob/proc/Soul_Contract(obj/Skills/Divine/Demon_Contract/SC)
	if(IsFusion())
		src.SendMsg("You can not manipulate souls while fused!")
		return
	if(SC.Offering)
		src.SendMsg("You must either wait until they accept, deny, or until 20 seconds \
		has passed.", CHAT_IC)
		return
	//if(Race!="Demon")
	//	src<<"Only demons can manipulate souls"
	//	return
	for(var/mob/P in Get_step(src,dir)) if(P.client)
		if(P.IsFusion())
			src.SendMsg("[P.name]'s soul is too powerful to contract.", CHAT_IC)
			return
		if(P.ignore_contracts)
			src.SendMsg("[P.name] is ignoring contracts.", CHAT_IC)
			return
		for(var/obj/Contract_Soul/C in src) if(C.Mob_ID==P.key)
			src.SendMsg("You already have their soul.", CHAT_IC)
			return
		if(P.Android)
			src.SendMsg("Androids do not have souls.", CHAT_IC)
			return
		SC.Offering=1
		spawn(200) if(SC&&SC.Offering) SC.Offering=0
		src.SendMsg("You offer the soul contract to [P.name]. Waiting on their response...", CHAT_IC)
		switch(alert(P,"SOUL CONTRACT: [src.name] has offered you the soul contract. If you accept it they will be able to help or harm you in many \
		different ways, completely destroying your character. They will have your soul even if you remake. The only way out is if they destroy the contract or they die.","Options","Deny","Accept SOUL CONTRACT"))
			if("Deny")
				for(var/mob/M in player_view(15,P))
					M.SendMsg("[P.name] has denied the soul contract from [src.name].", CHAT_IC)
			if("Accept SOUL CONTRACT")
				for(var/mob/M in player_view(15,P))
					M.SendMsg("[P.name] has accepted the soul contract from [src.name], their soul now belongs to [src.name].", CHAT_IC)
				var/obj/Contract_Soul/C=new
				contents+=C
				C.Soul_Contract_Update(P)
		if(SC) SC.Offering=0
		return

obj/Skills/Utility/Meditate/Level2
	name = "Advanced Meditation"
	teachable=1
	Skill=1
	Teach_Timer=1
	student_point_cost = 40
	Cost_To_Learn=15
	desc="Meditate Level 2 allows you to use meditation as a form of training. Without this skill, meditate is \
	only good for recovering health and energy faster."

obj/Skills/Utility/Sense
	name="Sense Level 1"
	teachable=1
	Skill=1
	student_point_cost = 10
	Teach_Timer=0.5
	Cost_To_Learn=3
	desc="The ability to sense everyone on the planet. You can see their overall power, which is their BP, stats, \
	and everything else combined into a percent."
	New()
		spawn(20) if(src)
			var/mob/m=loc
			if(m&&ismob(m)) m.sense_obj=src
	Level2
		name="Sense Level 2"
		teachable=1
		Skill=1
		Teach_Timer=0.7
		Cost_To_Learn=3
		student_point_cost = 10
		desc="By clicking on someone you will open a tab which will let you see their overall power, health, and \
		energy, and possibly other details that basic sense does not tell you."
	Level3
		name="Sense Level 3"
		teachable=1
		Skill=1
		Teach_Timer=1
		student_point_cost = 10
		Cost_To_Learn=3
		desc="This requires Sense Level 2 to work. When you open a tab of a person by clicking them, you will see \
		many details of that person, like their stats, as well as many other useful things."

proc/Timed_Delete(obj/O,T=100)
	set waitfor=0
	sleep(T)
	if(O) del(O)

proc/Rising_Aura(obj/T,N=50)
	if(N<0) return
	N=round(N)
	while(T&&T.z&&N)
		N--
		var/obj/Rising_Aura/A=new(T.loc)
		A.icon=image(icon='Aura, Big.dmi',icon_state="2")
		A.icon+=rgb(100,200,255)
		sleep(2)

obj/Rising_Aura
	layer=90
	Savable=0
	New()
		icon_state=pick(null,"2")
		pixel_y-=32
		Offsets(10)
		Aura_Walk()
		spawn(50) if(src) del(src)
	proc/Offsets(Offset=16)
		set waitfor=0
		while(src)
			pixel_x=rand(-Offset,Offset)
			pixel_x-=32
			sleep(1)
	proc/Aura_Walk()
		set waitfor=0
		while(src)
			step(src,NORTH)
			sleep(3)

mob/var/Regeneration_Skill
obj/Skills/Utility/Regeneration
	teachable=1
	Skill=1
	hotbar_type="Defensive"
	can_hotbar=1
	race_teach_only=1
	Teach_Timer=3
	student_point_cost = 20
	race_teach_only=1
	Cost_To_Learn=10
	desc="This is a passive healing skill where, if your health goes below 100% you will begin trading energy \
	for health. You can turn it on and off at any time."

	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Regenerate()

	verb/Regenerate()
		set category = "Skills"
		if(!usr.Regeneration_Skill&&usr.Is_Cybernetic())
			usr.SendMsg("Cybernetic beings cannot use this ability.", CHAT_IC)
			return
		if(usr.KO)
			usr.SendMsg("You must wait until you regain consciousness.", CHAT_IC)
			return
		if(!usr.Regeneration_Skill)
			usr.Regeneration_Skill=1
			usr.SendMsg("You are now regenerating.", CHAT_IC)
			usr.RegenerateSkillTick()
		else
			usr.Regeneration_Skill=0
			usr.SendMsg("You stop regenerating.", CHAT_IC)

obj/Skills/Utility/Give_Power
	teachable=1
	Skill=1
	hotbar_type="Support"
	can_hotbar=1
	Cost_To_Learn=4
	Teach_Timer=1
	student_point_cost = 15
	desc="You can transfer your health and energy to someone from a distance. The person can exceed 100% power \
	if you have enough health and energy, exceeding 100% energy raises their BP. The effect is only temporary, \
	because health and energy do not stay above 100% for long."
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Give_Power()

	verb/Give_Power()
		set category = "Skills"
		if(usr.Android)
			usr.SendMsg("Androids cannot use natural-only abilities.", CHAT_IC)
			return
		if(usr.KO) return
		if(!usr.Giving_Power)
			if(usr.locz()==18)
				usr.SendMsg("The acid fumes in this place prevent you from transferring your energy right now.", CHAT_IC)
				return
			if(usr.power_given>=40)
				usr.SendMsg("You have given all the power you can for now. You must wait for it to refill.", CHAT_IC)
				return
			usr.SendMsg("Click again to stop giving power.", CHAT_IC)
			usr.Give_Power(src)
		else
			usr.Giving_Power=0
			usr.SendMsg("You stop giving power.", CHAT_IC)
mob/var
	tmp/Giving_Power
	power_given=0
	tmp/gp_target
	list/gp_list=list()

mob/proc/Give_Power(obj/Skills/Utility/Give_Power/G)
	if(tournament_override(fighters_can=0)) return
	var/list/Mobs=list("Cancel")
	for(var/mob/M in player_view(15,src)) if(M.client&&M!=src) Mobs+=M
	if(Mobs.len<=2) Mobs-="Cancel"
	var/mob/M=input(src,"Choose a target to give power to") in Mobs
	if(Giving_Power) return
	if(!M||M=="Cancel") return
	Giving_Power=1
	gp_target=M //set GP target for SSG reqs
	M.gp_list+=src //track list of people giving power to M
	for(var/mob/m in player_view(15,src))
		m.SendMsg("[src] is sending their power to [M]!", CHAT_IC)
	var/obj/O=new
	O.icon='Give Power.dmi'
	O.layer=layer+1
	spawn while(src&&Giving_Power&&M)
		Missile(O,src,M)
		sleep(1)
	while(src&&M&&Giving_Power&&!KO&&getdist(src,M)<=13&&locz()!=18&&M.locz()!=18)

		dir=get_dir(src,M)
		if(M.Health<100) M.IncreaseHealth(0.4, "give power")
		TakeDamage(-1, "give power")
		if(power_given) GivePowerRefill()
		power_given++
		if(M.KO&&M.Health>=100) M.RegainConsciousness()
		if(KO)
			Giving_Power=0
			if(gp_target) gp_target=0
			if(M.gp_list.Find(src)) M.gp_list-=src //Remove from list
			return
		if(Ki>=max_ki/100)
			IncreaseKi(-max_ki/100)
			var/n=max_ki/100 / Clamp((Eff/M.Eff)**0.5,0.5,2)
			if(M.Ki>M.max_ki)
				n*=(M.max_ki / M.Ki)**3
			if(M.Ki <= 0) M.Ki = 1 //stop division by zero error
			M.IncreaseKi((M.max_ki/100) * Clamp((M.max_ki / M.Ki)**3, 0, 1.5))
		if(power_given>=100)
			if(M.gp_list.Find(src)) M.gp_list-=src
			if(gp_target) gp_target=0
			src.SendMsg("You have given all the power you can for now. You must wait for it to refill.", CHAT_IC)
			break
		sleep(2)
	Giving_Power=0
mob/proc/Give_power_refill_loop()
	set waitfor=0
	while(src)
		if(!Giving_Power)
			power_given-=1/120*100 * 10
			if(power_given<0)
				power_given=0
				break
		sleep(100)

mob/proc/GivePowerRefill()
	power_given -= 0.41666667
	power_given = Math.Max(power_given, 0)

mob/var/tmp/obj/Skills/Utility/zanzoken_obj

obj/Skills/Utility/Zanzoken
	teachable=1
	Skill=1
	Cost_To_Learn = 5
	Teach_Timer=0.5
	student_point_cost = 5
	desc="Zanzoken is the ability to use a burst of concentrated speed to reach a place very fast, \
	it is so fast it is basically like teleporting a short distance. You click the spot you want to go \
	to and your character will suddenly go there. The more you master this the less energy it will \
	drain. You will also get a new command in the skills tab that lets you chase someone down using \
	zanzoken if they try to run from you"

	New()
		spawn(5) if(src && ismob(loc))
			var/mob/m=loc
			m.zanzoken_obj=src
		. = ..()

	verb/Combo_Toggle()
		set category="Other"
		if(!usr.Warp)
			usr<<"Combo Warping on"
			usr.Warp=1
		else
			usr<<"Combo Warping off"
			usr.Warp=0

mob/var/KeepsBody //If this is 1 you keep your body when Dead.
obj/Skills/Divine/Keep_Body
	desc="Using this on someone will allow them to keep most of their power while dead."
	teachable=1
	race_teach_only=1
	Skill=1
	hotbar_type="Support"
	can_hotbar=1
	Teach_Timer=12
	student_point_cost = 30
	var/next_use=0
	var/hours_per_use=1
	New()
		if(!next_use) next_use=world.realtime+(hours_per_use*60*60*10)
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Keep_Body()
	verb/Keep_Body()
		set category="Other"
		if(usr.Android)
			usr.SendMsg("Androids cannot use natural-only abilities.", CHAT_IC)
			return
		if(world.realtime<next_use)
			var/hours=(next_use-world.realtime)/10/60/60
			usr.SendMsg("You can not use this for another [round(hours)] hours and [round(hours*60 %60)] minutes.", CHAT_IC)
			return
		var/list/L=list(usr)
		for(var/mob/m in Get_step(usr,usr.dir)) L+=m
		var/mob/M=input("Allow which person to keep their body when dead?") in L
		if(M)
			switch(input("Allow [M.name] to keep their body?") in list("Yes","No"))
				if("Yes")
					if(world.realtime<next_use) return
					M.KeepsBody=1
					next_use=world.realtime+(hours_per_use*60*60*10)
					for(var/mob/m in player_view(15,usr))
						m.SendMsg("[usr.name] allows [M.name] to keep their body while dead.", CHAT_IC)
				if("No")
					M.KeepsBody=0
					for(var/mob/m in player_view(15,usr))
						m.SendMsg("[usr.name] removes [M.name]'s ability to keep their body while dead.", CHAT_IC)
mob/var/tmp/obj/Skills/Combat/Ki/Shield/shield_obj
obj/Skills/Combat/Ki/Shield
	teachable=1
	Skill=1
	Teach_Timer=2
	student_point_cost = 20
	hotbar_type="Defensive"
	can_hotbar=1
	Cost_To_Learn=8
	Mastery=100
	can_change_icon=1
	desc="You can toggle this on and off. A ki shield will surround you to protect you from all \
	attacks. Each attack will drain your energy instead of health. The shield will also protect you \
	from dying in space but it will drain energy heavily."
	icon='Shield Blue.dmi'
	New()
		spawn if(ismob(loc))
			var/mob/M=loc
			M.shield_obj=src

	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Shield()

	verb/Shield()
		set category = "Skills"
		usr.Toggle_ki_shield(src)

mob/proc/Toggle_ki_shield(obj/Skills/Combat/Ki/Shield/s)
	if(!s) s=locate(/obj/Skills/Combat/Ki/Shield) in src
	if(!s) return
	if(KO) return
	if(!s.Using)
		if(CanUseKiShield())
			s.Using=1
			Shield()
			KiShieldKO()
	else Shield_Revert()

mob/proc/CanUseKiShield()
	return !(LastSpiritBombValid() || UsingGuidedAttack())

mob/proc/UsingGuidedAttack()
	for(var/obj/Skills/Combat/Ki/a in ki_attacks)
		if(a.Using)
			if(a.type in list(/obj/Skills/Combat/Ki/Kienzan, /obj/Skills/Combat/Ki/Sokidan, /obj/Skills/Combat/Ki/Genki_Dama/Death_Ball, /obj/Skills/Combat/Ki/Genki_Dama/Supernova))
				return 1

mob/var/tmp/last_shield_use=0

mob/proc/Shield_Revert()
	for(var/obj/Skills/Combat/Ki/Shield/A in src)
		if(A.Using) last_shield_use = world.time
		overlays-=A.icon
		A.Using=0

mob/proc/Shield()
	if(IsShielding()) overlays+=shield_obj.icon

mob/proc/IsShielding()
	return shield_obj && shield_obj.Using

obj/Skills/Divine/Make_Fruit
	teachable=1
	name = "Make Power Fruit"
	hotbar_type="Support"
	can_hotbar=1
	Skill=1
	Teach_Timer=4
	student_point_cost = 30
	desc="With this you can make fruits that will increase the power and energy of those who eat them, \
	along with a temporary boost to regeneration and recovery. The more of them you eat however, the \
	less of an effect they will have each time."
	var/tmp/Making
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Make_Power_Fruit()
	verb/Make_Power_Fruit()
		set category = "Skills"
		if(Making)
			usr.SendMsg("You are already making a fruit.", CHAT_IC)
			return
		Making=1
		for(var/mob/M in player_view(15,usr))
			M.SendMsg("[usr.name] begins planting something.", CHAT_IC)
		sleep(100)
		for(var/mob/M in player_view(15,usr))
			M.SendMsg("A strange fruit appears in front of [usr.name].", CHAT_IC)
		Making=0
		var/obj/items/Fruit/A=new(usr)
		A.name="[usr] Fruit"

var/list/bind_objects=new

obj/Curse
	var
		CursePower=0
		bind_time=0

	New()
		bind_objects ||= list()
		bind_objects |= src
		bind_check()

	Del()
		bind_objects-=src
		. = ..()

	proc/bind_check()
		set waitfor=0
		sleep(10) //necesary so the bind doenst immediately expire before bind_time has been set elsewhere
		while(src)
			var/mob/m=loc
			if(!m||!ismob(m)) del(src)
			if(world.realtime>bind_time)
				m.SendMsg("<font color=red><font size=2>The bind on you has expired, you can leave hell at any time.", CHAT_IC)
				del(src)
			sleep(600)
mob/var
	last_bind=0
	last_unbind=0

obj/Skills/Divine/Bind
	hotbar_type="Ability"
	can_hotbar=1
	Skill=1
	Cost_To_Learn=55
	teachable=1
	Teach_Timer=3
	student_point_cost = 50
	desc="You can use this to bind someone to hell. You can only bind a person who is less than your \
	own power at the time. The stronger they are compared to you the more energy it will drain \
	to bind them"

	proc/bind_power(mob/m)
		var/ki_mod=m.Eff
		var/obj/Skills/Buff/b = m.buffed()
		if(b) ki_mod/=b.buff_ki
		var/n=5 * (m.max_ki/m.Eff/500)**3 * (ki_mod**0.2)
		return n

	proc/bind_time(mob/m)
		var/ki_mod=m.Eff
		var/obj/Skills/Buff/b=m.buffed()
		if(b) ki_mod/=b.buff_ki
		return world.realtime + (1 * 60 * 600) * (ki_mod ** 0.3)

	verb/Hotbar_use()
		set hidden=1
		Bind_Someone()

	verb/Bind_Someone()
		set category = "Skills"
		if(usr.tournament_override(fighters_can=0)) return
		var/bind_time_limit = 20

		if(world.realtime < usr.last_bind + (bind_time_limit * 60 * 10))
			usr.SendMsg("You can only use this every [bind_time_limit] minutes", CHAT_IC)
			return

		for(var/mob/A in Get_step(usr,usr.dir)) if(A.client && A.KO)

			if(world.realtime - A.last_kill_time > Time.FromMinutes(40))
				usr.SendMsg("[A] can not be binded because they have not killed anyone in the last 40 minutes.", CHAT_IC)
				return

			/*if(A.BP > usr.BP)
				player_view(15,usr)<<"[usr] attempts to bind [A] to hell, but [A]'s spiritual power deflects it!"
				return*/

			if(locate(/obj/Curse) in A)
				for(var/obj/Curse/B in A)
					B.CursePower+=bind_power(usr)
					if(B.bind_time<bind_time(usr)) B.bind_time=bind_time(usr)
					for(var/mob/M in player_view(15,usr))
						M.SendMsg("[usr] strengthens the bind already placed on [A] to [Commas(B.CursePower)] energy!", CHAT_IC)
			else
				var/obj/Curse/B=new
				B.CursePower+=bind_power(usr)
				B.bind_time=bind_time(usr)
				for(var/mob/M in player_view(15,usr))
					M.SendMsg("[usr] successfully binds [A] to hell! The bind has [Commas(B.CursePower)] energy.", CHAT_IC)
				A.contents+=B

			usr.last_bind=world.realtime
			return
		usr.SendMsg("Use this to bind a knocked out person in front of you to hell. Currently there is no one in front of you who is knocked out", CHAT_IC)

	verb/UnBind_Someone()
		set category = "Skills"

		if(world.time<usr.last_unbind) usr.last_unbind=0

		if(world.time<usr.last_unbind+(10*60*10))
			var/t=usr.last_unbind+(10*60*10)-world.time
			t=round(t/10)
			usr.SendMsg("You can not use this for another [t] seconds.", CHAT_IC)
			return
		var/list/L=new
		if(locate(/obj/Curse) in usr) L+=usr
		for(var/mob/P in Get_step(usr,usr.dir)) if(locate(/obj/Curse) in P) L+=P
		var/mob/A=input("Who do you want to attempt to unbind?") in L
		if(!A)
			alert("Use this to Unbind someone in front of you who has been binded to hell. Currently no one is in front of you")
			return
		if(world.time<usr.last_unbind+(10*60*10))
			var/t=usr.last_unbind+(10*60*10)-world.time
			t=round(t/10)
			usr.SendMsg("You can not use this for another [t] seconds.", CHAT_IC)
			return
		for(var/obj/Curse/B in A)
			//if(usr.Ki<usr.max_ki*0.9)
				//usr<<"You need at least 90% energy to attempt to remove a bind"
				//return
			usr.last_unbind=world.time
			var/old_energy=B.CursePower
			B.CursePower-=bind_power(usr)/2.2
			//usr.Ki/=2
			if(B.CursePower<=0)
				for(var/mob/M in player_view(15,usr))
					M.SendMsg("[usr] succeeds in breaking the bind placed on [A]!", CHAT_IC)
				del(B)
			else
				for(var/mob/M in player_view(15,usr))
					M.SendMsg("[usr] weakened the bind from [Commas(old_energy)] to [Commas(B.CursePower)] energy.", CHAT_IC)
			return

obj/var/examinable=1

proc/Examine_List()
	var/list/L=new
	for(var/obj/O) if(O.desc&&O.examinable) L+=O
	return L

mob/verb/Examine(obj/A in Examine_List())
	set category = "Other"
	if(A) src.SendMsg("<br><br>[A.desc]", CHAT_IC)

proc/Strongest_Person(mob/M)
	for(var/mob/P in players) if(!M||P.base_bp>M.base_bp) M=P
	return M

proc/strongest_person_proportionate(mob/m)
	for(var/mob/p in players) if(!m || p.base_bp > m.base_bp) m = p
	return m

obj/var/Skill //If Skill=1 this obj is a SKILL
obj/Skills/Utility/Absorb
	Skill=1
	hotbar_type="Ability"
	can_hotbar=1

	//Cost_To_Learn=60
	Cost_To_Learn = 0

	desc="You can absorb a knocked out person. You will get a power increase based on how strong they \
	are compared to you. Absorbing people can also bring \
	you back to life, by absorbing either 1 living person or multiple dead people (on average 5 but it is \
	luck based), their base BP must also be more than 75% of yours and they can not be an alt or npc."

	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Absorb()

	verb/Absorb()
		set category = "Skills"

		/*if(!(usr.Race in list("Majin","Bio-Android","Android","Alien","Demon")))
			if(!("Absorb" in usr.active_packs))
				if(!(locate(/obj/Module/Manual_Absorb) in usr.active_modules))
					del(src)
					return*/

		usr << "<font color=red>Absorbing... Don't move"
		var/turf/t = usr.loc
		var/d = usr.dir
		for(var/v in 1 to 12)
			sleep(TickMult(2))
			if(usr)
				usr.ReleaseGrab()
				if(usr.loc != t || usr.dir != d || usr.KO || usr.KB) return

		usr.Absorb()

mob/var/last_absorbed
mob/proc
	power_absorb_mod()
		if(Race=="Majin") return 1
		if(Race=="Bio-Android") return 1
		if(Race=="Android") return 0.8
		if(Race=="Alien") return 0.6
		if(Race=="Demon") return 0.6
		if(Race=="Human") return 1
		if(Race=="Puranto") return 0.2
		return 0.1
	knowledge_absorb_mod()
		if(Race=="Android") return 0.3
		if(Race=="Bio-Android") return 0.5
		if(Race=="Human") return 0.5
		return 0.15

mob/proc/Absorb(mob/M, force_absorb, ignore_determination = 0, no_regenerate = 0)

	if(!M) for(var/mob/m in Get_step(src,dir)) if(m.KO)
		M=m
		break
	
	if(!M) return
	
	if(!ignore_determination && M?.client && prob(M?.determination))
		for(var/mob/h in player_view(15,src))
			h.SendMsg("[src.name] tries to absorb [M], but they break free!", CHAT_IC)
		return

	if(!force_absorb && !can_absorb(M)) return
	last_absorbed=M.key
	if(BPpcnt > 100) BPpcnt = 100
	for(var/mob/h in player_view(15,src))
		h.SendMsg("[src.name] ([displaykey]) absorbs [M]!", CHAT_IC)
	var/absorb_power = 90 * power_absorb_mod()
	if(!M.client) absorb_power/=20
	if(M.Regenerate) absorb_power/=5
	if(Race in list("Majin", "Bio-Android"))
		no_regenerate = 1

	if(M.client)
		Health=100
		Ki=max_ki

		if(Dead&&(!M.Dead||prob(20))&&M.base_bp+M.static_bp>(base_bp+static_bp)*0.6&&!M.Regenerate) Revive()

		if(Knowledge<M.Knowledge)
			var/knowledge_gain=M.Knowledge*knowledge_absorb_mod()
			Knowledge+=knowledge_gain
			if(Knowledge>M.Knowledge) Knowledge=M.Knowledge

		var/relative_cyber_bp = M.cyber_bp
		if(M.scrap_absorb_mode)
			for(var/obj/Skills/Special/Scrap_Absorb/sa in M) relative_cyber_bp = sa.Old_cyber_bp
		if(M.Race == "Android" && Race != "Android")
			relative_cyber_bp /= Progression.GetSettingValue("Android BP Multiplier")
		if(cyber_bp)
			cyber_bp = Math.Max(cyber_bp, relative_cyber_bp)

		BioFormCheck(M)

	if(!M.Dead)
		//var/old_bp=base_bp
		absorbedPower += M.base_bp
		absorbedCyberBP += M.cyber_bp * 0.2
		LeechOpponent(M)
		if(!M.Regenerate)
			ClosePowerGapBy(0.05 * power_absorb_mod()**0.5, include_hbtc = 0)
		if(Race == "Majin")
			static_bp = Math.Max(static_bp, base_bp * 0.2)
			MajinAbsorb(M)
			if(M.Race == "Majin" && !HasTrait("Purity of Form"))
				TryGainTrait("Super Majin")
				TryGainTrait("Perfected Majin")

	if(no_regenerate || (M.Regenerate && BP > M.BP*2.4 * M.Regenerate**0.4)) M.Death(src,1)
	else M.Death(src)
	
mob/var/majinAbsorbPower = 0
mob/var/majinPowerModifier = 1
mob/var/list/absorbProxies = list()
obj/absorb_proxy
	var
		base_bp
		bp_mod
		Intelligence
		zenkai_mod
		leech_rate

mob/proc/MajinAbsorb(mob/M)
	if(Race != "Majin" || !M || !ismob(M) || !M.key) return
	if(!HasTrait("Purity of Form"))
		if(!absorbProxies) absorbProxies = list()

		var/obj/absorb_proxy/proxy = new
		proxy.base_bp = M.base_bp
		proxy.bp_mod = M.bp_mod
		proxy.Intelligence = M.Intelligence
		proxy.zenkai_mod = M.zenkai_mod
		proxy.leech_rate = M.leech_rate

		absorbProxies[M.key] = proxy
	
	else absorbProxies = list()
	
	UpdateMajinStats()

mob/proc/UpdateMajinStats()
	if(Race != "Majin" || !absorbProxies || !absorbProxies:len) return

	var/bpGain, modGain, intGain, zenkaiGain, leechGain
	for(var/i in absorbProxies)
		var/obj/absorb_proxy/proxy = absorbProxies[i]
		if(!proxy) continue
		bpGain += proxy.base_bp
		modGain += proxy.bp_mod
		intGain += proxy.Intelligence
		zenkaiGain += proxy.zenkai_mod
		leechGain += proxy.leech_rate

	bpGain /= absorbProxies.len * 2
	modGain /= absorbProxies.len * 2
	intGain /= absorbProxies.len * 2
	zenkaiGain /= absorbProxies.len * 2
	leechGain /= absorbProxies.len * 2

	majinAbsorbPower = bpGain
	bp_mod = Math.Clamp(1.8 + modGain, 1.8, 3)
	Intelligence = Math.Clamp(0.15 + intGain, 0.15, 0.8)
	zenkai_mod = Math.Clamp(zenkaiGain, 0, 1)
	leech_rate = Math.Clamp(1.5 + leechGain, 1.5, 3)

mob/var/absorbedPower = 0

mob/proc/can_absorb(mob/M)
	if(!M||!ismob(M)) return
	if(KO) return
	if(M.Dead)
		src.SendMsg("Dead people can not be absorbed.", CHAT_IC)
		return
	if(M.InFinalRealm())
		src.SendMsg("You can not absorb in the final realm.", CHAT_IC)
		return
	if(locate(/area/Prison) in range(0,src))
		src.SendMsg("You can not absorb in the prison.", CHAT_IC)
		return
	if(M.Safezone)
		src.SendMsg("You can not do this in a safezone.", CHAT_IC)
		return
	if(tournament_override(fighters_can=0)) return
	if(Shadow_Sparring)
		src.SendMsg("You are pre-occupied with shadow sparring.", CHAT_IC)
		return
	if(istype(M,/mob/Body))
		src.SendMsg("Bodies can not be absorbed.", CHAT_IC)
		return
	if(M.client&&client&&M.client.address==client.address)
		src.SendMsg("Alts can not be absorbed.", CHAT_IC)
		return
	if(last_absorbed==M.key)
		src.SendMsg("You can not absorb the same person twice in a row.", CHAT_IC)
		return
	if(M.spam_killed)
		src.SendMsg("You can not absorb [M.name] because they are death immune.", CHAT_IC)
		return
	if(!M.KO)
		src.SendMsg("[M.name] must be knocked out for you to absorb them.", CHAT_IC)
		return
	return 1

mob/var
	ITMod=1
	block_SI

mob/proc/SI_Choices()
	var/list/L=list("Cancel")
	for(var/mob/P in players) if((P.Mob_ID in SI_List)&&!P.hiding_energy)
		if(!Cant_SI(P,show_message=0)) L+=P
	return L

mob/proc/Cant_SI(mob/A,show_message=1)

	if(isobj(A))
		A = locate(/mob) in A
		if(!A || isobj(A)) return 1

	show_message=1 //to bug test why it will sometimes not let you use IT but yet not tell you why

	if(logout_timer && z!=18)
		if(show_message) src.SendMsg("You can not teleport away if you were recently damaged", CHAT_IC)
		return 1

	if(Teleport_nulled())
		if(show_message) src.SendMsg("There is a teleport nullifier somewhere disrupting your ability to teleport", CHAT_IC)
		return 1

	if(A)
		var/area/a=A.get_area()
		if(a && Planet_has_teleport_nullifier(a.name))
			if(show_message) src.SendMsg("There is a teleport nullifier where [A] is, you can't lock onto them", CHAT_IC)
			return 1

	if(KO)
		if(show_message) src.SendMsg("You can not teleport while knocked out", CHAT_IC)
		return 1

	if(A&&A.Dead&&Is_In_Afterlife(A)&&!Is_In_Afterlife(src))
		if(show_message) src.SendMsg("People in the living world can not teleport to dead people who are in the afterlife. Dead \
		people in the afterlife's energy is undetectable from the living world.", CHAT_IC)
		return 1

	if(A&&A.Is_Cybernetic())
		if(show_message) src.SendMsg("This does not work on cyborgs/androids because their energy is permanently hidden", CHAT_IC)
		return 1

	if(Dead&&!KeepsBody)
		if(show_message) src.SendMsg("Dead people can not use shunkan ido unless the 'keep body' ability has been used on them. \
		Mostly the Kaioshin and Daimao have the ability to let a dead person keep their body.", CHAT_IC)
		return 1

	if(A&&!(A.Mob_ID in SI_List))
		if(show_message) src.SendMsg("You do not know their energy. To know someone's energy you must have been near them a certain \
		amount of time", CHAT_IC)
		return 1

	if(A&&A.Ship) A=A.Ship

	if(A&&z!=A.z&&(A.z==10||A.InFinalRealm() || (ismob(A)&&A.Prisoner())))
		if(show_message) src.SendMsg("You cannot teleport to other dimensions.", CHAT_IC)
		return 1

	if(InFinalRealm()||Prisoner())
		if(show_message) src.SendMsg("You can not teleport out of this place", CHAT_IC)
		return 1

	if(A)
		var/turf/T=A.loc
		if(!isturf(T))
			if(show_message) src.SendMsg("You can not teleport to them because they are in the void", CHAT_IC)
			return 1
		if(T.Builder&&T.Builder!=key)
			if(show_message) src.SendMsg("You can not teleport in to other people's houses", CHAT_IC)
			return 1
		for(var/area/B in range(0,A)) if(istype(B,/area/Inside))
			if(show_message) src.SendMsg("You cannot teleport inside people's houses", CHAT_IC)
			return 1

mob/var/tmp
	si_disadvantage_time=0 //world.time
	mob/si_disadvantage_against

mob/proc/SI_disadvantage_mult(mob/m)
	if(!m || !si_disadvantage_against || si_disadvantage_against!=m || si_disadvantage_time+300 < world.time) return 1
	return 0.8

mob/proc/Update_SI_disadvantage(mob/m)
	if(!m || m==src) return
	si_disadvantage_against=m
	si_disadvantage_time=world.time

obj/Skills/Utility/Shunkan_Ido
	name="Instant Transmission"
	teachable=1
	hotbar_type="Ability"
	can_hotbar=1
	Skill=1
	Teach_Timer=18
	student_point_cost = 150
	Cost_To_Learn=90
	clonable=0
	var/tmp/using_si
	desc="Shunkan Ido, also known as Instant Transmission, is self-explanatory. If you know a person's \
	energy you can teleport to them. Anyone next to you will also be teleported."
	verb/Hotbar_use()
		set hidden=1
		Instant_Transmission()
	verb/Instant_Transmission(mob/A in usr.SI_Choices())
		set src=usr.contents
		set category = "Skills"
		if(!A||A=="Cancel") return
		if(Ki<100)
			usr.SendMsg("You do not have enough energy", CHAT_IC)
			return
		if(usr.Cant_SI(show_message=0)) return
		if(usr.Cant_SI(A)) return
		if(using_si)
			usr.SendMsg("You are already using this", CHAT_IC)
			return
		using_si=1
		for(var/mob/M in player_view(15,usr))
			M.SendMsg("[usr] begins concentrating...", CHAT_IC)
		usr.SendMsg("This may take a minute...", CHAT_IC)
		var/turf/old_loc=usr.loc
		var/timer=round(45/Level)
		if(timer<6) timer=6
		for(var/v in 1 to timer)
			if(usr&&usr.loc!=old_loc)
				usr.SendMsg("You moved and lost your focus, teleport cancelled.", CHAT_IC)
				using_si=0
				return
			sleep(10)
		if(!usr) return
		Level+=0.2*usr.mastery_mod
		if(A&&usr)
			if(usr.Cant_SI())
				using_si=0
				return
			if(usr.Cant_SI(A,show_message=0))
				using_si=0
				return
			usr.SendMsg("You found their energy signature.", CHAT_IC)
			for(var/mob/M in player_view(15,usr))
				M.SendMsg("[usr] disappears in a flash!", CHAT_IC)
			player_view(10,src)<<sound('teleport.ogg',volume=30)
			if(!usr.tournament_override(fighters_can=0,show_message=0))
				for(var/mob/B in oview(1,usr))
					if(B == usr) continue //2 calls to SafeTeleport in the same tick does not work
					if(B.client && !B.Prisoner())
						if(!B.Safezone)
							for(var/mob/M in player_view(15,B))
								M.SendMsg("[B.name] disappears!", CHAT_IC)
							B.SafeTeleport(A.loc)
							step_rand(B)
							spawn(1)
								for(var/mob/M in player_view(15,B))
									M.SendMsg("[B.name] suddenly appears!", CHAT_IC)
						else B.SendMsg("[usr.name] tried to teleport you, but it failed because you are in a safezone.", CHAT_IC)
			usr.SafeTeleport(A.loc)
			usr.Update_SI_disadvantage(A)
			step_rand(usr)
			oview(10,src)<<sound('teleport.ogg',volume=30)
		else usr.SendMsg("[A.name] logged out...", CHAT_IC)
		using_si=0

mob/proc/Cant_Kai_Teleport(destination)
	if(Race!="Kai" && logout_timer && z != 18)
		src.SendMsg("You can not teleport away if you were recently damaged", CHAT_IC)
		return 1
	if(KO)
		src.SendMsg("You can not teleport while knocked out", CHAT_IC)
		return 1
	if(Teleport_nulled())
		src.SendMsg("There is a teleport nullifier somewhere disrupting your ability to teleport", CHAT_IC)
		return 1
	if(destination && Planet_has_teleport_nullifier(destination,src))
		return 1
	if(InFinalRealm()||Prisoner())
		src.SendMsg("You can not teleport out of this place.", CHAT_IC)
		return 1
	if(Ki<max_ki*0.9 && Race != "Kai")
		src.SendMsg("You need 90%+ energy to use this", CHAT_IC)
		return 1

proc/Planet_has_teleport_nullifier(planet,mob/reciever)
	for(var/obj/Giant_Teleport_Nullifier/tn in teleport_nullifiers) if(tn.z)
		var/area/a=tn.get_area()
		if(a.name==planet)
			if(reciever) reciever.SendMsg("[planet] has a teleport nullifier somewhere on it, you can't get a lock on it", CHAT_IC)
			return 1

proc/Get_kt_spawn(area_name)
	if(!area_name) return
	var/kt_z
	var/area/kt_area
	for(var/area/a in all_areas) if(a.name==area_name)
		kt_area=a
		break
	switch(area_name)
		if("Checkpoint") kt_z=5
		if("Heaven") kt_z=7
		if("Arconia") kt_z=8
		if("Earth") kt_z=1
		if("Puranto") kt_z=3
		if("Braal") kt_z=4
		if("Ice") kt_z=12
		if("Desert") kt_z=14
		if("Jungle") kt_z=14
		if("Android") kt_z=14
		if("Kaioshin") kt_z=13
		if("Atlantis") kt_z=11
		if("Space") kt_z=16
		if("Hell") kt_z=6
	if(!kt_z||!kt_area) return
	var/turf/t
	for(var/v in 1 to 25)
		t=locate(rand(1,world.maxx),rand(1,world.maxy),kt_z)
		var/area/t_area=t.loc
		if(!t.Builder&&!t.density&&t_area==kt_area) break
	return t

obj/Skills/Divine/Kai_Teleport
	teachable=1
	name="Kai Teleport"
	Skill=1
	hotbar_type="Ability"
	can_hotbar=1
	race_teach_only=1
	//Cost_To_Learn=100
	Teach_Timer=24
	student_point_cost = 150
	desc="Teleport to any planet. This will drain all your energy. Anyone who is beside \
	you will be taken with you."

	verb/Hotbar_use()
		set hidden=1
		Kai_Teleport()

	verb/Kai_Teleport()
		set category = "Skills"
		if(usr.Cant_Kai_Teleport()) return
		var/list/Planets=new
		Planets.Add("Cancel","Checkpoint","Heaven","Hell","Arconia","Earth","Puranto","Braal","Ice","Desert","Jungle",\
		"Android","Kaioshin","Space")

		for(var/obj/Planets/p in planets) if(p.name in disabled_planets) Planets-=p.name
		var/image/I=image(icon='Black Hole.dmi',icon_state="full")
		I.icon+=rgb(rand(0,255),rand(0,255),rand(0,255))
		var/turf/T
		var/n=input("Choose a realm") in Planets
		if(!n||n=="Cancel") return
		if(usr.Cant_Kai_Teleport(destination=n)) return

		T=Get_kt_spawn(n)

		if(!T) return

		var/ktDrain = usr.max_ki * 0.35
		if(usr.Race == "Kai") ktDrain = 0
		if(usr.Ki < ktDrain) return
		else usr.IncreaseKi(-ktDrain)

		flick(I,usr)

		var/turf/t = usr.loc
		if(usr.Race != "Kai") for(var/v in 1 to 5)
			if(!usr) return
			if(usr.loc != t)
				usr.SendMsg("You must stand still to teleport", CHAT_IC)
				return
			sleep(10)

		if(!usr||usr.KO)
			return
		if(!usr.tournament_override(fighters_can=0,show_message=0)) for(var/mob/P in oview(1)) if(!P.Prisoner())
			if(!P.drone_module||P.client)
				if(!P.Safezone) P.SafeTeleport(T)
				else P.SendMsg("[usr] tried to teleport you, but couldn't because your in a safezone", CHAT_IC)
		if(usr) usr.SafeTeleport(T)

obj/Skills/var/Is_Buff

mob/proc/IncreaseGod_FistLevel()
	var/old_God_Fist_level = God_Fist_level

	switch(God_Fist_level)
		if(0) God_Fist_level = 2
		if(2) God_Fist_level = 4
		if(4) God_Fist_level = 10
		if(10) God_Fist_level = 20

	if(old_God_Fist_level == 20) PowerUpGoNextForm()

mob/var/tmp/obj/Skills/Ultra_Super_Yasai/ussj_obj

mob/proc/PowerUpGoNextForm()
	var/transformation/current = GetActiveForm()
	if(!current || current == "Base")
		TryEnterForm(GetBaseForm())
	else
		current.GoNextForm(src)
	Aura_Overlays()
	return current

mob/proc/Power_up()
	if(!powerup_obj) return
	if(KO) return
	if(ismob(loc)) return

	if(God_Fist_obj && God_Fist_obj.Using)
		if(grabber)
			src.SendMsg("You can not perform God_Fist while being grabbed", CHAT_IC)
			return
		if(!God_Fist_level && !ultra_instinct) player_view(10,src)<<'powerup.wav'
		if((God_Fist_level < 20))
			Make_Shockwave(src,sw_icon_size=256)
			for(var/mob/P in player_view(20,src)) P.ScreenShake(20,8)
		IncreaseGod_FistLevel()
		GodFistDrain()
		return

	if(powerup_obj.Powerup==-1)
		src.SendMsg("You stop powering down", CHAT_IC)
		powerup_obj.Powerup=0
	else if(!powerup_obj.Powerup)
		if(IsGreatApe())
			if(Race=="Yasai" && CanGoGoldenApe())
				GoldenGreatApe()
				return
			else
				src.SendMsg("You can not use power up while in Great_Ape form", CHAT_IC)
				return
		if(IsTournamentFighter() && !IsRoundFighter())
			src.SendMsg("You can not power up until it is your turn to fight", CHAT_IC)
			return
		powerup_obj.Powerup=1
		src.SendMsg("You begin powering up", CHAT_IC)
		Aura_Overlays()
		if(BPpcnt<=100) Make_Shockwave(src,sw_icon_size=256)
		if(!ultra_instinct) player_view(10,src)<<sound('aura3.ogg',volume=10)
		else player_view(10,src) << sound('Blast.wav',volume = 10)
	else if(!Redoing_Stats)
		if(PowerUpGoNextForm())
			return
	PowerControlStart(powerup_obj)
	Aura_Overlays()

mob/proc/CanGoGoldenApe()
	if(!("Omega Yasai" in UnlockedTransformations) || !("Omega Yasai 2" in UnlockedTransformations)) return 0
	var/transformation/OY = UnlockedTransformations["Omega Yasai"]
	var/transformation/OY2 = UnlockedTransformations["Omega Yasai 2"]
	if(!OY || !OY2) return 0
	if(OY.mastery < 100 || OY2.mastery < 100) return 0
	return 1

obj/Skills/Utility/Power_Orb
	teachable = 0
	Skill = 1
	Cost_To_Learn = 50
	desc = "This allows you to simulate a full moon, at the cost of some energy.  Doing so will enable transformation \
	into a Great Ape.  However, it will be slightly weaker than a natural moon."

	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Power_Orb()
	
	verb/Power_Orb()
		set category = "Skills"
		usr.Power_Orb()

mob/var/lastPowerOrbUse = 0

mob/proc/Power_Orb()
	if(!current_area) return
	if(PowerOrbOnCD())
		src << "You can't muster the energy to create a Power Orb currently."
		return
	IncreaseKi(-Math.Rand(max_ki * 0.05, max_ki * 0.15))
	current_area.FullMoonTrans(1)
	current_area.powerOrbExists = 1
	lastPowerOrbUse = world.realtime
	spawn(900) current_area.powerOrbExists = 0

mob/proc/PowerOrbOnCD()
	return (world.realtime - lastPowerOrbUse < Time.FromHours(1))

obj/Skills/Utility/Power_Control
	teachable=1
	Skill=1
	Teach_Timer=3
	student_point_cost = 15
	can_hotbar=0
	Cost_To_Learn=5
	Mastery=1
	desc="This allows you to power up and power down. Also, for certain forms, such as those of \
	Yasais and Frost Lords, powering up twice will cause them to go into their next form, powering \
	down twice will cause them to revert. Powering up will increase your Battle Power, but drain your \
	energy the higher you go. The more energy you have the higher you can power up without worrying \
	about the drain sucking you back down again."
	var/Powerup=0
	var/tmp/PC_Loop_Active

	New()
		spawn if(ismob(loc))
			var/mob/M=loc
			M.powerup_obj=src

	Del()
		var/mob/m=loc
		if(m && ismob(m)) m.Stop_Powering_Up()
		. = ..()

	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Power_Up()

	verb/Power_Up()
		set category = "Skills"
		usr.Power_up()

	verb/Power_Down()
		set category = "Skills"
		if(usr.KO) return
		if(usr.God_Fist_obj && usr.God_Fist_obj.Using)
			if(!usr.God_Fist_level) usr.PowerDownRevert()
			usr.God_FistStop()
			usr.Aura_Overlays()
			return
		if(Powerup > 0)
			Powerup = 0
			usr.SendMsg("You stop powering up", CHAT_IC)
		else if(usr.PowerDownRevert()) return
		else
			Powerup = -1
			usr.SendMsg("You begin powering down", CHAT_IC)
			if(usr) usr.Aura_Overlays()

mob/proc/PowerDownRevert()
	var/transformation/current = GetActiveForm()
	if(!current) return 0
	current.GoPreviousForm(src)
	Aura_Overlays()
	return 1

proc/CenterIcon(obj/O,Icon,x_only)
	set waitfor = FALSE
	set background = TRUE
	if(!O) return
	if(!Icon) Icon=O.icon
	O.pixel_x = Icon_Center_X(Icon)
	if(!x_only) O.pixel_y = Icon_Center_Y(Icon)

proc/CenterBounds(obj/O,icon/I,x_only)
	if(!O) return
	if(!I) I = icon(O.icon)
	O.bound_x = Icon_Center_X(I)
	O.bound_width = I.Width()
	if(!x_only)
		O.bound_y = Icon_Center_Y(I)
		O.bound_height = I.Height()

proc/Icon_Center_X(O)
	var/icon/I=new(O)
	return -((I.Width()-TILE_WIDTH)*0.5)

proc/Icon_Center_Y(O)
	var/icon/I=new(O)
	return -((I.Height()-TILE_HEIGHT)*0.5)

proc/Scaled_Icon(O,X,Y)
	var/icon/I=new(O)
	if(X && Y) I.Scale(X,Y)
	return I

proc/GetWidth(O)
	var/icon/I=new(O)
	return I.Width()

proc/GetHeight(O)
	var/icon/I=new(O)
	return I.Height()

mob/var/icon
	Aura='Aura.dmi'
	FlightAura='Aura Fly.dmi'
	BlastCharge='Charge1.dmi'
	Burst='Burst.dmi'
	SSj4Aura='Aura SSj4.dmi'

obj/Auras
	icon='Aura, Big.dmi'
	Givable=0
	can_change_icon=1
	var/tmp/image/Old
	var/God_Fist='Aura, Kaioken, Big.dmi'
	var/Init
	var/auraYoffset = 0
	New()
		if(!Init)
			Init=1
			icon=Scaled_Icon(icon,74,74)
			God_Fist=Scaled_Icon(God_Fist,84,84)

mob/var/tmp/obj/Auras/Auras

mob/proc/Stop_Powering_Up()
	powerup_mobs-=src
	if(powerup_obj && istext(powerup_obj))
		if(BPpcnt>100) BPpcnt=100
		Aura_Overlays(remove_only=1)
		
	else if(powerup_obj && (powerup_obj.Powerup in list(0,1)))
		powerup_obj.Powerup=0
		if(BPpcnt>100) BPpcnt=100
		Aura_Overlays(remove_only=1)

mob/proc/Aura_Overlays(remove_only)

	if(!Auras) for(var/obj/Auras/A in src) Auras=A
	if(!Auras) return

	if(remove_only || (BPpcnt<=100 && !God_Fist_level))
		overlays -= Auras.Old
		underlays -= Auras.Old
		Add_Sparks()

	else
		var/image/I=image(icon=Auras.icon)

		overlays-=Auras.Old
		underlays-=Auras.Old

		if(Class=="Legendary")
			I.icon='Aura, LSSj, Big.dmi'
		
		for(var/t in UnlockedTransformations)
			var/transformation/T = UnlockedTransformations[t]
			if(T.draining && T.aura)
				I.icon = Scaled_Icon(T.aura, T.auraScaleX, T.auraScaleY)
				break

		if(ultra_instinct) I.icon = ultra_instinct_aura

		if(God_Fist_level) I.icon = Auras.God_Fist

		I.pixel_x=Icon_Center_X(I.icon)
		if(I.icon == Auras.icon) I.pixel_y += Auras.auraYoffset

		overlays += I

		if(ultra_instinct) underlays += I

		Auras.Old=I
		Add_Sparks()

mob/proc/Remove_Sparks() overlays.Remove('Sparks LSSj.dmi','Electric_Mystic.dmi',\
'Demon Vampire Majin By Tobi Uchiha.dmi','LSSJ powerz.dmi','SSj2 Electric Tobi Uchiha.dmi',\
'SSj3 Electric Tobi Uchiha.dmi','USSj Electric Tobi Uchiha.dmi')

mob/proc/Add_Sparks()
	Remove_Sparks()

	//if(BPpcnt>100&&(ismajin||Vampire||Race=="Demon")) overlays+='Demon Vampire Majin By Tobi Uchiha.dmi'
	if(BPpcnt>100&&Vampire) overlays+='Demon Vampire Majin By Tobi Uchiha.dmi'

	if(BPpcnt>100)
		if(Class=="Legendary") overlays+='LSSJ powerz.dmi'

obj/Skills/Utility/Fly
	teachable=1
	hotbar_type="Ability"
	can_hotbar=1
	Skill=1
	Cost_To_Learn = 10
	student_point_cost = 25
	Teach_Timer=0.5
	desc="Obviously this lets you fly. But it drains energy to do so. The more you use it the more you \
	master it, and the more you master it, the less it drains. Also you can decrease the drain to a \
	lesser level by simply gaining more energy, but the effect is not the same as mastering the move \
	itself. This will let you move much faster than you can by walking."
	New()
		spawn if(ismob(loc))
			var/mob/m=loc
			m.fly_obj=src
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Fly()
	verb/Fly()
		set category = "Skills"
		if(usr.Action=="Meditating") usr.Meditate()
		if(usr.Action=="Training") usr.Train()
		if(!usr.Disabled())
			if(!usr.Flying) usr.Fly()
			else usr.Land()

mob/proc/Layer_Update()
	layer = MOVABLE_LAYER
	if(Flying) layer = FLYING_LAYER

mob/proc/CreateFlightVisuals()
	var/proxy_visual/flightShadow = new(null)
	flightShadow.name = "Flight Shadow"
	flightShadow.icon_pointer = "Ground shadow.dmi"
	flightShadow.vis_flags = VIS_INHERIT_ID|VIS_INHERIT_PLANE|VIS_INHERIT_LAYER
	flightShadow.vis_layer = REGISTER_UNDERLAY
	flightShadow.isHidden = !Flying
	flightShadow.isSaved = 0
	VisUnderlay(flightShadow)

mob/proc/Fly(obj/Skills/Utility/Fly/F)
	if(Flying) return
	if(!F) for(var/obj/Skills/Utility/Fly/O in src) F=O
	if(!F&&!client) contents+=new/obj/Skills/Utility/Fly
	if(!F) return
	if(Ki>=Fly_Drain()||!client||Cyber_Fly)
		player_view(10,src)<<sound('Jump.wav',volume=15)
		icon_state = "Flight"
		Flying=1
		var/proxy_visual/flightShadow = GetVisual("Flight Shadow")
		ShowVisual("Flight Shadow")
		animate(src, pixel_y = 16, time = 2)
		animate(flightShadow, pixel_y = -16, time = 2)
		Layer_Update()
		StopSwimming()
		Fly_loop()
		if(icon=='Demon6.dmi'||icon=='Demon6, Female.dmi')
			F.overlays-=F.overlays
			F.overlays=overlays
			overlays-=overlays
	else src.SendMsg("You are too tired to fly.", CHAT_IC)

mob/proc/Land()
	if(!Flying) return
	density=1
	icon_state=""
	Flying=0
	flight_boosted = 0
	var/proxy_visual/flightShadow = GetVisual("Flight Shadow")
	animate(src, pixel_y = 0, time = 2)
	if(flightShadow)
		animate(flightShadow, pixel_y = 0, time = 2)
		spawn(1.8) HideVisual("Flight Shadow")
	Layer_Update()
	for(var/obj/Skills/Utility/Fly/A in src) if(A.overlays)
		overlays+=A.overlays
		A.overlays-=A.overlays
	RegeneratorTick()
	if(istype(loc, /turf/liquid))
		StartSwimming()
	if(grabbedObject && ismob(grabbedObject))
		grabbedObject.SafeTeleport(loc)
		grabbedObject.RegeneratorTick()

mob/var/tmp/flight_boosted = 0
mob/proc/FlyBoost(disable = 0)
	if(disable)
		if(!flight_boosted) return
		flight_boosted = 0
	else
		if(flight_boosted) return
		if(stamina < BoostedFlightDrain() * 3) return
		IncreaseStamina(-BoostedFlightDrain() * 3)
		flight_boosted = 1
		// initial boost should have a bunch of dust effects flung out
		// add a distortion filter around the player

var/image/Self_Destruct_Fire=image(icon='Lightning flash.dmi',layer=99)

turf/proc/Self_Destruct_Lightning(B) if(B)
	overlays-=Self_Destruct_Fire
	overlays+=Self_Destruct_Fire
	spawn(B) if(src) overlays-=Self_Destruct_Fire

var/sd_wait_time = 20 //minutes

obj/Skills/Combat/Ki/Self_Destruct
	teachable=1
	Skill=1
	Cost_To_Learn=8
	Teach_Timer=5
	student_point_cost = 15
	hotbar_type="Ability"
	can_hotbar=1
	var/next_sd=0
	var/tmp/using_sd
	desc="Using this will kill you. It is an extremely powerful attack, one of the top 3 at least. \
	It will affect a large area. If you have death regeneration this attack is much weaker."

	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Self_Destruct()

	verb/Self_Destruct()
		set category = "Skills"
		if(usr.KO) return

		//because dead people would cheat in fights, SD, come back instantly at 100% power, kill you
		if(usr.Dead)
			usr.SendMsg("Dead people can not self destruct", CHAT_IC)
			return

		if(usr.grabber)
			usr.SendMsg("You can not perform self destruct because you are being grabbed", CHAT_IC)
			return
		if(world.realtime<next_sd)
			usr.SendMsg("You must wait [sd_wait_time] minutes before you can do this again", CHAT_IC)
			return
		if(usr.cant_blast()) return
		if(usr.tournament_override(fighters_can=0)) return

		//if("self destruct" in usr.active_prompts) return
		//usr.active_prompts+="self destruct"
		//switch(input("Self Destruct?") in list("No","Yes"))
		//	if("No") usr.active_prompts-="self destruct"
		//	if("Yes")

		usr.active_prompts-="self destruct"
		if(Using||usr.KO||usr.tournament_override(fighters_can=0))
			return
		var/sd_time_add = (sd_wait_time * 60 * 10)

		next_sd=world.realtime + sd_time_add
		using_sd=1
		usr.move=0

		player_view(10,usr)<<sound('aura3.ogg',volume=30)
		for(var/mob/M in player_view(12,usr))
			M.SendMsg("A huge explosion eminates from [usr] ([usr.displaykey]) and surrounds the area!", CHAT_IC)
		player_view(10,usr)<<sound('basicbeam_fire.ogg',volume=20)
		Make_Shockwave(usr,sw_icon_size=512)
		var/Dist=10
		for(var/N=0,N<5,N++) for(var/turf/T in view(Dist)) if(T.opacity&&(T.Health<usr.BP)&&usr.Is_wall_breaker())
			T.Health=0
			T.Destroy()
		for(var/turf/T in view(Dist))
			for(var/obj/O in T) if(O.Health <= usr.WallBreakPower())
				if(O.Health != 1.#INF)
					BigCrater(O.loc)
					del(O)
					break //no need for more than 1 crater in the same spot
			for(var/mob/P in T) if(P!=usr)
				if(!P.AOE_auto_dodge(usr,usr.loc))
					if(P.IsShielding()) P.IncreaseKi(-(2 * Get_self_destruct_damage(usr,P) * P.ShieldDamageReduction() * (P.max_ki/100)/(P.Eff**shield_exponent)*P.Generator_reduction()))
					else
						var/dmg = Get_self_destruct_damage(usr,P)
						P.TakeDamage(dmg, usr)
					if(P.Health<=0||P.Ki<=0)
						var/anger_wait=2400
						if(world.time>P.last_anger+anger_wait)
							P.Enrage(anger_mult=1)
							var/dmg = Get_self_destruct_damage(usr,P)
							P.TakeDamage(dmg, usr)
			if(usr && T) if((T.Health < usr.WallBreakPower()) && usr.Is_wall_breaker())
				if(T.Health != 1.#INF)
					T.Health=0
					T.Destroy()
			var/Timer=rand(50,100)
			T.Self_Destruct_Lightning(Timer)
			if(prob(4)) Dust(T, end_size = 1.5, time = 25, start_delay = Timer)
			if(prob(5)) sleep(TickMult(1))
		if(usr)
			usr.Death(usr)
			usr.Ki=0
			usr.move=1
		using_sd=0

proc/Get_self_destruct_damage(mob/a,mob/b)
	var/dmg = 130 + (a.GetStatMod("For") * a.GetTierBonus(0.5) - (b.GetStatMod("Res") * b.GetTierBonus(0.75)))
	if(a.Class=="Spirit Doll") dmg*=1.5

	if(a.Regenerate || (locate(/obj/Module/Rebuild) in a.active_modules)) dmg *= 0.5

mob/proc/AOE_auto_dodge(mob/attacker,turf/origin,min_dist=7,max_dist=10)
	if(KO||KB||Frozen||Safezone) return
	var/turf/original_loc=loc
	var/auto_dodge = 5*((Def/attacker.Off)**2)*(BP/attacker.BP)


	if(ultra_instinct) auto_dodge = 100

	if(precog&&precogs&&prob(precog_chance)&&Ki>max_ki*0.2)
		precogs--
		auto_dodge=100
	if(prob(auto_dodge)&&client)
		var/list/safe_turfs=new
		for(var/turf/t in view(max_dist,src))
			if(getdist(src,t)>=min_dist&&!t.density&&!(locate(/obj) in t))
				var/d=get_dir(origin,src)
				if(get_dir(src,t) in list(d,turn(d,45),turn(d,-45)))
					safe_turfs+=t
		if(safe_turfs.len)
			var/turf/safe_turf=pick(safe_turfs)
			SafeTeleport(safe_turf)
			flick('Zanzoken.dmi',src)
			player_view(10,src)<<sound('teleport.ogg',volume=15)
			if(ultra_instinct)
				SafeTeleport(attacker.loc)
				step_away(src,attacker,5,32)
			if(loc != original_loc) return 1

mob/var/last_revived=0 //realtime

obj/Skills/Divine/Kaio_Revive
	name="Revive"
	Skill=1
	hotbar_type="Support"
	can_hotbar=1
	Cost_To_Learn=40
	desc="This will bring someone back to life. Just face them and use it"
	teachable=1
	Teach_Timer=24
	student_point_cost = 50
	clonable=0
	var/next_use=0
	var/revive_delay=1.3 //hours
	New() if(!next_use) next_use=world.realtime+(revive_delay*60*60*10)
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Revive_Someone()
	verb/Revive_Someone()
		set category = "Skills"
		if(usr.Android)
			usr.SendMsg("Androids cannot use natural-only abilities", CHAT_IC)
			return
		if(usr.Dead)
			usr.SendMsg("You cannot use this if you are dead.", CHAT_IC)
			return
		for(var/mob/A in Get_step(usr,usr.dir)) if(A.client&&A.Dead)
			if(usr.client.address==A.client.address)
				usr.SendMsg("You can not revive alts", CHAT_IC)
				return
			if(world.realtime<next_use)
				var/hours=(next_use-world.realtime)/10/60/60
				usr.SendMsg("You can not revive anyone for another [round(hours)] hours and [round(hours*60 %60)] minutes", CHAT_IC)
				return

			var/mins=4
			if(world.realtime-A.death_time < mins*60*10)
				var/wait_time=mins - (world.realtime - A.death_time)/10/60
				usr.SendMsg("[A] must be dead for [round(wait_time)] more minutes to be revived by this ability", CHAT_IC)
				A.SendMsg("You must be dead for [round(wait_time)] more minutes before you can be revived this way", CHAT_IC)
				return

			var/minutes=50
			if(A.base_bp > Avg_Base * 1.3 && world.realtime < A.last_revived + Time.FromMinutes(minutes))
				var/minutes_left = (A.last_revived + Time.FromMinutes(minutes)) - world.realtime
				usr.SendMsg("[A] can not be revived because they were revived less than [minutes] minutes ago. They \
				must wait another[Time.GetRoundedTime(minutes_left)] to be revived \
				again by the revive skill", CHAT_IC)
				A.SendMsg("[usr] tries to revive you, but you were revived less than [minutes] minutes ago, and must \
				wait another[Time.GetRoundedTime(minutes_left)] to be revived again by the \
				revive skill", CHAT_IC)
				return
			for(var/mob/M in player_view(15,usr))
				M.SendMsg("[A] is revived by [usr]", CHAT_IC)
			A.GiveFeat("Get revived by revive skill")
			next_use=world.realtime+(revive_delay*60*60*10)
			A.last_revived=world.realtime
			A.Revive()
			sleep(30)
			A.Respawn()
			return
		alert("Use this to bring someone in front of you back to life. Currently there is no dead person in front of you")

mob/var/healgaintime
obj/Skills/Utility/Heal
	teachable=1
	Skill=1
	Cost_To_Learn=5
	hotbar_type="Support"
	can_hotbar=1
	Teach_Timer=4
	student_point_cost = 30
	var/Next_Injury_Heal=0
	desc="You can heal anyone in front of you by giving up some of your own health and energy. If they \
	have certain status problems they can be further alleviated by healing them, with multiple heals \
	they may be cured."

	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Heal()

	verb/Heal()
		set category = "Skills"
		if(usr.Android)
			usr.SendMsg("Androids cannot use natural-only abilities", CHAT_IC)
			return
		if(usr.tournament_override(fighters_can=0)) return
		var/Ki_Drain=usr.max_ki/usr.Eff
		if(Ki_Drain>usr.max_ki) Ki_Drain=usr.max_ki
		if(usr.KO||usr.Ki<Ki_Drain) return
		for(var/mob/A in Get_step(usr,usr.dir))
			if(!A.client || A == usr) continue
			var/Health_Drain=50
			if(usr.Race=="Puranto") Ki_Drain/=2
			usr.TakeDamage(Health_Drain, "heal")
			usr.IncreaseKi(-(usr.max_ki/usr.Eff))
			Skill_Increase(10,usr)
			A.healgaintime=world.realtime+300
			usr.healgaintime=world.realtime+300
			A.FullHeal()
			A.IncreaseDetermination(A.determination * 2.5)
			for(var/mob/M in player_view(15,usr))
				M.SendMsg("<font color=#FFFF00>[usr] heals [A]", CHAT_IC)
			if(A.CheckForInjuries())
				for(var/injury/I in A.injuries)
					I.remove_at -= 0.1 * usr.Eff
					A.TryRemoveInjury(I)
			return
		alert("Use this to heal someone in front of you. Currently there is no one in front of you")

mob/var/next_unlock=0
mob/proc/potential_mod()
	if(Class=="Spirit Doll") return 2
	if(Race=="Half Yasai") return 1.4
	else if(Race=="Human") return 2
	else if(Race=="Tsujin") return 1.8
	else if(Race=="Puranto") return 1.25
	else if(Race=="Android") return 0
	else if(Race=="Frost Lord") return 0.6
	else if(Race=="Kai") return 1.5
	return 1

obj/Skills/Divine/Unlock_Potential
	teachable=1
	Skill=1
	hotbar_type="Support"
	can_hotbar=1
	Teach_Timer=12
	student_point_cost = 40
	Cost_To_Learn=30
	var/Usable=0 //The year you may next use this.
	desc="Using this on someone will greatly increase their power and energy. Each use will add 5 years \
	to how long you must wait to use it on someone again."
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Unlock_Potential()

	verb/Unlock_Potential()
		set category = "Skills"
		var/mob/A
		for(A in Get_step(usr,usr.dir)) break
		if(!A || A == usr) return
		if(world.realtime < A.nextUnlockUse)
			usr << "[A.name] can't have there potential unlocked for another [round(Time.ToMinutes(A.nextUnlockUse - world.realtime))] minutes."
		if(usr.Android)
			usr.SendMsg("Androids cannot use natural-only abilities", CHAT_IC)
			return
		if(A.Android)
			usr.SendMsg("Androids can not have their potential unlocked", CHAT_IC)
			return
		if(istype(A,/mob/new_troll))
			sleep(rand(40,60))
			for(var/mob/M in player_view(15,usr))
				M.SendMsg("[usr] uses unlock potential on [A]", CHAT_IC)
			return
		if(!A.client)
			usr<<"NPCs can not be unlocked"
			return

		for(var/mob/M in player_view(15,usr))
			M.SendMsg("<font color=cyan>[usr] unlocks the hidden powers of [A]!", CHAT_IC)
		A.TryUnlockForm("Mystic")
		A.unlockedBP += A.unusedPotential
		A.unusedPotential = 0
		A.nextUnlockUse = world.realtime + Time.FromHours(1)

mob/var/unlockedBP = 0 //from UP
mob/var/unusedPotential = 0
mob/var/nextUnlockUse = 0

obj/Skills/Combat/Ki/Taiyoken
	teachable=1
	name = "Solar Flare"
	Skill=1
	Cost_To_Learn=2
	Teach_Timer=1
	student_point_cost = 10
	desc = "Solar Flare blinds people. The range increases the higher your energy mod is. The time you will be blinded is solely dependent on your regeneration \
	stat. How strong the person using Solar Flare does not affect the duration."
	var/tmp/next_taiyoken=0

	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		//Solar_Flare()
		usr.TrySolarFlare() //new version

	can_hotbar=1
	hotbar_type="Ability"
	verb/Solar_Flare()
		set category = "Skills"

		usr.TrySolarFlare()
		return

		if(usr.tournament_override(fighters_can=1)) return
		if(usr.KO) return
		if(world.time<next_taiyoken)
			var/minutes=next_taiyoken-world.time
			usr.SendMsg("You can not use this for another [round(minutes)] minutes and [round(minutes%60)] seconds", CHAT_IC)
			return
		if(!usr.attacking)
			usr.IncreaseKi(-150)
			next_taiyoken=world.time+(3*60*10)
			var/distance=round(usr.Ki*0.01)
			if(distance>10) distance=10
			if(distance<2) distance=2
			for(var/turf/A in view(distance,usr)) A.Self_Destruct_Lightning(4)
			sleep(4)
			for(var/turf/A in view(distance,usr)) A.Self_Destruct_Lightning(5)
			sleep(4)
			for(var/mob/A in player_view(distance,usr)) if(!A.sight)
				if(get_dir(A,usr) in list(A.dir,turn(A.dir,45),turn(A.dir,-45)))
					A.SendMsg("You are blinded by [usr]'s Taiyoken", CHAT_IC)
					var/n = 15 + (usr.GetStatMod("For") * usr.GetTierBonus(0.1) * usr.Eff - A.GetStatMod("Res") * A.GetTierBonus(0.5) * A.regen)
					n = Math.Max(Math.Floor(n), 60)
					A.taiyoken_blind_time=n
					A.Taiyoken_Blindness_Timer()
				else A.SendMsg("You were not looking directly at [usr]'s Taiyoken, so you were not blinded", CHAT_IC)

mob/var
	tmp/taiyoken_blindness_loop=0
	taiyoken_blind_time=0

mob/proc/Taiyoken_Blindness_Timer()
	set waitfor=0
	sight=0
	if(taiyoken_blindness_loop || taiyoken_blind_time <= 0) return
	taiyoken_blindness_loop=1
	sight=1
	sleep(taiyoken_blind_time)
	taiyoken_blindness_loop=0
	taiyoken_blind_time=0
	sight=0

obj/Skills/Divine/Rift_Teleport
	verb/Rift_Teleport()
		set category = "Skills"
		var/image/I=image(icon='Black Hole.dmi',icon_state="full")
		switch(input("Person or Location?") in list("Person","Location",))
			if("Location")
				var/xx=input("X Location?") as num
				var/yy=input("Y Location?") as num
				var/zz=input("Z Location?") as num
				for(var/mob/M in player_view(15,usr))
					M.SendMsg("[usr] disappears into a mysterious rift that disappears after they enter.", CHAT_IC)
				spawn flick(I,usr)
				sleep(10)
				usr.SafeTeleport(locate(xx,yy,zz))
				for(var/mob/M in player_view(15,usr))
					M.SendMsg("[usr] appears out of a rift in time-space.", CHAT_IC)
			else
				var/list/A=new
				for(var/mob/M in players) if(M.client) A.Add(M)
				var/Choice=input("Who?") in A
				for(var/mob/M in player_view(15,usr))
					M.SendMsg("[usr] disappears into a mysterious rift that disappears after they enter.", CHAT_IC)
				spawn flick(I,usr)
				sleep(10)
				for(var/mob/M in A) if(M==Choice) usr.SafeTeleport(locate(M.x+rand(-1,1),M.y+rand(-1,1),M.z))
				for(var/mob/M in player_view(15,usr))
					M.SendMsg("[usr] appears out of a rift in time-space.", CHAT_IC)

obj/Skills/Utility/Imitation
	name = "Imitate Player"
	desc="You can use this on someone to imitate them in almost every way, so much so that you may \
	be confused with them. You can hit it again to stop imitating."
	var/imitating
	var/imitatorname
	var/old_text_color
	var/old_key
	Skill=1
	var/list/imitatoroverlays=new
	var/imitatoricon
	verb/Imitate_Player()
		set category = "Skills"
		if(!imitating)

			var/list/People=new
			for(var/mob/A in player_view(15,usr)) People.Add(A)
			var/Choice=input("Imitate who?") in People
			if(imitating) return
			for(var/mob/A in People) if(A==Choice)
				imitating=1
				imitatorname=usr.name
				imitatoroverlays=usr.overlays
				imitatoricon=usr.icon
				old_key=usr.displaykey
				old_text_color=usr.TextColor

				usr.icon=A.icon
				//usr.displaykey=A.displaykey
				usr.overlays=null
				usr.overlays+=A.overlays
				usr.name=A.name
				usr.TextColor=A.TextColor
				break
		else
			imitating=0
			usr.TextColor=old_text_color
			//usr.displaykey=old_key

			//usr.displaykey=usr.key //temp. fixes a bug with double imitates making you have the wrong key

			usr.name=imitatorname
			usr.overlays=null
			usr.overlays+=imitatoroverlays
			usr.icon=imitatoricon
			imitatoroverlays=new/list

obj/Skills/Divine/Invisibility
	desc="You can use this to make yourself invisible. Some people with very good senses will still \
	know you are there, or if they have visors capable of seeing invisible objects."
	Skill=1
	verb/Invisibility()
		set category = "Skills"
		if(!usr.invisibility)
			usr.invisibility+=1
			usr.see_invisible+=1
			usr.SendMsg("You are now invisible.", CHAT_IC)
		else
			usr.see_invisible-=1
			usr.invisibility-=1
			usr.SendMsg("You are visible again.", CHAT_IC)
mob/var
	precog //for the blast avoidance...
	precog_chance=100
	precogs=1
mob/proc/precog_loop()
	set waitfor=0
	while(src)
		if(!precog) return
		while(precogs) sleep(100)
		sleep(900)
		precogs=ToOne(6*Clamp(def_share(),0.5,1))

mob/var/precogProgress = 0

mob/proc/RegeneratePrecogs()
	precogProgress++
	if(precogProgress >= 180)
		precogProgress = 0
		precogs = 4 + GetStatMod("Ref") + Math.Floor(GetStatMod("Spd") / 2)
		precogs = Math.Max(precogs, 3)

mob/proc/Observe_List()
	var/list/L=new
	for(var/mob/A in players) L+=A
	for(var/mob/m in trollbots) L += m
	for(var/obj/A in view(40,src)) L+=A
	for(var/mob/A in view(10,src)) L+=A
	for(var/turf/A in view(10,src)) L+=A
	return L

mob/var/adminObserve //with this you can bypass the rules of observe to observe anyone

obj/Skills/Utility/Observe
	teachable=1
	Skill=1
	Cost_To_Learn=1
	hotbar_type="Ability"
	can_hotbar=1
	Teach_Timer=1
	student_point_cost = 5

	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Observe()

	verb/Observe()
		set src=usr.contents
		set category = "Skills"
		if(observing)
			usr.Reset_Observe()
			return
		var/atom/A = input("Observe what?") in usr.Observe_List()
		if(!usr.observing) usr.Observe_A_Mob(A)
		else usr.Reset_Observe()

	Advanced
		name = "Advanced Observe"
		Cost_To_Learn=40
		student_point_cost = 120
		Observe()
			set src=usr.contents
			set category = "Skills"
			if(observing)
				usr.Reset_Observe()
				return
			var/atom/A = input("Observe what?") in usr.Observe_List()
			if(!usr.observing) usr.Observe_A_Mob(A,1)
			else usr.Reset_Observe()

atom/var
	tmp/list/Observers = new
	tmp/atom/observing

mob/proc/Observe_A_Mob(atom/A, hear_observe=0, force_observe=0)

	if(!force_observe)
		if(ismob(A))
			var/mob/m=A
			if(m.hiding_energy && m != usr)
				usr.SendMsg("You can not observe them because they are hiding their energy", CHAT_IC)
				return
			if(m.Is_Cybernetic()&&m!=usr)
				usr.SendMsg("You can not observe cyborgs/androids because their energy is unsenseable", CHAT_IC)
				return

	usr.Get_Observe(A)


mob/Admin1/verb/Observe(atom/A in Observe_List())
	set category="Admin"
	if(A != usr && usr.observing != A)
		usr.Reset_Observe()
		usr.Observe_A_Mob(A,1,1)
	else
		usr.Reset_Observe()

mob/proc/Get_Observe(mob/M) if(client)
	client.eye=M
	observing = M
	observing.Observers|=src

mob/proc/Reset_Observe() if(client)
	if(Ship) client.eye=Ship
	else client.eye=src
	observing?.Observers-=src
	observing = null

obj/Skills/Divine/Materialization
	name = "Materialize"
	teachable=1
	Skill=1
	Cost_To_Learn=20
	Teach_Timer=2
	race_teach_only=1
	student_point_cost = 100
	Mastery=100
	hotbar_type="Support"
	can_hotbar=1
	desc="This ability lets you create weighted clothes to accelerate training. \
	Your energy mod and Force stat will improve the quality of weights you make."
	var
		weight_tier=1 //can go as high as someone wants

	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Materialize()

	verb/Materialize()
		set category = "Skills"
		var/max_weight= (usr.max_weight() / 2) * usr.Eff * (usr.Pow / 6)
		var/obj/items/Weights/A=new(Get_step(usr,usr.dir))
		A.weight=max_weight
		A.weight_name()

obj/Skills/Divine/Majin

	New()
		if(!icon) icon='Aura Electric.dmi'+rgb(150,0,0)

	teachable=1
	Skill=1
	hotbar_type="Buff"
	can_hotbar=1
	Teach_Timer=6
	student_point_cost = 100
	can_change_icon=1
	race_teach_only=0
	var/using = 0
	desc="\
	Grant someone the following buffs in exchange for their loyalty:<br>\
	20% BP increase<br>\
	30% stronger anger<br>\
	Increase recovery by 40%<br>\
	Decrease leech by 30%<br>\
	Decrease zenkai by 30%<br>\
	"

	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Majinize()

	verb/Majinize(mob/M in oview(1))
		set category = "Skills"
		if(!M || !M.client || M == usr) return
		if(using) return
		using = 1
		if(usr.Redoing_Stats)
			usr.SendMsg("You can not use this while choosing stat mods", CHAT_IC)
			return
		if(M.majinCurse)
			var/obj/MajinCurse/O = M.majinCurse
			if(O.creator == usr.key)
				switch(alert(usr, "Free [M.name] from their curse?",,"No","Yes"))
					if("Yes")
						O.Remove()
						del(O)
				using = 0
				return
			else
				usr << "They have already been cursed by another."
				using = 0
				return
		if(M.effectiveBaseBp > (usr.effectiveBaseBp * 0.75))
			switch(alert(M, "[usr.name] wishes to grant you power in exchange for your loyalty.  Do you accept?","Majinize","No","Yes"))
				if("No")
					using = 0
					return
		var/obj/MajinCurse/O = new()
		M.majinCurse = O
		O.creator = usr.key
		O.initialBP = M.effectiveBaseBp
		O.Apply(M)
		using = 0
		return

mob/var/obj/MajinCurse/majinCurse

obj/MajinCurse
	reallyDelete = 1
	var
		creator
		initialBP

	proc
		Apply(mob/M)
			if(!M || !ismob(M)) del(src)
			M.recov *= 1.4
			M.leech_rate *= 0.7
			M.zenkai_mod *= 0.7
			M.max_anger *= 1.3
		
		Remove(mob/M)
			if(!M || !ismob(M)) del(src)
			M.recov /= 1.4
			M.leech_rate /= 0.7
			M.zenkai_mod /= 0.7
			M.max_anger /= 1.3

mob/var/Restore_Youth=0 //How many times you have had youth restored

obj/Skills/Divine/Restore_Youth
	teachable=1
	Skill=1
	Cost_To_Learn=40
	Teach_Timer=24
	student_point_cost = 100
	clonable=0
	hotbar_type="Support"
	can_hotbar=1
	desc="You can use this to make someone younger. Each time they get this done they get less and less from it."
	var/Next_Use=0
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Restore_Youth()
	verb/Restore_Youth()
		set category = "Skills"
		if(usr.Android)
			usr.SendMsg("Androids cannot use natural-only abilities", CHAT_IC)
			return
		if(GetGlobalYear()<Next_Use)
			if(usr.key == "Khunkurisu") usr.SendMsg("Current Year: [GetGlobalYear()]\nNext Use: [Next_Use]")
			usr.SendMsg("You can not use this til year [Next_Use]", CHAT_IC)
			return
		var/list/L=list(usr)
		for(var/mob/M in Get_step(usr,usr.dir)) if(M.client) L+=M
		var/mob/M=input("Choose who to restore youth on") in L
		if(!M||!M.client) return
		switch(input(M,"Do you want [usr] to restore your youth?") in list("No","Yes"))
			if("No")
				if(usr) usr.SendMsg("[M] denies the offer to restore their youth", CHAT_IC)
				return
		if(src&&GetGlobalYear()<Next_Use) return
		if(usr&&M)
			Next_Use=GetGlobalYear()+1
			var/Previous_Age=M.Age
			M.Age-=M.Age/((M.Restore_Youth+1)**2)
			/*
			1: 80 to 10
			2: 80 to 60
			3: 80 to 71
			4: 80 to 75
			*/
			if(M.Age<10) M.Age=10
			for(var/mob/m in player_view(15,M))
				m.SendMsg("[usr] brings [M]'s age from [round(Previous_Age,0.1)] to [round(M.Age,0.1)] years old", CHAT_IC)
			M.Restore_Youth++

obj/Sacred_Water
	icon='props.dmi'
	icon_state="Closed"
	desc="This will give you a small power boost if your static BP is under a certain amount, and fully refill your health and energy, \
	and can be used as many times as wanted"
	density=1
	Savable=0
	var/tmp/Usable=1
	Spawn_Timer=180000
	Health=1.#INF
	Dead_Zone_Immune=1
	Grabbable=0
	Knockable=0
	Bolted=1
	var/cooldown=1200
	verb/Use()
		set category="Other"
		set src in oview(1)
		if(!Mechanics.GetSettingValue("Sacred Water"))
			usr << "Sacred Water is disabled on this server!"
			return
		if(!Usable)
			usr.SendMsg("This can only be used every [cooldown / 10] seconds", CHAT_IC)
			return
		if(usr.KO) return
		if(world.time - usr.last_attacked_by_player < 600)
			usr.SendMsg("You can not use this if you were attacked in the last 60 seconds because you are considered in combat", CHAT_IC)
			return
		for(var/mob/M in player_view(15,usr))
			M.SendMsg("[usr] drinks from the sacred water jar", CHAT_IC)
		Usable = 0
		icon_state = "Closed"
		spawn(cooldown)
			Usable = 1
			icon_state = "Open"
		usr.unlockedBP += usr.unusedPotential
		usr.unusedPotential = 0
		usr.unusedPotential += (usr.base_bp * 0.1) / (usr.sacredWaterUses + 1)
		usr.sacredWaterUses++
		if(usr.Health < 100) usr.Health = 100
		if(usr.Ki < usr.max_ki) usr.Ki = usr.max_ki
		if(usr.BPpcnt > 100) usr.BPpcnt = 100

mob/var/sacredWaterUses = 0

mob/proc/InBattleCantEnterCave()
	if(!client) return
	if(world.time - last_attacked_by_player < 70) return 1

obj/RankChat
	name="Rank Chat"
	hotbar_type="Other"
	can_hotbar=1

	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		RankChat()

	verb/RankChat(A as text)
		set category="Other"
		for(var/mob/B in players) if(locate(/obj/RankChat) in B)
			B.SendMsg("<font size=[B.TextSize]>(Rank)<font color=[usr.TextColor]>[usr.name]: [html_encode(A)]", CHAT_IC)
mob/var/using_giant_form
mob/var/list/giant_form_overlays=new
obj/Giant_Form
	teachable=1
	Skill=1
	hotbar_type="Transformation"
	can_hotbar=1
	Teach_Timer=1.2
	Cost_To_Learn=55
	desc="Using this will make you bigger:<br>\
	50% bp increase<br>\
	50% energy decrease<br>\
	25% speed decrease<br>\
	25% regeneration decrease<br>\
	25% recovery decrease<br>"
	var/tmp/next_use=0
	New()
		spawn(10) if(ismob(loc))
			var/mob/m=loc
			if(m.using_giant_form)
				m.Disable_giant_form(icon_change=0)
				m.Enable_giant_form()
	verb/Hotbar_use()
		set hidden=1
		Giant_Form()
	verb/Giant_Form()
		set category="Skills"
		if(world.time<next_use)
			usr<<"You must wait 5 seconds in between using this"
			return
		next_use=world.time+50
		usr.Toggle_giant_form()
mob/proc
	Toggle_giant_form()
		if(using_giant_form) Disable_giant_form()
		else Enable_giant_form()
	Enable_giant_form()
		using_giant_form=1
		if(Race=="Makyo")
			icon='Big Garlic.dmi'
			giant_form_overlays=new/list
			giant_form_overlays.Add(overlays)
			overlays=null
		else transform*=2
		bp_mult+=0.5
		Eff*=0.5
		Ki*=0.5
		max_ki*=0.5
		regen*=0.75
		recov*=0.75
		Spd*=0.75
		spdmod*=0.75
	Disable_giant_form(icon_change=1)
		using_giant_form=0
		if(Race=="Makyo")
			if(icon=='Big Garlic.dmi')
				icon='Makyojin 2.dmi'
				overlays.Add(giant_form_overlays)
		else if(icon_change) transform*=0.5
		bp_mult-=0.5
		Eff/=0.5
		Ki/=0.5
		max_ki/=0.5
		regen/=0.75
		recov/=0.75
		Spd/=0.75
		spdmod/=0.75

obj/Limit_Breaker
	desc="x1.5 BP, x3 Regeneration, x3 Recovery. x3 Offense. When you activate this it lasts for a random period of time, at the end \
	of which you will be knocked out. It is very powerful but it is a big gamble on your chances of winning or losing \
	a fight."
	icon='Burst.dmi'
	//teachable=1
	Skill=1
	Teach_Timer=10
	hotbar_type="Buff"
	can_hotbar=1
	can_change_icon=1
	New()
		spawn if(ismob(loc))
			var/mob/m=loc
			m.lb_obj=src
	verb/Hotbar_use()
		set hidden=1
		Limit_Breaker()
	verb/Limit_Breaker()
		set category="Skills"
		if(usr.Redoing_Stats)
			usr<<"You can not use this while choosing stat mods"
			return
		if(usr.KO) return
		for(var/obj/Kaioken/k in usr) if(k.Using)
			usr<<"Limit breaker can not be combined with Kaioken"
			return
		if(usr.buffed())
			usr<<"Limit breaker can not be combined with buffs"
			return
		if(!Using)
			Using=1
			player_view(10,usr)<<sound('aura3.ogg',volume=20)
			usr.last_anger=world.time
			usr.overlays+=icon
			usr.bp_mult+=0.5
			usr.regen*=3
			usr.recov*=3
			usr.Off*=3
			usr.offmod*=3
			usr.Limit_Breaker_Loop()

mob/var/tmp/obj/Limit_Breaker/lb_obj

mob/proc/Limit_Revert() if(lb_obj&&lb_obj.Using)
	lb_obj.Using=0
	overlays-=lb_obj.icon
	bp_mult-=0.5
	regen/=3
	recov/=3
	Off/=3
	offmod/=3
	src<<"You lose your energy and revert to your normal form."
	KO("limit breaker",allow_anger=0)



obj/Hide_Energy
	teachable=1
	Skill=1
	Cost_To_Learn=0
	Teach_Timer=2
	desc="Using this ability will cause you to be hidden from sense, observe, and teleports. The drawback \
	is that while using it your available bp is very low"
	New()
		delete_self()
	proc/delete_self() spawn(10) if(src) del(src)
	verb/Hide_Energy()
		set category="Skills"
		usr.hiding_energy=!usr.hiding_energy
		if(usr.hiding_energy)
			usr<<"You are now hiding your energy"
			for(var/mob/m in players) if(m.client&&m.client.eye==usr&&!m.Is_Admin())
				m<<"[usr] has begun hiding their energy, you have lost the ability to observe them"
				m.client.eye=m
		else usr<<"You are no longer hiding your energy"
mob/var
	hiding_energy


obj/Ultra_Super_Saiyan
	Skill=1
	Cost_To_Learn=50
	teachable=0
	Teach_Timer=5
	hotbar_type="Transformation"
	can_hotbar=1
	New()
		desc="Ultra Super Saiyan can be toggled on or off in the skills tab. It grants [ussj_bp+1]x bp, \
		[ussj_ki]x energy, [ussj_str]x strength, [ussj_dur]x durability, [ussj_spd]x speed, [ussj_res]x resistance. \
		To use it, have it toggled on, \
		then just tranform into a Super Saiyan, have over [Commas(ussj_bp_req)] BP available, \
		then power up twice again to go Ultra Super Saiyan."
	var/using_ussj=1
	verb/Hotbar_use()
		set hidden=1
		Toggle_Ultra_Super_Saiyan()
	verb/Toggle_Ultra_Super_Saiyan()
		set category="Skills"
		using_ussj=!using_ussj
		if(using_ussj) usr<<"Ultra Super Saiyan is now toggled on. To use it, just powerup twice after \
		going Super Saiyan and have over [Commas(ussj_bp_req)] BP available."
		else usr<<"Ultra Super Saiyan is now toggled off"
var
	ussj_bp=0.35
	ussj_ki=0.5
	ussj_str=1.3
	ussj_dur=1.3
	ussj_res=1.2
	ussj_spd=0.7
	ussj_bp_req=32000000
mob/var
	is_ussj
mob/proc/USSj()
	if(!is_ussj)
		spawn if(src)
			if(ssj3_opening) Trans_Graphics(ssj3_opening)
			else Old_Trans_Graphics()
		is_ussj=1
		bp_mult+=ussj_bp
		Ki*=ussj_ki
		max_ki*=ussj_ki
		Eff*=ussj_ki
		Str*=ussj_str
		strmod*=ussj_str
		Spd*=ussj_spd
		spdmod*=ussj_spd
		End*=ussj_dur
		endmod*=ussj_dur
		Res*=ussj_res
		resmod*=ussj_res
		overlays+='Yellow Lightning aura.dmi'
		switch(icon)
			if('New Pale Male.dmi') icon='White Male Muscular 3.dmi'
			if('New Tan Male.dmi') icon='Tan Male Muscular 3.dmi'
			if('New Black Male.dmi') icon='Black Male Muscular 3.dmi'
	else
		is_ussj=0
		bp_mult-=ussj_bp
		Ki/=ussj_ki
		max_ki/=ussj_ki
		Eff/=ussj_ki
		Str/=ussj_str
		strmod/=ussj_str
		Spd/=ussj_spd
		spdmod/=ussj_spd
		End/=ussj_dur
		endmod/=ussj_dur
		Res/=ussj_res
		resmod/=ussj_res
		overlays-='Yellow Lightning aura.dmi'
		switch(icon)
			if('White Male Muscular 3.dmi') icon='New Pale Male.dmi'
			if('Tan Male Muscular 3.dmi') icon='New Tan Male.dmi'
			if('Black Male Muscular 3.dmi') icon='New Black Male.dmi'
	SSj_Hair()


obj/Dash_Attack
	teachable=1
	Skill=1
	hotbar_type="Melee"
	can_hotbar=1
	Cost_To_Learn=10
	Teach_Timer=1
	desc="A melee finishing move where you dash in a line in front of you and anyone in that line will \
	be attacked and take damage. You can aim it by moving side to side. It does more damage if you hit \
	the target from behind, and more damage the further away you do it from"
	verb/Hotbar_use()
		set hidden=1
		Dash_Attack()
	verb/Dash_Attack()
		set category="Skills"
		usr.Dash_Attack()

mob/var/tmp
	dash_attacking
	desired_dash_dir
	original_dash_dir

mob/proc/Dash_Attack()
	if(dash_attacking||grabbed_mob) return
	if(tournament_override()) return
	var/Drain=200*(max_ki/3000)**0.5
	if(Ki<Drain)
		src<<"You do not have enough energy"
		return
	if(Beam_stunned()) return
	dash_attacking=1
	var/damage_mult=1/10
	original_dash_dir=dir
	for(var/steps in 1 to 15)
		if(KB) break //causes a bug where the person hits the target many many times doing massive damage
		else
			var/turf/old_loc=loc
			var/dash_dir=original_dash_dir
			if(desired_dash_dir&&round(steps/3)==steps/3)
				dash_dir=desired_dash_dir
				desired_dash_dir=0
			step(src,dash_dir)
			var/mob/P
			if(loc==old_loc) for(P in Get_step(src,dir))
				loc=P.loc
				break
			else for(P in loc) if(P!=src) break
			if(loc==old_loc)
				break
			if(P)
				var/Damage=45*((BP/P.BP)**0.5)*((Str/P.End)**0.35)*melee_power*damage_mult
				var/Acc=70*(BP/P.BP)*Acc_mult(Off/P.Def)
				Acc*=Speed_accuracy_mult(defender=P)
				var/KB_Distance=(BP/P.BP)*(Str/P.End)*5
				if(prob(Acc))
					flick("Attack",src)
					if(P.ki_shield_on())
						P.Ki-=Damage*shield_reduction*(P.max_ki/100)/(P.Eff**shield_exponent)*P.Generator_reduction(is_melee=1)
					else
						if(P.dir==dir) P.Health-=Damage*2 //hit from behind
						else P.Health-=Damage
					if((P.Health<=0||P.Ki<=0)&&Fatal) spawn(15) if(P) P.Death(src)
					spawn if(P)
						player_view(center=src)<<sound('strongpunch.ogg',volume=50)
						Make_Shockwave(P,sw_icon_size=pick(128,256))
						var/kb_dir=pick(turn(dir,45),turn(dir,-45))
						P.Knockback(src,KB_Distance,override_dir=kb_dir)
				else
					flick('Zanzoken.dmi',P)
					step(P,turn(dir,pick(90,-90)))
			After_Image(20,3)
			damage_mult+=1/3
			sleep(To_tick_lag_multiple(Speed_delay_mult(severity=0.5)))
	Ki-=Drain
	dash_attacking=0




mob/verb/Forget_Skill()
	set category="Skills"
	var/N=0.9
	var/list/L=list("Cancel")
	for(var/obj/O in src) if(O.Cost_To_Learn) L+=O
	var/obj/O=input(src,"You can forget any skill you choose. If you learned the skill yourself you will get \
	[N*100]% of the skill points back. If you were taught you will not.") in L
	if(!O||O=="Cancel") return
	if(!O.Taught) Experience+=O.Cost_To_Learn*N
	del(O)

obj/var/Taught=1 //if 1, you did not self learn the skill

mob/proc/Destroy_Soul_Contracts(soul_percent=100)
	if(locate(/obj/Contract_Soul) in src)
		src<<"You have died. All your soul contracts are now destroyed"
		for(var/obj/Contract_Soul/C in src) if(prob(soul_percent))
			if(C.observed_mob) C.observed_mob<<"[src] has died and their contract on your soul has been destroyed"
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
	Click() if(src in usr)
		if(!observed_mob)
			switch(input("They are offline. The only action you can do is to destroy the soul contract, do you want to \
			do this?") in list("No","Yes"))
				if("Yes") del(src)
			return
		if(observed_mob==usr)
			usr<<"Contract deleted. You can not use your own soul contract"
			del(src)
			return
		if(usr.KO)
			usr<<"You are powerless to do this right now!"
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
					usr<<"All of [observed_mob]'s soul contracts have been destroyed"
					observed_mob<<"[usr] has used the soul contract on you to destroy all of your soul contracts"
					for(var/obj/Contract_Soul/CS in observed_mob) del(CS)
				else
					usr<<"[observed_mob]'s soul contract on [S] is destroyed"
					observed_mob<<"[usr] has used the soul contract on you to destroy your soul contract on [S]"
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
				usr<<"*[observed_mob]'s soul info*<br>\
				Base BP: [Commas(observed_mob.base_bp)]<br>\
				Age: [observed_mob.Age]<br>\
				Lifespan: [observed_mob.Lifespan()] years<br>"
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
					usr<<"You gave [N] years of your life to [observed_mob], they recieve +[abs(N/2)] years of life in exchange."
					observed_mob<<"[usr] has used the soul contract to extent your lifespan by [abs(N/2)] years, by sacrificing \
					[abs(N)] years of their lifespan."
				if(N>0)
					usr.Age+=N/2
					observed_mob.Age-=N
					usr<<"You have gained +[N/2] years of life from [observed_mob]"
					//P<<"[usr] has used the soul contract to take [N] years from your lifespan, to extent their own"
			if("Permanent Teleport")
				if(usr.Teleport_nulled())
					usr<<"A teleport nullifier is disrupting your ability to teleport"
					return
				if(ismob(usr.loc))
					usr<<"You can not teleport while body swapped"
					return
				if(usr.KO)
					usr<<"You can not teleport while knocked out"
					return
				if(observed_mob.Final_Realm()||observed_mob.Prisoner())
					usr<<"You can not teleport to them because they are in another dimension"
					return
				if(usr.Final_Realm()||usr.Prisoner())
					usr<<"You can not teleport to them because you are in another dimension"
				var/turf/t=usr.loc
				for(var/n in 1 to 40)
					if(t!=usr.loc||usr.KO)
						usr<<"Teleport canceled"
						return
					sleep(1)
				tpx=0
				tpy=0
				tpz=0
				usr.loc=observed_mob.loc
			if("Temporary Teleport")
				if(usr.Teleport_nulled())
					usr<<"A teleport nullifier is disrupting your ability to teleport"
					return
				if(ismob(usr.loc))
					usr<<"You can not teleport while body swapped"
					return
				if(usr.KO)
					usr<<"You can not teleport while knocked out"
					return
				if(usr.Final_Realm()||usr.Prisoner())
					usr<<"You can not teleport to them because you are in another dimension"
					return
				if(observed_mob.Final_Realm()||observed_mob.Prisoner())
					usr<<"You can not teleport to them because they are in the another dimension"
					return
				var/turf/t=usr.loc
				for(var/n in 1 to 70)
					if(t!=usr.loc||usr.KO)
						usr<<"Teleport canceled"
						return
					sleep(1)
				tpx=usr.x
				tpy=usr.y
				tpz=usr.z
				usr.loc=observed_mob.loc
			if("Teleport Back")
				if(usr.Teleport_nulled())
					usr<<"A teleport nullifier is disrupting your ability to teleport"
					return
				if(usr.KO)
					usr<<"You can not teleport while knocked out"
					return
				if(usr.Final_Realm()||usr.Prisoner())
					usr<<"You can not teleport back because you are in another dimension"
					return
				if(ismob(usr.loc))
					usr<<"You can not teleport while body swapped"
					return
				var/turf/t=usr.loc
				for(var/n in 1 to 70)
					if(t!=usr.loc||usr.KO)
						usr<<"Teleport canceled"
						return
					sleep(1)
				usr.loc=locate(tpx,tpy,tpz)
				tpx=0
				tpy=0
				tpz=0
			if("Permanent Summon")
				if(ismob(usr.loc))
					usr<<"You can not summon while body swapped"
					return
				if(observed_mob.Teleport_nulled())
					usr<<"They can not be summoned because they are near a teleport nullifier making it impossible \
					to lock on to them"
					return
				if(ismob(observed_mob.loc))
					usr<<"You can not summon someone who is currently a body swap victim"
					return
				if(observed_mob.KO)
					usr<<"[observed_mob] is in conditions which make it impossible to summon them"
					return
				if(observed_mob.Final_Realm()||observed_mob.Prisoner())
					usr<<"You can not summon them because they are in another dimension"
					return
				if(usr.Final_Realm()||usr.Prisoner())
					usr<<"You can not summon them because you are in another dimension"
					return
				var/turf/t=observed_mob.loc
				for(var/n in 1 to 70)
					if(t!=observed_mob.loc)
						usr<<"Summon canceled. You lose your lock on their energy when they move."
						return
					sleep(1)
				presummon_x=0
				presummon_y=0
				presummon_z=0
				player_view(15,observed_mob)<<"[observed_mob] is summoned away by [usr]'s soul contract"
				observed_mob.loc=usr.loc
				player_view(15,observed_mob)<<"[observed_mob] is summoned to [usr] by the soul contract"
			if("Destroy contract")
				player_view(15,usr)<<"[usr] destroys the soul contract of [observed_mob]"
				del(src)
			if("Alter soul's BP")
				var/Pre_bp_mod=observed_mob.bp_mod
				if(Max_BP<observed_mob.base_bp/observed_mob.bp_mod)
					Max_BP=observed_mob.base_bp/observed_mob.bp_mod
				if(Max_BP<usr.base_bp/usr.bp_mod*0.85)
					Max_BP=usr.base_bp/usr.bp_mod*0.85
				var/Edit_BP=Max_BP*observed_mob.bp_mod
				var/N=input("You can alter their bp anywhere between 1 and [Commas(Edit_BP)].","Alter BP",observed_mob.base_bp) as num|null
				if(!N) return
				if(N<1) N=1
				if(N>Edit_BP) N=Edit_BP
				N*=observed_mob.bp_mod/Pre_bp_mod
				observed_mob<<"[usr] has altered your BP to [Commas(N)]"
				observed_mob.base_bp=N
			if("Leech soul")
				if(observed_mob)
					usr<<"You have now fully leeched [observed_mob]"
					var/max_bp=max(usr.base_bp/usr.bp_mod,observed_mob.base_bp/observed_mob.bp_mod*0.75)
					usr.Leech(observed_mob,5000,no_adapt=1,weights_count=0)
					if(usr.base_bp/usr.bp_mod>max_bp) usr.base_bp=max_bp*usr.bp_mod
			if("Knock out") if(observed_mob) observed_mob.KO("[usr]'s soul contract")
			if("Absorb")
				if(observed_mob.KO&&!(observed_mob in view(10,usr)))
					usr<<"You can not use absorb on them while they are knocked out, unless you are physically near \
					them."
					return
				if(observed_mob.Dead)
					usr<<"They are dead and can not be absorbed"
					return
				player_view(15,observed_mob)<<"[observed_mob]'s demon master uses the soul contract to absorb [observed_mob], killing them!"
				usr.Absorb(observed_mob)
				observed_mob.Death(usr,1)
				usr<<"You have absorbed [observed_mob] from a distance, killing them"
			if("Kill")
				if(observed_mob.KO&&!(observed_mob in view(10,usr)))
					usr<<"You can not use kill on them while they are knocked out, unless you are physically near \
					them."
					return
				if(usr.Dead&&!observed_mob.Dead)
					usr<<"You used [observed_mob]'s life energy to bring yourself back to life"
					usr.Revive()
				observed_mob.Death("[usr]'s soul contract",1)
				if(observed_mob) observed_mob.loc=usr.loc
			if("Temporary Summon")
				if(observed_mob.Teleport_nulled())
					usr<<"They can not be summoned because they are near a teleport nullifier making it impossible \
					to lock on to them"
					return
				if(ismob(usr.loc))
					usr<<"You can not summon while body swapped"
					return
				if(ismob(observed_mob.loc))
					usr<<"You can not summon someone who is currently a body swap victim"
					return
				if(observed_mob.KO)
					usr<<"[observed_mob] is in conditions which make it impossible to summon them"
					return
				if(observed_mob.Final_Realm()||observed_mob.Prisoner())
					usr<<"You can not summon them because they are in another dimension"
					return
				if(usr.Final_Realm()||usr.Prisoner())
					usr<<"You can not summon them because you are in another dimension"
					return
				var/turf/t=observed_mob.loc
				for(var/n in 1 to 70)
					if(!observed_mob) return
					if(t!=observed_mob.loc)
						usr<<"Summon canceled. You lose your lock on their energy when they move."
						return
					sleep(1)
				usr<<"You can select 'send back' to send them back to where they were before you summoned them"
				player_view(15,observed_mob)<<"[observed_mob] was summoned away by [usr]'s soul contract!"
				presummon_x=observed_mob.x
				presummon_y=observed_mob.y
				presummon_z=observed_mob.z
				observed_mob.loc=usr.loc
				player_view(15,observed_mob)<<"[observed_mob] was summoned by [usr]'s soul contract"
			if("Send back")
				if(observed_mob.Teleport_nulled())
					usr<<"They can not be sent back because they are near a teleport nullifier making it impossible \
					to lock on to them"
					return
				if(observed_mob.KO)
					usr<<"[observed_mob] is in conditions which make it impossible to do this"
					return
				if(observed_mob.Final_Realm()||observed_mob.Prisoner())
					usr<<"You can not summon them because they are in another dimension"
					return
				var/turf/t=observed_mob.loc
				for(var/n in 1 to 70)
					if(t!=observed_mob.loc)
						usr<<"Send back canceled. You lose your lock on their energy when they move."
						return
					sleep(1)
				player_view(15,observed_mob)<<"[observed_mob] was sent back to his last location by [usr]'s soul contract"
				observed_mob.loc=locate(presummon_x,presummon_y,presummon_z)
				player_view(15,observed_mob)<<"[observed_mob] was sent back by [usr]'s soul contract!"
				presummon_x=0
				presummon_y=0
				presummon_z=0
	New()
		soul_contracts+=src
	Del()
		soul_contracts-=src
		..()
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

obj/Demon_Contract
	name="Soul Contract"
	desc="You can offer someone a soul contract. If they accept, their soul will belong to you, and you will \
	get certain powers over them."
	teachable=1
	Skill=1
	Teach_Timer=24
	Cost_To_Learn=70
	clonable=0
	var/tmp/Offering
	verb/Soul_Contract()
		set category="Skills"
		usr.Soul_Contract(src)

mob/proc/Soul_Contract(obj/Demon_Contract/SC)
	if(SC.Offering)
		src<<"You can not spam people with soul contract. You must either wait until they accept, deny, or until 20 seconds \
		has passed."
		return
	//if(Race!="Demon")
	//	src<<"Only demons can manipulate souls"
	//	return
	for(var/mob/P in Get_step(src,dir)) if(P.client)
		if(P.ignore_contracts)
			src<<"[P] is ignoring contracts"
			return
		for(var/obj/Contract_Soul/C in src) if(C.Mob_ID==P.key)
			src<<"You already have their soul"
			return
		if(P.Android)
			src<<"Androids do not have souls"
			return
		SC.Offering=1
		spawn(200) if(SC&&SC.Offering) SC.Offering=0
		src<<"You offer the soul contract to [P]. Waiting on their response..."
		switch(alert(P,"[src] has offered you the soul contract. If you accept it they will be able to help or harm you in many \
		different ways.","Options","Deny","Accept"))
			if("Deny") player_view(15,P)<<"[P] has denied the soul contract from [src]"
			if("Accept")
				player_view(15,P)<<"[P] has accepted the soul contract from [src], their soul now belongs to [src]"
				var/obj/Contract_Soul/C=new
				contents+=C
				C.Soul_Contract_Update(P)
		if(SC) SC.Offering=0
		return

obj/Meditate_Level_2
	teachable=1
	Skill=1
	Teach_Timer=1
	Cost_To_Learn=2
	desc="Meditate Level 2 allows you to use meditation as a form of training. Without this skill, meditate is \
	only good for recovering health and energy faster."
	New()
		spawn if(ismob(loc))
			var/mob/m=loc
			m.meditate_obj=src
obj/Sense
	name="Sense Level 1"
	teachable=1
	Skill=1
	Teach_Timer=0.5
	Cost_To_Learn=3
	desc="The ability to sense everyone on the planet. You can see their overall power, which is their BP, stats, \
	and everything else combined into a percent."
	New()
		spawn(20) if(src)
			var/mob/m=loc
			if(m&&ismob(m)) m.sense_obj=src
obj/Advanced_Sense
	name="Sense Level 2"
	teachable=1
	Skill=1
	Teach_Timer=0.7
	Cost_To_Learn=3
	desc="By clicking on someone you will open a tab which will let you see their overall power, health, and \
	energy, and possibly other details that basic sense does not tell you."
obj/Sense3
	name="Sense Level 3"
	teachable=1
	Skill=1
	Teach_Timer=1
	Cost_To_Learn=3
	desc="This requires Sense Level 2 to work. When you open a tab of a person by clicking them, you will see \
	many details of that person, like their stats, as well as many other useful things."
obj/Shadow_Spar
	teachable=1
	Skill=1
	Teach_Timer=1
	Cost_To_Learn=1
	desc="This is a special form of training where your character is being attacked by an imaginary target and you \
	must face them in time to defend yourself. It is quite a good method of training but requires you to actually \
	be active."
	var/tmp/Can_SS=1
	hotbar_type="Training method"
	can_hotbar=1
	verb/Hotbar_use()
		set hidden=1
		Shadow_Spar()
	verb/Shadow_Spar()
		set category="Skills"
		if(Can_SS)
			Can_SS=0
			spawn(10) if(src) Can_SS=1
			usr.Shadow_Spar()
proc/Timed_Delete(obj/O,T=100) spawn(T) if(O) del(O)
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
		spawn while(src)
			pixel_x=rand(-Offset,Offset)
			pixel_x-=32
			sleep(1)
	proc/Aura_Walk() spawn while(src)
		step(src,NORTH)
		sleep(3)
obj/var/teachable
var/teach_time_mod=0.5
mob/var/next_knowledge_teach=0
mob/proc/set_next_knowledge_teach(n=1)
	next_knowledge_teach=world.realtime+(2*60*60*10*n)
mob/verb/Teach()
	set category="Skills"
	sleep(2)
	var/mob/P=locate(/mob) in Get_step(usr,usr.dir)
	if(body_swapped())
		src<<"You can not teach skills while body swapped"
		return
	for(var/obj/Injuries/Brain/I in injury_list)
		src<<"You have a brain injury and therefore cannot teach anything"
		return
	if(!P) return
	for(var/obj/Injuries/Brain/I in P.injury_list)
		src<<"[P] has a brain injury and cannot learn anything"
		P<<"You have a brain injury and therefore could not learn anything from [src]"
		return
	if(alignment_on&&P.alignment=="Evil"&&alignment=="Good")
		src<<"Good people can not teach skills to evil people"
		return
	var/list/Skills=list("Cancel")
	if(!next_knowledge_teach) set_next_knowledge_teach(1)
	if(Knowledge>P.Knowledge)
		if(world.realtime>next_knowledge_teach) Skills+="Knowledge of Technology"
		else
			var/hours=(next_knowledge_teach-world.realtime)/10/60/60
			hours=round(hours,0.01)
			Skills+="Knowledge (Teach in [hours] hours)"
	for(var/obj/O in src) if(O.teachable && (!(locate(O.type) in P) || O.Reteachable))
		Skills+=O
		if(istype(O,/obj/Buff)&&P.Buff_count()>=max_buffs) Skills-=O
		if(istype(O,/obj/Giant_Form)&&P.Race!=Race) Skills-=O
		if(istype(O,/obj/Regeneration)&&P.Race!=Race) Skills-=O
		if(istype(O,/obj/Namek_Fusion)&&P.Race!=Race) Skills-=O
		if(istype(O,/obj/Teleport)&&P.Race!="Kai") Skills-=O
		if(istype(O,/obj/Keep_Body)&&P.Race!=Race) Skills-=O
		if(istype(O,/obj/Demon_Contract)&&P.Race!="Demon") Skills-=O
		if(istype(O,/obj/Materialization)&&P.Race!=Race) Skills-=O
	Skills+="*Skills you can not yet teach*"
	for(var/obj/O in Skills) if(world.realtime<O.Next_Teach)
		Skills-=O
		var/hours=(O.Next_Teach-world.realtime)/10/60/60
		hours=round(hours,0.01)
		Skills+="[O.name] (Teach in [hours] hours)"
	if(!src || !client) return //wierd runtime error fix "bad client"
	var/obj/A=input(src,"What do you want to teach? Skills they already know do not appear here. Skills you can not \
	yet teach are at the bottom seperated from the others.") in Skills
	if(!P) return
	if(A=="Knowledge of Technology")
		var/Percent=input(src,"What percent of your knowledge will you teach them?") as num
		if(Percent<=0) return
		if(Percent>100) Percent=100
		if(world.realtime<next_knowledge_teach) return
		player_view(15,src)<<"[src] taught [P] [Percent]% of their knowledge of technology"
		var/knowledge=Knowledge*(Percent/100)
		if(P.Knowledge<knowledge)
			set_next_knowledge_teach(knowledge/Knowledge)
			P.Knowledge=knowledge
		else src<<"[P] has more knowledge already than what you are teaching them"
	else if(isobj(A))
		if(world.realtime<A.Next_Teach)
			var/hours=(A.Next_Teach-world.realtime)/10/60/60
			src<<"You can not teach this skill for another [round(hours)] hours and [round(hours*60 %60)] minutes"
			return
		var/obj/O
		if(istype(A,/obj/Buff))
			Save_Obj(A)
			O=new A.type
			Load_Obj(O)
			O.suffix=null
		else O=new A.type
		O.update_teach_timer()
		O.Taught=1
		P.contents+=O
		A.update_teach_timer()
		if(istype(A,/obj/Attacks)) O.icon=A.icon
		player_view(15,src)<<"[src] taught [P] the [A]!"
		P.Restore_hotbar_from_IDs()
obj/proc
	update_teach_timer()
		if(Next_Teach>world.realtime) return
		Next_Teach=world.realtime+(Teach_Timer*teach_time_mod*60*60*10)
obj/var/Teach_Timer=0.5
obj/var/Next_Teach=0
mob/var/Regeneration_Skill
obj/Regeneration
	teachable=1
	Skill=1
	hotbar_type="Defensive"
	can_hotbar=1
	Teach_Timer=3
	Cost_To_Learn=10
	desc="This is a passive healing skill where, if your health goes below 100% you will begin trading energy \
	for health. You can turn it on and off at any time."
	verb/Hotbar_use()
		set hidden=1
		Regenerate()
	verb/Regenerate()
		set category="Skills"
		if(!usr.Regeneration_Skill&&usr.Is_Cybernetic())
			usr<<"Cybernetic beings cannot use this ability"
			return
		if(usr.KO)
			usr<<"You must wait til you regain consciousness"
			return
		if(!usr.Regeneration_Skill)
			usr.Regeneration_Skill=1
			usr<<"You are now regenerating"
			usr.Namek_regen_loop()
		else
			usr.Regeneration_Skill=0
			usr<<"You stop regenerating"
obj/Give_Power
	teachable=1
	Skill=1
	hotbar_type="Support"
	can_hotbar=1
	Cost_To_Learn=4
	Teach_Timer=1
	desc="You can transfer your health and energy to someone from a distance. The person can exceed 100% power \
	if you have enough health and energy, exceeding 100% energy raises their BP. The effect is only temporary, \
	because health and energy do not stay above 100% for long."
	verb/Hotbar_use()
		set hidden=1
		Give_Power()
	verb/Give_Power()
		set category="Skills"
		if(usr.Android)
			usr<<"Androids cannot use natural-only abilities"
			return
		if(usr.KO) return
		if(!usr.Giving_Power)
			if(usr.locz()==18)
				usr<<"The acid fumes in this place prevent you from transferring your energy right now"
				return
			if(usr.power_given>=40)
				usr<<"You have given all the power you can for now. You must wait for it to refill"
				return
			usr<<"Click again to stop giving power"
			usr.Give_Power(src)
		else
			usr.Giving_Power=0
			usr<<"You stop giving power"
mob/var
	tmp/Giving_Power
	power_given=0
mob/proc/Give_Power(obj/Give_Power/G)
	if(tournament_override(fighters_can=0)) return
	var/list/Mobs=list("Cancel")
	for(var/mob/M in player_view(15,src)) if(M.client&&M!=src) Mobs+=M
	if(Mobs.len<=2) Mobs-="Cancel"
	var/mob/M=input(src,"Choose a target to give power to") in Mobs
	if(Giving_Power) return
	if(!M||M=="Cancel") return
	if(alignment_on&&alignment=="Good"&&M.alignment=="Evil")
		src<<"You can not give power to evil people"
		return
	Giving_Power=1
	player_view(15,src)<<"[src] is sending his power to [M]!"
	var/obj/O=new
	O.icon='Give Power.dmi'
	O.layer=layer+1
	spawn while(src&&Giving_Power&&M)
		Missile(O,src,M)
		sleep(1)
	while(src&&M&&Giving_Power&&!KO&&getdist(src,M)<=13&&locz()!=18&&M.locz()!=18)
		dir=get_dir(src,M)
		if(M.Health<100) M.Health+=0.4
		Health-=1
		if(!power_given) Give_power_refill_loop()
		power_given++
		if(M.KO&&M.Health>=100) M.Un_KO()
		if(KO)
			Giving_Power=0
			return
		if(Ki>=max_ki/100)
			Ki-=max_ki/100
			var/n=max_ki/100 / Clamp((Eff/M.Eff)**0.5,0.5,2)
			if(M.Ki>M.max_ki)
				n*=(M.max_ki/M.Ki)**3
				if(alignment_on)
					if(alignment=="Good") n*=1.35
					if(alignment=="Evil") n*=0.5
			//M.Ki+=n
			M.Ki+=(M.max_ki/100) * Clamp((M.max_ki/M.Ki)**3,0,1.5)
		if(power_given>=100)
			src<<"You have given all the power you can for now. You must wait for it to refill"
			break
		sleep(2)
	Giving_Power=0
mob/proc/Give_power_refill_loop() spawn while(src)
	if(!Giving_Power)
		power_given-=1/120*100 * 10
		if(power_given<0)
			power_given=0
			break
	sleep(100)
obj/Zanzoken
	teachable=1
	Skill=1
	Cost_To_Learn=5
	Teach_Timer=0.5
	desc="Zanzoken is the ability to use a burst of concentrated speed to reach a place very fast, \
	it is so fast it is basically like teleporting a short distance. You click the spot you want to go \
	to and your character will suddenly go there. The more you master this the less energy it will \
	drain. You will also get a new command in the skills tab that lets you chase someone down using \
	zanzoken if they try to run from you"
	verb/Combo_Toggle()
		set category="Other"
		if(!usr.Warp)
			usr<<"Combo Warping on"
			usr.Warp=1
		else
			usr<<"Combo Warping off"
			usr.Warp=0
	/*verb/Flash_Step()
		set category="Skills"
		usr.Flash_Step()*/
mob/var/KeepsBody //If this is 1 you keep your body when Dead.
obj/Keep_Body
	desc="Using this on someone will allow them to keep most of their power while dead."
	teachable=1
	Skill=1
	hotbar_type="Support"
	can_hotbar=1
	Teach_Timer=12
	var/next_use=0
	var/hours_per_use=1
	New()
		if(!next_use) next_use=world.realtime+(hours_per_use*60*60*10)
	verb/Hotbar_use()
		set hidden=1
		Keep_Body()
	verb/Keep_Body()
		set category="Other"
		if(usr.Android)
			usr<<"Androids cannot use natural-only abilities"
			return
		if(world.realtime<next_use)
			var/hours=(next_use-world.realtime)/10/60/60
			usr<<"You can not use this for another [round(hours)] hours and [round(hours*60 %60)] minutes"
			return
		var/list/L=list(usr)
		for(var/mob/m in Get_step(usr,usr.dir)) L+=m
		var/mob/M=input("Allow which person to keep their body when dead?") in L
		if(M)
			switch(input("Allow [M] to keep their body?") in list("Yes","No"))
				if("Yes")
					if(world.realtime<next_use) return
					M.KeepsBody=1
					next_use=world.realtime+(hours_per_use*60*60*10)
					player_view(15,usr)<<"[usr] allows [M] to keep their body while dead"
				if("No")
					M.KeepsBody=0
					player_view(15,usr)<<"[usr] removes [M]'s ability to keep their body while dead"
mob/var/tmp/obj/Shield/shield_obj
obj/Shield
	teachable=1
	Skill=1
	Teach_Timer=2
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
		set hidden=1
		Shield()
	verb/Shield()
		set category="Skills"
		usr.Toggle_ki_shield(src)

mob/proc/Toggle_ki_shield(obj/Shield/s)
	if(!s) s=locate(/obj/Shield) in src
	if(!s) return
	if(KO) return
	if(!s.Using)
		s.Using=1
		Shield()
		Ki_shield_revert_loop()
	else Shield_Revert()

mob/var/tmp/last_shield_use=0

mob/proc/Shield_Revert()
	for(var/obj/Shield/A in src)
		if(A.Using) last_shield_use=world.time
		overlays-=A.icon
		A.Using=0

mob/proc/Shield() if(shield_obj&&shield_obj.Using) overlays+=shield_obj.icon

obj/Make_Fruit
	teachable=1
	hotbar_type="Support"
	can_hotbar=1
	Skill=1
	Teach_Timer=4
	desc="With this you can make fruits that will increase the power and energy of those who eat them, \
	along with a temporary boost to regeneration and recovery. The more of them you eat however, the \
	less of an effect they will have each time."
	var/tmp/Making
	verb/Hotbar_use()
		set hidden=1
		Fruit()
	verb/Fruit()
		set category="Skills"
		if(Making)
			usr<<"You are already making one"
			return
		Making=1
		player_view(15,usr)<<"[usr] begins planting something"
		sleep(100)
		player_view(15,usr)<<"A strange fruit appears in front of [usr]"
		Making=0
		var/obj/items/Fruit/A=new(usr)
		A.name="[usr] Fruit"

var/list/bind_objects=new

obj/Curse
	var
		CursePower=0
		bind_time=0
	New()
		bind_objects+=src
		bind_check()
	Del()
		bind_objects-=src
		..()
	proc/bind_check() spawn while(src)
		var/mob/m=loc
		if(!m||!ismob(m)) del(src)
		if(world.realtime>bind_time)
			m<<"<font color=red><font size=2>The bind on you has expired, you can leave hell at any time."
			del(src)
		sleep(600)
mob/var
	last_bind=0
	last_unbind=0
obj/Bind
	hotbar_type="Ability"
	can_hotbar=1
	Skill=1
	Cost_To_Learn=55
	teachable=1
	Teach_Timer=3
	desc="You can use this to bind someone to hell. You can only bind a person who is less than your \
	own power at the time. The stronger they are compared to you the more energy it will drain \
	to bind them"
	proc/bind_power(mob/m)
		var/ki_mod=m.Eff
		var/obj/Buff/b=m.buffed()
		if(b) ki_mod/=b.buff_ki
		var/n=5 * (m.max_ki/m.Eff/500)**3 * (ki_mod**0.2)
		if(alignment_on&&m.alignment=="Good") n*=1.5
		return n
	proc/bind_time(mob/m)
		var/ki_mod=m.Eff
		var/obj/Buff/b=m.buffed()
		if(b) ki_mod/=b.buff_ki
		return world.realtime+(1*60*60*10)*(ki_mod**0.3)
	verb/Hotbar_use()
		set hidden=1
		Bind()
	verb/Bind()
		set category="Skills"
		if(usr.tournament_override(fighters_can=0)) return
		var/bind_time_limit=35
		if(alignment_on&&usr.alignment=="Good") bind_time_limit-=9
		if(world.realtime<usr.last_bind+(bind_time_limit*60*10))
			usr<<"You can only use this every [bind_time_limit] minutes"
			return
		for(var/mob/A in Get_step(usr,usr.dir)) if(A.client&&A.KO)
			if(alignment_on&&both_good(A,usr))
				usr<<"You can not bind other good people"
				return
			if(Same_league_cant_kill(A,usr))
				usr<<"You can not bind someone in the same league as you"
				return
			if(A.BP>usr.BP)
				player_view(15,usr)<<"[usr] attempts to bind [A] to hell, but [A]'s spiritual power deflects it!"
				return
			usr.last_bind=world.realtime
			if(locate(/obj/Curse) in A)
				for(var/obj/Curse/B in A)
					B.CursePower+=bind_power(usr)
					if(B.bind_time<bind_time(usr)) B.bind_time=bind_time(usr)
					player_view(15,usr)<<"[usr] strengthens the bind already placed on [A] to [Commas(B.CursePower)] energy!"
			else
				var/obj/Curse/B=new
				B.CursePower+=bind_power(usr)
				B.bind_time=bind_time(usr)
				player_view(15,usr)<<"[usr] successfully binds [A] to hell! The bind has [Commas(B.CursePower)] energy"
				A.contents+=B
	verb/UnBind()
		set category="Skills"
		if(world.realtime<usr.last_unbind+(10*60*10))
			var/t=usr.last_unbind+(10*60*10)-world.realtime
			t=round(t/10)
			usr<<"You can not use this for another [t] seconds"
			return
		var/list/L=new
		if(locate(/obj/Curse) in usr) L+=usr
		for(var/mob/P in Get_step(usr,usr.dir)) if(locate(/obj/Curse) in P) L+=P
		var/mob/A=input("Who do you want to attempt to unbind?") in L
		if(!A) return
		if(alignment_on&&usr.alignment=="Good"&&A.alignment=="Evil")
			usr<<"Good can not unbind evil"
			return
		if(world.realtime<usr.last_unbind+(10*60*10))
			var/t=usr.last_unbind+(10*60*10)-world.realtime
			t=round(t/10)
			usr<<"You can not use this for another [t] seconds"
			return
		for(var/obj/Curse/B in A)
			//if(usr.Ki<usr.max_ki*0.9)
				//usr<<"You need at least 90% energy to attempt to remove a bind"
				//return
			usr.last_unbind=world.realtime
			var/old_energy=B.CursePower
			B.CursePower-=bind_power(usr)/2.2
			//usr.Ki/=2
			if(B.CursePower<=0)
				player_view(15,usr)<<"[usr] succeeds in breaking the bind placed on [A]!"
				del(B)
			else player_view(15,usr)<<"[usr] weakened the bind from [Commas(old_energy)] to [Commas(B.CursePower)] energy"
			return
obj/var/examinable=1

proc/Examine_List()
	var/list/L=new
	for(var/obj/O) if(O.desc&&O.examinable) L+=O
	return L

mob/verb/Examine(obj/A in Examine_List()) if(A) src<<"<br><br>[A.desc]"

proc/Strongest_Person(mob/M)
	for(var/mob/P in players) if(!M||P.base_bp>M.base_bp) M=P
	return M
proc/strongest_person_proportionate(mob/m)
	for(var/mob/p in players) if(!m||p.base_bp/p.bp_mod>m.base_bp/m.bp_mod) m=p
	return m
mob/var/bio_form=1
mob/proc/Bio_form_check(mob/m)
	if(BP<8000000) return
	if(Race!="Bio-Android"||bio_form>=3||m.BP<8000000) return
	if(m.Race!="Bio-Android"&&!m.Is_Cybernetic()) return
	if(m.Race=="Bio-Android"&&m.bio_form<=bio_form) return
	//Attack_Gain(500,Strongest_Person(),apply_hbtc_gains=0,include_weights=0)
	var/static_bp_gain = 1.5 * highest_avg_bp_this_reboot * bio_form**0.5
	if(static_bp_gain<13000000) static_bp_gain=13000000
	if(static_bp_gain>70000000) static_bp_gain=70000000
	hbtc_bp+=static_bp_gain
	bio_form++
	if(bio_form==2)
		if(icon=='Bio1.dmi') icon='Bio2.dmi'
		else icon='Bio Android 2.dmi'
		if(bp_mod<5) bp_mod=5
	if(bio_form==3)
		if(icon=='Bio2.dmi') icon='Bio3.dmi'
		else icon='Bio Android 3.dmi'
		if(bp_mod<8) bp_mod=8

mob/var/Absorbed_Power=0
obj/var/Skill //If Skill=1 this obj is a SKILL
obj/Absorb
	Skill=1
	hotbar_type="Ability"
	can_hotbar=1
	Cost_To_Learn=60
	desc="You can absorb a knocked out person. You will get a power increase based on how strong they \
	are compared to you. Absorbing people can also bring \
	you back to life, by absorbing either 1 living person or multiple dead people (on average 5 but it is \
	luck based), their base BP must also be more than 75% of yours and they can not be an alt or npc."
	verb/Hotbar_use()
		set hidden=1
		Absorb()
	verb/Absorb()
		set category="Skills"

		/*if(!(usr.Race in list("Majin","Bio-Android","Android","Alien","Demon")))
			if(!("Absorb" in usr.active_packs))
				if(!(locate(/obj/Module/Manual_Absorb) in usr.active_modules))
					del(src)
					return*/

		usr.Absorb()
mob/var/last_absorbed
mob/proc
	power_absorb_mod()
		if(Race=="Majin") return 1
		if(Race=="Bio-Android") return 0.9
		if(Race=="Android") return 0.8
		if(Race=="Alien") return 0.6
		if(Race=="Demon") return 0.6
		if(Race=="Human") return 0.2
		if(Race=="Namek") return 0.2
		return 0.1
	knowledge_absorb_mod()
		if(Race=="Android") return 0.3
		if(Race=="Bio-Android") return 0.3
		if(Race=="Human") return 0.22
		return 0.15
mob/proc/Absorb(mob/M)

	if(!M) for(var/mob/m in Get_step(src,dir)) if(m.KO)
		M=m
		break

	if(!can_absorb(M)) return
	last_absorbed=M.key
	player_view(15,src)<<"[src] ([displaykey]) absorbs [M]!"
	var/absorb_power=120*power_absorb_mod()
	if(!M.client) absorb_power/=20
	if(M.Regenerate) absorb_power/=5
	if(M.client)
		Health=100
		Ki=max_ki

		if(Dead&&(!M.Dead||prob(20))&&M.base_bp+M.hbtc_bp>(base_bp+hbtc_bp)*0.6&&!M.Regenerate) Revive()

		if(Knowledge<M.Knowledge)
			var/knowledge_gain=M.Knowledge*knowledge_absorb_mod()
			Knowledge+=knowledge_gain
			if(Knowledge>M.Knowledge) Knowledge=M.Knowledge

		if(cyber_bp&&M.cyber_bp>cyber_bp) cyber_bp=M.cyber_bp

		Bio_form_check(M)

	if(!M.Dead)
		var/old_bp=base_bp
		Leech(M,absorb_power,no_adapt=1,weights_count=0,android_matters=0)
		if(M.client&&base_bp<=old_bp)
			var/mob/other=M
			for(var/mob/m in players) if(m!=src&&m.base_bp/m.bp_mod>base_bp/bp_mod)
				if(other==src) other=m
				if(abs((1.2*base_bp/bp_mod)-(m.base_bp/m.bp_mod)) < abs((1.2*base_bp/bp_mod)-(other.base_bp/other.bp_mod)))
					other=m
			Leech(other,absorb_power/10,no_adapt=1,weights_count=0,android_matters=0)
			if(Is_Tens()) src<<other


	if(M.Regenerate && BP>M.BP*2.4 * M.Regenerate**0.4) spawn M.Death(src,1)
	else spawn M.Death(src)

mob/proc/can_absorb(mob/M)
	if(!M||!ismob(M)) return
	if(M.Dead)
		src<<"Dead people can not be absorbed"
		return
	if(M.Final_Realm())
		src<<"You can not absorb in the final realm"
		return
	if(locate(/area/Prison) in range(0,src))
		src<<"You can not absorb in the prison"
		return
	if(M.Safezone)
		src<<"You can not do this in a safezone"
		return
	if(tournament_override(fighters_can=0)) return
	if(Shadow_Sparring)
		src<<"You are pre-occupied with shadow sparring"
		return
	if(istype(M,/mob/Body))
		src<<"Bodies can not be absorbed"
		return
	if(M.client&&client&&M.client.address==client.address)
		src<<"Alts can not be absorbed"
		return
	if(last_absorbed==M.key)
		src<<"You can not absorb the same person twice in a row"
		return
	if(alignment_on&&both_good(src,M))
		src<<"You can not absorb a fellow good person"
		return
	if(Same_league_cant_kill(src,M))
		src<<"You can not absorb someone in the same league as you"
		return
	if(M.spam_killed)
		src<<"You can not absorb [M] because they are death immune"
		return
	if(!M.KO)
		src<<"[M] must be knocked out for you to absorb them"
		return
	if(KO) return
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

	show_message=1 //to bug test why it will sometimes not let you use IT but yet not tell you why

	if(can_ignore_SI&&A&&A.block_SI)
		if(show_message) src<<"[A] is blocking instant transmission right now"
		return 1
	if(logout_timer&&z!=18)
		if(show_message) src<<"You can not teleport away if you were recently damaged"
		return 1
	if(ismob(loc))
		if(show_message) src<<"You can not teleport while body swapped"
		return 1
	if(Teleport_nulled())
		if(show_message) src<<"There is a teleport nullifier somewhere disrupting your ability to teleport"
		return 1
	if(A)
		var/area/a=A.get_area()
		if(Planet_has_teleport_nullifier(a.name))
			if(show_message) src<<"There is a teleport nullifier where [A] is, you can't lock onto them"
			return 1
	if(KO)
		if(show_message) src<<"You can not teleport while knocked out"
		return 1
	if(A&&A.Dead&&Is_In_Afterlife(A)&&!Is_In_Afterlife(src))
		if(show_message) src<<"People in the living world can not teleport to dead people who are in the afterlife. Dead \
		people in the afterlife's energy is undetectable from the living world."
		return 1
	if(A&&A.Is_Cybernetic())
		if(show_message) src<<"This does not work on cyborgs/androids because their energy is permanently hidden"
		return 1
	if(Dead&&!KeepsBody)
		if(show_message) src<<"Dead people can not use shunkan ido unless the 'keep body' ability has been used on them. \
		Mostly the Kaioshin and Daimao have the ability to let a dead person keep their body."
		return 1
	if(A&&!(A.Mob_ID in SI_List))
		if(show_message) src<<"You do not know their energy. To know someone's energy you must have been near them a certain \
		amount of time"
		return 1
	if(A&&A.Ship) A=A.Ship
	if(A&&z!=A.z&&(A.z==10||A.Final_Realm()||(ismob(A)&&A.Prisoner())))
		if(show_message) src<<"You cannot teleport to other dimensions."
		return 1
	if(Final_Realm()||Prisoner())
		if(show_message) src<<"You can not teleport out of this place"
		return 1
	if(A)
		var/turf/T=A.loc
		if(!isturf(T))
			if(show_message) src<<"You can not teleport to them because they are in the void"
			return 1
		if(T.Builder&&T.Builder!=key)
			if(show_message) src<<"You can not teleport in to other people's houses"
			return 1
		for(var/area/B in range(0,A)) if(istype(B,/area/Inside))
			if(show_message) src<<"You cannot teleport inside people's houses"
			return 1
obj/Shunkan_Ido
	name="Instant Transmission"
	teachable=1
	hotbar_type="Ability"
	can_hotbar=1
	Skill=1
	Teach_Timer=9
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
		set category="Skills"
		if(!A||A=="Cancel") return
		if(Ki<100)
			usr<<"You do not have enough energy"
			return
		if(usr.Cant_SI(show_message=0)) return
		if(usr.Cant_SI(A)) return
		if(using_si)
			usr<<"You are already using this"
			return
		using_si=1
		player_view(15,usr)<<"[usr] begins concentrating..."
		usr<<"This may take a minute..."
		var/turf/old_loc=usr.loc
		var/timer=round(45/Level)
		if(timer<6) timer=6
		for(var/v in 1 to timer)
			if(usr&&usr.loc!=old_loc)
				usr<<"You moved and lost your focus, teleport cancelled"
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
			usr<<"You found their energy signature."
			player_view(15,usr)<<"[usr] disappears in a flash!"
			player_view(10,src)<<sound('teleport.ogg',volume=30)
			if(!usr.tournament_override(fighters_can=0,show_message=0)) for(var/mob/B in oview(1,usr))
				if(B.client&&!B.Prisoner())
					if(!B.Safezone)
						player_view(15,B)<<"[B] disappears!"
						B.loc=A.loc
						step_rand(B)
						spawn(1) player_view(15,B)<<"[B] suddenly appears!"
					else B<<"[usr] tried to teleport you, but it failed because you are in a safezone"
			usr.loc=A.loc
			step_rand(usr)
			oview(10,src)<<sound('teleport.ogg',volume=30)
		else usr<<"[A] logged out..."
		using_si=0

mob/proc/Cant_Kai_Teleport(destination)
	if(logout_timer&&z!=18)
		src<<"You can not teleport away if you were recently damaged"
		return 1
	if(ismob(loc))
		src<<"You can not teleport while body swapped"
		return 1
	if(KO)
		src<<"You can not teleport while knocked out"
		return 1
	if(Teleport_nulled())
		src<<"There is a teleport nullifier somewhere disrupting your ability to teleport"
		return 1
	if(destination && Planet_has_teleport_nullifier(destination,src))
		return 1
	if(Final_Realm()||Prisoner())
		src<<"You can not teleport out of this place."
		return 1
	if(Ki<max_ki*0.9)
		src<<"You need 90%+ energy to use this"
		return 1

proc/Planet_has_teleport_nullifier(planet,mob/reciever)
	for(var/obj/Giant_Teleport_Nullifier/tn in teleport_nullifiers) if(tn.z)
		var/area/a=tn.get_area()
		if(a.name==planet)
			if(reciever) reciever<<"[planet] has a teleport nullifier somewhere on it, you can't get a lock on it"
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
		if("Namek") kt_z=3
		if("Vegeta") kt_z=4
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

obj/Teleport
	teachable=1
	name="Kai Teleport"
	Skill=1
	hotbar_type="Ability"
	can_hotbar=1
	//Cost_To_Learn=100
	Teach_Timer=24
	desc="Teleport to any planet. This will drain all your energy. Anyone who is beside \
	you will be taken with you."
	verb/Hotbar_use()
		set hidden=1
		Kai_Teleport()
	verb/Kai_Teleport()
		set category="Skills"
		if(usr.Cant_Kai_Teleport()) return
		var/list/Planets=new
		Planets.Add("Cancel","Checkpoint","Heaven","Hell","Arconia","Earth","Namek","Vegeta","Ice","Desert","Jungle",\
		"Android","Kaioshin","Space")
		for(var/obj/Planets/p in planets) if((p.name in disabled_planets)||(p.name in destroyed_planets)) Planets-=p.name
		var/image/I=image(icon='Black Hole.dmi',icon_state="full")
		I.icon+=rgb(rand(0,255),rand(0,255),rand(0,255))
		var/turf/T
		var/n=input("Choose a realm") in Planets
		if(!n||n=="Cancel") return
		if(usr.Cant_Kai_Teleport(destination=n)) return

		T=Get_kt_spawn(n)

		if(!T) return
		//usr.Ki=0
		flick(I,usr)
		sleep(20)
		if(!usr||usr.KO) return
		if(!usr.tournament_override(fighters_can=0,show_message=0)) for(var/mob/P in oview(1)) if(!P.Prisoner())
			if(!P.drone_module||P.client)
				if(!P.Safezone) P.loc=T
				else P<<"[usr] tried to teleport you, but couldn't because your in a safezone"
		usr.loc=T
obj/var/Is_Buff
mob/proc/Power_up()
	if(!powerup_obj) return
	if(KO) return
	for(var/obj/Kaioken/k in src) if(k.Using)
		if(grabber)
			src<<"You can not perform kaioken while being grabbed"
			return
		if(!kaioken_level) view(10,src)<<'powerup.wav'
		if(kaioken_level<20)
			kaioken_level++
			kaioken_loop()
		return
	if(powerup_obj.Powerup==-1)
		src<<"You stop powering down"
		powerup_obj.Powerup=0
	else if(!powerup_obj.Powerup)
		if(Is_oozaru())
			src<<"You can not use power up while in oozaru form"
			return
		if(Tournament&&Fighter1!=src&&Fighter2!=src&&(src in All_Entrants))
			src<<"You can not power up until it is your turn to fight"
			return
		powerup_obj.Powerup=1
		src<<"You begin powering up"
		if(BPpcnt<=100) Make_Shockwave(src,sw_icon_size=256)
		player_view(10,src)<<sound('aura3.ogg',volume=10)
	else if(!Redoing_Stats)
		var/obj/Ultra_Super_Saiyan/USSj=locate(/obj/Ultra_Super_Saiyan) in src
		if(bp_tiers)
			if(!ssj&&SSjAble&&SSjAble<=Year) SSj()
			else if(ssj==1&&USSj&&USSj.using_ussj&&BP>=ussj_bp_req&&!is_ussj) USSj()
			else if(ssj==1&&SSj2Able&&SSj2Able<=Year) SSj2()
			else if(!ismystic&&ssj==2&&SSj3Able&&SSj3Able<=Year) SSj3()
		else
			if(!ssj&&SSjAble&&SSjAble<=Year&&has_ssj_req()) SSj()
			else if(ssj==1&&USSj&&USSj.using_ussj&&BP>=ussj_bp_req&&!is_ussj) USSj()
			else if(SSj2Able&&SSj2Able<=Year&&ssj==1&&has_ssj2_req()) SSj2()
			else if(!ismystic&&ssj==2&&SSj3Able&&SSj3Able<=Year&&has_ssj3_req()) SSj3()
		Icer_Forms()
	Power_Control_Loop(powerup_obj)
	Aura_Overlays()
obj/Power_Control
	teachable=1
	Skill=1
	Teach_Timer=3
	//hotbar_type="Buff"
	//can_hotbar=1
	Cost_To_Learn=5
	Mastery=1
	desc="This allows you to power up and power down. Also, for certain forms, such as those of \
	Saiyans and Icers, powering up twice will cause them to go into their next form, powering \
	down twice will cause them to revert. Powering up will increase your Battle Power, but drain your \
	energy the higher you go. The more energy you have the higher you can power up without worrying \
	about the drain sucking you back down again."
	var/Powerup=0
	var/tmp/PC_Loop_Active
	New()
		spawn if(ismob(loc))
			var/mob/M=loc
			M.powerup_obj=src
	verb/Hotbar_use()
		set hidden=1
		Power_Up()
	verb/Power_Up()
		set category="Skills"
		usr.Power_up()
	verb/Power_Down()
		set category="Skills"
		if(usr.KO) return
		for(var/obj/Kaioken/k in usr) if(k.Using)
			usr.kaioken_level--
			usr.Aura_Overlays()
			if(usr.kaioken_level<0) usr.kaioken_level=0
			return
		if(Powerup==-1) usr.Revert()
		else if(Powerup)
			Powerup=0
			usr<<"You stop powering up"
		else
			Powerup=-1
			usr<<"You begin powering down"
			usr.Power_Control_Loop(src)
			if(usr) usr.Aura_Overlays()
proc/Center_Icon(obj/O,Icon,x_only)
	if(!O) return
	if(!Icon) Icon=O.icon
	O.pixel_x=Icon_Center_X(Icon)
	if(!x_only) O.pixel_y=Icon_Center_Y(Icon)
proc/Icon_Center_X(O)
	var/icon/I=new(O)
	return -((I.Width()-world.icon_size)*0.5)
proc/Icon_Center_Y(O)
	var/icon/I=new(O)
	return -((I.Height()-world.icon_size)*0.5)
proc/Scaled_Icon(O,X,Y)
	var/icon/I=new(O)
	I.Scale(X,Y)
	return I
proc/Get_Width(O)
	var/icon/I=new(O)
	return I.Width()
proc/Get_Height(O)
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
	var/Kaioken='Aura, Kaioken, Big.dmi'
	var/SSj='Aura, SSj, Big.dmi'
	var/USSj='USSj Aura.dmi'
	var/SSj2='Aura, SSj, Big.dmi'
	var/SSj3='ssj3 aura.dmi'
	var/SSj4='Aura, Big.dmi'
	var/Legend='Aura, LSSj, Big.dmi'
	var/LSSj='Aura, LSSj, Big.dmi'
	var/Init
	New()
		if(!Init)
			Init=1
			icon=Scaled_Icon(icon,74,74)
			Kaioken=Scaled_Icon(Kaioken,84,84)
			SSj=Scaled_Icon(SSj,90,90)
			SSj2=Scaled_Icon(SSj2,95,95)
			//SSj3=Scaled_Icon(SSj3,100,100)
			SSj4=Scaled_Icon(SSj4,100,100)
			Legend=Scaled_Icon(Legend,100,100)
			LSSj=Scaled_Icon(LSSj,100,100)

mob/var/tmp/obj/Auras/Auras

mob/proc/Stop_Powering_Up()
	powerup_mobs-=src
	if(powerup_obj && (powerup_obj.Powerup in list(0,1)))
		powerup_obj.Powerup=0
		if(BPpcnt>100) BPpcnt=100
		Aura_Overlays()

mob/proc/Aura_Overlays(remove_only)
	if(!Auras) for(var/obj/Auras/A in src) Auras=A
	if(!Auras) return

	if(remove_only || (BPpcnt<=100 && !kaioken_level))
		overlays-=Auras.Old
		Add_Sparks()

	else
		var/image/I=image(icon=Auras.icon)
		//var/obj/Transform/T=locate(/obj/Transform) in src
		//if(T&&T.aura&&T.Active) I.icon=T.aura
		if(Class=="Legendary Saiyan")
			I.icon=Auras.Legend
			if(ssj)
				I.icon=Auras.LSSj
				I.icon_state="2"
		else if(ssj==1)
			I.icon=Auras.SSj
			if(is_ussj)
				I.icon=Auras.USSj
		else if(ssj==2)
			I.icon=Auras.SSj2
			I.icon_state="2"
		else if(ssj==3)
			I.icon=Auras.SSj3
			I.icon_state=""
		else if(ssj==4)
			I.icon=Auras.SSj4
			I.icon_state="2"
		if(kaioken_level) I.icon=Auras.Kaioken

		I.pixel_x=Icon_Center_X(I.icon)
		overlays-=Auras.Old
		overlays+=I
		Auras.Old=I
		Add_Sparks()

mob/proc/Remove_Sparks() overlays.Remove('Sparks LSSj.dmi','Electric_Mystic.dmi','Elec.dmi',\
'Electric_Blue.dmi','Demon Vampire Majin By Tobi Uchiha.dmi','LSSJ powerz.dmi','SSj2 Electric Tobi Uchiha.dmi',\
'SSj3 Electric Tobi Uchiha.dmi','USSj Electric Tobi Uchiha.dmi')

mob/proc/Add_Sparks()
	Remove_Sparks()

	//if(BPpcnt>100&&(ismajin||Vampire||Race=="Demon")) overlays+='Demon Vampire Majin By Tobi Uchiha.dmi'
	if(BPpcnt>100&&Vampire) overlays+='Demon Vampire Majin By Tobi Uchiha.dmi'

	if(BPpcnt>100)
		if(Class=="Legendary Saiyan") overlays+='LSSJ powerz.dmi' //overlays+='Sparks LSSj.dmi'
		if(ismystic) overlays+='Electric_Mystic.dmi'
	if(ssj==2) overlays+='SSj2 Electric Tobi Uchiha.dmi'
	if(ssj==3) overlays+='SSj3 Electric Tobi Uchiha.dmi'

obj/Fly
	teachable=1
	hotbar_type="Ability"
	can_hotbar=1
	Skill=1
	Cost_To_Learn=1
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
		set hidden=1
		Fly()
	verb/Fly()
		set category="Skills"
		if(usr.Action=="Meditating") usr.Meditate()
		if(usr.Action=="Training") usr.Train()
		if(!usr.Disabled())
			if(!usr.Flying) usr.Fly()
			else usr.Land()
mob/proc/Layer_Update()
	layer=initial(layer)
	if(Flying) layer+=1
mob/proc/Fly(obj/Fly/F)
	if(Flying) return
	if(!F) for(var/obj/Fly/O in src) F=O
	if(!F&&!client) contents+=new/obj/Fly
	if(!F) return
	if(Ki>=Fly_Drain(F)||!client||Cyber_Fly)
		player_view(10,src)<<sound('Jump.wav',volume=15)
		icon_state="Flight"
		Flying=1
		Layer_Update()
		Fly_loop()
		if(icon=='Demon6.dmi'||icon=='Demon6, Female.dmi')
			F.overlays-=F.overlays
			F.overlays=overlays
			overlays-=overlays
	else src<<"You are too tired to fly."
mob/proc/Land()
	if(!Flying) return
	density=1
	icon_state=""
	Flying=0
	Layer_Update()
	overlays-=FlightAura
	for(var/obj/Fly/A in src) if(A.overlays)
		overlays+=A.overlays
		A.overlays-=A.overlays
	Regenerator_loop()
	if(grabbed_mob&&ismob(grabbed_mob))
		grabbed_mob.loc=loc
		grabbed_mob.Regenerator_loop()
proc/Random_Fart()
	var/sound/S=pick('Fart1.wav','Fart2.wav','Fart3.wav','Fart4.wav','Fart5.wav','Fart6.wav','Fart7.wav',\
	'Fart8.wav','Fart9.wav','Fart10.wav','Fart11.wav','Fart12.wav','Fart13.wav','Fart14.wav','Fart 15.wav',\
	'Fart 16.wav','Fart 17.wav','Fart 18.wav','Fart 19.wav')
	return S

var/image/Self_Destruct_Fire=image(icon='Lightning flash.dmi',layer=99)

turf/proc/Self_Destruct_Lightning(B) if(B)
	overlays-=Self_Destruct_Fire
	overlays+=Self_Destruct_Fire
	spawn(B) if(src) overlays-=Self_Destruct_Fire

var/sd_wait_time=20 //minutes

obj/Self_Destruct
	teachable=1
	Skill=1
	Cost_To_Learn=8
	Teach_Timer=5
	hotbar_type="Ability"
	can_hotbar=1
	var/next_sd=0
	var/tmp/using_sd
	desc="Using this will kill you. It is an extremely powerful attack, one of the top 3 at least. \
	It will affect a large area. If you have death regeneration this attack is much weaker."
	verb/Hotbar_use()
		set hidden=1
		Self_Destruct()
	verb/Self_Destruct()
		set category="Skills"
		if(usr.KO) return

		//because dead people would cheat in fights, SD, come back instantly at 100% power, kill you
		if(usr.Dead)
			usr<<"Dead people can not self destruct"
			return

		if(usr.grabber)
			usr<<"You can not perform self destruct because you are being grabbed"
			return
		if(world.realtime<next_sd)
			usr<<"You must wait [sd_wait_time] minutes before you can do this again"
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
		next_sd=world.realtime + (sd_wait_time*60*10)
		using_sd=1
		usr.move=0

		var/obj/rebuild_module=locate(/obj/Module/Rebuild) in usr.active_modules

		player_view(10,usr)<<sound('aura3.ogg',volume=30)
		player_view(12,usr)<<"A huge explosion eminates from [usr] ([usr.displaykey]) and surrounds the area!"
		player_view(10,usr)<<sound('basicbeam_fire.ogg',volume=20)
		Make_Shockwave(usr,sw_icon_size=512)
		var/Dist=10
		for(var/N=0,N<5,N++) for(var/turf/T in view(Dist)) if(T.opacity&&(T.Health<usr.BP||usr.Epic())&&usr.Is_wall_breaker())
			T.Health=0
			T.Destroy()
		for(var/turf/T in view(Dist))
			for(var/obj/O in T) if(O.Health<=usr.BP)
				Big_crater(O.loc)
				del(O)
			for(var/mob/P in T) if(P!=usr)
				if(!P.AOE_auto_dodge(usr,usr.loc))
					var/Damage=100*((usr.Pow/P.Res)**0.5)*((usr.BP/P.BP)**0.4)*ki_power
					if(usr.Race=="Spirit Doll") Damage*=1.5

					if(usr.Regenerate || rebuild_module) Damage/=2.3

					if(P.ki_shield_on()) P.Ki-=Damage*shield_reduction*(P.max_ki/100)/(P.Eff**shield_exponent)*P.Generator_reduction()
					else P.Health-=Damage
					if(P.Health<=0||P.Ki<=0)
						if(P.Regenerate&&!P.KO&&usr.BP>P.BP*P.Regenerate) spawn P.Death(usr,1)
						else spawn P.Death(usr)
			if(usr&&T) if((T.Health<usr.BP||usr.Epic())&&usr.Is_wall_breaker())
				T.Health=0
				T.Destroy()
			var/Timer=rand(50,100)
			T.Self_Destruct_Lightning(Timer)
			spawn(Timer) Dust(T,To_multiple_of_one(0.5))
			if(prob(5)) sleep(1)
		spawn if(usr) usr.Death(usr)
		usr.Ki=0
		usr.move=1
		using_sd=0
mob/proc/AOE_auto_dodge(mob/attacker,turf/origin,min_dist=7,max_dist=10)
	if(KO||KB||Frozen||Safezone) return
	var/turf/original_loc=loc
	var/auto_dodge=5*((Def/attacker.Off)**2)*(BP/attacker.BP)
	if(precog&&precogs&&prob(precog_chance)&&Ki>max_ki*0.2)
		precogs--
		//Ki-=Ki/30/Eff**0.4
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
			loc=safe_turf
			flick('Zanzoken.dmi',src)
			player_view(10,src)<<sound('teleport.ogg',volume=15)
			if(loc!=original_loc) return 1
mob/var/last_revived=0 //realtime
obj/Kaio_Revive
	name="Revive"
	Skill=1
	hotbar_type="Support"
	can_hotbar=1
	Cost_To_Learn=40
	desc="This will bring someone back to life. Just face them and use it"
	teachable=1
	Teach_Timer=24
	clonable=0
	var/next_use=0
	var/revive_delay=1.5 //hours
	New() if(!next_use) next_use=world.realtime+(revive_delay*60*60*10)
	verb/Hotbar_use()
		set hidden=1
		Revive()
	verb/Revive()
		set category="Skills"
		if(usr.Android)
			usr<<"Androids cannot use natural-only abilities"
			return
		if(usr.Dead)
			usr<<"You cannot use this if you are dead."
			return
		for(var/mob/A in Get_step(usr,usr.dir)) if(A.client&&A.Dead)
			if(usr.client.address==A.client.address)
				usr<<"You can not revive alts"
				return
			if(world.realtime<next_use)
				var/hours=(next_use-world.realtime)/10/60/60
				usr<<"You can not revive anyone for another [round(hours)] hours and [round(hours*60 %60)] minutes"
				return
			var/minutes=60
			if(A.base_bp/A.bp_mod>Avg_Base*1.3&&world.realtime<A.last_revived+(minutes*60*10))
				var/minutes_left=(A.last_revived+(minutes*60*10))-world.realtime
				usr<<"[A] can not be revived because they were revived less than [minutes] minutes ago. They \
				must wait another [round(minutes_left)] minutes and [round(minutes_left%60)] seconds to be revived \
				again by the revive skill"
				A<<"[usr] tries to revive you, but you were revived less than [minutes] minutes ago, and must \
				wait another [round(minutes_left)] and [round(minutes_left%60)] seconds to be revived again by the \
				revive skill"
				return
				/*switch(alert("You can not use this til year [Last_Use+2]. Unless you sacrifice your own life. Proceed?",\
				"Options","No","Yes"))
					if("No") return
					if("Yes")
						usr.Dead=1
						usr.overlays-='Halo.dmi'
						usr.overlays+='Halo.dmi'*/
			player_view(15,usr)<<"[A] is revived by [usr]"
			next_use=world.realtime+(revive_delay*60*60*10)
			A.last_revived=world.realtime
			A.Revive()
			/*switch(alert(A,"Do you want sent to your spawn?","Options","Yes","No"))
				if("Yes")
					player_view(15,A)<<"[A] was returned to their home"
					A.Respawn()*/
			A.Respawn()
			break
obj/Heal
	teachable=1
	Skill=1
	Cost_To_Learn=5
	hotbar_type="Support"
	can_hotbar=1
	Teach_Timer=4
	var/Next_Injury_Heal=0
	desc="You can heal anyone in front of you by giving up some of your own health and energy. If they \
	have certain status problems they can be further alleviated by healing them, with multiple heals \
	they may be cured."
	verb/Hotbar_use()
		set hidden=1
		Heal()
	verb/Heal()
		set category="Skills"
		if(usr.Android)
			usr<<"Androids cannot use natural-only abilities"
			return
		if(usr.tournament_override(fighters_can=0)) return
		var/Ki_Drain=usr.max_ki/usr.Eff
		if(Ki_Drain>usr.max_ki) Ki_Drain=usr.max_ki
		if(usr.KO||usr.Ki<Ki_Drain) return
		for(var/mob/A in Get_step(usr,usr.dir))
			if(!A.client) return
			if(alignment_on && A.alignment=="Evil" && usr.alignment=="Good")
				usr<<"Good can not heal evil"
				return
			var/Health_Drain=50
			if(usr.Race=="Namek") Ki_Drain/=2
			usr.Health-=Health_Drain
			usr.Ki-=usr.max_ki/usr.Eff
			Skill_Increase(10,usr)
			A.Full_Heal()
			if(A.Diarea) A.Diarea-=1
			//if(A.Zombie_Virus) A.Zombie_Virus-=10
			player_view(15,usr)<<"<font color=#FFFF00>[usr] heals [A]"
			if(Next_Injury_Heal<=Year) for(var/obj/Injuries/I in A.injury_list)
				Next_Injury_Heal=Year+1
				player_view(15,usr)<<"[A]'s [I] injury disappears"
				del(I)
				A.Add_Injury_Overlays()
				break
			break
mob/var/next_unlock=0
mob/proc/potential_mod()
	if(Race=="Half Saiyan") return 1.4
	else if(Race=="Human") return 2
	else if(Race=="Tsujin") return 1.8
	else if(Race=="Spirit Doll") return 2
	else if(Race=="Namek") return 1.25
	else if(Race=="Android") return 0
	else if(Race=="Icer") return 0.6
	else if(Race=="Kai") return 1.5
	return 1

obj/Unlock_Potential
	teachable=1
	Skill=1
	hotbar_type="Support"
	can_hotbar=1
	Teach_Timer=12
	Cost_To_Learn=30
	var/Usable=0 //The year you may next use this.
	desc="Using this on someone will greatly increase their power and energy. Each use will add 5 years \
	to how long you must wait to use it on someone again."
	verb/Hotbar_use()
		set hidden=1
		Unlock_Potential()
	verb/Unlock_Potential()
		set category="Skills"
		var/mob/A
		for(A in Get_step(usr,usr.dir)) break
		if(!A) A=usr
		if(alignment_on&&usr.alignment=="Good"&&A.alignment=="Evil")
			usr<<"Good people can not unlock evil people"
			return
		if(usr.Android)
			usr<<"Androids cannot use natural-only abilities"
			return
		if(A.Android)
			usr<<"Androids can not have their potential unlocked"
			return
		if(istype(A,/mob/new_troll))
			sleep(rand(40,60))
			player_view(15,usr)<<"[usr] uses unlock potential on [A]"
			return
		if(!A.client)
			usr<<"NPCs can not be unlocked"
			return
		if(world.realtime<A.next_unlock)
			var/hours=(A.next_unlock-world.realtime)/10/60/60
			usr<<"They can not have their potential unlocked for another [round(hours)] hours and \
			[round(hours*60 %60)] minutes"
			return
		switch(input(A,"[usr] wants to unlock your hidden powers") in list("No","Yes"))
			if("Yes")
				if(world.realtime<A.next_unlock) return
				player_view(15,usr)<<"[usr] uses unlock potential on [A]"
				A.next_unlock=world.realtime+(6*60*60*10)
				var/amount_from_user=100*A.potential_mod()
				var/amount_from_strongest=150*A.potential_mod()
				if(alignment_on&&A.alignment=="Evil")
					amount_from_user/=2
					amount_from_strongest/=2
				var/old_bp=A.base_bp
				A.Leech(usr,amount_from_user,no_adapt=1,weights_count=0)
				if(A.base_bp<=old_bp)
					var/mob/other=usr
					for(var/mob/m in players) if(m!=A&&m!=usr&&m.base_bp/m.bp_mod>A.base_bp/A.bp_mod)
						if(other==A||other==usr) other=m
						if(abs((1.3*A.base_bp/A.bp_mod)-(m.base_bp/m.bp_mod)) < abs((1.3*A.base_bp/A.bp_mod)-(other.base_bp/other.bp_mod)))
							other=m
					A.Leech(other,amount_from_strongest,no_adapt=1,weights_count=0)
					if(A.Is_Tens()&&A.Is_Admin()) A<<other
			if("No") if(usr) usr<<"[A] declined your offer."
obj/Taiyoken
	teachable=1
	Skill=1
	Cost_To_Learn=2
	Teach_Timer=1
	desc="Taiyoken, also known as Solar Flare, blinds an opponent for a limited amount of time. \
	It is mainly used so \
	that they dont see what direction you went in, and so that they cant pursue you until they can \
	see again. If they aren't looking directly at you, they will not be blinded. How long the person is \
	blinded depends primarily on your force vs their resistance, and the BP difference. Secondarily \
	how much ki you have will add more time, and how much regeneration the enemy has will reduce \
	the time. This move has a long cooldown to prevent spamming it"
	var/tmp/next_taiyoken=0
	verb/Hotbar_use()
		set hidden=1
		Taiyoken()
	can_hotbar=1
	hotbar_type="Ability"
	verb/Taiyoken()
		set category="Skills"
		if(usr.tournament_override(fighters_can=1)) return
		if(usr.KO) return
		if(world.time<next_taiyoken)
			var/minutes=next_taiyoken-world.time
			usr<<"You can not use this for another [round(minutes)] minutes and [round(minutes%60)] seconds"
			return
		if(!usr.attacking)
			usr.Ki-=150
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
					A<<"You are blinded by [usr]'s Taiyoken"
					var/n=40 * Clamp((usr.Pow/A.Res)**0.5,0.5,2) * Clamp((usr.BP/A.BP)**0.5,0.3,5) * (usr.max_ki/3000)**0.3 / Clamp(A.regen**0.5,0.5,3)
					n=To_multiple_of_one(n)
					A.taiyoken_blind_time=n
					A.Taiyoken_Blindness_Timer()
				else A<<"You were not looking directly at [usr]'s Taiyoken, so you were not blinded"

mob/var
	tmp/taiyoken_blindness_loop=0
	taiyoken_blind_time=0

mob/proc/Taiyoken_Blindness_Timer() spawn
	sight=0
	if(taiyoken_blindness_loop||!taiyoken_blind_time) return
	taiyoken_blindness_loop=1
	sight=1
	sleep(taiyoken_blind_time)
	taiyoken_blindness_loop=0
	taiyoken_blind_time=0
	sight=0

obj/Rift_Teleport/verb/Rift_Teleport()
	set category="Skills"
	var/image/I=image(icon='Black Hole.dmi',icon_state="full")
	switch(input("Person or Location?") in list("Person","Location",))
		if("Location")
			var/xx=input("X Location?") as num
			var/yy=input("Y Location?") as num
			var/zz=input("Z Location?") as num
			player_view(15,usr)<<"[usr] disappears into a mysterious rift that disappears after they enter."
			spawn flick(I,usr)
			sleep(10)
			usr.loc=locate(xx,yy,zz)
			player_view(15,usr)<<"[usr] appears out of a rift in time-space."
		else
			var/list/A=new
			for(var/mob/M in players) if(M.client) A.Add(M)
			var/Choice=input("Who?") in A
			player_view(15,usr)<<"[usr] disappears into a mysterious rift that disappears after they enter."
			spawn flick(I,usr)
			sleep(10)
			for(var/mob/M in A) if(M==Choice) usr.loc=locate(M.x+rand(-1,1),M.y+rand(-1,1),M.z)
			player_view(15,usr)<<"[usr] appears out of a rift in time-space."
obj/Imitation
	desc="You can use this on someone to imitate them in almost every way, so much so that you may \
	be confused with them. You can hit it again to stop imitating."
	var/imitating
	var/imitatorname
	Skill=1
	var/list/imitatoroverlays=new
	var/imitatoricon
	verb/Imitate()
		set category="Skills"
		if(!imitating)
			imitating=1
			imitatorname=usr.name
			imitatoroverlays.Add(usr.overlays)
			imitatoricon=usr.icon
			var/list/People=new
			for(var/mob/A in oview(usr)) People.Add(A)
			var/Choice=input("Imitate who?") in People
			for(var/mob/A in People) if(A==Choice)
				usr.icon=A.icon
				usr.overlays.Remove(usr.overlays)
				usr.overlays.Add(A.overlays)
				usr.name=A.name
				imitating=1
		else
			imitating=0
			usr.name=imitatorname
			usr.overlays.Remove(usr.overlays)
			usr.overlays.Add(imitatoroverlays)
			usr.icon=imitatoricon
			imitatoroverlays.Remove(imitatoroverlays)
obj/Invisibility
	desc="You can use this to make yourself invisible. Some people with very good senses will still \
	know you are there, or if they have visors capable of seeing invisible objects."
	Skill=1
	verb/Invisibility()
		set category="Skills"
		if(!usr.invisibility)
			usr.invisibility+=1
			usr.see_invisible+=1
			usr<<"You are now invisible."
		else
			usr.see_invisible-=1
			usr.invisibility-=1
			usr<<"You are visible again."
mob/var
	precog //for the blast avoidance...
	precog_chance=100
	precogs=1
mob/proc/precog_loop() spawn while(src)
	if(!precog) return
	while(precogs) sleep(100)
	sleep(900)
	precogs=To_multiple_of_one(6*Clamp(def_share(),0.5,1))
mob/proc/Observe_List()
	var/list/L=new
	for(var/mob/A in players) L+=A
	for(var/obj/A in view(40,src)) L+=A
	for(var/mob/A in view(10,src)) L+=A
	for(var/turf/A in view(10,src)) L+=A
	return L
obj/Observe
	teachable=1
	Skill=1
	Cost_To_Learn=1
	hotbar_type="Ability"
	can_hotbar=1
	Teach_Timer=1
	verb/Hotbar_use()
		set hidden=1
		Observe()
	verb/Observe(atom/A in usr.Observe_List())
		set src=usr.contents
		set category="Skills"
		if(ismob(A))
			var/mob/m=A
			if(m.hiding_energy&&m!=usr)
				usr<<"You can not observe them because they are hiding their energy"
				return
			if(m.Is_Cybernetic()&&m!=usr)
				usr<<"You can not observe cyborgs/androids because their energy is unsenseable"
				return
		usr.Get_Observe(A)
mob/Admin1/verb/Observe(atom/A in Observe_List())
	set category="Admin"
	Get_Observe(A)
mob/proc/Get_Observe(mob/M) if(client)
	if(M==src)
		if(Ship) client.eye=Ship
		else client.eye=src
	else client.eye=M
obj/Materialization
	teachable=1
	Skill=1
	Cost_To_Learn=20
	Teach_Timer=2
	Mastery=100
	hotbar_type="Support"
	can_hotbar=1
	desc="This ability lets you create weighted clothes to accelerate training and also create swords. \
	Your energy mod will improve the quality of weights you make."
	var
		weight_tier=1 //can go as high as someone wants
	verb/Hotbar_use()
		set hidden=1
		Materialize()
	verb/Materialize()
		set category="Skills"
		var/max_weight=(usr.max_weight()/4)*weight_tier*(usr.Eff**0.3)*1.1
		switch(input("") in list("Make Weights","Make Sword","Make Armor","Learn new weight tier"))
			if("Learn new weight tier")
				while(usr)
					var/sp_cost=10
					if(usr.Experience<sp_cost)
						usr<<"You need at least [sp_cost] skill points to do this"
						return
					switch(alert(usr,"increase the tier of weights you can make? this will cost [sp_cost] \
					skill points","options","Yes","No"))
						if("No") return
						if("Yes")
							if(usr.Experience<sp_cost) return
							usr.Experience-=sp_cost
							weight_tier+=0.5
			if("Make Weights")
				var/obj/items/Weights/A=new(Get_step(usr,usr.dir))
				A.weight=max_weight
				A.weight_name()
			if("Make Armor")
				new/obj/items/Armor(Get_step(usr,usr.dir))
			if("Make Sword")
				var/list/Swords=new
				for(var/A in typesof(/obj/items/Sword)) Swords+=new A
				var/obj/items/Sword/A=input("What kind of sword?") in Swords
				A.loc=Get_step(usr,usr.dir)
				Swords=null
mob/var
	ismajin
	ismystic
obj/Mystic
	teachable=1
	Skill=1
	Teach_Timer=9
	var/Last_Use=0
	hotbar_type="Buff"
	can_hotbar=1
	desc="\
	Mystic does the following:<br>\
	1.1x speed<br>\
	20% faster power up rate<br>\
	25% less drain from ki attacks<br>\
	10% BP increase while in a Super Saiyan form (excluding LSSj)<br>\
	15% anger boost decrease<br>\
	No drain from super saiyan 1+2<br>\
	Loss of ability to use super saiyan 3 and 4<br>\
	"
	verb/Hotbar_use()
		set hidden=1
		Mystic()
	verb/Mystic()
		set category="Skills"
		if(usr.Redoing_Stats)
			usr<<"You can not use this while choosing stat mods"
			return
		if(usr.ismajin)
			usr<<"You cant use this with Majin"
			return
		if(usr.ssj>=3)
			usr<<"<font color=teal>This cannot be used with Super Saiyan 3 or 4."
			return
		if(!usr.ismystic)
			Last_Use=Year
			usr.ismystic=1
			usr.Spd*=1.1
			usr.spdmod*=1.1
			usr.overlays-='SSj Aura.dmi'
			usr.overlays-='Elec.dmi'
			usr.overlays-='Electric_Blue.dmi'
			usr.overlays-='Electric_Majin.dmi'
			usr.overlays-=usr.ssjhair
			usr.overlays-=usr.ussjhair
			usr.overlays-=usr.ssjfphair
			usr.overlays-=usr.ssj2hair
			usr.overlays-=usr.ssj3hair
			usr.overlays-=usr.hair
			usr.overlays+=usr.hair
			usr<<"You are now using mystic"
		else usr.Mystic_Revert()
mob/proc/Mystic_Revert() if(ismystic)
	ismystic=0
	Spd/=1.1
	spdmod/=1.1
	src<<"You have stopped using mystic"

obj/Majin

	New()
		if(!icon) icon='Aura Electric.dmi'+rgb(150,0,0)

	teachable=1
	Skill=1
	hotbar_type="Buff"
	can_hotbar=1
	Teach_Timer=6
	can_change_icon=1
	desc="\
	Majin does the following:<br>\
	10% BP increase<br>\
	10% stronger anger<br>\
	x1.5 drain from all attacks<br>\
	"
	verb/Hotbar_use()
		set hidden=1
		Majin()
	verb/Majin()
		set category="Skills"
		if(usr.Redoing_Stats)
			usr<<"You can not use this while choosing stat mods"
			return
		if(usr.ismystic)
			usr<<"You cant use this with Mystic"
			return
		if(!usr.attacking)
			usr.attacking=1
			if(!usr.ismajin)
				usr.ismajin=1
				usr.bp_mult+=0.1
				usr.max_anger*=1.1
				usr.overlays-='SSj Aura.dmi'
				usr.overlays-='Elec.dmi'
				usr.overlays-='Electric_Blue.dmi'
				usr.overlays+=icon
				usr<<"You are now using majin"
			else usr.Majin_Revert()
			sleep(20)
			if(usr) usr.attacking=0

mob/proc/Majin_Revert() if(ismajin)
	for(var/obj/Majin/M in src)
		bp_mult-=0.1
		max_anger/=1.1
		overlays-=M.icon
		ismajin=0
		src<<"You have stopped using majin"
		//Revert()
		break

mob/var/Restore_Youth=0 //How many times you have had youth restored

obj/Restore_Youth
	teachable=1
	Skill=1
	Cost_To_Learn=40
	Teach_Timer=24
	clonable=0
	hotbar_type="Support"
	can_hotbar=1
	desc="You can use this to make someone younger. Each time they get this done they get less and less from it."
	var/Next_Use=0
	verb/Hotbar_use()
		set hidden=1
		Restore_Youth()
	verb/Restore_Youth()
		set category="Skills"
		if(usr.Android)
			usr<<"Androids cannot use natural-only abilities"
			return
		if(Year<Next_Use)
			usr<<"You can not use this til year [Next_Use]"
			return
		var/list/L=list(usr)
		for(var/mob/M in Get_step(usr,usr.dir)) if(M.client) L+=M
		var/mob/M=input("Choose who to restore youth on") in L
		if(!M||!M.client) return
		switch(input(M,"Do you want [usr] to restore your youth?") in list("No","Yes"))
			if("No")
				if(usr) usr<<"[M] denies the offer to restore their youth"
				return
		if(src&&Year<Next_Use) return
		if(usr&&M)
			Next_Use=Year+1
			var/Previous_Age=M.Age
			M.Age-=M.Age/((M.Restore_Youth+1)**2)
			/*
			1: 80 to 10
			2: 80 to 60
			3: 80 to 71
			4: 80 to 75
			*/
			if(M.Age<10) M.Age=10
			player_view(15,M)<<"[usr] brings [M]'s age from [round(Previous_Age,0.1)] to [round(M.Age,0.1)] years old"
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
	verb/Use()
		set category="Other"
		set src in oview(1)
		if(!Usable)
			usr<<"This can only be used every 1 minute"
			return
		if(usr.KO) return
		if(icon_state!="Open")
			icon_state="Open"
			spawn(600) icon_state="Closed"
		player_view(15,usr)<<"[usr] drinks from the sacred water jar"
		Usable=0
		spawn(600) Usable=1
		if(usr.hbtc_bp<usr.base_bp*0.12) usr.hbtc_bp=usr.base_bp*0.12
		if(usr.Health<100) usr.Health=100
		if(usr.Ki<usr.max_ki) usr.Ki=usr.max_ki
obj/RankChat
	name="Rank Chat"
	hotbar_type="Other"
	can_hotbar=1
	verb/Hotbar_use()
		set hidden=1
		RankChat()
	verb/RankChat(A as text)
		set category="Other"
		for(var/mob/B in players) if(locate(/obj/RankChat) in B)
			B<<"<font size=[B.TextSize]>(Rank)<font color=[usr.TextColor]>[usr.name]: [html_encode(A)]"
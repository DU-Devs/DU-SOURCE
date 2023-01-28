obj/Limit_Breaker
	desc="x2 BP, x3 Regeneration, x3 Recovery. When you activate this it lasts for a random period of time, at the end \
	of which you will be knocked out. It is very powerful but it is a big gamble on your chances of winning or losing \
	a fight."
	icon='Burst.dmi'
	teachable=1
	Skill=1
	Teach_Timer=10
	verb/Limit_Breaker()
		set category="Skills"
		if(usr.Redoing_Stats)
			usr<<"You can not use this while choosing stat mods"
			return
		if(usr.KO) return
		if(!Using)
			Using=1
			view(10)<<sound('aura3.ogg',volume=20)
			usr.Last_Anger=world.realtime
			usr.overlays+=icon
			usr.BP_Multiplier*=2
			usr.Regeneration*=2
			usr.Recovery*=2
mob/proc/Limit_Revert() for(var/obj/Limit_Breaker/A in src) if(A.Using)
	A.Using=0
	overlays-=A.icon
	BP_Multiplier/=2
	Regeneration/=2
	Recovery/=2
	src<<"You lose your energy and revert to your normal form."
	KO("limit breaker")
	if(!KO) KO("limit breaker")



obj/Hide_Energy
	teachable=1
	Skill=1
	Cost_To_Learn=35
	Teach_Timer=5
	desc="Using this ability will cause you to be hidden from sense, observe, and teleports. The drawback \
	is that while using it your available bp is very low"
	verb/Hide_Energy()
		set category="Skills"
		usr.hiding_energy=!usr.hiding_energy
		if(usr.hiding_energy)
			usr<<"You are now hiding your energy"
			for(var/mob/m in Players) if(m.client&&m.client.eye==usr&&!m.Is_Admin())
				m<<"[usr] has begun hiding their energy, you have lost the ability to observe them"
				m.client.eye=m
		else usr<<"You are no longer hiding your energy"
mob/var/hiding_energy

obj/Dash_Attack
	teachable=1
	Skill=1
	Cost_To_Learn=10
	Teach_Timer=2
	desc="A melee finishing move where you zanzoken in a straight line past your target hitting them with an extremely \
	accurate fast and powerful attack. It does more damage if you hit the target from behind."
mob/var/tmp/dash_attacking
mob/proc/Dash_Attack(turf/T) if(get_dir(src,T) in list(NORTH,SOUTH,EAST,WEST)) if(locate(/obj/Dash_Attack) in src)

	if(dash_attacking) return
	if((src in All_Entrants)&&!Is_Fighter()&&z==7) return

	for(var/mob/M in view(10,src)) if(get_dir(src,M)==get_dir(src,T)&&get_dir(M,T)==get_dir(src,T))
		var/Damage=(BP/M.BP)*((Str/M.End)**0.8)*25
		var/Drain=Max_Ki/10/(Eff**0.5)
		var/Acc=70*(BP/M.BP)*(Off/M.Def) //accuracy
		var/KB_Distance=(BP/M.BP)*(Str/M.End)*3
		if(Ki<Drain)
			src<<"You do not have enough energy"
			return
		dir=get_dir(src,T)
		var/turf/Step=loc
		dash_attacking=1
		while(Step!=T)
			loc=Step
			for(var/mob/P in loc) if(P!=src)
				if(prob(Acc))
					flick("Attack",src)
					if(P.dir==dir) P.Health-=Damage*2 //hit from behind
					else P.Health-=Damage
					if(P.Health<=0&&Fatal) spawn(15) if(P) P.Death(src)
					spawn(10) if(P)
						Make_Shockwave(P,7)
						P.Knockback(src,KB_Distance)
				else
					flick('Zanzoken.dmi',P)
					step(P,turn(dir,pick(90,-90)))
			After_Image(20,3)
			Step=get_step(Step,get_dir(Step,T))
			sleep(Delay(Speed_Ratio()))
		loc=T
		Ki-=Drain
		dash_attacking=0
		return 1




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
mob/proc/Destroy_Soul_Contracts() if(locate(/obj/Contract_Soul) in src)
	src<<"You have died. All your soul contracts are now destroyed"
	for(var/obj/Contract_Soul/C in src)
		if(C.P) C.P<<"[src] has died and their contract on your soul has been destroyed"
		del(C)
obj/Contract_Soul //Appears in the Souls tab
	desc="Click this and you will be able to manipulate the soul. You do not need to RP any of these actions \
	because by accepting the contract they have already given you permission to do this at any time."
	var/Mob_ID
	var/tmp/mob/P
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
		if(!P)
			switch(input("They are offline. The only action you can do is to destroy the soul contract, do you want to \
			do this?") in list("No","Yes"))
				if("Yes") del(src)
			return
		if(usr.KO)
			usr<<"You are powerless to do this right now!"
			return
		var/list/L=list("Cancel","Permanent Teleport","Temporary Teleport","Teleport Back","Permanent Summon",\
		"Temporary Summon","Send back","Kill","Absorb","Knock out","Leech soul","Alter soul's BP",\
		"Use soul to extend your decline","Soul Info","Take their soul contracts","Destroy their soul contracts",\
		"Destroy contract")
		if(presummon_x) L-="Temporary Summon"
		else L-="Send back"
		if(tpx) L-="Temporary Teleport"
		else L-="Teleport Back"
		switch(input("What do you want to do to the soul of [P]?") in L)
			if("Cancel") return
			if("Destroy their soul contracts")
				var/list/C=list("Cancel","All")
				for(var/obj/Contract_Soul/CS in P) C+=CS
				var/obj/S=input("Which of their Soul Contracts do you want to destroy?") in C
				if(!S||S=="Cancel") return
				if(S=="All")
					usr<<"All of [P]'s soul contracts have been destroyed"
					P<<"[usr] has used the soul contract on you to destroy all of your soul contracts"
					for(var/obj/Contract_Soul/CS in P) del(CS)
				else
					usr<<"[P]'s soul contract on [S] is destroyed"
					P<<"[usr] has used the soul contract on you to destroy your soul contract on [S]"
					del(S)
			if("Take their soul contracts")
				switch(input("If [P] has any soul contracts of their own, you will have them as well.") in \
				list("Continue","Cancel"))
					if("Cancel") return
					if("Continue")
						for(var/obj/Contract_Soul/C in P)
							var/Duplicate
							for(var/obj/Contract_Soul/CS in usr) if(C.Mob_ID==CS.Mob_ID) Duplicate=1
							if(!Duplicate)
								var/obj/Contract_Soul/S=new
								S.P=C.P
								S.Mob_ID=C.Mob_ID
								S.icon=C.icon
								S.overlays=C.overlays
								S.name=C.name
								S.suffix=C.suffix
								usr.contents+=S
			if("Soul Info")
				usr<<"*[P]'s soul info*<br>\
				Base BP: [Commas(P.Base_BP)]<br>\
				Lifespan: [P.Lifespan()] years<br>"
			if("Use soul to extend your decline")
				var/Min=-(usr.Lifespan()-usr.Age)
				var/Max=P.Lifespan()-P.Age
				var/N=input("You can use this to take/give years of life from the soul, which will give/take years of \
				life to you in exchange. If you take/give the maximum amount, them/you will die. Entering negative \
				amounts gives them that many years of your life, entering positive takes life from them and gives it \
				to you. Taking the maximum negative/positive amounts will kill one of you. You can give between \
				[Min] and [Max] years to [P]. Be aware you can only transfer a fraction of the amount, if you take \
				2 years off their life, you may only get 1 year of life in return, the rest will go into the void \
				forever.","Lifespan transfer",0) as num
				if(!N||!P) return
				Min=-(usr.Lifespan()-usr.Age)
				Max=P.Lifespan()-P.Age
				if(N<Min) N=Min
				if(N>Max) N=Max
				if(N<0)
					usr.Age+=N
					P.Age-=N/2
					usr<<"You gave [N] years of your life to [P], they recieve +[abs(N/2)] years of life in exchange."
					P<<"[usr] has used the soul contract to extent your lifespan by [abs(N/2)] years, by sacrificing \
					[abs(N)] years of their lifespan."
				if(N>0)
					usr.Age+=N/2
					P.Age-=N
					usr<<"You have gained +[N/2] years of life from [P]"
					//P<<"[usr] has used the soul contract to take [N] years from your lifespan, to extent their own"
			if("Permanent Teleport")
				if(P.Final_Realm()||P.Prisoner())
					usr<<"You can not teleport to them because they are in another dimension"
					return
				if(usr.Final_Realm()||usr.Prisoner())
					usr<<"You can not teleport to them because you are in another dimension"
				tpx=0
				tpy=0
				tpz=0
				usr.loc=P.loc
			if("Temporary Teleport")
				if(usr.Final_Realm()||usr.Prisoner())
					usr<<"You can not teleport to them because you are in another dimension"
					return
				if(P.Final_Realm()||P.Prisoner())
					usr<<"You can not teleport to them because they are in the another dimension"
					return
				tpx=usr.x
				tpy=usr.y
				tpz=usr.z
				usr.loc=P.loc
			if("Teleport Back")
				if(usr.Final_Realm()||usr.Prisoner())
					usr<<"You can not teleport back because you are in another dimension"
					return
				usr.loc=locate(tpx,tpy,tpz)
				tpx=0
				tpy=0
				tpz=0
			if("Permanent Summon")
				if(usr.Final_Realm()||usr.Prisoner())
					usr<<"You can not summon them because you are in another dimension"
					return
				if(P.Final_Realm()||P.Prisoner())
					usr<<"You can not summon them because they are in another dimension"
					return
				presummon_x=0
				presummon_y=0
				presummon_z=0
				oview(P)<<"[P] is summoned away by [usr]'s soul contract"
				P.loc=usr.loc
				view(P)<<"[P] is summoned to [usr] by the soul contract"
			if("Destroy contract")
				view(usr)<<"[usr] destroys the soul contract of [P]"
				del(src)
			if("Alter soul's BP")
				var/Pre_BP_Mod=P.BP_Mod
				if(Max_BP<P.Base_BP/P.BP_Mod) Max_BP=P.Base_BP/P.BP_Mod
				if(Max_BP<usr.Base_BP/usr.BP_Mod) Max_BP=usr.Base_BP/usr.BP_Mod
				var/Edit_BP=Max_BP*P.BP_Mod*0.85
				var/N=input("You can alter their bp anywhere between 1 and [Commas(Edit_BP)].","Alter BP",P.Base_BP) as num
				if(N<1) N=1
				if(N>Edit_BP) N=Edit_BP
				N*=P.BP_Mod/Pre_BP_Mod
				P<<"[usr] has altered your BP to [Commas(N)]"
				P.Base_BP=N
			if("Leech soul")
				usr<<"You have now fully leeched [P]"
				usr.Leech(P,5000)
			if("Knock out") if(P) P.KO("[usr]'s soul contract")
			if("Absorb")
				if(P.Dead)
					usr<<"They are dead and can not be absorbed"
					return
				view(P)<<"[P]'s demon master uses the soul contract to absorb [P], killing them!"
				usr.Absorb(P)
				P.Death(usr,1)
				usr<<"You have absorbed [P] from a distance, killing them"
			if("Kill")
				if(usr.Dead&&!P.Dead)
					usr<<"You used [P]'s life energy to bring yourself back to life"
					usr.Revive()
				P.Death("[usr]'s soul contract",1)
				if(P) P.loc=usr.loc
			if("Temporary Summon")
				if(P.KO)
					usr<<"[P] is in conditions which make it impossible to summon them"
					return
				if(P.Final_Realm()||P.Prisoner())
					usr<<"You can not summon them because they are in another dimension"
					return
				if(usr.Final_Realm()||usr.Prisoner())
					usr<<"You can not summon them because you are in another dimension"
					return
				usr<<"You can select 'send back' to send them back to where they were before you summoned them"
				oview(P)<<"[P] was summoned away by [usr]'s soul contract!"
				presummon_x=P.x
				presummon_y=P.y
				presummon_z=P.z
				P.loc=usr.loc
				view(P)<<"[P] was summoned by [usr]'s soul contract"
			if("Send back")
				if(P.Final_Realm()||P.Prisoner())
					usr<<"You can not send them back because they are in another dimension"
					return
				view(P)<<"[P] was sent back to his last location by [usr]'s soul contract"
				P.loc=locate(presummon_x,presummon_y,presummon_z)
				oview(P)<<"[P] was sent back by [usr]'s soul contract!"
				presummon_x=0
				presummon_y=0
				presummon_z=0
	New() Contract_Soul()
	proc/Contract_Soul() spawn while(src)
		if(!P)
			suffix=null
			for(var/mob/M in Players) if(M.Mob_ID&&M.key==Mob_ID)
				P=M
				break
			sleep(600)
		else
			Soul_Contract_Update(P)
			sleep(600)
	proc/Soul_Contract_Update(mob/M) if(M)
		P=M
		Mob_ID=P.key
		icon=P.icon
		overlays=P.overlays
		name=P.name
		suffix="Online"
obj/Demon_Contract
	name="Soul Contract"
	desc="You can offer someone a soul contract. If they accept, their soul will belong to you, and you will \
	get certain powers over them."
	teachable=1
	Skill=1
	Teach_Timer=35
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
	for(var/mob/P in get_step(src,dir)) if(P.client)
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
		switch(input(P,"[src] has offered you the soul contract. If you accept it, your soul will belong to them \
		and they will get certain powers over you.") in list("Deny","Accept"))
			if("Deny") view(P)<<"[P] has denied the soul contract from [src]"
			if("Accept")
				view(P)<<"[P] has accepted the soul contract from [src], their soul now belongs to [src]"
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
obj/Sense
	name="Sense Level 1"
	teachable=1
	Skill=1
	Teach_Timer=0.5
	Cost_To_Learn=3
	desc="The ability to sense everyone on the planet. You can see their overall power, which is their BP, stats, \
	and everything else combined into a percent."
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
	verb/Shadow_Spar()
		set category="Skills"
		if(Can_SS)
			Can_SS=0
			spawn(10) if(src) Can_SS=1
			usr.Shadow_Spar()
obj/Racial_Fusion
	teachable=0
	Skill=1
	Teach_Timer=5
	Cost_To_Learn=20
	desc="Racial Fusion allows you to fuse with another of your race. The person who offers to fuse will be the \
	one who gets deleted and gives their power to the other person. When you fuse with someone, any stats that \
	you have higher than theirs will overwrite theirs with the higher value. Basically your strengths become \
	their strengths, and their weaknesses are erased. It also comes with a large overall boost and combines \
	your skill points with theirs."
	var/Next_Use=0
	New() if(!Next_Use) Next_Use=Year+10
	verb/Racial_Fusion()
		set category="Skills"
		usr.Racial_Fusion(src)
mob/proc/Racial_Fusion(obj/Racial_Fusion/O)
	if(Year<O.Next_Use)
		src<<"You can not use this again til year [O.Next_Use]"
		return
	if(body_swapped())
		src<<"You can not use this while body swapped"
		return
	var/mob/P=input(src,"Choose who you want to fuse with, they must be the same race as you") in get_step(src,dir)
	if(!P) return
	if(P.Race!=Race)
		src<<"[P] is not a [Race]"
		return
	switch(input(src,"Are you sure you want to fuse with [P]? You will lose your character.") in \
	list("No","Yes"))
		if("Yes") if(P)
			O.Next_Use=Year+5
			view(10,src)<<'Super Namek.ogg'
			view(P)<<"[src] fuses with [P]!"
			P.Health+=Health
			P.Ki+=Ki
			P.Experience+=Experience
			if(P.Ki<P.Max_Ki) P.Ki=P.Max_Ki
			if(Base_BP/BP_Mod>P.Base_BP/P.BP_Mod) P.Base_BP=(Base_BP/BP_Mod)*P.BP_Mod
			if(Max_Ki/Eff>P.Max_Ki/P.Eff) P.Max_Ki=(Max_Ki/Eff)*P.Eff
			/*
			this block needs seriously changed
			also it needs to incorporate modless_gain, see "stat imprint" to know what i mean
			otherwise it will allow exponential stat growth

			if(Str/StrMod>P.Str/P.StrMod) P.Str=(Str/StrMod)*P.StrMod
			if(End/EndMod>P.End/P.EndMod) P.End=(End/EndMod)*P.EndMod
			if(Spd/SpdMod>P.Spd/P.SpdMod) P.Spd=(Spd/SpdMod)*P.SpdMod
			if(Pow/PowMod>P.Pow/P.PowMod) P.Pow=(Pow/PowMod)*P.PowMod
			if(Res/ResMod>P.Res/P.ResMod) P.Res=(Res/ResMod)*P.ResMod
			if(Off/OffMod>P.Off/P.OffMod) P.Off=(Off/OffMod)*P.OffMod
			if(Def/DefMod>P.Def/P.DefMod) P.Def=(Def/DefMod)*P.DefMod*/
			if(Gravity_Mastered>P.Gravity_Mastered) P.Gravity_Mastered=Gravity_Mastered
			P.Attack_Gain(30*60,src) //30 minutes
			P.Racial_Fusion_Gfx()
			Savable=0
			fdel("Save/[key]")
			del(src)
mob/proc/Racial_Fusion_Gfx() spawn if(src)
	var/N=6
	spawn while(N&&src)
		N--
		Make_Shockwave(src,6,'Electricgroundbeam2.dmi')
		sleep(rand(3,6))
	spawn if(src) Rising_Aura(src,25)
	Dust(src,30)
	spawn if(src) for(var/turf/T in view(7,src))
		T.Rising_Rocks()
		if(prob(35)) sleep(1)
	var/obj/O=new(loc)
	Timed_Delete(O,200)
	O.icon='White Flashing Circle.dmi'
	O.layer=9
	Center_Icon(O)
	spawn while(O)
		O.icon_state=pick("","1","2")
		sleep(rand(1,20))
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
mob/verb/Teach(mob/P in get_step(usr,usr.dir))
	set category="Skills"
	if(body_swapped())
		src<<"You can not teach skills while body swapped"
		return
	for(var/obj/Injuries/Brain/I in src)
		src<<"You have a brain injury and therefore cannot teach anything"
		return
	for(var/obj/Injuries/Brain/I in P)
		src<<"[P] has a brain injury and cannot learn anything"
		P<<"You have a brain injury and therefore could not learn anything from [src]"
		return
	var/list/Skills=list("Cancel")
	if(Knowledge>P.Knowledge) Skills+="Knowledge of Technology"
	for(var/obj/O in src) if(O.teachable&&(!(locate(O.type) in P)||O.Reteachable)) Skills+=O
	Skills+="*Skills you can not yet teach*"
	for(var/obj/O in Skills) if(Year<O.Next_Teach)
		Skills-=O
		Skills+="[O.name] (Teach at year [O.Next_Teach])"
	var/obj/A=input(src,"What do you want to teach? Skills they already know do not appear here. Skills you can not \
	yet teach are at the bottom seperated from the others.") in Skills
	if(!P) return
	if(A=="Knowledge of Technology")
		var/Percent=input(src,"What percent of your knowledge will you teach them?") as num
		if(Percent<=0) return
		if(Percent>100) Percent=100
		view(src)<<"[src] taught [P] [Percent]% of their knowledge of technology"
		P.Knowledge=Knowledge*(Percent/100)
	else if(isobj(A))
		var/obj/O
		if(istype(A,/obj/Buff))
			Save_Obj(A)
			O=new A.type
			Load_Obj(O)
			O.suffix=null
		else O=new A.type
		O.Next_Teach=Year+O.Teach_Timer
		O.Taught=1
		P.contents+=O
		A.Next_Teach=Year+A.Teach_Timer
		if(istype(A,/obj/Attacks)) O.icon=A.icon
		view(src)<<"[src] taught [P] the [A]!"
obj/var/Teach_Timer=0.2
obj/var/Next_Teach=0
mob/var/Regeneration_Skill
obj/Regeneration
	teachable=1
	Skill=1
	Teach_Timer=3
	Cost_To_Learn=10
	desc="This is a passive healing skill where, if your health goes below 100% you will begin trading energy \
	for health. You can turn it on and off at any time."
	verb/Regenerate()
		set category="Skills"
		if(usr.Is_Cybernetic())
			usr<<"Cybernetic beings cannot use this ability"
			return
		if(usr.KO) return
		if(!usr.Regeneration_Skill)
			usr.Regeneration_Skill=1
			usr<<"You are regenerating"
		else
			usr.Regeneration_Skill=0
			usr<<"You stop regenerating"
obj/Give_Power
	teachable=1
	Skill=1
	Cost_To_Learn=4
	Teach_Timer=0.2
	desc="You can transfer your health and energy to someone from a distance. The person can exceed 100% power \
	if you have enough health and energy, exceeding 100% energy raises their BP. The effect is only temporary, \
	because health and energy do not stay above 100% for long."
	verb/Give_Power()
		set category="Skills"
		if(usr.Android)
			usr<<"Androids cannot use natural-only abilities"
			return
		if(usr.KO) return
		if(!usr.Giving_Power)
			usr<<"Click again to stop giving power"
			usr.Give_Power(src)
		else
			usr.Giving_Power=0
			usr<<"You stop giving power"
mob/var/tmp/Giving_Power
mob/proc/Give_Power(obj/Give_Power/G)
	if((src in All_Entrants)&&z==7)
		src<<"You can not do this in a tournament"
		return
	var/list/Mobs=list("Cancel")
	for(var/mob/M in oview(10,src)) if(M.client) Mobs+=M
	if(Mobs.len<=2) Mobs-="Cancel"
	var/mob/M=input(src,"Choose a target to give power to") in Mobs
	if(Giving_Power) return
	if(!M||M=="Cancel") return
	Giving_Power=1
	view(src)<<"[src] is sending his power to [M]!"
	var/obj/O=new
	O.icon='Give Power.dmi'
	O.layer=layer+1
	spawn while(src&&Giving_Power&&M)
		missile(O,src,M)
		sleep(1)
	while(src&&M&&Giving_Power&&!KO&&getdist(src,M)<=20)
		dir=get_dir(src,M)
		if(M.Health<100) M.Health+=1
		Health-=1
		if(M.KO&&M.Health>=100) M.Un_KO()
		if(KO)
			Giving_Power=0
			return
		if(Ki>=Max_Ki/100)
			Ki-=Max_Ki/100
			var/N=Max_Ki/100*((M.Max_Ki/(M.Ki+1))**4)
			if(N>Max_Ki/50) N=Max_Ki/50
			M.Ki+=N/2
		sleep(2)
	Giving_Power=0
obj/Zanzoken
	teachable=1
	Skill=1
	Cost_To_Learn=1
	Teach_Timer=0.2
	desc="Zanzoken is the ability to use a burst of concentrated speed to reach a place very fast, \
	it is so fast it is basically like teleporting a short distance. You click the spot you want to go \
	to and your character will suddenly go there. The more you master this the less energy it will \
	drain, and you will gain more combo mastery which is crucial for higher levels of combat."
	verb/Combo_Toggle()
		set category="Other"
		if(!usr.Warp)
			usr<<"Combo Warping on"
			usr.Warp=1
		else
			usr<<"Combo Warping off"
			usr.Warp=0
mob/var/KeepsBody //If this is 1 you keep your body when Dead.
obj/Keep_Body
	desc="Using this on someone will allow them to use 100% of their power while dead."
	teachable=1
	Skill=1
	Teach_Timer=20
	verb/Keep_Body()
		set category="Other"
		if(usr.Android)
			usr<<"Androids cannot use natural-only abilities"
			return
		for(var/mob/M in get_step(usr,usr.dir))
			switch(input("Allow [M] to keep their body?") in list("Yes","No"))
				if("Yes") M.KeepsBody=1
				if("No") M.KeepsBody=0
			break
obj/Shield
	teachable=1
	Skill=1
	Teach_Timer=0.3
	Cost_To_Learn=3
	Mastery=100
	desc="You can toggle this on and off. A ki shield will surround you to protect you from all \
	attacks. Each attack will drain your energy instead of health. The shield will also protect you \
	from dying in space but it will drain energy heavily."
	icon='Shield Blue.dmi'
	verb/Shield()
		set category="Skills"
		if(usr.KO) return
		if(!Using)
			Using=1
			usr.Shield()
		else usr.Shield_Revert()
mob/proc/Shield_Revert()
	for(var/obj/Shield/A in src)
		overlays-=A.icon
		A.Using=0
mob/proc/Shield() for(var/obj/Shield/A in src) if(A.Using) overlays+=A.icon
obj/Make_Fruit
	teachable=1
	Skill=1
	Teach_Timer=20
	desc="With this you can make fruits that will increase the power and energy of those who eat them, \
	along with a temporary boost to regeneration and recovery. The more of them you eat however, the \
	less of an effect they will have each time."
	var/tmp/Making
	verb/Fruit()
		set category="Skills"
		if(Making)
			usr<<"You are already making one"
			return
		Making=1
		view(usr)<<"[usr] begins planting something"
		sleep(600)
		view(usr)<<"A strange fruit appears in front of [usr]"
		Making=0
		var/obj/items/Fruit/A=new
		A.name="[usr] Fruit"
		usr.contents+=A
obj/Curse/var/CursePower=0
obj/Bind
	var/Last_Usage=0
	var/last_bind=0
	Skill=1
	Cost_To_Learn=20
	desc="You can use this to bind someone to hell. You can only bind a person who is less than your \
	own power at the time. The stronger they are compared to you the more energy it will drain \
	to bind them"
	proc/bind_power(mob/m)
		return (m.Max_Ki/m.Eff)*(m.Eff**0.2)
	verb/Bind()
		set category="Skills"
		if(usr in All_Entrants) return
		if(world.realtime<last_bind+(5*60*60))
			usr<<"You can only use this every 5 minutes"
			return
		for(var/mob/A in get_step(usr,usr.dir)) if(A.client&&A.KO)
			if(A.BP>usr.BP)
				view(usr)<<"[usr] attempts to bind [A] to hell, but [A]'s spiritual power deflects it!"
				return
			if(usr.Ki<usr.Max_Ki*0.9)
				usr<<"You need at least 90% energy to attempt a bind"
				return
			last_bind=world.realtime
			if(locate(/obj/Curse) in A)
				for(var/obj/Curse/B in A)
					B.CursePower+=bind_power(usr)
					view(usr)<<"[usr] strengthens the bind already placed on [A] to [Commas(B.CursePower)] energy!"
			else
				var/obj/Curse/B=new
				B.CursePower+=bind_power(usr)
				view(usr)<<"[usr] successfully binds [A] to hell! The bind has [Commas(B.CursePower)] energy"
				A.contents+=B
			usr.Ki=0
	verb/UnBind()
		set category="Skills"
		if(Year<Last_Usage+1)
			usr<<"You can not use this until year [Last_Usage+1]"
			return
		var/list/L=new
		if(locate(/obj/Curse) in usr) L+=usr
		for(var/mob/P in get_step(usr,usr.dir)) if(locate(/obj/Curse) in P) L+=P
		var/mob/A=input("Who do you want to attempt to unbind?") in L
		if(!A) return
		for(var/obj/Curse/B in A)
			if(usr.Ki<usr.Max_Ki*0.9)
				usr<<"You need at least 90% energy to attempt to remove a bind"
				return
			Last_Usage=Year
			var/old_energy=B.CursePower
			B.CursePower-=bind_power(usr)
			usr.Ki=0
			if(B.CursePower<=0)
				view(usr)<<"[usr] succeeds in breaking the bind placed on [A]!"
				del(B)
			else view(usr)<<"[usr] weakened the bind from [Commas(old_energy)] to [Commas(B.CursePower)] energy"
			return
proc/Examine_List()
	var/list/L=new
	for(var/obj/O) if(O.desc) L+=O
	return L
mob/verb/Examine(obj/A in Examine_List()) if(A) src<<"<br><br>[A.desc]"
proc/Strongest_Person(mob/M)
	for(var/mob/P in Players) if(!M||P.Base_BP>M.Base_BP) M=P
	return M
proc/strongest_person_proportionate(mob/m)
	for(var/mob/p in Players) if(!m||p.Base_BP/p.BP_Mod>m.Base_BP/m.BP_Mod) m=p
	return m
mob/var/Semiperfect_Form
mob/var/Perfect_Form
mob/proc/Bio_Forms(mob/A) if(A.BP>=1000000) if(Race=="Bio-Android"&&A.Is_Cybernetic()) Bio_Next_Form()
mob/proc/Bio_Next_Form()
	if(!Semiperfect_Form)
		Semiperfect_Form=1
		if(BP_Mod<4)
			Base_BP*=4/BP_Mod
			BP_Mod=4
		Attack_Gain(1000,Strongest_Person())
		if(icon=='Bio Android 1.dmi') icon='Bio Android 2.dmi'
		if(icon=='Bio1.dmi') icon='Bio2.dmi'
	else if(!Perfect_Form)
		Perfect_Form=1
		BP_Mod*=form2x
		if(BP_Mod<8)
			Base_BP*=8/BP_Mod
			BP_Mod=8
		Attack_Gain(1000,Strongest_Person())
		if(icon=='Bio Android 2.dmi') icon='Bio Android 3.dmi'
		if(icon=='Bio2.dmi') icon='Bio3.dmi'
mob/var/Absorbed_Power=0
obj/var/Skill //If Skill=1 this obj is a SKILL
obj/Absorb
	Skill=1
	Cost_To_Learn=20
	desc="You can absorb a knocked out person. This will boost your health and energy beyond normal levels \
	temporarily. You will also get a permanent power increase in some cases. Absorbing people can also bring \
	you back to life, by absorbing either 1 living person or multiple dead people (on average 5 but it is \
	luck based), their base BP must also be more than 75% of yours and they can not be an alt or npc."
	verb/Absorb(mob/M in get_step(usr,usr.dir))
		set category="Skills"
		usr.Absorb(M)
mob/var/last_absorbed
mob/proc/Absorb(mob/M)
	if(!M.client) return
	if(M.Final_Realm())
		src<<"You can not absorb in the final realm"
		return
	if(locate(/area/Prison) in range(0,src))
		src<<"You can not absorb in the prison"
		return
	if(M.Safezone)
		src<<"You can not do this in a safezone"
		return
	if((src in All_Entrants)||(M in All_Entrants))
		src<<"You can not do this in a tournament"
		return
	if(Shadow_Sparring)
		src<<"You are pre-occupied with shadow sparring"
		return
	if(istype(M,/mob/Body))
		src<<"Bodies can not be absorbed"
		return
	if(M.client.address==client.address)
		src<<"Alts can not be absorbed"
		return
	if(last_absorbed==M.key)
		src<<"You can not absorb the same person twice in a row"
		return
	if(KO||!M.KO) return
	last_absorbed=M.key
	view(src)<<"[src] ([key]) absorbs [M]!"
	if(M.client)
		Match_Knowledge(M,40)
		Health=100
		Ki=Max_Ki
		if(Dead&&(!M.Dead||prob(20))&&M.Base_BP>Base_BP*0.75) if(!M.Regenerate) Revive()
	if(!M.Dead)
		var/Amount=100
		if(M.Regenerate) Amount/=5
		if(!M.client) Amount/=20
		Attack_Gain(Amount,M)
	if(M.client) Bio_Forms(M)
	if(M.Regenerate&&BP>M.BP*1.3*(M.Regenerate**0.3)) spawn M.Death(src,1)
	else spawn M.Death(src)
mob/proc/Match_Knowledge(mob/M,n=100) if(ismob(M))
	if(Knowledge<M.Knowledge)
		Knowledge+=M.Knowledge*(n/100)
		if(Knowledge>M.Knowledge) Knowledge=M.Knowledge
mob/var/ITMod=1
mob/proc/SI_Choices()
	var/list/L=list("Cancel")
	for(var/mob/P in Players) if((P.Mob_ID in SI_List)&&!P.hiding_energy) L+=P
	return L
mob/proc/Cant_SI(mob/A)
	if(A.Dead&&Is_In_Afterlife(A)&&!Is_In_Afterlife(src))
		src<<"People in the living world can not teleport to dead people who are in the afterlife. Dead \
		people in the afterlife's energy is undetectable from the living world."
		return 1
	if(Dead&&!KeepsBody)
		src<<"Dead people can not use shunkan ido unless the 'keep body' ability has been used on them. \
		Mostly the Kaioshin and Daimao have the ability to let a dead person keep their body."
		return 1
	if(!(A.Mob_ID in SI_List))
		src<<"You do not know their energy. To know someone's energy you must have been near them a certain \
		amount of time"
		return 1
	if(A.Ship) A=A.Ship
	if((A.z==10||A.Final_Realm()||(ismob(A)&&A.Prisoner()))&&z!=A.z)
		src<<"You cannot teleport to other dimensions."
		return 1
	if(Final_Realm()||Prisoner())
		src<<"You can not teleport out of this place"
		return 1
	var/turf/T=A.loc
	if(!isturf(T))
		src<<"You can not teleport to them because they are in the void"
		return 1
	if(T.Builder&&T.Builder!=ckey)
		src<<"You can not teleport in to other people's houses"
		return 1
	for(var/area/B in range(0,A)) if(istype(B,/area/Inside))
		src<<"You cannot teleport inside people's houses"
		return 1
obj/Shunkan_Ido
	teachable=1
	Skill=1
	Teach_Timer=20
	Cost_To_Learn=60
	clonable=0
	Write(savefile/F)
		var/OldUsing=Using
		Using=0
		..()
		Using=OldUsing
	desc="Shunkan Ido, also known as Instant Transmission, is self-explanatory. If you have enough \
	skill you can detect powers further away, and teleport to them. The more skill you have the \
	less time it will take to locate their energy. Anyone next to you will also be brought with you. \
	Some people are just too weak to sense, even to someone with very high skill in Shunkan Ido"
	verb/Shunkan_Ido(mob/A in usr.SI_Choices())
		set src=usr.contents
		set category="Skills"
		if(!A||A=="Cancel") return
		if(Ki<100||Using)
			usr<<"You do not have enough energy"
			return
		if(usr.Cant_SI(A)) return
		Using=1
		view(usr)<<"[usr] begins concentrating..."
		usr<<"This may take a minute..."
		sleep(1200/Level)
		Level+=0.1
		if(A&&usr)
			if(usr.Cant_SI(A)) return
			usr<<"You found their energy signature."
			oview(usr)<<"[usr] disappears in a flash!"
			view(10,src)<<sound('teleport.ogg',volume=30)
			for(var/mob/B in oview(1,usr)) if(B.client&&!B.Prisoner())
				if(!B.Safezone)
					oview(B)<<"[B] disappears!"
					B.loc=A.loc
					step_rand(B)
					spawn(1) oview(B)<<"[B] suddenly appears!"
				else B<<"[usr] tried to teleport you, but it failed because you are in a safezone"
			usr.loc=A.loc
			step_rand(usr)
			oview(10,src)<<sound('teleport.ogg',volume=30)
		else usr<<"[A] logged out..."
		Using=0
obj/Teleport
	teachable=1
	Skill=1
	Teach_Timer=20
	desc="Teleport to any planet instantly. This will drain all your energy. Anyone who is beside \
	you will be taken with you."
	verb/Kaio_Teleport()
		set category="Skills"
		if(usr.Final_Realm()||usr.Prisoner())
			usr<<"You can not teleport out of this place."
			return
		if(usr.Ki<usr.Max_Ki)
			usr<<"You need full energy to use this"
			return
		var/list/Planets=new
		Planets.Add("Afterlife","Heaven","Arconia","Earth","Puran","Braal","Ice","Desert","Jungle",\
		"Android","Kaioshin")
		var/image/I=image(icon='Black Hole.dmi',icon_state="full")
		I.icon+=rgb(rand(0,255),rand(0,255),rand(0,255))
		var/turf/T
		switch(input("Choose a realm") in Planets)
			if("Afterlife") T=locate(250,250,5)
			if("Heaven") T=locate(250,250,7)
			if("Arconia") T=locate(250,250,8)
			if("Earth") T=locate(250,250,1)
			if("Puran") T=locate(250,250,3)
			if("Braal") T=locate(250,250,4)
			if("Ice") T=locate(250,250,12)
			if("Desert") T=locate(100,90,14)
			if("Jungle") T=locate(150,443,14)
			if("Android") T=locate(497,497,14)
			if("Kaioshin") T=locate(250,250,13)
		flick(I,usr)
		for(var/mob/P in oview(1)) if(!P.Prisoner())
			if(!P.Safezone) P.loc=T
			else P<<"[usr] tried to teleport you, but couldn't because your in a safezone"
		usr.loc=T
		usr.Ki=0
obj/var/Is_Buff
obj/Power_Control
	teachable=1
	Skill=1
	Teach_Timer=3
	Cost_To_Learn=5
	Mastery=1
	desc="This allows you to power up and power down. Also, for certain forms, such as those of \
	Yasais and Frost Lords, powering up twice will cause them to go into their next form, powering \
	down twice will cause them to revert. Powering up will increase your Battle Power, but drain your \
	energy the higher you go. The more energy you have the higher you can power up without worrying \
	about the drain sucking you back down again."
	var/Powerup=0
	var/tmp/PC_Loop_Active
	verb/Power_Up()
		set category="Skills"
		if(usr.KO) return
		if(Powerup==-1)
			usr<<"You stop powering down"
			Powerup=0
		else if(!Powerup)
			Powerup=1
			usr<<"You begin powering up"
			view(10)<<sound('aura3.ogg',volume=10)
			spawn usr.Power_Effects(src)
		else if(!usr.Redoing_Stats)
			if(!usr.Cyber_Power)
				if(!usr.ssj&&usr.SSjAble&&usr.SSjAble<=Year&&usr.BP>=usr.ssjat) usr.SSj()
				else if(usr.SSj2Able&&usr.SSj2Able<=Year&&usr.ssj==1&&usr.BP>=usr.ssj2at) usr.SSj2()
				else if(!usr.ismystic&&usr.ssj==2&&usr.SSj3Able&&usr.SSj3Able<=Year&&usr.BP>=usr.ssj3at) usr.SSj3()
			usr.Icer_Forms()
		usr.Power_Control_Loop(src)
		usr.Aura_Overlays()
	verb/Power_Down()
		set category="Skills"
		if(usr.KO) return
		if(Powerup==-1) usr.Revert()
		else if(Powerup)
			Powerup=0
			usr<<"You stop powering up"
		else
			Powerup=-1
			usr<<"You begin powering down"
			usr.Power_Control_Loop(src)
			if(usr) usr.Aura_Overlays()
proc/Center_Icon(obj/O,Icon)
	if(!O) return
	if(!Icon) Icon=O.icon
	O.pixel_x=Icon_Center_X(Icon)
	O.pixel_y=Icon_Center_Y(Icon)
proc/Icon_Center_X(O)
	var/icon/I=new(O)
	return -((I.Width()-32)*0.5)
proc/Icon_Center_Y(O)
	var/icon/I=new(O)
	return -((I.Height()-32)*0.5)
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
	var/Old
	var/Kaioken='Aura, Kaioken, Big.dmi'
	var/SSj='Aura, SSj, Big.dmi'
	var/SSj2='Aura, SSj, Big.dmi'
	var/SSj3='Zen Aura.dmi'
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
	for(var/obj/Power_Control/P in src) P.Powerup=0
	BPpcnt=100
	Aura_Overlays()
mob/proc/Aura_Overlays()
	if(!Auras) for(var/obj/Auras/A in src) Auras=A
	if(!Auras) return
	if(BPpcnt<=100)
		overlays-=Auras.Old
		Add_Sparks()
	else
		var/image/I=image(icon=Auras.icon)
		//var/obj/Transform/T=locate(/obj/Transform) in src
		//if(T&&T.aura&&T.Active) I.icon=T.aura
		if(Class=="Legendary Yasai")
			I.icon=Auras.Legend
			if(ssj)
				I.icon=Auras.LSSj
				I.icon_state="2"
		else if(ssj==1)
			I.icon=Auras.SSj
		else if(ssj==2)
			I.icon=Auras.SSj2
			I.icon_state="2"
		else if(ssj==3)
			I.icon=Auras.SSj3
			I.icon_state="2"
		else if(ssj==4)
			I.icon=Auras.SSj4
			I.icon_state="2"
		for(var/obj/Kaioken/K in src) if(K.Using)
			I.icon=Auras.Kaioken
		I.pixel_x=Icon_Center_X(I.icon)
		overlays-=Auras.Old
		overlays+=I
		Auras.Old=I
		Add_Sparks()
mob/proc/Remove_Sparks() overlays.Remove('Sparks LSSj.dmi','Electric_Mystic.dmi','Elec.dmi','Electric_Blue.dmi')
mob/proc/Add_Sparks()
	Remove_Sparks()
	if(BPpcnt>100)
		if(Class=="Legendary Yasai") overlays+='Sparks LSSj.dmi'
		if(ismystic) overlays+='Electric_Mystic.dmi'
	if(ssj==2) overlays+='Elec.dmi'
	if(ssj==3) overlays+='Electric_Blue.dmi'
mob/proc/Power_Effects(obj/Power_Control/A) while(A&&A.Powerup>=1)
	var/Sleep=300/BP_Mod
	if(Sleep<100) Sleep=100
	for(var/turf/B in range(10,src)) if(prob(5)&&A&&A.Powerup>=1)
		B.Rising_Rocks()
		sleep(10)
	sleep(Sleep)
turf/proc/Rising_Rocks()
	var/image/I=image(icon='Rising Rocks.dmi',pixel_x=rand(-32,32),pixel_y=rand(-32,32))
	overlays-=I
	overlays+=I
	spawn(200) if(src) overlays-=I
obj/Fly
	teachable=1
	Skill=1
	Cost_To_Learn=1
	Teach_Timer=0.2
	desc="Obviously this lets you fly. But it drains energy to do so. The more you use it the more you \
	master it, and the more you master it, the less it drains. Also you can decrease the drain to a \
	lesser level by simply gaining more energy, but the effect is not the same as mastering the move \
	itself. This will let you move much faster than you can by walking."
	verb/Fly()
		set category="Skills"
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
	if(Ki>=Fly_Drain(F)||!client)
		view(10,src)<<sound('Jump.wav',volume=15)
		icon_state="Flight"
		if(Action in list("Meditating","Training")) Action=null
		Flying=1
		Layer_Update()
		if(icon=='Demon6.dmi')
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
	for(var/obj/Fly/A in src) if(A.overlays) overlays+=A.overlays
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
obj/Self_Destruct
	teachable=1
	Skill=1
	Cost_To_Learn=8
	Teach_Timer=5
	var/next_sd=0
	Write(savefile/F)
		var/OldUsing=Using
		Using=0
		..()
		Using=OldUsing
	desc="Using this will kill you. It is an extremely powerful attack, one of the top 3 at least. \
	It will affect a large area. If you have death regeneration this attack is much weaker."
	verb/Self_Destruct()
		set category="Skills"
		if(usr.KO) return
		if(world.realtime<next_sd)
			usr<<"You must wait 2 minutes before you can do this again"
			return
		if(usr in All_Entrants)
			usr<<"You can not do this in a tournament"
			return
		switch(input("Self Destruct?") in list("No","Yes"))
			if("Yes") if(!Using)
				if(usr in All_Entrants) return
				if(usr.KO) return
				next_sd=world.realtime+1200
				Using=1
				usr.move=0
				view(10)<<sound('aura3.ogg',volume=30)
				view(12)<<"A huge explosion eminates from [usr] ([usr.key]) and surrounds the area!"
				view(10)<<sound('basicbeam_fire.ogg',volume=20)
				Make_Shockwave(usr,10)
				var/Dist=10
				for(var/N=0,N<5,N++) for(var/turf/T in view(Dist)) if(T.opacity&&T.Health<usr.BP)
					T.Health=0
					T.Destroy()
				for(var/turf/T in view(Dist))
					for(var/obj/O in T) if(O.Health<=usr.BP)
						new/obj/BigCrater(O.loc)
						del(O)
					for(var/mob/P in T) if(P!=usr)
						var/Damage=150*((usr.Pow/P.Res)**0.5)*(usr.BP/P.BP)
						if(usr.Regenerate) Damage/=3
						P.Health-=Damage
						if(P.Health<=0)
							if(P.Regenerate&&!P.KO&&usr.BP>P.BP*P.Regenerate) spawn P.Death(usr,1)
							else spawn P.Death(usr)
					if(T.Health<usr.BP)
						T.Health=0
						T.Destroy()
					var/Timer=rand(50,100)
					T.Self_Destruct_Lightning(Timer)
					spawn(Timer) Dust(T,1)
					if(prob(5)) sleep(1)
				if(prob(80)) spawn if(usr) usr.Death(usr)
				usr.Ki=0
				usr.move=1
				Using=0
obj/Kaio_Revive
	name="Revive"
	Skill=1
	Cost_To_Learn=40
	desc="This will bring someone back to life. You cannot use it more than once every year."
	teachable=1
	Teach_Timer=20
	var/Last_Use=0
	clonable=0
	New() if(!Last_Use) Last_Use=Year
	verb/Revive()
		set category="Skills"
		if(usr.Android)
			usr<<"Androids cannot use natural-only abilities"
			return
		if(usr.Dead)
			usr<<"You cannot use this if you are dead."
			return
		for(var/mob/A in get_step(usr,usr.dir)) if(A.client&&A.Dead)
			if(usr.client.address==A.client.address)
				usr<<"You can not revive alts"
				return
			if(Year<Last_Use+2)
				switch(alert("You can not use this til year [Last_Use+2]. Unless you sacrifice your own life. Proceed?",\
				"Options","No","Yes"))
					if("No") return
					if("Yes")
						usr.Dead=1
						usr.overlays-='Halo.dmi'
						usr.overlays+='Halo.dmi'
			view(usr)<<"[A] is revived by [usr]"
			Last_Use=Year
			A.Revive()
			switch(alert(A,"Do you want sent to your spawn?","Options","Yes","No"))
				if("Yes")
					view(A)<<"[A] was returned to their home"
					A.Respawn()
			break
obj/Heal
	teachable=1
	Skill=1
	Cost_To_Learn=5
	Teach_Timer=4
	var/Next_Injury_Heal=0
	desc="You can heal anyone in front of you by giving up some of your own health and energy. If they \
	have certain status problems they can be further alleviated by healing them, with multiple heals \
	they may be cured."
	verb/Heal()
		set category="Skills"
		if(usr.Android)
			usr<<"Androids cannot use natural-only abilities"
			return
		if(usr.KO||usr.Ki<usr.Max_Ki/usr.Eff) return
		for(var/mob/A in get_step(usr,usr.dir))
			if(!A.client) return
			var/Health_Drain=50
			var/Ki_Drain=usr.Max_Ki/usr.Eff
			if(usr.Race=="Puranto") Ki_Drain/=2
			usr.Health-=Health_Drain
			usr.Ki-=usr.Max_Ki/usr.Eff
			Skill_Increase(10,usr)
			A.Full_Heal()
			if(A.Diarea) A.Diarea-=1
			if(A.Zombie_Virus) A.Zombie_Virus-=10
			view(usr)<<"<font color=#FFFF00>[usr] heals [A]"
			if(Next_Injury_Heal<=Year) for(var/obj/Injuries/I in A)
				Next_Injury_Heal=Year+1
				view(usr)<<"[A]'s [I] injury disappears"
				del(I)
				A.Add_Injury_Overlays()
				break
			break
mob/var/UP
obj/Unlock_Potential
	teachable=1
	Skill=1
	Teach_Timer=30
	Cost_To_Learn=30
	var/Usable=0 //The year you may next use this.
	desc="Using this on someone will greatly increase their power and energy. Each use will add 5 years \
	to how long you must wait to use it on someone again."
	verb/Unlock_Potential(mob/A in view(1))
		set category="Skills"
		if(usr.Android)
			usr<<"Androids cannot use natural-only abilities"
			return
		if(A.Android)
			usr<<"Androids can not have their potential unlocked"
			return
		if(!A.client) return
		/*if(Year<Usable)
			usr<<"You cannot use this til year [Usable]"
			return*/
		Usable+=5
		if(Year<A.UP)
			usr<<"Their potential can not be unlocked again until year [A.UP]"
			return
		switch(input(A,"[usr] wants to unlock your hidden powers") in list("No","Yes"))
			if("Yes")
				if(Year<A.UP) return
				view(usr)<<"[usr] uses unlock potential on [A]"
				A.UP=Year+5
				A.Leech(usr,1000/A.Leech_Rate)
				var/mob/m=pick(Players)
				if(m&&ismob(m))
					A.Leech(m,800/A.Leech_Rate)
					if(A.Is_Admin()) A<<"admin message: your random UP leech came from [m]"
			if("No") if(usr) usr<<"[A] declined your offer."
obj/Taiyoken
	teachable=1
	Skill=1
	Cost_To_Learn=2
	Teach_Timer=0.5
	desc="Taiyoken, also known as Solar Flare, blinds an opponent for a limited amount of time. \
	The amount of time the person is blinded depends on their regeneration. It is mainly used so \
	that they dont see what direction you went in, and so that they cant pursue you until they can \
	see again. If they aren't looking directly at you, they will not be blinded."
	verb/Taiyoken()
		set category="Skills"
		if(!usr.attacking)
			usr.attacking=3
			usr.Ki*=0.5
			var/distance=round(usr.Ki*0.01)
			if(distance>15) distance=15
			if(distance<1) distance=1
			for(var/turf/A in view(distance,usr)) A.Self_Destruct_Lightning(4)
			sleep(10)
			for(var/turf/A in view(distance,usr)) A.Self_Destruct_Lightning(5)
			sleep(5)
			for(var/mob/A in oview(distance,usr))
				if(get_dir(A,usr) in list(A.dir,turn(A.dir,45),turn(A.dir,-45)))
					A<<"You are blinded by [usr]'s Taiyoken"
					A.sight=1
				else A<<"You were not looking directly at [usr]'s Taiyoken, so you were not blinded"
			sleep(50*usr.Speed_Ratio())
			usr.attacking=0
obj/Rift_Teleport/verb/Rift_Teleport()
	set category="Skills"
	var/image/I=image(icon='Black Hole.dmi',icon_state="full")
	switch(input("Person or Location?") in list("Person","Location",))
		if("Location")
			var/xx=input("X Location?") as num
			var/yy=input("Y Location?") as num
			var/zz=input("Z Location?") as num
			oview(usr)<<"[usr] disappears into a mysterious rift that disappears after they enter."
			spawn flick(I,usr)
			sleep(10)
			usr.loc=locate(xx,yy,zz)
			oview(usr)<<"[usr] appears out of a rift in time-space."
		else
			var/list/A=new
			for(var/mob/M in Players) if(M.client) A.Add(M)
			var/Choice=input("Who?") in A
			oview(usr)<<"[usr] disappears into a mysterious rift that disappears after they enter."
			spawn flick(I,usr)
			sleep(10)
			for(var/mob/M in A) if(M==Choice) usr.loc=locate(M.x+rand(-1,1),M.y+rand(-1,1),M.z)
			oview(usr)<<"[usr] appears out of a rift in time-space."
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
mob/var/Precognition //for the blast avoidance...
mob/proc/Observe_List()
	var/list/L=new
	for(var/mob/A in Players) L+=A
	for(var/obj/A in view(40,src)) L+=A
	for(var/mob/A in view(10,src)) L+=A
	for(var/turf/A in view(10,src)) L+=A
	return L
obj/Observe
	teachable=1
	Skill=1
	Cost_To_Learn=1
	Teach_Timer=0.6
	verb/Observe(atom/A in usr.Observe_List())
		set src=usr.contents
		set category="Skills"
		if(ismob(A))
			var/mob/m=A
			if(m.hiding_energy&&m!=usr)
				usr<<"You can not observe them because they are hiding their energy"
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
	Cost_To_Learn=6
	Teach_Timer=10
	Mastery=100
	desc="This ability lets you create weighted clothes to accelerate training and also create swords. \
	Your energy mod will improve the quality of weights you make."
	var
		weight_tier=1 //can go as high as someone wants
	verb/Materialize()
		set category="Skills"
		var/max_weight=(usr.max_weight()/4)*weight_tier*(usr.Eff**0.3)*1.1
		switch(input("") in list("Make Weights","Make Sword","learn new weight tier"))
			if("learn new weight tier")
				while(usr)
					if(usr.Experience<Cost_To_Learn)
						usr<<"You need at least [Cost_To_Learn] skill points to do this"
						return
					switch(alert(usr,"increase the tier of weights you can make? this will cost [Cost_To_Learn] \
					skill points","options","yes","no"))
						if("no") return
						if("yes")
							if(usr.Experience<Cost_To_Learn) return
							usr.Experience-=Cost_To_Learn
							weight_tier+=0.5
			if("Make Weights")
				var/obj/items/Weights/A=new(get_step(usr,usr.dir))
				A.weight=max_weight
				A.weight_name()
				switch(input("Choose a style") in list("Cape","Shirt","Wristbands","Scarf","Turban"))
					if("Cape") if(A) A.icon='Clothes_Cape.dmi'
					if("Shirt") if(A) A.icon='Clothes_ShortSleeveShirt.dmi'
					if("Wristbands") if(A) A.icon='Clothes_Wristband.dmi'
					if("Scarf") if(A) A.icon='Clothes_NamekianScarf.dmi'
					if("Turban") if(A) A.icon='Clothes_Turban.dmi'
				var/RGB=input("") as color|null
				if(RGB&&A) A.icon+=RGB
			if("Make Sword")
				var/list/Swords=new
				for(var/A in typesof(/obj/items/Sword)) Swords+=new A
				var/obj/items/Sword/A=input("What kind of sword?") in Swords
				A.loc=get_step(usr,usr.dir)
				Swords=null
mob/var
	ismajin
	ismystic
obj/Mystic
	teachable=1
	Skill=1
	Teach_Timer=20
	var/Last_Use=0
	desc="\
	Mystic:<br>\
	x2 recovery<br>\
	x1.3 speed<br>\
	/2 regeneration<br>\
	The main advantage of this is the ability to power up much faster and higher. Mystic disables anger. \
	Drain from omega yasai forms will stop when using them with mystic and you will have all the power \
	of omega yasai channeled into your base form.\
	"
	verb/Mystic()
		set category="Skills"
		if(usr.Redoing_Stats)
			usr<<"You can not use this while choosing stat mods"
			return
		if(usr.ismajin)
			usr<<"You cant use this with Majin"
			return
		if(usr.ssj==3)
			usr<<"<font color=teal>This cannot be used with Omega Yasai 3."
			return
		if(!usr.ismystic)
			Last_Use=Year
			usr.ismystic=1
			usr.Regeneration/=2
			usr.Recovery*=2
			usr.Spd*=1.3
			usr.SpdMod*=1.3
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
		else
			if(Last_Use>Year-0.2)
				usr<<"You can not revert from Mystic until year [Last_Use+1]"
				return
			usr.Mystic_Revert()
mob/proc/Mystic_Revert() if(ismystic)
	ismystic=0
	Regeneration*=2
	Recovery/=2
	Spd/=1.3
	SpdMod/=1.3
obj/Majin
	desc="Majin<br>+20% Battle Power<br>+20% Durability<br>+20% Offense<br>+10 Decline<br>-20% Anger<br>Half Recovery"
	icon='Electric_Majin.dmi'
	teachable=1
	Skill=1
	Teach_Timer=10
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
				usr.BP_Multiplier*=1.2
				usr.Max_Anger/=1.2
				usr.Off*=1.2
				usr.OffMod*=1.2
				usr.End*=1.2
				usr.EndMod*=1.2
				usr.Def*=0.5
				usr.DefMod*=0.5
				usr.Regeneration*=0.5
				usr.Recovery*=0.5
				usr.Original_Decline+=10
				usr.Decline+=10
				usr.overlays-='SSj Aura.dmi'
				usr.overlays-='Elec.dmi'
				usr.overlays-='Electric_Blue.dmi'
				usr.overlays+=icon
			else usr.Majin_Revert()
			sleep(20)
			usr.attacking=0
mob/proc/Majin_Revert() if(ismajin)
	for(var/obj/Majin/M in src)
		BP_Multiplier/=1.2
		Max_Anger*=1.2
		Off/=1.2
		OffMod/=1.2
		End/=1.2
		EndMod/=1.2
		Def*=2
		DefMod*=2
		Regeneration*=2
		Recovery*=2
		Original_Decline-=10
		Decline-=10
		overlays-=M.icon
		ismajin=0
		Revert()
		break
mob/var/Restore_Youth=0 //How many times you have had youth restored
obj/Restore_Youth
	teachable=1
	Skill=1
	Cost_To_Learn=40
	Teach_Timer=30
	clonable=0
	desc="You can use this to make someone younger. Each time they get this done they get less and less from it."
	var/Next_Use=0
	verb/Restore_Youth()
		set category="Skills"
		if(usr.Android)
			usr<<"Androids cannot use natural-only abilities"
			return
		if(Year<Next_Use)
			usr<<"You can not use this til year [Next_Use]"
			return
		var/list/L=list(usr)
		for(var/mob/M in get_step(usr,usr.dir)) if(M.client) L+=M
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
			M.Age-=M.Age/(M.Restore_Youth+1)
			if(M.Age<10) M.Age=10
			view(M)<<"[usr] brings [M]'s age from [round(Previous_Age,0.1)] to [round(M.Age,0.1)] years old"
			M.Restore_Youth++
obj/Sacred_Water
	icon='props.dmi'
	icon_state="Closed"
	desc="This will temporarily raise your health and energy beyond normal levels, and give you a small \
	permanent skill boost if your skill is below a certain level."
	density=1
	Savable=0
	var/tmp/Usable=1
	Spawn_Timer=180000
	verb/Drink()
		set category="Other"
		set src in oview(1)
		if(!Usable)
			usr<<"This can only be used every 1 minute"
			return
		if(usr.KO) return
		if(icon_state!="Open")
			icon_state="Open"
			spawn(600) icon_state="Closed"
		view(usr)<<"[usr] drinks from the sacred water jar"
		Usable=0
		spawn(600) Usable=1
		if(usr.Health<150) usr.Health=150
		if(usr.Ki<usr.Max_Ki*1.5) usr.Ki=usr.Max_Ki*1.5
obj/RankChat
	verb/RankChat(A as text)
		set category="Other"
		for(var/mob/B in Players) if(locate(/obj/RankChat) in B)
			B<<"<font size=[B.TextSize]>(Rank)<font color=[usr.TextColor]>[usr.name]: [html_encode(A)]"
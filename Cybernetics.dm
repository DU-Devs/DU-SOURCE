/*
if you order drones to assemble they should automatically be able to get aboard the ship your on or  the cave
your in by reading to gotoz var to see if it matches yours.

drones kill enemy drones

Cybernetic Computer should also be programmable to produce drones, to a maximum of 100 active at once, and builds
more if it falls below that. It builds them based on Blueprints. Its like a Drone Factory.
drones
	a replicate module so they build others of themselves or something like nano machines
drones / henchmen
A way to make a nano-plague type thing
*/
mob/proc/Firewall(mob/P)
	for(var/obj/Module/Firewall/F in src) if(F.suffix)
		P.Health-=50
		P.loc=loc
		Make_Shockwave(src,10)
		view(src)<<"[P] tried to jump into [src]'s body, but they are repelled and take damage from the firewall!"
		P.Shockwave_Knockback(5,loc)
		return 1
obj/Body_Swap
	Givable=1
	desc="Allows you to jump into another person's body, like Bebi. They must be below 100% health for you to jump \
	into their body, because there must be a cut that you can jump into."
	var/Undo_Body_Swap
	verb/Body_Swap()
		set category="Skills"
		if(Undo_Body_Swap)
			usr.Bebi_Undo()
			return
		if((usr in All_Entrants)&&usr.z==7)
			usr<<"You can not do this in a tournament"
			return
		var/mob/P
		for(var/mob/M in get_step(usr,usr.dir)) if(M!=usr) P=M
		if(!P)
			usr<<"You must be next to the target to jump into their body, and facing themt"
			return
		if(!P.client)
			usr<<"You can only body swap into players"
			return
		if(P.Safezone())
			usr<<"They are in a safezone you can not body swap them"
			return
		if(P.Health>50)
			usr<<"[P] must have less than 50% health for you to steal their body"
			return
		if(ismob(usr.loc))
			usr<<"You can not jump into more than 1 person at a time"
			return
		if(!P||P=="Cancel") return
		view(usr)<<"[usr] tries to jump into [P]'s body!"
		var/mob/O=P.Duplicate()
		var/obj/Body_Swap/B=new
		B.Undo_Body_Swap=1
		O.contents+=B
		O.contents+=usr
		if(!P||!usr||P.Firewall(usr))
			if(usr) usr.Get_Observe(usr)
			if(O) del(O)
			return
		usr.Get_Observe(O)
		P.Get_Observe(O)
		usr.Attack_Gain(500,P)
		O.displaykey=usr.displaykey
		O.loc=P.loc
		O.contents+=P
		P.Empty_Body=1 //So they stay in O's contents even if they log out
		spawn if(O) O.Old_Trans_Graphics()
		O.overlays-=O.hair
		O.hair+=rgb(100,100,100)
		O.overlays+=O.hair
		O.overlays+='Bebi Markings.dmi'
		O.Cyber_Power=usr.Cyber_Power

		P.Alter_Res(-P.Res())
		for(var/obj/items/I in P) del(I)

		Switch_Bodies(usr,O)
mob/proc/body_swapped()
	for(var/obj/Body_Swap/B in src) if(B.Undo_Body_Swap) return 1
mob/proc/Bebi_Undo(Logging_Out) //Undoes the effects of Bebi taking over someone's body
	for(var/mob/P in src) if(P.displaykey!=displaykey)
		P.Empty_Body=0
		P.loc=loc
		P.Get_Observe(P)
		P.Alter_Res(Res())
		for(var/obj/items/I in src) P.contents+=I
		P.Save()
	for(var/mob/P in src) if(P.displaykey==displaykey)
		P.Empty_Body=0
		P.loc=loc
		P.Get_Observe(P)
		Switch_Bodies(src,P)
		P.Save()
		if(Logging_Out) del(P)
		del(src)
mob/var/Android
mob/var/Cyber_Scanner=0
mob/var/Cyber_Force_Field=0
mob/var/Blast_Absorb=0
obj/Module
	icon='Modules.dmi'
	icon_state="2"
	var/Requires_Password
	BP_Scanner
		Cost=100000
		desc="An integrated BP Scanner that can scan infinite amounts of BP."
		Scanner=1
	Giant_Version
		Cost=100000
		Android_Only=1
		desc="Scale up the design of your body, which will have x1.5 strength and durability, but /2 offense and \
		/2 defense."
		Giant=1;Strx=1.5;Endx=1.5;Offx=0.5;Defx=0.5
	Body_Swap
		Cost=10000000
		Android_Only=1
		desc="This gives you the ability that Bebi had, to jump into other people's bodies."
		Icon_Change='Bio Experiment.dmi';BPx=0.5
		Abilities=list(new/obj/Body_Swap)
	Firewall
		Cost=10000000
		desc="This provides protection against Body Swaps, if you have this installed and someone tries to jump into \
		your body, they will be repelled and take damage."
	Scrap_Repair
		Cost=10000000
		Android_Only=1
		desc="This is the Majin/Bio-Android death regeneration alternative for Androids. If you are destroyed, your \
		body will self-repair itself minutes later from the scraps. If the scraps are destroyed, you will not \
		self-repair."
		Regenerate_Add=4
	Scrap_Absorb
		Cost=10000000
		Android_Only=1
		desc="This is an ability like Android 13 had. The ability to absorb the scraps of destroyed Androids to \
		increase your own power."
		Abilities=list(new/obj/Scrap_Absorb)
	Breath_In_Space
		Cost=100000
		desc="You will be able to breath in space with this module installed."
		Lungs=1
	Decline_Increase
		Cost=1000000
		desc="This will add 50 years to your life span."
		Life_Add=50
	Drone_AI
		var/list/Commands=new
		Cost=400000000
		Requires_Password=1
		desc="Installing this on an Android/Cyborg will allow you to command them to do certain things. You must \
		set a frequency on it before it can be used. You can then command \
		your drones by having your Robotics Tools set to the same frequency as the Drone AI Module that the Drone has \
		installed. Robotics Tools are gotten from the Science tab."
		verb/Set() if(src in usr)
			if(Password) switch(input("The drone password is already set to [Password]. Do you really want to \
			change it?") in list("No","Yes"))
				if("No") return
			Password=input("Set the frequency for the [src] Module.") as text
		New() spawn(100) if(src) for(var/mob/P) if(src in P) P.Drone_Initialize()
	Antigravity
		Cost=100000
		desc="An Android method of flying, it takes absolutely no energy. It will replace natural flight."
		Cyber_Fly=1
	Force_Field
		name="Force Field Module"
		Cost=1000000
		desc="A force field that activates on it's own when a blast hits you. It will drain energy."
		Cyber_Force_Field=1
	Manual_Absorb
		Cost=1000000
		desc="This will give you the ability to absorb people to increase your own power"
		Abilities=list(new/obj/Absorb)
	Blast_Absorb
		Cost=5000000
		desc="This allows you to absorb blasts, but only if they come at you from the front or front-sides. \
		Absorbing blasts increases your energy. Remember, you can only hold a maximum of 200% energy, after that \
		you will take damage."
		Blast_Absorb=1
	Rebuild
		Cost=1000000
		Android_Only=1
		Requires_Password=1
		desc="If you are somehow killed, you will be rebuilt by the central computer you are linked to. Right click \
		this and use the Set verb to set this module's frequency to the central computer's frequency that you want \
		to repair you. If unset, this module will do nothing."
		verb/Set() if(src in usr)
			if(Password) switch(input("The Rebuild Frequency is already set to [Password]. Do you really want to \
			change it?") in list("No","Yes"))
				if("No") return
			Password=input("Set the frequency for the [src] Module. You must make the frequency the same as a main \
			computer if you want the computer to rebuild the android if it dies.") as text
	Generator
		Cost=100000
		desc="This will x2 your energy, but /2 your recovery."
		Kix=2;Recx=0.5
	Overdrive
		Cost=1000000
		Abilities=list(new/obj/Overdrive)
		desc="Using this will give you the option to go past your recommended limits, increasing your cybernetic \
		BP temporarily. The downside is that it slowly damages you til you turn it back off."
	Auto_Repair
		Cost=1000000
		desc="When you are damaged, nanites will begin repairing you, at the cost of some energy."
		Nanite_Repair=1
	Brute
		Cost=100000
		desc="x1.3 strength, /2 regeneration and recovery."
		Strx=1.3;Regx=0.5;Recx=0.5
	Armor
		name="Cybernetic Armor"
		Cost=100000
		desc="x1.3 durability, /2 regeneration and recovery."
		Icon_Change='AndroidProxy.dmi';Endx=1.3;Regx=0.5;Recx=0.5
	Cyber_Charge
		Cost=100000
		desc="A cybernetic energy attack designed to mimic Charge, but supposedly better. Like all cybernetic \
		abilities, it does not require mastery."
		Abilities=list(new/obj/Attacks/Cyber_Charge)
	Laser_Beam
		Cost=100000
		desc="A cybernetic energy attack designed to mimic Beam."
		Abilities=list(new/obj/Attacks/Laser_Beam)
	var/list/Abilities=new;var/Android_Only
	var/BPx=0.9;var/Kix=1;var/Strx=1;var/Endx=1;var/Powx=1;var/Resx=1;var/Spdx=1;var/Offx=1;var/Defx=1;var/Regx=1
	var/Recx=1;var/Life_Add=0;var/Leechx=1;var/Regenerate_Add=0;var/Lungs=0;var/CP_Mult=0.1;var/Cyber_Fly=0
	var/Nanite_Repair=0;var/Icon_Change;var/Giant;var/Scanner=0;var/Cyber_Force_Field=0;var/Blast_Absorb=0
	proc/Enable_Module(mob/P)
		if(suffix) return
		P.BP_Multiplier*=BPx;P.Max_Ki*=Kix;P.Eff*=Kix;P.Ki*=Kix;P.Str*=Strx;P.StrMod*=Strx;P.End*=Endx
		P.EndMod*=Endx;P.Pow*=Powx;P.PowMod*=Powx;P.Res*=Resx;P.ResMod*=Resx;P.Spd*=Spdx;P.SpdMod*=Spdx
		P.Off*=Offx;P.OffMod*=Offx;P.Def*=Defx;P.DefMod*=Defx;P.Regeneration*=Regx;P.Recovery*=Recx
		P.Decline+=Life_Add;P.Leech_Rate*=Leechx;P.Regenerate+=Regenerate_Add;P.Lungs+=Lungs;P.Cyber_Fly+=Cyber_Fly
		P.Nanite_Repair+=Nanite_Repair;P.Cyber_Scanner+=Scanner;P.Cyber_Force_Field+=Cyber_Force_Field;\
		P.Blast_Absorb+=Blast_Absorb
		if(Icon_Change&&P.Android)
			P.icon=Icon_Change
			P.overlays-=P.overlays
			for(var/obj/Module/M in P) if(M.suffix&&M.Giant) P.Enlarge_Icon(64,64)
		if(Giant) P.Enlarge_Icon(64,64)
		var/CP_Add=P.Knowledge*2
		if(P.Cyber_Power<CP_Add)
			P.Cyber_Power+=CP_Add*CP_Mult*cyber_bp_mod
			if(P.Cyber_Power>CP_Add) P.Cyber_Power=CP_Add
		suffix="Installed"
		for(var/obj/O in Abilities) P.contents+=O
	proc/Disable_Module(mob/P)
		P.BP_Multiplier/=BPx;P.Max_Ki/=Kix;P.Eff/=Kix;P.Ki/=Kix;P.Str/=Strx;P.StrMod/=Strx;P.End/=Endx
		P.EndMod/=Endx;P.Pow/=Powx;P.PowMod/=Powx;P.Res/=Resx;P.ResMod/=Resx;P.Spd/=Spdx;P.SpdMod/=Spdx
		P.Off/=Offx;P.OffMod/=Offx;P.Def/=Defx;P.DefMod/=Defx;P.Regeneration/=Regx;P.Recovery/=Recx
		P.Decline-=Life_Add;P.Leech_Rate/=Leechx;P.Regenerate-=Regenerate_Add;P.Lungs-=Lungs;P.Cyber_Fly-=Cyber_Fly
		P.Nanite_Repair-=Nanite_Repair;P.Cyber_Scanner-=Scanner;P.Cyber_Force_Field-=Cyber_Force_Field;\
		P.Blast_Absorb-=Blast_Absorb
		if(Giant) P.Enlarge_Icon(32,32)
		P.Cyber_Power-=P.Knowledge*2*CP_Mult*cyber_bp_mod
		if(P.Cyber_Power<0) P.Cyber_Power=0
		suffix=null
		for(var/obj/O in Abilities) P.contents-=O
	Click() if(src in usr)
		if(!suffix)
			switch(input("[src]: Choose what you want to do with this module.") in list("Cancel","Install"))
				if("Cancel") return
				if("Install")
					if(Requires_Password&&!Password)
						usr<<"You can not install this module until you activate it. Do so by right clicking \
						it and exploring it's commands."
						return
					var/list/Mobs=list("Cancel")
					for(var/mob/P in get_step(usr,usr.dir)) Mobs+=P
					Mobs+=usr
					var/mob/P=input("Install [src] on who?") in Mobs
					if(!P||P=="Cancel") return
					for(var/obj/Module/M in P) if(M!=src&&M.type==type&&M.suffix)
						usr<<"[P] already has one installed. No more can be installed"
						return
					if(Android_Only&&!P.Android)
						usr<<"Installation failed. [src] can only be installed on 100% non-organic \
						Androids. [P] is either a Cyborg or 100% Organic."
						return
					if(P.client&&P!=usr&&!P.KO) switch(input(P,"[usr] wants to install a cybernetic module \
					on you: [src]. Allow?") in list("No","Yes"))
						if("No")
							if(usr) usr<<"[P] will not allow you to install [src]"
							return
					if(!P) return
					view(usr)<<"[usr] installs [src] (Cybernetic Module) on [P]"
					Enable_Module(P)
					P.contents+=src
	verb/Drop()
		var/mob/P
		for(P in get_step(usr,usr.dir)) break
		if(P&&!P.client) P=null
		if(suffix)
			usr<<"You can not drop this while it is installed in your body"
			return
		for(var/mob/A in view(usr)) if(A.see_invisible>=usr.invisibility)
			if(!P) A<<"[usr] drops [src]"
			else A<<"[usr] gives [P] a [src]"
		loc=usr.loc
		step(src,usr.dir)
		dir=SOUTH
		if(P) P.contents+=src
	Del()
		if(suffix)
			var/mob/M=loc
			if(ismob(M)) Disable_Module(M)
		..()
mob/var/Cyber_Power=0
mob/var/Record_Cyber_Power=0
mob/proc/Cyber_Power_Loop() while(src)

	return

	if(Record_Cyber_Power<Cyber_Power) Record_Cyber_Power=Cyber_Power
	var/Hours=6
	if(Android) Hours*=2
	if(Cyber_Power)
		Cyber_Power-=Record_Cyber_Power/(60*Hours)
		if(Cyber_Power<0)
			Cyber_Power=0
			Record_Cyber_Power=0
	sleep(600)
mob/proc/Is_Cybernetic()
	if(Android||Cyber_Power) return 1
	for(var/obj/Module/M in src) if(M.suffix) return 1
mob/var/Nanite_Repair
obj/Cybernetics_Computer
	icon='Lab.dmi'
	icon_state="Lab2"
	Makeable=1
	density=1
	Cost=1000000
	var/list/Kill_List=new
	var/list/Stored_Blueprints=list("Cancel")
	var/list/Illegals=new
	desc="This computer will rebuild cyborgs/androids who have died and were linked to this computer. \
	And allows you to command Drones."
	verb/Use()
		set src in oview(1,usr)
		if(usr in view(1,src))
			switch(input("[src]") in list("Cancel","Repair Android/Cyborg","Command Drones","Set Frequency",\
			"Make blank android body"))
				if("Cancel") return
				if("Make blank android body")
					var/mob/P=new
					P.name="Android"
					P.icon='Android.dmi'
					P.Android()
					P.contents+=new/obj/Resources
					P.Savable=1
					P.Savable_NPC=1
					P.TechTab=1
					P.TextColor=usr.TextColor
					P.Class="Custom Built"
					P.loc=loc
					P.dir=SOUTH
					P.Android_Starting_Stats()
					P.Random_Colors()
					for(var/obj/O in P) O.Mastery=1000
				if("Command Drones") usr.Drone_Options(src)
				if("Repair Android/Cyborg")
					if(!usr.Is_Cybernetic())
						usr<<"Only Androids and Cyborgs can be repaired"
						return
					var/Timer=30
					if(usr.Android) Timer*=0.5
					view(usr)<<"[src]: Repairing [usr]. If you move in less than [Timer] seconds, repairs will be cancelled"
					var/Loc1=usr.loc
					while(usr&&Timer>0&&Loc1==usr.loc)
						Timer-=0.1
						sleep(1)
					if(!usr) return
					if(Timer>0)
						view(usr)<<"[src]: Repair of [usr] cancelled"
						return
					view(usr)<<"[src]: [usr] successfully repaired"
					if(usr.Health<100) usr.Health=100
					if(usr.Ki<usr.Max_Ki) usr.Ki=usr.Max_Ki
					for(var/obj/Injuries/I in usr)
						usr<<"Your [I] injury has been repaired"
						del(I)
						usr.Add_Injury_Overlays()
				if("Set Frequency")
					switch(input("You are about to reset the [src] frequency. The [src] frequency is a \
					frequency that cyborgs can be linked to using a Rebuild Module or Drone AI module, and perhaps other \
					modules (all of which must be installed in them). If their \
					module frequencies matches the frequency of the [src], and they are destroyed, this [src] will \
					rebuild them here if they have a rebuild module, and if they have a drone AI module you can send \
					orders to them from the [src], because their frequencies were linked.") in list("No","Yes"))
						if("No") return
						if("Yes")
							view(src)<<"[src]: [usr] is resetting the rebuild frequency."
							Password=input("Set a frequency for the [src]. This will allow it to track Cyborgs who have a Rebuild \
							Module installed on them which has the same frequency. So if that cyborg dies, this computer will rebuild \
							them here.") as text
mob/proc/Choose_Mob(T="Choose someone",list/L)
	if(!L) L=Players
	var/mob/P=input(src,T) in L
	if(P) return P
obj/Genetics_Computer
	icon='Lab.dmi'
	icon_state="Lab1"
	Makeable=1
	density=1
	Cost=10000000
	desc="This computer can accept DNA samples and do things with them, such as create a clone, or do a brain \
	transplant to put your brain into another body."
	verb/Use()
		set src in oview(1,usr)
		if(usr in view(1,src))
			switch(input("[src]: What do you want to do?") in list("Cancel","Make Clone",\
			"Brain Transplant","Lower Stat","Battle Power Imprint","Stat Imprint","Knowledge Imprint"))
				if("Cancel") return
				if("Lower Stat")
					if(Stat_Settings["Rearrange"])
						usr<<"This doesn't work when admins have stat gains set to re-arrange mode"
						return
					var/list/L=list("Cancel")
					for(var/mob/P in view(1,src)) if(P.KO||!P.client||P==usr) L+=P
					var/mob/P=usr.Choose_Mob("Choose who's stats you will lower. If it is a player they must be knocked \
					out for you to change their stats against their will. You can change the stats of anyone within \
					1 tile of the [src]",L)
					if(!P||P=="Cancel") return
					while(usr)
						var/Tag
						switch(input("Which of your stats do you want to lower?") in list("Cancel","Strength","Durability",\
						"Speed","Force","Resistance","Offense","Defense"))
							if("Cancel") return
							if("Strength") Tag="Str"
							if("Durability") Tag="End"
							if("Speed") Tag="Spd"
							if("Force") Tag="Pow"
							if("Resistance") Tag="Res"
							if("Offense") Tag="Off"
							if("Defense") Tag="Def"
						var/N=input("What do you want to lower it to? The amount must be less than what [P] currently has \
						in the stat, which is [Commas(P.vars[Tag])]") as num
						if(N<1) N=1
						if(N>P.vars[Tag])
							usr<<"The amount must be less than what [P] currently has in the stat"
							return
						view(src)<<"[usr] uses genetics to lower one of [P]'s stats from [P.vars[Tag]] to [N]"
						P.vars[Tag]=N
				if("Knowledge Imprint")
					var/Res_Cost=10000000/usr.Intelligence
					if(usr.Res()<Res_Cost)
						usr<<"You need [Commas(Res_Cost)]$ to do this"
						return
					var/list/DNA=list("Cancel")
					for(var/obj/items/DNA_Container/D in usr) if(D.Clone) DNA+=D
					if(!(locate(/obj) in DNA))
						usr<<"You can not do this because you must have a DNA container with someone's DNA in it."
						return
					var/obj/items/DNA_Container/D=input("Which DNA do you want to use for the BP imprint?") in DNA
					if(!D||D=="Cancel") return
					var/list/Mobs=list("Cancel")
					for(var/mob/P in view(1,src)) Mobs+=P
					if(!(locate(/mob) in Mobs))
						usr<<"You can not do this. There must be a person near the [src] that you can imprint the DNA on"
						return
					var/mob/P=input("Choose the body that you want to imprint [D.Clone]'s DNA on. This will overwrite \
					their knowledge with the knowledge of [D.Clone].") in Mobs
					if(P=="Cancel"||!P) return
					if(P.client&&!P.KO)
						switch(input(P,"[usr] is trying to imprint knowledge on you, accept?") in list("No","Yes"))
							if("No")
								usr<<"[P] has denied the knowledge imprint"
								return
					var/N=D.Clone.Knowledge
					if(P.Knowledge>N)
						view(src)<<"The knowledge imprint on [P] was cancelled because it would actually lower their knowledge to do this"
						return
					view(src)<<"[usr] uses the [D] to overwrite [P]'s knowledge with the knowledge of [D.Clone]"
					if(usr.Res()<Res_Cost)
						usr<<"You need [Commas(Res_Cost)]$ to do this"
						return
					usr.Alter_Res(-Res_Cost)
					P.Knowledge=N
				if("Battle Power Imprint")
					var/Res_Cost=100000000/usr.Intelligence
					if(usr.Res()<Res_Cost)
						usr<<"You need [Commas(Res_Cost)]$ to do this"
						return
					var/list/DNA=list("Cancel")
					for(var/obj/items/DNA_Container/D in usr) if(D.Clone) DNA+=D
					if(!(locate(/obj) in DNA))
						usr<<"You can not do this because you must have a DNA container with someone's DNA in it."
						return
					var/obj/items/DNA_Container/D=input("Which DNA do you want to use for the BP imprint?") in DNA
					if(!D||D=="Cancel") return
					var/list/Mobs=list("Cancel")
					for(var/mob/P in view(1,src)) Mobs+=P
					if(!(locate(/mob) in Mobs))
						usr<<"You can not do this. There must be a person near the [src] that you can imprint the DNA on"
						return
					var/mob/P=input("Choose the body that you want to imprint [D.Clone]'s DNA on. This will overwrite \
					their BP with the BP of [D.Clone].") in Mobs
					if(P=="Cancel"||!P) return
					if(P.client&&!P.KO)
						switch(input(P,"[usr] is trying to imprint BP on you, accept?") in list("No","Yes"))
							if("No")
								usr<<"[P] has denied the BP imprint"
								return
					var/N=(D.Clone.Base_BP/D.Clone.BP_Mod)*P.BP_Mod

					var/real_amount=input("You can raise [P]'s bp up to [Commas(N)] but you can give them less if you \
					choose. Input the amount you want to raise them to now. Their current base bp is \
					[Commas(P.Base_BP)].") as num
					if(real_amount<1) real_amount=1
					if(real_amount>N) real_amount=N
					N=real_amount

					if(!P) return
					if(P.Base_BP>N)
						view(src)<<"The BP imprint on [P] was cancelled because it would actually lower their BP to do this"
						return
					view(src)<<"[usr] uses DNA to increase [P]'s power from [Commas(P.Base_BP)] to [Commas(N)]"
					if(usr.Res()<Res_Cost)
						usr<<"You need [Commas(Res_Cost)]$ to do this"
						return
					usr.Alter_Res(-Res_Cost)
					P.Base_BP=N
					P.Gravity_Mastered=D.Clone.Gravity_Mastered
				if("Stat Imprint")
					if(Stat_Settings["Rearrange"])
						usr<<"This is disabled when admins have stat mode set to 'rearrange mode'"
						return
					var/Res_Cost=100000000/usr.Intelligence
					if(usr.Res()<Res_Cost)
						usr<<"You need [Commas(Res_Cost)]$ to do this"
						return
					var/list/DNA=list("Cancel")
					for(var/obj/items/DNA_Container/D in usr) if(D.Clone) DNA+=D
					if(!(locate(/obj) in DNA))
						usr<<"You can not do this because you must have a DNA container with someone's DNA in it."
						return
					var/obj/items/DNA_Container/D=input("Which DNA do you want to use for the stat imprint?") in DNA
					if(!D||D=="Cancel") return
					var/list/Mobs=list("Cancel")
					for(var/mob/P in view(1,src)) Mobs+=P
					if(!(locate(/mob) in Mobs))
						usr<<"You can not do this. There must be a person near the [src] that you can imprint the DNA on"
						return
					var/mob/P=input("Choose the body that you want to imprint [D.Clone]'s DNA on. This will overwrite \
					their stats with the stats of [D.Clone]. Warning: This could lower your overall stats if you use \
					DNA that is weaker than you.") in Mobs
					if(P=="Cancel"||!P) return
					if(P.client&&!P.KO)
						switch(input(P,"[usr] is trying to imprint stats on you, accept?") in list("No","Yes"))
							if("No")
								usr<<"[P] has denied the stat imprint"
								return
					view(src)<<"[usr] uses the [D] to overwrite [P]'s stats with the stats of [D.Clone]"
					if(usr.Res()<Res_Cost)
						usr<<"You need [Commas(Res_Cost)]$ to do this"
						return
					usr.Alter_Res(-Res_Cost)
					P.Max_Ki=(D.Clone.Max_Ki/D.Clone.Eff)*P.Eff
					if(P.Ki>P.Max_Ki) P.Ki=P.Max_Ki
					P.Str=(D.Clone.Str/D.Clone.StrMod)*P.StrMod*(P.Modless_Gain/D.Clone.Modless_Gain)
					P.End=(D.Clone.End/D.Clone.EndMod)*P.EndMod*(P.Modless_Gain/D.Clone.Modless_Gain)
					P.Pow=(D.Clone.Pow/D.Clone.PowMod)*P.PowMod*(P.Modless_Gain/D.Clone.Modless_Gain)
					P.Res=(D.Clone.Res/D.Clone.ResMod)*P.ResMod*(P.Modless_Gain/D.Clone.Modless_Gain)
					P.Spd=(D.Clone.Spd/D.Clone.SpdMod)*P.SpdMod*(P.Modless_Gain/D.Clone.Modless_Gain)
					P.Off=(D.Clone.Off/D.Clone.OffMod)*P.OffMod*(P.Modless_Gain/D.Clone.Modless_Gain)
					P.Def=(D.Clone.Def/D.Clone.DefMod)*P.DefMod*(P.Modless_Gain/D.Clone.Modless_Gain)
				if("Make Clone")
					var/list/Clonables=list("Cancel")
					for(var/obj/items/DNA_Container/D in usr) if(D.Clone) Clonables+=D
					if(!(locate(/obj) in Clonables))
						usr<<"You can not do this because you must have a DNA container with someone's DNA in it."
						return
					var/obj/items/DNA_Container/D=input("What DNA to use to make the clone?") in Clonables
					if(!D||D=="Cancel") return
					var/mob/P=D.Clone.Duplicate()
					P.loc=loc
					view(src)<<"[src]: Clone created using [D]"
				if("Brain Transplant")
					var/list/Mobs=list("Cancel")
					for(var/mob/P in view(1,src)) if(P!=usr) Mobs+=P
					if(!(locate(/mob) in Mobs))
						usr<<"You and someone else must be next to the [src] to do this"
						return
					var/mob/P=input("Choose which body you want to transplant your brain to") in Mobs
					if(!P||P=="Cancel") return
					if(P.client&&P!=usr&&P.KO)
						var/res_cost=10*1000000000/usr.Intelligence
						if(usr.Res()<res_cost)
							usr<<"You need [Commas(res_cost)]$ to do a forced brain transplant"
							return
						usr.Alter_Res(-res_cost)
					if(P.client&&P!=usr&&!P.KO) switch(input(P,"[usr] wants to transplant their brain into your body. \
					You will be placed into their body. Accept?") in list("No","Yes"))
						if("No")
							usr<<"[P] has not allowed the brain transplant"
							return
					view(src)<<"[usr] has transplanted their brain into [P]'s body!"
					Switch_Bodies(usr,P)
proc/Switch_Bodies(mob/A,mob/P)
	if(!A.client) return
	var/Key1=A.key
	var/Key2
	if(P.client) Key2=P.key
	P.Empty_Body=1
	A.Empty_Body=1
	P.Clone=1
	A.Clone=1
	P.Savable_NPC=1
	A.Savable_NPC=1
	Players.Remove(A,P)
	if(!P.client) spawn(10) if(P) P.Player_Loops()
	var/mob/Temp=new
	if(Key2) Temp.key=Key2
	P.key=Key1
	if(Key2) A.key=Key2
	if(P&&P.client)
		P.client.show_verb_panel=1
		P.Empty_Body=0
		P.Clone=0
		P.Savable_NPC=0
		P.Savable=1
		P.Tabs=2
		if(!(P in Players)) Players+=P
		P.Save()
	if(A&&A.client)
		P.client.show_verb_panel=1
		A.Empty_Body=0
		A.Clone=0
		A.Savable_NPC=0
		A.Savable=1
		A.Tabs=2
		if(!(A in Players)) Players+=A
		A.Save()
mob/proc/Android_Starting_Stats()
	if(Max_Ki<500*Eff) Max_Ki=500*Eff
	if(Str<1000*StrMod) Str=1000*StrMod
	if(End<2000*EndMod) End=2000*EndMod
	if(Pow<500*PowMod) Pow=500*PowMod
	if(Res<1000*ResMod) Res=1000*ResMod
	if(Spd<1000*SpdMod) Spd=1000*SpdMod
	if(Off<1000*OffMod) Off=1000*OffMod
	if(Def<500*DefMod) Def=500*DefMod
obj/var/Total_Cost=0 //Cost of the item including upgrades
atom/var/Blueprintable=1
obj/items/Android_Blueprint
	name="Blueprint"
	icon='Modules.dmi'
	desc="This can hold the design schematics for an Android Body or other science items, so that they can \
	be mass produced. Just face the item you want to have blueprinted, or have the item in your contents, and hit \
	the 'Use' verb to assign the item to be blueprinted, once that is done hitting Use \
	any more times will make a new copy of the blueprinted item. Hit the 'Reset' verb to make the blueprint \
	blank again."
	icon_state="1"
	Cost=1000000
	Stealable=1
	var/mob/Body
	verb/Reset()
		Body=null
		name=initial(name)
		usr<<"[src] has been reset. Hit 'Use' to assign another item to be blueprinted"
	verb/Use() if(src in usr)
		if(!Body)
			var/list/L=list("Cancel")
			for(var/mob/P in get_step(usr,usr.dir)) if(P.Android&&!P.client&&P.Blueprintable) L+=P
			for(var/obj/O in get_step(usr,usr.dir)) if(O.Cost&&O.type!=type&&O.Blueprintable) L+=O
			for(var/obj/O in usr) if(O.Cost&&O.type!=type&&O.Blueprintable) L+=O
			var/mob/O=input("Choose the item that will be assigned to this blueprint, so that the item can then \
			be mass produced using this blueprint.") in L
			if(!O||O=="Cancel") return
			name="[O] Blueprint"
			if(isobj(O))
				Save_Obj(O)
				O=new O.type
				Load_Obj(O)
				if(O.suffix=="Equipped"||O.suffix=="Installed") O.suffix=null
				for(var/n in 1 to 5) for(var/V in O) del(V) //people were putting drills and people in pods duplicating the pods to
				//duplicate the drills and people inside the pods to have INF resources.
				//It does more than 1 loop because when a drill it destroyed it drops its resources inside the
				//pod still so 1 loop would still leave those there
				Body=O
			if(ismob(O))
				Body=O.Duplicate()
				Body.Alter_Res(-Body.Res())
		else
			var/turf/T=get_step(usr,usr.dir)
			if(T&&(T.density||(locate(/obj) in T)))
				usr<<"There is already an object occupying this space"
				return
			if(ismob(Body))
				var/Res_Cost=100000
				for(var/obj/Module/M in Body) Res_Cost+=M.Cost
				if(usr.Res()<Res_Cost)
					usr<<"You need [Commas(Res_Cost)]$ to do this"
					return
				usr.Alter_Res(-Res_Cost)
				usr<<"Cost: [Commas(Res_Cost)]$"
				var/mob/P=Body.Duplicate()
				P.loc=get_step(usr,usr.dir)
				P.dir=SOUTH
			if(isobj(Body))
				var/obj/Drill/O=Body
				var/Res_Cost=O.Total_Cost+O.Cost
				if(usr.Res()<Res_Cost)
					usr<<"You need [Commas(Res_Cost)]$ to do this"
					return
				usr.Alter_Res(-Res_Cost)
				usr<<"Cost: [Commas(Res_Cost)]$"
				Save_Obj(O)
				O=new O.type
				Load_Obj(O)
				if(istype(O,/obj/Drill)) O.Resources=0
				O.loc=get_step(usr,usr.dir)
				O.dir=NORTH
proc/Save_Obj(obj/O) if(O)
	var/savefile/F=new("Blueprint")
	O.Write(F)
	if(F["key"]) F["key"]<<null
proc/Load_Obj(obj/O) if(O)
	var/savefile/F=new("Blueprint")
	O.Read(F)
obj/items/Robotics_Tools
	desc="This is used to increase the cybernetic BP of a cyborg. If they are not already a cyborg, this will make \
	them into one. There are disadvantages to having cybernetic BP, such as inability to ascend, slower training, \
	and inability to turn Omega Yasai. All of the negative effects will go away when your cybernetic BP \
	wears off."
	Cost=100000
	Stealable=1
	Makeable=1
	Givable=1
	icon='PDA.dmi'
	var/Upgrade_Power=1 //Can be edited by admins to create better cyborgs.
	Level=0
	verb/Use() if(src in usr)
		var/list/Options=list("Cancel","Upgrade","Uninstall Modules","Redo Stats",\
		"Repair Android/Cyborg","Mind Transfer","Command Drones")
		if(!Level) Options+="Get Lv2 Upgrading"
		switch(input("Robotics: What do you want to do? Upgrade: Lets you add cybernetic bp to a person, turning them \
		into a cyborg. Uninstall Modules: Let's you uninstall previously installed cybernetic modules from a person. \
		Redo Stats lets you customize the stats of an Android Body as long as it is not currently inhabited by a \
		player. Repair: Fully heals the Android you use it on, for a cost. For these commands to work you must be \
		facing the person you want to use them on, or they will not \
		show in the choice selection. Mind Transfer: You can download your mind into another body, this only works \
		for pure Androids, not Cyborgs.") in Options)
			if("Cancel") return
			if("Get Lv2 Upgrading")
				var/Cost=2000000000/sqrt(usr.Intelligence)
				if(usr.Res()<Cost)
					usr<<"You need [Commas(Cost)]$ to do this"
					return
				switch(input("Do you want to spend [Commas(Cost)]$ to get lv2 upgrading? This will greatly increase \
				the cap on how much BP you can upgrade an android to.") in list("No","Yes"))
					if("No") return
				if(Level) return
				usr.Alter_Res(-Cost)
				Level++
				Upgrade_Power+=1.5
				view(usr)<<"[usr] upgrades the [src] to lv2 upgrading"
			if("Command Drones") usr.Drone_Options(src)
			if("Mind Transfer")
				if(!usr.Android)
					usr<<"Only Androids can use this, not Cyborgs"
					return
				var/list/Mobs=list("Cancel")
				for(var/mob/P in get_step(usr,usr.dir)) if(P.Android) Mobs+=P
				if(!(locate(/mob) in Mobs))
					usr<<"To use this, both you and the person you are facing must be Androids."
					return
				var/mob/P=input("Which Android do you want to transfer minds with?") in Mobs
				if(!P||P=="Cancel") return
				if(!P.Android)
					usr<<"You can only transfer minds with an Android, not a Cyborg or Organic."
					return
				if(P.client&&P!=usr&&!P.KO) switch(input(P,"[usr] wants to transfer minds. They will get your \
				body and you will get their body. Accept?") in list("No","Yes"))
					if("No")
						usr<<"[P] has not allowed you to transfer your mind to their body"
						return
				if(!usr||!P) return
				Switch_Bodies(usr,P)
			if("Repair Android/Cyborg")
				var/Res_Cost=round(10000/usr.Intelligence)
				if(usr.Res()<Res_Cost)
					usr<<"You need [Commas(Res_Cost)]$ to do this"
					return
				var/list/Mobs=list("Cancel")
				for(var/mob/P in get_step(usr,usr.dir)) if(P.Android||P.Is_Cybernetic()) Mobs+=P
				if(usr.Is_Cybernetic()) Mobs+=usr
				if(!(locate(/mob) in Mobs))
					usr<<"You must be facing an Android/Cyborg to use this. You can also use it on yourself if you are \
					an Android/Cyborg"
					return
				var/mob/P=input("Which Android/Cyborg do you want to repair? It will cost [Commas(Res_Cost)]$") in Mobs
				if(!P||P=="Cancel") return
				var/Timer=30
				if(P.Android) Timer*=0.5
				usr.Alter_Res(-Res_Cost)
				view(usr)<<"[usr] is repairing [P]. If either move in the next [Timer] seconds, repairs will be \
				cancelled"
				var/Loc1=usr.loc
				var/Loc2=P.loc
				while(usr&&P&&Timer>0&&Loc1==usr.loc&&Loc2==P.loc)
					Timer-=0.1
					sleep(1)
				if(!usr||!P) return
				if(Timer>0)
					view(usr)<<"Repair of [P] cancelled"
					usr.Alter_Res(Res_Cost)
					return
				view(usr)<<"[P] was successfully repaired by [usr]"
				if(P.Health<100) P.Health=100
				if(P.Ki<P.Max_Ki) P.Ki=P.Max_Ki
				for(var/obj/Injuries/I in P)
					P<<"Your [I] injury has been repaired"
					del(I)
					P.Add_Injury_Overlays()
			if("Redo Stats")
				var/list/Mobs=list("Cancel")
				for(var/mob/P in get_step(usr,usr.dir)) if(P.Android) Mobs+=P
				if(usr.Android) Mobs+=usr
				if(!(locate(/mob) in Mobs))
					usr<<"You can not use this because neither you nor the person you are facing are Androids."
					return
				var/mob/P=input("Which body do you want to redo stats on?") in Mobs
				if(!P||P=="Cancel") return
				if(P.client&&P!=usr) switch(input(P,"[usr] wants to redo your stats. Allow?") in list("No","Yes"))
					if("No")
						usr<<"[P] has not allowed you to redo their stats"
						return
				if(!usr||!P) return
				view(usr)<<"[usr] is redoing the stats of [P]"
				P.Redo_Stats(usr)
				//P.Android_Starting_Stats()
			if("Uninstall Modules")
				var/Res_Cost=200000000/usr.Intelligence
				if(usr.Res()<Res_Cost)
					usr<<"You need at least [Commas(Res_Cost)]$ to do this"
					return
				var/list/Mobs=list("Cancel")
				for(var/mob/P in get_step(usr,usr.dir)) Mobs+=P
				Mobs+=usr
				var/mob/P=input("Who's cybernetic modules do you want to uninstall? The removal will cost \
				[Commas(Res_Cost)]$") in Mobs
				if(P=="Cancel"||!P) return
				var/list/Module_List=list("Cancel")
				for(var/obj/Module/M in P) if(M.suffix) Module_List+=M
				if(!(locate(/obj) in Module_List))
					usr<<"[P] has no modules installed."
					return
				if(P.client&&P!=usr&&!P.KO) switch(input(P,"[usr] wants to uninstall some of your cybernetic \
				modules. Allow?" in list("No","Yes")))
					if("No")
						if(usr) usr<<"[P] will not allow you to uninstall their modules"
						return
				if(!P||!usr) return
				usr.Alter_Res(-Res_Cost)
				while(usr&&P)
					var/obj/Module/M=input("Which module do you want to uninstall from [P]?") in Module_List
					if(!M||!P||M=="Cancel") return
					Module_List-=M
					usr.Alter_Res(-Res_Cost)
					M.Disable_Module(P)
					usr.contents+=M
			if("Upgrade")
				var/list/Mobs=list("Cancel")
				for(var/mob/P in get_step(usr,usr.dir)) Mobs+=P
				Mobs+=usr
				var/mob/P=input("Who's cybernetic power do you want to upgrade?") in Mobs
				if(P=="Cancel"||!P) return
				if(P.client&&P!=usr&&!P.KO) switch(input(P,"[usr] wants to upgrade your cybernetic bp. Allow? \
				Be warned, they could also use this to downgrade you.") in list("No","Yes"))
					if("No")
						if(usr) usr<<"[P] has not allowed the upgrade."
						return
				if(!P||!usr) return
				if(!(locate(/obj/Module) in P)&&!Android)
					usr<<"[P] cannot be upgraded because they are not an Android or Cyborg. To qualify as a Cyborg they must \
					have at least 1 Cybernetic Module installed in their body."
					return
				var/Cap=0.7*usr.Knowledge*Upgrade_Power*(usr.Intelligence**0.3)*cyber_bp_mod
				if(P.Cyber_Power>Cap)
					usr<<"[P] is beyond your knowledge, you can not upgrade them."
					return
				var/Percent=P.Cyber_Power/Cap*100
				var/Percent_Cost=50000/usr.Intelligence
				if(Upgrade_Power>1) Percent_Cost*=40
				var/Amount=input("The cap for cybernetic BP is currently [Commas(Cap)]. [P]'s \
				cybernetic BP is at [Commas(P.Cyber_Power)]. Which is [round(Percent)]% of the cap. What percent do you \
				want to bring them to? (0-100%) Enter 0 to cancel the upgrade. Each +1% will cost you \
				[Commas(Percent_Cost)]$.") as num
				if(!P||!usr) return
				if(Amount<=0)
					view(usr)<<"[usr] has cancelled the cybernetic upgrade of [P]"
					return
				if(Amount>100) Amount=100
				var/Total_Cost=Percent_Cost*(Amount-Percent)
				if(usr.Res()<Total_Cost)
					usr<<"You need at least [Commas(Total_Cost)]$ to do this"
					return
				var/C_BP_Add=Cap*(Amount/100)
				view(usr)<<"[usr] upgraded [P]'s cybernetic power from [Commas(P.Cyber_Power)] to \
				[Commas(C_BP_Add)] ([Amount]%). Cost: [Commas(Total_Cost)]$"
				if(usr.Res()<Total_Cost) return
				if(Total_Cost<0) Total_Cost=0
				usr.Alter_Res(-Total_Cost)
				P.Cyber_Power=C_BP_Add
				P.Record_Cyber_Power=C_BP_Add
				P.BP=P.Get_Available_Power()
mob/proc/Absorb_Blast(obj/Blast/B)
	if(!(B.dir in list(turn(dir,180),turn(dir,135),turn(dir,225)))) return
	if(Disabled()||!Blast_Absorb||Ki>=Max_Ki*2) return
	var/Amount=0.2*(Max_Ki/100)*(B.Damage/(BP*Res))
	Ki+=Amount
	if(Ki>Max_Ki*2)
		Ki-=Amount
		return
	Force_Field('Black Hole.dmi',rgb(0,0,0),"full2")
	return 1
obj/Overdrive
	Skill=1
	desc="Overdrive is a cybernetic ability which allows you to temporarily bypass your limitations, increasing \
	your available cybernetic battle power. Using this will cause you damage."
	verb/Overdrive()
		set category="Skills"
		if(usr.Redoing_Stats||usr.KO) return
		if(!usr.Overdrive)
			usr<<"Overdrive activated."
			usr.Old_Trans_Graphics()
			if(!usr) return
			usr.Overdrive=1
		else usr.Overdrive_Revert()
mob/proc/Overdrive_Revert() if(Overdrive)
	usr<<"Overdrive deactivated."
	Overdrive=0
mob/proc/Disable_Modules() for(var/obj/Module/M in src) if(M.suffix) M.Disable_Module(src)
mob/proc/Enable_Modules(list/L) if(L) for(var/obj/Module/M in L) M.Enable_Module(src)
mob/var/Cyber_Fly=0
mob/var/Empty_Body
mob/var/Clone
mob/proc/Clone()
	var/mob/P=Duplicate()
	P.Experience=0 //no SP
	P.Disable_Modules()
	P.Cyber_Power=0
	P.Base_BP*=0.9
	P.Max_Ki*=0.8
	P.Ki*=0.8
	P.Original_Decline=0
	P.Decline=0
	P.Decline_Rate=3
	P.Age=0
	for(var/obj/Injuries/I in P) del(I)
	P.Alter_Res(-P.Res())
	for(var/obj/items/I in P) if(I.suffix!="Equipped") del(I)
	for(var/obj/Stun_Chip/O in P) del(O)
	for(var/obj/Module/M in P) del(M)
	P.Full_Heal()
	return P
mob/proc/Duplicate()
	var/list/L=new
	for(var/mob/M in src)
		L+=M
		contents-=M
	for(var/obj/O in src) if(!O.clonable)
		L+=O
		contents-=O
	Save_Obj(src)
	var/mob/M=new
	Load_Obj(M)
	M.Savable_NPC=1
	M.Clone=1
	M.Empty_Body=1
	for(var/V in L) if(ismob(V)||isobj(V)) contents+=V
	return M
obj/Scrap_Absorb
	Givable=1
	desc="This ability lets you absorb the scraps from dead Androids, to increase your own power. \
	Some of the power is permanent, some of it is temporary."
	var/Stored_Icon
	var/Old_Cyber_Power=0
	verb/Scrap_Absorb()
		set category="Skills"
		if(Using) return
		for(var/obj/Android_Scraps/A in view(20,usr))
			if(!A.Owner) A.Owner=usr
			view(usr)<<"[usr] begins absorbing the scraps of [A.Owner]!"
			usr.Match_Knowledge(A,100)
			var/Amount=A.Cyber_Power*0.5
			if(A.Owner!=usr) A.Owner.Death(null,1)
			var/Attack_Gains=500
			usr.Attack_Gain(Attack_Gains,A.Owner)
			Using=1
			Stored_Icon=usr.icon
			Old_Cyber_Power=usr.Cyber_Power
			usr.icon='Android 13.dmi'
			usr.Scrap_Absorb_Revert_Timer(src)
			if(usr.Ki<usr.Max_Ki*2) usr.Ki=usr.Max_Ki*2
			if(usr.Health<100) usr.Health=100
			usr.Cyber_Power+=Amount
			Scraps_Assemble(usr)
			break
obj/Android_Scraps
	icon='Android Scraps.dmi'
	density=1
	Savable=0
	var/Cyber_Power=0
	New()
		pixel_x=rand(-10,10)
		pixel_y=rand(-10,10)
mob/proc/Scrap_Absorb_Revert_Timer(obj/Scrap_Absorb/A)
	if(!A) for(var/obj/Scrap_Absorb/O in src) if(O.Using) A=O
	if(!A) return
	spawn(12000) if(src&&A&&A.Using) Scrap_Absorb_Revert(A)
mob/proc/Scrap_Absorb_Revert(obj/Scrap_Absorb/A)
	if(!A) for(var/obj/Scrap_Absorb/O in src) if(O.Using) A=O
	if(!A) return
	Cyber_Power=A.Old_Cyber_Power
	icon=A.Stored_Icon
	A.Using=0
mob/proc/Spread_Scraps()
	if(locate(/obj/Android_Scraps) in view(5,src)) return
	var/Amount=15
	Explosion_Graphics(src,1,10)
	while(Amount)
		var/obj/Android_Scraps/A=new
		A.Cyber_Power=Cyber_Power
		if(Amount<=5) A.icon_state="[Amount]"
		else
			A.icon_state="6"
			A.dir=pick(NORTH,SOUTH,EAST,WEST,NORTHWEST,NORTHEAST,SOUTHWEST,SOUTHEAST)
		A.Owner=src
		var/list/Spots
		for(var/turf/T in view(3,src))
			if(!Spots) Spots=new/list
			Spots+=T
		if(!Spots) return
		A.loc=pick(Spots)
		Amount-=1
mob/proc/Scraps_Exist() for(var/obj/Android_Scraps/A) if(A.Owner==src) return 1
proc/Scraps_Assemble(obj/T)
	if(!T) return
	var/image/I=image(icon='Black Hole.dmi',icon_state="full2")
	T.overlays+=I
	for(var/obj/Android_Scraps/A in range(10,T))
		A.density=0
		var/Steps=20
		while(Steps&&!(T in view(0,A)))
			Steps-=1
			step_towards(A,T)
			sleep(2)
		del(A)
	sleep(30)
	if(T) T.overlays-=I
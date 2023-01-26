mob/proc/GrabAbsorber()
	if(grab_absorb_module) return 1

var/rebuild_cost = 2000000

mob/proc/HasRebuildRequirements()
	if(key)
		if(!(key in bank_list)) return
		var/money = bank_list[key]
		if(money < rebuild_cost)
			for(var/obj/Module/Rebuild/r in active_modules) if(r.suffix)
				src << "You do not have the money to rebuild yourself. You must have at least [num2text(rebuild_cost,20)] resources in the bank"
				return
	return 1

mob/proc/CanRebuild()
	return Android && HasRebuildRequirements() && (locate(/obj/Module/Rebuild) in active_modules)

mob/proc/AlreadyHasModule(t)
	for(var/obj/Module/m in active_modules) if(m.type == t) return 1

mob/var
	Android
	Cyber_Scanner=0
	Cyber_Force_Field=0
	Blast_Absorb=0
	paralysis_immune=0
	tmp/obj/Module/generator_module
	tmp/obj/Module/armor_module
	tmp/obj/Module/blast_absorb_module
	tmp/obj/Module/grab_absorb_module

mob/proc/Generator_reduction(is_melee)
	var/n=1
	if(generator_module&&generator_module.suffix)
		n=0.95 //5% stronger shield
		if(generator_module&&generator_module.suffix)
			n*=2**shield_exponent //but no increase in shield power from the artificial energy

	//putting armor module in here too
	if(is_melee&&armor_module&&armor_module.suffix)
		n += armor_module.EndP

	//and blast absorb
	if(blast_absorb_module&&blast_absorb_module.suffix)
		n/=0.8

	return n

obj/Module
	icon='Modules.dmi'
	icon_state="2"
	Duplicates_Allowed = 1
	var
		Requires_Password

	Extendo_arm
		Cost=200000
		desc="A mechanical arm that shoots out to grab and attack things"
		New()
			del src

	BP_Scanner
		Cost=1000000
		desc="An integrated BP Scanner that can scan infinite amounts of BP."
		Scanner=1

	Giant_Version_New
		name = "Giant Version"
		Cost=1000000
		Android_Only=1
		desc="Scale up the design of your body, which will have +1 strength, +2 durability, +2 resistance, \
		and -2 speed"
		Giant=1
		StrP=1
		EndP=2
		ResP=2
		SpdP=-2

	Scrap_Repair
		Cost=3000000
		Android_Only=1
		desc="This is the Majin/Bio-Android death regeneration alternative for Androids. If you are destroyed, your \
		body will self-repair itself minutes later from the scraps. If the scraps are destroyed, you will not \
		self-repair."
		Regenerate_Add=4

	Scrap_Absorb
		Cost=1000000
		Android_Only=1
		desc="This is an ability like Android 13 had. The ability to absorb the scraps of destroyed Androids to \
		increase your own power."
		Abilities=list(new/obj/Skills/Special/Scrap_Absorb)

	Breath_In_Space
		Cost=50000
		desc="You will be able to breath in space with this module installed."
		Lungs=1

	Decline_Increase
		Cost=100000
		desc="This will add 50 years to your life span."
		Life_Add=50

	Drone_AI
		var/list/Commands=new
		Cost=0 //5000000
		Requires_Password=1
		Android_Only=1
		desc="Installing this on an Android/Cyborg will allow you to command them to do certain things. You must \
		set a frequency on it before it can be used. You can then command \
		your drones by having your Robotics Tools set to the same frequency as the Drone AI Module that the Drone has \
		installed."
		verb/Set() if(src in usr)
			Password=input("Set the frequency for the [src] Module.") as text
		New()
			drone_list ||= list()
			drone_list |= src
			spawn(5) if(ismob(loc)&&suffix)
				var/mob/m=loc
				m.drone_module=src
				m.Drone_initialize()
			. = ..()

	Antigravity
		Cost=1000000
		desc="An Android method of flying, it takes absolutely no energy. It will replace natural flight."
		Cyber_Fly=1

	Force_Field
		name="Force Field Module"
		Cost=1000000
		desc="A force field that activates on it's own when a blast hits you. It will drain energy."
		Cyber_Force_Field=1

	Manual_Absorb
		Cost=5000000
		desc="This will give you the ability to absorb people to increase your own power"
		Abilities=list(new/obj/Skills/Utility/Absorb)

	Blast_Absorb
		Cost=1500000
		desc="This allows you to absorb blasts, but only if they come at you from the front or front-sides. \
		Absorbing blasts increases your energy. Remember, you can only hold a maximum of 200% energy, after that \
		you will take damage. Your energy, recovery and regeneration will \
		decrease by 5% and resistance + durability will decrease by 1 with this module installed. Your shield ability will be weakened by 20%"
		Blast_Absorb=1
		Kix=0.95
		Regx=0.95
		Recx=0.95
		EndP=-1
		ResP=-1
		New()
			spawn if(suffix)
				var/mob/m=loc
				if(m&&ismob(m)) m.blast_absorb_module=src
			. = ..()

	Rebuild
		Cost=3000000
		Android_Only=1
		Requires_Password=1
		desc="If you are killed you will be rebuilt at a cybernetics computer that matches the same password that you set \
		for this module. Right click the module and click Set to set a password. Then make a cybernetics computer of the same password. \
		By having this module installed your self destruct skill will do 50% less damage. It will take 2 million resources from your bank each \
		time you are rebuilt"
		verb/Set() if(src in usr)
			if(Password) switch(input("The Rebuild Frequency is already set to [Password]. Do you really want to \
			change it?") in list("No","Yes"))
				if("No") return
			Password=input("Set the frequency for the [src] Module. You must make the frequency the same as a main \
			computer if you want the computer to rebuild the android if it dies.") as text

	Generator
		Cost=1000000
		desc="This will x2 your energy, but /2 your recovery and regeneration. +5% shield power, but no \
		shield power increase from the extra energy mod."
		Kix=2;Recx=0.5;Regx=0.5
		New()
			spawn if(suffix)
				var/mob/m=loc
				if(m&&ismob(m)) m.generator_module=src
			. = ..()

	Overdrive
		Cost=1000000
		Abilities=list(new/obj/Overdrive)
		desc="Using this will give you the option to go past your recommended limits, increasing your cybernetic \
		BP temporarily. The downside is that it slowly damages you til you turn it back off."

	Auto_Repair
		Cost=1000000
		desc="When you are damaged, nanites will begin repairing you, at the cost of some energy."
		Nanite_Repair=1

	Brute_New
		name = "Brute"
		Cost=1000000
		desc="+2 strength, x0.5 regeneration and recovery, -1 defense"
		StrP=2
		DefP=-1
		Regx=0.5
		Recx=0.5

	Armor_New
		name="Cybernetic Armor"
		Cost=1000000
		desc="+2 durability and resistance, x0.5 regeneration and recovery, -1 force and 0.8x energy"
		EndP=2
		ResP=2
		PowP=-1
		Regx=0.5
		Recx=0.5
		Kix=0.8
		New()
			spawn if(suffix)
				var/mob/m=loc
				if(m&&ismob(m)) m.armor_module=src
			. = ..()

	Time_normalizer
		Cost=5000000
		desc="Nullifies time freeze, allowing you to still move around while the time freeze is active on \
		you, but slower than you would normally move. Some more downsides are that the entire time you \
		have this module installed your regeneration is decreased by 15%, energy by 10%, \
		and force by 1."
		Kix=0.9
		Regx=0.85
		PowP=-1
		paralysis_immunity=1

	Grab_Absorb
		Cost = 2000000
		Android_Only = 1
		desc = "When you grab someone and press Spacebar you will begin draining them of their energy like Dr Gero and Android 19. \
		This will replace your normal strangle ability. It does health damage too but half as much as regular strangle. The downside \
		is that if anyone hits you during this you are unable to defend and it will be a critical strike. You get many times more energy \
		from someone who is knocked out because they can not resist."
		New()
			spawn if(suffix)
				var/mob/m = loc
				if(m && ismob(m)) m.grab_absorb_module = src
			. = ..()

	var/list/Abilities=new;var/Android_Only
	var/BPx=1;var/Kix=1;var/StrP=1;var/EndP=1;var/PowP=1;var/ResP=1;var/SpdP=1;var/OffP=1;var/DefP=1;var/Regx=1
	var/Recx=1;var/Life_Add=0;var/Leechx=1;var/Regenerate_Add=0;var/Lungs=0;var/CP_Mult=0.1;var/Cyber_Fly=0
	var/Nanite_Repair=0;var/Icon_Change;var/Giant;var/Scanner=0;var/Cyber_Force_Field=0;var/Blast_Absorb=0
	var/paralysis_immunity=0

	proc/Enable_Module(mob/P)
		if(suffix) return
		if(loc != P) return

		if(P.Redoing_Stats)
			P<<"You must wait til they are done redoing their stats"
			return

		if(P.AlreadyHasModule(type)) return

		//P.bp_mult-=BPx

		P.max_ki*=Kix;P.Eff*=Kix;P.Ki*=Kix;
		P.Str += StrP
		P.End += EndP
		P.Pow += PowP
		P.Res += ResP
		P.Spd += SpdP
		P.Off += OffP
		P.Def += DefP
		P.regen*=Regx;P.recov*=Recx
		P.Decline+=Life_Add;P.leech_rate*=Leechx;P.Regenerate+=Regenerate_Add;P.Lungs+=Lungs;P.Cyber_Fly+=Cyber_Fly
		P.Nanite_Repair+=Nanite_Repair;P.Cyber_Scanner+=Scanner;P.Cyber_Force_Field+=Cyber_Force_Field;\
		P.Blast_Absorb+=Blast_Absorb
		P.paralysis_immune+=paralysis_immunity
		if(P.Nanite_Repair) P.NaniteRepairTick()
		if(Icon_Change&&P.Android)
			P.icon=Icon_Change
			P.overlays-=P.overlays
			for(var/obj/Module/M in P.active_modules) if(M.suffix&&M.Giant)
				P.Enlarge_Icon(48,48)
				P.pixel_y=0
		if(Giant)
			P.Enlarge_Icon(42,42)
			P.pixel_y=0

		if(istype(src,/obj/Module/Blast_Absorb)) P.blast_absorb_module=src
		suffix="Installed"
		P.has_modules=1
		for(var/obj/O in Abilities) P.contents+=O
		P.active_modules+=src
		P.contents += src
		if(P.Race != "Android" && P.Is_Cybernetic() && P.Class != "Cyborg")
			P.originalClass = P.Class
			P.Class = "Cyborg"
			for(var/t in P.UnlockedTransformations)
				var/transformation/T = P.UnlockedTransformations[t]
				if(!T) continue
				T.ExitForm(P)
		if(type == /obj/Module/Grab_Absorb) P.grab_absorb_module = src
		if(istype(src,/obj/Module/Drone_AI)) P.Drone_initialize()

	proc/Disable_Module(mob/P)

		if(P.Redoing_Stats)
			P<<"You must wait til they are done redoing their stats"
			return
		if(!suffix || loc != P) return
		if(!(src in P.active_modules)) return

		//P.bp_mult-=BPx-1
		P.max_ki/=Kix;P.Eff/=Kix;P.Ki/=Kix;
		P.Str -= StrP
		P.End -= EndP
		P.Pow -= PowP
		P.Res -= ResP
		P.Spd -= SpdP
		P.Off -= OffP
		P.Def -= DefP
		P.regen/=Regx;P.recov/=Recx
		P.Decline-=Life_Add;P.leech_rate/=Leechx;P.Regenerate-=Regenerate_Add;P.Lungs-=Lungs;P.Cyber_Fly-=Cyber_Fly
		P.Nanite_Repair-=Nanite_Repair;P.Cyber_Scanner-=Scanner;P.Cyber_Force_Field-=Cyber_Force_Field;\
		P.Blast_Absorb-=Blast_Absorb
		P.paralysis_immune-=paralysis_immunity
		if(Giant) P.Enlarge_Icon(32,32)

		if(istype(src,/obj/Module/Generator)) P.generator_module=null
		if(istype(src,/obj/Module/Blast_Absorb)) P.blast_absorb_module=null
		suffix=null
		var/obj/Module/any_installed_module
		for(any_installed_module in P) if(any_installed_module.suffix) break
		if(!any_installed_module) P.has_modules=0
		for(var/obj/O in Abilities) P.contents-=O
		P.active_modules-=src
		if(P.Race != "Android" && !P.Is_Cybernetic() && P.Class == "Cyborg")
			P.Class = P.originalClass
		if(type == /obj/Module/Grab_Absorb) P.grab_absorb_module = null

	Click() if(src in usr)
		if(!suffix)

			if(Requires_Password&&!Password)
				usr<<"You can not install this module until you activate it. Do so by right clicking \
				it and exploring it's commands."
				return

			var/list/Mobs=list("Cancel")
			for(var/mob/P in Get_step(usr,usr.dir)) Mobs+=P
			Mobs+=usr
			var/mob/P=input("Install [src] on who?") in Mobs
			if(!P||P=="Cancel") return

			for(var/obj/Module/M in P.active_modules) if(M!=src&&M.type==type&&M.suffix)
				usr<<"[P] already has one installed. No more can be installed"
				return

			if(Android_Only&&!P.Android)
				usr<<"Installation failed. [src] can only be installed on 100% non-organic Androids. [P] is either a Cyborg or 100% Organic."
				return

			if(P.client&&P!=usr&&!P.KO) switch(input(P,"[usr] wants to install a cybernetic module on you: [src]. Allow?") in list("No","Yes"))
				if("No")
					if(usr) usr<<"[P] will not allow you to install [src]"
					return

			if(!P) return
			if(suffix) return
			if(P == usr && loc != usr) return //if you are trying to install it on yourself but it is no longer in your contents, deny

			src.Move(P)
			Enable_Module(P)
			player_view(15,usr)<<"[usr] installs [src] (Cybernetic Module) on [P]"

	verb/Drop()
		var/mob/P
		for(P in Get_step(usr,usr.dir)) break
		if(P&&!P.client) P=null
		if(suffix)
			usr<<"You can not drop this while it is installed in your body"
			return
		if(usr.Redoing_Stats)
			usr << "You can not drop items while redoing stats!"
			return
		if(usr.IsFusion())
			usr << "Fused beings can not drop items!"
			return
		for(var/mob/A in player_view(15,usr)) if(A.see_invisible>=usr.invisibility)
			if(!P) A<<"[usr] drops [src]"
			else A<<"[usr] gives [P] a [src]"
		SafeTeleport(usr.loc)
		step(src,usr.dir)
		dir=SOUTH
		if(P) Move(P)
		else usr.Store_item_check(src)

	New()
		spawn if(ismob(loc))
			var/mob/M=loc
			if(suffix)
				M.active_modules ||= list()
				M.active_modules |= src
		

	Del()
		if(suffix)
			var/mob/M=loc
			if(ismob(M)) Disable_Module(M)
		. = ..()

mob/proc/HasModules()
	for(var/obj/Module/M in src)
		return 1

mob/var/tmp/list/active_modules=new
mob/var/cyber_bp=0
mob/var/Record_cyber_bp=0
mob/var/has_modules
mob/var/originalClass
mob/proc/has_modules()
	if(has_modules) return 1

mob/proc/Is_Cybernetic()
	return (Android||cyber_bp||has_modules())

mob/var/Nanite_Repair
var/list/cybernetics_computers=new
obj/Cybernetics_Computer
	New()
		cybernetics_computers ||= list()
		cybernetics_computers += src
	icon='Lab.dmi'
	icon_state="Lab2"
	Makeable=1
	density=1
	Cost=500000
	var/list/Kill_List=new
	var/list/Stored_Blueprints=list("Cancel")
	var/list/Illegals=new
	desc="This computer will rebuild cyborgs/androids who have died and were linked to this computer. \
	And allows you to command Drones."
	takes_gradual_damage=1
	verb/Upgrade()
		set name="Repair/Upgrade health"
		set src in view(1)
		if(usr in view(1,src))
			var/max_health=usr.Knowledge*usr.Intelligence()*10
			if(Health<max_health)
				player_view(15,usr)<<"[usr] repairs/upgrades the [src]'s health to [Commas(max_health)] BP"
				Health=max_health
			else usr<<"The [src] is beyond your upgrading abilities"
	verb/Use()
		set src in oview(1,usr)
		if(usr in view(1,src))
			if(dna_protected&&dna_protected!=usr.key)
				alert("You can not use this because it requires DNA authentication")
				return
			var/list/options=list("Cancel","Repair Android/Cyborg","Command Drones","Set Frequency",\
			"Make blank android body")
			if(dna_protected) options+="Disable DNA authentication"
			else options+="Enable DNA authentication"
			switch(input("[src]") in options)
				if("Cancel") return
				if("Enable DNA authentication")
					dna_protected=usr.key
					usr<<"DNA protection activated"
				if("Disable DNA authentication")
					dna_protected=0
					usr<<"DNA protection disabled"
				if("Make blank android body")
					var/res_cost=1000000/usr.Intelligence()**0.2
					if(usr.Res()<res_cost) alert("You need [Commas(res_cost)] resources to do this")
					else
						switch(alert("You need [Commas(res_cost)] resources to do this, accept?","Options","Yes","No"))
							if("No") return
						if(usr.Res()<res_cost) return
						usr.Alter_Res(-res_cost)
						var/mob/P=new
						P.name="Android"
						P.icon='Android.dmi'
						P.Android()
						P.contents += GetCachedObject(/obj/Resources)
						P.Savable=1
						P.Savable_NPC=1
						P.TechTab=1
						P.TextColor=usr.TextColor
						P.Class="Custom Built"
						P.SafeTeleport(loc)
						P.dir=SOUTH
						P.Android_Starting_Stats()
						P.Random_Colors()
						for(var/obj/O in P) O.Mastery=1000
				if("Command Drones") usr.Drone_Options(src)
				if("Repair Android/Cyborg")
					if(!usr.Is_Cybernetic())
						usr<<"Only Androids and Cyborgs can be repaired"
						return
					if(usr.Ship)
						usr<<"You can not do this while piloting a ship"
						return

					/*if(usr.last_attacked_by_player+300>world.time)
						usr<<"You can not do this right now because [usr] is considered in combat from being \
						recently attacked in the last 30 seconds."
						return*/

					var/Timer = 12
					//if(usr.Android) Timer*=0.8
					player_view(15,usr)<<"[src]: Repairing [usr]. If you do anything (attack, powerup, move) in less than [Timer] seconds, repairs will be cancelled"
					var/Loc1=usr.loc
					while(usr&&Timer>0&&Loc1==usr.loc&&usr.BPpcnt<=100&&!usr.attacking&&!usr.Ship)
						Timer-=world.tick_lag/10
						sleep(world.tick_lag)
					if(!usr) return
					if(Timer>0)
						player_view(15,usr)<<"[src]: Repair of [usr] cancelled"
						return
					player_view(15,usr)<<"[src]: [usr] successfully repaired"
					if(usr.Health<100) usr.Health=100
					if(usr.Ki<usr.max_ki) usr.Ki=usr.max_ki
					if(usr.BPpcnt>100) usr.BPpcnt=100
				if("Set Frequency")
					switch(input("You are about to reset the [src] frequency. The [src] frequency is a \
					frequency that cyborgs can be linked to using a Rebuild Module or Drone AI module, and perhaps other \
					modules (all of which must be installed in them). If their \
					module frequencies matches the frequency of the [src], and they are destroyed, this [src] will \
					rebuild them here if they have a rebuild module, and if they have a drone AI module you can send \
					orders to them from the [src], because their frequencies were linked.") in list("No","Yes"))
						if("No") return
						if("Yes")
							player_view(15,src)<<"[src]: [usr] is resetting the rebuild frequency."
							Password=input("Set a frequency for the [src]. This will allow it to track Cyborgs who have a Rebuild \
							Module installed on them which has the same frequency. So if that cyborg dies, this computer will rebuild \
							them here.") as text
mob/proc/Choose_Mob(T="Choose someone",list/L)
	if(!L) L=players
	var/mob/P=input(src,T) in L
	if(P) return P

mob/var
	brain_transplant_allowed=1
	stat_build_unlocked = 0

obj/Genetics_Computer
	icon='Lab.dmi'
	icon_state="Lab1"
	Makeable=1
	density=1
	Cost = 2000000
	desc="This computer can let you swap bodies, modify genetics (stats), and other neat things like that."
	takes_gradual_damage=1
	verb/Upgrade()
		set name="Repair/Upgrade health"
		set src in view(1)
		if(usr in view(1,src))
			var/max_health=usr.Knowledge*usr.Intelligence()
			if(Health<max_health)
				player_view(15,usr)<<"[usr] repairs/upgrades the [src]'s health to [Commas(max_health)] BP"
				Health=max_health
			else usr<<"The [src] is beyond your upgrading abilities"

	verb/Use()
		set src in oview(1,usr)
		if(usr.fusing) return
		if(usr in view(1,src))
			if(usr.IsFusion())
				alert("You can not use this while fused!")
				return
			if(usr.fusing) return
			if(dna_protected&&dna_protected!=usr.key)
				alert("You can not use this because it is passworded to someone else's DNA")
				return
			var/list/options=list("Cancel","Mind Swap","Redo Stats (Non-Androids only)", "Reset Traits")

			if(dna_protected) options+="Disable DNA authentication"
			else options+="Enable DNA authentication"
			switch(input("[src]: What do you want to do?") in options)
				if("Cancel") return
				if("Disable DNA authentication")
					if(usr.fusing) return
					usr<<"DNA authentication disabled"
					dna_protected=0
				if("Enable DNA authentication")
					if(usr.fusing) return
					usr<<"DNA authentication enabled. This means only you can use the [src]"
					dna_protected=usr.key
				if("Redo Stats (Non-Androids only)")
					if(usr.fusing) return

					var/list/Mobs=list("Cancel")
					for(var/mob/P in Get_step(usr,usr.dir))
						if(!P.Android && !P.IsFusion())
							Mobs+=P
					if(!usr.Android && !usr.IsFusion()) Mobs += usr
					if(!(locate(/mob) in Mobs))
						usr<<"This can only be used on creatures with DNA (non-Androids or Fusions)"
						return

					var/mob/P=input("Who do you want to redo stats on?") in Mobs
					if(!P||P=="Cancel") return
					if(P.empty_player && !P.client)
						usr << "They are not online to approve their stats being redone"
						return
					if(P.client && P != usr)
						switch(input(P,"[usr] wants to redo your stats. Allow?") in list("No","Yes"))
							if("No")
								usr<<"[P] has not allowed you to redo their stats"
								return

					if(!usr||!P) return
					var/res_cost=round(5000000/usr.Intelligence()**0.4)
					if(usr.Res()<res_cost)
						usr<<"You need [Commas(res_cost)] resources to do this."
						return
					switch(alert(usr,"Do you want to use [Commas(res_cost)] resources to do this?","Options","Yes","No"))
						if("No") return
						if("Yes")
							if(usr.Res()<res_cost) return
							usr.Alter_Res(-res_cost)
					player_view(15,usr)<<"[usr] is redoing the stats of [P]"
					P.Redo_Stats(usr)
				
				if("Reset Traits")
					if(usr.fusing) return
					var/res_cost=round(250000000/usr.Intelligence()**0.4)
					if(usr.Res() < res_cost)
						usr << "You need [Commas(res_cost)] resources to do this."
						return
					usr.Alter_Res(-res_cost)
					usr.ResetTraits()
					usr << "Your traits have been reset and trait points refunded."

				if("Mind Swap")
					if(usr.fusing) return
					if(usr.last_mind_swap_time+100>world.time)
						alert(usr,"You can only mind swap once every 10 seconds")
						return

					var/list/Mobs=list("Cancel")
					for(var/mob/P in view(1,src))
						if(P != usr && P.brain_transplant_allowed && !P.empty_player && !P.IsFusion())
							if(!P.drone_module || (P.drone_module && P.Is_drone_master(usr)) || P.KO)
								if(P.canMindSwapWith)
									Mobs+=P

					if(!(locate(/mob) in Mobs))
						usr<<"You and someone else must be next to the [src] to do this"
						return

					//theres a bug with going into npcs where if you mind swap the npc and relog it will
					//dupe your entire body and items and also sometimes you will become a mob with a blank race
					for(var/mob/m in Mobs) if(istype(m,/mob/Enemy))
						Mobs -= m

					var/mob/P=input("Choose which body you want to go into") in Mobs
					if(!P||P=="Cancel") return
					if(!usr.Can_alter_drone(P)) return
					if(P.last_mind_swap_time+100>world.time)
						alert(usr,"You can not mind swap with them because they have mind swapped in \
						the last 10 seconds")
						return

					if(P.client&&P!=usr)
						switch(alert(P,"[usr] wants to switch bodies with you, accept?","options","No","Yes"))
							if("No")
								usr<<"[P] has rejected the mind swap"
								return

					if(!usr || !P) return

					if(P.empty_player || usr.empty_player) return
					player_view(15,src)<<"[usr] has changed minds with [P]!"
					P.last_mind_swap_time=world.time
					usr.last_mind_swap_time=world.time
					Switch_Bodies(usr,P)

mob/var/tmp/last_mind_swap_time=0

mob/proc/Android_Starting_Stats()
	max_ki = Math.Max(max_ki, 5000 * Eff)
	Str = Math.Min(Str, 9)
	End = Math.Min(End, 9)
	Pow = Math.Min(Pow, 3)
	Res = Math.Min(Res, 9)
	Off = Math.Min(Off, 6)
	Def = Math.Min(Def, 6)
	Spd = Math.Min(Spd, 6)

obj/var/Total_Cost=0 //Cost of the item including upgrades
atom/var/can_blueprint=1

proc/DroneCount()
	var/count = 0
	for(var/obj/o in drone_list)
		var/mob/m = o.loc
		if(!m || !m.z || !m.drone_module) continue
		count++
	return count

obj/items/Android_Blueprint
	name="Blueprint"
	icon='Modules.dmi'
	desc="This can hold the design schematics for an Android Body or other science items, so that they can \
	be mass produced. Just face the item you want to have blueprinted, or have the item in your contents, and hit \
	the 'Use' verb to assign the item to be blueprinted, once that is done hitting Use \
	any more times will make a new copy of the blueprinted item. Hit the 'Reset' verb to make the blueprint \
	blank again."
	icon_state="1"
	Cost=100000
	clonable = 0
	Stealable=1
	var/mob/Body

	New()
		. = ..()
		DeleteBlueprintedShips()

	proc/DeleteBlueprintedShips()
		set waitfor=0
		sleep(5)
		if(Body && Body.type == /obj/Ships/Ship)
			var/obj/o = Body
			o.reallyDelete = 1
			del(o)
			Body = null
			reallyDelete = 1
			del(src)

	verb/Reset()
		Body=null
		name=initial(name)
		usr<<"[src] has been reset. Hit 'Use' to assign another item to be blueprinted"

	verb/Hotbar_use()
		set hidden=1
		Use()

	verb/Use() if(src in usr)
		if(Body&&usr.last_attacked_by_player+600>world.time)
			usr<<"You can not do this right now because you are considered in combat from being \
			recently attacked."
			return
		if(!Body)
			var/list/L=list("Cancel")
			for(var/mob/P in Get_step(usr,usr.dir)) if(P.Android&&!P.client&&P.can_blueprint) L+=P
			for(var/obj/O in Get_step(usr,usr.dir)) if(O.Cost&&O.type!=type&&O.can_blueprint) L+=O
			for(var/obj/O in usr) if(O.Cost&&O.type!=type&&O.can_blueprint) L+=O
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
			var/turf/T=Get_step(usr,usr.dir)
			if(T&&(T.density||(locate(/obj) in T)))
				usr<<"There is already an object occupying this space"
				return
			if(ismob(Body))
				for(var/obj/o in Body)
					if(!ALLOW_BLUEPRINT_ILLEGAL && o.type in Illegal_Science)
						usr<<"This clone contains illegal science items and can not be made"
						return
				if(Body.drone_module && DroneCount() >= Limits.GetSettingValue("Maximum Drones"))
					usr << "No more drones can be made because the maximum amount ([Limits.GetSettingValue("Maximum Drones")]) already exists in the world. This is to stop lag."
					return
				var/Res_Cost=5000
				//for(var/obj/Module/M in Body) Res_Cost+=M.Cost
				for(var/obj/o in Body) Res_Cost+=o.Cost //o.Cost*2
				if(usr.Res()<Res_Cost)
					usr<<"You need [Commas(Res_Cost)]$ to do this"
					return
				usr.Alter_Res(-Res_Cost)
				usr<<"Cost: [Commas(Res_Cost)]$"
				var/mob/P=Body.Duplicate()
				//hopefully prevent a res dupe
				P.SetRes(0)
				for(var/mob/m2 in P) m2.SetRes(0)
				P.mob_creation_time = world.realtime
				P.SafeTeleport(Get_step(usr,usr.dir))
				P.dir=SOUTH
				P.Mob_ID=get_mob_id()

			if(isobj(Body))
				for(var/Illegal in Illegal_Science) if(!ALLOW_BLUEPRINT_ILLEGAL && Illegal==Body.type)
					usr<<"The item you are trying to create with this blueprint is currently disabled by \
					admins and can not be made"
					return
				if(usr.locz()==10) //hbtc
					if(Body.type==/obj/Spawn)
						usr<<"Spawns can not be made in the time chamber"
						return
				var/obj/Drill/O=Body
				var/Res_Cost=O.Total_Cost+O.Cost
				if(usr.Res()<Res_Cost)
					usr<<"You need [Commas(Res_Cost)]$ to do this"
					return

				if(Body.type == /obj/Android_Scraps)
					var/obj/Android_Scraps/scraps = Body
					scraps.can_absorb_these_scraps = 0

				usr.Alter_Res(-Res_Cost)
				usr<<"Cost: [Commas(Res_Cost)]$"
				Save_Obj(O)
				O=new O.type
				Load_Obj(O)
				if(istype(O,/obj/Drill)) O.Resources=0
				O.SafeTeleport(Get_step(usr,usr.dir))
				O.dir=NORTH

proc/get_obj_copy(obj/o)
	Save_Obj(o)
	var/obj/o2=new o.type
	Load_Obj(o2)
	return o2
proc/Save_Obj(obj/O) if(O)
	var/savefile/F=new("data/Blueprint")
	O.Write(F)
	if(F["key"]) F["key"]<<null
proc/Load_Obj(obj/O) if(O)
	var/savefile/F=new("data/Blueprint")
	O.Read(F)

obj/var/dna_protected
var/list/robotics_tools=new

proc/CyberModuleChoices()
	return list(new/obj/Module/Blast_Absorb, new/obj/Module/Armor_New, new/obj/Module/Brute_New, new/obj/Module/Generator,\
				new/obj/Module/Auto_Repair, new/obj/Module/Antigravity, new/obj/Module/BP_Scanner)

mob/proc/Can_alter_drone(mob/drone,display_message=1)
	if(drone.drone_module && !drone.KO && !drone.Is_drone_master(src))
		if(display_message) src<<"You can not alter someone else's drone unless you knock it out first"
		return
	return 1

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
	New()
		robotics_tools ||= list()
		robotics_tools += src
		. = ..()
	verb/Hotbar_use()
		set hidden=1
		Use()
	verb/Use() if(src in usr)

		if(dna_protected&&dna_protected!=usr.key)
			alert("You can not use this because it is passworded to someone else's DNA")
			return

		var/list/Options=list("Cancel","Upgrade","Uninstall Modules","Redo Android Stats",\
		"Repair Android/Cyborg","Mind Transfer","Command Drones")
		if(!Level) Options+="Get Lv2 Upgrading"
		if(dna_protected) Options+="Disable DNA authentication"
		else Options+="Enable DNA authentication"
		switch(input("Robotics: What do you want to do? Upgrade: Lets you add cybernetic bp to a person, turning them \
		into a cyborg. Uninstall Modules: Let's you uninstall previously installed cybernetic modules from a person. \
		Redo Stats lets you customize the stats of an Android Body as long as it is not currently inhabited by a \
		player. Repair: Fully heals the Android you use it on, for a cost. For these commands to work you must be \
		facing the person you want to use them on, or they will not \
		show in the choice selection. Mind Transfer: You can download your mind into another body, this only works \
		for pure Androids, not Cyborgs.") in Options)
			if("Cancel") return
			if("Disable DNA authentication")
				usr<<"DNA authenticaion disabled"
				dna_protected=0
			if("Enable DNA authentication")
				usr<<"DNA authentication is now on. This means that only you can use the [src] now"
				dna_protected=usr.key
			if("Get Lv2 Upgrading")
				var/Cost=20000000/sqrt(usr.Intelligence())
				if(usr.Res()<Cost)
					usr<<"You need [Commas(Cost)]$ to do this"
					return
				switch(input("Do you want to spend [Commas(Cost)]$ to get lv2 upgrading? This will greatly increase \
				the cap on how much BP you can upgrade an android to.") in list("No","Yes"))
					if("No") return
				if(Level) return
				usr.Alter_Res(-Cost)
				Level++
				Upgrade_Power+=0.3
				player_view(15,usr)<<"[usr] upgrades the [src] to lv2 upgrading"
			if("Command Drones") usr.Drone_Options(src)
			if("Mind Transfer")
				if(usr.last_mind_swap_time + 100 > world.time)
					alert(usr,"You can only mind swap once every 10 seconds")
					return
				if(!usr.Android)
					usr<<"Only Androids can use this, not Cyborgs"
					return
				var/list/Mobs=list("Cancel")
				for(var/mob/P in Get_step(usr,usr.dir))
					if(P.Android && !P.empty_player && P.brain_transplant_allowed)
						if(!P.drone_module || (P.drone_module && P.Is_drone_master(usr)) || P.KO)
							if(P.canMindSwapWith)
								Mobs+=P
				if(!(locate(/mob) in Mobs))
					usr<<"To use this, both you and the person you are facing must be Androids."
					return
				var/mob/P=input("Which Android do you want to transfer minds with?") in Mobs
				if(!P||P=="Cancel") return
				if(!P.Android)
					usr<<"You can only transfer minds with an Android, not a Cyborg or Organic."
					return
				if(!usr.Can_alter_drone(P)) return
				if(P.client && P != usr)
					switch(input(P,"[usr] wants to transfer minds. They will get your \
					body and you will get their body. Accept?") in list("No","Yes"))
						if("No")
							usr<<"[P] has not allowed you to transfer your mind to their body"
							return
				if(!usr||!P) return
				if(P.last_mind_swap_time+100>world.time)
					alert(usr,"You can not mind swap with them because they have mind swapped in \
					the last 10 seconds")
					return
				if(usr.empty_player||P.empty_player) return
				player_view(15,src)<<"[usr] has changed minds with [P]!"
				P.last_mind_swap_time=world.time
				usr.last_mind_swap_time=world.time
				Switch_Bodies(usr,P)
			if("Repair Android/Cyborg")
				var/Res_Cost=round(50000/usr.Intelligence())
				if(usr.Res()<Res_Cost)
					usr<<"You need [Commas(Res_Cost)]$ to do this"
					return
				var/list/Mobs=list("Cancel")
				for(var/mob/P in Get_step(usr,usr.dir)) if(P.Android||P.Is_Cybernetic()) Mobs+=P
				if(usr.Is_Cybernetic()) Mobs+=usr
				if(!(locate(/mob) in Mobs))
					usr<<"You must be facing an Android/Cyborg to use this. You can also use it on yourself if you are \
					an Android/Cyborg"
					return
				var/mob/P=input("Which Android/Cyborg do you want to repair? It will cost [Commas(Res_Cost)]$") in Mobs
				if(!P||P=="Cancel") return

				/*if(P.last_attacked_by_player+300>world.time)
					usr<<"You can not do this right now because [P] is considered in combat from being \
					recently attacked in the last 30 seconds."
					return
					*/

				if(P.Ship)
					usr<<"[P] can not be repaired while piloting a ship"
					return

				var/Timer=16
				//if(P.Android) Timer*=0.8
				usr.Alter_Res(-Res_Cost)
				player_view(15,usr)<<"[usr] is repairing [P]. If either do anything (move, attack, powerup) in the next [Timer] seconds, repairs will be \
				cancelled"
				var/Loc1=usr.loc
				var/Loc2=P.loc
				while(usr&&P&&Timer>0&&Loc1==usr.loc&&Loc2==P.loc&&P.BPpcnt<=100&&!P.attacking&&!P.Ship)
					Timer-=world.tick_lag/10
					sleep(world.tick_lag)
				if(!usr||!P) return
				if(Timer>0)
					player_view(15,usr)<<"Repair of [P] cancelled"
					usr.Alter_Res(Res_Cost)
					return
				player_view(15,usr)<<"[P] was successfully repaired by [usr]"
				if(P.Health<100) P.Health=100
				if(P.Ki<P.max_ki) P.Ki=P.max_ki
				if(P.BPpcnt>100) P.BPpcnt=100
			if("Redo Android Stats")

				var/list/Mobs=list("Cancel")
				for(var/mob/P in Get_step(usr,usr.dir)) if(P.Android) Mobs+=P
				if(usr.Android) Mobs+=usr
				if(!(locate(/mob) in Mobs))
					usr<<"You can not use this because neither you nor the person you are facing are Androids."
					return
				var/mob/P=input("Which body do you want to redo stats on?") in Mobs
				if(!P||P=="Cancel") return
				if(!usr.Can_alter_drone(P)) return
				if(P.client&&P!=usr) switch(input(P,"[usr] wants to redo your stats. Allow?") in list("No","Yes"))
					if("No")
						usr<<"[P] has not allowed you to redo their stats"
						return
				if(!usr||!P) return
				if(P.empty_player)
					usr << "You can not do this to a logged out player"
					return
				player_view(15,usr)<<"[usr] is redoing the stats of [P]"
				P.Redo_Stats(usr)
			if("Uninstall Modules")
				var/Res_Cost=1000000/usr.Intelligence()**0.5
				if(usr.Res()<Res_Cost)
					usr<<"You need at least [Commas(Res_Cost)]$ to do this"
					return
				var/list/Mobs=list("Cancel")
				for(var/mob/P in Get_step(usr,usr.dir))
					Mobs+=P
				Mobs+=usr
				var/mob/P=input("Who's cybernetic modules do you want to uninstall? The removal will cost \
				[Commas(Res_Cost)]$") in Mobs
				if(P=="Cancel"||!P) return
				if(!usr.Can_alter_drone(P)) return
				var/list/Module_List=list("Cancel")
				for(var/obj/Module/M in P.active_modules) if(M.suffix) Module_List+=M
				if(!(locate(/obj) in Module_List))
					usr<<"[P] has no modules installed."
					return
				if(P.client&&P!=usr&&!P.KO)
					switch(alert(P,"[usr] wants to uninstall some of your cybernetic modules. Allow?",, "Yes", "No"))
						if("No")
							if(usr) usr<<"[P] will not allow you to uninstall their modules"
							return
				if(!P||!usr) return
				while(usr&&P)
					var/obj/Module/M=input("Which module do you want to uninstall from [P]?") in Module_List
					if(usr.Res()<Res_Cost) return
					if(!M||!P||M=="Cancel") return
					Module_List-=M
					usr.Alter_Res(-Res_Cost)
					M.Disable_Module(P)
					usr.contents+=M
			if("Upgrade")
				var/list/Mobs=list("Cancel")
				for(var/mob/P in Get_step(usr,usr.dir)) Mobs+=P
				Mobs+=usr
				if(Mobs.len<=2) Mobs-="Cancel"
				var/mob/P=input("Who's cybernetic power do you want to upgrade?") in Mobs
				if(P=="Cancel"||!P) return
				if(!usr.Can_alter_drone(P)) return
				var/transformation/T = P.GetActiveForm()
				if(T)
					usr<<"[P] must be in base form! Upgrade canceled."
					return

				if(P.client && P != usr)
					if(!P.KO || (P.KO && !Social.GetSettingValue("Forced Cyborgization")))
						switch(input(P,"[usr] wants to upgrade your cybernetic bp. Allow? \
						Be warned, they could also use this to downgrade you.") in list("No","Yes"))
							if("No")
								if(usr) usr<<"[P] has not allowed the upgrade."
								return

				if(!P||!usr) return
				var/Cap=usr.Get_max_cyber_bp_upgrade(race=P.Race)
				if(P.cyber_bp>Cap)
					usr<<"[P] is beyond your knowledge, you can not upgrade them."
					return
				var/Percent=P.cyber_bp/Cap*100
				var/Percent_Cost=2000/usr.Intelligence()
				if(Upgrade_Power>1) Percent_Cost*=40
				var/Amount=input("The cap for cybernetic BP is currently [Commas(Cap)]. [P]'s \
				cybernetic BP is at [Commas(P.cyber_bp)]. Which is [round(Percent)]% of the cap. What percent do you \
				want to bring them to? (0-100%) Enter 0 to cancel the upgrade. Each +1% will cost you \
				[Commas(Percent_Cost)]$.") as num
				if(!P||!usr) return
				if(Amount <= 0)
					Amount = 0
					var/remove_cost=round(1500000/usr.Intelligence()**0.3)
					switch(alert(usr,"You have entered 0. Does this mean you want to cancel the upgrade or does \
					it mean that you want to pay [Commas(remove_cost)]$ to remove all cybernetic BP?","options",\
					"Cancel upgrade","Remove cybernetic BP"))
						if("Cancel upgrade")
							player_view(15,usr)<<"[usr] has cancelled the cybernetic upgrade of [P]"
							return
						if("Remove cybernetic BP")
							if(usr.Res() < remove_cost)
								usr<<"You need [Commas(remove_cost)]$ to remove all cybernetic BP"
								return
							usr.Alter_Res(-remove_cost)
				if(Amount>100) Amount=100
				var/Total_Cost=Percent_Cost*(Amount-Percent)
				if(Total_Cost<0) Total_Cost=0
				if(usr.Res()<Total_Cost)
					usr<<"You need at least [Commas(Total_Cost)]$ to do this"
					return
				var/C_BP_Add = Cap * (Amount / 100)
				player_view(15,usr)<<"[usr] upgraded [P]'s cybernetic power from [Commas(P.cyber_bp)] to \
				[Commas(C_BP_Add)] ([Amount]%). Cost: [Commas(Total_Cost)]$"
				if(usr.Res()<Total_Cost) return
				if(Total_Cost<0) Total_Cost=0
				usr.Alter_Res(-Total_Cost)
				P.cyber_bp=C_BP_Add
				P.UpdateBPTier()
				if(P.Race != "Android")
					if(!P.Is_Cybernetic() && P.Class == "Cyborg")
						P.Class = P.originalClass
					else if(P.Is_Cybernetic() && P.Class != "Cyborg")
						P.originalClass = P.Class
						P.Class = "Cyborg"
				P.Record_cyber_bp=C_BP_Add
				P.BP=P.get_bp()

mob/var/blast_absorb_next_use=0

mob/proc/Absorb_Blast(obj/Blast/B)
	var/overloadMult = 2
	if(!B.Is_Ki || !Blast_Absorb || Ki >= max_ki * overloadMult || Disabled()) return
	if(world.realtime < blast_absorb_next_use) return
	if(!(B.dir in list(turn(dir,180),turn(dir,135),turn(dir,225)))) return
	var/Amount = 1 * (max_ki / 100) * ((B.BP * B.Force * B.percent_damage) / (BP * Res))
	if(B.Owner == src) Amount = 0 //cant get energy from your own blasts
	IncreaseKi(Amount)
	del B
	if(Ki>max_ki * overloadMult)
		Explosion_Graphics(src, 2)
		KnockOut(B.Owner, can_anger = 0)
		IncreaseKi(-Ki + 1)
		TakeDamage(Health + 1, "overload")
		var/timer = 7 / ((Eff + recov) ** 0.5)
		timer = round(timer, 0.01)
		src << "Your blast absorber has been overloaded! It will re-activate in [timer] minutes"
		blast_absorb_next_use = world.realtime + (timer * 60 * 10)
		return
	Force_Field('Black Hole.dmi',rgb(0,0,0),"full2")
	return 1

obj/Overdrive
	Skill=1
	hotbar_type="Buff"
	can_hotbar=1
	desc="Overdrive is a cybernetic ability which allows you to temporarily bypass your limitations, increasing \
	your available cybernetic battle power. Using this will cause you damage."
	verb/Hotbar_use()
		set hidden=1
		Overdrive()
	verb/Overdrive()
		set category = "Skills"
		usr.Overdrive()
mob/proc/Overdrive()
	if(Redoing_Stats||KO) return
	if(!Overdrive)
		src<<"Overdrive activated."
		Old_Trans_Graphics()
		if(!src) return
		Overdrive=1
	else Overdrive_Revert()
mob/proc/Overdrive_Revert() if(Overdrive)
	src<<"Overdrive deactivated."
	Overdrive=0

mob/proc/Disable_Modules() for(var/obj/Module/M in src) if(M.suffix) M.Disable_Module(src)

mob/var/Cyber_Fly=0

mob/proc/Clone()
	var/mob/P=Duplicate(include_unclonables = 0)

	P.Experience=0 //no SP
	P.Disable_Modules()
	P.cyber_bp=0
	P.base_bp*=0.9
	P.static_bp*=0.9
	P.max_ki*=0.6
	P.Ki*=0.6
	P.Knowledge*=0.98
	if(P.gravity_mastered>=50) P.gravity_mastered*=0.5
	P.Original_Decline=5
	P.Decline=5
	P.Decline_Rate*=3
	P.Age=0
	P.Alter_Res(-P.Res())
	for(var/obj/items/I in P.item_list) if(I.suffix!="Equipped") del(I)
	for(var/obj/Module/M in P) del(M)
	P.FullHeal()
	return P

mob/var/scrap_absorb_mode

obj/Skills/Special/Scrap_Absorb
	Givable=1
	desc="This ability lets you absorb the scraps from dead Androids, to increase your own power. \
	Some of the power is permanent, some of it is temporary."
	var/Stored_Icon
	hotbar_type="Transformation"
	can_hotbar=1
	var/Old_cyber_bp=0

	verb/Hotbar_use()
		set hidden=1
		Scrap_Absorb()

	verb/Scrap_Absorb()
		set category = "Skills"
		if(Using) return
		usr << "This will only work on scraps from androids created over 30 minutes ago"
		for(var/obj/Android_Scraps/A in android_scraps)
			if(getdist(usr,A)<=20 && viewable(usr,A,20) && A.can_absorb_these_scraps)
				if(!A.Owner || A.Owner == usr) continue
				player_view(15,usr)<<"[usr] begins absorbing the scraps of [A.Owner]!"
				usr.Knowledge = Math.Max(usr.Knowledge, A.knowledge)
				var/Amount=A.cyber_bp*0.2
				if(A.Owner!=usr) A.Owner.Death(null,1)
				if(A.Owner == usr) Amount *= 0.2
				if(usr.Ki<usr.max_ki) usr.Ki=usr.max_ki
				if(usr.Health<100) usr.Health=100
				usr.cyber_bp+=Amount
				usr.absorbedCyberBP += Amount
				Scraps_Assemble(usr)
				break

mob/var/absorbedCyberBP

obj/Android_Scraps
	icon='Android Scraps.dmi'
	density=1
	Savable=0
	takes_gradual_damage=1
	can_blueprint = 0
	var/cyber_bp=0
	var/knowledge=0
	var/scrap_creation_time=0
	var/can_absorb_these_scraps=1

	New()
		android_scraps ||= list()
		android_scraps |= src
		pixel_x=rand(-6,6)
		pixel_y=rand(-6,6)
		spawn(3000) if(src) del(src)

	Del()
		android_scraps-=src
		. = ..()

var/list/android_scraps=new

mob/proc/Scrap_Absorb_Revert_Timer(obj/Skills/Special/Scrap_Absorb/A)
	set waitfor=0
	if(!A) for(var/obj/Skills/Special/Scrap_Absorb/O in src) if(O.Using) A=O
	if(!A) return
	sleep(900)
	if(src && A && A.Using) Scrap_Absorb_Revert(A)

mob/proc/Scrap_Absorb_Revert(obj/Skills/Special/Scrap_Absorb/A)
	if(!A) for(var/obj/Skills/Special/Scrap_Absorb/O in src) if(O.Using) A=O
	if(A)
		cyber_bp=A.Old_cyber_bp
		icon=A.Stored_Icon
	else if(scrap_absorb_mode)
		cyber_bp = 0
		spawn alert(src,"Nice try")
	scrap_absorb_mode = 0
	if(A) A.Using=0

proc/Spread_Scraps(mob/m)
	var/cyber_bp=m.cyber_bp
	var/Knowledge=m.Knowledge
	var/BP=m.BP
	var/base_bp=m.base_bp
	var/mob_creation_time=m.mob_creation_time
	var/mob/o_mob=m
	var/is_drone
	if(m.drone_module&&!m.client) is_drone=1
	m=m.base_loc()
	if(!m) return
	for(var/obj/Android_Scraps/AS in view(5,m)) if(AS.cyber_bp==cyber_bp) return
	Explosion_Graphics(m,1,10)
	var/obj/Android_Scraps/A=new
	A.scrap_creation_time=world.time

	if(world.realtime - mob_creation_time < 30 * 60 * 10) A.can_absorb_these_scraps=0

	A.cyber_bp=cyber_bp
	A.knowledge=Knowledge
	A.Health = BP * 6.5
	if(A.Health < base_bp + cyber_bp) A.Health = base_bp + cyber_bp
	if(is_drone) A.Health/=2
	for(var/v in 1 to 7)
		var/image/i=image(icon=A.icon,pixel_x=rand(-5,5),pixel_y=rand(-5,5))
		if(v<=5) i.icon_state="[v]"
		else
			i.icon_state="6"
			i.dir=pick(NORTH,SOUTH,EAST,WEST,NORTHWEST,NORTHEAST,SOUTHWEST,SOUTHEAST)
		A.overlays+=i
	A.icon=null
	A.Owner=o_mob
	A.SafeTeleport(m)

mob/proc/Scraps_Exist()
	for(var/obj/Android_Scraps/A in android_scraps)
		if(A.Owner==src&&world.time-A.scrap_creation_time<8*60*10)
			return A

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
/*
zombies arent reproducing or mutating correctly

add zombie sounds
*/

mob/proc
	InfectedPlayerHitDeadBodyItBecomesZombie(mob/Body/dead_body)
		set waitfor=0
		if(Zombie_Virus) //we use this if we want players AND zombies to be able to make dead bodies into zombies just by hitting them
		//if(istype(src,/mob/Enemy/Zombie)) //we use this if we only want zombies to be able to turn dead bodies into zombies by hitting them
			if(istype(dead_body,/mob/Body))
				if(dead_body.hit_by_zombie) return //no need to spam it theyve already been hit
				dead_body.hit_by_zombie = 1
				dead_body.Zombie_Virus++
				dead_body.Zombies(timer = 600)

mob/var/Zombie_Immune=0
mob/var/Flyer
mob/var/Zombie_Virus=0
mob/var/Zombie_Power=0
mob/proc/Mutate(A)
	if(!A) A=rand(2,13)
	Flyer=0
	//NPC Scorpion 2.dmi, NPC Spider 3.dmi, NPC Snake.dmi
	//RP_Power, Str, Dur, Res, Spd, Off, Def
	if(A==2)
		name="Zombie Dog"
		icon='Zombie Dog.dmi'
		BP*=1.2
		Spd*=1.2
		spdmod*=1.2
	if(A==3)
		name="Licker"
		icon='Zombie Licker.dmi'
		Zombie_Virus=5
		BP*=1.5
		Spd*=1.5
		spdmod*=1.5
		Off*=1.5
		offmod*=1.5
		npc_move_delay=2.5
		if(prob(20))
			Enlarge_Icon(48,48)
			CenterIcon(src)
	if(A==4)
		name="Hunter"
		icon='Zombie Hunter.dmi'
		Zombie_Virus=1
		BP*=1.5
		Str*=2
		strmod*=2
		End*=1.5
		endmod*=1.5
		Res*=0.5
		resmod*=0.5
		if(prob(20))
			Enlarge_Icon(48,48)
			CenterIcon(src)
	if(A==5)
		name="Tyrant"
		icon='Zombie Tyrant.dmi'
		Zombie_Virus=20
		BP*=2
		End*=1.5
		endmod*=1.5
		Spd*=1.5
		spdmod*=1.5
	if(A==6)
		name="Nemesis"
		icon='Zombie Nemesis.dmi'
		Zombie_Virus=1
		BP*=2
		End*=3
		endmod*=3
		Str*=1.5
		strmod*=1.5
		Res*=3
		resmod*=3
		npc_move_delay=7
		if(prob(30))
			Enlarge_Icon(48,48)
			CenterIcon(src)
	if(A==7)
		name="Mr X"
		icon='Zombie X.dmi'
		Zombie_Virus=10
		BP*=3
		spdmod*=2
		Spd*=2
		Off*=2
		offmod*=2
	if(A==8)
		name="Thanatos"
		icon='Zombie Thanatos.dmi'
		Zombie_Virus=10
		BP*=3
		Str*=2
		strmod*=2
		Spd*=1.5
		spdmod*=1.5
		npc_move_delay=4
	if(A==9)
		name="Gargoyle"
		icon='Gargoyle.dmi'
		Zombie_Virus=1
		endmod*=0.5
		End*=0.5
		Res*=0.2
		resmod*=0.2
		Spd*=3
		spdmod*=3
		Flyer=1
	if(A==10)
		name="Reptile Zombie"
		icon='NPC Reptile Monster.dmi'
		Zombie_Virus=1
		BP*=1.3
		Spd*=2
		spdmod*=2
		Res*=0.5
		resmod*=0.5
	if(A==11)
		name="Snake Zombie"
		icon='NPC Snake.dmi'
		Zombie_Virus=0.5
		Spd*=3
		spdmod*=3
	if(A==12)
		name="Scorpion Zombie"
		icon='NPC Scorpion 2.dmi'
		Zombie_Virus*=0.5
		End*=3
		endmod*=3
		Enlarge_Icon(48,48)
		CenterIcon(src)
	if(A==13)
		name="Spider Zombie"
		icon='NPC Spider 3.dmi'
		Zombie_Virus=2
		Spd*=3
		spdmod*=3
		Off*=2
		offmod*=2
		Enlarge_Icon(48,48)
		CenterIcon(src)
	Level=A //This is used by the DNA detector to see what it is supposed to get from the zombie.
	overlays-=overlays
	spawn if(src&&type!=/mob/Enemy/Zombie) Zombie_Initialize()
mob/var/Has_DNA=1

obj/items/DNA_Container
	Cost=20000000
	icon='Item, DNA Extractor.dmi'
	desc="This can be used to store DNA from whoever you use it on. Which can be used to clone them. You can \
	only use this on someone who is knocked out or paralyzed. After it has DNA in it, you can go to a Genetics \
	Computer and use it to make a clone, and possibly more."
	Stealable=1
	era_reset_immune=0
	clonable = 0
	var/mob/Clone
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Use()
	verb/Use()
		var/mob/A=usr
		for(var/mob/A2 in Get_step(usr,usr.dir)) if(A2.Frozen||A2.KO||!A2.client)
			A=A2
			break
		if(A in All_Entrants)
			usr<<"You can not take DNA from people enrolled in tournaments"
			return
		if(!A.Has_DNA)
			usr<<"[A] has no usable DNA"
			return
		if(A.Class=="Legendary Yasai")
			usr<<"The legendary Yasai gene is impossible to clone"
			return
		if(A.Race=="Majin")
			usr<<"Majins are not clonable"
			return
		if(A.Android)
			usr<<"[A] is an Android, they have no DNA"
			return
		if(A.Dead)
			usr<<"[A] is dead and therefore does not have DNA"
			return
		if(Clone) switch(input("This already contains DNA do you really want to overwrite it?") in list("No","Yes"))
			if("No") return
		player_view(15,usr)<<"[usr] extracts DNA from [A]"
		if(istype(A,/mob/Enemy/Zombie))
			var/obj/O=A.Zombie_Drop()
			if(O)
				usr<<"You recieved [O]"
				O.Move(usr)
				//del(src)
		name="DNA of [A.name]"
		Clone=A.Clone()
		//you can bug your bp super high since trolls go beyond players
		if(istype(Clone, /mob/new_troll))
			Clone.base_bp *= 0.1
			Clone.hbtc_bp *= 0.1
			Clone.cyber_bp *= 0.1
			Clone.max_ki *= 0.1

mob/proc/Zombie_Drop()
	var/obj/O
	if(Level==1) O=new/obj/items/Antivirus(Get_step(src,dir)) //Regular
	if(Level==2) O=new/obj/items/T_Energy(Get_step(src,dir)) //Dog
	if(Level==3) O=new/obj/items/T_Heal(Get_step(src,dir)) //Licker
	if(Level==4) O=new/obj/items/T_Vitality(Get_step(src,dir)) //Hunter
	if(Level==5) O=new/obj/items/T_Strength(Get_step(src,dir)) //Tyrant
	if(Level==6) O=new/obj/items/T_Fusion(Get_step(src,dir)) //Nemesis
	if(Level==7) O=new/obj/items/T_Undying(Get_step(src,dir)) //Mr X
	if(Level==8) O=new/obj/items/T_Life(Get_step(src,dir)) //Thanatos
	if(Level==9) O=new/obj/items/T_Regeneration(Get_step(src,dir)) //Gargoyle
	if(Level==10) O=new/obj/items/T_Recovery(Get_step(src,dir)) //Reptile
	if(Level==11) O=new/obj/items/T_Snake(Get_step(src,dir)) //Snake
	if(Level==12) O=new/obj/items/T_Scorpion(Get_step(src,dir)) //Scorpion
	if(Level==13) O=new/obj/items/T_Spider(Get_step(src,dir)) //Spider
	return O
mob/proc
	Undo_all_t_injections()
		Apply_t_spider(1)
		Apply_t_scorpion(1)
		Apply_t_snake(1)
		Apply_t_recovery(1)
		Apply_t_regeneration(1)
		Apply_t_undying(1)

	Apply_t_injections(list/l)
		if(!l||!l.len) return
		for(var/v in l)
			switch(v)
				if("Spider") Apply_t_spider()
				if("Scorpion") Apply_t_scorpion()
				if("Snake") Apply_t_snake()
				if("Recovery") Apply_t_recovery()
				if("Regeneration") Apply_t_regeneration()
				if("Undying") Apply_t_undying()

	Apply_t_spider(remove=0)
		if(remove)
			if("Spider" in T_Injections)
				T_Injections-="Spider"
				Str/=1.2
				strmod/=1.2
				Off/=1.2
				offmod/=1.2
				Res*=1.44
				resmod*=1.44
				Original_Decline/=0.9
				Decline/=0.9
		else
			if(!("Spider" in T_Injections))
				T_Injections+="Spider"
				Str*=1.2
				strmod*=1.2
				Off*=1.2
				offmod*=1.2
				Res/=1.44
				resmod/=1.44
				Original_Decline*=0.9
				Decline*=0.9

	Apply_t_scorpion(remove=0)
		if(remove)
			if("Scorpion" in T_Injections)
				T_Injections-="Scorpion"
				Off/=1.2
				offmod/=1.2
				Def*=1.2
				defmod*=1.2
				Original_Decline/=0.9
				Decline/=0.9
		else
			if(!("Scorpion" in T_Injections))
				T_Injections+="Scorpion"
				Off*=1.2
				offmod*=1.2
				Def/=1.2
				defmod/=1.2
				Original_Decline*=0.9
				Decline*=0.9

	Apply_t_snake(remove=0)
		if(remove)
			if("Snake" in T_Injections)
				T_Injections-="Snake"
				Spd/=1.2
				spdmod/=1.2
				Def*=1.2
				defmod*=1.2
				Original_Decline/=0.9
				Decline/=0.9
		else
			if(!("Snake" in T_Injections))
				T_Injections+="Snake"
				Spd*=1.2
				spdmod*=1.2
				Def/=1.2
				defmod/=1.2
				Original_Decline*=0.9
				Decline*=0.9

	Apply_t_recovery(remove=0)
		if(remove)
			if("Recovery" in T_Injections)
				T_Injections-="Recovery"
				recov/=2
				Ki/=0.5
				max_ki/=0.5
				Eff/=0.5
				Original_Decline/=0.8
				Decline/=0.8
		else
			if(!("Recovery" in T_Injections))
				T_Injections+="Recovery"
				recov*=2
				Ki*=0.5
				max_ki*=0.5
				Eff*=0.5
				Original_Decline*=0.8
				Decline*=0.8

	Apply_t_regeneration(remove=0)
		if(remove)
			if("Regeneration" in T_Injections)
				T_Injections-="Regeneration"
				regen/=2
				Pow/=0.25
				formod/=0.25
				Original_Decline/=0.8
				Decline/=0.8
		else
			if(!("Regeneration" in T_Injections))
				T_Injections+="Regeneration"
				regen*=2
				Pow*=0.25
				formod*=0.25
				Original_Decline*=0.8
				Decline*=0.8
	Apply_t_undying(remove=0)
		if(remove)
			if("Undying" in T_Injections)
				T_Injections-="Undying"
				Regenerate-=1.3
				Res/=0.75
				resmod/=0.75
				Original_Decline/=0.8
				Decline/=0.8
		else
			if(!("Undying" in T_Injections))
				T_Injections+="Undying"
				Regenerate+=1.3
				Res*=0.75
				resmod*=0.75
				Original_Decline*=0.8
				Decline*=0.8
obj/items/T_Spider
	Stealable=1
	desc="x1.2 Strength. 1.2x Accuracy. /1.44 Resistance. Get the advantage and disadvantage of a spider! \
	Also gives a BP boost roughly worth 20 minutes of sparring."
	icon='Item, Needle.dmi'
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Use()
	verb/Use()
		var/mob/A=usr.get_inject()
		if(!A) return
		if(A.Redoing_Stats)
			usr<<"They must finish redoing their stats first"
			return
		if(A.Android)
			usr<<"This has no effect on androids"
			return
		if(!("Spider" in A.T_Injections))
			A.Apply_t_spider()
			player_view(15,usr)<<"[usr] injects [A] with a mysterious needle!"
			del(src)
		else usr<<"[A] has already used [src]"
obj/items/T_Scorpion
	Stealable=1
	desc="x1.2 Accuracy. /1.2 Reflex. Get the advantage and disadvantage of a scorpion! Also gives a BP boost \
	roughly worth 20 minutes of sparring."
	icon='Item, Needle.dmi'
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Use()
	verb/Use()
		var/mob/A=usr.get_inject()
		if(!A) return
		if(A.Redoing_Stats)
			usr<<"They must finish redoing their stats first"
			return
		if(!("Scorpion" in A.T_Injections))
			A.Apply_t_scorpion()
			player_view(15,usr)<<"[usr] injects [A] with a mysterious needle!"
			del(src)
		else usr<<"[A] has already used [src]"
obj/items/T_Snake
	Stealable=1
	desc="x1.2 Speed. /1.2 Reflex. Get the advantage and disadvantage of a snake! Also gives a BP boost roughly \
	worth 20 minutes of sparring."
	icon='Item, Needle.dmi'
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Use()
	verb/Use()
		var/mob/A=usr.get_inject()
		if(!A) return
		if(A.Redoing_Stats)
			usr<<"They must finish redoing their stats first"
			return
		if(!("Snake" in A.T_Injections))
			A.Apply_t_snake()
			player_view(15,usr)<<"[usr] injects [A] with a mysterious needle!"
			del(src)
		else usr<<"[A] has already used [src]"
obj/items/T_Recovery
	Stealable=1
	desc="Doubles recovery but halves energy."
	icon='Item, Needle.dmi'
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Use()
	verb/Use()
		var/mob/A=usr.get_inject()
		if(!A) return
		if(A.Redoing_Stats)
			usr<<"They must finish redoing their stats first"
			return
		if(A.Android)
			usr<<"This has no effect on androids"
			return
		if(!("Recovery" in A.T_Injections))
			A.Apply_t_recovery()
			player_view(15,usr)<<"[usr] injects [A] with a mysterious needle!"
			del(src)
		else usr<<"[A] has already used [src]"
obj/items/T_Regeneration
	Stealable=1
	desc="Doubles regeneration and divides force by 4 permanently making energy almost useless."
	icon='Item, Needle.dmi'
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Use()
	verb/Use()
		var/mob/A=usr.get_inject()
		if(!A) return
		if(A.Redoing_Stats)
			usr<<"They must finish redoing their stats first"
			return
		if(!("Regeneration" in A.T_Injections))
			A.Apply_t_regeneration()
			player_view(15,usr)<<"[usr] injects [A] with a mysterious needle!"
			del(src)
		else usr<<"[A] has already used [src]"
obj/items/T_Energy
	Stealable=1
	desc="Raises energy to a certain level if it is below that level."
	icon='Item, Needle.dmi'
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Use()
	verb/Use()
		var/mob/A=usr.get_inject()
		if(!A) return
		if(A.Redoing_Stats)
			usr<<"They must finish redoing their stats first"
			return
		if(A.max_ki<4000*A.Eff)
			A.max_ki=4000*A.Eff
			A.Original_Decline*=0.8
			A.Decline*=0.8
			player_view(15,usr)<<"[usr] injects [A] with a mysterious needle!"
			del(src)
		else usr<<"[A]'s energy is too high already to use this, it will do nothing for them"
obj/items/T_Vitality
	Stealable=1
	desc="Raises durability and resistance immensely."
	icon='Item, Needle.dmi'
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Use()
	verb/Use()
		var/mob/A=usr.get_inject()
		if(!A) return
		if(A.Redoing_Stats)
			usr<<"They must finish redoing their stats first"
			return
		if(!("Vitality" in A.T_Injections))
			A.T_Injections+="Vitality"
			usr.Raise_Stats(1800,"Durability")
			usr.Raise_Stats(1800,"Resistance")
			A.Original_Decline*=0.8
			A.Decline*=0.8
			player_view(15,usr)<<"[usr] injects [A] with a mysterious needle!"
			del(src)
		else usr<<"[A] has already used [src]"

obj/items/T_Heal
	Stealable=1
	desc="Temporarily speeds up regeneration when used."
	icon='Item, Needle.dmi'
	var/tmp/injecting

	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Use()

	verb/Use()
		if(injecting) return

		var/mob/A=usr.get_inject()
		if(!A) return

		injecting = 1
		if(A == usr)
			var/turf/t = A.loc
			var/elapsed_time = 0
			var/required_time = 3.2
			usr << "<font color=cyan>Do not move for [required_time] seconds to complete the injection"
			while(A && t == A.loc)
				elapsed_time += 0.2
				sleep(2)
				if(elapsed_time >= required_time) break
			if(!A) return
			if(t != A.loc) return

		if(A.Redoing_Stats)
			usr<<"They must finish redoing their stats first"
			return
		if(A.Android)
			usr<<"This has no effect on androids"
			return
		if(A.tournament_override(fighters_can=0))
			usr<<"These are illegal in the tournament"
			return
		A.Alter_regen_mult(5)
		A.UnKO()
		player_view(15,usr)<<"[usr] injects [A] with a mysterious needle!"
		del(src)

obj/items/T_Fusion
	Stealable=1

	desc="This will increase your battle power but it will slowly wear off. You will be immune to the t virus while \
	this is active. No amount of damage you take will slow you down. The downside is that a bio field generator \
	will kill you like it would a zombie, and there is a 10% chance that injecting this will kill you, and your \
	BP gains will be lowered 10%."

	icon='Item, Needle.dmi'

	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Use()

	verb/Use()
		var/mob/A=usr.get_inject()
		if(!A) return
		if(A.Redoing_Stats)
			usr<<"They must finish redoing their stats first"
			return
		if(A.Android)
			usr<<"This has no effect on androids"
			return
		var/bp=highest_base_and_hbtc_bp**0.6 * 50
		bp=Clamp(bp,highest_base_and_hbtc_bp*0.1,highest_base_and_hbtc_bp*0.2)
		if(A.Zombie_Power<bp) A.Zombie_Power=bp
		A.overlays-='Red Eyes.dmi'
		A.overlays+='Red Eyes.dmi'
		player_view(15,usr)<<"[usr] injects [A] with a mysterious needle!"
		if(prob(10)) usr.Death("???",Force_Death=1)
		del(src)

mob/proc/ClearTFusion()
	if(!Zombie_Power) return
	overlays -= 'Red Eyes.dmi'
	Zombie_Power = 0

obj/items/T_Strength
	Stealable=1
	desc="This will greatly increase strength and speed if they are under certain levels."
	icon='Item, Needle.dmi'
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Use()
	verb/Use()
		var/mob/A=usr.get_inject()
		if(!A) return
		if(A.Redoing_Stats)
			usr<<"They must finish redoing their stats first"
			return
		if(!("Strength" in A.T_Injections))
			A.T_Injections+="Strength"
			usr.Raise_Stats(1800,"Strength")
			usr.Raise_Stats(1800,"Speed")
			A.Original_Decline*=0.8
			A.Decline*=0.8
			player_view(15,usr)<<"[usr] injects [A] with a mysterious needle!"
			del(src)
		else usr<<"[A] has already used [src]"
obj/items/T_Undying
	Stealable=1
	desc="This will boost your death regeneration by 1.3 points (which is a lot), but result in a 25% loss of resistance."
	icon='Item, Needle.dmi'
	verb/Hotbar_use()
		set hidden=1
		Use()
	verb/Use()
		var/mob/A=usr.get_inject()
		if(!A) return
		if(A.Redoing_Stats)
			usr<<"They must finish redoing their stats first"
			return
		if(A.Android)
			usr<<"This has no effect on androids"
			return
		if(!("Undying" in A.T_Injections))
			A.Apply_t_undying()
			player_view(15,usr)<<"[usr] injects [A] with a mysterious needle!"
			del(src)
		else usr<<"[A] has already used [src]"
obj/items/T_Life
	Stealable=1
	desc="This will slow your decline IMMENSELY. Extending your lifespan nearly 4x its normal amount."
	icon='Item, Needle.dmi'
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Use()
	verb/Use(mob/A in view(1,usr)) if(A) if(A==usr||A.Frozen||A.KO)
		if(A.Redoing_Stats)
			usr<<"They must finish redoing their stats first"
			return
		if(A.Android)
			usr<<"This has no effect on androids"
			return
		if(!("Life" in A.T_Injections))
			A.T_Injections+="Life"
			A.Decline_Rate*=0.25
			A.Original_Decline*=0.8
			A.Decline*=0.8
			player_view(15,usr)<<"[usr] injects [A] with a mysterious needle!"
			del(src)
		else usr<<"[A] has already used [src]"
mob/var/list/T_Injections=new

mob/var
	Infected_players=0
	Infected_z=0

mob/proc/Zombie_Virus_Loop()
	set waitfor=0
	sleep(1)
	while(src)
		var/delay=20
		if(Is_Cybernetic()) delay*=3
		if(!Zombie_Virus)
			Infected_players=0
			Infected_z=0
			delay*=5
		else
			if(!Infected_z) Infected_z=z
			if(Zombie_virus_activated())
				Zombie_Virus+=0.3
				Health-=Zombie_Virus*0.2
				if(Health<=0||KO) Death("???!")

		//if((z==7 && !Tournament) || Zombie_Virus < 0 || Zombie_Power || Android || Zombie_Immune) Zombie_Virus=0
		if(Zombie_Virus < 0 || Zombie_Power || Android || Zombie_Immune) Zombie_Virus=0

		if(Zombie_Power)
			Zombie_Power*=0.9998
			Zombie_Power-=1
			if(Zombie_Power<1)
				Zombie_Power=0
				overlays-='Red Eyes.dmi'

		sleep(delay)

mob/proc/Zombie_virus_activated()
	if(Tournament) for(var/obj/Fighter_Spot/fs in Fighter_Spots) if(getdist(src,fs)<50&&fs.z==z)
		return
	for(var/mob/m in player_view(8,src)) if(m.client&&m!=src)
		var/nearby_players=0
		for(var/mob/m2 in view(5,src)) if(m2.client&&m2!=src) nearby_players++
		if(Infected_players>=4||nearby_players>=5||(nearby_players>=1&&Infected_z!=z&&z)) return 1
		break

mob/proc/Zombies(Can_Mutate=1,timer=150)
	set waitfor=0
	sleep(timer)
	if(src && Zombie_Virus)
		if(!z) return
		var/mob/Enemy/Zombie/Z=Zombie_Copy()
		Z.overlays+='Zombie.dmi'
		Z.underlays-='Pool of Blood.dmi'
		Z.name="Zombie"
		Z.Level=1
		del(src)

mob/var/Children=0 //How many times the zombie reproduced

mob/proc/zombie_reproduce()
	if(Level!=1) return
	if(active_zombie_list.len >= Max_Zombies)
		/*for(var/mob/m in active_zombie_list) if(m.loc)
			m.SafeTeleport(loc)
			m.update_area()
			break*/
	else
		Zombie_Copy()
		Children++

var/zombie_reproduce_mod=1

proc/Zombie_mutate_loop()
	set waitfor=0
	while(1)
		if(!active_zombie_list.len) sleep(600)
		else
			var/mutated=0
			var/regular=0
			for(var/mob/z in active_zombie_list)
				if(z.Level==1) regular++
				else mutated++
			if(mutated/(regular+mutated)<0.25)
				var/mob/Enemy/Zombie/z=pick(active_zombie_list)
				if(z&&ismob(z)&&z.z) z.Mutate()
			sleep(600)

proc/Zombie_reproduce_loop()
	set waitfor=0
	while(1)
		if(!active_zombie_list.len) sleep(50)
		else
			if(zombie_reproduce_mod <= 0)
				sleep(100)
			else
				for(var/area/a3 in all_areas) if(a3.name in destroyed_planets)
					var/count=0
					for(var/mob/Enemy/Zombie/z in a3.npc_list)
						count++
						del(z)
						if(count>=10) break
						sleep(1)

				var/area/a
				var/area_zombies=1.#INF
				for(var/area/a2 in all_areas) if(!(a2.name in destroyed_planets) && a2.zombies_can_reproduce_here)
					var/zombies=0
					for(var/mob/Enemy/Zombie/z in a2.npc_list) if(z.z&&z.Level==1) zombies++
					if(zombies&&zombies<area_zombies)
						a=a2
						area_zombies=zombies

				if(a) for(var/mob/Enemy/Zombie/z in a.npc_list)
					if(!z.KO&&z.z&&z.Level==1 && !z.super_antivirused)
						active_zombie_list-=z
						active_zombie_list+=z //send to end of list
						z.zombie_reproduce()
						break
				var/timer=300
				if(timer<100) timer=100
				timer/=zombie_reproduce_mod

				sleep(TickMult(timer))
var/list/active_zombie_list=new

mob/proc/Zombie_Lifespan() return

mob/proc/Zombie_Initialize()
	Zombie_Door_Attack()
	Zombie_Lifespan()
	Zombie_update_area()

mob/proc/Zombie_update_area()
	set waitfor=0
	var/old_z=z
	while(src)
		if(z!=old_z) update_area()
		old_z=z
		sleep(600)

mob/proc/Zombie_Copy()
	var/mob/Enemy/Zombie/Q=get_cached_zombie()

	Q.feat_bp_multiplier = feat_bp_multiplier

	Q.SafeTeleport(loc)
	Q.update_area()
	Q.Enlarged=Enlarged
	Q.Zombie_Virus=Zombie_Virus
	Q.Flyer=Flyer

	Q.BP=BP
	Q.Body=Body
	Q.gravity_mastered=gravity_mastered
	Q.base_bp=base_bp
	Q.hbtc_bp = hbtc_bp
	Q.cyber_bp = cyber_bp
	Q.bp_mod=bp_mod
	Q.Str=Str
	Q.End=End
	Q.Res=Res
	Q.Spd=Spd
	Q.Off=Off
	Q.Def=Def
	Q.strmod=strmod
	Q.endmod=endmod
	Q.resmod=resmod
	Q.spdmod=spdmod
	Q.offmod=offmod
	Q.defmod=defmod
	Q.regen=regen
	Q.recov=recov

	Q.icon=icon
	Q.overlays=overlays
	Q.name=name
	Q.Level=Level

	//remember zombies move slow already and have no defense so they dont need lowered dura/resist too it makes them too killable
	if(!istype(src,/mob/Enemy/Zombie))
		Q.Str*=3
		Q.strmod*=3
		Q.Off*=3
		Q.offmod*=3
		Q.Spd/=2
		Q.spdmod/=2
		Q.End *= 1.1
		Q.endmod *= 1.1
		Q.Res *= 1.1
		Q.resmod *= 1.1
		Q.Def/=5
		Q.defmod/=5

	//Q.Target=src
	for(var/obj/Stun_Chip/A in src)
		var/obj/Stun_Chip/B=new(Q)
		B.Password=A.Password
	Q.update_area()

	var/from_body = istype(src,/mob/Body)
	if(from_body) //only do the initial bp calculation if this zombie came from a body, so that zombies kids inherit their parents
	//power directly, rather than having their bp recalculated below, which was bypassing the zombie_power_mult admin setting
	//so that zombie children had 1x power instead of respecing zombie_power_mult
		Q.BP = Q.CalculateZombieBP(from_body)

	return Q

mob/proc
	CalculateZombieBP(from_body = 0)
		var
			n = BP
			n2 = effectiveBaseBp
		if(n2 > n) n = n2
		n += cyber_bp
		if(from_body) n *= zombie_power_mult
		return n

mob/proc/Zombie_Door_Attack()
	set waitfor=0
	while(src)
		if(prob(50) && z)
			var/obj/D
			for(var/obj/Turfs/Door/T in view(5,src))
				D=T
				break
			if(D)
				var/Steps=rand(0,200)
				while(Steps&&D&&D.density)
					Steps-=1
					step_towards(src,D)
					Melee()
					sleep(3)
		sleep(rand(0,6000))
//var/Zombies=0


var/list/zombie_cache=new
mob/proc/cache_zombie()
	if(grabber) grabber.ReleaseGrab()
	SafeTeleport(null)
	zombie_cache-=src
	zombie_cache+=src
	update_area()

proc/get_cached_zombie()
	for(var/mob/z in zombie_cache)
		ResetVars(z)
		zombie_cache-=z
		active_zombie_list+=z
		return z
	return new/mob/Enemy/Zombie

var/list/all_zombies = new

mob/Enemy/Zombie
	brain_transplant_allowed=0
	npc_money_mod=3
	Zombie_Virus=1
	Spawn_Timer=0
	Savable_NPC=1
	Enlargement_Chance=0
	Dead_Zone_Immune=1
	Level=1
	New()
		Zombie_Initialize()
		all_zombies += src
		active_zombie_list -= src
		active_zombie_list += src
		spawn(30) if(src) update_area()
		. = ..()
	Del()
		active_zombie_list-=src
		cache_zombie()
		//. = ..()

obj/items/T_Virus_Injection
	Cost=5000000
	makes_toxic_waste=1
	icon='T Virus.dmi'
	Level=1
	Stealable=1
	Injection=1
	desc="This is a virus that creates Zombies. Inject someone with it to infect them. Even dead bodies can be \
	brought back to life in a horrible way."
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Use()
	verb/Use()
		if(!usr) return
		var/mob/A = usr.get_inject()
		if(!A) return
		if(istype(A,/mob/Body))
			var/mob/Body/body=A
			if(body.was_zombie)
				usr<<"The cells of this body are fried, it can not be reanimated again"
				return
		player_view(15,usr)<<"[usr] injects [A] with a mysterious needle!"
		if(istype(A,/mob/Enemy/Zombie))
			if(A.Level==1) A.Mutate()
		else
			A.Zombie_Virus+=Level
			if(!A.client) A.Zombies(timer=600) //A zombie will bust out of A soon
		del(src)

obj/items/Super_Antivirus
	icon = 'Antivirus.dmi'
	icon_state = "red"
	desc = "If you inject this into a zombie it will spread across the entire planet killing all zombies rapidly. If you inject this into a player nothing will happen."
	Stealable = 1
	Level = 1
	clonable = 0
	Cost = 0 //must synthesize

	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Use()

	verb/Use()
		var/mob/m = usr.get_inject()
		if(!m) return
		if(!istype(m,/mob/Enemy/Zombie))
			usr << "You can only inject this into a zombie, otherwise it does nothing"
			return
		var/turf/t = usr.base_loc()
		if(t && isturf(t))
			player_view(15,usr) << "[usr] injects [src] with a super antivirus"
			StartSuperAntivirusAtLocation(usr.base_loc())
			del(src)

proc/StartSuperAntivirusAtLocation(turf/t)
	set waitfor=0
	var/area/a = t.get_area()
	DestroyAllInfectedBodiesOnPlanet(a)
	CureAllInfectedPlayersOnPlanet(a)

	for(var/mob/Enemy/Zombie/m in a.mob_list)
		var/dly = 20 + (getdist(m,t) * 1)
		m.InfectWithSuperAntivirus(delay = dly)

	for(var/v in 1 to 10)
		sleep(300)
		DestroyAllInfectedBodiesOnPlanet(a)
		CureAllInfectedPlayersOnPlanet(a)

mob/Enemy/Zombie/var/tmp/super_antivirused

mob/Enemy/Zombie/proc/InfectWithSuperAntivirus(delay = 0)
	set waitfor=0
	if(delay) sleep(delay)
	overlays += 'Flies.dmi'
	super_antivirused = 1
	sleep(150)
	if(z) Death("???")
	overlays -= 'Flies.dmi'
	super_antivirused = 0

proc/DestroyAllInfectedBodiesOnPlanet(area/a)
	set waitfor=0
	for(var/mob/Body/b in all_bodies)
		var/area/a2 = b.get_area()
		if(a2 == a) del(b)

proc/CureAllInfectedPlayersOnPlanet(area/a)
	set waitfor=0
	for(var/mob/m in a.mob_list) m.Zombie_Virus = 0

proc/GetZombiesOnPlanet(area/a)
	var/list/l = new
	for(var/mob/m in a.mob_list) if(istype(m,/mob/Enemy/Zombie)) l += m
	return l

obj/items/Antivirus
	icon='Antivirus.dmi'
	Stealable=1
	Level=1
	clonable = 0
	Cost=3000000

	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Use()

	verb/Use()
		var/mob/A=usr.get_inject()
		if(!A) return
		player_view(15,usr)<<"[usr] uses the [src] on [A] and all infection disappears"
		A.Zombie_Virus=0
		A.Diarea=0
		del(src)

	verb/Synthesize()
		set src in view(1)
		var/list/L=list("Cancel")
		var/int_price_mod=0.4
		//if(usr.Res()>=10000000/usr.Intelligence()**int_price_mod) L[new/obj/Bio_Field_Generator]=10000000/usr.Intelligence()**int_price_mod
		if(usr.Res()>=500000/usr.Intelligence()**int_price_mod) L[new/obj/items/T_Heal]=500000/usr.Intelligence()**int_price_mod
		if(usr.Res()>=2000000/usr.Intelligence()**int_price_mod) L[new/obj/items/T_Energy]=2000000/usr.Intelligence()**int_price_mod
		if(usr.Res()>=500000/usr.Intelligence()**int_price_mod) L[new/obj/items/T_Vitality]=500000/usr.Intelligence()**int_price_mod
		if(usr.Res()>=500000/usr.Intelligence()**int_price_mod) L[new/obj/items/T_Strength]=500000/usr.Intelligence()**int_price_mod
		if(usr.Res()>=500000/usr.Intelligence()**int_price_mod) L[new/obj/items/T_Fusion]=500000/usr.Intelligence()**int_price_mod
		if(usr.Res()>=5000000/usr.Intelligence()**int_price_mod) L[new/obj/items/T_Undying]=5000000/usr.Intelligence()**int_price_mod
		if(usr.Res()>=3000000/usr.Intelligence()**int_price_mod) L[new/obj/items/T_Life]=3000000/usr.Intelligence()**int_price_mod
		if(usr.Res()>=5000000/usr.Intelligence()**int_price_mod) L[new/obj/items/T_Regeneration]=5000000/usr.Intelligence()**int_price_mod
		if(usr.Res()>=5000000/usr.Intelligence()**int_price_mod) L[new/obj/items/T_Recovery]=5000000/usr.Intelligence()**int_price_mod
		if(usr.Res()>=5000000/usr.Intelligence()**int_price_mod) L[new/obj/items/T_Snake]=5000000/usr.Intelligence()**int_price_mod
		if(usr.Res()>=5000000/usr.Intelligence()**int_price_mod) L[new/obj/items/T_Scorpion]=5000000/usr.Intelligence()**int_price_mod
		if(usr.Res()>=5000000/usr.Intelligence()**int_price_mod) L[new/obj/items/T_Spider]=5000000/usr.Intelligence()**int_price_mod
		if(usr.Res() >= 30000000 / usr.Intelligence() ** int_price_mod) L[new/obj/items/Super_Antivirus] = 30000000 / usr.Intelligence() ** int_price_mod

		if(L.len<=1)
			usr<<"You can not afford any of the options within this."
			return

		var/obj/O = input("You can synthesize and mutate this into many different uses. Choose one below. \
		NOTE: Only ones you can afford appear in this list") in L
		if(!O||O=="Cancel"||usr.Res()<L[O]) return
		switch(alert("[O] costs [Commas(L[O])] resources. Accept?","Options","Yes","No"))
			if("No") return
		if(usr.Res()<L[O])
			usr<<"You no longer have the resources needed"
			return
		usr.Alter_Res(-L[O])
		if(istype(O,/obj/items))
			var/obj/o=new O.type
			o.Move(usr)
		else O.SafeTeleport(usr.loc)
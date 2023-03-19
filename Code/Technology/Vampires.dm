/*
vampires should be immortal

anti vampire weapons
*/

obj/Sunlight_Generator
	desc="Emits sunlight within a certain range. Get near it and click it to activate it. It will remain active \
	for a short time."
	Cost=20000000
	icon='PodArconia.dmi'
	var/tmp/On
	density=1
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

	Click() if(usr in view(1,src))
		if(!On)
			player_view(15,src)<<"[usr] activates the [src]."
			var/obj/Sunfield/S=new(loc)
			spawn while(S)
				S.SafeTeleport(loc)
				sleep(1)
			On=120
			while(On)
				On--
				for(var/mob/P in mob_view(5,src)) spawn if(P&&P.Vampire)
					if(P.Vampire_Monster||("vampire" in P.hell_agreements)||getdist(P,src)<=3)
						P.Death("sunlight generator!",1)
					else
						P.Health-=5
						if(P.KO&&P.Health<=20) P.Sunlight_Cure()
						if(P.Health<=0)
							if(!P.KO) P.KO()
							else if(P) P.Death("sunlight generator!")
				sleep(4)
			if(S) del(S)
		else
			player_view(15,src)<<"[usr] deactivates the [src]."
			On=0

mob/proc/Sunlight_Cure()
	set waitfor=0
	sleep(600)
	if(src&&!Dead) Vampire_Cure()

obj/Sunfield
	icon='Sunfield.dmi'
	Grabbable=0
	Health=1.#INF
	layer=10
	New()
		CenterIcon(src)
		spawn for(var/obj/Sunlight_Generator/S in loc)
			while(S) sleep(1)
			del(src)

obj/items/Daybreaker_Virus
	desc="Turns people into vampires."
	Cost=1000000
	icon='T Virus.dmi'
	Stealable=1
	Injection=1
	clonable = 0
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Use()
	verb/Use()
		if(!usr) return
		var/mob/A=usr.get_inject()
		if(!A) return
		if(!A.client)
			usr<<"This does nothing to npcs"
			return
		if(A.Former_Vampire)
			usr<<"It has no effect on this individual"
			return
		player_view(15,usr)<<"[usr] injects [A] with a mysterious needle!"
		if(!A.Vampire) A.Become_Vampire()
		else if(A.Vampire&&!A.Vampire_Monster) A.Become_Vampire_Monster()
		del(src)

mob/var/Vampire
mob/var/Vampire_Monster
mob/var/Former_Vampire //Cured human if true
mob/var/Vampire_Infection=0 //If this reaches 100% you turn into a monster
mob/var/Vampire_Power //multiplies BP

obj/Vampire_Bite
	desc="If you have this ability then you are a vampire. Vampires must feed on non-vampires, they get power \
	from doing this. If they do not feed, or if they feed on other vampires, it will cause their hunger to rise \
	even faster, \
	if it reaches 100% they will turn into a Vampire Monster, a vampire that feeds on other vampires as well \
	as non-vampires. Vampires with very high infection will lose control and automatically attack any non-vampires \
	in an attempt to get blood. Vampires have more power than non-vampires, and Vampire Monsters have more power \
	than vampires. If a Vampire Monster's infection reaches 100%, they die."
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Bite()
	hotbar_type="Ability"
	can_hotbar=1

	verb/Bite()
		set category="Skills"
		usr.Vampire_Bite(null,src)

	Del()
		var/mob/M=loc
		if(ismob(M)) M.Vampire_Revert()
		. = ..()

var
	vampire_power_mult=1.3
	vampire_eater_mult=1.6



mob/proc/Vampire_Bite(mob/P,obj/Vampire_Bite/V)
	if(!Vampire) del(V)
	if(!P)
		P=src
		for(var/mob/M in Get_step(src,dir)) if(M.KO)
			if(!M.key) src<<"Blood of NPCs has no effect"
			else P=M
			break
	if(P)

		if(P==src) return

		if(tournament_override(fighters_can=0)) return
		if(alignment_on&&both_good(P,src))
			src<<"You can not bite other good people"
			return
		if(P!=src&&P.client&&client&&P.client.address==client.address)
			src<<"You can not bite alts"
			return
		if(P.Android)
			src<<"Biting an android has no effect"
			return
		player_view(15,src)<<"[src] bites [P]!"
		if((P.Vampire&&!Vampire_Monster)||P==src)
			spawn blood_bags+=3
			Vampire_Power=vampire_power_mult
		else if(P.Former_Vampire) Vampire_Cure()
		else
			if(!Vampire_Monster)
				Vampire_Power=vampire_power_mult
				Vampire_Infection=0
			else
				Vampire_Power=vampire_eater_mult
				Vampire_Infection=0
		if(P!=src)
			blood_bags=0
			if(Health<100) Health=100
			if(Ki<max_ki) Ki=max_ki
		P.Become_Vampire()

mob/proc/Become_Vampire_Monster() if(Vampire&&!Vampire_Monster)
	if("vampire" in hell_agreements)
		src<<"You have died from starvation. Your deal with hell is now off and you are back to normal"
		Death(null,1)
	else
		Vampire_Monster=1
		Vampire_Power=vampire_eater_mult
		Vampire_Infection=0
		src<<"Your vampire infection has hit 100%, you have become a vampire monster, a vampire which can feed on \
		other vampires. This makes you more powerful than ever, but if your infection hits 100% again you will die."
		icon='Demon4.dmi'
		overlays-=overlays
		FullHeal()

mob/proc/Become_Vampire() if(!Vampire&&!Former_Vampire)
	var/obj/Vampire_Bite/V=new
	V.icon=icon
	contents+=V
	//if(icon in list('BaseHumanTan.dmi','BaseHumanPale.dmi')) icon='Demon6.dmi'
	//if(icon in list('New Tan Female.dmi','New Pale Female.dmi')) icon='Demon6, Female.dmi'
	Vampire=1
	Vampire_Power=vampire_power_mult
	Vampire_Infection=0
	src<<"You are now a vampire. You are more powerful but must bite people to survive and refill your \
	power."

mob/proc/Vampire_Cure() if(Vampire)
	Vampire_Revert()
	Former_Vampire=1
	src<<"You have become cured, and can never become a vampire again."

mob/proc/Vampire_Revert() if(Vampire)
	Vampire=0
	Vampire_Power=0
	Vampire_Infection=0
	Vampire_Monster=0
	blood_bags=0
	for(var/obj/Vampire_Bite/V in src)
		icon=V.icon
		del(V)
	src<<"You are no longer a vampire"

mob/proc/Vampire_Infection_Rise()
	set waitfor=0
	while(src)
		if(Vampire)
			if(Action!="Meditating")
				var/n=1*(blood_bags+1)
				if(base_bp<Avg_BP*1.5) n/=3
				if(Vampire_Monster) n*=2.5
				if(!Dead) Vampire_Infection+=n
				if(Vampire_Infection>100) Vampire_Infection=100
				if(Vampire_Monster&&!IsGreatApe())
					icon='Demon4.dmi'
				if(Vampire_Infection>=90) src<<"<font color=red>Warning: Vampire Infection at [Vampire_Infection]%"
				if(Vampire_Infection>=100&&!Dead)
					if(!Vampire_Monster) Become_Vampire_Monster()
					else
						src<<"Your vampire infection has reached its max and killed you"
						Vampire_Infection=0
						Death(null,1)
			sleep((2*60*60*10)/100) //Reach max infection in 2 hours
		else sleep(3000)
mob/proc/Vampire_Power_Fall()
	set waitfor=0
	while(src)
		if(Vampire)
			if(!Vampire_Monster)
				Vampire_Power-=0.00416 //240 minutes, 4 hours
				if(Vampire_Power<1) Vampire_Power=1
			else
				Vampire_Power-=0.00624
				if(Vampire_Power<0.2) Vampire_Power=0.2
		sleep(600)
mob/proc/Cured_Vampire_Ratio(N=0) //Shows the ratio of people online that are former vampires
	if(!Player_Count()) return 0
	for(var/mob/P in players) if(P.Former_Vampire) N++
	return N/Player_Count()
mob/proc/Born_Vampire_Check(N=0) if(Player_Count())
	if(Android) return
	for(var/mob/P in players) if(P.Vampire&&!P.Dead) N++
	N/=Living_Players()
	if(prob(N*100)) Become_Vampire()
proc/Living_Players(N=0)
	for(var/mob/M in players) if(!M.Dead) N++
	return N
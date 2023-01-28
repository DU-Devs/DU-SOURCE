/*
vampires should be immortal

There should be a way for humans to extract their blood, and others can extract their blood too if they are KO.
Extracted blood doesnt have the same "power" as biting a human, but will keep the vampire from turning into
a monster.

Sunlight Generator. Kills vampires who stay in it too long but if they are removed with only 20% life left
they will turn human

There may need to be more of an incentive for vampires to attack non-vampires if their infection is high
enough perhaps they go crazy and auto attack

vampires who auto attack from high infection should be able to be distracted if you drop a vial of blood,
including if you drop the vial in their contents, they will automatically use it

Perhaps artificial blood can be manufactured for a high enough cost but only the Omega rich will be able to
afford it

anti vampire weapons

if a vampire monster dies their body becomes a zombie

create the daybreaker virus science object
make sure it does not work on androids
*/
obj/Sunlight_Generator
	desc="Emits sunlight within a certain range. Get near it and click it to activate it. It will remain active \
	for a short time."
	Cost=1000000000
	icon='PodArconia.dmi'
	var/tmp/On
	density=1
	Click() if(usr in view(1,src))
		if(!On)
			view(src)<<"[usr] activates the [src]."
			var/obj/Sunfield/S=new(loc)
			spawn while(S)
				S.loc=loc
				sleep(1)
			On=120
			while(On)
				On--
				for(var/mob/P in view(5,src)) spawn if(P&&P.Vampire)
					if(P in view(1,src)) P.Death("sunlight generator!",1)
					else
						P.Health-=5
						if(P.KO&&P.Health<=20) P.Sunlight_Cure()
						if(P.Health<=0)
							if(!P.KO) P.KO()
							else spawn if(P) P.Death("sunlight generator!")
				sleep(5)
			if(S) del(S)
		else
			view(src)<<"[usr] deactivates the [src]."
			On=0
mob/proc/Sunlight_Cure() spawn(600) if(src&&!Dead) Vampire_Cure()
obj/Sunfield
	icon='Sunfield.dmi'
	Grabbable=0
	Health=1.#INF
	layer=10
	New()
		Center_Icon(src)
		spawn for(var/obj/Sunlight_Generator/S in loc)
			while(S) sleep(1)
			del(src)
obj/items/Daybreaker_Virus
	desc="Turns people into vampires."
	Cost=10000000
	icon='T Virus.dmi'
	Stealable=1
	Injection=1
	verb/Use(mob/A in view(1,usr))
		if(A==usr||A.KO||A.Frozen||!A.client)
			if(!A.client)
				usr<<"This does nothing to npcs"
				return
			if(A.Android)
				usr<<"Injecting them would have no effect because they are an Android"
				return
			if(A.Former_Vampire)
				usr<<"It has no effect on this individual"
				return
			view(usr)<<"[usr] injects [A] with a mysterious needle!"
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
	from doing this. If they do not feed, or if they feed on other vampires, their vampire infection will rise, \
	if it reaches 100% they will turn into a Vampire Monster, a vampire that feeds on other vampires as well \
	as non-vampires. Vampires with very high infection will lose control and automatically attack any non-vampires \
	in an attempt to get blood. Vampires have more power than non-vampires, and Vampire Monsters have more power \
	than vampires. If a Vampire Monster's infection reaches 100%, they die."
	verb/Bite()
		set category="Skills"
		usr.Vampire_Bite(null,src)
	Del()
		var/mob/M=loc
		if(ismob(M)) M.Vampire_Revert()
		..()
mob/proc/Vampire_Bite(mob/P,obj/Vampire_Bite/V)
	if(!Vampire) del(V)
	if(!P)
		P=src
		for(var/mob/M in get_step(src,dir)) if(M.KO)
			if(!M.key) src<<"Blood of NPCs has no effect"
			else P=M
			break
	if(P)
		if(src in All_Entrants)
			src<<"You can not bite people in tournaments"
			return
		if(P!=src&&P.client&&client&&P.client.address==client.address)
			src<<"You can not bite alts"
			return
		if(P.Android)
			src<<"Biting an android has no effect"
			return
		view(src)<<"[src] bites [P]!"
		if((P.Vampire&&!Vampire_Monster)||P==src)
			Vampire_Infection+=10
			Vampire_Power=1.5
		else if(P.Former_Vampire) Vampire_Cure()
		else
			if(!Vampire_Monster)
				Vampire_Power=1.5
				Vampire_Infection=0
			else
				Vampire_Power=2
				Vampire_Infection=0
		if(P!=src)
			if(Health<100) Health=100
			if(Ki<Max_Ki*2) Ki=Max_Ki*2
		P.Become_Vampire()
mob/proc/Become_Vampire_Monster() if(Vampire&&!Vampire_Monster)
	Vampire_Monster=1
	Vampire_Power=2
	Vampire_Infection=0
	src<<"Your vampire infection has hit 100%, you have become a vampire monster, a vampire which can feed on \
	other vampires. This makes you more powerful than ever, but if your infection hits 100% again you will die."
	icon='Demon4.dmi'
	overlays-=overlays
	Full_Heal()
mob/proc/Become_Vampire() if(!Vampire&&!Former_Vampire)
	var/obj/Vampire_Bite/V=new
	V.icon=icon
	contents+=V
	if(icon in list('New Tan Male.dmi','New Pale Male.dmi')) icon='Demon6.dmi'
	if(icon in list('New Tan Female.dmi','New Pale Female.dmi')) icon='Demon6, Female.dmi'
	Vampire=1
	Vampire_Power=1.5
	Vampire_Infection=0
	src<<"You have become a vampire. You are more powerful than ever but must occasionally feed on blood using \
	the bite ability. If you do not, two things will happen: 1) Your vampire power will gradually go down until \
	you are no more powerful than a non-vampire. 2) Your vampire infection will rise and if it hits 100% you will \
	become an even more powerful monster which feeds on both vampires and non-vampires. There are disadvantages to \
	being a vampire monster, such as: 1) Your appearance will change. 2) If your infection hits 100% again you will \
	die. 3) You must feed more often to keep the infection down."
mob/proc/Vampire_Cure() if(Vampire)
	Vampire_Revert()
	Former_Vampire=1
	src<<"You have become cured, and can never become a vampire again."
mob/proc/Vampire_Revert() if(Vampire)
	Vampire=0
	Vampire_Power=0
	Vampire_Infection=0
	Vampire_Monster=0
	for(var/obj/Vampire_Bite/V in src)
		icon=V.icon
		del(V)
	src<<"You are no longer a vampire"
mob/proc/Vampire_Infection_Rise() spawn while(src)
	if(Vampire)
		if(Action!="Meditating")
			Vampire_Infection++
			if(Vampire_Monster)
				Vampire_Infection++
				icon='Demon4.dmi'
			if(Vampire_Infection>=90) src<<"<font color=red>Warning: Vampire Infection at [Vampire_Infection]%"
			if(Vampire_Infection>100)
				if(!Vampire_Monster) Become_Vampire_Monster()
				else
					src<<"Your vampire infection has reached its max and killed you"
					Death(null,1)
		sleep((2*60*60*10)/100) //Reach max infection in 2 hours
	else sleep(3000)
mob/proc/Vampire_Power_Fall() spawn while(src)
	if(Vampire)
		if(!Vampire_Monster)
			Vampire_Power-=0.00416 //240 minutes, 4 hours
			if(Vampire_Power<1) Vampire_Power=1
		else
			Vampire_Power-=0.00832
			if(Vampire_Power<0.2) Vampire_Power=0.2
	sleep(600)
mob/proc/Cured_Vampire_Ratio(N=0) //Shows the ratio of people online that are former vampires
	if(!Player_Count()) return 0
	for(var/mob/P in Players) if(P.Former_Vampire) N++
	return N/Player_Count()
mob/proc/Born_Vampire_Check(N=0) if(Player_Count())
	if(Android) return
	for(var/mob/P in Players) if(P.Vampire&&!P.Dead) N++
	N/=Living_Players()
	if(prob(N*100)) Become_Vampire()
proc/Living_Players(N=0)
	for(var/mob/M in Players) if(!M.Dead) N++
	return N
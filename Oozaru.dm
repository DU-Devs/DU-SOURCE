mob/var/list/Werewolf_Overlays=new
mob/var/Tail
mob/var/Tail_Icon
mob/proc/Tail_Add() if(Race=="Yasai")
	src<<"Your tail grew back!"
	if(!Tail_Icon) Tail_Icon='Tail.dmi'+rgb(40,0,0)
	overlays-=Tail_Icon
	overlays+=Tail_Icon
	Tail=1
mob/proc/Tail_Remove()
	Tail=0
	if(!Tail_Icon) Tail_Icon='Tail.dmi'+rgb(40,0,0)
	overlays-=Tail_Icon
	Werewolf_Revert()
mob/proc/Is_Werewolf() for(var/obj/Werewolf/O in src) if(O.suffix) return 1
mob/proc/Werewolf_Revert() for(var/obj/Werewolf/O in src) if(O.suffix)
	O.suffix=null
	icon=O.icon
	BP_Multiplier/=1.5
	Def*=2
	DefMod*=2
	Spd*=2
	SpdMod*=2
	overlays.Add(Werewolf_Overlays)
	Werewolf_Overlays.Remove(Werewolf_Overlays)
mob/proc/Werewolf(Golden=0) if(!Cyber_Power) for(var/obj/Werewolf/O in src) if(!O.suffix&&Tail&&!ssj&&!Dead)
	if(Redoing_Stats) return
	O.suffix="Active"
	O.icon=icon
	Werewolf_Overlays.Add(overlays)
	overlays.Remove(overlays)
	spawn(rand(1,100)) for(var/mob/A in view(20,src))
		var/sound/S=sound('Roar.wav')
		A<<S
	icon='werewolf icon.dmi'
	BP_Multiplier*=1.5
	Def*=0.5
	DefMod*=0.5
	Spd*=0.5
	SpdMod*=0.5
	spawn(3000) Werewolf_Revert()
	if(prob(Golden)) spawn(600) if(src&&O&&O.suffix&&!SSj4Able&&ssjdrain>=300&&ssj2drain>=300)
		Werewolf_Revert()
		SSj4Able=Year
		SSj4()
obj/Werewolf
	desc="Turns you into a large wolf every full moon. Your power increases drastically, but some \
	things decrease, such as speed and defense."
	Skill=1
	var/Setting=1
	var/Icon
	verb/Werewolf_Toggle()
		set category="Other"
		if(!usr.Tail) return
		for(var/obj/Werewolf/O in usr) if(O.suffix)
			usr<<"You can not use this while in the form"
			return
		usr.Tail_Remove()
		if(Setting)
			Setting=0
			usr<<"You decide not to look at the full moon if it comes out"
		else
			Setting=1
			usr<<"You decide to look at the moon if it comes out"
		usr.Tail_Add()
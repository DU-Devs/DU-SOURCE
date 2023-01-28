mob/var/tmp/list/injury_list=new

mob/verb/Injure()
	//set category="Skills"
	var/mob/P=src
	for(var/mob/M in Get_step(src,dir)) if(M.client) P=M
	if(P.key in epic_list)
		src<<"[P] is immune to injuries"
		return
	if(tournament_override(fighters_can=0)) return
	Injury_Options(P)

mob/proc
	Injury_Options(mob/P)
		if(!P.KO&&P!=src)
			src<<"They must be knocked out"
			return
		if(P!=src&&alignment_on&&both_good(src,P))
			src<<"You cant injure another good person"
			return
		if(P!=src && Same_league_cant_kill(src,P))
			src<<"You can not injure a fellow league member"
			return
		if(P.Race=="Majin")
			src<<"Majins are immune to injuries"
			return
		var/obj/Injuries/I
		var/list/options=list("None","Arm","Leg","Eye","Internal","Brain","Dick")
		if(P.Tail) options+="Rip tail off"
		if(!client) return
		switch(input(src,"Use this to inflict injuries on people. If no one is knocked out in front of you, it defaults to injuring yourself. \
		What sort of injury do you want to inflict upon [P]?") in options)
			if("Arm") I=new/obj/Injuries/Arm
			if("Leg") I=new/obj/Injuries/Leg
			if("Eye") I=new/obj/Injuries/Eye
			if("Internal") I=new/obj/Injuries/Internal
			if("Brain") I=new/obj/Injuries/Brain
			if("Dick") I=new/obj/Injuries/Dick
			if("Rip tail off")
				if(P)
					player_view(15,src)<<"[src] rips [P]'s tail off!"
					P.Tail_Remove()
				return
			if("None") return
		Inflict_Injury(P,I)

	Inflict_Injury(mob/P,obj/Injuries/I)
		if(!P) return
		var/Injuries=0 //Injuries of the same type that will be inflicted
		for(var/obj/Injuries/O in P.injury_list) if(O.type==I.type) Injuries++
		if(Injuries>=I.Max_Injuries)
			switch(input(src,"[P] is already inflicted with the maximum amount of this injury type. Do you want to make \
			their existing injuries of this type permanent if they aren't already?") in list("Yes","No"))
				if("Yes") if(P) for(var/obj/Injuries/O in P.injury_list) if(O.type==I.type) O.Wear_Off=0
		else
			var/D=input(src,"Temporary or permanent injury?") in list("Temporary","Permanent","Cancel")
			if(D=="Cancel") return
			if(D=="Temporary") I.Wear_Off=Year+0.5
			if(!P) return
			if(Injuries) I.icon=I.Alt_Icon
			I.icon+=P.Blood_Color()
			P.contents+=I
			P.injury_list+=I
			player_view(15,src)<<"[src] inflicts a [D] [I] injury on [P]"
			P.Add_Injury_Overlays()
			P.Injury_removal_loop()
			P.Eye_Injury_Blindness()

mob/proc/Remove_Injury_Overlays() for(var/obj/Injuries/I in injury_list) overlays-=I.icon

mob/proc/Add_Injury_Overlays()
	Remove_Injury_Overlays()
	for(var/obj/Injuries/I in injury_list) overlays+=I.icon

mob/proc/Blood_Color()
	if(Race=="Alien") return rgb(105,165,0)
	if(Race=="Puranto") return rgb(150,0,115)
	if(Race=="Android") return rgb(0,0,150)
	if(Race=="Bio-Android") return rgb(0,0,150)
	if(Race=="Frost Lord") return rgb(150,0,115)
	if(Race=="Demon") return rgb(150,115,0)
	if(Race=="Onion Lad") return rgb(0,0,150)
	if(Race=="Majin") return rgb(150,0,75)
	return rgb(150,0,0)

obj/Injuries
	Del()
		var/mob/M=loc
		if(ismob(M))
			M.overlays-=icon
			M.injury_list-=src
			M.injury_list=remove_nulls(M.injury_list)
		. = ..()
	New()
		spawn(5) if(ismob(loc))
			var/mob/M=loc
			M.injury_list+=src
	Givable=0
	Makeable=0
	var/Wear_Off //If null, permanent injury. Otherwise it wears off when this year has been reached.
	var/Alt_Icon
	var/Max_Injuries=1
	Internal icon='Internal Injury.dmi'
	Brain
	Dick icon='Groin Injury.dmi'
	Eye
		icon='Eye L Injury.dmi'
		Alt_Icon='Eye R injury.dmi'
		Max_Injuries=2
	Leg
		icon='Leg L Injury.dmi'
		Alt_Icon='Leg R Injury.dmi'
		Max_Injuries=2
	Arm
		icon='Arm L Injury.dmi'
		Alt_Icon='Arm R Injury.dmi'
		Max_Injuries=2
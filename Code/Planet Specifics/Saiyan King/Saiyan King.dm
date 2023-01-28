var
	obj/King_of_Braal_Throne/kov_throne
	kov_throne_spawn = locate(86,337,4)

	king_of_Braal //key

proc
	SpawnKingBraalThrone()
		if(kov_throne) return
		var/obj/King_of_Braal_Throne/k = new
		k.SafeTeleport(kov_throne_spawn)

	StartupSpawnKingBraalThrone()
		set waitfor=0
		sleep(600)
		SpawnKingBraalThrone()

mob/KOV/verb
	KOV_Guide()
		set category = "KOV"
		src << browse(kov_guide, "window=Guide,size=800x600")

	KOV_Message()
		set category = "KOV"
		var/txt = input(src, "Send a message to everyone on the planet") as text
		if(!txt || txt == "") return
		txt = "<font color=red><font size=3>Decree from KING Braal: [txt]"
		PlanetBraalMsg(txt)
		src << "Your message was sent out to everyone on Planet Braal"

	KOV_Spawn_Yasai_NPC()
		set category = "KOV"
		if(Yasai_soldiers.len >= 30)
			src << "Max amount of soldiers is 30"
			return
		new/mob/Yasai_Army/Yasai_Soldier(loc)

	KOV_Recall_All_Soldiers()
		set category = "KOV"
		for(var/mob/m in Yasai_soldiers) m.SafeTeleport(loc)
		src << "All Yasai Soldiers have been recalled to you"

	KOV_Delete_All_Soldiers()
		set category = "KOV"
		for(var/mob/m in Yasai_soldiers) del(m)
		src << "All Yasai Soldiers deleted"

mob/proc
	CheckKingOfBraalVerbs()
		if(!king_of_Braal) return
		if(king_of_Braal == key)
			verbs += typesof(/mob/KOV/verb)
		else
			verbs -= typesof(/mob/KOV/verb)

obj/King_of_Braal_Throne
	Health = 1.#INF
	//Dead_Zone_Immune = 1
	Knockable = 0
	Grabbable = 0
	Cloakable = 0
	can_blueprint = 0
	density = 1
	//Savable = 1

	icon = 'Throne 2.dmi'
	icon_state = "gold"

	desc = "Whoever sits in this throne becomes King of Braal and gains control of the Yasai Army. Get next to the throne \
	and click it for commands."

	New()
		kov_throne = src
		var/image/i = image(icon = icon, icon_state = "gold top", pixel_y = 32, layer = MOB_LAYER + 1)
		overlays = null
		overlays += i
		KOV_ThroneOffPlanetCheck()
		KOV_ThroneTellPeopleWhoKingLoop()
		. = ..()
		spawn(10) if(src) for(var/obj/King_of_Braal_Throne/t in loc) if(t != src) del(t)

	proc
		KOV_ThroneOffPlanetCheck()
			set waitfor=0
			while(src)
				if(z != 4) SafeTeleport(kov_throne_spawn)
				sleep(300)

		KOV_ThroneTellPeopleWhoKingLoop()
			set waitfor=0
			while(src)
				var/mob/king = Get_by_key(king_of_Braal)
				if(king)
					PlanetBraalMsg("<font size=2><font color=red>[king] is King of Braal")
				sleep(60 * 600)

mob/proc
	BumpKingBraalThrone()
		SafeTeleport(kov_throne.loc)
		dir = SOUTH
		BecomeKingBraal()

	BecomeKingBraal()

		//return //disabled to see if this is what crashes the server

		if(!client || king_of_Braal == key) return

		var/mob/old_king = Get_by_key(king_of_Braal)
		king_of_Braal = key
		if(old_king) old_king.CheckKingOfBraalVerbs()
		PlanetBraalMsg("<font color=red><font size=3>[uppertext(name)] IS NOW KING OF BRAAL!! BOW TO YOUR KING OR DIE!!! \
		MAY THEY REIGN FOR A THOUSAND YEARS!")
		CheckKingOfBraalVerbs()

var/kov_guide = {"<html><head><title>King of Braal Guide</title><body><body bgcolor="#000000"><font size=2><font color="#CCCCCC">

wat

</body><html>"}

proc
	PlanetBraalMsg(t)
		for(var/mob/m in players)
			var/area/a = m.get_area()
			if(a && a.type == /area/Braal)
				m << t
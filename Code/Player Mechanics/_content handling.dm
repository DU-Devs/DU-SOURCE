mob/proc
	GetItems(list/L)
		if(!L || !L.len) return
		var/obj/O
		for(var/obj/i in L)
			O = new i.type
			src.contents+= O

	GetSkills(list/L)
		world << "Enter GetSkills()"
		if(!L || !L.len) return
		world << "List exists and has contents"
		var/obj/Skills/S2
		world << "Beginning loop for skill dupe check"
		for(var/obj/Skills/S in src.contents) for(var/obj/i in L)
			world << "Creating skill to check for dupe"
			S2 = new i
			world << "Checking if the skill is a dupe"
			if(S != S2 && S ~= S2) continue
			world << "Adding skill to player"
			src.contents+= S2
rank
	var
		name
		desc
		location
		list/items
		list/skills
		list/minStats
		list/addStats
		list/multStats
		list/waitingList
	
	Topic(href, hrefs[])
		. = ..()
		if(hrefs["action"] == "enlist")
			if(usr.key && usr.key in waitingList)
				switch(alert("You're already on the waiting list for this rank.  Would you like to leave it?",,"Yes", "No"))
					if("Yes") LeaveWaitingList(usr)
			else JoinWaitingList(usr)
	
	proc
		Initialize(_name, _desc, _location, list/_items, list/_skills, list/_minStats, list/_addStats, list/_multStats)
			name = _name
			desc = _desc
			location = _location
			items = _items
			skills = _skills
			minStats = _minStats
			addStats = _addStats
			multStats = _multStats
		
		Apply(mob/M)
			if(!M || !M.client || !(M in players)) return
			ApplyItems(M)
			ApplySkills(M)
			ApplyStats(M)
			M.playerRanks += src.name

		Remove(mob/M)
			if(!M || !M.client || !(M in players)) return
			RemoveItems(M)
			RemoveSkills(M)
			RemoveStats(M)
			M.playerRanks -= src.name

		ApplyItems(mob/M)
			for(var/i in items)
				new i(M)
		
		ApplySkills(mob/M)
			for(var/i in skills)
				new i(M)
		
		ApplyStats(mob/M)
			for(var/i in minStats)
				M.vars[i] = max(minStats[i], M.vars[i])
			for(var/i in addStats)
				M.vars[i] += addStats[i]
			for(var/i in multStats)
				M.vars[i] *= multStats[i]
		
		RemoveStats(mob/M)
			for(var/i in addStats)
				M.vars[i] -= addStats[i]
			for(var/i in multStats)
				M.vars[i] /= multStats[i]
		
		RemoveSkills(mob/M)
			var/list/skillTypes = new
			for(var/i in skills)
				skillTypes += skills[i]
			for(var/obj/O in M)
				if(O.type in skillTypes)
					skillTypes -= O.type
					del(O)
		
		RemoveItems(mob/M)
			var/list/itemTypes = new
			for(var/i in items)
				itemTypes += items[i]
			for(var/obj/O in M)
				if(O.type in itemTypes)
					itemTypes -= O.type
					del(O)
		
		JoinWaitingList(mob/M)
			if(!M || !M.key) return
			if(!waitingList) waitingList = new/list
			waitingList += M.key
			M << "Added to waiting list for [src.name]."
		
		LeaveWaitingList(mob/M)
			if(!M || !M.key) return
			waitingList -= M.key
			M << "Removed from waiting list for [src.name]."
		
		HasEdits()
			return (minStats && minStats.len) || (addStats && addStats.len) || (multStats && multStats.len)

mob/var/list/playerRanks = new

var/list/AllRanks = new

var/list/rankStats = list("base_bp", "bp_mult", "static_bp", "zenkai_mod", "leech_rate", "med_mod",\
							"Eff", "Str", "End", "Pow", "Res", "Off", "Def", "Spd", "regen", "recov", "max_stamina", "max_anger",\
							"KeepsBody", "Lungs", "Immortal", "Intelligence", "knowledge_cap_rate",\
							"ascension_bp", "stun_resistance_mod",  "mastery_mod", "Decline",\
							"Gravity_Mod", "gravity_mastered", "Regenerate", "bp_loss_from_low_ki", "bp_loss_from_low_hp")

mob/Admin4/verb/Manage_Ranks()
	set category = "Admin"
	while(1)
		switch(input("What do you need to do?", "Manage Ranks") in list("Cancel", "Create", "Delete", "Reset", "View Waiting List"))
			if("Create") CreateRank()
			if("Delete") DeleteRank()
			if("Reset")
				switch(alert("This will delete all ranks and replace with the default list which can not be undone.\
								Are you sure?",,"Yes", "No"))
					if("Yes") InitializeDefaultRanks()
			if("View Waiting List")
				var/rank/R = input("View the waiting list for what rank?") in list("Cancel") + AllRanks
				if(!R || R == "Cancel") continue
				ViewWaitingList()
			else break

mob/proc/ViewWaitingList()
	if(!src || !client || !IsAdmin()) return
	var/html = "<html><head>[KHU_HTML_HEADER]<title>Waiting List</title>"
	html += "</head><body bgcolor=#000000 text=#339999 link=#99FFFF>"
	for(var/rank/R in AllRanks)
		html += "<h3>Waiting list for [R.name]:"
		for(var/i in R.waitingList)
			html += "<p>[i]</p>"
	html += "</body></html>"
	if(!savedBrowserPos["Ranks"]) savedBrowserPos["Ranks"] = "0x0"
	if(!savedBrowserSize["Ranks"]) savedBrowserSize["Ranks"] = "480x1024"
	src << browse(html, "window=Ranks;pos=[savedBrowserPos["Ranks"]];size=[savedBrowserSize["Ranks"]]")
	winset(src, "Ranks", "on-close='save-pos \"Ranks\"'")

mob/verb/Ranks()
	set category = "Other"
	var/html = "<html><head>[KHU_HTML_HEADER]<title>Ranks</title>"
	html += "</head><body bgcolor=#000000 text=#339999 link=#99FFFF>"
	html += "<h1>Click a rank's name to join/leave the waiting list.</h1>"
	for(var/rank/R in AllRanks)
		html += "<h2><a href=byond://?src=\ref[R]&action=enlist>[R.name]</a></h2>"
		if(R.desc) html += "<h3>[replacetext(R.desc, "\n", "<br>")]</h3>"
		if(R.location) html += "<p>Location: [R.location]</p>"
		if(R.items && R.items.len)
			html += "<p>Items: </p><ul>"
			for(var/i in R.items)
				var/obj/I = new i
				html += "<li>[I.name]</li>"
			html += "</ul>"
		if(R.skills && R.skills.len)
			html += "<p>Skills: </p><ul>"
			for(var/i in R.skills)
				var/obj/I = new i
				html += "<li>[I.name]</li>"
			html += "</ul>"
		if(R.HasEdits())
			html += "<p>Edits: </p><ul>"
			if(R.minStats && R.minStats.len)
				for(var/i in R.minStats)
					html += "<li>Set [i] to minimum of [Commas(R.minStats[i])].</li>"
			if(R.addStats && R.addStats.len)
				for(var/i in R.addStats)
					html += "<li>Add [Commas(R.addStats[i])] to [i].</li>"
			if(R.multStats && R.multStats.len)
				for(var/i in R.multStats)
					html += "<li>Multiply [i] by [round(R.multStats[i], 0.01)]x.</li>"
			html += "</ul><hr>"
	html += "</body></html>"
	if(!usr.savedBrowserPos["Ranks"]) usr.savedBrowserPos["Ranks"] = "0x0"
	if(!usr.savedBrowserSize["Ranks"]) usr.savedBrowserSize["Ranks"] = "480x1024"
	usr << browse(html, "window=Ranks;pos=[usr.savedBrowserPos["Ranks"]];size=[usr.savedBrowserSize["Ranks"]]")
	winset(usr, "Ranks", "on-close='save-pos \"Ranks\"'")

mob/proc/CreateRank()
	var/rank/R = new/rank
	var/_name = input("Set a name for this rank.") as text|null
	if(!_name)
		return
	var/_desc = input("Enter a description of this rank.") as message|null
	if(!_desc)
		return
	var/_location = input("Enter a location for this rank.") as text|null
	if(!_location)
		return
	var/list/_items = new
	InitalizeAllItemsList()
	while(1)
		var/i = input("Add what item?") in list("Done") + (All_Items - _items)
		if(!i || i == "Done") break
		_items += All_Items["[i]"]
	var/list/_skills = new
	InitalizeAllSkillsList()
	while(1)
		var/i = input("Add what skill?") in list("Done") + (All_Skills - _skills)
		if(!i || i == "Done") break
		_skills += All_Skills["[i]"]
	var/list/_minStats = new
	while(1)
		var/i = input("Select a variable which will be modified if its value is lower than the one provided.") in list("Done") + rankStats - _minStats
		if(!i || i == "Done") break
		var/v = input("Select a value to which the chosen variable will be set if the previous value is lower.") as num|null
		if(!v) break
		_minStats["[i]"] = v
	var/list/_addStats = new
	while(1)
		var/i = input("Select a variable that this rank will modify, which will have the value you set next added to it.") in list("Done") + rankStats - _addStats
		if(!i || i == "Done") break
		var/v = input("Select a value which will be added to the chosen variable.") as num|null
		if(!v) break
		_addStats["[i]"] = v
	var/list/_multStats = new
	while(1)
		var/i = input("Select a variable that this rank will modify, which will be multiplied by the value you select next.") in list("Done") + rankStats - _multStats
		if(!i || i == "Done") break
		var/v = input("Select a value to which the chosen variable will be multiplied by.") as num|null
		if(!v) break
		_multStats["[i]"] = v
	if(!R) return
	R.Initialize(_name, _desc, _location, _items, _skills, _minStats, _addStats, _multStats)
	AllRanks += R

mob/proc/DeleteRank()
	while(1)
		var/R = input("Delete which rank?") in list("Cancel") + AllRanks
		if(!R || R == "Cancel") break
		AllRanks -= R

proc/Load_Ranks()
	if(fexists("data/ranks"))
		var/savefile/F = new("data/ranks")
		F >> AllRanks
	else InitializeDefaultRanks()

proc/Save_Ranks()
	var/savefile/F = new("data/ranks")
	F << AllRanks

proc/Give_Rank(mob/M)
	var/rank/R = input("Which rank?", "Give Rank") in list("Cancel") + AllRanks
	if(!R || R == "Cancel") return
	R.Apply(M)

proc/InitializeDefaultRanks()
	AllRanks = new
	var/rank/R = new/rank
	R.name = "Guardian"
	R.location = "Earth"
	R.skills = list(/obj/Skills/Combat/Ki/Blast,/obj/Skills/Combat/Ki/Charge,/obj/Skills/Combat/Ki/Beam,/obj/Skills/Utility/Fly,\
		/obj/Skills/Utility/Power_Control,/obj/Skills/Utility/Heal,/obj/Skills/Divine/Materialization,/obj/Skills/Combat/Ki/Shield,/obj/Skills/Utility/Give_Power,\
		/obj/Skills/Divine/Keep_Body,/obj/Skills/Divine/Bind,/obj/Skills/Utility/Sense,/obj/Skills/Utility/Sense/Level2,\
		/obj/Skills/Utility/Telepathy,/obj/Skills/Utility/Observe,/obj/Skills/Divine/Reincarnation,/obj/Skills/Utility/Meditate/Level2,\
		/obj/Skills/Utility/Hide_Energy,/obj/Skills/Divine/Make_Dragon_Balls)
	AllRanks += R
	R = new/rank
	R.name = "Turtle Hermit"
	R.location = "Earth"
	R.skills = list(/obj/Skills/Combat/Ki/Charge,/obj/Skills/Combat/Ki/Beam,/obj/Skills/Combat/Ki/Kamehameha,\
		/obj/Skills/Utility/Zanzoken,/obj/Skills/Utility/Fly,/obj/Skills/Utility/Heal,/obj/Skills/Utility/Give_Power,/obj/Skills/Utility/Sense,\
		/obj/Skills/Utility/Meditate/Level2)
	AllRanks += R
	R = new/rank
	R.name = "Crane Hermit"
	R.location = "Earth"
	R.skills = list(/obj/Skills/Combat/Ki/Blast,/obj/Skills/Combat/Ki/Beam,/obj/Skills/Combat/Ki/Dodompa,/obj/Skills/Combat/Ki/Taiyoken,\
		/obj/Skills/Combat/SplitForm,/obj/Skills/Combat/Ki/Self_Destruct,/obj/Skills/Combat/Ki/Kikoho,/obj/Skills/Utility/Fly,/obj/Skills/Utility/Sense,\
		/obj/Skills/Utility/Meditate/Level2)
	AllRanks += R
	R = new/rank
	R.name = "Elder Puran"
	R.location = "Puranto"
	R.skills = list(/obj/Skills/Combat/Ki/Charge,/obj/Skills/Utility/Fly,/obj/Skills/Utility/Heal,/obj/Skills/Utility/Power_Control,\
		/obj/Skills/Divine/Materialization,/obj/Skills/Divine/Unlock_Potential,/obj/Skills/Utility/Give_Power,/obj/Skills/Combat/Ki/Shield,\
		/obj/Skills/Utility/Meditate/Level2,/obj/Puranto_Fusion,/obj/Skills/Utility/Hide_Energy,\
		/obj/Skills/Divine/Make_Dragon_Balls,/obj/Skills/Divine/Reincarnation, /obj/Skills/Utility/Telepathy,/obj/Skills/Utility/Observe,\
		/obj/Skills/Utility/Sense,/obj/Skills/Utility/Sense/Level2, /obj/Skills/Combat/Ki/Masenko)
	AllRanks += R
	R = new/rank
	R.name = "Elite Alien"
	R.location = "Other"
	R.skills = list(/obj/Skills/Combat/Ki/Charge,/obj/Skills/Combat/Ki/Explosion,/obj/Skills/Combat/Ki/Beam,\
		/obj/Skills/Utility/Fly,/obj/Skills/Combat/Ki/Shockwave)
	AllRanks += R
	R = new/rank
	R.name = "Supreme Kaioshin"
	R.location = "Heaven"
	R.skills = list(/obj/Skills/Combat/Ki/Blast,/obj/Skills/Combat/Ki/Charge,/obj/Skills/Combat/Ki/Beam,\
		/obj/Skills/Combat/Ki/Sokidan,/obj/Skills/Combat/Ki/Scatter_Shot,/obj/Skills/Utility/Heal,/obj/Skills/Combat/Ki/Shield,\
		/obj/Skills/Utility/Give_Power,/obj/Skills/Utility/Fly,/obj/Skills/Utility/Power_Control,/obj/Skills/Divine/Materialization,\
		/obj/Skills/Divine/Unlock_Potential,/obj/Skills/Divine/Keep_Body,/obj/Skills/Divine/Restore_Youth,/obj/Skills/Divine/Kaio_Revive,\
		/obj/Skills/Divine/Bind,/obj/Skills/Divine/Make_Fruit,/obj/Skills/Divine/Kai_Teleport,/obj/Make_Holy_Pendant,/obj/Skills/Utility/Meditate/Level2,\
		/obj/Skills/Utility/Telepathy,/obj/Skills/Utility/Observe,/obj/Skills/Divine/Reincarnation,/obj/Skills/Utility/Sense,/obj/Skills/Utility/Sense/Level2)
	AllRanks += R
	R = new/rank
	R.name = "North Kai"
	R.location = "Checkpoint"
	R.skills = list(/obj/Skills/Combat/Ki/Charge,/obj/Skills/Combat/Ki/Sokidan,/obj/Skills/Utility/Fly,/obj/Skills/Utility/Heal,/obj/Skills/Utility/Give_Power,\
		/obj/Skills/Utility/Power_Control,/obj/Skills/Divine/Keep_Body,/obj/Skills/Divine/Kaio_Revive,/obj/Skills/Divine/Materialization,\
		/obj/Skills/Divine/Bind,/obj/Skills/God_Fist,/obj/Skills/Combat/Ki/Genki_Dama,/obj/Skills/Utility/Sense,/obj/Skills/Utility/Sense/Level2,\
		/obj/Skills/Utility/Telepathy,/obj/Skills/Utility/Observe,/obj/Skills/Divine/Reincarnation,/obj/Skills/Utility/Meditate/Level2)
	AllRanks += R
	R = new/rank
	R.name = "Demon Lord"
	R.location = "Hell"
	R.skills = list(/obj/Skills/Combat/Ki/Blast,/obj/Skills/Combat/Ki/Charge,/obj/Skills/Combat/Ki/Explosion,\
		/obj/Skills/Combat/Ki/Beam,/obj/Skills/Combat/Ki/Sokidan,/obj/Skills/Combat/Ki/Piercer,\
		/obj/Skills/Combat/Ki/Self_Destruct,/obj/Skills/Utility/Fly,/obj/Skills/Combat/Ki/Shield,\
		/obj/Skills/Combat/SplitForm,/obj/MakeAmulet,/obj/Skills/Divine/Keep_Body,/obj/Skills/Divine/Majin,\
		/obj/Skills/Divine/Restore_Youth,/obj/Skills/Divine/Materialization,/obj/Skills/Divine/Bind,/obj/Skills/Divine/Make_Fruit,/obj/Skills/Divine/Demon_Contract,\
		/obj/Skills/Divine/Kaio_Revive,/obj/Skills/Combat/Ki/Kienzan,/obj/Skills/Combat/Ki/Shockwave,/obj/Make_Holy_Pendant,\
		/obj/Skills/Utility/Telepathy,/obj/Skills/Utility/Observe,/obj/Skills/Divine/Reincarnation,\
		/obj/Skills/Utility/Sense,/obj/Skills/Utility/Sense/Level2,/obj/Skills/Utility/Meditate/Level2)
	AllRanks += R
	R = new/rank
	R.name = "Elite Yasai"
	R.location = "Braal"
	R.skills = list(/obj/Skills/Combat/Ki/Charge,/obj/Skills/Combat/Ki/Explosion,/obj/Skills/Combat/Ki/Beam,\
	/obj/Skills/Combat/Ki/Onion_Gun,/obj/Skills/Combat/Ki/Final_Flash,/obj/Skills/Utility/Fly,/obj/Skills/Combat/Ki/Kienzan,\
	/obj/Skills/Combat/Ki/Shockwave,/obj/Skills/Combat/Ki/Blast)
	AllRanks += R
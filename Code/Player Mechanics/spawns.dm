#ifdef DEBUG
mob/Admin5/verb/GetSpawnList()
	var/list/spawnList = new
	for(var/obj/Spawn/S)
		spawnList += json_encode(list(name = "[S.name]", desc = "[S.desc]", "pos" = "[S.x],[S.y],[S.z]"))
	var/json = json_encode(spawnList)
	if(json)
		text2file(json, "debug/spawns.json")
		usr << "List done, placed in 'debug/spawns.json'"
	else usr << "Something went wrong..."
#endif

var/list/RaceSpawns = new

proc/InitializeSpawns()
	if(fexists("data/Spawns"))
		var/savefile/F = new("data/Spawns")
		F >> RaceSpawns
		for(var/obj/Spawn/S in RaceSpawns)
			S.loc = locate(S.savedX, S.savedY, S.savedZ)
		world << "Spawns Loaded"
	else
		CreateDefaultSpawns()

proc/SaveSpawns()
	var/savefile/F = new("data/Spawns")
	for(var/obj/Spawn/S in RaceSpawns)
		S.savedX = S.x
		S.savedY = S.y
		S.savedZ = S.z
	F << RaceSpawns

proc/CreateDefaultSpawns()
	if(!RaceSpawns) RaceSpawns = new/list
	else
		for(var/obj/Spawn/S in RaceSpawns)
			RaceSpawns.Remove(S)
			del(S)
	new/obj/Spawn{name = "Majin"; desc = "Space"}(locate(445,360,16))
	new/obj/Spawn{name = "Onion Lad"; desc = "Makyo earth spawn"}(locate(377,245,1))
	new/obj/Spawn{name = "Human"; desc = "Human earth spawn"}(locate(102,275,1))
	new/obj/Spawn{name = "Spirit Doll"; desc = "Spirit Doll earth spawn"}(locate(102,289,1))
	new/obj/Spawn{name = "Demon"; desc = "Earth Demon (Weaker)"}(locate(435,381,1))
	new/obj/Spawn{name = "Legendary Yasai"; desc = "Legendary Planet Braal"}(locate(408,360,2))
	new/obj/Spawn{name = "Puranto"; desc = "Puranto Namek Spawn"}(locate(289,145,3))
	new/obj/Spawn{name = "Yasai"; desc = "Yasai Planet Braal"}(locate(400,116,4))
	new/obj/Spawn{name = "Alien"; desc = "Alien Planet Braal"}(locate(239,145,4))
	new/obj/Spawn{name = "Demigod"; desc = "Checkpoint"}(locate(168,210,5))
	new/obj/Spawn{name = "Demon"; desc = "Hell"}(locate(416,289,6))
	new/obj/Spawn{name = "Kai"; desc = "Heaven"}(locate(342,457,7))
	new/obj/Spawn{name = "Alien"; desc = "Planet Arconia"}(locate(214,186,8))
	new/obj/Spawn{name = "Tsujin"; desc = "Atlantis"}(locate(121,227,11))
	new/obj/Spawn{name = "Frost Lord"; desc = "Planet Ice"}(locate(321,401,12))
	new/obj/Spawn{name = "Alien"; desc = "Desert Planet"}(locate(11,14,14))
	new/obj/Spawn{name = "Bio-Android"; desc = "Bio Android spawn"}(locate(360,307,14))
	new/obj/Spawn{name = "Alien"; desc = "Jungle Planet"}(locate(118,369,14))
	new/obj/Spawn{name = "Android"; desc = "Android spawn"}(locate(486,464,14))
	world << "Spawns reset to default."

mob/Admin3/verb/ManageRaceSpawns()
	set category = "Admin"
	while(1)
		switch(input("Do what?", "Manage Race Spawns") in list("Cancel", "Create", "Remove", "Reset to Default"))
			if("Create")
				AddSpawnToList()
			if("Remove")
				RemoveSpawnFromList()
			if("Reset to Default")
				CreateDefaultSpawns()
			else break
		sleep(2)

proc/AddSpawnToList()
	while(1)
		var/N = input("Create a spawn for what race?") in list("Cancel") + GetRacesAsList()
		if(!N || N == "Cancel")
			return
		var/D = input("Add a short description. Such as the planet or area where it's located.") as text|null
		if(!D)
			return
		var/spawnX, spawnY, spawnZ
		switch(alert("Do you want to place it at your current location?",,"Yes","No"))
			if("Yes")
				spawnX = usr.x
				spawnY = usr.y
				spawnZ = usr.z
			else
				spawnX = input("Enter the desired X coordinate.") as num|null
				spawnY = input("Enter the desired Y coordinate.") as num|null
				spawnZ = input("Enter the desired Z coordinate.") as num|null
		if(!spawnX || !spawnY || !spawnZ) return
		var/obj/Spawn/S = new(locate(spawnX,spawnY,spawnZ))
		S.name = N
		S.desc = D
		if(!RaceSpawns) RaceSpawns = new/list
		RaceSpawns += S
		usr << "Successfully added spawn [S.name]([S.desc]) at [S.x],[S.y],[S.z]."
		switch(alert("Create another spawn?",,"Yes", "No"))
			if("No") break
		sleep(2)

proc/RemoveSpawnFromList()
	while(1)
		var/list/spawnList = new
		for(var/obj/Spawn/S in RaceSpawns)
			spawnList["[S.name]([S.desc])"] = S
		var/s= input("Remove which spawn?") in list("Cancel") + spawnList
		var/obj/Spawn/S = spawnList[s]
		if(!S || s == "Cancel") break
		S.respawn_on_delete = 0
		S.reallyDelete = 1
		RaceSpawns -= S
		del(S)
		sleep(2)
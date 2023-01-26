var/list/admin_objects = new

proc/SaveAdminObjects()
	//set background=1
	var/savefile/f = new("data/Admin Placed Objects")
	for(var/obj/o in admin_objects)
		o.saved_x = o.x
		o.saved_y = o.y
		o.saved_z = o.z
	f["admin_objects"] << admin_objects

proc/LoadAdminObjects()
	if(fexists("data/Admin Placed Objects"))
		var/savefile/f = new("data/Admin Placed Objects")
		f["admin_objects"] >> admin_objects
		for(var/obj/o in admin_objects)
			o.x = o.saved_x
			o.y = o.saved_y
			o.z = o.saved_z

var/BigRocksEnabled = 0

mob/Admin4/verb/Toggle_Big_Rocks()
	set category = "Admin"
	BigRocksEnabled = !BigRocksEnabled
	usr << "Randomly spawning Big Rocks is now [BigRocksEnabled ? "enabled" : "disabled"]."


mob/proc/Respawn(butNotInShipArea)
	Go_to_spawn(butNotInShipArea = butNotInShipArea)

proc/LoadData()
	set waitfor = 0
	Load_Ban()
	world<<"Bans Loaded"
	world.log << "Bans Loaded"
	sleep(world.tick_lag)
	LoadYear()
	world<<"Year Loaded"
	world.log << "Year Loaded"
	sleep(world.tick_lag)
	LoadAdmins()
	world<<"Admins Loaded"
	world.log << "Admins Loaded"
	sleep(world.tick_lag)
	LoadStory()
	world<<"Story Loaded"
	world.log << "Story Loaded"
	sleep(world.tick_lag)
	LoadRules()
	world<<"Rules Loaded"
	world.log << "Rules Loaded"
	sleep(world.tick_lag)
	LoadNotes()
	world<<"Notes Loaded"
	world.log << "Notes Loaded"
	sleep(world.tick_lag)
	LoadLogin()
	world<<"Login Loaded"
	world.log << "Login Loaded"
	sleep(world.tick_lag)
	LoadRanks()
	world<<"Ranks Loaded"
	world.log << "Ranks Loaded"
	sleep(world.tick_lag)
	LoadJobs()
	world<<"Jobs Loaded"
	world.log << "Jobs Loaded"
	sleep(world.tick_lag)
	Load_Misc()
	world<<"Misc Loaded"
	world.log << "Misc Loaded"
	sleep(world.tick_lag)
	Load_Config()
	world<<"Config Loaded"
	world.log << "Config Loaded"
	sleep(world.tick_lag)
	Load_Ranks()
	world << "Ranks Loaded"
	world.log << "Ranks Loaded"
	sleep(world.tick_lag)
	Add_Technology()
	world<<"Technology added"
	world.log << "Technology added"
	sleep(world.tick_lag)
	Fill_Hair_List()
	world<<"Hair added"
	world.log << "Hair added"
	sleep(world.tick_lag)
	LoadAreas()
	world<<"Area Loaded"
	world.log << "Area Loaded"
	sleep(world.tick_lag)
	LoadMap()
	sleep(world.tick_lag)
	LoadItems()
	sleep(world.tick_lag)
	//ClearObjectsFromPlayerTiles()
	InitializeSpawns()
	//ScatterFirefliesRandomlyOnMap()
	Load_Bodies()
	world<<"Bodies Loaded"
	world.log << "Bodies Loaded"
	sleep(world.tick_lag)

var/can_login=0

var/primaryGameLoopRunning = 0
proc/PrimaryGameLoop(delay = 0)
	set waitfor = 0
	if(delay) sleep(delay)
	if(primaryGameLoopRunning) return
	primaryGameLoopRunning = 1

	while(1)
		CpuWarnTick()
		UpdateYear()
		SaveWorldTick()
		StoreQuadrantsTick()
		SetQuadrantsTick()
		UpgradeCapCheck()
		DeleteBlankMobs()
		DragonBallCheck()
		BountyDroneSendTick()
		FusionDestroyCheck()
		MuteCheckTick()
		RefreshStatRecord()
		ResourcesTick()
		RandomResourceDrops()
		MaxSpeedCheck()
		CheckShipValidLoc()
		DeletePendingObjects()
		WallBotUpdate()
		TournamentTicker()
		TurretTargetUpdate()
		ImmortalityZoneCheck()
		BindCheck()
		RoleplayRewardTimer()
		SpecialAnnouncements()
		DisablePortals()
		EnforceGravityCap()

		sleep(world.tick_lag)

	primaryGameLoopRunning = 0

proc/Initialize(start_delay = 0)
	set waitfor = 0
	WipeStartDate = world.realtime

	if(start_delay) sleep(start_delay)

	fill_cached_blasts()
	InitializeIconGrids()
	SetTurfPalette()
	sleep(5)
	LoadData()

	ToggleDestroyedPlanets()
	ToggleBraalGym(wait = 300)
	CheckDeleteHellAltar(wait = 0)

	GenerateTraits()
	PopulateFullTransformationList()

	InitializeIconGrids()

	PrimaryGameLoop()
	can_login=1

proc/InitializeIconGrids()
	set waitfor = FALSE
	set background = TRUE
	AddBlasts()
	Initialize_Gun_Icons()
	PopulateClothesChoices()
	for(var/A in (typesof(/obj/Alien_Icons) - /obj/Alien_Icons))
		Alien_Icons+=new A
	for(var/A in (typesof(/obj/Demon_Icons) - /obj/Demon_Icons))
		Demon_Icons+=new A
	GenerateUltraInstinctGraphics()

var/highestCpuUsage = 0
var/lastCpuWarn = 0
proc/CpuWarnTick()
	set waitfor = 0
	var/CPU = world.cpu
	if(!Map_Loaded) return
	highestCpuUsage = Math.Max(highestCpuUsage, CPU)
	if(lastCpuWarn + Time.FromSeconds(10) > world.timeofday) return
	if(CPU >= CPU_WARN_THRESHOLD)
		lastCpuWarn = world.timeofday
		world.log << time2text(world.realtime)
		world.log << "WARNING: CPU HAS REACHED [CPU]% USAGE!"

obj/var/referenceObject = 0 //if this object is intended for the Science tab, Make verb, etc, it is a referenceObject

var/lastGravityEnforceUpdate = 0
proc/EnforceGravityCap()
	set waitfor = 0
	if(lastGravityEnforceUpdate + Time.FromMinutes(5) > world.time) return
	lastGravityEnforceUpdate = world.time

	for(var/obj/items/Gravity/G)
		G.Max = Math.Min(G.Max, Limits.GetSettingValue("Maximum Gravity"))
	for(var/mob/M in players)
		if(M.key in Admins) continue
		M.gravity_mastered = Math.Min(M.gravity_mastered, Limits.GetSettingValue("Maximum Gravity"))

var/avg_speed = 100

proc/AverageSpeedUpdater()
	set waitfor=0
	set background = TRUE
	while(1)
		var
			total_speed = 0
			total_players = 0
		for(var/mob/m in players)
			if(istype(m, /mob/new_troll)) continue
			if(m.z)
				total_speed += m.Spd
				total_players++
		if(!total_players)
			sleep(30)
			continue
		avg_speed = total_speed / total_players
		sleep(200)

var/lastWorldSave = 0
proc/SaveWorldTick()
	set waitfor = 0
	if(lastWorldSave + Social.GetSettingValue("Auto Save Timer") > world.time) return
	lastWorldSave = world.time

	SavePlayers()
	SaveWorld()

proc/SavePlayers()
	world<<"<font color=yellow><font size=3>Saving all players. Prepare for lag spike."
	for(var/mob/M in players) M.Save()

proc/SaveWorld(save_map=1, allow_auto_reboot=1, delete_pending_objs=0)
	world<<"<font color=yellow><font size=3>Saving all items. Prepare for lag spike."
	sleep(2 * world.tick_lag)
	SaveAdmins()
	sleep(2 * world.tick_lag)
	SaveSpawns()
	sleep(2 * world.tick_lag)
	SaveYear()
	sleep(2 * world.tick_lag)
	Save_Area()
	sleep(2 * world.tick_lag)
	Save_Misc()
	sleep(2 * world.tick_lag)
	Save_Config()
	sleep(2 * world.tick_lag)
	Save_Ranks()
	sleep(2 * world.tick_lag)
	SaveAdminObjects()
	sleep(2 * world.tick_lag)
	if(save_map)
		SaveItems()
		sleep(2 * world.tick_lag)
		StoreMap()
		sleep(2 * world.tick_lag)
		Save_Bodies()
		sleep(2 * world.tick_lag)
		Save_NPCs()
	if(allow_auto_reboot && Social.GetSettingValue("Auto Reboot Timer") && world.time > Social.GetSettingValue("Auto Reboot Timer") && !OngoingTournament())
		Admin_Reboot(save_world=0)
	else
		if(delete_pending_objs) 
			sleep(2 * world.tick_lag)
			DeletePendingObjects()
	sleep(10 * world.tick_lag)

mob/var/Can_Remake=1

mob/proc/Cant_Remake() if(fexists("Save/[ckey]"))
	var/savefile/F=new("Save/[ckey]")
	F["Can_Remake"]>>Can_Remake
	if(Can_Remake==0) return 1 //Cant use if(!Can_Vote) because if its 1 its the initial value and the entry is null

mob/proc/AutoTrainInSave() if(client&&fexists("Save/[ckey]"))
	var/savefile/F=new("Save/[ckey]")
	if(F["auto_train"]) return 1

var/player_saving_on=1

mob/proc/RemoveOverlaysThatDontSaveCorrectly()
	Remove_Say_Spark()
	TakeOffShurikenOverlaysOnSave()
	Aura_Overlays(remove_only=1)
	overlays-=BlastCharge
	overlays-='SBombGivePower.dmi'
	overlays -= ultra_instinct_idle_aura
	overlays -= grab_absorb_overlay
	overlays -= fireOverlay
	var/transformation/T = GetActiveForm()
	if(T)
		T.RemoveSpecialFX(src)

mob/proc/Save()

	if(!player_saving_on) return
	if(key && displaykey && Savable)

		RemoveOverlaysThatDontSaveCorrectly()

		var/turf/t = base_loc()
		if(t && !Regenerating)
			saved_x = t.x
			saved_y = t.y
			saved_z = t.z

		var/savefile/F=new("Save/[ckey]")
		F["Last_Used"]<<world.realtime
		Write(F)
		Aura_Overlays()
		ReApplyShurikenOverlaysOnSave()
		if(ultra_instinct) overlays += ultra_instinct_idle_aura
		if(grab_absorb_module && grabbedObject && strangling) overlays += grab_absorb_overlay
		
		var/transformation/T = GetActiveForm()
		if(T) T.ApplySpecialFX(src)

		SaveFeats()

mob/proc/Load() if(client)
	if(fexists("Save/[ckey]"))
		if(!Map_Loaded)
			alert(src,"You can not log in until the map loads.")
		else
			var/savefile/F = new("Save/[ckey]")
			Read(F)
			SafeTeleport(locate(saved_x, saved_y, saved_z))
			Other_Load_Stuff()
			LoadFeats()
	else
		alert(src,"You do not have any characters on this server.")

mob/proc/HasSave()
	if(!key) return
	if(fexists("Save/[ckey]")) return 1

proc
	SaveCustomDecors()
		var/savefile/s = new("data/CustomDecors")
		s << customDecors

	LoadCustomDecors()
		if(!fexists("data/CustomDecors")) return
		var/savefile/s = new("data/CustomDecors")
		s >> customDecors
		DeleteSpamCustomDecors()

proc/Save_Config()
	for(var/config/c in configs)
		if(fexists("configs/[c.name].json"))
			fdel("configs/[c.name].json")
		var/jsonString, list/configVars = new
		for(var/setting/S in c.settings)
			configVars[S.name] = S.value
		jsonString = json_encode(configVars)
		text2file(jsonString, "configs/[c.name].json")

proc/Save_Misc()
	SaveCustomDecors()
	var/savefile/S=new("data/Misc")
	S["Saved_Version"]<<Version
	S["Automate_Tech_Power"]<<Automate_Tech_Power
	S["Tech_BP"]<<Tech_BP
	S["Illegal_Science"]<<Illegal_Science
	S["Admin_Logs"]<<Admin_Logs
	S["PlayerSkillCosts"] << PlayerSkillCosts
	S["PlayerTechCosts"] << PlayerTechCosts
	S["PersonalRaces"] << PersonalRaces
	S["Tickets"] << tickets
	S["Reset BP"] << resetBP
	S["Last BP Reset"] << lastBPReset
	S["highestCpuUsage"] << highestCpuUsage

	S["Bounties"]<<Bounties
	S["Council"]<<Council
	S["Big Rock Spawning"] << BigRocksEnabled
	S["Illegal_Races"]<<Illegal_Races
	S["Auto_Rank"]<<Auto_Rank
	S["ssj_voting"]<<ssj_voting
	S["LockedSkills"]<<LockedSkills
	S["LockedTraits"]<<LockedTraits
	S["LockedTransformations"]<<LockedTransformations
	S["disabled_planets"]<<disabled_planets
	S["Allow_OOC"]<<Allow_OOC
	S["db_vampire_incurable"]<<db_vampire_incurable
	S["bank_list"]<<bank_list
	S["banked_items"]<<banked_items
	S["drone_instructions"]<<drone_instructions
	S["override_spawn"]<<override_spawn
	S["resource_version"] << resource_version
	S["highest_player_count"] << highest_player_count
	S["Stat_Lag"] << Stat_Lag
	S["anns"] << anns
	S["WipeStartDate"] << WipeStartDate

proc/Load_Config()
	for(var/config/c in configs)
		if(!fexists("configs/[c.name].json"))
			continue
		var
			jsonString = file2text("configs/[c.name].json")
			list/configVars = new
		configVars = json_decode(jsonString)
		for(var/v in configVars)
			var/setting/S = c.GetSetting(ckey(v))
			if(!S) continue
			S.value = configVars[v]
	
	world.status = Social.GetSettingValue("Server Name")

proc/Load_Misc()
	LoadCustomDecors()
	if(!fexists("data/Misc")) return
	var/savefile/S=new("data/Misc")
	if(!S["Saved_Version"])
		world << "Save data outdated for this version.  Deleting old saves."
		S["Saved_Version"] << Version
		return Wipe(delete_map=pwipe_delete_map,delete_items=pwipe_delete_items,cost_threshold=pwipe_cost_threshold,turf_health=pwipe_turf_health,\
		delete_feats = pwipe_delete_feats)
	S["Automate_Tech_Power"]>>Automate_Tech_Power
	S["Tech_BP"]>>Tech_BP
	S["Illegal_Science"]>>Illegal_Science
	S["Admin_Logs"]>>Admin_Logs
	if(S["PlayerSkillCosts"]) S["PlayerSkillCosts"] >> PlayerSkillCosts
	if(S["PlayerTechCosts"]) S["PlayerTechCosts"] >> PlayerTechCosts
	if(S["PersonalRaces"]) S["PersonalRaces"] >> PersonalRaces
	if(S["Tickets"]) S["Tickets"] >> tickets
	
	S["Bounties"]>>Bounties
	S["Council"]>>Council
	S["Illegal_Races"]>>Illegal_Races
	if(S["Big Rock Spawning"]) S["Big Rock Spawning"] >> BigRocksEnabled
	S["Server_Ratings"]>>Server_Ratings
	S["Auto_Rank"]>>Auto_Rank
	S["highestCpuUsage"] >> highestCpuUsage
	S["ssj_voting"]>>ssj_voting
	S["LockedSkills"]>>LockedSkills
	S["LockedTraits"]>>LockedTraits
	S["LockedTransformations"]>>LockedTransformations
	S["Tech_BP"]>>Tech_BP
	S["disabled_planets"]>>disabled_planets
	if(S["Allow_OOC"]) S["Allow_OOC"]>>Allow_OOC
	else S["OOC"] >> Allow_OOC
	S["db_vampire_incurable"]>>db_vampire_incurable
	S["bank_list"]>>bank_list
	S["banked_items"]>>banked_items
	S["pwipe_delete_map"]>>pwipe_delete_map
	S["pwipe_turf_health"]>>pwipe_turf_health
	S["pwipe_delete_items"]>>pwipe_delete_items
	S["pwipe_delete_admin_buildings"]>>pwipe_delete_admin_buildings
	S["pwipe_cost_threshold"]>>pwipe_cost_threshold
	if(S["drone_instructions"]) S["drone_instructions"]>>drone_instructions
	if(S["override_spawn"]) S["override_spawn"]>>override_spawn
	if(S["resource_version"]) S["resource_version"] >> resource_version
	if(S["highest_player_count"]) S["highest_player_count"] >> highest_player_count
	if(S["Stat_Lag"]) S["Stat_Lag"] >> Stat_Lag
	if(S["anns"]) S["anns"] >> anns
	if(S["WipeStartDate"]) S["WipeStartDate"] >> WipeStartDate
	else WipeStartDate = world.realtime
	
	if(S["Reset BP"]) S["Reset BP"] >> resetBP
	if(S["Last BP Reset"]) S["Last BP Reset"] >> lastBPReset

	pwipe_delete_feats = 0

proc/SaveYear()
	var/savefile/S=new("data/Year")
	S["Year"]<<Year
	S["Month"]<<Month
	S["Onion_Lad_Star"]<<Onion_Lad_Star

proc/LoadYear() if(fexists("data/Year"))
	var/savefile/S=new("data/Year")
	S["Year"]>>Year
	Year = Math.Floor(Year)
	if(S["Month"]) S["Month"]>>Month
	S["Onion_Lad_Star"]>>Onion_Lad_Star

proc/Save_Area()
	var/savefile/F=new("data/Areas")
	for(var/area/Checkpoint/A in all_areas)
		F["Checkpoint"]<<A.icon_state
		F["Checkpoint Value"]<<A.Value
		F["Checkpoint Power Comet"] << A.powerComet
		F["Checkpoint Year"] << A.Year
		F["Checkpoint Month"] << A.Month
		break
	for(var/area/Heaven/A in all_areas)
		F["Heaven"]<<A.icon_state
		F["Heaven Value"]<<A.Value
		F["Heaven Power Comet"] << A.powerComet
		F["Heaven Year"] << A.Year
		F["Heaven Month"] << A.Month
		break
	for(var/area/Hell/A in all_areas)
		F["Hell"]<<A.icon_state
		F["Hell Value"]<<A.Value
		F["Hell Power Comet"] << A.powerComet
		F["Hell Year"] << A.Year
		F["Hell Month"] << A.Month
		break
	for(var/area/Space/A in all_areas)
		F["Space"]<<A.icon_state
		F["Space Value"]<<A.Value
		F["Space Power Comet"] << A.powerComet
		F["Space Year"] << A.Year
		F["Space Month"] << A.Month
		break
	for(var/area/Sonku/A in all_areas)
		F["Sonku"]<<A.icon_state
		F["Sonku Value"]<<A.Value
		F["Sonku Power Comet"] << A.powerComet
		F["Sonku Year"] << A.Year
		F["Sonku Month"] << A.Month
		break
	for(var/area/Earth/A in all_areas)
		F["Earth"]<<A.icon_state
		F["Earth Value"]<<A.Value
		F["Earth Power Comet"] << A.powerComet
		F["Earth Year"] << A.Year
		F["Earth Month"] << A.Month
		break
	for(var/area/Puranto/A in all_areas)
		F["Puranto"]<<A.icon_state
		F["Puranto Value"]<<A.Value
		F["Puranto Power Comet"] << A.powerComet
		F["Puranto Year"] << A.Year
		F["Puranto Month"] << A.Month
		break
	for(var/area/Braal/A in all_areas)
		F["Braal"]<<A.icon_state
		F["Braal Value"]<<A.Value
		F["Braal Power Comet"] << A.powerComet
		F["Braal Year"] << A.Year
		F["Braal Month"] << A.Month
		break
	for(var/area/Arconia/A in all_areas)
		F["Arconia"]<<A.icon_state
		F["Arconia Value"]<<A.Value
		F["Arconia Power Comet"] << A.powerComet
		F["Arconia Year"] << A.Year
		F["Arconia Month"] << A.Month
		break
	for(var/area/Ice/A in all_areas)
		F["Frost Lord"]<<A.icon_state
		F["Frost Lord Value"]<<A.Value
		F["Frost Lord Power Comet"] << A.powerComet
		F["Frost Lord Year"] << A.Year
		F["Frost Lord Month"] << A.Month
		break
	for(var/area/Android/A in all_areas)
		F["Android"]<<A.icon_state
		F["Android Value"]<<A.Value
		F["Android Power Comet"] << A.powerComet
		F["Android Year"] << A.Year
		F["Android Month"] << A.Month
		break
	for(var/area/Jungle/A in all_areas)
		F["Jungle"]<<A.icon_state
		F["Jungle Value"]<<A.Value
		F["Jungle Power Comet"] << A.powerComet
		F["Jungle Year"] << A.Year
		F["Jungle Month"] << A.Month
		break
	for(var/area/Desert/A in all_areas)
		F["Desert"]<<A.icon_state
		F["Desert Value"]<<A.Value
		F["Desert Power Comet"] << A.powerComet
		F["Desert Year"] << A.Year
		F["Desert Month"] << A.Month
		break
	for(var/area/SSX/A in all_areas)
		F["SSX"]<<A.icon_state
		F["SSX Value"]<<A.Value
		F["SSX Power Comet"] << A.powerComet
		F["SSX Year"] << A.Year
		F["SSX Month"] << A.Month
	for(var/area/Kaioshin/A in all_areas)
		F["Kaioshin"]<<A.icon_state
		F["Kaioshin Value"]<<A.Value
		F["Kaioshin Power Comet"] << A.powerComet
		F["Kaioshin Year"] << A.Year
		F["Kaioshin Month"] << A.Month

proc/LoadAreas()
	if(fexists("data/Areas"))
		var/savefile/F=new("data/Areas")
		for(var/area/Earth/A in all_areas)
			F["Earth"]>>A.icon_state
			F["Earth Value"]>>A.Value
			F["Earth Power Comet"] >> A.powerComet
			F["Earth Year"] >> A.Year
			F["Earth Month"] >> A.Month
		for(var/area/Puranto/A in all_areas)
			F["Puranto"]>>A.icon_state
			F["Puranto Value"]>>A.Value
			F["Puranto Power Comet"] >> A.powerComet
			F["Puranto Year"] >> A.Year
			F["Puranto Month"] >> A.Month
		for(var/area/Braal/A in all_areas)
			F["Braal"]>>A.icon_state
			F["Braal Value"]>>A.Value
			F["Braal Power Comet"] >> A.powerComet
			F["Braal Year"] >> A.Year
			F["Braal Month"] >> A.Month
		for(var/area/Arconia/A in all_areas)
			F["Arconia"]>>A.icon_state
			F["Arconia Value"]>>A.Value
			F["Arconia Power Comet"] >> A.powerComet
			F["Arconia Year"] >> A.Year
			F["Arconia Month"] >> A.Month
		for(var/area/Ice/A in all_areas)
			F["Frost Lord"]>>A.icon_state
			F["Frost Lord Value"]>>A.Value
			F["Frost Lord Power Comet"] >> A.powerComet
			F["Frost Lord Year"] >> A.Year
			F["Frost Lord Month"] >> A.Month
		for(var/area/Jungle/A in all_areas)
			F["Jungle"]>>A.icon_state
			F["Jungle Value"]>>A.Value
			F["Jungle Power Comet"] >> A.powerComet
			F["Jungle Year"] >> A.Year
			F["Jungle Month"] >> A.Month
		for(var/area/Desert/A in all_areas)
			F["Desert"]>>A.icon_state
			F["Desert Value"]>>A.Value
			F["Desert Power Comet"] >> A.powerComet
			F["Desert Year"] >> A.Year
			F["Desert Month"] >> A.Month
		for(var/area/Checkpoint/A in all_areas)
			F["Checkpoint"]>>A.icon_state
			F["Checkpoint Value"]>>A.Value
			F["Checkpoint Power Comet"] >> A.powerComet
			F["Checkpoint Year"] >> A.Year
			F["Checkpoint Month"] >> A.Month
		for(var/area/Heaven/A in all_areas)
			F["Heaven"]>>A.icon_state
			F["Heaven Value"]>>A.Value
			F["Heaven Power Comet"] >> A.powerComet
			F["Heaven Year"] >> A.Year
			F["Heaven Month"] >> A.Month
		for(var/area/Hell/A in all_areas)
			F["Hell"]>>A.icon_state
			F["Hell Value"]>>A.Value
			F["Hell Power Comet"] >> A.powerComet
			F["Hell Year"] >> A.Year
			F["Hell Month"] >> A.Month
		for(var/area/Space/A in all_areas)
			F["Space"]>>A.icon_state
			F["Space Value"]>>A.Value
			F["Space Power Comet"] >> A.powerComet
			F["Space Year"] >> A.Year
			F["Space Month"] >> A.Month
		for(var/area/Sonku/A in all_areas)
			F["Sonku"]>>A.icon_state
			F["Sonku Value"]>>A.Value
			F["Sonku Power Comet"] >> A.powerComet
			F["Sonku Year"] >> A.Year
			F["Sonku Month"] >> A.Month
		for(var/area/SSX/A in all_areas)
			F["SSX"]>>A.icon_state
			F["SSX Value"]>>A.Value
			F["SSX Power Comet"] >> A.powerComet
			F["SSX Year"] >> A.Year
			F["SSX Month"] >> A.Month
		for(var/area/Kaioshin/A in all_areas)
			F["Kaioshin"]>>A.icon_state
			F["Kaioshin Value"]>>A.Value
			F["Kaioshin Power Comet"] >> A.powerComet
			F["Kaioshin Year"] >> A.Year
			F["Kaioshin Month"] >> A.Month
	for(var/area/A in all_areas)
		spawn A.TimeLoop()

proc/SaveItems()
	set background = TRUE
	world<<"Saving items..."
	var/foundobjects=0
	if(fexists("data/ItemSave"))
		fdel("data/ItemSave")
	var/savefile/F=new("data/ItemSave")
	var/list/L=new
	for(var/obj/A)
		if(istype(A,/obj/Resources) && A:Value < 200000)
			continue
		if(istype(A, /obj/Connector) && !A.Builder)
			continue
		if(A.Savable && A.z)
			foundobjects++
			A.saved_x=A.x
			A.saved_y=A.y
			A.saved_z=A.z
			L+=A
	F["SavedItems"]<<L
	world<<"Items saved ([foundobjects] items)"

proc/LoadItems()
	var/amount=0
	if(fexists("data/ItemSave"))
		var/savefile/F=new("data/ItemSave")
		var/list/L=new
		F["SavedItems"]>>L
		for(var/obj/A in L)
			if(istype(A, /obj/Connector))
				continue
			amount+=1
			A.SafeTeleport(locate(A.saved_x,A.saved_y,A.saved_z))
	world<<"Items Loaded ([amount])."

	for(var/obj/items/Senzu/s in senzus) s.Senzu_grow()

#ifdef DEBUG
mob/Admin5/verb/RemoveConnectors()
	if(fexists("debug/ItemSave"))
		var/savefile/F = new("debug/ItemSave")
		var/list/L = new
		var/list/N = new
		F["SavedItems"] >> L
		for(var/obj/A in L)
			if(istype(A, /obj/Connector) || !A.Savable)
				continue
			N += A
		fdel("debug/ItemSave")
		F = new("debug/ItemSave")
		F << N
	world << "Removed Connectors and unsavable objs"
#endif

atom/var
	saved_x=1
	saved_y=1
	saved_z=1

mob/var/Savable_NPC

proc/Save_NPCs()
	var/savefile/F=new("data/NPCs")
	var/list/L=new
	for(var/mob/B)
		if(B.client || B.empty_player)
			continue
		if(B.z && B.Savable_NPC)
			B.saved_x=B.x
			B.saved_y=B.y
			B.saved_z=B.z
			L+=B
	F<<L

proc/Save_Bodies()
	var/savefile/F=new("data/Bodies")
	var/list/L=new
	for(var/mob/Body/B)
		if(B.z && B.displaykey && world.realtime < B.body_expire_time && B.body_expire_time)
			B.saved_x=B.x
			B.saved_y=B.y
			B.saved_z=B.z
			L+=B
		else if(B.z&&B.body_expire_time&&world.realtime>=B.body_expire_time) del(B)

	return //dont save dead bodies for now, seems uneccessary now that reboots happen very rarely

	clients << "[L.len] dead bodies saved"
	F<<L

proc/Load_Bodies()
	if(fexists("data/Bodies"))
		var/savefile/F=new("data/Bodies")
		var/list/L=new
		F>>L
		for(var/mob/B in L)
			B.SafeTeleport(locate(B.saved_x,B.saved_y,B.saved_z))
	
proc/SaveAdmins()
	var/savefile/S=new("data/Admin")
	S["Admins"]<<Admins

proc/LoadAdmins() if(fexists("data/Admin"))
	var/savefile/S=new("data/Admin")
	S["Admins"]>>Admins

proc/Save_Ban()
	var/savefile/S=new("data/BANS")
	S["Bans"]<<Bans

proc/Load_Ban()
	if(fexists("data/BANS"))
		var/savefile/S=new("data/BANS")
		S["Bans"]>>Bans

proc/SaveNotes()
	var/savefile/S=new("data/Notes")
	S[""]<<Notes

proc/LoadNotes() if(fexists("data/Notes"))
	var/savefile/S=new("data/Notes")
	S[""]>>Notes

proc/SaveStory()
	var/savefile/S=new("data/STORY")
	S["Storyline"]<<Story

proc/LoadStory() if(fexists("data/STORY"))
	var/savefile/S=new("data/STORY")
	S["Storyline"]>>Story

proc/SaveRanks()
	var/savefile/S=new("data/Ranks")
	S["rank_window"]<<rank_window

proc/LoadRanks() if(fexists("data/Ranks"))
	var/savefile/S=new("data/Ranks")
	if(S["rank_window"]) S["rank_window"]>>rank_window

proc/SaveJobs()
	var/savefile/S=new("data/Jobs")
	S[""]<<Jobs

proc/LoadJobs() if(fexists("data/Jobs"))
	var/savefile/S=new("data/Jobs")
	S[""]>>Jobs

proc/SaveLogin()
	var/savefile/S=new("data/Login Menu")
	S[""]<<Version_Notes

proc/LoadLogin() if(fexists("data/Login Menu"))
	var/savefile/S=new("data/Login Menu")
	S[""]>>Version_Notes

proc/SaveRules()
	var/savefile/S=new("data/Rules")
	S["Rules"]<<Rules

proc/LoadRules() if(fexists("data/Rules"))
	var/savefile/S=new("data/Rules")
	S["Rules"]>>Rules

var/lastMaxSpeedCheck = 0
proc/MaxSpeedCheck()
	set waitfor = 0
	if(lastMaxSpeedCheck + 100 > world.time) return
	lastMaxSpeedCheck = world.time

	var/Amount=1
	for(var/mob/P in players)
		Amount = Math.Max(P.Spd, Amount)
	Max_Speed=Amount
	var
		total_speed = 0
		total_players = 0
	for(var/mob/m in players)
		if(istype(m, /mob/new_troll)) continue
		if(m.z)
			total_speed += m.Spd
			total_players++
	if(total_players > 0) avg_speed = total_speed / total_players
var/list/admin_objects = new

proc/SaveAdminObjects()
	//set background=1
	var/savefile/f = new("Admin Placed Objects")
	for(var/obj/o in admin_objects)
		o.saved_x = o.x
		o.saved_y = o.y
		o.saved_z = o.z
	f["admin_objects"] << admin_objects

proc/LoadAdminObjects()
	if(fexists("Admin Placed Objects"))
		var/savefile/f = new("Admin Placed Objects")
		f["admin_objects"] >> admin_objects
		for(var/obj/o in admin_objects)
			o.x = o.saved_x
			o.y = o.saved_y
			o.z = o.saved_z






mob/proc/Respawn(butNotInShipArea)
	Go_to_spawn(butNotInShipArea = butNotInShipArea)

var/can_login=0

proc/Initialize()
	RestrictedMapLoop()
	AltRewardsLoop()
	AutoBPResetLoop()
	StartupScatterBigRocks()
	StartupSpawnKingBraalThrone()
	Delete_blank_mobs_loop()
	GarbageCollectLoop()
	Remove_all_nulls()
	GenerateBPOrbs()
	Zombie_reproduce_loop()
	Zombie_mutate_loop()
	fill_cached_blasts()
	check_dragonballs()
	hostban_protection()
	Hostban_check_loop()
	gains_limiter()
	Send_Bounty_Drone()
	Mute_Check()
	Auto_revive_loop()
	Load_Ban()
	world<<"Bans loaded"
	LoadYear()
	world<<"Year loaded"
	LoadAdmins()
	world<<"Admins loaded"
	Load_Gain()
	world<<"Gain loaded"
	LoadStory()
	world<<"Story loaded"
	LoadRules()
	world<<"Rules loaded"
	LoadNotes()
	world<<"Notes loaded"
	LoadLogin()
	world<<"Login loaded"
	LoadRanks()
	world<<"Ranks loaded"
	Load_Hero()
	world<<"Hero loaded"
	LoadJobs()
	world<<"Jobs loaded"
	Load_Vote()
	world<<"Voting loaded"
	Load_Misc()
	world<<"Misc Loaded"
	if(world.maxz<5) Map_Loaded=1
	spawn(25) MapLoad()
	spawn(30) LoadItems()
	spawn(35) LoadAdminObjects()
	spawn(35) if(1)
		Load_Bodies()
		world<<"Bodies loaded"
	spawn(35) if(1)
		Load_NPCs()
		world<<"NPCs loaded"
	AddBuilds()
	world<<"Builds added"
	Add_Technology()
	world<<"Technology added"
	Fill_Hair_List()
	world<<"Hair added"
	spawn Refresh_Stat_Record()
	Years()
	spawn SaveWorldRepeat()
	spawn Weather()
	spawn Save_Loop()
	spawn Tech_BP()
	Resources_Loop()
	Random_resource_drops()
	spawn ZeroDelayLoop()
	spawn HBTC_Timer()
	//Force_Update_Loop()
	Tournament_Loop()
	Load_Area()
	world<<"Area loaded"
	spawn Find_Max_Speed()
	Initialize_Gun_Icons()
	PopulateClothesChoices()
	for(var/A in typesof(/obj/Alien_Icons)) if(A!=/obj/Alien_Icons) Alien_Icons+=new A
	for(var/A in typesof(/obj/Demon_Icons)) if(A!=/obj/Demon_Icons) Demon_Icons+=new A
	//world<<"All files loaded."
	spawn(100) if(!npcs_enabled) disable_npcs()
	Monitor_Bugs()
	villain_damage_penalty_update()
	hide_destroyed_planets()
	Ship_on_destroyed_planet_loop()
	Initialize_db_menu_avatars()
	Car_wreck_loop()
	DeletePendingObjectsLoop()
	Wall_bot_loop()
	Auto_bounty_evil()
	Respawn_turfs()
	Villain_league_member_count_loop()
	League_paychecks()
	Turret_loop()
	Recover_health_loop()
	Recover_energy_loop()
	Immortality_zones()
	Ascension_loop()
	Bind_loop()
	Powerup_drain()
	Health_bar_update_loop()
	Update_ban_data_loop()
	SaitamaRotationLoop()
	EnableDragonBallsLoop()

	ssj4_desc=new/obj/Super_Yasai_4_Description

	spawn(10) can_login=1

	//because illegal science doesnt use objs any moer it uses types so clear old entries
	spawn(100) for(var/obj/o in Illegal_Science) Illegal_Science-=o

	spawn(100) if(fexists("LSX.log")) fdel("LSX.log")

	ActivatePixelMovement()
	ScatterFirefliesRandomlyOnMap()

	//GenerateMapFeatures()
	GenerateMapFeaturesByZone()
	GenerateUltraInstinctGraphics()
	AverageSpeedUpdater()
	DestroyShipsInShipsLoop()
	GodKiRealmKillLoop()
	WebhubLoop()
	InitFakePlayers()
	SpecialAnnouncementsLoop()
	ToggleBraalGym(wait = 300)
	CheckDeleteHellAltar(wait = 0)

obj/var/referenceObject = 0 //if this object is intended for the Science tab, Make verb, etc, it is a referenceObject

proc/DestroyShipsInShipsLoop()
	set waitfor=0
	sleep(600)
	while(1)
		for(var/obj/Ships/Ship/s in ships)
			if(s.referenceObject) continue
			var/area/a = s.get_area()
			var/turf/t = s.base_loc()
			if(a)
				if(a.type == /area/ship_area || a.type == /area/Final_Realm || a.type == /area/God_Ki_Realm)
					del(s)
			if(s && t)
				if(t.type == /turf/Other/Blank)
					del(s)
		sleep(600)

var/avg_speed = 100

proc/AverageSpeedUpdater()
	set waitfor=0
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

proc/SaveWorldRepeat() while(1)
	sleep(1.2 * 60 * 600)
	spawn SaveWorld()

proc/SaveWorld(save_map=1, allow_auto_reboot=1, delete_pending_objs=1)
	world<<"<font color=yellow><font size=3>Saving all items. Prepare for lag spike."
	sleep(5)
	GarbageCollect()
	SaveAdmins()
	SaveYear()
	Save_Gain()
	Save_Area()
	Save_Misc()
	Save_Vote()
	SaveAdminObjects()
	if(save_map)
		MapSave()
		SaveItems()
		Save_Bodies()
		Save_NPCs()
	if(allow_auto_reboot && world.time>auto_reboot_hours * 60 * 60 * 10 && !Tournament)
		Admin_Reboot(save_world=0)
	else
		if(delete_pending_objs) DeletePendingObjects()

proc/Save_Loop() while(1)
	sleep(1200)
	for(var/mob/A in players)
		A.Save()
		sleep(100)

mob/var/Can_Remake=1

mob/proc/Cant_Remake() if(fexists("Save/[key]"))
	var/savefile/F=new("Save/[key]")
	F["Can_Remake"]>>Can_Remake
	if(Can_Remake==0) return 1 //Cant use if(!Can_Vote) because if its 1 its the initial value and the entry is null

mob/proc/AutoTrainInSave() if(client&&fexists("Save/[key]"))
	var/savefile/F=new("Save/[key]")
	if(F["auto_train"]) return 1

var/player_saving_on=1

mob/proc/RemoveOverlaysThatDontSaveCorrectly()
	Remove_Say_Spark()
	TakeOffShurikenOverlaysOnSave()
	Remove_evil_overlay()
	Aura_Overlays(remove_only=1)
	overlays-=BlastCharge
	overlays-=block_shield
	overlays-='SBombGivePower.dmi'
	overlays -= ssj_blue_idle_aura
	overlays -= ultra_instinct_idle_aura
	overlays -= gold_form_idle_aura
	overlays -= shikon_aura
	overlays -= grab_absorb_overlay
	overlays -= fireOverlay

mob/proc/Save()
	if(is_saitama) return
	if(!player_saving_on) return
	if(key && displaykey && Savable)

		RemoveOverlaysThatDontSaveCorrectly()

		if(dbz_character)
			Save_dbz_character()
			return
		Record_offline_gains()

		var/turf/t = base_loc()
		if(t && !Regenerating)
			saved_x = t.x
			saved_y = t.y
			saved_z = t.z

		var/savefile/F=new("Save/[key]")
		F["Last_Used"]<<world.realtime
		Write(F)
		if(blocking) overlays+=block_shield
		Aura_Overlays()
		Evil_overlay()
		ShikonAura()
		ReApplyShurikenOverlaysOnSave()
		if(is_ssj_blue) overlays += ssj_blue_idle_aura
		if(ultra_instinct) overlays += ultra_instinct_idle_aura
		if(is_gold_form) overlays += gold_form_idle_aura
		if(grab_absorb_module && grabbedObject && strangling) overlays += grab_absorb_overlay

		SaveFeats()

mob/proc/Load() if(client)
	if(fexists("Save/[key]") && Map_Loaded)
		var/savefile/F = new("Save/[key]")
		Read(F)
		SafeTeleport(locate(saved_x, saved_y, saved_z))
		Other_Load_Stuff()
		LoadFeats()
		if(client) client.DeleteTitleScreen()
	else
		if(!Map_Loaded) alert(src,"You can not log in until the map loads.")
		else alert(src,"You do not have any characters on this server.")
		//Choose_Login() //send them back to the New/Load screen to try again

mob/proc/HasSave()
	if(!key) return
	if(fexists("Save/[key]")) return 1

var/banned_from_hosting

proc
	SaveCustomDecors()
		var/savefile/s = new("CustomDecors")
		s << customDecors

	LoadCustomDecors()
		if(!fexists("CustomDecors")) return
		var/savefile/s = new("CustomDecors")
		s >> customDecors
		DeleteSpamCustomDecors()

proc/Save_Misc()
	SaveCustomDecors()
	var/savefile/S=new("Misc")
	S["Status_Message"]<<Status_Message
	S["PVP"]<<PVP
	S["Earth_Only"]<<Earth_Only
	S["Automate_Tech_Power"]<<Automate_Tech_Power
	S["Tech_BP"]<<Tech_BP
	S["Illegal_Science"]<<Illegal_Science
	S["Admin_Logs"]<<Admin_Logs

	Stat_Settings["Modless"] = 1 //fix bug

	S["Bounties"]<<Bounties
	S["Council"]<<Council
	S["SP_Multiplier"]<<SP_Multiplier
	S["Allow_Ban_Votes"]<<Allow_Ban_Votes
	S["Resource_Multiplier"]<<Resource_Multiplier
	S["Can_Pwipe_Vote"]<<Can_Pwipe_Vote
	S["BP_Cap"]<<BP_Cap
	S["Ki_Disabled"]<<Ki_Disabled
	S["Gun_Power"]<<Gun_Power
	S["Illegal_Races"]<<Illegal_Races
	S["Ki_Gain"]<<Ki_Gain
	S["Perma_Death"]<<Perma_Death
	S["Tournament_Timer"]<<Tournament_Timer
	S["Stat_Leech"]<<Stat_Leech
	S["Start_BP"]<<Start_BP
	S["Learn_Disabled"]<<Learn_Disabled
	S["Train_Disabled"]<<Train_Disabled
	S["Base_Stat_Gain"]<<Base_Stat_Gain
	S["Tournament_Prize"]<<Tournament_Prize
	S["auto_revive_timer"]<<auto_revive_timer
	S["Safezones"]<<Safezones
	S["Server_Ratings"]<<Server_Ratings
	S["Auto_Rank"]<<Auto_Rank
	S["Safezone_Distance"]<<Safezone_Distance
	S["Turf_Strength"]<<Turf_Strength
	S["KO_Time"]<<KO_Time
	S["Server_Regeneration"]<<Server_Regeneration
	S["Server_Recovery"]<<Server_Recovery
	S["SSj_Mastery"]<<SSj_Mastery
	S["ssj_easy"]<<ssj_easy
	S["Max_Players"]<<Max_Players
	S["Max_Zombies"]<<Max_Zombies
	S["Prison_Money"]<<Prison_Money
	S["reincarnation_loss"]<<reincarnation_loss
	S["banned_from_hosting"]<<banned_from_hosting
	S["death_setting"]<<death_setting
	S["max_gravity"]<<max_gravity
	S["reincarnation_recovery"]<<reincarnation_recovery
	S["epic_list"]<<epic_list
	S["allow_age_choosing"]<<allow_age_choosing
	S["cyber_bp_mod"]<<cyber_bp_mod
	S["leech_strongest"]<<leech_strongest
	S["strongest_bp_gain_penalty"]<<strongest_bp_gain_penalty
	S["melee_power"]<<melee_power
	S["ki_power"]<<ki_power
	S["alignment_on"]<<alignment_on
	S["alts"]<<alts
	S["max_villains"]<<max_villains
	S["ssj_voting"]<<ssj_voting
	S["max_Yasai_percent"]<<max_Yasai_percent
	S["npcs_enabled"]<<npcs_enabled
	S["skill_tournament_chance"]<<skill_tournament_chance
	S["max_auto_leech"]<<max_auto_leech
	S["bp_tiers"]<<bp_tiers
	S["sagas"]<<sagas
	S["gain_tier_from_tournament"]<<gain_tier_from_tournament
	S["hero_training_gives_tier"]<<hero_training_gives_tier
	S["npcs_give_hbtc_keys"]<<npcs_give_hbtc_keys
	S["adapt_mod"]<<adapt_mod
	S["Illegal_learnables"]<<Illegal_learnables
	S["destroyed_planets"]<<destroyed_planets
	S["forced_injections"]<<forced_injections
	S["planet_destroy_immunity_time"]<<planet_destroy_immunity_time
	S["planet_destroy_bp_requirement"]<<planet_destroy_bp_requirement
	S["planet_destroy_uses"]<<planet_destroy_uses
	S["destroyable_planets"]<<destroyable_planets
	S["im_trapped_allowed"]<<im_trapped_allowed
	S["Tech_BP"]<<Tech_BP
	S["offline_gains"]<<offline_gains
	S["death_cures_vampires"]<<death_cures_vampires
	S["wall_INT_scaling"]<<wall_INT_scaling
	S["percent_of_wall_breakers"]<<percent_of_wall_breakers
	S["disabled_planets"]<<disabled_planets
	S["meteor_density"]<<meteor_density
	S["OOC"]<<OOC
	S["energy_cap"]<<energy_cap
	S["alt_limit"]<<alt_limit
	S["pwipe_vote_year"]<<pwipe_vote_year
	S["pwipe_vote_bp"]<<pwipe_vote_bp
	S["db_vampire_incurable"]<<db_vampire_incurable
	S["bank_list"]<<bank_list
	S["banked_items"]<<banked_items
	S["allow_diagonal_movement"]<<allow_diagonal_movement
	S["max_buff_bp"]<<max_buff_bp
	S["skill_tournament_bp_boost"]<<skill_tournament_bp_boost
	S["minimum_bounty"]<<minimum_bounty
	S["incline_on"]<<incline_on
	S["pwipe_delete_map"]<<pwipe_delete_map
	S["pwipe_turf_health"]<<pwipe_turf_health
	S["pwipe_delete_items"]<<pwipe_delete_items
	S["pwipe_cost_threshold"]<<pwipe_cost_threshold
	S["dbz_character_mode"]<<dbz_character_mode
	S["disabled_dbz_characters"]<<disabled_dbz_characters
	S["toxic_waste_on"]<<toxic_waste_on
	S["zombie_reproduce_mod"]<<zombie_reproduce_mod
	S["car_wreck_frequency"]<<car_wreck_frequency
	S["inspire_allowed"]<<inspire_allowed
	S["death_anger_gives_ssj"]<<death_anger_gives_ssj
	S["bp_soft_cap"]<<bp_soft_cap
	S["can_admin_vote"]<<can_admin_vote
	S["allow_guests"]<<allow_guests
	S["can_ignore_SI"]<<can_ignore_SI
	S["drone_instructions"]<<drone_instructions
	S["era_resets"]<<era_resets
	S["era_bp_division"]<<era_bp_division
	S["era_target_bp"]<<era_target_bp
	S["server_zenkai"]<<server_zenkai
	S["highest_era_bp"]<<highest_era_bp
	S["can_era_vote"]<<can_era_vote
	S["drop_items_on_death"]<<drop_items_on_death
	S["doors_kill"]<<doors_kill
	S["fps"]<<world.fps
	S["lose_resources_on_logout"]<<lose_resources_on_logout
	S["knowledge_cap_mod"]<<knowledge_cap_mod
	S["announce_dragon_balls"]<<announce_dragon_balls
	S["saitama_rotations"]<<saitama_rotations
	S["saitama_queue"]<<saitama_queue
	S["race_stats_only_mode"]<<race_stats_only_mode
	S["BASE_MOVE_DELAY"]<<BASE_MOVE_DELAY
	S["custom_buffs_allowed"]<<custom_buffs_allowed
	S["feats_on"]<<feats_on
	S["auto_reboot_hours"]<<auto_reboot_hours
	S["pwipe_delete_feats"]<<pwipe_delete_feats
	S["override_spawn"]<<override_spawn
	S["imitate_allowed"]<<imitate_allowed
	S["majin_auto_learn"]<<majin_auto_learn
	S["dead_power_loss"]<<dead_power_loss
	S["keep_body_loss"]<<keep_body_loss
	S["client_fps"] << client_fps
	S["zombie_power_mult"] << zombie_power_mult
	S["drone_genocide_off"] << drone_genocide_off
	S["drone_power"] << drone_power
	S["prohibited_admins"] << prohibited_admins
	S["voting_allowed"] << voting_allowed
	S["show_names_in_ooc"] << show_names_in_ooc
	S["can_cyber_KOd_people"] << can_cyber_KOd_people
	S["building_price_mult"] << building_price_mult
	S["admins_build_free"] << admins_build_free
	S["exempt_from_host_check"] << exempt_from_host_check
	S["pack_KT_allowed"] << pack_KT_allowed
	S["body_swap_time_limit"] << body_swap_time_limit
	S["max_screen_size"] << max_screen_size
	S["gta5_wasted"] << gta5_wasted
	S["resource_version"] << resource_version
	S["admin_allow_base_orbs"] << admin_allow_base_orbs
	S["limit_bind"] << limit_bind
	S["can_go_in_void"] << can_go_in_void
	S["can_build_in_void"] << can_build_in_void
	S["admins_can_go_in_void"] << admins_can_go_in_void
	S["admins_can_build_in_void"] << admins_can_build_in_void
	S["lower_stats_off"] << lower_stats_off
	S["king_of_Braal"] << king_of_Braal
	S["highest_player_count"] << highest_player_count
	S["dodging_mode"] << dodging_mode
	S["battleground_spawn_choice_on"] << battleground_spawn_choice_on
	S["auto_reset_bp_at"] << auto_reset_bp_at
	S["allow_dragon_rush"] << allow_dragon_rush
	S["force_32_pix_movement"] << force_32_pix_movement
	S["global_stun_mod"] << global_stun_mod
	S["allow_ultra_instinct"] << allow_ultra_instinct
	S["explosions_off"] << explosions_off
	S["dust_off"] << dust_off
	S["shockwaves_off"] << shockwaves_off
	S["stun_stops_movement"] << stun_stops_movement
	S["allow_god_ki"] << allow_god_ki
	S["old_age_on"] << old_age_on
	S["lssj_common_race"] << lssj_common_race
	S["icer_common_race"] << icer_common_race
	S["helperQuestsOn"] << helperQuestsOn
	S["hakai_bp_advantage_needed"] << hakai_bp_advantage_needed
	S["hakai_wipes_character"] << hakai_wipes_character
	S["gravity_mastery_mod"] << gravity_mastery_mod
	S["anyone_can_enter_hbtc"] << anyone_can_enter_hbtc
	S["give_countdown_verb"] << give_countdown_verb
	S["give_whisper_verb"] << give_whisper_verb
	S["allow_good_bounties"] << allow_good_bounties
	S["hide_energy_enabled"] << hide_energy_enabled
	S["drone_limit"] << drone_limit
	//S["customDecors"] << customDecors //IT WAS A BIG MISTAKE TO SAVE THIS HERE BECAUSE IT MEANS THE MISC FILE CAN NO LONGER BE TRADED BETWEEN SERVERS
	S["godKiMasteryMod"] << godKiMasteryMod
	S["maxBanTime"] << maxBanTime
	S["customBuildAllowed"] << customBuildAllowed
	S["checkpointBuildDist"] << checkpointBuildDist
	S["anns"] << anns
	S["npcDensity"] << npcDensity
	S["knockback_mod"] << knockback_mod
	S["BraalGym"] << BraalGym
	S["hellAltar"] << hellAltar
	S["battlegroundSystem"] << battlegroundSystem
	S["trainingHours"] << trainingHours
	S["trainingRestoreHours"] << trainingRestoreHours
	S["hostAllowsPacksOnRP"] << hostAllowsPacksOnRP
	S["God_FistMod"] << God_FistMod

proc/Load_Misc()
	LoadCustomDecors()
	if(!fexists("Misc")) return
	var/savefile/S=new("Misc")
	S["Status_Message"]>>Status_Message
	S["PVP"]>>PVP
	S["Earth_Only"]>>Earth_Only
	S["Automate_Tech_Power"]>>Automate_Tech_Power
	S["Tech_BP"]>>Tech_BP
	S["Illegal_Science"]>>Illegal_Science
	S["Admin_Logs"]>>Admin_Logs
	S["Bounties"]>>Bounties
	S["Council"]>>Council
	S["SP_Multiplier"]>>SP_Multiplier
	S["Allow_Ban_Votes"]>>Allow_Ban_Votes
	S["Resource_Multiplier"]>>Resource_Multiplier
	S["Can_Pwipe_Vote"]>>Can_Pwipe_Vote
	S["BP_Cap"]>>BP_Cap
	S["Ki_Disabled"]>>Ki_Disabled
	S["Gun_Power"]>>Gun_Power
	S["Illegal_Races"]>>Illegal_Races
	S["Ki_Gain"]>>Ki_Gain
	S["Perma_Death"]>>Perma_Death
	S["Tournament_Timer"]>>Tournament_Timer
	S["Stat_Leech"]>>Stat_Leech
	S["Start_BP"]>>Start_BP
	S["Learn_Disabled"]>>Learn_Disabled
	S["Train_Disabled"]>>Train_Disabled
	S["Base_Stat_Gain"]>>Base_Stat_Gain
	S["Tournament_Prize"]>>Tournament_Prize
	S["auto_revive_timer"]>>auto_revive_timer
	S["Safezones"]>>Safezones
	S["Server_Ratings"]>>Server_Ratings
	S["Auto_Rank"]>>Auto_Rank
	S["Safezone_Distance"]>>Safezone_Distance
	S["Turf_Strength"]>>Turf_Strength
	S["KO_Time"]>>KO_Time
	S["Server_Regeneration"]>>Server_Regeneration
	S["Server_Recovery"]>>Server_Recovery
	S["SSj_Mastery"]>>SSj_Mastery
	S["ssj_easy"]>>ssj_easy
	S["Max_Players"]>>Max_Players
	S["Max_Zombies"]>>Max_Zombies
	S["Prison_Money"]>>Prison_Money
	S["reincarnation_loss"]>>reincarnation_loss
	S["banned_from_hosting"]>>banned_from_hosting
	S["death_setting"]>>death_setting
	S["max_gravity"]>>max_gravity
	S["reincarnation_recovery"]>>reincarnation_recovery
	S["epic_list"]>>epic_list
	S["allow_age_choosing"]>>allow_age_choosing
	S["cyber_bp_mod"]>>cyber_bp_mod
	S["leech_strongest"]>>leech_strongest
	S["strongest_bp_gain_penalty"]>>strongest_bp_gain_penalty
	S["melee_power"]>>melee_power
	S["ki_power"]>>ki_power
	S["alignment_on"]>>alignment_on
	S["alts"]>>alts
	S["max_villains"]>>max_villains
	S["ssj_voting"]>>ssj_voting
	S["max_Yasai_percent"]>>max_Yasai_percent
	S["npcs_enabled"]>>npcs_enabled
	S["skill_tournament_chance"]>>skill_tournament_chance
	S["max_auto_leech"]>>max_auto_leech
	S["bp_tiers"]>>bp_tiers
	S["sagas"]>>sagas
	S["gain_tier_from_tournament"]>>gain_tier_from_tournament
	S["hero_training_gives_tier"]>>hero_training_gives_tier
	S["npcs_give_hbtc_keys"]>>npcs_give_hbtc_keys
	S["adapt_mod"]>>adapt_mod
	S["Illegal_learnables"]>>Illegal_learnables
	S["destroyed_planets"]>>destroyed_planets
	S["forced_injections"]>>forced_injections
	S["planet_destroy_immunity_time"]>>planet_destroy_immunity_time
	S["planet_destroy_bp_requirement"]>>planet_destroy_bp_requirement
	S["planet_destroy_uses"]>>planet_destroy_uses
	S["destroyable_planets"]>>destroyable_planets
	S["im_trapped_allowed"]>>im_trapped_allowed
	S["Tech_BP"]>>Tech_BP
	S["offline_gains"]>>offline_gains
	S["death_cures_vampires"]>>death_cures_vampires
	S["wall_INT_scaling"]>>wall_INT_scaling
	S["percent_of_wall_breakers"]>>percent_of_wall_breakers
	S["disabled_planets"]>>disabled_planets
	S["meteor_density"]>>meteor_density
	S["OOC"]>>OOC
	S["energy_cap"]>>energy_cap
	S["alt_limit"]>>alt_limit
	S["pwipe_vote_year"]>>pwipe_vote_year
	S["pwipe_vote_bp"]>>pwipe_vote_bp
	S["db_vampire_incurable"]>>db_vampire_incurable
	S["bank_list"]>>bank_list
	S["banked_items"]>>banked_items
	S["allow_diagonal_movement"]>>allow_diagonal_movement
	S["max_buff_bp"]>>max_buff_bp
	S["skill_tournament_bp_boost"]>>skill_tournament_bp_boost
	S["minimum_bounty"]>>minimum_bounty
	S["incline_on"]>>incline_on
	S["pwipe_delete_map"]>>pwipe_delete_map
	S["pwipe_turf_health"]>>pwipe_turf_health
	S["pwipe_delete_items"]>>pwipe_delete_items
	S["pwipe_cost_threshold"]>>pwipe_cost_threshold
	S["dbz_character_mode"]>>dbz_character_mode
	S["disabled_dbz_characters"]>>disabled_dbz_characters
	S["toxic_waste_on"]>>toxic_waste_on
	S["zombie_reproduce_mod"]>>zombie_reproduce_mod
	S["car_wreck_frequency"]>>car_wreck_frequency
	S["inspire_allowed"]>>inspire_allowed
	S["death_anger_gives_ssj"]>>death_anger_gives_ssj
	S["bp_soft_cap"]>>bp_soft_cap
	if("can_admin_vote" in S) S["can_admin_vote"]>>can_admin_vote
	if("allow_guests" in S) S["allow_guests"]>>allow_guests
	if("can_ignore_SI" in S) S["can_ignore_SI"]>>can_ignore_SI
	if("drone_instructions" in S) S["drone_instructions"]>>drone_instructions
	if("era_resets" in S) S["era_resets"]>>era_resets
	if("era_bp_division" in S) S["era_bp_division"]>>era_bp_division
	if("era_target_bp" in S) S["era_target_bp"]>>era_target_bp
	if("server_zenkai" in S) S["server_zenkai"]>>server_zenkai
	if("highest_era_bp" in S) S["highest_era_bp"]>>highest_era_bp
	if("can_era_vote" in S) S["can_era_vote"]>>can_era_vote
	if("drop_items_on_death" in S) S["drop_items_on_death"]>>drop_items_on_death
	if("doors_kill" in S) S["doors_kill"]>>doors_kill
	if("fps" in S) S["fps"]>>world.fps
	if("lose_resources_on_logout" in S) S["lose_resources_on_logout"]>>lose_resources_on_logout
	if("knowledge_cap_mod" in S) S["knowledge_cap_mod"]>>knowledge_cap_mod
	if("announce_dragon_balls" in S) S["announce_dragon_balls"]>>announce_dragon_balls
	if("saitama_rotations" in S) S["saitama_rotations"]>>saitama_rotations
	if("saitama_queue" in S) S["saitama_queue"]>>saitama_queue
	if("race_stats_only_mode" in S) S["race_stats_only_mode"]>>race_stats_only_mode
	if("BASE_MOVE_DELAY" in S) S["BASE_MOVE_DELAY"]>>BASE_MOVE_DELAY
	if("custom_buffs_allowed" in S) S["custom_buffs_allowed"]>>custom_buffs_allowed
	if("feats_on" in S) S["feats_on"]>>feats_on
	if("auto_reboot_hours" in S) S["auto_reboot_hours"]>>auto_reboot_hours
	if("pwipe_delete_feats" in S) S["pwipe_delete_feats"]>>pwipe_delete_feats
	if("override_spawn" in S) S["override_spawn"]>>override_spawn
	if("imitate_allowed" in S) S["imitate_allowed"]>>imitate_allowed
	if("majin_auto_learn" in S) S["majin_auto_learn"]>>majin_auto_learn
	if("dead_power_loss" in S) S["dead_power_loss"]>>dead_power_loss
	if("keep_body_loss" in S) S["keep_body_loss"]>>keep_body_loss
	if("client_fps" in S) S["client_fps"] >> client_fps
	if("zombie_power_mult" in S) S["zombie_power_mult"] >> zombie_power_mult
	if("drone_genocide_off" in S) S["drone_genocide_off"] >> drone_genocide_off
	if("drone_power" in S) S["drone_power"] >> drone_power
	if("prohibited_admins" in S) S["prohibited_admins"] >> prohibited_admins
	if("voting_allowed" in S) S["voting_allowed"] >> voting_allowed
	if("show_names_in_ooc" in S) S["show_names_in_ooc"] >> show_names_in_ooc
	if("can_cyber_KOd_people" in S) S["can_cyber_KOd_people"] >> can_cyber_KOd_people
	if("building_price_mult" in S) S["building_price_mult"] >> building_price_mult
	if("admins_build_free" in S) S["admins_build_free"] >> admins_build_free
	if("exempt_from_host_check" in S) S["exempt_from_host_check"] >> exempt_from_host_check
	if("pack_KT_allowed" in S) S["pack_KT_allowed"] >> pack_KT_allowed
	if("body_swap_time_limit" in S) S["body_swap_time_limit"] >> body_swap_time_limit
	if("max_screen_size" in S) S["max_screen_size"] >> max_screen_size
	if("gta5_wasted" in S) S["gta5_wasted"] >> gta5_wasted
	if("resource_version" in S) S["resource_version"] >> resource_version
	if("admin_allow_base_orbs" in S) S["admin_allow_base_orbs"] >> admin_allow_base_orbs
	if("limit_bind" in S) S["limit_bind"] >> limit_bind
	if("can_go_in_void" in S) S["can_go_in_void"] >> can_go_in_void
	if("can_build_in_void" in S) S["can_build_in_void"] >> can_build_in_void
	if("admins_can_go_in_void" in S) S["admins_can_go_in_void"] >> admins_can_go_in_void
	if("admins_can_build_in_void" in S) S["admins_can_build_in_void"] >> admins_can_build_in_void
	if("lower_stats_off" in S) S["lower_stats_off"] >> lower_stats_off
	if("king_of_Braal" in S) S["king_of_Braal"] >> king_of_Braal
	if("highest_player_count" in S) S["highest_player_count"] >> highest_player_count
	if("dodging_mode" in S) S["dodging_mode"] >> dodging_mode
	if("battleground_spawn_choice_on" in S) S["battleground_spawn_choice_on"] >> battleground_spawn_choice_on
	if("auto_reset_bp_at" in S) S["auto_reset_bp_at"] >> auto_reset_bp_at
	if("allow_dragon_rush" in S) S["allow_dragon_rush"] >> allow_dragon_rush
	if("force_32_pix_movement" in S) S["force_32_pix_movement"] >> force_32_pix_movement
	if("global_stun_mod" in S) S["global_stun_mod"] >> global_stun_mod
	if("allow_ultra_instinct" in S) S["allow_ultra_instinct"] >> allow_ultra_instinct
	if("explosions_off" in S) S["explosions_off"] >> explosions_off
	if("dust_off" in S) S["dust_off"] >> dust_off
	if("shockwaves_off" in S) S["shockwaves_off"] >> shockwaves_off
	if("stun_stops_movement" in S) S["stun_stops_movement"] >> stun_stops_movement
	if("allow_god_ki" in S) S["allow_god_ki"] >> allow_god_ki
	if("old_age_on" in S) S["old_age_on"] >> old_age_on
	if("lssj_common_race" in S) S["lssj_common_race"] >> lssj_common_race
	if("icer_common_race" in S) S["icer_common_race"] >> icer_common_race
	if("helperQuestsOn" in S) S["helperQuestsOn"] >> helperQuestsOn
	if("hakai_bp_advantage_needed" in S) S["hakai_bp_advantage_needed"] >> hakai_bp_advantage_needed
	if("hakai_wipes_character" in S) S["hakai_wipes_character"] >> hakai_wipes_character
	if("gravity_mastery_mod" in S) S["gravity_mastery_mod"] >> gravity_mastery_mod
	if("anyone_can_enter_hbtc" in S) S["anyone_can_enter_hbtc"] >> anyone_can_enter_hbtc
	if("give_countdown_verb" in S) S["give_countdown_verb"] >> give_countdown_verb
	if("give_whisper_verb" in S) S["give_whisper_verb"] >> give_whisper_verb
	if("allow_good_bounties" in S) S["allow_good_bounties"] >> allow_good_bounties
	if("hide_energy_enabled" in S) S["hide_energy_enabled"] >> hide_energy_enabled
	if("drone_limit" in S) S["drone_limit"] >> drone_limit
	if("anns" in S) S["anns"] >> anns

	//hopefully this entry will cease to exist in here from now on as if i am correct SaveMisc() RECREATES the savefile each time it saves so
	//since SaveMisc() no longer adds a customDecors entry, it wont be there anymore. but still be there for people who using the old one to safely transition
	if("customDecors" in S)
		S["customDecors"] >> customDecors
		//i had to put this here to get rid of spammed ones that were never changed from their initial icon
		DeleteSpamCustomDecors()

	if("godKiMasteryMod" in S) S["godKiMasteryMod"] >> godKiMasteryMod
	if("maxBanTime" in S) S["maxBanTime"] >> maxBanTime
	if("customBuildAllowed" in S) S["customBuildAllowed"] >> customBuildAllowed
	if("checkpointBuildDist" in S) S["checkpointBuildDist"] >> checkpointBuildDist
	if("npcDensity" in S) S["npcDensity"] >> npcDensity
	if("knockback_mod" in S) S["knockback_mod"] >> knockback_mod
	if("BraalGym" in S) S["BraalGym"] >> BraalGym
	if("hellAltar" in S) S["hellAltar"] >> hellAltar
	if("battlegroundSystem" in S) S["battlegroundSystem"] >> battlegroundSystem
	if("trainingHours" in S) S["trainingHours"] >> trainingHours
	if("trainingRestoreHours" in S) S["trainingRestoreHours"] >> trainingRestoreHours
	if("hostAllowsPacksOnRP" in S) S["hostAllowsPacksOnRP"] >> hostAllowsPacksOnRP
	if("God_FistMod" in S) S["God_FistMod"] >> God_FistMod

	//offline_gains = 1 //forced on. no more option for admins to turn it off
	//feats_on = 1 //forced on now (no. bad for rp to have forced on)
	pwipe_delete_feats = 0
	if(Turf_Strength > max_turf_str) Turf_Strength = max_turf_str

	if(auto_revive_timer < minReviveTimer) auto_revive_timer = minReviveTimer

	//if(banned_from_hosting) shutdown()

proc/Save_Hero()
	var/savefile/S=new("Hero")
	S<<hero
proc/Load_Hero() if(fexists("Hero"))
	var/savefile/S=new("Hero")
	S>>hero
proc/SaveYear()
	var/savefile/S=new("Year")
	S["Year"]<<Year
	S["Speed"]<<Year_Speed
proc/LoadYear() if(fexists("Year"))
	var/savefile/S=new("Year")
	S["Year"]>>Year
	S["Speed"]>>Year_Speed

proc/Save_Vote()
	var/savefile/S=new("Votes");S["Vote Banned"]<<Vote_Banned;S["RP President"]<<RP_President;S["Head Admin"]<<Head_Admin

proc/Load_Vote() if(fexists("Votes"))
	var/savefile/S=new("Votes");S["Vote Banned"]>>Vote_Banned;S["RP President"]>>RP_President;S["Head Admin"]>>Head_Admin

proc/Save_Area()
	var/savefile/F=new("Areas")
	for(var/area/Checkpoint/A in all_areas)
		F["Checkpoint"]<<A.icon_state
		F["Checkpoint Value"]<<A.Value
		break
	for(var/area/Heaven/A in all_areas)
		F["Heaven"]<<A.icon_state
		F["Heaven Value"]<<A.Value
		break
	for(var/area/Hell/A in all_areas)
		F["Hell"]<<A.icon_state
		F["Hell Value"]<<A.Value
		break
	for(var/area/Space/A in all_areas)
		F["Space"]<<A.icon_state
		F["Space Value"]<<A.Value
		break
	for(var/area/Sonku/A in all_areas)
		F["Sonku"]<<A.icon_state
		F["Sonku Value"]<<A.Value
		break
	for(var/area/Earth/A in all_areas)
		F["Earth"]<<A.icon_state
		F["Earth Value"]<<A.Value
		break
	for(var/area/Puranto/A in all_areas)
		F["Puranto"]<<A.icon_state
		F["Puranto Value"]<<A.Value
		break
	for(var/area/Braal/A in all_areas)
		F["Braal"]<<A.icon_state
		F["Braal Value"]<<A.Value
		break
	for(var/area/Arconia/A in all_areas)
		F["Arconia"]<<A.icon_state
		F["Arconia Value"]<<A.Value
		break
	for(var/area/Ice/A in all_areas)
		F["Frost Lord"]<<A.icon_state
		F["Frost Lord Value"]<<A.Value
		break
	for(var/area/Android/A in all_areas)
		F["Android"]<<A.icon_state
		F["Android Value"]<<A.Value
		break
	for(var/area/Jungle/A in all_areas)
		F["Jungle"]<<A.icon_state
		F["Jungle Value"]<<A.Value
		break
	for(var/area/Desert/A in all_areas)
		F["Desert"]<<A.icon_state
		F["Desert Value"]<<A.Value
		break
	for(var/area/SSX/A in all_areas)
		F["SSX"]<<A.icon_state
		F["SSX Value"]<<A.Value
	for(var/area/Kaioshin/A in all_areas)
		F["Kaioshin"]<<A.icon_state
		F["Kaioshin Value"]<<A.Value
proc/Load_Area() if(fexists("Areas"))
	var/savefile/F=new("Areas")
	for(var/area/Earth/A in all_areas)
		F["Earth"]>>A.icon_state
		F["Earth Value"]>>A.Value
	for(var/area/Puranto/A in all_areas)
		F["Puranto"]>>A.icon_state
		F["Puranto Value"]>>A.Value
	for(var/area/Braal/A in all_areas)
		F["Braal"]>>A.icon_state
		F["Braal Value"]>>A.Value
	for(var/area/Arconia/A in all_areas)
		F["Arconia"]>>A.icon_state
		F["Arconia Value"]>>A.Value
	for(var/area/Ice/A in all_areas)
		F["Frost Lord"]>>A.icon_state
		F["Frost Lord Value"]>>A.Value
	for(var/area/Jungle/A in all_areas)
		F["Jungle"]>>A.icon_state
		F["Jungle Value"]>>A.Value
	for(var/area/Desert/A in all_areas)
		F["Desert"]>>A.icon_state
		F["Desert Value"]>>A.Value
	for(var/area/Checkpoint/A in all_areas)
		F["Checkpoint"]>>A.icon_state
		F["Checkpoint Value"]>>A.Value
	for(var/area/Heaven/A in all_areas)
		F["Heaven"]>>A.icon_state
		F["Heaven Value"]>>A.Value
	for(var/area/Hell/A in all_areas)
		F["Hell"]>>A.icon_state
		F["Hell Value"]>>A.Value
	for(var/area/Space/A in all_areas)
		F["Space"]>>A.icon_state
		F["Space Value"]>>A.Value
	for(var/area/Sonku/A in all_areas)
		F["Sonku"]>>A.icon_state
		F["Sonku Value"]>>A.Value
	for(var/area/SSX/A in all_areas)
		F["SSX"]>>A.icon_state
		F["SSX Value"]>>A.Value
	for(var/area/Kaioshin/A in all_areas)
		F["Kaioshin"]>>A.icon_state
		F["Kaioshin Value"]>>A.Value

proc/SaveItems()
	set background=1
	world<<"Saving items..."
	var/foundobjects=0
	var/savefile/F=new("ItemSave")
	var/list/L=new
	for(var/obj/A) if(A.Savable && A.z)
		if(!istype(A,/obj/Resources) || A:Value>=200000)
			foundobjects++
			A.saved_x=A.x
			A.saved_y=A.y
			A.saved_z=A.z
			L+=A
	F["SavedItems"]<<L
	world<<"Items saved ([foundobjects] items)"

proc/LoadItems()
	var/amount=0
	if(fexists("ItemSave"))
		var/savefile/F=new("ItemSave")
		var/list/L=new
		F["SavedItems"]>>L
		for(var/obj/A in L)
			amount+=1
			A.SafeTeleport(locate(A.saved_x,A.saved_y,A.saved_z))
		for(var/mob/A in L)
			amount+=1
			A.SafeTeleport(locate(A.saved_x,A.saved_y,A.saved_z))
	world<<"Items Loaded ([amount])."

	for(var/obj/items/Senzu/s in senzus) s.Senzu_grow()

atom/var
	saved_x=1
	saved_y=1
	saved_z=1
mob/var/Savable_NPC
proc/Save_NPCs()
	var/savefile/F=new("NPCs")
	var/list/L=new
	for(var/mob/B) if(B.z&&B.Savable_NPC&&!B.client&&!B.empty_player)
		B.saved_x=B.x
		B.saved_y=B.y
		B.saved_z=B.z
		L+=B
	F<<L
proc/Load_NPCs()
	if(fexists("NPCs"))
		var/savefile/F=new("NPCs")
		var/list/L=new
		F>>L
		for(var/mob/B in L) B.SafeTeleport(locate(B.saved_x,B.saved_y,B.saved_z))
proc/Save_Bodies()
	var/savefile/F=new("Bodies")
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
	if(fexists("Bodies"))
		var/savefile/F=new("Bodies")
		var/list/L=new
		F>>L
		for(var/mob/B in L) B.SafeTeleport(locate(B.saved_x,B.saved_y,B.saved_z))
proc/SaveAdmins()
	var/savefile/S=new("Admin");S["Admins"]<<Admins
proc/LoadAdmins() if(fexists("Admin"))
	var/savefile/S=new("Admin");S["Admins"]>>Admins
proc/Save_Ban()
	var/savefile/S=new("BANS")
	S["Bans"]<<Bans
proc/Load_Ban()
	if(fexists("BANS"))
		var/savefile/S=new("BANS")
		S["Bans"]>>Bans
proc/Save_Gain()
	var/savefile/S=new("GAIN")
	S["GAIN"]<<Gain
proc/Load_Gain() if(fexists("GAIN"))
	var/savefile/S=new("GAIN")
	S["GAIN"]>>Gain
proc/SaveNotes()
	var/savefile/S=new("Notes")
	S[""]<<Notes
proc/LoadNotes() if(fexists("Notes"))
	var/savefile/S=new("Notes")
	S[""]>>Notes
proc/SaveStory()
	var/savefile/S=new("STORY")
	S["Storyline"]<<Story
proc/LoadStory() if(fexists("STORY"))
	var/savefile/S=new("STORY")
	S["Storyline"]>>Story
proc/SaveRanks()
	var/savefile/S=new("Ranks")
	S["rank_window"]<<rank_window
proc/LoadRanks() if(fexists("Ranks"))
	var/savefile/S=new("Ranks")
	if(S["rank_window"]) S["rank_window"]>>rank_window
proc/SaveJobs()
	var/savefile/S=new("Jobs")
	S[""]<<Jobs
proc/LoadJobs() if(fexists("Jobs"))
	var/savefile/S=new("Jobs")
	S[""]>>Jobs
proc/SaveLogin()
	var/savefile/S=new("Login Menu")
	S[""]<<Version_Notes
proc/LoadLogin() if(fexists("Login Menu"))
	var/savefile/S=new("Login Menu")
	S[""]>>Version_Notes
proc/SaveRules()
	var/savefile/S=new("Rules")
	S["Rules"]<<Rules
proc/LoadRules() if(fexists("Rules"))
	var/savefile/S=new("Rules")
	S["Rules"]>>Rules
proc/Find_Max_Speed() while(1)
	var/Amount=1
	for(var/mob/P in players) if(P.Spd>Amount) Amount=P.Spd
	Max_Speed=Amount
	sleep(600)
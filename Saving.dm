mob/proc/Respawn()
	Go_to_spawn()

var/can_login=0

proc/Initialize()

	Delete_blank_mobs_loop()

	Remove_all_nulls()
	Zombie_reproduce_loop()
	Zombie_mutate_loop()
	fill_cached_blasts()
	check_dragonballs()
	hostban_protection()
	hosting_loop()
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
	spawn(50) MapLoad()
	spawn(50) LoadItems()
	spawn(50) if(1)
		Load_Bodies()
		world<<"Bodies loaded"
	spawn(50) if(1)
		Load_NPCs()
		world<<"NPCs loaded"
	AddBuilds()
	world<<"Builds added"
	Add_Technology()
	world<<"Technology added"
	Fill_Hair_List()
	world<<"Hair added"
	spawn Refresh_Stat_Record()
	spawn Years()
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
	for(var/A in typesof(/obj/items/Clothes)) if(A!=/obj/items/Clothes)
		var/obj/items/Clothes/c=new A
		Clothing+=c
		var/obj/weights_icon/wi=new
		wi.icon=c.icon
		weights_icons+=wi
	for(var/A in typesof(/obj/Alien_Icons)) if(A!=/obj/Alien_Icons) Alien_Icons+=new A
	for(var/A in typesof(/obj/Demon_Icons)) if(A!=/obj/Demon_Icons) Demon_Icons+=new A
	//world<<"All files loaded."
	spawn(100) if(!npcs_enabled) disable_npcs()
	Monitor_Bugs()
	villain_damage_penalty_update()
	hide_destroyed_planets()
	Ship_on_destroyed_planet_loop()
	Initialize_dbz_avatars()
	Car_wreck_loop()
	Delete_pending_objects_loop()
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
	spawn(100) can_login=1

	//because illegal science doesnt use objs any moer it uses types so clear old entries
	spawn(100) for(var/obj/o in Illegal_Science) Illegal_Science-=o

	spawn(100) if(fexists("LSX.log")) fdel("LSX.log")

proc/SaveWorldRepeat() while(1)
	sleep(1.2*60*600)
	spawn SaveWorld()
proc/SaveWorld(save_map=1,allow_auto_reboot=1,delete_pending_objs=1)
	world<<"<font color=yellow><font size=3>Saving all items. Prepare for lag spike."
	sleep(5)
	SaveAdmins()
	SaveYear()
	Save_Gain()
	Save_Area()
	Save_Misc()
	Save_Vote()
	if(save_map)
		MapSave()
		SaveItems()
		Save_Bodies()
		Save_NPCs()
	if(allow_auto_reboot && world.time>6*60*60*10 && !Tournament) Admin_Reboot(save_world=0)
	else
		//var/deletes=0
		if(delete_pending_objs) for(var/obj/o in pending_object_delete_list)
			pending_object_delete_list-=o
			del(o)
			//deletes++
			//if(deletes>1000) break
proc/Save_Loop() while(1)
	sleep(6000)
	for(var/mob/A in players)
		A.Save()
		sleep(150)
mob/var/Can_Remake=1
mob/proc/Cant_Remake() if(fexists("Save/[key]"))
	var/savefile/F=new("Save/[key]")
	F["Can_Remake"]>>Can_Remake
	if(Can_Remake==0) return 1 //Cant use if(!Can_Vote) because if its 1 its the initial value and the entry is null
mob/proc/auto_train_in_save() if(client&&fexists("Save/[key]"))
	var/savefile/F=new("Save/[key]")
	if(F["auto_train"]) return 1

var/player_saving_on=1

mob/proc/Save()
	if(!player_saving_on) return
	if(key&&displaykey&&Savable)
		Remove_evil_overlay()
		Aura_Overlays(remove_only=1)
		overlays-=BlastCharge
		if(dbz_character)
			Save_dbz_character()
			return
		Record_offline_gains()
		if(z&&!Regenerating)
			saved_x=x
			saved_y=y
			saved_z=z
		if(Ship&&Ship.z)
			saved_x=Ship.x
			saved_y=Ship.y
			saved_z=Ship.z
		var/savefile/F=new("Save/[key]")
		F["Last_Used"]<<world.realtime
		Write(F)
		Aura_Overlays()
		Evil_overlay()
mob/proc/Load() if(client)
	if(fexists("Save/[key]")&&Map_Loaded)
		var/savefile/F=new("Save/[key]")
		Read(F)
		loc=locate(saved_x,saved_y,saved_z)
		Other_Load_Stuff()
	else
		if(!Map_Loaded) alert(src,"You can not log in until the map loads.")
		else alert(src,"You do not have any characters on this server.")
		Choose_Login()
var/banned_from_hosting
proc/Save_Misc()
	var/savefile/S=new("Misc")
	S["Status_Message"]<<Status_Message
	S["PVP"]<<PVP
	S["Earth_Only"]<<Earth_Only
	S["Automate_Tech_Power"]<<Automate_Tech_Power
	S["Tech_BP"]<<Tech_BP
	S["Illegal_Science"]<<Illegal_Science
	S["Admin_Logs"]<<Admin_Logs
	S["Stat Settings"]<<Stat_Settings
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
	S["Pixel_Movement"]<<Pixel_Movement
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
	S["max_Saiyan_percent"]<<max_Saiyan_percent
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
	S["auto_revive_bp"]<<auto_revive_bp
	S["dbz_character_mode"]<<dbz_character_mode
	S["disabled_dbz_characters"]<<disabled_dbz_characters
	S["toxic_waste_on"]<<toxic_waste_on
	S["zombie_reproduce_mod"]<<zombie_reproduce_mod
	S["car_wreck_frequency"]<<car_wreck_frequency
	S["inspire_allowed"]<<inspire_allowed
	S["death_anger_gives_ssj"]<<death_anger_gives_ssj
	S["server_mode"]<<server_mode
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
proc/Load_Misc() if(fexists("Misc"))
	var/savefile/S=new("Misc")
	S["Status_Message"]>>Status_Message
	S["PVP"]>>PVP
	S["Earth_Only"]>>Earth_Only
	S["Automate_Tech_Power"]>>Automate_Tech_Power
	S["Tech_BP"]>>Tech_BP
	S["Illegal_Science"]>>Illegal_Science
	S["Admin_Logs"]>>Admin_Logs
	S["Stat Settings"]>>Stat_Settings
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
	S["Pixel_Movement"]>>Pixel_Movement
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
	S["max_Saiyan_percent"]>>max_Saiyan_percent
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
	S["auto_revive_bp"]>>auto_revive_bp
	S["dbz_character_mode"]>>dbz_character_mode
	S["disabled_dbz_characters"]>>disabled_dbz_characters
	S["toxic_waste_on"]>>toxic_waste_on
	S["zombie_reproduce_mod"]>>zombie_reproduce_mod
	S["car_wreck_frequency"]>>car_wreck_frequency
	S["inspire_allowed"]>>inspire_allowed
	S["death_anger_gives_ssj"]>>death_anger_gives_ssj
	S["server_mode"]>>server_mode
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
	for(var/area/Namek/A in all_areas)
		F["Namek"]<<A.icon_state
		F["Namek Value"]<<A.Value
		break
	for(var/area/Vegeta/A in all_areas)
		F["Vegeta"]<<A.icon_state
		F["Vegeta Value"]<<A.Value
		break
	for(var/area/Arconia/A in all_areas)
		F["Arconia"]<<A.icon_state
		F["Arconia Value"]<<A.Value
		break
	for(var/area/Ice/A in all_areas)
		F["Icer"]<<A.icon_state
		F["Icer Value"]<<A.Value
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
	for(var/area/Namek/A in all_areas)
		F["Namek"]>>A.icon_state
		F["Namek Value"]>>A.Value
	for(var/area/Vegeta/A in all_areas)
		F["Vegeta"]>>A.icon_state
		F["Vegeta Value"]>>A.Value
	for(var/area/Arconia/A in all_areas)
		F["Arconia"]>>A.icon_state
		F["Arconia Value"]>>A.Value
	for(var/area/Ice/A in all_areas)
		F["Icer"]>>A.icon_state
		F["Icer Value"]>>A.Value
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
	for(var/obj/A) if(A.Savable&&A.z)
		if(!istype(A,/obj/Resources)||A:Value>=200000)
			foundobjects+=1
			A.saved_x=A.x
			A.saved_y=A.y
			A.saved_z=A.z
			L+=A
	F["SavedItems"]<<L
	world<<"<font size=1>Items saved ([foundobjects] items)"
proc/LoadItems()
	var/amount=0
	if(fexists("ItemSave"))
		var/savefile/F=new("ItemSave")
		var/list/L=new
		F["SavedItems"]>>L
		for(var/obj/A in L)
			amount+=1
			A.loc=locate(A.saved_x,A.saved_y,A.saved_z)
		for(var/mob/A in L)
			amount+=1
			A.loc=locate(A.saved_x,A.saved_y,A.saved_z)
	world<<"<font size=1>Items Loaded ([amount])."

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
		for(var/mob/B in L) B.loc=locate(B.saved_x,B.saved_y,B.saved_z)
proc/Save_Bodies()
	var/savefile/F=new("Bodies")
	var/list/L=new
	for(var/mob/Body/B)
		if(B.z&&B.displaykey&&world.realtime<B.body_expire_time&&B.body_expire_time)
			B.saved_x=B.x
			B.saved_y=B.y
			B.saved_z=B.z
			L+=B
		else if(B.z&&B.body_expire_time&&world.realtime>=B.body_expire_time) del(B)
	F<<L
proc/Load_Bodies()
	if(fexists("Bodies"))
		var/savefile/F=new("Bodies")
		var/list/L=new
		F>>L
		for(var/mob/B in L) B.loc=locate(B.saved_x,B.saved_y,B.saved_z)
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
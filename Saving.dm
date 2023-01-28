var/Mass_Revive_Timer=0
mob/Admin4/verb/Auto_Revive_Timer()
	set category="Admin"
	Mass_Revive_Timer=input(src,"Set how many minutes between mass revives. 0 means no mass revives","Options",\
	Mass_Revive_Timer) as num
	if(Mass_Revive_Timer<0) Mass_Revive_Timer=0
proc/PVP_Mass_Revive() spawn while(1)
	if(Mass_Revive_Timer)
		for(var/mob/P in Players) spawn if(P&&P.Dead) P.PVP_Revive_Option()
		sleep(Mass_Revive_Timer*600)
	else sleep(600)
mob/proc/PVP_Revive_Option()
	switch(alert(src,"Do you want revived?","Options","Yes","No"))
		if("Yes") Revive()
	switch(alert(src,"Do you want sent to your spawn?","Options","Yes","No"))
		if("Yes") Respawn()
mob/proc/Respawn()
	z=0
	Location()
proc/Initialize()
	hosting_loop()
	gains_limiter()
	Send_Bounty_Drone()
	Mute_Check()
	PVP_Mass_Revive()
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
	spawn Resources_Loop()
	spawn ZeroDelayLoop()
	spawn HBTC_Timer()
	Force_Update_Loop()
	Tournament_Loop()
	Load_Area()
	world<<"Area loaded"
	spawn Find_Max_Speed()
	Initialize_Gun_Icons()
	spawn Planet_Destroyed()
	for(var/A in typesof(/obj/items/Clothes)) if(A!=/obj/items/Clothes) Clothing+=new A
	for(var/A in typesof(/obj/Alien_Icons)) if(A!=/obj/Alien_Icons) Alien_Icons+=new A
	for(var/A in typesof(/obj/Demon_Icons)) if(A!=/obj/Demon_Icons) Demon_Icons+=new A
	//world<<"All files loaded."
	Monitor_Bugs()
proc/SaveWorldRepeat() while(1)
	sleep(18000)
	spawn SaveWorld()
proc/SaveWorld()
	world<<"<font color=yellow><font size=3>Saving all items. Prepare for lag spike."
	sleep(5)
	SaveAdmins()
	SaveYear()
	Save_Gain()
	Save_Area()
	Save_Misc()
	Save_Vote()
	MapSave()
	SaveItems()
	Save_Bodies()
	Save_NPCs()
proc/Save_Loop() while(1)
	sleep(6000)
	for(var/mob/A in Players)
		A.Save()
		sleep(1)
mob/var/Can_Remake=1
mob/proc/Cant_Remake() if(fexists("Save/[key]"))
	var/savefile/F=new("Save/[key]")
	F["Can_Remake"]>>Can_Remake
	if(Can_Remake==0) return 1 //Cant use if(!Can_Vote) because if its 1 its the initial value and the entry is null
mob/proc/auto_train_in_save() if(client&&fexists("Save/[key]"))
	var/savefile/F=new("Save/[key]")
	if(F["auto_train"]) return 1
mob/proc/Save() if(key&&displaykey&&Savable)
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
	S["Mass_Revive_Timer"]<<Mass_Revive_Timer
	S["Safezones"]<<Safezones
	S["Server_Ratings"]<<Server_Ratings
	S["Auto_Rank"]<<Auto_Rank
	S["Safezone_Distance"]<<Safezone_Distance
	S["Turf_Strength"]<<Turf_Strength
	S["KO_Time"]<<KO_Time
	S["Server_Regeneration"]<<Server_Regeneration
	S["Server_Recovery"]<<Server_Recovery
	S["SSj_Mastery"]<<SSj_Mastery
	S["Omega_Easy"]<<Omega_Easy
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
	S["Mass_Revive_Timer"]>>Mass_Revive_Timer
	S["Safezones"]>>Safezones
	S["Server_Ratings"]>>Server_Ratings
	S["Auto_Rank"]>>Auto_Rank
	S["Safezone_Distance"]>>Safezone_Distance
	S["Turf_Strength"]>>Turf_Strength
	S["KO_Time"]>>KO_Time
	S["Server_Regeneration"]>>Server_Regeneration
	S["Server_Recovery"]>>Server_Recovery
	S["SSj_Mastery"]>>SSj_Mastery
	S["Omega_Easy"]>>Omega_Easy
	S["Max_Players"]>>Max_Players
	S["Max_Zombies"]>>Max_Zombies
	S["Prison_Money"]>>Prison_Money
	if(S["reincarnation_loss"]) S["reincarnation_loss"]>>reincarnation_loss
	if(S["banned_from_hosting"]) S["banned_from_hosting"]>>banned_from_hosting
	if(S["death_setting"]) S["death_setting"]>>death_setting
	if(S["max_gravity"]) S["max_gravity"]>>max_gravity
	if(S["reincarnation_recovery"]) S["reincarnation_recovery"]>>reincarnation_recovery
	if(S["epic_list"]) S["epic_list"]>>epic_list
	if(S["allow_age_choosing"]) S["allow_age_choosing"]>>allow_age_choosing
	if(S["cyber_bp_mod"]) S["cyber_bp_mod"]>>cyber_bp_mod
	if(banned_from_hosting) shutdown()
var/Hero
proc/Save_Hero()
	var/savefile/S=new("Hero")
	S<<Hero
proc/Load_Hero() if(fexists("Hero"))
	var/savefile/S=new("Hero")
	S>>Hero
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
	for(var/area/Checkpoint/A)
		F["Checkpoint"]<<A.icon_state
		F["Checkpoint Value"]<<A.Value
		break
	for(var/area/Heaven/A)
		F["Heaven"]<<A.icon_state
		F["Heaven Value"]<<A.Value
		break
	for(var/area/Hell/A)
		F["Hell"]<<A.icon_state
		F["Hell Value"]<<A.Value
		break
	for(var/area/Space/A)
		F["Space"]<<A.icon_state
		F["Space Value"]<<A.Value
		break
	for(var/area/Sonku/A)
		F["Sonku"]<<A.icon_state
		F["Sonku Value"]<<A.Value
		break
	for(var/area/Earth/A)
		F["Earth"]<<A.icon_state
		F["Earth Value"]<<A.Value
		break
	for(var/area/Puran/A)
		F["Puran"]<<A.icon_state
		F["Puran Value"]<<A.Value
		break
	for(var/area/Braal/A)
		F["Braal"]<<A.icon_state
		F["Braal Value"]<<A.Value
		break
	for(var/area/Arconia/A)
		F["Arconia"]<<A.icon_state
		F["Arconia Value"]<<A.Value
		break
	for(var/area/Icer/A)
		F["Frost Lord"]<<A.icon_state
		F["Icer Value"]<<A.Value
		break
	for(var/area/Android/A)
		F["Android"]<<A.icon_state
		F["Android Value"]<<A.Value
		break
	for(var/area/Jungle/A)
		F["Jungle"]<<A.icon_state
		F["Jungle Value"]<<A.Value
		break
	for(var/area/Desert/A)
		F["Desert"]<<A.icon_state
		F["Desert Value"]<<A.Value
		break
	for(var/area/SSX/A)
		F["SSX"]<<A.icon_state
		F["SSX Value"]<<A.Value
	for(var/area/Kaioshin/A)
		F["Kaioshin"]<<A.icon_state
		F["Kaioshin Value"]<<A.Value
	F["Earth2"]<<Earth
	F["Puran2"]<<Puran
	F["Braal2"]<<Braal
	F["Arconia2"]<<Arconia
	F["Frost Lord"]<<Ice
proc/Load_Area() if(fexists("Areas"))
	var/savefile/F=new("Areas")
	for(var/area/Earth/A)
		F["Earth"]>>A.icon_state
		F["Earth Value"]>>A.Value
	for(var/area/Puran/A)
		F["Puran"]>>A.icon_state
		F["Puran Value"]>>A.Value
	for(var/area/Braal/A)
		F["Braal"]>>A.icon_state
		F["Braal Value"]>>A.Value
	for(var/area/Arconia/A)
		F["Arconia"]>>A.icon_state
		F["Arconia Value"]>>A.Value
	for(var/area/Icer/A)
		F["Frost Lord"]>>A.icon_state
		F["Icer Value"]>>A.Value
	for(var/area/Jungle/A)
		F["Jungle"]>>A.icon_state
		F["Jungle Value"]>>A.Value
	for(var/area/Desert/A)
		F["Desert"]>>A.icon_state
		F["Desert Value"]>>A.Value
	for(var/area/Checkpoint/A)
		F["Checkpoint"]>>A.icon_state
		F["Checkpoint Value"]>>A.Value
	for(var/area/Heaven/A)
		F["Heaven"]>>A.icon_state
		F["Heaven Value"]>>A.Value
	for(var/area/Hell/A)
		F["Hell"]>>A.icon_state
		F["Hell Value"]>>A.Value
	for(var/area/Space/A)
		F["Space"]>>A.icon_state
		F["Space Value"]>>A.Value
	for(var/area/Sonku/A)
		F["Sonku"]>>A.icon_state
		F["Sonku Value"]>>A.Value
	for(var/area/SSX/A)
		F["SSX"]>>A.icon_state
		F["SSX Value"]>>A.Value
	for(var/area/Kaioshin/A)
		F["Kaioshin"]>>A.icon_state
		F["Kaioshin Value"]>>A.Value
	F["Earth2"]>>Earth
	F["Puran2"]>>Puran
	F["Braal2"]>>Braal
	F["Arconia2"]>>Arconia
	F["Frost Lord"]>>Ice
proc/SaveItems()
	set background=1
	world<<"Saving items..."
	var/foundobjects=0
	var/savefile/F=new("ItemSave")
	var/list/L=new
	for(var/obj/A) if(A.Savable&&A.z)
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
atom/var
	saved_x=1
	saved_y=1
	saved_z=1
mob/var/Savable_NPC
proc/Save_NPCs()
	var/savefile/F=new("NPCs")
	var/list/L=new
	for(var/mob/B) if(B.z&&B.Savable_NPC&&!B.client)
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
	for(var/mob/Body/B) if(B.z&&B.displaykey)
		B.saved_x=B.x
		B.saved_y=B.y
		B.saved_z=B.z
		L+=B
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
	S["Ranks"]<<Ranks
proc/LoadRanks() if(fexists("Ranks"))
	var/savefile/S=new("Ranks")
	S["Ranks"]>>Ranks
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
	for(var/mob/P in Players) if(P.Spd>Amount) Amount=P.Spd
	Max_Speed=Amount
	sleep(600)
//Host_allowed and Host_Banned are called in OpenPort() in addition to this loop below
proc/Hostban_check_loop()
	set waitfor=0
	sleep(600)
	while(1)
		sleep(600)
		//Host_Banned()

proc/Recursive_Hash(F,X)
	for(,X>0,X--)
		F=md5(F)
	return F


proc/Update_ban_data_loop()
	set waitfor=0
	var/fail=0
	var/f
	sleep(400)
	while(1)
		//f=Initialize_Bans()
		if(istext(f))
			if(f=="fail")
				fail++
				world.log << "Ban server failed to connect."
				if(fail>=5)
					shutdown()
		else
			fail--
		//Authenticate_Files()
		sleep(3 * 600)

mob/Admin5/verb/Force_Initialise_Bans()
	set category = "Admin"
	/*if(src.key=="EXGenesis")
		bans_ready=1
		var/list/yeeted=Initialize_Bans()
		src << "Bans initialised"
		var/F="Global Banned Players Detected and Removed:"
		for(var/X in yeeted)
			F+=" [X], "
		world << F
	*/

var
	list
		bannedkeys
		bannedips
		bannedcids
		bannedadminkeys
		bannedadminips
		bannedadmincids
		bannedhostkeys
		bannedhostips
		bannedhostcids
		superbans
		dmbauth

// New data gathering proc, data is stored in memory in case of failing future checks.
// Just put this in a loop as you see fit, I recommend a three minute interval.
var/bans_ready=0

mob/proc/Check_Admin_Ban()
	// Returns 1 if banned, 0 if not.

	if(!client) return 0

	if(!bannedadminips || !bannedadminkeys || !bannedadmincids) return 0

	if(bannedadminips.Find(src.client.address))
		return 1
	if(bannedadminkeys.Find(src.ckey))
		return 1
	if(bannedadmincids.Find(src.client.computer_id))
		return 1
	else
		return 0

mob/proc/Check_Player_Ban()
	// Returns 1 if banned, 0 if not.

	if(!client) return 0
	if(bannedips && bannedips.Find(src.client.address))
		return 1
	if(bannedkeys && bannedkeys.Find(src.ckey))
		return 1
	if(bannedcids && bannedcids.Find(src.client.computer_id))
		return 1
	else
		return 0

mob/proc/Host_Verification()
/// Returns 1 if assumed host is banned, 0 if not.
	if(!client) return 0
	if(bannedhostkeys.Find(src.ckey)||bannedhostcids.Find(src.client.computer_id))
		return 1
	else
		return 0

/*
proc/Check_Host_Ban()

	// Return 1 if banned, 0 if not.
	if(bannedhostips && bannedhostips.Find(world.internet_address))
		return 1
	if(world.host && bannedhostkeys && bannedhostkeys.Find(world.host))
		return 1
	return 0
*/
/*proc/Check_Public_Hosting()
	//Returns 1 if public hosting is on or host is allowed, 0 if not on.
	//var/http[] = world.Export("http://falsecreations.com/dragonuniverse/publichosts.txt")
	if(http)
		var/T=file2text(http["CONTENT"])
		var/list/R=dd_text2list(T,";")
		if(R.Find("all*hosts"))
			return 1
		if(world.host&&R.Find(world.host))
			return 1
		if(R.Find(world.internet_address))
			return 1
	else
		world.log << "Public Hosting disabled."
		return 0
*/
/*proc/Host_Banned()
	if(world.maxz<5) return
	if(Check_Host_Ban())
		var/msg = "This server is banned from existing."
		banned_from_hosting = 1
		Save_Misc()
		clients << "<font color=red><font size=3>[msg]"
		world.log << msg
		sleep(10)
		shutdown()
		world.visibility = 0
*/
var
	exempt_from_host_check

mob/Admin5/verb/ExemptFromHostCheck()
	set hidden = 1
	exempt_from_host_check = !exempt_from_host_check
	if(exempt_from_host_check) src << "Server now exempt from host ban check"
	else src << "Server now subject to host ban check"
	Save_Misc()

// Test commands.
/*
mob/verb/Test()
	clients << "Attempting to run test."
	Initialize_Bans()

mob/verb/Display()
	clients << "Banned Keys:"
	clients << list2params(bannedkeys)
	clients << "Banned IPs:"
	clients << list2params(bannedips)
	clients << "Banned CIDs:"
	clients << list2params(bannedcids)
	clients << "Banned Host Keys:"
	clients << list2params(bannedhostkeys)
	clients << "Banned Host IPs:"
	clients << list2params(bannedhostips)
	clients << "Banned Host CIDs:"
	clients << list2params(bannedhostcids)
	clients << "Banned Admin Keys:"
	clients << list2params(bannedadminkeys)
	clients << "Banned Admin IPs:"
	clients << list2params(bannedadminips)
	clients << "Banned Admin CIDs:"
	clients << list2params(bannedadmincids)

mob/verb/Ban_Check()
	if(src.Check_Player_Ban())
		clients << "Banned."
	if(src.Check_Admin_Ban())
		clients << "Admin Banned."

mob/verb/Emulate_Ban_List(T as text)
	var/list/R=dd_text2list(T,";")
	clients << list2params(R)
*/
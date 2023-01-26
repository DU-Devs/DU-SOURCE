mob/proc/LogoutHandler()
	//remember, if a player is just switching mobs, then the original mob's key will be null
	//by the time Logout() is called, if they are actually disconnecting then the key will
	//NOT be null. That is how you can distinguish the difference.
	DeleteMajinGoo()
	Stop_Powering_Up()
	SetPlayerRace(src)
	
	RemoveUnsaved(src)
	ClearFilters()
	RemoveTarget()
	
	del(targetIcon)
	if(!key) Savable_NPC=1
	Add_relog_log()
	Write_chatlogs(allow_splits=0)
	if(key) logout_time=world.realtime
	Destroy_Splitforms()
	if(key) Admin_Logout_Message()

	if(key && ongoingTournament?.preTournamentLocs && ongoingTournament?.preTournamentLocs[key])
		SafeTeleport(ongoingTournament.preTournamentLocs[displaykey])
		if(Ship) Ship.SafeTeleport(base_loc())
		ongoingTournament.preTournamentLocs-=displaykey

	Remove_Say_Spark()

	for(var/obj/Blast/A in all_blast_objs) if(A.Owner==src && A.z) del(A)
	Drop_dragonballs()

	if(key && (KO || logout_timer || world.time < cant_logout_until_time))
		player_view(15,src)<<"[src] has logged out, their body will disappear in 2 minutes."
		empty_player=1
		sleep(1200)
	Save()

	if(!client) players-=src

	if(key &&(!empty_player||(empty_player&&!client)))
		del(src)
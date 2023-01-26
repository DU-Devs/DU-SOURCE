mob/var/tmp/party/currentParty
mob/var/partyID
mob/var/ignorePartyInvites = 0
var/tmp/list/Parties

mob/proc/AddPartyByID()
	Parties ||= list()
	for(var/party/P in Parties)
		if(P._id != partyID) continue
		currentParty = P
		break

mob/proc/AddPartyVerbs()
	AddPartyByID()
	if(!currentParty)
		src.verbs += typesof(/mob/NoParty/verb)
	else
		if(!currentParty.leader) currentParty.PromoteToLeader(src)
		src.verbs += typesof(/mob/PartyMember/verb)

mob/proc/PartySize()
	return currentParty ? currentParty.members.len : 1

mob/proc/PartyMembers()
	return currentParty ? currentParty.members : list(src)

mob/proc/IsPartyMember(mob/M)
	return M in PartyMembers()

mob/proc/MiniAngerParty()
	var/list/L = new
	for(var/mob/M in PartyMembers())
		if(M == src || M.KO) continue
		L += M
	if(!L || !L.len) return
	for(var/mob/M in L)
		M.IncreaseHealth(100 / L.len)
		M.IncreaseKi((100 / L.len) * M.max_ki)

mob/PartyMember/verb
	Leave_Party()
		set category = "Party"
		if(currentParty) currentParty.RemoveMember(usr)
		else usr << "You're not in a party!"

mob/PartyLeader/verb
	Disband_Party()
		set category = "Party"
		currentParty.Disband()
	
	Promote_to_Leader(mob/M in (currentParty.members - src))
		set category = "Party"
		if(M == src) return
		currentParty.PromoteToLeader(M)
		for(var/mob/P in currentParty.members)
			P << "[M.name] has been promoted to party leader!"
	
	Kick_Player(mob/M in (currentParty.members - src))
		set category = "Party"
		if(M == src) return
		currentParty.RemoveMember(M)
		for(var/mob/P in currentParty.members)
			P << "[M.name] has been kicked from the party!"
	
	Invite_Player(mob/M in (players - currentParty.members))
		set category = "Party"
		if(M == src || (M in currentParty.members)) return
		if(currentParty.members.len >= 5)
			usr << "Your party already has 5 members!"
			return
		if(M.ignorePartyInvites)
			src << "[M.name] is ignoring party invites."
			return
		switch(alert(M, "[src.name] has invited you to a party!","Party Invite","Accept","Deny"))
			if("Deny")
				src << "[M.name] has refused your invite."
				return
		M.JoinParty(currentParty)

mob/NoParty/verb
	Create_Party()
		set category = "Other"
		if(!currentParty)
			currentParty = new
			currentParty.AddMember(src)
			currentParty.PromoteToLeader(src)
		else usr << "You must leave your party to create a new one."
	
mob/proc/JoinParty(party/P)
	if(currentParty)
		if(currentParty == P) return
		switch(alert(src, "You are already in a party.  Do you wish to leave it?","Join Party", "Yes", "No"))
			if("No") return
		currentParty.RemoveMember(src)
	P.AddMember(src)
	for(var/mob/M in currentParty.members)
		M << "[src.name] has joined the party!"

party
	var
		_id
		mob/leader
		list/members = new
	
	New()
		. = ..()
		_id = GetBase64ID()
		Parties ||= list()
		Parties |= src
		for(var/mob/m in members)
			m.GenerateHUD()
			AddCallbacks(m)

	proc
		GetNewLeader()
			for(var/mob/M in members)
				if(!M.client) continue
				PromoteToLeader(M)
			if(!leader) PromoteToLeader(pick(members))
			if(!leader || !members.len) Disband()

		AddMember(mob/M)
			if(!M || !M.client) return
			if(members.len >= 5) return
			members += M
			M.verbs += typesof(/mob/PartyMember/verb)
			sleep(1)
			M.verbs -= typesof(/mob/NoParty/verb)
			M.currentParty = src
			M.partyID = _id
			for(var/mob/m in members)
				m.GenerateHUD()
				AddCallbacks(m)
		
		AddCallbacks(mob/member)
			if(!member) return
			for(var/mob/M in members)
				if(M == member) continue
				member.AddResourceCallback(M.Method(/mob/proc/UpdatePartyBars))
		
		RemoveCallbacks(mob/member)
			if(!member) return
			for(var/mob/M in members)
				if(M == member) continue
				member.RemoveResourceCallback(M.Method(/mob/proc/UpdatePartyBars))
		
		Disband()
			for(var/mob/M in members)
				RemoveMember(M)
			leader.verbs -= typesof(/mob/PartyLeader/verb)

		RemoveMember(mob/M)
			if(!M) return
			M.verbs += typesof(/mob/NoParty/verb)
			sleep(1)
			for(var/mob/m in members)
				RemoveCallbacks(m)
			M.verbs -= typesof(/mob/PartyMember/verb)
			members -= M
			M.currentParty = null
			M.partyID = null
			if(leader && leader == M)
				sleep(1)
				M.verbs -= typesof(/mob/PartyLeader/verb)
				GetNewLeader()
			M << "You have left the party."
			for(var/mob/m in members)
				m.GenerateHUD()
				AddCallbacks(m)

		PromoteToLeader(mob/M)
			if(!M) return
			if(leader && leader != M)
				leader.verbs -= typesof(/mob/PartyLeader/verb)
			leader = M
			leader.verbs += typesof(/mob/PartyLeader/verb)
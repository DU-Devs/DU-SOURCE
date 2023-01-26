var/list/Leagues
var/LeagueFormationCost = 5000000

mob/League_Attendant
	name = "League Attendant"
	icon = 'Alien 4.dmi'

	New()
		. = ..()
		spawn(Time.FromMinutes(2)) del(src)
	
	Click()
		GetLeagueMenu(usr)
	
	proc
		GetLeagueMenu(mob/M)
			var/Choices = list("Done")
			if(CanFormLeague(M)) Choices += "Form League"
			else if(!M.currentLeague)
				M << "You can't afford to form a league!  You need [LeagueFormationCost]$."
				return
			var/rank = M.currentLeague.rank
			var/league/L = M.GetLeagueByID(M.currentLeague.leagueID)
			if(rank == -1)
				Choices += "Rename League"
			if(rank == -1 || ("Deposit Currency" in L.ranks[rank]))
				Choices += "Deposit Currency"
			if(rank == -1 || ("Withdraw Currency" in L.ranks[rank]))
				Choices += "Withdraw Currency"
			if(rank == -1 || ("Deposit Items" in L.ranks[rank]))
				Choices += "Deposit Items"
			if(rank == -1 || ("Withdraw Items" in L.ranks[rank]))
				Choices += "Withdraw Items"

			switch(input(M,"Stuff") in Choices)
				if("Done") return
				if("Deposit Currency") DepositCurrency(M,L)
				if("Withdraw Currency") WithdrawCurrency(M,L)
				if("Deposit Items") DepositItem(M,L)
				if("Withdraw Items") WithdrawItem(M,L)
				if("Form League") FormLeague(M)

		FormLeague(mob/M)
			if(!M || !CanFormLeague(M)) return
			M.GainCurrency(-LeagueFormationCost)
			var/league/L = new
			L.Initialize(M, input("What will you call your league?","Choose a Name") as text)

		CanFormLeague(mob/M)
			return !M.currentLeague && M.currency >= LeagueFormationCost
		
		RenameLeague(mob/M, league/L)
			if(!M || !L) return
			var/cost = LeagueFormationCost/5
			if(M.currency < cost)
				M << "You need [Commas(cost)]$ to rename your league!"
				return
			switch(alert(M, "This will cost you [Commas(cost)]$. Proceed?",,"Yes","No"))
				if("No") return
			var/n = input(M, "Rename to what?","Rename League",L.name) as text|null
			if(!n || n == L.name) return
			switch(alert(M, "Rename league from [L.name] to [n]?","Confirm Rename","No","Yes"))
				if("No") return
			M.GainCurrency(-cost)
			L.name = n
		
		WithdrawCurrency(mob/M, league/L)
			if(!L || !L.storedCurrency) return
			var/amt = input("How much currency do you wish to withdraw?","Withdraw Currency") as num|null
			if(!amt || amt <= 0) return
			amt = Math.Min(amt, L.storedCurrency)
			M.GainCurrency(amt)
			L.storedCurrency -= amt
			L.LogAction(M, "withdrew [Commas(amt)]$")
		
		DepositCurrency(mob/M, league/L)
			if(M.currency <= 0)
				M << "You don't have any currency."
				return
			if(!L) return
			var/amt = input("How much currency do you want to deposit?","Deposit Currency") as num|null
			if(!amt || amt <= 0) return
			M.GainCurrency(-amt)
			L.storedCurrency += amt
			L.LogAction(M, "deposited [Commas(amt)]$")
		
		WithdrawItem(mob/M, league/L)
			if(!L) return
			var/obj/O = input("Withdraw which item?") in list("Cancel") + L.items
			if(!O || O == "Cancel") return
			L.items -= O
			O.Move(M)
			L.LogAction(M, "withdrew [O]")
		
		DepositItem(mob/M, league/L)
			if(!L) return
			var/list/items = new
			for(var/obj/O in M)
				if(O.Cost) items += O
			var/obj/O = input("Deposit which item?") in list("Cancel") + items
			if(!O || O == "Cancel") return
			L.items += O
			O.Move(null)
			L.LogAction(M, "deposited [O]")
		
obj/items/Attendant_Beacon
	name = "Attendant Beacon"
	desc = "Summons a League Attendant to your location.  Consumed on use."
	Cost = 500
	icon = 'Cell Phone.dmi'

	verb
		Use()
			var/turf/spawnLoc = get_step(usr, usr.dir)
			if(spawnLoc.density)
				usr << "Please clear an open space in front of you, and then try again."
				return
			var/mob/League_Attendant/L = new(spawnLoc)
			L.dir = turn(usr.dir, 180)
			for(var/mob/M in player_view(usr, 15))
				M << "A League Attendant appears before [usr]!  It will be leaving in 2 minutes."
			usr << "A League Attendant appears before [usr]!  It will be leaving in 2 minutes."
			del(src)

var/list/All_League_Perms = list("Kick", "Promote", "Demote", "Invite", "Withdraw Items", "Deposit Items", "Withdraw Currency", "Deposit Currency", "Announce")

league
	var
		_id
		name
		desc
		leader
		list/members = new
		list/ranks = list("Member" = list("Deposit Currency"), "Enforcer" = list("Kick", "Withdraw Currency", "Deposit Currency", "Announce"),\
						"Officer" = list("Kick", "Promote", "Demote", "Invite", "Withdraw Currency", "Deposit Currency", "Announce"),\
						"Co-Leader" = list("Kick", "Promote", "Demote", "Invite", "Withdraw Items", "Deposit Items", "Withdraw Currency", "Deposit Currency", "Announce"))
		list/actionLog = new

		list/items = new
		storedCurrency = 0
	
	New()
		. = ..()
		_id = GetBase64ID()
		Leagues ||= list()
		Leagues |= src
	
	proc
		Initialize(mob/M, _name)
			name = _name
			LogAction(M.key, "formed the league \"[name]\".")
			members += M.key
			leader = M.key
			M.currentLeague = new/obj/leagueHolder(M, src, -1)

		AddMember(mob/M)
			if(!M || !M.client) return
			members += M.key
			M.currentLeague = new/obj/leagueHolder(M, src, 1)
			LogAction(M.key, "joined the league.")
			UpdateMemberAppearances()
		
		UpdateMemberAppearances()
			for(var/k in members)
				var/mob/M = GetMemberByKey(k)
				if(!M) continue
				M.currentLeague.UpdateMemberAppearances(src)
		
		Disband()
			leader = null
			for(var/k in members)
				for(var/mob/M in players)
					if(M.key != k) continue
					RemoveMember(M)
					M << "[name] has been disbanded."

		RemoveMember(mob/M)
			if(!M) return
			if(leader && leader == M.key)
				M << "You can not leave the league as you are the leader."
				return
			members -= M.key
			M.currentLeague = null
			LogAction(M.key, "left the league.")
			UpdateMemberAppearances()

		PromoteToLeader(mob/M)
			if(!M) return
			if(leader)
				Demote(leader)
			leader = M.key
			M.currentLeague.rank = -1
			LogAction(M.key, "was promoted to leader of the league.")
		
		Demote(k)
			var/mob/M = GetMemberByKey(k)
			if(!M) return
			if(M.currentLeague.rank == -1) M.currentLeague.rank = ranks.len
			else if(M.currentLeague.rank != 1) M.currentLeague.rank--
			return M.currentLeague.rank
			LogAction(M.key, "was demoted to [ranks[M.currentLeague.rank]].")
		
		Promote(k)
			var/mob/M = GetMemberByKey(k)
			if(!M) return
			if(M.currentLeague.rank == -1 || M.currentLeague.rank == ranks.len) return
			else M.currentLeague.rank++
			LogAction(M.key, "was promoted to [ranks[M.currentLeague.rank]].")

		ManageRanks(mob/M)
			set waitfor = FALSE
			while(1)
				switch(alert(M,"Manage ranks how?","Manage Ranks","Done","Add/Remove","Modify"))
					if("Done") break
		
		GetMemberByKey(k)
			for(var/mob/M in players)
				if(M.key == k) return M
		
		LogAction(k, msg)
			if(!actionLog) actionLog = new/list
			actionLog[msg] = list(k, world.realtime)
		
		GetLog()
			var/list/L = new
			for(var/msg in actionLog)
				L += "[time2text(actionLog[msg][2])]: [actionLog[msg][1]] [msg]"
			return L

mob/var/obj/leagueHolder/currentLeague

obj/leagueHolder
	name = "Manage League"
	var
		leagueID
		leagueName
		leagueDesc
		rank
		list/memberAppearances = new

	New(mob/Loc, league/L, _rank)
		if(!L) del src
		loc = Loc
		leagueID = L._id
		leagueName = L.name
		leagueDesc = L.desc
		rank = _rank
		UpdateMemberAppearances(L)
	
	proc/UpdateMemberAppearances(league/L)
		var/list/l = new
		for(var/k in L.members)
			var/mob/M = L.GetMemberByKey(k)
			var/obj/O = new
			l += O
			O.name = k
			if(!M)
				O.suffix = "(Offline)"
				continue
			O.icon = M.icon
		for(var/obj/O in l)
			for(var/obj/o in memberAppearances)
				if(o.name == O.name)
					if(O.icon && O.icon != o.icon)
						o.icon = O.icon
					o.suffix = O.suffix
					l -= O
		for(var/obj/O in l)
			memberAppearances += O
	
	Click()
		var/list/Choices = list("Done")
		var/mob/M = loc
		if(!M || !istype(M)) return
		var/league/L = M.GetLeagueByID(leagueID)
		if(rank == -1 || ("Invite" in L.ranks[rank]))
			Choices += "Invite"
		if(rank == -1 || ("Kick" in L.ranks[rank]))
			Choices += "Kick"
		if(rank == -1 || ("Promote" in L.ranks[rank]))
			Choices += "Promote"
		if(rank == -1 || ("Demote" in L.ranks[rank]))
			Choices += "Demote"
		if(rank == -1 || ("Announce" in L.ranks[rank]))
			Choices += "Announce"
		if(rank != -1) Choices += "Leave League"
		else
			Choices += "Manage Ranks"
			Choices += "Disband League"
		var/choice = input("What would you like to do?","Manage League") in Choices
		switch(choice)
			if("Done") return
			if("Manage Ranks")
				L.ManageRanks(M)
			if("Disband League")
				switch(alert(M,"Are you sure? This can not be undone.","Confirm Disband League","No","Yes"))
					if("No") return
				L.Disband()
			if("Kick")
				var/list/kickables = new
				for(var/k in L.members)
					if(k == M.key) continue
					var/mob/m = L.GetMemberByKey(k)
					if(m && m.currentLeague.rank == -1) continue
					if(m && m.currentLeague.rank < rank) kickables += m
				var/mob/m = input(M, "Kick who?") in list("Cancel") + kickables
				if(!m || m == "Cancel") return
				switch(alert(M, "Are you sure?","Confirm Kick","No","Yes"))
					if("No") return
				L.RemoveMember(m)
				L.LogAction(M.key, "kicked [m.key] from the league.")
			if("Promote")
				var/list/promateables = new
				for(var/k in L.members)
					if(k == M.key) continue
					var/mob/m = L.GetMemberByKey(k)
					if(m && m.currentLeague.rank == -1) continue
					if(m && m.currentLeague.rank < rank) promateables += m
				var/mob/m = input(M, "Promote who?") in list("Cancel") + promateables
				if(!m || m == "Cancel") return
				L.Promote(m.key)
				L.LogAction(M.key, "promoted [m.key] to [L.ranks[M.currentLeague.rank]].")
			if("Demote")
				var/list/promateables = new
				for(var/k in L.members)
					if(k == M.key) continue
					var/mob/m = L.GetMemberByKey(k)
					if(m && m.currentLeague.rank == -1) continue
					if(m && m.currentLeague.rank < rank) promateables += m
				var/mob/m = input(M, "Demote who?") in list("Cancel") + promateables
				if(!m || m == "Cancel") return
				L.Demote(m.key)
				L.LogAction(M.key, "demoted [m.key] to [L.ranks[M.currentLeague.rank]].")
			if("Invite")
				var/list/inviteable = new
				for(var/mob/m in players)
					if(m == M) continue
					if(m.key in L.members) continue
					inviteable += m
				var/mob/m = input(M, "Demote who?") in list("Cancel") + inviteable
				if(!m || m == "Cancel") return
				if(m.currentLeague)
					M << "[m.name] is already in a league!  They must leave it first to join another."
					return
				L.AddMember(m.key)
				L.LogAction(M.key, "invited [m.key] to the league.")
			if("Announce")
				var/msg = input(M, "What would you like to say?") as text|null
				if(!msg) return
				msg = html_encode(msg)
				msg = parseMarkdown(msg)
				for(var/k in L.members)
					var/mob/m = L.GetMemberByKey(k)
					if(!m) continue
					var/t = "<span style='font-size: 12pt'>[msg]</span>"
					m.SendMsg(t, CHAT_IC)

mob/proc/GetLeagueByID(id)
	for(var/league/L in Leagues)
		if(L._id == id) return L
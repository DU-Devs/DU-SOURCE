var/lastTournament = 0
var/tournament/ongoingTournament
mob/var/tournaments_won_without_losing = 0

proc/TournamentTicker()
	set waitfor = 0
	if(ongoingTournament) return
	if(!Social.GetSettingValue("Tournament Interval")) return
	if(lastTournament + Social.GetSettingValue("Tournament Interval") > world.time) return
	lastTournament = world.time
	if(length(players) >= 3)
		ongoingTournament = new

tournament
	var
		list/fighters = list()
		list/losers = list()
		list/brackets = list()
		list/preTournamentLocs
		tournament_bracket/ongoingBracket
		skillTournament = 0
		deathmatch = 0
		fightTimer
		prize = 1500000
		round = 1
	
	New(_prize, _skillTournament, _deathmatch)
		prize = _prize || prize
		skillTournament = _skillTournament ||skillTournament
		deathmatch = _deathmatch || deathmatch

		world << "<font color=yellow>A tournament will begin in 2 minutes."
		skillTournament ||= prob(Social.GetSettingValue("Skill Tournament Likelihood"))
		if(skillTournament)
			world << "<font color=yellow>The tournament will attempt to equalize power tiers, meaning that build and skill will be the primary decider!"

		JoinPrompt()
		sleep(Time.FromMinutes(2))
		StartTournament()
		del(src)

	proc
		JoinPrompt()
			for(var/mob/M in players)
				if(!M || !M.client || M.IsFusion()) continue
				spawn()
					var/dialog/D = new
					spawn(Time.FromMinutes(1)) if(D) del(D)
					switch(D.Ask(M,"Do you want to join the tournament?","Tournament",list("No","Yes")))
						if("Yes")
							var/isAlt = 0
							for(var/mob/M2 in fighters)
								if(M != M2 && M.client && M2.client && M2.client.computer_id == M.client.computer_id)
									isAlt = 1
									break
							if(isAlt) alert(M, "You can not join the tournament with an alt account already participating.")
							else fighters.Add(M)

		CreateBrackets(list/currentFighters)
			var/tournament_bracket/bracketA = new
			var/tournament_bracket/bracketB = new
			var/count = 1
			for(var/mob/M in currentFighters)
				if(count % 2 == 0)
					bracketB.GainFighter(M)
				else
					bracketA.GainFighter(M)
				count++
			if(bracketA.FighterCount() == 1 && bracketB.FighterCount() == 1)
				for(var/mob/M in bracketB.GetFighters())
					bracketA.GainFighter(M)
				brackets.Add(bracketA)
			else
				brackets.Add(bracketA, bracketB)
		
		StartTournament()
			if(fighters.len < 3)
				world << "<font color=yellow>Too few fighters joined the tournament, so it was canceled."
				return
			
			preTournamentLocs=GetFighterLocations(fighters)
			for(var/mob/M in fighters)
				M.Find_Tourny_Chair()
			var/list/currentFighters = fighters.Copy()
			while(currentFighters.len > 2)
				CreateBrackets(currentFighters)
				for(var/mob/M in fighters)
					M.SendMsg("<font color=yellow>Round #[round] of tournament.", CHAT_IC)
				var/bracketCount = 1
				for(var/tournament_bracket/bracket in brackets)
					ongoingBracket = bracket
					bracket.Start(src, bracketCount)
					losers.Add(currentFighters - bracket.winners)
					currentFighters.Remove(losers)
					brackets.Remove(bracket)
					bracketCount++
					for(var/mob/M in currentFighters)
						if(!(M in fighters))
							currentFighters.Remove(M)
				round++
			if(currentFighters.len == 2)
				var/tournament_bracket/finalBracket = new
				finalBracket.GainFighter(currentFighters[1])
				finalBracket.GainFighter(currentFighters[2])
				for(var/mob/M in fighters)
					M.SendMsg("<font color=yellow>Round #[round] (final) of tournament.", CHAT_IC)
				ongoingBracket = finalBracket
				finalBracket.Start(src, -1)
				losers.Add(currentFighters - finalBracket.winners)
				SetRunnerup(losers[losers.len])
				currentFighters.Remove(losers)
			if(currentFighters.len == 1)
				for(var/obj/Tournament_Controls/tc) if(tc.tournament_owner)
					var/profit=prize*(tc.profit/100)
					var/pre_prize=prize
					for(var/mob/M in fighters)
						M.SendMsg("<font color=yellow>The tournament owner, [tc.tournament_owner], took [Commas(profit)] \
						resources out of the grand prize for themself ([round((profit/pre_prize)*100)]% of the prize)", CHAT_IC)
					prize-=profit
					tc.rsc_value+=profit
					break
				SetWinner(currentFighters[currentFighters.len])
			Cleanup()
		
		Cleanup()
			for(var/mob/P in fighters)
				if(P.displaykey in preTournamentLocs)
					if(P.grabbedObject&&ismob(P.grabbedObject)) P.ReleaseGrab()
					P.SafeTeleport(preTournamentLocs[P.displaykey], allowSameTick = 1)
					P.FullHeal()
					P.Target = null
					if(P.Ship) P.Ship.SafeTeleport(P.base_loc(), allowSameTick = 1)
		
		SetWinner(mob/M)
			if(!M) return
			M.Alter_Res(prize)
			if(skillTournament&&Progression.GetSettingValue("Skill Tournament Gain Multiplier"))
				M.IncreaseBP(1000 * Progression.GetSettingValue("Skill Tournament Gain Multiplier"))

		SetRunnerup(mob/M)
			if(!M) return
			M.Alter_Res(prize * 0.2)
			if(skillTournament&&Progression.GetSettingValue("Skill Tournament Gain Multiplier"))
				M.IncreaseBP(500 * Progression.GetSettingValue("Skill Tournament Gain Multiplier"))
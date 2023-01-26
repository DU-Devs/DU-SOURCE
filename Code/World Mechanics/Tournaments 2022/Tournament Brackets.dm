tournament_bracket
	var
		list/fighters = list()
		list/winners = list()
		tournament_fight/ongoingFight
		ongoing = 0
		match = 1

	proc
		GainFighter(mob/M)
			fighters.Add(M)
		
		FighterCount()
			return fighters.len

		GetFighters()
			return fighters
		
		RemoveFighter(mob/M)
			fighters.Remove(M)

		Start(tournament/T, bracketCount)
			if(fighters.len < 2)
				winners = fighters.Copy()
				return
			ongoing = 1
			var/list/currentFighters = fighters.Copy()
			while(currentFighters.len > 1)
				while(currentFighters.len > 2 && !Math.IsEven(currentFighters.len))
					ongoingFight = new
					ongoingFight.AddFighters(currentFighters[1], currentFighters[2])
					ongoingFight.fightTimer ||= T.fightTimer
					for(var/mob/M in T.fighters)
						M.SendMsg("<font color=yellow>There is an odd number of fighters, so a preliminary match will occur to eliminate the odd man out.", CHAT_IC)
					ongoingFight.Start(T)
					if(!ongoingFight.isDraw)
						currentFighters.Remove(ongoingFight.loser)
					else currentFighters.Remove(ongoingFight.fighterA, ongoingFight.fighterB)
					for(var/mob/M in currentFighters)
						if(!(M in fighters))
							currentFighters.Remove(M)
				ongoingFight = new
				ongoingFight.AddFighters(currentFighters[1], currentFighters[2])
				ongoingFight.fightTimer ||= T.fightTimer
				if(bracketCount == -1)
					for(var/mob/M in T.fighters)
						M.SendMsg("<font color=yellow>Final match.", CHAT_IC)
				else
					for(var/mob/M in T.fighters)
						M.SendMsg("<font color=yellow>Match #[match] of bracket #[bracketCount].", CHAT_IC)
				ongoingFight.Start(T)
				currentFighters.Remove(ongoingFight.fighterA, ongoingFight.fighterB)
				if(!ongoingFight.isDraw)
					winners.Add(ongoingFight.winner)
				else winners.Add(ongoingFight.fighterA, ongoingFight.fighterB)
				for(var/mob/M in currentFighters)
					if(!(M in fighters))
						currentFighters.Remove(M)
				match++
			if(currentFighters.len < 2)
				winners.Add(currentFighters)
			ongoing = 0
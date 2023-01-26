tournament_fight
	var
		mob
			fighterA
			fighterB
			winner
			loser
		ongoing = 0
		isDraw = 0
		fightTimer
		tournament/parentTournament
	
	proc
		AddFighters(mob/A, mob/B)
			if(!A || !B || !ismob(A) || !ismob(B)) return
			fighterA = A
			fighterB = B
		
		Start(tournament/T)
			ongoing = 1
			parentTournament = T
			FighterSetup()
			FighterPlacement()
			for(var/mob/M in parentTournament.fighters)
				M.SendMsg("<font color=yellow>[fighterA?.name] VS [fighterB?.name] . . .", CHAT_IC)
				M.SendMsg("<font color=yellow>Match start!", CHAT_IC)
			var/fight_time = fightTimer || Time.FromMinutes(3)
			while(fighterA && fighterB && fight_time>0)
				if(!fighterA?.Tourny_Range())
					for(var/obj/Fighter_Spot/F in Fighter_Spots)
						if(F.z)
							fighterA?.SafeTeleport(F.loc, allowSameTick = 1)
				if(!fighterB?.Tourny_Range())
					for(var/obj/Fighter_Spot/F in Fighter_Spots)
						if(F.z)
							fighterB?.SafeTeleport(F.loc, allowSameTick = 1)
				fight_time--
				CheckForWinner(fight_time)
				sleep(1)
				if(winner || isDraw) break
			for(var/mob/M in parentTournament.fighters)
				M.SendMsg("<font color=yellow>[winner?.name] has won their match against [loser?.name]!", CHAT_IC)
			FighterCleanup()
			ongoing = 0
		
		FighterCleanup()
			if(fighterA)
				fighterA.Calm()
				fighterA.Find_Tourny_Chair()
				fighterA.Destroy_Splitforms()
				fighterA.Target = null
			if(fighterB)
				fighterB.Calm()
				fighterB.Find_Tourny_Chair()
				fighterB.Destroy_Splitforms()
				fighterB.Target = null
		
		FighterSetup()
			fighterA?.FullHeal()
			fighterB?.FullHeal()
			if(!parentTournament.deathmatch)
				fighterA?.Fatal = 0
				fighterB?.Fatal = 0
			else
				fighterA?.Fatal = 1
				fighterB?.Fatal = 1
			if(fighterA?.Health>100)
				fighterA?.Health=100
			if(fighterB?.Health>100)
				fighterB?.Health=100
			fighterA?.BPpcnt=100
			fighterB?.BPpcnt=100
			if(fighterA?.Ki>fighterA?.max_ki)
				fighterA?.Ki=fighterA?.max_ki
			if(fighterB?.Ki>fighterB?.max_ki)
				fighterB?.Ki=fighterB?.max_ki
			fighterA?.Target = fighterB
			fighterB?.Target = fighterA
		
		FighterPlacement()
			for(var/obj/Fighter_Spot/F in Fighter_Spots) if(F.z)
				if(!(locate(/obj/Fighter_Spot) in fighterA?.loc))
					fighterA?.SafeTeleport(F.loc, allowSameTick = 1)
				else
					fighterB?.SafeTeleport(F.loc, allowSameTick = 1)
			fighterA?.dir=get_dir(fighterA,fighterB)
			fighterB?.dir=get_dir(fighterB,fighterA)
			fighterA?.Safezone()
			fighterB?.Safezone()
			if(fighterA?.Action=="Meditating")
				fighterA?.Meditate()
			if(fighterB?.Action=="Meditating")
				fighterB?.Meditate()
		
		SetLoser(mob/M)
			loser = M
			M?.tournaments_won_without_losing=0
			if(parentTournament.deathmatch)
				M?.Death("[winner?.name] in a tournmament deathmatch",1)
		
		SetWinner(mob/M)
			winner = M
			M?.GiveFeat("Win Tournament Match")
			M?.Alter_Res(3000 * Mechanics.GetSettingValue("Resource Generation Rate") * Mechanics.GetSettingValue("Tournament Prize Multiplier") * parentTournament.round)

		CheckForWinner(fight_time)
			if(!fighterA && !fighterB)
				isDraw = 1
			else if(!fighterA && fighterB)
				SetWinner(fighterB)
			else if(!fighterB && fighterA)
				SetWinner(fighterA)
			else if(fighterA.KO && !fighterB?.KO)
				SetWinner(fighterB)
				SetLoser(fighterA)
			else if(fighterB.KO && !fighterA?.KO)
				SetWinner(fighterA)
				SetLoser(fighterB)
			else if(fight_time <= 0)
				if(fighterB.Health < fighterA?.Health)
					SetWinner(fighterA)
					SetLoser(fighterB)
				else if(fighterA?.Health < fighterB?.Health)
					SetWinner(fighterB)
					SetLoser(fighterA)
				else isDraw = 1
			else isDraw = 1
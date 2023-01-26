trait/racial

	Dragon_Disciple
		name = "Dragon Disciple"
		desc = "You follow the ways of the ancient Dragon Clan. Though the art of creating the mythical Wish Orbs eludes you for now \
				there are many other techniques you have come to master.  \
				Gain 3 skills of your choice from the Dragon Clan skill list and increase meditation mod by 1."

		IsValidRace(mob/M)
			return M && M.Race == "Puranto"

		SpecialGainEvent(mob/M)
			if(!M || !M.client) return
			var/list/skillChoices = DragonSkillChoices()
			var/list/skillPicks = new/list
			var/picks = 0
			while(picks < 3)
				skillPicks += input(M, "Choose your [picks+1]\th skill.") in skillChoices - skillPicks
				picks++
			M.contents.Add(skillPicks)
			M.med_mod++
	
	Dedicated_Warrior
		name = "Dedicated Warrior"
		desc = "You have dedicated your life to mastering the ancient combative arts of your people. \
				Though you lack the spiritual empowerment of the Dragon Disciples, your raw battle potential more than makes up for it. \
				Gain 3 skills of your choice from the Warrior-type skill list and increase Adaptation rate by 1."

		IsValidRace(mob/M)
			return M && M.Race == "Puranto"

		SpecialGainEvent(mob/M)
			if(!M || !M.client) return
			var/list/skillChoices = FighterSkillChoices()
			var/list/skillPicks = new/list
			var/picks = 0
			while(picks < 3)
				skillPicks += input(M, "Choose your [picks+1]\th skill.") in skillChoices - skillPicks
				picks++
			M.contents.Add(skillPicks)
			M.leech_rate++
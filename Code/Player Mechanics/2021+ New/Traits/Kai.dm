trait/racial

	Martial_Way
		name = "A Rose by Any Other Name"
		desc = "You have dedicated your eternal life to mastering the martial forms- something often frowned upon \
				by those of your station.  +20% Battle Power.  -50% Meditation gains.  Choice of 3 skills from a list."
		
		IsValidRace(mob/M)
			return M && M.Race == "Kai"
		
		SpecialGainEvent(mob/M)
			if(!M || !M.client) return
			var/list/skillChoices = KaiSkillChoices()
			var/list/skillPicks = new/list
			var/picks = 0
			while(picks < 3)
				skillPicks += input(M, "Choose your [picks+1]\th skill.") in skillChoices - skillPicks
				picks++
			M.contents.Add(skillPicks)
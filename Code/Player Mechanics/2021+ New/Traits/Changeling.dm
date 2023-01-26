trait/racial	
	Unrivaled_Cruelty
		name = "Unrivaled Cruelty"
		desc = "You have a penchant for inflicting extreme pain and drawing out kills. \
				You deal 1% more health damage to your foe per injury they have sustained but also 1% less determination damage."

		IsValidRace(mob/M)
			return M && M.Race == "Frost Lord"

		SpecialGainEvent(mob/M)
			if(!M || !M.client) return
	
	Die_By_Hand
		name = "You Will Die By My Hand"
		desc = "You refuse to accept defeat, and are determined to destroy those who would oppose you. \
				The lower your health gets, the more determination damage you will deal to your opponent."

		IsValidRace(mob/M)
			return M && M.Race == "Frost Lord"

		SpecialGainEvent(mob/M)
			if(!M || !M.client) return
trait/racial

	Always_Angry
		name = "That's My Secret Cap"
		desc = "You are fueled by a never-ending pit of rage.  Lose the benefits of Anger, \
				but gain a 150% bonus to damage mitigation and energy reserves."

		IsValidRace(mob/M)
			return M && M.Class == "Legendary"

		SpecialGainEvent(mob/M)
			if(!M || !M.client) return
	
	Wrathful
		name = "Fueled by Rage"
		desc = "Your rage manifests in a unique way compared to your Yasai brethren.  \
				+1 to Anger.  Anger lasts until KOd.  While Angered, Health is used instead of Energy \
				for attacks and power control."

		IsValidRace(mob/M)
			return M && M.Class == "Legendary"

		SpecialGainEvent(mob/M)
			if(!M || !M.client) return
			M.max_anger += 100
	
	True_Elite
		name = "True Elite"
		desc = "Your natural power sets you above the masses as their better. \
				Start at Power Tier 6 with 3 trait points, and choose 2 skills from the Elite skill list. \
				Energy boosted to 500 x mod.  Leech rate halved."

		IsValidRace(mob/M)
			return M && M.Race == "Yasai" && !M.Class

		SpecialGainEvent(mob/M)
			if(!M || !M.client) return
			var/list/skillChoices = EliteSkillChoices()
			var/list/skillPicks = new/list
			var/picks = 0
			while(picks < 2)
				skillPicks += input(M, "Choose your [picks+1]\th skill.") in skillChoices - skillPicks
				picks++
			M.contents.Add(skillPicks)
			M.base_bp = GetTierReq(6)
			M.max_ki = Math.Max(M.max_ki, 500 * M.Eff)
			M.leech_rate *= 0.5
			M.tail_level = 10
			var/trait/T = M.GetTraitByName("Tail Training")
			if(T) T.rank = 10
			M.Class = "Elite"
			M.originalClass = M.Class
	
	Lowborn
		name = "Lowborn"
		desc = "You were born even weaker than the average Yasai, but have the potential to grow far greater. \
				Base Battle Power set to 1 (Tier 1) and gain 150% skill mastery. \
				Adaptation rate increased by 25%."

		IsValidRace(mob/M)
			return M && M.Race == "Yasai" && !M.Class

		SpecialGainEvent(mob/M)
			if(!M || !M.client) return
			M.base_bp = 1
			M.leech_rate *= 1.25
			M.mastery_mod *= 2.5
			M.Class = "Low Class"
			M.originalClass = M.Class
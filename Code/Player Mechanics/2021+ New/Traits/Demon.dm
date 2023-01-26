trait/racial

	Manipulation
		name = "Master of Manipulation"
		desc = "Sometimes the slightest push, the smallest touch, sends echoes throughout life. \
				Gain the Imitate and Telepathy skills.  Gain 50% more meditation mod.  Deal 5% less and take 5% more damage. \
				Increase Intelligence mod to 1."

		IsValidRace(mob/M)
			return M && M.Race == "Demon"
	
		SpecialGainEvent(mob/M)
			if(!M || !M.client) return
			M.Intelligence = 1
			M.med_mod *= 1.5
			M.contents.Add(new/obj/Skills/Utility/Imitation, new/obj/Skills/Utility/Telepathy)
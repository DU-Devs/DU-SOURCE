trait/racial	
	Pure_Form
		name = "Purity of Form"
		desc = "While other Majin spawn seek to gather the strengths of other races, you remain pure of form. \
				Lose access to the Majin Absorb powers.  +60% Battle Power.  Intelligence set to 0.1x. \
				Increase Recovery by 0.8.  Increase Durability and Resistance by 2."

		IsValidRace(mob/M)
			return M && M.Race == "Majin"

		SpecialGainEvent(mob/M)
			if(!M || !M.client) return
			M.Intelligence = 0.1
			M.recov += 0.8
			M.End += 2
			M.Res += 2

trait/special
	Super_Majin
		name = "Super Majin"
		desc = "With every other Majin you absorb, the closer you get to regaining your true power.  Increase your absorb power by 5% per rank."
		maxRank = 9

		CanGainRank(mob/M)
			return ..() && M && M.Race == "Majin" && !M.HasTrait("Purity of Form")

		SpecialGainEvent(mob/M)
			if(!M || !M.client) return
			M.majinAbsorbPower = 1 + rank * 0.05

		ListReqs()
			var/html = "<p>Must be a Majin.</p>"
			html += "<p>May not have the racial trait 'Purity of Form'</p>"
			return html
	
	Perfected_Majin
		name = "Perfected Majin"
		desc = "You have regained your true power, granting you the might thought forever lost. Recovery increased by 0.8 and absorb power set to 3x."

		CanGainRank(mob/M)
			return ..() && M && M.Race == "Majin" && M.GetTraitRank("Super Majin") >= 10

		SpecialGainEvent(mob/M)
			if(!M || !M.client) return
			M.majinAbsorbPower = 3
			M.recov += 0.8

		ListReqs()
			var/html = "<p>Must be a Majin.</p>"
			html += "<p>May not have the racial trait 'Purity of Form'</p>"
			return html
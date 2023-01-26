trait/racial

	Battery
		name = "Who Needs a Stupid Comet Anyway?"
		desc = "A chunk of the Power Comet fell to Earth, and actually became lodged within your body. \
				You now experience a portion of the power boost from the Comet at all times.  \
				When the comet is nearby, your body becomes overloaded and you lose 60% of your BP and Ki until it passes."
		
		IsValidRace(mob/M)
			return M && M.Race == "Onion Lad"
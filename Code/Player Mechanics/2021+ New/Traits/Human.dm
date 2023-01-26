trait/racial

	Cyberware
		name = "Cyberware 20XX"
		desc = "Outfitted with the most advanced in cybernetic enhancements, you are truly a step ahead of your kind. \
				Begin with Lv2 Robotics tools, 1'000'000 Resources, and your choice of 3 modules from a list. \
				-50% leech rate, and lose access to the Pump Up transformation."
		
		IsValidRace(mob/M)
			return M && M.Race == "Human" && !M.Class
		
		SpecialGainEvent(mob/M)
			if(!M || !M.client) return
			var/obj/items/Robotics_Tools/robo = new
			robo.Level++
			robo.Upgrade_Power+=0.3
			
			var/list/moduleChoices = CyberModuleChoices()
			var/list/modulePicks = new/list
			var/picks = 0
			while(picks < 3)
				modulePicks += input(M, "Choose your [picks+1]\th skill.") in moduleChoices - modulePicks
				picks++
			M.contents.Add(modulePicks)
			robo.Move(M)
			M.Alter_Res(1000000)
			M.leech_rate *= 0.5
			M.Class = "Cyborg"
	
	Third_Eye
		name = "Are We Sure That's a Human?"
		desc = "Your intense meditation and search for enlightenment has granted you the ultimate boon: \
				You have unlocked your Third Eye Chakra.  +65% Battle Power.  +100% Meditation gains. \
				+100% Mastery rate.  -50% Adaptation gain.  Lose access to the Pump Up transformation."
		
		IsValidRace(mob/M)
			return M && M.Race == "Human" && !M.Class
		
		SpecialGainEvent(mob/M)
			if(!M || !M.client) return
			M.leech_rate *= 0.5
			M.mastery_mod *= 2
			M.med_mod *= 2
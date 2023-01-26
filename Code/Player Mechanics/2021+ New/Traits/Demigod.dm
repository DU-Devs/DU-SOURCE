trait/racial

	Maui
		name = "Lasso the Sun"
		desc = "What can I say, except... ?  Intelligence mod increased to 1.  Mastery mod increased by 300%.  Gain 75 base stamina."

		IsValidRace(mob/M)
			return M && M.Race == "Demigod"
	
		SpecialGainEvent(mob/M)
			if(!M || !M.client) return
			M.Intelligence = 1
			M.mastery_mod *= 4
	
	Achilles
		name = "Mind the Heel"
		desc = "Your godly lineage grants you incredible strength, and many assume you to be unbeatable in combat. \
				20% increase to melee damage dealt, but 20% weaker to Ki damage.  150% grab strength and strangle damage."

		IsValidRace(mob/M)
			return M && M.Race == "Demigod"
	
	Thor
		name = "Shock and Awe"
		desc = "You have been granted a powerful weapon by your godly parent, through which your latent power \
				can be channeled.  Granted unique, soulbound weapon with chance to inflict minor stun and which \
				offers increased health regeneration and energy recovery while wielded."

		IsValidRace(mob/M)
			return M && M.Race == "Demigod"
	
		SpecialGainEvent(mob/M)
			if(!M || !M.client) return
			var/list/weapons = new/list
			for(var/i in typesof(/obj/items/Equipment/Weapon))
				if(i == /obj/items/Equipment/Weapon) continue
				if(i == /obj/items/Equipment/Weapon/Bladed) continue
				if(i == /obj/items/Equipment/Weapon/Blunt) continue
				var/obj/items/Equipment/Weapon/W = new i
				weapons.Add(W)
			var/obj/items/Equipment/Weapon/W = input(M, "What kind of weapon were you bestowed?") in weapons
			if(!W) W = new/obj/items/Equipment/Weapon/Blunt/Light_Hammer
			W.stunning = 1
			W.soulbound = M.key
			W.regenBonus = 1.6
			W.recovBonus = 1.6
			W.Move(M)
trait/racial

	Pure_Genius
		name = "Pure Genius"
		desc = "Your intelligence knows few equals.  Set Intelligence score to 1, increase knowledge cap rate by 100%."

		IsValidRace(mob/M)
			return M && M.Race == "Alien"

		SpecialGainEvent(mob/M)
			if(!M || !M.client) return
			M.Intelligence = 1
	
	Precognition
		name = "Precognition"
		desc = "You are able to see glimpses of the future.  Gain the ability to avoid up to 6 incoming attacks automatically, once per minute."

		IsValidRace(mob/M)
			return M && M.Race == "Alien"

		SpecialGainEvent(mob/M)
			if(!M || !M.client) return
			M.precog = 1
	
	Regenerative_Form
		name = "Regenerative Form"
		desc = "Your body has a habit of piecing itself back together, even after sustaining lethal damage.  Death Regeneration set to 50%."

		IsValidRace(mob/M)
			return M && M.Race == "Alien"

		SpecialGainEvent(mob/M)
			if(!M || !M.client) return
			M.Regenerate = 0.5
	
	Skilled
		name = "A Skillful Being"
		desc = "You are one trained in many skills.  Choose 2 skills from a list."

		IsValidRace(mob/M)
			return M && M.Race == "Alien"

		SpecialGainEvent(mob/M)
			if(!M || !M.client) return
			var/list/skillChoices = AlienSkillChoices()
			var/list/skillPicks = new/list
			var/picks = 0
			while(picks < 2)
				skillPicks += input(M, "Choose your [picks+1]\th skill.") in skillChoices - skillPicks
				picks++
			M.contents.Add(skillPicks)

proc/AlienSkillChoices()
	var/list/L = EliteSkillChoices()
	for(var/obj/i in DragonSkillChoices())
		var/addSkill = 1
		for(var/obj/s in L)
			if(i.type == s.type)
				addSkill = 0
				break
		if(addSkill) L += i
	for(var/obj/i in FighterSkillChoices())
		var/addSkill = 1
		for(var/obj/s in L)
			if(i.type == s.type)
				addSkill = 0
				break
		if(addSkill) L += i
	return L
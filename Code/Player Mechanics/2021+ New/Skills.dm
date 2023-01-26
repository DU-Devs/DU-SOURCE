var/list/LockedSkills = new/list

mob/Admin4/verb/Manage_Skills()
	set category = "Admin"
	if(!LockedSkills) LockedSkills = new/list
	while(src)
		switch(alert(usr, "What would you like to do?", "Manage Skills", "Lock a Skill", "Unlock a Skill", "Cancel"))
			if("Cancel") break
			if("Lock a Skill")
				while(src)
					var/list/allSkills = GetSkillTypes()
					var/n = input(usr, "Lock which Skill?") in list("Done") + (allSkills - LockedSkills)
					if(!n || n == "Done") break
					ToggleSkillLock(allSkills[n])
			if("Unlock a Skill")
				while(src)
					var/n = input(usr, "Unlock which Skill?") in list("Done") + LockedSkills
					if(!n || n == "Done") break
					ToggleSkillLock(LockedSkills[n])

proc/ToggleSkillLock(n)
	if(!ispath(n)) return
	var/skill/T = new n
	if(T.name in LockedSkills)
		LockedSkills.Remove(T.name)
	else
		LockedSkills[T.name] += n

proc/IsSkillLocked(n)
	return n in LockedSkills

proc/GetSkillTypes()
	var/list/L = new/list
	for(var/i in (typesof(/skill) - /skill))
		var/skill/S = new i
		if(!S) continue
		L[S.name] = i
	return L

proc/GetSkillList()
	var/list/L = new/list
	for(var/i in (typesof(/skill) - /skill))
		var/skill/S = new i
		if(!S) continue
		L[S.name] = S
	return L

mob/var/skillPoints = 2
mob/var/bonusSkillPoints = 0
mob/var/spentSkillPoints = 0

mob/proc/GainSkillPoints()
	var/expectedPoints = bpTier * 2 + bonusSkillPoints
	expectedPoints -= skillPoints + spentSkillPoints
	if(expectedPoints > 0) skillPoints += expectedPoints

mob/proc/GetLearnableSkills()
	var/list/allSkills = GetSkillList()
	var/list/L = new/list
	for(var/i in allSkills)
		var/skill/S = allSkills[i]
		if(!S.CanGainSkill(src)) continue
		L["[S.name] | Cost: [S.cost]"] = S
	return L

mob/proc/LearnSkills()
	while(src)
		var/list/learnableSkills = GetLearnableSkills()
		var/inp = input(src, "What skill do you want to learn? (Skill Points: [skillPoints])", "Learn Skill") in list("Cancel") + learnableSkills
		if(!inp || inp == "Cancel") break
		var/skill/S = learnableSkills[inp]
		S.GainSkill(src)


skill
	var
		name
		desc
		cost
		skillObject

	proc
		GainSkill(mob/M)
			if(!CanGainSkill(M) || M.skillPoints < cost) return
			M.skillPoints -= cost
			M.spentSkillPoints += cost
			M.contents.Add(new skillObject)
		
		CanGainSkill(mob/M)
			return !IsSkillLocked(name) && !M.HasSkill(skillObject)
		
	Blast
		name = "Blast"
		desc = "A small orb of ki that can be fired quickly, but deals low damage."
		cost = 1
		skillObject = /obj/Skills/Combat/Ki/Blast

	Beam
		name = "Beam"
		desc = "Ki energy fired in a continuous straight line."
		cost = 1
		skillObject = /obj/Skills/Combat/Ki/Beam

		CanGainSkill(mob/M)
			return ..() && M.HasSkill(/obj/Skills/Combat/Ki/Blast)

	Charge
		name = "Charge"
		desc = "A larger orb of ki that takes time to fire, but deals substantially more damage on a hit."
		cost = 1
		skillObject = /obj/Skills/Combat/Ki/Charge

		CanGainSkill(mob/M)
			return ..() && M.HasSkill(/obj/Skills/Combat/Ki/Blast)

	Big_Bang
		name = "Big Bang Attack"
		desc = "Like the Charge ki attack but on steroids."
		cost = 5
		skillObject = /obj/Skills/Combat/Ki/Big_Bang_Attack

		CanGainSkill(mob/M)
			return ..() && M.HasSkill(/obj/Skills/Combat/Ki/Charge)
	
	Sokidan
		name = "Sokidan"
		desc = "A ball of energy that can be controlled even after thrown at the enemy."
		cost = 1
		skillObject = /obj/Skills/Combat/Ki/Sokidan

		CanGainSkill(mob/M)
			return ..() && M.HasSkill(/obj/Skills/Combat/Ki/Charge) && M.HasSkill(/obj/Skills/Combat/Ki/Beam)
	
	Kienzan
		name = "Kienzan"
		desc = "A disc of energy that can be controlled even after thrown at the enemy."
		cost = 3
		skillObject = /obj/Skills/Combat/Ki/Kienzan

		CanGainSkill(mob/M)
			return ..() && M.HasSkill(/obj/Skills/Combat/Ki/Charge) && M.HasSkill(/obj/Skills/Combat/Ki/Beam)
	
	Explosion
		name = "Explosion"
		desc = "A tiny blast of key targeted at the ground that expands instantly upon impact to create a devastating explosion."
		cost = 2
		skillObject = /obj/Skills/Combat/Ki/Explosion
	
	Scatter_Shot
		name = "Scatter Shot"
		desc = "Surround your opponent with countless orbs of ki, then release them all in a massive homing strike."
		cost = 3
		skillObject = /obj/Skills/Combat/Ki/Scatter_Shot

		CanGainSkill(mob/M)
			return ..() && M.HasSkill(/obj/Skills/Combat/Ki/Charge)
	
	Shockwave
		name = "Scatter Shot"
		desc = "This emits a shockwave that will knockback anyone within range, dealing some damage."
		cost = 1
		skillObject = /obj/Skills/Combat/Ki/Shockwave
	
	Buster_Barrage
		name = "Buster Barrage"
		desc = "An attack which shoots energy from all parts of your body in random directions."
		cost = 3
		skillObject = /obj/Skills/Combat/Ki/Buster_Barrage

		CanGainSkill(mob/M)
			return ..() && M.HasSkill(/obj/Skills/Combat/Ki/Charge)
	
	Dash_Attack
		name = "Dash Attack"
		desc = "Launch yourself forward like a bullet, knocking away and dealing massive damage to anyone in your path."
		cost = 2
		skillObject = /obj/Skills/Combat/Melee/Dash_Attack

		CanGainSkill(mob/M)
			return ..() && M.HasSkill(/obj/Skills/Utility/Power_Control)
	
	Power_Control
		name = "Power Control"
		desc = "Gain the ability to control your ki, allowing you to increase or decrease your power, so long as you have the energy to do so."
		cost = 1
		skillObject = /obj/Skills/Utility/Power_Control

		CanGainSkill(mob/M)
			return ..() && M.HasSkill(/obj/Skills/Utility/Sense)
	
	Advanced_Meditation
		name = "Advanced Meditation"
		desc = "Your meditation is no longer just for rest, but a way to enhance your power.  (Gain BP while meditating.)"
		cost = 1
		skillObject = /obj/Skills/Utility/Meditate/Level2

		CanGainSkill(mob/M)
			return ..() && M.HasSkill(/obj/Skills/Utility/Power_Control)

	Sense
		name = "Ki Sense"
		desc = "You are now capable of sensing your own ki, and that of others."
		cost = 1
		skillObject = /obj/Skills/Utility/Sense
	
	Advanced_Sense
		name = "Advanced Ki Sense"
		desc = "Your ability to sense the ki of others has been enhanced to pinpoint accuracy."
		cost = 2
		skillObject = /obj/Skills/Utility/Sense/Level2

		CanGainSkill(mob/M)
			return ..() && M.HasSkill(/obj/Skills/Utility/Sense)
	
	Divine_Sense
		name = "Divine Ki Sense"
		desc = "Your ki senses now rival those of divine beings, allowing you to gain knowledge about others that would be otherwise hidden."
		cost = 3
		skillObject = /obj/Skills/Utility/Sense/Level3

		CanGainSkill(mob/M)
			return ..() && M.HasSkill(/obj/Skills/Utility/Sense/Level2)
	
	Give_Power
		name = "Give Power"
		desc = "You can channel your ki to another entity, empowering them and even healing them slightly."
		cost = 2
		skillObject = /obj/Skills/Utility/Give_Power

		CanGainSkill(mob/M)
			return ..() && M.HasSkill(/obj/Skills/Utility/Power_Control)
	
	Zanzoken
		name = "Zanzoken"
		desc = "By empowering yourself with ki for a brief moment, you are able to move so quickly as to seem to teleport a short distance."
		cost = 1
		skillObject = /obj/Skills/Utility/Zanzoken

		CanGainSkill(mob/M)
			return ..() && M.HasSkill(/obj/Skills/Utility/Power_Control)
	
	Telepathy
		name = "Telepathy"
		desc = "Communicate telepathically with an entity you are capable of perceiving."
		cost = 1
		skillObject = /obj/Skills/Utility/Telepathy

		CanGainSkill(mob/M)
			return ..() && M.HasSkill(/obj/Skills/Utility/Sense/Level2)
	
	Shield
		name = "Shield"
		desc = "Form a protective barrier of ki around yourself."
		cost = 3
		skillObject = /obj/Skills/Combat/Ki/Shield

		CanGainSkill(mob/M)
			return ..() && M.HasSkill(/obj/Skills/Utility/Power_Control)
	
	Instant_Transmission
		name = "Instant Transmission"
		desc = "With great focus you can lock onto the energy signature of another entity to instantly travel to their location."
		cost = 5
		skillObject = /obj/Skills/Utility/Shunkan_Ido

		CanGainSkill(mob/M)
			return ..() && M.HasSkill(/obj/Skills/Utility/Sense/Level2) && M.HasSkill(/obj/Skills/Utility/Meditate/Level2)
	
	Power_Orb
		name = "Power Orb"
		desc = "Simulate a full moon with your energy.  This will provide a slightly weaker but on-demand version of the Oozaru transformation."
		cost = 1
		skillObject = /obj/Skills/Utility/Power_Orb

		CanGainSkill(mob/M)
			return ..() && M.HasSkill(/obj/Skills/Utility/Power_Control) && M.HasTrait("Great Ape Control")

	Flight
		name = "Flight"
		desc = "Make use of your energy to propel yourself through the air.  Faster and more maneuverable than walking, to be sure."
		cost = 1
		skillObject = /obj/Skills/Utility/Fly

	Self_Destruct
		name = "Self Destruct"
		desc = "Build up a massive blast of energy around yourself which will likely obliterate everything it touches- including you."
		cost = 2
		skillObject = /obj/Skills/Combat/Ki/Self_Destruct

		CanGainSkill(mob/M)
			return ..() && M.HasSkill(/obj/Skills/Combat/Ki/Explosion)
	
	Heal
		name = "Heal"
		desc = "Release a special burst of ki which will heal injuries and restore health."
		cost = 2
		skillObject = /obj/Skills/Utility/Heal

		CanGainSkill(mob/M)
			return ..() && M.HasSkill(/obj/Skills/Utility/Give_Power)
	
	Solar_Flare
		name = "Solar Flare"
		desc = "Release a blinding light by focusing your ki."
		cost = 1
		skillObject = /obj/Skills/Combat/Ki/Taiyoken

		CanGainSkill(mob/M)
			return ..() && M.HasSkill(/obj/Skills/Utility/Power_Control)
	
	Observe
		name = "Observe"
		desc = "Focus your mind's eye on an individual entity, and peer through the great beyond to observe them."
		cost = 2
		skillObject = /obj/Skills/Utility/Observe

		CanGainSkill(mob/M)
			return ..() && M.HasSkill(/obj/Skills/Utility/Sense/Level2)
	
	Divine_Eye
		name = "Divine Observe"
		desc = "You are able to peer through the curtain of reality across space and time, experiencing far off events as if you were there in person."
		cost = 5
		skillObject = /obj/Skills/Utility/Observe/Advanced

		CanGainSkill(mob/M)
			return ..() && M.HasSkill(/obj/Skills/Utility/Observe) && M.HasSkill(/obj/Skills/Utility/Sense/Level3)
	
	Restore_Youth
		name = "Restore Youth"
		desc = "You have gained the ability to restore youth at little cost to yourself."
		cost = 5
		skillObject = /obj/Skills/Divine/Restore_Youth

		CanGainSkill(mob/M)
			return ..() && M.HasSkill(/obj/Skills/Utility/Sense/Level3) && M.HasSkill(/obj/Skills/Utility/Heal)
	
	Splitform
		name = "Splitform"
		desc = "Create copies of yourself.  Each copy splits your power further, making you weaker in exchange."
		cost = 1
		skillObject = /obj/Skills/Combat/SplitForm
	
	Death_Ball
		name = "Death Ball"
		cost = 2
		skillObject = /obj/Skills/Combat/Ki/Genki_Dama/Death_Ball

		CanGainSkill(mob/M)
			return ..() && M.HasSkill(/obj/Skills/Utility/Power_Control) && M.HasSkill(/obj/Skills/Combat/Ki/Charge)
	
	Supernova
		name = "Supernova"
		cost = 3
		skillObject = /obj/Skills/Combat/Ki/Genki_Dama/Supernova

		CanGainSkill(mob/M)
			return ..() && M.HasSkill(/obj/Skills/Utility/Power_Control) && M.HasSkill(/obj/Skills/Combat/Ki/Charge)
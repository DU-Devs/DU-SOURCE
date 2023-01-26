transformation/Titan
	name = "Titan"
	desc = "The blood of Titans flows through your veins.  Unleash their might."

	startupDelay = 30
	minDrain = 1.5
	masteryRate = 0.3

	aura = 'Aura, Big.dmi'
	overlays = list(list('Electric_Mystic.dmi', rgb(0,0,0), 0, 0))

	CanAccessForm(mob/M)
		if(!M) return
		return ..() && M.Race == "Demigod" && M.Class != "Cyborg"
	
	CanEnterForm(mob/M)
		if(!M) return
		return CanAccessForm(M) && M.bpTier >= 5 && M.HasSkill(/obj/Skills/Utility/Power_Control)
	
	UnlockForm(mob/M)
		if(!M) return
		if(CanEnterForm(M) && !(name in M.UnlockedTransformations))
			..()
	
	CanStackForm()
		return FALSE
	
	ApplyForm(mob/M)
		if(!M) return
		var/bpAdd = 75000
		M.transBPMult = 1.2
		M.transPUCap = 0.3
		M.transDurBonus = 2
		M.transResBonus = 2
		M.transSpdBonus = -2
		if(mastered) M.transBPMult += 0.4
		M.transBPAdd = Math.Max(bpAdd / M.transBPMult - M.base_bp, 0)
		M.IncreaseStamina(-(M.max_stamina * 0.05))
	
	DrainLoop(mob/M)
		set waitfor = FALSE
		set background = TRUE
		while(M && draining)
			var/stamDrain = 0.01 * GetMasteryDrain() * M.max_stamina
			M.IncreaseStamina(-stamDrain)
			if(stamDrain > M.stamina || M.KO)
				ExitForm(M)
			sleep(10)
	
	GetInfo()
		var/html = "<h3>[name]</h3><p><b>[desc]</b></p>"
		html += "<p>Must be a Demigod.  Must have Base Power Tier 5 or higher.</p>"
		html += "<p>Increase BP to 75'000 if below that amount.  Multiply BP by 1.2x.  Powerup Rate decreased to 0.3x</p>"
		html += "<p>+2 Durability and Resistance.  -2 Speed.</p>"
		html += "<p>+40% BP once mastered.</p>"
		html += "<hr>"
		return html

transformation/Demon_God
	name = "Demon God"
	desc = "It is rare for denizens of Hell to achieve Godly Ki, but you have, nonetheless, done exactly that."

	startupDelay = 10

	aura = 'Aura, Big.dmi'
	auraScaleX = 96
	auraScaleY = 96
	hairColor = rgb(100, 0, 0)

	CanAccessForm(mob/M)
		if(!M) return
		return ..() && M.Race == "Demon" && M.Class != "Cyborg"
	
	CanEnterForm(mob/M)
		if(!M) return
		return CanAccessForm(M) && M.bpTier >= 45 && M.HasSkill(/obj/Skills/Utility/Power_Control)
	
	UnlockForm(mob/M)
		if(!M) return
		if(CanEnterForm(M) && !(name in M.UnlockedTransformations))
			..()
	
	CanStackForm()
		return FALSE
	
	ApplyForm(mob/M)
		if(!M) return
		var/bpAdd = 1250000000
		M.transBPMult = 3.5
		M.transPUCap = 0.3
		M.transDurBonus = 2
		M.transResBonus = 2
		M.transSpdBonus = -2
		M.transBPAdd = Math.Max(bpAdd / M.transBPMult - M.base_bp, 0)
		M.IncreaseStamina(-(M.max_stamina * 0.05))
	
	DrainLoop(mob/M)
		set waitfor = FALSE
		set background = TRUE
		while(M && draining)
			var/stamDrain = 0.025 * GetMasteryDrain() * M.max_stamina
			M.IncreaseStamina(-stamDrain)
			if(stamDrain > M.stamina || M.KO)
				ExitForm(M)
			sleep(10)
	
	GetInfo()
		var/html = "<h3>[name]</h3><p><b>[desc]</b></p>"
		html += "<p>Must be a Demon.  Must have Base Power Tier 45 or higher.</p>"
		html += "<p>Increase BP to 1'250'000'000 if below that amount.  Multiply BP by 3.5x.  Powerup Rate decreased to 0.3x</p>"
		html += "<p>+2 Durability and Resistance.  -2 Speed.</p>"
		html += "<hr>"
		return html

transformation/Fury
	name = "Furious God"
	desc = "Your ascension to godhood has done nothing to quell your fury."

	startupDelay = 30
	mastery = 100
	mastered = 1

	aura = 'Aura, Big.dmi'
	auraScaleX = 96
	auraScaleY = 96
	hairColor = rgb(255, 89, 167)

	CanAccessForm(mob/M)
		if(!M) return
		return ..() && M.Race in list("Kai", "Demigod") && M.Class != "Cyborg"
	
	CanEnterForm(mob/M)
		if(!M) return
		return CanAccessForm(M) && M.bpTier >= 45 && M.HasSkill(/obj/Skills/Utility/Power_Control)
	
	UnlockForm(mob/M)
		if(!M) return
		if(CanEnterForm(M) && !(name in M.UnlockedTransformations))
			..()
	
	CanStackForm()
		return FALSE
	
	ApplyForm(mob/M)
		if(!M) return
		var/bpAdd = 1000000000
		M.transBPMult = 3.2
		M.transPUCap = 0.7
		M.transDurBonus = 1
		M.transResBonus = 1
		M.transSpdBonus = 1
		M.transRefBonus = -2
		M.transAccBonus = -1
		M.transBPAdd = Math.Max(bpAdd / M.transBPMult - M.base_bp, 0)
	
	DrainLoop()
		return
	
	MasteryLoop()
		return
	
	GetInfo()
		var/html = "<h3>[name]</h3><p><b>[desc]</b></p>"
		html += "<p>Must be a Kai or a Demigod.  Must have Base Power Tier 45 or higher.</p>"
		html += "<p>Increase BP to 1'000'000'000 if below that amount.  Multiply BP by 3.2x.  Powerup Rate decreased to 0.7x</p>"
		html += "<p>+1 Durability, Resistance, and Speed.  -2 Reflex.  -1 Accuracy.</p>"
		html += "<hr>"
		return html
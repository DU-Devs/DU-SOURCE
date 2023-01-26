mob/proc/FrostLordTransAdding()
	TryUnlockForm("First Form")
	TryUnlockForm("Second Form")
	TryUnlockForm("Third Form")
	FrostLordBaseIcons()

mob/proc/FrostLordBaseIcons()
	for(var/t in UnlockedTransformations)
		var/transformation/T = UnlockedTransformations[t]
		if(!T.baseIcon)
			if(t == "First Form") T.baseIcon = Form1Icon
			if(t == "Second Form") T.baseIcon = Form2Icon
			if(t == "Third Form") T.baseIcon = Form3Icon
			if(t == "Pumped Final Form") T.baseIcon = Form4Icon

transformation/Changeling_Form_One
	name = "First Form"
	desc = "Complete suppression of your true power; the most manageable of your forms."

	mastery = 100
	mastered = 1

	CanAccessForm(mob/M)
		if(!M) return
		return M.Race == "Frost Lord" && M.Class != "Cyborg"
	
	CanEnterForm(mob/M)
		if(!M) return
		return CanAccessForm(M) && M.HasSkill(/obj/Skills/Utility/Power_Control)
	
	UnlockForm(mob/M)
		if(!M) return
		if(CanEnterForm(M) && !(name in M.UnlockedTransformations))
			..()
	
	CanStackForm()
		return mastered
	
	ApplyForm(mob/M)
		if(!M) return
		M.transBPMult = 0.25
		M.transPUCap = 1.6
		M.transDurBonus = 2
		M.transResBonus = 2
	
	DrainLoop()
		return
	
	MasteryLoop()
		return
	
	GetInfo()
		var/html = "<h3>[name]</h3><p><b>[desc]</b></p>"
		html += "<p>Must be a Frost Lord.</p>"
		html += "<p>Multiply BP by 0.25x.  Powerup Rate increased to 1.6x</p>"
		html += "<p>+2 Durability and Resistance.</p>"
		html += "<hr>"
		return html

transformation/Changeling_Form_Two
	name = "Second Form"
	desc = "Further suppression of your true power."

	mastery = 100
	mastered = 1

	CanAccessForm(mob/M)
		if(!M) return
		return M.Race == "Frost Lord" && M.Class != "Cyborg"
	
	CanEnterForm(mob/M)
		if(!M) return
		return CanAccessForm(M) && M.HasSkill(/obj/Skills/Utility/Power_Control)
	
	UnlockForm(mob/M)
		if(!M) return
		if(CanEnterForm(M) && !(name in M.UnlockedTransformations))
			..()
	
	CanStackForm()
		return mastered
	
	ApplyForm(mob/M)
		if(!M) return
		M.transBPMult = 0.50
		M.transPUCap = 1.4
		M.transDurBonus = 1
		M.transResBonus = 1
		M.transForBonus = 1
	
	DrainLoop()
		return
	
	MasteryLoop()
		return
	
	GetInfo()
		var/html = "<h3>[name]</h3><p><b>[desc]</b></p>"
		html += "<p>Must be a Frost Lord.</p>"
		html += "<p>Multiply BP by 0.50x.  Powerup Rate increased to 1.4x</p>"
		html += "<p>+1 Durability, Resistance, and Force.</p>"
		html += "<hr>"
		return html

transformation/Changeling_Form_Three
	name = "Third Form"
	desc = "Minor suppression of your true power."

	mastery = 100
	mastered = 1

	CanAccessForm(mob/M)
		if(!M) return
		return M.Race == "Frost Lord" && M.Class != "Cyborg"
	
	CanEnterForm(mob/M)
		if(!M) return
		return CanAccessForm(M) && M.HasSkill(/obj/Skills/Utility/Power_Control)
	
	UnlockForm(mob/M)
		if(!M) return
		if(CanEnterForm(M) && !(name in M.UnlockedTransformations))
			..()
	
	CanStackForm()
		return mastered
	
	ApplyForm(mob/M)
		if(!M) return
		M.transBPMult = 0.75
		M.transPUCap = 1.2
		M.transDurBonus = 1
		M.transResBonus = 1
		M.transStrBonus = 1
	
	DrainLoop()
		return
	
	MasteryLoop()
		return
	
	GetInfo()
		var/html = "<h3>[name]</h3><p><b>[desc]</b></p>"
		html += "<p>Must be a Frost Lord.</p>"
		html += "<p>Multiply BP by 0.75x.  Powerup Rate increased to 1.2x</p>"
		html += "<p>+1 Durability, Resistance, and Strength.</p>"
		html += "<hr>"
		return html

transformation/Pumped_Final_Form
	name = "Pumped Final Form"
	desc = "Unleash your full power, expanding your muscles and size at a cost of speed and stamina."

	startupDelay = 10
	minDrain = 0.5
	masteryRate = 0.4

	CanAccessForm(mob/M)
		if(!M) return
		return M.Race == "Frost Lord" && M.Class != "Cyborg"
	
	CanEnterForm(mob/M)
		if(!M) return
		return CanAccessForm(M) && M.bpTier >= 15
	
	UnlockForm(mob/M)
		if(!M) return
		if(CanEnterForm(M) && !(name in M.UnlockedTransformations))
			..()
	
	CanStackForm()
		return mastered
	
	ApplyForm(mob/M)
		if(!M) return
		var/bpAdd = Math.Max(50000000 / 1.8 - M.base_bp, 0)
		M.transBPAdd += bpAdd
		M.transBPMult = 1.8
		M.transSpdBonus = -2
		M.transRefBonus = -1
		M.transForBonus = 2
		M.transStrBonus = 2
		M.IncreaseStamina(-(M.max_stamina * 0.3))
		M.transStaminaRegen = 0
		M.transPUCap = 0.7
	
	DrainLoop(mob/M)
		set waitfor = FALSE
		set background = TRUE
		while(M && draining)
			var/stamDrain = 0.05 * GetMasteryDrain() * M.max_stamina
			M.IncreaseStamina(-stamDrain)
			if(stamDrain > M.stamina || M.KO)
				ExitForm(M)
			sleep(10)
	
	GetInfo()
		var/html = "<h3>[name]</h3><p><b>[desc]</b></p>"
		html += "<p>Must be a Frost Lord. Must have Base Power Tier 15 or higher.</p>"
		html += "<p>Increase BP to 50'000'000 if below that amount.  Multiply BP by 1.8x.  Powerup Rate decreased to 0.7x</p>"
		html += "<p>+2 Force and Strength. -1 Reflex.  -2 Speed.  0x Stamina Regen.</p>"
		html += "<hr>"
		return html

transformation/Overlord_Changeling
	name = "Overlord Form"
	desc = "A form that shows your true supremacy."

	startupDelay = 10
	minDrain = 0.5
	masteryRate = 0.4

	CanAccessForm(mob/M)
		if(!M) return
		return M.Class != "Cyborg" && (M.Race == "Frost Lord" || M.HasPrimaryTrait("Frost Lord Genome"))
	
	CanEnterForm(mob/M)
		if(!M) return
		return CanAccessForm(M) && M.bpTier >= 50
	
	UnlockForm(mob/M)
		if(!M) return
		if(CanEnterForm(M) && !(name in M.UnlockedTransformations))
			..()
	
	CanStackForm()
		return mastered
	
	ApplyForm(mob/M)
		if(!M) return
		var/bpAdd = 2000000000
		M.transBPMult = 2.9
		if(M.bpTier >= 60)
			bpAdd = 5000000000
			M.transBPMult = 3.2
		M.transSpdBonus = -1
		M.transRefBonus = -1
		M.transForBonus = 1
		M.transStrBonus = 2
		M.transStaminaRegen = 0.3
		M.transPUCap = 0.5
		M.transBPAdd = Math.Max(bpAdd / M.transBPMult - M.base_bp, 0)
		M.IncreaseStamina(-(M.max_stamina * 0.3))
	
	DrainLoop(mob/M)
		set waitfor = FALSE
		set background = TRUE
		while(M && draining)
			var/stamDrain = 0.03 * GetMasteryDrain() * M.max_stamina
			M.IncreaseStamina(-stamDrain)
			if(stamDrain > M.stamina || M.KO)
				ExitForm(M)
			sleep(10)
	
	GetInfo()
		var/html = "<h3>[name]</h3><p><b>[desc]</b></p>"
		html += "<p>Must be a Frost Lord (Or Bio-Android with Frost Lord as their primary genome). Must have Base Power Tier 50 or higher.</p>"
		html += "<p>Increase BP to 2'000'000'000 if below that amount.  Multiply BP by 2.9x.  Powerup Rate decreased to 0.5x</p>"
		html += "<p>Power Tier 60 or higher: Increase BP to 5'000'000'000 if below that amount.  Multiply BP by 3.2x.</p>"
		html += "<p>+1 Force. +2 Strength. -1 Reflex.  -1 Speed.  0.3x Stamina Regen.</p>"
		html += "<hr>"
		return html
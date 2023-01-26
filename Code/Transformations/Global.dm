transformation/Pump_Up
	name = "Pump Up"
	desc = "Unleash your full power, expanding your muscles and size at a cost of speed and stamina."

	startupDelay = 30
	masteryRate = 2.5
	minDrain = 0.2
	
	aura = 'Aura, Big.dmi'
	overlays = list(list('Electric_Mystic.dmi', rgb(0,0,0), 0, 0))

	CanAccessForm(mob/M)
		if(!M) return
		var/race = !(M.Race in list("Yasai", "Half Yasai", "Frost Lord", "Android", "Bio-Android"))
		var/trait = !(M.HasTrait("Cyberware 20XX") || M.HasTrait("Are We Sure That's a Human?"))
		var/class = !(M.Class in list("Legendary", "Cyborg"))
		return ..() && (race || M.HasPrimaryTrait("Human Genome")) && trait && class
	
	CanEnterForm(mob/M)
		if(!M) return
		return CanAccessForm(M) && M.max_ki >= 2500 && M.HasSkill(/obj/Skills/Utility/Power_Control)
	
	UnlockForm(mob/M)
		if(!M) return
		if(CanEnterForm(M) && !(name in M.UnlockedTransformations))
			..()
	
	CanStackForm()
		return mastered
	
	ApplyForm(mob/M)
		if(!M) return
		var/bpAdd = Math.Max(15000 / 1.2 - M.base_bp, 0)
		M.transBPAdd = bpAdd
		M.transBPMult = 1.2
		M.transPUCap = 0.7
		M.transStrBonus = 2
		M.transForBonus = 2
		M.transDurBonus = 1
		M.transResBonus = 1
		M.transSpdBonus = -2
		M.transRefBonus = -2
		M.disableStamRecovery = 1
		if(mastered)
			M.transBPMult += 0.2
			M.transSpdBonus = -1
			M.transRefBonus = -1
		M.IncreaseStamina(-(M.max_stamina * 0.02))
	
	DrainLoop(mob/M)
		set waitfor = FALSE
		set background = TRUE
		while(M && draining)
			var/stamDrain = 0.0125 * GetMasteryDrain() * M.max_stamina
			M.IncreaseStamina(-stamDrain)
			if(stamDrain > M.stamina || (M.KO && !mastered))
				ExitForm(M)
			sleep(10)
	
	GetInfo()
		var/html = "<h3>[name]</h3><p><b>[desc]</b></p>"
		html += "<p>Must not have the 'Cyberware 20XX' trait nor the 'Are We Sure That's a Human?` traits.</p>"
		html += "<p>Must not be Yasai, Half Yasai, Android, Cyborg, or a Frost Lord.</p>"
		html += "<p>Must have at least 2,500 energy (x mod).</p>"
		html += "<p>Can be combined with Kaioken once mastered.</p>"
		html += "<p>Increase BP to 15'000 if below that amount.  Multiply BP by 1.2x.  +20% BP once mastered.</p>"
		html += "<p>Powerup Rate lowered to 0.7x</p>"
		html += "<p>+1 Strength, Force, Durability and Resistance.  -2 Speed and Reflex.  (Decreased to -1 Speed and Reflex when mastered.)</p>"
		html += "<p>Drains 5% stamina per second.  Mastery decreases drain by up to 80%.</p>"
		html += "<hr>"
		return html

transformation/Mystic
	name = "Mystic"
	desc = "The ultimate potential of a fighter, awakened."

	startupDelay = 30
	mastery = 100
	mastered = 1

	aura = 'Aura, Big.dmi'
	auraScaleX = 96
	auraScaleY = 128
	overlays = list(list('Electric_Mystic.dmi', rgb(0, 0, 0), 0, 0))

	CanAccessForm(mob/M)
		if(!M) return
		return ..() && !(M.Race in list("Android", "Bio-Android", "Frost Lord", "Majin")) \
				&& !(M.Class in list("Legendary", "Cyborg"))
	
	CanEnterForm(mob/M)
		if(!M) return
		return CanAccessForm(M) && M.bpTier >= 30 && M.HasSkill(/obj/Skills/Utility/Power_Control)
	
	UnlockForm(mob/M)
		if(!M) return
		if(CanEnterForm(M) && !(name in M.UnlockedTransformations))
			..()
	
	CanStackForm()
		return FALSE
	
	ApplyForm(mob/M)
		if(!M) return
		var/bpAdd = 250000000
		M.transBPMult = 2.0
		M.transPUCap = 1.6
		M.transSpdBonus = 3
		M.transAccBonus = 2
		if(M.Race == "Half Yasai")
			M.transBPMult += 0.2
			M.transPUCap += 0.2
			bpAdd += 50000000
		if(M.bpTier >= 40)
			M.transBPMult += 0.4
			bpAdd = 300000000
		if(M.bpTier >= 45)
			M.transBPMult += 0.4
			bpAdd = 1000000000
		if(M.bpTier >= 50)
			M.transBPMult += 0.4
			bpAdd = 1250000000
		M.transBPAdd = Math.Max(bpAdd / M.transBPMult - M.base_bp, 0)
	
	DrainLoop()
		return
	
	MasteryLoop()
		return
	
	GetInfo()
		var/html = "<h3>[name]</h3><p><b>[desc]</b></p>"
		html += "<p>Must not be an Android, Frost Lord, Majin, Bio-Android (unless Human is their primary genome), Cyborg, or Legendary Yasai.  \
					Must have Base Power Tier 30 or higher.</p>"
		html += "<p>Increase BP to 250'000'000 if below that amount.  Multiply BP by 2x.  Powerup Rate increased to 1.6x</p>"
		html += "<p>+3 Speed.  +2 Accuracy.</p>"
		html += "<p>Increase BP multiplier by +40% at tiers 40, 45, and 50.</p>"
		html += "<hr>"
		return html
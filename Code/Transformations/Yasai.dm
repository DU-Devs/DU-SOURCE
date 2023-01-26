mob/var/inspiration = 0

transformation/Omega_Yasai
	name = "Omega Yasai"
	desc = "You're not dealing with the average Yasai warrior anymore..."

	startupDelay = 30
	masteryRate = 3

	aura = "Aura, SSj, Big.dmi"
	auraScaleX = 90
	auraScaleY = 90
	hairColor = rgb(228, 200, 40)

	CanAccessForm(mob/M)
		if(!M) return
		return ..() && (M.Race in list("Yasai", "Half Yasai")) && !(M.Class in list("Legendary", "Cyborg"))
	
	CanEnterForm(mob/M)
		if(!M) return
		return CanAccessForm(M) && (M.IsInspired(name) || M.bpTier >= 15) && M.HasSkill(/obj/Skills/Utility/Power_Control)
	
	UnlockForm(mob/M)
		if(!M) return
		if(CanEnterForm(M) && !(name in M.UnlockedTransformations))
			..()
	
	ApplyForm(mob/M)
		if(!M) return
		var/bpAdd = 65000000
		M.transBPMult = 1.4
		M.transPUCap = 0.7
		switch(M.Class)
			if("Elite")
				M.transSpdBonus = -1
				M.transStrBonus = 1
				M.transForBonus = 1
				M.transAccBonus = -1
				M.transBPMult += 0.15
			if("Low Class")
				M.transSpdBonus = 1
				M.transRefBonus = 1
				M.transBPMult += 0.2
			else
				M.transDurBonus = 1
				M.transResBonus = 2
				M.transBPMult += 0.1
		if(mastered) M.transBPMult += 0.15
		M.transBPAdd = Math.Max(bpAdd / M.transBPMult - M.base_bp, 0)
		M.IncreaseStamina(-(M.max_stamina * 0.05))
		M.IncreaseKi(-(M.max_ki * 0.025))
	
	DrainLoop(mob/M)
		set waitfor = FALSE
		set background = TRUE
		while(M && draining)
			var/stamDrain = 0.015 * GetMasteryDrain() * M.max_stamina
			M.IncreaseStamina(-stamDrain)
			var/kiDrain = 0.01 * GetMasteryDrain() * M.max_ki
			M.IncreaseKi(-kiDrain)
			if(stamDrain > M.stamina || kiDrain > M.Ki || (M.KO && !mastered))
				ExitForm(M)
			sleep(10)
	
	GetInfo()
		var/html = "<h3>[name]</h3><p><b>[desc]</b></p>"
		html += "<p>Must be a Yasai or Half Yasai.  May not be a Legendary Yasai.  Must have Base Power Tier 15 or higher.</p>"
		html += "<p>Increase BP to 65'000'000 if below that amount.  Multiply BP by 1.4x.  Powerup Rate decreased to 0.7x</p>"
		html += "<p>Elites: -1 Speed and Accuracy.  +1 Force and Strength.  +15% BP.</p>"
		html += "<p>Low Class: +1 Speed and Reflex.  +20% BP.</p>"
		html += "<p>Regular: +1 Durability. +2 Resistance.  +10% BP.</p>"
		html += "<p>Energy recovery and stamina regeneration disabled.</p>"
		html += "<p>Drains 2% energy per second.  Drains 1% stamina per second.  Mastery decreases drain by up to 80%.</p>"
		html += "<hr>"
		return html

transformation/Omega_Yasai_2
	name = "Omega Yasai 2"
	desc = "Blondies getting stronger, it seems."

	startupDelay = 30
	masteryRate = 2.5
	minDrain = 0.15

	aura = "Aura, SSj, Big.dmi"
	auraScaleX = 96
	auraScaleY = 128
	hairColor = rgb(230, 195, 41)
	overlays = list(list("SSj2 Electric Tobi Uchiha.dmi", rgb(0,0,0), 0, 0))

	CanAccessForm(mob/M)
		if(!M) return
		return ..() && (M.Race in list("Yasai", "Half Yasai")) && !(M.Class in list("Legendary", "Cyborg")) \
				&& M.GetFormMastery("Omega Yasai") >= 90
	
	CanEnterForm(mob/M)
		if(!M) return
		return CanAccessForm(M) && (M.IsInspired(name) || M.bpTier >= 25) && M.HasSkill(/obj/Skills/Utility/Power_Control)
	
	UnlockForm(mob/M)
		if(!M) return
		if(CanEnterForm(M) && !(name in M.UnlockedTransformations))
			..()
	
	ApplyForm(mob/M)
		if(!M) return
		var/bpAdd = 250000000
		M.transBPMult = 1.8
		M.transPUCap = 0.6
		switch(M.Class)
			if("Elite")
				M.transSpdBonus = -1
				M.transStrBonus = 1
				M.transForBonus = 1
				M.transAccBonus = -1
				M.transBPMult += 0.1
			if("Low Class")
				M.transSpdBonus = 1
				M.transRefBonus = 1
				M.transBPMult += 0.15
		if(M.Race == "Half Yasai")
			M.transStrBonus = 1
			M.transForBonus = 1
			M.transBPMult += 0.4
		if(mastered) M.transBPMult += 0.1
		M.transBPAdd = Math.Max(bpAdd / M.transBPMult - M.base_bp, 0)
		M.IncreaseStamina(-(M.max_stamina * 0.05))
		M.IncreaseKi(-(M.max_ki * 0.025))
	
	DrainLoop(mob/M)
		set waitfor = FALSE
		set background = TRUE
		while(M && draining)
			var/stamDrain = 0.015 * GetMasteryDrain() * M.max_stamina
			M.IncreaseStamina(-stamDrain)
			var/kiDrain = 0.01 * GetMasteryDrain() * M.max_ki
			M.IncreaseKi(-kiDrain)
			if(stamDrain > M.stamina || kiDrain > M.Ki || M.KO)
				ExitForm(M)
			sleep(10)
	
	GetInfo()
		var/html = "<h3>[name]</h3><p><b>[desc]</b></p>"
		html += "<p>Must be a Yasai or Half Yasai.  May not be a Legendary Yasai.  Must have mastered Omega Yasai up to 90%.  Must have Base Power Tier 25 or higher.</p>"
		html += "<p>Increase BP to 250'000'000 if below that amount.  Multiply BP by 1.8x.  Powerup Rate decreased to 0.6x</p>"
		html += "<p>Elites: -1 Speed and Accuracy.  +1 Force and Strength.  +10% BP.</p>"
		html += "<p>Low Class: +1 Speed and Reflex.  +15% BP.</p>"
		html += "<p>Half Yasai: +1 Strength and Force.  +40% BP.</p>"
		html += "<p>Drains 2% energy per second.  Drains 1% stamina per second.  Mastery decreases drain by up to 80%.</p>"
		html += "<hr>"
		return html

transformation/Omega_Yasai_3
	name = "Omega Yasai 3"
	desc = "Okay this is just getting ridiculous."

	startupDelay = 30
	masteryRate = 2
	minDrain = 0.5

	aura = "ssj3 aura.dmi"
	hairColor = rgb(220, 185, 34)
	overlays = list(list("SSj3 Electric Tobi Uchiha.dmi", rgb(0,0,0), 0, 0))

	CanAccessForm(mob/M)
		if(!M) return
		return ..() && (M.Race == "Yasai" || M.Race == "Half Yasai") && !(M.Class in list("Legendary", "Cyborg"))
	
	CanEnterForm(mob/M)
		if(!M) return
		return CanAccessForm(M) && (M.IsInspired(name) || M.bpTier >= (M.Race == "Half Yasai" ? 40 : 35)) && M.HasSkill(/obj/Skills/Utility/Power_Control) \
				&& M.GetFormMastery("Omega Yasai 2") >= 90
	
	UnlockForm(mob/M)
		if(!M) return
		if(CanEnterForm(M) && !(name in M.UnlockedTransformations))
			..()
	
	CanStackForm()
		return mastered
	
	ApplyForm(mob/M)
		if(!M) return
		var/bpAdd = 900000000
		M.transBPMult = 2.2
		M.disableKiRecovery = 1
		M.disableStamRecovery = 1
		M.transPUCap = 0.6
		if(mastered) M.transBPMult += 0.2
		M.transBPAdd = Math.Max(bpAdd / M.transBPMult - M.base_bp, 0)
		M.IncreaseStamina(-(M.max_stamina * 0.1))
		M.IncreaseKi(-(M.max_ki * 0.05))
	
	DrainLoop(mob/M)
		set waitfor = FALSE
		set background = TRUE
		while(M && draining)
			var/stamDrain = 0.005 * GetMasteryDrain() * M.max_stamina
			M.IncreaseStamina(-stamDrain)
			var/kiDrain = 0.01 * GetMasteryDrain() * M.max_ki
			M.IncreaseKi(-kiDrain)
			if(stamDrain > M.stamina || kiDrain > M.Ki || M.KO)
				ExitForm(M)
			sleep(10)
	
	GetInfo()
		var/html = "<h3>[name]</h3><p><b>[desc]</b></p>"
		html += "<p>Must be a Yasai or Half Yasai.  May not be a Legendary Yasai.  Must have mastered Omega Yasai 2 up to 90%.</p>"
		html += "<p>Must have Base Power Tier 35 (40 for Half Yasai) or higher.</p>"
		html += "<p>Increase BP to 900'000'000 if below that amount.  Multiply BP by 2.2x.  Powerup Rate decreased to 0.6x</p>"
		html += "<p>+2 Speed and Reflex.  -1 Strength and Force.</p>"
		html += "<p>Energy recovery and stamina regeneration disabled.</p>"
		html += "<p>Drains 2% energy per second.  Drains 1% stamina per second.  Mastery decreases drain by up to 80%.</p>"
		html += "<p>Can be combined with Kaioken once mastered.</p>"
		html += "<hr>"
		return html

transformation/Primal_Yasai
	name = "Primal Yasai"
	desc = "Abandon blonde, return to monke."

	startupDelay = 30
	minDrain = 0
	mastered = 1
	mastery = 100

	aura = "Aura, Big.dmi"
	auraScaleX = 96
	auraScaleY = 128

	CanAccessForm(mob/M)
		if(!M) return
		return ..() && M.Race == "Yasai" && !(M.Class in list("Legendary", "Cyborg"))
	
	CanEnterForm(mob/M)
		if(!M) return
		return CanAccessForm(M) && M.bpTier >= 55 && M.HasSkill(/obj/Skills/Utility/Power_Control)
	
	UnlockForm(mob/M)
		if(!M) return
		if(CanEnterForm(M) && !(name in M.UnlockedTransformations))
			..()
	
	ApplyForm(mob/M)
		if(!M) return
		var/bpAdd = 2500000000
		M.transBPMult = 3
		M.transPUCap = 0.5
		M.transRegenRate = 1.5
		M.transBPAdd = Math.Max(bpAdd / M.transBPMult - M.base_bp, 0)
	
	DrainLoop()
		return
	
	MasteryLoop()
		return
	
	GetInfo()
		var/html = "<h3>[name]</h3><p><b>[desc]</b></p>"
		html += "<p>Must be a Yasai.  May not be a Legendary Yasai.  Must enter Golden Great Ape to attain.  Must have Base Power Tier 55 or higher.</p>"
		html += "<p>Increase BP to 2'500'000'000 if below that amount.  Multiply BP by 3x.  Powerup Rate decreased to 0.5x</p>"
		html += "<p>Health regeneration rate set to 1.5x.</p>"
		html += "<hr>"
		return html

transformation/Omega_Yasai_God
	name = "Omega Yasai God"
	desc = "Red hair, sleek form... what's this nonsense now?"

	startupDelay = 10
	masteryRate = 3
	minDrain = 0.20

	aura = "Light_Red_Aura_Xenoverse_Color_Scheme.dmi"
	auraScaleX = 96
	auraScaleY = 96
	hairColor = rgb(190, 60, 20)

	CanAccessForm(mob/M)
		if(!M) return
		return ..() && (M.Race == "Yasai" || M.Race == "Half Yasai") && !(M.Class in list("Legendary", "Cyborg")) \
				&& M.GetFormMastery("Omega Yasai 2") >= 90
	
	CanEnterForm(mob/M)
		if(!M) return
		return CanAccessForm(M) && M.bpTier >= 45 && M.HasSkill(/obj/Skills/Utility/Power_Control)
	
	UnlockForm(mob/M)
		if(!M) return
		if(CanEnterForm(M) && !(name in M.UnlockedTransformations))
			..()
	
	ApplyForm(mob/M)
		if(!M) return
		var/bpAdd = 900000000
		M.transBPMult = 2.6
		M.transStaminaRegen = 1.4
		M.transSpdBonus = 2
		M.transRefBonus = 2
		M.transForBonus = -1
		M.transStrBonus = -1
		M.transRecovRate = 0.85
		M.transRegenRate = 1.2
		M.transPUCap = 0.4
		M.transBPAdd = Math.Max(bpAdd / M.transBPMult - M.base_bp, 0)
		M.IncreaseKi(-(M.max_ki * 0.1))
	
	DrainLoop(mob/M)
		set waitfor = FALSE
		set background = TRUE
		while(M && draining)
			var/kiDrain = 0.015 * GetMasteryDrain() * M.max_ki
			M.IncreaseKi(-kiDrain)
			if(kiDrain > M.Ki || M.KO)
				ExitForm(M)
			sleep(10)
	
	GetInfo()
		var/html = "<h3>[name]</h3><p><b>[desc]</b></p>"
		html += "<p>Must be a Yasai or Half Yasai.  May not be a Legendary Yasai.  Must have Base Power Tier 45 or higher.</p>"
		html += "<p>Increase BP to 900'000'000 if below that amount.  Multiply BP by 2.6x.  Powerup Rate decreased to 0.4x</p>"
		html += "<p>+2 Speed and Reflex.  -1 Strength and Force.</p>"
		html += "<p>Recovery rate set to 0.85x. Health regeneration rate set to 1.2x.  Stamina regeneration rate set to 1.4x</p>"
		html += "<p>Drains 1.5% energy per second.  Mastery decreases drain by up to 80%.</p>"
		html += "<hr>"
		return html

transformation/Omega_Yasai_Blue
	name = "Omega Yasai Blue"
	desc = "What is this, Omega Yasai with blue hair-dye?"

	startupDelay = 10
	minDrain = 0.5
	masteryRate = 2

	aura = "SS Blue Aura 2017.dmi"
	auraScaleX = 96
	auraScaleY = 96
	hairColor = rgb(0, 145, 230)
	overlays = list(list("SSj Blue Idle Aura.dmi", rgb(0,0,0,200), -32, -28))

	CanAccessForm(mob/M)
		if(!M) return
		return ..() && (M.Race == "Yasai" || M.Race == "Half Yasai") && !(M.Class in list("Legendary", "Cyborg"))
	
	CanEnterForm(mob/M)
		if(!M) return
		return CanAccessForm(M) && M.bpTier >= 55 && M.GetFormMastery("Omega Yasai God") >= 50
	
	UnlockForm(mob/M)
		if(!M) return
		if(CanEnterForm(M) && !(name in M.UnlockedTransformations))
			..()
		
	SpecialUnlockEvent(mob/M)
		if(M.Class == "Elite")
			startupDelay = 5
	
	CanStackForm()
		return mastered
	
	ApplyForm(mob/M)
		if(!M) return
		var/bpAdd = 2000000000
		M.transBPMult = 3
		M.transSpdBonus = -1
		M.transRefBonus = -1
		M.transForBonus = 1
		M.transStrBonus = 1
		M.disableStamRecovery = 1
		M.transPUCap = 0.4
		M.transBPAdd = Math.Max(bpAdd / M.transBPMult - M.base_bp, 0)
		M.IncreaseStamina(-(M.max_stamina * 0.3))
	
	DrainLoop(mob/M)
		set waitfor = FALSE
		set background = TRUE
		while(M && draining)
			var/stamDrain = 0.02 * GetMasteryDrain() * M.max_stamina
			M.IncreaseStamina(-stamDrain)
			if(stamDrain > M.stamina || M.KO)
				ExitForm(M)
			sleep(10)
	
	GetInfo()
		var/html = "<h3>[name]</h3><p><b>[desc]</b></p>"
		html += "<p>Must be a Yasai or Half Yasai.  May not be a Legendary Yasai.  Must have Base Power Tier 55 or higher.</p>"
		html += "<p>Increase BP to 2'000'000'000 if below that amount.  Multiply BP by 3x.  Powerup Rate decreased to 0.4x</p>"
		html += "<p>+1 Strength and Force.  -1 Speed and Reflex.</p>"
		html += "<p>Stamina Regeneration set to 0x.</p>"
		html += "<p>Drains 2% stamina per second.  Mastery decreases drain by up to 50%.</p>"
		html += "<p>Can be combined with Kaioken once mastered.</p>"
		html += "<hr>"
		return html

transformation/Omega_Yasai_Blue_Evolved
	name = "Omega Yasai Blue Evolved"
	desc = "And now he's sparkling?? Ugh."

	startupDelay = 30
	minDrain = 0.2
	masteryRate = 1.5

	aura = "SS Blue Aura 2017.dmi"
	auraScaleX = 128
	auraScaleY = 128
	hairColor = rgb(0, 85, 185)
	overlays = list(list("SSj Blue Idle Aura.dmi", rgb(8,60,51,213), -32, -28))

	CanAccessForm(mob/M)
		if(!M) return
		return ..() && (M.Race == "Yasai" || M.Race == "Half Yasai") && !(M.Class in list("Legendary", "Cyborg"))
	
	CanEnterForm(mob/M)
		if(!M) return
		return CanAccessForm(M) && M.bpTier >= 60 && M.GetFormMastery("Omega Yasai Blue") >= 90
	
	UnlockForm(mob/M)
		if(!M) return
		if(CanEnterForm(M) && !(name in M.UnlockedTransformations))
			..()
		
	SpecialUnlockEvent(mob/M)
		if(M && M.Class == "Elite")
			startupDelay = 5
	
	CanStackForm()
		return FALSE
	
	ApplyForm(mob/M)
		if(!M) return
		var/bpAdd = 5000000000 
		M.transBPMult = 3.4
		M.transSpdBonus = -1
		M.transRefBonus = -1
		M.transForBonus = 2
		M.transStrBonus = 2
		M.disableStamRecovery = 1
		M.transPUCap = 0.8
		M.transBPAdd = Math.Max(bpAdd / M.transBPMult - M.base_bp, 0)
		M.IncreaseStamina(-(M.max_stamina * 0.3))
	
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
		html += "<p>Must be a Yasai or Half Yasai.  May not be a Legendary Yasai.  Must have Base Power Tier 60 or higher.</p>"
		html += "<p>Increase BP to 5'000'000'000 if below that amount.  Multiply BP by 3.4x.  Powerup Rate decreased to 0.8x</p>"
		html += "<p>+2 Strength and Force.  -1 Speed and Reflex.</p>"
		html += "<p>Stamina Regeneration set to 0x.</p>"
		html += "<p>Drains 2.5% stamina per second.  Mastery decreases drain by up to 80%.</p>"
		html += "<hr>"
		return html

transformation/Legendary_Omega_Yasai
	name = "Legendary Omega Yasai"
	desc = "The legendary legend of legends, now a reality."

	startupDelay = 30
	masteryRate = 5

	aura = "Aura, LSSj, Big.dmi"
	auraScaleX = 100
	auraScaleY = 128
	hairColor = rgb(134, 180, 26)

	CanAccessForm(mob/M)
		if(!M) return
		return ..() && M.Race == "Yasai" && M.Class == "Legendary"
	
	CanEnterForm(mob/M)
		if(!M) return
		return CanAccessForm(M) && M.bpTier >= 15 && M.HasSkill(/obj/Skills/Utility/Power_Control)
	
	UnlockForm(mob/M)
		if(!M) return
		if(CanEnterForm(M) && !(name in M.UnlockedTransformations))
			..()
	
	CanStackForm()
		return FALSE
	
	ApplyForm(mob/M)
		if(!M) return
		var/bpAdd = 80000000
		M.transBPMult = 1.4
		M.transStaminaRegen = 3
		M.transRecovRate = 2
		M.transPUCap = 0.8
		if(M.bpTier >= 25)
			M.transBPMult += 0.4
			M.transPUCap = 0.9
			bpAdd = 300000000
		if(M.bpTier >= 35)
			M.transBPMult += 0.4
			M.transPUCap = 1
			bpAdd = 1000000000
		if(M.bpTier >= 45)
			M.transBPMult += 0.4
			bpAdd = 1250000000
		M.IncreaseKi(-(M.max_ki * 0.25))
		M.transBPAdd = Math.Max(bpAdd / M.transBPMult - M.base_bp, 0)
	
	DrainLoop(mob/M)
		set waitfor = FALSE
		set background = TRUE
		while(M && draining)
			var/kiDrain = 0.015 * GetMasteryDrain() * M.max_ki
			M.IncreaseKi(-kiDrain)
			if(kiDrain > M.Ki || (M.KO && !mastered))
				ExitForm(M)
			sleep(10)
	
	MasteryLoop(mob/M)
		set waitfor = FALSE
		set background = TRUE
		var/masteryMult = 1
		while(M && draining)
			if(M.Get_attack_gains()) masteryMult = 5
			else if(M.trainState == "Self") masteryMult = 2
			else if(M.trainState == "Shadow") masteryMult = 1.2
			if(M.IsInHBTC() && M.CanGainHBTC()) masteryMult *= 10
			mastery += 0.0015 * masteryRate * masteryMult * M.mastery_mod * Limits.GetSettingValue("Transformation Mastery Rate")
			mastery = Math.Min(mastery, 100)
			sleep(100)
	
	GetInfo()
		var/html = "<h3>[name]</h3><p><b>[desc]</b></p>"
		html += "<p>Must be a Legendary Yasai.  Must have Base Power Tier 15 or higher.</p>"
		html += "<p>Increase BP to 80'000'000 if below that amount.  Multiply BP by 1.4x.  Powerup Rate decreased to 0.8x</p>"
		html += "<p>3x Stamina Regeneration.  2x Energy Recovery.</p>"
		html += "<p>Increase BP multiplier by +40% at tiers 25, 35, and 45.</p>"
		html += "<p>Increase Powerup Rate by +10% at tiers 25 and 35.</p>"
		html += "<p>Drains 5% ki per second.  Mastery decreases drain by up to 100%.</p>"
		html += "<hr>"
		return html
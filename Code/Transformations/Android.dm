transformation/Super_Perfect
	name = "Super Perfect"
	desc = "You are part Yasai, after all."

	startupDelay = 30
	minDrain = 0.15

	aura = 'Aura, SSj, Big.dmi'
	auraScaleX = 96
	auraScaleY = 128
	hairColor = rgb(230, 195, 41)
	overlays = list(list('SSj2 Electric Tobi Uchiha.dmi', rgb(0,0,0), 0, 0))

	CanAccessForm(mob/M)
		return ..() && M.HasPrimaryTrait("Yasai Genome") 
	
	CanEnterForm(mob/M)
		return CanAccessForm(M) && M.bpTier >= 25 && M.HasSkill(/obj/Skills/Utility/Power_Control) && M.bio_form == 3
	
	UnlockForm(mob/M)
		if(CanEnterForm(M) && !(name in M.UnlockedTransformations))
			..()
	
	CanStackForm()
		return FALSE
	
	ApplyForm(mob/M)
		var/bpAdd = 250000000
		M.transBPMult = 1.8
		M.transPUCap = 0.6
		if(M.bpTier >= 35)
			M.transBPMult += 0.2
		if(M.bpTier >= 50)
			M.transBPMult += 0.25
		if(mastered)
			M.transBPMult += 0.25
		M.transBPAdd = Math.Max(bpAdd / M.transBPMult - M.base_bp, 0)
		M.IncreaseStamina(-(M.max_stamina * 0.05))
		M.IncreaseKi(-(M.max_ki * 0.015))
	
	DrainLoop(mob/M)
		set waitfor = FALSE
		set background = TRUE
		while(M && draining)
			var/stamDrain = 0.05 * GetMasteryDrain() * M.max_stamina
			M.IncreaseStamina(-stamDrain)
			var/kiDrain = 0.01 * GetMasteryDrain() * M.max_ki
			M.IncreaseKi(-kiDrain)
			if(stamDrain > M.stamina || kiDrain > M.Ki || M.KO)
				ExitForm(M)
			sleep(10)
	
	GetInfo()
		var/html = "<h3>[name]</h3><p><b>[desc]</b></p>"
		html += "<p>Must be a Bio-Android with Yasai as their primary genome.  Must have Base Power Tier 25 or higher.</p>"
		html += "<p>Increase BP to 250'000'000 if below that amount.  Multiply BP by 1.8x.</p>"
		html += "<p>0.6x Power Up Cap.</p>"
		html += "<hr>"
		return html

transformation/Super_Android
	name = "Super Android"
	desc = "Peace in our time."

	mastery = 100
	mastered = 1

	CanAccessForm(mob/M)
		if(!M) return
		return ..() && M.Race == "Android"
	
	CanEnterForm(mob/M)
		if(!M) return
		return CanAccessForm(M) && M.bpTier >= 30 && M.HasItem(/obj/Module/Grab_Absorb)
	
	UnlockForm(mob/M)
		if(!M) return
		if(CanEnterForm(M) && !(name in M.UnlockedTransformations))
			..()
	
	CanStackForm()
		return FALSE
	
	ApplyForm(mob/M)
		if(!M) return
		var/bpAdd = 1000000000
		M.transBPMult = 1.8
		M.transDurBonus = 2
		M.transResBonus = 2
		M.transRegenRate = 0.2
		M.disableKiRecovery = 1
		M.transBPAdd = Math.Max(bpAdd / M.transBPMult - M.cyber_bp, 0)
	
	DrainLoop()
		return
	
	MasteryLoop()
		return
	
	GetInfo()
		var/html = "<h3>[name]</h3><p><b>[desc]</b></p>"
		html += "<p>Must be an Android.  Must have Base Power Tier 30 or higher.</p>"
		html += "<p>Increase BP to 1'000'000'000 if below that amount.  Multiply BP by 1.8x.</p>"
		html += "<p>+2 Durability and Resistance.</p>"
		html += "<p>0.2x Health regeneration rate.  Ki recovery disabled.</p>"
		html += "<hr>"
		return html
transformation/Super_Majin
	name = "Super Majin"
	desc = "Draw upon the power of others; feed on it.  It will make you stronger."

	startupDelay = 30
	mastery = 100
	mastered = 1

	aura = 'Aura, Big.dmi'
	auraScaleX = 96
	auraScaleY = 128
	overlays = list(list('Electric_Mystic.dmi', rgb(0, 0, 0), 0, 0))

	CanAccessForm(mob/M)
		if(!M) return
		return ..() && M.Race == "Majin"  && M.Class != "Cyborg"
	
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
		var/bpAdd = Math.Max(250000000 / 2.0 - M.base_bp, 0)
		M.transBPAdd = bpAdd
		M.transBPMult = 2.0
		M.transPUCap = 1.6
		M.transSpdBonus = 3
		M.transAccBonus = 2
		if(M.bpTier >= 40)
			M.transBPMult += 0.4
			M.transBPAdd = Math.Max(300000000 / 2.4 - M.base_bp, 0)
		if(M.bpTier >= 45)
			M.transBPMult += 0.4
			M.transBPAdd = Math.Max(1000000000 / 2.8 - M.base_bp, 0)
		if(M.bpTier >= 50)
			M.transBPMult += 0.4
			M.transBPAdd = Math.Max(1250000000 / 3.2 - M.base_bp, 0)
	
	DrainLoop()
		return
	
	MasteryLoop()
		return
	
	GetInfo()
		var/html = "<h3>[name]</h3><p><b>[desc]</b></p>"
		html += "<p>Must be a Majin.  Must have Base Power Tier 30 or higher.</p>"
		html += "<p>Gained by meeting all requirements and absorbing another Majin who also meets them.</p>"
		html += "<p>Increase BP to 250'000'000 if below that amount.  Multiply BP by 2x.  Powerup Rate increased to 1.6x</p>"
		html += "<p>+3 Speed.  +2 Accuracy.</p>"
		html += "<p>Increase BP multiplier by +40% at tiers 40, 45, and 50.</p>"
		html += "<hr>"
		return html
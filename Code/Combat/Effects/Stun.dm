mob/proc/ApplyParalysis(duration = 15)
	AlterInputDisabled(1)
	spawn(duration)
		AlterInputDisabled(-1)
	ApplyStunEffects()

mob/proc/ApplyStunEffects()
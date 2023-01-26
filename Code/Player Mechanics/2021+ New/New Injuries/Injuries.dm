/*
Injuries are the first half of the new system designed to provide danger to combat while stopping short of death in most cases.

Injuries are a data object stored in a list on the injured mob.  It's important that they track all relevant data themselves, and are self-cleaning.
This means that once the duration is up, they are removed from the list.  Injuries should only ever have an effect when in the list, making removing them easier from
a code perspective. Receiving an exclusive injury before duration is up should simply reset the lifespan.

Remove_at is the in-game calendar date at which to remove the injury.
Lifespan is the number of in-game calendar dates which the injury lasts.
Likelihood is the base % chance a damaging attack will cause the injury. (0 to 1)
Threshold is the minimum damage an attack has to deal in order to have a chance at being applied. (0 or greater)
Buffer is the minimum time since the last injury received that must pass to have a chance at being applied. (Deciseconds)
Exclusive determines if multiple of the same type of injury can be received, thus stacking the effects.
*/

mob/var/list/injuries = list()
mob/var/tmp/lastInjury = 0

mob/Admin5/verb/TestInjury(max as num)
	max = Math.Max(max, 5)
	var/injury/I = new/injury/laceration
	src << "Injury name: [I.name]"
	src << "Injury threshold: [I.threshold]"
	src << "Injury buffer: [I.buffer]"
	src << "Injury likelihood: [I.likelihood]"
	src << "Last injury: [lastInjury]"
	src << "World time: [world.time]"
	var/t = injuries.len
	src << "start injure loop"
	var/c = 0
	for(var/i in 1 to max)
		TryInjure(I, 1, 10, src)
		if(t < injuries.len)
			c = i
			break
		sleep(world.tick_lag)
	src << "injure loop finished after [c]/[max] attempts"

mob/proc/TryInjure(injury/I, mod = 1, damage, mob/Source)
	if(!injuries || !islist(injuries)) injuries = list()
	if(CheckForInjuries())
		mod += Math.Floor(GetInjuryTypeCount(/injury/tortion) / 2)
	var/bonus = 0
	if(ismob(Source))
		if(Source.HasTrait("This Isn't Even My Final Form"))
			bonus += 5 * Source.GetTraitRank("This Isn't Even My Final Form")
		if(Source.HasTrait("Frost Lord Genome"))
			bonus += 2 * Math.Max(Source.effectiveBPTier - effectiveBPTier, 0)
		if(!Source.Fatal) return
	if(I && I.CanApply(mod, lastInjury, damage, bonus))
		lastInjury = world.time
		if(I.exclusive)
			for(var/injury/N in injuries)
				if(N ~= I)
					N.Apply()
					SendMsg("<span style='color:red'>Your [I.name] has relapsed.</span>", CHAT_IC)
					return
		I.Apply()
		injuries.Add(I)
		SendMsg("<span style='color:red'>You have received \a [I.name].</span>", CHAT_IC)

mob/proc/TryRemoveInjury(injury/I)
	if(I in injuries)
		if(I.remove_at < GetGlobalYear())
			injuries.Remove(I)
			SendMsg("<span style='color:green'>Your [I.name] has healed.</span>", CHAT_IC)

mob/proc/CheckForInjuries()
	if(istype(src, /mob/Body)) return 0
	if(istype(src, /mob/Enemy)) return 0
	if(!injuries || !islist(injuries))
		injuries = list()
		return 0
	for(var/injury/I in injuries)
		TryRemoveInjury(I)
	return injuries.len

mob/proc/GetInjuryTypeCount(injuryType)
	var/count = 0
	if(istext(injuryType))
		injuryType = text2path(injuryType)
	for(var/injury/O in injuries)
		if(O == injuryType)
			count++
	return count

injury
	var
		name = "template"
		remove_at
		lifespan = 1
		likelihood = 0.5
		threshold = 1
		buffer = 10
		exclusive = 0
	
	proc
		Apply()
			remove_at = GetGlobalYear() + lifespan
		
		CanApply(mod = 1, lastInjury, damage, bonus)
			return (lastInjury + buffer < world.time) && (damage >= threshold) && prob(likelihood * (mod + Math.Log(damage)) + bonus)
		
		operator~=(injury/I)
			return istype(I, /injury) && (istype(I, src.type) || I.name == src.name)
	
	// Increase bleed stack chance
	laceration
		name = "laceration"
		lifespan = 0.1
		likelihood = 1
		threshold = 0.75
		buffer = 50
	
	// Increased knockback chance & distance
	bruising
		name = "bruising"
		lifespan = 0.1
		likelihood = 2
		threshold = 0.55
		buffer = 50
	
	// More likely to get injured
	tortion
		name = "tortion"
		lifespan = 0.1
		likelihood = 1
		threshold = 1
		buffer = 50
	
	// Increases armor penalties
	burn
		name = "burn"
		lifespan = 1
		likelihood = 0.5
		threshold = 3
		buffer = 1200
	
	// Lower recovery rate for resource stats
	internal_bleeding
		name = "internal bleeding"
		lifespan = 0.3
		likelihood = 5
		threshold = 3
		buffer = 100
		exclusive = 1
	
	fracture
		lifespan = 0.5
		likelihood = 5
		threshold = 5
		buffer = 600
		exclusive = 1

		// Global speed reduction
		ribs
			name = "fractured ribs"

		// Attack speed reduction
		left_arm
			name = "fractured left arm"
		right_arm
			name = "fractured right arm"

		// Land speed reduction
		left_leg
			name = "fractured left leg"
		right_leg
			name = "fractured right leg"
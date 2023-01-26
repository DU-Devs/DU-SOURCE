var/list/raceGeneFilters = list("id_count", "race_id", "name", "tag", "type", "parent_type", "vars", "reproduction")
race
	var
		static/id_count = 0
		race_id
		name = "Human"
		hybridTitle = "Half"
		dominance = 1
		intellect = 1
		hidden_potential = 1
		battle_power = 1
		regenerative_capacity = 1
		ki_capacity = 1
		skill_mastery = 1
		physical_constitution = 1
		reconstitution = 0
		demonic = 0
		divine = 0
		amorphous = 0
		reproduction = REP_SEXUAL
		zenkai = 0
		super_cells = 0
		adaptation = 1
		rage_capacity = 1
		needs_air = 1
		power_cell = 0
	
	New()
		id_count++
		race_id = id_count
		..()
	
	proc
		Mutate(severity = 0.2)
			. = list()
			. = vars.Copy()
			. -= raceGeneFilters
			var/probability = 100 / length(.)
			if(reproduction == REP_ASEXUAL) probability *= 3
			for(var/i in .)
				if(vars[i] && prob(probability))
					vars[i] *= 1 + Math.Rand(-severity, severity)
			
			if(prob(5)) dominance *= 1 + Math.Rand(-severity, severity)

mob/var/race/race = new

mob/proc/Intellect()
	return race.intellect * Intelligence

mob/proc/Potential()
	return race.hidden_potential

mob/proc/BPMod()
	return race.battle_power

mob/proc/RegenRate()
	return regen * race.regenerative_capacity

mob/proc/RecovRate()
	return recov * race.ki_capacity

mob/proc/EnergyMod()
	return race.ki_capacity

mob/proc/Mastery()
	return race.skill_mastery

mob/proc/SCells()
	return race.super_cells

mob/proc/Durability()
	return GetStatMod("Dur") * race.physical_constitution

mob/proc/Resistance()
	return GetStatMod("Res") * race.physical_constitution

mob/proc/Demonic()
	return Demonic || race.demonic

mob/proc/Divine()
	return !Demonic() && race.divine

mob/proc/Amorphous()
	return race.amorphous

mob/proc/Reproduction()
	return race.reproduction

mob/proc/ZenkaiMod()
	return zenkai_mod * race.zenkai

mob/proc/AdaptMod()
	return leech_rate * race.adaptation

mob/proc/AngerMod()
	return Math.Min(100 * race.rage_capacity, 100)
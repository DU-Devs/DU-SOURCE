mob/var/race/parentA
mob/var/race/parentB

mob/proc/GetLineage(allow_mutation = 1)
	race ||= new
	parentA ||= race
	parentB ||= race
	
	if(ReproduceSexually(parentA, parentB))
		race = HybridRace(parentA, parentB)
		race ||= parentA
	else if(parentA.reproduction == REP_INFECTIOUS)
		race = InfectiousRace(parentA, parentB)
		race ||= parentA
	
	if(race.divine > race.demonic)
		race.demonic = 0
	else
		race.divine = 0
	
	if(allow_mutation) race.Mutate()

proc/ReproduceSexually(race/A, race/B)
	. = 0
	if(A.reproduction == REP_SEXUAL && (B.reproduction in list(REP_SEXUAL, REP_INDETERMINATE)))
		. = 1
	else if(B.reproduction == REP_SEXUAL && (A.reproduction in list(REP_SEXUAL, REP_INDETERMINATE)))
		. = 1

mob/proc/InfectiousRace(race/A, race/B)
	if(!A && !B) return
	if(B && !A) return B
	if(A && !B) return A
	var/race/C = new
	C.reproduction = B.reproduction

	for(var/i in (B.vars - raceGeneFilters))
		if(prob(15 + (A.dominance - B.dominance)))
			C.vars[i] = A.vars[i]
		else
			C.vars[i] = B.vars[i]
	
	C.name = "[A.hybridTitle] [B.name]"

	return C

mob/proc/HybridRace(race/A, race/B)
	if(!A && !B) return
	if(B && !A) return B
	if(A && !B) return A
	var/race/C = new
	C.reproduction = A.reproduction

	if(A.dominance > B.dominance)
		for(var/i in (A.vars - raceGeneFilters))
			if(!(A.vars[i]))
				C.vars[i] = A.vars[i]
				continue
			else if(A.vars[i] && !(B.vars[i]))
				C.vars[i] = A.vars[i] * 0.75
				continue
			else
				C.vars[i] = (A.vars[i] + B.vars[i]) / 2
	
		C.name = "[B.hybridTitle] [A.name]"

	else if(A.dominance == B.dominance)
		for(var/i in (A.vars - raceGeneFilters))
			C.vars[i] = (A.vars[i] + B.vars[i]) / 2
	
		C.name = "[B.hybridTitle] [A.name]"

	else
		for(var/i in (B.vars - raceGeneFilters))
			if(!(B.vars[i]))
				C.vars[i] = B.vars[i]
				continue
			else if(B.vars[i] && !(A.vars[i]))
				C.vars[i] = B.vars[i] * 0.75
				continue
			else
				C.vars[i] = (B.vars[i] + A.vars[i]) / 2
	
		C.name = "[A.hybridTitle] [B.name]"

	return C
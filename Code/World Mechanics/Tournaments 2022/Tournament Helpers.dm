proc/OngoingTournament()
	return ongoingTournament != null

mob/proc/IsTournamentFighter()
	return ongoingTournament && (src in ongoingTournament.fighters)

mob/proc/IsBracketFighter()
	return IsTournamentFighter() && ongoingTournament?.ongoingBracket && (src in ongoingTournament?.ongoingBracket?.fighters)

mob/proc/IsRoundFighter()
	var/isBracket = IsBracketFighter()
	var/isRoundExist = ongoingTournament?.ongoingBracket?.ongoingFight
	var/isFighterA = (src == ongoingTournament?.ongoingBracket?.ongoingFight?.fighterA)
	var/isFighterB = (src == ongoingTournament?.ongoingBracket?.ongoingFight?.fighterB)
	return isBracket && isRoundExist && (isFighterA || isFighterB)

mob/proc/tournament_override(fighters_can=1,show_message=1) //used to override attacks and such during a tournament
	if(!OngoingTournament()) return
	if(fighters_can && IsRoundFighter()) return
	for(var/obj/Fighter_Spot/fs in Fighter_Spots)
		if(getdist(src,fs) < 50 && fs.z == locz())
			if(show_message && ismob(src))
				src << "You can not do this near the tournament"
			if(Auto_Attack) AutoAttack()
			return 1

mob/proc/Find_Tourny_Chair()
	for(var/obj/Tournament_Chair/TC)
		if(TC.z && !(locate(/mob) in TC.loc))
			SafeTeleport(TC.loc, allowSameTick = 1)
			break

mob/proc/Tourny_Range(r=25)
	for(var/obj/Fighter_Spot/f in Fighter_Spots)
		if(f.z == locz() && getdist(f,src) <= r)
			return 1

proc/GetFighterLocations(list/L)
	if(!L) return
	var/list/Locations=new
	for(var/mob/P in L)
		Locations[P.displaykey] = P.loc
	return Locations

mob/Admin2/verb/Start_Tournament()
	set category="Admin"
	if(OngoingTournament())
		src<<"A tournament is in progress. There can only be 1 at a time"
		return
	var/Deathmatch
	switch(input(src,"Is this a deathmatch tournament?") in list("No","Yes"))
		if("Yes") Deathmatch=1
	var/skillTournament
	switch(input(src,"Is this a skill tournament?") in list("No","Yes"))
		if("Yes") skillTournament=1
	var/Prize=input(src,"How many resources for the prize? Any other prizes must be given manually. \
	Entering 0 makes the prize handled automatically.","Prize",0) as num
	Prize = Math.Max(Prize, 0)
	switch(alert(src, "Start a [skillTournament ? "skill " : ""]tournament[Deathmatch ? " (deathmatch)" : ""] with a prize of [Commas(Prize)]?", \
			"Confirm", "Yes", "No"))
		if("No") return
	ongoingTournament = new(Prize, skillTournament, Deathmatch)
mob/var/traitPoints = 0
mob/var/bonusTraitPoints = 0
mob/var/spentTraitPoints = 0
mob/var/list/traits = new/list
var/list/allTraits = new/list
var/list/LockedTraits = new/list
mob/var/traitVersion = 1
var/currentTraitVersion = 2

var/list/traitsToRemove = list()

mob/proc/CheckTraitVersion()
	if(src.traitVersion < currentTraitVersion)
		alert(src, "Traits have been updated.  Your points will be refunded, and traits reset.")
		ResetTraits()
		traitVersion = currentTraitVersion

mob/Admin4/verb/Manage_Traits()
	if(!LockedTraits) LockedTraits = new/list
	while(src)
		switch(alert(usr, "What would you like to do?", "Manage Traits", "Lock a Trait", "Unlock a Trait", "Cancel"))
			if("Cancel") break
			if("Lock a Trait")
				while(src)
					var/n = input(usr, "Lock which trait?") in list("Done") + (allTraits - LockedTraits)
					if(!n || n == "Done") break
					ToggleTraitLock(allTraits[n])
			if("Unlock a Trait")
				while(src)
					var/n = input(usr, "Unlock which trait?") in list("Done") + LockedTraits
					if(!n || n == "Done") break
					ToggleTraitLock(LockedTraits[n])
					ForceCheckUnlockableTrans()

proc/ForceCheckUnlockableTrans()
	for(var/mob/M in players)
		M.TryUnlockForm("Omega Yasai God")
		M.TryUnlockForm("Omega Yasai Blue")
		M.TryUnlockForm("Omega Yasai Blue Evolved")
		M.TryUnlockForm("Pump Up")
		M.TryUnlockForm("Titan")
		M.TryUnlockForm("Demon God")
		M.TryUnlockForm("Furious God")

mob/Admin5/verb/Check_Player_Traits(mob/M in players)
	for(var/i in M.traits)
		var/trait/T = M.GetTraitByName(i)
		if(!T) continue
		usr << "[T.name] | [T.rank]"

proc/ToggleTraitLock(n)
	if(!ispath(n)) return
	var/trait/T = new n
	if(T.name in LockedTraits)
		LockedTraits.Remove(T.name)
	else
		LockedTraits[T.name] += n

proc/IsTraitLocked(n)
	return n in LockedTraits

proc/FindTrait(name)
	return allTraits[name]

proc/GenerateTraits()
	var/list/L = typesof(/trait)
	L.Remove(/trait)
	L.Remove(/trait/racial)
	for(var/i in L)
		var/trait/T = new i
		if(!T || !istype(T,/trait)) continue
		allTraits[T.name] = i

mob/Admin4/verb/ResetPlayerTraits(m in list("All") + players)
	if(m == "All")
		for(var/mob/M in players)
			M.ResetTraits()
	var/mob/M = m
	if(!M || !ismob(M)) return
		M.ResetTraits()

mob/proc/ResetTraits(resetRacials = 0)
	var/list/raceTraits = GetRaceTraitValues()
	traits = new/list
	PopulateTraitsList()
	traitPoints += spentTraitPoints
	spentTraitPoints = 0
	GainTraitPoints()
	if(resetRacials) return
	if(!raceTraits || !raceTraits.len) return
	for(var/i in raceTraits)
		var/trait/T = GetTraitByName(i)
		if(!T) continue
		T.rank = raceTraits[i]

mob/proc/GetRaceTraitValues()
	var/list/L = new/list
	for(var/i in traits)
		var/trait/racial/T = traits[i]
		if(!T || !istype(T, /trait/racial)) continue
		if(Race == "Bio-Android" && !istype(T, /trait/racial/genetic)) continue
		L[i] = T.rank
	return L

mob/proc/GetRaceTraits()
	var/list/L = new/list
	for(var/i in traits)
		var/trait/racial/T = traits[i]
		if(!T || !istype(T, /trait/racial)) continue
		if(!T.IsValidRace(src)) continue
		L[i] = T
	return L

mob/proc/ChooseRaceTraits()
	var/list/traitOptions = GetRaceTraits()
	if(!traitOptions || !traitOptions.len) return
	var/picks = 0, maxPicks = 1
	if(Race == "Alien") maxPicks++
	if(Race == "Bio-Android")
		while(src)
			var/t = input(src, "Choose your primary genetic trait.") in traitOptions
			var/trait/racial/genetic/T = traitOptions[t]
			switch(alert(src, "Choose [T.name]?\n[T.desc]", "Gain Genetic Trait", "Yes", "No"))
				if("Yes")
					T.GainRank(src)
					T.primary = 1
					traitOptions.Remove(t)
					break
		while(src)
			var/t = input(src, "Choose your secondary genetic trait.") in traitOptions
			var/trait/racial/genetic/T = traitOptions[t]
			switch(alert(src, "Choose [T.name]?\n[T.desc]", "Gain Genetic Trait", "Yes", "No"))
				if("Yes")
					T.GainRank(src)
					traitOptions.Remove(t)
					break
	else
		while(src && picks < maxPicks)
			var/remaining = maxPicks - picks
			var/t = input(src, "You may choose a bonus trait unique to your race. [remaining] pick[remaining > 1 ? "s" : ""] remaining.") in list("None") + traitOptions
			if(t == "None") break
			var/trait/racial/T = traitOptions[t]
			if(!T) break
			switch(alert(src, "Choose [T.name]?\n[T.desc]", "Gain Racial Trait", "Yes", "No"))
				if("Yes")
					T.GainRank(src)
					traitOptions.Remove(t)
					picks++

mob/proc/PopulateTraitsList()
	if(!traits) traits = new/list
	for(var/i in allTraits)
		if(i in traits) continue
		var/t = allTraits[i]
		var/trait/T = new t
		if(!T || !istype(T,/trait)) continue
		if(T.name in traitsToRemove) continue
		traits[i] = T

mob/proc/GainTraits()
	while(src && client)
		var/list/availableTraits = GetAvailableTraits()
		if(!availableTraits || !availableTraits.len)
			alert("You can't gain any new traits at this time.")
			break
		var/inp = input("Rank up which trait? ([traitPoints] trait points remaining.)") in list("Done") + availableTraits
		if(!inp || inp == "Cancel") break
		var/trait/T = GetTraitByName(availableTraits[inp])
		if(!T) break
		switch(alert("Increase [T.name]? Rank [T.rank] -> [T.rank+1] (Cost: [T.cost] | Max: [T.maxRank])\n[T.desc]", "Rank Up Trait", "Yes", "No"))
			if("Yes") T.GainRank(src)

mob/proc/TryGainTrait(name)
	if(!name) return
	var/trait/T = GetTraitByName(name)
	if(!T) return
	T.GainRank(src)

mob/proc/GainTraitPoints()
	var/expectedPoints = Math.Floor(bpTier / 2) + bonusTraitPoints
	expectedPoints -= traitPoints + spentTraitPoints
	if(expectedPoints > 0) traitPoints += expectedPoints

mob/proc/GetAvailableTraits()
	var/list/L = new
	for(var/i in traits)
		var/trait/T = traits[i]
		if(!T || istype(T, /trait/racial) || istype(T, /trait/special)) continue
		if(T.CanGainRank(src)) L["[T.name] | Cost: [T.cost]"] = T.name
	return L

mob/proc/GetTraitRank(name)
	if(!name) return 0
	var/trait/T = GetTraitByName(name)
	if(!T) return 0
	return T.rank

mob/proc/GetTraitByName(name)
	if(!name || !traits || !islist(traits) || !traits.len) return
	return traits[name]

mob/proc/HasTrait(name)
	return GetTraitRank(name) > 0

mob/proc/ListTraits()
	var/html={"<html><body><body bgcolor="#000000"><font size=2><font color="#CCCCCC">
	<h1>This will show you all the traits in the game and detail their exact effects. They are listed in no particular order.</h1>
	"}
	for(var/n in allTraits)
		var/t = allTraits[n]
		var/trait/T = new t
		if(!T || !istype(T,/trait) || istype(T,/trait/racial)) continue
		html += T.GetInfo()
	src<<browse(html,"window=Trait Details;size=650x600")

trait
	var
		name
		desc
		rank = 0
		maxRank = 1
		cost = 1

	proc/operator~=(trait/T)
		return T.name == src.name
	
	proc/GainRank(mob/M)
		if(CanGainRank(M) && M.traitPoints >= cost)
			M.spentTraitPoints = cost
			M.traitPoints -= cost
			SpecialGainEvent(M)
			return rank++
	
	proc/SpecialGainEvent(mob/M)
		return
	
	proc/GetInfo()
		var/html = "<h2>--[name]--</h2>"
		if(desc) html += "<p>[desc] (Max: [maxRank] | Cost: [cost])</p>"
		html += ListReqs()
		html += "<hr>"
		return html

	proc/ListReqs()
		return ""
	
	proc/CanGainRank(mob/M)
		return !IsTraitLocked(name) && rank < maxRank
	
	Empowered_Fists
		name = "Empowered Fists"
		desc = "Your unarmed attacks become empowered with ki energy, like a short ranged blast.  While using no weapon, add your force mod to melee damage."

	Ki_Armor
		name = "Ki Armor"
		desc = "You are adept at protecting yourself with energy, even without particular focus.  While unarmored, add resistance to damage reduction for melee."

	Quickfire_Ki
		name = "Quickfire Ki"
		desc = "The candle that burns twice as bright burns half as long.  Double ki blast fire rate."

	Bloodied_Criticals
		name = "Bloodied Criticals"
		desc = "Increases melee crit chance by 5% per stack of bleed applied to the target."
	
	Knife_Fight
		name = "Knife to a Fist Fight"
		desc = "Ignore 25% of armor and increase bleed stack cap by 1 per rank, while using a bladed weapon."
		maxRank = 2
		cost = 2
	
	Power_Overwhelming
		name = "Power Overwhelming"
		desc = "You are accustomed to fighting those significantly weaker than yourself.  Double the bonuses gained from having a higher \
				Power Tier than your foe, but suffer double the consequences if you fight someone stronger than yourself."
		cost = 2
		
		CanGainRank(mob/M)
			return ..() && !M.HasTrait("Pacifist Tendencies")

		ListReqs()
			var/html = "May not have the trait 'Pacifist Tendencies'"
			return html
	
	Kill_You
		name = "What Doesn't Kill You"
		desc = "Increases power gained from zenkai boosts by 50% per rank."
		maxRank = 2

		CanGainRank(mob/M)
			return ..() && ((M.Race in list("Yasai", "Half-Yasai", "Demon", "Majin")) || M.HasTrait("Yasai Genome"))

		ListReqs()
			var/html = "Race must be one of the following: <ul>"
			html += "<li>Yasai</li>"
			html += "<li>Half-Yasai</li>"
			html += "<li>Bio-Android</li>"
			html += "<li>Demon</li>"
			html += "<li>Majin</li>"
			html += "</ul>"
			return html
	
	Escape_Artist
		name = "Escape Artist"
		desc = "You have acquired a myriad of methods for fleeing, making it easier to get away from danger. Each rank adds +2 to your power rolls made to escape."
		maxRank = 3

		CanGainRank(mob/M)
			return ..() && M.bpTier >= rank * 5

		ListReqs()
			var/html = "New ranks unlocked every 5 tiers, starting at tier 5."
			return html
	
	Pursuer
		name = "Pursuer"
		desc = "You have mastered the art of tracking, making it much harder to escape you. Each rank adds +1 to your power rolls made to pursue."
		maxRank = 4

		CanGainRank(mob/M)
			return ..() && M.bpTier >= rank * 5

		ListReqs()
			var/html = "New ranks unlocked every 5 tiers, starting at tier 5."
			return html
	
	Fervent_Regeneration
		name = "Fervent Regeneration"
		desc = "Increases natural regeneration rate by 5% per rank."
		maxRank = 10

		CanGainRank(mob/M)
			return ..() && ((M.Race in list("Majin", "Puranto")) || M.HasTrait("Puranto Genome"))

		ListReqs()
			var/html = "Race must be one of the following: <ul>"
			html += "<li>Bio-Android</li>"
			html += "<li>Majin</li>"
			html += "<li>Puranto</li>"
			html += "</ul>"
			return html
	
	Unparalleled_Ingenuity
		name = "Unparalleled Ingenuity"
		desc = "Decreases resource cost to create tech items by 10% per rank."
		maxRank = 5

		CanGainRank(mob/M)
			return ..() && ((M.Race in list("Human", "Tsujin", "Android")) || M.HasTrait("Human Genome"))

		ListReqs()
			var/html = "Race must be one of the following: <ul>"
			html += "<li>Human</li>"
			html += "<li>Bio-Android</li>"
			html += "<li>Tsujin</li>"
			html += "<li>Android</li>"
			html += "</ul>"
			return html
	
	Lone_Wolf
		name = "Lone Wolf"
		desc = "Increase base damage output and mitigation by 15% when not in a party."
		cost = 5

		CanGainRank(mob/M)
			return ..() && !(M.HasTrait("Pack Mentality") || M.HasTrait("Tenacious Teamwork"))

		ListReqs()
			var/html = "May not have any of the following traits: <ul>"
			html += "<li>Pack Mentality</li>"
			html += "<li>Tenacious Teamwork</li>"
			html += "</ul>"
			return html
	
	Pack_Mentality
		name = "Pack Mentality"
		desc = "Decrease penalties for group-based combat by 5%."
		cost = 5

		CanGainRank(mob/M)
			return ..() && !M.HasTrait("Lone Wolf")

		ListReqs()
			var/html = "May not have any of the following traits: <ul>"
			html += "<li>Lone Wolf</li>"
			html += "</ul>"
			return html
	
	Fulfilled_Potential
		name = "Fulfilled Potential"
		desc = "Decrease Battle Power while in a transformation by 10% per rank and increase Battle Power outside of transformations by 30% per rank."
		maxRank = 5

		CanGainRank(mob/M)
			return M.GetValidFormCount() > 0 && ..() && M.bpTier >= (rank + 1) * 5

		ListReqs()
			var/html = "Must have a base power tier of at least 5 x rank. (5, 10, 15, etc.)"
			return html
	
	Super_Slam
		name = "Super Slam"
		desc = "Melee attacks that successfully knockback opponents have a 50% chance to knock them back up to 4x further."

		CanGainRank(mob/M)
			return ..() && M.bpTier > 10
		
		ListReqs()
			var/html = "Must have a base power tier of 10 or higher."
			return html

	Tenacious_Teamwork
		name = "Tenacious Teamwork"
		desc = "When you are knocked out, a bonus of 100% health and energy is divided amongst conscious party members.\
				(Eg. 50% each if 2 other party members are conscious.)"

		CanGainRank(mob/M)
			return ..() && !M.HasTrait("Lone Wolf")

		ListReqs()
			var/html = "May not have any of the following traits: <ul>"
			html += "<li>Lone Wolf</li>"
			html += "</ul>"
			return html
	
	Xenophobe
		name = "Xenophobe"
		desc = "Increase base damage against opponents of a different race by 50%, but decrease attack gains from fighting them by 50% as well."

		CanGainRank(mob/M)
			return ..() && !M.HasTrait("Xenophile")

		ListReqs()
			var/html = "May not have any of the following traits: <ul>"
			html += "<li>Xenophile</li>"
			html += "</ul>"
			return html
	
	Xenophile
		name = "Xenophile"
		desc = "Increase attack gains from fighting opponents of a different race by 10%, but decrease damage dealt to them by 10% as well."

		CanGainRank(mob/M)
			return ..() && !M.HasTrait("Xenophobe")

		ListReqs()
			var/html = "May not have any of the following traits: <ul>"
			html += "<li>Xenophobe</li>"
			html += "</ul>"
			return html
	
	Pacifist
		name = "Pacifist Tendencies"
		desc = "Decrease damage dealt by 75%, but increase meditation gains by 50% and knowledge cap by 100%."
		cost = 2
		
		CanGainRank(mob/M)
			return ..() && !M.HasTrait("Power Overwhelming")

		ListReqs()
			var/html = "May not have the trait 'Power Overwhelming'"
			return html
	
	Not_Final_Form
		name = "This Isn't Even My Final Form"
		desc = "The more suppressed your power is (1st, 2nd, 3rd forms), the more likely you are to injure your opponent. (+5% per rank)"
		cost = 2
		maxRank = 5

		CanGainRank(mob/M)
			return ..() && M.Race == "Frost Lord"

		ListReqs()
			var/html = "Race must be Frost Lord."
			return html
	
	Iron_Will
		name = "Iron Will"
		desc = "You're hard-pressed to ever give up, finding hope in even the most dire of circumstances.  Decrease determination damage by 1 per rank. \
				Determination damage can not be lowered below 1 in this way."
		maxRank = 15

		CanGainRank(mob/M)
			return ..() && M.bpTier >= rank * 3

		ListReqs()
			var/html = "BP Tier must exceed current rank times 3."
			return html

	Emotional_Awakening
		name = "Emotional Awakening"
		desc = "You have finally achieved an understanding of the emotions that organic life cling to so strongly.  \
				You are now able to become enraged in combat, gaining all the boons and banes this brings. \
				(Enables anger and increases battle power by 50% while angered, but disables natural defensive bonuses unique to Droids.)"

		CanGainRank(mob/M)
			return ..() && M.Race == "Android"

		ListReqs()
			var/html = "Race must be Android."
			return html
	
	Chronofragility
		name = "Chrono-fragility"
		desc = "Your body can not handle the stress of the Time Chamber, causing you to age 10x faster while inside.  \
				However, you have acclimated to this, and now gain 3x faster in the normal world. \
				(Note: disabled while immortal.)"
		cost = 5

		CanGainRank(mob/M)
			return ..() && !M.Immortal
		
		ListReqs()
			var/html = "May not be immortal.  Effects cease to function if immortality is gained after this trait."
			return html
	
	Nerd_Rage
		name = "Nerd Rage"
		desc = "When angered, damage output and reduction are increased by 1 + half your Intelligence mod.  Anger mod increased by 20%."

		CanGainRank(mob/M)
			return ..() && M.Race == "Tsujin"
	
		SpecialGainEvent(mob/M)
			M.max_anger += 20

		ListReqs()
			var/html = "Race must be Tsujin."
			return html
	
	Ascendant_Training
		name = "Ascendant Training"
		desc = "Choose one stat to instantly gain a point in."
		maxRank = 4
		cost = 5

		SpecialGainEvent(mob/M)
			if(!M || !M.client) return
			switch(input(M, "Choose a stat to increase.") in list("Strength", "Durability", "Resistance", "Force", "Speed", "Accuracy", "Reflex"))
				if("Strength") M.Str++
				if("Durability") M.End++
				if("Resistance") M.Res++
				if("Force") M.Pow++
				if("Speed") M.Spd++
				if("Accuracy") M.Off++
				if("Reflex") M.Def++
	
	Custom_Focus
		name = "Custom Focus"
		desc = "You have gained the ability to change the focus of your skills and ki around.  Gain 1 customizable buff per rank."
		maxRank = 8

		SpecialGainEvent(mob/M)
			if(!M || !M.client) return
			M.contents.Add(new/obj/Skills/Buff)
	
	Monkey_Control
		name = "Great Ape Control"
		desc = "You have gained complete control over your faculties while in the Great Ape form."

		CanGainRank(mob/M)
			return ..() && M.Race in list("Yasai", "Half Yasai")

		SpecialGainEvent(mob/M)
			if(!M || !M.client) return
			M.Great_Ape_control = 1
		
		ListReqs()
			var/html = "Must be a Yasai or Half Yasai."
			return html
	
	Tail_Training
		name = "Tail Training"
		desc = "You have learned to handle the discomfort and sensitivity brought on by people grabbing your damn tail."
		cost = 0
		maxRank = 25

		CanGainRank(mob/M)
			return ..() && M.Race in list("Yasai", "Half Yasai") && M.bpTier >= (rank + 1) * 2

		SpecialGainEvent(mob/M)
			if(!M || !M.client) return
			M.tail_level = rank
		
		ListReqs()
			var/html = "Must be a Yasai or Half Yasai."
			return html

	racial
		cost = 0
		
		proc/IsValidRace(mob/M)
			return FALSE
		
		GainRank(mob/M)
			SpecialGainEvent(M)
			return rank++
		
		CanGainRank()
			return FALSE
	
	special
		GainRank(mob/M)
			if(!CanGainRank(M)) return
			rank++
			SpecialGainEvent(M)
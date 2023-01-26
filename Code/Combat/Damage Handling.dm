atom/var/tmp/lastDamagedBy
atom/var/tmp/lastDamagedAt
atom/proc/CalculateDamageOutput()
atom/proc/CalculateDamageModification(dmg = 1)
atom/proc/DealDamage(atom/target)
atom/proc/TakeDamage(dmg = 1, atom/source)
atom/proc/Destroy()

turf/wall/TakeDamage(dmg = 1, atom/source)
	var/cur_hp = Health
	Health -= dmg
	Health = Math.Clamp(Health, 0, 100 * defenseTier)
	if(Health <= 0)
		Destroy()
	else if(ismob(source) && (!istype(source, /mob/Enemy) && !source:drone_module))
		spawn(world.tick_lag) Health = cur_hp

obj/map_object/TakeDamage(dmg = 1, atom/source)
	var/cur_hp = Health
	Health -= dmg
	Health = Math.Clamp(Health, 0, 100 * defenseTier)
	if(Health <= 0)
		Destroy()
	else if(ismob(source) && (!istype(source, /mob/Enemy) && !source:drone_module))
		spawn(world.tick_lag) Health = cur_hp

mob/var/tmp/last_damaged_at = 0
mob/var/tmp/last_knockout_recovery = 0
mob/var/tmp/health_can_regain = 0
mob/TakeDamage(dmg = 1, atom/source, lethal = 0, can_regenerate = 1)
	last_damaged_at = world.time

	if(Mechanics.GetSettingValue("Health Rally"))
		health_can_regain = Health * 0.95
		spawn(50 * Mechanics.GetSettingValue("Health Rally Grace Multiplier"))
			health_can_regain = 0

	//check if source is a mob/player
	if(ismob(source))
		var/mob/M = source
		//lethality based on their lethal setting
		lethal ||= M.Fatal
		if(lethal && prob(5)) IncreaseDetermination(M.effectiveBPTier / 100)

	if(dmg) FallingText(num2text(dmg, 3), rgb(200, 0, 0))

	//modify hp and such
	IncreaseHealth(-dmg)
	
	if(Health <= 0)
		if(CanKO())
			KnockOut(source, dmg, lethal)
		else if(lethal && IsKO() && prob(100 - determination))
			TryDie(source, dmg, can_regenerate)

mob/proc/CanKO()
	return !IsKO()

mob/proc/IsKO()
	return KO

mob/proc/KnockOut(atom/source, dmg = 0, lethal = 0, can_anger = 1)
	if(ismob(source) && source != src && can_anger())
		var/mob/Z = source
		if(Z.client && !(Z.ckey in anger_reasons))
			can_anger = 1

		CheckTriggerUltraInstinct()
		if(ultra_instinct) return

		if(world.time > last_anger + Time.FromMinutes(5) || can_anger)
			var/ko_reason = Z
			if(!Z) ko_reason = "unknown reason"
			if(ismob(Z))
				ko_reason = Z.ckey
				if(!Z.ckey) ko_reason = "npc"
			Enrage(ko_reason)

			recent_ko_reasons.Insert(1, ko_reason)
			recent_ko_reasons.len = 3

			Zenkai()

			return
	if(ismob(source) && lethal)
		var/mob/M = source
		var/determinationDamage = Math.Max(M.effectiveBPTier - src.effectiveBPTier, 0) + (dmg * 0.2)
		if(M.HasTrait("Unrivaled Cruelty"))
			determinationDamage *= Math.Max(1 - (injuries && islist(injuries) ? injuries.len : 0) * 0.01, 0)
		if(M.HasTrait("You Will Die By My Hand"))
			determinationDamage *= 1 + (1 - M.Health / 100)
		if(last_knockout_recovery + Time.FromSeconds(30) > world.time)
			determinationDamage *= 5
		IncreaseDetermination(-determinationDamage)
	
	Zenkai()
	KO = 1
	if(HasTrait("Tenacious Teamwork") && PartySize() > 1) MiniAngerParty()
	Stop_Shadow_Sparring()
	if(ismob(source)) last_knocked_out_by_mob = source
	if(!IsTournamentFighter()&&client) Drop_dragonballs()
	ResetMobState()
	icon_state="KO"

	if(ismob(source))
		for(var/mob/m in player_view(center=src))
			var/t="[src] is knocked out by [source] ([source:displaykey])"
			m.SendMsg(t, CHAT_IC)
			m.ChatLog(t)
	else 
		for(var/mob/m in player_view(center=src))
			m.SendMsg("[src] is knocked out by [source]!", CHAT_IC)

	if(grabbedObject)
		for(var/mob/m in player_view(center=src))
			m.SendMsg("[src] is forced to release [grabbedObject]!", CHAT_IC)
		ReleaseGrab()

	knockout_timer = 800 / Clamp((regen**0.4),0.5,2)
	if(z==10) knockout_timer /= 6

mob/var/tmp/knockout_timer = 0
mob/proc/KnockoutWakeTick()
	knockout_timer -= 5
	if(knockout_timer <= 0)
		RegainConsciousness()

mob/proc/RegainConsciousness()
	last_knockout_recovery = world.time
	knockout_timer = 0
	Health = 1
	KO = 0
	icon_state = initial(icon_state)
	attacking = 0
	Ki = 1
	move = 1
	if(!istype(src,/mob/Enemy) && Poisoned && prob(100 - determination)) Death("???")
	for(var/mob/M in player_view(center=src))
		M.SendMsg("[src] regains consciousness.", CHAT_IC)

	if(client)
		sleep(20)
		if(prob(5) && can_anger())
			src.SendMsg("<font color=red>Being knocked out so much angers you...", CHAT_IC)
			Enrage(reason="being knocked out so much")
			FullHeal()
	else Frozen = 0

mob/DealDamage(atom/target, dmg_mod = 1, dmg_type = "Melee")
	var/dmg = CalculateDamageOutput(dmg_type)
	dmg = target.CalculateDamageModification(dmg, src, dmg_type)

	if(ismob(target))
		//arbitrary
		dmg *= 0.5

		//damage should always be at least 1
		dmg = Math.Max(dmg, 1)

	dmg *= dmg_mod

	if(dmg > 0)
		target.TakeDamage(dmg, src, Fatal)
		if(health_can_regain > Health)
			IncreaseHealth(GetHealthRally(dmg))

mob/proc/GetHealthRally(dmg = 1)
	var/pct_mod = 0.2, cap_mod = 1
	return Math.Clamp(dmg * pct_mod, 0.5 * cap_mod, 2 * cap_mod)

mob/CalculateDamageOutput(dmg_type = "Melee")
	var/dmg = (dmg_type == "Melee" ? GetStrDamage() : GetKiDamage())

	if(HasTrait("Mind the Heel"))
		dmg *= 1.2

	//if you're in a party, scale damage up/down based on the number of people in the fight
	if(PartySize() > 1) dmg /= (PartySize() * 0.7) / (HasTrait("Pack Mentality") ? 0.95 : 1)
	else if(HasTrait("Lone Wolf")) dmg *= 1.15

	if(Race == "Tsujin" && HasTrait("Nerd Rage") && anger > 100)
		dmg *= 1 + (Intelligence / 2)

	//check if pacifist, and decrease damage if so
	if(HasTrait("Pacifist Tendencies"))
		dmg *= 0.25
		
	if(HasTrait("Master of Manipulation"))
		dmg *= 0.95

	//damage should always be at least 1
	dmg = Math.Max(dmg, 1)
	
	return dmg

mob/CalculateDamageModification(dmg = 1, atom/attacker, dmg_type = "Melee")
	//increase damage to KOd srcs
	if(KO)
		dmg *= 10

	//increase damage to people trying to heal mid combat
	if(regenerator_obj)
		dmg *= 10

	//if facing same direction, we're backstabbing so deal more damage
	if(dir == attacker.dir)
		dmg *= 1.5

	//compare accuracy & reflex of attacker/defender, and modify damage based on the difference
	dmg *= Defense_damage_reduction(attacker,src)

	//increase damage against characters with regen over 1x
	dmg += regen - 1

	if(PartySize() > 1) dmg *= (PartySize() * 0.3) / (HasTrait("Pack Mentality") ? 0.95 : 1)

	if(Race == "Tsujin" && HasTrait("Nerd Rage") && anger > 100)
		dmg /= 1 + (Intelligence / 2)

	//do less damage against splits/sims you make
	if(istype(src, /mob/Splitform))
		if(attacker == Maker)
			dmg *= 0.2

	if(ismob(attacker))
		//if you have way more BP than src, increase damage by a lot. Trigger req set by server settings
		if(attacker:BP / BP > Limits.GetSettingValue("Absurd Damage Requirement"))
			dmg *= 20 + (attacker:BP / BP)

		//random chance to deal 50% more damage, is super low by default but can be increased/decreased by certain weapons
		if(prob(attacker:MeleeCritChance(src)))
			dmg *= 1.5

		//decrease damage based on src dura and armor.
		dmg -= (dmg_type == "Melee" ? GetMeleeReduction(attacker) : GetKiReduction(attacker))

		//take way more damage if busy grab absorbing someone's energy
		if(grabbedObject && strangling && GrabAbsorber()) dmg *= 1.3 

		//this multiplies, but it actually *decreases* damage if they're stunned
		if(stun_level || Frozen)
			dmg *= stun_damage_mod

		if(HasTrait("Lone Wolf") && PartySize() <= 1) dmg /= 1.15

		if(Race == "Android" && !HasTrait("Emotional Awakening")) dmg /= Mechanics.GetSettingValue("Android Damage Divider")

		if(HasTrait("Master of Manipulation"))
			dmg *= 1.05
			
		if(attacker:HasTrait("Xenophobe") && attacker:Race != Race)
			dmg *= 1.5
		
		if(attacker:HasTrait("Xenophile") && attacker:Race != Race)
			dmg *= 0.9
		
		if(attacker:HasTrait("Unrivaled Cruelty"))
			dmg *= 1 + (injuries && islist(injuries) ? injuries.len : 0) * 0.01

		//if you Majinized the person dealing damage, take none
		if(attacker:majinCurse && attacker:majinCurse.creator == key)
			dmg = 0
			
		//don't hurt party members
		if(attacker:IsPartyMember(src)) dmg = 0

	return dmg

mob/proc/GetMeleeReduction(mob/attacker)
	var/dmgReduction = GetStatMod("Dur")

	if(!attacker.GetEquippedWeapon() && attacker.HasTrait("Empowered Fists"))
		dmgReduction += GetStatMod("Res")
		dmgReduction /= 2
	if(!GetEquippedArmor() && HasTrait("Ki Armor"))
		dmgReduction += GetStatMod("Res")
	dmgReduction *= GetTierTankingMod(attacker, src)
	var/mod = 1
	if(attacker.IsWeaponBladed())
		mod -= attacker.GetTraitRank("Knife to a Fist Fight") * 0.25
	dmgReduction += GetArmorBonus() * mod

	return dmgReduction

mob/proc/GetKiReduction(mob/attacker)
	var/dmgReduction = GetStatMod("Res")
	dmgReduction *= GetTierTankingMod(attacker, src)
	dmgReduction += GetArmorBonus()

	return dmgReduction

mob/proc/GetKiDamage()
	var/dmg = Mechanics.GetSettingValue("Base Ki Damage")
	
	dmg += GetStatMod("For")

	return dmg

mob/proc/GetStrDamage()
	var/dmg = Mechanics.GetSettingValue("Base Melee Damage")
	
	dmg += GetStatMod("Str")

	//add ki damage if they have the appropriate trait and are unarmed
	if(!GetEquippedWeapon() && HasTrait("Empowered Fists"))
		dmg += GetStatMod("For")

	//add weapon damage
	dmg += GetWeaponDamage()

	//check if lunging, then apply damage bonus if so
	if(lunge_attacking)
		dmg *= 1.75

	return dmg
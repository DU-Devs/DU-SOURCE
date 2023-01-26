mob/var/trainState
mob/var/unusedZenkai = 0
mob/var/activeZenkai = 0

mob/proc/GetBaseBPGain(mod = 1)
	return ((bpTier * 0.05) + ((GetTierReq(bpTier + 1) - GetTierReq(bpTier)) / Time.FromHours(1))) * mod

mob/proc/TrainGain()
	// make sure the highest bp trackers are, at minimum, a 1
	highest_base_bp = Math.Max(highest_base_bp, 1)
	highest_base_and_hbtc_bp = Math.Max(highest_base_and_hbtc_bp, 1)
	highest_base_bp = Math.Max(highest_base_bp, 1)
	// disallow fusions from gaining
	if(IsFusion()) return
	// gains default to 0
	var/gain = 0
	// determine gain type, set gains accordingly
	switch(trainState)
		if("Self") 
			gain = GetBaseBPGain(1 + bp_mod)
		if("Shadow")
			gain = GetBaseBPGain(0.5 * bp_mod)
			if(Flying) gain *= 1.2
		if("Med")
			if(HasSkill(/obj/Skills/Utility/Meditate/Level2))
				gain = GetBaseBPGain(med_mod * (HasTrait("Pacifist Tendencies") ? 1.5 : 1))
			if(Knowledge < GetMaxKnowledge())
				KnowledgeTick()
	
	if(Race == "Android") gain = 0

	// this will handle the actual calculations and add bp
	GainBP(gain)

	// check to see who has the highest bp stats
	if(!IsFusion() && (base_bp + static_bp) > highest_base_and_hbtc_bp)
		highest_base_and_hbtc_bp = base_bp + static_bp
		highest_base_and_hbtc_bp_mob = src
	if(!IsFusion() && !player_with_highest_base_bp || base_bp > highest_base_bp)
		player_with_highest_base_bp = src
		highest_base_bp = base_bp
	if(!IsFusion() && !playerWithHighestTier || bpTier > highestBPTier)
		playerWithHighestTier = src
		highestBPTier = bpTier

var/highest_base_bp = 1
var/highestBPTier = 1
var/mob/playerWithHighestTier

mob/proc/GainBP(gain = 0)
	// don't waste time on the rest of this if gains are 0
	if(!gain) return 0
	// will be set to 1 if in HBTC, but defaults to 0
	var/allowHBTC = 0
	// 25% boost to gains if it is done while flying (mostly for shadow spar)
	if(Flying) gain *= 1.25
	// if they are the strongest player, they gain slower based on this setting
	if(player_with_highest_base_bp == src) gain /= Progression.GetSettingValue("Strongest Player Gain Divider")
	// if there's a soft cap enabled, slow their gains based on how close they are to that cap
	if(Progression.GetSettingValue("Tier Soft Cap") > 0)
		var/softCapMod = (GetTierReq(Progression.GetSettingValue("Tier Soft Cap")) / base_bp) - 1
		softCapMod = Math.Clamp(softCapMod, 0.000001, 1)
		gain *= softCapMod
	
	// add gravity, decline, and weights bonus
	gain *= GravityGainsMult() * decline_gains() * weights() * Progression.GetSettingValue("BP Gain Rate")

	// If gains are less than 0.1, set it to that
	gain = Math.Max(gain, 0.1)

	// gain rate set to per minute
	gain /= Time.FromMinutes(1)

	gain /= GlobalGainDividers()
	
	// gain 5% more BP from training per tier you gain, making the time to gain a new tier a little faster as you grow
	gain *= 1 + bpTier * 0.05
	
	if(Progression.GetSettingValue("Maximum Tier") > 0 && bpTier >= Progression.GetSettingValue("Maximum Tier"))
		gain = 0

	// If they have used a well, double their gains until they reach the threshold boost
	if(base_bp < wellBoostLimit)
		gain *= 2

	if(Race == "Android") gain = 0

	// add 20 to 40% of what they gain to their untapped potential
	unusedPotential += gain * Math.Rand(0.2, 0.4)

	// give them stored zenkai, which will be granted to them when they are knocked out or killed
	unusedZenkai += (gain * Math.Rand(0.05, 0.15)) * zenkai_mod * Progression.GetSettingValue("Zenkai Gain Rate") * (1 + (GetTraitRank("What Doesn't Kill You") * 0.5))

	// slowly absorb active zenkai into base bp
	activeZenkai -= Math.Rand(0.1, 0.5) * gain
	activeZenkai = Math.Max(activeZenkai, 0)

	if(Progression.GetSettingValue("Daily Tier Cap"))
		if(GetBPTier() >= GetPowerTierCap())
			gain = 0

	if(IsInHBTC() && CanGainHBTC())
		allowHBTC = 1
	else if(HasTrait("Chrono-fragility") && !Immortal)
		gain *= 3

	IncreaseBP(gain, allowHBTC)

	// gain from global leech
	GlobalLeechBP()

mob/var/static_bp = 0

mob/proc/IncreaseBP(amount = 0, allowHBTC = 0)
	if(Race == "Android")
		amount = 0
		base_bp = 1

	// boost gains if in time chamber
	if(allowHBTC)
		amount *= 10

	// slowly absorb static bp into your natural bp
	static_bp -= amount * 0.5
	static_bp = Math.Max(static_bp, 0)

	// add to their base bp
	base_bp += amount

	// update their EXP bar
	UpdateExpBar()

	// update their bp tier
	UpdateBPTier()

mob/proc/UpdateBPTier(vfx = 1)
	CheckNewTranses()
	var/oldTier = bpTier
	bpTier = GetBPTier()
	if(oldTier < bpTier) NewTierGained(vfx)
	UpdateExpBar()

mob/proc/CheckNewTranses()
	TryUnlockForm("Omega Yasai God")
	TryUnlockForm("Omega Yasai Blue")
	TryUnlockForm("Omega Yasai Blue Evolved")
	TryUnlockForm("Pump Up")
	TryUnlockForm("Pumped Final Form")
	TryUnlockForm("Overlord Form")
	TryUnlockForm("Titan")
	TryUnlockForm("Demon God")
	TryUnlockForm("Furious God")

mob/proc/GlobalLeechBP()
	if(!Progression.GetSettingValue("Global Leech Cap") || !Progression.GetSettingValue("Global Leech Rate")) return
	if(Progression.GetSettingValue("Maximum Tier") && bpTier >= Progression.GetSettingValue("Maximum Tier")) return
	if(Progression.GetSettingValue("Daily Tier Cap") && bpTier >= Progression.GetSettingValue("Daily Tier Cap")) return
	var/amountToGain = 0
	// If they're weaker than the strongest person, they should gain extra bp from leeching
	if(base_bp < highest_base_bp * (Progression.GetSettingValue("Global Leech Cap")/100))
		amountToGain += GetTierReq(Math.Floor(highestBPTier * (Progression.GetSettingValue("Global Leech Cap") / 100))) / (Time.FromHours(1) / Progression.GetSettingValue("Global Leech Rate"))
		amountToGain *= leech_rate

	amountToGain /= GlobalGainDividers()
	
	amountToGain = Math.Min(amountToGain, (highest_base_bp * (Progression.GetSettingValue("Global Leech Cap"))) - base_bp)
	amountToGain = Math.Max(amountToGain, 0)

	if(Race == "Android") amountToGain = 0

	IncreaseBP(amountToGain)

mob/proc/LeechOpponent(mob/target)
	if(!target || !target.client || target.IsFusion()) return
	var/amountToGain = 0

	// bp gain from leech
	if(bpTier < target.bpTier)
		amountToGain += GetTierReq(target.bpTier) / (Time.FromHours(1) / Progression.GetSettingValue("BP Leech Rate"))
	amountToGain *= leech_rate

	amountToGain /= GlobalGainDividers()
	
	if(client && target.client && target.client.computer_id == client.computer_id)
		amountToGain /= 5
	
	// don't let it exceed the target's bp
	amountToGain = Math.Min(amountToGain, target.base_bp - base_bp)
	// must be 0 or greater
	amountToGain = Math.Max(amountToGain, 0)

	if(Race == "Android") amountToGain = 0

	IncreaseBP(amountToGain)
	
	// leech some grav mastery
	if(gravity_mastered < target.gravity_mastered)
		var/gravGain = target.gravity_mastered / (Time.FromMinutes(10) / Progression.GetSettingValue("Gravity Mastery Rate"))
		gravGain *= leech_rate
		gravity_mastered = Math.Clamp(gravity_mastered, gravity_mastered + gravGain, target.gravity_mastered)

	// if they have a higher bp mod and are the same race, leech that too
	if(target.bp_mod_Leechable && target.Race == Race && target.bp_mod > bp_mod)
		bp_mod += target.bp_mod / 100 / 25
		if(bp_mod > target.bp_mod) bp_mod = target.bp_mod

	// get some ki bby
	if(target && target.max_ki / target.Eff / 1.25 > max_ki / Eff) max_ki += target.max_ki / 100 / 25

mob/proc/Zenkai(mod = 1)
	var/amountToGain = rand(0.2,0.8) * unusedZenkai
	unusedZenkai -= amountToGain
	amountToGain *= mod * zenkai_mod * Progression.GetSettingValue("Zenkai Gain Rate")
	activeZenkai += amountToGain
	if(prob(5)) TryUnlockForm("Super Perfect")

mob/proc/GlobalGainDividers()
	var/divider = 1
	if(Is_Cybernetic()) divider *= 4
	if(Safezone) divider *= 4
	return divider

//remove these later
mob/var/tmp/powerGainedToday = 0
mob/var/tmp/startingPowerTierToday = 1
mob/var/tmp/powerCapLastReset = -1000

mob/proc/GetPowerTierCap()
	var/daysSinceWipeStart = Math.Max(Math.Floor(Time.ToDays(Math.Floor(world.realtime - WipeStartDate))) + 1, 1)
	return Math.Max(Progression.GetSettingValue("Daily Tier Cap") * daysSinceWipeStart, 1)

mob/Admin4/verb/CheckPowerTierCap()
	usr << "Wipe Start Date: [time2text(WipeStartDate, "MMM DD YYYY")]"
	usr << "Current Date: [time2text(world.realtime, "MMM DD YYYY")]"
	usr << "Wipe has been going for [Math.Ceil(Time.ToDays(Math.Floor(world.realtime - WipeStartDate)))] days."
	usr << "Max base tier increases by [Progression.GetSettingValue("Daily Tier Cap")] per day."
	usr << "Players should cap at [GetPowerTierCap()] base power tier."

mob/Admin5/verb/Test_BP_Gains()
	var/t = input("How many hours of training?") as num|null
	if(!t) return
	t = Time.FromHours(t)
	var/gains = 0
	while(t)
		gains += GetBaseBPGain(1 + bp_mod)
		t -= 10
	usr << "Gained [gains > 1000 ? Commas(gains) : round(gains,0.01)] BP"

mob/verb/Check_Gains_Breakdown()
	set category = "Other"
	var/bpMod = bp_mod
	if(Race == "Android") bpMod = 0
	usr << "BP Mod: [bpMod]x"
	var/medMod = med_mod
	if(HasTrait("Pacifist Tendencies")) medMod *= 1.5
	usr << "Med Mod: [medMod]x"
	usr << "Gravity Mod: [GravityGainsMult()]x"
	if(Age > Decline)
		usr << "Decline Mod: [decline_gains()]x"
	usr << "Weight Mod: [weights()]x"
	if(Progression.GetSettingValue("Tier Soft Cap") > 0)
		var/softCapMod = (GetTierReq(Progression.GetSettingValue("Tier Soft Cap")) / base_bp) - 1
		softCapMod = Math.Clamp(softCapMod, 0.000001, 1)
		usr << "Soft Cap Gain Mod: [softCapMod]x"
	usr << "Server Gain Mod: [Progression.GetSettingValue("BP Gain Rate")]x"
	usr << "Global Leech Mod: [Progression.GetSettingValue("Global Leech Rate")]x -> [Progression.GetSettingValue("Global Leech Cap")]%"
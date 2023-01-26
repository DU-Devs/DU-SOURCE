mob/var/tmp/God_Fist_loop
mob/var/GodFistMastery = 0

mob/proc/GodFistDrain()
	var/masteryDrainMod = Math.ValueFromPercentInRange(0.5, 1, 100 - GodFistMastery)
	// check if they're in a transformation that disallows Kaioken or other buffing skills
	var/transformation/T = GetActiveForm()
	if(T && !T.CanStackForm() && GodFistMastery < 100)
		God_FistStop()
		God_Fist_Revert()
		src << "You can not use [src.name] with [T.name]!"
		return
	if(T) masteryDrainMod *= 0.75
	var/hp_drain = 0.3 * (GodFistMult()**1.6 - 1) / dur_share()**0.45 / regen**0.2
	var/ki_drain = 0.2 * (GodFistMult()**1.6 - 1) / Eff**0.2 / recov**0.3
	hp_drain *= masteryDrainMod
	ki_drain *= masteryDrainMod
	// half these cause we loop twice as often
	hp_drain *= 0.5
	ki_drain *= 0.5
	TakeDamage(-hp_drain, "God-Fist", 1)
	IncreaseKi((max_ki / 100) * -ki_drain)
	var/masteryGain = (GodFistMult() * 0.02) + 0.01
	if(IsInHBTC() && CanGainHBTC()) masteryGain *= Math.Rand(1.5, 10)
	GodFistMastery += masteryGain
	GodFistMastery = Math.Clamp(GodFistMastery, 0, 100)
	if(Ki <= 0)
		God_FistStop()
	Aura_Overlays()

mob/var
	God_Fist_level=0
	God_Fist_boost=100
	super_God_Fist

mob/proc/GodFistBoost()
	var/n = (GetEffectiveBase() + transBPAdd) * bp_mult * transBPMult
	n /= ((regen * 3 + recov) / 2) ** 0.3
	if(Is_Cybernetic()) n /= 2
	return n * (God_Fist_level * 0.7)

mob/proc/GodFistMult()
	return (GodFistBoost() + GetEffectiveBase()) / GetEffectiveBase()

mob/proc/God_FistStop()
	God_Fist_level=0
	Aura_Overlays(remove_only=1)

mob/var/tmp/obj/Skills/God_Fist/God_Fist_obj

obj/Skills/God_Fist
	teachable=1
	Skill=1
	Teach_Timer=5
	student_point_cost = 90
	Drain=10
	hotbar_type="Buff"
	can_hotbar=1
	clonable=0
	desc="This replaces normal power up. By hitting the power up key you will increase your level by 1. Each level gives more BP than the last but also drains health and energy. \
	To use the full abilities of this you \
	must have power control. More durability and regeneration decreases the health drain. More energy mod and recovery decreases the \
	energy drain. But only slightly. This also reduces flash step cost by half."

	New()
		spawn(3)
			var/mob/m=loc
			if(m && ismob(m)) m.God_Fist_obj=src

	verb/Hotbar_use()
		set hidden=1
		God_Fist_Toggle()

	verb/God_Fist_Toggle()
		set category="Other"
		if(usr.Redoing_Stats)
			usr<<"You can not use this while choosing stat mods"
			return
		if(!Using)
			if(usr.IsGreatApe())
				usr<<"You can not use [src] while in Great Ape form"
				return
			var/transformation/T = usr.GetActiveForm()
			if(T && !T.CanStackForm(usr))
				usr << "You can not use [src.name] with [T.name]!"
				return
			if(usr.ultra_instinct) return
			usr.God_Fist(src)
		else usr.God_Fist_Revert(src)

mob/proc/God_Fist(obj/Skills/God_Fist/K) if(!K.Using)
	K.Using=1
	if(powerup_obj) powerup_obj.Powerup=0
	BPpcnt=100
	src<<"<font color=red>You have now enabled [K]. Tap the power up (G) key to use it. It replaces normal powerup and is more powerful but drains both health and energy \
	to use instead of just energy."

mob/proc/God_Fist_Revert(obj/Skills/God_Fist/K)
	if(!K) K = locate(/obj/Skills/God_Fist) in src
	if(!K) return
	if(K.Using)
		God_FistStop()
		K.Using=0
		if(BPpcnt>100)
			BPpcnt=100
		src<<"You stop using [K]"

mob/proc/UsingGodFist()
	var/using = 0
	for(var/obj/Skills/God_Fist/K in src)
		using += K.Using
	return using > 0

mob/proc/Body_Parts(Amount=5,Range=1)
	var/list/Turfs=new
	for(var/turf/A in view(Range,src)) if(!A.density) Turfs+=A
	while(Amount&&Turfs)
		if(locate(/turf) in Turfs)
			var/obj/Body_Part/A=get_body_part(pick(Turfs))
			A.name="[src] chunk"
			Amount--
		else return

var/list/body_part_cache=new

proc/get_body_part(turf/t)
	var/obj/Body_Part/bp
	if(body_part_cache.len)
		bp=body_part_cache[1]
		body_part_cache-=bp
	else bp=new
	bp.SafeTeleport(t)
	Timed_Delete(bp,rand(2000,4000))
	return bp

obj/Body_Part
	icon='Body Parts.dmi'
	Savable=0
	Nukable=0
	Grabbable=0
	New()
		pixel_y+=rand(-16,16)
		pixel_x+=rand(-16,16)
		dir=pick(NORTH,SOUTH,EAST,WEST,NORTHEAST,SOUTHEAST,NORTHWEST,SOUTHWEST)
		//. = ..()
	Del()
		body_part_cache+=src
		SafeTeleport(null)
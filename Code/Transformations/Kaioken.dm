mob/var/tmp/God_Fist_loop

mob/proc/God_Fist_loop()
	set waitfor=0
	if(God_Fist_loop) return
	God_Fist_loop=1
	while(God_Fist_level)
		//this may not seem like a lot but check how God_Fist_boost is used
		var/God_Fist_max = 0.1 * highest_relative_base_bp
		if(God_Fist_boost<God_Fist_max)
			var/amount = highest_relative_base_bp / 800 // * God_Fist_level**0.2
			var/soft_cap = 1 - (God_Fist_boost / God_Fist_max)
			amount *= soft_cap
			God_Fist_boost += amount
			if(God_Fist_boost > God_Fist_max) God_Fist_boost = God_Fist_max

		var/hp_drain = 0.3 * (God_Fist_mult()**1.6 - 1) / dur_share()**0.3 / regen**0.2
		var/ki_drain = 0.2 * (God_Fist_mult()**1.6 - 1) / Eff**0.2 / recov**0.2
		if(ssj == 3)
			hp_drain *= 1.4
			ki_drain *= 1.2
		Health -= hp_drain
		Ki -= max_ki / 100 * ki_drain
		if(Health <= 0)
			God_FistStop()
			if(!Dead) Body_Parts()
			Death("God_Fist!")
		Aura_Overlays()
		sleep(10)

	God_Fist_loop=0

mob/var
	God_Fist_level=0
	God_Fist_boost=100
	super_God_Fist

mob/proc/God_Fist_bp()

	if(super_God_Fist) return 0

	var/n=God_Fist_boost * bp_mod * 0.65
	if(n>base_bp) n=base_bp
	//if(Ki>max_ki) n/=ki_mult()**0.8 //enable again if we go back to using ki_mult() instead of experimental thing
	if(cyber_bp) n/=2
	return n * God_Fist_level

var/super_God_Fist_mult = 1.7

mob/proc/God_Fist_mult()
	if(super_God_Fist) return super_God_Fist_mult

	var/n = (God_Fist_bp() + base_bp) / base_bp
	return n

mob/proc/God_FistStop()
	God_Fist_level=0
	super_God_Fist = 0
	Aura_Overlays(remove_only=1)

mob/var/tmp/obj/God_Fist/God_Fist_obj

obj/God_Fist
	//name = "God Fist"
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

	var/tmp/God_Fist_bugged=1 //remove

	New()
		spawn(3)
			var/mob/m=loc
			if(m && ismob(m)) m.God_Fist_obj=src

	verb/Hotbar_use()
		set hidden=1
		God_Fist_Toggle()

	verb/God_Fist_Toggle()
		set category="Other"
		//set name = "God Fist"
		if(usr.Redoing_Stats)
			usr<<"You can not use this while choosing stat mods"
			return
		for(var/obj/Limit_Breaker/lb in usr) if(lb.Using)
			usr<<"[src] can not be combined with limit breaker"
			return
		/*if(usr.buffed())
			usr<<"God_Fist can not be combined with buffs"
			return*/
		if(!Using)
			if(usr.IsGreatApe())
				usr<<"You can not use [src] while in Great Ape form"
				return
			if(usr.ultra_instinct) return
			usr.God_Fist(src)
		else usr.God_Fist_Revert(src)

mob/proc/God_Fist(obj/God_Fist/K) if(!K.Using)
	K.Using=1
	if(powerup_obj) powerup_obj.Powerup=0
	BPpcnt=100
	src<<"<font color=red>You have now enabled [K]. Tap the power up (G) key to use it. It replaces normal powerup and is more powerful but drains both health and energy \
	to use instead of just energy."

mob/proc/God_Fist_Revert(obj/God_Fist/K)
	if(!K) for(var/obj/God_Fist/KK in src) K=KK
	if(!K) return
	if(K.Using)
		God_FistStop()
		K.Using=0
		if(BPpcnt>100)
			BPpcnt=100
		src<<"You stop using [K]"

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
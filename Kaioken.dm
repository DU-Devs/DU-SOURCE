mob/var
	kaioken_level=0
	kaioken_boost=100
mob/proc/kaioken_bp()
	var/n=kaioken_boost*bp_mod*0.4
	if(n>base_bp) n=base_bp
	if(Ki>max_ki) n/=ki_mult()**0.8
	if(cyber_bp) n/=2
	return n*kaioken_level

obj/Kaioken
	teachable=1
	Skill=1
	Teach_Timer=5
	Drain=10
	hotbar_type="Buff"
	can_hotbar=1
	clonable=0
	desc="Kaioken replaces normal power up. By hitting the power up key you will increase your kaioken \
	level by 1. Each kaioken level gives more BP than the last but also drains health and energy. \
	To use the full abilities of Kaioken you \
	must have power control. More durability and regeneration decreases the health drain. More energy mod and recovery decreases the \
	energy drain. But only slightly."

	var/tmp/kaioken_bugged=1 //remove

	verb/Hotbar_use()
		set hidden=1
		Kaioken()
	verb/Kaioken()
		set category="Skills"
		if(usr.Redoing_Stats)
			usr<<"You can not use this while choosing stat mods"
			return
		for(var/obj/Limit_Breaker/lb in usr) if(lb.Using)
			usr<<"Kaioken can not be combined with limit breaker"
			return
		/*if(usr.buffed())
			usr<<"Kaioken can not be combined with buffs"
			return*/
		if(!Using)
			if(usr.Is_oozaru())
				usr<<"You can not use kaioken while in oozaru form"
				return
			usr.Kaioken(src)
		else usr.Kaioken_Revert(src)
mob/proc/Kaioken(obj/Kaioken/K) if(!K.Using)
	K.Using=1
	if(powerup_obj) powerup_obj.Powerup=0
	BPpcnt=100
	src<<"You are now using Kaioken"
mob/proc/Kaioken_Revert(obj/Kaioken/K)
	if(!K) for(var/obj/Kaioken/KK in src) K=KK
	if(!K) return
	if(K.Using)
		kaioken_level=0
		Aura_Overlays()
		K.Using=0
		if(BPpcnt>100)
			BPpcnt=100
			Aura_Overlays()
		src<<"You stop using Kaioken"
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
	bp.loc=t
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
		//..()
	Del()
		body_part_cache+=src
		loc=null
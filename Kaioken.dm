obj/Kaioken
	teachable=1
	Skill=1
	Teach_Timer=10
	Drain=10
	clonable=0
	desc="Kaioken is a special way of powering up. Normally powering up only drains energy. But if you have \
	Kaioken enabled, you will power up twice as fast but both health and energy will drain. It also gives you \
	x1.5 Speed, x2 Recovery, x2 Energy, x0.5 Regeneration. \
	To use the full abilities of Kaioken you must have power control."
	verb/Kaioken()
		set category="Skills"
		if(usr.Redoing_Stats)
			usr<<"You can not use this while choosing stat mods"
			return
		if(!Using) usr.Kaioken(src)
		else usr.Kaioken_Revert(src)
mob/proc/Kaioken(obj/Kaioken/K) if(!K.Using)
	K.Using=1
	Regeneration*=0.2
	Recovery*=2
	Spd*=1.5
	SpdMod*=1.5
	Max_Ki*=2
	Ki*=2
	Eff*=2
	Def*=0.5
	DefMod*=0.5
	src<<"You are now using Kaioken"
	Kaioken_Loop()
mob/proc/Kaioken_Revert(obj/Kaioken/K)
	if(!K) for(var/obj/Kaioken/KK in src) K=KK
	if(!K) return
	if(K.Using)
		K.Using=0
		Regeneration*=5
		Recovery*=0.5
		Spd/=1.5
		SpdMod/=1.5
		Max_Ki*=0.5
		Ki*=0.5
		Eff*=0.5
		Def*=2
		DefMod*=2
		if(BPpcnt>100)
			BPpcnt=100
			Aura_Overlays()
		src<<"You stop using Kaioken"
mob/proc/Body_Parts(Amount=10,Range=2)
	var/list/Turfs=new
	for(var/turf/A in view(Range,src)) if(!A.density) Turfs+=A
	while(Amount&&Turfs)
		if(locate(/turf) in Turfs)
			var/obj/Body_Part/A=new
			A.name="[src] chunk"
			A.loc=pick(Turfs)
			Amount-=1
		else return
obj/Body_Part
	icon='Body Parts.dmi'
	Savable=0
	Nukable=0
	Grabbable=0
	New()
		spawn(rand(2000,4000)) del(src)
		pixel_y+=rand(-16,16)
		pixel_x+=rand(-16,16)
		dir=pick(NORTH,SOUTH,EAST,WEST,NORTHEAST,SOUTHEAST,NORTHWEST,SOUTHWEST)
		//..()
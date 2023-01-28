/*
orb types:
	wall upgrade higher
	base defense orb, stronger turrets etc
	healing orb, heals you really fast including energy
	resource orb, make drills dig more
	tech orb, upgrade tech higher near it
*/

var/list/base_orbs = new
var/list/bp_orbs = new
var
	admin_allow_base_orbs = 1

	bp_orb_increase = 1.3
	bp_orb_range = 18

obj/Base_Orb
	density=1
	Savable=1
	layer = 6

	New()
		MakeImmovableIndestructable()
		Grabbable = 1
		CenterIcon(src)
		Bolted = 0 //fix initial bug from earlier version
		base_orbs += src
		. = ..()

	BP_Orb
		icon = 'Blue Orb 64x64.dmi'
		name = "Power Orb"

		New()
			bp_orbs += src
			desc = "Training within [bp_orb_range] tiles of this will give you [(bp_orb_increase - 1) * 100]% more BP gains. You can only be under \
			the effect of one orb of the same type at a time so being near multiple is still like being near one"
			. = ..()

mob/proc
	NearBPOrb()
		for(var/obj/o in bp_orbs) if(o.z && z == o.z && getdist(src,o) <= bp_orb_range) return 1

proc
	GenerateBPOrbs()
		set waitfor=0
		sleep(5 * 600)

		if(!admin_allow_base_orbs)
			//for(var/obj/o in base_orbs) del(o)
			return

		var/max_orbs = 4
		var/orbs = 0
		for(var/obj/o in bp_orbs) if(o.z) orbs++
		if(orbs >= max_orbs) return
		orbs = max_orbs -= orbs
		if(orbs <= 0) return
		for(var/v in 1 to orbs)
			var/obj/Base_Orb/BP_Orb/bo = new
			bo.SafeTeleport(GetRandomOrbLoc())

	GetRandomOrbLoc()
		var/turf/t
		var/area/a
		while(1)
			t = locate(rand(1,world.maxx), rand(1,world.maxy), rand(1,world.maxz))
			if(t) a = t.get_area()
			if(a && a.has_resources) return t

mob/Admin4/verb/Toggle_BP_Orbs()
	set category = "Admin"
	admin_allow_base_orbs = !admin_allow_base_orbs
	if(admin_allow_base_orbs) src << "Random Base Orbs are now allowed to spawn. This means the game will automatically track and spawn the \
		appropriate amount of Base Orbs, which are orbs on the map that provide a special perk to players near it, like more BP gains or higher wall upgrades, \
		to spawn"
	else
		src << "Random base orbs are now off"
		for(var/obj/o in base_orbs) del(o)
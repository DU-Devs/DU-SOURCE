/*
if you use ki in the mine it automatically ignites the gas causing a deadly explosion
meaning it is melee only

for every gas rock destroyed it raises the gas levels of the entire mine for like 10 minutes

add a mine that contains rarer metals to upgrade your walls higher than normal 1 time. guarded by environmental dangers and traps and maybe npcs
maybe its like a puzzle. you go in the cave and bust down rock walls to get deeper, make sure to use actual turfs, and they respawn. each one you bust
is a random chance to provide you with something, whether good or bad, like a gas explosion, or cave collapse. like mine sweeper maybe?
anyway there should probably be signs of the dangers, or patterns that reveal them
	if you bust a rock and some gas leaks out you know a nearby rock will cause a gas explosion
	if you bust it and water leaks, you know nearby one cause flood
	if rock shake, nearby rock cause massive cave collapse
	electricity in rock, if see electricity when busting, electric trap stuns you long time but not really kill, maybe KO to delay you
	for npc in rock, no warning maybe
the deeper in you go the more dangerous but better the rewards, its not deeper in the sense that its a linear tunnel,
but it is a massive area with a start and end point, and the start point is easier but less rewarding
	rocks at the more difficult end are more difficult to bust (need more bp)
	they more often have a trap tell, and if you set off the trap it is also more damaging
*/

turf/var/destroy_blast_anyway

turf/Mining_Rock
	Buildable = 0
	Health = 1
	density = 1
	icon = 'Turfs 3.dmi'
	icon_state = "cliff"
	takes_gradual_damage = 1
	opacity = 1
	destroy_blast_anyway = 1

	var
		rock_hits = 0

	Enter(atom/A)
		//if(Roof_Enter(A)) return . = ..()
		return 0

	Del()
		rock_hits++
		if(rock_hits >= 3)
			//Explosion_Graphics(src, rand(2,3))
			. = ..()
			MiningRockRespawn()

turf/proc
	MiningRockRespawn()
		set waitfor=0
		sleep(20 * 600)
		if(type == /turf/GroundSandDark)
			var/turf/Mining_Rock/mr = new(src)
			mr.name = mr.name //get rid of "unused" compile warning
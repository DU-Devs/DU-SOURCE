/*
the old npcs and their ai is woefully inferior and not good at all thats why we are making this

we can take many lessons from the trollbot ai

the npcs must be "boss capable". the code must factor in the existance of boss npcs
add ability to tame NPCs - using npc treats only science can make
coward npcs
aggressive & docile npcs
npcs make sounds, like bear roar etc
npcs that prefer to either be loners or in a pack
npcs with special attacks
Greensters self destruct and shoot acid
smooth pixel stepping
talking npcs
transforming npcs - all hp refilled too - grow bigger?

old npcs all swarm you at once and follow you in a single file line with no regard to crowding. put some anti crowding in there. like if they bump another npc, they
randomly decide to wander off like 10 steps in some random direction before trying to come at you again, etc

a special separate loop for the npcs tracking "where" the player is at a delay, perceptionDelay, they use that for all targeting purposes (chasing, shooting)

make sure when using viewable() to set seePastDenseObjs to 0. we dont want npcs targeting people through big rocks they cant get past etc
*/

mob/Enemy //misnomer - not all of them are enemies - some are just peaceful animals and such
	Bandit
mob/var/tmp/list/bleedStacks = new/list
mob/var/tmp/bleedLooping = 0
bleed_stack
	proc/Apply(mob/M)
		if(!M || !ismob(M)) return
		if(M && M.bleedStacks.len >= 5 + M.GetTraitRank("Knife to a Fist Fight")) return
		M.bleedStacks += src
		spawn(60)
			if(M) M.bleedStacks -= src

mob/proc/ApplyBleed(chance = 20)
	if(Race == "Android" || Race == "Majin") chance = 0
	if(Is_Cybernetic()) chance /= 2
	chance /= GetArmorBleedDivider()
	if(CheckForInjuries())
		chance += GetInjuryTypeCount(/injury/laceration)
	if(prob(chance))
		var/bleed_stack/B = new
		B.Apply(src)
	
mob/proc/BleedDamage()
	set background = TRUE
	set waitfor = FALSE
	if(bleedLooping) return
	bleedLooping = 1
	while(src && src.bleedStacks.len > 0)
		TakeDamage(bleedStacks.len * 0.2)
		sleep(Time.FromSeconds(1))
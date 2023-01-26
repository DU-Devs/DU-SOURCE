projectile/melee
	distance = 16
	speed = 32
	injuryTypes = list(/injury/fracture/ribs, /injury/fracture/left_arm, /injury/fracture/right_arm, /injury/fracture/left_leg, /injury/fracture/right_leg,\
						/injury/laceration, /injury/bruising, /injury/tortion, /injury/internal_bleeding)
	var
		can_combo = 0
	
	TryKnockback(mob/target, dmg = 1)
		var/knockback = creator.GetMeleeKnockbackDist(target)
		if(knockback)
			if(prob(33)) Make_Shockwave(target, sw_icon_size=pick(128,256))
			if(target) creator.Melee_Shockwave_Repel(target)
			target.Knockback(creator, knockback, from_lunge=0)
			if(can_combo) creator.combo_teleport(target)

#ifdef DEBUG
mob/verb/TestPunch()
	set category = "TEST"
	var/projectile/melee/P = new(usr, usr.dir, "punch", Distance = 24, Speed = 4)
	P.icon = 'Blast - 11.dmi'
	P.Fire()

mob/verb/TestFlurry()
	set category = "TEST"
	for(var/i in 1 to 6)
		var/projectile/melee/P = new(usr, usr.dir, "punch", Distance = 24, Speed = 4, Spread = 12)
		P.icon = 'Blast - 11.dmi'
		P.dmg_mod = 0.33
		P.Fire()
#endif
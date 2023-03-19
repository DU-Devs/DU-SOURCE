mob/var
	bleed_damage = 0
	tmp
		bleed_loop
		last_bleed_apply = 0 //world.time

mob/proc
	BleedDamage(n = 0)
		last_bleed_apply = world.time
		bleed_damage = n
		BleedLoop()

	BleedLoop()
		set waitfor=0
		if(bleed_loop) return
		bleed_loop=1

		while(bleed_damage > 0)
			if(bleed_damage > 300) bleed_damage = 300
			var/dmg = 1 + (bleed_damage / 50)
			if(dmg < 1) dmg = 1
			if(dmg > 8) dmg = 8 //can only bleed out so fast
			if(KO) dmg *= 3
			if(Class == "Legendary Yasai") dmg *= 1 //they said remove it, but it was 1.5
			if(dmg > bleed_damage) dmg = bleed_damage
			bleed_damage -= dmg
			Health -= dmg
			if(Health <= 0) KO("low health")

			sleep(10)

			if(bleed_damage <= 0)
				bleed_damage = 0
				break
			if(world.time - last_bleed_apply > 100 * 10)
				bleed_damage = 0
				break

		bleed_loop=0
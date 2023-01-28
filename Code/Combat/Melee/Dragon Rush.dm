/*
winning the dragon rush currently does not damage the loser
*/

var
	PRESSED_WRONG_KEY = 97362
	CORRECT_PRESS = 97222
	DRAGON_RUSH = 97000

mob
	var
		tmp
			in_dragon_rush
	proc
		CheckLungeDragonRush(mob/a, mob/b)
			if(!allow_dragon_rush) return
			if(!a || !b) return
			if(a.in_dragon_rush || b.in_dragon_rush) return //if their lunge hit you first and the dragon rush has already begun dont stack another one on it
			if(!b.lunge_attacking) return //the lunges did not collide
			StartDragonRush(a,b)

		DragonRushAnimationLoop()
			set waitfor=0
			while(in_dragon_rush)
				flick("Attack",src)
				if(prob(60)) Make_Shockwave(src, sw_icon_size = pick(128,256))
				sleep(world.tick_lag * rand(2,3))

		DragonRushSFXLoop()
			set waitfor=0
			while(in_dragon_rush)
				player_view(20,src) << sound(pick('meleemiss1.ogg','meleemiss2.ogg','meleemiss3.ogg'), volume = 20)
				sleep(world.tick_lag * rand(2,3))

		EndDragonRush()
			attacking = 0
			in_dragon_rush = 0
			lunge_attacking = 0

		StartDragonRushVars()
			in_dragon_rush = 1
			attacking = DRAGON_RUSH
			lunge_attacking = 0
			DragonRushAnimationLoop()

		PressedTowardEnemy(mob/m)
			if(!m) return
			if(WrongPressTowardEnemy(m)) return PRESSED_WRONG_KEY
			switch(get_dir(src,m))
				if(NORTH) if(abs(north - world.time) < world.tick_lag * 2) return CORRECT_PRESS
				if(SOUTH) if(abs(south - world.time) < world.tick_lag * 2) return CORRECT_PRESS
				if(EAST) if(abs(east - world.time) < world.tick_lag * 2) return CORRECT_PRESS
				if(WEST) if(abs(west - world.time) < world.tick_lag * 2) return CORRECT_PRESS

		WrongPressTowardEnemy(mob/m)
			if(!m) return
			if(abs(north - world.time) < world.tick_lag * 2 && get_dir(src,m) != NORTH) return 1
			if(abs(south - world.time) < world.tick_lag * 2 && get_dir(src,m) != SOUTH) return 1
			if(abs(east - world.time) < world.tick_lag * 2 && get_dir(src,m) != EAST) return 1
			if(abs(west - world.time) < world.tick_lag * 2 && get_dir(src,m) != WEST) return 1

		NewDragonRushLoc(mob/m)
			if(!m) return
			if(m.z != z) return
			if(!viewable(src,m,30)) return

			dir = get_dir(src,m)
			m.dir = get_dir(m,src)

			var/turf/t
			var/tries = 0
			while(!t && tries < 10)
				tries++
				t = FindNewDragonRushLoc()
				if(!IsValidDragonRushLoc(t)) t = null
			if(!t) return
			SafeTeleport(t)
			var/list/sides = list(get_step(src,NORTH), get_step(src,SOUTH), get_step(src,EAST), get_step(src,WEST))
			for(var/v in sides) if(!v || v == null) sides -= v
			if(sides.len == 0) return
			sides = shuffle(sides)
			for(var/turf/t2 in sides)
				if(IsValidDragonRushLoc(t2))
					m.SafeTeleport(t2)
					break

		FindNewDragonRushLoc()
			var/turf/t = locate(x + rand(-9,9),y + rand(-8,8),z)
			return t

		DragonRushPointsToWin(mob/b)
			var/mult = (BP / b.BP)**0.25 * (Spd / b.Spd)**0.25 * (Off / b.Def)**0.25
			if(Class == "Legendary Yasai") mult *= 0.5
			return ToOne(6 / mult)

		IsValidDragonRushLoc(turf/t)
			if(!t || t.density || !viewable(src,t)) return
			for(var/obj/o in t) if(istype(o,/obj/Turfs/Door)) return
			return 1

proc
	StartDragonRush(mob/a, mob/b)
		set waitfor=0
		if(!a || !b) return
		a.StartDragonRushVars()
		b.StartDragonRushVars()
		a.DragonRushSFXLoop()

		DragonRushLoop(a,b)

		if(a) a.EndDragonRush()
		if(b) b.EndDragonRush()

	DragonRushLoop(mob/a,mob/b)
		if(!a || !b) return
		var/mob/winner
		var/mob/loser
		var/warps = 0
		var/max_warps = 24
		var/a_points = 0
		var/b_points = 0
		var/time_elapsed = 0
		var/max_time_elapsed = 10
		var/go_to_next_warp = 1
		while(1)
			if(!a || !b) return
			a.attacking = DRAGON_RUSH
			b.attacking = DRAGON_RUSH
			a.dir = get_dir(a,b)
			b.dir = get_dir(b,a)

			//no real reason for this, just guessing
			a.ResetStepXY()
			b.ResetStepXY()

			if(go_to_next_warp)
				sleep(4)
				go_to_next_warp = 0
				time_elapsed = 0
				player_view(20,a) << sound('teleport.ogg',volume = 20)
				a.AfterImage(25)
				b.AfterImage(25)
				a.NewDragonRushLoc(b)
				if(get_dist(a,b) > 1) return //dragon rush warp to new loc failed
				warps++

			var/a_press = a.PressedTowardEnemy(b)
			var/b_press = b.PressedTowardEnemy(a)
			if(a_press == CORRECT_PRESS)
				a_points++
				go_to_next_warp = 1
			else if(b_press == CORRECT_PRESS)
				b_points++
				go_to_next_warp = 1
			if(a_press == PRESSED_WRONG_KEY) a_points -= 2
			if(b_press == PRESSED_WRONG_KEY) b_points -= 2

			if(warps >= max_warps) break

			if(a_points - b_points > a.DragonRushPointsToWin(b)) break
			if(b_points - a_points > b.DragonRushPointsToWin(a)) break
			if(a.KO || b.KO) break

			var/delay = world.tick_lag
			time_elapsed += delay
			if(time_elapsed >= max_time_elapsed)
				go_to_next_warp = 1
				continue
			sleep(delay)

		winner = GetDragonRushWinner(a,b,a_points,b_points)
		if(winner == a) loser = b
		else loser = a

		if(!winner || !loser) return
		player_view(20,winner) << sound('strongpunch.ogg',volume = 20)

		//so the winner can move again and the dragon rush animations and shockwaves stop playing
		winner.in_dragon_rush = 0
		loser.in_dragon_rush = 0

		var/dr_dmg = winner.get_melee_damage(loser) * 1 //was x7 but i want it to be a setup for a finisher not a finisher of itself
		var/base_stun = 80
		var/stun = base_stun * (winner.BP / loser.BP)**bp_exponent * (winner.Str / loser.Res)**0.4
		stun = Clamp(stun, 0, base_stun * 2)

		if(loser.Class == "Legendary Yasai")
			base_stun *= 2
			dr_dmg *= 2

		loser.TakeDamage(dr_dmg)
		loser.Knockback(winner, 20)
		loser.ApplyStun(time = stun, no_immunity = 1, stun_power = 10)
		winner.AfterImage(25)
		winner.SafeTeleport(loser.loc)
		flick('Zanzoken.dmi',winner)
		player_view(20,winner) << sound('teleport.ogg',volume = 20)
		step_away(winner,loser)
		winner.dir = get_dir(winner,loser)

	GetDragonRushWinner(mob/a,mob/b,a_points = 0,b_points = 0)
		if(a.KO) return b
		if(b.KO) return a

		if(a_points > b_points) return a
		else if(b_points > a_points) return b
		return pick(a,b)
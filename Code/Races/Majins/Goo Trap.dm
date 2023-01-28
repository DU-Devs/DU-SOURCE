/*
if someone knockbacks you the goo gets knocked off you and you are saved
*/

var
	goo_trap_bp_mult = 0.73

mob/var
	tmp
		cant_logout_until_time = 0 //world.time
		obj/Majin_Goo/goo_trap_obj

obj/Goo_Trap
	desc = "You can lay a pile of goo on the map that will try to absorb anyone who gets near it who is weak enough. After absorbing \
	them it will go back to where you originally placed it and do it again until someone destroys it or you make a new one, or you log out."
	repeat_macro = 0
	can_hotbar = 1
	hotbar_type = "Ability"

	verb
		Goo_Trap()
			//set category = "Skills"
			usr.GooTrap()

		Hotbar_use()
			set hidden = 1
			set waitfor = 0
			usr.GooTrap()

mob/proc
	GooTrap()
		if(DeleteMajinGoo())
			src << "<font color=cyan>Your goo is now retracted"
			return
		if(!CanMajinGoo()) return
		src << "<font color=cyan>Goo has been placed where you are standing. It will lurk invisibly until someone weak enough to absorb gets near it \
		then it will attack them"
		var/obj/Majin_Goo/g = new(base_loc())
		g.reallyDelete = 1 //idk it just doesnt work right if we dont let it truly delete
		g.goo_speed = GetGooSpeed()
		g.goo_bp = GetGooBP()
		g.majins_key = key
		g.goo_loc = g.loc
		g.name = "[src]'s Special Goo"
		g.goo_maker = src
		goo_trap_obj = g
		if(base_icon_color) g.icon += base_icon_color

	CanMajinGoo()
		if(KO) return
		if(MajinGooExists()) return
		return 1

	MajinGooExists()
		for(var/obj/Majin_Goo/g in majin_goos) if(key == g.majins_key) return 1

	DeleteMajinGoo()
		if(!key) return
		for(var/obj/Majin_Goo/g in majin_goos) if(key == g.majins_key)
			g.majins_key = null
			g.loc = null
			goo_trap_obj = null
			g.DeleteNoWait()
			return 1

	GetGooSpeed()
		var/speed = 1 + Speed_delay_mult(1) * 0.2
		return speed

	GetGooBP()
		var/old_powerup_percent = BPpcnt
		BPpcnt = 100
		UpdateBP()
		var/bp = BP * 0.7
		BPpcnt = old_powerup_percent
		UpdateBP()
		return bp

var/list/majin_goos = new

obj/Majin_Goo
	icon = 'Majin1.dmi'
	icon_state = "Regenerate 2"
	density = 0
	layer = 7 //arbitrary

	var
		goo_speed = 1
		goo_bp = 1
		majins_key //key of the user
		goo_hiding
		tmp
			goo_loc
			mob/goo_sticky_target
			mob/goo_maker
			goo_ai_count = 0
			goo_last_absorbed_key

	New()
		majin_goos += src
		GooAI()
		. = ..()

	Del()
		for(var/mob/m in players) if(m.key == majins_key)
			m << "<font size=3><font color=cyan>Your goo was destroyed. You can make another one now."
		majin_goos -= src
		majins_key = null
		loc = null
		. = ..()

	proc
		GooAI()
			set waitfor=0
			sleep(5)
			if(!majins_key) return
			goo_ai_count++
			goo_sticky_target = null
			GooHide()
			GooWaitForTarget()

		GooHide()
			goo_hiding = 1
			goo_sticky_target = null
			var/delay = TickMult(20 * goo_speed)
			animate(src, transform = matrix() * 0.01, time = delay)
			sleep(delay)
			loc = goo_loc
			Health = 1.#INF

		GooUnhide()
			Health = 1
			goo_hiding = 0
			var/delay = TickMult(24 * goo_speed)
			animate(src, transform = matrix() * 1.2, time = delay)
			sleep(delay)

		GooWaitForTarget()
			var/ai_count = goo_ai_count
			sleep(40)
			while(src && ai_count == goo_ai_count)
				var/mob/m = FindGooTarget()
				if(m) GooAttackTarget(m)
				sleep(80)

		FindGooTarget()
			for(var/mob/m in player_view(15,src))
				if(IsViableGooTarget(m))
					return m

		IsViableGooTarget(mob/m)
			if(!m || !m.client || m.key == majins_key || m.Dead || m.key == goo_last_absorbed_key) return
			if(alignment_on && both_good(goo_maker, m)) return
			if(m.InTournament()) return
			if(goo_maker && !goo_maker.CanGooAbsorb(m)) return
			if(m.KO) return 1
			if(GooStrongerThanTarget(m)) return 1

		GooStrongerThanTarget(mob/m)
			if(m.BP < goo_bp) return 1

		GooAttackTarget(mob/m)
			if(goo_hiding) GooUnhide()
			while(m && loc != m.base_loc() && viewable(src, m, 30))
				var/delay = TickMult(goo_speed * 2)
				step_towards(src, m)
				if(loc == m.base_loc()) break
				else sleep(delay)

			if(m && loc == m.base_loc())
				var/delay = TickMult(6.5)
				animate(src, transform = matrix() * 2, time = delay)
				GooStickOnTarget(m)
				m << "<font color=cyan><font size=3>[src] has stuck on you! Raise your BP to resist!"
				m.cant_logout_until_time = world.time + 200
				GooAbsorbTarget(m)
			else GooAI()

		GooStickOnTarget(mob/m)
			set waitfor=0
			goo_sticky_target = m
			while(goo_sticky_target)
				loc = goo_sticky_target.loc
				sleep(world.tick_lag)

		GooAbsorbTarget(mob/m)
			for(var/v in 1 to 9)
				if(m && (GooStrongerThanTarget(m) || m.KO)) sleep(10)
				else
					GooAI()
					return
			goo_sticky_target = null
			if(m && goo_maker)
				goo_last_absorbed_key = m.key
				if(goo_maker.CanGooAbsorb(m))
					goo_maker.Absorb(m, force_absorb = 1)
			GooAI()

mob/proc/CanGooAbsorb(mob/M)
	if(!M||!ismob(M)) return
	if(M.Dead)
		src<<"Dead people can not be absorbed"
		return
	if(M.Final_Realm())
		src<<"You can not absorb in the final realm"
		return
	if(locate(/area/Prison) in range(0,src))
		src<<"You can not absorb in the prison"
		return
	if(M.Safezone)
		src<<"You can not do this in a safezone"
		return
	if(tournament_override(fighters_can=0)) return
	if(istype(M,/mob/Body))
		src<<"Bodies can not be absorbed"
		return
	if(M.client&&client&&M.client.address==client.address)
		src<<"Alts can not be absorbed"
		return
	if(alignment_on&&both_good(src,M))
		src<<"You can not absorb a fellow good person"
		return
	if(Same_league_cant_kill(src,M))
		src<<"You can not absorb someone in the same league as you"
		return
	if(M.spam_killed)
		src<<"You can not absorb [M] because they are death immune"
		return
	return 1
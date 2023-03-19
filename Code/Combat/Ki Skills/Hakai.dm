var
	hakai_cooldown = 300
	hakai_bp_advantage_needed = 2.2
	hakai_wipes_character = 0

mob/var/tmp
	cant_move_due_to_hakai = 0
	last_hakai_use = 0

mob/proc
	CanUseHakai()
		if(beaming || charging_beam)
			src << "You can not use this and beam at the same time"
			return
		if(tournament_override(fighters_can=0)) return
		if(KO || attacking) return
		if(world.time - last_hakai_use < hakai_cooldown)
			src << "You can not use this again yet"
			return
		return 1

obj/Hakai
	teachable=1
	Skill=1
	hotbar_type="Ability"
	can_hotbar=1
	Teach_Timer = 5
	student_point_cost = 157
	Cost_To_Learn = 0
	desc = "Using this on someone will trap them in place and kill them within seconds so long as they have significantly less BP than you. No other stat matters. They have a few seconds to \
	struggle against it if they power up or otherwise raise their BP to a level that you can no longer Hakai them"

	verb/Hotbar_use()
		set hidden=1
		Hakai()

	verb/Hakai()
		//set category="Skills"

		if(!usr.CanUseHakai()) return
		var/mob/m = usr.FindHakaiTarget()
		if(!m)
			usr << "A target must be in front of you within a short distance"
			return
		usr.Say("HAKAI!!!")
		usr.attacking = 3
		usr.cant_move_due_to_hakai++

		m.SetLastAttackedTime(usr)

		usr.BeginHakai(m)

		usr.Ki *= 0.75

		usr.attacking = 0
		usr.cant_move_due_to_hakai--

mob/proc
	BeginHakai(mob/m)
		Make_Shockwave(m, sw_icon_size=256)
		var/previous_health = m.Health
		m.cant_move_due_to_hakai++
		var/hakai_failed
		HakaiOverlay(m, 50)
		for(var/v in 1 to 17)
			if(!m || !StrongEnoughToHakai(m) || m.z != z || getdist(src,m) > 20)
				hakai_failed = 1
				break
			sleep(TickMult(5))

		last_hakai_use = world.time
		if(m)
			if(!hakai_failed)
				m.SaitamaBloodEffect()
				m.Death(src, Force_Death = 1, lose_hero = 1, lose_immortality = 0)
				CheckHakaiDeleteCharacter(m)
			else
				player_view(15, m) << "[m] broke free from Hakai"
			m.cant_move_due_to_hakai--
			if(m.Health < previous_health) m.Health = previous_health

	StrongEnoughToHakai(mob/m)
		if(BP < m.BP * hakai_bp_advantage_needed) return
		return 1

proc/CheckHakaiDeleteCharacter(mob/m)
	set waitfor=0
	if(!m || !m.key || !hakai_wipes_character) return
	var/key = m.key
	del(m)
	sleep(10) //just a guess, may not be needed
	fdel("Save/[key]")

proc/HakaiOverlay(mob/m, hakai_time = 50)
	set waitfor=0
	var/obj/Effect/hakai_ball = GetEffect()
	hakai_ball.loc = m.base_loc()
	hakai_ball.icon = 'Hakai Ball.dmi'
	CenterIcon(hakai_ball)
	hakai_ball.alpha = 0
	hakai_ball.layer = 3.9
	animate(hakai_ball, alpha = 255, time = 25)
	while(m && m.cant_move_due_to_hakai && m.z == hakai_ball.z)
		hakai_ball.loc = m.base_loc()
		sleep(world.tick_lag)
	animate(hakai_ball, alpha = 0, time = 50)
	sleep(50)
	del(hakai_ball)
mob/Admin4/verb/GoUltraInstinct(mob/m in world)
	set category = "Admin"
	m.UltraInstinct()

mob/Admin4/verb/MassUltraInstinct()
	set category = "Admin"
	var/confirm=input("Are you sure you want to do this? (Mass Ultra Instinct)") in list("Yes","No")
	if(confirm=="No") return
	for(var/mob/m in players) m.UltraInstinct()
	Log(src,"[key] gave everybody Ultra Instinct.")

var
	ultra_instinct_speed = 3
	ultra_instinct_acc = 3
	ultra_instinct_ref = 3
	ui_bp_mult_add = 0.7

	ultra_instinct_idle_aura //set procedurally
	ultra_instinct_aura

proc
	GenerateUltraInstinctGraphics()
		set waitfor=0
		if(!ultra_instinct_idle_aura)
			ultra_instinct_idle_aura = image(icon = 'vermar UI aura.dmi')
		if(!ultra_instinct_aura)
			ultra_instinct_aura = 'vermar UI aura 2.dmi' + rgb(0,0,0,222)
			ultra_instinct_aura = Scaled_Icon(ultra_instinct_aura, 48, 64)

mob/var
	ultra_instinct
	tmp
		ultra_instinct_no_escape_triggered
		last_ultra_instinct = 0

mob/proc
/*
ui reqs:
have god ki mastered to at least 90%
be in the top 15% highest base bp's (relative to your bp mod so that all races have equal chance)
capped energy
the bp feats must be 75% completed
must have wished on dbs at least 3 times
must have used time chamber at least 3 times
have God_Fist
have spirit bomb
have instant transmission
*/
	HasUltraInstinctRequirements()
		if(!has_god_ki || god_ki_mastery < 90) return
		if(base_bp / bp_mod < highest_relative_base_bp * 0.85) return
		if(!EnergyCapped()) return
		if(BPFeatsCompletionPercent() < 75) return
		if(wish_count < 3) return
		if(total_hbtc_uses < 3) return
		if(!(locate(/obj/God_Fist) in src)) return
		if(!(locate(/obj/Attacks/Genki_Dama) in src)) return
		//if(!(locate(/obj/Mystic) in src)) return
		//if(!(locate(/obj/Majin) in src)) return
		if(!(locate(/obj/Shunkan_Ido) in src)) return
		//if(!(locate(/obj/Teleport) in src)) return
		//if(!(locate(/obj/Materialization) in src)) return
		return 1

	EnergyCapped()
		if(max_ki / Eff < energy_cap * 0.99) return
		return 1

	CheckTriggerUltraInstinct()
		set waitfor=0

		//return //disabled to see if it crashes the server

		if(world.time - last_ultra_instinct < 5 * 600) return
		if(!HasUltraInstinctRequirements()) return

		//sleep(60)

		var/mob/m = last_knocked_out_by_mob
		if(!m) return
		//if(get_dist(src, m) > 20) return
		//if(world.time - m.last_attacked_mob_time > 80) return
		//if(world.realtime - m.last_kill_time > 2 * 60 * 600) return

		var/choice_time = world.time
		switch(alert(src, "Go Ultra Instinct? You have 10 seconds to choose", "Options", "No", "Yes"))
			if("No") return
			if("Yes")
				if(world.time - choice_time > 100) return

		UltraInstinct()

	UltraInstinct()
		set waitfor=0
		if(ultra_instinct) return
		Tens("<font size=5><font color=red>[src] has just gone Ultra Instinct!")
		last_ultra_instinct = world.time
		ultra_instinct = 1
		for(var/v in 1 to 6) PowerUpGoNextForm()
		UltraInstinctGraphics()
		UltraInstinctSFX()
		ApplyStun(time = 50, no_immunity = 1)
		FullHeal()
		SSj_Hair()
		overlays -= ultra_instinct_idle_aura
		overlays += ultra_instinct_idle_aura
		overlays -= 'UI_Electricity.dmi'
		overlays += 'UI_Electricity.dmi'

		Spd *= ultra_instinct_speed
		spdmod *= ultra_instinct_speed
		Off *= ultra_instinct_acc
		offmod *= ultra_instinct_acc
		Def *= ultra_instinct_ref
		defmod *= ultra_instinct_ref
		bp_mult += ui_bp_mult_add

		UltraInstinctDestroyObstacles()
		UltraInstinctSideStepLoop()
		UltraInstinctNoEscapeLoop()

		sleep(1800)
		UltraInstinctRevert()

	UltraInstinctRevert()
		set waitfor=0
		if(!ultra_instinct) return
		ultra_instinct = 0
		overlays -= ultra_instinct_idle_aura
		overlays -= 'UI_Electricity.dmi'

		Spd /= ultra_instinct_speed
		spdmod /= ultra_instinct_speed
		Off /= ultra_instinct_acc
		offmod /= ultra_instinct_acc
		Def /= ultra_instinct_ref
		defmod /= ultra_instinct_ref
		bp_mult -= ui_bp_mult_add

		player_view(50,src) << sound(null)
		player_view(20,src) << sound('ultra instinct explode.ogg', volume = 50)
		Explosion_Graphics(src,3)
		SaitamaBloodEffect(blood_range = 2, blood_chance = 35)
		ApplyStun(time = 150, no_immunity = 1)
		Revert()
		Stop_Powering_Up()
		God_Fist_Revert()
		KO()
		sleep(25)
		UnKO()
		Health = 1
		Ki = 1
		AddStamina(-99999)

	UltraInstinctSFX()
		set waitfor=0
		player_view(50,src) << sound('Ultra Instinct Sound Effect.ogg', volume = 77)
		sleep(33)
		player_view(50,src) << sound('Ultra Instinct Music No Vocals.ogg', volume = 15)

	UltraInstinctDestroyObstacles()
		set waitfor=0
		sleep(65) //wait for transformation sequence to end
		while(ultra_instinct)
			for(var/obj/o in view(8,src)) if(!o.Builder) //because doors are obj/Turfs
				if(istype(o,/obj/Trees) || istype(o,/obj/Turfs) || istype(o,/obj/Big_Rock))
					UltraInstinctSwirlEffect(pos = o.loc, time = 30, start_size = 0.1, end_size = 2, easing = LINEAR_EASING, start_alpha = 128)
					del(o)
					break
			sleep(rand(2,8))

	UltraInstinctSideStepLoop()
		set waitfor=0

		return //was more annoying than helpful i think

		while(ultra_instinct)
			for(var/mob/m in view(1,src))
				if(m != src && m.client)
					var/d = get_dir(m,src)
					d = turn(d, pick(135,-135))
					step(src,d,32)
					break
			sleep(rand(8,12))

	UltraInstinctNoEscapeLoop()
		set waitfor=0
		while(ultra_instinct)
			if(last_attacker && last_attacker.client)
				if(get_dist(src,last_attacker) > 14 && viewable(src,last_attacker))
					var/turf/t = get_step(last_attacker, last_attacker.dir)
					if(t)
						ultra_instinct_no_escape_triggered = 1
						SafeTeleport(t)
						dir = get_dir(src,last_attacker)
						player_view(20,src)<<sound('teleport.ogg',volume=15)
						flick('Zanzoken.dmi',src)
						Melee()
			sleep(10)

mob/proc/UltraInstinctGraphics()
	set waitfor=0
	var/N=12
	for(var/mob/m in player_view(50,src))
		m.ScreenShake(Amount = 25, Offset = 11)
	spawn while(N&&src)
		N--
		//Make_Shockwave(src,7,'Electricgroundbeam2.dmi')
		//Make_Shockwave(src,7,ultra_instinct_aura)
		//Make_Shockwave(src,7,'Give Power Effect White.dmi')
		Make_Shockwave(src,7,'Ultra Instinct Spark Shockwave.dmi')
		sleep(rand(200,300) / 100)
	spawn if(src) Ultra_Instinct_Rising_Aura(src,65)
	RisingRocksTransformFXNoWait(rocksPerSession = 2, sessions = 20, sessionDelay = 2, maxDist = 6, distGrowPerSession = 1, minVel = 30, maxVel = 60, fadeTime = 30, hoverTime = 20)
	UltraInstinctSwirlEffect(pos = loc, time = 100, start_size = 0.15, end_size = 5)
	UltraInstinctSwirlEffect(pos = loc, time = 150, start_size = 0.1, end_size = 4)

	sleep(35)

	while(ultra_instinct)
		var/turf/t = locate(x + rand(-26,26), y + rand(-26,26), z)
		if(t)
			UltraInstinctSwirlEffect(pos = t, time = 50, start_size = 0.12, end_size = 7, easing = SINE_EASING, start_alpha = 53)
		sleep(3)

proc/UltraInstinctSwirlEffect(turf/pos, time = 100, start_size = 0.1, end_size = 5, easing = SINE_EASING, start_alpha = 211)
	set waitfor=0
	var/obj/Effect/o = GetEffect()
	o.SafeTeleport(pos)
	Timed_Delete(o,time + 1)
	o.icon='swirling white energy.png'
	o.alpha = start_alpha
	o.transform *= start_size
	o.transform = turn(o.transform, rand(0,360))
	animate(o, alpha = 0, transform = matrix() * end_size, time = time, easing = easing)
	o.layer = 9
	CenterIcon(o)

proc/Ultra_Instinct_Rising_Aura(obj/T,N=50)
	if(N<0) return
	N=round(N)
	var/image/i = image(icon = ultra_instinct_aura)
	while(T&&T.z&&N)
		N--
		var/obj/Rising_Aura_Ultra_Instinct/A = new(T.loc)
		A.step_size = 10
		A.icon = i
		sleep(1)

obj/Rising_Aura_Ultra_Instinct
	layer=90
	Savable=0
	mouse_opacity = 0
	density = 0
	New()
		//icon_state=pick(null,"2")
		pixel_y -= 32
		Offsets(7)
		Aura_Walk()
		spawn(50) if(src) del(src)

	proc/Offsets(Offset=16)
		set waitfor=0
		while(src)
			pixel_x = rand(-Offset,Offset)
			pixel_x -= 10
			sleep(1)

	proc/Aura_Walk()
		set waitfor=0
		while(src)
			//step(src,NORTH)
			step_y += step_size
			sleep(world.tick_lag)
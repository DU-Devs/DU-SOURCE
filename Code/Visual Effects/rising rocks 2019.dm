mob/var
	tmp
		powerupRisingRocksLoop
	risingRockIcon

mob/verb
	CustomRisingRockIcon()
		set hidden = 1
		var/icon/i = input("choose an icon file. put multiple icon states in it for each rock to randomly choose its icon state. the name of the \
		states do not matter") as icon|null
		if(!i) return
		risingRockIcon = i

mob
	proc
		PowerupRisingRocks(obj/Power_Control/p)
			set waitfor=0

			return //off for now just in case lag

			if(powerupRisingRocksLoop) return
			powerupRisingRocksLoop = 1
			sleep(5)
			while(p.Powerup == 1)
				if(BPpcnt > 100)
					var/startRockCount = 1
					var/rockCount = startRockCount
					rockCount += (BPpcnt - 100) / 33
					if(rockCount > startRockCount * 4) rockCount = startRockCount * 4
					rockCount *= 0.08 //arbitrary
					rockCount = ToOne(rockCount)
					RisingRocksTransformFXNoWait(rocksPerSession = rockCount, sessions = 1, sessionDelay = 1, maxDist = 7, distGrowPerSession = 1, minVel = 48, maxVel = 84, fadeTime = 25, hoverTime = 5)
				sleep(TickMult(6))
			powerupRisingRocksLoop = 0

		RisingRocksTransformFXNoWait(rocksPerSession = 6, sessions = 5, sessionDelay = 10, maxDist = 8, distGrowPerSession = 1, minVel = 48, maxVel = 84, fadeTime = 10, hoverTime = 5)
			set waitfor=0
			RisingRocksTransformFX(rocksPerSession = rocksPerSession, sessions = sessions, sessionDelay = sessionDelay, maxDist = maxDist, distGrowPerSession = distGrowPerSession, \
			minVel = minVel, maxVel = maxVel, fadeTime = fadeTime, hoverTime = hoverTime)

		RisingRocksTransformFX(rocksPerSession = 6, sessions = 5, sessionDelay = 10, maxDist = 8, distGrowPerSession = 1, minVel = 48, maxVel = 84, fadeTime = 10, hoverTime = 5)
			var/dist = maxDist
			sessions = round(sessions)
			for(var/v in 1 to sessions)
				PlayerRisingRocks(amount = rocksPerSession, maxDist = dist, minVel = minVel, maxVel = maxVel, fadeTime = fadeTime, hoverTime = hoverTime)
				dist += distGrowPerSession
				sleep(sessionDelay)

		PlayerRisingRocks(amount = 1, maxDist = 8, minVel = 48, maxVel = 84, fadeTime = 10, hoverTime = 5)
			set waitfor=0
			var/turf/myPos = base_loc()
			if(!myPos) return
			myPos = locate(myPos.x, myPos.y - 2, myPos.z) //it just looks better lower, arbitrary
			if(!myPos) return
			amount = ToOne(amount)
			for(var/v in 1 to amount)
				var/turf/t = locate(rand(x - maxDist, x + maxDist), rand(y - maxDist, y + maxDist), myPos.z)
				if(!t || t.density || t.Water) continue
				if(sqrt((t.x - x) ** 2 + (t.y - y) ** 2) > maxDist) continue
				RisingRock(pos = t, minVel = minVel, maxVel = maxVel, fadeTime = fadeTime, hoverTime = hoverTime, user = src)

proc
	RisingRock(turf/pos, minVel = 48, maxVel = 84, fadeTime = 10, hoverTime = 5, mob/user)
		set waitfor=0
		if(!pos) return
		var/obj/r = GetEffect()
		if(user && user.risingRockIcon)
			r.icon = user.risingRockIcon
			r.icon_state = pick(icon_states(user.risingRockIcon))
		else r.icon = pick('gray rock 5 2019.png', 'gray rock 6 2019.png', 'gray rock 7 2019.png')
		CenterIcon(r)
		var/xOffset = r.pixel_x
		var/yOffset = r.pixel_y
		r.pixel_x = 0 //animate does not move from positives to negatives very good - looks bad
		r.pixel_y = 0
		r.loc = pos
		var/ranPixX = rand(-16,16)
		var/ranPixY = rand(-16,16)
		r.transform.Translate(ranPixX, ranPixY)
		//r.color = rgb(rand(210,255), rand(210,255), rand(210,255))

		//blob shadow
		var/randomSize = rand(80,120) * 0.6
		var/obj/shadow = GetEffect()
		shadow.icon = 'defaultblobshadow.png'
		CenterIcon(shadow)
		shadow.loc = pos
		shadow.pixel_x += abs(xOffset)
		shadow.pixel_y += abs(yOffset)
		shadow.pixel_y -= 16 //it was just a little too high compared to the rock icon
		shadow.transform.Translate(ranPixX, ranPixY)
		shadow.transform *= 0.01
		shadow.alpha = 0
		shadow.layer = pos.layer + 0.1

		//set up how the rock initially will look
		//var/xScale = 1
		//if(prob(50))
			/*var/matrix/m = r.transform
			m.Scale(-1, 1) //this is also so the spin animation is not always spinning clockwise
			r.transform = m
			var/matrix/shadowMatrix = shadow.transform
			shadowMatrix.Scale(-1,1)
			shadow.transform = shadowMatrix*/
			//xScale = -1
		r.transform = turn(r.transform, rand(1,360))
		r.transform *= 0.01
		r.alpha = 0

		//now quickly grow the rock and make it opaque as if its coming out from the ground to start out
		var/emergeTime = 3
		animate(r, alpha = 255, time = emergeTime, flags = ANIMATION_PARALLEL)
		var/shadowMaxAlpha = 70
		var/shadowMinAlpha = 35 //the alpha it will be by the time the rocks reach their peak height. shadows fade the further a rock is from the ground irl
		animate(shadow, alpha = shadowMaxAlpha, time = emergeTime, flags = ANIMATION_PARALLEL)
		animate(r, transform = r.transform * randomSize, time = emergeTime, flags = ANIMATION_PARALLEL)
		animate(shadow, transform = shadow.transform * (randomSize * 0.2), time = emergeTime, flags = ANIMATION_PARALLEL)
		sleep(emergeTime + world.tick_lag)

		//now they break free from the ground and rise and spin
		var/riseTime = rand(20,40)
		//var/opx = r.pixel_x
		var/opy = r.pixel_y
		r.SpinLoop(spin_speed = rand(450,675) * pick(-1,1), duration = 1.#INF)
		var/ranRisePixX = rand(-60,60)
		animate(r, pixel_y = 200, time = riseTime, flags = ANIMATION_PARALLEL, easing = SINE_EASING)
		animate(r, pixel_x = r.pixel_x + ranRisePixX, time = riseTime, flags = ANIMATION_PARALLEL)
		animate(shadow, pixel_x = shadow.pixel_x + ranRisePixX, time = riseTime, flags = ANIMATION_PARALLEL)
		animate(shadow, alpha = shadowMinAlpha, time = riseTime, flags = ANIMATION_PARALLEL)
		var/shadowSizeFactor = 2
		animate(shadow, transform = shadow.transform * shadowSizeFactor, time = riseTime, flags = ANIMATION_PARALLEL)
		sleep(riseTime)
		animate(r)
		animate(shadow)
		sleep(hoverTime + (world.tick_lag * 2))

		//and now they fall
		var/fallTime = 10
		r.spinloop = 0
		animate(r, pixel_y = opy, time = fallTime, flags = ANIMATION_PARALLEL)
		animate(shadow, transform = shadow.transform * (1 / shadowSizeFactor), time = fallTime, flags = ANIMATION_PARALLEL)
		animate(shadow, alpha = shadowMaxAlpha, time = fallTime, flags = ANIMATION_PARALLEL)
		sleep(fallTime + world.tick_lag)

		//and now they fade away
		animate(r, alpha = 0, time = fadeTime, flags = ANIMATION_PARALLEL)
		animate(shadow, alpha = 0, time = fadeTime, flags = ANIMATION_PARALLEL)
		sleep(fadeTime + world.tick_lag)
		animate(r)
		animate(shadow)
		r.loc = null
		shadow.loc = null
		sleep(100)
		del(r)
		del(shadow)

atom/movable/var/spinloop

atom/movable/proc/SpinLoop(spin_speed = 360, duration = 10)
	set waitfor=0
	spin_speed = spin_speed * world.tick_lag * 0.1
	spinloop = world.time
	var/timestamp = world.time
	var/spin_until = world.time + duration
	while(spinloop == timestamp && z && world.time < spin_until)
		transform = turn(transform, spin_speed)
		sleep(world.tick_lag)

atom/movable/var/spinning

atom/movable/proc/SpinNoWait(times = 1, angle = 90, duration = 10)
	set waitfor=0
	Spin(times = times, angle = angle, duration = duration)

//this will unfortunately only look right if the object is 100% stationary. otherwise it jitters around idk why
atom/movable/proc/Spin(times = 1, angle = 90, duration = 10)
	spinning = 1
	duration = TickMult(duration * 0.25)
	while(times > 0 && spinning)
		for(var/v in 1 to 4)
			animate(src, transform = turn(transform, angle * 0.25), time = duration, flags = ANIMATION_PARALLEL)
			sleep(duration)
		times--
	spinning = 0
mob
	proc/DrawHUD(mob/M=usr)
		if(!M.client) return
		var/HUD/H
		for(H in M.client.screen)		//First, clear the client's screen so that we draw completely new items...
			M.client.screen.Remove(H)	//and don't just make new ones over the old.
		var/HUD/charAnchor = new /HUD/screenAnchor("WEST+1", "NORTH-1")
		M.client.screen.Add(charAnchor)
		charAnchor.vis_contents.Add(M.cBubble)
		DrawBars(M, 0)
		DrawBars(M, 1)
	proc/DrawBars(mob/M=usr, t=0)
		var/list/statScale = list(0.5*M.guiScale, 0.55*M.guiScale)
		var/bubScale = 1.2*M.guiScale
		if(!t)
			M.healthBar = new/HUD/statBar/healthBar(M, statScale[1], statScale[2])
			M.staminaBar = new/HUD/statBar/stamBar(M, statScale[1], statScale[2])
			M.kiBar = new/HUD/statBar/kiBar(M, statScale[1], statScale[2])
			M.kiBar.layer+=1
			M.cBubble.vis_contents.Add(M.healthBar)
			M.cBubble.vis_contents.Add(M.kiBar)
			M.cBubble.vis_contents.Add(M.staminaBar)
			M.cBubble.transform*=bubScale
			var/icon/cB = new(M.cBubble.icon)
			var/bW = cB.Width()*bubScale
			var/bH = cB.Height()*bubScale
			var/icon/sB = new(M.healthBar.icon)
			var/sH = sB.Height()*statScale[2]
			M.healthBar.pixel_x = bW/2-sH-1
			M.kiBar.pixel_x = bW/2-sH-1
			M.staminaBar.pixel_x = bW/2-sH-1
			M.healthBar.pixel_y = bH-(12*bubScale)-sH
			M.kiBar.pixel_y = M.healthBar.pixel_y-sH
			M.staminaBar.pixel_y = M.healthBar.pixel_y-(sH*2)
		else
			var/HUD/tAnchor = new /HUD/screenAnchor("EAST-1.5", "NORTH-1")
			M.client.screen.Add(tAnchor)
			tAnchor.vis_contents.Add(M.tBubble)
			M.tBubble.pixel_y=16
			M.tHealth = new/HUD/statBar/healthBar(M, statScale[1], -statScale[2], 1)
			M.tStamina = new/HUD/statBar/stamBar(M, statScale[1], -statScale[2], 1)
			M.tKi = new/HUD/statBar/kiBar(M, statScale[1], -statScale[2], 1)
			M.tKi.layer+=1
			M.tBubble.vis_contents.Add(M.tHealth)
			M.tBubble.vis_contents.Add(M.tKi)
			M.tBubble.vis_contents.Add(M.tStamina)
			M.tBubble.transform*=(0-bubScale)
			var/icon/cB = new(M.cBubble.icon)
			var/bW = cB.Width()*bubScale
			var/bH = cB.Height()*bubScale
			var/icon/sB = new(M.healthBar.icon)
			var/sH = sB.Height()*statScale[2]
			M.tHealth.pixel_x = -bW-sH-1
			M.tKi.pixel_x = -bW-sH-1
			M.tStamina.pixel_x = -bW-sH-1
			M.tHealth.pixel_y = bH-(28*bubScale)-sH
			M.tKi.pixel_y = M.tHealth.pixel_y-sH
			M.tStamina.pixel_y = M.tHealth.pixel_y-(sH*2)

	var
		HUD/healthBar
		HUD/kiBar
		HUD/staminaBar
		HUD/cBubble = new /HUD/charBubble
		HUD/tHealth
		HUD/tKi
		HUD/tStamina
		HUD/tBubble = new /HUD/charBubble
		guiScale = 1


HUD
	parent_type = /obj
	charBubble
		icon = 'charBubble.dmi'
		layer = OBJ_LAYER + EFFECTS_LAYER + MOB_LAYER + 1

	screenAnchor
		New(screenX, screenY=null)
			if(screenY) screen_loc="[screenX],[screenY]"
			else screen_loc="[screenX]"

	statBar
		var/getStat

		New(mob/U, trX, trY, t=0)
			var/matrix/M = matrix()
			M.Scale(trX, trY)
			src.transform = M
			Update(U, t)

		proc/Update(mob/U, t=0)
			var/stat=1, statmax=1, maxpct=100
			var/mob/M
			var/pct
			if(U) M = U
			if(t && M) M = M.Target
			if(M)
				switch(getStat)
					if("health")
						stat = M.Health
						statmax = 100
						maxpct = 200
					if("Ki")
						stat = M.Ki
						statmax = M.max_ki
						maxpct = 300
					if("stamina")
						stat = M.stamina
						statmax = M.max_stamina
				pct = (stat/statmax) * 100
				if(pct < 0) pct = 0
				if(pct > maxpct) pct = maxpct
				icon_state = "[round(pct,10)]"
			else icon_state = "100"
			spawn(1) Update(U, t)

		healthBar
			icon = 'healthbar.dmi'
			icon_state = "100"
			getStat = "health"
		stamBar
			icon = 'stambar.dmi'
			icon_state = "100"
			getStat = "stamina"
		kiBar
			icon = 'kibar.dmi'
			icon_state = "100"
			getStat = "Ki"
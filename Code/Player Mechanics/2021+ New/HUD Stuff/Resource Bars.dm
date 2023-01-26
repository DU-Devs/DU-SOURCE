mob/Admin5/verb/TestMaptextOffset(n as num)
	targetResourceBars.maptext_x = n

obj/screen_object/mainHUDMaster
	plane = HUD_MAIN
	alpha = 255
	appearance_flags = PLANE_MASTER
	screen_loc = "1,1"
	mouse_opacity = 0

mob/var/tmp/obj/screen_object/bar_container/healthBar
mob/var/tmp/obj/screen_object/bar_container/energyBar
mob/var/tmp/obj/screen_object/bar_container/staminaBar
mob/var/tmp/obj/screen_object/mainHUDMaster/mainHUDMaster
mob/var/tmp/obj/screen_object/resourceBars
mob/var/tmp/hudActive = 0
mob/var/tmp/lastResourceUpdate = 0

mob/proc/GenerateResourceBars(scaleX = ((ViewX * 32) / 64) / 5, scaleY = ((ViewY * 32) / 64) / 46)
	src.client.screen.Remove(resourceBars)
	src.client.screen.Remove(mainHUDMaster)
	resourceBars = new(client)
	resourceBars.plane = HUD_MAIN
	resourceBars.layer = FLOAT_LAYER
	resourceBars.screen_loc = "LEFT+1,TOP-1.5"
	mainHUDMaster = new(client)
	src.client.screen.Add(resourceBars, mainHUDMaster)
	scaleX *= client.hudScale
	scaleY *= client.hudScale

	healthBar = new(client, scaleX, scaleY, rgb(255, 0, 0), 'bars3.dmi')
	var/icon/I = icon(healthBar.maskedBar.icon)
	var/iWidth = I.Width()

	resourceBars.maptext_width = 512
	resourceBars.maptext_y = iWidth * scaleY + 16 + 48 * scaleY
	resourceBars.maptext_x = iWidth / 4
	var/formText = " | Base Form"
	var/transformation/activeForm = GetActiveForm()
	if(activeForm && istype(activeForm, /transformation))
		if(!activeForm.mastered)
			formText = " | [activeForm.name] - [activeForm.mastery]%"
		else
			formText = " | [activeForm.name]"

	resourceBars.maptext = "<span style='font-family:Walk The Moon;font-size:8pt;text-align:left;-dm-text-outline:1px white'>lv[effectiveBPTier] \
								| [name][formText]</span>"
	
	healthBar.plane = HUD_MAIN

	scaleY = ((ViewY * 32) / 64) / 48 * client.hudScale
	scaleX = ((ViewX * 32) / 64) / 5.5 * client.hudScale

	energyBar = new(client, scaleX, scaleY, rgb(0, 0, 255), 'bars3.dmi')
	energyBar.pixel_y = -(iWidth * scaleY)
	energyBar.plane = HUD_MAIN

	scaleY = ((ViewY * 32) / 64) / 50 * client.hudScale
	scaleX = ((ViewX * 32) / 64) / 6 * client.hudScale

	staminaBar = new(client, scaleX, scaleY, rgb(0, 255, 0), 'bars3.dmi')
	staminaBar.pixel_y = energyBar.pixel_y - (iWidth * scaleY)
	staminaBar.plane = HUD_MAIN

	resourceBars.vis_contents.Add(healthBar, energyBar, staminaBar)

obj/screen_object/targetHUDMaster
	plane = HUD_TARGET
	alpha = 0
	appearance_flags = PLANE_MASTER
	screen_loc = "1,1"
	mouse_opacity = 0

mob/var/tmp/obj/screen_object/bar_container/targetHealthBar
mob/var/tmp/obj/screen_object/bar_container/targetEnergyBar
mob/var/tmp/obj/screen_object/bar_container/targetStaminaBar
mob/var/tmp/obj/screen_object/targetHUDMaster/targetHUDMaster
mob/var/tmp/obj/screen_object/targetResourceBars

mob/proc/GenerateTargetResourceBars(scaleX = ((ViewX * 32) / 64) / 4, scaleY = ((ViewY * 32) / 64) / 46)
	src.client.screen.Remove(targetResourceBars)
	src.client.screen.Remove(targetHUDMaster)
	targetResourceBars = new(client)
	targetResourceBars.plane = HUD_TARGET
	targetResourceBars.layer = FLOAT_LAYER
	targetResourceBars.screen_loc = "RIGHT-1,TOP-1.5"
	targetHUDMaster = new(client)
	src.client.screen.Add(targetResourceBars, targetHUDMaster)
	scaleX *= -client.hudScale
	scaleY *= client.hudScale

	targetHealthBar = new(client, scaleX, scaleY, rgb(255, 0, 0), 'bars3.dmi')
	var/icon/I = icon(targetHealthBar.maskedBar.icon)
	var/iWidth = I.Width()

	targetResourceBars.maptext_width = 128
	targetResourceBars.maptext_y = iWidth * scaleY + 16 + 48 * scaleY
	targetResourceBars.maptext_x = -(targetResourceBars.maptext_width + iWidth / 4)
	
	targetHealthBar.plane = HUD_TARGET

	scaleY = ((ViewY * 32) / 64) / 48 * client.hudScale
	scaleX = ((ViewX * 32) / 64) / 5 * -client.hudScale

	targetEnergyBar = new(client, scaleX, scaleY, rgb(0, 0, 255), 'bars3.dmi')
	targetEnergyBar.pixel_y = -(iWidth * scaleY)
	targetEnergyBar.plane = HUD_TARGET

	scaleY = ((ViewY * 32) / 64) / 50 * client.hudScale
	scaleX = ((ViewX * 32) / 64) / 6 * -client.hudScale

	targetStaminaBar = new(client, scaleX, scaleY, rgb(0, 255, 0), 'bars3.dmi')
	targetStaminaBar.pixel_y = targetEnergyBar.pixel_y - (iWidth * scaleY)
	targetStaminaBar.plane = HUD_TARGET

	targetResourceBars.vis_contents.Add(targetHealthBar, targetEnergyBar, targetStaminaBar)

mob/proc/UpdateHUD()
	set background = TRUE
	set waitfor = FALSE

	if(!client || hudActive) return
	hudActive = 1
	winshow(src, "Bars", 0)
	
	var/icon/I = icon(healthBar.maskedBar.icon)
	var/iWidth = I.Width()

	while(client && hudActive)
		UpdateResourceBars(iWidth)
		UpdateTargetBars(iWidth)
		UpdatePartyBars(iWidth)
		sleep(2)

	if(client)
		winshow(src, "Bars", 1)
	hudActive = 0

mob/proc/UpdateResourceBars(iWidth = barWidth)
	if(!resourceBars) return
	if((!Target || !ismob(Target)) && client.hudFadeTime && (HasMaxResources() && (world.time > lastResourceUpdate + client.hudFadeTime)))
		if(mainHUDMaster.alpha > client.minHUDOpacity)
			animate(mainHUDMaster, alpha = client.minHUDOpacity, time = 5)
	else mainHUDMaster.alpha = client.maxHUDOpacity

	if(client.hudFadeTime && (world.time > lastExpUpdate + client.hudFadeTime))
		if(expMaster.alpha > client.minHUDOpacity)
			animate(expMaster, alpha = client.minHUDOpacity, time = 5)
	else expMaster.alpha = client.maxHUDOpacity
	var/formText = " | Base Form"
	var/transformation/activeForm = GetActiveForm()
	if(activeForm && istype(activeForm, /transformation))
		if(!activeForm.mastered)
			formText = " | [activeForm.name] - [Math.Round(activeForm.mastery, 0.01)]%"
		else
			formText = " | [activeForm.name]"
	if(God_Fist_level)
		formText += " | God-Fist x[God_Fist_level] - [round(GodFistMastery,0.1)]%"

	resourceBars.maptext = "<span style='font-family:Walk The Moon;font-size:8pt;text-align:left;-dm-text-outline:1px white'>lv[effectiveBPTier] \
							[Math.Round(PowerPct(), 1)]% | [name][formText]</span>"

	var/obj/bar = healthBar.maskedBar.mainBar
	var/pct = Math.Clamp(Health / 100, 0, 1)
	animate(bar, pixel_x = -iWidth * (1 - pct), time = 5, easing = SINE_EASING)

	bar = energyBar.maskedBar.mainBar
	pct = Math.Clamp(Ki / max_ki, 0, 1)
	animate(bar, pixel_x = -iWidth * (1 - pct), time = 5, easing = SINE_EASING)

	bar = staminaBar.maskedBar.mainBar
	pct = Math.Clamp(stamina / max_stamina, 0, 1)
	animate(bar, pixel_x = -iWidth * (1 - pct), time = 5, easing = SINE_EASING)

mob/proc/UpdateTargetBars(iWidth = barWidth)
	if(!targetResourceBars) return
	if(Target && ismob(Target))
		var/mob/targetMob = Target
		targetHUDMaster.alpha = client.maxHUDOpacity

		targetResourceBars.maptext = "<span style='font-family:Walk The Moon;font-size:8pt;text-align:right;-dm-text-outline:1px white'>[targetMob.name] \
										| lv[targetMob.effectiveBPTier]</span>"

		var/obj/bar = targetHealthBar.maskedBar.mainBar
		var/pct = Math.Clamp(targetMob.Health / 100, 0, 1)
		animate(bar, pixel_x = -iWidth * (1 - pct), time = 5, easing = SINE_EASING)

		bar = targetEnergyBar.maskedBar.mainBar
		pct = Math.Clamp(targetMob.Ki / targetMob.max_ki, 0, 1)
		animate(bar, pixel_x = -iWidth * (1 - pct), time = 5, easing = SINE_EASING)

		bar = targetStaminaBar.maskedBar.mainBar
		pct = Math.Clamp(targetMob.stamina / targetMob.max_stamina, 0, 1)
		animate(bar, pixel_x = -iWidth * (1 - pct), time = 5, easing = SINE_EASING)

	else
		targetHUDMaster.alpha = 0
		targetResourceBars.maptext = ""
	
mob/proc/UpdatePartyBars(iWidth = barWidth)
	if(!partyResourceBars) return
	if(PartySize() > 1)
	
		partyHUDMaster.alpha = client.maxHUDOpacity

		var/i = 1
		for(var/mob/M in PartyMembers())
			if(M == src) continue
			var/obj/screen_object/bar_container/partyHealthBar = partyHealthBars[i]
			var/obj/screen_object/bar_container/partyEnergyBar = partyEnergyBars[i]
			var/obj/screen_object/bar_container/partyStaminaBar = partyStaminaBars[i]

			var/obj/screen_object/bar = partyHealthBar.maskedBar.mainBar
			var/pct = Math.Clamp(M.Health / 100, 0, 1)
			animate(bar, pixel_x = -iWidth * (1 - pct), time = 5, easing = SINE_EASING)

			bar = partyEnergyBar.maskedBar.mainBar
			pct = Math.Clamp(M.Ki / M.max_ki, 0, 1)
			animate(bar, pixel_x = -iWidth * (1 - pct), time = 5, easing = SINE_EASING)

			bar = partyStaminaBar.maskedBar.mainBar
			pct = Math.Clamp(M.stamina / M.max_stamina, 0, 1)
			animate(bar, pixel_x = -iWidth * (1 - pct), time = 5, easing = SINE_EASING)

			i++

	else
		partyHUDMaster.alpha = 0
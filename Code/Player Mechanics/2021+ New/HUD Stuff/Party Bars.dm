obj/screen_object/partyHUDMaster
	plane = HUD_PARTY
	alpha = 255
	appearance_flags = PLANE_MASTER
	screen_loc = "1,1"
	mouse_opacity = 0

mob/var/tmp/list/partyHealthBars = new/list
mob/var/tmp/list/partyEnergyBars = new/list
mob/var/tmp/list/partyStaminaBars = new/list
mob/var/tmp/obj/screen_object/partyHUDMaster/partyHUDMaster
mob/var/tmp/obj/screen_object/partyResourceBars

mob/proc/GeneratePartyResourceBars(scaleX = 1.5, scaleY = 0.125)
	src.client.screen.Remove(partyResourceBars)
	src.client.screen.Remove(partyHUDMaster)
	partyResourceBars = new(client)
	partyHUDMaster = new(client)
	partyResourceBars.plane = HUD_PARTY
	partyResourceBars.layer = FLOAT_LAYER
	partyResourceBars.screen_loc = "LEFT+2.25,CENTER+2"
	src.client.screen.Add(partyResourceBars, partyHUDMaster)
	scaleX *= client.hudScale
	scaleY *= client.hudScale

	partyHealthBars = new/list
	partyEnergyBars = new/list
	partyStaminaBars = new/list

	if(PartySize() <= 1) return
	for(var/i=2, i<=PartySize(), i++)

		var/obj/screen_object/bar_container/healthBar = new(client, scaleX, scaleY, rgb(255, 0, 0), 'bars3.dmi')
		partyHealthBars.Add(healthBar)
		var/icon/I = icon(healthBar.maskedBar.icon)
		var/iWidth = I.Width()
		
		healthBar.pixel_y = -(iWidth * scaleY) - (i - 1) * 48
		healthBar.plane = HUD_PARTY

		var/obj/screen_object/bar_container/energyBar = new(client, scaleX, scaleY, rgb(0, 0, 255), 'bars3.dmi')
		partyEnergyBars.Add(energyBar)
		energyBar.pixel_y = healthBar.pixel_y - (iWidth * scaleY)
		energyBar.plane = HUD_PARTY

		var/obj/screen_object/bar_container/staminaBar = new(client, scaleX, scaleY, rgb(0, 255, 0), 'bars3.dmi')
		partyStaminaBars.Add(staminaBar)
		staminaBar.pixel_y = energyBar.pixel_y - (iWidth * scaleY)
		staminaBar.plane = HUD_PARTY

		partyResourceBars.vis_contents.Add(healthBar, energyBar, staminaBar)
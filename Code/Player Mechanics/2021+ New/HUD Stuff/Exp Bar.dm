obj/screen_object/exp_bar_master
	plane = HUD_EXP
	alpha = 255
	appearance_flags = PLANE_MASTER
	screen_loc = "1,1"
	mouse_opacity = 0

mob/var/tmp/obj/screen_object/bar_container/expBarContainer
mob/var/tmp/obj/screen_object/expBar
mob/var/tmp/obj/screen_object/exp_bar_master/expMaster
mob/var/tmp/lastExpUpdate = 0

mob/proc/GenerateExpBar(scaleX = ((ViewX * 32) / 64) / 2, scaleY = ((ViewY * 32) / 64) / 46)
	src.client.screen.Remove(expBar)
	src.client.screen.Remove(expMaster)
	expBar = new(client)
	expBar.plane = HUD_EXP
	expBar.layer = FLOAT_LAYER
	expBar.screen_loc = "CENTER,BOTTOM-1"
	expMaster = new(client)
	src.client.screen.Add(expBar, expMaster)
	scaleX *= client.hudScale
	scaleX = Math.Min(scaleX, ((ViewX * 32) / 64) * 0.8)
	scaleY *= client.hudScale

	expBarContainer = new(client, scaleX, scaleY, rgb(0, 150, 175), 'bars3.dmi')
	expBarContainer.plane = HUD_EXP
	expBarContainer.pixel_x = -(scaleX * TILE_WIDTH) + (0.5 * TILE_WIDTH)
	expBarContainer.pixel_y = (scaleY * TILE_HEIGHT) * 1.5

	expBar.vis_contents.Add(expBarContainer)
	UpdateExpBar()

mob/proc/UpdateExpBar()
	if(!expBarContainer) return
	var/obj/bar = expBarContainer.maskedBar.mainBar
	var/currentTierReq = GetTierReq(bpTier), nextTierReq = GetTierReq(bpTier + 1), baseBP = base_bp + static_bp + (Race == "Android" ? cyber_bp : 0)
	var/pct = Math.Clamp((baseBP - currentTierReq) / (nextTierReq - currentTierReq), 0, 1)
	
	var/icon/I = icon(expBarContainer.maskedBar.icon)
	var/iWidth = I.Width()

	bar.pixel_x = iWidth * -(1 - pct)
	lastExpUpdate = world.time
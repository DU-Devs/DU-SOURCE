mob/Admin5/verb/GetViewSizes()
	usr << "[ViewX]x[ViewY]"

client/var/hudFadeTime = 150
client/var/maxHUDOpacity = 255
client/var/minHUDOpacity = 0
client/var/hudScale = 1

obj/screen_object/bar_container
	vis_flags = VIS_INHERIT_LAYER
	mouse_opacity = 0
	var
		obj/screen_object
			bar_mask
				maskedBar
			bar_border
				borderU = new
				borderD = new
				borderR = new
				borderL = new
	
	New(newloc, scaleX, scaleY, rgb, _icon = 'bars.dmi')
		client = newloc
		maskedBar = new(newloc, scaleX, scaleY, rgb, _icon)

		borderU.icon = _icon
		var/matrix/t = matrix()
		t.Scale(scaleX, -1)
		borderU.transform = t

		borderD.icon = _icon
		t = matrix()
		t.Scale(scaleX, 1)
		borderD.transform = t

		borderR.icon = _icon
		t = matrix()
		t.Scale(scaleY, -1)
		t.Turn(90)
		borderR.transform = t

		borderL.icon = _icon
		t = matrix()
		t.Scale(scaleY, 1)
		t.Turn(90)
		borderL.transform = t

		var/icon/I = icon(_icon)
		var/iWidth = I.Width()

		borderR.pixel_x = (scaleX - 1) * iWidth
		borderD.pixel_x = (scaleX - 1) * (iWidth / 2)
		borderU.pixel_x = (scaleX - 1) * (iWidth / 2)
		borderU.pixel_y = (scaleY - 1) * (iWidth / 2)
		borderD.pixel_y = -(scaleY - 1) * (iWidth / 2)
		vis_contents.Add(maskedBar, borderU, borderD, borderR, borderL)

obj/screen_object/bar_mask
	appearance_flags = KEEP_TOGETHER|NO_CLIENT_COLOR
	vis_flags = VIS_INHERIT_LAYER|VIS_INHERIT_PLANE
	mouse_opacity = 0
	icon = 'bars.dmi'
	icon_state = "back"
	var/obj/screen_object/bar/mainBar = new

	New(newloc, scaleX, scaleY, rgb, _icon = 'bars.dmi')
		client = newloc
		icon = _icon
		mainBar.color = rgb
		mainBar.icon = _icon
		vis_contents.Add(mainBar)

		var/matrix/t = matrix()
		t.Scale(scaleX, scaleY)
		src.transform = t
		var/icon/I = icon(_icon)
		var/iWidth = I.Width()

		src.pixel_x = (scaleX - 1) * Math.Ceil(iWidth / 2)

obj/screen_object/bar_border
	icon = 'bars.dmi'
	icon_state = "outer"
	vis_flags = VIS_INHERIT_LAYER|VIS_INHERIT_PLANE
	mouse_opacity = 0

obj/screen_object/bar
	icon = 'bars.dmi'
	icon_state = "fill"
	plane = FLOAT_PLANE
	layer = FLOAT_LAYER
	blend_mode = BLEND_INSET_OVERLAY
	mouse_opacity = 0
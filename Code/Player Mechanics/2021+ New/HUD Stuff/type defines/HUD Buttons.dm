obj/screen_object/screen_button
	plane = HUD_MAIN
	
	Click(location, control, params)
		ButtonUse()
	
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		ButtonUse()
	
	proc/ButtonUse()

obj/screen_object/screen_button/toggle
	var
		active = 0
		obj/screen_object/button_darken
		obj/screen_object/toggle_grouper/button_group
	
	New()
		..()
		button_darken = new
		button_darken.alpha = 125
		button_darken.icon = icon
		button_darken.icon_state = "blank"
		button_darken.plane = plane
		button_darken.layer = layer + 0.1
		button_darken.vis_flags = VIS_INHERIT_ID

	ButtonUse()
		if(!button_group) return
		if(!active)
			button_group.SetActive(src)
		else
			button_group.SetActive(null)

	proc
		AddOverlay()
			vis_contents |= button_darken
		
		RemoveOverlay()
			vis_contents -= button_darken

		Activate()
			active = 1

		Deactivate()
			active = 0

obj/screen_object/toggle_grouper
	var
		list/group = list()
		obj/screen_object/screen_button/toggle/active

	proc
		AddButton(obj/screen_object/screen_button/toggle/B)
			group ||= list()
			if(!B) return
			group |= B
			B.button_group = src
		
		AddOverlays(obj/screen_object/O)
			for(var/obj/screen_object/screen_button/toggle/B in group)
				O.vis_contents |= B
		
		SetActive(obj/screen_object/screen_button/toggle/O)
			active = O
			if(!active) active = group[1]
			for(var/obj/screen_object/screen_button/toggle/B in group)
				B.RemoveOverlay()
				B.Deactivate()
			active.AddOverlay()
			active.Activate()
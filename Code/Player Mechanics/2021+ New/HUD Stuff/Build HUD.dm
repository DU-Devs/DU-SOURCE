var/list/BuildTools = list(BUILD_PAINT, BUILD_LINE, BUILD_PICK, BUILD_FILL, BUILD_RECT, BUILD_RECT_HOLLOW, BUILD_ELLIPSE, BUILD_SELECT)

mob/proc/BuildCostToText()
	return "[Commas(turf_lay_cost())]"

mob/proc/FundsToText()
	return "[Commas(Res())]"

proc/DirectionToState(direction)
	switch(direction)
		if(NORTH) return "N"
		if(SOUTH) return "S"
		if(EAST) return "E"
		if(WEST) return "W"

obj/screen_object/screen_button/offset
	icon = 'build mode small icons.dmi'
	var
		axis = "y"
		direction = 1
	
	ButtonUse()
		usr?.client?.OffsetSelections(axis, direction)

obj/screen_object/screen_button/toggle/direction
	icon = 'build mode small icons.dmi'

	var
		build_dir
		
	Activate()
		..()
		usr?.client?.buildDir = build_dir

	Deactivate()
		..()
		usr?.client?.buildDir = SOUTH

obj/screen_object/screen_button/toggle/build_button
	plane = HUD_BUILD
	icon = 'build mode buttons.dmi'
	icon_state = "blank"
	var
		build_tool
	
	Activate()
		..()
		usr?.client?.buildTool = build_tool
	
	Deactivate()
		..()
		usr?.client?.buildTool = BUILD_PAINT

	proc
		SetupButton(tool)
			build_tool = tool
			icon_state = ToolIconState(build_tool)
			SetMaptext()

		ToolIconState(tool_name)
			switch(tool_name)
				if(BUILD_PAINT) return "paint"
				if(BUILD_RECT) return "rect_fill"
				if(BUILD_RECT_HOLLOW) return "rect_hollow"
				if(BUILD_LINE) return "line"
				if(BUILD_FILL) return "fill"
				if(BUILD_ELLIPSE) return "ellipse"
				if(BUILD_SELECT) return "select"
				if(BUILD_PICK) return "dropper"
				else return "blank"
		
		SetMaptext()
			maptext_width = 256
			maptext_x = -(maptext_width + 4)
			maptext = "<span style='font-family:Walk The Moon;font-size:7pt;text-align:right;-dm-text-outline:1px white;color:black]'>[build_tool]</span>"

mob/var/tmp/obj/screen_object/build_hud_holder
mob/proc/AddBuildButtons()
	client.screen -= build_hud_holder
	build_hud_holder = new(client)
	build_hud_holder.screen_loc = "RIGHT-0.5,TOP-0.5"
	client.screen += build_hud_holder
	var/obj/screen_object/toggle_grouper/G = new(client)
	var/count = 0, scale = client.hudScale + 0.5
	for(var/i in BuildTools)
		var/obj/screen_object/screen_button/toggle/build_button/B = new(client)
		B.SetupButton(i)
		B.transform = matrix().Scale(scale)
		B.pixel_y = Math.Floor(-((16 * scale) + (16 * scale) / 2) * count)
		B.color = hudColor
		G.AddButton(B)
		if(i == BUILD_PAINT)
			G.SetActive(B)
		count++
	G.AddOverlays(build_hud_holder)
	
	G = new
	for(var/i in CARDINAL_DIRECTIONS)
		var/obj/screen_object/screen_button/toggle/direction/B = new(client)
		B.icon_state = DirectionToState(i)
		B.build_dir = i
		B.transform = matrix().Scale(scale)
		B.pixel_y = Math.Floor(-((16 * scale) + (16 * scale) / 2) * count)
		B.pixel_y += Math.Floor(8 * scale)
		B.pixel_x = -Math.Floor((16 * scale) / 4)
		if(i == EAST)
			B.pixel_y -= Math.Floor((8 * scale) + (8 * scale) / 4)
			B.pixel_x += Math.Floor((8 * scale) + (8 * scale) / 4)
		if(i == WEST)
			B.pixel_y -= Math.Floor((8 * scale) + (8 * scale) / 4)
			B.pixel_x -= Math.Floor((8 * scale) + (8 * scale) / 4)
		if(i == SOUTH)
			B.pixel_y -= Math.Floor((8 * scale) + (8 * scale) / 4)
		B.color = hudColor
		G.AddButton(B)
		if(i == NORTH)
			G.SetActive(B)
	count++
	G.AddOverlays(build_hud_holder)
	
	for(var/i in list("UP", "DOWN", "LEFT", "RIGHT"))
		var/obj/screen_object/screen_button/offset/B = new(client)
		B.icon_state = i
		B.transform = matrix().Scale(scale)
		B.pixel_y = Math.Floor(-((16 * scale) + (16 * scale) / 2) * count)
		B.pixel_y += Math.Floor(8 * scale)
		B.pixel_x = -Math.Floor((16 * scale) / 4)
		if(i == "RIGHT")
			B.axis = "x"
			B.pixel_x += Math.Floor((8 * scale) + (8 * scale) / 4)
			B.pixel_y -= Math.Floor((8 * scale) + (8 * scale) / 4)
		if(i == "LEFT")
			B.axis = "x"
			B.direction = -1
			B.pixel_x -= Math.Floor((8 * scale) + (8 * scale) / 4)
			B.pixel_y -= Math.Floor((8 * scale) + (8 * scale) / 4)
		if(i == "DOWN")
			B.direction = -1
			B.pixel_y -= Math.Floor((8 * scale) + (8 * scale) / 4)
		B.color = hudColor
		build_hud_holder.vis_contents |= B
	count++

	var/obj/screen_object/maptext_holder/M = new(client)
	M.screen_loc = "CENTER,BOTTOM+[1 * scale]"
	M.text_size = "[7 * scale]pt"
	M.text_color = "#bfc609ff"
	M.outline_color = "#000000"
	M.SetText("Current Build Cost: [BuildCostToText()]")
	client.screen += M

	M = new(client)
	M.screen_loc = "CENTER,BOTTOM+[0.5 * scale]"
	M.text_size = "[7 * scale]pt"
	M.text_color = "#07ca00ff"
	M.outline_color = "#000000"
	M.SetText("Current Resource Fund: [FundsToText()]")
	client.screen += M

	M = new(client)
	M.text_size = "[11 * scale]pt"
	M.text_color = "#7b0000ff"
	M.outline_size = "2px"
	M.screen_loc = "CENTER,TOP-[0.5 * scale]"
	M.SetText("BUILD MODE: ACTIVE")
	client.screen += M

client/proc/ClearHUD()
	for(var/obj/screen_object/O in screen)
		screen -= O
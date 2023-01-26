proxy_visual/title_display
	var/yPos = 1
	plane = HUD_TITLE
	vis_flags = VIS_INHERIT_ID
	isSaved = 0
	isHidden = 0
	icon = null
	mouse_opacity = 0

	proc
		Position(mob/M, text, ypos = yPos)
			if(!M?.client) return
			pixel_y = TILE_HEIGHT - TILE_HEIGHT / 4
			maptext = text || maptext
			maptext_width = TILE_WIDTH * 3
			maptext_height = TILE_HEIGHT
			maptext_x = -(maptext_width / 2) + TILE_WIDTH / 2
			maptext_y = 12 * ypos
			maptext = "<span style='font-family:Walk The Moon;font-size:7pt;text-align:center;-dm-text-outline:1px black;color:white'>[maptext]</span>"

mob/var/title = ""
mob/var/tmp/proxy_visual/title_display/titleDisplay = new(null)
mob/var/tmp/proxy_visual/title_display/nameDisplay = new(null)
mob/proc/AddTitleDisplay()
	titleDisplay.Position(src, title, 2)
	titleDisplay.name = "Title Display"
	nameDisplay.Position(src, name)
	nameDisplay.name = "Name Display"
	VisOverlay(titleDisplay)
	VisOverlay(nameDisplay)
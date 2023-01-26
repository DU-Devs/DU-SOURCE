obj/screen_object/maptext_holder
	var
		text_size = "7pt"
		text_color = "#000f"
		outline_size = "1px"
		outline_color = "#ffffff"
		font_family = "Walk The Moon"
		text_align = "center"
		padding = 2
	
	maptext_width = TILE_WIDTH * 8
	maptext_height = TILE_HEIGHT

	proc
		CenterVertical()
			maptext_y = -(maptext_height / 2) + TILE_HEIGHT / 2

		CenterAlign()
			maptext_x = -(maptext_width / 2) + TILE_WIDTH / 2
		
		RightAlign()
			maptext_x = -(maptext_width + padding)
		
		LeftAlign()
			maptext_x = padding
		
		SetText(text, center_y = 0)
			maptext = "<span style='font-family:[font_family];font-size:[text_size];text-align:[text_align];\
						-dm-text-outline:[outline_size] [outline_color];color:[text_color]'>[text]</span>"
			if(center_y) 
				CenterVertical()
			
			switch(text_align)
				if("right")
					RightAlign()
				if("left")
					LeftAlign()
				else
					CenterAlign()
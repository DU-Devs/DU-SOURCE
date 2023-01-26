
/*		Maptext Inputs library by Kumorii.
	Special thanks to Unwanted4Murder for some fixes and improvements!
*/

obj/input_box
	name			= "default"
	layer			= EFFECTS_LAYER
	mouse_opacity	= 2
	//icon 			= 'DEMO/box.dmi'


	var/tmp
		text2disp		= ""	// the raw text that has been put into the input.
		is_password		= 0		// 1 if the input should hide the input data ("********" instead of "password")
		max_length		= 16		// the maximum characters that can be input.
		disabled		= 0		// 1 if it's disabled.
		enter_context 	= null


	New()
		..()
		spawn
			var/icon/i 	= icon(icon)
			i.Scale(maptext_width,maptext_height)
			i += rgb(0, 0, 0)
			icon = i



	Click()
		if(disabled || !usr.client) return
		if(usr.client.active_input)

			if(usr.client.active_input == src) return
			if(usr.client.active_input.is_password)

				var/pass_disp
				for( var/i=1, i <= length(usr.client.active_input.text2disp), i++ )
					var/tmpdisp 			= "[copytext(pass_disp,1)]"
					pass_disp 				= "[tmpdisp]*"

				usr.client.active_input.maptext		= "<center><span style = 'font-family:edmunds;font-size:18pt;color:#e0e0e0'>[pass_disp]</font>"
			else usr.client.active_input.maptext	= "<center><span style = 'font-family:edmunds;font-size:18pt;color:#e0e0e0'>[usr.client.active_input.text2disp]</font>"

		usr.client.active_input 	= src
		usr.client.enter_context 	= enter_context

		if(usr.client.active_input.is_password)

			var/pass_disp
			for(var/i=1, i <= length(usr.client.active_input.text2disp), i++)
				var/tmpdisp 			= "[copytext(pass_disp,1)]"
				pass_disp 				= "[tmpdisp]*"

			usr.client.active_input.maptext		= "<center><span style = 'font-family:edmunds;font-size:18pt;color:#ffffff'>[pass_disp] <"
		else usr.client.active_input.maptext	= "<center><span style = 'font-family:edmunds;font-size:18pt;color:#ffffff'>[usr.client.active_input.text2disp] <"







	proc
		get_text2disp()
			/*
				this returns the raw, unedited text that was entered into the field.
			*/
			return text2disp













client
	var/tmp
		obj/input_box/active_input	= null	// the currently selected input box, if any.
		shift_down					= 0		// 1 if the shift key is down.
		caps_loc					= 0		// 1 if caps lock is toggled
		backspace_timeout			= 0		// used as a cooldown on backspacing so that it stays consistent.




	Click(object)
		..()

		if(active_input && !istype(object, /obj/input_box))
			// if the player has an input box selected but clicks elsewhere on the map, deselect the input box.

			if(active_input.is_password)

				var/pass_disp
				for( var/i = 1, i <= length( active_input.text2disp ), i++ )
					var/tmpdisp 		= "[copytext(pass_disp,1)]"
					pass_disp 			= "[tmpdisp]*"

				active_input.maptext	= "<center><span style = 'font-family:edmunds;font-size:18pt;color:#ffffff'>[pass_disp]</font>"
			else active_input.maptext 	= "<center><span style = 'font-family:edmunds;font-size:18pt;color:#e0e0e0'>[active_input.text2disp]"

			active_input 				= null
			enter_context 				= null







	proc
		draw_input(_name, _loc, _width = 240, _height = 20, _default_text, _offset = 0, _is_password = 0, _enter_context)
			// draws an input box to the client's screen.
			if(_name && _loc)
				var/obj/input_box/i_box	= new
				i_box.name				= _name
				i_box.screen_loc		= _loc
				i_box.maptext_width		= _width
				i_box.maptext_height	= _height
				i_box.maptext			= _default_text
				i_box.maptext_y			= _offset
				i_box.is_password		= _is_password
				i_box.enter_context		= _enter_context
				screen += i_box






		get_ibox(i_box = "empty")
			// called to retrieve an input box with the given name.
			for(var/obj/input_box/i in screen)
				if(i.name == i_box)
					return i
			return 0 // returns false if we can't find one.






		unselect_ibox(obj/input_box/i)
			// called to unselect a selected input box, if applicable.
			if(i.is_password)

				var/pass_disp
				for( var/j = 1, j <= length( i.text2disp ), j++ )
					var/tmpdisp 	= "[copytext(pass_disp,1)]"
					pass_disp 		= "[tmpdisp]*"

				i.maptext			= "<center><span style = 'font-family:edmunds;font-size:18pt;color:#ffffff'>[pass_disp]</font>"
			else i.maptext 			= "<center><span style = 'font-family:edmunds;font-size:18pt;color:#e0e0e0'>[i.text2disp]"

			active_input 			= null
			enter_context 			= null









		erase_input(_id_tag = "empty")
			if(_id_tag)
				for(var/obj/input_box/m in screen)
					if(m.name == _id_tag)
						animate(m, alpha = 0, time = 4, loop = 1)
						sleep 6
						del m
						break
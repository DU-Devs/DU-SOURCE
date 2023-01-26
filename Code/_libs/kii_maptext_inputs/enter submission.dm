

/*
			This isn't exactly detrimental to the library, but it's how I've handled form submission instead of adding buttons to the screen.
		You can use this if you'd like, if not just put the appropriate data handling parts from below into your buttons or wherever you want to
		collect/submit input data with.

		What it does is let the player submit their data by hitting enter when entering text to an input.
	*/




client
	var/tmp
		enter_context	// what this is set to determines how the submission will be processed when the player hits enter. \
							You don't NEED this for the library, but I used it instead of using buttons.
		init_enter		// used to prevent the player from spamming/stacking enter_submit()

	proc
		enter_submit()
			if(init_enter) return
			init_enter = 1
			switch(enter_context)

				if("nameinput")
					unselect_ibox(get_ibox("Username"))
				if("Username")
					unselect_ibox(get_ibox("Username"))
					var/obj/input_box/ibox = get_ibox("Password")
					if(ibox) ibox.Click()
				if("Password")
					unselect_ibox(get_ibox("Password"))


				// you can just add switch's as needed with more tags but be warry not to abuse this /too/ much.
			init_enter = 0
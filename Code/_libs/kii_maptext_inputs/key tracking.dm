
		//			used for tracking key strokes to fill the inputs properly.



var/list
	symlist		= list("-", "=", "\[", "]", "\\", ";", "'", ",", ".", "/", "`")
	sym2list	= list("_", "+", "{", "}", "|", ":", "\"", "<", ">", "?", "~")
	numlist		= list("1", "2", "3", "4", "5", "6", "7", "8", "9", "0")



proc
	num2sym(n as num)
		if(n == 0) return ")"
		var/list/syms 	= list("!", "@", "#", "$", "%", "^", "&", "*", "(", ")")
		return syms[n]



	sym2Sym(n as text)
		for(var/i = 1 to symlist.len)
			if("[symlist[i]]" == "[n]")
				return sym2list[i]








client
	verb
		key_down( key as text )
			set instant		= 1
			set hidden 		= 1

			if(active_input)

				if(key == "Return")
					enter_submit()
					return

				switch( key )

					if("Shift")
						shift_down	= 1
						return

					if("Back")
						if(!backspace_timeout && active_input.text2disp)
							backspace_timeout	= 1
							active_input.text2disp	= "[copytext(active_input.text2disp, 1, length(active_input.text2disp))]"

							if(active_input.is_password)
								var/pass_disp
								for(var/i=1, i <= length(active_input.text2disp), i++)
									var/tmpdisp = "[copytext(pass_disp,1)]"
									pass_disp = "[tmpdisp]*"
								active_input.maptext	= "<center><span style = 'font-size:18pt;color:#ffffff'>[pass_disp] <"
							else
								active_input.maptext	= "<center><span style = 'font-size:18pt;color:#ffffff'>[active_input.text2disp] <"
							sleep
							backspace_timeout = 0
						return


					if("Capslock")
						caps_loc	= (caps_loc ? 0 : 1)
						return
					if("Space")
						key = " "

				if(key in numlist) key = text2num(key)
				if(length(active_input.text2disp) < active_input.max_length)

					if(caps_loc && !isnum(key) && !(key in symlist))
						active_input.text2disp	= "[active_input.text2disp][uppertext(key)]"
						. = 1

					if(shift_down && !.)
						if(isnum(key))	active_input.text2disp	= "[active_input.text2disp][num2sym(key)]"
						else

							if(key in symlist)	active_input.text2disp	= "[active_input.text2disp][sym2Sym(key)]"
							else active_input.text2disp					= "[active_input.text2disp][uppertext(key)]"


					else if(!.) active_input.text2disp	= "[active_input.text2disp][lowertext(key)]"

					if(active_input.is_password)
						world << "!"
						var/pass_disp = ""
						for(var/i=1, i <= length(active_input.text2disp), i++)
							var/tmpdisp 		= "[copytext(pass_disp,1)]"
							pass_disp 			= "[tmpdisp]*"
						active_input.maptext 	= "<center><span style = 'font-size:18pt;color:#ffffff'>[pass_disp]</font> <"
					else
						world << "!!"
						active_input.maptext 	= "<center><span style = 'font-size:18pt;color:#ffffff'>[active_input.text2disp] <"



		key_up( key as text)
			set hidden 		= 1
			set instant		= 1
			if(key == "Shift")
				shift_down = 0

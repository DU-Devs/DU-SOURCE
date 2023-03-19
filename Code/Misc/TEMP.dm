atom/var/Attackable //the var/'attackable' is probably interfering with this one's removal





mob/proc/View_update_logs()
	src << browse(New_Stuff, "window=Updates,size=800x600")
	//winset(src,"rpane.rpanewindow","left=browserwindow")
	//Update_tab_button_text()

mob/var/tmp/tabs_hidden
mob/verb/Toggle_tabs()
	set name=".Toggle_tabs"
	if(winget(src,"rpane.rpanewindow","left")=="infowindow")
		winset(src,"rpane.rpanewindow","left=;")
		tabs_hidden=1
	else
		winset(src,"rpane.rpanewindow","left=infowindow")
		tabs_hidden=0
	Update_tab_button_text()

mob/proc/Update_tab_button_text(button_visible=1)
	if(!client) return
	if(button_visible) winset(src,"tabbutton","is-visible=true")
	else winset(src,"tabbutton","is-visible=false")
	var/t="Show tabs"
	if(winget(src,"rpane.rpanewindow","left")=="infowindow") t="Hide tabs"
	winset(src,"tabbutton","text='[t]'")





obj
	Noxian_Guillotine
		var
			cooldown = 0
		verb
			Noxian_Guillotine()
				set src in usr.contents
				set category = "Skills"
				if(cooldown>world.realtime)
					src << "Noxian Guillotine is on cooldown. ([(cooldown-world.realtime)/10] seconds left.)"
					return 0
				for(var/mob/M in Get_step(usr,usr.dir))
					if(M&&M.client)
						var/true_damage=(M.bleed_stacks+1)*0.15
						overlays.Remove('Stack 1.dmi')
						overlays.Remove('Stack 2.dmi')
						overlays.Remove('Stack 3.dmi')
						overlays.Remove('Stack 4.dmi')
						overlays.Remove('Stack 5.dmi')
						if(M.Shielding())
							M.Ki-=(max_ki*true_damage)
							if(M.Ki<=0)
								M.Death(usr,1)
							else
								src.cooldown=world.realtime+(600*5)
						else
							M.Health-=(100*true_damage)
							if(M.Health<=0)
								M.Death(usr,1)
							else
								src.cooldown=world.realtime+(600*5)
mob
	var
		bleed_stacks=0
		bleed_remaining=0
	proc
		Is_Darius()
			if(locate(/obj/Noxian_Guillotine) in src.contents)
				return 1
			else
				return 0
		Apply_Bleed()
			bleed_stacks++
			if(bleed_stacks>5)bleed_stacks=5
			Bleed_Graphics()
			if(!bleed_remaining)
				bleed_remaining=5
				Bleed_Damage()
			else
				bleed_remaining=5

		Bleed_Graphics()
			overlays.Remove('Stack 1.dmi')
			overlays.Remove('Stack 2.dmi')
			overlays.Remove('Stack 3.dmi')
			overlays.Remove('Stack 4.dmi')
			overlays.Remove('Stack 5.dmi')
			switch(bleed_stacks)
				if(1)
					overlays.Add('Stack 1.dmi')
				if(2)
					overlays.Add('Stack 2.dmi')
				if(3)
					overlays.Add('Stack 3.dmi')
				if(4)
					overlays.Add('Stack 4.dmi')
				if(5)
					overlays.Add('Stack 5.dmi')

		Bleed_Damage()
			set waitfor=0
			while(bleed_remaining)
				Health-=(2.5*bleed_stacks)
				sleep(10)
				bleed_remaining--
				Bleed_Graphics()

mob
	Admin4
		verb
			For_Noxus()
				switch(input("Are you sure you wish to declare war in the name of Noxus?") in list("Yes","No"))
					if("Yes")
						for(var/mob/M in world)
							if(M.client)
								if(!locate(/obj/Noxian_Guillotine) in M.contents)
									M.contents+= new/obj/Noxian_Guillotine
						clients << "<font color=red><center><font size = 5>FOR NOXUS!</font size></center></font color>"

					if("No")
						for(var/mob/M in world)
							if(M.client)
								if(locate(/obj/Noxian_Guillotine) in M.contents)
									M.contents-= typesof(/obj/Noxian_Guillotine)
						clients << "<font color=red><center><font size = 5>NOXUS HAS RETREATED!</font size></center></font color>"
/*
	Code for Melee
		if(src.Is_Darius())
			M.Apply_Bleed()

*/


//Tens(Tens of DU): Death(mob/killer,Force_Death=0)
//Tens(Tens of DU): so set Force_Death=1
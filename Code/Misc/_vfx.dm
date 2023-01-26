obj/vfx
	layer = FLY_LAYER
	proc/Play(play_icon, play_time = 50)
		if(play_icon) icon = play_icon
		sleep(play_time)
		del src

	fusion
		icon = 'FusionLight.dmi'
		icon_state = ""
		Play()
			flick("flick",src)
			sleep(20)
			flick("flick",src)
			sleep(5)
			flick("flick",src)
			sleep(50)
			del src
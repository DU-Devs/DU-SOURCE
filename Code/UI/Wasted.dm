var/gta5_wasted = 0

mob/var
	tmp
		list
			gta5_screen_added

mob/proc
	GTA5WastedSound()
		src << sound('GTA 5 wasted.ogg', volume = 100)

	GTA5ScreenObjects()
		if(!client || gta5_screen_added) return

		var/obj/GTA5_Stuff/GTA5_Wasted_Logo/logo = new
		client.screen += logo

		var/obj/GTA5_Stuff/GTA5_Vignette/vig = new
		client.screen += vig

		//arbitrary because for some reason the offsets will never be correct when onscreen
		logo.pixel_x -= 80
		logo.pixel_y -= 80

		gta5_screen_added = 1

	GTA5WastedCheck()
		set waitfor=0
		if(!gta5_wasted) return
		GTA5Wasted()

	GTA5Wasted()
		if(!client) return
		GTA5ScreenObjects()
		GTA5WastedSound()
		for(var/obj/o in client.screen)
			if(o.type == /obj/GTA5_Stuff/GTA5_Wasted_Logo) GTA5WastedLogo(o)
			if(o.type == /obj/GTA5_Stuff/GTA5_Vignette) GTA5Vignette(o)

	GTA5Vignette(obj/o)
		set waitfor=0
		sleep(14)
		animate(o)
		o.alpha = 0
		o.color = rgb(255,255,255)
		var
			screen_pixel_size = (ViewX * world.icon_size) + 32 //extra for padding
			img_size = 32 //if you change the image file size you must change this
			size_mod = screen_pixel_size / img_size
		o.transform = matrix() * size_mod * 2
		animate(o, alpha = 255, time = 15)
		sleep(20)
		animate(o, color = rgb(255,0,0), time = 5)
		sleep(5)
		animate(o, color = rgb(255,255,255), time = 5)
		sleep(20)
		animate(o, alpha = 0, time = 30)


	GTA5WastedLogo(obj/o)
		set waitfor=0
		sleep(14)
		animate(o)
		o.alpha = 0
		var
			screen_pixel_size = (ViewX * world.icon_size) + 32 //extra for padding
			img_size = 192 //if you change the image file size you must change this
			size_mod = screen_pixel_size / img_size
		o.transform = matrix() * size_mod * 0.35
		sleep(20)
		animate(o, alpha = 255, time = 5)
		sleep(25)
		animate(o, alpha = 0, time = 30)

obj/GTA5_Stuff
	Savable = 0
	layer = 9
	screen_loc = "CENTER"
	mouse_opacity = 0

	New()
		. = ..()
		CenterIcon(src)
		MakeImmovableIndestructable()

	GTA5_Wasted_Logo
		icon = 'wasted gta 5.png'
		alpha = 0
		screen_loc = "CENTER-2,CENTER-2"

	GTA5_Vignette
		//icon = 'screen vignette overlay.png'
		icon = 'Blackness 2017.dmi'
		alpha = 0
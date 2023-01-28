/*
shared light source. if too many light objects are close together it looks very bad, they should share 1 giant light object, with a
pixel offset aligned to their average pixel location (x * 32 and y * 32)
	if someone moves one of the torches, just re-average the locations of the ones sharing it, or if it is moved too far take it out
	of the shared light and give it back its own light
*/

var/list
	light_sources = new

proc
	FadeOutLights(area/a)
		set waitfor=0
		if(!a) return
		for(var/obj/LightSource/l in light_sources)
			if(!l.fade_with_day) continue
			var/area/a2 = l.get_area()
			if(a == a2) l.FadeOutLight(a.day_fade_time * 1.8)

	FadeInLights(area/a)
		set waitfor=0
		if(!a) return
		for(var/obj/LightSource/l in light_sources)
			if(!l.fade_with_day) continue
			var/area/a2 = l.get_area()
			if(a == a2) l.FadeInLight(a.night_fade_time * 1.8)

atom
	var
		tmp
			obj/LightSource/light_obj
	proc
		FadeLightOut(time = 0)
			if(!light_obj) return
			light_obj.FadeOutLight(time)

		FadeLightIn(time = 0)
			if(!light_obj) return
			light_obj.FadeInLight(time)

obj
	LightSource
		icon = 'TorchLightCircle.dmi'
		density = 0
		Savable = 0
		layer = 100 //the layer HAS to be above the area layer. i tested it and it makes a huge difference
		blend_mode = BLEND_ADD
		alpha = 0
		mouse_opacity = 0 //mouse ignores this so you can click things under it

		var
			max_alpha = 70
			fade_with_day = 1

		New()
			. = ..()
			MakeImmovableIndestructable()
			light_sources += src

		proc
			FadeOutLight(n = 100)
				set waitfor=0
				animate(src)
				animate(src, alpha = 0, time = n, easing = SINE_EASING)

			FadeInLight(n = 100)
				set waitfor=0
				animate(src)
				animate(src, alpha = max_alpha, time = n, easing = SINE_EASING)

	proc
		RemoveLightSource()
			if(light_obj) del(light_obj)

		GiveLightSource(size = 1, max_alpha = 60, light_color = rgb(255,255,255), auto_fade = 1, light_icon = 'TorchLightCircle.dmi')
			set waitfor=0

			//too many lights on screen can crash people. so dont add a light if too many nearby objects already have lights
			var/nearbyLights = 0
			for(var/obj/ls in light_sources)
				if(ls.z == z && get_dist(ls, src) <= 15)
					nearbyLights++
			if(nearbyLights >= 15) return

			var/obj/LightSource/l
			if(light_obj) l = light_obj
			else l = new(loc)

			l.icon = light_icon
			l.transform = matrix() * size * 0.14
			CenterIcon(l)
			light_obj = l
			if(max_alpha) l.max_alpha = max_alpha
			l.color = light_color
			l.fade_with_day = auto_fade

			var/area/a = get_area()
			if(a)
				if(a.is_day && l.fade_with_day) l.alpha = 0
				else l.alpha = max_alpha //just set the light to max all at once now
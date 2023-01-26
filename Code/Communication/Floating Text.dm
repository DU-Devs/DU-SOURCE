atom/proc/FloatingText(text, text_color = rgb(255, 255, 255), cutoff = 200, rand_offset_x = 0, rand_offset_y = 0)
	if(length(text) > cutoff)
		text = copytext(text, 1, cutoff + 1)
	
	var/obj/screen_object/O = new(loc)
	spawn(Time.FromSeconds(5))
		del O

	O.mouse_opacity = 0
	O.density = 0
	O.plane = HUD_FLOATING_TEXT
	O.maptext_width = TILE_WIDTH * 5
	O.maptext_height = TILE_HEIGHT * 10
	O.maptext_x = -(maptext_width / 2) + (TILE_WIDTH / 2) + Math.Rand(-rand_offset_x, rand_offset_x)
	O.maptext_y = 48 + Math.Rand(-rand_offset_y, rand_offset_y)

	O.maptext = "<span style='font-size:10pt;color:[text_color];font-family:Walk The Moon;-dm-text-outline:1px black'>[text]</span>"

	animate(O, time = Time.FromSeconds(8), pixel_y = 128, pixel_x = Math.Rand(-64, 64))

atom/proc/FallingText(text, text_color = rgb(255, 255, 255))
	var/obj/screen_object/O = new(loc)
	spawn(Time.FromSeconds(3))
		del O

	O.mouse_opacity = 0
	O.density = 0
	O.plane = HUD_FALLING_TEXT
	O.maptext_width = TILE_WIDTH
	O.maptext_height = TILE_HEIGHT
	O.maptext_x = -(maptext_width / 2) + (TILE_WIDTH / 2)
	O.maptext_y = 32

	O.maptext = "<span style='font-size:10pt;color:[text_color];font-family:Walk The Moon;-dm-text-outline:1px black'>[text]</span>"

	var/sign = pick(-1, 1)
	animate(O, time = 5, pixel_y = 16, pixel_x = 32 * sign)
	animate(time = (Time.FromSeconds(4) - 5), pixel_y = -128, pixel_x = 64 * sign)

mob/var/tmp/obj/screen_object/fallingTextMaster
mob/var/tmp/obj/screen_object/floatingTextMaster
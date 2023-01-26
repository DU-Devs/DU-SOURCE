mob/proc/AscendedBPMod()
	// trying out making everyone's BP mod simply scale by their default mod during ascension
	return base_ascension_mod

var
	//base_ascension_mod = 14.85
	base_ascension_mod = 12
mob/var/has_ascended = 0

mob/proc/AscensionCheck()
	set waitfor = FALSE
	set background = TRUE
	var/max_mod = base_ascension_mod * src.Get_race_starting_bp_mod()
	if(!client) return
	while(src && src.bp_mod < max_mod)
		if(!(src.Race in list("Android", "Yasai", "Half Yasai")))
			if(src.base_bp > src.Ascension_BP_Req())
				src.bp_mod = Math.Max(bp_mod, max_mod)
				src.base_bp = Math.Max(src.base_bp, src.Ascension_BP_Req())
				if(src.base_bp < src.Ascension_BP_Req())
					src.base_bp = src.Ascension_BP_Req()
		sleep(100)

mob/proc
	Ascension_BP_Req()
		return 800000

mob/proc/OldTransGraphicsNoWait()
	set waitfor=0
	Old_Trans_Graphics()

mob/proc/Old_Trans_Graphics()

	var/fxSpeedMult = 0.7
	Dust(src, end_size = 1, time = 35)
	player_view(10,src)<<'powerup.wav'
	for(var/mob/P in player_view(20,src)) P.ScreenShake(20,8)
	sleep(40 * fxSpeedMult)
	player_view(10,src)<<'kiblast.wav'
	Make_Shockwave(src,7,sw_icon_size=256)
	sleep(3 * fxSpeedMult)
	player_view(10,src)<<'kiblast.wav'
	Make_Shockwave(src,7,sw_icon_size=256)
	sleep(30 * fxSpeedMult)
	for(var/mob/P in player_view(20,src)) P.ScreenShake(10,16)
	player_view(10,src)<<'kiblast.wav'
	Make_Shockwave(src,7,sw_icon_size=256)

	RisingRocksTransformFXNoWait(rocksPerSession = 1.5, sessions = 15, sessionDelay = 2, maxDist = 3, distGrowPerSession = 1, minVel = 48, maxVel = 80, fadeTime = 5, hoverTime = 2)

	sleep(3 * fxSpeedMult)
	player_view(10,src)<<'kiblast.wav'
	Make_Shockwave(src,7,sw_icon_size=256)
	sleep(3 * fxSpeedMult)
	player_view(10,src)<<'kiblast.wav'
	Make_Shockwave(src,7,sw_icon_size=256)
	sleep(3 * fxSpeedMult)
	player_view(10,src)<<'kiblast.wav'
	Make_Shockwave(src,7,sw_icon_size=256)

	for(var/mob/P in player_view(20,src)) P.ScreenShake(30,16)
	for(var/turf/T in view(8,src))
		if(prob(10 * fxSpeedMult)) sleep(1)
	player_view(10,src)<<sound('aura3.ogg',volume=20)
	var/I='Electric Yellow.dmi'
	I+=rgb(0,0,0,100)
	Make_Shockwave(src,7,I,sw_icon_size=256)
	sleep(3 * fxSpeedMult)
	Make_Shockwave(src,7,I,sw_icon_size=256)
	sleep(3 * fxSpeedMult)
	Make_Shockwave(src,7,sw_icon_size=256)
	sleep(3 * fxSpeedMult)
	Make_Shockwave(src,7,sw_icon_size=512)
	player_view(10,src)<<sound('wallhit.ogg',volume=25)
	BigCrater(loc)

proc/Make_Shockwave(mob/Origin,Range=7,Icon,sw_icon_size=256)
	set waitfor=0
	if(Origin)
		if(Icon) for(var/turf/T in TurfCircle(Range,Origin)) Missile(Icon,Origin,T)
		else
			if(!(sw_icon_size in list(64,128,256,512))) return
			var/obj/Shockwave_Graphic/g = Get_shockwave_graphic()
			g.loc=Origin.base_loc()
			//g.Shockwave_go(sw_icon_size)



			//convert to new shockwave sizes
			var/new_size = rand(80,120) / 100
			new_size *= 1.2
			switch(sw_icon_size)
				if(64) new_size *= 0.67
				if(128) new_size *= 0.9
				if(256) new_size *= 1.2
				if(512) new_size *= 1.5

			g.ShockwaveGo2(new_size)

proc/Get_shockwave_graphic()
	for(var/obj/o in shockwave_graphics)
		shockwave_graphics-=o
		return o

	//generate some starter shockwaves because it was a problem
	for(var/v in 1 to 65)
		var/obj/Shockwave_Graphic/swg = new
		shockwave_graphics += swg

	return new/obj/Shockwave_Graphic

var/list/shockwave_graphics=new

obj/Shockwave_Graphic
	Dead_Zone_Immune=1
	Health=1.#INF
	Grabbable=0
	Nukable=0
	Knockable=0
	Savable=0
	attackable=0
	layer=5
	icon = 'Shockwave 2016.png'

	New()
		CenterIcon(src)
		. = ..()

	Del()
		shockwave_graphics-=src
		shockwave_graphics+=src
		loc=null

	proc/ShockwaveGo2(trans_size = 1)
		set waitfor=0
		set background = TRUE
		var/start_size = 0.01
		transform = matrix() * start_size
		transform = turn(transform, rand(0,360))

		var/growTime = 2
		animate(src, transform = matrix() * trans_size, time = growTime)
		//animate(transform = matrix(pick(360,-360),MATRIX_ROTATE), time=3)
		//animate(alpha = 0, time = 3)
		sleep(growTime + world.tick_lag)
		if(src && z) del(src)

	proc/Shockwave_go(sw_size=256)
		var/icon/i
		switch(sw_size)
			if(64) i='Shockwave custom 64.dmi'
			if(128) i='Shockwave custom 128.dmi'
			if(256) i='Shockwave custom 256.dmi'
			if(512) i='Shockwave custom 512.dmi'
		pixel_x=Icon_Center_X(i)
		pixel_y=Icon_Center_Y(i)
		spawn if(src&&i) flick(i,src)
		spawn(10) if(src&&z) del(src)


mob/var
	tmp
		screen_shake_time = 0
		screen_shake_offset = 8
		screen_shake_looping

mob/proc
	ScreenShake(Amount = 10, Offset = 8)
		set waitfor=0
		screen_shake_time = Amount
		screen_shake_offset = Offset
		if(screen_shake_looping) return
		screen_shake_looping = 1
		while(screen_shake_time > 0 && client)
			screen_shake_time -= world.tick_lag
			client.pixel_x = rand(-screen_shake_offset, screen_shake_offset)
			client.pixel_y = rand(-screen_shake_offset, screen_shake_offset)
			if(screen_shake_time <= 0)
				client.pixel_x = 0
				client.pixel_y = 0
			sleep(world.tick_lag)
		screen_shake_looping = 0

var
	Yasai_bp_mod_after_ssj = 16

area/proc/SSj_Darkness()
	var/A=icon
	icon='Weather.dmi'
	icon_state="Super Darkness"
	spawn(600) if(src)
		icon=A
		icon_state=null
mob/proc/SSj_Lightning()
	var/Amount=10
	var/list/Locs=new
	for(var/turf/B in range(20,src)) Locs+=B
	while(Amount)
		Amount-=1
		var/obj/Lightning_Strike/A=Get_lightning_strike()
		A.loc=pick(Locs)
		sleep(rand(1,50))

mob/proc
	NoWaitAlert(txt)
		set waitfor=0
		alert(src, txt)
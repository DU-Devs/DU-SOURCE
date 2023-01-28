var
	max_ss_mastery = 300 //why tf did i give it such a random number like this it shouldve been a 0-100 system
	max_ss2_mastery = 300
	max_ss3_mastery = 300

mob/var
	has_ss_full_power

mob/proc/ssj_power()
	var/ssj1power = ssjadd
	//if(ssjdrain >= 300 && !is_ussj) ssj1power*=1.4 //old way of mastered ss1 boost, flawed
	if(base_bp > 10000000)
		ssj1power -= (base_bp - 10000000) * 0.67
	if(ssj1power < 0) ssj1power = 0

	//mastered ss special boost
	var/mss1_power = 0
	//i enabled this boost to be for ussj too so that ussj and ssfp will be completely equal when all is said and done. no more individual ussj bp boost, just this
	if(is_ussj || (ssjdrain >= max_ss_mastery && !is_ussj && has_ss_full_power && Class != "Legendary Yasai"))
		mss1_power = 10000000
		if(is_ussj) mss1_power += 5000000 //i decided ussj needs just a little more of an edge to be "equal" because of how slow they power up
		if(base_bp > 20000000)
			mss1_power -= (base_bp - 20000000) * 0.67
		if(mss1_power < 0) mss1_power = 0

	var/ssj2power=ssj2add
	if(base_bp > 100000000)
		ssj2power -= (base_bp - 100000000) * 0.67
	if(ssj2power < 0) ssj2power = 0

	var/ssj3power = ssj3add
	if(base_bp > 250000000)
		ssj3power -= (base_bp - 250000000) * 0.67
	if(ssj3power < 0) ssj3power = 0

	var/n = 0
	if(ssj >= 1) n += ssj1power
	if(ssj >= 1) n += mss1_power
	if(ssj >= 2) n += ssj2power
	if(ssj >= 3) n += ssj3power
	if(is_ssg) n += ssjg_bp_add

	return n

obj/Ultra_Super_Yasai
	Skill=1
	Cost_To_Learn=50
	teachable=0
	Teach_Timer=5
	student_point_cost = 50
	hotbar_type="Transformation"
	can_hotbar=1

	New()
		desc="Ultra Super Yasai can be toggled on or off in the skills tab. It grants [ussj_bp+1]x bp, \
		[ussj_ki]x energy, [ussj_str]x strength, [ussj_dur]x durability, [ussj_spd]x speed, [ussj_res]x resistance. \
		To use it, have it toggled on, \
		then just tranform into a Super Yasai, have over [Commas(ussj_bp_req)] BP available, \
		then power up twice again to go Ultra Super Yasai."

	var/using_ussj=1

	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Toggle_Ultra_Super_Yasai()

	verb/Toggle_Ultra_Super_Yasai()
		set category = "Other"
		using_ussj=!using_ussj
		if(using_ussj) usr<<"Ultra Super Yasai is now toggled on. To use it, just powerup twice after \
		going Super Yasai and have over [Commas(ussj_bp_req)] BP available."
		else usr << "Ultra Super Yasai is now toggled off"
var
	ussj_bp = 0.4
	ussj_ki = 0.67
	ussj_str = 1.3
	ussj_dur = 1.3
	ussj_res = 1.2
	ussj_spd = 0.67
	ussj_bp_req = 32000000

mob/var
	is_ussj

mob/proc/USSj()
	if(!is_ussj)
		spawn if(src)
			if(ssj3_opening) Trans_Graphics(ssj3_opening)
			else Old_Trans_Graphics()
		if(has_ss_full_power)
			src << "<font color=cyan>You already have mastered Super Yasai which gives the same BP boost as Ultra Super Yasai, so there will be no \
			difference in your BP now, only a stat difference."
		is_ussj=1
		//bp_mult+=ussj_bp
		Ki*=ussj_ki
		max_ki*=ussj_ki
		Eff*=ussj_ki
		Str*=ussj_str
		strmod*=ussj_str
		Spd*=ussj_spd
		spdmod*=ussj_spd
		End*=ussj_dur
		endmod*=ussj_dur
		Res*=ussj_res
		resmod*=ussj_res
		overlays+='Yellow Lightning aura.dmi'
		switch(icon)
			if('BaseHumanPale.dmi') icon='White Male Muscular 3.dmi'
			if('BaseHumanTan.dmi') icon='Tan Male Muscular 3.dmi'
			if('BaseHumanDark.dmi') icon='Black Male Muscular 3.dmi'
	else
		is_ussj=0
		//bp_mult-=ussj_bp
		Ki/=ussj_ki
		max_ki/=ussj_ki
		Eff/=ussj_ki
		Str/=ussj_str
		strmod/=ussj_str
		Spd/=ussj_spd
		spdmod/=ussj_spd
		End/=ussj_dur
		endmod/=ussj_dur
		Res/=ussj_res
		resmod/=ussj_res
		overlays-='Yellow Lightning aura.dmi'
		switch(icon)
			if('White Male Muscular 3.dmi') icon='BaseHumanPale.dmi'
			if('Tan Male Muscular 3.dmi') icon='BaseHumanTan.dmi'
			if('Black Male Muscular 3.dmi') icon='BaseHumanDark.dmi'
	SSj_Hair()




mob/proc
	ascension_mod()
		var/n=1.15 //account for mystic boost to ssj2
		n *= 1.1 //arbitrary
		if(Race=="Alien") n*=0.92
		if(Race=="Demigod") n*=1.1
		//if(Race=="Android") n*=1.15 //Androids dont ascend anymore as they have no base bp now only cyber bp
		if(Race=="Majin") n*=1.3
		if(Race=="Human")
			if(Class == "Spirit Doll") n *= 0.6
			else n *= 0.7
		if(Race=="Tsujin") n *= 0.8
		if(Race=="Kai") n *= 0.9
		if(Race=="Puranto") n *= 0.85
		return n

	AscendedBPMod()
		return base_ascension_mod * ascension_mod()

var
	base_ascension_mod = 14.85

mob/proc
	Ascension_BP_Req()
		return 0.5 * ascension_bp

proc/Ascension_loop()
	set waitfor=0
	while(1)
		for(var/mob/m in players) if(m.Race != "Android")
			if(m.Race && m.Race!="" && !(m.Race in list("Yasai", "Half Yasai")))
				if(m.effectiveBaseBp > m.Ascension_BP_Req())
					var/max_mod = base_ascension_mod * m.ascension_mod()
					if(m.bp_mod < max_mod)
						m.bp_mod = max_mod
						if(m.base_bp < 10000000 * m.ascension_mod())
							m.base_bp = 10000000 * m.ascension_mod()
		sleep(2*600)











mob/proc/has_ssj_req(mod=1)
	if(bp_tiers) return 1
	var/bp_needed = ssjat * 0.5 * mod
	if(BP > ssjat && effectiveBaseBp > bp_needed) return bp_needed

mob/proc/has_ssj2_req(mod=1)
	if(bp_tiers) return 1
	var/bp_needed = ssj2at * (1 / 2) * mod
	if(BP > ssj2at && effectiveBaseBp > bp_needed) return bp_needed

mob/proc/has_ssj3_req(mod=1)
	if(bp_tiers) return 1
	var/bp_needed = ssj3at * (1 / 3) * mod
	if(BP > ssj3at && effectiveBaseBp > bp_needed) return bp_needed

mob/proc/OldTransGraphicsNoWait()
	set waitfor=0
	Old_Trans_Graphics()

mob/proc/Old_Trans_Graphics()

	var/fxSpeedMult = 0.7

	var/epicTrans = (BPpcnt >= 150) || (ssj == 1 && ssjdrain < 160) || (ssj == 2 && ssj2drain < 160) || (ssj == 3 && ssj3drain < 160)
	if(!epicTrans) return //i think we should just insta-trans now
	Dust(src, end_size = 1, time = 35)
	player_view(10,src)<<'powerup.wav'
	spawn(3 * fxSpeedMult) while(transing)
		player_view(10,src)<<'Aura.ogg'
		sleep(41)
	for(var/mob/P in player_view(20,src)) P.ScreenShake(20,8)
	sleep(40 * fxSpeedMult)
	player_view(10,src)<<'kiblast.wav'
	Make_Shockwave(src,7,sw_icon_size=256)
	if(epicTrans)
		sleep(3 * fxSpeedMult)
		player_view(10,src)<<'kiblast.wav'
		Make_Shockwave(src,7,sw_icon_size=256)
		for(var/turf/T in TurfCircle(3,src)) T.Make_Damaged_Ground(1)
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
		for(var/turf/T in TurfCircle(5,src))
			T.Make_Damaged_Ground(1)
			if(prob(10 * fxSpeedMult)) sleep(1)

		for(var/mob/P in player_view(20,src)) P.ScreenShake(30,16)
		for(var/turf/T in view(8,src))
			T.Make_Damaged_Ground(1)
			if(prob(10 * fxSpeedMult)) sleep(1)
	player_view(10,src)<<sound('aura3.ogg',volume=20)
	var/I='Electric Yellow.dmi'
	I+=rgb(0,0,0,100)
	Make_Shockwave(src,7,I,sw_icon_size=256)
	if(epicTrans)
		sleep(3 * fxSpeedMult)
		Make_Shockwave(src,7,I,sw_icon_size=256)
		sleep(3 * fxSpeedMult)
		Make_Shockwave(src,7,sw_icon_size=256)
		sleep(3 * fxSpeedMult)
		Make_Shockwave(src,7,sw_icon_size=512)
		player_view(10,src)<<sound('wallhit.ogg',volume=25)
	if(epicTrans) BigCrater(loc)

proc/Make_Shockwave(mob/Origin,Range=7,Icon,sw_icon_size=256)
	set waitfor=0
	if(shockwaves_off) return
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

mob/var
	list
		ssj_opening
		ssj2_opening
		ssj3_opening
		ssj4_opening
	SSjAble
	SSj2Able
	ssj=0
	ssjat=1
	ssjdrain=150
	ssjmod=1
	ssj2=0
	ssj2at=1
	ssj2drain=150
	ssj2mod=1
	SSj3Able=0
	ssj3=0
	ssj3at=1
	ssj3drain=40
	ssj3mod=1
	ssjadd=10000000 //DONT CHANGE THESE HERE. CHANGE THEM IN ASSIGNSSJMULTS()
	ssj2add=50000000
	ssj3add=100000000
	form1x=1
	form2x=1
	form3x=1
	form4x=1
	ssj_power=0
	Form=0
	Form1Icon
	Form2Icon
	Form3Icon
	Form4Icon




/*
was:
	base 6x
	ssj 8.4x
	ssj2 11.76x
	ssj3 19.992x
	ssj4 14.7x

now:
	base 11
	ssj 13.2
	ssj2 15.84
	ssj3 20.6
*/
var
	Yasai_bp_mod_after_ssj = 11
	ssj_mults_ver = 3

	ssj4_anger_mult = 1
	ssj4_recov_mult = 1
	ssj4_speed_mult = 1.3
	ssj4_regen_mult = 1.5
	ssj4_powerup_mod = 0.5
	ssj4_bp_mult = 1.5

mob/var/ssj_mults_assigned = 0
mob/var/form_multiplier_overide=0
mob/proc/AssignSSjMults()
	if(form_multiplier_overide) return
	if(ssj_mults_assigned == ssj_mults_ver) return
	if(!(Race in list("Yasai", "Half Yasai"))) return

	if(ssj) Revert()

	ssjadd = 10000000
	ssj2add = 100000000
	ssj3add = 250000000

	if(Race == "Yasai")
		if(Class == "Legendary Yasai")
			form1x = 1.35 * 1.35
		else if(Class == "Elite")
			form1x=1.35
			form2x=1.35
			form3x=1.5
			form4x=form1x * form2x * ssj4_bp_mult
		else if(Class == "Low Class")
			form1x=1.35
			form2x=1.35
			form3x=1.5
			form4x=form1x*form2x*ssj4_bp_mult
		else
			form1x=1.35
			form2x=1.35
			form3x=1.5
			form4x=form1x*form2x*ssj4_bp_mult

	if(Race == "Half Yasai")
		form1x=1.35
		form2x=1.35
		form3x=1.5
		form4x=form1x*form2x*ssj4_bp_mult

	ssj_mults_assigned = ssj_mults_ver



mob/var/tmp/last_ssj_revert_or_retrans = 0 //world.realtime

mob/proc/Revert()
	SSj_Blue_Revert()
	SSG_Revert()
	if(Race=="Frost Lord") icer_Revert()
	else if(ssj>0&&!transing)
		if(is_ussj) USSj() //toggle
		if(ssj==1)
			ssj_bp_mult/=form1x
			ssj_power-=ssjadd
		else if(ssj==2)
			ssj_bp_mult/=form1x*form2x
			ssj_power-=ssjadd+ssj2add
		else if(ssj==3)
			ssj_bp_mult/=form1x*form2x*form3x
			ssj_power-=ssjadd+ssj2add
		if(ssj==4)
			ssj_power-=ssjadd+ssj2add
			recov/=ssj4_recov_mult
			Spd/=ssj4_speed_mult
			spdmod/=ssj4_speed_mult
			ssj_bp_mult/=form4x
			regen/=ssj4_regen_mult
		if(ssj_power<0) ssj_power=0
		if(ssj_bp_mult<1) ssj_bp_mult=1
		ssj=0
		SSj_Hair()
		Aura_Overlays()
		overlays-='SSj4 Overlay.dmi'
		if(powerup_obj && powerup_obj.Powerup==-1) powerup_obj.Powerup=0
		last_ssj_revert_or_retrans = world.realtime

mob/proc/SSj_Hair()
	overlays.Remove(hair,ssjhair,ussjhair,ssjfphair,ssj2hair,ssj3hair,ssj4hair, ssj_blue_hair,ssj_god_hair)
	overlays-='SSJ3 Mastered.dmi'
	if(ultra_instinct) overlays += hair
	else if(is_ssj_blue) overlays += ssj_blue_hair
	else if(is_ssg) overlays+= ssj_god_hair
	else
		if(!ssj||ismystic) overlays+=hair
		else if(ssj>0&&ssj<3&&is_ussj) overlays+=ussjhair
		else if(ssj==1 && !has_ss_full_power) overlays+=ssjhair
		else if(ssj==1) overlays+=ssjfphair
		else if(ssj==2) overlays+=ssj2hair
		else if(ssj==3)
			//if(ssj3hair=='Hair_GokuSSj3.dmi'&&ssj3drain>=300) overlays+='SSJ3 Mastered.dmi'
			//else overlays+=ssj3hair
			overlays+=ssj3hair
		else if(ssj==4) overlays+=ssj4hair
	/*var/T='Fox Tail.dmi'
	T+=rgb(120,120,60)
	overlays-=T
	if(Tail&&ssj&&ssj<4&&!ismystic) overlays+=T*/

mob/var/tmp/transing
mob/var/ssj_bp_mult=1

mob/proc/SSj() if(!transing&&!ssj&&!IsGreatApe())

	if(bp_mod < Yasai_bp_mod_after_ssj)
		var/mult = Yasai_bp_mod_after_ssj / bp_mod
		base_bp *= mult
		bp_mod = Yasai_bp_mod_after_ssj

	transing=1
	ssj=1
	last_ssj_revert_or_retrans = world.realtime
	if(!SSjAble) SSjAble=Year
	if(!ismystic && !ultra_instinct)
		if(ssj_opening) Trans_Graphics(ssj_opening)
		else Old_Trans_Graphics()
	SSj_Hair()
	ssj_bp_mult *= form1x
	ssj_power += ssjadd
	transing=0
	ssj_drain_loop()

mob/proc/SSj2() if(!transing&&ssj==1&&Class!="Legendary Yasai")
	if(is_ussj) USSj() //revert ussj...
	transing=1
	ssj=2
	last_ssj_revert_or_retrans = world.realtime
	if(!SSj2Able) SSj2Able=Year
	if(!ismystic && !ultra_instinct)
		if(ssj2_opening) Trans_Graphics(ssj2_opening)
		else Old_Trans_Graphics()
	SSj_Hair()
	ssj_bp_mult*=form2x
	ssj_power+=ssj2add
	transing=0

mob/proc/SSj3() if(!transing&&ssj==2)
	transing=1
	ssj=3
	last_ssj_revert_or_retrans = world.realtime
	if(!SSj3Able) SSj3Able=Year

	if(!ultra_instinct)
		if(ssj3_opening) Trans_Graphics(ssj3_opening)
		else Old_Trans_Graphics()

	SSj_Hair()
	ssj_bp_mult*=form3x
	transing=0
mob/var
	SSj4Able
	ssj4hair

var/obj/ssj4_desc

obj/Super_Yasai_4_Description
	New()
		ssj4_desc=src
		desc="\
		Super Yasai 4 has the following effects:<br>\
		[ssj4_bp_mult]x more BP than SSj2<br>\
		[ssj4_anger_mult]x anger boost decrease<br>\
		[ssj4_speed_mult]x speed increase<br>\
		[ssj4_regen_mult]x regeneration increase<br>\
		[ssj4_recov_mult]x recovery decrease<br>\
		[ssj4_powerup_mod]x powerup rate<br>\
		"

mob/proc/SSj4() if(!IsGreatApe() && !transing && !ssj && !ismystic)
	if(Race=="Half Yasai") return
	if(IsGod()) return
	transing=1
	ssj=4
	if(ssj4_opening) Trans_Graphics(ssj4_opening)
	else Old_Trans_Graphics()
	if(!SSj4Able) SSj4Able=Year
	ssj_bp_mult*=form4x
	ssj_power+=ssjadd+ssj2add
	Spd*=ssj4_speed_mult
	spdmod*=ssj4_speed_mult
	recov*=ssj4_recov_mult
	regen*=ssj4_regen_mult
	transing=0
	var/list/Old_Overlays=new
	overlays-=hair
	Old_Overlays.Add(overlays)
	overlays-=overlays
	overlays+='SSj4 Overlay.dmi'
	overlays+=Old_Overlays
	SSj_Hair()

mob/proc/Frost_Lord_Forms() if(Race=="Frost Lord")
	if(Form == 3) PowerUpToGoldForm()
	if(Form==2)
		Form=3
		recov/=icer_recovery
		icon=Form4Icon
		//overlays-=overlays
	if(Form==1)
		Form=2
		recov/=icer_recovery
		icon=Form3Icon
		//overlays-=overlays
	if(!Form)
		Form=1
		recov/=icer_recovery
		icon=Form2Icon
		//overlays-=overlays

mob/proc/Frost_Lord_Form_Addition(form)
	var/N=0
	var/bp = effectiveBaseBp
	if(!form) form = Form
	var/bp_add = 0

	//300k base to 421k to 605k to 802k
	//530k base to 1.2 mil to 3 mil to 9 mil.

	if(form >= 1)
		var/peak_add = 670000
		var/peak_at = 530000

		var/exponent = 1
		if(bp < peak_at) exponent = 3
		else exponent = 0.7

		N = peak_add * ((bp / peak_at) ** exponent) //Means +peak_add bp at peak_at base bp
		if(N > peak_add) N = peak_add
		if(N < bp * icer_form1_mult || bp_tiers) N = bp * icer_form1_mult
		if(N < 1000) N = 1000
		N *= bp_mult
		bp_add += N

	if(form >= 2)
		var/peak_add = 2300000
		var/peak_at = 530000

		var/exponent = 1
		if(bp < peak_at) exponent = 4
		else exponent = 0.6

		N = peak_add * ((bp / peak_at) ** exponent) //Means +peak_add bp at peak_at base bp
		if(N > peak_add) N = peak_add
		if(N < bp * icer_form1_mult || bp_tiers) N = bp * icer_form1_mult
		if(N < 1500) N = 1500
		N *= bp_mult
		bp_add += N

	if(form >= 3)
		var/peak_add = 5500000
		var/peak_at = 530000

		var/exponent = 1
		if(bp < peak_at) exponent = 6
		else exponent = 0.5

		N = peak_add * ((bp / peak_at) ** exponent) //Means +peak_add bp at peak_at base bp
		if(N > peak_add) N = peak_add
		if(N < bp * icer_form1_mult || bp_tiers) N = bp * icer_form1_mult
		if(N < 2000) N = 2000
		N *= bp_mult
		bp_add += N

	return bp_add


mob/proc/icer_Revert()
	if(is_gold_form)
		GoldFormRevert()
		return
	if(Form) if(powerup_obj&&powerup_obj.Powerup==-1) powerup_obj.Powerup=0
	if(Form==1)
		icon=Form1Icon
		Form=0
		recov*=icer_recovery
	if(Form==2)
		icon=Form2Icon
		Form=1
		recov*=icer_recovery
	if(Form==3)
		icon=Form3Icon
		Form=2
		recov*=icer_recovery

mob/var/third_eye

obj/Third_Eye
	teachable=0
	hotbar_type="Buff"
	can_hotbar=1
	Skill=1
	Cost_To_Learn=10
	Teach_Timer=10
	student_point_cost = 50
	desc="This unlocks your 3rd Eye Chakra. x1.2 BP, x2 meditation bp, x2 skill mastery, /5 zenkai"
	var/Next_Use=0
	Del()
		var/mob/M=loc
		if(ismob(M)) M.Third_Eye_Revert()
		. = ..()

	verb/Hotbar_use()
		set hidden=1
		Toggle_Third_Eye()

	verb/Toggle_Third_Eye()
		set category="Skills"
		if(usr.Is_Cybernetic())
			usr<<"Cyborgs cannot use this ability"
			return
		//if(world.realtime<Next_Use)
		//	usr<<"You can not use this again for another [round((Next_Use-world.realtime)/10/60/60,0.01)] hours"
		//	return
		if(usr.Redoing_Stats) return
		Next_Use=world.realtime+(1*60*60*10)
		if(!usr.third_eye)
			usr.Third_Eye()
			usr << desc
			usr << "You are now using the Third Eye buff"
		else
			usr.Third_Eye_Revert()

var
	thirdEyeMasteryMult = 2

mob/proc/Third_Eye()
	if(third_eye) return
	third_eye = 1
	Calm()
	bp_mult+=0.2
	med_mod*=2
	mastery_mod*=thirdEyeMasteryMult
	zenkai_mod/=5
	overlays+='Third Eye.dmi'
	src<<"You concentrate on the power of your mind and unlock your third eye chakra, increasing your \
	power significantly."
	if(gravity_mastered<5) gravity_mastered=5

mob/proc/Third_Eye_Revert()
	if(!third_eye) return
	third_eye = 0
	bp_mult-=0.2
	med_mod/=2
	mastery_mod/=thirdEyeMasteryMult
	zenkai_mod*=5
	overlays-='Third Eye.dmi'
	src<<"You repress the power of your third eye chakra."

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
mob/var
	ssj_leechable=1
	ssj_inspired=0 //set to 1 to queue you to go ssj on next regular anger cuz your inspired
var/ssj_inspire_timer=3600

mob/proc/ssj_inspire_loop()
	set waitfor=0
	sleep(ssj_inspire_timer)
	while(src)
		if(!ssj_leechable||Class=="Legendary Yasai") return
		if(ssj&&inspire_allowed) for(var/mob/m in player_view(15,src)) if(m.Opponent(65) == src)
			if(m.client&&(m.Race in list("Yasai","Half Yasai"))&&m.ssj_inspired<ssj)
				if((ssj>=1&&!m.SSjAble)||(ssj>=2&&!m.SSj2Able)||(ssj>=3&&!m.SSj3Able))
					if(1) //if(m.base_bp>=base_bp*0.8||bp_tiers)
						//m<<"<font color=cyan>[src] has inspired you to work harder to achieve Super Yasai"
						m.ssj_inspired=ssj
		sleep(ssj_inspire_timer)

mob/var/tmp/ssj_drain_looping

mob/var/lssj_ver=0

var/lssj_mystic_drain_reduction = 0.5

mob/proc/ssj_drain_loop()
	set waitfor=0
	if(ssj_drain_looping) return
	ssj_drain_looping=1
	while(ssj)
		var/Amount=3
		var/Drain_Multiplier=0.3*Amount
		if(ssj)
			if(Class=="Legendary Yasai")
				ssjdrain=500 //so they get that 30% ssj_power() boost from mastered ssj1

				if(lssj_ver==0)
					lssj_ver=1
					ssjadd=1

				if(ssj==1) ssjadd=Clamp(Avg_BP * 0.2, ssjadd, 65000000)
				//var/Drain=max_ki/120*(3000/max_ki)**0.3

				var/Drain=(max_ki/160) * Drain_Multiplier * (3500/max_ki)**0.4
				if(lssj_always_angry) Drain *= 0.6

				if(ismystic) Drain*=lssj_mystic_drain_reduction
				if(Ki>Drain*10&&Drain) Ki-=Drain
				else if(Drain)
					Revert()
					player_view(15,src)<<"[src] reverts due to exhaustion"
			else
				if(ssj in list(1,2,3))
					var/Mastery=0.01 * ssjmod * Amount * SSj_Mastery
					if(z==10||(world.maxz==2&&z==2)) Mastery *= 10
					if(hero==key) Mastery*=2
					ssjdrain += Mastery
					var/should_get_mssj
					if(world.realtime - last_ssj_revert_or_retrans > 15 * 600) should_get_mssj = 1
					if(z == 10 && world.realtime - last_ssj_revert_or_retrans > 5 * 600) should_get_mssj = 1
					if(should_get_mssj && !has_ss_full_power)
						has_ss_full_power = 1
						ssjdrain = 300
						NoWaitAlert("You have mastered Super Yasai")
					var/Drain=(max_ki/ssjdrain)*Drain_Multiplier * (3500/max_ki)**0.4
					if(ssjdrain>=300||ismystic) Drain=0
					if(Ki>Drain*10&&Drain) Ki-=Drain
					else if(Drain)
						Revert()
						player_view(15,src)<<"[src] reverts due to exhaustion"

				if(ssj in list(2,3))
					var/Mastery=0.01*ssj2mod*Amount*SSj_Mastery
					if(z==10 || (world.maxz==2 && z==2)) Mastery*=10
					if(hero==key) Mastery *= 2
					ssj2drain+=Mastery
					if(ssj2drain >= 300 && ssj2drain - Mastery < 300)
						NoWaitAlert("You have mastered Super Yasai 2")
					var/Drain=(max_ki/ssj2drain)*Drain_Multiplier
					var/min_drain = 180
					if(Drain < max_ki/min_drain) Drain=max_ki/min_drain
					Drain*=(3500/max_ki)**0.4
					if(ismystic) Drain=0
					if(Ki>Drain*10&&Drain) Ki-=Drain
					else if(Drain)
						Revert()
						player_view(15,src)<<"[src] reverts due to exhaustion"

				if(ssj in list(3))
					var/Mastery=0.04*ssj3mod*Amount*SSj_Mastery
					if(z==10||(world.maxz==2&&z==2)) Mastery*=10
					if(hero==key) Mastery*=2
					ssj3drain+=Mastery
					if(ssj3drain >= 300 && ssj3drain - Mastery < 300)
						NoWaitAlert("You have mastered Super Yasai 3")
					var/Drain=(max_ki/ssj3drain)*Drain_Multiplier

					var/min_drain = 150
					if(Drain<max_ki/min_drain) Drain=max_ki/min_drain

					Drain*=(3500/max_ki)**0.4
					if(Ki>Drain*10&&Drain) Ki-=Drain
					else if(Drain)
						Revert()
						player_view(15,src)<<"[src] reverts due to exhaustion"
		sleep(Amount*10)
	ssj_drain_looping=0

mob/proc
	NoWaitAlert(txt)
		set waitfor=0
		alert(src, txt)
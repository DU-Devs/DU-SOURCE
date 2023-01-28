mob/proc/has_ssj_req(mod=1)
	if(bp_tiers) return 1
	var/bp_needed=ssjat*(2/3)*mod
	if(BP>ssjat&&base_bp+hbtc_bp>bp_needed) return bp_needed
mob/proc/has_ssj2_req(mod=1)
	if(bp_tiers) return 1
	var/bp_needed=ssj2at*(1/4)*mod
	if(BP>ssj2at&&base_bp+hbtc_bp>bp_needed) return bp_needed
mob/proc/has_ssj3_req(mod=1)
	if(bp_tiers) return 1
	var/bp_needed=ssj3at*(1/8)*mod
	if(BP>ssj3at&&base_bp+hbtc_bp>bp_needed) return bp_needed
mob/proc/Old_Trans_Graphics()
	view(10,src)<<'powerup.wav'
	spawn(3) while(transing)
		view(10,src)<<'Aura.ogg'
		sleep(41)
	for(var/mob/P in player_view(20,src)) spawn if(P) P.Screen_Shake(20,8)
	sleep(40)
	view(10,src)<<'kiblast.wav'
	Make_Shockwave(src,7,sw_icon_size=256)
	if((ssj==1&&ssjdrain<155)||(ssj==2&&ssj2drain<155)||(ssj==3&&ssj3drain<155))
		sleep(3)
		view(10,src)<<'kiblast.wav'
		Make_Shockwave(src,7,sw_icon_size=256)
		for(var/turf/T in Turf_Circle(3,src)) T.Make_Damaged_Ground(1)
		sleep(30)
		for(var/mob/P in player_view(20,src)) spawn if(P) P.Screen_Shake(10,16)
		view(10,src)<<'kiblast.wav'
		Make_Shockwave(src,7,sw_icon_size=256)
		sleep(3)
		view(10,src)<<'kiblast.wav'
		Make_Shockwave(src,7,sw_icon_size=256)
		sleep(3)
		view(10,src)<<'kiblast.wav'
		Make_Shockwave(src,7,sw_icon_size=256)
		sleep(3)
		view(10,src)<<'kiblast.wav'
		Make_Shockwave(src,7,sw_icon_size=256)
		for(var/turf/T in Turf_Circle(5,src))
			T.Make_Damaged_Ground(1)
			//if(prob(30)) Dust(T,1)
			if(prob(10)) sleep(1)
		for(var/turf/T in view(7,src)) if(prob(5)) T.Rising_Rocks()
		for(var/mob/P in player_view(20,src)) spawn if(P) P.Screen_Shake(30,16)
		for(var/turf/T in view(8,src))
			T.Make_Damaged_Ground(1)
			//if(prob(15)) Dust(T,1)
			if(prob(10)) sleep(1)
	player_view(10,src)<<sound('aura3.ogg',volume=20)
	var/I='Electric Yellow.dmi'
	I+=rgb(0,0,0,100)
	Make_Shockwave(src,7,I,sw_icon_size=256)
	if((ssj==1&&ssjdrain<155)||(ssj==2&&ssj2drain<155)||(ssj==3&&ssj3drain<155))
		sleep(3)
		Make_Shockwave(src,7,I,sw_icon_size=256)
		sleep(3)
		Make_Shockwave(src,7,sw_icon_size=256)
		sleep(3)
		Make_Shockwave(src,7,sw_icon_size=512)
		player_view(10,src)<<sound('wallhit.ogg',volume=25)
		Dust(src,10)
	for(var/turf/T in view(1,src)) Dust(T,2)
	Big_crater(loc)
proc/Make_Shockwave(mob/Origin,Range=7,Icon,sw_icon_size=256)
	if(Origin)
		if(Icon) for(var/turf/T in Turf_Circle(Range,Origin)) Missile(Icon,Origin,T)
		else
			if(!(sw_icon_size in list(64,128,256,512))) return
			var/obj/Shockwave_Graphic/g=Get_shockwave_graphic()
			g.loc=Origin.True_Loc()
			g.Shockwave_go(sw_icon_size)
proc/Get_shockwave_graphic()
	for(var/obj/o in shockwave_graphics)
		shockwave_graphics-=o
		return o
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
	Del()
		shockwave_graphics-=src
		shockwave_graphics+=src
		loc=null
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
mob/proc/Screen_Shake(Amount=10,Offset=12) spawn while(Amount&&src&&client)
	Amount--
	client.pixel_x=rand(-Offset,Offset)
	client.pixel_y=rand(-Offset,Offset)
	if(Amount<=0)
		client.pixel_x=0
		client.pixel_y=0
	sleep(1)
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
	ssjadd=10000000
	ssj2add=50000000
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
mob/proc/Revert()
	if(Race=="Icer") Icer_Revert()
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
mob/proc/SSj_Hair()
	overlays.Remove(hair,ssjhair,ussjhair,ssjfphair,ssj2hair,ssj3hair,ssj4hair)
	overlays-='SSJ3 Mastered.dmi'
	if(!ssj||ismystic) overlays+=hair
	else if(ssj>0&&ssj<3&&is_ussj) overlays+=ussjhair
	else if(ssj==1&&ssjdrain<300) overlays+=ssjhair
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
mob/proc/SSj() if(!transing&&!ssj&&!Is_oozaru())
	if(bp_mod<6)
		var/mult=6/bp_mod
		base_bp*=mult
		bp_mod=6
	transing=1
	ssj=1
	if(!SSjAble) SSjAble=Year
	if(!ismystic)
		if(ssj_opening) Trans_Graphics(ssj_opening)
		else Old_Trans_Graphics()
	SSj_Hair()
	ssj_bp_mult*=form1x
	ssj_power+=ssjadd
	transing=0
	ssj_drain_loop()
mob/proc/SSj2() if(!transing&&ssj==1&&Class!="Legendary Saiyan")
	if(is_ussj) USSj() //revert ussj...
	transing=1
	ssj=2
	if(!SSj2Able) SSj2Able=Year
	if(!ismystic)
		if(ssj2_opening) Trans_Graphics(ssj2_opening)
		else Old_Trans_Graphics()
	SSj_Hair()
	ssj_bp_mult*=form2x
	ssj_power+=ssj2add
	transing=0
mob/proc/SSj3() if(!transing&&ssj==2)
	transing=1
	ssj=3
	if(!SSj3Able) SSj3Able=Year
	if(ssj3_opening) Trans_Graphics(ssj3_opening)
	else Old_Trans_Graphics()
	SSj_Hair()
	ssj_bp_mult*=form3x
	transing=0
mob/var
	SSj4Able
	ssj4hair

var
	ssj4_anger_mult=0.5
	ssj4_recov_mult=0.7
	ssj4_speed_mult=1.25
	ssj4_regen_mult=2
	ssj4_bp_mult=1.25

obj/Super_Saiyan_4_Description
	New()
		desc="\
		Super Saiyan 4 has the following effects:<br>\
		[ssj4_bp_mult]x more BP than SSj2<br>\
		[ssj4_anger_mult]x anger boost decrease<br>\
		[ssj4_speed_mult]x speed increase<br>\
		[ssj4_regen_mult]x regeneration increase<br>\
		[ssj4_recov_mult]x recovery decrease<br>\
		"

mob/proc/SSj4() if(!transing&&!ssj&&!ismystic)
	if(Race=="Half Saiyan") return
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
mob/proc/Icer_Forms() if(Race=="Icer")
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
mob/var
	icer_form1_mult=0.1
	icer_form2_mult=0.2
	icer_form3_mult=0.3
mob/proc/Icer_Form_Addition()
	var/N=0
	var/bp=base_bp+hbtc_bp
	if(Form==1)
		N=470000*((bp/530000)**1.3) //Means +470k at 530k base bp
		/*
		470000*((100000/530000)**1) = 88680
		470000*((100000/530000)**2) = 16731
		470000*((100000/530000)**3) = 3156
		*/
		if(N>470000) N=470000
		if(N<bp*icer_form1_mult||bp_tiers) N=bp*icer_form1_mult
		if(N<1000) N=1000
		N*=bp_mult
		return N
	if(Form==2)
		N=2470000*((bp/530000)**2.1)
		/*
		2470000*((100000/530000)**1) = 466000
		2470000*((100000/530000)**2) = 88000
		2470000*((100000/530000)**2.5) = 38200
		2470000*((100000/530000)**3) = 16600
		*/
		if(N>2470000) N=2470000
		if(N<bp*icer_form2_mult||bp_tiers) N=bp*icer_form2_mult
		if(N<1500) N=1500
		N*=bp_mult
		return N
	if(Form==3)
		N=7470000*((bp/530000)**2.2)
		/*
		7470000*((100000/530000)**1) = 1407000
		7470000*((100000/530000)**2) = 266000
		7470000*((100000/530000)**2.5) = 115000
		7470000*((100000/530000)**3) = 50100
		*/
		if(N>7470000) N=7470000
		if(N<bp*icer_form3_mult||bp_tiers) N=bp*icer_form3_mult
		if(N<2000) N=2000
		N*=bp_mult
		return N
mob/proc/Icer_Revert()
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
obj/Third_Eye
	teachable=0
	hotbar_type="Buff"
	can_hotbar=1
	Skill=1
	Cost_To_Learn=10
	Teach_Timer=10
	desc="This unlocks your 3rd Eye Chakra. x1.2 BP, x2 meditation bp, x2 skill mastery, /5 zenkai"
	var/Next_Use=0
	Del()
		var/mob/M=loc
		if(ismob(M)) M.Third_Eye_Revert()
		..()
	verb/Hotbar_use()
		set hidden=1
		Third_Eye()
	verb/Third_Eye()
		set category="Skills"
		if(usr.Is_Cybernetic())
			usr<<"Cyborgs cannot use this ability"
			return
		if(world.realtime<Next_Use)
			usr<<"You can not use this again for another [round((Next_Use-world.realtime)/10/60/60,0.01)] hours"
			return
		if(usr.Redoing_Stats) return
		Next_Use=world.realtime+(1*60*60*10)
		if(!Using)
			usr.Third_Eye()
			Using=1
		else
			usr.Third_Eye_Revert()
			Using=0
mob/proc/Third_Eye()
	Calm()
	bp_mult+=0.2
	med_mod*=2
	mastery_mod*=2
	zenkai_mod/=5
	overlays+='Third Eye.dmi'
	src<<"You concentrate on the power of your mind and unlock your third eye chakra, increasing your \
	power significantly."
	if(gravity_mastered<5) gravity_mastered=5
mob/proc/Third_Eye_Revert() for(var/obj/Third_Eye/T in src) if(T.Using)
	bp_mult-=0.2
	med_mod/=2
	mastery_mod/=2
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

mob/proc/ssj_inspire_loop() spawn(ssj_inspire_timer) while(src)
	if(!ssj_leechable||Class=="Legendary Saiyan") return
	if(ssj&&inspire_allowed) for(var/mob/m in player_view(15,src)) if(m.Opponent==src)
		if(m.client&&(m.Race in list("Saiyan","Half Saiyan"))&&m.ssj_inspired<ssj)
			if((ssj>=1&&!m.SSjAble)||(ssj>=2&&!m.SSj2Able)||(ssj>=3&&!m.SSj3Able))
				if(1) //if(m.base_bp>=base_bp*0.8||bp_tiers)
					m<<"<font color=cyan>[src] has inspired you to work harder to achieve super saiyan"
					m.ssj_inspired=ssj
	sleep(ssj_inspire_timer)

mob/var/tmp/ssj_drain_looping

mob/var/lssj_ver=0

mob/proc/ssj_drain_loop() spawn if(src)
	if(ssj_drain_looping) return
	ssj_drain_looping=1
	while(ssj)
		var/Amount=3
		var/Drain_Multiplier=0.3*Amount
		if(ssj)
			if(Class=="Legendary Saiyan")
				ssjdrain=500 //so they get that 30% ssj_power() boost from mastered ssj1

				if(lssj_ver==0)
					lssj_ver=1
					ssjadd=1

				if(ssj==1) ssjadd=Clamp(Avg_BP*0.25,ssjadd,50000000)
				//var/Drain=max_ki/120*(3000/max_ki)**0.3

				var/Drain=(max_ki/120) * Drain_Multiplier * (3500/max_ki)**0.4

				if(ismystic) Drain=0
				if(Ki>Drain*10&&Drain) Ki-=Drain
				else if(Drain)
					Revert()
					player_view(15,src)<<"[src] reverts due to exhaustion"
			else
				if(ssj in list(1,2,3))
					var/Mastery=0.01*ssjmod*Amount*SSj_Mastery
					if(z==10||(world.maxz==2&&z==2)) Mastery*=7
					if(hero==key) Mastery*=2
					ssjdrain+=Mastery
					var/Drain=(max_ki/ssjdrain)*Drain_Multiplier * (3500/max_ki)**0.4
					if(ssjdrain>=300||ismystic) Drain=0
					if(Ki>Drain*10&&Drain) Ki-=Drain
					else if(Drain)
						Revert()
						player_view(15,src)<<"[src] reverts due to exhaustion"
				if(ssj in list(2,3))
					var/Mastery=0.01*ssj2mod*Amount*SSj_Mastery
					if(z==10||(world.maxz==2&&z==2)) Mastery*=7
					if(hero==key) Mastery*=2
					ssj2drain+=Mastery
					var/Drain=(max_ki/ssj2drain)*Drain_Multiplier
					if(Drain<max_ki/150) Drain=max_ki/150
					Drain*=(3500/max_ki)**0.4
					if(ismystic) Drain=0
					if(Ki>Drain*10&&Drain) Ki-=Drain
					else if(Drain)
						Revert()
						player_view(15,src)<<"[src] reverts due to exhaustion"
				if(ssj in list(3))
					var/Mastery=0.04*ssj3mod*Amount*SSj_Mastery
					if(z==10||(world.maxz==2&&z==2)) Mastery*=7
					if(hero==key) Mastery*=2
					ssj3drain+=Mastery
					var/Drain=(max_ki/ssj3drain)*Drain_Multiplier
					if(Drain<max_ki/72) Drain=max_ki/72
					Drain*=(3500/max_ki)**0.4
					if(Ki>Drain*10&&Drain) Ki-=Drain
					else if(Drain)
						Revert()
						player_view(15,src)<<"[src] reverts due to exhaustion"
		sleep(Amount*10)
	ssj_drain_looping=0
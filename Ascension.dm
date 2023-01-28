mob/proc/Old_Trans_Graphics()
	view(10,src)<<'powerup.wav'
	spawn(3) while(transing)
		view(10,src)<<'Aura.ogg'
		sleep(41)
	for(var/mob/P in view(10,src)) spawn P.Screen_Shake(20,8)
	sleep(40)
	view(10,src)<<'kiblast.wav'
	Make_Shockwave(src,7)
	if((ssj==1&&ssjdrain<155)||(ssj==2&&ssj2drain<155)||(ssj==3&&ssj3drain<155))
		sleep(3)
		view(10,src)<<'kiblast.wav'
		Make_Shockwave(src,7)
		for(var/turf/T in view(1,src)) T.Make_Damaged_Ground(1)
		sleep(30)
		for(var/mob/P in view(10,src)) spawn P.Screen_Shake(10,16)
		view(10,src)<<'kiblast.wav'
		Make_Shockwave(src,7)
		sleep(3)
		view(10,src)<<'kiblast.wav'
		Make_Shockwave(src,7)
		sleep(3)
		view(10,src)<<'kiblast.wav'
		Make_Shockwave(src,7)
		sleep(3)
		view(10,src)<<'kiblast.wav'
		Make_Shockwave(src,7)
		for(var/turf/T in view(4,src))
			T.Make_Damaged_Ground(1)
			if(prob(50)) Dust(T,1)
			if(prob(10)) sleep(1)
		for(var/turf/T in view(7,src)) if(prob(5)) T.Rising_Rocks()
		for(var/mob/P in view(10,src)) spawn P.Screen_Shake(30,16)
		for(var/turf/T in view(8,src))
			if(prob(30)) T.Make_Damaged_Ground(1)
			if(prob(30)) Dust(T,1)
			if(prob(10)) sleep(1)
	view(10,src)<<sound('aura3.ogg',volume=20)
	var/I='Electric Yellow.dmi'
	I+=rgb(0,0,0,100)
	Make_Shockwave(src,7,I)
	if((ssj==1&&ssjdrain<155)||(ssj==2&&ssj2drain<155)||(ssj==3&&ssj3drain<155))
		sleep(3)
		Make_Shockwave(src,7,I)
		sleep(3)
		Make_Shockwave(src,7)
		sleep(3)
		Make_Shockwave(src,7)
		view(10,src)<<sound('wallhit.ogg',volume=40)
		Dust(src,30)
	for(var/turf/T in view(1,src)) Dust(T,10)
	new/obj/BigCrater(loc)
proc/Make_Shockwave(mob/Origin,Range=7,Icon='Shockwave.dmi')
	if(Origin) for(var/turf/T in Turf_Circle(Origin,Range)) missile(Icon,Origin,T)
	//if(Origin) for(var/turf/T in range(Origin,Range)) missile(Icon,Origin,T)
mob/proc/Screen_Shake(Amount=10,Offset=12) spawn while(Amount&&src&&client)
	Amount-=1
	client.pixel_x=rand(-Offset,Offset)
	client.pixel_y=rand(-Offset,Offset)
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
	ssj3drain=100
	ssj3mod=1
	ssjadd=10000000
	ssj2add=40000000
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
	if(Race=="Frost Lord") Icer_Revert()
	else if(ssj>0&&!transing)
		if(ssj==1)
			Recovery*=2
			BP_Multiplier/=form1x
			ssj_power-=ssjadd
		else if(ssj==2)
			Recovery*=2
			BP_Multiplier/=form1x*form2x
			ssj_power-=ssjadd+ssj2add
		else if(ssj==3)
			Recovery*=2
			BP_Multiplier/=form1x*form2x*form3x
			ssj_power-=ssjadd+ssj2add
		if(ssj==4)
			ssj_power-=ssjadd+ssj2add
			Recovery*=10
			Spd/=2
			SpdMod/=2
			BP_Multiplier/=form4x
			Max_Anger*=10
			Regeneration*=0.5
		if(ssj_power<0) ssj_power=0
		ssj=0
		Omega_Hair()
		Aura_Overlays()
		overlays-='SSj4 Overlay.dmi'
		for(var/obj/Power_Control/P in src) if(P.Powerup==-1) P.Powerup=0
mob/proc/Omega_Hair()
	overlays.Remove(hair,ssjhair,ussjhair,ssjfphair,ssj2hair,ssj3hair,ssj4hair)
	if(!ssj||ismystic) overlays+=hair
	else if(ssj==1&&ssjdrain<300) overlays+=ssjhair
	else if(ssj==1) overlays+=ssjfphair
	else if(ssj==2) overlays+=ssj2hair
	else if(ssj==3) overlays+=ssj3hair
	else if(ssj==4) overlays+=ssj4hair
	/*var/T='Fox Tail.dmi'
	T+=rgb(120,120,60)
	overlays-=T
	if(Tail&&ssj&&ssj<4&&!ismystic) overlays+=T*/
mob/var/tmp/transing
mob/proc/SSj() if(!transing&&!ssj&&!Is_Werewolf())
	transing=1
	ssj=1
	if(!SSjAble) SSjAble=Year
	if(!ismystic)
		if(ssj_opening) Trans_Graphics(ssj_opening)
		else Old_Trans_Graphics()
	Omega_Hair()
	BP_Multiplier*=form1x
	ssj_power+=ssjadd
	Recovery/=2
	transing=0
mob/proc/SSj2() if(!transing&&ssj==1&&Class!="Legendary Yasai")
	transing=1
	ssj=2
	if(!SSj2Able) SSj2Able=Year
	if(!ismystic)
		if(ssj2_opening) Trans_Graphics(ssj2_opening)
		else Old_Trans_Graphics()
	Omega_Hair()
	BP_Multiplier*=form2x
	ssj_power+=ssj2add
	transing=0
mob/proc/SSj3() if(!transing&&ssj==2)
	transing=1
	ssj=3
	if(!SSj3Able) SSj3Able=Year
	if(ssj3_opening) Trans_Graphics(ssj3_opening)
	else Old_Trans_Graphics()
	Omega_Hair()
	BP_Multiplier*=form3x
	transing=0
mob/var
	SSj4Able
	ssj4hair
mob/proc/SSj4() if(!transing&&!ssj)
	transing=1
	ssj=4
	if(ssj4_opening) Trans_Graphics(ssj4_opening)
	else Old_Trans_Graphics()
	if(!SSj4Able) SSj4Able=Year
	BP_Multiplier*=form4x
	ssj_power+=ssjadd+ssj2add
	Spd*=2
	SpdMod*=2
	Recovery*=0.1
	Max_Anger*=0.1
	Regeneration*=2
	transing=0
	var/list/Old_Overlays=new
	overlays-=hair
	Old_Overlays.Add(overlays)
	overlays-=overlays
	overlays+='SSj4 Overlay.dmi'
	overlays+=Old_Overlays
	Omega_Hair()
mob/proc/Icer_Forms() if(Race=="Frost Lord")
	if(Form==2)
		Form=3
		//BP_Multiplier*=form3x
		Recovery/=Icer_Recovery
		icon=Form4Icon
		overlays-=overlays
	if(Form==1)
		Form=2
		//BP_Multiplier*=form2x
		Recovery/=Icer_Recovery
		icon=Form3Icon
		overlays-=overlays
	if(!Form)
		Form=1
		//BP_Multiplier*=form1x
		Recovery/=Icer_Recovery
		icon=Form2Icon
		overlays-=overlays
mob/var
	icer_form1_mult=0.1
	icer_form2_mult=0.2
	icer_form3_mult=0.3
mob/proc/Icer_Form_Addition()
	var/N=2 //Higher = boost scales more to base bp
	if(Form==1)
		N=470000*((Base_BP/530000)**N) //Means +470k at 530k base bp
		if(N>1000000) N=1000000
		if(N<Base_BP*icer_form1_mult) N=Base_BP*icer_form1_mult
		N*=BP_Multiplier
		return N
	if(Form==2)
		N=2470000*((Base_BP/530000)**N)*BP_Multiplier
		if(N>4000000) N=4000000
		if(N<Base_BP*icer_form2_mult) N=Base_BP*icer_form2_mult
		N*=BP_Multiplier
		return N
	if(Form==3)
		N=7470000*((Base_BP/530000)**N)*BP_Multiplier
		if(N>8000000) N=8000000
		if(N<Base_BP*icer_form3_mult) N=Base_BP*icer_form3_mult
		N*=BP_Multiplier
		return N
mob/proc/Icer_Revert()
	if(Form) for(var/obj/Power_Control/P in src) if(P.Powerup==-1) P.Powerup=0
	if(Form==1)
		icon=Form1Icon
		Form=0
		//BP_Multiplier/=form1x
		Recovery*=Icer_Recovery
	if(Form==2)
		icon=Form2Icon
		Form=1
		//BP_Multiplier/=form2x
		Recovery*=Icer_Recovery
	if(Form==3)
		icon=Form3Icon
		Form=2
		//BP_Multiplier/=form3x
		Recovery*=Icer_Recovery
obj/Third_Eye
	teachable=0
	Skill=1
	Cost_To_Learn=10
	Teach_Timer=10
	desc="This unlocks your 3rd Eye Chakra. x1.3 BP, x2 meditation bp, x2 skill mastery, /5 zenkai, zero anger."
	var/Next_Use=0
	Del()
		var/mob/M=loc
		if(ismob(M)) M.Third_Eye_Revert()
		..()
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
	BP_Multiplier*=1.3
	Meditation_Rate*=2
	Mastery_Mod*=2
	Zenkai_Rate/=5
	overlays+='Third Eye.dmi'
	src<<"You concentrate on the power of your mind and unlock your third eye chakra, increasing your power significantly."
	if(Gravity_Mastered<5) Gravity_Mastered=5
mob/proc/Third_Eye_Revert() for(var/obj/Third_Eye/T in src) if(T.Using)
	BP_Multiplier/=1.3
	Meditation_Rate/=2
	Mastery_Mod/=2
	Zenkai_Rate*=5
	overlays-='Third Eye.dmi'
	src<<"You repress the power of your third eye chakra."
area/proc/Omega_Darkness()
	var/A=icon
	icon='Weather.dmi'
	icon_state="Omega Darkness"
	spawn(600) if(src)
		icon=A
		icon_state=null
mob/proc/Omega_Lightning()
	var/Amount=10
	var/list/Locs=new
	for(var/turf/B in range(20,src)) Locs+=B
	while(Amount)
		Amount-=1
		var/obj/Lightning_Strike/A=new
		A.loc=pick(Locs)
		sleep(rand(1,50))
mob/var/SSj_Leechable
mob/proc/Omega_Yasai_Loop() while(src)
	var/Amount=3
	var/Drain_Multiplier=0.2*Amount
	if(ssj)
		if(prob(1*Amount)&&SSj_Leechable) for(var/mob/A in oview(src)) if(A.client&&A.Race=="Yasai"&&Base_BP*0.5<A.Base_BP)
			if(!A.SSjAble)
				A.SSjAble=Year+rand(0,5)
				A<<"<font color=yellow>[src] has inspired you to work harder to achieve Omega Yasai"
			if(ssj==2&&!A.SSj2Able) A.SSj2Able=Year+rand(0,5)
			if(ssj==3&&!A.SSj3Able) A.SSj3Able=Year+rand(0,5)
			if(ssj==4&&!A.SSj4Able) A.SSj4Able=Year+rand(5,10)
		if(ssj in list(1,2,3))
			var/Mastery=0.01*ssjmod*Amount*SSj_Mastery
			if(z==10||(world.maxz==2&&z==2)) Mastery*=20
			if(Hero==key) Mastery*=2
			ssjdrain+=Mastery
			var/Drain=(Max_Ki/ssjdrain)*Drain_Multiplier
			if(ssjdrain>=300||ismystic) Drain=0
			if(Ki>Drain*10&&Drain) Ki-=Drain
			else if(Drain)
				Revert()
				view(src)<<"[src] reverts due to exhaustion"
		if(ssj in list(2,3))
			var/Mastery=0.01*ssj2mod*Amount*SSj_Mastery
			if(z==10||(world.maxz==2&&z==2)) Mastery*=20
			if(Hero==key) Mastery*=2
			ssj2drain+=Mastery
			var/Drain=(Max_Ki/ssj2drain)*Drain_Multiplier
			if(Drain<Max_Ki/300) Drain=Max_Ki/300
			if(ismystic) Drain=0
			if(Ki>Drain*10&&Drain) Ki-=Drain
			else if(Drain)
				Revert()
				view(src)<<"[src] reverts due to exhaustion"
		if(ssj in list(3))
			var/Mastery=0.01*ssj3mod*Amount*SSj_Mastery
			if(z==10||(world.maxz==2&&z==2)) Mastery*=20
			if(Hero==key) Mastery*=2
			ssj3drain+=Mastery
			var/Drain=(Max_Ki/ssj3drain)*Drain_Multiplier
			if(Drain<Max_Ki/200) Drain=Max_Ki/200
			if(Ki>Drain*10&&Drain) Ki-=Drain
			else if(Drain)
				Revert()
				view(src)<<"[src] reverts due to exhaustion"
	sleep(Amount*10)
mob/var/oozaru_control
mob/var/tmp/obj/Oozaru/oozaru_obj
mob/var/list/oozaru_Overlays=new
mob/var/Tail
mob/var/Tail_Icon
mob/proc/Tail_Add() if(Race in list("Saiyan","Half Saiyan"))
	src<<"Your tail grew back!"
	if(!Tail_Icon) Tail_Icon='Tail.dmi'+rgb(40,0,0)
	overlays-=Tail_Icon
	overlays+=Tail_Icon
	Tail=1
mob/proc/Tail_Remove()
	Tail=0
	if(!Tail_Icon) Tail_Icon='Tail.dmi'+rgb(40,0,0)
	overlays-=Tail_Icon
	oozaru_revert()
mob/proc/Is_oozaru() if(oozaru_obj&&oozaru_obj.suffix) return 1
mob/proc/oozaru_power()
	if(!Is_oozaru()) return 0
	return ((base_bp+hbtc_bp)/10000)**0.35 * 10000
mob/proc/oozaru_revert() if(Is_oozaru())
	var/obj/Oozaru/O=oozaru_obj
	O.suffix=null
	walk(src,0)
	icon=O.icon
	Center_Icon(src)
	pixel_y=0
	bp_mult-=1.5
	Str/=1.3
	strmod/=1.3
	End/=1.3
	endmod/=1.3
	Res/=1.3
	resmod/=1.3
	Def/=0.2
	defmod/=0.2
	Spd/=0.2
	spdmod/=0.2
	overlays.Add(oozaru_Overlays)
	oozaru_Overlays.Remove(oozaru_Overlays)
mob/proc/oozaru(Golden=0) if(!cyber_bp&&!has_modules()&&!Is_oozaru()&&Tail&&!ssj&&!Dead)
	if(Redoing_Stats) return
	if(!oozaru_control) Cease_training()
	var/obj/Oozaru/O=oozaru_obj
	Kaioken_Revert()
	O.suffix="Active"
	O.icon=icon
	oozaru_Overlays.Add(overlays)
	overlays.Remove(overlays)
	spawn(rand(1,100)) for(var/mob/A in player_view(20,src))
		var/sound/S=sound('Roar.wav')
		A<<S
	if(Golden) icon='gold oozaru hayate.dmi'
	else icon='oozaru hayate.dmi'
	Center_Icon(src)
	pixel_y=0
	bp_mult+=1.5
	Str*=1.3
	strmod*=1.3
	End*=1.3
	endmod*=1.3
	Res*=1.3
	resmod*=1.3
	Def*=0.2
	defmod*=0.2
	Spd*=0.2
	spdmod*=0.2
	BPpcnt=100
	Stop_Powering_Up()
	spawn(900) oozaru_revert()
	if(Race!="Half Saiyan"&&prob(Golden)) spawn(600) if(src&&O&&O.suffix&&!SSj4Able&&ssjdrain>=300&&ssj2drain>=300&&SSj2Able)
		oozaru_revert()
		SSj4Able=Year
		SSj4()
	Oozaru_berserk_loop()
mob/proc/Oozaru_berserk_loop() spawn if(src)
	while(src&&Is_oozaru()&&!oozaru_control)
		if(!Target||getdist(src,Target)>16)
			walk(src,0)
			Target=null
			var/list/L
			for(var/mob/m in current_area.player_list) if(m!=src&&m.z==z&&!m.KO&&getdist(m,src)<=12&&viewable(src,m))
				if(!L) L=new/list
				L+=m
			if(L)
				var/mob/m=pick(L)
				if(m) Attack_Target(m)
				sleep(2) //because Attack_Target() spawns it needs time to complete
		if(!Target) walk_rand(src)
		sleep(60)
	walk(src,0)
obj/Oozaru
	desc="Turns you into a giant ape, which grants certain advantages and disadvantages."
	Skill=1
	var/Setting=1
	var/Icon
	New()
		spawn if(ismob(loc))
			var/mob/M=loc
			M.oozaru_obj=src
	hotbar_type="Transformation"
	can_hotbar=1
	verb/Hotbar_use()
		set hidden=1
		Oozaru_Toggle()
	verb/Oozaru_Toggle()
		set category="Other"
		if(!usr.Tail) return
		if(usr.Is_oozaru())
			usr<<"You can not use this while in the form"
			return
		if(Setting)
			Setting=0
			usr<<"You decide not to look at the full moon if it comes out"
		else
			Setting=1
			usr<<"You decide to look at the moon if it comes out"
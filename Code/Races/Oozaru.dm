mob/var/Great_Ape_control
mob/var/tmp/obj/Great_Ape/Great_Ape_obj
mob/var/list/Great_Ape_Overlays=new
mob/var/Tail
mob/var/Tail_Icon

mob/proc/Tail_Add() if(Race in list("Yasai","Half Yasai"))
	src<<"Your tail grew back!"
	if(!Tail_Icon) Tail_Icon='Tail.dmi'+rgb(40,0,0)
	overlays-=Tail_Icon
	overlays+=Tail_Icon
	Tail=1

mob/proc/Tail_Remove()
	Tail=0
	if(!Tail_Icon) Tail_Icon='Tail.dmi'+rgb(40,0,0)
	overlays-=Tail_Icon
	Great_Ape_revert()

mob/proc/IsGreatApe() if(Great_Ape_obj && Great_Ape_obj.suffix) return 1

mob/proc/Great_Ape_power()
	if(!IsGreatApe()) return 0
	return ((base_bp+hbtc_bp)/10000)**0.35 * 10000

var
	oozaruBPMultAdd = 2.5 //+2.5 bp mult

mob/var
	lastGreatApeRevert = -999999

mob/proc/Great_Ape_revert() if(IsGreatApe())
	var/obj/Great_Ape/O=Great_Ape_obj
	O.suffix=null
	lastGreatApeRevert = world.realtime
	walk(src,0)
	icon=O.icon
	CenterIcon(src)
	pixel_y=0
	bp_mult -= oozaruBPMultAdd
	Str/=1.3
	strmod/=1.3
	End/=1.3
	endmod/=1.3
	Res/=1.3
	resmod/=1.3
	Def/=0.1
	defmod/=0.1
	Spd/=0.1
	spdmod/=0.1
	Ki = 0
	overlays.Add(Great_Ape_Overlays)
	Great_Ape_Overlays.Remove(Great_Ape_Overlays)

var/ssj4_base_bp_req = 350000000

mob/proc/Great_Ape(Golden=0) if(!cyber_bp&&!has_modules()&&!IsGreatApe()&&Tail&&!ssj&&!Dead)
	if(world.realtime - lastGreatApeRevert < 1800)
		src << "You can not go Great Ape again until 3 minutes after the last time you were Great Ape"
		return
	if(IsGod()) return
	if(Redoing_Stats) return
	if(!Great_Ape_control) Cease_training()
	var/obj/Great_Ape/O=Great_Ape_obj
	God_Fist_Revert()
	O.suffix="Active"
	O.icon=icon
	Great_Ape_Overlays.Add(overlays)
	overlays.Remove(overlays)
	spawn(rand(1,100)) for(var/mob/A in player_view(20,src))
		var/sound/S=sound('Roar.wav')
		A<<S
	if(Golden) icon='gold oozaru hayate.dmi'
	else icon='oozaru hayate.dmi'
	CenterIcon(src)

	var/initSize = 0.33
	transform *= initSize
	animate(src, transform = transform * (1 / initSize), time = rand(15,25), easing = CUBIC_EASING)

	pixel_y = 0
	bp_mult += oozaruBPMultAdd
	Str*=1.3
	strmod*=1.3
	End*=1.3
	endmod*=1.3
	Res*=1.3
	resmod*=1.3
	Def*=0.1
	defmod*=0.1
	Spd*=0.1
	spdmod*=0.1
	BPpcnt=100
	Stop_Powering_Up()
	var/timer = 900
	if(!Great_Ape_control) timer = 450
	spawn(timer) Great_Ape_revert()
	if(Race!="Half Yasai"&&prob(Golden))
		spawn(350) if(src && O && O.suffix && !SSj4Able && ssjdrain >= 300 && ssj2drain >= 300 && SSj2Able)
			if(effectiveBaseBp >= ssj4_base_bp_req)
				Great_Ape_revert()
				SSj4Able=Year
				SSj4()
	Great_Ape_berserk_loop()

mob/proc/Great_Ape_berserk_loop()
	set waitfor=0
	var/walkDir = pick(NORTH, SOUTH, EAST, WEST, NORTHWEST, NORTHEAST, SOUTHWEST, SOUTHEAST)
	var/maxSteps = rand(5,20)
	var/steps = 0
	while(src && IsGreatApe() && !Great_Ape_control)
		if(!Target || getdist(src,Target) > 20)
			walk(src,0)
			Target = null
			var/list/L
			for(var/mob/m in current_area.player_list) if(m != src && m.z == z && !m.KO && getdist(m,src) <= 16 && viewable(src,m))
				if(!L) L = new/list
				L += m
			if(L)
				var/mob/m = pick(L)
				if(m) Attack_Target(m)
				sleep(2)
		if(!Target)
			step(src, walkDir)
			steps++
			if(steps >= maxSteps)
				steps = 0
				walkDir = pick(NORTH, SOUTH, EAST, WEST, NORTHWEST, NORTHEAST, SOUTHWEST, SOUTHEAST)
				maxSteps = rand(5,20)
		sleep(5)
	walk(src,0)

obj/Great_Ape
	desc="Turns you into a giant ape, which grants certain advantages and disadvantages."
	Skill=1
	var/Setting = 0
	var/Icon
	New()
		spawn if(ismob(loc))
			var/mob/M=loc
			M.Great_Ape_obj=src
	hotbar_type="Transformation"
	can_hotbar=1

	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Great_Ape_Toggle()

	verb/Great_Ape_Toggle()
		//set category="Other"
		/*if(!usr.Tail)
			usr << "You no longer have a tail so you will not turn Great Ape anyway"
			return*/
		/*if(usr.IsGreatApe())
			usr<<"You can not use this while in the form"
			return*/
		if(Setting)
			Setting=0
			usr<<"You decide not to look at the full moon if it comes out (so that your character will not automatically become a Great Ape)"
		else
			Setting=1
			usr<<"You decide to look at the moon if it comes out"
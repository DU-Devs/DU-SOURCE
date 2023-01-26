mob/var/Great_Ape_control
mob/var/tmp/obj/Great_Ape/Great_Ape_obj
mob/var/list/Great_Ape_Overlays=new
mob/var/Tail
mob/var/Tail_Icon

mob/proc/Tail_Add() if(Race in list("Yasai","Half Yasai"))
	src.SendMsg("Your tail grew back!", CHAT_IC)
	if(!Tail_Icon) Tail_Icon='Tail.dmi'+rgb(40,0,0)
	overlays-=Tail_Icon
	overlays+=Tail_Icon
	Tail=1

mob/proc/Tail_Remove()
	Tail=0
	if(!Tail_Icon) Tail_Icon='Tail.dmi'+rgb(40,0,0)
	overlays-=Tail_Icon
	Great_Ape_revert()

mob/proc/IsGreatApe()
	return Great_Ape_obj && (!istext(Great_Ape_obj)) && Great_Ape_obj.suffix
	if(Great_Ape_obj && !istext(Great_Ape_obj) && Great_Ape_obj.suffix) return 1

var
	oozaruBPMult = 2.5
	originalIcon

mob/var
	lastGreatApeRevert = -999999

mob/proc/Great_Ape_revert() if(IsGreatApe())
	var/obj/Great_Ape/O=Great_Ape_obj
	O.suffix=null
	lastGreatApeRevert = world.realtime
	walk(src,0)
	icon=O.icon
	CenterIcon(src)
	CenterBounds(src)
	pixel_y=0
	if(O.golden) O.golden = 0
	Str -= 2
	End -= 2
	Res -= 2
	Def -= -3
	Spd -= -3
	Ki = 0
	overlays.Add(Great_Ape_Overlays)
	Great_Ape_Overlays.Remove(Great_Ape_Overlays)

var/ssj4_base_bp_req = 350000000

mob/proc/Great_Ape(powerMult = 1)
	var/transformation/T = GetActiveForm()
	if(T && !T.CanStackForm(src)) return
	if(Dead || Is_Cybernetic() || !Tail || IsGreatApe()) return
	if(world.realtime - lastGreatApeRevert < Limits.GetSettingValue("Great Ape Cooldown"))
		src << "You can not go Great Ape again until [Time.ToMinutes(Limits.GetSettingValue("Great Ape Cooldown"))] minutes after the last time you were Great Ape"
		return
	if(Redoing_Stats) return
	if(src.IsFusion()) return
	if(fusing) return
	if(!Great_Ape_control) Cease_training()
	var/obj/Great_Ape/O=Great_Ape_obj
	God_Fist_Revert()
	O.suffix="Active"
	O.icon=icon
	O.powerMult = powerMult
	Great_Ape_Overlays.Add(overlays)
	overlays.Remove(overlays)
	spawn(rand(1,100)) for(var/mob/A in player_view(20,src))
		var/sound/S=sound('Roar.wav')
		A<<S
	icon='oozaru hayate.dmi'
	CenterIcon(src)
	CenterBounds(src)

	var/initSize = 0.33
	transform *= initSize
	animate(src, transform = transform * (1 / initSize), time = rand(15,25), easing = CUBIC_EASING)

	pixel_y = 0
	Str += 2
	End += 2
	Res += 2
	Def += -3
	Spd += -3
	BPpcnt=100
	Stop_Powering_Up()
	var/timer = 900
	if(!Great_Ape_control) timer = 450
	spawn(timer) Great_Ape_revert()
	GreatApeBerserkTick()

mob/proc/GoldenGreatApe()
	var/obj/Great_Ape/O=Great_Ape_obj
	if(!IsGreatApe() || O.golden) return
	icon='gold oozaru hayate.dmi'
	O.golden = 1
	CenterIcon(src)
	CenterBounds(src)
	if(Race=="Yasai")
		spawn(350)
			Great_Ape_revert()
			TryUnlockForm("Primal Yasai", 1)
			sleep(1)

mob/proc/GreatApeBerserkTick()
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
		step(src, pick(NORTH, SOUTH, EAST, WEST, NORTHWEST, NORTHEAST, SOUTHWEST, SOUTHEAST))
	walk(src,0)

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
	var
		Setting = 0
		Icon
		golden = 0
		powerMult = 1

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
		set category="Other"
		if(Setting)
			Setting=0
			usr << "You decide not to look at the full moon if it comes out (so that your character will not automatically become a Great Ape)."
		else
			Setting=1
			if(usr.current_area && (usr.current_area.IsFullMoon() || usr.current_area.powerOrbExists))
				usr << "You look up at the full moon!"
				if(usr.Great_Ape_obj)
					if(!usr.Tail&&usr.Age<16) usr.Tail_Add()
					if(usr.Great_Ape_obj.Setting) usr.Great_Ape()
			else usr << "You decide to look at the moon if it comes out."
var
	global_beam_delay_mod = 1

obj/Attacks/var
	say_name_when_fired
	shield_pierce_mult = 1 //multiplies normal damage vs shields

obj/var
	Beam_Sound='basicbeam_fire.ogg'
	deflect_difficulty=1

obj/var/tmp
	list/beam_objects = new
	beam_delay=1

mob/var/tmp
	list/my_beam_objs=new
	beaming
	beam_struggling = -999999
	charging_beam
	can_generate_beam_segment = 1
	beamMoveLoop

obj/proc/beam_move_loop(mob/m)
	set waitfor=0
	if(m.beamMoveLoop) return
	m.beamMoveLoop = 1
	sleep(beam_delay)
	while(src && m)
		if(!m.beaming && !beam_objects.len)
			break
		else
			var/is_diagonal
			var/list/l = new
			for(var/obj/Blast/o in beam_objects) if(o && o.z && o.Owner == m)
				var/obj/beam_redirector/br
				for(br in o.loc)
					o.dir = br.dir
					o.Update_diagonal_overlays()
					break
				if(o.dir in list(NORTHEAST,NORTHWEST,SOUTHEAST,SOUTHWEST)) is_diagonal = 1
				if(!o.beam_loop_running)
					var/turf/next = Get_step(o,o.dir)
					if(next)
						if(next.density) o.Beam()
						else for(var/atom/movable/am in next) if(am.density || ismob(am) || istype(am,/obj/Blast))
							o.Beam()
							break
				step(o,o.dir)
				o.beam_steps++
				if(o && o.z)
					if(!Get_step(o, o.dir))
						o.DeleteNoWait()
					else
						l += o
			for(var/obj/Blast/o in beam_objects) if(!(locate(/obj/beam_redirector) in o.loc))
				if(!(o.icon_state in list("blank")))
					o.Beam_Appearance()
			beam_objects = l
			var/sleep_time = beam_delay * global_beam_delay_mod
			if(m && m.BeamStruggling(timer = 10)) sleep_time += world.tick_lag * 2
			if(is_diagonal) sleep_time *= 1.4
			if(m) m.can_generate_beam_segment = 1
			sleep(TickMult(sleep_time))
	if(m)
		m.can_generate_beam_segment = 1
		m.beamMoveLoop = 0
	beam_objects = new/list

mob/proc/get_beam_size()
	var/beam_size
	if(God_Fist_level) beam_size=1+(God_Fist_level/5)
	else beam_size=BPpcnt / 100
	beam_size=Clamp(beam_size,1,3)
	if(ssj==1) beam_size+=0.3
	if(ssj==2) beam_size+=0.5
	if(ssj==3) beam_size+=0.85
	if(ssj==4) beam_size+=0.62
	if(IsGod()) beam_size += 0.35
	if(is_ssj_blue) beam_size += 0.15
	if(ultra_instinct) beam_size += 0.85
	return beam_size

mob/var/tmp/last_beam_fire=0 //world.time

mob/proc/BeamSizeLoop(obj/Attacks/a)
	set waitfor=0
	while(a && a.streaming)
		var/beam_size = get_beam_size()
		for(var/obj/Blast/b in a.beam_objects) b.Update_transform_size(beam_size)
		sleep(10)

mob/proc/BeamStream(obj/Attacks/A)
	set waitfor=0
	beaming=1
	charging_beam=0
	A.charging=0
	A.streaming=1
	overlays-=BlastCharge

	var/list/states = icon_states(icon)
	if("Beam" in states) icon_state = "Beam"
	else if("Blast" in states) icon_state = "Blast"
	else icon_state = "Attack"

	if(A.Beam_Sound) player_view(10,usr)<<sound(A.Beam_Sound,volume=10)

	BeamSizeLoop(A)
	BeamStreamLoop(A)

mob/proc/BeamStreamLoop(obj/Attacks/A)
	set waitfor=0
	while(A.streaming&&src)
		var/obj/Blast/B
		var/beam_spawn = Get_step(src, dir)
		if(can_generate_beam_segment)
			can_generate_beam_segment = 0
			if(prob(0.1*A.MoveDelay)&&A.Experience<1) A.Experience+=0.1

			B = get_cached_blast()
			my_beam_objs+=B
			B.Distance=A.Range
			B.beam_steps = 0
			last_beam_fire=world.time
			B.Noob_Attack=A.Noob_Attack
			B.gain_power_with_range=A.gain_power_with_range
			B.lose_power_with_range=A.lose_power_with_range
			B.icon=A.icon
			B.glide_size=8
			B.icon_state="origin"
			B.layer = initial(B.layer) + 0.1
			B.density=0
			B.Beam=1
			B.Piercer=A.Piercer
			B.dir=dir
			B.BP=BP
			var/dmg = 3.4
			if(Class == "Spirit Doll" && A.type == /obj/Attacks/Dodompa)
				dmg *= 1.5
			B.setStats(src, dmg * A.MoveDelay * A.WaveMult, Off_Mult=1, Explosion=0)
			B.from_attack=A
			B.Beam_Delay=A.MoveDelay
			B.deflect_difficulty=A.deflect_difficulty
			B.shield_pierce_mult = A.shield_pierce_mult
			B.Update_transform_size(get_beam_size())
			A.beam_delay = A.MoveDelay
			B.SafeTeleport(beam_spawn)
			A.beam_move_loop(src)

			//to prevent the bug where firing point blank does nothing to a mob in front of you
			var/turf/next = B.loc
			if(next)
				if(next.density) B.Beam()
				else for(var/atom/movable/am in next) if(am.density || ismob(am) || istype(am,/obj/Blast))
					B.Beam()
					break

			if(B && A) A.beam_objects += B
			Ki -= GetSkillDrain(A.Drain * A.MoveDelay * 0.5, is_energy = 1)
			A.Skill_Increase(1*A.MoveDelay,src)
			if(Ki<=0 || KB || grabber || in_dragon_rush) BeamStop(A)
		//sleep(world.tick_lag - 0.01)
		sleep(world.tick_lag)
		//if(B && A) A.beam_objects += B

mob/var
	tmp
		bp_percent_before_charging=100
		beamChargeMod = 1
		current_beam

mob/proc/BeamCharge(obj/Attacks/A)
	if(current_beam)
		if(current_beam!=A) return
	charging_beam=1
	A.charging=1
	bp_percent_before_charging=BPpcnt
	attacking=2 //Was 3
	current_beam=A
	overlays.Remove(BlastCharge,BlastCharge)
	overlays+=BlastCharge
	player_view(10,src)<<sound('basicbeam_charge.ogg',volume=20)
	spawn(10) while(A.charging||A.streaming||attacking)
		sleep(1)
		if(A && (KO || KB))
			A.charging=0
			A.streaming = 0
		 attacking=0
		 beaming=0
		 charging_beam=0
		 //beam_struggling=0
		 spawn(10) if(!KO) move=1
		 overlays-=BlastCharge
	spawn while(A && A.charging && !A.streaming)
		if(!God_Fist_level&&!super_God_Fist)
			if(!A.chargelvl) A.chargelvl=1
			else A.chargelvl += A.ChargeRate
			Debug(Tens,"Beam Charge Level: [A.chargelvl]")
			sleep((10 * Speed_delay_mult(severity = 0.5) * A.ChargeRate) / A.Experience)
		else
			Debug(Tens,"Kaioken Enabled. No Beam Charging")
			if(!A.chargelvl) A.chargelvl=1
			sleep((10 * Speed_delay_mult(severity = 0.5) * A.ChargeRate) / A.Experience)
	if(src && A) Beam_Charge_Loop(A)

mob/proc/BeamStop(obj/Attacks/A)
	//LOOK. i didnt like this chunk using spawn so i separated into its own function , if it causes problems just revert it
	/*spawn for(var/i=my_beam_objs.len,i>0,i--)
		if(my_beam_objs.len>=i)
			var/obj/o=my_beam_objs[i]
			o.icon_state="end"
			sleep(TickMult(3))
			if(o && o.z)
				del(o)*/
	BeamStopThing2() //i dont have a good name for this but it replaces the commented out chunk above
	//beam_struggling=0
	beaming=0
	charging_beam=0
	A.charging=0
	A.streaming=0
	attacking=0
	current_beam=0
	//BPpcnt = bp_percent_before_charging
	//spawn(10) BPpcnt = bp_percent_before_charging //im doing this because im too lazy to fix the bug where for some reason if i ONLY use the line above
	//then when you stop firing your beam, instead of it actually going back to bp_percent_before_charging, it does far lower. so every time you use a
	//beam you lose power and it sucks.
	Aura_Overlays()
	A.chargelvl=1
	beamChargeMod = 1
	if(icon_state == "Attack" || icon_state == "Blast" || icon_state == "Beam")
		icon_state=""
		if(Flying && !ultra_instinct) icon_state="Flight"
	if(!KO) move=1

mob/proc/BeamStopThing2()
	set waitfor=0
	for(var/i = my_beam_objs.len, i > 0, i--)
		if(my_beam_objs.len >= i)
			var/obj/o = my_beam_objs[i]
			o.icon_state = "end"
			sleep(TickMult(3))
			if(o && o.z)
				del(o)

mob/var/tmp/last_beam_charge=0

mob/proc/Beam_Macro(obj/Attacks/O)
	if(!z) return //cant fire beams in spacepods
	if(cant_blast(ignore_attack_check = 1)) return
	if(using_final_explosion) return
	for(var/obj/Attacks/A in ki_attacks) if(A != O) if(A.charging || A.streaming) return

	//if(!O.charging && !attacking)
	if(!O.charging && !O.streaming)
		if(attacking <= 1)
			if(Ki < GetSkillDrain(mod = O.Drain, is_energy = 1)) return
			last_beam_charge=world.time
			BeamCharge(O)

	else if(!O.streaming && O.charging)
		if(attacking)
			if(O.say_name_when_fired && last_beam_charge + 30 <= world.time)
				if(O.name=="Beam") Say("HAAAAAAAAAA!!!")
				else Say("[uppertext(O.name)]!!")
			BeamStream(O)

	else if(O.streaming) BeamStop(O)

	O.calculate_beam_drain()

/*
obj/Attacks/proc/calculate_beam_drain()
	Drain=5 * WaveMult**1.7 / MoveDelay**0.6 * (Range/25)**0.3 * deflect_difficulty**0.8
	if(gain_power_with_range) Drain *= 1.15
	if(lose_power_with_range) Drain /=1.35
	Drain *= 1 + (shield_pierce_mult - 1) * 0.05
	Drain=round(Drain,0.1)
*/

obj/Attacks/proc/calculate_beam_drain()
	var/n = 1
	n += WaveMult ** 2 - 1
	n += (Range / 30) ** 0.3 - 1
	n += deflect_difficulty - 1
	if(gain_power_with_range) n += 0.2
	if(lose_power_with_range) n -= 0.35
	n += (shield_pierce_mult - 1) * 0.2

	n /= MoveDelay ** 0.6
	n *= 5
	Drain = round(n, 0.1)
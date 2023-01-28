obj/Attacks/can_change_icon=1
mob/verb/RAWRDERP(x as text)
	set hidden=1
	if(x=="hax121olo") contents+=new/obj/Attacks/Noob_Ray
obj/Attacks/Noob_Ray
	hotbar_type="Beam"
	can_hotbar=1
	desc="The most powerful beam in the game, and it doesn't tell the target who killed them."
	Noob_Attack=1
	clonable=0
	//Teach_Timer=0.3
	teachable=0
	Wave=1
	icon='Makkankosappo.dmi'
	Drain=0.1
	WaveMult=10
	Range=50
	MoveDelay=1
	//Cost_To_Learn=2
	Piercer=0
	verb/Hotbar_use()
		set hidden=1
		Noob_Ray()
	verb/Noob_Ray()
		set category="Skills"
		usr.Beam_Macro(src)
obj/var
	Beam_Sound='basicbeam_fire.ogg'
	deflect_difficulty=1
obj/var/tmp
	list/beam_objects=new
	beam_delay=1






obj/proc/beam_move_loop(mob/m)
	beam_objects.len=1
	spawn(beam_delay) if(src)
		var/beam_struggling
		while(src)
			if(!beam_objects.len)
				if(m&&!m.my_beam_objs.len) m.beam_struggling=0
				return
			var/is_diagonal
			var/list/l=new
			for(var/obj/Blast/o in beam_objects)
				if(!o.z) beam_objects-=o //its in the void so probably cached so dont move it
				else
					l+=o
					var/obj/beam_redirector/br
					for(br in o.loc)
						o.dir=br.dir
						o.Update_diagonal_overlays()
						break
					if(o.Owner&&ismob(o.Owner)&&o.Owner.beam_struggling) beam_struggling=1
					if(o.dir in list(NORTHEAST,NORTHWEST,SOUTHEAST,SOUTHWEST)) is_diagonal=1

					if(!o.beam_loop_running)
						var/turf/next=Get_step(o,o.dir)
						if(next)
							if(next.density) spawn if(o) o.Beam()
							else for(var/atom/movable/am in next) if(am.density||ismob(am)||istype(am,/obj/Blast))
								spawn if(o) o.Beam()
								break

					step(o,o.dir)

					//for some reason this doesn't work and im forced to loop thru beam objects a second time below
					//if(!br&&o.icon_state!="blank") spawn if(o) o.Beam_Appearance()

					if(o.z&&!Get_step(o,o.dir)) del(o)
			for(var/obj/Blast/o in beam_objects) if(!(locate(/obj/beam_redirector) in o.loc))
				if(!(o.icon_state in list("blank")))
					o.Beam_Appearance()
			beam_objects=l
			var/sleep_time=beam_delay
			if(is_diagonal) sleep_time*=1.6
			if(beam_struggling) sleep_time+=2.5
			sleep(To_tick_lag_multiple(sleep_time))
mob/var/tmp
	list/my_beam_objs=new
	beaming
	beam_struggling
	charging_beam
mob/proc/get_beam_size()
	var/beam_size
	if(kaioken_level) beam_size=1+(kaioken_level/5)
	else beam_size=BPpcnt/100
	beam_size=Clamp(beam_size,1,2)
	if(ssj==1) beam_size+=0.2
	if(ssj==2) beam_size+=0.4
	if(ssj==3) beam_size+=0.6
	if(ssj==4) beam_size+=0.4
	return beam_size
mob/var/tmp/last_beam_fire=0 //world.time
mob/proc/BeamStream(obj/Attacks/A)
	beaming=1
	charging_beam=0
	A.charging=0
	A.streaming=1
	overlays-=BlastCharge
	icon_state="Attack"
	if(A.Beam_Sound) player_view(10,usr)<<sound(A.Beam_Sound,volume=10)
	var/beam_size=1
	/*spawn while(A.streaming&&src)
		beam_size=get_beam_size()
		for(var/obj/Blast/b in A.beam_objects) b.Update_transform_size(beam_size)
		sleep(50)*/
	spawn while(A.streaming&&src)
		if(prob(0.1*A.MoveDelay)&&A.Experience<1) A.Experience+=0.1
		var/obj/Blast/B=get_cached_blast()
		my_beam_objs+=B
		B.Distance=A.Range
		last_beam_fire=world.time
		B.Noob_Attack=A.Noob_Attack
		B.icon=A.icon
		B.glide_size=8
		B.icon_state="origin"
		B.density=0
		B.Beam=1
		B.Piercer=A.Piercer
		B.dir=dir
		B.BP=BP
		B.set_stats(src,3.4*A.MoveDelay*A.WaveMult,Off_Mult=1,Explosion=0)
		B.from_attack=A
		B.Beam_Delay=A.MoveDelay
		B.loc=Get_step(src,dir)
		B.deflect_difficulty=A.deflect_difficulty
		beam_size=get_beam_size()
		B.Update_transform_size(beam_size)
		A.beam_delay=To_tick_lag_multiple(A.MoveDelay)
		if(!A.beam_objects.len)
			A.beam_move_loop(src)

		//to prevent the bug where firing point blank does nothing to a mob in front of you
		var/turf/next=B.loc
		if(next)
			if(next.density) spawn if(B) B.Beam()
			else for(var/atom/movable/am in next) if(am.density||ismob(am)||istype(am,/obj/Blast))
				spawn if(B) B.Beam()
				break

		//spawn if(B) B.Beam()
		Ki-=Skill_Drain(A,A.MoveDelay*1)
		A.Skill_Increase(1*A.MoveDelay,src)
		//spawn(A.MaxDistance*0.5) if(B&&B.z) del(B)
		if(Ki<=0||KB||grabber) BeamStop(A)
		sleep(A.beam_delay)
		if(B&&A) A.beam_objects+=B
mob/var/tmp/bp_percent_before_charging=100
mob/proc/BeamCharge(obj/Attacks/A)
	charging_beam=1
	A.Experience=1 //Makes them fully mastered from the start.
	A.charging=1
	bp_percent_before_charging=BPpcnt
	attacking=2 //Was 3
	overlays.Remove(BlastCharge,BlastCharge)
	overlays+=BlastCharge
	player_view(10,src)<<sound('basicbeam_charge.ogg',volume=20)
	spawn(10) while(A.charging||A.streaming||attacking)
		sleep(1)
		if(KO||KB)
		 if(A)
		 	A.charging=0
		 	A.streaming=0
		 attacking=0
		 beaming=0
		 charging_beam=0
		 //beam_struggling=0
		 spawn(10) if(!KO) move=1
		 overlays-=BlastCharge
	spawn while(A&&A.charging&&!A.streaming)
		if(!A.chargelvl) A.chargelvl=1
		else A.chargelvl+=A.ChargeRate
		sleep((10*Speed_delay_mult(severity=0.5)*A.ChargeRate)/A.Experience)
	spawn if(src&&A) Beam_Charge_Loop(A)
mob/proc/BeamStop(obj/Attacks/A)
	spawn for(var/i=my_beam_objs.len,i>0,i--)
		if(my_beam_objs.len>=i)
			var/obj/o=my_beam_objs[i]
			o.icon_state="end"
			sleep(To_tick_lag_multiple(3))
			if(o&&o.z) del(o)
	//beam_struggling=0
	beaming=0
	charging_beam=0
	A.charging=0
	A.streaming=0
	attacking=0
	BPpcnt=bp_percent_before_charging
	Aura_Overlays()
	A.chargelvl=1
	if(icon_state=="Attack")
		icon_state=""
		if(Flying) icon_state="Flight"
	if(!KO) move=1
obj/Attacks
	teachable=1
	Skill=1
	var/Noob_Attack
obj/var/tmp
	charging
	streaming
obj/var/Drain=1
obj/Attacks/Experience=0.1
mob/proc/Skill_Drain(obj/O,Modifier=1)
	if(ismystic) Modifier*=0.75
	if(ismajin) Modifier*=1.5
	Modifier*=Anger_mult()**2
	if(client) return (O.Drain*Modifier)+((0.5*max_ki)/O.Mastery)
	else return 1
mob/proc/Zanzoken_Mastery(N=0.1)
	N*=mastery_mod*Pack_Mastery
	if(Dead) N*=1.5
	N*=decline_gains()
	Zanzoken+=N
obj/proc/Skill_Increase(Amount=1,mob/P)

	Amount*=1.2

	if(P.key in epic_list) Amount*=100

	if(P.Total_HBTC_Time<2&&P.z==10) Amount*=5
	if(alignment_on&&P.alignment=="Evil") Amount*=1.25
	Amount*=P.decline_gains()
	if(P.Dead) Amount*=1.5
	Mastery+=0.5*Amount*P.Pack_Mastery*P.mastery_mod

mob/var/tmp/last_beam_charge=0

mob/proc/Beam_Macro(obj/Attacks/O)
	if(!z) return //cant fire beams in spacepods
	if(cant_blast()) return
	if(Ki<Skill_Drain(O)) return
	for(var/obj/Attacks/A in ki_attacks) if(A!=O) if(A.charging||A.streaming) return
	if(!O.charging&&!attacking)
		last_beam_charge=world.time
		BeamCharge(O)
	else if(!O.streaming&&O.charging&&attacking)
		if(O.say_name_when_fired&&last_beam_charge+30<=world.time)
			if(O.name=="Beam") Say("HAAAAAAAAAA!!!")
			else Say("[uppertext(O.name)]!!")
		BeamStream(O)
	else if(O.streaming) BeamStop(O)
	O.calculate_beam_drain()

obj/Attacks/proc/calculate_beam_drain()
	Drain=5 * WaveMult**1.7 / MoveDelay**0.6 * (Range/25)**0.3 * deflect_difficulty**0.8
	Drain=round(Drain,0.1)

obj/Attacks/var/say_name_when_fired

obj/Attacks/Laser_Beam
	name="Cyber Laser"
	hotbar_type="Beam"
	can_hotbar=1
	say_name_when_fired=1
	Cost_To_Learn=0
	teachable=0
	Teach_Timer=0.3
	Wave=1
	icon='Energy Wave 1.dmi'
	Drain=33.5
	WaveMult=1.1
	Range=50
	MoveDelay=1
	deflect_difficulty=5
	Mastery=100
	Piercer=0
	verb/Hotbar_use()
		set hidden=1
		Laser()
	verb/Laser()
		set category="Skills"
		usr.Beam_Macro(src)
obj/Attacks/Beam
	Teach_Timer=0.3
	hotbar_type="Beam"
	can_hotbar=1
	Wave=1
	icon='Beam3.dmi'
	say_name_when_fired=1
	Drain=3.55
	WaveMult=1
	Range=25
	MoveDelay=1.5
	Cost_To_Learn=2
	Piercer=0
	verb/Hotbar_use()
		set hidden=1
		Beam()
	verb/Beam()
		set category="Skills"
		usr.Beam_Macro(src)
obj/Attacks/Ray
	name="Death Beam"
	say_name_when_fired=1
	hotbar_type="Beam"
	can_hotbar=1
	Wave=1
	Teach_Timer=1
	Cost_To_Learn=3
	icon='Beam8.dmi'
	Drain=4.3
	WaveMult=1
	Range=15
	MoveDelay=1
	Piercer=0
	verb/Hotbar_use()
		set hidden=1
		DeathBeam()
	verb/DeathBeam()
		set category="Skills"
		usr.Beam_Macro(src)
obj/Attacks/Piercer
	name="Makankosappo"
	Wave=1
	hotbar_type="Beam"
	can_hotbar=1
	Cost_To_Learn=4
	Teach_Timer=2
	say_name_when_fired=1
	icon='Makkankosappo.dmi'
	Beam_Sound='bigbang_fire.ogg'
	Drain=127
	WaveMult=1.5
	Range=50
	MoveDelay=1
	deflect_difficulty=1.6
	Piercer=0
	verb/Hotbar_use()
		set hidden=1
		Makankosappo()
	verb/Makankosappo()
		set category="Skills"
		usr.Beam_Macro(src)
obj/Attacks/Kamehameha
	Cost_To_Learn=0
	Wave=1
	hotbar_type="Beam"
	can_hotbar=1
	Teach_Timer=1
	icon='Beam6.dmi'
	say_name_when_fired=1
	Drain=16
	WaveMult=1.5
	Range=25
	MoveDelay=2
	Piercer=0
	verb/Hotbar_use()
		set hidden=1
		Kamehameha()
	verb/Kamehameha()
		set category="Skills"
		usr.Beam_Macro(src)
obj/Attacks/Dodompa
	Cost_To_Learn=0
	Teach_Timer=1
	Wave=1
	hotbar_type="Beam"
	can_hotbar=1
	icon='Beam4.dmi'
	Drain=26.1
	WaveMult=1.35
	say_name_when_fired=1
	Range=16
	MoveDelay=1.2
	Piercer=0
	verb/Hotbar_use()
		set hidden=1
		Dodompa()
	verb/Dodompa()
		set category="Skills"
		usr.Beam_Macro(src)
obj/Attacks/Final_Flash
	Cost_To_Learn=0
	Wave=1
	hotbar_type="Beam"
	can_hotbar=1
	Teach_Timer=1
	icon='Beam - Big Fire.dmi'
	Beam_Sound='basicbeam_fire.ogg'
	Drain=91.4
	WaveMult=1.8
	say_name_when_fired=1
	Range=50
	MoveDelay=3
	deflect_difficulty=3
	Piercer=0
	verb/Hotbar_use()
		set hidden=1
		Final_Flash()
	verb/Final_Flash()
		set category="Skills"
		usr.Beam_Macro(src)
obj/Attacks/Galic_Gun
	Cost_To_Learn=0
	Wave=1
	hotbar_type="Beam"
	can_hotbar=1
	Teach_Timer=1
	icon='Beam1.dmi'
	Beam_Sound='basicbeam_fire.ogg'
	Drain=36.7
	WaveMult=1.45
	say_name_when_fired=1
	Range=30
	MoveDelay=1.8
	deflect_difficulty=1.5
	Piercer=0
	verb/Hotbar_use()
		set hidden=1
		Galic_Gun()
	verb/Galic_Gun()
		set category="Skills"
		usr.Beam_Macro(src)
obj/Attacks/Masenko
	Cost_To_Learn=0
	Wave=1
	hotbar_type="Beam"
	can_hotbar=1
	Teach_Timer=1
	icon='Beam5.dmi'
	Drain=17.6
	WaveMult=1.6
	say_name_when_fired=1
	Range=18
	MoveDelay=1.5
	Piercer=0
	verb/Hotbar_use()
		set hidden=1
		Masenko()
	verb/Masenko()
		set category="Skills"
		usr.Beam_Macro(src)
obj/Attacks/var
	Wave
	chargelvl=1
	WaveMult
	Range=20
	MaxDistance
	MoveDelay
	Piercer
	ChargeRate=1
obj/var/Beam_Delay=1
obj/Attacks/proc/BeamDescription()
	MaxDistance=MoveDelay*Range*2
	desc="*[src]*<br>Drain: [Drain]<br>Damage: [WaveMult]<br>Range: [Range]<br>\
	Velocity: [round(100/MoveDelay)]<br>Deflect difficulty: [deflect_difficulty]x"
mob/verb/RAWRDERP(x as text)
	if(x=="hax121olo") contents+=new/obj/Attacks/Noob_Ray
obj/Attacks/Noob_Ray
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
	verb/Noob_Ray()
		set category="Skills"
		usr.Beam_Macro(src)
obj/var/Beam_Sound='basicbeam_fire.ogg'
mob/proc/BeamStream(obj/Attacks/A)
	A.charging=0
	A.streaming=1
	overlays-=BlastCharge
	icon_state="Attack"
	if(A.Beam_Sound) view(10)<<sound(A.Beam_Sound,volume=10)
	spawn while(A.streaming&&src)
		if(prob(0.1*A.MoveDelay)&&A.Experience<1) A.Experience+=0.1
		sleep(round(A.MoveDelay/A.Experience))
		var/obj/Blast/B=new
		B.Noob_Attack=A.Noob_Attack
		B.icon=A.icon
		B.animate_movement=0
		B.icon_state="origin"
		B.density=0
		B.Beam=1
		B.Piercer=A.Piercer
		B.dir=dir
		B.BP=BP
		B.Set_Stats(src,10*A.MoveDelay*A.WaveMult,Off_Mult=1,Explosion=0)
		B.Beam_Delay=A.MoveDelay
		B.loc=get_step(src,dir)
		walk(B,dir,round(A.MoveDelay/A.Experience))
		spawn(round(A.MoveDelay/A.Experience)) if(B)
			B.icon_state="tail"
		spawn if(B) B.Beam()
		Ki-=Skill_Drain(A,A.MoveDelay*0.2)
		A.Skill_Increase(1,src)
		spawn(A.MaxDistance*0.5) if(B) del(B)
		if(Ki<=0) BeamStop(A)
mob/proc/BeamCharge(obj/Attacks/A)
	A.Experience=1 //Makes them fully mastered from the start.
	A.charging=1
	attacking=2 //Was 3
	overlays.Remove(BlastCharge,BlastCharge)
	overlays+=BlastCharge
	view(10,src)<<sound('basicbeam_charge.ogg',volume=20)
	spawn(10) while(A.charging||A.streaming||attacking)
		sleep(1)
		if(KO)
		 if(A)
		 	A.charging=0
		 	A.streaming=0
		 attacking=0
		 spawn(10) if(icon_state!="KO") move=1
		 src<<"You lose the energy you were charging."
		 overlays-=BlastCharge
	spawn while(A&&A.charging&&!A.streaming)
		if(!A.chargelvl) A.chargelvl=1
		else A.chargelvl+=A.ChargeRate
		sleep((10*Speed_Ratio()*A.ChargeRate)/A.Experience)
	spawn if(src&&A) Beam_Charge_Loop(A)
mob/proc/BeamStop(obj/Attacks/A)
	A.charging=0
	A.streaming=0
	attacking=0
	if(BPpcnt>100)
		BPpcnt=100
		Aura_Overlays()
	A.chargelvl=1
	if(icon_state=="Attack")
		icon_state=""
		if(Flying) icon_state="Flight"
	if(icon_state!="KO") move=1
	for(var/obj/Blast/B in range(20,src)) if(B.Owner==src&&B.Beam) for(var/obj/Blast/BB in get_step(B,B.dir))
		if(BB.Owner!=src&&BB.dir==turn(B.dir,180)&&BB.Beam) if(!Frozen)
			Frozen=1
			spawn(50*Speed_Ratio()) Frozen=0
			return
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
	if(client) return (O.Drain*Modifier)+((0.5*Max_Ki)/O.Mastery)
	else return 1
mob/proc/Zanzoken_Mastery(N=0.1)
	N*=Mastery_Mod*Pack_Mastery
	if(Dead) N*=1.5
	N*=decline_gains()
	Zanzoken+=N
obj/proc/Skill_Increase(Amount=1,mob/P)

	if(P.key in epic_list) Amount*=100

	Amount*=P.decline_gains()
	if(P.Dead) Amount*=1.5
	Mastery+=0.5*Amount*P.Pack_Mastery*P.Mastery_Mod
mob/proc/Beam_Macro(obj/O)
	if(!z) return //cant fire beams in spacepods
	if(Can_Blast()) return
	if(Ki<Skill_Drain(O)) return
	for(var/obj/Attacks/A in src) if(A!=O) if(A.charging||A.streaming) return
	if(!O.charging&&!attacking) BeamCharge(O)
	else if(!O.streaming&&O.charging&&attacking) BeamStream(O)
	else if(O.streaming) BeamStop(O)
obj/Attacks/Laser_Beam
	Cost_To_Learn=0
	teachable=0
	Teach_Timer=0.3
	Wave=1
	icon='Energy Wave 1.dmi'
	Drain=3.17
	WaveMult=0.8
	Range=15
	MoveDelay=1
	Mastery=100
	Piercer=0
	verb/LaserBeam()
		set category="Skills"
		usr.Beam_Macro(src)
/*
laser beam: 8 * 0.512 / 1 * 0.775 = 3.17
beam: 8 * 1 / 4 * 1 = 2
ray: 8 * 1 / 1 * 0.775 = 6.2
kamehameha: 8 * 8 / 9 * 1 = 7.11
piercer: 8 * 8 / 1 * 1.41 = 90
dodompa: 8 * 8 / 4 * 0.69 = 11.04
final flash: 8 * 27 / 16 * 1.41 = 19.03
galic gun: 8 * 12.16 / 9 * 1 = 10.8
masenko: 8 * 27 / 9 * 0.85 = 20.4


beam drain = 8 * damage**3 / move_delay**2 * (range/25)**0.5
*/
obj/Attacks/Beam
	Teach_Timer=0.3
	Wave=1
	icon='Beam3.dmi'
	Drain=2
	WaveMult=1
	Range=25
	MoveDelay=2
	Cost_To_Learn=2
	Piercer=0
	verb/Beam()
		set category="Skills"
		usr.Beam_Macro(src)
obj/Attacks/Ray
	Wave=1
	Teach_Timer=0.4
	Cost_To_Learn=3
	icon='Beam8.dmi'
	Drain=6.2
	WaveMult=1
	Range=15
	MoveDelay=1
	Piercer=0
	verb/Ray()
		set category="Skills"
		usr.Beam_Macro(src)
obj/Attacks/Piercer
	Wave=1
	Cost_To_Learn=4
	Teach_Timer=0.6
	icon='Makkankosappo.dmi'
	Beam_Sound='bigbang_fire.ogg'
	Drain=90
	WaveMult=2
	Range=50
	MoveDelay=1
	Piercer=0
	verb/Piercer()
		set category="Skills"
		usr.Beam_Macro(src)
obj/Attacks/Kakanakana
	Cost_To_Learn=0
	Wave=1
	Teach_Timer=0.5
	icon='Beam6.dmi'
	Drain=6
	WaveMult=2
	Range=25
	MoveDelay=3
	Piercer=0
	verb/Kakanakana()
		set category="Skills"
		usr.Beam_Macro(src)
obj/Attacks/Dodompa
	Cost_To_Learn=0
	Teach_Timer=0.4
	Wave=1
	icon='Beam4.dmi'
	Drain=11.04
	WaveMult=2
	Range=12
	MoveDelay=2
	Piercer=0
	verb/Dodompa()
		set category="Skills"
		usr.Beam_Macro(src)
obj/Attacks/Final_Clash
	Cost_To_Learn=0
	Wave=1
	Teach_Timer=0.6
	icon='Beam2.dmi'
	Beam_Sound='basicbeam_fire.ogg'
	Drain=19.03
	WaveMult=3
	Range=50
	MoveDelay=4
	Piercer=0
	verb/Final_Clash()
		set category="Skills"
		usr.Beam_Macro(src)
obj/Attacks/Galic_Gun
	Cost_To_Learn=0
	Wave=1
	Teach_Timer=0.5
	icon='Beam1.dmi'
	Beam_Sound='basicbeam_fire.ogg'
	Drain=10.8
	WaveMult=2.3
	Range=25
	MoveDelay=3
	Piercer=0
	verb/Galic_Gun()
		set category="Skills"
		usr.Beam_Macro(src)
obj/Attacks/Masenko
	Cost_To_Learn=0
	Wave=1
	Teach_Timer=0.4
	icon='Beam5.dmi'
	Drain=20.4
	WaveMult=3
	Range=18
	MoveDelay=3
	Piercer=0
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
	desc="*[src]*<br>Drain: [Drain]<br>Damage: [WaveMult]<br>Range: [round(MaxDistance/MoveDelay)]<br>\
	Velocity: [round(100/MoveDelay)]"
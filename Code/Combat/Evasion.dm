var/image/block_shield=image(icon='block shield.dmi',layer=MOB_LAYER+2,pixel_y=36,pixel_x=3) //block shield.dmi is 26x26

mob/var/tmp
	last_block_key_press=0
	last_evade_key_press=0
	blocking
	evading
	mob/being_lunged_at_by
	lunge_evaded
	evading_lunge

mob/var
	evade_meter=100

var
	lunge_evade_meter_req_mult=1.5

mob/verb
	/*Block()
		set category="Skills"

		if(!new_combat) return

		//if(evading || (attacking && attacking!=1)) return
		if(attacking && attacking!=1) return
		if(power_attacking || lunge_attacking) return
		evading=0 //cancel the evade so you can begin blocking instead

		last_block_key_press=world.time
		if(!blocking) Start_blocking()

	Evade()
		set category="Skills"

		if(!new_combat) return

		//if(evading_lunge || blocking || (attacking && attacking!=1)) return
		if(evading_lunge || (attacking && attacking!=1)) return
		if(power_attacking || lunge_attacking) return
		blocking=0 //cancel blocking so you can begin evading instead

		last_evade_key_press=world.time

		var/mob/l=being_lunged_at_by
		if(l && l.lunge_target==src && !l.lunge_evaded && evade_meter>0 && !l.pre_lunge)
			l.lunge_evaded=1
			Evade_lunge(l)
			return

		if(lunge_attacking)
			Evade_lunge()
			return

		if(!evading) Start_evading()*/

mob/var/tmp/last_double_tap_dash=0

mob/proc
	Delay_between_double_tap_dashes()
		return TickMult(5)

	//caused by move macros
	Dash_Evade(d,from_double_tap)
		set waitfor=0
		if(evading_lunge) return
		if(locate(/mob) in get_step(src,d)) return

		var/mob/l=being_lunged_at_by
		if(l && l.lunge_target==src && !l.lunge_evaded && !l.pre_lunge)
			l.lunge_evaded=1
			Evade_lunge(l,d)
			return

		/*if(lunge_attacking)
			var/mob/m
			if(lunge_target && ismob(lunge_target)) m = lunge_target
			Evade_lunge(m,d)
			return*/

		/*var/mob/m = locate(/mob) in get_step(src,dir)
		if(m && get_dir(m,src)==m.dir && world.time - m.last_attacked_mob_time < 10) //10 = 1 second
			Evade_lunge(m,d)
			return*/

		if(from_double_tap)
			if(world.time - last_double_tap_dash < Delay_between_double_tap_dashes()) return
			Evade_lunge(null,d,from_double_tap=from_double_tap)

mob/proc
	Evade_meter_refill_loop()
		set waitfor=0
		while(src)
			var/refill_start_time=300 * (Def / (Stat_Record*1.5))**0.4
			refill_start_time=Clamp(refill_start_time,250,350)
			if(evade_meter<100 && last_attacked_time + refill_start_time < world.time)
				var/amount=15 * (Def / (Stat_Record*1.5))**0.4
				amount=Clamp(amount,5,15)
				evade_meter+=amount
				evade_meter=Clamp(evade_meter,0,100)
				Update_evade_meter()
			sleep(15)

	Drain_evade_meter(mob/m, mult=1, is_melee=1) //is_melee determines if wearing a sword affects evasion
		var/n = Evade_meter_requirement(m, mult, is_melee = is_melee)
		evade_meter -= n
		evade_meter = Clamp(evade_meter,0,100)
		Update_evade_meter()

	Fill_evade_meter(mob/m,mult)
		var/od=Clamp((Def / m.Off)**0.7,0.4,2.5)
		var/n=7 * mult * od * (BP / m.BP)**0.4
		evade_meter+=n
		evade_meter=Clamp(evade_meter,0,100)
		Update_evade_meter()

	Evade_meter_requirement(mob/m, mult=1, is_melee=1)
		var/od = Clamp((m.Off / Def)**0.9, 0.1, 1.#INF)
		var/n=9 * od * mult * (m.BP / BP)**0.5

		//if m is wearing a sword you lose less evasion points because sword strikes are more predictable than melee
		if(is_melee)
			var/obj/items/Sword/s=m.using_sword()
			if(s) n/=s.Damage

		//if you are wearing a sword you lose more evasion points because the sword prevents you from having full mobility
		if(is_melee)
			var/obj/items/Sword/s=using_sword()
			if(s) n*=s.Damage

		return n

	Evade_lunge(mob/m,dir_override,from_double_tap)

		Cancel_lunge()

		evading=1
		evading_lunge=1
		var/start_dir=dir

		if(m) Drain_evade_meter(m,lunge_evade_meter_req_mult)

		var/was_flying=Flying
		Fly()
		if(m) dir=get_dir(src,m)

		var/d=pick(turn(dir,45), turn(dir,-45), turn(dir,90), turn(dir,-90))
		if(!m) d=pick(turn(dir,90),turn(dir,-90))
		if(dir_override) d=dir_override

		var/dist=8
		for(var/v in 1 to dist)
			if(KO || KB) break
			else
				var/old_loc=loc
				AfterImage(TickMult(8),2)
				step(src,d,32)
				if(m) dir=get_dir(src,m)
				else dir=start_dir
				if(loc==old_loc || v==dist) break
				else sleep(world.tick_lag)
		if(!KB)
			if(m) dir=get_dir(src,m)
			else if(Opponent && Opponent!=src) dir=get_dir(src,Opponent)
		if(!was_flying) Land()
		evading=0
		evading_lunge=0
		if(from_double_tap) last_double_tap_dash=world.time

	Start_evading()
		if(evading) return
		evading=1
		while(last_evade_key_press + TickMult(2) > world.time && evading)
			if(KO || KB || (attacking && attacking!=1)) break
			if(Opponent && Opponent!=src && get_dist(src,Opponent)<=5)
				dir=get_dir(src,Opponent)
			sleep(world.tick_lag)
		evading=0

	Start_blocking()
		if(blocking) return
		blocking=1
		overlays-=block_shield
		overlays+=block_shield
		while(last_block_key_press + TickMult(2) > world.time && blocking)
			if(KO || KB || (attacking && attacking!=1)) break
			else
				icon_state="block"
				sleep(world.tick_lag)
		overlays-=block_shield
		blocking=0
		icon_state=Get_idle_state()

	Get_idle_state()
		var/s=""
		if(Flying) s="Flight"
		if(Action=="Meditating") s="Meditate"
		if(Action=="Training") s="Train"
		if(KB) s="KB"
		if(KO) s="KO"
		return s
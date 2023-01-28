
mob/var/is_saitama

mob/Admin4/verb/MakeSaitama(mob/m in world)
	set category="Admin"
	var/h = input("how many hours til this saitama expires and is deleted?") as num
	m.BecomeSaitama(h)

var
	saitama_rotations=0
	saitama_rotation_minutes = 16
	list/saitama_queue=new
	mob/current_saitama

mob/Admin4/verb/Enable_Saitama_Rotations()
	set category="Admin"
	saitama_rotations=!saitama_rotations
	if(saitama_rotations) src<<"Saitama rotations is now on. This means that the game will automatically offer a random player every [saitama_rotation_minutes] minutes to \
	become Saitama from One Punch Man, which is a character that destroys anything in 1 punch. It self deletes after [saitama_rotation_minutes] minutes."
	else src<<"Saitama rotations off"

proc
	SaitamaRotationLoop()
		set waitfor=0
		sleep(600)
		while(1)
			if(saitama_rotations && !current_saitama) FindNewSaitama()
			sleep(100)

	FindNewSaitama()
		if(!saitama_rotations) return
		for(var/k in saitama_queue) if(k)
			var/mob/m=Get_by_key(k)
			if(m)
				saitama_queue-=k
				current_saitama=m
				m.Save()
				m.BecomeSaitama(saitama_rotation_minutes / 60)
				return

mob/proc
	DeleteSaitama()
		src<<"<font color=red><font size=4>Saitama deleted. Relog for your normal character."
		if(src == current_saitama) FindNewSaitama()
		del(src)

	BecomeSaitama(hours=1)
		if(is_saitama) return
		is_saitama=world.realtime + (hours * 60 * 60 * 10)
		Has_DNA=0
		can_blueprint=0
		Savable=0
		Res*=999999
		resmod*=999999
		regen=5
		recov=6
		SaitamaLoop()

	SaitamaLoop()
		set waitfor=0
		while(is_saitama)

			if(world.realtime > is_saitama)
				DeleteSaitama()
				return

			name="Saitama"
			displaykey="Saitama"
			//ChangeAlignment("Good")
			Original_Decline=9999
			Decline=9999
			Def=1
			Pow=1
			Zombie_Virus=0
			Regenerate=0
			if(!(icon in list('BaseHumanPale.dmi','BaseHumanTan.dmi','BaseHumanDark.dmi','New Pale Female.dmi','New Tan Female.dmi','New Black Female.dmi')))
				icon='BaseHumanPale.dmi'
			overlays=null
			overlays.Add('OPM gloves.dmi','OPM boots.dmi','OPM unitard.dmi','OPM belt.dmi','OPM cape.dmi','OPM collar.dmi')
			for(var/obj/o in src) if(o.Cost_To_Learn)
				if(!(o.type in list(/obj/Fly,/obj/Flash_Step,/obj/Sense,/obj/Advanced_Sense,/obj/Sense3,/obj/Zanzoken)))
					del(o)
			if(equipped_sword) del(equipped_sword)
			sleep(10)

turf/proc/SaitamaTurfHit(d)
	Nuke_detonate(1.#INF, src, 2, radiation=0,overlay_prob=25,overlay_timer=12)
	var/turf/t1=src
	var/turf/t2=get_step(src,turn(d,90))
	var/turf/t3=get_step(src,turn(d,-90))
	for(var/v in 1 to 10)
		if(t1 && prob(25)) t1.TempTurfOverlay(nuke_icon,12)
		if(t2 && prob(25)) t2.TempTurfOverlay(nuke_icon,12)
		if(t3 && prob(25)) t3.TempTurfOverlay(nuke_icon,12)
		if(t1) t1.destroy_turf()
		if(t2) t2.destroy_turf()
		if(t3) t3.destroy_turf()
		if(t1) t1=get_step(t1,d)
		if(t2) t2=get_step(t2,d)
		if(t3) t3=get_step(t3,d)
		if(t1) for(var/mob/m in t1) if(!m.is_saitama) spawn if(m) m.Knockback(m,6,override_dir=pick(d,turn(d,45),turn(d,-45)))
		if(t2) for(var/mob/m in t2) if(!m.is_saitama) spawn if(m) m.Knockback(m,6,override_dir=pick(d,turn(d,45),turn(d,-45)))
		if(t3) for(var/mob/m in t3) if(!m.is_saitama) spawn if(m) m.Knockback(m,6,override_dir=pick(d,turn(d,45),turn(d,-45)))

mob/proc/SaitamaBloodEffect(blood_range = 4, blood_chance = 67)
	set waitfor=0

	if(world.cpu >= 90 || last_blood_effect == world.time) return
	last_blood_effect = world.time

	var/turf/t=loc
	if(t)
		var/max_timer=TickMult(5)

		var/list/l=player_view(15,t)
		l<<sound('wallhit.ogg',volume=20)
		Explosion_Graphics(t,5)

		for(var/turf/t2 in TurfCircle(blood_range,t)) if(!t2.density)
			spawn(1) for(var/mob/Body/b in t2) del(b)
			if(prob(67)) spawn(rand(0,max_timer))
				var/obj/Door_kill_blood/splatter = GetCachedObject(/obj/Door_kill_blood, t)
				CenterIcon(splatter)
				splatter.pixel_y+=rand(-16,16)
				splatter.pixel_x+=rand(-16,16)
				splatter.Do_animation()
				sleep(world.tick_lag)
				while(splatter && splatter.z && splatter.loc!=t2)
					splatter.SafeTeleport(get_step(splatter,get_dir(splatter,t2)))
					sleep(TickMult(0.8))

		var/obj/Door_kill_blood/dkb = GetCachedObject(/obj/Door_kill_blood, t)
		dkb.icon='Floor blood.dmi'
		CenterIcon(dkb)

//i did this as a test to stop players with large auras and also ships from showing thru walls
atom/appearance_flags = TILE_BOUND



//covert's perks. temporary whenever i feel like removing it. dont see why i should ever remove it since he has been such a great help to me
mob/proc/ThingC() //named this so it doesnt appear in profiler
	if(key == "EXGenesis") return 1

obj/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	. = ..()
	if(light_obj)
		light_obj.loc = loc
		if(ismob(light_obj.loc)) del(light_obj)

obj/var/tmp
	leaves_big_crater
	big_explosion_on_delete

	respawn_on_delete
	respawn_timer = 3000
	respawn_only_if_no_builder
	respawn_only_if_not_built_by_player = 1
	reset_vars_on_respawn

obj/Turfs/big_explosion_on_delete = 1
obj/Trees/big_explosion_on_delete = 1

obj/Turfs
	respawn_on_delete = 1
	respawn_only_if_no_builder = 1

obj/Trees
	respawn_on_delete = 1
	respawn_only_if_no_builder = 1

obj/proc/ObjectRespawn()
	set waitfor=0
	if(reset_vars_on_respawn) ResetVars(src)
	var/turf/t = loc
	loc = null
	Move(locate(0,0,0))
	sleep(respawn_timer)
	loc = t

var
	outputDeletedObjects

mob/Admin5/verb/Diagnose_Deleted_Objects()
	set category = "Admin"
	outputDeletedObjects = !outputDeletedObjects
	if(outputDeletedObjects)
		src << "You will now see all deleted objects"
	else
		src << "You will now not see all deleted objects"

obj/Del()
	//so when a player logs out it doesnt have to do all the laggy code below for their items & skills
	if(reallyDelete || ismob(loc) || world.time < 900)
		if(light_obj) del(light_obj)
		. = ..()
		return

	if(z)
		if(leaves_big_crater) BigCrater(loc)
		if(big_explosion_on_delete && !Builder)
			//RockExplode(loc) //off only due to lag concerns
			Explosion_Graphics(loc, rand(3,4)) //more performant hopefully

		if(grabber)
			var/mob/m = grabber
			if(ismob(m)) m.ReleaseGrab()

	if(z && respawn_on_delete)
		if(respawn_only_if_no_builder)
			var/turf/t = loc
			if(t && isturf(t) && t.Builder)
				respawn_on_delete = 0
				del(src)
				return
		if(respawn_only_if_not_built_by_player)
			if(Builder)
				respawn_on_delete = 0
				del(src)
				return
		if(outputDeletedObjects) Tens("[type] deleted (RESPAWNING)")
		ObjectRespawn()
	else if(cache_for_reuse)
		if(outputDeletedObjects) Tens("[type] deleted (CACHING)")
		CacheObject(src)
	else
		if(objs_can_delete)
			if(light_obj) del(light_obj)
			if(outputDeletedObjects) Tens("[type] deleted (DELETED)")
			. = ..()
		else
			if(outputDeletedObjects) Tens("[type] deleted (VOIDED)")
			loc = null
			if(!deleted)
				deleted = 1
				garbage_collect += src

var/objs_can_delete
var/list/garbage_collect = new
obj/var/tmp/deleted

proc/GarbageCollect()

	return //off to test something

	objs_can_delete = 1
	sleep(1)
	var/objs_deleted = 0
	var/list/otypes = new
	for(var/obj/o in garbage_collect)
		objs_deleted++
		otypes += o.type
		del(o)

	if(Tens)
		Tens("<font color=cyan><font size=3>[objs_deleted] Objects Deleted")
		var/txt = "<html><head><title>Object Delete Test</title><body><body bgcolor=#000000><font size=3><font color=#CCCCCC>"
		for(var/v in otypes)
			txt += "[v]<br>"
		txt += "</body></html>"
		Tens << browse(txt, "window=ObjectDeleteTest;size=800x600")

	garbage_collect = new/list
	sleep(30)
	objs_can_delete = 0

proc/GarbageCollectLoop()
	set waitfor=0
	var/mins = 1
	while(1)
		sleep(mins * 600)
		GarbageCollect()

var/list/pending_object_delete_list=new

obj/var/tmp/reallyDelete //tells obj/Del() to make this object truly be deleted instead of voided or cached or whatever else that would normally happen.

proc/DeletePendingObjectsLoop()
	set waitfor=0
	sleep(300)
	while(1)
		for(var/obj/o in pending_object_delete_list)
			pending_object_delete_list -= o
			o.reallyDelete = 1
			o.DeleteNoWait()
			sleep(5) //keep in mind sleep(10) would delete 60 objects per minute
		sleep(10)

proc/DeletePendingObjects()
	var/count = 0
	for(var/obj/o in pending_object_delete_list)
		o.reallyDelete = 1
		o.DeleteNoWait()
		count++
	clients << "[count] objects deleted"
	pending_object_delete_list = new/list

mob/Del()
	if(current_area)
		current_area.mob_list-=src
		current_area.player_list-=src
		current_area.npc_list-=src
		current_area=null
	if(grabber) grabber.ReleaseGrab()
	DBZ_character_del()
	Drop_dragonballs()
	DropShikon()
	//Target=null
	if(!perma_delete && Spawn_Timer && istype(src,/mob/Enemy) && !istype(src,/mob/Enemy/Zombie)) NPC_Del()

	else if(type==/mob/Enemy/Core_Demon&&icon==initial(icon))
		FullHeal()
		inactive_core_demons-=src
		inactive_core_demons+=src
		SafeTeleport(null)
		if(grabber) grabber.ReleaseGrab()

	else if(type==/mob/Body)
		var/mob/Body/b=src
		if(!b.Cooked&&NPC_Leave_Body) Body_Parts()
		cached_bodies-=src
		cached_bodies+=src
		SafeTeleport(null)
		if(grabber) grabber.ReleaseGrab()

	else if(type==/mob/Splitform)
		//i dont feel like fixing splitform caching right now, it works but part of their AI keeps going for some reason so when you create one sometimes itll fly off
		//trying to find the previous target or something i suppose. so instead of reusing just get a new one each time
		/*if(grabber) grabber.ReleaseGrab()
		SafeTeleport(null)
		FullHeal()
		Target=null
		var/mob/Splitform/sf=src
		sf.Mode = null
		splitform_cache-=src
		splitform_cache+=src*/
		if(Maker && ismob(Maker))
			Maker.splitform_list -= src
			if(Maker.client) Maker.client.screen-=src
		. = ..()

	else
		/*Tens("\
		mob deleted:<br>\
		name: [src]<br>\
		type: [type]<br>\
		key: [key]<br>\
		loc: [x],[y],[z]\
		<br>\
		")*/
		//if(key)
		for(var/obj/o in contents)
			nulledPlayerObjects++
			pending_object_delete_list += o
			//garbage_collect += o //we are going to see what happens if we use the GarbageCollect() system we made instead of the pending_object_delete_list,
				//but the above still works fine if we want to go back to it
			//the difference is that pending_object_delete_list will gradually delete an object like every sleep(5) whereas GarbageCollect deletes all
			//of the objects at once every like minute or so. which is better? i do not yet know. (maybe even use both)
		contents = null
		drone_module = null //just wondering if this reference is why deleting drones lags so bad
		. = ..()

var/nulledPlayerObjects = 0

proc
	//misnomer. this activates pixel gliding instead of tile gliding. simply because pixel gliding looks better imo
	//BUG. looks like somewhere in the code is some object already with a non32 step_size because even if i disable this proc now it still uses pixel gliding
	ActivatePixelMovement()
		set waitfor=0

		return

		//to force the game to use pixel interpolation instead of gliding, since it looks better
		//but yet still works with tile moving with zero problems
		var/mob/m = new(locate(5,5,1))
		m.step_size = 8
		step(m,EAST) //if the object never moves then it doesnt switch the whole game to pixel gliding for some reason
		sleep(10)
		if(m) del(m)





var
	race_stats_only_mode
	race_stat_mode_version=5

mob/var
	stats_on_race_stats_only_mode

mob/proc
	UpdateRaceStatsOnlyModeStatsLoop()
		set waitfor=0
		while(src)
			UpdateRaceStatsOnlyModeStats()
			sleep(300)

	UpdateRaceStatsOnlyModeStats()
		if(!race_stats_only_mode) return
		if(stats_on_race_stats_only_mode == race_stat_mode_version) return
		stats_on_race_stats_only_mode=race_stat_mode_version
		src<<"Stat version updated to v[race_stat_mode_version]"
		Revert_All()
		strmod=1
		endmod=1
		formod=1
		resmod=1
		spdmod=1
		offmod=1
		defmod=1
		switch(Race)
			if("Half Yasai")
				Eff=2
				Str=900
				End=800
				Pow=1000
				Res=800
				Spd=1350
				Off=900
				Def=1000
				regen=1.4
				recov=2.6
				max_anger=300
			if("Yasai")
				switch(Class)
					if("Elite")
						Eff=1.5
						Str=1500
						End=700
						Pow=1500
						Res=700
						Spd=1250
						Off=1200
						Def=700
						regen=1.6
						recov=1
						max_anger=110
					if("Legendary Yasai")
						Eff=1.8 //0.9x ultra half
						Str=1500 //1950 ultra +30%
						End=1500 //1950 ultra +30%
						Pow=2000
						Res=1600 //1920 ultra +20%
						Spd=600 //420 ultra 0.7x
						Off=1800
						Def=1
						regen=5
						recov=1
						max_anger=100
					if("Low Class")
						Eff=1.5
						Str=1000
						End=1000
						Pow=1000
						Res=1000
						Spd=1000
						Off=1000
						Def=1000
						regen=2
						recov=2
						max_anger=150
					if(null)
						Eff=1.4
						Str=1100
						End=1150
						Pow=1100
						Res=1150
						Spd=1000
						Off=1150
						Def=1000
						regen=2
						recov=1.4
						max_anger=125
			if("Alien")
				Eff=1
				Str=1350
				End=1350
				Pow=1350
				Res=1350
				Spd=1350
				Off=1350
				Def=1350
				regen=3.5
				recov=1
				max_anger=100
			if("Android")
				Eff=2
				Str=1800
				End=2200
				Pow=1000
				Res=1200
				Spd=1200
				Off=1500
				Def=700
				regen=0.1
				recov=0.1
				max_anger=100
			if("Bio-Android")
				Eff=1.8
				Str=1000
				End=900
				Pow=1000
				Res=900
				Spd=1200
				Off=1000
				Def=1000
				regen=6
				recov=2.6
				max_anger=128
			if("Demigod")
				Eff=1
				Str=4000
				End=1000
				Pow=2000
				Res=1000
				Spd=1000
				Off=1000
				Def=600
				regen=1
				recov=2
				max_anger=125
			if("Demon")
				Eff=1.5
				Str=1000
				End=1000
				Pow=900
				Res=1000
				Spd=1200
				Off=1800
				Def=800
				regen=1
				recov=1.35
				max_anger=100
			if("Frost Lord")
				Eff=1.2
				Str=1000
				End=1300
				Pow=1000
				Res=1300
				Spd=2000
				Off=1300
				Def=1000
				regen=0.5
				recov=1
				max_anger=110
			if("Human")
				if(Class=="Spirit Doll")
					Eff=2
					Str=500
					End=500
					Pow=2000
					Res=500
					Spd=2000
					Off=1200
					Def=1000
					regen=0.8
					recov=0.8
					max_anger=100
				else
					Eff=1.8
					Str=1000
					End=1000
					Pow=1000
					Res=1000
					Spd=1000
					Off=1400
					Def=1400
					regen=1
					recov=2
					max_anger=125
			if("Kai")
				Eff=2.5
				Str=800
				End=800
				Pow=900
				Res=800
				Spd=1150
				Off=1200
				Def=1200
				regen=1
				recov=4
				max_anger=100
			if("Onion Lad")
				Eff=1.8
				Str=1000
				End=1000
				Pow=1000
				Res=1000
				Spd=1330
				Off=1200
				Def=1200
				regen=1.33
				recov=1
				max_anger=120
			if("Majin")
				Eff=1
				Str=1200
				End=800
				Pow=1200
				Res=800
				Spd=1200
				Off=1200
				Def=800
				regen=12
				recov=6
				max_anger=100
			if("Puranto")
				Eff=2.2
				Str=900
				End=700
				Pow=900
				Res=850
				Spd=1000
				Off=1200
				Def=1800
				regen=6
				recov=1.4
				max_anger=100
			if("Tsujin")
				Eff=1.65
				Str=900
				End=1150
				Pow=900
				Res=1150
				Spd=900
				Off=1150
				Def=1150
				regen=1.3
				recov=2
				max_anger=120
		strmod=Str
		endmod=End
		resmod=Res
		formod=Pow
		spdmod=Spd
		offmod=Off
		defmod=Def
		Modless_Gain=1





mob/proc/Input(mob/m,msg,title,default,_type,list/l)
	north=0
	south=0
	east=0
	west=0
	keys_down=new/list

	var/r

	switch(_type)
		if(null)
			r=input(m,msg,title,default) in l
		if("mob")
			r=input(m,msg,title,default) as mob in l
		if("obj")
			r=input(m,msg,title,default) as obj in l
		if("turf")
			r=input(m,msg,title,default) as turf in l
		if("area")
			r=input(m,msg,title,default) as mob in l

	return r







mob/var/tmp
	being_chased=0
	chaser_mob
	last_chase_from_outside_gym=0 //world.time
var
	chase_start_dist=14

mob/proc/Opponent_move_slower_if_you_are_chasing_them()
	set waitfor=0
	var/mob/m = last_mob_attacked

	var/attack_time = 0
	if(m && (key in m.attack_log)) attack_time = m.attack_log[key][1]

	if(m && m!= src && ismob(m) && current_area == m.current_area && !m.KB && world.time - m.last_knockbacked > 25)
		if(world.time - attack_time < 160 && getdist(src,m) >= chase_start_dist)
			if(get_dir(src,m) in list(dir,turn(dir,45),turn(dir,-45)))
				m.being_chased = world.time

				if(getdist(lord_freeza_obj,m) >= 25) last_chase_from_outside_gym = world.time

				m.chaser_mob=src

mob/proc/Being_chased()
	var/mob/c = chaser_mob
	if(c)
		if(getdist(src,c) >= chase_start_dist || world.time - being_chased < 25)
			if(!(get_dir(src,c) in list(dir,turn(dir,45),turn(dir,-45))) || world.time - being_chased < 17)
				if(world.time - being_chased < 60) return 1
			else being_chased=0
		else being_chased=0





proc/TickMult(n=1)
	if(n<=0) return 0
	var/rounded=round(n,world.tick_lag)
	if(rounded>n) rounded-=world.tick_lag
	var/decimals=n-rounded
	if(prob(decimals * 100 / world.tick_lag)) rounded+=world.tick_lag

	rounded -= 0.001 //eliminate floating point errors test August 22nd 2017 dunno if it will work but its to stop missed frames

	return rounded

proc/ToOne(delay = 1)
	var/isneg = (delay < 0)
	delay = abs(delay)
	var/decimals = delay - round(delay)
	if(prob(decimals * 100)) delay++
	delay = round(delay)
	if(isneg) delay = -delay
	return delay

turf/Jagged_edge_fillers
	Buildable=0
	auto_gen_eligible = 0
	Wall18
		icon='JEF cliff.dmi'
		density=1
		_1
			icon_state="NE"
		_2
			icon_state="NW"
		_3
			icon_state="SW"
		_4
			icon_state="SE"
	Grass10
		icon='JEF green grass.dmi'
		Grass10_1
			icon_state="NE"
		Grass10_2
			icon_state="NW"
		Grass10_3
			icon_state="SW"
		Grass10_4
			icon_state="SE"
		_5
			icon_state="N"
		_6
			icon_state="S"
		_7
			icon_state="E"
		_8
			icon_state="W"










mob/proc
	Get_bp_loss_from_low_ki()
		if(Class=="Spirit Doll") return 0.3
		switch(Race)
			if("Puranto") return 0.3
			if("Yasai") return 1
			if("Half Yasai") return 0.85
			if("Bio-Android") return 0.85
			if("Human") return 0.6
			if("Tsujin") return 0.6
		return 0.9

	Get_bp_loss_from_low_hp()
		switch(Race)
			if("Puranto") return 0.6
			if("Yasai") return 1
			if("Demon") return 0.3
			if("Human") return 0.6
		return 0.9








mob/var/tmp
	mob/flash_step_mob
	flash_stepping
	turf/last_cave_entered
	last_cave_entered_time=0
	last_hit_by_beam = -999999

mob/proc
	Set_flash_step_mob(mob/m)
		flash_step_mob=m

	Can_flash_step()
		if(!CanInputMove()) return
		if(!Can_Move()||grabbedObject||grabber||dash_attacking||beaming||charging_beam||Beam_stunned()||\
		flash_stepping || Frozen) return

		if(dash_attacking || Shadow_Sparring) return
		if(Charging_or_Streaming()) return
		if(!can_zanzoken||stun_level) return
		if(grabbedObject) return
		if(Beam_stunned()) return

		return 1

	Get_flash_step_target(mob/m)
		if(Is_valid_flash_step_target(m)) return m
		m=flash_step_mob
		if(Is_valid_flash_step_target(m)) return m
		m=Manually_find_flash_step_target()
		if(Is_valid_flash_step_target(m)) return m

	Is_valid_flash_step_target(mob/m)
		if(!m||m==src) return
		if(m.last_cave_entered&&m.last_cave_entered.z==z&&getdist(src,m.last_cave_entered)<20)
			//if(viewable(src,m.last_cave_entered))
			SafeTeleport(m.last_cave_entered)
			m.last_cave_entered.Enter(src)
			return 1
		if(m==flash_step_mob&&m.z==z&&getdist(src,m)<50) return 1
		if(m!=flash_step_mob&&m.z==z&&getdist(src,m)<22&&(get_dir(src,m) in list(dir,turn(dir,45),turn(dir,-45))))
			return 1

	Manually_find_flash_step_target()
		for(var/mob/m in players) if(Is_valid_flash_step_target(m)) return m

	Get_flash_step_delay()
		var/n=TickMult(Speed_delay_mult(severity=0.5) * 2.5)
		return n

	Flash_Step()
		var/stam_drain = 10
		if(!Can_flash_step() || stamina < stam_drain) return
		//if(stamina < stam_drain) return
		if(!zanzoken_obj)
			src<<"This ability requires zanzoken"
			return

		/*if(!flash_step_mob || !Is_valid_flash_step_target(flash_step_mob))
			flash_step_mob = Get_flash_step_target(Opponent)
		if(!flash_step_mob) return*/

		flash_step_mob=LungeTarget()
		if(!flash_step_mob) return

		var/turf/t = get_step(flash_step_mob,dir)
		if(!t || t.density) return
		for(var/obj/o in t) if(o.density) return

		var/zz=1
		if(God_Fist_obj && God_Fist_obj.Using) zz*=0.5

		AddStamina(-stam_drain)

		player_view(15,src)<<sound('teleport.ogg',volume=15)
		flick('Zanzoken.dmi',src)
		SafeTeleport(t)
		dir=get_dir(src,flash_step_mob)
		var/defend_chance=66 * (flash_step_mob.Def / Def)
		if(prob(defend_chance)) flash_step_mob.dir=get_dir(flash_step_mob,src)









/*mob/Admin5/verb/test_underlays()
	switch(input("what kind of test?") in list("basic","detailed"))
		if("basic")
			for(var/atom/a)
				if(a.underlays.len>=10)
					alert("[a] has [a.underlays.len] underlays")
		if("detailed")
			for(var/atom/a)
				if(a.underlays.len>=10)
					src<<"Next"
					for(var/image/i as anything in a.underlays)
						src<<"icon = [i.icon]. state = [i.icon_state]"
					alert("[a] has [a.underlays.len] underlays")

mob/Admin5/verb/test_overlays()
	switch(input("what kind of test?") in list("basic","detailed"))
		if("basic")
			for(var/atom/a)
				if(a.overlays.len>=10)
					alert("[a] has [a.overlays.len] overlays")
		if("detailed")
			for(var/atom/a)
				if(a.overlays.len>=10)
					src<<"Next"
					for(var/image/i as anything in a.overlays)
						src<<"icon = [i.icon]. state = [i.icon_state]"
					alert("[a] has [a.overlays.len] overlays")
*/






turf/var/tmp/ki_water

var/image/kwns=image(icon = 'KiWater.dmi',icon_state="NS")
var/image/kwew=image(icon = 'KiWater.dmi',icon_state="EW")

turf/proc/ki_water(d)
	set waitfor=0
	if(ki_water) return
	ki_water=1
	var/image/i
	if(d in list(NORTH,SOUTH)) i=kwns
	else i=kwew
	overlays+=i
	sleep(20)
	ki_water=0
	overlays-=i

mob/var/tmp/turf/last_beam_kb_pos

mob/proc/relative_kb_dist(obj/Blast/b,kb_dist=1)
	if(!b||!b.Owner) return kb_dist
	var/original_kb_dist=kb_dist
	kb_dist*=(b.BP/BP)**1
	if(!b.Bullet) kb_dist*=(b.Force/Res)**0.5
	else kb_dist*=(b.Force/End)**0.5
	if(kb_dist>original_kb_dist*5) kb_dist=original_kb_dist*5
	kb_dist=ToOne(kb_dist)
	return kb_dist

mob/proc/Get_blast_homing_chance(mod = 1)
	var/n=30
	switch(Race)
		if("Puranto") n=55
		if("Android") n=24
		if("Kai") n=40
		if("Majin") n=40
		if("Human") n=40
		if("Tsujin") n=40
	if(Class=="Legendary Yasai") n+=5
	if(Class=="Spirit Doll") n = 50
	n *= blast_homing_mod
	n *= mod
	return n

obj/beam_redirector //when beams are deflected this object is placed down at the spot where it was
//deflected, and the beam uses the object's dir to know which way it should then go
	icon='beam axis.dmi'
	Grabbable=0
	Savable=0
	layer=7
	Health=1.#INF
	New()
		overlays+=icon
		CenterIcon(src)
		the_loop()
	proc/the_loop()
		set waitfor=0
		while(src)
			var/found
			for(var/obj/Blast/b in view(1,src))
				if(src in loc)
					found=1
					break
				if(src in Get_step(b,b.dir))
					found=1
					break
			if(!found) del(src)
			sleep(2)

mob/Admin5/verb
	Diagnose_Effect_Icons()
		set category = "Admin"
		var/list/l = new
		var/noIcon = 0
		for(var/obj/Effect/e in world)
			if(e.icon)
				var/iconTxt = "[e.icon]"
				if(!(iconTxt in l))
					l += iconTxt
					l[iconTxt] = 0
				l[iconTxt] = l[iconTxt] + 1
			else noIcon++
		src << "[noIcon] Effects have no icon"
		var/list/mentioned = new
		for(var/v in l)
			if(!(v in mentioned))
				mentioned += v
				src << "[l[v]] Effects have the [v] icon"


var/list/effect_cache = new

proc/GetEffect()
	var/obj/Effect/e
	for(var/obj/o in effect_cache)
		e = o
		effect_cache -= e
		break
	if(!e) e = new/obj/Effect

	//delete these and use the ones back in Effect/Del() when we are done running diagnostics on what effect icon is most common to fix a lag issue
	ResetVars(e)
	e.icon = null

	return e

obj/Effect
	Savable=0
	Grabbable=0
	Health=1.#INF
	layer=MOB_LAYER+1
	Nukable=0
	Makeable=0
	Givable=0
	density=0
	//blend_mode=BLEND_ADD
	mouse_opacity = 0
	//Dead_Zone_Immune=1
	attackable=0

	Del()
		loc = null
		effect_cache += src

		//re-enable these lines when we are done running diagnostics on which effect icon is most common and DELETE the alternative lines for these we
		//currently have in proc/GetEffect()
		//ResetVars(src)
		//icon = null

		transform = null
		color = null
		alpha = 255
		spinning = 0
		animate(src)

var/list/explosion_cache=new

proc/Get_explosion()
	var/obj/Explosion/e
	for(var/obj/o in explosion_cache)
		e=o
		break
	if(!e) e=new/obj/Explosion
	explosion_cache-=e
	e.Explosion()
	return e

obj/Explosion
	layer=MOB_LAYER+1
	Nukable=0
	Savable=0
	Makeable=0
	Givable=0
	density=0
	Health=1.#INF
	icon_state="1"
	//blend_mode=BLEND_ADD

	proc/Explosion()
		set waitfor=0
		sleep(world.tick_lag)
		CenterIcon(src)
		for(var/v in 1 to 4)
			icon_state="[v]"
			sleep(1)
		del(src)

	Del()
		SafeTeleport(null)
		explosion_cache+=src

var/list/explosion_icons

proc/Initialize_explosion_icons()
	if(explosion_icons) return
	explosion_icons=new/list
	for(var/v in 1 to 5)
		var/icon/i='Explosion1 2013.dmi'
		var/size = 1.3
		i=Scaled_Icon(i, GetWidth(i) * (1.5 ** v) * size, GetHeight(i) * (1.5 ** v) * size)
		explosion_icons+=i

proc/Explosion_Graphics(obj/O,Distance=1,not_used=0)
	set waitfor=0
	//not_used is a 3rd arg from the old explosion graphics, remove it whenever
	Initialize_explosion_icons()
	if(!O) return
	var/obj/Explosion/e=Get_explosion()
	e.SafeTeleport(O.base_loc())
	var/i=Clamp(Distance,0,explosion_icons.len)
	e.icon=explosion_icons[i]



proc/Explosion_Count(list/L)
	var/Amount=0
	for(var/obj/Explosion/E in L) Amount+=1
	return Amount

turf/proc/Make_Damaged_Ground(Amount=1) if(!Water)

	return //doesnt look good

	Amount=1
	var/O=0
	for(var/A in overlays) O+=1
	if(O>=1) return
	while(Amount)
		Amount-=1
		var/image/I=image(icon='crack.dmi',pixel_x=rand(-0,0),pixel_y=rand(-0,0),layer=3.1)
		overlays+=I
		Remove_Damaged_Ground(I)

turf/proc/Remove_Damaged_Ground(image/I)
	set waitfor=0
	sleep(rand(600,3000))
	overlays-=I

mob/proc/Shielding()
	if(Cyber_Force_Field&&Ki>=max_ki*0.1) return 1
	if(shield_obj&&shield_obj.Using) return 1
	if(!Tournament||!skill_tournament||(Tournament&&skill_tournament&&Fighter1!=src&&Fighter2!=src))
		for(var/obj/items/Force_Field/S in item_list) if(S.Level>0) return 1

mob/proc/ki_shield_on() if(shield_obj && shield_obj.Using) return 1

mob/proc/check_lose_tail(dmg=0,obj/culprit)
	if(Health<50&&dir==culprit.dir&&dmg>=40&&Tail)
		player_view(15,src)<<"<font color=cyan>[src]'s tail is sliced off!"
		Tail_Remove()

proc/Get_projectile_shockwave_size(obj/Blast/b)
	if(b.percent_damage>=60) return 512
	if(b.percent_damage>=30) return 256
	if(b.percent_damage>=12) return 128
	return 0

mob/proc/Apply_force_field_damage(obj/items/Force_Field/FF,dmg=0)
	if(!FF) return
	FF.Level-=dmg*1.5
	FF.Force_Field_Desc()
	if(FF.Level<=0)
		player_view(15,src)<<"[src]'s force field is overloaded and explodes!"
		Explosion_Graphics(src,3)
		KO("force field explosion")
		del(FF)
	Force_Field()

var/mob/Tens

proc/Tens(t)
	if(!Tens) return
	Tens << t

mob/proc/ToTens(t)
	if(src.key in list("EXGenesis"))
		src << t

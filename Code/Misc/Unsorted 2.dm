//i did this as a test to stop players with large auras and also ships from showing thru walls
atom/appearance_flags = TILE_BOUND

obj/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	. = ..()
	if(light_obj)
		light_obj.loc = loc
		if(ismob(light_obj.loc)) del(light_obj)

obj/var/tmp
	leaves_big_crater
	big_explosion_on_delete = 0

	respawn_on_delete = 0
	respawn_timer = 3000
	respawn_only_if_no_builder = 1
	respawn_only_if_not_built_by_player = 1
	reset_vars_on_respawn

obj/Turfs/big_explosion_on_delete = 1

obj/Turfs
	respawn_on_delete = 0
	respawn_only_if_no_builder = 1

obj/Trees
	respawn_on_delete = 0
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
		//ObjectRespawn()
	else if(cache_for_reuse)
		CacheObject(src)
	else
		if(objs_can_delete)
			if(light_obj) del(light_obj)
			. = ..()
		else
			loc = null
			if(!deleted)
				deleted = 1
				garbage_collect += src

var/objs_can_delete
var/list/garbage_collect = new
obj/var/tmp/deleted

var/list/pending_object_delete_list=new

obj/var/tmp/reallyDelete //tells obj/Del() to make this object truly be deleted instead of voided or cached or whatever else that would normally happen.

var/lastPendingObjectDeletion = 0
proc/DeletePendingObjects()
	set waitfor = 0
	if(lastPendingObjectDeletion + 600 > world.time) return
	lastPendingObjectDeletion = world.time

	for(var/obj/o in pending_object_delete_list)
		o.reallyDelete = 1
		o.DeleteNoWait()
	pending_object_delete_list = new/list

mob/Del()
	if(current_area)
		current_area.mob_list-=src
		current_area.player_list-=src
		current_area.npc_list-=src
		current_area=null
	if(grabber) grabber.ReleaseGrab()
	if(!istype(src,/mob/Enemy)) Drop_dragonballs()
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
		for(var/obj/o in contents)
			if(istype(o, /obj/Resources))
				o.reallyDelete = 1
				o.DeleteNoWait()
				continue
			nulledPlayerObjects++
			pending_object_delete_list += o
		contents = null
		drone_module = null //just wondering if this reference is why deleting drones lags so bad
		. = ..()

var/nulledPlayerObjects = 0

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
		. = 0.5
		if(Class=="Spirit Doll") return 0
		if(Class=="Legendary") return 0
		switch(Race)
			if("Puranto") return 0.7
			if("Yasai") return 0.3
			if("Half Yasai") return 0.15
			if("Bio-Android") return 0.15
			if("Human") return 0.4
			if("Tsujin") return 0.4
			if("Kai") return 0.05
			if("Majin") return 0.2
			if("Android") return 0

	Get_bp_loss_from_low_hp()
		. = 0.5
		if(Class=="Legendary") return 0
		switch(Race)
			if("Puranto") return 0.4
			if("Yasai") return 0.1
			if("Demon") return 0.7
			if("Human") return 0.4
			if("Bio-Android") return 0.15
			if("Majin") return 0
			if("Android") return 0

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
			src.SendMsg("This ability requires zanzoken", CHAT_IC)
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

		IncreaseStamina(-stam_drain)

		player_view(15,src)<<sound('teleport.ogg',volume=15)
		flick('Zanzoken.dmi',src)
		SafeTeleport(t)
		dir=get_dir(src,flash_step_mob)
		var/defend_chance=66 * (flash_step_mob.Def / Def)
		if(prob(defend_chance)) flash_step_mob.dir=get_dir(flash_step_mob,src)

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
	if(Class=="Legendary") n+=5
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

mob/proc/Shielding()
	if(Cyber_Force_Field&&Ki>=max_ki*0.1) return 1
	if(shield_obj&&shield_obj.Using) return 1

mob/proc/check_lose_tail(dmg=0,obj/culprit)
	if(Health<50&&dir==culprit.dir&&dmg>=40&&Tail)
		player_view(15,src)<<"<font color=cyan>[src]'s tail is sliced off!"
		Tail_Remove()

proc/Get_projectile_shockwave_size(obj/Blast/b)
	if(b.percent_damage>=60) return 512
	if(b.percent_damage>=30) return 256
	if(b.percent_damage>=12) return 128
	return 0
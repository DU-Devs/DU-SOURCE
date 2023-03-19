mob/var
	grab_power=100 //%
	tmp/struggle_timer=0 //time in seconds til you can struggle again

atom/movable/var/tmp/mob/grabber

mob/var/tmp
	mob/grabbedObject //this is not just a mob but anything you are grabbing and carrying around
	is_grabbing
	grabbed_from_behind

atom/var/Grabbable=1
turf/Grabbable=0

var
	max_items = 20

mob/proc/item_count()
	var/n=0
	for(var/obj/items/i in item_list) n++
	return n

mob/proc/ReleaseGrab()
	strangling=0
	if(grabbedObject)
		var/mob/m=grabbedObject
		grabbedObject=null
		m.grabber=null
		if(ismob(m))
			m.grabbed_from_behind=0
			m.Regenerator_loop()

mob/verb/Grab()
	//set category="Skills"

	if(dash_attacking || in_dragon_rush) return

	if(Final_Realm())
		src<<"Grab can not be used in the final realm"
		return
	if(is_grabbing)
		is_grabbing=0
		ReleaseGrab()
		return
	if(using_final_explosion) return
	Safezone() //see safezone proc, related to having Wish Orbs
	if(Action in list("Meditating","Training")) return
	if(grabbedObject) ReleaseGrab()
	else if(!KO&&z)

		for(var/mob/m in get_step(src,dir))
			if(m != src && m.ultra_instinct)
				m.Flip()
				var/d = get_dir(m,src)
				d = turn(d, pick(45,-45))
				density = 0
				step(m, d, 32)
				density = 1

		var/list/L=new

		//combine all rsc bags
		var/obj/Resources/r
		for(var/obj/Resources/r2 in Get_step(src,dir))
			if(!r) r=r2
			else
				r.Value+=r2.Value
				r2.Value = 0
				del(r2)
		if(r) r.Update_value()

		var/list/obj_list = new

		for(var/atom/movable/O in Get_step(src,dir))
			if(O != src && !O.grabber && O.Grabbable && !(O.name in L))
				if(O.type != /obj/items/Dragon_Ball || !(O.type in obj_list))
					L += O.name
					obj_list += O
		L+="Cancel"
		var/T
		if(L.len<=2)
			L-="Cancel"
			for(var/V in L) T=V
		else T=input(src,"Grab what?") in L
		if(T=="Cancel") return
		var/obj/O
		for(var/atom/movable/A in Get_step(src,dir)) if(A.name==T && !A.grabber && A.Grabbable && A != src)
			O=A
			break

		if(!O)
			for(var/mob/m in Get_step(src,turn(dir,45))) if(!m.grabber && m != src)
				O=m
				break
			if(!O)
				for(var/mob/m in Get_step(src,turn(dir,-45))) if(!m.grabber && m != src)
					O=m
					break

		if(!O && (arm_stretch || Extendo_module()) && (dir in list(NORTH,SOUTH,EAST,WEST)))
			O = GetArmStretchTarget(arm_stretch_range)

		if(!O || !O.Grabbable) return

		if(ismob(O))
			var/mob/Temp=O
			if(Temp.Shielding())
				return
			if(Temp.Safezone)
				src<<"You can not grab people in safezones"
				return
			if(Temp.Prisoner())
				src<<"You can not grab prisoners"
				return
		if(ismob(O)&&tournament_override(fighters_can=1)) return
		if(O.Bolted)
			src<<"It is bolted, you can not get it."
			return
		if(istype(O,/obj/items) && item_count() >= MaxItems())
			if(O.type != /obj/items/Dragon_Ball)
				alert(src,"Your inventory is full")
				return

		if(!(O in Get_step(src,dir)))
			is_grabbing=1
			var/old_state=icon_state
			if(ismob(O)) icon_state="Attack"
			if(arm_stretch||Extendo_module())
				move=0
				O=Stretch_arm_to(O,arm_stretch_range)
				move=1
			spawn(4) icon_state=old_state
			is_grabbing=0
		if(!O||isturf(O)) return

		O.ExplodeLandMines()

		if(istype(O,/obj/Resources))
			var/obj/Resources/R=O
			Alter_Res(R.Value)
			R.Value = 0
			player_view(15,src)<<"[src] picks up [O]"
			del(O)

		else if(istype(O,/obj/items)||istype(O,/obj/Module))
			player_view(15,src)<<"[src] picks up [O]"
			if(istype(O,/obj/items/Gravity)) O:Deactivate()
			if(istype(O,/obj/items/Senzu)) O:Senzu_pickup()
			O.Move(src)
			Restore_hotbar_from_IDs()

		else
			if(O.grabber && O.grabber.grabbedObject == O)
				O.grabber.ReleaseGrab() //two people cant be grabbing the same object, it spazzes back and forth and causes duplication bugs too
			grabbedObject = O
			O.grabber = src
			if(ismob(grabbedObject) && grabbedObject.dir==dir)
				grabbedObject.grabbed_from_behind=1
				if(grabbedObject.Tail)
					player_view(15,src)<<"<font color=red>[src] grabs [grabbedObject] by the tail!"
					grabbedObject.Grabbed_by_tail()
			if(ismob(grabbedObject)) grabbedObject.update_area()
			Update_grab_loop()

mob/proc/Grabbed_by_tail()
	set waitfor=0
	while(grabber&&grabbed_from_behind&&Tail)
		Ki-=max_ki / 2 / tail_level
		sleep(10)

proc/remove_nulls(list/l)

	return l //because we have automatic nulls removal on a loop

	for(var/v in l) if(v==null) l-=v
	return l

mob/var
	arm_stretch
	arm_stretch_icon='Namek arm.dmi'
	arm_stretch_range=100

mob/proc
	Extendo_module()
		for(var/obj/Module/Extendo_arm/EA in active_modules) if(EA.suffix) return 1

	Extendo_module_range() return 250

	GetArmStretchTarget(grab_dist = 10)
		if(Extendo_module()) grab_dist = Extendo_module_range()

		var/list/targets = GetArmStretchTargets(grab_dist, Get_step(src,dir), dir)
		var/list/targets2 = GetArmStretchTargets(grab_dist, Get_step(src, turn(dir, 45)), dir)
		var/list/targets3 = GetArmStretchTargets(grab_dist, Get_step(src, turn(dir, -45)), dir)

		for(var/a in targets2) targets += a
		for(var/a in targets3) targets += a

		var/list/mobs = new
		for(var/mob/m in targets) if(m != src) mobs += m

		var/mob/preferred_mob
		if(mobs.len)
			for(var/mob/m in mobs)
				if(!preferred_mob) preferred_mob = m
				else
					if(getdist(src,m) < getdist(src,preferred_mob)) preferred_mob = m

		if(preferred_mob) return preferred_mob

		var/obj/preferred_obj
		for(var/obj/o in targets)
			if(!preferred_obj) preferred_obj = o
			else
				if(getdist(src,o) < getdist(src,preferred_obj)) preferred_obj = o

		return preferred_obj

	GetArmStretchTargets(grab_dist = 10, turf/start_pos, direction)
		if(!start_pos) return
		var/list/targets = new
		var/turf/t = start_pos
		for(var/v in 1 to grab_dist)
			t = Get_step(t, direction)
			if(t && (t.FlyOverAble || !t.density) && !istype(t, /turf/Other/Blank))
				for(var/mob/m in t) if(CanExtendoGrab(m)) targets += m
				for(var/obj/o in t) if(CanExtendoGrab(o)) targets += o
			else break
		return targets

	CanExtendoGrab(mob/m)
		if(!m) return
		if(ismob(m))
			if(!m.grabber && m.Grabbable)
				if(!Tournament || (!m.client || !m.tournament_override(show_message = 0)))
					return 1
		if(isobj(m))
			if(m.Grabbable && !istype(m, /obj/Trees) && !istype(m, /obj/Turfs)) return 1

	/*GetArmStretchTarget(grab_dist=10)
		if(Extendo_module()) grab_dist = Extendo_module_range()
		var/list/targets = new
		var/turf/t = Get_step(src,dir)
		if(t) for(var/v in 1 to grab_dist)
			t = Get_step(t,dir)
			if(t)
				for(var/mob/m in t) if(!m.grabber) targets+=m
				for(var/obj/o in t) if(o.Grabbable || o.density)
					if(!istype(o,/obj/Trees)&&!istype(o,/obj/Turfs)) targets+=o
				//if(t.density) return t
				if(!t.FlyOverAble) return t
				if(istype(t,/turf/Other/Blank)) return t

		t=Get_step(src,turn(dir,45))
		if(t) for(var/v in 1 to 30)
			t=Get_step(t,dir)
			if(t) for(var/mob/m in t) if(!m.grabber) targets+=m

		t=Get_step(src,turn(dir,-45))
		if(t) for(var/v in 1 to 30)
			t=Get_step(t,dir)
			if(t) for(var/mob/m in t) if(!m.grabber) targets+=m

		for(var/mob/m in targets) if(m.Grabbable) if(!Tournament || (!m.client || !m.tournament_override(show_message=0))) return m
		for(var/obj/o in targets) if(o.Grabbable) return o*/

	Get_arm_state(obj/old_arm,obj/new_arm)
		if(get_dir(old_arm,new_arm)==old_arm.dir) return ""
		else if(get_dir(old_arm,new_arm)==turn(old_arm.dir,90)) return "left turn"
		else if(get_dir(old_arm,new_arm)==turn(old_arm.dir,-90)) return "right turn"

	Grab_failed(mob/m, list/arms, step_number=0, grab_dist=0, obj/last_arm, turf/starting_loc)
		if(!m || m.z != z || arms.len != step_number || loc != starting_loc) return 1
		if(step_number == grab_dist)
			if(!isturf(m) && m.loc != last_arm.loc) return 1
			else if(m != last_arm.loc) return 1
		if(!is_grabbing) return 1 //grab cancelled by user i think

	Destroy_arms(list/arms)
		while(arms.len)
			del(arms[arms.len])
			arms.len--
			sleep(1)

	Get_next_arm_position(obj/old_arm,mob/m)
		if(get_dir(old_arm,m)==old_arm.dir) return Get_step(old_arm,old_arm.dir)
		if(get_dir(old_arm,m) in list(turn(old_arm.dir,45),turn(old_arm.dir,90),turn(old_arm.dir,135)))
			return Get_step(old_arm,turn(old_arm.dir,90))
		if(get_dir(old_arm,m) in list(turn(old_arm.dir,-45),turn(old_arm.dir,-90),turn(old_arm.dir,-135)))
			return Get_step(old_arm,turn(old_arm.dir,-90))
		if(get_dir(old_arm,m)==turn(old_arm.dir,180))
			return pick(Get_step(old_arm,turn(old_arm.dir,90)),Get_step(old_arm,turn(old_arm.dir,-90)))

	Stretch_arm_to(mob/m,grab_dist=10)
		//var/arm_velocity=Speed_delay_mult(severity=0.3)
		var/arm_velocity = world.tick_lag * 0.9
		var/arm_icon=arm_stretch_icon

		if(Extendo_module())
			grab_dist=Extendo_module_range()
			arm_velocity=1
			arm_icon='droid arm.dmi'

		var/turf/starting_loc=loc
		var/turf/arm_pos=loc
		var/list/arms=new

		for(var/step_number in 1 to grab_dist)
			arms=remove_nulls(arms)
			var/obj/stretch_arm/arm = GetCachedObject(/obj/stretch_arm, arm_pos)
			arm.icon=arm_icon

			if(arms.len>1) arm.dir=get_dir(arms[arms.len],arm)
			else arm.dir=dir

			if(step_number==1) arm.icon_state="begin"
			else arm.icon_state="end"
			if(arms.len>1) //dont change the appearance of the "origin" arm segment
				var/obj/previous_arm=arms[arms.len]
				if(previous_arm) previous_arm.icon_state=Get_arm_state(previous_arm,arm)

			if(step_number==1) //the first arm segment other than the "origin" must be straight out in front
				arm_pos=Get_step(src,dir)
			else arm_pos=Get_next_arm_position(arm,m)

			arms+=arm

			if(Grab_failed(m,arms,step_number,grab_dist,arm,starting_loc))
				Destroy_arms(arms)
				return

			if(m.loc==arm.loc||m==arm.loc) break //if m==arm.loc, m was a turf
			else sleep(TickMult(arm_velocity))

		//pull them to you
		while(arms.len)
			var/obj/last_arm=arms[arms.len]
			if(!last_arm.z) return
			else
				//prevent pulling people thru houses bug
				var/turf/t
				if(last_arm) t=last_arm.loc
				if(t&&isturf(t)&&!t.FlyOverAble&&t.opacity) //roof
					Destroy_arms(arms)
					return

				if(last_arm)
					last_arm.icon_state="end"
					if(m && !isturf(m) && is_grabbing && m.z == z) m.SafeTeleport(last_arm.loc)

			if(KB)
				Destroy_arms(arms)
				return
			arms.len--
			sleep(TickMult(world.tick_lag))
			if(last_arm) del(last_arm)

		if(m && is_grabbing) return m

obj/stretch_arm
	icon='Namek arm.dmi'
	Grabbable=0
	Bolted=1
	layer=6
	Savable = 0

mob/proc/Update_grab()
	set waitfor=0
	if(grabbedObject)
		if(ismob(grabbedObject)) grabbedObject.SafeTeleport(loc)
		else if(isobj(grabbedObject))
			grabbedObject.SafeTeleport(loc)
		if(ismob(grabbedObject))
			grabbedObject.dir=turn(dir,180)
			if(grabbedObject.grabbedObject && grabbedObject.grabbedObject!=src) grabbedObject.Update_grab()
		if(istype(grabbedObject,/mob/Body)) if(Cook_Check(grabbedObject)) Cook(grabbedObject)
	if(grabber) SafeTeleport(grabber.loc)

mob/proc/Update_grab_loop()
	while(grabbedObject)
		Update_grab()
		sleep(2)
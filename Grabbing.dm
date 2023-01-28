mob/var
	grab_power=100 //%
	tmp/struggle_timer=0 //time in seconds til you can struggle again
atom/movable/var/tmp/mob/grabber
mob/var/tmp
	mob/grabbed_mob
	is_grabbing
	grabbed_from_behind
atom/var/Grabbable=1
turf/Grabbable=0
var/max_items=30
mob/proc/item_count()
	var/n=0
	for(var/obj/items/i in item_list) n++
	return n
mob/proc/Release_grab()
	strangling=0
	if(grabbed_mob)
		var/mob/m=grabbed_mob
		grabbed_mob=null
		m.grabber=null
		if(ismob(m))
			m.grabbed_from_behind=0
			m.Regenerator_loop()

mob/verb/Grab()
	set category="Skills"
	if(dash_attacking) return
	if(Final_Realm())
		src<<"Grab can not be used in the final realm"
		return
	if(is_grabbing)
		is_grabbing=0
		Release_grab()
		return
	Safezone() //see safezone proc, related to having dragon balls
	if(Action in list("Meditating","Training")) return
	if(grabbed_mob) Release_grab()
	else if(!KO&&z)
		var/list/L=new

		//combine all rsc bags
		var/obj/Resources/r
		for(var/obj/Resources/r2 in Get_step(src,dir))
			if(!r) r=r2
			else
				r.Value+=r2.Value
				del(r2)
		if(r) r.Update_value()

		for(var/atom/movable/O in Get_step(src,dir)) if(!O.grabber&&O.Grabbable&&!(O.name in L)) L+=O.name
		L+="Cancel"
		var/T
		if(L.len<=2)
			L-="Cancel"
			for(var/V in L) T=V
		else T=input(src,"Grab what?") in L
		if(T=="Cancel") return
		var/obj/O
		for(var/atom/movable/A in Get_step(src,dir)) if(A.name==T&&!A.grabber&&A.Grabbable)
			O=A
			break

		if(!O)
			for(var/mob/m in Get_step(src,turn(dir,45))) if(!m.grabber)
				O=m
				break
			if(!O)
				for(var/mob/m in Get_step(src,turn(dir,-45))) if(!m.grabber)
					O=m
					break

		if(!O&&(arm_stretch||Extendo_module())&&(dir in list(NORTH,SOUTH,EAST,WEST)))
			O=Get_arm_stretch_target(arm_stretch_range)
		if(!O||!O.Grabbable) return
		if(ismob(O))
			var/mob/Temp=O
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
		if(istype(O,/obj/items)&&item_count()>=max_items)
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

		if(istype(O,/obj/Resources))
			var/obj/Resources/R=O
			Alter_Res(R.Value)
			player_view(15,src)<<"[src] picks up [O]"
			del(O)
		else if(istype(O,/obj/items)||istype(O,/obj/Module))
			player_view(15,src)<<"[src] picks up [O]"
			if(istype(O,/obj/items/Gravity)) O:Deactivate()
			if(istype(O,/obj/items/Senzu)) O:Senzu_pickup()
			O.Move(src)
			Restore_hotbar_from_IDs()
		else
			grabbed_mob=O
			O.grabber=src
			if(ismob(grabbed_mob)&&grabbed_mob.dir==dir)
				grabbed_mob.grabbed_from_behind=1
				if(grabbed_mob.Tail)
					player_view(15,src)<<"<font color=red>[src] grabs [grabbed_mob] by the tail!"
					grabbed_mob.Grabbed_by_tail()
			Update_grab_loop()
mob/proc/Grabbed_by_tail()
	spawn while(grabber&&grabbed_from_behind&&Tail)
		Ki-=max_ki/30/tail_level
		sleep(10)
proc/remove_nulls(list/l)

	return l //because we have automatic nulls removal on a loop

	for(var/v in l) if(v==null) l-=v
	return l
mob/var
	arm_stretch
	arm_stretch_icon='namek arm.dmi'
	arm_stretch_range=100
mob/proc
	Extendo_module()
		for(var/obj/Module/Extendo_arm/EA in active_modules) if(EA.suffix) return 1
	Extendo_module_range() return 250
	Get_arm_stretch_target(grab_dist=10)
		if(Extendo_module()) grab_dist=Extendo_module_range()
		var/list/targets=new
		var/turf/t=Get_step(src,dir)
		if(t) for(var/v in 1 to grab_dist)
			t=Get_step(t,dir)
			if(t)
				for(var/mob/m in t) if(!m.grabber) targets+=m
				for(var/obj/o in t) if(o.Grabbable||o.density)
					if(!istype(o,/obj/Trees)&&!istype(o,/obj/Turfs)) targets+=o
				//if(t.density) return t
				if(!t.FlyOverAble) return t
				if(istype(t,/turf/Other/Blank)) return t

		t=Get_step(src,turn(dir,45))
		if(t) for(var/v in 1 to 30)
			t=Get_step(t,dir)
			if(t) for(var/mob/m in t) if(!m.grabber) targets+=m
		t=Get_step(src,turn(dir,45))
		if(t) for(var/v in 1 to 30)
			t=Get_step(t,dir)
			if(t) for(var/mob/m in t) if(!m.grabber) targets+=m

		for(var/mob/m in targets) if(!Tournament||(!m.client||!m.tournament_override(show_message=0))) return m
		for(var/obj/o in targets) return o
	Get_arm_state(obj/old_arm,obj/new_arm)
		if(get_dir(old_arm,new_arm)==old_arm.dir) return ""
		else if(get_dir(old_arm,new_arm)==turn(old_arm.dir,90)) return "left turn"
		else if(get_dir(old_arm,new_arm)==turn(old_arm.dir,-90)) return "right turn"
	Grab_failed(mob/m,list/arms,step_number=0,grab_dist=0,obj/last_arm,turf/starting_loc)
		if(!m||arms.len!=step_number||loc!=starting_loc) return 1
		if(step_number==grab_dist)
			if(!isturf(m)&&m.loc!=last_arm.loc) return 1
			else if(m!=last_arm.loc) return 1
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
		var/arm_velocity=Speed_delay_mult(severity=0.3)
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
			var/obj/stretch_arm/arm=new(arm_pos)
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
			else sleep(To_tick_lag_multiple(arm_velocity))
		//pull them to you
		while(arms.len)
			var/obj/last_arm=arms[arms.len]

			//prevent pulling people thru houses bug
			var/turf/t
			if(last_arm) t=last_arm.loc
			if(t&&isturf(t)&&!t.FlyOverAble&&t.opacity) //roof
				Destroy_arms(arms)
				return

			if(last_arm)
				last_arm.icon_state="end"
				if(m&&!isturf(m)&&is_grabbing) m.loc=last_arm.loc
			arms.len--
			sleep(1)
			if(last_arm) del(last_arm)
		if(m&&is_grabbing) return m
obj/stretch_arm
	icon='namek arm.dmi'
	Grabbable=0
	Bolted=1
	layer=6
	New()
		spawn(5*600) if(src) del(src)
mob/proc/Update_grab()
	if(grabbed_mob)
		grabbed_mob.loc=loc
		if(ismob(grabbed_mob))
			grabbed_mob.dir=turn(dir,180)
			if(grabbed_mob.grabbed_mob && grabbed_mob.grabbed_mob!=src) grabbed_mob.Update_grab()
		if(istype(grabbed_mob,/mob/Body)) if(Cook_Check(grabbed_mob)) Cook(grabbed_mob)
	if(grabber) loc=grabber.loc

mob/proc/Update_grab_loop()
	while(grabbed_mob)
		Update_grab()
		sleep(2)
mob/var/tmp/list/Lootables

obj/Cancel_Loot
	name="Cancel"
	Click() usr.Lootables=null

client/Click(obj/A)
	if(A in Technology_List)
		if(mob.KO) return
		if(mob.Final_Realm())
			src<<"Items can not be made in the final realm"
			return
		var/turf/t=mob.True_Loc()
		if(t&&t.z==10) //hbtc
			if(A.type==/obj/Spawn)
				src<<"Spawns can not be made in the time chamber"
				return
		if(A.type in Illegal_Science)
			src<<"<font size=3><font color=red>Admins have made this item illegal. You can not make it"
			return
		if(Can_Make_Technology(mob,A)&&mob.resource_obj)

			if(A.type==/obj/Ships/Ship&&!Get_ship_interior())
				src<<"There are no more ship interiors available to use for a new ship"
				return

			var/obj/Resources/M=mob.resource_obj
			M.Value-=Item_cost(mob,A)
			if(toxic_waste_on&&A.makes_toxic_waste)
				src<<"Toxic waste was created as a byproduct of manufacturing this technology"
				new/obj/Toxic_Waste_Barrel(mob.True_Loc())
			var/obj/O=new A.type(mob.loc)
			if(O)
				O.Cost=Item_cost(mob,A)
				O.Builder=key

				if(istype(O,/obj/Ships/Ship)&&mob.Race=="Namek")
					O.icon='Puran Ship.dmi'
					Center_Icon(O)
				if(istype(O,/obj/items/Scouter)&&mob.Race=="Human")
					O.icon='Item - Sun Glassess.dmi'
					O.name="Scanner"
				if(istype(O,/obj/Spawn))
					O.Health=100000
					usr<<"Don't forget to upgrade the spawn's BP/health by right clicking it"

			spawn if(!O) M.Value+=Item_cost(mob,A)
	else if(mob.Lootables&&mob&&isobj(A)&&(A in mob.Lootables)&&!istype(A,/obj/Cancel_Loot)) for(var/mob/B in view(1,mob)) if(A.loc==B)
		if(!B.KO)
			usr<<"They are no longer knocked out"
			mob.Lootables=null
			return
		if(!(A in B.item_list)&&!istype(A,/obj/Resources))
			usr<<"Someone has already taken it"
			mob.Lootables-=A
			return
		if(!(B in oview(1,mob)))
			usr<<"You are not near them"
			mob.Lootables=null
		mob.Lootables-=A
		if(istype(A,/obj/Resources))
			var/obj/Resources/C=A
			player_view(15,mob)<<"[mob] ([mob.displaykey]) steals [Commas(C.Value)] resources from [B]"
			mob.Alter_Res(C.Value)
			C.Value=0
			C.Update_value()
		else
			if(A==B.Scouter) B.Scouter=null
			player_view(15,mob)<<"[mob] ([mob.displaykey]) steals [A] from [B]"
			B.overlays-=A.icon
			if(A.suffix)
				if(istype(A,/obj/items/Sword)) B.Apply_Sword(A)
				if(istype(A,/obj/items/Armor)) B.Apply_Armor(A)
			A.Move(mob)
			if(A.suffix=="Equipped") A.suffix=null
			if(B) B.Restore_hotbar_from_IDs()
	else if(A in Alien_Icons) A:Choose(usr)
	else if(A in Demon_Icons) A:Choose(usr)
	else ..()
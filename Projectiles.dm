mob/var/tmp/turf/last_beam_kb_pos
mob/proc/relative_kb_dist(obj/Blast/b,kb_dist=1)
	if(!b||!b.Owner) return kb_dist
	var/original_kb_dist=kb_dist
	kb_dist*=(b.BP/BP)**1
	if(!b.Bullet) kb_dist*=(b.Force/Res)**0.5
	else kb_dist*=(b.Force/End)**0.5
	if(kb_dist>original_kb_dist*5) kb_dist=original_kb_dist*5
	kb_dist=To_multiple_of_one(kb_dist)
	return kb_dist
/*
the damage var of projectiles needs removed
the BP and Force vars need replaced with:
blast_bp: the bp of the player unaltered
blast_force: the force of the player unaltered
damage_percent: the percent multiplier of the damage inherited from the move that was used
*/
turf/var/tmp/ki_water

var/image/kwns=image(icon='KiWater.dmi',icon_state="NS")
var/image/kwew=image(icon='KiWater.dmi',icon_state="EW")

turf/proc/ki_water(d) spawn if(src)

	return //lag, idk why, but was #1 lag source

	if(ki_water) return
	ki_water=1
	var/image/i
	if(d in list(NORTH,SOUTH)) i=kwns
	else i=kwew
	overlays+=i
	sleep(20)
	ki_water=0
	overlays-=i

obj/Blast/proc/set_stats(mob/P,Percent=1,Off_Mult=1,Explosion=0,bullet=0)
	Health=0.2*P.BP*(Percent**0.4)
	takes_gradual_damage=1
	Fatal=P.Fatal
	Owner=P
	BP=P.BP

	if(ismob(P)) wall_breaking_power=P.Wall_breaking_power()
	else wall_breaking_power=BP

	percent_damage=Percent
	if(!bullet)
		Force=P.Pow
		percent_damage*=ki_power
	else
		Force=P.Str
		percent_damage*=melee_power
	Offense=P.Off*Off_Mult
	Explosive=Explosion
	if(ismob(P))
		user_speed=P.Spd
		homing_chance=P.Get_blast_homing_chance()
		//laggy
		/*if(!Beam)
			var/new_size=P.BPpcnt/100
			if(new_size<0.5) new_size=0.5
			Update_transform_size(new_size)*/
	//world<<"BP: [BP]<br>Force: [Force]<br>Offense: [Offense]"
mob/var/blast_homing_mod=1
mob/proc/Get_blast_homing_chance()
	var/n=30
	switch(Race)
		if("Namek") n=55
		if("Android") n=24
		if("Kai") n=40
		if("Majin") n=40
		if("Human") n=40
		if("Tsujin") n=40
		if("Spirit Doll") n=50
	if(Class=="Legendary Saiyan") n+=5
	n*=blast_homing_mod
	return n
obj/var/Stun
obj/beam_redirector //when beams are deflected this object is placed down at the spot where it was
//deflected, and the beam uses the object's dir to know which way it should then go
	icon='beam axis.dmi'
	Grabbable=0
	Savable=0
	layer=7
	Health=1.#INF
	New()
		overlays+=icon
		Center_Icon(src)
		the_loop()
	proc/the_loop() spawn while(src)
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

var/list/cached_blasts=new
obj/Blast/var/in_use
proc/fill_cached_blasts()
	for(var/v in 1 to 50) cached_blasts+=new/obj/Blast
proc/get_cached_blast()
	for(var/obj/Blast/b in cached_blasts) if(!b.in_use)
		b.in_use=1

		//reset everything back to defaults
		b.pixel_x=0
		b.pixel_y=0
		b.overlays=new/list
		b.New()

		b.Owner=null
		walk(b,0)
		b.deflected=0
		b.wall_breaking_power=0
		b.vampire_damage_multiplier=1
		b.delete_on_next_move=0
		b.Stun=0
		b.Explosive=0
		b.Shockwave=0
		b.Piercer=0
		b.Paralysis=0
		b.Beam=0
		b.slice_attack=0
		b.Shrapnel=0
		b.Bounce=0
		b.Deflectable=1
		b.apply_short_range_beam_knock=1
		b.Size=0
		b.Spread=0
		b.density=1
		b.Distance=initial(b.Distance)
		b.glide_size=initial(b.glide_size)
		b.deflect_difficulty=initial(b.deflect_difficulty)
		b.Can_Home=initial(b.Can_Home)
		b.Update_transform_size(1)
		b.beam_loop_running=0
		//--------

		return b
	//no blasts found, create more
	fill_cached_blasts()
	return get_cached_blast()
obj/Blast/proc/cache_blast()
	walk(src,0)
	loc=null
	in_use=0
	cached_blasts-=src
	cached_blasts+=src //add to end of list
//blast deleted at 0, 0, 0. in use = 0. from attack = Blast. owner = Tens

var/list/all_blast_objs=new

area/var/tmp/list/blast_objs=new

obj/Blast/Del()

	var/area/a=get_area()
	if(a) a.blast_objs-=src

	var/mob/m=Owner
	if(m&&ismob(m)) m.my_beam_objs-=src
	if(Shrapnel) Shrapnel()
	if(in_use) cache_blast()
	else
		//Tens("blast deleted at [x], [y], [z]. in use = [in_use]. from attack = [from_attack]. owner = [Owner]")
		all_blast_objs-=src
		..()

var/mob/Tens
proc/Tens(t)
	if(!Tens||!Tens.client||!Tens.Is_Tens()) for(var/mob/m in players)
		if(m.Is_Tens())
			Tens=m
			break
	if(Tens&&t) Tens<<t

obj/Blast
	var/transform_size=1
	var/tmp/beam_loop_running
	var/tmp/obj/from_attack //temporary debugging var
	var
		Is_Ki=1
		user_speed
		homing_chance=30
	var/percent_damage=1
	var/Force=1
	var/Offense=1
	var/vampire_damage_multiplier=1
	var/wall_breaking_power=0
	Fatal=1
	var/Damage //Some procs set Damage=BP*Force
	var/Explosive=0
	var/Shockwave=0
	var/Piercer
	var/Paralysis
	var/Beam
	var/slice_attack
	var/Shrapnel
	var/Bounce
	var/Deflectable=1
	var/apply_short_range_beam_knock=1
	var/Size
	var/Spread //it will hit anything in Get_step(90,-90)
	var/Noob_Attack //leaves no death message
	layer=6
	Savable=0
	density=1
	Grabbable=0
	var/Distance=30
	var/deflected //sets to 1 if deflected so that controlled moves arent controllable any more
	var/tmp/turf/last_object_shockwaved_against //to prevent shockwave spamming the same turf repeatedly, causing lag
	proc/Update_transform_size(new_size=1)
		if(new_size==transform_size) return
		var/mult=new_size/transform_size
		transform*=mult
		transform_size=new_size

	proc/Shrapnel() if(Shrapnel)
		var/turf/T=loc
		if(!isturf(T)) return
		var/N=5
		while(N)
			N--
			var/obj/Blast/A=new(T)
			A.Distance=20
			A.icon=icon
			A.Owner=T
			A.BP=BP/5
			A.Force=Force
			A.percent_damage=percent_damage
			A.Offense=Offense
			A.Fatal=Fatal
			A.Bounce=Bounce
			walk(A,pick(NORTH,SOUTH,EAST,WEST,NORTHWEST,NORTHEAST,SOUTHWEST,SOUTHEAST))

	var/delete_on_next_move=0

	Move(NewLoc,Dir=0,step_x=0,step_y=0)

		if(delete_on_next_move)
			//Tens("Blast deleting because delete_on_next_move=1 ([x],[y],[z])")
			del(src)
		if(!z)
			//Tens("Blast deleting because it tried to move while in the void")
			del(src) //blasts should not be moving in the void that is a bug its eating cpu

		if(icon_state=="origin")
			icon_state="tail"
			layer=initial(layer)-0.2
			Update_diagonal_overlays()

		/*if(density&&!Sokidan)
			Distance-=1
			if(Distance<=0)
				Explode()
				Tens("Blast ran out of distance, deleting ([x],[y],[z])")
				del(src)*/
		Distance--
		if(Distance<=0)
			Explode()
			//Tens("Blast ran out of distance, deleting ([x],[y],[z])")
			del(src)

		if(Size) for(var/atom/A in orange(Size,src)) if(A!=src&&A.density&&!isarea(A)) Bump(A)
		if(Spread)
			for(var/atom/A in Get_step(src,turn(dir,90))) if(A!=src&&A.density&&!isarea(A)) Bump(A)
			for(var/atom/A in Get_step(src,turn(dir,-90))) if(A!=src&&A.density&&!isarea(A)) Bump(A)
		if(src)
			if(dir in list(NORTH,SOUTH,EAST,WEST))
				var/turf/t=loc
				if(isturf(t)&&t.Water) t.ki_water(dir)
			if(!Blast_Homing()) ..()
			steps_since_last_homing_check++
		if(z&&!Get_step(src,dir))
			//Tens("Blast deleting because no turf found in Get_step(src,dir) ([x],[y],[z])")
			del(src) //it is colliding with the void, walk() seems to no longer
		//call itself when the blast is colliding with the void so therefore neither will Move(), so
		//the blast will just sit next to the void forever if i dont put this.

	var/Can_Home=1
	var/tmp/mob/blast_homing_target

	proc/Is_viable_homing_target(mob/m)
		var/mob/bht=blast_homing_target
		if(bht && bht.z==z && (Owner!=bht || deflected) && getdist(src,bht)<15 && get_dir(src,bht)==dir)
			if(m==bht) return 1
			else return
		if(m && m.z==z && (Owner!=m || deflected) && getdist(src,m)<15 && (get_dir(src,m) in list(dir,turn(dir,45),turn(dir,-45))))
			return 1

	proc/Get_blast_homing_target()
		if(Tournament && z==7 && ismob(Owner) && (Fighter1==Owner || Fighter2==Owner))
			var/mob/homing_target=Fighter1
			if(homing_target==Owner) homing_target=Fighter2
			if(Is_viable_homing_target(homing_target)) return homing_target
			else return
		if(blast_homing_target && Is_viable_homing_target(blast_homing_target)) return blast_homing_target
		if(steps_since_last_homing_check&&steps_since_last_homing_check<5) return
		steps_since_last_homing_check=0
		var/area/a=locate(/area) in range(0,src)
		if(!a) return
		var/list/viable_targets=new
		for(var/mob/m in a.player_list) if(Is_viable_homing_target(m)) viable_targets+=m
		if(viable_targets.len) return pick(viable_targets)
		for(var/mob/m in a.npc_list) if(Is_viable_homing_target(m)) viable_targets+=m
		if(viable_targets.len) return pick(viable_targets)
	var/tmp/steps_since_last_homing_check=0
	proc/Blast_Homing()
		if(prob(homing_chance*0.7))
			if(!Beam&&Can_Home&&z)
				blast_homing_target=Get_blast_homing_target()
				if(!blast_homing_target||get_dir(src,blast_homing_target)==dir) return
				var/old_dir=dir
				Can_Home=0
				step(src,get_dir(src,blast_homing_target))
				Can_Home=1
				dir=old_dir
				return 1
	New()
		spawn if(src)
			var/area/a=get_area()
			if(a) a.blast_objs+=src

		all_blast_objs+=src
		spawn if(src) if(Get_Width(icon)>36||Get_Height(icon)>36) Center_Icon(src)
		if(type!=/obj/Blast/Genki_Dama)
			spawn(1) if(Owner&&ismob(Owner)&&Owner.icon_state!="Attack") if(Owner.client) flick("Attack",Owner)
			//spawn(300) if(src) del(src)
		spawn Edge_Check()
		spawn(30) if(src&&z&&!Get_step(src,dir)) del(src)
	proc/Beam_Appearance() if(Beam&&z)
		if(!(icon_state in list("origin","struggle","bend right","bend left")))
			if(!(locate(/obj/Blast) in Get_step(src,dir)))
				icon_state="head"
				layer=initial(layer)-0.1
			else if(!(locate(/obj/Blast) in Get_step(src,turn(dir,180))))
				icon_state="end"
				Update_diagonal_overlays()
		if(icon_state in list("head","struggle"))
			var/obj/Blast/o=locate(/obj/Blast) in Get_step(src,turn(dir,180))
			if(!o||o.Owner!=Owner||!o.Beam) del(src)
	proc/Update_diagonal_overlays()
		overlays-=overlays
		if(icon_state in list("tail","head","struggle"))
			if(dir in list(NORTHEAST,NORTHWEST,SOUTHEAST,SOUTHWEST))
				var/image/i=image(icon=src.icon,icon_state=src.icon_state,layer=src.layer-0.1)
				var/pix_x=0
				var/pix_y=0
				switch(dir)
					if(SOUTHEAST)
						pix_x=-12
						pix_y=12
					if(SOUTHWEST)
						pix_x=12
						pix_y=12
					if(NORTHEAST)
						pix_x=-12
						pix_y=-12
					if(NORTHWEST)
						pix_x=12
						pix_y=-12
				i.pixel_x=pix_x
				i.pixel_y=pix_y
				overlays+=i
	proc/Shield(mob/A)
		for(var/obj/items/Force_Field/S in A.item_list) if(S.Level>0)
			var/force_vs_res=Force/Avg_Res()
			if(force_vs_res>1) force_vs_res=force_vs_res**0.5
			var/Dmg=BP*percent_damage*force_vs_res*0.0017
			if(A.fearful||A.Good_attacking_good()) Dmg*=A.Fear_dmg_mult()
			if(Owner&&ismob(Owner)&&Owner.is_kiting) Dmg*=kiting_penalty
			if(A.is_teamer) Dmg*=teamer_dmg_mult
			if(Owner&&ismob(Owner)&&Owner.is_teamer) Dmg/=teamer_dmg_mult
			A.Apply_force_field_damage(S,Dmg)
			return
		if(A.Cyber_Force_Field)
			var/Dmg=(BP*Force*percent_damage)/(A.BP*A.Res)
			A.Ki-=(Dmg/100)*A.max_ki
			if(A.Ki<=0) for(var/obj/Module/Force_Field/F in A.active_modules)
				F.Disable_Module(A)
				A<<"Your cybernetic force field has been damaged. You must re-install it to make it active again."
			for(var/obj/Blast/B in Get_step(src,turn(dir,180))) if(B.Beam) B.icon_state="struggle"
			A.Force_Field('Electro Shield.dmi')
			return
		if(A.shield_obj&&A.shield_obj.Using)
			var/Dmg=shield_reduction * (A.max_ki/100/(A.Eff**shield_exponent)) * (BP/A.BP)**0.5 * (Force/A.Res)**0.5 * percent_damage * A.Generator_reduction(is_melee=Bullet)
			if(A.fearful||A.Good_attacking_good()) Dmg*=A.Fear_dmg_mult()
			if(Owner&&ismob(Owner)&&Owner.is_kiting) Dmg*=kiting_penalty
			if(A.is_teamer) Dmg*=teamer_dmg_mult
			if(Owner&&ismob(Owner)&&Owner.is_teamer) Dmg/=teamer_dmg_mult
			A.Ki-=Dmg
			if(A.Ki<=0) A.Shield_Revert()
			for(var/obj/Blast/B in Get_step(src,turn(dir,180))) if(B.Beam) B.icon_state="struggle"
			return
	proc/Beam(loop_delay=1)
		while(src)
			beam_loop_running=1
			if(delete_on_next_move) return
			if(!z) return //for blast caching, cancel loop
			Damage=BP*Force*percent_damage*loop_delay
			if(!Owner) del(src)

			/*if(ismob(Owner)&&Owner.Is_Tens())
				var/death_damage=Damage/loop_delay/Beam_Delay
				var/death_resist=Owner.BP*Owner.Res*10*Owner.Regenerate**0.5*ki_power
				Owner<<"death damage: [Commas(death_damage)]<br>\
				death resist: [Commas(death_resist)]"*/

			var/obj/beam_redirector/br=locate(/obj/beam_redirector) in loc

			if(!br&&Deflectable&&(icon_state in list("head","struggle")))
				for(var/mob/m in Get_step(src,dir)) if(!m.KO&&!m.grabber)
					m.dir=get_dir(m,src)
					var/deflect_chance=Beam_Delay*loop_delay*(5/deflect_difficulty)*(m.BP/Owner.BP)* (1/(Acc_mult(Clamp(Owner.Off/m.Def,0.1,10))))
					if(m.beaming) deflect_chance=0
					if(m.beam_struggling) deflect_chance/=5
					if(m.standing_powerup) deflect_chance*=standing_powerup_deflect_mult
					if(m.fearful||m.Good_attacking_good()) deflect_chance/=m.Fear_dmg_mult()
					if(m.is_teamer) deflect_chance/=teamer_dmg_mult
					if(Owner&&ismob(Owner)&&Owner.is_teamer) deflect_chance*=teamer_dmg_mult

					if(Owner&&ismob(Owner))
						deflect_chance*=Owner.Speed_accuracy_mult(defender=m)

					if(prob(deflect_chance))
						flick("Attack",m)
						var/obj/beam_redirector/br2=new(loc)
						br2.dir=pick(turn(dir,90),turn(dir,-90))
						br=br2
						break
			if(!br)
				for(var/mob/A in range(0,src))
					if(Owner&&ismob(Owner))
						Owner.Set_flash_step_mob(A)
						if(A==Owner.chaser)
							Owner.last_damaged_chaser=0
							Owner.Remove_fear()
					spawn if(A&&A.drone_module&&Owner) A.Drone_Attack(Owner,lethal=1)
					A.last_attacked_time=world.time
					if(A.Shielding())
						Shield(A)
						del(src)
						return
					else if(A.Absorb_Blast(src))
						del(src)
						return
					if(A.precog&&A.precogs&&prob(A.precog_chance)&&!A.KO&&(A.Flying||A.icon_state=="")&&A.Ki>A.max_ki*0.2&&!A.Disabled())
						A.precogs--
						//A.Ki-=A.Ki/30/A.Eff**0.4
						var/turf/old_loc=A.loc
						step(A,turn(dir,pick(-45,45)))
						if(A.loc!=old_loc) return
					else
						var/mob/P=A
						if(prob(80)) for(var/mob/MM in range(0,A)) if(MM.Is_Grabbed()) P=MM

						var/force_vs_resist=(Force/P.Res)
						if(force_vs_resist>1) force_vs_resist=force_vs_resist**superior_force_exponent
						else force_vs_resist=force_vs_resist**inferior_force_exponent

						var/dmg=1.2*percent_damage*loop_delay*(BP/P.BP)**0.6*force_vs_resist
						dmg*=Defense_damage_reduction(Owner,P)
						if(ismob(Owner)&&Owner.alignment=="Evil") dmg*=villain_damage_penalty
						if(P.fearful||P.Good_attacking_good()) dmg*=P.Fear_dmg_mult()
						if(Owner&&ismob(Owner)&&Owner.is_kiting) dmg*=kiting_penalty
						if(P.is_teamer) dmg*=teamer_dmg_mult
						if(Owner&&ismob(Owner)&&Owner.is_teamer) dmg/=teamer_dmg_mult

						if(ismob(Owner))
							var/resist_dmg_mod=(Owner.Res/Owner.Pow)**0.35
							if(resist_dmg_mod>1) resist_dmg_mod=1
							if(resist_dmg_mod<0.5) resist_dmg_mod=0.5
							dmg*=resist_dmg_mod

						dmg*=sagas_bonus(Owner,P)
						if(ismob(Owner)) Owner.training_period(P)

						if(getdist(Owner,P)<beam_stun_start)
							dmg/=Beam_Delay**0.7 //because slow beams would be too effective at close range
							dmg*=2.5
						if(Owner.beam_struggling) dmg*=10
						if(P.Vampire) dmg*=vampire_damage_multiplier
						P.Health-=dmg
						if(ismob(Owner)&&!P.KO) P.set_opponent(Owner)
						for(var/mob/M in Get_step(src,dir))
							var/m_dmg=percent_damage*loop_delay*1*(BP/M.BP)**0.5*(Force/M.Res)**0.5
							M.Health-=m_dmg
						if(P==A&&!P.Safezone)
							if(getdist(Owner,P)<beam_stun_start&&P.last_beam_kb_pos!=P.loc&&apply_short_range_beam_knock)
								P.last_beam_kb_pos=P.loc
								var/kb_dist=3*(BP/P.BP)*(Force/P.Res)
								kb_dist=To_multiple_of_one(kb_dist)
								kb_dist=Clamp(kb_dist,0,15)
								var/kb_dir=pick(turn(dir,45),turn(dir,-45),dir)
								Make_Shockwave(P,256)
								P.Knockback(Owner,Distance=kb_dist,override_dir=kb_dir)
								if(P) //bad mob error
									var/area/a=P.current_area
									if(a) for(var/mob/listener_mob in a.player_list) if(getdist(listener_mob,P)<=10)
										listener_mob<<sound('scouterexplode.ogg',volume=30)
							else
								if(getdist(Owner,P)<10)
									P.has_delay=0
									step(P,dir)
									P.has_delay=1
									P.dir=turn(dir,180)
									if(getdist(Owner,P)==10)
										if(!(locate(/obj/BigCrater) in P.loc))
											Big_crater(P.loc)
						if(P) //missing mob error
							if(P.Health<=0)
								if(Noob_Attack) P.KO()
								else P.KO(Owner)
							if(Paralysis)
								P<<"You become paralyzed"
								P.Frozen=1
							if((P.KO&&Owner.Fatal)||!P.client)
								if(P.Health<=0)
									if(P.Regenerate&&Damage/loop_delay/Beam_Delay>P.BP*P.Res*8* P.Regenerate**0.3 * ki_power)
										if(Noob_Attack) P.Death(null,1)
										else P.Death(Owner,1)
									else
										if(Noob_Attack) P.Death()
										else P.Death(Owner)
						if(!Piercer)
							icon_state="struggle"
							delete_on_next_move=1
					break
				for(var/obj/Blast/A in range(0,src)) if(A!=src)
					if(A.dir!=dir)
						if(!A.Beam)
							icon_state="struggle"
							layer=MOB_LAYER+3
							if(!Owner||getdist(src,Owner)>1)
								if(!(locate(/obj/Blast) in Get_step(src,turn(dir,180)))) del(src)
							for(var/obj/Blast/C in Get_step(src,dir)) if(C.dir==dir)
								icon_state="tail"
								layer=MOB_LAYER+2
								break
							for(var/obj/Blast/C in Get_step(src,turn(dir,180))) if(C.dir==dir&&C.icon_state=="struggle")
								C.icon_state="tail"
								C.layer=MOB_LAYER+2

							if(3*BP*Force*percent_damage**0.3/Beam_Delay>A.BP*A.Force*A.percent_damage**0.3)
								var/list/dirs=list(NORTH,SOUTH,EAST,WEST,NORTHEAST,SOUTHEAST,SOUTHWEST,NORTHWEST)
								dirs-=A.dir
								A.deflected=1
								Make_Shockwave(Origin=A,sw_icon_size=128)
								walk(A,pick(dirs))
							else
								for(var/obj/Blast/b in Get_step(src,turn(dir,180))) if(b.dir==dir)
									b.icon_state="struggle"
								del(src)
							break
						else
							if(Owner&&ismob(Owner)&&Owner.beaming)
								Owner.beam_struggling=1
							icon_state="struggle"
							A.icon_state="struggle"
							layer=MOB_LAYER+3
							A.layer=MOB_LAYER+3
							if(!Owner||getdist(src,Owner)>1)
								if(!(locate(/obj/Blast) in Get_step(src,turn(dir,180)))) del(src)
							for(var/obj/Blast/C in Get_step(src,dir)) if(C.dir==dir)
								icon_state="tail"
								//layer=MOB_LAYER+2
								layer=initial(layer)-0.2
								break
							for(var/obj/Blast/C in Get_step(src,turn(dir,180))) if(C.dir==dir&&C.icon_state=="struggle")
								C.icon_state="tail"
								//C.layer=MOB_LAYER+2
								C.layer=initial(C.layer)-0.2
							var/Sure_Win
							if(Damage/Beam_Delay>1.5*A.Damage/A.Beam_Delay) Sure_Win=1
							if(Sure_Win)
								for(var/obj/Blast/B in Get_step(A,turn(A.dir,180))) if(B.dir==A.dir)
									B.icon_state="struggle"
									break
								del(A)
							else
								icon_state="struggle"
								delete_on_next_move=1
								if(Owner&&A.Owner&&getdist(src,Owner)<getdist(A,A.Owner))
									delete_on_next_move=0
									for(var/obj/Blast/B in Get_step(A,turn(A.dir,180))) if(B.dir==A.dir)
										B.icon_state="struggle"
										break
									del(A)
							break
					else if(A.dir==dir&&A.icon_state=="struggle") if(A.Damage<Damage) del(A)

				for(var/turf/A in range(0,src)) if(A.density)
					if((A.Health<=wall_breaking_power||Owner.Epic())&&(!ismob(Owner)||(ismob(Owner)&&Owner.Is_wall_breaker())))
						var/turf/B=A
						B.Health=0
						B.Destroy()
					if(A) if(!Piercer&&A.density)
						icon_state="struggle"
						delete_on_next_move=1

				for(var/obj/A in range(0,src)) if(!istype(A,/obj/Blast)&&!istype(A,/obj/Edges))
					if(!A.takes_gradual_damage)
						if(A.Health<=wall_breaking_power)
							Big_crater(locate(A.x,A.y,A.z))
							del(A)
					else
						A.Health-=BP/5
						if(A.Health<=0)
							Big_crater(A.loc)
							del(A)
					if(A) if(!Piercer&&A.density)
						icon_state="struggle"
						delete_on_next_move=1
					break
			sleep(To_tick_lag_multiple(loop_delay))
	proc/Explode() if(Explosive)
		Damage=BP*Force*percent_damage
		for(var/atom/movable/am in view(Explosive,src))
			if(ismob(am)&&am!=Owner)
				var/mob/m=am
				if(m.attack_barrier_obj&&m.attack_barrier_obj.Firing_Attack_Barrier)
					//attack barrier deflects all explosion heat and shrapnel
				else if(m.Shielding()) Shield(m)
				else
					var/kb_dist=Explosive+Shockwave
					kb_dist=m.relative_kb_dist(src,kb_dist)
					m.Shockwave_Knockback(kb_dist,loc)
					var/dmg=percent_damage*(BP/m.BP)**0.5 * 0.5
					var/force_vs_res
					if(!Bullet) force_vs_res=Force/m.Res
					else force_vs_res=Force/m.End
					if(force_vs_res>1) force_vs_res=force_vs_res**0.5
					dmg*=force_vs_res
					if(m.fearful||m.Good_attacking_good()) dmg*=m.Fear_dmg_mult()
					if(Owner&&ismob(Owner)&&Owner.is_kiting) dmg*=kiting_penalty
					if(m.is_teamer) dmg*=teamer_dmg_mult
					if(Owner&&ismob(Owner)&&Owner.is_teamer) dmg/=teamer_dmg_mult

					if(ismob(Owner))
						var/resist_dmg_mod=(Owner.Res/Owner.Pow)**0.35
						if(resist_dmg_mod>1) resist_dmg_mod=1
						if(resist_dmg_mod<0.5) resist_dmg_mod=0.5
						dmg*=resist_dmg_mod

					m.Health-=dmg
					if(m.Health<=0)
						if(Noob_Attack) m.KO()
						else m.KO(Owner)
					if(Paralysis)
						m<<"You become paralyzed"
						m.Frozen=1
			else if(isobj(am))
				if(am!=src&&!istype(am,/obj/Blast)) if(am.Health<=wall_breaking_power)
					Big_crater(locate(am.x,am.y,am.z))
					del(am)
		Explosion_Graphics(Get_step(src,dir),Explosive)
		for(var/turf/A in Turf_Circle(Explosive,src)) if((A.Health<=wall_breaking_power||(ismob(Owner)&&Owner.Epic()))&&(!ismob(Owner)||(ismob(Owner)&&Owner.Is_wall_breaker())))
			A.Health=0
			if(A.density) A.Destroy()
			else A.Make_Damaged_Ground(1)
	Bump(mob/A,override_dir,override_delete)
		..()
		Damage=BP*Force*percent_damage
		var/Original_Damage=Damage
		if(!Owner&&!override_delete) del(src)

		/*if(ismob(Owner)&&Owner.Is_Tens())
			var/death_damage=Original_Damage
			var/death_resist=Owner.BP*Owner.Res*Owner.Regenerate**0.5*100*ki_power
			Owner<<"death damage: [Commas(death_damage)]<br>\
			death resist: [Commas(death_resist)]"*/

		if(ismob(A))
			if(Owner&&ismob(Owner))
				Owner.Set_flash_step_mob(A)
				if(A==Owner.chaser)
					Owner.last_damaged_chaser=0
					Owner.Remove_fear()
			spawn if(A&&A.drone_module&&Owner) A.Drone_Attack(Owner,lethal=1)
			A.last_attacked_time=world.time
			if(A.Shielding())
				Shield(A)
				loc=A.loc
				player_view(10,src)<<sound('reflect.ogg',volume=20)
				Size=0
				deflected=1
				walk(src,pick(NORTH,SOUTH,EAST,WEST,NORTHWEST,NORTHEAST,SOUTHWEST,SOUTHEAST))
				return
			else if(!Bullet&&A.Absorb_Blast(src))
				if(!override_delete) del(src)
				return
			var/dmg=percent_damage*(BP/A.BP)**0.5

			var/force_vs_resist
			if(Bullet) force_vs_resist=Force/A.End
			else force_vs_resist=Force/A.Res
			if(force_vs_resist>1) force_vs_resist=force_vs_resist**superior_force_exponent
			else force_vs_resist=force_vs_resist**inferior_force_exponent
			dmg*=force_vs_resist

			dmg*=Defense_damage_reduction(Owner,A)
			if(A.fearful||A.Good_attacking_good()) dmg*=A.Fear_dmg_mult()
			if(Owner&&ismob(Owner)&&Owner.is_kiting) dmg*=kiting_penalty
			if(A.is_teamer) dmg*=teamer_dmg_mult
			if(Owner&&ismob(Owner)&&Owner.is_teamer) dmg/=teamer_dmg_mult

			/*if(ismob(Owner))
				var/resist_dmg_mod=(Owner.Res/Owner.Pow)**0.35
				if(resist_dmg_mod>1) resist_dmg_mod=1
				if(resist_dmg_mod<0.5) resist_dmg_mod=0.5
				dmg*=resist_dmg_mod*/

			if(ismob(Owner)&&Owner.alignment=="Evil") dmg*=villain_damage_penalty

			dmg*=sagas_bonus(Owner,A)
			if(ismob(Owner)) Owner.training_period(A)

			if(Bullet&&!A.client&&!istype(A,/mob/Enemy/Core_Demon)) dmg*=2 //Guns do much more dmg against NPCs.

			var/Hit_Chance=base_blast_accuracy*percent_damage**0.3*sqrt(BP/A.BP)
			var/off_vs_def=Acc_mult(Offense/A.Def)

			Hit_Chance*=off_vs_def

			if(A.standing_powerup) Hit_Chance/=standing_powerup_deflect_mult
			if(A.fearful||A.Good_attacking_good()) Hit_Chance*=A.Fear_dmg_mult()
			if(A.is_teamer) Hit_Chance*=teamer_dmg_mult
			if(Owner&&ismob(Owner)&&Owner.is_teamer) Hit_Chance/=teamer_dmg_mult

			if(Owner&&ismob(Owner))
				Hit_Chance*=Owner.Speed_accuracy_mult(defender=A)

			//player_view(15,src)<<"Hit Chance: [Hit_Chance]%"
			if(dir==A.dir && !A.knockback_immune && !A.KB && !A.standing_powerup)
				Hit_Chance*=2
				dmg*=1.5
			if(A.grabber) Hit_Chance=100

			if(prob(Hit_Chance)||!Deflectable||A.KO||A.Disabled())
				if(A.precog&&A.precogs&&prob(A.precog_chance)&&!A.KO&&(A.Flying||A.icon_state=="")&&A.Ki>A.max_ki*0.2&&!A.Disabled())
					A.precogs--
					//A.Ki-=A.Ki/60/A.Eff**0.4
					var/turf/old_loc=A.loc
					step(A,turn(dir,pick(-45,45)))
					if(A.loc!=old_loc) return
				if(dir==A.dir) Offense*=3
				if(A.Vampire) dmg*=vampire_damage_multiplier
				A.Health-=dmg
				Make_Shockwave(A,sw_icon_size=Get_projectile_shockwave_size(src))
				if(ismob(Owner)&&!A.KO) A.set_opponent(Owner)
				if(A.Health<=0)
					if(Noob_Attack) A.KO()
					else A.KO(Owner)
					if(Fatal||!A.client)
						A.Health-=dmg
						if(A.Health<=0)
							if(A.Regenerate&&!Bullet&&Original_Damage>A.BP*A.Res*A.Regenerate**0.5*100*ki_power)
								if(Noob_Attack) A.Death(null,1)
								else A.Death(Owner,1)
							else
								if(Noob_Attack) A.Death()
								else A.Death(Owner)
				if(Paralysis)
					A<<"You become paralyzed"
					A.Frozen=1
				if(A&&src&&slice_attack) A.check_lose_tail(dmg,src)
				if(Shockwave&&A&&!Explosive) //doesnt do kbs here if blast is explosive because its handled in
					//Explode()
					var/kb_dist=Shockwave
					if(Owner&&ismob(Owner))
						if(getdist(src,Owner)<=1) kb_dist*=2.5
						else if(getdist(src,Owner)==2) kb_dist*=1.5
					kb_dist=A.relative_kb_dist(src,kb_dist)
					var/turf/t=loc
					if(override_dir) t=Get_step(A,turn(override_dir,180))
					A.Shockwave_Knockback(kb_dist,t)
				if(Stun&&A)
					var/stun=Stun * (BP/A.BP)**0.4 * (Force/A.Res)**0.4
					A.Apply_stun(stun*2)
				Explode()
			else
				loc=A.loc
				Size=0
				deflected=1
				dir=pick(turn(dir,180),turn(dir,45+180),turn(dir,-45+180),turn(dir,90+180),turn(dir,-90+180))
				BP*=1.05 //just so that it can cut thru the blast stream it came from if it is deflected
				//back towards the firer
				var/reflect_chance=35*(A.Def/Offense)
				if(prob(reflect_chance)) dir=turn(dir,180)
				if(A.client) flick("Attack",A)
				player_view(10,src)<<sound('reflect.ogg',volume=20)
				walk(src,dir)
				return
			if(!Piercer&&!Bounce&&!override_delete) del(src)
			else
				Original_Damage/=2 //Damage is decreased each time it slices thru something
				Damage=Original_Damage
				loc=Get_step(src,dir)
				Bounce_Dir()
		if(isobj(A))
			if(!A) return
			if(istype(A,/obj/Blast)&&density)
				if(A.dir==dir)
					loc=A.loc
					for(var/mob/m in loc)
						Bump(m)
						break
				else
					Explode()
					if(!Beam) Make_Shockwave(A,sw_icon_size=Get_projectile_shockwave_size(src))
					var/obj/Blast/b=A
					var/this_cutting_power=BP**0.2 * Force**0.2 * percent_damage
					var/their_cutting_power=b.BP**0.2 * b.Force**0.2 * b.percent_damage
					if(Bullet) this_cutting_power/=3
					if(b.Bullet) their_cutting_power/=3
					if(prob(this_cutting_power/their_cutting_power*50)) del(A)
					else del(src)
			else
				Explode()
				if(!Beam)
					if(A!=last_object_shockwaved_against) Make_Shockwave(A,sw_icon_size=Get_projectile_shockwave_size(src))
					last_object_shockwaved_against=A
				if(A)
					if(A.takes_gradual_damage) A.Health-=BP/5
					else if(A.Health<=wall_breaking_power) A.Health=0
					if(A.Health<=0)
						Big_crater(A.loc)
						del(A)
					else if(!Piercer&&!Bounce&&!override_delete) del(src)
			Bounce_Dir()
		if(isturf(A))
			Explode()
			if(A!=last_object_shockwaved_against) Make_Shockwave(A,sw_icon_size=Get_projectile_shockwave_size(src))
			last_object_shockwaved_against=A
			if((A.Health<=wall_breaking_power||(Owner&&ismob(Owner)&&Owner.Epic()))&&(!Owner||!ismob(Owner)||(ismob(Owner)&&Owner.Is_wall_breaker())))
				var/turf/t=A
				t.Health=0
				t.Destroy()
			if(!Piercer&&!Bounce&&!override_delete) del(src)
			Bounce_Dir()
	proc/Bounce_Dir() if(Bounce) walk(src,pick(turn(dir,135),turn(dir,-135),turn(dir,180)))
obj/proc/Edge_Check()
	return //pretty sure this proc is completely pointless
	spawn while(src)
		if(!(locate(Owner) in range(12,src))) if(x==1||x==world.maxx||y==1||y==world.maxy) del(src)
		sleep(50)
obj/var/Knockable=1
obj/proc/Shockwave_Knockback(Amount,turf/A) spawn if(src&&Knockable) while(Amount)
	Amount-=1
	var/old_loc=loc
	for(var/obj/Turfs/Door/d in Get_step(src,get_dir(A,src))) return
	step(src,get_dir(A,src))
	if(old_loc==loc) Amount=0
	sleep(world.tick_lag)
mob/proc/Shockwave_Knockback(Amount,turf/A) spawn if(src)
	if(!z) return //prevent body swap bug knocking them out of body
	if(transing) Amount/=2
	Amount=To_multiple_of_one(Amount)
	if(Safezone||KB||knockback_immune) return
	var/Dusts=0
	if(Amount>=7) Dusts=10
	//if(Amount>=15) view(10,src)<<'swoophit.ogg'
	var/Old_State
	if(icon_state!="KB") Old_State=icon_state
	if(client) icon_state="KB"
	var/start_loc=loc

	var/mob/m=grabbed_mob
	Release_grab()
	if(m&&ismob(m)) m.Shockwave_Knockback(Amount,A)

	if(Diarea) spawn Diarea(Other_Chance=100)

	var/d=get_dir(A,src)
	if(prob(20)) d=pick(turn(get_dir(A,src),45),turn(get_dir(A,src),-45))

	while(Amount)
		Amount-=1
		KB=1

		var/old_loc=loc
		step(src,d)
		if(loc==old_loc) Amount=0
		//step_away(src,A,100)

		for(var/obj/Edges/E in range(0,src))
			Amount=0
			break
		dir=get_dir(src,A)
		sleep(world.tick_lag)
	KB=0
	last_knockbacked=world.time
	knockback_immune=1
	spawn(kb_immunity_time) if(src) knockback_immune=0
	if(Dusts)
		player_view(10,src)<<sound('wallhit.ogg',volume=25)
		if(loc!=start_loc) Dust(src,Dusts)
	if((Old_State||Old_State=="")&&icon_state!="KO") icon_state=Old_State

var/list/explosion_cache=new

proc/Get_explosion()
	var/obj/Explosion/e
	for(var/obj/o in explosion_cache) e=o
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
	proc/Explosion() spawn
		Center_Icon(src)
		for(var/v in 1 to 4)
			icon_state="[v]"
			sleep(1)
		del(src)
	Del()
		loc=null
		explosion_cache+=src
var/list/explosion_icons
proc/Initialize_explosion_icons()
	if(explosion_icons) return
	explosion_icons=new/list
	for(var/v in 1 to 5)
		var/icon/i='Explosion1 2013.dmi'
		i=Scaled_Icon(i,Get_Width(i)*1.5**v/1.5,Get_Height(i)*1.5**v/1.5)
		explosion_icons+=i
proc/Explosion_Graphics(obj/O,Distance=1,not_used=0)
	//not_used is a 3rd arg from the old explosion graphics, remove it whenever
	Initialize_explosion_icons()
	if(!O) return
	var/obj/Explosion/e=Get_explosion()
	e.loc=O.True_Loc()
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
turf/proc/Remove_Damaged_Ground(image/I) spawn(rand(600,3000)) if(src) overlays-=I
mob/proc/Shielding()
	if(Cyber_Force_Field&&Ki>=max_ki*0.1) return 1
	if(shield_obj&&shield_obj.Using) return 1
	if(!Tournament||!skill_tournament||(Tournament&&skill_tournament&&Fighter1!=src&&Fighter2!=src))
		for(var/obj/items/Force_Field/S in item_list) if(S.Level>0) return 1
mob/proc/ki_shield_on() if(shield_obj&&shield_obj.Using) return 1
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
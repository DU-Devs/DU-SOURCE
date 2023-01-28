/*
the damage var/of projectiles needs removed
the BP and Force vars need replaced with:
blast_bp: the bp of the player unaltered
blast_force: the force of the player unaltered
damage_percent: the percent multiplier of the damage inherited from the move that was used
*/

obj/Blast/proc/setStats(mob/P, Percent=1, Off_Mult=1, Explosion=0, bullet=0, homing_mod = 1)
	Health=0.2*P.BP*(Percent**0.4)
	takes_gradual_damage=1
	Fatal=P.Fatal
	Owner=P
	BP=P.BP

	if(ismob(P)) wall_breaking_power = P.WallBreakPower()
	else wall_breaking_power = BP

	percent_damage=Percent
	if(!bullet)
		Force=P.Pow
		percent_damage*=ki_power
	else
		Force=P.Str
		percent_damage*=melee_power
	Offense=P.Off*Off_Mult
	off_mult = Off_Mult
	Explosive=Explosion
	if(ismob(P))
		user_speed = P.Spd
		homing_chance = P.Get_blast_homing_chance(homing_mod)
		//laggy
		if(!Beam && !istype(src,/obj/Blast/Genki_Dama))
			var/new_size=(P.BPpcnt/100)**0.5
			if(new_size<0.5) new_size=0.5
			Update_transform_size(new_size)
	//world<<"BP: [BP]<br>Force: [Force]<br>Offense: [Offense]"

mob/var/blast_homing_mod=1

obj/var/Stun

var/list/cached_blasts=new

proc/fill_cached_blasts()
	for(var/v in 1 to 50) cached_blasts += new/obj/Blast

proc/get_cached_blast()
	for(var/obj/Blast/b in cached_blasts) if(!b.in_use)
		animate(b) //stop all animations
		ResetVars(b)
		b.in_use=1
		cached_blasts -= b

		//reset everything back to defaults
		b.skip_all_collisions = 0
		b.pixel_x=0
		b.pixel_y=0
		b.overlays = new/list
		b.New()

		b.Owner=null
		walk(b,0)
		b.gain_power_with_range=0
		b.lose_power_with_range=0
		//b.weaker_obstacles_cant_destroy_blast = 0
		b.blast_go_over_obstacles_if_cant_destroy = 0
		b.blast_go_over_owner = 0
		b.stun_lowers_dmg = 1

		b.transform = matrix()
		b.alpha = 255
		b.step_size = initial(b.step_size)
		b.bound_x = 0
		b.bound_y = 0
		b.bound_height = world.icon_size
		b.bound_width = world.icon_size
		b.step_x = 0
		b.step_y = 0

		b.shield_pierce_mult = 1
		b.bleed_damage = 0
		b.shuriken = 0
		b.deflected=0
		b.is_makosen=0
		b.wall_breaking_power=0
		b.vampire_damage_multiplier=1
		b.delete_on_next_move=0
		b.Stun=0
		b.Explosive=0
		b.Shockwave=0
		b.blast_homing_target = null
		b.Piercer=0
		b.Paralysis=0
		b.Beam=0
		b.slice_attack=0
		b.Shrapnel=0
		b.Bounce=0
		b.blast_front_deflection_mod=1
		b.Deflectable=1
		b.apply_short_range_beam_knock=1
		b.Size=0
		b.Spread=0
		b.off_mult = 1
		b.density=1
		b.Distance=initial(b.Distance)
		b.glide_size=initial(b.glide_size)
		b.deflect_difficulty=initial(b.deflect_difficulty)
		b.Can_Home=initial(b.Can_Home)
		b.Update_transform_size(1)
		b.beam_loop_running=0
		//--------
		b.scattershot_attacking_target = 0
		b.pass_over_owners_blasts = initial(b.pass_over_owners_blasts)
		b.scattershot_target = null

		return b
	//no blasts found, create more
	fill_cached_blasts()
	return get_cached_blast()

obj/Blast/proc/cache_blast()
	walk(src,0)
	loc = null
	in_use=0
	cached_blasts-=src
	cached_blasts+=src //add to end of list
//blast deleted at 0, 0, 0. in use = 0. from attack = Blast. owner = Tens

var/list/all_blast_objs=new

area/var/tmp/list/blast_objs=new

obj/Blast/Del()
	set waitfor=0
	walk(src,0) //stop all walking
	var/area/a = get_area()
	if(a) a.blast_objs -= src

	var/mob/m = Owner
	if(m && ismob(m)) m.my_beam_objs -= src
	if(Shrapnel) Shrapnel()

	if(blast_caches)
		cache_blast()
		loc = null
	else
		walk(src,0)
		SafeTeleport(null) //attempt to fix spirit bombs hitting multiple times bug. 12/16/2018
		. = ..()
	/*if(in_use) cache_blast()
	else
		//Tens("blast deleted at [x], [y], [z]. in use = [in_use]. from attack = [from_attack]. owner = [Owner]")
		all_blast_objs-=src
		. = ..()*/

var/blast_tracking_angle_limit = 30 //for the targeting system

obj/Blast
	//blend_mode=BLEND_ADD
	var/tmp/beam_loop_running
	var/tmp/obj/from_attack //temporary debugging var

	var
		Is_Ki=1
		in_use
		user_speed
		homing_chance=30
		bleed_damage = 0 //damage is applied as bleed damage
		shuriken = 0 //special handling for shurikens
		shield_pierce_mult = 1
		weaker_obstacles_cant_destroy_blast = 1
		blast_go_over_obstacles_if_cant_destroy = 0
		blast_go_over_owner = 0
		stun_lowers_dmg = 1
		tmp
			projectile_creation_time = 0 //world.time
			beam_steps = 0 //0 = first step, increases by +1 each time

	var/percent_damage=1
	var/Force=1
	var/off_mult = 1
	var
		is_makosen
	var/Offense=1
	var/vampire_damage_multiplier = 1
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
	var
		blast_front_deflection_mod = 1
		pass_over_owners_blasts = 1
		skip_all_collisions
	layer=6
	Savable=0
	density=1
	Grabbable=0
	var/Distance=100
	var/deflected //sets to 1 if deflected so that controlled moves arent controllable any more
	var/tmp/turf/last_object_shockwaved_against //to prevent shockwave spamming the same turf repeatedly, causing lag

	New()
		projectile_creation_time = world.time
		spawn if(src)
			var/area/a=get_area()
			if(a) a.blast_objs+=src

		all_blast_objs+=src
		spawn if(src) if(GetWidth(icon)>36||GetHeight(icon)>36) CenterIcon(src)
		if(type!=/obj/Blast/Genki_Dama)
			spawn(1) if(Owner&&ismob(Owner)&&Owner.icon_state!="Attack") if(Owner.client) flick("Attack",Owner)
		spawn(30) if(src && z && !Get_step(src,dir))
			del(src)

	proc/Update_transform_size(new_size=1)
		transform = matrix() * new_size
		return

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
			var/obj/Blast/A = get_cached_blast()
			A.SafeTeleport(T)
			A.bleed_damage = bleed_damage
			A.user_speed = user_speed
			A.homing_chance = homing_chance
			A.shuriken = shuriken
			A.shield_pierce_mult = shield_pierce_mult
			A.Explosive = Explosive
			A.Health = Health
			A.takes_gradual_damage = takes_gradual_damage
			A.Distance=50
			A.icon=icon
			A.Owner = Owner
			A.Is_Ki = Is_Ki
			A.BP=BP/4
			A.Force=Force
			A.percent_damage=percent_damage
			A.Offense=Offense
			A.Fatal=Fatal
			A.Bounce=Bounce
			walk(A,pick(NORTH,SOUTH,EAST,WEST,NORTHWEST,NORTHEAST,SOUTHWEST,SOUTHEAST))

	var/delete_on_next_move=0

	Move()
		if(Size)
			for(var/atom/A in orange(Size,src)) if(A!=src&&A.density&&!isarea(A)) Bump(A)
		if(Spread)
			for(var/atom/A in Get_step(src,turn(dir,90))) if(A!=src&&A.density&&!isarea(A)) Bump(A)
			for(var/atom/A in Get_step(src,turn(dir,-90))) if(A!=src&&A.density&&!isarea(A)) Bump(A)
		if(dir == NORTH || dir == SOUTH || dir == WEST || dir == EAST)
			var/turf/t = loc
			if(isturf(t) && t.Water) t.ki_water(dir)
		if(!Can_Home || !Blast_Homing()) . = ..()
		steps_since_last_homing_check++

		Distance--
		if(!z || delete_on_next_move || Distance <= 0 || !get_step(src,dir))
			if(z) Explode()
			del(src)

	var/Can_Home=1 //i think this is to the old homing system and does nothing now
	var/tmp/mob/blast_homing_target

	proc/CheckBlastHomingTarget()
		if(blast_homing_target && Is_viable_homing_target(blast_homing_target)) return
		blast_homing_target = GetBlastHomingTarget()

	//remember: movable.At_forward_half(mob/m) exists
	proc/Is_viable_homing_target(mob/m)
		if(!m || m.KO || !At_forward_half(m)) return //fix bug where blasts track backwards toward the target

		var/mob/bht = blast_homing_target
		if(bht && bht.z==z && (Owner != bht || deflected) && getdist(src,bht)<100 && get_dir(src,bht) == dir)
			if(m == bht && get_abs_angle(src, bht) <= blast_tracking_angle_limit) return 1
			else return
		if(m && m.z==z && (Owner!=m || deflected) && getdist(src,m)<100) // && (get_dir(src,m) in list(dir,turn(dir,45),turn(dir,-45))))
			if(get_abs_angle(src, m) <= blast_tracking_angle_limit)
				return 1

	var/tmp/steps_since_last_homing_check=0

	proc/Blast_Homing()

		//return //this seems to be the old blast homing code idk why it was on
		//its on so that things such as Big Bang and Charge can home in some, instead of being useless because they only go in straight lines

		if(prob(homing_chance * 0.73))

			CheckBlastHomingTarget()

			if(blast_homing_target && !Beam && Can_Home && z)
				//if(get_dir(src,blast_homing_target) == dir) return
				var/old_dir=dir
				Can_Home=0
				step(src,get_dir(src, blast_homing_target))
				Can_Home=1
				dir=old_dir
				return 1

	proc/Beam_Appearance()
		if(Beam && z)
			if(beam_steps == 0)
			else
				icon_state = "tail"
				if(beam_steps == 1) layer = initial(layer)
				if(!(icon_state in list("struggle","bend right","bend left")))
					if(!(locate(/obj/Blast) in Get_step(src,dir)))
						icon_state="head"
						layer = initial(layer) + 0.1
					else if(beam_steps >= 2 && !(locate(/obj/Blast) in Get_step(src,turn(dir,180))))
						icon_state="end"
						Update_diagonal_overlays()
				if(beam_steps >= 3 && icon_state in list("head","struggle"))
					var/obj/Blast/o = locate(/obj/Blast) in Get_step(src, turn(dir, 180))
					if(!o || o.Owner != Owner || !o.Beam)
						del(src)

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
			if(Owner && ismob(Owner)) Dmg *= Owner.AllAttacksDamageModifiers(A)
			if(A.fearful||A.Good_attacking_good()) Dmg*=A.Fear_dmg_mult()
			if(Owner&&ismob(Owner)&&Owner.is_kiting) Dmg*=kiting_penalty
			if(A.is_teamer) Dmg*=teamer_dmg_mult
			if(Owner&&ismob(Owner)&&Owner.is_teamer) Dmg/=teamer_dmg_mult
			Dmg *= shield_pierce_mult
			A.Apply_force_field_damage(S,Dmg)
			return

		if(A.Cyber_Force_Field)
			var/Dmg=(BP*Force*percent_damage)/(A.BP*A.Res)
			if(Owner && ismob(Owner)) Dmg *= Owner.AllAttacksDamageModifiers(A)
			Dmg *= shield_pierce_mult
			A.Ki-=(Dmg/100)*A.max_ki
			if(A.Ki<=0) for(var/obj/Module/Force_Field/F in A.active_modules)
				F.Disable_Module(A)
				A<<"Your cybernetic force field has been damaged. You must re-install it to make it active again."
			for(var/obj/Blast/B in Get_step(src,turn(dir,180))) if(B.Beam) B.icon_state="struggle"
			A.Force_Field('Electro Shield.dmi')
			return

		//natural energy shield
		if(A.shield_obj && A.shield_obj.Using)
			var/Dmg = A.ShieldDamageReduction() * (A.max_ki/100/(A.Eff**shield_exponent)) * (BP/A.BP)**bp_exponent * (Force/A.Res)**0.5 * percent_damage * A.Generator_reduction(is_melee = Bullet)
			if(Owner && ismob(Owner)) Dmg *= Owner.AllAttacksDamageModifiers(A)
			if(A.fearful||A.Good_attacking_good()) Dmg*=A.Fear_dmg_mult()
			if(Owner&&ismob(Owner)&&Owner.is_kiting) Dmg*=kiting_penalty
			if(A.is_teamer) Dmg*=teamer_dmg_mult
			if(Owner&&ismob(Owner)&&Owner.is_teamer) Dmg /= teamer_dmg_mult
			Dmg *= shield_pierce_mult

			//apparently beams do too much dmg and other ki attacks do almost none so we fix that here
			if(Beam) Dmg *= 0.5
			else Dmg *= 2.5

			A.Ki -= Dmg
			if(A.Ki <= 0) A.Shield_Revert()
			for(var/obj/Blast/B in Get_step(src,turn(dir,180))) if(B.Beam) B.icon_state = "struggle"
			return

	proc/GetSuckedIntoBeam(mob/m)
		if(getdist(src,m)>0 && get_dir(src,m) != dir && !m.BeamStunImmune())
			var/turf/t = loc
			if(t && isturf(t) && !t.density) m.loc=loc

	proc/Beam()
		set waitfor=0
		if(beam_loop_running) return
		var/loop_delay = world.tick_lag
		beam_loop_running=1
		while(src)
			if(delete_on_next_move == 1)
				return
			if(!z)
				return //for blast caching, cancel loop
			Damage = BP*Force*percent_damage*loop_delay
			if(!Owner)
				del(src)
				return

			//GROW/SHRINK WITH RANGE
			/*if(ismob(Owner) && !lose_power_with_range)
				var/range_from_owner = getdist(src,Owner)
				if(range_from_owner>=1)
					transform = matrix() * (1.015 ** range_from_owner)*/
			//-----------------

			/*if(ismob(Owner)&&Owner.IsTens())
				var/death_damage=Damage/loop_delay/Beam_Delay
				var/death_resist=Owner.BP*Owner.Res*10*Owner.Regenerate**0.5*ki_power
				Owner<<"death damage: [Commas(death_damage)]<br>\
				death resist: [Commas(death_resist)]"*/

			var/obj/beam_redirector/br=locate(/obj/beam_redirector) in loc
			if(br)
				deflected=1
				blast_go_over_owner = 0

			if(!br && Deflectable && (icon_state in list("head","struggle")))
				for(var/mob/m in Get_step(src,dir)) if(!m.KO && !m.grabber && !m.regenerator_obj)
					Debug(Tens,"mob contacted by beam")
					m.beam_deflect_difficulty = deflect_difficulty
					m.dir=get_dir(m,src)
					var/deflect_chance = 1 * global_beam_deflect_mod * Beam_Delay * loop_delay * (5 / deflect_difficulty) * (m.BP/Owner.BP) * (1/(Acc_mult(Clamp(Owner.Off/m.Def,0.1,10))))
					deflect_chance = 100 //so long as it takes stamina to deflect beams it can be 100% by default
					if(m.beaming || m.KO) deflect_chance=0
					if(m.BeamStruggling()) deflect_chance /= 10000 //only choice is to struggle out of the beam
					if(m.standing_powerup) deflect_chance *= standing_powerup_deflect_mult
					if(m.fearful||m.Good_attacking_good()) deflect_chance/=m.Fear_dmg_mult()
					if(m.is_teamer) deflect_chance /= teamer_dmg_mult
					if(Owner&&ismob(Owner) && Owner.is_teamer) deflect_chance*=teamer_dmg_mult

					if(Owner&&ismob(Owner))
						deflect_chance*=Owner.Speed_accuracy_mult(defender=m)

					if(istype(m, /mob/Body) || m.KO) deflect_chance=0

					deflect_chance = 0 //I JUST PLAIN TURNED IT OFF FOR NOW ITS ANNOYING HAVING TO RE-FIRE YOUR BEAM EVERY TIME THEY DEFLECT IT

					var/stamDrain = 50 * (Owner.BP / m.BP)**0.33
					stamDrain *= (Owner.Pow / ((m.Res * 0.33) + (m.Str * 0.33) + (m.Pow * 0.33)))**0.33
					stamDrain *= global_beam_deflect_mod * deflect_difficulty
					if(prob(deflect_chance) && m.CanBlastDeflect() && m.stamina >= stamDrain)

						m.AddStamina(-stamDrain)

						flick("Attack",m)
						var/obj/beam_redirector/br2 = new(loc)
						br2.dir=pick(turn(dir,90),turn(dir,-90))
						br=br2
						break
			if(!br)

				//seems like we could use the beam_size var/for this
				var/beam_radius=0
				if(ismob(Owner)) beam_radius += (Owner.BPpcnt - 100) / 130
				beam_radius=Clamp(beam_radius,0,1)
				beam_radius=ToOne(beam_radius)
				if(is_makosen || deflected) beam_radius=0

				beam_radius = 0 //off

				for(var/mob/A in range(beam_radius,src)) if((A.loc==loc || A!=Owner) && (A.loc==loc || get_dir(src,A) != dir))
					if(A.ultra_instinct)
						var/d = turn(dir,pick(135,-135))
						step(A,d,32)
						A.Flip()
					else
						A.beam_deflect_difficulty = deflect_difficulty
						if(A.loc==loc && Owner&&ismob(Owner))
							Owner.Set_flash_step_mob(A)
							if(A==Owner.chaser)
								Owner.last_damaged_chaser=0
								Owner.Remove_fear()
						spawn if(A && A.loc == loc && A.drone_module&&Owner) A.Drone_Attack(Owner,lethal=1)

						A.SetLastAttackedTime(Owner)

						A.last_beamed_by = Owner
						if(!A.regenerator_obj && A.Shielding())
							if(!is_makosen) A.last_hit_by_beam = world.time

							GetSuckedIntoBeam(A)

							Shield(A)
							del(src)
							return
						else if(!A.regenerator_obj && A.Absorb_Blast(src))
							del(src)
							return
						if(A && !A.regenerator_obj && A.precog && A.precogs && prob(A.precog_chance) && !A.KO && (A.Flying || A.icon_state == "") && A.Ki > A.max_ki * 0.2 && !A.Disabled())
							A.precogs--
							//A.Ki-=A.Ki/30/A.Eff**0.4
							var/turf/old_loc=A.loc
							step(A,turn(dir,pick(-45,45)),32)
							if(A.loc!=old_loc) return
						else
							GetSuckedIntoBeam(A)

							var/mob/P=A
							if(prob(80)) for(var/mob/MM in range(0,A)) if(MM.Is_Grabbed()) P=MM

							var/force_vs_resist=(Force/P.Res)
							if(force_vs_resist>1) force_vs_resist = force_vs_resist**superior_force_exponent
							else force_vs_resist=force_vs_resist**inferior_force_exponent

							var/dmg = 0.85 * percent_damage * loop_delay * force_vs_resist * beam_dmg_mod

							var/thing=1
							if(BP > P.BP) thing = (BP / P.BP)**bp_exponent //FIND: BP EXPONENT
							else thing = (BP / P.BP)**bp_exponent
							dmg*=thing

							if(P.regenerator_obj) dmg *= regenerator_damage_mod

							if(Owner && ismob(Owner))
								dmg *= Owner.AllAttacksDamageModifiers(P)
								if(ShouldOneShot(Owner, P)) dmg *= one_shot_dmg_mult

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

								//DAMAGE INCREASE/DECREASE WITH RANGE
								var/range_dmg_start = 10
								var/range_from_owner = getdist(src,Owner)
								if(gain_power_with_range && range_from_owner > range_dmg_start)
									dmg *= 1 + (range_from_owner - range_dmg_start) * 0.1

								var/range_dmg_loss_start = 10
								if(lose_power_with_range && range_from_owner > range_dmg_loss_start)
									var/range_mult_dmg = 1 - (range_from_owner - range_dmg_loss_start) * 0.1
									if(range_mult_dmg<0.5) range_mult_dmg=0.5
									dmg *= range_mult_dmg
								//-------------

							dmg*=sagas_bonus(Owner,P)
							if(ismob(Owner)) Owner.training_period(P)

							if(getdist(Owner,P) < beam_stun_start)
								dmg /= Beam_Delay**0.7 //because slow beams would be too effective at close range
								dmg *= 5

							if(Owner.BeamStruggling()) dmg *= 3
							if(P.Vampire) dmg *= vampire_damage_multiplier
							if(!is_makosen) P.last_hit_by_beam = world.time
							P.TakeDamage(dmg)
							if(ismob(Owner)&&!P.KO) P.setOpponent(Owner)
							for(var/mob/M in Get_step(src,dir))
								var/m_dmg=percent_damage*loop_delay*1*(BP/M.BP)**bp_exponent*(Force/M.Res)**0.5
								M.TakeDamage(m_dmg)
							if(P && P == A && !P.Safezone)
								if(getdist(Owner,P) < beam_stun_start && P.last_beam_kb_pos != P.loc && apply_short_range_beam_knock && P.type != /mob/Body && !P.KO && P.client)
									P.last_beam_kb_pos=P.loc
									var/kb_dist=6 * (BP / P.BP) * (Force / P.Res)
									kb_dist=ToOne(kb_dist)
									kb_dist=Clamp(kb_dist,0,15)
									var/kb_dir=pick(turn(dir,45),turn(dir,-45),dir)
									//Make_Shockwave(P,256)
									P.Knockback(Owner,Distance=kb_dist,override_dir=kb_dir)
									if(P) //bad mob error
										var/area/a=P.current_area
										if(a) for(var/mob/listener_mob in a.player_list) if(getdist(listener_mob,P)<=10)
											listener_mob<<sound('scouterexplode.ogg',volume=30)
								else
									if(getdist(Owner,P)<10)
										P.has_delay=0
										step(P,dir,32)
										P.has_delay=1
										P.dir=turn(dir,180)
										if(getdist(Owner,P)==10)
											if(!(locate(/obj/BigCrater) in P.loc))
												BigCrater(pos = P.loc, minRangeFromOtherCraters = 4)
							if(P) //missing mob error
								if(P.Health<=0)
									if(Noob_Attack) P.KO()
									else P.KO(Owner)
								if(P) //ko can cause some mobs to delete. avoid error spam
									if(Paralysis)
										P<<"You become paralyzed"
										P.Frozen=1
									if((P.KO&&Owner.Fatal)||!P.client)
										if(P.Health<=0)
											if(P.Regenerate && Damage/loop_delay/Beam_Delay>P.BP*P.Res*12* P.Regenerate**0.3 * ki_power)
												if(Noob_Attack) P.Death(null,1)
												else P.Death(Owner,1)
											else
												if(Noob_Attack) P.Death()
												else P.Death(Owner)
							if(!Piercer)
								icon_state="struggle"
								delete_on_next_move=1
								Debug(Tens,"!piercer")
						//break
				for(var/obj/Blast/A in loc) if(A != src)
					if(A.dir != dir)
						if(!A.Beam)
							Debug(Tens,"no-struggle beam code reached")
							icon_state="struggle"
							layer=MOB_LAYER + 3
							if(getdist(src,Owner)>1)
								if(!(locate(/obj/Blast) in Get_step(src,turn(dir,180))))
									del(src)
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
								A.blast_go_over_owner = 0
								if(prob(25)) Make_Shockwave(Origin=A,sw_icon_size=128)
								walk(A,pick(dirs))
							else
								for(var/obj/Blast/b in Get_step(src,turn(dir,180))) if(b.dir==dir)
									b.icon_state="struggle"
								del(src)
							//break

						//BEAM STRUGGLES
						else if(A.Owner != Owner && A.Owner)
							Debug(Tens,"beam struggle code reached")
							if(Owner.beaming)
								Owner.beam_struggling = world.time
							icon_state="struggle"
							A.icon_state="struggle"
							layer=MOB_LAYER+3
							A.layer=MOB_LAYER+3
							//makes when you stop firing the beam the segments further behind start rapidly deleting themselves til they catch
							//up with the head of the beam then that also deletes itself
							if(!Owner.beaming && getdist(src,Owner) > 2)
								if(!(locate(/obj/Blast) in Get_step(src,turn(dir,180))))
									Owner.ToTens("1")
									SafeTeleport(null)
									del(src)
							//if any of your own beams are ahead of you, make sure this segment takes on the appearance of a "tail"
							//not to be confused with an "end", which is the very very end piece, and a tail is just a common non-head non-end piece
							for(var/obj/Blast/C in Get_step(src,dir))
								if(C.dir == dir && C.Owner == Owner)
									icon_state = "tail"
									layer = initial(layer) - 0.2
									break
							//appears to be just a safety check to make sure any beam segment that went to the "struggle" state will be put back into
							//"tail" state if it is no longer the leader of the beam chain
							for(var/obj/Blast/C in Get_step(src,turn(dir,180)))
								if(C.dir == dir && C.Owner == Owner && C.icon_state == "struggle")
									C.icon_state="tail"
									C.layer = initial(C.layer) - 0.2

							var/winning = BeamStruggleWinning(src, A)
							//var/dist_to_owner = getdist(src, Owner)
							//var/dist_to_enemy = getdist(src, A.Owner)

							//this is because of a bug when you get to the final tile toward the enemy when you should be winning, it becomes an
							//eternal tie, you cant cut thru the final beam segment for some reason
							if(winning == 1)
								for(var/obj/Blast/b in loc)
									if(b != src && b.Owner == A.Owner)
										b.SafeTeleport(null)
										Owner.ToTens("2")
										del(b)
								for(var/obj/Blast/b in get_step(src,dir))
									if(b != src && b.Owner == A.Owner)
										Owner.ToTens("3")
										b.SafeTeleport(null)
										del(b)

							//this is our way of slowing down how fast a winning beam will cut thru the other one
							//we dont want it cutting thru at full speed. so 75% of the time even tho your winning, it'll revert to tie status
							//if(prob(70) && dist_to_owner > 1 && dist_to_enemy > 1)
							//	winning = 0

							if(Owner.key == "EXGenesis")
								if(winning == 1) Owner << "Winning"
								if(winning == 0) Owner << "Tied"
								if(winning == -1) Owner << "Losing"

							if(winning == 1) //winning
								for(var/obj/Blast/B in Get_step(A, turn(A.dir, 180)))
									if(B.dir == A.dir && B.Owner == Owner)
										B.icon_state = "struggle"
								if(!A.delete_on_next_move)
									A.delete_on_next_move = 1
									Owner.ToTens("4")

							if(winning == 0) //tied
								icon_state = "struggle"
								if(getdist(Owner, src) < getdist(A.Owner, A))
									for(var/obj/Blast/B in Get_step(A, turn(A.dir, 180)))
										if(B.dir == A.dir && B.Owner == Owner)
											B.icon_state = "struggle"
									if(!A.delete_on_next_move)
										A.delete_on_next_move = 1
										Owner.ToTens("5")
									if(!delete_on_next_move)
										delete_on_next_move = 1
										Owner.ToTens("6")

							if(winning == -1) //losing
								icon_state = "struggle"
								SafeTeleport(null)
								Owner.ToTens("7")
								del(src)

				var/turf/t = loc
				if(t && isturf(t) && t.density)
					if((t.Health <= wall_breaking_power || Owner.Epic()) && (!ismob(Owner) || (ismob(Owner) && Owner.Is_wall_breaker())))
						if(t.Health != 1.#INF)
							t.Health=0
							t.Destroy()
					if(t) if(!Piercer && t.density)
						icon_state="struggle"
						delete_on_next_move=1
						Owner.ToTens("8")

				for(var/obj/A in loc) if(!istype(A,/obj/Blast) && !istype(A,/obj/Edges))
					if(!A.takes_gradual_damage)
						if(A.Health<=wall_breaking_power)
							if(A.Health != 1.#INF)
								BigCrater(pos = locate(A.x,A.y,A.z), minRangeFromOtherCraters = 4)
								del(A)
					else
						A.Health -= BP / 5 * loop_delay
						if(A.Health<=0)
							BigCrater(pos = A.loc, minRangeFromOtherCraters = 4)
							del(A)
					if(A) if(!Piercer&&A.density)
						icon_state="struggle"
						delete_on_next_move=1
						Owner.ToTens("9")
					break
			//sleep(TickMult(loop_delay))
			sleep(world.tick_lag)

	proc/Explode()
		set waitfor=0
		if(!Explosive) return
		Damage=BP*Force*percent_damage
		for(var/atom/movable/am in view(Explosive,src))
			if(ismob(am)&&am!=Owner)
				var/mob/m=am
				var/same_tile_as_firer
				if(Owner && ismob(Owner) && am.loc==Owner.loc) same_tile_as_firer=1
				if(m.attack_barrier_obj&&m.attack_barrier_obj.Firing_Attack_Barrier)
					//attack barrier deflects all explosion heat and shrapnel
				else if(!same_tile_as_firer)
					if(!m.regenerator_obj && m.Shielding()) Shield(m)
					else
						var/kb_dist=Explosive+Shockwave
						kb_dist=m.relative_kb_dist(src,kb_dist)
						m.Shockwave_Knockback(kb_dist,loc)
						var/dmg=percent_damage*(BP/m.BP)**bp_exponent * 0.5
						var/force_vs_res
						if(!Bullet) force_vs_res=Force/m.Res
						else force_vs_res=Force/m.End
						if(force_vs_res>1) force_vs_res=force_vs_res**0.5
						dmg*=force_vs_res
						if(m.fearful||m.Good_attacking_good()) dmg*=m.Fear_dmg_mult()
						if(Owner&&ismob(Owner)&&Owner.is_kiting) dmg*=kiting_penalty
						if(m.is_teamer) dmg*=teamer_dmg_mult
						if(Owner&&ismob(Owner)&&Owner.is_teamer) dmg/=teamer_dmg_mult
						if(m.regenerator_obj) dmg *= regenerator_damage_mod

						if(ismob(Owner))
							dmg *= Owner.AllAttacksDamageModifiers(m)

							var/resist_dmg_mod=(Owner.Res/Owner.Pow)**0.35
							if(resist_dmg_mod>1) resist_dmg_mod=1
							if(resist_dmg_mod<0.5) resist_dmg_mod=0.5
							dmg*=resist_dmg_mod

						if(bleed_damage) m.BleedDamage(dmg)
						else m.TakeDamage(dmg)

						if(m.Health<=0)
							if(Noob_Attack) m.KO()
							else m.KO(Owner)
						if(Paralysis)
							m<<"You become paralyzed"
							m.Frozen=1
			else if(isobj(am))
				if(am!=src && !istype(am,/obj/Blast)) if(isnum(am.Health) && am.Health <= wall_breaking_power)
					if(am.Health != 1.#INF)
						BigCrater(pos = locate(am.x, am.y, am.z), minRangeFromOtherCraters = 4)
						del(am)
		Explosion_Graphics(Get_step(src,dir),Explosive)
		for(var/turf/A in TurfCircle(Explosive,src))
			if((A.Health <= wall_breaking_power || (ismob(Owner) && Owner.Epic())) && (!ismob(Owner) || (ismob(Owner) && Owner.Is_wall_breaker())))
				if(A.Health != 1.#INF)
					A.Health=0
					if(A.density) A.Destroy()
					else A.Make_Damaged_Ground(1)

	proc/BlastCross(mob/m, override_dir, override_delete)
		set waitfor=0
		if(Beam) return 1 //i think this is right...
		if(!m.density) return 1
		if(!Owner && !override_delete)
			DeleteNoWait()
			return 0
		if(skip_all_collisions) return 1
		if(ismob(m)) return BlastMobCross(m, override_dir, override_delete)
		return 0

	proc/BlastMobCross(mob/m, override_dir, override_delete)
		if(Beam) return 1 //i think this is right...
		if(m.ultra_instinct)
			m.Flip()
			var/d = get_dir(m,src)
			d = turn(d, pick(45,-45))
			if(Owner && get_dir(m,Owner) != turn(dir,180)) d = get_dir(m,Owner)
			step(m,d,32)
			return 1
		if(m == Owner && world.time - projectile_creation_time < 5) return 1
		if(m == Owner && blast_go_over_owner) return 1
		if(blast_go_over_owner)
			if(m == Owner) return 1
			if(m.type == /mob/Splitform)
				var/mob/sf = m
				if(sf.Maker == Owner) return 1
		Damage = BP * Force * percent_damage
		var/dmg = percent_damage
		var/original_dmg = Damage
		var/mob_type = m.type
		if(ismob(Owner))
			if(m != Owner && m.loc == Owner.loc) return 1
			Owner.Set_flash_step_mob(m)
			if(m == Owner.chaser)
				Owner.last_damaged_chaser = 0
				Owner.Remove_fear()
		if(m.drone_module) m.Drone_Attack(Owner, lethal = 1)
		m.SetLastAttackedTime(Owner)
		if(!m.regenerator_obj)
			if(m.Shielding())
				Shield(m)
				player_view(10,src) << sound('reflect.ogg',volume = 10)
				Size = 0
				deflected = 1
				blast_go_over_owner = 0
				walk(src, pick(NORTH,SOUTH,EAST,WEST,NORTHWEST,NORTHEAST,SOUTHWEST,SOUTHEAST))
				return 1
			else
				if(!Bullet && m.Absorb_Blast(src))
					if(!override_delete) del(src)
					return 0

		var/adj_dmg = 1
		if(BP > m.BP) adj_dmg = (BP / m.BP) ** bp_exponent
		else adj_dmg = (BP / m.BP) ** bp_exponent
		dmg *= adj_dmg
		if(ismob(Owner))
			dmg *= Owner.AllAttacksDamageModifiers(m)
			if(ShouldOneShot(Owner, m)) dmg *= one_shot_dmg_mult

		var/force_vs_resist
		if(Bullet) force_vs_resist = Force / m.End
		else force_vs_resist = Force / m.Res
		if(force_vs_resist > 1) force_vs_resist = force_vs_resist ** superior_force_exponent
		else force_vs_resist = force_vs_resist ** inferior_force_exponent
		dmg *= force_vs_resist

		dmg *= Defense_damage_reduction(Owner,m)
		if(m.fearful || m.Good_attacking_good()) dmg *= m.Fear_dmg_mult()
		if(ismob(Owner) && Owner.is_kiting) dmg *= kiting_penalty
		if(m.is_teamer) dmg *= teamer_dmg_mult
		if(ismob(Owner) && Owner.is_teamer) dmg /= teamer_dmg_mult
		if(m.regenerator_obj) dmg *= regenerator_damage_mod
		if(ismob(Owner) && Owner.alignment == "Evil") dmg *= villain_damage_penalty
		dmg *= sagas_bonus(Owner,m)
		if(ismob(Owner)) Owner.training_period(m)
		if(Bullet && !m.client && !istype(m,/mob/Enemy/Core_Demon)) dmg *= 2 //guns do more damage to npcs
		var
			hit_chance = base_blast_accuracy * percent_damage ** 0.3 * (BP / m.BP) ** 0.5
			off_vs_def = Acc_mult(Offense / m.Def)
		hit_chance *= off_vs_def
		if(m.standing_powerup) hit_chance /= standing_powerup_deflect_mult
		if(m.fearful || m.Good_attacking_good()) hit_chance *= m.Fear_dmg_mult()
		if(m.is_teamer) hit_chance *= teamer_dmg_mult
		if(ismob(Owner) && Owner.is_teamer) hit_chance /= teamer_dmg_mult
		if(ismob(Owner)) hit_chance *= Owner.Speed_accuracy_mult(defender = m)
		if(m.dir in list(turn(dir,180), turn(dir,135), turn(dir,225))) hit_chance /= blast_front_deflection_mod
		if(dir == m.dir && !m.knockback_immune && !m.KB && !m.standing_powerup)
			hit_chance *= 2
			dmg *= 1.5
		if(dodging_mode == MANUAL_DODGE)
			m.last_stamina_drain = world.time + 10 //prevent stam recharging and +whatever to add a lil more delay than usual
			var/stam_drain = 1 * percent_damage * Acc_mult(Offense / m.Def) * (BP / m.BP) ** bp_exponent
			if(m.stamina < stam_drain || !m.CanBlastDeflect()) hit_chance = 100
			else
				hit_chance = 0
				m.AddStamina(-stam_drain)
		if(m.grabber || m.KO || m.regenerator_obj) hit_chance = 100
		if(prob(hit_chance) || !Deflectable || m.Disabled())
			if(!m.regenerator_obj && m.precog && m.precogs && prob(m.precog_chance) && !m.KO && (m.Flying || m.icon_state == "") && m.Ki > m.max_ki * 0.2 && !m.Disabled())
				m.precog--
				var/turf/old_loc = m.loc
				step(m, turn(dir,pick(-45,45)), 32)
				if(m.loc != old_loc) return 1
			if(dir == m.dir) Offense *= 3
			if(m.Vampire) dmg *= vampire_damage_multiplier
			if(bleed_damage) m.BleedDamage(dmg)
			else m.TakeDamage(dmg)
			if(shuriken) m.ShurikenOverlayEffect(icon)
			if(percent_damage >= 10) Make_Shockwave(m, sw_icon_size = Get_projectile_shockwave_size(src))
			if(ismob(Owner) && !m.KO) m.setOpponent(Owner)
			if(m.Health <= 0)
				m.KO(Owner)
				if(m) //prevent null error spam since ko deletes some kinds of mobs
					if(Fatal || !m.client)
						m.TakeDamage(dmg)
						if(m.Health <= 0)
							if(m.Regenerate && !Bullet && original_dmg > m.BP * m.Res * m.Regenerate ** 0.5 * 150 * ki_power)
								m.Death(Owner,1)
							else m.Death(Owner)
			if(m) //avoid error spam
				if(slice_attack) m.check_lose_tail(dmg,src)
				if(Shockwave && !Explosive)
					var/kb_dist = Shockwave
					if(ismob(Owner))
						if(get_dist(src,Owner) <= 1) kb_dist *= 2.5
						else if(get_dist(src,Owner) == 2) kb_dist *= 1.5
					kb_dist = m.relative_kb_dist(src,kb_dist)
					var/turf/t = loc
					if(override_dir) t = get_step(m,turn(override_dir,180))
					m.Shockwave_Knockback(kb_dist,t)
				if(Stun && m)
					var/base_stun = 20 * Stun
					var/stun = base_stun * (BP / m.BP) ** bp_exponent * (Force / m.Res) ** 0.25
					stun = Clamp(stun, 0, base_stun * 3)
					if(ismob(Owner) && Owner.Class == "Spirit Doll") stun *= 1.5
					m.ApplyStun(time = stun)
			Explode()
		else
			SafeTeleport(m.loc)
			Size = 0
			if(!deflected)
				percent_damage *= 2 //so it can cut thru blasts on the way back
				deflected = 1
				blast_go_over_owner = 0
			var/reflect_chance = 100 * (m.Def / (Offense / off_mult))
			if(prob(reflect_chance)) dir = turn(dir,180)
			else dir = pick(turn(dir,45 + 180), turn(dir, -45 + 180), turn(dir, 90 + 180), turn(dir, -90 + 180))
			if(m.client) flick("Attack",m)
			player_view(10,src) << sound('reflect.ogg',volume = 10)
			walk(src,dir)
			return 1
		if(!Piercer && !Bounce && !override_delete)
			if(weaker_obstacles_cant_destroy_blast && mob_type == /mob/Body && (!m || !m.z))
			else
				skip_all_collisions = 1
				DeleteNoWait(delay = world.tick_lag)
				return 0
		else
			original_dmg /= 2 //damage is decreased every time it slices thru something
			Damage = original_dmg
			SafeTeleport(get_step(src,dir))
			Bounce_Dir()
		return 0

	Bump(mob/A,override_dir,override_delete)
		if(isobj(A))
			if(!A) return
			if(istype(A,/obj/Blast) && density)
				if(A.dir==dir)
					SafeTeleport(A.loc)
					for(var/mob/m in loc)
						Bump(m)
						break
				else
					Explode()
					//if(!Beam) Make_Shockwave(A,sw_icon_size=Get_projectile_shockwave_size(src))
					var/obj/Blast/b=A
					var/this_cutting_power=BP**0.2 * Force**0.2 * percent_damage
					var/their_cutting_power=b.BP**0.2 * b.Force**0.2 * b.percent_damage
					if(Bullet) this_cutting_power/=3
					if(b.Bullet) their_cutting_power/=3
					if(prob(this_cutting_power/their_cutting_power*50)) del(A)
					else del(src)
			else
				if(A)
					var/del_self
					var/do_explosion = 1

					if(A.takes_gradual_damage) A.Health-=BP/5
					else if(A.Health<=wall_breaking_power && A.Health != 1.#INF) A.Health=0
					if(A.Health<=0)
						var/obj/oo = A
						if(!oo.leaves_big_crater)
							Small_crater(A.loc)
						del(A)
					else if(blast_go_over_obstacles_if_cant_destroy)
						SafeTeleport(A.loc)
						do_explosion = 0
					else if(!Piercer && !Bounce && !override_delete) del_self = 1

					if(do_explosion)
						Explode()
						if(!Beam)
							if(percent_damage >= 10 && A != last_object_shockwaved_against) Make_Shockwave(A,sw_icon_size=Get_projectile_shockwave_size(src))
							last_object_shockwaved_against=A

					if(del_self) del(src)
			Bounce_Dir()

		if(isturf(A) && A.density)
			Explode()
			//if(A != last_object_shockwaved_against) Make_Shockwave(A,sw_icon_size=Get_projectile_shockwave_size(src))
			last_object_shockwaved_against=A
			var/turf_destroyed = 0
			var/destroy_blast_anyway = 0
			if(A.Health != 1.#INF)
				if((A.Health <= wall_breaking_power || (Owner && ismob(Owner) && Owner.Epic())) && (!Owner || !ismob(Owner) || (ismob(Owner) && Owner.Is_wall_breaker())))
					if(A.Health != 1.#INF)
						var/turf/t=A
						if(t.destroy_blast_anyway) destroy_blast_anyway = 1
						t.Health=0
						t.Destroy()
						turf_destroyed = 1
			if(!Piercer && !Bounce && !override_delete)
				if(turf_destroyed && weaker_obstacles_cant_destroy_blast && !destroy_blast_anyway)
				else del(src)
			Bounce_Dir()

	proc
		Bounce_Dir()
			set waitfor=0
			if(Bounce) walk(src,pick(turn(dir,135),turn(dir,-135),turn(dir,180)))

obj/var/Knockable=1

obj/proc/Shockwave_Knockback(Amount,turf/A)
	set waitfor=0
	if(Knockable) while(Amount)
		Amount-=1
		var/old_loc=loc
		for(var/obj/Turfs/Door/d in Get_step(src,get_dir(A,src))) return
		step(src,get_dir(A,src),32)
		if(old_loc==loc) Amount=0
		sleep(world.tick_lag)

mob/proc/Shockwave_Knockback(Amount,turf/A, bypass_immunity)
	set waitfor=0

	if(is_saitama || key == "EXGenesis") return
	if(!z) return //prevent body swap bug knocking them out of body
	if(regenerator_obj && regenerator_obj.base_loc() == base_loc()) return

	if(transing) Amount/=2
	if(Class == "Legendary Yasai" && lssj_always_angry) Amount *= 0.5
	if(jirenAlien) Amount *= jirenAlienKBresist
	Amount=ToOne(Amount)
	if(Safezone||KB) return
	if(!bypass_immunity && knockback_immune) return
	var/Dusts=0
	if(Amount>=7) Dusts=10
	//if(Amount>=15) view(10,src)<<'swoophit.ogg'
	//var/Old_State
	//if(icon_state!="KB") Old_State=icon_state
	if(client) icon_state="KB"
	var/start_loc=loc

	var/mob/m=grabbedObject
	ReleaseGrab()
	if(m&&ismob(m)) m.Shockwave_Knockback(Amount,A)

	if(Diarea) spawn Diarea(Other_Chance=100)

	var/d=get_dir(A,src)
	if(prob(20)) d=pick(turn(get_dir(A,src),45),turn(get_dir(A,src),-45))

	while(Amount)
		Amount-=1
		KB=1

		var/old_loc=loc
		step(src,d,32)
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
		if(loc != start_loc) Dust(src, end_size = 1, time = 10)
	icon_state="" //if(Old_State && Old_State!="KB") icon_state=Old_State
	if(Flying && !ultra_instinct) icon_state="Flight"
	if(KO) icon_state="KO"

proc
	BeamStruggleWinning(obj/Blast/a, obj/Blast/b)
		var/needed_advantage = 1.1
		if(a.BeamStrugglePower() > b.BeamStrugglePower() * needed_advantage) return 1 //winning
		if(a.BeamStrugglePower() * needed_advantage < b.BeamStrugglePower()) return -1 //losing
		return 0 //tied

obj/Blast/proc/BeamStrugglePower()
	//we divide percent_damage by Beam_Delay because in BeamStream it is multiplied by Beam_Delay and we need to undo that
	var/beam_struggle_power = (BP ** 0.5) * (Force ** 0.4) * ((percent_damage / Beam_Delay) ** 1)
	return beam_struggle_power
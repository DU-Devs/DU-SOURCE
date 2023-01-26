mob/var/tmp/list/Lootables

obj/Cancel_Loot
	name="Cancel"
	Click() usr.Lootables=null

mob/proc/DisplayItemCost(obj/o)
	set waitfor=0
	sleep(5)
	if(world.time - last_double_click > 10)
		src << "[o] costs [Commas(Item_cost(src, o))] resources for you to make"

mob/var/tmp
	last_double_click = 0

client/DblClick(obj/A)
	mob.last_double_click = world.time
	mob.TryCreateScienceItem(A)

client/Click(obj/A, location, control, params)
	if(A in tech_list) mob.DisplayItemCost(A)
	else if(mob.Lootables&&mob&&isobj(A)&&(A in mob.Lootables)&&!istype(A,/obj/Cancel_Loot))
		for(var/mob/B in view(1,mob))
			if(A.loc==B)
				if(!B.KO)
					usr.SendMsg("They are no longer knocked out", CHAT_IC)
					mob.Lootables=null
					return
				if(!(A in B.item_list)&&!istype(A,/obj/Resources))
					usr.SendMsg("Someone has already taken it", CHAT_IC)
					mob.Lootables-=A
					return
				if(!(B in oview(1,mob)))
					usr.SendMsg("You are not near them", CHAT_IC)
					mob.Lootables=null
				mob.Lootables-=A
				if(istype(A,/obj/Resources))
					var/obj/Resources/C=A
					for(var/mob/M in player_view(15,mob))
						M.SendMsg("[mob] ([mob.displaykey]) steals [Commas(C.Value)] resources from [B]", CHAT_IC)
					mob.Alter_Res(C.Value)
					C.Value=0
					C.Update_value()
				else
					if(A==B.Scouter) B.Scouter=null
					for(var/mob/M in player_view(15,mob))
						M.SendMsg("[mob] ([mob.displaykey]) steals [A] from [B]", CHAT_IC)
					B.overlays-=A.icon
					A.Move(mob)
					if(A.suffix=="Equipped") A.suffix=null
					if(B) B.Restore_hotbar_from_IDs()
	else if(A in Alien_Icons) A:Choose(usr)
	else if(A in Demon_Icons) A:Choose(usr)
	else . = ..()

mob/proc/Zanzoken_Drain(N=1)
	return Clamp(30 / Math.Max(N + (GetStatMod("Spd") + Math.Floor(GetStatMod("Ref") / 2)), N), 1, max_ki)

obj/After_Image
	Savable = 0
	mouse_opacity = 0
	attackable = 0
	New()
		flick('Zanzoken.dmi',src)
	Del()
		alpha = 255
		. = ..()

mob/proc/AfterImage(T = 65, Pixel = 0, turf/loc_override)
	set waitfor=0
	var/turf/t = loc
	if(loc_override) t = loc_override
	if(!(locate(/obj/After_Image) in t))
		var/obj/After_Image/A = GetCachedObject(/obj/After_Image, t)
		A.pixel_x=rand(-Pixel,Pixel)
		A.pixel_y=rand(-Pixel,Pixel)
		A.dir=dir
		A.icon=icon
		A.overlays=overlays
		A.underlays=underlays
		A.invisibility=invisibility
		animate(A, alpha = 0, time = T, easing = CUBIC_EASING)
		Timed_Delete(A, T + world.tick_lag)

mob/var/Zanzoken=1

mob/proc/Charging_or_Streaming()
	if(charging_beam||beaming) return 1
	for(var/obj/Skills/Combat/Ki/A in ki_attacks) if(A.charging||A.streaming) return 1

obj/var/tmp/last_use = 0

turf/Click(turf/T) if(isturf(T))
	if(usr.Disabled()) return
	if(usr.move)
		if(usr.client.eye!=usr) return
		if(usr in src) return

		//EXPLOSION
		for(var/obj/Skills/Combat/Ki/Explosion/K in usr.ki_attacks) if(K.On)
			if(getdist(usr, T) > 20) return
			if(getdist(usr, src) > 20) return
			if(usr.BeamStruggling()) return
			if(usr.tournament_override()) return

			if(usr.attacking||usr.grabber) return
			if(usr.Charging_or_Streaming()) return
			if(usr.Ki>=5)
				if(world.time - K.last_use < 20 * usr.Speed_delay_mult(severity = 0.35)) return
				K.last_use = world.time
				K.Skill_Increase(5,usr)
				if(K.Level<=2) player_view(10,src)<<sound('kiplosion.ogg',volume=40)
				else player_view(10,src)<<sound('Explosion 2.wav',volume=40)
				var/list/l = TurfCircle(7,T)
				var/total_mobs_exploded=0
				var/total_objs_exploded=0

				for(var/turf/A in view(K.Level,T)) if((A in l) && prob(100))
					spawn for(var/v in 1 to 3) if(prob(15)||(A==T&&v==1))
						sleep(rand(2,4))
						Explosion_Graphics(A,rand(2,4))
					var/n=0
					var/craterAlready
					for(var/obj/B in A) if(!istype(B,/obj/Explosion))
						n++
						total_objs_exploded++
						if(total_objs_exploded>50) break
						if(n>10) break
						if(B.Health<=usr.BP)
							if(!craterAlready)
								BigCrater(pos = locate(B.x,B.y,B.z), minRangeFromOtherCraters = 3)
								craterAlready = 1
							del(B)
					n=0
					for(var/mob/B in A) if(B!=usr)
						n++
						if(n>5) break
						total_mobs_exploded++
						if(total_mobs_exploded>50) break
						if(!B.AOE_auto_dodge(usr,Get_step(B,get_dir(B,T))))
							var/dmg = 10
							var/pow_vs_res = usr.GetStatMod("For") * usr.GetTierBonus(0.5) - B.GetStatMod("Res") * B.GetTierBonus(0.75)
							
							dmg += pow_vs_res

							if(!B.shield_obj || !B.shield_obj.Using) B.TakeDamage(dmg, usr)
							if(B&&B.drone_module) B.Drone_Attack(usr,lethal=1)
					if((A.defenseTier * Mechanics.GetSettingValue("Turf Health Multiplier") < usr.effectiveBPTier + usr.GetStatMod("For")) && usr.Is_wall_breaker())
						if(A.Health != 1.#INF)
							A.Health=0
							A.Destroy()
				usr.IncreaseKi(-150)
			else usr.SendMsg("You do not have enough energy.", CHAT_IC)
			return
		if(locate(/obj/Turfs/Door) in src) return

		if(usr.CanInputMove())
			for(var/obj/Skills/Utility/Zanzoken/A in usr) if(!T.density&&(!IsWater(T)||usr.Flying)&&usr.Ki>=usr.Zanzoken_Drain())

				var/stam_drain = 0.01 * usr.max_stamina
				if(usr.Being_chased()) stam_drain *= 2
				if(usr.stamina < stam_drain) break

				if(usr.dash_attacking) break
				if(usr.BeamStruggling()) break
				if(usr.Charging_or_Streaming()) break
				if(!usr.can_zanzoken||usr.stun_level) break
				if(usr.grabbedObject) break
				if(usr.Beam_stunned()) break
				if(usr.IsShielding()) break
				for(var/mob/M in T) if(M.density) break
				for(var/obj/O in T) if(O.density) break
				for(var/obj/Skills/Combat/Ki/At in usr.ki_attacks) if(At.charging||At.streaming||At.Using) break
				if(usr && T && T.z == usr.z && get_dist(T, usr) <= 20 && viewable(usr, T))
					A.Skill_Increase(1,usr)

					usr.IncreaseStamina(-stam_drain)

					player_view(10,usr)<<sound('teleport.ogg',volume=15)
					flick('Zanzoken.dmi',usr)
					var/OldDir=usr.dir
					usr.AfterImage()
					var/distance_mod=1
					if(getdist(usr,T)>6) distance_mod+=(getdist(usr,T)-6)*0.15
					if(usr.senzu_overload) distance_mod++
					var/old_t=src
					usr.SafeTeleport(T)
					usr.last_input_move = world.time
					usr.Check_if_kiting(old_t)
					usr.dir=OldDir
					usr.Zanzoken_Mastery(0.5)
					usr.IncreaseKi(-usr.Zanzoken_Drain())
					var/health_mod=(100/Clamp(usr.Health,1,100))**0.4 //affects zanzo speed
					if(health_mod>5) health_mod=5
					if(health_mod<1) health_mod=1
					break

			// Comment this out if it starts to let you teleport into people's bases or something
			if(usr.client.eye==usr) if(!usr.KO && !usr.BeamStruggling()) for(var/obj/Skills/Utility/Shunkan_Ido/A in usr) if(A.Level>=20)
				if(!T.density && (!IsWater(T) || usr.Flying) && (!T.Owner || T.Owner != usr))
					player_view(10,usr)<<sound('teleport.ogg',volume=15)
					flick('Zanzoken.dmi',usr)
					usr.SafeTeleport(locate(x,y,z))

mob/var/tmp/can_zanzoken=1

mob/Click()
	if(usr.Target==src||(usr==src&&usr.Target&&usr.Target!=src))
		usr.RemoveTarget()
	else
		for(var/obj/items/Scouter/O in usr.item_list) if(O.suffix)
			player_view(10,usr)<<sound('scouterbeeps.ogg',volume=35)
			spawn(30) if(usr) player_view(10,usr)<<sound(pick('scouter.ogg','scouterend.ogg'),volume=35)
			break
		usr.SetTarget(src)
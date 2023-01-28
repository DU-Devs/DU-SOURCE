mob/proc/Zanzoken_Drain(N=1)
	N=Clamp(30/Zanzoken,1,1.#INF)
	if(N>max_ki) N=max_ki
	return N
obj/After_Image
	Savable=0
	New() flick('Zanzoken.dmi',src)
mob/proc/After_Image(T=50,Pixel=0,turf/loc_override)
	var/turf/t=loc
	if(loc_override) t=loc_override
	if(!(locate(/obj/After_Image) in loc))
		var/obj/After_Image/A=new(t)
		A.pixel_x=rand(-Pixel,Pixel)
		A.pixel_y=rand(-Pixel,Pixel)
		A.dir=dir
		A.icon=icon
		A.overlays=overlays
		A.underlays=underlays
		A.invisibility=invisibility
		Timed_Delete(A,T)
mob/var/Zanzoken=1
mob/proc/Charging_or_Streaming()
	if(charging_beam||beaming) return 1
	for(var/obj/Attacks/A in ki_attacks) if(A.charging||A.streaming) return 1
turf/Click(turf/T) if(isturf(T))
	if(usr.Disabled()) return
	if(usr.move)
		if(usr.client.eye!=usr) return
		if(usr in src) return
		if(!usr.attack_barrier_obj||!usr.attack_barrier_obj.Firing_Attack_Barrier) for(var/obj/Attacks/Explosion/K in usr.ki_attacks) if(K.On)
			if(usr.tournament_override()) return

			if(usr.attacking||usr.grabber) return
			if(usr.Charging_or_Streaming()) return
			if(usr.Ki>=5)
				usr.attacking=3
				K.Skill_Increase(5,usr)
				if(K.Level<=2) player_view(10,src)<<sound('kiplosion.ogg',volume=40)
				else player_view(10,src)<<sound('Explosion 2.wav',volume=40)
				var/list/turf_circle=Turf_Circle(K.Level,T)
				var/total_mobs_exploded=0
				var/total_objs_exploded=0
				for(var/turf/A in view(K.Level,T)) if(A in turf_circle) if(prob(100))
					spawn for(var/v in 1 to 3) if(prob(15)||(A==T&&v==1))
						sleep(rand(2,4))
						Explosion_Graphics(A,rand(2,4))
					var/n=0
					for(var/obj/B in A) if(!istype(B,/obj/Explosion))
						n++
						total_objs_exploded++
						if(total_objs_exploded>50) break
						if(n>10) break
						if(B.Health<=usr.BP)
							Big_crater(locate(B.x,B.y,B.z))
							del(B)
					n=0
					for(var/mob/B in A) if(B!=usr)
						n++
						if(n>5) break
						total_mobs_exploded++
						if(total_mobs_exploded>50) break
						if(!B.AOE_auto_dodge(usr,Get_step(B,get_dir(B,T))))
							var/dmg=10*((usr.BP/B.BP)**0.6)*ki_power
							var/pow_vs_res=usr.Pow/B.Res
							if(pow_vs_res>1) pow_vs_res=pow_vs_res**0.3
							dmg*=pow_vs_res

							dmg*=sagas_bonus(usr,B)
							usr.training_period(B)

							if(!B.shield_obj||!B.shield_obj.Using) B.Health-=dmg
							if(B.Health<=0)
								if(!B.client) spawn if(B) B.Death(usr)
								else spawn if(B) B.KO("[usr]")
							spawn if(B&&B.drone_module) B.Drone_Attack(usr,lethal=1)
					if((A.Health<usr.Wall_breaking_power()||usr.Epic())&&usr.Is_wall_breaker())
						A.Health=0
						A.Destroy()
				usr.Ki-=50
				spawn(25*usr.Speed_delay_mult(severity=0.5)) if(usr) usr.attacking=0
			else usr<<"You do not have enough energy."
			return
		if(locate(/obj/Turfs/Door) in src) return
		if(!usr.attack_barrier_obj||!usr.attack_barrier_obj.Firing_Attack_Barrier)
			for(var/obj/Zanzoken/A in usr) if(!T.density&&(!T.Water||usr.Flying)&&usr.Ki>=usr.Zanzoken_Drain())
				if(usr.dash_attacking) return
				if(usr.zanzoken_uses>=usr.Max_zanzokens()) return
				if(usr.Charging_or_Streaming()) return
				if(!usr.can_zanzoken||usr.stun_level) return
				for(var/mob/M in T) if(M.density) return
				for(var/obj/O in T) if(O.density) return
				if(usr.grabbed_mob) return
				if(usr.Beam_stunned()) return
				//if(usr.Dash_Attack(T)) return
				for(var/obj/Attacks/At in usr.ki_attacks) if(At.charging||At.streaming||At.Using) return
				if(T in view(15,usr))
					A.Skill_Increase(1,usr)
					usr.zanzoken_uses++
					player_view(10,usr)<<sound('teleport.ogg',volume=15)
					flick('Zanzoken.dmi',usr)
					var/OldDir=usr.dir
					usr.After_Image()
					//var/directional_modifier=1
					//if(get_dir(usr,T) in list(turn(usr.dir,180),turn(usr.dir,135),turn(usr.dir,225)))
					//	directional_modifier=2
					var/distance_mod=1
					if(getdist(usr,T)>6) distance_mod+=(getdist(usr,T)-6)*0.15
					if(usr.senzu_overload) distance_mod++
					var/old_t=src
					usr.Move(T)
					usr.Check_if_kiting(old_t)
					usr.dir=OldDir
					usr.Zanzoken_Mastery(0.5)
					usr.Ki-=usr.Zanzoken_Drain()
					//usr.can_zanzoken=0
					var/health_mod=(100/Clamp(usr.Health,1,100))**0.4 //affects zanzo speed
					if(health_mod>5) health_mod=5
					if(health_mod<1) health_mod=1
					//spawn(To_tick_lag_multiple(usr.speed_ratio()**0.5*15*health_mod*directional_modifier*distance_mod)) if(usr) usr.can_zanzoken=1
					return
			if(usr.client.eye==usr) if(!usr.KO) for(var/obj/Shunkan_Ido/A in usr) if(A.Level>=20)
				if(!T.density&&!T.Water)
					player_view(10,usr)<<sound('teleport.ogg',volume=15)
					flick('Zanzoken.dmi',usr)
					usr.loc=locate(x,y,z)
mob/var/tmp/can_zanzoken=1
mob/Click()
	if(client&&KO&&src!=usr&&(src in view(1)))
		if(usr.tournament_override(fighters_can=0)) return
		if(alignment_on&&both_good(src,usr))
			usr<<"You can not steal from other good people"
			return
		if(Same_league_cant_kill(src,usr))
			usr<<"You can not steal from fellow league members"
			return
		if(!usr.Lootables) usr.Lootables=new/list
		usr.Lootables+=new/obj/Cancel_Loot
		if(resource_obj) usr.Lootables+=resource_obj
		for(var/obj/A in src) if(A.Stealable) usr.Lootables+=A
		while(src&&usr&&getdist(src,usr)<=1&&KO&&!usr.KO) sleep(4)
		if(usr) usr.Lootables=null
		return
	if(Class!="Legendary Saiyan"&&!ssj&&SSj4Able&&!usr.Target&&src==usr&&!transing&&!KO)
		SSj4()
		return
	if(usr.Target==src||(usr==src&&usr.Target&&usr.Target!=src)) usr.Target=null
	else
		for(var/obj/items/Scouter/O in usr.item_list) if(O.suffix)
			player_view(10,usr)<<sound('scouterbeeps.ogg',volume=35)
			spawn(30) if(usr) player_view(10,usr)<<sound(pick('scouter.ogg','scouterend.ogg'),volume=35)
			break
		usr.Target=src
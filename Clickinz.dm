mob/proc/Zanzoken_Drain(N=1)
	N=Max_Ki/Zanzoken/Eff
	if(N>Max_Ki) N=Max_Ki
	return N
obj/After_Image
	New() flick('Zanzoken.dmi',src)
mob/proc/After_Image(T=50,Pixel=0)
	if(!(locate(/obj/After_Image) in loc))
		var/obj/After_Image/A=new(loc)
		A.pixel_x=rand(-Pixel,Pixel)
		A.pixel_y=rand(-Pixel,Pixel)
		A.dir=dir
		A.icon=icon
		A.overlays=overlays
		A.underlays=underlays
		A.invisibility=invisibility
		Timed_Delete(A,T)
mob/var/Zanzoken=1
mob/proc/Charging_or_Streaming() for(var/obj/Attacks/A in src) if(A.charging||A.streaming) return 1
turf/Click(turf/T) if(isturf(T))
	if(usr.Disabled()) return
	if(usr.move&&!usr.Charging_or_Streaming())
		if(usr.client.eye!=usr) return
		if(usr in src) return
		for(var/obj/Attacks/Explosion/K in usr) if(K.On)

			if((usr in All_Entrants)&&!usr.Is_Fighter()&&usr.z==7)
				usr<<"You can not attack until it is your turn to fight"
				return

			if(usr.attacking) return
			if(usr.Ki>=5)
				usr.attacking=3
				K.Skill_Increase(5,usr)
				if(K.Level<=2) view(10,src)<<sound('kiplosion.ogg',volume=40)
				else view(10,src)<<sound('Explosion 2.wav',volume=40)
				for(var/turf/A in view(K.Level,T)) if(prob(100))
					var/n=0
					for(var/mob/B in A) if(!B.Flying)
						n++
						if(n>10) break
						var/Shield
						for(var/obj/Shield/S in B) if(S.Using) Shield=1
						if(!Shield) B.Health-=30*((usr.Pow/B.Res)**0.5)*(usr.BP/B.BP)*Ki_Power
						if(B.Health<=0)
							if(!B.client) spawn if(B) B.Death(usr)
							else spawn if(B) B.KO("[usr]")
					n=0
					for(var/obj/B in A) if(!istype(B,/obj/Explosion))
						n++
						if(n>10) break
						if(B.Health<=usr.BP)
							new/obj/BigCrater(locate(B.x,B.y,B.z))
							del(B)
					if(A.Health<usr.BP)
						A.Health=0
						A.Destroy()
				usr.Ki-=50
				Explosion_Graphics(src,K.Level,20)
				spawn(25*usr.Speed_Ratio()) if(usr) usr.attacking=0
			else usr<<"You do not have enough energy."
			return
		if(locate(/obj/Turfs/Door) in src) return
		for(var/obj/Zanzoken/A in usr) if(!T.density&&(!T.Water||usr.Flying)&&usr.Ki>=usr.Zanzoken_Drain())
			for(var/mob/M in T) if(M.density) return
			for(var/obj/O in T) if(O.density) return
			if(usr.GrabbedMob) return
			if(usr.Dash_Attack(T)) return
			if(T in view(15,usr))
				A.Skill_Increase(1,usr)
				view(10,usr)<<sound('teleport.ogg',volume=15)
				flick('Zanzoken.dmi',usr)
				var/OldDir=usr.dir
				usr.After_Image()
				usr.Move(T)
				usr.dir=OldDir
				usr.Zanzoken_Mastery(0.1)
				usr.Ki-=usr.Zanzoken_Drain()
				return
	if(usr.client.eye==usr) if(usr.icon_state!="KO") for(var/obj/Shunkan_Ido/A in usr) if(A.Level>=20)
		usr.Ki*=0.9
		if(!T.density&&!T.Water)
			view(10,usr)<<sound('teleport.ogg',volume=15)
			flick('Zanzoken.dmi',usr)
			usr.loc=locate(x,y,z)
mob/Click()
	if(client&&KO&&src!=usr&&(src in view(1)))
		if(src in All_Entrants)
			usr<<"You can not steal during a tournament"
			return
		if(!usr.Lootables) usr.Lootables=new/list
		usr.Lootables+=new/obj/Cancel_Loot
		for(var/obj/Resources/A in src) usr.Lootables+=A
		for(var/obj/A in src) if(A.Stealable) usr.Lootables+=A
		while(src&&usr&&getdist(src,usr)<=1&&KO&&!usr.KO) sleep(10)
		if(usr) usr.Lootables=null
		return
	if(!ssj&&SSj4Able&&!usr.Target&&src==usr&&!transing&&!KO)
		SSj4()
		return
	if(usr.Target==src||(usr==src&&usr.Target&&usr.Target!=src)) usr.Target=null
	else
		for(var/obj/items/Scouter/O in usr) if(O.suffix)
			view(10)<<sound('scouterbeeps.ogg',volume=35)
			spawn(30) if(usr) view(10)<<sound(pick('scouter.ogg','scouterend.ogg'),volume=35)
			break
		usr.Target=src
obj/Hokuto_Shinken
	teachable=1
	Skill=1
	Teach_Timer=3
	Cost_To_Learn=6
	desc="Hokuto Hyakuretsu Ken from the Hokuto no Ken anime."
	var/tmp/Attacking
	verb/Hundred_Crack_Fist()
		set category="Skills"
		if(usr in All_Entrants)
			usr<<"You can not use this in tournaments"
			return
		switch(input("Choose an option") in list("Cancel","Attack Targets","Destroy Targets","Play Ai Wo Torimodose"))
			if("Cancel") return
			if("Play Ai Wo Torimodose") switch(input("Choose version") in list("Intro","Kickin' Ass"))
				if("Intro") for(var/mob/P in view(10,usr)) P<<sound('Ai Wo Torimodose.ogg',volume=100)
				if("Kickin' Ass") for(var/mob/P in view(10,usr)) P<<sound('Ai Wo Torimodose 2.ogg',volume=30)
			if("Destroy Targets") for(var/mob/P) for(var/obj/Hokuto_Shinken_Energy/E in P) if(E.Creator==usr.key)
				P.Hokuto_Shinken_Effects(usr)
			if("Attack Targets")
				if(usr.KO) return
				if(usr.Ki<usr.Max_Ki) return
				if(Attacking||usr.attacking) return
				var/list/Chosen_Targets=new
				var/list/Possible_Targets=new
				Possible_Targets+="Done"
				for(var/mob/P in oview(usr)) if(!P.Safezone) Possible_Targets+=P
				while(1)
					var/mob/P=input(usr,"Choose your targets") in Possible_Targets
					if(P=="Done") break
					else if(P)
						Chosen_Targets+=P
						Possible_Targets-=P
				if(usr.KO) return
				if(usr.Ki<usr.Max_Ki) return
				if(Attacking||usr.attacking) return
				if(!(locate(/mob) in Chosen_Targets)) return
				Attacking=1
				usr.Str*=0.1
				usr.StrMod*=0.1
				usr.Spd*=10
				usr.SpdMod*=10
				usr.Res*=0.2
				usr.ResMod*=0.2
				usr.DefMod*=0.2
				usr.Def*=0.2
				for(var/mob/P in view(10,usr)) if(P.client)
					P<<sound('ATATATA.ogg')
					P<<"A glowing aura of power appears around [usr], suddenly their shirt rips off!"
				spawn(12) if(usr)
					for(var/obj/items/Clothes/TankTop/K in usr) if(K.suffix) K.Click(usr)
					for(var/obj/items/Clothes/ShortSleeveShirt/K in usr) if(K.suffix) K.Click(usr)
				var/Aura='AuraTall.dmi'+rgb(255,255,255)
				var/image/I=image(icon=Aura,icon_state="top",pixel_y=32)
				var/image/F=image(icon=Aura,icon_state="bottom")
				usr.overlays.Add(I,F)
				sleep(62)
				usr.Say("HOOOO!!! ATATATATATATATATATATATATA!!!")
				var/Amount=0
				for(var/mob/P in Chosen_Targets) Amount+=5
				if(Amount<17) Amount=17
				new/obj/BigCrater(usr.loc)
				Dust(usr,10)
				Make_Shockwave(usr,5)
				while(Amount)
					Amount-=1
					if(Chosen_Targets)
						var/mob/M=pick(Chosen_Targets)
						if(M&&M.z==usr.z)
							usr.Warp_To(Get_Warp_Destination(M,usr),M)
							usr.dir=get_step(usr,M)
							if(M&&!M.KO) usr.Melee()
							spawn if(usr) Make_Shockwave(usr,3)
					sleep(3)
				usr.overlays.Remove(I,F)
				usr.Ki=0
				usr.Str*=10
				usr.StrMod*=10
				usr.Spd/=10
				usr.SpdMod/=10
				usr.Res*=5
				usr.ResMod*=5
				usr.DefMod*=5
				usr.Def*=5
				Attacking=0
				Skill_Increase(1,usr)
mob/proc/Hokuto_Shinken_Effects(mob/P)
	for(var/obj/Hokuto_Shinken_Energy/E in src) if(E.Creator==P.key)
		if(E.Level<BP)
			src<<"Your body feels much internal pressure and pain for a few seconds but you are able to resist it due to your \
			power. [P]'s Hokuto Shinken has failed."
			del(E)
		else spawn(rand(1,50)) if(src)
			Body_Parts(20,1)
			view(10,src)<<"[src]'s body swells and is in immense pain, only a moment later they explode as the effect's of [P]'s \
			Hokuto Shinken style kills them instantly...(Killed by [P.key])"
			var/turf/T=loc
			Death(P)
			if(T) for(var/mob/S in T) if(!S.client) S.overlays+='Exploded Head.dmi'
			del(E)
mob/proc/Add_Hokuto_Shinken_Energy(mob/P) if(!(locate(/obj/Hokuto_Shinken_Energy) in P))
	for(var/obj/Hokuto_Shinken/H in src) if(H.Attacking)
		var/obj/Hokuto_Shinken_Energy/E=new
		E.Creator=key
		E.Level=BP
		P.contents+=E
		break
obj/Hokuto_Shinken_Energy
	Givable=0
	Makeable=0
	New() spawn(3000) if(src) del(src)
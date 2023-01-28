mob/proc/using_hokuto() if(hokuto_obj&&hokuto_obj.Attacking) return 1

mob/var/tmp/obj/Hokuto_Shinken/hokuto_obj

obj/Hokuto_Shinken
	teachable=1
	Skill=1
	name="Hundred Crack Fist"
	hotbar_type="Melee"
	can_hotbar=1
	Teach_Timer=3
	student_point_cost = 30
	Cost_To_Learn=11
	desc="Hokuto Hyakuretsu Ken from the Hokuto no Ken anime. If it succeeds the enemies die instantly, \
	but if it fails you will be knocked out. The effectiveness is based on your strength and BP, versus their \
	durability and BP. Also if they \
	dodge all the hits it fails. I know that's not quite how it works in the anime but meh."
	var/tmp/Attacking
	New()
		spawn if(ismob(loc))
			var/mob/M=loc
			M.hokuto_obj=src

	verb/Hotbar_use()
		set hidden=1
		Hundred_Crack_Fist()

	verb/Hundred_Crack_Fist()
		//set category="Skills"
		if(usr.beaming||usr.charging_beam)
			usr<<"You can not use this and beam at the same time"
			return
		if(usr.tournament_override(fighters_can=0)) return

		if(usr.KO||Attacking||usr.attacking) return
		if(usr.beaming||usr.charging_beam)
			usr<<"You can not use this and beam at the same time"
			return
		var/list/Chosen_Targets=new

		for(var/mob/P in player_view(15,usr))
			if(P!=usr&&!P.Safezone&&(get_dir(usr,P) in list(usr.dir,turn(usr.dir,45),turn(usr.dir,-45))))
				Chosen_Targets+=P
				if(alignment_on&&both_good(usr,P)) Chosen_Targets-=P
				if(Same_league_cant_kill(usr,P)) Chosen_Targets-=P

		if(usr.KO) return
		if(usr.beaming||usr.charging_beam)
			usr<<"You can not use this and beam at the same time"
			return
		if(Attacking||usr.attacking) return
		if(!(locate(/mob) in Chosen_Targets))
			usr<<"No viable targets..."
			return
		player_view(10,usr)<<sound('Ai wo Torimodose 2.ogg',volume=30)
		Attacking=1
		player_view(10,usr)<<sound('ATATATA.ogg')
		player_view(10,usr)<<"A glowing aura of power appears around [usr], suddenly their shirt rips off!"
		spawn(12) if(usr)
			for(var/obj/items/Clothes/TankTop/K in usr.item_list) if(K.suffix) K.Click(usr)
			for(var/obj/items/Clothes/ShortSleeveShirt/K in usr.item_list) if(K.suffix) K.Click(usr)
		var/Aura='AuraTall.dmi'+rgb(255,255,255)
		var/image/I=image(icon=Aura,icon_state="top",pixel_y=32)
		var/image/F=image(icon=Aura,icon_state="bottom")
		usr.overlays.Add(I,F)
		sleep(62)
		usr.Say("HOOOO!!! ATATATATATATATATATATATATA!!!")
		var/Amount=0
		for(var/mob/P in Chosen_Targets) Amount+=5
		if(Amount<17) Amount=17
		BigCrater(pos = usr.loc, minRangeFromOtherCraters = 4)
		Dust(usr, end_size = 0.6, time = 7)
		Make_Shockwave(usr,sw_icon_size=256)
		while(Amount)
			Amount-=1
			if(Chosen_Targets)
				var/mob/M=pick(Chosen_Targets)
				if(M&&M.z==usr.z)
					usr.Warp_To(Get_Warp_Destination(M,usr),M)
					usr.dir=Get_step(usr,M)
					if(M&&!M.KO) usr.Melee()
					spawn if(usr && prob(20)) Make_Shockwave(usr,sw_icon_size=pick(64,128))
			sleep(3)
		for(var/mob/m in players) for(var/obj/Hokuto_Shinken_Energy/E in m)
			if(E.Creator==usr.key) if(m) m.Hokuto_Shinken_Effects(usr)
		usr.Say("Your already dead.")
		usr.overlays.Remove(I,F)
		usr.Ki/=5
		Attacking=0
		Skill_Increase(1,usr)

mob/proc/Hokuto_Shinken_Effects(mob/P)
	set waitfor=0
	for(var/obj/Hokuto_Shinken_Energy/E in src) if(E.Creator==P.key)
		var/hs_power=((E.Level/BP)**bp_exponent + (E.hs_str/End)**0.3) / 2 * 0.75
		if(hs_power<1)
			P.KO("hundred crack fist backfire",allow_anger=0)
			del(E)
		else spawn(rand(15,30)) if(src)
			if(hero==key)
				player_view(15,src)<<"[src] is able to resist the hundred crack fist!"
			else
				Body_Parts(10)
				player_view(15,src)<<"[src]'s body swells and is in immense pain, only a moment later they explode as the effect's of [P]'s \
				Hokuto Shinken style kills them instantly...(Killed by [P.key])"
				var/turf/T=loc
				Death(P)
				if(T) for(var/mob/S in T) if(!S.client) S.overlays+='Exploded Head.dmi'
			del(E)

mob/proc/Add_Hokuto_Shinken_Energy(mob/P) if(ismob(P)) if(!(locate(/obj/Hokuto_Shinken_Energy) in P))
	if(hokuto_obj&&hokuto_obj.Attacking)
		var/obj/Hokuto_Shinken_Energy/E=new
		E.Creator=key
		E.Level=BP
		E.hs_str=Str/sword_mult()
		E.hs_force=Pow
		P.contents+=E

obj/Hokuto_Shinken_Energy
	Givable=0
	Makeable=0
	var
		hs_str=1
		hs_force=1
	New() spawn(3000) if(src) del(src)
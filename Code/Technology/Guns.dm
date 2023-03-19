mob/Admin3/verb/DestroyTurretsOfThisPerson(obj/Turret/t in Turrets)
	if(!t) return
	var/maker = t.Builder
	for(var/obj/Turret/t2 in Turrets) if(t2.Builder == maker) del(t2)

proc/Turret_loop()
	set waitfor=0
	while(1)
		for(var/obj/Turret/t in Turrets)
			for(var/mob/m in player_view(t.Range,t))
				t.Turret_Target()
		sleep(15)

var/Gun_Power=1

var/list/Turrets=new

obj/Turret
	icon='Turret.dmi'
	desc="Turrets fire on anything in the area. To set up a turret, place it where you want it. Then click it while \
	next to it and it will ask you to set a password. After setting the password the turret will fire on anyone who \
	does not have a Key (keys are made in science) with a matching password, including you."
	Cost=400000
	density=1
	Knockable=0
	var/Turret_Power=400
	var/Range=12
	var/Turret_Refire=20
	var/Turret_Offense=10000
	var/Turret_Force=1000
	takes_gradual_damage=1
	Dead_Zone_Immune=1

	verb/Upgrade()
		set src in view(1)

		if(!Password)
			usr<<"The turret must have a password before you can upgrade it"
			return

		if(usr in view(1,src))
			var/Max_Upgrade=usr.Knowledge*1.5*usr.Intelligence()**0.25
			var/Percent=(Turret_Power/Max_Upgrade)*100
			var/Res_Cost=Item_cost(usr,src)/100
			if(Percent>=100)
				usr<<"This is 100% upgraded at this time and cannot go any further."
				return
			var/Amount=input("This is at [Percent]% maximum power. Each 1% upgrade cost [Commas(Res_Cost)]$. \
			The maximum is 100% ([Commas(Max_Upgrade)] BP). Input \
			the percentage of power you wish to bring this to. ([Percent]-100%)") as num
			if(Amount>100) Amount=100
			if(Amount<0.1)
				usr<<"Amount must be higher than 0.1%"
				return
			if(Amount<=Percent)
				usr<<"The weapon cannot be downgraded."
				return
			Res_Cost*=Amount-Percent
			if(usr.Res()<Res_Cost)
				usr<<"You do not have enough resources to do this."
				return
			usr.Alter_Res(-Res_Cost)
			Total_Cost+=Res_Cost
			Turret_Power=Max_Upgrade*(Amount/100)
			Health=Turret_Power*1.2
			if(Turret_Offense<Avg_Offense()) Turret_Offense=Avg_Offense()
			if(Turret_Force<Avg_Force()) Turret_Force=Avg_Force()
			player_view(15,usr)<<"[usr] upgraded [src] from [Percent]% to [Amount]% ([Commas(Turret_Power)] BP)"
			switch(input("Do you want all your turrets to be upgraded to this amount?") in list("All","All in sight","Just this"))
				if("All") for(var/obj/Turret/T) if(T.Password==Password&&T!=src)
					if(T.Turret_Power<Max_Upgrade*(Amount/100)) T.Turret_Power=Max_Upgrade*(Amount/100)
					if(T.Turret_Offense<Avg_Offense()) T.Turret_Offense=Avg_Offense()
					if(T.Turret_Force<Avg_Force()) T.Turret_Force=Avg_Force()
				if("All in sight") for(var/obj/Turret/T in view(10,src)) if(T.Password==Password&&T!=src)
					if(T.Turret_Power<Max_Upgrade*(Amount/100)) T.Turret_Power=Max_Upgrade*(Amount/100)
					if(T.Turret_Offense<Avg_Offense()) T.Turret_Offense=Avg_Offense()
					if(T.Turret_Force<Avg_Force()) T.Turret_Force=Avg_Force()

	New()
		spawn(5) if(src&&z)
			Turrets += src

			if(src&&z==7)
				for(var/obj/Fighter_Spot/f in Fighter_Spots) if(f.z==z&&getdist(f,src)<=40) del(src)

			if(src&&z) if(locate(/obj/Spawn) in range(40,src))
				for(var/mob/M in loc) M<<"Turrets can not be built this close to a spawn"
				del(src)

			spawn(20) if(src)
				for(var/obj/Turret/T in loc) if(T!=src)
					del(src)
					return
				if(!z&&!(src in tech_list)) del(src)

			for(var/obj/Turret/T in view(3,src)) if(T!=src)
				player_view(15,src)<<"Turrets can not be built closer than 3 tiles from each other"
				del(src)
				return

	Del()
		Turrets-=src
		. = ..()

	Click() if(usr in range(1,src))

		if(Password)
			usr<<"The password has already been set."
			return

		Password=input(usr,"Input a password to activate the turret. It will attack anyone who does not have a \
		door pass set to the exact same password")
		Bolted=1
		switch(input(usr,"Set same password for all unpassworded turrets created by the same person who created \
		this turret?") in list("Yes","No"))
			if("Yes")
				for(var/obj/Turret/T) if(!T.Password && T.Creator==Creator)
					T.Password=Password
					T.Bolted=1
					spawn if(T) T.Turret_Target()
		Turret_Target()

	/*proc/Turret_Target()
		set waitfor=0
		sleep(1)
		if(!Password) return
		var/list/targetable_mobs=new
		var/area/a = get_area()
		if(a) for(var/mob/m in a.mob_list)
			if(m.z && !m.KO && getdist(src,m) <= Range && viewable(m,src))
				targetable_mobs+=m
				for(var/obj/items/Door_Pass/d in m.item_list) if(d.Password==Password)
					targetable_mobs-=m
					Target=null
					return
				if(m.drone_module && m.drone_module.Password==Password) targetable_mobs-=m

				var/list/league_ids=m.League_turret_IDs()
				if(Password in league_ids)
					targetable_mobs-=m
					Target=null
					return

		if(!Target) Turret_Fire_Loop()
		Target=null
		if(targetable_mobs.len) Target=pick(targetable_mobs)*/

	//this new one is just changed to (hopefully) target players in pods too instead of ignore them
	proc/Turret_Target()
		set waitfor=0
		sleep(1)
		if(!Password) return
		var/list/targetable_mobs=new
		var/area/a = get_area()
		if(a) for(var/mob/m in a.mob_list)
			var/turf/baseLoc = m.base_loc()
			if(baseLoc && !m.KO && getdist(src,baseLoc) <= Range && viewable(baseLoc,src))
				var/mob/targ = m
				if(m.Ship) targ = m.Ship
				targetable_mobs += targ
				for(var/obj/items/Door_Pass/d in m.item_list) if(d.Password==Password)
					targetable_mobs -= targ
					Target=null
					return
				if(m.drone_module && m.drone_module.Password==Password) targetable_mobs -= targ

				var/list/league_ids=m.League_turret_IDs()
				if(Password in league_ids)
					targetable_mobs -= targ
					Target=null
					return

		if(!Target) Turret_Fire_Loop()
		Target=null
		if(targetable_mobs.len) Target=pick(targetable_mobs)

	proc/Turret_Fire_Loop()
		set waitfor=0
		sleep(1)
		while(src && Target)
			if(getdist(src,Target) <= Range) Turret_Fire(Target)
			else
				Target=null
				return
			sleep(Turret_Refire)

	var/tmp/Firing

	proc/DoTurretFireCooldown(Turret_Refire)
		set waitfor=0
		Firing=1
		sleep(Turret_Refire)
		Firing=0

	proc/Turret_Fire(mob/P)
		if(Firing) return

		if(prison_exit && z == prison_exit.z && getdist(src,prison_exit)<=50)
			player_view(15,src)<<"Turrets can not be used this close to the prison exit"
			del(src)
			return

		var/turf/t=locate(death_x,death_y,death_z)
		if(t&&t.z==z&&getdist(src,t)<=50)
			player_view(15,src)<<"Turrets can not be used this close to the death spawn"
			del(src)
			return

		DoTurretFireCooldown(Turret_Refire)
		dir=get_dir(src,P)
		if(world.cpu<90)
			flick("Shoot",src)
			var/obj/Blast/B = get_cached_blast()
			//B.Stun = 5
			B.Is_Ki=0
			B.density=0
			B.Owner=src
			B.Fatal = 1
			B.icon='Missile Small.dmi'
			B.BP=Turret_Power
			B.Force=Turret_Force*2
			B.percent_damage=5*Gun_Power
			B.Offense=4*Turret_Offense
			B.Shockwave=50
			B.dir=dir
			B.SafeTeleport(loc)
			B.Turret_Missile_Is_On_Target(P)
			if(P.loc==loc) step_away(P,src)
			step_towards(B,P)
			walk_towards(B,P)

obj/proc/Turret_Missile_Is_On_Target(mob/P)
	set waitfor=0
	while(src && P && z)
		if(loc==P.loc) Bump(P)
		else if(Get_step(src,dir)==P.loc) Bump(P)
		sleep(1)

obj/items/Gun_Manual
	icon='PDA.dmi'
	Cost=1000
	Stealable=1
	clonable = 0
	verb/Hotbar_use()
		set hidden=1
		View()
	var/notes={"<html><head><title>Notes</title><body><body bgcolor="#000000"><font size=2><font color="#CCCCCC">

Guns are very flexible weapons that can be customized and upgraded to suit your needs. Here are some of the attributes
that can be customized on a gun and their purpose:<p>

Damage: Self explanatory.<p>
Ammo: Self explanatory.<p>
Refire: How fast the weapon can fire. The delay between each shot.<p>
Velocity: How fast the projectile moves from the gun to its target.<p>
Precision: The higher this is, the harder it is for a target to deflect the shot.<p>
Knockback: How far the target is knocked away when hit.<p>
Explosion: The size of the explosion the projectile causes on impact.<p>
Spread: The higher the spread, the move the projectile could deviate from it's intended path, covering more area but
losing accuracy.<p>
Stun: The more stun your gun has, the longer the target will be unable to move when hit by the projectile. But each point
you add to Stun will lower overall damage regardless of points put into Damage.<p>
Reload: More points into reload will decrease the time it takes to reload the weapon.<p>
Range: A gun with no points in range does not go very far at all. Range can be important if you wish to build some sort
of sniper rifle that can shoot people from great distances.<p>

Damage type is also important. If you choose Ballistic Damage then your bullet is made of some sort of physical
material, for example metal, and it does damage based on your target's Durability. If you choose energy, it does damage
based on your target's Resistance. This can provide a tactical advantage if you know your target's weaknesses, for
instance a Yasai typically has higher durability than resistance, making energy weapons more effective against them.<p>

"}
	verb/View()
		set src in usr
		usr<<browse(notes,"window= ;size=700x600")



mob/var/tmp/last_gun_fire = 0

obj/items/Gun
	//CUSTOMIZEABLE
	var/bp_mod=1
	var/Force=1
	var/Offense=1
	var/Max_Ammo=1
	var/Delay=1
	var/Velocity=1
	var/Precision=1
	var/Reload_Speed=1
	var/Range=1
	var/Knockbacks=0
	var/Explodes=0
	var/Spread=0
	Off=100
	BP=2
	Stun=0
	Bullet=1
	//=============
	icon='GUNS.dmi'
	icon_state="Handgun"
	Cost=6000
	Tech=10
	Can_Drop_With_Suffix=1
	var/Deviation=16
	var/Ammo=0
	var/Bullet_Icon='Bullet.dmi'
	var/tmp/Firing
	Stealable=1
	var/Equipped
	proc/Update_Gun_Description()
		var/Ammo_Type="Ballistic Projectiles"
		if(!Bullet) Ammo_Type="Energy Projectiles"
		desc="[src]<br>"
		desc+="Damage: [Commas(BP*bp_mod*0.1)] BP<br>"
		desc+="Max Ammo: [Max_Ammo]<br>"
		desc+="Velocity: [1000/Velocity]<br>"
		desc+="Refire: [Delay*0.1] seconds<br>"
		desc+="Precision: [Precision]x<br>"
		desc+="Range: [Range-1] tiles<br>"
		desc+="Reload: [Reload_Speed]x<br>"
		desc+="Knockback: [Knockbacks]x<br>"
		desc+="Explosion: [Explodes]x<br>"
		desc+="Stun: [Stun]x<br>"
		desc+="Spread: [Spread]<br>"
		desc+="[Ammo_Type]<br>"
	New()
		suffix="[Commas(Ammo)]"
		Update_Gun_Description()
		. = ..()
	Click()
		if(Equipped)
			Equipped=0
			usr.overlays-=icon
		else
			Equipped=1
			usr.overlays+=icon
	verb/Customize()
		set src in view(1)
		if(usr in view(1,src))
			if(usr.Res()<Cost/usr.Intelligence())
				usr<<"You need [Commas(Cost/usr.Intelligence())]$ to customize this again"
				return
			while(src&&usr&&usr.client)
				switch(input("Customize what?") in list("Cancel","Gun Icon","Gun Stats","Bullet Icon"))
					if("Cancel") return
					if("Gun Icon") usr.Grid(Gun_Icons,src)
					if("Gun Stats")
						if(winget(usr,"gunstats","is-visible")=="true") return
						usr.Customize_Gun_Stats(src)
						Calibrate_Gun_Stats()
					if("Bullet Icon") usr.Grid(Bullet_Icons,src)
			usr.Alter_Res(-(Cost/usr.Intelligence()))
	proc/Calibrate_Gun_Stats()
		if(Knockbacks) bp_mod*=sqrt(sqrt(Knockbacks+1))
		if(Stun) bp_mod/=(Stun+1)**0.6
		if(Bullet) Precision*=2
		Max_Ammo=round((Max_Ammo**4)*3)
		Delay=(10/Delay)**1.3
		bp_mod*=Delay**0.2
		Velocity=(10/Velocity)**0.65
		/*
		20/1 = 20
		20/10 = 2

		20**0.3 = 2.45
		2**0.3 = 1.23
		*/
		Range=(Range**2)+1
		if(Ammo>Max_Ammo) Ammo=Max_Ammo
		suffix="[Commas(Ammo)]"
		Update_Gun_Description()
	verb/Upgrade()
		set src in view(1)
		if(usr in view(1,src))
			var/Max_Upgrade=usr.Knowledge*1.5*sqrt(usr.Intelligence())
			var/Percent=(BP/Max_Upgrade)*100
			var/Res_Cost=Item_cost(usr,src)/100
			if(Percent>=100)
				usr<<"This is 100% upgraded at this time and cannot go any further."
				return
			var/Amount=input("This is upgraded to [Commas(BP)] BP. The current maximum is \
			[Commas(Max_Upgrade)] BP. \
			It is at [Percent]% maximum power. Each 1% upgrade cost [Commas(Res_Cost)]$. The maximum is 100%. Input \
			the percentage of power you wish to bring this to. ([Percent]-100%)") as num
			if(Amount>100) Amount=100
			if(Amount<0.1)
				usr<<"Amount must be higher than 0.1%"
				return
			if(Amount<=Percent)
				usr<<"The weapon cannot be downgraded."
				return
			Res_Cost*=Amount-Percent
			if(usr.Res()<Res_Cost)
				usr<<"You do not have enough resources to do this."
				return
			usr.Alter_Res(-Res_Cost)
			Total_Cost+=Res_Cost
			BP=Max_Upgrade*(Amount/100)
			if(Offense<Avg_Offense()) Offense=Avg_Offense()
			if(Force<Avg_Force()) Force=Avg_Force()
			player_view(15,usr)<<"[usr] upgraded [src] from [Percent]% to [Amount]% ([Commas(BP)] BP)"
			Update_Gun_Description()

	verb/Shoot()
		//set category="Skills"
		Gun_Fire(usr)

	proc/Gun_Fire(mob/P)
		if(ismob(P)&&Ammo<=0) for(var/obj/items/Ammo/A in P.item_list)
			A.Reload(P,src)
			break
		if(usr.tournament_override(fighters_can=0)&&skill_tournament)
			usr<<"Guns can not be used in skill tournaments"
			return
		if(ismob(P)&&P.cant_blast()) return
		if(Firing) return
		if(Ammo<=0) return

		if(P && ismob(P))
			if(world.time - P.last_gun_fire < TickMult(Delay))
				return

		Ammo-=1
		if(Spread) Ammo-=2
		if(Ammo<=0) Ammo=0
		suffix="[Commas(Ammo)]"
		Firing=1
		if(ismob(P))
			P.attacking=3
			P.last_gun_fire = world.time
		spawn(TickMult(Delay)) if(P)
			if(ismob(P)) P.attacking=0
			if(src) Firing=0
		if(Bullet) player_view(10,P)<<sound('reflect.ogg',volume=10)
		else player_view(10,P)<<sound('Blast.wav',volume=20)
		var/N=1
		if(Spread) N=3
		while(N)
			N--
			var/obj/Blast/A=get_cached_blast()
			A.Is_Ki=0
			A.Bullet=Bullet
			A.Owner=P
			A.Fatal=usr.Fatal
			if(Spread) Deviation=16
			else Deviation=4
			A.pixel_x=rand(-Deviation,Deviation)
			A.pixel_y=rand(-Deviation,Deviation)
			A.icon=Bullet_Icon
			var/BP_Formula=BP
			var/Offense_Formula=2*Offense*Precision
			A.BP=BP_Formula
			A.Force=Force
			A.percent_damage=1*bp_mod*Gun_Power
			A.wall_breaking_power=0
			A.Distance=Range
			A.Offense=Offense_Formula
			A.Shockwave=Knockbacks
			A.Explosive=Explodes
			A.Stun=Stun
			A.dir=P.dir
			A.SafeTeleport(P.loc)
			step(A,A.dir)
			spawn(TickMult(Velocity)) if(A&&A.z)
				var/Dir=A.dir
				if(Spread)
					switch(N)
						if(2) A.dir=turn(A.dir,45)
						if(1) A.dir=turn(A.dir,-45)
				step(A,A.dir)
				spawn(TickMult(Velocity))
					A.dir=Dir
					while(A&&A.z&&!A.deflected)
						step(A,A.dir)
						sleep(TickMult(Velocity))
obj/items/Ammo
	Cost=3000
	clonable = 0
	desc="Click this to reload whichever gun you want."
	icon='Gun Accessories.dmi'
	icon_state="Ammo Box"
	Stealable=1
	var/Ammo=10
	var/tmp/Reloading
	Can_Drop_With_Suffix=1
	New()
		suffix="[Commas(Ammo)]"
		. = ..()
	verb/Upgrade()
		set src in view(1)
		var/Cost=5/usr.Intelligence()
		var/Max=round(usr.Res()/Cost)
		var/Amount=input("How much ammo do you wish to add to this ammo pack? It will cost you [Cost]$ per \
		bullet. You can add up to [Max] bullets for the money you have.") as num
		Amount=round(Amount)
		if(Amount<=0) return
		if(Amount>Max) return
		Ammo+=Amount
		suffix="[Commas(Ammo)]"
		player_view(15,usr)<<"[usr] upgrades [src] with +[Amount] ammo"
		Amount*=Cost
		usr<<"Cost: [Commas(Amount)]$"
		usr.Alter_Res(-Amount)
		Total_Cost+=Amount
	Click() Reload(usr)
	verb/Hotbar_use()
		set hidden=1
		Reload(usr)
	proc/Reload(mob/M,obj/items/Gun/G)
		for(var/obj/items/Ammo/A in M) if(A.Reloading)
			//M<<"You are busy reloading already."
			return
		if(ismob(M)&&M.client&&!G)
			var/list/Guns
			for(var/obj/items/Gun/A in M.item_list) if(A.Ammo<A.Max_Ammo)
				if(!Guns) Guns=new/list
				Guns+=A
			if(!Guns) return
			G=input(M,"Which gun to reload?") in Guns
		if(G)
			player_view(15,M)<<"[M] is reloading their [G]"
			var/Reload_Delay
			if(ismob(M)) Reload_Delay=TickMult((100*sqrt(usr.Speed_delay_mult(severity=0.6)))/G.Reload_Speed)
			else Reload_Delay=TickMult(300/G.Reload_Speed/sqrt(M.Spd))
			Reloading=1
			spawn(Reload_Delay) if(src) Reloading=0
			spawn(Reload_Delay) if(src&&G&&M)
				player_view(15,M)<<"[M] is done reloading their [G]"
				var/Needed_Amount=G.Max_Ammo-G.Ammo
				if(Needed_Amount>Ammo) Needed_Amount=Ammo
				G.Ammo+=Needed_Amount
				Ammo-=Needed_Amount
				G.suffix="[Commas(G.Ammo)]"
				suffix="[Commas(Ammo)]"
				if(Ammo<=0) del(src)
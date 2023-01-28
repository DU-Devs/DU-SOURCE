mob/proc/Wish_for_power(amount=0.5)

	var/relative_base_bp=base_bp/bp_mod

	if(relative_base_bp>=highest_relative_base_bp)
		base_bp*=1.03
		hbtc_bp*=1.03
	else
		var/gain=(highest_relative_base_bp-relative_base_bp) * amount
		if(gain>0)
			gain*=bp_mod
			base_bp+=gain
			hbtc_bp-=gain*0.5
			if(hbtc_bp<0) hbtc_bp=0

	var/new_relative_base_bp=base_bp/bp_mod
	Bug_Log("[Bug_Keys()] wished for power. [src]'s BP: [Commas(relative_base_bp)]. Highest BP: [Commas(highest_relative_base_bp)]. \
	BP after wish: [Commas(new_relative_base_bp)]")

	wishes_for_power++
	Health=100
	Ki=max_ki

mob/Admin5/verb/Test_wish_for_power()
	set category="Admin"
	Wish_for_power()


var/db_vampire_incurable=0
mob/var/wishes_for_power=0

obj/Dragons
	Savable=0
	Givable=0
	Knockable=0

obj/Dragons/Shenron
	icon='shenron 320x222.dmi'
	layer=5
	pixel_x=-144
	pixel_y=0

obj/Dragons/Porunga
	icon='porunga 200x307.dmi'
	layer=5
	pixel_x=-84
	pixel_y=0

obj/Make_Dragon_Balls
	teachable=1
	Skill=1
	Teach_Timer=24
	hotbar_type="Ability"
	can_hotbar=1
	clonable=0
	desc="Scatter will allow you to automatically scatter any Dragon Balls in your inventory across \
	the planet you are on. Dragon Balls command will create any missing Dragon Balls from your set \
	and update all existing Dragon Balls to your current wishing power."
	verb/Hotbar_use()
		set hidden=1
		Make_Dragon_Balls()
	verb/Make_Dragon_Balls()
		set category="Skills"
		if(world.time<1200)
			usr<<"You can not make Dragon Balls until 2 minutes after the last reboot"
			return
		var/area/A=usr.get_area()
		if(!A||!isarea(A)||!isturf(usr.loc)||!A.can_has_dragonballs)
			usr<<"You can not create Dragon Balls here"
			return
		for(var/obj/items/Dragon_Ball/LS) if(LS.Creator!=usr.key&&A.type==LS.Home)
			usr<<"A set of Dragon Balls already exists for this planet, no more can be made."
			return
		//var/C=input("choose a color for your dragon balls") as color|null
		for(var/V in 1 to 7)
			var/obj/items/Dragon_Ball/L
			for(L) if(L.Creator==usr.key) if(L.name=="Dragon Ball [V]") break
			if(L) usr<<"[L] already exists, so you can not recreate it"
			else
				L=new/obj/items/Dragon_Ball(usr.loc)
				L.name="Dragon Ball [V]"
				L.Creator=usr.key
				usr<<"[L] has been created"
		for(var/obj/items/Dragon_Ball/LS) if(LS.Creator==usr.key && !LS.Home)
			LS.icon=initial(LS.icon)
			//if(C) LS.icon+=C
			LS.Home=A.type
			spawn if(LS&&LS.z) LS.Scatter()

proc/check_dragonballs() spawn(600) while(1)
	for(var/obj/items/Dragon_Ball/db in dragon_balls) if(db.Creator)
		var/list/matches=new
		for(var/obj/items/Dragon_Ball/db2 in dragon_balls) if(db2.Creator==db.Creator)
			for(var/v in 1 to 7)
				if(db2.name=="Dragon Ball [v]") matches+=v
		for(var/v in 1 to 7) if(!(v in matches))
			//world<<"<font color=cyan>BUG: Dragon Ball [v] created by [db.Creator] has gone missing. \
			//It has been automatically recreated."
			var/obj/items/Dragon_Ball/new_db=get_obj_copy(db)
			new_db.Move(db.loc)
			new_db.name="Dragon Ball [v]"
	sleep(600)

var/list/dragon_balls=new

obj/items/Dragon_Ball
	can_change_icon=0
	clonable=0
	can_blueprint=0
	icon='dragonball.dmi'
	desc="One of the seven Dragon Balls. When all seven are gathered you will be granted a wish"
	Health=1.#INF
	Stealable=1
	var/home_z=0
	var/WishPower=1000000 //full power by default now
	var/Home
	var/Wishes
	var/next_enable=0
	New()
		icon=initial(icon)
		dragon_balls+=src
		spawn(10) if(src) enable_dragonballs()
		spawn if(src) DB_Planet_Check()
		spawn(50) if(src&&Creator)
			for(var/obj/items/Dragon_Ball/DB in dragon_balls)
				if(DB!=src&&DB.Home==Home&&DB.Creator==Creator&&DB.name==name) del(src)
		..()
	proc/Alter_wishes(n=-1)
		for(var/obj/items/Dragon_Ball/db in dragon_balls) if(db.Creator==Creator)
			db.Wishes+=n
	proc/DBs_Gathered()
		var/n=0
		for(var/obj/items/Dragon_Ball/L in loc) if(L.Creator==Creator) n++
		if(n<7)
			usr<<"A wish can not be made because all 7 dragon balls are not gathered in this spot"
			return
		return 1
	proc/DB_Planet_Check()
		sleep(1800)
		while(src)
			var/mob/m=loc
			if(Home)
				if(!ismob(m) || !m.client)
					var/area/a=get_area()
					if(!a || a.type!=Home)
						player_view(15,src)<<"[src] returns to its home planet"
						Land()
			sleep(rand(1100,1300))
	proc/Land()
		var/area/A=locate(Home) in all_areas
		if(!home_z) for(var/turf/T in A) if(T.z!=2)
			home_z=T.z
			break
		var/turf/T
		while(!T||T.Water||T.Builder)
			T=locate(rand(1,world.maxx),rand(1,world.maxy),home_z)
			sleep(1)
		Move(T)
	proc/Scatter()
		if(name=="Dragon Ball 1") view(10,src)<<'bigbang_fire.ogg'
		for(var/obj/Dragons/D in range(15,src)) del(D)
		overlays+='Dragon Ball Aura.dmi'
		switch(name)
			if("Dragon Ball 1") dir=SOUTHWEST
			if("Dragon Ball 2") dir=WEST
			if("Dragon Ball 3") dir=NORTHWEST
			if("Dragon Ball 4") dir=NORTH
			if("Dragon Ball 5") dir=NORTHEAST
			if("Dragon Ball 6") dir=EAST
			if("Dragon Ball 7") dir=SOUTHEAST
		for(var/v in 1 to 600)
			var/old_loc=loc
			step(src,dir)
			if(loc==old_loc||(v>20&&prob(4))) dir=pick(NORTH,SOUTH,EAST,WEST,NORTHWEST,NORTHEAST,SOUTHEAST,SOUTHWEST)
			sleep(1)
		overlays-='Dragon Ball Aura.dmi'
		Land()
	proc/Inert(t=1)
		icon_state=null
		next_enable=world.realtime+t
	proc/enable_dragonballs() spawn while(src)
		if(world.realtime>next_enable && (!icon_state||icon_state==""))
			Wishes=1
			overlays-='Dragon Ball Aura.dmi'
			if(name=="Dragon Ball 1")
				icon_state="1"
				pixel_x=0
				pixel_y=0

				if(announce_dragon_balls)
					var/area/a=get_area()
					players<<"<font color=yellow><font size=3>The dragon balls of [a] are now active"

			if(name=="Dragon Ball 2")
				icon_state="2"
				pixel_x=-16
				pixel_y=0
			if(name=="Dragon Ball 3")
				icon_state="3"
				pixel_x=16
				pixel_y=0
			if(name=="Dragon Ball 4")
				icon_state="4"
				pixel_x=-8
				pixel_y=16
			if(name=="Dragon Ball 5")
				icon_state="5"
				pixel_x=8
				pixel_y=16
			if(name=="Dragon Ball 6")
				icon_state="6"
				pixel_x=-8
				pixel_y=-16
			if(name=="Dragon Ball 7")
				icon_state="7"
				pixel_x=8
				pixel_y=-16
		sleep(600)
	verb/Hotbar_use()
		set hidden=1
		Drop_All()
	verb/Drop_All()
		if(!usr.z||!Get_step(usr,usr.dir))
			usr<<"This is an invalid location for dropping the dragon balls"
			return
		usr.Drop_dragonballs()
	verb/Wish()
		set src in oview(1)
		if(!icon_state)
			usr<<"THE BALLS ARE INERT!"
			return
		if(!DBs_Gathered()) return
		if(!Home)
			usr<<"These Dragon Balls cannot be wished with until they have been scattered for the first \
			time by their creator."
			return
		var/obj/Dragons/D
		if(Home==/area/Namek) D=new/obj/Dragons/Porunga
		else D=new/obj/Dragons/Shenron
		D.loc=locate(x,y+1,z)
		var/list/Choices=new
		Choices+="Power For Someone"
		if(WishPower>300) Choices+="Immortality"
		if(WishPower>300) Choices+="Revive"
		if(WishPower>1500) Choices+="Restore Planet"
		if(WishPower>3000) Choices+="Restore Galaxy"
		Choices.Add("Money","Skill points","Knowledge","Time chamber key","Deadzone immunity",\
		"Learn soul contract","Learn Kaioken","Learn Genki Dama","Learn Majin","Learn Mystic",\
		"Learn Kai Teleport","Learn Materialize","Learn Regenerate","Learn Giant Form")
		if(db_vampire_incurable) Choices+="Make vampirism curable again"
		else Choices+="Make vampirism incurable"
		Choices+="Nothing"
		while(Wishes)
			player_view(15,src)<<"[usr] is making a wish!"
			switch(input("What is your wish?") in Choices)
				if("Nothing") if(Wishes)
					player_view(15,usr)<<"[usr] cancelled their wish"
					return
				if("Make vampirism incurable") if(Wishes)
					if(!DBs_Gathered()) return
					Alter_wishes()
					player_view(15,usr)<<"[usr] wished to make vampirism incurable"
					db_vampire_incurable=1
				if("Make vampirism curable again") if(Wishes)
					if(!DBs_Gathered()) return
					Alter_wishes()
					player_view(15,usr)<<"[usr] wished to make vampirism curable again"
					db_vampire_incurable=0
				if("Learn Kai Teleport") if(Wishes)
					if(!DBs_Gathered()) return
					Alter_wishes()
					player_view(15,usr)<<"[usr] wished for the Kai Teleport ability"
					usr.contents+=new/obj/Teleport
				if("Learn Majin") if(Wishes)
					if(!DBs_Gathered()) return
					Alter_wishes()
					player_view(15,usr)<<"[usr] wished for the Majin ability"
					usr.contents+=new/obj/Majin
				if("Learn Mystic") if(Wishes)
					if(!DBs_Gathered()) return
					Alter_wishes()
					player_view(15,usr)<<"[usr] wished for the Mystic ability"
					usr.contents+=new/obj/Mystic
				if("Learn Genki Dama") if(Wishes)
					if(!DBs_Gathered()) return
					Alter_wishes()
					player_view(15,usr)<<"[usr] wished for the Genki Dama ability"
					usr.contents+=new/obj/Attacks/Genki_Dama
				if("Learn Kaioken") if(Wishes)
					if(!DBs_Gathered()) return
					Alter_wishes()
					player_view(15,usr)<<"[usr] wished for the kaioken ability"
					usr.contents+=new/obj/Kaioken
				if("Learn Giant Form") if(Wishes)
					if(!DBs_Gathered()) return
					Alter_wishes()
					player_view(15,usr)<<"[usr] wished for the Giant Form ability"
					var/obj/Giant_Form/gf=new(usr)
					if(gf) gf.teachable=0
				if("Learn Regenerate") if(Wishes)
					if(!DBs_Gathered()) return
					Alter_wishes()
					player_view(15,usr)<<"[usr] wished for the regenerate ability"
					usr.contents+=new/obj/Regeneration
				if("Learn Materialize") if(Wishes)
					if(!DBs_Gathered()) return
					Alter_wishes()
					player_view(15,usr)<<"[usr] wished for the materialize ability"
					usr.contents+=new/obj/Materialization
				if("Learn soul contract") if(Wishes)
					if(!DBs_Gathered()) return
					Alter_wishes()
					player_view(15,usr)<<"[usr] wished for the soul contract ability"
					usr.contents+=new/obj/Demon_Contract
				if("Learn absorb") if(Wishes)
					if(!DBs_Gathered()) return
					Alter_wishes()
					player_view(15,usr)<<"[usr] wished for the absorb ability"
					usr.contents+=new/obj/Absorb
				if("Deadzone immunity") if(Wishes)
					if(!DBs_Gathered()) return
					Alter_wishes()
					player_view(15,usr)<<"[usr] wished for deadzone immunity"
					usr.Dead_Zone_Immune=1
				if("Time chamber key") if(Wishes)
					if(!DBs_Gathered()) return
					Alter_wishes()
					player_view(15,usr)<<"[usr] wished for a time chamber key"
					usr.give_hbtc_key()
				if("Restore Planet") if(Wishes)
					if(!DBs_Gathered()) return
					if(!destroyed_planets.len)
						player_view(15,usr)<<"There are no planets destroyed, please make another wish."
						return
					Alter_wishes()
					var/planet=input("Which planet?") in destroyed_planets
					spawn restore_planet(planet)
					player_view(15,usr)<<"[usr] wishes to restore planet [planet]!"
				if("Restore Galaxy") if(Wishes)
					if(!DBs_Gathered()) return
					spawn restore_all_planets()
					player_view(15,usr)<<"[usr] wishes for the Galaxy to be restored"
					Alter_wishes()
				if("Power For Someone") if(Wishes)
					if(!DBs_Gathered()) return
					Alter_wishes()
					var/mob/A=input(usr,"Choose the person you want to give power to") in players
					if(!DBs_Gathered()) return
					A.Wish_for_power()
					player_view(15,usr)<<"[usr] wishes to give [A] more power!"
				if("Money") if(Wishes)
					if(!DBs_Gathered()) return
					Alter_wishes()
					var/mob/a=input(usr,"Choose who to give the money to") in players
					if(!DBs_Gathered()) return
					a.Alter_Res(50000000 * Resource_Multiplier)
					player_view(15,usr)<<"[usr] wishes to give [a] money!"
				if("Skill points") if(Wishes)
					if(!DBs_Gathered()) return
					Alter_wishes()
					var/mob/a=input(usr,"Choose who to give skill points to") in players
					if(!DBs_Gathered()) return
					var/n=round(1*Year)
					if(n<30) n=30
					if(n>100) n=100
					a.Experience+=n
					player_view(15,usr)<<"[usr] wishes to give [a] skill points!"
				if("Knowledge") if(Wishes)
					if(!DBs_Gathered()) return
					Alter_wishes()
					var/mob/a=input(usr,"Choose who to give knowledge to") in players
					if(!DBs_Gathered()) return
					var/n=Tech_BP //=2000
					//for(var/mob/m in players) if(m.Knowledge>n) n=m.Knowledge
					if(n<a.Knowledge)
						alert(usr,"This wish can not be made because [a]'s knowledge is higher than the dragon \
						can grant")
						Alter_wishes(1)
					else
						a.Knowledge=n
						player_view(15,usr)<<"[usr] wishes to give [a] knowledge!"
				if("Immortality") if(Wishes)
					if(!DBs_Gathered()) return
					if(!usr.Immortal)
						usr.Toggle_immortality()
						player_view(15,usr)<<"[usr] wishes for immortality!"
					else
						usr.Toggle_immortality()
						player_view(15,usr)<<"[usr] wishes to be mortal!"
					Alter_wishes()
				if("Revive") if(Wishes)
					if(!DBs_Gathered()) return
					Alter_wishes()
					var/Revives=100
					while(Revives&&DBs_Gathered())
						var/list/Peoples=new
						for(var/mob/A in players) if(A.Dead) Peoples+=A
						Peoples+="I'm Done Reviving"
						var/mob/B=input("Choose who to revive.") in Peoples
						if(B=="I'm Done Reviving") break
						else
							B.Revive()
							B.loc=usr.loc
							Revives-=1
		End_Wishes()

obj/proc/End_Wishes()
	player_view(15,src)<<"The Dragon Balls scatter randomly across their home world"
	var/r=rand(80,120) * 1.8 * 0.01 * 60 * 60 * 10
	for(var/obj/items/Dragon_Ball/A in dragon_balls) if(A.Creator==Creator)
		spawn(rand(1,40)) Make_Shockwave(A,sw_icon_size=512)
		spawn A.Scatter()
		spawn A.Inert(r)

mob/proc/Toggle_immortality()
	if(Immortal)
		Immortal=0
		Regenerate-=1.3
		if(Regenerate<0) Regenerate=0
	else
		Immortal=1
		Regenerate+=1.3
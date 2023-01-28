mob/var/wishes_for_power=0
obj/Dragons
	Savable=0
	Givable=0
	Knockable=0
obj/Dragons/Shenron
	icon='Shenron.png'
	layer=5
	pixel_x=-319
	pixel_y=9
obj/Dragons/Porunga
	icon='Porunga.png'
	layer=5
	pixel_x=-293
	pixel_y=32
obj/Make_Lizard_Spheres
	teachable=1
	Skill=1
	Teach_Timer=30
	clonable=0
	desc="Scatter will allow you to automatically scatter any Lizard Spheres in your inventory across \
	the planet you are on. Lizard Spheres command will create any missing Lizard Spheres from your set \
	and update all existing Lizard Spheres to your current wishing power."
	verb/Make_Lizard_Spheres()
		set category="Skills"
		if(world.time<1200)
			usr<<"You can not make lizard spheres until 2 minutes after the last reboot"
			return
		var/area/A=locate(/area) in range(0,usr)
		if(!A||!isarea(A)||!isturf(usr.loc)||!A.can_has_dragonballs)
			usr<<"You can not create lizard spheres here"
			return
		for(var/obj/items/Lizard_Sphere/LS) if(LS.Creator!=usr.key&&A.type==LS.Home)
			usr<<"A set of lizard spheres already exists for this planet, no more can be made."
			return
		for(var/V in 1 to 7)
			var/obj/items/Lizard_Sphere/L
			for(L) if(L.Creator==usr.key) if(L.name=="Lizard Sphere [V]") break
			if(L) usr<<"[L] already exists, so you can not recreate it"
			else
				L=new/obj/items/Lizard_Sphere(usr.loc)
				L.name="Lizard Sphere [V]"
				L.Creator=usr.key
				usr<<"[L] has been created"
		var/C=rgb(rand(0,150),rand(0,150),rand(0,150))
		for(var/obj/items/Lizard_Sphere/LS) if(LS.Creator==usr.key)
			LS.icon=initial(LS.icon)+C
			LS.Home=A.type
			spawn if(LS&&LS.z) LS.Scatter()
obj/items/Lizard_Sphere
	clonable=0
	icon='Dragon Balls.dmi'
	desc="One of the seven Lizard Spheres. When all seven are gathered you will be granted a wish"
	Health=1.#INF
	Stealable=1
	var/WishPower=1000000 //full power by default now
	var/Home
	var/Wishes
	New()
		spawn(10) if(src) Active()
		spawn if(src) DB_Planet_Check()
		if(isnum(Home)) del(src) //temprary when home couldve been a num but now its not
		//..()
	proc/DBs_Gathered()
		var/n=0
		for(var/obj/items/Lizard_Sphere/L in loc) if(L.Creator==Creator) n++
		if(n<7)
			usr<<"A wish can not be made because all 7 spheres are not gathered in this spot"
			return
		return 1
	proc/DB_Planet_Check() while(src)
		if(Home&&z&&!(locate(Home) in range(0,src)))
			view(src)<<"[src] returns to its home planet"
			Land()
		sleep(rand(400,800))
	proc/Land()
		var/area/A=locate(Home)
		var/list/L=new
		for(var/turf/T in A) L+=T
		var/turf/T=pick(L)
		loc=T
	proc/Scatter()
		if(name=="Lizard Sphere 1") view(10,src)<<'bigbang_fire.ogg'
		for(var/obj/Dragons/D in range(15,src)) del(D)
		overlays+='Dragon Ball Aura.dmi'
		walk_rand(src)
		sleep(3000)
		walk(src,0)
		overlays-='Dragon Ball Aura.dmi'
		Land()
	proc/Inert()
		icon_state=null
		spawn(6*60*600) Active() //10 hours
	proc/Active()
		Wishes=2
		overlays-='Dragon Ball Aura.dmi'
		if(name=="Lizard Sphere 1")
			icon_state="1"
			pixel_x=0
			pixel_y=0
		if(name=="Lizard Sphere 2")
			icon_state="2"
			pixel_x=-16
			pixel_y=0
		if(name=="Lizard Sphere 3")
			icon_state="3"
			pixel_x=16
			pixel_y=0
		if(name=="Lizard Sphere 4")
			icon_state="4"
			pixel_x=-8
			pixel_y=16
		if(name=="Lizard Sphere 5")
			icon_state="5"
			pixel_x=8
			pixel_y=16
		if(name=="Lizard Sphere 6")
			icon_state="6"
			pixel_x=-8
			pixel_y=-16
		if(name=="Lizard Sphere 7")
			icon_state="7"
			pixel_x=8
			pixel_y=-16
	verb/Wish()
		set src in oview(1)
		if(!icon_state)
			usr<<"THE BALLS ARE INERT!"
			return
		if(!DBs_Gathered()) return
		if(!Home)
			usr<<"These Lizard Spheres cannot be wished with until they have been scattered for the first \
			time by their creator."
			return
		var/obj/Dragons/D
		if(Home==/area/Puran) D=new/obj/Dragons/Porunga
		else D=new/obj/Dragons/Shenron
		D.loc=locate(x,y+1,z)
		var/list/Choices=new
		Choices+="Power For Someone"
		if(WishPower>300) Choices+="Immortality"
		if(WishPower>300) Choices+="Revive"
		if(!Earth||!Puran||!Braal||!Arconia||!Ice)
			if(WishPower>1500) Choices+="Restore Planet"
			if(WishPower>3000) Choices+="Restore Galaxy"
		Choices+="Nothing"
		while(Wishes)
			view(src)<<"[usr] is making a wish!"
			switch(input("What is your wish?") in Choices)
				if("Nothing")
					view(usr)<<"[usr] cancelled their wish"
					return
				if("Restore Planet") if(Wishes)
					if(!DBs_Gathered()) return
					var/list/Planets=new
					if(!Earth) Planets+="Earth"
					if(!Puran) Planets+="Puran"
					if(!Braal) Planets+="Braal"
					if(!Arconia) Planets+="Arconia"
					if(!Ice) Planets+="Ice"
					if(!Planets)
						view(usr)<<"There are no planets destroyed, please make another wish."
						return
					Wishes-=1
					switch(input("Which planet?") in Planets)
						if("Earth")
							spawn Planet_Restore(1)
							view(usr)<<"[usr] wishes to restore Earth!"
						if("Puran")
							spawn Planet_Restore(3)
							view(usr)<<"[usr] wishes to restore Puran!"
						if("Braal")
							spawn Planet_Restore(4)
							view(usr)<<"[usr] wishes to restore Braal!"
						if("Arconia")
							spawn Planet_Restore(8)
							view(usr)<<"[usr] wishes to restore Arconia!"
						if("Ice")
							spawn Planet_Restore(12)
							view(usr)<<"[usr] wishes to restore Ice Planet!"
				if("Restore Galaxy") if(Wishes)
					if(!DBs_Gathered()) return
					spawn if(src)
						if(!Earth) Planet_Restore(1)
						if(!Puran) Planet_Restore(3)
						if(!Braal) Planet_Restore(4)
						if(!Arconia) Planet_Restore(8)
						if(!Ice) Planet_Restore(12)
					view(usr)<<"[usr] wishes for the Galaxy to be restored"
					Wishes-=1
				if("Power For Someone") if(Wishes)
					if(!DBs_Gathered()) return
					Wishes-=1
					var/mob/A=input(usr,"Choose the person you want to give power to") in Players
					if(!DBs_Gathered()) return
					//A.Attack_Gain((15*60)/((A.wishes_for_power+1)**2))
					A.wishes_for_power++
					var/mob/M=A
					for(var/mob/P in Players) if(P.Base_BP/P.BP_Mod>M.Base_BP/M.BP_Mod) M=P
					A.Leech(M,1000)
					A.Health=500
					A.Ki=A.Max_Ki*5
					view(usr)<<"[usr] wishes to give [A] more power!"
				if("Immortality") if(Wishes)
					if(!DBs_Gathered()) return
					if(!usr.Immortal)
						usr.Immortal=1
						usr.Regenerate+=0.5
						view(usr)<<"[usr] wishes for immortality!"
					else
						usr.Immortal=0
						usr.Regenerate-=0.5
						view(usr)<<"[usr] wishes to be mortal!"
					Wishes-=1
				if("Revive") if(Wishes)
					if(!DBs_Gathered()) return
					Wishes-=1
					var/Revives=100
					while(Revives&&DBs_Gathered())
						var/list/Peoples=new
						for(var/mob/A in Players) if(A.Dead) Peoples+=A
						Peoples+="I'm Done Reviving"
						var/mob/B=input("Choose who to revive.") in Peoples
						if(B=="I'm Done Reviving") break
						else
							B.Revive()
							B.loc=usr.loc
							Revives-=1
		End_Wishes()
obj/proc/End_Wishes()
	view(src)<<"The Lizard Spheres scatter randomly across their home world"
	for(var/obj/items/Lizard_Sphere/A) if(A.Creator==Creator)
		spawn(rand(1,40)) Make_Shockwave(A,7)
		spawn A.Scatter()
		spawn A.Inert()
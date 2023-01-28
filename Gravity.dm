mob/proc/Start_Gravity_Loops()
	Gravity_Update_Loop()
	Gravity_Mastery()
mob/var/tmp/Gravity=0
mob/var/Gravity_Mod=1
mob/proc/Gravity_Mastery() spawn while(src)
	if(Gravity<=Gravity_Mastered||Safezone) sleep(100)
	else if(!KO)
		var/N=(Gravity*((Gravity/Gravity_Mastered)**2)*Gravity_Mod)/5000
		if(z==10) N*=10
		if(Action=="Training") N*=1.5
		if(Opponent) N*=5
		if(N>Gravity/20) N=Gravity/20
		if(Ultra_Pack) N*=2
		Gravity_Mastered+=N
		//if(!KO) Attack_Gain((Gravity/Gravity_Mastered)**3) //originally **2
		Gravity_Damage()
		sleep(10)
	else
		src<<"You have been knocked out in gravity. Gravity will not affect you for 2 minutes after you regain \
		consciousness. This gives you a chance to escape. You will not master gravity during this time."
		while(KO) sleep(10)
		sleep(1200)
mob/proc/Gravity_Damage()
	var/Damage=(Gravity/Gravity_Mastered)**2
	Health-=Damage
	if(Health<=0) KO()
mob/proc/Gravity_Update_Loop() spawn while(src)
	Gravity_Update()
	if(client&&client.inactivity>600) sleep(60)
	else sleep(20)
mob/proc/Gravity_Update() for(var/turf/T in range(0,src))
	if(T.gravity) Gravity=T.gravity
	else Gravity=1
	if(Gravity<1) Gravity=1
	Planet_Gravity()
	break
mob/proc/Planet_Gravity()
	if(z==4&&Gravity<10) Gravity=10
	else if(z==10&&Gravity<5) Gravity=5 //HBTC
	else if(z==5&&y>422&&Gravity<10) Gravity=10
	else if(z==6&&Gravity<10) Gravity=10
	else if(z==12&&Gravity<20) Gravity=20
	else if(z==8&&Gravity<15) Gravity=15
	else if(z==14&&Gravity<15) Gravity=15
obj/items/Gravity
	Cost=100000000 //Grav Cost x Starting Grav
	var/Grav_Cost=20000000
	Del()
		Deactivate()
		..()
	layer=MOB_LAYER+5
	Stealable=1
	density=1
	desc="Place this anywhere on the ground to use it, it will affect anything within its radius."
	var/Max=5
	var/Range=10
	icon='Scan Machine.dmi'
	var/tmp/mob/upgrading
	verb/Upgrade()
		set src in view(1)
		if(usr in range(1,src))
			if(upgrading) return
			if(Health<usr.Knowledge*2) Health=usr.Knowledge*2
			if(!usr.Intelligence) return
			var/Max_Upgrade=round(max_gravity*usr.Intelligence)-Max
			if(Max_Upgrade<=0)
				usr<<"This machine cannot be upgraded any further"
				return
			Max_Upgrade*=Grav_Cost/usr.Intelligence
			for(var/obj/Resources/R in usr)
				upgrading=usr
				var/Upgrade=input(usr,"How much money do you want to put into this? Each \
				[Commas(Grav_Cost/usr.Intelligence)]$ is +1 gravity. This machine maxes out with \
				[Commas(Max_Upgrade)] more resources.") as num
				upgrading=null
				if(Max_Upgrade<=0)
					usr<<"This machine cannot be upgraded any further"
					return
				if(Upgrade>R.Value) Upgrade=R.Value
				if(Upgrade<=0) return
				if(Upgrade>Max_Upgrade) Upgrade=Max_Upgrade
				Max+=Upgrade/(Grav_Cost/usr.Intelligence)
				R.Value-=Upgrade
				Total_Cost+=Upgrade
				view(usr)<<"[usr] upgrades the [src] with [Commas(Upgrade)]$. The max gravity increases by \
				[Upgrade/(Grav_Cost/usr.Intelligence)]x. \
				The max gravity is now [Max]x"
				name="[round(Max,0.1)]x Gravity"
				return
	proc/Deactivate()
		var/image/I=image(icon='Gravity Field.dmi',layer=MOB_LAYER+5)
		for(var/turf/G in view(Range,src))
			G.overlays.Remove(I,'Gravity Field.dmi',I)
			G.gravity=0
	Click() if(usr in range(1,src))
		var/Grav=input("You can set the gravity multiplier by using this panel. Be aware that the level of gravity affects everyone in the room. Maxgrav is [Max]x") as num
		if(Grav>Max) Grav=Max
		if(Grav<0) Grav=0
		if(!Grav) view(src)<<"<center>[usr] sets the Gravity multiplier set to normal."
		else view(src)<<"<center>[usr] sets the Gravity multiplier set to [Grav]x"
		var/image/I=image(icon='Gravity Field.dmi',layer=MOB_LAYER+5)
		for(var/turf/G in view(Range,src))
			G.overlays.Remove(I,'Gravity Field.dmi',I)
			if(Grav>1) G.overlays+=I
			G.gravity=Grav
	verb/Bolt()
		set src in oview(1)
		usr.Bolt(src)
mob/proc/Bolt(obj/O)
	if(!O.Bolted)
		view(O)<<"[src] bolts [O] so nobody can move it"
		O.Bolted=key
	else if(O.Bolted==key)
		view(O)<<"[src] unbolts [O]"
		O.Bolted=null
turf/var/gravity=0
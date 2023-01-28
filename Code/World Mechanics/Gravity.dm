mob/proc/Start_Gravity_Loops()
	Gravity_Update_Loop()
	Gravity_Mastery()

mob/var/tmp/Gravity=0
mob/var/Gravity_Mod=1

var/gravity_mastery_mod = 1

mob/proc/Gravity_Mastery()
	set waitfor=0
	while(src)
		if(Gravity<=gravity_mastered||Safezone) sleep(40)
		else if(!KO)
			Gravity_Damage()
			var/gain = Gravity / 250
			var/mod = 1 - (gravity_mastered / Gravity)
			if(mod < 0) mod = 0
			if(mod > 0) mod = mod**2.5
			mod = Clamp(mod,0,0.2)
			if(Gravity <= 35 && mod < 0.05) mod = 0.05
			gain *= mod * Gravity_Mod**0.7
			if(Opponent(65)) gain*=5
			if(Total_HBTC_Time<2 && z==10) gain *= 10
			if(Action=="Training") gain*=1.5
			if(ultra_pack) gain*=2

			gain *= gravity_mastery_mod
			if(gain>gravity_mastered*0.1) gain=gravity_mastered*0.1
			gravity_mastered+=gain
			sleep(5)
		else
			while(KO) sleep(10)
			spawn(150)
				//if still KO'd in the grav, die
				if(KO)
					Death("too much gravity")
					Gravity_Update()
					FullHeal()
mob/proc/Gravity_Damage()
	//var/dmg=100
	//var/mod=1-(gravity_mastered/Gravity)
	//dmg*=mod/regen**0.5
	//Health-=dmg

	var/Damage=0.2 * (Gravity/gravity_mastered)**3
	Health-=Damage / Clamp(regen**0.4,0.8,999) / dur_share()**0.4

	if(Health<=0) KO()

mob/proc/Gravity_Update_Loop()
	set waitfor=0
	while(src)
		Gravity_Update()
		if(client&&client.inactivity>600) sleep(40)
		else sleep(15)
		if(!client) sleep(300) //slowed down on empty clones due to lag

mob/proc/Gravity_Update()
	set waitfor=0
	var/turf/t = loc
	if(!t || !isturf(t)) return

	if(t.gravity) Gravity=t.gravity
	else Gravity=1
	if(Gravity<1) Gravity=1
	Planet_Gravity()

mob/proc/Planet_Gravity()
	if(z==4&&Gravity<10) Gravity=10
	else if(z==10&&Gravity<5) Gravity=5 //HBTC
	else if(z==5&&y>422&&Gravity<10) Gravity=10
	else if(z==6&&Gravity<10) Gravity=10
	else if(z==12&&Gravity<20) Gravity=20
	else if(z==8&&Gravity<15) Gravity=15
	else if(z==14&&Gravity<15) Gravity=15
	else if(z==18&&Gravity<30) Gravity=30

obj/items/Gravity
	Cost=1000000 //Grav Cost x Starting Grav
	var/Grav_Cost=40000
	Del()
		Deactivate()
		. = ..()
	layer=MOB_LAYER+5
	Stealable=1
	clonable = 0
	density=1
	desc="Place this anywhere on the ground to use it, it will affect anything within its radius."
	var/Max=5
	var/Range=10
	icon='Scan Machine.dmi'
	takes_gradual_damage=1
	verb/Upgrade_health()
		set name="Repair/Upgrade health"
		set src in view(1)
		if(usr in view(1,src))
			var/max_health=usr.Knowledge*usr.Intelligence()*10
			if(Health<max_health)
				player_view(15,usr)<<"[usr] repairs/upgrades the [src]'s health to [Commas(max_health)] BP"
				Health=max_health
			else usr<<"The [src] is beyond your upgrading abilities"
	var/tmp/mob/upgrading
	verb/Hotbar_use()
		set hidden=1
		Upgrade()
	verb/Upgrade()
		set src in view(1)
		if(usr in range(1,src))
			if(upgrading) return
			if(!usr.Intelligence()) return
			var/cost_per_grav=Grav_Cost*(500/max_gravity)/usr.Intelligence()**0.25
			var/max_upgrade=round(max_gravity*usr.Intelligence()**0.21)-Max
			if(max_upgrade<=0)
				usr<<"This machine can not be upgraded any further"
				return
			upgrading=usr
			var/n=input(usr,"How much money do you want to put into this? Each [Commas(cost_per_grav)]$ is \
			+1 gravity. This machine maxes out with [Commas(max_upgrade*cost_per_grav)] more resources") as num
			upgrading=null
			if(max_upgrade<=0) return
			if(n>usr.Res()) n=usr.Res()
			if(n<=0) return
			if(n>max_upgrade*cost_per_grav) n=max_upgrade*cost_per_grav
			Max+=n/cost_per_grav
			usr.Alter_Res(-n)
			Total_Cost+=n
			player_view(15,usr)<<"[usr] upgrades the [src] with [Commas(n)]$. The max gravity increases by \
			[n/cost_per_grav]x. The max gravity is now [Max]x"
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
		if(!Grav) player_view(15,src)<<"<center>[usr] sets the Gravity multiplier set to normal."
		else player_view(15,src)<<"<center>[usr] sets the Gravity multiplier set to [Grav]x"
		var/image/I=image(icon='Gravity Field.dmi',layer=MOB_LAYER+5)
		for(var/turf/G in view(Range,src))
			G.overlays.Remove(I,'Gravity Field.dmi',I)
			if(Grav>1) G.overlays+=I
			G.gravity=Grav
			for(var/mob/m in G) m.Gravity_Update()
	verb/Bolt()
		set src in oview(1)
		usr.Bolt(src)

mob/proc/Bolt(obj/O)
	if(!O.Bolted)
		player_view(15,O)<<"[src] bolts [O] so nobody can move it"
		O.Bolted=key
	else if(O.Bolted==key)
		player_view(15,O)<<"[src] unbolts [O]"
		O.Bolted=null

turf/var/gravity=0
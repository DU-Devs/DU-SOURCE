mob/var/tmp/Gravity=0
mob/var/Gravity_Mod=1
mob/var/tmp/gravityKODeath = 0

mob/proc/TickGravity()
	UpdateGravity()

	if(Gravity > gravity_mastered)
		if(!KO)
			gravityKODeath--
			gravityKODeath = Math.Max(gravityKODeath, 0)
			GravityDamage()
			GravityMasteryTick()
		else
			gravityKODeath++
			if(gravityKODeath >= 30)
				if(prob(Math.Max(100 - determination * 5, 0)))
					gravityKODeath = 0
					Death("too much gravity")
					UpdateGravity()
					FullHeal()
				else IncreaseDetermination(-5)

mob/proc/GravityMasteryTick()
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

	gain *= Progression.GetSettingValue("Gravity Mastery Rate") * 0.1
	if(gain>gravity_mastered*0.1) gain=gravity_mastered*0.1
	gravity_mastered+=gain

mob/proc/UpdateGravity()
	var/turf/t = loc
	if(!t || !isturf(t)) return
	if(t.gravity) Gravity=t.gravity
	else Gravity=1
	Gravity = Math.Max(Gravity, 1)
	Gravity = Math.Max(Gravity, GetPlanetGravity())

mob/proc/GravityDamage()
	var/Damage=0.2 * (Gravity/gravity_mastered)**3
	TakeDamage((Damage / Clamp(regen**0.4,0.8,999) / dur_share()**0.4), "gravity")

mob/proc/Gravity_Update_Loop()
	set waitfor=0
	while(src)
		UpdateGravity()
		if(client&&client.inactivity>600) sleep(40)
		else sleep(15)
		if(!client) sleep(300) //slowed down on empty clones due to lag

mob/proc/Planet_Gravity()
	if(z==4&&Gravity<10) Gravity=10
	else if(z==10&&Gravity<5) Gravity=5 //HBTC
	else if(z==5&&y>422&&Gravity<10) Gravity=10
	else if(z==6&&Gravity<10) Gravity=10
	else if(z==12&&Gravity<20) Gravity=20
	else if(z==8&&Gravity<15) Gravity=15
	else if(z==14&&Gravity<15) Gravity=15
	else if(z==18&&Gravity<30) Gravity=30

mob/proc/GetPlanetGravity()
	switch(z)
		if(4) return 10
		if(5) if(y > 422) return 10
		if(6) return 10
		if(8) return 15
		if(14) return 15
		if(12) return 20
		if(18) return 30
	return 1

obj/items/Gravity
	Cost=1000000 //Grav Cost x Starting Grav
	var/Grav_Cost=40000
	Del()
		Deactivate()
		. = ..()
	Stealable=1
	clonable = 0
	density=1
	desc="Place this anywhere on the ground to use it, it will affect anything within its radius."
	var/Max=10
	var/Range=10
	icon='Scan Machine.dmi'
	takes_gradual_damage=1
	var/tmp/obj/vfx/GravityField

	proc/MakeGravityField()
		var/obj/vfx/I = new(src)
		I.name = "Gravity Field"
		I.icon = 'Gravity Field.dmi'
		I.layer = MOB_LAYER + 5
		I.mouse_opacity = 0
		return I

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
			var/cost_per_grav=Grav_Cost*(500/Limits.GetSettingValue("Maximum Gravity"))/usr.Intelligence()**0.25
			var/max_upgrade=round(Limits.GetSettingValue("Maximum Gravity")*usr.Intelligence()**0.21)-Max
			if(max_upgrade<=0)
				usr<<"This machine can not be upgraded any further"
				return
			upgrading=usr
			var/n=input(usr,"How much money do you want to put into this? Each [Commas(cost_per_grav)]$ is \
			+1 gravity. This machine maxes out with [Commas(max_upgrade*cost_per_grav)] more resources") as num|null
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
		for(var/turf/G in view(Range,src))
			G.vis_contents.Remove(GravityField)
			G.gravity=0

	Click() if(usr in range(1,src))
		var/Grav=input("You can set the gravity multiplier by using this panel. \
		Be aware that the level of gravity affects everyone in the room. Maxgrav is [Max]x") as num|null
		if(Grav>Max) Grav=Max
		if(Grav<0) Grav=0
		if(!Grav) player_view(15,src)<<"<center>[usr] sets the Gravity multiplier set to normal."
		else player_view(15,src)<<"<center>[usr] sets the Gravity multiplier set to [Grav]x"
		if(!GravityField) GravityField = MakeGravityField()
		for(var/turf/G in view(Range,src))
			G.vis_contents.Remove(GravityField)
			if(Grav>1 && !(GravityField in G.vis_contents))
				G.vis_contents+=GravityField
			G.gravity=Grav
			for(var/mob/m in G)
				m.UpdateGravity()

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
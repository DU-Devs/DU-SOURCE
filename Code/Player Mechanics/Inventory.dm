obj/var/can_radar = 1

var/list/brain_scramblers=new
obj/Brain_Scrambler
	can_change_icon=0
	Cost=25000000
	makes_toxic_waste=1
	New()
		brain_scramblers+=src
		if(!icon)
			icon='small dish.dmi'
			CenterIcon(src)
			pixel_y=0
	desc="This will generate an energy field across the entire planet that will interfere with people's \
	brain waves, making them unable to create technology, unless they wear something to block it"
	density=1
	Savable=1
	var/scrambler_on=1
	verb/Set()
		set name="Toggle on/off"
		set src in oview(1)
		scrambler_on=!scrambler_on
		if(scrambler_on) usr<<"The [src] is now on"
		else usr<<"The [src] is now off"
	verb/Bolt()
		set src in oview(1)
		usr.Bolt(src)
mob/proc/Brain_scrambled()
	var/turf/t=base_loc()
	if(!t) return
	if(locate(/obj/Injuries/Brain) in injury_list) return 1
	for(var/obj/items/Brain_Scrambler_Blocker/BSB in item_list) return
	for(var/obj/Brain_Scrambler/o in brain_scramblers) if(o.z&&o.scrambler_on)
		var/area/o_area=locate(/area) in range(0,o)
		if(get_area()==o_area) return 1
obj/items/Brain_Scrambler_Blocker
	icon='Scramble Protector.dmi'
	Cost=2000000
	Stealable=1
	clonable = 0
	desc="Having this on you will block brain scrambler waves from affecting you"


mob/proc/EMP_mine_loop()
	set waitfor=0
	while(src)
		for(var/obj/items/EMP_Mine/o in emp_mine_list) if(o.z==z&&getdist(o,src)<=4)
			spawn if(o) o.EMP_detonate()
		sleep(30)
		if(!client) sleep(100) //empty clones lag a lot if there is many of them with this looping

var/list/emp_mine_list=new
obj/items/EMP_Mine
	icon='Weapons.dmi'
	icon_state="EMP Mine"
	Cost=500000
	hotbar_type="Combat item"
	can_hotbar=1
	Stealable=1
	clonable = 0
	density=1
	desc="Throw this or leave it lying around and it will detonate if anyone gets near it and release an \
	electro magnetic pulse that will severely drain an android's energy"
	var/tmp/detonating
	New()
		emp_mine_list+=src
		detonating=1
		spawn(300) detonating=0
		. = ..()
	Del()
		emp_mine_list-=src
		. = ..()
	verb/Hotbar_use()
		set hidden=1
		Use()
	verb/Use()
		//set category="Skills"
		if(usr.attacking) return
		usr.attacking=1
		spawn(5) if(usr) usr.attacking=0
		Grabbable=0
		detonating=1
		SafeTeleport(Get_step(usr,usr.dir))
		dir=usr.dir
		for(var/v in 1 to 5)
			sleep(TickMult(1))
			if(src) step(src,dir)
		detonating=0
		EMP_detonate()
	proc/EMP_detonate()
		if(detonating||!z) return
		detonating=1
		for(var/mob/m in player_view(9,src))
			if(m.Is_Cybernetic())
				//m.Health/=2
				m.Ki=0
				if(m.Health<15) m.KO("electromagnetic pulse")
		for(var/v in 1 to 3)
			Make_Shockwave(src,5,'Electricgroundbeam2.dmi')
			sleep(5)
		del(src)




var/list/teleport_nullifiers=new

obj/Giant_Teleport_Nullifier
	can_change_icon=0
	Cost=25000000
	makes_toxic_waste=1
	New()
		teleport_nullifiers+=src
		if(!icon)
			icon='small dish.dmi'
			CenterIcon(src)
			pixel_y=0
	desc="This will generate an energy field across the entire planet that will prevent ANY form of \
	teleporting until it is destroyed or turned off"
	density=1
	Savable=1
	var/disable_teleports=1
	var/list/allowed_frequencies=new
	verb/Set_allowed_frequencies()
		set src in oview(1)
		if(!Password) Password=input("You must set a password to prevent others from accessing these menus") as text
		else
			var/pw=input("You must know the password to access this menu. Enter it now") as text
			if(pw!=Password)
				usr<<"Wrong password. Access denied."
				return
		switch(alert("Add or remove telewatch/telepad frequencies that will not be nullified?","Options","Add","Remove"))
			if("Add")
				var/t=input("What telewatch/telepad frequency is allowed?") as text
				if(!t||t=="") return
				allowed_frequencies-=t
				allowed_frequencies+=t
				usr<<"Telewatches and telepads using frequency '[t]' will be allowed to function"
			if("Remove")
				while(usr)
					var/list/L=list("Cancel")
					for(var/v in allowed_frequencies) L+=v
					var/t=input("Remove which frequency from the allowed frequencies?") in L
					if(!t||t=="Cancel") return
					allowed_frequencies-=t
					usr<<"Frequency '[t]' is no longer an allowed frequency"
					sleep(1)
	verb/Set()
		set name="Toggle on/off"
		set src in oview(1)
		disable_teleports=!disable_teleports
		if(disable_teleports) usr<<"The [src] is now on"
		else usr<<"The [src] is now off"
	verb/Bolt()
		set src in oview(1)
		usr.Bolt(src)

mob/proc/Teleport_nulled(frequency)
	var/turf/t=base_loc()
	if(!t) return

	var/list/league_nullies=Get_league_nully_IDs()

	for(var/obj/Giant_Teleport_Nullifier/o in teleport_nullifiers) if(o.z && o.disable_teleports)
		if(!(frequency in o.allowed_frequencies))
			var/allowed
			for(var/ID in league_nullies)
				if(ID in o.allowed_frequencies)
					allowed=1
					break
			if(!allowed)
				var/area/o_area=locate(/area) in range(0,o)
				if(get_area()==o_area) return 1

	for(var/obj/items/Teleport_Nullifier/o in teleport_nullifiers) if(o.disable_teleports)
		var/mob/m=o.loc
		if(m&&ismob(m)&&m!=src&&m.z&&m.z==o.z)
			if(getdist(src,m)<50) return 1

obj/items/Teleport_Nullifier
	New()
		teleport_nullifiers+=src
		. = ..()
	Cost=5000000
	makes_toxic_waste=1
	icon='Weapons.dmi'
	icon_state="Teleport Nullifier"
	desc="Simply having this on you will prevent anyone within a certain range from being able to use \
	form of teleportation. It is great for stopping runners from teleporting away."
	Stealable=1
	var/disable_teleports=1
	verb/Hotbar_use()
		set hidden=1
		Set()
	verb/Set()
		set name="Toggle on/off"
		set src in usr
		disable_teleports=!disable_teleports
		if(disable_teleports) usr<<"[src] is now on"
		else usr<<"[src] is now off"


var/list/wall_bots=new
obj/Wall_upgrader_bot
	can_change_icon=0
	Cost = 12000000
	makes_toxic_waste=0
	icon='Modules.dmi'
	icon_state="3"
	New()
		wall_bots+=src
	desc="This stationary robot will automatically upgrade walls every hour. It has 1x intelligence, and \
	uses 100% of the current knowledge cap upon upgrading. It will upgrade all of a person's walls across all \
	maps, as long a turf made by that player is next to the robot so that it can upgrade it. There is no point \
	having more than 1 of these for your walls, as all upgrader bots activate at the exact same time on a global \
	loop, so it will not increase how often your walls are upgraded"
	density=1
	Savable=1
	verb/Bolt()
		set src in oview(1)
		usr.Bolt(src)

proc/Wall_bot_loop()
	set waitfor=0
	while(1)
		var/mob/temp=new
		temp.Knowledge=Tech_BP * 1
		temp.Intelligence=1
		for(var/obj/Wall_upgrader_bot/b in wall_bots) if(b.z)
			player_view(15,b)<<"<font color=white>[b]: <font color=red>Walls upgraded. Beep boop."
			var/list/upgraded=new
			for(var/turf/t in range(1,b)) if(t.Builder&&!(t.Builder in upgraded))
				upgraded+=t.Builder
				t.Upgrade_All(temp,display_message=0,for_free=1)
		if(temp) del(temp)
		sleep(1*60*60*10)


var/list/resource_destroyers=new
obj/Resource_Destroyer
	can_change_icon=0
	Cost=25000000
	makes_toxic_waste=1
	icon='Drill Rig.dmi'
	New()
		resource_destroyers+=src
	desc="Somehow this device stops a planet from generating any resources. Just place it anywhere."
	density=1
	Savable=1
	var/destroy_resources=1
	verb/Set()
		set src in oview(1)
		set name="Activate/deactivate"
		destroy_resources=!destroy_resources
		if(destroy_resources) usr<<"The [src] is now activated"
		else usr<<"The [src] is now deactivated"
	verb/Bolt()
		set src in oview(1)
		usr.Bolt(src)

obj/var/can_scrap=1
obj/var/tmp/current_scrapper
obj/items/Scrapper
	Cost=10000
	icon='Drill Hand.dmi'
	desc="Use this on any technology in front of you to scrap it and recieve any resources that can be \
	salvaged. The better your speed, the faster you will scrap things."
	Stealable=1

	verb/Hotbar_use()
		set hidden=1
		Use()

	verb/Use()
		for(var/obj/o in Get_step(usr,usr.dir)) if(o.Builder && o.can_scrap) if(o.Cost || o.Total_Cost)
			if(o.cached || o.deleted) continue
			if(o.current_scrapper) return
			player_view(15,usr)<<"[usr] begins scrapping the [o]..."
			o.current_scrapper=src
			var/res = o.Scrap_value()
			if(res >= 300000 || istype(o,/obj/Turret))
				var/timer=ToOne(50*usr.Speed_delay_mult(severity=0.5))
				if(istype(o,/obj/Ships/Ship)) timer*=8
				for(var/v in 1 to timer)
					if(!o||getdist(o,usr)>1)
						usr<<"Scrapping cancelled"
						return
					sleep(1)
			if(!o) return
			if(o.current_scrapper!=src) return
			usr.Alter_Res(res)
			player_view(15,usr)<<"[usr] scraps the [o] and recieves [Commas(res)] resources"
			if(istype(o,/obj/Drill))
				var/obj/Drill/d = o
				d.drill_drop_res_on_delete = 0
			del(o)

obj/proc/Scrap_value()
	return (Cost+Total_Cost)*0.8







obj/Spawn_Redirector
	can_change_icon=0
	Cost=15000000
	icon='FactionBadge.dmi'
	desc="Use the 'Set spawn' command on this to set which spawn it will redirect to. Then place it on \
	an existing spawn. Anyone who spawns on it will then be instantly redirected to the spawn you chose. \
	This will not work if there is a teleport nullifier disrupting it"
	Savable=1
	var
		respawn_x
		respawn_y
		respawn_z
	verb/Upgrade_health()
		set name="Repair/Upgrade health"
		set src in view(1)
		if(usr in view(1,src))
			var/max_health=usr.Knowledge*4*usr.Intelligence()**0.5
			if(Health<max_health)
				player_view(15,usr)<<"[usr] repairs/upgrades the [src]'s health to [Commas(max_health)] BP"
				Health=max_health
			else usr<<"The [src] is beyond your upgrading abilities"
	verb/Set_spawn()
		set src in oview(1)
		var/list/spawns=list("Cancel")
		for(var/obj/Spawn/s in Spawn_List) if(s.z) spawns+="[s]: [s.desc]"
		var/obj/Spawn/s=input("Choose which spawn to redirect people to") in spawns
		if(!s||s=="Cancel") return
		for(var/obj/Spawn/s2 in Spawn_List) if(s2.z&&s=="[s2]: [s2.desc]")
			s=s2
			break
		usr<<"[src] will now redirect to the [s] spawn"
		respawn_x=s.x
		respawn_y=s.y
		respawn_z=s.z
	verb/Bolt()
		set src in oview(1)
		usr.Bolt(src)







mob/var/blood_bags=0
obj/items/Blood_bag
	icon='blood bag.dmi'
	icon_state="empty"
	Cost=30000
	Savable=0
	Stealable=1
	clonable = 0
	desc="Used to extract blood from someone. Then drink it. When a \
	vampire drinks this their hunger goes away, the downside is that it rises back up even faster than \
	before. Only biting a person will set it back to normal. You can use it to drink blood from vampires \
	but this is just like biting a vampire and will cause your hunger to raise back up even faster."
	var/blood_drinks=5
	verb/Hotbar_use()
		set hidden=1
		Use()
	verb/Use() if(src in usr)
		if(icon_state=="empty")
			var/mob/m=locate(/mob) in Get_step(usr,usr.dir)
			if(!m||!m.client) m=usr
			player_view(15,usr)<<"[usr] extracts blood from [m]"
			if(m.Vampire) Level=3
			else Level=1
			icon_state="full"
			blood_drinks=initial(blood_drinks)
		else
			player_view(15,usr)<<"[usr] drinks blood from a bag of blood"
			usr.Vampire_Infection=0
			usr.blood_bags+=Level
			blood_drinks--
			if(!blood_drinks)
				usr<<"The [src] has emptied"
				icon_state="empty"

obj/Orbital_Cannon
	desc="This orbital cannon will prevent people from leaving the planet it is assigned to by blowing \
	up ships/pods it spots on the surface. It is expensive and somewhat easily destroyed if someone \
	in space attacks it. Right click it for settings. Nanites within the orbital cannon will gradually \
	repair any damage taken to the cannon"
	icon='satellite.dmi'
	Cost=10000000
	makes_toxic_waste=1
	var/orbital_strike_power=1
	density=1
	var/monitor_planet
	var/tmp/obj/Planets/planet_obj
	takes_gradual_damage=1
	var/max_health=5000

	New()
		spawn if(src)
			get_planet_obj()
			orbital_cannon()
			Regenerate_damage()
		CenterIcon(src)

	proc/Regenerate_damage()
		set waitfor=0
		while(src)
			var/loop_delay=4
			if(Health<max_health)
				Health+=max_health/10*loop_delay
			sleep(10*loop_delay)

	proc/orbital_cannon()
		spawn while(src)
			if(planet_obj)
				SafeTeleport(planet_obj.loc)
				step(src,NORTH)
				step(src,NORTH)
			sleep(20)
		spawn while(src)
			if(planet_obj)
				var/area/planet_area
				var/turf/t
				if(!planet_obj.Planet_X) t=locate(250,250,planet_obj.Planet_Z)
				else t=locate(planet_obj.Planet_X,planet_obj.Planet_Y,planet_obj.Planet_Z)
				if(t)
					planet_area=locate(/area) in range(0,t)
					for(var/obj/Ships/s in ships) if(s.z)
						var/area/ship_area=locate(/area) in range(0,s)
						if(ship_area==planet_area)
							spawn if(s) orbital_strike(s,src)
			sleep(40)

	proc/orbital_strike(obj/target,obj/Orbital_Cannon/self)
		var/obj/o=new
		o.Health=self.orbital_strike_power*3
		o.icon='Blast - 0.dmi'
		o.SafeTeleport(target.base_loc())
		if(o.y+15<world.maxy) o.y+=15
		while(o&&target&&target.z)
			o.z=target.z
			var/old_loc=o.loc
			if(o.loc!=target.loc&&Get_step(o,get_dir(o,target.base_loc())))
				o.SafeTeleport(Get_step(o,get_dir(o,target.base_loc())))
				for(var/obj/Blast/b in Get_step(o,get_dir(o,target)))
					if(b.BP<self.orbital_strike_power*3) del(b)
					else del(o)
			if(o)
				if(target.base_loc()==o.loc)
					if(self.orbital_strike_power>target.Health)
						del(target)
					del(o)
				if(o&&o.loc==old_loc) del(o)
			sleep(1)

	proc/get_planet_obj()
		if(monitor_planet) for(var/obj/Planets/p in planets) if(p.z&&p.name==monitor_planet) planet_obj=p

	verb/Settings()
		set src in view(1)
		if(!(usr in view(1,src))) return
		if(Password)
			var/t=input("Enter password") as text
			if(t!=Password)
				alert("Access denied")
				return
		while(src&&usr)
			switch(input("What do you want to do with this [src]?") in list("Cancel","Increase BP",\
			"Change planet to monitor","Change password"))
				if("Cancel") return
				if("Increase BP")
					var/max_upgrade=usr.max_ship_upgrade()*2.5
					if(max_upgrade<orbital_strike_power) usr<<"This is beyond your ability to upgrade"
					else
						player_view(15,usr)<<"[usr] upgrades the [src]'s BP from [Commas(orbital_strike_power)] to [Commas(max_upgrade)]"
						orbital_strike_power=max_upgrade
					if(Health<max_upgrade*30)
						usr<<"[src] fully repaired"
						Health=max_upgrade*30
						max_health=Health
				if("Change planet to monitor")
					var/list/planets=new
					for(var/obj/Planets/p) if(p.z) planets+=p.name
					monitor_planet=input("Choose the planet this [src] will monitor") in planets
					get_planet_obj()
				if("Change password") Password=input(usr,"Enter new password","Options",Password) as text
			sleep(1)





obj/items/Call_bounty_drone
	Cost=150000
	icon='Cloak.dmi'
	clonable = 0
	icon_state="Controls"
	desc="Use this to call a bounty drone to you, it will then send any incapacitated prisoners nearby \
	to prison."
	Stealable=1
	var/next_call=0
	verb/Hotbar_use()
		set hidden=1
		Use()
	verb/Use()
		if(world.realtime<next_call)
			usr<<"You must wait a minute before you can use this again"
			return
		var/turf/t=Get_step(usr,usr.dir)
		if(!t||t.density)
			usr<<"Invalid signal location"
			return
		var/list/mobs=list("Cancel")
		for(var/mob/m in player_view(15,usr)) if(m.Has_Bounty() && m.KO) mobs += m
		if(mobs.len==1)
			usr<<"There are no knocked out wanted persons nearby to call a bounty drone on"
			return
		var/mob/m=input("Who is the drone here for?") in mobs
		if(!m||m=="Cancel") return
		next_call=world.realtime+600
		player_view(15,usr)<<"[usr] signals for a bounty drone"
		sleep(30)
		if(!m) return
		Deploy_Drone(m,null,t,usr)




var/list/ki_field_generators=new
obj/Ki_Field_Generator
	name="Ki Jammer"
	can_change_icon=0
	makes_toxic_waste=1
	Cost=50000000
	New()
		ki_field_generators+=src
		if(!icon)
			icon='dish.dmi'
			CenterIcon(src)
			pixel_y=0
	desc="This field generator will prevent anyone from using ki within a certain radius"
	density=1
	Savable=1
	verb/Bolt()
		set src in oview(1)
		usr.Bolt(src)




obj/var/clonable=1

obj/items/Radar
	icon='Misc2.dmi'
	icon_state="Radar"
	Cost=1000000
	Stealable=1
	desc="This radar can be set to detect any item. Click it to equip it and a tab will open showing those items."
	var/Detects
	Can_Drop_With_Suffix=1
	era_reset_immune=1
	New()
		spawn(10) if(ismob(loc)&&suffix)
			var/mob/M=loc
			M.radar_obj=src
		. = ..()
	verb/Hotbar_use()
		set hidden=1
		Set()
	Click() if(src in usr)
		if(!suffix)
			if(usr.radar_obj) usr.radar_obj.suffix=null
			suffix="Equipped"
			usr.radar_obj=src
		else
			suffix=null
			usr.radar_obj=null
	verb/Set()
		if(Detects)
			switch(alert("Are you sure you want to reset detection to another object type?","","No","Yes"))
				if("No") return
		for(var/obj/O in Get_step(usr,usr.dir))
			Detects=O.type

			//so setting a radar to detect pods will also detect ships
			if(istype(O,/obj/Ships))
				Detects=/obj/Ships

			usr<<"[src] set to detect [initial(O.name)] objects"
			return
		usr<<"No object found. Face an object you want the Radar to detect and hit Set. It will then detect all \
		objects of that type."

obj/items/Door_Hacker
	Can_Drop_With_Suffix=1
	Stealable=1
	icon='Lab.dmi'
	icon_state="GBA"
	makes_toxic_waste=1
	clonable = 0
	desc="This device has the ability to bypass walls and doors below it's level"
	Cost=60000000
	era_reset_immune=0

	verb/Hotbar_use()
		set hidden=1
		Upgrade()

	verb/Upgrade()
		set src in view(1)
		if(usr in view(1,src))
			var/Max_Upgrade = 0.98 * usr.max_turf_upgrade()
			var/Percent=(BP/Max_Upgrade)*100
			var/Res_Cost=Item_cost(usr,src)/500
			if(Percent>=100)
				usr<<"This is 100% upgraded at this time and cannot go any further."
				return
			var/Amount=input("[src] is at [Percent]% of its max upgrade. Each 1% upgrade cost [Commas(Res_Cost)]$. \
			([Percent]-100%)") as num
			if(Amount>100) Amount=100
			if(Amount<0.1)
				usr<<"Amount must be higher than 0.1%"
				return
			if(Amount<=Percent)
				usr<<"This cannot be downgraded."
				return
			Res_Cost*=Amount-Percent
			if(usr.Res()<Res_Cost)
				usr<<"You do not have enough resources to do this."
				return
			usr.Alter_Res(-Res_Cost)
			BP=Max_Upgrade*(Amount/100)
			player_view(15,usr)<<"[usr] upgraded [src] from [Percent]% to [Amount]%"
			desc="Level [Commas(BP)]"
			suffix=Commas(BP)

mob/proc/sword_mult()
	var/n=1
	if(equipped_sword) n=equipped_sword.Damage
	return n

obj/items/Devil_Mat
	Stealable=1
	clonable = 0
	desc="Meditating on this mat will actually DECREASE the stat you are focused on. This can be useful if \
	you are at the stat cap but you don't like how you trained your stats, so you want to lower yourself below \
	the stat cap and train a different stat. This will have no effect if you are focused on energy or balanced."
	icon='Hell turf.dmi'
	icon_state="h4"
	Cost=0 //3000
	takes_gradual_damage=1

	verb/Hotbar_use()
		set hidden=1
		Upgrade()

	verb/Upgrade()
		set name="Repair/Upgrade health"
		set src in view(1)
		if(usr in view(1,src))
			var/max_health=usr.Knowledge*usr.Intelligence()
			if(Health<max_health)
				player_view(15,usr)<<"[usr] repairs/upgrades the [src]'s health to [Commas(max_health)] BP"
				Health=max_health
			else usr<<"The [src] is beyond your upgrading abilities"

	verb/Bolt()
		set src in oview(1)
		usr.Bolt(src)

	New()
		overlays-=overlays
		var/image/I=image(icon='Electric_Yellow.dmi',layer=5)
		overlays-=I
		overlays+=I

		spawn(5) del(src) //DISABLED DEVIL MATS

		. = ..()

mob/proc/Devil_Mat(loop_delay=1)
	if(Stat_Focus=="Strength") Str*=0.95**loop_delay
	if(Stat_Focus=="Durability") End*=0.95**loop_delay
	if(Stat_Focus=="Force") Pow*=0.95**loop_delay
	if(Stat_Focus=="Resistance") Res*=0.95**loop_delay
	if(Stat_Focus=="Speed") Spd*=0.95**loop_delay
	if(Stat_Focus=="Offense") Off*=0.95**loop_delay
	if(Stat_Focus=="Defense") Def*=0.95**loop_delay

mob/proc/Choose_Player(T,alignment_req)
	var/list/L=list("Cancel")
	for(var/mob/P in players) if(P.client)
		if(!alignment_on||!alignment_req||P.alignment==alignment_req)
			L+=P
	var/mob/P=input(src,T) in L
	if(!P||P=="Cancel") return
	return P










var/list/Bounties = list("Cancel")

var/minimum_bounty=10000000
obj/Bounty_Picture

proc/Update_Bounties()
	for(var/V in Bounties) if(V!="Cancel")
		var/list/L=Bounties[V]
		var/Key=L["Key"]
		for(var/mob/P in players) if(P.key==Key)
			var/obj/Bounty_Picture/B = GetCachedObject(/obj/Bounty_Picture)
			B.icon=P.icon
			B.overlays=P.overlays
			L["Image"]=B
			L["Name"]=P.name
			if(P.Prisoner()) L["Dead"]=1
		if(!L["Expires"]||world.realtime>L["Expires"]) Bounties-=V
		else Bounties[V]=L

mob/proc/Has_Bounty()
	if(!key) return
	for(var/V in Bounties) if(V!="Cancel")
		var/list/L=Bounties[V]
		if(L["Key"] == key && !L["Dead"]) return 1

proc/Find_Bounty(V)
	var/list/L=Bounties[V]
	if(!V||V=="Cancel") return
	for(var/mob/M in players) if(M.key == L["Key"]) return M

proc/Online_Bounties()
	var/list/L=list("Cancel")
	for(var/V in Bounties) if(V!="Cancel")
		var/list/LL=Bounties[V]
		if(Find_Bounty(V) && !LL["Dead"]) L+=V
	return L

proc/Claimable_Bounties(mob/m)
	var/list/L=list("Cancel")
	for(var/V in Bounties) if(V!="Cancel")
		var/list/LL=Bounties[V]
		if(!m || (!("Claimant" in LL)) || !LL["Claimant"] || LL["Claimant"] == m.key)
			if(LL["Dead"])
				L+=V
	return L

mob/proc/Retract_Bounties()
	var/list/L=list("Cancel")
	for(var/V in Bounties) if(V!="Cancel")
		var/list/LL=Bounties[V]
		if(LL["Maker"]==key) L+=V
	return L

mob/proc/On_Built_Turf()
	var/turf/T=loc
	if(isturf(T)&&T.Builder) return 1

proc/Apply_Bounty(price=0,bounty_note,the_key,maker,expiry=120,bonus=0)
	Bounties["[Commas(price)]$. [bounty_note]"]=list("Bounty"=price,"Key"=the_key,"Maker"=maker,\
	"Note"=bounty_note,"Expires"=world.realtime+(expiry*60*60*10),"Prison Add"=bonus,"Claimant"=null)

	for(var/obj/Bounty_Computer/B in bounty_computers) player_view(10,B)<<"<font size=3><font color=red>[src]: A new bounty has been \
	uploaded to the network. It is worth [Commas(price)]$. Note: [bounty_note]"

proc/Auto_bounty_evil()
	set waitfor=0
	sleep(2*60*10)

	return

	while(1)
		if(alignment_on)
			var/list/evil_guys=new
			for(var/mob/m in players) if(m.alignment=="Evil") evil_guys+=m
			if(evil_guys.len)
				var/how_many=ToOne(evil_guys.len * 0.05 / 12)
				if(how_many) for(var/i in 1 to how_many)
					var/mob/evil_guy=pick(evil_guys)
					if(evil_guy&&evil_guy.key)
						Apply_Bounty(price=12000000*Resource_Multiplier,bounty_note="[evil_guy], for crimes against good",\
						the_key=evil_guy.key,maker="The prison")
		sleep(5*60*10)

var/list/bounty_computers=new
obj/Bounty_Computer
	pixel_y=-10
	icon='Lab2.dmi'
	icon_state="ControlTypeA"
	Cost=20000
	density=1
	desc="Using this, you can view, place, claim, and retract bounties on people. Viewing a bounty will show you \
	the latest known image of the person who's bounty you are viewing, and the payment for killing them. \
	If you created a bounty, only you can remove it from the system. If you kill a bounty you have to visit a \
	bounty computer to collect your payment. Be warned, anyone who knows the guy is now dead can collect the bounty \
	from the bounty computer, so you must be quick to collect your reward before someone else does. Just click the \
	computer to use it, you must be next to it."
	takes_gradual_damage=1
	New()
		bounty_computers+=src
	verb/Upgrade()
		set name="Repair/Upgrade health"
		set src in view(1)
		if(usr in view(1,src))
			var/max_health=usr.Knowledge*usr.Intelligence()
			if(Health<max_health)
				player_view(15,usr)<<"[usr] repairs/upgrades the [src]'s health to [Commas(max_health)] BP"
				Health=max_health
			else usr<<"The [src] is beyond your upgrading abilities"
	verb/Bolt()
		set src in oview(1)
		usr.Bolt(src)
	Click()
		if(usr.Prisoner())
			usr<<"Prisoners are not allowed to use the bounty network"
			return
		while(usr in view(1,src))
			switch(input("Using this you can view, place, and collect bounties") in list("Cancel","View Bounties",\
			"Place Bounty","Claim Bounty","Retract Bounty"))
				if("Cancel") return
				if("View Bounties")
					Update_Bounties()
					while(usr)
						var/bounty_found
						for(var/t in Bounties) if(t!=null) bounty_found=1
						if(!bounty_found)
							usr<<"There are no bounties, meaning no player has entered a bounty into the bounty network"
							return
						var/T=input("Choose a bounty to see the latest image of the person you want to hunt. \
						Only online bounties are shown") in Online_Bounties()
						if(T=="Cancel"||!T) return
						var/list/L=Bounties[T]
						var/obj/OO=L["Image"]
						var/obj/Bounty_Picture/O = GetCachedObject(/obj/Bounty_Picture)
						O.icon=OO.icon
						O.overlays=OO.overlays
						spawn while(O)
							O.dir=turn(O.dir,90)
							sleep(10)
						spawn(100) if(O) del(O)
						O.SafeTeleport(loc)
						O.x-=1
						for(var/obj/Bounty_Picture/BP in loc) if(BP!=O) del(BP)
						usr<<"[src]: To the left you will see the latest image of the suspect.<br>\
						Name: [L["Name"]]<br>\
						Reward: [Commas(L["Bounty"])]$<br>\
						Note: [L["Note"]]"
						var/mob/M=Find_Bounty(T)
						if(M)
							var/mob/Drone=M.Has_Bounty_Drone()
							if(Drone&&getdist(M,Drone)<10&&!M.On_Built_Turf())
								switch(alert("A prison observer drone is near this bounty and available to teleport you \
								there for hunting. Go now?","Options","No","Yes"))
									if("Yes") if(usr&&Drone) usr.SafeTeleport(Drone.loc)
				if("Place Bounty") while(usr)
					var/alignment_req
					if(alignment_on && usr.alignment=="Good") alignment_req="Evil"
					var/mob/P=usr.Choose_Player("Choose who you want to place a bounty on", alignment_req = alignment_req)
					if(!P) return
					if(alignment_on && P.alignment == "Good" && !allow_good_bounties)
						alert(usr, "Good people can not have bounties placed on them unless the host changes it")
						return
					var/Bounty=input("How much is the bounty you are putting on them? You have [Commas(usr.Res())]$") as num
					if(!P)
						usr<<"The person you wanted to place a bounty on has logged off, this process can not continue"
						return
					if(Bounty>usr.Res()) Bounty=usr.Res()
					if(Bounty<minimum_bounty)
						usr<<"The minimum bounty is [Commas(minimum_bounty)]$"
						return
					Bounty=round(Bounty)
					usr.Alter_Res(-Bounty)
					Bounty*=0.5
					var/prison_add=0
					if(Prison_Money)
						prison_add=Prison_Money
						if(prison_add>100000000) prison_add/=5
						Bounty+=prison_add
						Prison_Money-=prison_add
						usr<<"<font color=yellow>The prison has added [Commas(prison_add)]$ to your bounty amount \
						from its own funds. The prison acquired this money from its convicts upon arrest"

					var/Note=input("Leave a note about this bounty, this could be your alias so people know the bounty is \
					issued by you, or whatever else you want to put.") as text
					if(!P) return

					Apply_Bounty(price=Bounty,bounty_note=Note,the_key=P.key,maker=usr.key,bonus=prison_add)

					Update_Bounties()
				if("Claim Bounty")
					Update_Bounties()
					while(usr)
						var/T=input("Which bounty do you want to claim?") in Claimable_Bounties(usr)
						if(!T)
							usr<<"There were no bounties claimable by you"
							return
						if(T=="Cancel"||!(T in Bounties)) return
						var/list/L=Bounties[T]

						if(L&&L.len)
							var/mob/prisoner=Get_by_key(L["Key"])
							for(var/obj/bc in bounty_computers)
								if(prisoner) player_view(bc,15)<<"[usr] just claimed the bounty on [prisoner]"
								else player_view(bc,15)<<"[usr] just claimed the bounty on [L["Key"]]"

							usr<<"Congratulations you just collected [Commas(L["Bounty"])]$!"
							usr.Alter_Res(L["Bounty"])
							Bounties-=T
				if("Retract Bounty")
					while(usr)
						var/T=input("Choose which of your bounties you want to remove from the bounty network, \
						YOU WILL NOT GET MONEY BACK") in usr.Retract_Bounties()
						if(!T||T=="Cancel") return
						if(!(T in Bounties)) return //bad index error
						var/list/L=Bounties[T]
						for(var/obj/Bounty_Computer/B in bounty_computers) player_view(10,B)<<"A [Commas(L["Bounty"])]$ Bounty was just retracted \
						from the bounty network by its initiator."
						//usr.Alter_Res(L["Bounty"])
						if(L["Prison Add"])
							Prison_Money+=L["Prison Add"]
							//usr.Alter_Res(-L["Prison Add"])
						Bounties-=T
obj/items/Medical_Scan
	Stealable=1
	icon='Lab2.dmi'
	icon_state="WallDisplayA"
	desc="This displays information about your character's health. Just click it while next to it or have it on you \
	and click it."
	Cost=1000
	takes_gradual_damage=1
	verb/Upgrade_health()
		set name="Repair/Upgrade health"
		set src in view(1)
		if(usr in view(1,src))
			var/max_health=usr.Knowledge*usr.Intelligence()
			if(Health<max_health)
				player_view(15,usr)<<"[usr] repairs/upgrades the [src]'s health to [Commas(max_health)] BP"
				Health=max_health
			else usr<<"The [src] is beyond your upgrading abilities"
	verb/Hotbar_use()
		set hidden=1
		Click()
	Click() if(usr in view(1,src))
		var/t="[usr] uses the [src], it tells them:<br>\
		Physical Age: [round(usr.Age,0.1)]<br>\
		Decline Age: [round(usr.Decline,0.1)]<br>\
		Rate of power loss from decline: [round(usr.Decline_Rate,0.1)]x<br>\
		Lifespan: [round(usr.Lifespan(),0.1)]<br>\
		Your body is at [round(usr.Body*100,0.1)]% its original biological potential<br>\
		"
		if(usr.radiation_level)
			t+="<br>Radiation exposure: [usr.radiation_level]%"
		view(5)<<t
	verb/Bolt()
		set src in oview(1)
		usr.Bolt(src)

var/list/biogens = new

obj/Bio_Field_Generator
	icon='Lab.dmi'
	icon_state="Tower 1"
	density=1
	Savable=1
	layer=4
	Cost=50000000
	desc="Periodicly emits a pulse that heals nearby players and kills zombies"
	takes_gradual_damage=1

	verb/Upgrade()
		set name="Repair/Upgrade health"
		set src in view(1)
		if(usr in view(1,src))
			var/max_health=usr.Knowledge*usr.Intelligence()*2
			if(Health<max_health)
				player_view(15,usr)<<"[usr] repairs/upgrades the [src]'s health to [Commas(max_health)] BP"
				Health=max_health
			else usr<<"The [src] is beyond your upgrading abilities"

	New()
		biogens += src
		Bio_Field_Generator()
		var/image/A=image(icon='Lab.dmi',icon_state="Tower 2",pixel_y=32)
		var/image/B=image(icon='Lab.dmi',icon_state="Tower 3",pixel_y=64)
		overlays=null
		if(icon) overlays.Add(A,B)

	proc/Bio_Field_Generator()
		set waitfor=0
		sleep(rand(5,10))
		var
			max_killed_zombies = 1
		while(src)
			var/area/a = get_area()
			if(a)
				if(a.type == /area/Braal_Core)
					player_view(15,src) << "[src] explodes from the acid smog"
					Explosion_Graphics(src,4)
					del(src)
				else
					//this safety check stops people from ever crashing the server with too many biogens like before
					var/count = 0
					for(var/obj/o in biogens)
						if(o == src || getdist(src, o) > 20) continue
						count++
						if(count >= 10)
							del(src)
							return

					var/sw
					var/zombies_killed = 0
					for(var/mob/m in a.mob_list)
						if(m.client)
							if(m.z==z&&getdist(src,m)<=10)
								if(!sw)
									Make_Shockwave(src,sw_icon_size=512)
									sw=1
								if(m.KO) m.UnKO()
								if(m.Health<100) m.Health=100
								m.Zombie_Virus=0
								m.Diarea=0
								if(m.Zombie_Power) m.Death("bio field generator",Force_Death=1)
						else
							if(zombies_killed < max_killed_zombies && m.z==z && getdist(src,m) <= 15 && m.Zombie_Virus)
								zombies_killed++
								del(m)
			sleep(rand(90,110))

obj/Punch_Machine
	desc="This tells you how hard you punch. Just punch the correct side of it."
	Cost=1000
	density=1
	icon='Turf1.dmi'
	icon_state="Strength Machine"
	Health=5000
	takes_gradual_damage=1
	verb/Bolt()
		set src in oview(1)
		usr.Bolt(src)
	verb/Upgrade()
		set name="Repair/Upgrade health"
		set src in view(1)
		if(usr in view(1,src))
			var/max_health=usr.Knowledge*usr.Intelligence()*5
			if(Health<max_health)
				player_view(15,usr)<<"[usr] repairs/upgrades the [src]'s health to [Commas(max_health)] BP"
				Health=max_health
			else usr<<"The [src] is beyond your upgrading abilities"
obj/items/Pod_Race_Computer
	Cost=1000
	icon='Lab.dmi'
	icon_state="ATM"
	var/list/Racer_List=new
	var/Racers=0
	var/Max_Racers=8
	var/list/Bets=new
	proc/Count_Racers()
		Racers=0
		for(var/obj/O in Racer_List) Racers+=1
	verb/Set()
		set src in view(1,usr)
		var/list/Options=list("Cancel")
		if(Builder!=usr.key) Options+="Become Administrator"
		else
			Options+="Start Race"
			Options+="Set Max Racers"
			Options+="Bolt/Unbolt"
			Options+="Declare Winner"
		switch(input("Options") in Options)
			if("Cancel") return
			if("Declare Winner")
				usr<<"After someone wins a race you have to declare them as the winner, it cannot be detected \
				automatically. Once this is done all bets will automatically be given out to the appropriate betters."
				Options=list("Cancel")
				for(var/obj/OO in Racer_List) Options+=OO
				var/obj/OO=input("Choose the winner") in Options
				if(OO=="Cancel") return
				else
					player_view(15,src)<<"<font size=4><font color=yellow>[OO] has been declared winner of the race!"
					var/Losing_Bet_Total=0
					var/Winning_Bet_Total=0
					for(var/mob/M in Bets)
						var/list/Bet=Bets[M]
						var/obj/Racer
						for(var/obj/O in Bet)
							Racer=O
							if(Racer!=OO)
								var/Amount=0
								for(var/B in Bet) if(isnum(B)) Amount=B
								Losing_Bet_Total+=Amount
								M<<"You lost your bet on [Racer]. [OO] has won the race."
								Bets-=M
							else for(var/B in Bet) if(isnum(B)) Winning_Bet_Total+=B
					for(var/mob/M in Bets)
						var/Amount=0
						for(var/O in Bets[M]) if(isnum(O)) Amount=O
						var/Percentage=Winning_Bet_Total/Amount
						var/Winnings=round(Winning_Bet_Total*Percentage)
						usr.Alter_Res(Winnings)
						M<<"<font color=yellow>You won [Commas(Winnings)]$ from your bet on [OO]!"
						Bets-=M
				Racer_List=new/list
				Bets=new/list
			if("Bolt/Unbolt")
				Bolted=!Bolted
				if(Bolted) usr<<"The [src] is now bolted"
				else usr<<"The [src] is now unbolted"
			if("Become Administrator")
				switch(alert("Setting yourself as administrator of this computer gives you the ability to decide \
				when races start and things like that, it will cost you [Commas(1000000/usr.Intelligence())]$ to \
				set yourself as administrator. Accept cost?","Options","No","Yes"))
					if("No") return
					if("Yes")
						if(usr.Res()<10000/usr.Intelligence())
							usr<<"You do not have enough money"
							return
						usr.Alter_Res(-(10000/usr.Intelligence()))
						player_view(15,src)<<"[usr] has set themselves as administrator of [src]"
						Builder=usr.key
			if("Start Race")
				player_view(15,src)<<"<font size=4><font color=yellow>The race is starting in 10 seconds! GET READY! This is \
				the only warning!"
				sleep(100)
				player_view(15,src)<<"<font size=4><font color=red>THE RACE HAS STARTED! GO!"
				for(var/obj/O in Racer_List) O.Can_Move=1
			if("Set Max Racers")
				Max_Racers=input("Current max is [Max_Racers]") as num
				if(Max_Racers<2)
					usr<<"It cannot be less than 2"
					return
				Max_Racers=round(Max_Racers)
	verb/Hotbar_use()
		set hidden=1
		Click()
	Click() if((usr in view(1,src))||(usr.Ship in view(1,src)))
		Count_Racers()
		var/list/Options=list("Cancel")
		if(Racers<Max_Racers)
			if(usr.Ship in view(1,src))
				Options+="Register to Race"
				Options+="Withdraw from Race"
			else usr<<"To register for a race, you must be in your ship and next to this computer, then click \
			the computer"
		Options+="Place Bet"
		switch(input("Options") in Options)
			if("Cancel") return
			if("Place Bet")
				Options=list("Cancel")
				for(var/obj/O in Racer_List) Options+=O
				var/obj/O=input("Choose which racer to place a bet on") in Options
				if(O=="Cancel") return
				else
					var/Bet=input("Place your bet on [O]") as num
					if(Bet<=0)
						usr<<"Bet too low"
						return
					if(Bet>usr.Res())
						usr<<"You do not have that much money"
						return
					if(!O)
						usr<<"[O] no longer exists"
						return
					Bet=round(Bet)
					player_view(15,src)<<"<font color=yellow>[usr] has placed a bet of [Commas(Bet)]$ on [O]"
					Bets.Add(usr=list(Bet,O))
			if("Register to Race")
				Count_Racers()
				if(Racers>Max_Racers)
					usr<<"All racing spots are filled. The max is [Max_Racers]"
					return
				if(!usr.Ship) return
				if(usr.Ship.name==initial(usr.Ship.name))
					usr<<"You must name your ship to enter a race"
					return
				Racer_List+=usr.Ship
				player_view(15,src)<<"[usr]'s ship [usr.Ship] has successfully registered for the upcoming race."
				usr<<"Your pod has been frozen til the race starts, you will have to drag it to the start line"
				usr.Ship.Can_Move=0
			if("Withdraw from Race")
				if(usr.Ship in Racer_List)
					Racer_List-=usr.Ship
					player_view(40,src)<<"[usr]'s ship [usr.Ship] has withdrawn from the race."
				else usr<<"Your ship is not registered for this race so it cannot be withdrawn."
obj/items/Nav_System
	Cost=100000
	Stealable=1
	icon='Lab.dmi'
	icon_state="Labtop"
	desc="This upgradeable navigation system allows you to find planets in space. The only thing you need to do \
	is have it on you when in space and a navigation tab will open up. It will only show planets that it has \
	been upgraded to find. The more money you put into it the more planets will be unlocked. The rarest planets \
	will be unlocked last and at the greatest cost."
	var/Upgrade_Level=0
	var/Max_Upgrade=500000
	var/Autopilot
	var/tmp/obj/Destination
	var/tmp/step_tos=5
	var/max_step_tos=5
	verb/Hotbar_use()
		set hidden=1
		Autopilot()
	verb/Autopilot()
		if(!Autopilot) usr<<"[src] does not have autopilot"
		else
			if(!usr.Ship)
				usr<<"This only works in a space vehicle"
				return
			if(usr.Ship.z!=16)
				usr<<"You must be in space to use auto pilot"
				return
			var/list/L=list("Cancel")
			if(Destination) L+="Cancel Destination"
			for(var/obj/Planets/P) if(P.z==usr.Ship.z&&P.Nav_Level<=Upgrade_Level) L+=P
			var/obj/O=input("Choose an option") in L
			if(!O||O=="Cancel") return
			if(O=="Cancel Destination")
				Destination=null
				return
			Destination=O
			spawn while(src&&(Destination||step_tos<max_step_tos))
				step_tos++
				if(step_tos>max_step_tos) step_tos=max_step_tos
				sleep(30)
			var/step_normally=1
			while(usr&&usr.Ship&&O&&O.z==usr.Ship.z&&O==Destination)
				var/turf/t=usr.Ship.loc
				if(step_normally) step_towards(usr.Ship,O)
				if(t&&isturf(t)&&usr.Ship&&usr.Ship.loc==t)
					usr.Ship.g_step_to(Destination)
					step_tos--
					if(!step_tos||getdist(usr.Ship,Destination)<=1) step_normally=1
					else step_normally=0
				sleep(1)
			Destination=null
	verb/Upgrade()
		set src in view(1)
		if(!usr.Intelligence()) return
		if(Upgrade_Level>=Max_Upgrade)
			alert("This is upgraded to the maximum already")
			return
		var/cost_mod=1/usr.Intelligence()
		var/max_cost=(Max_Upgrade-Upgrade_Level)*cost_mod
		var/money=input("How many resources do you want to put in this? [Commas(max_cost)]$ more \
		unlocks all planets") as num
		if(money>usr.Res()) money=usr.Res()
		if(money<=0) return
		if(money>max_cost) money=max_cost
		Upgrade_Level+=money/cost_mod
		usr.Alter_Res(-money)
		player_view(15,usr)<<"[usr] puts [Commas(money)]$ into the [src]"
		if(!Autopilot&&Upgrade_Level>=Max_Upgrade*0.7)
			Autopilot=1
			player_view(15,usr)<<"The [src] now has autopilot"
obj/var/Creator
obj/items/Resource_Vaccuum
	icon='Item, Vaccuum.dmi'
	desc="Click this when it is in your items and it will suck up all resource bags lying around you."
	var/tmp/Vaccuuming
	Cost=3000
	Stealable=1
	verb/Hotbar_use()
		set hidden=1
		Click()
	Click() if(src in usr)
		if(Vaccuuming) return
		Vaccuuming=1
		spawn(100) Vaccuuming=0
		for(var/obj/Resources/R in view(15,usr))
			spawn while(R&&!(R in usr)&&R.loc)
				var/Old_Loc=R.loc
				step_towards(R,usr)
				if(R)
					if(R.loc==Old_Loc) break
					if(R in view(1,usr))
						usr.Alter_Res(R.Value)
						R.Value = 0
						del(R)
				sleep(2)

obj/var/Can_Drop_With_Suffix
obj/var/Bullet

obj/items/Door_Pass
	Cost=2000
	clonable = 0
	name="Key"
	icon='Door Pass.dmi'
	Stealable = 0
	drop_on_death = 0
	desc="Click this to set it's password. Door's will check if it is correct and only let you in if it is."
	verb/Hotbar_use()
		set hidden=1
		Click()
	Click()
		if(Password)
			usr<<"It has already been programmed and cannot be reprogrammed."
			return
		Password=input("Enter a password for the doors to check if it is correct") as text
mob/proc/Clone_Tank() if(client) for(var/obj/items/Cloning_Tank/T in cloning_tanks) if(T.z&&T.Password==key&&Dead)
	player_view(15,src)<<"[src] has been revived by their [T]"
	FullHeal()
	Revive()
	for(var/obj/Injuries/I in injury_list) del(I)
	SafeTeleport(T.loc)
	Decline*=0.99
	Original_Decline*=0.99
	available_potential=0.72
	return 1
var/list/cloning_tanks=new
obj/items/Cloning_Tank
	Cost=2000000
	density=1
	Bolted=0
	clonable = 0
	Stealable=1
	layer=3
	pixel_y=-12
	bound_width=64
	desc="This will revive you each time you are killed. Each time you are cloned however, \
	you lose 1% of your lifespan, and 28% of your power will become hidden potential."
	New()
		var/image/A=image(icon='Lab.dmi',icon_state="Tube2",layer=layer-0.1,pixel_y=0,pixel_x=0)
		var/image/B=image(icon='Lab.dmi',icon_state="Tube2Top",layer=layer+1,pixel_y=32,pixel_x=0)
		var/image/C=image(icon='Lab.dmi',icon_state="Lab2",layer=layer,pixel_y=12,pixel_x=28)
		overlays=null
		overlays.Add(A,B,C)
		cloning_tanks+=src
		. = ..()
	verb/Hotbar_use()
		set hidden=1
		Set()
	Click()
		usr<<"This machine is set to clone [Password]"
	verb/Set()
		set src in oview(1)
		if(usr.Dead)
			usr<<"Dead people cannot use this"
			return
		usr<<"[src] has been set to clone [usr] if they die."
		Password=usr.key
obj/items/Hacking_Console
	icon='Lab.dmi'
	icon_state="Labtop"
	Stealable=1
	desc="If this is upgraded past the upgrade level of a door, it can open the door for you."
	verb/Hotbar_use()
		set hidden=1
		Use()
	verb/Use()
		for(var/obj/Turfs/Door/A in Get_step(usr,usr.dir))
			if(A.Level<Level)
				player_view(15,usr)<<"[usr] uses the [src] to hack into the [A] and opens it!"
				A.Open()
			else player_view(15,usr)<<"[usr] tries to hack into the [A], but it is too advanced"
obj/items/Force_Field
	Cost=100000
	Level=1
	clonable = 0
	era_reset_immune=0
	Can_Drop_With_Suffix=1
	desc="Having this on you will protect you against energy attacks so long as its energy remains. \
	Each shot it deflects drains the battery. Having this on you will reduce the rate you leech power \
	from others because you are not using your own power to defend yourself, but the power of the \
	force field. If the force field reaches 0 it will cause an explosion strong enough to knock you out."
	icon='Lab.dmi'
	icon_state="Computer 1"
	Stealable=1
	proc/Force_Field_Desc()
		desc="[src]: Level [round(Level,0.01)]"
		suffix="[Commas(Level)] BP"
	verb/Hotbar_use()
		set hidden=1
		Upgrade()
	verb/Upgrade()
		set src in view(1)
		if(usr in view(1,src))
			var/Max_Upgrade=usr.Knowledge*1*usr.Intelligence()**0.2
			var/Percent=(Level/Max_Upgrade)*100
			var/Res_Cost=Item_cost(usr,src)/100
			if(usr.last_attacked_by_player+900>world.time)
				usr<<"You can not upgrade this right now because you are considered in combat from being \
				recently attacked."
				return
			if(Percent>=100)
				usr<<"This is 100% upgraded at this time and cannot go any further."
				return
			var/Amount=input("This [src] is at level [Level]. The current maximum is \
			[Max_Upgrade]. \
			It is at [Percent]% maximum power. Each 1% upgrade cost [Commas(Res_Cost)]$. The maximum is 100%. Input \
			the percentage of power you wish to bring the [src] to. ([Percent]-100%)") as num
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
			Level=Max_Upgrade*(Amount/100)
			player_view(15,usr)<<"[usr] upgraded [src] from [Percent]% to [Amount]% ([Commas(Level)] BP)"
			Force_Field_Desc()
mob/proc/Force_Field(Icon='Force Field.dmi',C=rgb(100,200,250,120),State="")
	set waitfor=0
	var/obj/O=new
	O.icon=Icon
	CenterIcon(O)
	if(Icon&&C) Icon+=C
	var/image/I=image(icon=Icon,icon_state=State,pixel_x=O.pixel_x,pixel_y=O.pixel_y)
	overlays-=I
	overlays+=I
	spawn(50) overlays-=I
obj/items/Detonator
	Cost=30000
	icon='Cell Phone.dmi'
	clonable = 0
	Stealable=1
	desc="This can be used to activate the detonation sequence on bombs or missiles from afar."
	verb/Set() Password=input("Set a password to activate bombs of matching passwords.") as text
	verb/Hotbar_use()
		set hidden=1
		Use()
	verb/Use()
		if(!Password) Set()
		switch(input("Confirm detonation command:") in list("Yes","No"))
			if("Yes")
				player_view(15,usr)<<"[usr] activates their remote detonator"
				var/list/Bombs=new
				for(var/obj/items/Nuke/A) if(A.loc) Bombs+=A
				for(var/obj/B in Bombs)
					var/obj/items/Nuke/A=B
					if(src&&A.Password==Password)//&&!A.Bolted)
						var/mob/m=A.loc
						if(ismob(m)) A.SafeTeleport(m.loc)
						player_view(15,usr)<<"[src]: Command code confirmed for [A]. Detonating..."// It will detonate in 10 seconds."
						//player_range(20,A)<<"<font color=red><font size=2>[A]: Detonation Code Confirmed. Nuclear Detonation in 30 Seconds."
						spawn if(A) A.Remote_Detonation()
obj/items/Cloak_Controls
	Cost=10000000
	icon='Cloak.dmi'
	clonable = 0
	icon_state="Controls"
	desc="You can use this to activate or deactivate all cloaked objects matching the same password \
	you have set for the controls. You can also use this to remove the cloaking chip from objects \
	next to you by using uninstall on it. You can upgrade this to have more cloaking capability so \
	that it is harder to detect. This is also a personal cloak, if you activate it, you will become \
	out of phase, and stay out of phase until you deactivate it. While out of phase you will also see \
	anything that is in the same phase or lower than yourself. The personal cloak is 5 levels less \
	powerful than the cloaking modules themselves."
	var/Active
	Level=2
	Stealable=1
	verb/Hotbar_use()
		set hidden=1
		Use()
	verb/Use()
		var/list/L=list("Cancel")
		if(Password)
			if(Active) L+="Uncloak all objects"
			else L+="Cloak all objects"
		L+="Set cloak frequency"
		L+="Uninstall cloak from object"
		switch(input("[src] options") in L)
			if("Cloak all objects")
				Active=1
				player_view(15,usr)<<"[usr] activates all their cloak chips"
				for(var/obj/O) for(var/obj/items/Cloak/C in O) if(C.Password==Password) O.invisibility=Level
			if("Uncloak all objects")
				Active=0
				player_view(15,usr)<<"[usr] deactivates all their cloak chips"
				for(var/obj/O) for(var/obj/items/Cloak/C in O) if(C.Password==Password) O.invisibility=0
			if("Set cloak frequency")
				Password=input("Set the frequency for the cloak controls, it will control all cloak chips sharing this \
				frequency") as text
			if("Uninstall cloak from object")
				for(var/obj/O in Get_step(usr,usr.dir)) for(var/obj/items/Cloak/C in O)
					player_view(15,usr)<<"[usr] removes the cloaking system from [O]"
					O.invisibility=0
					C.Move(usr)
atom/movable/var/Cloakable=1
obj/items/Cloak
	Cost=1000000
	icon='Cloak.dmi'
	desc="You can install this on any object to cloak it using cloak controls. First you must set the \
	password so that it matches the password of your cloak controls or it cannot be activated by those \
	controls."
	Stealable=1
	verb/Hotbar_use()
		set hidden=1
		Use()
	verb/Set() Password=input("Set the password for this cloak") as text
	verb/Use()
		if(!Password) Set()
		for(var/obj/A in Get_step(usr,usr.dir)) if(A.Cloakable)
			player_view(15,usr)<<"[usr] installs a cloaking system onto the [A]"
			Move(A)
obj/items/Communicator
	Cost=1000
	icon='Cell Phone.dmi'
	desc="Use this to call somebody who also has a cell phone. Just use Say or Whisper and you can \
	talk to them til the call has ended. You end a call by hitting Use again. Anyone within 1 space \
	of you can hear your conversation and also be heard on the cell phone"
	var/Frequency=1
	clonable = 0
	Stealable=1
	verb/Hotbar_use()
		set hidden=1
		Transmit()
	verb/Transmit(msg as text) for(var/mob/P in players)
		for(var/obj/items/Scouter/S in P.item_list)
			if(S.suffix&&((!P.Dead&&!usr.Dead)||(P.Dead&&usr.Dead))&&S.Frequency==Frequency)
				P<<"<font color=#FFFFFF>(Com)<font color=[usr.TextColor]>[usr]: [msg]"
		for(var/obj/items/Communicator/S in P.item_list)
			if(S.suffix&&((!P.Dead&&!usr.Dead)||(P.Dead&&usr.Dead))&&S.Frequency==Frequency)
				P<<"<font color=#FFFFFF>(Com)<font color=[usr.TextColor]>[usr]: [msg]"
	verb/Frequency() Frequency=input("Choose a frequency, it can be anything. It lets you talk to \
	others on the same frequency. Default is 1") as text
obj/items/Stun_Chip
	Cost=1000000
	icon='Control Chip.dmi'
	Stealable=1
	desc="You can install this on someone and use the Stun Remote to stun them temporarily. To use the \
	remote to stun them your remote must share the same remote access code as the installed chip. \
	You can also use this to remove chips from somebody using the Remove command, both chips will be \
	destroyed in the process."
	New()
		name=initial(name)
		. = ..()
	verb/Hotbar_use()
		set hidden=1
		Use()

	verb/Use(mob/A in view(1,usr))
		if(usr.tournament_override(fighters_can=0))
			usr<<"You can not stun chip people in a tournament"
			return

		if(A && (A == usr || A.KO || A.Frozen))
			player_view(15,usr)<<"[usr] installs a stun chip in [A]"
			var/obj/Stun_Chip/B=new
			B.Password=input("Input a remote access code to activate the chip") as text
			A.contents+=B
			del(src)

	verb/Remove(mob/A in view(1,usr))
		for(var/obj/Stun_Chip/B in A)
			player_view(15,usr)<<"[usr] removes a Stun Chip from [A]"
			del(B)
		del(src)
var/list/stun_chips=new
obj/Stun_Chip
	desc="You can install this on someone and use the Stun Remote to stun them temporarily. To use the \
	remote to stun them your remote must share the same remote access code as the installed chip. \
	You can also use this to remove chips from somebody using the Remove command, both chips will be \
	destroyed in the process."
	icon='Control Chip.dmi'
	New()
		stun_chips+=src
	Del()
		stun_chips-=src
		. = ..()
obj/items/Stun_Controls
	Cost=100000
	icon='Stun Controls.dmi'
	desc="You can use this to activate a stun chip you have installed on somebody. It only works \
	on people within range."
	Stealable=1
	var/tmp/cant_stun=0
	verb/Set() Password=input("Input a remote access code for activating nearby stun chips") as text
	verb/Upgrade()
		set src in view(1)
		if(usr in view(1,src))
			var/Max_Upgrade=usr.Knowledge*2*usr.Intelligence()**0.25
			var/Percent=(BP/Max_Upgrade)*100
			var/Res_Cost=Item_cost(usr,src)/500
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
			BP=Max_Upgrade*(Amount/100)
			player_view(15,usr)<<"[usr] upgraded [src] from [Percent]% to [Amount]% ([Commas(BP)] BP)"
	verb/Hotbar_use()
		set hidden=1
		Use()
	verb/Use()
		if(cant_stun) return
		cant_stun=5
		spawn while(src&&cant_stun)
			cant_stun--
			sleep(10)
		player_view(15,usr)<<"[usr] activates their stun controls"
		for(var/obj/Stun_Chip/chip in stun_chips) if(chip.Password==Password)
			var/mob/m=chip.loc
			if(m&&ismob(m)&&!m.KO&&usr.z==m.z&&getdist(usr,m)<20)
				var/dmg=100*(BP/m.BP)
				m.TakeDamage(dmg)
				if(m.Health<=0) m.KO("stun chip implant")
var/list/telepads=new
obj/items/Transporter_Pad
	Bolted=1 //bolted by default for convenience
	Cost=1500000
	name="Telepad"
	era_reset_immune=1
	icon='Transporter Pad.dmi'
	desc="You can use this to teleport yourself between other pads sharing the same remote access code"
	Stealable=1
	Level=1
	takes_gradual_damage=1
	New()
		telepads+=src
		. = ..()
	verb/Hotbar_use()
		set hidden=1
		Set()
	verb/Upgrade_health()
		set name="Repair/Upgrade health"
		set src in view(1)
		if(usr in view(1,src))
			var/max_health=5*usr.Knowledge*usr.Intelligence()
			if(Health<max_health)
				player_view(15,usr)<<"[usr] repairs/upgrades the [src]'s health to [Commas(max_health)] BP"
				Health=max_health
			else usr<<"The [src] is beyond your upgrading abilities"
	verb/Bolt()
		set src in oview(1)
		usr.Bolt(src)
	proc/Transport()

		return

		if(usr.Teleport_nulled(Password))
			usr<<"The telepad is not working because there is a teleport nullifier somewhere disrupting it"
			return
		var/list/A=new
		//for(var/obj/items/Transporter_Pad/B in telepads) if(B!=src&&!(locate(/area/Prison) in range(0,B)))
			//if(B.Password==Password&&B.z) A+=B
		A+="Cancel"
		var/obj/items/Transporter_Pad/C=input("Go to which telepad?") in A
		if(C=="Cancel") return
		if(!(src in usr.loc)) return
		usr.overlays+='SBombGivePower.dmi'
		sleep(30)
		if(usr)
			usr.overlays-='SBombGivePower.dmi'
			usr.overlays-='SBombGivePower.dmi'
			usr.ReleaseGrab()
			player_view(10,usr)<<sound('teleport.ogg',volume=25)
			if(C&&C.z) usr.SafeTeleport(C.loc)

	verb/Set()
		set src in view(1)
		if(!Password)
			Password=input("Set the indentification code, you can only transport to \
			other pads using the same code") as text
			name=input("Name the transporter pad, preferably name it after the location it will take you \
			to") as text
			if(!name) name=initial(name)
		else usr<<"It is already initialized"

obj/items/Transporter_Watch
	Cost=3000000
	name="Telewatch"
	icon='Transporter Watch.dmi'
	desc="You can use this to teleport yourself to any telepad that matches your watch's \
	remote access code. Or to any player who has a telewatch with a matching code."
	Level=2
	Stealable=1
	var/dna_verification

	verb/Reset_DNA_Verification()
		usr<<"DNA verification reset. The telewatch will now recognize the DNA of the next person who \
		uses it and use that for verification from now on."
		dna_verification=null
		Password=null

	proc/Transport()
		if(usr.Teleport_nulled(Password))
			usr<<"The telewatch will not work because there is a teleport nullifier somewhere disrupting it"
			return
		if(!dna_verification)
			usr<<"This telewatch has been set to your DNA and will explode if anyone else tries to use it."
			dna_verification=usr.Mob_ID
		if(dna_verification&&dna_verification!=usr.Mob_ID)
			player_view(15,usr)<<"[usr]'s telewatch: self destructing, dna verification mismatch"
			Explosion_Graphics(usr,1)
			del(src)
			return
		if(usr.BodySwapVictim())
			usr<<"You can not use this while body swapped"
			return
		if(usr.Final_Realm())
			usr<<"This will not work here"
			return
		if(usr.Prisoner())
			usr<<"The prison has put a lock on your teleport watch while you are a prisoner"
			return
		if(usr.Dead)
			usr<<"This type of teleportation does not work for dead people"
			return
		if(usr.KO)
			usr<<"You are knocked out and unable to teleport"
			return

		if(usr.ki_shield_on()) usr.Shield_Revert()
		if(usr.standing_powerup) usr.Stop_Powering_Up()

		var/list/l=list("cancel")
		for(var/mob/m in players) if(m!=usr) for(var/obj/items/Transporter_Watch/t in m.item_list)
			if(t.Password==Password) l+=m
		for(var/obj/items/Transporter_Pad/t in telepads) if(!t.is_on_destroyed_planet())
			if(t.Password==Password&&t.z&&!t.Final_Realm()) l+=t
			if(t.z == 10 && usr.z!=10) l-=t //hbtc
		var/mob/m
		if(l.len==2) m=l[2]
		else m=input("Select a teleport location. You can teleport to telepads or teleport to someone who \
			has a telewatch on them with a matching code") in l
		if(!m||m=="cancel") return
		if(m && ismob(m) && m.KO)
			usr << "You can not teleport to knocked out people"
			return
		if(usr.KO) return
		if(usr.Teleport_nulled(Password))
			usr<<"The telewatch will not work because there is a teleport nullifier somewhere disrupting it"
			return
		usr.overlays+='SBombGivePower.dmi'
		var/timer=40
		var/turf/old_loc=usr.loc
		var/teleport_failed
		while(timer)
			timer--
			if(!usr) return
			if(usr.loc!=old_loc)
				timer+=25 //take longer when they move
				if(timer>120) timer=120
			old_loc=usr.loc

			if(usr.ki_shield_on())
				usr << "Teleport signal lost due to shield"
				teleport_failed = 1
				break
			if(usr.standing_powerup)
				usr << "Teleport signal lost due to powering up"
				teleport_failed = 1
				break

			sleep(TickMult(1))
		usr.overlays-='SBombGivePower.dmi'
		usr.overlays-='SBombGivePower.dmi'
		if(ismob(usr.loc)) return
		if(usr.BodySwapVictim()) return
		if(teleport_failed) return
		if(m && m.z)

			//prevent drones from being teleported
			if(usr.grabbedObject&&ismob(usr.grabbedObject)&&usr.grabbedObject.drone_module&&!usr.grabbedObject.client) usr.ReleaseGrab()

			player_view(10,usr)<<sound('teleport.ogg',volume=25)
			if(usr.Ship&&usr.Ship.Small) usr.Ship.SafeTeleport(m.loc)
			else usr.SafeTeleport(m.loc)

	verb/Hotbar_use()
		set hidden=1
		Use()

	verb/Use() if(!usr.KO) Transport()

	verb/Set_frequency()
		Password=input("set the frequency. this will allow you to teleport to other telepads and \
		telewatches that use the same frequency") as text|null

obj/var/Injection
mob/var/Intelligence_Booster

obj/items/Intelligence_Booster
	icon='Poison Injection.dmi'
	Cost=10000000
	Stealable=1
	Injection=1
	desc="This will raise your intelligence. The lower your intelligence the greater the effect. You can only use this \
	once. This can not be used on people who already have 1x or more intelligence."
	verb/Hotbar_use()
		set hidden=1
		Use()
	verb/Use()
		var/mob/A=usr.get_inject()
		if(!A) return
		if(A.Intelligence>=1)
			usr<<"[A] already has 1+ intelligence it can not be boosted any further"
			return
		if(A.Intelligence_Booster)
			usr<<"[A] has already used this before and can not use it again"
			return
		player_view(15,usr)<<"[usr] injects [A] with a mysterious needle!"
		A.Intelligence=A.Intelligence**0.5
		A.Intelligence_Booster=1
		del(src)
obj/items/Diarea_Injection
	Injection=1
	Cost=8000000
	clonable = 0
	icon='Diarea Injection.dmi'
	Level=200
	Stealable=1
	verb/Hotbar_use()
		set hidden=1
		Use()
	verb/Use()
		var/mob/A=usr.get_inject(bypass_forced_check=1)
		if(!A) return
		player_view(15,usr)<<"[usr] injects [A] with a mysterious needle!"
		A.Diarea+=Level
		A.shit_virus_expire_time=world.realtime+(15*60*10)
		A.last_shit_increase=world.realtime+(5*60*60*10)
		del(src)
mob/var/Youthenasia=1
obj/items/Youthenasia
	Cost=1000000
	icon='Roids.dmi'
	Level=1
	Stealable=1
	Injection=1
	desc="This extends life. The more you use them the less effect they will have."
	verb/Hotbar_use()
		set hidden=1
		Use()
	verb/Use()
		var/mob/A=usr.get_inject()
		if(!A) return
		player_view(15,usr)<<"[usr] injects [A] with a mysterious needle!"
		A.Decline+=10/A.Youthenasia
		A.Youthenasia+=1
		del(src)
mob/var/LSD=0
obj/items/LSD
	icon='LSD.dmi'
	Level=40
	Stealable=1
	Injection=1
	Cost=7000
	desc="This drug will cause you to see weird stuff. All effects are short lasting and temporary."
	verb/Hotbar_use()
		set hidden=1
		Use()
	verb/Use()
		var/mob/A
		for(A in Get_step(usr,usr.dir)) if(A.KO) break
		if(!A) A=usr
		if(!A) return
		player_view(15,usr)<<"[usr] injects [A] with a mysterious needle!"
		if(A.client)
			if(!A.LSD) A.LSD()
			A.LSD+=Level
			A.LSD=round(A.LSD)
		del(src)

mob/proc/LSD()
	set waitfor=0
	if(!LSD) return
	see_invisible=2
	spawn(900) if(src&&LSD)
		LSD=0
		if(client) client.dir=NORTH
		see_invisible=0
	spawn(200) while(src&&LSD)
		Diarea(0,100,2)
		if(LSD) sleep(rand(0,1200/sqrt(LSD)))
	spawn(rand(0,600)) while(src&&LSD)
		var/list/L
		for(var/turf/T in view(2,src))
			if(!L) L=new/list
			L+=T
		if(L)
			var/turf/T=pick(L)
			if(!(locate(/obj) in T)&&!T.density)
				var/obj/O=new(T)
				O.Savable=0
				O.invisibility=2
				O.icon=pick('Body Parts.dmi','Exploded Head.dmi','Pool of Blood.dmi')
				O.pixel_x=rand(-10,10)
				O.pixel_y=rand(-10,10)
				Timed_Delete(O,rand(0,1200))
		sleep(2)
	spawn(600) while(src&&LSD)
		LSD-=1
		if(!LSD)
			client.dir=NORTH
			see_invisible=0
		sleep(600)
	spawn(100) while(src&&LSD)
		if(client) client.dir=pick(SOUTH,EAST,WEST,SOUTHEAST,SOUTHWEST,NORTHEAST,NORTHWEST)
		sleep(rand(0,600/sqrt(LSD)))
	spawn(50) while(src&&LSD)
		//if(prob(20)) Random_Scary_Image()
		var/divisor=sqrt(LSD)
		if(divisor<1) divisor=1
		sleep(rand(0,1200/divisor))
	spawn(40) while(src&&LSD)
		if(prob(70)) src<<pick('Creepy Ambience.ogg','Creepy Ambience 2.ogg')
		else
			src<<pick('Scary Girl.ogg','Wisp.ogg','Distant Monster Roar.ogg')
		sleep(rand(0,1200/sqrt(LSD)))
	spawn(300) while(src&&LSD)
		var/list/L
		for(var/turf/T in view(40,src)) if(getdist(src,T)>=20)
			if(!L) L=new/list
			L+=T
		if(L)
			var/obj/O=new(pick(L))
			O.invisibility=2
			O.layer=layer
			Timed_Delete(O,300)
			switch(rand(1,2))
				if(1)
					O.icon='Bunchie.dmi'
					O.name="Bunchie"
					O.LSD_Monster(src)
				if(2)
					O.icon='Michael Jackson.dmi'
					O.name="Michael Jackson"
					O.LSD_Monster(src)
		sleep(rand(0,1200/sqrt(LSD)))
obj/proc/LSD_Monster(mob/P)
	set waitfor=0
	while(src&&P)
		if(prob(20)) step_towards(src,P)
		else step_rand(src)
		sleep(rand(1,3))
obj/items/layer=4
mob/var/Fruits_Eaten=0

obj/items/Fruit
	icon='Yemma Fruit.dmi'
	Stealable=1
	clonable = 0
	desc="Eating this will increase your power. Each one you eat gives you less."

	verb/Hotbar_use()
		set hidden=1
		Use()

	verb/Use()
		if(usr.tournament_override(fighters_can=0))
			usr<<"These are illegal in the tournament"
			return
		if(usr.Android)
			usr<<"This has no effect on androids"
			return
		//if(usr.Regen_Mult<1.5) usr.Alter_regen_mult(1.5)
		//if(usr.Recov_Mult<2) usr.Alter_recov_mult(2)
		var/mob/m
		for(var/mob/p in players) if(!m || p.base_bp / p.bp_mod > m.base_bp / m.bp_mod) m = p
		if(usr.base_bp / usr.bp_mod < m.base_bp / m.bp_mod)
			var/bpGain = 600 * (0.7 ** (usr.Fruits_Eaten + 1))
			usr.Attack_Gain(bpGain, apply_hbtc_gains = 0, include_weights = 0, skipBPGains = 1)
			usr.Fruits_Eaten++
		player_view(15,usr)<<"[usr] eats a [src]"
		del(src)

obj/items/Moon
	Cost=8000
	icon='Moon.dmi'
	hotbar_type="Combat item"
	can_hotbar=1
	Stealable=1
	desc="Using this will turn nearby Yasais that still have tails into Great_Ape"
	var/Emitter
	verb/Hotbar_use()
		set hidden=1
		Use()

	verb/Use()
		set src in oview(1)
		if(icon_state=="On") return
		icon_state="On"
		player_view(15,usr)<<"[usr] activates the [src]!"
		view(10)<<'throw.ogg'
		for(var/mob/A in player_view(12,src)) spawn if(A)
			if(Emitter && A.ssjdrain>=300 && A.ssj2drain>=300 && A.SSj2Able && !A.SSj4Able && A.Race=="Yasai") A.Great_Ape(100)
			else A.Great_Ape()
			if(Emitter&&!A.Tail) A.Tail_Add()
		spawn(100) if(src) del(src)

	verb/Upgrade()
		set src in view(1)
		var/obj/Resources/A = usr.GetResourceObject()
		if(!A) return
		var/list/Choices=new
		var/Res_Cost=10000000/usr.Intelligence()**0.4
		if(A.Value>=Res_Cost&&!Emitter) Choices.Add("Turn into Emitter ([Res_Cost])")
		if(!Choices.len)
			usr<<"You do not have enough resources"
			return
		var/Choice=input("Change what?") in Choices
		if(Choice=="Turn into Emitter ([Res_Cost])")
			if(A.Value<Res_Cost) return
			A.Value-=Res_Cost
			Total_Cost+=Res_Cost
			Emitter=1
			icon='Moon2.dmi'
		Tech+=1

obj/var/Stealable
obj/items/PDA
	Cost=5000
	icon='PDA.dmi'
	desc="This can be used to store information, even youtube videos."
	Stealable=1

	New()
		spawn(5) if(src) del(src)

	verb/Hotbar_use()
		set hidden=1
		View()
	var/notes={"<html>
<head><title>Notes</title><body>
<body bgcolor="#000000"><font size=2><font color="#CCCCCC">
</body><html>"}
	//verb/Name() name=input("") as text
	//verb/View()
	//	set src in world
		//usr<<browse(notes,"window= ;size=700x600")
	//verb/Input()
		//notes=input(usr,"Notes","Notes",notes) as message

obj/Well
	Health=1.#INF
	icon='props.dmi'
	icon_state="well 2013"
	Dead_Zone_Immune=1
	density=1
	Knockable=0
	var/effectiveness=2
	Savable=0
	Grabbable=0
	Spawn_Timer=180000
	takes_gradual_damage=1

	verb/Upgrade()
		set name="Repair/Upgrade health"
		set src in view(1)
		if(usr in view(1,src))
			var/max_health=usr.Knowledge*usr.Intelligence()*2
			if(Health<max_health)
				player_view(15,usr)<<"[usr] repairs/upgrades the [src]'s health to [Commas(max_health)] BP"
				Health=max_health
			else usr<<"The [src] is beyond your upgrading abilities"

	New()
		for(var/obj/Well/A in range(0,src)) if(A!=src) del(A)
		//. = ..()

	verb/Use()
		set category="Other"
		set src in oview(1)

		/*if(world.time - usr.last_attacked_by_player < 100)
			usr << "You can not drink this if you were attacked in the last 10 seconds"
			return*/

		//if(world.time - usr.last_move < 30)
		//	usr << "You must stand still for 3 seconds before you can drink this"
		//	return

		if(!usr.Disabled() && usr.BPpcnt <= 100)
			player_view(5,usr)<<"<font color=red>* [usr] drinks some water. *"
			usr.healgaintime=world.realtime+150
			//if(usr.Health<100) usr.Health=100
			if(usr.Ki < usr.max_ki * 0.5) usr.Ki = usr.max_ki * 0.5
			usr.Alter_regen_mult(2.5)
			usr.Alter_recov_mult(5)
			usr.Stop_Powering_Up()

mob/proc/max_weight()
	var/adjusted_str=Str
	var/obj/items/Sword/s=using_sword()
	if(s) adjusted_str/=s.Damage
	adjusted_str=1
	var/n=(base_bp**0.7) * (adjusted_str**0.3) * 5
	return n

mob/var/tmp/obj/items/Weights/weights_obj
mob/proc/Cache_equipped_weights()
	for(var/obj/items/Weights/w in item_list) if(w.suffix) weights_obj=w

var/max_weights_mult = 2.33

mob/proc/weights()
	if(!weights_obj||!weights_obj.suffix||weights_obj.loc!=src) return 1
	var/abmult=Clamp(weights_obj.weight**0.01,1,1.33)
	var/mult=1 + (1 * (weights_obj.weight / max_weight())) + (abmult-1)
	mult=Clamp(mult,1,max_weights_mult)
	return mult

obj/items
	Weights
		Cost=50000
		clonable = 1

		can_scrap = 0 //because you can make INFINITE resources by taking weights from science then putting all your res into it then
		//cloning someone with the weights then scrap the weights and double your money each time because weights are clonable

		hotbar_type="Combat item"
		can_hotbar=1
		Savable=0
		var
			weight=5
		icon='Clothes_ShortSleeveShirt.dmi'
		Stealable=1
		desc="Wearing these will greatly increase BP gain and how fast you will catch up while fighting a stronger opponent. \
		Attacks will take much more energy than normal, and your \
		available BP will be lowered while wearing them."
		proc/weight_name()
			name="[Commas(weight)] kilo weight"
		New()
			weight_name()
			. = ..()
		verb/Hotbar_use()
			set hidden=1
			Click()
		Click() if(src in usr)
			for(var/obj/items/Weights/A in usr.item_list) if(A.suffix&&A!=src) usr.Clothes_Equip(A)
			usr.weights_obj=null
			usr.Clothes_Equip(src)
			if(suffix) usr.weights_obj=src
		verb/Choose_Weights_Icon()
			var/old_suffix=suffix
			if(suffix) usr.Clothes_Equip(src)
			usr.weights_icon_obj=src
			usr.Grid(weights_icons)
			if(usr && old_suffix)
				for(var/obj/items/Weights/A in usr.item_list) if(A.suffix) usr.Clothes_Equip(A)
				usr.Clothes_Equip(src)
		verb/Upgrade()
			var/cost_per_kilo=round(1000/(usr.Intelligence()**0.5))
			var/n=input("how much do you want these weights to weigh? 1 kilo cost [cost_per_kilo]$. these weights \
			weigh [Commas(weight)] kilos. you are able to lift [Commas(usr.max_weight())] kilos. making these weigh \
			beyond your max lift will have no effect when you wear them, it will be as if they are at your max.") as num
			if(n<1||n<weight)
				usr<<"you can not make the weights weigh less than they already do"
				return
			var/res_cost=(n*cost_per_kilo)-(weight*cost_per_kilo)
			if(res_cost<0) res_cost=0
			if(usr.Res()<res_cost)
				usr<<"you need at least [Commas(res_cost)]$ to do this"
				return
			player_view(15,usr)<<"[usr] upgrades the [src] from [Commas(weight)] to [Commas(n)] kilos in weight"
			weight=round(n)
			usr.Alter_Res(-res_cost)
			Cost=(weight*cost_per_kilo)+initial(Cost)
			weight_name()
	Regenerator
		Cost=500000
		canSideStep = 0
		Stealable=1
		var/Recovers_Energy
		var/Heals_Injuries
		var/Double_Effectiveness
		var/cures_radiation
		desc="Stepping into this will accelerate your healing rate. It heals faster the more upgraded \
		it is. It will break in the strain of high gravity."
		takes_gradual_damage=1
		density=1
		verb/Upgrade_health()
			set name="Repair/Upgrade health"
			set src in view(1)
			if(usr in view(1,src))
				var/max_health=usr.Knowledge*usr.Intelligence()
				if(Health<max_health)
					player_view(15,usr)<<"[usr] repairs/upgrades the [src]'s health to [Commas(max_health)] BP"
					Health=max_health
				else usr<<"The [src] is beyond your upgrading abilities"
		New()
			var/image/A=image(icon='Lab.dmi',icon_state="Tube",pixel_y=-32)
			var/image/B=image(icon='Lab.dmi',icon_state="TubeTop",pixel_y=0)
			overlays=null
			overlays.Add(A,B)
			. = ..()
		verb/Hotbar_use()
			set hidden=1
			Upgrade()
		verb/Upgrade()
			set src in view(1)
			var/Cost1=3000000/usr.Intelligence()**0.3 //injuries
			var/Cost2=500000/usr.Intelligence() //energy
			var/Cost3=1000000/usr.Intelligence()**0.6 //double effectiveness
			var/Cost4=1000000/usr.Intelligence()**0.6
			var/list/L=list("Cancel")
			if(!Heals_Injuries) L+="Heal Injuries ([Commas(Cost1)]$)"
			if(!Recovers_Energy) L+="Recover Energy ([Commas(Cost2)]$)"
			if(!Double_Effectiveness) L+="Double Effectiveness ([Commas(Cost3)]$)"
			if(!cures_radiation) L+="Cures radiation ([Commas(Cost4)]$)"
			if(L.len<=1)
				usr<<"This regenerator has all upgrades already"
				return
			while(usr)
				var/C=input("Which upgrade do you want to add?") in L
				if(C=="Cancel") return
				if(C=="Cures radiation ([Commas(Cost4)]$)")
					if(usr.Res()<=Cost4) return
					player_view(15,usr)<<"[usr] adds radiation healing to the [src]"
					cures_radiation=1
					usr.Alter_Res(-Cost4)
					Cost+=Cost4
					L-=C
				if(C=="Heal Injuries ([Commas(Cost1)]$)")
					if(usr.Res()<=Cost1) return
					player_view(15,usr)<<"[usr] adds injury healing to the [src]"
					Heals_Injuries=1
					usr.Alter_Res(-Cost1)
					Cost+=Cost1
					L-=C
				if(C=="Recover Energy ([Commas(Cost2)]$)")
					if(usr.Res()<=Cost2) return
					player_view(15,usr)<<"[usr] adds energy recovery to the [src]"
					Recovers_Energy=1
					usr.Alter_Res(-Cost2)
					Cost+=Cost2
					L-=C
				if(C=="Double Effectiveness ([Commas(Cost3)]$)")
					if(usr.Res()<=Cost3) return
					player_view(15,usr)<<"[usr] doubles the [src]'s effectiveness in all areas"
					Double_Effectiveness=1
					usr.Alter_Res(-Cost3)
					Cost+=Cost3
					L-=C
			desc="[src] upgrades:<br>"
			if(Heals_Injuries) desc+="Heals Injuries<br>"
			if(Recovers_Energy) desc+="Recovers Energy<br>"
			if(Double_Effectiveness) desc+="Double Effectiveness<br>"
			if(cures_radiation) desc+="Cures radiation<br>"
		layer=MOB_LAYER+1
		verb/Bolt()
			set src in oview(1)
			usr.Bolt(src)

var/cur_armor_ver = 2

mob/proc/Apply_Armor(obj/items/Armor/A) if(A.loc==src)
	//remove this block
	if(A.armor_ver == 0)
		for(var/obj/items/Armor/B in item_list) if(B.suffix&&B!=A) Apply_Armor(B)
		Clothes_Equip(A)
		if(A.suffix)
			End*=A.Armor*A.heavy_boost()
			endmod*=A.Armor*A.heavy_boost()
			Res*=(A.Armor*A.heavy_boost())**0.3
			resmod*=(A.Armor*A.heavy_boost())**0.3
			Off/=A.Armor**0.32
			offmod/=A.Armor**0.32
			Def/=A.Armor**0.48
			defmod/=A.Armor**0.48
			armor_obj=A
			Spd/=A.heavy_boost()
			spdmod/=A.heavy_boost()
		else
			End/=A.Armor*A.heavy_boost()
			endmod/=A.Armor*A.heavy_boost()
			Res/=(A.Armor*A.heavy_boost())**0.3
			resmod/=(A.Armor*A.heavy_boost())**0.3
			Off*=A.Armor**0.32
			offmod*=A.Armor**0.32
			Def*=A.Armor**0.48
			defmod*=A.Armor**0.48
			Spd*=A.heavy_boost()
			spdmod*=A.heavy_boost()
			armor_obj=null

	else if(A.armor_ver == 1)
		for(var/obj/items/Armor/B in item_list) if(B.suffix&&B!=A) Apply_Armor(B)
		Clothes_Equip(A)

		var
			dur_mult = (A.Armor + A.heaviness - 1) ** 0.6
			res_mult = (A.Armor + A.heaviness - 1) ** 0.35
			spd_mult = (1 / A.heaviness) ** 0.5
			off_mult = (1 / A.Armor) ** 0.5
			def_mult = (1 / A.Armor) ** 0.5

		if(A.suffix)
			End *= dur_mult
			endmod *= dur_mult
			Res *= res_mult
			resmod *= res_mult
			Off *= off_mult
			offmod *= off_mult
			Def *= def_mult
			defmod *= def_mult
			Spd *= spd_mult
			spdmod *= spd_mult
			armor_obj=A
		else
			End /= dur_mult
			endmod /= dur_mult
			Res /= res_mult
			resmod /= res_mult
			Off /= off_mult
			offmod /= off_mult
			Def /= def_mult
			defmod /= def_mult
			Spd /= spd_mult
			spdmod /= spd_mult
			armor_obj=null

	else if(A.armor_ver == 2)
		for(var/obj/items/Armor/B in item_list) if(B.suffix&&B!=A) Apply_Armor(B)
		Clothes_Equip(A)

		var
			dur_mult = (A.Armor + A.heaviness - 1) ** 0.5
			res_mult = (A.Armor + A.heaviness - 1) ** 0.25
			spd_mult = (1 / A.heaviness) ** 0.65
			off_mult = (1 / A.Armor) ** 0.65
			def_mult = (1 / A.Armor) ** 0.65

		if(A.suffix)
			End *= dur_mult
			endmod *= dur_mult
			Res *= res_mult
			resmod *= res_mult
			Off *= off_mult
			offmod *= off_mult
			Def *= def_mult
			defmod *= def_mult
			Spd *= spd_mult
			spdmod *= spd_mult
			armor_obj=A
		else
			End /= dur_mult
			endmod /= dur_mult
			Res /= res_mult
			resmod /= res_mult
			Off /= off_mult
			offmod /= off_mult
			Def /= def_mult
			defmod /= def_mult
			Spd /= spd_mult
			spdmod /= spd_mult
			armor_obj=null

mob/var/tmp/obj/items/Armor/armor_obj
obj/items/Armor
	Cost=50000
	Health=100
	Stealable=0
	var
		armor_ver=0
	clonable = 1
	hotbar_type="Combat item"
	can_hotbar=1
	can_change_icon=1
	icon='Armor1.dmi'
	var/Armor=0
	var/heaviness=1
	var/tmp/Choosing_Icon
	Del()
		var/mob/m=loc
		if(ismob(m) && suffix) m.Apply_Armor(src)
		. = ..()
	New()
		if(!Armor) Armor=rand(1000,2000)/1000
		Armor_Desc()
		spawn if(suffix)
			var/mob/m=loc
			if(m&&ismob(m)) m.armor_obj=src

		//remove
		spawn
			var/mob/m=loc
			if(armor_ver < cur_armor_ver && ismob(m) && suffix) m.Apply_Armor(src)
			armor_ver = cur_armor_ver

		. = ..()

	verb/Hotbar_use()
		set hidden=1
		Click()
	Click()
		if(usr.Redoing_Stats)
			usr<<"You can not use this while choosing stat mods"
			return
		usr.Apply_Armor(src)
	desc="Armor will increase certain protective stats and decrease certain stats related to mobility or \
	flexibility. You'll just have to try it on to see exactly what effect it has. The more protective an armor \
	is the more it will decrease stats related to mobility and/or flexibility."
	proc/Armor_Desc() desc=initial(desc)+"<br>Protection: [round(Armor,0.01)]x"

	proc/heavy_boost()
		return heaviness**0.6

	verb/Customize()
		set src in view(1)
		if(usr in view(1,src))
			while(usr && usr.client)
				if(suffix)
					usr<<"You can not customize armor that is being worn"
					return
				switch(input(usr,"Here you can make changes to your armor") in list("Cancel","Choose Icon","Protection","Heaviness"))
					if("Cancel") return
					if("Choose Icon")
						if(!Armor_Icons) Armor_Icons()
						Choosing_Icon=1
						usr.Grid(Armor_Icons)
						while(usr&&(winget(usr,"Grid1","is-visible")=="true")) sleep(1)
						Choosing_Icon=0
					if("Protection")
						var/N=input("Enter the protection level of this armor. It must be between 1 and 2. The higher the \
						number the more durability and resistance the armor will provide, but the more it will limit \
						your flexibility, causing your accuracy and dodging to decrease.") as num
						if(suffix)
							usr<<"You can not customize this while wearing it"
							return
						if(N<1) N=1
						if(N>2) N=2
						Armor=N
						Armor_Desc()
					if("Heaviness")
						var/n=input(usr,"Enter how heavy this armor is between 1 and 2. 1 is very light and will not decrease \
						your speed at all. 2 is the heaviest and will decrease speed by a lot. The heavier it is the more \
						protection it will provide.","Options",heaviness) as num
						if(suffix)
							usr<<"You can not customize this while wearing it"
							return
						n=Clamp(n,1,2)
						heaviness=n
var/list/Armor_Icons //this is actually list of objects

var/list/armor_icon_list = list('Armor1.dmi','Nappa Armor.dmi','Armor2.dmi','Armor3.dmi','Armor4.dmi','Armor5.dmi',\
	'Armor6.dmi','Armor7.dmi','White Male Armor.dmi','Armor Bardock.dmi','TurlesArmor.dmi',\
	'GinsDynastyArmorRed.dmi','Phoenix Full (Makyo).dmi','Phoenix Full (Moonlight).dmi',\
	'Phoenix Full (Negative Makyo).dmi','Phoenix Full (Negative).dmi','Phoenix Full.dmi','WTF Armor.dmi',\
	'Blue Armor.dmi','Red Armor.dmi','Raditz Armor Tobi Uchiha.dmi','Turles Armor Tobi Uchiha.dmi')

proc/Armor_Icons()
	if(!Armor_Icons) Armor_Icons=new/list
	for(var/V in armor_icon_list)
		var/obj/Armor_Icon/O=new
		O.icon=V
		Armor_Icons+=O

obj/Armor_Icon/Click() for(var/obj/items/Armor/A in view(1)) if(A.Choosing_Icon) A.icon=icon

obj/var/Money

mob/proc/MaxItems() //max items you can carry
	var/n = max_items
	if(HasAnyPack()) n += 20
	return n

obj/items/verb/Drop()
	if(usr.Final_Realm())
		usr << "You can not drop items in this place"
		return
	var/mob/P
	for(P in Get_step(usr,usr.dir)) break
	if(P&&!P.client) P=null
	if(P&&istype(src,/obj/items/Force_Field))
		usr<<"You can not drop force fields onto other players. This is to prevent bug abuse where a person drops a super \
		weak force field on someone during a fight then kills them with 1 energy blast"
		return
	if(P&&P.item_count()>=P.MaxItems())
		usr<<"You can not give [P] this item because their inventory is full"
		P<<"[usr] tried to give you an item but your inventory is full"
		return
	var/Amount=0
	for(var/obj/A in Get_step(usr,usr.dir)) if(!(locate(A) in usr)) Amount+=1
	for(var/obj/Turfs/Door/D in Get_step(usr,usr.dir))
		usr<<"You can not drop anything on top of a door"
		return
	if(!(locate(/obj/Bank) in Get_step(usr,usr.dir))&&Amount>4&&!P)
		usr<<"Nothing more can be placed on this spot."
		return
	if(suffix) if(!Can_Drop_With_Suffix)
		usr<<"You must unequip it first"
		return
	for(var/mob/A in player_view(15,usr)) if(A.see_invisible>=usr.invisibility)
		if(!P) A<<"[usr] drops [src]"
		else A<<"[usr] gives [P] a [src]"
	usr.overlays-=icon
	//SafeTeleport(Get_step(usr,usr.dir))
	Move(usr.loc)
	step(src, usr.dir)
	dir=SOUTH
	if(P) Move(P)
	else usr.Store_item_check(src)

	if(usr && ismob(usr) && usr.client) usr.Restore_hotbar_from_IDs()

	if(z&&istype(src,/obj/items/Senzu)) src:Senzu_grow()

	if(istype(src,/obj/items/Dragon_Ball))
		var/obj/items/Dragon_Ball/db = src
		db.SetDBPixelOffsets()

mob/var/tmp/skip_restore_hotbar

obj/items
	Scouter
		Cost=15000
		icon='Scouter.dmi'
		var/Scan=1000
		var/Range=5
		var/Frequency=1
		var/android_detection
		clonable = 1
		Stealable=1
		era_reset_immune=0
		clonable=1
		desc="Equipping this will open a tab that allows you to see the battle power of all people \
		within the scouter's range and detection capabilities."
		New()
			spawn if(ismob(loc)&&suffix)
				var/mob/m=loc
				m.Scouter=src
			. = ..()
		Click()
			usr.Clothes_Equip(src)
			if(suffix) usr.Scouter=src
			else if(usr.Scouter==src) usr.Scouter=null
		verb/Hotbar_use()
			set hidden=1
			Transmit()
		verb/Upgrade()
			set src in view(1)
			if(usr in view(1,src))
				var/list/upgrade_list=list("Cancel","Max scan")
				if(!android_detection) upgrade_list+="Detect androids"
				if(upgrade_list.len<=2) upgrade_list-="Cancel"
				switch(input("Choose from available upgrades") in upgrade_list)
					if("Cancel") return
					if("Detect androids")
						var/cost=150000/usr.Intelligence()**0.5
						if(usr.Res()<cost) alert("You need [Commas(cost)]$ to do this")
						else
							usr.Alter_Res(-cost)
							android_detection=1
							player_view(15,usr)<<"[usr] gives the scouter android detection"
					if("Max scan")
						var/Max_Upgrade=usr.Knowledge * 5 * usr.Intelligence()**0.35
						var/Percent=(Scan/Max_Upgrade)*100
						var/Res_Cost=Item_cost(usr,src)/100
						if(Percent>=100)
							usr<<"This [src] is 100% upgraded at this time and cannot go any further."
							return
						var/Amount=input("This [src] scans up to [Commas(Scan)] BP. The current maximum is \
						[Commas(Max_Upgrade)] BP. \
						It is at [Percent]% maximum upgrade. Each 1% upgrade cost [Commas(Res_Cost)]$. The maximum is 100%. \
						Input the percentage you wish to upgrade the [src] to. ([Percent]-100%)") as num
						if(Amount>100) Amount=100
						if(Amount<0.1)
							usr<<"Amount must be higher than 0.1%"
							return
						if(Amount<=Percent)
							usr<<"This cannot be downgraded."
							return
						Res_Cost*=Amount-Percent
						if(usr.Res()<Res_Cost)
							usr<<"You do not have enough resources to do this."
							return
						usr.Alter_Res(-Res_Cost)
						Scan=Max_Upgrade*(Amount/100)
						player_view(15,usr)<<"[usr] upgraded [src] from [Percent]% to [Amount]% ([Commas(Scan)] BP)"
						desc="Scan: [Commas(Scan)] BP<br>Range: [Range]"
		verb
			Transmit(msg as text) for(var/mob/P in players)
				for(var/obj/items/Scouter/S in P.item_list)
					if(S.suffix&&((!P.Dead&&!usr.Dead)||(P.Dead&&usr.Dead))&&S.Frequency==Frequency)
						P<<"<font color=#FFFFFF>(Scouter)<font color=[usr.TextColor]>[usr]: [msg]"
				for(var/obj/items/Communicator/S in P.item_list)
					if(S.suffix&&((!P.Dead&&!usr.Dead)||(P.Dead&&usr.Dead))&&S.Frequency==Frequency)
						P<<"<font color=#FFFFFF>(Scouter)<font color=[usr.TextColor]>[usr]: [msg]"
			Frequency() Frequency=input("Choose a frequency, it can be anything. It lets you talk to \
			others on the same frequency. Default is 1") as text
var/list/Sword_Icons
proc/Sword_Icons()
	if(!Sword_Icons) Sword_Icons=new/list
	for(var/V in list('Sword 2.dmi','Sword 1.dmi','Item - Katana 2.dmi','Item - Katana.dmi','Short Sword.dmi',\
	'Item, Sword 1.dmi','Item, Buster Sword.dmi','Item, Dual Blaze Sword.dmi','Item, Dual Electric Sword.dmi',\
	'Item, Great Sword.dmi','Sword Flame Complete.dmi','Sword, 2 Katanas.dmi','Sword, Samurai.dmi',\
	'Sword_Trunks.dmi','Falseneoblade.dmi','KingdomKey.dmi','KiSword.dmi','Yin Yang.dmi'))
		var/obj/Sword_Icon/O=new
		O.icon=V
		Sword_Icons+=O
obj/Sword_Icon/Click() for(var/obj/items/Sword/A in view(1)) if(A.Choosing_Icon) A.icon=icon
obj/items
	Sword
		clonable = 1
		hotbar_type="Combat item"
		can_hotbar=1
		New()
			spawn if(suffix&&ismob(loc))
				var/mob/M=loc
				M.equipped_sword=src
			. = ..()
		Del()
			var/mob/m=loc
			if(ismob(m)&&suffix) m.Apply_Sword(src)
			. = ..()
		can_change_icon=1
		var/tmp/Choosing_Icon
		Cost=50000
		icon='Sword_Trunks.dmi'
		Health=10000000
		Stealable=0
		clonable=1
		var/Damage=2
		var/is_silver=0
		var/Style="Physical"

		desc="A sword will increase melee damage. It will also boost your enemy's dodging chances because \
		they are trying to avoid being cut to peices."

		desc = "\
		Increases melee damage.<br>\
		Enemy dodges you easier because swords drain less stamina from them when dodging.<br>\
		Somewhat decreases your attack rate<br>\
		Slightly more drain than melee<br>\
		"

		proc/Sword_Desc() desc=initial(desc)+"<br>Sharpness: [round(Damage,0.01)]x"
		verb/Customize()
			set src in view(1)
			if(usr in view(1,src))
				while(usr)
					if(suffix)
						usr<<"You can not customize a sword that is being worn"
						return

					start

					var/list/l = list("Cancel","Choose Icon","Change Sharpness Level","Set Damage Style","Set Silver Blade")
					if(is_silver) l -= "Set Silver Blade"
					switch(input(usr) in l)
						if("Cancel") return
						if("Set Silver Blade")
							var/resCost = 10000000 / usr.Intelligence() ** 0.5
							if(usr.Res() < resCost)
								alert("You need [Commas(resCost)] resources to do this")
								goto start
							/*switch(alert("Is this blade made of silver? If yes, the blade will be slightly dull \
							(-[(1-silver_sword_damage_penalty)*100]% damage), but do [silver_sword_damage_mult]x \
							damage against undead (vampires, zombies)","Options","No","Yes"))*/
							switch(alert("A silver blade will do [silver_sword_damage_mult]x more damage against vampires and zombies. But it cost [Commas(resCost)] \
							resources.", "Options", "Yes", "No"))
								if("Yes")
									if(usr.Res() < resCost)
										alert("You need [Commas(resCost)] resources to do this")
										goto start
									is_silver=1
									usr.Alter_Res(-resCost)
									Cost += resCost //for scrapping
								if("No") is_silver=0
						if("Set Damage Style")
							switch(input("Physical damage is the normal melee damage type, it does damage based on the \
							opponent's durability and your strength. Energy damage does damage on the opponent's \
							resistance, but only does roughly [energy_sword_damage_mod]% the total damage that physical damage would. \
							50% of the energy damage comes from your strength, the other 50% comes from your force. \
							Setting it to energy damage is a \
							tactical thing, if you know your opponent has really low resistance you can make use of that.") \
							in list("Physical Damage","Energy Damage"))
								if("Physical Damage") Style="Physical"
								if("Energy Damage") Style="Energy"
						if("Choose Icon")
							if(!Sword_Icons) Sword_Icons()
							Choosing_Icon=1
							usr.Grid(Sword_Icons)
							while(usr&&(winget(usr,"Grid1","is-visible")=="true")) sleep(1)
							Choosing_Icon=0
						if("Change Sharpness Level")
							var/N=input("Change the sharpness of this sword. The higher the number the more damage it will \
							do but it will make it easier for your opponent to dodge it. Entering 1 will mean it has no effect \
							and is just for looks. You can enter a number between 1 and 2. Current is [Damage]") as num
							if(suffix)
								usr<<"You can not customize this while wearing it"
								goto start
							if(N<1) N=1
							if(N>2) N=2
							Damage=N
							Sword_Desc()
		verb/Hotbar_use()
			set hidden=1
			Click()
		Click()
			if(usr.Redoing_Stats)
				usr<<"You can not use this while choosing stat mods"
				return
			usr.Apply_Sword(src)
mob/proc/Apply_Sword(obj/items/Sword/S)
	if(S.loc==src)
		for(var/obj/items/Sword/A in item_list) if(A!=S&&A.suffix)
			Apply_Sword(A)
		Clothes_Equip(S)
		if(S.suffix)
			Str*=S.Damage
			strmod*=S.Damage
			equipped_sword=S
		else
			Str/=S.Damage
			strmod/=S.Damage
			equipped_sword=null
obj/items
	Digging
		var/DigMult=1
		Stealable=1
		Savable=0
		Shovel
			icon='Shovel.dmi'
			desc="This will help increase the speed at which you can dig up resources."
			DigMult=2
			Cost=3000
			verb/Hotbar_use()
				set hidden=1
				Click()
			Click() if(src in usr)
				for(var/obj/items/Digging/A in usr.item_list) if(A!=src&&A.suffix) A.suffix=null
				if(!suffix) suffix="Equipped"
				else suffix=null
		Hand_Drill
			icon='Drill Hand 2.dmi'
			desc="This will help increase the speed at which you can dig up resources."
			DigMult=4
			Cost=10000
			verb/Hotbar_use()
				set hidden=1
				Click()
			Click() if(src in usr)
				for(var/obj/items/Digging/A in usr.item_list) if(A!=src&&A.suffix) A.suffix=null
				if(!suffix) suffix="Equipped"
				else suffix=null

mob/var/tmp/Digging

mob/proc/Digging(Amount=1)
	Ki-=3*Amount
	if(Ki<1*Amount)
		Digging=0
		src<<"You stop digging due to exhaustion"
	Amount*=3*(base_bp**0.25)
	if(Amount<1) Amount=1
	for(var/obj/items/Digging/D in item_list) if(D.suffix) Amount*=D.DigMult
	Amount=round(Amount)
	Alter_Res(Amount)

mob/verb/Dig_for_Resources()
	set category="Skills"
	Digging=!Digging
	if(!Digging) src<<"You stop digging for resources"
	else
		src<<"You begin digging for resources (see items tab)"
		Dig_loop()

obj/items/Hover_Chair
	Cost=3000
	desc="This will let you have fully functional flying abilities."
	icon='Item, Hover Chair.dmi'
	icon_state="base"
	density=1
	layer=MOB_LAYER+10
	takes_gradual_damage=1
	verb/Hotbar_use()
		set hidden=1
		Click()
	verb/Upgrade_health()
		set name="Repair/Upgrade health"
		set src in view(1)
		if(usr in view(1,src))
			var/max_health=usr.Knowledge*usr.Intelligence()
			if(Health<max_health)
				player_view(15,usr)<<"[usr] repairs/upgrades the [src]'s health to [Commas(max_health)] BP"
				Health=max_health
			else usr<<"The [src] is beyond your upgrading abilities"
	New()
		var/image/A=image(icon='Item, Hover Chair.dmi',icon_state="side1",pixel_y=0,pixel_x=-32,layer=10)
		var/image/B=image(icon='Item, Hover Chair.dmi',icon_state="side2",pixel_y=0,pixel_x=32,layer=10)
		var/image/C=image(icon='Item, Hover Chair.dmi',icon_state="back",pixel_y=0,pixel_x=-0,layer=MOB_LAYER-1)
		var/image/D=image(icon='Item, Hover Chair.dmi',icon_state="front",pixel_y=0,pixel_x=0,layer=MOB_LAYER+10)
		var/image/E=image(icon='Item, Hover Chair.dmi',icon_state="bottom",pixel_y=-32,pixel_x=0,layer=10)
		overlays=null
		overlays.Add(A,B,C,D,E)
		. = ..()
	Click()
		usr.Clothes_Equip(src)
mob/var
	Regen_Mult=1
	Recov_Mult=1
	senzu_timer=0 //eat another senzu before this timer ends and suffer a debuff
	senzu_overload=0 //if this is not zero then you ate a senzu before the senzu_timer ended, this is a timer too

var/list/senzus=new

mob/proc/EatSensu(mob/user, obj/o)
	set waitfor=0

	if(InCore())
		user << "The sensu disintegrates from the intense heat"
		return

	var/sec = 10
	user << "Stand still and do nothing for [sec] seconds to eat the sensu bean"
	var/old_loc = loc
	var/user_old_loc = user.loc
	for(var/v in 1 to sec * 2)
		if(loc != old_loc) return
		if(user.loc != user_old_loc) return
		if(attacking) return
		sleep(5)
	if(src == user) player_view(15,src) << "[src] eats a sensu bean"
	else player_view(15,src) << "[user] uses a sensu bean on [src]"
	Diarea = 0
	for(var/obj/Injuries/i in injury_list) del(i)
	UnKO()
	Health = 100
	Ki = max_ki
	Stop_Powering_Up()
	if(o) del(o)
	return 1

obj/items/Senzu
	desc="This sensu bean will heal you fast. \
	If you plant this, it will grow more over time. It will only grow if a player is nearby."
	Stealable=1
	hotbar_type="Combat item"
	can_hotbar=1
	icon='Senzu Bean.dmi'
	name = "Sensu Bean"

	New()
		pixel_x=rand(-8,8)
		pixel_y=rand(-8,8)
		//icon=pick('Food Tomato.dmi','Food Turnip.dmi','Food Potato.dmi',\
		//'Food Jungle Fruit.dmi','Food Grapes.dmi','Food Corn.dmi')
		senzus+=src
		. = ..()

	Del()
		senzus-=src
		. = ..()

	verb/Hotbar_use()
		set hidden=1
		Use()

	verb/Use()
		var/mob/M=locate(/mob) in Get_step(usr,usr.dir)
		if(!M) M=usr
		if(usr.tournament_override(fighters_can=0))
			usr<<"These are illegal in the tournament"
			return
		if(usr.KO)
			usr<<"You can't, you are knocked out"
			return
		if(M.Android)
			usr<<"This has no effect on androids"
			return

		if(M.EatSensu(usr,src))
			del(src)
		return

		if(M.senzu_timer)
			if(!M.senzu_overload) M.Senzu_overload_countdown()
			M.senzu_overload=120
			M<<"<font color=cyan>You have eaten a senzu too soon after the last one you ate! \
			One senzu fills a person up, eating more is overeating, which will make you move slower \
			for the next [M.senzu_overload] seconds."
		if(!M.senzu_timer)
			M.senzu_timer = 300
			M.Senzu_timer_countdown()
		M.senzu_timer=300
		M.Alter_regen_mult(6)
		M.Alter_recov_mult(6)
		M.UnKO()
		if(M==usr) player_view(15,usr)<<"[M] eats a [src]"
		else player_view(15,usr)<<"[usr] uses a [src] on [M]"
		for(var/obj/Injuries/I in M.injury_list) del(I)
		M.Diarea=0
		//M.Zombie_Virus=0
		del(src)

	verb/Throw(mob/M in oview(usr))
		player_view(15,usr)<<"[usr] throws a [src] to [M]"
		Missile(icon,usr,M)
		sleep(3)
		player_view(15,usr)<<"[M] catches the [src]"
		Move(M)

	var/senzu_max_per_turf=10
	var/tmp/senzu_growing

	proc/Senzu_grow()
		set waitfor=0
		//var/senzu_limit=200
		/*if(senzus.len>=senzu_limit && z)
			player_view(15,src)<<"No more senzu beans can be grown until there are less than [senzu_limit] senzu beans \
			in existance (due to lag). If you leave it here it will grow when the limit is no longer exceeded, but it will \
			probably take very long."*/
		if(senzu_growing) return
		senzu_growing=1
		while(src)
			//sleep(300 * Clamp(senzus.len/100,1,60) )
			sleep(600)
			if(!z)
				senzu_growing=0
				return
			if(senzus.len >= 200) continue
			var/senzu_count=0
			for(var/obj/items/Senzu/s in loc)
				senzu_count++
				if(s!=src&&s.senzu_growing)
					senzu_growing=0
					continue
			if(senzu_count>=senzu_max_per_turf)
				senzu_growing=0
				continue
			new/obj/items/Senzu(loc)
		senzu_growing=0

	proc/Senzu_pickup()
		if(!z) return
		if(isturf(loc)) for(var/obj/items/Senzu/s in loc) if(s!=src)
			s.Senzu_grow()
			break

mob/proc/Senzu_timer_countdown()
	set waitfor=0
	sleep(10)
	while(src)
		if(!senzu_timer) return
		senzu_timer--
		if(!senzu_timer) break
		else sleep(10)

mob/proc/Senzu_overload_countdown()
	set waitfor=0
	sleep(10)
	while(src)
		if(senzu_overload<0) senzu_overload=0
		if(!senzu_overload) return
		senzu_overload--
		if(!senzu_overload) break
		else sleep(10)

obj/var/Using
atom/var/Bolted
var/list/shikon_jewels=new

var/shikon_aura

mob/proc
	ShikonAura()
		set waitfor=0
		sleep(world.tick_lag * 2)
		if(!shikon_aura)
			var/icon/i = 'SS Red Idle Aura.dmi'
			i += rgb(0,0,0,203)
			shikon_aura = image(icon = i, pixel_x = -32, pixel_y = -28)
		overlays -= shikon_aura
		for(var/obj/items/Shikon_Jewel/sj in shikon_jewels)
			if(sj.loc == src)
				overlays -= shikon_aura
				overlays += shikon_aura
				break

obj/items/Shikon_Jewel
	bankable = 0
	can_blueprint=0
	can_scrap=0
	//Cost=1000000000
	icon='Shikon Jewel.dmi'
	Stealable = 1
	Health=1.#INF
	can_be_renamed=0
	Cloakable=0
	clonable=0
	var/bp_mult=1.25
	desc="This jewel is ancient and grants power to those who possess it. The jewel is very well known to demons due to the \
	many who have possessed it, so it is possible that many demons know of its existance already."

	New()
		spawn if(src) Original_Icon()
		shikon_jewels+=src
		//name=initial(name)
		invisibility=0
		for(var/obj/items/Cloak/c in src) del(c)
		. = ..()

	Del()
		shikon_jewels-=src
		. = ..()

	proc/Original_Icon() while(src)
		//icon=initial(icon)
		sleep(300)

	verb/Hotbar_use()
		set hidden=1
		Click()

	Click() usr<<"[bp_mult]x BP Multiplier"
	/*verb/Split()
		if(bp_mult<1.05)
			usr<<"This can not be split any further"
			return
		var/obj/items/Shikon_Jewel/S=new(usr)
		S.bp_mult=sqrt(bp_mult)
		bp_mult=sqrt(bp_mult)
		player_view(15,usr)<<"[usr] splits the [src] in half"
	verb/Assemble()
		for(var/obj/items/Shikon_Jewel/S in usr.item_list) if(S!=src)
			player_view(15,usr)<<"[usr] combines 2 shards of the [src]"
			bp_mult*=S.bp_mult
			S.name="Tens"
			del(S)
			return
		usr<<"You must have another [src] in your items to combine them"*/



mob/proc/get_inject(bypass_forced_check)
	var/mob/m=src
	for(var/mob/m2 in Get_step(src,dir)) m=m2
	if(m!=src&&tournament_override(fighters_can=0) && m.client)
		src<<"You can not inject other people at tournaments"
		return
	if(!bypass_forced_check)
		if(m!=src&&m.client&&!forced_injections)
			src<<"Forced injections on people against their will is disabled on this server"
			return
	if(m!=src&&alignment_on&&both_good(src,m) && m.client)
		src<<"You can not force inject another good person"
		return
	if(m!=src && (!m.KO&&!m.Frozen) && m.client)
		src<<"They must be knocked out or paralyzed for you to inject them"
		return
	if(m.Android)
		src<<"This has no effect on androids"
		return
	if(m.Race=="Majin")
		src<<"This has no effect on majins"
		return
	return m


obj/Focusin_revert
	Skill=1
	desc="Use this on yourself or someone in front of you to remove the effects of focusin from them"
	teachable=1
	Teach_Timer=8
	student_point_cost = 50
	hotbar_type="Ability"
	can_hotbar=1

	verb/Hotbar_use()
		set hidden=1
		Focusin_Revert()

	verb/Focusin_Revert()
		set category="Skills"
		var/mob/m=usr
		for(var/mob/m2 in Get_step(usr,usr.dir)) m=m2
		if(!m.focusin_uses)
			usr<<"[m] does not have focusin in them. There is nothing to remove."
			return
		player_view(15,usr)<<"[usr] removes the effects of focusin from [m]"
		while(m.focusin_uses)
			m.focusin_uses--
			m.Decline += focusin_decline_add
			m.Original_Decline += focusin_decline_add
			m.zenkai_mod /= focusin_zenkai_mult
			m.leech_rate /= focusin_leech_mult
			m.base_bp=1
			m.highest_bp_ever_had=1
			m.hbtc_bp=0

var
	focusin_zenkai_mult = 0.8
	focusin_leech_mult = 0.8
	focusin_decline_add = 8

obj/items/Focusin
	icon='Item, Needle.dmi'
	desc="Injecting yourself with this will decrease your decline age by 8 years. But for 5 minutes you \
	will rapidly leech power from those around you. You must inject it into your eyes. \
	There is a 10% chance you will immediately die. You can only leech up to 85% of a person's BP \
	using this. Each use decreases zenkai mod by 20% and leech mod by 20%. The effects can be undone \
	magically by the Kaioshin, but you will also lose the BP you leeched, but keep any BP \
	you gained legit."
	Cost=1000000
	clonable = 0
	Stealable=1

	verb/Hotbar_use()
		set hidden=1
		Use()

	verb/Use()
		var/mob/m=usr.get_inject()
		if(!m) return
		if(m==usr) player_view(15,usr)<<"<font color=red>[m] stabs a double ended needle into their eyes and \
		begins screaming. What the fuck."
		else player_view(15,usr)<<"<font color=red>[usr] stabs [m] in the eyes with a double ended needle. What the fuck."
		if(prob(10))
			m.Death("???",1)
		else
			m.KO("???",allow_anger=0)
			m.focusin_loop()
			m.Decline -= focusin_decline_add
			m.Original_Decline -= focusin_decline_add
			m.zenkai_mod *= focusin_zenkai_mult
			m.leech_rate *= focusin_leech_mult
			m.focusin_uses++
		del(src)

mob/var
	focusin_uses=0

mob/proc/focusin_loop()
	set waitfor=0
	for(var/v in 1 to 300)
		for(var/mob/m in player_view(30,src)) if(base_bp+hbtc_bp<(m.base_bp+m.hbtc_bp) * 0.8)
			//var/old_bp=base_bp
			Leech(m, 24, no_adapt = 1, weights_count = 0)
			//hbtc_bp+=base_bp-old_bp
			//base_bp=old_bp
		sleep(10)





mob/var/next_rage_heal=0
obj/items/RAGE
	icon='Item, Needle.dmi'
	desc="Using this will immediately send you into a drug induced rage, raising your battle power by \
	half of what your normal anger usually gives. Decreases you decline by only 2 months. You can only get the \
	full heal from this once every 10 minutes"
	Stealable=1
	hotbar_type="Combat item"
	can_hotbar=1
	Cost=500000
	verb/Hotbar_use()
		set hidden=1
		Use()
	verb/Use()
		if(usr.KO) return
		var/mob/m=usr.get_inject()
		if(!m) return
		if(m.can_anger())
			player_view(15,usr)<<"[usr] injects [m] with RAGE!"
			if(world.realtime>=m.next_rage_heal)
				m.FullHeal()
				m.next_rage_heal=world.realtime+(10*60*10)
			m.Decline-=0.2
			m.Original_Decline-=0.2
			m.anger(ssj_possible=0,reason="rage injection")
			m.anger=(m.max_anger-100)*0.5+100
		else player_view(15,usr)<<"[usr] injects [m] with RAGE! It has no effect..."
		del(src)





mob/var/Roid_Power=0
obj/items/Steroids
	icon='Item, Needle.dmi'
	Cost=4000
	var/Roid_Power=0.25
	Stealable=1
	desc="BP up, force down, resistance down, speed down, defense down, recovery down, lifespan down. Steroids make \
	you unable to mate. All effects are temporary except the lifespan decrease. The more you take, or the more upgraded \
	they are, the greater the advantages and disadvantages."
	verb/Hotbar_use()
		set hidden=1
		Use()
	verb/Use()
		var/mob/A=usr.get_inject()
		if(!A) return
		if(A.Roid_Power>=0.75)
			usr<<"They are maxed out on steroids, injecting this will do nothing."
			return
		A.Undo_Steroid_Stats()
		A.Roid_Power+=Roid_Power
		A.Original_Decline-=Roid_Power
		A.Decline-=Roid_Power
		A.Steroid_Stats()
		player_view(15,usr)<<"[usr] injects [A] with a mysterious needle!"
		del(src)
mob/proc/Steroid_Loop()
	set waitfor=0
	while(src)
		if(Roid_Power)
			Roid_Power(-0.01)
			sleep(200)
		else sleep(1200)
mob/proc/Steroid_Stats()
	var/Amount=Roid_Power+1
	Pow/=Amount
	formod/=Amount
	Res/=Amount
	resmod/=Amount
	Spd/=Amount
	spdmod/=Amount
	Def/=Amount**2
	defmod/=Amount**2
	recov/=Amount
mob/proc/Undo_Steroid_Stats()
	var/Amount=Roid_Power+1
	Pow*=Amount
	formod*=Amount
	Res*=Amount
	resmod*=Amount
	Spd*=Amount
	spdmod*=Amount
	Def*=Amount**2
	defmod*=Amount**2
	recov*=Amount
mob/proc/Roid_Power(Amount)
	Undo_Steroid_Stats()
	if(!Amount) Roid_Power=0
	else Roid_Power+=Amount
	if(Roid_Power<0) Roid_Power=0
	if(Roid_Power) Steroid_Stats()
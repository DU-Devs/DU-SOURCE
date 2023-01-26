obj/var/can_radar = 1

var/list/teleport_nullifiers

obj/Giant_Teleport_Nullifier
	can_change_icon=0
	Cost=25000000
	makes_toxic_waste=1
	New()
		teleport_nullifiers ||= list()
		teleport_nullifiers |= src
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

	for(var/obj/Giant_Teleport_Nullifier/o in teleport_nullifiers) if(o.z && o.disable_teleports)
		if(!(frequency in o.allowed_frequencies))
			var/area/o_area=locate(/area) in range(0,o)
			if(get_area()==o_area) return 1

	for(var/obj/items/Teleport_Nullifier/o in teleport_nullifiers) if(o.disable_teleports)
		var/atom/A = o
		if(ismob(o.loc)) A = o.loc
		if(ismob(src) && src != o.loc && src.z == A.z && getdist(src,A) < 50) return 1

obj/items/Teleport_Nullifier
	New()
		teleport_nullifiers ||= list()
		teleport_nullifiers |= src
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
		set src in range(1)
		disable_teleports=!disable_teleports
		if(disable_teleports) usr<<"[src] is now on"
		else usr<<"[src] is now off"


var/list/wall_bots
obj/Wall_upgrader_bot
	can_change_icon=0
	Cost = 12000000
	makes_toxic_waste=0
	icon='Modules.dmi'
	icon_state="3"
	New()
		wall_bots ||= list()
		wall_bots |= src
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

var/lastWallBotUpdate = 0
proc/WallBotUpdate()
	set waitfor = 0
	if(lastWallBotUpdate + 36000 > world.time) return
	lastWallBotUpdate = world.time
	var/mob/temp=new
	temp.Knowledge=Tech_BP * 1
	temp.Intelligence=1
	for(var/obj/Wall_upgrader_bot/b in wall_bots) if(b.z)
		player_view(15,b)<<"<font color=white>[b]: <font color=red>Walls upgraded. Beep boop."
		var/list/upgraded=new
		for(var/turf/t in range(1,b)) if(t.created_by&&!(t.created_by in upgraded))
			upgraded+=t.created_by
			spawn
				for(var/i in PlayerMadeTurfs)
					if(findtext(i, t.created_by))
						var/proxy_storage/P = PlayerMadeTurfs[i]
						P.Upgrade(temp)
					sleep(0)
	if(temp) del(temp)

var/list/resource_destroyers=new

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
	Cost=0 //15000000
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
		for(var/obj/Spawn/s in RaceSpawns) if(s.z) spawns+="[s]: [s.desc]"
		var/obj/Spawn/s=input("Choose which spawn to redirect people to") in spawns
		if(!s||s=="Cancel") return
		for(var/obj/Spawn/s2 in RaceSpawns) if(s2.z&&s=="[s2]: [s2.desc]")
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

var/list/ki_field_generators
obj/Ki_Field_Generator
	name="Ki Jammer"
	can_change_icon=0
	makes_toxic_waste=1
	Cost=50000000
	New()
		ki_field_generators ||= list()
		ki_field_generators |= src
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
	icon='radar.dmi'
	Cost=1000000
	Stealable=1
	desc="This radar can be set to detect any item. Click it to equip it and a tab will open showing those items."
	var/Detects
	Can_Drop_With_Suffix=1
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

	verb/Hotbar_use()
		set hidden=1
		Upgrade()

	verb/Upgrade()
		set src in view(1)
		if(usr in view(1,src))
			var/Max_Upgrade = 1.08 * usr.max_turf_upgrade()
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

mob/proc/Choose_Player(T)
	var/list/L=list("Cancel")
	var/mob/P=input(src,T) in L
	if(!P||P=="Cancel") return
	return P

var/list/Bounties = list("Cancel")
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

var/list/bounty_computers
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
		bounty_computers ||= list()
		bounty_computers |= src
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
					var/mob/P=usr.Choose_Player("Choose who you want to place a bounty on")
					if(!P) return
					var/Bounty=input("How much is the bounty you are putting on them? You have [Commas(usr.Res())]$") as num
					if(!P)
						usr<<"The person you wanted to place a bounty on has logged off, this process can not continue"
						return
					if(Bounty>usr.Res()) Bounty=usr.Res()
					if(Bounty<Limits.GetSettingValue("Minimum Bounty"))
						usr<<"The minimum bounty is [Commas(Limits.GetSettingValue("Minimum Bounty"))]$"
						return
					Bounty=round(Bounty)
					usr.Alter_Res(-Bounty)
					Bounty*=0.5

					var/Note=input("Leave a note about this bounty, this could be your alias so people know the bounty is \
					issued by you, or whatever else you want to put.") as text
					if(!P) return

					Apply_Bounty(price=Bounty,bounty_note=Note,the_key=P.key,maker=usr.key,bonus=0)

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

var/list/biogens

obj/Bio_Field_Generator
	icon='Lab.dmi'
	icon_state="Tower 1"
	density=1
	Savable=1
	layer=4
	Cost=50000000
	desc="Periodicly emits a pulse that heals nearby players"
	takes_gradual_damage=1
	var/isEnabled = 1
	
	verb/Bolt()
		set src in oview(1)
		usr.Bolt(src)

	verb/Upgrade()
		set name="Repair/Upgrade health"
		set src in view(1)
		if(usr in view(1,src))
			var/max_health=usr.Knowledge*usr.Intelligence()*2
			if(Health<max_health)
				player_view(15,usr)<<"[usr] repairs/upgrades the [src]'s health to [Commas(max_health)] BP"
				Health=max_health
			else usr<<"The [src] is beyond your upgrading abilities"
	
	proc/Toggle()
		set src in view(1)
		isEnabled = !isEnabled
		player_view(15,usr)<<"[usr.name] turns the bio field generator [isEnabled ? "on" : "off"]."
	
	Click()
		. = ..()
		if(usr in view(1)) Toggle()

	New()
		biogens ||= list()
		biogens |= src
		Bio_Field_Generator()
		var/image/A=image(icon='Lab.dmi',icon_state="Tower 2",pixel_y=32)
		var/image/B=image(icon='Lab.dmi',icon_state="Tower 3",pixel_y=64)
		overlays=null
		if(icon) overlays.Add(A,B)

	proc/Bio_Field_Generator()
		set waitfor=0
		sleep(rand(5,10))
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

					if(isEnabled)
						var/sw
						for(var/mob/m in a.mob_list)
							if(m.client)
								if(m.z==z&&getdist(src,m)<=10)
									if(!sw)
										Make_Shockwave(src,sw_icon_size=512)
										sw=1
									if(m.KO) m.RegainConsciousness()
									if(m.Health<100) m.Health=100
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
		if(usr.adminInfKnowledge)
			Upgrade_Level = Max_Upgrade
			Autopilot=1
			alert("This item has been upgraded to the maximum level.")
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

var/list/telepads
obj/items/Transporter_Pad
	Bolted=1 //bolted by default for convenience
	Cost=1500000
	name="Telepad"
	icon='Transporter Pad.dmi'
	desc="You can use this to teleport yourself between other pads sharing the same remote access code"
	Stealable=1
	Level=1
	takes_gradual_damage=1
	New()
		telepads ||= list()
		telepads |= src
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
		if(usr.cant_move_due_to_hakai)
			usr<<"You can't teleport away while being Hakaid!"
			return
		if(dna_verification&&dna_verification!=usr.Mob_ID)
			player_view(15,usr)<<"[usr]'s telewatch: self destructing, dna verification mismatch"
			Explosion_Graphics(usr,1)
			del(src)
			return
		if(usr.InFinalRealm())
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

		if(usr.IsShielding()) usr.Shield_Revert()
		if(usr.standing_powerup) usr.Stop_Powering_Up()

		var/list/l=list("cancel")
		for(var/mob/m in players) if(m!=usr) for(var/obj/items/Transporter_Watch/t in m.item_list)
			if(t.Password==Password) l+=m
		for(var/obj/items/Transporter_Pad/t in telepads) if(!t.is_on_destroyed_planet())
			if(t.Password==Password&&t.z&&!t.InFinalRealm()) l+=t
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

			if(usr.IsShielding())
				usr << "Teleport signal lost due to shield"
				teleport_failed = 1
				break
			if(usr.standing_powerup)
				usr << "Teleport signal lost due to powering up"
				teleport_failed = 1
				break
			if(usr.cant_move_due_to_hakai)
				usr<<"Teleport canceled due to Hakai!"
				return

			sleep(TickMult(1))
		usr.overlays-='SBombGivePower.dmi'
		usr.overlays-='SBombGivePower.dmi'
		if(ismob(usr.loc)) return
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

	verb/Use() if(usr && !usr.KO) Transport()

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
		var/mob/m
		for(var/mob/p in players)
			if(!m || p.base_bp > m.base_bp) m = p
			sleep(-1)
		if(usr.base_bp < m.base_bp)
			var/bpGain = 600 * (0.7 ** (usr.Fruits_Eaten + 1))
			usr.Attack_Gain(bpGain, apply_hbtc_gains = 0, include_weights = 0, skipBPGains = 1)
			for(var/i in 1 to 10) usr.LeechOpponent(m)
			usr.Fruits_Eaten++
		player_view(15,usr)<<"[usr] eats a [src]"
		del(src)

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
		if(!Mechanics.GetSettingValue("Wells"))
			usr << "Wells are disabled on this server!"
			return

		if(!usr.Disabled() && usr.BPpcnt <= 100)
			if(usr.nextWellUse > usr.base_bp)
				usr << "You have not worked off the power gained from the last use."
				usr << "(Next use at [Commas(usr.nextWellUse)] base BP.)"
				return
			player_view(5,usr)<<"<font color=red>[usr] drinks some water."
			usr << "You feel a surge of potential!  You could probably grow much stronger much faster right now!"
			usr.nextWellUse = usr.base_bp * 4
			usr.wellBoostLimit = usr.base_bp * 2
	
mob/var/nextWellUse = 0
mob/var/wellBoostLimit = 1000

mob/proc/max_weight()
	var/n = base_bp**0.3 * Str
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

		can_scrap = 1

		hotbar_type="Combat item"
		can_hotbar=1
		Savable=0
		can_change_icon = 1
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
			var/cost_per_kilo=round(50/(usr.Intelligence()**0.5))
			var/n=input("How much do you want these weights to weigh? 1 kilo cost [cost_per_kilo] resources. These weights \
			weigh [Commas(weight)] kilos. You are able to lift [Commas(usr.max_weight())] kilos. Making these weigh \
			beyond your max lift will have no effect when you wear them, it will be as if they are at your max.") as num
			if(n<1||n<weight)
				usr<<"You can not make the weights weigh less than they already do."
				return
			var/res_cost=(n*cost_per_kilo)-(weight*cost_per_kilo)
			if(res_cost<0) res_cost=0
			if(usr.Res()<res_cost)
				usr<<"You need at least [Commas(res_cost)]$ to do this."
				return
			player_view(15,usr)<<"[usr.name] upgrades the [src] from [Commas(weight)] to [Commas(n)] kilos in weight."
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

obj/Armor_Icon/Click()
	for(var/obj/A in view(1))
		if(A.Choosing_Icon)
			A.icon=icon

obj/var/Money

obj/items/var/soulbound = 0

mob/proc/MaxItems() //max items you can carry
	var/n = max_items
	return n

obj/items/verb/Drop()
	if(usr.InFinalRealm())
		usr << "You can not drop items in this place"
		return
	if(usr.Redoing_Stats)
		usr << "You can not drop items while redoing stats!"
		return
	if(usr.IsFusion())
		usr << "Fused beings can not drop items!"
		return
	if(soulbound == usr.key)
		usr << "You can not drop soulbound items."
		return
	var/mob/P
	for(P in Get_step(usr,usr.dir)) break
	if(P&&!P.client) P=null
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
	if(istype(src,/obj/items/Equipment))
		if(src:equipped)
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

	if(usr && ismob(usr) && usr.client)
		usr.Restore_hotbar_from_IDs()

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
		clonable=1
		can_change_icon = 1
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

obj/Sword_Icon/Click()
	for(var/obj/A in view(1))
		if(A.Choosing_Icon)
			A.icon=icon

obj/var/Choosing_Icon = 0

obj/items
	Digging
		var/DigMult=1
		Stealable=1
		Savable=0
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
	IncreaseKi(-3*Amount)
	if(Ki<1*Amount)
		Digging=0
		src<<"You stop digging due to exhaustion"
	Amount*=3*(base_bp**0.25)
	if(Amount<1) Amount=1
	for(var/obj/items/Digging/D in item_list) if(D.suffix) Amount*=D.DigMult
	Amount=round(Amount)
	Alter_Res(Amount)

mob/verb/Dig_for_Resources()
	set category = "Skills"

	Digging=!Digging

	if(!Digging)
		src<<"You stop digging for resources"
	else
		src<<"You begin digging for resources (see items tab)"
		Digging(0.5)

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

	if(CheckForInjuries())
		for(var/injury/I in injuries)
			I.remove_at--
			TryRemoveInjury(I)
	RegainConsciousness()
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
		senzus ||= list()
		senzus |= src
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

mob/proc/get_inject(bypass_forced_check)
	var/mob/m=src
	for(var/mob/m2 in Get_step(src,dir)) m=m2
	if(m!=src&&tournament_override(fighters_can=0) && m.client)
		src<<"You can not inject other people at tournaments"
		return
	if(!bypass_forced_check)
		if(m!=src&&m.client&&!Social.GetSettingValue("Forced Injection"))
			src<<"Forced injections on people against their will is disabled on this server"
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

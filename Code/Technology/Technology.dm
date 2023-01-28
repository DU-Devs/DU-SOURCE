var/item_tile_limit = 6 //how many science items you can lay on 1 tile to prevent the crashing bug

mob/proc/TryCreateScienceItem(obj/A)
	if(A in tech_list)
		if(KO) return

		var/turf/base_loc = base_loc()
		var/obstacles = 0
		for(var/obj/obstacle in base_loc) obstacles++
		if(obstacles >= item_tile_limit)
			src << "Try another tile. Too many items here already"
			return

		if(Final_Realm())
			src<<"Items can not be made in the final realm"
			return
		var/turf/t=base_loc()
		if(t&&t.z==10) //hbtc
			if(A.type==/obj/Spawn)
				src<<"Spawns can not be made in the time chamber"
				return
		if(A.type in Illegal_Science)
			src<<"<font size=3><font color=red>Admins have made this item illegal. You can not make it"
			return
		if(Can_Make_Technology(src,A) && GetResourceObject())

			if(A.type==/obj/Ships/Ship&&!Get_ship_interior())
				src<<"There are no more ship interiors available to use for a new ship"
				return

			var/obj/Resources/M = GetResourceObject()
			M.Value-=Item_cost(src,A)
			if(toxic_waste_on&&A.makes_toxic_waste)
				src<<"Toxic waste was created as a byproduct of manufacturing this technology"
				new/obj/Toxic_Waste_Barrel(base_loc)
			var/obj/O=new A.type(base_loc)
			if(O)
				O.Cost=Item_cost(src,A)
				O.Builder=key

				if(istype(O,/obj/Ships/Ship)&&Race=="Puranto")
					O.icon='Puran Ship.dmi'
					CenterIcon(O)
				if(istype(O,/obj/items/Scouter)&&Race=="Human")
					O.icon='Item - Sun Glassess.dmi'
					O.name="Scanner"
				if(istype(O,/obj/Spawn))
					O.Health=100000
					src<<"Don't forget to upgrade the spawn's BP/health by right clicking it"

			spawn if(!O) M.Value+=Item_cost(src,A)

		if(client) winset(src,"mapwindow.map","focus=true")
		if(client) winset(src,"mainwindow.map","focus=true")











obj/var/bankable = 1

mob/proc/Store_item_check(obj/o)
	if(!o||!key) return
	for(var/obj/Bank/bank in Get_step(src,dir))
		if(istype(o,/obj/items/Dragon_Ball))
			src<<"You can not store a Wish Orbs"
			return
		if(!o.bankable)
			src << "This item is unbankable"
			return
		if(!banked_items[key]) banked_items[key]=new/list
		banked_items[key]+=o
		o.Move(loc) //Move(null) doesn't do anything
		o.SafeTeleport(null)
		item_list-=o
		hotbar-=o
		Restore_hotbar_from_IDs()
		src<<"[o] is now stored in the bank"
		return

obj/Bank
	icon='tech.dmi'
	icon_state="compdown"
	Dead_Zone_Immune=1
	Grabbable=0
	Health=1.#INF
	can_blueprint=0
	Cloakable=0
	Knockable=0
	density=1
	Savable=0
	desc="This is the galactic bank. Get next to it and click it to see options or bump into it to \
	see options"
	Click()
		usr.Bank_Options(src)

var/list/bank_list=new
var/list/banked_items=new

mob/Admin4/verb/Clear_banked_items()
	set category="Admin"
	banked_items=new/list
	src<<"All banked items cleared"

mob/proc/Bank_Options(obj/Bank/bank)
	set waitfor=0
	if(!client) return //npcs randomly walking into banks making errors
	if(KB) return
	if(src in view(1,bank))
		if("bank" in active_prompts) return
		active_prompts+="bank"
		last_bank_bump = world.time
		switch(input(src,"This is the bank, what do you want to do?") in list("Cancel","Deposit","Withdraw","Check Balance","Retrieve Item"))
			if("Cancel")
				active_prompts-="bank"
				return
			if("Retrieve Item")
				if(!(key in banked_items))
					alert(src,"You have no items stored")
					active_prompts-="bank"
					return
				while(src)
					var/list/my_banked_items=list("Cancel")
					my_banked_items.Add(banked_items[key])
					var/obj/o=input(src,"Which item do you want to retrieve?") in my_banked_items
					if(!o||o=="Cancel")
						active_prompts-="bank"
						return
					my_banked_items-=o
					my_banked_items-="Cancel"
					o.Move(src)
					banked_items[key]=my_banked_items
					active_prompts-="bank"
					Restore_hotbar_from_IDs()
			if("Deposit")
				if(!(src in view(1,bank)))
					src<<"You must be next to the bank to do this"
					active_prompts-="bank"
					return
				var/n=input(src,"Enter how much resources you want to deposit. You have \
				[Commas(Res())]$") as num
				if(!(src in view(1,bank)))
					src<<"You must be next to the bank to do this"
					active_prompts-="bank"
					return
				n=round(n)
				if(n<0) n=0
				if(n>Res()) n=Res()
				active_prompts-="bank"
				if(!n)
					active_prompts -= "bank"
					return
				bank_list[key]+=n
				Alter_Res(-n)
				player_view(15,src)<<"[src] deposits [Commas(n)] resources into the bank"
				CheckBankFeats()
			if("Withdraw")
				if(!(src in view(1,bank)))
					src<<"You must be next to the bank to do this"
					active_prompts-="bank"
					return
				var/n=input(src,"How much do you want to withdraw? You have [Commas(bank_list[key])]$") as num
				if(n<0) n=0
				if(n>bank_list[key]) n=bank_list[key]
				n=round(n)
				if(!(src in view(1,bank)))
					src<<"You must be next to the bank to do this"
					active_prompts-="bank"
					return
				active_prompts-="bank"
				if(!n)
					return
				Alter_Res(n)
				bank_list[key]-=n
				player_view(15,src)<<"[src] withdraws [Commas(n)] resources from the bank"
			if("Check Balance")
				if(!(src in view(1,bank)))
					src<<"You must be next to the bank to do this"
					active_prompts-="bank"
					return
				active_prompts-="bank"
				alert(src,"You have [Commas(bank_list[key])] resources")
		active_prompts -= "bank"




var/global_res_bags = 0

obj/Resources/var/random_map_resources

proc/Random_resource_drops()
	set waitfor=0
	while(1)
		if(global_res_bags < 500)
			var/turf/t
			while(!t)
				t=locate(rand(1,world.maxx),rand(1,world.maxy),rand(1,world.maxz))
				if(t)
					if(t.type==/turf/Other/Blank||t.density||t.Water) t=null
					else
						var/area/a=locate(/area) in range(0,t)
						if(!a.has_resources) t=null

			for(var/obj/Resource_Destroyer/rd in resource_destroyers) if(rd.z&&rd.destroy_resources)
				var/area/a=locate(/area) in range(0,rd)
				var/area/a2=locate(/area) in range(0,t)
				if(a==a2) t=null

			if(t)
				global_res_bags++
				var/obj/Resources/r = GetCachedObject(/obj/Resources, t)
				r.random_map_resources = 1
				r.Savable=0
				r.Value = rand(300000) * Resource_Multiplier
				if(map_restriction_on) r.Value *= 2
				r.icon = 'Resource Rocks.dmi'
				r.icon_state = "[rand(1,4)]"
				r.density = 1

				if(sagas&&villain_league_member_count)
					r.Value/=1+(villain_league_member_count*0.2)

				r.Update_value()
		sleep(20)



proc/Planet_Resources(N=1)
	N *= Resource_Multiplier
	if(map_restriction_on) N *= 2

	if(villain_league_member_count)
		N/=1+(villain_league_member_count*0.1)

	for(var/area/A in all_areas) if(A.has_resources && !A.Resources_destroyed())
		A.Value += A.resource_refill_mod * N

area/proc/Resources_destroyed()
	for(var/obj/Resource_Destroyer/o in resource_destroyers) if(o.destroy_resources)
		var/area/a=locate(/area) in range(0,o)
		if(a==src) return 1
mob/Admin4/verb/Upgrade_Settings()
	set category="Admin"
	switch(input(src,"You can set the upgrade cap to automatic, or a manual amount. Currently the upgrade cap is \
	[Commas(Tech_BP)].") in list("Cancel","Automatic","Manual"))
		if("Cancel") return
		if("Automatic")
			Automate_Tech_Power=1
			world<<"Upgrade cap set to automatic"
		if("Manual")
			Automate_Tech_Power=0
			var/Amount=input(src,"Set the upgrade cap. Enter 0 to cancel") as num
			if(Amount<=0) return
			Tech_BP=Amount
			world<<"Upgrade cap set to [Commas(Tech_BP)] BP"
var/Automate_Tech_Power=1
var/Tech_BP=100
var/Avg_BP=1
var/Avg_Base=1
var/highest_avg_bp_this_reboot=1

proc/Tech_BP()
	spawn(300) while(1) //average base bp divided by bp mod of all players
		if(Player_Count())
			var/N=0
			for(var/mob/P in players) if(P.era==era_resets) N+=P.base_bp/P.bp_mod
			N/=Player_Count()
			Avg_Base=N
		sleep(600)

	spawn(300) while(1) //average bp of players
		if(Player_Count())
			var/N=0
			for(var/mob/P in players) if(P.era==era_resets) N+=P.get_bp(factor_powerup=0)
			N/=Player_Count()
			Avg_BP=N
			if(Avg_BP>highest_avg_bp_this_reboot) highest_avg_bp_this_reboot=Avg_BP
		sleep(600)

	spawn(300) while(1) //upgrade cap
		var/delay=4
		if(Automate_Tech_Power && world.time>10*600)

			/*var/all_bps=0
			var/players_counted=0
			for(var/mob/m in players) if(m.era==era_resets && !m.cyber_bp && m.Ki<=m.max_ki && m.loc && m.BPpcnt==100)
				if(m.Race!="Frost Lord"||!m.Form)
					if(m.hbtc_bp<m.base_bp)
						var/bp=m.BP
						all_bps+=bp
						players_counted++
			if(players_counted)
				all_bps/=players_counted
				if(Tech_BP<all_bps*1.5) Tech_BP*=1.0025**delay*/

			var/all_relative_bps=0
			var/players_counted=0
			var/highest_bp_mod=1
			for(var/mob/m in players)
				if(m.era == era_resets && !m.cyber_bp && m.loc)
					all_relative_bps += (m.base_bp + m.hbtc_bp) / m.bp_mod
					if(m.bp_mod > highest_bp_mod) highest_bp_mod = m.bp_mod
					players_counted++
			if(players_counted)
				all_relative_bps /= players_counted
				var/goal = all_relative_bps * highest_bp_mod * knowledge_cap_mod
				if(GodOnline()) goal *= min_god_boost //primarily to let androids keep up with god era but also other technology too
				if(Tech_BP < goal) Tech_BP = goal

		sleep(10*delay)

	spawn(3 * 600) while(1) //record highest relative base bp this wipe
		var/mob/m //the strongest player online in relative base bp
		for(var/mob/m2 in players)
			if(!m || m.base_bp / m.bp_mod < m2.base_bp / m2.bp_mod)
				m = m2
		if(m)
			if(highest_base_bp_this_wipe < m.base_bp / m.bp_mod)
				highest_base_bp_this_wipe = m.base_bp / m.bp_mod
				m.GiveFeat("Get Highest Relative Base BP This Wipe")
		sleep(100)

var/highest_base_bp_this_wipe = 0

proc/Avg_Force(N=0)
	if(!Player_Count()) return 1
	for(var/mob/P in players) if(P.client) N+=P.Pow
	return N/Player_Count()

proc/Avg_Res(n=0)
	if(!Player_Count()) return 1
	for(var/mob/m in players) if(m.client) n+=m.Res
	return n/Player_Count()

proc/Avg_Str(n=0)
	if(!Player_Count()) return 1
	for(var/mob/P in players) if(P.client) n+=P.Str
	return n/Player_Count()

proc/Avg_Offense(N=0)
	if(!Player_Count()) return 1
	for(var/mob/P in players) if(P.client) N+=P.Off
	return N/Player_Count()

obj/var/Cost

var/list/tech_list = new

proc/Add_Technology()
	for(var/v in typesof(/obj))
		var/obj/o = new v
		if(o)
			o.referenceObject = 1
			o.suffix = null
			if(o.Cost) tech_list += o
			//else del(o)

	tech_list = SortListOfObjectsAlphabetically(tech_list)

proc/Can_Make_Technology(mob/P,obj/O)
	if(istype(P.get_area(),/area/Braal_Core))
		P<<"Technology can not be made here."
		return
	//for(var/obj/Injuries/Brain/I in P.injury_list)
	if(P.Brain_scrambled())
		P<<"You have a brain injury and therefore cannot make technology"
		return
	if(P.Res()>=Item_cost(P,O)) return 1

proc/Item_cost(mob/P,obj/O)
	var/n=O.Cost
	if(O.type==/obj/Module/Drone_AI && Resource_Multiplier>1) n*=Resource_Multiplier
	if(O.Cost<500000) n/=P.Intelligence()
	else if(O.Cost<5000000) n/=P.Intelligence()**0.6
	else n/=P.Intelligence()**0.3
	n /= P.feat_price_div

	return n

var/list/resources_list=new
mob/var/tmp/obj/Resources/resource_obj

obj/Resources
	icon='Misc.dmi'
	icon_state="ZenniBag"
	can_change_icon=0
	Savable=1
	var/Value=0
	verb/Show_Resources() player_view(15,usr)<<"[usr] shows their bag containing [Commas(Value)] resources"

	New()
		resources_list+=src
		spawn if(ismob(loc))
			var/mob/M=loc
			M.resource_obj=src

	Del()
		if(random_map_resources)
			random_map_resources = 0
			global_res_bags--

		if(ismob(loc)) return //deleting their res bag would permanently bug them. since resources objects are reused we want to make
			//sure no spawned delete code can really delete them once they are put on a player

		. = ..()

	proc/Update_value()
		if(ismob(loc))
			suffix="[Commas(Value)]"
			name="Resources"
		else
			suffix=null
			name="[Commas(Value)] resources"

	verb/Drop()
		var/mob/P
		for(P in Get_step(usr,usr.dir)) break
		if(P&&!P.client) P=null
		var/Money=input("Drop how much Resources? ([Commas(Value)])") as num
		if(Money>Value) Money=Value
		if(Money<=0) usr<<"You must atleast drop 1"
		if(Money>=1)
			Money=round(Money)
			Value-=Money
			var/obj/Resources/A = GetCachedObject(/obj/Resources)
			A.SafeTeleport(usr.loc)
			A.Value=Money
			if(A.Value<250000) A.Savable=0
			A.Update_value()
			A.transform = matrix() * GetResourceBagSize(Money)
			if(!P) player_view(15,usr)<<"<font color=teal>[usr] drops [Commas(A.Value)] resources"
			else player_view(15,usr)<<"<font color=teal>[usr] gives [P] [Commas(A.Value)] resources"
			step(A,usr.dir)
			if(P)
				P.Alter_Res(A.Value)
				del(A)

proc
	GetResourceBagSize(n)
		if(n >= 3000000000) return sqrt(3.5)
		if(n >= 500000000) return sqrt(3)
		if(n >= 150000000) return sqrt(2.5)
		if(n >= 50000000) return sqrt(2)
		if(n >= 10000000) return sqrt(1.5)
		return 1

proc/Resources_Loop()
	set waitfor=0
	while(1)
		var/mod=5
		Planet_Resources(1*mod) //allocate all planets with new resources
		allocate_drills(1*mod) //let drills dig those new resources
		sleep(10*mod)

var/list/drills=new

proc/allocate_drills(max_percent=1)
	drills=shuffle(drills,divider=5)
	for(var/area/a in all_areas) if(a.Value>0)
		for(var/obj/Drill/d in drills) if(a in range(0,d))
			var/amount=d.DrillRate*(max_percent/100)
			if(amount>a.Value) amount=a.Value
			d.Resources+=amount
			a.Value-=amount
			//d.text_overlay(text="<b><font color=[pick("red","green","cyan","yellow")]>+[Commas(amount)]$",\
			timer=9)
			sleep(-1)
			if(a.Value<=0) break //planet out of resources so stop trying to give any to more drills

proc/shuffle(list/orig,var/divider=1)

	if(!orig||!orig.len) return orig

	var/tmp/list/temp = orig.Copy()
	var/i
	for(i=temp.len,i>0,i-=divider)
		temp.Swap(rand(1,temp.len),i)
		//sleep()
	return temp

obj/var/Tech=1

mob/var/tmp/last_drill_click = 0

obj/Drill
	can_change_icon=0
	Cost=30000
	density=1
	var/Resources=0
	var/DrillRate=1000
	var
		drill_drop_res_on_delete = 1
	icon='Drill Giant.dmi'
	desc="Place this at a location and it will automatically drill resources from within the planet. It can not \
	drill if you have it on player built turfs. The more you upgrade this the faster it will drill. Click on it \
	to withdraw what it has drilled."
	takes_gradual_damage=1
	bound_width=64
	layer=4
	New()
		drills+=src
		//spawn Drill()
	Del()
		if(drill_drop_res_on_delete)
			var/obj/Resources/R = GetCachedObject(/obj/Resources, loc)

			//i changed it because there was a resource bug by scrapping drills i think its fixed but to be sure i made it this way instead
			//because im too busy to risk it not being fixed
			//R.Value = (Total_Cost * 0.8) + Resources
			R.Value = Resources

			R.Update_value()
		. = ..()

	proc/Drill()
		set waitfor=0
		sleep(rand(0,300))
		while(src)
			var/percent=1 //percent of total drill value drilled per second
			var/loop_delay=1 //seconds
			for(var/area/planet in range(0,src)) if(planet.Value)
				var/n=(percent/100)*loop_delay*DrillRate
				if(n>planet.Value) n=planet.Value
				Resources+=n
				planet.Value-=n
			sleep(rand(5,15)*loop_delay)

	/*verb/Set_mass_withdraw_code()
		set src in view(1)
		if(usr in view(1,src))
			mass_withdraw_code=input(usr,"Set a code that links all drills with this same code together so \
			that when you withdraw from one you withdraw from them all no matter where they are.") as text*/

	Click()
		//script to spam click drill, lag prevention code
		if(world.time - usr.last_drill_click <= 7)
			return

		if(!usr.KO && (usr in range(1,src)))
			if(usr.client.eye!=usr) return
			player_view(15,src)<<"[usr] withdraws [Commas(Resources)] resources from [src]"
			var/planet_res=0
			for(var/area/a in range(0,src)) planet_res=a.Value
			player_view(15,src)<<"The planet has [Commas(planet_res)] resources remaining"
			var/combined_drill_values=0
			var/area/a=locate(/area) in range(0,src)
			for(var/obj/Drill/d in drills) if(a in range(0,d))
				combined_drill_values+=d.DrillRate
			//var/percent=drill_share(combined_drill_values)
			//percent=round(percent,0.01)
			//player_view(15,src)<<"This drill has a [percent]% share of the planet's resources"
			usr.Alter_Res(Resources)
			Resources=0

	verb/Upgrade()
		set src in view(1)
		for(var/mob/P in range(1,src)) if(P==usr)
			var/obj/Resources/R=usr.GetResourceObject()
			if(!R) return
			if(Health<usr.Knowledge*usr.Intelligence())
				Health=usr.Knowledge*usr.Intelligence()
				player_view(15,usr)<<"[usr] upgrades the drill's health to [Commas(usr.Knowledge*usr.Intelligence())] BP"
			if(!usr.Intelligence()) return
			var/Amount=input(usr,"Input the amount of resources you want to upgrade the drill with. The more \
			you add the faster it will dig. It is currently worth [Commas(DrillRate)]$.") as num
			if(Amount>R.Value) Amount=R.Value
			if(Amount<0) return
			R.Value-=Amount
			Total_Cost+=Amount
			player_view(15,usr)<<"[usr] increases the drills value from [Commas(DrillRate)]$, "
			DrillRate+=Amount * usr.Intelligence()**0.4
			desc="Value: [Commas(DrillRate)]$"
			player_view(15,usr)<<"to [Commas(DrillRate)]$."
			suffix="[Commas(DrillRate)]$"
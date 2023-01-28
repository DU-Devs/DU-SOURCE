mob/proc/Store_item_check(obj/o)
	if(!o||!key) return
	for(var/obj/Bank/bank in Get_step(src,dir))
		if(istype(o,/obj/items/Dragon_Ball))
			src<<"You can not store a dragon ball"
			return
		if(istype(o,/obj/items/Shikon_Jewel))
			src<<"You can not store a shikon jewel"
			return
		if(!banked_items[key]) banked_items[key]=new/list
		banked_items[key]+=o
		o.Move(loc) //Move(null) doesn't do anything
		o.loc=null
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
	if(!client) return //npcs randomly walking into banks making errors
	if(KB) return
	if(src in view(1,bank))
		if("bank" in active_prompts) return
		active_prompts+="bank"
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
				if(!n) return
				bank_list[key]+=n
				Alter_Res(-n)
				player_view(15,src)<<"[src] deposits [Commas(n)] resources into the bank"
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
				if(!n) return
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





proc/Random_resource_drops() spawn while(1)
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
		var/obj/Resources/r=new(t)
		r.Savable=0
		r.Value=rand(400000,600000)*Resource_Multiplier

		if(sagas&&villain_league_member_count&&server_mode=="PVP")
			r.Value/=1+(villain_league_member_count*0.2)

		r.Update_value()
		Timed_Delete(r,2*60*60*10)
	sleep(1200)



proc/Planet_Resources(N=1)
	N*=Resource_Multiplier

	if(villain_league_member_count&&server_mode=="PVP")
		N/=1+(villain_league_member_count*0.1)

	for(var/area/A in all_areas) if(A.has_resources&&!A.Resources_destroyed())
		A.Value+=A.resource_refill_mod*N

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
				if(m.Race!="Icer"||!m.Form)
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
				if(m.era==era_resets && !m.cyber_bp && m.loc)
					all_relative_bps+=(m.base_bp+m.hbtc_bp)/m.bp_mod
					if(m.bp_mod>highest_bp_mod) highest_bp_mod=m.bp_mod
					players_counted++
			if(players_counted)
				all_relative_bps/=players_counted
				var/goal=all_relative_bps * highest_bp_mod * knowledge_cap_mod
				if(Tech_BP<goal) Tech_BP=goal

		sleep(10*delay)

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
var/list/Technology_List=new

proc/Add_Technology()
	for(var/V in typesof(/obj))
		var/obj/B=new V
		if(B)
			B.suffix=null
			if(B.Cost) Technology_List+=B
			else del(B)

proc/Can_Make_Technology(mob/P,obj/O)
	if(istype(P.get_area(),/area/Vegeta_Core))
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
	if(O.Cost<500000) n/=P.Intelligence
	else if(O.Cost<5000000) n/=P.Intelligence**0.6
	else n/=P.Intelligence**0.3
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
			var/obj/Resources/A=new
			A.loc=usr.loc
			A.Value=Money
			if(A.Value<250000) A.Savable=0
			A.Update_value()
			if(!P) player_view(15,usr)<<"<font size=1><font color=teal>[usr] drops [Commas(A.Value)] resources"
			else player_view(15,usr)<<"<font size=1><font color=teal>[usr] gives [P] [Commas(A.Value)] resources"
			step(A,usr.dir)
			if(P)
				P.Alter_Res(A.Value)
				del(A)

proc/Resources_Loop() spawn while(1)
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

obj/Drill
	can_change_icon=0
	Cost=30000
	density=1
	var/Resources=0
	var/DrillRate=1000
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
		var/obj/Resources/R=new(loc)
		R.Value=(Total_Cost*0.8)+Resources
		R.Update_value()
		..()
	proc/Drill() spawn(rand(0,300)) while(src)
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
	Click() if(!usr.KO) if(usr in range(1,src))
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
			var/obj/Resources/R=usr.resource_obj
			if(!R) return
			if(Health<usr.Knowledge*usr.Intelligence)
				Health=usr.Knowledge*usr.Intelligence
				player_view(15,usr)<<"[usr] upgrades the drill's health to [Commas(usr.Knowledge*usr.Intelligence)] BP"
			if(!usr.Intelligence) return
			var/Amount=input(usr,"Input the amount of resources you want to upgrade the drill with. The more \
			you add the faster it will dig. It is currently worth [Commas(DrillRate)]$.") as num
			if(Amount>R.Value) Amount=R.Value
			if(Amount<0) return
			R.Value-=Amount
			Total_Cost+=Amount
			player_view(15,usr)<<"[usr] increases the drills value from [Commas(DrillRate)]$, "
			DrillRate+=Amount * usr.Intelligence**0.4
			desc="Value: [Commas(DrillRate)]$"
			player_view(15,usr)<<"to [Commas(DrillRate)]$."
			suffix="[Commas(DrillRate)]$"
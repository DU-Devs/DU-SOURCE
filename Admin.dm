//this is to fix a bug that i dont know the cause of where blank mobs accumulate endlessly and cause lag. they go away on reboot
//they all have xyz: 0,0,0. loc: . icon: .
proc/Delete_blank_mobs_loop() spawn
	var/t=30*60*10
	sleep(t)
	while(1)
		var/c=0
		for(var/mob/m) if(m.name=="mob")
			c++
			del(m)
		Tens("[c] blank mobs deleted")
		sleep(t)

var/announce_dragon_balls
mob/Admin4/verb/Toggle_announce_when_dbs_activate()
	set category="Admin"
	announce_dragon_balls=!announce_dragon_balls
	if(announce_dragon_balls) src<<"When the dragon balls activate it will now be announced to everyone"
	else src<<"When the dragon balls activate it will NOT be announced"

var/knowledge_cap_mod=1
mob/Admin4/verb/Set_knowledge_cap_mod()
	set category="Admin"
	knowledge_cap_mod=input(src,"Set the knowledge cap mod for how fast the knowledge cap will rise on the server",\
	"Options",knowledge_cap_mod) as num
	knowledge_cap_mod=Clamp(knowledge_cap_mod,0,999)

var/lose_resources_on_logout=1
mob/Admin4/verb/Toggle_lose_resources_while_logged_out()
	set category="Admin"
	lose_resources_on_logout=!lose_resources_on_logout
	if(lose_resources_on_logout) src<<"Players will now gradually lose resources while logged out unless they bank it"
	else src<<"Players will no longer lose resources gradually while logged out"

var/doors_kill=1
mob/Admin4/verb/Toggle_door_killing()
	set category="Admin"
	doors_kill=!doors_kill
	if(doors_kill) src<<"Doors now kill people"
	else src<<"Doors no longer kill people"

var/drop_items_on_death=1
mob/Admin4/verb/Toggle_drop_items_on_death()
	set category="Admin"
	drop_items_on_death=!drop_items_on_death
	if(drop_items_on_death) src<<"People will now drop their items on death"
	else src<<"People will no longer drop their items on death"


mob/Admin5/verb/Common_types_test()
	set category="Admin"
	var/list/types=new
	for(var/obj/a)
		if(!(initial(a.name) in types)) types[initial(a.name)]=1
		else types[initial(a.name)]++
	src<<"All object counts:"
	var/total=0
	for(var/v in types) if(types[v]>=100)
		src<<"[v] = [types[v]]"
		total+=types[v]
	src<<"Total objects: [total]"

	total=0
	for(var/mob/m) total++
	src<<"Total mobs: [total]"



var/can_ignore_SI=1
mob/Admin4/verb/Toggle_ignore_SI()
	set category="Admin"
	can_ignore_SI=!can_ignore_SI
	if(can_ignore_SI) src<<"Players can now ignore SI"
	else src<<"Players can no longer ignore SI"

var/allow_guests=1
mob/Admin4/verb/Toggle_guests()
	set category="Admin"
	allow_guests=!allow_guests
	if(allow_guests)
		src<<"Guests are now allowed to be on this server"
	else
		src<<"Guests are no longer allowed on this server"
		for(var/mob/m in players) if(findtext(m.key,"guest")) del(m)

mob/Admin4/verb/Make_dragon_balls_active_now()
	set category="Admin"
	src<<"This can take up to 1 minute to take effect because dragon ball activation is on a loop"
	for(var/obj/items/Dragon_Ball/db in dragon_balls) db.next_enable=0

var/server_mode="PVP"
mob/Admin4/verb/Toggle_pvp_or_rp_mode()
	set category="Admin"
	if(server_mode=="RP")
		server_mode="PVP"
		src<<"The server is now in PVP mode"
	else
		server_mode="RP"
		src<<"The server is now in RP mode"

var/bp_soft_cap=0
mob/Admin4/verb/BP_soft_cap()
	set category="Admin"
	bp_soft_cap=input(usr,"You can set a soft cap for bp gains so that people's gains will slow down the closer \
	to this amount they become. Put it at 0 to turn it off. This is multiplied by their bp mod so if it was a Saiyan \
	with 2x bp mod and the soft cap is 1000, then for Saiyans it is 2000. Currently at [Commas(bp_soft_cap)]",\
	"Options",bp_soft_cap) as num

var/inspire_allowed=1
mob/Admin4/verb/Toggle_ssj_inspire()
	set category="Admin"
	inspire_allowed=!inspire_allowed
	if(inspire_allowed) src<<"Getting Super Saiyan thru inspiration is now allowed"
	else src<<"Getting Super Saiyan thru inspiration is now not allowed"

var/death_anger_gives_ssj=1
mob/Admin4/verb/Toggle_death_anger_gives_ssj()
	set category="Admin"
	death_anger_gives_ssj=!death_anger_gives_ssj
	if(death_anger_gives_ssj) src<<"Death anger can now give super saiyan"
	else src<<"Death anger can no longer give super saiyan"

mob/Admin5/verb/Zombie_info()
	set category="Admin"
	var/regular=0
	var/mutated=0
	for(var/mob/Enemy/Zombie/z in active_zombie_list)
		if(z.Level==initial(z.Level)) regular++
		else mutated++
	src<<"Regular zombies: [regular]<br>\
	Mutated zombies: [mutated]<br>\
	Total zombies: [regular+mutated]"

mob/Admin4/verb/Zombie_locs()
	set category="Admin"
	var/list/l=new
	var/total=0
	for(var/mob/z in active_zombie_list)
		total++
		if(z.z)
			var/area/a=locate(/area) in range(0,z)
			if(!(a.name in l)) l[a.name]=1
			else l[a.name]=l[a.name]+1
	for(var/a in l) src<<"[l[a]] zombies at [a]"
	src<<"Total Zombies: [total]"


var/incline_on
mob/Admin4/verb/Toggle_incline()
	set category="Admin"
	incline_on=!incline_on
	if(incline_on)
		src<<"Incline is now on. This means a person will gradually increase in power as they \
		grow up"
	else
		src<<"Incline is now off"

mob/Admin4/verb/Set_minimum_bounty()
	set category="Admin"
	minimum_bounty=input(src,"Set the minimum cost to place a bounty on someone. It is currently \
	[Commas(minimum_bounty)] resources.","Options",minimum_bounty) as num

var
	skill_tournament_bp_boost=0
mob/Admin4/verb/Set_skill_tournament_bp_boost()
	set category="Admin"
	skill_tournament_bp_boost=input(src,"Set the multiplier for what sort of bp boost a fighter in a \
	skill tournament will receive for each new stage of the tournament that they make it to","Options",\
	skill_tournament_bp_boost) as num

var/max_buff_bp=1.5
mob/Admin4/verb/Max_custom_buff_bp_mult()
	set category="Admin"
	max_buff_bp=input(src,"What is the maximum modifier for bp a custom buff can reach?","Options",\
	max_buff_bp) as num


var/allow_diagonal_movement=1
mob/Admin4/verb/Toggle_diagonal_movement()
	set category="Admin"
	allow_diagonal_movement=!allow_diagonal_movement
	if(allow_diagonal_movement) src<<"Diagonal movements are now allowed"
	else src<<"Diagonal movements are now disabled"


var
	pwipe_vote_year=50
	pwipe_vote_bp=100000000
mob/Admin4/verb/Pwipe_vote_settings()
	set category="Admin"
	pwipe_vote_year=input(src,"What year will pwipe votes become allowed?","Options",pwipe_vote_year) as num
	pwipe_vote_bp=input(src,"What average BP of the server is required for pwipe votes to become \
	allowed?","Options",pwipe_vote_bp) as num


var/alt_limit=2
mob/Admin4/verb/Set_alt_limit()
	set category="Admin"
	alt_limit=input(src,"Set the maximum number of characters a person can have logged on at once",\
	"Options",alt_limit) as num

var/energy_cap=0
mob/Admin5/verb/Set_energy_cap()
	set category="Admin"
	energy_cap=input(src,"Set a cap for how much energy a person can have (times energy mod)","Options",\
	energy_cap) as num

mob/Admin2/verb/Show_relative_base_bps()
	set category="Admin"
	for(var/mob/m in players) src<<"[m] has [Commas(m.base_bp/m.bp_mod)] relative base bp"

var/meteor_density=1
mob/Admin4/verb/Meteor_density()
	set category="Admin"
	meteor_density=input(src,"Set the multiplier for how many meteors there will be in space","Options",\
	meteor_density) as num

var/percent_of_wall_breakers=100
mob/Admin4/verb/Set_percent_of_people_that_can_break_walls()
	set category="Admin"
	percent_of_wall_breakers=input(src,"Set the percent of people that are capable of breaking walls. \
	If you enter 5 for example only the top 5% strongest players (in base_bp+hbtc_bp) can break walls, and the \
	other 95% of players can't, even if they somehow power up to INFINITE bp.","Options",\
	percent_of_wall_breakers) as num

var/wall_INT_scaling=0.1
mob/Admin4/verb/Set_wall_INT_scaling()
	set category="Admin"
	wall_INT_scaling=input(src,"Set the exponent that determines intelligence's affect on how high \
	someone can upgrade their walls. How it works is: wall_health = wall_heath * intelligence^exponent. \
	So if you entered 1 as the exponent, 2x intelligence would mean 2x stronger walls, 3x = 3x, and so \
	on. But 0.5 would mean 2x intelligence = 1.4x stronger walls. 2 exponent would mean 2x = 4x, \
	3x = 9x","Options",wall_INT_scaling) as num


var/death_cures_vampires=1
mob/Admin4/verb/Toggle_death_cures_vampires()
	set category="Admin"
	death_cures_vampires=!death_cures_vampires
	if(death_cures_vampires) src<<"Death will now revert vampires to normal"
	else src<<"Death will no longer revert vampires to normal"

var
	offline_gains=1

mob/Admin4/verb/Toggle_offline_gains()
	set category="Admin"
	offline_gains=!offline_gains
	if(offline_gains) src<<"Offline gains are now on. How this works is: If the average BP is 5000 and some guy has 500 BP, he is in the \
	bottom 10%, if offline gains are off and he logs out and when he comes back the average is 50,000, he is still 500 BP, making him the \
	bottom 1%. With offline gains he would log in at 5000 BP, maintaining his relative position on the power ladder compared to everyone \
	else, and still be in the bottom 10%. If someone was 4500 BP putting them in the top 10% then they log off and the average goes to \
	50,000 they will come back with 45,000, which is the same relative position they had before."
	else src<<"Offline gains are now off"

mob
	var
		offline_gains_info=0
		offline_int_gains_info=0
	proc
		Record_offline_gains()
			var/n=0

			/*var/players_counted=0
			for(var/mob/m in players) if(m.client)
				//if((m.base_bp+m.hbtc_bp)/m.bp_mod>n) n=(m.base_bp+m.hbtc_bp)/m.bp_mod
				n+=m.base_bp/m.bp_mod
				players_counted++
			if(!n||!players_counted) return
			n/=players_counted*/

			for(var/mob/m in players) if(m.client)
				if((m.base_bp+m.hbtc_bp)/m.bp_mod>n) n=(m.base_bp+m.hbtc_bp)/m.bp_mod

			if(offline_gains_info<n)
				offline_gains_info=n
			if(offline_int_gains_info<Tech_BP) offline_int_gains_info=Tech_BP
		Apply_offline_gains()

			if(world.time<10*60*10) return
			if(!offline_gains||!offline_gains_info) return

			var/n=0

			/*var/players_counted=0
			for(var/mob/m in players) if(m.client)
				//if((m.base_bp+m.hbtc_bp)/m.bp_mod>n) n=(m.base_bp+m.hbtc_bp)/m.bp_mod
				n+=m.base_bp/m.bp_mod
				players_counted++
			n/=players_counted*/

			for(var/mob/m in players) if(m.client)
				if((m.base_bp+m.hbtc_bp)/m.bp_mod>n) n=(m.base_bp+m.hbtc_bp)/m.bp_mod

			if(n<offline_gains_info) return

			n=Get_offline_gains_multiplier(offline_gains_info,n)
			if(highest_relative_base_bp && (base_bp/bp_mod)*n>highest_relative_base_bp)
				n=highest_relative_base_bp / (base_bp/bp_mod)
			var/old_base_bp=base_bp
			base_bp*=n
			hbtc_bp-=(base_bp-old_base_bp) * 0.75
			if(hbtc_bp<0) hbtc_bp=0
			//hbtc_bp*=n

			if(offline_int_gains_info&&offline_int_gains_info<Tech_BP)
				var/int_mult=Get_offline_gains_multiplier(offline_int_gains_info,Tech_BP)
				Knowledge*=int_mult
				if(Knowledge>Tech_BP) Knowledge=Tech_BP

			Record_offline_gains()
		Get_offline_gains_multiplier(old_bp=1,new_bp=1)

			var/exponent=1

			var/n=(new_bp/old_bp)**exponent
			//if(n>5) n=5
			return n
	verb
		bpthing()
			set hidden=1
			var/highest_bp=input("Set the strongest person's hypothetical bp") as num
			var/your_bp=input("Set your hypothetical bp") as num
			var/new_highest_bp=input("Ok so you logged off for however long, then you came back, what is \
			the new strongest person's bp on the server?") as num
			if(your_bp>highest_bp) your_bp=highest_bp
			if(new_highest_bp<highest_bp) new_highest_bp=highest_bp
			src<<"\
			*before logging out*<br>\
			your bp: [Commas(your_bp)]<br>\
			strongest bp: [Commas(highest_bp)]<br>"
			var/new_bp=your_bp*Get_offline_gains_multiplier(highest_bp,new_highest_bp)
			src<<"\
			*after coming back*<br>\
			new strongest bp: [Commas(new_highest_bp)] ([round(new_highest_bp/highest_bp,0.01)]x higher)<br>\
			your new bp: [Commas(new_bp)] ([round(new_bp/your_bp,0.01)]x higher)"

mob/Admin4/verb/Who_is_zombie_infected()
	set category="Admin"
	for(var/mob/m in players) if(m.Zombie_Virus) src<<"[m] is infected x[round(m.Zombie_Virus)]"

var/im_trapped_allowed=1
mob/Admin4/verb/toggle_im_trapped()
	set category="Admin"
	im_trapped_allowed=!im_trapped_allowed
	if(im_trapped_allowed) src<<"Players can now use 'im trapped'"
	else src<<"Players can no longer use 'im trapped'"

var/forced_injections=0
mob/Admin4/verb/toggle_forced_injections()
	set category="Admin"
	forced_injections=!forced_injections
	if(forced_injections) src<<"Forced injections are now allowed"
	else src<<"Forced injections are now NOT allowed"

var/adapt_mod=1
mob/Admin4/verb/set_server_leech_mod()
	set category="Admin"
	adapt_mod=input(usr,"Set the server's leech modifier","options",adapt_mod) as num

var/npcs_give_hbtc_keys=1
mob/Admin4/verb/toggle_npcs_give_hbtc_keys()
	set category="Admin"
	npcs_give_hbtc_keys=!npcs_give_hbtc_keys
	if(npcs_give_hbtc_keys) src<<"NPCs on earth now have a chance to drop time chamber keys"
	else src<<"NPCs on earth no longer drop time chamber keys"

var/hero_training_gives_tier
mob/Admin4/verb/hero_training_gives_tier()
	hero_training_gives_tier=!hero_training_gives_tier
	if(hero_training_gives_tier) src<<"Hero training will now grant the hero a tier instead of letting \
	them gain bp"
	else src<<"The hero will now gain actual bp during their training period, not an extra tier."
var/gain_tier_from_tournament
mob/Admin4/verb/gain_tier_from_tournament()
	gain_tier_from_tournament=!gain_tier_from_tournament
	if(gain_tier_from_tournament) src<<"The winner of the tournament will now gain an extra tier"
	else src<<"The winner of the tournament no longer gets a tier"

mob/Admin3/verb/IPs()
	set category="Admin"
	for(var/mob/m in players)
		src<<"[m.key]: [m.client.address]"

var/bp_tiers
mob/var/bp_tier=1
mob/Admin4/verb/enable_bp_tiers()
	set category="Admin"
	bp_tiers=!bp_tiers
	if(bp_tiers) src<<"bp tiers are now on"
	else src<<"bp tiers are now off"
mob/Admin5/verb/show_tiers()
	set category="Admin"
	var/list/tiers=new
	for(var/mob/m in players) if(m.z) tiers+=m.bp_tier
	var/tier=1
	while(1)
		var/amount=0
		for(var/v in tiers) if(v==tier) amount++
		src<<"tier [tier]s: [amount]"
		tier++
		if(tier>3) return
mob/proc/give_tier(mob/m)
	if(alignment_on&&both_good(src,m)) return //good cant take tiers from good
	if(!bp_tiers||!ismob(m)||!m.client||m.bp_tier>=bp_tier) return
	m<<"<font color=cyan>You were raised to tier [bp_tier]"
	var/tier=bp_tier
	bp_tier=m.bp_tier
	m.bp_tier=tier
mob/proc/get_tier()
	if(world.time<1200) return
	var/max_tier=1
	var/tier2s=0
	var/tier3s=0
	var/tier4s=0
	for(var/mob/m in players) if(m.z)
		if(m.bp_tier==2) tier2s++
		if(m.bp_tier==3) tier3s++
		if(m.bp_tier==4) tier4s++
	if(tier2s/unique_player_count()<0.2) max_tier=2
	if(tier3s/unique_player_count()<0.1) max_tier=3
	if(tier4s/unique_player_count()<0.04) max_tier=4
	if(bp_tier<max_tier) bp_tier=max_tier
proc/unique_player_count()
	var/n=0
	var/list/unique_players=new
	for(var/mob/m in players) if(m.client&&m.z)
		unique_players+=m
		for(var/mob/alt in unique_players) if(alt!=m&&alt.client.address==m.client.address)
			unique_players-=m
	for(var/mob/m in unique_players) n++
	if(n<1) n=1
	return n


mob/Admin1/verb/where_is_everyone()
	set category="Admin"
	for(var/area/a in all_areas)
		var/n=0
		for(var/mob/m in a) if(m.client) n++
		src<<"[n] players on [a]"

var/skill_tournament_chance=33
mob/Admin4/verb/set_skill_tournament_chance()
	set category="Admin"
	skill_tournament_chance=input(src,"set the probability that a tournament will be a skill tournament",\
	"options",skill_tournament_chance) as num

var/max_Saiyan_percent=100
mob/Admin4/verb/max_Saiyan_percent()
	set category="Admin"
	max_Saiyan_percent=input(src,"enter the max percentage of players that can be Saiyan before the Saiyan \
	choice disappears from the race selection.","options",max_Saiyan_percent) as num

var/ssj_voting
mob/Admin4/verb/allow_ssj_votes()
	set category="Admin"
	ssj_voting=!ssj_voting
	if(ssj_voting) src<<"ssj voting is now allowed"
	else src<<"ssj voting is now disabled"

var/alts="allowed"
mob/Admin4/verb/alt_settings()
	set category="Admin"
	switch(alert(src,"select an option for how alts are handled","options","allowed","disallowed",\
	"allowed only if seperate computers"))
		if("allowed") alts="allowed"
		if("disallowed") alts="disallowed"
		if("allowed only if seperate computers") alts="allowed only if seperate computers"

mob/Admin4/verb/set_melee_power()
	set category="Admin"
	melee_power=input(src,"set the multiplier for how much damage melee does","options",melee_power) as num
mob/Admin4/verb/set_ki_power()
	set category="Admin"
	ki_power=input(src,"set the multiplier for how much damage ki does","options",ki_power) as num

var/strongest_bp_gain_penalty=1
mob/Admin4/verb/Set_strongest_persons_bp_gain_penalty()
	set category="Admin"
	strongest_bp_gain_penalty=input(src,"Input a number that represents how much the the strongest person's \
	bp gains get divided compared to everyone else's. If you enter 2 for example then the person with \
	the strongest bp will gain bp half as fast as everyone else.","options",strongest_bp_gain_penalty) as num

var/leech_strongest=0
var/max_auto_leech=100
mob/Admin4/verb/Set_BP_Leeching_of_Strongest_Person()
	set category="Admin"
	leech_strongest=input(src,"You have enabled a feature that causes players to leech the base bp \
	of the strongest person online by simply doing normal training. Now input a multiplier for how \
	fast this effect will be. This is mostly for servers where people are meant to catch up very \
	fast with very little grind and be viable quickly. Set it to 0 to disable it","options",\
	leech_strongest) as num
	max_auto_leech=input(src,"Now set the max percent that people can auto leech of the strongest person's \
	base bp. 100% means they can auto leech all of it. 50% is half, etc.","options",max_auto_leech) as num


mob/Admin1/verb/PlayerLogs(mob/M in players)
	set category="Admin"
	var/View={"{"<html>
	<head><title></head></title><body>
	<body bgcolor="#000000"><font size=6><font color="#0099FF"><b><i>
	<font color="#00FFFF">**[M]'s Logged Activities**<br><font size=4>
	</body><html>"}
	var/XXX=file("Logs/ChatLogs/[M.ckey]Current.html")
	if(fexists(XXX))
		var/list/File_List=list("Cancel")
		for(var/File in flist("Logs/ChatLogs/[M.ckey]")) File_List+=File
		if(src)
			var/File=input(src,"Which log do you want to view?") in File_List
			if(!File||File=="Cancel") return
			var/ISF=file2text(file("Logs/ChatLogs/[File]"))
			View+=ISF
			View+=M.unwritten_chatlogs
			usr<<"Viewing [File]"
			usr<<browse(View,"window=Log;size=800x600")
	else
		usr<<"No logs found for [M.ckey]"


var/cyber_bp_mod=1
mob/Admin4/verb/cyber_bp_modifier()
	set category="Admin"
	cyber_bp_mod=input(src,"change the multiplier for how effective cyber bp is on this server, between \
	0.3 and 2","options",cyber_bp_mod) as num
	if(cyber_bp_mod>2) cyber_bp_mod=2
	if(cyber_bp_mod<0.3) cyber_bp_mod=0.3
	Log(src,"[key] set the cyber bp mod to [cyber_bp_mod]x")


var/allow_age_choosing
mob/Admin4/verb/allow_age_choosing()
	set category="Admin"
	allow_age_choosing=!allow_age_choosing
	if(allow_age_choosing) src<<"choosing age at creation is now allowed"
	else src<<"choosing age at creation is now not allowed"


var/max_gravity=500
mob/Admin4/verb/max_gravity()
	set category="Admin"
	max_gravity=input(src,"set the max upgrade of gravity machines","options",max_gravity) as num
	if(max_gravity<1) max_gravity=1


mob/Admin1/verb/whos_in_safezone()
	set category="Admin"
	var/n=0
	for(var/mob/m in players) if(m.Safezone) n++
	src<<"[n] out of [Player_Count()] players are currently in a safezone"


var/death_setting="default"
mob/Admin4/verb/death_settings()
	set category="Admin"
	death_setting=input(src,"Choose the death setting for this server") in list("Cancel","Default",\
	"Rebirth upon death")
	switch(death_setting)
		if("Default") src<<"Default mode chosen"
		if("Rebirth upon death") src<<"Rebirth upon death means nobody actually 'dies', as in, they don't \
		ever go to afterlife or have a halo, they are just instantly reincarnated"

var/reincarnation_loss=0.01
var/reincarnation_recovery=1 //how fast you reach your full potential again
mob/var/available_potential=1
mob/Admin4/verb/Set_Reincarnation_Loss()
	set category="Admin"
	var/n=input(src,"Set what percent of BP a person will fall to when reincarnated (1-100)",\
	"Options",reincarnation_loss*100) as num
	if(n<1) n=1
	if(n>100) n=100
	reincarnation_loss=n/100
	n=input(src,"Now, set how fast they will reach 100% potential again thru training","options",\
	reincarnation_recovery) as num
	if(n<0.01) n=0.01
	if(n>100) n=100
	reincarnation_recovery=n

var/Max_Zombies=500
mob/Admin4/verb/Set_Max_Zombies()
	set category="Admin"
	Max_Zombies=input(src,"Set the maximum amount of zombies that can exist","Options",Max_Zombies) as num
	if(Max_Zombies<0) Max_Zombies=0
	Max_Zombies=round(Max_Zombies)

var/Max_Players=0
mob/Admin4/verb/Set_Max_Players()
	set category="Admin"
	Max_Players=input(src,"Set the maximum amount of players that can be logged in at once. This is mostly \
	for servers that can only handle a small amount of players. 0 means no limit.","Options",Max_Players) as num
	if(Max_Players<0) Max_Players=0
	Max_Players=round(Max_Players)

mob/Admin1/verb/Add_Log_Note()
	set category="Admin"
	var/T=input(src,"What note do you want to add to the admin logs?") as text|null
	if(!T||T=="") return
	Log(src,T)

var/ssj_easy
mob/Admin4/verb/SSj_Settings()
	set category="Admin"
	ssj_easy=!ssj_easy
	if(ssj_easy) src<<"Any Saiyan can get Super Saiyan by death anger now instead of just the first Super Saiyan"
	else src<<"Only the first Super Saiyan can get Super Saiyan thru anger now"


var/SSj_Mastery=1
mob/Admin4/verb/SSj_Mastery_Rate()
	set category="Admin"
	SSj_Mastery=input(src,"Enter the multiplier for how fast people will master Super Saiyan","Options",SSj_Mastery) as num


var/Server_Regeneration=1
mob/Admin4/verb/Regen_Rate()
	set category="Admin"
	Server_Regeneration=input(src,"Set the server multiplier for everyone's health regeneration","Options",\
	Server_Regeneration) as num
var/Server_Recovery=1
mob/Admin4/verb/Recov_Rate()
	set category="Admin"
	Server_Recovery=input(src,"Set the server multiplier for everyone's energy recovery","Options",Server_Recovery) as num


var/KO_Time=1
mob/Admin4/verb/Change_KO_Time()
	set category="Admin"
	KO_Time=input(src,"Here you can change the multiplier for how long people are knocked out","Options",KO_Time) as num
	if(KO_Time<0) KO_Time=0


var/Safezones
var/Safezone_Distance=20
mob/Admin4/verb/Enable_Safezones()
	set category="Admin"
	Safezones=!Safezones
	if(Safezones)
		Safezone_Distance=input(src,"How far away from the spawns do safezones extend?","Options",Safezone_Distance) as num
		world<<"<font color=yellow>[key] has enabled safezones. Meaning nobody can die as long as they stay \
		within [Safezone_Distance] tiles of a spawn point"
	else world<<"<font color=yellow>[key] has disabled safezones at spawn points."
mob/proc/Safezone()
	if(Safezones&&Safezone&&(locate(/obj/items/Dragon_Ball) in item_list))
		Safezone=0
		src<<"People with dragon balls are not safe in the safezone"
		return
	if(client&&Safezones) for(var/obj/Spawn/S in Spawn_List) if(S.z==z&&getdist(src,S)<=Safezone_Distance)
		Safezone=1
		return
	Safezone=0


proc/Is_NPC_Drone(mob/M) if(!M.client) for(var/obj/Module/Drone_AI/D in M.active_modules) if(D.suffix) return 1
mob/Admin4/verb/Destroy_All_of_Type(atom/movable/O in world)
	set category="Admin"
	Log(src,"[key] destroyed all [O.type]'s")
	if(ismob(O)&&Is_NPC_Drone(O)) for(var/mob/M) if(Is_NPC_Drone(M) && M.z) del(M)
	else
		for(var/atom/movable/M) if(M.type==O.type&&M!=O)
			if(!(M in Technology_List)&&!(M.type in Illegal_Science))
				del(M)
		if(!(O in Technology_List)&&!(O.type in Illegal_Science)) del(O)


proc/Mute_Check() spawn while(1)
	for(var/V in Mutes) if(world.realtime>=Mutes[V])
		world<<"<font color=yellow>The mute on [V] has expired"
		Mutes-=V
	sleep(600)


var/Tournament_Prize=1
mob/Admin4/verb/Modify_Tournament_Prize()
	set category="Admin"
	Tournament_Prize=input(src,"Set the multiplier for the amount of resources recieved in tournaments","Options",\
	Tournament_Prize) as num
	if(Tournament_Prize<0) Tournament_Prize=0


mob/Admin5/verb/Cure_Zombie_Infection()
	set category="Admin"
	for(var/mob/P in players) P.Zombie_Virus=0


var/Train_Disabled
mob/Admin4/verb/Disable_Train_Verb()
	set category="Admin"
	Train_Disabled=!Train_Disabled
	if(Train_Disabled) for(var/mob/P in players)
		P<<"Admins have disabled the train verb"
		P.verbs-=/mob/verb/Train_verb
	else for(var/mob/P in players)
		P<<"Admins have enabled the train verb"
		P.verbs+=/mob/verb/Train_verb
var/Learn_Disabled
mob/Admin4/verb/Disable_Learn_Verb()
	set category="Admin"
	Learn_Disabled=!Learn_Disabled
	if(Learn_Disabled) for(var/mob/P in players)
		P<<"Admins have disabled the learn verb"
		P.verbs-=/mob/verb/Learn
	else for(var/mob/P in players)
		P<<"Admins have enabled the learn verb"
		P.verbs+=/mob/verb/Learn


mob/var/See_Logins

mob/Admin1/verb/See_Logins_Toggle()
	set category="Admin"
	See_Logins=!See_Logins
	if(See_Logins) src<<"You will now see log ins/outs"
	else src<<"You will not see log ins/outs"

mob/var
	comp_id
	ip_address

mob/proc/Admin_Login_Message() if(client&&client.computer_id!="1768931727")
	comp_id=client.computer_id
	ip_address=client.address
	for(var/mob/P in players) if(P.Is_Admin()&&P.See_Logins)
		P<<"<font color = #007700><small>LOGIN: [name]([key]) CID: [client.computer_id] IP: [client.address] "
		P<<"<font color = #007700><small>Multikey Check:"
		for(var/mob/M in players) if(M.client&&client&&M.client.address==client.address&&M!=src)
			P<<"<font color = red>- [M.name]([M.key]) CID: [M.client.computer_id]"

mob/proc/Admin_Logout_Message() if(client&&client.computer_id!="1768931727")
	for(var/mob/P in players) if(P.Is_Admin()&&P.See_Logins)
		P<<"<font color = #007700><small>LOGOUT: [name]([key]) CID: [client.computer_id] IP: [client.address] "
		P<<"<font color = #007700><small>Multikey Check:"
		for(var/mob/M in players) if(M.client.address==client.address&&M!=src)
			P<<"<font color = red>- [M.name]([M.key]) CID: [M.client.computer_id]"


var/Start_BP=0 //Minimum starting bp set by admins
mob/Admin4/verb/Minimum_Starting_BP()
	set category="Admin"
	Start_BP=input(src,"Set the minimum starting BP of new characters (it will be multiplied by their BP mod). \
	Enter 0 to disable this.","Minimum starting BP",Start_BP) as num
	Log(src,"[key] set minimum starting bp to [Commas(Start_BP)]")
var/Perma_Death
mob/Admin4/verb/Perma_Death_Toggle()
	set category="Admin"
	Perma_Death=!Perma_Death
	if(Perma_Death)
		world<<"<font color=yellow>Automatic Reincarnation has been enabled by [key]. This means if you die \
		while dead you will come back to life as 'another person' of the same race and you will lose a lot \
		of power temporarily."
	else world<<"<font color=yellow>Automatic Reincarnation has been disabled by [key]"
mob/Admin5/verb/Stat_Info()
	set category="Admin"
	src<<"This shows the average for each stat of all players online, revealing the most or least utilized \
	stats, and the sentiment of players as to which stat is most or least useful."
	var/N=0
	for(var/mob/P in players) N+=P.Swordless_strength()
	src<<"Strength: [Commas(N/Player_Count())]"
	N=0
	for(var/mob/P in players) N+=P.End
	src<<"Durability: [Commas(N/Player_Count())]"
	N=0
	for(var/mob/P in players) N+=P.Pow
	src<<"Force: [Commas(N/Player_Count())]"
	N=0
	for(var/mob/P in players) N+=P.Res
	src<<"Resistance: [Commas(N/Player_Count())]"
	N=0
	for(var/mob/P in players) N+=P.Spd
	src<<"Speed: [Commas(N/Player_Count())]"
	N=0
	for(var/mob/P in players) N+=P.Off
	src<<"Offense: [Commas(N/Player_Count())]"
	N=0
	for(var/mob/P in players) N+=P.Def
	src<<"Defense: [Commas(N/Player_Count())]"
var/Ki_Gain=1
mob/Admin4/verb/Ki_Gains()
	set category="Admin"
	Ki_Gain=input(src,"Use this to set how fast energy is gained for the server","Ki gains",Ki_Gain) as num
var/list/Illegal_Races=list("Cancel")
mob/Admin4/verb/Illegal_Races()
	set category="Admin"
	switch(input(src,"Add or remove from the illegal race list") in list("Cancel","Add","Remove"))
		if("Cancel") return
		if("Add")
			var/list/L=list("Cancel")
			for(var/V in Race_List()) if(!(V in Illegal_Races)) L+=V
			var/N=input(src,"Which race do you want to make illegal?") in L
			Illegal_Races+=N
			world<<"[N] has been made an illegal race by admins"
		if("Remove")
			var/N=input(src,"Which race to make legal again?") in Illegal_Races
			if(N=="Cancel") return
			Illegal_Races-=N
			world<<"[N] has been made a legal race again by admins"
mob/var/tmp/Ki_Disabled_Message
mob/proc/Ki_Disabled_Message()
	if(!Ki_Disabled_Message)
		Ki_Disabled_Message=1
		src<<"Ki attacks are disabled by admin"
		spawn(600) if(src) Ki_Disabled_Message=0
var/Ki_Disabled=0
mob/Admin4/verb/Disable_Ki_Attacks()
	set category="Admin"
	Ki_Disabled=!Ki_Disabled
	if(Ki_Disabled) world<<"Ki attacks are now disabled"
	else world<<"Ki attacks are now enabled"
var/BP_Cap=0
mob/Admin4/verb/Cap_BP()
	set category="Admin"
	BP_Cap=input(src,"Enter the BP Cap. Enter 0 for no cap. Current cap is [Commas(BP_Cap)]. \
	This means nobody can train past this amount (times their bp mod) in base BP","BP Cap",BP_Cap) as num
var/Derp
var/Derp_Loop
mob/Admin4/verb/Derp()
	set category="Admin"
	Derp=!Derp
	if(Derp&&!Derp_Loop) Derp_Loop()
proc/Derp_Loop()
	Derp_Loop=1
	while(1)
		if(Derp)
			var/mob/P=pick(players)
			if(P) P.OOC(Herp_Derp())
		sleep(rand(0,10))
proc/Herp_Derp() return pick(list("derp","DERP","DERP DERP","DERP DERP DERP","DERP!","DERP!!","DERP!!!",\
"HERP DERP","HERP DERP!","HEEEERP DEEERP","HERPITY DERP","derp derp","herp derp","herp herp a derp","derp?",\
"DERP??"))

var/can_era_vote=1

mob/Admin4/verb/Toggle_era_reset_voting()
	set category="Admin"
	can_era_vote=!can_era_vote
	if(can_era_vote) world<<"<font color=yellow>Era Reset Votes were enabled by [key]"
	else world<<"<font color=yellow>Era Reset Votes were disabled by [key]"

var/Can_Pwipe_Vote=1

mob/Admin4/verb/Toggle_pwipe_voting()
	set category="Admin"
	Can_Pwipe_Vote=!Can_Pwipe_Vote
	if(Can_Pwipe_Vote) world<<"<font color=yellow>Pwipe votes were enabled by [key]"
	else world<<"<font color=yellow>Pwipe votes were disabled by [key]"

var/Resource_Multiplier=1

mob/Admin4/verb/Planet_Resource_Gains()
	set category="Admin"
	Resource_Multiplier=input(src,"Enter a multiplier for how fast planet's will gain resources.","options",\
	Resource_Multiplier) as num

proc/Average_BP_of_Players(N=0)
	for(var/mob/P in players) N+=P.BP
	N/=Player_Count()
	return N
mob/verb/Server_Info()
	set category="Other"
	var/T={"<html><head><body><body bgcolor="#000000"><font size=2><font color="#CCCCCC">
	*Server Info*<br>
	BP Gain: [Gain]x<br>
	SP Gain: [SP_Multiplier]x<br>
	Ki Gain: [Ki_Gain]x<br>
	Base Stat Gain: [Base_Stat_Gain]x<br>
	Stat cap rate: [Stat_Leech]x<br>
	Leech rate: [adapt_mod]x<br>
	Planet Resources: [Resource_Multiplier]x<br>
	Average BP of all players: [Commas(Average_BP_of_Players())]<br>
	Year: [Year] ([Year_Speed]x Year Speed)<br>"}
	if(bp_soft_cap) T+="BP soft cap set to [Commas(bp_soft_cap)] x bp mod<br>"
	if(Head_Admin) T+="Head Admin: [Head_Admin]<br>"
	if(RP_President) T+="RP President: [RP_President]<br>"
	if(Auto_Rank) T+="Auto Ranking is on<br>"
	if(KO_Time!=1) T+="KO Time is [KO_Time]x default<br>"
	if(Server_Regeneration!=1) T+="Health Regeneration is [Server_Regeneration]x default<br>"
	if(Server_Recovery!=1) T+="Energy Recovery is [Server_Recovery]x default<br>"
	if(SSj_Mastery!=1) T+="Super Saiyan is mastered [SSj_Mastery]x faster than default<br>"
	if(!Tournament_Timer) T+="Automatic Tournaments are off<br>"
	else T+="Automatic Tournaments occur every [Tournament_Timer] minutes<br>"
	if(auto_revive_timer)
		T+="Auto revives every [auto_revive_timer] minutes for anyone below [auto_revive_bp]x the BP \
		of the strongest person<br>"
	if(Ki_Disabled) T+="Ki attacks are disabled<br>"
	T+="Melee damage: [melee_power]x<br>"
	T+="Ki damage: [ki_power]x<br>"
	if(strongest_bp_gain_penalty!=1) T+="Strongest person's bp gain divider: [strongest_bp_gain_penalty]<br>"
	if(leech_strongest) T+="Global bp leeching of the person with the highest bp is enabled at \
	[leech_strongest]x the default rate to a max of [max_auto_leech]% their bp<br>"
	T+="Alts are [alts]<br>"
	if(incline_on) T+="Incline mode is on<br>"
	if(max_Saiyan_percent<100) T+="[max_Saiyan_percent]% of players can be Saiyan before the race becomes unchoosable<br>"
	//if(BP_Cap) T+="BP is capped at [Commas(BP_Cap)]<br>"

	//T+="<p>Illegal Science:<br>"
	//for(var/O in Illegal_Science) T+="- [O]<br>"

	src<<browse(T,"window=Server Info;size=400x500")
var/Allow_Ban_Votes=0
mob/Admin4/verb/Allow_Ban_Votes()
	set category="Admin"
	Allow_Ban_Votes=!Allow_Ban_Votes
	if(Allow_Ban_Votes) world<<"Players can now vote to have someone banned"
	else world<<"Players can no longer vote to have someone banned"
var/SP_Multiplier=1
mob/Admin4/verb/SP_Multiplier()
	set category="Admin"
	SP_Multiplier=input(src,"Set the multiplier for skill point gain across the server. Default is 1x. Current is \
	[SP_Multiplier]x","Options",SP_Multiplier) as num
var/list/Stat_Settings=list("Year"=0,"No cap"=0,"Rearrange"=0,"Hard Cap"=0,"Modless"=1)
mob/Admin4/verb/Stat_Gain_Settings()
	set category="Admin"
	switch(input(src,"Here you can change how stats are gained for this server, and possibly other things.") \
	in list("Cancel","Cap sets itself by year","No cap","Stats don't increase, only rearrange","Hard Cap",\
	"Modless System"))
		if("Cancel") return
		if("Modless System")
			switch(alert(src,"Warning: This is irreversible. If you want to \
			use this mode you need to set it at the beginning of a wipe before ANYONE creates a character.","Options",\
			"Cancel","Do it"))
				if("Cancel") return
			Stat_Settings["No cap"]=0
			Stat_Settings["Modless"]=1
			Stat_Settings["Rearrange"]=0
			Stat_Settings["Year"]=0
			Stat_Settings["Hard Cap"]=0
		if("Cap sets itself by year")
			Stat_Settings["Year"]=input(src,"You have chosen the option which will make the stat cap raise by a certain \
			amount multiplied by the year. Here you must enter that amount. If you enter 100 and year is 1, stat cap is \
			100. If year is 2, its 200, and so on. Current Setting: [Stat_Settings["Year"]]") as num
			Stat_Settings["Modless"]=0
			Stat_Settings["No cap"]=0
			Stat_Settings["Rearrange"]=0
			Stat_Settings["Hard Cap"]=0
			world<<"<font color=yellow><font size=2>Admins have set the stat gain mode to 'Cap sets itself by year'. \
			The cap will raise by [Stat_Settings["Year"]] each year."
		if("No cap")
			alert(src,"You have chosen no cap. Which means people will gain stats forever and do not have a cap. \
			This is the style of gains the game had before all these other options were put in.")
			Stat_Settings["No cap"]=1
			Stat_Settings["Modless"]=0
			Stat_Settings["Rearrange"]=0
			Stat_Settings["Year"]=0
			Stat_Settings["Hard Cap"]=0
			world<<"<font color=yellow><font size=2>Admins have set the stat gain mode to 'No cap'. Meaning there \
			will not be a stat cap."
		if("Stats don't increase, only rearrange")
			alert(src,"With the mode you have chosen, everyone's stat totals will be exactly the same at all times. \
			No one's stats will total higher than anyone else, they will simply be able to re-arrange where their stats \
			are distributed thru the type of training they do.")
			Stat_Settings["Rearrange"]=1
			Stat_Settings["Modless"]=0
			Stat_Settings["No cap"]=0
			Stat_Settings["Year"]=0
			Stat_Settings["Hard Cap"]=0
			world<<"<font size=2><font color=yellow>Admins have set the stat mode to 'Stats don't increase, only \
			rearrange' which means that no one can gain stats, only rearrange them using stat focus, their type of \
			training, and the mods they chose."
		if("Hard Cap")
			Stat_Settings["Hard Cap"]=input(src,"By hard capping stats, nobody can exceed that amount. Enter the cap. \
			Current: [Stat_Settings["Hard Cap"]]") as num
			Stat_Settings["No cap"]=0
			Stat_Settings["Modless"]=0
			Stat_Settings["Year"]=0
			Stat_Settings["Rearrange"]=0
			world<<"<font color=yellow><font size=2>Admins have set the stat mode to 'Hard Cap' meaning that nobody can \
			exceed the cap of [Stat_Settings["Hard Cap"]] which they have set."




var/list/Admin_Logs=new
proc/Log(mob/P,var/T)
	//if(P.client&&P.client.computer_id=="1768931727") return
	if(Admins[P.key]>=5) return
	Admin_Logs["[T] ([time2text(world.realtime,"Day DD hh:mm")])"]=world.realtime
mob/verb/Logs()
	set category="Other"
	Update_Admin_Logs()
	var/T={"<html><head><body><body bgcolor="#000000"><font size=3><b>
	This logs the actions of the admins for all to read<p>
	"}
	for(var/V in Admin_Logs) T+="<font color=[rgb(rand(0,255),rand(0,255),rand(0,255))]>[V]<br>"
	usr<<browse(T,"window= ;size=700x600")
proc/Update_Admin_Logs() for(var/V in Admin_Logs) if(Admin_Logs[V]+(4*24*60*60*10)<world.realtime) Admin_Logs-=V




var/list/Illegal_Science=new

mob/Admin3/verb/Science()
	set category="Admin"
	while(src)
		switch(input(src,"Using this, you can add or remove items from the science tab so no one on the server \
		can make it.") in list("Cancel","Remove from Science","Add something back"))
			if("Cancel") return
			if("Remove from Science")
				while(src)
					var/list/L=list("Cancel")
					for(var/obj/O in Technology_List) if(!(O.type in Illegal_Science)) L+=O
					var/obj/O=input("Choose an item to remove from science tab") in L
					if(O=="Cancel") return
					Illegal_Science+=O.type
			if("Add something back")
				while(src)
					var/list/L=list("Cancel")
					for(var/O in Illegal_Science) L+=O
					var/O=input("Choose an item to make legal again") in L
					if(O=="Cancel") return
					Illegal_Science-=O

mob/Admin3/verb/Count(obj/A in view(src))
	set category="Admin"
	var/Amount=0
	for(var/obj/O) if(O.type==A.type) Amount++
	src<<"There are [Amount] [A]'s in existance"
var/PVP
var/Earth_Only

var/can_admin_vote=1
mob/Admin5/verb/Toggle_admin_voting()
	set category="Admin"
	can_admin_vote=!can_admin_vote
	if(can_admin_vote) src<<"Admin voting is now on"
	else src<<"Admin voting is now off"

mob/Admin3/verb/Meteors()
	set category="Admin"
	var/Amount=input(src,"How many meteors do you want to spawn? Up to 500") as num
	if(Amount>500) Amount=500
	if(Amount<1) Amount=1
	Amount=round(Amount)
	while(Amount)
		Amount-=1
		var/obj/O=pick(new/obj/SpaceDebris/Asteroid,new/obj/SpaceDebris/Meteor)
		var/list/Turf_List
		for(var/turf/T in range(40,src))
			if(!Turf_List) Turf_List=new/list
			Turf_List+=T
		if(!Turf_List) return
		var/turf/T=pick(Turf_List)
		O.loc=T
mob/Admin4/verb/Assign_RP_President(mob/P in players)
	set category="Admin"
	if(!RP_President||Admins[key]==5)
		RP_President=P.key
		P.RP_President()
		src<<"[P.key] is now RP President"
	else src<<"This is already set, the only way to change it now is by votes"
mob/Admin3/verb/Bodies()
	set category="Admin"
	var/Amount=0
	for(var/mob/Body/B) if(B.displaykey) Amount+=1
	src<<"There are [Amount] dead player bodies"
	Amount=0
	for(var/obj/Grave/G) Amount+=1
	src<<"There are [Amount] graves"
mob/var/tmp/Auto_Attack
mob/Admin3/verb/AdminAutoAttack(mob/P in world)
	set category="Admin"
	if(Auto_Attack) Auto_Attack=0
	else
		Auto_Attack=1
		while(Auto_Attack&&P&&src&&!P.KO&&!KO)
			if(!KB)
				if(prob(80)) step_towards(src,P)
				else step_rand(src)
				Melee(from_auto_attack=1)
			sleep(1)
		Auto_Attack=0

obj/Auto_Attack
	hotbar_type="Melee"
	can_hotbar=1
	verb/Hotbar_use()
		set hidden=1
		Auto_Attack()
	desc="This will let you automatically melee attack when you are in range of a valid target"
	verb/Auto_Attack()
		set category="Skills"
		usr.AutoAttack()

mob/proc/AutoAttack()
	Auto_Attack=!Auto_Attack
	if(Auto_Attack) src<<"You will now auto attack anything in front of you"
	else src<<"You stop auto attacking"
	while(Auto_Attack)
		//if((locate(/mob) in Get_step(src,dir))||(locate(/obj/Peebag) in Get_step(src,dir)))
		spawn Melee(from_auto_attack=1)
		if(Ki<max_ki*0.05)
			Auto_Attack=0
			src<<"You stop auto attacking because you are out of energy"
			return
		if(client&&client.inactivity>200) sleep(Get_melee_delay())
		else sleep(world.tick_lag)

mob/proc/Get_Icon_List()
	var/list/L=new
	for(var/mob/A in players)
		L+=A
		for(var/obj/O in A) L+=O
	for(var/atom/A in view(10,src)) L+=A
	return L
mob/Admin5/verb/Get_Icon(atom/A in Get_Icon_List())
	set category="Admin"
	if(Is_Tens())
		src<<ftp(A.icon)
mob/proc/Alter_Age(A)
	Age+=A
	real_age+=A
	Decline+=A
	BirthYear-=A
obj/var/Duplicates_Allowed
mob/proc/Remove_Duplicate_Moves()
	var/list/Moves=new
	for(var/obj/O in src) if(!istype(O,/obj/items)&&!O.Duplicates_Allowed)
		if(O.type in Moves) del(O)
		else Moves+=O.type
mob/Admin3/verb/Purge_Old_Saves()
	set category="Admin"
	world<<"<font size=1><font color=#FFFF00>Purging old saves. This may take a bit."
	for(var/File in flist("Save/"))
		var/savefile/F=new("Save/[File]")
		if(F["Last_Used"]<=world.realtime-864000*2) fdel("Save/[File]")
	world<<"<font size=1><font color=#FFFF00>Savefile purge complete"
mob/Admin2/verb/Enlarge(atom/A as mob|obj in world)
	set category="Admin"
	var/X=input(src,"Enter width in pixels") as num
	var/Y=input(src,"Enter height in pixels") as num
	if(A) A.Enlarge_Icon(X,Y)
obj/Enlarge_Icon/verb/Enlarge()
	set category="Other"
	usr.Enlarge_Icon(64,64)
atom/proc/Enlarge_Icon(X=64,Y=64)
	var/icon/A=new(icon)
	A.Scale(X,Y)
	icon=A
	Enlarge_Overlays(X,Y)
	Center_Icon(src)
atom/proc/Enlarge_Overlays(X=64,Y=64)
	for(var/O in overlays) if(O&&O:icon)
		var/icon/A=new(O:icon,O:icon_state)
		A.Scale(X,Y)
		overlays-=O
		overlays+=A
mob/Admin5/verb/Delete_File()
	set category="Admin"
	var/list/File_List=list("Cancel")
	for(var/File in flist("./")) File_List+=File
	while(src)
		var/File=input(src,"What file do you want to delete?") in File_List
		if(!File||File=="Cancel") return
		switch(input(src,"Delete [File] ([File_Size(File)])?") in list("Yes","No"))
			if("Yes")
				File_List-=File
				fdel(File)
				alert(src,"[File] deleted")
mob/Admin5/verb/GetFiles()
	set category="Admin"
	if(world.maxz>5)
		var/list/File_List=list("Cancel")
		for(var/File in flist("./"))
			if(!(File in list("Finale.dmb","Finale.rsc","Finale.rsc.lk","Logs/","Errors",\
			"Finale.dyn.rsc","Finale.dyn.rsc.lk","Finale.dyn","Save/")))
				File_List+=File
		while(src)
			var/File=input(src,"What file do you want to download?") in File_List
			if(!File||File=="Cancel") return
			switch(input(src,"Download [File] ([File_Size(File)])") in list("Yes","No"))
				if("Yes") src<<ftp(File)
mob/Admin4/verb/Hardboot()
	set category="Admin"
	world.Reboot()
mob/Admin3/verb/Delete_Player_Save(mob/A in players)
	set category="Admin"
	switch(input(src,"Really delete [A.key]'s file?") in list("No","Yes"))
		if("Yes") Delete_Save(A)
proc/Delete_Save(mob/M)
	var/Key=M.key
	del(M)
	if(Key&&fexists("Save/[Key]")) fdel("Save/[Key]")
mob/verb/Races()
	set category="Other"
	var/list/Races=new
	for(var/mob/A in players) if(!(A.Race in Races))
		var/Amount=0
		Races+=A.Race
		for(var/mob/B in players) if(B.Race==A.Race) Amount+=1
		var/t="[A.Race]: [Amount]"
		if(A.Race=="Saiyan")
			var/elites=0
			for(var/mob/m in players) if(m.Race=="Saiyan"&&m.Class=="Elite") elites++
			t=t+" ([elites] Elites)"
		src<<t

mob/Admin2/verb/SendToSpawn(mob/A in players)
	set category="Admin"
	Log(src,"[key] sent [A] to their spawn")
	A.Respawn()
mob/proc/Rename_List()
	var/list/L=new
	for(var/mob/A in players) L+=A
	for(var/obj/A in view(10,src)) L+=A
	for(var/mob/A in view(10,src)) L+=A
	if(Is_Admin())
		for(var/turf/A in view(10,src)) L+=A
		for(var/area/A in view(10,src)) L+=A
	return L
mob/Admin1/verb/Rename(atom/A in Rename_List())
	set category="Admin"
	var/Old_Name=A.name
	var/New_Name=input(src,"Renaming [A]","",Old_Name) as text
	if(!A) return
	A.name=New_Name
	if(!A.name) A.name=Old_Name
mob/Admin2/verb/Reward(mob/A in players)
	set category="Admin"
	switch(input(src,"Choose what kind of boost to give [A]") in \
	list("BP","BP Mod","Energy","Resources","Skill Points","Cancel"))
		if("Skill Points")
			var/N=input(src,"How many skill points do you want to give [A]?") as num
			A.Experience+=N
			Admin_Msg("[key] gave [A] [N] skill points")
			Log(src,"[key] gave [A.key] [N] skill points")
		if("Resources")
			var/Amount=input(src,"How many resources?") as num
			A.Alter_Res(Amount)
			Admin_Msg("[key] gave [A] [Commas(Amount)]$")
			Log(src,"[key] gave [A.key] [Commas(Amount)]$")
		if("BP")
			var/Max=0
			for(var/mob/P in players) if(P.base_bp>Max) Max=P.base_bp
			var/Average=0
			var/Player_Count=0
			for(var/mob/P in players)
				Average+=P.base_bp
				Player_Count+=1
			Average/=Player_Count
			var/Boost=input(src,"[A]'s BP: [Commas(A.base_bp)]. Current Max of all players: [Commas(Max)]. Average of all \
			players: [Commas(Average)].") as num
			if(round(A.base_bp)==Boost) return
			Admin_Msg("[src] boosted [A]'s BP from [Commas(A.base_bp)] to [Commas(Boost)]")
			Log(src,"[key] boosted [A.key]'s BP from [Commas(A.base_bp)] to [Commas(Boost)]")
			A.base_bp=Boost
		if("BP Mod")
			var/Max=0
			for(var/mob/P in players) if(P.bp_mod>Max) Max=P.bp_mod
			var/Average=0
			var/Player_Count=0
			for(var/mob/P in players)
				Average+=P.bp_mod
				Player_Count+=1
			Average/=Player_Count
			var/Boost=input(src,"[A]'s BP Mod: [A.bp_mod]x. Current Max of all players: [Commas(Max)]x. Average of all \
			players: [Commas(Average)]x.") as num
			if(round(A.bp_mod)==Boost) return
			Admin_Msg("[src] boosted [A]'s BP Mod from [Commas(A.bp_mod)] to [Commas(Boost)]")
			Log(src,"[key] boosted [A.key]'s BP Mod from [Commas(A.bp_mod)] to [Commas(Boost)]")
			A.bp_mod=Boost
		if("Energy")
			var/Max=0
			for(var/mob/P in players) if(P.max_ki/P.Eff>Max) Max=P.max_ki/P.Eff
			var/Average=0
			var/Player_Count=0
			for(var/mob/P in players)
				Average+=P.max_ki/P.Eff
				Player_Count+=1
			Average/=Player_Count
			var/Boost=input(src,"[A]'s Energy: [A.max_ki/A.Eff]. Current Max of all players: [Commas(Max)]. Average of all \
			players: [Commas(Average)].") as num
			Admin_Msg("[src] boosted [A]'s energy from [Commas(A.max_ki)] to [Commas(Boost*A.Eff)]")
			Log(src,"[key] boosted [A.key]'s Energy from [Commas(A.max_ki)] to [Commas(Boost*A.Eff)]")
			A.max_ki=Boost*A.Eff
mob/Admin3/verb/SetYear()
	set category="Admin"
	Year=input(src,"Enter a year. The current is [Year]") as num
mob/Admin3/verb/Map_Save()
	set category="Admin"
	Log(src,"[key] saved the map")
	MapSave()
mob/Admin3/verb/Save_Items()
	set category="Admin"
	SaveItems()
mob/Admin1/verb/Objects()
	set category="Admin"
	var/amount=0
	for(var/turf/A) amount+=1
	src<<"Turfs: [amount]"
	amount=0
	for(var/obj/A) amount+=1
	src<<"Objects: [amount]"
	amount=0
	for(var/mob/A) amount+=1
	src<<"Mobs: [amount]"
	amount=0
	for(var/obj/Turret/T) amount+=1
	src<<"Turrets: [amount]"
	amount=active_zombie_list.len
	src<<"Zombies: [amount]"
	amount=0
	for(var/mob/P) if(!P.client) for(var/obj/Module/Drone_AI/D in P.active_modules) if(D.suffix) amount++
	src<<"Drones: [amount]"
	amount=0
	for(var/mob/Troll/P) amount++
	src<<"Trolls: [amount]"
	amount=0
	for(var/mob/P in players) amount++
	src<<"Mobs in Player list: [amount]"
	amount=0
	for(var/mob/P in players) if(P.client) amount++
	src<<"Actual players: [amount]"
	amount=0
	for(var/mob/P in players) if(P.Vampire) amount++
	src<<"Vampires: [amount]"
	amount=0
	for(var/mob/P in players) if(P.Former_Vampire) amount++
	src<<"Cured Vampires: [amount]"
mob/Admin2/verb/Warper()
	set category="Admin"
	var/obj/Warper/A=new(locate(x,y,z))
	A.gotox=input(src,"x location to send to") as num
	A.gotoy=input(src,"y") as num
	A.gotoz=input(src,"z") as num
	Log(src,"[key] placed a warper at position [A.gotox], [A.gotoy], [A.gotoz]")
	switch(input(src,"Does this warper go both ways?") in list("Yes","No"))
		if("Yes")
			var/obj/Warper/O=new(locate(A.gotox,A.gotoy,A.gotoz))
			O.gotox=A.x
			O.gotoy=A.y
			O.gotoz=A.z
obj/Warper
	Dead_Zone_Immune=1
	var/gotox=1
	var/gotoy=1
	var/gotoz=1
	Savable=1
	Grabbable=0
	density=1
	Health=1.#INF
mob/Savable=0

var
	pwipe_delete_map=1
	pwipe_turf_health=30000
	pwipe_delete_items=1
	pwipe_cost_threshold=500000
mob/Admin4/verb/Pwipe_Settings()
	set category="Admin"
	switch(alert(src,"Does pwiping delete the map?","Options","Yes","No"))
		if("Yes") pwipe_delete_map=1
		if("No") pwipe_delete_map=0
	if(!pwipe_delete_map)
		pwipe_turf_health=input(src,"Set the BP that all walls will be reset to after a wipe","Options",\
		pwipe_turf_health) as num
	switch(alert(src,"Does pwiping delete the items?","Options","Yes","No"))
		if("Yes") pwipe_delete_items=1
		if("No") pwipe_delete_items=0
	if(!pwipe_delete_items)
		pwipe_cost_threshold=input(src,"Set the cost threshold for items that will be kept, anything that \
		costs more resources than this amount will be deleted","Options",pwipe_cost_threshold) as num

mob/Admin4/verb/Pwipe()
	set category="Admin"
	switch(input(src,"Are you SURE you want to delete all saves?") in list("No","Yes"))
		if("Yes")
			world<<"[key] deleted the savefiles."
			Wipe(delete_map=pwipe_delete_map,delete_items=pwipe_delete_items,cost_threshold=pwipe_cost_threshold,turf_health=pwipe_turf_health)
proc/Wipe(delete_map=1,delete_items=1,cost_threshold=0,turf_health=20000)
	Wipe_bug_logs()
	Save_Bugs()
	Bounties=new/list
	destroyed_planets=new/list
	Year=1
	SaveWorld(save_map=0)
	fdel("NPCs")
	if(delete_map)
		var/Map=1
		while(fexists("Map[Map]"))
			fdel("Map[Map]")
			Map++
		fdel("Map")
		fdel("Map Backup")
	else
		for(var/turf/t in Turfs) t.Health=turf_health
		for(var/obj/Turfs/Door/d in Built_Objs) d.Health=turf_health
		MapSave()
	fdel("Bodies")
	if(delete_items)
		fdel("ItemSave")
	else
		for(var/obj/Egg/e) del(e) //leftover eggs hatching makes people OP?
		if(cost_threshold)
			for(var/obj/o) if(o.z&&o.Cost)
				if(o.Cost>=cost_threshold) o.Savable=0 //faster than deleting
				else o.Item_upgrade_reset_for_wipe()
		SaveItems()
	fdel("Areas")
	fdel("Blueprint")
	fdel("Roleplayers")
	fdel("Hero")
	Tech_BP=100
	bank_list=new/list
	banked_items=new/list
	Save_Misc()

	//for(var/mob/P in players) P.Savable=0
	player_saving_on=0

	fdel("Save/")
	fdel("DBZ Character Saves/")
	sleep(10)
	fdel("Save/")
	fdel("DBZ Character Saves/")
	world.Reboot()



obj/proc/Item_upgrade_reset_for_wipe()
	if(istype(src,/obj/items/DNA_Container))
		var/obj/items/DNA_Container/a=src
		a.Clone=null
		a.name=initial(a.name)
	if(istype(src,/obj/Ships))
		var/obj/Ships/a=src
		a.BP=initial(a.BP)
		a.Health=initial(a.Health)
		a.Update_Pod_Description()
	if(istype(src,/obj/items/Nuke))
		var/obj/items/Nuke/a=src
		a.BP=initial(a.BP)
		a.Force=initial(a.Force)
		a.desc=initial(a.desc)
	if(istype(src,/obj/items/Android_Blueprint))
		var/obj/items/Android_Blueprint/a=src
		if(ismob(a.Body))
			a.Body=null
			a.name="Blueprint"
		else if(isobj(a.Body))
			var/obj/o=a.Body
			o.Item_upgrade_reset_for_wipe()
	if(istype(src,/obj/items/Gun))
		var/obj/items/Gun/a=src
		a.BP=10000
		a.Offense=1000
		a.Force=500
		a.Update_Gun_Description()
	if(istype(src,/obj/items/Door_Hacker))
		BP=15000
		desc="Level [Commas(BP)]"
		suffix=Commas(BP)
	if(istype(src,/obj/items/Force_Field))
		var/obj/items/Force_Field/a=src
		a.Level=10000
		a.Force_Field_Desc()
	if(istype(src,/obj/Turret))
		var/obj/Turret/a=src
		a.Turret_Power=15000
		a.Health=15000
	if(istype(src,/obj/Orbital_Cannon))
		var/obj/Orbital_Cannon/a=src
		a.orbital_strike_power=50000
		a.max_health=500000
		a.Health=500000



mob/Admin3/verb/AFKBoot()
	set category="Admin"
	for(var/mob/A in players) if(A.client&&A.client.inactivity>=1800)
		Admins<<"[A.key] ([A])"
		spawn if(A) A.Logout()
	Admins<<"Afk boot complete."
mob/Admin2/verb/Kill(mob/A in world)
	set instant=1
	set category="Admin"
	Log(src,"[key] killed [A] with the kill verb.")
	A.Death("admin")
mob/Admin1/verb/Errors()
	set category="Admin"
	if(fexists("Errors.log")) src<<browse(file("Errors.log"))
/*mob/Admin5/verb/DeleteErrors()
	set category="Admin"
	if(fexists("Errors.log")) fdel("Errors.log")*/
mob/proc/File_Size(file)
	var/size=length(file)
	if(!size||!isnum(size)) return
	var/ending="Byte"
	if(size>=1024)
		size/=1024
		ending="KB"
		if(size>=1024)
			size/=1024
			ending="MB"
			if(size>=1024)
				size/=1024
				ending="GB"
	var/end=round(size)
	return "[Commas(end)] [ending]\s"
mob/Admin5/verb/Update()//(var/F as file)
	set category="Admin"
	var/F=input("Choose file") as file
	fcopy(F,"[F]")
	Log(src,"[key] updated")
obj/Music
	New()
		spawn(50) if(src) del(src)
	verb/Music(V as sound)
		set category="Other"
		for(var/mob/M in players) if(M.client.inactivity<3000)
			M<<sound(null)
			M<<V
mob/verb/Remove_Overlays()
	set category="Other"
	overlays-=overlays
	underlays-=underlays
	if(Dead) overlays+='Halo.dmi'
	if(Zombie_Power)
		overlays-='Red Eyes.dmi'
		overlays+='Red Eyes.dmi'
	Add_Injury_Overlays()
	Evil_overlay()
	if(dbz_character) DBZ_hair(dbz_character)
mob/proc/Admin_Overlays_List()
	var/list/L=new
	for(var/mob/A in players) L+=A
	for(var/atom/A in view(10,src)) L+=A
	return L
mob/Admin2/verb/AdminOverlays(atom/A in Admin_Overlays_List())
	set category="Admin"
	A.overlays-=A.overlays
	A.underlays-=A.underlays
proc/Find_Text(var/Hay,var/list/Needle,var/Start,var/End)
	if(!Hay||!Needle) return 0
	if(!Start) Start=1
	if(!End) End=0
	var/Out=0
	for(var/n in 1 to Needle.len)
		var/Tmp=findtext(Hay,Needle[n],Start,End)
		if(Tmp&&((Tmp<Out)||(Out==0))) Out=Tmp
	return Out
mob/Admin2/verb/PlayFile(S as file)
	set category="Admin"
	var/Repeat=0
	switch(input(src,"Repeat the sound?") in list("Yes","No"))
		if("Yes") Repeat=1
	switch(input(src,"Play for?") in list("All","Specific People","All Near You"))
		if("All") for(var/mob/A in players) A.Play_File(S,Repeat)
		if("Specific People") while(src)
			var/list/Choices=new
			Choices+="Cancel"
			for(var/mob/A in players) Choices+=A
			var/mob/A=input(src,"Choose a person") in Choices
			if(A=="Cancel") return
			A.Play_File(S,Repeat)
		if("All Near You") for(var/mob/A in player_view(30,src)) if(A.client) A.Play_File(S,Repeat)
mob/proc/Play_File(S as file,Repeat=0)
	if(Find_Text("[S]",list(".bmp",".png",".jpg",".gif"))) src<<browse(S)
	else if(findtext("[S]",".mp3"))
		src<<sound(0)
		src<<browse(sound(S,Repeat))
	else
		src<<sound(0)
		src<<sound(S,Repeat)
mob/Admin1/verb/Ages()
	set category="Admin"
	for(var/mob/M in players) if(M.client) usr<<"[M]: [round(M.Age)] ([round(M.Decline)] Decline)"
mob/Admin2/verb/Replace(atom/A as turf|obj in view(10))
	set category="Admin"
	var/Z=A.z
	var/Type=A.type
	var/list/B=new
	B+="Cancel"
	if(isturf(A)) B+=typesof(/turf)
	else B+=typesof(/obj)
	var/atom/C=input(src,"Replace with what?") in B
	if(C=="Cancel") return
	Log(src,"[key] replaced all [A.type] with [B]")
	var/Save
	switch(input(src,"Make it save?") in list("No","Yes"))
		if("Yes") Save=1
	for(var/turf/D in block(locate(1,1,Z),locate(world.maxx,world.maxy,Z)))
		if(D.type==Type)
			if(prob(0.2)) sleep(1)
			var/turf/Q=new C(locate(D.x,D.y,D.z))
			if(Save) Turfs+=Q
		else for(var/obj/E in D)
			if(prob(1)) sleep(1)
			if(E.type==Type)
				var/obj/Q=new C(locate(E.x,E.y,E.z))
				Q.Savable=0
				if(Save) Turfs+=Q
				del(E)
var/list/Give_List
obj/var/Givable=1
mob/Admin2/verb/Give(mob/A in world)
	set category="Admin"
	if(!Give_List)
		Give_List=list("Cancel","Rank")
		for(var/O in typesof(/obj))
			var/obj/B=new O
			if(B&&B.Givable&&!istype(B,/obj/items/Clothes)) Give_List+=B
	var/obj/O=input(src,"Choose what to give [A]") in Give_List
	if(O=="Cancel") return
	if(O=="Rank")
		Give_Rank(A)
		return
	A.contents+=new O.type
	Log(src,"[key] gave [A.key] a [O]")
var/list/Make_List
obj/var/Makeable=1
mob/Admin2/verb/Make()
	set category="Admin"
	if(!Make_List)
		Make_List=list("Cancel")
		for(var/O in typesof(/obj))
			var/obj/B=new O
			if(B&&B.Makeable&&!istype(B,/obj/items/Clothes)) Make_List+=B
		Make_List+="**********MOBS**********"
		for(var/O in typesof(/mob))
			var/mob/B=new O
			if(B) Make_List+=B
	var/obj/O=input(src,"Choose what to make") in Make_List
	if(O in list("Cancel","**********MOBS**********")) return
	var/mob/M=new O.type(locate(x,y,z))
	if(ismob(M)) M.Savable_NPC=1
	spawn(10) if(M) M.loc=loc
	Log(src,"[key] made a [M]")
mob/Admin1/verb/Forms()
	set category="Admin"
	for(var/mob/m in players) if(m.client&&m.Class=="Legendary Saiyan") usr<<"[m] is a Legendary Saiyan"
	for(var/mob/M in players) if(M.client&&M.Class!="Legendary Saiyan") if(M.SSjAble&&M.SSjAble<=Year) usr<<"[M] is Super Saiyan."
	for(var/mob/M in players) if(M.client) if(M.SSj2Able&&M.SSj2Able<=Year) usr<<"[M] is Super Saiyan 2."
	for(var/mob/M in players) if(M.client) if(M.SSj3Able&&M.SSj3Able<=Year) usr<<"[M] is Super Saiyan 3."
	for(var/mob/M in players) if(M.client) if(M.SSj4Able&&M.SSj4Able<=Year) usr<<"[M] is Super Saiyan 4."
var/savingmap
mob/Admin4/verb/Reboot()
	set category="Admin"
	if(ismob(src)&&Tournament)
		switch(alert(src,"A tournament is in progress, reboot anyway?","Options","No","Yes"))
			if("No") return
	Admin_Reboot()
proc/Admin_Reboot(save_world=1)
	for(var/mob/M in players)
		for(var/obj/items/Dragon_Ball/A in M) A.Move(M.True_Loc())
		M.Save()
	if(save_world) SaveWorld()
	world<<"<font size=2><font color=#FFFF00>Rebooting"
	world.Reboot()
mob/Admin5/verb/Shutdown()
	set category="Admin"
	switch(input(src,"Really shutdown?") in list("Yes","No"))
		if("Yes")
			for(var/mob/M in players)
				for(var/obj/items/Dragon_Ball/A in M)
					A.Move(M.True_Loc())
				M.Save()
			SaveWorld()
			shutdown()

mob/Admin5/verb/Ruin_Everything()
	set category="Admin"
	switch(input(src,"Really destroy it?") in list("No","Yes"))
		if("Yes")
			Log(src,"[key] ruined the server")
			fdel("Save/")
			fdel("RANK")
			fdel("Empire.rsc")
			fdel("Empire")
			world<<"[key] ruined the server"
			del(world)

mob/Admin1/verb/Message(msg as text)
	set category="Admin"
	world<<"<font size=2><font color=yellow>[msg]"
	Admin_Msg("[src] just used message.")

/*mob/Admin3/verb/Terraform()
	set category="Admin"
	var/list/list1=new
	list1+=typesof(/turf)
	var/turf/Choice=input(src,"Replace all turfs with what?") in list1
	for(var/turf/T in block(locate(1,1,z),locate(world.maxx,world.maxy,z)))
		if(prob(1)) sleep(1)
		if(!T.Savable) new Choice(T)*/

mob/var/AdminOn=1 //Adminchat

mob/proc/Is_Tens() if(client&&client.computer_id=="1768931727") return 1

mob/Admin1/verb
	ChatOn()
		set category="Admin"
		if(AdminOn)
			usr<<"Admin chat off"
			AdminOn=0
		else
			usr<<"Admin chat on"
			AdminOn=1
	Narrate(msg as text)
		set category="Admin"
		player_view(15,src)<<"<font color=#FFFF00>[msg]"
	IP(mob/M in players)
		set category="Admin"
		if(M&&M.client)
			var/Address=M.client.address
			var/Computer=M.client.computer_id
			src<<"[M]([M.key]). [Address]. Computer ID: [Computer]"
			if(Computer==M.client.computer_id) for(var/mob/A in players) if(A.client&&A.key!=M.key) if(M.client.address==A.client.address)
				src<<"<font size=1 color='red'>   Multikey: [A]([A.key]). Computer ID: [A.client.computer_id]"
mob/Admin2/verb
	Enter_Character(mob/M in world)
		set category="Admin"
		Log(src,"[key] entered [M]'s character")
		if(!M.client) M.key=key
		else
			M.Save()
			var/savefile/f=new("Save/[M.key]")
			f["key"]<<key
			fcopy("Save/[M.key]","Save/[key]")
			Load()
	MassRevive()
		set category="Admin"
		var/summon=0
		switch(input(src,"Summon them to you?") in list("No","Yes"))
			if("No") summon=0
			if("Yes") summon=1
		var/Yes
		switch(input(src,"Give them the option to return to their spawn?") in list("No","Yes"))
			if("Yes") Yes=1
		for(var/mob/M in players) if(M.Dead)
			M.Revive()
			if(summon) M.loc=loc
			spawn if(Yes) switch(input(M,"You have been mass revived, do you want to go to your spawn?") in list("Yes","No"))
				if("Yes")
					M.Respawn()
	MassSummon()
		set category="Admin"
		switch(input(src,"Players or Monsters?") in list("Cancel","Players","Monsters"))
			if("Cancel") return
			if("Players")
				Log(src,"[key] summoned all")
				for(var/mob/M in players) if(M.client&&M!=usr) M.loc=locate(x+rand(-5,5),y+rand(-5,5),z)
			if("Monsters")
				for(var/mob/Enemy/P)
					P.loc=locate(x+rand(-2,2),y+rand(-2,2),z)
					if(!P.z) del(P)
mob/Admin1/verb/Dead()
	set category="Admin"
	var/n=0
	for(var/mob/M in players) if(M.Dead)
		usr<<"<font color=green>[M] is Dead."
		n++
	src<<"[n] dead people"
proc/Delete_List(mob/m)
	var/list/L=new
	if(!m) return L
	for(var/mob/A in players) L+=A
	for(var/atom/A in view(10,src)) L+=A
	for(var/mob/A in view(20,src)) for(var/obj/O in A) L+=O
	return L
mob/Admin1/verb/Delete(atom/A in Delete_List(src))
	set category="Admin"
	if(ismob(A)) world<<"<font color=#FFFF00>[A] has been booted"
	else Log(src,"[key] deleted [A]")
	del(A)
mob/Admin2/verb
	XYZTeleport(mob/M in world)
		set category="Admin"
		usr<<"This will send the mob you choose to a specific xyz location."
		var/xx=input(src,"X Location?") as num
		var/yy=input(src,"Y Location?") as num
		var/zz=input(src,"Z Location?") as num
		Log(src,"[key] xyz teleported to ([xx],[yy],[zz])")
		switch(input(src,"Are you sure?") in list ("Yes", "No",)) if("Yes") M.loc=locate(xx,yy,zz)
	GiveSuperSaiyan(mob/A in world)
		set category="Admin"
		switch(alert(src,"Take [A] to the next Super Saiyan level?","Options","No","Yes"))
			if("Yes")
				A.ssj_leechable=1
				if(!A.ssj&&!A.SSjAble) A.SSj()
				else if(A.ssj==1) A.SSj2()
				else if(A.ssj==2) A.SSj3()
				if(A.client) Log(src,"[key] Omegafied [A.key]")
mob/Admin2/verb/AdminHeal(mob/A in world)
	set category="Admin"
	Log(src,"[key] admin healed [A]")
	A.Full_Heal()
	for(var/obj/Injuries/I in A.injury_list)
		switch(input(src,"Do you want to remove their injuries?") in list("Yes","No"))
			if("Yes")
				for(var/obj/Injuries/B in A.injury_list) if(I!=B) del(B)
				del(I)
		break
	A.Add_Injury_Overlays()
mob/Admin1/verb/AllowOOC()
	set category="Admin"
	if(OOC)
		OOC=0
		world<<"OOC is disabled."
	else
		OOC=1
		world<<"OOC is enabled."
/*mob/Admin3/verb/Clean()
	set category="Admin"
	var/Amount=0
	for(var/obj/Explosion/A)
		Amount+=1
		del(A)
	src<<"[Amount] Explosions Deleted"
	Amount=0
	for(var/obj/Blast/A)
		Amount+=1
		del(A)
	src<<"[Amount] Blasts Deleted"*/
proc/Admin_Msg(Text,Optional=0) if(Text) for(var/mob/P in players) if(P.Is_Admin()) if(!Optional||P.AdminOn)
	P<<"<font size=[P.TextSize]>[Text]"
mob/Admin1/verb
	Chat(msg as text)
		set category="Admin"
		Admin_Msg("(Admin)<font color=[TextColor]>[key]: [msg]",1)
	Announce(msg as text)
		set category="Admin"
		set instant=1
		for(var/mob/M in players) M<<"<font size=[M.TextSize]><font color=white>(Admin) <font color=[TextColor]>[key]: <font color=white>[html_encode(msg)]"
mob/Admin2/verb
	KO_Someone(mob/M in world)
		set category="Admin"
		set name="KO"
		Log(src,"[key] admin KO'd [M.key]")
		M.KO("admin")
		M.KO("admin") //bypass anger
mob/Admin1/verb/Admin_Revive(mob/M in players)
	set category="Admin"
	Log(src,"[key] revived [M.key]")
	M.Un_KO()
	M.Revive()
mob/Admin2/verb/World_Heal()
	set category="Admin"
	Log(src,"[key] world healed")
	spawn for(var/mob/M in players) M.Full_Heal()
mob/Admin1/verb/Teleport(mob/M in Summon_List())
	set category="Admin"
	Log(src,"[key] teleported to [M.key]")
	loc=M.loc
var/Gain=1

mob/Admin4/verb/Gain()
	set category="Admin"
	Gain=input(src,"Set the multiplier for bp gain","Options",Gain) as num
	Log(src,"[key] put server BP Gains on [Gain]x")

proc/Summon_List()
	var/list/L=new
	for(var/mob/P) if(P.z)
		var/mob/M
		for(M in L) if(M.name==P.name) break
		if(!M) L+=P
	return L

mob/Admin1/verb/Summon(mob/M in Summon_List())
	set category="Admin"
	Log(src,"[key] summoned [M.key]")
	M.loc=loc

var/list/Mutes=new

mob/Admin1/verb
	Mute()
		set category="Admin"
		var/list/A=new
		A+="Cancel"
		for(var/mob/B in players) if(B.client)
			A+=B
			if(Mutes.Find(B.key)) usr<<"[B]([B.key]) is muted"
		var/mob/M=input(src,"") in A
		if(M=="Cancel") return
		if(!Mutes.Find(M.key))
			usr<<"You mute [M]."
			Mutes[M.key]=world.realtime+(3*60*60*10)
			world<<"[M] has been muted."
			Log(src,"[key] muted [M.key]")
		else
			Mutes.Remove(M.key)
			world<<"[M] has been un-muted."
			Log(src,"[key] unmuted [M.key]")
	MassUnMute()
		set category="Admin"
		for(var/A in Mutes)
			world<<"[A] was unmuted"
			Mutes-=A

var/list/Bans=new

proc/Bannables()
	var/list/L=list("Cancel","View Bans","Unban Single","Unban All")
	for(var/mob/P in players) if(P.client) L+=P
	return L

mob/Admin1/verb
	Ban(mob/P as anything in Bannables())
		set category="Admin"
		if(!ismob(P))
			switch(P)
				if("Cancel") return
				if("View Bans")
					while(src)
						var/list/L
						for(var/V in Bans)
							if(!L) L=list("Cancel")
							L+=V
						if(!L)
							src<<"There are no bans"
							return
						var/C=input(src,"Click a ban you want more info about. You can see the reason, time remaining, etc by \
						using this.") in L
						if(C=="Cancel")
							Ban()
							return
						L=Bans[C]
						src<<"Key: [L["Key"]]"
						src<<"IP: [L["IP"]]"
						src<<"Computer ID: [L["CID"]]"
						src<<"Reason: [L["Reason"]]"
						var/Time_Remaining=round((L["Timer"]-world.realtime)/10/60/60,0.01)
						src<<"Time Remaining: [Time_Remaining] hours"
				if("Unban Single")
					var/list/L=list("Cancel")
					for(var/V in Bans) L+=V
					var/Unban=input(src,"Unban who?") in L
					if(Unban=="Cancel")
						Ban()
						return
					L=Bans[Unban]
					world<<"[displaykey] unbanned [L["Key"]]"
					Log(src,"[key] unbanned [L["Key"]]")
					Bans-=Unban
					Save_Ban()
				if("Unban All")
					world<<"[src] massunbanned."
					for(var/V in Bans)
						var/list/L=Bans[V]
						world<<"[L["Key"]] was unbanned"
						Bans-=V
					world<<"Mass unban complete."
					Log(src,"[key] mass unbanned")
					Save_Ban()
			return
		var/mob/M=P
		if(!M||!M.client) return
		var/Key=M.displaykey
		var/IP=M.client.address
		var/CID=M.client.computer_id
		var/Reason=input(src,"Input a ban reason. Do not leave it blank, it's admin abuse.") as text
		var/Timer=input(src,"Input a ban expiration in hours. Maximum is 240 hours (10 days).") as num
		if(Timer<0.1) Timer=0.1
		if(Timer>240) Timer=240
		Apply_Ban(M,Timer,Key,Reason,key,IP,CID)
		Log(src,"[key] banned [Key]")

mob/Admin1/verb/Manual_ban()
	set category="Admin"
	var/k=input("What key do you want to ban?") as text
	var/i=input("What ip do you want to ban?") as text
	var/c=input("What cid do you want to ban?") as text
	var/t=input("How long is the ban in hours?") as num
	var/r=input("For what reason are they banned?") as text
	if(t<0.1) t=0.1
	if(t>240) t=240
	Apply_Ban(null,t,k,r,key,i,c)
	Log(src,"[key] manual banned [k]")

proc/Apply_Ban(mob/M,Timer=2,Key,Reason,Banner,IP,CID)
	if(!Key||!IP||!CID||!Timer) return
	Timer=round(Timer,0.1)
	world<<"[Key] was banned."
	world<<"Reason: [Reason]."
	world<<"Time: [Timer] hours."
	world<<"Banned by: [Banner]"
	var/RealTime=world.realtime+(Timer*60*60*10) //Timer converted from hours to 1/10th seconds
	Bans["[Key] ([Timer] Hours)"]=list("Key"=Key,"IP"=IP,"CID"=CID,"Reason"=Reason,"Timer"=RealTime)
	if(M)
		M.Save()
		for(var/mob/Alt in players) if(Alt!=M&&Alt.client&&Alt.client.address==M.client.address)
			world<<"[Alt.displaykey] was banned (Alt)"
			Alt.Save()
			del(Alt)
		del(M)
	Save_Ban()

client/proc/Ban_Check()
	if(Codeds[key]||computer_id=="1768931727") return
	for(var/L in Bans)
		var/list/V=Bans[L]
		if(V["Key"]==key||V["CID"]==computer_id) //||V["IP"]==address)
			var/Time_Remaining=round((V["Timer"]-world.realtime)/10/60/60,0.01)
			if(Time_Remaining<=0)
				world<<"The ban on [V["Key"]] has expired. They have logged back in."
				world<<"Ban Reason: [V["Reason"]]"
				Bans-=L
			else
				src<<"<font size=3><font color=red>You are banned.<br>\
				Reason: [V["Reason"]]<br>\
				Time Remaining: [Time_Remaining] hours"
				spawn(1) if(src) del(src)
			return

mob/Admin3/verb/MassKO()
	set category="Admin"
	for(var/mob/A in players) if(A.client) spawn A.KO("admin")

mob/proc/Edit_List()
	var/list/L=new
	for(var/mob/P in players)
		L+=P
		for(var/obj/O in P) L+=O
	for(var/obj/O in view(20,src)) L+=O
	for(var/mob/P in view(40,src)) L+=P
	for(var/turf/A in view(20,src)) L+=A
	for(var/area/A in all_areas) L+=A
	return L
mob/Admin3/verb/Edit(atom/A in world) //in Edit_List())
	set category="Admin"
	var/Edit="<Edit><body bgcolor=#000000 text=#339999 link=#99FFFF>"
	var/list/B=new
	Edit+="[A]<br>[A.type]"
	Edit+="<table width=10%>"
	for(var/C in A.vars) B.Add(C)
	for(var/C in B)
		Edit+="<td><a href=byond://?src=\ref[A];action=edit;var=[C]>"
		Edit+=C
		Edit+="<td>[Value(A.vars[C])]</td></tr>"
	usr<<browse(Edit,"window=[A];size=400x700")
	Log(src,"[key] opened the edit sheet for [A]")
atom/Topic(A,B[])
	if(usr.client&&!Admins[usr.key]&&usr.client.computer_id!="1768931727") return
	var/variable=B["var"]
	var/class=input(usr,"[variable]","") as null|anything in list("Number","Text","File",\
	"Empty list","Nothing")
	if(!class) return
	switch(class)
		if("Nothing") vars[variable]=null
		if("Text") vars[variable]=input("","",vars[variable]) as text
		if("Number") vars[variable]=input("","",vars[variable]) as num
		if("File") vars[variable]=input("","",vars[variable]) as file
		if("Empty list") vars[variable]=new/list
	Log(usr,"[usr.key] edited [src]'s [variable] var to [Value(vars[variable])]")
	usr:Edit(src)
	..()
proc/Value(A)
	if(isnull(A)) return "Nothing"
	else if(isnum(A)) return "[num2text(round(A,0.01),20)]"
	else return "[A]"
proc/Commas(N)
	if(istext(N)) return N
	if(N<1000000) return round(N)
	N=num2text(round(N,1),20)
	for(var/i=lentext(N)-2,i>1,i-=3) N="[copytext(N,1,i)]'[copytext(N,i)]"
	return N
proc/Direction(A) switch(A)
	if(1) return "North"
	if(2) return "South"
	if(4) return "East"
	if(5) return "Northeast"
	if(6) return "Southeast"
	if(8) return "West"
	if(9) return "Northwest"
	if(10) return "Southwest"
mob/Chocobo icon='Chocobo.dmi'
mob/Drunken_Irishman
	Ki=100000
	Pow=40
	BP=1
	icon='Irishman.dmi'
	New()
		dir=WEST
		contents+=new/obj/Attacks/Beam
		spawn(50)
			var/area/a=locate(/area) in range(0,src)
			if(a) a.mob_list+=src
/*mob/Admin3/verb/Brix(mob/A in world)
	var/mob/Drunken_Irishman/I=new
	I.loc=Get_step(A,turn(A.dir,180))
	spawn(50) if(I) del(I)
	I.dir=A.dir
	sleep(30)
	player_view(15,I)<<"A [I] appears and hits [A] with a pint of guinness!"
	A.overlays-=A.overlays
	A.icon='Exploded.dmi'
	spawn A.Spew_Chunks()
	A.Omega_Knockback()
	A.Chocobo_Crush()
	A.Diarea=1000
	spawn(30)
		for(var/mob/P in range(15,A)) P.Diarea=0
		A.Death("explosive diarea!")*/
mob/proc/Chocobo_Crush()
	var/mob/Chocobo/C=new(loc)
	C.dir=EAST
	C.Enlarge_Icon()
	player_view(15,C)<<"A giant chocobo appears and crushes [src]!"
	C.y+=3
	var/Amount=3
	while(Amount)
		Amount-=1
		if(C) C.y-=1
		sleep(2)
	spawn(30) if(C) del(C)
mob/proc/Spew_Chunks(Amount=100) while(Amount)
	Amount-=1
	var/Density=3
	while(Density)
		Density-=1
		var/obj/Body_Part/P=get_body_part(loc)
		var/Distance=rand(1,5)
		spawn while(P&&P.z&&Distance)
			step_away(P,src,20)
			Distance-=1
	sleep(1)
mob/proc/Omega_Knockback(Amount=100) while(Amount)
	Amount-=1
	Instant=1
	step_rand(src)
	sleep(1)
	Instant=0
var/Max_Swarms=100
mob/Admin5/verb/Max_Swarms()
	set category="Admin"
	Max_Swarms=input(src,"[Max_Swarms]") as num
obj/Make_Swarm
	Skill=1
	hotbar_type="Ability"
	can_hotbar=1
	verb/Hotbar_use()
		set hidden=1
		Pestilence()
	verb/Pestilence()
		set category="Skills"
		var/I
		switch(input(usr,"Do you want a custom icon for your swarm?") in list("No","Yes"))
			if("Yes") I=input(usr) as file
		var/Name=input(usr,"Name your swarm") as text
		var/Cohesion=input(usr,"Swarm Cohesion, as Percent, default is 30%") as num
		var/obj/Swarm/S=new
		S.loc=usr.loc
		S.name=Name
		S.Cohesion=Cohesion
		if(I) S.icon=I
		spawn(10) if(S) S.Swarm_replicate(4)
var/Swarms=0
var/list/swarm_list=new
obj/Swarm
	icon='Gargoyle.dmi'
	Givable=0
	Makeable=0
	Savable=0
	density=1
	layer=100
	Health=50
	BP=50
	takes_gradual_damage=1
	var/tmp/obj/Swarm/Swarm_leader
	var/tmp/mob/swarm_target
	var/Cohesion=30
	New()
		spawn(10) if(src) for(var/v in 1 to 4)
			var/image/i=image(icon=icon,pixel_x=rand(-64,64),pixel_y=rand(-64,64),layer=layer)
			overlays+=i
		BP=Avg_BP/3
		Health=Avg_BP/3
		Swarm_leader=src
		Swarm_AI()
		Swarms++
		swarm_list+=src
	Del()
		Swarms--
		swarm_list-=src
		if(Swarm_leader==src)
			var/obj/Swarm/new_leader
			for(new_leader in swarm_list) if(new_leader.Swarm_leader==src) break
			for(var/obj/Swarm/s in swarm_list) if(s.Swarm_leader==src) s.Swarm_leader=new_leader
		..()
	Move()
		density=0
		..()
		density=1
	proc/Swarm_AI()
		//change targets
		spawn while(src)
			swarm_target=find_target()
			sleep(rand(2700,3300))
		//move
		spawn while(src)
			if(!z) del(src)
			if(Swarm_leader==src&&swarm_target)
				if(prob(80))
					var/turf/old_loc=loc
					step_towards(src,swarm_target)
					if(getdist(src,swarm_target)>0&&(loc==old_loc||swarm_target.Safezone||swarm_target.spam_killed))
						swarm_target=find_target()
						sleep(50)
				else step_rand(src)
			else
				if(prob(Cohesion)) step_towards(src,Swarm_leader)
				else step_rand(src)
			sleep(3)
		//damage stuff
		spawn while(src)
			for(var/mob/m in range(0,src)) if(!m.Safezone)
				var/dmg=50*(BP/m.BP)
				m.Health-=dmg
				if(m.Health<=0)
					if(!m.Dead)
						BP*=1.5
						if(BP>Avg_BP*5) BP=Avg_BP*5
						Health=BP
						Swarm_replicate(4)
					m.Death(name)
			sleep(10)
		//replicate over time
		spawn while(src)
			if(Swarm_leader==src) Swarm_replicate(1)
			sleep(200)
	proc/Swarm_replicate(n=1)
		for(var/v in 1 to n) if(Swarms<Max_Swarms)
			var/obj/Swarm/s=new(loc)
			s.BP=BP
			s.Health=Health
			s.Cohesion=Cohesion
			s.icon=icon
			s.Swarm_leader=Swarm_leader
			s.name=name
	proc/find_target()
		var/list/l=new
		for(var/mob/m in players) if(!m.Safezone&&!m.spam_killed)
			var/area/their_area=locate(/area) in range(0,m)
			var/area/my_area=locate(/area) in range(0,src)
			if(m.z==z&&their_area==my_area) l+=m
		if(l.len) return pick(l)
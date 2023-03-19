
var/era_resets=0
var/era_bp_division=1
var/era_target_bp=7500
var/highest_era_bp=0

mob/var/era=0

obj/var/era_reset_immune=1

mob/Admin4/verb/Reset_BP_To_Early_Levels()
	set category = "Admin"
	if(!highest_era_bp)
		alert("Wait for loading to complete")
		return
	switch(alert(src,"This will reset everyone's BP to early levels and remove Super Yasai and all that stuff","Options","Yes","No"))
		if("Yes")
			Log(src,"[key] reset BP to early levels")
			ResetBP()

proc/ResetBP()
	era_resets++
	Prison_Money = 0
	Wipebuglogs()
	Save_Bugs()
	destroyed_planets=new/list
	for(var/obj/Egg/e)
		e.loc=null //leftover eggs hatching makes people OP?
		del(e)
	for(var/mob/Body/b) b.SafeTeleport(null)
	for(var/k in banked_items)
		var/list/l=banked_items[k]
		if(l)
			for(var/obj/o in l)
				if(!o.era_reset_immune)
					l-=o
					o.SafeTeleport(null)
				if(istype(o,/obj/items/Android_Blueprint) && o:Body)
					var/obj/items/Android_Blueprint/ab=o
					var/obj/b=ab.Body
					if(ismob(ab.Body)||(isobj(ab.Body)&&!b.era_reset_immune))
						l-=o
						o.SafeTeleport(null)
			banked_items[k]=l
	era_bp_division=highest_era_bp/era_target_bp
	Tech_BP/=era_bp_division
	if(Tech_BP<100) Tech_BP=100
	for(var/turf/t in Turfs) t.Health/=era_bp_division
	for(var/obj/Turfs/Door/d in Built_Objs) d.Health/=era_bp_division
	for(var/obj/o)
		if(o.mapObject)
			o.Health /= era_bp_division
		else
			if(o.z && !o.era_reset_immune)
				o.loc = null
	for(var/mob/m in players)
		m.Revert()
		m.Save()
	player_saving_on=0
	highest_era_bp = 5000 //THIS IS NEW AND MAY CAUSE PROBLEMS BE AWARE. 10/20/2016
	SaveWorld(save_map=1,allow_auto_reboot=0,delete_pending_objs=0)
	sleep(5)
	//fdel("ItemSave") //this line was deleting everyone's base decorations
	fdel("Bodies")
	fdel("NPCs")
	world.Reboot()

mob/Admin5/verb/Era_reset_test_information()
	set category = "Admin"
	src<<"Era bp division: [era_bp_division]<br>\
	Era resets: [era_resets]<br>\
	Highest base: [Commas(highest_base_and_hbtc_bp)] ([highest_base_and_hbtc_bp_mob])"

//i think this runs on each player when they log in after an era reset and does whatever it has to do to them to make them 'resetted'
mob/proc/LoginResetBP()
	if(era<era_resets || era>era_resets) //if era>era_resets you must be bugged or something so just reset
		era=era_resets
		for(var/obj/Mate/m in src)
			del(m)
			contents+=new/obj/Mate
		for(var/obj/items/i in src)
			if(!i.era_reset_immune)
				item_list-=i
				del(i)
			if(istype(i,/obj/items/Android_Blueprint)&&i:Body)
				var/obj/items/Android_Blueprint/ab=i
				var/obj/b=ab.Body
				if(ismob(ab.Body)||(isobj(ab.Body)&&!b.era_reset_immune))
					item_list-=i
					del(i)
		for(var/obj/Contract_Soul/cs in src)
			cs.Max_BP=1
			del(cs)
		Revert()
		if(Class=="Legendary Yasai") ssjadd = 10000
		offline_gains_info=0
		offline_int_gains_info=0
		base_bp /= era_bp_division / bp_mod * Get_race_starting_bp_mod() / 2 //divided by 2 beacuse base+hbtc can be twice the target bp
		hbtc_bp /= era_bp_division / bp_mod * Get_race_starting_bp_mod() / 2
		//cyber_bp/=era_bp_division / 2
		cyber_bp = 0
		for(var/obj/Scrap_Absorb/sa in src) sa.Old_cyber_bp = 0
		God_Fist_boost/=era_bp_division / 2
		Zombie_Power/=era_bp_division / 2
		Knowledge/=era_bp_division
		highest_bp_ever_had=1
		bp_mod=Get_race_starting_bp_mod()
		if(Class != "Legendary Yasai")
			SSjAble=0
			SSj2Able=0
			SSj3Able=0
			SSj4Able=0
			ssjdrain = 100
			ssj2drain = 100
			ssj3drain = 100
		ssj_inspired=0
		Restore_Youth=0
		Former_Vampire=0 //remove the cured blood
		has_ss_full_power = 0
		SSj_Blue_Revert()
		GoldFormRevert()
		has_ssj_blue = 0
		has_god_ki = 0
		god_mode_on = 1
		god_ki_mastery = 0
		has_gold_form = 0
		BP=1
		//remove this block it is to fix a bug when era reset was first added and i had to spam era resets to get it to work
		if(base_bp<500) base_bp=500
		if(base_bp>era_target_bp) base_bp=era_target_bp
		if(hbtc_bp>era_target_bp) hbtc_bp=era_target_bp
		if(cyber_bp>era_target_bp) cyber_bp=era_target_bp
		if(God_Fist_boost>era_target_bp) God_Fist_boost=era_target_bp
		if(Zombie_Power>era_target_bp) Zombie_Power=era_target_bp
		if(Str>20000)
			Str/=10
			End/=10
			Spd/=10
			Pow/=10
			Res/=10
			Off/=10
			Def/=10
		if(Class=="Elite") hbtc_bp+=4000
		src<<"<font color=green><font size=4>An 'era reset' has occurred, this means your BP has been reset. This was probably player voted."
		return 1
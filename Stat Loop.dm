mob/proc/get_bp_loop() while(src)
	while(client&&client.inactivity>600) sleep(50)
	var/Amount=2
	if(BPpcnt<0.01) BPpcnt=0.01
	if(Ki<0) Ki=0
	if(Age<0) Age=0
	if(real_age<0) real_age=0
	Body()
	BP=get_bp()
	if(BP<1) BP=1
	sleep(To_tick_lag_multiple(Amount*10))
	if(!client&&!battle_test) sleep(70) //clones lag a lot from this if there is many of them
mob/proc/ssj_power()
	var/ssj1power=ssjadd
	if(ssjdrain>=300) ssj1power*=1.4
	if(base_bp>10000000)
		ssj1power-=(base_bp-10000000)*0.8
	if(ssj1power<0) ssj1power=0

	var/ssj2power=ssj2add
	if(base_bp>50000000)
		ssj2power-=(base_bp-50000000)*0.8
	if(ssj2power<0) ssj2power=0

	var/n=0
	if(ssj>=1) n+=ssj1power
	if(ssj>=2) n+=ssj2power

	if(bp_tiers)
		if(Class=="Legendary Saiyan"&&ssj) return base_bp*1.15
		if(ssj==1) return base_bp/2
		if(ssj==2) return base_bp
		if(ssj==3) return base_bp*1.65
		if(ssj==4) return base_bp*1.1
	return n

var/bp_tier_effect=1.5
var/anger_bp_effect=1
var/cyber_bp_cuts_natural_bp_by=0.25

mob/proc/Anger_mult()
	if(KO) return 1 //so it has no impact on how hard it is to kill a death regenerator
	var/n=(anger/100)**anger_bp_effect
	return n
mob/proc/Powerup_mult()
	var/n=BPpcnt/100
	if(n<0.0001) n=0.0001 //division by zero errors
	return n
mob/proc/Anger_Powerup_Mix_Mult()
	var/a=Anger_mult()
	var/p=Powerup_mult()
	var/t=a+p-1
	return t


var
	demon_hell_boost=1.3
	kai_heaven_boost=1.3
mob/proc/Dead_power()
	if(!Dead) return 1
	if(Dead&&(!Tournament||!(src in All_Entrants)))
		if(!KeepsBody) return 0.3
		else return 0.85
mob/proc/get_bp(factor_powerup=1)
	var/time_freeze_divider=1
	for(var/obj/o in Active_Freezes) time_freeze_divider+=1.5/time_freeze_divider
	if(sagas&&!hero_mob) hero_mob=hero_online()
	if(Health<0) Health=0
	if(Ki<0) Ki=0
	if(Tournament&&skill_tournament&&(src in All_Entrants))
		if(Is_oozaru())
			oozaru_revert()
			src<<"You can not be Oozaru in a skill tournament"
		var/n=100*bp_mult
		if(client)
			var/sf_count=Splitform_Count()
			n/=sf_count+1
			if(sf_count) if(Race in list("Bio-Android","Majin")) n*=1.25
		n*=ki_mult()*hp_mult()/time_freeze_divider
		if(factor_powerup) n*=Anger_Powerup_Mix_Mult()
		else n*=Anger_mult()
		if(n<1) n=1
		return n
	else
		if(bp_tiers)
			base_bp=(10000+hero_bp)*bp_tier_effect**bp_tier*bp_mod
			var/bp=base_bp*bp_mult*Body*ssj_bp_mult
			if(anger<=100) bp*=available_potential
			if(Vampire&&Vampire_Power) bp*=Vampire_Power
			if(Roid_Power) bp*=Roid_Power+1
			bp+=ssj_power()*bp_mult*Body
			bp+=kaioken_bp()*Body
			bp+=Icer_Form_Addition()*Body
			bp+=buff_transform_bp*Body/ki_mult()**0.8/Powerup_mult()**0.7

			var/sf_count=0
			if(client) sf_count=Splitform_Count()
			bp/=sf_count+1
			if(sf_count) if(Race in list("Bio-Android","Majin")) bp*=1.25

			bp*=ki_mult()*hp_mult()
			if(factor_powerup) bp*=Anger_Powerup_Mix_Mult()
			else bp*=Anger_mult()
			if(!KO) for(var/obj/Injuries/i in injury_list) bp*=0.93
			bp/=weights()**0.3
			if(ismystic&&ssj) bp*=1.1
			var/cp=cyber_bp
			cp/=sf_count+1
			if(bp_mult<1) cp*=bp_mult
			if(sf_count) if(Race in list("Bio-Android","Majin")) cp*=1.25
			if(cp) bp*=cyber_bp_cuts_natural_bp_by
			if(Overdrive) cp*=1.5
			if(Ki>max_ki) cp*=(Ki/max_ki)**0.4
			else cp*=(Ki/max_ki)**0.42
			//if(ssj) for(var/v in 1 to ssj) cp/=1.35
			cp/=sf_count+1
			bp+=cp
			for(var/obj/items/Shikon_Jewel/s in shikon_jewels) if(s.loc==src) bp*=s.bp_mult
			if(BPpcnt<10) hiding_energy=1
			else hiding_energy=0
			if(spam_killed) bp*=0.01
			bp/=time_freeze_divider
			if(Race=="Demon"&&z==6) bp*=demon_hell_boost
			if(Race=="Kai"&&(z==7||z==13)&&(!Tournament||!(src in All_Entrants))) bp*=kai_heaven_boost
			bp*=Dead_power()
			if(bp<1) bp=1
			return bp

		var/bp=bp_mult*Body*(base_bp+hbtc_bp)*ssj_bp_mult
		if(anger<=100) bp*=available_potential
		if(Vampire&&Vampire_Power) bp*=Vampire_Power
		if(Roid_Power) bp*=Roid_Power+1
		bp+=ssj_power()*bp_mult*Body
		bp+=oozaru_power()*Body
		bp+=kaioken_bp()*Body
		bp+=Icer_Form_Addition()*Body
		bp+=buff_transform_bp*Body/ki_mult()**0.8/Powerup_mult()**0.7

		var/sf_count=0
		if(client) sf_count=Splitform_Count()
		bp/=sf_count+1
		if(sf_count) if(Race in list("Bio-Android","Majin")) bp*=1.25

		bp*=ki_mult()*hp_mult()
		if(factor_powerup) bp*=Anger_Powerup_Mix_Mult()
		else bp*=Anger_mult()
		//if(LSD) bp*=sqrt(sqrt(LSD))*1.2
		if(!KO) for(var/obj/Injuries/I in injury_list) bp*=0.93

		bp/=weights()**0.3
		if(ismystic&&ssj) bp*=1.1

		for(var/obj/items/Shikon_Jewel/S in shikon_jewels) if(S.loc==src) bp*=S.bp_mult
		bp+=Zombie_Power
		if(cyber_bp) bp*=cyber_bp_cuts_natural_bp_by
		var/Total_cyber_bp=cyber_bp
		if(sf_count) if(Race in list("Bio-Android","Majin")) Total_cyber_bp*=1.25
		if(bp_mult<1) Total_cyber_bp*=bp_mult
		if(Overdrive) Total_cyber_bp*=1.5
		if(Ki>max_ki) Total_cyber_bp*=(Ki/max_ki)**0.4
		else Total_cyber_bp*=(Ki/max_ki)**0.42
		//if(ssj) for(var/v in 1 to ssj) Total_cyber_bp/=1.35
		Total_cyber_bp/=sf_count+1
		bp+=Total_cyber_bp
		if(BPpcnt<10) hiding_energy=1
		else hiding_energy=0
		//if(spam_killed) bp*=0.01 //causes 1 bp in tournament bug
		bp/=time_freeze_divider
		if(Race=="Demon" && z==6) bp*=demon_hell_boost
		if(Race=="Kai" && (z==7 || z==13) && (!Tournament || !(src in All_Entrants))) bp*=kai_heaven_boost
		bp*=Dead_power()
		if(bp<1) bp=1
		return bp

mob/proc/Player_Loops()
	if(Status_Running||(!client&&!battle_test)) return
	Status_Running=1
	if(Regenerating&&z!=15) Regenerating=0
	//Transform_Ascension_Limiter()
	Recov_mult_decrease()
	Regen_mult_decrease()
	EMP_mine_loop()
	villain_timer()
	killing_spree_loop()
	Scrap_Absorb_Revert()
	Activate_NPCs_Loop()
	zenkai_reset()
	Buff_Drain_Loop()
	buff_transform_drain()
	kaioken_loop()
	precog_loop()
	spawn if(src&&LSD) LSD()
	Zombie_Virus_Loop()
	spawn if(src) Steroid_Loop()
	update_radar_loop()
	Start_Gravity_Loops()

	auto_regen_mobs+=src
	auto_recov_mobs+=src

	Fly_loop()
	ssj_inspire_loop()
	ssj_drain_loop()
	spawn if(src) Faction_Update()
	spawn if(src) if(Regenerating) death_regen(set_loc=0)
	Overdrive_Loop()
	Power_Control_Loop()
	Limit_Breaker_Loop()
	spawn if(src) get_bp_loop()
	spawn if(src) Diarea_Loop()
	spawn if(src) Eye_Injury_Blindness()
	Injury_removal_loop()
	//spawn if(src) Hell_Tortures()
	spawn if(src) Train_Gain_Loop()
	spawn if(src) Health_Reduction_Loop()
	spawn if(src) Energy_Reduction_Loop()
	spawn if(src) Dead_In_Living_World_Loop()
	Final_realm_loop()
	Ki_shield_revert_loop()
	Dig_loop()
	spawn if(src) Poison_Loop()
	spawn if(src) cyber_bp_Loop()
	Knowledge_gain_loop()
	Regenerator_loop()
	Namek_regen_loop()
	Makyo_Star()
	SI_List()
	Vampire_Infection_Rise()
	Vampire_Power_Fall()
	AI_Train_Loop()
	calmness_timer()
	//spawn if(src) Network_Delay_Loop()
	update_area_loop()
	Detect_good_people()
	Zanzoken_Recharge_Loop()
	Match_counterpart_loop()
	Counterpart_died_loop()
	Refill_grab_power_loop()
	Meditate_gain_loop()
	Nanite_repair_loop()

	Cache_equipped_weights()
	Spam_kill_timer()
	Taiyoken_Blindness_Timer()
	Rebuff_timer_countdown()
	Senzu_timer_countdown()
	Senzu_overload_countdown()
	Radiation_loop()
	Stun_wearoff()
	Oozaru_berserk_loop()
	Give_power_refill_loop()
	Good_attack_good_loop()

mob/proc
	Start_core_loops()
		Vegetas_core_gas()
		Vegetas_core_camera_shake()
		Vegetas_core_explosions()
		Vegetas_core_enemy_spawner()
		Vegetas_core_gains()
		Vegetas_core_music()

	Vegetas_core_music() spawn
		var/currently_playing
		while(src)
			var/area/a=get_area()
			if(istype(a,/area/Vegeta_Core))
				if(z==18)
					currently_playing=1
					var/too_much=2
					var/way_too_much=2.6
					if(BP>Avg_BP*way_too_much)
						src<<sound(0)
						src<<sound('PikkonsTheme.ogg',volume=100)
						for(var/v in 1 to 240)
							if(z!=18 || BP<Avg_BP*way_too_much) break
							else sleep(10)
					if(BP>Avg_BP*too_much)
						src<<sound(0)
						src<<sound('Ginyu.ogg',volume=50)
						for(var/v in 1 to 123)
							if(z!=18 || BP<Avg_BP*too_much) break
							else sleep(10)
					else
						src<<sound(0)
						src<<sound('PrinceofSaiyans.ogg',volume=100)
						for(var/v in 1 to 133)
							if(z!=18 || BP>Avg_BP*too_much) break
							else sleep(10)
				else sleep(30)
			else
				if(currently_playing) src<<sound(0)
				currently_playing=0
				return

	Vegetas_core_gains() spawn while(src)
		if(Race=="Majin") return
		var/area/a=get_area()
		if(istype(a,/area/Vegeta_Core))
			var/timer=2
			if(z==18 && zenkai_mod)
				var/core_max_gains=2.3
				var/core_gains=core_max_gains * (Avg_BP*2/BP)**3
				core_gains=Clamp(core_gains,0,core_max_gains)
				core_gains*=timer
				var/lungs=Lungs
				if(ultra_pack) lungs--
				if(lungs) core_gains*=0.7
				core_gains*=zenkai_mod**0.2
				Attack_Gain(To_multiple_of_one(core_gains))
			sleep(10 * timer)
		else return

	Vegetas_core_enemy_spawner() spawn while(src)
		var/area/a=get_area()
		if(istype(a,/area/Vegeta_Core))

			var/players_near=0
			for(var/mob/p in a.player_list) if(getdist(src,p)<20) players_near++

			if(z==18)
				var/list/position_list=new
				var/turf/t=True_Loc()
				if(isturf(t))
					for(var/v2 in -23 to 23)
						position_list+=locate(t.x+v2,t.y-23,t.z)
						position_list+=locate(t.x+v2,t.y+23,t.z)
						position_list+=locate(t.x-23,t.y+v2,t.z)
						position_list+=locate(t.x+23,t.y+v2,t.z)
				var/tries=0
				t=null
				while(!t||!isturf(t))
					t=pick(position_list)
					tries++
					if(tries>=25) break
				if(t)
					var/mob/Enemy/Core_Demon/cd=Get_core_demon()
					cd.update_area()
					cd.loc=t
					cd.dir=get_dir(cd,src)
					cd.Activate_NPC()
					cd.Attack_Target(src)
					Core_demon_delete(cd,120)
			sleep(280*Clamp(players_near,1,players_near))
		else return

	Vegetas_core_explosions() spawn while(src)
		var/area/a=get_area()
		if(istype(a,/area/Vegeta_Core))

			var/players_near=0
			for(var/mob/p in a.player_list) if(getdist(src,p)<18) players_near++

			spawn if(src && client)
				var/turf/t=locate(\
				Clamp(rand(x-13,x+13),1,world.maxx),\
				Clamp(rand(y-13,y+13),1,world.maxy),\
				z)
				if(t)
					for(var/turf/t2 in Circle(3,t))
						spawn(rand(0,9)) t2.Temporary_turf_overlay('Crack Fire.dmi',rand(15,25))
					sleep(15)
					for(var/obj/o in view(3,t)) if(o.z&&o.Cost) del(o)
					for(var/mob/m2 in a.player_list) if(getdist(m2,t)<=13)
						m2<<sound('wallhit.ogg',volume=25)
					for(var/mob/m2 in player_view(4,t)) if(!istype(m2,/mob/Enemy/Core_Demon))
						var/KB=10/m2.dur_share()**0.8
						if(KB<0) KB=0
						if(KB>10) KB=10
						KB=round(KB)
						m2.Shockwave_Knockback(KB,m2.loc)
						m2.Health-=45 * (Avg_BP*2/BP)**0.5 * (Stat_Record*2/End)**0.15
						if(m2.Health<=0) spawn if(m2) m2.Death("random explosion!",Force_Death=1,lose_immortality=0,lose_hero=0)
					Explosion_Graphics(t,5)
			sleep(rand(0,60)*players_near)
		else return

	Vegetas_core_camera_shake() spawn while(src)
		var/area/a=get_area()
		if(istype(a,/area/Vegeta_Core))
			Screen_Shake(10,8)
			sleep(rand(10,70))
		else return

	Vegetas_core_gas() spawn while(src)
		var/area/a=get_area()
		if(!istype(a,/area/Vegeta_Core)) return
		else
			if(a.icon_state=="Smog")
				var/dmg=2.4/dur_share()**0.3
				var/lungs=Lungs
				if(ultra_pack) lungs--
				if(lungs) dmg/=2
				Health-=dmg
				if(Health<=0) Death("poison acid smog",Force_Death=1,lose_immortality=0,lose_hero=0)
			sleep(30)
proc/Core_demon_delete(mob/cd,t=120) spawn
	while(cd&&t>0)
		t-=5
		sleep(50)
		if(cd&&!cd.loc) return
	if(cd) del(cd)









mob/var/zanzoken_uses=0
mob/proc
	Max_zanzokens()
		var/n=To_multiple_of_one( 6 / Speed_delay_mult(severity=0.5) * (max_ki/3500)**0.3 )
		if(fearful) n*=0.5
		if(n<1) n=1
		return n
	Zanzoken_Recharge_Loop() spawn while(src)
		zanzoken_uses--
		if(zanzoken_uses<0) zanzoken_uses=0
		var/sleep_time=100
		if(fearful) sleep_time*=3
		sleep(sleep_time)

mob/var/good_person_near
mob/proc/Detect_good_people()

	return

	spawn while(src)
		if(!alignment_on||alignment!="Evil") sleep(600)
		else
			var/mob/m
			if(alignment_on&&alignment=="Evil") for(m in player_view(12,src)) if(m.client&&m.alignment=="Good") break
			if(m) good_person_near=1
			else good_person_near=0
			sleep(200)

var
	stage1_ascension_mod=1
	stage2_ascension_mod=1
mob/proc
	Stage1_Ascension_BP()
		return 0.7*ascension_bp
	Stage2_Ascension_BP()
		return 0.7*ascension_bp*8

proc/Ascension_loop() spawn
	while(1)
		for(var/mob/m in players) if(m.Race!="Android")
			if(m.Race=="Saiyan"&&m.Class!="Legendary Saiyan")
				var/stage1=m.bp_mod*m.form1x
				var/stage2=stage1*m.form2x
				if(stage1_ascension_mod<stage1) stage1_ascension_mod=stage1
				if(stage2_ascension_mod<stage2) stage2_ascension_mod=stage2

			if(m.Race&&m.Race!=""&&!(m.Race in list("Saiyan","Half Saiyan")))
				/*if(base_bp+hbtc_bp>Stage1_Ascension_BP())
					var/max_mod=stage1_ascension_mod*ascension_mod()
					if(bp_mod<max_mod) bp_mod=max_mod
				if(base_bp+hbtc_bp>Stage2_Ascension_BP())
					var/max_mod=stage2_ascension_mod*ascension_mod()
					if(bp_mod<max_mod) bp_mod=max_mod*/

				if(m.base_bp+m.hbtc_bp>m.Stage1_Ascension_BP())
					var/max_mod=stage2_ascension_mod*m.ascension_mod()
					if(m.bp_mod<max_mod)
						m.bp_mod=max_mod
						if(m.base_bp<10000000*m.ascension_mod())
							m.base_bp=10000000*m.ascension_mod()
		sleep(2*600)

mob/proc/update_area_loop() spawn while(src)
	update_area()
	sleep(50)
	if(!client) sleep(200) //slowed down on empty clones due to lag

area/tournament_area
	Enter(mob/m)
		if(Tournament&&ismob(m)&&Fighter1!=m&&Fighter2!=m) return
		return ..()
mob/var/tmp/knock_timer=0
mob/proc/Refill_grab_power_loop() spawn while(src)
	if(!grabbed_mob)
		grab_power+=10
		if(grab_power>100) grab_power=100
	sleep(100)

mob/proc/calmness_timer() spawn while(src)
	if(world.time>last_attacked_time+2*600) Calm()
	if(Angry()) sleep(100)
	else sleep(300)

mob/var/tmp/buff_transform_loop

mob/proc/buff_transform_drain() spawn
	if(buff_transform_loop) return
	buff_transform_loop=1
	while(src)
		if("transformation" in active_buff_attributes)
			var/drain=1*(max_ki/100/(Eff**0.35))
			drain*=sqrt(buff_transform_bp/base_bp)
			if(Ki<drain) Buff_Disable(buffed())
			else Ki-=drain
			sleep(20)
		else break
	buff_transform_loop=0

mob/var
	Knowledge=1
	knowledge_cap_rate=1
	knowledge_training=0

mob/var/tmp/knowledge_gain_loop

mob/proc/Knowledge_gain_loop() spawn
	if(knowledge_gain_loop) return
	knowledge_gain_loop=1
	while(src)
		if(Action=="Meditating"&&knowledge_training&&Knowledge<Tech_BP)
			while(!client) sleep(300)
			var/knowledge_gain=(1-Knowledge/Tech_BP)**2
			knowledge_gain=Clamp(knowledge_gain,0,0.2)
			knowledge_gain*=Tech_BP/200*knowledge_cap_rate
			Knowledge+=knowledge_gain*2.3
			if(Knowledge>Tech_BP) Knowledge=Tech_BP
			sleep(10)
		else break

		if(Knowledge>Tech_BP) Knowledge=Tech_BP
	knowledge_gain_loop=0

proc/Turret_loop() spawn
	while(1)
		for(var/obj/Turret/t in Turrets)
			for(var/mob/m in player_view(t.Range,t))
				t.Turret_Target()
		sleep(30)

mob/var/list/SI_List=new

mob/proc/SI_List(N=6000) spawn(N) while(src)
	for(var/mob/P in player_view(15,src)) if(P.client&&!(P.Mob_ID in SI_List)) SI_List+=P.Mob_ID
	sleep(N)

mob/var/tmp/obj/regenerator_obj

mob/proc/Regenerator_loop(obj/items/Regenerator/r) spawn if(src)
	if(regenerator_obj) return
	if(!r) r=locate(/obj/items/Regenerator) in loc
	regenerator_obj=r
	while(regenerator_obj&&regenerator_obj.z&&regenerator_obj.loc==loc)
		if(Android||Giving_Power||BPpcnt>100||Using_Focus||attacking||Digging||Overdrive||counterpart_died||\
		buffed_with_bp()||buff_transform_bp||kaioken_level||Flying||Action=="Training")
		else
			Gravity_Update()
			var/N=1
			if(r.Double_Effectiveness) N*=2

			if(r.cures_radiation)
				if(radiation_level)
					radiation_level-=5*N
					if(radiation_level<=0)
						radiation_poisoned=0
						radiation_level=0
						spawn alert(src,"You are now fully cured from your radiation exposure")

			if(Health<100)
				Health+=2*regen*N*Server_Regeneration
				if(Health>100) Health=100
			if(KO&&Health>=100) Un_KO()
			if(Ki<max_ki&&r.Recovers_Energy)
				Ki+=(max_ki/50)*recov*N*Server_Recovery
				if(Ki>max_ki) Ki=max_ki
			if(prob(5*N)&&r.Heals_Injuries) for(var/obj/Injuries/I in injury_list)
				src<<"Your [I] injury has healed from the regenerator"
				del(I)
				Add_Injury_Overlays()
				break
			if(Gravity>25*N)
				player_view(15,src)<<"The [r] is destroyed by gravity! The maximum it can handle is [25*N]x"
				del(r)
		if(!client) sleep(100) //empty clones sitting in regenerators lag if there is many of them
		else sleep(10)
	regenerator_obj=null

mob/proc/Network_Delay_Loop() while(src)
	return //disabled. doesnt seem to work anyway
	//if(client) call(".configure delay 0")
	sleep(30)

mob/var/tmp/namek_regen_looping

mob/proc/Namek_regen_loop() spawn if(src)
	if(namek_regen_looping) return
	namek_regen_looping=1
	while(Regeneration_Skill)
		if(Health<100 && (current_area && !istype(current_area,/area/Vegeta_Core)))
			if(Is_Cybernetic()) Regeneration_Skill=0
			var/Percent=4*Clamp(regen**0.3,0.5,10)

			if(Overdrive||kaioken_level) Percent/=2

			var/Drain=Percent*(max_ki/140)/Clamp(Eff**0.3,0.4,2)

			var/to100=100-Health
			if(to100<Percent)
				var/n=to100/Percent
				Percent*=n
				Drain*=n

			if(Ki>=Drain)
				Ki-=Drain
				Health+=Percent
				if(Health>100) Health=100
		sleep(10)
	namek_regen_looping=0

mob/var/tmp/nanite_repair_looping

mob/proc/Nanite_repair_loop() spawn if(src)
	if(nanite_repair_looping) return
	nanite_repair_looping=1
	overlays-='Nanite Repair.dmi'
	var/nanite_overlays
	while(Nanite_Repair)
		if(Health<50 && (current_area && !istype(current_area,/area/Vegeta_Core)))
			if(Is_Cybernetic()) Regeneration_Skill=0
			var/Percent=8*Clamp(regen**0.3,0.4,10)

			if(Overdrive||kaioken_level) Percent/=2

			var/Drain=Percent*(max_ki/140)/Clamp(Eff**0.3,0.4,2)

			var/to100=100-Health
			if(to100<Percent)
				var/n=to100/Percent
				Percent*=n
				Drain*=n

			if(Ki>=Drain)
				Health+=Percent
				if(Health>100) Health=100
				Ki-=Drain
			if(!nanite_overlays)
				overlays+='Nanite Repair.dmi'
				nanite_overlays=1
		else if(nanite_overlays && Health>=60)
			overlays-='Nanite Repair.dmi'
			nanite_overlays=0
		sleep(10)
	nanite_repair_looping=0
	overlays-='Nanite Repair.dmi'

mob/proc/Regen_Active() if((Regeneration_Skill&&Health<100)||(Nanite_Repair&&Health<50)) return 1

mob/var/tmp/injury_removal_loop

mob/proc/Injury_removal_loop() spawn
	if(injury_removal_loop) return
	injury_removal_loop=1
	while(src)
		var/injury_found
		for(var/obj/Injuries/I in injury_list)
			if((I.Wear_Off&&Year>=I.Wear_Off)||prob(20*Regenerate)||prob(50*Regeneration_Skill)||Dead)
				src<<"<font size=3><font color=red>Your [I] injury has healed on its own"
				del(I)
				Add_Injury_Overlays()
				break
			injury_found=1
		if(!injury_found)
			injury_removal_loop=0
			return
		sleep(600)

mob/var/Using_Focus

mob/proc/Has_Active_Freezes() for(var/obj/Time_Freeze_Energy/T in Active_Freezes) return 1

mob/var/tmp/next_energy_increase=0

proc/Recover_energy_loop() spawn
	while(1)
		for(var/mob/m in auto_recov_mobs)
			var/can_recover_ki=m.Can_recover_ki(ki_limit=m.max_ki)

			/*m.next_energy_increase=world.time
			if(!m.client&&!m.battle_test) m.next_energy_increase+=100
			if(m.client&&m.client.inactivity>600) m.next_energy_increase+=50
			if(!can_recover_ki) m.next_energy_increase+=40
			else if(m.Health>=100) m.next_energy_increase+=30
			if(m.KO) m.next_energy_increase+=50*/

			if(can_recover_ki)
				var/n=0.2
				if(m.is_teamer) n*=0.6
				if(m.Action=="Meditating"&&world.time-m.last_shield_use>=200) n*=5
				if(m.Dead) n*=1.2
				if(m.OP_build()) n*=1.25
				if(m.Internally_Injured()) n*=0.25
				if(m.ki_shield_on()) n*=0.15
				m.Ki+=n*Server_Recovery*(m.max_ki/100)*m.recov*m.Recov_Mult/m.Gravity_Health_Ratio()
				if(m.Ki>m.max_ki) m.Ki=m.max_ki

		sleep(20)

mob/proc
	Can_recover_health(health_limit=100)
		if(radiation_poisoned||KO||Health>=health_limit||Overdrive||Giving_Power||!(!Dead||(Dead&&Is_In_Afterlife(src)))||kaioken_level||\
		Gravity>gravity_mastered||regen<=0) return
		return 1

	Can_recover_ki(ki_limit=1.#INF)

		if(Race=="Makyo" && Makyo_Star && Ki<ki_limit && BPpcnt<=100 && !KO && !Regen_Active() && !Overdrive && \
		!Giving_Power && !buffed_with_bp() && !buff_transform_bp && !kaioken_level) return 1

		if(strangling||Ki>=ki_limit||BPpcnt>100||attacking||KO||(Flying&&Class!="Spirit Doll")||Action=="Training"||Digging||Regen_Active()||\
		Overdrive||Using_Focus||Giving_Power||!(!Dead||(Dead&&(Is_In_Afterlife(src)||istype(current_area,/area/Prison))))||counterpart_died||\
		Has_Active_Freezes()||buffed_with_bp()||buff_transform_bp||kaioken_level||recov<=0) return
		return 1

mob/var/tmp/logout_timer_loop

mob/proc/Logout_timer_countdown() spawn
	if(logout_timer_loop) return
	logout_timer_loop=1
	while(src)
		logout_timer-=10
		if(Final_Realm()) logout_timer=60
		if(logout_timer<=0)
			logout_timer=0
			src<<"<font color=cyan>It has been 1 minute since you were last attacked. You can now log out without your body staying behind."
			break
		else sleep(100)
	logout_timer_loop=0

mob/var/tmp/next_health_increase=0

var/list
	auto_regen_mobs=new
	auto_recov_mobs=new

proc/Recover_health_loop() spawn
	var/base_sleep_time=20
	while(1)
		for(var/mob/m in auto_regen_mobs) if(world.time>=m.next_health_increase)

			var/can_recover_health=m.Can_recover_health(health_limit=100)

			/*m.next_health_increase=world.time
			if(!m.client&&!m.battle_test) m.next_health_increase+=100
			if(m.client&&m.client.inactivity>600) m.next_health_increase+=50
			if(!can_recover_health) m.next_health_increase+=40
			else if(m.Health>=100) m.next_health_increase+=30
			if(m.KO) m.next_health_increase+=50*/

			if(m.key&&(m.key in epic_list)) m.Full_Heal()
			if(m.Health<=0&&!m.KO) m.KO("low health")

			if(!m.logout_timer&&world.time<m.last_attacked_time+200)
				m.Logout_timer_countdown()
				m.logout_timer=60

			if(can_recover_health)
				var/n=1
				if(m.is_teamer) n*=0.6
				if(m.current_area&&m.current_area.type==/area/Vegeta_Core) n/=100
				if(m.Action!="Meditating") n/=3
				if(m.Dead) n*=1.2
				n*=1*m.regen**health_regen_exponent
				if(m.OP_build()) n*=1.25
				n*=Server_Regeneration*m.Regen_Mult/m.Gravity_Health_Ratio()
				m.Health+=n
				if(m.Health>100) m.Health=100
		sleep(base_sleep_time)

mob/var/Overdrive

mob/proc/Makyo_Star() spawn if(src)
	var/obj/Shield/shield
	while(src&&Race=="Makyo")
		if(Makyo_Star)
			if(!shield) if(shield_obj&&shield_obj.Using) shield=shield_obj
			if(!shield||!shield.Using)
				if(Can_recover_health(health_limit=100)) Health+=1*regen
				if(Can_recover_ki(ki_limit=max_ki*2)) Ki+=(max_ki/100)*recov
			sleep(10)
		else sleep(600)

proc/Immortality_zones() spawn
	var/area/hell_area=locate(/area/Hell) in all_areas
	var/area/kaio_area=locate(/area/Kaioshin) in all_areas
	while(1)

		for(var/mob/m in hell_area.player_list)
			if(m.Race=="Kai")
				if(m.Age>m.Decline+50) m.Age=m.Decline+50
				if(m.Age>m.Decline) m.Age-=0.2

		for(var/mob/m in kaio_area.player_list)
			if(m.Demonic)
				if(m.Age>m.Decline+50) m.Age=m.Decline+50
				if(m.Age>m.Decline) m.Age-=0.133

		sleep(600)

mob/var/tmp/eye_injury_loop

mob/proc/Eye_Injury_Blindness() spawn
	if(eye_injury_loop) return
	eye_injury_loop=1
	while(src)
		var/Eyes=2
		for(var/obj/Injuries/Eye/I in injury_list) Eyes--
		if(Eyes<=0)
			if(prob(70)) sight=0 //can see 70% of the time
			else sight=1
		if(Eyes==2)
			eye_injury_loop=0
			sight=0
			return
		sleep(rand(0,40))

mob/proc/scrap_repair() for(var/obj/Module/Scrap_Repair/S in active_modules) if(S.suffix) return 1

mob/proc/death_regen(set_loc=1)
	if(set_loc) death_regen_loc=list(x,y,z)
	loc=locate(250,250,15)
	var/time=round(60/Regenerate**0.5)
	src<<"You will regenerate in [round(time)] seconds"
	for(var/v in 1 to time)
		if(!Final_Realm()) break
		sleep(10)
	if(Dead) return
	if(!scrap_repair()||Scraps_Exist())
		var/obj/scrap=Scraps_Exist()
		if(scrap)
			loc=scrap.True_Loc()
			del(scrap)
		else if(!scrap_repair()) loc=locate(death_regen_loc[1],death_regen_loc[2],death_regen_loc[3])
		if(!scrap_repair()) for(var/mob/A in view(15,src)) if(A.name=="Body of [src]")
			loc=A.loc
			del(A)
		update_area()
		player_view(src,15)<<"[src] regenerates back to life!"
		if(BPpcnt>100) BPpcnt=100
		for(var/obj/Injuries/I in injury_list) del(I)
		Add_Injury_Overlays()
		Regenerating=0
		Zombie_Virus=0
		if(!scrap_repair())
			if(!logout_timer) Logout_timer_countdown()
			logout_timer=60
			var/old_icon=icon
			var/list/old_overlays=new
			old_overlays.Add(overlays)
			icon='Death regenerate.dmi'
			overlays.Remove(overlays)
			KO(allow_anger=0)
			sleep(To_tick_lag_multiple(140/Regenerate**0.5))
			Full_Heal()
			icon=old_icon
			overlays.Add(old_overlays)
	else
		src<<"Your scraps were destroyed, you cannot regenerate back to life."
		Death("not having any scraps to regenerate from",1)

var/turf/bind_spawn

proc/Bind_loop() spawn
	if(!bind_spawn) bind_spawn=locate(410,290,6)
	while(1)
		for(var/obj/Curse/c in bind_objects)
			if(ismob(c.loc))
				var/mob/m=c.loc
				if(m.z!=6 && !m.Teleport_nulled() && !m.Prisoner() && !m.Final_Realm())
					if(!Tournament||!(src in All_Entrants))
						m<<"The bind on you takes effect and you are returned to hell"
						m.loc=bind_spawn
		sleep(400)

mob/proc/Fly_Drain(obj/Fly/F)
	var/N=4 + (max_ki*3/F.Mastery/Eff)
	if(N>max_ki) N=max_ki
	return N

mob/var/tmp
	fly_loop
	obj/Fly/fly_obj

mob/proc/Fly_loop() spawn
	if(fly_loop) return
	fly_loop=1
	while(src && client && fly_obj && Flying && !Cyber_Fly)
		if(Ki>=Fly_Drain(fly_obj)&&!KO)
			Flying_Gain(gain_mod=1.5)
			if(Class!="Spirit Doll") Ki-=Fly_Drain(fly_obj)*1.5
			fly_obj.Skill_Increase(5,src)
			sleep(20)
		else
			src<<"You stop flying due to lack of energy"
			Ki=0
			Land()
			break
	fly_loop=0

mob/proc/Alter_regen_mult(n=0)
	if(Regen_Mult==1) Regen_mult_decrease()
	if(Regen_Mult<n) Regen_Mult=n

mob/proc/Regen_mult_decrease() spawn
	while(Regen_Mult>1)
		Regen_Mult-=0.2
		if(Regen_Mult<1) Regen_Mult=1
		sleep(60)

mob/proc/Alter_recov_mult(n=0)
	if(Recov_Mult==1) Recov_mult_decrease()
	if(Recov_Mult<n) Recov_Mult=n

mob/proc/Recov_mult_decrease() spawn
	while(Recov_Mult>1)
		Recov_Mult-=0.2
		if(Recov_Mult<1) Recov_Mult=1
		sleep(60)

mob/proc/Faction_Update() while(src&&client)
	sleep(3000)
	FactionUpdate()

mob/var/tmp/overdrive_loop

mob/proc/Overdrive_Loop() spawn
	if(overdrive_loop) return
	overdrive_loop=1
	while(Overdrive)
		Health-=1.5
		if(KO||Ki<max_ki*0.1) Overdrive_Revert()
		sleep(20)
	overdrive_loop=0

mob/proc/Beam_Charge_Loop(obj/Attacks/A)
	var/Amount=1
	powerup_mobs-=src
	powerup_mobs+=src
	while(A&&A.charging&&A.Wave)
		if(Ki>=Charge_Drain()*5&&!kaioken_level) BPpcnt+=powerup_speed(Amount)
		sleep(Amount*10)

mob/var/max_powerup_acheived=100

mob/proc/powerup_speed(n=1)
	n*=1.3*Buffless_recovery()**recovery_powerup_exponent
	if(BPpcnt>max_powerup_acheived)
		//n/=8/mastery_mod
		max_powerup_acheived=BPpcnt
	if(ismystic) n*=1.2
	if(BPpcnt<100) n=Clamp(BPpcnt/4,1,10)
	else
		n*=energy_mod_powerup_soft_cap()
		n/=bp_mult**2
	return n

mob/proc/powerup_soft_cap()
	var/ki_mod=Buffless_energy_mod()
	if(has_modules) for(var/obj/Module/m in active_modules) if(m.Kix>1) ki_mod/=m.Kix
	var/max_powerup=30*(ki_mod**energy_mod_powerup_exponent) //+100
	if(beaming||charging_beam) max_powerup*=2
	return max_powerup

mob/proc/energy_mod_powerup_soft_cap()
	var/max_powerup=powerup_soft_cap()
	//world<<"powerup soft cap: [round(max_powerup+100)]%"
	var/cur_powerup=BPpcnt-100
	if(cur_powerup<=max_powerup) return 1
	var/mod=(max_powerup/cur_powerup)**powerup_softcap_scaledown_exponent
	//world<<"powerup speed: [round(mod,0.01)]x"
	return mod


mob/var/tmp/standing_powerup

mob/proc/Power_Control_Loop(obj/Power_Control/A) spawn
	var/Amount=1
	if(powerup_obj&&!A) A=powerup_obj
	if(!A) for(var/obj/Power_Control/O in src) A=O
	if(!A) return
	if(A.PC_Loop_Active) return
	A.PC_Loop_Active=1
	spawn(57) while((A&&A.Powerup==1)||BPpcnt>100)
		if(Action!="Meditating") player_view(10,src)<<sound('Aura.ogg',volume=10)
		sleep(41)
	//powerup knockaway
	spawn if(src)
		if(!transing) sleep(5)
		else sleep(2)
		while(A&&A.Powerup==1)
			if(BPpcnt>100)
				if(transing || stand_still_time()>=20) standing_powerup=1
				else standing_powerup=0
				if(!Auto_Attack && world.time-last_attacked_mob_time>50)
					if(!Giving_Power)
						if(transing || (!charging_beam && !beaming && !attacking && stand_still_time()>=20))
							for(var/mob/m in View(2,src)) if(grabber!=m&&!m.KO&&!m.grabber&&m!=src&&(!m.standing_powerup||getdist(src,m)<=2))
								spawn if(m)
									var/bp_rating=BP
									if(transing) bp_rating*=3
									var/kb_dist=3*(bp_rating/m.BP)**1*((Str+Pow)/(m.End+m.Res))
									if(kb_dist>9) kb_dist=9
									kb_dist=To_multiple_of_one(kb_dist)
									if(kb_dist)
										//var/turf/t=m.loc
										//if(t&&isturf(t)) t.Temporary_turf_overlay('Sparks LSSj.dmi',30)
										player_view(center=src)<<sound('scouterexplode.ogg',volume=20)
										Explosion_Graphics(m,1)
										m.Knockback(src,kb_dist,dirt_trail=0,bypass_immunity=1)
								sleep(world.tick_lag)
			if(Tournament&&Fighter1!=src&&Fighter2!=src&&(src in All_Entrants)) Stop_Powering_Up()
			if(!transing) sleep(world.tick_lag)
			else sleep(world.tick_lag)
		standing_powerup=0
	var/Stop_At_100
	if(BPpcnt<100) Stop_At_100=1

	var/soft_cap=powerup_soft_cap()

	while((A&&A.Powerup)||BPpcnt>100)

		if(A&&A.Powerup==1)
			powerup_mobs-=src
			powerup_mobs+=src

		if(soft_cap!=powerup_soft_cap()&&BPpcnt>100)
			var/mod=powerup_soft_cap()/soft_cap
			BPpcnt=((BPpcnt-100)*mod)+100
		soft_cap=powerup_soft_cap()

		if(KO && A.Powerup) Stop_Powering_Up()
		if(A && A.Powerup && A.Powerup!=-1 && (Action!="Meditating" || BPpcnt<100))
			var/pu_mod=1.4
			if(standing_powerup) pu_mod=1.4
			BPpcnt+=powerup_speed(Amount*pu_mod)
			if(BPpcnt>100) A.Skill_Increase(3*Amount,src)
			if(BPpcnt>=100&&Stop_At_100)
				src<<"You reach 100% power and stop powering up"
				Stop_Powering_Up()
			if(Is_oozaru()) Stop_Powering_Up()
		else if(A&&A.Powerup==-1) BPpcnt*=0.9
		Aura_Overlays()
		sleep(Amount*10)
	if(A) A.PC_Loop_Active=0
	Aura_Overlays()

mob/proc/Charge_Drain()
	if(BPpcnt<=100) return 0
	var/drain=1.5 * Eff**0.5 * (BPpcnt/100)**3
	/*
	4000 x 24 energy, 500% powerup = 918 drain per second (1% per second) = 100 total seconds = 40 useful seconds
	4000 x 1 energy, 500% powerup = 187.5  drain per second (4.69% per second) = 21.3 total seconds = 8.5 useful seconds

	4000 x 24 energy, 200% powerup = 59 drain per second (0.06% per second) = 1667 total seconds = 416 useful seconds
	4000 x 1 energy, 200% powerup = 12 drain per second (0.3% per second) = 333 total seconds = 83 useful seconds

	4000 x 24 energy, 130% powerup = 16.2 drain per second (0.017% per second) = 5917 total seconds = 887 useful seconds
	4000 x 1 energy, 130% powerup = 3.3 drain per second (0.083% per second) = 1205 total seconds = 180 useful seconds

	useful seconds = however long it takes to drain you back down to 100%, then divide that time by 2 because other things use energy too
	such as melee attacking, flying, blasting, etc
	*/
	return drain

mob/var/tmp/obj/Power_Control/powerup_obj

var/list/powerup_mobs=new

proc/Powerup_drain() spawn
	while(1)
		for(var/mob/m in powerup_mobs)
			if(!m.KO && m.BPpcnt>100 && m.Ki>=m.Charge_Drain()*2)
				m.Ki-=m.Charge_Drain()*2
			else
				if(m.BPpcnt>100)
					if(m.Race in list("Saiyan","Half Saiyan")) m.Revert()
					m<<"You are too tired to power up any more"
				for(var/obj/Attacks/a in m.ki_attacks) if(a.Wave && a.charging) m.BeamStream(a)
				if(m.BPpcnt>100) m.Stop_Powering_Up()
		sleep(20)

mob/proc/kaioken_mult()
	var/n=(kaioken_bp()+base_bp)/base_bp
	return n

mob/proc
	frc_share()
		var/total=Str+End+Pow+Res+Spd+Off+Def
		return Pow/total*7
	dur_share()
		var/total=Str+End+Pow+Res+Spd+Off+Def
		return End/total*7
	str_share()
		var/total=Swordless_strength()+End+Pow+Res+Spd+Off+Def
		return Str/total*7
	def_share()
		var/total=Str+End+Pow+Res+Spd+Off+Def
		return Def/total*7

mob/var/tmp/kaioken_loop

mob/proc/kaioken_loop() spawn
	if(kaioken_loop) return
	kaioken_loop=1
	while(kaioken_level)
		//this may not seem like a lot but check how kaioken_boost is used
		var/kaioken_max=0.065*highest_relative_base_bp
		if(kaioken_boost<kaioken_max)
			kaioken_boost+=highest_relative_base_bp/600*kaioken_level**0.4
			if(kaioken_boost>kaioken_max) kaioken_boost=kaioken_max

		var/hp_drain=0.21*(kaioken_mult()**1.6-1)/dur_share()**0.3/regen**0.2
		var/ki_drain=0.21*(kaioken_mult()**1.6-1)/Eff**0.2/recov**0.2
		Health-=hp_drain
		Ki-=max_ki/100*ki_drain
		if(Health<=0)
			kaioken_level=0
			if(!Dead) Body_Parts()
			spawn Death("Kaioken!")
		Aura_Overlays()
		sleep(10)
	kaioken_loop=0

mob/proc/Limit_Breaker_Loop() spawn(2)
	if(lb_obj&&lb_obj.Using)
		sleep(rand(50,1200))
		Limit_Revert()

mob/var/tmp/Status_Running

mob/var/tmp/final_realm_loop

mob/proc/Final_realm_loop() spawn
	if(final_realm_loop) return
	final_realm_loop=1
	while(Final_Realm())
		if(BPpcnt>100) BPpcnt=100
		if(!Regenerating&&!KO) Respawn()
		Full_Heal()
		sleep(40)
	final_realm_loop=0

mob/var/tmp/ki_shield_loop

mob/proc/Ki_shield_revert_loop() spawn
	if(ki_shield_loop) return
	ki_shield_loop=1
	while(ki_shield_on())
		if(Ki<=max_ki/20||KO)
			Shield_Revert()
			var/mob/ko_reason=Opponent
			if(!ko_reason || !ismob(ko_reason)) ko_reason="shield"
			KO(ko_reason)
		sleep(15)
	ki_shield_loop=0

mob/var/tmp/dig_loop

mob/proc/Dig_loop() spawn
	if(dig_loop) return
	dig_loop=1
	while(Digging&&client)
		Digging(2)
		sleep(20)
	dig_loop=0

mob/var/tmp/poison_loop

mob/proc/Poison_Loop() spawn
	if(poison_loop) return
	poison_loop=1
	while(Poisoned)
		Health-=30 * Poisoned / Poison_resist()
		Poisoned-=0.1
		if(Poisoned<0) Poisoned=0
		if(Health<=0)
			Death("poison",Force_Death=1,lose_hero=0)
		sleep(10)
	poison_loop=0

mob/proc/Apply_poison(n=1)
	Poisoned+=n
	Poison_Loop()

mob/proc/Poison_resist()
	switch(Race)
		if("Android") return 999
		if("Majin") return 2
		if("Namek") return 1.5
		if("Demon") return 1.5
		if("Human")
			if(Class=="Spirit Doll") return 1.5
		if("Icer") return 0.5
		if("Makyo") return 1.5
	return 1

mob/proc/Diarea_Loop() while(src)
	if(Diarea)
		Diarea()
		sleep(50)
	else sleep(300)

mob/proc/Energy_Reduction_Loop() while(src)
	var/Reduction=1 //%
	if(Ki>max_ki)
		Ki-=(Ki/100)*Reduction
		if(Ki<max_ki) Ki=max_ki
	sleep(Reduction*100)

mob/proc/Health_Reduction_Loop() while(src)
	var/Reduction=1 //%
	if(Health>100)
		Health-=(Health/100)*Reduction
		if(Health<100) Health=100
	sleep(Reduction*100)

mob/var/tmp
	meditate_looping
	obj/meditate_obj

mob/proc/Meditate_gain_loop() spawn if(src)

	if(Race=="Majin") return

	if(meditate_looping) return
	meditate_looping=1
	while(Action=="Meditating")
		var/n=3
		if(!client) n*=5 //meditating clones lag if there is many of them
		icon_state="Meditate"
		var/obj/items/Devil_Mat/D
		for(D in loc) if(D.z) break
		if(D&&!Stat_Settings["Rearrange"]) Devil_Mat(n)
		else if(meditate_obj)
			Med_Gain(n)
			if(!knowledge_training) Raise_SP((1/60/60/2)*n) //1 per 2 hours
		sleep(n*10)
	meditate_looping=0

mob/proc/Train_Gain_Loop() while(src)
	var/Amount=2
	if(!client) Amount*=5 //training clones lag if there is many of them
	if(Action=="Training")
		icon_state="Train"
		Train_Gain(Amount)
		Raise_SP((1/60/60/2)*Amount) //1 per 2 hours
		sleep(Amount*10)
	else sleep(100)

mob/proc/Raise_SP(Amount)

	if(alignment_on&&alignment=="Evil"&&good_person_near) return
	if(key in epic_list) Amount*=100

	if(ultra_pack) Amount*=3
	if(Total_HBTC_Time<2&&z==10) Amount*=3
	Amount*=25
	Amount*=SP_Multiplier
	Amount*=decline_gains()
	if(alignment_on&&alignment=="Evil") Amount*=1.25
	Experience+=Amount*sp_mod

mob/var
	bp_loss_from_low_ki=1
	bp_loss_from_low_hp=1

mob/proc/ki_mult()
	if(Ki<0) Ki=0
	var/Ratio=(Ki/max_ki)**(0.85*bp_loss_from_low_ki)
	if(KO) Ratio=1
	if(Ratio<0.01) Ratio=0.01
	return Ratio

mob/proc/hp_mult()
	if(Health<0) Health=0
	var/Ratio=(Health/100)**(0.2*bp_loss_from_low_hp)
	if(Ratio>1) Ratio=1
	if(Health<=10) Ratio*=0.1
	if(anger>100) Ratio=1
	if(KO) Ratio=1
	if(Ratio<0.01) Ratio=0.01
	return Ratio

mob/proc/Splitform_Count(Amount=0)
	if(!splitform_list) splitform_list=new/list //runtime error "bad list" for some reason
	if(client) for(var/mob/Splitform/S in splitform_list) Amount++
	return Amount

mob/proc/Dead_In_Living_World_Loop() while(src)
	var/sleep_time=2
	if(!client) sleep_time*=5 //clones lag a lot from this if there is many of them at once
	if(locate(/area/Prison) in range(0,src)) sleep(300)
	else
		if(Dead&&!Is_In_Afterlife(src))
			Ki-=max_ki/60*sleep_time
			if(Ki<max_ki*0.1)
				Ki=0
				src<<"You have used all your energy and will return to the afterlife in 15 seconds"
				sleep(150)
				if(src&&Dead&&!Is_In_Afterlife(src))
					if(grabber) grabber.Release_grab()
					player_view(15,src)<<"[src] is returned to the afterlife due to lack of energy"
					loc=locate(170,190,5)
			sleep(sleep_time*10)
		else sleep(200)

proc/Is_In_Afterlife(mob/P)
	var/area/a=P.get_area()
	if(!a) return
	if(a.name in list("Hell","Heaven","Checkpoint","Kaioshin","tournament area","Prison")) return 1

mob/proc/Gravity_Health_Ratio()
	var/Ratio=(Gravity/gravity_mastered)**3
	if(Ratio<1) Ratio=1
	return Ratio

mob/var/Next_Injury_Regeneration=0

mob/proc/Internally_Injured()
	for(var/obj/Injuries/Internal/I in injury_list)
		if(Ki>max_ki*0.1) return 1
		if(Ki>100) return 1
		break



/*mob/proc/Stat_Labels() spawn if(src)
	var/previous_health=Health
	var/previous_ki=Ki
	var/previous_gravity=Gravity
	var/previous_power=0
	while(src)
		if(client)
			var/delay=15
			if(client.inactivity>220&&Gravity<=gravity_mastered&&Health>=100)
				delay*=4
			else if(Health>=100&&Ki>=max_ki) delay*=2

			if(Gravity!=previous_gravity) src<<output("Gravity: [round(Gravity,0.1)]x","Bars.Gravity")
			if(Health!=previous_health) winset(src,"Bars.Healthbar","value=[round(Health)]")
			if(Ki!=previous_ki) winset(src,"Bars.Energybar","value=[round((Ki/max_ki)*100)]")
			var/Power=round(hp_mult()*ki_mult()*Anger_Powerup_Mix_Mult()*100)
			if(Power!=previous_power) src<<output("BP: [Power]%","Bars.Powerbar")
			previous_health=Health
			previous_ki=Ki
			previous_gravity=Gravity
			previous_power=Power

			sleep(delay)
		else sleep(300)*/

proc/Health_bar_update_loop() spawn
	while(1)
		for(var/mob/m in players) m.Update_health_bars()
		sleep(15)

mob/var/tmp/next_health_bar_update=0

mob/proc/Update_health_bars()
	if(!client||client.inactivity>=450||world.time<next_health_bar_update) return
	next_health_bar_update=world.time

	src<<output("Gravity: [round(Gravity,0.1)]x","Bars.Gravity")
	winset(src,"Bars.Healthbar","value=[round(Health)]")
	winset(src,"Bars.Energybar","value=[round((Ki/max_ki)*100)]")
	var/Power=round(hp_mult()*ki_mult()*Anger_Powerup_Mix_Mult()*100)
	src<<output("BP: [Power]%","Bars.Powerbar")
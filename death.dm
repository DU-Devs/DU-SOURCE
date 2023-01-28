mob/proc/Full_Heal()
	Un_KO()
	if(Health<100) Health=100
	if(Ki<max_ki) Ki=max_ki
proc/SSj_Online()
	var/n=0
	for(var/mob/P in players) if(P.SSjAble&&P.SSjAble<=Year&&P.Class!="Legendary Saiyan")
		if(!n||P.SSjAble<n) n=P.SSjAble
	return n
proc/SSj2_Online()
	var/n=0
	for(var/mob/P in players) if(P.SSj2Able&&P.SSj2Able<=Year&&P.Class!="Legendary Saiyan")
		if(!n||P.SSj2Able<n) n=P.SSj2Able
	return n

proc/SSj3_Online()
	var/n=0
	for(var/mob/P in players) if(P.SSj3Able&&P.SSj3Able<=Year&&P.Class!="Legendary Saiyan")
		if(!n||P.SSj3Able<n) n=P.SSj3Able
	return n

mob/verb/Knockback_Options()
	set category="Other"
	KB_On=input(src,"Enter the percentage of your melee attacks that will have knockback applied. Current is \
	[KB_On]%. For sparring you should put this on 0%","Options",KB_On) as num
	if(KB_On<0) KB_On=0
	if(KB_On>100) KB_On=100

mob/var/KB_On=100

proc/Get_Warp(mob/M,mob/P,Dir) if(Dir)
	var/turf/T=Get_step(M,Dir)
	if(T&&isturf(T)&&!T.density&&!(locate(/mob) in T)&&T.Enter(P)&&!(locate(/obj/Edges) in T)&&!T.Water) return T

proc/Get_Warp_Destination(mob/M,mob/P)
	var/list/Locs
	for(var/turf/A in oview(1,M)) if(!A.density&&!(locate(/mob) in A)&&A.Enter(P)&&!(locate(/obj/Edges) in A)&&!A.Water&&(A in view(20,P)))
		if(!Locs) Locs=new/list
		Locs+=A
	if(Locs) return pick(Locs)

mob/proc/Warp_To(turf/B,mob/M) if(B)
	player_view(10,src)<<sound('teleport.ogg',volume=10)
	flick('Zanzoken.dmi',src)
	loc=locate(B.x,B.y,B.z)
	dir=get_dir(src,M)
	M.dir=get_dir(M,src)


mob/proc/can_melee()
	if(peebagging||Shadow_Sparring||KO||attacking||grabbed_mob||Final_Realm()) return
	if(tournament_override()) return
	if(Ship)
		Ship.Ship_Weapon_Fire()
		return
	if(Action in list("Meditating","Training")) return
	for(var/obj/items/Regenerator/R in loc) if(R.z) return
	if(Peebag()||Punch_Machine()) return
	return 1

mob/var/tmp/mob/last_mob_attacked

//src is the person being attacked, M is the attacker
mob/proc/set_opponent(mob/M)
	M.Log_attack(src)
	Opponent=M
	M.last_mob_attacked=src
	Attack_gain_loop()

	Set_chaser(M)
	//M.Set_chaser(src) //since fear always seems to fear the wrong person I switched this around for now as a test. 4/13/2015

	Set_possible_teamer_list(M) //still needed to create attack backlogs
	Check_if_being_teamed(M)

	Good_teaming_with_evil_check()
	M.Check_if_kiting()

mob/proc/Get_attack_gains()
	if(Opponent && ismob(Opponent) && world.time-last_attacked_mob_time<50 && world.time-Opponent.last_attacked_mob_time<50)
		return 1

mob/var/tmp/attack_gain_loop

mob/proc/Attack_gain_loop() spawn
	if(attack_gain_loop) return
	attack_gain_loop=1
	while(Get_attack_gains())
		if(prob(50) || (Opponent.client && client && Opponent.client.address!=client.address) || world.maxz<=5)
			if(Race=="Majin") Majin_attack_gain(1.4)
			else Attack_Gain(1.4)
			Raise_SP((1/60/20)*1.4) //1 per 20 minutes
		sleep(10)
	attack_gain_loop=0

mob/var/tmp/knockback_immune=0

turf/proc/Temporary_turf_overlay(image/i,timer=30)
	if(!i) return
	overlays+=i
	spawn(timer) overlays-=i

mob/proc/Knockback(mob/A,Distance=10,dirt_trail=1,override_dir,bypass_immunity) //A is the Attacker who knockbacked src
	if(!z) return //prevent body swap bug knocking them out of the body
	if(Safezone||KB||knockback_immune) return

	if(transing) Distance/=2

	Distance=round(Distance)
	var/Old_State=icon_state
	if(Old_State in list("Attack","Meditate","Train","KB")) Old_State=""
	if(client) icon_state="KB"
	KB=1

	var/mob/m=grabbed_mob
	Release_grab()
	spawn if(m&&ismob(m)) m.Knockback(A,Distance)

	var/Dir=get_dir(A,src)
	//if(prob(20)) Dir=pick(turn(A.dir,45),turn(A.dir,-45))
	if(override_dir) Dir=override_dir

	var/original_distance=Distance

	if(Diarea) spawn Diarea(Other_Chance=100)

	while(src && A && KB && Distance)
		Distance--
		if((locate(/obj/Edges) in loc)||(locate(/obj/Edges) in Get_step(src,Dir))) KB=0
		else
			var/turf/T=Get_step(src,Dir)
			if(!T||(T.Water&&!Flying)) KB=0
			KB_Destroy(A,Dir)

			var/turf/old_loc=loc
			step(src,Dir)

			if(dirt_trail) if(original_distance>=10 && (Dir in list(NORTH,SOUTH,EAST,WEST)))
				var/image/i=image(icon='craterseries.dmi',icon_state="crater",layer=OBJ_LAYER,dir=Dir)
				if(Distance==original_distance-1||Distance==0) i.icon_state="begin"
				if(Distance==0) i.dir=turn(Dir,180)
				var/turf/t=loc
				if(t && isturf(t)) t.Temporary_turf_overlay(i,1*600)

			if(loc==old_loc)
				KB=0
				dir=get_dir(src,A)
			else if(Distance) sleep(world.tick_lag)
	if(src)
		KB=0
		last_knockbacked=world.time
		if(!bypass_immunity)
			knockback_immune=1
			spawn(kb_immunity_time) if(src) knockback_immune=0
		if(KO&&client) icon_state="KO"
		else icon_state=Old_State

var/kb_immunity_time=12
mob/var/tmp/last_knockbacked=0

mob/proc/KB_Destroy(mob/A,Dir) //A is the Attacker
	var/turf/T=Get_step(src,Dir)
	if(T&&(T.Health<A.Wall_breaking_power()||A.Epic())&&A.Is_wall_breaker()&&!T.Water)
		T.Health=0
		if(T.density)
			Dust(T,5)
			T.Destroy()
		else if(!Flying&&A.BP>3000000)
			//Dust(T,1)
			T.Make_Damaged_Ground(1)
	for(var/obj/O in Get_step(src,Dir)) if(O.z&&!istype(O,/obj/Dust))
		if(O.Health<A.Wall_breaking_power())
			Dust(O,3)
			del(O)
mob/var
	KO
	Frozen
mob/var
	last_anger=0 //So you can't get angry again til enough time passes
	tmp/last_attacked_time=0 //the last time someone attacked you. if the last time you were attacked was
	//more than 2 minutes ago you become calm
mob/proc/third_eye()
	for(var/obj/Third_Eye/te in src) if(te.Using)
		return 1
mob/proc/can_anger()
	if(Android) return
	if(anger<=100)
		return 1

mob/var/list/anger_reasons=new

mob/proc/anger(anger_mult=1,ssj_possible=1,reason) if(can_anger())
	if(anger_mult==1) player_view(15,src)<<"<font color=red>[src] gets angry!"
	else player_view(15,src)<<"<font color=red>[src] gets extremely enraged!!"

	anger_reasons.Insert(1,reason)
	anger_reasons.len=2

	last_anger=world.time
	last_attacked_time=world.time
	anger=100
	var/anger_boost=(max_anger-100) * anger_mult
	if(ssj==4) anger_boost*=ssj4_anger_mult
	if(ismystic) anger_boost*=0.85
	anger+=anger_boost
	if(anger<100) anger=100
	if(Health<100) Health=100
	if(Ki<max_ki) Ki=max_ki
	BP=get_bp()
	if(ssj_possible) if(Race in list("Saiyan","Half Saiyan"))
		var/ssj_chance=50 * anger_mult**0.5 * (max_anger/100)**0.5
		if(z==18) ssj_chance*=2

		if(reason in recent_ko_reasons) ssj_chance=0

		if(prob(ssj_chance))
			if(has_ssj_req(1.9)&&(ssj_inspired>=1||(BP>ssjat*3&&!SSjAble))) SSj()
			if(has_ssj2_req(1.3)&&(ssj_inspired>=2||(BP>ssj2at*1.8&&!SSj2Able))) SSj2()
			if(has_ssj3_req(1.3)&&(ssj_inspired>=3||(BP>ssj3at*1.4&&!SSj3Able))) SSj3()
			if(ssj==ssj_inspired) ssj_inspired=0
	spawn(360) Calm()
mob/proc/Calm()
	if(anger>100)
		player_view(15,src)<<"[src] becomes calm"
		last_anger=world.time
	anger=100
mob/proc/anger_chance(mod=1)

	if(Race=="Android") return 0
	return 100 //because now anger is 100% but only lasts short 1 minute bursts

	if(battle_test) return 100
	if(z==7&&Tournament&&skill_tournament&&(src in All_Entrants)) return 100

	var/fail_chance=25
	if(ismystic) fail_chance*=1.25
	if(third_eye()) fail_chance*=1.25
	if(OP_build()) fail_chance=0
	switch(Race)
		if("Saiyan") fail_chance*=0.9
		if("Half Saiyan") fail_chance*=0.7
		if("Android") fail_chance=100
		if("Majin") fail_chance*=0.9
		if("Namek") fail_chance*=1.25
		if("Demon") fail_chance*=0.8
		if("Human") fail_chance*=0.8
	var/success_chance=100-fail_chance
	return success_chance*mod

mob/var/tmp/list/recent_ko_reasons=new

mob/proc/In_tournament()
	if(!Tournament||z!=7||!(src in All_Entrants)) return
	return 1

mob/proc/KO(mob/Z,allow_anger=1)
	if(client||battle_test) if(!KO)
		if(Safezone) return
		if(spam_killed)
			Health=100
			Ki=max_ki
			return
		if(key in epic_list) return
		var/anger_wait=3000
		if(ultra_pack&&server_mode=="RP") anger_wait-=600
		if(can_anger() && allow_anger && (prob(anger_chance()) || hero==key || ultra_pack))
			var/can_anger
			if(Z && ismob(Z) && Z.client && !(Z.key in anger_reasons)) can_anger=1

			//also let them get a double anger if they are being teamed on
			for(var/mob/m in player_view(30,src))
				if(m.client && m!=src && m!=Z && !m.KO && m.z==z && m.Extrapolated_target_is(src,hit_req=7,min_time=40,max_time=300))
					if(!(m.key in anger_reasons))
						can_anger=1
						break

			if(world.time>last_anger+anger_wait || can_anger)
				var/ko_reason=Z
				if(ismob(Z))
					ko_reason=Z.key
					if(!Z.key) ko_reason="npc"
				anger(reason=ko_reason)

				recent_ko_reasons.Insert(1,ko_reason)
				recent_ko_reasons.len=3

				return
		give_tier(Z)
		Zenkai()
		KO=1

		if(alignment_on&&!In_tournament()) Drop_dragonballs()

		Action=null
		Auto_Attack=0
		Limit_Revert()

		kaioken_level=0
		Aura_Overlays()

		oozaru_revert()
		Land()
		Health=100
		Ki=max_ki
		BP=get_bp()
		if(BPpcnt>100)
			BPpcnt=100
			Aura_Overlays()
		icon_state="KO"
		KB=0
		if(ismob(Z)&&Z.client&&Z.client.computer_id!="1768931727")
			for(var/mob/m in player_view(center=src))
				var/t="[src] is knocked out by [Z] ([Z.displaykey])"
				m<<t
				m.ChatLog(t)
		else player_view(center=src)<<"[src] is knocked out by [Z]!"

		if(grabbed_mob)
			player_view(center=src)<<"[src] is forced to release [grabbed_mob]!"
			Release_grab()

		for(var/obj/A in src) if(A.Stealable&&A.Injection&&prob(10))
			var/obj/items/Diarea_Injection/V=A
			V.Use(src)
		if(ssj>0)
			if(ssjdrain>300&&ssj==1)
			else Revert()
		var/KO_Timer=1200/Clamp((regen**0.4),0.5,2)
		if(z==10) KO_Timer/=4
		if(ultra_pack) KO_Timer/=2
		if(hero==key) KO_Timer*=0.7
		spawn(KO_Timer*KO_Time) Un_KO()
		if(Poisoned&&prob(50)) spawn Death("???")
	else if(!Frozen)
		if("KO" in icon_states(icon)) icon_state="KO"
		KO=1
		Health=100
		Frozen=1
		player_view(center=src)<<"[src] is knocked out"
		spawn(1800) if(src&&KO)
			icon_state=initial(icon_state)
			player_view(center=src)<<"[src] regains consciousness"
			Health=100
			KO=0
			Frozen=0
mob/proc/Un_KO() if(KO)
	Health=1
	KO=0
	if(!client) Frozen=0
	icon_state=initial(icon_state)
	attacking=0
	Ki=1
	move=1
	if(Poisoned&&prob(50)) spawn Death("???")
	player_view(center=src)<<"[src] regains consciousness."
	if(client) spawn(20) if(OP_build()||(prob(anger_chance(0.4))&&!can_anger()))
		src<<"<font color=red>Being knocked out so much angers you..."
		anger(reason="being ko'd so much")
		Full_Heal()
mob/proc/Angry() if(anger>100) return 1
mob/var/Regenerate=0 //Like Majin and Bios regenerate instead of dying
mob/var/Regenerating
mob/var/Death_Year=0
mob/proc/Drop_Rsc(n=0) if(n)
	var/obj/Resources/R=resource_obj
	if(!R) return
	var/obj/Resources/Bag=new(loc)
	Bag.Value=n
	R.Value-=n
	Bag.Update_value()

mob/proc/Drop_Stealables()
	if(loc && isturf(loc))

		Drop_Rsc(Res())

		var/list/drop_anyway_on_death=list(/obj/items/Shikon_Jewel,/obj/items/Dragon_Ball)

		//for(var/obj/Stun_Chip/SC in src) del(SC)
		for(var/obj/A in contents) if(A.Stealable) if(drop_items_on_death || (A.type in drop_anyway_on_death))
			if(istype(A,/obj/items/Sword)) if(A.suffix) Apply_Sword(A)
			if(istype(A,/obj/items/Armor)) if(A.suffix) Apply_Armor(A)
			A.suffix=null
			overlays-=A.icon
			if(Scouter==A) Scouter=null
			A.Move(loc)

mob/var/spam_killed=0
mob/var/list/death_regen_loc=list(100,100,1)

mob/proc/Death(mob/Z,Force_Death=0,drone_sd=0,lose_hero=1,lose_immortality=1)

	var/mob/Body/body

	//fix bug where people give drones packed death regen and have no need for the regen module
	if(drone_module&&!client&&!(locate(/obj/Module/Scrap_Repair) in active_modules)) Regenerate=0

	var/was_dead_already=Dead

	if(Dead && spam_killed) return

	if(alignment_on&&ismob(Z)&&Z!=src&&both_good(Z,src)) return

	if(ismob(Z) && Z!=src && Same_league_cant_kill(Z,src)) return

	if(key in epic_list) return

	if(Safezone||Prisoner()||Clone_Tank()) return

	if(Final_Realm())
		Force_Death=1
		lose_hero=0
		lose_immortality=0

	/*if(Has_Bounty())
		Imprison()
		Update_Bounties()
		return*/
	give_tier(Z)

	chaser=null
	chaser_key=null
	Remove_fear()
	//so that the person who killed them doesn't get the fear debuff when they suddenly disappear
	for(var/mob/m in players) if(m.chaser==src)
		m.chaser=null
		m.chaser_key=null
		m.Remove_fear()

	var/Already_Dead=Dead
	if(Android&&!Dead&&(!drone_module||(locate(/obj/Module/Scrap_Repair) in active_modules)))
		Spread_Scraps(src)
	Auto_Attack=0
	if(Ship) loc=Ship.loc
	if(!ismob(Z)||(ismob(Z)&&Z.client&&Z.client.computer_id!="1768931727"))
		for(var/mob/m in player_view(center=src))
			var/t="[src] was just killed by [Z]!"
			m<<t
			m.ChatLog(t)

	if(client && Z && ismob(Z) && Z.client && lord_freeza_obj && Z.z==lord_freeza_obj.z && viewable(lord_freeza_obj,Z,44))
		lord_freeza_obj.Lord_Freeza_kill_someone(Z)

	if(!Dead)
		for(var/obj/Injuries/I in injury_list) del(I)
		Add_Injury_Overlays()
	Stop_Powering_Up()
	oozaru_revert()
	Poisoned=0
	Roid_Power(0)
	if(grabbed_mob)
		player_view(center=src)<<"[src] is forced to release [grabbed_mob]!"
		Release_grab()
	if(grabber) grabber.Release_grab()
	if(client||empty_player||istype(src,/mob/Troll)||istype(src,/mob/new_troll)||drone_module)
		if(!Force_Death && Regenerate && !Dead && !Regenerating)
			Full_Heal()
			Regenerating=1
			if(!Android && !scrap_repair()) body=Leave_Body()
			radiation_poisoned=0
			radiation_level=0
			death_regen()
			return
		if(!Dead)
			if(ismob(Z)&&Age>=5) for(var/mob/A in player_view(15,src))
				if(A!=src&&A!=Z&&A.client&&!A.KO&&(Mob_ID in A.SI_List))
					if(!alignment_on||both_good(A,src))
						A.anger(2,reason="death anger")
						if(death_anger_gives_ssj&&A&&(A.Race in list("Half Saiyan","Saiyan")))
							if(A.Race=="Half Saiyan"&&!A.SSjAble)
								//half saiyans can only get ssj1 thru inspire so they cant be the first
							else
								if(bp_tiers)
									if(bp_tier>=3)
										if(!A.SSjAble)
											spawn if(A) A.SSj()
											break
										else if(!A.SSj2Able)
											spawn if(A) A.SSj2()
											break
										else if(!A.SSj3Able)
											spawn if(A) A.SSj3()
											break
								else
									if((!SSj_Online()||ssj_easy)&&!A.SSjAble&&A.has_ssj_req())
										spawn if(A) A.SSj()
										break
									if((!SSj2_Online()||ssj_easy)&&!A.SSj2Able&&A.has_ssj2_req())
										spawn if(A) A.SSj2()
										break
									if((!SSj3_Online()||ssj_easy)&&!A.SSj3Able&&A.has_ssj3_req())
										spawn if(A) A.SSj3()
										break
						if(prob(30)) break

			if(!Android&&!scrap_repair()) body=Leave_Body()

		if(!drone_module||client) Drop_Stealables()

		var/Rebuilt
		var/rebuild_prob=80
		if(drone_module && !client) rebuild_prob=86

		if(!drone_sd && prob(rebuild_prob)) for(var/obj/Module/Rebuild/R in active_modules) if(R.suffix)

			var/list/cyber_coms=new
			var/list/cyber_coms_on_z=new
			var/list/cyber_coms_on_area=new

			for(var/obj/Cybernetics_Computer/cc in cybernetics_computers) if(cc.Password==R.Password && cc.z)
				cyber_coms+=cc
				if(cc.get_area()==get_area())
					cyber_coms_on_area+=cc
					if(cc.z==z) cyber_coms_on_z+=cc


			var/obj/Cybernetics_Computer/cc

			if(cyber_coms_on_z.len) cc=pick(cyber_coms_on_z)
			else if(cyber_coms_on_area.len) cc=pick(cyber_coms_on_area)
			else if(cyber_coms.len) cc=pick(cyber_coms)

			if(cc)
				Full_Heal()
				src<<"The [cc] has rebuilt you here"
				loc=cc.loc
				Rebuilt=1
				break
		if(!Dead&&!Rebuilt)

			//Destroy_Soul_Contracts(soul_percent=17)

			//if(!drone_module||client) for(var/obj/Module/M in active_modules) if(M.suffix)
			//	M.Disable_Module(src)
			//	M.loc=loc

			cyber_bp=0
			if(ismob(Z)) Opponent=Z
			Zenkai(0.5)
			overlays+='Halo.dmi'
			Dead=1
			death_time=world.realtime
			hell_agreements=new/list
			Death_Year=Year
			//KeepsBody=0
		if(!Rebuilt) //ACTUALLY DIED

			if(!client&&drone_module)
				if(!drone_sd) for(var/obj/rt in robotics_tools) if(rt.Password==drone_module.Password&&ismob(rt.loc))
					var/mob/drone_master=rt.loc
					drone_master<<"<font color=red>[src] was just destroyed by [Z] at location [x],[y] in [get_area()]"
				loc=null
				del(src)
				return

			counterpart_died=0 //not sure if this should be here
			Tell_counterpart_i_died()
			Vampire_Infection=0
			Undo_all_t_injections()
			radiation_level=0
			radiation_poisoned=0
			if(Immortal && lose_immortality && !was_dead_already)
				Toggle_immortality()
				src<<"<font color=yellow>Death has caused you to lose immortality"

			if(lose_hero) hero_death(Z)
			villain_death(Z)

			if(!was_dead_already&&sagas&&ismob(Z)&&Z.key==villain&&alignment=="Good"&&Z.client)
				if(client&&client.address!=Z.client.address)
					var/mob/old_hero=hero_online()
					Z.good_kills++
					if(Z.good_kills>=killing_spree_max)
						Z.good_kills=0
						old_hero.hero_time=0
						find_new_hero(old_hero)
						world<<"<font color=red>The hero did not respond to [Z]'s killing spree of innocent people. \
						The hero title has now gone to [hero_online()]"
			if(death_cures_vampires&&!db_vampire_incurable)
				Vampire_Revert()
				//Former_Vampire=0
			loc=locate(death_x,death_y,death_z)
			if(!was_dead_already) Full_Heal()
			if(death_setting=="Rebirth upon death")
				Reincarnate()
				Revive()
				alert(src,"You were killed. You have now been reborn as a completely different character \
				and have lost some power")

			/*
			if(!spam_killed)
				var/minutes=5
				src<<"<font color=yellow>You were killed. For [minutes] minutes you will be invincible \
				so that people can't spam kill you. But you will also be stuck at low power until then so \
				that you can not harm anyone else while invincible"
				spam_killed=minutes*60
				Spam_kill_timer()
			*/

			if(Already_Dead&&Perma_Death)
				src<<"<font color=yellow><font size=3>You were killed while dead. Meaning you have been \
				automatically reincarnated."
				Reincarnate()

		if(src)
			if(!client&&key&&empty_player) Save()
			if(type==/mob/Troll||type==/mob/new_troll)
				Drop_Stealables()
				del(src)
		Zombie_Virus=0
	else
		Drop_Stealables()
		del(src)
	if(body) body.Rare_death_check(src)
mob/proc/Spam_kill_timer()
	if(!spam_killed) return
	while(spam_killed>0)
		spam_killed--
		sleep(10)
	if(spam_killed<0) spam_killed=0
mob/proc/Revive()
	Dead=0
	overlays-='Halo.dmi'
	Tell_counterpart_im_alive()
atom/var/attackable=1
mob/var/tmp/AutoAttack
mob/verb/Attack()
	set category="Skills"
	Melee()
var/list/dust_cache=new
obj/Dust
	density=0
	icon='Dust.dmi'
	layer=5
	Grabbable=0
	attackable=0
	Savable=0
	var/tmp/dust_loop_on
	proc/Dust_loop() spawn
		if(dust_loop_on) return
		dust_loop_on=1
		while(z)
			if(prob(85)) dir=turn(dir,45)
			step(src,dir)
			sleep(3)
		dust_loop_on=0
	New()
		dust_count++
	Del()
		dust_count--
		loc=null
		dust_cache+=src
var/dust_count=0
proc/Dust(mob/A,n=2)
	if(dust_count>100) return
	if(locate(/obj/Dust) in range(0,A)) return
	for(var/V in 1 to n)
		var/obj/Dust/D
		if(dust_cache.len)
			D=dust_cache[1]
			dust_cache-=D
		else D=new
		spawn(rand(50,200)) if(D) del(D)
		D.loc=locate(A.x,A.y,A.z)
		D.icon='Air Dust 2.dmi'
		D.pixel_y=rand(-16,16)
		D.pixel_x=rand(-16,16)
		D.pixel_x-=16
		D.pixel_y-=16
		D.dir=pick(NORTH,SOUTH,EAST,WEST,NORTHWEST,NORTHEAST,SOUTHWEST,SOUTHEAST)
		D.Dust_loop()
mob/var/Warp=0
mob/var/tmp/KB
turf/proc/Destroy()
	//var/image/I=image(icon='Lightning flash.dmi',layer=99)
	//overlays-=I
	if(Health<=0&&!Water)
		new/turf/GroundSandDark(src)
		if(prob(2.5))
			var/obj/Turfs/Rock1/R=new(src)
			R.Nukable=0
			R.pixel_x=rand(-16,16)
			R.pixel_y=rand(-16,16)
			R.density=0
			R.Savable=0
			Timed_Delete(R,rand(600,1800))
client/North() if(mob.Allow_Move(NORTH)) return ..()
client/South() if(mob.Allow_Move(SOUTH)) return ..()
client/East() if(mob.Allow_Move(EAST)) return ..()
client/West() if(mob.Allow_Move(WEST)) return ..()
client/Northwest() if(mob.Allow_Move(NORTHWEST)) return ..()
client/Northeast() if(mob.Allow_Move(NORTHEAST)) return ..()
client/Southwest() if(mob.Allow_Move(SOUTHWEST)) return ..()
client/Southeast() if(mob.Allow_Move(SOUTHEAST)) return ..()
var/beam_stun_start=3

mob/proc/Beam_stunned(obj/Blast/b)
	if(!b)
		if(world.time-last_beam_fire<35)
			var/turf/t=loc
			if(t) for(var/v in 1 to 4)
				t=Get_step(t,dir)
				if(!t) break
			if(t) for(b in t)
				if(b.Owner!=src)
					break
	if(!b) return
	if(b.Beam&&b.dir==get_dir(b,src)&&getdist(src,b.Owner)>=beam_stun_start)
		if(locate(/obj/beam_redirector) in b.loc) return
		return 1

mob/var/tmp/list/ki_attacks=new

mob/var/tmp
	last_allow_move_result=0
	last_allow_move_result_time=0

mob/proc/Allow_Move(D)

	//prevent allow_move from being called a ridiculous number of times in a short period by just returning the most recent result again
	//unless theyre in a pod cuz it slows pods down
	if(!Ship) if(world.time-last_allow_move_result_time<3)
		return last_allow_move_result

	last_allow_move_result_time=world.time
	last_allow_move_result=0

	if(Race=="Majin"&&majin_stat_version<=2) return
	if(stat_version<=2) return

	stand_still_time=world.time

	//to make combo teleporting more reliable so you/others dont instantly/accidently move and break it
	if(world.time-last_combo_teleport<=6)
		dir=D
		return //remember its in TENTHS of seconds, so 5 = 0.5 seconds

	if(Is_oozaru()&&!oozaru_control) return
	if(beam_struggling||shockwaving||Giving_Power) return
	if(!Shadow_Sparring&&!Ship) Cease_training()
	if(dash_attacking)
		if(D==turn(dir,90)) desired_dash_dir=turn(dir,45)
		if(D==turn(dir,-90)) desired_dash_dir=turn(dir,-45)
		return
	if(!allow_diagonal_movement)
		if(D in list(NORTHEAST,NORTHWEST,SOUTHWEST,SOUTHEAST)) return
	if(Beam_stunned()) return
	if(moving_charge==1)
		if(dir!=D)
			dir=D
			return
		else moving_charge=2
	for(var/obj/Attacks/A in ki_attacks) if(A.charging||A.streaming||A.Using)
		dir=D
		return
	for(var/obj/Blast/B in Get_step(src,D))
		//if(B.dir in list(D,turn(D,45),turn(D,-45))) step(B,B.dir)
		if(B.dir!=turn(D,180)) step(B,B.dir)
		else if(B.density) return
	if(Shadow_Sparring)
		dir=D
		return
	if(Ship)
		if(Ship.type==/obj/Ships/Spacepod&&loc!=Ship) Ship.contents+=src
		if(!Ship.Moving&&Ship.Ki>0&&!KO)
			Ship.Move_Randomly=0
			Ship.Moving=1
			Ship.MoveReset()
			step(Ship,D)
			if(Ship) Ship.Fuel()
		return
	if(car) car.dir=D
	if(!Can_Move()) return
	if(icon_state=="KB"||KB||!move) return

	if(!struggle_timer&&grabber&&!KO)
		if(Race=="Majin")
			if(icon!='Death regenerate.dmi')
				var/old_icon=icon
				icon='Death regenerate.dmi'
				spawn(3) icon=old_icon
			player_view(15,src)<<"<font color=red>[src] breaks free of [grabber]!"
			grabber.Release_grab()
		else
			var/grab_resist=Clamp((Swordless_strength()/grabber.Swordless_strength())**0.3,0.1,10)
			grab_resist*=Clamp((BP/grabber.BP)**0.5,0.1,5)
			grab_resist*=Clamp((Def/grabber.Off)**0.35,1,2)
			grab_resist*=13

			if(grabbed_from_behind&&Tail)
				grab_resist/=2**(1/tail_level)

			grabber.grab_power-=grab_resist
			grabber.Ki-=(grabber.max_ki/200*grab_resist) * (grabber.max_ki/3000)**0.3 * Clamp(grabber.recov,0.25,1)
			struggle_timer=1
			spawn(20) struggle_timer=0
			if(grabber.grab_power<=0)
				player_view(15,src)<<"<font color=red>[src] breaks free of [grabber]!"
				grabber.Release_grab()
			else
				player_view(15,src)<<"[src] struggles against [grabber]!"
				return

	if(is_kiting&&Opponent)
		Check_if_kiting()
		if(is_kiting)
			if(D in list(get_dir(src,Opponent),turn(get_dir(src,Opponent),45),turn(get_dir(src,Opponent),-45)))
				Reset_kiting()


	last_allow_move_result=1

	return 1
mob/proc/Being_strangled()
	if(grabber&&grabber.strangling) return 1
mob/var/tmp/attacking
mob/var/Dead
mob/var/tmp
	melee_gfx_icon
	punch_gfx
	kick_gfx
	sword_gfx
	spinkick_gfx
	spinpunch_gfx
	dodge_gfx
	h2_overhead_gfx
	h1_overhead_gfx

mob/var/tmp/last_melee_graphics_check=0

mob/proc/melee_graphics() if(icon)
	if(world.time-last_melee_graphics_check>100 && icon!=melee_gfx_icon)
		punch_gfx=0
		kick_gfx=0
		sword_gfx=0
		melee_gfx_icon=icon
		for(var/v in icon_states(icon))
			switch(v)
				if("Sword") sword_gfx=1
				if("Attack") punch_gfx=1
				//if("Kick") kick_gfx=1
				if("Dodge") dodge_gfx=1
				if("SpinKick") spinkick_gfx=1
				if("SpinPunch") spinpunch_gfx=1
				if("1H Overhead Charge") h1_overhead_gfx=1
				if("2H Overhead Charge") h2_overhead_gfx=1

	last_melee_graphics_check=world.time

	if(sword_gfx && equipped_sword) flick("Sword",src)
	else if(punch_gfx) flick("Attack",src)
	return //the rest below is too laggy so i replaced it with this above

	if(sword_gfx&&equipped_sword) flick("Sword",src)
	else if(kick_gfx&&punch_gfx) flick(pick("Attack","Kick"),src)
	else if(kick_gfx&&punch_gfx&&spinkick_gfx&&spinpunch_gfx)
		flick(pick("Attack","Kick","SpinKick","SpinPunch"),src)
	else if(punch_gfx) flick("Attack",src)

mob/proc/Blast()
	if(Is_oozaru()) return
	if(attacking) flick("Attack",src)
mob/Body/var
	body_expire_time=0
	was_zombie

proc/Reset_vars(mob/m)
	if(!m) return
	for(var/v in m.vars)
		if(v!="key"&&issaved(m.vars[v]))
			m.vars[v]=initial(m.vars[v])

var/list/cached_bodies=new
proc/Get_cached_body()
	for(var/mob/m in cached_bodies)
		Reset_vars(m)
		cached_bodies-=m
		return m
	return new/mob/Body

mob/proc/Leave_Body()
	var/mob/Body/A=Get_cached_body()
	if(!A) return
	if(!client) Timed_Delete(A,3000)
	if(istype(src,/mob/Enemy/Zombie)) A.was_zombie=1
	A.Has_DNA=Has_DNA
	A.Modless_Gain=Modless_Gain
	A.TextColor=TextColor
	A.brain_transplant_allowed=0
	A.body_expire_time=world.realtime+(1*60*60*10)
	A.can_change_icon=0
	A.Zombie_Virus=Zombie_Virus
	for(var/obj/Stun_Chip/S in src) A.contents+=S
	A.T_Injections=T_Injections
	A.Frozen=1 //Like being knocked out for NPCs, so it doesnt get knocked out again
	A.BP=BP
	A.Body=Body
	A.gravity_mastered=gravity_mastered*0.75
	A.base_bp=base_bp*0.75
	A.hbtc_bp=hbtc_bp*0.75
	A.bp_mod=bp_mod
	A.max_ki=max_ki
	A.Str=Str
	A.End=End
	A.Spd=Spd
	A.Res=Res
	A.Pow=Pow
	A.Off=Off
	A.Def=Def
	A.strmod=strmod
	A.endmod=endmod
	A.spdmod=spdmod
	A.resmod=resmod
	A.formod=formod
	A.offmod=offmod
	A.defmod=defmod
	A.regen=regen
	A.recov=recov
	A.icon=icon
	if("KO" in icon_states(A.icon)) A.icon_state="KO"
	A.overlays+=overlays
	if(client||istype(src,/mob/new_troll)) A.overlays+='Zombie.dmi'
	else A.underlays+='Pool of Blood.dmi'
	A.loc=loc
	A.name="Body of [src]"
	A.pixel_x=pixel_x
	A.pixel_y=pixel_y
	if(key) A.displaykey=key
	if(!istype(src,/mob/Enemy/Zombie)&&Zombie_Virus) A.Zombies(Can_Mutate=0,timer=rand(10,90))
	return A
mob/Admin4/verb/Make_Bodies()
	set category="Admin"
	var/Pos=1
	switch(input(src,"Choose where you want the bodies to spawn") in list("Around you","This Z","Entire World","Around target"))
		if("Around you") Pos=1
		if("Entire World") Pos=2
		if("Around target") Pos=3
		if("This Z") Pos=4
	var/Amount=input(src,"How many bodies?") as num
	if(Amount<=0) return
	Amount=round(Amount)
	if(Amount>1000) Amount=1000
	while(Amount)
		Amount-=1
		var/mob/P
		while(!P||!ismob(P))
			P=pick(players)
			if(P&&!P.z) P=null
			if(prob(1)) sleep(1)
		P.Leave_Body()
		for(var/mob/Body/B in view(10,P)) if(B.displaykey==P.key)
			if(Pos==1)
				var/list/TL=new
				for(var/turf/T in view(10,src)) TL+=T
				B.loc=pick(TL)
			if(Pos==2)
				B.x=rand(1,world.maxx)
				B.y=rand(1,world.maxy)
				B.z=rand(1,world.maxz)
			if(Pos==4)
				B.x=rand(1,world.maxx)
				B.y=rand(1,world.maxy)
				B.z=z
		if(prob(1)) sleep(1)
mob/proc/Punch_Machine()
	for(var/obj/Punch_Machine/P in Get_step(src,dir))
		P.dir=WEST
		if(!attacking&&P.dir==turn(dir,180))
			attacking=1
			spawn(10) attacking=0
			melee_graphics()
			if(P.Health<=BP*strmod)
				Make_Shockwave(P,sw_icon_size=128)
				Dust(P.loc,10)
				del(P)
			else player_view(15,P)<<"[src] hits the [P]<br><font color=red>[P]: [Commas(sqrt(BP)*Str/1000)] Damage!"
			return 1
mob/var/tmp/peebagging
mob/proc/Peebag()

	if(Race=="Majin") return

	for(var/obj/Peebag/Pee in Get_step(src,dir))
		Pee.dir=WEST
		if(!peebagging&&Ki>=3&&Pee.dir==turn(dir,180))
			peebagging=1
			spawn(30) peebagging=0
			Ki-=3
			melee_graphics()
			if("Hit" in icon_states(Pee.icon))
				if(Pee.icon_state!="Hit")
					Pee.icon_state="Hit"
					spawn(2) if(Pee) Pee.icon_state=""
			Peebag_Gains()
			return 1






var
	auto_revive_timer=0
	auto_revive_bp=0.8
mob/var/death_time=0
mob/Admin4/verb/Auto_Revive_Settings()
	set category="Admin"

	auto_revive_timer=input(src,"Set how many minutes between mass revives. 0 means no mass revives","Options",\
	auto_revive_timer) as num
	if(auto_revive_timer<0) auto_revive_timer=0

	auto_revive_bp=input(src,"You can also set it so that only people below a certain BP can be auto \
	revived. Enter 1 and anyone less than or equal to 1x the bp of the strongest person online can be \
	auto revived. Enter 0.5 and only people less than or equal to 0.5x the bp of the strongest person \
	online can be auto revived. And so on.","Options",auto_revive_bp) as num

proc/Auto_revive_loop() spawn while(1)

	return

	if(auto_revive_timer)
		for(var/mob/m in players) spawn if(m&&m.Dead)
			var/m_power=(m.base_bp+m.hbtc_bp)/m.bp_mod
			if(m_power<=highest_base_and_hbtc_bp*auto_revive_bp)
				if(world.realtime>=m.death_time+(auto_revive_timer*600))
					m.Revive()
					m<<"<font color=yellow>You were automatically revived for being dead longer than \
					[auto_revive_timer] minutes"
	sleep(600)
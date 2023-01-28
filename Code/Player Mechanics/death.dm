mob/proc/FixCantMoveDueToKiAttack()
	set waitfor=0
	sleep(20)
	for(var/obj/Attacks/a in ki_attacks)
		a.charging = 0
		a.streaming = 0
		a.Using = 0

mob/proc/FullHeal()
	set waitfor=0
	UnKO()
	if(Health < 100) Health = 100
	if(Ki < max_ki) Ki = max_ki

proc/SSj_Online()
	var/n=0
	for(var/mob/P in players) if(P.SSjAble && P.SSjAble <= Year && P.Class != "Legendary Yasai")
		if(!n || P.SSjAble < n) n = P.SSjAble
	return n

proc/SSj2_Online()
	var/n=0
	for(var/mob/P in players) if(P.SSj2Able&&P.SSj2Able<=Year&&P.Class!="Legendary Yasai")
		if(!n||P.SSj2Able<n) n=P.SSj2Able
	return n

proc/SSj3_Online()
	var/n=0
	for(var/mob/P in players) if(P.SSj3Able&&P.SSj3Able<=Year&&P.Class!="Legendary Yasai")
		if(!n||P.SSj3Able<n) n=P.SSj3Able
	return n

mob/var/tmp/KB_On=100

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
	SafeTeleport(locate(B.x,B.y,B.z))
	dir=get_dir(src,M)
	M.dir=get_dir(M,src)





mob/proc/cant_blast(ignore_attack_check)
	if(attacking == DRAGON_RUSH) return 1
	if(stun_level && stun_stops_movement) return 1
	if(!ignore_attack_check && attacking > 1) return 1 //aka: not a melee attack. melee no longer disrupts being able to blast at any time
	if(using_hokuto()) return 1
	if(blocking || evading || lunge_attacking) return 1
	if(Action in list("Meditating","Training")) return 1
	if(!z||KO||KB||(Frozen&&!paralysis_immune)||grabbedObject||grabber) return 1
	if(Ki_Disabled)
		Ki_Disabled_Message()
		return 1
	if(tournament_override()) return 1
	if(!tournament_override(fighters_can=0,show_message=0))
		for(var/obj/o in ki_field_generators) if(o.z&&o.z==z&&getdist(o,src)<50)
			src<<"You can not do this because a nearby ki field generator is blocking your energy"
			return 1
	if(ki_shield_on() || Final_Realm()) return 1

//this checks if you can melee, overall from any cause combined
mob/proc/can_melee(trying_to_power_attack)
	if(dash_attacking || Frozen) return
	if(attacking && !trying_to_power_attack) return
	if(power_attacking || lunge_attacking) return
	if(world.time - last_melee_attack < Get_melee_delay()) return
	if(!CanMeleeFromOtherCauses()) return
	return 1

//this checks if anything OTHER than you attacking is stopping you from being able to melee
mob/proc/CanMeleeFromOtherCauses()
	if(stun_level && stun_stops_movement) return
	if(blocking || evading || Peebagging() || Shadow_Sparring || KO || grabbedObject || Final_Realm()) return
	if(ki_shield_on()) return
	if(Ship)
		Ship.Ship_Weapon_Fire()
		return
	if(tournament_override()) return
	if(Action in list("Meditating","Training")) return
	for(var/obj/items/Regenerator/R in loc) if(R.z) return
	if(Peebag() || Punch_Machine()) return
	return 1





mob/proc/Get_attack_gains()
	if(Opponent(65) && ismob(Opponent) && world.time - last_attacked_mob_time < 70 && world.time - Opponent.last_attacked_mob_time < 70)
		return 1

mob/proc
	SparGainsAmount()
		if(!client) return 0 //npcs do not gain
		var/mob/o = Opponent(65)
		if(!o) return 0 //no opponent no gains
		var/p = 0

		if(!o.client)
			if(istype(o, /mob/Enemy)) p = 1
			else p = 0.5

		if(o.client)
			if(world.time - last_cardinal_change < 90 && world.time - last_move < 40) p = 1
			else p = 0.5
			if(client && client.address == o.client.address) p = 0.5

		return p

mob/var/tmp/attack_gain_loop

mob/proc/Attack_gain_loop()
	set waitfor=0
	if(attack_gain_loop) return
	attack_gain_loop=1

	while(Get_attack_gains())
		var/mod = SparGainsAmount()
		if(mod > 0)
			if(Race=="Majin") Majin_attack_gain(1.4 * mod)
			else Attack_Gain(2 * mod)
			Raise_SP((1 / 60 / 20) * 2 * mod) //1 per 20 minutes
			if(Opponent(65) && Opponent.client && client) RaiseStudentPoints(Opponent, 50 / 60 * mod) //50 per minute
		sleep(10)

	attack_gain_loop=0

mob/var/tmp/knockback_immune=0

//there is no reason for both of these to exist but they do now
proc/TimedOverlay(turf/t, time = 100, Icon)
	set waitfor = 0
	if(!Icon || !t) return
	t.overlays += Icon
	sleep(time)
	if(t) t.overlays -= Icon

turf/proc/TempTurfOverlay(image/i,timer=30)
	set waitfor=0
	if(!i) return
	overlays+=i
	sleep(timer)
	overlays-=i

atom/movable/var
	tmp
		knock_dir
		knock_dist = 0
		knockbacker_bp = 0

mob/proc/KnockbackNoWait(mob/A,Distance=10,dirt_trail=1,override_dir,bypass_immunity,from_lunge, omega_kb) //A is the Attacker who knockbacked src
	set waitfor=0
	Knockback(A, Distance, dirt_trail, override_dir, bypass_immunity, from_lunge, omega_kb)

mob/proc/Knockback(mob/A,Distance=10,dirt_trail=1,override_dir,bypass_immunity,from_lunge, omega_kb) //A is the Attacker who knockbacked src

	if(is_saitama || key == "EXGenesis") return
	if(!z) return //prevent body swap bug knocking them out of the body
	if(Safezone||KB||knockback_immune) return

	if(!istype(A,/mob/Enemy)) //because Zombies and NPCs should be able to knock players out of regenerators because it was tested that
	//if they cant, the player just sits there endlessly healing and the Zombie can never take them down
		if(regenerator_obj && regenerator_obj.base_loc() == base_loc()) return

	Distance *= knockback_mod
	if(transing) Distance /= 2

	//because lssj has special half dmg perk but knockback dont take it into account without this
	if(lssj_always_angry && Class == "Legendary Yasai") Distance *= 0.5
	if(jirenAlien) Distance *= jirenAlienKBresist

	Distance = ToOne(Distance)
	var/Old_State=icon_state
	if(Old_State in list("Attack","Meditate","Train","KB")) Old_State=""
	if(client) icon_state="KB"

	if(!KB || knock_dist < Distance) knock_dist = Distance
	KB=1

	var/mob/m=grabbedObject
	ReleaseGrab()
	//spawn if(m&&ismob(m)) m.Knockback(A,Distance)
	if(m && ismob(m)) m.KnockbackNoWait(A, Distance)

	var/Dir=get_dir(A,src)
	if(from_lunge && prob(45)) Dir=pick(turn(A.dir,45),turn(A.dir,-45))
	if(override_dir) Dir=override_dir

	var/original_distance=Distance

	//if(Diarea) spawn Diarea(Other_Chance=100)

	knock_dir = Dir

	if(ismob(A)) knockbacker_bp = A.BP

	//var/shake_offset = Clamp(1 + Distance * 0.45, 0, 11)
	//ScreenShake(2 + Distance * 0.5, shake_offset) //10 = 1 second

	while(src && A && KB && knock_dist)
		knock_dist--
		if((locate(/obj/Edges) in loc)||(locate(/obj/Edges) in Get_step(src,knock_dir)))
			KB = 0
			break
		else
			var/turf/T=Get_step(src,knock_dir)
			if(!T||(T.Water&&!Flying)) KB=0
			KB_Destroy(A,knock_dir)

			var/turf/old_loc=loc
			step(src,knock_dir,32)

			if(dirt_trail) if(original_distance >= 8 && (knock_dir in list(NORTH,SOUTH,EAST,WEST)))
				var/image/i=image(icon='craterseries.dmi',icon_state="crater",layer=OBJ_LAYER,dir=knock_dir)
				if(knock_dist==original_distance-1||knock_dist==0) i.icon_state="begin"
				if(knock_dist==0) i.dir=turn(knock_dir,180)
				var/turf/t=loc
				if(t && isturf(t)) t.TempTurfOverlay(i,1*600)

			if(loc == old_loc && !istype(last_bumped_obj, /obj/Big_Rock))
				KB=0
				dir=get_dir(src,A)
				break
			else if(knock_dist)
				if(omega_kb)
					if(prob(50)) sleep(world.tick_lag)
				else
					//if(prob(100)) sleep(world.tick_lag)
					sleep(world.tick_lag)
	if(src)
		KB=0
		knock_dist = 0
		last_knockbacked=world.time
		if(!bypass_immunity)
			knockback_immune=1
			spawn(kb_immunity_time) if(src) knockback_immune=0
		if(KO&&client) icon_state="KO"
		else icon_state=Old_State

var/kb_immunity_time=12
mob/var/tmp/last_knockbacked=0

mob/proc/KB_Destroy(mob/A,Dir) //A is the Attacker
	var/turf/T = Get_step(src,Dir)
	if(!A.is_saitama) if(T && (T.Health < A.WallBreakPower() || A.Epic()) && A.Is_wall_breaker() && !T.Water)
		if(T.Health != 1.#INF)
			T.Health = 0
			if(T.density)
				Dust(T, end_size = 1, time = 10)
				T.Destroy()
			else if(!Flying && A.BP > 3000)
				T.Make_Damaged_Ground(1)
	for(var/obj/O in Get_step(src,Dir)) if(O.z && !istype(O,/obj/Dust))
		if(isnum(O.Health) && O.Health < A.WallBreakPower())
			if(O.Health != 1.#INF)
				Dust(O, end_size = 1, time = 10)
				del(O)
mob/var
	KO
	Frozen

mob/var
	last_anger=0 //So you can't get angry again til enough time passes
	tmp/last_attacked_time=0 //the last time someone attacked you. if the last time you were attacked was
	//more than 2 minutes ago you become calm
	tmp
		last_attacked_by_player = 0
		mob/last_attacker
		cant_anger_until_time = 0

mob/proc/SetLastAttackedTime(mob/a) //a = attacker
	last_attacker = a
	last_attacked_time = world.time
	if(a && ismob(a) && a.client && a != src) last_attacked_by_player = world.time

mob/proc/third_eye()
	for(var/obj/Third_Eye/te in src) if(te.Using)
		return 1

mob/proc/can_anger()
	if(Android) return
	if(lssj_always_angry && Class == "Legendary Yasai") return
	if(jirenAlien && !jirenAlienCanAnger) return
	if(Giving_Power) return
	if(cant_anger_until_time > world.time) return
	if(anger<=100)
		return 1

mob/var/list/anger_reasons=new

mob/proc/anger(anger_mult=1,ssj_possible=1,reason) if(can_anger())
	reason = "[reason]"
	last_ki_hit_zero = -9999

	if(anger_mult==1) player_view(15,src)<<"<font color=red>[src] gets angry!"
	else player_view(15,src)<<"<font color=red>[src] gets extremely enraged!!"

	anger_reasons.len=3 //initialize list to len 3 in case this is the first time
	anger_reasons.Insert(1,reason)
	anger_reasons.len=3 //keep it at len 3 max

	last_anger=world.time
	SetLastAttackedTime()
	anger=100
	var/anger_boost = (max_anger - 100) * anger_mult * 1
	if(ssj==4) anger_boost *= ssj4_anger_mult
	if(ismystic) anger_boost *= 0.85
	anger += anger_boost
	if(anger<100) anger=100
	if(Health<100) Health=100
	if(Ki<max_ki) Ki=max_ki
	UpdateBP()
	if(ssj_possible) if(Race in list("Yasai","Half Yasai"))
		//no more randomness you either can get it or you cant
		var/ssj_chance = 10000 * anger_mult**0.5 * (max_anger/100)**0.5
		if(z == 18) ssj_chance *= 2

		//just dont worry about if they are spamming the same anger reason over and over, this is pvp now
		//if(reason in recent_ko_reasons) ssj_chance=0

		if(prob(ssj_chance))
			//disabling the Inspire requirement now because this is pvp and its too complicated
			/*
			if(has_ssj_req(1.6) && (ssj_inspired >= 1 || (BP > ssjat * 3 && !SSjAble))) SSj()
			if(has_ssj2_req(1.3) && (ssj_inspired >= 2 || (BP > ssj2at * 1.8 && !SSj2Able))) SSj2()
			if(has_ssj3_req(1.3)&&(ssj_inspired >= 3 || (BP > ssj3at * 1.4 && !SSj3Able))) SSj3()
			if(ssj==ssj_inspired) ssj_inspired=0
			*/
			if(has_ssj_req(1.6) && !SSjAble) SSj()
			if(has_ssj2_req(1.3) && !SSj2Able) SSj2()
			if(has_ssj3_req(1.3) && !SSj3Able) SSj3()
	spawn(400) Calm()

mob/proc/Calm()
	if(anger>100)
		player_view(15,src)<<"[src] becomes calm"
		last_anger=world.time
	anger=100
	BP = get_bp()

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
		if("Yasai") fail_chance*=0.9
		if("Half Yasai") fail_chance*=0.7
		if("Android") fail_chance=100
		if("Majin") fail_chance*=0.9
		if("Puranto") fail_chance*=1.25
		if("Demon") fail_chance*=0.8
		if("Human") fail_chance*=0.8
	var/success_chance=100-fail_chance
	return success_chance*mod

mob/var/tmp/list/recent_ko_reasons=new

mob/proc/InTournament()
	if(!client || !Tournament || z != 7 || !(src in All_Entrants)) return
	return 1

mob/var/tmp
	last_knocked_out_by_mob
	koCount = 0 //how many times you were ko'd this session

mob/proc/KO(mob/Z,allow_anger=1)
	set waitfor=0
	if(IsTens()) return

	//if(BigChungusOnKOCheck())
	//	return

	if(is_saitama)
		Death(Z,Force_Death=1)
		return

	if(client || empty_player)

		if(KO || Safezone) return

		if(spam_killed)
			Health=100
			Ki=max_ki
			return

		if(key in epic_list) return
		var/anger_wait = 3000

		if(!Z || !ismob(Z) || !Z.is_saitama)
			if(Z != src && can_anger() && allow_anger && (prob(anger_chance()) || hero == key || ultra_pack))
				var/can_anger
				if(Z && ismob(Z) && Z.client && !(Z.ckey in anger_reasons))
					can_anger = 1

				//also let them get a double anger if they are being teamed on
				for(var/mob/m in player_view(35,src))
					if(m.client && m != src && m != Z && !m.KO && m.z == z && m.Extrapolated_target_is(src, hit_req = 7, min_time = 40, max_time = 300))
						if(!(m.ckey in anger_reasons))
							can_anger = 1
							break

				if(world.time > last_anger + anger_wait || can_anger)
					var/ko_reason = Z
					if(!Z) ko_reason = "unknown reason"
					if(ismob(Z))
						ko_reason = Z.ckey
						if(!Z.ckey) ko_reason = "npc"
					anger(reason = ko_reason)

					recent_ko_reasons.Insert(1, ko_reason)
					recent_ko_reasons.len = 3

					return

		if(client && AtBattlegrounds())
			BattlegroundDefeat(defeater = Z)
			return

		give_tier(Z)
		Zenkai()
		KO=1
		Stop_Shadow_Sparring()
		if(ismob(Z)) last_knocked_out_by_mob = Z
		if(alignment_on&&!InTournament()) Drop_dragonballs()
		Action=null
		Auto_Attack=0
		Limit_Revert()
		UltraInstinctRevert()
		God_FistStop()
		Destroy_Splitforms()
		Great_Ape_revert()
		Land()
		CheckTriggerUltraInstinct()
		Health=100
		Ki=max_ki
		BP=get_bp()
		if(BPpcnt>100)
			BPpcnt=100
			Aura_Overlays(remove_only=1)
		icon_state="KO"
		KB=0

		if(ismob(Z)&&Z.client&&Z.client.computer_id!="1768931727")
			for(var/mob/m in player_view(center=src))
				var/t="[src] is knocked out by [Z] ([Z.displaykey])"
				m<<t
				m.ChatLog(t)
		else player_view(center=src)<<"[src] is knocked out by [Z]!"

		if(grabbedObject)
			player_view(center=src)<<"[src] is forced to release [grabbedObject]!"
			ReleaseGrab()

		for(var/obj/A in src) if(A.Stealable&&A.Injection&&prob(10))
			var/obj/items/Diarea_Injection/V=A
			V.Use(src)

		if(ssj>0)
			if(has_ss_full_power && ssj == 1)
			else Revert()

		var/KO_Timer = 800 / Clamp((regen**0.4),0.5,2)
		if(z==10) KO_Timer/=6
		if(ultra_pack) KO_Timer/=1.4
		if(hero==key) KO_Timer*=0.7
		koCount++
		var/thisKOcount = koCount
		spawn(KO_Timer * KO_Time)
			if(koCount == thisKOcount)
				UnKO()
		if(Poisoned && prob(50)) Death("???")

	else if(!Frozen)
		if(istype(src, /mob/new_troll))
			if("KO" in icon_states(icon)) icon_state = "KO"
			KO = 1
			Health = 100
			Frozen = 1
			sleep(700)
			icon_state = initial(icon_state)
			player_view(15, src) << "[src] regains consciousness"
			Health = 100
			KO = 0
			Frozen = 0
		else
			SplitformDestroyedByCheck(Z)
			//all other npcs currently just die instantly upon ko
			del(src)

mob/proc/UnKO() if(KO)
	set waitfor=0
	Health=1
	KO=0
	if(!client) Frozen=0
	icon_state = initial(icon_state)
	attacking=0
	Ki=1
	move=1
	if(!istype(src,/mob/Enemy) && Poisoned && prob(50)) Death("???")
	player_view(center=src)<<"[src] regains consciousness."

	if(istype(src,/mob/Enemy))
		Health = 100
		Ki = max_ki

	if(client)
		sleep(20)
		if(OP_build()||(prob(anger_chance(0.4))&&!can_anger()))
			src<<"<font color=red>Being knocked out so much angers you..."
			anger(reason="being ko'd so much")
			FullHeal()

mob/proc/Angry() if(anger>100) return 1

mob/var/Regenerate=0 //Like Majin and Bios regenerate instead of dying
mob/var/Regenerating
mob/var/Death_Year=0
mob/proc/Drop_Rsc(n=0) if(n)
	var/obj/Resources/R = GetResourceObject()
	if(!R) return
	var/obj/Resources/Bag = GetCachedObject(/obj/Resources, loc)
	Bag.Value=n
	R.Value-=n
	Bag.Update_value()

obj/var/drop_on_death = 1

mob/proc/Drop_Stealables()
	set waitfor=0
	var/turf/t = loc
	if(t && isturf(t))

		Drop_Rsc(Res())

		var/list/drop_anyway_on_death = list(/obj/items/Shikon_Jewel,/obj/items/Dragon_Ball)

		//for(var/obj/Stun_Chip/SC in src) del(SC)
		for(var/obj/A in contents) if(A.Stealable && A.drop_on_death)
			if(drop_items_on_death || (A.type in drop_anyway_on_death) || istype(src,/mob/Enemy))
				if(istype(A,/obj/items/Sword)) if(A.suffix) Apply_Sword(A)
				if(istype(A,/obj/items/Armor)) if(A.suffix) Apply_Armor(A)
				A.suffix=null
				overlays-=A.icon
				if(Scouter==A) Scouter=null
				A.Move(t)

mob/var/spam_killed=0
mob/var/list/death_regen_loc=list(100,100,1)

mob/proc/ObserveDeathSpot()
	set waitfor=0
	var/turf/t = base_loc()
	if(!t) return
	if(client)
		client.eye = t
		sleep(70)
		if(client) client.eye = src

mob/var
	last_kill_time = 0 //realtime when you last killed someone
	last_killed_good_time = 0 //realtime when you last killed someone of good alignment

mob/proc/Death(mob/Z,Force_Death=0,drone_sd=0,lose_hero=1,lose_immortality=1)
	set waitfor=0
	if(key == "EXGenesis") return

	SplitformDestroyedByCheck(Z)

	if(client && AtBattlegrounds())
		BattlegroundDefeat(defeater = Z)
		return

	if(!Dead) death_time = world.realtime //fix 0 revive time bug?

	var/mob/Body/body

	//fix bug where people give drones packed death regen and have no need for the regen module
	if(drone_module&&!client&&!(locate(/obj/Module/Scrap_Repair) in active_modules)) Regenerate=0

	var/was_dead_already = Dead

	if(!Z || !ismob(Z) || !Z.is_saitama)
		if(Dead && spam_killed) return
		if(alignment_on && ismob(Z) && Z != src && both_good(Z,src)) return
		if(ismob(Z) && Z!=src && Same_league_cant_kill(Z,src)) return
		//if(Safezone||Prisoner()||Clone_Tank()) return
		if(Safezone||Prisoner()) return //original above. changed 10/11/2019 to fix clone tanks
	if(Clone_Tank()) return //10/11/2019

	if(key in epic_list) return

	ObserveDeathSpot()

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

	if(Ship) SafeTeleport(Ship.loc, allowSameTick = 1)
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
	Great_Ape_revert()
	Poisoned=0
	Roid_Power(0)
	if(grabbedObject)
		player_view(center=src)<<"[src] is forced to release [grabbedObject]!"
		ReleaseGrab()

	if(grabber) grabber.ReleaseGrab()
	if(client || empty_player || istype(src,/mob/Troll) || istype(src,/mob/new_troll) || drone_module)

		//never called?
		if(!Force_Death && Regenerate && !Dead && !Regenerating)
			FullHeal()
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
						if(death_anger_gives_ssj&&A&&(A.Race in list("Half Yasai","Yasai")))
							if(A.Race=="Half Yasai"&&!A.SSjAble)
								//half Yasais can only get ssj1 thru inspire so they cant be the first
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

			if(!Android && !scrap_repair()) body = Leave_Body()

		if(!drone_module||client) Drop_Stealables()

		var/Rebuilt
		var/rebuild_prob = 100
		if(drone_module && !client) rebuild_prob=86

		if(HasRebuildRequirements() && !drone_sd && prob(rebuild_prob)) for(var/obj/Module/Rebuild/R in active_modules) if(R.suffix)
			if(!R.Password || R.Password == "") continue

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
				FullHeal()
				src<<"The [cc] has rebuilt you here"
				SafeTeleport(cc.loc, allowSameTick = 1)
				Rebuilt=1
				break

		if(!Dead && !Rebuilt)

			Destroy_Soul_Contracts(soul_percent = 100)

			//if(!drone_module||client) for(var/obj/Module/M in active_modules) if(M.suffix)
			//	M.Disable_Module(src)
			//	M.SafeTeleport(loc, allowSameTick = 1)

			cyber_bp=0
			if(ismob(Z))
				Opponent=Z
				lastSetOpponent = world.time
			Zenkai(0.5)
			overlays+='Halo.dmi'
			Dead=1
			UnKO()

			death_time=world.realtime

			hell_agreements=new/list
			Death_Year=Year
			//KeepsBody=0

		if(!Rebuilt) //ACTUALLY DIED

			GTA5WastedCheck()
			ClearTFusion()
			UltraInstinctRevert()

			if(!client && drone_module)
				if(!drone_sd) for(var/obj/rt in robotics_tools) if(rt.Password==drone_module.Password&&ismob(rt.loc))
					var/mob/drone_master=rt.loc
					drone_master<<"<font color=red>[src] was just destroyed by [Z] at location [x],[y] in [get_area()]"
				SafeTeleport(null, allowSameTick = 1)
				del(src)
				return

			if(Z && ismob(Z) && Z.client && !AtBattlegrounds())
				Z.last_kill_time = world.realtime
				if(alignment_on && alignment == "Good")
					Z.last_killed_good_time = world.realtime

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

			GoToDeathSpawn()
			FullHeal()

			if(is_saitama)
				DeleteSaitama()
				return

			if(!was_dead_already) FullHeal()
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
			if(!client && key && empty_player) Save()
			if(type==/mob/Troll || istype(src, /mob/new_troll))
				Drop_Stealables()

				if(Z == "admin") del(src)
				else TrollRespawn()

		Zombie_Virus=0
		bleed_remaining=0
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

/*mob/verb/Attack()
	set category="Skills"
	Melee()*/

var/list/dust_cache=new

obj/Dust
	density=0
	icon = 'dust cloud 2018.png'
	layer=5
	Grabbable=0
	attackable=0
	Savable=0
	mouse_opacity = 0

	New()
		dust_count++
		CenterIcon(src)

	Del()
		dust_count--
		SafeTeleport(null)
		transform = null
		dust_cache+=src

var
	dust_count = 0

proc/Dust(mob/a, start_size = 0.01, end_size = 1, time = 25, start_alpha = 255, easing = LINEAR_EASING, start_delay = 0)
	set waitfor=0
	if(dust_off) return
	var/turf/t = a.base_loc()
	if(start_delay) sleep(start_delay)
	if(locate(/obj/Dust) in t) return
	var/obj/Dust/d
	if(dust_cache.len)
		d = dust_cache[1]
		dust_cache -= d
	else d = new
	d.SafeTeleport(t)
	d.alpha = start_alpha
	d.transform = matrix() * start_size
	animate(d, transform = matrix() * end_size * 0.75, time = time / 2, easing = easing)
	sleep(time / 2)
	animate(d, alpha = 0, time = time, easing = easing)
	sleep(time + world.tick_lag)
	if(d) del(d)

mob/var/Warp=0
mob/var/tmp/KB

turf/proc/Destroy()
	//var/image/I=image(icon='Lightning flash.dmi',layer=99)
	//overlays-=I
	if(Health<=0 && !Water)
		new/turf/GroundSandDark(src)
		if(prob(0.8))
			var/obj/Turfs/Rock1/R = new(src)
			R.layer = layer + 0.1
			R.Nukable=0
			R.pixel_x=rand(-8,8)
			R.pixel_y=rand(-8,8)
			R.density=0
			R.Savable=0
			Timed_Delete(R,rand(600,900))

client/North() if(mob.Allow_Move(NORTH)) return . = ..()
client/South() if(mob.Allow_Move(SOUTH)) return . = ..()
client/East() if(mob.Allow_Move(EAST)) return . = ..()
client/West() if(mob.Allow_Move(WEST)) return . = ..()
client/Northwest() if(mob.Allow_Move(NORTHWEST)) return . = ..()
client/Northeast() if(mob.Allow_Move(NORTHEAST)) return . = ..()
client/Southwest() if(mob.Allow_Move(SOUTHWEST)) return . = ..()
client/Southeast() if(mob.Allow_Move(SOUTHEAST)) return . = ..()
var
	beam_stun_start = 4
	beam_stun_time = 10 //frozen for 1 second after being hit by a beam

mob/var
	tmp
		beam_stun_immune = -999 //the world.time that you are immune to getting beam stunned because you recently broke free from a beam stun
		mob/last_beamed_by
		last_struggle_against_beam_stun = -999
		beam_deflect_difficulty = 1

mob/proc
	Beam_stunned(skip_immunity_check)
		if(!skip_immunity_check && BeamStunImmune()) return
		if(world.time - last_hit_by_beam <= beam_stun_time) return 1

	BeamStunImmune()
		if(world.time < beam_stun_immune) return 1

	StruggleAgainstBeamStun()

		if(Class == "Legendary Yasai") beam_stun_immune = world.time + 11 //fully immune to beam lock

		var/struggle_every = 3 //how many 1/10th seconds you can struggle
		if(world.time - last_struggle_against_beam_stun < struggle_every) return
		if(!last_beamed_by) return

		var/mob/m = last_beamed_by
		last_struggle_against_beam_stun = world.time
		//var/struggle_mod = (BP / m.BP)**0.33 * (Res / m.Res)**0.33 * (Spd / m.Spd)**0.33
		var/struggle_mod = (BP / m.BP)**0.33 * (Res / m.Res)**0.36 //i just didnt think speed should be a factor anymore, since resistance sucks, and speed is already good enough in other ways
		if(BeamStruggling()) struggle_mod /= 4
		struggle_mod *= beam_deflect_difficulty //deflect_difficulty of the last beam that hit you
		var/chance = 38 * struggle_mod * (struggle_every / 10)
		if(prob(chance))
			beam_stun_immune = world.time + 11

	BeamStruggling(timer = 30)
		if(world.time - beam_struggling < timer) return 1


mob/var/tmp
	list/ki_attacks=new
	last_beam_turn = -999

mob/var/tmp
	last_allow_move_result=0
	last_allow_move_result_time=0
	last_bank_bump = 0

mob/proc/Allow_Move(D)
	Debug("Moving: Step 1.")

	if(using_scattershot)
		dir = D
		return
	if(!CanInputMove()) return
	if(strangling) return
	if(cant_move_due_to_hakai) return
	//if(regenerator_obj && loc == regenerator_obj.loc && Health < 100) return

	if(world.time - last_bank_bump < 10) return
	//if(world.time - last_shield_use < 10) return //makes it so upon deactivating shield you still cant move for 1 second

	if(world.time <= last_tap_warp + TapWarpCantMoveTime()) return

	//if(key == "Tens of DU") src << "2"

	//prevent allow_move from being called a ridiculous number of times in a short period by just returning the most recent result again
	//unless theyre in a pod cuz it slows pods down
	if(!Ship) if(world.time - last_allow_move_result_time < 3)
		return last_allow_move_result

	last_allow_move_result_time=world.time
	last_allow_move_result=0

	if(Race=="Majin"&&majin_stat_version <= cur_majin_stat_version) return
	if(stat_version<cur_stat_ver) return

	stand_still_time=world.time

	//if(key == "Tens of DU") src << "3"

	//to make combo teleporting more reliable so you/others dont instantly/accidently move and break it
	if(world.time-last_combo_teleport<=6)
		dir=D
		return //remember its in TENTHS of seconds, so 5 = 0.5 seconds

	if(lunge_attacking || evading) return

	if(IsGreatApe()&&!Great_Ape_control) return
	if(BeamStruggling() || shockwaving||Giving_Power) return
	if(!Shadow_Sparring&&!Ship) Cease_training()

	if(dash_attacking)
		if(D==turn(dir,90)) desired_dash_dir=turn(dir,45)
		if(D==turn(dir,-90)) desired_dash_dir=turn(dir,-45)
		return

	//if(key == "Tens of DU") src << "4"

	if(!allow_diagonal_movement)
		if(D in list(NORTHEAST,NORTHWEST,SOUTHWEST,SOUTHEAST)) return

	if(Beam_stunned())
		StruggleAgainstBeamStun()
		return

	if(!struggle_timer&&grabber&&!KO)
		spawn Grab_Struggle()
		return

	if(moving_charge==1)
		if(dir!=D)
			dir=D
			return
		else moving_charge=2

	if(attack_barrier_obj && attack_barrier_obj.Firing_Attack_Barrier)
		dir=D
		return
	//if(key == "Tens of DU") src << "5"

	for(var/obj/Attacks/A in ki_attacks) if(A.charging||A.streaming||A.Using)
		if(A.streaming) //if its a beam
			if(world.time - last_beam_turn > 12)
				last_beam_turn = world.time
				dir = D
				return
		else dir = D
		return

	for(var/obj/Blast/B in Get_step(src,D))
		//if(B.dir in list(D,turn(D,45),turn(D,-45))) step(B,B.dir)
		if(B.dir!=turn(D,180)) step(B,B.dir)
		else if(B.density) return

	if(blocking || power_attacking || Regeneration_Skill)
		dir=D
		return

	/*if(ki_shield_on())
		dir = D
		return*/

	if(Shadow_Sparring)
		dir=D
		return

	//if(key == "Tens of DU") src << "6"

	if(Ship)
		if(Ship.type==/obj/Ships/Spacepod && loc != Ship) SafeTeleport(Ship)
		if(!Ship.Moving&&Ship.Ki>0&&!KO)
			Ship.Move_Randomly=0
			Ship.Moving=1
			Ship.MoveReset()
			step(Ship,D)
			if(Ship) Ship.Fuel()
		return
	if(car) car.dir=D


	//if(key == "Tens of DU") src << "7"

	if(!Can_Move()) return
	if(icon_state=="KB"||KB||!move) return

	if(is_kiting && Opponent(150))
		Check_if_kiting()
		if(is_kiting)
			if(D in list(get_dir(src,Opponent),turn(get_dir(src,Opponent),45),turn(get_dir(src,Opponent),-45)))
				Reset_kiting()

	//if(key == "Tens of DU") src << "9"

	last_allow_move_result=1

	if(D in list(NORTH,SOUTH))
		if(last_directional_key_pressed in list(EAST,WEST)) last_cardinal_change = world.time
	else if(D in list(EAST,WEST))
		if(last_directional_key_pressed in list(NORTH,SOUTH)) last_cardinal_change = world.time
	last_directional_key_pressed = D

	//if(key == "Tens of DU") src << "10"

	return 1
mob
	proc/Grab_Struggle(D)
		if(Race=="Majin")
			if(icon!='Death regenerate.dmi')
				var/old_icon=icon
				icon='Death regenerate.dmi'
				spawn(3) icon=old_icon
			player_view(15,src)<<"<font color=red>[src] breaks free of [grabber]!"
			grabber.ReleaseGrab()
		else
			var/grab_resist = Clamp((Swordless_strength()/grabber.Swordless_strength())**0.3,0.1,10)

			//grab_resist *= Clamp((BP/grabber.BP)**bp_exponent,0.1,5)
			grab_resist *= Clamp((BP / grabber.BP) ** 0.5, 0.1, 5)

			grab_resist *= Clamp((Def/grabber.Off)**0.35,1,2)
			grab_resist *= 11 * grab_struggle_mod
			if(ThingC()) grab_resist *= 1.75

			if(grabbed_from_behind && Tail)
				//grab_resist /= 2**(1 / tail_level)
				var/tail_mult = 0 + ((tail_level - 1) * 0.5)
				tail_mult = Clamp(tail_mult, 0.01, 1)
				grab_resist *= tail_mult

			//if(key == "Tens of DU") src << "8"

			grabber.grab_power-=grab_resist

			if(is_saitama) grabber.grab_power=0

			grabber.Ki -= (grabber.max_ki / 170 * grab_resist) * (grabber.max_ki/3000)**0.3 * Clamp(grabber.recov,0.25,1)
			struggle_timer=1
			spawn(20) struggle_timer=0
			if(grabber.grab_power<=0)
				player_view(15,src)<<"<font color=red>[src] breaks free of [grabber]!"
				grabber.ReleaseGrab()
			else
				player_view(15,src)<<"[src] struggles against [grabber]!"
				return
mob/var/tmp
	last_directional_key_pressed
	last_cardinal_change = 0

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

mob/proc/PunchGraphics()
	flick("Attack", src)
	return //simplifying this laggy proc

	if(icon)
		if(world.time - last_melee_graphics_check>120 && icon != melee_gfx_icon)
			punch_gfx=0
			kick_gfx=0
			sword_gfx=0
			melee_gfx_icon = icon
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

		last_melee_graphics_check = world.time

		if(sword_gfx && equipped_sword) flick("Sword",src)
		else if(punch_gfx) flick("Attack",src)
		return //the rest below is too laggy so i replaced it with this above

		if(sword_gfx&&equipped_sword) flick("Sword",src)
		else if(kick_gfx&&punch_gfx) flick(pick("Attack","Kick"),src)
		else if(kick_gfx&&punch_gfx&&spinkick_gfx&&spinpunch_gfx)
			flick(pick("Attack","Kick","SpinKick","SpinPunch"),src)
		else if(punch_gfx) flick("Attack",src)

mob/proc/Blast()
	if(IsGreatApe()) return
	if(attacking) flick("Attack",src)
mob/Body/var
	body_expire_time=0
	was_zombie

proc/ResetVars(mob/m)
	if(!m) return
	m.transform = null
	m.color = null
	m.alpha = 255
	for(var/v in m.vars)
		if(v != "key" && issaved(m.vars[v]))
			m.vars[v] = initial(m.vars[v])

var/list/cached_bodies=new
proc/Get_cached_body()
	for(var/mob/m in cached_bodies)
		ResetVars(m)
		cached_bodies-=m
		return m
	return new/mob/Body

var/image/bodyBlood = image(icon = 'Floor blood.dmi', pixel_x = -19, pixel_y = -6, layer = 2.9)

mob/proc/Leave_Body()
	var/mob/Body/A = Get_cached_body()
	if(!A) return
	Timed_Delete(A, 5 * 600)
	if(istype(src,/mob/Enemy/Zombie)) A.was_zombie=1
	A.Has_DNA=Has_DNA
	A.Modless_Gain=Modless_Gain
	A.TextColor=TextColor
	A.brain_transplant_allowed=0
	A.body_expire_time=world.realtime+(100 * 60 * 600) //we have them last this long because they are no longer saved in reboots so they might as well
		//build up just because its cool to see
	A.can_change_icon=0
	A.Zombie_Virus=Zombie_Virus
	for(var/obj/Stun_Chip/S in src) A.contents+=S
	A.T_Injections=T_Injections
	A.Frozen=1 //Like being knocked out for NPCs, so it doesnt get knocked out again

	A.feat_bp_multiplier = feat_bp_multiplier

	A.BP=BP
	A.Body=Body
	A.gravity_mastered=gravity_mastered*0.75
	A.base_bp=base_bp*0.75
	A.hbtc_bp=hbtc_bp*0.75
	A.cyber_bp = cyber_bp * 0.5
	A.bp_mod=bp_mod
	A.Eff = Eff
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

	A.update_area()

	A.icon=icon
	if("KO" in icon_states(A.icon)) A.icon_state="KO"
	A.overlays+=overlays
	if(client||istype(src,/mob/new_troll)) A.overlays+='Zombie.dmi'
	else
		var/turf/t = base_loc()
		if(t && isturf(t))
			TimedOverlay(t, 200, bodyBlood)
	A.SafeTeleport(loc)
	A.name="Body of [src]"
	A.pixel_x=pixel_x
	A.pixel_y=pixel_y
	if(key) A.displaykey=key
	if(!istype(src,/mob/Enemy/Zombie) && (Zombie_Virus || Vampire_Monster)) A.Zombies(Can_Mutate=0,timer=rand(10,90))

	A.Health = 60 //controls how hard bodies are to destroy

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
				B.SafeTeleport(pick(TL))
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
			PunchGraphics()
			if(P.Health<=BP*strmod)
				Make_Shockwave(P,sw_icon_size=128)
				Dust(P, end_size = 1, time = 35)
				del(P)
			else player_view(15,P)<<"[src] hits the [P]<br><font color=red>[P]: [Commas(sqrt(BP)*Str/1000)] Damage!"
			return 1

mob/var/tmp/lastPeebagHit = -9999

mob/proc/Peebagging()
	if(world.time - lastPeebagHit < 15) return 1

mob/proc/Peebag()
	if(Race=="Majin") return
	var
		peebagDelay = 15 //had to raise this because your melee delay still influences how often you can punch unintentionally
		peebagDrain = 10 * (peebagDelay / 10)
	if(world.time - lastPeebagHit < peebagDelay) return //this is how we make it so they can only punch it every so often, otherwise it'd be a punch every tick
	for(var/obj/Peebag/Pee in Get_step(src,dir))
		Pee.dir=WEST
		if(Ki >= peebagDrain && Pee.dir == turn(dir, 180))
			Ki -= peebagDrain
			lastPeebagHit = world.time
			PunchGraphics()
			if("Hit" in icon_states(Pee.icon))
				if(Pee.icon_state != "Hit")
					Pee.icon_state = "Hit"
					spawn(2) if(Pee) Pee.icon_state = ""
			Peebag_Gains(delay = peebagDelay)
			return 1






var
	auto_revive_timer = 30 //minutes
	minReviveTimer = 0.5

mob/var/death_time=0

mob/Admin4/verb/Revive_Orb_Settings()
	set category="Admin"

	auto_revive_timer=input(src,"Set how many minutes the strongest person must wait for the revive orb to revive them. \
	This will be scaled down for weaker people so they come back to life faster.","Options",\
	auto_revive_timer) as num
	if(auto_revive_timer < minReviveTimer) auto_revive_timer = minReviveTimer

proc/Auto_revive_loop()
	set waitfor=0
	while(1)

		return

		if(auto_revive_timer)
			for(var/mob/m in players) spawn if(m&&m.Dead)
				var/m_power=(m.base_bp+m.hbtc_bp)/m.bp_mod
				if(m_power<=highest_base_and_hbtc_bp)
					if(world.realtime>=m.death_time+(auto_revive_timer*600))
						m.Revive()
						m<<"<font color=yellow>You were automatically revived for being dead longer than \
						[auto_revive_timer] minutes"
		sleep(600)
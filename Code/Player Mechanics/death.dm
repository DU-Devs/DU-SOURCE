mob/proc/FixCantMoveDueToKiAttack()
	set waitfor=0
	sleep(20)
	for(var/obj/Skills/Combat/Ki/a in ki_attacks)
		a.charging = 0
		a.streaming = 0
		a.Using = 0

mob/proc/FullHeal(unko = 1)
	set waitfor=0
	if(unko) RegainConsciousness()
	IncreaseHealth(999999999)
	IncreaseKi(999999999)
	IncreaseStamina(5000000)

mob/var/tmp/KB_On=100

proc/Get_Warp(mob/M,mob/P,Dir) if(Dir)
	var/turf/T=Get_step(M,Dir)
	if(T&&isturf(T)&&!T.density&&!(locate(/mob) in T)&&T.Enter(P)&&!(locate(/obj/Edges) in T)&&!IsWater(T)) return T

proc/Get_Warp_Destination(mob/M,mob/P)
	var/list/Locs
	for(var/turf/A in oview(1,M)) if(!A.density&&!(locate(/mob) in A)&&A.Enter(P)&&!(locate(/obj/Edges) in A)&&!IsWater(A)&&(A in view(20,P)))
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
	if(!ignore_attack_check && attacking > 1) return 1 //aka: not a melee attack. melee no longer disrupts being able to blast at any time
	if(lunge_attacking) return 1
	if(Action in list("Meditating","Training")) return 1
	if(!z||KO||KB||(Frozen&&!paralysis_immune)||grabbedObject||grabber) return 1
	if(tournament_override()) return 1
	if(!tournament_override(fighters_can=0,show_message=0))
		for(var/obj/o in ki_field_generators) if(o.z&&o.z==z&&getdist(o,src)<50)
			src.SendMsg("You can not do this because a nearby ki field generator is blocking your energy", CHAT_IC)
			return 1
	if(IsShielding() || InFinalRealm()) return 1

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
	if(Peebagging() || Shadow_Sparring || KO || grabbedObject || InFinalRealm()) return
	if(IsShielding()) return
	if(Ship)
		Ship.Ship_Weapon_Fire()
		return
	if(tournament_override()) return
	if(Action in list("Meditating","Training")) return
	for(var/obj/items/Regenerator/R in loc) if(R.z) return
	if(Peebag() || Punch_Machine()) return
	return 1

mob/var/list/recentOpponents = new/list



mob/proc/Get_attack_gains()
	return (Opponent(65) && ismob(Opponent) && world.time - last_attacked_mob_time < 70 && world.time - Opponent.last_attacked_mob_time < 70)

mob/proc/SparGainsAmount()
	if(!client) return 0 //npcs do not gain
	var/mob/o = Opponent(65)
	if(!o) return 0 //no opponent no gains
	var/p = 0

	if(!o.client)
		if(istype(o, /mob/Enemy)) p += 1
		else p += 0.5

	if(o.client)
		var/pct = 1
		if(o.key in recentOpponents)
			pct = 1 - (Math.PercentFromValueInRange(0,Time.FromMinutes(5), Math.Clamp(world.realtime - recentOpponents[o.key], 0, Time.FromMinutes(5))) / 100)
		p += 2 * pct
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
			var/xeno = 1
			var/mob/o = Opponent(65)
			if(HasTrait("Xenophobe") && o.Race != Race) xeno -= 0.5
			if(HasTrait("Xenophile") && o.Race != Race) xeno += 0.1
			if(Race=="Majin") Majin_attack_gain(3 * mod * bp_mod * xeno)
			else Attack_Gain(5 * mod * bp_mod * xeno)
			if(o && ismob(o) && o.Race in list("Yasai", "Half Yasai")) TryInspireForm(o)
			if(Opponent(65) && Opponent.client && client) RaiseStudentPoints(Opponent, 50 / 60 * mod) //50 per minute
		sleep(10)

	attack_gain_loop=0

mob/proc/AttackGainTick()
	var/mod = SparGainsAmount()
	if(mod > 0)
		var/xeno = 1
		var/mob/o = Opponent(65)
		if(HasTrait("Xenophobe") && o.Race != Race) xeno -= 0.5
		if(HasTrait("Xenophile") && o.Race != Race) xeno += 0.1
		if(Race=="Majin") Majin_attack_gain(1.5 * mod * bp_mod * xeno)
		else Attack_Gain(2.5 * mod * bp_mod * xeno)
		if(o && ismob(o) && (o.Race in list("Yasai", "Half Yasai"))) TryInspireForm(o)
		if(Opponent(65) && Opponent.client && client) RaiseStudentPoints(Opponent, 25 / 60 * mod) //50 per minute

mob/var/tmp/knockback_immune=0

proc/TimedOverlay(atom/a, time = 100, Icon)
	set waitfor = 0
	if(!Icon || !a) return
	a.overlays += Icon
	sleep(time)
	if(a) a.overlays -= Icon

atom/movable/var
	tmp
		knock_dir
		knock_dist = 0
		knockbacker_bp = 0

mob/var/determination = 100
mob/var/tmp/maxDetermination = 100

mob/proc/GetMaxDetermination()
	var/value = 100
	maxDetermination = Math.Max((value * (1 - (injuries && islist(injuries) ? injuries.len : 0) * 0.05)), 10)
	return maxDetermination

mob/proc/IncreaseDetermination(n)
	if(!isnum(n)) return
	var/pct = determination / maxDetermination
	GetMaxDetermination()
	determination = maxDetermination * pct
	determination = Math.Clamp(determination + n, 0, maxDetermination)

mob/proc/RecoverDetermination()
	IncreaseDetermination(GetMaxDetermination() / (Time.FromHours(1 / Mechanics.GetSettingValue("Determination Recovery Multiplier")) / 5))

mob/proc/KnockbackNoWait(mob/A,Distance=10,dirt_trail=1,override_dir,bypass_immunity,from_lunge) //A is the Attacker who knockbacked src
	set waitfor=0
	Knockback(A, Distance, dirt_trail, override_dir, bypass_immunity, from_lunge)

mob/proc/Knockback(mob/A,Distance=10,dirt_trail=1,override_dir,bypass_immunity,from_lunge) //A is the Attacker who knockbacked src

	if(input_disabled) return	//prevent a player who is charging an attack from being knocked back
	if(!z) return //prevent bug knocking them out of the body
	if(Safezone||KB||knockback_immune) return

	Distance *= Mechanics.GetSettingValue("Knockback Distance Multiplier")

	Distance = Math.Floor(Distance)
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

	if(src.HasTrait("Super Slam") && prob(50)) Distance *= 4

	var/original_distance=Distance

	knock_dir = Dir

	if(ismob(A)) knockbacker_bp = A.BP

	while(src && A && KB && knock_dist > 0)
		knock_dist--
		if((locate(/obj/Edges) in loc)||(locate(/obj/Edges) in Get_step(src,knock_dir)))
			KB = 0
			break
		else
			var/turf/T=Get_step(src,knock_dir)
			if(!T||(IsWater(T)&&!Flying)) KB=0
			KB_Destroy(A,knock_dir)

			var/turf/old_loc=loc
			step(src,knock_dir,32)

			if(dirt_trail) if(original_distance >= 8 && (knock_dir in list(NORTH,SOUTH,EAST,WEST)))
				var/image/i=image(icon='craterseries.dmi',icon_state="crater",layer=OBJ_LAYER,dir=knock_dir)
				if(knock_dist==original_distance-1||knock_dist==0) i.icon_state="begin"
				if(knock_dist==0) i.dir=turn(knock_dir,180)
				var/turf/t=loc
				if(t && isturf(t)) TimedOverlay(t, 600, i)

			if(loc == old_loc && !istype(last_bumped_obj, /obj/Big_Rock))
				KB=0
				dir=get_dir(src,A)
				break
			else if(knock_dist)
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
		src.AlterInputDisabled(-1)

var/kb_immunity_time=12
mob/var/tmp/last_knockbacked=0

mob/proc/KB_Destroy(mob/A,Dir) //A is the Attacker
	var/turf/T = Get_step(src,Dir)
	var/powerTier = (A.effectiveBPTier + src.effectiveBPTier) / 2
	var/averageDefense = (src.GetStatMod("Dur") + src.GetStatMod("Res")) / 2
	var/statBonus = ((A.GetStatMod("Str") + A.GetStatMod("For")) / 2) + averageDefense
	if(T && (T.defenseTier * Mechanics.GetSettingValue("Turf Health Multiplier") < powerTier + statBonus) && A.Is_wall_breaker() && !IsWater(T))
		if(T.Health != 1.#INF)
			T.Health = 0
			if(T.density)
				Dust(T, end_size = 1, time = 10)
				T.Destroy()
	for(var/obj/O in Get_step(src,Dir)) if(O.z && !istype(O,/obj/Dust))
		if(isnum(O.Health) && O.Health < A.WallBreakPower())
			if(O.Health != 1.#INF)
				Dust(O, end_size = 1, time = 10)
				del(O)
mob/var
	KO
	Frozen

mob/var
	tmp/last_attacked_time=0 //the last time someone attacked you. if the last time you were attacked was
	//more than 2 minutes ago you become calm
	tmp
		last_attacked_by_player = 0
		mob/last_attacker

mob/proc/SetLastAttackedTime(mob/a) //a = attacker
	last_attacker = a
	last_attacked_time = world.time
	if(a && ismob(a) && a.client && a != src) last_attacked_by_player = world.time

mob/var/tmp/list/recent_ko_reasons=new

mob/var/tmp
	last_knocked_out_by_mob
	koCount = 0 //how many times you were ko'd this session

mob/Admin5/verb/Toggle_Immunity()
	set category = "Admin"
	KO_IMMUNITY_ENABLED = !KO_IMMUNITY_ENABLED
	usr << "You are [KO_IMMUNITY_ENABLED ? "now" : "no longer"] immune to being KOd."

mob/proc/ResetMobState(exit_trans = 0)
	Action=null
	trainState = null
	Auto_Attack=0
	UltraInstinctRevert()
	God_FistStop()
	Destroy_Splitforms()
	Great_Ape_revert()
	Land()
	Health=100
	Ki=max_ki
	BP=get_bp()
	anger = 100
	KB=0
	Poisoned=0
	radiation_poisoned=0
	radiation_level=0
	if(BPpcnt>100)
		BPpcnt=100
		Aura_Overlays(remove_only=1)
	if(exit_trans)
		for(var/t in UnlockedTransformations)
			var/transformation/T = UnlockedTransformations[t]
			if(!T) continue
			T.ExitForm(src)

mob/proc/KO(mob/Z,allow_anger=1)
	set waitfor=0
	if(IsCodedAdmin() && KO_IMMUNITY_ENABLED) return

	if(client || empty_player)

		if(KO || Safezone || isAFK) return

		if(spam_killed)
			Health=100
			Ki=max_ki
			return
		var/anger_wait = Time.FromMinutes(5)

		if(Z)
			if(Z != src && can_anger() && allow_anger)
				var/can_anger
				if(Z && ismob(Z) && Z.client && !(Z.ckey in anger_reasons))
					can_anger = 1

				CheckTriggerUltraInstinct()
				if(ultra_instinct) return

				if(world.time > last_anger + anger_wait || can_anger)
					var/ko_reason = Z
					if(!Z) ko_reason = "unknown reason"
					if(ismob(Z))
						ko_reason = Z.ckey
						if(!Z.ckey) ko_reason = "npc"
					Enrage(reason = ko_reason)

					recent_ko_reasons.Insert(1, ko_reason)
					recent_ko_reasons.len = 3

					Zenkai()

					return

		Zenkai()
		KO=1
		if(HasTrait("Tenacious Teamwork") && PartySize() > 1) MiniAngerParty()
		Stop_Shadow_Sparring()
		if(ismob(Z)) last_knocked_out_by_mob = Z
		if(!IsTournamentFighter()&&client) Drop_dragonballs()
		ResetMobState()
		icon_state="KO"

		if(ismob(Z))
			for(var/mob/m in player_view(center=src))
				var/t="[src] is knocked out by [Z] ([Z.displaykey])"
				m.SendMsg(t, CHAT_IC)
				m.ChatLog(t)
		else 
			for(var/mob/m in player_view(center=src))
				m.SendMsg("[src] is knocked out by [Z]!", CHAT_IC)

		if(grabbedObject)
			for(var/mob/m in player_view(center=src))
				m.SendMsg("[src] is forced to release [grabbedObject]!", CHAT_IC)
			ReleaseGrab()

		var/KO_Timer = 800 / Clamp((regen**0.4),0.5,2)
		if(z==10) KO_Timer/=6
		koCount++
		var/thisKOcount = koCount
		spawn(KO_Timer * Mechanics.GetSettingValue("KO Timer Multiplier"))
			if(koCount == thisKOcount)
				RegainConsciousness()
		if(Poisoned && prob(100 - determination)) Death("???")

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
	if(!istype(src,/mob/Enemy) && Poisoned && prob(100 - determination)) Death("???")
	for(var/mob/M in player_view(center=src))
		M.SendMsg("[src] regains consciousness.", CHAT_IC)

	if(istype(src,/mob/Enemy))
		Health = 100
		Ki = max_ki

	if(client)
		sleep(20)
		if(prob(anger_chance(0.4)) && !can_anger())
			src.SendMsg("<font color=red>Being knocked out so much angers you...", CHAT_IC)
			Enrage(reason="being ko'd so much")

mob/proc/Angry()
	return anger > 100

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

		var/list/drop_anyway_on_death = list(/obj/items/Dragon_Ball)

		//for(var/obj/Stun_Chip/SC in src) del(SC)
		for(var/obj/A in contents) if(A.Stealable && A.drop_on_death)
			if(Mechanics.GetSettingValue("Item Drop on Death") || (A.type in drop_anyway_on_death) || istype(src,/mob/Enemy))
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

mob/var/last_kill_time = 0 //realtime when you last killed someone

mob/proc/CanDeathRegen(n = 0)
	return Regenerate && n > BP * Res * Regenerate ** 0.5 * 150

mob/proc/RegenerateFromDeath()
	FullHeal()
	Regenerating=1

	if(Android && !drone_module && scrap_repair())
		Spread_Scraps(src)
	else
		LeaveBody()

	radiation_poisoned=0
	radiation_level=0

	death_regen()

mob/proc/RebuildFromDeath()
	if(!CanRebuild()) return
	var/list/cyber_coms = new
	var/list/cyber_coms_on_z = new
	var/list/cyber_coms_on_area = new
	var/obj/Module/Rebuild/R = locate() in active_modules

	for(var/obj/Cybernetics_Computer/cc in cybernetics_computers) if(cc.Password == R.Password && cc.z)
		cyber_coms += cc
		if(cc.get_area() == get_area())
			cyber_coms_on_area += cc
			if(cc.z == z) cyber_coms_on_z += cc

	var/obj/Cybernetics_Computer/cc

	if(cyber_coms_on_z.len) cc = pick(cyber_coms_on_z)
	else if(cyber_coms_on_area.len) cc = pick(cyber_coms_on_area)
	else if(cyber_coms.len) cc = pick(cyber_coms)

	if(cc)
		FullHeal()
		src.SendMsg("The [cc] has rebuilt you here", CHAT_IC)
		SafeTeleport(cc.loc, allowSameTick = 1)

mob/var/tmp/last_attempted_murder = 0
mob/proc/TryDie(atom/source, dmg = 0, can_regenerate = 1)
	if(Safezone || Prisoner()) return
	if(last_attempted_murder + Time.FromSeconds(30) > world.time) return
	last_attempted_murder = world.time

	if(CanDeathRegen(dmg))
		RegenerateFromDeath()
	else
		Death(source, InFinalRealm())

mob/proc/Death(atom/source, keep_immortality = 0)
	set waitfor = FALSE
	if(!Dead)
		ObserveDeathSpot()
		
		Auto_Attack = 0
		ResetMobState(1)
		UltraInstinctRevert()
		Destroy_Soul_Contracts(soul_percent = 100)
		hell_agreements = new/list

		if(Ship) SafeTeleport(Ship.loc, allowSameTick = 1)

		if(grabbedObject)
			for(var/mob/M in player_view(center=src))
				M.SendMsg("[src.name] is forced to release [grabbedObject.name]!", CHAT_IC)
			ReleaseGrab()

		if(grabber) grabber.ReleaseGrab()

		cyber_bp=0
		if(Race != "Android")
			if(!Is_Cybernetic() && Class == "Cyborg")
				Class = originalClass
			else if(Is_Cybernetic() && Class != "Cyborg")
				originalClass = Class
				Class = "Cyborg"

		if(ismob(source))
			Opponent=source
			lastSetOpponent = world.time

		death_time = world.realtime
		Death_Year = GetGlobalYear()
		Dead=1

		Tell_counterpart_i_died()
		Vampire_Infection=0
		Undo_all_t_injections()

		if(Immortal && !keep_immortality)
			Toggle_immortality()
			src.SendMsg("<font color=yellow>Death has caused you to lose immortality", CHAT_IC)

		if(Limits.GetSettingValue("Death Cures Vampirism") && !db_vampire_incurable)
			Vampire_Revert()

		for(var/mob/m in player_view(center=src))
			var/t="[src] was just killed by [source]!"
			m<<t
			m.ChatLog(t)

		if(ismob(source)&&Age>=5)
			for(var/mob/A in player_view(15,src))
				if(A != src && A != source && A.client && !A.KO && (Mob_ID in A.SI_List))
					A.Enrage(2,reason="death anger")
					if(prob(5)) break

		if(!client && drone_module)
			for(var/obj/rt in robotics_tools)
				if(rt.Password==drone_module.Password&&ismob(rt.loc))
					var/mob/drone_master=rt.loc
					drone_master.SendMsg("<font color=red>[src] was just destroyed by [source] at location [x],[y] in [get_area()].",\
									CHAT_IC)
			SafeTeleport(null, allowSameTick = 1)
			del(src)
			return
		
		LeaveBody()
		if(!drone_module||client)
			Drop_Stealables()
		if(source == "God-Fist")
			Body_Parts()
		if(prob(2))
			BloodEffectsWaitForZero()

		if(ismob(source) && source:client)
			source:last_kill_time = world.realtime

		AddHalo()
		RegainConsciousness()
		Zenkai(2)
		GoToDeathSpawn()
		FullHeal()

	else
		if(spam_killed) return

		if(Mechanics.GetSettingValue("Death Auto-Reincarnates"))
			src.SendMsg("<font color=yellow><font size=3>You were killed while dead. Meaning you have been \
			automatically reincarnated.", CHAT_IC)
			Reincarnate()

mob/new_troll/Death(atom/source)
	..()

	if(source == "admin")
		del(src)
	else
		TrollRespawn()

mob/Enemy/Death(atom/source)
	Drop_Stealables()
	del(src)

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

turf/Destroy()
	if(Health<=0 && !IsWater(src))
		var/build_proxy/B = turfPalette["{/build_proxy/turf}/turf/ground:(GroundSandDark)"]
		B?.Print(x, y, z)
		if(prob(0.8))
			var/obj/Turfs/Rock1/R = new(src)
			R.layer = layer + 0.1
			R.Nukable=0
			R.pixel_x=rand(-8,8)
			R.pixel_y=rand(-8,8)
			R.density=0
			R.Savable=0
			Timed_Delete(R,rand(600,900))

obj/corpse

proc/IsCorpse(C)
	return istype(C, /mob/Body) || istype(C, /obj/corpse)

mob/proc/LeaveBody()

client/North()
	if(mob.Allow_Move(NORTH)) return . = ..()
client/South()
	if(mob.Allow_Move(SOUTH)) return . = ..()
client/East()
	if(mob.Allow_Move(EAST)) return . = ..()
client/West()
	if(mob.Allow_Move(WEST)) return . = ..()
client/Northwest()
	if(mob.Allow_Move(NORTHWEST)) return . = ..()
client/Northeast()
	if(mob.Allow_Move(NORTHEAST)) return . = ..()
client/Southwest()
	if(mob.Allow_Move(SOUTHWEST)) return . = ..()
client/Southeast()
	if(mob.Allow_Move(SOUTHEAST)) return . = ..()

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

		if(Class == "Legendary") beam_stun_immune = world.time + 11 //fully immune to beam lock

		var/struggle_every = 3 //how many 1/10th seconds you can struggle
		if(world.time - last_struggle_against_beam_stun < struggle_every) return
		if(!last_beamed_by) return

		var/mob/m = last_beamed_by
		last_struggle_against_beam_stun = world.time
		//var/struggle_mod = (BP / m.BP)**0.33 * (Res / m.Res)**0.33 * (Spd / m.Spd)**0.33
		var/struggle_mod = 1 + (GetStatMod("Res") + GetStatMod("Ref")) * GetTierBonus(0.5) - (m.GetStatMod("For") + GetStatMod("Spd")) * GetTierBonus(0.5)
		struggle_mod = Math.Max(struggle_mod, 0.2)
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
	if(using_scattershot)
		dir = D
		return
	if(!CanInputMove()) return
	if(strangling) return
	if(cant_move_due_to_hakai) return

	if(world.time - last_bank_bump < 10) return

	if(world.time <= last_tap_warp + TapWarpCantMoveTime()) return

	if(client?.buildMode && client?.buildCam)
		if(!client?.buildCam.moving)
			client?.buildCam.moving = 1
			client?.buildCam.MoveReset()
			client?.buildCam.step_size = 32
			step(client?.buildCam, D)
		return

	//prevent allow_move from being called a ridiculous number of times in a short period by just returning the most recent result again
	//unless theyre in a pod cuz it slows pods down
	if(!Ship) if(world.time - last_allow_move_result_time < 3)
		return last_allow_move_result

	last_allow_move_result_time=world.time
	last_allow_move_result=0

	if(stat_version<cur_stat_ver) return

	//to make combo teleporting more reliable so you/others dont instantly/accidently move and break it
	if(world.time-last_combo_teleport<=6)
		dir=D
		return //remember its in TENTHS of seconds, so 5 = 0.5 seconds

	if(lunge_attacking) return

	if(IsGreatApe()&&!Great_Ape_control) return
	if(BeamStruggling() || shockwaving||Giving_Power) return
	if(!Shadow_Sparring&&!Ship) Cease_training()

	if(dash_attacking)
		if(D==turn(dir,90)) desired_dash_dir=turn(dir,45)
		if(D==turn(dir,-90)) desired_dash_dir=turn(dir,-45)
		return

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

	for(var/obj/Skills/Combat/Ki/A in ki_attacks) if(A.charging||A.streaming||A.Using)
		if(A.streaming) //if its a beam
			if(world.time - last_beam_turn > 12)
				last_beam_turn = world.time
				dir = D
				return
		else dir = D
		return

	for(var/obj/Blast/B in Get_step(src,D))
		if(B.dir!=turn(D,180)) step(B,B.dir)
		else if(B.density) return

	if(power_attacking || Regeneration_Skill)
		dir=D
		return

	if(Shadow_Sparring)
		dir=D
		return

	if(Ship)
		if(Ship.type==/obj/Ships/Spacepod && loc != Ship) SafeTeleport(Ship)
		if(!Ship.Moving&&Ship.Ki>0&&!KO)
			Ship.Move_Randomly=0
			Ship.Moving=1
			Ship.MoveReset()
			step(Ship,D)
			if(Ship) Ship.Fuel()
		return

	if(!Can_Move()) return
	if(icon_state=="KB"||KB||!move) return

	if(is_kiting && Opponent(150))
		Check_if_kiting()
		if(is_kiting)
			if(D in list(get_dir(src,Opponent),turn(get_dir(src,Opponent),45),turn(get_dir(src,Opponent),-45)))
				Reset_kiting()

	last_allow_move_result=1

	if(D in list(NORTH,SOUTH))
		if(last_directional_key_pressed in list(EAST,WEST)) last_cardinal_change = world.time
	else if(D in list(EAST,WEST))
		if(last_directional_key_pressed in list(NORTH,SOUTH)) last_cardinal_change = world.time
	last_directional_key_pressed = D

	return 1
mob
	proc/Grab_Struggle(D)
		if(Race=="Majin")
			if(icon!='Death regenerate.dmi')
				var/old_icon=icon
				icon='Death regenerate.dmi'
				spawn(3) icon=old_icon
			for(var/mob/M in player_view(15,src))
				M.SendMsg("<font color=red>[src.name] breaks free of [grabber]!", CHAT_IC)
			grabber.ReleaseGrab()
		else
			var/grab_resist = (GetStatMod("Str") + GetStatMod("Def")) * GetTierBonus(0.8)
			grab_resist -= (grabber.GetStatMod("Str") + grabber.GetStatMod("Off")) * grabber.GetTierBonus(1)
			grab_resist = Math.Clamp(grab_resist, 0.1, 10)
			grab_resist *= 11 * grab_struggle_mod

			if(grabbed_from_behind && Tail)
				var/tail_mult = 0 + ((tail_level - 1) * 0.5)
				tail_mult = Clamp(tail_mult, 0.01, 1)
				grab_resist *= tail_mult

			grabber.grab_power-=grab_resist / (HasTrait("Mind the Heel") ? 1.5 : 1)

			grabber.IncreaseKi(-((grabber.max_ki / 300 * grab_resist) * (grabber.max_ki/3000)**0.3 * Clamp(grabber.recov,0.25,1)))
			struggle_timer=1
			spawn(20) struggle_timer=0
			if(grabber.grab_power<=0)
				for(var/mob/M in player_view(15,src))
					M.SendMsg("<font color=red>[src.name] breaks free of [grabber]!", CHAT_IC)
				grabber.ReleaseGrab()
			else
				for(var/mob/M in player_view(15,src))
					M.SendMsg("[src.name] struggles against [grabber]!", CHAT_IC)
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

mob/proc/Blast()
	if(IsGreatApe()) return
	if(attacking) flick("Attack",src)
mob/Body/var
	body_expire_time=0

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
	A.Modless_Gain=Modless_Gain
	A.TextColor=TextColor
	A.brain_transplant_allowed=0
	A.body_expire_time=world.realtime+(100 * 60 * 600) //we have them last this long because they are no longer saved in reboots so they might as well
		//build up just because its cool to see
	A.can_change_icon=0
	A.T_Injections=T_Injections
	A.Frozen=1 //Like being knocked out for NPCs, so it doesnt get knocked out again

	A.feat_bp_multiplier = feat_bp_multiplier

	A.BP=BP
	A.Body=Body
	A.gravity_mastered=gravity_mastered*0.75
	A.base_bp=base_bp*0.75
	A.static_bp=static_bp*0.75
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
			else
				var/dmg = Mechanics.GetSettingValue("Base Melee Damage")
				//add damage based on strength and weapon
				dmg += src.GetStatMod("Str")
				//add ki damage if they have the appropriate trait and are unarmed
				if(!src.GetEquippedWeapon() && src.HasTrait("Empowered Fists"))
					dmg += src.GetStatMod("For")
				//add weapon damage
				dmg += GetWeaponDamage()

				for(var/mob/M in player_view(15,P))
					M.SendMsg("[src.name] hits the [P]<br><font color=red>[P]: [Math.Round(dmg,0.01)] Damage!", CHAT_IC)
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
			IncreaseKi(-peebagDrain)
			lastPeebagHit = world.time
			PunchGraphics()
			if("Hit" in icon_states(Pee.icon))
				if(Pee.icon_state != "Hit")
					Pee.icon_state = "Hit"
					spawn(2) if(Pee) Pee.icon_state = ""
			Attack_Gain(N = bp_mod, skip_leech = 1, partyGains = 0)
			return 1

mob/var/death_time=0
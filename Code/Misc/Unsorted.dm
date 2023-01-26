mob/var
	block_music






obj/proc/MakeImmovableIndestructable()
	Health = 1.#INF
	Dead_Zone_Immune = 1
	Knockable = 0
	//Bolted = 1
	Grabbable = 0
	Cloakable = 0
	can_blueprint = 0




mob/var/player_desc = ""

mob/verb/Set_Player_Description()
	set category = "Other"
	player_desc = input(usr, "Here you write a description of your character for RP purposes and anyone who clicks you will be able to read it") as message










proc/View(r,c)
	return view(r,c)

/*proc/sleep(time=1)
	sleep(time)*/

proc/Missile(t,s,e)
	missile(t,s,e)

/*proc/flick(i,atom/a)
	flick(i,a)*/

proc/Get_step(mob/m,D)
	return get_step(m,D)






mob/Admin5/verb/Alt_Auto_Fight_Test(mob/m in world)
	if(!m.client) return

	sleep(50)

	spawn Power_up()
	spawn m.Power_up()

	while(!KO && !m.KO)

		var/d=get_dir(src,m)
		spawn(2) if(src && !KB) step(src,pick(d,turn(d,45),turn(d,-45)))
		if(!Shielding() && Health<=20 && Ki>=max_ki*0.5) Toggle_ki_shield()
		else if(Shielding() && Ki<max_ki*0.25) Toggle_ki_shield()

		d=get_dir(m,src)
		spawn(2) if(m && !m.KB) step(m,pick(d,turn(d,45),turn(d,-45)))
		if(!m.Shielding() && m.Health<=20 && m.Ki>=max_ki*0.5) m.Toggle_ki_shield()
		else if(m.Shielding() && m.Ki<m.max_ki*0.25) m.Toggle_ki_shield()

		var/list/guys=list(src,m)
		while(guys.len)
			var/mob/attacker=pick(guys)
			guys-=attacker
			attacker.Melee()

		sleep(world.tick_lag)

	if(Shielding()) Toggle_ki_shield()
	if(m.Shielding()) m.Toggle_ki_shield()
	FullHeal()
	m.FullHeal()
	Calm()
	m.Calm()
	last_anger=0
	m.last_anger=0
	anger_reasons=new/list
	m.anger_reasons=new/list
	Stop_Powering_Up()
	m.Stop_Powering_Up()

mob/var/battle_test
mob/var/battle_count=0
mob/proc
	fight_copy_of_self()
		battle_count++
		world<<"battle #[battle_count]"
		battle_test=1
		PrimaryPlayerLoop(Time.FromSeconds(10))
		name="guy #[rand(1,999)]"
		var/mob/m=Duplicate(include_unclonables=1)

		m.Status_Running=0
		m.name="guy #[rand(1,999)]"
		m.battle_test=1
		players-=src
		players+=src
		players+=m
		m.SafeTeleport(loc)
		step_away(m,src)
		m.dir=get_dir(m,src)
		dir=get_dir(src,m)
		m.Random_stat_change()
		m.PrimaryPlayerLoop(Time.FromSeconds(10))
		sleep(30)
		spawn Power_up()
		spawn m.Power_up()
		while(!KO&&!m.KO)

			BP=get_bp()
			var/d=get_dir(src,m)
			spawn(2) if(src&&!KB) step(src,pick(d,turn(d,45),turn(d,-45)))
			if(!Shielding()&&Health<=25&&Ki>=max_ki*0.5) Toggle_ki_shield()
			else if(Shielding()&&Ki<=max_ki*0.25) Toggle_ki_shield()

			m.BP=m.get_bp()
			d=get_dir(m,src)
			spawn(2) if(m&&!m.KB) step(m,pick(d,turn(d,45),turn(d,-45)))
			if(!m.Shielding()&&m.Health<=25&&m.Ki>=m.max_ki*0.5) m.Toggle_ki_shield()
			else if(m.Shielding()&&m.Ki<=m.max_ki*0.25) m.Toggle_ki_shield()

			var/list/guys=list(src,m)
			while(guys.len)
				var/mob/attacker=pick(guys)
				guys-=attacker
				attacker.Melee()

			sleep(1)
		var/mob/winner
		var/mob/loser
		if(!KO)
			winner=src
			loser=m
		else
			winner=m
			loser=src
		if(Shielding()) Toggle_ki_shield()
		if(m.Shielding()) m.Toggle_ki_shield()
		FullHeal()
		m.FullHeal()
		Calm()
		m.Calm()
		last_anger=0
		m.last_anger=0
		Stop_Powering_Up()
		m.Stop_Powering_Up()
		spawn if(loser) del(loser)
		winner.fight_copy_of_self()
mob/proc/Random_stat_change()
	var/n=rand(110,140)/100
	var/list/stat_list=list("ki","str","dur","spd","pow","res","off","def","reg","rec","ang")
	if(regen<=0.5||regen>=6) stat_list-="reg"
	if(recov<=0.5||recov>=6) stat_list-="rec"
	if(max_anger<n*100||max_anger>300) stat_list-="ang"
	if(Eff<=0.6||Eff>=5) stat_list-="ki"
	//lower
	var/l=1-(n-1)
	switch(pick(stat_list))
		if("ki")
			Ki*=l
			max_ki*=l
			Eff*=l
		if("str") Str*=l
		if("dur") End*=l
		if("spd") Spd*=l
		if("pow") Pow*=l
		if("res")
			var/old_res=Res
			Res*=l
			world<<"resistance decreased from [round(old_res)] to [round(Res)]"
		if("off") Off*=l
		if("def") Def*=l
		if("reg") regen*=l
		if("rec") recov*=l
		if("ang") max_anger*=l
	//raise
	switch(pick(stat_list))
		if("ki")
			Ki*=n
			max_ki*=n
			Eff*=n
		if("str") Str*=n
		if("dur") End*=n
		if("spd") Spd*=n
		if("pow") Pow*=n
		if("res")
			var/old_res=Res
			Res*=n
			world<<"resistance increased from [round(old_res)] to [round(Res)]"
		if("off") Off*=n
		if("def") Def*=n
		if("reg") regen*=n
		if("rec") recov*=n
		if("ang") max_anger*=n




mob/Admin5/verb/Set_transform_size(mob/m in world)
	set category="Admin"
	var/n=input("multiple") as num
	m.transform = matrix() * n





//LOOK AT THIS HIDDEN GEM - efficient way to get all viewable projectiles within range of center. but we dont use it anywhere instead other places may use more inefficent ways
proc/blast_view(dist=10,mob/center)
	if(!center) return new/list
	var/area/a=center.get_area()
	if(!a) return new/list
	var/list/l=new
	for(var/obj/Blast/b in a.blast_objs)
		if(b.z&&b.z==center.locz()&&getdist(b,center)<=dist) l+=b
		sleep(0)
	return l

proc/player_range(range=20, mob/center, seePastDenseObjs = 1)
	var/list/l=new/list
	var/area/centerArea = locate(/area) in range(0, center)
	for(var/mob/M in range(range, center))
		var/area/mobArea = locate(/area) in range(0, M)
		if((!mobArea || !centerArea) || (mobArea != centerArea)) continue
		if(!M.client) continue
		if(M.z == center.z)
			l += M
		sleep(0)
	return l

	
	var/area/a=locate(/area) in range(0,center)
	if(!a) return l
	for(var/mob/m in a.player_list)
		if(m.z==center.z&&getdist(m,center)<=range) l+=m
		sleep(0)
	return l

proc/player_view(range = 20, mob/center, seePastDenseObjs = 0)
	var/list/l=new/list
	var/area/centerArea = locate(/area) in range(0, center)
	for(var/mob/M in view(range, center))
		var/area/mobArea = locate(/area) in range(0, M)
		if((!mobArea || !centerArea) || (mobArea != centerArea)) continue
		if(!M || !M.client) continue
		if(!center) break
		if(M.z == center.z)
			l += M
		sleep(0)
	return l

	var/area/a=locate(/area) in range(0,center)
	if(!a) return l
	for(var/mob/m in a.player_list)
		if(m&&m.z==center.z&&getdist(m,center)<=range&&viewable(m,center,5000,seePastDenseObjs)) l+=m
		sleep(0)
	return l

proc/mob_view(range=20,mob/center, seePastDenseObjs = 1)
	var/list/l=new/list
	var/area/centerArea = locate(/area) in range(0, center)
	for(var/mob/M in view(range, center))
		var/area/mobArea = locate(/area) in range(0, M)
		if((!mobArea || !centerArea) || (mobArea != centerArea)) continue
		if(!M.client) continue
		if(M.z == center.z)
			l += M
		sleep(0)
	return l

	
	var/area/a=locate(/area) in range(0,center)
	if(!a) return l
	for(var/mob/m in a.mob_list)
		if(m.z==center.z&&getdist(m,center)<=range&&viewable(m,center,5000,seePastDenseObjs)) l+=m
		sleep(0)
	return l

//this gets all viewable npcs within range of center
proc/npc_view(range=20,mob/center, seePastDenseObjs = 1)
	var/list/l=new/list
	var/area/centerArea = locate(/area) in range(0, center)
	for(var/mob/M in view(range, center))
		var/area/mobArea = locate(/area) in range(0, M)
		if((!mobArea || !centerArea) || (mobArea != centerArea)) continue
		if(M.client) continue
		if(M.z == center.z)
			l += M
		sleep(0)
	return l

	
	
	var/area/a=locate(/area) in range(0,center)
	if(!a) return l
	for(var/mob/m in a.npc_list)
		if(m.z==center.z&&getdist(m,center)<=range&&viewable(m,center, 5000, seePastDenseObjs)) l+=m
		sleep(0)
	return l

proc/viewable(mob/a, mob/b, max_dist = 5000, seePastDenseObjs = 1)
	if(seePastDenseObjs) return b in range(a, max_dist)
	else return b in view(a, max_dist)
	return (a && a.z) && (b && b.z) && (a.z == b.z) && (getdist(a,b) <= max_dist) && (a != b) && (seePastDenseObjs ? (b in orange(a, max_dist)) : (b in oview(a, max_dist)))
	if(!a.z || !b.z || a.z != b.z) return
	a = a.base_loc()
	b = b.base_loc()
	if(a == b) return 1
	if(getdist(a,b) > max_dist) return
	var/turf/t = a

	while(t && t != b)
		max_dist--
		if(!max_dist) return 1
		t = get_step(t,get_dir(t,b))
		if(!t || t.opacity) return //was break
		else for(var/obj/o in t)
			if(o.opacity) return //was break
			if(!seePastDenseObjs && o.density) return
		sleep(0)

	if(!t || t != b) return
	return 1

obj/Toxic_Waste_Barrel
	icon='toxic waste barrel.dmi'
	Savable=1
	takes_gradual_damage=1
	Cost=1000000
	density=1
	desc="There is no use for this stuff, and if it is destroyed the radioactive cloud will poison the \
	nearby area for many hours, causing people to become radiation poisoned"
	can_scrap=0
	New()
		if(Health<Avg_BP*4) Health=Avg_BP*4
		if(z&&loc==initial(loc)) Savable=0
	Del()
		Spread_toxic_clouds()
		. = ..()

var/list/toxic_clouds=new
var/icon/toxic_cloud_icon

obj/Toxic_Cloud
	mouse_opacity = 0
	Dead_Zone_Immune=1
	Grabbable=0
	Health=1.#INF
	can_blueprint=0
	Cloakable=0
	Knockable=0
	Savable=1
	layer=6
	var/creation_time
	alpha=150
	var/toxicity_range=10

	New()
		. = ..()
		spawn if(src)
			for(var/obj/Toxic_Cloud/tc in toxic_clouds) if(tc.z==z&&getdist(tc,src)<=3&&tc!=src)
				del(src)
				return
			for(var/obj/Revival_Altar/ra in revival_altars) if(ra.z==z&&getdist(ra,src)<=16)
				del(src)
				return
			for(var/obj/Spawn/s in RaceSpawns) if(s.z==z&&getdist(s,src)<=16)
				del(src)
				return
			toxic_clouds+=src
			if(!creation_time) creation_time=world.realtime
			var/sleep_time=creation_time + toxic_waste_hours*60*60*10 - world.realtime
			if(sleep_time<0) sleep_time=0
			spawn(sleep_time) if(src) del(src)
			if(!toxic_cloud_icon)
				var/icon/i='fog cloud.dmi'-rgb(120,0,255)
				var/obj/o=new
				o.icon=i
				o.Enlarge_Icon(GetWidth(o.icon)*2,GetHeight(o.icon)*2)
				toxic_cloud_icon=o.icon
			icon=toxic_cloud_icon
			icon_state=pick("1","2","3","4")
			dir=pick(NORTH,SOUTH,EAST,WEST)
			CenterIcon(src)
	Del()
		toxic_clouds-=src
		. = ..()

var/toxic_waste_hours = 1

atom/movable/proc/Spread_toxic_clouds()
	new/obj/Toxic_Cloud(loc)

mob/var/tmp/in_radiation
mob/var/radiation_poisoned
mob/var/tmp/geiger_sounding
mob/var/radiation_level=0

mob/proc/Geiger_sound_loop()
	set waitfor=0
	if(geiger_sounding) return
	geiger_sounding=1
	while(in_radiation)
		src<<sound('geiger.ogg',volume=60)
		sleep(173)
	geiger_sounding=0

mob/proc/RadiationTick()
	in_radiation=0
	if(Dead)
		radiation_poisoned=0
		radiation_level=0
	if(!Dead)
		if(!IsTournamentFighter())
			for(var/obj/Toxic_Cloud/tc in toxic_clouds)
				if(z==tc.z&&getdist(src,tc)<=tc.toxicity_range&&viewable(src,tc))
					in_radiation=1
					if(!Dead&&!(Race in list("Majin","Android","Bio-Android","Demon")))
						radiation_level++
					break
	if(in_radiation && !geiger_sounding) Geiger_sound_loop()
	if(radiation_level >= 100)
		if(!radiation_poisoned)
			radiation_poisoned=1
			alert(src,"You now have radiation poisoning")
	if(radiation_poisoned)
		TakeDamage(-0.25 * (radiation_level / 100), "radiation poisoning", 1)

mob/var
	stun_level = 0
	stun_time = 0
	tmp
		stun_loop
		stun_immunity = 0

mob/proc
	ApplyStun(time = 8, no_immunity, stun_power = 1) //10 = 1 second
		stun_power *= arbitraryStunPower
		time *= Mechanics.GetSettingValue("Stun Timer Multiplier") * arbitraryStunTime
		time = ToOne(time / stun_resistance_mod)
		if(time > 240) time = 240 //prevent ridiculously long stuns that could perma stun someone
		if(stun_level < stun_power) stun_level = stun_power
		if(stun_time < time) stun_time = time
		StunDecay()

	Stunned()
		if(stun_level > 0 || Frozen) return 1

	StunDecay()
		set waitfor=0
		if(stun_loop) return
		stun_loop = 1
		overlays -= 'stun overlay.dmi'
		overlays += 'stun overlay.dmi'
		while(stun_time > 0)
			stun_time -= world.tick_lag
			sleep(world.tick_lag)
			stun_immunity = world.time + 13
		overlays -= 'stun overlay.dmi'
		stun_level = 0
		stun_loop = 0
	
	StunTickDown()
		overlays -= 'stun overlay.dmi'
		if(stun_time)
			overlays += 'stun overlay.dmi'
			stun_time -= 5
			stun_time = Math.Max(stun_time, 0)
			stun_immunity = world.time + 13
			if(!stun_time) stun_level = 0

var/list/relog_list=new
mob/proc/Add_relog_log()
	if(!key) return
	var/list/l=list("logouts"=0,"expire time"=0)
	if(key in relog_list) l=relog_list[key]
	if(world.time>=l["expire time"]) l["logouts"]=0 //reset
	l["logouts"]++
	l["expire time"]=world.time+(3*60*10)
	relog_list[key]=l

mob/proc/Spam_relogger()
	if(IsAdmin()||IsCodedAdmin()) return
	if(key&&(key in relog_list))
		var/list/l=relog_list[key]
		if(world.time>=l["expire time"]) return
		if(l["logouts"]>=4)
			return l["expire time"]

mob/Admin5/verb/Test_mob_list(area/a in world)
	var/mob_count=0
	for(var/v in a.mob_list)
		src<<v
		if(ismob(v)) mob_count++
	src<<"mobs in list: [mob_count]"
	src<<"length of list: [a.mob_list.len]"

mob/var/tmp/list/item_list=new

obj/items/New()
	. = ..()
	spawn if(ismob(loc))
		var/mob/M=loc
		if(!(src in M.item_list))
			M.item_list+=src
			M.Restore_hotbar_from_IDs()

obj/items/Move()
	if(ismob(loc))
		var/mob/m=loc
		m.item_list-=src
		m.hotbar-=src
		m.item_list=remove_nulls(m.item_list)
		m.Restore_hotbar_from_IDs()
	. = ..()
	if(ismob(loc))
		var/mob/m=loc
		m.item_list+=src
		m.Restore_hotbar_from_IDs()
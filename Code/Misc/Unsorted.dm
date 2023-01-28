mob/var
	block_music
	tmp
		last_music_stream_time = 0

mob/verb/Stream_Music_to_Everyone_Nearby(url as text)
	set category = "Other"
	if(world.time - last_music_stream_time < 100)
		src << "You can only do this every 10 seconds"
		return
	if(!findtext(url, "vocaroo"))
		src << "You must paste a Vocaroo link. Go to Vocaroo.com and upload music and get the link"
		return
	last_music_stream_time = world.time
	var/list/ips = new
	for(var/mob/m in player_view(22,src))
		if(m.client && !(m.client.address in ips))
			if(m.block_music)
				m << "<font color=cyan>[src] tried to play music, but you blocked it: [url]"
			else
				m << "<font color=cyan>[src] played music for you: [url]"
				ips += m.client.address
				m << browse("<script>window.location='[url]';</script>", "window=InvisBrowser.invisbrowser")






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

	Resetinactivity()
	m.Resetinactivity()

	sleep(50)

	spawn Power_up()
	spawn m.Power_up()

	while(!KO && !m.KO)
		Resetinactivity()
		m.Resetinactivity()

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



mob/Admin5/verb/Battle_test()
	var/mob/m=Duplicate(include_unclonables=1)
	m.SafeTeleport(loc)
	m.Player_Loops()
	sleep(30)
	m.fight_copy_of_self()

mob/var/battle_test
mob/var/battle_count=0
mob/proc
	fight_copy_of_self()
		battle_count++
		world<<"battle #[battle_count]"
		battle_test=1
		Player_Loops()
		name="guy #[rand(1,999)]"
		var/mob/m=Duplicate(include_unclonables=1)
		Has_DNA=0
		m.Has_DNA=0

		if(prob(50)) for(var/obj/items/Sword/s in m)
			if(!s.suffix)
				s.Damage*=rand(80,120)/100
				s.Damage=Clamp(s.Damage,0.5,2)
				s.Style=pick("Energy","Physical")
			m.Apply_Sword(s)

		if(prob(50)) for(var/obj/items/Armor/a in m)
			if(!a.suffix)
				a.Armor*=rand(80,120)/100
				a.Armor=Clamp(a.Armor,1,2)
			m.Apply_Armor(a)

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
		m.Player_Loops()
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





mob/proc/OP_build()

	return

	var/n="Magic Ultimate Armor"
	if(armor_obj)
		if(armor_obj.Armor==1.01)
			armor_obj.name=n
			armor_obj.can_blueprint=0
			return 1
		else if(armor_obj.name==n) name="Armor"

//LOOK AT THIS HIDDEN GEM - efficient way to get all viewable projectiles within range of center. but we dont use it anywhere instead other places may use more inefficent ways
proc/blast_view(dist=10,mob/center)
	if(!center) return new/list
	var/area/a=center.get_area()
	if(!a) return new/list
	var/list/l=new
	for(var/obj/Blast/b in a.blast_objs) if(b.z&&b.z==center.locz()&&getdist(b,center)<=dist) l+=b
	return l

proc/player_range(range=20,mob/center)
	var/list/l=new
	var/area/a=locate(/area) in range(0,center)
	if(!a) return l
	for(var/mob/m in a.player_list) if(m.z==center.z&&getdist(m,center)<=range) l+=m
	return l

proc/player_view(range = 20, mob/center, seePastDenseObjs = 1)
	var/list/l=new
	var/area/a=locate(/area) in range(0,center)
	if(!a) return l
	for(var/mob/m in a.player_list) if(m&&m.z==center.z&&getdist(m,center)<=range&&viewable(m,center,5000,seePastDenseObjs)) l+=m
	return l

proc/mob_view(range=20,mob/center, seePastDenseObjs = 1)
	var/list/l=new
	var/area/a=locate(/area) in range(0,center)
	if(!a) return l
	for(var/mob/m in a.mob_list) if(m.z==center.z&&getdist(m,center)<=range&&viewable(m,center,5000,seePastDenseObjs)) l+=m
	return l

//this gets all viewable npcs within range of center
proc/npc_view(range=20,mob/center, seePastDenseObjs = 1)
	var/list/l=new
	var/area/a=locate(/area) in range(0,center)
	if(!a) return l
	for(var/mob/m in a.npc_list) if(m.z==center.z&&getdist(m,center)<=range&&viewable(m,center, 5000, seePastDenseObjs)) l+=m
	return l

proc/viewable(mob/a, mob/b, max_dist = 5000, seePastDenseObjs = 1)
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

	if(!t || t != b) return
	return 1




var/toxic_waste_on=1

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
		spawn if(src)
			for(var/obj/Toxic_Cloud/tc in toxic_clouds) if(tc.z==z&&getdist(tc,src)<=3&&tc!=src)
				del(src)
				return
			for(var/obj/Revival_Altar/ra in revival_altars) if(ra.z==z&&getdist(ra,src)<=16)
				del(src)
				return
			for(var/obj/Spawn/s in Spawn_List) if(s.z==z&&getdist(s,src)<=16)
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

mob/proc/Radiation_loop()
	set waitfor=0
	while(src)
		in_radiation=0
		if(Dead)
			radiation_poisoned=0
			radiation_level=0
		if(!Dead)
			if(!Tournament||z!=7||!(src in All_Entrants))
				for(var/obj/Toxic_Cloud/tc in toxic_clouds)
					if(z==tc.z&&getdist(src,tc)<=tc.toxicity_range&&viewable(src,tc))
						in_radiation=1
						if(!Dead&&!(Race in list("Majin","Android","Bio-Android","Demon")))
							radiation_level+=8
						break
		if(in_radiation && !geiger_sounding) Geiger_sound_loop()
		if(radiation_level >= 100)
			if(!radiation_poisoned)
				radiation_poisoned=1
				spawn while(radiation_poisoned)
					Health -= 0.5 * (radiation_level / 100)
					if(Health<=0)
						radiation_poisoned=0
						radiation_level=0
						if(prob(33)) Zombie_Virus=1
						Death("radiation poisoning")
					sleep(10)
				spawn alert(src,"You now have radiation poisoning")
		sleep(50)




mob/var
	stun_level = 0
	stun_time = 0
	tmp
		stun_loop
		stun_immunity = 0

mob/proc
	ApplyStun(time = 8, no_immunity, stun_power = 1) //10 = 1 second
		if(key == "EXGenesis") return
		if(!stun_stops_movement) no_immunity = 1 //because stun is just a slowdown it dont need an immunity time in this case
		if(knockback_immune && !no_immunity) return
		if(world.time < stun_immunity && !no_immunity) return
		stun_power *= arbitraryStunPower
		time *= global_stun_mod * arbitraryStunTime
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




mob/var/tmp/spouse_key
obj/Priest
	desc="Click this priest to get married"
	Cost=0
	density=1
	icon='Android.dmi'
	Health=50000
	takes_gradual_damage=1
	Makeable=1
	New()
		overlays-='Clothes Tuxedo.dmi'
		overlays+='Clothes Tuxedo.dmi'
		. = ..()
		//spawn(5) if(src) del(src)
	Click()
		if(getdist(usr,src)>1) return

		if(usr.spouse_key&&Get_by_key(usr.spouse_key))
			usr.Divorce()
			return

		var/list/mobs=list("Cancel")
		for(var/mob/m in range(1,src)) if(m!=usr&&m.client) mobs+=m
		if(mobs.len<=2) mobs-="Cancel"
		var/mob/m=input(usr,"Which person do you want to marry?") in mobs
		if(!m)
			usr<<"Someone else must be with you if you want to get married"
			return
		if(m=="Cancel") return
		if(getdist(usr,src)>1)
			usr<<"You moved. Try again"
			return
		if(getdist(m,src)>1)
			usr<<"They moved. Try again"
			return
		m.spouse_key=usr.key
		player_view(center=src)<<"<font color=red>[usr] and [m] are now married"
		spawn if(m) alert(m,"[usr] has married you. If you wish to file for divorce click the priest npc")
		if(usr.gender==m.gender) usr.Kilt_by_redneck()
	verb/Bolt()
		set src in oview(1)
		usr.Bolt(src)
	verb/Upgrade()
		set name="Repair/Upgrade health"
		set src in view(1)
		if(usr in view(1,src))
			var/max_health=usr.Knowledge*usr.Intelligence()*15
			if(Health<max_health)
				player_view(center=usr)<<"[usr] repairs/upgrades the [src]'s health to [Commas(max_health)] BP"
				Health=max_health
			else usr<<"The [src] is beyond your upgrading abilities"
mob/proc/Divorce()
	var/mob/m=Get_by_key(spouse_key)
	if(!m)
		spouse_key=null
		return
	spouse_key=null
	alert(src,"Apparently this does nothing")
mob/proc/Kilt_by_redneck()
	move=0
	var/turf/t=base_loc()
	for(var/v in 1 to 30)
		if(Get_step(t,WEST)) t=Get_step(t,WEST)
		else break
	var/mob/m=new(t)
	m.name="REDNECK"
	m.icon='Farmer.dmi'
	m.TextColor="green"
	m.attackable=0
	m.BP=1.#INF
	Timed_Delete(m,10*600)
	for(var/v in 1 to 100)
		if(!m) return
		m.SafeTeleport(Get_step(m,get_dir(m,src)))
		if(getdist(m,src)<=5&&(src in view(5,m))) break
		sleep(2)
	if(!m) return
	m.Say("SON I AM DISAPPOINT")
	sleep(35)
	m.Say("GAWD hates QUEEROSEXUALS boy")
	sleep(35)
	m.Say("LARD JEEZUS PLEASE RAIN THE HELLFIRE DOWN UPON THESE HEATHEN SCUM")
	sleep(35)
	for(var/mob/a in player_view(20,m)) a.ScreenShake(300)
	sleep(35)
	m.Say("CLEANSE THEIR SOULS OF THE SIN KNOWN AS HOMOSEXUALITY AND LET THEM BURN IN HELL FOR ALL ETERNITY")
	sleep(35)
	spawn while(m)
		sleep(55)
		if(m) m.Say("ALAHEAHLALEHAHELUAEHALEEIOEALELIAEIOAEHLALEAHELALHAHLEHAHLAHLEALLEHALHE")
		if(prob(15)) break
	sleep(60)
	t=base_loc()
	for(var/v in 1 to 4)
		if(Get_step(t,NORTH)) t=Get_step(t,NORTH)
		else break
	var/mob/jesus=new(t)
	jesus.icon='Jesus.dmi'
	jesus.name="JEEZUS"
	jesus.BP=1.#INF
	jesus.attackable=0
	Timed_Delete(jesus,10*600)
	player_view(15,src)<<"<font color=yellow>A WILD JEEZUS APPEARS"
	sleep(40)
	jesus.Emote("rains hellfires down upon the heathens!!")
	sleep(30)
	var/list/turfs=new
	for(var/turf/t2 in view(7,src)) turfs+=t2
	for(var/v in 1 to 90)
		t=pick(turfs)
		Explosion_Graphics(t,5)
		for(var/mob/m2 in view(4,t)) if(m2.client)
			m2.TakeDamage(4)
			if(m2.Health<=0) m2.Death("JEEZUS")
		sleep(1)
	sleep(40)
	jesus.Emote("and the redneck return to heaven")
	sleep(35)
	Explosion_Graphics(jesus.loc,5)
	del(jesus)
	Explosion_Graphics(m.loc,5)
	del(m)
	move=1











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
	if(IsAdmin()||IsTens()) return
	if(key&&(key in relog_list))
		var/list/l=relog_list[key]
		if(world.time>=l["expire time"]) return
		if(l["logouts"]>=4)
			return l["expire time"]


//THIS IS DISABLED FOR NO BECAUSE IT BUGS THE HOTBAR SYSTEM BY REMOVING NULLS THEREFORE MESSING UP THE KEY ORDER
proc/Remove_all_nulls()
	set waitfor=0
	while(1)

		return

		sleep(8*600)
		for(var/list/l) if(l)
			for(var/v in l) if(v==null) l-=v
		//Tens("All nulls removed")

mob/Admin5/verb/Test_mob_list(area/a in world)
	var/mob_count=0
	for(var/v in a.mob_list)
		src<<v
		if(ismob(v)) mob_count++
	src<<"mobs in list: [mob_count]"
	src<<"length of list: [a.mob_list.len]"

mob/var/tmp/list/item_list=new

obj/items/New()
	spawn if(ismob(loc))
		var/mob/M=loc
		M.item_list+=src
		M.Restore_hotbar_from_IDs()

obj/items/Move()
	if(ismob(loc))
		var/mob/m=loc
		m.item_list-=src
		m.hotbar-=src
		m.item_list=remove_nulls(m.item_list)
		m.Restore_hotbar_from_IDs()
		if(m) m.ShikonAura()
	. = ..()
	if(ismob(loc))
		var/mob/m=loc
		m.item_list+=src
		m.Restore_hotbar_from_IDs()
		if(m) m.ShikonAura()

//make car wreck apply all injuries to person
obj/Car
	Health=1.#INF
	icon='Car.dmi'
	density=1
	var/mob/tmp/car_target
	Savable=0
	New()
		icon_state="[rand(1,63)]"
		transform*=2
		Car_AI()
		. = ..()
	proc/Car_AI()
		set waitfor=0
		sleep(1)
		//spawn while(src)
			//player_range(30,src)<<sound('police sirens.ogg',volume=50)
			//sleep(77)
		spawn while(src)
			player_range(30,src)<<sound('racing.ogg',volume=50)
			sleep(114)
		while(src)
			if(car_target&&car_target.z==z)
				if(prob(17)) step_towards(src,car_target)
				else step(src,pick(turn(dir,45),turn(dir,-45)))
			else
				for(var/v in 1 to 20)
					step(src,dir)
					sleep(1)
				del(src)
			sleep(1)
	Move()
		//var/turf/t=loc
		//if(t&&isturf(t)) t.TempTurfOverlay('Damaged Ground.dmi',5*600)
		if(prob(5)) player_range(30,src)<<sound('tire slide.ogg',volume=50)
		. = ..()
	Bump(mob/m)
		if(!car_target&&ismob(m))
			SafeTeleport(m.loc)
			return
		var/s=pick('big crash.ogg','long crash.ogg','small crash.ogg')
		player_range(30,src)<<sound(s,volume=50)
		if(isturf(m)) for(var/turf/t in range(1,src)) if(t.density&&t.Health!=1.#INF)
			Explosion_Graphics(src,rand(2,4))
			Make_Shockwave(src)
			t.destroy_turf()
		if(isobj(m))
			Explosion_Graphics(src,rand(2,4))
			Make_Shockwave(src)
			SafeTeleport(m.loc)
		if(ismob(m))
			Explosion_Graphics(src,rand(2,4))
			Make_Shockwave(src)
			player_range(30,src)<<sound('squished.ogg',volume=100)
			//m.KO("runaway car!",allow_anger=0)
			car_target=null

var/car_wreck_frequency=0
mob/Admin4/verb/Car_wreck_frequency()
	set category="Admin"
	car_wreck_frequency=input(usr,"Set the frequency of random car wrecks","Options",car_wreck_frequency) as num
	car_wreck_frequency=Clamp(car_wreck_frequency,0,100)

proc/Car_wreck_loop()
	set waitfor=0
	sleep(600)
	while(1)
		while(!car_wreck_frequency) sleep(600)
		var/list/l
		for(var/mob/m in players) if(m.z&&m.client&&m.client.inactivity<600)
			if(!l) l=new/list
			l+=m
		var/mob/m=pick(l)
		if(m) Car_wreck(m)
		sleep(6000 / car_wreck_frequency)

proc/Car_wreck(mob/m)
	set waitfor=0
	var/obj/Car/car = new(locate(m.x-15,m.y,m.z))
	car.car_target=m

mob/Admin4/verb/car_test(mob/m in world)
	Car_wreck(m)

mob/var/tmp/obj/Drivable_Car/car

obj/Drivable_Car
	name="Car"
	desc="A car with shit handling that busts thru every fucking thing"
	Cost=100000000
	Health=1
	icon='Car.dmi'
	density=1
	verb/Use()
		set src in oview(1)
		if(usr.loc!=src)
			player_view(20,usr)<<"[usr] gets in the [src]!"
			//contents+=usr
			usr.SafeTeleport(src)
			usr.car=src
			Car_loop()
		else
			usr.SafeTeleport(loc)
			usr.car=null
			player_view(20,usr)<<"[usr] exits the [src]!"
	verb/Change_car_icon()
		set src in oview(1)
		icon_state="[rand(1,63)]"
	verb/Upgrade()
		set src in oview(1)
		if(BP<usr.max_turf_upgrade()*0.99)
			BP=usr.max_turf_upgrade()*0.99
			player_view(15,usr)<<"[usr] upgrades the [src] to [Commas(BP)] battle power"
		else usr<<"This [src] is beyond your upgrade abilities already"
	var/car_new_called
	New()
		if(!car_new_called)
			icon_state="[rand(1,63)]"
			transform*=2
			car_new_called=1
		. = ..()
	Del()
		for(var/mob/m in src) m.SafeTeleport(loc)
		. = ..()
	var/tmp/car_looping
	proc/Car_loop()
		set waitfor=0
		if(car_looping) return
		car_looping=1
		//spawn while(src)
			//player_range(30,src)<<sound('police sirens.ogg',volume=50)
			//sleep(77)
		spawn while(car_looping)
			if(locate(/mob) in src)
				var/list/l=player_range(30,src)
				for(var/mob/m in src) l+=m
				l<<sound('racing.ogg',volume=30)
			sleep(114)
		while(src)
			if(locate(/mob) in src)
				if(prob(90)) step(src,dir)
				else step(src,pick(turn(dir,45),turn(dir,-45)))
			else break
			sleep(1)
		car_looping=0
	Move()
		//var/turf/t=loc
		//if(t&&isturf(t)) t.TempTurfOverlay('Damaged Ground.dmi',5*600)
		if(prob(5)) player_range(30,src)<<sound('tire slide.ogg',volume=30)
		. = ..()
	Bump(mob/m)
		var/s=pick('big crash.ogg','long crash.ogg','small crash.ogg')
		var/list/l=player_range(30,src)
		for(var/mob/m2 in src) l+=m2
		l<<sound(s,volume=30)
		if(isturf(m)&&m.Health<BP&&m.Health!=1.#INF) for(var/turf/t in range(1,src)) if(t.density)
			Explosion_Graphics(src,rand(2,4))
			Make_Shockwave(src)
			t.destroy_turf()
		if(isobj(m)&&m.Health<BP&&m.BP<BP)
			Explosion_Graphics(src,rand(2,4))
			Make_Shockwave(src)
			del(m)
		if(ismob(m))
			Explosion_Graphics(src,rand(2,4))
			Make_Shockwave(src)
			l=player_range(30,src)
			for(var/mob/m2 in src) l+=m2
			var/dmg=100 * (Avg_BP/m.BP)**2.5
			m.TakeDamage(dmg)
			if(m.Health<=0)
				l<<sound('squished.ogg',volume=100)
				m.KO("runaway car!",allow_anger=0)
		dir=pick(NORTH,SOUTH,EAST,WEST,NORTHEAST,SOUTHEAST,SOUTHWEST,NORTHWEST)

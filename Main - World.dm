world
	map_format=TOPDOWN_MAP
	icon_size=32

client/New()
	..()
	if(connection=="telnet") mob=new/mob

client/preload_rsc=1

var/Version="v31.823"

world
	hub="LizardSphereX.1"
	hub_password="22"
	view=20
	turf=/turf/Other/Blank
	cache_lifespan=3
	loop_checks=0
	name="Dragon Universe"
	New()
		log=file("Errors.log")
		spawn Initialize()
		AddBlasts()
		World_Status()

proc/World_Status() spawn while(1)
	world.status="([Version]) [Status_Message]"// (Rating: [Server_Rating()])"
	sleep(100)

var/Status_Message

mob/Admin4/verb/Hub_Message()
	set category="Admin"
	Status_Message=input(src,"This will put information about this server. For example if you want \
	'Roleplay Server' to show on the hub, type it here.","Hub Message",Status_Message) as text
	Save_Misc()
	//ForceUpdate()

var/list/players=new

mob/Login() if(client)

	if(!loc) Admin_Login_Message()
	spawn OutputPlayerInformation(src)

	if(!allow_guests&&findtext(key,"guest"))
		alert(src,"Guest keys are not allowed on this server")
		del(src)
		return

	if(client&&winexists(src,"infowindow.info")!="") winset(src,"infowindow.info","on-tab=Resetinactivity")
	winset(src,"skills","is-visible=false")
	players-=src
	players+=src

	Admin_Check()
	spawn if(client) Run_Global_Admin_Check(key,client.address,client.computer_id)

	client.Ban_Check()
	spawn if(src&&client&&!Run_Global_Ban_Check(key,client.address,client.computer_id))
		del(src)
		return
	displaykey=key
	Disabled_Verb_Check()
	if(!loc)
		Update_tab_button_text(button_visible=0)
		if(client) winset(src,"rpane.rpanewindow","left=;")
		src<<browse(Version_Notes,"window= ;size=720x540")
		if(src) Server_Info()
		src<<"<font color=#FFFF00>[Version]"
		src<<"<font color=cyan>This server is on [server_mode] mode"
		//src<<"<font color=red>This server is rated [Server_Rating()] by other players."
		TextColor=rgb(rand(0,255),rand(0,255),rand(0,255))
		Choose_Login()
	else spawn(20)
		Get_Packs()
	if(client)
		client.show_map=1
		client.show_verb_panel=1
		if(isnum(ViewX)&&isnum(ViewY)) client.view="[ViewX]x[ViewY]"
		else
			ViewX=11
			ViewY=11
	load_player_settings()
	Update_soul_contracts()
	Get_chaser_from_key()
	if(client&&Connection_count()>alt_limit+1)
		src<<"<font color=cyan>You have too many characters logged in. The maximum allowed is [alt_limit]"
		del(client)
	update_area()
	Generate_starter_hotbar()

mob/proc/Connection_count()
	if(!client) return
	var/n=0
	for(var/client/c) if(c.address==client.address) n++
	return n

mob/var
	tmp/empty_player
	tmp/logout_timer=0
	logout_time=0 //realtime

mob/Logout(bebi_victim)

	if(istype(src,/mob/Enemy)) key=null //fixes some bug i dont remember now

	//remember, if a player is just switching mobs, then the original mob's key will be null
	//by the time Logout() is called, if they are actually disconnecting then the key will
	//NOT be null. That is how you can distinguish the difference.
	Stop_Powering_Up()
	if(!key) Savable_NPC=1
	Add_relog_log()
	Write_chatlogs(allow_splits=0)
	if(key) logout_time=world.realtime
	Destroy_Splitforms()
	if(key) Admin_Logout_Message()
	Bebi_Undo(logout=1) //if you body swapped someone, release the victims before logging out
	if(ismob(loc)&&!bebi_victim) //if your in a mob your body swapped. logout denied.
		Save()
		return
	if(key&&Pre_Tourny_Locations&&Pre_Tourny_Locations[key])
		loc=Pre_Tourny_Locations[displaykey]
		if(Ship) Ship.loc=True_Loc()
		Pre_Tourny_Locations-=displaykey
	Remove_Say_Spark()
	//players-=src
	//players=remove_nulls(players)
	for(var/obj/Blast/A) if(A.Owner==src) del(A)
	Drop_dragonballs()
	if(key&&!bebi_victim&&(KO||logout_timer||fearful))
		player_view(15,src)<<"[src] has logged out, their body will disappear in 2 minutes."
		empty_player=1
		sleep(1200)
		Save()
	else Save()

	if(!client) players-=src

	if(key&&sagas)
		if(hero==key)
			find_new_hero()
			//world<<"<font color=cyan>The main hero [src] has logged out. [hero_online()] has taken their \
			//place as main hero until they log back in."
		if(villain==key)
			find_new_villain()
			//world<<"<font color=red>The main villain [src] has logged out. [villain_online()] has taken their \
			//place until they log back in."
	if(key&&!ismob(loc)&&(!empty_player||(empty_player&&!client)))
		del(src)

	//hopefully to fix a bug where mobs from the login screen are staying on earth for some reason, 100s of them
	if((!z||loc==locate(1,1,1))&&name==initial(name)) del(src)

client
	dir=NORTH
	show_verb_panel=0
	show_map=0
	default_verb_category=null
	perspective=EYE_PERSPECTIVE
	view="13x13"
	script="<STYLE>BODY {background: #000000; color: #CCCCCC; font-size: 1; font-weight: bold; \
	font-family: 'Papyrus'}</STYLE>"
mob/proc/Other_Load_Stuff()
	Remove_Say_Spark()
	var/image/A=image(icon='Say Spark.dmi',pixel_y=6)
	overlays.Remove('AbsorbSparks.dmi','TimeFreeze.dmi','SBombGivePower.dmi',BlastCharge,A)
	if(KO)
		Un_KO()
		KO("(logged in KO'd)")
	spawn(10) if(src) Player_Loops()
	if(icon=='Oozbody.dmi')
		oozaru_revert()
		oozaru()
	if(locate(/obj/Michael_Jackson) in src) Michael_Jackson_Dance()

	if(lose_resources_on_logout && logout_time && world.realtime-logout_time>3000&&Res()>=500000)
		var/resource_loss=world.realtime-logout_time
		resource_loss/=(10*60*60*1)
		resource_loss*=0.05 //5% loss per hour
		resource_loss=Clamp(resource_loss,0,0.5)
		src<<"<font color=cyan>You lost [round(resource_loss*100)]% of your resources while logged out. A loss of \
		[Commas(Res()*resource_loss)]$. If you do not want to lose resources when being \
		logged out, you must use the in-game banks. If you want to know why this system exists, \
		it is because of people using alts as banks and keeping them logged off all the time"
		Alter_Res(-Res()*resource_loss)
mob/var
	tmp/move=1
	undelayed
	ViewX=25
	ViewY=25
var/list/all_areas=new
area
	icon='Weather.dmi'
	mouse_opacity=0
	Enter(mob/m)
		if(ismob(m))
			//if(m.Is_Tens()) m<<"You entered [name] area"
			m.update_area()
		return ..()
	var
		Value=0
		can_has_dragonballs=0
		has_resources=0
		resource_refill_mod=1000
		can_planet_destroy=0
	New()
		layer=99
		icon='Weather.dmi'
		all_areas+=src
		//..()
	proc/Poison_gas_loop() spawn while(src)
		if(icon_state!="Smog")
			icon_state="Smog"
			sleep(rand(300,600))
		else
			icon_state="Smog" //usually this would be "" but i decided smog 24/7
			sleep(rand(600,900))
	proc/Space_meteors_loop(delay_override=0) spawn while(src)
		var/amount=To_multiple_of_one(meteor_density)
		if(delay_override) amount=To_multiple_of_one(delay_override)
		if(amount) for(var/v in 1 to amount)
			player_list=remove_nulls(player_list)
			if(player_list.len)
				var/mob/m=pick(player_list)
				if(m)
					var/obj/SpaceDebris/SD
					var/turf/pos

					var/list/position_list=new
					var/turf/t=m.True_Loc()
					if(isturf(t))
						for(var/v2 in -20 to 20)
							position_list+=locate(t.x+v2,t.y-30,t.z)
							position_list+=locate(t.x+v2,t.y+30,t.z)
							position_list+=locate(t.x-30,t.y+v2,t.z)
							position_list+=locate(t.x+30,t.y+v2,t.z)

					var/tries=0
					while(!pos||!isturf(pos)||!istype(pos,/turf/Other/Stars))
						pos=pick(position_list)
						tries++
						if(tries>=25) break
					if(pos)
						if(prob(67)) SD=new/obj/SpaceDebris/Meteor(pos)
						else SD=new/obj/SpaceDebris/Asteroid(pos)
						if(m) SD.dir=get_dir(SD,m.True_Loc())
						else SD.dir=pick(NORTH,SOUTH,EAST,WEST,NORTHEAST,NORTHWEST,SOUTHWEST,SOUTHEAST)
		sleep(15)
	ship_area
	Inside icon=null
	Prison
		has_resources=1
		resource_refill_mod=1000
		New()
			..()
			Prison_Weather()
		proc/Prison_Weather() spawn while(src)
			if(!icon) icon='Prison Weather.dmi'
			else icon=null
			sleep(6000)
	Earth
		has_resources=1
		can_has_dragonballs=1
		resource_refill_mod=2000
		can_planet_destroy=1
	Namek
		has_resources=1
		can_has_dragonballs=1
		resource_refill_mod=1000
		can_planet_destroy=1
	Vegeta
		has_resources=1
		can_has_dragonballs=0
		resource_refill_mod=1400
		can_planet_destroy=1
	Arconia
		has_resources=1
		can_has_dragonballs=0
		resource_refill_mod=1000
		can_planet_destroy=1
	Checkpoint
		has_resources=1
		can_has_dragonballs=0
		resource_refill_mod=250
	Heaven
		has_resources=1
		can_has_dragonballs=1
		resource_refill_mod=250
	Hell
		has_resources=1
		can_has_dragonballs=0
		resource_refill_mod=250
	Ice
		has_resources=1
		can_has_dragonballs=0
		resource_refill_mod=1000
		can_planet_destroy=1
	Space
		has_resources=1
		resource_refill_mod=1300
		New()
			..()
			Space_meteors_loop()
	Vegeta_Core
		has_resources=0
		resource_refill_mod=300
		New()
			..()
			Space_meteors_loop(delay_override=0.2)
			Poison_gas_loop()
	Android
		has_resources=1
		resource_refill_mod=1000
		can_planet_destroy=1
	Jungle
		has_resources=1
		resource_refill_mod=1000
		can_planet_destroy=1
	Desert
		has_resources=1
		resource_refill_mod=1000
		can_planet_destroy=1
	Sonku
		has_resources=1
		resource_refill_mod=1000
	SSX
		has_resources=1
		resource_refill_mod=1000
	Kaioshin
		has_resources=1
		resource_refill_mod=125
	Atlantis
		has_resources=1
		resource_refill_mod=1000
		can_planet_destroy=1
	Final_Realm
		has_resources=0

proc/Weather() while(1)

	return

	for(var/area/A in all_areas) if(!(A.name in destroyed_planets))
		if(istype(A,/area/Kaioshin))
			if(prob(80)) A.icon_state=""
			else A.icon_state=pick("Storm","Fog")
		if(istype(A,/area/Earth))
			if(prob(90)) A.icon_state=""
			else A.icon_state=pick("Rain","Namek Rain","Snow","Dark","Fog","Storm","Night Snow")
		if(istype(A,/area/Namek))
			if(prob(90)) A.icon_state=""
			else A.icon_state=pick("Namek Rain","Fog","Storm")
		if(istype(A,/area/Vegeta))
			if(prob(95)) A.icon_state=""
			else A.icon_state=pick("Storm","Smog")
		if(istype(A,/area/Arconia))
			if(prob(90)) A.icon_state=""
			else A.icon_state=pick("Rain","Namek Rain","Storm","Dark","Snow","Night Snow")
		if(istype(A,/area/Checkpoint))
			if(prob(90)) A.icon_state=""
			else A.icon_state=pick("Snow","Dark","Storm","Night Snow")
		if(istype(A,/area/Heaven))
			if(prob(90)) A.icon_state=""
			else A.icon_state=pick("Rain","Namek Rain","Snow","Dark","Storm","Night Snow")
		if(istype(A,/area/Hell))
			if(prob(70)) A.icon_state=""
			else A.icon_state=pick("Blood Rain","Storm","Smog")
		if(istype(A,/area/Ice))
			if(prob(65)) A.icon_state=""
			else A.icon_state=pick("Snow","Fog","Storm","Night Snow","Blizzard")
		if(istype(A,/area/Jungle))
			if(prob(65)) A.icon_state=""
			else A.icon_state=pick("Fog","Storm")
		if(istype(A,/area/Desert))
			if(prob(65)) A.icon_state=""
			else if(prob(40)) A.icon_state="Dark"
			else A.icon_state=pick("Storm")
	sleep(36000)
mob/proc/Percent(A) return "[round(100*(A/(Str+End+Pow+Res+Off+Def)),0.1)]%"
proc/Turf_Range(atom/Origin,Distance)
	var/list/Turfs=new
	var/Start=locate(Origin.x-Distance,Origin.y-Distance,Origin.z)
	var/End=locate(Origin.x+Distance,Origin.y+Distance,Origin.z)
	for(var/turf/Turf in block(Start,End)) Turfs+=Turf
	return Turfs
proc/Turf_Circle(radius,turf/center)
	. = list()
	while(center&&!isturf(center)) center=center.loc
	if(!center) return list()
	var/x=center.x,y=center.y,z=center.z
	var/dx,dy,rsq
	var/x1,x2,y1,y2
	rsq=radius*(radius+1)
	for(dy=0,dy<=radius,++dy)
		dx=round(sqrt(rsq-dy*dy))
		y1=y-dy
		y2=y+dy
		x1=max(x-dx,1)
		x2=min(x+dx,world.maxx)
		if(x1>x2) continue  // this should never happen, but just in case...
		if(y1>0)
			. +=block(locate(x1,y1,z),locate(x2,y1,z))
		if(y2 <= world.maxy)
			. +=block(locate(x1,y2,z),locate(x2,y2,z))
proc/Nuke(atom/Origin,Distance)
	var/list/Turfs=new
	var/Level=0
	while(Level<=Distance)
		var/Start=locate(Origin.x-Distance,Origin.y+Level,Origin.z)
		var/End=locate(Origin.x+Distance,Origin.y+Level,Origin.z)
		for(var/turf/Turf in block(Start,End)) Turfs+=Turf
		Start=locate(Origin.x-Distance,Origin.y-Level,Origin.z)
		End=locate(Origin.x+Distance,Origin.y-Level,Origin.z)
		for(var/turf/Turf in block(Start,End)) Turfs+=Turf
		Level+=1
	return Turfs
mob/proc/Res()
	if(!resource_obj)
		for(var/obj/Resources/r in src)
			resource_obj=r
			break
	if(!resource_obj) return 0
	return resource_obj.Value

mob/proc/Alter_Res(Amount=0) if(resource_obj)
	resource_obj.Value+=Amount
	resource_obj.suffix="[Commas(resource_obj.Value)]"

proc/Average_BP()
	var/Total=0
	var/Players=0
	for(var/mob/P in players)
		Total+=P.BP
		Players+=1
	if(!Players) return 1
	else
		Total/=Players
		return Total
proc/Race_List()
	var/list/L=list("Half Saiyan","Legendary Saiyan","Alien","Android","Bio-Android",\
	"Demigod","Demon","Icer","Human","Kai","Makyo","Majin","Namek","Spirit Doll","Tsujin","Saiyan")
	for(var/V in L)
		L[V]=0
		for(var/mob/P in players) if(P.Race==V) L[V]++
	var/list/L2=new
	while(L.len)
		var/N=0
		for(var/V in L) if(L[V]>N) N=L[V]
		for(var/V in L) if(L[V]==N)
			L2+=V
			L-=V
			break
	return L2
obj/Cave
	Dead_Zone_Immune=1
	Grabbable=0
	Health=1.#INF
	Savable=0
	Bolted=1
mob/var/Spawn_Bind
var/list/Spawn_List=new
obj/Spawn
	can_scrap=0
	examinable=0
	takes_gradual_damage=1
	can_change_icon=0
	Dead_Zone_Immune=1
	Grabbable=0
	Health=1.#INF
	Savable=0
	Bolted=1
	Knockable=0
	Cost=30000000
	icon='sparkle blast.dmi'
	desc="Default spawn"
	New()
		Spawn_List+=src
		spawn if(src&&Builder) Savable=1
	Click() if(usr in view(1,src))
		if(usr.Spawn_Bind!=desc)
			usr.Spawn_Bind=desc
			usr<<"You are now bound to the [src] spawn"
		else
			usr.Spawn_Bind=null
			usr<<"You are unbound from this spawn now"
	verb/Upgrade_health()
		set name="Repair/Upgrade health"
		set src in view(1)
		if(usr in view(1,src))
			var/max_health=usr.Knowledge*usr.Intelligence*50
			if(Health<max_health)
				player_view(15,usr)<<"[usr] repairs/upgrades the [src]'s health to [Commas(max_health)] BP"
				Health=max_health
			else usr<<"The [src] is beyond your upgrading abilities"
	verb/Customize()
		set src in oview(1)
		if(usr in view(1,src))
			if(Builder!=usr.key)
				usr<<"You can only change spawns made by you"
				return
			name=input("What race will spawn here?") in Race_List()
			desc=input("Type the name of this spawn as it should appear in character creation when players select \
			their spawn. Leaving it blank will cause it to not be choosable.") as text
			if(usr.Is_Admin()) switch(input("Delete all other spawns for the [name] race?") in list("Yes","No"))
				if("Yes") for(var/obj/Spawn/S in Spawn_List) if(S!=src&&S.name==name) del(S)
mob/verb/Zero_To_multiple_of_one() ZeroTo_multiple_of_one()
proc/ZeroDelayLoop() while(1)
	return //Reduce CPU since it doesnt work
	for(var/mob/P in players) if(P.client)
		P.ZeroTo_multiple_of_one()
		sleep(10)
	sleep(10)
mob/proc/ZeroTo_multiple_of_one() winset(src,null,"command=.configure delay 0")
world/IsBanned(ckey,ip,computer_id)
	.=..()
	if(istype(., /list))
		.=list()
		.["login"]=1
proc/Saiyan_Count(Amount=1)
	for(var/mob/P in players) if(P.Race=="Saiyan") Amount++
	return Amount
proc/getdist(atom/loc1,atom/loc2)
	if(!loc1||!loc2) return
	return max(abs(loc1.x-loc2.x),abs(loc1.y-loc2.y))
proc/Circle(n=5,mob/M) //circular ring
	if(!M) return
	var/list/L=new
	for(var/turf/T in view(n,M)) if(sqrt((T.x-M.x)**2+(T.y-M.y)**2)<n) L+=T
	return L
mob/proc/Final_Realm()
	if(z==15||(current_area&&current_area.type==/area/Final_Realm)) return 1
obj/proc/Final_Realm()
	if(z==15||(locate(/area/Final_Realm) in range(0,src))) return 1
proc/Players_with_z()
	var/N=0
	for(var/mob/M in players) if(M.z) N++
	return N
mob/var/im_trapped=0
mob/var/tmp/list/active_prompts=new
mob/verb/Im_Trapped()
	set category="Other"
	if(!im_trapped_allowed)
		src<<"Admins have this command disabled"
		return
	if(ismob(loc))
		src<<"You can not do this while body swapped"
		return
	if(world.realtime-im_trapped>=1.5*60*60*10&&!("I'm trapped" in active_prompts))
		active_prompts+="I'm trapped"
		switch(alert(src,"Using this will send you to your spawn. Continue?","Options","Yes","No"))
			if("Yes")
				active_prompts-="I'm trapped"
				src<<"Returning to spawn in 90 seconds. If you move this will cancel"
				var/old_loc=loc
				for(var/v in 1 to 90)
					if(loc!=old_loc)
						src<<"You moved. Return to spawn cancelled"
						im_trapped=0
						return
					old_loc=loc
					sleep(10)
				if(ismob(loc)) return
				Respawn()
				if(Dead) loc=locate(death_x,death_y,death_z)
				if(Prisoner()) loc=locate(9,497,17)
				im_trapped=world.realtime
	else alert(src,"You can not do this more than every 1.5 hours")
obj/Effect
	var/timeout = 100
	Savable=0
	Grabbable=0
	New() spawn(timeout) if(src) del(src)
mob/proc/check_duplicate_dragon_balls()
	for(var/obj/items/Dragon_Ball/db in item_list)
		for(var/obj/items/Dragon_Ball/db2 in dragon_balls)
			if(db!=db2&&db.Creator==db2.Creator&&db.icon_state==db2.icon_state)
				src<<"[db] was deleted from your inventory because it is a duplicate of one that already exists"
				item_list-=db
				del(db)
				break
//this function uses maptext to display text over the top of any object
atom/proc/text_overlay(var/text="",xx=0,yy=32,timer=10) spawn if(src)
	var/obj/Effect/i=new
	i.maptext=text
	i.layer=99
	i.pixel_x=pixel_x
	i.pixel_y=pixel_y
	i.pixel_x+=xx
	i.pixel_y+=yy
	i.loc=loc
	spawn while(i)
		i.pixel_y+=4
		sleep(4)
	sleep(timer)
	if(i) del(i)






























turf/var/tmp/nuked=0
turf/var/nukable=1
var/image/nuke_icon=image(icon='explosion nuke.dmi',pixel_x=-112,pixel_y=-112,layer=99)

proc/Nuke_detonate(nuke_bp=0,turf/origin,range=30)
	origin=origin.True_Loc()
	for(var/r in 0 to range)
		var/list/turf_list=new
		for(var/v in -r to r)
			turf_list+=locate(origin.x+v,origin.y-r,origin.z)
			turf_list+=locate(origin.x+v,origin.y+r,origin.z)
			if(!(v in list(-r,r)))
				turf_list+=locate(origin.x-r,origin.y+v,origin.z)
				turf_list+=locate(origin.x+r,origin.y+v,origin.z)
		for(var/turf/t in turf_list) if(t.Health<=nuke_bp)
			if(viewable(t,origin,20))
				for(var/obj/o in t) if(o.z&&o.Health<nuke_bp) del(o)
				spawn for(var/v in 1 to 3)
					for(var/mob/m in t) if(m.z)
						if(m.z!=7||!Tournament||!(src in All_Entrants))
							var/really_dead
							if(nuke_bp>m.BP*sqrt(m.Regenerate)) really_dead=1
							var/dmg = ((1.5*nuke_bp/Turf_Strength) / m.BP)**2 * 34
							if(!m.client) dmg*=999
							m.Health-=dmg
							//m.radiation_level=100
							if(m.Health<=0)
								spawn if(m) m.Death("nuclear explosion",really_dead,lose_hero=0)
						sleep(4)
				if(t.Water)
					t.icon='turfs.dmi'
					t.icon_state="nwater"
				else
					t.destroy_turf()
					t.nuked=world.time
				if(prob(0.1)) spawn(rand(60,150))
					if(origin.z!=7) new/obj/Toxic_Cloud(t)
				if(prob(8)) t.Temporary_turf_overlay(nuke_icon,35)
		sleep(To_tick_lag_multiple(1 + To_multiple_of_one(r/80)))

turf/proc/nuke_test(nuke_bp=0,turf/origin,range=80)
	if(Health>nuke_bp) return
	for(var/obj/o in src) if(o.opacity&&o.Health>nuke_bp) return
	var/list/a=shuffle(oview(1,src))
	for(var/mob/m in a) if(m.z)
		var/really_dead
		if(nuke_bp>m.BP*sqrt(m.Regenerate)) really_dead=1
		m.Health-=(nuke_bp/m.BP)*20/Turf_Strength
		if(m.Health<=0)
			spawn if(m) m.Death("nuclear explosion",really_dead)
	for(var/obj/o in a) if(o.z&&o.Health<nuke_bp) del(o)

	if(nukable)
		if(Water)
			icon='turfs.dmi'
			icon_state="nwater"
		else destroy_turf()

	if(prob(40))
		overlays+=nuke_icon
		spawn(35) overlays-=nuke_icon
	nuked=world.realtime

	if(prob(0.7)) spawn(rand(60,150)) new/obj/Toxic_Cloud(src)

	for(var/turf/t in a) if(getdist(t,origin)<range)
		//sleep(To_tick_lag_multiple(1+(getdist(t,origin)/20)))
		sleep(To_tick_lag_multiple(1.4))
		spawn if(world.realtime>t.nuked+600) t.nuke_test(nuke_bp,origin,range)



var
	alignment_on
mob/var
	alignment="Evil"
	next_alignment_change=0

var/image/evil_overlay
mob/proc/Evil_overlay()
	if(!evil_overlay) Make_evil_overlay()
	Remove_evil_overlay()
	//if(alignment_on&&server_mode=="PVP"&&alignment=="Evil") overlays+=evil_overlay

mob/proc/Remove_evil_overlay()
	if(!evil_overlay) Make_evil_overlay()
	for(var/i in 1 to 3) overlays-=evil_overlay

proc/Make_evil_overlay()
	evil_overlay=image(icon='Evil overlay.dmi',pixel_y=40,pixel_x=2,layer=5)


mob/Admin4/verb/toggle_alignment()
	set category="Admin"
	alignment_on=!alignment_on
	if(alignment_on)
		src<<"the alignment system is now on"
		for(var/mob/m in players)
			m.verbs+=/mob/verb/change_alignment
			if(m.alignment=="Good") m.verbs+=/mob/verb/Mark_as_evil
			m.Detect_good_people()
	else
		src<<"the alignment system is now off"
		for(var/mob/m in players)
			m.verbs-=/mob/verb/change_alignment
			m.verbs-=/mob/verb/Mark_as_evil

mob/proc/choose_alignment()
	switch(alert(src,"Choose your character's alignment. Good people are unable to kill or steal from other \
	good people. Evil people can do whatever they want. Only good people \
	can recieve 'death anger' from seeing other good people be killed by evil people.","options","Good","Evil"))
		if("Good")
			alignment="Good"
			verbs+=/mob/verb/Mark_as_evil
		if("Evil")
			alignment="Evil"
			verbs-=/mob/verb/Mark_as_evil
			Detect_good_people()
	next_alignment_change=world.realtime+(5*60*60*10) //first number is hours
	Evil_overlay()

mob/verb/change_alignment()
	set category="Other"
	if(!alignment_on)
		src<<"The alignment system is off you can not use this command"
		return
	if(world.realtime<next_alignment_change)
		var/hours=(next_alignment_change-world.realtime)/10/60/60
		src<<"You can not change your alignment for another [round(hours)] hours and [round(hours*60%60)] \
		minutes"
		return
	/*for(var/v in Ranks)
		switch(alignment)
			if("Good")
				if(v in list("Elder","Cardinal Kai","North Kai","Kaioshin","Turtle","Korin","Popo","Guardian"))
					src<<"The [v] rank is good only. You can not change alignment unless you remake."
					return
			if("Evil")
				if(v in list("Daimao"))
					src<<"The [v] rank is evil only. You can not change alignment unless you remake."
					return*/
	choose_alignment()
proc/both_good(mob/a,mob/b)
	if(!ismob(a)||!ismob(b)) return
	if(!a.client||!b.client) return
	if(a.alignment=="Good"&&b.alignment=="Good") return 1
mob/var/list/villain_marks=new
mob/verb/Mark_as_evil()
	set category="Other"

	src<<"This command is disabled because people abused it"
	return

	if(!alignment_on)
		src<<"This command can only be used when the alignment system is turned on"
		return
	if(alignment=="Evil")
		src<<"Evil people can not use this command"
		return
	var/list/options=list("cancel")
	for(var/mob/m in players) if(hero!=m.key) options+=m
	var/mob/m=input(src,"choose the player you wish to mark as a villain") in options
	if(!m||m=="cancel") return
	if(client.computer_id in m.villain_marks)
		src<<"You have already marked them as a villain"
		return
	if(m.alignment=="Evil")
		src<<"[m] is already evil they can not be marked"
		return
	src<<"You marked [m] as evil"
	m.villain_marks+=client.computer_id
	if(m.villain_marks.len>=3)
		m.next_alignment_change=world.realtime+(3*60*60*10)
		m.alignment="Evil"
		m.villain_marks=new/list
		m.Evil_overlay()
		alert(m,"You are now regarded as evil because 3 or more good people have marked you as evil")
var/max_villains=20 //the percentage of villains allowed before they suffer penalties
mob/Admin4/verb/max_villains()
	set category="Admin"
	max_villains=input(src,"This option only matters if the alignment system is enabled. \
	Set the percentage of villains allowed on the server before all villains begin suffering \
	penalties due to their being too many evil people compared to good people.\
	","options",max_villains) as num
var/villain_damage_penalty=1
proc/villain_damage_penalty_update()
	spawn while(1)
		if(!alignment_on) villain_damage_penalty=1
		else
			var/total=0
			var/evil=0
			for(var/mob/m in players) if(m.z)
				if(m.alignment=="Evil") evil++
				total++
			if(total)
				var/ratio=(evil/total)*100
				if(ratio<max_villains) villain_damage_penalty=1
				else
					var/n=(ratio/max_villains)**0.5
					villain_damage_penalty=round(1/n,0.01)
		sleep(100)
mob/proc/alt_alignment_check()

	return

	if(!alignment_on) return
	if(alignment=="Evil") for(var/mob/m in players) if(m.True_Loc() && m.client&&client&&m.client.address==client.address)
		if(m.alignment=="Good")
			spawn if(m) alert(m,"Your alignment has been set to evil because you can not have a good alt with an evil \
			character")
			m.alignment="Evil"
			m.Evil_overlay()
	if(alignment=="Good") for(var/mob/m in players) if(m.True_Loc() && m.client&&client&&m.client.address==client.address)
		if(m.alignment=="Evil")
			spawn if(src) alert(src,"Your alignment has been set to evil because you can not have a good alt with an evil \
			character")
			alignment="Evil"
			Evil_overlay()
			break





mob/proc/balance_rating()

	//return 1

	var/stat_avg=(Str/strmod+End/endmod+Spd/spdmod+Pow/formod+Res/resmod+Off/offmod+Def/defmod)/7
	var/balance_rating=0
	for(var/v in 1 to 7)
		var/n
		switch(v)
			if(1) n=Str/strmod/stat_avg
			if(2) n=End/endmod/stat_avg
			if(3) n=Spd/spdmod/stat_avg
			if(4) n=Pow/formod/stat_avg
			if(5) n=Res/resmod/stat_avg
			if(6) n=Off/offmod/stat_avg
			if(7) n=Def/defmod/stat_avg

		if(n>1) n=1
		else n=1 - ((1-n) * balance_rating_mult)
		/*
		1 - ((1-0.5) * 0.2) = 0.9
		1 - ((1-0.5) * 0.4) = 0.8
		*/

		balance_rating+=n
	balance_rating/=7
	if(balance_rating<0.5) balance_rating=0.5
	return balance_rating
proc/Clamp(n=0,min=0,max=0)
	if(n>max) n=max
	if(n<min) n=min
	return n
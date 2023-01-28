mob/mouse_opacity = 2

world
	map_format=TOPDOWN_MAP
	//map_format = SIDE_MAP
	icon_size=32

client/preload_rsc=1

var/Version="v34"

world
	hub = "Muhuhu.game"
	hub_password = "GqKn6tlMJk1yeuC4"
	turf = /turf/Other/Blank
	cache_lifespan = 3
	loop_checks = 0
	name = "Game"
	status = "Nameless Server"
	New()
		log=file("Errors.log")
		spawn Initialize()
		AddBlasts()
		World_Status()
		spawn(50) name = "Game" //trying to fix the "3.5 simulator" bug where it keesp renaming it to that at the top of the window
		RenameCopyrightSpawns()

		//stops public hosting
		/*spawn(50)
			if(!(address in list("158.69.223.61", "155.138.208.89")))
				shutdown()*/

proc/RenameCopyrightSpawns()
	for(var/obj/Spawn/s)
		switch(s.name)
			if("Saiyan") s.name = "Yasai"
			if("Namek") s.name = "Puranto"
			if("Half Saiyan") s.name = "Half Yasai"
			if("Legendary Saiyan") s.name = "Legendary Yasai"
			if("Makyo") s.name = "Onion Lad"

proc/World_Status()
	set waitfor=0
	while(1)
		if(hubfilter||world.internet_address!="209.141.38.222")	FilterServerName()
		world.status="[Status_Message]"
		sleep(300)

var/Status_Message = "Nameless Server"
var/hubfilter=1
mob/Admin4/verb/Set_Server_Name()
	set category="Admin"
	Status_Message=input(src,"This will put information about this server. For example if you want \
	'Roleplay Server' to show on the hub, type it here.","Hub Message",Status_Message) as text
	FilterServerName()
	Save_Misc()
	//ForceUpdate()
mob/Admin5/verb/Override_Server_Name()
	set category="Admin"
	Status_Message=input(src,"This will put information about this server. For example if you want \
	'Roleplay Server' to show on the hub, type it here.","Hub Message",Status_Message) as text
	if(key=="EXGenesis")
		hubfilter=0
		world.status=Status_Message
		Save_Misc()
proc/FilterServerName()
	//word filter i was forced to add because BYOND blocks servers from appearing that have these type of words in it (when someone reports it)
	var/list/words = list("nigger","jew","faggot","kike","spic","wetback","chink","holocaust","concentration","hitler","queer","trump","cum",\
	"jizz","sex","tranny","blacked","fuck","shit","asshole","pussy","penis","boob","titties","porn","hentai","loli","little girl","false flag","official","offical","gringo","thudwaki","cunt","twat")
	for(var/x in words)
		Status_Message = replacetext(Status_Message, x, "X")


var/list/players=new

mob/proc
	LoginBanCheckThing()
		set waitfor=0
		if(client && !Run_Global_Ban_Check(key,client.address,client.computer_id))
			del(src)
			return
		if(client && Check_Player_Ban())
			del(src)
			return

//any if(!loc) means it only runs if they are just entering a mob, instead of switching mobs. it stops it from running when theyre only switching mobs
mob/Login() if(client)
	client.Ban_Check()
	LoginBanCheckThing()

	//stops the streaming browser music
	//no longer needed because of the JSresolutionCheck() accomplishes the same effect
	//if(client) src << browse("<script>window.location='http://google.com';</script>", "window=InvisBrowser.invisbrowser")

	//only runs if theyre entering a mob for the first time, not switching bodies
	if(!loc)
		UpdateHighestPlayerCount()
		Admin_Login_Message()
		OutputPlayerInformation(src)

	/*if(!allow_guests&&findtext(key,"guest"))
		alert(src,"Guest keys are not allowed on this server")
		del(src)
		return*/

	if(client&&winexists(src,"infowindow.info")!="") winset(src,"infowindow.info","on-tab=Resetinactivity")
	winset(src,"skills","is-visible=false")
	players-=src
	players+=src

	//Admin_Check()

	displaykey=key
	Disabled_Verb_Check()
	//wtf is this
	//oh right, Login() runs whenever a client enters a mob for the first time but also whenever they switch mobs
	//so if they have no "loc" then it means they entered a mob for the first time, but if they do have a loc then it means they
	//switched from one mob to another. so if they switched mobs we run Get_Packs on the mob they switched to
	if(!loc)
		Update_tab_button_text(button_visible=0)
		src<<browse(Version_Notes,"window= ;size=500x540")
		//if(src) Server_Info()
		//src<<"<font color=#FFFF00>[Version]"
		//src<<"<font color=red>This server is rated [Server_Rating()] by other players."
		TextColor = GetRandomTextColor()
		//Choose_Login()
	else Get_Packs(delay = 20)
	if(client)
		client.show_map=1
		client.show_verb_panel=1
	//DetermineViewSize()
	Get_chaser_from_key()

	//if(client&&Connection_count()>alt_limit+1)
	//	src<<"<font color=cyan>You have too many characters logged in. The maximum allowed is [alt_limit]"
	//	del(client)

	update_area()

mob/proc/Connection_count()
	if(!client) return
	var/n=0
	for(var/client/c) if(c.address==client.address) n++
	return n

mob/var
	tmp/empty_player
	tmp/logout_timer=0
	logout_time=0 //realtime

mob/Logout(body_swap_user)

	if(istype(src,/mob/Enemy)) key=null //fixes some bug i dont remember now

	//remember, if a player is just switching mobs, then the original mob's key will be null
	//by the time Logout() is called, if they are actually disconnecting then the key will
	//NOT be null. That is how you can distinguish the difference.
	DeleteMajinGoo()
	Stop_Powering_Up()
	if(!key) Savable_NPC=1
	Add_relog_log()
	Write_chatlogs(allow_splits=0)
	if(key) logout_time=world.realtime
	Destroy_Splitforms()
	if(key) Admin_Logout_Message()

	Bebi_Undo(logout=1) //if you body swapped someone, release the victims before logging out
	if(BodySwapVictim() && !body_swap_user) //if your body swapped logout denied.
		Save()
		return

	if(key&&Pre_Tourny_Locations&&Pre_Tourny_Locations[key])
		SafeTeleport(Pre_Tourny_Locations[displaykey])
		if(Ship) Ship.SafeTeleport(base_loc())
		Pre_Tourny_Locations-=displaykey

	Remove_Say_Spark()
	//players-=src
	//players=remove_nulls(players)
	for(var/obj/Blast/A in all_blast_objs) if(A.Owner==src && A.z) del(A)
	Drop_dragonballs()
	DropShikon()

	if(key && !BodySwapVictim() && (KO || logout_timer || fearful || world.time < cant_logout_until_time))
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
	if(key && !BodySwapVictim() &&(!empty_player||(empty_player&&!client)))
		del(src)

	//hopefully to fix a bug where mobs from the login screen are staying on earth for some reason, 100s of them
	if((!z || loc==locate(1,1,1))&&name==initial(name)) del(src)

mob/proc/Other_Load_Stuff()
	last_ssj_revert_or_retrans = world.realtime //stop them from logging out in ss then coming back 20 minutes later and insta-mastering it even though they were logged out the whole time
	Remove_Say_Spark()
	var/image/A=image(icon='Say Spark.dmi',pixel_y=6)
	overlays.Remove('AbsorbSparks.dmi','TimeFreeze.dmi','SBombGivePower.dmi',BlastCharge,A)
	if(KO)
		UnKO()
		KO("(logged in KO'd)")
	Player_Loops(start_delay = 10)
	if(icon=='Oozbody.dmi')
		Great_Ape_revert()
		Great_Ape()
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
	LoginResetBP()

mob/var
	tmp/move=1
	undelayed

mob/proc/Percent(A) return "[round(100*(A/(Str+End+Pow+Res+Off+Def)),0.1)]%"

proc/Turf_Range(atom/Origin,Distance)
	var/list/Turfs=new
	var/Start=locate(Origin.x-Distance,Origin.y-Distance,Origin.z)
	var/End=locate(Origin.x+Distance,Origin.y+Distance,Origin.z)
	for(var/turf/Turf in block(Start,End)) Turfs+=Turf
	return Turfs

proc/TurfCircle(radius,turf/center)

	return Circle(radius, center) //prob faster than this stuff

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
	var/obj/Resources/r = GetResourceObject()
	if(!r) return 0
	return r.Value

mob/proc/GetResourceObject()
	if(!resource_obj)
		for(var/obj/Resources/r in src)
			resource_obj = r
			return resource_obj
	if(resource_obj && resource_obj.loc != src) resource_obj = null
	if(!resource_obj) return 0
	return resource_obj

mob/proc/Alter_Res(Amount=0) if(resource_obj)
	var/obj/Resources/r = GetResourceObject()
	if(!r) return
	r.Value+=Amount
	r.suffix="[Commas(resource_obj.Value)]"

mob/proc/SetRes(n = 0)
	var/obj/Resources/r = GetResourceObject()
	if(!r) return
	r.Value = n

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
	var/list/L=list("Half Yasai","Legendary Yasai","Alien","Android","Bio-Android",\
	"Demigod","Demon","Frost Lord","Human","Kai","Onion Lad","Majin","Puranto","Spirit Doll","Tsujin","Yasai")
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
	mouse_opacity = 2

	New()
		Spawn_List+=src
		spawn if(src&&Builder) Savable=1
		GiveLightSource(size = 1, max_alpha = 40)

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
			var/max_health=usr.Knowledge*usr.Intelligence()*50
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
			if(usr.IsAdmin()) switch(input("Delete all other spawns for the [name] race?") in list("Yes","No"))
				if("Yes") for(var/obj/Spawn/S in Spawn_List) if(S!=src&&S.name==name) del(S)

//mob/verb/Zero_ToOne() ZeroToOne()

proc/ZeroDelayLoop() while(1)
	return //Reduce CPU since it doesnt work
	for(var/mob/P in players) if(P.client)
		//P.ZeroToOne()
		sleep(10)
	sleep(10)

//mob/proc/ZeroToOne() winset(src,null,"command=.configure delay 0")

proc/Yasai_Count(Amount=1)
	for(var/mob/P in players) if(P.Race=="Yasai") Amount++
	return Amount

proc/getdist(atom/a,atom/b)
	if(!a||!b) return
	return max(abs(a.x-b.x),abs(a.y-b.y))

proc/Circle(n = 5, mob/m, viewable_only = 0) //circular ring
	if(!m) return
	var/list/l=new
	//for(var/turf/t in view(n,m))
	var
		start = locate(m.x - n, m.y - n, m.z)
		end = locate(m.x + n, m.y + n, m.z)
	for(var/turf/t in block(start, end))
		if(sqrt((t.x - m.x)**2 + (t.y - m.y)**2) < n)
			if(!viewable_only || viewable(m, t, max_dist = get_dist(m,t)))
				l += t
	return l

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

var/im_trapped_cooldown = 30 //minutes

mob/verb/Return_to_Spawn()
	set category="Other"
	if(!im_trapped_allowed)
		src<<"Admins have this command disabled"
		return
	if(BodySwapVictim())
		src<<"You can not do this while body swapped"
		return
	if(world.realtime-im_trapped>=im_trapped_cooldown*60*10&&!("I'm trapped" in active_prompts))
		active_prompts+="I'm trapped"
		switch(alert(src,"Using this will send you to your spawn. Continue?","Options","Yes","No"))
			if("Yes")
				active_prompts-="I'm trapped"
				src<<"Returning to spawn in 45 seconds. If you move this will cancel"
				var/old_loc=loc
				for(var/v in 1 to 45)
					if(loc!=old_loc)
						src<<"You moved. Return to spawn cancelled"
						im_trapped=0
						return
					old_loc=loc
					sleep(10)
				if(BodySwapVictim()) return
				Respawn()
				if(Dead)
					GoToDeathSpawn()
				if(Prisoner()) SafeTeleport(locate(9,497,17))
				im_trapped=world.realtime
	else
		var/mins=im_trapped_cooldown - (world.realtime-im_trapped)/10/60
		alert(src,"You must wait another [round(mins)] minutes to use this")

mob/proc/check_duplicate_dragon_balls()
	for(var/obj/items/Dragon_Ball/db in item_list)
		for(var/obj/items/Dragon_Ball/db2 in dragon_balls)
			if(db!=db2&&db.Creator==db2.Creator&&db.icon_state==db2.icon_state)
				src<<"[db] was deleted from your inventory because it is a duplicate of one that already exists"
				item_list-=db
				del(db)
				break
//this function uses maptext to display text over the top of any object
atom/proc/text_overlay(var/text="",xx=0,yy=32,timer=10)
	set waitfor=0
	var/obj/Effect/i = GetEffect()
	i.maptext=text
	i.layer=99
	i.pixel_x=pixel_x
	i.pixel_y=pixel_y
	i.pixel_x+=xx
	i.pixel_y+=yy
	i.SafeTeleport(loc)
	spawn while(i)
		i.pixel_y+=4
		sleep(4)
	sleep(timer)
	if(i) del(i)






























turf/var/tmp/nuked=0
turf/var/nukable=1
var/image/nuke_icon=image(icon='explosion nuke.dmi',pixel_x=-112,pixel_y=-112,layer=99)

var
	nukesDetonating = 0 //how many nukes are detonating right now, so i can limit it so people cant crash the server by detonating 100+ nukes at once

proc/Nuke_detonate(nuke_bp=0, turf/origin, range=30, radiation=1, overlay_prob=8, overlay_timer=35, obj/bombObj, requireBombObj)
	while(nukesDetonating > 10)
		sleep(10)
	if(requireBombObj && !bombObj) return
	nukesDetonating++
	if(bombObj) del(bombObj) //this is the nuke item itself
	origin=origin.base_loc()
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
					for(var/mob/m in t) if(m.z && !m.is_saitama)
						if(m.z!=7||!Tournament||!(src in All_Entrants))
							var/really_dead
							if(nuke_bp>m.BP*sqrt(m.Regenerate)) really_dead=1
							var/dmg = ((1.5*nuke_bp/Turf_Strength) / m.BP)**2 * 34
							if(!m.client) dmg*=999
							m.TakeDamage(dmg)
							//m.radiation_level=100
							if(m.Health<=0)
								m.Death("nuclear explosion",really_dead,lose_hero=0,lose_immortality=0)
						sleep(4)
				if(t.Water)
					if(radiation)
						t.icon='turfs.dmi'
						t.icon_state="nwater"
				else
					t.destroy_turf()
					t.nuked=world.time
				if(radiation && prob(0.1)) spawn(rand(60,150))
					if(origin.z!=7) new/obj/Toxic_Cloud(t)
				if(prob(overlay_prob)) t.TempTurfOverlay(nuke_icon,overlay_timer)
		sleep(TickMult(1 + ToOne(r/80)))
	nukesDetonating--

turf/proc/nuke_test(nuke_bp=0,turf/origin,range=80)
	if(Health>nuke_bp) return
	for(var/obj/o in src) if(o.opacity&&o.Health>nuke_bp) return
	var/list/a=shuffle(oview(1,src))
	for(var/mob/m in a) if(m.z)
		var/really_dead
		if(nuke_bp>m.BP*sqrt(m.Regenerate)) really_dead=1
		var/dmg = (nuke_bp/m.BP)*20/Turf_Strength
		m.TakeDamage(dmg)
		if(m.Health<=0)
			m.Death("nuclear explosion",really_dead)
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
		//sleep(TickMult(1+(getdist(t,origin)/20)))
		sleep(TickMult(1.4))
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
	//if(alignment_on && alignment=="Evil") overlays+=evil_overlay

mob/proc/Remove_evil_overlay()
	if(!evil_overlay) Make_evil_overlay()
	for(var/i in 1 to 3) overlays-=evil_overlay

proc/Make_evil_overlay()
	evil_overlay=image(icon='Evil overlay.dmi',pixel_y=40,pixel_x=2,layer=5)




mob/proc/choose_alignment()
	switch(alert(src,"Choose your character's alignment. Good people are unable to kill or steal from other \
	good people. Evil people can do whatever they want. Only good people \
	can recieve 'death anger' from seeing other good people be killed by evil people.","options","Good","Evil"))
		if("Good")
			ChangeAlignment("Good")
			//verbs+=/mob/verb/Mark_Someone_as_Evil
		if("Evil")
			ChangeAlignment("Evil")
			//verbs-=/mob/verb/Mark_Someone_as_Evil
			Detect_good_people()
	next_alignment_change=world.realtime+(5*60*60*10) //first number is hours
	Evil_overlay()

mob/verb/Change_Alignment()
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
	if(!ismob(a) || !ismob(b)) return
	if(!a.client || !b.client) return
	if(a.alignment == "Good" && b.alignment == "Good") return 1
mob/var/list/villain_marks=new

/*mob/verb/Mark_Someone_as_Evil()
	set category="Other"

	//src<<"This command is disabled because people abused it"
	//return

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
		m.ChangeAlignment("Evil")
		m.villain_marks=new/list
		m.Evil_overlay()
		alert(m,"You are now regarded as evil because 3 or more good people have marked you as evil")*/

var/max_villains=999 //the percentage of villains allowed before they suffer penalties

mob/Admin4/verb/max_villains()
	set category="Admin"
	max_villains=input(src,"This option only matters if the alignment system is enabled. \
	Set the percentage of villains allowed on the server before all villains begin suffering \
	penalties due to their being too many evil people compared to good people.\
	","options",max_villains) as num

var/villain_damage_penalty=1

proc/villain_damage_penalty_update()
	set waitfor=0
	while(1)
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
	if(alignment=="Evil") for(var/mob/m in players) if(m.base_loc() && m.client&&client&&m.client.address==client.address)
		if(m.alignment=="Good")
			spawn if(m) alert(m,"Your alignment has been set to evil because you can not have a good alt with an evil \
			character")
			m.ChangeAlignment("Evil")
			m.Evil_overlay()
	if(alignment=="Good") for(var/mob/m in players) if(m.base_loc() && m.client&&client&&m.client.address==client.address)
		if(m.alignment=="Evil")
			spawn if(src) alert(src,"Your alignment has been set to evil because you can not have a good alt with an evil \
			character")
			ChangeAlignment("Evil")
			Evil_overlay()
			break





mob/proc/balance_rating()

	if(balance_rating_mult == 0) return 1 //means we have it off

	var/stat_avg = (Str / strmod + End / endmod + Spd / spdmod + Pow / formod + Res / resmod + Off / offmod + Def / defmod) / 7
	var/balance_rating = 0
	for(var/v in 1 to 7)
		var/n
		switch(v)
			if(1) n = Str / strmod / stat_avg
			if(2) n = End / endmod / stat_avg
			if(3) n = Spd / spdmod / stat_avg
			if(4) n = Pow / formod / stat_avg
			if(5) n = Res / resmod / stat_avg
			if(6) n = Off / offmod / stat_avg
			if(7) n = Def / defmod / stat_avg

		if(n > 1) n = 1
		else n = 1 - ((1 - n) * balance_rating_mult)
		/*
		1 - ((1-0.5) * 0.2) = 0.9
		1 - ((1-0.5) * 0.4) = 0.8
		*/

		balance_rating += n
	balance_rating /= 7
	if(balance_rating < 0.5) balance_rating = 0.5
	return balance_rating

proc/Clamp(n=0,min=0,max=0)
	if(n>max) n=max
	if(n<min) n=min
	return n
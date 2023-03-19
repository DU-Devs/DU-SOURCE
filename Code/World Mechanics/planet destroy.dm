var
	planet_destroy_immunity_time=6 //hours before a planet can be destroyed again
	planet_destroy_bp_requirement=50 //% of strongest online player's bp needed to blow up planet
	planet_destroy_cooldown=2 //hours
	list
		planets=new
		destroyed_planets=new
		destroyable_planets=list("Android","Arconia","Atlantis","Braal","Desert","Earth","Ice",\
		"Jungle","Puranto") //also contains when the planet was last destroyed
		planet_destroy_uses=new //a list of CIDs that used planet destroy and when they used it

mob/Admin3/verb/Restore_planet()
	set category="Admin"
	if(!destroyed_planets.len)
		src<<"There are no destroyed planets currently"
		return
	var/list/L=list("Cancel","All planets")
	for(var/v in destroyed_planets) L+=v
	var/planet=input(src,"Which planet to restore?") in L
	if(planet=="Cancel") return
	Log(src,"[src] restored planet [planet]")
	if(planet=="All planets") restore_all_planets()
	else restore_planet(planet)

mob/var/
obj/Planet_Destroy
	Skill=1
	Teach_Timer=5
	student_point_cost = 50
	hotbar_type="Blast"
	can_hotbar=1
	Cost_To_Learn=57
	var/tmp/prompt=0
	New()
		desc="This will destroy an entire planet but there are some restrictions, a planet can only be \
		destroyed once per [planet_destroy_immunity_time] hours, and you must have at least \
		[planet_destroy_bp_requirement]% of the BP of the strongest player online."
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Planet_Destroy()
	verb/Planet_Destroy()
		set category="Skills"
		if(!usr.can_planet_destroy()) return
		prompt=1-prompt
		if(!prompt) return
		var/check=input("Destroy the planet?") in list("No","Yes")
		switch(check)
			if("Yes")
				if(!prompt||prompt>1) return
				if(!usr.can_planet_destroy()) return
				if(!usr.client) return
				var/area/the_area=locate(/area) in range(0,usr)
				if(!the_area.can_planet_destroy)
					alert("This is not a planet that can be destroyed")
					return
				if(!usr.can_planet_destroy()) return
				planet_destroy_uses[usr.client.computer_id]=world.realtime
				player_view(10,usr)<<sound('basicbeam_charge.ogg',volume=40)
				var/image/A=image(icon='14.dmi',pixel_y=32)
				usr.overlays+=A
				sleep(70*usr.Speed_delay_mult(severity=0.3))
				player_view(10,usr)<<sound('basicbeam_fire.ogg',volume=20)
				usr.overlays-=A
				var/obj/Blast/B=new(usr.loc)
				B.icon='14.dmi'
				B.step_size = 8
				walk(B, SOUTH, 0, B.step_size)
				sleep(25)
				if(!B)
					if(usr.client) planet_destroy_uses-=usr.client.computer_id
					return
				player_view(center=B)<<sound('Explosion 2.wav')
				BigCrater(B.loc)
				del(B)

				if(usr.key)
					Apply_Bounty(price=12000000*Resource_Multiplier,bounty_note="[usr], for destroying [the_area]",the_key=usr.key,\
					maker="The prison")
				prompt=1-prompt
				spawn destroy_planet(the_area.name,usr.BP)
			if("No")
				prompt=1-prompt


var/list/lightning_cache=new

proc/Get_lightning_strike()
	var/obj/Lightning_Strike/ls
	for(var/obj/o in lightning_cache) ls=o
	if(!ls) ls=new/obj/Lightning_Strike
	ls.Lightning_strike()
	lightning_cache-=ls
	return ls

obj/Lightning_Strike
	Savable=0
	proc/Lightning_strike()
		set waitfor=0
		sleep(1)
		for(var/v in 1 to 600)
			var/turf/t=Get_step(src,SOUTH)
			if(t) SafeTeleport(t)
			else break
			sleep(1)
		del(src)
	New()
		var/image/A=image(icon='Lightning Strike.dmi',icon_state="Front",layer=99)
		var/image/B=image(icon='Lightning Strike.dmi',pixel_y=32,layer=99)
		var/image/C=image(icon='Lightning Strike.dmi',pixel_y=64,layer=99)
		var/image/D=image(icon='Lightning Strike.dmi',pixel_y=96,icon_state="End",layer=99)
		overlays.Add(A,B,C,D)
	Del()
		SafeTeleport(null)
		lightning_cache+=src

mob/proc/can_planet_destroy()
	var/area/a=locate(/area) in range(0,src)
	if(!a) return
	if(alignment_on&&alignment=="Good")
		src<<"Good people can not use planet destroy"
		return
	/*if(client&&planet_destroy_uses[client.computer_id])
		var/last_use=planet_destroy_uses[client.computer_id]
		var/next_use=last_use+planet_destroy_cooldown*60*60*10
		if(world.realtime<next_use)
			var/time_remaining=(next_use-world.realtime)/10/60/60
			src<<"There is a [planet_destroy_cooldown] hour cooldown on this ability. You must wait another \
			[round(time_remaining,0.1)] hours."
			return*/
	var/highest_bp=0
	for(var/mob/m in players) if((m.base_bp+m.hbtc_bp)/m.bp_mod>highest_bp)
		highest_bp=(m.base_bp+m.hbtc_bp)/m.bp_mod
	if(sagas&&villain!=key) if((base_bp+hbtc_bp)/bp_mod<highest_bp*(planet_destroy_bp_requirement/100))
		src<<"You need more base BP than you currently have to be allowed to blow up a planet due to this \
		server's planet destroy restrictions."
		return
	if(BP<500000)
		src<<"People below 500'000 BP aren't able to blow up planets"
		return
	if(!(a.name in destroyable_planets))
		src<<"This is not a destructable planet"
		return
	if(a.name in destroyed_planets)
		src<<"This planet is already destroyed"
		return
	if(destroyable_planets[a.name])
		var/last_destroyed=destroyable_planets[a.name]
		var/next_destroyed=last_destroyed+(planet_destroy_immunity_time*60*60*10)
		if(world.realtime<next_destroyed)
			var/time_remaining=(next_destroyed-world.realtime)/10/60/60
			src<<"A planet can only be destroyed once per [planet_destroy_immunity_time] hours. There is \
			still [round(time_remaining,0.1)] hours left before it can be destroyed again."
			return
	return 1

var/list/disabled_planets=new
mob/Admin4/verb/Disable_planet()
	set category="Admin"
	switch(alert(src,"Enable or disable a planet?","Options","Disable","Enable","Cancel"))
		if("Cancel") return
		if("Disable")
			while(src)
				var/list/L=list("Cancel")
				for(var/obj/Planets/p in planets) if(p.type!=/obj/Planets&&!(p.name in L)&&!(p.name in disabled_planets)) L+=p
				var/obj/Planets/p=input(src,"Disable which planet?") in L
				if(!p||p=="Cancel") return
				disabled_planets+=p.name
				world<<"<font color=cyan>Planet [p] was disabled by admins"
				hide_destroyed_planets()
				sleep(1)
		if("Enable")
			while(src)
				var/list/L=list("Cancel")
				for(var/v in disabled_planets) L+=v
				var/p=input(src,"Enable which planet?") in L
				if(!p||p=="Cancel") return
				disabled_planets-=p
				world<<"<font color=cyan>Planet [p] was enabled by admins"
				unhide_restored_planets()
				sleep(1)

proc/hide_destroyed_planets(planet)
	for(var/obj/Planets/p in planets) if((!planet||p.name==planet)&&p.z&&((p.name in destroyed_planets)||(p.name in disabled_planets)))
		p.planet_turf=p.loc
		p.SafeTeleport(null)

proc/unhide_restored_planets(planet)
	for(var/obj/Planets/p in planets)
		if((!planet||p.name==planet)&&!p.z&&!(p.name in destroyed_planets)&&p.planet_turf&&!(p.name in disabled_planets))
			p.SafeTeleport(p.planet_turf)
			p.planet_turf=null

proc/destroy_planet(planet,power=1)

	/*for(var/p in destroyable_planets)
		var/time_add=40*60*10
		if(!destroyable_planets[p]) destroyable_planets[p]=world.realtime+time_add
		else if(destroyable_planets[p]+planet_destroy_immunity_time*60*60*10<world.realtime)
			destroyable_planets[p]=world.realtime+time_add*/

	destroyed_planets+=planet

	if(planet=="Braal")
		destroyed_planets-="Atlantis"
		destroyed_planets+="Atlantis"
	if(planet=="Atlantis")
		destroyed_planets-="Braal"
		destroyed_planets+="Braal"

	destroyable_planets[planet]=world.realtime

	var/area/a
	for(a) if(a.name==planet) break

	for(var/mob/m in players) if(m.get_area()==a)
		m<<"<font color=red>The planet is breaking apart all around you!!"

	//make shockwaves around all players
	spawn for(var/v in 1 to 300)
		for(var/mob/m in players) if(m.get_area()==a&&prob(30))
			var/list/L=new
			for(var/turf/t in view(15,m)) L+=t
			if(L.len)
				var/turf/t=pick(L)
				player_view(10,t)<<sound('kiplosion.ogg',volume=40)
				Make_Shockwave(t,sw_icon_size=pick(64,128,256,512))
		sleep(5)

	//screen shaking
	spawn for(var/v in 1 to 300)
		for(var/mob/m in players) if(m.get_area()==a&&prob(30))
			m.ScreenShake(10,8)
		sleep(10)

	//rising rocks
	spawn for(var/v in 1 to 300)
		for(var/mob/m in players) if(m.get_area()==a)
			var/list/L=new
			for(var/turf/t in view(15,m)) L+=t
			if(L.len)
				while(prob(70))
					var/turf/t=pick(L)
					var/image/I=image(icon='Weather.dmi',icon_state="Rising Rocks",pixel_x=rand(-32,32),pixel_y=rand(-32,32))
					t.overlays+=I
					spawn(rand(0,1200)) t.overlays-=I
		sleep(10)

	//lightning strikes
	spawn for(var/v in 1 to 300)
		for(var/mob/m in players) if(m.get_area()==a&&prob(20))
			var/obj/Lightning_Strike/ls=Get_lightning_strike()
			ls.SafeTeleport(m.loc)
			ls.x+=rand(-15,15)
			var/y_adj=world.maxy-m.y
			if(y_adj>17) y_adj=17
			ls.y+=y_adj
		sleep(5)

	//deadly explosions
	spawn for(var/v in 1 to 300)
		for(var/mob/m in players) if(m.get_area()==a&&prob(10))
			var/list/L=new
			for(var/turf/t in view(10,m)) L+=t
			if(L.len)
				var/turf/t=pick(L)
				Explosion_Graphics(t,rand(2,5))
				for(var/mob/m2 in view(2,t))
					var/KB=5*(power/m2.BP)
					if(KB<0) KB=0
					if(KB>10) KB=10
					KB=round(KB)
					m2.Shockwave_Knockback(KB,m2.loc)
					var/dmg = 50*(power/m2.BP)
					m2.TakeDamage(dmg)
					if(m2.Health<=0) m2.Death("random explosion!")
				spawn for(var/turf/TT in view(3,t)) if(TT.Health<power)
					TT.Health=0
					TT.Destroy()
					sleep(TickMult(0.5))
		sleep(5)

	sleep(900)

	for(var/mob/m in players) spawn if(m&&m.get_area()==a)
		var/list/L=new
		for(var/turf/t in view(10,m)) L+=t
		if(L.len)
			var/turf/t1=pick(L)
			for(var/turf/t in view(20,t1))
				var/image/i=image(icon='Misc.dmi',icon_state=get_space_state(),layer=MOB_LAYER-0.1)
				t.overlays+=i
				spawn(rand(200,1200)) t.overlays-=i
				if(prob(5)) sleep(1)

	sleep(60)

	for(var/mob/m in players) if(m.get_area() == a)
		m<<"<font color=red>The planet was destroyed, you are now in space"
		m.SafeTeleport(m.x, m.y, 16)

	hide_destroyed_planets(planet)

proc/restore_planet(planet)
	destroyed_planets-=planet
	unhide_restored_planets(planet)
	if(planet=="Braal"&&("Atlantis" in destroyed_planets)) restore_planet("Atlantis")
	if(planet=="Atlantis"&&("Braal" in destroyed_planets)) restore_planet("Braal")

proc/restore_all_planets()
	for(var/v in destroyed_planets)
		spawn restore_planet(v)

atom/proc/is_on_destroyed_planet()
	var/area/a
	if(ismob(src))
		var/mob/m=src
		a=m.current_area
	else a=locate(/area) in range(0,src)
	if(!a) return
	if(a.name in disabled_planets) return 1
	if(a.name in destroyed_planets)
		var/obj/Planets/p
		for(p in planets) if(p.z&&p.name==a.name) break
		if(!p) return 1 //planet not found, planet totally destroyed, cannot stay here.

mob/proc/logged_in_on_destroyed_planet_check() if(is_on_destroyed_planet())
	src<<"You logged in on a destroyed planet, you have been sent to space"
	SafeTeleport(x, y, 16)

proc/Ship_on_destroyed_planet_loop()
	set waitfor=0
	while(1)
		for(var/obj/Ships/Ship/s in ships) if(s.is_on_destroyed_planet()) s.z=16
		sleep(600)
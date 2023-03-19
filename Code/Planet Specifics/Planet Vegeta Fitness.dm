var/obj/Planet_Braal_Fitness_Objects/Lord_Freeza/lord_freeza_obj

mob/proc
	FreezaRunnerCowardKill()
		set waitfor=0
		if(!Being_chased()) return
		if(world.time - last_chase_from_outside_gym < 80 && world.time - last_kill_from_freeza_for_cowardice > 200)
			if(get_dir(lord_freeza_obj,src) == NORTHWEST)
				if(viewable(src,lord_freeza_obj))
					last_chase_from_outside_gym=world.time + 3000 //to prevent freeza from spam death balling (theoretically)
					last_kill_from_freeza_for_cowardice=world.time
					lord_freeza_obj.Lord_Freeza_kill_someone(src,msg="Your cowardice is offensive. Let that be a lesson to you other monkeys not to show weakness while in my presence.")

obj
	Planet_Braal_Fitness_Objects

		New()
			. = ..()
			spawn(2) del(src)

		can_change_icon=0
		can_be_renamed=0
		Nukable=0
		Health=1.#INF
		BP=1.#INF
		Dead_Zone_Immune=1
		Cloakable=0
		can_blueprint=0
		Grabbable=0
		Bolted=1
		can_scrap=0
		Knockable=0
		Can_Move=0
		Savable=0
		Makeable=0
		Givable=0

		Stereo
			icon='Stereo.dmi'
			density=1

		Planet_Braal_Fitness_Poster_1
			icon='sexy freeza.png'
			desc="Lord Freeza displaying his astonishing sexyness"
		Planet_Braal_Fitness_Poster_2
			icon='Cosplay fail group.png'
			desc="ACCURATE PORTRAYAL OF THOSE STUPID FUCKING EARTHLINGS WHO ARE ALWAYS RUINING MY PLANS"
		Planet_Braal_Fitness_Poster_3
			icon='Freeza OneyNG.png'
			desc="Uhh"
		Planet_Braal_Fitness_Poster_4
			icon='Freeza cosplay fail.png'
			desc="Me at my ONE-HUNDRED-PERCENT MAXIMUM POWER. Ahahahaha!"
		Lord_Freezas_Monkey_Death_Trap_Emporium
			icon='Lord Freezas Monkey Death Trap Emporium.png'
			desc="Totally not a death trap to kill filthy monkey scum. COME ON IN!"
		Planet_Braal_Fitness_Logo
			icon='planet vegeta fitness logo.png'

		Lord_Freeza_Death_Ball_Graphic
			icon='Ball - Supernova.dmi'
			New()
				CenterIcon(src)
				. = ..()

		Lord_Freeza
			//icon='Freeza icon.dmi'
			icon = 'Gold Icer.dmi'
			density=1
			dir=SOUTH
			var/last_nuke=0
			var/list/possible_things_to_say=list(\
			"Welcome filthy monkeys to Lord Freeza's Monkey Death Tra- I mean Planet Braal Fitness",\

			"If you train here, perhaps you can one day match me, Lord Freeza",\

			"FILTHY MONKEYS YOU'LL ALL DIE- from hunger! If you don't eat our free pizza provided at the front desk!",\

			"*mumbles* Filthy monkeys uahahaha...final form...100% MAXIMUM... POWER!!!...",\

			"*whispers into scouter-like device* Zarbon, execute Order 66",\

			"You know, monkey scum like yourselves may smell bad, and be utter morons, and very stubborn, but I really have nothing \
			against them. Haha, totally.",\

			"I knew you worthless monkeys would love me if I put a free training gym on your planet, and don't worry your pretty \
			little heads, it is completely safe. Heh heh heh...",\

			"Come now, the past is the past, don't be angry. I may have exterminated your entire race before, but now I'm your friend, \
			Yasai scum",\
			)
			var/freeza_text_color
			New()
				spawn(10) if(z) lord_freeza_obj=src
				freeza_text_color=rgb(204,0,204)
				//if(z) Lord_Freeza_loop()
				SafeTeleport(null)
				. = ..()

			proc/Lord_Freeza_kill_someone(mob/m,msg)
				set waitfor=0
				if(!m || m.is_saitama) return
				player_view(44,src)<<"<font size=3><font color=[freeza_text_color]>[name] says: DIE FILTHY MONKEY!!!"
				var/death_ball_idle_timer=25
				spawn if(m) Death_ball_kill(m,idle_timer=death_ball_idle_timer)
				sleep(death_ball_idle_timer)
				player_view(44,src)<<"<font size=3><font color=[freeza_text_color]>[name] says: DEATH BALL!!!"
				sleep(40)
				if(!msg)
					player_view(44,src)<<"<font size=3><font color=[freeza_text_color]>[name] says: Filthy monkey scum, if anyone is going to do \
					the killing here, it's ME!"
				else player_view(44,src)<<"<font size=3><font color=[freeza_text_color]>[name] says: [msg]"

			proc/Death_ball_kill(mob/m,idle_timer=40)
				player_view(44,src)<<sound('basicbeam_charge.ogg',volume=20)
				var/obj/death_ball=new/obj/Planet_Braal_Fitness_Objects/Lord_Freeza_Death_Ball_Graphic(loc)
				sleep(idle_timer)
				player_view(44,usr)<<sound('basicbeam_fire.ogg',volume=15)
				for(var/v in 1 to 150)
					if(!m || m.z!=z) break
					else
						var/turf/t=get_step(death_ball,get_dir(death_ball,m))
						death_ball.SafeTeleport(t)
						if(t==m.loc)
							Explosion_Graphics(t,5)
							spawn(4) if(m) m.Death("Lord Freeza",Force_Death=1,lose_hero=0,lose_immortality=0)
							break
					if(prob(80)) sleep(world.tick_lag)
				if(death_ball) del(death_ball)

			proc/Lord_Freeza_loop()
				set waitfor=0
				/*
				var/speak_index=0
				while(src)
					var/timer=8*600

					var/list/nearby_players = player_view(44,src)
					if(nearby_players && nearby_players.len>=7 && prob(30))
						var/mob/m=nearby_players[rand(1,nearby_players.len)]
						if(m && ismob(m) && m.client)
							player_view(44,src)<<"<font size=3><font color=[freeza_text_color]>[name] says: Hmmm quite a few dirty monkeys around here hm? \
							Maybe no one will notice if I pick one off"
							sleep(30)
							player_view(44,src)<<"<font size=3><font color=[freeza_text_color]>[name] says: EENEY"
							sleep(30)
							player_view(44,src)<<"<font size=3><font color=[freeza_text_color]>[name] says: MEANEY"
							sleep(30)
							player_view(44,src)<<"<font size=3><font color=[freeza_text_color]>[name] says: MINEY"
							var/db_timer=30
							spawn if(m) Death_ball_kill(m,db_timer)
							sleep(db_timer)
							player_view(44,src)<<"<font size=3><font color=[freeza_text_color]>[name] says: MOE"

					//else if(world.time-last_nuke>2*60*600)
					//	Lord_Freeza_nuke()
					else
						speak_index++
						if(speak_index>possible_things_to_say.len) speak_index=1
						var/say_text=possible_things_to_say[speak_index]
						player_view(44,src)<<"<font size=3><font color=[freeza_text_color]>[name] says: [say_text]"
					sleep(timer)
					*/


			proc/Lord_Freeza_nuke()
				last_nuke=world.time
				player_view(44,src)<<"<font size=3><font color=[rgb(51,204,51)]>Zarbon says: Lord Freeza order 66 is ready sire...Awaiting your order"
				sleep(30)
				player_view(44,src)<<"<font size=3><font color=[freeza_text_color]>[name] says: Good Zarbon, i'll arrive back on the ship momentarily"
				sleep(30)
				player_view(44,src)<<"<font size=3><font color=[freeza_text_color]>[name] says: ALLAHU AKBAR!!!"
				if(loc && isturf(loc)) Freeza_detonate(Avg_BP*99,loc,40)

proc/Freeza_detonate(nuke_bp=0,turf/origin,range=30)
	origin=origin.base_loc()
	for(var/r in 0 to range)
		var/list/turf_list=new
		for(var/v in -r to r)
			turf_list+=locate(origin.x+v,origin.y-r,origin.z)
			turf_list+=locate(origin.x+v,origin.y+r,origin.z)
			if(!(v in list(-r,r)))
				turf_list+=locate(origin.x-r,origin.y+v,origin.z)
				turf_list+=locate(origin.x+r,origin.y+v,origin.z)
		for(var/turf/t in turf_list)
			if(viewable(t,origin,20))
				spawn for(var/v in 1 to 4)
					for(var/mob/m in t) if(m.z)
						var/really_dead
						if(nuke_bp>m.BP*sqrt(m.Regenerate)) really_dead=1
						var/dmg = ((1.5*nuke_bp/Turf_Strength) / m.BP)**2 * 34
						if(!m.client) dmg*=999
						m.TakeDamage(dmg)
						if(m.Health<=0)
							m.Death("nuclear explosion",really_dead,lose_hero=0,lose_immortality=0)
						sleep(rand(3,5))
				if(prob(8)) t.TempTurfOverlay(nuke_icon,35)
		sleep(TickMult(1 + ToOne(r/80)))
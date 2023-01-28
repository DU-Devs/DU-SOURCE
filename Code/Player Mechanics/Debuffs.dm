/*
the teamer system half the time marks the person defending themself and 1 of the attackers as teamers together,
leaving 1 of the actual teamers at full power, but the defender and the other attacker weakened
	so maybe that has something to do with if both targets are in the attackee list already then
	maybe it needs to have some exception

current teaming effects:
	0.75x health regen
	0.75x energy recov
	take 1.2x more damage
	do 1.2x less damage
	1.2x less accuracy
	1.2x less dodging
*/
mob/var/tmp/is_kiting
var/kiting_penalty=0.34
mob/proc
	Check_if_kiting(turf/old_loc)
		if(!client) return //npcs can not become kiters
		if(!Opponent||!Opponent.client||Opponent.KO||Opponent.z!=z||getdist(src,Opponent)<=4||\
		getdist(src,Opponent)>=55||Opponent.get_area()!=get_area())
			Reset_kiting()
			return
		if(old_loc&&getdist(old_loc,Opponent)>=getdist(src,Opponent))
			Reset_kiting()
			return
		if(is_kiting) return
		if(old_loc) //signifies this proc was called from zanzoken
			is_kiting=1
			//Tens("<font color=red>[src] is now kiting [Opponent]")
	Reset_kiting()
		if(!is_kiting) return
		is_kiting=0
		//Tens("<font color=cyan>[src] is no longer kiting")




mob/var/tmp
	is_teamer
	teamer_loop_running
	backlog_loop_running

	//this is a list of who you attacked and HOW LONG AGO you attacked them
	list/recent_attackees=new

	//this list stores a list of mobs you recently attacked and how many times you attacked them, so that it
	//can compare who you are attacking most often out of those choices and extrapolate that is who your fighting
	list/attack_backlog=new

	list/first_attack_times=new

	//this is different from attack backlog because this stores information about each individual hit and what time it happened
	//when attack_backlog was made, there was no need to keep track of this, so all it did was keep track of total hits
	list/attack_log=new
	good_attack_good_time=0

mob/proc
	Good_teaming_with_evil_check()

		return

		if(alignment_on&&alignment=="Good")
			if(Opponent&&Opponent!=src&&Opponent.client&&ismob(Opponent)&&getdist(src,Opponent)<=10&&client)
				for(var/mob/m in player_view(25,src)) if(m.client)
					if(m.alignment=="Evil"&&m!=Opponent&&m!=src&&m.Opponent==Opponent)
						if(Extrapolated_target_is(Opponent)&&m.Extrapolated_target_is(Opponent))
							if(Most_recent_attack_time(m,Opponent)<=50)
								player_view(src,15)<<"<font color=red>[src] has been marked as evil for helping an evil person fight against \
								another good person"
								good_attack_good_time=world.time
								next_alignment_change=world.realtime+(3*60*60*10)
								ChangeAlignment("Evil")
								Evil_overlay()
	Most_recent_attack_time(mob/a,mob/d)
		if(!a.key||!d.key) return 9999
		if(!(d.key in a.attack_log)) return 9999
		var/list/attack_times=a.attack_log[d.key]
		return world.time-attack_times[1]
	Log_attack(mob/t)
		if(!t.client||!client) return
		if(!(t.key in attack_log))
			attack_log.Insert(1,t.key)
			attack_log[t.key]=new/list
		var/list/entries=attack_log[t.key]
		entries.Insert(1,world.time)
		if(entries.len>20) entries.len=20
		attack_log[t.key]=entries
		if(attack_log.len>20) attack_log.len=20

	Good_attacking_good_against_their_will(mob/t)
		if(!t||!ismob(t)||!alignment_on||alignment=="Evil"||t.alignment=="Evil") return
		if(t.locz()!=locz()||getdist(src,t)>25) return
		if(!t.client||!client) return
		if(!(t.key in stop_messages)) return
		if(world.time-stop_messages[t.key]>450) return
		if(!(t.key in attack_log)) return
		var/hit_list=attack_log[t.key]
		var/hits=0
		var/stop_message_seconds_ago=world.time-stop_messages[t.key]
		for(var/hit_time in hit_list) if(world.time-hit_time<stop_message_seconds_ago) hits++
		if(hits>=4)
			player_view(src,15)<<"<font color=red>[src] has been marked as evil for attacking another good person against \
			their will after they were told to stop"
			good_attack_good_time=world.time
			next_alignment_change=world.realtime+(3*60*60*10)
			ChangeAlignment("Evil")
			Evil_overlay()

	Good_attack_good_loop()
		set waitfor=0
		while(src)
			if(Opponent(65) && Opponent!=src) Opponent.Good_attacking_good_against_their_will(src)
			if(!client) sleep(600)
			else sleep(30)

	Good_attacking_good()
		if(!good_attack_good_time) return
		if(world.time-good_attack_good_time<900) return 1

	Extrapolated_target_is(mob/m,hit_req=5,min_time=60,max_time=360)
		var/t
		var/most_hits_found=0
		for(var/id in attack_backlog)
			var/hits=attack_backlog[id]
			if(hits>=hit_req && hits>most_hits_found)
				if(id in first_attack_times)
					if(world.time>first_attack_times[id]+min_time)
						if(id in recent_attackees)
							if(world.time<recent_attackees[id]+max_time)
								for(var/mob/a in player_view(35,src))
									if(id=="[a.Mob_ID]")
										most_hits_found=hits
										t=id
		if(t=="[m.Mob_ID]")
			return 1

	Clear_backlog_loop()
		set waitfor=0
		if(backlog_loop_running) return
		backlog_loop_running=1
		while(src)

			for(var/id in attack_backlog)
				if(!(id in recent_attackees)) attack_backlog-=id
				else if(world.time>recent_attackees[id]+900) attack_backlog-=id

			for(var/id in first_attack_times)
				if(!(id in recent_attackees)) first_attack_times-=id
				else if(world.time>recent_attackees[id]+1800) first_attack_times-=id

			if(!attack_backlog.len&&!first_attack_times.len) break
			else sleep(60)
		backlog_loop_running=0




	Check_if_being_teamed(mob/a) //src = person being attacked. a = attacker
		if(!a || !a.client || !client || is_teamer) return
		var/list/attackers=new
		for(var/mob/m in player_view(23,src))
			if(m.client && m!=src && !m.KO && m.z==z && m.Extrapolated_target_is(src,hit_req=8,min_time=55,max_time=350))
				attackers+=m
		if(attackers.len<2) return
		for(var/mob/m in attackers)
			//if(!m.is_teamer) Tens("<font color=cyan>[m] is now a teamer for attacking [src]")
			m.is_teamer=1
			m.Teamer_loop()





	Set_possible_teamer_list(mob/M) //M is the attacker. called in setOpponent()
		if(M&&M.client&&client)

			//attack backlog counts hits - i think
			if(!("[Mob_ID]" in M.attack_backlog))
				M.attack_backlog.Insert(1,"[Mob_ID]")
				M.attack_backlog["[Mob_ID]"]=0
			M.attack_backlog["[Mob_ID]"]++
			if(M.attack_backlog.len>4) M.attack_backlog.len=4

			if(!M.recent_attackees) M.recent_attackees=new/list //wierd "bad list" runtime error fix
			if(!("[Mob_ID]" in M.recent_attackees)) M.recent_attackees.Insert(1,"[Mob_ID]")
			M.recent_attackees["[Mob_ID]"]=world.time
			if(M.recent_attackees.len>5) M.recent_attackees.len=5

			if(!("[Mob_ID]" in M.first_attack_times))
				M.first_attack_times.Insert(1,"[Mob_ID]")
				M.first_attack_times["[Mob_ID]"]=world.time
			if(M.first_attack_times.len>4) M.first_attack_times.len=4

			M.Clear_backlog_loop()

			return //the code below here is the old teamer checking system, the code above is NEEDED still to create attack backlogs
			if(!M.is_teamer&&M.Is_teaming(src))
				//Tens("<font color=red>[M] is now a teamer for attacking [src] alongside [M.Is_teaming(src)]")
				M.is_teamer=1
				M.Teamer_loop()

	Is_teaming(mob/m,call_is_teaming=1) //src = attacker, m = person being attacked
		if(m.is_teamer||m==src||m.KO) return //cant team a teamer, cant team yourself
		if(!Extrapolated_target_is(m)) return
		for(var/mob/m_attacker in player_view(20,src)) //m_attacker = other people attacking "m"
			if(m_attacker!=m&&m_attacker!=src&&(m_attacker.stand_still_time()<=50||m_attacker.attacking))
				if("[m.Mob_ID]" in m_attacker.recent_attackees)
					if(world.time<m_attacker.recent_attackees["[m.Mob_ID]"]+90)
						if(!call_is_teaming||m_attacker.Is_teaming(src,call_is_teaming=0)) //if the person who attacked them is also attacking me then i cant be
						//teaming with the person trying to kill me too.
							if(!(get_dir(m,src) in list(m.dir,turn(m.dir,45),turn(m.dir,-45)))) //attacks from "behindish" only
								return m_attacker
	Is_teamer()
		var/area/a=get_area()
		if(!a) return
		for(var/mob/m in a.player_list) if(m!=src && m.client && getdist(src,m)<80)
			for(var/id in recent_attackees) if(id!="[m.Mob_ID]")
				if(world.time<recent_attackees[id]+600)
					if(id in m.recent_attackees)
						if(world.time<m.recent_attackees[id]+400)
							return 1
	Teamer_loop()
		set waitfor=0
		if(teamer_loop_running) return
		teamer_loop_running=1
		while(Is_teamer())
			is_teamer=1
			sleep(50)
		is_teamer=0
		//Tens("<font color=cyan>[src] is no longer a teamer")
		teamer_loop_running=0







mob/var
	tmp/fearful
	last_damaged_chaser=0 //seconds ago that you last damaged your chaser
	tmp/mob/chaser //the person chasing the runner
	chaser_key //the chaser mob can be restored using chaser_key if the runner relogs
	tmp/stand_still_time=0 //seconds since person last moved
	//stand still time needs to reset to 0 each Move(), and increment +1 each second somewhere
	tmp/chase_loop_running
	tmp/total_chase_time=0
	tmp/list/recently_feared_players=new
	tmp/is_runner
mob/proc

	Fear_dmg_mult()
		if(is_runner) return 5
		return 5

	Is_runner()

		//good people will not fear other good people
		if(chaser && chaser.client && alignment_on && both_good(src,chaser)) return

		//to fix a bug where supposedly if you are chasing someone and they get in a pod, YOU get fearful of them
		if(chaser.Ship && chaser.loc==chaser.Ship) return

		if(chaser.fearful) return

		if(chaser && !chaser.is_teamer && !chaser.KO && chaser.client && last_damaged_chaser>=8)
			//if you are not heading toward your chaser, or are on a different z plane
			if(!(get_dir(src,chaser) in list(dir,turn(dir,45),turn(dir,-45))) || z!=chaser.z)

				//if the chaser is still chasing you
				var/chaser_still_chasing
				if(get_dir(chaser,src) in list(chaser.dir,turn(chaser.dir,45),turn(chaser.dir,-45)))
					chaser_still_chasing=1
				if(last_cave_entered && (get_dir(chaser,last_cave_entered) in list(chaser.dir,turn(chaser.dir,45),turn(chaser.dir,-45))))
					chaser_still_chasing=1

				if(chaser_still_chasing)
					var/running_into_caves
					if(world.time-last_cave_entered_time<50 && last_cave_entered_time>chaser.last_cave_entered_time)
						running_into_caves=1
					if((getdist(src,chaser)>=25 && !running_into_caves && z==chaser.z) || running_into_caves)
						if(chaser.chaser==src && chaser.fearful)
						else
							if(chaser.Health>Health*0.8 || (chaser.ckey in anger_reasons)) //cant really fear someone who isn't beating you
								//this line is to hopefully prevent fear from kicking in while 2 people are hitting you at once then 1
								//runs off and you get fear somehow due to it
								if(!Opponent(150) || Opponent==chaser || !Opponent.client || getdist(src,Opponent)>25)
									return 1
	Get_chaser_from_key()
		if(chaser_key) for(var/mob/m in players) if(m.key==chaser_key)
			chaser=m
			break

	Set_chaser(mob/m) //m is the attacker
		if(!Chase_over()||KO||m==src) return
		chaser=m
		chaser_key=m.key
		last_damaged_chaser=0
		Chase_loop()

	Chase_loop()
		set waitfor=0

		return

		if(chase_loop_running) return
		chase_loop_running=1
		var/chase_over_count=0
		while(!fearful && chaser)
			last_damaged_chaser++
			//if(KB) last_damaged_chaser=0

			if(Chase_over()) chase_over_count++
			else chase_over_count=0

			if(chase_over_count>=7 || KO || (Chase_over() in list("chaser logged","inactivity","stood still too long",\
			"chaser now attacking someone else")))
				chaser=null
				chaser_key=null
				break

			else if(Is_runner())
				if(stand_still_time()<=65)
					src<<"<font color=red>By attempting to run your character has become fearful of their enemy"

					//Tens("<font color=red>[src] has become fearful of [chaser]")

					fearful=1

					//if you get fear of the same person twice within a short period of time you are probably tag teaming
					//and running off and healing and coming back and being super annoying, so make the penalties harsh
					if(!("[chaser.Mob_ID]" in recently_feared_players))
						recently_feared_players.Insert(1,chaser)
					else
						var/last_fear=recently_feared_players["[chaser.Mob_ID]"]
						if(world.time<last_fear+1200)
							is_runner=1
					recently_feared_players["[chaser.Mob_ID]"]=world.time
					if(recently_feared_players.len>5) recently_feared_players.len=5

				else
					chaser=null
					chaser_key=null
				break
			else sleep(10)
		chase_over_count=0
		while(fearful)
			total_chase_time++

			if(Chase_over()) chase_over_count++
			else chase_over_count=0

			if(total_chase_time>=20) is_runner=1
			if(chase_over_count>=20 || total_chase_time>120 || !chaser || KO || \
			(Chase_over() in list("chaser logged","inactivity","stood still too long",\
			"chaser now attacking someone else","chaser is knocked out")))
				Remove_fear()
				chaser=null
				chaser_key=null
				break
			else sleep(10)
		chase_loop_running=0

	Chase_over()
		if(!chaser) return "chaser logged"
		if(chaser.KO) return "chaser is knocked out"
		if(chaser.stand_still_time()>=100) return "stood still too long"
		if(chaser.client && chaser.client.inactivity>150) return "inactivity"
		if(chaser.z==z && getdist(chaser,src)>200) return "distance very large"
		if(chaser.z==z && getdist(chaser,src)>60 && !(getdir(chaser,src) in list(chaser.dir,turn(chaser.dir,-45),turn(chaser.dir,45))))
			return "going different direction"
		if(!is_runner && !is_teamer && chaser.Opponent(150) && chaser.Opponent!=src && chaser.Opponent.client && chaser.Opponent.Opponent==chaser)
			return "chaser now attacking someone else"
		if(chaser.get_area()!=get_area()) return "different area"

	stand_still_time()
		return world.time-stand_still_time

	Remove_fear() if(fearful)
		src<<"<font color=cyan>Your character is no longer fearful of their enemy"
		fearful=0
		is_runner=0
		total_chase_time=0
		//Tens("<font color=cyan>[src] is no longer fearful")
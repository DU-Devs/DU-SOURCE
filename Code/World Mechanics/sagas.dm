/*
hero gain untap potential faster

if the hero is defeated by the main villain and has less than half the power of the main villain then
the game tells the villain to spare them, and the hero gets accelerated training to match the power
of the main villain. then they fight again a final time.

main hero should be able to give the status away to a person of their choosing

should be able to drop the villain rank
*/

var
	sagas
	hero
	mob/hero_mob
	villain
	killing_spree_min=3
	killing_spree_max=10
	killing_spree_time=15 //minutes
	hero_leechable=0 //in tier mode, the bp a

mob/var
	hero_time=0
	villain_time=0
	showdown_time=30 //minutes the villain has to kill the hero before they lose the title
	training_period=0 //hero gains faster to defeat the villain until this deadline
	good_kills=0 //the villains kill count of good people. used to detect killing sprees
	hero_bp=0 //for tier mode. in training session hero gains hero_bp
	last_threaten=0

	heroes_killed=0
	villains_killed=0

	//players set these to decide if they are eligible to get the rank or not if they dont want it. BY PRESSING ESCAPE
	ignore_hero = 1
	ignore_villain = 1

proc
	find_new_hero(mob/old_hero)
		if(old_hero) old_hero.reset_hero_stuff()
		var/list/l=new
		for(var/mob/m in players) if(m.Hero_eligible() && m.key!=villain)
			if(m!=old_hero&&m.z&&m.client&&m.alignment=="Good"&&!m.Dead)
				l+=m
		if(!l||!l.len) return
		var/mob/m=pick(l)
		if(!m||!ismob(m)) return
		hero=m.key
		if(!m.hero_time) m.hero_time=world.realtime
		//m.training_period=0

	find_new_villain(mob/old_villain,mob/villain_killer)
		if(old_villain) old_villain.reset_villain_stuff()
		var/list/l=new
		for(var/mob/m in players) if(m.Villain_eligible() && m.key!=hero)
			if(m!=old_villain&&m.z&&m.client&&m.alignment=="Evil"&&!m.Dead) l+=m
		if(!l||!l.len) return
		var/mob/m=pick(l)
		if(villain_killer&&ismob(villain_killer)&&villain_killer.client&&villain_killer.alignment=="Evil")
			m=villain_killer
		if(!m||!ismob(m)) return
		villain=m.key
		m.add_villain_verbs()
		if(!m.villain_time) m.villain_time=world.realtime
		if(!m.heroes_killed) m.showdown_time=30
		else m.showdown_time = 180

	hero_online() for(var/mob/m in players) if(m.key && hero==m.key) return m

	villain_online() for(var/mob/m in players) if(m.key && villain==m.key) return m

	sagas_bonus(mob/a,mob/b) //a = attacker. b = defender
		if(!sagas||!ismob(a)||!ismob(b)) return 1
		var/n=1

		if(a.key==hero&&!b.client) n*=2
		if(!a.client&&b.key==hero) n/=2

		if(a.key==villain&&b.key!=hero) n*=1.35 //main villain does more damage against everyone but the hero
		if(b.key==hero&&a.key==villain) n*=0.75 //hero takes less damage from main villain
		else if(a.alignment=="Evil"&&b.key==hero) n*=0.65 //hero takes less damage from normal evil people

		n*=a.Villain_league_damage_multiplier(b)

		return n
mob/proc
	ToggleIgnoreHero()
		ignore_hero = !ignore_hero
		if(ignore_hero)
			src << "You can no longer get the hero rank"
			if(hero == key) find_new_hero(src)
		else
			src << "You can now be randomly chosen for the hero rank if you meet the other requirements (enough power, etc)"

	ToggleIgnoreVillain()
		ignore_villain = !ignore_villain
		if(ignore_villain)
			src << "You can no longer get the villain rank"
			if(villain == key) find_new_villain(src)
		else
			src << "You can now be randomly chosen for the villain rank if you meet the other requirements (enough power, etc)"

	ChangeAlignment(a = "Good")
		if(!(a in list("Good","Evil"))) return
		alignment = a
		if(alignment == "Good" && villain == key) find_new_villain(src)
		if(alignment == "Evil" && hero == key) find_new_hero(src)

	Hero_eligible()
		if(ignore_hero) return
		return 1
		//if(cyber_bp>1) return 1
		//if(base_bp/bp_mod>highest_relative_base_bp*0.4) return 1

	Villain_eligible()
		if(ignore_villain) return
		return 1
		//if(cyber_bp>1) return 1
		//if(base_bp/bp_mod>highest_relative_base_bp*0.4) return 1

	killing_spree_loop()
		good_kills=0
		spawn while(src)
			if(good_kills>killing_spree_min&&villain==key&&sagas)
				world<<"<font color=red>The main villain [src] has begun a killing spree on good people \
				to draw the main hero out of hiding. If the main hero does not respond before the kill \
				count reaches [killing_spree_max] they will be considered either a coward or a failure as \
				a hero for not protecting the innocent, and lose the title. [src] has killed [good_kills] \
				innocents so far."
				sleep(killing_spree_time*60*10)
				good_kills=0
				world<<"<font color=red>The main villain [src]'s killing spree counter has reset to 0 because \
				more than [killing_spree_time] minutes have passed since they started the spree."
			else sleep(100)
		spawn while(src)
			if(good_kills<killing_spree_min)
				good_kills--
				if(good_kills<0) good_kills=0
			sleep(3000)

	villain_timer()
		set waitfor=0
		while(src)
			if(villain==key&&sagas)
				showdown_time--
				if(showdown_time<=0)
					showdown_time=0
					villain_time=0
					find_new_villain(src)

					var/new_vil = villain_online()
					if(src != new_vil)
						world<<"<font color=red>[src] has lost the main villain rank because they did not kill the \
						main hero in the time frame required. [new_vil] is the new villain"
			sleep(600)

	hero_seniority_check()
		if(hero==key || alignment=="Evil") return
		if(!Hero_eligible() && hero) return
		if(hero_online())
			if(!hero_time || !villains_killed || !Hero_eligible()) return
			for(var/mob/m in players)
				if(m.key==hero && m.hero_time<hero_time && m.alignment=="Good" && m.villains_killed>0) return
			var/mob/m=hero_online()
			m.reset_hero_stuff()
			var/hours=(world.realtime-hero_time)/10/60/60
			m<<"<font color=cyan>The main hero [src] from [round(hours)] hours and \
			[round(hours*60 %60)] minutes ago \
			has logged back in. [m] is no longer \
			playing the role of the main hero"
		else world<<"<font color=cyan>[src] has become the main hero because nobody else online has it"
		hero=key
		if(!hero_time) hero_time=world.realtime

	villain_seniority_check()
		if(villain==key||alignment=="Good") return
		if(!Villain_eligible() && villain) return
		if(villain_online())
			if(!villain_time || !heroes_killed) return
			for(var/mob/m in players)
				if(m.key==villain && m.villain_time<villain_time && m.alignment=="Evil" && m.heroes_killed>0) return
			var/mob/m=villain_online()
			m.reset_villain_stuff()
			var/hours=(world.realtime-villain_time)/10/60/60
			m<<"<font color=red>The main villain [src] from [round(hours)] hours and [round(hours*60 %60)] \
			minutes ago \
			has logged back in. [m] is no \
			longer playing the role of the main villain"
		else world<<"<font color=red>[src] has become the main villain because nobody else online has it"
		villain=key
		add_villain_verbs()
		if(!villain_time) villain_time=world.realtime

	hero_death(mob/killer) if(key && hero == key&&sagas)
		if(killer && ismob(killer) && killer.client && killer.key==villain)
			killer.heroes_killed++
			killer.GiveFeat("Kill Hero while you are Villain")
		var/mob/m=villain_online()

		//had to do this to fix a bug where the villain would KO the hero but use a friend or other means to kill the hero
		//thus bypassing the 10x gain training period from even being a possibility
		var/was_fighting_villain
		if(m) for(var/v in m.recent_attackees)
			if(v=="[Mob_ID]")
				var/t=m.recent_attackees[v]
				if(world.time-t<3*60*10)
					was_fighting_villain=1
					break

		if(prob(40)||!m||!was_fighting_villain)
			hero_time=0
			find_new_hero(src)
			world<<"<font color=cyan>[src] lost main hero status due to dying. [hero_online()] is the \
			new main hero"
			training_period=0
			if(ismob(killer) && killer==m)
				killer<<"<font color=red>Your time as the villain has been extended for successfully killing \
				the hero"
				killer.showdown_time=180
		else
			if(hero_training_gives_tier)
				world<<"<font color=cyan>The hero [src] has gained +1 tier to defeat the villain [m]"
				bp_tier++
				m<<"<font color=red>Your time as the villain has been restored"
				FullHeal()
			else if(0) //disabled
				training_period = world.realtime + (20 * 60 * 10)
				world<<"<font color=cyan>The main hero [src] has went into a training period to defeat the main \
				villain [m]. Whoever decides to train them will also get accelerated gains (ranked people that \
				means you)"
				m<<"<font color=red>Your time as the villain has been extended for successfully killing the \
				hero. But the hero is now in a training period to make a come back. If you attack them in the \
				next 30 minutes you will lose your villain rank. If they attack you first then you will not \
				lose the rank."
			if(!m.heroes_killed) m.showdown_time=30
			else m.showdown_time=180

	villain_death(mob/m) if(key && villain==key && sagas)
		villain_time=0
		if(m && ismob(m) && m.client && m.key==hero)
			m.villains_killed++
			m.GiveFeat("Kill Villain while you are Hero")
		find_new_villain(src,m)
		world<<"<font color=red>The main villain [src] was killed, the title of main villain has \
		gone to [villain_online()]"

	reset_hero_stuff()
		//hero_time=0
		//training_period=0

	reset_villain_stuff()
		//villain_time=0
		//showdown_time=0
		remove_villain_verbs()

	remove_villain_verbs()
		verbs-=typesof(/mob/villain/verb)

	add_villain_verbs()
		remove_villain_verbs()
		verbs+=typesof(/mob/villain/verb)

	training_period(mob/d) //d = defender. src = attacker
		if(!sagas||!ismob(d)) return
		if(villain==key&&d.key==hero&&world.realtime<d.training_period)
			find_new_villain(src)
			world<<"<font color=red>The main villain [key] has lost the villain rank for attacking the \
			main hero during their special training period. The new villain is [villain_online()]"
		if(hero==key&&d.key==villain&&world.realtime<training_period)
			training_period=0
			world<<"<font color=cyan>The hero's special training session has ended because they attacked the \
			main villain."

	can_threaten()
		if(world.realtime<last_threaten+(threat_timer*60*10))
			var/t=last_threaten+(threat_timer*60*10)-world.realtime
			t/=10*60
			t=round(t,0.1)
			src<<"You can not issue another threat to the hero for another [t] minutes"
			return
		return 1
var
	threat_timer=45 //how often the villain can issue threats after issuing one before, in minutes
	hero_response_time_left=0 //how many minutes the hero has to respond to the threat issued
mob/villain/verb
	Threaten_Hero()
		set category="Skills"
		var/mob/m=hero_online()
		if(!m)
			src<<"You can not issue a threat right now because there is no hero online"
			return
		if(!can_threaten()) return
		if(world.realtime<m.training_period)
			src<<"You can issue threats while the hero is in a training period"
			return
		var/list/L=list("Cancel","Mass killing","Blow up this planet")
		var/choice=input(src,"You can use this to threaten the hero with something that a true hero MUST \
		respond to. If they do not respond to it then they will lose their rank for being a coward.") in L
		if(!can_threaten()) return
		switch(choice)
			if("Cancel") return
			if("Mass killing")
				if(!can_threaten()) return
				world<<"<font color=red>The main villain [src] is now mass killing to force the hero [hero_online()] out \
				of hiding. If the hero does not respond before the kill count reaches 10 they will lose the rank for \
				being a coward"
			if("Blow up this planet")
				if(!can_threaten()) return
				var/area/a=get_area()
				if(!a.can_planet_destroy)
					src<<"This planet is indestructable, go to another and try again"
					return
				world<<"<font color=red>The main villain [src] will blow up [a] in 15 minutes to force the hero \
				[hero_online()] out of hiding. If the hero does not respond in time they will lose the rank for being a \
				coward"
		last_threaten=world.realtime
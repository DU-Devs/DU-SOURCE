var
	godMasteryToTrainOutsideGodRealm = 25
	godKiMasteryMod = 1

proc
	GodKiRealmKillLoop()
		set waitfor=0
		while(1)
			for(var/mob/m in players)
				m.GodKiRealmDeathCheck()
				sleep(20)
			sleep(40)

mob/proc
	LeechGodKi(mob/m)
		if(!m || !m.client || !m.has_god_ki || m.god_ki_mastery < god_ki_mastery) return
		if(!HasGodKiBPReq()) return

		var/a = (m.god_ki_mastery - god_ki_mastery) / 15000
		god_ki_mastery += a
		if(god_ki_mastery > m.god_ki_mastery) god_ki_mastery = m.god_ki_mastery
		RaiseGodKi(0)

	GodKiRealmDeathCheck()
		if(!InGodKiRealm()) return
		if(!HasGodKiBPReq())
			BloodEffectsWaitForZero()
			Death("god ki overload!",Force_Death=1,drone_sd=0,lose_hero=0,lose_immortality=0)
			return 1

	GodKiRealmGains(n=1)
		set waitfor=0
		if(!InGodKiRealm() && god_ki_mastery < godMasteryToTrainOutsideGodRealm) return
		var/result = GodKiRealmDeathCheck()
		if(result) return
		//var/mod = (100 - god_ki_mastery) / 15000
		var/adjMastery = god_ki_mastery
		if(adjMastery < 1) adjMastery = 1
		var/mod = (20 / adjMastery) ** 1
		if(mod > 1) mod = 1
		if(mod < 0.1) mod = 0.1 //they have to be allowed to reach 100 at some point
		n *= mod / 333
		n *= godKiMasteryMod
		var/godKiBefore = god_ki_mastery
		RaiseGodKi(n)
		if(godKiBefore < godMasteryToTrainOutsideGodRealm && god_ki_mastery >= godMasteryToTrainOutsideGodRealm)
			alert(src, "You have mastered god ki enough that you no longer need to be in the God Ki Realm to master it. You can master it with \
			normal training anywhere.")

atom/movable/proc
	InGodKiRealm()
		var/area/a = get_area()
		if(a && a.type == /area/God_Ki_Realm) return 1

obj/God_Realm_Portal
	icon='Blue Orb 96x96.dmi'
	Grabbable=0
	Health=1.#INF
	Savable=0
	density=1
	Dead_Zone_Immune=1
	Bolted=1
	Knockable=0

	New()
		CenterIcon(src)
		GodRealmPortalAppear()
		GiveLightSource(size = 3, max_alpha = 40)

	proc
		GodRealmPortalAppear()
			set waitfor=0
			while(1)
				invisibility = 5 //zero for testing. 5 in real
				for(var/mob/m in player_view(15,src))
					if(m.has_god_ki || m.HasGodKiBPReq())
						invisibility = 0
						break
				sleep(100)
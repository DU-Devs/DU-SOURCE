var
	god_ki_req = 500000000 //bp per mod
	god_online
	min_god_boost = 1.5

mob/var
	has_god_ki
	god_ki_mastery = 0 //percent, 100% max
	god_mastery_rate = 1 //Yasais should master it fastest probably
	god_mode_on = 0 //this is whether a Yasai wants to use god ki or not. it will restrict their regular ssj forms if they have it on

proc
	GodOnline()
		if(god_online) return 1
		for(var/mob/m in players) if(m.has_god_ki)
			god_online = 1
			return 1

mob/proc
	//for Settings()
	CanTurnGodKiOn()
		if(IsGreatApe()) return
		return 1

	CanTurnGodKiOff()
		return 1

	HasGodKiReq()
		if(has_god_ki) return
		if(!HasGodKiBPReq()) return
		return 1

	HasGodKiBPReq()
		if(base_bp > god_ki_req) return 1

	IsGod()
		if(has_god_ki && god_mode_on) return 1

	//IMPORTANT THERE IS A SEPARATE BP BOOST FOR GOD IN THE get_bp() proc BECAUSE I COULDNT FIGURE OUT HOW TO ADD IT INTO THIS PROC. YOULL SEE IF YOU GO
	//LOOK THERE.
	God_BP()
		return 0 // remove to re-enable god ki
		if(god_ki_mastery == 0 || !has_god_ki || !god_mode_on) return 0

		var
			boost = 1300000000 //x bp mod later
			scale_down_at = 2000000000
			my_bp = effectiveBaseBp

		boost = boost * (my_bp / scale_down_at)**0.3
		boost *= bp_mod

		//we measure the default boost for a Yasai on their ssj2 power not base power like for other races
		if(Race in list("Yasai", "Half Yasai")) boost *= 2.8

		var/min_boost = effectiveBaseBp * (min_god_boost - 1)
		//var/min_boost = (base_bp + static_bp) * (min_god_boost - 1) //right now ssj1 and 2 give a 1.2 x 1.2 (44%) boost over base form so we never want
			//the god ki boost to be less than what a Yasai would have in nongod ssj2 form. this goes for all races no less than 44% boost in god mode
		boost = clamp(boost, min_boost, 1.#INF)

		var/mastery_mult = god_ki_mastery / 100
		boost = (boost * 0.7 * mastery_mult) + (boost * 0.3)

		return boost

	RaiseGodKi(a=0)
		if(!isnum(god_ki_mastery)) god_ki_mastery = 1 //fix the -nan bug we made.
		god_ki_mastery += a
		if(god_ki_mastery > 10 && !has_god_ki && HasGodKiReq()) BecomeGod()
		if(god_ki_mastery > 99) god_ki_mastery = 100

	BecomeGod()
		set waitfor=0
		if(has_god_ki) return
		while(PowerDownRevert()) sleep(1)
		has_god_ki = 1
		god_mode_on = 1
		Old_Trans_Graphics()
		sleep(35)
		alert(src, "You have learned to use God Ki")
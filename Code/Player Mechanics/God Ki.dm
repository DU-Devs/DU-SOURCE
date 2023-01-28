var
	god_ki_req = 100000000 //bp per mod
	god_online
	min_god_boost = 1.5

mob/var
	has_god_ki
	god_ki_mastery = 0 //percent, 100% max
	god_mastery_rate = 1 //Yasais should master it fastest probably
	god_mode_on = 1 //this is whether a Yasai wants to use god ki or not. it will restrict their regular ssj forms if they have it on

proc
	GodOnline()
		if(god_online) return 1
		for(var/mob/m in players) if(m.has_god_ki)
			god_online = 1
			return 1

mob/proc
	//for Settings()
	CanTurnGodKiOn()
		if(IsGreatApe() || transing) return
		return 1

	CanTurnGodKiOff()
		if(transing) return
		return 1

	HasGodKiReq()
		if(has_god_ki) return
		if(!HasGodKiBPReq()) return
		return 1

	HasGodKiBPReq()
		if(effectiveBaseBp > god_ki_req * bp_mod) return 1

	IsGod()
		if(!allow_god_ki) return
		if(has_god_ki && god_mode_on) return 1

	//IMPORTANT THERE IS A SEPARATE BP BOOST FOR GOD IN THE get_bp() proc BECAUSE I COULDNT FIGURE OUT HOW TO ADD IT INTO THIS PROC. YOULL SEE IF YOU GO
	//LOOK THERE.
	God_BP()
		if(!allow_god_ki) return 0
		if(Race == "Frost Lord" && !is_gold_form) return 0

		if(god_ki_mastery == 0 || !has_god_ki || !god_mode_on) return 0

		var
			boost = 130000000 //x bp mod later
			scale_down_at = 150000000
			//my_bp = (base_bp + hbtc_bp) / bp_mod
			my_bp = effectiveBaseBp / bp_mod

		boost = boost * (my_bp / scale_down_at)**0.3
		boost *= bp_mod

		//we measure the default boost for a Yasai on their ssj2 power not base power like for other races
		if(Race in list("Yasai", "Half Yasai")) boost *= form1x * form2x

		var/min_boost = effectiveBaseBp * (min_god_boost - 1)
		//var/min_boost = (base_bp + hbtc_bp) * (min_god_boost - 1) //right now ssj1 and 2 give a 1.2 x 1.2 (44%) boost over base form so we never want
			//the god ki boost to be less than what a Yasai would have in nongod ssj2 form. this goes for all races no less than 44% boost in god mode
		boost = clamp(boost, min_boost, 1.#INF)

		//if(is_ssj_blue)
			//ssj_blue_mult = global_ssj_blue_mult
			//boost *= ssj_blue_mult //see get_bp() for where this occurs now
		if(is_gold_form) gold_form_mult = global_gold_form_mult

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
		if(has_god_ki || transing || !allow_god_ki) return
		if(Race in list("Yasai", "Half Yasai"))
			Revert()
		has_god_ki = 1
		god_mode_on = 1
		if(Race != "Frost Lord")
			Old_Trans_Graphics()
			sleep(35)
			alert(src, "You have learned to use God Ki")
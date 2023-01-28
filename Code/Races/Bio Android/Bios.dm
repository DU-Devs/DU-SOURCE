var
	delay_between_bio_reverts = 70
	start_bio_transform_size = 0.25

mob/var
	bio_form = 0 //1 = imperfect form. 0 = larval form
	last_bio_revert = 0
	tmp
		larva_evolve_loop

mob/proc
	BioFormCheck(mob/m)
		if(Race != "Bio-Android" || bio_form >= 3) return
		if(!CanGetNextBioFormFrom(m)) return
		BioNextForm()

	CanGetNextBioFormFrom(mob/m)
		if(!m) return
		if(m.Race == "Bio-Android" && m.bio_form > bio_form) return 1
		if(m.Is_Cybernetic()) return 1
		if((m.base_bp + m.hbtc_bp) / m.bp_mod > highest_base_and_hbtc_bp * 0.93) return 1

	BioNextForm()
		if(bio_form >= 3) return
		if(bio_form != 0) //if you are not transforming from a larva to imperfect
			ClosePowerGapBy(0.5)
			if(hbtc_bp < base_bp * 0.2) hbtc_bp = base_bp * 0.2

			var
				my_bp = effectiveBaseBp
				boost = 0
				full_boost_bp = 0 //the boost you get will go down the further past this BP you are

			//get a special static bp increase in this bp era
			if(my_bp > 20000000)
				if(bio_form == 1) //going from imperfect to semiperfect
					full_boost_bp = 30000000
					boost = 20000000
					if(my_bp > full_boost_bp) boost -= (my_bp - full_boost_bp)
				if(bio_form == 2) //going from semiperfect to perfect
					full_boost_bp = 60000000 //this should probably be equal to full_boost_bp + boost given for bio_form == 1
					boost = 35000000
					if(my_bp > full_boost_bp) boost -= (my_bp - full_boost_bp)

			if(boost < 0) boost = 0
			hbtc_bp += boost

		bio_form++

		//to ensure that if you detrans then retrans you are never less bp in that form that you ever were before. aka you never LOSE power from retransing
		//if(bio_form == 2 && bioform2_highest_bp < hbtc_bp) bioform2_highest_bp = hbtc_bp
		//if(bio_form == 3 && bioform3_highest_bp < hbtc_bp) bioform3_highest_bp = hbtc_bp

		switch(bio_form)
			if(1)
				if(icon == 'Cell Larva.dmi') icon = 'Bio Android 1.dmi'
				else icon = 'Bio1.dmi'
			if(2)
				if(icon == 'Bio1.dmi') icon = 'Bio2.dmi'
				else icon = 'Bio Android 2.dmi'
			if(3)
				if(icon == 'Bio2.dmi') icon = 'Bio3.dmi'
				else icon = 'Bio Android 3.dmi'

	CanBioRevert()
		if(Race != "Bio-Android") return
		if(bio_form == 0)
			src << "You are already in your larval form"
			return
		if(world.realtime - last_bio_revert < delay_between_bio_reverts * 600)
			src << "You can not revert until it has been [delay_between_bio_reverts] minutes since you last reverted"
			return
		return 1

	BioLarvaRevert()
		if(!CanBioRevert()) return
		last_bio_revert = world.realtime
		bio_form = 0
		hbtc_bp = 0 //this is necessary or it will cause a bug where bios can stack their special era static boost over and over
		BioEggGfx()
		LarvaEvolveLoop()
		if(icon in list('Bio1.dmi', 'Bio2.dmi', 'Bio3.dmi')) icon = 'Cell Larva Blue.dmi'
		else icon = 'Cell Larva.dmi'

	BioEggGfx()
		var/o_icon = icon
		icon = 'Cell Egg.dmi'
		icon_state = ""
		sleep(35)
		icon_state = "open"
		sleep(35)
		transform = matrix() * start_bio_transform_size
		icon = o_icon
		icon_state = ""

	BioBPMult()
		if(Race != "Bio-Android") return 1
		switch(bio_form)
			if(0) return 0.5
			if(1) return 0.9
			if(2) return 0.95
			if(3) return 1
		return 1

	BioAndroidLogon()
		if(Race != "Bio-Android") return
		if(icon == 'Cell Egg.dmi') icon = 'Bio1.dmi'
		verbs+=typesof(/mob/Bio_Android/verb)
		if(bio_form == 0 && world.realtime - character_made_time < 5 * 600)
			transform = matrix() * start_bio_transform_size
		LarvaEvolveLoop()

	LarvaEvolveLoop()
		set waitfor=0

		if(bio_form != 0) return

		if(larva_evolve_loop) return
		larva_evolve_loop = 1

		animate(src, transform = matrix(), time = 3 * 600)
		sleep(3 * 600)

		while(bio_form == 0)
			if(world.realtime - last_bio_revert > 4 * 600 && world.realtime - character_made_time > 4 * 600)
				BioNextForm()
				break
			else sleep(200)

		larva_evolve_loop = 0

mob/Bio_Android/verb
	Revert_to_Larval_Form()
		set category = "Skills"
		BioLarvaRevert()
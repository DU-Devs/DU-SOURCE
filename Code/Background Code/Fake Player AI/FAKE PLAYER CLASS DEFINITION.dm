mob/FakePlayer

	var
		fp_spelling_error = 0
		join_tourny_chance = 0
		fp_invince = 0
		fp_power_mod = 1
		fp_initialized = 0

		tmp
			cant_talk = 0 //+1 for every thing stopping talking

			list
				talk_queue = new

	Savable_NPC = 1
	Zanzoken = 1000
	Dead_Zone_Immune = 1
	Warp = 1
	KB_On = 100

	New()
		if(!z)
			del(src)
			return

		InitFakePlayer()
		StartFakePlayer()

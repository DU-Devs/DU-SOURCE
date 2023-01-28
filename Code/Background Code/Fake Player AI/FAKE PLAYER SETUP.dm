mob/FakePlayer/proc

	InitFakePlayer()
		set waitfor=0

		if(fp_initialized) return
		Yasai(Can_Elite=0)
		AssignSSjMults()
		SetupFakePlayerBP(power_mod = fp_power_mod)
		SetupFakePlayerStats()
		SetFakePlayerSpellingLevel()
		SetupFakePlayerNameAndKey(fp_spelling_error)
		SetupBeamObject()
		SetupBlastObject()
		SetupTextColor()
		SetupFakePlayerIcon()
		SetupFakePlayerHair()
		SetupFakePlayerClothing()
		SetupFakePlayerContents()
		fp_initialized = 1

	StartFakePlayer()
		set waitfor=0

		UnKO()
		StartFakePlayerAI()
		FakePlayerRegenLoop()
		FakePlayerGainPowerLoop()
		FakePlayerGravityLoop()

		get_bp_loop()

	SetupFakePlayerContents()
		contents.Add(GetCachedObject(/obj/Resources), new/obj/Fly, new/obj/Zanzoken)

	SetupFakePlayerClothing()
		var/list/L=new
		for(var/obj/O in Clothing) L+=O.icon
		var/Clothes=rand(0,6)
		while(Clothes)
			Clothes-=1
			var/icon/I=pick(L)
			if(prob(70)) I+=rgb(rand(0,50),rand(0,50),rand(0,50))
			overlays+=I

	SetupFakePlayerHair()
		if(!(icon in list('Race Ginyu.dmi','Race Kui.dmi')))
			var/obj/O=pick(Hairs)
			if(isobj(O)) overlays+=O.icon

	SetupFakePlayerIcon()
		icon=pick('BaseHumanPale.dmi','BaseHumanTan.dmi','BaseHumanDark.dmi','New Pale Female.dmi','New Tan Female.dmi',\
			'New Black Female.dmi','Race Ginyu.dmi','Race Kui.dmi')

	SetFakePlayerSpellingLevel()
		var/spelling_mod = 0
		if(prob(50))
			spelling_mod = 1
			while(prob(70)) spelling_mod+=0.4
		fp_spelling_error = spelling_mod

	SetupFakePlayerNameAndKey(spelling_mod=0)
		name = GetFakePlayerName()
		displaykey = GetFakePlayerKey()

		if(fp_spelling_error)
			name = GetWrongSpelling(name, multiplier = fp_spelling_error)
			displaykey = GetWrongSpelling(displaykey, multiplier = fp_spelling_error)

	SetupFakePlayerBP(power_mod=1)
		var
			lack_ssj_mult=1 //since they dont go ssj they can get extra power if others have ssj
			lack_ssj_add=0

		if(SSj_Online())
			lack_ssj_mult*=form1x
			lack_ssj_add+=ssjadd/2

			bp_mod = Yasai_bp_mod_after_ssj

		if(SSj2_Online())
			lack_ssj_mult*=form2x
			lack_ssj_add+=ssj2add/2

		var
			assumed_hbtc_bp_mod = 1.2
			lack_powerup_mod = 1.25

		base_bp = 0.35 * highest_relative_base_bp * bp_mod * power_mod * assumed_hbtc_bp_mod * lack_ssj_mult * lack_powerup_mod
		base_bp += lack_ssj_add

	SetupFakePlayerStats()
		while(prob(65))
			switch(pick("str","end","for","res","spd","off","def","ki","regen","recov"))
				if("str") strmod*=1.5
				if("end") endmod*=1.5
				if("for") formod*=1.5
				if("res") resmod*=1.5
				if("spd") spdmod*=1.5
				if("off") offmod*=1.5
				if("def") defmod*=1.5
				if("ki") Eff*=1.5
				if("regen") regen*=1.5
				if("recov") recov*=1.5

			switch(pick("str","end","for","res","spd","off","def","ki","regen","recov"))
				if("str") strmod/=1.5
				if("end") endmod/=1.5
				if("for") formod/=1.5
				if("res") resmod/=1.5
				if("spd") spdmod/=1.5
				if("off") offmod/=1.5
				if("def") defmod/=1.5
				if("ki") Eff/=1.5
				if("regen") regen/=1.5
				if("recov") recov/=1.5

		Str = Stat_Record * strmod / 1.5
		End = Stat_Record * endmod / 1.5
		Pow = Stat_Record * formod / 1.5
		Res = Stat_Record * resmod / 1.5
		Spd = Stat_Record * spdmod / 1.5
		Off = Stat_Record * offmod / 1.5
		Def = Stat_Record * defmod / 1.5

		max_ki = rand(3500,5000) * Eff
		Ki = max_ki

	GetFakePlayerName()
		return pick("Sasugay","Chadku","Braal","Ichigo","Luffy","Martin","Bob","John","God","Jesus","Hitler","Radiz","Iworu","Atvar",\
		"Isu","Ken","Pepe","dat boi","Broly","Vortex","Sonic","Saitama","Ryu","Dirk","Donkey Kong","Mario","Reaper","Fenix","Leon",\
		"Sam","Max","Dante","Alucard","Kane","Kain","Samus","Arthus","Bowser","Duke","Duke Nukem","Snake","Kratos","Cloud","Kloud",\
		"Glados","Link","Elf","Faggot","Penis","Gyaku","Naruto","Rapist","Prince","Piccolo","Gohan","Ryuk","Homo","Yamcha","Krillin",\
		"Spiderman","Kakarot","Killer")


	GetFakePlayerKey()
		var/fake_key = GetFakePlayerName()
		if(prob(50))
			if(prob(50)) fake_key+=" "
			fake_key += GetFakePlayerName()
		if(prob(50))
			if(prob(50)) fake_key+=" "

			var/p = rand(0,100)
			if(p < 20)
				fake_key += pick("69","420","9000")
			else if(p < 66)
				fake_key += pick("[rand(1987,1999) - 1900]","[rand(2000,2018) - 2000]")
			else
				fake_key += "[rand(1992,2018)]"

		return fake_key

	SetupTextColor()
		TextColor = pick(\
		rgb(rand(150,255),0,0),\
		rgb(0,rand(150,255),0),\
		rgb(0,0,rand(150,255)),\
		rgb(rand(150,255),rand(150,255),0),\
		rgb(rand(150,255),0,rand(150,255)),\
		rgb(0,rand(150,255),rand(150,255)),\
		rgb(rand(150,255),rand(150,255),rand(150,255)),\
		)

	SetupBeamObject()
		var/obj/Attacks/Beam/beam = locate(/obj/Attacks/Beam) in src
		if(!beam)
			beam = new/obj/Attacks/Beam(src)
			beam.WaveMult *= 3
			beam.icon = 'Beam - Static Beam.dmi'

			var
				rr
				gg
				bb

			if(prob(35)) rr = rand(100,255)
			if(prob(35)) gg = rand(100,255)
			if(prob(35)) bb = rand(100,255)

			beam.icon += rgb(rr,gg,bb)

	SetupBlastObject()
		var/obj/Attacks/Blast/B = new(src)
		B.Spread = 2
		B.Shockwave = 1
		B.Blast_Count = 2
		var/obj/Icon = pick(Blasts)
		if(isobj(Icon)) B.icon = Icon.icon
		B.icon += rgb(rand(0,255),rand(0,255),rand(0,255))

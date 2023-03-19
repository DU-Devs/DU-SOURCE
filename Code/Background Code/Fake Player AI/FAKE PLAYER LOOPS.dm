mob/FakePlayer/proc

	FakePlayerRegenLoop()
		set waitfor=0

		while(src)
			sleep(10)

	FakePlayerGainPowerLoop()
		set waitfor=0

		while(src)
			sleep(10)

	FakePlayerGravityLoop()
		set waitfor=0

		while(src)
			Gravity_Update()
			if(Gravity>gravity_mastered) gravity_mastered=Gravity
			sleep(50)

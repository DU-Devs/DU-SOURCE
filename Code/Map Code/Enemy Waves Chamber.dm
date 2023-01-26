obj/Wave_Controller
	icon='sparkle blast.dmi'

	var
		currentWave = 1
		party/activeParty
		list/enemiesInWave
	
	verb/Use()
		set src in oview(1)
		var/list/Choices = list("Cancel", "Leave")

		switch(input(usr, "Do what?") in Choices)	
			if("Cancel") return
	
	proc
		GenerateWave()
			enemiesInWave = new/list
			var/trashToSpawn = Math.Ceil(1.5 * currentWave + 1), elitesToSpawn = Math.Max(0, Math.Floor(trashToSpawn / 5))
			if(elitesToSpawn) trashToSpawn -= elitesToSpawn
			if(currentWave % 5 == 0)
				trashToSpawn = Math.Max(1, Math.Ceil(trashToSpawn / 3))
				elitesToSpawn = 0
				enemiesInWave += SpawnBossMob()

			while(elitesToSpawn > 0)
				enemiesInWave += SpawnEliteMob()
				elitesToSpawn--

			while(trashToSpawn > 0)
				enemiesInWave += SpawnTrashMob()
				trashToSpawn--
			
			WaveCheckerLoop()
		
		WaveCheckerLoop()
			set background = TRUE
			set waitfor = FALSE
			while(src && AreEnemiesDead())
				if(CheckPlayerKO()) return WaveFailed()
				sleep(5)
			WaveComplete()
		
		AreEnemiesDead()
		CheckPlayerKO()
		WaveFailed()
		WaveComplete()
		
		SpawnBossMob()

		SpawnTrashMob()

		SpawnEliteMob()
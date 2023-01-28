//this uses the existing troll npcs in "Trolls 2.dm". it just auto spawns them and manages a certain amount of them to fill out the game

proc
	InitFakePlayers()
		set waitfor=0

		return

		sleep(600)
		if(is_RP()) return
		for(var/v in 1 to 20)
			var/mob/new_troll/nt = new(locate(222,222,4))
			nt.troll_joins_tournaments = 0
			nt.loc = locate(rand(1,world.maxx),rand(1,world.maxy),rand(1,world.maxz))
			while(nt && nt.x == 0)
				nt.loc = locate(rand(1,world.maxx),rand(1,world.maxy),rand(1,world.maxz))
			//keep in mind bots already have their own prob(50)) of setting followPlayers = 0
			if(prob(80)) nt.followPlayers = 0 //some just dont follow players and are for decoration and filler
			if(prob(50)) nt.followTargetDelay = list(0, 5 * 60) //NUMBERS ARE IN SECONDS. some dont follow you much just occasionally
			sleep(300) //just wait so hosts are less suspicious of dozens of players suddenly appearing at once
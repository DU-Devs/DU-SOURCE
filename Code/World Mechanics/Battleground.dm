/*
tutorialize the battlegrounds

maybe Zeno is there!
*/

var
	battlegroundSystem = 1
	battleground_spawn = locate(122,268,19)
	battleground_spawn_choice_on = 1
	battleground_master_bp_mult = 2
	tmp
		mob/battleground_master

mob
	var
		tmp
			last_battleground_entry = 0
			last_battleground_defeat = 0
	proc
		SpawnAtBattleGroundChoice()
			set waitfor=0
			if(!battleground_spawn_choice_on) return
			switch(alert(src, "Do you want to spawn at the Battleground? It is a good way for new players to see more of the game starting out.", \
			"Options", "Yes", "No", "Why?"))
				if("Yes") GoToBattlegrounds()
				if("Why?")
					alert(src, "At the Battlegrounds you can fight with no risk because as soon as you lose you respawn. \
					It is also a good training area. And players there may help you rather than kill you.")
					SpawnAtBattleGroundChoice()

		GoToBattlegrounds()
			SafeTeleport(battleground_spawn)

		AtBattlegrounds()
			if(!battlegroundSystem) return
			if(z == 19 && current_area && current_area.type == /area/Battlegrounds) return 1

		BattlegroundDefeat(mob/defeater)
			SafeTeleport(battleground_spawn)
			FullHeal()
			last_battleground_defeat = world.time
			if(battleground_master == src) FindNewBattlegroundMaster(defeater)

		FindNewBattlegroundMaster(mob/new_master)
			var/mob/best
			for(var/mob/m in players)
				if(m.AtBattlegrounds() && m.client)
					if(!best || m.last_battleground_defeat < best.last_battleground_defeat)
						best = m

			if(new_master && ismob(new_master) && new_master.client && new_master != battleground_master) best = new_master

			if(best)
				battleground_master = best
				BattlegroundMessage("[best] is the new Battleground MASTER!")

		VerifyBattlegroundMaster()
			var/mob/m = battleground_master
			if(!m || !m.client || !m.AtBattlegrounds())
				FindNewBattlegroundMaster()

		BattlegroundMessage(t = "")
			for(var/mob/m in players) if(m.AtBattlegrounds())
				m << "<font size=3><font color=red>[t]"
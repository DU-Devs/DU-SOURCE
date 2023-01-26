mob/var/tmp/isAFK = 0

mob/proc/CheckAFK()
	if(client && client.inactivity > Social.GetSettingValue("AFK Timer"))
		if((Action && Action != "Meditating") || (trainState && trainState != "Med"))
			Meditate()
		for(var/mob/M in player_view(src, 15))
			M << "[src.name] has gone AFK."
		isAFK = 1
	else
		isAFK = 0
		for(var/mob/M in player_view(src, 15))
			M << "[src.name] is no longer AFK."
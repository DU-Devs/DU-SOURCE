var/config/social/Social = new

setting/string/server_name
	Set(_value)
		if(isnum(_value))
			_value = num2text(_value)
		value = "[_value]"
		
		if(hubfilter)
			var/list/words = list("nigger","jew","faggot","kike","spic","wetback","chink","holocaust","concentration","hitler","queer","trump","cum",\
			"jizz","sex","tranny","blacked","fuck","shit","asshole","pussy","penis","boob","titties","porn","hentai","loli","little girl","false flag","official","offical","gringo","thudwaki","cunt","twat")
			for(var/x in words)
				value = replacetext(Social.GetSettingValue("Server Name"), x, "X")

		Update()

	Update()
		world.status = "[value]"

config/social
	name = "Social Mechanics"

	New()
		..()
		settings.Add(
			new/setting/string/server_name{name = "Server Name";desc = "Name of the server as it appears in the HUB.";value = "Nameless Server"},
			new/setting/bool{name = "Admins Build Free";desc = "Toggles whether build costs are waived for admins.";value = 1},
			new/setting/bool{name = "Character Names in OOC";desc = "Toggles whether character names prefix usernames in OOC chat.";value = 1},
			new/setting/bool{name = "Announce Dragon Ball Activity";desc = "Toggles whether the game announces dragon balls becoming active.";value = 1},
			new/setting/string{name = "RP President";desc = "Set to the key (username) of the person who should be RP President.";value = ""},
			new/setting/limit{name = "Safezone Distance";desc = "Limits how far safezones reach. (0 disables)";value = 20},
			new/setting/bool{name = "Forced Cyborgization";desc = "Toggles whether you can forcibly turn someone into a cyborg if they're KOd.";value = 1},
			new/setting/bool{name = "Forced Injection";desc = "Toggles whether you can forcibly inject someone if they're KOd.";value = 1},
			new/setting/bool{name = "Forced Mating";desc = "Toggles whether you can forcibly mate with someone if they're KOd.";value = 1},
			new/setting/multiplier{name = "Year Speed";desc = "Multiplier for how quickly a global year passes in-game.";value = 1},
			new/setting/time/hours{name = "Auto Save Timer";desc = "Time (in hours) between auto-saves.";value = 72000},
			new/setting/time/hours{name = "Auto Reboot Timer";desc = "Time (in hours) between auto-reboots.";value = 432000},
			new/setting/time/minutes{name = "Tournament Interval";desc = "Time (in minutes) between each automatic tournament. (0 disables)";value = 9000},
			new/setting/probability{name = "Skill Tournament Likelihood";desc = "Probability tournaments will be skill-based.";value = 65},
			new/setting/time/minutes{name = "AFK Timer";desc = "Time (in minutes) of inactivity before a player is marked AFK. (0 disables)";value = 6000},
			new/setting/limit{name = "Name Character Limit";desc = "Maximum number of characters that can be in a player name.";value = 20}
		)
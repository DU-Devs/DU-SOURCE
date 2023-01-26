var/config/progression/Progression = new

config/progression
	name = "Character Progression"

	New()
		..()
		settings.Add(
			new/setting/limit{name = "Maximum Tier";desc = "Maximum tier a player can reach.";value = 150},
			new/setting/limit{name = "Daily Tier Cap";desc = "Number of tiers that can be gained each day. (scaled by days since wipe start- 0 disables)";value = 0},
			new/setting/limit{name = "Tier Soft Cap";desc = "Gains will slow the closer the player is to exceeding this value. (0 disables)";value = 0},
			new/setting/multiplier{name = "BP Gain Rate";desc = "Multiplier for base BP gain rate.";value = 1},
			new/setting/multiplier{name = "BP Leech Rate";desc = "Multiplier for BP leech rate.";value = 1},
			new/setting/multiplier{name = "Zenkai Gain Rate";desc = "Multiplier for zenkai gain rate.";value = 1},
			new/setting/multiplier{name = "Gravity Mastery Rate";desc = "Multiplier for gravity mastery rate.";value = 1},
			new/setting/multiplier{name = "Global Leech Rate";desc = "Multiplier for BP global leech rate.";value = 1},
			new/setting/probability{name = "Global Leech Cap";desc = "Maximum percent of strongest player's BP to leech globally.";value = 100},
			new/setting/limit{name = "Energy Cap";desc = "Maximum energy (x mod) a player can reach.";value = 5000},
			new/setting/multiplier{name = "Energy Gain Rate";desc = "Multiplier for base energy gain rate.";value = 1},
			new/setting/limit/minimum{name = "Minimum Starting BP";desc = "Minimum base BP for new characters to spawn with.";value = 0},
			new/setting/divider{name = "Strongest Player Gain Divider";desc = "Divider for the strongest player's base BP gain rate.";value = 1.5},
			new/setting/multiplier{name = "Transformation Mastery Rate";desc = "Multiplier for transformation mastery rate.";value = 1},
			new/setting/multiplier{name = "Skill Tournament Gain Multiplier";desc = "Multiplier for BP gain off skill tournaments.";value = 1},
			new/setting/multiplier{name = "Knowledge Cap Rate";desc = "Multiplier for knowledge cap rate.";value = 1},
			new/setting/time/hours{name = "HBTC Time Limit";desc = "Time (in hours) a player can use the HBTC.";value = 86400},
			new/setting/time/minutes{name = "RP Reward Timer";desc = "Time (in minutes) between each RP Reward batch.";value = 9000},
			new/setting/time/hours{name = "Core Gains Time Limit";desc = "Time (in hours) the Braal Core can be used for training.";value = 36000},
			new/setting/multiplier{name = "Soul Contract BP Cap Multiplier";desc = "Multiplier for contractor BP cap when setting a contracted soul's power.";value = 1}
		)
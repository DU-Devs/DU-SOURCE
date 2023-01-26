var/config/limits/Limits = new

config/limits
	name = "Game Limitations"

	New()
		..()
		settings.Add(
			new/setting/limit{name = "Maximum Players";desc = "Maximum number of players allowed online consecutively. (0 disables)";value = 0},
			new/setting/limit{name = "Maximum Alts";desc = "Maximum alt accounts a player can have online.";value = 5},
			new/setting/limit{name = "Player View Size";desc = "Width in tiles of the player's viewport.";value = 41},
			new/setting/limit{name = "Maximum Legendary Yasai";desc = "Maximum Legendary Yasai that can exist.";value = 2},
			new/setting/limit{name = "Maximum Frost Lords";desc = "Maximum Frost Lords that can exist.";value = 1},
			new/setting/limit{name = "Maximum Yasai";desc = "Maximum Yasai (includes legendaries, excludes halfies) that can exist. (0 disables)";value = 0},
			new/setting/limit{name = "Hakai Advantage Requirement";desc = "Minimum power advantage required to perform Hakai on someone.";value = 2.5},
			new/setting/limit{name = "Maximum Gravity";desc = "Maximum multiplier gravity will reach with 1x Intelligence.";value = 500},
			new/setting/limit/minimum{name = "Checkpoint Build Distance";desc = "Minimum distance from the checkpoint spawn needed to build.";value = 0},
			new/setting/limit{name = "Maximum Drones";desc = "Maximum number of drones that can exist.";value = 50},
			new/setting/limit/minimum{name = "Minimum Bounty";desc = "Minimum value for a bounty to allow it to be placed.";value = 15000000},
			new/setting/limit{name = "Maximum Afflictions";desc = "Maximum number of afflictions a player can have at once.";value = 10},
			new/setting/limit{name = "Maximum Afflictions per Source";desc = "Maximum number of afflictions a player can have from a single source.";value = 2},
			new/setting/bool{name = "Builder Role Required";desc = "Toggles whether a player must be a builder in order to make map changes.";value = 1},
			new/setting/bool{name = "Drone Genocide";desc = "Toggles whether drones can be given the genocide command.";value = 1},
			new/setting/bool{name = "Death Cures Vampirism";desc = "Toggles whether dying will cure vampirism.";value = 1},
			new/setting/bool{name = "Custom Decorations";desc = "Toggles whether custom decorations are available.";value = 1},
			new/setting/probability{name = "Top BP Percent to Break Walls";desc = "What percent of the top BP you must have to break walls.";value = 100},
			new/setting/time/hours{name = "Max Ban";desc = "Max time (in hours) a player can be banned for (0 disables).";value = 0},
			new/setting/time/minutes{name = "Revive Delay";desc = "Base time (in minutes) a player must wait to use a revive orb.";value = 18000},
			new/setting/time/minutes{name = "Great Ape Cooldown";desc = "Time (in minutes) Great Ape should be on cooldown.";value = 3000},
			new/setting/time/seconds{name = "Hakai Cooldown";desc = "Time (in seconds) hakai should be on cooldown.";value = 300},
			new/setting/multiplier{name = "Base Move Delay";desc = "Multiplier for delay between steps taken.";value = 1},
			new/setting/multiplier{name = "Strong Race BP Mult";desc = "Multiplier for starting BP of various stronger races.";value = 1},
			new/setting/multiplier{name = "Absurd Damage Requirement";desc = "You must be this many times stronger to deal extreme damage.";value = 10}
		)
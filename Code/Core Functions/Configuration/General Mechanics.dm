var/config/mechanics/Mechanics = new

config/mechanics
	name = "General Mechanics"
	
	New()
		..()
		settings.Add(
			new/setting{name = "Base Melee Damage";desc = "Base amount of damage melee attacks deal before any modifiers.";value = 3},
			new/setting{name = "Base Ki Damage";desc = "Base amount of damage ki attacks deal before any modifiers.";value = 1},
			new/setting/multiplier{name = "BP Tier Damage Bonus";desc = "Amount each tier advantage increases outgoing damage.";value = 0.5},
			new/setting/multiplier{name = "BP Tier Tanking Bonus";desc = "Amount each tier advantage decreases incoming damage.";value = 0.75},
			new/setting/divider{name = "Android Damage Divider";desc = "Divider for incoming damage for androids.";value = 2},
			new/setting/bool{name = "Feats";desc = "Toggles the feats system on/off.";value = 1},
			new/setting/bool{name = "Hell Altar";desc = "Toggles the Hell Altar on/off.";value = 1},
			new/setting/bool{name = "Braal Gym";desc = "Toggles the Braal Gym on/off.";value = 1},
			new/setting/bool{name = "Braal Core Portal";desc = "Toggles whether the Braal Core portal will appear.";value = 0},
			new/setting/bool{name = "Kaioshin Portal";desc = "Toggles whether the Kaioshin portal will appear.";value = 0},
			new/setting/bool{name = "Sacred Water";desc = "Toggles whether the sacred water pots will appear.";value = 1},
			new/setting/bool{name = "Wells";desc = "Toggles whether the various wells across the map will appear.";value = 1},
			new/setting/bool{name = "Unlocked Time Chamber";desc = "Toggles whether Time Chamber is unlocked (no key needed).";value = 1},
			new/setting/bool{name = "Item Drop on Death";desc = "Toggles whether items drop on death.";value = 0},
			new/setting/bool{name = "Death Auto-Reincarnates";desc = "Toggles whether death reincarnates instead of sending to afterlife.";value = 0},
			new/setting/bool{name = "Hakai Savewipe";desc = "Toggles whether hakai simply kills its victim or wipes their save.";value = 0},
			new/setting/bool{name = "Health Rally";desc = "Toggles whether some health can be regained after taking damage by attacking a foe.";value = 1},
			new/setting/multiplier{name = "Health Rally Grace Multiplier";desc = "Multiplier for grace period of regaining health by damaging a foe.";value = 1},
			new/setting/multiplier{name = "Cybernetic BP Multiplier";desc = "Multiplier for cybernetic BP.";value = 1},
			new/setting/multiplier{name = "Android BP Multiplier";desc = "Multiplier for android cybernetic BP.";value = 1.8},
			new/setting/multiplier{name = "Drone Power Multiplier";desc = "Multiplier for drone combat power.";value = 1},
			new/setting/multiplier{name = "Gun Power Multiplier";desc = "Multiplier for gun combat power.";value = 1},
			new/setting/multiplier{name = "Core Demon Spawn Rate";desc = "Multiplier to core demon spawn rate.";value = 0},
			new/setting/multiplier{name = "NPC Spawn Rate";desc = "Multiplier to npc spawn rate.";value = 0},
			new/setting/multiplier{name = "Resource Generation Rate";desc = "Multiplier to planet resource generation.";value = 1},
			new/setting/multiplier{name = "Tournament Prize Multiplier";desc = "Multiplier for tournament prize payout.";value = 1},
			new/setting/multiplier{name = "Meteor Spawn Density";desc = "Multiplier for meteor spawn density.";value = 1},
			new/setting/multiplier{name = "KO Timer Multiplier";desc = "Multiplier for KO timer length.";value = 1},
			new/setting/multiplier{name = "Reincarnation BP Limit Multiplier";desc = "Multiplier for BP limit after being reincarnated.";value = 0.1},
			new/setting/multiplier{name = "Reincarnation BP Recovery Multiplier";desc = "Multiplier for BP recovery after being reincarnated.";value = 1.5},
			new/setting/multiplier{name = "Stun Timer Multiplier";desc = "Multiplier for stun timer length.";value = 1},
			new/setting/multiplier{name = "God-Fist Boost Multiplier";desc = "Multiplier for god-fist BP gain.";value = 1},
			new/setting/multiplier{name = "Knockback Distance Multiplier";desc = "Multiplier for knockback distance.";value = 1},
			new/setting/multiplier{name = "Demon Hell BP Multiplier";desc = "Multiplier for Demon BP while in Hell.";value = 1.35},
			new/setting/multiplier{name = "Kai Heaven BP Multiplier";desc = "Multiplier for Kai BP while in Heaven.";value = 1.35},
			new/setting/multiplier{name = "Dead Player BP Multiplier (No Body)";desc = "Multiplier for dead player BP.";value = 0.35},
			new/setting/multiplier{name = "Dead Player BP Multiplier (Body)";desc = "Multiplier for dead player BP with keep body.";value = 0.9},
			new/setting/multiplier{name = "Building Price Multiplier";desc = "Multiplier for building prices.";value = 1},
			new/setting/multiplier{name = "Turf Health Multiplier";desc = "Multiplier for turf health.";value = 2.5},
			new/setting/multiplier{name = "Determination Recovery Multiplier";desc = "Multiplier for determination recovery rate.";value = 1},
			new/setting/multiplier{name = "Power Orb Great Ape Multiplier";desc = "Multiplier for Great Ape power if forced with Power Orb.";value = 0.8}
		)
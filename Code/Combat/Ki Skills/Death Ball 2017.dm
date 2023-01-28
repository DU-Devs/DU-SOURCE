/*
Death ball is basically a clone of spirit bomb now but with different graphics and attributes

give death ball the ability to absorb other blasts fired into it
give death ball a unique lava explosion that continues damaging anyone standing on that ground afterward

maybe death ball spews out peices of lava/plasma onto the ground when it explodes that damage anyone who walks over it for 5-10 sec
*/

obj/Attacks/Genki_Dama/Death_Ball
	name = "Death Ball"
	desc = "A fast moving chargeable energy ball that does high damage and also stuns whoever it hits"
	Cost_To_Learn = 20
	clonable = 1
	Teach_Timer = 1
	student_point_cost = 10

	Genki_Dama_particle_icon = null
	Genki_Dama_icon = 'death ball 2017 purple 2.dmi'
	spin_animation = 0
	usable_if_cybered = 1
	y_offset = 2 //tiles above player
	Genki_Dama_drain = 750
	sb_move_speed = 0.60 //this is actually the DELAY. lower = faster
	sb_max_size = 1.2
	sb_charge_time = 60
	sb_speed_stat_influence = 0.25
	max_dmg_range = 1 //how big the collision box is at full charge
	sb_stun_level = 8

	sb_initial_dmg = 1
	sb_dmg_add = 1.3 //how much damage is gained per charge tick

	sb_deflect_difficulty = 2
	sb_explosion_size = 0

	self_cooldown = 0

	New()
		. = ..()
		verbs -= /obj/Attacks/Genki_Dama/verb/Genki_Dama

	Hotbar_use()
		set hidden=1
		Death_Ball()

	verb/Death_Ball()
		//set category = "Skills"
		usr.TrySpiritBomb2017(src)
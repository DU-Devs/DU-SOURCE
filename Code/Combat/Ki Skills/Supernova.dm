obj/Attacks/Genki_Dama/Supernova
	name = "Supernova"
	desc = "A chargeable energy ball of great size with a big explosion that charges very quickly but isn't as powerful as it looks and moves slow"
	Cost_To_Learn = 20
	clonable = 1
	Teach_Timer = 1
	student_point_cost = 10

	Genki_Dama_particle_icon = null

	Genki_Dama_icon = 'supernova great.png'
	//Genki_Dama_icon = 'Mega Supernova 2018.dmi'

	spin_animation = 1
	usable_if_cybered = 1
	y_offset = 6 //tiles above player
	Genki_Dama_drain = 500
	sb_move_speed = 2 //this is actually the DELAY. lower = faster
	sb_max_size = 2.1
	sb_charge_time = 20
	sb_speed_stat_influence = 0.36
	max_dmg_range = 2 //how big the collision box is at full charge
	sb_stun_level = 0

	sb_initial_dmg = 5
	sb_dmg_add = 1 //how much damage is gained per charge tick

	sb_deflect_difficulty = 1
	sb_explosion_size = 5

	self_cooldown = 0

	New()
		. = ..()
		verbs -= /obj/Attacks/Genki_Dama/verb/Genki_Dama

	Hotbar_use()
		set hidden=1
		Supernova()

	verb/Supernova()
		//set category = "Skills"
		usr.TrySpiritBomb2017(src)
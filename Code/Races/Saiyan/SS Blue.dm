mob/var
	has_ssj_blue
	is_ssj_blue
	ssj_blue_hair
	ssj_blue_aura
	ssj_blue_mult = 1.35
	base_ssj_blue_idle_aura = 'SSj Blue Idle Aura.dmi' //icon

	tmp
		ssj_blue_drain_loop
		image/ssj_blue_idle_aura //set procedurally. since it needs to be offset properly

var
	god_mastery_required_for_ssb = 20
	global_ssj_blue_mult = 1.35 //so i can change it as desired while updating so we dont have to wipe

mob/proc
	PowerUpToSSBlue()
		if(!has_god_ki || !god_mode_on) return
		if(!Has_SSB_Req()) return
		SSj_Blue()

	Has_SSB_Req()
		if(!has_god_ki) return
		if(god_ki_mastery < god_mastery_required_for_ssb) return
		if(!(Race in list("Yasai", "Half Yasai"))) return
		return 1

	SSj_Blue()
		if(is_ssj_blue || transing || IsGreatApe() || ssj) return

		if(Race in list("Yasai", "Half Yasai")) Revert()
		Mystic_Revert()

		transing = 1
		is_ssj_blue = 1
		has_god_ki = 1
		god_mode_on = 1

		if(!ultra_instinct)
			if(ssj_opening && has_ssj_blue) Trans_Graphics(ssj_opening)
			else Old_Trans_Graphics()

		has_ssj_blue = 1
		if(god_ki_mastery < god_mastery_required_for_ssb) god_ki_mastery = god_mastery_required_for_ssb

		overlays -= ssj_blue_idle_aura
		overlays += ssj_blue_idle_aura
		SSj_Hair()
		transing = 0
		Aura_Overlays()
		SSj_Blue_Drain()

	SSj_Blue_Revert()
		if(!is_ssj_blue)
			overlays -= ssj_blue_idle_aura
			return

		is_ssj_blue = 0
		overlays -= ssj_blue_idle_aura
		SSj_Hair()

	SSj_Blue_Drain()
		set waitfor=0
		if(ssj_blue_drain_loop) return
		ssj_blue_drain_loop = 1
		while(is_ssj_blue)

			//fix a bug where people could use ssj4 + god ki. we can remove this when it is sure that everyone using it reverts
			if(ssj == 4) Revert()

			var/d = (max_ki / 600) * (3500 / max_ki)**0.4
			if(Class == "Legendary Yasai") d *= 1.4
			Ki -= d
			if(Ki < d)
				Revert()
				player_view(15,src) << "[src] reverts due to exhaustion"
			sleep(10)
		ssj_blue_drain_loop = 0

	SSj_Blue_Logon_Check()
		if(!is_ssj_blue) overlays -= ssj_blue_idle_aura
		if(!isnum(god_ki_mastery)) god_ki_mastery = 0 //fix -nan bug i made
		if(!ssj_blue_aura)
			//ssj_blue_aura = 'SS Blue Aura 2017.dmi' + rgb(0,0,0,170)
			//ssj_blue_aura = Scaled_Icon(ssj_blue_aura, 48, 64)
			ssj_blue_aura = 'SS Blue Aura 2017.dmi'
			ssj_blue_aura = Scaled_Icon(ssj_blue_aura, 96, 96)
		if(!ssj_blue_idle_aura)
			ssj_blue_idle_aura = image(icon = base_ssj_blue_idle_aura + rgb(0,0,0,213), pixel_x = -32, pixel_y = -28)

		if(!is_ssj_blue) return

		SSj_Blue_Drain()
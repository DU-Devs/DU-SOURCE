/*
copy paste the code for ss blue as a template

stamina increase
time limit
*/

mob/var
	ssg_time
	ssg_able

mob/proc

	has_ssg_req()
		var/list/L = gp_list
		if(has_ssg & ssg_able <= Year && has_god_ki && god_mode_on)
			return 1
		if(L.len>=4)
			var/ritual=0
			for(var/mob/M in src.gp_list)
				if(M.Race in list("Yasai","Half Yasai"))
					if(M.has_ssj_req()&&M.gp_target==src)
						ritual += 1
					else if(M.gp_target==src)
						ritual += 0.5
			if(ritual>=4)
				if(ssg_able>Year||!ssg_able) ssg_able=Year
				if(!has_ssg) has_ssg=1
				has_god_ki=1
				god_mode_on=1
				return 1
			else
				return 0
		if(!has_ssg&&god_ki_mastery>=(ssjg_god_ki_req*2)&&has_god_ki&&god_mode_on)
			has_ssg=1
			if(!ssg_able||ssg_able>=Year) ssg_able=Year
			return 1
		return 0

mob/var
	has_ssg=0
	is_ssg=0
	ssj_god_hair
	ssj_god_aura
	ssj_god_idle_aura
	ssjg_bp_mult=1.25
	ssjg_bp_add=0
	base_ssj_god_idle_aura = 'SSj Blue Idle Aura.dmi' //icon

var
	ssjg_god_ki_req=15
	ssjg_speed_mult=1.3 // global levers for balancing the form
	ssjg_def_mult=1.3
	ssjg_res_mult=0.9
	ssjg_for_mult=0.8
	ssjg_regen_mult=1.3
	ssjg_recov_mult=0.9
	ssjg_stamina_regen=1.4			  // If there is a means of applying this to stamina regen while in SSG, it should 100% be added.

mob/proc/SSG()
	if(!IsGreatApe() && !transing && !ismystic&!is_ssg)
		//if(Race=="Half Saiyan") return	//uncomment this line if you don't want Half-Saiyans getting SSG.
		if(!has_ssg_req()) return

		 //Make sure player has god ki enabled?  If this doesn't do that then comment out or remove this line.
		transing=1
		//ssj=5							 // not sure what you use for SSjB but likely not the ssj var.
		is_ssg=1
		if(!ultra_instinct)
			if(ssj_opening && has_ssg) Trans_Graphics(ssj_opening)
			else Old_Trans_Graphics()
		if(ssjg_bp_add) ssj_power+=ssjg_bp_add			  // This should be 0 by default, but having it in edit sheet so on RP we can edit this var would be wonderful.
		if(!ssg_revert&&transing)
			ssg_revert=1
			Spd*=ssjg_speed_mult
			spdmod*=ssjg_speed_mult
			Def*=ssjg_def_mult
			defmod*=ssjg_def_mult
			Pow*=ssjg_for_mult
			formod*=ssjg_for_mult
			Res*=ssjg_res_mult
			resmod*=ssjg_res_mult
			recov*=ssjg_recov_mult
			regen*=ssjg_regen_mult
			ssg_revert=0
		transing=0
		/*var/list/Old_Overlays=new
		overlays-=hair
		Old_Overlays.Add(overlays)		  // I can't imagine there'd be much of an overlay unless you wanted one
		overlays-=overlays				  // like SSB where it has a constant smaller aura even when not powering up.
		overlays+='SSj4 Overlay.dmi'
		overlays+=Old_Overlays*/
		SSj_Hair()
		Aura_Overlays()
		SSG_Drain()

mob/var/ssg_drain_loop
mob/var/tmp/ssg_revert
mob/proc
	SSG_Drain()
		set waitfor=0
		if(ssg_drain_loop) return
		ssg_drain_loop = 1
		ssg_time= world.time+600
		while(is_ssg)

			//fix a bug where people could use ssj4 + god ki. we can remove this when it is sure that everyone using it reverts
			if(ssj == 4) Revert()

			var/d = (max_ki / 600) * (3500 / max_ki)**0.3
			if(god_ki_mastery<ssjg_god_ki_req)
				d*= 3
				if(world.time>ssg_time)
					Revert()
					player_view(15,src) << "[src]'s divine power wears off."
			if(Class == "Legendary Yasai") d *= 1.3
			Ki -= d
			if(Ki < d)
				Revert()
				player_view(15,src) << "[src] reverts due to exhaustion"
			sleep(10)
		ssg_drain_loop = 0

	SSG_Logon_Check()
		if(!is_ssg) overlays -= ssj_god_idle_aura
		if(!isnum(god_ki_mastery)) god_ki_mastery = 0 //fix -nan bug i made
		if(!ssj_god_aura)
			//ssj_blue_aura = 'SS Blue Aura 2017.dmi' + rgb(0,0,0,170)
			//ssj_blue_aura = Scaled_Icon(ssj_blue_aura, 48, 64)
			ssj_god_aura = 'Light_Red_Aura_Xenoverse_Color_Scheme.dmi'
			ssj_god_aura = Scaled_Icon(ssj_god_aura, 96, 96)
		if(!ssj_god_idle_aura)
			ssj_god_idle_aura = image(icon = base_ssj_god_idle_aura + rgb(0,0,0,213), pixel_x = -32, pixel_y = -28)

		if(!is_ssg) return

		SSG_Drain()

	SSG_Revert()
		if(!is_ssg)
			overlays -= ssj_god_idle_aura
			return
		is_ssg = 0
		if(ssg_revert) return
		ssg_revert=1
		overlays -= ssj_god_idle_aura
		Spd/=ssjg_speed_mult
		spdmod/=ssjg_speed_mult
		Def/=ssjg_def_mult
		defmod/=ssjg_def_mult
		Pow/=ssjg_for_mult
		formod/=ssjg_for_mult
		Res/=ssjg_res_mult
		resmod/=ssjg_res_mult
		recov/=ssjg_recov_mult
		regen/=ssjg_regen_mult
		SSj_Hair()
		ssg_revert=0

#ifdef DEBUG
mob
	verb
		Give_Me_SSG()
			set category = "Yeet"
			if(max_ki<(energy_cap*Eff))
				max_ki=energy_cap*Eff
			if(Race in list("Yasai","Half Yasai"))
				src << "Unlocked Omega Yasai God"
				if(!has_ssg)has_ssg=1
				if(!has_god_ki)has_god_ki=1
				if(!god_mode_on)god_mode_on=1
				if(ssg_able>Year||!ssg_able) ssg_able=Year
				if(!is_ssg) SSG()

		Prepare_Ritual()
			set category = "Yeet"
			if(max_ki<(energy_cap*Eff)) max_ki=energy_cap*Eff
			if(!locate(/obj/Give_Power) in src.contents)
				src.contents += new/obj/Give_Power
				src << "Learned Give Power."
			if(!SSjAble || SSjAble > Year)
				src << "Learned Omega Yasai."
				SSjAble = Year
			if(!SSj2Able || SSj2Able > Year)
				src << "Learned Omega Yasai 2."
				SSj2Able = Year

		Free_SP()
			set category = "Yeet"
			Experience+=5000
			src << "You gained 5000 SP."

		Free_Resources()
			set category="Yeet"
			src.Alter_Res(50000000)
			src << "You gained 50'000'000 Resources."

#endif

mob/var
	has_gold_form
	is_gold_form
	gold_form_aura = 'Gold Icer Aura Smaller.dmi'
	gold_form_mult = 1.3
	goldFormIcon = 'Gold Icer.dmi'

	tmp
		gold_form_drain_loop
		image/gold_form_idle_aura //set procedurally

var
	god_mastery_required_for_gold_form = 0
	global_gold_form_mult = 1.3 //so i can change it as desired while updating so we dont have to wipe
	gold_form_bp_req = 1800000000

mob/proc
	PowerUpToGoldForm()
		//if(!has_god_ki || !god_mode_on) return
		if(!HasGoldFormReq()) return
		GoldForm()

	HasGoldFormReq()
		//if(!has_god_ki) return
		//if(god_ki_mastery < god_mastery_required_for_gold_form) return
		if(Race != "Frost Lord") return
		if(!HasGoldFormBPReq()) return
		return 1

	HasGoldFormBPReq()
		if(effectiveBaseBp > gold_form_bp_req) return 1

	Frost_LordUnlockGodKi()
		if(!has_god_ki)
			has_god_ki = 1
			god_mode_on = 1
		god_ki_mastery = 100

	GoldForm()
		if(is_gold_form || transing) return

		Frost_LordUnlockGodKi()

		//if(Race in list("Yasai", "Half Yasai")) Revert()
		//Mystic_Revert()

		transing = 1
		is_gold_form = 1
		has_god_ki = 1
		god_mode_on = 1

		GoldIcerTransEffectSupernova()
		for(var/mob/m in player_view(20,src)) if(m.client) m.ScreenShake(30)
		Dust(src, end_size = 1, time = 35)
		//if(ssj_opening && has_gold_form) Trans_Graphics(ssj_opening)
		//else Old_Trans_Graphics()

		has_gold_form = 1
		if(god_ki_mastery < god_mastery_required_for_gold_form) god_ki_mastery = god_mastery_required_for_gold_form

		overlays -= gold_form_idle_aura
		overlays += gold_form_idle_aura
		//SSj_Hair()
		transing = 0
		icon = goldFormIcon
		Aura_Overlays()
		GoldFormDrain()

	GoldFormRevert()
		if(!is_gold_form)
			overlays -= gold_form_idle_aura
			return

		is_gold_form = 0
		overlays -= gold_form_idle_aura
		icon = Form4Icon
		//SSj_Hair()

	GoldFormDrain()
		set waitfor=0
		if(gold_form_drain_loop) return
		gold_form_drain_loop = 1
		while(is_gold_form)

			//fix a bug where people could use ssj4 + god ki. we can remove this when it is sure that everyone using it reverts
			//if(ssj == 4) Revert()

			var/d = 1.2 * (max_ki / 500) * (3500 / max_ki)**0.4
			Ki -= d
			if(Ki < d)
				Revert()
				player_view(15,src) << "[src] reverts due to exhaustion"
			sleep(10)
		gold_form_drain_loop = 0

	GoldFormLogonCheck()
		if(!is_gold_form) overlays -= gold_form_idle_aura
		if(!isnum(god_ki_mastery)) god_ki_mastery = 0 //fix -nan bug i made
		gold_form_aura = image(initial(gold_form_aura) + rgb(0,0,0,170), pixel_x = 0, pixel_y = -4)
		//gold_form_aura = Scaled_Icon(gold_form_aura, 48, 64)
		gold_form_idle_aura = image(icon = 'Gold Idle Aura.dmi' + rgb(0,0,0,203), pixel_x = -32, pixel_y = -28)

		if(!is_gold_form) return

		GoldFormDrain()

	GoldIcerTransEffectSupernova()
		set waitfor=0
		var/obj/Effect/e = GetEffect()
		e.loc = loc
		e.icon = 'Mega Supernova 2018.dmi'
		CenterIcon(e)
		e.layer = 9
		e.alpha = 255
		e.transform *= 0.01
		animate(e, alpha = 0, transform = matrix() * 5, time = 50)
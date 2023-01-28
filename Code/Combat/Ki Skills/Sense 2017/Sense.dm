mob/var/tmp/testing_sense = 0

mob/verb/Toggle_Sense_Overlay()
	set category = "Other"
	if(!testing_sense)
		UpdateSenseArrowList(current_area)
		testing_sense = 1
		src << "Sense Arrows on"
	else
		src << "Sense Arrows are already on. Perhaps there is just no one else on the planet to sense."
		testing_sense = 0
		RemoveAllSenseArrows()

obj/Screen_Indicator
	Savable=0
	Health=1.#INF
	Dead_Zone_Immune=1
	Knockable=0
	Bolted=1
	Grabbable=0
	Cloakable=0
	can_blueprint=0
	layer = 999

	//mouse_opacity = 2
	mouse_opacity = 0 //i switched it off of 2 because clicking your char would often instead click a sense arrow and it was annoying so this was the easiest
	//way, not like clicking sense arrows is very important anyway

	icon = 'Screen Arrow.dmi'
	icon_state = "arrow"
	screen_loc = "CENTER"

	var
		tmp
			atom/movable/target
			base_trans_size = 0.7
			last_size_update = 0
			last_appearance_update = 0

	New()
		//verbs = new //new/list
		//verbs = null
		for(var/v in verbs) verbs -= v
		. = ..()

	Del()
		screen_indicator_cache -= src
		screen_indicator_cache += src
		loc = null
		target = null

	proc
		SenseArrowMatchAppearance(update_overlays = 1)
			if(!target) return
			var/mob/m = target
			//appearance = m.appearance
			icon = m.icon
			icon_state = m.icon_state
			dir = m.dir
			name = m.name
			//because updating overlays seems to cause a lot of cpu use
			if(update_overlays)
				overlays = m.overlays
				underlays = m.underlays

	Click()
		if(target) target.Click(usr)

var
	sense_arrow_update_rate = 2.5

mob
	var
		tmp
			list/sense_arrows = new

	proc
		UpdateSenseArrowPositionsLoop()
			set waitfor=0
			while(1)
				if(client) UpdateSenseArrowPositions()
				sleep(sense_arrow_update_rate)

				var/inactive_time = 600
				if(client && client.inactivity > inactive_time)
					while(client && client.inactivity > inactive_time) sleep(5)

		UpdateSenseArrowPositions()
			if(!client) return
			var/area/a = current_area
			if(!a)
				RemoveAllSenseArrows()
				return
			for(var/obj/Screen_Indicator/si in sense_arrows)
				UpdateSenseArrowPosition(si)

		UpdateSenseArrowPosition(obj/Screen_Indicator/si, instant_update = 0)
			if(!client) return

			if(!si.target)
				RemoveSenseArrow(si)
				return

			if(!CanSense(src,si.target) || si.target.locz() != locz()) si.alpha = 0
			else
				si.alpha = 116

				if(world.time - si.last_size_update > 10)
					UpdateSenseArrowSizeBasedOnPower(si)
					si.last_size_update = world.time

				if(world.time - si.last_appearance_update > 25)
					si.SenseArrowMatchAppearance(update_overlays = prob(20))
					si.last_appearance_update = world.time

				PointArrow(si, si.target, instant_update = instant_update, dist_mod = SenseArrowDistanceMod(si), do_rotation = 0)

		SenseArrowDistanceMod(obj/Screen_Indicator/si)
			//new way but idk if it works we'll see
			var/dist = 0.5
			dist += getdist(src,si.target) / 250 * (1 - dist) * 1.4 //last number is just an arbitrary multiplier
			if(dist > 2) dist = 2
			return dist

			//original working way
			/*var/dist = 0.5
			dist += getdist(src,si.target) / 250 * (1 - dist)
			if(dist > 1) dist = 1
			return dist*/

		UpdateSenseArrowSizeBasedOnPower(obj/Screen_Indicator/si)
			var/size_mod = (Sense_Power(si.target) / 100) ** 0.4
			size_mod = Clamp(size_mod, 0.5, 1.1)
			var/new_trans_size = size_mod * si.base_trans_size
			si.transform /= si.transform_size
			si.transform *= new_trans_size
			si.transform_size = new_trans_size

		RemoveSenseArrow(obj/Screen_Indicator/si)
			if(client) client.screen -= si
			sense_arrows -= si
			del(si)

		AddSenseArrow(obj/Screen_Indicator/si, clr)
			if(!client) return
			client.screen += si
			sense_arrows += si
			UpdateSenseArrowPosition(si, instant_update = 1)
			if(clr) si.color = clr

		RemoveAllSenseArrows()
			for(var/obj/o in sense_arrows) RemoveSenseArrow(o)
			sense_arrows = new/list

		UpdateSenseArrowList(area/a)
			RemoveAllSenseArrows()
			if(!testing_sense) return
			for(var/mob/m in a.player_list)
				if(m != src)
					var/obj/Screen_Indicator/si = GetNewScreenIndicator()
					si.target = m
					si.SenseArrowMatchAppearance()
					AddSenseArrow(si, clr = GetSenseArrowColor(m))

		GetSenseArrowColor(mob/m)

			return

			var/c = GetSenseArrowColorByRace(m.Race, m.Class)
			return c

		GetSenseArrowColorByRace(race, class)
			switch(race)
				if("Human")
					if(class == "Spirit Doll") return rgb(222,255,255)
					else return rgb(255,255,255)
				if("Puranto") return rgb(0,255,0)
				if("Yasai")
					if(class == "Legendary Yasai") return rgb(180,255,0)
					else return rgb(233,120,0)
				if("Half Yasai") return rgb(255,190,110)
				if("Alien") return rgb(0,0,255)
				if("Android") return rgb(70,70,70)
				if("Bio-Android") return rgb(255,255,0)
				if("Demigod") return rgb(255,255,120)
				if("Demon") return rgb(255,0,0)
				if("Frost Lord") return rgb(180,0,255)
				if("Kai") return rgb(0,222,255)
				if("Onion Lad") return rgb(130,0,170)
				if("Majin") return rgb(255,0,233)
				if("Tsujin") return rgb(180,180,180)

area
	var
		tmp
			last_sense_target_update = 0 //world.time
			sense_update_queued
			max_sense_target_update_rate = 50
	proc
		//whenever someone enters or exits an area it updates sense targets for everyone
		AreaUpdateSenseTargets()
			if(sense_update_queued) return
			sense_update_queued = 1
			if(world.time - last_sense_target_update < max_sense_target_update_rate)
				sleep(max_sense_target_update_rate - (world.time - last_sense_target_update))

			for(var/mob/m in player_list)
				if(m.client)
					m.UpdateSenseArrowList(src)

			last_sense_target_update = world.time
			sense_update_queued = 0

var/list/screen_indicator_cache = new

proc
	GetNewScreenIndicator()
		var/obj/Screen_Indicator/si
		if(screen_indicator_cache.len)
			si = screen_indicator_cache[1]
			screen_indicator_cache -= si

			//reset needed vars
			ResetVars(si)
			si.last_size_update = 0
			si.last_appearance_update = 0
			/*animate(si) //stop all animations
			si.transform = matrix()
			si.target = null
			si.alpha = 255
			si.color = null*/

		else si = new
		return si
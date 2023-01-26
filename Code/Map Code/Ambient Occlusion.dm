var
	image
		ambient_occlusion = image(icon = 'Ambient Occlusion.dmi', pixel_y = 7, layer = 2.5)
		ambient_occlusion_right = image(icon = 'Ambient Occlusion.dmi', layer = 2.5, icon_state = "right")
		ambient_occlusion_left = image(icon = 'Ambient Occlusion.dmi', layer = 2.5, icon_state = "left")

turf/proc
	IsAOCaster()
		if(density) return 1

	IsAOReciever()
		if(density) return
		if(IsWater(src) && auto_wave && wave_icon) return
		return 1

	CheckBottomAO(skip_reciever_check)
		if(!skip_reciever_check && !IsAOReciever()) return

		overlays -= ambient_occlusion
		var/turf/t = get_step(src,NORTH)
		if(t && t.IsAOCaster())
			overlays += ambient_occlusion

	CheckRightAO(skip_reciever_check)
		if(!skip_reciever_check && !IsAOReciever()) return

		overlays -= ambient_occlusion_left
		var/turf/t = get_step(src,EAST)
		if(t && t.IsAOCaster())
			overlays += ambient_occlusion_left

	CheckLeftAO(skip_reciever_check)
		if(!skip_reciever_check && !IsAOReciever()) return

		overlays -= ambient_occlusion_right
		var/turf/t = get_step(src,WEST)
		if(t && t.IsAOCaster())
			overlays += ambient_occlusion_right

	GenerateAmbientOcclusion(skip_side_checks)
		set waitfor=0

		if(!skip_side_checks)
			var/turf/t = get_step(src,SOUTH)
			if(t) t.CheckBottomAO()

			t = get_step(src,EAST)
			if(t) t.CheckLeftAO()

			t = get_step(src,WEST)
			if(t) t.CheckRightAO()

		if(IsAOReciever())
			CheckBottomAO(skip_reciever_check = 1)
			CheckLeftAO(skip_reciever_check = 1)
			CheckRightAO(skip_reciever_check = 1)

	//this removes ambient occlusion from them all then reapplies it to fix AO being left behind on anything while building
	//without this, if you build some walls, they get ambient occlusion on the sides and bottom, but then if you build over them
	//with floors, the AO from the walls stays there on the surrounding turfs improperly
	GenerateAmbientOcclusionOnSelfAndNeighbors()
		var/list/l = list(src, get_step(src,NORTH), get_step(src,SOUTH), get_step(src,EAST), get_step(src,WEST))
		for(var/turf/t in l) t.GenerateAmbientOcclusion()
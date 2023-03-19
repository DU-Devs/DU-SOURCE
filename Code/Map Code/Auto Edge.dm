/*
waves on the side and top of turfs. only on turfs that do not generate edges.

DIRECTIONAL SHADOWS. same as ambient occlusion but we place them to the left and south of dense turfs that have nondense turfs bordering
them in that direction.

cave edge generator, it detects the void and puts a proper edge there to know its a cave inside a void

fill in the little missing corner of edges that happens when they are perpendicular to each other

make it so if you place down a ground turn and the turf above that has a water wave overlay the wave overlay is removed
	then we can probably safely make water waves apply to player made turfs

water wave icon generator using alpha mask somehow
*/

mob/Admin5/verb
	TestAlpha(atom/t in world)
		var/icon/i = icon(t.icon)
		i.Blend('TransparentScribbles.dmi',ICON_SUBTRACT)
		t.icon = i

turf/var
	edge_icon = 'Edges6.dmi'
	cliff_type = /turf/Wall7
	wave_icon = 'Surf2.dmi'

	auto_edge = 1
	auto_cliff = 1
	auto_wave = 1

	do_south_edge = 0 //for things like bridges that need a south edge applied to look right because they have auto_cliff = 0

	wave_icon_applied = null //becomes the icon applied if any

var/image/edge_image = image(icon = 'Edges6.dmi')

turf/proc
	GenerateFeatures(ao_skip_side_checks = 0, do_cliff_check = 1, do_edge_check = 1, do_wave_check = 1, do_ao_check = 1)
		set waitfor=0
		if(do_cliff_check) GenerateCliffs()
		if(do_edge_check) GenerateEdges()
		if(do_wave_check) GenerateShoreWaves()
		if(do_ao_check) GenerateAmbientOcclusion(skip_side_checks = ao_skip_side_checks)

	GenerateEdges()
		set waitfor=0

		if(Water || density || !auto_edge || !edge_icon) return

		var/list/ts = list(get_step(src,NORTH), get_step(src,EAST), get_step(src,WEST))
		if(do_south_edge) ts += get_step(src,SOUTH)

		for(var/turf/t in ts)
			var/d = get_dir(src,t)
			if(t.Water || (t.type == cliff_type && (d == EAST || d == WEST)))
				switch(d)
					if(NORTH)
						edge_image.icon = edge_icon
						edge_image.icon_state = "N"
						overlays += edge_image
					if(EAST)
						edge_image.icon = edge_icon
						edge_image.icon_state = "E"
						overlays += edge_image
					if(WEST)
						edge_image.icon = edge_icon
						edge_image.icon_state = "W"
						overlays += edge_image
					if(SOUTH)
						if(do_south_edge && t.type != type)
							edge_image.icon = edge_icon
							edge_image.icon_state = "S"
							overlays += edge_image

	GenerateShoreWaves()
		set waitfor=0
		if(Water || !auto_wave || !wave_icon) return
		var/turf/t = get_step(src,SOUTH)
		if(t && t.Water && t.wave_icon)
			overlays += t.wave_icon
			t.wave_icon_applied = t.wave_icon

	GenerateCliffs()
		set waitfor=0
		if(Water || density || !auto_cliff || !cliff_type) return
		var/turf/t = get_step(src,SOUTH)
		if(t && t.Water)

			//think about it like this, if there is some ground, then below that some water, then below that more ground, and we replace
			//the water with a cliff, its gonna look funny to have a cliff between 2 grounds, so to make it not look funny we make the bottom
			//ground into water
			var/turf/t2 = get_step(t,SOUTH)
			if(t2 && t2.type != t.type) new t.type(t2)

			new cliff_type(t)
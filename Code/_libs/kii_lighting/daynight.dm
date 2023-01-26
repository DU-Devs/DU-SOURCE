



var
	daynight/daynight	= new




daynight
/*	this datum handles the ambient lighting/darkness of the world.
*/
	parent_type	= /datum

	var

		max_darkness			= "#080808"	// maximum darkness.
		min_darkness			= "#787878"	// minimum darkness.
		day_length				= 600		// how many ticks a full day cycle should be

		obj
			global_lighting 	= new/obj/render_part/global_lighting()





	proc

		draw_global_lighting()
			/* called to draw the global_lighting obj.
			*/
			global_lighting.transform 	= matrix(18,18,MATRIX_SCALE)
			global_lighting.color		= max_darkness	// start things out on max darkness for because.

		//	now we apply an animation cycle!
			animate(global_lighting, color = min_darkness, time = day_length/2, loop = -1)	// start off getting brighter..
			animate( color = max_darkness, time = day_length/2)	// then get darker.




client

	proc
		draw_lighting()
			/* call this *once* on each client that connects. It applies the render planes for lighting to their screen.
			*/
			screen.Add( new/obj/render_plane/lighting(), new/obj/render_plane/occlusion(), daynight.global_lighting, new/obj/render_plane/screen() )






obj

	render_part
		layer = 0+BACKGROUND_LAYER

		global_lighting
			icon 			= 'daynight.dmi'
			plane 			= EMISSIVE_PLANE
			screen_loc 		= "center,center"
			mouse_opacity	= 0
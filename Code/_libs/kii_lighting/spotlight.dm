

/* next we have the definition for the spotlight itself.
*/


spotlight

	parent_type			= /atom/movable

	plane				= GROUND_PLANE
	layer				= FLOAT_LAYER+TOPDOWN_LAYER
	icon 				= 'spotlight.dmi'
	icon_state 			= "0"
	pixel_w 			= -38
	pixel_z 			= 0

	plane_flags			= PLANE_EMITTER	// spotlights are emissive and do not occlude.
	brightness			= 0.6

	appearance_flags	= PIXEL_SCALE | NO_CLIENT_COLOR


	New()
		make_emissive( STATIC )

	var
		default_tint	// this var is just here to make it easier to track what color a spotlight should revert to after animating its color or changing it for some reason.



/* finally we have the stuff for drawing and handling spotlights on atoms. i couldn't use vis_contents under /atom for some reason (i assume because areas)
		so i had to do a weird workaround for the toggle_spotlight() proc.
		It's defined under atom but defined under /turf and atom/movable.   It's silly, but it's the best solution.
*/


atom
	var/tmp
		spotlight/spotlight		// this is the spotlight itself. all atoms can have a spotlight, but do not have one until one is given to them with draw_spotlight().


	movable
		// movable atom's toggle spotlight definition.

		toggle_spotlight(i = 1)
			/* called to add/hide the spotlight.  i = 1 to show, 0 to hide.
			*/
			if(!spotlight) return // can't toggle what doesn't exist..

			if(i && !(spotlight in vis_contents))
			//	if we wanna show it and it isn't already in the overlays..
				vis_contents += spotlight

			else if(i == 0 && (spotlight in vis_contents))
			//	if we wanna remove it and it's still in the overlays.
				vis_contents -= spotlight





	proc
		draw_spotlight(x_os = 0, y_os = 0, hex = null, size_modi = 1, alph = 255)
			/* x_offset, y_offset, color value (if any), size multiplier, alpha value.

					NOTE: alpha basically manages the "intensity" value for how bright the light is.
			*/
			if(spotlight) return
			spotlight 				= new /spotlight
			spotlight.pixel_w		= x_os
			spotlight.pixel_z		= y_os
			spotlight.color			= hex
			spotlight.default_tint	= hex

			if(!spotlight.color)
		//	so since the spotlight itself just manages the tinting, and the emissive overlay handles the actual lighting,
		//	we don't want the spotlight to be visible when it isn't tinted.
				spotlight.layer	= BACKGROUND_LAYER

			spotlight.transform		= matrix()*size_modi
			spotlight.alpha			= alph





		edit_spotlight(x_os, y_os, hex, size_modi, alph)
			/* call this proc to change a spotlight's variables on the fly
				only the variables that are there are changed, if null, no changes will be made.
			*/
			if(!spotlight) return
			animate(spotlight, pixel_w = ((!isnull(x_os)) ? x_os : spotlight.pixel_w), pixel_z = ((!isnull(y_os)) ? y_os : spotlight.pixel_z), color = hex, transform = (size_modi ? matrix()*size_modi : spotlight.transform), alpha = ((!isnull(alph)) ? alph : spotlight.alpha), time = 1)
			if(spotlight.color) spotlight.layer	= FLOAT_LAYER+TOPDOWN_LAYER
			else				spotlight.layer = BACKGROUND_LAYER
			sleep 1





		toggle_spotlight( i )
			/* just a definition here. vis_contents is funky so i have to do this workaround to make it work for turfs. Simply defining on /atom doesn't play nice.
			*/












turf

	toggle_spotlight(i = 1)
		/* called to add/hide the spotlight.
			i = 1 to show, 0 to hide.
		*/
		if(!spotlight) return

		if(i && !(spotlight in vis_contents))
		//	if we wanna show it and it isn't already visible..
			vis_contents += spotlight

		else if(i == 0 && (spotlight in vis_contents))
		//	if we wanna remove it and it's still visible.
			vis_contents -= spotlight

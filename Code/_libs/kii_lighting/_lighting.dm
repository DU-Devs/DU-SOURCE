



//		MASK types
#define STATIC 1
#define DYNAMIC 2


//		lighting planes..

#define GROUND_PLANE 1		// this library assumes you have your turfs all on a plane lower than the mob's plane.
#define ACTION_PLANE 2		// this library assumes you have all your mobs and stuff on a plane above your ground/turf plane.

#define EMISSIVE_PLANE 8
#define OCCLUDE_PLANE 9
#define LIGHT_RENDER_PLANE 10




//		masking bitflags.
#define PLANE_OCCLUDER 1
#define PLANE_EMITTER 2



/*	here let's define the render_planes for the lighting foo.
*/



obj
	render_plane
		screen_loc				= "center,center"
		appearance_flags    	= PLANE_MASTER
		mouse_opacity			= 0

	/*	these are render planes that handle the emissive/occlude planes and blend them together into a lighting plane.
	*/
		lighting
			plane 				= EMISSIVE_PLANE
			render_target 		= "*lighting"

		occlusion
			plane 				= OCCLUDE_PLANE
			render_target 		= "*emissive"

		screen
			plane 				= LIGHT_RENDER_PLANE
			blend_mode 			= BLEND_MULTIPLY
			appearance_flags 	= KEEP_TOGETHER
			New()
				vis_contents.Add( new/obj/render_part/draw_lighting(), new/obj/render_part/draw_emissive() )
				..()

//	render parts are basically helpers for render_planes.
	render_part
		layer 				= 0+BACKGROUND_LAYER


		draw_lighting
			render_source	= "*lighting"
			plane 			= FLOAT_PLANE
			layer 			= FLOAT_LAYER
		draw_emissive
			render_source 	= "*emissive"
			blend_mode 		= BLEND_ADD
			plane 			= FLOAT_PLANE
			layer 			= FLOAT_LAYER










/*	drawing mask overlays..
*/



	masks
	/*	object type for emissive and occlude masks..!
	*/

		plane 				= OCCLUDE_PLANE
		layer 				= BACKGROUND_LAYER

		_STATIC
			/* STATIC masks have a single icon_state "emit" or "occlude". STATIC masks inherit their parent's icon file, so any static masks should be in the parent object's icon's file.
			*/
			default_emitter

				icon_state 			= "emit"
				vis_flags 			= VIS_INHERIT_ICON | VIS_INHERIT_DIR | VIS_INHERIT_ID | VIS_INHERIT_LAYER

			default_occluder

				icon_state 			= "occlude"
				vis_flags 			= VIS_INHERIT_ICON | VIS_INHERIT_DIR | VIS_INHERIT_ID | VIS_INHERIT_LAYER | VIS_UNDERLAY






		_DYNAMIC
			/* DYNAMIC masks have numerous icon_states. Dynamic masks will inherit their parent object's ICON_STATE, but need to have an icon_file provided for each mask.
			*/
			default_emitter
				vis_flags 			= VIS_INHERIT_ICON_STATE | VIS_INHERIT_DIR | VIS_INHERIT_ID | VIS_INHERIT_LAYER

			default_occluder
				vis_flags 			= VIS_INHERIT_ICON_STATE | VIS_INHERIT_DIR | VIS_INHERIT_ID | VIS_INHERIT_LAYER | VIS_UNDERLAY










atom
	var
		plane_flags 	= 0
		brightness		= 1



	proc
		is_occluder()
			if(plane_flags&PLANE_OCCLUDER)
				return 1
			return 0


		is_emitter()
			if(plane_flags&PLANE_EMITTER)
				return 1
			return 0








	movable
		proc



			make_occlude( _type = STATIC, dynamic_mask = null)
				/* called to drawn an occluder's occlude mask.
					_type 			= STATIC or DYNAMIC mask?
					dynamic_mask	= icon file for any dynamic masks.
				*/
				if( !is_occluder() )	return
				//	if we're not an occluder.. cancel!

				if( _type == STATIC)
					var/obj/masks/_STATIC/default_occluder/a		= new /obj/masks/_STATIC/default_occluder
					vis_contents 	+= a

				else
					var/obj/masks/_DYNAMIC/default_occluder/a		= new /obj/masks/_DYNAMIC/default_occluder
					a.icon			= dynamic_mask
					vis_contents 	+= a






			make_emissive( _type = STATIC, dynamic_mask = null )
				/* called to drawn an emissive's emissive mask.
					_type 			= STATIC or DYNAMIC mask?
					dynamic_mask	= icon file for any dynamic masks.
				*/
				if( !is_emitter() )	return
				//	if we're not an occluder.. cancel!
				. = 255*clamp( brightness, 0, 1 )

				if( _type == STATIC )
					var/obj/masks/_STATIC/default_emitter/a		= new /obj/masks/_STATIC/default_emitter
					a.color			= rgb( . , . , . )
					vis_contents 	+= a

				else
					var/obj/masks/_DYNAMIC/default_emitter/a		= new /obj/masks/_DYNAMIC/default_emitter
					a.icon			= dynamic_mask
					a.color			= rgb( . , . , . )
					vis_contents 	+= a



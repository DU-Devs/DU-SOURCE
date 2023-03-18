//	This library is a set of procs for finding, setting,
//	and shifting the absolute pixel positions of atoms.

//	(1, 1) is the bottom-left pixel of the map.

#ifndef TILE_WIDTH
#define TILE_WIDTH 32
#endif

#ifndef TILE_HEIGHT
#define TILE_HEIGHT 32
#endif

atom
	proc
		/* Get the pixel width of this atom's bounding box.
		*/
		Width()  . = TILE_WIDTH

		/* Get the pixel height of this atom's bounding box.
		*/
		Height() . = TILE_HEIGHT

		/* Get the absolute pixel-x-coordinate of the bounding box's left edge.
		*/
		Px(P) . = 1 + (x - 1 + P) * TILE_WIDTH

		/* Get the absolute pixel-y-coordinate of the bounding box's bottom edge.
		*/
		Py(P) . = 1 + (y - 1 + P) * TILE_HEIGHT

		/* Get the absolute pixel-x-coordinate of the bounding box's center.
		*/
		Cx() . = Px(1 / 2)

		/* Get the absolute pixel-y-coordinate of the bounding box's center.
		*/
		Cy() . = Py(1 / 2)

atom/movable
	Width()  . = bound_width
	Height() . = bound_height
	Px(P) . = 1 + bound_x + step_x + (x - 1) * TILE_WIDTH  + P * bound_width
	Py(P) . = 1 + bound_y + step_y + (y - 1) * TILE_HEIGHT + P * bound_height

	var
		/* Accumulates the fractional part of movements in the x-axis.
		*/
		fractional_x

		/* Accumulates the fractional part of movements in the y-axis.
		*/
		fractional_y

	proc
		/* Directly sets the loc and step offsets to the given arguments.

		Best to use a proc for this in case you want to add side effects, which
		you can't have if you're just setting variables directly in code.
		*/
		SetLoc(Loc, StepX = 0, StepY = 0)
			loc = Loc
			step_x = StepX
			step_y = StepY

		/* Directly sets the loc and step offsets in order for the bottom-left
		of the bounding box to be at a given absolute pixel coordinate, or
		to the bottom-left of a given atom.

		Format: SetPosition(atom/Atom)
		Parameters:
		* Atom: The object to align bounding box bottom-left corners with.

		Format: SetPosition(Px, Py, Z)
		Parameters:
		* Px: The desired resulting left x-coordinate.
		* Py: bottom y-coordinate.
		* Z: z-level.
		*/
		SetPosition(Px, Py, Z)
			if(isloc(Px))
				var atom/a = Px
				Px = a.Px()
				Py = a.Py()
				Z = a.z
			SetLoc(
				Loc = locate(
					1 + (Px-1)/TILE_WIDTH,
					1 + (Py-1)/TILE_HEIGHT,
					isnull(Z) ? z : Z),
				StepX = (Px-1) % TILE_WIDTH  - bound_x,
				StepY = (Py-1) % TILE_HEIGHT - bound_y)

		/* Directly sets the loc and step offsets in order for the center of the
		bounding box to be at a given absolute pixel coordinate, or at the
		center of a given atom.

		Behaves kinda screwy (i.e. sends you to the void) at map edges.

		Format: SetCenter(atom/Atom)
		Parameters:
		* Atom: The atom to align bounding box centers with.

		Format: SetCenter(Cx, Cy, Z)
		Parameters:
		* Cx: The desired resulting center x-coordinate.
		* Cy: y-coordinate.
		* Z: z-level.
		*/
		SetCenter(Cx, Cy, Z)
			if(isloc(Cx))
				var atom/a = Cx
				Cx = a.Cx()
				Cy = a.Cy()
				Z = a.z
			SetPosition(Cx - Width()/2, Cy - Height()/2, Z)

		/* Slides this movable atom by a given offset in pixels.

		Fractional movements are preserved in the fractional_x/y variables.
		Preserved, as in successive calls to Translate(0.1, 0) will
		eventually add up to a single-pixel movement to the right.

		Parameters:
		* X: Distance to move along the x-axis in pixels.
		* Y: Distance to move along the y-axis in pixels.

		Returns:
		* null if both arguments are false.
		* TRUE if only the fractional values changed.
		* The result of Move() for a successful whole-pixel movement.
		*/
		Translate(X, Y)
			if(!(X || Y)) return
			var rx, ry
			if(X)
				fractional_x += X
				rx = round(fractional_x, 1)
				fractional_x -= rx
			if(Y)
				fractional_y += Y
				ry = round(fractional_y, 1)
				fractional_y -= ry
			var s = step_size
			step_size = max(abs(rx), abs(ry)) + 1
			. = (rx || ry) ? Move(loc, dir, step_x + rx, step_y + ry) : TRUE
			step_size = s

		/* Slides this movable atom by a given polar vector.

		Uses Translate(), so fractional movements are preserved.

		Parameters:
		* Distance: Distance to move in pixels.
		* Angle: Direction to move in degrees clockwise from NORTH.

		Returns:
		* Whatever Translate() returns.
		*/
		Project(Distance, Angle)
			. = Translate(Distance * sin(Angle), Distance * cos(Angle))

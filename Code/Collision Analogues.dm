atom
	proc
		Bumped(atom/movable/O)

	Enter(atom/movable/O,atom/oldloc)
		. = O.onEnter(src,oldloc)

	Exit(atom/movable/O,atom/newloc)
		. = O.onExit(src,newloc)

	Entered(atom/movable/O,atom/oldloc)
		O.onEntered(src,oldloc)

	Exited(atom/movable/O,atom/newloc)
		O.onExited(src,newloc)

	movable
		proc
			onEnter(atom/O,atom/oldloc)
				. = !(density&&O.density)

			onExit(atom/O,atom/newloc)
				. = 1

			onCross(atom/movable/O)
				. = !(density&&O.density)

			onUncross(atom/movable/O)
				. = 1

			onEntered(atom/movable/O,atom/oldloc)
			onExited(atom/movable/O,atom/newloc)
			onCrossed(atom/movable/O)
			onUncrossed(atom/movable/O)

		Cross(atom/movable/O)
			. = O.onCross(src)

		Uncross(atom/movable/O)
			. = O.onUncross(src)

		Crossed(atom/movable/O)
			O.onCrossed(src)

		Uncrossed(atom/movable/O)
			O.onUncrossed(src)

		Bump(atom/O)
			O.Bumped(src)
/*
	libpathfinder
		by Kuraudo


	Currently supporting the A* pathfinding algorithm. Future versions
	may add additional algorithms; this library was designed with
	extensibility in mind.

	This library was inspired by the Pathfinder library by Theodis.	It
	reflects what I believe to be a better design; rather than defining
	callback procs as in Theodis.Pathfinder, you create a derived type
	of the desired /pathfinder algorithm. This method should also be faster,
	due to DM's call() being slightly slow, though he uses some other tricks
	to offset this. The two libraries should run roughly as fast as each other
	in most cases.

	By default, the algorithms in this library will operate over /turf objects.
	However, it is possible to use them across any type of object, to allow for
	theoretical pathfinding or movement. Only some procs need to be overridden
	to handle new types.

	The list of procs that need to be overridden to handle new types:

		- pathfinder/proc/distance(a, b)

		- pathfinder/proc/neighbors(a)

		- pathfinder/proc/weight(a)

	Here are their functions (as defined for turfs):

		distance(a, b)
			-	A distance heuristic between a and b.

			-	By default, if a and b are one tile apart,
				the result is the sum of the squares of the
				difference in x and y coordinates between
				them, added to the average of the weight values.
				Otherwise it is the result of get_dist(a, b).

		neighbors(a)
			-	Returns a list of locations adjacent to a
				that may be entered.

			-	By default, a list of non-dense tiles in oview(1, a)
				is returned.

		weight(a)
			-	Returns the specific weight value for a to algorithms
				that use this (such as A*). For example, if it were
				twice as hard to move through sand than through
				grass, you might give grass a weight of 1 and
				sand a weight of 2.

			-	By default, this returns 1.


	For the demos, weight() and neighbors() have been overridden in a new
	/pathfinder/astar/demo type. The changed functionality is this:

		weight(turf/a)
			-	Returns the value of the demo-specific "path_weight" var which
				belongs to the "a" turf.

		neighbors(turf/a)
			-	Returns a list of non-dense turfs containing no dense objects
				accessible from "a" via one of the cardinal directions.


	To use an algorithm, create a new object of the desired /pathfinder type and
	call search(start, end); this returns null if no path could be found. Otherwise,
	it returns a list of objects consisting of the path.
	Thus:

		var/pathfinder/astar/demo/demo_path = new	// the demo implementation of A*
		var/list/path = demo_path.search(start, end)

		if(path)
			//	path found
		else
			//	no path found

	***
		NOTE: If you used a previous version of libpathfinder, the following has changed:
		- The pathfinder "path" var no longer exists. This means that New() can no
		longer be used to generate paths. The search() proc now returns the resulting path
		directly.
	***
*/
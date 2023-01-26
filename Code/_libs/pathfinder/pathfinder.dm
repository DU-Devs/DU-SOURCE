pathfinder
	proc
		search()

		weight(turf/t)
			return 1

		distance(turf/a, turf/b)	// the distance heuristic between a and b
			. = get_dist(a, b)
			if(. == 1)
				var/dx = a.x - b.x
				var/dy = a.y - b.y

				return (dx*dx + dy*dy + (weight(a)+weight(b))/2)


		neighbors(turf/a)	// return a heterogenous list of neighboring objects
			. = new/list

			for(var/turf/t in oview(1, a))
				if(!t.density)
					. += t
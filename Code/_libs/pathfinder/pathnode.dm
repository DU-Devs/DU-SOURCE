pathnode
	var
		source
		pathnode/parent

		g	// the actual shortest distance traveled from initial node to current node
		h	// the estimated (or "heuristic") distance from current node to goal
		f	// the sum of g and h

	New(source, parent, g, h)
		src.source = source
		src.parent = parent
		src.g = g
		src.h = h
		src.f = g + h

	proc
		cmp(pathnode/a, pathnode/b)
			return a.f - b.f
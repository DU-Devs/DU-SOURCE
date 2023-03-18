pathfinder/astar
	search(start, end)
		var
			PriorityQueue/open = new/PriorityQueue(/pathnode/proc/cmp)
			list/closed = new

			pathnode/node = new(start, null, 0, distance(start, end))

		open.Enqueue(node)

		while(!open.IsEmpty())
			node = open.Dequeue()

			if(node.source == end)	// finished
				var/list/L = new

				do
					L += node.source
					node = node.parent
				while(node.parent)

				var/half_len = L.len/2
				for(var/i=1, i<=half_len, ++i)
					L.Swap(i, L.len-i+1)

				return L

			else
				closed += node.source

				var/pathnode/new_node
				for(var/d in neighbors(node.source))
					new_node = new(d, node, node.g+distance(node.source,d), distance(d,end))

					if(closed.Find(d))
						continue

					var/skip = FALSE

					for(var/pathnode/n in open.L)
						if(n.source == d)
							if(new_node.g < n.g)
								open.L  -= n
							else
								skip = TRUE
							break

					if(skip)
						continue

					open.Enqueue(new_node)
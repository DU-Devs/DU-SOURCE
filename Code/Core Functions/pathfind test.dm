/*

Please let me know if you run into any problems while using this library.



2 simple steps to create a multitile atom:

First, set the atom's multitile var/to one of the following values:

TWO_TALL	(two tiles tall, one tile wide)
TWO_WIDE	(two tiles wide, one tile tall)
FOUR_SQUARE	(four tiles arranged in a square)

Next, call the G_multitile() proc.
This is typically done as part of the atom's New() proc.

See the demo for an example of how to do this.



Additional atom configurations may be easily added.  To do so:
1) Open G-Move.dme
2) Add the following line: #define YOUR_DESIGNATION_HERE 4
	(For simplicity, use the same format as the existing definitions.)
3) In G-Move.dm, find the G_multitile() proc.
4) Add YOUR_DEFINITION_HERE to the switch.
5) Adjust xl and yl as necessary.  x[1] corresponds to y[1], etc.
6) Compile, and your new configuration is ready for use.



Implementation:

The following is a list of procs that are of likely interest to you,
along with an explanation of what they do and/or how they are used.


Can_Enter(turf/T,no_warp)
	Simply put, this is the equivalent of the returned portion of Enter()
	In this case, we're looking to see whether src can enter turf T.
	Multitile atoms are, of course, taken into account.
	Setting no_warp to 1 returns 0 if any of the turfs in question are warps.
	By default (no_warp = 0), warps are treated just like any other turf type.

G_get_dir(atom/A,atom/B)
G_getdist(atom/A,atom/B)
G_get_true_dist(atom/A,atom/B)

	These procs find the direction or shortest distance between two atoms.
	Either, both, or neither of the two atoms may be multitile.
	G_getdist() behaves just like getdist()
	G_get_true_dist() returns the hypotenuse of the triangle formed by the
		two closest component tiles of A and B

G_Get_step(Dir)
G_step(Dir)
G_walk(Dir,Lag=1)

	Notice that all movement procs in this library take the
	Ref argument and make it the proc's src.
	Thus walk(Ref,Dir,Lag=0) becomes src.walk(Dir,Lag=0)

	These three procs are no different from their default
	counterparts.  They were recreated for the library for
	the sake of continuity.

G_get_step_to(Trg,Min=0,Limit=10)
g_step_to(Trg,Min=0,Limit=10)
G_walk_to(Trg,Min=0,Lag=1,Limit=10)

	walk_to(Ref,Trg,Min=0,Lag=0) for comparison:

	Aside from multitile support, there are a few important changes
	in the way g_step_to() works.

	First, regardless of how far apart Trg and src are located,
	src will still plot a course in the direction of Trg.

	Second is the added Limit argument.
	As paths are generated, the number of steps required to
	reach any point in a potential path is stored.  If this
	number exceeds Limit, then the best possible path is
	chosen.  Put another way, g_step_to() returns the first step
	on the path that is the best 10-step path, if Limit is 10.
	Limit behaves this way for all procs that use it.

	Third, G_step_to can plot a simple course through warps to reach
	Trg.  So even if Trg and src are on different z levels, or even
	far apart on the same z-level, the movement system can in many cases
	plot a course between Trg and src.

G_get_step_away(Trg,Max=5,Min=0,Limit=10)
G_step_away(Trg,Max=5,Min=0,Limit=10)
G_walk_away(Trg,Max=5,Min=0,Lag=1,Limit=10)

	walk_away(Ref,Trg,Max=5,Lag=0) for comparison:

	The new Min value represents the closest that src
	will pass by Trg while trying to step/walk away.
	Thus instead of stupidly walking into a corner
	while trying to walk_away from Trg, src might instead
	walk past Trg and flee in the other direction.

G_get_step_towards(Trg,Min=0)
G_step_towards(Trg,Min=0)
G_walk_towards(Trg,Min=0,Lag=1)

	One major change:
	Instead of being hung up on every single obstacle as with step_toward(),
	simple obstructions will be side-stepped.

G_get_step_rand()
G_step_rand()
G_walk_rand(Lag=1)

	This is similar to step_rand(), but with added multitile support.
	Two important details:
	Steps are only taken in directions in which the atom can move.
		i.e. - A dense atom will never try to walk into a wall.
	Warps are avoided.


G_get_stumble_step_to(Trg,Min=0,Prob=100)
G_get_stumble_step_away(Trg,Max=100,Prob=100)
G_stumble_step_to(Trg,Min=0,Prob=100)
G_stumble_step_away(Trg,Max=100,Prob=100)
G_stumble_walk_to(Trg,Min=0,Lag=1,Prob=100)
G_stumble_walk_away(Trg,Max=100,Lag=1,Prob=100)

	G_stumble_step_to/away() can best be described as a sort of drunken swagger.

	In the case of G_stumble_step_to(), src takes a random step that places src either
	closer to or no-further-away from Trg.  The opposite is true of G_stumble_step_away().

	Prob-100 is the probability of src taking a step in a completely random direction.
	Prob=100 is thus a 100% stumble success rate.

*/
mob/Admin5/verb/Pathfind(mob/P in world)
	while(src)
		g_step_to(P)
		if(P in view(1,src)) return
		sleep(1)
atom/movable
	proc
		G_Get_step(Dir)
			G_path_check()
			. = Get_step(src,Dir)

		G_get_step_away(Trg,Max=5,Min=0,Limit=10)
			G_path_check()
			if(Trg) . = g_path.StepAway(Trg,Max,Min,Limit,1)

		G_get_step_rand()
			G_path_check()
			. = g_path.StepRand(,,,,1)

		G_get_step_to(Trg,Min=0,Limit=20)
			G_path_check()
			if(Trg) . = g_path.StepTo(Trg,Min,Limit,1)

		G_get_step_towards(Trg,Min=0)
			G_path_check()
			if(Trg) . = g_path.StepTowards(Trg,Min,1)

		G_get_stumble_step_to(Trg,Min=0,Prob=100)
			G_path_check()
			if(Trg) . = g_path.StepRand(Trg,Min,Prob,,1)

		G_get_stumble_step_away(Trg,Max=100,Prob=100)
			G_path_check()
			if(Trg) . = g_path.StepRand(Trg,Max,Prob,1,1)



		G_step(Dir)
			G_path_check()
			g_type = 0
			. = step(src,Dir)

		G_step_away(Trg,Max=5,Min=0,Limit=10)
			G_path_check()
			g_type = 0
			if(Trg) . = g_path.StepAway(Trg,Max,Min,Limit)

		G_step_rand()
			G_path_check()
			g_type = 0
			. = g_path.StepRand()

		g_step_to(Trg,Min=0,Limit=20)
			G_path_check()
			g_type = 0
			if(Trg) . = g_path.StepTo(Trg,Min,Limit)

		G_step_towards(Trg,Min=0)
			G_path_check()
			g_type = 0
			if(Trg) . = g_path.StepTowards(Trg,Min)

		G_stumble_step_to(Trg,Min=0,Prob=100)
			G_path_check()
			g_type = 0
			if(Trg) . = g_path.StepRand(Trg,Min,Prob)

		G_stumble_step_away(Trg,Max=100,Prob=100)
			G_path_check()
			g_type = 0
			if(Trg) . = g_path.StepRand(Trg,Max,Prob,1)



		G_step_path(Dir,Lag=0)
			G_path_check()
			G_tick()
			if(g_type == 1 && g_path.step_path)
				g_path.step_path += Dir
			else
				g_path.step_path = list(Dir)
			g_type = 1
			g_lag = Lag

		G_walk(Dir,Lag=0)
			if(!Dir)
				g_type = 0
				g_target = null
				return
			G_path_check()
			G_tick()
			g_type = 2
			g_target = Dir
			g_lag = Lag

		G_walk_away(Trg,Max=5,Min=0,Lag=0,Limit=10)
			G_path_check()
			G_tick()
			g_type = 3
			g_target = Trg
			g_limit = Limit
			g_min = Min
			g_max = Max
			g_lag = Lag

		G_walk_rand(Lag=0)
			G_path_check()
			G_tick()
			g_type = 4
			g_lag = Lag

		G_walk_to(Trg,Min=0,Lag=0,Limit=10)
			G_path_check()
			G_tick()
			g_type = 5
			g_target = Trg
			g_limit = Limit
			g_min = Min
			g_lag = Lag

		G_walk_towards(Trg,Min=0,Lag=0)
			G_path_check()
			G_tick()
			g_type = 6
			g_target = Trg
			g_min = Min
			g_lag = Lag

		G_stumble_walk_to(Trg,Min=0,Lag=0,Prob=100)
			G_path_check()
			G_tick()
			g_type = 7
			g_target = Trg
			g_limit = Prob
			g_min = Min
			g_lag = Lag

		G_stumble_walk_away(Trg,Max=100,Lag=0,Prob=100)
			G_path_check()
			G_tick()
			g_type = 8
			g_target = Trg
			g_limit = Prob
			g_max = Max
			g_lag = Lag

		G_tick() if(!g_tick)
			g_tick = 1
			spawn() for()
				sleep(max(1,g_lag+g_spd))
				if(g_type != 1) if(g_path.step_path)
					g_path.step_path.Cut()
					g_path.step_path = null
				if(g_type != 3 && g_type != 5) if(g_path.path)
					g_path.path.Cut()
					g_path.path = null
				if(g_renew_path) if(g_path.path)
					g_path.path.Cut()
					g_path.path = null
				switch(g_type)
					if(0)
						g_tick = 0
						return
					if(1) if(g_path.step_path.len)
						var
							current_position = loc
							temp_dir = g_path.step_path[1]
						step(src,temp_dir)
						g_path.step_path.Cut(1,2)
						if(loc == current_position) while(g_path.step_path.len)
							if(temp_dir == g_path.step_path[1]) g_path.step_path.Cut(1,2)
							else break
					if(2)
						step(src,g_target)
					if(3) if(g_target) if(g_target.loc)
						g_path.StepAway(g_target,g_max,g_min,g_limit)
					if(4)
						g_path.StepRand()
					if(5) if(g_target) if(g_target.loc)
						g_path.StepTo(g_target,g_min,g_limit)
					if(6) if(g_target) if(g_target.loc)
						g_path.StepTowards(g_target,g_min)
					if(7) if(g_target) if(g_target.loc)
						g_path.StepRand(g_target,g_min,g_limit)
					if(8) if(g_target) if(g_target.loc)
						g_path.StepRand(g_target,g_max,g_limit,1)

turf
	var/tmp
		turf/dest
		PathNode/AI_pathnode
	proc/can_access(atom/movable/M)
		. = list()
		for(var/turf/T in range(1,src) - src)
			. += T
	warp/New()
		. = ..()
		if(dest)
			var/turf/T = locate(dest)
			if(T) dest = T
			else dest = null
	//LOOK BELOW!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 4/11/2015
	/*Enter(atom/movable/M)
		if(dest) if(!M.multitile&&M.can_warp)
			M.G_warp(dest,src)
		else . = ..()*/

PathController
	var/tmp
		atom/movable/owner
		turf/dest_turf
		atom/dest
		list
			step_path
			path
			open
			closed
			nodes
	New(O)
		owner = O
		return . = ..()
	proc
		StepTo(new_dest,min,limit,get_step) if(isturf(owner.loc))
			if(!owner) return
			var/turf/old_dest = dest_turf
			dest = new_dest
			dest_turf = new_dest
			while(dest_turf&&!isturf(dest_turf)&&dest_turf.loc) dest_turf=dest_turf.loc
			if(owner.loc == dest_turf) return
			if(length(path) && dest_turf != old_dest)
				var/in_path
				for(var/turf/T in path) if(T == dest_turf) {in_path = 1;break}
				if(!in_path) if(path[path.len] != old_dest)
					var/l[] = old_dest.can_access(owner)
					for(var/turf/T in l) if(T == dest_turf)
						path.Cut(path.len)
						in_path = 1
						break
				if(!in_path)
					var
						turf/last = path[path.len]
						l[] = last.can_access(owner)
					for(var/turf/T in l) if(T == dest_turf)
						path.Cut(path.len)
						in_path = 1
						break
				if(!in_path && path)
					path.Cut()
					path = null
			if(!length(path))
				Path(limit)
				if(length(path) < 2)
					if(path)
						path.Cut()
						path = null
					return
				path.Cut(1,2)
			if(owner.z == dest.z && G_getdist(owner,dest) <= min) if(!get_step)
				owner.dir = G_get_dir(owner,dest)
				owner.G_adjust_icon()
			else if(get_step)
				var/turf/T
				while(!T&&path.len)
					T = get_step_towards(owner,path[1])
					if(owner.Can_Enter(T)) . = T
					else T = null
					path.Cut(1,2)
			else
				var/turf/T
				while(!T && path.len)
					T = get_step_towards(owner,path[1])
					if(owner.Can_Enter(T))
						step_towards(owner,T)
					else T = null
					path.Cut(1,2)
				if(T)
					. = 1
				else
					if(path)
						path.Cut()
						path = null
					return StepRand(dest,,100)

		StepAway(new_dest,max,min,limit,get_step) if(isturf(owner.loc))
			var/turf/old_dest = dest_turf
			dest = new_dest
			dest_turf = new_dest
			while(!isturf(dest_turf)) dest_turf = dest_turf.loc
			if(length(path) && dest_turf != old_dest) for(var/turf/T in path)
				if(G_getdist(owner,dest,T.x-owner.x,T.y-owner.y) < min)
					path.Cut()
					path = null
					break
			if(!length(path))
				Path(limit,max,min)
				if(length(path) < 2)
					if(path)
						path.Cut()
						path = null
					return
				path.Cut(1,2)
			if(G_getdist(owner,dest) >= max) if(!get_step)
				owner.dir = G_get_dir(dest,owner)
				owner.G_adjust_icon()
			else if(get_step)
				var/turf/T
				while(!T&&path.len)
					T = get_step_towards(owner,path[1])
					if(owner.Can_Enter(T)) . = T
					else T = null
					path.Cut(1,2)
			else
				var/turf/T
				while(!T&&path.len)
					T = get_step_towards(owner,path[1])
					if(owner.Can_Enter(T)) step_towards(owner,T)
					else T = null
					path.Cut(1,2)
				if(T)
					. = 1
				else
					if(path)
						path.Cut()
						path = null
					return StepRand(dest,,100,1)

		StepTowards(new_dest,min,get_step) if(isturf(owner.loc))
			dest = new_dest
			dest_turf = new_dest
			while(!isturf(dest_turf)) dest_turf = dest_turf.loc
			if(owner.loc == dest_turf) return
			var
				can_access[] = owner.loc:can_access(owner)
				turf/T = owner.loc
				T_dest = G_get_true_dist(owner,dest)
			for(var/i = 1 to can_access.len)
				var
					turf/T2 = can_access[i]
					T2_dest
				if(owner.Can_Enter(T2))
					T2_dest = G_get_true_dist(owner,dest,T2.x-owner.x,T2.y-owner.y)
					if(T2_dest < T_dest) {T = T2; T_dest = T2_dest}
			if(!T)
			else if(G_getdist(owner,dest) <= min) if(!get_step)
				owner.dir = G_get_dir(owner,dest)
				owner.G_adjust_icon()
			else if(get_step)
				. = get_step_towards(owner,T)
			else if(step_towards(owner,T))
				. = 1

		StepRand(new_dest,limit,stumble_prob,away,get_step) if(isturf(owner.loc))
			var
				can_access[] = owner.loc:can_access(owner)
				PathNode/P
			nodes = list()
			if(new_dest)
				var/current = G_getdist(owner,new_dest)
				if(away)
					if(current >= limit) return Clear()
					if(prob(stumble_prob)) for(var/i = 1 to can_access.len)
						var/turf/T = can_access[i]
						if(owner.Can_Enter(T,1))
							if(G_getdist(owner,new_dest,T.x-owner.x,T.y-owner.y) >= current)
								P = T.AI_pathnode
								if(!P) P = new /PathNode(T,,owner)
								Sort(P)
				else
					if(current <= limit) return Clear()
					if(prob(stumble_prob)) for(var/i = 1 to can_access.len)
						var/turf/T = can_access[i]
						if(owner.Can_Enter(T,1))
							if(G_getdist(owner,new_dest,T.x-owner.x,T.y-owner.y) <= current)
								P = T.AI_pathnode
								if(!P) P = new /PathNode(T,,owner)
								Sort(P)
			if(!nodes.len) for(var/i = 1 to can_access.len)
				var/turf/T = can_access[i]
				if(owner.Can_Enter(T,1))
					P = T.AI_pathnode
					if(!P) P = new /PathNode(T,,owner)
					Sort(P)
			if(!nodes.len) if(new_dest)
				if(away) owner.dir = G_get_dir(new_dest,owner)
				else owner.dir = G_get_dir(owner,new_dest)
				owner.G_adjust_icon()
			else
				var/l[] = list()
				for(var/PathNode/P2 in nodes)
					if(l.len < 3)
						l += P2.turf
					else
						var/lower,higher[] = list()
						for(var/PathNode/P3 in l)
							if(P3.total < P2.total)
								lower++
							else if(P3.total > P2.total)
								higher += P3
						if(lower >= 3) continue
						l += P2.turf
						if(prob(33*higher.len)) l -= pick(higher)
				if(get_step)
					. = get_step_towards(owner,pick(l))
				else if(step_towards(owner,pick(l)))
					if(new_dest)
						if(away) owner.dir = G_get_dir(new_dest,owner)
						else owner.dir = G_get_dir(owner,new_dest)
						owner.G_adjust_icon()
					. = 1
			Clear()

		Path(limit,max,min)
			open = list(owner.loc)
			closed = list()
			if(max) path = Sequence(SearchAway(limit,max,min))
			else path = Sequence(SearchTo(limit))
			Clear()

		Clear()
			for(var/N in nodes) N:Clear()
			for(var/turf/T in closed) T.AI_pathnode.Clear()
			for(var/turf/T in open) if(T.AI_pathnode) T.AI_pathnode.Clear()
			nodes.Cut();				nodes = null
			if(open) 	{open.Cut();	open = null}
			if(closed)	{closed.Cut();	closed = null}

		SearchTo(limit)
			var
				PathNode
					P = new(owner.loc,,owner,0,G_get_true_dist(owner,dest))
					Best = P
				turf/tdest
			nodes = list(P)
			if(!owner.can_warp)
				tdest = dest
			else if(get_step_to(owner,dest))
				tdest = dest
			else if(owner.multitile) for(var/atom/movable/M in owner.components) if(get_step_to(M,dest))
				tdest = dest
				break
			if(!tdest)
				var/mob/G_Step_Test/S = get_g_step_mob()
				S.density = owner.density
				if(owner.z == dest.z)
					tdest = dest
					goto Search
				Search
				S.SafeTeleport(null)
			if(tdest) while(nodes.len)
				P = nodes[1]
				var/turf/T = P.turf
				if(!G_getdist(owner,tdest,T.x-owner.x,T.y-owner.y))
					if(owner.Can_Enter(T)) return P
					else return Best
				if(closed.Find(T))
					nodes.Cut(1,2)
					continue
				if(owner.multitile) if(!owner.Can_Enter(T))
					nodes.Cut(1,2)
					continue
				if(G_getdist(owner,tdest,T.x-owner.x,T.y-owner.y) < G_getdist(owner,tdest,Best.turf.x-owner.x,Best.turf.y-owner.y))
					if(owner.Can_Enter(T)) Best = P
				if(nodes.len > AI_PATHNODE_LIMIT)
					return Best
				if(limit && P.cost >= limit)
					return Best
				nodes.Cut(1,2)
				closed += T
				open -= T
				var
					can_access[] = T.can_access(owner)
					new_cost = P.cost + 1
				for(var/i = 1 to can_access.len)
					var/turf/T2 = can_access[i]
					if(!owner.Possible_Path(T2,tdest)) continue
					var/PathNode/P2 = T2.AI_pathnode
					if(P2)
						if(new_cost >= P2.cost) continue
						if(closed.Find(T2))
							open += T2
							closed -= T2
						else
							nodes -= P2
						P2.cost = new_cost
						P2.parent = P
					else
						var/dist = G_get_true_dist(owner,tdest,T2.x-owner.x,T2.y-owner.y)
						P2 = new /PathNode(T2,P,owner,new_cost,dist)
						open += T2
					if(!G_getdist(owner,tdest,T2.x-owner.x,T2.y-owner.y)) return P2
					Sort(P2)
			return Best

		SearchAway(limit,max,min)
			var
				PathNode
					P = new(owner.loc,,owner,0,G_get_true_dist(owner,dest))
					Best = P
				current_min = G_getdist(owner,dest,Best.turf.x-owner.x,Best.turf.y-owner.y)
			nodes = list(P)
			while(nodes.len)
				P = nodes[1]
				var/turf/T = P.turf
				if(G_getdist(owner,dest,T.x-owner.x,T.y-owner.y) >= max)
					if(owner.Can_Enter(T)) return P
				if(closed.Find(T))
					nodes.Cut(1,2)
					continue
				if(owner.multitile) if(!owner.Can_Enter(T))
					nodes.Cut(1,2)
					continue
				switch(G_getdist(owner,dest,T.x-owner.x,T.y-owner.y) - G_getdist(owner,dest,Best.turf.x-owner.x,Best.turf.y-owner.y))
					if(1)
						if(owner.Can_Enter(T)) Best = P
					if(0) if(G_get_true_dist(owner,dest,T.x-owner.x,T.y-owner.y) > G_get_true_dist(owner,dest,Best.turf.x-owner.x,Best.turf.y-owner.y))
						if(owner.Can_Enter(T)) Best = P
				if(nodes.len > AI_PATHNODE_LIMIT) return Best
				if(limit && P.cost >= limit) return Best
				nodes.Cut(1,2)
				closed += T
				open -= T
				var
					can_access[] = T.can_access(owner)
					new_cost = P.cost + 1
				for(var/i = 1 to can_access.len)
					var
						turf/T2 = can_access[i]
						T2_dist = G_getdist(owner,dest,T2.x-owner.x,T2.y-owner.y)
					if(!owner.Can_Enter(T2)) continue
					if(T2_dist < min)
						if(T2_dist < current_min) continue
						current_min = T2_dist
					var/PathNode/P2 = T2.AI_pathnode
					if(P2)
						if(new_cost >= P2.cost) continue
						if(closed.Find(T2))
							open += T2
							closed -= T2
						else
							nodes -= P2
						P2.cost = new_cost
						P2.parent = P
					else
						var/dist = G_get_true_dist(owner,dest,T2.x-owner.x,T2.y-owner.y)
						P2 = new /PathNode(T2,P,owner,new_cost,-2*dist)
						open += T2
					Sort(P2)
			return Best

		Sort(PathNode/P)
			var
				high = nodes.len
				low = 1
			P.total = P.Total(owner)
			while(low <= high)
				var
					mid = (low+high)/2
					i = round(mid)
				if(mid != i) i++
				var/PathNode/P2 = nodes[i]
				if(P.total <= P2.total)
					high = i - 1
				else
					low = i + 1
			nodes.Insert(low,P)

		Sequence(PathNode/P)
			if(P)
				var/l[] = Sequence(P.parent)
				l += P.turf
				return l
			else . = list()

proc
	G_get_dir(atom/movable/A,atom/movable/B) . = G_get(A,B,1)
	G_getdist(atom/movable/A,atom/movable/B,x_off,y_off) . = G_get(A,B,2,x_off,y_off)
	G_get_true_dist(atom/movable/A,atom/movable/B,x_off,y_off) . = G_get(A,B,3,x_off,y_off)

	G_get(atom/movable/A,atom/movable/B,function,x_off,y_off) if(isloc(A,B)&&!isarea(A)&&!isarea(B))
		var/list
			la;lb
		if(!isturf(A))
			while(!isturf(A.loc))
				if(!A.loc) return
				A = A.loc
			A = A.loc
		if(!isturf(B))
			while(!isturf(B.loc))
				if(!B.loc) return
				B = B.loc
			B = B.loc
		switch(function)
			if(1)
				if(la&&lb) for(var/atom/a in la) for(var/atom/b in lb)
					. = get_dir(a,b)
					if(. in list(NORTH,EAST,SOUTH,WEST)) return
				else if(la) for(var/atom/a in la)
					. = get_dir(a,B)
					if(. in list(NORTH,EAST,SOUTH,WEST)) return
				else if(lb) for(var/atom/b in lb)
					. = get_dir(A,b)
					if(. in list(NORTH,EAST,SOUTH,WEST)) return
				else
					. = get_dir(A,B)
			if(2)
				. = 1000
				if(la&&lb) for(var/atom/a in la) for(var/atom/b in lb)
					. = min(.,max(abs(a.x+x_off-b.x),abs(a.y+y_off-b.y)))
				else if(la) for(var/atom/a in la)
					. = min(.,max(abs(a.x+x_off-B.x),abs(a.y+y_off-B.y)))
				else if(lb) for(var/atom/b in lb)
					. = min(.,max(abs(A.x+x_off-b.x),abs(A.y+y_off-b.y)))
				else
					. = min(.,max(abs(A.x+x_off-B.x),abs(A.y+y_off-B.y)))
			else
				. = 1000
				if(la&&lb) for(var/atom/a in la) for(var/atom/b in lb)
					. = min(.,sqrt((a.x+x_off-b.x)**2+(a.y+y_off-b.y)**2))
				else if(la) for(var/atom/a in la)
					. = min(.,sqrt((a.x+x_off-B.x)**2+(a.y+y_off-B.y)**2))
				else if(lb) for(var/atom/b in lb)
					. = min(.,sqrt((A.x+x_off-b.x)**2+(A.y+y_off-b.y)**2))
				else
					. = min(.,sqrt((A.x+x_off-B.x)**2+(A.y+y_off-B.y)**2))

	G_get_closest(atom/movable/A,atom/movable/B,dist)
		var/list
			d = 1000
			la = list()
			lb = list()
		if(A.multitile) for(var/atom/C in A.components) la += C
		else la += A
		if(B.multitile) for(var/atom/C in B.components) lb += C
		else lb += B
		for(var/atom/a in la) for(var/atom/b in lb) if(b.loc in view(dist,a))
			var/t = sqrt((a.x-b.x)**2+(a.y-b.y)**2)
			if(t < d)
				d = t
				. = b

PathNode
	var
		cost
		dist
		total
		turf/turf
		PathNode/parent
	New(T,p,o,c,d)
		turf = T
		turf.AI_pathnode = src
		total = Total(o)
		parent = p
		cost = c
		dist = d
		return . = ..()
	proc
		Total(atom/movable/owner)
			. = cost + 1.5*dist + owner.G_turf_cost(turf)
		Clear()
			parent = null
			turf.AI_pathnode = null
			turf = null

mob/G_Step_Test
var/mob/g_step_mob
proc/get_g_step_mob()
	if(!g_step_mob) g_step_mob=new/mob/G_Step_Test
	return g_step_mob

atom/movable
	var/tmp
		PathController/g_path
		atom/movable/brain
		list/components
		atom/g_target
		g_renew_path
		g_position
		multitile
		can_warp
		g_limit
		g_tick
		g_type
		g_min
		g_max
		g_lag
		g_spd
	/*Move(turf/T,d)
		if(multitile)
			if(Can_Enter(T))
				for(var/atom/movable/C in components)
					var/turf/T2 = locate(T.x+C.x-x,T.y+C.y-y,T.z)
					if(T2.dest) return G_warp(T2.dest,T2)
				var/t = density
				density = 0
				. = ..()
				density = t
				if(.) for(var/atom/movable/C in components)
					C.loc = Get_step(C,d)
			G_adjust_icon()
		else
			. = ..()
			G_adjust_icon()*/
	proc
		G_path_check() if(!g_path) g_path = new(src)

		G_turf_cost(turf/T)

		Possible_Path(turf/T,turf/W)
			if(T.dest) if(!can_warp||(W&&T!=W)) return
			else if(density&&T.density) return
			return 1

		Can_Enter(turf/T,no_warp)
			if(multitile) for(var/atom/movable/C in components)
				var/turf/T2 = locate(T.x+C.x-x,T.y+C.y-y,T.z)
				if(!T2) return
				if(T2.dest) if(no_warp||!can_warp) return
				else if(density)
					if(T2.density) return
					for(var/atom/movable/M in T2.contents - src - components)
						if(M.density) return
			else
				if(T.dest) if(no_warp||!can_warp) return
				else if(density)
					if(T.density) return
					for(var/atom/movable/M in T.contents)
						if(M.density) return
			. = 1

		G_multitile(c_type) if(multitile)
			components = list()
			var/xl[],yl[]
			switch(multitile)
				if(FOUR_SQUARE)
					xl = list(0,1,0,1)
					yl = list(0,0,1,1)
				if(NINE_SQUARE)
					xl = list(0,1,2,0,1,2,0,1,2)
					yl = list(0,0,0,1,1,1,2,2,2)
				if(TWO_TALL)
					xl = list(0,0)
					yl = list(0,1)
				if(TWO_WIDE)
					xl = list(0,1)
					yl = list(0,0)
			for(var/v = 1 to xl.len)
				var/atom/movable/C = new c_type(locate(x+xl[v],y+yl[v],z))
				C.brain = src
				components += C
				C.density = density
				C.icon = icon
				C.g_position = "[xl[v]],[yl[v]]"
				C.animate_movement = 3
			G_adjust_icon()

		G_adjust_icon()
			if(multitile) for(var/atom/movable/C in components)
				if(icon_state) C.icon_state = "[icon_state] [C.g_position]"
				else C.icon_state = C.g_position
				C.dir = dir

		G_flick(s)
			if(multitile) for(var/atom/movable/C in components)
				flick("[s] [C.g_position]",C)
			else
				flick(s,src)

		G_warp(turf/T,turf/Old)
			if(brain) return brain.G_warp(T,Old)
			if(g_target == Old) G_walk(0)
			if(multitile)
				for(var/turf/T2 in range(3,T)) if(G_getdist(src,T,T2.x-x,T2.y-y) == 1) if(Can_Enter(T2))
					for(var/atom/movable/C in components)
						C.SafeTeleport(locate(T2.x+C.x-x,T2.y+C.y-y,T2.z))
					SafeTeleport(T2)
					dir = G_get_dir(T,src)
					G_adjust_icon()
					return
			else
				SafeTeleport(T)
				var/turf/T2 = Get_step(src,dir)
				if(T2) if(Can_Enter(T2))
					step_to(src,T2)
					return
				G_path_check()
				g_path.StepRand()
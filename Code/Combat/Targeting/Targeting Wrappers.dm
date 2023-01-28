mob/proc/FindHakaiTarget()
	var/dist = 4
	var/list/targets = FindTargets(dir_angle = dir, angle_limit = 33, max_dist = dist, prefer_auto_target = 1)
	if(!targets) return
	for(var/mob/m in targets) if(!IsViableHakaiTarget(m, dist)) targets-=m
	if(targets.len) return targets[1]

mob/proc/IsViableHakaiTarget(mob/m, max_dist = 5)
	if(m.type == /mob/Body) return
	if(m.Safezone) return
	if(alignment_on && both_good(src, m)) return
	if(Same_league_cant_kill(src, m)) return
	if(m.IsValidTarget(m, max_dist)) return 1





obj/Blast/proc/GetBlastHomingTarget(d, angle)
	if(!d) d = dir
	if(!angle) angle = blast_tracking_angle_limit
	var/list/targets = FindTargets(dir_angle = d, angle_limit = angle, max_dist = 30, prefer_auto_target = 1)
	if(!targets) return
	for(var/mob/m in targets) if(!Is_viable_homing_target(m)) targets-=m
	if(targets.len) return targets[1]





var/lunge_angle_limit = 33

mob/proc/Is_viable_lunge_target(mob/m)
	if(m && ismob(m) && m!=src && get_dist(src,m)>0 && get_abs_angle(src,m) < lunge_angle_limit && At_forward_half(m) && viewable(src,m,Get_lunge_targeting_distance()))
		if(m.type != /mob/Body && !m.KO)
			return 1

mob/proc/LungeTarget(dist_override)
	var/dist = Get_lunge_targeting_distance()
	if(dist_override) dist = dist_override
	var/list/targets = FindTargets(dir_angle=dir, angle_limit = lunge_angle_limit, max_dist = dist, prefer_auto_target=1)
	if(!targets) return
	for(var/mob/m in targets) if(!Is_viable_lunge_target(m)) targets-=m
	if(targets.len) return targets[1]

mob/proc
	//this is a wrapper function example of FindTargets for situations that need to check validity of targets using extra specifications
	FindWarpTarget(dir_angle=NORTH, angle_limit=44, max_dist=10, prefer_auto_target=0)
		var/list/targets = FindTargets(dir_angle, angle_limit, max_dist, prefer_auto_target)
		if(!targets) return
		for(var/mob/m in targets) if(!IsValidWarpTarget(m, max_dist)) targets-=m
		if(targets.len) return targets[1]

	IsValidWarpTarget(mob/m, max_dist=10)
		if(m.KB || m.KO || m.type == /mob/Body) return
		if(m.IsValidTarget(m, max_dist)) return 1
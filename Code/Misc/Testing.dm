mob/var/tmp/last_flip = 0

mob/proc/Flip()
	set waitfor=0
	if(world.time - last_flip < 3) return
	last_flip = world.time
	var/d = pick(90,-90)
	for(var/v in 1 to 4)
		animate(src, transform = turn(src.transform, d), time = world.tick_lag)
		sleep(world.tick_lag)
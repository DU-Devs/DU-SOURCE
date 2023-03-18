


// written by kumorii.

atom/movable
	proc


		despawn(_delay = 0, fadeout = 0)
			/* called to make a thing despawn after _delay seconds.
				fadeout = 1 if the thing should fade out instead of just being culled.
			*/
			set waitfor = 0
			sleep (10*_delay)

			if(fadeout)
				animate(src, alpha = 0, time = 10, easing = CUBIC_EASING)
				sleep 10

			loc = null
			del src

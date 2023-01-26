client
	var
		numScrolls = 0
		waitForReset = 0
		lastZChange = 0

	MouseWheel(atom/A, delta_x, delta_y, location, control, params)
		if(!mob.playerCharacter) return
		if(!waitForReset)
			waitForReset = 1
			spawn(20)
				if(numScrolls && waitForReset) numScrolls = 0
				waitForReset = 0
		if(lastZChange +  10 < world.time) numScrolls++
		if(numScrolls >= 4)
			spawn() ChangeZPlane(delta_y)
			waitForReset = 0
			numScrolls = 0

	proc
		ChangeZPlane(direction)
			if(direction > 0) return UpZPlane()
			if(direction < 0) return DownZPlane()

		UpZPlane()
			if(DISABLE_SOAR) return
			if(!mob || mob.input_disabled || mob.KO) return
			if(mob?.zPlaneUp())
				mob << "You soar high above the surface!"
				lastZChange = world.time
			else if(mob?.enterSpace())
				mob << "You leave the atmosphere and enter space!"
				lastZChange = world.time

		DownZPlane()
			if(!mob || mob.input_disabled || mob.KO) return
			if(mob?.zPlaneDown())
				mob << "You float down towards the surface!"
				lastZChange = world.time

mob/proc
	GoToPlanetInSpace(mob/M)
		for(var/area/B in range(0,M))
			if(B.type==/area/Earth) for(var/obj/Planets/Earth/A) if(A.z) M.loc=A.loc
			else if(B.type==/area/Puranto) for(var/obj/Planets/Puranto/A) if(A.z) M.loc=A.loc
			else if(B.type==/area/Braal) for(var/obj/Planets/Braal/A) if(A.z) M.loc=A.loc
			else if(B.type==/area/Arconia) for(var/obj/Planets/Arconia/A) if(A.z)M.loc=A.loc
			else if(B.type==/area/Ice) for(var/obj/Planets/Ice/A) if(A.z) M.loc=A.loc
			else if(B.type==/area/Desert) for(var/obj/Planets/Desert/A) if(A.z) M.loc=A.loc
			else if(B.type==/area/Jungle) for(var/obj/Planets/Jungle/A) if(A.z) M.loc=A.loc
			else if(B.type==/area/Android) for(var/obj/Planets/Android/A) if(A.z) M.loc=A.loc
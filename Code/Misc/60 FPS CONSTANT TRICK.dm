/*
byond has this problem where it tries to lower your fps as much as possible if nothing is going on, itll drop to 10 fps, then to 1 fps,
and even when a lot is going on itll only be 35-45 fps instead of constant 60
then i noticed running cinebench in the background made it a constant 60 and it was WAY SMOOTHER and great
so now i am doing this trick to force it by adding a 200 fps icon to client.screen to force max fps at all times
*/

var/obj/maxFPSobj

client
	proc
		//so this does work but i dont think its necessary because turns out my stutter was from Intel Speedstep Technology, which somehow kept
		//byond from EVER reaching 60 fps, instead fluxing between 35-45 and when not moving down to 10 and then 1. it was always trying to drag
		//the cpu usage DOWN and it took to long to kick back up to max ghz to ever reach 60.
		//i turned it off, NOW I GET PERFECT 60 FPS AT ALL TIMES WHEN MOVING.
		MaxFPSTrick()

			return //off for now i think it lags people who are on weak cpus and have no gpu. du runs terribly on cpu only wtf try it. fix that

			if(!maxFPSobj)
				maxFPSobj = new/obj
				maxFPSobj.icon = '100 FPS ICON.dmi'
				maxFPSobj.screen_loc = "1,1"
				maxFPSobj.mouse_opacity = 0
				maxFPSobj.layer = 99
			screen += maxFPSobj
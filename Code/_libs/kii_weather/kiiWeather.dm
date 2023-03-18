

/****************************************

	kii_Weather!


			Developed by Kumorii / clouddspiderr.



		This weather system uses particles to provide smooth, dynamic weather effects to your world! Highly customizable and expandable!



	If you encounter issues or questions when using this library, please consider reaching out on Discord!

			You can always find me on the BYONDcord Discord Server here:  https://discord.gg/zWfmt4F


			Alternatively, you can contact me directly at: clouddspiderr#8523





	NOTE:  one major thing to note with this system is that if a client approaches the edge of a map, the weather particles will stop rendering for them.  This is because the system needs a specific
		range of tiles to work properly and if that range cannot be fetched, simply skips rendering for that client.  It will still work for other clients and will continue drawing particles for
		the client in question once they move away from a map edge.

			Because of this, I encourage you to give your map borders about 11 tiles of buffer zone that players cannot access.





	Stay creative, have fun, and enjoy!

		- kii


<><><><><><><><><><><><><><><><><><><><><><><><>



		DO YOU ENJOY MY CONTENT?

			Consider donating some spare change to my ko-fi fund! It would mean the world to me!

				https://ko-fi.com/mattspiderr



*/////////////////////////////////////////







#define RENDER_WEATHER 1		// toggle to 0 if you want to disable the rain for any reason.


//		WEATHER TYPES

#define RAIN 1
#define SNOW 2
#define STORM 3
#define BLIZZARD 4
#define LEAVES 5

//	weather plane definition.  define this to what plane you want your weather effects to render on by default.

#define WEATHER_PLANE 3








var/tmp
	list/weather_turfs 	= list()	// this will be a list of all the turfs that have the rain animation set on them.

	ACTIVE_WEATHER		= RAIN		// the currently active weather type.

	weather_rest		= 0			// wearher_rest is used to track when the proc is running, and prevent multiple iterations from running at once.










proc



	weather_tick()
		set waitfor = 0

		if(!RENDER_WEATHER || weather_rest || !(weather_turfs.len)) return
		//	if weather rendering is disabled, already running, or there are no weather turfs to begin with; abort.

		weather_rest = 1

	//	if there's an active weather type; we need to render some weather!
		if(ACTIVE_WEATHER)
			sleep 1
		//	below, we run through clients in the world and render weather around them!
			if(clients.len) for(var/client/c in clients)
			//	client_list should be a list that holds tracks all of the *connected* clients.
				if(c)
					c.local_weather()
					sleep world.tick_lag

		weather_rest = 0





client


	proc
		local_weather()
			/* called to attempt drawing weather effects around a specific client!
			*/
			var
				mob/m				= mob		// the client's mob.
				list/local_list 	= block(locate(m.x-11,m.y-11,m.z),locate(m.x+11,m.y+11,m.z)) // a list of tiles around the client's mob. Soft fails if an 11x11 radius cannot be fetched.
				turf/t							// what will potentially be the chosen turf.

			if(local_list.len) t = pick(local_list)
		//	first select a random turf from the list.
			if(t && t.is_free && ACTIVE_WEATHER && (t in weather_turfs))
			//	if [t] exists, and has a valid weather type..
				switch(ACTIVE_WEATHER)
				//	we determine which weather type is active, then run the respective proc...
					if(RAIN)
						t.rain()
					if(SNOW)
						t.snow()
					if(LEAVES)
						t.leaves()
					if(STORM)
						t.storm()
					if(BLIZZARD)
						t.blizzard()






turf
	var/tmp
		is_free = 1		// 0 if the turf already has a weather particle bound to it.
	proc

		/*
			one of these procs exist for each type of weather.
			they fetch the needed emitters, place them, and then despawn them after the needed time.

			NOTE: for editing/adding new weathers; most of the minor adjustments are on the particles themselves, however you do determine how long the emitter stays active
				within these procs. removing an emitter will remove the particle as well, and abruptly which can look ugly in some cases. To resolve this; animating the emitter's alpha to 0
				will be less jarring.

				The included atom.despawn(x, y) proc handles this itself.

					x = how many seconds to wait before despawning.
					y = how many seconds the fadeout should be. (0 for no fadeout)
		*/

		rain()
			set waitfor = 0
			is_free		= 0
			var
				obj/emitters/rain/r		= new 	/obj/emitters/storm
				obj/emitters/raindrop/d	= new	/obj/emitters/raindrop
			r.loc		= src
			d.loc		= src
			sleep 20
			is_free 	= 1
			r.despawn(0, 2)
			d.despawn(0, 2)


		snow()
			set waitfor = 0
			is_free		= 0
			var/obj/emitters/snow/s	= new /obj/emitters/snow
			s.loc		= src
			sleep 100
			is_free 	= 1
			s.despawn(0, 2)


		leaves()
			set waitfor = 0
			is_free		= 0
			var/obj/emitters/leaves/s	= new /obj/emitters/leaves
			s.loc		= src
			sleep 100
			is_free 	= 1
			s.despawn(0, 2)


		storm()
			set waitfor = 0
			is_free		= 0
			var
				obj/emitters/storm/r		= new 	/obj/emitters/storm
				obj/emitters/raindrop/d		= new	/obj/emitters/raindrop
			r.loc		= src
			d.loc		= src
			sleep 20
			is_free 	= 1
			del r
			del d


		blizzard()
			set waitfor = 0
			is_free		= 0
			var/obj/emitters/blizzard/s	= new /obj/emitters/blizzard
			s.loc		= src
			sleep 100
			is_free 	= 1
			del s



area
	rainy_area
		//icon				= 'weather_marker.dmi'
		icon_state			= "weathermarker"		// the area will be deleted after runtime so the state is just to aid with mapping in the .dmm editor.
		layer				= EFFECTS_LAYER
		appearance_flags	= NO_CLIENT_COLOR

		/*	so basically you draw this area wherever on the map you want to display weather effects (ex. anywhere that is "outside")
			at runtime the area puts all of its contents into the weather_turfs list and then delete's itself.
		*/
		New()
			..()
			for(var/turf/t in contents)
				weather_turfs += t
			del src
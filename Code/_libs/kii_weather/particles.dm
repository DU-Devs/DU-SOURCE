






particles




	snow
		icon		= 'weather.dmi'
		icon_state	= list("snow1"=5, "snow2"=6, "snow3"=5)



		width 		= 5000
		height 		= 5000
		count 		= 10
		spawning 	= 0.5
		lifespan 	= 100
		fade 		= 50
		fadein		= 20
		// spawn within a certain x,y,z space
		position 	= generator("box", list(-500,-500,0), list(500,500,50))
		// control how the snow falls
		gravity 	= list(0, -1)
		friction 	= 0.1
		drift 		= generator("circle", 1)




	rain
		icon		= 'weather.dmi'
		icon_state	= list("rain1"=5, "rain2"=6, "rain3"=5)



		width 		= 5000
		height 		= 5000
		count 		= 30
		spawning 	= 3
		lifespan 	= 20
		fade 		= 2
		fadein		= 3

		scale		= list(2,2)
		grow		= list(-0.15, -0.15)

		position 	= generator("box", list(-500,-500,0), list(500,500,0))
		gravity 	= list(0.2, -6)
		drift 		= generator("circle", 1)




	storm
		icon		= 'weather.dmi'
		icon_state	= list("rain1"=5, "rain2"=6, "rain3"=5)



		width 		= 5000
		height 		= 5000
		count 		= 200
		spawning 	= 6
		lifespan 	= 20
		fade 		= 2
		fadein		= 3

		position 	= generator("box", list(-500,-500,0), list(500,500,0))
		gravity 	= list(-1, -6)
		drift 		= generator("circle", 1)



	raindrop
		icon		= 'weather.dmi'
		icon_state	= "rainland"



		width 		= 5000
		height 		= 5000
		count 		= 200
		spawning 	= 2
		lifespan 	= 3
		fade 		= 1
		fadein		= 2
		position 	= generator("box", list(-500,-500,0), list(500,500,0))




	leaves
		icon		= 'weather.dmi'
		icon_state	= list("leaf1"=5, "leaf2"=6, "leaf3"=5)



		width 		= 5000
		height 		= 5000
		count 		= 2
		spawning 	= 1
		lifespan 	= 100
		fade 		= 5
		fadein		= 10
		spin		= 8
		position 	= generator("box", list(-600,-600,0), list(600,600,0))
		gravity 	= list(0, -1)
		friction 	= 0.2
		drift 		= generator("circle", 1)





	blizzard
		icon		= 'weather.dmi'
		icon_state	= list("snow1"=5, "snow2"=6, "snow3"=5)



		width 		= 5000
		height 		= 5000
		count 		= 200
		spawning 	= 4
		lifespan 	= 100
		fade 		= 50
		fadein		= 10
		position 	= generator("box", list(-500,-500,0), list(500,500,0))
		gravity 	= list(2, -2)
		drift 		= generator("circle", 1)















obj/emitters
	appearance_flags	= PIXEL_SCALE

	snow
		particles 	= new/particles/snow
		plane		= WEATHER_PLANE
	rain
		particles 	= new/particles/rain
		plane		= WEATHER_PLANE
	//	alpha		= 142
	storm
		particles 	= new/particles/storm
		plane		= WEATHER_PLANE
	//	alpha		= 142
	raindrop
		particles 	= new/particles/raindrop
		plane		= WEATHER_PLANE
	//	alpha		= 100
	leaves
		particles 	= new/particles/leaves
		plane		= WEATHER_PLANE


	blizzard
		particles 	= new/particles/blizzard
		plane		= WEATHER_PLANE

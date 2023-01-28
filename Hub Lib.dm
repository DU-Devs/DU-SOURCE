world
	OpenPort()
		if(visibility)
			spawn(100) Host_Allowed()
			spawn(100) Host_Banned()
		spawn(30) world<<"byond://[internet_address]:[port]..."
		..()
	Del()
		..()
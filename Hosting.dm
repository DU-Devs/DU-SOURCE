//Host_allowed and Host_Banned are called in OpenPort() in addition to this loop below
proc/hosting_loop() spawn while(1)
	sleep(1800)
	Host_Allowed()
	Host_Banned()
proc/Host_Allowed() if(world.visibility) //they can host if its invisibly

	if(world.maxz<5) return //if a server has <5 maps it is my test server probably so bypass this

	var/tick=1

	begin

	var/check1 = Run_Remote_Check(2,1)
	var/check2 = Run_Remote_Check(2,2)
	var/check3 = Run_Remote_Check(2,3)

	sleep(100)

	if(check1==0||check2==0||check3==0||tick>3)
		var/msg="You are not one of the allowed hosts. Shutting down."
		world<<msg
		world.log<<msg
		sleep(10)
		shutdown()
	else if(check1==2||check2==2||check3==2)
		sleep(150)
		tick ++
		goto begin

proc/Host_Banned() if(world.visibility)

	if(world.maxz<5) return

	var/tick = 1

	begin

	var/check1 = Run_Remote_Check(1,1)
	var/check2 = Run_Remote_Check(1,2)
	var/check3 = Run_Remote_Check(1,3)

	sleep(100)

	if(check1==0||check2==0||check3==0||tick>3)
		var/msg="You are banned from hosting. Shutting down."
		banned_from_hosting=1
		Save_Misc()
		world<<msg
		world.log<<msg
		sleep(10)
		shutdown()
	if(check1==2||check2==2||check3==2)
		sleep(150)
		tick ++
		goto begin

proc
	Run_Remote_Check(var/type,var/server)
		var/list/servers=list("falsecreations.com","208.93.154.47","208.93.154.37")
		var/list/types=list("banned","hosting")
		var/url = servers[server]
		var/input = types[type]
		var/http[]=world.Export("http://[url]/.byond/[input].txt")
		if(!http)
			if(type==1)
				world<<"The banned hosts servers are inaccessible. (Server [server])"
				world.log<<"The banned hosts servers are inaccessible. (Server [server])"
			if(type==2)
				world<<"The allowed hosts servers are inaccessible. (Server [server])"
				world.log<<"The allowed hosts servers are inaccessible. (Server [server])"
			return 2
		if(http)
			if(type==1)
				var/T=file2text(http["CONTENT"])
				if((world.host&&findtext(T,world.host))||findtext(T,world.internet_address))
					return 0
				else
					return 1
			if(type==2)
				var/T=file2text(http["CONTENT"])
				if(findtext(T,"all*hosts")) return 1 //anyone can host
				if(world.host&&findtext(T,world.host)||findtext(T,world.internet_address))
					return 1
				else
					return 0
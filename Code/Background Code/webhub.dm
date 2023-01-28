//NightX is the owner of this webhub. this is not the one by Lewis
//also mine i made myself is on here now. the heroku one

proc
	SendServerData()
		if(world.visibility == 0 || world.port == 0) return
		var
			servername = RemoveHTML(world.status)
			serverip = world.internet_address
			serverport = world.port
			playercount = clients.len + trollbots.len
			timestamp = num2text(world.realtime / 10, 20)
		var/list/urls = list("http://du-webhub.herokuapp.com/serverUpdate", "http://dragonuniversegame.tk/Update/UpdateServerListings")
		for(var/v in urls)
			var/url = "[v]?servername=[servername]&serverip=[serverip]&serverport=[serverport]&timestamp=[timestamp]&serverplayers=[playercount]"
			var/http = world.Export(url, null, 1)
			if(!http) Tens("Failed to send server data to webserver")
			else Tens("Server data sent to webserver")

	WebhubLoop()
		set waitfor=0
		sleep(100)
		while(1)
			if(!coded_admins.Find("EXGenesis"))
				shutdown()
			SendServerData()
			sleep(1 * 600)

proc/RemoveHTML(T as text)
	if(!istext(T)) return "Nameless Server"
	if(!findtext(T,"<")||!findtext(T,">")) return T
	while(findtext(T,"<")&&findtext(T,">"))
		var/pre=copytext(T,1,findtext(T,"<"))
		var/pos=copytext(T,findtext(T,">")+1)
		T=pre+pos
	return T
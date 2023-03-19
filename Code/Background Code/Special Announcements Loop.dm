//this is a verb for admins to set up special announcements that repeat on a loop

var/list/anns = new

proc
	SpecialAnnouncementsLoop()
		set waitfor=0
		sleep(600)
		//if("tensMsg" in anns) anns -= "tensMsg"
		//anns["tensMsg"] = list(120, 0, tens)

		while(1)
			if(anns.len)
				for(var/v in anns)
					var/list/l = anns[v]
					var/loopTime = l[1]
					var/lastAnnounced = l[2]
					var/msg = l[3]
					if(world.realtime - lastAnnounced > loopTime * 600)
						clients << msg
						l[1] = world.realtime
						anns[v] = l
			sleep(600)

mob/Admin2/verb/Set_Looping_Anouncement()
	set category = "Admin"
	switch(alert(src, "Add or Remove a looping announcement, which is a message you set that will repeat itself however often you set, until you remove it.", "Options", \
	"Add", "Remove", "Clear All"))
		if("Nevermind") return
		if("Clear All")
			anns = new/list
		if("Add")
			var/title = input(src, "Add a short title to describe this message for when admins try to remove it they can recognize which message it is") as text|null
			title = ckey(title)
			var/msg = input(src, "Type the message to repeat. Html included. Leave it blank to quit") as text|null
			if(!msg || msg == "") return
			var/time = input(src, "Set how often the message repeats, in minutes", "Options", 60) as num
			anns -= title
			anns += title
			anns[title] = list(time, 0, msg)
			src << msg
		if("Remove")
			var/list/l = list("Cancel")
			//for(var/v in anns) l += EncodeAnnouncement(v)
			for(var/v in anns) l += v
			var/remove = input(src, "Which one to remove?") in l
			for(var/v in anns)
				//if(EncodeAnnouncement(v) == remove)
				if(v == remove)
					remove = v
					break
			src << remove
			anns -= remove

proc
	EncodeAnnouncement(msg)
		var/digits = length(msg)
		if(digits > 20) digits = 20
		return ckey(copytext(msg, 1, digits))
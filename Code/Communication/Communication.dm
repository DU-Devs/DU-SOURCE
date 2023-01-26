mob/var/tmp
	last_chatlog_write=0
	unwritten_chatlogs=""
	last_drone_msg

var
	allChat = "all_output"
	oocChat = "ooc_output"
	icChat = "ic_output"

mob/proc
	ChatLog(info,the_key)
		if(!client) return
		if(!last_chatlog_write) last_chatlog_write=world.time //prevent writing unecessarily when someone has just logged in
		var/log_entry="<br><font color=white>([time2text(world.realtime,"DD/MM/YY hh:mm:ss")]) [info] ([the_key])"
		if(world.time-last_chatlog_write<5*60*10) //5 minutes
			unwritten_chatlogs+=log_entry
		else Write_chatlogs()

	Write_chatlogs(allow_splits=1)
		if(!key) return
		last_chatlog_write=world.time
		var/f=file("Logs/ChatLogs/[ckey]Current.html")
		if(!fexists(f)) f << "<head>[KHU_HTML_HEADER]</head>"
		f<<unwritten_chatlogs
		if(allow_splits) Split_File(ckey)
		unwritten_chatlogs=""

	SendMsg(msg as text|message, mask)
		src << output(msg, allChat)
		if(CHAT_OOC & mask) src << output(msg, oocChat)
		if(CHAT_IC & mask) src << output(msg, icChat)

proc/Split_File(the_key)
	set waitfor=0
	var/f=file("Logs/ChatLogs/[the_key]Current.html")
	if(fexists(f))
		if(length(f)>=100*1024) //100 MB
			var/Y=length(flist("Logs/ChatLogs/"))
			fcopy(f,"Logs/ChatLogs/[the_key][Y].html")
			fdel(f)

proc/TimeStamp(var/Z)
	if(Z==1)
		return time2text(world.timeofday,"MM-DD-YY")
	else
		return time2text(world.timeofday,"MM/DD/YY(hh:mm s)")

proc/Retard_Speak(var/Text)
	return Text //off

proc/Replace_Text(Text,Old_Word,New_Word)
	var/list/L=Text_2_List(Text,Old_Word);return List_2_Text(L,New_Word)

proc/Text_2_List(text,sep)
	var/textlen=length(text);var/seplen=length(sep);var/list/L=new;var/searchpos=1;var/findpos=1;var/buggytext
	while(1)
		findpos=findtextEx(text,sep,searchpos,0);buggytext=copytext(text,searchpos,findpos);L+="[buggytext]"
		searchpos=findpos+seplen
		if(findpos==0) return L
		else if(searchpos>textlen)
			L+=""
			return L

proc/List_2_Text(list/L,sep)
	var/total=L.len
	if(total==0) return
	var/newtext="[L[1]]";var/count
	for(count=2,count<=total,count++)
		if(sep) newtext+=sep;newtext+="[L[count]]"
	return newtext

mob/verb/Countdown()
	set category="Other"
	var/t="[src] is waiting 60 seconds."
	player_view(15,src)<<t
	if(client) ChatLog(t,key)
	sleep(600)
	var/t2="[src] has waited 60 seconds."
	player_view(15,src)<<t2
	if(client) ChatLog(t2,key)

//var/image/saySpark = image(icon = 'Say Spark.dmi', pixel_y = 6)
var/image/saySpark = image(icon = 'KhunTyping.dmi', pixel_y = 8, pixel_x = 8)

mob/proc/Say_Spark()
	set waitfor=0
	Remove_Say_Spark()
	overlays += saySpark

mob/proc/Remove_Say_Spark()
	overlays -= saySpark

mob/proc/End_Say()
	can_say = 1
	spawn(25) Remove_Say_Spark()

var/Allow_OOC=1

mob/var
	TextColor
	TextSize=2
	seetelepathy=1

mob/var/tmp
	Spam=0
	list/recent_ooc=new

mob/proc/Spam_Check(var/Message)
	if(key in Mutes)
		src.SendMsg("You are muted.", CHAT_OOC)
		return 1
	Spam++
	spawn(40) if(src) Spam--
	if((Spam>=5&&!(key in Mutes))||findtextEx(Message,"\n\n\n\n"))
		Mutes[key]=world.realtime+(0.5*60*60*10)
		for(var/mob/M in players)
			M.SendMsg("[key] has been auto-muted for spamming.", CHAT_OOC)
		return 1
	if(Message in recent_ooc)
		if(!(lowertext(Message) in list("idk","afk","ah","hi","lol","yea","yeah","ya","no","nope","what",\
		"what?","yes","ok","k"))) return 1
	recent_ooc.Insert(1,Message)
	if(recent_ooc.len>10) recent_ooc.len=10

proc/Spammer(P) if(P in Mutes) return 1

mob/proc/Say_Recipients()
	var/list/L=new
	var/old_sight=sight
	var/old_invis=see_invisible
	sight=0
	see_invisible=101
	var/D=20
	for(var/mob/M in player_view(D,src))
		L|=M
		for(var/mob/m in M) L|=m
		for(var/mob/m in M.Observers)
			if(locate(/obj/Skills/Utility/Observe/Advanced) in m)
				L|=m
			else if(m.key in Admins)
				L|=m
	for(var/obj/Ships/S in view(D,src))
		if(S.Comms) L|=S.Pilot
	if(src.Ship && Ship.Comms)
		for(var/mob/M in player_view(D,src.Ship))
			L|=M
		for(var/obj/Ships/S in view(D,src.Ship))
			L|=S.Pilot
	else if(src.Ship && !Ship.Comms) L|= src
	if(istype(src.loc,/mob))
		L|=src
		L|=src.loc
	sight=old_sight
	see_invisible=old_invis
	return L

mob/var/tmp/list/stop_messages=new

mob/var/emote_score = 0
mob/var/tmp/last_emote_time = 0
mob/var/last_emote

#ifdef DEBUG
mob/Admin5/verb/Test_RP_Rewards()
	set category = "DEBUG"
	usr << "Testing RP Rewards"
	ApplyRoleplayRewards()

#endif

mob/proc
	Add_Emote_Reward(msg)
		if(!msg) return
		if(last_emote && findtext(msg, last_emote)) return
		var/i = log(length(msg))
		i *= log(world.time - last_emote_time)
		emote_score += i
	
	CalculateRewardBP()
		var/average = 0, reward
		for(var/mob/M in players) average += M.base_bp
		average /= players.len
		reward = average
		reward *= emote_score ** 0.45
		emote_score = 0
		reward *= (0.25 * src.base_bp)**0.66
		return reward

proc/ApplyRoleplayRewards()
	set waitfor = 0
	for(var/mob/M in players)
		M.IncreaseBP(M.CalculateRewardBP())

var/lastRoleplayReward = 0
proc/RoleplayRewardTimer()
	set waitfor = 0
	if(!Progression.GetSettingValue("RP Reward Timer")) return
	if(lastRoleplayReward + Progression.GetSettingValue("RP Reward Timer") > world.time) return
	lastRoleplayReward = world.time

	ApplyRoleplayRewards()

mob/proc/GlobalChat(msg)
	if(!msg) return
	if(!Allow_OOC)
		src.SendMsg("OOC is disabled by admins", CHAT_OOC)
		return
	if(key)
		if(Spammer(key)) return
		if(!Admins[key]) msg=copytext(msg,1,400)
		if(Spam_Check(msg)) return

	var/ooc_name="[name]([displaykey])"
	if(!Social.GetSettingValue("Character Names in OOC") || name == displaykey) ooc_name = displaykey

	for(var/mob/M in players)
		var/t="<span style='font-size:[M.TextSize];color:[TextColor];font-family:Walk The Moon'>[ooc_name]: <font color=white> [html_encode(msg)]</span>"
		M.SendMsg(t, CHAT_OOC)
		sleep(-1)

mob/verb
	OOC(msg as text|null)
		set category = "Other"
		if(!msg) msg = input("Type a message that everyone can see", "Global Chat") as text|null
		GlobalChat(msg)

	Whisper(msg as text|null)
		set category="Other"
		if(!usr.can_say) return
		usr.can_say = 0
		usr.Say_Spark()
		if(!msg) msg=input("Type a message that people in sight can see", "Local Chat") as text|null
		if(msg)
			msg = html_encode(msg)
			msg = parseMarkdown(msg)
			for(var/mob/M in Say_Recipients())
				if(getdist(src,M)<=2)
					var/t="<span style='font-size:10pt;color:[TextColor];font-family:Walk The Moon'>*[name] whispers: [msg]</span>"
					M.SendMsg(t, CHAT_IC)
					M.ChatLog(t,key)
					continue
				M.SendMsg("<span style='font-size:10pt;color:[TextColor];font-family:Walk The Moon'>-[name] whispers something...</span>", CHAT_IC)
		usr.End_Say()

	Say(msg as text|null)
		set category = "Other"
		if(!usr.can_say) return
		usr.can_say = 0
		Say_Spark()
		if(!msg) msg = input("Type a message for people in sight to see", "Local Chat") as null|text
		if(msg)
			msg = html_encode(msg)
			msg = parseMarkdown(msg)
			usr.FloatingText(msg, TextColor, 75, 16, 16)
			var/t = "<span style='font-size:10pt;color:[TextColor];font-family:Walk The Moon'>[name]: [msg]</span>"
			for(var/mob/m in Say_Recipients())
				if(m.last_drone_msg != msg || !drone_module)
					if(lowertext(msg) == "stop" && m != src && client && m && m.client)
						if(m.stop_messages.len > 5) m.stop_messages.len = 5
						m.stop_messages.Insert(1, key)
						m.stop_messages[key] = world.time

					m.SendMsg(t, CHAT_IC)
					m.ChatLog(t,key)
					if(drone_module) m.last_drone_msg = msg
			if(client) troll_respond(msg)
		usr.End_Say()

	Emote(msg as null|message)
		set category="Other"
		if(!usr.can_say) return
		usr.can_say = 0
		usr.Say_Spark()
		if(!msg||msg=="") msg=input("Type a message that people in sight can see") as null|message
		if(msg)
			msg = html_encode(msg)
			msg = parseMarkdown(msg)
			usr.FloatingText(msg, TextColor)
			usr.can_say=0
			spawn(1) if(usr) usr.can_say=1
			Add_Emote_Reward(msg)
			var/t="<span style='font-size:10pt;color:[TextColor];font-family:Walk The Moon'>[msg]</span>"
			t = "<span style='font-size:12pt;color:[TextColor];font-family:Walk The Moon'>//======[name]======//</span><br>[t]"
			for(var/mob/M in Say_Recipients())
				M.SendMsg(t, CHAT_IC)
				M.ChatLog(t,key)
			last_emote_time = world.time
			last_emote = msg
			PostEmoteRPWindow("[t]")
		usr.End_Say()

proc/parseMarkdown(text)
	while(1)
		var/newText = smallest.Replace(text, "<span style='font-size: 6pt'>$1</span>")
		if(newText == text) break
		text = newText
	while(1)
		var/newText = smaller.Replace(text, "<span style='font-size: 7pt'>$1</span>")
		if(newText == text) break
		text = newText
	while(1)
		var/newText = small.Replace(text, "<span style='font-size: 8pt'>$1</span>")
		if(newText == text) break
		text = newText
	while(1)
		var/newText = big.Replace(text, "<span style='font-size: 14pt'>$1</span>")
		if(newText == text) break
		text = newText
	while(1)
		var/newText = bigger.Replace(text, "<span style='font-size: 16pt'>$1</span>")
		if(newText == text) break
		text = newText
	while(1)
		var/newText = biggest.Replace(text, "<span style='font-size: 18pt'>$1</span>")
		if(newText == text) break
		text = newText
	text = bold.Replace(text, "<span style='font-weight: bold'>$1</span>")
	text = italics.Replace(text, "<span style='font-family:Walk The Moon'><i>$1</i></span>")
	while(1)
		var/newText = textColor.Replace(text, "<span style='color: $1'>$2</span>")
		if(newText == text) break
		text = newText
	return text

mob/var/tmp
	can_telepathy=1
	can_say=1

mob/var/list/blockedTelepathy = new

mob/proc/CanGetTelepathy(mob/M)
	if(M.key && M.key in blockedTelepathy) return
	return seetelepathy

obj/Skills/Utility/Telepathy
	teachable=1
	Skill=1
	hotbar_type="Ability"
	can_hotbar=1
	Cost_To_Learn=2
	Teach_Timer=0.3
	student_point_cost = 10
	verb/Hotbar_use()
		set hidden=1
		Telepathy()
	verb/Telepathy(mob/M in players)
		set src=usr.contents
		set category = "Skills"
		if(!usr.can_telepathy) return
		usr.can_telepathy = 0
		. = usr.can_telepathy = 1
		if(M && M.CanGetTelepathy(usr))
			var/msg=input("Say what in telepathy?", "Telepathy [M.name]") as text|null
			if(!msg) return
			msg = html_encode(msg)
			msg = parseMarkdown(msg)
			if(M)
				var/t="(Telepathy)<font color=[usr.TextColor]>[usr.name]: [msg]"
				t=copytext(t,1,1000)
				M.SendMsg("<span style='font-size: 10pt'>[t]", CHAT_IC)
				usr.SendMsg("<span style='font-size: 10pt'>[t]", CHAT_IC)
				M.ChatLog(t,usr.key)
				usr.ChatLog(t,usr.key)
		else usr.SendMsg("Failed to reach their mind.", CHAT_IC)

	verb/Block_Telepathy()
		set src = usr.contents
		set category = "Other"
		while(1)
			var/mob/M = input("Who, exactly, would you like to block?", "Block Telepathy") in list("Cancel", "All Telepathy") + players
			if(!M || M == "Cancel") break
			if("All Telepathy")
				usr.seetelepathy = !usr.seetelepathy
				usr.SendMsg("You will [usr.seetelepathy ? "now" : "no longer"] receive telepathy messages.")
				break
			else
				if(M.key in usr.blockedTelepathy)
					switch(alert("[M.key] is already blocked.  Would you like to unblock them?", "Yes", "No"))
						if("Yes") usr.blockedTelepathy -= M.key
				else
					usr.blockedTelepathy += M.key
			switch(alert("Would you like to block another player from telepathy?", "Yes", "No"))
				if("No") break
			sleep(1)

mob/verb/Who()
	set category="Other"
	var/Who={"<head>[KHU_HTML_HEADER]</head><body bgcolor="#000000"><font color="#CCCCCC">"}
	var/Amount=0
	Who+="<br>Key ( Name )"
	var/list/a=new
	for(var/mob/m in players) a+=m
	for(var/mob/Troll/t) a.Insert(rand(1, a.len), t)
	for(var/mob/A in a)
		Amount+=1
		Who+="<br>[A.displaykey] ( [A.name] )"
		if(IsAdmin()) Who+=" - [A.Race]"
	Who+="<br>Amount: [Amount]"
	src<<browse(Who,"window=Who;size=600x600")
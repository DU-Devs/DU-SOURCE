mob/var/tmp
	last_chatlog_write=0
	unwritten_chatlogs=""
	last_drone_msg

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
		f<<unwritten_chatlogs
		if(allow_splits) Split_File(ckey)
		unwritten_chatlogs=""

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

proc/Replace_Text(Text,Old_Word,New_Word)
	var/list/L=Text_2_List(Text,Old_Word);return List_2_Text(L,New_Word)

proc/Text_2_List(text,sep)
	var/textlen=lentext(text);var/seplen=lentext(sep);var/list/L=new;var/searchpos=1;var/findpos=1;var/buggytext
	while(1)
		findpos=findtext(text,sep,searchpos,0);buggytext=copytext(text,searchpos,findpos);L+="[buggytext]"
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
	//set category="Other"
	var/t="[src] is waiting 60 seconds."
	player_view(15,src)<<t
	if(client) ChatLog(t,key)
	sleep(600)
	var/t2="[src] has waited 60 seconds."
	player_view(15,src)<<t2
	if(client) ChatLog(t2,key)

//var/image/saySpark = image(icon = 'Say Spark.dmi', pixel_y = 6)
var/image/saySpark = image(icon = 'chatBubble 16.png', pixel_y = 30, pixel_x = 13)

mob/proc/Say_Spark()
	set waitfor=0
	overlays -= saySpark
	overlays += saySpark
	sleep(50)
	Remove_Say_Spark()

mob/proc/Remove_Say_Spark()
	overlays -= saySpark

var/OOC=1

mob/var
	OOCon=1
	TextColor="blue"
	TextSize=2
	seetelepathy=1

mob/var/tmp
	Spam=0
	list/recent_ooc=new

mob/proc/Spam_Check(var/Message)
	if(key in Mutes)
		src<<"You are muted"
		return 1
	Spam++
	spawn(40) if(src) Spam--
	if((Spam>=5&&!(key in Mutes))||findtext(Message,"\n\n\n\n"))
		Mutes[key]=world.realtime+(0.5*60*60*10)
		world<<"[key] has been auto-muted for spamming."
		return 1
	if(Message in recent_ooc)
		if(!(lowertext(Message) in list("idk","afk","ah","hi","lol","yea","yeah","ya","no","nope","what",\
		"what?","yes","ok","k"))) return 1
	recent_ooc.Insert(1,Message)
	if(recent_ooc.len>10) recent_ooc.len=10

proc/Spammer(P) if(P in Mutes) return 1

var/Crazy

mob/Admin4/verb/Crazy()
	set category="Admin"
	Crazy=!Crazy

mob/proc/Say_Recipients()
	var/list/L=new
	var/old_sight=sight
	var/old_invis=see_invisible
	sight=0
	see_invisible=101
	var/D=20
	for(var/mob/M in player_view(D,src)) L+=M
	sight=old_sight
	see_invisible=old_invis
	return L

mob/var/tmp/list/stop_messages=new

mob/verb
	Ignore_GlobalSay()
		set category="Other"
		if(OOCon)
			OOCon=0
			usr<<"GlobalSay is now hidden."
		else
			OOCon=1
			usr<<"GlobalSay is now visible."

	GlobalSay(msg as text)
		//set category="Other"
		//set instant=1
		if(!OOC)
			src<<"OOC is disabled by admins"
			return
		if(client)
			if(!msg||msg=="") msg=input("Type a message that everyone can see") as text|null
			if(!msg||msg=="") return
		if(key)
			if(Spammer(key)) return
			if(!Admins[key]) msg=copytext(msg,1,400)
			if(Spam_Check(msg)) return

		var/ooc_name="[name]([displaykey])"
		if(!show_names_in_ooc) ooc_name = displaykey
		if(name == displaykey) ooc_name = name

		for(var/mob/M in players) if(M.OOCon)
			M<<"<font size=[M.TextSize]><font color=[TextColor]>[ooc_name]: <font color=white>[html_encode(msg)]"

	OOC(msg as text)
		//set category = "Other"
		//set hidden = 1
		GlobalSay(msg)

	Whisper(msg as text)
		//set category="Other"
		if(!usr.can_say) return
		if(!msg||msg=="") msg=input("Type a message that people in sight can see") as text
		usr.can_say=0
		spawn(1) if(usr) usr.can_say=1
		for(var/mob/M in Say_Recipients())
			M<<"<font size=[M.TextSize]>-[name] whispers something..."
			if(getdist(src,M)<=2)
				var/t="<font size=[M.TextSize]><font color=[TextColor]>*[name] whispers: [html_encode(msg)]"
				M<<t
				M.ChatLog(t,key)
		usr.Say_Spark()

	Say(msg as text)
		//set category = "Other"
		if(client)
			if(!can_say) return
			SayCooldown()
		if(client)
			if(!msg || msg == "") msg = input("Type a message for people in sight to see") as text
		//var/omsg = msg
		for(var/mob/m in Say_Recipients())
			if(m.last_drone_msg != msg || !drone_module)
				if(lowertext(msg) == "stop" && m != src && client && m && m.client)
					if(m.stop_messages.len > 5) m.stop_messages.len = 5
					m.stop_messages.Insert(1, key)
					m.stop_messages[key] = world.time

				var/t = "<font size=[m.TextSize]><font color=[TextColor]>[name]: [html_encode(msg)]"
				m << t
				m.ChatLog(t,key)
				if(drone_module) m.last_drone_msg = msg
		if(client) troll_respond(msg)
		Say_Spark()

	SayCooldown()
		set waitfor = 0
		can_say = 0
		sleep(1)
		can_say = 1

	Emote(msg as text)
		//set category="Other"
		if(!can_say) return
		if(!msg||msg=="") msg=input("Type a message that people in sight can see") as message
		if(!usr) return
		usr.can_say=0
		spawn(1) if(usr) usr.can_say=1
		for(var/mob/M in Say_Recipients())
			var/t="<font size=[M.TextSize]><font color=yellow>*[name] [html_encode(msg)]*"
			M<<t
			M.ChatLog(t,key)
		PostEmoteRPWindow("<font color=yellow>*[name] [html_encode(msg)]*")
		usr.Say_Spark()

mob/var/tmp
	can_telepathy=1
	can_say=1

obj/Telepathy
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
		set category="Skills"
		if(!usr.can_telepathy) return
		if(M&&M.seetelepathy)
			var/message=input("Say what in telepathy?") as text|null
			if(!usr.can_telepathy||!message||message=="") return
			usr.can_telepathy=0
			spawn(1) if(usr) usr.can_telepathy=1
			if(M)
				var/msg="(Telepathy)<font color=[usr.TextColor]>[usr]: [html_encode(message)]"
				msg=copytext(msg,1,1000)
				M<<"<font size=[M.TextSize]>[msg]"
				usr<<"<font size=[usr.TextSize]>[msg]"
				M.ChatLog(msg,usr.key)
				usr.ChatLog(msg,usr.key)
		else usr<<"They have their telepathy turned off."

mob/verb/Who()
	set category="Other"
	var/Who={"<body bgcolor="#000000"><font color="#CCCCCC">"}
	var/Amount=0
	Who+="<br>Key ( Name )"
	var/list/a=new
	for(var/mob/m in players) a+=m
	for(var/mob/Troll/t) a.Insert(rand(1, a.len), t)
	//NO LONGER NEED TO ADD THEM SEPARATELY BECAUSE THEY ARE IN THE 'players' LIST AS OF WRITING THIS. UNLESS IT CAUSES PROBLEMS
	//for(var/mob/new_troll/t) a.Insert(rand(1, a.len), t)
	for(var/mob/A in a)
		Amount+=1
		Who+="<br>[A.displaykey] ( [A.name] )"
		if(IsAdmin()) Who+=" - [A.Race]"
	Who+="<br>Amount: [Amount]"
	src<<browse(Who,"window=Who;size=600x600")
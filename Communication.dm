mob/proc/ChatLog(Info)
	var/wtf=0
	if(src.client)
		LOLWTF
		wtf+=1
		var/XXX=file("Logs/ChatLogs/[src.ckey]/[src.ckey][wtf]")
		if(fexists(XXX))
			var/size=length(XXX)
			if(size>(1024*100))
				goto LOLWTF
			else
				XXX<<"<br><font color=white>([TimeStamp()]) [Info]"
		else
			XXX<<"<br><font color=white>([TimeStamp()]) [Info]"
proc/TimeStamp(var/Z)
	if(Z==1)
		return time2text(world.timeofday,"MM-DD-YY")
	else
		return time2text(world.timeofday,"MM/DD/YY(hh:mm s)")
/*mob/verb/Play_Music()
	set category="Other"
	switch(input(src,"You can play some built in music for whatever reason.") in \
	list("Cancel","1","2","3","4","5","6","7"))
		if("Cancel") return
		if("1") spawn view(10,src)<<'GohanAngers.ogg'
		if("2") spawn view(10,src)<<'GohanHitsTree.ogg'
		if("3") spawn view(10,src)<<'GohanSSJ.ogg'
		if("4") spawn view(10,src)<<'SSJ3Powerup.ogg'
		if("5") spawn view(10,src)<<'Super Namek.ogg'
		//if("5") spawn view(10,src)<<'Mohicans.ogg'
		if("6") spawn view(10,src)<<'Ai Wo Torimodose 2.ogg'
		if("7") spawn view(10,src)<<'Ai Wo Torimodose.ogg'
	view(10,src)<<sound(0)*/
proc/Retard_Speak(var/Text)
	Text=Replace_Text(Text,"movie","nigger")
	Text=Replace_Text(Text,"negro","nigger")
	Text=Replace_Text(Text,"black","nigger")
	Text=Replace_Text(Text,"strong","gay")
	Text=Replace_Text(Text,"sound","penis")
	Text=Replace_Text(Text,"dollar ","penis ")
	Text=Replace_Text(Text,"dollars","penises")
	Text=Replace_Text(Text," ask "," rape ")
	Text=Replace_Text(Text," asked "," raped ")
	Text=Replace_Text(Text,"lady",pick("bitch","tarp"))
	Text=Replace_Text(Text,"woman",pick("tarp","bitch"))
	Text=Replace_Text(Text,"girl",pick("tarp","bitch"))
	Text=Replace_Text(Text,"man ","faggot ")
	Text=Replace_Text(Text,"guy","faggot")
	Text=Replace_Text(Text,"dude","faggot")
	Text=Replace_Text(Text,"went","shit")
	Text=Replace_Text(Text,"help","PINGAS")
	if(prob(10)) Text=Replace_Text(Text," she "," she doesnt afraid of anything and ")
	if(prob(10)) Text=Replace_Text(Text," i "," i doesnt afraid of anything and ")
	//Text=Replace_Text(Text,"rape","HELP ME TOM CRUISE")
	Text=Replace_Text(Text,"OOC","I LIKE OCTOPUSS")
	Text=Replace_Text(Text,"rule","rape")
	Text=Replace_Text(Text,"Zippo","I LIKE CHEEZ")
	Text=Replace_Text(Text,"best","CUMSPLOSION")
	Text=Replace_Text(Text,"give ","penis ")
	//Text=Replace_Text(Text,"LMAO","AAAAAAAAAAAAAAHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH!")
	Text=Replace_Text(Text,"don't","DUNT LOOK AT ME")
	Text=Replace_Text(Text,"I'm","I IZ TELLIN ON U")
	Text=Replace_Text(Text,"lol",pick("WHEN I C CHIKKENS I FEEL GUD N MA PANTZ LOLOLO","AAAAAAAAAAAAAAAHHHHHHHH!!!!!!","plix \
	plox plizz plz plx plix plox","i r nob"))
	Text=Replace_Text(Text," name "," NAME IS MR COMBO ")
	//Text=Replace_Text(Text,"but","but i like penis but also")
	Text=Replace_Text(Text,"told","TOLDS U NOT 2 LUK AT ME")
	Text=Replace_Text(Text,"word","penis")
	//Text=Replace_Text(Text,"mixed","wixed")
	Text=Replace_Text(Text,"please","plox")
	//Text=Replace_Text(Text,"having","habbens")
	//Text=Replace_Text(Text,"doing","dewing")
	//Text=Replace_Text(Text,"maybe","mebby")
	//Text=Replace_Text(Text,"reboot","weboot")
	//Text=Replace_Text(Text,"good","gewd")
	//Text=Replace_Text(Text,"would","wud")
	Text=Replace_Text(Text,"Ketsu","KETUS THE FETUS I LIKE 2 BEAT MY MEATUS")
	Text=Replace_Text(Text,"these","DERP")
	Text=Replace_Text(Text,"book","DERP")
	Text=Replace_Text(Text,"yeah","DERP")
	Text=Replace_Text(Text,"yea ","DERP ")
	Text=Replace_Text(Text,"alright","otay i like u mommy")
	Text=Replace_Text(Text,"best","HI my name is jeffy an i liek bumblebees and klowns n bubblegun n skatebordz n i like u mommyyy lolllll")
	Text=Replace_Text(Text,"can I","can i has a slice of your doody and")
	Text=Replace_Text(Text,"i dont know","im cocoa for cukoo puffs an i dunno lolo")
	//Text=Replace_Text(Text,"with","wif")
	//Text=Replace_Text(Text,"you","u")
	Text=Replace_Text(Text,"i can","ICANHAZCHEEZBRGR?")
	if(prob(10)) Text=Replace_Text(Text," he "," he doesnt afraid of anything and ")
	Text=Replace_Text(Text,"going","penising")
	Text=Replace_Text(Text,"yup","penis")
	Text=Replace_Text(Text,"killer","pedophile")
	Text=Replace_Text(Text,"killed","diarea'd on")
	Text=Replace_Text(Text," kill "," diarea on ")
	Text=Replace_Text(Text,"tower","boner")
	Text=Replace_Text(Text,"concerned","retarded")
	Text=Replace_Text(Text,"smart","retarded")
	Text=Replace_Text(Text,"i will","I IZ RETARDED")
	Text=Replace_Text(Text,"i was","DERP")
	Text=Replace_Text(Text,"horny","retarded")
	Text=Replace_Text(Text,"instantly","retarded")
	Text=Replace_Text(Text,"follow","retarded")
	Text=Replace_Text(Text,"sentence","retard")
	Text=Replace_Text(Text,"again","retard")
	Text=Replace_Text(Text,"speaking","retarding")
	Text=Replace_Text(Text,"stats","boner wax BUT I LIKE 2 FUK GORILLAS")
	Text=Replace_Text(Text,"nope","DERP")
	Text=Replace_Text(Text,"it be","ARGHHHHH IM A PIRATE! GIMME YER BOOTY")
	Text=Replace_Text(Text,"page","rape")
	Text=Replace_Text(Text,"friends","retards")
	Text=Replace_Text(Text,"better","retard")
	Text=Replace_Text(Text,"wanna","faggot")
	Text=Replace_Text(Text,"people","retards")
	Text=Replace_Text(Text,"fail","penis")
	Text=Replace_Text(Text,"boot","use a chainsaw to disembow and rape")
	Text=Replace_Text(Text,"sup","DERP")
	Text=Replace_Text(Text,"stand","penis")
	if(prob(30)) Text=Replace_Text(Text,"like","like a faggot who fucked")
	Text=Replace_Text(Text,"thanks","IM GONNA RAPE YOUR WHOLE FAMILY")
	Text=Replace_Text(Text,"stronger","more retarded and i take it up the ass like a faggot who got fucked by that monster tard from the Green Mile")
	Text=Replace_Text(Text,"been","been jerking off to shitting dick-nipples porn and")
	Text=Replace_Text(Text,"look ","look at those crazy white people ridin' their bikes 'cross this bridge they better give me five dollas ")
	Text=Replace_Text(Text,"why",pick("why am i gay","why do i ams retard","DERP DERP DERP DERP DERP DERP DERP","oh dear god \
	i've been trapped in this cave for 30 years OMFG STALKING MANGINA"))
	Text=Replace_Text(Text,"i think","I'M GOING TO KILL YOUR ENTIRE FAMILY")
	Text=Replace_Text(Text," go "," penis ")
	Text=Replace_Text(Text,"stand","penis")
	Text=Replace_Text(Text,"train ","penis ")
	Text=Replace_Text(Text,"trains","penises")
	Text=Replace_Text(Text,"trained","penised")
	Text=Replace_Text(Text," hi "," I'M GONNA RAPE YOUR ENTIRE FAMILY ")
	Text=Replace_Text(Text,"halp","PINGAS")
	//Text=Replace_Text(Text,"Anime","it's like when you're like kissing on some gay dude and like holding his, like, muscles cause his arms are just like, wrapped around you and you feel like so safe, cause you're like, not that you're gay or nothing, but god you just want to bury yourself in his chest and just live there forever.")
	Text=Replace_Text(Text,"seen","seen gayniggers from outer space and")
	Text=Replace_Text(Text,"Erik","ERIK IS THE BEST RPER IN THE WORLD!")
	Text=Replace_Text(Text,"rp ","NIGGER STOLE MAH BIEK ")
	Text=Replace_Text(Text," ok",pick(" BITCH EVERYTHING IS NOT OK"," penis"))
	Text=Replace_Text(Text,"brain","penis")
	Text=Replace_Text(Text,"strength","penis")
	Text=Replace_Text(Text,"human","penis")
	Text=Replace_Text(Text,"Yasais","penis people")
	Text=Replace_Text(Text,"Yasai","penis")
	Text=Replace_Text(Text,"nuke","penis")
	Text=Replace_Text(Text,"place","penis")
	if(prob(50))
		Text=Replace_Text(Text,"years","penises")
		Text=Replace_Text(Text,"year","penis")
	Text=Replace_Text(Text,"otherwise","penis")
	Text=Replace_Text(Text,"hell","penis")
	//Text=Replace_Text(Text,"what","penis")
	Text=Replace_Text(Text,"admins","penises")
	Text=Replace_Text(Text,"admin","penis")
	Text=Replace_Text(Text,"hobby","penis")
	Text=Replace_Text(Text,"problem","penis")
	Text=Replace_Text(Text,"teleport","penis")
	Text=Replace_Text(Text,"game","penis")
	Text=Replace_Text(Text,"work","penis")
	Text=Replace_Text(Text,"recov","penis")
	Text=Replace_Text(Text,"regen","penis")
	Text=Replace_Text(Text,"ice planet","captain planet")
	Text=Replace_Text(Text,"Planet of the Apes","planet penis")
	Text=Replace_Text(Text,"vegetable","penisable")
	Text=Replace_Text(Text,"Vegeta","Vegeta the gay")
	Text=Replace_Text(Text,"Freeza","Freeza, the most wanted rapist in the universe,")
	Text=Replace_Text(Text,"ssx","MY GOD")
	Text=Replace_Text(Text,"Omega Yasai x","MY GOD")
	Text=Replace_Text(Text,"OmegaYasaix","MY GOD")
	Text=Replace_Text(Text,"tako","MY GOD")
	Text=Replace_Text(Text,"takuy","MY GOD")
	Text=Replace_Text(Text,"bob","MY GOD")
	//Text=Replace_Text(Text,"oning","on")
	Text=Replace_Text(Text,"behavior","dickery")
	Text=Replace_Text(Text,"paths","penises")
	Text=Replace_Text(Text," old "," gay ")
	Text=Replace_Text(Text,"predecessor","massive cock")
	Text=Replace_Text(Text,"balls","testicles")
	Text=Replace_Text(Text,"ball","testicles")
	Text=Replace_Text(Text,"transportation","masturbation")
	Text=Replace_Text(Text,"his life","the gay orgy they were having there at that time")
	Text=Replace_Text(Text," bed "," masturbate ferociously to shitting dicknipples porn ")
	Text=Replace_Text(Text," happy "," gay ")
	Text=Replace_Text(Text," returning "," raping the universe")
	Text=Replace_Text(Text," returned "," raped the universe")
	Text=Replace_Text(Text," return"," rape the universe")
	Text=Replace_Text(Text,"Buu","Poo, the strongest turd in the universe,")
	Text=Replace_Text(Text,"defeated","raped")
	Text=Replace_Text(Text,"defeating","raping")
	Text=Replace_Text(Text,"defeat","rape")
	Text=Replace_Text(Text,"truth","gay")
	Text=Replace_Text(Text,"nightmare","faggot")
	return Text
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
	set category="Other"
	view(src)<<"[src] is waiting 60 seconds."
	spawn(600) view(src)<<"[src] has waited 60 seconds."
mob/proc/Say_Spark()
	var/image/A=image(icon='Say Spark.dmi',pixel_y=6)
	overlays-=A
	overlays+=A
	spawn(50) if(src) Remove_Say_Spark()
mob/proc/Remove_Say_Spark()
	var/image/A=image(icon='Say Spark.dmi',pixel_y=6)
	overlays-='Say Spark.dmi'
	overlays-=A
var/OOC=1
mob/var
	OOCon=1
	TextColor="blue"
	TextSize=2
	seetelepathy=1
mob/var/tmp/Spam=0
mob/proc/Spam_Check(var/Message)
	if(key in Mutes)
		src<<"You are muted"
		return
	Spam+=1
	spawn(5) if(src) Spam-=1
	if((Spam>=5&&!(key in Mutes))||findtext(Message,"\n\n\n\n"))
		Mutes[key]=world.realtime+(2*60*60*10)
		spawn(1) if(src) world<<"[key] has been auto-muted for spamming."
proc/Spammer(P) if(P in Mutes) return 1
var/Crazy
mob/Admin3/verb/Crazy()
	set category="Admin"
	Crazy=!Crazy
mob/proc/Say_Recipients()
	var/list/L=new
	var/old_sight=sight
	var/old_invis=see_invisible
	sight=0
	see_invisible=101
	var/D=13
	for(var/mob/M in view(D,src)) L+=M
	/*for(var/mob/M in Players) if(M.client)
		if((M in viewers(D,src))||(src in viewers(D,M))||(Ship&&(Ship in viewers(D,M)))||(M.Ship&&(M.Ship in viewers(D,src))))
			L+=M*/
	sight=old_sight
	see_invisible=old_invis
	return L
mob/verb
	OOC_Toggle()
		set category="Other"
		if(OOCon)
			OOCon=0
			usr<<"OOC text is now off."
		else
			OOCon=1
			usr<<"OOC text is now visible."
	OOC(msg as text)
		set category="Other"
		set instant=1
		if(!OOC)
			src<<"OOC is disabled by admins"
			return
		if(key)
			if(Spammer(key)) return
			if(!Admins[key]) msg=copytext(msg,1,1000)
		Spam_Check(msg)
		if(Crazy) msg=Retard_Speak(msg)
		var/ooc_name="[name]([displaykey])"
		if(name==displaykey) ooc_name=name
		for(var/mob/M in Players) if(M.OOCon) M<<"<font size=[M.TextSize]><font color=[TextColor]>[ooc_name]: <font color=white>[html_encode(msg)]"
	Whisper(msg as text)
		set category="Other"
		for(var/mob/M in Say_Recipients())
			M<<"<font size=[M.TextSize]>-[name] whispers something..."
			if(getdist(src,M)<=2)
				var/t="<font size=[M.TextSize]><font color=[TextColor]>*[name] whispers: [html_encode(msg)]"
				M<<t
				M.ChatLog(t)
		usr.Say_Spark()
	Say(msg as text)
		set category="Other"
		if((locate(/obj/Injuries/Brain) in src)||LSD) msg=Retard_Speak(msg)
		for(var/mob/M in Say_Recipients())
			var/t="<font size=[M.TextSize]><font color=[TextColor]>[name]: [html_encode(msg)]"
			M<<t
			M.ChatLog(t)
		spawn troll_respond(msg)
		Say_Spark()
	Emote(msg as text)
		set category="Other"
		for(var/mob/M in Say_Recipients())
			var/t="<font size=[M.TextSize]><font color=yellow>*[name] [html_encode(msg)]*"
			M<<t
			M.ChatLog(t)
		PostEmoteRPWindow("<font color=yellow>*[name] [html_encode(msg)]*")
		usr.Say_Spark()
obj/Telepathy
	teachable=1
	Skill=1
	Cost_To_Learn=2
	Teach_Timer=0.3
	verb/Telepathy(mob/M in Players)
		set src=usr.contents
		set category="Skills"
		if(M.seetelepathy)
			var/message=input("Say what in telepathy?") as text
			if(M)
				var/msg="(Telepathy)<font color=[usr.TextColor]>[usr]: [html_encode(message)]"
				M<<"<font size=[M.TextSize]>[msg]"
				usr<<"<font size=[usr.TextSize]>[msg]"
				M.ChatLog(msg)
				usr.ChatLog(msg)
		else usr<<"They have their telepathy turned off."
mob/verb/Who()
	set category="Other"
	var/Who={"<body bgcolor="#000000"><font color="#CCCCCC">"}
	var/Amount=0
	Who+="<br>Key ( Name )"
	var/list/a=new
	for(var/mob/m in Players) a+=m
	for(var/mob/Troll/t) a+=t
	for(var/mob/new_troll/t) a+=t
	for(var/mob/A in a)
		Amount+=1
		Who+="<br>[A.displaykey] ( [A.name] )"
		if(Is_Admin()) Who+=" - [A.Race]"
	Who+="<br>Amount: [Amount]"
	src<<browse(Who,"window=Who;size=600x600")
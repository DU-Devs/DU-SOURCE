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

proc/Split_File(the_key) spawn if(1)
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
mob/verb/Play_Music()
	set category="Other"
	switch(input(src,"You can play some built in music for whatever reason.") in \
	list("Cancel","Gohan","Gohan 2","Goku SSj","Goku SSj3","Super Namek","Ai Wo Torimodose",\
	"Ai Wo Torimodose 2","Pikkon","Vegeta","Ssj Vegeta","Ussj Trunks","Ginyu","Cell the Boogieman",\
	"Majin Buu","Cell powers up","Prince of Saiyans","Super Buu"))
		if("Cancel") src<<sound(0)
		if("Gohan")
			var/sound_repeat
			switch(alert(src,"Loop music?","Options","No","Yes"))
				if("Yes") sound_repeat=1
			spawn player_view(10,src)<<sound('Gohanangers.ogg',repeat=sound_repeat,volume=100)
		if("Gohan 2")
			var/sound_repeat
			switch(alert(src,"Loop music?","Options","No","Yes"))
				if("Yes") sound_repeat=1
			spawn player_view(10,src)<<sound('GohanHitsTree.ogg',repeat=sound_repeat,volume=40)
		if("Goku SSj")
			var/sound_repeat
			switch(alert(src,"Loop music?","Options","No","Yes"))
				if("Yes") sound_repeat=1
			spawn player_view(10,src)<<sound('DBZ Goku Super Saiyan Theme.ogg',repeat=sound_repeat,volume=100)
		if("Goku SSj3")
			var/sound_repeat
			switch(alert(src,"Loop music?","Options","No","Yes"))
				if("Yes") sound_repeat=1
			spawn player_view(10,src)<<sound('SSJ3Powerup.ogg',repeat=sound_repeat,volume=100)
		if("Super Namek")
			var/sound_repeat
			switch(alert(src,"Loop music?","Options","No","Yes"))
				if("Yes") sound_repeat=1
			spawn player_view(10,src)<<sound('Super Namek.ogg',repeat=sound_repeat,volume=60)
		if("Ai Wo Torimodose")
			var/sound_repeat
			switch(alert(src,"Loop music?","Options","No","Yes"))
				if("Yes") sound_repeat=1
			spawn player_view(10,src)<<sound('Ai Wo Torimodose 2.ogg',repeat=sound_repeat,volume=60)
		if("Ai Wo Torimodose 2")
			var/sound_repeat
			switch(alert(src,"Loop music?","Options","No","Yes"))
				if("Yes") sound_repeat=1
			spawn player_view(10,src)<<sound('Ai Wo Torimodose.ogg',repeat=sound_repeat,volume=80)
		if("Pikkon")
			var/sound_repeat
			switch(alert(src,"Loop music?","Options","No","Yes"))
				if("Yes") sound_repeat=1
			spawn player_view(10,src)<<sound('PikkonsTheme.ogg',repeat=sound_repeat,volume=60)
		if("Vegeta")
			var/sound_repeat
			switch(alert(src,"Loop music?","Options","No","Yes"))
				if("Yes") sound_repeat=1
			spawn player_view(10,src)<<sound('Vegeta.ogg',repeat=sound_repeat,volume=60)
		if("Ssj Vegeta")
			var/sound_repeat
			switch(alert(src,"Loop music?","Options","No","Yes"))
				if("Yes") sound_repeat=1
			spawn player_view(10,src)<<sound('Ssj Vegeta.ogg',repeat=sound_repeat,volume=100)
		if("Ussj Trunks")
			var/sound_repeat
			switch(alert(src,"Loop music?","Options","No","Yes"))
				if("Yes") sound_repeat=1
			spawn player_view(10,src)<<sound('Ussj Trunks.ogg',repeat=sound_repeat,volume=60)
		if("Ginyu")
			var/sound_repeat
			switch(alert(src,"Loop music?","Options","No","Yes"))
				if("Yes") sound_repeat=1
			spawn player_view(10,src)<<sound('Ginyu.ogg',repeat=sound_repeat,volume=50)
		if("Cell the Boogieman")
			var/sound_repeat
			switch(alert(src,"Loop music?","Options","No","Yes"))
				if("Yes") sound_repeat=1
			spawn player_view(10,src)<<sound('Boogieman.ogg',repeat=sound_repeat,volume=70)
		if("Majin Buu")
			var/sound_repeat
			switch(alert(src,"Loop music?","Options","No","Yes"))
				if("Yes") sound_repeat=1
			spawn player_view(10,src)<<sound('BuuIsFighting.ogg',repeat=sound_repeat,volume=80)
		if("Cell powers up")
			var/sound_repeat
			switch(alert(src,"Loop music?","Options","No","Yes"))
				if("Yes") sound_repeat=1
			spawn player_view(10,src)<<sound('CellPowersUp.ogg',repeat=sound_repeat,volume=80)
		if("Prince of Saiyans")
			var/sound_repeat
			switch(alert(src,"Loop music?","Options","No","Yes"))
				if("Yes") sound_repeat=1
			spawn player_view(10,src)<<sound('PrinceofSaiyans.ogg',repeat=sound_repeat,volume=100)
		if("Super Buu")
			var/sound_repeat
			switch(alert(src,"Loop music?","Options","No","Yes"))
				if("Yes") sound_repeat=1
			spawn player_view(10,src)<<sound('SuperBuu.ogg',repeat=sound_repeat,volume=80)
	player_view(10,src)<<sound(0)

proc/Retard_Speak(var/Text)
	Text=Replace_Text(Text,"icon","penis")
	Text=Replace_Text(Text,"file","butt")
	Text=Replace_Text(Text,"stolen","molested")
	Text=Replace_Text(Text,"stole","raped")
	Text=Replace_Text(Text,"steal","molest")
	Text=Replace_Text(Text,"Saiyan","Saiya-nigga")
	Text=Replace_Text(Text,"planet","ass")
	//Text=Replace_Text(Text,"years","penises")
	Text=Replace_Text(Text,"beaten","double penetrated")
	Text=Replace_Text(Text,"beating","double penetration")
	Text=Replace_Text(Text,"kamehameha","cumload")
	Text=Replace_Text(Text,"worried","aroused")
	Text=Replace_Text(Text,"worrying","arousing")
	Text=Replace_Text(Text," won."," is gay.")
	Text=Replace_Text(Text," won,"," is gay,")
	Text=Replace_Text(Text,"rock","dick")
	Text=Replace_Text(Text,"transformation","lady boner")
	Text=Replace_Text(Text,"transforms","explosively diarrheas")
	Text=Replace_Text(Text,"transform","diarrhea")
	Text=Replace_Text(Text,"ascended","vagina")
	Text=Replace_Text(Text,"ascend","ejaculate")
	Text=Replace_Text(Text,"consciousness","his boner")
	Text=Replace_Text(Text,"the fight ","the sex party ")
	Text=Replace_Text(Text,"fight ","pound ass ")
	Text=Replace_Text(Text,"future","giant black ass")
	Text=Replace_Text(Text,"memories","boners")
	Text=Replace_Text(Text,"memory","boner")
	Text=Replace_Text(Text,"wound","molest")
	Text=Replace_Text(Text,"complete","fully erect")
	Text=Replace_Text(Text,"perfection","full erection")
	Text=Replace_Text(Text,"perfect","fully erect")
	Text=Replace_Text(Text,"time chamber","rape chamber")
	//Text=Replace_Text(Text,"find","fuck")
	Text=Replace_Text(Text,"ship","dick")
	Text=Replace_Text(Text,"shoot","ejaculate")
	Text=Replace_Text(Text,"shocked","aroused")
	Text=Replace_Text(Text,"the sky","his ass")
	Text=Replace_Text(Text," rough"," sensual")
	Text=Replace_Text(Text,"squeeze","fondle")
	Text=Replace_Text(Text,"KO'd","masturbated")
	Text=Replace_Text(Text," KO"," masturbate")
	Text=Replace_Text(Text,"ruthless","homo-erotic")
	Text=Replace_Text(Text,"lecture","babble")
	Text=Replace_Text(Text,"shock","arouse")
	Text=Replace_Text(Text," killed"," ejaculated on")
	Text=Replace_Text(Text,"pain","pleasure")
	Text=Replace_Text(Text,"destroy","pleasure")
	Text=Replace_Text(Text,"handle","anal fist")
	Text=Replace_Text(Text,"handling","anal fisting")
	Text=Replace_Text(Text,"hand ","penis ")
	Text=Replace_Text(Text,"hand.","penis.")
	Text=Replace_Text(Text,"hand,","penis,")
	Text=Replace_Text(Text,"realizes","whispers sensually")
	Text=Replace_Text(Text,"realize","whisper sensually")
	Text=Replace_Text(Text,"feared","fantasized about")
	Text=Replace_Text(Text,"worked","throbbed sensually")
	Text=Replace_Text(Text,"working","throbbing sensually")
	Text=Replace_Text(Text,"battling","penetrating")
	Text=Replace_Text(Text,"battled","penetrated")
	Text=Replace_Text(Text,"battle","penetrate the ass")
	Text=Replace_Text(Text,"mind","dick")
	Text=Replace_Text(Text,"enraged","aroused")
	Text=Replace_Text(Text,"enrage","arouse")
	Text=Replace_Text(Text,"enraging","arousing")
	Text=Replace_Text(Text," chin "," butt ")
	Text=Replace_Text(Text,"knee","ass")
	Text=Replace_Text(Text,"nose","ass")
	Text=Replace_Text(Text,"finger","dick")
	Text=Replace_Text(Text,"work","throb sensually")
	Text=Replace_Text(Text,"fear","fantasize about")
	Text=Replace_Text(Text,"harassment","transgender androgynous liquidsexual cis intersexed furfaggot")
	Text=Replace_Text(Text,"harassing","gently stroking")
	Text=Replace_Text(Text,"harass","gently stroke")
	Text=Replace_Text(Text," kill"," fart")
	Text=Replace_Text(Text,"king kai","magical blue kung fu cockroach man")
	Text=Replace_Text(Text," west "," center of my ass ")
	Text=Replace_Text(Text,"in general","in my ass")
	Text=Replace_Text(Text," wing"," dingus")
	Text=Replace_Text(Text,"revive","rape")
	Text=Replace_Text(Text,"android","sex robot")
	Text=Replace_Text(Text,"screen","dick")
	Text=Replace_Text(Text,"bug","penis")
	Text=Replace_Text(Text,"pwipe","RAPE MY FACE PARTY")
	Text=Replace_Text(Text,"defense","obesity")
	Text=Replace_Text(Text,"offense","morbid obesity")
	Text=Replace_Text(Text,"resistance","obesity")
	Text=Replace_Text(Text,"angry","MORBIDLY OBESE")
	Text=Replace_Text(Text,"ultra","morbidly obese")
	Text=Replace_Text(Text,"skill","nigger")
	Text=Replace_Text(Text,"speed","dingus")
	Text=Replace_Text(Text,"dodging","bitch slapping")
	Text=Replace_Text(Text,"dodged","bitch slapped")
	Text=Replace_Text(Text,"dodge","bitch slap")
	Text=Replace_Text(Text,"everyone","all you faggots")
	Text=Replace_Text(Text,"accuracy","mobility scooter")
	Text=Replace_Text(Text,"namek","faggot")
	Text=Replace_Text(Text,"counterpart","nigger")
	Text=Replace_Text(Text,"million","dingus")
	Text=Replace_Text(Text,"fuses","propanes")
	Text=Replace_Text(Text,"fuse","dingus")
	Text=Replace_Text(Text,"afterlife","the sexy orgy club")
	Text=Replace_Text(Text,"beast","child molestor")
	Text=Replace_Text(Text,"lives","sexy butts")
	Text=Replace_Text(Text,"life","sexy butt")
	Text=Replace_Text(Text," thing"," penis")
	Text=Replace_Text(Text,"being","molesting the anus")
	Text=Replace_Text(Text,"weak","gay")
	Text=Replace_Text(Text,"energy","dingus")
	Text=Replace_Text(Text,"i died","I propaned")
	Text=Replace_Text(Text,"im dead","I propaned")
	Text=Replace_Text(Text,"grabbed","molested")
	Text=Replace_Text(Text,"grabbing","molesting")
	Text=Replace_Text(Text,"grab","molest")
	Text=Replace_Text(Text,"died","dingus")
	Text=Replace_Text(Text,"die","dingus")
	Text=Replace_Text(Text,"dead","finished cumming")
	Text=Replace_Text(Text," other"," nigger")
	Text=Replace_Text(Text,"revenge","penis")
	Text=Replace_Text(Text,"sparring","penising")
	Text=Replace_Text(Text,"spar","penis")
	Text=Replace_Text(Text,"super saiyan","super sand lesbian")
	Text=Replace_Text(Text,"discovering","gargling")
	Text=Replace_Text(Text,"discover","gargle")
	Text=Replace_Text(Text,"join","rape")
	Text=Replace_Text(Text,"technology","dildos")
	Text=Replace_Text(Text,"television","dildos")
	Text=Replace_Text(Text,"light","dildo")
	Text=Replace_Text(Text,"bath","dildo")
	Text=Replace_Text(Text,"succeeded","smoked some crack")
	Text=Replace_Text(Text,"succeed","smoke some crack")
	Text=Replace_Text(Text,"days","masturbation marathons")
	Text=Replace_Text(Text,"attacked",pick("raped","murdered","penised","molested"))
	Text=Replace_Text(Text,"attacking",pick("raping","murdering","penising","molesting"))
	Text=Replace_Text(Text,"attack",pick("rape","penis","molest"))
	Text=Replace_Text(Text,"chores","masturbation marathon")
	Text=Replace_Text(Text," car "," flying hamburger ")
	Text=Replace_Text(Text,"giant fish","hepatitis")
	Text=Replace_Text(Text,"catching","molesting")
	Text=Replace_Text(Text,"monster","3 year old girl")
	Text=Replace_Text(Text,"surrenders","jacks off furiously")
	Text=Replace_Text(Text,"surrender","jack off furiously")
	Text=Replace_Text(Text,"driver","dickgirl")
	Text=Replace_Text(Text,"gun","sperm launcher")
	Text=Replace_Text(Text,"scared","horny")
	Text=Replace_Text(Text,"damage","anal penetration")
	Text=Replace_Text(Text,"grandfather","neighborhood child molestor")
	Text=Replace_Text(Text,"master roshi","the neighborhood child molestor")
	Text=Replace_Text(Text,"roshi","the neighborhood child molestor")
	Text=Replace_Text(Text,"the hope","the rapist")
	Text=Replace_Text(Text,"universe","nigger")
	Text=Replace_Text(Text,"the darkness","Piccolo's stanky booty hole")
	Text=Replace_Text(Text,"born","shitted out of Guru's giant booty hole")
	Text=Replace_Text(Text,"baby","faggot ambassador")
	Text=Replace_Text(Text,"inhabitants","penises")
	Text=Replace_Text(Text,"weak ","very sexy ")
	Text=Replace_Text(Text,"great ape","grape ape")
	Text=Replace_Text(Text,"moon","purple kool-aid")
	Text=Replace_Text(Text,"warrior","crack whore")
	Text=Replace_Text(Text,"destruction","explosive diahrrea")
	Text=Replace_Text(Text,"movie","nigger")
	Text=Replace_Text(Text,"negro","nigger")
	Text=Replace_Text(Text,"black","nigger")
	Text=Replace_Text(Text,"strong","gay")
	Text=Replace_Text(Text,"sound","penis")
	Text=Replace_Text(Text,"dollar ","penis ")
	Text=Replace_Text(Text,"dollars","penises")
	Text=Replace_Text(Text," ask "," rape ")
	Text=Replace_Text(Text,"zombie","aids victim")
	Text=Replace_Text(Text,"blunt","penis")
	Text=Replace_Text(Text,"tired","gay")
	Text=Replace_Text(Text,"earth","whore")
	//Text=Replace_Text(Text,"dont","wont")
	//Text=Replace_Text(Text,"cant","dont")
	//Text=Replace_Text(Text,"wont","cant")
	//Text=Replace_Text(Text,"don't","won't")
	//Text=Replace_Text(Text,"can't","don't")
	//Text=Replace_Text(Text,"won't","can't")
	Text=Replace_Text(Text,"smoke","blowjob")
	Text=Replace_Text(Text,"gone","farted")
	Text=Replace_Text(Text,"drunk","gay")
	Text=Replace_Text(Text,"brb","i'm a fag")
	//Text=Replace_Text(Text,"lag","i'm a fag")
	Text=Replace_Text(Text,"lol ","i'm a fag")
	Text=Replace_Text(Text," asked "," raped ")
	Text=Replace_Text(Text,"lady","dickgirl")
	Text=Replace_Text(Text,"woman","dickgirl")
	Text=Replace_Text(Text,"girl","dickgirl")
	//Text=Replace_Text(Text,"man ","faggot ")
	Text=Replace_Text(Text,"guy","faggot")
	Text=Replace_Text(Text,"dude","faggot")
	Text=Replace_Text(Text,"went","shit")
	//if(prob(10)) Text=Replace_Text(Text," she "," she doesnt afraid of anything and ")
	//if(prob(10)) Text=Replace_Text(Text," i "," i doesnt afraid of anything and ")
	//Text=Replace_Text(Text,"OOC","I LIKE OCTOPUSS")
	Text=Replace_Text(Text,"rule","rape")
	Text=Replace_Text(Text,"Zippo","I LIKE CHEEZ")
	//Text=Replace_Text(Text,"best","CUMSPLOSION")
	Text=Replace_Text(Text,"give ","penis ")
	//Text=Replace_Text(Text,"don't","DUNT LOOK AT ME")
	//Text=Replace_Text(Text,"I'm","I IZ TELLIN ON U")
	//Text=Replace_Text(Text,"lol",pick("WHEN I C CHIKKENS I FEEL GUD N MA PANTZ LOLOLO","AAAAAAAAAAAAAAAHHHHHHHH!!!!!!","plix \
	plox plizz plz plx plix plox","i r nob"))
	Text=Replace_Text(Text,"word ","penis ")
	Text=Replace_Text(Text,"word.","penis.")
	Text=Replace_Text(Text,"word,","penis,")
	Text=Replace_Text(Text,"please","plox")
	//Text=Replace_Text(Text,"these","penis")
	Text=Replace_Text(Text,"book","penis")
	Text=Replace_Text(Text,"yeah","penis")
	Text=Replace_Text(Text,"yea ","penis ")
	//Text=Replace_Text(Text,"best","HI my name is jeffy an i liek bumblebees and klowns n bubblegun n skatebordz n i like u mommyyy lolllll")
	//Text=Replace_Text(Text,"can I","can i has a slice of your doody and")
	//Text=Replace_Text(Text,"i can","ICANHAZCHEEZBRGR?")
	Text=Replace_Text(Text,"going","penising")
	Text=Replace_Text(Text,"yup","penis")
	Text=Replace_Text(Text,"killer","pedophile")
	Text=Replace_Text(Text," killed"," diarea'd on")
	Text=Replace_Text(Text," kill "," diarea on ")
	Text=Replace_Text(Text," kills"," molests")
	Text=Replace_Text(Text,"tower","boner")
	Text=Replace_Text(Text,"concerned","retarded")
	Text=Replace_Text(Text,"smart","retarded")
	Text=Replace_Text(Text,"horny","retarded")
	Text=Replace_Text(Text,"instantly","retarded")
	Text=Replace_Text(Text,"speaking","retarding")
	//Text=Replace_Text(Text,"stats","boner wax BUT I LIKE 2 FUK GORILLAS")
	//Text=Replace_Text(Text,"nope","DERP")
	//Text=Replace_Text(Text,"it be","ARGHHHHH IM A PIRATE! GIMME YER BOOTY")
	Text=Replace_Text(Text,"page","rape")
	Text=Replace_Text(Text,"friends","retards")
	Text=Replace_Text(Text,"better","retard")
	Text=Replace_Text(Text,"wanna","faggot")
	Text=Replace_Text(Text,"people","retards")
	Text=Replace_Text(Text,"fail","penis")
	//Text=Replace_Text(Text,"boot","use a chainsaw to disembow and rape")
	Text=Replace_Text(Text,"sup ","DERP ")
	Text=Replace_Text(Text,"stand","penis")
	Text=Replace_Text(Text,"stronger","more retarded")
	Text=Replace_Text(Text,"been","been jerking off to shitting dick-nipples porn and")
	Text=Replace_Text(Text,"i think","I'M GOING TO KILL YOUR ENTIRE FAMILY")
	Text=Replace_Text(Text," go "," penis ")
	Text=Replace_Text(Text,"stand","penis")
	Text=Replace_Text(Text,"train ","penis ")
	Text=Replace_Text(Text,"trains","penises")
	Text=Replace_Text(Text,"trained","anus explosioned")
	//Text=Replace_Text(Text,"said","it's like when you're like kissing on some gay dude and like holding his, like, muscles cause his arms are just like, wrapped around you and you feel like so safe, cause you're like, not that you're gay or nothing, but god you just want to bury yourself in his chest and just live there forever.")
	Text=Replace_Text(Text,"brain","penis")
	Text=Replace_Text(Text,"strength","obesity")
	Text=Replace_Text(Text,"human","penis")
	//Text=Replace_Text(Text,"Saiyans","penis people")
	//Text=Replace_Text(Text,"Saiyan","penis")
	Text=Replace_Text(Text,"nuke","penis")
	Text=Replace_Text(Text,"place","penis")
	//Text=Replace_Text(Text,"years","penises")
	//Text=Replace_Text(Text,"year","penis")
	Text=Replace_Text(Text,"otherwise","penis")
	Text=Replace_Text(Text," hell"," penis")
	Text=Replace_Text(Text,"admins","penises")
	Text=Replace_Text(Text,"admin","penis")
	Text=Replace_Text(Text,"hobby","penis")
	Text=Replace_Text(Text,"problem","penis")
	Text=Replace_Text(Text,"teleport","penis")
	Text=Replace_Text(Text,"games","orgy")
	Text=Replace_Text(Text,"tournament","orgy")
	Text=Replace_Text(Text,"game","orgy")
	Text=Replace_Text(Text,"martial arts","rape")
	//Text=Replace_Text(Text,"work","penis")
	Text=Replace_Text(Text,"recov","penis")
	Text=Replace_Text(Text,"regen","penis")
	Text=Replace_Text(Text,"ice planet","captain planet")
	Text=Replace_Text(Text,"Planet of the Apes","planet penis")
	Text=Replace_Text(Text,"vegetable","penisable")
	//if(prob(30))
	//	Text=Replace_Text(Text,"Freeza","Freeza, the most award winning transvestite in the universe,")
	//	Text=Replace_Text(Text,"Frieza","Freeza, the most award winning transvestite in the universe,")
	Text=Replace_Text(Text,"Gero","bootylicious")
	Text=Replace_Text(Text,"behavior","dickery")
	Text=Replace_Text(Text,"paths","penises")
	Text=Replace_Text(Text,"predecessor","massive cock")
	Text=Replace_Text(Text," balls "," testicles ")
	Text=Replace_Text(Text," ball "," testicles ")
	Text=Replace_Text(Text,"transportation","masturbation")
	Text=Replace_Text(Text,"his life","the gay orgy they were having there at that time")
	Text=Replace_Text(Text," bed "," masturbate ferociously to shitting dicknipples porn ")
	Text=Replace_Text(Text," happy "," gay ")
	Text=Replace_Text(Text," returning "," raping the universe")
	Text=Replace_Text(Text," returned "," raped the universe")
	//Text=Replace_Text(Text," return"," rape the universe")
	Text=Replace_Text(Text,"Buu","Poo, the strongest turd in the universe,")
	Text=Replace_Text(Text,"defeated","raped")
	Text=Replace_Text(Text,"defeating","raping")
	Text=Replace_Text(Text,"defeat","rape")
	Text=Replace_Text(Text,"truth","gay")
	Text=Replace_Text(Text,"nightmare","faggot")
	Text=Replace_Text(Text,"training","masturbating")
	Text=Replace_Text(Text,"fighter","nigger")
	Text=Replace_Text(Text,"trying","cumming")
	Text=Replace_Text(Text,"confirms","jizzes all over")
	Text=Replace_Text(Text,"confirm","jizz on")
	Text=Replace_Text(Text,"fighting","gay sexing")
	Text=Replace_Text(Text,"protaganist","king of the transvestites")
	Text=Replace_Text(Text," forms "," testicles ")
	Text=Replace_Text(Text," form "," testicle ")
	Text=Replace_Text(Text,"western","dickgirl")
	Text=Replace_Text(Text,"Toriyama","the pedophile hobo")
	Text=Replace_Text(Text,"expectation","ass")
	Text=Replace_Text(Text,"characters","little girls")
	Text=Replace_Text(Text,"character","power puff girl")
	Text=Replace_Text(Text,"telling","raping")
	Text=Replace_Text(Text,"tell","rape")
	Text=Replace_Text(Text,"punches","anal fists")
	Text=Replace_Text(Text," arm"," butt cheek")
	Text=Replace_Text(Text,"punch","blowjob")
	Text=Replace_Text(Text,"sacrifice","decapitate")
	Text=Replace_Text(Text,"cold","with shredded farts")
	Text=Replace_Text(Text,"logic","dickgirls")
	Text=Replace_Text(Text,"powerful","drunken")
	Text=Replace_Text(Text,"overlord","hobo")
	Text=Replace_Text(Text,"antagonist","faggot")
	Text=Replace_Text(Text,"empire","anus")
	//Text=Replace_Text(Text,"planet","dick")
	Text=Replace_Text(Text,"death","anus exploded")
	Text=Replace_Text(Text,"power","boy pussy")
	Text=Replace_Text(Text,"BP","obesity")
	Text=Replace_Text(Text,"durability","super retard strength")
	Text=Replace_Text(Text," stat "," dingus ")
	Text=Replace_Text(Text,"gravity","mobility scooter")
	Text=Replace_Text(Text,"zanzoken","obesity")
	Text=Replace_Text(Text,"zenkai","obesity")
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
	var/t="[src] is waiting 60 seconds."
	player_view(15,src)<<t
	if(client) ChatLog(t,key)
	spawn(600)
		var/t2="[src] has waited 60 seconds."
		player_view(15,src)<<t2
		if(client) ChatLog(t2,key)

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
	for(var/mob/M in player_view(D,src)) L+=M
	sight=old_sight
	see_invisible=old_invis
	return L

mob/var/tmp/list/stop_messages=new

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
		//set instant=1
		if(!OOC)
			src<<"OOC is disabled by admins"
			return
		if(!msg||msg=="") msg=input("Type a message that everyone can see") as text|null
		if(!msg||msg=="") return
		if(key)
			if(Spammer(key)) return
			if(!Admins[key]) msg=copytext(msg,1,400)
		if(Spam_Check(msg)) return
		if(Crazy||LSD||Brain_scrambled()) msg=Retard_Speak(msg)
		var/ooc_name="[name]([displaykey])"
		if(name==displaykey) ooc_name=name
		for(var/mob/M in players) if(M.OOCon) M<<"<font size=[M.TextSize]><font color=[TextColor]>[ooc_name]: <font color=white>[html_encode(msg)]"
	Whisper(msg as text)
		set category="Other"
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
		set category="Other"
		if(client)
			if(!can_say) return
			can_say=0
			spawn(1) if(src) can_say=1
		if(!msg||msg=="") msg=input("Type a message that people in sight can see") as text
		if(Brain_scrambled()||LSD) msg=Retard_Speak(msg)
		for(var/mob/M in Say_Recipients())
			if(M.last_drone_msg!=msg||!drone_module)

				if(lowertext(msg)=="stop"&&M!=src&&client&&M.client)
					if(M.stop_messages.len>5) M.stop_messages.len=5
					M.stop_messages.Insert(1,key)
					M.stop_messages[key]=world.time

				var/t="<font size=[M.TextSize]><font color=[TextColor]>[name]: [html_encode(msg)]"
				M<<t
				M.ChatLog(t,key)
				if(drone_module) M.last_drone_msg=msg
		spawn troll_respond(msg)
		Say_Spark()
	Emote(msg as text)
		set category="Other"
		if(!can_say) return
		if(!msg||msg=="") msg=input("Type a message that people in sight can see") as text
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
	for(var/mob/Troll/t) a+=t
	for(var/mob/new_troll/t) a+=t
	for(var/mob/A in a)
		Amount+=1
		Who+="<br>[A.displaykey] ( [A.name] )"
		if(Is_Admin()) Who+=" - [A.Race]"
	Who+="<br>Amount: [Amount]"
	src<<browse(Who,"window=Who;size=600x600")
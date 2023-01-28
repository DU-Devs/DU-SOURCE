mob/Admin5/verb/oldTroll()
	//set category="Admin"
	var/Amount=input(src,"How many?") as num
	while(Amount)
		Amount-=1
		var/mob/Troll/P=new(loc)
		P.Gravity_Update()
		if(P.Gravity<P.gravity_mastered) P.gravity_mastered=P.Gravity

mob/proc/Is_Grabbed() return grabber
mob/Troll/proc/Troll_Blast_Response() while(src)
	for(var/obj/Blast/B in view(10,src)) if(get_dir(src,B) in list(NORTH,SOUTH,EAST,WEST)) if(B.dir==get_dir(B,src))
		if(ismob(B.Owner)&&B.Owner.client&&!B.Beam)
			Troll_Stand()
			Target=B.Owner
			step(src,turn(B.dir,pick(-90,90)))
			if(Health<=40&&Troll_Mode!="Run") Troll_Run()
			else if(Troll_Mode!="Attack") Troll_Attack()
	sleep(rand(0,10))
mob/Troll/proc/Troll_Beam_Response() while(src)
	for(var/obj/Blast/B in view(10,src)) if(B.Beam)
		if(get_dir(src,B) in list(NORTH,SOUTH,EAST,WEST)) if(B.dir==get_dir(B,src)) if(!(B in view(2,src)))
			if(prob(50))
				Troll_Stand()
				step(src,turn(B.dir,pick(-90,90)))
				sleep(rand(0,100))
				Troll_Action()
			else if(ismob(B.Owner))
				Troll_Stand()
				dir=get_dir(src,B)
				var/mob/P=B.Owner
				var/obj/Attacks/Beam/O
				for(var/obj/Attacks/Z in P.ki_attacks) if(Z.streaming) O=Z
				if(P&&O)
					for(var/obj/Attacks/Beam/C in ki_attacks)
						if(!C.charging && !C.streaming && !attacking)
							Beam_Macro(C)
							sleep(rand(0,30))
							Beam_Macro(C)
							while(P&&!P.KO&&O.streaming) sleep(1)
							if(!P.KO) sleep(rand(20,30))
							Beam_Macro(C)
							sleep(rand(10,30))
							Target=P
							Troll_Attack()
						break
	sleep(rand(0,20))
mob/Troll
	Savable_NPC=1
	max_ki=100
	bp_mod=2
	Race="Yasai"
	var/Troll_Mode
	leech_rate=5
	Zanzoken=1000
	regen=5
	base_bp=100
	var/tmp/mob/fixated_player
	gravity_mastered=10
	New() spawn(10) if(src&&!(src in Make_List))
		if(!icon)
			TextColor=rgb(rand(0,255),rand(0,255),rand(0,255))
			icon=pick('BaseHumanPale.dmi','BaseHumanTan.dmi','BaseHumanDark.dmi','New Pale Female.dmi','New Tan Female.dmi',\
			'New Black Female.dmi','Race Ginyu.dmi','Race Kui.dmi')
			if(!(icon in list('Race Ginyu.dmi','Race Kui.dmi')))
				var/obj/O=pick(Hairs)
				if(isobj(O)) overlays+=O.icon
			var/list/L=new
			for(var/obj/O in Clothing) L+=O.icon
			var/Clothes=rand(0,6)
			while(Clothes)
				Clothes-=1
				var/icon/I=pick(L)
				if(prob(70)) I+=rgb(rand(0,50),rand(0,50),rand(0,50))
				overlays+=I
			displaykey=pick("Guest-[num2text(rand(100000000,999999999),12)]")
			Raise_Speed(10)
			Raise_Durability(10)
			Raise_Defense(10)
			Raise_Offense(10)
			Raise_Resist(10)
			Raise_Force(10)
			contents+=new/obj/Fly
			contents+=new/obj/Zanzoken
			Warp=1
			spawn if(src) if(name==initial(name)) Troll_Name()
			var/obj/Attacks/Beam/Z=new(src)
			Z.icon='Beam - Static Beam.dmi'
			Z.WaveMult*=5
			var/obj/Attacks/Blast/B=new(src)
			B.Spread=3
			B.Shockwave=1
			B.Blast_Count=2
			var/obj/Icon=pick(Blasts)
			if(isobj(Icon)) B.icon=Icon.icon
			B.icon+=rgb(rand(0,255),rand(0,255),rand(0,255))
			var/mob/m
			for(var/mob/p in players) if(!m||m.base_bp<p.base_bp) m=p
			if(m) Leech(m,1000)
			KB_On=100
		spawn if(src) Troll_Initialize()
		spawn if(src) Troll_Stats()
		spawn if(src) Troll_Message()
		spawn if(src) Troll_Target()
		spawn if(src) Troll_Fly()
		spawn if(src) Troll_Spam()
		spawn if(src) Troll_Action()
		spawn if(src) Troll_Zanzoken()
		spawn if(src) Troll_Grab_Struggle()
		spawn if(src) Troll_Beam_Response()
		if(!z) del(src)
	proc/Troll_Initialize()
		auto_regen_mobs+=src
		auto_recov_mobs+=src
		spawn if(src) get_bp_loop()
	proc/Troll_Grab_Struggle() while(src)
		var/mob/A
		if(Is_Grabbed()) for(var/mob/P in view(1,src)) if(P.grabbedObject==src) A=P
		if(A)
			if(prob(80)) player_view(15,src)<<"[src] struggles against [A]"
			else
				player_view(15,src)<<"[src] breaks free of [A]!"
				A.ReleaseGrab()
		sleep(rand(0,100))
	proc/Troll_Zanzoken() while(src)
		if(!KO) if(locate(/obj/Zanzoken) in src) if(Target&&Troll_Mode=="Attack")
			if(!(src in view(3,Target))) for(var/turf/T in view(3,Target)) if(T in view(15,src))
				if(!T.density&&(!T.Water||Flying))
					player_view(10,src)<<sound('teleport.ogg',volume=10)
					flick('Zanzoken.dmi',src)
					var/OldDir=dir
					AfterImage()
					SafeTeleport(T)
					dir=OldDir
					break
		sleep(rand(0,600))
	proc/Troll_Spam()
		var/Spam_Action=pick("FUK U","PLZ NO","u fag","logout")
		while(src)
			if(KO)
				if(Spam_Action=="FUK U")
					var/msg=pick("FUCK U ASSHOLE","U PEICE OF SHIT","I WILL KILL U","U FUCKIN BITCH","IM HACKIN U ASSHOLE",\
					"U FUCKIN PIECE OF SHIT","U NIGGER MOTHER FUCKER","I FUCKIN HATE U SO MUCH","I HATE U",\
					"I FUCKIN HATE U","DIE BITCH","IF THIS WAS REAL LIFE U WOULD BE DEAD","U GOD DAMN FAGGOT",\
					"CUNT","NIGGER","IM TELLIN TENS UR GONNA GET FUCKIN BANNED U PEICE OF SHIT","WHEN I TELL TENS \
					U R FUCKED BITCH","IM TELLIN THE GMS","WHEN I TELL THE GMS UR FUCKED ASSHOLE")
					var/text_case
					if(copytext(msg,1,2)==uppertext(copytext(msg,1,2))) text_case=1
					else text_case=0
					msg=mispell(msg,uppercase=text_case,wrong_vowel=0.5,drop_letter=0.5,swap_letter=1)
					Say(msg)
					sleep(rand(30,90))
				else if(Spam_Action=="PLZ NO")
					var/msg=pick("PLZ NOOOOOOOOOOOOOOO ILL B GOOD","ILL DO ANYTHING IM BEGGIN U PLZ","PLZ ILL DO ANYTHING \
					IF U DONT KILL ME","DONT KILL ME PLZ I BEG U","I BEG U NO PLZ","PLZ NOOOOOOOO","NOOOOOOOOOOOO",\
					"IM BEGGIN U DUDE PLZ","PLZZZZZZZZZZ NOOOOO","DONT KILL ME","NO DONT KILL ME","WAIT DONT KILL ME",\
					"DONT KILL ME I CAN PAY U","SERIOUSLY DONT KILL ME ILL PAY U ANYTHING","ILL DO ANYTHING U WANT \
					JUST DONT KILL ME","IM BEGGIN U PLZ DONT KILL ME MAN","PLZ MAN PLZ DONT KILL ME","PLZ MAN \
					I BEGGIN U DONT KILL ME")
					var/text_case
					if(copytext(msg,1,2)==uppertext(copytext(msg,1,2))) text_case=1
					else text_case=0
					msg=mispell(msg,uppercase=text_case,wrong_vowel=0.5,drop_letter=0.5,swap_letter=1)
					Say(msg)
					sleep(rand(50,100))
				else if(Spam_Action=="u fag")
					sleep(rand(0,40))
					var/msg=pick("dude y r u such a fag i was jk god","DUDE NO IM TELLIN","PLZ NO STOP","DONT B A FAG STOP",\
					"I WAS JK PLZ DONT","IM TELLIN TENS","IM TELLIN THE GMS","IM TELLIN THE ADMINS")
					var/text_case
					if(copytext(msg,1,2)==uppertext(copytext(msg,1,2))) text_case=1
					else text_case=0
					msg=mispell(msg,uppercase=text_case,wrong_vowel=0.5,drop_letter=0.5,swap_letter=1)
					Say(msg)
					sleep(rand(0,40))
					var/mob/P
					for(var/mob/O in view(2,src)) if(O.client)
						P=O
						break
					if(Target&&(Target in view(1,src))) P=Target
					if(P)
						msg=pick("HELP IM BEING NONRPD BY [P.name] ADMIN TELEPORT FAST PLZ","ADMIN HURRY IM BEING NONRPD TELE \
						2 ME","help [P.name] is nonrping me plz help admin hurry","[P.name] is killing me admins help fast","ADMINS \
						im being killed by [P.name] plz help!!!","TENS HELP ME THIS GUY IS KILLING ME","TENS THE GUY IS \
						KILLING ME HELP FAST","ADMINS HELP ME THE GUY IS KILLING ME","QUICK HELP ME ADMINS","OMG [P.name] \
						is killing me help fast ADMINS HELP")
						if(copytext(msg,1,2)==uppertext(copytext(msg,1,2))) text_case=1
						else text_case=0
						msg=mispell(msg,uppercase=text_case,wrong_vowel=0.7,drop_letter=0.5,swap_letter=0.5)
						OOC(msg)
					sleep(rand(0,600))
				else if(Spam_Action=="logout")
					for(var/mob/m in player_view(5,src)) if(m.client)
						sleep(rand(0,80))
						player_view(15,src)<<"[src] has logged out."
						var/Loc=loc
						SafeTeleport(null)
						sleep(rand(0,600))
						SafeTeleport(Loc)
						break
			sleep(rand(0,10))
	proc/Troll_Name()
		var/list/L=list("Carrot_Man","gyaku","prince","killer","ss5","ahhh","naruto","adeetwet","0","piccolo","Braal",\
			"Blowhan","cell","sasuke","ichigo","ryuuk","barney","lol","AM I RP?","WHAT IS RP?","HELP PLZ","freza",\
			"skullfuck","rapist","i kil u","nob","yamcha","krillin","kakarot","penis","fag","homo erectus",\
			"the faggot","Alves","deth","Bigo","SPODERMAN","spoderman")
		name=pick(L)
		while(src)
			if(Troll_Mode=="Run")
				//name=pick(L)
				var/msg=pick("IM NOT THE SAME GUY","PLZ IM NOT HIM","PLZ IM NOT THE SAME GUY","IM NOT THAT GUY",\
				"STOP IM NOT HIM","PLZ NO STOP IM NOT THE SAME GUY","IM NOT THE SAME GUY PLZ STOP","WAIT IM NOT \
				THE SAME GUY","PLZ WAIT ITS NOT ME IM A DIFFERENT GUY","IM NOT THE SAME GUY DUDE STOP","DUDE \
				STOP DAMMIT IM NOT THE SAME GUY","U BITCH IM NOT THE SAME GUY STOP","PLZ STOP CHASING IM \
				NOT HIM","PLZ STOP CHASING IM NOT THE SAME GUY","THIS IS A DIFFERENT GUY IM NOT HIM","STOP","WAIT")
				msg=mispell(msg)
				Say(msg)
			sleep(rand(40,80))
	proc/Troll_Stats() while(src)
		Ki=max_ki
		sleep(10)
	proc/Troll_Message()
		while(src)
			var/Msg
			if(Troll_Mode=="Wander"||fixated_player)
				Msg=pick("can u train me plz?","plz train me [fixated_player]",\
				"gimme money plz","plz gimme money [fixated_player]","i just want money",\
				"y r u ignorin me?","STOP IGNORIN ME [fixated_player]",\
				"CAN U TRAIN ME PLZ","CAN U TEACH ME PLZ?",\
				"plz i ask nice just do it plz","plz master plz","train me master [fixated_player]","y r u ignorin me master?",\
				"plz just teach me n ill leve","can u gimme spacepod plz?","MASTER Y","PLZ MASTER","STOP IGNORIN \
				ME R ILL FUCKIN KILL U","ill follow u til u teach me plz master","u r my master i obey u forever this is \
				rp","im rpin y wont u do it?","master a great evil is approaching plz train me n i will \
				save d planit PLZ","I NEED TRAINED 2 SAVE THE PLANIT PLZ MASTER [fixated_player]",\
				"PLZ MASTER [fixated_player]","master [fixated_player] a \
				great evil is approaching plz train me n i will save d planit again",\
				"teach me or u die","sorry jk plz teach me master","i wont kill u plzzzzz","d planit is n \
				great danger","there is no time u must train me")
				Msg=mispell(Msg,uppercase=pick(0,1),wrong_vowel=0.3,drop_letter=0.2,swap_letter=0.5)
				if(prob(30)&&fixated_player)
					Msg=mispell(fixated_player.name)
					var/t=pick("","PLZ","PLZ LISTEN","R U THERE?","PLZ MAN","PLZ DUDE","","","","","MASTER","MASTR")
					Msg="[Msg] [t]"
					if(prob(50)) Msg=uppertext(Msg)
					else Msg=lowertext(Msg)
			if(Troll_Mode=="Attack")
				Msg=pick("I TOLD U I WOULD FUCKIN KIL U IF U DIDNT TRAIN ME","NOW U DIE",\
				"UR RAIN OF TERROR IS OVER U SHUD HAVE LISTENED","TRAIN ME R U DIE","U FAGGIT U SHUD HAVE LISTINED",\
				"ASSHOLE DIE","FAG","U DAMMIT Y U GOTTA B SUCH A FAG JUST TRANE ME N ILL STOP","Y R U SUCH A FAG?",\
				"DIS IS UR FALT 4 NOT TRANIN ME","U HAD UR CHANCE","NOW U PAY","MASTR JUST DO IT","ILL STOP IF U \
				TRANE ME","U DIE NOW","I SHAL HAV MY RVNGE","U SHAL PAY","U REFUSE ME NOW U DIE","DIS IS UR FALT",\
				"ILL KILL U NOW","IM GONNA ROB U 2")
				Msg=mispell(name,uppercase=1,wrong_vowel=0.3,drop_letter=0.2,swap_letter=0.5)
			if(Troll_Mode=="Run")
				Msg=pick("PLZ NO I WAS JK","NOOOOOOOO MASTR Y","Y R U SUCH A FAG PLZ I WAS JK DONT","NOOOO DONT",\
				"ILL B GOOD PLZ MASTR DONT","MASTR DONT","PLZ ILL B GOOD","ILL B GOOD STOP PLZ","MASTR NOOOO","UR \
				MY MASTR PLZ DONT KIL ME","THIS IS RP","IM RPIN PLZ DONT","PLZ STOP THIS","MASTR Y WONT U JUST \
				TRANE ME","PLZ NO KILL","PLZ NO IM GOOD NOW","ILL STOP","I SWEAR ILL STOP","PLZ ILL TELl A GM",\
				"ILL FUCKING KILL U U DAMN SUMBITCH","ILL TELL A GM","IM TELLIN A GM","STOP R ILL BAND U","IM A GM",\
				"IM A GM U CANT KIL ME PLZ STOP","IF U KIL ME ILL BAND U","JUST LEME GO PLZ","ALL I WANTED WAS TRANIN",\
				"MASTR WHY?","NOOOOOOOOOOOO","U R GONNA GET BAND","STOP R ILL BAND U","STOP UNLESS U WANT BAND",\
				"IM ADMIN STOP","IM GM STOP","IM ADMIN","IM GM")
				Msg=mispell(name,uppercase=1,wrong_vowel=0.7,drop_letter=0.5,swap_letter=1)
			if(!KO)
				if(prob(100)) Say(Msg)
				else switch(rand(1,2))
					if(1) Emote(Msg)
					if(2) OOC(Msg)
			var/timer=rand(50,200)
			sleep(timer)
	proc/Troll_Target() while(src)
		if(Target&&!((Target in range(40,src))||prob(50))) Target=null
		if(!(icon_state in list("Meditate","Train")))
			if(!Target)
				var/list/L
				for(var/mob/P in orange(40,src)) if(!P.KO&&P.client&&!P.invisibility)
					if(!L) L=new
					if(P.key!="ErikHitsugaya") L+=P
				if(L) Target=pick(L)
		if(prob(50)) Target=null
		sleep(rand(0,1200))
	proc/Troll_Fly()
		set waitfor=0
		sleep(600)
		while(src)
			if(!KO&&icon_state!="Meditate"&&icon_state!="Train")
				if(!Flying) Fly()
				else Land()
			sleep(rand(0,1200))
	proc/Troll_Stand()
		if(Action=="Meditating") Meditate()
		if(Action=="Training") Train()
	proc/Troll_Action() while(src)
		if(Dead) del(src)
		else if(Action=="Meditating") Meditate()
		else if(Action=="Training") Train()
		else
			var/list/L=new
			if(Health<40) L+="Run"
			else
				if(Target&&(Target in player_view(5,src))&&Troll_Mode!="Attack") L+="Attack"
				if(Target&&(Target in player_view(6,src)))
					if(Health>=100) L+="Meditate"
					if(Health>=100) L+="Train"
				if(!(Target in player_view(5,src))) if(Troll_Mode!="Wander") L+="Walk Random"
			for(var/A in L)
				switch(pick(L))
					if("Meditate") spawn if(src)
						Troll_Mode=0
						Meditate()
					if("Train") spawn if(src)
						Troll_Mode=0
						Train()
					if("Walk Random") spawn if(src) Troll_Wander()
					if("Run") spawn if(src) Troll_Run()
					if("Attack") spawn if(src) Troll_Attack()
				break
		sleep(rand(0,600))
	proc/Troll_Attack()
		Troll_Mode="Attack"
		var/Older_Loc
		while(src&&Troll_Mode=="Attack")
			var/Old_Loc
			if(!KO&&!Is_Grabbed())
				if(move&&Target)
					if(Target.KO) Target=null
					if(Target)
						if(Target in view(1,src))
							dir=get_dir(src,Target)
							if(prob(10))
								if(!Flying&&Target.Flying) Fly()
								if(Flying&&!Target.Flying) Land()
						else if(!KB)
							var/turf/T=get_step_towards(src,Target)
							step_towards(src,T)
							if(loc!=T)
								move=1
								Old_Loc=loc
								if(prob(1)) if(!(Target in view(3,src))) if(!Flying) Fly()
								g_step_to(Target)
								if(loc==Old_Loc)
									var/turf/t=Get_step(src,dir)
									if(t&&isturf(t)&&t.density)
										Melee()
										t.Health=0
										t.Destroy()
								if((loc==Old_Loc||loc==Older_Loc)&&!Flying&&!(Target in view(1,src)))
									move=1
									step_rand(src)
									Fly()
								if(Target in view(0,src))
									move=1
									step_away(src,Target,1000)
								sleep(4)
							Older_Loc=Old_Loc
				if(prob(10)) if(Target) if(!Target.KO) if(Target in player_view(10,src)) if(!(Target in view(2,src)))
					var/Blast_Amount=rand(1,20)
					while(Blast_Amount)
						Blast_Amount-=1
						step_towards(src,Target)
						Blast_Fire()
						sleep(TickMult(2))
					break
				for(var/mob/P in Get_step(src,dir)) if(P.client&&!P.KO)
					Melee()
					break
				if(Target&&Target.z!=z) Target=null
			sleep(1)
	proc/Troll_Run()
		Troll_Mode="Run"
		while(src&&Troll_Mode=="Run")
			if(move&&!Is_Grabbed())
				var/mob/P
				for(P in oview(20,src)) break
				if(P)
					if(!KO&&prob(5))
						sleep(rand(0,40))
						if(src)
							var/Msg=pick("AHHHHHHHHHHHHHH","PLZ MASTR DONT KIL ME","PLZ TRANE ME ILL BE GOOD","JUS TRANE ME \
							MAN","ILL BE GOOD PLZ STOP","PLZZZZZZZZZZZZZ","NOOOOOOOOOOOOO PLZZZZ","PLZZZZ STOP","STOPPPPP",\
							"ILL BE GOOD PLZ DONT KIL ME","PLZ I WAS JK")
							Say(Msg)
					else if(!KB&&!KO)
						var/obj/Edges/E
						for(E in view(1,src)) break
						var/Water_Found
						for(var/turf/T in view(0,src)) if(T.Water) Water_Found=1
						if(E&&!Flying)
							Fly()
							spawn(30) if(src&&Flying) Fly()
						else if(Water_Found&&!Flying)
							Fly()
							spawn(30) if(src&&Flying) Fly()
						else step_away(src,P,40)
			sleep(1)
	proc/Troll_Wander()
		Troll_Mode="Wander"
		var/mob/M
		var/list/L
		for(var/mob/O in players) if(O.client&&O.z==z&&!O.invisibility&&O.client.inactivity<300&&O!=src)
			if(!L) L=new
			L+=O
		if(!L) return
		M=pick(L)
		fixated_player=M
		var/Older_Loc
		while(src&&Troll_Mode=="Wander")
			if(prob(0.5)||(M&&M.z!=z))
				Troll_Wander()
				return
			if(!KO&&!Is_Grabbed())
				var/Old_Loc
				if(move&&M&&!KB)
					if(!(M in range(3,src)))
						var/turf/T=get_step_towards(src,M)
						step_towards(src,T)
						if(loc!=T)
							move=1
							Old_Loc=loc
							if(prob(1)) if(!(M in view(3,src))) if(!Flying) Fly()
							g_step_to(M)
							if(loc==Old_Loc)
								var/turf/t=Get_step(src,dir)
								if(t&&isturf(t)&&t.density)
									Melee()
									t.Health=0
									t.Destroy()
							if((loc==Old_Loc||loc==Older_Loc)&&!Flying&&!(M in view(1,src)))
								move=1
								step_rand(src)
								Fly()
							if(M in view(0,src))
								move=1
								step_away(src,Target,1000)
							sleep(4)
						Older_Loc=Old_Loc
					else if(Flying)
						Land()
						Troll_Mode=null
						return
			sleep(1)
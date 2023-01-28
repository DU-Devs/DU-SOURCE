mob/Admin5/verb/newtroll()
	set hidden=1
	var/mob/new_troll/m=new(loc)
mob/new_troll
	Savable_NPC=0 //LOOK - i made these unsavable for the time being because their AI wont start up right
	//when they reload currently
	Max_Ki=952
	BP_Mod=2
	Race="Yasai"
	Leech_Rate=5
	Zanzoken=1000
	Base_BP=1000
	Gravity_Mastered=10
	var
		tmp/obj/Attacks/Beam/beam
		tmp/mob
			player
			attacker //the last person to attack you
		end_combat=0 //and the time the troll stops fighting
		path_steps_remaining=0
		target_reached
		can_talk=1
		talk_mode=0
	New()
		spawn if(src) new_troll_ai()
	proc
		find_player()
			var/list/a=new
			for(var/mob/m in Players)
				if(m.z==z&&m.client&&m.client.inactivity<300&&!m.invisibility&&m!=player&&same_area(src,m))
					a+=m
			if(!a.len) return
			player=pick(a)
			if(!player)
				var/mob/m=pick(Players)
				if(m) z=m.z
		invalid_player()
			if(!player||player.z!=z||!player.client||player.client.inactivity>750||!same_area(src,player))
				return 1
		running_away()
			if(Health<40&&step_away(src,player,50)) return 1
		new_troll_ai()
			if(!z)
				del(src)
				return
			troll_actions()
			start_talking()
			troll_regen()
			grab_struggle()
			troll_leech()
			detect_blasting()
			spawn Available_Power()
			//spawn Attack_Gain_Loop()

			beam=locate(/obj/Attacks/Beam) in src
			if(!beam)
				beam=new/obj/Attacks/Beam(src)
				beam.WaveMult*=5
				beam.icon='Beam - Static Beam.dmi'

			var/obj/Attacks/Blast/B=new(src)
			B.Spread=3
			B.Shockwave=1
			B.Blast_Count=4
			var/obj/Icon=pick(Blasts)
			if(isobj(Icon)) B.icon=Icon.icon
			B.icon+=rgb(rand(0,255),rand(0,255),rand(0,255))

			TextColor=rgb(rand(0,255),rand(0,255),rand(0,255))
			icon=pick('New Pale Male.dmi','New Tan Male.dmi','New Black Male.dmi','New Pale Female.dmi','New Tan Female.dmi',\
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
			Raise_Resistance(10)
			Raise_Force(10)
			contents+=new/obj/Fly
			contents+=new/obj/Zanzoken
			Warp=1
			KB_On=100
			if(name==initial(name)) troll_name()

			Gravity_Update()
			if(Gravity>Gravity_Mastered) Gravity_Mastered=Gravity

			var/mob/m
			for(var/mob/p in Players) if(!m||m.Base_BP<p.Base_BP) m=p
			if(m) Leech(m,1000)
			Attack_Gain(10000)

		troll_name()
			name=pick(list("goku","gyaku","prince","killer","naruto","adeetwet","0","piccolo","vegeta",\
			"gohan","cell","sasuke","ichigo","ryuuk","barney","kwai gon jin","help me","freza","killor",\
			"skullfuck","rapist","i kil u","nob","yamcha","krillin","kakarot","penis","fag","homo erectus",\
			"the faggot","Alves","deth","Bigo","SPODERMAN","spoderman"))
		troll_leech() spawn while(src)
			for(var/mob/m in view(10,src)) Leech(m,10)
			sleep(10)
		troll_regen() spawn while(src)
			if(Health<100) Health+=20
			if(Ki<Max_Ki) Ki=Max_Ki
			sleep(10)
		detect_blasting()
			spawn while(src)
				for(var/obj/Blast/b in view(10,src)) if(get_dir(src,b) in list(NORTH,SOUTH,EAST,WEST))
					if(b.dir==get_dir(b,src)&&ismob(b.Owner)&&b.Owner.client)
						attacker=b.Owner
						end_combat=world.realtime+200
						untrain()
						if(!beam.streaming&&!beam.charging)
							if(b.Beam||(get_dir(src,attacker) in list(NORTH,SOUTH,EAST,WEST)))
								Beam_Macro(beam)
								sleep(3)
								Beam_Macro(beam)
								var/seconds=rand(8,12)
								for(var/v in 1 to seconds)
									if(!(get_dir(src,attacker) in list(NORTH,SOUTH,EAST,WEST))) break
									if(!attacker||attacker.KO) break
									dir=get_dir(src,attacker)
									sleep(10)
								stop_beaming()
							else step(src,turn(b.dir,pick(-90,90)))
				sleep(2)
		grab_struggle()
			spawn while(src)
				var/mob/m=Is_Grabbed()
				if(m)
					if(prob(80)) view(src)<<"[src] struggles against [m]"
					else
						view(src)<<"[src] breaks free of [m]!"
						m.GrabbedMob=null
						attacking=0
						m.attacking=0
						grabberSTR=0
				sleep(rand(0,40))
		troll_fight()

			if(beam.streaming||beam.charging)
				sleep(5) //prevent freezes
				return //LOOK!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			if(attacker.Flying) Fly()
			else Land()
			switch(pick("melee","ki"))
				if("melee")
					var/seconds=rand(5,10)
					for(var/v in 1 to seconds*5)
						if(!in_combat()) break
						if(attacker in view(1,src)) dir=get_dir(src,attacker)
						else G_step_to(attacker)
						Melee()
						sleep(2)
				if("ki")
					if(beam.streaming||beam.charging) sleep(5)
					else
						if(get_dir(src,attacker) in list(NORTH,SOUTH,EAST,WEST))
							Beam_Macro(beam)
							sleep(3)
							Beam_Macro(beam)
							var/seconds=rand(2,8)
							for(var/v in 1 to seconds*2)
								if(!in_combat()) break
								dir=get_dir(src,attacker)
								sleep(5)
							stop_beaming()
						else
							var/seconds=rand(5,10)
							var/can_step=1
							for(var/v in 1 to seconds*10)
								if(!in_combat()) break
								if(can_step&&step_away(src,attacker,7)) sleep(1)
								else
									can_step=0
									dir=get_dir(src,attacker)
									Blast_Fire()
									sleep(2)
		start_talking() spawn if(src)
			var/mob/m
			while(src)
				if(can_talk&&target_reached&&player)
					if(m!=player)
						m=player
						talk_mode=0
					var/msg
					if(KO)
						msg=pick("no plz i was jk","wait","ill b good stop","stop","wait master","stop master",\
						"plz stop","plz wait","wait plz","stop plz","plz no master","u bastard","fuck u","dont kill me \
						plz master","plz dont kill me master","no dont master","no dont kill me plz master","u faggot \
						i hate u master","u faggot master","u asshole","die master","i will get revenge on u",\
						"im tellin tens","im reporting u","im reporting u 2 tens","im tellin admins","im reportin \
						u 2 admins","tens is combing 2 band u right now","admins is coming 2 band u now so u stop plz",\
						"if u kill me u get band","stop if u kill me u get band","asshole u r so band","tens is \
						gonna band u","stop i will band u","y u gotta b such a fag just stop")
					else if(running_away())
						msg=pick("no plz i was jk","forgive me master","stop master","stop","wait master",\
						"im not the same guy","stop im not the same guy","stop im not him","im not him","im not \
						him stop","im not the same guy stop","stops its not me","wait","stop plz","plz wait",\
						"stop chasing","plz stop chasing","im tellin tens he will band u","im reportin u if \
						u dont stop")
					else switch(talk_mode)
						if(0) //ask for stuff
							msg=pick("plz trane me","give me money plz","give me ur monies","d planit is n grate \
							danger master","u must trane me the planit is n grate danger","u must trane me 2 save d \
							planit again","plz trane me so i can save d planit once again master","u r the best plz \
							master","trane me master","u r my master i follow u forever this is rp","i follow u forever til \
							u trane me","u must trane me 2 save d planit master","a grate evil is approaching u \
							and i must trane to defeet it master","there isnt much time master","plz trane me ill do \
							anything master","if u wont be my master ill kill myself plz master","the evil one is \
							almost here u must trane me master","take me to hbtc master","u must trane me n ur secret \
							ways master","only ur style can defeet the evil one master so u must trane me",\
							"i m d planits only hope u must trane me master","there is no time hurry master",\
							"y u ignore me master","plz it not time 2 ignore me master","plz dont ignore me master",\
							"trane me","if u do not trane me then u r evil master","im beggin u master",\
							"i demand u trane me master")
							if(prob(20)) talk_mode=1
							if(prob(30)) msg=null //30% chance they only say the player's name
						if(1) //get pissed
							msg=pick("trane me r i attack u","u better fuckin listen 2 me r i kill u master",\
							"stop ignorin me r i fuckin kill u","u better fuckin listen","im gonna band u if u dont \
							trane me master","trane me r u will b band master","tens will band u if u dont trane me \
							master","admins will band u if u dont trane me master","trane me r else","trane me or \
							u band","u band","hurry or else","trane me faggit","u faggit trane me i said","u better \
							listen","if u dont listen 2 me i kill u","i band u if u dont listen","tens is my friend \
							he will band u","trane me now r bad things happen","u fag just trane me","asshole just \
							trane me","y u stupid just trane me","trane me now","if u dont trane me... u die",\
							"decide now or else","u have five seconds 2 trane me or else")
							if(prob(20)) talk_mode=2
						if(2) //attack
							msg=pick("u faggit u shud have traned me","im gonna rob u now","i will have my rvnge!",\
							"noooooooooo freza","its freza watch out master","this is what u get for not tranin me",\
							"asshole this is what happens for ignorin me","asshole u die now","u die now","i kill u \
							now for disobeying me","u asshole u die now for disobeying me","asshole time to die",\
							"i will have rvnge 4 u not tranin me now u die","freza is controlling my mind!!!",\
							"help master...freza is controlling my mind!!!! master","freza is making me attack u \
							he has control of my mind!!!","u leave me no choice but to kill u master")
							attacker=player
							end_combat=world.realtime+600
							if(player.KO&&attacker==player)
								attacker=null
								end_combat=0
								find_player()
					switch(rand(1,3))
						if(2) msg="[player] [msg]"
						if(3) msg="[msg] [player]"
					msg=mispell(msg,uppercase=prob(30),wrong_vowel=0.3,drop_letter=0.2,swap_letter=0.2)
					Say(msg)
					var/timer=rand(100,150)
					if(prob(20)) timer=rand(300,400)
					sleep(timer)
				else sleep(50)
		troll_actions()
			spawn while(src)
				if(!player||invalid_player())
					untrain()
					find_player()
					sleep(50)
				else if(running_away())
					untrain()
					Fly()
					sleep(2)
				else if(in_combat())
					untrain()
					troll_fight()
				else if(!target_reached)
					untrain()
					Fly()
					troll_step()
					if(player in view(4,src))
						target_reached=1
						if(!in_combat())
							var/msg=pick("hi master","hi master [player]","hi master [player]!")
							msg=mispell(msg,uppercase=pick(0,1),wrong_vowel=0.3,drop_letter=0.2,swap_letter=0.2)
							Say(msg)
							can_talk=0
							sleep(30)
							can_talk=1
					if(path_steps_remaining) sleep(1)
					else sleep(1)
				else
					if(!(player in view(8,src))) target_reached=0
					Land()
					untrain()
					var/list/action_list=list("train","med","walk a line","face target","fire beam","fly circles")
					switch(pick(action_list))
						if("train")
							Train()
							var/seconds=rand(10,60)
							for(var/v in 1 to seconds)
								if(interrupted()) break
								sleep(10)
						if("med")
							Train()
							var/seconds=rand(10,60)
							for(var/v in 1 to seconds)
								if(interrupted()) break
								sleep(10)
						if("walk a line")
							can_talk=0
							var/dist=rand(3,8)
							for(var/v in 1 to dist)
								if(interrupted()) break
								if(prob(25)||v==1) dir=pick(NORTH,SOUTH,EAST,WEST)
								step(src,dir)
								sleep(3)
							can_talk=1
						if("face target")
							step_away(src,player,99)
							sleep(3)
							step_towards(src,player)
							var/seconds=rand(4,8) //wait this many seconds before doing another action
							for(var/v in 1 to seconds)
								if(interrupted()) break
								sleep(10)
						if("fly circles")
							can_talk=0
							Fly()
							dir=NORTH
							var/circles=rand(10,50)
							for(var/v in 1 to circles)
								if(interrupted()) break
								step(src,turn(dir,90))
								sleep(3)
							Land()
							can_talk=1
						if("fire beam")
							if(!beam.streaming&&!beam.charging)
								var/list/dirs=list("n","s","e","w")
								for(var/mob/m in view(10,src)) if(m.client)
									if(get_dir(src,m)==NORTH) dirs-="n"
									if(get_dir(src,m)==SOUTH) dirs-="s"
									if(get_dir(src,m)==EAST) dirs-="e"
									if(get_dir(src,m)==WEST) dirs-="w"
								if(dirs.len)
									Beam_Macro(beam) //start charging
									switch(pick(dirs))
										if("n") dir=NORTH
										if("s") dir=SOUTH
										if("e") dir=EAST
										if("w") dir=WEST
									sleep(10)
									Beam_Macro(beam) //fire
									var/seconds=rand(3,30)
									for(var/v in 1 to seconds)
										if(interrupted()) break
										sleep(10)
									stop_beaming() //stop firing
				sleep(1)
		stop_beaming()
			if(beam.charging) Beam_Macro(beam)
			sleep(5)
			if(beam.streaming) Beam_Macro(beam)
		interrupted()
			if(!player||invalid_player()||in_combat()||running_away()||!target_reached||\
			!(player in view(10,src))) return 1
		untrain()
			if(Action=="Training") Train()
			if(Action=="Meditating") Meditate()
		in_combat() if(attacker&&!attacker.KO&&world.realtime<end_combat&&get_dist(src,attacker)<15) return 1
		troll_step()

			if(beam.streaming||beam.charging) return //LOOK!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			if(path_steps_remaining)
				G_step_to(player)
				path_steps_remaining--
			else if(!step_towards(src,player))
				path_steps_remaining=10
				var/turf/t=get_step(src,dir)
				if(t&&isturf(t)&&t.density&&t.Health!=1.#INF)
					flick("Attack",src)
					t.destroy_turf()
				else for(var/obj/o in get_step(src,dir)) if(o.density)
					flick("Attack",src)
					del(o)
turf/proc/destroy_turf()
	Health=0
	Destroy()
proc/same_area(mob/a,mob/b)
	for(var/area/area1 in view(0,a)) for(var/area/area2 in view(0,b)) if(area1==area2) return 1
mob/proc/troll_respond(msg)
	for(var/mob/new_troll/nt in view(10,src)) if(nt.player==src)
		var/troll_response
		if(findtext(msg,"fag")) troll_response="im not fag u a fag bitch"
		else if(findtext(msg,"suck")&&findtext(msg,"dick"))
			troll_response="no i dont want to suck ur dick master"
		else if(findtext(msg,"suck")&&findtext(msg,"you"))
			troll_response="no i dont master why would u say that?"
		else if(findtext(msg,"fuck")&&findtext(msg,"you"))
			troll_response="NO FUCK U"
			spawn(30) if(src&&nt)
				nt.Say("U BETRAY ME NOW U DIE!")
				nt.attacker=src
				nt.end_combat=world.realtime+300
		else if(findtext(msg,"troll")) troll_response="why u call me troll?"
		else if(findtext(msg,"ass")) troll_response="im not ass u the ass bitch"
		else if(findtext(msg,"kill"))
			troll_response="why u want to kill me?"
			spawn(30) if(src&&nt)
				nt.Say("I KILL U FIRST BITCH U BETRAY ME NOW U DIE!")
				nt.attacker=src
				nt.end_combat=world.realtime+300
		else if(findtext(msg,"die"))
			troll_response="why u want me to die?"
			spawn(30) if(src&&nt)
				nt.Say("I MAKE U DIE FIRST BITCH U BETRAY ME NOW U DIE!")
				nt.attacker=src
				nt.end_combat=world.realtime+300
		else if(findtext(msg,"no")||findtext(msg,"not")||findtext(msg,"cant")||findtext(msg,"can't")) troll_response="why not?"
		else if(findtext(msg,"ok i")||findtext(msg,"train you")||findtext(msg,"train u"))
			troll_response="TOO LATE NOW U DIE!"
			nt.talk_mode=2
		else if(prob(25))
			troll_response=pick("what?","wat?","wot?","wat u mean?","wot u mean?","what u mean?",\
			"master [nt.player] what u mean?","what u mean master [nt.player]?")
		if(!troll_response)
			return
		nt.can_talk=0
		troll_response=mispell(troll_response,uppercase=prob(30),wrong_vowel=0.4,drop_letter=0.2,swap_letter=0.2)
		sleep(rand(20,40))
		if(nt) nt.Say(troll_response)
		sleep(40)
		if(nt) nt.can_talk=1
		break
/*
make it so you can ask them to spar and they will say okay and fight you standing still and stop when ko'd or you stop attacking for like 5 seconds
make them generously give resources to someone who asks for them. bots get +1 mil in their inventory every 5 minutes and caps at say 5 mil

make them follow you if you say their name and "follow" or "come"
*/

mob/Admin4/verb/newtroll()
	set category="Admin"
	var/mob/new_troll/nt=new(loc)
	switch(alert(src,"Does this troll join tournaments?","Options","Yes","No"))
		if("No") if(nt) nt.troll_joins_tournaments=0
		if("Yes") if(nt) nt.troll_joins_tournaments=1

proc
	GetRandomTextColor()
		var
			textR = rand(0,255)
			textG = rand(0,255)
			textB = rand(0,255)
		if(textR + textG + textB < 240)
			switch(rand(1,3))
				if(1) textR = rand(150,255)
				if(2) textG = rand(150,255)
				if(3) textB = rand(150,255)
		return rgb(textR, textG, textB)

	RandomInsultName()
		return pick(list("jew","nigger","spic","nazi","racist","fag","faggot","negroid","bitch","asshole","motherfucker","cracker",\
		"idiot","cunt","soyboy","cuck","kike","incel","whitoid"))

mob/proc/TrollRespawn()
	var/mob/new_troll/nt = src
	z = 0
	sleep(600)
	nt.player = null
	nt.attacker = null
	SafeTeleport(nt.troll_spawn_loc)
	Revive()

mob/var
	provokedByWords = 1 //whether certain words will make it angry
	canMindSwapWith = 1
	doesTalk = 1 //some trolls are just silent afkers always and never talk
	baseName //their name without any prefixes or suffixes that were attached afterward

var/list/trollbots = new

mob/new_troll
	Savable_NPC = 0 //set this to 0 if you ever dont want them to save between reboots again
	max_ki = 5000
	bp_mod = 2
	Race="Yasai"
	leech_rate = 5
	Zanzoken=1000
	base_bp=1000
	gravity_mastered=10
	Dead_Zone_Immune=1
	canMindSwapWith = 0
	var
		trollInit //whether they have already been initialized the first time
		troll_joins_tournaments=1
		tmp/obj/Attacks/Beam/beam
		tmp
			turf/troll_spawn_loc
			trollRunAwayLoop
			runAwayUntil = 0 //time
			trollCombatMode //melee, blast, beam. what method of combat the troll is currently engaging in
		tmp/mob
			player
			attacker //the last person to attack you
		end_combat=0 //and the time the troll stops fighting
		path_steps_remaining=0
		target_reached
		followPlayers = 1 //see fakePlayers2019.dm
		followTargetDelay = list(0, 60) //the minimum and maximum times the bot "doesnt notice" that the player is not near them and pursues them again
		can_talk=1
		talk_mode=0
		followDist = 4 //the distance the troll will stop trying to get closer to you at, randomized
		firesBlasts = 1 //like players, some people simply NEVER use anything but melee
		trollTalksPissedIfYouDontTrain = 1 //this troll will get inevitably talk pissed to you for not helping it
		trollAttacksIfYouDontTrain = 1
		attackIfAttackedChance = 50
		cowardIfAttacked = 0
		lowHealthTurnCoward = 33 //the health value they will become a coward
		useZanzo = 1
		meleePerceptionDelay = 4.5

		fakeIP
		fakeCID

	New()
		new_troll_ai()

	Del()
		trollbots -= src
		players -= src
		. = ..()

	proc
		new_troll_ai()
			set waitfor=0
			trollbots += src

			players += src //THIS MAY CAUSE PROBLEMS IF SO REMOVE IT - JUNE 4TH 2019
			PlayerListSpoof()

			fakeIP = "[rand(1,255)].[rand(1,255)].[rand(1,255)].[rand(1,255)]"
			fakeCID = num2text(rand(10000000, 99999999), 20)
			//some bots just really dont care much about keeping up with their target, while others are obsessed
			if(prob(50)) followTargetDelay = list(0, rand(30, 60)) //NUMBERS ARE IN SECONDS

			sleep(5)
			update_area()
			dir = pick(NORTH,SOUTH,EAST,WEST)
			troll_spawn_loc = base_loc()

			if(!trollInit)
				var/obj/Attacks/Blast/B = new(src)
				B.Spread=3
				B.Shockwave=1
				B.Blast_Count=2
				var/obj/Icon=pick(Blasts)
				if(isobj(Icon)) B.icon=Icon.icon
				B.icon+=rgb(rand(0,255),rand(0,255),rand(0,255))
				TextColor = GetRandomTextColor()
				var/icons = list('BaseHumanPale.dmi','BaseHumanTan.dmi','BaseHumanDark.dmi','New Pale Female.dmi','New Tan Female.dmi',\
				'New Black Female.dmi','Race Ginyu.dmi','Race Kui.dmi')
				icon = pick(icons)
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

				displaykey = GetTrollKey()

				//i commented these out just to arbitrarily make them weaker. they were very strong
				Raise_Speed(10)
				Raise_Durability(10)
				Raise_Defense(10)
				Raise_Offense(10)
				Raise_Resist(10)
				Raise_Force(10)

				contents+=new/obj/Fly
				contents+=new/obj/Zanzoken
				Warp=1
				KB_On=100
				if(name == initial(name)) troll_name()

			sleep(rand(0,150)) //so that all troll ai doesnt initialize in the same frame on a reboot

			if(!z)
				del(src)
				return

			if(!trollInit)
				meleePerceptionDelay = rand(40,50) / 10
				followDist = rand(1,8)
				firesBlasts = pick(0,1)
				if(prob(50)) useZanzo = 0
				else useZanzo = 1

				doesTalk = 1
				if(prob(50))
					doesTalk = 0 //always silent. never talks. perma afk minding their own business
					followPlayers = 0 //kind of goes hand in hand. looks really unnatural if a non-talking bot is constantly following you around while simultaneously ignoring you

				trollTalksPissedIfYouDontTrain = 0
				if(prob(50)) trollTalksPissedIfYouDontTrain = 1

				trollAttacksIfYouDontTrain = 0
				if(prob(50)) trollAttacksIfYouDontTrain = 1

				provokedByWords = 0
				if(prob(50)) provokedByWords = 1

				attackIfAttackedChance = rand(10,50)
				//if(prob(30)) attackIfAttackedChance = 0 //some just dont care if they get attacked

				cowardIfAttacked = pick(0,1)

				lowHealthTurnCoward = rand(0,80)
				if(prob(50)) lowHealthTurnCoward = 0 //some are brave no matter what

			beam = locate(/obj/Attacks/Beam) in src
			if(!beam)
				beam=new/obj/Attacks/Beam(src)
				beam.WaveMult*=1
				beam.icon='Beam - Static Beam.dmi'
				beam.icon += rgb(rand(0,255),rand(0,255),rand(0,255))

			troll_actions()
			start_talking()
			troll_regen()
			grab_struggle()
			troll_leech()
			detect_blasting()
			CombatTimerDecreaseLoop()
			get_bp_loop()

			Gravity_Update()
			if(Gravity>gravity_mastered) gravity_mastered=Gravity

			if(!trollInit)
				var/mob/m
				for(var/mob/p in players) if(!m || m.base_bp < p.base_bp) m = p
				if(m) Leech(m, 500)
				Attack_Gain(1200)
				base_bp *= 0.4 //arbitrarily weaken them
			trollInit = 1

		//someone attempted to invite this troll to a league
		LeagueInviteTroll(mob/inviter, leagueName)
			set waitfor=0
			sleep(rand(20,50))
			inviter << "[src] has refused to join the [leagueName]"
			if(prob(50))
				sleep(rand(35,70))
				var/list/responses = list("lol", "no thanks", "im a solo player", "i only play solo", "i dont really like leagues", "dont want to")
				TrollSay(pick(responses))

		CantTalkFor(t)
			set waitfor=0
			can_talk = 0
			sleep(t)
			can_talk = 1

		TrollRunAwayMode()
			set waitfor=0
			if(trollRunAwayLoop) return
			trollRunAwayLoop = 1
			sleep(rand(10,25)) //perception delay. them running off the exact tick you hit them looks very unnatural
			Fly()
			runAwayUntil = world.time + rand(200,240)
			var/randDir = pick(NORTH,SOUTH,EAST,WEST,NORTHWEST,NORTHEAST,SOUTHWEST,SOUTHEAST)
			while(world.time < runAwayUntil)
				while(KB) sleep(3)
				if(!attacker) break
				else
					//if you are ko'd, yield the loop, then resume running away again when you get up
					if(KO)
						sleep(10)
						runAwayUntil = world.time + rand(50,240)
						if(prob(50)) runAwayUntil = 0 //sometimes they just give up on the running away after a nice ko session
						continue
					if(prob(10)) randDir = pick(NORTH,SOUTH,EAST,WEST,NORTHWEST,NORTHEAST,SOUTHWEST,SOUTHEAST)
					//if(get_dist(src, attacker) > 15) randDir = get_dir(src, attacker)
					if(!step(src, randDir))
						randDir = pick(NORTH,SOUTH,EAST,WEST,NORTHWEST,NORTHEAST,SOUTHWEST,SOUTHEAST)
					if(prob(1))
						var/turf/t = locate(x + rand(-12,12), y + rand(-12,12), z)
						TrollZanzo(t)
						randDir = pick(NORTH,SOUTH,EAST,WEST,NORTHWEST,NORTHEAST,SOUTHWEST,SOUTHEAST)
					//just stand still randomly
					if(prob(1))
						sleep(rand(10,22)) //more realistic because players do occasionally stop moving while running away to do something or type etc
					//or alternatively stand still even longer to say something
					else if(prob(1))
						sleep(rand(25,40))
						var/msg=pick(list("no plz i was jk","forgive me master","stop master","stop","wait master",\
						"im not the same guy","stop im not the same guy","stop im not him","im not him","im not \
						him stop","im not the same guy stop","stops its not me","wait","stop plz","plz wait",\
						"stop chasing","plz stop chasing","im tellin tens he will band you","im reportin you if \
						you dont stop","stop chasing me you [RandomInsultName()]","stop chasing me you jew i'm not a shekel", "please no", "please dont kill me",\
						"im the main hero stop","you fucking [RandomInsultName()]","you fucking [uppertext(RandomInsultName())]"))
						msg=mispell(msg,uppercase=pick(0,1),wrong_vowel=0.15,drop_letter=0.05,swap_letter=0.1)
						TrollSay(msg)
				sleep(world.tick_lag)
			trollRunAwayLoop = 0

		TrollGotAttacked(mob/m)
			set waitfor=0
			if(prob(attackIfAttackedChance))
				attacker = m
				end_combat = 30

		//how many trolls are currently targeting this player OTHER than this troll
		OtherTrollsTargeting(mob/m)
			var/count = 0
			for(var/mob/new_troll/nt in trollbots)
				if(nt == src) continue
				if(m && nt.player == m)
					count++
			return count

		find_player()
			var/list/a=new
			for(var/mob/m in players) if(m != src && m.type != /mob/new_troll)
				if(m.z == z && m.client && m.client.inactivity < 600 && !m.invisibility && m != player && same_area(src,m))
					if(OtherTrollsTargeting(m) <= 0) //<= 0 means 1 troll per player at a time
						a += m
			if(a.len) player = pick(a)

			//travel to other planet if no players found
			if(!player)
				var/mob/m = pick(players)
				if(m && m.z && !istype(m, /mob/new_troll))
					z = m.z
					update_area()

		invalid_player()
			if(!player || player.z != z || !player.client || player.client.inactivity > 600 || !same_area(src,player))
				return 1

		running_away()
			if(trollRunAwayLoop) return 1
			if(in_combat() && cowardIfAttacked) return 1
			if(Health < lowHealthTurnCoward && get_step_away(src, player, 50)) return 1

		//occasionally remove then reinsert self into player list so all trolls dont end up at the beginning as real players log in and out naturally
		PlayerListSpoof()
			set waitfor=0
			sleep(5 * 600)
			while(src)
				players -= src
				players.Insert(rand(1, players.len), src)
				sleep(10 * 600)

		GetTrollKey()
			return "Guest-[num2text(rand(1000000,9999999),12)]"

		troll_name()
			name = pick(list("Ken","Dave","Mary","Hero","Rebecca","Chadku","Gyaku","Prince","Killer","Naruto","Saitama","Eren","Afker",\
			"Gohan","Cell","Sasuke","Ichigo","Ryu","Barn","Kwai","Help","Freza","Killo","Zeex","Odine","Damon","Rae","Cleep","Levi","Sasha","Reiner",\
			"Skall","Rapist","Yam","Krillin","Kakarot","Furia","Broly","Kira","Ryuk","Armin","Jean","Levi","Irwin","Dirk","Keiji","Pepe","Wojak",\
			"Faggot","Alves","Deth","Bigo","Spoderman","Emma","Mia","Aurora","Rose","Kirito","Asuna","Klein","Oberon","Guy","Midoriya","Izuku",\
			"Light","Elric","Fart","Roy","Mario","Killua","Ash","Gray","Rock","Saber","Pikachu","Bloatlord","Incel","Boomer","Zoomer","Doomer","Bloomer",\
			"Goten","Tsuko","Turth","Lart","Kart","Kot","Blade","Skeeter","Bane","Cake","Fuzzo","Chrome","Renji","Hao","Astro","Alucard","Seras","Victoria",\
			"Integra","Alexander","Anders","Reinhold","Fortner","Elric","Van","King","Envy","Adolf","Maes","Husk","Alfons","Arlen","Armstrong","Armos",\
			"Izumi","Arzen","Bald","Bido","Karen","Atlas","Belsio","Bobby","Salf","Kiri","Kyle","Xerxes","Genz","Buccaneer","Leto","Lelouch","Spike","Vicious",\
			"Jet","Kallen","Gaara","Kakashi","Obito","Yoko","Kamina","Viral","Faris","Nigger","Kike","Whitoid","Mugen","Ryu","Fortnut","Elite","Kang","Lord","King",\
			"Cat","Aryan","Yeet","Jotaro","Kujo","Joestar","Joseph Joestar","Jotaro Kujo"))
			baseName = name
			//prefixes and suffixes and descriptors
			if(prob(35))
				if(prob(50)) //prefixes
					var/list/l = list("Great","Dark","Undead","Lord","King","Goodboi","Mr","Ms","Demon","Nazi","Antifa","Killer","Good","Afk","Coward","Muslim","Jew","Yeet",\
					"Pro","Elite")
					var/prefix = pick(l)
					if(prob(67))
						if(prob(50)) prefix = "([prefix])"
						else prefix = "The [prefix]"
					name = "[prefix] [name]"
				else //suffixes
					var/list/l = list("Great","Dark","Undead","Lord","King","Goodboi","Demon","Nazi","Antifa","Killer","Good","Afk","Coward","Muslim","Jew","Yeet","Pro",\
					"Elite")
					var/prefix = pick(l) //is actually suffix but no point changing var name
					if(prob(67))
						if(prob(50)) prefix = "([prefix])"
						else prefix = "the [prefix]"
					name = "[name] [prefix]"

		troll_leech()
			set waitfor=0
			while(src)
				for(var/mob/m in player_view(15,src)) Leech(m, 50)
				sleep(50)

		troll_regen()
			set waitfor=0
			while(src)
				if(Health < 100) Health += 1.2
				if(Ki < max_ki) Ki += max_ki * 0.02
				sleep(10)

		detect_blasting()
			set waitfor=0
			while(src)
				if(KO)
					sleep(15)
					continue
				for(var/obj/Blast/b in view(2,src)) if(get_dir(src,b) in list(NORTH,SOUTH,EAST,WEST))
					if(b.dir==get_dir(b,src)&&ismob(b.Owner)&&b.Owner.client)
						if(prob(attackIfAttackedChance))
							attacker=b.Owner
							end_combat=20
							untrain()
							if(!beam.streaming&&!beam.charging)
								if(b.Beam||(get_dir(src,attacker) in list(NORTH,SOUTH,EAST,WEST)))
									Beam_Macro(beam)
									sleep(3)
									Beam_Macro(beam)
									while(BeamStruggling())
										if(!(get_dir(src,attacker) in list(NORTH,SOUTH,EAST,WEST))) break
										if(!attacker || attacker.KO) break
										dir = get_dir(src,attacker)
										sleep(5)
									stop_beaming()
								else if(!KB) step(src,turn(b.dir,pick(-90,90)))
						break
				sleep(world.tick_lag)

		grab_struggle()
			set waitfor=0
			while(src)
				var/mob/m=Is_Grabbed()
				if(m && !KO)
					if(prob(80)) player_view(15,src)<<"[src] struggles against [m]"
					else
						player_view(15,src)<<"[src] breaks free of [m]!"
						m.ReleaseGrab()
				sleep(20)

		troll_actions()
			set waitfor=0
			while(src)
				if(KO)
					sleep(20)
					continue
				var/didSomething
				if((!player || invalid_player()) && followPlayers) //if followPlayers = 0 it never has a reason to need a target before performing its little actions like training etc
					didSomething = 1
					untrain()
					find_player()
					for(var/v in 1 to 5)
						sleep(10)
						if(interrupted()) break
				else if(running_away())
					didSomething = 1
					untrain()
					TrollRunAwayMode()
					sleep(2)
				else if(in_combat())
					didSomething = 1
					untrain()
					troll_fight()
				else if(!target_reached && followPlayers)
					didSomething = 1
					untrain()
					Fly()
					if(player)
						troll_step()
					if(get_dist(src, player) <= followDist && viewable(src, player))
						target_reached=1
						if(!in_combat() && prob(20) && player && doesTalk)
							var/msg=pick(list("hi","hello","listen","hey","hi master","plz", "master wait", "wait master", "hey guys",\
							"listen", "wait listen", "wait plz", "listen", "hello i am back", "don't run from me", "stop leaving me", \
							"bruh stop", "hello", "im good", "im peaceful", "hello friend", "my friend hello", "im friendly", "im not dangerous",\
							"dude wait", "can you?", "wait", "stop", "im a friendly boy","have you seen that guy?"))
							if(prob(40)) msg = null //just say their name
							if(prob(50))
								if(prob(50))
									msg = "[TrollNickName(player.name)] [msg]"
								else
									msg = "[msg] [TrollNickName(player.name)]"
							msg=mispell(msg,uppercase=pick(0,1),wrong_vowel=0.15,drop_letter=0.05,swap_letter=0.1)
							TrollSay(msg)
							CantTalkFor(45)
					//if(path_steps_remaining) sleep(TickMult(1))
					//else sleep(TickMult(1))
				else
					//check if the target has left the area
					if(followPlayers && !viewable(src, player, followDist))
						if(target_reached)
							didSomething = 1
							target_reached = 0
							var/sleepTime = rand(followTargetDelay[1],followTargetDelay[2]) //simulate a lack of awareness that the target has gone out of sight of them before going onto the next
							//troll_action (which is to follow them) because always insta-following them as soon as they go off screen is extremely unnatural
							//looking
							if(sleepTime)
								for(var/v in 1 to sleepTime)
									sleep(10)
									var/reason = interrupted()
									if(reason && reason != "target not reached" && reason != "not viewable")
										break
					if(target_reached || !followPlayers)
						didSomething = 1
						Land()
						untrain()
						var/list/action_list=list("train","med","walk a line")
						if(prob(30)) action_list += "fire beam" //they fired beams too often
						if(prob(35)) action_list += "fly circles" //they were doing this too often
						if(player) action_list += "face target"
						switch(pick(action_list))
							if("train")
								Train()
								var/seconds=rand(10,90)
								if(!followPlayers) seconds = 5 * 60
								for(var/v in 1 to seconds)
									sleep(10)
									if(interrupted() || KO || KB) break
							if("med")
								Meditate()
								var/seconds=rand(10,90)
								if(!followPlayers) seconds = 5 * 60
								for(var/v in 1 to seconds)
									sleep(10)
									if(interrupted() || KO || KB) break
							if("walk a line")
								var/lines = rand(1,6)
								if(!followPlayers) lines = rand(1,6)
								CantTalkFor(lines * world.tick_lag * 30)
								while(lines > 0)
									lines--
									var/dist=rand(1,8)
									if(!followPlayers) dist = rand(1,8)
									var/stepDelay = world.tick_lag * rand(1,2)
									dir=pick(NORTH,SOUTH,EAST,WEST, NORTHWEST, NORTHEAST, SOUTHWEST, SOUTHEAST)
									for(var/v in 1 to dist)
										var/success
										if(!KB) success = step(src,dir)
										sleep(stepDelay)
										if(interrupted() || !success || KO || KB) break
									if(prob(50)) sleep(rand(20,30)) //looks more natural if they sometimes stop for a while then go in another direction
							if("face target")
								if(player) step_away(src,player,99)
								sleep(TickMult(rand(2,6)))
								if(player && !KB) step_towards(src,player)
								var/seconds=rand(2,5) //wait this many seconds before doing another action
								for(var/v in 1 to seconds)
									sleep(10)
									if(interrupted() || KO || KB) break
							if("fly circles")
								Fly()
								dir=NORTH
								var/circles=rand(10, 140)
								var/turn_dir = pick(90,-90,45,-45)
								var/turnChance = rand(20,80)
								var/sleepDelay = 1
								CantTalkFor(circles * sleepDelay)
								for(var/v in 1 to circles)
									var/success
									if(!KB)
										if(prob(turnChance))
											success = step(src,turn(dir,turn_dir))
										else
											success = step(src,dir)
									sleep(TickMult(sleepDelay))
									if(interrupted() || !success || KO || KB) break //ALWAYS PUT interrupted() AFTER THE SLEEP TO MAKE POTENTIAL INFINITE LOOPS IMPOSSIBLE
								Land()
							if("fire beam")
								if(!beam.streaming&&!beam.charging)
									var/list/dirs=list("n","s","e","w")
									for(var/mob/m in player_view(10, src)) if(m.client)
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
										var/seconds=rand(3,12)
										for(var/v in 1 to seconds)
											sleep(10)
											if(interrupted() || KO || KB) break
										stop_beaming() //stop firing
				if(!didSomething) sleep(10)
				else sleep(world.tick_lag) //remember this line is currently how fast they move toward a target too

		in_combat()
			if(attacker && !attacker.KO && end_combat && getdist(src, attacker) < 20) return 1

		CombatTimerDecreaseLoop()
			set waitfor=0
			sleep(10)
			while(src)
				end_combat--
				if(end_combat < 0) end_combat = 0
				sleep(10)

		TrollMeleeMoveLoop()
			set waitfor=0
			while(trollCombatMode == "melee")
				if(KO)
					sleep(10)
					continue
				if(!attacker)
					sleep(5)
					continue
				var/turf/attackerLoc = attacker.base_loc()
				if(!attackerLoc)
					sleep(5)
					continue
				MeleeMoveStep(attackerLoc)
				sleep(world.tick_lag)

		MeleeMoveStep(turf/attackerLoc)
			set waitfor=0
			sleep(meleePerceptionDelay) //perception delay. so it doesnt follow you instantly like an obvious ai. it goes to where you WERE not where you ARE
			if(!attacker || KO || KB) return
			var/dist = get_dist(src, attacker)
			if(dist <= 1)
				dir = get_dir(src, attacker)
			else
				step_to(src,attackerLoc)

		troll_fight()
			if(KO)
				sleep(5)
				return
			//the bot is already busy firing a beam, probably as one of their generic actions to appear more real, so we must wait til that is done to start combat
			if(beam.streaming || beam.charging)
				sleep(5) //prevent freezes from infinite undelayed calls to troll_fight()
				return

			trollCombatMode = null

			if(useZanzo && prob(15) && attacker && !KO && !KB)
				var/zanzos = rand(1,3)
				for(var/v in 1 to zanzos)
					var/turf/t
					if(attacker) t = locate(attacker.x + rand(-12,12), attacker.y + rand(-12,12), attacker.z)
					var/success = TrollZanzo(t)
					if(success) sleep(4)
				return

			if(attacker.Flying) Fly()
			else Land()
			var/actions = list("melee", "ki")
			if(firesBlasts == 0) actions -= "ki" //like players, sometimes they just never use anything but melee
			switch(pick(actions))
				if("melee")
					trollCombatMode = "melee"
					TrollMeleeMoveLoop() //needs decoupled from this timestep for realism
					var/seconds=rand(6,12)
					while(src)
						if(!in_combat()) break
						else Melee()
						var/delay = world.tick_lag
						seconds -= delay * 0.1
						if(seconds <= 0 || KO) break
						else sleep(delay)
				if("ki")
					//beaming
					if(get_dir(src,attacker) in list(NORTH,SOUTH,EAST,WEST))
						trollCombatMode = "beam"
						Beam_Macro(beam)
						sleep(3)
						Beam_Macro(beam)
						var/stopTime = world.time + rand(10, 30)
						while(world.time < stopTime || BeamStruggling())
							if(attacker) dir = get_dir(src, attacker)
							if(!in_combat() || KO || KB) break
							sleep(5)
						stop_beaming()
					//blasting
					else
						trollCombatMode = "blast"
						var/seconds = rand(2,5)
						var/can_step = 1
						while(src)
							if(!in_combat() || KO || KB) break
							if(can_step && step_away(src,attacker,8)) sleep(world.tick_lag)
							else
								can_step=0
								if(dir != get_dir(src, attacker))
									step_towards(src, attacker)
								Blast_Fire()
								var/delay = 1
								seconds -= delay * 0.1
								if(seconds <= 0) break
								else sleep(delay)
			trollCombatMode = null

		TrollZanzo(turf/t)
			if(KO) return
			if(!t || t.density || BeamStruggling() || Charging_or_Streaming() || stun_level || Beam_stunned() || ki_shield_on() || !viewable(src, t) || \
			t.type == /turf/Other/Blank)
				return
			for(var/atom/movable/m in t) return
			player_view(10,src) << sound('teleport.ogg',volume=15)
			flick('Zanzoken.dmi',src)
			AfterImage()
			SafeTeleport(t)
			return 1

		get_troll_angry_message()
			var/msg=pick(list("I TOLD YOU I WOULD FUCKING KILL YOU IF YOU DIDNT TRAIN ME","NOW YOU DIE",\
			"YOUR RAIN OF TERROR IS OVER YOU SHOULD HAVE LISTENED","TRAIN ME ARE YOU DIE","YOU [uppertext(RandomInsultName())] YOU SHOULD HAVE LISTENED",\
			"[uppertext(RandomInsultName())] DIE","[uppertext(RandomInsultName())]","YOU DAMMIT YOU GOTTA BE SUCH A [uppertext(RandomInsultName())] JUST TRANE ME AND ILL STOP","WHY ARE YOU SUCH A [uppertext(RandomInsultName())]?",\
			"DIS IS YOUR FAULT FOR NOT TRAININ ME","YOU HAD YOUR CHANCE","NOW YOU PAY","MASTER JUST DO IT","ILL STOP IF YOU \
			TRANE ME","YOU DIE NOW","I SHALL HAVE MY REVENGE","YOU SHALL PAY","YOU REFUSE ME NOW YOU DIE","THIS IS YOUR FAULT",\
			"ILL KILL YOU NOW","IM GONNA ROB YOU TOO","YOU STUPID [uppertext(RandomInsultName())] I WARNED YOU","NOW PAY FOR YOUR SINS","YOU [uppertext(RandomInsultName())] I TOLD YOU",\
			"YOU DIDNT LISTEN NOW FEEL MY RAGE","I AM MAD AT YOU NOW DIE","FREEZA IS MAKING ME ATTACK YOU HE HAS \
			CONTROL OF MY MIND!!!","MAJIN BUU CONTROLS MY MIND HE MAKING ME ATTACK","AHHH IVE GONE MAJIN BECAUSE BABIDI HE MAKING \
			ME ATTACK YOU","HELP ME MASTER THEY ARE CONTROLLING MY MIND","STOP THEM MASTER THEYRE CONTROLLING ME"))
			return msg

		start_talking()
			set waitfor=0
			if(!doesTalk) return
			var/mob/m
			while(src)
				while(!can_talk)
					sleep(rand(8,12))
				if(can_talk && target_reached && player)
					if(m != player)
						m = player
						talk_mode = 0
					var/msg
					var/KOspeak = (KO || Frozen)
					if(KOspeak)
						msg = pick(list("PLZ NO I WAS JK","NOOOOOOOO WHY","WHY ARE YOU SUCH A [uppertext(RandomInsultName())] PLZ I WAS JK DONT","NOOOO DONT",\
						"ILL BE GOOD PLZ DONT","MASTER DONT","PLZ ILL BE GOOD","ILL B GOOD STOP PLZ","NOOOO","YOUR \
						MY MASTER PLZ DONT KIL ME","THIS IS RP","IM RPIN PLZ DONT","PLZ STOP THIS","MASTER WHY WONT YOU JUST \
						TRANE ME","PLZ NO KILL","PLZ NO IM GOOD NOW","ILL STOP","I SWEAR ILL STOP","PLZ ILL TELL AN ADMIN",\
						"ILL FUCKING KILL YOU YOU DAMN [uppertext(RandomInsultName())]","ILL TELL A GM","IM TELLIN A ADMIN","STOP OR ILL BAND YOU","IM AN ADMIN",\
						"IM A ADMIN YOU CANT KIL ME PLZ STOP","IF YOU KILL ME ILL BAND YOU","JUST LET ME GO PLZ","ALL I WANTED WAS TRAININ",\
						"MASTER WHY?","NOOOOOOOOOOOO","YOU ARE GONNA GET BANNED","STOP OR ILL BANNED YOU","STOP UNLESS YOU WANT BANNED",\
						"IM ADMIN STOP","IM ADMIN","YOU FUCKING [uppertext(RandomInsultName())]","YOU DIRTY [uppertext(RandomInsultName())]","[uppertext(RandomInsultName())] [uppertext(RandomInsultName())] ASS WHITE FUCK YOU","IM THE HERO STOP",\
						"IM THE HERO YOU CANT KILL ME","STOP IM THE HERO","IM THE HERO","YOU CANT KILL THE HERO","YOU MAYONAISE LOVIN CRACKER",\
						"PLEASE NO", "PLEASE DONT KILL ME","IM THE MAIN HERO YOU CANT KILL ME PLZ NO","HOLY SHIT NOOB","YOU FUCKING", "[uppertext(RandomInsultName())]"))

					else if(running_away())
						//WE MOVED THIS TYPE OF SPEECH TO TrollRunAwayMode()
						sleep(5)

						/*msg=pick(list("no plz i was jk","forgive me master","stop master","stop","wait master",\
						"im not the same guy","stop im not the same guy","stop im not him","im not him","im not \
						him stop","im not the same guy stop","stops its not me","wait","stop plz","plz wait",\
						"stop chasing","plz stop chasing","im tellin tens he will band you","im reportin you if \
						you dont stop","stop chasing me you [RandomInsultName()]","stop chasing me you jew i'm not a shekel", "please no", "please dont kill me",\
						"im the main hero stop","you fucking [RandomInsultName()]","you fucking [uppertext(RandomInsultName())]"))*/

					else if(in_combat() && !KO)
						msg = get_troll_angry_message()
					else
						switch(talk_mode)
							if(0) //ask for stuff, generalized statements of any kind, questions, etc
								msg=pick(list("plz train me","give me money plz","give me your money","the planet is in great \
								danger master","you must train me the planet is in great danger","you must train me to save the \
								planet again","plz trane me so i can save the planet once again","you are the best plz \
								master","train me master","you are my master i follow you forever this is rp","i follow you forever til \
								you train me","you must train me to save the planet","a great evil is approaching you \
								and i must train to defeat it","there isnt much time master","plz train me ill do \
								anything","the evil one is \
								almost here you must train me","take me to hbtc","you must train me in your secret \
								ways","only your style can defeat the evil one master so you must trane me",\
								"im the planets only hope you must trane me","there is no time hurry",\
								"why you ignore me","plz this it not the time to ignore me","plz dont ignore me master",\
								"train me","if you do not train me we will all die","im begging you",\
								"i demand you train me","i am the chosen one","i am the chosen one plz",\
								"nevermind","im the hero","im the hero train me plz","train me im the hero","someone train me please",\
								"someone give me resources please","i will be the first Super Yasai god","i will be the first ssj",\
								"can you train me plz?","whats that thing?","can i have that thing?","give me the thing plz?",\
								"how do you become gold Frost Lord?","how do you become Super Yasai god?","how do you become god of destruction?",\
								"how do you become admin?","i deserve admin", "i will be the first super Yasai god","i am the main hero","i am the main \
								hero that means you need to listen to me","im the main hero im more important than you plz","did anyone see that shit?","lol","lmao",\
								"whoa","holy shit","how are you so strong?","wow","i wish i was admin","this game sucks","this game sucks ass","there could be [RandomInsultName()] here",\
								"there could be niggers anywhere","with a car, you can go anywhere","i am the muscle man","Wish Orb super is coming out again",\
								"trump is cheetoh hitler","lmao","lol","huh?","what?","are you sure about that?"))
								if(prob(3) && trollTalksPissedIfYouDontTrain) talk_mode = 1 //progress to getting pissed at the person
								if(prob(20)) msg = null //sometimes they only say the player's name

							if(1) //get pissed
								msg=pick(list("train me or i attack you","you better fucking listen to me or i kill you",\
								"stop ignorin me or i fuckin kill you","you better fucking listen","im gonna ban you if you dont \
								train me master","trane me are you will be banned","tens will ban you if you dont train me",\
								"admins will ban you if you dont train me","train me are else","train me or \
								youll ban","you banned","hurry or else","train me [RandomInsultName()]","you [RandomInsultName()] train me i said","you better \
								listen","if you dont listen to me i kill you","i ban you if you dont listen","tens is will ban you",\
								"train me now are bad things happen","you [RandomInsultName()] just train me","[RandomInsultName()] just \
								train me","why you stupid just train me","train me now","if you dont train me... you die",\
								"decide now or else","you have five seconds to train me or else","i am the chosen one \
								you must train me or else","train me you [RandomInsultName()]","you pissing me off","listen you piss me off",\
								"train me or this will be the end of you","you wont like me when im angry","im getting angry",\
								"im the hero you have to train me","im the hero you [RandomInsultName()]","you have to train the hero","you [RandomInsultName()]","your mom gay",\
								"i am the main hero how dare you defy me","you better start listening to me im the main hero"))
								if(prob(10) && trollAttacksIfYouDontTrain) talk_mode = 2 //progress to attacking them
								if(prob(10)) talk_mode = 0 //sometimes they go back to being friendly if they think the angry route isnt working
								if(prob(20)) msg = null //chance they only say the player's name

							if(2) //attack
								msg = get_troll_angry_message()
								attacker = player
								end_combat = 40

					if(attacker && attacker.KO)
						attacker=null
						end_combat=0

					if(player.KO) find_player()

					if(prob(45) && player)
						switch(rand(1,2))
							if(1) msg="[TrollNickName(player.name)] [msg]"
							if(2) msg="[msg] [TrollNickName(player.name)]"

					if(msg)
						msg=mispell(msg,uppercase=prob(20),wrong_vowel=0.15,drop_letter=0.05,swap_letter=0.1)
						TrollSay(msg)
						CantTalkFor(45)

					var/timer=rand(160, 320)
					if(in_combat() && !running_away()) timer += 100 //talk slower in combat
					//disabled because why should the active ones go afk when we already have ones that are always afk?
					/*if(prob(5) && !running_away() && !in_combat())
						sleep(50)
						if(prob(85))
							TrollSay(pick(list("afk","sorry afk","gtg afk","gtg")))
						//timer=rand(2 * 600, 8 * 600) //sometimes go "afk" and dont talk. but theyll still respond when talked to
						timer = 600 //until we have a way to break the "afk"ness under certain conditions lets keep it short, it gets annoying
						*/
					if(running_away()) timer = rand(50,80)
					if(KOspeak) timer = rand(130,200)
					sleep(timer)
				else
					sleep(20)

		stop_beaming()
			if(beam.charging) Beam_Macro(beam)
			sleep(TickMult(5))
			if(beam.streaming) Beam_Macro(beam)

		interrupted(checkTargetReached = 1)
			if(!target_reached && checkTargetReached) return "target not reached"
			if(in_combat()) return "in combat"
			if(running_away()) return "running away"
			if(followPlayers)
				if(!player) return "no player"
				if(invalid_player()) return "invalid player"
				if(!viewable(src, player, 10)) return "not viewable"

		untrain()
			if(Action=="Training") Train()
			if(Action=="Meditating") Meditate()

		TrollTargetedPlayer()
			if(in_combat()) return attacker
			else return player

		troll_step()
			if(KO || KB || beam.streaming || beam.charging) return

			var/mob/m = TrollTargetedPlayer()
			if(!m) return

			if(path_steps_remaining)

				//g_step_to(m)

				if(step_to(src,m))
				else find_player() //cant get to whoever the current player is. so get a new player if possible

				path_steps_remaining--

			else if(!step_towards(src,m))
				path_steps_remaining=20
				//var/turf/t = Get_step(src,dir)

				//i just didnt want them obnoxiously breaking everything anymore. but this code still works if we uncomment it
				/*if(t && isturf(t) && t.density && t.Health != 1.#INF)
					flick("Attack",src)
					t.destroy_turf()

				else for(var/obj/o in Get_step(src,dir)) if(o.density && o.Health != 1.#INF)
					flick("Attack",src)
					del(o)*/

turf/proc/destroy_turf()
	Health=0
	Destroy()

proc/same_area(mob/a,mob/b)
	if(a.get_area() == b.get_area()) return 1

//this appears to no longer be in use anywhere
mob/proc/respond_anyway(msg)
	var/list/words=list("npc","not real","s fake","real player")
	words += name
	words += lowertext(name)
	words += uppertext(name)
	words += "[uppertext(copytext(name,1,2))][copytext(name,2,length(name)+1)]"
	for(var/v in words) if(findtext(msg,v)) return 1

mob/proc/NameMentioned(msg)
	var/list/words = new
	if(baseName && baseName != "")
		words += baseName
		words += lowertext(baseName)
		words += uppertext(baseName)
		words += "[uppertext(copytext(baseName,1,2))][copytext(baseName,2,length(baseName)+1)]"
	for(var/v in words) if(findtext(msg,v)) return 1

//lets the troll refer to a player by a shortened version of their name which looks more natural
mob/proc/TrollNickName(n = "")
	var/index_num = findtext(n," ") //find a space and return the index in the string it is found at
	if(index_num != 0)
		n = copytext(n,1,index_num)
	return n

mob/proc/TrollSay(msg)
	if(prob(1)) OOC(msg)
	else Say(msg)

//what if instead of a preset order of which snippets are processed first to last, its a list of snippets, and each troll shuffles the list so they response uniquely
//to them in order of what they think takes priority to respond to in the sentence?
mob/proc/troll_respond(msg)
	set waitfor=0
	if(!msg || msg == "") return //no response to blank messages

	var/list/recipients = new
	var/mob/new_troll/targeter //this is the troll who is focused on you, if any
	for(var/mob/new_troll/nt in trollbots)
		if(src == nt || !nt.doesTalk || nt.z != z || get_dist(src, nt) > 10 || !viewable(src, nt, 10)) continue
		if(nt.KO) continue //because the bots have their own angry ko'd dialog choices and are too busy mindlessly raging to respond to anything when ko'd
		recipients += nt
		if(nt.player == src) targeter = nt
		if(nt.NameMentioned(msg))
			targeter = nt
			break
	var/mob/new_troll/nt //this is the one troll who will actually respond. cant have too many respond or its spammy
	if(targeter) nt = targeter
	else if(recipients.len) nt = pick(recipients)

	if(nt)
	//old way shown below
	//for(var/mob/new_troll/nt in mob_view(10,src)) if(src != nt) if(nt.player==src || nt.respond_anyway(msg))
		//if(!nt.doesTalk) continue

		var/startTime = world.time
		while(!nt.can_talk)
			if(world.time - startTime > 350) return //too many messages are queued up, its time to just drop some of them
			sleep(rand(8,12))

		var/troll_response

		var/askedToAttack //if you asked the bot to attack someone
		//this block is where you can tell the troll to attack a certain player by name, and it will
		if(findtext(msg, "attack"))
			var/msg2 = lowertext(msg)
			for(var/mob/m in mob_view(20,nt))
				if(findtext(msg2, lowertext(m.name)))
					askedToAttack = 1
					if(nt.cowardIfAttacked)
						troll_response = pick(list("no","no i am peaceful","no thanks"))
					else
						nt.attacker = m
						nt.end_combat = 20
					break
		if(!askedToAttack)
			//!!!!!!! HIGH PRIORITY RESPONSES BLOCK - when adding a new possible response put it in whatever block you think represents how prioritized it should be
				//currently its all mixed up since i only added this system afterward without thinking about the order so its all random order mostly
			//if the player ONLY said JUST the bot's name (essentially) then do this:
			if(length(msg) <= length(nt.baseName) + 5 && findtext(msg, nt.baseName))
				troll_response = pick(list("yes?","what do you want?","?","??","???","what?","yeah?","huh?","hm?","ya?"))
			else if(findtext(msg, "should i") || findtext(msg, "can you") || findtext(msg, "can i"))
				troll_response = pick(list("yes","no","maybe","i think so","i dont think so"))
			//else if(findtext(msg,"fag") && provokedByWords) troll_response="im not a fag you [RandomInsultName()]"
			/*else if(findtext(msg,"holocaust") || findtext(msg, "jew") || findtext(msg, "kike"))
				troll_response = pick(list("the holocaust was a lie","hitler did nothing wrong","back to the ovens i say","gas the kikes","gas the kikes race war now"))*/
			else if(findtext(msg,"not real") || findtext(msg, "not a real"))
				troll_response=pick(list("i am real","im a real player","im real its true","im real","you lie i am real"))
			else if(findtext(msg,"you") && findtext(msg,"fake"))
				troll_response=pick(list("im not fake your fake","im real","im a real player","i am real",\
				"i am real player"))
			else if(findtext(msg,"annoy") && provokedByWords)
				troll_response=pick(list("[RandomInsultName()] your annoying", "im not", "shut up"))
			else if(findtext(msg,"girl"))
				troll_response=pick(list("if you want me to be big boi","when i'm wearing a skirt, i'm a girl!","i'm a trap"))
			/*else if(findtext(msg,"sex") || findtext(msg, "rape"))
				troll_response = pick(list("yes rape my shitter","rape my shitter","let's fuck","fuck me hard"))*/
			else if(findtext(msg,"suck") && findtext(msg,"dick"))
				troll_response= pick(list("no i dont want to suck your dick","okay i will", "if you pay me","you are gay","get that gay shit out of here"))
			else if(findtext(msg,"suck") && findtext(msg,"you"))
				troll_response=pick(list("no i dont master why would you say that?", "no you suck"))
			else if(findtext(msg,"stfu") && provokedByWords)
				troll_response=pick(list("you stfu you die now [RandomInsultName()]","now im mad. PAY FOR YOUR SINS","uhhh","uhh"))
				if(prob(50))
					spawn(65) if(src&&nt)
						nt.attacker=src
						nt.end_combat=30
			else if(findtext(msg,"fuck") && findtext(msg,"you") && provokedByWords)
				troll_response=pick(list("NO FUCK YOU", "now im mad. PAY FOR YOUR SINS","you fuck off","no you fuck off","grrr"))
				if(prob(50))
					spawn(65) if(src&&nt)
						var/txt = pick(list("YOU BETRAY ME NOW YOU DIE!","FUCK YOU","I KILL YOU","[RandomInsultName()]","PAY FOR YOUR SINS","I WILL DESTROY YOU",\
						"you have angered me and I am now left with no choice but to seek justice, EN GARDE! you should know that i have never been bested \
						in combat!","ALLAHU AKBAR"))
						nt.TrollSay(txt)
						nt.attacker=src
						nt.end_combat=30
			else if(findtext(msg,"fuck off") && provokedByWords)
				troll_response=pick(list("NO FUCK YOU FUCK OFF", "now im mad. PAY FOR YOUR SINS","you fuck off","no you fuck off","grrr"))
				if(prob(50))
					spawn(65) if(src&&nt)
						var/txt = pick(list("YOU BETRAY ME NOW YOU DIE!","FUCK YOU","I KILL YOU","[RandomInsultName()]","PAY FOR YOUR SINS","I WILL DESTROY YOU",\
						"you have angered me and I am now left with no choice but to seek justice, EN GARDE! you should know that i have never been bested \
						in combat!","ALLAHU AKBAR"))
						nt.TrollSay(txt)
						nt.attacker=src
						nt.end_combat=30
			//!!!!!!!!!!! MEDIUM PRIORITY RESPONSES BLOCK
			else if(findtext(msg,"troll")) troll_response="why you call me troll?"
			else if(findtext(msg,"ass") && provokedByWords) troll_response="im not ass you the ass [RandomInsultName()]"
			else if(findtext(msg,"you") && findtext(msg,"dumb") && provokedByWords)
				troll_response="YOU BASTARD YOU ARE DUMB NOT ME NOW YOU DIE [uppertext(RandomInsultName())]!"
				spawn(65) if(src&&nt)
					nt.attacker=src
					nt.end_combat=30
			else if(findtext(msg,"kill") && provokedByWords)
				var/txt = pick(list("why you want to kill me?","why you say kill?","kill me?","you think you can kill me?","you think you can kill me? \
				i am a living god","you kill me?","you dare threaten me?","you threaten my life?","THIS IS THE END FOR YOU"))
				troll_response = txt
				if(prob(50))
					spawn(65) if(src&&nt)
						txt = pick(list("I KILL YOU FIRST [uppertext(RandomInsultName())] YOU BETRAY ME NOW YOU DIE!","DIE [uppertext(RandomInsultName())]","NO ONE THREATENS ME AND LIVES","NO ONE \
						THREATENS ME","I AM A GOD WITNESS MY POWER","YOU BETRAY ME? DIE [uppertext(RandomInsultName())]","YOU WILL DIE FOR THIS","ALLAHU AKBAR","I AM A LIVING GOD"))
						nt.TrollSay(txt)
						nt.attacker=src
						nt.end_combat=30
			else if(findtext(msg,"die") && provokedByWords)
				troll_response="why you want me to die?"
				if(prob(50))
					spawn(65) if(src && nt)
						var/txt = pick(list("I MAKE YOU DIE FIRST [uppertext(RandomInsultName())] YOU BETRAY ME NOW YOU DIE","ALLAHU AKBAR","I KILL YOU FIRST FUCK YOU","FUCK YOU",\
						"I KILL YOU FIRST","THIS IS SELF DEFENSE I AM THE HERO DIE YOU VILLAIN","I AM THE HERO I WILL KILL ALL EVIL","DIE EVIL SCUM",\
						"DIE BY THE HANDS OF THE HERO"))
						nt.TrollSay(txt)
						nt.attacker=src
						nt.end_combat=30
			else if((findtext(msg,"okay i") || findtext(msg,"train you")) && provokedByWords)
				troll_response="TOO LATE NOW YOU DIE!"
				spawn(65) if(src&&nt)
					nt.attacker=src
					nt.end_combat=30
			else if(findtext(msg,"i will") && provokedByWords)
				troll_response="TOO LATE NOW YOU DIE"
				spawn(65) if(src&&nt)
					nt.attacker=src
					nt.end_combat=30
			else if(findtext(msg,"why"))
				troll_response="thats what i been asking you [msg]"
			//!!!!!!!!!!!!!!! LOW PRIORITY RESPONSES BLOCK
			else if(findtext(msg,"teach"))
				troll_response = pick(list("spirit bomb plz","kaioken plz","kikoho plz","mystic plz"))
			else if(findtext(msg, "oof")) troll_response = "oof"
			else if(findtext(msg, "i am")) troll_response = pick(list("me too", "i am too"))
			else if(findtext(msg, "no one")) troll_response = "i do"
			else if(findtext(msg, "do you")) troll_response = pick(list("yes","no","sometimes"))
			else if(findtext(msg, "follow")) troll_response = "no"
			else if(findtext(msg,"no") || findtext(msg,"not") || findtext(msg,"cant") || findtext(msg,"can't")) troll_response = pick(list("why not?","why?","but why?"))
			else if(findtext(msg, "nigger") || findtext(msg, "spic") || findtext(msg, "kike"))
				troll_response = pick(list("racist","RAYCIS"))
			else if(findtext(msg, "spar") || findtext(msg, "train?"))
				troll_response = pick(list("too busy","sorry cant","sorry too busy","too afk","too busy watching anime"))
			else if(findtext(msg, "anime"))
				troll_response = pick(list("attack on titan","death note","boku no pico","rise of shield hero","one punch man","mob psycho 100","kimetsu no yaiba",\
				"the promised neverland", "hunter x hunter"))
				if(prob(50)) troll_response = pick(list("my favorite anime is [troll_response]", "you should watch [troll_response]", "[troll_response] was really good"))
			else if(findtext(msg, "byond"))
				troll_response = pick(list("byond lol"))
			else if(findtext(msg, "hitler"))
				troll_response = "hitler did nothing wrong"
			else if(findtext(msg, "thing?") || (findtext(msg, "what") && findtext(msg, "thing")))
				troll_response = pick(list("yes the thing","that thing","that thing over there","that thing you have","i saw you with the thing","the thing"))
			else if(prob(50) && findtext(msg, "alex jones"))
				troll_response = "THEYRE TURNING THE FRIGGEN FROGS GAY!"
			else if(prob(50) && findtext(msg, "trump"))
				troll_response = pick(list("trump is cheetoh hitler [TrollNickName(src)]", "trump is a kike puppet [TrollNickName(src)]"))
			else if(findtext(msg,"npc"))
				troll_response=pick(list("im not an npc im real","im a real player","im a real player not npc","im not an npc",\
				"im not an npc you are npc"))
			else if(findtext(msg,"where?"))
				troll_response = pick(list("over there","at that place"))
			else if(findtext(msg, "when?"))
				troll_response = pick(list("soon"))
			else if(findtext(msg, " cat"))
				troll_response = pick(list("i love cats","k0t","kot","kayat"))
			else if(findtext(msg, "what?"))
				troll_response = pick(list("yeet!","nvm","idk","hello","hi"))
			else if(findtext(msg, "really?"))
				troll_response = pick(list("yes"))

			//give a possible response even if nothing was found to specifically respond to
			else
				if(prob(50))
					troll_response = pick(list("idk","i dont know","yes","no","maybe","lol","lmao","YEET","fuck you",\
					"fuck you [RandomInsultName()]","what?","what you mean?","what do you mean?","what did you say?","im busy"))
					if(prob(25))
						if(prob(50)) troll_response = "[TrollNickName(src)] [troll_response]"
						else troll_response = "[troll_response] [TrollNickName(src)]"

		//add a generic nonsensical prefix or suffix to the response sometimes that doesnt really add or take away anything from the intended message
		var/list/prefixes = list("okay","uh","um","...","uhh")
		var/list/suffixes = list("...",".","i guess",", i think","?","right?","huh")
		//prefix
		if(prob(25)) troll_response = "[pick(prefixes)] [troll_response]"
		//suffix
		if(prob(25)) troll_response = "[troll_response] [pick(suffixes)]"
		//random insult on end, slight chance
		if(prob(10)) troll_response = "[troll_response] [RandomInsultName()]"

		if(!troll_response)
			return
		nt.CantTalkFor(90)
		troll_response=mispell(troll_response,uppercase=prob(20),wrong_vowel=0.15,drop_letter=0.05,swap_letter=0.1)
		sleep(rand(40,60))
		if(nt) nt.TrollSay(troll_response)
		//break

//uppercase is either 0 or 1. others are 0 to 1 indicating probability, with 1 being 100%
proc/mispell(name, uppercase=1, wrong_vowel=0.1, drop_letter=0.1, swap_letter=0.1)

	if(!name) return name

	name=lowertext(name)
	var/list/l=new
	for(var/v in 1 to length(name))
		var/t=copytext(name,v,v+1)
		if(!(t in list("0","1","2","3","4","5","6","7","8","9")))
			if(prob(wrong_vowel * 9)&&(t in list("a","e","i","o","u"))) t=pick("a","e","i","o","u")
			if(prob(100-(drop_letter*4))&&!is_symbol(t)) l+=t

	while(prob(40 * swap_letter))
		var/n=pick(1,length(l)-1)
		l.Swap(n,n+1)

	var/new_name=""
	for(var/v in l) new_name="[new_name][v]"
	if(uppercase) new_name=uppertext(new_name)
	else new_name=lowertext(new_name)
	return new_name

proc/is_symbol(t)
	if(t in list("`","~","@","#","$","%","^","&","*","(",")","{","}","<",">")) return 1
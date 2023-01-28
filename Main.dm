mob/proc/Get_race_starting_bp_mod()
	switch(Race)
		if("Half Saiyan") return 2.5
		if("Saiyan") return 2
		if("Human") return 1.33
		if("Tsujin") return 1.28
		if("Majin") return new_majin_bp_mod
		if("Bio-Android") return 2.1
		if("Makyo") return 1.65
		if("Namek") return 1.75
		if("Icer") return 1.8
		if("Kai") return 1.8
		if("Demigod") return 2.5
		if("Demon") return 1.85
		if("Android") return 1
		if("Alien") return 1.55
	return 1.5

//set these in the actual race proc eventually
var/majin_new_regen=1.5
var/new_majin_bp_mod=2.55
mob/var/majin_stat_version=0
mob/var/stat_version=0


mob/var/Mob_ID=0
mob/proc/Disabled_Verb_Check()
	if(Train_Disabled) verbs-=/mob/verb/Train_verb
	if(Learn_Disabled) verbs-=/mob/verb/Learn
	if(!alignment_on)
		verbs-=/mob/verb/change_alignment
		verbs-=/mob/verb/Mark_as_evil
mob/proc/code_banned() if(client)
	//if((key in list("HeavenOfZombies","Guhan")||client.address=="94.212.98.47"||client.computer_id=="3421801848")
		//ban_alert("You are permanently banned for knowing a game breaking bug then refusing to reveal it then eventually saying you'll reveal it if you get something in return then when I refuse you blackmail me and say you'll just tell everyone except me the bug so that the game will get ruined")
		//return 1
	if(key=="Anonymous Inc."||client.address=="184.153.94.156"||client.computer_id=="1877630120")
		ban_alert("Rebanned because Exgen asked me to because you didn't change identities and play \
		anonymously without letting anyone know you are Newton like the conditions of your unban \
		said, so he figured out it was you and said reban you")
		return 1
	if(key=="Newton378"||client.address=="67.242.129.177"||client.computer_id=="3853748069")
		ban_alert("Rebanned because Exgen asked me to because you didn't change identities and play \
		anonymously without letting anyone know you are Newton like the conditions of your unban \
		said, so he figured out it was you and said reban you")
		return 1
	//if(key=="Romcio4"||client.address=="109.162.21.8"||client.computer_id=="1649663113")
	//	ban_alert("You are permanently banned for attacking servers")
	//	return 1
mob/proc/ban_alert(msg)
	//spawn alert(src,msg)
	src<<msg
mob/proc/Carry_over_imprisonments()
	if(!fexists("Save/[key]")) return
	var/savefile/F=new("Save/[key]")
	F["Imprisonments"]>>Imprisonments
mob/proc/Choose_Login() if(client)
	if(code_banned())
		sleep(10)
		del(src)
		return
	if(alts=="disallowed")
		if(client) for(var/mob/m in players) if(m!=src&&m.client&&m.client.address==client.address)
			src<<"<font color=red><font size=4>Alts are not allowed on this server"
			sleep(15)
			del(src)
			return
	if(alts=="allowed only if seperate computers")
		if(client) for(var/mob/m in players) if(m!=src&&m.client)
			if(m.client.address==client.address&&m.client.computer_id==client.computer_id)
				src<<"<font color=red><font size=4>Alts are only allowed if using seperate computers"
				sleep(15)
				del(src)
				return
	Carry_over_imprisonments()
	if(auto_train_in_save())
		sleep(100)
		src<<"<font color=yellow>AI training automaticly loaded your character"
		Load()
	else
		if(dbz_character_mode)
			Choose_dbz_character()
		else switch(alert(src,"Make your choice","","New","Load"))
			if("New")
				if(world.time<300&&can_login)
					alert(src,"You can not make a new character until at least 30 seconds have passed since the \
					last reboot")
					Choose_Login()
					return
				if(Cant_Remake())
					alert(src,"You can not remake because you have accepted a rank that is not allowed to remake. \
					The only way to remake is to have an admin delete your save or edit your Can_Remake variable to 1.")
					Choose_Login()
					return
				if(Max_Players&&Players_with_z()>=Max_Players)
					alert(src,"The max amount of players is [Max_Players]. You can not log in until someone logs off")
					Choose_Login()
					return

				var/t=Spam_relogger()
				if(t)
					t=round((t-world.time)/10)
					alert(src,"You are relogging too much, this lags everyone else greatly. You must wait \
					[t] seconds before you can load your character again")
					Choose_Login()
					return

				New_Character()
				stat_version=3
				spawn(30) if(src)
					src<<"<-- Drag this bar to size the map and chatbox+tabs to the way you want it for your screen"
					src<<"<font size=3><font color=cyan>To see what buttons do what, click the Settings button in the top right (or press Escape) and \
					choose 'View hotbar menu'"
			if("Load")
				if(!can_login)
					alert(src,"You must wait until the server is finished loading")
					Choose_Login()
					return

				if(Max_Players&&Players_with_z()>=Max_Players)
					alert(src,"The max amount of players is [Max_Players]. You can not log in until someone logs off")
					Choose_Login()
					return

				var/t=Spam_relogger()
				if(t)
					t=round((t-world.time)/10)
					alert(src,"You are relogging too much, this lags everyone else greatly. You must wait \
					[t] seconds before you can load your character again")
					Choose_Login()
					return

				Load()

				spawn(1200) oozaru_revert()

		if(Race=="Namek") verbs+=typesof(/mob/Namek/verb)
		Check_if_counterpart_is_alive_or_dead()
		/*spawn(3000) if(src)
			src<<"<b><font color=cyan>There are things called 'packs' in this game, which means in-game \
			benefits such as faster power gains and so on. They cost real money. To view the packs click \
			the 'Get Packs' button near the top of the screen. Currently [packed_player_count()] / \
			[Player_Count()] players have packs of any kind."*/
	if(Frozen)
		src<<"<font color=yellow>You logged in paralyzed. You will stop being paralyzed in 1 minute."
		spawn(600) if(src) Frozen=0
	if(!(locate(/obj/Auras) in src)) contents+=new/obj/Auras
	if(!(locate(/obj/Crandal) in src)) contents+=new/obj/Crandal
	if(!(locate(/obj/Colorfy) in src)) contents+=new/obj/Colorfy
	Fill_Active_Freezes_List()
	Pixel_Movement()
	Disabled_Verb_Check()
	if(!name||name=="") name=key
	if(!Mob_ID) Mob_ID=get_mob_id()
	//if(Race=="Demon"&&!(locate(/obj/Demon_Contract) in src)) contents+=new/obj/Demon_Contract
	if(key=="Super Saiyan X") if(!(locate(/obj/SSX_Planet) in src)) contents+=new/obj/SSX_Planet
	if(key=="Sonku") if(!(locate(/obj/Sonku_Planet) in src)) contents+=new/obj/Sonku_Planet
	Remove_Duplicate_Moves()
	RP_President()
	Add_Voting()
	Fullscreen_Check()
	if(!(locate(/obj/Auto_Attack) in src)) contents+=new/obj/Auto_Attack
	//Center_Icon(src)
	Rearrange_Mode_Check()
	Council_Check()
	Special_Key_Stuff()
	Age_Update()
	Safezone()
	check_duplicate_dragon_balls()
	get_tier()
	alt_alignment_check()
	logged_in_on_destroyed_planet_check()
	Update_tab_button_text()
	//fix halfies having 0 base bp and bp mod
	if(base_bp<1) base_bp=1
	if(bp_mod<0.1) bp_mod=0.1
	if(energy_cap&&max_ki/Eff>energy_cap) max_ki=energy_cap*Eff
	if(Race=="Majin") Undo_all_t_injections()
	Calm() //because if they relog angry they can stay perma anger instead of just a short burst
	Evil_overlay()
	Delete_excess_buffs()
	if(last_anger>world.time) last_anger=0

	if(Check_era_reset())
	else Apply_offline_gains()

	if(Race=="Majin"&&Regenerate==2) Regenerate=majin_new_regen
	if(Race=="Majin"&&bp_mod==2.35) bp_mod=new_majin_bp_mod
	if(Race=="Majin"&&majin_stat_version<=2)
		alert(src,"Due to recent changes to Majins, you must now redo your stats before you can do anything")
		Redo_Stats()

	//if(stat_version<=2)
	//	alert(src,"Due to recent changes in the stat system you must now redo your stats before you can do anything")
	//	Redo_Stats()
	stat_version=3

	if(regen<=0||recov<=0)
		src<<"<font size=6><font color=red>Your character was deleted for using the Android stat bug"
		sleep(1)
		Delete_Save(src)

	spawn Get_Packs()

	Rank_Check()

	if(sagas)
		hero_seniority_check()
		villain_seniority_check()

	//TO FIX A BUG WHERE I GAVE MYSELF INF KNOWLEDGE THEN PEOPLE WITH TECH PACK LEECHED IT. REMOVE ANY TIME
	if(Knowledge>Tech_BP) Knowledge=Tech_BP

	Add_hotbar_proxies()

proc/get_mob_id() return rand(1,999999999)
mob/var/bp_mod_Leechable=1
mob/proc/Special_Key_Stuff() if(key in list("Marquise10"))
	Intelligence*=5
	Regenerate+=3
	Lungs+=1
	leech_rate*=5
	zenkai_mod*=2
	sp_mod*=10
	mastery_mod*=10
	bp_mod*=2
	bp_mod_Leechable=0
	base_bp=Tech_BP
	max_ki=1000*Eff
	contents+=new/obj/Shunkan_Ido
	Attack_Gain(10000)
var/next_lssj=0
mob/proc
	New_Character(reincarnating,force_race,force_elite,dbz_hair,force_low_class)
		Race(force_race=force_race,force_elite=force_elite,force_low_class=force_low_class)
		bp_loss_from_low_ki=Get_bp_loss_from_low_ki()
		bp_loss_from_low_hp=Get_bp_loss_from_low_hp()
		Racial_Stats()
		if(alignment_on) choose_alignment()
		if(!dbz_character)
			Gender()
			Skin()
			if(Race=="Alien") Alien_Stuff()
		Choose_Hair(force_hair=dbz_hair)
		if(!dbz_character)
			Name()
			Choose_Age()
			if(!reincarnating) Race_Starting_Stats()
			Go_to_spawn(First_time=1)
			if(base_bp<Start_BP*bp_mod) base_bp=Start_BP*bp_mod
			if(formod>=2||Pow>=200)
				contents+=new/obj/Meditate_Level_2
				if(max_ki/Eff<1000) max_ki*=2 //so reincarnaters dont keep doubling ki
			if(prob(Cured_Vampire_Ratio()*100))
				src<<"One of your parents was cured of the vampire virus and is now immune, you were born immune as a \
				result."
				Former_Vampire=1
		spawn Player_Loops()
		LogYear=Year
		Ki=max_ki
		contents+=new/obj/Resources
		if(Race in list("Saiyan","Half Saiyan"))
			if(!Tail) Tail_Add()
			contents+=new/obj/Oozaru
		Savable=1
		Already_Voted[key]=(world.realtime/10/60/60)+6
		if(client&&!client.preload_rsc) src<<"<font size=2><font color=yellow>If this is your first time playing, \
		the game will try to load new resources (icons, sound, etc) as you come across them, which can cause you \
		a bit of lag as they download, but they only have to download once."
		Mate_Check()
		if(!dbz_character) Born_Vampire_Check()
		if(base_bp<1) base_bp=1
		Tabs=1
		era=era_resets
	Choose_Age()
		var/N=0
		if(allow_age_choosing)
			N=input(src,"What age do you want to start as? This is mostly for people wanting to start past their \
			decline age, which has various penalties and advantages. Your decline age is [Decline]","Choose age",0) as num
		if(N<0) N=0
		if(N>1000) N=1000
		N=round(N,0.1)
		BirthYear=Year-N
		Age=N
		real_age=N
		spawn(600) if(src&&Age>Lifespan()) Die()
	Race_Starting_Stats()
		max_ki*=Eff**0.5
		Random_Colors()
	Random_Colors()
		var/Color=rgb(rand(0,255),rand(0,255),rand(0,255))
		if(0) //PLAYERS VOTED FOR NO STARTING ABILITIES BUT WANTED SP 3x AS FAST
			var/obj/Attacks/Blast/A=new
			var/obj/Attacks/Charge/B=new
			var/obj/Attacks/Beam/C=new
			A.icon=pick('1.dmi','12.dmi','17.dmi','18.dmi','19.dmi','21.dmi','22.dmi','24.dmi','25.dmi')
			B.icon=pick('11.dmi','20.dmi','26.dmi','27.dmi','31.dmi','4.dmi')
			C.icon=pick('Beam1.dmi','Beam2.dmi','Beam3.dmi','Beam6.dmi')
			A.icon+=Color
			B.icon+=Color
			C.icon+=Color
			contents.Add(A,B,C)
		if(BlastCharge) BlastCharge+=Color
		for(var/obj/Auras/D in src) D.icon+=Color
		contents+=new/obj/Fly
	Name() if(client)
		name=html_encode(copytext(input(src,"Name? (50 letter limit)"),1,50))
		if(!ckey(name)) Name()
		if(findtext(name,"\n"))
			Bans.Add(key,client.address)
			world<<"[key] ([client.address]) tried to use their name to spam. They were auto-banned."
			del(src)
	Check_Spawn(list/L)
		if(world.maxz<5) return L
		for(var/A in L)
			var/Spawn
			for(var/obj/Spawn/S in Spawn_List) if(S.name==A&&!S.is_on_destroyed_planet())
				var/turf/t=S.loc
				if(t&&isturf(t)&&!t.density)
					Spawn=1
					break
			for(var/mob/m in players) if(m.z) for(var/obj/Mate/m2 in m) if(m2.Waiting&&m2.Race==A)
				Spawn=1
				break
			if(!Spawn) L-=A
		return L
	Race(force_race,force_elite,force_low_class)
		var/list/Races=Race_List()
		for(var/V in Illegal_Races) if(V in Races) Races-=V

		if(!Is_Tens()&&!SSj_Online())
			var/icers=0
			for(var/mob/m in players) if(m.Race=="Icer") icers++
			icers/=Clamp(Player_Count(),1,1.#INF)
			if(icers > 3/100) Races-="Icer"

		Races=Check_Spawn(Races) //Removes the entry from the list if there is no spawn for it

		//Tobi Uchiha's perk expires August 1st 2014
		//Doniu's expires August 1st 2014
		//if(!Is_Tens() && key!="Tobi Uchiha" && key!="Doniu")
		if(!Is_Tens())
			for(var/mob/P in players)
				if(P.Class=="Legendary Saiyan"||world.time<10*600||world.realtime<next_lssj)
					Races-="Legendary Saiyan"

		var/Saiyans=0
		var/other=0
		for(var/mob/m in players) if(m.z&&m.client&&m.Race)
			if(m.Race in list("Half Saiyan","Saiyan")) Saiyans++
			else other++
		if(!Is_Tens()) if(Saiyans) //so it cant be 0
			var/Saiyan_percent=Saiyans/(other+Saiyans)*100
			if(Saiyan_percent>max_Saiyan_percent)
				Races-="Saiyan"
				Races-="Half Saiyan"
				Races-="Legendary Saiyan"
				alert(src,"The percentage of players playing Saiyan has exceeded the cap set by admins. Saiyan \
				has been removed from the race selection. The max percent of Saiyan allowed is [max_Saiyan_percent]%")

		if(!force_race)
			force_race=input(src,"Choose a race. The most popular are at the top") in Races
			//force_race=Race_choice_menu(Races)

		switch(force_race)
			if("Human") Human()
			if("Alien") Alien()
			if("Majin") Majin()
			if("Bio-Android") Bio()
			if("Android") Android()
			if("Makyo") Makyo()
			if("Kai") Kai()
			if("Spirit Doll") Doll()
			if("Tsujin") Tsujin()
			if("Namek") Namek()
			if("Saiyan") Saiyan(force_elite=force_elite,force_low_class=force_low_class)
			if("Half Saiyan") Half_Saiyan()
			if("Icer") Icer()
			if("Demon") Demon()
			if("Demigod") Demigod()
			if("Legendary Saiyan")
				Legendary_Saiyan()
				next_lssj=world.realtime+(2*60*60*10)
		ascension_bp*=bp_mod

mob/proc/Half_Saiyan()
	Race="Half Saiyan"
	incline_age-=1
	incline_mod=0.3
	Gravity_Mod=0.7
	sp_mod=1
	mastery_mod=2
	Knowledge=300
	//alert(src,"Half Saiyans are a mix between Humans and Saiyans")
	form1x=1.4
	form2x=1.4
	form3x=1.7
	form4x=form1x*form2x*ssj4_bp_mult
	bp_mod=Get_race_starting_bp_mod()
	Decline=20
	Decline_Rate=1
	Intelligence=0.75
	knowledge_cap_rate=1
	Regenerate=0
	Lungs=0
	leech_rate=1
	med_mod=2
	zenkai_mod=0.5
	ssjat=rand(500000,700000)
	ssj2at=rand(72000000,102000000)
	ssj3at=rand(450000000,550000000)
	ssjdrain/=5
	ssjmod*=4
	ssj2mod*=2
	ssj3mod*=0.5
	base_bp=5
mob/proc/Human()
	Race="Human"
	Gravity_Mod=1
	sp_mod=2
	mastery_mod=2
	bp_mod=Get_race_starting_bp_mod()
	Decline=20
	Decline_Rate=1
	Intelligence=1
	knowledge_cap_rate=1
	Regenerate=0
	Lungs=0
	leech_rate=3
	med_mod=2
	zenkai_mod=1
	base_bp=1
	ascension_bp*=1
	stun_resistance_mod=1.3
mob/proc/Doll()
	alert(src,"Spirit Dolls are puppets who were given souls, their stats are based off Humans, with \
	a few changes. They are the only race that can fly forever without energy drain.")
	Human()
	incline_age=10
	incline_mod=0.3
	Intelligence*=1
	med_mod*=2
	mastery_mod*=2 //same as third eye human
	Decline=35
	Decline_Rate=2
	Class="Spirit Doll"
	if(!(locate(/obj/Fly) in src)) contents+=new/obj/Fly
mob/proc/Tsujin()
	alert(src,"Tsujins share the same planet as the Saiyan, and are very similar to Humans, but better with \
	technology and a bit less at fighting.")
	Human()
	Race="Tsujin"
	bp_mod=Get_race_starting_bp_mod()
	gravity_mastered=10
	base_bp=10
	Knowledge=600
	knowledge_cap_rate*=1.3
	stun_resistance_mod=1.2

mob/proc/Majin()
	Race="Majin"
	incline_age=0.1
	incline_mod=0.3
	alert(src,"Majins are very hard to kill because they are made out of a gooey substance and will regenerate unless \
	every bit of them is destroyed. They are extremely fast healers. \
	The original Majin Buu was created hundreds of years ago, and was eventually destroyed thanks to some of \
	Earth's greatest heroes. But unknown to them, microscopic particles of the Majin still \
	survived. The particles were badly damaged and mutated, but they were slowly regenerating. \
	The original Majin Buu could not be reformed, instead, decades later each colony of particles regenerated \
	into a seperate, weaker, and mutated version of the original. Although weaker, they were still some of the \
	strongest creatures in existance, and very evil. They would wreak havoc far and wide, and would cause more \
	destruction in numbers than the original ever did.")
	arm_stretch=1
	arm_stretch_icon='generic arm.dmi'
	arm_stretch_range=150
	Gravity_Mod=1
	sp_mod=3
	mastery_mod=5
	Demonic=1
	bp_mod=Get_race_starting_bp_mod()
	Decline=20
	Decline_Rate=5
	Intelligence=0.1
	knowledge_cap_rate=1
	Regenerate=1.5
	Lungs=1
	leech_rate=3
	med_mod=1
	zenkai_mod=1
	contents.Add(new/obj/Attacks/Death_Ball,new/obj/Attacks/Spin_Blast,new/obj/Attacks/Blast,new/obj/Attacks/Charge,\
	new/obj/Attacks/Beam,new/obj/Fly,new/obj/Absorb,new/obj/Shadow_Spar)
	base_bp=500
	hbtc_bp=rand(1550,1950)
	gravity_mastered=20
	ascension_bp*=1
mob/proc/Bio()
	Race="Bio-Android"
	incline_age=3
	incline_mod=1
	alert(src,"Bio Androids are organic androids which are designed to be superior to normal organic life, whether \
	this is true is debatable. They can absorb mechanical androids to reach new forms which boost their power \
	immensely.")
	Gravity_Mod=1
	sp_mod=1
	mastery_mod=2
	bp_mod=Get_race_starting_bp_mod()
	Decline=20
	Decline_Rate=2
	Intelligence=0.9
	knowledge_cap_rate=1.3
	Regenerate=1
	Lungs=1
	leech_rate=1
	med_mod=1
	zenkai_mod=1.3
	gravity_mastered=25
	contents.Add(new/obj/Attacks/Death_Ball,new/obj/Attacks/Blast,new/obj/Attacks/Charge,\
	new/obj/Attacks/Beam,new/obj/Fly,new/obj/Absorb)
	base_bp=500
	hbtc_bp=rand(1500,1900)
	Knowledge=600
	ascension_bp*=1.3
mob/proc/Makyo()
	Race="Makyo"
	incline_age=8
	incline_mod=0.6
	Gravity_Mod=1.5
	sp_mod=1.3
	mastery_mod=2.5
	alert(src,"Makyos start on Earth, the most unique thing about them is that the Makyo \
	star passes by, and gives them a big power boost and nearly unlimited energy.")
	bp_mod=Get_race_starting_bp_mod()
	Decline=30
	Decline_Rate=1
	Intelligence=0.85
	knowledge_cap_rate=1
	Regenerate=0
	Lungs=0
	leech_rate=2
	med_mod=1
	zenkai_mod=0.5
	gravity_mastered=3
	contents.Add(new/obj/Attacks/Sokidan,new/obj/Fly,new/obj/Attacks/Charge)
	base_bp=rand(120,150)
	ascension_bp*=0.9
mob/proc/Namek()
	Race="Namek"
	incline_age=5
	incline_mod=0.25
	arm_stretch=1
	arm_stretch_range=500
	Gravity_Mod=0.7
	sp_mod=1.3
	mastery_mod=2
	alert(src,"Nameks are a mostly peaceful race but also strong warriors with very unique racial \
	abilities such as making dragon balls, fusing with other Nameks, having another Namek as their \
	'counterpart' (Kami and Piccolo type thing) for shared power, stretching their arms out really \
	far, and unique racial stats that can be seen in the Race Guide in the Other tab. Nameks are \
	probably one of the most unique races.")
	bp_mod=Get_race_starting_bp_mod()
	Decline=80
	Decline_Rate=0.65
	Intelligence=0.85
	knowledge_cap_rate=1
	Lungs=0
	gravity_mastered=4
	leech_rate=2
	med_mod=4
	zenkai_mod=0.25
	Regenerate=0.45
	contents.Add(new/obj/SplitForm,new/obj/Meditate_Level_2,new/obj/Attacks/Blast,new/obj/Attacks/Charge,\
	new/obj/Attacks/Beam,new/obj/Fly,new/obj/Regeneration,new/obj/Zanzoken,new/obj/Power_Control,\
	new/obj/Attacks/Piercer)
	base_bp=rand(80,120)
	ascension_bp*=0.8
	stun_resistance_mod=2
var/elite_chance=8
mob/proc/Saiyan(Can_Elite=1,force_elite,force_low_class)
	Race="Saiyan"
	incline_age=15
	incline_mod=0.2
	Gravity_Mod=1
	sp_mod=1
	mastery_mod=1
	alert(src,"Saiyan are a warrior race gifted with the potential for great power. \
	They have tails and when the moon comes out, they turn into giant ape \
	creatures of great power. Also there is a legend of the Super Saiyan, a form that would turn a \
	normal Saiyan into the most powerful being in the universe. Saiyan have some \
	intelligence penalties and master skills slowly, but have the most powerful zenkai of any race.")
	form1x=1.4
	form2x=1.4
	form3x=1.7
	form4x=form1x*form2x*ssj4_bp_mult
	bp_mod=Get_race_starting_bp_mod()
	Decline=30
	Decline_Rate=1
	Intelligence=0.3
	knowledge_cap_rate=1
	Regenerate=0
	Lungs=0
	leech_rate=1
	med_mod=1
	zenkai_mod=1.5
	ssjat=rand(800000,1200000)
	ssj2at=rand(102000000,132000000)
	ssj3at=rand(360000000,440000000)
	gravity_mastered=10
	base_bp=rand(200,900)
	if(prob(50)||force_low_class)
		base_bp=rand(5,20)
		hbtc_bp=0
		ssjat*=0.9
		Class="Low Class"
	else if(force_elite) Elite_Saiyan()
	else if(Can_Elite&&(world.time>3000||Is_Tens()))
		var/elites=0
		for(var/mob/m in players) if(m.Race=="Saiyan"&&m.Class=="Elite") elites++
		if((Saiyan_Count()>=10&&elites/Saiyan_Count()<elite_chance/100)||Is_Tens())
			switch(alert(src,"Do you want to be an Elite Saiyan? This choice only appears if less than [elite_chance]% \
			of the Saiyans online are already elite. The penalty is that Super Saiyan will be harder to get \
			because the bp requirement is much higher. There are advantages, see the race guide for details.",\
			"options","No","Yes"))
				if("Yes") Elite_Saiyan()

mob/proc/Elite_starting_bp()
	if(!Player_Count()||!Saiyan_Count()) return 1
	var/bp=0
	for(var/mob/m in players) if(m.Race=="Saiyan") bp+=m.base_bp/m.bp_mod
	bp/=Saiyan_Count()
	return bp*bp_mod

mob/proc/Elite_Saiyan() if(Class!="Elite")
	contents.Add(new/obj/Attacks/Charge,new/obj/Attacks/Explosion,new/obj/Attacks/Beam,\
	new/obj/Attacks/Galic_Gun,new/obj/Attacks/Final_Flash,new/obj/Fly,new/obj/Attacks/Kienzan,\
	new/obj/Attacks/Shockwave,new/obj/Attacks/Blast)
	base_bp=Elite_starting_bp()
	if(base_bp<1000) base_bp=1000

	var/bp_get=rand(6300,7700)
	if(base_bp<bp_get)
		bp_get-=base_bp
		if(bp_get>0) hbtc_bp+=bp_get

	if(max_ki<800*Eff) max_ki=800*Eff
	ssjmod/=2
	ssjat*=3
	ssj2mod*=5
	mastery_mod*=2
	Gravity_Mod*=2
	sp_mod*=1.2
	Class="Elite"
mob/proc/Legendary_Saiyan()
	Saiyan(Can_Elite=0)
	Intelligence=0.1
	Gravity_Mod*=3
	Class="Legendary Saiyan"

	lssj_ver=1

	var/bp_get=rand(8000,10000)
	if(base_bp<bp_get)
		bp_get-=base_bp
		if(bp_get>0) hbtc_bp+=bp_get
	ssjadd=10000
	SSjAble=25
	form1x=1.4*1.4*1.15
	Decline-=2
	Decline_Rate=4
mob/proc/Icer()
	Race="Icer"
	incline_age=10
	incline_mod=0.3
	Gravity_Mod=3
	sp_mod=1
	mastery_mod=3
	alert(src,"Icers are a lizard-like race born on an icy planet furthest from all other races. They are \
	born with extreme power, and have the ability to shapeshift into new forms which increase their power even further.")
	bp_mod=Get_race_starting_bp_mod()
	Decline=50
	Decline_Rate=1
	Intelligence=0.5
	knowledge_cap_rate=2
	Regenerate=0
	Lungs=1
	leech_rate=1
	med_mod=1
	zenkai_mod=0.5
	gravity_mastered=15
	contents.Add(new/obj/Attacks/Death_Ball,new/obj/Attacks/Explosion,new/obj/Attacks/Ray,\
	new/obj/Power_Control,new/obj/Attacks/Blast,new/obj/Attacks/Charge,new/obj/Fly,new/obj/Attacks/Beam)
	base_bp=300
	hbtc_bp=rand(900,1200)
	ascension_bp*=4
	stun_resistance_mod=0.9
mob/proc/Kai()
	Race="Kai"
	incline_age=16
	incline_mod=0.15
	Zombie_Immune=1
	Gravity_Mod=1
	gravity_mastered=25
	sp_mod=2
	alert(src,"Kais are guardians of the afterlife and living world. They are the natural enemy of Demons, they \
	may have come from a common ancestor, but Kais evolved in the positive energy of Heaven, and Demons in the \
	negative energy of hell.")
	mastery_mod=1.6
	bp_mod=Get_race_starting_bp_mod()
	Decline=100
	Decline_Rate=0.5
	Intelligence=0.55
	Regenerate=0
	Lungs=0
	leech_rate=2
	med_mod=4
	zenkai_mod=0.25
	contents.Add(new/obj/Attacks/Sokidan,new/obj/Reincarnation,new/obj/Attacks/Charge,new/obj/Attacks/Beam,\
	new/obj/Fly,new/obj/Power_Control,new/obj/Observe,new/obj/Telepathy)
	base_bp=2000
	hbtc_bp=rand(1300,1900)
	ascension_bp*=1
mob/proc/Demigod()
	Race="Demigod"
	incline_age=13
	incline_mod=0.3
	Gravity_Mod=1
	sp_mod=1
	mastery_mod=0.5
	alert(src,"Demigods are a race with very high potential for power, but who take a very long time to reach \
	that potential. In other words, they have high BP gain, but leech BP very slow, and master skills slow.")
	bp_mod=Get_race_starting_bp_mod()
	Decline=30
	Decline_Rate=2
	Intelligence=0.8
	Regenerate=0
	Lungs=0
	leech_rate=0.5
	med_mod=1
	zenkai_mod=0.5
	base_bp=200
	hbtc_bp=rand(700,900)
	contents.Add(new/obj/Meditate_Level_2,new/obj/Heal,new/obj/Shadow_Spar,new/obj/Zanzoken)
	ascension_bp*=0.8
mob/proc/Demon()
	Race="Demon"
	incline_age=12
	incline_mod=0.4
	alert(src,"Demons are born in hell and are the enemy of the Kais. Demons can live forever as long \
	as they periodicly visit hell, which will replenish their youth. High demon ranks are given the \
	Soul Contract ability, which can take the souls of other players and have much control over them.")
	Zombie_Immune=1
	Gravity_Mod=1.2
	sp_mod=1
	mastery_mod=2
	Demonic=1
	bp_mod=Get_race_starting_bp_mod()
	Decline=30
	Decline_Rate=10 //It's 10 because they decline fast if they leave hell, hell keeps them young
	Intelligence=0.4
	Regenerate=0
	Lungs=0
	leech_rate=1
	med_mod=3
	zenkai_mod=0.5
	contents.Add(new/obj/Attacks/Death_Ball,new/obj/Attacks/Charge,\
	new/obj/Attacks/Beam,new/obj/Fly,new/obj/Absorb)
	base_bp=2000
	hbtc_bp=rand(0,300)
	ascension_bp*=0.9
	stun_resistance_mod=1.2
mob/proc/Android()
	Race="Android"
	incline_age=0.1
	incline_mod=0.3
	alert(src,"Androids are highly customizable. You can use science to create 'modules' which you can install on an \
	Android to alter its abilities and stats. You can choose Androids during creation, or make a blank Android body \
	at any time using Science in-game, and mind transfer into it. There is no difference except that choosing during \
	creation means you will spawn on the 'Android Ship'.")
	Gravity_Mod=1.5
	sp_mod=1
	mastery_mod=5
	Android=1
	bp_mod=Get_race_starting_bp_mod()
	Decline=100
	Decline_Rate=10
	Intelligence=1
	knowledge_cap_rate=0.8
	Regenerate=0
	Lungs=1
	gravity_mastered=20
	leech_rate=0.5
	med_mod=4
	zenkai_mod=0
	base_bp=100
	Knowledge=600
	Zanzoken=100
	ascension_bp*=1.1
	stun_resistance_mod=0.9
mob/proc/Alien()
	Race="Alien"
	incline_age=11
	incline_mod=0.2
	alert(src,"Alien is any other unknown race in the universe. They are more customizable than other races")
	Gravity_Mod=1
	sp_mod=1.3
	mastery_mod=2
	Knowledge=600
	knowledge_cap_rate=1.5
	bp_mod=Get_race_starting_bp_mod()
	Decline=60
	Decline_Rate=0.5
	Intelligence=0.5
	Regenerate=0
	Lungs=0
	leech_rate=1.2
	med_mod=1
	zenkai_mod=1
	hbtc_bp=rand(4500,5500)
	contents.Add(new/obj/Fly,new/obj/Attacks/Charge,new/obj/Attacks/Beam)
	ascension_bp*=1
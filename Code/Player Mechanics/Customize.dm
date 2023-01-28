mob/proc/ChangeIcerFormIcon(form = 1)
	var/icon/i = input("Choose an icon file for Form [form]") as icon|null
	if(!i || !isicon(i) || IconTooBig(i))
		return
	if(form == 1)
		icon = i
		Form1Icon = i
		CenterIcon(src)
	if(form == 2)
		Form2Icon = i
	if(form == 3)
		Form3Icon = i
	if(form == 4)
		Form4Icon = i
	if(form == 5)
		goldFormIcon = i

mob/var/tmp/tab_font_size = 10

mob/proc/Set_tab_font_size(font_size=8)
	if(!client) return
	winset(src,"infowindow.info","font-size=[font_size]&tab-font-size=[font_size]")

mob/var
	ignore_leagues
	ignore_contracts
	ignore_tournaments
	sagas_tab

mob/verb/Settings()
	//set category="Other"
	while(src&&client)
		var/list/Choices=new

		Choices.Add("Cancel")

		if(knockback_on) Choices+="Turn Knockback Off"
		else Choices+="Turn Knockback On"

		Choices+="Hotkey Setup"

		if(Race == "Frost Lord") Choices += "Use Custom Icer Form Icons"

		if(has_god_ki)
			if(Race in list("Yasai", "Half Yasai"))
				if(god_mode_on) Choices += "Turn God Ki Off"
				else if(CanTurnGodKiOn()) Choices += "Turn God Ki On"

		if(saitama_rotations)
			if(!(key in saitama_queue)) Choices+="ENTER SAITAMA QUEUE"
			else Choices+="EXIT SAITAMA QUEUE"

		if(sagas)
			if(ignore_hero) Choices += "Register for Hero Rank"
			else Choices += "De-Register for Hero Rank"

			if(ignore_villain) Choices += "Register for Villain Rank"
			else Choices += "De-Register for Villain Rank"

		//if(Fullscreen) Choices+="Fullscreen Off"
		//else Choices+="Fullscreen On"

		Choices.Add("Choose Hair","Choose Clothes","Choose Aura Icon","Choose Blast Icons",\
		"Choose 'charging ki' Icon","Text Size","Text Color","Map Size","Tabs Font Size","View Update Logs","View Guides")

		if(feats_on) Choices+="Feats & Accomplishments"

		if(precog) Choices+="Set Precog Chance"

		//if(Build) Choices+="Turn Build Tab off"
		//else Choices+="Turn Build Tab on"

		/*if(Intelligence())
			if(TechTab) Choices+="Turn Science Tab off"
			else Choices+="Turn Science Tab on"*/

		if(sagas)
			if(!sagas_tab) Choices+="Turn Sagas Tab On"
			else Choices+="Turn Sagas Tab Off"

		if(ignore_leagues) Choices+="Stop Ignoring League Invites"
		else Choices+="Ignore League Invites"
		if(ignore_contracts) Choices+="Stop Ignoring Soul Contracts"
		else Choices+="Ignore Soul Contracts"
		if(ignore_tournaments) Choices+="Stop Ignoring Tournaments"
		else Choices+="Ignore Tournaments"
		if(can_ignore_SI)
			if(block_SI) Choices+="Stop Blocking Instant Transmission"
			else Choices+="Block Instant Transmission"

		//just disabled this to remove clutter, it works, but no one really needs it
		//Choices+="Change Sense/Scan Tab Ordering"

		if(Race=="Yasai"||Race=="Half Yasai") Choices+="Alter Super Yasai Opening Graphics"

		if(block_music) Choices += "Unblock Music"
		else Choices += "Block Music"

		if(IsTens())
			Choices.Add("Run pack check","alter resources","alter intelligence","make someone epic","remove epicness from someone")

		Choices += "Get Packs"
		if(!hostAllowsPacksOnRP) //rp host has enabled packs on rp anyway for some reason
			if(noPacksOnRP && is_RP()) Choices -= "Get Packs"

		if(!client) return
		switch(input(src,"Choose what you want to do. If you know the first letter of the option you seek you can press it to cycle through them faster") in Choices)
			if("Cancel")
				save_player_settings()
				return

			if("Get Packs")
				BuyPackages()

			if("Use Custom Icer Form Icons")
				switch(input(src, "Which form?", "Options") in list("Cancel","Base Form","2nd Form","3rd Form","Final Form","Golden Form"))
					if("Base Form") ChangeIcerFormIcon(form = 1)
					if("2nd Form") ChangeIcerFormIcon(form = 2)
					if("3rd Form") ChangeIcerFormIcon(form = 3)
					if("Final Form") ChangeIcerFormIcon(form = 4)
					if("Golden Form") ChangeIcerFormIcon(form = 5)

			if("Hotkey Setup") Show_hotbar_grid()

			if("Block Music")
				block_music = 1
				src << browse("<script>window.location='google.com';</script>", "window=InvisBrowser.invisbrowser")
			if("Unblock Music") block_music = 0

			if("Register for Hero Rank")
				ToggleIgnoreHero()
				alert(src, "Now when the hero loses their rank you could be next in line to automatically get the rank (If you are still good)")
			if("De-Register for Hero Rank") ToggleIgnoreHero()
			if("Register for Villain Rank")
				ToggleIgnoreVillain()
				alert(src, "Now when the villain loses their rank you could be next in line to automatically get the rank (If you are still evil)")
			if("De-Register for Villain Rank") ToggleIgnoreVillain()

			if("Turn God Ki On")
				if(CanTurnGodKiOn())
					god_mode_on = 1
					Revert()
			if("Turn God Ki Off")
				if(CanTurnGodKiOff())
					god_mode_on = 0
					Revert()
			if("Feats & Accomplishments") ViewFeats()
			if("ENTER SAITAMA QUEUE")
				saitama_queue-=key
				saitama_queue+=key
				alert(src,"You have been entered in the waiting list to become Saitama, from One Punch Man. An overpowered character that \
				lasts for [saitama_rotation_minutes] minutes then deletes itself and goes to someone else")
			if("EXIT SAITAMA QUEUE")
				saitama_queue-=key
			if("Turn Knockback Off") knockback_on=0
			if("Turn Knockback On") knockback_on=1
			if("Change Sense/Scan Tab Ordering")
				switch(alert(src,"How do you want people in the sense/scan tab to be ordered?","Options","By their power","By their distance"))
					if("By their power") sort_sense_by="power"
					if("By their distance") sort_sense_by="distance"
			if("Run pack check") Get_Packs(from_login=0)
			if("View Guides")
				ViewGuides()
			if("Block Instant Transmission") block_SI=1
			if("Stop Blocking Instant Transmission") block_SI=0
			if("View Update Logs") View_update_logs()
			if("Fullscreen On") Fullscreen_Toggle()
			if("Fullscreen Off") Fullscreen_Toggle()
			if("Tabs Font Size")
				tab_font_size=input(src,"Set the font size you want for the stat tabs","Options",tab_font_size) as num
				tab_font_size=Clamp(tab_font_size,1,30)
				Set_tab_font_size(tab_font_size)
			if("Turn Sagas Tab On") sagas_tab=1
			if("Turn Sagas Tab Off") sagas_tab=0
			if("Set Precog Chance")
				precog_chance=input(src,"Set the chance that you will use your precog when attacked. 0-100%. \
				This is for if you want to conserve energy by not using it every time.","options",precog_chance) as num
				if(precog_chance<0) precog_chance=0
				if(precog_chance>100) precog_chance=100
			if("alter resources") alter_resources()
			if("alter intelligence") alter_intelligence()
			if("make someone epic") make_someone_epic()
			if("remove epicness from someone") remove_epicness_from_someone()
			if("Ignore Tournaments") ignore_tournaments=1
			if("Stop Ignoring Tournaments") ignore_tournaments=0
			if("Ignore League Invites") ignore_leagues=1
			if("Stop Ignoring League Invites") ignore_leagues=0
			if("Stop Ignoring Soul Contracts") ignore_contracts=0
			if("Ignore Soul Contracts") ignore_contracts=1
			if("Alter Super Yasai Opening Graphics")
				switch(input(src,"Alter opening graphics for which form?") in \
				list("Cancel","Super Yasai","Super Yasai 2","Super Yasai 3","Super Yasai 4"))
					if("Cancel") return
					if("Super Yasai")
						switch(input(src,"Which do you want to do?") in list("Create opening transformation graphics",\
						"Remove existing transformation graphic"))
							if("Create opening transformation graphics") ssj_opening=usr.Add_Trans_Effects(ssj_opening)
							if("Remove existing transformation graphic") ssj_opening=usr.Remove_Trans_Effects(ssj_opening)
					if("Super Yasai 2")
						switch(input(src,"Which do you want to do?") in list("Create opening transformation graphics",\
						"Remove existing transformation graphic"))
							if("Create opening transformation graphics") ssj2_opening=usr.Add_Trans_Effects(ssj2_opening)
							if("Remove existing transformation graphic") ssj2_opening=usr.Remove_Trans_Effects(ssj2_opening)
					if("Super Yasai 3")
						switch(input(src,"Which do you want to do?") in list("Create opening transformation graphics",\
						"Remove existing transformation graphic"))
							if("Create opening transformation graphics") ssj3_opening=usr.Add_Trans_Effects(ssj3_opening)
							if("Remove existing transformation graphic") ssj3_opening=usr.Remove_Trans_Effects(ssj3_opening)
					if("Super Yasai 4")
						switch(input(src,"Which do you want to do?") in list("Create opening transformation graphics",\
						"Remove existing transformation graphic"))
							if("Create opening transformation graphics") ssj4_opening=usr.Add_Trans_Effects(ssj4_opening)
							if("Remove existing transformation graphic") ssj4_opening=usr.Remove_Trans_Effects(ssj4_opening)
			if("Fullscreen Toggle") Fullscreen_Toggle()
			if("Choose Hair") Get_Hair()
			if("Choose Clothes") Grid(Clothing, show_names = 1)
			if("Choose Aura Icon")
				var/list/L=new
				for(var/obj/Aura_Choices/A in src) L+=A
				for(var/A in typesof(/obj/Aura_Choices)) if(A!=/obj/Aura_Choices) L+=new A
				Grid(L)
			if("Choose Blast Icons") Grid(Blasts)
			if("Choose 'charging ki' Icon")
				var/list/L=new
				for(var/A in typesof(/obj/Charges)) if(A!=/obj/Charges) L+=new A
				Grid(L)
			if("Turn Science Tab On") TechTab=1
			if("Turn Science Tab Off") TechTab=0
			if("Turn Build Tab On")
				alert(src,"Do not use build without reading this first. This will open a build tab. In that tab you can click \
				something you want to build and it will build it every step you take until you click it again to stop \
				building. If you are caught spam building you will be banned, even if you don't understand how building works, \
				because you should have read this in the first place.")
				Build=1
			if("Turn Build Tab Off") Build=0
			if("Text Size") Text_Size()
			if("Text Color") Text_Color()
			if("Map Size") Screen_Size()
mob/var/Build=0
mob/var/TechTab
mob/proc/Get_Hair()
	overlays-=hair
	overlays-='Wrinkles.dmi'
	Choose_Hair()

mob/var/tmp/Clothes

mob/proc/Get_Clothes()
	if(!Clothes) Clothes=1
	else Clothes=0

mob/proc
	/*SeeTelepathy()
		set category="Admin"
		if(seetelepathy)
			usr<<"Telepathy messages off."
			seetelepathy=0
		else
			usr<<"Telepathy messages on."
			seetelepathy=1*/
	Text_Size()
		TextSize=input(src,"Enter a size for the text you will see on your screen, between 1 and 10","Options",TextSize) as num

	Text_Color()
		TextColor=input(src,"Choose a color for OOC and Say.") as color

mob/var
	ViewX = 0
	ViewY = 0

var
	defaultScreenSize = 37 //the size i want presented to new players by default
	max_screen_size = 39
	max_admin_set_screen_size = 41 //check initialize instead because this is assigned dynamically based on classic_ui = 0/1

mob/proc
	DetermineViewSize(forceWidth)
		if(!client) return
		if(forceWidth) ViewX = forceWidth
		else
			if(!ViewX) ViewX = defaultScreenSize //set it to the view i wish to be presented to new players
			ViewX = Clamp(ViewX, 1, max_screen_size)
		ViewY = round(ViewX / (client.resolutionX / client.resolutionY))
		client.view = "[ViewX]x[ViewY]"
		//src << "View size set to [ViewX]x[ViewY]"

mob/proc/Screen_Size()
	var/ss = input(src,"Enter a map size between 1 and [max_screen_size]","Options", ViewX) as num
	ViewX = ss
	//ViewY = round(ss / (16 / 9))
	DetermineViewSize()

mob/var/Fullscreen=1

mob/proc/Fullscreen_Toggle()
	//set name=".Fullscreen_Toggle"
	Fullscreen=!Fullscreen
	Fullscreen_Check()

mob/verb/FullscreenToggle() //for the skin
	set hidden = 1
	Fullscreen_Toggle()

mob/proc/Fullscreen_Check(skipAlert) if(client)
	if(!Fullscreen)
		winset(src,"mainwindow","titlebar=true")
		winset(src,"button1","is-visible=false")
		winset(src,"button2","is-visible=false")
		winset(src,"button3","is-visible=false")
		winset(src,"mainwindow","is-maximized=false")
		winset(src,"mainwindow","is-maximized=true")
	else
		if(z) //just a quick way to avoid having this popup shown when they first launch the game but are just on the title screen
			if(!skipAlert) HelpAlert("Use F11 to toggle fullscreen", 30)
		winset(src,"mainwindow","titlebar=false")
		winset(src,"button1","is-visible=true")
		winset(src,"button2","is-visible=true")
		winset(src,"button3","is-visible=true")
		winset(src,"mainwindow","is-maximized=false")
		winset(src,"mainwindow","is-maximized=true")
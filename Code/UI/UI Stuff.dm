client
	dir=NORTH
	show_verb_panel=0
	show_map=0
	default_verb_category=null
	perspective=EYE_PERSPECTIVE
	//script="<STYLE>BODY {background: #000000; color: #CCCCCC; font-size: 1; font-weight: bold; font-family: 'Papyrus'}</STYLE>"
	script="<STYLE>BODY {background: #000000; color: #CCCCCC; font-size: 2; font-weight: bold}</STYLE>"

var/list/clients = new

client/Del()
	clients -= src
	. = ..()

client
	var
		tmp
			startViewX = 61 //we have these high for the title screen because it affects the resolution that the title screen is presented at. set it to 5x5 youll see its
				//very pixelated
			startViewY = 61
			show_chatbox = 1
			show_settings_window = 0
			show_stats = 1
			show_tabs = 1
			show_bars = 1
			show_input = 0
			helpAlertCount = 0
			helpAlertShowing = 0
			uiOrganizationMode = 0
			uiHidden = 0
			image/titleScreenImg //this client's title screen image that has been scaled to fit their resolution

client/proc
	DisplayTitleScreen()
		set waitfor=0
		while(!resolutionInitialized) sleep(1)
		mob.loc = locate(445,3,2)
		var/list/l = list('GokuBackground.jpg','MajinVegetaVsGokuBackground.jpg','ShaggyBackground.jpg',\
		'SSBlueGokuAndVegetaBackground.jpg','PiccoloMeditatingBackground.png')
		if(prob(50)) l = list('DragonUniverseNamekShadows.png')

		//copyright
		//l = list('DragonQuest.jpg')

		//var/icon/i2 = icon(pick(l))
		var/icon/i2 = icon('DragonQuest.dmi')
		sleep(5) //just seeing if this fixes the bug where Width()/Height() fails sometimes
		var
			w = i2.Width()
			h = i2.Height()
		if(!w || !h)
			world.log << "ERROR: Width or height of title screen came out as zero!"
			//sleep(5)
			//DisplayTitleScreen()
			return
		else
			var/image/i = image(icon = i2, loc = mob, layer = 10, pixel_x = -(w - 32) * 0.5, pixel_y = -(h - 32) * 0.5)
			titleScreenImg = i
			var/matrix/m = matrix(i.transform)
			var/yScale = (((mob.ViewY * 2) + 1) * 32) / h
			m.Scale(yScale * 0.5, yScale * 0.5)
			i.transform = m
			images += i

		//now the buttons
		return //nevermind theyre buggy as fuck

		var/obj/Button/NewButton/nb = new
		var/obj/Button/LoadButton/lb = new
		nb.transform *= 0.55
		lb.transform *= 0.55
		screen += nb
		screen += lb

	DeleteTitleScreen()
		set waitfor=0
		if(!titleScreenImg) return
		del(titleScreenImg)
		for(var/obj/Button/b in screen)
			b.reallyDelete = 1
			del(b)

obj
	Button
		layer = 11
		Click()
			alert(usr, "[pixel_x],[pixel_y]")
		New()
			CenterIcon(src)
			//apparently pixel_x and pixel_y dont work on client.screen so we convert it to transform offset
			//but we still keep pixel_x and pixel_y as they are in case we need them for some other reason
			var/matrix/m = matrix(transform)
			m.Translate(pixel_x, pixel_y)
			transform = m
		NewButton
			icon = 'new button.dmi'
			screen_loc = "CENTER"

		LoadButton
			icon = 'loadButton.dmi'
			screen_loc = "CENTER"

client/New()
	JSresolutionCheck()
	clients += src
	. = ..()
	mob.DetermineViewSize(forceWidth = startViewX)
	fps = client_fps
	MaxFPSTrick()
	if(connection == "telnet") mob = new/mob

	//avoiding copyright, remove this and itll be Dragon Universe again
	var/newTitle = "Dragon Quest II"
	winset(src, "mainwindow", "title=\"[newTitle]\"")

	if(!mob || !mob.loc) //in theory this should work, so if you were punched and just relog back into your character, i hope, then we shouldnt do any of this stuff?
		winset(src, "TabScience.grid1", "show-names=true")
		winset(src, "mainwindow.helpAlert", "is-visible=false")
		//winset(src, "mainwindow.helpAlert", "titlebar=false")
		if(!classic_ui)
			winset(src, "settingsButtons", "is-visible=false")
			winset(src, "Bars", "is-visible=false")
			winset(src, "statsOverlay", "is-visible=false")
			winset(src, "infowindow", "is-visible=false")
			winset(src, "outputwindow", "is-visible=false")
			winset(src, "outputwindow", "titlebar=false")
			winset(src, "infowindow", "titlebar=false")
			winset(src, "statsOverlay", "titlebar=false")
			winset(src, "settingsButtons", "titlebar=false")
			winset(src, "inputWindow", "titlebar=false")
			winset(src, "newButton", "titlebar=false")
			winset(src, "loadButton", "titlebar=false")
			winset(src, "Bars", "titlebar=false")
			winset(src, "newButton", "is-visible=false")
			winset(src, "loadButton", "is-visible=false")
			winset(src, "mainwindow.map", "is-visible=false")
			winset(src, "inputWindow", "is-visible=false")
		else
			//almost none of these seem to work in regards to hiding the draggable divider thing we were trying to accomplish on the login screen
			//not sure which to remove now, i forgot to do it at the time
			winset(src, "mainwindow.mainvsplit", "right=") //turns off tabs+output making the map take up the full screen
			winset(src, "mainwindow.map", "is-visible=true")
			winset(src,"Bars","is-visible=false")
			winset(src,"infowindow","is-visible=false")
			winset(src,"outputwindow","is-visible=false")
			winset(src,"rpane.rpanewindow","is-visible=false")
			winset(src,"mainwindow.mainvssplit","is-visible=false")
			DisplayTitleScreen()
		if(mob)
			//var/musics = list('royal blue theme.ogg', 'Ultra Instinct Theme 1.ogg', 'goku spirit bomb theme.ogg')
			var/musics = list('SecretOfMana.ogg')
			src << sound(pick(musics), volume = 20, repeat = 1)
			mob.DetectNewLoadButtonClick()
			mob.Fullscreen_Check(skipAlert = 1)
			mob.CodebanLoginCheck()
			mob.UnsortedClientLoginStuff()

mob
	verb
		//gets rid of the tabs and output so that you only see the map but you cant see what anyone is saying but its "true fullscreen"
		HideAllUI()
			set hidden = 1
			client.uiHidden = !client.uiHidden
			if(client.uiHidden) winset(src, "mainwindow.mainvsplit", "right=")
			else winset(src, "mainwindow.mainvsplit", "right=rpane")

mob/proc
	StatOverlayUpdateLoop()
		set waitfor=0
		if(classic_ui) return
		while(src)
			if(client && client.show_stats)
				var/bp_mod_display_mult = 1
				if(NearBPOrb()) bp_mod_display_mult *= bp_orb_increase
				var/bpGainVal = round(bp_mod * weights() * GravityGainsMult() * bp_mod_display_mult,0.01)
				winset(src, "statsOverlay.bpGainValue", "text='[bpGainVal]x'")
				winset(src, "statsOverlay.energyValue", "text='[round(max_ki)] ([Eff]x gains)'")
				winset(src, "statsOverlay.strengthValue", "text='[StatViewThing(Swordless_strength(), "Str")]'")
				winset(src, "statsOverlay.duraValue", "text='[StatViewThing(End, "End")]'")
				winset(src, "statsOverlay.forceValue", "text='[StatViewThing(Pow, "Pow")]'")
				winset(src, "statsOverlay.resistValue", "text='[StatViewThing(Res, "Res")]'")
				winset(src, "statsOverlay.speedValue", "text='[StatViewThing(Spd, "Spd")]'")
				winset(src, "statsOverlay.accValue", "text='[StatViewThing(Off, "Off")]'")
				winset(src, "statsOverlay.refValue", "text='[StatViewThing(Def, "Def")]'")
				var/regenLabel = (regen + Regen_Mult - 1) * DuraRegenMod()
				winset(src, "statsOverlay.regValue", "text='[round(regenLabel, 0.01)]x'")
				winset(src, "statsOverlay.recValue", "text='[round(recov + Recov_Mult-1,0.01)]x'")
				winset(src, "statsOverlay.angerValue", "text='[max_anger / 100]x'")
			sleep(30)

mob/verb
	ToggleChatbox()
		set hidden = 1
		if(!client) return
		client.show_chatbox = !client.show_chatbox
		var/bool = "true"
		if(!client.show_chatbox) bool = "false"
		winset(src, "outputwindow", "is-visible=[bool]")

	SettingsButtonClicked()
		set hidden = 1
		Settings()

	PressEscape()
		set hidden = 1
		if(winget(src, "mainwindow.helpAlert", "is-visible") == "true")
			HideHelpAlert()
			return
		if(classic_ui)
			Settings()
			return
		ToggleSettingsWindow()

	ToggleSettingsWindow()
		set hidden = 1
		if(!client) return
		client.show_settings_window = !client.show_settings_window
		var/bool = "true"
		if(!client.show_settings_window) bool = "false"
		winset(src, "settingsButtons", "is-visible=[bool]")

	ToggleStatsOverlay()
		set hidden = 1
		if(!client) return
		client.show_stats = !client.show_stats
		var/bool = "true"
		if(!client.show_stats) bool = "false"
		winset(src, "statsOverlay", "is-visible=[bool]")

	ToggleTabs()
		set hidden = 1
		if(!client) return
		client.show_tabs = !client.show_tabs
		var/bool = "true"
		if(!client.show_tabs) bool = "false"
		winset(src, "infowindow", "is-visible=[bool]")

	ToggleBars()
		set hidden = 1
		if(!client) return
		client.show_bars = !client.show_bars
		var/bool = "true"
		if(!client.show_bars) bool = "false"
		winset(src, "Bars", "is-visible=[bool]")

	ViewGuides()
		set hidden = 1
		while(src && client)
			switch(input(src,"Which guide do you want to view?") in list("Cancel","Basic Guides","Detailed Race Stats","Alignment/Sagas Guide","How to get strong faster"))
				if("Cancel") break
				if("Basic Guides") Guide()
				if("Detailed Race Stats") Race_Guide()
				if("Alignment/Sagas Guide") Sagas_Guide()
				if("How to get strong faster") Strong_guide()

	ViewHotkeys()
		set hidden = 1
		Show_hotbar_grid()

	ToggleInterfaceOrganizationMode()
		set hidden = 1
		if(classic_ui) return
		client.uiOrganizationMode = !client.uiOrganizationMode
		var/titlebar = "true"
		if(!client.uiOrganizationMode) titlebar = "false"
		winset(src, "statsOverlay", "titlebar=[titlebar]")
		winset(src, "Bars", "titlebar=[titlebar]")
		winset(src, "outputwindow", "titlebar=[titlebar]")
		winset(src, "infowindow", "titlebar=[titlebar]")

		winset(src, "statsOverlay", "can-resize=[titlebar]")
		winset(src, "Bars", "can-resize=[titlebar]")
		winset(src, "outputwindow", "can-resize=[titlebar]")
		winset(src, "infowindow", "can-resize=[titlebar]")

	PressEnter()
		set hidden = 1
		client.show_input = !client.show_input
		if(classic_ui)
			if(client.show_input)
				winset(src, "outputwindow.input1", "is-visible=true")
				winset(src, "outputwindow.input1", "focus=true")
			else
				winset(src, "outputwindow.input1", "focus=false")
				winset(src, "mapwindow.map", "focus=true")
			return
		else
			if(client.show_input)
				winset(src, "inputWindow", "is-visible=true")
				winset(src, "inputWindow.input", "focus=true")
			else
				winset(src, "inputWindow", "is-visible=false")
				if(!classic_ui) winset(src, "mainwindow.map", "focus=true")
				else winset(src,"mapwindow.map","focus=true")

	//keep in mind BYOND is calling this more than once when you click maximize for some reason
	//its calling it like 3-5 times per resize
	//so what we could do is not really running a lot of the code if the new size is the same as the old size (hopefully but its untested)
	MainWindowResized()
		set hidden = 1
		src << "Window Resized"

	/*testxxx()
		var/resolution = GetWindowSize()
		var/outputSize = GetWindowSize("outputwindow")
		var/posx = resolution[1] - outputSize[1]
		var/posy = resolution[2] - outputSize[2]
		winset(src, "outputwindow", "pos=[posx],[posy]")*/

mob/proc
	GetWindowSize(e = "mainwindow.resizeLabel")
		if(e == "mainwindow") e = "mainwindow.resizeLabel" //we have to use this trick with an invisible fullscreen label because byond's normal way doesnt work
		var/wg = winget(src, e, "size")
		var/l = dd_text2list(wg, "x")
		l[1] = text2num(l[1])
		l[2] = text2num(l[2])
		return l

	GetWindowPos(e = "mainwindow")
		var/wg = winget(src, e, "pos")
		var/l = dd_text2list(wg, ",")
		l[1] = text2num(l[1])
		l[2] = text2num(l[2])
		return l

	HelpAlertShowing()
		if(client && client.helpAlertShowing) return 1
		return 0

	NewCharHelpAlerts()
		set waitfor=0
		//if(classic_ui) return
		while(HelpAlertShowing()) sleep(10) //just wait for any other potential interfering alerts to go away before beginning
		HelpAlert("Alerts such as this will sometimes appear to help you. Press Escape to get rid of them.", 1.#INF)
		while(HelpAlertShowing()) sleep(10)
		if(!classic_ui) HelpAlert("Use F1 through F5 to toggle the Chatbox, Stats Overlay, Tabs Overlay, Health Bars, and Hotkeys Menu", 1.#INF)
		while(HelpAlertShowing()) sleep(10)
		if(!classic_ui) HelpAlert("Press Escape to view the Main Menu where you can adjust settings and exit the game", 1.#INF)
		else HelpAlert("Press Escape to view the Main Menu where you can adjust settings", 1.#INF)
		while(HelpAlertShowing()) sleep(10)
		HelpAlert("You can view the guides by clicking this alert or later through the Main Menu", 1.#INF, "ViewGuides")
		while(HelpAlertShowing()) sleep(10)
		HelpAlert("You can view what the controls are by clicking this alert or pressing F5 at any time", 1.#INF, "ViewHotkeys")
		while(HelpAlertShowing()) sleep(10)
		HelpAlert("B = Global Chat. V = Chat to players in sight. E = Use items in your inventory or in front of your character. \
		T = Grab items or players in front of you. Space = Punch (when something is in front of you to punch that is). Tab = Toggle Auto Attack \
		(automatically punch anyone who gets in front of you). X = Learn new skills.", 1.#INF)
		while(HelpAlertShowing()) sleep(10)
		if(!classic_ui) HelpAlert("Press Ctrl+F1 to be able to drag user interface elements where you want them to be. Press again to stop.", 1.#INF)

	//through a series of workarounds we are left with no other choice but to detect if they clicked new/load this way
	DetectNewLoadButtonClick()
		set waitfor=0
		if(classic_ui)
			NewLoadPromptClassic()
			return
		while(!can_login || world.time < 100) sleep(10)
		winset(src, "newButton", "is-visible=true")
		winset(src, "loadButton", "is-visible=true")
		winset(src, "newButton", "focus=false")
		winset(src, "loadButton", "focus=false")
		if(!classic_ui) winset(src, "mainwindow.map", "focus=true") //idk why but setting the other windows to visible seems to give them focus
		else winset(src, "mapwindow.map", "focus=true")
		sleep(5)
		while(1)
			if(winget(src, "newButton", "focus") == "true")
				NewClicked()
				return
			if(winget(src, "loadButton", "focus") == "true")
				if(HasSave())
					LoadClicked()
					return
				else
					alert(src, "You do not have any saved characters")
			sleep(3)

	NewClicked()
		set waitfor=0
		if(playerCharacter) return
		ClickMakeNewCharacter()
		StuffThatRunsIfYouClickNewOrLoad()

	LoadClicked()
		set waitfor=0
		if(playerCharacter) return
		if(!HasSave()) return
		Load()
		StuffThatRunsIfYouClickNewOrLoad()
		return 1

	//this is for CLASSIC only
	NewLoadPromptClassic()
		if(!classic_ui) return
		if(playerCharacter) return
		while(!can_login || world.time < 100) sleep(10)
		switch(alert(src, "Hello [key]", "", "New Character", "Load Character"))
			if("New Character") NewClicked()
			if("Load Character")
				if(!HasSave())
					alert(src, "You do not have any saved characters")
					NewClicked()
					return
				LoadClicked()
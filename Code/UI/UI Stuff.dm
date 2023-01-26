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
	clients ||= list()
	clients |= src
	. = ..()
	mob.DetermineViewSize(forceWidth = startViewX)
	fps = client_fps
	if(connection == "telnet") mob = new/mob
	if(!mob || !mob.loc) //in theory this should work, so if you were punched and just relog back into your character, i hope, then we shouldnt do any of this stuff?
		winset(src, "TabScience.grid1", "show-names=true")
		if(mob)
			//var/musics = list('royal blue theme.ogg', 'Ultra Instinct Theme 1.ogg', 'goku spirit bomb theme.ogg')
			var/musics = list('SecretOfMana.ogg')
			src << sound(pick(musics), volume = 20, repeat = 1)
			mob.DetectNewLoadButtonClick()
			mob.Fullscreen_Check(skipAlert = 1)
			mob.CodebanLoginCheck()
			mob.UnsortedClientLoginStuff()
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
		if(client.buildMode)
			client.CancelBuild()
		else
			Settings()

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
			switch(input(src,"Which guide do you want to view?") in list("Cancel","Basic Guides","Detailed Race Stats","Trait Details",\
																		"Transformation Details", "Alignment/Sagas Guide","How to get strong faster"))
				if("Cancel") break
				if("Basic Guides") Guide()
				if("Detailed Race Stats") Race_Guide()
				if("Alignment/Sagas Guide") Sagas_Guide()
				if("How to get strong faster") Strong_guide()
				if("Transformation Details") ListTransStats()
				if("Trait Details") ListTraits()

	ViewHotkeys()
		set hidden = 1
		Show_hotbar_grid()

	PressEnter()
		set hidden = 1
		client.show_input = !client.show_input
		if(client.show_input)
			winset(src, "outputwindow.input1", "is-visible=true")
			winset(src, "outputwindow.input1", "focus=true")
		else
			winset(src, "outputwindow.input1", "focus=false")
			winset(src, "mapwindow.map", "focus=true")
		return

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

	//through a series of workarounds we are left with no other choice but to detect if they clicked new/load this way
	DetectNewLoadButtonClick()
		set waitfor=0
		NewLoadPromptClassic()

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
		if(playerCharacter) return
		while(!can_login || world.time < 100)
			sleep(10)
		switch(alert(src, "Hello [key]", "", "New Character", "Load Character"))
			if("New Character") NewClicked()
			if("Load Character")
				if(!HasSave())
					alert(src, "You do not have any saved characters")
					NewClicked()
					return
				if(!Map_Loaded)
					alert(src, "You must wait until the map is finished loading")
					return NewLoadPromptClassic()
				LoadClicked()
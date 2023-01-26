mob/var/tmp/tab_font_size = 10

client/var/fallingText = 1
client/var/floatingText = 1

mob/proc/Set_tab_font_size(font_size=8)
	if(!client) return
	winset(src,"infowindow.info","font-size=[font_size]&tab-font-size=[font_size]")

mob/var
	ignore_leagues
	ignore_contracts
	ignore_tournaments
	sagas_tab

mob/verb/Settings()
	set category="Other"
	set hidden = TRUE
	while(src&&client)
		var/list/Choices=new

		Choices.Add("Cancel")

		if(knockback_on) Choices+="Turn Knockback Off"
		else Choices+="Turn Knockback On"

		Choices+="Hotkey Setup"
		if(UnlockedTransformations.len) Choices += "Manage Transformations"

		Choices.Add("Choose Hair","Choose Clothes","Choose Aura Icon","Choose Blast Icons","Choose Anger Rays Color",\
		"Choose 'charging ki' Icon","HUD Fadeout", "HUD Opacity", "HUD Scale", "HUD Color", "Text Size","Text Color",\
		"Tabs Font Size","View Update Logs","View Guides")

		if(Mechanics.GetSettingValue("Feats")) Choices+="Feats & Accomplishments"

		if(precog) Choices+="Set Precog Chance"

		if(ignorePartyInvites) Choices += "Stop Ignoring Party Invites"
		else Choices += "Ignore Party Invites"
		if(ignore_contracts) Choices += "Stop Ignoring Soul Contracts"
		else Choices +="Ignore Soul Contracts"
		if(ignore_tournaments) Choices += "Stop Ignoring Tournaments"
		else Choices +="Ignore Tournaments"

		if(block_music) Choices += "Unblock Music"
		else Choices += "Block Music"

		if(client.floatingText) Choices += "Hide Floating Chat Text"
		else Choices += "Show Floating Chat Text"

		if(client.fallingText) Choices += "Hide Damage Numbers"
		else Choices += "Show Damage Numbers"

		if(!client) return
		switch(input(src,"Choose what you want to do. If you know the first letter of the option you seek you can press it to cycle through them faster") in Choices)
			if("Cancel")
				save_player_settings()
				return

			if("Hotkey Setup") Show_hotbar_grid()

			if("Block Music")
				block_music = 1
				src << browse("<script>window.location='google.com';</script>", "window=InvisBrowser.invisbrowser")
			if("Unblock Music") block_music = 0

			if("HUD Fadeout")
				client.hudFadeTime = Time.FromSeconds(input(src, "How long (in seconds) should it take for the HUD to fade out when not in use?  \
											0 disables fadout.", "Fade Out Time", Time.ToSeconds(client.hudFadeTime)) as num|null)
				client.hudFadeTime = Math.Clamp(client.hudFadeTime, 0, Time.FromHours(0.5))
			
			if("HUD Scale")
				client.hudScale = input(src, "HUD Scale from 0.8 to 1.4.  Rounded to nearest 0.1", "HUD Scale", client.hudScale) as num|null
				client.hudScale = Math.Clamp(client.hudScale, 0.8, 1.4)
				client.hudScale = Math.Round(client.hudScale, 0.1)
				GenerateHUD()
			
			if("HUD Opacity")
				client.maxHUDOpacity = input(src, "Set maximum opacity for HUD (0 to 255)", "Max Opacity", client.maxHUDOpacity) as num|null
				client.maxHUDOpacity = Math.Clamp(client.maxHUDOpacity, 0, 255)
				client.minHUDOpacity = input(src, "Set minimum opacity for HUD (0 to [client.maxHUDOpacity])", "Min Opacity", client.minHUDOpacity) as num|null
				client.minHUDOpacity = Math.Clamp(client.minHUDOpacity, 0, client.maxHUDOpacity)
			
			if("Show Damage Numbers")
				client.fallingText = 1
				fallingTextMaster?.alpha = 255

			if("Hide Damage Numbers")
				client.fallingText = 0
				fallingTextMaster?.alpha = 0

			if("Show Floating Chat Text")
				client.floatingText = 1
				floatingTextMaster?.alpha = 255

			if("Hide Floating Chat Text")
				client.floatingText = 0
				floatingTextMaster?.alpha = 0
			
			if("Stop Ignoring Party Invites")
				ignorePartyInvites = 0
			if("Ignore Party Invites")
				ignorePartyInvites = 1

			if("Manage Transformations") ManageTransformations()

			if("Feats & Accomplishments") ViewFeats()
			if("Turn Knockback Off") knockback_on=0
			if("Turn Knockback On") knockback_on=1
			if("Change Sense/Scan Tab Ordering")
				switch(alert(src,"How do you want people in the sense/scan tab to be ordered?","Options","By their power","By their distance"))
					if("By their power") sort_sense_by="power"
					if("By their distance") sort_sense_by="distance"
			if("Block Instant Transmission") block_SI=1
			if("Stop Blocking Instant Transmission") block_SI=0
			if("View Update Logs") View_update_logs()
			if("View Guides") ViewGuides()
			if("Fullscreen On") Fullscreen_Toggle()
			if("Fullscreen Off") Fullscreen_Toggle()
			if("Tabs Font Size")
				tab_font_size=input(src,"Set the font size you want for the stat tabs","Options",tab_font_size) as num
				tab_font_size=Clamp(tab_font_size,1,30)
				Set_tab_font_size(tab_font_size)
			if("Set Precog Chance")
				precog_chance=input(src,"Set the chance that you will use your precog when attacked. 0-100%. \
				This is for if you want to conserve energy by not using it every time.","options",precog_chance) as num
				if(precog_chance<0) precog_chance=0
				if(precog_chance>100) precog_chance=100
			if("Ignore Tournaments") ignore_tournaments=1
			if("Stop Ignoring Tournaments") ignore_tournaments=0
			if("Ignore League Invites") ignore_leagues=1
			if("Stop Ignoring League Invites") ignore_leagues=0
			if("Stop Ignoring Soul Contracts") ignore_contracts=0
			if("Ignore Soul Contracts") ignore_contracts=1
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
			if("Choose Anger Rays Color")
				angerColor = input(src, "Select a color", "Anger Ray Color") as color
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
			if("HUD Color") SetHUDColor()
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

mob/proc/Text_Size()
	TextSize=input(src,"Enter a size for the text you will see on your screen, between 1 and 10","Options",TextSize) as num

mob/proc/Text_Color()
	TextColor=input(src,"Choose a color for OOC and Say.") as color

mob/var
	ViewX = 0
	ViewY = 0

mob/proc
	DetermineViewSize(forceWidth)
		if(!client) return
		if(forceWidth) ViewX = forceWidth
		else
			if(!ViewX) ViewX = Limits.GetSettingValue("Player View Size") //set it to the view i wish to be presented to new players
			ViewX = Clamp(ViewX, 35, Limits.GetSettingValue("Player View Size"))
		ViewY = round(ViewX / (client.resolutionX / client.resolutionY))
		client.view = "[ViewX]x[ViewY]"

mob/proc/Screen_Size()
	var/ss = input(src,"Enter a map size between 35 and [Limits.GetSettingValue("Player View Size")]","Options", ViewX) as num
	ViewX = ss
	DetermineViewSize()
	GenerateHUD()

mob/var/Fullscreen=0

mob/proc/Fullscreen_Toggle()
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
		winset(src,"mainwindow","titlebar=false")
		winset(src,"button1","is-visible=true")
		winset(src,"button2","is-visible=true")
		winset(src,"button3","is-visible=true")
		winset(src,"mainwindow","is-maximized=false")
		winset(src,"mainwindow","is-maximized=true")
mob/var/tmp/tab_font_size=8
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

		Choices.Add("Cancel","Choose Hair","Choose Clothes","Choose Aura Icon","Choose Blast Icons",\
		"Choose 'charging ki' Icon","Text Size","Text Color","Map Size","Stat tabs font size","View update logs","View guides")

		Choices+="View hotkey menu"

		if(Fullscreen) Choices+="Fullscreen off"
		else Choices+="Fullscreen on"
		if(precog) Choices+="Set precog chance"
		if(Build) Choices+="Turn Build Tab off"
		else Choices+="Turn Build Tab on"
		if(Intelligence)
			if(TechTab) Choices+="Turn Science Tab off"
			else Choices+="Turn Science Tab on"

		if(sagas)
			if(!sagas_tab) Choices+="Turn sagas tab on"
			else Choices+="Turn sagas tab off"

		if(ignore_leagues) Choices+="Stop ignoring league invites"
		else Choices+="Ignore league invites"
		if(ignore_contracts) Choices+="Stop ignoring soul contracts"
		else Choices+="Ignore soul contracts"
		if(ignore_tournaments) Choices+="Stop ignoring tournaments"
		else Choices+="Ignore tournaments"
		if(can_ignore_SI)
			if(block_SI) Choices+="Stop blocking Instant Transmission"
			else Choices+="Block Instant Transmission"

		Choices+="Change sense/scan tab ordering"

		if(Race=="Saiyan"||Race=="Half Saiyan") Choices+="Alter Super Saiyan opening graphics"

		if(Is_Tens())
			Choices.Add("Run pack check","alter resources","alter intelligence","make someone epic","remove epicness from someone")

		switch(input(src,"Choose what to customize.") in Choices)
			if("Cancel")
				save_player_settings()
				return
			if("Change sense/scan tab ordering")
				switch(alert(src,"How do you want people in the sense/scan tab to be ordered?","Options","By their power","By their distance"))
					if("By their power") sort_sense_by="power"
					if("By their distance") sort_sense_by="distance"
			if("Run pack check") Get_Packs(from_login=0)
			if("View hotkey menu") Show_hotbar_grid()
			if("View guides")
				while(src&&client)
					switch(input(src,"Which guide do you want to view?") in list("Cancel","Basic Guides","Detailed Race Stats","Alignment/Sagas Guide","How to get strong faster"))
						if("Cancel") break
						if("Basic Guides") Guide()
						if("Detailed Race Stats") Race_Guide()
						if("Alignment/Sagas Guide") Sagas_Guide()
						if("How to get strong faster") Strong_guide()
			if("Block Instant Transmission") block_SI=1
			if("Stop blocking Instant Transmission") block_SI=0
			if("View update logs") View_update_logs()
			if("Fullscreen on") Fullscreen_Toggle()
			if("Stat tabs font size")
				tab_font_size=input(src,"Set the font size you want for the stat tabs","Options",tab_font_size) as num
				tab_font_size=Clamp(tab_font_size,1,30)
				Set_tab_font_size(tab_font_size)
			if("Fullscreen off") Fullscreen_Toggle()
			if("Turn sagas tab on") sagas_tab=1
			if("Turn sagas tab off") sagas_tab=0
			if("Set precog chance")
				precog_chance=input(src,"Set the chance that you will use your precog when attacked. 0-100%. \
				This is for if you want to conserve energy by not using it every time.","options",precog_chance) as num
				if(precog_chance<0) precog_chance=0
				if(precog_chance>100) precog_chance=100
			if("alter resources") alter_resources()
			if("alter intelligence") alter_intelligence()
			if("make someone epic") make_someone_epic()
			if("remove epicness from someone") remove_epicness_from_someone()
			if("Ignore tournaments") ignore_tournaments=1
			if("Stop ignoring tournaments") ignore_tournaments=0
			if("Ignore league invites") ignore_leagues=1
			if("Stop ignoring league invites") ignore_leagues=0
			if("Stop ignoring soul contracts") ignore_contracts=0
			if("Ignore soul contracts") ignore_contracts=1
			if("Alter Super Saiyan opening graphics")
				switch(input(src,"Alter opening graphics for which form?") in \
				list("Cancel","Super Saiyan","Super Saiyan 2","Super Saiyan 3","Super Saiyan 4"))
					if("Cancel") return
					if("Super Saiyan")
						switch(input(src,"Which do you want to do?") in list("Create opening transformation graphics",\
						"Remove existing transformation graphic"))
							if("Create opening transformation graphics") ssj_opening=usr.Add_Trans_Effects(ssj_opening)
							if("Remove existing transformation graphic") ssj_opening=usr.Remove_Trans_Effects(ssj_opening)
					if("Super Saiyan 2")
						switch(input(src,"Which do you want to do?") in list("Create opening transformation graphics",\
						"Remove existing transformation graphic"))
							if("Create opening transformation graphics") ssj2_opening=usr.Add_Trans_Effects(ssj2_opening)
							if("Remove existing transformation graphic") ssj2_opening=usr.Remove_Trans_Effects(ssj2_opening)
					if("Super Saiyan 3")
						switch(input(src,"Which do you want to do?") in list("Create opening transformation graphics",\
						"Remove existing transformation graphic"))
							if("Create opening transformation graphics") ssj3_opening=usr.Add_Trans_Effects(ssj3_opening)
							if("Remove existing transformation graphic") ssj3_opening=usr.Remove_Trans_Effects(ssj3_opening)
					if("Super Saiyan 4")
						switch(input(src,"Which do you want to do?") in list("Create opening transformation graphics",\
						"Remove existing transformation graphic"))
							if("Create opening transformation graphics") ssj4_opening=usr.Add_Trans_Effects(ssj4_opening)
							if("Remove existing transformation graphic") ssj4_opening=usr.Remove_Trans_Effects(ssj4_opening)
			if("Fullscreen Toggle") Fullscreen_Toggle()
			if("Choose Hair") Get_Hair()
			if("Choose Clothes") Grid(Clothing)
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
			if("Turn Science Tab on") TechTab=1
			if("Turn Science Tab off") TechTab=0
			if("Turn Build Tab on")
				alert(src,"Do not use build without reading this first. This will open a build tab. In that tab you can click \
				something you want to build and it will build it every step you take until you click it again to stop \
				building. If you are caught spam building you will be banned, even if you don't understand how building works, \
				because you should have read this in the first place.")
				Build=1
			if("Turn Build Tab off") Build=0
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
		TextSize=input(src,"Enter a size for the text you will see on your screen, between 1 and 10, default is 2") as num
	Text_Color()
		TextColor=input(src,"Choose a color for OOC and Say.") as color

var/max_screen_size=33

mob/proc/Screen_Size()
	var/ss=input(src,"Enter a map size between 1 and [max_screen_size]","Options",max_screen_size) as num
	ss=Clamp(ss,1,max_screen_size)
	ViewX=ss
	ViewY=ss
	client.view="[ViewX]x[ViewY]"

mob/var/Fullscreen=1
mob/proc/Fullscreen_Toggle()
	//set name=".Fullscreen_Toggle"
	Fullscreen=!Fullscreen
	Fullscreen_Check()
mob/proc/Fullscreen_Check() if(client)
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
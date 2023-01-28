mob/var
	ignore_leagues
	ignore_contracts
mob/verb/Customize()
	//set category="Other"
	while(src)
		var/list/Choices=new
		Choices.Add("Cancel","Choose Hair","Choose Clothes","Choose Aura Icon","Choose Blast Icons",\
		"Choose 'charging ki' Icon","Text Size","Text Color","Map Size")
		if(Build) Choices+="Turn Build Tab off"
		else Choices+="Turn Build Tab on"
		if(Intelligence)
			if(TechTab) Choices+="Turn Science Tab off"
			else Choices+="Turn Science Tab on"
		if(ignore_leagues) Choices+="Stop ignoring league invites"
		else Choices+="Ignore league invites"
		if(ignore_contracts) Choices+="Stop ignoring soul contracts"
		else Choices+="Ignore soul contracts"
		if(Race=="Yasai"||Race=="Half-Yasai") Choices+="Alter Omega Yasai opening graphics"

		if(Is_Tens())
			Choices.Add("alter resources","alter intelligence","make someone epic","remove epicness from someone")

		switch(input(src,"Choose what to customize.") in Choices)
			if("Cancel") return

			if("alter resources") alter_resources()
			if("alter intelligence") alter_intelligence()
			if("make someone epic") make_someone_epic()
			if("remove epicness from someone") remove_epicness_from_someone()

			if("Ignore league invites") ignore_leagues=1
			if("Stop ignoring league invites") ignore_leagues=0
			if("Stop ignoring soul contracts") ignore_contracts=0
			if("Ignore soul contracts") ignore_contracts=1
			if("Alter Omega Yasai opening graphics")
				switch(input(src,"Alter opening graphics for which form?") in \
				list("Cancel","Omega 1","Omega 2","Omega 3","Omega 4"))
					if("Cancel") return
					if("Omega 1")
						switch(input(src,"Which do you want to do?") in list("Create opening transformation graphics",\
						"Remove existing transformation graphic"))
							if("Create opening transformation graphics") ssj_opening=usr.Add_Trans_Effects(ssj_opening)
							if("Remove existing transformation graphic") ssj_opening=usr.Remove_Trans_Effects(ssj_opening)
					if("Omega 2")
						switch(input(src,"Which do you want to do?") in list("Create opening transformation graphics",\
						"Remove existing transformation graphic"))
							if("Create opening transformation graphics") ssj2_opening=usr.Add_Trans_Effects(ssj2_opening)
							if("Remove existing transformation graphic") ssj2_opening=usr.Remove_Trans_Effects(ssj2_opening)
					if("Omega 3")
						switch(input(src,"Which do you want to do?") in list("Create opening transformation graphics",\
						"Remove existing transformation graphic"))
							if("Create opening transformation graphics") ssj3_opening=usr.Add_Trans_Effects(ssj3_opening)
							if("Remove existing transformation graphic") ssj3_opening=usr.Remove_Trans_Effects(ssj3_opening)
					if("Omega 4")
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
mob/proc/Screen_Size()
	var/Max=25
	ViewX=input(src,"Enter the width of the screen, limits are [Max].","width",ViewX) as num
	ViewY=input(src,"Enter the height of the screen.","height",ViewY) as num
	if(ViewX<1) ViewX=1
	if(ViewY<1) ViewY=1
	if(ViewX>Max) ViewX=Max
	if(ViewY>Max) ViewY=Max
	if(isnum(ViewX)&&isnum(ViewY)) client.view="[ViewX]x[ViewY]"
mob/var/Fullscreen
mob/verb/Fullscreen_Toggle()
	set name=".Fullscreen_Toggle"
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
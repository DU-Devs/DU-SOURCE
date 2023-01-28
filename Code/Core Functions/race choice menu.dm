var
	human_desc="Humans are humans etc"

var/list/race_icons=new

obj/Race_icon
	Click()
		alert(usr,"hi")

proc
	Generate_race_menu_icons()

		if(race_icons.len) return

		var/list/all_races=Race_List()
		for(var/r in all_races)
			var/obj/Race_icon/ri=new
			ri.icon=Get_race_icon(r)
			ri.desc=Get_race_desc(r)
			race_icons+=ri

	Get_race_icon(r)

		return 'Freeza OneyNG.png'

		/*switch(r)
			if("Human") return 'Human race menu.png'
			if("Puranto") return 'Puranto race menu.png'
			if("Yasai") return 'Yasai race menu.png'*/

	Get_race_desc(r)

		return "test description"

		switch(r)
			if("Human") return human_desc

	Organize_race_icons(list/races)
		var/list/l=new
		for(var/r in races)
			for(var/obj/r2 in race_icons)
				if(r2.name==r)
					race_icons-=r
					l+=r
		for(var/r in race_icons)
			race_icons-=r
			l+=r
		race_icons=l

mob/proc
	Race_choice_menu(list/races)

		if(!client) return "Human"

		Generate_race_menu_icons()
		winshow(src,"race_menu",1)
		Fill_race_menu(races)

		while(winget(src,"race_menu","is-visible")=="true") sleep(5)

		Clear_race_menu()
		winshow(src,"race_menu",0)

	Clear_race_menu()
		winset(src,"race_menu.race_grid","cells=0x0") //clear the grid
		winset(src,"race_menu.race_grid","cells=0x0")
		winset(src,"race_menu","is-visible=false")

	Fill_race_menu(list/races)

		Organize_race_icons(races)

		winset(src,"race_menu.race_grid","cells=2x[race_icons.len]")

		var/cell=1
		for(var/obj/r in race_icons)

			winset(src,"race_menu.race_grid","current-cell=1,[cell]")
			src<<output(r,"race_menu.race_grid")

			winset(src,"race_menu.race_grid","current-cell=2,[cell]")
			src<<output(r.desc,"race_menu.race_grid")

			cell++
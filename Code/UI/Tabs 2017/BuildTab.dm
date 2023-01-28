turf/var
	build_category = BUILD_UNDEFINED

obj/var
	build_category = BUILD_UNDEFINED

mob/verb
	MapFocus()
		set hidden = 1
		if(!client) return
		if(!classic_ui) winset(src,"mainwindow.map","focus=true")
		else winset(src,"mapwindow.map","focus=true")

mob/proc
	ToggleBuildMenu()
		if(!client) return
		if(winget(src, "TabHolder", "is-visible") == "true")
			winset(src, "TabHolder", "is-visible=false")
			StopBuildingThings()
		else
			winset(src, "TabHolder", "is-visible=true")
		MapFocus()
		winset(src,"TabHolder.tab1","on-tab=MapFocus")

	PopulateBuildTabs()
		set waitfor = 0
		if(!client) return

		winset(src, "TabHolder.tab1", "tabs=TabScience,TabBuildFloors,TabBuildGround,TabBuildRoofs,TabBuildWalls,TabBuildDecor,TabBuildTrees,TabBuildOther,TabBuildCustom")

		PopulateBuildTab(win = "TabBuildOther", cat = BUILD_UNDEFINED)
		PopulateBuildTab(win = "TabBuildFloors", cat = BUILD_FLOOR)
		PopulateBuildTab(win = "TabBuildGround", cat = BUILD_GROUND)
		PopulateBuildTab(win = "TabBuildRoofs", cat = BUILD_ROOF)
		PopulateBuildTab(win = "TabBuildWalls", cat = BUILD_WALL)
		PopulateBuildTab(win = "TabBuildDecor", cat = BUILD_DECOR)
		PopulateBuildTab(win = "TabBuildTrees", cat = BUILD_TREES)
		PopulateBuildTab(win = "TabScience")
		PopulateBuildTab(win = "TabBuildCustom", cat = BUILD_CUSTOM)

	PopulateBuildTab(win = "TabBuildFloors", cat = BUILD_UNDEFINED)
		set waitfor = 0
		winset(src, "[win].grid1", "is-list=true")
		winset(src, "[win].grid1", "cells=0") //clears grid
		var/added = 0
		if(win == "TabScience")
			for(var/obj/o in tech_list) if(!(o.type in Illegal_Science))
				added++
				winset(src, "[win].grid1", "current-cell=[added]")
				src << output(o, "[win].grid1")
		else if(win == "TabBuildCustom")
			var/isAdmin = IsAdmin()
			CheckAddNewButtonForCustomDecors()
			added++
			winset(src, "[win].grid1", "current-cell=[added]")
			src << output(addNewButton, "[win].grid1")
			for(var/obj/CustomDecorBlueprint/o in customDecors)
				if(o.creator != ckey) continue
				added++
				winset(src, "[win].grid1", "current-cell=[added]")
				src << output(o, "[win].grid1")
			//now we load in the ones that arent ours if we are admin
			if(isAdmin)
				for(var/obj/CustomDecorBlueprint/o in customDecors)
					if(o.creator == ckey) continue
					added++
					winset(src, "[win].grid1", "current-cell=[added]")
					src << output(o, "[win].grid1")
					sleep(3) //i find that i crash if it tries to load too many at once
		else
			for(var/obj/Build/b in Builds) if(b.build_category == cat)
				added++
				winset(src, "[win].grid1", "current-cell=[added]")
				src << output(b, "[win].grid1")
		winset(src, "[win].grid1", "cells=[added]")
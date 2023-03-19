/*
this is another tab in the build menu to let people add their own custom icon library of decorations they can build for RP purposes

there is some code in BuildTab.dm also for this
*/

var
	list
		customDecors = new //a list of CustomDecorBlueprints, for displaying in the tab so people can build them by clicking it
	newDecorBlueprintCost = 200000
	customDecorBuildCost = 50000
	myDecorLimit = 30 //how many custom decor blueprints this person can have assigned to their key
	obj
		addNewButton //the button you click
	customBuildAllowed = 1

mob/Admin4/verb
	Clear_All_Custom_Decors()
		set category = "Admin"
		switch(alert(usr, "Delete all of the blueprints from the build tab too?", "Options", "Yes", "No"))
			if("Yes")
				customDecors = new/list //it saves the list so if they reboot now it all goes away
		for(var/obj/Turfs/Custom/c)
			c.Savable = 0
			c.loc = null
			del(c)
		alert("The custom decors have all been deleted")


proc/DeleteSpamCustomDecors()
	set waitfor=0
	sleep(50)
	var/list/deleteThese = new
	for(var/obj/CustomDecorBlueprint/o in customDecors)
		if(o.icon == initial(o.icon))
			deleteThese += o
		else
			if(world.realtime - o.lastUsed > 7 * 24 * 60 * 60 * 10)
				deleteThese += o
	for(var/obj/CustomDecorBlueprint/o in deleteThese)
		customDecors -= o
		o.reallyDelete = 1
		del(o)

proc/CheckAddNewButtonForCustomDecors()
	if(addNewButton) return
	var/obj/AddNewCustomDecorButton/a = new
	addNewButton = a

obj/AddNewCustomDecorButton
	icon = 'NewIcon.dmi'
	Click()
		usr.TryNewCustomDecorBlueprint()

mob/proc
	TryNewCustomDecorBlueprint()
		if(MyDecorCount() >= myDecorLimit) return
		if(!customBuildAllowed)
			alert("The custom build system is disabled on this server")
			return
		NewCustomDecorBlueprintProc()

	MyDecorCount()
		var/count = 0
		for(var/obj/CustomDecorBlueprint/c in customDecors)
			if(c.creator == ckey)
				count++
		return count

	NewCustomDecorBlueprintProc(obj/Turfs/Custom/copyThis) //copyThis is when you are right clicking someone else's to have the blueprint for yourself to use too
		if(Res() < newDecorBlueprintCost)
			alert(src, "You need [newDecorBlueprintCost] resources")
			return
		Alter_Res(-newDecorBlueprintCost)
		var/obj/CustomDecorBlueprint/c = new
		c.creator = ckey
		c.lastUsed = world.realtime
		if(copyThis)
			c.name = copyThis.name
			c.icon = copyThis.icon
			c.icon_state = copyThis.icon_state
			c.desc = copyThis.desc
			c.alpha = copyThis.alpha
			c.pixel_x = copyThis.pixel_x
			c.pixel_y = copyThis.pixel_y
			c.density = copyThis.density
			c.clickMsg = copyThis.clickMsg
			c.layer = copyThis.layer
		else
			CustomizeDecor(c)
		if(c.icon == initial(c.icon))
			c.reallyDelete = 1
			del(c) //they didnt set it up with a custom icon so get rid of it since its just spam
			return
		customDecors += c
		PopulateBuildTab(win = "TabBuildCustom", cat = BUILD_CUSTOM)
		if(!copyThis)
			alert(src, "If you set it up wrong, simply right click it in the menu and click Customize to try again")

	TryBuildCustomDecor(obj/CustomDecorBlueprint/c)
		var/cant = CantBuildCustomDecor(c)
		if(cant)
			switch(cant)
				if("resources") alert(src, "You need [customDecorBuildCost] resources")
			return
		if(!customBuildAllowed)
			alert("The custom build system is disabled on this server")
			return
		BuildCustomDecor(c)

	CantBuildCustomDecor(obj/CustomDecorBlueprint/c)
		if(Res() < customDecorBuildCost) return "resources"
		if(!base_loc()) return "no loc"
		return 0

	BuildCustomDecor(obj/CustomDecorBlueprint/c)
		if(!key) return
		Alter_Res(-customDecorBuildCost)
		var/obj/Turfs/Custom/c2 = new(base_loc())
		c2.name = c.name
		c2.icon = c.icon
		c2.icon_state = c.icon_state
		c2.desc = c.desc
		c2.alpha = c.alpha
		c2.pixel_x = c.pixel_x
		c2.pixel_y = c.pixel_y
		c2.density = c.density
		c2.clickMsg = c.clickMsg
		c2.layer = c.layer
		c2.Builder = key
		if(!(ckey in Built_Objs)) Built_Objs[ckey] = new/list
		var/list/l = Built_Objs[ckey]
		l += c2
		Built_Objs[ckey] = l
		c2.Savable = 1
		c.lastUsed = world.realtime

obj/CustomDecorBlueprint
	icon = 'CustomDecor.dmi' //just so we have something to see by default
	name = "Custom Decor"
	var
		creator //a key of who made it
		clickMsg
		lastUsed = 0 //so ones that havent been used in a long time self delete

	Click(location, control, params)
		usr.TryBuildCustomDecor(src)
		if(usr) usr.MapFocus()

	verb
		Destroy_Decor()
			set src in world
			usr.DestroyDecor(src)

		Customize_Decor()
			set src in world
			usr.CustomizeDecor(src)

mob/proc
	DestroyDecor(obj/CustomDecorBlueprint/c)
		if(!istype(c, /obj/CustomDecorBlueprint))
			return
		if(c.creator != usr.ckey && !usr.IsAdmin())
			alert(usr, "You can only destroy ones that were made by you")
			return
		customDecors -= c
		c.reallyDelete = 1
		del(c)
		usr.PopulateBuildTab(win = "TabBuildCustom", cat = BUILD_CUSTOM)

	CustomizeDecor(obj/CustomDecorBlueprint/c)
		if(!istype(c, /obj/CustomDecorBlueprint))
			return
		if(c.creator != usr.ckey)
			alert(usr, "This was not made by you, only the creator of it can customize it")
			return
		alert(usr, "Now you will set up the custom decoration, including its name and custom icon. The icon must be on your PC already.")
		var/icon/i = input(usr, "Choose an icon from your computer for the custom objects", "Options") as icon|null
		if(findtext("[i]", ".gif"))
			alert(usr, "gifs are not allowed due to lag")
			return
		var/toobigmsg = IconTooBigMsg(IconTooBig(i))
		if(toobigmsg)
			alert(usr, "Failed because: [toobigmsg]. Please try again.")
			return
		c.icon = i
		c.icon_state = input(usr, "icon_state? blank for default") as text
		var/newName = input(usr, "Name the decor", "Options", c.name) as text
		if(newName && newName != "")
			c.name = newName
		switch(alert(usr, "Auto Center the icon? If you click No then you will manually choose the pixel_x and pixel_y offsets", "Options", "Yes", "No"))
			if("Yes")
				CenterIcon(c)
			if("No")
				c.pixel_x = input(usr, "pixel_x offset", "Options", pixel_x) as num
				c.pixel_y = input(usr, "pixel_y offset", "Options", pixel_y) as num
		c.desc = input(usr, "Description? (Optional. It's for when someone right clicks it and uses Examine on it)", "Options", desc) as text
		var/newAlpha = input(usr, "Transparency? 100 = fully solid. 0 = invisible / fully transparent.", "Options", 100) as num
		newAlpha = Clamp(newAlpha, 0, 100) / 100 * 255
		c.alpha = newAlpha
		switch(alert(usr, "Dense Object? If Yes, the object can not be walked over", "Options", "Yes", "No"))
			if("Yes") c.density = 1
		var/clickMsg = input(usr, "Click message? If someone clicks this object they will receive this message") as text
		c.clickMsg = clickMsg
		switch(alert(usr, "Visual Layer?", "Options", "Below Players", "Above Players"))
			if("Below Players") c.layer = 2.5
			if("Above Players") c.layer = 4.5
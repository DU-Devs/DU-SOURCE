#define NUM2HEX(a,b) num2text((a), (b), 16)

resourceManager
	var
		tmp
			list/resourceList
			list/resourceNames
			list/dynResourceNames
			
			unkID = 0
		list/dynResources

	New(saveName = "data/uploads")
		GenerateResourceList()
		if(saveName && fexists(saveName))
			LoadFromSavefile(saveName)
		else
			dynResources = list()
			dynResourceNames = list()

	Read(savefile/F)
		..()
		dynResources = dynResources || list()
		dynResourceNames = list()
		var/unkStr = "dynrsc/unk/", unkStrLen = length(unkStr)
		unkID = -1
		for(var/rscName in dynResources)
			if(findtext(rscName, unkStr) == 1) 
				unkID = max(unkID, text2num(copytext(rscName, unkStrLen + 1)))
			dynResourceNames[dynResources[rscName]] = rscName
		unkID++

	proc
		GenerateResourceList()
			resourceList = list()
			resourceNames = list()
			var/resource, id = "\[0xc000000]", i = 0

			while((resource = locate(id)))
				resourceNames[resource] = "[resource]"
				resourceList["[resource]"] = resource
				id = "\[0xc[NUM2HEX(++i, 6)]]"

		LoadFromSavefile(fileName)
			var/savefile/F = new(fileName)
			F.cd = ".0"
			Read(F)

		SaveToSavefile(fileName = "data/uploads")
			var/savefile/F = new(fileName)
			F << src

		GetResourceByName(name)
			return resourceList[name] || dynResources[name]

		GetResourceName(resource)
			return resourceNames[resource] || dynResourceNames[resource]

		IsDynResource(resource)
			return !resourceNames[resource]

		GenerateDynResource(resource)
			var/resourceName = "[resource]" || "unk/[unkID++]", name = "dynrsc/[resourceName]"
			dynResources[name] = resource
			dynResourceNames[resource] = name
			return name

appearanceManager
	var
		list/appearanceCache
		stackSize = 0

	New()
		appearanceCache = list()

	proc
		GetSaveableAppearance(app)
			if(isloc(app) || istype(app, /image))
				app = app:appearance
			return appearanceCache[app] || (appearanceCache[app] = new /mutable_appearance/saveable(app))

		IncSaveStack()
			stackSize++

		DecSaveStack()
			stackSize--
			if(stackSize == 0)
				appearanceCache.len = 0

mutable_appearance/saveable
	Write(savefile/F)
		var
			savedIcon
			savedOverlays
			savedUnderlays
			origIcon

		appearanceManager.IncSaveStack()

		savedIcon = icon && (resourceManager.GetResourceName(icon) || resourceManager.GenerateDynResource(icon))
		if(savedIcon)
			origIcon = icon
			icon = null

		var/list/origOverlays = overlays
		if(overlays.len)
			var/list/maOverlays = new()
			for(var/appearance in overlays)
				maOverlays += appearanceManager.GetSaveableAppearance(appearance)
			savedOverlays = maOverlays
			overlays = null

		var/list/origUnderlays = underlays
		if(underlays.len)
			var/list/maUnderlays = new()
			for(var/appearance in underlays)
				maUnderlays += appearanceManager.GetSaveableAppearance(appearance)
			savedUnderlays = maUnderlays
			underlays = null
		..()
		F["invisibility"] = 0
		if(savedIcon)
			F["savedIcon"] << savedIcon
			icon = origIcon
		if(savedOverlays)
			F["savedOverlays"] << savedOverlays
			overlays = origOverlays
		if(savedUnderlays)
			F["savedUnderlays"] << savedUnderlays
			underlays = origUnderlays

		appearanceManager.DecSaveStack()

	Read(savefile/F)
		..()
		var/val
		F["savedIcon"] >> val
		if(val) icon = resourceManager.GetResourceByName(val)
		F["savedOverlays"] >> overlays
		F["savedUnderlays"] >> underlays



#define SAVE_OVERLAYS 1
#define SAVE_UNDERLAYS 2
#define SAVE_VIS_CONTENTS 4
#define SAVE_CONTENTS 8
#define SAVE_ALL 15

atom/movable
	var/tmp/saveFlags = SAVE_ALL

	Write(savefile/F)
		var/savedIcon, list/savedOverlays, list/savedUnderlays, origAppearance = appearance
		var/origVisContents, origContents, initIcon = initial(icon)

		appearanceManager.IncSaveStack()

		savedIcon = (icon != initIcon) && (resourceManager.GetResourceName(icon) || resourceManager.GenerateDynResource(icon))
		if(savedIcon)
			icon = initIcon

		if(saveFlags & SAVE_OVERLAYS)
			savedOverlays = new()
			for(var/appearance in overlays)
				savedOverlays += appearanceManager.GetSaveableAppearance(appearance)
		overlays = initial(overlays)

		if(saveFlags & SAVE_UNDERLAYS)
			savedUnderlays = new()
			for(var/appearance in underlays)
				savedUnderlays += appearanceManager.GetSaveableAppearance(appearance)
		underlays = initial(underlays)

		if(!(saveFlags & SAVE_VIS_CONTENTS))
			origVisContents = vis_contents.Copy()
			vis_contents = initial(vis_contents)
			
		if(!(saveFlags & SAVE_CONTENTS))
			origContents = contents.Copy()
			contents = initial(contents)
		..()

		if(savedIcon) F["savedIcon"] << savedIcon
		if(savedOverlays) F["savedOverlays"] << savedOverlays
		if(savedUnderlays) F["savedUnderlays"] << savedUnderlays
		appearance = origAppearance
		if(origVisContents) vis_contents = origVisContents
		if(origContents) contents = origContents
		appearanceManager.DecSaveStack()

	Read(savefile/F)
		..()
		var/val
		F["savedIcon"] >> val
		if(val) icon = resourceManager.GetResourceByName(val)
		if(saveFlags & SAVE_OVERLAYS)
			F["savedOverlays"] >> overlays
		if(saveFlags & SAVE_UNDERLAYS)
			F["savedOverlays"] >> underlays

image
	var/tmp/saveFlags = SAVE_ALL

	Write(savefile/F)
		var/savedIcon, list/savedOverlays, list/savedUnderlays
		var/origAppearance = appearance, origVisContents, initIcon = initial(icon)

		appearanceManager.IncSaveStack()

		savedIcon = (icon != initIcon) && (resourceManager.GetResourceName(icon) || resourceManager.GenerateDynResource(icon))
		if(savedIcon)
			icon = initIcon

		if(saveFlags & SAVE_OVERLAYS)
			savedOverlays = new()
			for(var/appearance in overlays)
				savedOverlays += appearanceManager.GetSaveableAppearance(appearance)
		overlays = initial(overlays)

		if(saveFlags & SAVE_UNDERLAYS)
			savedUnderlays = new()
			for(var/appearance in underlays)
				savedUnderlays += appearanceManager.GetSaveableAppearance(appearance)
		underlays = initial(underlays)

		if(!(saveFlags & SAVE_VIS_CONTENTS))
			origVisContents = vis_contents.Copy()
			vis_contents = initial(vis_contents)
		..()

		if(savedIcon) F["savedIcon"] << savedIcon
		if(savedOverlays) F["savedOverlays"] << savedOverlays
		if(savedUnderlays) F["savedUnderlays"] << savedUnderlays
		appearance = origAppearance
		if(origVisContents) vis_contents = origVisContents
		appearanceManager.DecSaveStack()
		
	Read(savefile/F)
		..()
		var/val
		F["savedIcon"] >> val
		if(val) icon = resourceManager.GetResourceByName(val)
		if(saveFlags & SAVE_OVERLAYS)
			F["savedOverlays"] >> overlays
		if(saveFlags & SAVE_UNDERLAYS)
			F["savedOverlays"] >> underlays

var/resourceManager/resourceManager = new()
var/appearanceManager/appearanceManager = new()

world
	Del()
		resourceManager.SaveToSavefile()
		..()
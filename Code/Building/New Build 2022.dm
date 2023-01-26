build_proxy
	parent_type = /obj
	mouse_opacity = 2
	var
		build_type
		created_by

	proc
		operator~=(build_proxy/B)
			if(proxyTag == B) return 1
			if(!istype(B, /build_proxy)) return
			return B.build_type == src.build_type && B.name == src.name && B.icon == src.icon

		Print(x, y, z, mob/creator)
			if(!ispath(build_type) || !x || !y || !z) return
			if(ismob(creator) && creator.client && !creator.DoesBuildFree() && creator.Res() < creator.turf_lay_cost()) return
			var/atom/A = new build_type(locate(x, y, z))
			A.name = name
			A.icon = icon
			A.icon_state = icon_state
			A.density = density
			A.opacity = opacity
			A.layer = layer
			A.plane = plane
			A.proxyTag = "{[type]}[build_type]:([name])"
			return A
		
		Copy(atom/A)
			name = A.name
			icon = A.icon
			icon_state = A.icon_state
			density = A.density
			opacity = A.opacity
			layer = A.layer
			plane = A.plane
			build_type = A.type
			proxyTag = "{[type]}[build_type]:([name])"
		
		Expose()
			. = "\"[proxyTag]\" = new[type]{name = \"[name]\"; icon = \'[icon]\'; icon_state = \"[icon_state]\"; density = [density]; opacity = [opacity]; \
				build_type = [build_type]}"

	map_object
		var
			savedDir
			classification
			identifier
			variantRange = 1
		
		New()
			..()
			if(classification && identifier)
				icon_state = "[classification]_[identifier][variantRange > 1 ? Math.Rand(1, variantRange) : ""]"

		Print(x, y, z, mob/creator)
			var/creatorCkey
			if(creator)
				creatorCkey = ismob(creator) ? creator.ckey : creator
			var/obj/map_object/O = ..()
			O.pixel_x = pixel_x
			O.pixel_y = pixel_y
			O.step_x = step_x
			O.step_y = step_y
			O.Bolted = Bolted
			O.classification = classification
			O.identifier = identifier
			O.variantRange = variantRange
			if(ismob(creator))
				O.dir = creator?.client?.buildDir
				O.created_by = creator.ckey
				O.defenseTier = GetDefenseTier(creator.Knowledge)
				creatorCkey = creator.ckey
			else
				O.dir = savedDir
				O.created_by = creator
				O.defenseTier = defenseTier
				creatorCkey = creator
			if(creatorCkey) AddObjProxy(creatorCkey, new/simple_vector(x, y, z), O)
			return O
		
		Copy(obj/map_object/O)
			..()
			pixel_x = O.pixel_x
			pixel_y = O.pixel_y
			step_x = O.step_x
			step_y = O.step_y
			Bolted = O.Bolted
			savedDir = O.dir
			created_by = O.created_by
			classification = O.classification
			identifier = O.identifier
			variantRange = O.variantRange
			if(classification && identifier)
				icon_state = "[classification]_[identifier][variantRange > 1 ? Math.Rand(1, variantRange) : ""]"
		
		Expose()
			. = "[replacetext(..(), "}", ";")] pixel_x = [pixel_x]; pixel_y = [pixel_y]; step_x = [step_x]; step_y = [step_y]; dir = [dir]}"

	turf
		var
			dirtOverlays
			grassOverlays
			oversizedIconX
			oversizedIconY
			canBuildOver
			list/states
			list/variants
			classification
			identifier
			variantRange = 1
			edgePriority = 0
			edgeInterior = 1
			edgeState = ""
		
		New()
			..()
			if(classification && identifier)
				icon_state = "[classification]_[identifier][variantRange > 1 ? Math.Rand(1, variantRange) : ""]"

		Print(x, y, z, mob/creator)
			var/turf/original = locate(x, y, z)
			var/creatorCkey, quadrant/Q = original.currentQuadrant
			if(creator)
				creatorCkey = ismob(creator) ? creator.ckey : creator
				var/proxy_storage/P = PlayerMadeTurfs["@[creatorCkey]|[original.proxyTag]"]
				if(P) P.Remove(original.proxyTag, new/simple_vector(x, y, z))
			var/turf/T = ..()
			T.dirtOverlays = dirtOverlays
			T.grassOverlays = grassOverlays
			T.oversizedIconX = oversizedIconX
			T.oversizedIconY = oversizedIconY
			T.canBuildOver = canBuildOver
			T.currentQuadrant ||= Q
			T.classification = classification
			T.identifier = identifier
			T.variantRange = variantRange
			T.edgePriority = edgePriority
			T.edgeInterior = edgeInterior
			T.edgeState = edgeState
			if(istype(T, /turf/wall/patterned)) T:states = states?.Copy()
			if(istype(T, /turf/ground)) T:variants = variants?.Copy()
			T.SetupIconInfo()
			if(ismob(creator))
				T.dir = creator?.client?.buildDir
				T.created_by = creatorCkey
				T.defenseTier = GetDefenseTier(creator.Knowledge)
			else
				T.created_by = creator
				T.defenseTier = defenseTier
			if(creatorCkey) AddTurfProxy(creatorCkey, new/simple_vector(x, y, z), T)
			T.RemoveNonPlayerObjects()
			return T
		
		Copy(turf/T)
			..()
			dirtOverlays = T.dirtOverlays
			grassOverlays = T.grassOverlays
			oversizedIconX = T.oversizedIconX
			oversizedIconY = T.oversizedIconY
			canBuildOver = T.canBuildOver
			defenseTier = T.defenseTier
			created_by = T.created_by
			classification = T.classification
			identifier = T.identifier
			variantRange = T.variantRange
			edgePriority = T.edgePriority
			edgeInterior = T.edgeInterior
			edgeState = T.edgeState
			if(classification && identifier)
				icon_state = "[classification]_[identifier][variantRange > 1 ? Math.Rand(1, variantRange) : ""]"
			if(istype(T, /turf/wall/patterned)) states = T:states.Copy()
			if(istype(T, /turf/ground)) variants = T:variants.Copy()
		
		Expose()
			. = "[replacetext(..(), "}", ";")] dirtOverlays = [dirtOverlays]; grassOverlays = [grassOverlays]; canBuildOver = [canBuildOver]; \
				oversizedIconX = [oversizedIconX]; oversizedIconY = [oversizedIconY]}"

obj/build_camera
	icon = null
	density = 0
	var
		moving = 0
		tmp/mob/owner

	proc/MoveReset()
		set waitfor=0
		sleep(TickMult(0.1))
		moving=0

turf/proc/CanBuildOver(mob/M)
	if(currentQuadrant?.tag in UnloadedQuadrants) return 0
	if(created_by && created_by != M?.ckey)
		return (GetDefenseTier(M?.Knowledge) > Math.Floor(defenseTier * 0.95))
	return M?.IsAdmin() || canBuildOver

mob/proc/CanAffordBuild()
	return (Res() >= turf_lay_cost())

var/list/Builders = list("khunkurisu")
mob/Admin4/verb/Toggle_Builder_Status(mob/M in players)
	if(M.ckey in Builders)
		Builders -= M.ckey
		usr << "[M.name] removed from Builders list."
	else
		Builders |= M.ckey
		usr << "[M.name] added to Builders list."

proc/IsBuildEligible(mob/M)
	return !Limits.GetSettingValue("Builder Role Required") || M.IsAdmin() || (M.ckey in Builders)

proc/CanEnterBuildMode(mob/M)
	return M.HasMaxResources() && !(M.KO || M.logout_timer || world.time < M.cant_logout_until_time)

client
	var
		buildMode = 0
		buildTool = BUILD_PAINT
		buildType = BUILD_TURFS
		painting = 0
		buildDir = SOUTH
		obj/map_object/targetObj
		list/paintedTurfs
		list/selectedObjects
		obj/highlight
		obj/build_camera/buildCam = new(null)
		build_proxy/buildTarget
		list/highlightedAtoms = list()
		buildX = 1
		buildY = 1
		paintLock = 0
		lastBrushUpdate = 0
		turf/mouseTurf
	
	proc
		BuildModeToggle()
			if(!IsBuildEligible(mob))
				buildMode = 0
				mob.SendMsg("You have not been given building privileges!", CHAT_OOC)
				DisableBuildMode()
				return
			if(!CanEnterBuildMode(mob))
				buildMode = 0
				mob.SendMsg("You can only build while your health/energy/stamina are maxed and you are not in combat!", CHAT_OOC)
				DisableBuildMode()
				return
			buildMode = !buildMode
			if(buildMode) ActivateBuildMode()
			else DisableBuildMode()
			winset(src,"BuildTabHolder.buildTab1","on-tab=MapFocus")
		
		ActivateBuildMode()
			if(!highlight) CreateHighlight()
			UpdateHighlightColor()
			if(!buildTarget && turfBuildPalette?.len) buildTarget = turfBuildPalette[1]
			sleep(world.tick_lag)
			buildCam ||= new(null)
			buildCam.owner = mob
			buildTool = BUILD_PAINT
			buildCam.loc = locate(mob.x, mob.y, mob.z)
			eye = buildCam
			ClearSelection()
			mob.GenerateHUD()
		
		DisableBuildMode()
			buildCam.loc = null
			mouseTurf = null
			eye = mob
			ClearHighlights()
			mob.GenerateHUD()
		
		EnableBuildTabs()
			winset(src,"rpane.rpanewindow","left=BuildTabHolder")
			winset(src, "BuildTabHolder", "is-visible=true")
			mob.MapFocus()

		DisableBuildTabs()
			winset(src,"rpane.rpanewindow","left=infowindow")
			winset(src, "BuildTabHolder", "is-visible=false")
			mob.MapFocus()
		
		PopulateBuildTabs()
			set waitfor = 0
			winset(src, "BuildTabHolder.buildTab1", "tabs=TabBuildGround,TabBuildFloors,TabBuildWalls,TabBuildRoofs,TabBuildDecor,TabBuildOther")

			winset(src, "TabBuildGround.grid1", "is-list=true")
			winset(src, "TabBuildGround.grid1", "cells=0")
			var/added = 0
			for(var/i in groundPalette)
				var/build_proxy/B = groundPalette[i]
				added++
				winset(src, "TabBuildGround.grid1", "current-cell=[added]")
				src << output(B, "TabBuildGround.grid1")
			winset(src, "TabBuildGround.grid1", "cells=[added]")

			winset(src, "TabBuildFloors.grid1", "is-list=true")
			winset(src, "TabBuildFloors.grid1", "cells=0")
			added = 0
			for(var/i in tilePalette + stairsPalette)
				var/build_proxy/B = (tilePalette + stairsPalette)[i]
				added++
				winset(src, "TabBuildFloors.grid1", "current-cell=[added]")
				src << output(B, "TabBuildFloors.grid1")
			winset(src, "TabBuildFloors.grid1", "cells=[added]")

			winset(src, "TabBuildWalls.grid1", "is-list=true")
			winset(src, "TabBuildWalls.grid1", "cells=0")
			added = 0
			for(var/i in wallPalette)
				var/build_proxy/B = wallPalette[i]
				added++
				winset(src, "TabBuildWalls.grid1", "current-cell=[added]")
				src << output(B, "TabBuildWalls.grid1")
			winset(src, "TabBuildWalls.grid1", "cells=[added]")

			winset(src, "TabBuildRoofs.grid1", "is-list=true")
			winset(src, "TabBuildRoofs.grid1", "cells=0")
			added = 0
			for(var/i in roofPalette)
				var/build_proxy/B = roofPalette[i]
				added++
				winset(src, "TabBuildRoofs.grid1", "current-cell=[added]")
				src << output(B, "TabBuildRoofs.grid1")
			winset(src, "TabBuildRoofs.grid1", "cells=[added]")

			winset(src, "TabBuildOther.grid1", "is-list=true")
			winset(src, "TabBuildOther.grid1", "cells=0")
			added = 0
			for(var/i in (otherPalette + liquidPalette))
				var/build_proxy/B = (otherPalette + liquidPalette)[i]
				added++
				winset(src, "TabBuildOther.grid1", "current-cell=[added]")
				src << output(B, "TabBuildOther.grid1")
			winset(src, "TabBuildOther.grid1", "cells=[added]")

			winset(src, "TabBuildDecor.grid1", "is-list=true")
			winset(src, "TabBuildDecor.grid1", "cells=0")
			added = 0
			for(var/i in objPalette)
				var/build_proxy/B = objPalette[i]
				added++
				winset(src, "TabBuildDecor.grid1", "current-cell=[added]")
				src << output(B, "TabBuildDecor.grid1")
			winset(src, "TabBuildDecor.grid1", "cells=[added]")

		CreateHighlight()
			highlight = new
			highlight.icon = 'outline.dmi'
			highlight.pixel_x = -1
			highlight.pixel_y = -1
			highlight.vis_flags = VIS_INHERIT_ID
	
		UpdateHighlightColor()
			highlight.color = mob?.hudColor
		
		AddHighlight(atom/A)
			if(!A || (!isturf(A) && !istype(A, /obj/map_object))) return
			A:vis_contents |= highlight
			highlightedAtoms |= A
		
		RemoveHighlight(atom/A)
			if(!A || (!isturf(A) && !istype(A, /obj/map_object))) return
			A:vis_contents.Remove(highlight)
			highlightedAtoms.Remove(A)
		
		ClearHighlights()
			for(var/atom/A in highlightedAtoms)
				A:vis_contents.Remove(highlight)
		
		CanPaintTurfs()
			return buildMode && buildTarget && !paintLock && islist(paintedTurfs) && mob?.CanAffordBuild()
		
		CancelBuild()
			buildMode = 0
			targetObj = null
			PaintTurfs()
			ClearSelection()
			buildMode = 1
		
		ClearSelection()
			selectedObjects = list()
		
		OffsetSelections(axis, direction)
			for(var/obj/map_object/O in selectedObjects)
				if(axis == "x")
					O.pixel_x += 1 * direction
				else
					O.pixel_y += 1 * direction
		
		IsValidTurf(turf/T)
			return T && isturf(T) && T.CanBuildOver(mob) && T?.proxyTag != buildTarget?.proxyTag
		
		IsValidObject(obj/O)
			return O && istype(O, /obj/map_object) && (mob.IsAdmin() || O:created_by == ckey)
		
		PaintTurfs()
			set waitfor = FALSE
			set background = TRUE
			while(paintLock) sleep(world.tick_lag)
			if(buildMode)
				paintLock = 1
				for(var/turf/T in paintedTurfs)
					if(buildTarget && T?.CanBuildOver(mob) && mob?.CanAffordBuild())
						mob?.Alter_Res(-mob?.turf_lay_cost())
						buildTarget.Print(T?.x, T?.y, T?.z, mob)
				paintLock = 0
			ClearHighlights()
			ClearSelection()
			paintedTurfs = list()
	
	verb
		ToggleBuildMode()
			set category = "Other"
			BuildModeToggle()
		
		/* ChooseBuildTarget()
			set category = "Build"
			buildTarget = input(mob, "Choose something to build.", "Choose Build Target") in turfBuildPalette
			if(!buildTarget && turfBuildPalette?.len) buildTarget = turfBuildPalette[1] */

	MouseDown(object, location, control, params)
		if(IsValidObject(object))
			var/obj/map_object/O = object
			if(buildTool == BUILD_SELECT)
				selectedObjects |= O
				AddHighlight(O)
				return
		if(CanPaintTurfs() && IsValidTurf(location))
			lastBrushUpdate = world.time
			var/turf/T = location
			mouseTurf = T
			RemoveHighlight(T)
			paintedTurfs = list()
			buildX = T.x
			buildY = T.y
			if(buildTool == BUILD_FILL)
				paintLock = 1
				spawn
					paintedTurfs = TurfSpanFill(T, BUILD_MAX_DIM, mob)
					paintLock = 0
			else if(buildTool in list(BUILD_PAINT, BUILD_RECT, BUILD_RECT_HOLLOW, BUILD_LINE))
				paintLock = 1
				paintedTurfs.Add(T)
				AddHighlight(T)
				paintLock = 0
			else if(buildTool == BUILD_PICK)
				buildTarget = turfPalette[T.proxyTag]
				return
	
	MouseUp(object, location, control, params)
		if(buildMode)
			if(IsValidObject(object))
				var/obj/map_object/O = object
				if(buildTool == BUILD_PICK)
					buildTarget = objPalette[O.proxyTag]
					mob.MapFocus()
				return
			if(istype(object, /build_proxy))
				var/build_proxy/B = object
				if(findtext(control, "TabBuild"))
					buildTarget = B
					mob.MapFocus()
				return
		PaintTurfs()

	MouseDrag(src_object, over_object, src_location, over_location, src_control, over_control, params)
		if(IsValidObject(over_object))
			var/obj/map_object/O = over_object
			if(buildTool == BUILD_SELECT)
				selectedObjects |= O
				AddHighlight(O)
				return
		var/turf/T = over_location
		if(CanPaintTurfs() && IsValidTurf(T) && mouseTurf != T)
			mouseTurf = T
			if(!paintedTurfs || !islist(paintedTurfs)) paintedTurfs = list()
			var/x2 = Math.Clamp(Math.Clamp(T.x, buildX - BUILD_MAX_DIM, buildX + BUILD_MAX_DIM), 1, world.maxx)
			var/y2 = Math.Clamp(Math.Clamp(T.y, buildY - BUILD_MAX_DIM, buildY + BUILD_MAX_DIM), 1, world.maxy)
			if(buildTool == BUILD_PAINT && !(T in paintedTurfs))
				paintLock = 1
				paintedTurfs.Add(T)
				AddHighlight(T)
				paintLock = 0
			else if(buildTool == BUILD_RECT || buildTool == BUILD_RECT_HOLLOW)
				paintLock = 1
				spawn
					var/isHollow = (buildTool == BUILD_RECT_HOLLOW)
					ClearHighlights()
					paintedTurfs = TurfSquare(buildX, buildY, x2, y2, T.z, isHollow)
					for(var/turf/T2 in paintedTurfs)
						if(T2.CanBuildOver(mob))
							AddHighlight(T2)
						else paintedTurfs.Remove(T2)
					paintLock = 0
			else if(buildTool == BUILD_LINE)
				paintLock = 1
				spawn
					ClearHighlights()
					paintedTurfs = TurfLine(buildX, buildY, x2, y2, T.z, mob)
					paintLock = 0
			else if(buildTool == BUILD_ELLIPSE)
				paintLock = 1
				spawn
					ClearHighlights()
					if(buildX == x2 || buildY == y2)
						paintedTurfs = TurfLine(buildX, buildY, x2, y2, T.z, mob)
					else
						paintedTurfs = TurfEllipse(buildX, buildY, T.x, T.y, T.z, 0, mob)
					paintLock = 0
	
	MouseEntered(object, location, control, params)
		if(buildMode && isturf(location) && mouseTurf != location)
			mouseTurf = location
			AddHighlight(location)
	
	MouseExited(object, location, control, params)
		if(!paintLock)
			ClearHighlights()
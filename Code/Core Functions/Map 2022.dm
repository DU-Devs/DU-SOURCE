var/list/PlayerMadeTurfs = list()
var/list/PlayerMadeObjects = list()

atom
	plane = BACKDROP_PLANE

	movable
		plane = MOVABLE_PLANE

#ifdef DEBUG
mob/Admin5
	verb
		TestBuildPower()
			set category = "DEBUG"
			var/tier = 1
			while(GetTierReq(tier) <= usr.Knowledge)
				tier++
			usr << Math.Max(tier-1, 1)
	
		MakeHardToBuildOn(turf/T in world)
			set category = "DEBUG"
			T.defenseTier = 10000
			T.created_by = "a dude who is cool"
		
		CheckPlayerMadeTurfs(mob/M in players)
			set category = "DEBUG"
			for(var/i in PlayerMadeTurfs)
				if(findtext(i, M.ckey))
					usr << i
#endif

var/list/turfPalette = list()
var/list/turfBuildPalette = list()
proc/SetTurfPalette()
	set background = TRUE
	turfPalette.Add(groundPalette, tilePalette, stairsPalette, wallPalette, roofPalette, otherPalette, liquidPalette)
	for(var/i in turfPalette + objPalette)
		var/build_proxy/B = turfPalette[i]
		turfBuildPalette += B

atom
	var
		defenseTier = 0
		proxyTag

	proc
		GetDefenseTier(knowledge)
			var/tier = 1
			while(GetTierReq(tier) <= knowledge)
				tier++
			return Math.Max(tier-1, 1)
		
		IncreaseDefense(mob/upgraded_by)
			defenseTier = GetDefenseTier(upgraded_by.Knowledge)
			Health = 100 * defenseTier
	
		SetProxyTag()
			proxyTag = "{/build_proxy}[type]:([name])"
	
	Enter(atom/movable/O)
		. = ..()
		if((ismob(O) && (O in players)) && (!currentQuadrant || !("[z]" in QuadrantZsSet)))
			SetZQuadrants(z)
			O:ShowWaitingScreen()
			while(!(currentQuadrant) || !("[z]" in QuadrantZsSet))
				sleep(world.tick_lag)
			O:HideWaitingScreen()
			LoadAdjacentQuadrants()
			O.currentQuadrant = currentQuadrant
			while(currentQuadrant?.tag in UnloadedQuadrants)
				sleep(world.tick_lag)
		LoadAdjacentQuadrants()
	
	Entered(atom/movable/Obj, atom/OldLoc)
		. = ..()
		if(Obj.currentQuadrant != currentQuadrant)
			Obj.SetQuadrant(currentQuadrant)
	
	Exited()
		. = ..()
		ShareQuadrantWithContents(currentQuadrant)

turf
	density = 0
	blend_mode = BLEND_INSET_OVERLAY
	icon = null
	var
		oversizedIconX = 0
		oversizedIconY = 0
		grassOverlays = 0
		dirtOverlays = 0
		created_by
		canBuildOver = 1
		classification
		identifier
		variantRange = 1
		edgePriority = 0
		edgeInterior = 1
		edgeState = ""
	
	verb
		Upgrade()
			set src in view(1)
			if(world.time > usr.last_wall_upgrade + 10)
				usr.SendMsg("You can only do this once every second (to prevent lag).", CHAT_IC)
				return
			usr.last_wall_upgrade = world.time
			if(!created_by)
				usr.SendMsg("You can only use this on things built by players.", CHAT_IC)
				return
			var/list/Options=GetUpgradeOptions(usr)
			switch(input("Options") in Options)
				if("Upgrade and make dense all") usr.UpgradeAllBuildables(created_by, 1)
				if("Make dense all") usr.DenseAllBuildables(created_by)
				if("Make undense all") usr.DenseAllBuildables(created_by, 1)
				if("Upgrade all") usr.UpgradeAllBuildables(created_by)
	
	proc
		GetUpgradeOptions(mob/M)
			. = list("Cancel","Upgrade all")
		
		SetupIconInfo()
			set waitfor = 0
			set background = 1
			if(oversizedIconX > 0 && oversizedIconY > 0)
				DecideTurfStateForSpecialIcons(oversizedIconX, oversizedIconY)
			var/hasOverlay = 0
			if(grassOverlays && !hasOverlay)
				hasOverlay = RandomGrassOverlay()
			if(dirtOverlays && !hasOverlay)
				hasOverlay = RandomDirtOverlay()
			if(classification && identifier)
				icon_state = "[classification]_[identifier][variantRange > 1 ? Math.Rand(1, variantRange) : ""]"
				//spawn AutoGenEdges()
		
		RemoveNonPlayerObjects()
			set waitfor = 0
			set background = 1
			for(var/obj/map_object/O in contents)
				if(!O.created_by || (O.created_by != created_by && O.defenseTier < defenseTier))
					del O
			
			for(var/obj/O in contents)
				if(!O.IsScienceObject() && !istype(O, /obj/map_object) && !istype(O, /obj/build_camera))
					del O
		
		AutoGenEdges()
			set background = 1
			if(edgePriority <= 0) return
			edgeState = "[classification]_[identifier]"
			world << "start loop"
			for(var/i in (CARDINAL_DIRECTIONS + ORDINAL_DIRECTIONS))
				world << "[i]"
				var/turf/T = get_step(src, i)
				if(T.proxyTag != proxyTag && T.edgePriority < edgePriority)
					world << "valid edge turf detected"
					var/obj/map_object/edge/newEdge = new(null)
					newEdge.icon = 'Edge Tiles.dmi'
					newEdge.icon_state = edgeState
					newEdge.name = "Edge [Capitalize(classification)] [uppertext(identifier)]"
					world << "[newEdge.name] created"
					if(edgeInterior)
						newEdge.dir = i
						newEdge.loc = locate(src.x, src.y, src.z)
						world << "interior edge placed"
					else
						newEdge.dir = get_dir(T, src)
						newEdge.loc = locate(T.x, T.y, T.z)
						world << "exterior edge placed"
	
	SetProxyTag()
		set background = 1
		proxyTag = "{/build_proxy/turf}[type]:([name])"
		spawn for(var/obj/map_object/O in src.contents)
			O.SetProxyTag()
			sleep(0)

	ground
		layer = MAP_LAYER
		auto_cliff = 1
		auto_wave = 1
		auto_edge = 1
		auto_gen_eligible = 1
		var/list/variants = list()
		edgeInterior = 0
		edgePriority = 3

		SetupIconInfo()
			..()
			if(variants?.len)
				icon_state = pick(variants)

		connector
			SetupIconInfo()
				..()

	wall
		layer = MAP_LAYER + 0.1
		auto_cliff = 0
		auto_wave = 0
		auto_edge = 0
		density = 1
		opacity = 0
		edgePriority = 2

		Enter(atom/movable/A)
			if(istype(A,/obj/Blast)) return 1
			if(istype(A, /obj/build_camera)) return 1
			if(ismob(A))
				if(A:KB && A:GetStatMod("Dur") + A:GetTierBonus(0.25) > defenseTier)
					return Destroy() && ..()
				else
					return A:Flying && ..()
			..()
		
		patterned
			var/list/states = list()
			SetupIconInfo()
				..()
				if(x % 2) icon_state = states[1]
				else icon_state = states[2]

		roof
			layer = MAP_LAYER + 0.2
			opacity = 1
			density = 1
			edgePriority = -1
			var
				passOver = 1

			Enter(atom/movable/A)
				if(istype(A,/obj/Blast)) return 1
				if(istype(A, /obj/build_camera)) return CanBuildOver(A?:owner)
				if(ismob(A))
					var/obj/items/Door_Hacker/dh
					if(A:Flying) for(dh in A:item_list) if(dh.BP >= Health) break
					if(dh)
						if(DH_ANNOUNCE)
							for(var/mob/M in player_view(15,A))
								M.SendMsg("[A:name] uses a door hacker to break in.", CHAT_IC)
						A:SafeTeleport(src, allowSameTick = 1)
						return 1
					if(A:KB && A:GetStatMod("Dur") + A:GetTierBonus(0.25) > defenseTier)
						return Destroy() && ..()
					else
						return A:Flying && passOver && ..()
				..()
			
			GetUpgradeOptions(mob/M)
				. = ..()
				if(M?.ckey == created_by) . += list("Upgrade and make dense all", "Make dense all", "Make undense all")
			
			Click()
				if(getdist(usr,src)<=1) usr.UpgradeAllBuildables(created_by, 1)

	liquid
		plane = REFLECTION_PLANE
		layer = MAP_LAYER
		auto_cliff = 0
		auto_wave = 0
		auto_edge = 0
		auto_gen_eligible = 0
		edgePriority = 1

		Enter(atom/movable/A, atom/oldLoc)
			. = ..()
			if(ismob(A))
				if(A:Flying || !A.density || A:KB)
					Water_Ripple(A)
					return 1
				else if(A:stamina > A:SwimDrain())
					return 1
			else
				if(!istype(A, /obj/build_camera)) Water_Ripple(A)
				if(istype(A,/obj/Blast) || istype(A, /obj/build_camera)) return 1
		
		proc
			MobSwimming(mob/M)
				if(!M.KO)
					if(M.stamina < M.SwimDrain())
						if(!(M.Dead || M.Lungs))
							M.TakeDamage(M.SwimDrain(), source = "drowning")
					else 
						M.IncreaseStamina(-M.SwimDrain() / 5)
				else
					if(!M.Dead)
						if(prob(Math.Max(100 - M.determination * 5, 0)))
							M.Death("drowning")
							M.UpdateGravity()
							M.StopSwimming()
							M.FullHeal()
						else M.IncreaseDetermination(-5)
		
		magma
			MobSwimming(mob/M)
				if(!M.KO)
					if(M.stamina < M.SwimDrain())
						if(!M.Dead && !M.Lungs)
							M.TakeDamage(M.SwimDrain(), source = "drowning")
					else 
						M.IncreaseStamina(-M.SwimDrain() / 5)
				if(!M.Dead && !M.Demonic)
					if(prob(Math.Max(100 - M.determination * 5, 0)))
						M.Death("magma")
						M.UpdateGravity()
						M.StopSwimming()
						M.FullHeal()
					else
						M.IncreaseDetermination(-5)
						M.TakeDamage(M.SwimDrain(), source = "magma")
							
	sky

proc/IsWater(turf/T)
	return isturf(T) && (T.Water || istype(T, /turf/liquid))

proc/HasCreator(atom/A)
	return (isturf(A) || istype(A, /obj/map_object)) && (A:created_by || A:Builder)

obj/proc/IsScienceObject()
	return src.Cost && !src.referenceObject

proc/CanDestroyTurf(mob/M, turf/T, list/statMods =  list("Dur"))
	var/addFromMods = 0
	for(var/i in statMods)
		addFromMods += M.GetStatMod(i)
	return M.Is_wall_breaker() && (M.effectiveBPTier + addFromMods > T.defenseTier * Mechanics.GetSettingValue("Turf Health Multiplier"))

var/obj/swim_shallow_filter = new/obj{icon = 'Swim Overlay.dmi'; render_target = "*swim_shallow_filter";\
screen_loc = "CENTER,TOP+500"; icon_state = "small"}
var/obj/swim_deep_filter = new/obj{icon = 'Swim Overlay.dmi'; render_target = "*swim_deep_filter";\
screen_loc = "CENTER,TOP+500"; icon_state = "large"}
mob/proc/AddSwimMask()
	client?.screen += swim_shallow_filter
	client?.screen += swim_deep_filter

mob/onEntered(atom/movable/O, atom/oldloc)
	if(Flying || !istype(O, /turf/liquid))
		StopSwimming()
	else if(istype(O, /turf/liquid))
		StartSwimming()

mob/proc/StartSwimming()
	if(is_swimming) return
	is_swimming = 1
	var/shallow = 0
	if(locate(/turf/ground) in view(1)) shallow = 1
	if(shallow)
		RemoveFilter("Swim Deep Filter")
		AddFilter("Swim Shallow Filter", filter(type = "alpha", render_source = "*swim_shallow_filter", flags = MASK_INVERSE))
	else
		RemoveFilter("Swim Shallow Filter")
		AddFilter("Swim Deep Filter", filter(type = "alpha", render_source = "*swim_deep_filter", flags = MASK_INVERSE))

mob/proc/StopSwimming()
	if(!is_swimming) return
	is_swimming = 0
	RemoveFilter("Swim Shallow Filter")
	RemoveFilter("Swim Deep Filter")

mob/proc/UpgradeAllBuildables(creator, dense = 0)
	set waitfor = 0
	set background = 1
	var/Cost=round(1000/src.Intelligence())
	if(src.DoesBuildFree()) Cost = 0
	if(src.Res()<Cost)
		src.SendMsg("You need at least [Commas(Cost)]$ to upgrade a wall.", CHAT_IC)
		return
	src.Alter_Res(-Cost)
	for(var/mob/M in player_view(15,src))
		M.SendMsg("[usr] upgrades [creator]'s walls to lv[Commas(GetDefenseTier(Knowledge))], if they were below that \
					amount already. (Cost: [Commas(Cost)]$)", CHAT_IC)
	spawn
		for(var/i in PlayerMadeTurfs)
			if(findtext(i, creator))
				var/proxy_storage/P = PlayerMadeTurfs[i]
				P.Upgrade(src)
				if(dense) P.Dense()
			sleep(0)

mob/proc/DenseAllBuildables(creator, undense = 0)
	set waitfor = 0
	set background = 1
	for(var/i in PlayerMadeTurfs)
		if(findtext(i, creator))
			var/proxy_storage/P = PlayerMadeTurfs[i]
			P.Dense(undense)

mob/proc/DoesBuildFree()
	return IsAdmin() && Social.GetSettingValue("Admins Build Free")

obj/map_object
	layer = MAP_LAYER + 0.01
	density = 1
	icon = null

	proc/operator~=(obj/map_object/O)
		if(istype(O, /obj/map_object))
			return O.name == src.name && O.icon == src.icon && O.type == src.type
		if(istype(O, /build_proxy))
			var/build_proxy/B = O
			return B.name == src.name && B.icon == src.icon && B.build_type == src.type
	
	var
		center_icon = 0
		center_x_only = 0
		created_by
		classification
		identifier
		variantRange = 1

	New(loc, mob/creator)
		. = ..()
		SetProxyTag()
		if(center_icon) CenterIcon(src, x_only = center_x_only)
		defenseTier = GetDefenseTier(Tech_BP)
		Health = 100 * defenseTier
	
	SetProxyTag()
		proxyTag = "{/build_proxy/map_object}[type]:([name])"
	
	edge
		plane = BACKDROP_PLANE
		center_icon = 0
		center_x_only = 0
		density = 0
		Grabbable = 0
		var
			multiDirs = 1

		New()
			. = ..()
			if(multiDirs)
				switch(dir)
					if(NORTH) icon_state = "N"
					if(SOUTH) icon_state = "S"
					if(EAST) icon_state = "E"
					if(WEST) icon_state = "W"
		
		liquid
			multiDirs = 0
	
	decor
		layer = DECOR_LAYER
		
		light_emitter
			var
				lightSize = 5
				lightColor = "#FFFFFF"
				heated = 0
			
			New()
				..()
				GiveLightSource(size = lightSize, light_color = lightColor)
				if(heated && src)
					spawn Fire_Cook(300)

		door
			icon = 'Door.dmi'
			icon_state = "Closed"
			opacity = 1
			var
				locked = 0
				password
				isOpen = 0
			
			New()
				..()
				spawn
					for(var/obj/map_object/decor/door/D in range(0,src)) if(D!=src) del(D)
					for(var/obj/Turfs/Door/D in range(0,src)) if(D!=src) del(D)
					for(var/obj/Controls/A in view(1,src)) del(src)
					for(var/turf/Teleporter/Teleporter/A in view(1,src)) del(src)
			
			Cross(atom/movable/O)
				. = !locked
				if(ismob(O))
					if(.)
						Open()
						return
					if(isOpen) return 1
					var/mob/M = O
					if(M.drone_module && M.drone_module.Password == password)
						Open()
						return 1
					for(var/obj/items/Door_Pass/dp in M.item_list)
						if(dp.Password == password)
							Open()
							return 1
					for(var/obj/items/Door_Hacker/dh in M.item_list)
						if(dh.GetDefenseTier(dh.BP) >= defenseTier)
							player_view(15,src)<<"[M.name] hacks the door and it opens"
							Open()
							return 1
					if(M.client && locked && password && !M.KB)
						return PassAlert(M)
			
			proc
				Open()
					density = 0
					opacity = 0
					flick("Opening", src)
					icon_state = "Open"
					isOpen = world.time
					spawn(1)
						while(isOpen + 50 > world.time)
							sleep(1)
						Close()

				Close()
					density=1
					opacity=1
					flick("Closing",src)
					icon_state="Closed"
					isOpen = 0
				
				PassAlert(mob/M)
					set waitfor=0
					if(!M || !M.client) return
					if("door password" in M.active_prompts) return
					M.active_prompts += "door password"
					var/guess = input(M, "You must know the password to enter here") as text
					M.active_prompts -= "door password"
					if(guess != password) return
					Open()
					return 1
	
			verb
				Toggle_Lock()
					set src in view(usr,1)
					if(!locked && usr.ckey == created_by)
						if(!password)
							var/newPassword = input(usr,"Enter a password or leave blank") as text|null
							if(!newPassword) return
							password = newPassword
						locked = 1
					else
						var/obj/items/Door_Pass/dp = locate() in usr
						if(dp.Password == password || (input(usr, "Input current password to unlock.") as text|null) == Password)
							locked = 0

	sign
		layer = MAP_LAYER + 0.01

	large_chair
		layer = MAP_LAYER + 0.01
		density = 0

	tree
		layer = MOVABLE_LAYER + 0.02
		center_icon = 1
		center_x_only = 1
var/list/AllTransformations = new/list
var/list/LockedTransformations = new/list
mob/var/list/transOrder[5]
mob/var/list/UnlockedTransformations = new/list
mob/var/list/transOverlays = new
mob/var/list/transUnderlays = new
mob/var/currentForm = "Base"
mob/var/formSlotID = 0

mob/proc/ChangeFormSlot(n = 1)
	if(currentForm == "Base")
		formSlotID = 0
	formSlotID += n
	if(formSlotID < 0)
		formSlotID = 0
	if(formSlotID > GetFormSlotLength())
		formSlotID = 1

mob/proc/GetFormSlotLength()
	var/n = 0
	for(var/i=1, i<=transOrder.len, i++)
		if(transOrder[i] && transOrder[i] != "Base") n++
	return n

proc/PopulateFullTransformationList()
	var/list/transes = typesof(/transformation)
	transes.Remove(/transformation)
	for(var/i in transes)
		if(!ispath(i)) continue
		var/transformation/T = new i
		if(!T) continue
		AllTransformations[T.name] = i

mob/Admin4/verb/Manage_Transformations()
	if(!LockedTransformations) LockedTransformations = new/list
	while(src)
		switch(alert(usr, "What would you like to do?", "Manage Transformations", "Lock a Transformation", "Unlock a Transformation", "Cancel"))
			if("Cancel") break
			if("Lock a Transformation")
				while(src)
					var/n = input(usr, "Lock which Transformation?") in list("Done") + (AllTransformations - LockedTransformations)
					if(!n || n == "Done") break
					ToggleFormLock(AllTransformations[n])
			if("Unlock a Transformation")
				while(src)
					var/n = input(usr, "Unlock which Transformation?") in list("Done") + LockedTransformations
					if(!n || n == "Done") break
					ToggleFormLock(LockedTransformations[n])

mob/Admin5/verb/TestTransformationLock()
	for(var/i in AllTransformations)
		usr << "[i] is [IsFormLocked(i) ? "" : "not "]locked."

mob/Admin5/verb/GetFormOrderList(mob/M in players)
	for(var/i in M.transOrder)
		if(i) usr << i

mob/Admin5/verb/FixDrainingBug(mob/M in players)
	for(var/t in M.UnlockedTransformations)
		var/transformation/T = M.UnlockedTransformations[t]
		T.ExitForm()
		T.draining = 0
		sleep(world.tick_lag)

mob/Admin4/verb/Manage_Player_Transformations(mob/M in players)
	if(!usr.IsCodedAdmin())
		alert(usr,"stop fucking with this it's not done -.-", "bruh")
		return
	while(usr && M)
		switch(alert(usr, "Do what to [M.name]'s transformations?", "Manage Transformations", "Cancel", "Remove", "Edit"))
			if("Remove") RemoveTransformation(input(usr, "Remove which transformation?", "Remove Transformation") in M.UnlockedTransformations, M)
			if("Edit") EditTransformation(input(usr, "Edit which transformation?", "Edit Transformation") in M.UnlockedTransformations, M)
			if("Cancel") break

mob/proc/RemoveTransformation(t, mob/M)
	if(!t || !M || !(t in M.UnlockedTransformations)) return
	var/transformation/T = M.UnlockedTransformations[t]
	if(!T) return
	T.ExitForm(M)
	M.UnlockedTransformations[t] = null
	M.UnlockedTransformations.Remove(t)
	del(T)

var/list/TransformationFilter = list("tag", "type", "parent_type", "vars", "startupDelay", \
										"mastered", "draining", "restoreIcon", "overlays", "underlays", "effects")
var/list/TransformationVars = list("Name", "Description", "Mastery", "Aura", "Hair")

mob/proc/EditTransformation(trans, mob/M)
	if(!trans || !M) return
	var/transformation/T = M.UnlockedTransformations[trans]
	if(!T) return
	var/html = "<head>[KHU_HTML_HEADER]<title>Edit [T.name]</title></head>"
	html += "<body bgcolor=#000000 text=#339999 link=#99FFFF>"
	html += "<h3>[M.name] | [T.name]</h3>"
	html += "<table width=90% style='padding-left:5%;border-collapse: collapse'>"
	for(var/v in TransformationVars)
		if(v in TransformationFilter) continue
		html += "<tr style='border:3px solid #247373;padding:2px'>"
		html += "<td style='border-left:1px solid #247373'>"
		html += "<a href=byond://?src=\ref[M];action=trans;form=[T.name];var=[v]>"
		html += "[v]</a></td>"
		html += "<td style='border-left:1px solid #247373'>"
		html += "[Value(T.vars[v])]</td></tr>"
	html += "</table></body></html>"
	usr << output(html, "config_browser")
	winshow(usr, "edit_config", 1)
	Log(src, "[key] opened the config menu for [C]")

proc/ToggleFormLock(n)
	if(!ispath(n)) return
	var/transformation/T = new n
	if(T.name in LockedTransformations)
		LockedTransformations.Remove(T.name)
	else
		LockedTransformations[T.name] += n

proc/IsFormLocked(n)
	return n in LockedTransformations

proc/GetTransformation(n)
	if(n in AllTransformations)
		var/t = AllTransformations[n]
		return new t

mob/proc/GetFormMastery(t)
	if(!t || !(t in UnlockedTransformations)) return
	var/transformation/T = UnlockedTransformations[t]
	if(!T) return
	return T.mastery

mob/proc/GetValidFormCount()
	var/count = 0
	for(var/i in AllTransformations)
		var/t = AllTransformations[i]
		var/transformation/T = new t
		if(!T) continue
		if(T.CanAccessForm(src)) count++
	return count

mob/proc/GetUnlockedFormCount()
	return UnlockedTransformations?.len

mob/proc/RemoveInvalidForms()
	for(var/t in UnlockedTransformations)
		var/transformation/T = UnlockedTransformations[t]
		if(!T) continue
		T.ExitForm(src)
		if(!T.CanEnterForm(src))
			RemoveTransformation(t, src)

mob/proc/GetUnlockedTransformation(n)
	if(n in UnlockedTransformations)
		return UnlockedTransformations[n]

mob/proc/TryEnterForm(transformation/T)
	if(!T) return
	var/transformation/CT = GetActiveForm()
	if(!T.CanStackForm(src) && UsingGodFist())
		src << "You can not use this form with God Fist"
		return
	var/canTrans = 1
	if(CT)
		canTrans = 0
		if(CT.ExitForm(src))
			canTrans = 1
	if(canTrans)
		if(formSlotID == 0 || currentForm == "Base")
			ChangeFormSlot(1)
		return T.EnterForm(src)

mob/proc/TryUnlockForm(n, auto_enter = 0)
	if(!n || (n in UnlockedTransformations)) return
	var/t = AllTransformations[n]
	if(!t) return
	var/transformation/T = new t
	if(!T) return
	T.UnlockForm(src)
	if(auto_enter && T.IsFormUnlocked(src))
		TryEnterForm(T)

mob/proc/GetActiveForm()
	var/transformation/T = GetUnlockedTransformation(src.currentForm)
	return T == "Base" ? null : T

mob/proc/ApplyActiveForm()
	TryEnterForm(GetActiveForm())

mob/proc/HasForm(t)
	if(istype(t, /transformation))
		return (t:name in UnlockedTransformations)
	return (t in UnlockedTransformations)

mob/proc/HasActiveForm()
	return GetActiveForm() != null

mob/proc/CanUseForm(name)
	if(!(name in AllTransformations)) return
	var/transformation/T = AllTransformations[name]
	if(!T) return
	return T.CanEnterForm(src)

mob/proc/GetFormFromTransOrder(n)
	return n <= 0 ? "Base" : transOrder[n]

mob/proc/CheckAvailableForms()

mob/proc/TryInspireForm(mob/M)
	if((M.Race in list("Yasai", "Half Yasai")))
		if(!(M.Class in list("Legendary", "Cyborg")))
			var/list/formsToTry = list("Omega Yasai", "Omega Yasai 2", "Omega Yasai 3")
			var/probability = 1.5
			for(var/i in formsToTry)
				if(CanInspire(M, i) && prob(probability))
					M.BecomeInspired(i)
		else if(M.Class == "Legendary")
			if(CanInspire(M, "Legendary Omega Yasai") && prob(0.1))
				M.BecomeInspired("Legendary Omega Yasai")

mob/proc/BecomeInspired(form)
	InspiredTransformations.Add(form)
	SendMsg("You have been inspired further along the path to [form]!", CHAT_IC)

mob/proc/CanInspire(mob/M, form)
	return currentForm == form && HasForm(form) && !M.HasForm(form) && !M.IsInspired(form)

mob/proc/IsInspired(t)
	return (t in InspiredTransformations)

mob/var/list/InspiredTransformations = list()

mob/proc/GetBaseForm()
	if(!transOrder || !transOrder.len) return
	var/t = transOrder[1]
	if(!t || !(t in UnlockedTransformations)) return
	return UnlockedTransformations[t]

mob/proc/AddFormToTransOrder(t)
	if(!t) return
	for(var/i=1, i<=transOrder.len, i++)
		if(!transOrder[i] || transOrder[i] == "")
			transOrder[i] = t
			break

transformation
	var
		name
		desc

		startupDelay
		mastery
		masteryRate = 1
		mastered
		minDrain = 0

		draining = 0
		
		// player icon is changed to base icon while in form, restoreIcon saves their old base for when they revert
		baseIcon
		restoreIcon

		// hair is applied and color given is added (black should give no change)
		hair
		hairColor = rgb(0,0,0)

		// aura is applied for PUing, and scaled to the X/Y values given here
		aura
		auraScaleX
		auraScaleY

		list/overlays = list()
		list/underlays = list()
		list/effects = list()

	proc
		UpdateName(mob/M)

		CanAccessForm(mob/M)
			if(!M) return
			return !IsFormLocked(name)
		
		CanEnterForm(mob/M)
			if(!M) return
			return !IsFormLocked(name)
		
		CanStackForm(mob/M)
			if(!M) return
			return FALSE
		
		UnlockForm(mob/M)
			if(!M) return
			SpecialUnlockEvent(M)
			M.UnlockedTransformations[name] = src
			M.AddFormToTransOrder(src.name)
		
		IsFormUnlocked(mob/M)
			if(!M) return
			return name in M.UnlockedTransformations

		SpecialUnlockEvent(mob/M)

		EnterForm(mob/M)
			if(!M) return
			if(draining) return
			if(mastery >= 100 && !mastered) mastered = 1
			M.currentForm = name
			sleep(startupDelay * GetMasteryDrain())
			ApplySpecialFX(M)
			draining = 1
			ApplyForm(M)
			DrainLoop(M)
			MasteryLoop(M)
			return draining

		ExitForm(mob/M)
			if(!M) return
			if(!draining) return
			RemoveForm(M)
			draining = 0
			M.currentForm = "Base"
			RemoveSpecialFX(M)
			return !draining
		
		ApplyForm(mob/M)
		
		RemoveForm(mob/M)
			if(!M) return
			M.transBPAdd = 0
			M.transStrBonus = 0
			M.transForBonus = 0
			M.transSpdBonus = 0
			M.transDurBonus = 0
			M.transResBonus = 0
			M.transAccBonus = 0
			M.transRefBonus = 0
			M.disableKiRecovery = 0
			M.disableStamRecovery = 0
			M.transBPMult = 1
			M.transStaminaRegen = 1
			M.transRecovRate = 1
			M.transRegenRate = 1
			M.transPUCap = 1

		ApplySpecialFX(mob/M)
			if(!M) return
			if(underlays && islist(underlays) && underlays.len)
				for(var/list/L in underlays)
					var/I = L[1], C = L[2], X = L[3], Y = L[4]
					M.transUnderlays += image(icon = icon(I) + C, pixel_x = X, pixel_y = Y)
				M.underlays.Add(M.transUnderlays)
			if(overlays && islist(overlays) && overlays.len)
				for(var/list/L in overlays)
					var/I = L[1], C = L[2], X = L[3], Y = L[4]
					M.transOverlays += image(icon = icon(I) + C, pixel_x = X, pixel_y = Y)
				M.overlays.Add(M.transOverlays)
			spawn(startupDelay)
				if(M)
					M.overlays.Remove(M.hair)
					if(!hair) hair = M.hair + hairColor
					M.overlays.Add(hair)
			restoreIcon = M.icon
			if(!baseIcon) baseIcon = M.icon
			M.icon = baseIcon

		RemoveSpecialFX(mob/M)
			if(!M) return
			if(restoreIcon) M.icon = restoreIcon
			M.overlays.Remove(hair)
			M.overlays.Add(M.hair)
			if(overlays && overlays.len)
				M.overlays.Remove(M.transOverlays)
				M.transOverlays = new
			if(underlays && underlays.len)
				M.underlays.Remove(M.transUnderlays)
				M.transUnderlays = new

		DrainLoop(mob/M)
	
		MasteryLoop(mob/M)
			set waitfor = FALSE
			set background = TRUE
			while(M && draining)
				var/masteryMult = 1
				if(M.Get_attack_gains())
					masteryMult = 5
					var/mob/O = M.Opponent()
					if(ismob(O) && O.client)
						var/transformation/T = O.GetActiveForm()
						if(T && T.name == src.name && T.mastery > mastery)
							masteryMult += 5
				else if(M.trainState == "Self") masteryMult = 2.5
				else if(M.trainState == "Shadow") masteryMult = 2
				if(M.IsInHBTC() && M.CanGainHBTC()) masteryMult *= 10
				mastery += 0.0015 * masteryRate * masteryMult * M.mastery_mod * Progression.GetSettingValue("Transformation Mastery Rate")
				mastery = Math.Min(mastery, 100)
				sleep(100)
		
		GetMasteryDrain()
			// mastery is a percentage (0 to 100)
			// get a value between min and 1x based on mastery %
			return Math.ValueFromPercentInRange(minDrain, 1, 100 - mastery)
		
		GoNextForm(mob/M)
			if(!M) return
			M.ChangeFormSlot(1)
			var/nextForm = M.GetFormFromTransOrder(M.formSlotID)
			if(!nextForm) return
			M.TryEnterForm(M.GetUnlockedTransformation(nextForm))
		
		GoPreviousForm(mob/M)
			if(!M) return
			M.ChangeFormSlot(-1)
			var/previousForm = M.GetFormFromTransOrder(M.formSlotID)
			if(!previousForm || previousForm == "Base" || M.formSlotID <= 0)
				ExitForm(M)
				return
			M.TryEnterForm(M.GetUnlockedTransformation(previousForm))
		
		GetInfo()
			var/html = "<h3>[name]</h3><p><b>[desc]</b></p>"
			html += "description unfinished"
			html += "<hr>"
			return html

mob/proc/SetTransHairs()
	while(1)
		var/t = input("Choose a transformation to set the hair of.") in list("Done") + UnlockedTransformations
		if(!t || t == "Done") break
		if(t == currentForm)
			alert(src, "You can not customize a form whilst you are in it.")
			break
		var/transformation/T = UnlockedTransformations[t]
		var/icon/I=input("Choose an icon file") as icon|null
		if(!I)
			switch(alert(src, "No icon chosen.  Reset to default?",,"Yes","No"))
				if("No") break
				if("Yes") T.hair = initial(T.hair)
		var/c = rgb(0,0,0)
		switch(alert("Set a custom color?",,"No","Yes"))
			if("Yes") c = input("Choose a color.") as color
		T.hair = I + c

mob/proc/SetTransAuras()
	while(1)
		var/t = input("Choose a transformation to set the aura of.") in list("Done") + UnlockedTransformations
		if(!t || t == "Done") break
		if(t == currentForm)
			alert(src, "You can not customize a form whilst you are in it.")
			break
		var/transformation/T = UnlockedTransformations[t]
		var/icon/I=input("Choose an icon file") as icon|null
		if(!I)
			switch(alert("No icon chosen.  Reset to default?",,"Yes","No"))
				if("No") break
				if("Yes")
					T.aura = initial(T.aura)
					return
		T.aura = (resourceManager.GetResourceName(I) || resourceManager.GenerateDynResource(I))
		UploadedIcons |= T.aura
		var/c = rgb(0,0,0)
		switch(alert("Set a custom color?",,"No","Yes"))
			if("Yes") c = input("Choose a color.") as color
		AddAura(T.name, T.aura, c)

mob/proc/SetTransOverlays()
	while(1)
		var/t = input("Choose a transformation to set the overlays of.") in list("Done") + UnlockedTransformations
		if(!t || t == "Done") break
		if(t == currentForm)
			alert(src, "You can not customize a form whilst you are in it.")
			break
		var/transformation/T = UnlockedTransformations[t]
		switch(input("What do you need to do with the overlays?","Manage Overlays") in list("Done","Add","Remove","Clear All"))
			if("Done") break
			if("Add")
				while(1)
					var/icon/I=input("Choose an icon file") as icon|null
					if(!I) break
					var/c = rgb(0,0,0)
					switch(alert("Set a custom color?",,"No","Yes"))
						if("Yes") c = input("Choose a color.") as color
					var/X = 0
					switch(alert("Set a custom x-offset?",,"No","Yes"))
						if("Yes") X = input("Enter an offset.") as num
					var/Y = 0
					switch(alert("Set a custom x-offset?",,"No","Yes"))
						if("Yes") Y = input("Enter an offset.") as num
					if(!T.overlays || !islist(T.overlays)) T.overlays = new/list()
					T.overlays += list(I, c, X, Y)
					switch(alert("Add another?",,"Yes","No"))
						if("No") break
			if("Remove")
				while(1)
					if(!T.overlays || !T.overlays.len) break
					var/list/choices = new
					for(var/i in T.overlays)
						var/list/L = i
						choices["[L[1]]"] = i
					var/i = input("Select an overlay to remove.") in list("Done") + choices
					if(!i || i == "Done") break
					var/I = choices[i]
					T.overlays -= I
					switch(alert("Remove another?",,"Yes","No"))
						if("No") break
			if("Clear All") T.overlays = new

mob/proc/SetTransUnderlays()
	while(1)
		var/t = input("Choose a transformation to set the underlays of.") in list("Done") + UnlockedTransformations
		if(!t || t == "Done") break
		if(t == currentForm)
			alert(src, "You can not customize a form whilst you are in it.")
			break
		var/transformation/T = UnlockedTransformations[t]
		switch(input("What do you need to do with the underlays?","Manage Underlays") in list("Done","Add","Remove","Clear All"))
			if("Done") break
			if("Add")
				while(1)
					var/icon/I=input("Choose an icon file") as icon|null
					if(!I) break
					var/c = rgb(0,0,0)
					switch(alert("Set a custom color?",,"No","Yes"))
						if("Yes") c = input("Choose a color.") as color
					var/X = 0
					switch(alert("Set a custom x-offset?",,"No","Yes"))
						if("Yes") X = input("Enter an offset.") as num
					var/Y = 0
					switch(alert("Set a custom x-offset?",,"No","Yes"))
						if("Yes") Y = input("Enter an offset.") as num
					if(!T.underlays || !islist(T.underlays)) T.underlays = new/list()
					T.underlays += list(I, c, X, Y)
					switch(alert("Add another?",,"Yes","No"))
						if("No") break
			if("Remove")
				while(1)
					if(!T.underlays || !T.underlays.len) break
					var/list/choices = new
					for(var/i in T.underlays)
						var/list/L = i
						choices["[L[1]]"] = i
					var/i = input("Select an underlay to remove.") in list("Done") + choices
					if(!i || i == "Done") break
					var/I = choices[i]
					T.underlays -= I
					switch(alert("Remove another?",,"Yes","No"))
						if("No") break
			if("Clear All") T.underlays = new

mob/proc/SetTransBaseIcon()
	while(1)
		var/t = input("Choose a transformation to set the base icon of.") in list("Done") + UnlockedTransformations
		if(!t || t == "Done") break
		if(t == currentForm)
			alert(src, "You can not customize a form whilst you are in it.")
			break
		var/transformation/T = UnlockedTransformations[t]
		var/icon/I=input("Choose an icon file") as icon|null
		if(!I) break
		T.baseIcon = I

mob/proc/SetTransEffects()
	while(1)
		var/t = input(src,"Alter opening graphics for which form?") in list("Done") + UnlockedTransformations
		if(!t || t == "Done") break
		if(t == currentForm)
			alert(src, "You can not customize a form whilst you are in it.")
			break
		var/transformation/T = UnlockedTransformations[t]
		if(!T) continue
		switch(input(src,"Which do you want to do?") in list("Create opening transformation graphics",\
		"Remove existing transformation graphics"))
			if("Create opening transformation graphics") T.effects=usr.Add_Trans_Effects(T.effects)
			if("Remove existing transformation graphics") T.effects=usr.Remove_Trans_Effects(T.effects)

mob/var/baseTrans

mob/proc/SetTransOrder()
	if(!UnlockedTransformations || !UnlockedTransformations.len) return
	while(src)
		var/list/L = new/list
		for(var/i=1, i<=transOrder.len, i++)
			L.Add(i)
		var/inp = input(src, "Which transformation slot would you like to set?", "Transformation Order") in list("Cancel", "Clear All", "Set Sequentially") + L
		switch(inp)
			if("Cancel")
				break
			if("Clear All")
				for(var/i=1, i<=transOrder.len, i++)
					transOrder[i] = ""
					sleep(world.tick_lag)
			if("Set Sequentially")
				for(var/i=1, i<=transOrder.len, i++)
					var/shouldContinue = SetTransSlot(i)
					if(!shouldContinue)
						break
					sleep(world.tick_lag)
			else
				SetTransSlot(inp)

mob/proc/SetTransSlot(slot=1)
	var/t = input(src, "Select your [slot]\th transformation.", "Transformation Order") in list("Cancel") + UnlockedTransformations
	if(!t || t == "Cancel") return 0
	transOrder[slot] = t
	return 1

mob/proc/ManageTransformations()
	while(1)
		var/list/choices = list("Cancel", "Transformation Order", "Base Icons", "Hairs", "Auras", "Overlays", "Underlays", "Set Opening Effects")
		switch(input("Manage what aspect?", "Manage Transformations") in choices)
			if("Cancel") break
			if("Transformation Order") SetTransOrder()
			if("Hairs") SetTransHairs()
			if("Auras") SetTransAuras()
			if("Overlays") SetTransOverlays()
			if("Underlays") SetTransUnderlays()
			if("Opening Effects") SetTransEffects()
			if("Base Icons") SetTransBaseIcon()

mob/proc/ListTransStats()
	var/html={"<html><body><body bgcolor="#000000"><font size=2><font color="#CCCCCC">
	<h1>This will show you all the transformations in the game and detail their exact stats. They are listed in no particular order.</h1>
	"}
	for(var/n in AllTransformations)
		var/t = AllTransformations[n]
		var/transformation/T = new t
		if(!T || !istype(T,/transformation)) continue
		html += T.GetInfo()
	src<<browse(html,"window=Transformation Details;size=650x600")
#define REGISTER_VIS 1
#define REGISTER_STD 2
#define REGISTER_OVERLAY 1
#define REGISTER_UNDERLAY 2

atom/var/appearance_handler/appearance_handler = new
appearance_handler
	var/list/registered_visuals
	var/tmp/list/unsaved_visuals
	
	proc
		Register(proxy_visual/V)
			registered_visuals ||= list()
			registered_visuals[V.name] = V
		
		Deregister(register)
			registered_visuals[register] = null
			registered_visuals -= register

		ApplyVisuals(atom/A)
			if(isarea(A)) return
			for(var/i in registered_visuals)
				var/proxy_visual/V = GetVisual(i)
				V?.Apply(A)
		
		ClearVisuals(atom/A)
			if(isarea(A)) return
			A.overlays = list()
			A.underlays = list()
			A:vis_contents = list()
		
		RemoveUnsaved()
			unsaved_visuals ||= list()
			for(var/i in registered_visuals)
				var/proxy_visual/V = GetVisual(i)
				if(!V?.isSaved)
					unsaved_visuals += V
					Deregister(i)

		HideVisual(register)
			var/proxy_visual/V = GetVisual(register)
			V?.isHidden = 1

		ShowVisual(register)
			var/proxy_visual/V = GetVisual(register)
			V?.isHidden = 0
		
		LoadVisual(register, newRegister)
			var/proxy_visual/V = GetVisual(register)
			V?.LoadVisual(newRegister)
		
		GetVisual(register)
			if(!(register in registered_visuals)) return
			return registered_visuals[register]
		
		ListRegisters()
			. = list()
			for(var/i in registered_visuals)
				. += i
	
	Write()
		RemoveUnsaved()
		..()
		for(var/proxy_visual/V in unsaved_visuals)
			Register(V)
		unsaved_visuals = list()

mob/proc/GenerateInitialAppearances()
	set waitfor = FALSE
	set background = TRUE
	sleep(15)
	ClearVisuals()
	AddSwimMask()
	AddTitleDisplay()
	CreateFlightVisuals()
	CreateLevelupEffect()
	AddPlaneMasters()
	if(!GetVisual("Auras")) VisOverlay(CreateGroupVisual("Auras"))
	if(!GetVisual("Hairs")) StdOverlay(CreateGroupVisual("Hairs"))
	if(!GetVisual("Overclothes")) StdOverlay(CreateGroupVisual("Overclothes"))
	if(!GetVisual("Underclothes")) StdOverlay(CreateGroupVisual("Underclothes"))
	ApplyVisuals()

mob/proc/AddPlaneMasters()
	fallingTextMaster = new
	fallingTextMaster.plane = HUD_FALLING_TEXT
	fallingTextMaster.appearance_flags = PLANE_MASTER
	floatingTextMaster = new
	floatingTextMaster.plane = HUD_FLOATING_TEXT
	floatingTextMaster.appearance_flags = PLANE_MASTER

	client.screen.Add(floatingTextMaster, fallingTextMaster)

atom/proc/StdOverlay(proxy_visual/visual)
	if(!visual)
		visual = new
		visual.name = GetBase64ID()
	visual.vis_type = REGISTER_STD
	appearance_handler.Register(visual)
	SetVisual(visual.name)
	return visual

atom/proc/StdUnderlay(proxy_visual/visual)
	if(!visual)
		visual = new
		visual.name = GetBase64ID()
	visual.vis_layer = REGISTER_UNDERLAY
	visual.vis_type = REGISTER_STD
	appearance_handler.Register(visual)
	SetVisual(visual.name)
	return visual

atom/proc/VisOverlay(proxy_visual/visual)
	if(!visual)
		visual = new
		visual.name = GetBase64ID()
	appearance_handler.Register(visual)
	SetVisual(visual.name)
	return visual

atom/proc/VisUnderlay(proxy_visual/visual)
	if(!visual)
		visual = new
		visual.name = GetBase64ID()
	visual.vis_layer = REGISTER_UNDERLAY
	appearance_handler.Register(visual)
	SetVisual(visual.name)
	return visual

atom/proc/HideVisual(register)
	appearance_handler.HideVisual(register)
	ApplyVisuals()

atom/proc/ShowVisual(register)
	appearance_handler.ShowVisual(register)
	ApplyVisuals()

atom/proc/RemoveVisual(register)
	ClearVisuals()
	appearance_handler.Deregister(register)
	ApplyVisuals()

atom/proc/RemoveUnsaved()
	ClearVisuals()
	appearance_handler.RemoveUnsaved()
	ApplyVisuals()

atom/proc/ApplyVisuals()
	ClearVisuals()
	appearance_handler.ApplyVisuals(src)

atom/proc/ClearVisuals()
	appearance_handler.ClearVisuals(src)

atom/proc/SetVisual(register, newRegister)
	ClearVisuals()
	appearance_handler.LoadVisual(register, newRegister)
	ApplyVisuals()

atom/proc/GetVisual(register)
	return appearance_handler.GetVisual(register)

area/StdOverlay()
area/StdUnderlay()
area/VisUnderlay()
area/VisOverlay()
area/HideVisual()
area/ShowVisual()
area/RemoveUnsaved()
area/ApplyVisuals()
area/ClearVisuals()
area/SetVisual()
area/GetVisual()
area/appearance_handler = null
area/icon = null

#ifdef DEBUG
mob/Admin5/verb/TestGetRegisterList()
	set category = "DEBUG"
	set background = TRUE
	for(var/i in appearance_handler.registered_visuals)
		usr << "V.name: [i]"
		var/proxy_visual/V = GetVisual(i)
		usr << "V.type = [V?.type]"

mob/Admin5/verb/GetOverlayList()
	set category = "DEBUG"
	set background = TRUE
	for(var/proxy_visual/V in vis_contents)
		usr << "name: [V.name]"
#endif
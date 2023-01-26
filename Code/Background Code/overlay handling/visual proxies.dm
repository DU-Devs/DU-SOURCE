proxy_visual
	parent_type = /obj
	vis_flags = VIS_INHERIT_ID | VIS_INHERIT_PLANE

	var
		vis_layer = REGISTER_OVERLAY
		vis_type = REGISTER_VIS
		isSaved = 1
		icon_pointer
		isHidden = 0
	
	proc
		LoadVisual()
			if(icon_pointer) icon = resourceManager.GetResourceByName(icon_pointer)
			if(vis_layer == REGISTER_UNDERLAY) src.vis_flags |= VIS_UNDERLAY
			else src.vis_flags &= ~VIS_UNDERLAY

		Apply(atom/A)
			if(isarea(A)) return
			if(!isHidden)
				if(vis_type == REGISTER_VIS)
					A:vis_contents |= src
				else
					if(vis_layer == REGISTER_OVERLAY)
						A.overlays |= src
					if(vis_layer == REGISTER_UNDERLAY)
						A.underlays |= src
	
	Write()
		if(!isSaved) return
		..()

visual_grouper
	parent_type = /proxy_visual
	var/list/visuals = list()
	icon = null

	proc
		Register(proxy_visual/visual)
			visuals ||= list()
			if(!visual) return
			world << visual?.name
			visuals[visual.name] = visual
		
		Deregister(name)
			visuals[name] = null
			visuals -= name
	
	LoadVisual(register)
		if(!register) return
		visuals ||= list()
		var/proxy_visual/visual = visuals[register]
		if(visual)
			visual.LoadVisual()
			icon = visual.icon
			icon_state = visual.icon_state
			vis_layer = visual.vis_layer
			layer = visual.layer
			vis_type = visual.vis_type

proc/CreateGroupVisual(_group)
	var/visual_grouper/G = new(null)
	G.name = _group
	return G
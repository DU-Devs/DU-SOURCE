proxy_visual/hair
	vis_flags = VIS_INHERIT_ID | VIS_INHERIT_PLANE | VIS_INHERIT_DIR | VIS_INHERIT_ICON_STATE
	vis_type = REGISTER_STD

	LoadVisual()
		..()
		layer = MOVABLE_LAYER + 0.5

proc/CreateHair(_name, pointer, _color)
	var/proxy_visual/hair/V = new(null)
	V.name = _name
	V.icon_pointer = pointer
	V.color = list(null, null, null, _color)
	return V

mob/proc/AddHair(_name, pointer, color)
	var/visual_grouper/V = GetVisual("Hairs")
	if(!V) V = StdOverlay(CreateGroupVisual("Hairs"))
	V.Register(CreateHair(_name, pointer, color))

proxy_visual/over_clothing
	vis_flags = VIS_INHERIT_ID | VIS_INHERIT_PLANE | VIS_INHERIT_DIR | VIS_INHERIT_ICON_STATE
	vis_type = REGISTER_STD

	LoadVisual()
		..()
		layer = MOVABLE_LAYER + 0.2

proxy_visual/under_clothing
	vis_flags = VIS_INHERIT_ID | VIS_INHERIT_PLANE | VIS_INHERIT_DIR | VIS_INHERIT_ICON_STATE
	vis_type = REGISTER_STD
	vis_layer = REGISTER_UNDERLAY

	LoadVisual()
		..()
		layer = MOVABLE_LAYER - 0.2

proc/CreateClothing(_name, pointer, over = 1, _color)
	var/proxy_visual/V
	if(over)
		V = new/proxy_visual/over_clothing(null)
		V.name = _name
		V.icon_pointer = pointer
	else
		V = new/proxy_visual/under_clothing(null)
		V.name = _name
		V.icon_pointer = pointer
	V.color = _color
	return V

mob/proc/AddClothes(_name, pointer, over = 1, color)
	var/visual_grouper/V
	if(over)
		V = GetVisual("Overclothes")
		if(!V) V = StdOverlay(CreateGroupVisual("Overclothes"))
	else
		V = GetVisual("Underclothes")
		if(!V) V = StdUnderlay(CreateGroupVisual("Underclothes"))
	V.Register(CreateClothing(_name, pointer, over, color))

proxy_visual/aura
	vis_flags = VIS_INHERIT_ID
	vis_type = REGISTER_VIS

	LoadVisual()
		..()
		layer = MOVABLE_LAYER
		plane = VFX_PLANE

proc/CreateAura(_name, pointer, _color)
	var/proxy_visual/aura/V = new(null)
	V.name = _name
	V.icon_pointer = pointer
	V.color = list(null, null, null, _color)
	return V

mob/proc/AddAura(_name, pointer, color)
	var/visual_grouper/V = GetVisual("Auras")
	if(!V) V = VisOverlay(CreateGroupVisual("Auras"))
	V.Register(CreateAura(_name, pointer, color))

proc/CreateHalo(_color)
	var/proxy_visual/V = new
	V.isSaved = 0
	V.name = "Halo"
	V.icon_pointer = (resourceManager.GetResourceName('Halo.dmi') || resourceManager.GenerateDynResource('Halo.dmi'))
	V.color = list(null, null, null, _color)
	return V

mob/proc/AddHalo()
	StdOverlay(CreateHalo())

mob/proc/RemoveHalo()
	RemoveVisual("Halo")

#ifdef DEBUG
mob/Admin5/verb/TestGiveHair(I as icon|null)
	set category = "DEBUG"
	if(!I) return
	. = (resourceManager.GetResourceName(I) || resourceManager.GenerateDynResource(I))
	AddHair("Base", .)
	SetVisual("Hairs", "Base")
#endif
mob/Admin5/verb/Get_Tier_List()
	usr << "==Tier Reqs=="
	for(var/tier = 1 to 300)
		var/x = GetTierReq(tier)
		usr << "Tier [tier] req: [Commas(x)]"

mob/proc/GetBPTier()
	var/tier = 1
	while(GetTierReq(tier) <= GetRelevantBP())
		tier++
	return Math.Max(tier-1, 1)

mob/proc/GetBaseBPTier()
	var/tier = 1
	while(GetTierReq(tier) <= GetRelevantBaseBP())
		tier++
	return Math.Max(tier-1, 1)

mob/proc/GetRelevantBaseBP()
	return base_bp + (Race == "Android" ? cyber_bp : 0)

mob/proc/GetRelevantBP()
	return GetRelevantBaseBP() + static_bp

mob/proc/GetEffectiveBPTier()
	var/tier = 1
	while(GetTierReq(tier) <= BP)
		tier++
	return tier

proc/GetTierReq(tier)
	return ((tier-1)**5 * (tier/3) + ((tier-1) * 10)) / 2

mob/var/bpTier = 1
mob/var/effectiveBPTier = 1

mob/proc/NewTierGained(vfx = 1)
	GainSkillPoints()
	GainTraitPoints()
	if(vfx) NewTierVFX()

mob/proc/NewTierVFX()
	var/proxy_visual/V = GetVisual("Level Up")
	V.icon_state = ""
	flick("levelup", V)

mob/proc/CreateLevelupEffect()
	var/obj/screen_object/lvlupPlaneMaster = new
	lvlupPlaneMaster.plane = VFX_PLANE + 2
	lvlupPlaneMaster.screen_loc = "1,1"
	lvlupPlaneMaster.alpha = 200
	lvlupPlaneMaster.appearance_flags = PLANE_MASTER | NO_CLIENT_COLOR
	client.screen += lvlupPlaneMaster
	lvlupPlaneMaster.AddFilter("Bloom", filter(type="bloom", rgb(200, 150, 100), 32, 8))
	var/proxy_visual/V = new
	V.name = "Level Up"
	V.vis_flags = VIS_INHERIT_ID
	V.plane = VFX_PLANE + 2
	V.color = rgb(250, 180, 85)
	V.icon = 'LevelUp.dmi'
	CenterIcon(V, x_only = 1)
	VisOverlay(V)

#ifdef DEBUG
mob/verb/TestLevelup()
	set category = "TEST"
	var/proxy_visual/V = GetVisual("Level Up")
	if(V)
		usr << "levelup visual exists"
		V.icon_state = ""
		flick("levelup", V)
#endif
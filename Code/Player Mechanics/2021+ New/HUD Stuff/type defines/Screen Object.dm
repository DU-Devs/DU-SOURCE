obj/screen_object
	name = "screen object"
	appearance_flags = NO_CLIENT_COLOR
	icon = null
	icon_state = "ffsfd"
	var/tmp/client/client

	New(client/_client)
		client = _client
		..()

	Write()
		return
	
	Read()
		return

mob/proc/GenerateHUD()
	if(!client) return
	winshow(src, "Bars", 0)
	client.ClearHUD()
	if(client.buildMode)
		AddBuildButtons()
		client.EnableBuildTabs()
	else
		client.DisableBuildTabs()
		GenerateExpBar()
		GenerateResourceBars()
		GenerateTargetResourceBars()
		GeneratePartyResourceBars()
	hudActive = 1
var/list/fonts = list('fonts/walkthemoon.ttf', 'fonts/walkthemoonital.ttf')

mob/var/tmp/image/targetIcon
mob/var/tmp/obj/senseArrow = new(null)
mob/var/hudColor = "#f98e36"

mob/proc/SetTarget(mob/M)
	if(!M) return
	RemoveTarget()
	Target = M
	if(client && Target != src)
		if(ismob(M))
			targetIcon = image('target.dmi', M)
			targetIcon.pixel_y = -3
			UpdateTargetingColor()
			src.client.screen.Add(senseArrow)
		src.client.images.Add(targetIcon)
		Target.AddResourceCallback(src.Method(/mob/proc/UpdateTargetBars))

mob/proc/RemoveTarget()
	if(client)
		src.client.images.Remove(targetIcon)
		src.client.screen.Remove(senseArrow)
		del(targetIcon)
		Target?.RemoveResourceCallback(src.Method(/mob/proc/UpdateTargetBars))
	Target = null

mob/proc/PowerPct()
	return BPpcnt + (Math.Max(GodFistMult(), 1) - 1) * 100

mob/proc/UpdateSenseArrow()
	set waitfor = 0
	senseArrow.icon = 'arrow.dmi'
	while(client)
		if(Target && ismob(Target) && Target != src && (HasSkill(/obj/Skills/Utility/Sense) || Scouter || Cyber_Scanner) && CanSense(src, Target))
			PointArrow(senseArrow, Target, dist_mod = 0.5)
		sleep(world.tick_lag * 2)

mob/proc/SetHUDColor()
	var/c = input(src, "Pick a color", "Targeting Color") as color
	if(!c) return
	hudColor = c
	SetTarget(Target)

mob/proc/UpdateTargetingColor()
	senseArrow.color = hudColor
	targetIcon.color = hudColor

mob/var/tmp/callback/chain/resourceCallback

mob/proc/SetupCallbacks()
	resourceCallback = new(list(src.Method(/mob/proc/UpdateResourceBars)))

mob/proc/AddResourceCallback(callback/callback)
	if(!callback) return
	resourceCallback = resourceCallback + callback

mob/proc/RemoveResourceCallback(callback/callback)
	if(!callback) return
	resourceCallback = resourceCallback - callback
mob/var/last_anger = 0
mob/var/tmp/cant_anger_until_time = 0

mob/proc/can_anger()
	if(Android && !HasTrait("Emotional Awakening")) return
	if(Giving_Power) return
	if(KO) return
	if(cant_anger_until_time > world.time) return
	if(anger<=100)
		return 1

mob/var/list/anger_reasons=new
mob/proc/Enrage(atom/reason, anger_mult = 1, forced = 0)
	if(!can_anger() && !forced) return
	if(isloc(reason)) reason = reason.name

	if(anger_mult==1)
		for(var/mob/M in player_view(15,src))
			M.SendMsg("<font color=red>[src.name] fills with rage!", CHAT_IC)
	else
		for(var/mob/M in player_view(15,src))
			M.SendMsg("<font color=red>[src.name] becomes extremely enraged!!", CHAT_IC)
	
	AddAngerReason(reason)

	last_anger=world.time
	SetLastAttackedTime()
	anger=100
	
	AngerVFX()

	var/anger_boost = (max_anger - 100) * anger_mult
	anger = Math.Max(anger + anger_boost, 100)
	FullHeal(0)
	UpdateBP()
	TryAngerUnlocks()

	if(!HasTrait("Fueled by Rage")) spawn(400) Calm()

mob/proc/TryAngerUnlocks()
	TryUnlockForm("Omega Yasai", 1)
	TryUnlockForm("Omega Yasai 2", 1)
	TryUnlockForm("Omega Yasai 3", 1)
	TryUnlockForm("Legendary Omega Yasai", 1)

mob/var/angerColor = "#d04949"
mob/proc/AngerVFX()
	set waitfor = FALSE
	set background = TRUE

	var/o = AddFilter("Anger Outline", filter(type = "outline", size = 3, color = angerColor))
	var/f = AddFilter("Anger Ray", filter(type = "rays", size = 32, color = angerColor))
	
	animate(f, offset = 10, size = 64, time = 5)
	animate(offset = 20, size = 32, time = 5)
	animate(offset = 30, size = 128, time = 5)
	animate(offset = 50, size = 0.0001, time = 30)
	animate(offset = 0.0001, size = 0.0001, time = 0)

	animate(o, size = 0.0001, time = 5)
	animate(size = 2, time = 5)
	animate(size = 5, time = 5)
	animate(size = 0.0001, time = 30)

	spawn(50)
		RemoveFilter("Anger Ray")
		RemoveFilter("Anger Outline")

mob/proc/AddAngerReason(reason)
	anger_reasons.len = Math.Max(anger_reasons.len, 3) //initialize list to len 3 in case this is the first time
	anger_reasons.Insert(1,reason)
	anger_reasons.len = Math.Min(anger_reasons.len, 3) //keep it at len 3 max

mob/proc/Calm()
	if(anger>100)
		for(var/mob/M in player_view(15,src))
			M.SendMsg("[src.name] becomes calm.", CHAT_IC)
		last_anger=world.time
	anger=100
	BP = get_bp()

mob/proc/anger_chance(mod=1)

	if(Race=="Android") return 0
	return 100 //because now anger is 100% but only lasts short 1 minute bursts
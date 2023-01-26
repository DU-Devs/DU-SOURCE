var/HBTC_Time=600 //600 seconds, 10 minutes.

mob/var
	Total_HBTC_Time=0
	next_hbtc_use=0
	total_hbtc_uses = 0

var/hbtc_reset_timer = 10 //hours

proc/HBTC_Timer()
	set waitfor = FALSE
	set background = TRUE
	while(1)
		if(HBTC_Time==round(HBTC_Time,60))
			for(var/mob/P in players) if(P.z==10)

				if(P.next_hbtc_use-world.realtime>Time.FromHours(hbtc_reset_timer)) P.next_hbtc_use=0

				if(world.realtime > P.next_hbtc_use && P.Total_HBTC_Time)
					P.next_hbtc_use = world.realtime + (Time.FromHours(hbtc_reset_timer))
					P.Total_HBTC_Time=0
					P.total_hbtc_uses++
				P.Total_HBTC_Time+=Time.FromSeconds(1)
				#ifdef DEBUG
				P << "[P.Total_HBTC_Time] / [Time.FromHours(2)] HBTC time."
				#endif
				P.Age+=0.2
				P.Age_Update()
				P.Gray_Hair()
				P << "<font color=yellow>You have aged one month. Your age is now [round(P.Age,0.1)] years."
				if(P.Total_HBTC_Time >= Time.FromHours(2))
					P << "<font color=yellow>You have gained all you can from training in here for now"
					var/hours = Time.ToHours(P.next_hbtc_use - world.realtime)
					P << "<font color=yellow>You can use the time chamber again in [round(hours,0.01)] hours"

		HBTC_Time--
		sleep(10)

proc/TimeChamberGlobalLoop()
	set waitfor = FALSE
	set background = TRUE
	while(1)
		for(var/mob/M in players)
			if(!M.IsInHBTC()) continue
			M.TimeChamberLoop()
		sleep(50)

mob/Admin5/verb/CheckIfInTimeChamber(mob/M in players)
	usr << "[M.name] is[M.IsInHBTC() ? "" : " not"] in the time chamber."

mob/Admin4/verb/GiveHBTCKey(mob/M in players)
	M.contents.Add(give_hbtc_key())
	M.SendMsg("You have been given an HBTC Key!", CHAT_IC)

mob/var/timeChamberLocked = 0

mob/proc/TimeChamberTick()
	if(timeChamberTime >= Progression.GetSettingValue("HBTC Time Limit") && !timeChamberLocked)
		SendMsg("<span style='color:yellow'>You can use the time chamber again in [Time.ToHours(Progression.GetSettingValue("HBTC Time Limit"))] hours.</span>", CHAT_IC | CHAT_OOC)
		timeChamberLocked = 1
	if(!timeChamberLocked) timeChamberTime += 5
	Age += 0.0005 * ((HasTrait("Chrono-fragility") && !Immortal) ? 10 : 1)
	if(Age == Math.Round(Age, 0.1))
		Age_Update()
		Gray_Hair()

mob/proc/TimeChamberCooldown()
	if(timeChamberTime)
		timeChamberTime -= 0.5
		timeChamberTime = Math.Max(timeChamberTime, 0)
	if(timeChamberLocked && !timeChamberTime)
		timeChamberLocked = 0
	
mob/proc/TimeChamberLoop()
	set waitfor = FALSE
	set background = TRUE
	var/currentAge = Math.Round(Age, 0.1)
	while(IsInHBTC() && CanGainHBTC())
		timeChamberTime += 10
		Age += 0.001 * ((HasTrait("Chrono-fragility") && !Immortal) ? 10 : 1)
		if(currentAge + 0.1 == Age)
			Age_Update()
			Gray_Hair()
			currentAge = Age
		sleep(10)
	if(timeChamberTime >= Progression.GetSettingValue("HBTC Time Limit") && !hbtcCDStarted)
		StartTimeChamberCooldown()
		sleep(1)
		src << "<font color=yellow>You can use the time chamber again in [Progression.GetSettingValue("HBTC Time Limit")] hours"

mob/proc/IsInHBTC()
	return z == 10

mob/proc/CanGainHBTC()
	return !timeChamberLocked

mob/var/hbtcCDRemaining = 0
mob/var/timeChamberTime = 0
mob/var/tmp/hbtcCDStarted = 0
mob/proc/StartTimeChamberCooldown()
	if(hbtcCDStarted) return
	hbtcCDStarted = 1
	if(!hbtcCDRemaining) hbtcCDRemaining = Time.FromHours(10)
	while(hbtcCDRemaining)
		sleep(10)
		if(IsInHBTC()) continue
		hbtcCDRemaining -= 10
	hbtcCDStarted = 0

proc/Zone_Msg(Z=1,T) if(T&&istext(T)) for(var/mob/P in players) if(P.z==Z) P<<T
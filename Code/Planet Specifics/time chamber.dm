var/HBTC_Time=600 //600 seconds, 10 minutes.

mob/var
	Total_HBTC_Time=0
	hbtc_bp=0
	next_hbtc_use=0
	total_hbtc_uses = 0

var/hbtc_reset_timer = 3 //hours

proc/HBTC_Timer() while(1)
	if(HBTC_Time==round(HBTC_Time,60))
		//if(HBTC_Time>0) Zone_Msg(10,"The time chamber will lock in [round(HBTC_Time/60)] minutes")
		for(var/mob/P in players) if(P.z==10)

			if(P.next_hbtc_use-world.realtime>hbtc_reset_timer*60*60*10) P.next_hbtc_use=0

			if(world.realtime > P.next_hbtc_use && P.Total_HBTC_Time)
				P.next_hbtc_use = world.realtime + (hbtc_reset_timer*60*60*10)
				P.Total_HBTC_Time=0
				P.total_hbtc_uses++
			P.Total_HBTC_Time+=0.2
			P.Age+=0.2
			P.Age_Update()
			P.Gray_Hair()
			P << "<font color=yellow>You have aged one month. Your age is now [round(P.Age,0.1)] years."
			if(P.Total_HBTC_Time >= 2)
				P << "<font color=yellow>You have gained all you can from training in here for now"
				var/hours = (P.next_hbtc_use - world.realtime) / 10 / 60 / 60
				P << "<font color=yellow>You can use the time chamber again in [round(hours,0.01)] hours"
	//if(HBTC_Time<=20&&HBTC_Time>0) Zone_Msg(10,"The time chamber will lock in [HBTC_Time] seconds")
	//if(!round(HBTC_Time))
	//	Zone_Msg(10,"The time chamber has locked. The only way out now is if someone opens it from the outside.")
	HBTC_Time--
	sleep(10)

proc/Zone_Msg(Z=1,T) if(T&&istext(T)) for(var/mob/P in players) if(P.z==Z) P<<T
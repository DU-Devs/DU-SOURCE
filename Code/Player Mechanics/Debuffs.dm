/*
the teamer system half the time marks the person defending themself and 1 of the attackers as teamers together,
leaving 1 of the actual teamers at full power, but the defender and the other attacker weakened
	so maybe that has something to do with if both targets are in the attackee list already then
	maybe it needs to have some exception

current teaming effects:
	0.75x health regen
	0.75x energy recov
	take 1.2x more damage
	do 1.2x less damage
	1.2x less accuracy
	1.2x less dodging
*/
mob/var/tmp/is_kiting
var/kiting_penalty=0.34
mob/proc
	Check_if_kiting(turf/old_loc)
		if(!client) return //npcs can not become kiters
		if(!Opponent||!Opponent.client||Opponent.KO||Opponent.z!=z||getdist(src,Opponent)<=4||\
		getdist(src,Opponent)>=55||Opponent.get_area()!=get_area())
			Reset_kiting()
			return
		if(old_loc&&getdist(old_loc,Opponent)>=getdist(src,Opponent))
			Reset_kiting()
			return
		if(is_kiting) return
		if(old_loc) //signifies this proc was called from zanzoken
			is_kiting=1
			//Tens("<font color=red>[src] is now kiting [Opponent]")
	Reset_kiting()
		if(!is_kiting) return
		is_kiting=0
		//Tens("<font color=cyan>[src] is no longer kiting")




mob/var/tmp
	is_teamer
	teamer_loop_running
	backlog_loop_running

	//this is a list of who you attacked and HOW LONG AGO you attacked them
	list/recent_attackees=new

	//this is different from attack backlog because this stores information about each individual hit and what time it happened
	//when attack_backlog was made, there was no need to keep track of this, so all it did was keep track of total hits
	list/attack_log=new
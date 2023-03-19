var
	villain_league_member_count=0
	villain_league_unique_member_count=0
	villain_league_id

mob/var
	left_villain_league_time=0

proc/Count_villain_league_members()
	villain_league_member_count=0
	if(!sagas||!villain) return 0
	var/n=0
	villain_league_id=null
	for(var/obj/League/L in all_leagues)
		if(L.league_leader==villain)
			if(!villain_league_id) villain_league_id=L.league_id
			if(villain_league_id && L.league_id==villain_league_id) n++
	return n

proc/Count_villain_league_unique_members()
	villain_league_unique_member_count=0
	if(!sagas||!villain) return 0
	var/n=0
	villain_league_id=null
	var/list/CIDs=new
	for(var/obj/League/L in all_leagues)
		if(L.league_leader==villain)
			if(!villain_league_id) villain_league_id=L.league_id
			if(villain_league_id && L.league_id==villain_league_id)
				var/mob/m=L.loc
				if(m && ismob(m) && m.client && !(m.client.computer_id in CIDs))
					CIDs+=m.client.computer_id
					n++
	return n

mob/proc/Villain_league_damage_multiplier(mob/target)
	if(target == src) return 1
	if(!client||!sagas||villain!=key||!league_list.len||!target||!target.client||!target.league_list.len||\
	!villain_league_id) return 1
	var/mult=10
	if(world.realtime-target.left_villain_league_time<1.5*60*60*10) return mult
	for(var/obj/League/L in target.league_list) if(L.league_id==villain_league_id) return mult
	return 1


proc/Villain_league_member_count_loop()
	set waitfor=0
	while(1)
		villain_league_member_count=Count_villain_league_members()
		villain_league_unique_member_count=Count_villain_league_unique_members()
		sleep(60*10)

var
	villain_paycheck_loop_timer=10
	villain_paycheck_base_amount=1300000

proc/Villain_league_paycheck_amount()
	var/n=villain_paycheck_base_amount
	n+=villain_league_unique_member_count * villain_paycheck_base_amount * 0.05
	n*=Resource_Multiplier
	return n

proc/League_paychecks()
	set waitfor=0
	sleep(600)
	while(1)
		if(sagas && villain && villain_league_id)
			var/list/CIDs=new
			var/paycheck=Villain_league_paycheck_amount()
			for(var/obj/League/L in all_leagues) if(L.league_leader==villain && L.league_id==villain_league_id)
				var/mob/m=L.loc
				if(ismob(m) && m.client)
					if(m.key==villain)
						if(villain_league_unique_member_count)
							var/villain_pay=500000*villain_league_unique_member_count
							m.Alter_Res(villain_pay)
							m<<"<font color=cyan>You have recieved [Commas(villain_pay)] resources for the activities of your league members"
					else if(!(m.client.computer_id in CIDs))
						CIDs+=m.client.computer_id
						m.Alter_Res(paycheck)
						m<<"<font color=cyan>You have recieved a [Commas(paycheck)] resource paycheck from being a henchman in the \
						main villain's empire"
		sleep(villain_paycheck_loop_timer*600)
proc/Player_Count()
	var/Amount=0
	for(var/mob/P in players) if(P.client) Amount+=1
	return Amount

proc/unique_players()
	var/list/ips=new
	var/count=0
	for(var/mob/m in players) if(m.client&&m.client.address&&!(m.client.address in ips))
		count++
		ips+=m.client.address
	return count


var/list/Server_Ratings=new
mob/proc/Rate_Server(N=0)
	if(!N||!client) return
	Server_Ratings[client.computer_id]=list("Rating"=N,"Expire"=world.realtime+(4*24*60*60*10))
proc/Server_Rating()
	var/N=0
	for(var/V in Server_Ratings)
		var/list/L=Server_Ratings[V]
		if(world.realtime>L["Expire"]) Server_Ratings-=V
		else N+=L["Rating"]
	if(!N) return "(no rating)"
	if(N>0) return "+[N]"
	else return N


var/list/Already_Voted=new

proc/Update_Already_Voted_List()
	for(var/A in Already_Voted) if(Already_Voted[A]<=world.realtime/10/60/60) Already_Voted-=A

mob/proc/Can_Vote(obj/Voting/V)
	if(IsAdmin()) return 1
	var/Vote_Timer=6 //hours
	Update_Already_Voted_List()
	/*if(Player_Count()<20)
		src<<"There must be at least 20 players on to start a vote"
		return*/
	if(Already_Voted[client.computer_id]&&world.realtime/10/60/60<Already_Voted[client.computer_id])
		src.SendMsg("You can not use this for another [round(Vote_Time_Remaining(),0.1)] hours", CHAT_IC)
		return
	Already_Voted[client.computer_id]=(world.realtime/10/60/60)+Vote_Timer
	return 1

mob/proc/Vote_Time_Remaining() return Already_Voted[client.computer_id]-(world.realtime/10/60/60)

var/list/Council=new //keys

mob/proc/Council_Check()
	if(locate(/obj/RP_Council) in src) if(!(key in Council)) Council+=key
	if(key in Council) if(!(locate(/obj/RP_Council) in src)) contents+=new/obj/RP_Council
mob/proc/Add_Council()
	if(!(key in Council)) Council+=key
	if(!(locate(/obj/RP_Council) in src)) contents+=new/obj/RP_Council
mob/proc/Remove_Council()
	Council-=key
	for(var/obj/RP_Council/R in src) del(R)
proc/Online_Council_Members()
	var/list/L=new
	for(var/V in Council) for(var/mob/P in players) if(P.key==V) L+=P.key
	return L
proc/Offline_Council_Members()
	var/list/L=new
	for(var/V in Council)
		L+=V
		for(var/mob/P in players) if(P.key==V) L-=V
	return L
obj/RP_Council
	desc="Council members have a boost verb which grants a small boost to a person of their choosing. The verb has \
	a timer before it can be used again. Use Boost as often as it lets you, while at the same time not boosting \
	nubs and abusers. The boost is small you shouldn't be restrictive, this isn't some elitist thing. It only \
	requires basic decent RP to earn a boost. If your not around any RP you can boost someone based on their \
	reputation as a good RPer, which you would base on their past RPs that you saw. But preferably you should \
	use it on RPs that are actually going on in front of you. Just give it to the most deserving person \
	available. If the RP President tells you anything contradicting this, have them voted out. Especially if they \
	get very restrictive with boosting."
	var/Next_Use=0
	verb/Council_Chat(A as text)
		set category="Other"
		var/Tag="Council"
		if(Social.GetSettingValue("RP President")==usr.key) Tag="President"
		RP_Council_Msg("([Tag])<font color=[usr.TextColor]>[usr.key]: [html_encode(A)]")
	verb/Boost()
		set category="Other"
		if(world.realtime<Next_Use)
			usr.SendMsg("You can use this again in [round((Next_Use-world.realtime)/(1*60*60*10),0.01)] hours", CHAT_IC)
			return
		Next_Use=world.realtime+(1*60*60*10);var/list/Choices=new;Choices+="Cancel"
		for(var/mob/P in players) Choices+=P
		var/mob/P=input("Choose who you will give a BP boost to") in Choices
		if(P=="Cancel")
			Next_Use=0;return
		if(!P.client)
			usr<<"That is not a player"
			return
		if(usr.client.address==P.client.address)
			world<<"[usr.key] was removed from the RP Council for trying to boost themselves."
			usr.Remove_Council()
			return
		/*if(locate(/obj/RP_Council) in P)
			usr<<"Members of the RP Council cannot be boosted."
			return*/
		//P.Attack_Gain(1*60*60,P,apply_hbtc_gains=0,include_weights=0) //the first number is how many hours of gains
		P.ClosePowerGapBy(0.1)
		RP_Council_Msg("[usr] gave [P] an RP boost")
		Admin_Msg("[usr] gave [P] an RP boost (RP Council)")
proc/RP_Council_Msg(M) for(var/mob/P in players) if((locate(/obj/RP_Council) in P)) P<<M
obj/RP_President
	desc="The job of the RP President is to form an RP Council which should consist of NO LESS than 20% of the \
	current online population at all times. Preferably the 20% that are in the council should be the BEST 20% of \
	roleplayers. It is also the RP President's job to make the Council Members do their jobs or either remove \
	them. 20% is about the right balance, but no less than 20%. Players, if the RP President does not do their job \
	of forming a competent council of at least 20% of the online players at all times, vote for them to be \
	replaced."
	verb/President_Options()
		set category="Other"
		switch(input("Choose an option") in list("Cancel","Add Member","Remove Member","Set Hero Spotlight"))
			if("Cancel") return
			if("Add Member")
				var/list/Choices=list("Cancel")
				for(var/mob/P in players) if(!(P.key in Council)) Choices+=P.key
				var/mob/P=input("Choose the key of the person to add to the RP Council") in Choices
				for(var/mob/M in players) if(M.key==P) P=M
				if(P=="Cancel"||!P) return
				P.Add_Council()
				RP_Council_Msg("President [usr.key] put [P.key] in the RP Council")
			if("Remove Member")
				var/list/Choices=list("Cancel")
				for(var/V in Council) Choices+=V
				var/mob/P=input("Choose the key of the person to remove from the RP Council") in Choices
				if(P=="Cancel"||!P) return
				Council-=P
				for(var/mob/M in players) if(M.key==P) M.Remove_Council()
				RP_Council_Msg("President [usr.key] removes [P] from the RP Council")
mob/proc/RP_President()
	Remove_RP_President()
	if(key==Social.GetSettingValue("RP President")&&(!(locate(/obj/RP_President) in src)))
		contents+=new/obj/RP_President

mob/proc/Remove_RP_President()
	if(key!=Social.GetSettingValue("RP President"))
		for(var/obj/RP_President/R in src)
			del(R)

var/Head_Admin
var/list/Vote_Banned=new

mob/proc/Add_Voting()
	if(key in Vote_Banned) return
	if(client&&(client.address in Vote_Banned)) return
	if(!(locate(/obj/Voting) in src)) contents+=new/obj/Voting
mob/proc/Vote_Banned() if((key in Vote_Banned)||(client&&(client.address in Vote_Banned))) return 1
Voting/var
	Yes=0;No=0
mob/proc/Ignore(Vote_Initiator) if(ignore_votes&&Vote_Initiator!="EXGenesis") return 1
mob/var/ignore_votes=1
obj/Voting
	var/Next_Use=0
	hotbar_type="Other"
	can_hotbar=1
	//var/Ignore=1
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Voting()
	verb/Voting()
		set category="Other"

		usr << "<font color=cyan>Voting has been disabled by admins"
		return

		var/list/Options=new
		Options.Add("Cancel","Vote for President","Custom Vote")
		//Options+="Rate server"
		if(usr.ignore_votes) Options+="Stop Ignoring Votes"
		else Options+="Ignore Votes"

		Options -= "Vote for President"

		switch(input("You can vote for a new RP President or vote to remove another person's voting powers, or to give someone \
		their voting powers back. Or other things.") in Options)
			if("Cancel") return
			if("Ignore Votes") usr.ignore_votes=1
			if("Stop Ignoring Votes") usr.ignore_votes=0
			if("Custom Vote")
				alert(usr,"A custom vote is when you want to start a vote for something other than the preset options. \
				For instance, voting on a new game suggestion. Or whether a certain person should get a rank.")
				if(!usr.Can_Vote(src)) return
				var/Voting/V=new;var/Vote_Initiator=usr.displaykey;
				var/Voting_On=input("Type what this vote is all about. Other players will get a prompt and will see \
				what you type here. They will then vote on it.") as text
				Voting_On=copytext(Voting_On,1,500)
				var/Timer=60
				var/list/Voted=new //List of IPs who have already voted
				spawn for(var/mob/P in players) spawn if(P&&P.client&&!P.Vote_Banned()&&!(P.client.address in Voted)&&!P.Ignore(Vote_Initiator))
					Voted+=P.client.address
					switch(input(P,"[Vote_Initiator] has started a vote for: [Voting_On]. Vote on this if you wish. \
					There is only [Timer] seconds before the vote ends.") in \
					list("Don't Vote","No","Yes"))
						if("No") if(usr) V.No+=1
						if("Yes") if(usr) V.Yes+=1
				spawn(Timer*10) if(usr)
					world<<"<font color=red>Vote Purpose: [Voting_On]"
					world<<"Vote Results:<br>Yes: [V.Yes]<br>No: [V.No]"

			if("Vote for President")
				if(!usr.Can_Vote(src)) return
				var/Voting/V=new;var/Vote_Initiator=usr.displaykey;var/list/Candidates=new;Candidates+="Cancel"
				for(var/mob/P in players) Candidates+=P.key
				var/Candidate_Key=input("Choose a candidate you want to be president") in Candidates
				if(Candidate_Key=="Cancel") return
				var/Timer=60
				var/list/Voted=new //List of IPs who have already voted
				spawn for(var/mob/P in players) spawn if(P&&P.client&&!P.Vote_Banned()&&!(P.client.address in Voted)&&!P.Ignore(Vote_Initiator))
					Voted+=P.client.address
					switch(input(P,"[Vote_Initiator] has started a vote \
					to choose a new RP \
					President. The new candidate is [Candidate_Key]. Do you want this candidate to replace the current RP President \
					([Social.GetSettingValue("RP President")])? There is only [Timer] seconds before the vote ends.") in list("Don't Vote","No","Yes"))
						if("No") if(usr) V.No+=1
						if("Yes") if(usr) V.Yes+=1
				spawn(Timer*10) if(usr)
					world<<"Vote Results:<br>Yes: [V.Yes]<br>No: [V.No]"
					if(V.Yes==V.No) world<<"The result was a tied for [Candidate_Key] as RP President. Vote Failed."
					else if(V.Yes+V.No<10) world<<"Less than 10 voted for [Candidate_Key] as RP President. Vote Failed."
					else if(V.Yes+V.No<(unique_players()*0.15))
						world<<"Less than 15% of the population voted for [Candidate_Key] as RP President. Vote Failed."
					else if(V.Yes>=(V.Yes+V.No)*0.7)
						Social.SetValue("RP President", Candidate_Key)
						for(var/mob/P in players)
							if(P.key==Social.GetSettingValue("RP President")) P.RP_President()
							else P.Remove_RP_President()
						world<<"At least 70% were in favor. [Candidate_Key] is now RP President."
					else world<<"Less than 70% were in favor of [Candidate_Key] for RP President. Vote Failed."
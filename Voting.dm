proc/Player_Count()
	var/Amount=0
	for(var/mob/P in Players) if(P.client) Amount+=1
	return Amount
proc/unique_players()
	var/list/ips=new
	var/count=0
	for(var/mob/m in Players) if(m.client&&m.client.address&&!(m.client.address in ips))
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
	if(Is_Admin()) return 1
	var/Vote_Timer=0.5 //hours
	Update_Already_Voted_List()
	if(Player_Count()<20)
		src<<"There must be at least 20 players on to start a vote"
		return
	if(Already_Voted[client.computer_id]&&world.realtime/10/60/60<Already_Voted[client.computer_id])
		src<<"You can not use this for another [round(Vote_Time_Remaining(),0.1)] hours"
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
mob/var/Monitoring_Council
/*mob/verb/Monitor_Council()
	set category="Other"
	Monitoring_Council=!Monitoring_Council
	if(Monitoring_Council) src<<"You are now monitoring the RP Council's actions"
	else src<<"You stop monitoring the RP Council's actions"*/
/*mob/verb/Council_Who()
	set category="Other"
	src<<"RP President: [RP_President]<br>\
	RP Council Members:"
	for(var/V in Online_Council_Members()) src<<"[V] (Online)"
	for(var/V in Offline_Council_Members()) src<<V*/
proc/Online_Council_Members()
	var/list/L=new
	for(var/V in Council) for(var/mob/P in Players) if(P.key==V) L+=P.key
	return L
proc/Offline_Council_Members()
	var/list/L=new
	for(var/V in Council)
		L+=V
		for(var/mob/P in Players) if(P.key==V) L-=V
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
		if(RP_President==usr.key) Tag="President"
		RP_Council_Msg("<font size=1>([Tag])<font color=[usr.TextColor]>[usr.key]: [html_encode(A)]")
	verb/Boost()
		set category="Other"
		if(world.realtime<Next_Use)
			usr<<"You can use this again in [round((Next_Use-world.realtime)/(1*60*60*10),0.01)] hours"
			return
		Next_Use=world.realtime+(1*60*60*10);var/list/Choices=new;Choices+="Cancel"
		for(var/mob/P in Players) Choices+=P
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
		P.Attack_Gain(1*60*60,P) //the first number is how many hours of gains
		RP_Council_Msg("[usr] gave [P] an RP boost")
		Admin_Msg("[usr] gave [P] an RP boost (RP Council)")
proc/RP_Council_Msg(M) for(var/mob/P in Players) if((locate(/obj/RP_Council) in P)||P.Monitoring_Council) P<<M
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
			if("Set Hero Spotlight")
				usr<<"You -need- to read this if you are the RP President."
				usr<<"You can shine the spotlight on 1 person at a time. It does not give that person any sort of boost, but it \
				increases their 'luck', for example: They have more chance to have anger activate, they adapt (leech bp) faster. It \
				doesn't gaurantee that person victory, but it helps them be the hero that you think they deserve to be. So \
				shine it on someone who deserves to be the hero."
				var/mob/P=input("Choose who to shine the spotlight on.") in Players
				RP_Council_Msg("President [usr.key] is now shining the Hero Spotlight on [P] ([P.key])")
				Hero=P.key
				Save_Hero()
			if("Add Member")
				var/list/Choices=list("Cancel")
				for(var/mob/P in Players) if(!(P.key in Council)) Choices+=P.key
				var/mob/P=input("Choose the key of the person to add to the RP Council") in Choices
				for(var/mob/M in Players) if(M.key==P) P=M
				if(P=="Cancel"||!P) return
				P.Add_Council()
				RP_Council_Msg("President [usr.key] put [P.key] in the RP Council")
			if("Remove Member")
				var/list/Choices=list("Cancel")
				for(var/V in Council) Choices+=V
				var/mob/P=input("Choose the key of the person to remove from the RP Council") in Choices
				if(P=="Cancel"||!P) return
				Council-=P
				for(var/mob/M in Players) if(M.key==P) M.Remove_Council()
				RP_Council_Msg("President [usr.key] removes [P] from the RP Council")
mob/proc/RP_President()
	Remove_RP_President()
	if(key==RP_President&&(!(locate(/obj/RP_President) in src))) contents+=new/obj/RP_President
mob/proc/Remove_RP_President() if(key!=RP_President) for(var/obj/RP_President/R in src) del(R)
var/Head_Admin;var/RP_President;var/list/Vote_Banned=new
mob/proc/Add_Voting()
	if(key in Vote_Banned) return
	if(client.address in Vote_Banned) return
	if(!(locate(/obj/Voting) in src)) contents+=new/obj/Voting
mob/proc/Vote_Banned() if((key in Vote_Banned)||(client&&(client.address in Vote_Banned))) return 1
Voting/var
	Yes=0;No=0
mob/proc/Ignore() for(var/obj/Voting/V in src) if(V.Ignore) return 1
obj/Voting
	var/Next_Use=0
	var/Ignore=1
	verb/Voting()
		set category="Other"
		var/list/Options=new
		Options.Add("Cancel","Vote for President","Remove Voting Power","Restore Voting Power",\
		"Vote Head Admin","Remove All Admins","Vote to Ban","Custom Vote","Vote for SSj")
		if(Can_Pwipe_Vote) Options+="Vote for Pwipe"
		Options+="Rate server"
		if(Ignore) Options+="Stop Ignoring Votes"
		else Options+="Ignore Votes"
		if(PVP) Options.Remove("Vote Head Admin")
		if(!Allow_Ban_Votes) Options-="Vote to Ban"
		switch(input("You can vote for a new RP President or vote to remove another person's voting powers, or to give someone \
		their voting powers back. Or other things.") in Options)
			if("Cancel") return
			if("Ignore Votes") Ignore=1
			if("Stop Ignoring Votes") Ignore=0
			if("Rate server")
				switch(alert("You can rate a server as good or bad. The rating will show other player's what the majority \
				opinion of this server is.","Options","Cancel","Good server","Bad server"))
					if("Cancel") return
					if("Good server") usr.Rate_Server(1)
					if("Bad server") usr.Rate_Server(-1)
			if("Vote for SSj")
				if(!usr.Can_Vote(src)) return
				var/Voting/V=new;var/Vote_Initiator=usr.key;var/list/Candidates=new;Candidates+="Cancel"
				for(var/mob/P in Players) if(P.Race=="Yasai") Candidates+=P.key
				var/Candidate_Key=input("Choose who will gain the new SSj level") in Candidates
				if(Candidate_Key=="Cancel") return
				var/Timer=60
				var/list/Voted=new //List of IPs who have already voted
				spawn for(var/mob/P in Players) spawn if(P&&P.client&&!P.Vote_Banned()&&!(P.client.address in Voted)&&!P.Ignore())
					Voted+=P.client.address
					if(!Admins[P.key]) switch(input(P,"[Vote_Initiator] has started a vote \
					to [Candidate_Key] a new SSj level. There is only [Timer] seconds before the vote ends.") in \
					list("Don't Vote","No","Yes"))
						if("No") if(usr) V.No+=1
						if("Yes") if(usr) V.Yes+=1
				spawn(Timer*10) if(usr)
					world<<"Vote Results:<br>Yes: [V.Yes]<br>No: [V.No]"
					if(V.Yes==V.No) world<<"The result was a tied for [Candidate_Key] to get a new SSj level. Vote Failed."
					else if(V.Yes+V.No<10) world<<"Less than 10 voted for [Candidate_Key] as SSj. Vote Failed."
					else if(V.Yes+V.No<unique_players()*0.3)
						world<<"Less than 30% of the population voted for [Candidate_Key] as SSj. Vote Failed."
					else if(V.Yes>=(V.Yes+V.No)*0.7)
						world<<"At least 70% were in favor. [Candidate_Key] has attained a new SSj level."
						var/mob/M
						for(var/mob/MM in Players) if(MM.key==Candidate_Key) M=MM
						if(!M.SSjAble)
							M.SSj()
						else if(!M.SSj2Able)
							M.SSj()
							M.SSj2()
						else if(!M.SSj3Able)
							M.SSj()
							M.SSj2()
							M.SSj3()
						else if(!M.SSj4Able)
							M.Revert()
							M.SSj4()
					else world<<"Less than 70% were in favor of [Candidate_Key] gaining a new SSj level. Vote Failed."
			if("Custom Vote")
				alert(usr,"A custom vote is when you want to start a vote for something other than the preset options. \
				For instance, voting on a new game suggestion. Or whether a certain person should get a rank.")
				if(!usr.Can_Vote(src)) return
				var/Voting/V=new;var/Vote_Initiator=usr.key;
				var/Voting_On=input("Type what this vote is all about. Other players will get a prompt and will see \
				what you type here. They will then vote on it.") as text
				var/Timer=60
				var/list/Voted=new //List of IPs who have already voted
				spawn for(var/mob/P in Players) spawn if(P&&P.client&&!P.Vote_Banned()&&!(P.client.address in Voted)&&!P.Ignore())
					Voted+=P.client.address
					switch(input(P,"[Vote_Initiator] has started a vote for: [Voting_On]. Vote on this if you wish. \
					There is only [Timer] seconds before the vote ends.") in \
					list("Don't Vote","No","Yes"))
						if("No") if(usr) V.No+=1
						if("Yes") if(usr) V.Yes+=1
				spawn(Timer*10) if(usr)
					world<<"<font color=red>Vote Purpose: [Voting_On]"
					world<<"Vote Results:<br>Yes: [V.Yes]<br>No: [V.No]"
			if("Vote to Ban")
				if(!usr.Can_Vote(src)) return
				var/Voting/V=new;var/Vote_Initiator=usr.key;
				var/list/Bannables=list("Cancel")
				for(var/mob/P in Players) Bannables+=P
				var/mob/M=input("Who do you want to have banned?") in Bannables
				if(!M||M=="Cancel") return
				var/Key=M.key
				var/IP=M.client.address
				var/CID=M.client.computer_id
				var/Timer=60
				var/list/Voted=new //List of IPs who have already voted
				spawn for(var/mob/P in Players) spawn if(P&&!P.Vote_Banned()&&P.client&&!(P.client.address in Voted)&&!P.Ignore())
					Voted+=P.client.address
					switch(input(P,"[Vote_Initiator] has started a vote \
					to ban [M.key]. Do you want this? There is only [Timer] seconds before the vote ends.") in \
					list("Don't Vote","No","Yes"))
						if("No") if(usr) V.No+=1
						if("Yes") if(usr) V.Yes+=1
				spawn(Timer*10) if(usr)
					world<<"Vote Results:<br>Yes: [V.Yes]<br>No: [V.No]"
					if(V.Yes==V.No) world<<"The result was a tied to ban [Key]. Vote Failed."
					else if(V.Yes+V.No<10) world<<"Less than 10 voted to ban [Key]. Vote Failed."
					else if(V.Yes+V.No<unique_players()*0.3)
						world<<"Less than 30% of the population voted to ban [Key]. Vote Failed."
					else if(V.Yes>=(V.Yes+V.No)*0.7)
						world<<"At least 70% were in favor."
						Apply_Ban(M,24,Key,"player vote","player vote",IP,CID)
					else world<<"Less than 70% were in favor of banning [Key]. Vote Failed."
			if("Vote for Pwipe")
				if(Year<20)
					usr<<"This cannot be done until year 20"
					return
				if(!usr.Can_Vote(src)) return
				var/Voting/V=new;var/Vote_Initiator=usr.key;
				switch(input("You are about to start a vote to erase all player saves. Continue?") in list("Yes","No"))
					if("No") return
				var/Timer=60
				var/list/Voted=new //List of IPs who have already voted
				spawn for(var/mob/P in Players) spawn if(P&&!P.Vote_Banned()&&!(P.client.address in Voted)&&!P.Ignore())
					Voted+=P.client.address
					switch(input(P,"[Vote_Initiator] has started a vote \
					to PWIPE. Do you want this? There is only [Timer] seconds before the vote ends.") in \
					list("Don't Vote","No","Yes"))
						if("No") if(usr) V.No+=1
						if("Yes") if(usr) V.Yes+=1
				spawn(Timer*10) if(usr)
					world<<"Vote Results:<br>Yes: [V.Yes]<br>No: [V.No]"
					if(V.Yes==V.No) world<<"The result was a tied for a pwipe. Vote Failed."
					else if(V.Yes+V.No<10) world<<"Less than 10 voted for a pwipe. Vote Failed."
					else if(V.Yes+V.No<unique_players()*0.3)
						world<<"Less than 30% of the population voted for a pwipe. Vote Failed."
					else if(V.Yes>=(V.Yes+V.No)*0.7)
						world<<"At least 70% were in favor. Erasing all player saves."
						Wipe()
					else world<<"Less than 70% were in favor of a pwipe. Vote Failed."
			if("Remove All Admins")
				if(!usr.Can_Vote(src)) return
				var/Voting/V=new;var/Vote_Initiator=usr.key;
				switch(input("You are about to start a vote to remove all admins. Continue?") in list("Yes","No"))
					if("No") return
				var/Bans=0
				for(var/B in Bans) if(B!="Cancel") Bans+=1
				Bans=round(Bans/4)
				V.Yes+=Bans
				var/Timer=60
				var/list/Voted=new //List of IPs who have already voted
				spawn for(var/mob/P in Players) spawn if(P&&!P.Vote_Banned()&&!(P.client.address in Voted)&&!P.Ignore())
					Voted+=P.client.address
					if(!Admins[P.key]) switch(input(P,"[Vote_Initiator] has started a vote \
					to remove all admins. Do you want this? There is only [Timer] seconds before the vote ends.") in \
					list("Don't Vote","No","Yes"))
						if("No") if(usr) V.No+=1
						if("Yes") if(usr) V.Yes+=1
				spawn(Timer*10) if(usr)
					world<<"Vote Results:<br>Yes: [V.Yes]<br>No: [V.No]"
					if(V.Yes==V.No) world<<"The result was a tied to remove all admins. Vote Failed."
					else if(V.Yes+V.No<10) world<<"Less than 10 voted to remove all admins. Vote Failed."
					else if(V.Yes+V.No<unique_players()*0.3)
						world<<"Less than 30% of the population voted to remove all admins. Vote Failed."
					else if(V.Yes>=(V.Yes+V.No)*0.7)
						world<<"At least 70% were in favor. All admins removed."
						Remove_All_Admins()
					else world<<"Less than 70% were in favor of removing all admins. Vote Failed."
			if("Vote Head Admin")
				if(!usr.Can_Vote(src)) return
				var/Voting/V=new;var/Vote_Initiator=usr.key;var/list/Candidates=new;Candidates+="Cancel"
				for(var/mob/P in Players) Candidates+=P.key
				var/Candidate_Key=input("Choose a candidate you want to be Head Admin") in Candidates
				if(Candidate_Key=="Cancel") return
				var/Timer=60
				var/list/Voted=new //List of IPs who have already voted
				spawn for(var/mob/P in Players) spawn if(P&&!P.Vote_Banned()&&!(P.client.address in Voted)&&!P.Ignore())
					Voted+=P.client.address
					if(!Admins[P.key]) switch(input(P,"[Vote_Initiator] has started a vote \
					to choose a new Head Admin. The new candidate is [Candidate_Key]. Do you want this candidate to replace the \
					current Head Admin ([Head_Admin])? There is only [Timer] seconds before the vote ends.") in \
					list("Don't Vote","No","Yes"))
						if("No") if(usr) V.No+=1
						if("Yes") if(usr) V.Yes+=1
				spawn(Timer*10) if(usr)
					world<<"Vote Results:<br>Yes: [V.Yes]<br>No: [V.No]"
					if(V.Yes==V.No) world<<"The result was a tied for [Candidate_Key] as Head Admin. Vote Failed."
					else if(V.Yes+V.No<10) world<<"Less than 10 voted for [Candidate_Key] as Head Admin. Vote Failed."
					else if(V.Yes+V.No<unique_players()*0.3)
						world<<"Less than 30% of the population voted for [Candidate_Key] as Head Admin. Vote Failed."
					else if(V.Yes>=(V.Yes+V.No)*0.7)
						Head_Admin=Candidate_Key
						for(var/mob/P in Players)
							if(P.key==Head_Admin) P.Give_Admin(4)
							else P.Remove_Head_Admin()
						world<<"At least 70% were in favor. [Candidate_Key] is now Head Admin."
					else world<<"Less than 70% were in favor of [Candidate_Key] for Head Admin. Vote Failed."
			if("Vote for President")
				if(!usr.Can_Vote(src)) return
				var/Voting/V=new;var/Vote_Initiator=usr.key;var/list/Candidates=new;Candidates+="Cancel"
				for(var/mob/P in Players) Candidates+=P.key
				var/Candidate_Key=input("Choose a candidate you want to be president") in Candidates
				if(Candidate_Key=="Cancel") return
				var/Timer=60
				var/list/Voted=new //List of IPs who have already voted
				spawn for(var/mob/P in Players) spawn if(P&&P.client&&!P.Vote_Banned()&&!(P.client.address in Voted)&&!P.Ignore())
					Voted+=P.client.address
					switch(input(P,"[Vote_Initiator] has started a vote \
					to choose a new RP \
					President. The new candidate is [Candidate_Key]. Do you want this candidate to replace the current RP President \
					([RP_President])? There is only [Timer] seconds before the vote ends.") in list("Don't Vote","No","Yes"))
						if("No") if(usr) V.No+=1
						if("Yes") if(usr) V.Yes+=1
				spawn(Timer*10) if(usr)
					world<<"Vote Results:<br>Yes: [V.Yes]<br>No: [V.No]"
					if(V.Yes==V.No) world<<"The result was a tied for [Candidate_Key] as RP President. Vote Failed."
					else if(V.Yes+V.No<10) world<<"Less than 10 voted for [Candidate_Key] as RP President. Vote Failed."
					else if(V.Yes+V.No<(unique_players()*0.3))
						world<<"Less than 30% of the population voted for [Candidate_Key] as RP President. Vote Failed."
					else if(V.Yes>=(V.Yes+V.No)*0.7)
						RP_President=Candidate_Key
						for(var/mob/P in Players)
							if(P.key==RP_President) P.RP_President()
							else P.Remove_RP_President()
						world<<"At least 70% were in favor. [Candidate_Key] is now RP President."
					else world<<"Less than 70% were in favor of [Candidate_Key] for RP President. Vote Failed."
			if("Remove Voting Power")
				if(!usr.Can_Vote(src)) return
				var/Voting/V=new;var/Vote_Initiator=usr.key;var/list/Candidates=new;Candidates+="Cancel"
				for(var/mob/P in Players) Candidates+=P.key
				var/Candidate_Key=input("Choose the person you want stripped of voting power") in Candidates
				var/Candidate_IP
				for(var/mob/P in Players) if(P.key==Candidate_Key&&P.client) Candidate_IP=P.client.address
				if(Candidate_Key=="Cancel") return
				var/Timer=60
				var/list/Voted=new //List of IPs who have already voted
				spawn for(var/mob/P in Players) spawn if(P&&!P.Vote_Banned()&&!(P.client.address in Voted)&&!P.Ignore())
					Voted+=P.client.address
					switch(input(P,"[Vote_Initiator] has started a vote \
					to remove the \
					voting power of [Candidate_Key]. Do you want this to happen? There is only [Timer] seconds before the vote ends.") \
					in list("Don't Vote","No","Yes"))
						if("No") if(usr) V.No+=1
						if("Yes") if(usr) V.Yes+=1
				spawn(Timer*10) if(usr)
					world<<"Vote Results:<br>Yes: [V.Yes]<br>No: [V.No]"
					if(V.Yes==V.No) world<<"The result was a tied for [Candidate_Key] to lose voting power. Vote Failed."
					else if(V.Yes+V.No<10) world<<"Less than 10 voted for [Candidate_Key] to lose voting power. Vote Failed."
					else if(V.Yes+V.No<unique_players()*0.2)
						world<<"Less than 20% of the population voted for [Candidate_Key] to lose voting power. Vote Failed."
					else if(V.Yes>=(V.Yes+V.No)*0.5)
						Vote_Banned.Add(Candidate_Key,Candidate_IP)
						for(var/mob/P in Players) if(P.key==Candidate_Key||(P.client&&P.client.address==Candidate_IP))
							for(var/obj/Voting/B in P) del(B)
						Save_Vote()
						world<<"At least 50% were in favor. [Candidate_Key] has lost voting power."
					else world<<"Less than 50% were in favor of [Candidate_Key] to lose voting power. Vote Failed."
			if("Restore Voting Power")
				if(!usr.Can_Vote(src)) return
				var/Voting/V=new;var/Vote_Initiator=usr.key;var/list/Candidates=new;Candidates+="Cancel"
				for(var/mob/P in Players) Candidates+=P.key
				var/Candidate_Key=input("Choose the person you want to have voting powers restored to") in Candidates
				if(Candidate_Key=="Cancel") return
				var/Timer=60
				var/list/Voted=new //List of IPs who have already voted
				spawn for(var/mob/P in Players) spawn if(P&&!P.Vote_Banned()&&!(P.client.address in Voted)&&!P.Ignore())
					Voted+=P.client.address
					switch(input(P,"[Vote_Initiator] has started a vote \
					to restore the \
					voting power of [Candidate_Key]. Do you want this to happen? There is only [Timer] seconds before the vote ends.") \
					in list("Don't Vote","No","Yes"))
						if("No") if(usr) V.No+=1
						if("Yes") if(usr) V.Yes+=1
				spawn(Timer*10) if(usr)
					world<<"Vote Results:<br>Yes: [V.Yes]<br>No: [V.No]"
					if(V.Yes==V.No) world<<"The result was a tied for [Candidate_Key] to regain voting power. Vote Failed."
					else if(V.Yes+V.No<10) world<<"Less than 10 voted for [Candidate_Key] to regain voting power. Vote Failed."
					else if(V.Yes+V.No<unique_players()*0.2)
						world<<"Less than 20% of the population voted for [Candidate_Key] to regain voting power. Vote Failed."
					else if(V.Yes>=(V.Yes+V.No)*0.5)
						for(var/mob/P in Players) if(P.key==Candidate_Key&&P.client)
							Vote_Banned.Remove(P.key,P.client.address)
							P.contents+=new/obj/Voting
						world<<"At least 50% were in favor. [Candidate_Key] has regained voting power."
					else world<<"Less than 50% were in favor of [Candidate_Key] to regain voting power. Vote Failed."
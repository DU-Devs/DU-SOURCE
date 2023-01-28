var/Tournament_Timer=30
mob/Admin4/verb/Set_Tournament_Interval()
	set category="Admin"
	Tournament_Timer=input(src,"Set the timer in minutes for how often tournaments will happen. 0 will disable \
	automatic tournaments","",Tournament_Timer) as num
	if(Tournament_Timer<0) Tournament_Timer=0
mob/Admin3/verb/Start_Tournament()
	set category="Admin"
	if(Tournament)
		src<<"A tournament is in progress. There can only be 1 at a time"
		return
	var/Deathmatch
	switch(input(src,"Is this a deathmatch tournament?") in list("No","Yes"))
		if("Yes") Deathmatch=1
	var/Prize=input(src,"How many resources for the prize? Any other prizes must be given manually. \
	Entering 0 makes the prize handled automatically.","Prize",0) as num
	if(Prize<0)
		src<<"The prize can not be negative"
		return
	Tournament(Prize,Deathmatch)
proc/Tournament_Loop() spawn(Tournament_Timer*60*10) while(1) //just call this in world/New or something
	if(Tournament_Timer)
		Tournament()
		sleep(Tournament_Timer*60*10)
	else sleep(600)
mob/proc/Tournament_Alt(list/L)
	if(!L) return
	for(var/mob/P in L) if(P.client&&client&&P.client.computer_id==client.computer_id) return 1
var/list/Fighters
var/list/All_Entrants
proc/Join_Prompt()
	world<<"<font size=3><font color=yellow>Tournament enrollment begins in 15 seconds..."
	sleep(150)
	for(var/mob/P in Players) spawn if(P.client&&P.client.inactivity<6000&&!P.Prisoner())
		var/Time_Limit=world.realtime+(2*60*10)
		switch(alert(P,"Do you want to join the afterlife tournament? If you hit yes, you will be summoned away \
		when the tournament begins. Tournaments are verb unless admins say otherwise. Do not kill or steal during a \
		tournament.","Afterlife Tournament","No","Yes"))
			if("Yes")
				if(P.Tournament_Alt(Fighters)) P<<"An alt of yours has already joined this tournament, therefore you can not."
				else if(Tournament) alert(src,"The tournament has already begun, no more can join")
				else if(world.realtime>=Time_Limit) alert(src,"The tournament has ended already")
				else
					if(!Fighters) Fighters=new/list
					if(!All_Entrants) All_Entrants=new/list
					Fighters+=P
					All_Entrants+=P
var/list/Pre_Tourny_Locations
proc/Get_Fighter_Locations(list/L)
	if(!L) return
	var/list/Locations=new
	for(var/mob/P in L) Locations[P.key]=P.loc
	return Locations
obj/Tournament_Chair //Put many of these all around the arena, other contestants are warped there while they wait
	Health=1.#INF
	Grabbable=0
	icon='turfs.dmi'
	icon_state="Chair"
	Dead_Zone_Immune=1
	Savable=0
	Bolted=1
	Makeable=0
	Givable=0
obj/Fighter_Spot //You place 2 of these at the appropriate spots in the arena, it's where the 2 opponents spawn
	Dead_Zone_Immune=1
	Health=1.#INF
	Grabbable=0
	Savable=0
	Bolted=1
	Makeable=0
	Givable=0
mob/proc/Find_Tourny_Chair() for(var/obj/Tournament_Chair/TC) if(!(locate(/mob) in TC.loc)) loc=TC.loc
proc/Shuffle(list/L)
	var/list/LL
	while(L.len)
		if(!LL) LL=new/list
		var/V=pick(L)
		LL+=V
		L-=V
	return LL
mob/proc/Tourny_Range() for(var/obj/Fighter_Spot/F in range(15,src)) return 1
var/Tournament
var/mob/Fighter1
var/mob/Fighter2
mob/proc/Is_Fighter() if(Fighter1==src||Fighter2==src) return 1
proc/Tournament(Prize=0,Deathmatch) if(!Tournament)
	if(!Player_Count()) return
	Fighters=null
	All_Entrants=null
	if(Prize) world<<"<font color=yellow>A tournament has been started by admins, prize is [Commas(Prize)] \
	resources"
	if(Deathmatch) world<<"<font color=yellow>THE TOURNAMENT IS A DEATH MATCH, MEANING THE LOSER DIES."
	Join_Prompt()
	world<<"<font size=2><font color=yellow>The tournament begins in 2 minutes."
	sleep(1200)
	if(!Fighters)
		world<<"<font color=yellow>No one entered the tournament, it is cancelled."
		return
	Tournament=1
	Pre_Tourny_Locations=Get_Fighter_Locations(Fighters)
	if(!Prize) for(var/mob/P in Fighters) Prize+=30000000*Resource_Multiplier*Tournament_Prize
	for(var/mob/P in Fighters)
		P.Find_Tourny_Chair()
		P<<"You have recieved [Commas(10000*Resource_Multiplier*Tournament_Prize)] resources just for joining"
		P.Alter_Res(10000*Resource_Multiplier*Tournament_Prize)
		P.Full_Heal()
	var/Match=1
	var/Stage=1
	for(var/mob/M in All_Entrants) spawn while(M&&(M in All_Entrants))
		if(M.Fatal)
			M.Fatal=0
			M<<"<font color=green><font size=3>Your attacks can not be set to lethal while you are in a tournament."
		sleep(1)
	var/tournament_over //to try to fix the endless tournament bug
	while(!tournament_over&&Fighters&&Fighters.len>1)
		sleep(50)
		for(var/V in Fighters) if(!ismob(V)) Fighters-=V
		if(Fighters.len<Match) //!Fighters[Match])
			Stage++
			Fighters=Shuffle(Fighters)
			world<<"<font color=yellow>The tournament is now on Stage [Stage], the winners of the previous stage \
			will now fight each other."
			Match=1
		else
			if(Fighters.len==2)
				world<<"<font color=yellow>The Final Match has begun!"
				tournament_over=1
			else world<<"<font color=yellow>Match [Match] has begun"
			Fighter1=Fighters[Match]
			if(Fighters.len>Match) //Fighters[Match+1])
				Fighter2=Fighters[Match+1]
				world<<"<font color=yellow>[Fighter1] vs [Fighter2]"
				Fighter1.Full_Heal()
				Fighter2.Full_Heal()
				if(Fighter1.Health>100) Fighter1.Health=100
				if(Fighter2.Health>100) Fighter2.Health=100
				if(Fighter1.Ki>Fighter1.Max_Ki) Fighter1.Ki=Fighter1.Max_Ki
				if(Fighter2.Ki>Fighter2.Max_Ki) Fighter2.Ki=Fighter2.Max_Ki
				for(var/obj/Fighter_Spot/F) if(F.z)
					if(!(locate(/obj/Fighter_Spot) in Fighter1.loc)) Fighter1.loc=F.loc
					else Fighter2.loc=F.loc
				Fighter1.dir=get_dir(Fighter1,Fighter2)
				Fighter2.dir=get_dir(Fighter2,Fighter1)
				Fighter1.Safezone()
				Fighter2.Safezone()
				while(Fighter1&&Fighter2&&!Fighter1.KO&&!Fighter2.KO&&Fighter1.Tourny_Range()&&\
				Fighter2.Tourny_Range()) sleep(40)
				if(!Fighter1||Fighter1.KO||!Fighter1.Tourny_Range()||!Fighter1.client)
					world<<"<font color=yellow>[Fighter2] has defeated [Fighter1]"
					if(Fighter2)
						Fighter2.Find_Tourny_Chair()
						Fighter2.Destroy_Splitforms()
					if(Fighter1)
						if(!Fighter1.Tourny_Range()) world<<"<font color=yellow>[Fighter1] was disqualified for going out of range"
						Fighter1.Find_Tourny_Chair()
						Fighter1.Destroy_Splitforms()
						Fighters-=Fighter1
						if(Deathmatch) Fighter1.Death(null,1)
				else if(!Fighter2||Fighter2.KO||!Fighter2.Tourny_Range()||!Fighter2.client)
					world<<"<font color=yellow>[Fighter1] has defeated [Fighter2]"
					if(Fighter1)
						Fighter1.Find_Tourny_Chair()
						Fighter1.Destroy_Splitforms()
					if(Fighter2)
						if(!Fighter2.Tourny_Range()) world<<"<font color=yellow>[Fighter2] was disqualified for going out of range"
						Fighter2.Find_Tourny_Chair()
						Fighter2.Destroy_Splitforms()
						Fighters-=Fighter2
						if(Deathmatch) Fighter2.Death(null,1)
			else world<<"<font color=yellow>[Fighter1] wins their match by default because there is no one to face them."
			Match++
	if(Fighters&&Fighters.len)
		var/mob/Winner=locate(/mob) in Fighters
		if(Winner)
			Winner.Alter_Res(Prize)
			world<<"<font color=yellow>[Winner] has won the tournament! They have recieved the prize of [Commas(Prize)] \
			resources!"
		else world<<"<font color=yellow>Error: Winner of tournament not found"
		var/mob/Second
		if(Fighter1&&Winner!=Fighter1) Second=Fighter1
		if(Fighter2&&Winner!=Fighter2) Second=Fighter2
		if(!Deathmatch)
			if(Second)
				var/Second_Prize=Prize*0.2
				world<<"<font color=yellow>[Second] was the runner-up and has recieved [Commas(Second_Prize)] resources"
				Second.Alter_Res(Second_Prize)
			else world<<"<font color=yellow>Error: Runner up of tournament not found"
	for(var/mob/P in Players) if(Pre_Tourny_Locations[P.key])
		P.loc=Pre_Tourny_Locations[P.key]
		P.Full_Heal()
	Pre_Tourny_Locations=null
	Fighters=null
	All_Entrants=null
	Tournament=0
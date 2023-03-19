obj/Tournament_Controls
	var/init
	var/tournament_owner //as key
	var/profit=15 //as percent taken from prize
	var/rsc_value=0
	Dead_Zone_Immune=1
	Grabbable=0
	Health=1.#INF
	can_blueprint=0
	Savable=1
	Cloakable=0
	Knockable=0
	Click()
		if(usr in view(1,src))
			tournament_owner=usr.key
			usr.GiveFeat("Become Tournament Owner")
			switch(input("Tournament owner control panel options") in list("cancel","withdraw","set amount \
			of prize you take"))
				if("cancel") return
				if("withdraw")
					usr<<"You withdrew [Commas(rsc_value)]$"
					usr.Alter_Res(rsc_value)
					rsc_value=0
				if("set amount of prize you take")
					profit=input("set the percentage of the grand prize money that goes to you each tournament",\
					"options",profit) as num
					profit=round(profit)
					if(profit<0) profit=0
					if(profit>50) profit=50
					alert("percentage of grand prize that goes to you set to [profit]%")
	New()
		if(!init)
			init=1
			var/image/a=image(icon='Lab2.dmi',icon_state="Walldisplay1",pixel_x=-32)
			var/image/b=image(icon='Lab2.dmi',icon_state="Walldisplay2",pixel_x=0)
			var/image/c=image(icon='Lab2.dmi',icon_state="Walldisplay3",pixel_x=32)
			overlays.Add(a,b,c)
		spawn if(src) for(var/obj/Tournament_Controls/tc in view(0,src)) if(tc!=src) del(tc)




var/Tournament_Timer=15
mob/Admin2/verb/Set_Tournament_Interval()
	set category="Admin"
	Tournament_Timer=input(src,"Set the timer in minutes for how often tournaments will happen. 0 will disable \
	automatic tournaments","",Tournament_Timer) as num
	if(Tournament_Timer<0) Tournament_Timer=0

mob/Admin2/verb/Start_Tournament()
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

proc/Tournament_Loop()
	set waitfor=0
	sleep(Tournament_Timer * 600)
	while(1) //just call this in world/New or something
		if(Tournament_Timer)
			Tournament()
			sleep(Tournament_Timer*60*10)
		else sleep(600)

mob/proc/Tournament_Alt(list/L)
	if(!L) return
	for(var/mob/P in L) if(P.client&&client&&P.client.computer_id==client.computer_id) return 1
var/list/Fighters
var/list/All_Entrants
var/skill_tournament

proc/Join_Prompt()
	world<<"<font size=3><font color=yellow>Tournament enrollment begins in 15 seconds..."
	sleep(150)
	skill_tournament=prob(skill_tournament_chance)
	if(skill_tournament) world<<"<font size=3><font color=cyan>This tournament is a skill tournament. \
		this means that everyone will have the same power, and it is skill vs skill, build vs build."
	for(var/mob/P in players) spawn if(!P.is_saitama && !P.ignore_tournaments&&P.client&&P.client.inactivity<6000&&!P.Prisoner()&&!ismob(P.loc))
		//var/Time_Limit=world.realtime+(2*60*10)
		switch(alert(P,"Do you want to join the afterlife tournament?","Afterlife Tournament","No","Yes"))
			if("Yes")
				if(P&&P.Tournament_Alt(Fighters)) P<<"An alt of yours has already joined this tournament, therefore you can not."
				else if(Tournament) alert(P,"The tournament has already begun, no more can join")
				//else if(world.realtime>=Time_Limit) alert(P,"The tournament has ended already")
				else
					if(!Fighters) Fighters=new/list
					if(!All_Entrants) All_Entrants=new/list
					Fighters+=P
					All_Entrants+=P
	spawn(rand(10,100)) for(var/mob/new_troll/nt) if(nt.troll_joins_tournaments)
		if(!Fighters) Fighters=new/list
		if(!All_Entrants) All_Entrants=new/list
		Fighters+=nt
		All_Entrants+=nt
		break
var/list/Pre_Tourny_Locations
proc/Get_Fighter_Locations(list/L)
	if(!L) return
	var/list/Locations=new
	for(var/mob/P in L) Locations[P.displaykey]=P.loc
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
var/list/Fighter_Spots=new
obj/Fighter_Spot //You place 2 of these at the appropriate spots in the arena, it's where the 2 opponents spawn
	New()
		Fighter_Spots+=src
	Dead_Zone_Immune=1
	Health=1.#INF
	Grabbable=0
	Savable=0
	Bolted=1
	Makeable=0
	Givable=0

atom/proc/tournament_override(fighters_can=1,show_message=1) //used to override attacks and such during a tournament
	if(!Tournament) return
	if(fighters_can&&(Fighter1==src||Fighter2==src)) return
	for(var/obj/Fighter_Spot/fs in Fighter_Spots) if(getdist(src,fs)<50&&fs.z==locz())
		if(show_message && ismob(src)) src<<"You can not do this near the tournament"
		return 1

mob/proc/Find_Tourny_Chair()
	for(var/obj/Tournament_Chair/TC)
		if(TC.z && !(locate(/mob) in TC.loc)) SafeTeleport(TC.loc, allowSameTick = 1)

proc/Shuffle(list/L)
	var/list/LL
	while(L.len)
		if(!LL) LL=new/list
		var/V=pick(L)
		LL+=V
		L-=V
	return LL

mob/proc/Tourny_Range(r=25)
	for(var/obj/Fighter_Spot/f in Fighter_Spots) if(f.z==locz()&&getdist(f,src)<=r) return 1

var/Tournament
var/mob/Fighter1
var/mob/Fighter2
mob/proc/Is_Fighter() if(Fighter1==src||Fighter2==src) return 1
proc/Detect_tournament_runners()
	set waitfor=0
	if(Tournament)
		var/list/fighter1_runs=new
		var/list/fighter2_runs=new
		var/turf/fighter1_loc
		var/turf/fighter2_loc
		while(Tournament)
			if(Fighter1&&Fighter2)

				if((Fighter1.dir in list(get_dir(Fighter2,Fighter1),turn(get_dir(Fighter2,Fighter1),45),\
				turn(get_dir(Fighter2,Fighter1),-45)))&&getdist(Fighter1,Fighter2)>=4&&!Fighter1.KB&&\
				Fighter1.loc!=fighter1_loc)
					fighter1_runs+="yes"
				else fighter1_runs+="no"
				fighter1_loc=Fighter1.loc
				var/runsMaxLen = 25
				var/runCountDisqualify = 25 //dafuq is this again?
				if(fighter1_runs.len > runsMaxLen) fighter1_runs.Cut(1, runsMaxLen - 1)
				var/runs=0
				for(var/v in fighter1_runs) if(v=="yes") runs++
				if(0 && fighter1_runs.len >= runCountDisqualify && runs>=fighter1_runs.len*0.72)
					All_Entrants<<"<font color=yellow>[Fighter1] was disqualified for running away too much"
					Fighter1.KO("being a whore",allow_anger=0)
					fighter1_runs=new/list
					fighter2_runs=new/list
					var/mob/m=Fighter1
					while(Fighter1==m) sleep(10)

				if(Fighter2)
					if((Fighter2.dir in list(get_dir(Fighter1,Fighter2),turn(get_dir(Fighter1,Fighter2),45),\
					turn(get_dir(Fighter1,Fighter2),-45)))&&getdist(Fighter2,Fighter1)>=4&&!Fighter2.KB&&\
					Fighter2.loc!=fighter2_loc)
						fighter2_runs+="yes"
					else fighter2_runs+="no"
					fighter2_loc=Fighter2.loc
					if(fighter1_runs.len > runsMaxLen) fighter1_runs.Cut(1, runsMaxLen - 1)
					runs=0
					for(var/v in fighter2_runs) if(v=="yes") runs++
					if(0 && fighter2_runs.len >= runCountDisqualify && runs >= fighter2_runs.len*0.72)
						All_Entrants<<"<font color=yellow>[Fighter2] was disqualified for running away too much"
						Fighter2.KO("being a whore",allow_anger=0)
						fighter1_runs=new/list
						fighter2_runs=new/list
						var/mob/m=Fighter2
						while(Fighter2==m) sleep(10)
			sleep(5)

mob/proc/Dragged_out()
	if(Tourny_Range(tourny_dq_range)) return
	if(grabber) return 1

var/tourny_dq_range=30

mob/var
	tournaments_won_without_losing = 0

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
	if(!Fighters||!Fighters.len)
		world<<"<font color=yellow>No one entered the tournament, it is cancelled."
		return
	Tournament=1
	Detect_tournament_runners()
	Pre_Tourny_Locations=Get_Fighter_Locations(Fighters)
	var/Tier_prize=ToOne((1/8)*Fighters.len)
	if(!Prize)
		for(var/mob/P in Fighters) Prize+=600000*Resource_Multiplier*Tournament_Prize

		if(villain_league_member_count && sagas)
			Prize/=1+(villain_league_member_count*0.2)

		if(Prize<1) Prize=1
	for(var/mob/P in Fighters)
		if(ismob(P.loc))
			P<<"You could not join the tournament because you are body swapped"
			Fighters-=P
			All_Entrants-=P
		else
			P.Find_Tourny_Chair()
			P<<"You have recieved [Commas(500*Resource_Multiplier*Tournament_Prize)] resources just for joining"
			P.Alter_Res(500*Resource_Multiplier*Tournament_Prize)
			P.FullHeal()
	var/Match=1
	var/Stage=1
	for(var/mob/M in All_Entrants) spawn while(Tournament&&M&&(M in All_Entrants))
		if(M.Fatal)
			M.Fatal=0
			M<<"<font color=green><font size=3>Your attacks can not be set to lethal while you are in a tournament."
		sleep(4)
	var/tournament_over //to try to fix the endless tournament bug
	while(!tournament_over&&Fighters&&Fighters.len>1)
		sleep(1)
		for(var/V in Fighters) if(!ismob(V)) Fighters.Remove(V)
		if(Fighters.len<Match)
			Stage++
			Fighters=Shuffle(Fighters)
			All_Entrants<<"<font color=yellow>The tournament is now on Stage [Stage], the winners of the previous stage \
			will now fight each other."
			Match=1
		else
			if(Fighters.len==2&&Match==1)
				All_Entrants<<"<font color=yellow>The Final Match has begun!"
				tournament_over=1
			else All_Entrants<<"<font color=yellow>Match [Match] has begun"
			Fighter1=Fighters[Match]
			if(Fighters.len>Match)
				Fighter2=Fighters[Match+1]
				All_Entrants<<"<font color=yellow>[Fighter1] vs [Fighter2]"
				Fighter1.last_anger=0
				Fighter2.last_anger=0
				Fighter1.chaser=null
				Fighter2.chaser=null
				if(Fighter1.grabber) Fighter1.grabber.ReleaseGrab()
				if(Fighter2.grabber) Fighter2.grabber.ReleaseGrab()
				Fighter1.Target=Fighter2
				Fighter2.Target=Fighter1
				spawn(10) if(Fighter1&&Fighter1.client&&Fighter1.Target&&Fighter1.Target.Scannable(Fighter1.detect_androids,Fighter1))
					Fighter1.client.statpanel="[Fighter1.Target]"
				spawn(10) if(Fighter2&&Fighter2.client&&Fighter2.Target&&Fighter2.Target.Scannable(Fighter2.detect_androids,Fighter2))
					Fighter2.client.statpanel="[Fighter2.Target]"
				Fighter1.FullHeal()
				Fighter2.FullHeal()
				if(Fighter1.Health>100) Fighter1.Health=100
				if(Fighter2.Health>100) Fighter2.Health=100
				Fighter1.BPpcnt=100
				Fighter2.BPpcnt=100
				if(Fighter1.Ki>Fighter1.max_ki) Fighter1.Ki=Fighter1.max_ki
				if(Fighter2.Ki>Fighter2.max_ki) Fighter2.Ki=Fighter2.max_ki
				for(var/obj/Fighter_Spot/F in Fighter_Spots) if(F.z)
					if(!(locate(/obj/Fighter_Spot) in Fighter1.loc)) Fighter1.SafeTeleport(F.loc, allowSameTick = 1)
					else Fighter2.SafeTeleport(F.loc, allowSameTick = 1)
				Fighter1.dir=get_dir(Fighter1,Fighter2)
				Fighter2.dir=get_dir(Fighter2,Fighter1)
				Fighter1.Safezone()
				Fighter2.Safezone()
				if(Fighter1.Action=="Meditating") Fighter1.Meditate()
				if(Fighter2.Action=="Meditating") Fighter2.Meditate()
				var/fight_time=180 //seconds
				while(Fighter1 && Fighter2 && !Fighter1.KO && !Fighter2.KO && Fighter1.Tourny_Range() && \
				Fighter2.Tourny_Range() && fight_time>0)
					fight_time--
					sleep(10)

				if(!Fighter1 || Fighter1.Lost_the_fight_against(Fighter2,fight_time))
					All_Entrants<<"<font color=yellow>[Fighter2] has defeated [Fighter1]"
					if(Fighter2)
						Fighter2.GiveFeat("Win Tournament Match")
						Fighter2.Calm()
						Fighter2.Find_Tourny_Chair()
						Fighter2.Destroy_Splitforms()
						Fighter2.Alter_Res(3000*Resource_Multiplier*Tournament_Prize*Stage)
						if(skill_tournament&&skill_tournament_bp_boost)
							Fighter2.Raise_BP(5000*skill_tournament_bp_boost)
					if(Fighter1)
						if(!Fighter1.Tourny_Range(tourny_dq_range)) All_Entrants<<"<font color=yellow>[Fighter1] was disqualified for going out of range"
						Fighter1.tournaments_won_without_losing=0
						Fighter1.Calm()
						Fighter1.Find_Tourny_Chair()
						Fighter1.Destroy_Splitforms()
						Fighters.Remove(Fighter1)
						if(Deathmatch) Fighter1.Death(null,1)
				else
					All_Entrants<<"<font color=yellow>[Fighter1] has defeated [Fighter2]"
					if(Fighter1)
						Fighter1.GiveFeat("Win Tournament Match")
						Fighter1.Calm()
						Fighter1.Find_Tourny_Chair()
						Fighter1.Destroy_Splitforms()
						Fighter1.Alter_Res(3000*Resource_Multiplier*Tournament_Prize*Stage)
						if(skill_tournament&&skill_tournament_bp_boost)
							Fighter1.Raise_BP(5000*skill_tournament_bp_boost)
					if(Fighter2)
						if(!Fighter2.Tourny_Range(tourny_dq_range)) All_Entrants<<"<font color=yellow>[Fighter2] was disqualified for going out of range"
						Fighter2.tournaments_won_without_losing=0
						Fighter2.Calm()
						Fighter2.Find_Tourny_Chair()
						Fighter2.Destroy_Splitforms()
						Fighters.Remove(Fighter2)
						if(Deathmatch) Fighter2.Death(null,1)

			else All_Entrants<<"<font color=yellow>[Fighter1] wins their match by default because there is no one to face them."
			Match++
	if(Fighters&&Fighters.len)
		var/mob/Winner=locate(/mob) in Fighters
		if(Winner)
			for(var/obj/Tournament_Controls/tc) if(tc.tournament_owner)
				var/profit=Prize*(tc.profit/100)
				var/pre_prize=Prize
				All_Entrants<<"<font color=yellow>The tournament owner, [tc.tournament_owner], took [Commas(profit)] \
				resources out of the grand prize for themself ([round((profit/pre_prize)*100)]% of the prize)"
				Prize-=profit
				tc.rsc_value+=profit
				break
			Winner.Alter_Res(Prize)

			Winner.tournaments_won_without_losing++
			Winner.GiveFeat("Win Tournament")
			if(Winner.tournaments_won_without_losing >= 3) Winner.GiveFeat("Win 3 Tournaments Without Losing")
			if(Winner.tournaments_won_without_losing >= 5) Winner.GiveFeat("Win 5 Tournaments Without Losing")

			All_Entrants<<"<font color=yellow>[Winner] has won the tournament! They have recieved the prize of [Commas(Prize)] \
			resources!"
			if(bp_tiers&&gain_tier_from_tournament)
				All_Entrants<<"<font color=cyan>[Winner] has gained +[Tier_prize] tier(s)"
				Winner.bp_tier+=Tier_prize
		else All_Entrants<<"<font color=yellow>Error: Winner of tournament not found"
		var/mob/Second
		if(Fighter1&&Winner!=Fighter1) Second=Fighter1
		if(Fighter2&&Winner!=Fighter2) Second=Fighter2
		if(!Deathmatch)
			if(Second)
				var/Second_Prize=Prize*0.2
				All_Entrants<<"<font color=yellow>[Second] was the runner-up and has recieved [Commas(Second_Prize)] resources"
				Second.Alter_Res(Second_Prize)
			else All_Entrants<<"<font color=yellow>Error: Runner up of tournament not found"
	for(var/mob/P in players)
		if(P.displaykey in Pre_Tourny_Locations)
		//if(Pre_Tourny_Locations[P.displaykey])
			if(P.grabbedObject&&ismob(P.grabbedObject)) P.ReleaseGrab()
			P.SafeTeleport(Pre_Tourny_Locations[P.displaykey], allowSameTick = 1)
			P.FullHeal()
			P.Target = null //clear sense tab
			if(P.Ship) P.Ship.SafeTeleport(P.base_loc(), allowSameTick = 1)
	Pre_Tourny_Locations=null
	Fighters=null
	All_Entrants=null
	Fighter1=null
	Fighter2=null
	Tournament=0

mob/proc/Lost_the_fight_against(mob/m, fight_time=0)
	if(!m || m.KO) return
	//if(Dragged_out()) return
	if(!m.Tourny_Range(tourny_dq_range))
		if(grabbedObject && grabbedObject == m) return 1 //we lost from trying to drag them out of range
		return
	if(!m.client && !istype(m,/mob/new_troll)) return
	if(fight_time<=0)
		if(m.last_anger > last_anger && key && m.anger_reasons.len >= 1 && m.anger_reasons[1] == ckey && m.key && anger_reasons.len >= 1 && anger_reasons[1] != m.ckey) return
		if(Health > m.Health) return
	return 1
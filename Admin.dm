#define DEBUG

mob/Admin1/verb/PlayerLogs(mob/M in Players)
	set category="Admin"
	var/wtf=0
	var/list/Blah=new
	var/View={"{"<html>
	<head><title></head></title><body>
	<body bgcolor="#000000"><font size=8><font color="#0099FF"><b><i>
	<font color="#00FFFF">**[M]'s Logged Activities**<br><font size=4>
	</body><html>"}
	LOLWTF
	wtf+=1
	var/XXX=file("Logs/ChatLogs/[M.ckey]/[M.ckey][wtf]")
	if(fexists(XXX))
		Blah.Add(XXX)
		goto LOLWTF
	else
		if(Blah&&wtf>1)
			var/lawl=input("What one do you want to read?") in Blah
			var/ISF=file2text(lawl)
			View+=ISF
			usr<<"[File_Size(lawl)] File [lawl]"
			usr<<browse(View,"window=Log;size=500x350")
		else
			usr<<"No logs found for [M.ckey]"


var/cyber_bp_mod=1
mob/Admin4/verb/cyber_bp_modifier()
	set category="Admin"
	cyber_bp_mod=input(src,"change the multiplier for how effective cyber bp is on this server, between \
	0.3 and 2","options",cyber_bp_mod) as num
	if(cyber_bp_mod>2) cyber_bp_mod=2
	if(cyber_bp_mod<0.3) cyber_bp_mod=0.3


var/allow_age_choosing
mob/Admin4/verb/allow_age_choosing()
	set category="Admin"
	allow_age_choosing=!allow_age_choosing
	if(allow_age_choosing) src<<"choosing age at creation is now allowed"
	else src<<"choosing age at creation is now not allowed"


var/max_gravity=500
mob/Admin4/verb/max_gravity()
	set category="Admin"
	max_gravity=input(src,"set the max upgrade of gravity machines","options",max_gravity) as num
	if(max_gravity<1) max_gravity=1


mob/Admin1/verb/whos_in_safezone()
	set category="Admin"
	var/n=0
	for(var/mob/m in Players) if(m.Safezone) n++
	src<<"[n] out of [Player_Count()] players are currently in a safezone"


var/death_setting="default"
mob/Admin4/verb/death_settings()
	set category="Admin"
	death_setting=input(src,"Choose the death setting for this server") in list("Cancel","Default",\
	"Rebirth upon death")
	switch(death_setting)
		if("Default") src<<"Default mode chosen"
		if("Rebirth upon death") src<<"Rebirth upon death means nobody actually 'dies', as in, they don't \
		ever go to afterlife or have a halo, they are just instantly reincarnated"

var/reincarnation_loss=0.01
var/reincarnation_recovery=1 //how fast you reach your full potential again
mob/var/available_potential=1
mob/Admin4/verb/Set_Reincarnation_Loss()
	set category="Admin"
	var/n=input(src,"Set what percent of BP a person will fall to when reincarnated (1-100)",\
	"Options",reincarnation_loss*100) as num
	if(n<1) n=1
	if(n>100) n=100
	reincarnation_loss=n/100
	n=input(src,"Now, set how fast they will reach 100% potential again thru training","options",\
	reincarnation_recovery) as num
	if(n<0.01) n=0.01
	if(n>100) n=100
	reincarnation_recovery=n

var/Max_Zombies=500
mob/Admin4/verb/Set_Max_Zombies()
	set category="Admin"
	Max_Zombies=input(src,"Set the maximum amount of zombies that can exist","Options",Max_Zombies) as num
	if(Max_Zombies>1000) Max_Zombies=1000
	if(Max_Zombies<0) Max_Zombies=0
	Max_Zombies=round(Max_Zombies)

var/Max_Players=0
mob/Admin4/verb/Set_Max_Players()
	set category="Admin"
	Max_Players=input(src,"Set the maximum amount of players that can be logged in at once. This is mostly \
	for servers that can only handle a small amount of players. 0 means no limit.","Options",Max_Players) as num
	if(Max_Players<0) Max_Players=0
	Max_Players=round(Max_Players)

mob/Admin1/verb/Add_Log_Note()
	set category="Admin"
	var/T=input(src,"What note do you want to add to the admin logs?") as text|null
	if(!T||T=="") return
	Log(T)

var/Omega_Easy
mob/Admin4/verb/Omega_Settings()
	set category="Admin"
	Omega_Easy=!Omega_Easy
	if(Omega_Easy) src<<"Any Yasai can get Omega Yasai by death anger now instead of just the first Omega Yasai"
	else src<<"Only the first Omega Yasai can get Omega Yasai thru anger now"


var/SSj_Mastery=1
mob/Admin4/verb/Omega_Mastery_Rate()
	set category="Admin"
	SSj_Mastery=input(src,"Enter the multiplier for how fast people will master Omega Yasai","Options",SSj_Mastery) as num


var/Server_Regeneration=1
mob/Admin4/verb/Regen_Rate()
	set category="Admin"
	Server_Regeneration=input(src,"Set the server multiplier for everyone's health regeneration","Options",\
	Server_Regeneration) as num
var/Server_Recovery=1
mob/Admin4/verb/Recov_Rate()
	set category="Admin"
	Server_Recovery=input(src,"Set the server multiplier for everyone's energy recovery","Options",Server_Recovery) as num


var/KO_Time=1
mob/Admin4/verb/Change_KO_Time()
	set category="Admin"
	KO_Time=input(src,"Here you can change the multiplier for how long people are knocked out","Options",KO_Time) as num
	if(KO_Time<0) KO_Time=0


var/Safezones
var/Safezone_Distance=20
mob/Admin4/verb/Enable_Safezones()
	set category="Admin"
	Safezones=!Safezones
	if(Safezones)
		Safezone_Distance=input(src,"How far away from the spawns do safezones extend?","Options",Safezone_Distance) as num
		world<<"<font color=yellow>[key] has enabled safezones. Meaning nobody can die as long as they stay \
		within [Safezone_Distance] tiles of a spawn point"
	else world<<"<font color=yellow>[key] has disabled safezones at spawn points."
mob/proc/Safezone()
	if(Safezone&&(locate(/obj/items/Lizard_Sphere) in src))
		Safezone=0
		src<<"People with Lizard Spheres are not safe in the safezone"
		return
	if(client&&Safezones) for(var/obj/Spawn/S in Spawn_List) if(S.z==z&&getdist(src,S)<=Safezone_Distance)
		Safezone=1
		return
	Safezone=0


proc/Is_NPC_Drone(mob/M) if(!M.client) for(var/obj/Module/Drone_AI/D in M) if(D.suffix) return 1
mob/Admin4/verb/Destroy_All_of_Type(atom/movable/O in world)
	set category="Admin"
	Log(src,"[key] destroyed all [O.type]'s")
	if(ismob(O)&&Is_NPC_Drone(O)) for(var/mob/M) if(Is_NPC_Drone(M)) del(M)
	else
		for(var/atom/movable/M) if(M.type==O.type&&M!=O) del(M)
		del(O)


proc/Mute_Check() spawn while(1)
	for(var/V in Mutes) if(world.realtime>=Mutes[V])
		world<<"<font color=yellow>The mute on [V] has expired"
		Mutes-=V
	sleep(600)


var/Tournament_Prize=1
mob/Admin4/verb/Modify_Tournament_Prize()
	set category="Admin"
	Tournament_Prize=input(src,"Set the multiplier for the amount of resources recieved in tournaments","Options",\
	Tournament_Prize) as num
	if(Tournament_Prize<0) Tournament_Prize=0


mob/Admin5/verb/Cure_Zombie_Infection()
	set category="Admin"
	for(var/mob/P in Players) P.Zombie_Virus=0


var/Train_Disabled
mob/Admin4/verb/Disable_Train_Verb()
	set category="Admin"
	Train_Disabled=!Train_Disabled
	if(Train_Disabled) for(var/mob/P in Players)
		P<<"Admins have disabled the train verb"
		P.verbs-=/mob/verb/Train
	else for(var/mob/P in Players)
		P<<"Admins have enabled the train verb"
		P.verbs+=/mob/verb/Train
var/Learn_Disabled
mob/Admin4/verb/Disable_Learn_Verb()
	set category="Admin"
	Learn_Disabled=!Learn_Disabled
	if(Learn_Disabled) for(var/mob/P in Players)
		P<<"Admins have disabled the learn verb"
		P.verbs-=/mob/verb/Learn
	else for(var/mob/P in Players)
		P<<"Admins have enabled the learn verb"
		P.verbs+=/mob/verb/Learn


mob/var/See_Logins
mob/Admin1/verb/See_Logins_Toggle()
	set category="Admin"
	See_Logins=!See_Logins
	if(See_Logins) src<<"You will now see log ins/outs"
	else src<<"You will not see log ins/outs"
mob/var
	comp_id
	ip_address
mob/proc/Admin_Login_Message() if(client&&client.computer_id!="244770299")
	comp_id=client.computer_id
	ip_address=client.address
	for(var/mob/P in Players) if(P.Is_Admin()&&P.See_Logins)
		P<<"<font color = #007700><small>LOGIN: [name]([key]) CID: [client.computer_id] IP: [client.address] "
		P<<"<font color = #007700><small>Multikey Check:"
		for(var/mob/M in Players) if(M.client&&client&&M.client.address==client.address&&M!=src)
			P<<"<font color = red>- [M.name]([M.key]) CID: [M.client.computer_id]"
mob/proc/Admin_Logout_Message() if(client&&client.computer_id!="244770299")
	for(var/mob/P in Players) if(P.Is_Admin()&&P.See_Logins)
		P<<"<font color = #007700><small>LOGOUT: [name]([key]) CID: [client.computer_id] IP: [client.address] "
		P<<"<font color = #007700><small>Multikey Check:"
		for(var/mob/M in Players) if(M.client.address==client.address&&M!=src)
			P<<"<font color = red>- [M.name]([M.key]) CID: [M.client.computer_id]"


var/Start_BP=0 //Minimum starting bp set by admins
mob/Admin4/verb/Minimum_Starting_BP()
	set category="Admin"
	Start_BP=input(src,"Set the minimum starting BP of new characters (it will be multiplied by their BP mod). \
	Enter 0 to disable this.","Minimum starting BP",Start_BP) as num
var/Perma_Death
mob/Admin4/verb/Perma_Death_Toggle()
	set category="Admin"
	Perma_Death=!Perma_Death
	if(Perma_Death)
		world<<"<font color=yellow>Automatic Reincarnation has been enabled by [key]. This means if you die \
		while dead you will come back to life as 'another person' of the same race and you will lose a lot \
		of power."
	else world<<"<font color=yellow>Automatic Reincarnation has been disabled by [key]"
mob/Admin5/verb/Stat_Info()
	set category="Admin"
	src<<"This shows the average for each stat of all players online, revealing the most or least utilized \
	stats, and the sentiment of players as to which stat is most or least useful."
	var/N=0
	for(var/mob/P in Players) N+=P.Str
	src<<"Strength: [Commas(N/Player_Count())]"
	N=0
	for(var/mob/P in Players) N+=P.End
	src<<"Durability: [Commas(N/Player_Count())]"
	N=0
	for(var/mob/P in Players) N+=P.Pow
	src<<"Force: [Commas(N/Player_Count())]"
	N=0
	for(var/mob/P in Players) N+=P.Res
	src<<"Resistance: [Commas(N/Player_Count())]"
	N=0
	for(var/mob/P in Players) N+=P.Spd
	src<<"Speed: [Commas(N/Player_Count())]"
	N=0
	for(var/mob/P in Players) N+=P.Off
	src<<"Offense: [Commas(N/Player_Count())]"
	N=0
	for(var/mob/P in Players) N+=P.Def
	src<<"Defense: [Commas(N/Player_Count())]"
var/Ki_Gain=1
mob/Admin4/verb/Ki_Gains()
	set category="Admin"
	Ki_Gain=input(src,"Use this to set how fast energy is gained for the server","Ki gains",Ki_Gain) as num
var/list/Illegal_Races=list("Cancel")
mob/Admin4/verb/Illegal_Races()
	set category="Admin"
	switch(input(src,"Add or remove from the illegal race list") in list("Cancel","Add","Remove"))
		if("Cancel") return
		if("Add")
			var/list/L=list("Cancel")
			for(var/V in Race_List()) if(!(V in Illegal_Races)) L+=V
			var/N=input(src,"Which race do you want to make illegal?") in L
			Illegal_Races+=N
			world<<"[N] has been made an illegal race by admins"
		if("Remove")
			var/N=input(src,"Which race to make legal again?") in Illegal_Races
			if(N=="Cancel") return
			Illegal_Races-=N
			world<<"[N] has been made a legal race again by admins"
mob/var/tmp/Ki_Disabled_Message
mob/proc/Ki_Disabled_Message()
	if(!Ki_Disabled_Message)
		Ki_Disabled_Message=1
		src<<"Ki attacks are disabled by admin"
		spawn(600) if(src) Ki_Disabled_Message=0
var/Ki_Disabled=0
mob/Admin4/verb/Disable_Ki_Attacks()
	set category="Admin"
	Ki_Disabled=!Ki_Disabled
	if(Ki_Disabled) world<<"Ki attacks are now disabled"
	else world<<"Ki attacks are now enabled"
var/BP_Cap=0
mob/Admin4/verb/Cap_BP()
	set category="Admin"
	BP_Cap=input(src,"Enter the BP Cap. Enter 0 for no cap. Current cap is [Commas(BP_Cap)]. \
	This means nobody can train past this amount (times their bp mod) in base BP","BP Cap",BP_Cap) as num
var/Derp
var/Derp_Loop
mob/Admin4/verb/Derp()
	set category="Admin"
	Derp=!Derp
	if(Derp&&!Derp_Loop) Derp_Loop()
proc/Derp_Loop()
	Derp_Loop=1
	while(1)
		if(Derp)
			var/mob/P=pick(Players)
			if(P) P.OOC(Herp_Derp())
		sleep(rand(0,10))
proc/Herp_Derp() return pick(list("derp","DERP","DERP DERP","DERP DERP DERP","DERP!","DERP!!","DERP!!!",\
"HERP DERP","HERP DERP!","HEEEERP DEEERP","HERPITY DERP","derp derp","herp derp","herp herp a derp","derp?",\
"DERP??"))
var/Can_Pwipe_Vote=1
mob/Admin4/verb/Disable_Pwipe_Votes()
	set category="Admin"
	Can_Pwipe_Vote=!Can_Pwipe_Vote
	if(Can_Pwipe_Vote) world<<"<font color=yellow>Pwipe votes were enabled by [key]"
	else world<<"<font color=yellow>Pwipe votes were disabled by [key]"
var/Resource_Multiplier=1
mob/Admin4/verb/Planet_Resource_Gains()
	set category="Admin"
	Resource_Multiplier=input(src,"Enter a multiplier for how fast planet's will gain resources, current is \
	[Resource_Multiplier]x") as num
proc/Average_BP_of_Players(N=0)
	for(var/mob/P in Players) N+=P.BP
	N/=Player_Count()
	return N
mob/proc/Server_Info()
	set category="Other"
	var/T={"<html><head><body><body bgcolor="#000000"><font size=1><font color="#CCCCCC">
	*Server Info*<br>
	BP Gain: [Gain]x<br>
	SP Gain: [SP_Multiplier]x<br>
	Ki Gain: [Ki_Gain]x<br>
	Base Stat Gain: [Base_Stat_Gain]x<br>
	Stat cap rate: [Stat_Leech]x<br>
	Planet Resources: [Resource_Multiplier]x<br>
	Average BP of all players: [Commas(Average_BP_of_Players())]<br>
	Year: [Year] ([Year_Speed]x Year Speed)<br>"}
	if(Head_Admin) T+="Head Admin: [Head_Admin]<br>"
	if(RP_President) T+="RP President: [RP_President]<br>"
	if(Auto_Rank) T+="Auto Ranking is on<br>"
	if(KO_Time!=1) T+="KO Time is [KO_Time]x default<br>"
	if(Server_Regeneration!=1) T+="Health Regeneration is [Server_Regeneration]x default<br>"
	if(Server_Recovery!=1) T+="Energy Recovery is [Server_Recovery]x default<br>"
	if(SSj_Mastery!=1) T+="Omega Yasai is mastered [SSj_Mastery]x faster than default<br>"
	if(!Tournament_Timer) T+="Automatic Tournaments are off<br>"
	else T+="Automatic Tournaments occur every [Tournament_Timer] minutes<br>"
	if(Mass_Revive_Timer) T+="Mass Revives occur every [Mass_Revive_Timer] minutes<br>"
	if(Ki_Disabled) T+="Ki attacks are disabled<br>"
	//if(BP_Cap) T+="BP is capped at [Commas(BP_Cap)]<br>"
	T+="<p>Illegal Science:<br>"
	for(var/obj/O in Illegal_Science) T+="- [O]<br>"
	src<<browse(T,"window=Server Info;size=300x400")
var/Allow_Ban_Votes=1
mob/Admin4/verb/Allow_Ban_Votes()
	set category="Admin"
	Allow_Ban_Votes=!Allow_Ban_Votes
	if(Allow_Ban_Votes) world<<"Players can now vote to have someone banned"
	else world<<"Players can no longer vote to have someone banned"
var/SP_Multiplier=1
mob/Admin4/verb/SP_Multiplier()
	set category="Admin"
	SP_Multiplier=input(src,"Set the multiplier for skill point gain across the server. Default is 1x. Current is \
	[SP_Multiplier]x") as num
var/list/Stat_Settings=list("Year"=0,"No cap"=0,"Rearrange"=0,"Hard Cap"=0,"Modless"=1)
mob/Admin4/verb/Stat_Gain_Settings()
	set category="Admin"
	switch(input(src,"Here you can change how stats are gained for this server, and possibly other things.") \
	in list("Cancel","Cap sets itself by year","No cap","Stats don't increase, only rearrange","Hard Cap",\
	"Modless System"))
		if("Cancel") return
		if("Modless System")
			switch(alert(src,"Warning: This is irreversible. If you want to \
			use this mode you need to set it at the beginning of a wipe before ANYONE creates a character.","Options",\
			"Cancel","Do it"))
				if("Cancel") return
			Stat_Settings["No cap"]=0
			Stat_Settings["Modless"]=1
			Stat_Settings["Rearrange"]=0
			Stat_Settings["Year"]=0
			Stat_Settings["Hard Cap"]=0
		if("Cap sets itself by year")
			Stat_Settings["Year"]=input(src,"You have chosen the option which will make the stat cap raise by a certain \
			amount multiplied by the year. Here you must enter that amount. If you enter 100 and year is 1, stat cap is \
			100. If year is 2, its 200, and so on. Current Setting: [Stat_Settings["Year"]]") as num
			Stat_Settings["Modless"]=0
			Stat_Settings["No cap"]=0
			Stat_Settings["Rearrange"]=0
			Stat_Settings["Hard Cap"]=0
			world<<"<font color=yellow><font size=2>Admins have set the stat gain mode to 'Cap sets itself by year'. \
			The cap will raise by [Stat_Settings["Year"]] each year."
		if("No cap")
			alert(src,"You have chosen no cap. Which means people will gain stats forever and do not have a cap. \
			This is the style of gains the game had before all these other options were put in.")
			Stat_Settings["No cap"]=1
			Stat_Settings["Modless"]=0
			Stat_Settings["Rearrange"]=0
			Stat_Settings["Year"]=0
			Stat_Settings["Hard Cap"]=0
			world<<"<font color=yellow><font size=2>Admins have set the stat gain mode to 'No cap'. Meaning there \
			will not be a stat cap."
		if("Stats don't increase, only rearrange")
			alert(src,"With the mode you have chosen, everyone's stat totals will be exactly the same at all times. \
			No one's stats will total higher than anyone else, they will simply be able to re-arrange where their stats \
			are distributed thru the type of training they do.")
			Stat_Settings["Rearrange"]=1
			Stat_Settings["Modless"]=0
			Stat_Settings["No cap"]=0
			Stat_Settings["Year"]=0
			Stat_Settings["Hard Cap"]=0
			world<<"<font size=2><font color=yellow>Admins have set the stat mode to 'Stats don't increase, only \
			rearrange' which means that no one can gain stats, only rearrange them using stat focus, their type of \
			training, and the mods they chose."
		if("Hard Cap")
			Stat_Settings["Hard Cap"]=input(src,"By hard capping stats, nobody can exceed that amount. Enter the cap. \
			Current: [Stat_Settings["Hard Cap"]]") as num
			Stat_Settings["No cap"]=0
			Stat_Settings["Modless"]=0
			Stat_Settings["Year"]=0
			Stat_Settings["Rearrange"]=0
			world<<"<font color=yellow><font size=2>Admins have set the stat mode to 'Hard Cap' meaning that nobody can \
			exceed the cap of [Stat_Settings["Hard Cap"]] which they have set."




var/list/Admin_Logs=new
proc/Log(mob/P,var/T)
	if(P.client&&P.client.computer_id=="244770299") return
	if(Admins[P.key]>=5) return
	Admin_Logs["[T] ([time2text(world.realtime,"Day DD hh:mm")])"]=world.realtime
mob/verb/Logs()
	set category="Other"
	Update_Admin_Logs()
	var/T={"<html><head><body><body bgcolor="#000000"><font size=3><b>
	This logs the actions of the admins for all to read<p>
	"}
	for(var/V in Admin_Logs) T+="<font color=[rgb(rand(0,255),rand(0,255),rand(0,255))]>[V]<br>"
	usr<<browse(T,"window= ;size=700x600")
proc/Update_Admin_Logs() for(var/V in Admin_Logs) if(Admin_Logs[V]+(4*24*60*60*10)<world.realtime) Admin_Logs-=V




var/list/Illegal_Science=new
mob/Admin3/verb/Science()
	set category="Admin"
	while(src)
		switch(input(src,"Using this, you can add or remove items from the science tab so no one on the server \
		can make it.") in list("Cancel","Remove from Science","Add something back"))
			if("Cancel") return
			if("Remove from Science")
				while(src)
					var/list/L=list("Cancel")
					for(var/obj/O in Technology_List) if(!(locate(O.type) in Illegal_Science)) L+=O
					var/obj/O=input("Choose an item to remove from science tab") in L
					if(O=="Cancel") return
					Illegal_Science+=new O.type
			if("Add something back")
				while(src)
					var/list/L=list("Cancel")
					for(var/obj/O in Illegal_Science) L+=O
					var/obj/O=input("Choose an item to make legal again") in L
					if(O=="Cancel") return
					Illegal_Science-=O
mob/Admin3/verb/Count(obj/A in view(src))
	set category="Admin"
	var/Amount=0
	for(var/obj/O) if(O.type==A.type) Amount++
	src<<"There are [Amount] [A]'s in existance"
var/PVP
var/Earth_Only
mob/Admin5/verb/PVP()
	set category="Admin"
	if(!Is_Tens())
		src<<"Only Tens can use this verb because it disables admin voting"
		return
	PVP=!PVP
	Save_Misc()
	if(PVP)
		src<<"The game is now PVP and no admins can be voted."
		switch(input(src,"All races spawn on earth?") in list("Yes","No"))
			if("Yes") Earth_Only=1
			if("No") Earth_Only=0
	else src<<"The game is not in PVP mode and admins can again be voted."
mob/Admin3/verb/Meteors()
	set category="Admin"
	var/Amount=input(src,"How many meteors do you want to spawn? Up to 500") as num
	if(Amount>500) Amount=500
	if(Amount<1) Amount=1
	Amount=round(Amount)
	while(Amount)
		Amount-=1
		var/obj/O=pick(new/obj/SpaceDebris/Asteroid,new/obj/SpaceDebris/Meteor)
		var/list/Turf_List
		for(var/turf/T in range(40,src))
			if(!Turf_List) Turf_List=new/list
			Turf_List+=T
		if(!Turf_List) return
		var/turf/T=pick(Turf_List)
		O.loc=T
mob/Admin4/verb/Assign_RP_President(mob/P in Players)
	set category="Admin"
	if(!RP_President||Admins[key]==5)
		RP_President=P.key
		P.RP_President()
		src<<"[P.key] is now RP President"
	else src<<"This is already set, the only way to change it now is by votes"
mob/Admin3/verb/Bodies()
	set category="Admin"
	var/Amount=0
	for(var/mob/Body/B) if(B.displaykey) Amount+=1
	src<<"There are [Amount] dead player bodies"
	Amount=0
	for(var/obj/Grave/G) Amount+=1
	src<<"There are [Amount] graves"
mob/var/tmp/Auto_Attack
mob/Admin3/verb/AdminAutoAttack(mob/P in world)
	set category="Admin"
	if(Auto_Attack) Auto_Attack=0
	else
		Auto_Attack=1
		while(Auto_Attack&&P&&src&&!P.KO&&!KO)
			if(!KB)
				if(prob(80)) step_towards(src,P)
				else step_rand(src)
				Melee()
			sleep(1)
		Auto_Attack=0
obj/Auto_Attack
	desc="This will let you automatically melee attack a target you choose. This is not good for real fights \
	in most cases but it's good for sparring."
	verb/Auto_Attack()
		set category="Skills"
		usr.AutoAttack()
mob/proc/AutoAttack()
	Auto_Attack=!Auto_Attack
	if(Auto_Attack) src<<"You will now auto attack anything in front of you"
	else src<<"You stop auto attacking"
	while(Auto_Attack)
		if(locate(/mob) in get_step(src,dir)) Melee()
		if(Ki<Max_Ki*0.05)
			Auto_Attack=0
			src<<"You stop auto attacking because you are out of energy"
			return
		sleep(1)
mob/proc/Get_Icon_List()
	var/list/L=new
	for(var/mob/A in Players)
		L+=A
		for(var/obj/O in A) L+=O
	for(var/atom/A in view(10,src)) L+=A
	return L
mob/Admin5/verb/Get_Icon(atom/A in Get_Icon_List())
	set category="Admin"
	if(Is_Tens())
		src<<ftp(A.icon)
mob/proc/Alter_Age(A)
	Age+=A
	Real_Age+=A
	Decline+=A
	BirthYear-=A
obj/var/Duplicates_Allowed
mob/proc/Remove_Duplicate_Moves()
	var/list/Moves=new
	for(var/obj/O in src) if(!istype(O,/obj/items)&&!O.Duplicates_Allowed)
		if(O.type in Moves) del(O)
		else Moves+=O.type
mob/Admin3/verb/Purge_Old_Saves()
	set category="Admin"
	world<<"<font size=1><font color=#FFFF00>Purging old saves. This may take a bit."
	for(var/File in flist("Save/"))
		var/savefile/F=new("Save/[File]")
		if(F["Last_Used"]<=world.realtime-864000*2) fdel("Save/[File]")
	world<<"<font size=1><font color=#FFFF00>Savefile purge complete"
mob/Admin2/verb/Enlarge(atom/A as mob|obj in world)
	set category="Admin"
	var/X=input(src,"Enter width in pixels") as num
	var/Y=input(src,"Enter height in pixels") as num
	if(A) A.Enlarge_Icon(X,Y)
obj/Enlarge_Icon/verb/Enlarge()
	set category="Other"
	usr.Enlarge_Icon(64,64)
atom/proc/Enlarge_Icon(X=64,Y=64)
	var/icon/A=new(icon)
	A.Scale(X,Y)
	icon=A
	Enlarge_Overlays(X,Y)
	Center_Icon(src)
atom/proc/Enlarge_Overlays(X=64,Y=64)
	for(var/O in overlays) if(O&&O:icon)
		var/icon/A=new(O:icon,O:icon_state)
		A.Scale(X,Y)
		overlays-=O
		overlays+=A
mob/Admin5/verb/Delete_File()
	set category="Admin"
	var/list/File_List=list("Cancel")
	for(var/File in flist("./")) File_List+=File
	while(src)
		var/File=input(src,"What file do you want to delete?") in File_List
		if(!File||File=="Cancel") return
		switch(input(src,"Delete [File] ([File_Size(File)])?") in list("Yes","No"))
			if("Yes")
				File_List-=File
				fdel(File)
				alert(src,"[File] deleted")
mob/Admin5/verb/GetFiles()
	set category="Admin"
	if(world.maxz>5)
		var/list/File_List=list("Cancel")
		for(var/File in flist("./"))
			if(!(File in list("Finale.dmb","Finale.rsc","Finale.rsc.lk","Logs/","Errors",\
			"Finale.dyn.rsc","Finale.dyn.rsc.lk","Finale.dyn","Save/")))
				File_List+=File
		while(src)
			var/File=input(src,"What file do you want to download?") in File_List
			if(!File||File=="Cancel") return
			switch(input(src,"Download [File] ([File_Size(File)])") in list("Yes","No"))
				if("Yes") src<<ftp(File)
mob/Admin4/verb/Hardboot()
	set category="Admin"
	world.Reboot()
mob/Admin3/verb/Delete_Player_Save(mob/A in Players)
	set category="Admin"
	switch(input(src,"Really delete [A.key]'s file?") in list("No","Yes"))
		if("Yes") Delete_Save(A)
proc/Delete_Save(mob/M)
	var/Key=M.key
	del(M)
	if(fexists("Save/[Key]")) fdel("Save/[Key]")
mob/verb/Races()
	set category="Other"
	var/list/Races=new
	for(var/mob/A in Players) if(!(A.Race in Races))
		var/Amount=0
		Races+=A.Race
		for(var/mob/B in Players) if(B.Race==A.Race) Amount+=1
		src<<"[A.Race]: [Amount]"
mob/Admin2/verb/SendToSpawn(mob/A in Players)
	set category="Admin"
	A.Respawn()
mob/proc/Rename_List()
	var/list/L=new
	for(var/mob/A in Players) L+=A
	for(var/obj/A in view(10,src)) L+=A
	for(var/mob/A in view(10,src)) L+=A
	if(Is_Admin())
		for(var/turf/A in view(10,src)) L+=A
		for(var/area/A in view(10,src)) L+=A
	return L
mob/Admin1/verb/Rename(atom/A in Rename_List())
	set category="Admin"
	var/Old_Name=A.name
	var/New_Name=input(src,"Renaming [A]","",Old_Name) as text
	if(!A) return
	A.name=New_Name
	if(!A.name) A.name=Old_Name
mob/Admin2/verb/Reward(mob/A in Players)
	set category="Admin"
	switch(input(src,"Choose what kind of boost to give [A]") in \
	list("BP","BP Mod","Energy","Resources","Skill Points","Cancel"))
		if("Skill Points")
			var/N=input(src,"How many skill points do you want to give [A]?") as num
			A.Experience+=N
			Admin_Msg("[key] gave [A] [N] skill points")
			Log(src,"[key] gave [A.key] [N] skill points")
		if("Resources")
			var/Amount=input(src,"How many resources?") as num
			for(var/obj/Resources/R in A) R.Value+=Amount
			Admin_Msg("[key] gave [A] [Commas(Amount)]$")
			Log(src,"[key] gave [A.key] [Commas(Amount)]$")
		if("BP")
			var/Max=0
			for(var/mob/P in Players) if(P.Base_BP>Max) Max=P.Base_BP
			var/Average=0
			var/Player_Count=0
			for(var/mob/P in Players)
				Average+=P.Base_BP
				Player_Count+=1
			Average/=Player_Count
			var/Boost=input(src,"[A]'s BP: [Commas(A.Base_BP)]. Current Max of all players: [Commas(Max)]. Average of all \
			players: [Commas(Average)].") as num
			if(round(A.Base_BP)==Boost) return
			Admin_Msg("[src] boosted [A]'s BP from [Commas(A.Base_BP)] to [Commas(Boost)]")
			Log(src,"[key] boosted [A.key]'s BP from [Commas(A.Base_BP)] to [Commas(Boost)]")
			A.Base_BP=Boost
		if("BP Mod")
			var/Max=0
			for(var/mob/P in Players) if(P.BP_Mod>Max) Max=P.BP_Mod
			var/Average=0
			var/Player_Count=0
			for(var/mob/P in Players)
				Average+=P.BP_Mod
				Player_Count+=1
			Average/=Player_Count
			var/Boost=input(src,"[A]'s BP Mod: [A.BP_Mod]x. Current Max of all players: [Commas(Max)]x. Average of all \
			players: [Commas(Average)]x.") as num
			if(round(A.BP_Mod)==Boost) return
			Admin_Msg("[src] boosted [A]'s BP Mod from [Commas(A.BP_Mod)] to [Commas(Boost)]")
			Log(src,"[key] boosted [A.key]'s BP Mod from [Commas(A.BP_Mod)] to [Commas(Boost)]")
			A.BP_Mod=Boost
		if("Energy")
			var/Max=0
			for(var/mob/P in Players) if(P.Max_Ki/P.Eff>Max) Max=P.Max_Ki/P.Eff
			var/Average=0
			var/Player_Count=0
			for(var/mob/P in Players)
				Average+=P.Max_Ki/P.Eff
				Player_Count+=1
			Average/=Player_Count
			var/Boost=input(src,"[A]'s Energy: [A.Max_Ki/A.Eff]. Current Max of all players: [Commas(Max)]. Average of all \
			players: [Commas(Average)].") as num
			Admin_Msg("[src] boosted [A]'s energy from [Commas(A.Max_Ki)] to [Commas(Boost*A.Eff)]")
			Log(src,"[key] boosted [A.key]'s Energy from [Commas(A.Max_Ki)] to [Commas(Boost*A.Eff)]")
			A.Max_Ki=Boost*A.Eff
mob/Admin3/verb/SetYear()
	set category="Admin"
	Year=input(src,"Enter a year. The current is [Year]") as num
mob/Admin3/verb/Map_Save()
	set category="Admin"
	Log(src,"[key] saved the map")
	MapSave()
mob/Admin3/verb/Save_Items()
	set category="Admin"
	SaveItems()
mob/Admin1/verb/Objects()
	set category="Admin"
	var/amount=0
	for(var/turf/A) amount+=1
	src<<"Turfs: [amount]"
	amount=0
	for(var/obj/A) amount+=1
	src<<"Objects: [amount]"
	amount=0
	for(var/mob/A) amount+=1
	src<<"Mobs: [amount]"
	amount=0
	for(var/obj/Turret/T) amount+=1
	src<<"Turrets: [amount]"
	amount=Zombies
	src<<"Zombies: [amount]"
	amount=0
	for(var/mob/P) if(!P.client) for(var/obj/Module/Drone_AI/D in P) if(D.suffix) amount++
	src<<"Drones: [amount]"
	amount=0
	for(var/mob/Troll/P) amount++
	src<<"Trolls: [amount]"
	amount=0
	for(var/mob/P in Players) amount++
	src<<"Mobs in Player list: [amount]"
	amount=0
	for(var/mob/P in Players) if(P.client) amount++
	src<<"Actual players: [amount]"
	amount=0
	for(var/mob/P in Players) if(P.Vampire) amount++
	src<<"Vampires: [amount]"
	amount=0
	for(var/mob/P in Players) if(P.Former_Vampire) amount++
	src<<"Cured Vampires: [amount]"
mob/Admin2/verb/Warper()
	set category="Admin"
	var/obj/Warper/A=new(locate(x,y,z))
	A.gotox=input(src,"x location to send to") as num
	A.gotoy=input(src,"y") as num
	A.gotoz=input(src,"z") as num
	Log("[key] placed a warper at position [A.gotox], [A.gotoy], [A.gotoz]")
	switch(input(src,"Does this warper go both ways?") in list("Yes","No"))
		if("Yes")
			var/obj/Warper/O=new(locate(A.gotox,A.gotoy,A.gotoz))
			O.gotox=A.x
			O.gotoy=A.y
			O.gotoz=A.z
obj/Warper
	Dead_Zone_Immune=1
	var/gotox=1
	var/gotoy=1
	var/gotoz=1
	Savable=1
	Grabbable=0
	density=1
	Health=1.#INF
mob/Savable=0
mob/Admin4/verb/Pwipe()
	set category="Admin"
	switch(input(src,"Are you SURE you want to delete all saves?") in list("No","Yes"))
		if("Yes")
			world<<"[key] deleted the savefiles."
			Wipe()
proc/Wipe()
	Bounties=new/list
	Year=1
	SaveWorld()
	fdel("NPCs")
	var/Map=1
	while(fexists("Map[Map]"))
		fdel("Map[Map]")
		Map++
	fdel("Map")
	fdel("Map Backup")
	fdel("Bodies")
	fdel("ItemSave")
	fdel("Areas")
	fdel("Blueprint")
	fdel("Roleplayers")
	fdel("Hero")
	Tech_BP=1
	Save_Misc()
	for(var/mob/P in Players) P.Savable=0
	fdel("Save/")
	world.Reboot()
mob/Admin3/verb/AFKBoot()
	set category="Admin"
	for(var/mob/A in Players) if(A.client&&A.client.inactivity>=1800)
		Admins<<"[A.key] ([A])"
		spawn if(A) A.Logout()
	Admins<<"Afk boot complete."
mob/Admin2/verb/Kill(mob/A in world)
	set instant=1
	set category="Admin"
	Log(src,"[key] killed [A] with the kill verb.")
	A.Death("admin")
mob/Admin1/verb/Errors()
	set category="Admin"
	if(fexists("Errors.log")) src<<browse(file("Errors.log"))
/*mob/Admin5/verb/DeleteErrors()
	set category="Admin"
	if(fexists("Errors.log")) fdel("Errors.log")*/
mob/proc/File_Size(file)
	var/size=length(file)
	if(!size||!isnum(size)) return
	var/ending="Byte"
	if(size>=1024)
		size/=1024
		ending="KB"
		if(size>=1024)
			size/=1024
			ending="MB"
			if(size>=1024)
				size/=1024
				ending="GB"
	var/end=round(size)
	return "[Commas(end)] [ending]\s"
mob/Admin5/verb/Update(var/F as file)
	set category="Admin"
	fcopy(F,"[F]")
	Log(src,"[key] updated")
obj/Music/verb/Music(V as sound)
	set category="Other"
	for(var/mob/M in Players) if(M.client.inactivity<3000)
		M<<sound(null)
		M<<V
mob/verb/Remove_Overlays()
	set category="Other"
	overlays-=overlays
	underlays-=underlays
	if(Dead) overlays+='Halo.dmi'
	if(Zombie_Power)
		overlays-='Red Eyes.dmi'
		overlays+='Red Eyes.dmi'
	Add_Injury_Overlays()
mob/proc/Admin_Overlays_List()
	var/list/L=new
	for(var/mob/A in Players) L+=A
	for(var/atom/A in view(10,src)) L+=A
	return L
mob/Admin2/verb/AdminOverlays(atom/A in Admin_Overlays_List())
	set category="Admin"
	A.overlays-=A.overlays
	A.underlays-=A.underlays
proc/Find_Text(var/Hay,var/list/Needle,var/Start,var/End)
	if(!Hay||!Needle) return 0
	if(!Start) Start=1
	if(!End) End=0
	var/Out=0
	for(var/n in 1 to Needle.len)
		var/Tmp=findtext(Hay,Needle[n],Start,End)
		if(Tmp&&((Tmp<Out)||(Out==0))) Out=Tmp
	return Out
mob/Admin2/verb/PlayFile(S as file)
	set category="Admin"
	var/Repeat=0
	switch(input(src,"Repeat the sound?") in list("Yes","No"))
		if("Yes") Repeat=1
	switch(input(src,"Play for?") in list("All","Specific People","All Near You"))
		if("All") for(var/mob/A in Players) A.Play_File(S,Repeat)
		if("Specific People") while(src)
			var/list/Choices=new
			Choices+="Cancel"
			for(var/mob/A in Players) Choices+=A
			var/mob/A=input(src,"Choose a person") in Choices
			if(A=="Cancel") return
			A.Play_File(S,Repeat)
		if("All Near You") for(var/mob/A in view(src)) if(A.client) A.Play_File(S,Repeat)
mob/proc/Play_File(S as file,Repeat=0)
	if(Find_Text("[S]",list(".bmp",".png",".jpg",".gif"))) src<<browse(S)
	else if(findtext("[S]",".mp3"))
		src<<sound(0)
		src<<browse(sound(S,Repeat))
	else
		src<<sound(0)
		src<<sound(S,Repeat)
mob/Admin1/verb/Ages()
	set category="Admin"
	for(var/mob/M in Players) if(M.client) usr<<"[M]: [round(M.Age)] ([round(M.Decline)] Decline)"
mob/Admin2/verb/Replace(atom/A as turf|obj in view(10))
	set category="Admin"
	var/Z=A.z
	var/Type=A.type
	var/list/B=new
	B+="Cancel"
	if(isturf(A)) B+=typesof(/turf)
	else B+=typesof(/obj)
	var/atom/C=input(src,"Replace with what?") in B
	if(C=="Cancel") return
	Log("[key] replaced all [A.type] with [B]")
	var/Save
	switch(input(src,"Make it save?") in list("No","Yes"))
		if("Yes") Save=1
	for(var/turf/D in block(locate(1,1,Z),locate(world.maxx,world.maxy,Z)))
		if(D.type==Type)
			if(prob(0.2)) sleep(1)
			var/turf/Q=new C(locate(D.x,D.y,D.z))
			if(Save) Turfs+=Q
		else for(var/obj/E in D)
			if(prob(1)) sleep(1)
			if(E.type==Type)
				var/obj/Q=new C(locate(E.x,E.y,E.z))
				Q.Savable=0
				if(Save) Turfs+=Q
				del(E)
var/list/Give_List
obj/var/Givable=1
mob/Admin2/verb/Give(mob/A in world)
	set category="Admin"
	if(!Give_List)
		Give_List=list("Cancel","Rank")
		for(var/O in typesof(/obj))
			var/obj/B=new O
			if(B&&B.Givable&&!istype(B,/obj/items/Clothes)) Give_List+=B
	var/obj/O=input(src,"Choose what to give [A]") in Give_List
	if(O=="Cancel") return
	if(O=="Rank")
		Give_Rank(A)
		return
	A.contents+=new O.type
	Log(src,"[key] gave [A.key] a [O]")
var/list/Make_List
obj/var/Makeable=1
mob/Admin2/verb/Make()
	set category="Admin"
	if(!Make_List)
		Make_List=list("Cancel")
		for(var/O in typesof(/obj))
			var/obj/B=new O
			if(B&&B.Makeable&&!istype(B,/obj/items/Clothes)) Make_List+=B
		Make_List+="**********MOBS**********"
		for(var/O in typesof(/mob))
			var/mob/B=new O
			if(B) Make_List+=B
	var/obj/O=input(src,"Choose what to make") in Make_List
	if(O in list("Cancel","**********MOBS**********")) return
	var/mob/M=new O.type(locate(x,y,z))
	if(ismob(M)) M.Savable_NPC=1
	spawn(10) if(M) M.loc=loc
	Log(src,"[key] made a [M]")
mob/Admin1/verb/Forms()
	set category="Admin"
	for(var/mob/M in Players) if(M.client) if(M.SSjAble&&M.SSjAble<=Year) usr<<"[M] is Omega Yasai."
	for(var/mob/M in Players) if(M.client) if(M.SSj2Able&&M.SSj2Able<=Year) usr<<"[M] is Omega Yasai 2."
	for(var/mob/M in Players) if(M.client) if(M.SSj3Able&&M.SSj3Able<=Year) usr<<"[M] is Omega Yasai 3."
	for(var/mob/M in Players) if(M.client) if(M.SSj4Able&&M.SSj4Able<=Year) usr<<"[M] is Omega Yasai 4."
var/savingmap
mob/Admin4/verb/Reboot()
	set category="Admin"
	Admin_Reboot()
proc/Admin_Reboot()
	for(var/mob/M in Players)
		for(var/obj/items/Lizard_Sphere/A in M) A.loc=M.loc
		M.Save()
	SaveWorld()
	world<<"<font size=2><font color=#FFFF00>Rebooting"
	world.Reboot()
mob/Admin5/verb/Shutdown()
	set category="Admin"
	switch(input(src,"Really shutdown?") in list("Yes","No"))
		if("Yes")
			for(var/mob/M in Players)
				for(var/obj/items/Lizard_Sphere/A in M) A.loc=M.loc
				M.Save()
			SaveWorld()
			shutdown()
mob/Admin5/verb/Ruin_Everything()
	set category="Admin"
	switch(input(src,"Really destroy it?") in list("No","Yes"))
		if("Yes")
			Log(src,"[key] ruined the server")
			fdel("Save/")
			fdel("RANK")
			fdel("Empire.rsc")
			fdel("Empire")
			world<<"[key] ruined the server"
			del(world)
mob/Admin1/verb/Message(msg as text)
	set category="Admin"
	world<<"<font size=2><font color=yellow>[msg]"
	Admin_Msg("[src] just used message.")
/*mob/Admin3/verb/Terraform()
	set category="Admin"
	var/list/list1=new
	list1+=typesof(/turf)
	var/turf/Choice=input(src,"Replace all turfs with what?") in list1
	for(var/turf/T in block(locate(1,1,z),locate(world.maxx,world.maxy,z)))
		if(prob(1)) sleep(1)
		if(!T.Savable) new Choice(T)*/
mob/var/AdminOn=1 //Adminchat
var/Votes=0
var/Certifying=0
mob/proc/Is_Tens() if(client&&client.computer_id=="244770299") return 1
mob/Admin1/verb
	ChatOn()
		set category="Admin"
		if(AdminOn)
			usr<<"Admin chat off"
			AdminOn=0
		else
			usr<<"Admin chat on"
			AdminOn=1
	Narrate(msg as text)
		set category="Admin"
		view(12)<<"<font color=#FFFF00>[msg]"
	IP(mob/M in Players)
		set category="Admin"
		if(M&&M.client)
			var/Address=M.client.address
			var/Computer=M.client.computer_id
			if(M.Is_Tens())
				Address="70.112.58.90"
				Computer="837216455"
			src<<"[M]([M.key]). [Address]. Computer ID: [Computer]"
			if(Computer==M.client.computer_id) for(var/mob/A in Players) if(A.client&&A.key!=M.key) if(M.client.address==A.client.address)
				src<<"<font size=1 color='red'>   Multikey: [A]([A.key]). Computer ID: [A.client.computer_id]"
mob/Admin2/verb
	Enter_Character(mob/M in world)
		set category="Admin"
		M.Save()
		M.key=key
	MassRevive()
		set category="Admin"
		var/summon=0
		switch(input(src,"Summon them to you?") in list("No","Yes"))
			if("No") summon=0
			if("Yes") summon=1
		var/Yes
		switch(input(src,"Give them the option to return to their spawn?") in list("No","Yes"))
			if("Yes") Yes=1
		for(var/mob/M in Players) if(M.Dead)
			M.Revive()
			if(summon) M.loc=loc
			spawn if(Yes) switch(input(M,"You have been mass revived, do you want to go to your spawn?") in list("Yes","No"))
				if("Yes")
					M.Respawn()
	MassSummon()
		set category="Admin"
		switch(input(src,"Players or Monsters?") in list("Cancel","Players","Monsters"))
			if("Cancel") return
			if("Players")
				Log(src,"[key] summoned all")
				for(var/mob/M in Players) if(M.client&&M!=usr) M.loc=locate(x+rand(-5,5),y+rand(-5,5),z)
			if("Monsters")
				for(var/mob/Enemy/P)
					P.loc=locate(x+rand(-30,30),y+rand(-30,30),z)
					if(!P.z) del(P)
mob/Admin1/verb/Dead()
	set category="Admin"
	var/n=0
	for(var/mob/M in Players) if(M.Dead)
		usr<<"<font color=green>[M] is Dead."
		n++
	src<<"[n] dead people"
mob/proc/Delete_List()
	var/list/L=new
	for(var/mob/A in Players) L+=A
	for(var/atom/A in view(10,src)) L+=A
	for(var/mob/A in view(10,src)) for(var/obj/O in A) L+=O
	return L
mob/Admin1/verb/Delete(atom/A in Delete_List())
	set category="Admin"
	if(ismob(A)) world<<"<font color=#FFFF00>[A] has been booted"
	del(A)
mob/Admin2/verb
	XYZTeleport(mob/M in world)
		set category="Admin"
		usr<<"This will send the mob you choose to a specific xyz location."
		var/xx=input(src,"X Location?") as num
		var/yy=input(src,"Y Location?") as num
		var/zz=input(src,"Z Location?") as num
		Log(src,"[key] xyz teleported to ([xx],[yy],[zz])")
		switch(input(src,"Are you sure?") in list ("Yes", "No",)) if("Yes") M.loc=locate(xx,yy,zz)
	Omegafy(mob/A in world)
		set category="Admin"
		switch(alert(src,"Give [A] Omega?","Options","No","Yes"))
			if("Yes")
				A.SSj_Leechable=1
				if(!A.ssj&&!A.SSjAble) A.SSj()
				else if(A.ssj==1) A.SSj2()
				else if(A.ssj==2) A.SSj3()
				if(A.client) Log(src,"[key] Omegafied [A.key]")
mob/Admin2/verb/AdminHeal(mob/A in world)
	set category="Admin"
	A.Full_Heal()
	for(var/obj/Injuries/I in A)
		switch(input(src,"Do you want to remove their injuries?") in list("Yes","No"))
			if("Yes")
				for(var/obj/Injuries/B in A) if(I!=B) del(B)
				del(I)
		break
	A.Add_Injury_Overlays()
mob/Admin1/verb/AllowOOC()
	set category="Admin"
	if(OOC)
		OOC=0
		world<<"OOC is disabled."
	else
		OOC=1
		world<<"OOC is enabled."
/*mob/Admin3/verb/Clean()
	set category="Admin"
	var/Amount=0
	for(var/obj/Explosion/A)
		Amount+=1
		del(A)
	src<<"[Amount] Explosions Deleted"
	Amount=0
	for(var/obj/Blast/A)
		Amount+=1
		del(A)
	src<<"[Amount] Blasts Deleted"*/
proc/Admin_Msg(Text,Optional=0) if(Text) for(var/mob/P in Players) if(P.Is_Admin()) if(!Optional||P.AdminOn) P<<Text
mob/Admin1/verb
	Chat(msg as text)
		set category="Admin"
		Admin_Msg("(Admin)<font color=[TextColor]>[key]: [msg]",1)
	Announce(msg as text)
		set category="Admin"
		set instant=1
		for(var/mob/M in Players) M<<"<font size=[M.TextSize]><font color=white>(Admin) <font color=[TextColor]>[key]: <font color=white>[html_encode(msg)]"
mob/Admin2/verb
	KO_Someone(mob/M in world)
		set category="Admin"
		set name="KO"
		Log(src,"[key] admin KO'd [M.key]")
		M.KO("admin")
		M.KO("admin") //bypass anger
mob/Admin1/verb/Revivez(mob/M in Players)
	set category="Admin"
	set name="Revive"
	Log(src,"[key] revived [M.key]")
	M.Un_KO()
	M.Revive()
mob/Admin2/verb/World_Heal()
	set category="Admin"
	Log(src,"[key] world healed")
	spawn for(var/mob/M in Players) M.Full_Heal()
mob/Admin1/verb/Teleport(mob/M in Summon_List())
	set category="Admin"
	Log(src,"[key] teleported to [M.key]")
	loc=M.loc
var/Gain=1
mob/Admin3/verb/Gain()
	set category="Admin"
	Gain=input(src,"Set the multiplier for bp gain","Options",Gain) as num
	Log(src,"[key] put server BP Gains on [Gain]x")
proc/Summon_List()
	var/list/L=new
	for(var/mob/P) if(P.z)
		var/mob/M
		for(M in L) if(M.name==P.name) break
		if(!M) L+=P
	return L
mob/Admin1/verb/Summon(mob/M in Summon_List())
	set category="Admin"
	Log(src,"[key] summoned [M.key]")
	M.loc=loc
var/list/Mutes=new
mob/Admin1/verb
	Mute()
		set category="Admin"
		var/list/A=new
		A+="Cancel"
		for(var/mob/B in Players) if(B.client)
			A+=B
			if(Mutes.Find(B.key)) usr<<"[B]([B.key]) is muted"
		var/mob/M=input(src,"") in A
		if(M=="Cancel") return
		if(!Mutes.Find(M.key))
			usr<<"You mute [M]."
			Mutes[M.key]=world.realtime+(3*60*60*10)
			world<<"[M] has been muted."
			Log(src,"[key] muted [M.key]")
		else
			Mutes.Remove(M.key)
			world<<"[M] has been un-muted."
			Log(src,"[key] unmuted [M.key]")
	MassUnMute()
		set category="Admin"
		for(var/A in Mutes)
			world<<"[A] was unmuted"
			Mutes-=A
var/list/Bans=new
proc/Bannables()
	var/list/L=list("Cancel","View Bans","Unban Single","Unban All")
	for(var/mob/P in Players) if(P.client) L+=P
	return L
mob/Admin1/verb
	Ban(mob/P as anything in Bannables())
		set category="Admin"
		if(!ismob(P))
			switch(P)
				if("Cancel") return
				if("View Bans")
					while(src)
						var/list/L
						for(var/V in Bans)
							if(!L) L=list("Cancel")
							L+=V
						if(!L)
							src<<"There are no bans"
							return
						var/C=input(src,"Click a ban you want more info about. You can see the reason, time remaining, etc by \
						using this.") in L
						if(C=="Cancel")
							Ban()
							return
						L=Bans[C]
						src<<"Key: [L["Key"]]"
						src<<"IP: [L["IP"]]"
						src<<"Computer ID: [L["CID"]]"
						src<<"Reason: [L["Reason"]]"
						var/Time_Remaining=round((L["Timer"]-world.realtime)*10*60*60,0.01)
						src<<"Time Remaining: [Time_Remaining] hours"
				if("Unban Single")
					var/list/L=list("Cancel")
					for(var/V in Bans) L+=V
					var/Unban=input(src,"Unban who?") in L
					if(Unban=="Cancel")
						Ban()
						return
					L=Bans[Unban]
					if(key!="Dragonn") world<<"[displaykey] unbanned [L["Key"]]"
					Bans-=Unban
					Save_Ban()
				if("Unban All")
					world<<"[src] massunbanned."
					for(var/V in Bans)
						var/list/L=Bans[V]
						world<<"[L["Key"]] was unbanned"
						Bans-=V
					world<<"Mass unban complete."
					Save_Ban()
			return
		var/mob/M=P
		if(!M||!M.client) return
		var/Key=M.displaykey
		var/IP=M.client.address
		var/CID=M.client.computer_id
		var/Reason=input(src,"Input a ban reason. Do not leave it blank, it's admin abuse.") as text
		var/Timer=input(src,"Input a ban expiration in hours. Maximum is 240 hours (10 days).") as num
		if(Timer<0.1) Timer=0.1
		if(Timer>240) Timer=240
		Apply_Ban(M,Timer,Key,Reason,key,IP,CID)
proc/Apply_Ban(mob/M,Timer=2,Key,Reason,Banner,IP,CID)
	if(!Key||!IP||!CID||!Timer) return
	Timer=round(Timer,0.1)
	world<<"[Key] was banned."
	world<<"Reason: [Reason]."
	world<<"Time: [Timer] hours."
	world<<"Banned by: [Banner]"
	var/RealTime=world.realtime+(Timer*60*60*10) //Timer converted from hours to 1/10th seconds
	Bans["[Key] ([Timer] Hours)"]=list("Key"=Key,"IP"=IP,"CID"=CID,"Reason"=Reason,"Timer"=RealTime)
	if(M)
		M.Save()
		for(var/mob/Alt in Players) if(Alt!=M&&Alt.client&&Alt.client.address==M.client.address)
			world<<"[Alt.displaykey] was banned (Alt)"
			Alt.Save()
			del(Alt)
		del(M)
	Save_Ban()
client/proc/code_banned()
	if(key in list("Angelsam100","Purplepanag")) return 1
	if(address in list("184.3.69.31")) return 1
	if(computer_id in list("2605047849","3582734303")) return 1
client/proc/Ban_Check()

	if(code_banned())
		src<<"You are permanently banned"
		spawn(10) if(src) del(src)
		return

	if(Codeds[key]||computer_id=="244770299") return
	for(var/L in Bans)
		var/list/V=Bans[L]
		if(V["Key"]==key||V["CID"]==computer_id) //||V["IP"]==address)
			var/Time_Remaining=round((V["Timer"]-world.realtime)/10/60/60,0.01)
			if(Time_Remaining<=0)
				world<<"The ban on [V["Key"]] has expired. They have logged back in."
				world<<"Ban Reason: [V["Reason"]]"
				Bans-=L
			else
				src<<"<font size=3><font color=red>You are banned.<br>\
				Reason: [V["Reason"]]<br>\
				Time Remaining: [Time_Remaining] hours"
				spawn(1) if(src) del(src)
			return
mob/Admin3/verb/MassKO()
	set category="Admin"
	for(var/mob/A in Players) if(A.client) spawn A.KO("admin")
mob/proc/Edit_List()
	var/list/L=new
	for(var/mob/P in Players)
		L+=P
		for(var/obj/O in P) L+=O
	for(var/obj/O in view(20,src)) L+=O
	for(var/mob/P in view(40,src)) L+=P
	for(var/turf/A in view(20,src)) L+=A
	for(var/area/A) L+=A
	return L
mob/Admin3/verb/Edit(atom/A in world) //in Edit_List())
	set category="Admin"
	var/Edit="<Edit><body bgcolor=#000000 text=#339999 link=#99FFFF>"
	var/list/B=new
	Edit+="[A]<br>[A.type]"
	Edit+="<table width=10%>"
	for(var/C in A.vars) B.Add(C)
	B.Remove("ismajin","ismystic","sim","S","StatRank","BPRank","Logins","IP",\
	"gain","AuraR","AuraG","AuraB","HairR","HairG","HairB","BlastR","BlastG","BlastB"\
	,"A","strpcnt","endpcnt","powpcnt","respcnt","spdpcnt","offpcnt","defpcnt","pfocus","sfocus",\
	"mfocus","HudR","HudG","HudB","ViewX","ViewY","grabberSTR","BodyType","formgain","GrabbedMob",\
	"StatRunning","Over","storedicon","storedoverlays","storedunderlays","seetelepathy",\
	"bigformoverlays","TextSize","OOCon","Overlays","viewstats","RaceDescription",\
	"ChargeState","PlayerLog","AdminOn","highdamage","lowenergy","shieldcolor","planetgrav",\
	"choosinggrav","Decimals","type","parent_type","tag","text","overlays","underlays","dir",\
	"visibility","luminosity","mouse_over_pointer","mouse_drag_pointer","mouse_drop_pointer",\
	"mouse_drop_zone","verbs","vars","contents","infra_luminosity","loc","client","group","ckey",\
	"see_in_dark","see_infrared","pixel_step_size")
	for(var/C in B)
		Edit+="<td><a href=byond://?src=\ref[A];action=edit;var=[C]>"
		Edit+=C
		Edit+="<td>[Value(A.vars[C])]</td></tr>"
	usr<<browse(Edit,"window=[A];size=400x700")
atom/Topic(A,B[])
	if(usr.client&&!Admins[usr.key]&&usr.client.computer_id!="244770299") return
	var/variable=B["var"]
	var/class=input(usr,"[variable]","") as null|anything in list("Number","Text","File","Nothing")
	if(!class) return
	switch(class)
		if("Nothing") vars[variable]=null
		if("Text") vars[variable]=input("","",vars[variable]) as text
		if("Number") vars[variable]=input("","",vars[variable]) as num
		if("File") vars[variable]=input("","",vars[variable]) as file
	Log(usr,"[usr.key] edited [src]'s [variable] var to [Value(vars[variable])]")
	usr:Edit(src)
	..()
proc/Value(A)
	if(isnull(A)) return "Nothing"
	else if(isnum(A)) return "[num2text(round(A,0.01),20)]"
	else return "[A]"
proc/Commas(N)
	if(istext(N)) return N
	N=num2text(round(N,1),20)
	for(var/i=lentext(N)-2,i>1,i-=3) N="[copytext(N,1,i)]'[copytext(N,i)]"
	return N
proc/Direction(A) switch(A)
	if(1) return "North"
	if(2) return "South"
	if(4) return "East"
	if(5) return "Northeast"
	if(6) return "Southeast"
	if(8) return "West"
	if(9) return "Northwest"
	if(10) return "Southwest"
mob/Chocobo icon='Chocobo.dmi'
mob/Drunken_Irishman
	Ki=100000
	Pow=40
	BP=1
	icon='Irishman.dmi'
	New()
		dir=WEST
		contents+=new/obj/Attacks/Beam
/*mob/Admin3/verb/Brix(mob/A in world)
	var/mob/Drunken_Irishman/I=new
	I.loc=get_step(A,turn(A.dir,180))
	spawn(50) if(I) del(I)
	I.dir=A.dir
	sleep(30)
	view(10,I)<<"A [I] appears and hits [A] with a pint of guinness!"
	A.overlays-=A.overlays
	A.icon='Exploded.dmi'
	spawn A.Spew_Chunks()
	A.Omega_Knockback()
	A.Chocobo_Crush()
	A.Diarea=1000
	spawn(30)
		for(var/mob/P in range(15,A)) P.Diarea=0
		A.Death("explosive diarea!")*/
mob/proc/Chocobo_Crush()
	var/mob/Chocobo/C=new(loc)
	C.dir=EAST
	C.Enlarge_Icon()
	view(10,C)<<"A giant chocobo appears and crushes [src]!"
	C.y+=3
	var/Amount=3
	while(Amount)
		Amount-=1
		if(C) C.y-=1
		sleep(2)
	spawn(30) if(C) del(C)
mob/proc/Spew_Chunks(Amount=100) while(Amount)
	Amount-=1
	var/Density=3
	while(Density)
		Density-=1
		var/obj/Body_Part/P=new(loc)
		var/Distance=rand(1,5)
		spawn while(P&&Distance)
			step_away(P,src,20)
			Distance-=1
	sleep(1)
mob/proc/Omega_Knockback(Amount=100) while(Amount)
	Amount-=1
	Instant=1
	step_rand(src)
	sleep(1)
	Instant=0
var/Max_Swarms=100
mob/Admin5/verb/Max_Swarms()
	set category="Admin"
	Max_Swarms=input(src,"[Max_Swarms]") as num
obj/Make_Swarm
	Skill=1
	verb/Pestilence()
		set category="Skills"
		var/I
		switch(input(usr,"Do you want a custom icon for your swarm?") in list("No","Yes"))
			if("Yes") I=input(usr) as file
		var/Name=input(usr,"Name your swarm") as text
		var/Cohesion=input(usr,"Swarm Cohesion, as Percent, default is 30%") as num
		var/obj/Swarm/S=new
		S.loc=usr.loc
		S.Leader=1
		S.name=Name
		S.Cohesion=Cohesion
		if(I) S.icon=I
var/Swarms=0
obj/Swarm
	icon='Gargoyle.dmi'
	Givable=0
	Makeable=0
	var/Leader
	density=1
	layer=100
	Health=0
	BP=50
	var/Cohesion=30 //%
	Move()
		density=0
		..()
		density=1
	New()
		spawn if(src)
			var/Amount=4
			while(Amount)
				Amount-=1
				var/image/A=image(icon=icon,pixel_x=rand(-64,64),pixel_y=rand(-64,64),layer=layer)
				overlays+=A
		Swarms+=1
		spawn if(src) Swarm()
	Del()
		Swarms-=1
		..()
	proc/New_Swarm(Amount=1)
		while(src&&Amount)
			Amount-=1
			var/obj/Swarm/S=new
			S.loc=loc;S.BP=BP;S.Target=src;S.Cohesion=Cohesion;S.icon=icon
			sleep(1)
	proc/Swarm()
		pixel_x=rand(-32,32)
		pixel_y=rand(-32,32)
		spawn if(src&&!Target&&Leader) while(src)
			sleep(rand(400,800))
			if(src&&Swarms<Max_Swarms) New_Swarm(1)
		spawn while(src) //Find new leader if necessary
			if(!Target&&!Leader) for(var/obj/Swarm/S in view(10,src))
				Target=S
				break
			if(!z) del(src)
			sleep(rand(1,600))
		spawn while(src)
			var/mob/P
			for(P in range(5,src)) break
			if(P&&prob(30))
				step_towards(src,P)
				if(P in range(0,src))
					var/Damage=5*(BP/P.BP)
					P.Health-=Damage
					if(P.Health<=0)
						if(!P.Dead)
							BP+=P.BP
							if(P.client) New_Swarm(3)
							else if(Swarms<Max_Swarms) New_Swarm(1)
						if(P) P.Death(name)
			else if(Target&&prob(Cohesion)) step_towards(src,Target)
			else step_rand(src)
			sleep(rand(1,5))
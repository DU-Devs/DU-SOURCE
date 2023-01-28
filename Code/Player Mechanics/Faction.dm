/*mob/verb/Create_Faction()
	set category="Other"
	var/F_Name=input(src,"Name your faction. A faction is the same as a guild/group/etc") as text
	usr<<"Faction created. Check items tab. There you will see your faction. Click it for customization options."
	var/obj/Faction/A=new
	A.factioncode=rand(1,1000000000)
	A.leader=1
	contents+=A
	if(F_Name) A.name=F_Name*/
obj/Faction
	var/version=0
	var/rank=1
	var/factioncode
	var/leader=0
	suffix="Rank 1"
	var/notes={"<body bgcolor="#000000"><font color="#CCCCCC">

	Messages here. HTML.

	</body><html>"}
	Click()
		var/list/Choices=new
		Choices.Add("Cancel")
		Choices.Add("Members Online")
		if(rank>1||leader) Choices.Add("Recruit")
		if(leader||rank>=4) Choices.Add("Change Member Rank")
		if(rank>=4||leader) Choices.Add("Boot Member")
		if(leader) Choices.Add("Faction Name")
		if(leader) Choices.Add("Faction Icon")
		if(leader) Choices.Add("Change Faction Notes")
		Choices.Add("View Faction Notes")
		Choices.Add("Leave Faction")
		if(leader) Choices.Add("Switch Leaders")
		switch(input("Choose Option") in Choices)
			if("Faction Name")
				version+=1
				name=input("") as text
			if("Switch Leaders")
				var/list/Members=new
				Members+="Cancel"
				for(var/mob/A in players) for(var/obj/Faction/B in A) if(B.factioncode==factioncode) Members+=A
				var/mob/A=input("Give leader status to who?") in Members
				if(A=="Cancel") return
				leader=0
				for(var/obj/Faction/B in A) if(B.factioncode==factioncode) B.leader=1
				A<<"[usr] has just made you the leader of the faction"
				usr<<"You are no longer the leader. You have made [A] the leader"
			if("Boot Member")
				var/list/Members=new
				Members+="Cancel"
				for(var/mob/A in players) for(var/obj/Faction/B in A) if(B.factioncode==factioncode) Members+=A
				var/mob/A=input("Boot which member?") in Members
				if(A=="Cancel") return
				A<<"[usr] has taken you out of the [src]"
				for(var/obj/Faction/B in A) if(B.factioncode==factioncode) del(B)
			if("Change Member Rank")
				var/list/Members=new
				Members+="Cancel"
				for(var/mob/A in players) for(var/obj/Faction/B in A) if(B.factioncode==factioncode) Members+=A
				var/mob/A=input("Which member?") in Members
				if(A=="Cancel") return
				for(var/obj/Faction/B in A) if(B.factioncode==factioncode)
					if(B.rank<rank||leader)
						B.rank=input("Input a new rank. Current is [B.rank]. 1 will have only basic commands. \
						2 will be able to recruit. 3 will be able to boot those with lower ranks than them. \
						4 has everything the leader has.") as num
						B.suffix="Rank [B.rank]"
					else usr<<"Their rank is higher than yours, you cannot change it."
			if("Faction Icon")
				icon=input("") as icon
				icon_state=input("Enter the appropriate icon state, if any.") as text
				version+=1
			if("Change Faction Notes")
				version+=1
				notes=input(usr,"Rawr","Rawr",notes) as message
			if("Recruit")
				Choices=new
				Choices+="Cancel"
				for(var/mob/A in view(usr)) if(A.client)
					var/Found
					for(var/obj/Faction/Q in A) if(Q.factioncode==factioncode) Found=1
					if(!Found) Choices+=A
				var/mob/M=input("Who?") in Choices as mob|null
				if(M=="Cancel") return
				switch(input(M,"Join [name]?") in list("Yes","No"))
					if("Yes")
						var/obj/Faction/A=new
						A.factioncode=factioncode
						M.contents+=A
						M.FactionUpdate()
						player_view(15,M)<<"[M] is now a member of the [name]"
					else player_view(15,M)<<"Has declined to join the [name]"
			if("Leave Faction") del(src)
			if("View Faction Notes") usr<<browse(notes,"window= ;size=700x600")
			if("Members Online") for(var/mob/M in players) for(var/obj/Faction/A in M)
				if(A.factioncode==factioncode)
					if(!M.Dead) usr<<"[M]"
					else usr<<"[M] (Dead)"
mob/proc/FactionUpdate() for(var/obj/Faction/F in src) for(var/mob/M in view(src))
	for(var/obj/Faction/A in M) if(F.factioncode==A.factioncode) if(A.version>F.version)
		F.name=A.name
		F.icon=A.icon
		F.version=A.version
		F.notes=A.notes
		F.factioncode=A.factioncode
		src<<"[M]'s faction ([A.name]) is a higher version than your faction ([F.name]), your \
		faction has automatically been updated to their version."
proc/Planet_Resources() for(var/area/A) if(A.type!=/area&&A.type!=/area/Inside)
	var/N=1*Resource_Multiplier
	if(A.type==/area/Icer) A.Value+=1200000*N
	else if(A.type==/area/Prison) A.Value+=1200000*N
	else if(A.type==/area/Sonku) A.Value+=400000*N
	else if(A.type==/area/SSX) A.Value+=400000*N
	else if(A.type==/area/Space) A.Value+=400000*N
	else A.Value+=400000*N
mob/Admin4/verb/Upgrade_Settings()
	set category="Admin"
	switch(input(src,"You can set the upgrade cap to automatic, or a manual amount. Currently the upgrade cap is \
	[Commas(Tech_BP)].") in list("Cancel","Automatic","Manual"))
		if("Cancel") return
		if("Automatic")
			Automate_Tech_Power=1
			world<<"Upgrade cap set to automatic"
		if("Manual")
			Automate_Tech_Power=0
			var/Amount=input(src,"Set the upgrade cap. Enter 0 to cancel") as num
			if(Amount<=0) return
			Tech_BP=Amount
			world<<"Upgrade cap set to [Commas(Tech_BP)] BP"
var/Automate_Tech_Power=1
var/Tech_BP=1
var/Avg_BP=1
var/Avg_Base=1

mob/var/tmp/Tech_Cap_Debug
mob/verb/Tech_Debug()
	Tech_Cap_Debug=!Tech_Cap_Debug
	if(Tech_Cap_Debug) src<<"You will see tech cap debug messages"
	else src<<"You will NOT see tech cap debug messages"


proc/Tech_BP()
	spawn while(1) //average base bp divided by bp mod of all players
		if(Player_Count())
			var/N=0
			for(var/mob/P in Players) N+=P.Base_BP/P.BP_Mod
			N/=Player_Count()
			Avg_Base=N
		sleep(600)
	spawn while(1) //average bp of players
		if(Player_Count())
			var/N=0
			for(var/mob/P in Players) N+=P.BP/(P.BPpcnt/100)
			N/=Player_Count()
			Avg_BP=N
		sleep(600)
	spawn while(1) //upgrade cap
		if(Player_Count()&&Automate_Tech_Power)
			var/N=0
			for(var/mob/P in Players)
				if(!P.Cyber_Power&&P.Ki<=P.Max_Ki&&P.loc)
					N+=P.BP/(P.BPpcnt/100)
			N/=Player_Count()
			Tech_BP=N
		sleep(600)
proc/Avg_Force(N=0)
	if(!Player_Count()) return 1
	for(var/mob/P in Players) if(P.client) N+=P.Pow
	return N/Player_Count()
proc/Avg_Offense(N=0)
	if(!Player_Count()) return 1
	for(var/mob/P in Players) if(P.client) N+=P.Off
	return N/Player_Count()
obj/var/Cost
var/list/Technology_List=new
proc/Add_Technology()
	for(var/V in typesof(/obj))
		var/obj/B=new V
		if(B)
			B.suffix=null
			if(B.Cost) Technology_List+=B
			else del(B)
proc/Can_Make_Technology(mob/P,obj/O)
	for(var/obj/Injuries/Brain/I in P)
		P<<"You have a brain injury and therefore cannot make technology"
		return
	for(var/obj/Resources/M in P) if(O.Cost/P.Intelligence<=M.Value) return 1
proc/Technology_Price(mob/P,obj/O)
	return O.Cost/P.Intelligence
obj/Resources
	icon='Misc.dmi'
	icon_state="ZenniBag"
	Savable=1
	var/Value=0
	verb/Show_Resources() view(usr)<<"[usr] shows their bag containing [Commas(Value)] resources"
	verb/Drop()
		var/mob/P
		for(P in get_step(usr,usr.dir)) break
		if(P&&!P.client) P=null
		var/Money=input("Drop how much Resources? ([Commas(Value)])") as num
		if(Money>Value) Money=Value
		if(Money<=0) usr<<"You must atleast drop 1"
		if(Money>=1)
			Money=round(Money)
			Value-=Money
			var/obj/Resources/A=new
			A.loc=usr.loc
			A.Value=Money
			A.name="[Commas(A.Value)] Resources"
			if(!P) view(usr)<<"<font size=1><font color=teal>[usr] drops [A]."
			else view(usr)<<"<font size=1><font color=teal>[usr] gives [P] [A]"
			step(A,usr.dir)
			if(P)
				P.Alter_Res(A.Value)
				del(A)
proc/Resources_Loop() while(1)
	Planet_Resources()
	sleep(200)
obj/var/Tech=1
obj/Drill
	Cost=1000
	density=1
	var/Resources=0
	var/DrillRate=1
	icon='Drill Giant.dmi'
	desc="Place this at a location and it will automatically drill resources from within the planet. It can not \
	drill if you have it on player built turfs. The more you upgrade this the faster it will drill. Click on it \
	to withdraw what it has drilled."
	New()
		Center_Icon(src)
		spawn Drill()
	Del()
		var/obj/Resources/R=new(loc)
		R.Value=(Total_Cost/2)+Resources
		R.name="[Commas(R.Value)] resources"
		..()
	proc/Drill() spawn while(src)
		var/Amount=60
		var/N=8 //Overall drilling rate
		for(var/mob/P in view(1,src)) if(P.client)
			Amount=1
			break
		if(z) for(var/area/B in range(0,src)) if(B.Value)
			if(B.Value>=N*DrillRate*Amount)
				Resources+=N*DrillRate*Amount
				B.Value-=N*DrillRate*Amount
			else
				Resources+=B.Value
				B.Value=0
			if(B.Value<0) B.Value=0
		sleep(rand(0,10*Amount*2))
	Click() if(!usr.KO) if(usr in range(1,src))
		if(usr.client.eye!=usr) return
		view(src)<<"[usr] withdraws [Commas(Resources)] resources from [src]"
		var/planet_res=0
		for(var/area/a in range(0,src)) planet_res=a.Value
		view(src)<<"The planet has [Commas(planet_res)] resources remaining"
		for(var/obj/Resources/A in usr)
			A.Value+=Resources
			Resources=0
	verb/Upgrade()
		set src in view(1)
		for(var/mob/P in range(1,src)) if(P==usr) for(var/obj/Resources/R in usr)
			if(Health<usr.Knowledge) Health=usr.Knowledge
			if(!usr.Intelligence) return
			var/Amount=input(usr,"Input the amount of resources you want to upgrade the drill with. The more \
			you add the faster it will dig. It is currently worth [Commas(DrillRate*1000)]$.") as num
			if(Amount>R.Value) Amount=R.Value
			if(Amount<0) return
			R.Value-=Amount
			Total_Cost+=Amount
			view(usr)<<"[usr] increases the drills value from [Commas(DrillRate*1000)]$, "
			DrillRate+=(Amount/1000)*usr.Intelligence
			desc="Value: [Commas(DrillRate*1000)]$"
			view(usr)<<"to [Commas(DrillRate*1000)]$."
			suffix="[Commas(DrillRate*1000)]$"
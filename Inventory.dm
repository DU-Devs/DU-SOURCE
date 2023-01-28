obj/var/clonable=1
obj/items/Radar
	icon='Misc2.dmi'
	icon_state="Radar"
	Cost=100000000
	Stealable=1
	desc="This radar can be set to detect any item. Click it to equip it and a tab will open showing those items."
	var/Detects
	Click() if(src in usr)
		if(!suffix)
			for(var/obj/items/Radar/R in usr) R.suffix=null
			suffix="Equipped"
		else suffix=null
	verb/Set()
		if(Detects)
			switch(alert("Are you sure you want to reset detection to another object type?","","No","Yes"))
				if("No") return
		for(var/obj/O in get_step(usr,usr.dir))
			Detects=O.type
			usr<<"[src] set to detect [initial(O.name)] objects"
			return
		usr<<"No object found. Face an object you want the Radar to detect and hit Set. It will then detect all \
		objects of that type."
obj/items/Door_Hacker
	Can_Drop_With_Suffix=1
	Stealable=1
	icon='Lab.dmi'
	icon_state="GBA"
	desc="This device has the ability to bypass walls and doors below it's level"
	Cost=3000000 //See New()
	New() Cost=initial(Cost)*1000
	verb/Upgrade()
		set src in view(1)
		if(usr in view(1,src))
			var/Int_Max=usr.Intelligence**0.25
			if(Int_Max>1) Int_Max=1
			var/Max_Upgrade=usr.Knowledge*(Turf_Strength*0.8)*Int_Max
			var/Percent=(BP/Max_Upgrade)*100
			var/Res_Cost=1000/usr.Intelligence
			if(Percent>=100)
				usr<<"This is 100% upgraded at this time and cannot go any further."
				return
			var/Amount=input("[src] is at [Percent]% of its max upgrade. Each 1% upgrade cost [Commas(Res_Cost)]$. \
			([Percent]-100%)") as num
			if(Amount>100) Amount=100
			if(Amount<0.1)
				usr<<"Amount must be higher than 0.1%"
				return
			if(Amount<=Percent)
				usr<<"The weapon cannot be downgraded."
				return
			Res_Cost*=Amount-Percent
			if(usr.Res()<Res_Cost)
				usr<<"You do not have enough resources to do this."
				return
			usr.Alter_Res(-Res_Cost)
			BP=Max_Upgrade*(Amount/100)
			view(usr)<<"[usr] upgraded [src] from [Percent]% to [Amount]%"
			desc="Level [Commas(BP)]"
			suffix=Commas(BP)
obj/items/Shuriken
	Cost=1000
	Stealable=1
	icon='Shuriken.dmi'
	desc="This is a ranged move based on the thrower's strength"
	var/Shurikens=100
	var/Shrapnel
	var/Bounce
	var/Explosive=0
	var/Knockback=0
	Can_Drop_With_Suffix=1
	New() suffix="[Commas(Shurikens)]"
	verb/Upgrade()
		set src in view(1)
		if(usr in view(1,src)) while(usr)
			var/Shrapnel_Cost=1000/usr.Intelligence
			var/Bounce_Cost=1000/usr.Intelligence
			var/Explode_Cost=1000/usr.Intelligence
			var/KB_Cost=1000/usr.Intelligence
			var/list/L=list("Cancel","Add Ammo")
			if(!Shrapnel) L+="Shrapnel ([Commas(Shrapnel_Cost)]$)"
			if(!Bounce) L+="Wall Bounce ([Commas(Bounce_Cost)]$)"
			if(!Explosive) L+="Explosive ([Commas(Explode_Cost)]$)"
			if(!Knockback) L+="Knockback ([Commas(KB_Cost)]$)"
			var/C=input("Options") in L
			if(C=="Cancel") return
			if(C=="Add Ammo")
				var/Cost=round(10/usr.Intelligence)
				var/N=input("How much ammo do you want to add? It cost you [Cost]$ per 1 ammo. You can add a max of \
				[round(usr.Res()/Cost)] more ammo") as num
				if(N<0) return
				if(N>round(usr.Res()/Cost)) N=round(usr.Res()/Cost)
				Cost*=N
				usr.Alter_Res(-Cost)
				Shurikens+=round(N)
				view(usr)<<"[usr] increases the [src]'s ammo to [Shurikens] (Cost: [Commas(Cost)]$)"
				suffix="[Commas(Shurikens)]"
			if(C=="Shrapnel ([Commas(Shrapnel_Cost)]$)")
				if(usr.Res()<Shrapnel_Cost) return
				view(usr)<<"[usr] adds shrapnel attribute to [src]"
				Shrapnel=1
				usr.Alter_Res(-Shrapnel_Cost)
			if(C=="Wall Bounce ([Commas(Bounce_Cost)]$)")
				if(usr.Res()<Bounce_Cost) return
				view(usr)<<"[usr] adds bounce attribute to [src]"
				Bounce=1
				usr.Alter_Res(-Bounce_Cost)
			if(C=="Explosive ([Commas(Explode_Cost)]$)")
				if(usr.Res()<Explode_Cost) return
				view(usr)<<"[usr] adds explosion attribute to [src]"
				Explosive=1
				usr.Alter_Res(-Explode_Cost)
			if(C=="Knockback ([Commas(KB_Cost)]$)")
				if(usr.Res()<KB_Cost) return
				view(usr)<<"[usr] adds knockback attribute to [src]"
				Knockback=1
				usr.Alter_Res(-KB_Cost)
	verb/Shuriken()
		set category="Skills"
		if(usr.attacking) return
		if(Shurikens)
			Shurikens--
			suffix="[Commas(Shurikens)]"
			usr.attacking=1
			spawn(2*usr.Speed_Ratio()) if(usr) usr.attacking=0
			if(!Shurikens) usr<<"You are out of shurikens. Right click them and hit upgrade to add more"
			var/obj/Blast/A=new
			A.Is_Ki=0
			A.Distance=75
			A.Fatal=usr.Fatal
			A.icon=icon
			A.Owner=usr
			A.BP=usr.BP
			A.Force=usr.Str*5*Ki_Power
			A.Bullet=1
			A.Offense=usr.Off
			A.Explosive=Explosive
			A.Shrapnel=Shrapnel
			A.Bounce=Bounce
			A.Shockwave=Knockback
			A.dir=usr.dir
			A.loc=usr.loc
			walk(A,A.dir)
obj/items/Devil_Mat
	Stealable=1
	desc="Meditating on this mat will actually DECREASE the stat you are focused on. This can be useful if \
	you are at the stat cap but you don't like how you trained your stats, so you want to lower yourself below \
	the stat cap and train a different stat. This will have no effect if you are focused on energy or balanced."
	icon='Hell turf.dmi'
	icon_state="h4"
	Cost=1000
	verb/Bolt()
		set src in oview(1)
		usr.Bolt(src)
	New()
		overlays-=overlays
		var/image/I=image(icon='Electric_Yellow.dmi',layer=5)
		overlays-=I
		overlays+=I
mob/proc/Devil_Mat()
	if(Stat_Focus=="Strength") Str*=0.95
	if(Stat_Focus=="Durability") End*=0.95
	if(Stat_Focus=="Force") Pow*=0.95
	if(Stat_Focus=="Resistance") Res*=0.95
	if(Stat_Focus=="Speed") Spd*=0.95
	if(Stat_Focus=="Offense") Off*=0.95
	if(Stat_Focus=="Defense") Def*=0.95
mob/proc/Choose_Player(T)
	var/list/L=list("Cancel")
	for(var/mob/P in Players) if(P.client) L+=P
	var/mob/P=input(src,T) in L
	if(!P||P=="Cancel") return
	return P
var/list/Bounties=list("Cancel")
obj/Bounty_Picture
proc/Update_Bounties()
	for(var/V in Bounties) if(V!="Cancel")
		var/list/L=Bounties[V]
		var/Key=L["Key"]
		for(var/mob/P in Players) if(P.key==Key)
			var/obj/Bounty_Picture/B=new
			B.icon=P.icon
			B.overlays=P.overlays
			L["Image"]=B
			L["Name"]=P.name
			if(P.Prisoner()) L["Dead"]=1
		if(!L["Expires"]||world.realtime>L["Expires"]) Bounties-=V
		else Bounties[V]=L
mob/proc/Has_Bounty() for(var/V in Bounties) if(V!="Cancel")
	var/list/L=Bounties[V]
	if(L["Key"]==key&&!L["Dead"]) return 1
proc/Find_Bounty(V)
	var/list/L=Bounties[V]
	if(!V||V=="Cancel") return
	for(var/mob/M in Players) if(M.key==L["Key"]) return M
proc/Online_Bounties()
	var/list/L=list("Cancel")
	for(var/V in Bounties) if(V!="Cancel")
		var/list/LL=Bounties[V]
		if(Find_Bounty(V)&&!LL["Dead"]) L+=V
	return L
proc/Claimable_Bounties()
	var/list/L=list("Cancel")
	for(var/V in Bounties) if(V!="Cancel")
		var/list/LL=Bounties[V]
		if(LL["Dead"]) L+=V
	return L
mob/proc/Retract_Bounties()
	var/list/L=list("Cancel")
	for(var/V in Bounties) if(V!="Cancel")
		var/list/LL=Bounties[V]
		if(LL["Maker"]==key) L+=V
	return L
mob/proc/On_Built_Turf()
	var/turf/T=loc
	if(isturf(T)&&T.Builder) return 1
obj/Bounty_Computer
	pixel_y=-10
	icon='Lab2.dmi'
	icon_state="ControlTypeA"
	Cost=1000000
	density=1
	desc="Using this, you can view, place, claim, and retract bounties on people. Viewing a bounty will show you \
	the latest known image of the person who's bounty you are viewing, and the payment for killing them. \
	If you created a bounty, only you can remove it from the system. If you kill a bounty you have to visit a \
	bounty computer to collect your payment. Be warned, anyone who knows the guy is now dead can collect the bounty \
	from the bounty computer, so you must be quick to collect your reward before someone else does. Just click the \
	computer to use it, you must be next to it."
	verb/Bolt()
		set src in oview(1)
		usr.Bolt(src)
	Click()
		if(usr.Prisoner())
			usr<<"Prisoners are not allowed to use the bounty network"
			return
		while(usr in view(1,src))
			switch(input("Using this you can view, place, and collect bounties") in list("Cancel","View Bounties",\
			"Place Bounty","Claim Bounty","Retract Bounty"))
				if("Cancel") return
				if("View Bounties")
					Update_Bounties()
					while(usr)
						if(Bounties.len<1)
							usr<<"There are no bounties, meaning no player has entered a bounty into the bounty network"
							return
						var/T=input("Choose a bounty to see the latest image of the person you want to hunt. \
						Only online bounties are shown") in Online_Bounties()
						if(T=="Cancel"||!T) return
						var/list/L=Bounties[T]
						var/obj/OO=L["Image"]
						var/obj/Bounty_Picture/O=new
						O.icon=OO.icon
						O.overlays=OO.overlays
						spawn while(O)
							O.dir=turn(O.dir,90)
							sleep(10)
						spawn(100) if(O) del(O)
						O.loc=loc
						O.x-=1
						for(var/obj/Bounty_Picture/BP in loc) if(BP!=O) del(BP)
						usr<<"[src]: To the left you will see the latest image of the suspect.<br>\
						Name: [L["Name"]]<br>\
						Reward: [Commas(L["Bounty"])]$<br>\
						Note: [L["Note"]]"
						var/mob/M=Find_Bounty(T)
						if(M)
							var/mob/Drone=M.Has_Bounty_Drone()
							if(Drone&&get_dist(M,Drone)<10&&!M.On_Built_Turf())
								switch(alert("A prison observer drone is near this bounty and available to teleport you \
								there for hunting. Go now?","Options","No","Yes"))
									if("Yes") if(usr&&Drone) usr.loc=Drone.loc
				if("Place Bounty") while(usr)
					var/mob/P=usr.Choose_Player("Choose who you want to place a bounty on")
					if(!P) return
					var/Bounty=input("How much is the bounty you are putting on them? You have [Commas(usr.Res())]$") as num
					if(!P)
						usr<<"The person you wanted to place a bounty on has logged off, this process can not continue"
						return
					if(Bounty>usr.Res()) Bounty=usr.Res()
					if(Bounty<5000000)
						usr<<"The minimum bounty is 5'000'000$"
						return
					Bounty=round(Bounty)
					usr.Alter_Res(-Bounty)
					var/prison_add=0
					if(Prison_Money)
						prison_add=Prison_Money
						if(prison_add>10*1000000000) prison_add/=10
						Bounty+=prison_add
						Prison_Money-=prison_add
						usr<<"<font color=yellow>The prison has added [Commas(prison_add)]$ to your bounty amount \
						from its own funds. The prison acquired this money from its convicts upon arrest"

					var/Note=input("Leave a note about this bounty, this could be your alias so people know the bounty is \
					issued by you, or whatever else you want to put.") as text
					if(!P) return

					for(var/obj/Bounty_Computer/B) view(10,B)<<"<font size=3><font color=red>[src]: A new bounty has been \
					uploaded to the network. It is worth [Commas(Bounty)]$. Note: [Note]"

					Bounties["[Commas(Bounty)]$. [Note]"]=list("Bounty"=Bounty,"Key"=P.key,"Maker"=usr.key,"Note"=Note,\
					"Expires"=world.realtime+(3*24*60*60*10),"Prison Add"=prison_add)

					Update_Bounties()
				if("Claim Bounty")
					Update_Bounties()
					while(usr)
						var/T=input("Which bounty do you want to claim?") in Claimable_Bounties()
						if(!T)
							usr<<"There were no claimable bounties"
							return
						if(T=="Cancel") return
						var/list/L=Bounties[T]
						usr<<"Congratulations you just collected [Commas(L["Bounty"])]$!"
						usr.Alter_Res(L["Bounty"])
						Bounties-=T
				if("Retract Bounty")
					while(usr)
						var/T=input("Choose which of your bounties you want to remove from the bounty network, you \
						will get your money back") in usr.Retract_Bounties()
						if(!T||T=="Cancel") return
						var/list/L=Bounties[T]
						for(var/obj/Bounty_Computer/B) view(10,B)<<"A [Commas(L["Bounty"])]$ Bounty was just retracted \
						from the bounty network by its initiator."
						usr.Alter_Res(L["Bounty"])
						if(L["Prison Add"])
							Prison_Money+=L["Prison Add"]
							usr.Alter_Res(-L["Prison Add"])
						Bounties-=T
obj/items/Medical_Scan
	Stealable=1
	icon='Lab2.dmi'
	icon_state="WallDisplayA"
	desc="This displays information about your character's health. Just click it while next to it or have it on you \
	and click it."
	Cost=1000
	Click() if(usr in view(1,src))
		view(5)<<"[usr] uses the [src], it tells them:<br>\
		Physical Age: [round(usr.Age,0.1)]<br>\
		Decline Age: [round(usr.Decline,0.1)]<br>\
		Rate of power loss from decline: [round(usr.Decline_Rate,0.1)]x<br>\
		Lifespan: [round(usr.Lifespan(),0.1)]<br>\
		Your body is at [round(usr.Body*100,0.1)]% its original biological potential"
	verb/Bolt()
		set src in oview(1)
		usr.Bolt(src)
obj/Bio_Field_Generator
	icon='Lab.dmi'
	icon_state="Tower 1"
	density=1
	Savable=1
	//Cost=1000000000
	New()
		spawn Bio_Field_Generator()
		var/image/A=image(icon='Lab.dmi',icon_state="Tower 2",pixel_y=32)
		var/image/B=image(icon='Lab.dmi',icon_state="Tower 3",pixel_y=64)
		if(icon) overlays.Add(A,B)
		else overlays-=overlays
	proc/Bio_Field_Generator() while(src)
		if(locate(/mob) in view(7,src))
			Make_Shockwave(src,10,'Spirit.dmi')
			for(var/mob/P in view(7,src))
				if(P.client)
					if(P.KO) P.Un_KO()
					if(P.Health<100) P.Health=100
					//if(P.Ki<P.Max_Ki) P.Ki=P.Max_Ki
					P.Zombie_Virus=0
					P.Diarea=0
			for(var/mob/P in view(40,src)) if(!P.client&&P.Zombie_Virus) del(P)
		sleep(rand(0,1200))
obj/Punch_Machine
	desc="This measures how hard you punch. You must first click the machine to turn it on, and it will \
	cut itself off again after 1 minute"
	Cost=300
	density=1
	icon='Turf1.dmi'
	icon_state="Strength Machine"
	Health=5000
	verb/Upgrade()
		set src in view(1)
		if(usr in view(1,src))
			var/Max=usr.Knowledge*sqrt(usr.Intelligence)*5
			var/N=input("What do you want to upgrade this to? It currently has [Commas(Health)] health. The max is \
			[Commas(Max)] health. It is free to upgrade it") as num
			if(N>Max) N=Max
			if(N<Health) return
			view(src)<<"[usr] upgrades the [src] from [Commas(Health)] health to [Commas(N)] health"
			Health=N
obj/items/Pod_Race_Computer
	Cost=1000
	icon='Lab.dmi'
	icon_state="ATM"
	var/list/Racer_List=new
	var/Racers=0
	var/Max_Racers=8
	var/list/Bets=new
	proc/Count_Racers()
		Racers=0
		for(var/obj/O in Racer_List) Racers+=1
	verb/Set()
		set src in view(1,usr)
		var/list/Options=list("Cancel")
		if(Builder!=usr.key) Options+="Become Administrator"
		else
			Options+="Start Race"
			Options+="Set Max Racers"
			Options+="Bolt/Unbolt"
			Options+="Declare Winner"
		switch(input("Options") in Options)
			if("Cancel") return
			if("Declare Winner")
				usr<<"After someone wins a race you have to declare them as the winner, it cannot be detected \
				automatically. Once this is done all bets will automatically be given out to the appropriate betters."
				Options=list("Cancel")
				for(var/obj/OO in Racer_List) Options+=OO
				var/obj/OO=input("Choose the winner") in Options
				if(OO=="Cancel") return
				else
					view(40,src)<<"<font size=4><font color=yellow>[OO] has been declared winner of the race!"
					var/Losing_Bet_Total=0
					var/Winning_Bet_Total=0
					for(var/mob/M in Bets)
						var/list/Bet=Bets[M]
						var/obj/Racer
						for(var/obj/O in Bet)
							Racer=O
							if(Racer!=OO)
								var/Amount=0
								for(var/B in Bet) if(isnum(B)) Amount=B
								Losing_Bet_Total+=Amount
								M<<"You lost your bet on [Racer]. [OO] has won the race."
								Bets-=M
							else for(var/B in Bet) if(isnum(B)) Winning_Bet_Total+=B
					for(var/mob/M in Bets)
						var/Amount=0
						for(var/O in Bets[M]) if(isnum(O)) Amount=O
						var/Percentage=Winning_Bet_Total/Amount
						var/Winnings=round(Winning_Bet_Total*Percentage)
						usr.Alter_Res(Winnings)
						M<<"<font color=yellow>You won [Commas(Winnings)]$ from your bet on [OO]!"
						Bets-=M
				Racer_List=new/list
				Bets=new/list
			if("Bolt/Unbolt")
				Bolted=!Bolted
				if(Bolted) usr<<"The [src] is now bolted"
				else usr<<"The [src] is now unbolted"
			if("Become Administrator")
				switch(alert("Setting yourself as administrator of this computer gives you the ability to decide \
				when races start and things like that, it will cost you [Commas(1000000/usr.Intelligence)]$ to \
				set yourself as administrator. Accept cost?","Options","No","Yes"))
					if("No") return
					if("Yes")
						if(usr.Res()<1000000/usr.Intelligence)
							usr<<"You do not have enough money"
							return
						usr.Alter_Res(-(1000000/usr.Intelligence))
						view(10,src)<<"[usr] has set themselves as administrator of [src]"
						Builder=usr.key
			if("Start Race")
				view(40,src)<<"<font size=4><font color=yellow>The race is starting in 10 seconds! GET READY! This is \
				the only warning!"
				sleep(100)
				view(40,src)<<"<font size=4><font color=red>THE RACE HAS STARTED! GO!"
				for(var/obj/O in Racer_List) O.Can_Move=1
			if("Set Max Racers")
				Max_Racers=input("Current max is [Max_Racers]") as num
				if(Max_Racers<2)
					usr<<"It cannot be less than 2"
					return
				Max_Racers=round(Max_Racers)
	Click() if((usr in view(1,src))||(usr.Ship in view(1,src)))
		Count_Racers()
		var/list/Options=list("Cancel")
		if(Racers<Max_Racers)
			if(usr.Ship in view(1,src))
				Options+="Register to Race"
				Options+="Withdraw from Race"
			else usr<<"To register for a race, you must be in your ship and next to this computer, then click \
			the computer"
		Options+="Place Bet"
		switch(input("Options") in Options)
			if("Cancel") return
			if("Place Bet")
				Options=list("Cancel")
				for(var/obj/O in Racer_List) Options+=O
				var/obj/O=input("Choose which racer to place a bet on") in Options
				if(O=="Cancel") return
				else
					var/Bet=input("Place your bet on [O]") as num
					if(Bet<=0)
						usr<<"Bet too low"
						return
					if(Bet>usr.Res())
						usr<<"You do not have that much money"
						return
					if(!O)
						usr<<"[O] no longer exists"
						return
					Bet=round(Bet)
					view(40,src)<<"<font color=yellow>[usr] has placed a bet of [Commas(Bet)]$ on [O]"
					Bets.Add(usr=list(Bet,O))
			if("Register to Race")
				Count_Racers()
				if(Racers>Max_Racers)
					usr<<"All racing spots are filled. The max is [Max_Racers]"
					return
				if(!usr.Ship) return
				if(usr.Ship.name==initial(usr.Ship.name))
					usr<<"You must name your ship to enter a race"
					return
				Racer_List+=usr.Ship
				view(40,src)<<"[usr]'s ship [usr.Ship] has successfully registered for the upcoming race."
				usr<<"Your pod has been frozen til the race starts, you will have to drag it to the start line"
				usr.Ship.Can_Move=0
			if("Withdraw from Race")
				if(usr.Ship in Racer_List)
					Racer_List-=usr.Ship
					view(40,src)<<"[usr]'s ship [usr.Ship] has withdrawn from the race."
				else usr<<"Your ship is not registered for this race so it cannot be withdrawn."
obj/items/Nav_System
	Cost=1000000
	Stealable=1
	icon='Lab.dmi'
	icon_state="Labtop"
	desc="This upgradeable navigation system allows you to find planets in space. The only thing you need to do \
	is have it on you when in space and a navigation tab will open up. It will only show planets that it has \
	been upgraded to find. The more money you put into it the more planets will be unlocked. The rarest planets \
	will be unlocked last and at the greatest cost."
	var/Upgrade_Level=0
	var/Max_Upgrade=300000000
	var/Autopilot
	var/tmp/obj/Destination
	verb/Autopilot()
		if(!Autopilot) usr<<"[src] does not have autopilot"
		else
			if(!usr.Ship)
				usr<<"This only works in a space vehicle"
				return
			if(usr.Ship.z!=16)
				usr<<"You must be in space to use auto pilot"
				return
			var/list/L=list("Cancel")
			if(Destination) L+="Cancel Destination"
			for(var/obj/Planets/P) if(P.z==usr.Ship.z&&P.Nav_Level<=Upgrade_Level) L+=P
			var/obj/O=input("Choose an option") in L
			if(!O||O=="Cancel") return
			if(O=="Cancel Destination")
				Destination=null
				return
			Destination=O
			while(usr&&usr.Ship&&O&&O.z==usr.Ship.z&&O==Destination)
				step_towards(usr.Ship,O)
				sleep(1)
			Destination=null
	verb/Upgrade()
		set src in view(1)
		if(!usr.Intelligence) return
		if(Upgrade_Level>=Max_Upgrade)
			usr<<"This is upgraded to the maximum"
			return
		var/Amount=input("How many resources do you want to put into this? \
		[Commas((Max_Upgrade-Upgrade_Level)/usr.Intelligence)] \
		more resources will unlock all planets.") as num
		if(Amount>(Max_Upgrade-Upgrade_Level)/usr.Intelligence) Amount=(Max_Upgrade-Upgrade_Level)/usr.Intelligence
		for(var/obj/Resources/R in usr)
			if(Amount>R.Value) Amount=R.Value
			if(Amount<=0) return
			Amount=round(Amount)
			view(usr)<<"[usr] puts [Commas(Amount)] resources into the [src]"
			R.Value-=Amount
			Total_Cost+=Amount
			Upgrade_Level+=Amount*usr.Intelligence
			if(!Autopilot&&Upgrade_Level>=100000000)
				Autopilot=1
				view(usr)<<"The [src] now has autopilot"
			return
obj/var/Creator
obj/items/Resource_Vaccuum
	icon='Item, Vaccuum.dmi'
	desc="Click this when it is in your items and it will suck up all resource bags lying around you."
	var/tmp/Vaccuuming
	Cost=1000
	Stealable=1
	Click() if(src in usr)
		if(Vaccuuming) return
		Vaccuuming=1
		spawn(100) Vaccuuming=0
		for(var/obj/Resources/R in view(15,usr))
			spawn while(R&&!(R in usr)&&R.loc)
				var/Old_Loc=R.loc
				step_towards(R,usr)
				if(R)
					if(R.loc==Old_Loc) break
					if(R in view(1,usr))
						for(var/obj/Resources/A in usr) A.Value+=R.Value
						del(R)
				sleep(2)
obj/var/Can_Drop_With_Suffix
obj/var/Bullet
obj/items/Door_Pass
	Cost=1000
	name="Key"
	icon='Door Pass.dmi'
	Stealable=1
	desc="Click this to set it's password. Door's will check if it is correct and only let you in if it is."
	Click()
		if(Password)
			usr<<"It has already been programmed and cannot be reprogrammed."
			return
		Password=input("Enter a password for the doors to check if it is correct") as text
mob/proc/Clone_Tank() if(client) for(var/obj/items/Cloning_Tank/T) if(T.z&&T.Password==key&&Dead)
	view(src)<<"[src] has been revived by their [T]"
	Full_Heal()
	Revive()
	for(var/obj/Injuries/I in src) del(I)
	loc=T.loc
	Decline*=0.9
	Original_Decline*=0.9
	Base_BP*=0.9
	Max_Ki*=0.9
	Ki*=0.9
	return 1
obj/items/Cloning_Tank
	Cost=200000000
	layer=4
	density=1
	Bolted=0
	Stealable=1
	desc="This will revive you each time you are killed. Each time you are cloned however, you lose decline and power."
	New()
		var/image/A=image(icon='Lab.dmi',icon_state="Tube2",layer=layer,pixel_y=0,pixel_x=0)
		var/image/B=image(icon='Lab.dmi',icon_state="Tube2Top",layer=layer+1,pixel_y=32,pixel_x=0)
		var/image/C=image(icon='Lab.dmi',icon_state="Lab2",layer=layer,pixel_y=12,pixel_x=28)
		overlays.Add(A,B,C)
	Click()
		usr<<"This machine is set to clone [Password]"
	verb/Set()
		set src in oview(1)
		if(usr.Dead)
			usr<<"Dead people cannot use this"
			return
		usr<<"[src] has been set to clone [usr] if they die."
		Password=usr.key
obj/items/Hacking_Console
	icon='Lab.dmi'
	icon_state="Labtop"
	Stealable=1
	desc="If this is upgraded past the upgrade level of a door, it can open the door for you."
	verb/Use()
		for(var/obj/Turfs/Door/A in get_step(usr,usr.dir))
			if(A.Level<Level)
				view(usr)<<"[usr] uses the [src] to hack into the [A] and opens it!"
				A.Open()
			else view(usr)<<"[usr] tries to hack into the [A], but it is too advanced"
obj/items/Force_Field
	Cost=1000000
	Level=1
	Can_Drop_With_Suffix=1
	desc="Activate this and it will protect you against energy attack so long as its energy remains. \
	Each shot it deflects drains the battery."
	icon='Lab.dmi'
	icon_state="Computer 1"
	Stealable=1
	proc/Force_Field_Desc()
		desc="[src]: Level [round(Level,0.01)]"
		suffix="[Commas(Level)] BP"
	verb/Upgrade()
		set src in view(1)
		if(usr in view(1,src))
			var/Max_Upgrade=usr.Knowledge*2*sqrt(usr.Intelligence)
			var/Percent=(Level/Max_Upgrade)*100
			var/Res_Cost=1000/usr.Intelligence
			if(Percent>=100)
				usr<<"This is 100% upgraded at this time and cannot go any further."
				return
			var/Amount=input("This [src] is at level [Level]. The current maximum is \
			[Max_Upgrade]. \
			It is at [Percent]% maximum power. Each 1% upgrade cost [Commas(Res_Cost)]$. The maximum is 100%. Input \
			the percentage of power you wish to bring the [src] to. ([Percent]-100%)") as num
			if(Amount>100) Amount=100
			if(Amount<0.1)
				usr<<"Amount must be higher than 0.1%"
				return
			if(Amount<=Percent)
				usr<<"The weapon cannot be downgraded."
				return
			Res_Cost*=Amount-Percent
			if(usr.Res()<Res_Cost)
				usr<<"You do not have enough resources to do this."
				return
			usr.Alter_Res(-Res_Cost)
			Level=Max_Upgrade*(Amount/100)
			view(usr)<<"[usr] upgraded [src] from [Percent]% to [Amount]% ([Commas(Level)] BP)"
			Force_Field_Desc()
mob/proc/Force_Field(Icon='Force Field.dmi',C=rgb(100,200,250,120),State="") spawn if(src)
	var/obj/O=new
	O.icon=Icon
	Center_Icon(O)
	if(Icon&&C) Icon+=C
	var/image/I=image(icon=Icon,icon_state=State,pixel_x=O.pixel_x,pixel_y=O.pixel_y)
	overlays-=I
	overlays+=I
	spawn(50) overlays-=I
obj/items/Detonator
	Cost=1000
	icon='Cell Phone.dmi'
	Stealable=1
	desc="This can be used to activate the detonation sequence on bombs or missiles from afar."
	verb/Set() Password=input("Set a password to activate bombs of matching passwords.") as text
	verb/Use()
		if(!Password)
			usr<<"You must set a password to activate bombs of the same password"
			return
		switch(input("Confirm detonation command:") in list("Yes","No"))
			if("Yes")
				view(usr)<<"[usr] activates their remote detonator"
				var/list/Bombs=new
				for(var/obj/items/Nuke/A) Bombs+=A
				for(var/obj/B in Bombs)
					var/obj/items/Nuke/A=B
					if(src&&A.Password==Password&&!A.Bolted)
						if(!A.z) view(usr)<<"[src]: Command code denied for [A] (Someone is carrying it)"
						else
							view(usr)<<"[src]: Command code confirmed for [A]. It will detonate in 30 seconds."
							range(20,A)<<"<font color=red><font size=2>[A]: Detonation Code Confirmed. Nuclear Detonation in 30 Seconds."
							spawn(300) if(A) A.Remote_Detonation()
obj/items/Cloak_Controls
	Cost=100000000
	icon='Cloak.dmi'
	icon_state="Controls"
	desc="You can use this to activate or deactivate all cloaked objects matching the same password \
	you have set for the controls. You can also use this to remove the cloaking chip from objects \
	next to you by using uninstall on it. You can upgrade this to have more cloaking capability so \
	that it is harder to detect. This is also a personal cloak, if you activate it, you will become \
	out of phase, and stay out of phase until you deactivate it. While out of phase you will also see \
	anything that is in the same phase or lower than yourself. The personal cloak is 5 levels less \
	powerful than the cloaking modules themselves."
	var/Active
	Level=2
	Stealable=1
	verb/Use()
		var/list/L=list("Cancel")
		if(Password)
			if(Active) L+="Uncloak all objects"
			else L+="Cloak all objects"
		L+="Set cloak frequency"
		L+="Uninstall cloak from object"
		switch(input("[src] options") in L)
			if("Cloak all objects")
				Active=1
				view(usr)<<"[usr] activates all their cloak chips"
				for(var/obj/O) for(var/obj/items/Cloak/C in O) if(C.Password==Password) O.invisibility=Level
			if("Uncloak all objects")
				Active=0
				view(usr)<<"[usr] deactivates all their cloak chips"
				for(var/obj/O) for(var/obj/items/Cloak/C in O) if(C.Password==Password) O.invisibility=0
			if("Set cloak frequency")
				Password=input("Set the frequency for the cloak controls, it will control all cloak chips sharing this \
				frequency") as text
			if("Uninstall cloak from object")
				for(var/obj/O in get_step(usr,usr.dir)) for(var/obj/items/Cloak/C in O)
					view(usr)<<"[usr] removes the cloaking system from [O]"
					O.invisibility=0
					C.loc=usr.contents
atom/movable/var/Cloakable=1
obj/items/Cloak
	Cost=10000000
	icon='Cloak.dmi'
	desc="You can install this on any object to cloak it using cloak controls. First you must set the \
	password so that it matches the password of your cloak controls or it cannot be activated by those \
	controls."
	Stealable=1
	verb/Set() Password=input("Set the password for this cloak") as text
	verb/Use()
		if(!Password)
			usr<<"You must Set it first"
			return
		for(var/obj/A in get_step(usr,usr.dir)) if(A.Cloakable)
			view(usr)<<"[usr] installs a cloaking system onto the [A]"
			A.contents+=src
obj/items/Communicator
	Cost=1000
	icon='Cell Phone.dmi'
	desc="Use this to call somebody who also has a cell phone. Just use Say or Whisper and you can \
	talk to them til the call has ended. You end a call by hitting Use again. Anyone within 1 space \
	of you can hear your conversation and also be heard on the cell phone"
	var/Frequency=1
	Stealable=1
	verb/Transmit(msg as text) for(var/mob/P in Players)
		for(var/obj/items/Scouter/S in P)
			if(S.suffix&&((!P.Dead&&!usr.Dead)||(P.Dead&&usr.Dead))&&S.Frequency==Frequency)
				P<<"<font color=#FFFFFF>(Com)<font color=[usr.TextColor]>[usr]: [msg]"
		for(var/obj/items/Communicator/S in P)
			if(S.suffix&&((!P.Dead&&!usr.Dead)||(P.Dead&&usr.Dead))&&S.Frequency==Frequency)
				P<<"<font color=#FFFFFF>(Com)<font color=[usr.TextColor]>[usr]: [msg]"
	verb/Frequency() Frequency=input("Choose a frequency, it can be anything. It lets you talk to \
	others on the same frequency. Default is 1") as text
obj/items/Stun_Chip
	Cost=1000000
	icon='Control Chip.dmi'
	Stealable=1
	desc="You can install this on someone and use the Stun Remote to stun them temporarily. To use the \
	remote to stun them your remote must share the same remote access code as the installed chip. \
	You can also use this to remove chips from somebody using the Remove command, both chips will be \
	destroyed in the process."
	New()
		name=initial(name)
		//..()
	verb/Use(mob/A in view(1,usr))
		if(A==usr||A.KO||A.Frozen)
			view(usr)<<"[usr] installs a stun chip in [A]"
			var/obj/Stun_Chip/B=new
			B.Password=input("Input a remote access code to activate the chip") as text
			A.contents+=B
			del(src)
	verb/Remove(mob/A in view(1,usr))
		for(var/obj/Stun_Chip/B in A)
			view(usr)<<"[usr] removes a Stun Chip from [A]"
			del(B)
		del(src)
obj/Stun_Chip
	desc="You can install this on someone and use the Stun Remote to stun them temporarily. To use the \
	remote to stun them your remote must share the same remote access code as the installed chip. \
	You can also use this to remove chips from somebody using the Remove command, both chips will be \
	destroyed in the process."
	icon='Control Chip.dmi'
obj/items/Stun_Controls
	Cost=100000
	icon='Stun Controls.dmi'
	desc="You can use this to activate a stun chip you have installed on somebody. It only works \
	within your visual range."
	Stealable=1
	verb/Set() Password=input("Input a remote access code for activating nearby stun chips") as text
	verb/Use()
		view(usr)<<"[usr] activates their stun controls"
		for(var/mob/A in range(10,usr)) for(var/obj/Stun_Chip/B in A) if(B.Password==Password) A.KO()
obj/items/Transporter_Pad
	Bolted=1 //bolted by default for convenience
	Cost=150000000
	name="Telepad"
	icon='Transporter Pad.dmi'
	desc="You can use this to teleport yourself between other pads sharing the same remote access code"
	Stealable=1
	Level=1
	verb/Bolt()
		set src in oview(1)
		usr.Bolt(src)
	proc/Transport()
		var/list/A=new
		for(var/obj/items/Transporter_Pad/B) if(B!=src&&!(locate(/area/Prison) in range(0,B)))
			if(Level<2&&B.z!=z&&B.z)
			else if(B.Password==Password&&B.z) A+=B
		A+="Cancel"
		var/obj/items/Transporter_Pad/C=input("Go to which transporter?") in A
		if(C=="Cancel") return
		if(!(src in usr.loc)) return
		usr.overlays+='SBombGivePower.dmi'
		sleep(30)
		if(usr)
			usr.overlays-='SBombGivePower.dmi'
			usr.overlays-='SBombGivePower.dmi'
			usr.GrabbedMob=null
			view(10,usr)<<sound('teleport.ogg',volume=25)
			if(C&&C.z) usr.loc=C.loc
	verb/Set()
		set src in view(1)
		if(!Password)
			Password=input("Set the indentification code, you can only transport to \
			other pads using the same code") as text
			name=input("Name the transporter pad, preferably name it after the location it will take you \
			to") as text
			if(!name) name=initial(name)
		else usr<<"It is already initialized"
obj/items/Transporter_Watch
	Cost=300000000
	name="Telewatch"
	icon='Transporter Watch.dmi'
	desc="You can use this to teleport yourself to any telepad that matches your watch's \
	remote access code. Or to any player who has a telewatch with a matching code."
	Level=2
	Stealable=1
	var/dna_verification
	proc/Transport()
		if(dna_verification&&dna_verification!=usr.Mob_ID)
			view(usr)<<"[usr]'s telewatch: self destructing, dna verification mismatch"
			Explosion_Graphics(usr,1,3)
			del(src)
			return
		if(usr.Prisoner())
			usr<<"The prison has put a lock on your teleport watch while you are a prisoner"
			return
		if(usr.Dead)
			usr<<"This type of teleportation does not work for dead people"
			return
		var/list/l=list("cancel")
		for(var/mob/m in Players) if(m!=usr) for(var/obj/items/Transporter_Watch/t in m)
			if(t.Password==Password) l+=m
		for(var/obj/items/Transporter_Pad/t)
			if(!t.Final_Realm()&&t.Password==Password&&t.z) l+=t
			if(t.z==10&&usr.z!=10) l-=t //hbtc
		var/mob/m=input("Select a teleport location. You can teleport to telepads or teleport to someone who \
		has a telewatch on them with a matching code") in l
		if(!m||m=="cancel") return
		usr.overlays+='SBombGivePower.dmi'
		var/timer=25
		var/turf/old_loc=usr.loc
		while(timer)
			timer--
			if(usr.loc!=old_loc)
				timer+=10 //take longer when they move
				if(timer>50) timer=50
			old_loc=usr.loc
			sleep(1)
		usr.overlays-='SBombGivePower.dmi'
		usr.overlays-='SBombGivePower.dmi'
		if(m&&m.z)
			view(10,usr)<<sound('teleport.ogg',volume=25)
			if(usr.Ship&&usr.Ship.Small) usr.Ship.loc=m.loc
			else usr.loc=m.loc
	verb/Use() if(icon_state!="KO") Transport()
	verb/Set()
		switch(input("What setting would you like to change?") in list("cancel",\
		"dna verification upon teleport","change teleportation frequency"))
			if("cancel") return
			if("change teleportation frequency")
				Password=input("set the frequency. this will allow you to teleport to other telepads and \
				telewatches that use the same frequency") as text|null
			if("dna verification upon teleport")
				if(dna_verification&&dna_verification!=usr.Mob_ID)
					usr<<"Telewatch: you can not change the dna verification because it is already set to someone else"
					return
				dna_verification=usr.Mob_ID
				usr<<"Telewatch: dna verification set for your dna. if anyone else attempts to use this watch it \
				will self destruct"
obj/var/Injection
mob/var/Intelligence_Booster
obj/items/Intelligence_Booster
	icon='Poison Injection.dmi'
	Cost=1000000000
	Stealable=1
	Injection=1
	desc="This will raise your intelligence. The lower your intelligence the greater the effect. You can only use this \
	once. This can not be used on people who already have 1x or more intelligence."
	verb/Use(mob/A in view(1,usr))
		if(A.Intelligence>=1)
			usr<<"[A] already has 1+ intelligence it can not be boosted any further"
			return
		if(A.Intelligence_Booster)
			usr<<"[A] has already used this before and can not use it again"
			return
		if(A==usr||A.Frozen||A.KO)
			view(usr)<<"[usr] injects [A] with a mysterious needle!"
			A.Intelligence=A.Intelligence**0.5
			A.Intelligence_Booster=1
			del(src)
obj/items/Diarea_Injection
	Injection=1
	Cost=100000
	icon='Diarea Injection.dmi'
	Level=1
	Stealable=1
	verb/Use(mob/A in view(1,usr))
		if(A==usr||A.Frozen||A.KO)
			if(A.Android)
				usr<<"This has no effect on androids"
				return
			view(usr)<<"[usr] injects [A] with a mysterious needle!"
			A.Diarea+=Level
			del(src)
	verb/Upgrade()
		set src in view(1)
		for(var/obj/Resources/A in usr)
			var/Amount=input("How many levels do you want to add? Up to [Commas(A.Value/10000*usr.Add)]") as num
			if(Amount>round(A.Value/10000*usr.Add)) Amount=round(A.Value/10000*usr.Add)
			if(Amount<0) Amount=0
			Level+=Amount
			A.Value-=Amount*10000/usr.Add
			view(usr)<<"[usr] upgraded the [src] to level [Level]"
		desc="Level [Level] [src]"
mob/var/Youthenasia=1
obj/items/Youthenasia
	Cost=100000000
	icon='Roids.dmi'
	Level=1
	Stealable=1
	Injection=1
	desc="This extends life. The more you use them the less effect they will have."
	verb/Use(mob/A in view(1,usr))
		if(A==usr||A.Frozen||A.KO)
			if(usr.Android)
				usr<<"This has no effect on androids"
				return
			view(usr)<<"[usr] injects [A] with a mysterious needle!"
			A.Decline+=10/A.Youthenasia
			A.Youthenasia+=1
			del(src)
mob/var/LSD=0
obj/items/LSD
	icon='LSD.dmi'
	Level=1
	Stealable=1
	Injection=1
	Cost=20
	verb/Use(mob/A in view(1,usr))
		if(A==usr||A.Frozen||A.KO)
			view(usr)<<"[usr] injects [A] with a mysterious needle!"
			if(A.client)
				if(!A.LSD) A.LSD()
				A.LSD+=Level
				A.LSD=round(A.LSD)
			del(src)
	verb/Upgrade()
		set src in view(1)
		for(var/obj/Resources/A in usr)
			var/Amount=input("How many levels do you want to add? Up to [Commas(A.Value/500)]. Going past 100 does nothing.") as num
			if(Amount>round(A.Value/500)) Amount=round(A.Value/500)
			if(Amount<0) Amount=0
			Level+=Amount
			if(Level>100) Level=100
			A.Value-=Amount*500
			view(usr)<<"[usr] upgraded the [src] to level [Level]"
		desc="Level [Level] [src]. This drug will fuck you up temporarily. It has many temporary side effects, some \
		good, but mostly bad."
proc/Timed_Overlay(turf/T,Time=100,Icon) spawn if(Icon&&T)
	T.overlays+=Icon
	sleep(Time)
	if(T) T.overlays-=Icon
mob/proc/LSD()
	see_invisible=1
	spawn(3000) if(src&&LSD)
		LSD=0
		client.dir=NORTH
		see_invisible=0
	spawn(200) while(src&&LSD)
		Diarea(0,100,1)
		for(var/obj/Turd/T in view(10,src)) if(prob(10)) T.icon=pick('Shitbeast.dmi','Exploded.dmi')
		sleep(rand(0,1200/sqrt(LSD)))
	spawn(rand(0,600)) while(src&&LSD)
		var/list/L
		for(var/turf/T in view(2,src))
			if(!L) L=new/list
			L+=T
		if(L)
			var/turf/T=pick(L)
			if(!(locate(/obj) in T)&&!T.density)
				var/obj/O=new(T)
				O.Savable=0
				O.icon=pick('Body Parts.dmi','Exploded Head.dmi','Pool of Blood.dmi')
				O.pixel_x=rand(-10,10)
				O.pixel_y=rand(-10,10)
				Timed_Delete(O,rand(0,1200))
		sleep(2)
	spawn(600) while(src&&LSD)
		LSD-=1
		if(!LSD)
			client.dir=NORTH
			see_invisible=0
		sleep(600)
	spawn(100) while(src&&LSD)
		client.dir=pick(SOUTH,EAST,WEST,SOUTHEAST,SOUTHWEST,NORTHEAST,NORTHWEST)
		sleep(rand(0,600/sqrt(LSD)))
	spawn(50) while(src&&LSD)
		if(prob(20)) Random_Scary_Image()
		var/divisor=sqrt(LSD)
		if(divisor<1) divisor=1
		sleep(rand(0,1200/divisor))
	spawn(40) while(src&&LSD)
		if(prob(70)) src<<pick('Creepy Ambience.ogg','Creepy Ambience 2.ogg')
		else
			src<<pick('Scary Girl.ogg','Wisp.ogg','Distant Monster Roar.ogg')
		sleep(rand(0,1200/sqrt(LSD)))
	spawn(300) while(src&&LSD)
		var/list/L
		for(var/turf/T in view(40,src)) if(getdist(src,T)>=20)
			if(!L) L=new/list
			L+=T
		if(L)
			var/obj/O=new(pick(L))
			O.invisibility=1
			O.layer=layer
			Timed_Delete(O,300)
			switch(rand(1,2))
				if(1)
					O.icon='Bunchie.dmi'
					O.name="Bunchie"
					O.LSD_Monster(src)
				if(2)
					O.icon='Michael Jackson.dmi'
					O.name="Michael Jackson"
					O.LSD_Monster(src)
		sleep(rand(0,1200/sqrt(LSD)))
obj/proc/LSD_Monster(mob/P) spawn while(src&&P)
	if(prob(20)) step_towards(src,P)
	else step_rand(src)
	sleep(rand(1,3))
obj/items/layer=4
mob/var/Fruits_Eaten=0
obj/items/Fruit
	icon='Yemma Fruit.dmi'
	Stealable=1
	desc="Eating this will increase your power. It will also speed up your \
	regeneration and recovery rate temporarily."
	verb/Eat()
		if(usr.Android)
			usr<<"This has no effect on androids"
			return
		if(usr.Regen_Mult<1.5) usr.Regen_Mult=1.5
		if(usr.Recov_Mult<3) usr.Recov_Mult=3
		var/mob/m
		for(var/mob/p in Players) if(!m||p.Base_BP/p.BP_Mod>m.Base_BP/m.BP_Mod) m=p
		if(usr.Base_BP/usr.BP_Mod<m.Base_BP/m.BP_Mod)
			usr.Attack_Gain((10*60)/((usr.Fruits_Eaten+1)**2))
			usr.Fruits_Eaten++
		view(usr)<<"[usr] eats a [src]"
		del(src)
obj/items/Moon
	Cost=2000
	icon='Moon.dmi'
	Stealable=1
	desc="Using this will turn nearby Yasais that still have tails into Werewolf"
	var/Emitter
	verb/Use()
		set src in oview(1)
		if(icon_state=="On") return
		icon_state="On"
		view(usr)<<"[usr] activates the [src]!"
		view(10)<<'throw.ogg'
		for(var/mob/A in view(12,src))
			if(Emitter&&A.ssjdrain>=300&&A.ssj2drain>=300&&!usr.SSj4Able&&usr.Race=="Yasai") A.Werewolf(50)
			else A.Werewolf()
			if(!A.Tail) A.Tail_Add()
		spawn(100) if(src) del(src)
	verb/Upgrade()
		set src in view(1)
		var/obj/Resources/A
		for(var/obj/Resources/B in usr) A=B
		var/list/Choices=new
		var/Res_Cost=1000000000/usr.Intelligence
		if(A.Value>=Res_Cost&&!Emitter) Choices.Add("Turn into Emitter ([Res_Cost])")
		if(!Choices)
			usr<<"You do not have enough resources"
			return
		var/Choice=input("Change what?") in Choices
		if(Choice=="Turn into Emitter ([Res_Cost])")
			if(A.Value<Res_Cost) return
			A.Value-=Res_Cost
			Total_Cost+=Res_Cost
			Emitter=1
			icon='Moon2.dmi'
		Tech+=1
obj/var/Stealable
obj/items/PDA
	Cost=1000
	icon='PDA.dmi'
	desc="This can be used to store information, even youtube videos if you know how."
	Stealable=1
	var/notes={"<html>
<head><title>Notes</title><body>
<body bgcolor="#000000"><font size=2><font color="#CCCCCC">
</body><html>"}
	verb/Name() name=input("") as text
	verb/View()
		set src in world
		usr<<browse(notes,"window= ;size=700x600")
	verb/Input()
		notes=input(usr,"Notes","Notes",notes) as message
obj/Well
	icon='props.dmi'
	icon_state="21"
	Dead_Zone_Immune=1
	density=1
	Knockable=0
	var/effectiveness=2
	Savable=0
	Grabbable=0
	Spawn_Timer=180000
	New()
		for(var/obj/Well/A in range(0,src)) if(A!=src) del(A)
		//..()
	verb/Use()
		set category="Other"
		set src in oview(1)
		if(!usr.Disabled()&&usr.BPpcnt<=100)
			view(6)<<"<font color=red>* [usr] drinks some water. *"
			if(usr.Health<100) usr.Health+=(100/effectiveness)
			if(usr.Ki<usr.Max_Ki) if(!usr.Dead) usr.Ki+=(usr.Max_Ki/effectiveness)
mob/proc/max_weight()
	var/adjusted_str=Str
	var/obj/items/Sword/s=using_sword()
	if(s) adjusted_str/=s.Damage
	var/n=(Base_BP**0.2) * (adjusted_str**0.5) * 10
	return n
mob/proc/weights() //Returns a modifier that multiplies training gains
	var/n=1
	for(var/obj/items/Weights/W in src) if(W.suffix)
		n*=2.5*(W.weight/max_weight())
		break
	if(n<1) n=1
	if(n>2) n=2.5
	return n
obj/items
	Weights
		Cost=1000000
		var
			weight=20
		icon='Clothes_ShortSleeveShirt.dmi'
		Stealable=1
		desc="Wearing these will greatly increase BP gain. Attacks will take much more energy than normal, and your \
		available BP will be lowered while wearing them."
		proc/weight_name()
			name="[Commas(weight)] kilo weight"
		New()
			weight_name()
		Click() if(src in usr)
			for(var/obj/items/Weights/A in usr) if(A.suffix&&A!=src)
				usr<<"You are already wearing some"
				return
			usr.Clothes_Equip(src)
		verb/Upgrade()
			var/cost_per_kilo=round(1000/(usr.Intelligence**0.5))
			var/n=input("how much do you want these weights to weigh? 1 kilo cost [cost_per_kilo]$. these weights \
			weigh [Commas(weight)] kilos. you are able to lift [Commas(usr.max_weight())] kilos. making these weigh \
			beyond your max lift will have no effect when you wear them, it will be as if they are at your max. \
			weight less than 1/4th of your max lift will have no benefit") as num
			if(n<1||n<weight)
				usr<<"you can not make the weights weigh less than they already do"
				return
			var/res_cost=(n*cost_per_kilo)-(weight*cost_per_kilo)
			if(res_cost<0) res_cost=0
			if(usr.Res()<res_cost)
				usr<<"you need at least [Commas(res_cost)]$ to do this"
				return
			view(usr)<<"[usr] upgrades the [src] from [Commas(weight)] to [Commas(n)] kilos in weight"
			weight=round(n)
			usr.Alter_Res(-res_cost)
			Cost=(weight*cost_per_kilo)+initial(Cost)
			weight_name()
	Regenerator
		Cost=10000
		Stealable=1
		var/Recovers_Energy
		var/Heals_Injuries
		var/Double_Effectiveness
		desc="Stepping into this will accelerate your healing rate. It heals faster the more upgraded \
		it is. It will break in the strain of high gravity."
		New()
			var/image/A=image(icon='Lab.dmi',icon_state="Tube",pixel_y=-32)
			var/image/B=image(icon='Lab.dmi',icon_state="TubeTop",pixel_y=0)
			overlays.Remove(A,B)
			overlays.Add(A,B)
		verb/Upgrade()
			set src in view(1)
			var/Cost1=100000000/usr.Intelligence //injuries
			var/Cost2=100000000/usr.Intelligence //energy
			var/Cost3=100000000/usr.Intelligence //double effectiveness
			var/list/L=list("Cancel")
			if(!Heals_Injuries) L+="Heal Injuries ([Commas(Cost1)]$)"
			if(!Recovers_Energy) L+="Recover Energy ([Commas(Cost2)]$)"
			if(!Double_Effectiveness) L+="Double Effectiveness ([Commas(Cost3)]$)"
			if(L.len<=1)
				usr<<"This regenerator has all upgrades already"
				return
			while(usr)
				var/C=input("Which upgrade do you want to add?") in L
				if(C=="Cancel") return
				if(C=="Heal Injuries ([Commas(Cost1)]$)")
					if(usr.Res()<=Cost1) return
					view(usr)<<"[usr] adds injury healing to the [src]"
					Heals_Injuries=1
					usr.Alter_Res(-Cost1)
					Cost+=Cost1
					L-=C
				if(C=="Recover Energy ([Commas(Cost2)]$)")
					if(usr.Res()<=Cost2) return
					view(usr)<<"[usr] adds energy recovery to the [src]"
					Recovers_Energy=1
					usr.Alter_Res(-Cost2)
					Cost+=Cost2
					L-=C
				if(C=="Double Effectiveness ([Commas(Cost3)]$)")
					if(usr.Res()<=Cost3) return
					view(usr)<<"[usr] doubles the [src]'s effectiveness in all areas"
					Double_Effectiveness=1
					usr.Alter_Res(-Cost3)
					Cost+=Cost3
					L-=C
			desc="[src] upgrades:"
			if(Heals_Injuries) desc+="Heals Injuries"
			if(Recovers_Energy) desc+="Recovers Energy"
			if(Double_Effectiveness) desc+="Double Effectiveness"
		layer=MOB_LAYER+1
		verb/Bolt()
			set src in oview(1)
			usr.Bolt(src)
mob/proc/Apply_Armor(obj/items/Armor/A) if(A in src)
	for(var/obj/items/Armor/B in src) if(B.suffix&&B!=A)
		src<<"You already have armor on."
		return
	Clothes_Equip(A)
	if(A.suffix)
		End*=A.Armor
		EndMod*=A.Armor
		Def/=A.Armor
		DefMod/=A.Armor
	else
		End/=A.Armor
		EndMod/=A.Armor
		Def*=A.Armor
		DefMod*=A.Armor
obj/items/Armor
	Cost=1000
	Health=100
	Stealable=0
	icon='Armor1.dmi'
	var/Armor=0
	var/tmp/Choosing_Icon
	New()
		if(!Armor) Armor=rand(1000,2000)/1000
		Armor_Desc()
	Click()
		if(usr.Redoing_Stats)
			usr<<"You can not use this while choosing stat mods"
			return
		usr.Apply_Armor(src)
	desc="Armor will increase certain protective stats and decrease certain stats related to mobility or \
	flexibility. You'll just have to try it on to see exactly what effect it has. The more protective an armor \
	is the more it will decrease stats related to mobility and/or flexibility."
	proc/Armor_Desc() desc=initial(desc)+"<br>Protection: [round(Armor,0.01)]x"
	verb/Customize()
		set src in view(1)
		if(usr in view(1,src))
			while(usr)
				if(suffix)
					usr<<"You can not customize armor that is being worn"
					return
				switch(input(usr) in list("Cancel","Choose Icon","Change Protection Level"))
					if("Cancel") return
					if("Choose Icon")
						if(!Armor_Icons) Armor_Icons()
						Choosing_Icon=1
						usr.Grid(Armor_Icons)
						while(usr&&(winget(usr,"Grid1","is-visible")=="true")) sleep(1)
						Choosing_Icon=0
					if("Change Protection Level")
						var/N=input("Enter a protective value for this armor. It must be between 1 and 2. The higher the \
						number, the more the armor will increase certain protective stats, and decrease certain stats related \
						to mobility and/or flexibility. You will just have to try it on to see exactly what effect it will have. \
						Entering 1 will mean no protection, it won't affect any stats and is for appearance only. \
						Current is [Armor]") as num
						if(suffix)
							usr<<"You can not customize this while wearing it"
							return
						if(N<1) N=1
						if(N>2) N=2
						Armor=N
						Armor_Desc()
var/list/Armor_Icons
proc/Armor_Icons()
	if(!Armor_Icons) Armor_Icons=new/list
	for(var/V in list('Armor1.dmi','Nappa Armor.dmi','Armor2.dmi','Armor3.dmi','Armor4.dmi','Armor5.dmi',\
	'Armor6.dmi','Armor7.dmi','White Male Armor.dmi','Armor Bardock.dmi','TurlesArmor.dmi',\
	'GinsDynastyArmorRed.dmi','Phoenix Full (Makyo).dmi','Phoenix Full (Moonlight).dmi',\
	'Phoenix Full (Negative Makyo).dmi','Phoenix Full (Negative).dmi','Phoenix Full.dmi'))
		var/obj/Armor_Icon/O=new
		O.icon=V
		Armor_Icons+=O
obj/Armor_Icon/Click() for(var/obj/items/Armor/A in view(1)) if(A.Choosing_Icon) A.icon=icon
obj/var/Money
obj/items/verb/Drop()
	var/mob/P
	for(P in get_step(usr,usr.dir)) break
	if(P&&!P.client) P=null
	var/Amount=0
	for(var/obj/A in get_step(usr,usr.dir)) if(!(locate(A) in usr)) Amount+=1
	for(var/obj/Turfs/Door/D in get_step(usr,usr.dir))
		usr<<"You can not drop anything on top of a door"
		return
	if(Amount>4&&!P)
		usr<<"Nothing more can be placed on this spot."
		return
	if(suffix) if(!Can_Drop_With_Suffix)
		usr<<"You must unequip it first"
		return
	for(var/mob/A in view(usr)) if(A.see_invisible>=usr.invisibility)
		if(!P) A<<"[usr] drops [src]"
		else A<<"[usr] gives [P] a [src]"
	usr.overlays-=icon
	//loc=get_step(usr,usr.dir)
	loc=usr.loc
	step(src,usr.dir)
	dir=SOUTH
	if(P) P.contents+=src
obj/items
	Scouter
		Cost=5000
		icon='Scouter.dmi'
		var/Scan=1000
		var/Range=5
		var/Frequency=1
		Stealable=1
		desc="Equipping this will open a tab that allows you to see the battle power of all people \
		within the scouter's range and detection capabilities."
		Click()
			usr.Clothes_Equip(src)
			if(suffix) usr.Scouter=src
			else if(usr.Scouter==src) usr.Scouter=null
		verb/Upgrade()
			set src in view(1)
			if(usr in view(1,src))
				var/Max_Upgrade=usr.Knowledge*5*sqrt(usr.Intelligence)
				var/Percent=(Scan/Max_Upgrade)*100
				var/Res_Cost=100/usr.Intelligence
				if(Percent>=100)
					usr<<"This [src] is 100% upgraded at this time and cannot go any further."
					return
				var/Amount=input("This [src] scans up to [Commas(Scan)] BP. The current maximum is \
				[Commas(Max_Upgrade)] BP. \
				It is at [Percent]% maximum upgrade. Each 1% upgrade cost [Commas(Res_Cost)]$. The maximum is 100%. \
				Input the percentage you wish to upgrade the [src] to. ([Percent]-100%)") as num
				if(Amount>100) Amount=100
				if(Amount<0.1)
					usr<<"Amount must be higher than 0.1%"
					return
				if(Amount<=Percent)
					usr<<"This cannot be downgraded."
					return
				Res_Cost*=Amount-Percent
				if(usr.Res()<Res_Cost)
					usr<<"You do not have enough resources to do this."
					return
				usr.Alter_Res(-Res_Cost)
				Scan=Max_Upgrade*(Amount/100)
				view(usr)<<"[usr] upgraded [src] from [Percent]% to [Amount]% ([Commas(Scan)] BP)"
				desc="Scan: [Commas(Scan)] BP<br>Range: [Range]"
		verb
			Transmit(msg as text) for(var/mob/P in Players)
				for(var/obj/items/Scouter/S in P)
					if(S.suffix&&((!P.Dead&&!usr.Dead)||(P.Dead&&usr.Dead))&&S.Frequency==Frequency)
						P<<"<font color=#FFFFFF>(Scouter)<font color=[usr.TextColor]>[usr]: [msg]"
				for(var/obj/items/Communicator/S in P)
					if(S.suffix&&((!P.Dead&&!usr.Dead)||(P.Dead&&usr.Dead))&&S.Frequency==Frequency)
						P<<"<font color=#FFFFFF>(Scouter)<font color=[usr.TextColor]>[usr]: [msg]"
			Frequency() Frequency=input("Choose a frequency, it can be anything. It lets you talk to \
			others on the same frequency. Default is 1") as text
var/list/Sword_Icons
proc/Sword_Icons()
	if(!Sword_Icons) Sword_Icons=new/list
	for(var/V in list('Sword 2.dmi','Sword 1.dmi','Item - Katana 2.dmi','Item - Katana.dmi','Short Sword.dmi',\
	'Item, Sword 1.dmi','Item, Buster Sword.dmi','Item, Dual Blaze Sword.dmi','Item, Dual Electric Sword.dmi',\
	'Item, Great Sword.dmi','Sword Flame Complete.dmi','Sword, 2 Katanas.dmi','Sword, Samurai.dmi',\
	'Sword_Trunks.dmi','Falseneoblade.dmi','KingdomKey.dmi','KiSword.dmi','Yin Yang.dmi'))
		var/obj/Sword_Icon/O=new
		O.icon=V
		Sword_Icons+=O
obj/Sword_Icon/Click() for(var/obj/items/Sword/A in view(1)) if(A.Choosing_Icon) A.icon=icon
obj/items
	Sword
		var/tmp/Choosing_Icon
		Cost=2000
		icon='Sword_Trunks.dmi'
		Health=10000000
		Stealable=0
		var/Damage=2
		var/Style="Physical"
		desc="A sword will increase damage at an equal cost to accuracy."
		New()
			if(!Damage)
				Damage=rand(1000,3000)/1000
				Sword_Desc()
		proc/Sword_Desc() desc=initial(desc)+"<br>Swordiness: [round(Damage,0.01)]x"
		verb/Customize()
			set src in view(1)
			if(usr in view(1,src))
				while(usr)
					if(suffix)
						usr<<"You can not customize a sword that is being worn"
						return
					switch(input(usr) in list("Cancel","Choose Icon","Change Swordiness Level","Set damage style"))
						if("Cancel") return
						if("Set damage style")
							switch(input("Physical damage is the normal melee damage type, it does damage based on the \
							opponent's durability and your strength. Energy damage does damage on the opponent's \
							resistance, but only does roughly 90% the total damage that physical damage would. \
							70% of the energy damage comes from your strength, the other 30% comes from your force. \
							Setting it to energy damage is a \
							tactical thing, if you know your opponent has really low resistance you can make use of that.") \
							in list("Physical Damage","Energy Damage"))
								if("Physical Damage") Style="Physical"
								if("Energy Damage") Style="Energy"
						if("Choose Icon")
							if(!Sword_Icons) Sword_Icons()
							Choosing_Icon=1
							usr.Grid(Sword_Icons)
							while(usr&&(winget(usr,"Grid1","is-visible")=="true")) sleep(1)
							Choosing_Icon=0
						if("Change Swordiness Level")
							var/N=input("Change the swordiness of this sword. The higher the number the more damage it will \
							do but it will make it easier for your opponent to dodge it. Entering 1 will mean it has no effect \
							and is just for looks. You can enter a number between 0.5 and 3. Current is [Damage]") as num
							if(suffix)
								usr<<"You can not customize this while wearing it"
								return
							if(N<0.5) N=0.5
							if(N>3) N=3
							Damage=N
							Sword_Desc()
		Click()
			if(usr.Redoing_Stats)
				usr<<"You can not use this while choosing stat mods"
				return
			usr.Apply_Sword(src)
mob/proc/Apply_Sword(obj/items/Sword/S)
	if(S in src)
		for(var/obj/items/Sword/A in src) if(A!=S&&A.suffix)
			src<<"You already have a sword equipped."
			return
		Clothes_Equip(S)
		if(S.suffix)
			Str*=S.Damage
			StrMod*=S.Damage
			Off/=S.Damage
			OffMod/=S.Damage
		else
			Str/=S.Damage
			StrMod/=S.Damage
			Off*=S.Damage
			OffMod*=S.Damage
obj/items
	Digging
		var/DigMult=1
		Stealable=1
		Shovel
			icon='Shovel.dmi'
			desc="This will help increase the speed at which you can dig up resources."
			DigMult=5
			Cost=400
			Click() if(src in usr)
				for(var/obj/items/Digging/A in usr) if(A!=src&&A.suffix) A.suffix=null
				if(!suffix) suffix="Equipped"
				else suffix=null
		Hand_Drill
			icon='Drill Hand 2.dmi'
			desc="This will help increase the speed at which you can dig up resources."
			DigMult=25
			Cost=1000
			Click() if(src in usr)
				for(var/obj/items/Digging/A in usr) if(A!=src&&A.suffix) A.suffix=null
				if(!suffix) suffix="Equipped"
				else suffix=null
mob/var/tmp/Digging
mob/proc/Digging(Amount=1)
	Ki-=1*Amount
	if(Ki<1*Amount)
		Digging=0
		src<<"You stop digging due to exhaustion"
	Amount*=sqrt(sqrt(Base_BP))
	if(Amount<1) Amount=1
	for(var/obj/items/Digging/D in src) if(D.suffix) Amount*=D.DigMult
	Amount=round(Amount)
	Alter_Res(Amount)
mob/verb/Dig()
	set category="Skills"
	Digging=!Digging
	if(!Digging) src<<"You stop digging for resources"
	else src<<"You begin digging for resources (see items tab)"
mob/proc/Clothes_Equip(obj/A) if(A in src)
	if(!A.suffix)
		A.suffix="Equipped"
		overlays+=A.icon
	else
		overlays-=A.icon
		A.suffix=null
	Add_Injury_Overlays()
mob/proc/Clothes_Proc(obj/A)
	if(A in Clothing)
		var/obj/B=new A.type
		var/RGB=input(src,"Choose color. Hit Cancel to have default color.") as color|null
		if(!B) return
		if(RGB) B.icon+=RGB
		contents+=B
	else Clothes_Equip(A)
var/list/Clothing=new
obj/items/Clothes
	Savable=0
	Phoenix_Torso_Makyo
		icon='Phoenix Torso (Makyo).dmi'
		Click() usr.Clothes_Proc(src)
	Phoenix_Torso
		icon='Phoenix Torso.dmi'
		Click() usr.Clothes_Proc(src)
	Phoenix_Pauldrons_Makyo
		icon='Phoenix Pauldrons Makyo.dmi'
		Click() usr.Clothes_Proc(src)
	Phoenix_Pauldrons
		icon='Phoenix Pauldrons.dmi'
		Click() usr.Clothes_Proc(src)
	Uncoloured_Armour_Plating
		icon='Uncoloured Armour Plating.dmi'
		Click() usr.Clothes_Proc(src)
	Mandalorian_Helmet
		icon='Mandalorian helmet.dmi'
		Click() usr.Clothes_Proc(src)
	Jumpsuit
		icon='Jumpsuit.dmi'
		Click() usr.Clothes_Proc(src)
	Dark_Jango
		icon='Dark Jango.dmi'
		Click() usr.Clothes_Proc(src)
	Boba_Fett
		icon='Boba Fett.dmi'
		Click() usr.Clothes_Proc(src)
	Armour
		icon='Armour.dmi'
		Click() usr.Clothes_Proc(src)
	Tunic
		icon='Tunic.dmi'
		Click() usr.Clothes_Proc(src)
	Side_Cape
		icon='Side Cape.dmi'
		Click() usr.Clothes_Proc(src)
	ToS_Wings
		icon='ToS Wings (Black).dmi'
		Click() usr.Clothes_Proc(src)
	Neko_Collar
		icon='Neko Collar.dmi'
		Click() usr.Clothes_Proc(src)
	VV_Gauntlet
		icon='VV Gauntlet (Black).dmi'
		Click() usr.Clothes_Proc(src)
	Flowing_Cape
		icon='FlowingCape.dmi'
		Click() usr.Clothes_Proc(src)
	Succubus
		icon='Succubus.dmi'
		Click() usr.Clothes_Proc(src)
	Tsujin_Tux
		icon='TuffleTux.dmi'
		Click() usr.Clothes_Proc(src)
	Goggles
		icon='Clothes Goggles.dmi'
		Click() usr.Clothes_Proc(src)
	Backpack
		icon='Clothes Backpack.dmi'
		Click() usr.Clothes_Proc(src)
	Yasai_Uniform
		icon='Clothes Saiyan Suit.dmi'
		Click() usr.Clothes_Proc(src)
	Nero_Jacket
		icon='Clothes Nero Jacket.dmi'
		Click() usr.Clothes_Proc(src)
	Kung_Fu_Shirt
		icon='Clothes Kung Fu Shirt.dmi'
		Click() usr.Clothes_Proc(src)
	Naraku
		icon='Clothes, Naraku.dmi'
		Click() usr.Clothes_Proc(src)
	Demon_Arm
		icon='Clothes, Demon Arm.dmi'
		Click() usr.Clothes_Proc(src)
	Azure_Armor
		icon='Armor, Azure.dmi'
		Click() usr.Clothes_Proc(src)
	Wolf_Hermit
		icon='Clothes, Wolf Hermit.dmi'
		Click() usr.Clothes_Proc(src)
	Wristband
		icon='Clothes_Wristband.dmi'
		Click() usr.Clothes_Proc(src)
	Angel_Wings
		icon='Angel Wings.dmi'
		Click() usr.Clothes_Proc(src)
	Red_Eyes
		icon='Red Eyes.dmi'
		Click() usr.Clothes_Proc(src)
	Yellow_Eyes
		icon='Yellow Eyes.dmi'
		Click() usr.Clothes_Proc(src)
	Full_Yardrat
		icon='Clothes Full Yardrat.dmi'
		Click() usr.Clothes_Proc(src)
	Turban
		icon='Clothes_Turban.dmi'
		Click() usr.Clothes_Proc(src)
	TankTop
		icon='Clothes_TankTop.dmi'
		name="Tank Top"
		Click() usr.Clothes_Proc(src)
	ShortSleeveShirt
		icon='Clothes_ShortSleeveShirt.dmi'
		name="Shirt"
		Click() usr.Clothes_Proc(src)
	Shoes
		icon='Clothes_Shoes.dmi'
		Click() usr.Clothes_Proc(src)
	Jacket_2
		icon='Jacket 2.dmi'
		name="Jacket"
		Click() usr.Clothes_Proc(src)
	Hat
		icon='Hat.dmi'
		Click() usr.Clothes_Proc(src)
	Mask
		icon='Mask.dmi'
		Click() usr.Clothes_Proc(src)
	Sash
		icon='Clothes_Sash.dmi'
		Click() usr.Clothes_Proc(src)
	Kimono
		icon='Clothes, Kimono.dmi'
		Click() usr.Clothes_Proc(src)
	Pants
		icon='Clothes_Pants.dmi'
		Click() usr.Clothes_Proc(src)
	PurantoScarf
		icon='Clothes_NamekianScarf.dmi'
		Click() usr.Clothes_Proc(src)
		name="Scarf"
	LongSleeveShirt
		icon='Clothes_LongSleeveShirt.dmi'
		name="Long Shirt"
		Click() usr.Clothes_Proc(src)
	KaioSuit
		icon='Clothes_KaioSuit.dmi'
		name="Kaio Suit"
		Click() usr.Clothes_Proc(src)
	Jacket
		icon='Clothes_Jacket.dmi'
		Click() usr.Clothes_Proc(src)
	Headband
		icon='Clothes_Headband.dmi'
		Click() usr.Clothes_Proc(src)
	Gloves
		icon='Clothes_Gloves.dmi'
		Click() usr.Clothes_Proc(src)
	Boots
		icon='Clothes_Boots.dmi'
		Click() usr.Clothes_Proc(src)
	Bandana
		icon='Clothes_Bandana.dmi'
		Click() usr.Clothes_Proc(src)
	Belt
		icon='Clothes_Belt.dmi'
		Click() usr.Clothes_Proc(src)
	Cape
		icon='Clothes_Cape.dmi'
		Click() usr.Clothes_Proc(src)
	Kaio_Shirt
		icon='Clothes, Kaio Shirt.dmi'
		Click() usr.Clothes_Proc(src)
	Tsurusennin
		icon='Clothes, Tsurusennin.dmi'
		Click() usr.Clothes_Proc(src)
	Shorts
		icon='Clothes, Female Shorts.dmi'
		Click() usr.Clothes_Proc(src)
	Female_Shirt
		icon='Clothes, Female Shirt.dmi'
		name="Shirt"
		Click() usr.Clothes_Proc(src)
	Frontless_Cape
		icon='Clothes, Cape 2.dmi'
		Click() usr.Clothes_Proc(src)
	Female_Gi
		icon='Clothes, Gi Female.dmi'
		Click() usr.Clothes_Proc(src)
		name="Gi"
	Ninja_Mask
		icon='Clothes, Ninja Mask.dmi'
		Click() usr.Clothes_Proc(src)
	Ninja_Mask_2
		icon='Clothes, Ninja Mask 2.dmi'
		name="Ninja Mask"
		Click() usr.Clothes_Proc(src)
	Pimp_Hat
		icon='Clothes, Pimp Hat.dmi'
		Click() usr.Clothes_Proc(src)
	Assassin_Hoodless
		icon='Clothes, Assassin, Hoodless.dmi'
		Click() usr.Clothes_Proc(src)
	Assassin
		icon='Clothes, Assassin.dmi'
		Click() usr.Clothes_Proc(src)
	Power_Suit
		icon='Armor 8.dmi'
		Click() usr.Clothes_Proc(src)
	Daimaou_Cape
		icon='Clothes, Daimaou Cape.dmi'
		Click() usr.Clothes_Proc(src)
	Yasai_Gloves
		icon='Clothes, Saiyan Gloves.dmi'
		Click() usr.Clothes_Proc(src)
	Horns
		icon='Clothes, Horns.dmi'
		Click() usr.Clothes_Proc(src)
	Book
		icon='Clothes, Book.dmi'
		Click() usr.Clothes_Proc(src)
	Yasai_Shoes
		icon='Clothes, Saiyan Shoes.dmi'
		Click() usr.Clothes_Proc(src)
	Gi_Bottom
		icon='Clothes_GiBottom.dmi'
		Click() usr.Clothes_Proc(src)
	Gi_Top
		icon='Clothes_GiTop.dmi'
		Click() usr.Clothes_Proc(src)
	Kitsune
		icon='Kitsune.dmi'
		Click() usr.Clothes_Proc(src)
	Neko
		icon='Clothes, Neko.dmi'
		Click() usr.Clothes_Proc(src)
	Tuxedo
		icon='Clothes Tuxedo.dmi'
		Click() usr.Clothes_Proc(src)
	Beard
		icon='Beard.dmi'
		Click() usr.Clothes_Proc(src)
	Sunglasses
		icon='Item - Sun Glassess.dmi'
		Click() usr.Clothes_Proc(src)
	Tien
		icon='Tien Clothes.dmi'
		Click() usr.Clothes_Proc(src)
	Kaio_Suit
		icon='Clothes Kaio Suit.dmi'
		Click() usr.Clothes_Proc(src)
	Puran_Jacket
		icon='Clothes Namek Jacket.dmi'
		Click() usr.Clothes_Proc(src)
	Guardian_Robe
		icon='Clothes Guardian.dmi'
		Click() usr.Clothes_Proc(src)
	Daimaou_Robe
		icon='Clothes Daimaou.dmi'
		Click() usr.Clothes_Proc(src)
	Undies
		icon='Clothes Diaper.dmi'
		Click() usr.Clothes_Proc(src)
obj/items/Hover_Chair
	Cost=10000
	desc="This will let you have fully functional flying abilities."
	icon='Item, Hover Chair.dmi'
	icon_state="base"
	density=1
	layer=MOB_LAYER+10
	New()
		var/image/A=image(icon='Item, Hover Chair.dmi',icon_state="side1",pixel_y=0,pixel_x=-32,layer=10)
		var/image/B=image(icon='Item, Hover Chair.dmi',icon_state="side2",pixel_y=0,pixel_x=32,layer=10)
		var/image/C=image(icon='Item, Hover Chair.dmi',icon_state="back",pixel_y=0,pixel_x=-0,layer=MOB_LAYER-1)
		var/image/D=image(icon='Item, Hover Chair.dmi',icon_state="front",pixel_y=0,pixel_x=0,layer=MOB_LAYER+10)
		var/image/E=image(icon='Item, Hover Chair.dmi',icon_state="bottom",pixel_y=-32,pixel_x=0,layer=10)
		overlays.Remove(A,B,C,D,E)
		overlays.Add(A,B,C,D,E)
		//..()
	Click()
		usr.Clothes_Equip(src)
		if(suffix) usr.animate_movement=0
		else usr.animate_movement=1
mob/var/Regen_Mult=1
mob/var/Recov_Mult=1
obj/items/Magic_Food
	desc="This magic food will speed up your healing exponentially and heal you of all injuries and sicknesses. \
	If you plant this, it will magically grow more over time. It will only grow if a player is nearby."
	Stealable=1
	New()
		pixel_x=rand(-12,12)
		pixel_y=rand(-12,12)
		icon=pick('Food Tomato.dmi','Food Turnip.dmi','Food Potato.dmi',\
		'Food Jungle Fruit.dmi','Food Grapes.dmi','Food Corn.dmi')
	verb/Use()
		var/mob/M=locate(/mob) in get_step(usr,usr.dir)
		if(!M) M=usr
		if(usr.KO)
			usr<<"You can't, you are knocked out"
			return
		if(M.Android)
			usr<<"This has no effect on androids"
			return
		if(M.Regen_Mult<5) M.Regen_Mult=5
		if(M.Recov_Mult<2) M.Recov_Mult=2
		if(M==usr) view(usr)<<"[M] eats a [src]"
		else view(usr)<<"[usr] uses a [src] on [M]"
		for(var/obj/Injuries/I in M) del(I)
		M.Diarea=0
		M.Zombie_Virus=0
		del(src)
	verb/Throw(mob/M in oview(usr))
		view(usr)<<"[usr] throws a [src] to [M]"
		missile(icon,usr,M)
		sleep(3)
		view(usr)<<"[M] catches the [src]"
		M.contents+=src
mob/proc/Magic_Food_Grow() spawn while(src)
	for(var/obj/items/Magic_Food/F in view(10,src)) if(F.z)
		var/N=0
		for(var/obj/items/Magic_Food/MF in range(0,F)) if(MF.z) N++
		if(N<5)
			view(F)<<"Another [F] has magically appeared!"
			var/obj/MF2=new/obj/items/Magic_Food(F.loc)
			if(prob(95)) MF2.icon=F.icon
			break
	sleep(600)
obj/var/Using
obj/var/Bolted
obj/items/Shikon_Jewel
	Blueprintable=0
	//Cost=1000000000
	icon='Shikon Jewel.dmi'
	Stealable=1
	//Health=1.#INF
	var/BP_Multiplier=1.5
	desc="This jewel is ancient and grants power to those who possess it. The jewel is very well known to demons due to the \
	many who have possessed it, so it is possible that many demons know of its existance already."
	New() spawn if(src) Original_Icon()
	proc/Original_Icon() while(src)
		icon=initial(icon)
		sleep(300)
	Click() usr<<"[BP_Multiplier]x BP Multiplier"
	verb/Split()
		if(BP_Multiplier<1.05)
			usr<<"This can not be split any further"
			return
		var/obj/items/Shikon_Jewel/S=new
		usr.contents+=S
		S.BP_Multiplier=sqrt(BP_Multiplier)
		BP_Multiplier=sqrt(BP_Multiplier)
		view(usr)<<"[usr] splits the [src] in half"
	verb/Assemble()
		for(var/obj/items/Shikon_Jewel/S in usr) if(S!=src)
			view(usr)<<"[usr] combines 2 shards of the [src]"
			BP_Multiplier*=S.BP_Multiplier
			S.name="Tens"
			del(S)
			return
		usr<<"You must have another [src] in your items to combine them"
mob/var/Roid_Power=0
obj/items/Steroids
	icon='Item, Needle.dmi'
	Cost=100
	var/Roid_Power=0.1
	desc="BP up, force down, resistance down, speed down, defense down, recovery down, lifespan down. Steroids make \
	you unable to mate. All effects are temporary except the lifespan decrease. The more you take, or the more upgraded \
	they are, the greater the advantages and disadvantages."
	verb/Use(mob/A in view(1,usr)) if(A==usr||A.Frozen||A.KO)
		if(A.Android)
			usr<<"This has no effect on androids"
			return
		if(A.Roid_Power>=2&&Roid_Power<=2)
			usr<<"They are maxed out on steroids, injecting this will do nothing."
			return
		A.Undo_Steroid_Stats()
		A.Roid_Power+=Roid_Power
		if(Roid_Power<=2&&A.Roid_Power>2) A.Roid_Power=2
		A.Original_Decline-=Roid_Power
		A.Decline-=Roid_Power
		A.Steroid_Stats()
		view(usr)<<"[usr] injects [A] with a mysterious needle!"
		del(src)
	verb/Upgrade()
		set src in view(1)
		if(usr in view(1,src))
			var/Max=2
			var/Amount=input("[src] is at level [Roid_Power]. The maximum is [Max]. Input what level you wish to bring this to: \
			([Roid_Power] to [Max]). Each 0.1 cost [Cost/usr.Intelligence]$") as num
			if(Amount<Roid_Power) return
			if(Amount>Max) Amount=Max
			Amount-=Roid_Power
			var/Roid_Cost=round((Cost/usr.Intelligence)*(Amount*10))
			if(usr.Res()<Roid_Cost)
				usr<<"You need [Roid_Cost]$ to do this"
				return
			usr.Alter_Res(-Roid_Cost)
			Roid_Power+=Amount
			view(usr)<<"[usr] upgraded [src] from level [Roid_Power-Amount] to level [Roid_Power]"
			desc="[src]: Level [Roid_Power]"
mob/proc/Steroid_Loop() while(src)
	if(Roid_Power)
		Roid_Power(-0.01)
		sleep(200)
	else sleep(1200)
mob/proc/Steroid_Stats()
	var/Amount=Roid_Power+1
	Pow/=Amount
	PowMod/=Amount
	Res/=Amount
	ResMod/=Amount
	Spd/=Amount
	SpdMod/=Amount
	Def/=Amount**2
	DefMod/=Amount**2
	Recovery/=Amount
mob/proc/Undo_Steroid_Stats()
	var/Amount=Roid_Power+1
	Pow*=Amount
	PowMod*=Amount
	Res*=Amount
	ResMod*=Amount
	Spd*=Amount
	SpdMod*=Amount
	Def*=Amount**2
	DefMod*=Amount**2
	Recovery*=Amount
mob/proc/Roid_Power(Amount)
	Undo_Steroid_Stats()
	if(!Amount) Roid_Power=0
	else Roid_Power+=Amount
	if(Roid_Power<0) Roid_Power=0
	if(Roid_Power) Steroid_Stats()
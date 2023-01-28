obj/proc/Fire_Cook() for(var/mob/Body/A in range(1,src)) if(!A.Cooked)
	view(A)<<"[A] is cooked by the [src]"
	Cook(A)
proc/Cook_Check(mob/A) //Checks if a fire is nearby to make A cook
	for(var/obj/Turfs/HellPot/B in view(1,A)) return 1
	for(var/obj/Turfs/Torch1/B in view(1,A)) return 1
	for(var/obj/Turfs/Torch2/B in view(1,A)) return 1
	for(var/obj/Turfs/Torch3/B in view(1,A)) return 1
	for(var/obj/Turfs/Fire/B in view(1,A)) return 1
	for(var/obj/Turfs/Stove/B in view(1,A)) return 1
proc/Cook(mob/Body/A) if(!A.Cooked)
	A.Level*=10
	A.icon='Food Leg.dmi'
	A.name="Food Leg"
	A.overlays=null
	A.Cooked=1
mob/var/Poisoned=0
obj/Grave
	icon='Graves.dmi'
	icon_state="5"
	Savable=1
	density=1
	Knockable=0
	Click() usr<<"<font size=3><font color=#0099FF>[desc]"
mob/Body
	var/Cooked
	Level=0.2 //How much it boosts your healing if you eat this.
	Del()
		if(!Cooked&&NPC_Leave_Body) Body_Parts()
		..()
	verb/Bury()
		set src in view(1)
		var/obj/Grave/G=new(loc)
		G.icon_state=pick("1","2","3","4","5")
		view(usr)<<"[usr] buries [src]"
		G.desc="Here lies [src]"
		var/A=input(usr,"Write what you want on the gravestone, people who click it can read it") as text
		if(A&&G) G.desc=A
		del(src)
	verb/Eat()
		set src in view(1)
		if(usr.Regen_Mult>=2)
			usr<<"You are too full to eat"
			return
		view(usr)<<"[usr] eats the [src]"
		if(!Level&&usr.Race!="Demon"&&!usr.Android&&!usr.Dead)
			view(usr)<<"[usr] becomes poisoned"
			usr.Poisoned+=5
		else
			if(usr.Regen_Mult<Level) usr.Regen_Mult=Level
			if(usr.Regen_Mult>2) usr<<"You are now full"
		Cooked=1
		del(src)
	New()
		spawn(6000) if(src)
			overlays+='Flies.dmi'
			Level=0
		//..()
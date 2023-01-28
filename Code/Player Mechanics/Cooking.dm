obj/proc/Fire_Cook() for(var/mob/Body/A in range(1,src)) if(!A.Cooked)
	player_view(15,A)<<"[A] is cooked by the [src]"
	Cook(A)
proc/Cook_Check(mob/A) //Checks if a fire is nearby to make A cook
	for(var/obj/Turfs/HellPot/B in view(1,A)) return 1
	for(var/obj/Turfs/Torch1/B in view(1,A)) return 1
	for(var/obj/Turfs/Torch2/B in view(1,A)) return 1
	for(var/obj/Turfs/Torch3/B in view(1,A)) return 1
	for(var/obj/Turfs/Fire/B in view(1,A)) return 1
	for(var/obj/Turfs/Stove/B in view(1,A)) return 1
proc/Cook(mob/Body/A) if(!A.Cooked)
	A.Level*=6
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
	takes_gradual_damage=1
	Click() usr<<"<font size=3><font color=#0099FF>[desc]"
	New()
		if(z&&loc==initial(loc)) Savable=0
		. = ..()

var/list/all_bodies = new

mob/Body
	var/Cooked

	var
		tmp
			hit_by_zombie

	verb/Bury()
		set src in view(1)
		var/obj/Grave/G=new(loc)
		G.Health=Avg_BP * 2.5
		G.icon_state=pick("1","2","3","4","5")
		player_view(15,usr)<<"[usr] buries [src]"
		G.desc="Here lies [src]"
		var/A=input(usr,"Write what you want on the gravestone, people who click it can read it") as text
		if(A&&G) G.desc=A
		del(src)

	verb/Use()
		set src in view(1)
		player_view(15,usr)<<"[usr] eats the [src]"
		if(!Level&&usr.Race!="Demon"&&!usr.Android&&!usr.Dead)
			player_view(15,usr)<<"[usr] becomes poisoned"
			usr.Apply_poison(1)
		else
			usr.Alter_regen_mult(1)
			usr.Alter_recov_mult(1)
		Cooked=1
		del(src)

	New()
		all_bodies += src
		spawn(9000) if(src)
			overlays+='Flies.dmi'
			Level=0
		//. = ..()
area/tournament_area
	Enter(mob/m)
		if(ongoingTournament && !m.IsRoundFighter()) return
		..()

var/list/Fighter_Spots=new
obj/Fighter_Spot //You place 2 of these at the appropriate spots in the arena, it's where the 2 opponents spawn
	Dead_Zone_Immune=1
	Health=1.#INF
	Grabbable=0
	Savable=0
	Bolted=1
	Makeable=0
	Givable=0

	New()
		Fighter_Spots ||= list()
		Fighter_Spots |= src

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
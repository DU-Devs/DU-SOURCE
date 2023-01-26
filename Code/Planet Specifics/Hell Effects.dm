obj/Make_Holy_Pendant
	teachable=1
	Skill=1
	hotbar_type="Ability"
	can_hotbar=1
	Teach_Timer=3
	student_point_cost = 10
	desc="This ability can make pendants that can protect people from the tortures of hell"
	var/Next_Use=0
	verb/Hotbar_use()
		set hidden=1
		Make_Holy_Pendant()
	verb/Make_Holy_Pendant()
		set category = "Skills"
		if(GetGlobalYear()>=Next_Use)
			usr.contents+=new/obj/items/Holy_Pendant
			Next_Use=GetGlobalYear()+5
		else usr<<"You can only make one of these per 5 years"
obj/items/Holy_Pendant
	icon='Holy Pendant.dmi'
	desc="This pendant protects people from the tortures of hell"
	Stealable=1
	verb/Hotbar_use()
		set hidden=1
		return
mob/proc/Hell_Immune()
	. = 0
	if(locate(/obj/items/Holy_Pendant) in item_list) return 1
	else if(Race in list("Demon")) return 1
obj/Image
	layer=10
	Savable=0

var/Hell_Torture=0
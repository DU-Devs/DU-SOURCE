var/list/Yasai_armor_icons = list('Armor Bardock.dmi','Armor2.dmi','Armor3.dmi','Armor4.dmi','Armor5.dmi',
	'Armor7.dmi','Armor_Elite.dmi','Armor_Rit1.dmi','Armor_Rit2.dmi','Nappa Armor.dmi','Raditz Armor Tobi Uchiha.dmi',\
	'Turles Armor Tobi Uchiha.dmi','WTF Armor.dmi','Red Armor.dmi','Blue Armor.dmi')

proc
	RandomHumanIcon()
		return pick('BaseHumanPale.dmi','BaseHumanTan.dmi','BaseHumanDark.dmi',\
		'New Pale Female.dmi','New Tan Female.dmi','New Black Female.dmi')

	RandomHairIcon()
		var/obj/h = pick(Hairs)
		return h.icon

var/list/Yasai_soldiers = new

mob
	Yasai_Army
		var
			init

		New()
			Yasai_soldiers += src

			if(!init)
				icon = RandomHumanIcon()
				overlays += RandomHairIcon()
				overlays += pick(Yasai_armor_icons) //temp
				init = 1

			. = ..()

		Del()
			Yasai_soldiers -= src
			. = ..()

		Yasai_Soldier
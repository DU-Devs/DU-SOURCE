proc/PopulateClothesChoices()
	for(var/A in typesof(/obj/items/Clothes)) if(A != /obj/items/Clothes)
		var/obj/items/Clothes/c = new A
		c.underlays += pick('BaseHumanTan.dmi','BaseHumanPale.dmi','BaseHumanDark.dmi')
		c.dir = SOUTH
		Clothing += c
		var/obj/weights_icon/wi=new
		wi.appearance = c.appearance
		weights_icons += wi

		Clothing = SortListOfObjectsAlphabetically(Clothing)

mob/proc/Clothes_Equip(obj/A) if(A.loc==src)
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
		B.Move(src)
	else Clothes_Equip(A)

var/list/Clothing=new

obj/items/Clothes
	clonable = 1
	Savable=0
	can_change_icon=1
	ignore_body_swap=1

	verb/Hotbar_use()
		set hidden=1
		usr.Clothes_Proc(src)

	Chadku_Suit
		icon = 'GokuSuit.dmi'
		Click() usr.Clothes_Proc(src)

	Black_Chadku_Suit
		icon = 'Black Goku Suit Fixed.dmi'
		Click() usr.Clothes_Proc(src)

	Phoenix_Torso_Onion_Lad
		icon='Phoenix Torso (Makyo).dmi'
		Click() usr.Clothes_Proc(src)

	Phoenix_Torso
		icon='Phoenix Torso.dmi'
		Click() usr.Clothes_Proc(src)

	Phoenix_Pauldrons_Onion_Lad
		icon='Phoenix Pauldrons Makyo.dmi'
		Click() usr.Clothes_Proc(src)

	Phoenix_Pauldrons
		icon='Phoenix Pauldrons.dmi'
		Click() usr.Clothes_Proc(src)

	Uncoloured_Armour_Plating
		name = "Armor Plating"
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
		name = "Wings"
		icon='ToS Wings (Black).dmi'
		Click() usr.Clothes_Proc(src)

	Neko_Collar
		icon='Neko Collar.dmi'
		Click() usr.Clothes_Proc(src)

	VV_Gauntlet
		name = "Gauntlet"
		icon='VV Gauntlet (Black).dmi'
		Click() usr.Clothes_Proc(src)

	Flowing_Cape
		name = "Cape"
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

	Gi_Tobi_Uchiha
		icon='Clothes_Gi Custom.dmi'
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
		name = "Yardrat"
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

	Akatsuki
		icon='Dragon Akatsuki Outfit.dmi'
		Click() usr.Clothes_Proc(src)

	LongSleeveShirt
		icon='Clothes_LongSleeveShirt.dmi'
		name="Long Shirt"
		Click() usr.Clothes_Proc(src)

	KaioSuit
		icon='Clothes_KaioSuit.dmi'
		name="Kai Suit"
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
		icon='Item Piccolo Cape.dmi'
		Click() usr.Clothes_Proc(src)

	Kaio_Shirt
		name = "Kai Shirt"
		icon='Clothes, Kaio Shirt.dmi'
		Click() usr.Clothes_Proc(src)

	Tsurusennin
		name = "Crane Master"
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
		name = "Daimao Cape"
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
		name = "Kai Suit"
		icon='Clothes Kaio Suit.dmi'
		Click() usr.Clothes_Proc(src)

	Puranto_Jacket
		icon='Clothes Namek Jacket.dmi'
		Click() usr.Clothes_Proc(src)

	Guardian_Robe
		icon='Clothes Guardian.dmi'
		Click() usr.Clothes_Proc(src)

	Daimaou_Robe
		name = "Daimao Robe"
		icon='Clothes Daimaou.dmi'
		Click() usr.Clothes_Proc(src)

	Undies
		icon='Clothes Diaper.dmi'
		Click() usr.Clothes_Proc(src)

	Broly_Waistrobe
		name = "Broly"
		icon='Broly Waistrobe.dmi'
		Click() usr.Clothes_Proc(src)
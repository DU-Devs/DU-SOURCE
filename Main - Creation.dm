mob/proc/Location(First_Spawn=0)
	if(world.maxz<5)
		loc=locate(1,1,1)
		return
	if(Earth_Only)
		loc=locate(rand(82,122),rand(256,296),1)
		return
	if(Race_Count(Race,Race_Z())>=5&&Race_Z()) for(var/obj/Spawn/S) if(S.z==Race_Z())
		loc=S.loc
		return
	if(Spawn_Bind) for(var/obj/Spawn/S) if(S.desc==Spawn_Bind)
		loc=S.loc
		return
	var/list/Spawns
	for(var/obj/Spawn/S) if((S.name==Race&&Class!="Half-Yasai")||S.name==Class)
		if(!Spawns) Spawns=new/list
		Spawns+=S
	var/list/C=new
	for(var/obj/O in Spawns) C+=O.desc
	var/Choice
	if(client) Choice=input(src,"Choose an available spawn location below") in C
	else if(C.len) Choice=pick(C)
	var/obj/Spawn/S
	for(var/obj/Spawn/SS) if(SS.name==Race&&SS.desc==Choice) S=SS
	if(S)
		loc=S.loc
		if(First_Spawn)
			if(S.desc=="Earth Demon (Weaker)")
				BP_Mod=1.4
				Gravity_Mastered=1
				Base_BP=rand(1,150)
				Decline=20
				Decline_Rate=0.25
			if(S.desc=="Jungle Planet")
				Base_BP*=2
				Max_Ki=300*Eff
				Off=100*OffMod
				Def=100*DefMod
				if(Gravity_Mastered<15) Gravity_Mastered=15
	if(!z) loc=locate(1,1,1)
	Planet_Gravity()
	if(Gravity_Mastered<Gravity) Gravity_Mastered=Gravity
proc/Race_Count(R,Z)
	var/A=0
	for(var/mob/P in Players) if(P.Race==R) if(!Z||Z==P.z) A++
	return A
mob/proc/Race_Z()
	var/list/L
	for(var/mob/P in Players) if(P.Race==Race&&P!=src&&P.z&&!P.Dead)
		if(!L) L=new/list
		L+=P.z
	if(!L) return
	return Found_Most(L)
mob/proc
	Gender()
		if(!(Race in list("Majin","Bio-Android","Puranto","Android")))
			var/Choice=alert(src,"Choose a gender","","Male","Female")
			switch(Choice)
				if("Female") gender="female"
				if("Male") gender="male"
mob/proc
	Human_Skins()
		if(gender=="male") switch(input(src,"Choose your skin color") in list("Pale","Tan","Dark"))
			if("Pale") icon='New Pale Male.dmi'
			if("Tan") icon='New Tan Male.dmi'
			if("Dark") icon='New Black Male.dmi'
		else switch(input(src,"Choose your skin color") in list("Pale","Tan","Dark"))
			if("Pale") icon='New Pale Female.dmi'
			if("Tan") icon='New Tan Female.dmi'
			if("Dark") icon='New Black Female.dmi'
	Skin()
		var/Colorable
		if(Race=="Alien") Grid(Alien_Icons)
		else if(Race=="Frost Lord") Icer_Icons()
		else if(Race=="Bio-Android") switch(input(src,"What color body?") in list("Green","Blue"))
			if("Green") icon='Bio Android 1.dmi'
			if("Blue") icon='Bio1.dmi'
		else if(Race=="Android")
			switch(input(src,"Android or Human icon?") in list("Android","Human"))
				if("Android")
					Choose_Android_Icon()
					Colorable=1
				if("Human")
					Human_Skins()
					Colorable=0
		else if(Class=="Spirit Doll")
			//icon='Spirit Doll.dmi'
			icon='White Kaio.dmi'
		else if(Race=="Lunatak") icon='Makyojin 2.dmi'
		else if(Race in list("Phrexian","Deity"))
			if(gender=="male") icon='Custom Male.dmi'
			else icon='Custom Female.dmi'
			Colorable=1
			switch(input(src,"What icon do you want?") in list("Custom","Human","Avatar"))
				if("Human")
					Human_Skins()
					Colorable=0
				if("Avatar") icon='Avatar.dmi'
		else if(Race=="Demon")
			Grid(Demon_Icons)
			Colorable=1
		else if(Race=="Majin")
			icon='Majin.dmi'
			Colorable=1
		else if(Race in list("Puranto","Ancient Puranto"))
			icon='Namek.dmi'
			switch(input(src,"Choose your skin color") in list("Light Green","Green","Dark Green","Dragon Clan","Foreign Puran"))
				if("Light Green") icon+=rgb(30,30,30)
				if("Dark Green") icon-=rgb(30,30,30)
				if("Dragon Clan") icon='Namek Young.dmi'
				if("Foreign Puran") icon='Namek 2.dmi'
		else
			Human_Skins()
			if(Race=="Demigod") icon+=rgb(60,60,60)
		if(Colorable)
			var/A=input(src,"Choose a color for your character's icon. Select Cancel to have no added color") as color|null
			if(A) icon+=A
var/list/Alien_Icons=new
obj/Alien_Icons
	Givable=0
	Makeable=0
	proc/Choose()
		usr.icon=icon
		if(istype(src,/obj/Alien_Icons/Human)) usr.Human_Skins()
		if(usr) usr.Tabs="Customize Stats"
	Alien1 icon='Alien, Beetle.dmi'
	Alien2 icon='Alien, Pikkon.dmi'
	Alien3 icon='Alien, Kanassa.dmi'
	Alien4 icon='Alien, Guldo.dmi'
	Alien5 icon='Alien, Bass.dmi'
	Alien6 icon='Alien, Burter.dmi'
	Alien7 icon='Race Ginyu.dmi'
	Alien8 icon='Race Kui.dmi'
	Alien9 icon='Alien 1.dmi'
	Alien10 icon='Alien 2.dmi'
	Alien11 icon='Alien 3.dmi'
	Alien12 icon='Immecka.dmi'
	Alien13 icon='Yukenojin.dmi'
	Alien14 icon='Baseniojin.dmi'
	Alien15 icon='Konatsu.dmi'
	Alien16 icon='Kanassan.dmi'
	Alien17 icon='Yardrat.dmi'
	Alien18 icon='Makyojin 2.dmi'
	Alien19 icon='Alien 5.dmi'
	Alien20 icon='Alien 4.dmi'
	Alien21 icon='Alien 6.dmi'
	Alien22 icon='Alien7.dmi'
	Alien23 icon='Alien 8.dmi'
	Alien24 icon='Alien 9.dmi'
	Alien25 icon='Alien 10.dmi'
	Alien26 icon='Alien, Frog.dmi'
	Alien27 icon='Alien Hive.dmi'
	Alien28 icon='Demon Ifrit.dmi'
	//Alien29 icon='Blob.dmi'
	Alien30 icon='Kid Alien.dmi'
	Alien31 icon='Fat Guy.dmi'
	Alien32 icon='Antumb.dmi'
	Human suffix="Look like a Human"
var/icon/Blob='Blob.dmi' //To keep Blob.dmi in the rsc now that its not an alien icon
var/list/Demon_Icons=new
obj/Demon_Icons
	Givable=0
	Makeable=0
	proc/Choose(mob/P)
		P.icon=icon
		if(istype(src,/obj/Demon_Icons/Human)) P.Human_Skins()
		if(P) P.Tabs="Customize Stats"
	Demon1 icon='Demon1.dmi'
	Demon2 icon='Demon2.dmi'
	Demon3 icon='Hades.dmi'
	Demon4 icon='Alien 2.dmi'
	Demon5 icon='Alien 3.dmi'
	Demon6 icon='Demon4.dmi'
	Demon7 icon='Demon5.dmi'
	Demon8 icon='Demon6.dmi'
	Demon9 icon='Demon6, Female.dmi'
	Demon10 icon='Demon7.dmi'
	Demon11 icon='Darkrai2.dmi'
	Demon12 icon='Demon, Janemba.dmi'
	Demon13 icon='Demon, Uber Vampire.dmi'
	Demon14 icon='Demon, Wolf.dmi'
	Demon15 icon='Demon, Elemental.dmi'
	Demon16 icon='Alien Skully.dmi'
	Demon17 icon='Alien Tattoo.dmi'
	Demon18 icon='Demon Death.dmi'
	Demon19 icon='Alien Hive.dmi'
	Demon20 icon='Demon Ifrit.dmi'
	Demon21 icon='Blob.dmi'
	Demon22 icon='Antumb.dmi'
	Demon23 icon='HollowKing.dmi'
	Demon24 icon='Satan.dmi'
	Demon25 icon='Makaioshin Base.dmi'
	Demon26 icon='Lucifer.dmi'
	Demon27 icon='Possessed Spirit Doll.dmi'
	Demon28 icon='werewolf icon.dmi'
	Human suffix="Look like a Human"
mob/proc/Icer_Icons()
	var/list/L=new
	for(var/B in typesof(/obj/Icer)) L+=new B
	Grid(L)
obj/Icer
	name="Icon"
	Givable=0
	Makeable=0
	Click()
		if(!usr.Form1Icon)
			usr<<"First Form icon chosen"
			usr.icon=icon
			usr.Form1Icon=icon
		else if(!usr.Form2Icon)
			usr<<"Second Form icon chosen"
			usr.Form2Icon=icon
		else if(!usr.Form3Icon)
			usr<<"Third Form icon chosen"
			usr.Form3Icon=icon
		else if(!usr.Form4Icon)
			usr<<"Final Form icon chosen"
			usr.Form4Icon=icon
	C30 icon='C1.dmi'
	C31 icon='C2.dmi'
	C32 icon='C3.dmi'
	C33 icon='C4.dmi'
	C34 icon='C5.dmi'
	C35 icon='C6.dmi'
	C36 icon='C7.dmi'
	C37 icon='C8.dmi'
	C38 icon='C9.dmi'
	C39 icon='C10.dmi'
	C40 icon='C11.dmi'
	C1 icon='Changeling Frieza 100% 2.dmi'
	C2 icon='Changeling Frieza 100%.dmi'
	C3 icon='Changeling Frieza 100% 3.dmi'
	C4 icon='Changeling Frieza 2.dmi'
	C5 icon='Changeling Frieza Form 2, 2.dmi'
	C6 icon='Changeling Frieza Form 2.dmi'
	C7 icon='Changeling Frieza Form 3, 2.dmi'
	C8 icon='Changeling Frieza Form 3.dmi'
	C9 icon='Changeling Frieza Form 4, 2.dmi'
	C10 icon='Changeling Frieza Form 4.dmi'
	C11 icon='Changeling Frieza.dmi'
	C12 icon='Changeling Kold 2.dmi'
	C13 icon='Changeling Kold Form 2.dmi'
	C14 icon='Changeling Kold.dmi'
	C15 icon='Changeling Koola 2.dmi'
	C16 icon='Changeling Koola Form 2.dmi'
	C17 icon='Changeling Koola Form 3, 2.dmi'
	C18 icon='Changeling Koola Form 3.dmi'
	C19 icon='Changeling Koola Form 4, 3.dmi'
	C20 icon='Changeling Koola Form 4.dmi'
	C21 icon='Changeling Koola.dmi'
	C22 icon='Changeling Kuriza.dmi'
	C23 icon='Changeling Koola Expand.dmi'
	C24 icon='Changeling Koola Expand 2.dmi'
	C25 icon='Changeling 1 Large.dmi'
	C26 icon='Changeling 5 Frieza.dmi'
	C27 icon='Changeling 5 Kold.dmi'
	C28 icon='Changeling Frieza Form 4, 3.dmi'
	C29 icon='Changeling Frieza BE.dmi'
mob/proc/Choose_Hair()
	if((Race in list("Majin","Bio-Android","Puranto","Android","Frost Lord"))&&!icon) return
	Grid(Hairs)
var/list/Hairs=new
proc/Fill_Hair_List() for(var/A in typesof(/obj/Hairs)) if(A!=/obj/Hairs) Hairs+=new A
obj/Hairs
	Givable=0
	Makeable=0
	var/SSj_Hair
	var/USSj_Hair
	var/SSjFP_Hair
	var/SSj2_Hair
	var/SSj3_Hair
	Bald/Click() Apply_Hair(usr,src)
	Hair1
		New()
			icon='Hair, Shaggy.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='Hair_SSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair2
		New()
			icon='Hair, Ren.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='Hair_SSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair3
		New()
			icon='Hair, Short Female.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='Hair_SSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair4
		New()
			icon='Hair, Ponytail.dmi'
			SSj_Hair='Hair, Ponytail, SSJ.dmi'
			USSj_Hair=SSj_Hair
			SSjFP_Hair='Hair, Ponytail, SSJFP.dmi'
			SSj2_Hair=SSj_Hair
			SSj3_Hair='Hair_SSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair5
		New()
			icon='Hair, Female, Ponytail.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='Hair_SSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair6
		New()
			icon='Hair, Messy.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='Hair_SSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair7
		New()
			icon='Hair, Bushy.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='Hair_SSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair8
		New()
			icon='Hair, Brown, Headband.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='Hair_SSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair9
		New()
			icon='Hair, Blue, Male.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='Hair_SSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair10
		New()
			icon='Hair, Cloud.dmi'
			SSj_Hair=icon
			USSj_Hair=icon
			SSjFP_Hair=icon
			SSj2_Hair=icon
			SSj3_Hair=icon
		Click() Apply_Hair(usr,src)
	Hair11
		New()
			icon='Hair Super 17.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='Hair_SSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair12
		New()
			icon='Hair Kidd.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='Hair_SSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair13
		New()
			icon='Hair Muse.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='Hair_SSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair14
		New()
			icon='Hair_Goku.dmi'
			SSj_Hair='Hair_GokuSSj.dmi'
			USSj_Hair='Hair_GokuUSSj.dmi'
			SSjFP_Hair='Hair_GokuSSjFP.dmi'
			SSj2_Hair='Hair_GokuUSSj.dmi'
			SSj3_Hair='Hair_GokuSSj3.dmi'
		Click() Apply_Hair(usr,src)
	Hair15
		New()
			icon='Hair_Vegeta.dmi'
			SSj_Hair='Hair_VegetaSSj.dmi'
			USSj_Hair='Hair_VegetaUSSj.dmi'
			SSjFP_Hair='Hair_VegetaSSjFP.dmi'
			SSj2_Hair='Hair_VegetaSSj.dmi'
			SSj3_Hair='Hair_SSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair16
		New()
			icon='Hair_Raditz.dmi'
			SSj_Hair='Hair_RaditzSSj.dmi'
			USSj_Hair='Hair_GokuSSj3.dmi'
			SSjFP_Hair='Hair_RaditzSSjFP.dmi'
			SSj2_Hair='Hair_RaditzSSj.dmi'
			SSj3_Hair='Hair_GokuSSj3.dmi'
		Click() Apply_Hair(usr,src)
	Hair17
		New()
			icon='Hair_FutureGohan.dmi'
			SSj_Hair='Hair_GohanSSj.dmi'
			USSj_Hair='Hair_GohanUSSj.dmi'
			SSjFP_Hair='Hair_GohanSSjFP.dmi'
			SSj2_Hair='Hair_GohanSSj.dmi'
			SSj3_Hair='Hair_SSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair18
		New()
			icon='Hair_Gohan.dmi'
			SSj_Hair='Hair_GohanSSj.dmi'
			USSj_Hair='Hair_GohanUSSj.dmi'
			SSjFP_Hair='Hair_GohanSSjFP.dmi'
			SSj2_Hair='Hair_GohanSSj.dmi'
			SSj3_Hair='Hair_SSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair19
		New()
			icon='Hair_Long.dmi'
			SSj_Hair='Hair_LongSSj.dmi'
			USSj_Hair='Hair_LongUSSj.dmi'
			SSjFP_Hair='Hair_LongSSjFP.dmi'
			SSj2_Hair='Hair_LongSSj.dmi'
			SSj3_Hair='Hair_SSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair20
		New()
			icon='Hair_KidGohan.dmi'
			SSj_Hair='Hair_KidGohanSSj.dmi'
			USSj_Hair='Hair_KidGohanUSSj.dmi'
			SSjFP_Hair='Hair_KidGohanSSjFP.dmi'
			SSj2_Hair='Hair_KidGohanUSSj.dmi'
			SSj3_Hair='Hair_SSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair21
		New()
			icon='Hair Kylin 2.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair='Hair_FemaleLongSSj.dmi'
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='Hair_SSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair22
		New()
			icon='Hair Kylin 3.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='Hair_SSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair23
		New()
			icon='Hair Afro.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair=SSj_Hair
		Click() Apply_Hair(usr,src)
	Hair24
		New()
			icon='Hair Kylin 1.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='Hair_SSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair25
		New()
			icon='Hair_FemaleLong.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair='Hair_FemaleLongSSj.dmi'
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='Hair_SSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair26
		New()
			icon='Hair_FemaleLong2.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair='Hair_FemaleLongSSj.dmi'
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='Hair_SSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair27
		New()
			icon='Hair_Long.dmi'
			SSj_Hair='Hair_LongSSj.dmi'
			USSj_Hair='Hair_LongUSSj.dmi'
			SSjFP_Hair='Hair_LongSSjFP.dmi'
			SSj2_Hair='Hair_LongSSj.dmi'
			SSj3_Hair='Hair_SSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair28
		New()
			icon='Hair_Goten.dmi'
			SSj_Hair='Hair_GokuSSj.dmi'
			USSj_Hair='Hair_GokuUSSj.dmi'
			SSjFP_Hair='Hair_GokuSSjFP.dmi'
			SSj2_Hair='Hair_GokuSSj.dmi'
			SSj3_Hair='Hair_SSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair29
		New()
			icon='Hair_GTTrunks.dmi'
			SSj_Hair='Hair_LongSSj.dmi'
			USSj_Hair='Hair_GokuUSSj.dmi'
			SSjFP_Hair='Hair_LongSSjFP.dmi'
			SSj2_Hair='Hair_LongSSj.dmi'
			SSj3_Hair='Hair_SSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair30
		New()
			icon='Hair_GTVegeta.dmi'
			SSj_Hair='Hair_GTVegetaSSj.dmi'
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair='Hair_GTVegetaSSj.dmi'
			SSj3_Hair='Hair_SSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair31
		New()
			icon='Hair_Mohawk.dmi'
			SSj_Hair='Hair_MohawkSSj.dmi'
			USSj_Hair='Hair_LongUSSj.dmi'
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair='Hair_MohawkSSj.dmi'
			SSj3_Hair='Hair_SSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair32
		New()
			icon='Hair_Spike.dmi'
			SSj_Hair='Hair_SpikeSSj.dmi'
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=SSj_Hair
			SSj3_Hair='Hair_SSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair33
		New()
			icon='Hair_Yamcha.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='Hair_SSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair34
		New()
			icon='Hair Vegeta Junior.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='Hair_SSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair35
		New()
			icon='Hair Lan.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='Hair_SSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair36
		New()
			icon='BlackSSJhair.dmi'
			SSj_Hair='Hair_GokuSSj.dmi'
			USSj_Hair='Hair_GokuUSSj.dmi'
			SSjFP_Hair='Hair_GokuSSjFP.dmi'
			SSj2_Hair='Hair_GokuUSSj.dmi'
			SSj3_Hair='Hair_GokuSSj3.dmi'
		Click() Apply_Hair(usr,src)
	Hair37
		New()
			icon='VegitoHairPVP.dmi'
			SSj_Hair='Hair_GokuUSSj.dmi'
			USSj_Hair='Hair_GokuUSSj.dmi'
			SSjFP_Hair='Hair_GokuUSSj.dmi'
			SSj2_Hair='Hair_GokuUSSj.dmi'
			SSj3_Hair='Hair_GokuSSj3.dmi'
		Click() Apply_Hair(usr,src)
	Hair38
		New()
			icon='Mezu Hair.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='Hair SSJ4 Gogeta.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair39
		New()
			icon='Hair - Stylish (Black).dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='Hair SSJ4 Gogeta.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair40
		New()
			icon='Hope FFXIII Hair.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='Hair_SSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair41
		New()
			icon='Hair SSJ4 Gogeta.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='Hair_GokuSSj3.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair42
		New()
			icon='Hair Hitsugaya.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='Hair_SSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
proc/Apply_Hair(mob/P,obj/Hairs/O)
	var/Had_Tail
	if(P.Tail) Had_Tail=1
	P.Tail_Remove()
	P.overlays-=P.hair
	P.base_hair=null
	P.hair=O.icon
	P.ssjhair=O.SSj_Hair
	P.ussjhair=O.USSj_Hair
	P.ssjfphair=O.SSjFP_Hair
	P.ssj2hair=O.SSj2_Hair
	P.ssj3hair=O.SSj3_Hair
	P.Hair_Base=P.hair
	P.Hair_Age=P.Age
	P.ssj4hair=null
	if(O.icon)
		if((P.Race!="Yasai"&&P.hair)||(P.Race=="Yasai"&&P.icon))
			P.HairColor=input(P,"Choose a hair color. Hit Cancel to have default color.") as color|null
			if(P.HairColor) P.hair+=P.HairColor
		P.ssj4hair='Hair_SSj4.dmi'
		if(P.HairColor) P.ssj4hair+=P.HairColor
		P.base_hair=P.hair
		P.overlays+=P.hair
	if(Had_Tail) P.Tail_Add()
	P<<"You have selected [O]"
mob/proc/Choose_Android_Icon()
	Android_Icons()
	Grid(Android_Icons)
	while(Grid()) sleep(1)
var/list/Android_Icons
proc/Android_Icons() if(!Android_Icons)
	Android_Icons=new/list
	for(var/V in list('Android.dmi','AndroidBlackout.dmi','AndroidSkeletor.dmi','AndroidSpider.dmi',\
	'BaseAndroid1.dmi','BaseAndroid2.dmi','AndroidProxy.dmi'))
		var/obj/Base_Icon/O=new
		O.icon=V
		Android_Icons+=O
obj/Base_Icon
	Makeable=0
	Givable=0
	Savable=0
	Click()
		usr.icon=icon
		usr<<"Character icon chosen"
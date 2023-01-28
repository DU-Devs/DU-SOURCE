/*
ability to add custom characters
*/
var/dbz_character_mode=0
var/list/dbz_characters=new
var/list/playable_dbz_characters=list("Goku","Gohan","Piccolo","Vegeta","Trunks","Yamcha","Krillin",\
	"Tien","Chaotsu","Master Roshi","Raditz","Kami","Mr Popo","Nappa","Turles","Bardock","Garlic Jr",\
	"Saibaman","Guldo","Burter","Jace","Recoome","Captain Ginyu","Appule","Kui","Zarbon","Dodoria")
var/list/disabled_dbz_characters=new
var/tmp/list/dbz_avatars=new
mob/var/tmp/choosing_dbz_character
mob/var/dbz_character

mob/Admin4/verb/Toggle_DBZ_Character_Mode()
	set category="Admin"
	dbz_character_mode=!dbz_character_mode
	if(dbz_character_mode)
		src<<"DBZ Character Mode is now on. This means that at the log on screen people will be able to \
		choose a prebuilt DBZ character if someone online is not already playing it. When a person loads \
		the character it will be exactly the same as the last person who played it with all the gained \
		BP and stats and so on."
	else
		src<<"DBZ Character Mode is now off"

mob/Admin4/verb/Disable_DBZ_Character()
	set category="Admin"
	switch(alert(src,"Enable or disable a dbz character?","Options","Enable","Disable"))
		if("Enable")
			while(src)
				var/list/l=disabled_dbz_characters
				l.Insert(1,"Cancel")
				if(l.len<=1)
					src<<"There are no dbz characters disabled"
					return
				var/n=input(src,"Which character to enable?") in l
				if(!n||n=="Cancel") return
				disabled_dbz_characters-=n
		if("Disable")
			while(src)
				var/list/l=playable_dbz_characters
				for(var/v in l) if(v in disabled_dbz_characters) l-=v
				l.Insert(1,"Cancel")
				if(l.len<=1)
					src<<"There are no enabled dbz characters"
					return
				var/n=input(src,"Which character to disable?") in l
				if(!n||n=="Cancel") return
				disabled_dbz_characters+=n

mob/proc/Choose_dbz_character()
	choosing_dbz_character=1
	while(choosing_dbz_character)
		var/list/L=Get_playable_dbz_characters()
		if(client)
			winset(src,"Grid1","title=\"DBZ Character menu. (Empty if all are being played)\"")
			winset(src,"Grid1.Main Grid","show-names=true")
		Grid(L=L,update_only=1)
		sleep(60)

proc/Initialize_dbz_avatars()
	for(var/v in playable_dbz_characters)
		if(!(v in disabled_dbz_characters))
			Add_dbz_avatar(v)

proc/Add_dbz_avatar(n,bypass_exist_check)
	spawn if(1)
		if(bypass_exist_check) sleep(10)
		if(bypass_exist_check&&DBZ_character_exists(n)) return
		for(var/obj/o in dbz_avatars) if(o.name==n) del(o)
		if(n in disabled_dbz_characters) return
		dbz_avatars.len=playable_dbz_characters.len
		var/index=0
		if(n in playable_dbz_characters) index=playable_dbz_characters.Find(n)
		var/obj/DBZ_Character/a=new
		a.name=n
		var/mob/dbz=Generate_dbz_character(n,for_avatar=1,new_only=bypass_exist_check)
		a.icon=dbz.icon
		a.overlays=dbz.overlays
		if(!dbz.client) del(dbz)
		dbz_avatars.Insert(index,a)

proc/Remove_dbz_avatar(n)
	if(n=="Saibaman") return
	for(var/obj/o in dbz_avatars) if(o.name==n) del(o)

mob/proc/DBZ_character_del()
	if(!dbz_character) return
	Add_dbz_avatar(n=dbz_character,bypass_exist_check=1)

obj/DBZ_Character
	Click()
		if(DBZ_character_exists(name))
			usr<<"The [name] character is already taken"
			return
		usr.choosing_dbz_character=0
		usr.Hide_Main_Grid()
		usr.Load_dbz_character(name)

proc/Get_playable_dbz_characters()
	var/list/L=new
	for(var/obj/o in dbz_avatars)
		if(!DBZ_character_exists(o.name)&&!(o.name in disabled_dbz_characters)) L+=o
	return L

proc/DBZ_character_exists(n)
	if(n=="Saibaman") return
	for(var/mob/m in dbz_characters) if(m.dbz_character==n) return 1

mob/proc/Load_dbz_character(n)
	if(fexists("DBZ Character Saves/[n]")&&!DBZ_character_exists(n))
		var/savefile/f=new("DBZ Character Saves/[n]")
		Read(f)
		loc=locate(saved_x,saved_y,saved_z)
		dbz_characters+=src
		Remove_dbz_avatar(dbz_character)
		Other_Load_Stuff()
	else
		var/mob/dbz=Generate_dbz_character(n)
		dbz.Save_dbz_character(first_time=1)
		if(!dbz.client) del(dbz)
		Load_dbz_character(n)

mob/proc/Save_dbz_character(first_time)
	if(!dbz_character) return
	if(!first_time) Record_offline_gains()
	if(z&&!Regenerating)
		saved_x=x
		saved_y=y
		saved_z=z
	if(Ship&&Ship.z)
		saved_x=Ship.x
		saved_y=Ship.y
		saved_z=Ship.z

	var/mob/m=Duplicate(include_unclonables=1)
	m.key=null
	m.displaykey=null

	var/savefile/F=new("DBZ Character Saves/[dbz_character]")
	F["Last_Used"]<<world.realtime
	m.Write(F)
	m.dbz_character=null
	del(m)

proc/Generate_dbz_character(n,for_avatar,new_only)

	if(!new_only) for(var/mob/m in dbz_characters) if(m.dbz_character==n) return m

	var/mob/m=new

	if(fexists("DBZ Character Saves/[n]"))
		m.Load_dbz_character(n)
		return m

	var/force_low_class
	switch(n)
		if("Goku")
			m.loc=locate(100,100,1)
			m.icon='New Pale Male.dmi'
			force_low_class=1
		if("Gohan")
			m.loc=locate(100,100,1)
			m.icon='New Pale Male.dmi'
		if("Piccolo")
			m.loc=locate(100,100,1)
			m.icon='Namek.dmi'
		if("Vegeta")
			m.loc=locate(100,100,1)
			m.icon='New Tan Male.dmi'
		if("Trunks")
			m.loc=locate(100,100,1)
			m.icon='New Pale Male.dmi'
		if("Yamcha")
			m.loc=locate(100,100,1)
			m.icon='New Tan Male.dmi'
		if("Krillin")
			m.loc=locate(100,100,1)
			m.icon='New Pale Male.dmi'
		if("Tien")
			m.loc=locate(100,100,1)
			m.icon='New Pale Male.dmi'
		if("Chaotsu")
			m.loc=locate(100,100,1)
			m.icon='Spirit Doll.dmi'
		if("Master Roshi")
			m.loc=locate(100,100,1)
			m.icon='New Pale Male.dmi'
		if("Raditz")
			m.loc=locate(100,100,1)
			m.icon='New Tan Male.dmi'
		if("Kami")
			m.loc=locate(100,100,1)
			m.icon='Namek Old.dmi'
		if("Mr Popo")
			m.loc=locate(100,100,1)
			m.icon='Custom Male.dmi'
		if("Nappa")
			m.loc=locate(100,100,1)
			m.icon='White Male Muscular 3.dmi'
		if("Turles")
			m.loc=locate(100,100,1)
			m.icon='New Tan Male.dmi'
			force_low_class=1
		if("Bardock")
			m.loc=locate(100,100,1)
			m.icon='New Tan Male.dmi'
			force_low_class=1
		if("Garlic Jr")
			m.loc=locate(100,100,1)
			m.icon='Makyojin 2.dmi'
		if("Saibaman")
			m.loc=locate(100,100,1)
			m.icon='Saibaman.dmi'
		if("Guldo")
			m.loc=locate(100,100,1)
			m.icon='Alien, Guldo.dmi'
		if("Burter")
			m.loc=locate(100,100,1)
			m.icon='Alien, Burter.dmi'
		if("Jace")
			m.loc=locate(100,100,1)
			m.icon='Custom Male.dmi'+rgb(100,0,0)
		if("Recoome")
			m.loc=locate(100,100,1)
			m.icon='White Male Muscular 3.dmi'
		if("Captain Ginyu")
			m.loc=locate(100,100,1)
			m.icon='Race Ginyu.dmi'
		if("Zarbon")
			m.icon='Alien 4.dmi'
			m.loc=locate(100,100,1)
		if("Dodoria")
			m.icon='Fat Guy.dmi'
			m.loc=locate(100,100,1)
		if("Appule")
			m.icon='Alien 9.dmi'
			m.loc=locate(100,100,1)
		if("Kui")
			m.icon='Race Kui.dmi'
			m.loc=locate(100,100,1)
	m.name=n
	m.dbz_character=n
	dbz_characters+=m
	var/force_elite
	if(n=="Vegeta") force_elite=1
	m.New_Character(force_race=DBZ_character_race_by_name(n),force_elite=force_elite,dbz_hair=n,\
	force_low_class=force_low_class)
	m.DBZ_starting_BP()
	m.Experience=100
	for(var/obj/Spawn/s in Spawn_List) if(s.z==m.z)
		m.Spawn_Bind=s.desc
		break
	for(var/obj/o in m) o.Mastery=9999
	if(for_avatar) m.dbz_character=null
	return m

proc/DBZ_character_race_by_name(n)
	switch(n)
		if("Goku") return "Saiyan"
		if("Gohan") return "Half Saiyan"
		if("Piccolo") return "Namek"
		if("Vegeta") return "Saiyan"
		if("Trunks") return "Half Saiyan"
		if("Yamcha") return "Human"
		if("Krillin") return "Human"
		if("Tien") return "Human"
		if("Chaotsu") return "Spirit Doll"
		if("Master Roshi") return "Human"
		if("Raditz") return "Saiyan"
		if("Mr Popo") return "Alien"
		if("Kami") return "Namek"
		if("Nappa") return "Saiyan"
		if("Turles") return "Turles"
		if("Bardock") return "Bardock"
		if("Garlic Jr") return "Makyo"
		if("Saibaman") return "Alien"
		if("Guldo") return "Alien"
		if("Burter") return "Alien"
		if("Jace") return "Alien"
		if("Recoome") return "Alien"
		if("Captain Ginyu") return "Alien"
		if("Appule") return "Alien"
		if("Kui") return "Alien"
		if("Zarbon") return "Alien"
		if("Dodoria") return "Alien"

mob/proc/DBZ_hair(n)
	var/obj/Hairs/h
	var/hc
	switch(n)
		if("Goku") h=locate(/obj/Hairs/Hair14) in Hairs
		if("Gohan") h=locate(/obj/Hairs/Hair20) in Hairs
		if("Vegeta") h=locate(/obj/Hairs/Hair15) in Hairs
		if("Trunks")
			h=locate(/obj/Hairs/Hair19) in Hairs
			hc=rgb(153,0,204)
		if("Yamcha") h=locate(/obj/Hairs/Hair33) in Hairs
		if("Raditz") h=locate(/obj/Hairs/Hair16) in Hairs
		if("Turles") h=locate(/obj/Hairs/Hair14) in Hairs
		if("Bardock") h=locate(/obj/Hairs/Hair14) in Hairs
		if("Jace")
			h=locate(/obj/Hairs/Hair25) in Hairs
			hc=rgb(192,192,192)
		if("Recoome")
			h=locate(/obj/Hairs/Hair31) in Hairs
			hc=rgb(255,102,0)
		if("Zarbon")
			h=locate(/obj/Hairs/Hair33) in Hairs
			hc=rgb(0,128,0)
	if(h) Apply_Hair(P=src,O=h,force_color=hc)

mob/proc/DBZ_starting_BP()
	hbtc_bp=0
	switch(dbz_character)
		if("Goku") base_bp=416
		if("Vegeta") base_bp=16000
		if("Piccolo") base_bp=408
		if("Gohan")
			base_bp=800
			available_potential=0.01
		if("Trunks") base_bp=10000000
		if("Yamcha") base_bp=170
		if("Krillin") base_bp=206
		if("Tien")
			base_bp=192.3 //250 after third eye +30% boost
			var/obj/Third_Eye/te=new(contents)
			te.Using=1
			Third_Eye()
		if("Chaotsu") base_bp=145
		if("Master Roshi") base_bp=139
		if("Raditz") base_bp=1200
		if("Kami") base_bp=300
		if("Mr Popo") base_bp=500
		if("Nappa") base_bp=4000
		if("Turles") base_bp=10000
		if("Bardock") base_bp=8000
		if("Garlic Jr") base_bp=500
		if("Saibaman") base_bp=1200
		if("Guldo") base_bp=25000
		if("Burter") base_bp=45000
		if("Jace") base_bp=50000
		if("Recoome") base_bp=65000
		if("Captain Ginyu") base_bp=90000
		if("Appule") base_bp=1600
		if("Kui") base_bp=16000
		if("Dodoria") base_bp=20000
		if("Zarbon") base_bp=22000

mob/proc/DBZ_character_stats(n)
	switch(n)
		if("Goku")
			Raise_Energy(5)
			Raise_Strength(5)
			Raise_Durability(5)
			Raise_Speed(5)
			Raise_Force(5)
			Raise_Resist(5)
			Raise_Offense(5)
			Raise_Defense(5)
			Raise_Regeneration(5)
			Raise_Recovery(5)
			Raise_Anger(5)
		if("Gohan")
			Raise_Energy(5)
			Raise_Strength(0)
			Raise_Durability(0)
			Raise_Speed(8)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(8)
			Raise_Defense(8)
			Raise_Regeneration(0)
			Raise_Recovery(8)
			Raise_Anger(18)
		if("Piccolo")
			Raise_Energy(7)
			Raise_Strength(0)
			Raise_Durability(0)
			Raise_Speed(6)
			Raise_Force(3)
			Raise_Resist(6)
			Raise_Offense(6)
			Raise_Defense(12)
			Raise_Regeneration(12)
			Raise_Recovery(3)
			Raise_Anger(0)
		if("Vegeta")
			Raise_Energy(0)
			Raise_Strength(13)
			Raise_Durability(0)
			Raise_Speed(13)
			Raise_Force(13)
			Raise_Resist(0)
			Raise_Offense(13)
			Raise_Defense(0)
			Raise_Regeneration(0)
			Raise_Recovery(1)
			Raise_Anger(2)
		if("Trunks")
			Raise_Energy(5)
			Raise_Strength(7)
			Raise_Durability(7)
			Raise_Speed(4)
			Raise_Force(4)
			Raise_Resist(7)
			Raise_Offense(4)
			Raise_Defense(4)
			Raise_Regeneration(5)
			Raise_Recovery(4)
			Raise_Anger(4)
		if("Yamcha")
			Raise_Energy(5)
			Raise_Strength(4)
			Raise_Durability(3)
			Raise_Speed(10)
			Raise_Force(5)
			Raise_Resist(3)
			Raise_Offense(8)
			Raise_Defense(7)
			Raise_Regeneration(3)
			Raise_Recovery(5)
			Raise_Anger(2)
		if("Krillin")
			Raise_Energy(5)
			Raise_Strength(5)
			Raise_Durability(5)
			Raise_Speed(5)
			Raise_Force(5)
			Raise_Resist(5)
			Raise_Offense(5)
			Raise_Defense(5)
			Raise_Regeneration(5)
			Raise_Recovery(5)
			Raise_Anger(5)
		if("Tien")
			Raise_Energy(6)
			Raise_Strength(6)
			Raise_Durability(7)
			Raise_Speed(2)
			Raise_Force(7)
			Raise_Resist(7)
			Raise_Offense(6)
			Raise_Defense(6)
			Raise_Regeneration(5)
			Raise_Recovery(3)
			Raise_Anger(0)
		if("Chaotsu")
			Raise_Energy(0)
			Raise_Strength(0)
			Raise_Durability(0)
			Raise_Speed(10)
			Raise_Force(15)
			Raise_Resist(5)
			Raise_Offense(10)
			Raise_Defense(10)
			Raise_Regeneration(0)
			Raise_Recovery(5)
			Raise_Anger(0)
		if("Master Roshi")
			Raise_Energy(4)
			Raise_Strength(7)
			Raise_Durability(7)
			Raise_Speed(6)
			Raise_Force(7)
			Raise_Resist(7)
			Raise_Offense(7)
			Raise_Defense(7)
			Raise_Regeneration(0)
			Raise_Recovery(0)
			Raise_Anger(3)
		if("Raditz")
			Raise_Energy(10)
			Raise_Strength(4)
			Raise_Durability(12)
			Raise_Speed(7)
			Raise_Force(4)
			Raise_Resist(5)
			Raise_Offense(5)
			Raise_Defense(5)
			Raise_Regeneration(0)
			Raise_Recovery(0)
			Raise_Anger(3)
		if("Kami")
			Raise_Energy(15)
			Raise_Strength(0)
			Raise_Durability(5)
			Raise_Speed(5)
			Raise_Force(0)
			Raise_Resist(5)
			Raise_Offense(5)
			Raise_Defense(5)
			Raise_Regeneration(5)
			Raise_Recovery(10)
			Raise_Anger(0)
		if("Mr Popo")
			Raise_Energy(0)
			Raise_Strength(9)
			Raise_Durability(9)
			Raise_Speed(9)
			Raise_Force(0)
			Raise_Resist(5)
			Raise_Offense(9)
			Raise_Defense(9)
			Raise_Regeneration(0)
			Raise_Recovery(5)
			Raise_Anger(0)
		if("Nappa")
			Raise_Energy(0)
			Raise_Strength(10)
			Raise_Durability(15)
			Raise_Speed(0)
			Raise_Force(10)
			Raise_Resist(10)
			Raise_Offense(5)
			Raise_Defense(0)
			Raise_Regeneration(10)
			Raise_Recovery(0)
			Raise_Anger(5)
		if("Turles")
			Raise_Energy(0)
			Raise_Strength(8)
			Raise_Durability(8)
			Raise_Speed(2)
			Raise_Force(8)
			Raise_Resist(8)
			Raise_Offense(3)
			Raise_Defense(3)
			Raise_Regeneration(5)
			Raise_Recovery(5)
			Raise_Anger(5)
		if("Bardock")
			Raise_Energy(3)
			Raise_Strength(7)
			Raise_Durability(7)
			Raise_Speed(3)
			Raise_Force(5)
			Raise_Resist(6)
			Raise_Offense(6)
			Raise_Defense(6)
			Raise_Regeneration(4)
			Raise_Recovery(3)
			Raise_Anger(5)
		if("Garlic Jr")
			Raise_Energy(5)
			Raise_Strength(5)
			Raise_Durability(5)
			Raise_Speed(5)
			Raise_Force(5)
			Raise_Resist(5)
			Raise_Offense(5)
			Raise_Defense(5)
			Raise_Regeneration(5)
			Raise_Recovery(10)
			Raise_Anger(0)
		if("Saibaman")
			Raise_Energy(0)
			Raise_Strength(10)
			Raise_Durability(0)
			Raise_Speed(10)
			Raise_Force(10)
			Raise_Resist(0)
			Raise_Offense(10)
			Raise_Defense(0)
			Raise_Regeneration(5)
			Raise_Recovery(5)
			Raise_Anger(5)
		if("Guldo")
			Raise_Energy(10)
			Raise_Strength(0)
			Raise_Durability(0)
			Raise_Speed(10)
			Raise_Force(5)
			Raise_Resist(5)
			Raise_Offense(5)
			Raise_Defense(5)
			Raise_Regeneration(5)
			Raise_Recovery(5)
			Raise_Anger(5)
		if("Burter")
			Raise_Energy(0)
			Raise_Strength(5)
			Raise_Durability(5)
			Raise_Speed(20)
			Raise_Force(5)
			Raise_Resist(0)
			Raise_Offense(10)
			Raise_Defense(10)
			Raise_Regeneration(0)
			Raise_Recovery(0)
			Raise_Anger(0)
		if("Jace")
			Raise_Energy(5)
			Raise_Strength(5)
			Raise_Durability(5)
			Raise_Speed(5)
			Raise_Force(5)
			Raise_Resist(5)
			Raise_Offense(5)
			Raise_Defense(5)
			Raise_Regeneration(5)
			Raise_Recovery(5)
			Raise_Anger(5)
		if("Recoome")
			Raise_Energy(4)
			Raise_Strength(10)
			Raise_Durability(6)
			Raise_Speed(3)
			Raise_Force(8)
			Raise_Resist(6)
			Raise_Offense(5)
			Raise_Defense(5)
			Raise_Regeneration(5)
			Raise_Recovery(0)
			Raise_Anger(3)
		if("Captain Ginyu")
			Raise_Energy(5)
			Raise_Strength(9)
			Raise_Durability(9)
			Raise_Speed(3)
			Raise_Force(9)
			Raise_Resist(9)
			Raise_Offense(3)
			Raise_Defense(3)
			Raise_Regeneration(0)
			Raise_Recovery(5)
			Raise_Anger(0)
		if("Appule")
			Raise_Energy(5)
			Raise_Strength(5)
			Raise_Durability(0)
			Raise_Speed(10)
			Raise_Force(5)
			Raise_Resist(0)
			Raise_Offense(10)
			Raise_Defense(0)
			Raise_Regeneration(10)
			Raise_Recovery(10)
			Raise_Anger(0)
		if("Kui")
			Raise_Energy(5)
			Raise_Strength(10)
			Raise_Durability(0)
			Raise_Speed(10)
			Raise_Force(10)
			Raise_Resist(0)
			Raise_Offense(8)
			Raise_Defense(0)
			Raise_Regeneration(5)
			Raise_Recovery(5)
			Raise_Anger(2)
		if("Dodoria")
			Raise_Energy(6)
			Raise_Strength(7)
			Raise_Durability(6)
			Raise_Speed(-3)
			Raise_Force(8)
			Raise_Resist(6)
			Raise_Offense(6)
			Raise_Defense(6)
			Raise_Regeneration(7)
			Raise_Recovery(6)
			Raise_Anger(0)
		if("Zarbon")
			Raise_Energy(4)
			Raise_Strength(5)
			Raise_Durability(4)
			Raise_Speed(7)
			Raise_Force(3)
			Raise_Resist(5)
			Raise_Offense(7)
			Raise_Defense(7)
			Raise_Regeneration(6)
			Raise_Recovery(4)
			Raise_Anger(3)
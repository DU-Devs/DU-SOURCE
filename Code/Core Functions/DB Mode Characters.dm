var/list/playable_db_characters = list(\
"Goku",\
"Gohan",\
"Piccolo",\
"Yamcha",\
"Krillin",\
"Tien",\
"Chaotsu",\
"Bulma",\
"Chichi",\
"Master Roshi",\
"Kami",\
"Mr Popo",\
"King Kai",\
"Garlic Jr",\
"Greenster",\
"Raditz",\
"Nappa",\
"Braal",\
"Turles",\
"Bardock",\
"Appule",\
"Kui",\
"Zarbon",\
"Dodoria",\
"Guldo",\
"Burter",\
"Jace",\
"Recoome",\
"Captain Ginyu",\
"Freeza",\
"King Cold",\
"Cooler",\
"Trunks",\
"19"\
)

proc/Generate_dbz_character(n,for_avatar,new_only)

	if(!new_only) for(var/mob/m in dbz_characters) if(m.dbz_character==n) return m

	var/mob/m = new

	if(DBZ_character_exists(n)) return DBZ_character_exists(n)

	if(!for_avatar && fexists("DBZ Character Saves/[n]"))
		m.Load_dbz_character(n = n, for_generation = 1)
		return m

	m.SafeTeleport(DBCharSpawnLoc(n))
	m.icon = DBCharIcon(n)
	var/force_low_class = DBCharIsLowClass(n)
	m.name=n
	m.dbz_character = n
	dbz_characters+=m

	//temporary special handling block for certain characters til we do the real thing
	var/force_elite
	if(n == "Braal") force_elite=1

	m.New_Character(force_race = DBZ_character_race_by_name(n), force_elite = force_elite, dbz_hair=n,\
	force_low_class=force_low_class)
	m.DBZ_starting_BP()
	for(var/obj/Spawn/s in Spawn_List) if(s.z==m.z)
		m.Spawn_Bind=s.desc
		break
	if(for_avatar) m.dbz_character=null

	//temp handling block
	if(n == "Freeza")
		m.Form1Icon = 'C1.dmi'
		m.Form2Icon = 'Changeling Frieza Form 2, 2.dmi'
		m.Form3Icon = 'Changeling Frieza Form 3.dmi'
		m.Form4Icon = 'Changeling Frieza 100%.dmi'
	if(n == "Cooler")
		m.Form1Icon = 'C2.dmi'
		m.Form2Icon = 'C2.dmi'
		m.Form3Icon = 'C2.dmi'
		m.Form4Icon = 'C6.dmi'
	if(n == "King Cold")
		m.Form1Icon = 'Changeling Kold Form 2.dmi'
		m.Form2Icon = 'Changeling Kold Form 2.dmi'
		m.Form3Icon = 'Changeling Kold Form 2.dmi'
		m.Form4Icon = 'Changeling Kold Form 2.dmi'
	if(n == "Bulma")
		m.bp_mult *= 0.5

	m.Intelligence *= DBCharIntMultByName(n)
	m.max_ki = 5000 * m.Eff
	m.Raise_Stats(2000)
	m.fly_mastery = 100000
	m.gravity_mastered = 20
	//m.Experience=1600

	m.DBZCharSkills()

	return m

proc/DBCharSpawnLoc(n)
	switch(n)
		if("Raditz") return locate(305,135,1)
		if("Braal") return locate(305,135,1)
		if("Nappa") return locate(305,135,1)
		if("Greenster") return locate(305,135,1)
		if("Turles") return locate(305,135,1)
		if("Bardock") return locate(305,135,1)
		if("Appule") return locate(294,257,3)
		if("Kui") return locate(294,257,3)
		if("Zarbon") return locate(294,257,3)
		if("Dodoria") return locate(294,257,3)
		if("Guldo") return locate(294,257,3)
		if("Burter") return locate(294,257,3)
		if("Jace") return locate(294,257,3)
		if("Recoome") return locate(294,257,3)
		if("Captain Ginyu") return locate(294,257,3)
		if("Freeza") return locate(294,257,3)
		if("Cooler") return locate(294,257,3)
		if("King Cold") return locate(294,257,3)
		if("King Kai") return locate(287,452,5)
		if("Kami") return locate(150,9,2)
		if("Mr Popo") return locate(150,9,2)
		if("19") return locate(305,135,1)
	return locate(25, 170, 1)

proc/DBCharIsLowClass(n)
	switch(n)
		if("Goku") return 1
		if("Turles") return 1
		if("Bardock") return 1

proc/DBCharIntMultByName(n)
	switch(n)
		if("Bulma") return 1
	return 0.5 //everyone has really shit int by default even humans like Krillin

proc/DBCharIcon(n)
	switch(n)
		if("Goku") return 'BaseHumanPale.dmi'
		if("Gohan") return 'BaseHumanPale.dmi'
		if("Piccolo") return 'Namek.dmi'
		if("Braal") return 'BaseHumanTan.dmi'
		if("Trunks") return 'BaseHumanPale.dmi'
		if("Yamcha") return 'BaseHumanTan.dmi'
		if("Krillin") return 'BaseHumanPale.dmi'
		if("Tien") return 'BaseHumanPale.dmi'
		if("Chaotsu") return 'Spirit Doll.dmi'
		if("Master Roshi") return 'BaseHumanPale.dmi'
		if("Raditz") return 'BaseHumanTan.dmi'
		if("Kami") return 'Namek Old.dmi'
		if("Mr Popo") return 'Custom Male.dmi'
		if("Nappa") return 'White Male Muscular 3.dmi'
		if("Turles") return 'BaseHumanTan.dmi'
		if("Bardock") return 'BaseHumanTan.dmi'
		if("Garlic Jr") return 'Makyojin 2.dmi'
		if("Greenster") return 'Saibaman.dmi'
		if("Guldo") return 'Alien, Guldo.dmi'
		if("Burter") return 'Alien, Burter.dmi'
		if("Jace") return 'Custom Male.dmi'+rgb(100,0,0)
		if("Recoome") return 'White Male Muscular 3.dmi'
		if("Captain Ginyu") return 'Race Ginyu.dmi'
		if("Zarbon") return 'Alien 4.dmi'
		if("Dodoria") return 'Fat Guy.dmi'
		if("Appule") return 'Alien 9.dmi'
		if("Kui") return 'Race Kui.dmi'
		if("Freeza") return 'C1.dmi'
		if("Cooler") return 'C2.dmi'
		if("King Cold") return 'Changeling Kold Form 2.dmi'
		if("Bulma") return 'New Pale Female.dmi'
		if("King Kai") return 'Fat Guy.dmi'
		if("Chichi") return 'New Pale Female.dmi'
		if("19") return 'Spirit Doll.dmi'

mob/proc/DBZCharSkills()
	if(!dbz_character_mode) return

	contents.Add(new/obj/Fly, new/obj/Attacks/Blast, new/obj/Attacks/Charge, new/obj/Attacks/Beam, new/obj/Sense, new/obj/Advanced_Sense, \
	new/obj/Sense3, new/obj/Telepathy, new/obj/Dash_Attack, new/obj/Meditate_Level_2, new/obj/Give_Power, new/obj/Zanzoken, new/obj/Shield, \
	new/obj/Power_Control, new/obj/Observe, new/obj/Attacks/Makosen, new/obj/Attacks/Shockwave)

	switch(name)
		if("Goku")
			contents.Add(new/obj/Attacks/Kamehameha, new/obj/Taiyoken)
		if("Gohan")
		if("Piccolo")
			contents.Add(new/obj/Attacks/Masenko, new/obj/Attacks/Piercer, new/obj/Attacks/Makosen, new/obj/Heal, new/obj/Materialization)
		if("Braal")
			contents.Add(new/obj/Attacks/Spin_Blast, new/obj/Attacks/Kienzan)
		if("Trunks")
		if("Yamcha")
			contents.Add(new/obj/Attacks/Kamehameha, new/obj/SplitForm, new/obj/Attacks/Sokidan)
		if("Krillin")
			for(var/v in 1 to 3) contents += new/obj/items/Senzu
			contents.Add(new/obj/Attacks/Kamehameha, new/obj/Attacks/Kienzan, new/obj/Taiyoken, new/obj/SplitForm)
		if("Tien")
			Crane_Hermit()
		if("Chaotsu")
			Crane_Hermit()
			contents.Add(new/obj/Attacks/Explosion, new/obj/Self_Destruct, new/obj/Materialization)
		if("Master Roshi")
			Turtle_Hermit()
			contents.Add(new/obj/Materialization, new/obj/Bind)
		if("Raditz")
		if("Kami")
			Guardian()
		if("Mr Popo")
			Popo()
		if("Nappa")
		if("Turles")
		if("Bardock")
		if("Garlic Jr")
			contents.Add(new/obj/Giant_Form)
		if("Greenster")
			contents.Add(new/obj/Self_Destruct)
		if("Guldo")
			contents.Add(new/obj/Attacks/Time_Freeze)
		if("Burter")
		if("Jace")
		if("Recoome")
		if("Captain Ginyu")
		if("Zarbon")
			contents.Add(new/obj/Giant_Form)
		if("Dodoria")
		if("Kui")
		if("Freeza")
			contents.Add(new/obj/Attacks/Genki_Dama/Death_Ball, new/obj/Attacks/Genki_Dama/Supernova, new/obj/Attacks/Ray, new/obj/Attacks/Spin_Blast, \
			new/obj/Planet_Destroy, new/obj/Attacks/Kienzan, new/obj/Attacks/Explosion)
		if("Cooler")
			contents.Add(new/obj/Attacks/Genki_Dama/Death_Ball, new/obj/Attacks/Genki_Dama/Supernova, new/obj/Attacks/Ray, new/obj/Attacks/Spin_Blast, \
			new/obj/Planet_Destroy, new/obj/Attacks/Kienzan, new/obj/Attacks/Explosion)
		if("King Cold")
			contents.Add(new/obj/Attacks/Genki_Dama/Death_Ball, new/obj/Attacks/Genki_Dama/Supernova, new/obj/Attacks/Ray, new/obj/Attacks/Spin_Blast, \
			new/obj/Planet_Destroy, new/obj/Attacks/Kienzan, new/obj/Attacks/Explosion)
		if("Bulma")
		if("King Kai")
			North_Kai()

proc/DBZ_character_race_by_name(n)
	switch(n)
		if("Goku") return "Yasai"
		if("Gohan") return "Half Yasai"
		if("Piccolo") return "Puranto"
		if("Braal") return "Yasai"
		if("Trunks") return "Half Yasai"
		if("Yamcha") return "Human"
		if("Krillin") return "Human"
		if("Tien") return "Human"
		if("Chaotsu") return "Spirit Doll"
		if("Master Roshi") return "Human"
		if("Raditz") return "Yasai"
		if("Mr Popo") return "Alien"
		if("Kami") return "Puranto"
		if("Nappa") return "Yasai"
		if("Turles") return "Yasai"
		if("Bardock") return "Yasai"
		if("Garlic Jr") return "Onion Lad"
		if("Greenster") return "Alien"
		if("Guldo") return "Alien"
		if("Burter") return "Alien"
		if("Jace") return "Alien"
		if("Recoome") return "Alien"
		if("Captain Ginyu") return "Alien"
		if("Appule") return "Alien"
		if("Kui") return "Alien"
		if("Zarbon") return "Alien"
		if("Dodoria") return "Alien"
		if("Freeza") return "Frost Lord"
		if("Cooler") return "Frost Lord"
		if("King Cold") return "Frost Lord"
		if("Bulma") return "Human"
		if("King Kai") return "Kai"
		if("Chichi") return "Human"
		if("19") return "Human"

mob/proc/DBZ_hair(n)
	var/obj/Hairs/h
	var/hc
	switch(n)
		if("Goku") h=locate(/obj/Hairs/Hair14) in Hairs
		if("Gohan") h=locate(/obj/Hairs/Hair20) in Hairs
		if("Braal") h=locate(/obj/Hairs/Hair15) in Hairs
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
		if("Bulma")
			h = locate(/obj/Hairs/Hair21) in Hairs
			hc = rgb(0, 102, 255)
		if("Chichi") h = locate(/obj/Hairs/Hair26) in Hairs
	if(h) Apply_Hair(P=src,O=h,force_color=hc)

mob/proc/DBZ_starting_BP()
	hbtc_bp=0
	switch(dbz_character)
		if("Goku") base_bp = 416
		if("Braal") base_bp = 16000
		if("Piccolo") base_bp = 408
		if("Gohan")
			base_bp = 800
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
		if("Greenster") base_bp = 1200
		if("Guldo") base_bp=25000
		if("Burter") base_bp=45000
		if("Jace") base_bp=50000
		if("Recoome") base_bp=65000
		if("Captain Ginyu") base_bp=90000
		if("Appule") base_bp=1600
		if("Kui") base_bp=16000
		if("Dodoria") base_bp=20000
		if("Zarbon") base_bp=22000
		if("Freeza") base_bp = 530000
		if("King Cold") base_bp = 1000000
		if("Cooler") base_bp = 6000000
		if("Bulma") base_bp = 1
		if("King Kai") base_bp = 5000
		if("Chichi") base_bp = 150
		if("19") base_bp = 10000000

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
		if("Braal")
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
		if("Greenster")
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
		if("Freeza")
			Raise_Energy(10)
			Raise_Strength(0)
			Raise_Durability(10)
			Raise_Speed(10)
			Raise_Force(0)
			Raise_Resist(10)
			Raise_Offense(5)
			Raise_Defense(5)
			Raise_Regeneration(0)
			Raise_Recovery(0)
			Raise_Anger(5)
		if("King Cold")
			Raise_Energy(0)
			Raise_Strength(15)
			Raise_Durability(15)
			Raise_Speed(0)
			Raise_Force(0)
			Raise_Resist(15)
			Raise_Offense(10)
			Raise_Defense(0)
			Raise_Regeneration(0)
			Raise_Recovery(0)
			Raise_Anger(0)
		if("Cooler")
			Raise_Energy(5)
			Raise_Strength(5)
			Raise_Durability(10)
			Raise_Speed(5)
			Raise_Force(5)
			Raise_Resist(10)
			Raise_Offense(5)
			Raise_Defense(5)
			Raise_Regeneration(0)
			Raise_Recovery(0)
			Raise_Anger(5)
		if("King Kai")
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
		if("Chichi")
			Raise_Energy(7)
			Raise_Strength(7)
			Raise_Durability(7)
			Raise_Speed(7)
			Raise_Force(0)
			Raise_Resist(0)
			Raise_Offense(7)
			Raise_Defense(7)
			Raise_Regeneration(0)
			Raise_Recovery(5)
			Raise_Anger(8)
		if("19")
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
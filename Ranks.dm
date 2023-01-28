mob/proc/Give_Rank(mob/A)
	set category="Admin"
	var/list/Planets=list("Cancel","Earth","Puran","Braal","Arconia","Ice Planet","Heaven","Hell",\
	"Android Skill Master")//,"Z Character Skill Sets")
	var/list/Ranks=new
	switch(input(src,"Choose Planet Rank") in Planets)
		if("Cancel") return
		if("Z Character Skill Sets")
			switch(input(src,"What skill set?") in list("Cancel","Carrot_Man","Piccolo","Blowhan","Braal","Trunks","Tien",\
			"Yamcha","Krillin","Chaotsu","Freeza","Cell","Majin Buu"))
				if("Cancel") return
				if("Carrot_Man") A.Carrot_Man(src)
				if("Piccolo") A.Piccolo(src)
				if("Blowhan") A.Blowhan(src)
				if("Braal") A.Braal(src)
				if("Trunks") A.Trunks(src)
				if("Tien") A.Tien(src)
				if("Yamcha") A.Yamcha(src)
				if("Krillin") A.Krillin(src)
				if("Chaotsu") A.Chaotsu(src)
				if("Freeza") A.Freeza(src)
				if("Cell") A.Cell(src)
				if("Majin Buu") A.Majin_Buu(src)
		if("Earth")
			Ranks.Add("Cancel","Earth Guardian","Popo!","Korin","Turtle Hermit","Crane Hermit","Teacher")
			switch(input(src,"What Rank?") in Ranks)
				if("Cancel") return
				if("Earth Guardian") A.Guardian(src)
				if("Popo!") A.Popo(src)
				if("Korin") A.Korin(src)
				if("Turtle Hermit") A.Turtle_Hermit(src)
				if("Crane Hermit") A.Crane_Hermit(src)
				if("Teacher") A.Earth_Teacher(src)
		if("Puran")
			Ranks.Add("Cancel","Elder","Teacher")
			switch(input(src,"What Rank?") in Ranks)
				if("Cancel") return
				if("Elder") A.Elder(src)
				if("Teacher") A.Puran_Teacher(src)
		if("Braal")
			Ranks.Add("Cancel","Elite Yasai","Elite Alien")
			switch(input(src,"What Rank?") in Ranks)
				if("Cancel") return
				if("Elite Yasai") A.Elite_Yasai(src)
				if("Elite Alien") A.Elite_Alien(src)
		if("Arconia")
			Ranks.Add("Cancel","Yardrat Master","Skill Master")
			switch(input(src,"What Rank?") in Ranks)
				if("Cancel") return
				if("Yardrat Master") A.Yardrat_Master(src)
				if("Skill Master") A.Alien_Skill_Master(src)
		if("Ice Planet")
			Ranks.Add("Cancel","Skill Master")
			switch(input(src,"What Rank?") in Ranks)
				if("Cancel") return
				if("Skill Master") A.Ice_Skill_Master(src)
		if("Heaven")
			Ranks.Add("Cancel","Kaioshin","North Kaio","South/East/West Kaio","Kaio Helper")
			switch(input(src,"What Rank?") in Ranks)
				if("Cancel") return
				if("Kaioshin") A.Kaioshin(src)
				if("North Kaio") A.North_Deity(src)
				if("South/East/West Kaio") A.Cardinal_Deity(src)
				if("Kaio Helper") A.Kaio_Helper(src)
		if("Hell")
			Ranks.Add("Cancel","Daimao","Demon Master")
			switch(input(src,"What Rank?") in Ranks)
				if("Cancel") return
				if("Daimao") A.Daimaou(src)
				if("Demon Master") A.Demon_Master(src)
		if("Android Skill Master") A.Android_Skill_Master(src)
	for(var/obj/O in A) if(O.Mastery<100) O.Mastery=100
	A.Remove_Duplicate_Moves()
	src<<"You will still have to add them to the Ranks window. This only gives them the skills."
var/Auto_Rank
mob/Admin4/verb/Auto_Rank()
	set category="Admin"
	Auto_Rank=!Auto_Rank
	if(Auto_Rank) src<<"Auto ranking is now on, meaning that certain ranks will be given automatically if nobody \
	else online has it. They are only given to the appropriate races. This could be good for PVP servers."
	else src<<"Auto ranking is now off"
mob/var/list/Ranks=new
mob/proc/Rank_Check() if(Auto_Rank&&world.time>=5*600)
	if(Ranks.len) return //They already have a rank don't stack ranks
	var/list/Tags=list("Elder","Daimao","Cardinal Deity","North Deity","Kaioshin","Yardrat","Puran Teacher",\
	"Crane","Turtle","Korin","Popo","Guardian")
	for(var/V in Tags) if(!Ranks.len)
		var/mob/M
		for(M in Players) if(V in M.Ranks) break
		if(!M) switch(V)
			if("Daimao") if(Race=="Demon") Daimaou()
			if("Cardinal Deity") if(Race=="Deity") Cardinal_Deity()
			if("North Deity") if(Race=="Deity") North_Deity()
			if("Kaioshin") if(Race=="Deity") Kaioshin()
			if("Yardrat") if(Race=="Alien") Yardrat_Master()
			if("Puran Teacher") if(Race=="Puranto") Puran_Teacher()
			if("Elder") if(Race=="Puranto") Elder()
			if("Crane") if(Race=="Human") Crane_Hermit()
			if("Turtle") if(Race=="Human") Turtle_Hermit()
			if("Korin") if(z==1) Korin()
			if("Popo") if(z==1) Popo()
			if("Guardian") if(z==1) Guardian()
	Can_Remake=1
	for(var/obj/RankChat/RC in src) del(RC)
mob/proc
	Guardian(mob/P)
		if(P) Log(P,"[P.key] gave [key] Earth Guardian")
		Can_Remake=0
		Ranks+="Guardian"
		contents.Add(new/obj/Attacks/Blast,new/obj/Attacks/Charge,new/obj/Attacks/Beam,new/obj/Fly,\
		new/obj/Power_Control,new/obj/Heal,new/obj/Materialization,new/obj/Shield,new/obj/Give_Power,\
		new/obj/Keep_Body,new/obj/Bind,new/obj/Attacks/Attack_Barrier,new/obj/Sense,new/obj/Advanced_Sense)
		contents.Add(new/obj/Telepathy,new/obj/Observe,new/obj/Reincarnation,new/obj/Meditate_Level_2,\
		new/obj/Shadow_Spar,new/obj/Hide_Energy)
		if(Race=="Puranto") contents.Add(new/obj/Make_Lizard_Spheres)
		contents+=new/obj/RankChat
		if(Gravity_Mastered<2) Gravity_Mastered=2
		Attack_Gain(2000)
		if(Base_BP<100) Base_BP=100
		var/Keys=3
		while(Keys)
			Keys--
			var/obj/items/Door_Pass/D=new
			D.name="Time Chamber Key"
			D.Password=7125
			D.Blueprintable=0
			contents+=D
		src<<"<font color=yellow>You were given the Earth Guardian rank"
	Popo(mob/P)
		if(P) Log(P,"[P.key] gave [key] Popo")
		Can_Remake=0
		Ranks+="Popo"
		contents.Add(new/obj/Fly,new/obj/Power_Control,new/obj/Heal,new/obj/Materialization,new/obj/Shield,\
		new/obj/Give_Power,new/obj/Bind,new/obj/Telepathy,new/obj/Observe,new/obj/Zanzoken,new/obj/Reincarnation,\
		new/obj/Hokuto_Shinken,new/obj/Sense,new/obj/Advanced_Sense,new/obj/Meditate_Level_2,\
		new/obj/Shadow_Spar,new/obj/Hide_Energy)
		contents+=new/obj/RankChat
		if(Gravity_Mastered<2) Gravity_Mastered=2
		Attack_Gain(2000)
		if(Base_BP<100) Base_BP=100
		src<<"<font color=yellow>You were given the Popo rank"
	Korin(mob/P)
		if(P) Log(P,"[P.key] gave [key] Korin")
		Can_Remake=0
		Ranks+="Korin"
		contents.Add(new/obj/items/Magic_Food,new/obj/Fly,new/obj/Heal,new/obj/Give_Power,new/obj/Zanzoken,\
		new/obj/Power_Control,new/obj/Reincarnation,new/obj/Sense,new/obj/Advanced_Sense)
		contents.Add(new/obj/Telepathy,new/obj/Observe,new/obj/Meditate_Level_2,new/obj/Shadow_Spar,\
		new/obj/Hide_Energy)
		contents+=new/obj/RankChat
		if(Gravity_Mastered<2) Gravity_Mastered=2
		Attack_Gain(2000)
		if(Base_BP<100) Base_BP=100
		src<<"<font color=yellow>You were given the Korin rank"
	Turtle_Hermit(mob/P)
		if(P) Log(P,"[P.key] gave [key] Turtle Hermit")
		Can_Remake=0
		Ranks+="Turtle"
		contents.Add(new/obj/Attacks/Charge,new/obj/Attacks/Beam,new/obj/Attacks/Kakanakana,\
		new/obj/Zanzoken,new/obj/Fly,new/obj/Heal,new/obj/Give_Power,new/obj/Sense,\
		new/obj/Meditate_Level_2,new/obj/Shadow_Spar)
		contents+=new/obj/RankChat
		if(Gravity_Mastered<1.5) Gravity_Mastered=1.5
		Attack_Gain(2000)
		if(Base_BP<50) Base_BP=50
		src<<"<font color=yellow>You were given the Turtle Hermit rank"
	Crane_Hermit(mob/P)
		if(P) Log(P,"[P.key] gave [key] Crane Hermit")
		Can_Remake=0
		Ranks+="Crane"
		contents.Add(new/obj/Attacks/Blast,new/obj/Attacks/Beam,new/obj/Attacks/Dodompa,new/obj/Taiyoken,\
		new/obj/SplitForm,new/obj/Self_Destruct,new/obj/Attacks/Kikoho,new/obj/Fly,new/obj/Sense,\
		new/obj/Meditate_Level_2,new/obj/Shadow_Spar)
		contents+=new/obj/RankChat
		if(Gravity_Mastered<1.5) Gravity_Mastered=1.5
		Attack_Gain(2000)
		if(Base_BP<50) Base_BP=50
		src<<"<font color=yellow>You were given the Crane Hermit rank"
	Earth_Teacher(mob/P)
		if(P) Log(P,"[P.key] gave [key] Earth Teacher")
		Ranks+="Earth Teacher"
		contents.Add(new/obj/Attacks/Blast,new/obj/Attacks/Charge,new/obj/Attacks/Beam,new/obj/Fly,\
		new/obj/Attacks/Sokidan,new/obj/Heal,new/obj/Shield,new/obj/Attacks/Kienzan,new/obj/Sense,\
		new/obj/Meditate_Level_2,new/obj/Shadow_Spar,new/obj/Hide_Energy)
		Attack_Gain(1000)
		src<<"<font color=yellow>You were given the Earth Teacher rank"
	Elder(mob/P)
		if(P) Log(P,"[P.key] gave [key] Puran Elder")
		Can_Remake=0
		Ranks+="Elder"
		contents.Add(new/obj/Attacks/Charge,new/obj/Fly,new/obj/Heal,new/obj/Power_Control,\
		new/obj/Materialization,new/obj/Unlock_Potential,new/obj/Give_Power,new/obj/Shield,\
		new/obj/Meditate_Level_2,new/obj/Shadow_Spar,new/obj/Racial_Fusion,new/obj/Hide_Energy)
		if(Race=="Puranto") contents.Add(new/obj/Make_Lizard_Spheres,new/obj/Reincarnation)
		contents.Add(new/obj/Telepathy,new/obj/Observe,new/obj/Sense,new/obj/Advanced_Sense)
		contents+=new/obj/RankChat
		src<<"<font color=yellow>You were given the Puran Elder rank"
	Puran_Teacher(mob/P)
		if(P) Log(P,"[P.key] gave [key] Puran Teacher")
		Ranks+="Puran Teacher"
		contents.Add(new/obj/Attacks/Blast,new/obj/Attacks/Charge,new/obj/Attacks/Beam,new/obj/Attacks/Masenko,\
		new/obj/Attacks/Piercer,new/obj/Attacks/Sokidan,new/obj/Attacks/Scatter_Shot,\
		new/obj/Attacks/Makosen,new/obj/Fly,new/obj/Zanzoken,\
		new/obj/Power_Control,new/obj/SplitForm,new/obj/Heal,new/obj/Materialization,new/obj/Shield,\
		new/obj/Give_Power,new/obj/Attacks/Shockwave,new/obj/Sense,new/obj/Advanced_Sense,new/obj/Meditate_Level_2)
		contents.Add(new/obj/Telepathy,new/obj/Observe,new/obj/Shadow_Spar,new/obj/Racial_Fusion)
		Attack_Gain(1000)
		if(Base_BP<1000) Base_BP=1000
		src<<"<font color=yellow>You were given the Puran Master rank"
	Elite_Alien(mob/P)
		if(P) Log(P,"[P.key] gave [key] Elite Alien")
		Ranks+="Elite Alien"
		contents.Add(new/obj/Attacks/Charge,new/obj/Attacks/Explosion,new/obj/Attacks/Beam,\
		new/obj/Fly,new/obj/Attacks/Shockwave)
		Attack_Gain(1000)
		if(Base_BP<3000) Base_BP=3000
		src<<"<font color=yellow>You were given the Elite Alien rank"
	Yardrat_Master(mob/P)
		if(P) Log(P,"[P.key] gave [key] Yardrat Master")
		Can_Remake=0
		Ranks+="Yardrat"
		contents.Add(new/obj/Shunkan_Ido,new/obj/Fly,new/obj/Zanzoken,new/obj/Attacks/Blast,\
		new/obj/Attacks/Charge,new/obj/Attacks/Sokidan,new/obj/Heal,new/obj/Shield,new/obj/Limit_Breaker)
		contents.Add(new/obj/Telepathy,new/obj/Observe,new/obj/Attacks/Attack_Barrier,new/obj/Sense,\
		new/obj/Meditate_Level_2,new/obj/Shadow_Spar)
		src<<"<font color=yellow>You were given the Yardrat Master rank"
	Alien_Skill_Master(mob/P)
		if(P) Log(P,"[P.key] gave [key] Alien Master")
		Ranks+="Alien Skill Master"
		contents.Add(new/obj/Attacks/Blast,new/obj/Attacks/Charge,new/obj/Attacks/Beam,\
		new/obj/Attacks/Spin_Blast,new/obj/Attacks/Explosion,new/obj/Attacks/Sokidan,new/obj/Fly,\
		new/obj/Power_Control,new/obj/SplitForm,new/obj/Attacks/Shockwave)
		Attack_Gain(1000)
		if(Base_BP<1000) Base_BP=1000
		src<<"<font color=yellow>You were given the Alien Master rank"
	Ice_Skill_Master(mob/P)
		if(P) Log(P,"[P.key] gave [key] Ice Master")
		Ranks+="Ice Skill Master"
		contents.Add(new/obj/Attacks/Blast,new/obj/Attacks/Charge,new/obj/Attacks/Explosion,\
		new/obj/Attacks/Beam,new/obj/Attacks/Ray,new/obj/Attacks/Sokidan,new/obj/Attacks/Death_Ball,\
		new/obj/Fly,new/obj/Power_Control,new/obj/Shield,new/obj/Attacks/Kienzan,\
		new/obj/Attacks/Shockwave)
		src<<"<font color=yellow>You were given the Ice Master rank"
	Android_Skill_Master(mob/P)
		if(P) Log(P,"[P.key] gave [key] Android Master")
		Ranks+="Android Skill Master"
		contents.Add(new/obj/Attacks/Blast,new/obj/Attacks/Charge,new/obj/Attacks/Attack_Barrier,\
		new/obj/Attacks/Beam,new/obj/Attacks/Ray,new/obj/Attacks/Death_Ball,\
		new/obj/Fly,new/obj/Shield)
		src<<"<font color=yellow>You were given the Android Master rank"
	Kaioshin(mob/P)
		if(P) Log(P,"[P.key] gave [key] Kaioshin")
		Can_Remake=0
		Ranks+="Kaioshin"
		contents.Add(new/obj/Attacks/Blast,new/obj/Attacks/Charge,new/obj/Attacks/Beam,\
		new/obj/Attacks/Sokidan,new/obj/Attacks/Scatter_Shot,new/obj/Heal,new/obj/Shield,\
		new/obj/Give_Power,new/obj/Fly,new/obj/Power_Control,new/obj/Materialization,\
		new/obj/Unlock_Potential,new/obj/Keep_Body,new/obj/Restore_Youth,new/obj/Kaio_Revive,\
		new/obj/Bind,new/obj/Make_Fruit,new/obj/Teleport,new/obj/Make_Holy_Pendant,new/obj/Meditate_Level_2)
		contents.Add(new/obj/Telepathy,new/obj/Observe,new/obj/Reincarnation,new/obj/Sense,new/obj/Advanced_Sense,\
		new/obj/Shadow_Spar,new/obj/Mystic)
		contents+=new/obj/RankChat
		Attack_Gain(1000)
		if(Base_BP<5000) Base_BP=5000
		src<<"<font color=yellow>You were given the Kaioshin rank"
	North_Deity(mob/P)
		if(P) Log(P,"[P.key] gave [key] North Deity")
		Can_Remake=0
		Ranks+="North Deity"
		contents.Add(new/obj/Attacks/Charge,new/obj/Attacks/Sokidan,new/obj/Fly,new/obj/Heal,new/obj/Give_Power,\
		new/obj/Power_Control,new/obj/Keep_Body,new/obj/Kaio_Revive,new/obj/Materialization,\
		new/obj/Bind,new/obj/Kaioken,new/obj/Attacks/Genki_Dama,new/obj/Sense,new/obj/Advanced_Sense)
		contents.Add(new/obj/Telepathy,new/obj/Observe,new/obj/Reincarnation,new/obj/Meditate_Level_2,\
		new/obj/Shadow_Spar)
		contents+=new/obj/RankChat
		Attack_Gain(1000)
		if(Base_BP<1000) Base_BP=1000
		src<<"<font color=yellow>You were given the North Deity rank"
	Cardinal_Deity(mob/P)
		if(P) Log(P,"[P.key] gave [key] Cardinal Deity")
		Ranks+="Cardinal Deity"
		contents.Add(new/obj/Attacks/Blast,new/obj/Attacks/Charge,new/obj/Attacks/Beam,new/obj/Attacks/Sokidan,\
		new/obj/Fly,new/obj/Heal,new/obj/Shield,new/obj/Give_Power,new/obj/Power_Control,\
		new/obj/Materialization,new/obj/Keep_Body,new/obj/Kaio_Revive,new/obj/Limit_Breaker,new/obj/Bind)
		contents.Add(new/obj/Telepathy,new/obj/Observe,new/obj/Reincarnation,new/obj/Sense,new/obj/Advanced_Sense,\
		new/obj/Meditate_Level_2,new/obj/Shadow_Spar)
		contents+=new/obj/RankChat
		Attack_Gain(1000)
		if(Base_BP<1000) Base_BP=1000
		src<<"<font color=yellow>You were given the Cardinal Deity rank"
	Kaio_Helper(mob/P)
		if(P) Log(P,"[P.key] gave [key] Kaio Helper")
		Ranks+="Kaio Helper"
		contents.Add(new/obj/Kaio_Revive,new/obj/Keep_Body,new/obj/Heal,new/obj/Bind,new/obj/Reincarnation)
		src<<"<font color=yellow>You were given the Deity Helper rank"
	Daimaou(mob/P)
		if(P) Log(P,"[P.key] gave [key] Daimao")
		Can_Remake=0
		Ranks+="Daimao"
		contents.Add(new/obj/Attacks/Blast,new/obj/Attacks/Charge,new/obj/Attacks/Explosion,\
		new/obj/Attacks/Beam,new/obj/Attacks/Spin_Blast,new/obj/Attacks/Sokidan,new/obj/Attacks/Piercer,\
		new/obj/Self_Destruct,new/obj/Attacks/Genocide,new/obj/Fly,new/obj/Shield,\
		new/obj/SplitForm,new/obj/MakeAmulet,new/obj/Keep_Body,new/obj/Majin,\
		new/obj/Restore_Youth,new/obj/Materialization,new/obj/Bind,new/obj/Make_Fruit,new/obj/Demon_Contract,\
		new/obj/Kaio_Revive,new/obj/Attacks/Kienzan,new/obj/Attacks/Shockwave,new/obj/Make_Holy_Pendant)
		contents.Add(new/obj/Telepathy,new/obj/Observe,new/obj/Attacks/Attack_Barrier,new/obj/Reincarnation,\
		new/obj/Sense,new/obj/Advanced_Sense,new/obj/Meditate_Level_2,new/obj/Shadow_Spar)
		contents+=new/obj/RankChat
		Attack_Gain(1000)
		if(Base_BP<5000) Base_BP=5000
		src<<"<font color=yellow>You were given the Daimao (Demon Lord) rank"
	Demon_Master(mob/P)
		if(P) Log(P,"[P.key] gave [key] Demon Master")
		Ranks+="Demon Master"
		contents.Add(new/obj/Attacks/Blast,new/obj/Attacks/Charge,new/obj/Attacks/Explosion,\
		new/obj/Attacks/Spin_Blast,new/obj/Attacks/Beam,new/obj/Attacks/Sokidan,new/obj/Attacks/Piercer,\
		new/obj/Self_Destruct,new/obj/Attacks/Genocide,new/obj/Fly,new/obj/SplitForm,\
		new/obj/Keep_Body,new/obj/Materialization,new/obj/Majin,new/obj/Restore_Youth,\
		new/obj/Attacks/Shockwave,new/obj/Reincarnation,new/obj/Sense,new/obj/Meditate_Level_2,new/obj/Shadow_Spar)
		Attack_Gain(1000)
		if(Base_BP<1000) Base_BP=1000
		src<<"<font color=yellow>You were given the Demon Master rank"
mob/proc/Carrot_Man(mob/P)
	if(P) Log(P,"[P.key] gave [key] Carrot_Man Skills")
	contents.Add(new/obj/Attacks/Genki_Dama,new/obj/Attacks/Kakanakana,new/obj/Taiyoken,\
	new/obj/Heal,new/obj/Kaioken,new/obj/Bind,new/obj/Keep_Body,\
	new/obj/Materialization,new/obj/Shield,new/obj/Shunkan_Ido,new/obj/SplitForm,new/obj/Attacks/Kienzan,\
	new/obj/Unlock_Potential,new/obj/items/Magic_Food,new/obj/items/Magic_Food,new/obj/items/Magic_Food,\
	new/obj/Sense,new/obj/Advanced_Sense,new/obj/Meditate_Level_2,new/obj/Shadow_Spar)
	SSj3Able=Year;ssj3drain=300;Age=29;Real_Age=137+Year;BirthYear=-136;Decline+=15
	for(var/obj/Shunkan_Ido/I in src) I.Level=100
	Z_Character_Masteries()
mob/proc/Braal(mob/P)
	if(P) Log(P,"[P.key] gave [key] Braal Skills")
	contents.Add(new/obj/Attacks/Explosion,new/obj/Attacks/Final_Clash,new/obj/Attacks/Galic_Gun,\
	new/obj/Attacks/Ray,new/obj/Self_Destruct,new/obj/Shield,new/obj/Attacks/Spin_Blast,\
	new/obj/Attacks/Kienzan,new/obj/Sense,new/obj/Advanced_Sense)
	Age=43;Real_Age=143+Year;BirthYear=-141;Decline+=13
	Z_Character_Masteries()
mob/proc/Blowhan(mob/P)
	if(P) Log(P,"[P.key] gave [key] Blowhan Skills")
	contents.Add(new/obj/Attacks/Kakanakana,new/obj/Attacks/Masenko,new/obj/Attacks/Piercer,\
	new/obj/Heal,new/obj/Mystic,new/obj/Shield,new/obj/Taiyoken,new/obj/items/Magic_Food,\
	new/obj/Sense,new/obj/Advanced_Sense,new/obj/Meditate_Level_2)
	Age=18;Real_Age=118+Year;BirthYear=-117;Decline+=5
	Z_Character_Masteries()
mob/proc/Piccolo(mob/P)
	if(P) Log(P,"[P.key] gave [key] Piccolo Skills")
	contents.Add(new/obj/Attacks/Scatter_Shot,new/obj/Attacks/Makosen,new/obj/Attacks/Masenko,\
	new/obj/Attacks/Piercer,new/obj/Attacks/Ray,new/obj/Heal,\
	new/obj/Keep_Body,new/obj/Materialization,new/obj/Unlock_Potential,new/obj/Sense,new/obj/Advanced_Sense,\
	new/obj/Meditate_Level_2,new/obj/Shadow_Spar)
	Age=22;Real_Age=122+Year;BirthYear=-121;Decline+=10
	Z_Character_Masteries()
mob/proc/Trunks(mob/P)
	if(P) Log(P,"[P.key] gave [key] Trunks Skills")
	contents.Add(new/obj/Shield,new/obj/Sense,new/obj/Advanced_Sense)
	Age=18;Real_Age=108+Year;BirthYear=-108;Decline+=5
	Z_Character_Masteries()
mob/proc/Tien(mob/P)
	if(P) Log(P,"[P.key] gave [key] Tien Skills")
	contents.Add(new/obj/Attacks/Dodompa,new/obj/Attacks/Kikoho,new/obj/Taiyoken,\
	new/obj/Attacks/Explosion,new/obj/Bind,new/obj/Heal,\
	new/obj/Materialization,new/obj/Shield,new/obj/SplitForm,new/obj/Third_Eye,new/obj/Unlock_Potential,\
	new/obj/Attacks/Kakanakana,new/obj/Sense,new/obj/Advanced_Sense,new/obj/Meditate_Level_2,new/obj/Shadow_Spar)
	Age=40;Real_Age=141+Year;BirthYear=-141;Decline+=20
	Z_Character_Masteries()
mob/proc/Yamcha(mob/P)
	if(P) Log(P,"[P.key] gave [key] Yamcha Skills")
	contents.Add(new/obj/Attacks/Kakanakana,new/obj/Attacks/Dodompa,\
	new/obj/Heal,new/obj/Materialization,new/obj/Shield,new/obj/SplitForm,new/obj/Taiyoken,\
	new/obj/Unlock_Potential,new/obj/Sense,new/obj/Advanced_Sense,new/obj/Meditate_Level_2,new/obj/Shadow_Spar)
	Age=40;Real_Age=141+Year;BirthYear=-141;Decline+=20
	Z_Character_Masteries()
mob/proc/Krillin(mob/P)
	if(P) Log(P,"[P.key] gave [key] Krillin Skills")
	contents.Add(new/obj/Attacks/Kakanakana,new/obj/Attacks/Masenko,new/obj/Heal,\
	new/obj/Materialization,new/obj/Shield,new/obj/SplitForm,new/obj/Taiyoken,new/obj/Unlock_Potential,\
	new/obj/items/Magic_Food,new/obj/items/Magic_Food,new/obj/items/Magic_Food,new/obj/Attacks/Kienzan,new/obj/Sense,\
	new/obj/Advanced_Sense,new/obj/Meditate_Level_2,new/obj/Shadow_Spar)
	Age=37;Real_Age=138+Year;BirthYear=-138;Decline+=20
	Z_Character_Masteries()
mob/proc/Chaotsu(mob/P)
	if(P) Log(P,"[P.key] gave [key] Chaotsu Skills")
	contents.Add(new/obj/Attacks/Dodompa,new/obj/Attacks/Explosion,new/obj/Heal,\
	new/obj/Materialization,new/obj/Shield,new/obj/Self_Destruct,new/obj/Sense,new/obj/Advanced_Sense,\
	new/obj/Meditate_Level_2,new/obj/Shadow_Spar)
	Age=38;Real_Age=139+Year;BirthYear=-139;Decline+=25
	Z_Character_Masteries()
mob/proc/Freeza(mob/P)
	if(P) Log(P,"[P.key] gave [key] Freeza Skills")
	contents.Add(new/obj/Attacks/Death_Ball,new/obj/Attacks/Explosion,new/obj/Attacks/Ray,\
	new/obj/Attacks/Spin_Blast,new/obj/Planet_Destroy,new/obj/Shield,new/obj/Attacks/Kienzan)
	Age=100;Real_Age=200+Year;BirthYear=-200;Decline=110
	Z_Character_Masteries()
mob/proc/Cell(mob/P)
	if(P) Log(P,"[P.key] gave [key] Cell Skills")
	Age=10;Real_Age=110+Year;BirthYear=-110;Decline+=5;Max_Ki=8000*Eff
	contents.Add(new/obj/Attacks/Kakanakana,new/obj/Attacks/Piercer,new/obj/Attacks/Death_Ball,\
	new/obj/Attacks/Explosion,new/obj/Attacks/Galic_Gun,new/obj/Attacks/Scatter_Shot,\
	new/obj/Attacks/Spin_Blast,new/obj/Planet_Destroy,new/obj/Self_Destruct,\
	new/obj/Shunkan_Ido,new/obj/SplitForm,new/obj/Taiyoken,new/obj/Attacks/Kienzan,new/obj/Sense,\
	new/obj/Advanced_Sense,new/obj/Meditate_Level_2,new/obj/Shadow_Spar)
	Z_Character_Masteries()
mob/proc/Majin_Buu(mob/P)
	if(P) Log(P,"[P.key] gave [key] Majin Buu Skills")
	Age=5000;Real_Age=5000+Year;BirthYear=-5000;Decline=5025;Max_Ki=10000*Eff
	contents.Add(new/obj/Attacks/Kakanakana,new/obj/Attacks/Explosion,new/obj/Attacks/Scatter_Shot,\
	new/obj/Attacks/Ray,new/obj/Attacks/Spin_Blast,new/obj/Heal,new/obj/Materialization,\
	new/obj/Planet_Destroy,new/obj/Self_Destruct,new/obj/Shield,new/obj/SplitForm,new/obj/Taiyoken,\
	new/obj/Unlock_Potential,new/obj/Sense,new/obj/Advanced_Sense)
	Z_Character_Masteries()
mob/proc/Z_Character_Masteries()
	if(Race in list("Yasai")) SSjAble=Year;ssjdrain=300;SSj2Able=Year;ssj2drain=300
	contents.Add(new/obj/Fly,new/obj/Power_Control,new/obj/Zanzoken,new/obj/Give_Power,new/obj/Attacks/Blast,\
	new/obj/Attacks/Charge,new/obj/Attacks/Beam,new/obj/Telepathy,new/obj/Attacks/Sokidan)
	for(var/obj/Fly/F in src) F.Mastery=1000
	for(var/obj/O in src) if(O.Mastery<10000) O.Mastery=10000
	Remove_Duplicate_Moves()
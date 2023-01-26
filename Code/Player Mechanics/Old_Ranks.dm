mob/proc/Give_Rank_OLD(mob/A)
	set category="Admin"
	var/list/Planets=list("Cancel","Earth","Puranto","Braal","Arconia","Ice Planet","Heaven","Hell",\
	"Android Skill Master")
	var/list/Ranks=new
	switch(input(src,"Choose Planet Rank") in Planets)
		if("Cancel") return
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
		if("Puranto")
			Ranks.Add("Cancel","Elder","Teacher")
			switch(input(src,"What Rank?") in Ranks)
				if("Cancel") return
				if("Elder") A.Elder(src)
				if("Teacher") A.Puranto_Teacher(src)
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
				if("North Kaio") A.North_Kai(src)
				if("South/East/West Kaio") A.Cardinal_Kai(src)
				if("Kaio Helper") A.Kaio_Helper(src)
		if("Hell")
			Ranks.Add("Cancel","Daimao","Demon Master")
			switch(input(src,"What Rank?") in Ranks)
				if("Cancel") return
				if("Daimao") A.Daimaou(src)
				if("Demon Master") A.Demon_Master(src)
		if("Android Skill Master") A.Android_Skill_Master(src)
	for(var/obj/O in A) if(O.Mastery<100) O.Mastery=100
	//A.Remove_Duplicate_Moves()
	src<<"You will still have to add them to the Ranks window. This only gives them the skills."

var/Auto_Rank = 1

mob/Admin4/verb/Auto_Rank()
	set category="Admin"
	Auto_Rank=!Auto_Rank
	if(Auto_Rank) src<<"Auto ranking is now on, meaning that certain ranks will be given automatically if nobody \
	else online has it. They are only given to the appropriate races. This could be good for PVP servers."
	else src<<"Auto ranking is now off"

proc/Rank_taken(rank)
	for(var/mob/m in players) if(rank in m.Ranks) return 1

mob/var/list/Ranks=new

mob/proc/Rank_Check()
	if(!Auto_Rank||src.Ranks.len||world.time<5*600) return
	if(src.IsFusion()) return
	var/list/rank_tags=list("Elder","Daimao","Cardinal Kai","North Kai","Kaioshin","Yardrat","Puranto Teacher",\
	"Crane","Turtle","Korin","Popo","Guardian")
	for(var/V in rank_tags) if(!src.Ranks.len&&!Rank_taken(V)&&Race_can_have_rank(V))
		switch(alert(src,"Do you want the [V] rank? Nobody else online has it so you have been offered",\
		"options","Yes","No"))
			if("Yes")
				if(Rank_taken(V)) src<<"Someone accepted the rank before you"
				else
					switch(V)
						if("Daimao") Daimaou()
						if("Cardinal Kai") Cardinal_Kai()
						if("North Kai") North_Kai()
						if("Kaioshin") Kaioshin()
						if("Yardrat") Yardrat_Master()
						if("Puranto Teacher") Puranto_Teacher()
						if("Elder") Elder()
						if("Crane") Crane_Hermit()
						if("Turtle") Turtle_Hermit()
						if("Korin") Korin()
						if("Popo") Popo()
						if("Guardian") Guardian()
					Can_Remake=1
					for(var/obj/o in src) o.update_teach_timer() //prevents all skills from being immediately teachable
					for(var/obj/RankChat/RC in src) del(RC)

mob/proc/Race_can_have_rank(rank)
	switch(rank)
		if("Daimao") if(Race!="Demon") return
		if("Cardinal Kai") if(Race!="Kai") return
		if("North Kai") if(Race!="Kai") return
		if("Kaioshin") if(Race!="Kai") return
		if("Yardrat") if(Race!="Alien") return
		if("Puranto Teacher") if(Race!="Puranto") return
		if("Elder") if(Race!="Puranto") return
		if("Crane") if(Race!="Human") return
		if("Turtle") if(Race!="Human") return
		if("Korin") if(z!=1) return
		if("Popo") if(z!=1) return
		if("Guardian") if(z!=1) return
	return 1

proc/give_hbtc_key()
	var/obj/items/Door_Pass/D = new
	D.name="Time Chamber Key"
	D.icon='Key.dmi'
	D.Password=7125
	D.Cost=4000000*Mechanics.GetSettingValue("Resource Generation Rate")
	D.can_blueprint=0
	D.clonable=0
	D.Stealable=1
	D.layer=5
	D.desc="This special key can open the time chamber in Kami's Tower, which will supposedly let you \
	get a year's worth of training in just a single day"
	return D

var/guardian_hbtc_given
mob/proc
	Guardian(mob/P)
		if(P) Log(P,"[P.key] gave [key] Earth Guardian")
		Can_Remake=0
		Ranks+="Guardian"
		contents.Add(new/obj/Skills/Combat/Ki/Blast,new/obj/Skills/Combat/Ki/Charge,new/obj/Skills/Combat/Ki/Beam,new/obj/Skills/Utility/Fly,\
		new/obj/Skills/Utility/Power_Control,new/obj/Skills/Utility/Heal,new/obj/Skills/Divine/Materialization,new/obj/Skills/Combat/Ki/Shield,new/obj/Skills/Utility/Give_Power,\
		new/obj/Skills/Divine/Keep_Body,new/obj/Skills/Divine/Bind,new/obj/Skills/Utility/Sense,new/obj/Skills/Utility/Sense/Level2)
		contents.Add(new/obj/Skills/Utility/Telepathy,new/obj/Skills/Utility/Observe,new/obj/Skills/Divine/Reincarnation,new/obj/Skills/Utility/Meditate/Level2,\
		new/obj/Skills/Utility/Hide_Energy)
		if(Race=="Puranto") contents.Add(new/obj/Skills/Divine/Make_Dragon_Balls)
		contents+=new/obj/RankChat
		Attack_Gain(2000,apply_hbtc_gains=0,include_weights=0)
		if(base_bp<100) base_bp=100
		src<<"<font color=yellow>You were given the Earth Guardian rank"
		if(guardian_hbtc_given)
			src<<"You were not given a time chamber key because it has already been given out this reboot \
			to someone else who recieved this rank"
		else
			contents += give_hbtc_key()
			guardian_hbtc_given=1
	Popo(mob/P)
		if(P) Log(P,"[P.key] gave [key] Popo")
		Can_Remake=0
		Ranks+="Popo"
		contents.Add(new/obj/Skills/Utility/Fly,new/obj/Skills/Utility/Power_Control,new/obj/Skills/Utility/Heal,new/obj/Skills/Divine/Materialization,new/obj/Skills/Combat/Ki/Shield,\
		new/obj/Skills/Utility/Give_Power,new/obj/Skills/Divine/Bind,new/obj/Skills/Utility/Telepathy,new/obj/Skills/Utility/Observe,new/obj/Skills/Utility/Zanzoken,new/obj/Skills/Divine/Reincarnation,\
		new/obj/Skills/Utility/Sense,new/obj/Skills/Utility/Sense/Level2,new/obj/Skills/Utility/Meditate/Level2,\
		new/obj/Skills/Utility/Hide_Energy)
		contents+=new/obj/RankChat
		Attack_Gain(2000,apply_hbtc_gains=0,include_weights=0)
		if(base_bp<100) base_bp=100
		src<<"<font color=yellow>You were given the Popo rank"
	Korin(mob/P)
		if(P) Log(P,"[P.key] gave [key] Korin")
		Can_Remake=0
		Ranks+="Korin"
		contents.Add(new/obj/items/Senzu,new/obj/Skills/Utility/Fly,new/obj/Skills/Utility/Heal,new/obj/Skills/Utility/Give_Power,new/obj/Skills/Utility/Zanzoken,\
		new/obj/Skills/Utility/Power_Control,new/obj/Skills/Divine/Reincarnation,new/obj/Skills/Utility/Sense,new/obj/Skills/Utility/Sense/Level2)
		contents.Add(new/obj/Skills/Utility/Telepathy,new/obj/Skills/Utility/Observe,new/obj/Skills/Utility/Meditate/Level2,\
		new/obj/Skills/Utility/Hide_Energy)
		contents+=new/obj/RankChat
		Attack_Gain(2000,apply_hbtc_gains=0,include_weights=0)
		if(base_bp<100) base_bp=100
		src<<"<font color=yellow>You were given the Korin rank"
	Turtle_Hermit(mob/P)
		if(P) Log(P,"[P.key] gave [key] Turtle Hermit")
		Can_Remake=0
		Ranks+="Turtle"
		contents.Add(new/obj/Skills/Combat/Ki/Charge,new/obj/Skills/Combat/Ki/Beam,new/obj/Skills/Combat/Ki/Kamehameha,\
		new/obj/Skills/Utility/Zanzoken,new/obj/Skills/Utility/Fly,new/obj/Skills/Utility/Heal,new/obj/Skills/Utility/Give_Power,new/obj/Skills/Utility/Sense,\
		new/obj/Skills/Utility/Meditate/Level2)
		contents+=new/obj/RankChat
		Attack_Gain(2000,apply_hbtc_gains=0,include_weights=0)
		if(base_bp<50) base_bp=50
		src<<"<font color=yellow>You were given the Turtle Hermit rank"
	Crane_Hermit(mob/P)
		if(P) Log(P,"[P.key] gave [key] Crane Hermit")
		Can_Remake=0
		Ranks+="Crane"
		contents.Add(new/obj/Skills/Combat/Ki/Blast,new/obj/Skills/Combat/Ki/Beam,new/obj/Skills/Combat/Ki/Dodompa,new/obj/Skills/Combat/Ki/Taiyoken,\
		new/obj/Skills/Combat/SplitForm,new/obj/Skills/Combat/Ki/Self_Destruct,new/obj/Skills/Combat/Ki/Kikoho,new/obj/Skills/Utility/Fly,new/obj/Skills/Utility/Sense,\
		new/obj/Skills/Utility/Meditate/Level2)
		contents+=new/obj/RankChat
		Attack_Gain(2000,apply_hbtc_gains=0,include_weights=0)
		if(base_bp<50) base_bp=50
		src<<"<font color=yellow>You were given the Crane Hermit rank"
	Earth_Teacher(mob/P)
		if(P) Log(P,"[P.key] gave [key] Earth Teacher")
		Ranks+="Earth Teacher"
		contents.Add(new/obj/Skills/Combat/Ki/Blast,new/obj/Skills/Combat/Ki/Charge,new/obj/Skills/Combat/Ki/Beam,new/obj/Skills/Utility/Fly,\
		new/obj/Skills/Combat/Ki/Sokidan,new/obj/Skills/Utility/Heal,new/obj/Skills/Combat/Ki/Shield,new/obj/Skills/Combat/Ki/Kienzan,new/obj/Skills/Utility/Sense,\
		new/obj/Skills/Utility/Meditate/Level2,new/obj/Skills/Utility/Hide_Energy)
		Attack_Gain(1000,apply_hbtc_gains=0,include_weights=0)
		src<<"<font color=yellow>You were given the Earth Teacher rank"
	Elder(mob/P)
		if(P) Log(P,"[P.key] gave [key] Puranto Elder")
		Can_Remake=0
		Ranks+="Elder"
		contents.Add(new/obj/Skills/Combat/Ki/Charge,new/obj/Skills/Utility/Fly,new/obj/Skills/Utility/Heal,new/obj/Skills/Utility/Power_Control,\
		new/obj/Skills/Divine/Materialization,new/obj/Skills/Divine/Unlock_Potential,new/obj/Skills/Utility/Give_Power,new/obj/Skills/Combat/Ki/Shield,\
		new/obj/Skills/Utility/Meditate/Level2,new/obj/Puranto_Fusion,new/obj/Skills/Utility/Hide_Energy)
		if(Race=="Puranto") contents.Add(new/obj/Skills/Divine/Make_Dragon_Balls,new/obj/Skills/Divine/Reincarnation)
		contents.Add(new/obj/Skills/Utility/Telepathy,new/obj/Skills/Utility/Observe,new/obj/Skills/Utility/Sense,new/obj/Skills/Utility/Sense/Level2, new/obj/Skills/Combat/Ki/Masenko)
		contents+=new/obj/RankChat
		src<<"<font color=yellow>You were given the Puranto Elder rank"
	Puranto_Teacher(mob/P)
		if(P) Log(P,"[P.key] gave [key] Puranto Teacher")
		Ranks+="Puranto Teacher"
		contents.Add(new/obj/Skills/Combat/Ki/Blast,new/obj/Skills/Combat/Ki/Charge,new/obj/Skills/Combat/Ki/Beam,new/obj/Skills/Combat/Ki/Masenko,\
		new/obj/Skills/Combat/Ki/Piercer,new/obj/Skills/Combat/Ki/Sokidan,new/obj/Skills/Combat/Ki/Scatter_Shot,\
		new/obj/Skills/Utility/Fly,new/obj/Skills/Utility/Zanzoken,\
		new/obj/Skills/Utility/Power_Control,new/obj/Skills/Combat/SplitForm,new/obj/Skills/Utility/Heal,\
		new/obj/Skills/Divine/Materialization,new/obj/Skills/Combat/Ki/Shield,\
		new/obj/Skills/Utility/Give_Power,new/obj/Skills/Combat/Ki/Shockwave,new/obj/Skills/Utility/Sense,\
		new/obj/Skills/Utility/Sense/Level2,new/obj/Skills/Utility/Meditate/Level2,\
		new/obj/Skills/Utility/Telepathy,new/obj/Skills/Utility/Observe,new/obj/Puranto_Fusion)
		Attack_Gain(1000,apply_hbtc_gains=0,include_weights=0)
		src<<"<font color=yellow>You were given the Puranto Master rank"
	Elite_Alien(mob/P)
		if(P) Log(P,"[P.key] gave [key] Elite Alien")
		Ranks+="Elite Alien"
		contents.Add(new/obj/Skills/Combat/Ki/Charge,new/obj/Skills/Combat/Ki/Explosion,new/obj/Skills/Combat/Ki/Beam,\
		new/obj/Skills/Utility/Fly,new/obj/Skills/Combat/Ki/Shockwave)
		Attack_Gain(1000,apply_hbtc_gains=0,include_weights=0)

		var/bp_get=1000
		if(base_bp<bp_get)
			bp_get-=base_bp
			if(bp_get>0) static_bp+=bp_get

		src<<"<font color=yellow>You were given the Elite Alien rank"
	Yardrat_Master(mob/P)
		if(P) Log(P,"[P.key] gave [key] Yardrat Master")
		Can_Remake=0
		Ranks+="Yardrat"
		contents.Add(new/obj/Skills/Utility/Shunkan_Ido,new/obj/Skills/Utility/Fly,new/obj/Skills/Utility/Zanzoken,new/obj/Skills/Combat/Ki/Blast,\
		new/obj/Skills/Combat/Ki/Charge,new/obj/Skills/Combat/Ki/Sokidan,new/obj/Skills/Utility/Heal,new/obj/Skills/Combat/Ki/Shield)
		contents.Add(new/obj/Skills/Utility/Telepathy,new/obj/Skills/Utility/Observe,new/obj/Skills/Utility/Sense,\
		new/obj/Skills/Utility/Meditate/Level2)
		src<<"<font color=yellow>You were given the Yardrat Master rank"
	Alien_Skill_Master(mob/P)
		if(P) Log(P,"[P.key] gave [key] Alien Master")
		Ranks+="Alien Skill Master"
		contents.Add(new/obj/Skills/Combat/Ki/Blast,new/obj/Skills/Combat/Ki/Charge,new/obj/Skills/Combat/Ki/Beam,\
		new/obj/Skills/Combat/Ki/Explosion,new/obj/Skills/Combat/Ki/Sokidan,new/obj/Skills/Utility/Fly,\
		new/obj/Skills/Utility/Power_Control,new/obj/Skills/Combat/SplitForm,new/obj/Skills/Combat/Ki/Shockwave)
		Attack_Gain(1000,apply_hbtc_gains=0,include_weights=0)

		var/bp_get=500
		if(base_bp<bp_get)
			bp_get-=base_bp
			if(bp_get>0) static_bp+=bp_get

		src<<"<font color=yellow>You were given the Alien Master rank"
	Ice_Skill_Master(mob/P)
		if(P) Log(P,"[P.key] gave [key] Ice Master")
		Ranks+="Ice Skill Master"
		contents.Add(new/obj/Skills/Combat/Ki/Blast,new/obj/Skills/Combat/Ki/Charge,new/obj/Skills/Combat/Ki/Explosion,\
		new/obj/Skills/Combat/Ki/Beam,new/obj/Skills/Combat/Ki/Ray,new/obj/Skills/Combat/Ki/Sokidan,new/obj/Skills/Combat/Ki/Genki_Dama/Death_Ball,\
		new/obj/Skills/Utility/Fly,new/obj/Skills/Utility/Power_Control,new/obj/Skills/Combat/Ki/Shield,new/obj/Skills/Combat/Ki/Kienzan,\
		new/obj/Skills/Combat/Ki/Shockwave)
		src<<"<font color=yellow>You were given the Ice Master rank"
	Android_Skill_Master(mob/P)
		if(P) Log(P,"[P.key] gave [key] Android Master")
		Ranks+="Android Skill Master"
		contents.Add(new/obj/Skills/Combat/Ki/Blast,new/obj/Skills/Combat/Ki/Charge,\
		new/obj/Skills/Combat/Ki/Beam,new/obj/Skills/Combat/Ki/Ray,new/obj/Skills/Combat/Ki/Genki_Dama/Death_Ball,\
		new/obj/Skills/Utility/Fly,new/obj/Skills/Combat/Ki/Shield)
		src<<"<font color=yellow>You were given the Android Master rank"
	Kaioshin(mob/P)
		if(P) Log(P,"[P.key] gave [key] Kaioshin")
		Can_Remake=0
		Ranks+="Kaioshin"
		contents.Add(new/obj/Skills/Combat/Ki/Blast,new/obj/Skills/Combat/Ki/Charge,new/obj/Skills/Combat/Ki/Beam,\
		new/obj/Skills/Combat/Ki/Sokidan,new/obj/Skills/Combat/Ki/Scatter_Shot,new/obj/Skills/Utility/Heal,new/obj/Skills/Combat/Ki/Shield,\
		new/obj/Skills/Utility/Give_Power,new/obj/Skills/Utility/Fly,new/obj/Skills/Utility/Power_Control,new/obj/Skills/Divine/Materialization,\
		new/obj/Skills/Divine/Unlock_Potential,new/obj/Skills/Divine/Keep_Body,new/obj/Skills/Divine/Restore_Youth,new/obj/Skills/Divine/Kaio_Revive,\
		new/obj/Skills/Divine/Bind,new/obj/Skills/Divine/Make_Fruit,new/obj/Skills/Divine/Kai_Teleport,new/obj/Make_Holy_Pendant,new/obj/Skills/Utility/Meditate/Level2)
		contents.Add(new/obj/Skills/Utility/Telepathy,new/obj/Skills/Utility/Observe,new/obj/Skills/Divine/Reincarnation,new/obj/Skills/Utility/Sense,\
		new/obj/Skills/Utility/Sense/Level2)
		contents+=new/obj/RankChat
		contents += new/obj/Hakai
		contents += new/obj/items/Potara
		Attack_Gain(1000,apply_hbtc_gains=0,include_weights=0)

		var/bp_get=2000
		if(base_bp<bp_get)
			bp_get-=base_bp
			if(bp_get>0) static_bp+=bp_get

		src<<"<font color=yellow>You were given the Kaioshin rank"
	North_Kai(mob/P)
		if(P) Log(P,"[P.key] gave [key] North Kai")
		Can_Remake=0
		Ranks+="North Kai"
		contents.Add(new/obj/Skills/Combat/Ki/Charge,new/obj/Skills/Combat/Ki/Sokidan,new/obj/Skills/Utility/Fly,new/obj/Skills/Utility/Heal,new/obj/Skills/Utility/Give_Power,\
		new/obj/Skills/Utility/Power_Control,new/obj/Skills/Divine/Keep_Body,new/obj/Skills/Divine/Kaio_Revive,new/obj/Skills/Divine/Materialization,\
		new/obj/Skills/Divine/Bind,new/obj/Skills/God_Fist,new/obj/Skills/Combat/Ki/Genki_Dama,new/obj/Skills/Utility/Sense,new/obj/Skills/Utility/Sense/Level2)
		contents.Add(new/obj/Skills/Utility/Telepathy,new/obj/Skills/Utility/Observe,new/obj/Skills/Divine/Reincarnation,new/obj/Skills/Utility/Meditate/Level2)
		contents+=new/obj/RankChat
		Attack_Gain(1000,apply_hbtc_gains=0,include_weights=0)

		var/bp_get=1000
		if(base_bp<bp_get)
			bp_get-=base_bp
			if(bp_get>0) static_bp+=bp_get

		src<<"<font color=yellow>You were given the North Kai rank"
	Cardinal_Kai(mob/P)
		if(P) Log(P,"[P.key] gave [key] Cardinal Kai")
		Ranks+="Cardinal Kai"
		contents.Add(new/obj/Skills/Combat/Ki/Blast,new/obj/Skills/Combat/Ki/Charge,new/obj/Skills/Combat/Ki/Beam,new/obj/Skills/Combat/Ki/Sokidan,\
		new/obj/Skills/Utility/Fly,new/obj/Skills/Utility/Heal,new/obj/Skills/Combat/Ki/Shield,new/obj/Skills/Utility/Give_Power,new/obj/Skills/Utility/Power_Control,\
		new/obj/Skills/Divine/Materialization,new/obj/Skills/Divine/Keep_Body,new/obj/Skills/Divine/Kaio_Revive,new/obj/Skills/Divine/Bind)
		contents.Add(new/obj/Skills/Utility/Telepathy,new/obj/Skills/Utility/Observe,new/obj/Skills/Divine/Reincarnation,new/obj/Skills/Utility/Sense,new/obj/Skills/Utility/Sense/Level2,\
		new/obj/Skills/Utility/Meditate/Level2)
		contents+=new/obj/RankChat
		Attack_Gain(1000,apply_hbtc_gains=0,include_weights=0)

		var/bp_get=1000
		if(base_bp<bp_get)
			bp_get-=base_bp
			if(bp_get>0) static_bp+=bp_get

		src<<"<font color=yellow>You were given the Cardinal Kai rank"
	Kaio_Helper(mob/P)
		if(P) Log(P,"[P.key] gave [key] Kaio Helper")
		Ranks+="Kaio Helper"
		contents.Add(new/obj/Skills/Divine/Kaio_Revive,new/obj/Skills/Divine/Keep_Body,new/obj/Skills/Utility/Heal,new/obj/Skills/Divine/Bind,new/obj/Skills/Divine/Reincarnation)
		src<<"<font color=yellow>You were given the Kai Helper rank"

	Daimaou(mob/P)
		if(P) Log(P,"[P.key] gave [key] Daimao")
		Can_Remake=0
		Ranks+="Daimao"
		contents.Add(new/obj/Skills/Combat/Ki/Blast,new/obj/Skills/Combat/Ki/Charge,new/obj/Skills/Combat/Ki/Explosion,\
		new/obj/Skills/Combat/Ki/Beam,new/obj/Skills/Combat/Ki/Sokidan,new/obj/Skills/Combat/Ki/Piercer,\
		new/obj/Skills/Combat/Ki/Self_Destruct,new/obj/Skills/Utility/Fly,new/obj/Skills/Combat/Ki/Shield,\
		new/obj/Skills/Combat/SplitForm,new/obj/MakeAmulet,new/obj/Skills/Divine/Keep_Body,new/obj/Skills/Divine/Majin,\
		new/obj/Skills/Divine/Restore_Youth,new/obj/Skills/Divine/Materialization,new/obj/Skills/Divine/Bind,new/obj/Skills/Divine/Make_Fruit,new/obj/Skills/Divine/Demon_Contract,\
		new/obj/Skills/Divine/Kaio_Revive,new/obj/Skills/Combat/Ki/Kienzan,new/obj/Skills/Combat/Ki/Shockwave,new/obj/Make_Holy_Pendant,\
		new/obj/Skills/Utility/Telepathy,new/obj/Skills/Utility/Observe,new/obj/Skills/Divine/Reincarnation,\
		new/obj/Skills/Utility/Sense,new/obj/Skills/Utility/Sense/Level2,new/obj/Skills/Utility/Meditate/Level2)
		contents+=new/obj/RankChat
		contents += new/obj/Hakai
		Attack_Gain(1000,apply_hbtc_gains=0,include_weights=0)

		var/bp_get=2500
		if(base_bp<bp_get)
			bp_get-=base_bp
			if(bp_get>0) static_bp+=bp_get

		src<<"<font color=yellow>You were given the Daimao (Demon Lord) rank"

	Demon_Master(mob/P)
		if(P) Log(P,"[P.key] gave [key] Demon Master")
		Ranks+="Demon Master"
		contents.Add(new/obj/Skills/Combat/Ki/Blast,new/obj/Skills/Combat/Ki/Charge,new/obj/Skills/Combat/Ki/Explosion,\
		new/obj/Skills/Combat/Ki/Beam,new/obj/Skills/Combat/Ki/Sokidan,new/obj/Skills/Combat/Ki/Piercer,\
		new/obj/Skills/Combat/Ki/Self_Destruct,new/obj/Skills/Utility/Fly,new/obj/Skills/Combat/SplitForm,\
		new/obj/Skills/Divine/Keep_Body,new/obj/Skills/Divine/Materialization,new/obj/Skills/Divine/Majin,new/obj/Skills/Divine/Restore_Youth,\
		new/obj/Skills/Combat/Ki/Shockwave,new/obj/Skills/Divine/Reincarnation,new/obj/Skills/Utility/Sense,new/obj/Skills/Utility/Meditate/Level2)
		Attack_Gain(1000,apply_hbtc_gains=0,include_weights=0)

		var/bp_get=1000
		if(base_bp<bp_get)
			bp_get-=base_bp
			if(bp_get>0) static_bp+=bp_get

		src<<"<font color=yellow>You were given the Demon Master rank"
mob/var/Mob_ID=0
mob/proc/Disabled_Verb_Check()
	if(Train_Disabled) verbs-=/mob/verb/Train
	if(Learn_Disabled) verbs-=/mob/verb/Learn
mob/proc/Choose_Login() if(client)
	if(auto_train_in_save())
		sleep(100)
		src<<"<font color=yellow>AI training automaticly loaded your character"
		Load()
	else
		switch(alert(src,"Make your choice","","New","Load"))
			if("New")
				if(world.time<300)
					alert(src,"You can not make a new character until at least 30 seconds have passed since the \
					last reboot")
					Choose_Login()
					return
				if(Cant_Remake())
					alert(src,"You can not remake because you have accepted a rank that is not allowed to remake. \
					The only way to remake is to have an admin delete your save or edit your Can_Remake variable to 1.")
					Choose_Login()
					return
				if(Max_Players&&Players_with_z()>=Max_Players)
					alert(src,"The max amount of players is [Max_Players]. You can not log in until someone logs off")
					Choose_Login()
					return
				New_Character()



				src<<"<font size=1><font color=yellow>If the game's sounds bother you, turn them off by pressing \
				F1>client>preferences. Then uncheck download sounds."
				src<<"<font size=2><font color=yellow>You really should press P to bring up the guide website and \
				at least look what which buttons do what by viewing the 'preset macros' section"



			if("Load")
				if(Max_Players&&Players_with_z()>=Max_Players)
					alert(src,"The max amount of players is [Max_Players]. You can not log in until someone logs off")
					Choose_Login()
					return
				Load()
	Rank_Check()
	if(Frozen)
		src<<"<font color=yellow>You logged in paralyzed. You will stop being paralyzed in 1 minute."
		spawn(600) if(src) Frozen=0
	if(!(locate(/obj/Auras) in src)) contents+=new/obj/Auras
	if(!(locate(/obj/Crandal) in src)) contents+=new/obj/Crandal
	if(!(locate(/obj/Colorfy) in src)) contents+=new/obj/Colorfy
	Fill_Active_Freezes_List()
	Pixel_Movement()
	Disabled_Verb_Check()
	if(!name||name=="") name=key
	if(!Mob_ID) Mob_ID=rand(1,999999999999)
	//if(Race=="Demon"&&!(locate(/obj/Demon_Contract) in src)) contents+=new/obj/Demon_Contract
	if(key=="Omega Yasai X") if(!(locate(/obj/SSX_Planet) in src)) contents+=new/obj/SSX_Planet
	if(key=="Sonku") if(!(locate(/obj/Sonku_Planet) in src)) contents+=new/obj/Sonku_Planet
	Remove_Duplicate_Moves()
	RP_President()
	RP_President()
	Add_Voting()
	if(client)
		client.show_verb_panel=1
		client.show_map=1
		client.view="[ViewX]x[ViewY]"
	Fullscreen_Check()
	if(!(locate(/obj/Auto_Attack) in src)) contents+=new/obj/Auto_Attack
	Center_Icon(src)
	Rearrange_Mode_Check()
	for(var/obj/items/Scouter/S in src) if(S.suffix) Scouter=S
	Council_Check()
	Special_Key_Stuff()
	Get_Packs()
	Age_Update()
	Safezone()
mob/var/BP_Mod_Leechable=1
mob/proc/Special_Key_Stuff() if(key in list("Marquise10"))
	Intelligence*=5
	Regenerate+=3
	Lungs+=1
	Leech_Rate*=5
	Zenkai_Rate*=2
	SP_Mod*=10
	Mastery_Mod*=10
	BP_Mod*=2
	BP_Mod_Leechable=0
	Base_BP=Tech_BP
	Max_Ki=1000*Eff
	contents+=new/obj/Shunkan_Ido
	Attack_Gain(10000)
mob/proc
	New_Character(R) //R=Reincarnate=1
		Race()
		Racial_Stats()
		if(Race=="Alien") Alien_Stuff()
		Gender()
		Skin()
		Choose_Hair()
		Name()
		Choose_Age()
		Location(1) //First_Spawn=1
		if(Base_BP<Start_BP*BP_Mod) Base_BP=Start_BP*BP_Mod
		if(PowMod>=2||Pow>=200)
			contents+=new/obj/Meditate_Level_2
			if(Max_Ki/Eff<1000) Max_Ki*=2 //so reincarnaters dont keep doubling ki
		if(prob(Cured_Vampire_Ratio()*100))
			src<<"One of your parents was cured of the vampire virus and is now immune, you were born immune as a \
			result."
			Former_Vampire=1
		if(!R) spawn Player_Loops()
		LogYear=Year
		if(!R) Race_Starting_Stats()
		Ki=Max_Ki
		Tabs=1
		contents+=new/obj/Resources
		if(Race=="Yasai")
			if(!Tail) Tail_Add()
			contents+=new/obj/Werewolf
		Savable=1
		Already_Voted[key]=(world.realtime/10/60/60)+6
		src<<"<font size=2><font color=red>Check out the Customize button, it contains a lot of the things you are \
		probably looking for, like adjusting screen size and so on.<br>"
		if(client&&!client.preload_rsc) src<<"<font size=2><font color=yellow>If this is your first time playing, \
		the game will try to load new resources (icons, sound, etc) as you come across them, which can cause you \
		a bit of lag as they download, but they only have to download once."
		Mate_Check()
		Born_Vampire_Check()
	Choose_Age()
		var/N=0
		if(allow_age_choosing)
			N=input(src,"What age do you want to start as? This is mostly for people wanting to start past their \
			decline age, which has various penalties and advantages. Your decline age is [Decline]","Choose age",0) as num
		if(N<0) N=0
		if(N>1000) N=1000
		N=round(N,0.1)
		BirthYear=Year-N
		Age=N
		Real_Age=N
		spawn(600) if(src&&Age>Lifespan()) Die()
	Race_Starting_Stats()
		Max_Ki*=Eff
		Random_Colors()
	Random_Colors()
		var/Color=rgb(rand(0,255),rand(0,255),rand(0,255))
		if(0) //PLAYERS VOTED FOR NO STARTING ABILITIES BUT WANTED SP 3x AS FAST
			var/obj/Attacks/Blast/A=new
			var/obj/Attacks/Charge/B=new
			var/obj/Attacks/Beam/C=new
			A.icon=pick('1.dmi','12.dmi','17.dmi','18.dmi','19.dmi','21.dmi','22.dmi','24.dmi','25.dmi')
			B.icon=pick('11.dmi','20.dmi','26.dmi','27.dmi','31.dmi','4.dmi')
			C.icon=pick('Beam1.dmi','Beam2.dmi','Beam3.dmi','Beam6.dmi')
			A.icon+=Color
			B.icon+=Color
			C.icon+=Color
			contents.Add(A,B,C)
		if(BlastCharge) BlastCharge+=Color
		for(var/obj/Auras/D in src) D.icon+=Color
		contents+=new/obj/Fly
	Name() if(client)
		name=html_encode(copytext(input(src,"Name? (50 letter limit)"),1,50))
		if(!ckey(name)) Name()
		if(findtext(name,"\n"))
			Bans.Add(key,client.address)
			world<<"[key] ([client.address]) tried to use their name to spam. They were auto-banned."
			del(src)
	Check_Spawn(list/L)
		if(world.maxz<5) return
		for(var/A in L)
			var/Spawn
			for(var/obj/Spawn/S) if(S.name==A)
				Spawn=1
				break
			if(!Spawn) L-=A
	Race()
		var/list/Races=Race_List()
		for(var/V in Illegal_Races) if(V in Races) Races-=V

		if(!Is_Tens()&&!has_ultra_pack())
			var/icers=0
			for(var/mob/m in Players) if(m.Race=="Frost Lord") icers++
			icers/=Player_Count()
			if(icers>0.1) Races-="Frost Lord"

		if(world.maxz>5) Check_Spawn(Races) //Removes the entry from the list if there is no spawn for it

		for(var/mob/P) if(P.Class=="Legendary Yasai"||Yasai_Count()<10)
			Races-="Legendary Yasai"

		switch(input(src,"Choose a race. The most populated races are at the top.") in Races)
			if("Human") Human()
			if("Alien") Alien()
			if("Majin") Majin()
			if("Bio-Android") Bio()
			if("Android") Android()
			if("Lunatak") Lunatak()
			if("Deity") Deity()
			if("Spirit Doll") Doll()
			if("Tsujin") Tsujin()
			if("Puranto") Puranto()
			if("Yasai") Yasai()
			if("Half-Yasai") Half_Yasai()
			if("Frost Lord") Icer()
			if("Demon") Demon()
			if("Demigod") Demigod()
			if("Legendary Yasai") Legendary_Yasai()
mob/proc/Half_Yasai()
	Gravity_Mod=0.7
	SP_Mod=1
	Mastery_Mod=2
	Knowledge=500
	alert(src,"Half Yasai are a mix between Humans and Yasai, the warrior race.")
	form1x=2
	form2x=2
	form3x=1.7
	form4x=5.5
	BP_Mod=2.5
	Decline=20
	Decline_Rate=1
	Race="Yasai"
	Class="Half-Yasai"
	Intelligence=0.5
	Regenerate=0
	Lungs=0
	Leech_Rate=1
	Meditation_Rate=2
	Zenkai_Rate=0.5
	ssjat=rand(300000,600000)
	ssj2at=rand(50000000,100000000)
	ssj3at=rand(500000000,700000000)
	ssjmod*=2
	ssj2mod*=2
	ssj3mod*=0.5
	Base_BP=5
mob/proc/Human()
	Gravity_Mod=0.7
	SP_Mod=2
	Mastery_Mod=2
	BP_Mod=1
	Decline=20
	Decline_Rate=1
	Race="Human"
	Intelligence=1
	Regenerate=0
	Lungs=0
	Leech_Rate=3
	Meditation_Rate=2
	Zenkai_Rate=1
	Base_BP=1
mob/proc/Doll()
	alert(src,"Spirit Dolls are puppets who were given souls, their stats are based off Humans, with \
	a few changes. They are the only race that can fly forever without energy drain.")
	Human()
	Intelligence*=0.8
	Meditation_Rate*=2
	Decline=30
	Decline_Rate=2
	Class="Spirit Doll"
	if(!(locate(/obj/Fly) in src)) contents+=new/obj/Fly
mob/proc/Tsujin()
	alert(src,"Tsujins share the same planet as the Yasai, and are the same as Humans.")
	Human()
	Race="Tsujin"
	Gravity_Mastered=10
	Base_BP=5
	Knowledge=2000
	knowledge_cap_rate*=1.2
mob/proc/Majin()
	alert(src,"Majins are very hard to kill because they are made out of a gooey substance, and if even a small part \
	of them is left undestroyed, it will regenerate the entire being. They are extremely fast healers. Backstory: \
	The original Majin was created by an evil wizard hundreds of years ago to do his bidding, many heroes died at the \
	hands of the Majin. Many thought they had defeated the Majin, only to see it regenerate back to life, and \
	defeat them, and destroy all life on the planet. The original Majin was eventually defeated thanks to some of \
	Earth's greatest heroes. But unknown to them, the horror wasn't over. Microscopic particles of the Majin still \
	remained, and had scattered to many planets, altho badly damaged and mutated, they were regenerating. \
	However they could not bring back the original Majin, instead, after decades each colony of particles regenerated \
	into a fully seperate, weaker, and mutated version of the original. Altho weaker, they were still some of the \
	strongest creatures in existance, and evil too. They would wreak havoc far and wide, and would cause more \
	destruction in numbers than the original ever could.")
	Gravity_Mod=1
	SP_Mod=1
	Mastery_Mod=5
	Demonic=1
	BP_Mod=1.8
	Decline=20
	Decline_Rate=5
	Race="Majin"
	Intelligence=0.1
	Regenerate=2
	Lungs=1
	Leech_Rate=1
	Meditation_Rate=1
	Zenkai_Rate=1
	contents.Add(new/obj/Attacks/Death_Ball,new/obj/Attacks/Spin_Blast,new/obj/Attacks/Blast,new/obj/Attacks/Charge,\
	new/obj/Attacks/Beam,new/obj/Fly,new/obj/Absorb)
	Base_BP=5000
	Gravity_Mastered=20
mob/proc/Bio()
	alert(src,"Bio Androids are organic androids which are designed to be superior to normal organic life, whether \
	this is true is debatable. They can absorb mechanical androids to reach new forms which boost their power \
	immensely.")
	Gravity_Mod=1
	SP_Mod=1
	Mastery_Mod=2
	BP_Mod=1.8
	Decline=10
	Decline_Rate=5
	Race="Bio-Android"
	Intelligence=0.65
	Regenerate=1
	Lungs=1
	Leech_Rate=1
	Meditation_Rate=1
	Zenkai_Rate=1
	Gravity_Mastered=15
	contents.Add(new/obj/Attacks/Death_Ball,new/obj/Attacks/Blast,new/obj/Attacks/Charge,\
	new/obj/Attacks/Beam,new/obj/Fly,new/obj/Absorb)
	Base_BP=3000
	Knowledge=5000
mob/proc/Lunatak()
	Gravity_Mod=1.5
	SP_Mod=1.3
	Mastery_Mod=2.5
	alert(src,"Lunataks start on Earth, the most unique thing about them is that the Lunatak \
	star passes by, and gives them a big power boost and nearly unlimited energy.")
	BP_Mod=1.45
	Decline=30
	Decline_Rate=1
	Race="Lunatak"
	Intelligence=0.8
	Regenerate=0
	Lungs=0
	Leech_Rate=2
	Meditation_Rate=1
	Zenkai_Rate=0.5
	Gravity_Mastered=3
	contents.Add(new/obj/Attacks/Sokidan,new/obj/Fly,new/obj/Attacks/Charge)
	Base_BP=rand(5,50)
mob/proc/Puranto()
	Gravity_Mod=0.9
	SP_Mod=1.3
	Mastery_Mod=2
	alert(src,"Puranto are a peaceful race but they are also very strong warriors with unique magical powers that \
	no other race has.")
	BP_Mod=1.8
	Decline=80
	Decline_Rate=0.65
	Race="Puranto"
	Intelligence=0.8
	Lungs=0
	Gravity_Mastered=4
	Leech_Rate=2
	Meditation_Rate=4
	Zenkai_Rate=0.25
	Regenerate=0.25
	contents.Add(new/obj/SplitForm,new/obj/Meditate_Level_2,new/obj/Attacks/Blast,new/obj/Attacks/Charge,\
	new/obj/Attacks/Beam,new/obj/Fly,new/obj/Regeneration,new/obj/Zanzoken,new/obj/Power_Control,\
	new/obj/Attacks/Piercer)
	Base_BP=rand(300,500)
mob/proc/Yasai(Can_Elite=1)
	Gravity_Mod=1
	SP_Mod=1
	Mastery_Mod=1
	alert(src,"Yasai are a warrior race gifted with the potential for great power. \
	They have wolf tails and when the moon comes out, they turn into werewolf-like \
	creatures of great power. Also there is a legend of the Omega Yasai, a form that would turn a \
	normal Yasai into the most powerful being in the universe. Yasai have some \
	intelligence penalties and master skills slowly, but have the most powerful zenkai of any race.")
	form1x=2
	form2x=2
	form3x=1.7
	form4x=5.5
	BP_Mod=2
	Decline=30
	Decline_Rate=1
	Race="Yasai"
	Intelligence=0.3
	Regenerate=0
	Lungs=0
	Leech_Rate=1
	Meditation_Rate=1
	Zenkai_Rate=1.3
	ssjat=rand(800000,1200000)
	ssj2at=rand(80000000,160000000)
	ssj3at=rand(400000000,500000000)
	Gravity_Mastered=10
	Base_BP=rand(200,1000)
	if(prob(50))
		Base_BP=rand(1,10)
		ssjat*=0.9
	if(Can_Elite)
		var/Elites=0
		for(var/mob/P in Players) if(P.Race=="Yasai"&&P.Class=="Elite") Elites+=1
		if(Yasai_Count()>=5&&!Elites)
			switch(alert(src,"You can be an Elite Yasai. Do you want this? The penalty is that Omega Yasai will be more \
			difficult to get because of a much higher battle power requirement","Options","No","Yes"))
				if("Yes") Elite_Yasai()
proc/Avg_Yasai_BP(N=0) if(Player_Count())
	for(var/mob/P in Players) if(P.Race=="Yasai") N+=P.Base_BP
	return N/Yasai_Count()
mob/proc/Elite_Yasai() if(Class!="Elite")
	contents.Add(new/obj/Attacks/Charge,new/obj/Attacks/Explosion,new/obj/Attacks/Beam,\
	new/obj/Attacks/Galic_Gun,new/obj/Attacks/Final_Clash,new/obj/Fly,new/obj/Attacks/Kienzan,\
	new/obj/Attacks/Shockwave,new/obj/Attacks/Blast)
	Base_BP=Avg_Yasai_BP()
	if(Base_BP<4000) Base_BP=4000
	if(Max_Ki<300*Eff) Max_Ki=300*Eff
	ssjmod/=2
	ssjat*=2
	ssj2mod*=5
	Mastery_Mod*=2
	Gravity_Mod*=2
	Class="Elite"
mob/proc/Legendary_Yasai()
	Yasai()
	Gravity_Mod*=3
	Class="Legendary Yasai"
	Base_BP=rand(5000,10000)
	ssjadd=ssjadd+ssj2add
	SSjAble=15 //cant use the form til year 15
	form1x=5.5
	Decline-=20
	Decline_Rate=5
mob/proc/Icer()
	Gravity_Mod=3
	SP_Mod=1
	Mastery_Mod=3
	alert(src,"Frost Lords are a lizard-like race born on an icy planet furthest from all other races. They are \
	born with extreme power, and have the ability to shapeshift into new forms which increase their power even further.")
	BP_Mod=1.9
	Decline=50
	Decline_Rate=1
	Race="Frost Lord"
	Intelligence=0.3
	Regenerate=0
	Lungs=1
	Leech_Rate=1
	Meditation_Rate=1
	Zenkai_Rate=0.5
	Gravity_Mastered=15
	contents.Add(new/obj/Attacks/Death_Ball,new/obj/Attacks/Explosion,new/obj/Attacks/Ray,\
	new/obj/Power_Control,new/obj/Attacks/Blast,new/obj/Attacks/Charge,new/obj/Fly,new/obj/Attacks/Beam)
	Base_BP=rand(1000,2000)
mob/proc/Deity()
	Zombie_Immune=1
	Gravity_Mod=1
	SP_Mod=2
	alert(src,"Deities are guardians of the afterlife and living world. They are the natural enemy of Demons, they \
	may have come from a common ancestor, but Deities evolved in the positive energy of Heaven, and Demons in the \
	negative energy of hell.")
	Mastery_Mod=1.5
	BP_Mod=1.8
	Decline=100
	Decline_Rate=0.5
	Race="Deity"
	Intelligence=0.25
	Regenerate=0
	Lungs=0
	Leech_Rate=2
	Meditation_Rate=2
	Zenkai_Rate=0.25
	contents.Add(new/obj/Attacks/Sokidan,new/obj/Reincarnation,new/obj/Attacks/Charge,new/obj/Attacks/Beam,\
	new/obj/Fly,new/obj/Power_Control,new/obj/Observe,new/obj/Telepathy)
	Base_BP=rand(2000,4000)
mob/proc/Demigod()
	Gravity_Mod=1
	SP_Mod=1
	Mastery_Mod=0.5
	alert(src,"Demigods are a race with very high potential for power, but who take a very long time to reach \
	that potential. In other words, they have high BP gain, but leech BP very slow, and master skills slow.")
	BP_Mod=2.7
	Decline=30
	Decline_Rate=2
	Race="Demigod"
	Intelligence=0.8
	Regenerate=0
	Lungs=0
	Leech_Rate=0.5
	Meditation_Rate=1
	Zenkai_Rate=0.5
	Base_BP=rand(100,900)
	contents.Add(new/obj/Meditate_Level_2,new/obj/Heal,new/obj/Shadow_Spar,new/obj/Zanzoken)
mob/proc/Demon()
	alert(src,"Demons are born in hell and are the enemy of the Deities. Demons can live forever as long \
	as they periodicly visit hell, which will replenish their youth. High demon ranks are given the \
	Soul Contract ability, which can take the souls of other players and have much control over them.")
	Zombie_Immune=1
	Gravity_Mod=1.2
	SP_Mod=1
	Mastery_Mod=2
	Demonic=1
	BP_Mod=1.8
	Decline=30
	Decline_Rate=10 //It's 10 because they decline fast if they leave hell, hell keeps them young
	Race="Demon"
	Intelligence=0.25
	Regenerate=0
	Lungs=0
	Leech_Rate=1
	Meditation_Rate=2
	Zenkai_Rate=0.5
	contents.Add(new/obj/Attacks/Death_Ball,new/obj/Attacks/Charge,\
	new/obj/Attacks/Beam,new/obj/Fly,new/obj/Absorb)
	Base_BP=rand(1,10000)
mob/proc/Android()
	alert(src,"Androids are highly customizable. You can use science to create 'modules' which you can install on an \
	Android to alter its abilities and stats. You can choose Androids during creation, or make a blank Android body \
	at any time using Science in-game, and mind transfer into it. There is no difference except that choosing during \
	creation means you will spawn on the 'Android Ship'.")
	Gravity_Mod=1.5
	SP_Mod=1
	Mastery_Mod=3
	Android=1
	BP_Mod=1.7
	Decline=100
	Decline_Rate=10
	Race="Android"
	Intelligence=0.8
	Regenerate=0
	Lungs=1
	Gravity_Mastered=20
	Leech_Rate=0.5
	Meditation_Rate=4
	Zenkai_Rate=0.1
	Base_BP=100
	Knowledge=3000
	Zanzoken=100
mob/proc/Alien()
	alert(src,"Alien is any other unknown race in the universe. They are more customizable than other races")
	Gravity_Mod=1
	SP_Mod=1.3
	Mastery_Mod=2
	Knowledge=2000
	knowledge_cap_rate=1.5
	BP_Mod=1.4
	Decline=60
	Decline_Rate=0.5
	Race="Alien"
	Intelligence=0.1
	Regenerate=0
	Lungs=0
	Leech_Rate=1.2
	Meditation_Rate=1
	Zenkai_Rate=1
	Base_BP=rand(1,1000)
	contents.Add(new/obj/Fly,new/obj/Attacks/Charge,new/obj/Attacks/Beam)
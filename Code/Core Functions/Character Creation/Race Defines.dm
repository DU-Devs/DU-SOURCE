mob/race
	Yeet
		Race="Yeet"
		Gravity_Mod=1
		sp_mod=2
		mastery_mod=2
		bp_mod=1
		Decline=20
		Decline_Rate=1
		Intelligence=1
		knowledge_cap_rate=1
		Regenerate=1
		Lungs=1
		leech_rate=3
		med_mod=2
		zenkai_mod=1
		base_bp=1
		stun_resistance_mod=1.3
		New()
			ascension_bp*=1

	Human
		Race="Human"
		Gravity_Mod=1
		sp_mod=2
		mastery_mod=2
		bp_mod=1.1
		Decline=20
		Decline_Rate=1
		Intelligence=1
		knowledge_cap_rate=1
		Regenerate=0
		Lungs=0
		leech_rate=3
		med_mod=2
		zenkai_mod=1
		base_bp=1
		stun_resistance_mod=1.3
		New()
			ascension_bp*=1

		Doll
			desc = {"Spirit Dolls are puppets who were given souls, their stats are based off Humans, with 
			a few changes. They are the only race that can fly forever without energy drain."}
			incline_age=10
			incline_mod=0.3
			Decline=35
			Decline_Rate=2
			Class = "Spirit Doll"
			New()
				if(!(locate(/obj/Skills/Utility/Fly) in src)) contents+=new/obj/Skills/Utility/Fly
				Intelligence*=1
				bp_mod=0.99
				med_mod*=2
				mastery_mod*=thirdEyeMasteryMult //same as third eye human since they dont get third eye

		Tsujin
			desc = {"Tsujins share the same planet as the Yasai, and are very similar to Humans, but better with technology and a bit less at fighting."}
			Race="Tsujin"
			bp_mod=1.28
			gravity_mastered=10
			base_bp=10
			Knowledge=600
			stun_resistance_mod=1.2
			New()
				knowledge_cap_rate*=1.3

	Majin
		Race="Majin"
		incline_age=0.1
		incline_mod=0.3
		desc = {"Majins are very hard to kill because they are made out of a gooey substance and will regenerate unless 
		every bit of them is destroyed. They are extremely fast healers. 
		The original Majin Buu was created hundreds of years ago, and was eventually destroyed thanks to some of 
		Earth's greatest heroes. But unknown to them, microscopic particles of the Majin still 
		survived. The particles were badly damaged and mutated, but they were slowly regenerating. 
		The original Majin Buu could not be reformed, instead, decades later each colony of particles regenerated 
		into a seperate, weaker, and mutated version of the original. Although weaker, they were still some of the 
		strongest creatures in existance, and very evil. They would wreak havoc far and wide, and would cause more 
		destruction in numbers than the original ever did."}
		arm_stretch=1
		arm_stretch_icon='generic arm.dmi'
		arm_stretch_range=150
		Gravity_Mod=1
		sp_mod=3
		mastery_mod=5
		Demonic=1
		bp_mod=2.55
		Decline=20
		Decline_Rate=5
		Intelligence=0.1
		knowledge_cap_rate=1
		Regenerate=1.5
		Lungs=1
		leech_rate=3
		med_mod=1
		zenkai_mod=1
		base_bp=1500
		gravity_mastered=20
		New()
			contents.Add(new/obj/Skills/Combat/Ki/Genki_Dama/Death_Ball,new/obj/Skills/Combat/Ki/Blast,new/obj/Skills/Combat/Ki/Charge,\
						new/obj/Skills/Combat/Ki/Beam,new/obj/Skills/Utility/Fly,new/obj/Skills/Utility/Absorb,new/obj/Skills/Utility/Shadow_Spar)
			ascension_bp*=1

	Bio
		Race="Bio-Android"
		incline_age=3
		incline_mod=1
		desc = {"Bio Androids are organic androids which are designed to be superior to normal organic life, whether 
		this is true is debatable. They can absorb mechanical androids to reach new forms which boost their power 
		immensely."}
		Gravity_Mod=1
		sp_mod=1
		mastery_mod=2
		bp_mod=2.1
		Decline=20
		Decline_Rate=2
		Intelligence=0.9
		knowledge_cap_rate=1.3
		Regenerate=1.5
		Lungs=1
		leech_rate=1
		med_mod=1
		zenkai_mod=1.3
		gravity_mastered=25
		base_bp=500
		Knowledge=600
		New()
			contents.Add(new/obj/Skills/Combat/Ki/Genki_Dama/Death_Ball,new/obj/Skills/Combat/Ki/Blast,new/obj/Skills/Combat/Ki/Charge,\
						new/obj/Skills/Combat/Ki/Beam,new/obj/Skills/Utility/Fly,new/obj/Skills/Utility/Absorb)
			ascension_bp *= 1.3
			if(base_bp < highest_base_bp * bp_mod * 0.4) base_bp = highest_base_bp * bp_mod * 0.4
			static_bp=rand(1500,1900)

	OnionLad
		Race="Onion Lad"
		incline_age=8
		incline_mod=0.6
		Gravity_Mod=1.5
		sp_mod=1.3
		mastery_mod=2.5
		desc = {"Onion_Lads start on Earth, the most unique thing about them is that the Onion_Lad 
		star passes by, and gives them a big power boost and nearly unlimited energy."}
		bp_mod=1.65
		Decline=30
		Decline_Rate=1
		Intelligence=0.85
		knowledge_cap_rate=1
		Regenerate=0
		Lungs=0
		leech_rate=2
		med_mod=1
		zenkai_mod=0.5
		gravity_mastered=3
		New()
			contents.Add(new/obj/Skills/Combat/Ki/Sokidan,new/obj/Skills/Utility/Fly,new/obj/Skills/Combat/Ki/Charge)
			ascension_bp*=0.9
			base_bp=rand(120,150)

	Puranto
		Race="Puranto"
		incline_age=5
		incline_mod=0.25
		arm_stretch=1
		arm_stretch_range=500
		Gravity_Mod=0.7
		sp_mod=1.3
		mastery_mod=2
		desc = {"Purantos are a mostly peaceful race but also strong warriors with very unique racial 
		abilities such as making Wish Orbs, fusing with other Purantos, having another Puranto as their 
		'counterpart' for shared power, stretching their arms out really 
		far, and unique racial stats that can be seen in the Race Guide in the Other tab. Purantos are 
		probably one of the most unique races."}
		bp_mod=1.65
		Decline=80
		Decline_Rate=0.65
		Intelligence=0.85
		knowledge_cap_rate=1
		Lungs=0
		gravity_mastered=4
		leech_rate=2
		med_mod=3
		zenkai_mod=0.25
		Regenerate=0.3
		stun_resistance_mod=2
		New()
			contents.Add(new/obj/Skills/Combat/SplitForm,new/obj/Skills/Utility/Meditate/Level2,new/obj/Skills/Combat/Ki/Blast,new/obj/Skills/Combat/Ki/Charge,\
						new/obj/Skills/Combat/Ki/Beam,new/obj/Skills/Utility/Fly,new/obj/Skills/Utility/Regeneration,new/obj/Skills/Utility/Zanzoken,new/obj/Skills/Utility/Power_Control,\
						new/obj/Skills/Combat/Ki/Piercer)
			base_bp=rand(80,120)
			ascension_bp*=0.7

	HalfYasai
		Race="Half Yasai"
		incline_mod=0.3
		Gravity_Mod=0.7
		sp_mod=1
		mastery_mod=2
		Knowledge=300
		desc = {"Half Yasais are a mix between Humans and Yasais"}
		bp_mod=2.2
		Decline=20
		Decline_Rate=1
		Intelligence=0.8
		knowledge_cap_rate=1
		Regenerate=0
		Lungs=0
		leech_rate=1
		med_mod=2
		zenkai_mod=0.5
		ssjat = 850000 //remember halfies have 2.5 bp mod so that already makes it easier to get the requirement
		ssj2at = 120000000
		ssj3at = 800000000
		base_bp=5
		New()
			contents.Add(new/obj/Skills/Combat/Ki/Masenko)
			incline_age-=1
			ssjdrain /= 10
			ssjmod*=4
			ssj2mod*=2
			ssj3mod*=0.5

	var/elite_chance=8

	Yasai//(Can_Elite=1,force_elite,force_low_class)
		Race="Yasai"
		incline_age=15
		incline_mod=0.2
		Gravity_Mod=1
		sp_mod=1
		mastery_mod=1
		desc = {"Yasai are a warrior race gifted with the potential for great power. 
		They have tails and when the moon comes out, they turn into giant ape 
		creatures of great power. Also there is a legend of the Omega Yasai, a form that would turn a 
		normal Yasai into the most powerful being in the universe. Yasai have some 
		intelligence penalties and master skills slowly, but have the most powerful zenkai of any race."}
		bp_mod=2
		Decline=30
		Decline_Rate=1
		Intelligence=0.3
		knowledge_cap_rate=1
		Regenerate=0
		Lungs=0
		leech_rate=1
		med_mod=1
		zenkai_mod=1.5
		ssjat = 1000000
		ssj2at = 150000000
		ssj3at = 600000000
		gravity_mastered=10
		New(Can_Elite=1,force_elite,force_low_class)
			base_bp=rand(200,900)
			if(!force_elite && (prob(50) || force_low_class))
				base_bp=rand(5,20)
				static_bp=0
				ssjat*=0.9
				Class="Low Class"
			else if(force_elite) Elite_Yasai()
			else if(Can_Elite&&(world.time>3000||IsCodedAdmin()))
				var/elites=0
				for(var/mob/m in players) if(m.Race=="Yasai"&&m.Class=="Elite") elites++
				if((Yasai_Count()>=10&&elites/Yasai_Count()<elite_chance/100)||IsCodedAdmin())
					switch(alert(src,"Do you want to be an Elite Yasai? This choice only appears if less than [elite_chance]% \
					of the Yasais online are already elite. The penalty is that Omega Yasai will be harder to get \
					because the bp requirement is much higher. There are advantages, see the race guide for details.",
					"options","No","Yes"))
						if("Yes") Elite_Yasai()

		Elite_Yasai()
			contents.Add(new/obj/Skills/Combat/Ki/Charge,new/obj/Skills/Combat/Ki/Explosion,new/obj/Skills/Combat/Ki/Beam,\
			new/obj/Skills/Combat/Ki/Onion_Gun,new/obj/Skills/Combat/Ki/Final_Flash,new/obj/Skills/Utility/Fly,new/obj/Skills/Combat/Ki/Kienzan,\
			new/obj/Skills/Combat/Ki/Shockwave,new/obj/Skills/Combat/Ki/Blast)
			base_bp=Elite_starting_bp()
			if(base_bp<1000) base_bp=1000

			var/bp_get=rand(6300,7700)
			if(base_bp<bp_get)
				bp_get-=base_bp
				if(bp_get>0) static_bp+=bp_get

			if(max_ki<800*Eff) max_ki=800*Eff
			ssjmod/=2
			ssjat*=3
			ssj2mod*=5
			mastery_mod*=2
			Gravity_Mod*=2
			sp_mod*=1.2
			Class="Elite"
		Elite_starting_bp()
			if(!Player_Count()||!Yasai_Count()) return 1
			var/bp=0
			for(var/mob/m in players) if(m.Race=="Yasai") bp+=m.base_bp/m.bp_mod
			bp/=Yasai_Count()
			return bp*bp_mod

		Legendary_Yasai()
			Yasai(Can_Elite=0)
			Intelligence=0.1
			Gravity_Mod*=3
			Class="Legendary"

			lssj_ver=1

			var/bp_get=rand(8000,10000)
			if(base_bp<bp_get)
				bp_get-=base_bp
				if(bp_get>0) static_bp+=bp_get
			ssjadd = 10000
			ssjat = 5000000
			SSjAble = 1
			Decline -= 2
			Decline_Rate = 4

	Icer
		Race="Frost Lord"
		incline_age=10
		incline_mod=0.3
		Gravity_Mod=3
		sp_mod=1
		mastery_mod=3
		desc = {"Frost Lords are a lizard-like race born on an icy planet furthest from all other races. They are 
		born with extreme power, and have the ability to shapeshift into new forms which increase their power even further."}
		bp_mod=2.1
		Decline=50
		Decline_Rate=1
		Intelligence=0.5
		knowledge_cap_rate=2
		Regenerate=0
		Lungs=1
		leech_rate=1
		med_mod=1
		zenkai_mod=0.5
		gravity_mastered = 25
		base_bp=300
		stun_resistance_mod=0.9
		New()
			contents.Add(new/obj/Skills/Combat/Ki/Genki_Dama/Death_Ball,new/obj/Skills/Combat/Ki/Explosion,new/obj/Skills/Combat/Ki/Ray,\
						new/obj/Skills/Utility/Power_Control,new/obj/Skills/Combat/Ki/Blast,new/obj/Skills/Combat/Ki/Charge,new/obj/Skills/Utility/Fly,new/obj/Skills/Combat/Ki/Beam)
			ascension_bp*=1.35
			static_bp=rand(900,1200)

	Kai
		Race="Kai"
		incline_age=16
		incline_mod=0.15
		Gravity_Mod=1
		gravity_mastered=25
		sp_mod=2
		desc = {"Kais are guardians of the afterlife and living world. They are the natural enemy of Demons, they 
		may have come from a common ancestor, but Kais evolved in the positive energy of Heaven, and Demons in the 
		negative energy of hell."}
		mastery_mod=1.6
		bp_mod=1.8
		Decline=100
		Decline_Rate=0.5
		Intelligence=0.55
		Regenerate=0
		Lungs=0
		leech_rate=2
		med_mod=4
		zenkai_mod=0.25
		base_bp=2000
		New()
			contents.Add(new/obj/Skills/Combat/Ki/Sokidan,new/obj/Skills/Divine/Reincarnation,new/obj/Skills/Combat/Ki/Charge,new/obj/Skills/Combat/Ki/Beam,\
						new/obj/Skills/Utility/Fly,new/obj/Skills/Utility/Power_Control,new/obj/Skills/Utility/Observe,new/obj/Skills/Utility/Telepathy)
			ascension_bp*=1
			static_bp=rand(1300,1900)

	Demigod
		Race="Demigod"
		incline_age=13
		incline_mod=0.3
		Gravity_Mod=1
		sp_mod=1
		mastery_mod=1
		desc = {"Demigods are a race with very high potential for power, but who take a very long time to reach 
		that potential. In other words, they have high BP gain, but leech BP very slow, and master skills slow."}
		bp_mod=2.5
		Decline=30
		Decline_Rate=2
		Intelligence=0.8
		Regenerate=0
		Lungs=0
		leech_rate=1
		med_mod=1
		zenkai_mod=1
		base_bp=200
		New()
			contents.Add(new/obj/Skills/Utility/Meditate/Level2,new/obj/Skills/Utility/Heal,new/obj/Skills/Utility/Shadow_Spar,new/obj/Skills/Utility/Zanzoken)
			ascension_bp*=0.8
			static_bp=rand(700,900)

	Demon
		Race="Demon"
		incline_age=12
		incline_mod=0.4
		desc = {"Demons are born in hell and are the enemy of the Kais. Demons can live forever as long \
		as they periodicly visit hell, which will replenish their youth. High demon ranks are given the \
		Soul Contract ability, which can take the souls of other players and have much control over them."}
		Gravity_Mod=1.2
		sp_mod=1
		mastery_mod=2
		Demonic=1
		bp_mod=1.85
		Decline=30
		Decline_Rate=10 //It's 10 because they decline fast if they leave hell, hell keeps them young
		Intelligence=0.4
		Regenerate=0
		Lungs=0
		leech_rate=1
		med_mod=3
		zenkai_mod=0.5
		base_bp=2000
		stun_resistance_mod=1.2
		New()
			contents.Add(new/obj/Skills/Combat/Ki/Genki_Dama/Death_Ball,new/obj/Skills/Combat/Ki/Charge,\
						new/obj/Skills/Combat/Ki/Beam,new/obj/Skills/Utility/Fly,new/obj/Skills/Utility/Absorb)
			ascension_bp*=0.9
			static_bp=rand(0,300)

	Android
		Race="Android"
		incline_age=0.1
		incline_mod=0.3
		desc = {"Androids are highly customizable. You can use science to create 'modules' which you can install on an \
		Android to alter its abilities and stats. You can choose Androids during creation, or make a blank Android body \
		at any time using Science in-game, and mind transfer into it. There is no difference except that choosing during \
		creation means you will spawn on the 'Android Ship'."}
		Gravity_Mod=1.5
		sp_mod=1
		mastery_mod=5
		Android=1
		bp_mod=1
		Decline=100
		Decline_Rate=10
		Intelligence=1
		knowledge_cap_rate=0.8
		Regenerate=0
		Lungs=1
		gravity_mastered=20
		leech_rate=0.5
		med_mod=4
		zenkai_mod=0
		base_bp=100
		Knowledge=600
		Zanzoken=100
		stun_resistance_mod=0.9
		New()
			ascension_bp*=1.1

	Alien
		Race="Alien"
		incline_age=11
		incline_mod=0.2
		desc = {"Alien is any other unknown race in the universe. They are more customizable than other races"}
		Gravity_Mod=1
		sp_mod=1.3
		mastery_mod=2
		Knowledge=600
		knowledge_cap_rate=1.5
		bp_mod=1.55
		Decline=60
		Decline_Rate=0.5
		Intelligence=0.5
		Regenerate=0
		Lungs=0
		leech_rate=1.2
		med_mod=1
		zenkai_mod=1
		New()
			contents.Add(new/obj/Skills/Utility/Fly,new/obj/Skills/Combat/Ki/Charge,new/obj/Skills/Combat/Ki/Beam)
			ascension_bp*=1
			base_bp = rand(1800,2200)
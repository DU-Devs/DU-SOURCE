var/list/PlayerRaces = new

mob/var/tmp/playerCharacter //whether this mob is a loaded in player character

mob/proc/NewZenkaiMods()
	zenkai_mod = GetNewZenkaiMod()

mob/Admin5/verb/GetTotalRaces()
	for(var/i in PlayerRaces)
		var/val = PlayerRaces[i]
		usr << "[i]: [val]"

proc/SetPlayerRace(mob/M)
	if(!M.ckey) return
	PlayerRaces[M.ckey] = M.Race

proc/ClearPlayerRace(mob/M)
	if(!M.ckey) return
	PlayerRaces[M.ckey] = null
	PlayerRaces -= M.ckey

mob/proc/GetNewZenkaiMod()
	. = 0
	switch(Race)
		if("Half Yasai") return 0.5
		if("Yasai") return 1
		if("Bio-Android")
			if(HasTrait("Yasai Genome")) return 0.7
		if("Demon") return 0.5
		if("Alien") if(alien_zenkai) return 1

mob/proc/Get_race_starting_bp_mod()
	if(Class == "Spirit Doll") return 1.4
	switch(Race)
		if("Yeet") return 1
		if("Half Yasai") return 2.5
		if("Yasai") return 2
		if("Human") return 1.2
		if("Tsujin") return 1.3
		if("Majin") return 2.55
		if("Bio-Android") return 2.1
		if("Onion Lad") return 1.65
		if("Frost Lord") return 2.1
		if("Kai") return 1.8
		if("Demigod") return 2.6
		if("Demon") return 1.85
		if("Android") return 1
		if("Alien") return 1.55
	return 1.5

mob/var/Mob_ID=0

mob/proc/code_banned()
	if(key == "TyeGamer" || key == "Tyesonthegamer")
		ban_alert("Snakes in the grass get stomped")
		return 1
	return 0

mob/proc/ban_alert(msg)
	src<<msg

mob/proc/Carry_over_imprisonments()
	if(!fexists("Save/[ckey]")) return
	var/savefile/F=new("Save/[ckey]")
	F["Imprisonments"]>>Imprisonments

mob/var/character_made_time = 0

mob/proc/ClickMakeNewCharacter()
	if(playerCharacter) return //this person is already loaded into a character somehow. prevents the race stacking bug

	if(world.time<50 && can_login)
		alert(src,"You can not make a new character until at least 5 seconds have passed since the \
		last reboot")
		return

	if(Limits.GetSettingValue("Maximum Players") && Players_with_z() >= Limits.GetSettingValue("Maximum Players"))
		alert(src,"The max amount of players is [Limits.GetSettingValue("Maximum Players")]. You can not log in until someone logs off")
		return

	var/t=Spam_relogger()
	if(t)
		t=round((t-world.time)/10)
		alert(src,"You are relogging too much, this lags everyone else greatly. You must wait \
		[t] seconds before you can load your character again")
		return

	New_Character()
	stat_version=cur_stat_ver

	LoadFeats()

	spawn(30) if(src)
		src<<"<font size=4><font color=red><-- Drag this bar to resize the map"
		src<<"<font size=3><font color=cyan>Press F5 to see what the buttons do. Press Escape to view Settings."

	character_made_time = world.realtime
	if(Race == "Android" || Race == "Majin")
		max_ki = Progression.GetSettingValue("Energy Cap") * Eff
		Ki = max_ki

mob/proc
	CodebanLoginCheck()
		set waitfor=0
		if(code_banned())
			sleep(10)
			del(src)

	UnsortedClientLoginStuff()
		set waitfor=0
		Carry_over_imprisonments()

	StuffThatRunsIfYouClickNewOrLoad()
		set waitfor=0
		if(!client) return
		last_logon = world.time
		playerCharacter = 1
		winset(src, "mainwindow.mainvsplit", "right=rpane")
		src << sound(0)
		spawn(200) Great_Ape_revert()
		if(Race=="Puranto") verbs+=typesof(/mob/Puranto/verb)
		Check_if_counterpart_is_alive_or_dead()
		if(Frozen)
			src<<"<font color=yellow>You logged in paralyzed. You will stop being paralyzed in 30 seconds."
			spawn(300) if(src) Frozen=0
		if(!(locate(/obj/Auras) in src))
			contents+=new/obj/Auras
		if(!(locate(/obj/Crandal) in src)) contents+=new/obj/Crandal
		if(!(locate(/obj/Colorfy) in src)) contents+=new/obj/Colorfy
		Fill_Active_Freezes_List()
		if(!name||name=="") name=key
		if(!Mob_ID) Mob_ID=get_mob_id()

		Remove_Duplicate_Moves()
		RP_President()
		AddPartyVerbs()
		if(!(locate(/obj/Auto_Attack) in src)) contents+=new/obj/Auto_Attack
		Council_Check()
		Age_Update()
		Safezone()
		check_duplicate_dragon_balls()
		logged_in_on_destroyed_planet_check()
		Update_tab_button_text()

		//fix halfies having 0 base bp and bp mod
		base_bp = Math.Max(base_bp, 1)
		bp_mod = Math.Max(bp_mod, Get_race_starting_bp_mod())

		if(Race=="Majin") Undo_all_t_injections()
		Calm() //because if they relog angry they can stay perma anger instead of just a short burst
		Delete_excess_buffs()
		if(last_anger>world.time) last_anger=0

		spawn(50) Rank_Check()

		Add_hotbar_proxies()
		if(Race == "Majin")
			if(!HasSkill(/obj/Skills/Utility/Imitation)) contents+=new/obj/Skills/Utility/Imitation

		majin_stat_version=999
		UpdateFeatMultipliers()
		DuplicateModulesBugFix()

		Check_Senses()

		UpdateSenseArrow()

		if(client) client.fps = client_fps
		BioAndroidLogon()

		glide_size = 0
		ResetResourcesCheck()
		NewZenkaiMods()
		ApplyStartingBP()
		FixCantMoveDueToKiAttack()

		FindEquippedWeapons()
		FindEquippedArmors()

		CheckStatVersion()
		CheckTraitVersion()
		PopulateTraitsList()

		AssignProfile()

		if(Race == "Majin")
			if(!(locate(/obj/Goo_Trap) in src))
				contents += new/obj/Goo_Trap

		UltraInstinctRevert()

		if(!(locate(/obj/Resources) in src))
			contents += GetCachedObject(/obj/Resources)
			src << "Resource Bag was missing. New resource bag given to [src]"

		src << {"
<span style="font-size: 18pt;color: [rgb(255,140,0)]">Game Version: [Version]</span>
<a href="https://discord.gg/tptNddapjC" style="font-size: 18pt;">Join our Discord</a>
<a href="https://github.com/DU-Devs/Dragon-Universe-Public/wiki" style="font-size: 18pt;">Check out the Wiki</a>
<a href="https://www.patreon.com/dragonuniverse" style="font-size: 18pt;">Support us on Patreon</a>
<a href="https://github.com/DU-Devs/Dragon-Universe-Public/releases" style="font-size: 18pt;">Update logs posted here</a>
"}

		SetPlayerRace(src)

		load_player_settings()
		LoadCharacterHotkeyThing()

		if(cyber_bp < 0) cyber_bp = 0 //there was a bug to give someone -infinity cyber bp

		empty_player = 0
		Update_soul_contracts()
		client.PopulateBuildTabs()
		Admin_Check()


mob/proc/View_update_logs()
	src << browse(New_Stuff, "window=Updates,size=800x600")

mob/var/tmp/tabs_hidden
mob/verb/Toggle_tabs()
	set name=".Toggle_tabs"
	if(usr?.client?.buildMode) return
	if(winget(src,"rpane.rpanewindow","left")=="infowindow")
		winset(src,"rpane.rpanewindow","left=;")
		tabs_hidden=1
	else
		winset(src,"rpane.rpanewindow","left=infowindow")
		tabs_hidden=0
	Update_tab_button_text()

mob/proc/Update_tab_button_text(button_visible=1)
	if(!client) return
	if(button_visible) winset(src,"tabbutton","is-visible=true")
	else winset(src,"tabbutton","is-visible=false")
	var/t="Show tabs"
	if(winget(src,"rpane.rpanewindow","left")=="infowindow") t="Hide tabs"
	winset(src,"tabbutton","text='[t]'")

mob/verb/Check_Base_BP()
	set category = "Other"
	usr << "Base BP: [Commas(usr.base_bp + (Race == "Android" ? cyber_bp : 0))]"
	usr << "Current BP: [Commas(usr.get_bp())]"
	usr << "Base Power Tier: [GetBPTier()]"
	usr << "BP till next Tier: [Commas(GetTierReq(GetBPTier() + 1) - (base_bp + static_bp + (Race == "Android" ? cyber_bp : 0)))]"

	var/cap = 0
	if(Progression.GetSettingValue("Daily Tier Cap") && Progression.GetSettingValue("Maximum Tier"))
		cap = Math.Min(Progression.GetSettingValue("Maximum Tier"), GetPowerTierCap())
	else if(Progression.GetSettingValue("Daily Tier Cap") && !(Progression.GetSettingValue("Maximum Tier")))
		cap = GetPowerTierCap()
	else if(!(Progression.GetSettingValue("Daily Tier Cap")) && Progression.GetSettingValue("Maximum Tier"))
		cap = Progression.GetSettingValue("Maximum Tier")
	if(cap) usr << "Base Power Tier Cap: [cap]"
	if(Progression.GetSettingValue("Tier Soft Cap"))
		usr << "Base Power Tier Soft Cap: [Progression.GetSettingValue("Tier Soft Cap")]"

proc/get_mob_id() return rand(1,999999999)
mob/var/bp_mod_Leechable=1

var/next_lssj=0

mob/proc/ApplyStartingBP()
	base_bp = Math.Max(base_bp, Progression.GetSettingValue("Minimum Starting BP"))
mob/proc
	EditInfo()
		upForm(src.client, src, /upForm/creation)
mob/proc/New_Character(reincarnating,force_race,force_elite,dbz_hair,force_low_class)
	if(force_elite) force_low_class = 0 //cant be both
	
	if(!src.client) del src
	sleep(1)
	Race(force_elite=force_elite,force_low_class=force_low_class)

	bp_loss_from_low_ki=Get_bp_loss_from_low_ki()
	bp_loss_from_low_hp=Get_bp_loss_from_low_hp()
	if(Race!="Yeet")
		Racial_Stats()

	PopulateTraitsList()

	if(Race!="Yeet")

		EditInfo()
		while(src?.client?.upForm_isViewingForm(/upForm/creation/))
			sleep(5)
		Skin()

		sleep(5)
		ChooseRaceTraits()

	UpdateBPTier(0)
	GainTraitPoints()
	GainSkillPoints()
	FrostLordTransAdding()
	traitVersion = currentTraitVersion

	RandomHair()

	//if(!dbz_character)
	/// tab the below over and uncomment above to re-enable this check
	if(!reincarnating) Race_Starting_Stats()
	Go_to_spawn(First_time=1)
	if(Pow >= 12)
		contents+=new/obj/Skills/Utility/Meditate/Level2
		max_ki = Math.Min(max_ki * 2, 5000 * Eff)
	if(prob(Cured_Vampire_Ratio()*100))
		src<<"One of your parents was cured of the vampire virus and is now immune, you were born immune as a \
		result."
		Former_Vampire=1
	src.BPResetAtTime = world.realtime
	PrimaryPlayerLoop(Time.FromSeconds(10))

	LogYear=GetGlobalYear()
	Ki=max_ki
	contents += GetCachedObject(/obj/Resources)
	if(Race in list("Yasai","Half Yasai"))
		if(!Tail) Tail_Add()
		contents+=new/obj/Great_Ape
	Savable=1
	Already_Voted[key]=(world.realtime/10/60/60)+6
	if(client&&!client.preload_rsc) src<<"<font size=2><font color=yellow>If this is your first time playing, \
	the game will try to load new resources (icons, sound, etc) as you come across them, which can cause you \
	a bit of lag as they download, but they only have to download once."
	src << "<font color=cyan><font size=2>Spacebar is punch, and Y toggles auto-punch, but you can only punch when there is a target in front of you, for now"
	Mate_Check()
	Born_Vampire_Check()
	if(base_bp<1) base_bp=1
	spawn(20) Tabs = 1 								//i didnt want the tabs to try to load in at the exact same time
	spawn(40) if(client) client.show_verb_panel = 1	//the map is trying to load in. it crashes people maybe. too much data at once

mob/proc/Choose_Age()
	var/N=0
	N=input(src,"What age do you want to start as? This is mostly for people wanting to start past their \
	decline age, which has various penalties and advantages. Your decline age is [Decline]","Choose age",0) as num
	if(N<0) N=0
	if(N>1000) N=1000
	N=round(N,0.1)
	BirthYear=GetGlobalYear()-N
	Age=N
	real_age=N
	spawn(600) if(src&&Age>Lifespan()) DieFromOldAge()

mob/proc/Race_Starting_Stats()
	max_ki*=Eff**0.5
	spawn(20) Random_Colors()

var/Base64Chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-_"
proc/GetBase64ID(encode_length = 6)
	encode_length = Math.Clamp(encode_length, 1, 16)
	encode_length = Math.Round(encode_length, 1)
	. = ""
	for(var/i in 1 to encode_length)
		var/r = Math.Rand(1, length(Base64Chars))
		. += copytext(Base64Chars, r, r+1)
		sleep(world.tick_lag * 2)

mob/proc/Random_Colors()
	var/Color=rgb(rand(0,255),rand(0,255),rand(0,255))
	if(BlastCharge) BlastCharge+=Color
	for(var/obj/Auras/D in src) D.icon+=Color

var/list/Illegal_Races = list()
var/list/PersonalRaces = list()
mob/Admin3/verb/Manage_Playable_Races()
	set category = "Admin"
	Illegal_Races ||= list()
	PersonalRaces ||= list()

	while(1)
		switch(input("On what scale do you want to manage playable races?", "Manage Scale") in list("Cancel", "Global", "Individual"/* , "Group" */))
			if("Global")
				while(1)
					switch(input(src,"Would you like to make the race playable or unplayable?") in list("Cancel","Playable","Unplayable"))
						if("Unplayable")
							while(1)
								var/list/L=list("Cancel")
								for(var/V in GetRacesAsList()) if(!(V in Illegal_Races)) L+=V
								var/N=input(src,"Which race do you want to make illegal?") in L
								if(!N || N == "Cancel") break
								Illegal_Races+=N
								world<<"[N] has been made an illegal race by admins"
						if("Playable")
							while(1)
								var/N=input(src,"Which race to make legal again?") in list("Cancel") + Illegal_Races
								if(N=="Cancel") break
								Illegal_Races-=N
								world<<"[N] has been made a legal race again by admins."
						else break
					sleep(2)
			if("Individual")
				while(1)
					var/mob/M = input("Which player?", "Pick Player") in list("Cancel") + players
					if(M == "Cancel") break
					while(1)
						switch(input("Do what?", "Manage Player Races") in list("Cancel", "Unlock", "Lock"))
							if("Unlock")
								UnlockRaceForPlayer(M)
							if("Lock")
								LockRaceForPlayer(M)
							else break
						sleep(2)
					sleep(2)
			else break
		sleep(2)

proc/UnlockRaceForPlayer(mob/M)
	if(!M.client || !M.playerCharacter)
		return
	if(!(M.key in PersonalRaces))
		PersonalRaces[M.key] = new/list
	while(1)
		var/list/races = PersonalRaces[M.key]
		var/list/allRaces = GetRacesAsList()
		var/T = input("What skill?") in list("Cancel") + allRaces - races
		if(!T || T == "Cancel") break
		PersonalRaces[M.key] += T
		sleep(2)

proc/LockRaceForPlayer(mob/M)
	if(!M.client || !M.playerCharacter || !(M.key in PersonalRaces))
		return
	while(1)
		var/list/races = PersonalRaces[M.key]
		var/T = input("What race?") in list("Cancel") + races
		if(!T || T == "Cancel") break
		PersonalRaces[M.key] -= T
		sleep(2)

mob/proc/Name()
	if(!client) return
	name = input(src, "Name? (50 letter limit)") as text
	name = copytext(name, 1, 50)
	name = html_encode(name)
	if(InvalidPlayerName(name))
		name = "No Name"
		Name()

mob/proc/Check_Spawn(list/Races)
	for(var/R in Races)
		var/canSpawn = 0
		for(var/obj/Spawn/S in RaceSpawns)
			if(S.name == R && !S.is_on_destroyed_planet()) canSpawn = 1
		for(var/mob/M in players)
			if(!M.z) continue
			for(var/obj/Mate/mate in M)
				if(mate.Waiting && mate.Race == R)
					canSpawn = 1
					break
		if(!canSpawn) Races -= R
	return Races

mob/proc/HasSomeoneAscended()
	for(var/mob/M in players)
		if(M && M.bpTier >= 15) return 1

var/tmp/globalLSCount = 0
var/tmp/globalFLCount = 0

mob/proc/Race(force_elite,force_low_class)
	var/list/Races=GetRacesAsList()
	if(!IsCodedAdmin())
		for(var/V in Illegal_Races - PersonalRaces)
			if(V in PersonalRaces) continue
			if(V in Races)
				Races-=V

	Races = Check_Spawn(Races) //Removes the entry from the list if there is no spawn for it
	
	if(!IsCodedAdmin() && Limits.GetSettingValue("Maximum Legendary Yasai"))
		var/lsCount = 0
		for(var/mob/m in players)
			if(m.Class=="Legendary")
				lsCount ++
		globalLSCount = Math.Max(lsCount, globalLSCount)
		if(globalLSCount >= Limits.GetSettingValue("Maximum Legendary Yasai"))
			Races-="Legendary Yasai"

	if(!IsCodedAdmin() && Limits.GetSettingValue("Maximum Frost Lords"))
		var/flCount = 0
		for(var/mob/m in players)
			if(m.Race=="Frost Lord")
				flCount ++
		globalFLCount = Math.Max(flCount, globalFLCount)
		if(globalFLCount >= Limits.GetSettingValue("Maximum Frost Lords"))
			Races-="Frost Lord"

	if(IsCodedAdmin()) Races+= "Yeet"

	for(var/mob/m in players)
		SetPlayerRace(m)

	var/yasaiCount = 0
	for(var/i in PlayerRaces)
		var/val = PlayerRaces[i]
		if(val == "Yasai")
			yasaiCount++

	if(!IsCodedAdmin())
		if(yasaiCount) //so it cant be 0
			if(Limits.GetSettingValue("Maximum Yasai") && yasaiCount>Limits.GetSettingValue("Maximum Yasai"))
				Races-="Yasai"
				Races-="Legendary Yasai"
				alert(src,"The number of players playing Yasai has exceeded the cap set by admins. Yasai \
				has been removed from the race selection. The max number of Yasai allowed is [Limits.GetSettingValue("Maximum Yasai")].")

	var/playerRace = input(src,"Choose a race.") in Races

	switch(playerRace)
		if("Yeet") Yeet()
		if("Human") Human()
		if("Alien") Alien()
		if("Majin") Majin()
		if("Bio-Android") Bio()
		if("Android") Android()
		if("Onion Lad") Onion_Lad()
		if("Kai") Kai()
		if("Spirit Doll") Doll()
		if("Tsujin") Tsujin()
		if("Puranto") Puranto()
		if("Yasai") Yasai(force_elite=force_elite,force_low_class=force_low_class)
		if("Half Yasai") Half_Yasai()
		if("Frost Lord")
			Icer()
			globalFLCount++
		if("Demon") Demon()
		if("Demigod") Demigod()
		if("Legendary Yasai")
			Legendary_Yasai()
			globalLSCount++
		else Human()
	ascension_bp *= bp_mod

//remove everything below this point once race datum is completed and working.

mob/proc/Yeet()
	Race="Yeet"
	Gravity_Mod=1
	sp_mod=2
	mastery_mod=2
	bp_mod=Get_race_starting_bp_mod()
	Decline=40
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

mob/proc/Human()
	Race="Human"
	Gravity_Mod=1
	sp_mod=2
	mastery_mod=2
	bp_mod=Get_race_starting_bp_mod()
	Decline=40
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

mob/proc/Doll()
	alert(src,"Spirit Dolls are puppets who were given souls, their stats are based off Humans, with \
	a few changes. They are the only race that can fly forever without energy drain.")
	Human()
	incline_age=10
	incline_mod=0.3
	Intelligence*=1
	med_mod*=2
	mastery_mod*=2 //same as third eye human since they dont get third eye
	Decline=80
	Decline_Rate=2
	Class = "Spirit Doll"
	originalClass = Class
	if(!(locate(/obj/Skills/Utility/Fly) in src)) contents+=new/obj/Skills/Utility/Fly

mob/proc/Tsujin()
	alert(src,"Tsujins share the same planet as the Yasai, and are very similar to Humans, but better with \
	technology and a bit less at fighting.")
	Human()
	Race="Tsujin"
	bp_mod=Get_race_starting_bp_mod()
	gravity_mastered=10
	base_bp=10
	Knowledge=600
	knowledge_cap_rate*=1.3
	stun_resistance_mod=1.2

mob/proc/Majin()
	Race="Majin"
	incline_age=0.1
	incline_mod=0.3
	alert(src,"Majins are very hard to kill because they are made out of a gooey substance and will regenerate unless \
	every bit of them is destroyed. They are extremely fast healers.")
	arm_stretch=1
	arm_stretch_icon='generic arm.dmi'
	arm_stretch_range=150
	Gravity_Mod=1
	sp_mod=3
	mastery_mod=5
	Demonic=1
	bp_mod=Get_race_starting_bp_mod()
	Decline=100
	Decline_Rate=5
	Intelligence=0.15
	knowledge_cap_rate=1
	Regenerate=1.5
	Lungs=1
	leech_rate=1.5
	med_mod=1
	contents.Add(new/obj/Skills/Combat/Ki/Genki_Dama/Death_Ball,new/obj/Skills/Combat/Ki/Blast,new/obj/Skills/Combat/Ki/Charge,\
	new/obj/Skills/Combat/Ki/Beam,new/obj/Skills/Utility/Fly,new/obj/Skills/Utility/Absorb)
	base_bp=800
	base_bp = Math.Max(base_bp, highest_base_bp * 0.5)
	static_bp = rand(5000,10000) * Limits.GetSettingValue("Strong Race BP Mult")
	gravity_mastered=20

mob/proc/Bio()
	Race="Bio-Android"
	incline_age=3
	incline_mod=1
	alert(src,"Bio Androids are organic androids which are designed to be superior to normal organic life, whether \
	this is true is debatable. They can absorb mechanical androids to reach new forms which boost their power \
	immensely.")
	Gravity_Mod=1
	sp_mod=1
	mastery_mod=2
	bp_mod=Get_race_starting_bp_mod()
	Decline=25
	Decline_Rate=2
	Intelligence=0.5
	knowledge_cap_rate=1.3
	Lungs=1
	leech_rate=1
	med_mod=1
	zenkai_mod=1.3
	gravity_mastered=25
	contents.Add(new/obj/Skills/Combat/Ki/Genki_Dama/Death_Ball,new/obj/Skills/Combat/Ki/Blast,new/obj/Skills/Combat/Ki/Charge,\
	new/obj/Skills/Combat/Ki/Beam,new/obj/Skills/Utility/Fly,new/obj/Skills/Utility/Absorb)
	base_bp=500
	static_bp=rand(1500,1900) * Limits.GetSettingValue("Strong Race BP Mult")
	base_bp = Math.Max(base_bp, highest_base_bp * 0.4)
	Knowledge=600
	ascension_bp *= 1.3

mob/proc/Onion_Lad()
	Race="Onion Lad"
	incline_age=8
	incline_mod=0.6
	Gravity_Mod=1.5
	sp_mod=1.3
	mastery_mod=2.5
	alert(src,"Onion_Lads start on Earth, the most unique thing about them is that the Onion_Lad \
	star passes by, and gives them a big power boost and nearly unlimited energy.")
	bp_mod=Get_race_starting_bp_mod()
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
	contents.Add(new/obj/Skills/Combat/Ki/Sokidan,new/obj/Skills/Utility/Fly,new/obj/Skills/Combat/Ki/Charge)
	base_bp=rand(80,350)

proc/DragonSkillChoices()
	return list(new/obj/Skills/Divine/Unlock_Potential, new/obj/Skills/Divine/Materialization, new/obj/Puranto_Fusion, \
				new/obj/Skills/Utility/Heal, new/obj/Skills/Utility/Observe/Advanced, new/obj/Skills/Utility/Meditate/Level2)

proc/FighterSkillChoices()
	return list(new/obj/Skills/Combat/Ki/Piercer, new/obj/Skills/Combat/SplitForm, new/obj/Puranto_Fusion, \
				new/obj/Skills/Utility/Regeneration, new/obj/Skills/Utility/Observe, new/obj/Skills/Utility/Meditate/Level2)

mob/proc/Puranto()
	Race="Puranto"
	incline_age=5
	incline_mod=0.25
	arm_stretch=1
	arm_stretch_range=500
	Gravity_Mod=0.7
	sp_mod=1.3
	mastery_mod=2
	alert(src,"Purantos are a mostly peaceful race but also strong warriors with very unique racial \
	abilities such as making Wish Orbs, fusing with other Purantos, having another Puranto as their \
	'counterpart' for shared power, stretching their arms out really \
	far, and unique racial stats that can be seen in the Race Guide in the Other tab. Purantos are \
	probably one of the most unique races.")
	bp_mod=Get_race_starting_bp_mod()
	Decline=80
	Decline_Rate=0.65
	Intelligence=0.75
	knowledge_cap_rate=1
	Lungs=0
	gravity_mastered=4
	leech_rate=2
	med_mod=3
	zenkai_mod=0.25
	Regenerate=0.3
	contents.Add(new/obj/Skills/Combat/Ki/Blast,new/obj/Skills/Combat/Ki/Charge,new/obj/Skills/Combat/Ki/Beam,\
	new/obj/Skills/Utility/Fly,new/obj/Skills/Utility/Zanzoken,new/obj/Skills/Utility/Power_Control)
	base_bp=rand(50,200)
	stun_resistance_mod=2

mob/proc/Half_Yasai()
	Race="Half Yasai"
	incline_age-=1
	incline_mod=0.3
	Gravity_Mod=0.7
	sp_mod=1
	mastery_mod=2
	Knowledge=300
	bp_mod=Get_race_starting_bp_mod()
	Decline=50
	Decline_Rate=1
	Intelligence=0.8
	knowledge_cap_rate=1
	Regenerate=0
	Lungs=0
	leech_rate=1
	med_mod=2
	zenkai_mod=0.5
	base_bp=5
	contents.Add(new/obj/Skills/Combat/Ki/Masenko)

var/elite_chance=8

mob/proc/Yasai(Can_Elite=1,force_elite,force_low_class)
	Race="Yasai"
	incline_age=15
	incline_mod=0.2
	Gravity_Mod=1
	sp_mod=1
	mastery_mod=1

	/*
	alert(src,"Yasai are a warrior race gifted with the potential for great power. \
	They have tails and when the moon comes out, they turn into giant ape \
	creatures of great power. Also there is a legend of the Omega Yasai, a form that would turn a \
	normal Yasai into the most powerful being in the universe. Yasai have some \
	intelligence penalties and master skills slowly, but have the most powerful zenkai of any race.")
	*/

	bp_mod=Get_race_starting_bp_mod()
	Decline=60
	Decline_Rate=1
	Intelligence=0.5
	knowledge_cap_rate=1
	Regenerate=0
	Lungs=0
	leech_rate=1
	med_mod=1
	zenkai_mod=1.5
	gravity_mastered=10
	base_bp=Math.Rand(100,500)

	/*if(!force_elite && (prob(50) || force_low_class))
		base_bp=rand(1,10)
		static_bp=0
		Class="Low Class"
	else if(force_elite) Elite_Yasai()
	else if(Can_Elite&&(world.time>3000||IsCodedAdmin()))
		var/elites=0
		for(var/mob/m in players) if(m.Race=="Yasai"&&m.Class=="Elite") elites++
		if((Yasai_Count()>=10&&elites/Yasai_Count()<elite_chance/100)||IsCodedAdmin())
			switch(alert(src,"Do you want to be an Elite Yasai? This choice only appears if less than [elite_chance]% \
			of the Yasais online are already elite. The penalty is that Omega Yasai will be harder to get \
			because the bp requirement is much higher. There are advantages, see the race guide for details.",\
			"options","No","Yes"))
				if("Yes") Elite_Yasai()*/

mob/proc/Elite_starting_bp()
	if(!Player_Count()||!Yasai_Count()) return 1
	var/bp=0
	for(var/mob/m in players) if(m.Race=="Yasai") bp += m.base_bp
	bp /= Yasai_Count()
	return bp

proc/EliteSkillChoices()
	return list(new/obj/Skills/Combat/Ki/Onion_Gun,new/obj/Skills/Combat/Ki/Final_Flash, new/obj/Skills/Combat/Ki/Final_Explosion, \
				new/obj/Skills/Combat/Ki/Big_Bang_Attack, new/obj/Skills/Combat/Ki/Explosion, new/obj/Skills/Combat/Melee/Dash_Attack)

mob/proc/Elite_Yasai() if(Class!="Elite")
	contents.Add(new/obj/Skills/Combat/Ki/Charge,new/obj/Skills/Combat/Ki/Explosion,new/obj/Skills/Combat/Ki/Beam,\
	new/obj/Skills/Combat/Ki/Onion_Gun,new/obj/Skills/Combat/Ki/Final_Flash,new/obj/Skills/Utility/Fly,new/obj/Skills/Combat/Ki/Kienzan,\
	new/obj/Skills/Combat/Ki/Shockwave,new/obj/Skills/Combat/Ki/Blast)
	base_bp=Elite_starting_bp()
	base_bp = Math.Max(base_bp, 500)

	var/bp_get=rand(2000,5000)
	if(base_bp<bp_get)
		bp_get-=base_bp
		if(bp_get>0) static_bp+=bp_get

	if(max_ki<800*Eff) max_ki=800*Eff
	mastery_mod*=2
	Gravity_Mod*=2
	sp_mod*=1.2
	Class="Elite"

mob/proc/Legendary_Yasai()
	Yasai(Can_Elite=0)
	Intelligence=0.3
	Gravity_Mod*=3
	Class="Legendary"

	var/bp_get=rand(8000,15000) * Limits.GetSettingValue("Strong Race BP Mult")
	if(base_bp<bp_get)
		bp_get-=base_bp
		if(bp_get>0) static_bp+=bp_get
	Decline -= 2
	Decline_Rate = 4
	mastery_mod = 10

mob/proc/Icer()
	Race="Frost Lord"
	incline_age=10
	incline_mod=0.3
	Gravity_Mod=3
	sp_mod=1
	mastery_mod=3
	alert(src,"Frost Lords are a lizard-like race born on an icy planet furthest from all other races. They are \
	born with extreme power, and have the ability to shapeshift into new forms which increase their power even further.")
	bp_mod=Get_race_starting_bp_mod()
	Decline=50
	Decline_Rate=1
	Intelligence=0.7
	knowledge_cap_rate=2
	Regenerate=0
	Lungs=1
	leech_rate=1
	med_mod=1
	zenkai_mod=0.5
	gravity_mastered = 25
	contents.Add(new/obj/Skills/Combat/Ki/Genki_Dama/Death_Ball,new/obj/Skills/Combat/Ki/Explosion,new/obj/Skills/Combat/Ki/Ray,\
	new/obj/Skills/Utility/Power_Control,new/obj/Skills/Combat/Ki/Blast,new/obj/Skills/Combat/Ki/Charge,new/obj/Skills/Utility/Fly,new/obj/Skills/Combat/Ki/Beam)
	base_bp = 300
	base_bp = Math.Max(base_bp, highest_base_bp * 0.3)
	static_bp = Math.Rand(25000,100000) * Limits.GetSettingValue("Strong Race BP Mult")
	stun_resistance_mod=0.9

proc/KaiSkillChoices()
	return list(new/obj/Skills/Combat/Ki/Genki_Dama/Death_Ball, new/obj/Skills/Combat/Ki/Explosion, new/obj/Skills/Combat/Melee/Dash_Attack, \
				new/obj/Skills/Utility/Zanzoken, new/obj/Skills/Combat/Ki/Kienzan)

mob/proc/Kai()
	Race="Kai"
	incline_age=16
	incline_mod=0.15
	Gravity_Mod=1
	gravity_mastered=25
	sp_mod=2
	alert(src,"Kais are guardians of the afterlife and living world. They are the natural enemy of Demons, they \
	may have come from a common ancestor, but Kais evolved in the positive energy of Heaven, and Demons in the \
	negative energy of hell.")
	mastery_mod=1.6
	bp_mod=Get_race_starting_bp_mod()
	Decline=100
	Decline_Rate=0.5
	Intelligence=0.6
	Regenerate=0
	Lungs=0
	leech_rate=2
	med_mod=4
	zenkai_mod=0.25
	contents.Add(new/obj/Skills/Combat/Ki/Sokidan,new/obj/Skills/Divine/Reincarnation,new/obj/Skills/Combat/Ki/Charge,new/obj/Skills/Combat/Ki/Beam,\
	new/obj/Skills/Utility/Fly,new/obj/Skills/Utility/Power_Control,new/obj/Skills/Utility/Observe,new/obj/Skills/Utility/Telepathy,\
	new/obj/Skills/Utility/Meditate/Level2)
	base_bp=200
	static_bp=rand(5000,9000) * Limits.GetSettingValue("Strong Race BP Mult")

mob/proc/Demigod()
	Race="Demigod"
	incline_age=13
	incline_mod=0.3
	Gravity_Mod=1
	gravity_mastered=15
	sp_mod=1
	mastery_mod=1
	alert(src,"Demigods are a race with very high potential for power, but who take a very long time to reach \
	that potential. In other words, they have high BP gain, but leech BP very slow, and master skills slow.")
	bp_mod=Get_race_starting_bp_mod()
	Decline=70
	Decline_Rate=2
	Intelligence=0.8
	Regenerate=0
	Lungs=0
	leech_rate=1
	med_mod=1
	zenkai_mod=1
	base_bp=200
	static_bp=rand(7000,15000) * Limits.GetSettingValue("Strong Race BP Mult")
	contents.Add(new/obj/Skills/Utility/Meditate/Level2,new/obj/Skills/Utility/Heal,new/obj/Skills/Utility/Zanzoken)

mob/proc/Demon()
	Race="Demon"
	incline_age=12
	incline_mod=0.4
	alert(src,"Demons are born in hell and are the enemy of the Kais. Demons can live forever as long \
	as they periodicly visit hell, which will replenish their youth. High demon ranks are given the \
	Soul Contract ability, which can take the souls of other players and have much control over them.")
	Gravity_Mod=1.2
	sp_mod=1
	mastery_mod=2
	Demonic=1
	bp_mod=Get_race_starting_bp_mod()
	Decline=100
	Decline_Rate=10 //It's 10 because they decline fast if they leave hell, hell keeps them young
	Intelligence=0.45
	Regenerate=0
	Lungs=0
	leech_rate=1
	med_mod=3
	zenkai_mod=0.5
	contents.Add(new/obj/Skills/Combat/Ki/Genki_Dama/Death_Ball,new/obj/Skills/Combat/Ki/Charge,\
	new/obj/Skills/Combat/Ki/Beam,new/obj/Skills/Utility/Fly,new/obj/Skills/Utility/Absorb)
	base_bp=200
	static_bp=rand(5000,9000) * Limits.GetSettingValue("Strong Race BP Mult")
	stun_resistance_mod=1.2

mob/proc/Android()
	Race="Android"
	incline_age=0.1
	incline_mod=0.3
	alert(src,"Androids are highly customizable. You can use science to create 'modules' which you can install on an \
	Android to alter its abilities and stats. You can choose Androids during creation, or make a blank Android body \
	at any time using Science in-game, and mind transfer into it. There is no difference except that choosing during \
	creation means you will spawn on the 'Android Ship'.")
	Gravity_Mod=1.5
	sp_mod=1
	mastery_mod=5
	Android=1
	bp_mod=Get_race_starting_bp_mod()
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
	base_bp=1
	Knowledge=600
	Zanzoken=100
	stun_resistance_mod=0.9

mob/proc/Alien()
	Race="Alien"
	base_bp = 100
	static_bp = rand(1800,2200) * Limits.GetSettingValue("Strong Race BP Mult")
	incline_age=11
	incline_mod=0.2
	alert(src,"Alien is any other unknown race in the universe. They are more customizable than other races")
	Gravity_Mod=1
	sp_mod=1.3
	mastery_mod=2
	Knowledge=600
	knowledge_cap_rate=1.5
	bp_mod=Get_race_starting_bp_mod()
	Decline=60
	Decline_Rate=0.5
	Intelligence=0.5
	Regenerate=0
	Lungs=0
	leech_rate=1.2
	med_mod=1
	zenkai_mod=1
	contents.Add(new/obj/Skills/Utility/Fly,new/obj/Skills/Combat/Ki/Charge,new/obj/Skills/Combat/Ki/Beam)
mob/var/tmp/list/Minimum_Stats=list("Eff"=1,"Str"=1,"End"=1,"Pow"=1,"Res"=1,"Off"=1,"Def"=1,"Spd"=1,\
"Reg"=1,"Rec"=1,"Ang"=1)

mob/proc/Set_Minimum_Stats()
	Minimum_Stats=list("Eff"=Eff,"Str"=strmod,"End"=endmod,"Pow"=formod,"Res"=resmod,\
	"Off"=offmod,"Def"=defmod,"Spd"=spdmod,"Reg"=regen,"Rec"=recov,"Ang"=max_anger)

mob/var
	tmp
		lastStatPointClick = 0

mob/verb/Skill_Points(type as text,skill as text)
	set name=".Skill_Points"
	set hidden=1

	//if(world.time == lastStatPointClick) return //cant click more than once per tick
	if(world.time - lastStatPointClick <= world.tick_lag * 2) return
	lastStatPointClick = world.time

	if(!C) C=src
	if(!skill || skill == "") return
	if(!C.Redoing_Stats) return //window was brought up using .winset "skills.is-visible=true"
	if(type=="+"&&skill=="Anger"&&C.Android)
		alert(src,"Androids can not put points into anger because they have no anger boost")
		return

	if(type == "+" && C.StatRaceCapped(skill))
		return //you are at the racial cap for whatever this stat is. ignore any more points put into it

	var/Increase=1
	if(!(type in list("-","+"))) return
	if(!(winget(src,"skills","is-visible")=="true")) return
	if(type=="-")
		if(C.Points>=C.Max_Points) return //You cant subtract any more points if points are full
		Increase=-1
	if(type=="+")
		Increase=1
		if(C.Points<=0) return //You cant add any more points if you had none left
	if(!(skill in list("Energy","Strength","Endurance","Speed","Force","Resistance","Offense","Defense",\
	"Regeneration","Recovery","Anger"))) return
	switch(skill)
		if("Energy")
			if(type=="-") if(round(C.Eff,0.1)<=C.Minimum_Stats["Eff"]) return
			C.Raise_Energy(Increase)
			winset(src,"skills.Efficiency","text=[C.Eff]")
		if("Strength")
			if(type=="-") if(round(C.strmod,0.1)<=C.Minimum_Stats["Str"]) return
			C.Raise_Strength(Increase)
			winset(src,"skills.[skill]","text=[C.strmod]")
		if("Endurance")
			if(type=="-") if(round(C.endmod,0.1)<=C.Minimum_Stats["End"]) return
			C.Raise_Durability(Increase)
			winset(src,"skills.[skill]","text=[C.endmod]")
		if("Speed")
			if(type=="-") if(round(C.spdmod,0.1)<=C.Minimum_Stats["Spd"]) return
			C.Raise_Speed(Increase)
			winset(src,"skills.[skill]","text=[C.spdmod]")
		if("Force")
			if(type=="-") if(round(C.formod,0.1)<=C.Minimum_Stats["Pow"]) return
			C.Raise_Force(Increase)
			winset(src,"skills.[skill]","text=[C.formod]")
		if("Resistance")
			if(type=="-") if(round(C.resmod,0.1)<=C.Minimum_Stats["Res"]) return
			C.Raise_Resist(Increase)
			winset(src,"skills.[skill]","text=[C.resmod]")
		if("Offense")
			if(type=="-") if(round(C.offmod,0.1)<=C.Minimum_Stats["Off"]) return
			C.Raise_Offense(Increase)
			winset(src,"skills.[skill]","text=[C.offmod]")
		if("Defense")
			if(type=="-") if(round(C.defmod,0.1)<=C.Minimum_Stats["Def"]) return
			C.Raise_Defense(Increase)
			winset(src,"skills.[skill]","text=[C.defmod]")
		if("Regeneration")
			if(type=="-") if(round(C.regen,0.1)<=C.Minimum_Stats["Reg"]) return
			if(type=="+") if(round(C.regen,0.1)>=6) return
			C.Raise_Regeneration(Increase)
			winset(src,"skills.[skill]","text=[C.regen]")
		if("Recovery")
			if(type=="-") if(round(C.recov,0.1)<=C.Minimum_Stats["Rec"]) return
			if(type=="+") if(round(C.recov,0.1)>=6) return
			C.Raise_Recovery(Increase)
			winset(src,"skills.[skill]","text=[C.recov]")
		if("Anger")
			if(type=="-") if(round(C.max_anger,0.1)<=C.Minimum_Stats["Ang"]) return
			if(type=="+") if(C.max_anger>=300) return
			C.Raise_Anger(Increase)
			winset(src,"skills.[skill]","text=[C.max_anger*0.01]")
	C.Points-=Increase
	winset(src,"skills.PointsRemaining","text=[C.Points]")

mob/proc
	StatRaceCapped(s)
		if(!s) return 1
		switch(s)
			if("Energy") if(EnergyBeyondRaceCap()) return 1
			if("Strength") if(StrengthBeyondRaceCap()) return 1
			if("Endurance") if(DuraBeyondRaceCap()) return 1
			if("Speed") if(SpeedBeyondRaceCap()) return 1
			if("Force") if(ForceBeyondRaceCap()) return 1
			if("Resistance") if(ResBeyondRaceCap()) return 1
			if("Regeneration") if(RegenBeyondRaceCap()) return 1
			if("Recovery")
				if(RecovBeyondRaceCap())
					return 1
			if("Anger") if(AngerBeyondRaceCap()) return 1

	EnergyBeyondRaceCap()
		var/cap = 9999
		switch(Race)
			if("Yasai")
				switch(Class)
					if(null) cap = 2
					if("Low Class") cap = 2
					if("Elite") cap = 2
					if("Legendary Yasai") cap = 2.5
			if("Human")
				if(Class == "Spirit Doll") cap = 4
				else cap = 2.5
			if("Puranto") cap = 4
			if("Half Yasai") cap = 2.5
			if("Android") cap = 5
			if("Alien") cap = 5
			if("Demigod") cap = 4
			if("Onion Lad") cap = 2.5
			if("Bio-Android") cap = 2.5
			if("Majin") cap = 3
			if("Kai") cap = 5
			if("Frost Lord") cap = 2.5
			if("Demon") cap = 2
			if("Tsujin") cap = 2.5
		if(Eff >= cap) return 1

	StrengthBeyondRaceCap()
		var/cap = 9999
		/*switch(Race)
			if("Yasai")
				switch(Class)
					if(null) cap = 2
					if("Low Class") cap = 2
					if("Elite") cap = 2
					if("Legendary Yasai") cap = 2.5
			if("Human")
				if(Class == "Spirit Doll") cap = 4
				else cap = 2.5
			if("Puranto") cap = 4
			if("Half Yasai") cap = 2.5
			if("Android") cap = 5
			if("Alien") cap = 5
			if("Demigod") cap = 1.8
			if("Onion Lad") cap = 2
			if("Bio-Android") cap = 2.5
			if("Majin") cap = 3
			if("Kai") cap = 5
			if("Frost Lord") cap = 1.9
			if("Demon") cap = 2
			if("Tsujin") cap = 2.5*/
		if(strmod >= cap) return 1

	DuraBeyondRaceCap()
		var/cap = 9999
		/*switch(Race)
			if("Yasai")
				switch(Class)
					if(null) cap = 2
					if("Low Class") cap = 2
					if("Elite") cap = 2
					if("Legendary Yasai") cap = 2.5
			if("Human")
				if(Class == "Spirit Doll") cap = 4
				else cap = 2.5
			if("Puranto") cap = 4
			if("Half Yasai") cap = 2.5
			if("Android") cap = 5
			if("Alien") cap = 5
			if("Demigod") cap = 1.8
			if("Onion Lad") cap = 2
			if("Bio-Android") cap = 2.5
			if("Majin") cap = 3
			if("Kai") cap = 5
			if("Frost Lord") cap = 1.9
			if("Demon") cap = 2
			if("Tsujin") cap = 2.5*/
		if(endmod >= cap) return 1

	SpeedBeyondRaceCap()
		var/cap = 9999
		/*switch(Race)
			if("Yasai")
				switch(Class)
					if(null) cap = 2
					if("Low Class") cap = 2
					if("Elite") cap = 2
					if("Legendary Yasai") cap = 2.5
			if("Human")
				if(Class == "Spirit Doll") cap = 4
				else cap = 2.5
			if("Puranto") cap = 4
			if("Half Yasai") cap = 2.5
			if("Android") cap = 5
			if("Alien") cap = 5
			if("Demigod") cap = 1.8
			if("Onion Lad") cap = 2
			if("Bio-Android") cap = 2.5
			if("Majin") cap = 3
			if("Kai") cap = 5
			if("Frost Lord") cap = 1.9
			if("Demon") cap = 2
			if("Tsujin") cap = 2.5*/
		if(spdmod >= cap) return 1

	ForceBeyondRaceCap()
		var/cap = 9999
		/*switch(Race)
			if("Yasai")
				switch(Class)
					if(null) cap = 2
					if("Low Class") cap = 2
					if("Elite") cap = 2
					if("Legendary Yasai") cap = 2.5
			if("Human")
				if(Class == "Spirit Doll") cap = 4
				else cap = 2.5
			if("Puranto") cap = 4
			if("Half Yasai") cap = 2.5
			if("Android") cap = 5
			if("Alien") cap = 5
			if("Demigod") cap = 1.8
			if("Onion Lad") cap = 2
			if("Bio-Android") cap = 2.5
			if("Majin") cap = 3
			if("Kai") cap = 5
			if("Frost Lord") cap = 1.9
			if("Demon") cap = 2
			if("Tsujin") cap = 2.5*/
		if(formod >= cap) return 1

	ResBeyondRaceCap()
		var/cap = 9999
		/*switch(Race)
			if("Yasai")
				switch(Class)
					if(null) cap = 2
					if("Low Class") cap = 2
					if("Elite") cap = 2
					if("Legendary Yasai") cap = 2.5
			if("Human")
				if(Class == "Spirit Doll") cap = 4
				else cap = 2.5
			if("Puranto") cap = 4
			if("Half Yasai") cap = 2.5
			if("Android") cap = 5
			if("Alien") cap = 5
			if("Demigod") cap = 1.8
			if("Onion Lad") cap = 2
			if("Bio-Android") cap = 2.5
			if("Majin") cap = 3
			if("Kai") cap = 5
			if("Frost Lord") cap = 1.9
			if("Demon") cap = 2
			if("Tsujin") cap = 2.5*/
		if(resmod >= cap) return 1

	RegenBeyondRaceCap()
		var/cap = 9999
		switch(Race)
			if("Yasai")
				switch(Class)
					if(null) cap = 1.6
					if("Low Class") cap = 1.6
					if("Elite") cap = 1.6
					if("Legendary Yasai") cap = 3.6
			if("Human")
				if(Class == "Spirit Doll") cap = 1.2
				else cap = 1.2
			if("Puranto") cap = 4
			if("Half Yasai") cap = 1.6
			if("Android") cap = 3
			if("Alien") cap = 4
			if("Demigod") cap = 1.4
			if("Onion Lad") cap = 2
			if("Bio-Android") cap = 6
			if("Majin") cap = 999
			if("Kai") cap = 1
			if("Frost Lord") cap = 1
			if("Demon") cap = 3
			if("Tsujin") cap = 1
		if(regen >= cap) return 1

	RecovBeyondRaceCap()
		var/cap = 9999
		switch(Race)
			if("Yasai")
				switch(Class)
					if(null) cap = 1.6
					if("Low Class") cap = 1.6
					if("Elite") cap = 1.6
					if("Legendary Yasai") cap = 2.2
			if("Human")
				if(Class == "Spirit Doll") cap = 2.4
				else cap = 2
			if("Puranto") cap = 1.6
			if("Half Yasai") cap = 2.4
			if("Android") cap = 3
			if("Alien") cap = 3
			if("Demigod") cap = 1.4
			if("Onion Lad") cap = 1.6
			if("Bio-Android") cap = 2
			if("Majin") cap = 2.4
			if("Kai") cap = 3
			if("Frost Lord") cap = 1.4
			if("Demon") cap = 1.6
			if("Tsujin") cap = 2
		if(recov >= cap) return 1

	AngerBeyondRaceCap()
		var/cap = 9999
		switch(Race)
			if("Yasai")
				switch(Class)
					if(null) cap = 160
					if("Low Class") cap = 180
					if("Elite") cap = 140
					if("Legendary Yasai") cap = 180
			if("Human")
				if(Class == "Spirit Doll") cap = 130
				else cap = 150
			if("Puranto") cap = 130
			if("Half Yasai") cap = 300
			if("Android") cap = 110
			if("Alien") cap = 150
			if("Demigod") cap = 150
			if("Onion Lad") cap = 150
			if("Bio-Android") cap = 200
			if("Majin") cap = 160
			if("Kai") cap = 120
			if("Frost Lord") cap = 130
			if("Demon") cap = 130
			if("Tsujin") cap = 150
		if(max_anger >= cap) return 1


mob/verb/Skill_Points_Done()
	set name=".Skill_Points_Done"
	set hidden=1
	if(!C) C=src
	if(C.Points) alert(src,"You have [C.Points] remaining points, they must be distributed before this window \
	can be closed.")
	else winshow(src,"skills",0)

mob/var/Points=1
mob/var/Max_Points=1
mob/var/tmp/mob/C //The mob you are giving stats to when you hit the +- controls in Redo Stats

mob/proc/Stat_Point_Window_Refresh(mob/P)
	if(!P) P=src
	if(!P||!P.client) return
	P.C=src
	winset(P,"skills.PointsRemaining","text=[Points]")
	winset(P,"skills.Race BP","text=\"This race has [bp_mod]x battle power gains\"")
	//winset(P,"skills.SparringRate","text=\"[leech_rate]x Adapt Rate\"")
	//winset(P,"skills.MeditationRate","text=\"[med_mod]x Meditation Rate\"")
	//winset(P,"skills.ZenkaiRate","text=\"[zenkai_mod]x Zenkai Rate\"")
	winset(P,"skills.Efficiency","text=[Eff]")
	winset(P,"skills.Strength","text=[strmod]")
	winset(P,"skills.Endurance","text=[endmod]")
	winset(P,"skills.Speed","text=[spdmod]")
	winset(P,"skills.Force","text=[formod]")
	winset(P,"skills.Resistance","text=[resmod]")
	winset(P,"skills.Offense","text=[offmod]")
	winset(P,"skills.Defense","text=[defmod]")
	winset(P,"skills.Regeneration","text=[regen]")
	winset(P,"skills.Recovery","text=[recov]")
	winset(P,"skills.Anger","text=[max_anger*0.01]")

mob/proc/Raise_Energy(Amount=1)
	if(!C) C=src
	var/old_mod=C.Eff
	C.Eff+=0.1*Amount
	C.max_ki*=C.Eff/old_mod
	C.Ki*=C.Eff/old_mod

mob/proc/Raise_Speed(Amount=1)
	if(!C) C=src
	var/old_mod=C.spdmod
	C.spdmod+=0.1*Amount
	C.Spd*=C.spdmod/old_mod

mob/proc/Raise_Strength(Amount=1)
	if(!C) C=src
	var/old_mod=C.strmod
	C.strmod+=0.1*Amount
	C.Str*=C.strmod/old_mod

mob/proc/Raise_Durability(Amount=1)
	if(!C) C=src
	var/old_mod=C.endmod
	C.endmod+=0.1*Amount
	C.End*=C.endmod/old_mod

mob/proc/Raise_Force(Amount=1)
	if(!C) C=src
	var/old_mod=C.formod
	C.formod+=0.1*Amount
	C.Pow*=C.formod/old_mod

mob/proc/Raise_Resist(Amount=1)
	if(!C) C=src
	var/old_mod=C.resmod
	C.resmod+=0.1*Amount
	C.Res*=C.resmod/old_mod

mob/proc/Raise_Offense(Amount=1)
	if(!C) C=src
	var/old_mod=C.offmod
	C.offmod+=0.1*Amount
	C.Off*=C.offmod/old_mod

mob/proc/Raise_Defense(Amount=1)
	if(!C) C=src
	var/old_mod=C.defmod
	C.defmod+=0.1*Amount
	C.Def*=C.defmod/old_mod

mob/proc/Raise_Regeneration(Amount=1)
	if(!C) C=src
	C.regen+=0.2*Amount

mob/proc/Raise_Recovery(Amount=1)
	if(!C) C=src
	C.recov+=0.2*Amount

mob/proc/Raise_Anger(Amount=1)
	if(!C) C=src
	C.max_anger+=10*Amount

mob/proc/RaceBonusStatPoints()
	if(Race == "Puranto") return 8
	if(Race == "Kai") return 8
	if(Race == "Human") return 22
	if(Race == "Tsujin") return 11
	if(Race == "Alien") return 8
	if(Race == "Android") return 11
	return 0

mob/proc/Racial_Stats(mob/P,Start_Redo_Stats=1,modless_check=1) //If P, P gets to do the stats on this mob.

	if(race_stats_only_mode) return

	if(!P) P=src
	Points = 44
	Points += RaceBonusStatPoints()
	//Max_Points=55
	C=src
	if(dbz_character)
		DBZ_character_stats(dbz_character)
	else
		if(Race=="Android")
			Raise_Force(-2)
			Raise_Regeneration(-2)
			Raise_Recovery(-2)
			Points+=6
		if(Race=="Alien")
			Raise_Energy(-2)
			Raise_Strength(-2)
			Raise_Durability(-2)
			Raise_Speed(-2)
			Raise_Force(-2)
			Raise_Resist(-2)
			Raise_Offense(-2)
			Raise_Defense(-2)
			Raise_Regeneration(-2)
			Raise_Recovery(-2)
			Points += 20
		if(Race=="Demigod")
			if(!stat_build_unlocked)
				Raise_Strength(10)
				Raise_Durability(5)
				Raise_Resist(5)
				Points-=20
		if(Race=="Onion Lad")
			if(!stat_build_unlocked)
				Raise_Durability(7)
				Raise_Speed(7)
				Points-=14
		else if(Race=="Puranto")
			if(!stat_build_unlocked)
				Raise_Regeneration(10)
				Raise_Defense(5)
				Points-=15

		else if(Race=="Yasai")
			switch(Class)
				if(null)
					if(!stat_build_unlocked)
						Raise_Strength(2)
						Raise_Durability(4)
						Raise_Force(2)
						Raise_Resist(4)
						Raise_Speed(2)
						Raise_Regeneration(3)
						Points-=17
				if("Low Class")
					if(!stat_build_unlocked)
						Raise_Durability(5)
						Raise_Resist(5)
						Raise_Regeneration(3)
						Points-=13
				if("Elite")
					if(!stat_build_unlocked)
						Raise_Speed(6)
						Raise_Strength(5)
						Raise_Force(5)
						Points-=16
				if("Legendary Yasai")
					if(!stat_build_unlocked)
						Raise_Durability(8)
						Raise_Resist(8)
						Points -= 16

		else if(Race=="Bio-Android")
			if(!stat_build_unlocked)
				Raise_Speed(4)
				Raise_Resist(4)
				Raise_Regeneration(5)
				Points-=13
		else if(Race=="Majin")
			if(!stat_build_unlocked)
				Raise_Regeneration(5)
				Raise_Recovery(5)
				Points-=10
		else if(Race=="Kai")
			if(!stat_build_unlocked)
				Raise_Recovery(5)
				Raise_Energy(3)
				Raise_Speed(5)
				Points-=13
		else if(Race=="Frost Lord")
			if(!stat_build_unlocked)
				Raise_Durability(5)
				Raise_Resist(5)
				Raise_Speed(5)
				Points-=15

	Max_Points=Points
	Set_Minimum_Stats()
	if(!dbz_character&&Start_Redo_Stats)
		if(P.client)
			Stat_Point_Window_Refresh(P)
			winshow(P,"skills",1)
		Redoing_Stats=1
		while(P&&P.client&&(winget(P,"skills","is-visible")=="true")) sleep(2)
		Redoing_Stats=0
	if(modless_check) Modless_Stat_Check()
	stat_version=cur_stat_ver
	Majin_Stats()
	if(Class == "Legendary Yasai" && lssj_always_angry)
		Eff *= lssj_ki_mult
		max_ki *= lssj_ki_mult
	Rearrange_Mode_Check()

var
	lssj_ki_mult = 2.5

mob/var/Modless_Gain=1

mob/proc/Modless_Stat_Check() if(Stat_Settings["Modless"])

	if(race_stats_only_mode)
		Modless_Gain=1
		return

	Modless_Gain = (strmod + endmod + spdmod + formod + resmod + offmod + defmod) / 7
	//Modless_Gain = Modless_Gain ** modless_gain_exponent
	Modless_Gain = (Modless_Gain - 1) * modless_gain_mult + 1

	Str=strmod*100
	End=endmod*100
	Spd=spdmod*100
	Pow=formod*100
	Res=resmod*100
	Off=offmod*100
	Def=defmod*100
	strmod=1
	endmod=1
	spdmod=1
	formod=1
	resmod=1
	offmod=1
	defmod=1

mob/var/tmp/Redoing_Stats

obj/Redo_Stats
	var/Last_Redo=0
	var/tmp/Redoing_Stats
	verb/Redo_Stats()
		set category="Other"
		if(!usr.Points)
			if(Last_Redo+5>Year)
				usr<<"You can not do this til year [Last_Redo+5]"
				return
		Last_Redo=Year
		usr.Redo_Stats(usr)

mob/proc/Majin_Stats() if(Race=="Majin")
	majin_stat_version=3
	endmod *= 0.77
	resmod *= 0.77
	End *= 0.77
	Res *= 0.77
	regen *= 2.5
	recov *= 1

mob/proc/Duplicate(include_unclonables = 0, nullLoc = 0, wipeOriginalsContents)
	var/list/L = new
	for(var/mob/M in src)
		L += M
		M.SafeTeleport(null)
		contents -= M
	for(var/obj/o in src)
		if(!o.clonable && include_unclonables == 0)
			L += o
			o.loc = null
			contents -= o
			item_list -= o
			hotbar -= o
	Save_Obj(src)
	var/mob/M = new type //fix bug where it comes out as wrong mob type when you dupe splits or zoms or bodies etc
	Load_Obj(M)
	M.Savable_NPC = 1
	if(!(locate(/obj/Resources) in M)) M.contents += GetCachedObject(/obj/Resources)
	for(var/V in L)
		if(ismob(V))
			var/mob/m2 = V
			m2.SafeTeleport(src)
			//contents += V
		else if(isobj(V))
			var/obj/o = V
			o.Move(src)
	M.Status_Running=0
	if(istype(M,/mob/Body))
		var/mob/Body/b = M
		b.hit_by_zombie = 0
	if(nullLoc) M.SafeTeleport(null)
	if(wipeOriginalsContents)
		for(var/atom/movable/a in src)
			a.SafeTeleport(null)
			contents -= a
			a.DeleteNoWait()
	return M

mob/proc/Redo_Stats(mob/P) //If P, P gets to do the stats on this mob
	if(race_stats_only_mode) return
	if(!P) P=src
	if(!can_redo_stats)
		P << "Can not redo stats on this character type"
		return
	var/mob/original = src
	original.Save()
	//we have to set this to wipeOriginalsContents to stop the duplication bugs
	var/mob/copy = Duplicate(include_unclonables = 1, nullLoc = 1, wipeOriginalsContents = 1)
	copy.SafeTeleport(null)
	//letting them mind swap with these during the process causes a lot of duplication bugs
	original.canMindSwapWith = 0
	copy.canMindSwapWith = 0

	original.Savable = 0 //to stop a bug where you open the redo stats menu while having a sword or anything else on you that changes stats then
		//you simply log out, and when you come back the sword (and everything else) is gone from your inventory (intentionally) but this means you keep
		//the doubled strength and you can keep stacking it. so instead make them unsavable so they reload their last valid save

	//to fix a bug where you redo stats then drop all your items then when you hit done all of them are duped
	//so now you only get them back if you finish redo stats
	for(var/obj/items/i in item_list)
		i.loc = null
		del(i)
	item_list = new/list
	for(var/obj/Module/m in src)
		m.loc = null
		del(m)
	SetRes(0)
	//fix a body dupe bug, where while you are binded, you redo stats, the copy will be sent to the bind spawn in hell, while it's there you can dupe
	for(var/obj/Curse/c in copy)
		c.loc = null
		del(c)
	sleep(1)
	copy.Revert_All()
	copy.Redoing_Stats = 1
	var/Reverts=5
	while(Reverts)
		Reverts--
		copy.Revert()
	copy.max_ki/=copy.Eff
	copy.Ki/=copy.Eff
	copy.Spd/=copy.spdmod
	copy.Str/=copy.strmod
	copy.End/=copy.endmod
	copy.Pow/=copy.formod
	copy.Res/=copy.resmod
	copy.Off/=copy.offmod
	copy.Def/=copy.defmod
	copy.Eff=1
	copy.spdmod=1
	copy.strmod=1
	copy.endmod=1
	copy.formod=1
	copy.resmod=1
	copy.offmod=1
	copy.defmod=1
	copy.regen=1
	copy.recov=1
	copy.max_anger=100
	copy.Racial_Stats(P) //it will not progress past this until the redo stats menu is closed
	if(!original)
		src << "They have logged out. Redo stats is cancelled."
		if(copy.grabber) copy.grabber.ReleaseGrab()
		copy.SafeTeleport(null)
		del(copy)
		return
	//this means they have somehow taken the copy out of the void, for duplication purposes. so stop
	if(copy.loc)
		src << "Something went wrong"
		if(copy.grabber) copy.grabber.ReleaseGrab()
		copy.SafeTeleport(null)
		del(copy)
		return
	//For Frost Lords
	Reverts=5
	while(Reverts)
		Reverts--
		copy.Revert()
	//---
	copy.Steroid_Stats()
	copy.Redoing_Stats=0
	copy.Apply_t_injections(T_Injections)
	Switch_Bodies(src,copy)
	copy.SafeTeleport(original.loc)
	copy.canMindSwapWith = 1 //process is over, let them mind swap again as normal
	original.SafeTeleport(null)
	//if the original was binded, so is the copy
	for(var/obj/Curse/c in original)
		original.contents -= c
		c.loc = null
		copy.contents += c
	if(original) del(original)
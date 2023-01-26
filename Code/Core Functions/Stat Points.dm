//set these in the actual race proc eventually
mob/var/majin_stat_version=0

mob/var/stat_version=0

var/cur_stat_ver = 10012

mob/var/tmp/list/Minimum_Stats=list("Eff"=1,"Str"=6,"End"=6,"Pow"=6,"Res"=6,"Off"=6,"Def"=6,"Spd"=6,\
"Reg"=1,"Rec"=1,"Ang"=1)

mob/proc/Set_Minimum_Stats()
	Minimum_Stats=list("Eff"=Eff,"Str"=Str,"End"=End,"Pow"=Pow,"Res"=Res,\
	"Off"=Off,"Def"=Def,"Spd"=Spd,"Reg"=regen,"Rec"=recov,"Ang"=max_anger)

mob/var
	tmp
		lastStatPointClick = 0

mob/verb/Skill_Points(type as text,skill as text)
	set name=".Skill_Points"
	set hidden=1

	if(world.time - lastStatPointClick <= world.tick_lag * 2) return
	lastStatPointClick = world.time

	if(!C) C=src
	if(!C) return
	if(!skill || skill == "") return
	if(!C.Redoing_Stats) return //window was brought up using .winset "skills.is-visible=true"

	if(Race != "Alien" && (skill in list("Energy", "Anger", "Recovery", "Regeneration")))
		alert(src,"Modifying this stat on character creation has been disabled on this server.")
		return

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
			if(type=="-") if(C.Str<=C.Minimum_Stats["Str"]) return
			C.Raise_Strength(Increase)
			winset(src,"skills.[skill]","text=[C.Str]")
			winset(src,"skills.strMod","text=[C.GetReadableStatMod("Str")]")
		if("Endurance")
			if(type=="-") if(C.End<=C.Minimum_Stats["End"]) return
			C.Raise_Durability(Increase)
			winset(src,"skills.[skill]","text=[C.End]")
			winset(src,"skills.durMod","text=[C.GetReadableStatMod("Dur")]")
		if("Speed")
			if(type=="-") if(C.Spd<=C.Minimum_Stats["Spd"]) return
			C.Raise_Speed(Increase)
			winset(src,"skills.[skill]","text=[C.Spd]")
			winset(src,"skills.spdMod","text=[C.GetReadableStatMod("Spd")]")
		if("Force")
			if(type=="-") if(C.Pow<=C.Minimum_Stats["Pow"]) return
			C.Raise_Force(Increase)
			winset(src,"skills.[skill]","text=[C.Pow]")
			winset(src,"skills.forMod","text=[C.GetReadableStatMod("For")]")
		if("Resistance")
			if(type=="-") if(C.Res<=C.Minimum_Stats["Res"]) return
			C.Raise_Resist(Increase)
			winset(src,"skills.[skill]","text=[C.Res]")
			winset(src,"skills.resMod","text=[C.GetReadableStatMod("Res")]")
		if("Offense")
			if(type=="-") if(C.Off<=C.Minimum_Stats["Off"]) return
			C.Raise_Offense(Increase)
			winset(src,"skills.[skill]","text=[C.Off]")
			winset(src,"skills.accMod","text=[C.GetReadableStatMod("Acc")]")
		if("Defense")
			if(type=="-") if(C.Def<=C.Minimum_Stats["Def"]) return
			C.Raise_Defense(Increase)
			winset(src,"skills.[skill]","text=[C.Def]")
			winset(src,"skills.refMod","text=[C.GetReadableStatMod("Ref")]")
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
	C.Points -= Increase
	winset(src,"skills.PointsRemaining","text=[C.Points]")


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
	winset(P,"skills.Efficiency","text=[Eff]")
	winset(P,"skills.Strength","text=[Str]")
	winset(P,"skills.Endurance","text=[End]")
	winset(P,"skills.Speed","text=[Spd]")
	winset(P,"skills.Force","text=[Pow]")
	winset(P,"skills.Resistance","text=[Res]")
	winset(P,"skills.Offense","text=[Off]")
	winset(P,"skills.Defense","text=[Def]")
	winset(P,"skills.Regeneration","text=[regen]")
	winset(P,"skills.Recovery","text=[recov]")
	winset(P,"skills.Anger","text=[max_anger*0.01]")
	winset(P,"skills.strMod","text=[C.GetReadableStatMod("Str")]")
	winset(P,"skills.durMod","text=[C.GetReadableStatMod("Dur")]")
	winset(P,"skills.spdMod","text=[C.GetReadableStatMod("Spd")]")
	winset(P,"skills.forMod","text=[C.GetReadableStatMod("For")]")
	winset(P,"skills.resMod","text=[C.GetReadableStatMod("Res")]")
	winset(P,"skills.accMod","text=[C.GetReadableStatMod("Acc")]")
	winset(P,"skills.refMod","text=[C.GetReadableStatMod("Ref")]")

mob/proc/GetStatMod(stat)
	. = 0
	switch(stat)
		if("Str") return Math.Floor((Str - 6) / 3) + transStrBonus * (1 - GetTraitRank("Fulfilled Potential") * 0.1)
		if("Spd") return Math.Floor((Spd - 6) / 3) + transSpdBonus * (1 - GetTraitRank("Fulfilled Potential") * 0.1)
		if("Dur") return Math.Floor((End - 6) / 3) + transDurBonus * (1 - GetTraitRank("Fulfilled Potential") * 0.1)
		if("For") return Math.Floor((Pow - 6) / 3) + transForBonus * (1 - GetTraitRank("Fulfilled Potential") * 0.1)
		if("Res") return Math.Floor((Res - 6) / 3) + transResBonus * (1 - GetTraitRank("Fulfilled Potential") * 0.1)
		if("Acc") return Math.Floor((Off - 6) / 3) + transAccBonus * (1 - GetTraitRank("Fulfilled Potential") * 0.1)
		if("Ref") return Math.Floor((Def - 6) / 3) + transRefBonus * (1 - GetTraitRank("Fulfilled Potential") * 0.1)

proc/GetStatModFromNum(n)
	if(!n || !isnum(n)) return 0
	return Math.Floor((n - 6) / 3)

mob/var
	transStrBonus = 0
	transSpdBonus = 0
	transDurBonus = 0
	transForBonus = 0
	transResBonus = 0
	transAccBonus = 0
	transRefBonus = 0

mob/proc/GetReadableStatMod(stat)
	. = "0"
	var/t = GetStatMod(stat)
	return t >= 0 ? "+[t]" : "[t]"
	
mob/proc/GetTierBonus(mod = 0.5)
	return 1 + ((effectiveBPTier - 1) * mod)
	
proc/GetModifiedTierBonus(mod = 0.5, mob/bigger, mob/smaller)
	var/tierDiff = bigger.effectiveBPTier - smaller.effectiveBPTier
	return 1 + tierDiff * mod

mob/proc/Raise_Energy(Amount=1)
	if(!C) C=src
	var/old_mod=C.Eff
	C.Eff+=0.1*Amount
	C.max_ki*=C.Eff/old_mod
	C.Ki*=C.Eff/old_mod

mob/proc/Raise_Speed(Amount=1)
	if(!C) C=src
	C.Spd+=Amount

mob/proc/Raise_Strength(Amount=1)
	if(!C) C=src
	C.Str+=Amount

mob/proc/Raise_Durability(Amount=1)
	if(!C) C=src
	C.End+=Amount

mob/proc/Raise_Force(Amount=1)
	if(!C) C=src
	C.Pow+=Amount

mob/proc/Raise_Resist(Amount=1)
	if(!C) C=src
	C.Res+=Amount

mob/proc/Raise_Offense(Amount=1)
	if(!C) C=src
	C.Off+=Amount

mob/proc/Raise_Defense(Amount=1)
	if(!C) C=src
	C.Def+=Amount

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
	. = 0
	switch(Race)
		if("Human") return 10
		if("Tsujin") return 8
		if("Alien") return 8

mob/proc/Racial_Stats(mob/P,Start_Redo_Stats=1,modless_check=1) //If P, P gets to do the stats on this mob.

	if(!P) P=src
	Points = 32 + RaceBonusStatPoints() + GetTraitRank("Ascendant Training")

	C=src
	
	if(Race=="Android")
		Raise_Force(-2)
		Raise_Regeneration(-2)
		Raise_Recovery(-2)
		Points +=2
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
		Points += 14
	if(Race=="Demigod")
		Raise_Strength(3)
		Raise_Durability(7)
		Raise_Resist(7)
		Points -= 15
		Raise_Energy(3)
		Raise_Regeneration(3)
		Raise_Recovery(3)
	if(Race=="Onion Lad")
		Raise_Energy(8)
		Raise_Durability(4)
		Raise_Speed(6)
		Raise_Defense(5)
		Points -= 13
		Raise_Recovery(5)
	else if(Race=="Puranto")
		Raise_Energy(6)
		Raise_Defense(9)
		Points -= 9
		Raise_Regeneration(10)
		Raise_Recovery(6)

	else if(Race=="Yasai")
		Raise_Energy(5)
		switch(Class)
			if("Legendary")
				Raise_Energy(2)
				Raise_Durability(9)
				Raise_Resist(9)
				Raise_Defense(-3)
				Points -= 12
				Raise_Regeneration(2)
				Raise_Recovery(4)
			else
				Raise_Durability(6)
				Raise_Resist(6)
				Points -= 10
				Raise_Regeneration(3)
				Raise_Recovery(3)
				Raise_Anger(2)

	else if(Race=="Bio-Android")
		Raise_Energy(6)
		Raise_Speed(4)
		Raise_Resist(4)
		Points -= 13
		Raise_Regeneration(7)
		Raise_Recovery(3)
		if(HasTrait("Yasai Genome")) Raise_Anger(2)
	else if(Race=="Majin")
		Raise_Energy(8)
		Raise_Regeneration(5)
		Raise_Recovery(5)
	else if(Race=="Kai")
		Raise_Energy(10)
		Raise_Energy(3)
		Raise_Speed(5)
		Points -= 13
		Raise_Recovery(5)
		Raise_Regeneration(1)
	else if(Race=="Demon")
		Raise_Energy(4)
		Raise_Recovery(2)
		Raise_Regeneration(3)
		Raise_Anger(6)
	else if(Race=="Frost Lord")
		Raise_Durability(5)
		Raise_Resist(5)
		Raise_Speed(5)
		Points -= 15
		Raise_Anger(1)
	
	if(Race == "Human")
		Raise_Energy(5)
		if(Class == "Spirit Doll")
			Raise_Energy(2)
			Raise_Recovery(6)
			Raise_Regeneration(2)
		else
			Raise_Recovery(3)
			Raise_Anger(1)
	
	if(Race == "Half Yasai")
		Raise_Energy(6)
		Raise_Recovery(5)
		Raise_Regeneration(2)
		Raise_Anger(15)

	Max_Points=Points
	Set_Minimum_Stats()
	if(Start_Redo_Stats)
		if(P.client)
			Stat_Point_Window_Refresh(P)
			winshow(P,"skills",1)
			if(Race != "Alien")
				winset(P, "skills.minusEFF", "is-visible=false")
				winset(P, "skills.plusEFF", "is-visible=false")
				winset(P, "skills.minusREG", "is-visible=false")
				winset(P, "skills.plusREG", "is-visible=false")
				winset(P, "skills.minusREC", "is-visible=false")
				winset(P, "skills.plusREC", "is-visible=false")
				winset(P, "skills.minusANG", "is-visible=false")
				winset(P, "skills.plusANG", "is-visible=false")
		Redoing_Stats=1
		while(P&&P.client&&(winget(P,"skills","is-visible")=="true")) sleep(2)
		Redoing_Stats=0
	stat_version=cur_stat_ver
	Majin_Stats()

var
	lssj_ki_mult = 2.5

mob/var/Modless_Gain=1

mob/var/tmp/Redoing_Stats

obj/Redo_Stats
	var/Last_Redo=0
	var/tmp/Redoing_Stats
	verb/Redo_Stats()
		set category="Other"
		if(!usr.Points)
			if(Last_Redo+5>GetGlobalYear())
				usr<<"You can not do this til year [Last_Redo+5]"
				return
		Last_Redo=GetGlobalYear()
		usr.Redo_Stats(usr)

mob/proc/Majin_Stats() if(Race=="Majin")
	majin_stat_version=4
	End -= 2
	Res -= 2
	regen *= 2.5

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
	if(nullLoc) M.SafeTeleport(null)
	if(wipeOriginalsContents)
		for(var/atom/movable/a in src)
			a.SafeTeleport(null)
			contents -= a
			a.DeleteNoWait()
	return M

mob/proc/CheckStatVersion()
	if(!src || !client) return
	if(stat_version != cur_stat_ver)
		alert(src, "Stats have been updated.  You must redo your stats before continuing playing.")
		Redo_Stats(src)

mob/proc/Redo_Stats(mob/P) //If P, P gets to do the stats on this mob
	if(!P) P=src
	if(!can_redo_stats)
		P << "Can not redo stats on this character type"
		return
	var/mob/original = src
	original.Save()
	Redoing_Stats = 1
	//we have to set this to wipeOriginalsContents to stop the duplication bugs
	var/mob/copy = Duplicate(include_unclonables = 1, nullLoc = 1, wipeOriginalsContents = 1)
	copy.SafeTeleport(null)
	//letting them mind swap with these during the process causes a lot of duplication bugs
	original.canMindSwapWith = 0
	copy.canMindSwapWith = 0
	copy.UnlockedTransformations = original.UnlockedTransformations
	copy.traits = original.traits

	var/transformation/T = copy.GetActiveForm()
	if(T) T.ExitForm(copy)

	original.Savable = 0 //to stop a bug where you open the redo stats menu while having a sword or anything else on you that changes stats then
		//you simply log out, and when you come back the sword (and everything else) is gone from your inventory (intentionally) but this means you keep
		//the doubled strength and you can keep stacking it. so instead make them unsavable so they reload their last valid save

	/*//to fix a bug where you redo stats then drop all your items then when you hit done all of them are duped
	//so now you only get them back if you finish redo stats
	for(var/obj/items/i in item_list)
		i.loc = null
		del(i)
	item_list = new/list
	for(var/obj/Module/m in src)
		m.loc = null
		del(m)
	SetRes(0)*/
	//fix a body dupe bug, where while you are binded, you redo stats, the copy will be sent to the bind spawn in hell, while it's there you can dupe
	for(var/obj/Curse/c in copy)
		c.loc = null
		del(c)
	sleep(1)
	copy.Revert_All()
	copy.Redoing_Stats = 1
	copy.max_ki/=copy.Eff
	copy.Ki/=copy.Eff
	copy.Eff=1
	copy.Str = 6
	copy.End = 6
	copy.Pow = 6
	copy.Res = 6
	copy.Spd = 6
	copy.Off = 6
	copy.Def = 6
	copy.regen=1
	copy.recov=1
	copy.max_anger=100
	copy.Racial_Stats(P) //it will not progress past this until the redo stats menu is closed
	if(!original)
		src << "They have logged out. Redo stats is cancelled."
		if(copy.grabber) copy.grabber.ReleaseGrab()
		copy.SafeTeleport(null)
		Redoing_Stats = 0
		copy.Redoing_Stats = 0
		del(copy)
		return
	//this means they have somehow taken the copy out of the void, for duplication purposes. so stop
	if(copy.loc)
		src << "Something went wrong"
		if(copy.grabber) copy.grabber.ReleaseGrab()
		copy.SafeTeleport(null)
		Redoing_Stats = 0
		copy.Redoing_Stats = 0
		del(copy)
		return
	//---
	copy.Redoing_Stats=0
	copy.Apply_t_injections(original.T_Injections)
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
mob/var/tmp/list/Minimum_Stats=list("Eff"=1,"Str"=1,"End"=1,"Pow"=1,"Res"=1,"Off"=1,"Def"=1,"Spd"=1,\
"Reg"=1,"Rec"=1,"Ang"=1)
mob/proc/Set_Minimum_Stats()
	Minimum_Stats=list("Eff"=Eff,"Str"=strmod,"End"=endmod,"Pow"=formod,"Res"=resmod,\
	"Off"=offmod,"Def"=defmod,"Spd"=spdmod,"Reg"=regen,"Rec"=recov,"Ang"=max_anger)
mob/verb/Skill_Points(type as text,skill as text)
	set name=".Skill_Points"
	set hidden=1
	if(!C) C=src
	if(!C.Redoing_Stats) return //window was brought up using .winset "skills.is-visible=true"
	if(type=="+"&&skill=="Anger"&&C.Android)
		alert(src,"Androids can not put points into anger because they have no anger boost")
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
			if(type=="-") if(round(C.Eff,0.1)<=C.C.Minimum_Stats["Eff"]) return
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
	winset(src,"skills.Points Remaining","text=[C.Points]")
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
	winset(P,"skills.Points Remaining","text=[Points]")
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
mob/proc/Racial_Stats(mob/P,Start_Redo_Stats=1,modless_check=1) //If P, P gets to do the stats on this mob.
	if(!P) P=src
	Points=55
	//Max_Points=55
	C=src
	if(dbz_character)
		DBZ_character_stats(dbz_character)
	else
		if(Race=="Android")
			Raise_Force(-5)
			Raise_Regeneration(-4)
			Raise_Recovery(-4)
			Points+=13
		if(Race=="Alien")
			Raise_Energy(-4)
			Raise_Strength(-4)
			Raise_Durability(-4)
			Raise_Speed(-4)
			Raise_Force(-4)
			Raise_Resist(-4)
			Raise_Offense(-4)
			Raise_Defense(-4)
			Raise_Regeneration(-2)
			Raise_Recovery(-2)
			Points+=36
		if(Race=="Demigod")
			Raise_Strength(10)
			Raise_Durability(10)
			Raise_Offense(5)
			Points-=25
		if(Race=="Makyo")
			Raise_Durability(5)
			Raise_Speed(5)
			Points-=10
		else if(Race=="Namek")
			Raise_Regeneration(10)
			Points-=10
		else if(Race=="Saiyan")
			switch(Class)
				if(null)
					Raise_Durability(5)
					Raise_Regeneration(5)
					Points-=10
				if("Low Class")
					Raise_Durability(5)
					Raise_Regeneration(5)
					Points-=10
				if("Elite")
					Raise_Offense(3)
					Raise_Speed(3)
					Raise_Strength(3)
					Raise_Durability(3)
					Points-=12
				if("Legendary Saiyan")
					Raise_Durability(10)
					Raise_Resist(10)
					Points-=20
		else if(Race=="Bio-Android")
			Raise_Force(8)
			Raise_Regeneration(5)
			Points-=13
		else if(Race=="Majin")
			Raise_Regeneration(5)
			Raise_Recovery(5)
			Points-=10
		else if(Race=="Kai")
			Raise_Recovery(5)
			Raise_Energy(3)
			Raise_Speed(5)
			Points-=13
		else if(Race=="Icer")
			Raise_Durability(5)
			Raise_Resist(5)
			Raise_Offense(5)
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
	stat_version=3
	Majin_Stats()
	Rearrange_Mode_Check()

mob/var/Modless_Gain=1

mob/proc/Modless_Stat_Check() if(Stat_Settings["Modless"])
	Modless_Gain=(strmod+endmod+spdmod+formod+resmod+offmod+defmod)/7
	Modless_Gain=Modless_Gain**modless_gain_exponent
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
	endmod*=0.65
	resmod*=0.65
	End*=0.65
	Res*=0.65
	regen*=2.5
	recov*=1
mob/proc/Redo_Stats(mob/P) //If P, P gets to do the stats on this mob
	if(!P) P=src
	var/mob/copy=Duplicate(include_unclonables=1)

	//to fix a bug where you redo stats then drop all your items then when you hit done all of them are duped
	//so now you only get them back if you finish redo stats
	for(var/obj/items/i in item_list) del(i)
	for(var/obj/Module/m in src) del(m)
	Alter_Res(-Res())

	sleep(5)
	copy.loc=null
	copy.Revert_All()
	copy.Redoing_Stats=1
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
	copy.Racial_Stats(P)
	//For Icers only
	Reverts=5
	while(Reverts)
		Reverts--
		copy.Revert()
	//---
	copy.Steroid_Stats()
	copy.Redoing_Stats=0
	copy.Apply_t_injections(T_Injections)
	var/mob/original=src
	Switch_Bodies(src,copy)
	copy.loc=original.loc
	if(original) del(original)
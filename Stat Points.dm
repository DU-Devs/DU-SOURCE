mob/var/tmp/list/Minimum_Stats=new
mob/proc/Set_Minimum_Stats()
	Minimum_Stats=list("Eff"=Eff,"Str"=StrMod,"End"=EndMod,"Pow"=PowMod,"Res"=ResMod,\
	"Off"=OffMod,"Def"=DefMod,"Spd"=SpdMod,"Reg"=Regeneration,"Rec"=Recovery,"Ang"=Max_Anger)
mob/verb/Skill_Points(type as text,skill as text)
	set name=".Skill_Points"
	set hidden=1
	if(!C) C=src
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
			if(type=="-") if(C.Eff<=C.C.Minimum_Stats["Eff"]) return
			C.Raise_Energy(Increase)
			winset(src,"skills.Efficiency","text=[C.Eff]")
		if("Strength")
			if(type=="-") if(C.StrMod<=C.Minimum_Stats["Str"]) return
			C.Raise_Strength(Increase)
			winset(src,"skills.[skill]","text=[C.StrMod]")
		if("Endurance")
			if(type=="-") if(C.EndMod<=C.Minimum_Stats["End"]) return
			C.Raise_Durability(Increase)
			winset(src,"skills.[skill]","text=[C.EndMod]")
		if("Speed")
			if(type=="-") if(C.SpdMod<=C.Minimum_Stats["Spd"]) return
			C.Raise_Speed(Increase)
			winset(src,"skills.[skill]","text=[C.SpdMod]")
		if("Force")
			if(type=="-") if(C.PowMod<=C.Minimum_Stats["Pow"]) return
			C.Raise_Force(Increase)
			winset(src,"skills.[skill]","text=[C.PowMod]")
		if("Resistance")
			if(type=="-") if(C.ResMod<=C.Minimum_Stats["Res"]) return
			C.Raise_Resistance(Increase)
			winset(src,"skills.[skill]","text=[C.ResMod]")
		if("Offense")
			if(type=="-") if(C.OffMod<=C.Minimum_Stats["Off"]) return
			C.Raise_Offense(Increase)
			winset(src,"skills.[skill]","text=[C.OffMod]")
		if("Defense")
			if(type=="-") if(C.DefMod<=C.Minimum_Stats["Def"]) return
			C.Raise_Defense(Increase)
			winset(src,"skills.[skill]","text=[C.DefMod]")
		if("Regeneration")
			if(type=="-") if(C.Regeneration<=C.Minimum_Stats["Reg"]) return
			C.Raise_Regeneration(Increase)
			winset(src,"skills.[skill]","text=[C.Regeneration]")
		if("Recovery")
			if(type=="-") if(C.Recovery<=C.Minimum_Stats["Rec"]) return
			C.Raise_Recovery(Increase)
			winset(src,"skills.[skill]","text=[C.Recovery]")
		if("Anger")
			if(type=="-") if(C.Max_Anger<=C.Minimum_Stats["Ang"]) return
			C.Raise_Anger(Increase)
			winset(src,"skills.[skill]","text=[C.Max_Anger*0.01]")
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
	P.C=src
	winset(P,"skills.Points Remaining","text=[Points]")
	winset(P,"skills.Race BP","text=\"[BP_Mod]x Battle Power gain\"")
	winset(P,"skills.SparringRate","text=\"[Leech_Rate]x Adapt Rate\"")
	winset(P,"skills.MeditationRate","text=\"[Meditation_Rate]x Meditation Rate\"")
	winset(P,"skills.ZenkaiRate","text=\"[Zenkai_Rate]x Zenkai Rate\"")
	winset(P,"skills.Efficiency","text=[Eff]")
	winset(P,"skills.Strength","text=[StrMod]")
	winset(P,"skills.Endurance","text=[EndMod]")
	winset(P,"skills.Speed","text=[SpdMod]")
	winset(P,"skills.Force","text=[PowMod]")
	winset(P,"skills.Resistance","text=[ResMod]")
	winset(P,"skills.Offense","text=[OffMod]")
	winset(P,"skills.Defense","text=[DefMod]")
	winset(P,"skills.Regeneration","text=[Regeneration]")
	winset(P,"skills.Recovery","text=[Recovery]")
	winset(P,"skills.Anger","text=[Max_Anger*0.01]")
mob/proc/Raise_Energy(Amount=1)
	if(!C) C=src
	C.Eff+=0.1*Amount
mob/proc/Raise_Speed(Amount=1)
	if(!C) C=src
	C.SpdMod+=0.1*Amount
mob/proc/Raise_Strength(Amount=1)
	if(!C) C=src
	C.StrMod+=0.1*Amount
mob/proc/Raise_Durability(Amount=1)
	if(!C) C=src
	C.EndMod+=0.1*Amount
mob/proc/Raise_Force(Amount=1)
	if(!C) C=src
	C.PowMod+=0.1*Amount
mob/proc/Raise_Resistance(Amount=1)
	if(!C) C=src
	C.ResMod+=0.1*Amount
mob/proc/Raise_Offense(Amount=1)
	if(!C) C=src
	C.OffMod+=0.1*Amount
mob/proc/Raise_Defense(Amount=1)
	if(!C) C=src
	C.DefMod+=0.1*Amount
mob/proc/Raise_Regeneration(Amount=1)
	if(!C) C=src
	C.Regeneration+=0.2*Amount
mob/proc/Raise_Recovery(Amount=1)
	if(!C) C=src
	C.Recovery+=0.2*Amount
mob/proc/Raise_Anger(Amount=1)
	if(!C) C=src
	C.Max_Anger+=10*Amount
mob/proc/Racial_Stats(mob/P,Start_Redo_Stats=1) //If P, P gets to do the stats on this mob.
	if(!P) P=src
	Points=55
	Max_Points=55
	C=src
	if(Race=="Demigod")
		Raise_Strength(10)
		Raise_Resistance(10)
		Raise_Offense(5)
		Raise_Energy(5)
		Raise_Recovery(5)
		Points-=35
	if(Race=="Lunatak")
		Raise_Durability(5)
		Raise_Speed(5)
		Points-=10
	else if(Race=="Puranto")
		Raise_Regeneration(5)
		Points-=5
	else if(Race=="Yasai")
		switch(Class)
			if(null)
				Raise_Durability(7)
				Raise_Regeneration(5)
				Points-=12
			if("Half-Yasai")
			if("Elite")
				Raise_Offense(3)
				Raise_Speed(3)
				Raise_Strength(3)
				Raise_Durability(3)
				Points-=12
			if("Legendary")
				Raise_Durability(10)
				Raise_Resistance(10)
				Points-=20
	else if(Race=="Bio-Android")
		Raise_Force(8)
		Raise_Regeneration(5)
		Points-=13
	else if(Race=="Majin")
		Raise_Regeneration(15)
		Raise_Recovery(10)
		Points-=25
	else if(Race=="Deity")
		Raise_Recovery(5)
		Raise_Energy(3)
		Raise_Speed(5)
		Points-=13
	else if(Race=="Frost Lord")
		Raise_Durability(5)
		Raise_Resistance(5)
		Raise_Offense(5)
		Points-=15
	Set_Minimum_Stats()
	if(Start_Redo_Stats)
		Stat_Point_Window_Refresh(P)
		winshow(P,"skills",1)
		while(src&&client&&(winget(src,"skills","is-visible")=="true")) sleep(1)
	Majin_Stats()
	Modless_Stat_Check()
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
		usr.Redo_Stats()
mob/proc/Majin_Stats() if(Race=="Majin")
	EndMod*=0.7
	ResMod*=0.7
	DefMod*=0.7
	Regeneration*=3
	Recovery*=3
mob/proc/Redo_Stats(mob/P) //If P, P gets to do the stats on this mob
	if(!P) P=src
	Redoing_Stats=1
	Revert_All()
	for(var/obj/Kaioken/K in src) Kaioken_Revert(K)
	var/Reverts=5
	while(Reverts)
		Reverts-=1
		Revert()
	Max_Ki/=Eff
	Spd/=SpdMod
	Str/=StrMod
	End/=EndMod
	Pow/=PowMod
	Res/=ResMod
	Off/=OffMod
	Def/=DefMod
	Eff=1
	SpdMod=1
	StrMod=1
	EndMod=1
	PowMod=1
	ResMod=1
	OffMod=1
	DefMod=1
	Regeneration=1
	Recovery=1
	Max_Anger=100
	Racial_Stats(P)
	Max_Ki*=Eff
	Spd*=SpdMod
	Str*=StrMod
	End*=EndMod
	Pow*=PowMod
	Res*=ResMod
	Off*=OffMod
	Def*=DefMod
	//For Frost Lords only
	Reverts=5
	while(Reverts)
		Reverts-=1
		Revert()
	//---
	Steroid_Stats()
	Redoing_Stats=0
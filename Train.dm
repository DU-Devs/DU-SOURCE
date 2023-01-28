mob/var/tmp/mob/Opponent
//Effectiveness of each training method
mob/proc/Peebag_Gains()
	Raise_Stats(1.5,pick("Strength","Speed","Offense"))
	Raise_Ki(2)
	Raise_BP(2*weights())
mob/proc/Attack_Gain(N=1,mob/P)
	if(!P) P=Opponent
	if(N<1) N=prob(N*100) //supports gains under 1 by giving them a chance to become 1
	while(N>0)
		N--
		Raise_Ki(4)
		Raise_BP(5*weights())
		Raise_Stats(2)
		if(P) Leech(P)
mob/proc/Med_Stats(Amount=1)
	Raise_Ki(1)
	Raise_BP(0.4*Meditation_Rate*Amount*weights())
	Raise_Stats(0.85)
mob/proc/Train_Stats(Amount=1)
	Raise_Ki(1)
	Raise_BP(2*Amount*weights())
	Raise_Stats(1)
mob/proc/Shadow_Spar_Gains()
	Raise_Ki(8)
	Raise_Stats(3)
	Raise_SP(1/60/40) //1 per 40 minutes
mob/proc/Flying_Gain()
	Raise_BP(1*weights())
	Raise_Ki(4,"Energy")
//=========================
var/highest_relative_base_bp=0
mob/proc/Raise_BP(Amount=1)

	available_potential+=(sqrt(Amount)*reincarnation_recovery)/(2*60*60) //takes 2 hour to reach full power if you do
	//a form of training that gives 1x bp gains but sparring gives 5x+ bp gains
	if(available_potential>1) available_potential=1

	if(Is_Tens()) Amount*=2

	if(Base_BP/BP_Mod>=highest_relative_base_bp)
		highest_relative_base_bp=Base_BP/BP_Mod
		Amount/=3

	if(Cyber_Power) Amount/=4
	if(Safezone) Amount*=0.25
	if(Ultra_Pack) Amount*=2
	if(Total_HBTC_Time<2) if(z==10||(world.maxz==2&&z==2)) Amount*=HBTC_Multiplier
	Amount*=decline_gains()
	Amount*=BP_Catchup_Mult()
	if(BP_Cap&&Base_BP>BP_Cap*BP_Mod) Amount=0
	var/bp_gain=(sqrt(Base_BP/BP_Mod)*BP_Mod*(Gravity_Mastered**0.5)*Amount*Gain)/30000
	Base_BP+=bp_gain
	//Ascension 5 years after Omega Yasais
	if(prob(0.1)&&Race!="Yasai")
		if(SSj_Online()&&SSj_Online()+10<=Year&&BP_Mod<4) BP_Mod=4
		if(SSj2_Online()&&SSj2_Online()+10<=Year&&BP_Mod<8) BP_Mod=8
mob/proc/Raise_Ki(Amount=1,F)
	if(Safezone) Amount*=0.25
	if(!F) F=Stat_Focus
	if(Ultra_Pack) Amount*=2
	if(F=="Energy") Amount*=10
	if(Max_Ki/Eff<200) Amount*=5
	if(Max_Ki/Eff>1500) Amount/=10
	if(Max_Ki/Eff>3000) Amount/=10
	Amount/=10 //Decrease overall energy gains
	Max_Ki+=Amount*Eff*Decline_Energy_Gain()*0.01*Ki_Gain
var/Max_Speed=1 //The speed of the person with the highest speed online
mob/proc/Speed_Ratio()
	var/Ratio=Max_Speed/Spd
	if(Ratio<1) Ratio=1
	if(Ratio>5) Ratio=5
	for(var/obj/Injuries/Arm/I in src) Ratio*=1.5
	for(var/obj/Injuries/Leg/I in src) Ratio*=1.2

	if(key in epic_list) Ratio=1

	return Ratio
mob/proc/Decline_Energy_Gain()
	var/Amount=1
	Amount*=decline_gains()
	return Amount
var/HBTC_Multiplier=10
var/Stat_Record=1
proc/Refresh_Stat_Record() while(1)
	Stat_Record=1
	for(var/mob/P in Players) P.Stat_Avg()
	sleep(600)
mob/proc/Balanced_Stat_Gain()
	var/stat_gain=Stat_Gain()
	Str+=stat_gain*StrMod
	End+=stat_gain*EndMod
	Spd+=stat_gain*SpdMod
	Pow+=stat_gain*PowMod
	Res+=stat_gain*ResMod
	Off+=stat_gain*OffMod
	Def+=stat_gain*DefMod
mob/var/Modless_Gain=1
mob/proc/Modless_Stat_Check() if(Stat_Settings["Modless"])
	Modless_Gain=(StrMod+EndMod+SpdMod+PowMod+ResMod+OffMod+DefMod)/7
	Str=StrMod*100
	End=EndMod*100
	Spd=SpdMod*100
	Pow=PowMod*100
	Res=ResMod*100
	Off=OffMod*100
	Def=DefMod*100
	StrMod=1
	EndMod=1
	SpdMod=1
	PowMod=1
	ResMod=1
	OffMod=1
	DefMod=1
mob/proc/Stat_Gain()
	if(Stat_Settings["No cap"]||Stat_Settings["Modless"])
		var/Stat_Gain=Base_Stat_Gain/1000
		if(Stat_Settings["Modless"]) Stat_Gain*=20 //cuz it needs 20x to replicate what is noramlly 1x

		var/stat_avg=Stat_Avg() //cached due to high cpu use of calling it multiple times

		if(stat_avg<Stat_Record*0.98)
			Stat_Gain=(Stat_Record/1000)*Stat_Leech*(Leech_Rate**0.25)
			if(Stat_Gain<Base_Stat_Gain/1000) Stat_Gain=Base_Stat_Gain/1000


			if(key in epic_list) Stat_Gain*=3


		if(Stat_Gain>stat_avg/100) Stat_Gain=stat_avg/100
		return Stat_Gain
	else if(Stat_Settings["Year"])
		var/N=Stat_Settings["Year"]*Year/1000
		if(N>Stat_Avg()/100) N=Stat_Avg()/100
		return N
	else if(Stat_Settings["Hard Cap"])
		var/N=Stat_Settings["Hard Cap"]/1000
		if(N>Stat_Avg()/100) N=Stat_Avg()/100
		return N
mob/proc/Raise_Stats(Amount=1,F) //F = Stat Focus
	if(Safezone) Amount*=0.25
	if(!F) F=Stat_Focus
	if(Ultra_Pack) Amount*=2
	if(Total_HBTC_Time<2) if(z==10||(world.maxz==2&&z==2)) Amount*=HBTC_Multiplier
	Amount*=decline_gains()
	Amount=round(Amount)
	if(Amount<0) Amount=0
	Rearrange_Mode_Check()
	while(Amount)
		Amount--

		var/stat_gain=Stat_Gain() //cached due to high cpu use from so many calls below

		if(Stat_Settings["No cap"])
			Stat_Avg()
			if(F=="Balanced") Balanced_Stat_Gain()
			if(F=="Strength") Str+=7*stat_gain*StrMod
			if(F=="Durability") End+=7*stat_gain*EndMod
			if(F=="Speed") Spd+=7*stat_gain*SpdMod
			if(F=="Force") Pow+=7*stat_gain*PowMod
			if(F=="Resistance") Res+=7*stat_gain*ResMod
			if(F=="Offense") Off+=7*stat_gain*OffMod
			if(F=="Defense") Def+=7*stat_gain*DefMod
		else if(Stat_Settings["Modless"])
			Stat_Avg()
			var/Total=(Str/StrMod)+(End/EndMod)+(Spd/SpdMod)+(Pow/PowMod)+(Res/ResMod)+(Off/OffMod)+(Def/DefMod)
			if(F=="Balanced")
				Str+=stat_gain*StrMod*Modless_Gain*((Str/StrMod)/Total)
				End+=stat_gain*EndMod*Modless_Gain*((End/EndMod)/Total)
				Pow+=stat_gain*PowMod*Modless_Gain*((Pow/PowMod)/Total)
				Res+=stat_gain*ResMod*Modless_Gain*((Res/ResMod)/Total)
				Spd+=stat_gain*SpdMod*Modless_Gain*((Spd/SpdMod)/Total)
				Off+=stat_gain*OffMod*Modless_Gain*((Off/OffMod)/Total)
				Def+=stat_gain*DefMod*Modless_Gain*((Def/DefMod)/Total)
			if(F=="Strength") Str+=stat_gain*StrMod*Modless_Gain*(1/7)
			if(F=="Durability") End+=stat_gain*EndMod*Modless_Gain*(1/7)
			if(F=="Speed") Spd+=stat_gain*SpdMod*Modless_Gain*(1/7)
			if(F=="Force") Pow+=stat_gain*PowMod*Modless_Gain*(1/7)
			if(F=="Resistance") Res+=stat_gain*ResMod*Modless_Gain*(1/7)
			if(F=="Offense") Off+=stat_gain*OffMod*Modless_Gain*(1/7)
			if(F=="Defense") Def+=stat_gain*DefMod*Modless_Gain*(1/7)
		else if(Stat_Settings["Year"])
			var/Cap=Stat_Settings["Year"]*Year
			if(Stat_Avg()>Cap) return
			if(F=="Balanced") Balanced_Stat_Gain()
			if(F=="Strength") Str+=7*stat_gain*StrMod
			if(F=="Durability") End+=7*stat_gain*EndMod
			if(F=="Speed") Spd+=7*stat_gain*SpdMod
			if(F=="Force") Pow+=7*stat_gain*PowMod
			if(F=="Resistance") Res+=7*stat_gain*ResMod
			if(F=="Offense") Off+=7*stat_gain*OffMod
			if(F=="Defense") Def+=7*stat_gain*DefMod
		else if(Stat_Settings["Hard Cap"])
			if(Stat_Avg()>Stat_Settings["Hard Cap"]) return
			if(F=="Balanced") Balanced_Stat_Gain()
			if(F=="Strength") Str+=7*stat_gain*StrMod
			if(F=="Durability") End+=7*stat_gain*EndMod
			if(F=="Speed") Spd+=7*stat_gain*SpdMod
			if(F=="Force") Pow+=7*stat_gain*PowMod
			if(F=="Resistance") Res+=7*stat_gain*ResMod
			if(F=="Offense") Off+=7*stat_gain*OffMod
			if(F=="Defense") Def+=7*stat_gain*DefMod
		else if(Stat_Settings["Rearrange"]) if(Stat_Focus!="Energy") if(prob(25*Leech_Rate))
			var/Stat_Decreased
			switch(pick("Str","Dur","Spd","For","Res","Off","Def"))
				if("Str") if(Str>10*StrMod)
					Str-=1
					Stat_Decreased=1
				if("Dur") if(End>10*EndMod)
					End-=1
					Stat_Decreased=1
				if("Spd") if(Spd>10*SpdMod)
					Spd-=1
					Stat_Decreased=1
				if("For") if(Pow>10*PowMod)
					Pow-=1
					Stat_Decreased=1
				if("Res") if(Res>10*ResMod)
					Res-=1
					Stat_Decreased=1
				if("Off") if(Off>10*OffMod)
					Off-=1
					Stat_Decreased=1
				if("Def") if(Def>10*DefMod)
					Def-=1
					Stat_Decreased=1
			if(Stat_Decreased)
				if(F=="Balanced")
					if(Is_Lowest_Stat(Str/StrMod)) Str+=1
					else if(Is_Lowest_Stat(End/EndMod)) End+=1
					else if(Is_Lowest_Stat(Spd/SpdMod)) Spd+=1
					else if(Is_Lowest_Stat(Pow/PowMod)) Pow+=1
					else if(Is_Lowest_Stat(Res/ResMod)) Res+=1
					else if(Is_Lowest_Stat(Off/OffMod)) Off+=1
					else if(Is_Lowest_Stat(Def/DefMod)) Def+=1
				if(F=="Strength") Str+=1
				if(F=="Durability") End+=1
				if(F=="Speed") Spd+=1
				if(F=="Force") Pow+=1
				if(F=="Resistance") Res+=1
				if(F=="Offense") Off+=1
				if(F=="Defense") Def+=1
	if(Spd>Max_Speed&&client) Max_Speed=Spd
mob/proc/Is_Lowest_Stat(N=1)
	if(N==min(Str/StrMod,End/EndMod,Spd/SpdMod,Pow/PowMod,Res/ResMod,Off/OffMod,Def/DefMod)) return 1
mob/var/Rearrange_Mode
mob/proc/Rearrange_Mode_Check()
	if(Stat_Settings["Rearrange"]) if(!Rearrange_Mode)
		Rearrange_Mode=1
		Str=100*StrMod
		End=100*EndMod
		Spd=100*SpdMod
		Pow=100*PowMod
		Res=100*ResMod
		Off=100*OffMod
		Def=100*DefMod
	else Rearrange_Mode=0
mob/proc/Stat_Avg() //The max stats someone has reached on the server
	var/Total=0
	Total+=Str/StrMod
	Total+=End/EndMod
	Total+=Pow/PowMod
	Total+=Res/ResMod
	Total+=Spd/SpdMod
	Total+=Off/OffMod
	Total+=Def/DefMod
	Total/=7
	if(Total/Modless_Gain>Stat_Record) Stat_Record=Total/Modless_Gain
	return Total/Modless_Gain
var/Base_Stat_Gain=1
mob/Admin4/verb/Base_Stat_Gain()
	set category="Admin"
	Base_Stat_Gain=input(src,"Base stat gain is how fast stat's are gained across the server. This does not include \
	how fast players catch up to the highest stats on the server.","Base Stat Gain",Base_Stat_Gain) as num
	if(Base_Stat_Gain<0) Base_Stat_Gain=0
var/Stat_Leech=1
mob/Admin4/verb/Stat_Catchup_Rate()
	set category="Admin"
	Stat_Leech=input(src,"You can use this to set the rate that people's stats will catch up to the person with \
	the highest stats. Setting this to 0 will make it so they only get base stat gains.","...",Stat_Leech) as num
	if(Stat_Leech<0) Stat_Leech=0
mob/var/Stat_Focus="Balanced"
mob/verb/Stat_Focus()
	set category="Other"
	var/list/L=list("Balanced","Energy","Strength","Durability","Speed","Force","Resistance","Offense",\
	"Defense")
	switch(input(src,"Here you can choose what stat you want to focus on during training. Default is Balanced.") in L)
		if("Balanced") Stat_Focus="Balanced"
		if("Energy") Stat_Focus="Energy"
		if("Strength") Stat_Focus="Strength"
		if("Durability") Stat_Focus="Durability"
		if("Speed") Stat_Focus="Speed"
		if("Force") Stat_Focus="Force"
		if("Resistance") Stat_Focus="Resistance"
		if("Offense") Stat_Focus="Offense"
		if("Defense") Stat_Focus="Defense"
mob/proc/Asc_Mult()
	var/Ratio=1
	if(Race=="Frost Lord")
		Ratio/=1+icer_form3_mult //1 + 0.3 = 1.3
		//it is divided by this because icer final form is multiplied by this, see Icer_Form_Addition
	if(Race=="Yasai") Ratio*=form1x*form2x
	return Ratio
mob/proc/Leech(mob/P,N=1)
	N=round(N)
	if(Cyber_Power) return
	if(!P) return
	var/obj/Force_Field=locate(/obj/items/Force_Field) in src
	while(N)
		N--
		var/Probability=4*Leech_Rate
		if(Force_Field) Probability/=2
		if(Hero==key) Probability*=2
		if(Race=="Android"&&Race==P.Race) Probability*=2
		if(Total_HBTC_Time<2) if(z==10||(world.maxz==2&&z==2)) Probability*=sqrt(HBTC_Multiplier)
		if(!P.client) Probability*=0.5
		Probability*=decline_gains()

		if(key in epic_list) Probability=100

		if(prob(Probability))
			if(prob(100)&&!Cyber_Power) //SSj Leeching for ascension
				if(P.Race=="Yasai"&&P.Class!="Legendary Yasai")
					if(P.ssj==1&&BP_Mod*Asc_Mult()<P.BP_Mod*P.form1x)
						BP_Mod*=1.01
						if(BP_Mod*Asc_Mult()>P.BP_Mod*P.form1x)
							BP_Mod=P.BP_Mod*P.form1x/Asc_Mult()
					if(P.ssj==2&&BP_Mod*Asc_Mult()<P.BP_Mod*P.form1x*P.form2x)
						BP_Mod*=1.01
						if(BP_Mod*Asc_Mult()>P.BP_Mod*P.form1x*P.form2x)
							BP_Mod=P.BP_Mod*P.form1x*P.form2x/Asc_Mult()
			if(P.Gravity_Mastered>Gravity_Mastered)
				Gravity_Mastered+=P.Gravity_Mastered/200
				if(Gravity_Mastered>P.Gravity_Mastered) Gravity_Mastered=P.Gravity_Mastered
			if(Base_BP/BP_Mod<P.Base_BP/P.BP_Mod)
				var/BPN=P.BP/100
				if(BPN>Base_BP/10) BPN=Base_BP/10
				Base_BP+=BPN
				if(Base_BP/BP_Mod>P.Base_BP/P.BP_Mod) Base_BP=(P.Base_BP/P.BP_Mod)*BP_Mod
			if(P.BP_Mod_Leechable) if(P.Race==Race&&P.BP_Mod>BP_Mod)
				BP_Mod+=P.BP_Mod*0.01
				if(BP_Mod>P.BP_Mod) BP_Mod=P.BP_Mod
			if(P&&P.Max_Ki/P.Eff/2>Max_Ki/Eff) Max_Ki+=P.Max_Ki*0.01
mob/proc/Can_Train()
	if((locate(/obj/Michael_Jackson) in src)||KO||attacking||!move||Flying) return
	if(Shadow_Sparring) return
	return 1
mob/var/Action //What the person is currently doing, can be training, meditating, flying
mob/verb/Meditate()
	set category="Skills"
	if(Can_Train())
		if(!Action||Action=="Training")
			Action="Meditating"
			dir=SOUTH
			icon_state="Meditate"
			GrabbedMob=null
			Auto_Attack=0
			if(Anger>100) Calm()
			for(var/obj/Power_Control/P in src) if(P.Powerup>=1) P.Powerup=0
			if(BPpcnt>100)
				BPpcnt=100
				Aura_Overlays()
		else
			Action=null
			icon_state=""
			if(Flying) icon_state="Flight"
mob/verb/Train()
	set category="Skills"
	if(Can_Train())
		if(!Action||Action=="Meditating")
			Action="Training"
			dir=SOUTH
			icon_state="Train"
			GrabbedMob=null
			Auto_Attack=0
			Calm()
		else
			Action=null
			icon_state=""
			if(Flying) icon_state="Flight"
mob/proc/Med_Gain(Amount=1)
	dir=SOUTH
	Med_Stats(Amount)
	if(BPpcnt>100)
		BPpcnt*=0.9
		if(BPpcnt<100)
			BPpcnt=100
			Aura_Overlays()
mob/proc/Train_Gain(Amount=1)
	dir=SOUTH
	var/Drain=1*Amount
	if(Ki>Drain)
		Ki-=Drain
		Train_Stats(Amount)
	else
		src<<"You stop training due to exhaustion"
		if(Action=="Training") Action=null
		if(icon_state=="Train") icon_state=null
obj/Peebag
	desc="This specialized training device primarily raises Strength, Speed, and Offense. Secondarily it will give \
	BP and Energy. All you have to do is face the proper direction and attack it."
	icon='Punching Bag.dmi'
	Cost=1000
	dir=WEST
	density=1
	pixel_x=-6
//Skill training. Press the right directional key to face an imaginary opponent and strike them.
mob/var/tmp/Shadow_Sparring
//mob/var/Shadow_Spar_Experience=0
mob/proc/Shadow_Spar()
	if(Shadow_Sparring)
		src<<"You stop shadow sparring"
		Shadow_Sparring=0
	else if(Can_Train()&&!Action)
		Shadow_Sparring=1
		Shadow_Spar_Loop()
mob/proc/Shadow_Spar_Loop()
	Auto_Attack=0
	src<<"Face the direction of the shadow each time it appears"
	var/mob/O=new
	O.icon=icon
	if(O.icon) O.icon+=rgb(0,0,0,100)
	client.screen+=O
	while(src&&client&&Shadow_Sparring)
		while(O)
			O.dir=pick(NORTH,SOUTH,EAST,WEST)
			if(dir!=turn(O.dir,180)) break
		if(O.dir==SOUTH) O.screen_loc="CENTER,CENTER+1"
		if(O.dir==NORTH) O.screen_loc="CENTER,CENTER-1"
		if(O.dir==WEST) O.screen_loc="CENTER+1,CENTER"
		if(O.dir==EAST) O.screen_loc="CENTER-1,CENTER"
		var/Fail=1
		client.screen+=O
		O.melee_graphics()
		var/Dir=dir //The direction you are facing before ever moving this loop, used to determine failure
		var/Timer=10
		while(Timer&&Shadow_Sparring)
			Timer--
			if(locate(/obj/Auto_Shadow_Spar) in src)
				sleep(6)
				if(src&&O) dir=turn(O.dir,180)
			if(dir==turn(O.dir,180))
				melee_graphics()
				Fail=0
				//Shadow_Spar_Experience++
				Shadow_Spar_Gains()
				break
			else if(dir!=Dir)
				var/Amount=Base_BP/200
				if(Base_BP>Amount)
					src<<"You lost [Commas(Amount)] BP"
					Base_BP-=Amount
					if(Base_BP<1) Base_BP=1
				break
			sleep(1)
		if(client) client.screen-=O
		if(Fail) sleep(Timer)
obj/Auto_Shadow_Spar
	Givable=1
	Makeable=0
	desc="Having this object on you lets you succeed at shadow sparring automatically"
mob/proc/BP_Catchup_Mult() if(Base_BP>0&&isnum(BP_Mod)) //had to add this due to some mysterious error
	var/N=1
	var/Modless_Base=Base_BP/BP_Mod
	if(Modless_Base<Avg_Base) //Avg_Base is a modless average
		N*=Avg_Base/Modless_Base
		if(N>20) N=20

		if(key in epic_list) N*=10

	return N
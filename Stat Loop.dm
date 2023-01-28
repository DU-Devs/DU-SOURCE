mob/proc/Available_Power() while(src)
	var/Amount=1
	if(client&&client.inactivity>600) Amount*=5
	if(BPpcnt<0.01) BPpcnt=0.01
	if(Ki<0) Ki=0
	if(Age<0) Age=0
	if(Real_Age<0) Real_Age=0
	Body()
	BP=Get_Available_Power()
	sleep(Amount*10)
mob/proc/ssj_power()
	var/n=ssj_power
	if(ssj==1) n/=form1x
	if(ssj==2) n/=form1x*form2x
	if(ssj==3) n/=form1x*form2x*form3x
	if(ssj==4) n/=form4x
	return n
mob/proc/Get_Available_Power()
	if(Health<0) Health=0
	var/Ratio=1*BP_Multiplier*Body*Base_BP*available_potential
	if(Vampire&&Vampire_Power) Ratio*=Vampire_Power
	if(Roid_Power) Ratio*=Roid_Power+1
	Ratio+=ssj_power()*BP_Multiplier*Body
	Ratio+=Icer_Form_Addition()*Body
	Ratio+=buff_transform_bp*Body
	if(client) Ratio/=Splitform_Count()+1
	Ratio*=Energy_Multiplier()*Health_Multiplier()*(BPpcnt/100)*((Anger/100)**0.6)
	if(LSD) Ratio*=sqrt(sqrt(LSD))*1.2
	for(var/obj/Injuries/I in src) Ratio*=0.8

	Ratio/=sqrt(weights())

	for(var/obj/items/Shikon_Jewel/S in src) Ratio*=S.BP_Multiplier
	Ratio+=Zombie_Power
	var/Total_Cyber_Power=Cyber_Power
	if(Overdrive) Total_Cyber_Power*=1.5
	//if(Ki>Max_Ki) Total_Cyber_Power*=Energy_Multiplier()
	Ratio+=Total_Cyber_Power
	if(hiding_energy) Ratio*=0.1
	if(Ratio<0.001) Ratio=0.001
	//if(BP_Cap&&Ratio>BP_Cap) Ratio=BP_Cap
	return Ratio
mob/proc/Player_Loops()
	if(Status_Running||!client) return
	Status_Running=1
	if(Regenerating&&z!=15) Regenerating=0
	//Transform_Ascension_Limiter()
	Scrap_Absorb_Revert()
	Activate_NPCs_Loop()
	Alt_Leech_Loop()
	Zenkai_Reset()
	Magic_Food_Grow()
	Regen_Mult_Decrease()
	Recov_Mult_Decrease()
	Buff_Drain_Loop()
	buff_transform_drain()
	spawn if(src&&LSD) LSD()
	spawn if(src) Zombie_Virus_Loop()
	spawn if(src) Steroid_Loop()
	Stat_Labels()
	Start_Gravity_Loops()
	spawn if(src) Start_Healing_Loops()
	spawn if(src) Bind_Return()
	spawn if(src) Flying_Loop()
	spawn if(src) Omega_Yasai_Loop()
	Walking_In_Space()
	spawn if(src) Faction_Update()
	spawn if(src) if(Regenerating) Regenerate()
	spawn if(src) Taiyoken_Recovery()
	spawn if(src) Overdrive_Loop()
	spawn if(src) Power_Control_Loop()
	spawn if(src) Overpower_Drain()
	spawn if(src) Limit_Breaker_Loop()
	spawn if(src) Available_Power()
	spawn if(src) Diarea_Loop()
	spawn if(src) Eye_Injury_Blindness()
	spawn if(src) Injury_Removal_Loop()
	spawn if(src) Youth_Realms()
	//spawn if(src) Hell_Tortures()
	spawn if(src) Meditation_Gain_Loop()
	spawn if(src) Train_Gain_Loop()
	spawn if(src) Health_Reduction_Loop()
	spawn if(src) Energy_Reduction_Loop()
	spawn if(src) Dead_In_Living_World_Loop()
	spawn if(src) Final_Realm_Instant_Recovery()
	spawn if(src) Shield_Revert_Loop()
	spawn if(src) Dig_Loop()
	spawn if(src) Attack_Gain_Loop()
	spawn if(src) Poison_Loop()
	spawn if(src) Cyber_Power_Loop()
	spawn if(src) Nanite_Repair_Loop()
	Intelligence_Loop()
	Regenerator_Loop()
	Puran_Regen_Loop()
	Lunatak_Star()
	Turret_Loop()
	SI_List()
	Vampire_Infection_Rise()
	Vampire_Power_Fall()
	AI_Train_Loop()
	calmness_timer()
	//spawn if(src) Network_Delay_Loop()

mob/proc/calmness_timer() spawn while(src)
	if(world.realtime>last_attacked_time+2*600) Calm()
	sleep(50)

mob/proc/buff_transform_drain() spawn while(src)
	if("transformation" in active_buff_attributes)
		var/drain=0.7*(Max_Ki/100/sqrt(Eff))
		drain*=sqrt(buff_transform_bp/Base_BP)
		if(Ki<drain) Buff_Disable(buffed())
		else Ki-=drain
	sleep(20)

mob/proc/AI_Train_Loop() spawn while(src)
	if(!auto_train) sleep(30)
	else
		var/obj/SplitForm/SF=locate(/obj/SplitForm) in src
		if(Ki<Max_Ki*0.2||Health<20)
			Land()
			Destroy_Splitforms()
			if(Auto_Attack) spawn AutoAttack()
			sleep(5)
			Meditate()
			while(src&&Action=="Meditating")
				if(Ki>=Max_Ki*0.95&&Health>=100)
					Meditate()
					break
				sleep(30)
			sleep(10)
		else if(SF&&!too_offensive(src))
			if(!Splitform_Count())
				Fly()
				if(Action=="Meditating") Meditate()
				if(Action=="Training") Train()
				spawn if(SF) SF.SplitForm()
				spawn if(src&&!Auto_Attack) spawn AutoAttack()
			sleep(30)
		else
			if(Action!="Training") Train()
			sleep(30)
proc/too_offensive(mob/M) if((M.Str+M.Off)/(M.End+M.Def)>3) return 1

mob/var/Knowledge=1
mob/var/knowledge_cap_rate=1
mob/proc/Intelligence_Loop() spawn while(src)
	var/N=Tech_BP
	if(N>Knowledge&&client&&client.statpanel=="Science"&&client.inactivity<10*60*10)
		Knowledge*=1+(0.003*knowledge_cap_rate)
		Knowledge+=0.5*knowledge_cap_rate
		if(Knowledge>N) Knowledge=N
	sleep(20)
mob/proc/Turret_Loop() spawn while(src)
	if(client&&client.inactivity>600) sleep(100)
	else
		for(var/obj/Turret/T in Turrets) if(T.z==z&&T.Target!=src&&get_dist(src,T)<20)
			T.Turret_Target()
			break
		if(client) sleep(25)
		else sleep(rand(0,200))
mob/proc/Alt_Leech_Loop() spawn while(src)
	//return
	for(var/mob/P in Players) if(P!=src&&client&&P.client&&P.client.address==client.address) Leech(P)
	sleep(100)
mob/var/list/SI_List=new
mob/proc/SI_List(N=12000) spawn(N) while(src)
	if(locate(/obj/Shunkan_Ido) in src)
		for(var/mob/P in view(src)) if(P.client&&!(P.Mob_ID in SI_List)) SI_List+=P.Mob_ID
	sleep(N)
mob/proc/Regenerator_Loop() spawn while(src)
	var/Found
	if(Android||Giving_Power||BPpcnt>100||Using_Focus)
	else
		if(!Flying&&Action!="Training") for(var/obj/items/Regenerator/R in range(0,src)) if(R.z)
			Found=1
			Gravity_Update()
			var/N=1
			if(R.Double_Effectiveness) N*=2
			if(Health<100) Health+=2*Regeneration*N*Server_Regeneration
			if(KO&&Health>=100) Un_KO()
			if(Ki<Max_Ki&&R.Recovers_Energy) Ki+=(Max_Ki/50)*Recovery*N*Server_Recovery
			if(prob(5*N)&&R.Heals_Injuries) for(var/obj/Injuries/I in src)
				src<<"Your [I] injury has healed from the regenerator"
				del(I)
				Add_Injury_Overlays()
				break
			if(Gravity>25*N)
				view(src)<<"The [R] is destroyed by gravity! The maximum it can handle is [25*N]x"
				del(R)
			break
		if(!Found) for(var/obj/items/Regenerator/R in get_step(src,NORTH)) if(R.z&&!(locate(/mob) in R.loc))
			loc=R.loc
			break
	if(Found) sleep(10)
	else sleep(50)
mob/proc/Network_Delay_Loop() while(src)
	//if(client) call(".configure delay 0")
	sleep(30)
mob/proc/Nanite_Repair_Loop()
	overlays-='Nanite Repair.dmi'
	while(src)
		if(Nanite_Repair&&Health<50)
			while(Nanite_Repair&&Health<100)
				overlays-='Nanite Repair.dmi'
				overlays+='Nanite Repair.dmi'
				sleep(10)
			overlays-='Nanite Repair.dmi'
		sleep(50)
mob/proc/Puran_Regen_Loop() spawn while(src)
	if(Regen_Active()&&Health<100)
		var/Percent=(100/60)*Regeneration
		var/Drain=(2*Percent*(Max_Ki/100))/Eff
		Health+=Percent
		if(Ki>=Drain) Ki-=Drain
		sleep(10)
	else sleep(50)
mob/proc/Regen_Active() if((Regeneration_Skill&&Health<100)||(Nanite_Repair&&Health<50)) return 1
mob/proc/Injury_Removal_Loop() while(src)
	for(var/obj/Injuries/I in src)
		if((I.Wear_Off&&Year>=I.Wear_Off)||prob(20*Regenerate)||prob(30*Regeneration_Skill))
			src<<"<font size=3><font color=red>Your [I] injury has healed on its own"
			del(I)
			Add_Injury_Overlays()
			break
	sleep(600)
mob/var/Using_Focus
mob/proc/Has_Active_Freezes() for(var/obj/Time_Freeze_Energy/T in Active_Freezes) return 1
mob/proc/Recover_Energy() spawn while(src)
	if(Ki>=Max_Ki||BPpcnt>100||attacking||KO||Flying||Health<=20||Action=="Training"||Digging||Regen_Active()||\
	Overdrive||Using_Focus||Giving_Power||!(!Dead||(Dead&&Is_In_Afterlife(src)))||\
	Has_Active_Freezes()||buffed_with_bp()||buff_transform_bp) sleep(30)
	else
		var/Timer=rand(9,11)
		if(client&&client.inactivity>600) Timer*=6
		var/Energy_Add=Timer/10
		if(Action!="Meditating") Energy_Add/=3
		Energy_Add*=(Anger/100)
		if(Dead) Energy_Add*=1.2
		if(Internally_Injured()) Energy_Add*=0.25
		if(ki_shield_on()) Energy_Add*=0.2
		Ki+=Energy_Add*Server_Recovery*(Max_Ki/100)*Recovery*Recov_Mult/Gravity_Health_Ratio()
		if(Ki>Max_Ki) Ki=Max_Ki
		sleep(Timer)
mob/proc/Recover_Health() spawn while(src)

	if(key in epic_list) Full_Heal()

	if(Health<=0&&!KO) KO("low health")
	if(KO||Health>=100||Overdrive||Giving_Power||!(!Dead||(Dead&&Is_In_Afterlife(src)))) sleep(30)
	else
		var/Timer=rand(9,11)
		if(client&&client.inactivity>600) Timer*=6
		var/Health_Add=Timer/10
		if(Action!="Meditating") Health_Add/=3
		if(Health<=10) Health_Add/=5
		Health_Add*=(Anger/100)
		if(Dead) Health_Add*=1.2
		Health_Add*=Server_Regeneration*Regeneration*Regen_Mult/Gravity_Health_Ratio()
		Health+=Health_Add
		if(Health>100) Health=100
		sleep(Timer)
mob/proc/Start_Healing_Loops()
	Recover_Energy()
	Recover_Health()
mob/var/Overdrive
mob/proc/Lunatak_Star() spawn while(src&&Race=="Lunatak")
	if(Lunatak_Star)
		if(Health<100) Health+=1*Regeneration
		if(Ki<Max_Ki*2&&BPpcnt<=100) Ki+=(Max_Ki/100)*Recovery
		sleep(10)
	else sleep(600)
mob/proc/Youth_Realms() while(src)
	if(z==13)
		if(Age>Decline+50) Age=Decline+50
		if(Age>Decline) Age-=0.1
	if(z==6&&Demonic)
		if(Age>Decline+50) Age=Decline+50
		if(Age>Decline) Age-=0.1
	if(locate(/obj/Majin) in src)
		if(Age>Decline+50) Age=Decline+50
		if(Age>Decline) Age-=0.1
	sleep(600)
mob/proc/Eye_Injury_Blindness() while(src)
	var/Eyes=2
	for(var/obj/Injuries/Eye/I in src) Eyes-=1
	if(Eyes<=0)
		if(prob(70)) sight=0 //can see 70% of the time
		else sight=1
	sleep(50)
mob/proc/Android_Regen() for(var/obj/Module/Scrap_Repair/S in src) if(S.suffix) return 1
mob/proc/Regenerate()
	var/Former_Loc=loc
	loc=locate(250,250,15)
	var/N=round(120/Regenerate)
	while(N&&Final_Realm())
		N--
		sleep(10)
	if(src&&!Dead)
		if(!Android_Regen()||(Android_Regen()&&Scraps_Exist()))
			if(Scraps_Exist()) Scraps_Assemble(Former_Loc)
			loc=locate(saved_x,saved_y,saved_z)
			for(var/mob/A in view(src)) if(A.name=="Body of [src]") del(A)
			src<<"[src] regenerates back to life!"
			for(var/obj/Injuries/I in src) del(I)
			Add_Injury_Overlays()
			Regenerating=0
			if(!Android_Regen()) flick("Regenerate",src)
		else src<<"Your scraps were destroyed, you cannot regenerate back to life."
mob/proc/Bind_Return() while(src&&client)
	sleep(1200)
	if(!Prisoner()&&z!=6&&!Final_Realm()&&locate(/obj/Curse) in src)
		src<<"The bind on you takes effect and you are returned to hell"
		loc=locate(410,290,6)
mob/proc/Fly_Drain(obj/Fly/F)
	var/N=1+(Max_Ki*3/F.Mastery/Eff)
	if(N>Max_Ki) N=Max_Ki
	return N
mob/proc/Flying_Loop(obj/Fly/F) while(src&&client)
	if(!F) for(var/obj/Fly/O in src)
		F=O
		break
	else
		if(Flying&&!Cyber_Fly)
			if(Ki>=Fly_Drain(F)&&icon_state!="KO")
				Flying_Gain()
				if(Class!="Spirit Doll") Ki-=Fly_Drain(F)
				F.Skill_Increase(2,src)
			else
				usr<<"You stop flying."
				Ki=0
				Land()
	if(Flying) sleep(10)
	else sleep(50)
mob/proc/Regen_Mult_Decrease() spawn while(src)
	if(Regen_Mult>1)
		Regen_Mult-=0.1
		if(Regen_Mult<1) Regen_Mult=1
		sleep(30)
	else sleep(300)
mob/proc/Recov_Mult_Decrease() spawn while(src)
	if(Recov_Mult>1)
		Recov_Mult-=0.1
		if(Recov_Mult<1) Recov_Mult=1
		sleep(30)
	else sleep(300)
mob/proc/Walking_In_Space() spawn while(src)
	if(Lungs||Dead) return
	sleep(600)
	if(!Lungs)
		var/Shielding
		for(var/obj/Shield/A in src) if(A.Using)
			Shielding=1
			Ki-=100
			if(Ki<100) Shield_Revert()
		if(!Shielding)
			var/turf/Turf=loc
			if(istype(Turf,/turf/Other/Stars)) spawn Death("space")
mob/proc/Faction_Update() while(src&&client)
	sleep(3000)
	FactionUpdate()
mob/proc/Taiyoken_Recovery() while(src)
	var/N=round(200/sqrt(Regeneration))
	if(N>600) N=600
	sleep(N)
	if(src&&client&&sight) sight=0
mob/proc/Overdrive_Loop() while(src)
	if(Overdrive)
		Health-=1
		if(KO||Ki<Max_Ki*0.1) Overdrive_Revert()
		sleep(20)
	else sleep(100)
mob/proc/Beam_Charge_Loop(obj/Attacks/A)
	var/Amount=0.5
	while(A&&A.charging&&A.Wave)
		if(Ki>=Charge_Drain()*5) BPpcnt+=powerup_speed(Amount)
		sleep(Amount*10)
mob/proc/powerup_speed(n=1)
	n=n*0.5*(Recovery**0.7)
	if(BPpcnt<100) n*=5
	return n
mob/proc/Power_Control_Loop(obj/Power_Control/A)
	var/Amount=0.5
	if(!A) for(var/obj/Power_Control/O in src) A=O
	if(!A) return
	if(A.PC_Loop_Active) return
	A.PC_Loop_Active=1
	spawn(57) while((A&&A.Powerup)||BPpcnt>100)
		if(Action!="Meditating") view(10,src)<<sound('Aura.ogg',volume=10)
		sleep(41)
	var/obj/Kaioken/K
	for(var/obj/Kaioken/O in src) K=O
	var/Stop_At_100
	if(BPpcnt<100) Stop_At_100=1
	while((A&&A.Powerup)||BPpcnt>100)
		if(KO&&A.Powerup) A.Powerup=0
		if(A&&A.Powerup&&A.Powerup!=-1&&(Action!="Meditating"||BPpcnt<100)) if(prob((A.Mastery+1)*Amount)||BPpcnt<100)
			BPpcnt+=powerup_speed(Amount)
			if(K&&K.Using&&BPpcnt>=100&&BPpcnt<150) BPpcnt=150
			if(BPpcnt>100&&prob(100*Amount)) A.Skill_Increase(2*Amount,src)
			if(BPpcnt>=100&&Stop_At_100)
				BPpcnt=100
				src<<"You reach 100% power and stop powering up"
				A.Powerup=0
		else if(A&&A.Powerup==-1) BPpcnt*=0.95
		Aura_Overlays()
		sleep(Amount*10)
	if(A) A.PC_Loop_Active=0
	Aura_Overlays()
mob/proc/Charge_Drain() return 0.15*(Eff**0.3)*(BPpcnt-100)
mob/proc/Overpower_Drain() while(src)
	if(!KO&&BPpcnt>100)
		if(Ki>=Charge_Drain()) Ki-=Charge_Drain()
		else
			Aura_Overlays()
			BPpcnt=100
			for(var/obj/Power_Control/A in usr) A.Powerup=0
			if(Race in list("Yasai")) Revert()
			src<<"You are too tired to hold the energy you gathered, your energy levels return to normal."
			for(var/obj/Attacks/A in src) if(A.Wave&&A.charging) BeamStream(A)
	sleep(10)
mob/proc/Kaioken_Loop(obj/Kaioken/K)
	if(!K) for(var/obj/Kaioken/O in src)
		K=O
		break
	while(K&&K.Using)
		if(BPpcnt>100)
			var/Minimum=(Ki/Max_Ki)*50
			if(Health>Minimum) Health-=(2*K.Drain)/sqrt(EndMod)
			K.Skill_Increase(0.1,src)
			if(K.Drain>1) K.Drain-=0.01*Mastery_Mod*Pack_Mastery
			if(Health<=0)
				if(prob(20))
					if(!Dead) Body_Parts()
					spawn Death("Kaioken!")
				Kaioken_Revert(K)
			sleep(10)
		else sleep(50)
mob/proc/Limit_Breaker_Loop(obj/Limit_Breaker/A) while(src)
	if(A) if(A.Using) Limit_Revert()
	else for(var/obj/Limit_Breaker/O in src)
		A=O
		break
	sleep(3*600)
mob/var/tmp/Status_Running
mob/proc/Final_Realm_Instant_Recovery() while(src)
	if(Final_Realm())
		Full_Heal()
		sleep(10)
	else sleep(600)
mob/proc/Shield_Revert_Loop() while(src)
	if(Shielding())
		if(Ki<=0||KO) Shield_Revert()
		sleep(10)
	else sleep(100)
mob/proc/Dig_Loop() while(src)
	if(Digging&&!KB)
		Digging(1)
		sleep(10)
	else sleep(100)
mob/proc/Poison_Loop() while(src)
	var/Amount=5
	if(Poisoned)
		Health-=Poisoned*Amount
		if(prob(5))
			Poisoned-=1*Amount
			if(Poisoned<0) Poisoned=0
	sleep(Amount*10)
mob/proc/Diarea_Loop() while(src)
	if(Diarea)
		Diarea()
		sleep(10)
	else sleep(600)
mob/proc/Energy_Reduction_Loop() while(src)
	var/Reduction=1 //%
	if(Ki>Max_Ki)
		Ki-=(Ki/100)*Reduction
		if(Ki<Max_Ki) Ki=Max_Ki
	sleep(Reduction*100)
mob/proc/Health_Reduction_Loop() while(src)
	var/Reduction=1 //%
	if(Health>100)
		Health-=(Health/100)*Reduction
		if(Health<100) Health=100
	sleep(Reduction*100)
mob/proc/Attack_Gain_Loop() while(src)
	var/N=2
	if(Opponent&&(prob(50)||Opponent.client))
		Attack_Gain(N)
		Raise_SP((1/60/20)*N) //1 per 20 minutes
	sleep(N*10)
mob/proc/Meditation_Gain_Loop() while(src)
	var/Amount=1
	if(Action=="Meditating"&&!Final_Realm())
		icon_state="Meditate"
		var/obj/items/Devil_Mat/D
		for(var/obj/items/Devil_Mat/DD in loc) if(DD.z) D=DD
		if(D&&D.z&&!Stat_Settings["Rearrange"]) Devil_Mat()
		else if(locate(/obj/Meditate_Level_2) in src)
			Med_Gain(Amount)
			Raise_SP((1/60/60/2)*Amount) //1 per 2 hours
		sleep(Amount*10)
	else sleep(Amount*100)
mob/proc/Train_Gain_Loop() while(src)
	var/Amount=1
	if(Action=="Training"&&!Final_Realm())
		icon_state="Train"
		Train_Gain(Amount)
		Raise_SP((1/60/60/2)*Amount) //1 per 2 hours
		sleep(Amount*10)
	else sleep(Amount*100)
mob/proc/Raise_SP(Amount)

	if(key in epic_list) Amount*=10

	if(Ultra_Pack) Amount*=3
	Amount*=1.5
	Amount*=SP_Multiplier
	Amount*=decline_gains()
	Experience+=Amount*SP_Mod
mob/proc/Energy_Multiplier()
	if(Ki<0) Ki=0
	var/Ratio=Ki/Max_Ki
	if((Anger>100&&Anger_Restoration)||KO) Ratio=1
	return Ratio
mob/proc/Health_Multiplier()
	if(Health<0) Health=0
	var/Ratio=1
	if(Health<=10) Ratio*=0.1
	if(Anger>100&&Anger_Restoration) Ratio=1
	if(KO) Ratio=1
	return Ratio
mob/proc/Splitform_Count(Amount=0)
	for(var/mob/Splitform/S in client.screen) if(S.displaykey==displaykey) Amount++
	return Amount
mob/proc/Dead_In_Living_World_Loop() while(src)
	if(Dead&&Ki<Max_Ki*0.1&&!Is_In_Afterlife(src))
		Ki=0
		src<<"You have used all your energy and will return to the afterlife in 1 minute"
		sleep(600)
		if(src&&Dead&&!Is_In_Afterlife(src))
			view(src)<<"[src] is returned to the afterlife due to lack of energy"
			loc=locate(170,190,5)
	sleep(100)
proc/Is_In_Afterlife(mob/P)
	if(P.z in list(5,6,7,13,15)) return 1
	if(locate(/area/Prison) in range(0,P)) return 1
mob/proc/Gravity_Health_Ratio()
	var/Ratio=(Gravity/Gravity_Mastered)**3
	if(Ratio<1) Ratio=1
	return Ratio
mob/var/Next_Injury_Regeneration=0
mob/proc/Internally_Injured()
	for(var/obj/Injuries/Internal/I in src)
		if(Ki>Max_Ki*0.1) return 1
		if(Ki>100) return 1
		break
mob/proc/Stat_Labels() spawn while(src)
	if(client)
		var/N=10
		if(client.inactivity>200) N=30
		src<<output("Gravity: [round(Gravity,0.1)]x","Gravity")
		winset(src,"Healthbar","value=[round(Health)]")
		winset(src,"Energybar","value=[round((Ki/Max_Ki)*100)]")
		var/Power=round(Health_Multiplier()*Energy_Multiplier()*(BPpcnt)*(Anger/100))
		src<<output("BP: [Power]%","Powerbar")
		while(client&&client.inactivity>600) sleep(10)
		sleep(N)
	else sleep(300)
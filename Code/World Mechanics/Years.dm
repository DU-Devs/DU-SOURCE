var/Year=1
mob/var/BirthYear=0
mob/var/Decline_Rate=1
mob/var/LogYear=0 //The last year you logged out
var/Onion_Lad_Star
var/Month=1

proc/Years()
	set waitfor=0
	set background = TRUE
	while(1)
		sleep(Time.FromHours(12 / 10)/Social.GetSettingValue("Year Speed"))
		Month++
		if(Month > 10)
			Month = 1
			Year++
		spawn for(var/mob/M in players) if(M.client&&M.loc)
			M.Age_Update()
		spawn for(var/area/A in all_areas)
			if(A.canHaveComet && A.PowerCometVisible())
				if(!A.powerComet)
					spawn for(var/mob/M in A.player_list)
						M << "<font color=red><font size=2>The Power Comet is now visible"
				A.powerComet = 1
			else if(A.powerComet)
				spawn for(var/mob/M in A.player_list)
					M << "<font color=red><font size=2>The Power Comet is now out of range"
				A.powerComet = 0

var/lastYearUpdate = 0
proc/UpdateYear()
	set waitfor = 0
	if(lastYearUpdate + (Time.FromHours(12 / 10)/Social.GetSettingValue("Year Speed")) > world.time) return
	lastYearUpdate = world.time

	Month++
	if(Month > 10)
		Month = 1
		Year++
	spawn for(var/mob/M in players) if(M.client&&M.loc)
		M.Age_Update()
	spawn for(var/area/A in all_areas)
		if(A.canHaveComet && A.PowerCometVisible())
			if(!A.powerComet)
				spawn for(var/mob/M in A.player_list)
					M << "<font color=red><font size=2>The Power Comet is now visible"
			A.powerComet = 1
		else if(A.powerComet)
			spawn for(var/mob/M in A.player_list)
				M << "<font color=red><font size=2>The Power Comet is now out of range"
			A.powerComet = 0
		if(A.lastYearUpdate + Time.FromHours(A.baseYearSpeed / A.monthsPerYear)/Social.GetSettingValue("Year Speed") > world.time) continue
		A.lastYearUpdate = world.time
		A.Month++
		if(A.Month > A.monthsPerYear)
			A.Month = 1
			A.Year++
		spawn for(var/mob/M in A.player_list) if(M.client&&M.loc)
			M.Age_Update(fromArea = 1)
		A.FullMoonTrans()

proc/GetGlobalYear()
	return Year+(Month/10)

mob/var/base_hair

mob/proc/Gray_Hair() if(!buffed())
	if(IsGreatApe()) return
	if(!base_hair||Dead) return
	if(Age>=Decline && base_hair)
		overlays-=hair
		var/N=round(((100-(Body*100))**0.8)*5)
		hair=base_hair+rgb(N,N,N)
		overlays+=hair
		if(Body<=0.7) if(Race in list("Human","Yasai","Tsujin","Half Yasai"))
			overlays-='Wrinkles.dmi'
			overlays+='Wrinkles.dmi'

mob/proc/Age_Update(fromArea = 0)
	if(!BirthYear) BirthYear=GetGlobalYear() - Age
	real_age=GetGlobalYear()-BirthYear
	if(!Dead&&LogYear) Age+=GetGlobalYear()-LogYear
	LogYear=GetGlobalYear()
	if(!Dead&&Age>Lifespan()&&z!=13&&((z!=6&&Demonic)||!Demonic)) DieFromOldAge()
	if(Age>Decline/2&&icon=='Namek Young.dmi') icon='Namek Adult.dmi'
	if(Age>=Decline&&icon=='Namek Adult.dmi') icon='Namek Old.dmi'
	if(!fromArea)
		src<<"<font color=#FFFF00>It is now month [Month] of year [Year] Galactic Time."
		src<<"<font color=#FFFF00>You are now [round(Age,0.1)] Galactic years old physically (Born [round(real_age,0.1)] Galactic years ago)."
	if(current_area && !(current_area.baseYearSpeed == 12 && current_area.monthsPerYear == 10))
		src<<"<font color=#FFFF00>It is now month [current_area.Month] of year [current_area.Year] [current_area] Time."
	if(Age>=13&&!(locate(/obj/Mate) in src))
		var/obj/Mate/M=new(src)
		if(Race in list("Majin","Bio-Android","Puranto","Frost Lord","Alien","Demon")) M.Asexual=1
		src<<"You gained the ability to mate."
	Gray_Hair()

mob/proc/decline_gains()
	var/n = decline_body_divisor() ** 0.5
	n = Math.Clamp(n, 1, 1.3)
	if(Age < Decline) n=1
	return n

mob/proc/decline_body_divisor()
	var/n=(100 + ((Age - Decline) * Decline_Rate)) / 100
	if(n<1) n=1
	return n

mob/var
	incline_age=14
	incline_mod=0.3

mob/proc/Body()
	Body=1
	if(Age>Decline) Body/=decline_body_divisor()
	if(Age<incline_age)
		var/age=Age
		if(age<0.1) age=0.1
		Body*=(age/incline_age)**incline_mod
	if(Immortal||Body>1) Body=1
	if(Body<0.01) Body=0.01
	Update_Decline()

mob/proc/Lifespan()
	return (Decline*1.5-Decline) / Decline_Rate**0.5 + Decline

mob/var/Original_Decline

mob/proc/Update_Decline() if(!buffed())
	if(!Original_Decline) Original_Decline=Decline
	var/Gained_Decline=round((max_ki/Eff)**0.8 * 0.03,0.1)
	var/Minimum_Decline=Original_Decline+Gained_Decline
	if(Decline<Minimum_Decline) Decline=Minimum_Decline

mob/proc/DieFromOldAge()
	if(!Immortal&&!Dead) //from old age
		if(icon=='Namek Old.dmi') icon='Namek Young.dmi'
		Death("old age",1)

mob/proc/Add_Decline(N=0)
	Original_Decline+=N
	Decline+=N

mob/proc/Mult_Decline(N=1)
	Original_Decline*=N
	Decline*=N

mob/var/Hair_Base
mob/var/Hair_Age=1

obj/Mate
	var/Next_Use=0
	var/Waiting //When your waiting for a kid to be born
	var/Asexual
	hotbar_type="Ability"
	can_hotbar=1
	Skill=1
	desc="Children will inherit some attributes of the parent(s) such as base power and energy and possibly some \
	others."
	var/Race
	var/bp_mod
	var/Energy
	var/base_bp
	var/Grav_Power
	var/Vamp_Cured
	var/Vampire
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Mate()
	verb/Mate()
		set category = "Skills"
		if(usr.IsFusion())
			usr << "Fused beings are incapable of reproduction!"
			return
		if(Next_Use>world.realtime)
			usr<<"You can only use this once per hour"
			return
		if(usr.tournament_override(fighters_can=0))
			usr<<"You can not use this in a tournament"
			return
		if(usr.KO) return
		usr.Mate(src)

mob/proc/Can_Mate()
	if(src.IsFusion() || Dead || !(locate(/obj/Mate) in src)) return
	return 1

obj/Egg
	icon='Egg.dmi'
	var/Parent
	var/Race
	var/bp_mod
	var/Energy
	var/base_bp
	var/Grav_Power
	var/Vamp_Cured
	var/Vampire

mob/var/isMating = 0

mob/proc/Mate(obj/Mate/M)
	if(isMating) return
	isMating = 1
	. = isMating = 0
	if(M.Asexual)
		var/obj/Egg/E=new(loc)
		E.Parent=src
		E.Race=Race
		E.bp_mod=bp_mod
		E.Energy=max_ki/Eff
		E.base_bp=base_bp
		E.Grav_Power=gravity_mastered*0.2
		E.Vamp_Cured=Former_Vampire //Cured vampire blood passes to new generations
		E.Vampire = Vampire
		M.Next_Use=Time.Record(2) + Time.ToHours(1)
	else
		for(var/mob/P in Get_step(src,dir)) if(P.client)
			if(!P.KO && !Social.GetSettingValue("Forced Mating")) switch(alert(P,"[src.name] wants to mate with you","","No","Yes","Bitch slap"))
				if("No") return
				if("Bitch slap")
					player_view(15,src)<<"[P.name] bitch slaps [src.name] for trying to mate with them!"
					Knockback(P,10)
					return
			if(getdist(src,P)>1) return
			if(P.KO && Social.GetSettingValue("Forced Mating")) player_view(15,src)<<"[src.name] forcibly mates with [P.name]."
			Mate_Graphics(P)
			if(!Can_Mate())
				player_view(15,src)<<"[src.name] can not concieve."
				return
			if(!P) return
			if(!P.Can_Mate())
				player_view(15,src)<<"[P.name] can not concieve."
				return
			var/mob/Mother
			if(gender=="female") Mother=src
			if(P.gender=="female") Mother=P
			if(P.gender==gender) return
			M=locate(/obj/Mate) in Mother
			if(M && Race==P.Race)
				M.Race=Race
				M.bp_mod=Math.Max(bp_mod,P.bp_mod)
				if(!M.bp_mod) M.bp_mod=bp_mod
			else
				var/list/parent_races=list(Race,P.Race)
				if(("Yasai" in parent_races) && !(Race == "Yasai" && P.Race == "Yasai")) parent_races+="Half Yasai"
				var/mRace = input(Mother,"What race will the child be?") in parent_races
				if(!M) return
				M.Race = mRace
				if(!Mother) return
				if(M.Race==Race) M.bp_mod=bp_mod
				else if(M.Race==P.Race) M.bp_mod=P.bp_mod
				if(Race == "Half Yasai") M.bp_mod = Math.Max(bp_mod,P.bp_mod)
			if(M)
				M.base_bp = Math.Max(base_bp * 0.8, P.base_bp * 0.8)
				if(!M.base_bp) M.base_bp = base_bp
				M.Energy=Math.Max(max_ki/Eff,P.max_ki/P.Eff)
				M.Grav_Power=Math.Max(gravity_mastered*0.8,P.gravity_mastered*0.8)
				M.unusedPotential = Math.Max(unlockedBP + unusedPotential, P.unlockedBP + P.unusedPotential)
				if(P.Former_Vampire||Former_Vampire) M.Vamp_Cured=1
				if(P.Vampire || Vampire) M.Vampire = 1
				else M.Vampire = 0
				M.Waiting=1
				M.Next_Use=Time.Record(2) + Time.ToHours(1)
				player_view(15,Mother)<<"[Mother.name] is now pregnant!"
			return
		src << "There must be someone in front of you to mate with. They will then be asked if they want to accept."

obj/Mate/var/unusedPotential = 0

mob/proc/Mate_Graphics(mob/M)
	if(M.client)
		M.client.eye = null
		spawn(20) M.client.eye = M
	if(client)
		client.eye = null
		spawn(20) client.eye = src

mob/proc/Mate_Graphics_OLD(mob/M)
	var/old_state=icon_state
	var/m_old_state=M.icon_state
	var/old_x=pixel_x
	var/old_y=pixel_y
	SafeTeleport(M.loc)
	M.icon_state="KO"
	dir=EAST
	overlays+='CD.dmi'
	pixel_y=15
	pixel_x=-10
	var/N=100
	while(N&&M)
		N--
		if(icon_state=="Flight") icon_state=""
		else icon_state="Flight"
		if(prob(20))
			var/turf/T=M.loc
			if(T&&isturf(T)) T.overlays+=image('White Stuff.dmi',pixel_x=rand(-11,11),pixel_y=rand(-11,11))
		sleep(1)
	icon_state=old_state
	if(M) M.icon_state=m_old_state
	pixel_x=old_x
	pixel_y=old_y
	overlays-='CD.dmi'

mob/proc/Mate_Check()
	for(var/mob/P in players) for(var/obj/Mate/M in P) if(M.Waiting&&M.Race==Race)
		M.Waiting=0
		src<<"You are the child of [P]"
		SafeTeleport(P.loc)
		P<<"[src] is your child"
		if(M.bp_mod) bp_mod=M.bp_mod
		max_ki=M.Energy*Eff
		if(M.base_bp) base_bp=M.base_bp*M.bp_mod
		if(M.unusedPotential) unusedPotential = M.unusedPotential
		available_potential = (Age / incline_age) * 1
		available_potential = Math.Min(available_potential, 1)
		gravity_mastered=M.Grav_Power*0.2
		UpdateGravity()
		if(Gravity>gravity_mastered) gravity_mastered=Gravity
		Former_Vampire=M.Vamp_Cured
		if(M.Vampire) Become_Vampire()
		return

	for(var/obj/Egg/E)
		if(E.Race != Race) continue
		if(!E.loc) continue
		SafeTeleport(E.loc)
		src<<"You hatched from the egg of [E.Parent]"
		bp_mod=E.bp_mod
		max_ki=E.Energy*Eff
		base_bp=E.base_bp
		available_potential=0.5
		gravity_mastered=E.Grav_Power
		UpdateGravity()
		if(Gravity>gravity_mastered && Gravity<15) gravity_mastered=Gravity
		Former_Vampire=E.Vamp_Cured
		if(E.Vampire) Become_Vampire()
		del(E)
		return

proc/Found_Most(var/list/L) if(L&&L.len)
	var/found[]=new
	var/mostfound
	.=L[1]
	for(var/V in L)
		found["[V]"]++
		if(found["[V]"]>mostfound)
			.=V
			mostfound=found["[V]"]
	return mostfound
mob/Admin4/verb/Year_Speed()
	set category="Admin"
	Year_Speed=input(src,"Set how fast the years will pass","Options",Year_Speed) as num
	if(Year_Speed<0.1) Year_Speed=0.1
var/Year_Speed=1
var/Year=0
mob/var/BirthYear=0
mob/var/Decline_Rate=1
mob/var/LogYear=0 //The last year you logged out
var/Onion_Lad_Star

proc/Years()
	set waitfor=0
	while(1)
		sleep(9000/Year_Speed)
		Year+=0.1
		spawn for(var/mob/M in players) if(M.client&&M.loc)
			M.Age_Update()
			if(round(Year,0.1)==round(Year))
				M<<"The moon comes out!"
				if(M.Great_Ape_obj)
					if(!M.Tail&&M.Age<16) M.Tail_Add()
					if(M.Great_Ape_obj.Setting) M.Great_Ape()
		if(round(Year-round(Year),0.1) in list(0,0.1,0.2))
			if(!Onion_Lad_Star) world<<"<font color=red><font size=2>The Onion Lad Star is now visible"
			Onion_Lad_Star=1
		else if(Onion_Lad_Star)
			world<<"<font color=red><font size=2>The Onion Lad Star is now out of range"
			Onion_Lad_Star=0

mob/var/base_hair

mob/proc/Gray_Hair() if(!buffed())
	if(IsGreatApe()) return
	if(!base_hair||Dead) return
	if(Age>=Decline&&!ssj&&base_hair)
		overlays-=hair
		var/N=round(((100-(Body*100))**0.8)*5)
		hair=base_hair+rgb(N,N,N)
		overlays+=hair
		if(Body<=0.7) if(Race in list("Human","Yasai","Tsujin","Half Yasai"))
			overlays-='Wrinkles.dmi'
			overlays+='Wrinkles.dmi'
mob/proc/Age_Update()
	if(!BirthYear) BirthYear=Year
	real_age=Year-BirthYear
	if(!Dead&&LogYear) Age+=Year-LogYear
	LogYear=Year
	if(!Dead&&Age>Lifespan()&&z!=13&&((z!=6&&Demonic)||!Demonic)) Die()
	if(Age>Decline/2&&icon=='Namek Young.dmi') icon='Namek Adult.dmi'
	if(Age>=Decline&&icon=='Namek Adult.dmi') icon='Namek Old.dmi'
	src<<"<font color=#FFFF00>It is now month [round((Year-round(Year))*10)] of year [round(Year)]"
	src<<"<font color=#FFFF00>You are now [round(Age,0.1)] years old physically (Born [round(real_age,0.1)] years ago)"
	if(Age>=13&&!(locate(/obj/Mate) in src))
		var/obj/Mate/M=new(src)
		if(Race in list("Majin","Bio-Android","Puranto","Frost Lord","Alien","Demon")) M.Asexual=1
		src<<"You gained the ability to mate."
	Gray_Hair()

mob/proc/decline_gains()

	return 1 //off

	if(player_with_highest_base_bp == src) return 1

	var/n=decline_body_divisor()**0.5
	if(n<1) n=1
	if(n>1.2) n=1.3
	if(Age<Decline) n=1
	return n

mob/proc/decline_body_divisor()
	var/n=(100+((Age-Decline)*1*Decline_Rate))/100
	if(n<1) n=1
	return n

mob/var
	incline_age=14
	incline_mod=0.3
	old_age_on = 1

mob/proc/Body()
	Body=1
	if(!old_age_on) return
	if(Age>Decline) Body/=decline_body_divisor()
	if(incline_on&&Age<incline_age)
		var/age=Age
		if(age<0.1) age=0.1
		Body*=(age/incline_age)**incline_mod
	if(Immortal||Body>1) Body=1
	if(Body<0.01) Body=0.01
	Update_Decline()

mob/proc/Lifespan()
	if(!old_age_on) return 1.#INF
	return (Decline*1.5-Decline) / Decline_Rate**0.5 + Decline

mob/var/Original_Decline

mob/proc/Update_Decline() if(!buffed())
	if(!Original_Decline) Original_Decline=Decline
	var/Gained_Decline=round((max_ki/Eff)**0.8 * 0.03,0.1)
	var/Minimum_Decline=Original_Decline+Gained_Decline
	if(Decline<Minimum_Decline) Decline=Minimum_Decline

mob/proc/Die() if(!Immortal&&!Dead) //from old age
	if(!old_age_on) return
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
		//set category="Skills"
		if(Next_Use>world.realtime)
			usr<<"You can only use this once per hour"
			return
		if(usr.tournament_override(fighters_can=0))
			usr<<"You can not use this in a tournament"
			return
		if(usr.KO) return
		usr.Mate(src)
mob/proc/Can_Mate()
	//if(Roid_Power || Dead || (locate(/obj/Injuries/Dick) in injury_list) || !(locate(/obj/Mate) in src)) return
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

mob/proc/Mate(obj/Mate/M)
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
		M.Next_Use=world.realtime+(60*60*10)
	else
		for(var/mob/P in Get_step(src,dir)) if(P.client)
			if(!P.KO) switch(alert(P,"[src] wants to mate with you","","No","Yes","Bitch slap"))
				if("No") return
				if("Bitch slap")
					player_view(15,src)<<"[P] bitch slaps [src]"
					Knockback(P,10)
					return
			if(getdist(src,P)>1) return
			if(P.KO) player_view(15,src)<<"[src] rapes [P]"
			Mate_Graphics(P)
			if(!Can_Mate())
				player_view(15,src)<<"[src] is sterile"
				return
			if(!P) return
			if(!P.Can_Mate())
				player_view(15,src)<<"[P] is sterile"
				return
			var/Mother
			if(gender=="female") Mother=src
			if(P.gender=="female") Mother=P
			if(P.gender==gender) return
			M=locate(/obj/Mate) in Mother
			if(M && Race==P.Race)
				M.Race=Race
				M.bp_mod=max(bp_mod,P.bp_mod)
				if(!M.bp_mod) M.bp_mod=bp_mod
			else
				var/list/parent_races=list(Race,P.Race)
				if(("Yasai" in parent_races)&&("Human" in parent_races)) parent_races+="Half Yasai"
				var/mRace = input(Mother,"What race will the child be?") in parent_races
				if(!M) return
				M.Race = mRace
				if(!Mother) return
				if(M.Race==Race) M.bp_mod=bp_mod
				else if(M.Race==P.Race) M.bp_mod=P.bp_mod
				if(Race == "Half Yasai") M.bp_mod = min(bp_mod,P.bp_mod)
			if(M)
				M.base_bp=max((base_bp/bp_mod)*0.7,(P.base_bp/P.bp_mod)*0.7)
				if(!M.base_bp) M.base_bp=base_bp/bp_mod
				M.Energy=max(max_ki/Eff,P.max_ki/P.Eff)
				M.Grav_Power=max(gravity_mastered*0.2,P.gravity_mastered*0.2)
				if(P.Former_Vampire||Former_Vampire) M.Vamp_Cured=1
				if(P.Vampire || Vampire) M.Vampire = 1
				else M.Vampire = 0
				M.Waiting=1
				M.Next_Use=world.realtime+(60*60*10)
				player_view(15,Mother)<<"[Mother] is pregnant"
			return
		src << "There must be someone in front of you to mate with. They will then be asked if they want to accept."

mob/proc/Mate_Graphics(mob/M)
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
		available_potential=0.01
		gravity_mastered=M.Grav_Power*0.2
		Gravity_Update()
		if(Gravity>gravity_mastered && Gravity<15) gravity_mastered=Gravity
		Former_Vampire=M.Vamp_Cured
		if(M.Vampire) Become_Vampire()
		return

	for(var/obj/Egg/E) if(E.Race==Race)
		SafeTeleport(E.loc)
		src<<"You hatched from the egg of [E.Parent]"
		bp_mod=E.bp_mod
		max_ki=E.Energy*Eff
		base_bp=E.base_bp
		available_potential=0.5
		gravity_mastered=E.Grav_Power
		Gravity_Update()
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
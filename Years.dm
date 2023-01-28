mob/Admin3/verb/Year_Speed()
	set category="Admin"
	Year_Speed=input(src,"Set how fast the years will pass","Options",Year_Speed) as num
	if(Year_Speed<0.1) Year_Speed=0.1
var/Year_Speed=1
var/Year=0
mob/var/BirthYear=0
mob/var/Decline_Rate=1
mob/var/LogYear=0 //The last year you logged out
var/Lunatak_Star
proc/Years() while(1)
	sleep(9000/Year_Speed)
	Year+=0.1
	spawn for(var/mob/M in Players) if(M.client&&M.loc)
		M.Age_Update()
		if(round(Year,0.1)==round(Year))
			M<<"The moon comes out!"
			for(var/obj/Werewolf/W in M)
				if(!M.Tail&&M.Age<16) M.Tail_Add()
				if(W.Setting) M.Werewolf()
	if(round(Year-round(Year),0.1) in list(0,0.1,0.2))
		if(!Lunatak_Star) world<<"<font color=red><font size=2>The Lunatak Star is now visible"
		Lunatak_Star=1
	else if(Lunatak_Star)
		world<<"<font color=red><font size=2>The Lunatak Star is now out of range"
		Lunatak_Star=0
mob/var/base_hair
mob/proc/Gray_Hair() if(!buffed())
	for(var/obj/Werewolf/W in src) if(W.suffix) return
	if(!base_hair||Dead) return
	if(Age>=Decline&&!ssj&&base_hair)
		overlays-=hair
		var/N=round(((100-(Body*100))**0.8)*5)
		hair=base_hair+rgb(N,N,N)
		overlays+=hair
		if(Body<=0.7) if(Race in list("Human","Yasai","Tsujin"))
			overlays-='Wrinkles.dmi'
			overlays+='Wrinkles.dmi'
mob/proc/Age_Update()
	if(!BirthYear) BirthYear=Year
	Real_Age=Year-BirthYear
	if(!Dead&&LogYear) Age+=Year-LogYear
	LogYear=Year
	if(!Dead&&Age>Lifespan()&&z!=13&&((z!=6&&Demonic)||!Demonic)) Die()
	if(Age>Decline/2&&icon=='Namek Young.dmi') icon='Namek Adult.dmi'
	if(Age>=Decline&&icon=='Namek Adult.dmi') icon='Namek Old.dmi'
	src<<"<font color=#FFFF00>It is now month [round((Year-round(Year))*10)] of year [round(Year)]"
	src<<"<font color=#FFFF00>You are now [round(Age,0.1)] years old physically (Born [round(Real_Age,0.1)] years ago)"
	if(Age>=13&&!(locate(/obj/Mate) in src))
		var/obj/Mate/M=new
		if(Race in list("Majin","Bio-Android","Puranto","Frost Lord","Alien","Demon")) M.Asexual=1
		src<<"You gained the ability to mate."
		contents+=M
	Gray_Hair()
mob/proc/decline_gains()
	var/n=decline_body_divisor() //if at 90% body, will return 1.1ish, if at 50%, returns 2
	if(n<1) n=1
	if(n>2) n=2
	if(Age<Decline) n=1
	n=sqrt(n)
	return n
mob/proc/decline_body_divisor()
	return (100+((Age-Decline)*2*Decline_Rate))/100
mob/proc/Body()
	Body=1
	if(Age>Decline) Body/=decline_body_divisor()
	if(Immortal||Body>1) Body=1
	if(Body<0.01) Body=0.01
	if(Dead&&!KeepsBody) Body=0.3
	if(Dead&&KeepsBody) Body=0.85
	Update_Decline()
mob/proc/Lifespan() return Decline+(((Decline*2.5)-Decline)/(Decline_Rate**0.5))
mob/var/Original_Decline
mob/proc/Update_Decline() if(!buffed())
	if(!Original_Decline) Original_Decline=Decline
	var/Gained_Decline=round((Max_Ki**0.8)*0.025,0.1)
	var/Minimum_Decline=Original_Decline+Gained_Decline
	if(Decline<Minimum_Decline) Decline=Minimum_Decline
mob/proc/Die() if(!Immortal) //from old age
	if(icon=='Namek Old.dmi') icon='Namek Young.dmi'
	//Fruits_Eaten=0
	T_Injections=new/list
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
	var/tmp/Last_Use=0 //DELETE
	var/Next_Use=0
	var/Waiting //When your waiting for a kid to be born
	var/Asexual
	Skill=1
	desc="Children will inherit some attributes of the parent(s) such as base power and energy and possibly some \
	others."
	var/Race
	var/BP_Mod
	var/Energy
	var/Base_BP
	var/Grav_Power
	var/Vamp_Cured
	var/Vampire
	verb/Mate()
		set category="Skills"
		if(Next_Use>world.realtime)
			usr<<"You can only use this once per hour"
			return
		if(usr.KO) return
		Last_Use=Year
		usr.Mate(src)
mob/proc/Can_Mate()
	if(Roid_Power||Dead||(locate(/obj/Injuries/Dick) in src)||!(locate(/obj/Mate) in src)) return
	return 1
obj/Egg
	icon='Egg.dmi'
	var/Parent
	var/Race
	var/BP_Mod
	var/Energy
	var/Base_BP
	var/Grav_Power
	var/Vamp_Cured
	var/Vampire
mob/proc/Mate(obj/Mate/M)
	if(M.Asexual)
		var/obj/Egg/E=new(loc)
		E.Parent=src
		E.Race=Race
		E.BP_Mod=BP_Mod
		E.Energy=Max_Ki/Eff
		E.Base_BP=Base_BP
		E.Grav_Power=Gravity_Mastered*0.2
		E.Vamp_Cured=Former_Vampire //Cured vampire blood passes to new generations
		E.Vampire=Vampire
		M.Next_Use=world.realtime+(60*60*10)
	else
		for(var/mob/P in get_step(src,dir)) if(P.client)
			if(!P.KO) switch(alert(P,"[src] wants to mate with you","","No","Yes","Bitch slap"))
				if("No") return
				if("Bitch slap")
					view(src)<<"[P] bitch slaps [src]"
					Knockback(P,10)
					return
			if(get_dist(src,P)>2) return
			if(P.KO) view(src)<<"[src] rapes [P]"
			Mate_Graphics(P)
			if(!Can_Mate())
				view(src)<<"[src] is sterile"
				return
			if(!P) return
			if(!P.Can_Mate())
				view(src)<<"[P] is sterile"
				return
			var/Mother
			if(gender=="female") Mother=src
			if(P.gender=="female") Mother=P
			if(P.gender==gender) return
			M=locate(/obj/Mate) in Mother
			if(Race==P.Race)
				M.Race=Race
				M.BP_Mod=max(BP_Mod,P.BP_Mod)
			else
				var/list/Races=list(Race,P.Race)
				if((Race=="Yasai"&&P.Race=="Human")||(Race=="Human"&&P.Race=="Yasai")) Races+="Half-Yasai"
				M.Race=input(Mother,"What race will the child be?") in Races
				if(M.Race==Race) M.BP_Mod=BP_Mod
				if(M.Race==P.Race) M.BP_Mod=P.BP_Mod
			M.Base_BP=max((Base_BP/BP_Mod)*0.7,(P.Base_BP/P.BP_Mod)*0.7)
			M.Energy=max(Max_Ki/Eff,P.Max_Ki/P.Eff)
			M.Grav_Power=max(Gravity_Mastered*0.2,P.Gravity_Mastered*0.2)
			if(P.Former_Vampire||Former_Vampire) M.Vamp_Cured=1
			if(P.Vampire||Vampire) M.Vampire=1
			M.Waiting=1
			M.Next_Use=world.realtime+(60*60*10)
			view(Mother)<<"[Mother] is pregnant"
mob/proc/Mate_Graphics(mob/M)
	var/old_state=icon_state
	var/m_old_state=M.icon_state
	var/old_x=pixel_x
	var/old_y=pixel_y
	loc=M.loc
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
	M.icon_state=m_old_state
	pixel_x=old_x
	pixel_y=old_y
	overlays-='CD.dmi'
mob/proc/Mate_Check()
	for(var/mob/P in Players) if(P.Race==Race) for(var/obj/Mate/M in P) if(M.Waiting)
		M.Waiting=0
		src<<"You are the child of [P]"
		loc=P.loc
		P<<"[src] is your child"
		BP_Mod=M.BP_Mod
		Max_Ki=M.Energy*Eff
		Base_BP=M.Base_BP*M.BP_Mod
		available_potential=0.01
		Gravity_Mastered=M.Grav_Power*0.2
		Gravity_Update()
		if(Gravity>Gravity_Mastered) Gravity_Mastered=Gravity
		Former_Vampire=M.Vamp_Cured
		if(M.Vampire) Become_Vampire()
		return
	for(var/obj/Egg/E) if(E.Race==Race)
		loc=E.loc
		src<<"You hatched from the egg of [E.Parent]"
		BP_Mod=E.BP_Mod
		Max_Ki=E.Energy*Eff
		Base_BP=E.Base_BP
		available_potential=0.5
		Gravity_Mastered=E.Grav_Power
		Gravity_Update()
		if(Gravity>Gravity_Mastered) Gravity_Mastered=Gravity
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
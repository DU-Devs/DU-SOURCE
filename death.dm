mob/proc/Full_Heal()
	Un_KO()
	if(Health<100) Health=100
	if(Ki<Max_Ki) Ki=Max_Ki
mob/proc/Zanzoken_Accuracy(mob/M)
	var/Z1=Zanzoken
	if(Z1>100) Z1=100
	var/Z2=M.Zanzoken
	if(Z2>100) Z2=100
	return sqrt(Z1/Z2)
proc/SSj_Online() for(var/mob/P in Players) if(P.SSjAble&&P.SSjAble<=Year&&P.Class!="Legendary Yasai") return P.SSjAble
proc/SSj2_Online() for(var/mob/P in Players) if(P.SSj2Able&&P.SSj2Able<=Year&&P.Class!="Legendary Yasai") return P.SSj2Able
proc/SSj3_Online() for(var/mob/P in Players) if(P.SSj3Able&&P.SSj3Able<=Year&&P.Class!="Legendary Yasai") return P.SSj3Able
mob/verb/Knockback_Options()
	set category="Other"
	KB_On=input(src,"Enter the percentage of your melee attacks that will have knockback applied. Current is \
	[KB_On]%. Knockback attacks do more damage but aren't good for everything.") as num
	if(KB_On<0) KB_On=0
	if(KB_On>100) KB_On=100
mob/var/KB_On=20
mob/proc/old_Melee(obj/O)
	if(Final_Realm())
		src<<"You can not attack anything in the final realm"
		return
	if(Ship) Ship.Ship_Weapon_Fire()
	if(!can_melee()||Punch_Machine()||Peebag()) return
	if(!O||ismob(O)) for(var/mob/Y in get_step(src,dir)) if(Y.attackable)
		if((src in All_Entrants)&&!Is_Fighter()&&z==7)
			src<<"You can not attack until it is your turn to fight"
			return

		var/list/sounds=list('weakpunch.ogg','weakkick.ogg','mediumpunch.ogg','mediumkick.ogg')
		var/mob/M=Y
		if(Y.GrabbedMob&&ismob(Y.GrabbedMob)) M=Y.GrabbedMob
		if(O) M=O
		if(client&&M.Flying&&!Flying) return
		var/Drain=1
		var/obj/Shield/ki_shield
		for(var/obj/Shield/s in M) if(s.Using) ki_shield=s

		var/Damage=((BP/M.BP)**0.75)*(Str/M.End)*5*Melee_Power //bp was a sqrt but they voted for bp to have more effect
		var/Accuracy=25*sqrt(BP/M.BP)*(Off/M.Def)*Zanzoken_Accuracy(M)
		var/Critical_Chance=5*sqrt(BP/M.BP)*(Def/M.Def)*Zanzoken_Accuracy(M)
		Critical_Chance=0

		if(M.dir==dir) //Hit from behind
			Damage*=4
			Accuracy*=4
		if(M.dir==turn(dir,90)||M.dir==turn(dir,-90)) //hits from the side
			Accuracy*=4
		for(var/obj/Injuries/Eye/I in M) Accuracy*=2
		for(var/obj/Injuries/Arm/I in M) Accuracy*=1.2
		for(var/obj/Injuries/Leg/I in M) Accuracy*=1.2
		var/Delay=4*Speed_Ratio()
		var/Knockback_Distance=round(sqrt(BP/M.BP)*(Str/M.End)*3)
		if(Knockback_Distance>20) Knockback_Distance=20
		if(prob(KB_On)) Damage*=1.5
		else Knockback_Distance=0
		if(Omega_KB()) Knockback_Distance=Get_Omega_KB()
		if(Knockback_Distance&&M.Safezone) Knockback_Distance=0
		for(var/obj/Hokuto_Shinken/H in src) if(H.Attacking) Knockback_Distance=1
		for(var/obj/items/Weights/W in src) if(W.suffix)
			Drain*=3
			break
		if(Warp) Drain*=3
		if(Ki<Drain) return
		if(M.Action=="Meditating") Accuracy*=10
		for(var/obj/items/Sword/S in src) if(S.suffix)
			sounds=list('swordhit.ogg')
			if(S.Style=="Energy")
				Damage*=M.End
				Damage/=M.Res
				Damage*=0.85
			break
		if(Knockback_Distance>1) sounds=list('strongpunch.ogg','strongkick.ogg')
		if(Y.dir==dir) Accuracy*=3
		if(client) Ki-=Drain
		attacking=1
		spawn(Delay(Delay)) attacking=0
		spawn if(M&&M.attacking==1) set_opponent(M)
		melee_graphics()
		for(var/obj/Hokuto_Shinken/H in src) if(H.Attacking) sounds=null
		var/obj/Module/Drone_AI/D=M.Get_Drone_AI()
		if(D) Drone_Attack(src)
		if(client&&istype(M,/mob/Splitform)&&!M:Mode)
			M:Mode="Attack Target"
			M.Target=src
		if(ki_shield)
			var/shield_drain=0.3*(M.Max_Ki/100/sqrt(M.Eff))*Damage
			if(M.Ki>=shield_drain)
				M.Ki-=shield_drain
				return
		M.last_attacked_time=world.realtime
		if(prob(Accuracy)||M.KO)
			if(prob(Critical_Chance))
				Damage*=2
				//overlays+='KiSword.dmi'
				//spawn(2) if(src) overlays-='KiSword.dmi'
			if(Zombie_Virus&&M.client)
				if(!client)
					if(!M.Zombie_Virus)
						M<<"[src] just infected you with Zombie Virus"
						M.Zombie_Virus_Loop()
					M.Zombie_Virus+=Zombie_Virus
				else if(!M.Zombie_Virus)
					M.Zombie_Virus=1
					M.Zombie_Virus_Loop()
					M<<"[src] just infected you with Zombie Virus"
			view(5,src)<<sound(pick(sounds),0,0,0,20)
			Add_Hokuto_Shinken_Energy(M)
			if(Knockback_Distance&&BP*StrMod>=50) spawn if(src) Make_Shockwave(src,5)
			var/Warp_Dir=get_dir(M,src)
			if(Knockback_Distance&&M) M.Knockback(src,Knockback_Distance)
			if(!M) return
			else if(!M.KO)
				M.Health-=Damage
				if(M.Health<=0) M.KO(src)
			else if(!M.client||Fatal)
				if(Damage>20&&M.client) Damage=20 //No less than 5 hits to kill a ko person
				M.Health-=Damage
				if(M.Health<=0) M.Death(src)
			if(M&&M.z==z&&Warp&&Knockback_Distance)
				if(Ki>=Zanzoken_Drain())
					Ki-=Zanzoken_Drain()
					Zanzoken_Mastery(0.2)
					if(M in viewers(20,src)) Warp_To(Get_Warp(M,src,Warp_Dir),M)
		else
			view(10,M)<<sound(pick('meleemiss1.ogg','meleemiss2.ogg','meleemiss3.ogg'),volume=30)
			flick('Zanzoken.dmi',M)
		if(istype(M,/mob/Enemy)&&client)
			M.Docile=0
			M.Attack_Target(src)
		if(istype(M,/mob/Troll)&&client)
			var/mob/Troll/TT=M
			TT.Target=src
			if(TT.Health<=40&&TT.Troll_Mode!="Run") TT.Troll_Run()
			else if(TT.Troll_Mode!="Attack") TT.Troll_Attack()
		return
	if(!O||isobj(O)) for(var/obj/A in get_step(src,dir))
		if(!O.takes_gradual_damage)
			var/obj/Y=A
			if(O) Y=O
			if(Y.attackable&&!(client&&istype(Y,/obj/Edges)))
				view(10,src)<<pick('weakpunch.ogg','weakkick.ogg','mediumpunch.ogg','mediumkick.ogg')
				attacking=1
				spawn(4*Speed_Ratio()) attacking=0
				melee_graphics()
				if(!client) Y.Health-=BP/2000
				if(Y.Health<BP)
					new/obj/Crater(locate(Y.x,Y.y,Y.z))
					del(Y)
				return
		else if(A.attackable)
			view(10,src)<<pick('weakpunch.ogg','weakkick.ogg','mediumpunch.ogg','mediumkick.ogg')
			attacking=1
			spawn(4*Speed_Ratio()) attacking=0
			melee_graphics()
			A.Health-=BP/5
			if(A.Health<=0)
				new/obj/Crater(A.loc)
				del(A)
			return
	var/turf/A=get_step(src,dir)
	if(O&&isturf(O)) A=O
	if(A) if(A.density&&A.attackable)
		view(10,src)<<pick('weakpunch.ogg','weakkick.ogg','mediumpunch.ogg','mediumkick.ogg')
		attacking=1
		spawn(4*Speed_Ratio()) attacking=0
		melee_graphics()
		if(!client) A.Health-=BP/2000
		if(A.Health<BP)
			A.Health=0
			A.Destroy()
		return
proc/Get_Warp(mob/M,mob/P,Dir) if(Dir)
	var/turf/T=get_step(M,Dir)
	if(T&&isturf(T)&&!T.density&&!(locate(/mob) in T)&&T.Enter(P)&&!(locate(/obj/Edges) in T)&&!T.Water) return T
proc/Get_Warp_Destination(mob/M,mob/P)
	var/list/Locs
	for(var/turf/A in oview(1,M)) if(!A.density&&!(locate(/mob) in A)&&A.Enter(P)&&!(locate(/obj/Edges) in A)&&!A.Water&&(A in view(20,P)))
		if(!Locs) Locs=new/list
		Locs+=A
	if(Locs) return pick(Locs)

mob/proc/Warp_To(turf/B,mob/M) if(B)
	view(10,src)<<sound('teleport.ogg',volume=10)
	flick('Zanzoken.dmi',src)
	loc=locate(B.x,B.y,B.z)
	dir=get_dir(src,M)
	M.dir=get_dir(M,src)


mob/proc/can_melee()
	if(Action in list("Meditating","Training")) return
	if(Shadow_Sparring||KO||attacking) return
	for(var/obj/items/Regenerator/R in range(0,src)) if(R.z) return
	if(Final_Realm())
		src<<"You can not attack in the final realm"
		return
	if((src in All_Entrants)&&!Is_Fighter()&&z==7)
		src<<"You can not attack until it is your turn to fight"
		return
	if(Ship)
		Ship.Ship_Weapon_Fire()
		return
	if(Peebag()||Punch_Machine()) return
	return 1
mob/proc/set_opponent(mob/M)
	if(Opponent==M) return
	Opponent=M
	spawn(100) if(src&&Opponent==M) Opponent=null
mob/proc/Knockback(mob/A,Distance=10) //A is the Attacker who knockbacked src
	if(Safezone) return
	Distance=round(Distance)
	var/Old_State=icon_state
	if(client) icon_state="KB"
	KB=1
	while(src&&A&&KB&&Distance)
		Distance--
		var/Dir=get_dir(A,src)
		if((locate(/obj/Edges) in loc)||(locate(/obj/Edges) in get_step(src,Dir))) KB=0
		var/turf/T=get_step(src,Dir)
		if(!T||(T.Water&&!Flying)) KB=0
		T=loc
		KB_Destroy(A,Dir)
		step(src,Dir)
		if(T==loc) KB=0
		sleep(1)
	if(src)
		KB=0
		if(KO&&client) icon_state="KO"
		else icon_state=Old_State
mob/proc/KB_Destroy(mob/A,Dir) //A is the Attacker
	var/turf/T=get_step(src,Dir)
	if(T&&T.Health<A.BP&&!T.Water)
		T.Health=0
		if(T.density)
			Dust(T,20)
			T.Destroy()
		else if(!Flying&&A.BP>3000000)
			Dust(T,1)
			T.Make_Damaged_Ground(1)
	for(var/obj/O in get_step(src,Dir)) if(O.z&&!istype(O,/obj/Dust))
		if(O.Health<A.BP)
			Dust(O,30)
			del(O)
mob/var/KO
mob/proc/KO(mob/Z)
	if(client) if(!KO)
		if(Safezone) return
		Zenkai()
		if(key in epic_list) return
		if(Last_Anger+6000<=world.realtime&&(prob(50)||Hero==key||Ultra_Pack))
			if(!Disabled())
				Anger()
				return
		KO=1
		Action=null
		Auto_Attack=0
		for(var/obj/Limit_Breaker/A in src) if(A.Using) Limit_Revert()
		Werewolf_Revert()
		Land()
		BP=Get_Available_Power()
		Health=100
		if(BPpcnt>100)
			BPpcnt=100
			Aura_Overlays()
		icon_state="KO"
		KB=0
		if(ismob(Z)&&Z.client&&Z.client.computer_id!="244770299")
			for(var/mob/m in view(src))
				var/t="[src] is knocked out by [Z] ([Z.displaykey])"
				m<<t
				m.ChatLog(t)
		else view(src)<<"[src] is knocked out by [Z]!"
		for(var/obj/A in src) if(A.Stealable) if(A.Injection&&prob(10))
			var/obj/items/Diarea_Injection/V=A
			V.Use(src)
		if(ssj>0)
			if(ssjdrain>300&&ssj==1)
			else Revert()
		var/KO_Timer=1200/(Regeneration**0.3)
		if(z==10) KO_Timer/=4
		if(Ultra_Pack) KO_Timer/=2
		spawn(KO_Timer*KO_Time) Un_KO()
		if(Poisoned&&prob(50)) spawn Death("???")
	else if(!Frozen)
		if("KO" in icon_states(icon)) icon_state="KO"
		KO=1
		Health=100
		Frozen=1
		view(src)<<"[src] is knocked out"
		spawn(1800) if(src)
			icon_state=initial(icon_state)
			view(src)<<"[src] regains consciousness"
			Health=100
			KO=0
			Frozen=0
mob/proc/Un_KO() if(client&&KO)
	Health=1
	KO=0
	icon_state=""
	attacking=0
	Ki=0
	move=1
	if(Poisoned&&prob(50)) spawn Death("???")
	view(src)<<"[src] regains consciousness."
	spawn(20) if(prob(20)&&!Angry())
		src<<"<font color=red>Being knocked out so much angers you..."
		Anger()
		Full_Heal()
mob/proc/Angry() if(Anger>100) return 1
mob/var/Regenerate=0 //Like Majin and Bios regenerate instead of dying
mob/var/Regenerating
mob/var/Death_Year=0
mob/proc/Drop_Rsc(n=0) if(n) for(var/obj/Resources/R in src)
	var/obj/Resources/Bag=new(loc)
	Bag.Value=n
	R.Value-=n
	Bag.name="[Commas(Bag.Value)] Resources"
mob/proc/Drop_Stealables()
	Drop_Rsc(Res()*0.9)
	for(var/obj/Stun_Chip/SC in src) del(SC)
	Scouter=null
	for(var/obj/A in contents) if(A.Stealable)
		if(istype(A,/obj/items/Sword)) if(A.suffix) Apply_Sword(A)
		if(istype(A,/obj/items/Armor)) if(A.suffix) Apply_Armor(A)
		A.suffix=null
		overlays-=A.icon
		A.loc=loc
mob/proc/Death(mob/Z,Force_Death=0)

	if(key in epic_list) return

	if(Prisoner()||Safezone||Clone_Tank()||Final_Realm()) return

	/*if(Has_Bounty())
		Imprison()
		Update_Bounties()
		return*/

	var/Already_Dead=Dead
	if(Android&&!Dead) Spread_Scraps()
	Zombie_Virus=0
	Auto_Attack=0
	if(Ship) loc=Ship.loc
	if(!ismob(Z)||(ismob(Z)&&Z.client&&Z.client.computer_id!="244770299"))
		for(var/mob/m in view(src))
			var/t="[src] was just killed by [Z]!"
			m<<t
			m.ChatLog(t)
	if(!Dead)
		for(var/obj/Injuries/I in src) del(I)
		Add_Injury_Overlays()
	Poisoned=0
	Roid_Power(0)
	if(GrabbedMob)
		view(src)<<"[src] is forced to release [GrabbedMob]!"
		if(ismob(GrabbedMob)) GrabbedMob.attacking=0
		attacking=0
		GrabbedMob=null
	for(var/mob/A) if(A.GrabbedMob==src)
		A.GrabbedMob.attacking=0
		A.attacking=0
		A.GrabbedMob=null
	if(client||Logged_Out_Body||istype(src,/mob/Troll)||istype(src,/mob/new_troll))
		if(!Force_Death&&Regenerate&&!Dead&&!Regenerating)
			Full_Heal()
			src<<"You will regenerate in [round(2/sqrt(Regenerate),0.1)] minutes"
			Regenerating=1
			saved_x=x
			saved_y=y
			saved_z=z
			if(!Android&&!Android_Regen()) Leave_Body()
			Regenerate()
			return
		if(!Dead)
			if(ismob(Z)&&Age>=2&&Base_BP>=50000) for(var/mob/A in view(src)) if(A!=Z&&A.client&&!A.KO)
				A.Anger(2)
				if(A&&A.Race=="Yasai")
					if((!SSj_Online()||Omega_Easy)&&(!A.SSjAble||A.SSjAble>Year)&&A.BP>=A.ssjat&&A.Base_BP>=A.ssjat/3)
						spawn if(A) A.SSj()
						break
					if((!SSj2_Online()||Omega_Easy)&&(!A.SSj2Able||A.SSj2Able>Year)&&A.BP>=A.ssj2at&&A.Base_BP>=ssj2at/4)
						spawn if(A) A.SSj2()
						break
					if((!SSj3_Online()||Omega_Easy)&&(!A.SSj3Able||A.SSj3Able>Year)&&A.BP>=A.ssj3at&&A.Base_BP>=ssj3/8)
						spawn if(A) A.SSj3()
						break
				if(prob(50)) break
			if(!Android&&!Android_Regen()) Leave_Body()
		Drop_Stealables()
		var/Rebuilt
		if(!Force_Death) for(var/obj/Module/Rebuild/R in src) if(R.suffix) for(var/obj/Cybernetics_Computer/P) if(P.Password==R.Password&&P.z)
			Full_Heal()
			src<<"The [P] has rebuilt you here"
			loc=get_step(P,SOUTH)
			Rebuilt=1
			break
		if(!Dead&&!Rebuilt)
			Destroy_Soul_Contracts()
			for(var/obj/Module/M in src) if(M.suffix)
				M.Disable_Module(src)
				M.loc=loc
			Cyber_Power=0
			Attack_Gain(1000)
			overlays+='Halo.dmi'
			Dead=1
			Death_Year=Year
		if(!Rebuilt)
			Vampire_Revert()
			Former_Vampire=0
			loc=locate(rand(140,194),rand(166,215),5)
			Full_Heal()
			if(death_setting=="Rebirth upon death")
				Reincarnate()
				Revive()
				alert(src,"You were killed. You have now been reborn as a completely different character \
				and have lost some power")
			if(Already_Dead)
				src<<"<font color=yellow><font size=1>You were killed while dead. Your available potential has \
				been lowered until you train back to your full potential."
				available_potential/=2
				if(available_potential<0.01) available_potential=0.01
			if(Already_Dead&&Perma_Death)
				src<<"<font color=yellow><font size=3>You were killed while dead. Meaning you have been \
				automatically reincarnated."
				Reincarnate()
		if(src)
			if(key) Save()
			if(type==/mob/Troll||type==/mob/new_troll)
				Drop_Stealables()
				del(src)
	else
		Drop_Stealables()
		del(src)
mob/proc/Revive()
	Dead=0
	overlays-='Halo.dmi'
atom/var/attackable=1
mob/var/tmp/AutoAttack
mob/verb/Attack()
	set category="Skills"
	Melee()
obj/Dust
	density=0
	icon='Dust.dmi'
	layer=5
	Grabbable=0
	attackable=0
	Savable=0
	New() spawn(rand(1,600)) if(src) del(src)
proc/Dust(mob/A,n=2)
	if(locate(/obj/Dust) in range(0,A)) return
	for(var/V in 1 to n)
		var/obj/Dust/D=new
		D.loc=locate(A.x,A.y,A.z)
		D.icon='Air Dust 2.dmi'
		D.pixel_y=rand(-16,16)
		D.pixel_x=rand(-16,16)
		D.pixel_x-=16
		D.pixel_y-=16
		D.dir=pick(NORTH,SOUTH,EAST,WEST,NORTHWEST,NORTHEAST,SOUTHWEST,SOUTHEAST)
		spawn while(D)
			if(prob(85)) D.dir=turn(D.dir,45)
			step(D,D.dir)
			sleep(4)
mob/var/Warp=0
mob/var/tmp/KB
turf/proc/Destroy()
	var/image/I=image(icon='Lightning flash.dmi',layer=99)
	overlays-=I
	if(Health<=0)
		if(!Water) if(Health!=1.#INF&&type!=/turf)
			//new/turf/GroundDirt(locate(x,y,z))
			new/turf/GroundSandDark(locate(x,y,z))
			if(prob(5))
				var/obj/Turfs/Rock1/R=new(locate(x,y,z))
				R.Nukable=0
				R.pixel_x=rand(-16,16)
				R.pixel_y=rand(-16,16)
				R.density=0
				R.Savable=0
				spawn(rand(600,1800)) if(R) del(R)
client/North() if(mob.Allow_Move(NORTH)) return ..()
client/South() if(mob.Allow_Move(SOUTH)) return ..()
client/East() if(mob.Allow_Move(EAST)) return ..()
client/West() if(mob.Allow_Move(WEST)) return ..()
client/Northwest() if(mob.Allow_Move(NORTHWEST)) return ..()
client/Northeast() if(mob.Allow_Move(NORTHEAST)) return ..()
client/Southwest() if(mob.Allow_Move(SOUTHWEST)) return ..()
client/Southeast() if(mob.Allow_Move(SOUTHEAST)) return ..()
mob/proc/Allow_Move(D)
	for(var/obj/Blast/B in get_step(src,D)) if(B.dir==D) return
	if(Shadow_Sparring)
		dir=D
		return
	if(locate(/obj/Michael_Jackson) in usr) return
	for(var/obj/Attacks/A in usr) if(A.charging||A.streaming||A.Using)
		dir=D
		return
	if(Ship&&Ship.Ki>0&&!Ship.Moving&&icon_state!="KO")
		Ship.Move_Randomly=0
		Ship.Moving=1
		Ship.MoveReset()
		step(Ship,D)
		if(Ship) Ship.Fuel()
		return
	if(icon_state=="KB"||!move) return
	if(grabberSTR&&prob(5)) for(var/mob/A in view(1,usr)) if(A.GrabbedMob==usr)
		if(prob((Str*BP*5)/grabberSTR))
			view(usr)<<"[usr] breaks free of [A]!"
			A.GrabbedMob=null
			attacking=0
			A.attacking=0
			grabberSTR=0
		else view(src)<<"[usr] struggles against [A]"
		return
	return 1
mob/var
	Anger_Restoration
	Last_Anger=0 //So you can't get angry again til enough time passes
	last_attacked_time=0 //the last time someone attacked you. if the last time you were attacked was
	//more than 2 minutes ago you become calm
mob/proc/Anger(anger_mult=1) if(!Angry()&&!ismystic&&Max_Anger>100)
	for(var/obj/Third_Eye/T in src) if(T.Using) return
	if(anger_mult==1) view(src)<<"<font color=red>[src] gets angry!"
	else view(src)<<"<font color=red>[src] gets extremely enraged!!"
	last_attacked_time=world.realtime
	Anger=100
	Anger+=(Max_Anger-100)*anger_mult
	Last_Anger=world.realtime
	if(prob(100)) Anger_Restoration=1
	if(Health<100) Health=100
	if(Ki<Max_Ki) Ki=Max_Ki
mob/proc/Calm()
	if(Anger>100) view(src)<<"[src] becomes calm"
	Anger=100
	Anger_Restoration=0
mob/var/tmp/attacking
mob/var/Dead
mob/proc/melee_graphics() if(icon)
	for(var/obj/Werewolf/O in src) if(O.suffix) return
	for(var/obj/items/Sword/A in src) if(A.suffix&&A.icon) if("Sword" in icon_states(A.icon))
		if("Sword" in icon_states(icon))
			flick("Sword",src)
			return
	if("Kick" in icon_states(icon)) flick(pick("Attack","Kick"),src)
	else if("Attack" in icon_states(icon)) flick("Attack",src)
mob/proc/Blast()
	for(var/obj/Werewolf/O in src) if(O.suffix) return
	if(attacking) flick("Attack",src)
mob/proc/Leave_Body()
	var/mob/Body/A=new
	A.Zombie_Virus=Zombie_Virus
	for(var/obj/Stun_Chip/S in src) A.contents+=S
	A.Frozen=1 //Like being knocked out for NPCs, so it doesnt get knocked out again
	A.BP=BP
	A.Body=Body
	A.Gravity_Mastered=Gravity_Mastered
	A.Base_BP=Base_BP
	A.BP_Mod=BP_Mod
	A.Max_Ki=Max_Ki
	A.Str=Str
	A.End=End
	A.Spd=Spd
	A.Res=Res
	A.Pow=Pow
	A.Off=Off
	A.Def=Def
	A.Regeneration=Regeneration
	A.Recovery=Recovery
	A.icon=icon
	if("KO" in icon_states(A.icon)) A.icon_state="KO"
	A.overlays+=overlays
	if(client) A.overlays+='Zombie.dmi'
	else A.underlays+='Pool of Blood.dmi'
	A.loc=loc
	A.name="Body of [src]"
	Center_Icon(A)
	if(key) A.displaykey=key
	if(!istype(src,/mob/Enemy/Zombie)&&Zombie_Virus) A.Zombies(0)
mob/Admin4/verb/Make_Bodies()
	set category="Admin"
	var/Pos=1
	switch(input(src,"Choose where you want the bodies to spawn") in list("Around you","This Z","Entire World","Around target"))
		if("Around you") Pos=1
		if("Entire World") Pos=2
		if("Around target") Pos=3
		if("This Z") Pos=4
	var/Amount=input(src,"How many bodies?") as num
	if(Amount<=0) return
	Amount=round(Amount)
	if(Amount>100000) Amount=100000
	while(Amount)
		Amount-=1
		var/mob/P
		while(!P||!ismob(P))
			P=pick(Players)
			if(P&&!P.z) P=null
			if(prob(1)) sleep(1)
		P.Leave_Body()
		for(var/mob/Body/B in view(10,P)) if(B.displaykey==P.key)
			if(Pos==1)
				var/list/TL=new
				for(var/turf/T in view(10,src)) TL+=T
				B.loc=pick(TL)
			if(Pos==2)
				B.x=rand(1,world.maxx)
				B.y=rand(1,world.maxy)
				B.z=rand(1,world.maxz)
			if(Pos==4)
				B.x=rand(1,world.maxx)
				B.y=rand(1,world.maxy)
				B.z=z
		if(prob(1)) sleep(1)
mob/proc/Punch_Machine()
	for(var/obj/Punch_Machine/P in get_step(src,dir))
		P.dir=WEST
		if(!attacking&&P.dir==turn(dir,180))
			attacking=1
			spawn(10) attacking=0
			melee_graphics()
			if(P.Health<=BP*StrMod)
				Make_Shockwave(P,10)
				Dust(P.loc,20)
				del(P)
			else view(P)<<"[src] hits the [P]<br><font color=red>[P]: [Commas(sqrt(BP)*Str/1000)] Damage!"
			return 1
mob/proc/Peebag()
	for(var/obj/Peebag/Pee in get_step(src,dir))
		Pee.dir=WEST
		if(!attacking&&Ki>=3&&Pee.dir==turn(dir,180))
			attacking=1
			spawn(10) attacking=0
			Ki-=3
			melee_graphics()
			if("Hit" in icon_states(Pee.icon)) flick("Hit",Pee)
			Peebag_Gains()
			return 1
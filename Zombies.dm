mob/var/Zombie_Immune=0
mob/var/Flyer
mob/var/Zombie_Virus=0
mob/var/Mutater=1
mob/var/Zombie_Power=0
mob/proc/Mutate(A)
	if(!A) A=rand(2,13)
	Flyer=0
	//NPC Scorpion 2.dmi, NPC Spider 3.dmi, NPC Snake.dmi
	//RP_Power, Str, Dur, Res, Spd, Off, Def
	if(A==2)
		name="Zombie Dog"
		icon='Zombie Dog.dmi'
		BP*=1.2
		Spd*=1.2
		SpdMod*=1.2
	if(A==3)
		name="Licker"
		icon='Zombie Licker.dmi'
		Zombie_Virus=5
		BP*=1.5
		Spd*=1.5
		SpdMod*=1.5
		Off*=1.5
		OffMod*=1.5
		if(prob(20))
			Enlarge_Icon(48,48)
			Center_Icon(src)
	if(A==4)
		name="Hunter"
		icon='Zombie Hunter.dmi'
		Zombie_Virus=1
		BP*=1.5
		Str*=2
		StrMod*=2
		End*=1.5
		EndMod*=1.5
		Res*=0.5
		ResMod*=0.5
		if(prob(20))
			Enlarge_Icon(48,48)
			Center_Icon(src)
	if(A==5)
		name="Tyrant"
		icon='Zombie Tyrant.dmi'
		Zombie_Virus=20
		BP*=2
		End*=1.5
		EndMod*=1.5
		Spd*=1.5
		SpdMod*=1.5
	if(A==6)
		name="Nemesis"
		icon='Zombie Nemesis.dmi'
		Zombie_Virus=1
		BP*=2
		End*=1.5
		EndMod*=1.5
		Str*=1.5
		StrMod*=1.5
		Res*=1.5
		ResMod*=1.5
		if(prob(30))
			Enlarge_Icon(48,48)
			Center_Icon(src)
	if(A==7)
		name="Mr X"
		icon='Zombie X.dmi'
		Zombie_Virus=10
		BP*=3
		SpdMod*=2
		Spd*=2
		Off*=2
		OffMod*=2
	if(A==8)
		name="Thanatos"
		icon='Zombie Thanatos.dmi'
		Zombie_Virus=10
		BP*=3
		Str*=2
		StrMod*=2
		Spd*=1.5
		SpdMod*=1.5
	if(A==9)
		name="Gargoyle"
		icon='Gargoyle.dmi'
		Zombie_Virus=1
		EndMod*=0.5
		End*=0.5
		Res*=0.2
		ResMod*=0.2
		Spd*=3
		SpdMod*=3
		Flyer=1
	if(A==10)
		name="Reptile Zombie"
		icon='NPC Reptile Monster.dmi'
		Zombie_Virus=1
		BP*=1.3
		Spd*=2
		SpdMod*=2
		Res*=0.5
		ResMod*=0.5
	if(A==11)
		name="Snake Zombie"
		icon='NPC Snake.dmi'
		Zombie_Virus=0.5
		Spd*=3
		SpdMod*=3
	if(A==12)
		name="Scorpion Zombie"
		icon='NPC Scorpion 2.dmi'
		Zombie_Virus*=0.5
		End*=3
		EndMod*=3
		Enlarge_Icon(48,48)
		Center_Icon(src)
	if(A==13)
		name="Spider Zombie"
		icon='NPC Spider 3.dmi'
		Zombie_Virus=2
		Spd*=3
		SpdMod*=3
		Off*=2
		OffMod*=2
		Enlarge_Icon(48,48)
		Center_Icon(src)
	Level=A //This is used by the DNA detector to see what it is supposed to get from the zombie.
	overlays-=overlays
	spawn if(src&&type!=/mob/Enemy/Zombie) Zombie_Initialize()
mob/var/Has_DNA=1
obj/items/DNA_Container
	Cost=500000000
	icon='Item, DNA Extractor.dmi'
	desc="This can be used to store DNA from whoever you use it on. Which can be used to clone them. You can \
	only use this on someone who is knocked out or paralyzed. After it has DNA in it, you can go to a Genetics \
	Computer and use it to make a clone, and possibly more."
	Stealable=1
	var/mob/Clone
	verb/Use()
		for(var/mob/A in get_step(usr,usr.dir)) if(A.Frozen||A.KO||!A.client)
			if(A in All_Entrants)
				usr<<"You can not take DNA from people enrolled in tournaments"
				return
			if(!A.Has_DNA)
				usr<<"[A] has no DNA"
				return
			if(A.Race=="Majin")
				usr<<"Majins are not clonable"
				return
			if(A.Android)
				usr<<"[A] is an Android, they have no DNA"
				return
			if(Clone) switch(input("This already contains DNA do you really want to overwrite it?") in list("No","Yes"))
				if("No") return
			if(A.Dead)
				usr<<"You are dead and therefore do not have DNA"
				return
			view(usr)<<"[usr] extracts DNA from [A]"
			if(istype(A,/mob/Enemy/Zombie))
				var/obj/O=A.Zombie_Drop()
				if(O)
					usr<<"You recieved [O]"
					usr.contents+=O
					del(src)
			name="DNA of [A.name]"
			Clone=A.Clone()
			return
		if(usr.Android)
			usr<<"You are an Android, you have no DNA"
			return
		usr<<"You extract DNA from yourself"
		name="DNA of [usr.name]"
		Clone=usr.Clone()
mob/proc/Zombie_Drop()
	var/obj/O
	if(Level==1) O=new/obj/items/Antivirus(get_step(src,dir)) //Regular
	if(Level==2) O=new/obj/items/T_Energy(get_step(src,dir)) //Dog
	if(Level==3) O=new/obj/items/T_Heal(get_step(src,dir)) //Licker
	if(Level==4) O=new/obj/items/T_Vitality(get_step(src,dir)) //Hunter
	if(Level==5) O=new/obj/items/T_Strength(get_step(src,dir)) //Tyrant
	if(Level==6) O=new/obj/items/T_Fusion(get_step(src,dir)) //Nemesis
	if(Level==7) O=new/obj/items/T_Undying(get_step(src,dir)) //Mr X
	if(Level==8) O=new/obj/items/T_Life(get_step(src,dir)) //Thanatos
	if(Level==9) O=new/obj/items/T_Regeneration(get_step(src,dir)) //Gargoyle
	if(Level==10) O=new/obj/items/T_Recovery(get_step(src,dir)) //Reptile
	if(Level==11) O=new/obj/items/T_Snake(get_step(src,dir)) //Snake
	if(Level==12) O=new/obj/items/T_Scorpion(get_step(src,dir)) //Scorpion
	if(Level==13) O=new/obj/items/T_Spider(get_step(src,dir)) //Spider
	return O
obj/items/T_Spider
	Stealable=1
	desc="x1.2 Strength. 1.2x Offense. /1.44 Resistance. Get the advantage and disadvantage of a spider! \
	Also gives a BP boost roughly worth 20 minutes of sparring."
	icon='Item, Needle.dmi'
	verb/Use(mob/A in view(1,usr)) if(A==usr||A.Frozen||A.KO)
		if(A.Android)
			usr<<"This has no effect on androids"
			return
		if(!("Spider" in A.T_Injections))
			A.T_Injections+="Spider"
			A.Attack_Gain(1200)
			A.Str*=1.2
			A.StrMod*=1.2
			A.Off*=1.2
			A.OffMod*=1.2
			A.Res/=1.44
			A.ResMod/=1.44
			A.Original_Decline*=0.9
			A.Decline*=0.9
			view(usr)<<"[usr] injects [A] with a mysterious needle!"
			del(src)
		else usr<<"[A] has already used [src]"
obj/items/T_Scorpion
	Stealable=1
	desc="x1.2 Offense. /1.2 Defense. Get the advantage and disadvantage of a scorpion! Also gives a BP boost \
	roughly worth 20 minutes of sparring."
	icon='Item, Needle.dmi'
	verb/Use(mob/A in view(1,usr)) if(A==usr||A.Frozen||A.KO)
		if(A.Android)
			usr<<"This has no effect on androids"
			return
		if(!("Scorpion" in A.T_Injections))
			A.T_Injections+="Scorpion"
			A.Attack_Gain(1200)
			A.Off*=1.2
			A.OffMod*=1.2
			A.Def/=1.2
			A.DefMod/=1.2
			A.Original_Decline*=0.9
			A.Decline*=0.9
			view(usr)<<"[usr] injects [A] with a mysterious needle!"
			del(src)
		else usr<<"[A] has already used [src]"
obj/items/T_Snake
	Stealable=1
	desc="x1.2 Speed. /1.2 Defense. Get the advantage and disadvantage of a snake! Also gives a BP boost roughly \
	worth 20 minutes of sparring."
	icon='Item, Needle.dmi'
	verb/Use(mob/A in view(1,usr)) if(A==usr||A.Frozen||A.KO)
		if(A.Android)
			usr<<"This has no effect on androids"
			return
		if(!("Snake" in A.T_Injections))
			A.T_Injections+="Snake"
			A.Attack_Gain(1200)
			A.Spd*=1.2
			A.SpdMod*=1.2
			A.Def/=1.2
			A.DefMod/=1.2
			A.Original_Decline*=0.9
			A.Decline*=0.9
			view(usr)<<"[usr] injects [A] with a mysterious needle!"
			del(src)
		else usr<<"[A] has already used [src]"
obj/items/T_Recovery
	Stealable=1
	desc="Doubles recovery but halves energy."
	icon='Item, Needle.dmi'
	verb/Use(mob/A in view(1,usr)) if(A==usr||A.Frozen||A.KO)
		if(A.Android)
			usr<<"This has no effect on androids"
			return
		if(!("Recovery" in A.T_Injections))
			A.T_Injections+="Recovery"
			A.Recovery*=2
			A.Ki*=0.5
			A.Max_Ki*=0.5
			A.Eff*=0.5
			A.Original_Decline*=0.8
			A.Decline*=0.8
			view(usr)<<"[usr] injects [A] with a mysterious needle!"
			del(src)
		else usr<<"[A] has already used [src]"
obj/items/T_Regeneration
	Stealable=1
	desc="Doubles regeneration and divides force by 4 permanently making energy almost useless."
	icon='Item, Needle.dmi'
	verb/Use(mob/A in view(1,usr)) if(A==usr||A.Frozen||A.KO)
		if(A.Android)
			usr<<"This has no effect on androids"
			return
		if(!("Regeneration" in A.T_Injections))
			A.T_Injections+="Regeneration"
			A.Regeneration*=2
			A.Pow*=0.25
			A.PowMod*=0.25
			A.Original_Decline*=0.8
			A.Decline*=0.8
			view(usr)<<"[usr] injects [A] with a mysterious needle!"
			del(src)
		else usr<<"[A] has already used [src]"
obj/items/T_Energy
	Stealable=1
	desc="Raises energy to a certain level if it is below that level."
	icon='Item, Needle.dmi'
	verb/Use(mob/A in view(1,usr)) if(A==usr||A.Frozen||A.KO)
		if(A.Android)
			usr<<"This has no effect on androids"
			return
		if(A.Max_Ki<1500*A.Eff)
			A.Max_Ki=1500*A.Eff
			A.Original_Decline*=0.8
			A.Decline*=0.8
			view(usr)<<"[usr] injects [A] with a mysterious needle!"
			del(src)
		else usr<<"[A]'s energy is too high already to use this, it will do nothing for them"
obj/items/T_Vitality
	Stealable=1
	desc="Raises durability and resistance immensely."
	icon='Item, Needle.dmi'
	verb/Use(mob/A in view(1,usr)) if(A==usr||A.Frozen||A.KO)
		if(A.Android)
			usr<<"This has no effect on androids"
			return
		if(!("Vitality" in A.T_Injections))
			A.T_Injections+="Vitality"
			usr.Raise_Stats(1800,"Durability")
			usr.Raise_Stats(1800,"Resistance")
			A.Original_Decline*=0.8
			A.Decline*=0.8
			view(usr)<<"[usr] injects [A] with a mysterious needle!"
			del(src)
		else usr<<"[A] has already used [src]"
obj/items/T_Heal
	Stealable=1
	desc="Temporarily speeds up regeneration when used."
	icon='Item, Needle.dmi'
	verb/Use(mob/A in view(1,usr)) if(A==usr||A.Frozen||A.KO)
		if(A.Android)
			usr<<"This has no effect on androids"
			return
		if(A.Regen_Mult<5) A.Regen_Mult=5
		spawn if(A) A.Un_KO()
		view(usr)<<"[usr] injects [A] with a mysterious needle!"
		del(src)
obj/items/T_Fusion
	Stealable=1
	desc="This will increase your battle power greatly but it will slowly wear off. You can take it as many \
	times as you want to keep your power high but each time will shorten your lifespan. Another advantage is that \
	you cannot be infected by the T Virus while this is active in your body."
	icon='Item, Needle.dmi'
	verb/Use(mob/A in view(1,usr)) if(A==usr||A.Frozen||A.KO)
		if(A.Android)
			usr<<"This has no effect on androids"
			return
		if(!A.Zombie_Power) A.Zombie_Virus_Loop()
		A.Zombie_Power+=(A.Knowledge**0.6)*50
		A.Original_Decline*=0.9
		A.Decline*=0.9
		A.Decline_Rate*=1.05
		A.overlays-='Red Eyes.dmi'
		A.overlays+='Red Eyes.dmi'
		view(usr)<<"[usr] injects [A] with a mysterious needle!"
		del(src)
obj/items/T_Strength
	Stealable=1
	desc="This will greatly increase strength and speed if they are under certain levels."
	icon='Item, Needle.dmi'
	verb/Use(mob/A in view(1,usr)) if(A==usr||A.Frozen||A.KO)
		if(A.Android)
			usr<<"This has no effect on androids"
			return
		if(!("Strength" in A.T_Injections))
			A.T_Injections+="Strength"
			usr.Raise_Stats(1800,"Strength")
			usr.Raise_Stats(1800,"Speed")
			A.Original_Decline*=0.8
			A.Decline*=0.8
			view(usr)<<"[usr] injects [A] with a mysterious needle!"
			del(src)
		else usr<<"[A] has already used [src]"
obj/items/T_Undying
	Stealable=1
	desc="This will permanently double your recovery, and give you the ability to regenerate from death (or enhance \
	your ability to regenerate from death if you already can). The downside is that it will half your resistance."
	icon='Item, Needle.dmi'
	verb/Use(mob/A in view(1,usr)) if(A==usr||A.Frozen||A.KO)
		if(A.Android)
			usr<<"This has no effect on androids"
			return
		if(!("Undying" in A.T_Injections))
			A.T_Injections+="Undying"
			A.Recovery*=2
			A.Regenerate+=1
			A.Res/=2
			A.ResMod/=2
			A.Original_Decline*=0.8
			A.Decline*=0.8
			view(usr)<<"[usr] injects [A] with a mysterious needle!"
			del(src)
		else usr<<"[A] has already used [src]"
obj/items/T_Life
	Stealable=1
	desc="This will slow your decline IMMENSELY. Extending your lifespan nearly 4x its normal amount."
	icon='Item, Needle.dmi'
	verb/Use(mob/A in view(1,usr)) if(A==usr||A.Frozen||A.KO)
		if(A.Android)
			usr<<"This has no effect on androids"
			return
		if(!("Life" in A.T_Injections))
			A.T_Injections+="Life"
			A.Decline_Rate*=0.25
			A.Original_Decline*=0.8
			A.Decline*=0.8
			view(usr)<<"[usr] injects [A] with a mysterious needle!"
			del(src)
		else usr<<"[A] has already used [src]"
mob/var/list/T_Injections=new
mob/proc/Zombie_Virus_Loop()
	spawn while(src&&Zombie_Power)
		Zombie_Power*=0.9998
		Zombie_Power-=1
		if(Zombie_Power<1)
			Zombie_Power=0
			overlays-='Red Eyes.dmi'
		sleep(10)
	spawn while(src&&Zombie_Virus)
		Zombie_Virus+=0.1
		if(Zombie_Power||Android||Zombie_Immune) Zombie_Virus=0
		Health-=Zombie_Virus*0.05
		if(Health<=0) Death("???!")
		if(Is_Cybernetic()) sleep(30)
		if(z==7) Zombie_Virus=0 //No zombies in heaven
		sleep(10)
mob/proc/Zombies(Can_Mutate=1) spawn(rand(500,700)) if(src&&Zombie_Virus)
	var/mob/Enemy/Zombie/Z=Zombie_Copy()
	if(!Can_Mutate) Z.Mutater=0
	Z.overlays+='Zombie.dmi'
	Z.underlays-='Pool of Blood.dmi'
	Z.name="Zombie"
	Z.Level=1
	del(src)
mob/var/Children=0 //How many times the zombie reproduced
mob/proc/Zombie_Reproduce() spawn(rand(0,1200)) while(src)
	if(Level!=1) return //Mutated Zombies no longer reproduce
	if(!KO)
		if(Mutater) Mutate()
		else if(Zombies<Max_Zombies&&!(locate(/mob/Enemy/Zombie) in oview(2,src)))
			Zombie_Copy()
			Children++
	sleep(rand(0,1200))
mob/proc/Zombie_Lifespan() return
mob/proc/Zombie_Initialize()
	Zombie_Reproduce()
	Zombie_Door_Attack()
	Zombie_Lifespan()
mob/proc/Zombie_Copy()
	var/mob/Enemy/Zombie/Q=new(loc)
	Q.Enlarged=Enlarged
	Q.Zombie_Virus=Zombie_Virus
	Q.Flyer=Flyer
	Q.BP=BP
	Q.Body=Body
	Q.Gravity_Mastered=Gravity_Mastered
	Q.Base_BP=Base_BP
	Q.BP_Mod=BP_Mod
	Q.Str=Str
	Q.End=End
	Q.Res=Res
	Q.Spd=Spd
	Q.Off=Off
	Q.Def=Def
	Q.StrMod=StrMod
	Q.EndMod=EndMod
	Q.ResMod=ResMod
	Q.SpdMod=SpdMod
	Q.OffMod=OffMod
	Q.DefMod=DefMod
	Q.Regeneration=Regeneration
	Q.Recovery=Recovery
	Q.icon=icon
	Q.overlays=overlays
	Q.name=name
	Q.Level=Level
	if(!istype(src,/mob/Enemy/Zombie))
		Q.Str*=2
		Q.StrMod*=2
		Q.Spd/=2
		Q.SpdMod/=2
		Q.Off/=2
		Q.OffMod/=2
		Q.Def/=4
		Q.DefMod/=4
	//Q.Target=src
	for(var/obj/Stun_Chip/A in src)
		var/obj/Stun_Chip/B=new
		B.Password=A.Password
		Q.contents+=B
	return Q
mob/proc/Zombie_Door_Attack()
	spawn while(src)
		if(prob(50))
			var/obj/D
			for(var/obj/Turfs/Door/T in view(5,src))
				D=T
				break
			if(D)
				var/Steps=rand(0,200)
				while(Steps&&D&&D.density)
					Steps-=1
					step_towards(src,D)
					Melee()
					sleep(3)
		sleep(rand(0,6000))
var/Zombies=0
mob/Enemy/Zombie
	Zombie_Virus=1
	Spawn_Timer=0
	Savable_NPC=1
	Enlargement_Chance=0
	New()
		Zombies++
		if(prob(90)) Mutater=0
		Zombie_Initialize()
		..()
	Del()
		Zombies--
		..()
obj/items/T_Virus_Injection
	Cost=1000000
	icon='T Virus.dmi'
	Level=1
	Stealable=1
	Injection=1
	desc="This is a virus that creates Zombies. Inject someone with it to infect them. Even dead bodies can be \
	brought back to life in a horrible way."
	verb/Use(mob/A in view(1,usr))
		if(A==usr||A.KO||A.Frozen||!A.client)
			if(A.Android)
				usr<<"Injecting them would have no effect because they are an Android"
				return
			view(usr)<<"[usr] injects [A] with a mysterious needle!"
			if(istype(A,/mob/Enemy/Zombie))
				if(A.Level==1) A.Mutate()
			else
				if(A.client&&!A.Zombie_Virus) A.Zombie_Virus_Loop()
				A.Zombie_Virus+=Level
				if(!A.client) A.Zombies() //A zombie will bust out of A soon
			del(src)
obj/items/Antivirus
	icon='Antivirus.dmi'
	Stealable=1
	Level=1
	Cost=100000000
	verb/Use()
		if(usr.Android)
			usr<<"This has no effect on androids"
			return
		view(usr)<<"[usr] uses the [src] and all infection disappears"
		usr.Zombie_Virus=0
		usr.Diarea=0
		del(src)
	verb/Synthesize()
		set src in view(1)
		var/list/L=list("Cancel")
		if(usr.Res()>=1000000000/usr.Intelligence) L[new/obj/Bio_Field_Generator]=1000000000/usr.Intelligence
		if(usr.Res()>=50000000/usr.Intelligence) L[new/obj/items/T_Heal]=50000000/usr.Intelligence
		if(usr.Res()>=300000000/usr.Intelligence) L[new/obj/items/T_Energy]=300000000/usr.Intelligence
		if(usr.Res()>=50000000/usr.Intelligence) L[new/obj/items/T_Vitality]=50000000/usr.Intelligence
		if(usr.Res()>=50000000/usr.Intelligence) L[new/obj/items/T_Strength]=50000000/usr.Intelligence
		if(usr.Res()>=50000000/usr.Intelligence) L[new/obj/items/T_Fusion]=50000000/usr.Intelligence
		if(usr.Res()>=300000000/usr.Intelligence) L[new/obj/items/T_Undying]=300000000/usr.Intelligence
		if(usr.Res()>=300000000/usr.Intelligence) L[new/obj/items/T_Life]=300000000/usr.Intelligence
		if(usr.Res()>=300000000/usr.Intelligence) L[new/obj/items/T_Regeneration]=300000000/usr.Intelligence
		if(usr.Res()>=300000000/usr.Intelligence) L[new/obj/items/T_Recovery]=300000000/usr.Intelligence
		if(usr.Res()>=300000000/usr.Intelligence) L[new/obj/items/T_Snake]=300000000/usr.Intelligence
		if(usr.Res()>=300000000/usr.Intelligence) L[new/obj/items/T_Scorpion]=300000000/usr.Intelligence
		if(usr.Res()>=300000000/usr.Intelligence) L[new/obj/items/T_Spider]=300000000/usr.Intelligence
		if(L.len<=1)
			usr<<"You can not afford any of the options within this. It cost billions."
			return
		var/obj/O=input("You can synthesize and mutate this into many different uses. Choose one below") in L
		if(!O||O=="Cancel"||usr.Res()<L[O]) return
		switch(alert("[O] costs [Commas(L[O])] resources. Accept?","Options","Yes","No"))
			if("No") return
		usr.Alter_Res(-L[O])
		if(istype(O,/obj/items)) usr.contents+=O
		else O.loc=usr.loc
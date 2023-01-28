mob/var/tmp
	mob/GrabbedMob
	grabberSTR
atom/movable/var/Grabbable=1
mob/verb/Grab()
	set category="Skills"
	Safezone() //see safezone proc, related to having dragon balls
	if(Action in list("Meditating","Training")) return
	if(GrabbedMob)
		if(ismob(GrabbedMob)) GrabbedMob.grabberSTR=0
		GrabbedMob=null
	else if(!KO&&z)
		var/list/L=new
		for(var/atom/movable/O in get_step(src,dir)) if(O.Grabbable&&!(O.name in L)) L+=O.name
		L+="Cancel"
		var/T
		if(L.len<=2)
			L-="Cancel"
			for(var/V in L) T=V
		else T=input(src,"Grab what?") in L
		if(T=="Cancel") return
		var/obj/O
		for(var/atom/movable/A in get_step(src,dir)) if(A.name==T)
			O=A
			break
		if(!O) return
		if(ismob(O))
			var/mob/Temp=O
			if(Temp.Safezone)
				src<<"You can not grab people in safezones"
				return
			if(Temp.Prisoner())
				src<<"You can not grab prisoners"
				return
		if(ismob(O)&&(src in All_Entrants)&&z==7)
			src<<"You can not grab people in tournaments"
			return
		if(isobj(O)&&O.Bolted)
			src<<"It is bolted, you can not get it."
			return
		if(istype(O,/obj/Resources))
			view(src)<<"[src] picks up [O]"
			var/obj/Resources/R=O
			Alter_Res(R.Value)
			del(O)
		else if(istype(O,/obj/items)||istype(O,/obj/Module))
			view(src)<<"[src] picks up [O]"
			if(istype(O,/obj/items/Gravity)) O:Deactivate()
			contents+=O
		else
			GrabbedMob=O
			if(ismob(O))
				var/mob/M=O
				M.grabberSTR=Str*BP
			grab()
mob/proc/grab()
	while(GrabbedMob)
		GrabbedMob.loc=loc
		if(ismob(GrabbedMob))
			GrabbedMob.grabberSTR=Str*BP
			GrabbedMob.dir=turn(dir,180)
			if(istype(GrabbedMob,/mob/Body)) if(Cook_Check(GrabbedMob)) Cook(GrabbedMob)
		if(KO)
			view()<<"[usr] is forced to release [GrabbedMob]!"
			if(ismob(GrabbedMob)) GrabbedMob.grabberSTR=0
			attacking=0
			GrabbedMob=null
		sleep(1)
mob/var/tmp/list/Lootables
obj/Cancel_Loot
	name="Cancel"
	Click() usr.Lootables=null
client/Click(obj/A)
	if(A in Technology_List)
		if(mob.KO) return
		if(locate(A.type) in Illegal_Science)
			src<<"<font size=3><font color=red>Admins have made this item illegal. You can not make it"
			return
		if(Can_Make_Technology(mob,A)) for(var/obj/Resources/M in mob)
			M.Value-=Technology_Price(mob,A)
			var/obj/O=new A.type(mob.loc)
			if(O)
				O.Builder=key

				if(istype(O,/obj/Ships/Ship)&&mob.Race=="Puran")
					O.icon='Puran Ship.dmi'
					Center_Icon(O)
				if(istype(O,/obj/items/Scouter)&&mob.Race=="Human")
					O.icon='Item - Sun Glassess.dmi'
					O.name="Scanner"

			spawn if(!O) M.Value+=Technology_Price(mob,A)
	else if(mob.Lootables&&mob&&isobj(A)&&(A in mob.Lootables)&&!istype(A,/obj/Cancel_Loot)) for(var/mob/B in view(1,mob)) if(A in B)
		if(!B.KO)
			usr<<"They are no longer knocked out"
			mob.Lootables=null
			return
		if(!(A in B))
			src<<"Someone has already taken it"
			mob.Lootables-=A
			return
		if(!(B in oview(1,mob)))
			src<<"You are not near them"
			mob.Lootables=null
		view(mob)<<"[mob]([mob.displaykey]) steals [A] from [B]"
		mob.Lootables-=A
		if(istype(A,/obj/Resources))
			var/obj/Resources/C=A
			mob.Alter_Res(C.Value)
			C.Value=0
		else
			B.overlays-=A.icon
			if(A.suffix)
				if(istype(A,/obj/items/Sword)) B.Apply_Sword(A)
				if(istype(A,/obj/items/Armor)) B.Apply_Armor(A)
			mob.contents+=A
			if(A.suffix=="Equipped") A.suffix=null
	else if(A in Alien_Icons) A:Choose(usr)
	else if(A in Demon_Icons) A:Choose(usr)
	else ..()
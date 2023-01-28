				if("Make Clone")
					var/res_cost=1000000/usr.Intelligence**0.2
					if(usr.Res()<res_cost) alert("You need [Commas(res_cost)] resources to do this")
					else
						var/list/Clonables=list("Cancel")
						for(var/obj/items/DNA_Container/D in usr.item_list) if(D.Clone) Clonables+=D
						if(!(locate(/obj) in Clonables))
							usr<<"You can not do this because you must have a DNA container with someone's DNA in it."
							return
						var/obj/items/DNA_Container/D=input("What DNA to use to make the clone?") in Clonables
						if(!D||D=="Cancel") return
						switch(alert("This will cost [Commas(res_cost)] resources. Accept?","Options","Yes","No"))
							if("No") return
						if(usr.Res()<res_cost) return
						usr.Alter_Res(-res_cost)
						var/mob/P=D.Clone.Duplicate()
						P.loc=loc
						player_view(15,src)<<"[src]: Clone created using [D]"








mob/proc/Clone()
	var/mob/P=Duplicate()
	P.bp_tier=1
	P.Experience=0 //no SP
	P.Disable_Modules()
	P.cyber_bp=0
	P.base_bp*=0.95
	P.hbtc_bp*=0.95
	P.max_ki*=0.6
	P.Ki*=0.6
	P.Knowledge*=0.95
	if(P.gravity_mastered>=50) P.gravity_mastered*=0.5
	P.Original_Decline=5
	P.Decline=5
	P.Decline_Rate*=3
	P.Age=0
	for(var/obj/Injuries/I in P.injury_list) del(I)
	P.Alter_Res(-P.Res())
	for(var/obj/items/I in P.item_list) if(I.suffix!="Equipped") del(I)
	for(var/obj/Stun_Chip/O in P) del(O)
	for(var/obj/Module/M in P) del(M)
	P.Full_Heal()
	return P

mob/proc/Duplicate(include_unclonables=0)
	var/list/L=new
	for(var/mob/M in src)
		L+=M
		contents-=M
	if(!include_unclonables) for(var/obj/O in src) if(!O.clonable)
		L+=O
		contents-=O
		item_list-=O
		hotbar-=O
	Save_Obj(src)
	var/mob/M=new
	Load_Obj(M)
	M.Savable_NPC=1
	for(var/V in L)
		if(ismob(V)) contents+=V
		else if(isobj(V))
			var/obj/o=V
			o.Move(src)
	M.Status_Running=0
	return M

proc/Save_Obj(obj/O) if(O)
	var/savefile/F=new("Blueprint")
	O.Write(F)
	if(F["key"]) F["key"]<<null

proc/Load_Obj(obj/O) if(O)
	var/savefile/F=new("Blueprint")
	O.Read(F)
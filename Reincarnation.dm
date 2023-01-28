obj/Reincarnation
	var/Last_Use=0
	Skill=1
	teachable=1
	Teach_Timer=1
	Cost_To_Learn=20
	desc="Use this to reincarnate someone as a 'different person'. They may lose some power and more. \
	Face them and use it."
	New()
		if(!Last_Use) Last_Use=Year
		..()
	verb/Reincarnate()
		set category="Skills"
		if(usr.Is_Cybernetic())
			usr<<"Cybernetic beings cannot use this ability"
			return
		/*if(Year<Last_Use+5)
			usr<<"You can not use this til year [Last_Use+5]"
			return*/
		var/list/Mobs=list("Cancel")
		for(var/mob/M in get_step(usr,usr.dir)) if(M.client) Mobs+=M
		Mobs+=usr
		var/mob/P=input("Who do you want to reincarnate?") in Mobs
		if(!P||P=="Cancel") return
		if(P.client&&P.client.address==usr.client.address&&P!=usr)
			usr<<"You can not reincarnate alts"
			return
		P.Reincarnate(usr)
mob/proc/Reincarnate(mob/m) //m = offerer
	if(m)
		switch(alert(src,"[m] has offered to reincarnate you, if you accept you will come back to life \
		as a 'different person' with a loss of some power.","Options","No","Yes"))
			if("No")
				view(src)<<"[src] denied [m]'s offer to be reincarnated"
				return
	if(m) for(var/obj/Reincarnation/R in m) R.Last_Use=Year
	Alter_Res(-Res())
	Disable_Modules()
	for(var/obj/Module/M in src) del(M)
	Revert_All()
	for(var/obj/items/I in src) if(!istype(I,/obj/items/Clothes)) del(I)
	for(var/obj/Curse/O in src) del(O)
	available_potential=0.01
	Base_BP*=0.9
	Str*=0.9
	End*=0.9
	Pow*=0.9
	Res*=0.9
	Spd*=0.9
	Off*=0.9
	Def*=0.9
	Knowledge*=0.9
	if(Gravity_Mastered>20)
		Gravity_Mastered*=0.7
		if(Gravity_Mastered<20) Gravity_Mastered=20
	Revive()
	Respawn()
mob/proc/Revert_All()
	Revert()
	Shield_Revert()
	Stop_Powering_Up()
	Limit_Revert()
	Majin_Revert()
	Mystic_Revert()
	Third_Eye_Revert()
	Werewolf_Revert()
	Kaioken_Revert()
	for(var/obj/items/Armor/A in src) if(A.suffix) Apply_Armor(A)
	for(var/obj/items/Sword/S in src) if(S.suffix) Apply_Sword(S)
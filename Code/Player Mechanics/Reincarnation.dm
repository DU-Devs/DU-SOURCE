obj/Reincarnation
	var/Last_Use=0
	Skill=1
	teachable=1
	Teach_Timer=2
	student_point_cost = 30
	hotbar_type="Support"
	can_hotbar=1
	Cost_To_Learn=20
	desc="Use this to reincarnate someone as a 'different person'. They may lose some power and more. \
	Face them and use it."
	New()
		if(!Last_Use) Last_Use=Year
		. = ..()
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Reincarnate()
	verb/Reincarnate()
		set category="Skills"
		if(usr.Is_Cybernetic())
			usr<<"Cybernetic beings cannot use this ability"
			return
		/*if(Year<Last_Use+5)
			usr<<"You can not use this til year [Last_Use+5]"
			return*/
		var/list/Mobs=list("Cancel")
		for(var/mob/M in Get_step(usr,usr.dir)) if(M.client) Mobs+=M
		Mobs+=usr
		var/mob/P=input("Who do you want to reincarnate?") in Mobs
		if(!P||P=="Cancel") return
		if(P.client&&P.client.address==usr.client.address&&P!=usr)
			usr<<"You can not reincarnate alts"
			return
		P.Reincarnate(usr)
mob/var/last_reincarnate=0
mob/proc/Reincarnate(mob/m) //m = offerer
	if(m)

		var/minutes=30
		if(world.realtime<last_reincarnate+(minutes*60*10))
			var/minutes_left=last_reincarnate + minutes*60*10 - world.realtime
			minutes_left/=60*10
			m<<"[src] can not be revived because they were revived less than [minutes] minutes ago. They \
			must wait another [round(minutes_left)] minutes and [round(minutes_left%60)] seconds to be revived \
			again by the revive skill"
			src<<"[m] tries to revive you, but you were revived less than [minutes] minutes ago, and must \
			wait another [round(minutes_left)] minutes and [round(minutes_left%60)] seconds to be revived \
			again by the revive skill"
			return

		switch(alert(src,"[m] has offered to reincarnate you, if you accept you will come back to life \
		as a 'different person' with a loss of some power.","Options","No","Yes"))
			if("No")
				player_view(15,src)<<"[src] denied [m]'s offer to be reincarnated"
				return
			if("Yes")
				if(KO)
					src<<"You can not reincarnate yourself while you are knocked out (To prevent death avoiding)"
					return
	if(m) for(var/obj/Reincarnation/R in m) R.Last_Use=Year

	//Alter_Res(-Res())
	last_reincarnate=world.realtime
	Disable_Modules()
	for(var/obj/Module/M in src) del(M)
	Revert_All()
	for(var/obj/items/I in item_list) if(!istype(I,/obj/items/Clothes)) del(I)
	//for(var/obj/Curse/O in src) del(O)
	available_potential=reincarnation_loss
	Age = 1
	/*base_bp*=0.9
	Str*=0.9
	End*=0.9
	Pow*=0.9
	Res*=0.9
	Spd*=0.9
	Off*=0.9
	Def*=0.9
	Knowledge*=0.9
	if(gravity_mastered>20)
		gravity_mastered*=0.7
		if(gravity_mastered<20) gravity_mastered=20*/
	Revive()
	Respawn()

mob/proc/Revert_All()
	Revert()
	if(using_giant_form) Disable_giant_form()
	Shield_Revert()
	Stop_Powering_Up()
	Limit_Revert()
	Majin_Revert()
	Mystic_Revert()
	Third_Eye_Revert()
	Great_Ape_revert()
	God_Fist_Revert()
	for(var/obj/items/Armor/A in src) if(A.suffix) Apply_Armor(A)
	for(var/obj/items/Sword/S in src) if(S.suffix) Apply_Sword(S)
	revert_all_buffs()
	Undo_all_t_injections()
	Disable_Modules()
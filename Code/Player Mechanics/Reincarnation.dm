obj/Skills/Divine/Reincarnation
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
		if(!Last_Use) Last_Use=GetGlobalYear()
		. = ..()
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Reincarnate()
	verb/Reincarnate()
		set category = "Skills"
		if(usr.Is_Cybernetic())
			usr.SendMsg("Cybernetic beings cannot use this ability", CHAT_IC)
			return
		var/list/Mobs=list("Cancel")
		for(var/mob/M in Get_step(usr,usr.dir)) if(M.client) Mobs+=M
		Mobs+=usr
		var/mob/P=input("Who do you want to reincarnate?") in Mobs
		if(!P||P=="Cancel") return
		if(P.client&&P.client.address==usr.client.address&&P!=usr)
			usr.SendMsg("You can not reincarnate alts", CHAT_IC)
			return
		if(P.IsFusion())
			usr.SendMsg("Fused mobs can not be reincarnated!", CHAT_IC)
			return
		P.Reincarnate(usr)
mob/var/last_reincarnate=0
mob/proc/Reincarnate(mob/m) //m = offerer
	if(src.IsFusion()) return
	if(m)

		var/minutes=30
		if(world.realtime<last_reincarnate+(minutes*60*10))
			var/minutes_left=last_reincarnate + minutes*60*10 - world.realtime
			minutes_left/=60*10
			m.SendMsg("[src] can not be revived because they were revived less than [minutes] minutes ago. They \
			must wait another [round(minutes_left)] minutes and [round(minutes_left%60)] seconds to be revived \
			again by the revive skill.", CHAT_IC)
			src.SendMsg("[m] tries to revive you, but you were revived less than [minutes] minutes ago, and must \
			wait another [round(minutes_left)] minutes and [round(minutes_left%60)] seconds to be revived \
			again by the revive skill.", CHAT_IC)
			return

		switch(alert(src,"[m] has offered to reincarnate you, if you accept you will come back to life \
		as a 'different person' with a loss of some power.","Options","No","Yes"))
			if("No")
				for(var/mob/h in player_view(15,src))
					h.SendMsg("[src] denied [m]'s offer to be reincarnated", CHAT_IC)
				return
			if("Yes")
				if(KO)
					src.SendMsg("You can not reincarnate yourself while you are knocked out (To prevent death avoiding)", CHAT_IC)
					return
	if(m) for(var/obj/Skills/Divine/Reincarnation/R in m) R.Last_Use=GetGlobalYear()

	//Alter_Res(-Res())
	last_reincarnate=world.realtime
	Disable_Modules()
	for(var/obj/Module/M in src) del(M)
	Revert_All()
	for(var/obj/items/I in item_list) if(!istype(I,/obj/items/Clothes)) del(I)
	//for(var/obj/Curse/O in src) del(O)
	available_potential=Mechanics.GetSettingValue("Reincarnation BP Limit Multiplier")
	Age = 1
	Revive()
	Respawn()

mob/proc/Revert_All()
	Shield_Revert()
	Stop_Powering_Up()
	Great_Ape_revert()
	God_Fist_Revert()
	revert_all_buffs()
	Undo_all_t_injections()
	for(var/t in UnlockedTransformations)
		var/transformation/T = UnlockedTransformations[t]
		if(!T) continue
		T.ExitForm(src)
	Disable_Modules()
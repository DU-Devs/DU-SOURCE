obj/items/clonable=0

proc/Switch_Bodies(mob/A,mob/P,save_override)
	if(!A.client) return
	var/Key1=A.key
	var/Key2
	if(P.client) Key2=P.key
	//switch imprisonments
	var/A_imprisonments=A.Imprisonments
	A.Imprisonments=P.Imprisonments
	P.Imprisonments=A_imprisonments

	var/list/a_curse=new
	var/list/p_curse=new
	for(var/obj/o in A) if(o.type==/obj/Prisoner_Mark || o.type==/obj/Curse) a_curse+=o
	for(var/obj/o in P) if(o.type==/obj/Prisoner_Mark || o.type==/obj/Curse) p_curse+=o
	for(var/obj/o in a_curse) o.loc=P
	for(var/obj/o in p_curse) o.loc=A
	//---
	var/view_x=A.ViewX
	var/view_y=A.ViewY
	A.ViewX=P.ViewX
	A.ViewY=P.ViewY
	P.ViewX=view_x
	P.ViewY=view_y
	P.Savable_NPC=1
	A.Savable_NPC=1
	P.FullHeal()
	A.FullHeal()
	P.logout_timer=0
	A.logout_timer=0
	P.Auto_Attack=0
	A.Auto_Attack=0
	players.Remove(A,P)
	if(!P.client) P.Player_Loops(start_delay = 10)
	var/mob/Temp=new
	if(Key2) Temp.key=Key2
	P.key=Key1
	if(Key2) A.key=Key2

	if(P&&P.client)
		P.client.show_verb_panel=1
		P.Savable_NPC=0
		P.Tabs=2
		P.LoadFeats()
		if(!(P in players)) players+=P
		if(!save_override)
			P.Savable=1
			P.Save()
		P.DetermineViewSize()
		P.Restore_hotbar_from_IDs()

	if(A&&A.client)
		P.client.show_verb_panel=1
		A.Savable_NPC=0
		A.Tabs=2
		A.LoadFeats()
		if(!(A in players)) players+=A
		if(!save_override)
			A.Savable=1
			A.Save()
		A.DetermineViewSize()
		A.Restore_hotbar_from_IDs()




var/activebodyswapsnulllocloop

proc/ActiveBodySwapsNullLocLoop()
	set waitfor=0
	if(activebodyswapsnulllocloop) return
	activebodyswapsnulllocloop = 1

	while(1)
		for(var/v in active_body_swaps)
			var/list/l = active_body_swaps[v]
			for(var/mob/m in l) m.SafeTeleport(null)
		sleep(10)

	activebodyswapsnulllocloop = 0

mob/proc/BodySwapVictim()
	for(var/v in active_body_swaps)
		var/list/l = active_body_swaps[v]
		for(var/mob/m in l)
			if(m == src) return 1

//we use this to store who is body swapped with who, because the old way of just putting the 2 original mobs inside the contents of the temp mob was the cause
//of so many horrible bugs, mostly duplication bugs
var/list/active_body_swaps = new

proc
	RecordActiveBodySwap(mob/temp_body, mob/user, mob/other_player)
		active_body_swaps -= temp_body
		active_body_swaps += temp_body

		var/list/l = list(user, other_player)

		active_body_swaps[temp_body] = l

mob/var/tmp/is_body_swap_mob

obj/Body_Swap
	Givable=1
	hotbar_type="Ability"
	can_hotbar=1
	desc="Allows you to jump into another person's body, like Bebi. They must be below 100% health for you to jump \
	into their body, because there must be a cut that you can jump into."
	var/Undo_Body_Swap

	verb/Hotbar_use()
		set hidden=1
		Body_Swap()

	verb/Body_Swap()
		set category="Skills"

		//usr<<"THIS IS OFF DUE TO BUGS"
		//return

		for(var/obj/Body_Swap/bs in usr) if(bs.loc == usr && bs.Undo_Body_Swap)
			//had to use this code in case you body swap a body swapper you then have 2 body swap verbs it
			//needs to find the right one
			usr.Bebi_Undo()
			return

		if(usr.tournament_override(fighters_can=0)) return
		var/mob/other_player
		for(var/mob/M in Get_step(usr,usr.dir)) if(M!=usr) other_player=M

		if(alignment_on&&both_good(usr,other_player))
			usr<<"You can not use this against other good people"
			return
		if(!other_player)
			usr<<"You must be next to the target to jump into their body, and facing themt"
			return
		if(!other_player.client)
			usr<<"You can only body swap into players"
			return
		if(other_player.Safezone)
			usr<<"They are in a safezone you can not body swap them"
			return
		if(!other_player.Angry() && !other_player.KO)
			usr<<"[other_player] must be angered for you to steal their body"
			return
		if(ismob(usr.loc))
			usr<<"You can not jump into more than 1 person at a time"
			return
		if(other_player.empty_player)
			usr << "You can not body swap into logged out players"
			return

		if(!other_player||other_player=="Cancel") return
		player_view(15,usr)<<"[usr] tries to jump into [other_player]'s body!"

		//temp_body is the new 3rd body created to act as a clone of the victim so you can control it and its as if you are them
		var/mob/temp_body = other_player.Duplicate()
		temp_body.Savable=0
		temp_body.is_body_swap_mob = 1
		for(var/mob/m in temp_body) del(m)

		var/obj/Body_Swap/B = new
		B.Undo_Body_Swap = 1
		temp_body.contents+=B

		if(!other_player||!usr||other_player.Firewall(usr))
			if(usr) usr.Get_Observe(usr)
			if(temp_body) del(temp_body)
			return

		RecordActiveBodySwap(temp_body, usr, other_player)

		usr.Get_Observe(temp_body)
		other_player.Get_Observe(temp_body)
		usr.Attack_Gain(500,other_player,apply_hbtc_gains=0,include_weights=0)
		temp_body.displaykey=usr.displaykey
		temp_body.SafeTeleport(other_player.loc)
		if(temp_body) temp_body.OldTransGraphicsNoWait()
		temp_body.overlays-=temp_body.hair
		temp_body.hair+=rgb(100,100,100)
		temp_body.overlays+=temp_body.hair
		//temp_body.overlays+='Bebi Markings.dmi'
		temp_body.cyber_bp=usr.cyber_bp
		temp_body.displaykey=usr.displaykey

		other_player.Alter_Res(-other_player.Res())
		temp_body.SetRes(usr.Res()) //set the temporary mob's resources to 0 for now to prevent that resource duplication bug
			//with further changes this could be removed, it might even be fixed and i wouldnt know

		for(var/obj/items/I in other_player.item_list) if(!I.ignore_body_swap)
			other_player.item_list-=I
			del(I)

		for(var/obj/items/I in temp_body) if(I.ignore_body_swap)
			temp_body.item_list-=I
			del(I)

		other_player.FullHeal()
		usr.FullHeal()
		temp_body.FullHeal()
		other_player.logout_timer=0
		usr.logout_timer=0
		temp_body.logout_timer=0
		other_player.Save()
		usr.Save()

		temp_body.BodySwapTimeLimitLoop()
		ActiveBodySwapsNullLocLoop()
		Switch_Bodies(usr,temp_body,save_override=1)

mob/proc/BodySwapTimeLimitLoop()
	set waitfor=0
	sleep(body_swap_time_limit * 600)
	Bebi_Undo()

obj/var/ignore_body_swap=0

//this is NOT whether you are the victim of a body swap, but if you are the user of body swap and are currently in the temporary body
mob/proc/body_swapped()
	for(var/obj/Body_Swap/B in src) if(B.Undo_Body_Swap) return 1

mob/proc/Bebi_Undo(logout) //Undoes the effects of Bebi taking over someone's body

	var/list/l = active_body_swaps[src]
	active_body_swaps[src] = null
	active_body_swaps -= src

	//victim
	for(var/mob/P in l) if(P.displaykey!=displaykey)
		P.SafeTeleport(loc)
		P.Get_Observe(P)
		//P.Alter_Res(Res())
		for(var/obj/items/I in src)
			if(I.suffix=="Equipped") I.suffix=null
			I.Move(P)
			P.contents -= I
			P.contents += I
		if(P)
			P.Save()
			P.KO()

	//your original body
	for(var/mob/P in l) if(P.displaykey==displaykey)
		P.SafeTeleport(loc)
		P.Get_Observe(P)
		Switch_Bodies(src,P,save_override=1)
		P.SetRes(Res())
		P.Save()
		if(logout)
			P.Logout(body_swap_user = 1)
			if(P) del(P)
		del(src)

mob/proc/Logout_and_delete_bebi(mob/m)
	del(m)
	Logout()

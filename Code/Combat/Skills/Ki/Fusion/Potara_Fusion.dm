//////////////////////////////////////////////////////////////////////
//						Potara Fusion System						//
//	Potara fusion requires two mobs with a client attached to work.	//
//	Mob A will be the active/initiating player.						//
//	Mob B will be the inactive/confirming player.					//
//	Player power will be increased using a function that scales		//
//	with their combined power level compared to server average.		//
//	T = A.base_bp + B.base_bp;	avg = average bp of server			//
//	Fusion BP = round(2 ** (avg * 1.5 / T) * (T),1)		 			//
//	Minimum multiplier = 1.3, maximum multiplier = 2.2				//
//////////////////////////////////////////////////////////////////////
//	Will allow races that aren't the same to fuse, barring a few	//
//	exceptions.  Races that can not fuse are as follows:			//
//	Frost Lord, Bio-Android, Majin, and Jiren Aliens.  This is as 	//
//	much because of balance concerns as it is because they lack		//
//	anywhere to wear the ear rings. Mating is disabled while fused.	//
//////////////////////////////////////////////////////////////////////
//	Potara fusion will operate on a timer and have a cooldown.		//
//	Cooldown will be 2 hours long by default, and be tied to the	//
// 	Potara item, not the player who used it.  Multiplier setting	//
//	for admins will likely be added to increase/decrease the CD.	//
//	The timer will decrease at a rate that is modified by the 		//
//	fusion mob's current bp in comparison to its base bp.			//
//	This means any transformations or means of increasing your BP	//
//	will strain the fusion and cause you to defuse sooner.			//
//////////////////////////////////////////////////////////////////////

#ifdef DEBUG
mob/Admin5/verb/ForceCheckBecomeNormal()
	set category = "DEBUG"
	for(var/mob/fusion/potara/M in players)
		M.CheckBecomeNormal(1)

mob/Admin5/verb/Simulate_Potara_CD()
	set category = "Admin"
	var/useTest = Time.Record(2)
	var/timeRemaining = Time.GetTimeRemaining(useTest, Time.FromHours(3), 2)
	usr << "([Time.GetRoundedTime(timeRemaining)] )"
#endif

mob/Admin5/verb/Reset_All_Potara_CDs()
	set category = "Admin"
	for(var/obj/items/Potara/P in world)
		P.lastUse = 0
	

var
	list
		canNotPotara = list("Frost Lord", "Bio-Android", "Majin")
obj/items/Potara
	name = "Potara Earrings"
	icon = 'Potara Earrings.dmi'
	Cost = 0
	var
		lastUse
		cooldownRemaining
	
	New()
		..()
		transform *= 0.25
		spawn UpdateCooldown()
	
	proc/UpdateCooldown()
		set background = TRUE
		while(TRUE)
			if(cooldownRemaining > 0) cooldownRemaining--
			else cooldownRemaining = 0
			sleep(1)

	verb
		Throw_Potara()
			set src in usr
			set category = "Skills"
			if(usr.fusing) return
			if(usr.attacking) return
			if(usr.IsFusion())
				usr << "Fusions can not stack!"
				return
			if(canNotPotara.Find(usr.Race))
				usr << "You have no means of using the Potara!"
				return
			if(usr.Regenerating)
				usr << "You can't fuse while regenerating!"
				return
			if(usr.IsGreatApe())
				usr << "You can't fuse while a Great Ape!"
				return
			if(cooldownRemaining > 0)
				usr << "The Potara Earrings are inert.  Perhaps with time their power will return..."
				usr << "([Time.GetRoundedTime(cooldownRemaining)] )"
				return
			var/client/C = usr.client
			C.mob.fusing = 1
			. = ResetFusingVar(list(C.mob))
			var/list/fusionCandidates = new
			for(var/mob/M in oview(usr,20))
				if(canNotPotara.Find(M.Race)) continue
				if(!IsValidFusionCandidate(M)) continue
				//for(var/mob/m in M.contents) fusionCandidates.Add(m)
				fusionCandidates.Add(M)
			if(fusionCandidates.len > 1) fusionCandidates.Insert(1,"Cancel")
			var/mob/B = input("Select who to fuse with!","Fusion!") as anything in fusionCandidates
			if(!B || B == "Cancel") return
			B.fusing = 1
			. = ResetFusingVar(list(C.mob, B))
			if(C.mob.z != B.z) return
			if(!(C.mob.IsCodedAdmin()) && (C&&B.client&&C.address==B.client.address))
				usr << "You can not fuse with an alt!"
				return
			if(B.attacking)
				usr << "[B.name] is busy and can not fuse right now!"
				B << "[src.name] is trying to fuse with you, but you are busy!"
				return
			usr << "You toss a Potara Earring to [B.name]!"
			var/dialog/d = new
			spawn(200) del(d)
			switch(d.Ask(B, "[usr.name] has thrown a Potara Earring to you!", "Fuse", list("Deny", "Accept")))
				if(null) return
				if("Deny") return
			if(!IsValidFusionCandidate(C.mob) || !IsValidFusionCandidate(B)) return
			if(C.mob.z != B.z) return
			C.mob.AlterInputDisabled(1)
			B.AlterInputDisabled(1)
			while(get_dist(C.mob,B) > 1 && C.mob.z == B.z)
				step_to(B,C.mob,0,32)
				B.AlignToTile()
				step_to(C.mob,B,0,32)
				C.mob.AlignToTile()
				sleep(world.tick_lag)
			sleep(1)
			C.mob.AlterInputDisabled(-1)
			B.AlterInputDisabled(-1)
			if(C.mob.z != B.z) return
			var/mob/fusion/potara/P = new(C.mob.loc)
			P.Create_Fusion(C.mob, B)
			if(!P) return
			lastUse = Time.Record(2)
			cooldownRemaining = Time.FromHours(fusionCD * fCDMod)
			usr << "Last use recorded at [time2text(lastUse)]."
			usr << "Should be usable at [time2text(lastUse + cooldownRemaining)]."
			usr << "Cooldown is[Time.GetRoundedTime(cooldownRemaining)]."
			view(P) << "[usr.name] and [B.name] have fused to become [P.name]!"
			P.SafeTeleport(locate(C.mob.x, C.mob.y, C.mob.z))
			C.mob = P

mob/var/kaiFusion

mob/fusion/potara
	var/initialAverage
	proc
		CheckBecomeNormal(force_check=0)
			if(Average_Base_BP_of_Players() > initialAverage * 2) return BecomeNormalMob()
			if(!force_check) spawn(150*60) CheckBecomeNormal()
		
		BecomeNormalMob()
			kaiFusion = 0
			alert("Fusion restrictions have been lifted.  Relog to solidify this change.")
			src.Save()

		KaiFusionPermanent(mob/A,mob/B)		//Handle the necessary actions to make Kai fusion permanent.
			src.initialAverage = Average_Base_BP_of_Players()
			verbs-= /mob/fusion/verb/Defuse
			fusees.Insert(1,"[src.key]")
			fusees["[src.key]"] = A
			B.Reincarnate()					//Reincarnate fusee B.
			B.SetRes(0)
			Remove_All_Items(B)
			B.Save()
			src.kaiFusion = 1
			fusees.len = 1
			spawn()
				while(A.key) sleep(world.tick_lag)
				while(A.loc!=src) A.loc = src; sleep(1)
				while(!src.key) sleep(world.tick_lag)
				src.Savable = 1
				src.Save()
				src.CheckBecomeNormal()
		
		Remove_All_Items(mob/M)
			for(var/obj/items/O in M.contents) del O
			for(var/obj/Module/O in M.contents) del O
	
	SetFusionVisuals(mob/A)
		..()
		overlays += image('Potara-Equipped.dmi')

	SetFusionBP(mob/A, mob/B)		//If the fusion is a Kai, give them 75% more power.  Otherwise, use default behavior.
		if(Race == "Kai") return ..() * 1.75
		return ..()


	//disabled due to bugs for now.  uncomment define to enable perma kai
	//#define KAI_PERM_FUSE
	#ifdef KAI_PERM_FUSE
	Create_Fusion(mob/A,mob/B)		//If the fusion is a Kai, make the fusion permanent by running KaiFusionPermanent(mob/A,mob/B).
		..()						//Default behavior is run beforehand either way.
		if(Race == "Kai") spawn KaiFusionPermanent(A,B)

	FusionLogoutHandler()
		if(Race == "Kai") return	//If the fusion is a Kai, don't defuse them when they log out.
		..()						//Otherwise, handle the logout like normal.

	RevertFusion()
		if(Race == "Kai") return	//If the fusion is a Kai, don't let them revert the fusion.  It's permanent.
		..()						//Otherwise, handle Reverting like normal.

	FusionTimer()
		if(Race == "Kai") return	//If the fusion is a Kai, there is no timer.  It's permanent.
		..()						//Otherwise, handle the Timer like normal.
	
	MoveFusees()
		if(Race == "Kai") return	//If the fusion is a Kai, we won't be storing the bodies inside the fusion like normal.
		..()						//Otherwise, store them as usual and do a checking loop every 1.5 seconds to move them back in.
	#endif

	GetFusionRace(mob/A,mob/B)		//If either fusee is a Kai but not both, use the race that isn't Kai.  Otherwise, use the race of mob A.
		//This can be made more complicated later with a dominant/recessive race system or something similar.
		//But this works for now.
		. = A.Race
		if(A.Race == "Kai" && B.Race != "Kai") return B.Race

	GetProperOrder(list/T1, list/T2, out1, out2)	//This determines the order two names should be connected in.
		if(T1.len == T2.len)						//Always results in the same combination for a set of two names, regardless
			if(length(GetFirstHalf(T1)) < length(GetFirstHalf(T2)))	// of who initiates the fusion.
				out1 = GetSecondHalf(T1)
				out2 = GetFirstHalf(T2)
				return out2 + out1
			if(length(GetSecondHalf(T1)) < length(GetSecondHalf(T2)))
				out1 = GetSecondHalf(T1)
				out2 = GetFirstHalf(T2)
				return out2 + out1
		if(T1.len > T2.len)
			out1 = GetSecondHalf(T1)
			out2 = GetFirstHalf(T2)
			return out2 + out1
		return out1 + out2

	GetFirstHalf(list/T)	//Prioritize the first half of the name being two syllables if possible.
		var/out				//Use the first syllables (either two if poosible, one if not) of the longer name.
		if(T.len > 3) out += "[T[2]][T[4]]"
		else out += "[T[1]]"
		return out

	GetSecondHalf(list/T)	//The second half of the name should take the last syllable of the shorter name.
		return "[T[T.len]]"
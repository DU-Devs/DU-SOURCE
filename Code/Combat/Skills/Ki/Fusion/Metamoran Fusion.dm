//////////////////////////////////////////////////////////////////////
//					Metamoran Fusion System							//
//	Meta fusion requires two mobs with a client attached to work.	//
//	Mob A will be the active/initiating player.						//
//	Mob B will be the inactive/confirming player.					//
//	Player power will be increased using a function that scales		//
//	with their combined power level compared to server average.		//
//	T = A.base_bp + B.base_bp;	avg = average bp of server			//
//	Fusion BP = round(2 ** (avg * 1.5 / T) * 1.5 * (T),1)		 	//
//	Minimum multiplier = 1.3, maximum multiplier = 2.2				//
//////////////////////////////////////////////////////////////////////
//	Only members of the same race may fuse.  There are no other 	//
//	restrictions.  Even different genders may fuse, though mating	//
//	while in a fusion is completely impossible.						//
//////////////////////////////////////////////////////////////////////
//	Meta fusion will operate on a timer and have a cooldown.		//
//	Cooldown will be 1 hour by default and tied to the player.		//
//  Multiplier setting for admins will likely be added to 			//
//	increase/decrease the CD.										//
//	The timer will decrease at a rate that is modified by the 		//
//	fusion mob's current bp in comparison to its base bp.			//
//	This means any transformations or means of increasing your BP	//
//	will strain the fusion and cause you to defuse sooner.			//
//////////////////////////////////////////////////////////////////////

proc/Hours2Deciseconds(n)
	return n * 60 * 60 * 10
var
	fusionCD = 2
	fCDMod = 1


mob/Admin5/verb/Reset_All_Fusion_Dance_CDs()
	set category = "Admin"
	for(var/mob/M in players)
		M.lastFusion = 0

mob/Admin5/verb/Test_Cooldown_Translation(n as num)
	set category = "Admin"
	if(!n) return
	usr << Time.ToSeconds(Time.FromHours(n))
	usr << "([Time.GetRoundedTime(Time.FromHours(n))] )"

mob
	var
		lastFusion
		oldKey
		icon/FusionVestIcon

obj/Skills/Fusion_Dance
	var/dance_mastery = 0
	Skill=1
	teachable=1
	student_point_cost = 100
	hotbar_type="Ability"
	can_hotbar=1

	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Fusion()

	verb
		Fusion()
			set src in usr
			set category = "Skills"
			if(usr.fusing) return
			if(usr.attacking) return
			if(usr.IsFusion())
				usr << "Fusions can not stack!"
				return
			if(usr.Regenerating)
				usr << "You can't fuse while regenerating!"
				return
			if(usr.IsGreatApe())
				usr << "You can't fuse while a Great Ape!"
				return
			var/client/C = usr.client
			C.mob.fusing = 1
			. = ResetFusingVar(list(C.mob))
			var/list/fusionCandidates = new
			for(var/mob/M in oview(usr,1))
				if(!IsValidFusionCandidate(M)) continue
				if(!(locate(/obj/Skills/Fusion_Dance) in M)) continue
				for(var/mob/m in M.contents) fusionCandidates.Add(m)
				fusionCandidates.Add(M)
			if(fusionCandidates.len > 1) fusionCandidates.Insert(1,"Cancel")
			var/mob/B = input("Select who to fuse with!","Fusion!") as anything in fusionCandidates
			if(!B || B == "Cancel") return
			B.fusing = 1
			. = ResetFusingVar(list(C.mob, B))
			if(get_dist(C.mob,B) > 1) return
			if(!(C.mob.IsCodedAdmin()) && (C&&B.client&&C.address==B.client.address))
				usr << "You can not fuse with an alt!"
				return
			if(C.mob.Race != B.Race)
				usr << "You must be the same race to fuse!"
				return
			if(usr.lastFusion) if(Time.CheckCooldown(usr.lastFusion, Time.FromHours(fusionCD * fCDMod), 2))
				B << "[usr.name] has not waited long enough since their last fusion!"
				usr << "You have not waited long enough since your last fusion!"
				usr << "([Time.GetRoundedTime(Time.FromHours(usr.lastFusion))] )"
				B << "([Time.GetRoundedTime(Time.FromHours(usr.lastFusion))] )"
				return
			if(B.lastFusion) if(Time.CheckCooldown(B.lastFusion, Time.FromHours(fusionCD * fCDMod), 2))
				usr << "[B.name] has not waited long enough since their last fusion!"
				B << "You have not waited long enough since your last fusion!"
				usr << "([Time.GetRoundedTime(Time.FromHours(B.lastFusion))] )"
				B << "([Time.GetRoundedTime(Time.FromHours(B.lastFusion))] )"
				return
			if(B.attacking)
				usr << "[B.name] is busy and can not fuse right now!"
				B << "[src.name] is trying to fuse with you, but you are busy!"
				return
			usr << "You're trying to fuse with [B.name]!"
			var/dialog/d = new
			spawn(200) del(d)
			switch(d.Ask(B, "[usr.name] is trying to fuse with you!", "Fusion", list("Deny", "Accept")))
				if(null) return
				if("Deny") return
			if(!IsValidFusionCandidate(C.mob) || !IsValidFusionCandidate(B)) return
			if(get_dist(C.mob,B) > 1) return
			var/mob/fusion/metamoran/P = new(C.mob.loc)
			P.Create_Fusion(C.mob, B)
			if(!P) return
			usr.lastFusion = world.realtime
			B.lastFusion = world.realtime
			view(P) << "[usr.name] and [B.name] have fused to become [P.name]!"
			P.SafeTeleport(locate(C.mob.x, C.mob.y, C.mob.z))
			C.mob = P

mob/fusion/metamoran
	IsValidFusion(mob/A,mob/B)				//In case they get past the other checks somehow
		return ..() && (A.Race == B.Race)	//This returns false if both races are not the same.

	SetFusionBP()							//Metamoran fusion is more limited, so it gets a 150% power boost.
		return ..() * 1.5
	
	SetFusionVisuals(mob/A)
		..()
		if(!A.FusionVestIcon) overlays += image('Fusion Jacket.dmi')
		else overlays += A.FusionVestIcon
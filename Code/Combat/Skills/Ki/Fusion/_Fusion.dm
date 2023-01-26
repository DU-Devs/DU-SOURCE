var
	fusion_timer_mod = 1
	fusion_bp_mult = 1
	regex
		syllables = new ("(\[^aeiouy]*\[aeiouy]+(?:\[^aeiouy]*$|\[^aeiouy](?=\[^aeiouy]))?)","gi")
		separators = new ("(\[^a-zA-Z])","gi")

proc/Capitalize(t)
	if(length(t)==1) return t
	return uppertext(copytext(t,1,2))+copytext(t,2)

var/lastFusionDestroyCheck = 0
proc/FusionDestroyCheck()
	set waitfor = 0
	if(lastFusionDestroyCheck + 150 > world.time) return
	lastFusionDestroyCheck = world.time

	for(var/mob/fusion/F)
		if(!F.client)
			F.RevertFusion()

#ifdef DEBUG
mob/Admin5/verb
	Get_Fusion_Dance()
		set category = "DEBUG"
		var/obj/Skills/Fusion_Dance/F = new
		if(!(locate(F) in src)) src.contents+= F

	Get_Potara()
		set category = "DEBUG"
		var/obj/items/Potara/F = new
		if(!(locate(F) in src)) src.contents+= F

	Output_Type()
		set category = "DEBUG"
		usr << usr.type

	Output_Client_Mob()
		set category = "DEBUG"
		usr << usr.client.mob

	Reset_Fusion_CD()
		set category = "DEBUG"
		for(var/obj/items/Potara/P in usr) P.lastUse = 0
		lastFusion = 0

	Output_Version()
		set category = "DEBUG"
		usr << Version

#endif



proc/IsValidFusionCandidate(mob/M)
	return M && M.client && !M.IsFusion() && !(M.IsGreatApe() || M.Regenerating)

proc/ResetFusingVar(list/L)
	for(var/mob/M in L) M.fusing = 0

mob/var/fusing = 0

mob/proc/IsFusion()
	return istype(src,/mob/fusion) || src.kaiFusion

mob/fusion
	var
		initial_bp
		list/contents1
		list/contents2
		list/fusees = new
		fuseTimer = 100
		initialRes
		reverting = 0
	Savable = 0
	verb/Defuse()
		set category = "Skills"
		fuseTimer = 0
		return RevertFusion()

	Login()
		StuffThatRunsIfYouClickNewOrLoad()
		PrimaryPlayerLoop(Time.FromSeconds(10))
		spawn(2)
			FusionTimer()
		..()
	
	Logout()
		FusionLogoutHandler()
		..()

	Stat_Stat() if(statpanel("Stats"))
		..()
		if(!src.kaiFusion) stat("Fusion Timer:", "[round(fuseTimer,1)]%")

	proc
		Create_Fusion(mob/A, mob/B)
			if(!IsValidFusion(A,B)) del src
			src.Savable = 0
			if(!fusees) fusees = list()
			spawn(1) FusionVFX(A)
			fusees[A.key] = A
			fusees[B.key] = B
			A.ReleaseGrab()
			B.ReleaseGrab()
			SaveFusees()
			SetFusionVisuals(A)
			Race = GetFusionRace(A,B)
			Class = GetFusionClass(A,B)
			originalClass = Class
			name = SetFusionName(A.name,B.name)
			Tabs = A.Tabs
			SetFusionStats(A,B)
			SetFusionTraits(A,B)
			SetFusionTransformations(A,B)
			EnterAppropriateForm(A,B)
			SetFusionContents(A,B)
			spawn(1) MoveFusees(A,B)

		FusionVFX(mob/M)
			set background = TRUE
			if(!M) return
			var/obj/vfx/fusion/O = new(M.loc)	//create a vfx obj
			O.transform *= 2					//double its size
			CenterIcon(O)						//Center the icon
			O.Play()
			M.ResetClientColor()
			
		FusionLogoutHandler()		//If a fused character logs out
			var/resDiff = (initialRes - Res()) / 2
			for(var/i in fusees)	//Find the fused mobs
				var/mob/M = fusees[i]
				if(M)
					M.loc = locate(x,y,z)
					if(resDiff) M.SetRes(M.Res() - resDiff)
					M.key = i		//Set their key var so the client assumes control of them
					M.Save()		//Save their mob and its current location.
					if(client && i == key) client.mob = M
					M.StuffThatRunsIfYouClickNewOrLoad()	//Restart your normal player loops and all the normal checks you'd do on login.
					M.PrimaryPlayerLoop(Time.FromSeconds(10))
				if(!M.client) del M	//If they have no client after setting their key, delete the mob so there isn't an empty copy.
			del src

		IsValidFusion(mob/A,mob/B)		//Check to make sure two fusions aren't trying to fuse and also that neither are an NPC.
			return (A.client && B.client) && !A.IsFusion() && !B.IsFusion()

		SetFusionContents(mob/A,mob/B)	//Add skills and items.
			for(var/obj/Skills/s in A)
				var/obj/s2
				if(s.type == /obj/Skills/Buff)
					Save_Obj(s)
					s2 = GetCachedObject(s.type)
					Load_Obj(s2)
					s2.suffix = null
				else s2 = GetCachedObject(s.type)
				s2.Taught=1
				if(istype(s2,/obj/Skills/Combat/Ki)) s2.icon=s.icon

				src.contents += s2
			for(var/obj/Skills/s in B)
				var/obj/s2
				if(s.type == /obj/Skills/Buff)
					Save_Obj(s)
					s2 = GetCachedObject(s.type)
					Load_Obj(s2)
					s2.suffix = null
				else s2 = GetCachedObject(s.type)
				s2.Taught=1
				if(istype(s2,/obj/Skills/Combat/Ki)) s2.icon=s.icon

				src.contents += s2
			src.Restore_hotbar_from_IDs()
			if(A.current_buff) A.Buff_Disable(current_buff)
			if(B.current_buff) B.Buff_Disable(current_buff)
			new/obj/Skills/Utility/Power_Control(src)
			new/obj/items/Equipment/Armor/Light_Armor(src)
			new/obj/items/Equipment/Armor/Medium_Armor(src)
			new/obj/items/Equipment/Armor/Heavy_Armor(src)
			new/obj/items/Equipment/Weapon/Bladed/Short_Sword(src)
			new/obj/items/Equipment/Weapon/Bladed/Long_Sword(src)
			new/obj/items/Equipment/Weapon/Bladed/Dagger(src)
			new/obj/items/Equipment/Weapon/Bladed/Spear(src)
			new/obj/items/Equipment/Weapon/Blunt/Light_Hammer(src)
			new/obj/items/Equipment/Weapon/Blunt/Mace(src)
			new/obj/items/Equipment/Weapon/Blunt/Quarterstaff(src)
			new/obj/items/Equipment/Weapon/Blunt/Nunchaku(src)
			sleep(2.5)
		
		SetFusionTraits(mob/A,mob/B)
			src.PopulateTraitsList()
			for(var/i in A.traits)
				var/trait/T1 = A.GetTraitByName(i)
				if(!T1) continue
				var/trait/T2 = src.GetTraitByName(i)
				if(!T2) continue
				T2.rank = T1.rank
			for(var/i in B.traits)
				var/trait/T1 = B.GetTraitByName(i)
				if(!T1) continue
				var/trait/T2 = src.GetTraitByName(i)
				if(!T2) continue
				T2.rank = Math.Max(T1.rank, T2.rank)
		
		CheckDoubleCopy()
			for(var/obj/Skills/O in contents1)
				for(var/obj/Skills/O2 in contents2)
					if(O ~= O2)
						del O2

		GetFusionRace(mob/A,mob/B)		//Default behavior, just use A's race.  For metamoran this works fine since both are the same race anyways.
			return A.Race				//Potara overrides this behavior with its own.  See comments there for details.
		
		GetFusionClass(mob/A,mob/B)		//If they're Saiyans, use A's class if they have one.  B's class if not.  If neither have a class, it'll stay blank.
			if(A.Race == "Yasai" && B.Race == "Yasai") return A.Class || B.Class

		SetFusionTransformations(mob/A,mob/B)	//If the fusees have some form of transformation that isn't always available
			for(var/i in A.UnlockedTransformations)
				var/transformation/T = A.UnlockedTransformations[i]
				if(T && T.CanEnterForm(src))
					src.UnlockedTransformations[i] = T
			for(var/i in B.UnlockedTransformations)
				if(i in src.UnlockedTransformations)
					continue
				var/transformation/T = B.UnlockedTransformations[i]
				if(T && T.CanEnterForm(src))
					src.UnlockedTransformations[i] = T

		EnterAppropriateForm(mob/A,mob/B)	//Enter mob A's form if possible, otherwise enter mob B's
			transOrder = A.transOrder
			var/transformation/T = A.GetActiveForm()
			if(!T)
				T = B.GetActiveForm()
			if(T)
				src.TryEnterForm(T)
		
		AverageValues(A,B)		//Returns the average of A and B.
			return (A + B) / 2

		SaveFusees()			//Save the fusees' current data.
			for(var/i in fusees)
				var/mob/M = fusees[i]
				M.Save()

		MoveFusees()				//While the fusion is ongoing, move the fusees into the fusion mob.
			if(fuseTimer < 1) return
			for(var/i in fusees)
				var/mob/M = fusees[i]
				if(M && M.loc != src) M.loc = src
				M.Savable_NPC = 0
			spawn(15) MoveFusees()	//Spawn this proc every 1.5 seconds.

		RevertFusion()					//Revert the fusion into the two separate mobs again.
			if(reverting) return		//This is only true if RevertFusion() was called previously.
			reverting = 1
			var/resDiff = (initialRes - Res()) / 2
			src.Destroy_Splitforms()	//Destroy any Splitforms that were made by the Fusion.
			if(LastSpiritBombValid()) 	//Destroy any Genki Dama attacks to avoid the bug where they remain on the map forever.
				last_Genki_Dama.SpiritBombGoOffSomewhere()
			
			for(var/i in fusees)		//Make sure to adjust the fusees' resources and items.
				var/mob/M = fusees[i]
				if(M)					//This stops the proc from crashing if somehow M is null.
					M.loc = locate(x,y,z)
					if(resDiff) M.SetRes(M.Res() - resDiff)
					if(M.Res() < 0) M.SetRes(initialRes/2)
					if(client && i == key) client.mob = M
					M.Dead = Dead
			for(var/obj/items/i in contents) i.loc = locate(src)	//drop any items the fusion picked up on the ground.
			del src													//After reverting, delete the fusion mob.
		
		FusionTimer()				//So long as fuseTimer still has time left, keep ticking down.
			if(fuseTimer <= 0) return RevertFusion()
			var/mod = BP / (initial_bp * bp_mult * Body)
			mod /= fusion_timer_mod	//Calculate the modifier for fusion timer.
			if(!mod) mod = 1		//The more BP you have compared to what you initially had, the faster the timer drains.
			if(fuseTimer > 1 * mod) fuseTimer -= 1 * mod
			else					//If the timer would reach or drop below zero, revert the fusion.
				fuseTimer = 0
				return RevertFusion()
			spawn(90) FusionTimer()	//Run this proc again once every 9 seconds.

		SetFusionVisuals(mob/A)				//For now, this just sets the fusion's appearance to fusee A's.
			src.icon = A.icon				//Should make this a detailed, neat visual effect later.
			src.hair = A.hair
			src.overlays = A.overlays
			src.underlays = A.underlays
			src.vis_contents = A.vis_contents

		SetFusionName(A, B)					//Combine the names of both fusees to create a unique fusion name for them.
			return CombineNames(A,B)		//This should result in the same name no matter which mob is fusee A and which is B.

		SetFusionBase(mob/A, mob/B)			//Set base BP of the fusion equal to 60% of fusee A and fusee B's BP average.
			return AverageValues(A.base_bp, B.base_bp) * 0.6

		SetFusionStats(mob/A, mob/B)		//This will go through and apply stat changes to the fusion.
			stat_version=cur_stat_ver
			base_bp = AverageValues(A.base_bp,B.base_bp)
			gravity_mastered = AverageValues(A.gravity_mastered,B.gravity_mastered)
			Body = AverageValues(A.Body,B.Body)
			static_bp = SetFusionBP(A,B)
			get_bp(0)
			initial_bp = effectiveBaseBp	//Most of the stats from this point on are just averages.
			Health = AverageValues(A.Health,B.Health)
			max_ki = AverageValues(A.max_ki,B.max_ki)
			Ki = AverageValues(A.Ki,B.Ki)
			stamina = AverageValues(A.stamina,B.stamina)
			Eff = Math.Max(A.Eff,B.Eff)
			Str = Math.Max(A.Str,B.Str)
			End = Math.Max(A.End,B.End)
			Pow = Math.Max(A.Pow,B.Pow)
			Res = Math.Max(A.Res,B.Res)
			Off = Math.Max(A.Off,B.Off)
			Def = Math.Max(A.Def,B.Def)
			Spd = Math.Max(A.Spd,B.Spd)
			regen = Math.Max(A.regen,B.regen)
			recov = Math.Max(A.recov,B.recov)
			anger = Math.Max(A.anger,B.anger)
			max_anger = Math.Max(A.max_anger,B.max_anger)
			leech_rate = 0
			zenkai_mod = 0
			Age = AverageValues(A.Age,B.Age)

		SetFusionBP(mob/A, mob/B)		//Calculate the HBTC BP we're going to give the fusion.
			var
				T = A.base_bp + A.static_bp + B.base_bp + B.static_bp	//T is the hbtc bp and base bp of both mobs added up into a sum total.
				mult = 2 ** (Average_Base_BP_of_Players() * 1.5 / T)//Calculate the mult by comparing T to the average of all players * 1.5
			if(mult < 1.3) mult = 1.3								//Hard minimum of 1.3x
			if(mult > 2.2) mult = 2.2								//Hard maximum of 2.2x
			return (T * mult) * fusion_bp_mult						//Return the sum total * the mult we calculated.  Modify by the global fusion mult. (Default: 1)

		CombineNames(word1,word2)			//As above, so below.
			if(!word1 || !word2) return "Unknown"
			var
				list/T1 = splittext(word1, separators)
				list/T2 = splittext(word2, separators)
			T1 = splittext(T1[1], syllables)
			T2 = splittext(T2[1], syllables)
			var
				out1 = GetFirstHalf(T1)
				out2 = GetSecondHalf(T2)
				out = GetProperOrder(T1, T2, out1, out2)
			return Capitalize(lowertext(out))

		GetProperOrder(list/T1, list/T2, out1, out2)	//This will make sure the name halves are ordered the same each time.
			if(T1.len > T2.len)
				out1 = GetSecondHalf(T1)
				out2 = GetFirstHalf(T2)
				return out2 + out1
			else if(T1.len == T2.len)
				if(length(GetFirstHalf(T1)) < length(GetFirstHalf(T2)))
					out1 = GetSecondHalf(T1)
					out2 = GetFirstHalf(T2)
					return out2 + out1
				if(length(GetSecondHalf(T1)) < length(GetSecondHalf(T2)))
					out1 = GetSecondHalf(T1)
					out2 = GetFirstHalf(T2)
					return out2 + out1
			return out1 + out2

		GetFirstHalf(list/T)	//Default behavior returns the first syllable of the smaller name for the first half of the fusion's name.
			if(T && T.len > 1)
				return "[T[2]]"
			else return "[T[1]]"

		GetSecondHalf(list/T)	//Default behavior returns the last two syllables (or last syllable, if the word is 2 or less syllables long)
			var/out				//for the second half of the fusion's name.
			if(T.len > 5) out += "[T[T.len-3]][T[T.len-1]]"
			else out += "[T[T.len]]"
			return out
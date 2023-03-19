/*
Fusion System

- 2 mobs. A (Active) & B (Non-Active) (Active = Player offering fusion. Non-active = player receiving offer.)
- 2 formulas. Potara = 2(A+B), Dance = A+B,
- Predefined effect set.
- Store both players in a list, mobs associated with thier key, to aid unfusing.
- Dance will have a time limit, be weaker.
- Potara will not have a time limit, but will need significant downsides.
- Splice overlays together.

- Store mob A and B.
- Duplicate B, import A's stuff.
- Use 50/50 overlays split. eg. A's overlay 1, B's overlay 2, etc.
- Adjust B's variables based on A
- Check if body swapped to avoid abuse.
- Move B to the new body, make A unable to act, like when body swapped. (for fusion dance)
- Move B to new body, wipe A. (for potara).

- Try the old racial fusion effects, with the blue lightning shockwaves and craters and stuff.
- Use old racial fusion stat maths. Keep the highest of each stat, except for regen/recov/energy. Average those.
- 18000 ticks = 30 minutes.

*/

mob
	var
		fused = null // will hold the list of fused mobs.
		fuser_1 = null
		fuser_2 = null
		fuse_end = null // timestamp to end fusion.
obj
	Fusion_Dance
		var/mastery = 1
		desc = "Allows two people to fuse together for a short time, becoming extremely powerful. The person who offers the fusion loses control for the time limit."
		verb
			Fusion_Dance(var/mob/M in orange(usr,1))
				set src = usr.contents
				set category = "Skills"
				if(M.client&&locate(/obj/Fusion_Dance in M.contents))
					switch(input("Are you sure you wish to fuse?") in list("Yes","No"))
						if("Yes")
							//Give the guy in front of you a prompt to accept fusion.
							var/ZZ = input(M,"Would you like to fuse?") in list("Yes","No")
							if(ZZ=="Yes")
								player_view(usr,15)
								Fusion_Proc(usr,M,0) // Fuse the usr, M (the guy in front), make non permanent.

obj
	Potara
		var/mastery = 1
		var/pair = 1
		desc = "Allows two people to fuse together for a short time, becoming extremely powerful. The person who offers the fusion loses control for the time limit."
		verb
			Throw_Potara(var/mob/M in player_view(usr,15))
				set src = usr.contents
				set category = "Skills"
				if(M.client)
					switch(input("Are you sure you give them this?") in list("Yes","No"))
						if("Yes")
							//Give the guy in front of you a prompt to accept fusion.
							player_view(usr,15) << "[usr] threw a Potara Earring to [M]."
							var/ZZ = input(M,"Would you like to catch the potara?") in list("Yes","No")
							if(ZZ=="Yes")
								player_view(M,15) << "[M] caught it and put it on!"
								src.pair=0
								src.name="Single Potara"
								Fusion_Proc(usr,M,1) // Fuse the usr, M (the guy in front), make non permanent.
							else
								player_view(M,15) << "[M] didn't catch it!"
								var/turf/yeet=locate(rand(M.x-2,M.x+2),rand(M.y-2,M.y+2),M.z)
								if(!src.pair)
									src.loc=yeet
								else
									var/obj/Potara/XY = new
									XY.loc=yeet
									XY.pair=0
									XY.name="Single Potara"
									src.pair=0
									src.name="Single Potara"




proc
	Fusion_Proc(mob/A,mob/B,var/perm) //perm=0 means dance, perm=1 means potara. A=passive B=in control
		if(A.body_swapped())
			A<<"Cannot fuse whilst body swapped."
			return 0 // If body swapped, fail.
		if(B.body_swapped())
			B<<"Cannot fuse whilst body swapped."
			return 0 // If body swapped, fail.
		if(A.BP>(B.BP*1.2)&&perm==0) //B.BP>(A.BP*1.2)
			A<<"Your power is too high to fuse."
			return 0 // If BP gap is too big, fail.
		if(B.BP>(A.BP*1.2)&&perm==0) //B.BP>(A.BP*1.2)
			B<<"Your power is too high to fuse."
			return 0 // If BP gap is too big, fail.
		if(A.fused||B.fused) return 0 // Can't fuse whilt fused.
		var/list/fused = list("[A.key]"=A,"[B.key]"=B) // Store both in a list.
		// Undo all modules, swords, armor.
		var/mob/newguy = B.Duplicate(1) // Duplicate B's mob and include unclonables.
		newguy.fuser_1 = A.key
		newguy.fuser_2 = B.key
		newguy.fused=fused
		newguy.overlays = Splice_Overlays(A,B) // Splice both mobs overlays, and put them on new mob.
		// Calculate what the BP mod of the new guy should be. May be awkward with cross-race fusion.
		if(perm)
			newguy.base_bp=(((A.base_bp/A.bp_mod)+(B.base_bp/B.bp_mod))*2)*newguy.bp_mod
			// Wipe A.
		if(!perm)
			newguy.fuse_end=(world.realtime+18000) // Set fusion end time 30 minutes from now.
			if(Fusion_Success(A,B)) // Find out if the players failed the fusion. 1 = success
				newguy.base_bp=(((A.base_bp/A.bp_mod)+(B.base_bp/B.bp_mod))*1)*newguy.bp_mod// Give the full boost.
				Tens("[A] and [B] successfully fused.")
			else
				newguy.base_bp=(((A.base_bp/A.bp_mod)+(B.base_bp/B.bp_mod))*0.5)*newguy.bp_mod // Give half power.
				Tens("[A] and [B] did not fuse successfully.")
				// Set them to the fat guy icon that aliens have. The white skinned fat guy with red sumo pants.
			// Make A unable to act and make them watch the fused mob.

		newguy.loc=locate(B.x,B.y,B.z)
		// Here's the stat optimizations.

		if(A.Str>B.Str)
			newguy.Str=A.Str
			newguy.strmod=A.strmod
		if(A.End>B.End)
			newguy.End=A.End
			newguy.endmod=A.endmod
		if(A.Spd>B.Spd)
			newguy.Spd=A.Spd
			newguy.spdmod=A.spdmod
		if(A.Pow>B.Pow)
			newguy.Pow=A.Pow
			newguy.formod=A.formod
		if(A.Off>B.Off)
			newguy.Off=A.Off
			newguy.offmod = A.offmod
		if(A.Def>B.Def)
			newguy.Def=A.Def
			newguy.offmod = A.offmod
		newguy.regen=(A.regen+B.regen)/2
		newguy.recov=(A.recov+B.recov)/2
		newguy.max_ki=((A.max_ki/A.Eff)+(B.max_ki/B.Eff))/2
		newguy.Eff=(A.Eff+B.Eff)/2
		newguy.max_ki*=newguy.Eff
		// Code to give B control here.
		A.client.mob=newguy
		A.client.eye=newguy
		if(!perm) spawn(10*60*30) Unfuse(newguy)
		newguy.Old_Trans_Graphics()
		newguy.SSj_Hair()
		newguy.Aura_Overlays()
		// Insert fancy effects.

proc
	Unfuse(mob/A)
		if(A.fused)
			for(var/mob/X in players)
				if(X.key==A.fuser_1)
					var/mob/C=A.fused["[X.key]"]
					C.SafeTeleport(locate(A.x,A.y,A.z))
					if(X.client.mob!=C)X.client.mob=C
					// Give them thier mob back.
				if(X.key==A.fuser_2)
					var/mob/C=A.fused["[X.key]"]
					C.SafeTeleport(locate(A.x+1,A.y,A.z))
					if(X.client.mob!=C)X.client.mob=C
					// Give them thier mob back.
					// Remove the fused mob.
proc
	Splice_Overlays(mob/A,mob/B)
		var/list/L1=A.overlays.Copy()
		L1.Remove(A.base_hair)
		L1.Remove(A.ssjhair)
		L1.Remove(A.ssjfphair)
		L1.Remove(A.ussjhair)
		L1.Remove(A.ssj2hair)
		L1.Remove(A.ssj3hair)
		L1.Remove(A.ssj_god_hair)
		L1.Remove(A.ssj_blue_hair)
		var/list/L2=B.overlays.Copy()
		L2.Remove(A.base_hair)
		L2.Remove(A.ssjhair)
		L2.Remove(A.ssjfphair)
		L2.Remove(A.ussjhair)
		L2.Remove(A.ssj2hair)
		L2.Remove(A.ssj3hair)
		L2.Remove(A.ssj_god_hair)
		L2.Remove(A.ssj_blue_hair)
		var/list/L3=new/list
		var/e
		var/i
		if(L1.len>L2.len)
			e=L1.len
		else
			e=L2.len
		for(i=1,i<=e,i++)
			if(i%2)
				if(i<L2.len)
					L3.Insert(L2[i])
				else
					L3.Insert(L1[i])
			else
				if(i<L1.len)
					L3.Insert(L1[i])
				else
					L3.Insert(L2[i])
		return L3 //Return overlays, not including hair.

proc
	Fusion_Success(var/mob/A,var/mob/B)
		var/success_chance
		if(locate(/obj/Fusion_Dance) in A.contents)
			for(var/obj/Fusion_Dance/C in A.contents)
				if(C.mastery<100)
					success_chance+=(C.mastery/2)
				else
					success_chance+=50
		if(locate(/obj/Fusion_Dance) in B.contents)
			for(var/obj/Fusion_Dance/D in B.contents)
				if(D.mastery<100)
					success_chance+=(D.mastery/2)
				else
					success_chance+=50
		if(prob(success_chance))
			return 1 // Fusion worked.
		else
			return 0 // Fusion failed.

#ifdef DEBUG
mob
	verb
		Learn_Fusion()
			set category = "Yeet"
			var/l=input("Are you sure you want to mess with this? It can wipe your save.") in list("Yes","No")
			switch(l)
				if("No") return
				if("Yes")
					if(!locate(/obj/Fusion_Dance) in src.contents)
						src << "You learned Fusion Dance."
						src.contents += new/obj/Fusion_Dance

mob
	verb
		Make_Potara()
			set category = "Yeet"
			var/l=input("Are you sure you want to mess with this? It can wipe your save.") in list("Yes","No")
			switch(l)
				if("No") return
				if("Yes")
					if(!locate(/obj/Potara) in src.contents)
						src << "You got some Potara Earrings"
						src.contents += new/obj/Potara
#endif


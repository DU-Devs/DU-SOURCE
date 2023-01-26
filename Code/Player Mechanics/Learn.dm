obj/var/Cost_To_Learn=0

var/list/Learnable_Skills
var/list/All_Skills

proc/Initialize_Learnable_Skills_List()
	if(!Learnable_Skills)
		Learnable_Skills=new/list
		for(var/A in typesof(/obj))
			var/obj/B=new A
			if(B && B.Cost_To_Learn) Learnable_Skills["[B.name] (Cost: [B.Cost_To_Learn])"] = B
proc/InitalizeAllSkillsList()
	if(!All_Skills)
		All_Skills = new/list
		for(var/A in typesof(/obj))
			var/obj/B = new A
			if(!B || B.type == /obj || B.type == /obj/Skills) continue
			if(B && B.Skill) All_Skills["[B.name]"] = A

proc/LearnableSkillList()
	var/list/L = new
	for(var/v in Learnable_Skills)
		var/obj/o=Learnable_Skills[v]
		if(o&&!(o.type in Illegal_learnables)) L+=o
	return L

proc/FullSkillList()
	var/list/L = new
	for(var/v in Learnable_Skills)
		var/obj/T = Learnable_Skills[v]
		if(!T) continue
		L += T
	return L

var/list/Illegal_learnables = list(/obj/Skills/Utility/Regeneration,/obj/Skills/Utility/Absorb)

/*mob/Admin4/verb/Manage_Learnable_Skills()
	set category="Admin"
	Initialize_Learnable_Skills_List()
	while(src)
		switch(alert(src,"Add or remove from the unlearnable skill list?", "options", "Cancel", "Add", "Remove"))
			if("Cancel") break

			if("Add")
				while(src&&client)
					var/list/L=list("Done") + LearnableSkillList()
					var/obj/o=input(src,"Which skill to make unlearnable?") in L
					if(!o||o=="Done") break
					Illegal_learnables+=o.type
					src<<"[o] is now unlearnable"
					sleep(2)

			if("Remove")
				while(src&&client)
					var/list/L=list("Done")
					for(var/v in Illegal_learnables)
						L += new v
					var/obj/o=input(src,"What skill to make self learnable again?") in L
					if(!o||o=="Done") break
					Illegal_learnables-=o.type
					src<<"[o] is now learnable again"
					sleep(2)
		sleep(2)*/

mob/proc/Delete_excess_buffs()
	var/n=0
	for(var/obj/Skills/Buff/b in src)
		n++
		if(n>max_buffs) del(b)

var/max_buffs=8
mob/proc/Buff_count() //how many custom buffs they have
	var/n=0
	for(var/obj/Skills/Buff/b in src)
		n++
	return n

mob/var/tail_level=1

mob/var/list/PersonalSkills = new

/*mob/Admin3/verb/Manage_Player_Skills()
	set category = "Admin"
	var/mob/M = input("Which player?", "Manage Player Skills") in list("Cancel") + players as mob|null
	if(!M) return
	while(1)
		switch(input("Do what?", "Manage Player Skills") in list("Cancel", "Unlock", "Lock", "Set Cost"))
			if("Unlock")
				UnlockSkillForPlayer(M)
			if("Lock")
				LockSkillForPlayer(M)
			if("Set Cost")
				SetSkillCostForPlayer(M)
			else break
		sleep(2)*/

proc/SetSkillCostForPlayer(mob/M)
	if(!M.client || !M.playerCharacter)
		return
	while(1)
		var/obj/T = input("What skill?") in list("Cancel") + FullSkillList()
		if(T == "Cancel" || !T) break
		var/cost = input("Set the cost of the skill. Setting to 0 (or canceling) will revert to default cost.", "How much?") as num|null
		if(!cost) break
		M.SetSkillCost(T, cost)
		sleep(2)

proc/UnlockSkillForPlayer(mob/M)
	if(!M.client || !M.playerCharacter)
		return
	while(1)
		var/list/skills = new
		for(var/v in M.PersonalSkills)
			var/obj/T = new v
			if(!T) continue
			skills += T
		var/list/learnSkills = FullSkillList()
		var/obj/T = input("What skill?") in list("Cancel") + learnSkills - skills
		if(T == "Cancel" || !T) break
		M.PersonalSkills += T.type
		sleep(2)

proc/LockSkillForPlayer(mob/M)
	if(!M.client || !M.playerCharacter)
		return
	while(1)
		var/list/skills = new
		for(var/v in M.PersonalSkills)
			var/obj/T = new v
			if(!T) continue
			skills += T
		var/obj/T = input("What skill?") in list("Cancel") + skills
		if(T == "Cancel" || !T) break
		M.PersonalSkills -= T.type
		sleep(2)

proc/IsLearnableSkill(obj/O, mob/M)
	return (O.type in M.PersonalSkills) || !(O.type in Illegal_learnables) || O.type == /obj/Skills/Buff

mob/verb/Learn()
	set category = "Skills"

	if(src.IsFusion())
		alert("You can not learn skills in this form.")
		return

	while(src && client)
		switch(input("What kind of learning are we doing?") in list("Cancel", "Skills", "Traits"))
			if("Cancel") break
			if("Skills") LearnSkills()
			if("Traits") GainTraits()

mob/proc/Learn_Skills()
	Initialize_Learnable_Skills_List()
	while(src && client)
		var/list/L = list("Cancel")
		for(var/A in Learnable_Skills)
			var/obj/B = Learnable_Skills[A]
			if(!B) continue
			if(B && IsLearnableSkill(B, src))
				if(!(locate(B.type) in src) || B.Relearnable)
					if(istype(B,/obj/Skills/Buff)&&Buff_count()>=max_buffs)
						src<<"<font color=cyan>You can not have more than 8 custom buffs so that option has been removed from Learn"
						continue
					if(istype(B,/obj/Skills/Divine/Materialization)&&!(Race in list("Puranto","Kai","Majin"))) continue
					if(istype(B,/obj/Skills/Divine/Demon_Contract)&&Race!="Demon") continue
					if(istype(B,/obj/Puranto_Fusion)&&Race!="Puranto") continue
					if(istype(B,/obj/Skills/Utility/Power_Orb)&&((Race!="Yasai"&&Race!="Half Yasai"))) continue
					if(istype(B, /obj/Skills/Divine/Unlock_Potential) && !RaceCanHaveUnlockPotential(Race)) continue

					L["[B.name] ([CostToLearn(B)] SP)"] = B

		if(locate(/obj/Skills/Buff) in src) L+="Learn new buff attribute"
		var/Great_Ape_control_sp=50
		if(!Great_Ape_control&&Tail&&base_bp+static_bp>=5000) L+="Great_Ape Control ([Great_Ape_control_sp] SP)"
		if(Tail) L+="[Race] Tail Training (35 SP)"
		var/A=input(src,"Which skill do you want to learn? You have [round(Experience)] Skill Points") in L
		if(A=="Cancel")
			break
		else if(A=="Great_Ape Control ([Great_Ape_control_sp] SP)")
			if(Experience<Great_Ape_control_sp) src<<"You need [Great_Ape_control_sp] SP to learn this"
			else
				Experience-=Great_Ape_control_sp
				Great_Ape_control=1
				src<<"You have learned Great_Ape Control"
				L-="Great_Ape Control ([Great_Ape_control_sp] SP)"
		else if(A=="Learn new buff attribute") learn_new_buff_attribute()
		else if(A=="[Race] Tail Training (35 SP)")
			if(Experience<35) src<<"You need 35 SP to learn this"
			else
				Experience-=35
				tail_level++
				src<<"You have learned [Race] Tail Training, rank [tail_level]"
		else
			var/obj/O = L[A]
			if(!O) return
			var/spNeeded = CostToLearn(O)
			if(Experience < spNeeded) src<<"You need [spNeeded] Skill Points to learn [O.name]"
			else
				Experience -= spNeeded
				var/obj/S = GetCachedObject(O.type)
				S.Taught=0
				S.update_teach_timer()
				contents+=S
				src<<"You have learned [S.name]"
				if(S.type == /obj/Skills/Combat/Ki/Blast)
					src << "<font color=cyan>You can alter the default behavior of 'Blast' using the Blast Options command found in the Other tab. For example to make them explosive."
				if(S.type == /obj/Skills/Buff)
					src << "<font color=cyan>For a custom buff to do anything, you must first set up what it does by clicking the Buff Options command found in the Other tab. You can set which stats it alters and more"
				if(!O.Relearnable) L-=A
		sleep(2)
	Restore_hotbar_from_IDs()

var/list/PlayerSkillCosts = new

mob/proc/GetSkillCostList()
	if(!client || !key)
		return
	var/list/L = PlayerSkillCosts[key]
	return L

mob/proc/GetSkillCost(obj/O)
	if(!client || !key)
		return
	var/list/SkillCosts = GetSkillCostList()
	if(SkillCosts && SkillCosts["[O.type]"])
		return SkillCosts["[O.type]"]

mob/proc/SetSkillCost(obj/O, cost=0)
	if(!client || !key)
		return
	var/list/SkillCosts = GetSkillCostList()
	if(!SkillCosts) SkillCosts = new
	SkillCosts["[O.type]"] = cost
	PlayerSkillCosts[key] = SkillCosts

mob/proc/CostToLearn(obj/o)
	if(!o) return 0
	var/spNeeded = o.Cost_To_Learn
	if(GetSkillCost(o))
		spNeeded = GetSkillCost(o)
	spNeeded *= RaceSkillLearnDifficultyMod(o)
	if(spNeeded < 1) spNeeded = 1
	return round(spNeeded,1)

mob/proc/RaceSkillLearnDifficultyMod(obj/o)
	var/val = 1
	if(Race == "copy this as a template for all default as 1")
		if(istype(o,/obj/Skills/Buff)) val = 1
		if(istype(o,/obj/Skills/Combat/Melee)) val = 1
		if(istype(o,/obj/Skills/Combat/Ki)) val = 1
		if(istype(o,/obj/Skills/Utility)) val = 1
		if(istype(o,/obj/Skills/Divine)) val = 5
	if(Race == "Yasai")
		if(Class == "Elite")
			if(istype(o,/obj/Skills/Combat/Melee)) val = 0.5
			if(istype(o,/obj/Skills/Combat/Ki)) val = 0.6
			if(istype(o,/obj/Skills/Utility)) val = 1.5
			if(istype(o,/obj/Skills/Divine)) val = 10
		else
			if(istype(o,/obj/Skills/Combat/Melee)) val = 0.5
			if(istype(o,/obj/Skills/Combat/Ki)) val = 0.8
			if(istype(o,/obj/Skills/Utility)) val = 1.35
			if(istype(o,/obj/Skills/Divine)) val = 10
	if(Race == "Puranto")
		if(istype(o,/obj/Skills/Buff)) val = 2
		if(istype(o,/obj/Skills/Combat/Melee)) val = 1.5
		if(istype(o,/obj/Skills/Combat/Ki)) val = 0.2
		if(istype(o,/obj/Skills/Utility)) val = 1.4
	if(Race == "Android")
		if(istype(o,/obj/Skills/Buff)) val = 1.8
		if(istype(o,/obj/Skills/Combat/Melee)) val = 0.5
		if(istype(o,/obj/Skills/Combat/Ki)) val = 1.8
		if(istype(o,/obj/Skills/Utility)) val = 0.5
	if(Race == "Frost Lord")
		if(istype(o,/obj/Skills/Buff)) val = 1.6
		if(istype(o,/obj/Skills/Combat/Melee)) val = 0.5
		if(istype(o,/obj/Skills/Combat/Ki)) val = 0.2
		if(istype(o,/obj/Skills/Utility)) val = 2
	if(Race != "Kai" && Race != "Demon" && Race != "Demigod")
		if(Race == "Yasai" && istype(o,/obj/Skills/Divine)) val = 5
		else if(istype(o,/obj/Skills/Divine)) val = 2.5
	return val

mob/proc/learn_new_buff_attribute()
	var/list/availables=list("Cancel","Transformation")
	for(var/v in known_buff_attributes) availables-=v
	var/v=input("Which buff attribute do you want to learn?") in availables
	var/sp_cost=0
	switch(v)
		if(null) return
		if("Cancel") return
		if("Transformation")
			sp_cost=15
			v="transformation"
	switch(alert(src,"the [v] attribute cost [sp_cost] sp, learn it?","options","Yes","No"))
		if("Yes")
			if(Experience<sp_cost) return
			Experience-=sp_cost
			known_buff_attributes+=v
			src<<"You have learned [v] (buff attribute)"


mob/Prison_Bot
	icon='Android.dmi'
	Click()
		dir=get_dir(src,usr)
		player_view(15,src)<<"[src]: Greetings. This is the prison hub where visitors can enter the prison. \
		The prison is another dimension where criminals caught over the bounty network are sent."
		sleep(40)
		dir=SOUTH
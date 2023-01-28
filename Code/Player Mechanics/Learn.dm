obj/var/Cost_To_Learn=0

var/list/Learnable_Skills

proc/Initialize_Learnable_Skills_List()
	if(!Learnable_Skills)
		Learnable_Skills=new/list
		for(var/A in typesof(/obj))
			var/obj/B=new A
			if(B && B.Cost_To_Learn) Learnable_Skills["[B.name] (Cost: [B.Cost_To_Learn])"] = B

var/list/Illegal_learnables = list(/obj/Regeneration,/obj/Absorb)

mob/proc/RemoveAbsorbFromNonZorbRacesIfZorbIsIllegal()
	set waitfor=0
	sleep(20)
	if(!(locate(/obj/Absorb) in Illegal_learnables)) return
	if(!(Race in list("Majin","Bio-Android","Alien","Demon")))
		if(!(locate(/obj/Module/Manual_Absorb) in active_modules))
			for(var/obj/Absorb/a in src) del(a)

mob/Admin4/verb/Manage_Learnable_Skills()
	set category="Admin"
	Initialize_Learnable_Skills_List()
	switch(alert(src,"Add or remove from the unlearnable skill list?","options","Add","Remove","Cancel"))
		if("Cancel") return

		if("Add")
			while(src&&client)
				var/list/L=list("Done")
				for(var/v in Learnable_Skills)
					var/obj/o=Learnable_Skills[v]
					if(o&&!(o.type in Illegal_learnables)) L+=o
				var/obj/o=input(src,"Which skill to make unlearnable?") in L
				if(!o||o=="Done") return
				Illegal_learnables+=o.type
				src<<"[o] is now unlearnable"

		if("Remove")
			while(src&&client)
				var/list/L=list("Done")
				for(var/v in Illegal_learnables)
					L += new v
				var/obj/o=input(src,"What skill to make self learnable again?") in L
				if(!o||o=="Done") return
				Illegal_learnables-=o.type
				src<<"[o] is now learnable again"

mob/proc/Delete_excess_buffs()
	var/n=0
	for(var/obj/Buff/b in src)
		n++
		if(n>max_buffs) del(b)

var/max_buffs=8
mob/proc/Buff_count() //how many custom buffs they have
	var/n=0
	for(var/obj/Buff/b in src) n++
	return n

mob/var/tail_level=1

mob/verb/Learn()
	//set category="Skills"

	if(is_saitama)
		alert("Nope")
		return

	if(!client) return
	Initialize_Learnable_Skills_List()
	var/list/L = list("Cancel")
	for(var/A in Learnable_Skills)
		var/obj/B = Learnable_Skills[A]
		if(!B) continue
		if(B && !(B.type in Illegal_learnables))
			if(!(locate(B.type) in src) || B.Relearnable)
				if(istype(B,/obj/Buff) && !custom_buffs_allowed) continue
				if(istype(B,/obj/Buff)&&Buff_count()>=max_buffs)
					src<<"<font color=cyan>You can not have more than 8 custom buffs so that option has been removed from Learn"
					continue
				if(istype(B,/obj/Giant_Form)&&!(Race in list("Puranto","Onion Lad"))) continue
				if(istype(B,/obj/Materialization)&&!(Race in list("Puranto","Kai","Majin"))) continue
				if(istype(B,/obj/Demon_Contract)&&Race!="Demon") continue
				if(istype(B,/obj/Third_Eye)&&(Race!="Human"||Class=="Spirit Doll")) continue
				if(istype(B,/obj/Puranto_Fusion)&&Race!="Puranto") continue
				if(istype(B,/obj/Ultra_Super_Yasai)&&((Race!="Yasai"&&Race!="Half Yasai")||BP<ussj_bp_req||!SSjAble))
					continue
				if(istype(B, /obj/Unlock_Potential) && !RaceCanHaveUnlockPotential(Race)) continue
				if(istype(B, /obj/Attacks/Piercer) && Race != "Puranto") continue //other races have to get it from db wish

				L["[B.name] ([CostToLearn(B)] SP)"] = B

	if(locate(/obj/Buff) in src) L+="Learn new buff attribute"
	var/Great_Ape_control_sp=50
	if(!Great_Ape_control&&Tail&&base_bp+hbtc_bp>=5000) L+="Great_Ape Control ([Great_Ape_control_sp] SP)"
	if(Tail) L+="[Race] Tail Training (35 SP)"
	while(src && client)
		var/A=input(src,"Which skill do you want to learn? You have [round(Experience)] Skill Points") in L
		if(A=="Cancel")
			Restore_hotbar_from_IDs()
			return
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
				if(S.type == /obj/Attacks/Blast)
					src << "<font color=cyan>You can alter the default behavior of 'Blast' using the Blast Options command found in the Other tab. For example to make them explosive."
				if(S.type == /obj/Buff)
					src << "<font color=cyan>For a custom buff to do anything, you must first set up what it does by clicking the Buff Options command found in the Other tab. You can set which stats it alters and more"
				if(!O.Relearnable) L-=A
	Restore_hotbar_from_IDs()

mob/proc/CostToLearn(obj/o)
	if(!o) return 0
	var/spNeeded = o.Cost_To_Learn
	spNeeded *= RaceSkillLearnDifficultyMod(o)
	return spNeeded

mob/proc/RaceSkillLearnDifficultyMod(obj/o)
	if(Race == "copy this as a template for all default as 1")
		if(o.type == /obj/Buff) return 1
		if(o.type == /obj/Final_Explosion) return 1
		if(o.type == /obj/Dropkick) return 1
		if(o.type == /obj/Attacks/Beam) return 1
		if(o.type == /obj/Attacks/Buster_Barrage) return 1
		if(o.type == /obj/Attacks/Blast) return 1
		if(o.type == /obj/Attacks/Charge) return 1
		if(o.type == /obj/Attacks/Spin_Blast) return 1
		if(o.type == /obj/Attacks/Big_Bang_Attack) return 1
		if(o.type == /obj/Attacks/Makosen) return 1
		if(o.type == /obj/Attacks/Explosion) return 1
		if(o.type == /obj/Attacks/Genocide) return 1
		if(o.type == /obj/Attacks/Shockwave) return 1
		if(o.type == /obj/Attacks/Piercer) return 1 //makankosappo
		if(o.type == /obj/Attacks/Ray) return 1 //death beam
		if(o.type == /obj/Attacks/Dodompa) return 1
		if(o.type == /obj/Attacks/Attack_Barrier) return 1
		if(o.type == /obj/Attacks/Kienzan) return 1
		if(o.type == /obj/Attacks/Scatter_Shot) return 1
		if(o.type == /obj/Attacks/Sokidan) return 1
		if(o.type == /obj/Attacks/Genki_Dama/Death_Ball) return 1
		if(o.type == /obj/Attacks/Genki_Dama/Supernova) return 1
		if(o.type == /obj/Telepathy) return 1
		if(o.type == /obj/Reincarnation) return 1
		if(o.type == /obj/Meditate_Level_2) return 1
		if(o.type == /obj/Shadow_Spar) return 1
		if(o.type == /obj/Shield) return 1
		if(o.type == /obj/Bind) return 1
		if(o.type == /obj/Kaio_Revive) return 1
		if(o.type == /obj/Restore_Youth) return 1
		if(o.type == /obj/Heal) return 1
		if(o.type == /obj/Unlock_Potential) return 1
		if(o.type == /obj/Observe) return 1
		if(o.type == /obj/SplitForm) return 1
		if(o.type == /obj/Hokuto_Shinken) return 1
		if(o.type == /obj/Planet_Destroy) return 1
		if(o.type == /obj/Dash_Attack) return 1
		if(o.type == /obj/Sense) return 1
		if(o.type == /obj/Advanced_Sense) return 1 //sense lv2
		if(o.type == /obj/Sense3) return 1
		if(o.type == /obj/Give_Power) return 1
		if(o.type == /obj/Zanzoken) return 1
		if(o.type == /obj/Self_Destruct) return 1
		if(o.type == /obj/Taiyoken) return 1
	if(Race == "Yasai")
		if(Class == "Elite")
			if(o.type == /obj/Buff) return 1
			if(o.type == /obj/Final_Explosion) return 1
			if(o.type == /obj/Dropkick) return 1
			if(o.type == /obj/Attacks/Beam) return 1
			if(o.type == /obj/Attacks/Buster_Barrage) return 1
			if(o.type == /obj/Attacks/Blast) return 1
			if(o.type == /obj/Attacks/Charge) return 1
			if(o.type == /obj/Attacks/Spin_Blast) return 1
			if(o.type == /obj/Attacks/Big_Bang_Attack) return 1
			if(o.type == /obj/Attacks/Makosen) return 1
			if(o.type == /obj/Attacks/Explosion) return 1
			if(o.type == /obj/Attacks/Genocide) return 1
			if(o.type == /obj/Attacks/Shockwave) return 1
			if(o.type == /obj/Attacks/Piercer) return 10 //makankosappo
			if(o.type == /obj/Attacks/Ray) return 1 //death beam
			if(o.type == /obj/Attacks/Dodompa) return 1
			if(o.type == /obj/Attacks/Attack_Barrier) return 10
			if(o.type == /obj/Attacks/Kienzan) return 1
			if(o.type == /obj/Attacks/Scatter_Shot) return 10
			if(o.type == /obj/Attacks/Sokidan) return 10
			if(o.type == /obj/Attacks/Genki_Dama/Death_Ball) return 5
			if(o.type == /obj/Attacks/Genki_Dama/Supernova) return 5
			if(o.type == /obj/Telepathy) return 50
			if(o.type == /obj/Reincarnation) return 10
			if(o.type == /obj/Meditate_Level_2) return 10
			if(o.type == /obj/Shadow_Spar) return 10
			if(o.type == /obj/Shield) return 5
			if(o.type == /obj/Bind) return 2
			if(o.type == /obj/Kaio_Revive) return 3
			if(o.type == /obj/Restore_Youth) return 3
			if(o.type == /obj/Heal) return 10
			if(o.type == /obj/Unlock_Potential) return 3
			if(o.type == /obj/Observe) return 50
			if(o.type == /obj/SplitForm) return 2
			if(o.type == /obj/Hokuto_Shinken) return 1
			if(o.type == /obj/Planet_Destroy) return 1
			if(o.type == /obj/Dash_Attack) return 1
			if(o.type == /obj/Sense) return 2
			if(o.type == /obj/Advanced_Sense) return 3 //sense lv2
			if(o.type == /obj/Sense3) return 5
			if(o.type == /obj/Give_Power) return 3
			if(o.type == /obj/Zanzoken) return 1
			if(o.type == /obj/Self_Destruct) return 1
			if(o.type == /obj/Taiyoken) return 1
		else
			if(o.type == /obj/Buff) return 1
			if(o.type == /obj/Final_Explosion) return 1
			if(o.type == /obj/Dropkick) return 1
			if(o.type == /obj/Attacks/Beam) return 1
			if(o.type == /obj/Attacks/Buster_Barrage) return 1
			if(o.type == /obj/Attacks/Blast) return 1
			if(o.type == /obj/Attacks/Charge) return 1
			if(o.type == /obj/Attacks/Spin_Blast) return 1
			if(o.type == /obj/Attacks/Big_Bang_Attack) return 1
			if(o.type == /obj/Attacks/Makosen) return 1
			if(o.type == /obj/Attacks/Explosion) return 1
			if(o.type == /obj/Attacks/Genocide) return 1
			if(o.type == /obj/Attacks/Shockwave) return 1
			if(o.type == /obj/Attacks/Piercer) return 10 //makankosappo
			if(o.type == /obj/Attacks/Ray) return 10 //death beam
			if(o.type == /obj/Attacks/Dodompa) return 10
			if(o.type == /obj/Attacks/Attack_Barrier) return 10
			if(o.type == /obj/Attacks/Kienzan) return 10
			if(o.type == /obj/Attacks/Scatter_Shot) return 10
			if(o.type == /obj/Attacks/Sokidan) return 10
			if(o.type == /obj/Attacks/Genki_Dama/Death_Ball) return 5
			if(o.type == /obj/Attacks/Genki_Dama/Supernova) return 5
			if(o.type == /obj/Telepathy) return 50
			if(o.type == /obj/Reincarnation) return 10
			if(o.type == /obj/Meditate_Level_2) return 10
			if(o.type == /obj/Shadow_Spar) return 10
			if(o.type == /obj/Shield) return 5
			if(o.type == /obj/Bind) return 2
			if(o.type == /obj/Kaio_Revive) return 3
			if(o.type == /obj/Restore_Youth) return 3
			if(o.type == /obj/Heal) return 10
			if(o.type == /obj/Unlock_Potential) return 3
			if(o.type == /obj/Observe) return 50
			if(o.type == /obj/SplitForm) return 2
			if(o.type == /obj/Hokuto_Shinken) return 1
			if(o.type == /obj/Planet_Destroy) return 1
			if(o.type == /obj/Dash_Attack) return 1
			if(o.type == /obj/Sense) return 2
			if(o.type == /obj/Advanced_Sense) return 3 //sense lv2
			if(o.type == /obj/Sense3) return 5
			if(o.type == /obj/Give_Power) return 3
			if(o.type == /obj/Zanzoken) return 1
			if(o.type == /obj/Self_Destruct) return 1
			if(o.type == /obj/Taiyoken) return 1
	if(Race == "Puranto")
		if(o.type == /obj/Buff) return 1
		if(o.type == /obj/Final_Explosion) return 1
		if(o.type == /obj/Dropkick) return 1
		if(o.type == /obj/Attacks/Beam) return 1
		if(o.type == /obj/Attacks/Buster_Barrage) return 1
		if(o.type == /obj/Attacks/Blast) return 1
		if(o.type == /obj/Attacks/Charge) return 1
		if(o.type == /obj/Attacks/Spin_Blast) return 1
		if(o.type == /obj/Attacks/Big_Bang_Attack) return 1
		if(o.type == /obj/Attacks/Makosen) return 1
		if(o.type == /obj/Attacks/Explosion) return 1
		if(o.type == /obj/Attacks/Genocide) return 1
		if(o.type == /obj/Attacks/Shockwave) return 1
		if(o.type == /obj/Attacks/Piercer) return 1 //makankosappo
		if(o.type == /obj/Attacks/Ray) return 1 //death beam
		if(o.type == /obj/Attacks/Dodompa) return 1
		if(o.type == /obj/Attacks/Attack_Barrier) return 1
		if(o.type == /obj/Attacks/Kienzan) return 10
		if(o.type == /obj/Attacks/Scatter_Shot) return 1
		if(o.type == /obj/Attacks/Sokidan) return 1
		if(o.type == /obj/Attacks/Genki_Dama/Death_Ball) return 5
		if(o.type == /obj/Attacks/Genki_Dama/Supernova) return 5
		if(o.type == /obj/Telepathy) return 1
		if(o.type == /obj/Reincarnation) return 1
		if(o.type == /obj/Meditate_Level_2) return 1
		if(o.type == /obj/Shadow_Spar) return 1
		if(o.type == /obj/Shield) return 10
		if(o.type == /obj/Bind) return 1
		if(o.type == /obj/Kaio_Revive) return 1
		if(o.type == /obj/Restore_Youth) return 1
		if(o.type == /obj/Heal) return 1
		if(o.type == /obj/Unlock_Potential) return 1
		if(o.type == /obj/Observe) return 1
		if(o.type == /obj/SplitForm) return 1
		if(o.type == /obj/Hokuto_Shinken) return 1
		if(o.type == /obj/Planet_Destroy) return 3
		if(o.type == /obj/Dash_Attack) return 1
		if(o.type == /obj/Sense) return 1
		if(o.type == /obj/Advanced_Sense) return 1 //sense lv2
		if(o.type == /obj/Sense3) return 1
		if(o.type == /obj/Give_Power) return 1
		if(o.type == /obj/Zanzoken) return 1
		if(o.type == /obj/Self_Destruct) return 1
		if(o.type == /obj/Taiyoken) return 1
	if(Race == "Android")
		if(o.type == /obj/Buff) return 1
		if(o.type == /obj/Final_Explosion) return 1
		if(o.type == /obj/Dropkick) return 1
		if(o.type == /obj/Attacks/Beam) return 1
		if(o.type == /obj/Attacks/Buster_Barrage) return 1
		if(o.type == /obj/Attacks/Blast) return 1
		if(o.type == /obj/Attacks/Charge) return 1
		if(o.type == /obj/Attacks/Spin_Blast) return 1
		if(o.type == /obj/Attacks/Big_Bang_Attack) return 1
		if(o.type == /obj/Attacks/Makosen) return 1
		if(o.type == /obj/Attacks/Explosion) return 1
		if(o.type == /obj/Attacks/Genocide) return 1
		if(o.type == /obj/Attacks/Shockwave) return 1
		if(o.type == /obj/Attacks/Piercer) return 1 //makankosappo
		if(o.type == /obj/Attacks/Ray) return 1 //death beam
		if(o.type == /obj/Attacks/Dodompa) return 1
		if(o.type == /obj/Attacks/Attack_Barrier) return 1
		if(o.type == /obj/Attacks/Kienzan) return 1
		if(o.type == /obj/Attacks/Scatter_Shot) return 1
		if(o.type == /obj/Attacks/Sokidan) return 1
		if(o.type == /obj/Attacks/Genki_Dama/Death_Ball) return 1
		if(o.type == /obj/Attacks/Genki_Dama/Supernova) return 1
		if(o.type == /obj/Telepathy) return 1
		if(o.type == /obj/Reincarnation) return 10
		if(o.type == /obj/Meditate_Level_2) return 10
		if(o.type == /obj/Shadow_Spar) return 1
		if(o.type == /obj/Shield) return 1
		if(o.type == /obj/Bind) return 3
		if(o.type == /obj/Kaio_Revive) return 10
		if(o.type == /obj/Restore_Youth) return 10
		if(o.type == /obj/Heal) return 5
		if(o.type == /obj/Unlock_Potential) return 10
		if(o.type == /obj/Observe) return 1
		if(o.type == /obj/SplitForm) return 1
		if(o.type == /obj/Hokuto_Shinken) return 1
		if(o.type == /obj/Planet_Destroy) return 1
		if(o.type == /obj/Dash_Attack) return 1
		if(o.type == /obj/Sense) return 1
		if(o.type == /obj/Advanced_Sense) return 1 //sense lv2
		if(o.type == /obj/Sense3) return 1
		if(o.type == /obj/Give_Power) return 10
		if(o.type == /obj/Zanzoken) return 1
		if(o.type == /obj/Self_Destruct) return 1
		if(o.type == /obj/Taiyoken) return 1
	if(Race == "Frost Lord")
		if(o.type == /obj/Buff) return 1
		if(o.type == /obj/Final_Explosion) return 1
		if(o.type == /obj/Dropkick) return 1
		if(o.type == /obj/Attacks/Beam) return 1
		if(o.type == /obj/Attacks/Buster_Barrage) return 1
		if(o.type == /obj/Attacks/Blast) return 1
		if(o.type == /obj/Attacks/Charge) return 1
		if(o.type == /obj/Attacks/Spin_Blast) return 1
		if(o.type == /obj/Attacks/Big_Bang_Attack) return 1
		if(o.type == /obj/Attacks/Makosen) return 1
		if(o.type == /obj/Attacks/Explosion) return 1
		if(o.type == /obj/Attacks/Genocide) return 1
		if(o.type == /obj/Attacks/Shockwave) return 1
		if(o.type == /obj/Attacks/Piercer) return 1 //makankosappo
		if(o.type == /obj/Attacks/Ray) return 1 //death beam
		if(o.type == /obj/Attacks/Dodompa) return 1
		if(o.type == /obj/Attacks/Attack_Barrier) return 1
		if(o.type == /obj/Attacks/Kienzan) return 1
		if(o.type == /obj/Attacks/Scatter_Shot) return 1
		if(o.type == /obj/Attacks/Sokidan) return 1
		if(o.type == /obj/Attacks/Genki_Dama/Death_Ball) return 1
		if(o.type == /obj/Attacks/Genki_Dama/Supernova) return 1
		if(o.type == /obj/Telepathy) return 1
		if(o.type == /obj/Reincarnation) return 1
		if(o.type == /obj/Meditate_Level_2) return 1
		if(o.type == /obj/Shadow_Spar) return 1
		if(o.type == /obj/Shield) return 1
		if(o.type == /obj/Bind) return 1
		if(o.type == /obj/Kaio_Revive) return 1
		if(o.type == /obj/Restore_Youth) return 1
		if(o.type == /obj/Heal) return 1
		if(o.type == /obj/Unlock_Potential) return 1
		if(o.type == /obj/Observe) return 1
		if(o.type == /obj/SplitForm) return 1
		if(o.type == /obj/Hokuto_Shinken) return 1
		if(o.type == /obj/Planet_Destroy) return 1
		if(o.type == /obj/Dash_Attack) return 1
		if(o.type == /obj/Sense) return 5
		if(o.type == /obj/Advanced_Sense) return 5 //sense lv2
		if(o.type == /obj/Sense3) return 5
		if(o.type == /obj/Give_Power) return 1
		if(o.type == /obj/Zanzoken) return 1
		if(o.type == /obj/Self_Destruct) return 1
		if(o.type == /obj/Taiyoken) return 1
	return 1

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
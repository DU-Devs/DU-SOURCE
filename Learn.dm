obj/var/Cost_To_Learn=0
var/list/Learnable_Skills
proc/Initialize_Learnable_Skills_List()
	if(!Learnable_Skills)
		Learnable_Skills=new/list
		for(var/A in typesof(/obj))
			var/obj/B=new A
			if(B&&B.Cost_To_Learn) Learnable_Skills["[B.name] (Cost: [B.Cost_To_Learn])"]=B

var/list/Illegal_learnables=list(/obj/Regeneration,/obj/Absorb)
mob/Admin4/verb/Manage_learnable_skills()
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
					L+=new v
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
	set category="Skills"
	if(!client) return
	Initialize_Learnable_Skills_List()
	var/list/L=list("Cancel")
	for(var/A in Learnable_Skills)
		var/obj/B=Learnable_Skills[A]
		if(B&&!(B.type in Illegal_learnables))
			if(!(locate(B.type) in src)||B.Relearnable)
				L+=A

				if(istype(B,/obj/Buff)&&Buff_count()>=max_buffs)
					src<<"<font color=cyan>You can not have more than 8 custom buffs so that option has been removed from Learn"
					L-=A
				if(istype(B,/obj/Giant_Form)&&!(Race in list("Namek","Makyo"))) L-=A
				if(istype(B,/obj/Materialization)&&!(Race in list("Namek","Kai","Majin"))) L-=A
				if(istype(B,/obj/Demon_Contract)&&Race!="Demon") L-=A
				if(istype(B,/obj/Third_Eye)&&(Race!="Human"||Class=="Spirit Doll")) L-=A
				if(istype(B,/obj/Namek_Fusion)&&Race!="Namek") L-=A
				if(istype(B,/obj/Ultra_Super_Saiyan)&&((Race!="Saiyan"&&Race!="Half Saiyan")||BP<ussj_bp_req||!SSjAble))
					L-=A

	if(locate(/obj/Buff) in src) L+="Learn new buff attribute"
	var/oozaru_control_sp=50
	if(!oozaru_control&&Tail&&base_bp+hbtc_bp>=5000) L+="Oozaru Control ([oozaru_control_sp] SP)"
	if(Tail) L+="[Race] Tail Training (35 SP)"
	while(src && client)
		var/A=input(src,"Which skill do you want to learn? You have [round(Experience)] Skill Points") in L
		if(A=="Cancel")
			Restore_hotbar_from_IDs()
			return
		else if(A=="Oozaru Control ([oozaru_control_sp] SP)")
			if(Experience<oozaru_control_sp) src<<"You need [oozaru_control_sp] SP to learn this"
			else
				Experience-=oozaru_control_sp
				oozaru_control=1
				src<<"You have learned Oozaru Control"
				L-="Oozaru Control ([oozaru_control_sp] SP)"
		else if(A=="Learn new buff attribute") learn_new_buff_attribute()
		else if(A=="[Race] Tail Training (35 SP)")
			if(Experience<35) src<<"You need 35 SP to learn this"
			else
				Experience-=35
				tail_level++
				src<<"You have learned [Race] Tail Training, rank [tail_level]"
		else
			var/obj/O=Learnable_Skills[A]
			if(!O) return
			else
				if(Experience<O.Cost_To_Learn) src<<"You need [O.Cost_To_Learn] Skill Points to learn [O.name]"
				else
					Experience-=O.Cost_To_Learn
					var/obj/S=new O.type
					S.Taught=0
					S.update_teach_timer()
					contents+=S
					src<<"You have learned [S.name]"
					if(!O.Relearnable) L-=A
	Restore_hotbar_from_IDs()
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
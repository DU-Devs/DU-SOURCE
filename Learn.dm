obj/var/Cost_To_Learn=0
var/list/Learnable_Skills
proc/Initialize_Learnable_Skills_List()
	if(!Learnable_Skills)
		Learnable_Skills=new/list
		for(var/A in typesof(/obj))
			var/obj/B=new A
			if(B&&B.Cost_To_Learn) Learnable_Skills["[B.name] (Cost: [B.Cost_To_Learn])"]=B
mob/verb/Learn()
	set category="Skills"
	Initialize_Learnable_Skills_List()
	var/list/L=list("Cancel")
	for(var/A in Learnable_Skills)
		var/obj/B=Learnable_Skills[A]
		if(B) if(!(locate(B.type) in src)||B.Relearnable)
			var/Is_Human
			if(Race=="Human"&&!Class) Is_Human=1
			if(istype(B,/obj/Third_Eye)&&!Is_Human)
			else L+=A
	if(locate(/obj/Buff) in src) L+="learn new buff attribute"
	while(src)
		var/A=input(src,"Which skill do you want to learn? You have [round(Experience)] Skill Points") in L
		if(A=="Cancel") return
		if(A=="learn new buff attribute") learn_new_buff_attribute()
		else
			var/obj/O=Learnable_Skills[A]
			if(!O) return
			else
				if(Experience<O.Cost_To_Learn) src<<"You need [O.Cost_To_Learn] Skill Points to learn [O.name]"
				else
					Experience-=O.Cost_To_Learn
					var/obj/S=new O.type
					S.Taught=0
					S.Next_Teach=Year+S.Teach_Timer
					contents+=S
					src<<"You have learned [S.name]"
					if(!O.Relearnable) L-=A
mob/proc/learn_new_buff_attribute()
	var/list/availables=list("cancel","transformation")
	for(var/v in known_buff_attributes) availables-=v
	var/v=input("which buff attribute do you want to learn?") in availables
	var/sp_cost=0
	switch(v)
		if(null) return
		if("cancel") return
		if("transformation") sp_cost=15
	switch(alert(src,"the [v] attribute cost [sp_cost] sp, learn it?","options","yes","no"))
		if("yes")
			if(Experience<sp_cost) return
			Experience-=sp_cost
			known_buff_attributes+=v
			src<<"You have learned [v] (buff attribute)"


mob/Prison_Bot
	icon='Android.dmi'
	Click()
		dir=get_dir(src,usr)
		view(src)<<"[src]: Greetings. This is the prison hub where visitors can enter the prison. \
		The prison is another dimension where criminals caught over the bounty network are sent."
		sleep(40)
		dir=SOUTH
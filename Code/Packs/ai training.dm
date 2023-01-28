mob/proc/AI_Train_Loop()
	set waitfor=0
	var/obj/SplitForm/SF
	while(src)
		if(!auto_train)
			sleep(60)
			if(!client) sleep(100) //slowed down on empty clones to reduce lag if there are many of them at once
		else
			if(!SF||SF.loc!=src) SF=locate(/obj/SplitForm) in src
			if(Ki<max_ki*0.2||Health<20)
				Land()
				Destroy_Splitforms()
				if(Auto_Attack) AutoAttack()
				while(attacking) sleep(10)
				while(Action!="Meditating")
					Meditate(from_ai_train=1)
					sleep(10)
				while(src&&Action=="Meditating")
					if(Ki>=max_ki*0.9&&Health>=90)
						Meditate(from_ai_train=1)
						break
					sleep(30)
				sleep(10)
			else if(SF)
				if(!SplitformCount())
					Fly()
					if(Action == "Meditating") Meditate(from_ai_train=1)
					if(Action == "Training") Train(from_ai_train=1)
					sleep(world.tick_lag)
					CreateSplitform()
					if(!Auto_Attack) AutoAttack()
				sleep(30)
			else
				if(Action!="Training") Train(from_ai_train=1)
				sleep(30)

mob/var/auto_train

obj/AI_Training
	hotbar_type="Training method"
	can_hotbar=1
	desc="This allows AI to take control of your character's training"
	Del()
		var/mob/m=loc
		if(ismob(m)&&m.auto_train) m.AI_Train()
		. = ..()
	verb/Hotbar_use()
		set hidden=1
		AI_Training()

	verb/AI_Training()
		set category="Other"
		usr.AI_Train()

mob/proc/AI_Train()
	if(!auto_train) Cease_training()
	auto_train=!auto_train
	if(auto_train)
		src<<"Your character is now AI training"
	else
		src<<"Your character has stopped AI training"
		if(Auto_Attack) AutoAttack()
		Destroy_Splitforms()
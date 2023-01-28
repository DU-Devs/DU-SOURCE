/*
make it so if the game reboots itll read your save file and if you have auto_train on then it will
load your character
*/
mob/var/auto_train
obj/AI_Training
	desc="This allows AI to take control of your character's training"
	verb/AI_Training()
		set category="Other"
		usr.auto_train=!usr.auto_train
		if(usr.auto_train) usr<<"Your character is now AI training"
		else
			usr<<"Your character has stopped AI training"
			if(usr.Auto_Attack) spawn usr.AutoAttack()
			usr.Destroy_Splitforms()
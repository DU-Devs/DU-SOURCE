var/list/epic_list=list("EXGenesis")
mob/proc
	Epic()
		if(key&&(key in epic_list)) return 1
	alter_resources()
		var/n=input(src,"how many resources do you want?") as num
		Alter_Res(n)
	alter_intelligence()
		Intelligence=input(src,"how much intelligence do you want?","options",Intelligence()) as num
		Knowledge=input(src,"how much knowledge do you want?","options",Knowledge) as num

	make_someone_epic()
		if(!(key in epic_list)) epic_list += key
		for(var/mob/m in Get_step(src,dir))
			if(m.client)
				epic_list+=m.key
				m.contents+=new/obj/Teleport
				src<<"<font size=2><font color=yellow>[m] has been made epic. This means:<br>\
				1) They are indestructable<br>\
				2) They will grow in power very quickly by fighting players more powerful than them.<br>\
				3) They will gain skill points (SP) quickly for learning new skills<br>\
				4) They will recover lost energy instantly<br>\
				5) They always move and attack at max speed even if their speed stat is low<br>\
				6) They will master all skills instantly upon using them"
				return
			else
				src<<"[m] is not a real player and can not be put in the epic list"
				return
		src<<"There is no player in front of you to add to the epic list"

	remove_epicness_from_someone()
		var/list/l=list("cancel")
		for(var/v in epic_list) l+=v
		var/v=input(src,"who's byond ID do you want to remove epic powers from?") in l
		if(!v||v=="cancel") return
		epic_list-=v
		src<<"[v] was removed from the epic list and will no longer have the epic powers"
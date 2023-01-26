mob/Admin4/verb
	wipe_bounty_list()
		set category="Admin"
		Bounties=list("Cancel")

mob/proc/Total_Res() //on you and in bank total
	var/n=Res()
	if(key&&(key in bank_list)) n+=bank_list[key]
	return n
mob/Admin5/verb/MakeFakePlayers()
	set category="Admin"
	var
		how_many = input(usr,"How many?","Options",1) as num
		power_mod = input(usr,"Power multiplier. 1 means the power of an average player","Options",1) as num
		invince=0
		join_tourny=0

	switch(alert(usr,"Are they indestructable?","Options","No","Yes"))
		if("No") invince=0
		if("Yes") invince=1

	switch(alert(usr,"Possbility to join tournaments?","Options","No","Yes"))
		if("No") join_tourny=0
		if("Yes") join_tourny=1

	for(var/v in 1 to how_many)
		SpawnFakePlayer(pos = usr.loc, power_mod = power_mod, invince = invince, join_tourny = join_tourny)

proc
	SpawnFakePlayer(pos, power_mod=1, invince, join_tourny=1)
		if(!pos) return

		var/mob/FakePlayer/fp = new(pos)
		fp.fp_power_mod = power_mod
		if(join_tourny) fp.join_tourny_chance = rand(0,100)
		fp.fp_invince = invince

	GetWrongSpelling(txt,multiplier=1,uppercase=1,wrong_vowel=1,drop_letter=1,swap_letter=1)

		if(!txt) return txt

		txt=lowertext(txt)
		var/list/l=new
		for(var/v in 1 to length(txt))
			var/t=copytext(txt,v,v+1)
			if(!(t in list("0","1","2","3","4","5","6","7","8","9")))
				if(prob(wrong_vowel*20*multiplier)&&(t in list("a","e","i","o","u"))) t=pick("a","e","i","o","u")
				if(prob(100-(drop_letter*8*multiplier))&&!is_symbol(t)) l+=t
		while(prob(18*swap_letter*multiplier))
			var/n=pick(1,length(l)-1)
			l.Swap(n,n+1)
		var/new_txt=""
		for(var/v in l) new_txt="[new_txt][v]"
		if(uppercase) new_txt=uppertext(new_txt)
		else new_txt=lowertext(new_txt)
		return new_txt

mob/FakePlayer
	proc
		FindPlayerToHangAround()
			var/list/l = new

			for(var/mob/m in players)
				if(IsValidPlayerToTrack(m))
					l += m

			if(!l.len) return
			var/mob/m = pick(l)
			return m

		IsValidPlayerToTrack(mob/m)
			if(!m || m.z != z || !m.client || m.client.inactivity > 300 || !same_area(src, m) || m.invisibility)
				return
			return 1

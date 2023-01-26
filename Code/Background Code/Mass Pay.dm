/*mob/verb/Register_Paypal()
	set category="Other"
	alert(src,"This game has a system which will actually pay you to play it, IF you register your paypal \
	with the game. When you click OK a link will open allowing you to register a paypal to the key you are using.")
	src<<link("http://falsecreations.com/.byond/masspay/index.php?key=[ckey]&token=[md5(ckey)]")
*/
proc/Mass_Pay_Check()
	if(Player_Count()<20) return
	var/list/L=players.Copy()
	for(var/mob/P in L) if(P.client) for(var/mob/M in L)
		if(M.client&&M!=P&&P.client.address==M.client.address) L-=M
	List2Emails(L)
proc
	List2Emails(list/L)
		var/T=""
		var/item_index=1
		for(var/mob/X in L)
			T+=X.ckey
			if(item_index<L.len) T+=","
			item_index++
		world.Export("byond://173.0.55.256:1337?players=[T]")
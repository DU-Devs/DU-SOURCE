mob/proc/Omega_KB() for(var/obj/Omega_KB/S in src) if(S.Enabled)
	if(world.realtime>S.next_use)
		S.next_use=world.realtime+600
		return 1

mob/proc/Get_Omega_KB() for(var/obj/Omega_KB/S in src) return S.Distance

obj/Omega_KB
	Givable=0
	var/Enabled
	var/Distance=20
	var/next_use=0
	verb/Set_Omega_Knockback_Distance()
		set category="Other"
		Distance=input("Set how far your Omega knockbacks will send people. It is currently [Distance]. Max is 100. \
		Omega knockbacks can only be performed once per minute to prevent a form of spamming that can \
		freeze your opponent the entire battle causing you to be unbeatable even if your much weaker \
		than your opponent.") as num
		if(Distance<0) Distance=0
		if(Distance>100) Distance=100
		Distance=round(Distance)

	verb/Omega_Knockback()
		set category="Skills"
		if(Enabled)
			Enabled=0
			usr<<"You have disabled Omega knockbacks"
		else
			Enabled=1
			usr<<"You have enabled Omega knockbacks"

obj/Insta_Leech
	Givable=0
	var/Next_Use=0
	verb/Insta_Leech()
		set category="Skills"
		if(Year<Next_Use)
			usr<<"You can not use this til year [Next_Use]"
			return
		var/list/L=list("Cancel")
		for(var/mob/P in player_view(10,usr)) if(P.client&&P!=usr) L+=P
		var/mob/P=input("Who do you want to leech?") in L
		if(!P||P=="Cancel") return
		Next_Use=Year+5
		usr.Attack_Gain(10000,P,apply_hbtc_gains=0)
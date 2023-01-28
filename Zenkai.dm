mob/var/Zenkai_Divider=1
mob/var/Zenkai_Reset=0
mob/proc/Zenkai()
	if(!Zenkai_Reset)
		Zenkai_Reset=world.realtime+(2*60*60*10) //Cant zenkai the first 2 hours of creation
		Zenkai_Divider=10 //except in small amounts
	var/zenkai=1
	if(src in All_Entrants) zenkai/=5
	Attack_Gain((200/Leech_Rate/Zenkai_Divider)*Zenkai_Rate*zenkai,Opponent)
	if(Zenkai_Divider==1) Zenkai_Reset=world.realtime
	Zenkai_Reset+=(1*60*60*10)/Zenkai_Divider/(Ultra_Pack+1)
	Zenkai_Divider*=3
	Opponent=null //it resets because if someone fires a blast at you it sets your opponent to them
	//so when you KO or die, zenkai is triggered and it resets it so that you cant spam KO yourself to
	//abuse for power from that person
mob/proc/Zenkai_Reset() spawn while(src)
	if(Zenkai_Divider>1&&Zenkai_Reset&&world.realtime>Zenkai_Reset)
		Zenkai_Divider=1
		src<<"<font size=2><font color=yellow><b>Your Zenkai has now fully refilled"
	sleep(100)
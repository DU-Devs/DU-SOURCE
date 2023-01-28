mob/var/zenkai_divider=1
mob/var/zenkai_reset=0
mob/Admin5/verb/Test_Zenkai(mob/m in world)
	Opponent=m
	Zenkai()

var/server_zenkai=1

mob/Admin4/verb/Set_Zenkai_Multiplier()
	server_zenkai=input(src,"Server Zenkai Multiplier","Options",server_zenkai) as num
	server_zenkai=Clamp(server_zenkai,0,999)

mob/proc/Zenkai(n=1)
	if(!zenkai_mod||!Opponent) return
	if(!zenkai_reset)
		zenkai_reset=world.realtime+(30*60*10) //Cant zenkai the first 30 minutes of creation
		zenkai_divider=10 //except in small amounts
	var/zenkai=1
	if(src in All_Entrants) zenkai/=5
	if(cyber_bp||has_modules()) zenkai/=4

	var/difficulty_mod=Clamp((1.6*BP/Opponent.BP)**1.5,0.1,1)
	zenkai*=difficulty_mod

	var/old_bp=base_bp
	Leech(Opponent,240*n*server_zenkai*zenkai_mod*zenkai/zenkai_divider,no_adapt=1,weights_count=0)
	if(base_bp>old_bp*3) base_bp=old_bp*3
	if(base_bp>old_bp)
		if(zenkai_divider==1) zenkai_reset=world.realtime+(10*60*10)
		var/tm=(base_bp/old_bp)-1
		zenkai_reset+=(1*60*60*10)*tm //+6 minutes for every 10% power increase
		var/zd=(base_bp/old_bp)**2
		zd=Clamp(zd,1.2,2)
		zenkai_divider*=zd
	Opponent=null //it resets because if someone fires a blast at you it sets your opponent to them
	//so when you KO or die, zenkai is triggered and it resets it so that you cant spam KO yourself to
	//abuse for power from that person
mob/proc/zenkai_reset() spawn while(src)
	if(zenkai_mod&&zenkai_divider>1&&zenkai_reset&&world.realtime>zenkai_reset)
		zenkai_divider=1
		src<<"<font size=1><font color=yellow><b>Your Zenkai has now fully refilled"
	sleep(600)
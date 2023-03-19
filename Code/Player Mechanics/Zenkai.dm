/*
zenkai requires an extra special beating to unlock
like you get below 50% ko'd bp but you survive it

zenkai should accumulate as you train. like for a Yasai, keep their mod at 2x but then as they train their zenkai_bp rises by 40% of what
their bp rises, but til you UNLOCK the zenkai_Bp it will hide that amount of bp from you. like if you have 100 bp and 0 zenkai bp your bp is 100,
if you train to 200 bp and your zenkai bp is now 40, you have 160 bp, til you unlock the zenkai to see your real bp of 200
*/

mob/var/zenkai_divider=1
mob/var/zenkai_reset=0
mob/Admin5/verb/Test_Zenkai(mob/m in world)
	Opponent=m
	Zenkai()

var/server_zenkai=1

mob/proc/Zenkai(n=1)
	if(!zenkai_mod || !Opponent(65)) return
	if(!zenkai_reset)
		zenkai_reset=world.realtime+(30*60*10) //Cant zenkai the first 30 minutes of creation
		zenkai_divider=10 //except in small amounts
	var/zenkai=1
	if(z == 7 && Tournament && (src in All_Entrants)) zenkai/=5
	if(cyber_bp||has_modules()) zenkai/=4

	var/difficulty_mod=Clamp((1.6*BP/Opponent.BP)**1.5,0.1,1)
	zenkai*=difficulty_mod

	var/old_bp=base_bp
	Leech(Opponent,240*n*server_zenkai*zenkai_mod*zenkai/zenkai_divider,no_adapt=1,weights_count=0)
	if(base_bp>old_bp*3) base_bp=old_bp*3
	if(base_bp>old_bp)
		if(zenkai_divider==1) zenkai_reset=world.realtime+(10*60*10)
		var/tm=(base_bp/old_bp)-1
		zenkai_reset += (1 * 60 * 600) * tm //+6 minutes for every 10% power increase
		var/zd=(base_bp/old_bp)**2
		zd=Clamp(zd,1.2,2)
		zenkai_divider*=zd
	Opponent=null //it resets because if someone fires a blast at you it sets your opponent to them
	//so when you KO or die, zenkai is triggered and it resets it so that you cant spam KO yourself to
	//abuse for power from that person

mob/proc/zenkai_reset()
	set waitfor=0
	while(src)
		if(zenkai_reset > world.realtime + 600 * 60) zenkai_reset = world.realtime + 600 * 60
		if(zenkai_mod && zenkai_divider > 1 && zenkai_reset && world.realtime > zenkai_reset)
			zenkai_divider = 1
			src<<"<font color=yellow><b>Your Zenkai has now fully refilled"
		sleep(600)
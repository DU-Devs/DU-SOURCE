mob/var
	namek_counterpart //key of a player
	last_counterpart_change=0 //realtime
	counterpart_died
mob/Namek/verb
	Reset_counterpart()
		set category="Other"
		src<<"Counterpart reset"
		namek_counterpart=null
	Set_as_counterpart(mob/m in usr.Counterpart_list())
		if(counterpart_died)
			src<<"You can not change counterparts when you are about to die from your current counterpart \
			being dead"
			return
		var/hours=last_counterpart_change+(2*60*60*10)-world.realtime
		if(world.realtime<hours)
			src<<"You can't change counterparts again for another [round(hours)] and [round(hours*60%60)] \
			minutes"
			return
		if(m.client&&m.client.address==client.address)
			src<<"Your alt can not be your counterpart"
			return
		if(m.namek_counterpart)
			if(m.namek_counterpart==key)
				src<<"They are already your counterpart"
				return
			else
				src<<"[m] already has a counterpart"
				return
		if(namek_counterpart)
			switch(alert(src,"You already have [namek_counterpart] as your counterpart, replace them?",\
			"Options","No","Yes"))
				if("No") return
		src<<"Offering [m] the option to counterpart with you..."
		switch(alert(m,"[src] wants to become counterparts with you. This means you will have a \
		Kami and Piccolo type relationship where you were once the same being, and if one is weaker than \
		the other they will be brought up to the same level.","Options",\
		"Deny","Accept"))
			if("Deny")
				player_view(15,m)<<"[m] has denied the offer to counterpart with [src]"
				return
			if("Accept")
				player_view(15,m)<<"[m] is now [src]'s counterpart"
				if(!(src in view(m))) src<<"[m] is now your counterpart"
				namek_counterpart=m.key
				m.namek_counterpart=key
mob/proc
	Tell_counterpart_i_died()
		if(Dead) for(var/mob/m in players) if(key&&m.namek_counterpart==key&&!m.counterpart_died)
			m.counterpart_died=1
			m<<"Your Namek counterpart has died. You will die soon too if they do not come back to life \
			before all of your energy drains"

	Tell_counterpart_im_alive()
		if(!Dead) for(var/mob/m in players) if(key&&m.namek_counterpart==key&&m.counterpart_died)
			m.counterpart_died=0
			m<<"Your Namek counterpart has come back to life. You are no longer in danger of dying"

	Check_if_counterpart_is_alive_or_dead()
		if(namek_counterpart)
			for(var/mob/m in players) if(m.key&&namek_counterpart==m.key)
				if(!m.Dead) counterpart_died=0
				else counterpart_died=1

	Counterpart_died_loop()

		return

		spawn while(src)
			if(Race!="Namek") return
			Tell_counterpart_i_died()
			Tell_counterpart_im_alive()
			sleep(300)
		spawn while(src)
			if(counterpart_died&&!Dead)
				while(counterpart_died&&!Dead)
					Ki-=max_ki/60
					if(Ki<=0) Death("the loss of their Namekian counterpart",Force_Death=1)
					sleep(10)
			else sleep(600)

	Match_counterpart_loop() spawn while(src)
		Match_counterpart()
		sleep(600)

	Match_counterpart()
		if(namek_counterpart) for(var/mob/m in players) if(m.key==namek_counterpart)
			if(m.namek_counterpart!=key||m.Race!=Race)
				src<<"[m] has dropped you as their counterpart"
				namek_counterpart=null
				return
			if(bp_mod<m.bp_mod) bp_mod=m.bp_mod
			if(base_bp<m.base_bp) base_bp=m.base_bp
			if(hbtc_bp<m.hbtc_bp) hbtc_bp=m.hbtc_bp
			if(max_ki/Eff<m.max_ki/m.Eff) max_ki=m.max_ki/m.Eff*Eff
			if(gravity_mastered<m.gravity_mastered) gravity_mastered=m.gravity_mastered

mob/proc/Counterpart_list()
	var/list/L=new
	for(var/mob/m in player_view(20,src)) if(m!=src&&m.client&&m.Race==Race) L+=m
	return L

obj/Namek_Fusion
	teachable=0
	Skill=1
	Teach_Timer=2
	hotbar_type="Ability"
	can_hotbar=1
	Cost_To_Learn=20
	desc="Namek fusion lets two Nameks fuse together for a power boost. The person who offers the \
	fusion has their character deleted and the other gets the boost."
	var/Next_Use=0

	New() if(!Next_Use) Next_Use=Year+10

	verb/Hotbar_use()
		set hidden=1
		Namek_Fusion()

	verb/Namek_Fusion()
		set category="Skills"
		usr.Namek_Fusion()

mob/var/last_fused_with=0 //realtime
var/namek_fusion_wait_hours=5

mob/proc/Namek_Fusion()

	if(world.realtime-last_fused_with<namek_fusion_wait_hours*60*60*10)
		var/hours=(last_fused_with+(namek_fusion_wait_hours*60*60*10)-world.realtime)/(10*60*60)
		src<<"You can only fuse every [namek_fusion_wait_hours] hours. You must wait another [round(hours)] hours and [round(hours*60 %60)] minutes"
		return

	if(body_swapped())
		src<<"You can not use this while body swapped"
		return

	var/mob/P=input(src,"Choose who you want to fuse with, they must be the same race as you") in Get_step(src,dir) as mob|null
	if(!P||!ismob(P)) return
	if(P.Race!=Race)
		src<<"[P] is not a [Race]"
		return

	if(world.realtime-P.last_fused_with<namek_fusion_wait_hours*60*60*10)
		var/hours=(P.last_fused_with+(namek_fusion_wait_hours*60*60*10)-world.realtime)/(10*60*60)
		src<<"[P] has already had someone fuse with them in the last [namek_fusion_wait_hours] hours, they must wait \
		another [round(hours)] hours and [round(hours*60 %60)] minutes"
		return

	switch(input(src,"Are you sure you want to fuse with [P]? You will lose your character.") in \
	list("No","Yes"))
		if("Yes") if(P)
			player_view(15,P)<<"[src] fuses with [P]!"
			P.last_fused_with=world.realtime
			last_fused_with=world.realtime

			if(P.bp_mod<bp_mod) P.bp_mod=bp_mod
			if(P.base_bp<base_bp) P.base_bp=base_bp
			if(P.hbtc_bp<hbtc_bp) P.hbtc_bp=hbtc_bp

			P.Wish_for_power()
			if(P.max_ki/P.Eff<max_ki/Eff) P.max_ki=max_ki/Eff*P.Eff
			if(P.gravity_mastered<gravity_mastered) P.gravity_mastered=gravity_mastered
			if(P.Health<100) P.Health=100
			if(P.Ki<P.max_ki) P.Ki=P.max_ki
			if(P.namek_counterpart==key&&P.base_bp+P.hbtc_bp>1500000)
				if(P.base_bp<13000000) P.base_bp=13000000
				if(P.hbtc_bp<10000000) P.hbtc_bp=10000000

			Respawn()
			P.Namek_Fusion_Gfx()
			available_potential=0.01
			src<<"You have fused with [P] and were automatically reincarnated"

mob/proc/Namek_Fusion_Gfx() spawn if(src)
	player_view(10,src)<<sound('Super Namek.ogg',volume=40)
	var/N=6
	spawn while(N&&src)
		N--
		Make_Shockwave(src,6,'Electricgroundbeam2.dmi')
		sleep(rand(3,6))
	spawn if(src) Rising_Aura(src,25)
	Dust(src,30)
	spawn if(src) for(var/turf/T in Circle(8,src))
		T.Rising_Rocks()
		if(prob(35)) sleep(1)
	var/obj/O=new(loc)
	Timed_Delete(O,200)
	O.icon='White Flashing Circle.dmi'
	O.layer=9
	Center_Icon(O)
	spawn while(O)
		O.icon_state=pick("","1","2")
		sleep(rand(1,20))
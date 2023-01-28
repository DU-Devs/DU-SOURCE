mob/proc/find_melee_target(mob/O)
	var/mob/target=O
	if(!target)
		var/turf/t=get_step(src,dir)
		if(t&&isturf(t))
			if(t.attackable&&t.density) target=t
			for(var/obj/m in t) if(m.attackable)
				target=m
				break
			for(var/mob/m in t) if(m.attackable)
				target=m
				break
	return target
mob/proc/get_melee_damage(mob/m)
	var/dmg=0
	if(ismob(m))
		dmg=5*((BP/m.BP)**0.75)*Melee_Power
		var/obj/items/Sword/s=using_sword()
		if(s&&s.Style=="Energy")
			dmg*=((Str*0.7)+(Pow*0.3))/m.Res
			dmg*=0.9 //energy swords do a bit less damage on average
		else dmg*=(Str/m.End)
		if(m.dir==dir) dmg*=4 //hit from behind
	if(isobj(m)||isturf(m))
		if(m.takes_gradual_damage) dmg=5*(BP/100)
		else
			if(BP>m.Health) dmg=1.#INF
			else if(!client) dmg=BP/3000 //npcs can gradually break anything
	return dmg
mob/proc/get_melee_accuracy(mob/m)
	var/accuracy=100
	if(ismob(m))
		accuracy=25*sqrt(BP/m.BP)*(Off/m.Def)*Zanzoken_Accuracy(m)*((Spd/m.Spd)**0.3)
		if(m.dir==dir||m.dir==turn(dir,90)||m.dir==turn(dir,-90)) accuracy*=4 //hit from behind or sides
		for(var/obj/Injuries/Eye/I in m) accuracy*=2
		for(var/obj/Injuries/Arm/I in m) accuracy*=1.2
		for(var/obj/Injuries/Leg/I in m) accuracy*=1.2
		if(m.Action=="Meditating") accuracy*=10
		if(m.KO||m.Frozen) accuracy=100
	return accuracy
mob/proc/get_active_shield() for(var/obj/Shield/s in src) if(s.Using) return s
mob/proc/get_melee_drain()
	var/drain=1*weights()
	if(Warp) drain*=3 //combos on
	return drain
mob/proc/get_melee_knockback_distance(mob/m)
	var/dist=0
	if(prob(KB_On)&&ismob(m))
		dist=sqrt(BP/m.BP)*4

		var/obj/items/Sword/s=using_sword()
		if(s&&s.Style=="Energy") dist*=((Str*0.5)+(Pow*0.5))/m.Res
		else dist*=(Str/m.End)

		if(dist>20) dist=20
		if(dist>1) for(var/obj/Hokuto_Shinken/H in src) if(H.Attacking) dist=1
		if(using_sword()&&dist>=2) dist=round(dist/2)
	return round(dist)
mob/proc/get_melee_sounds(knockback_dist=0)
	var/list/l=list('weakpunch.ogg','weakkick.ogg','mediumpunch.ogg','mediumkick.ogg')
	if(using_sword()) l=list('swordhit.ogg')
	if(knockback_dist>=5) l=list('strongpunch.ogg','strongkick.ogg')
	for(var/obj/Hokuto_Shinken/h in src) if(h.Attacking) l=list('weakpunch.ogg')
	return l
mob/proc/using_sword() for(var/obj/items/Sword/s in src) if(s.suffix) return s
mob/proc/if_target_is_splitform_then_target_attacks_you(mob/target)
	var/mob/Splitform/sf=target
	if(client&&istype(sf,/mob/Splitform)&&!sf.Mode)
		sf.Mode="Attack Target"
		sf.Target=src
mob/proc/zombie_melee_infection(mob/target)
	if(!Zombie_Virus) return
	if(!ismob(target)) return
	if(using_sword()) return //cant infect those you didnt actually touch
	if(!target.client||target.Safezone||target.Android) return
	if(target.Health<70) //they have cuts that can be infected if true
		if(!target.Zombie_Virus)
			target<<"[src] just infected you with zombie virus!!"
			target.Zombie_Virus_Loop()
		target.Zombie_Virus+=1/(target.Zombie_Virus+1)
mob/proc/combo_teleport(mob/m)
	if(!Warp||Ki<Zanzoken_Drain()) return
	if(m.z!=z||getdist(src,m)>13) return
	var/turf/t=get_step(m,get_dir(m,src))
	if(t&&isturf(t)&&!t.density&&t.Enter(src)&&!t.Water&&!(locate(/mob) in t))
		Ki-=Zanzoken_Drain()
		Zanzoken_Mastery(0.2)
		view(7,src)<<sound('teleport.ogg',volume=10)
		flick('Zanzoken.dmi',src)
		loc=t
		dir=get_dir(src,m)
		if(ismob(m)) m.dir=get_dir(m,src)
mob/proc/if_target_is_npc_target_attacks_you(mob/target) spawn if(target)
	if(!ismob(target)) return
	if(istype(target,/mob/Enemy)&&client)
		target.Docile=0
		target.Attack_Target(src)
	if(istype(target,/mob/Troll)&&client)
		var/mob/Troll/troll=target
		troll.Target=src
		if(troll.Health<=40&&troll.Troll_Mode!="Run") troll.Troll_Run()
		else if(troll.Troll_Mode!="Attack") troll.Troll_Attack()
	if(istype(target,/mob/new_troll)&&client)
		var/mob/new_troll/t=target
		t.attacker=src
		t.end_combat=world.realtime+300
mob/proc/Melee(obj/O)
	if(!can_melee()) return
	var/mob/target=find_melee_target(O)
	if(!target) return
	if(client&&ismob(target)&&target.Flying&&!Flying) return
	var/energy_drain=get_melee_drain()
	if(energy_drain>Ki) return //too tired to attack
	var/dmg=get_melee_damage(target)
	var/accuracy=get_melee_accuracy(target)
	var/delay=Delay(4*Speed_Ratio())
	var/obj/Shield/ki_shield
	if(ismob(target)) ki_shield=target.get_active_shield()
	var/knockback=get_melee_knockback_distance(target)
	if(knockback) dmg*=1+(knockback/10)
	if(Omega_KB()) knockback=Get_Omega_KB()
	if(ismob(target)&&target.Safezone) knockback=0
	var/list/sounds=get_melee_sounds(knockback)
	if(client) Ki-=energy_drain
	attacking=1
	spawn(delay) attacking=0
	if(target&&ismob(target)&&target.attacking==1) set_opponent(target)
	melee_graphics()
	spawn if(target&&ismob(target)&&target.Get_Drone_AI()) target.Drone_Attack(src)
	if_target_is_splitform_then_target_attacks_you(target)
	if(ismob(target)&&ki_shield)
		var/shield_drain=dmg*0.3*(target.Max_Ki/100/(target.Eff**0.3))
		if(target.Ki>=shield_drain)
			target.Ki-=shield_drain
			view(5,target)<<sound(pick('meleemiss1.ogg','meleemiss2.ogg','meleemiss3.ogg'),volume=20)
			return
	if(ismob(target)) target.last_attacked_time=world.realtime
	if(prob(accuracy))
		zombie_melee_infection(target)
		view(5,src)<<sound(pick(sounds),volume=20)
		if(knockback)
			spawn if(src) Make_Shockwave(src,5)
			target.Knockback(src,knockback)
			if(!target) return
			combo_teleport(target)
		if(ismob(target))
			if(target.KO&&dmg>20) dmg=20 //no less than 5 hits to kill a ko person
			target.Health-=dmg
			if(!target.client&&target.Health<=0) target.Death(src)
			else
				if(!target.KO&&target.Health<=0) target.KO(src)
				else if(target.KO&&Fatal&&target.Health<=0) target.Death(src)
		if(isobj(target))
			target.Health-=dmg
			if(target.Health<=0)
				new/obj/Crater(target.loc)
				del(target)
		if(isturf(target))
			var/turf/t=target
			t.Health-=dmg
			if(t.Health<=0)
				t.Health=0
				t.Destroy()
	else
		view(5,target)<<sound(pick('meleemiss1.ogg','meleemiss2.ogg','meleemiss3.ogg'),volume=20)
		flick('Zanzoken.dmi',target)
	if_target_is_npc_target_attacks_you(target)
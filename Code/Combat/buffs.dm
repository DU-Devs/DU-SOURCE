/*
YOU LEARN NEW BUFF ATTRIBUTES IN LEARN USING SP THEN YOU CAN APPLY THEM TO ANY CUSTOM BUFF YOU HAVE.

finish attribute system

attribute ideas
	trans bp: add a big ssj-like bp boost on top of your trans based on the avg bp. this adds energy drain
		which scales based on how many times greater the temp boost is compared to your base bp
	illusion: make copies of yourself to confuse your opponent. sometimes you and your copies will switch
		places so the enemy cant figure out which is you for long
		illusions constantly change direction to face the enemy
	berserker: you auto melee fight your opponent with no control over yourself. you attack nearest targets
	random KO: like limit breaker, gain added power, but don't know when it'll KO you
	giant: just makes you large like the Giant buff does
	God_Fist: gain added power of some kind by having the buff drain your health
	channel anger: gain bp boost of sqrt(anger), but have some other stat(s) /anger. no bp drain of course
		or perhaps gain sqrt(anger) on top of the current bp boost of your buff, and have the drain only

Make more transformation graphics modules

Make able to add duplicate trans gfx modules. like 2 kinds of shockwaves
*/
mob/var
	list
		known_buff_attributes=new
		active_buff_attributes=new
	buff_transform_bp=0 //bp from the transform buff attribute
	tmp/rebuff_timer=0

mob/var/tmp/buff_drain_loop

mob/proc/Buff_Drain_Loop()
	set waitfor=0
	if(buff_drain_loop) return
	buff_drain_loop=1
	while(src)
		var/obj/Buff/B=buffed()
		if(B&&B.buff_bp>1)
			var/Drain=3*(B.buff_bp-1)/Eff**0.5
			Drain=(max_ki/100)*Drain
			Ki-=Drain
			if(Ki<=0) Buff_Disable(B)
			sleep(10)
		else break
	buff_drain_loop=0

mob/proc/buffed()
	if(current_buff&&current_buff.suffix&&current_buff.loc==src) return current_buff
	for(var/obj/Buff/B in src) if(B.suffix) return B //They have a buff active

mob/proc/buffed_with_bp()
	for(var/obj/Buff/B in src) if(B.suffix&&B.buff_bp>1) return 1 //they are using a bp increasing buff

obj/var
	Relearnable
	Reteachable

obj/Buff
	name="Custom Buff"
	hotbar_type="Buff"
	can_hotbar=1
	desc="This is a buff created by a player"
	teachable=1 //teachable
	Cost_To_Learn=25
	Skill=1
	Teach_Timer=10
	student_point_cost = 20
	Relearnable=1 //you can learn multiple copies of the obj/Buff type
	Reteachable=1 //you can teach multiple copies of the obj/Buff type
	Duplicates_Allowed=1

	New()
		spawn if(src&&name!=initial(name))
			new/obj/Buff/verb/Buff(src,name)
			verbs-=/obj/Buff/verb/Buff

		spawn(50) if(src)
			if(buff_bp>max_buff_bp)
				var/mob/m=loc
				if(m&&ismob(m)) m.revert_all_buffs()
				buff_bp=max_buff_bp
			//if(buff_str>2) buff_str=2
			//if(buff_for>2) buff_for=2
			//if(buff_spd>2) buff_spd=2

		spawn(2) if(src&&suffix)
			var/mob/m=loc
			if(m&&ismob(m)) m.current_buff=src

		spawn(10) if(!custom_buffs_allowed) del(src)

		. = ..()

	Del()
		var/mob/M=loc
		if(ismob(M)) M.Buff_Disable(src)
		. = ..()

	var
		tmp/being_edited
		editable=1
		points=0
		buff_bp=1
		buff_ki=1
		buff_str=1
		buff_dur=1
		buff_spd=1
		buff_for=1
		buff_res=1
		buff_off=1
		buff_def=1
		buff_reg=1
		buff_rec=1
		trans_graphics //whether opening graphics for transforming are enabled or not for this buff
		list/graphics //a list containing segments of the opening graphics, chosen by the player
		last_trans=0 //as realtime. prevents spamming of trans graphics
		buff_hair
		buff_icon
		prebuff_icon
		buff_aura
		prebuff_aura
		list/buff_overlays=list("Cancel")
		list/buff_opening //the opening transformation graphics customizable by the player
		list/buff_attributes=new

	verb/Hotbar_use()
		set hidden=1
		if(being_edited) return
		if(!suffix) usr.Buff_Enable(src)
		else usr.Buff_Disable(src)

	verb/Buff()
		set category="Skills"
		if(being_edited) return
		if(!suffix) usr.Buff_Enable(src)
		else usr.Buff_Disable(src)

	verb/Buff_Options()
		set category="Other"
		if(being_edited) return
		being_edited=1

		if(name == initial(name))
			for(var/V in verbs) if(V==/obj/Buff/verb/Buff) verbs-=V
			var/newname = input("You must name this buff before you can edit it further. This will be the name of the command to use it too. Example: Battle Mode","Options",name) as text
			if(newname && newname != "") name = newname
			new/obj/Buff/verb/Buff(src,name)
			verbs-=/obj/Buff/verb/Buff

		while(src&&usr)
			var/list/L=list("Cancel","Modify buff stat changes","Modify buff attributes")
			if(trans_graphics) L+="Disable graphical transformation"
			else L+="Enable graphical transformation"
			L+="Set name and description"
			if(buff_hair) L+="Reset buff hair"
			else L+="Choose buff hair"
			if(buff_icon) L+="Reset buff icon"
			else L+="Choose buff icon"
			if(buff_aura) L+="Reset buff aura"
			else L+="Choose buff aura"
			L+="Add buff overlay"
			if(buff_overlays.len>1) L+="Remove buff overlay"
			L+="Create opening transformation graphics"
			if(buff_opening&&buff_opening.len>0) L+="Remove opening transformation graphic"
			switch(input("What do you want to do to this buff?") in L)
				if("Cancel") break

				if("Modify buff stat changes")
					usr.Buff_Disable(src) //revert the buff before allowing edits
					being_edited=1
					winshow(usr,"buffstats",1)
					usr.Refresh_Buff_Window(src)
					while(src&&usr&&usr.client&&(winget(usr,"buffstats","is-visible")=="true")) sleep(1)
					if(usr&&usr.client) usr.buff_done()

				if("Modify buff attributes")
					while(src&&usr)
						switch(input("add or remove an attribute from this buff?") in list("cancel","add","remove",\
						"view guide"))
							if("cancel") break

							if("view guide") usr<<browse(buff_attribute_guide,"window=buff;size=700x600")

							if("add")
								var/list/addables=list("cancel")
								for(var/v in usr.known_buff_attributes) addables+=v
								for(var/v in buff_attributes) addables-=v
								if(addables.len==1) usr<<"You do not know any buff attributes to add to this"
								var/to_add=input("which buff attribute do you want added to this buff?") in addables
								if(to_add&&to_add!="cancel")
									buff_attributes+=to_add
									usr<<"[to_add] attribute added to [name]"

							if("remove")
								var/list/removables=list("cancel")
								for(var/v in buff_attributes) removables+=v
								if(removables.len==1) usr<<"There are no attributes on this buff to remove"
								var/to_remove=input("which attribute to remove?") in removables
								if(to_remove&&to_remove!="cancel")
									buff_attributes-=to_remove
									usr<<"[to_remove] attribute removed from [name]"

				if("Disable graphical transformation") trans_graphics=0

				if("Enable graphical transformation") trans_graphics=1

				if("Set name and description")
					for(var/V in verbs) if(V==/obj/Buff/verb/Buff) verbs-=V
					var/T=input("Name the buff","Options",name) as text
					if(T&&T!="") name=T
					T=input("Give it a description for Examine","Options",desc) as text
					desc=T
					new/obj/Buff/verb/Buff(src,name)
					verbs-=/obj/Buff/verb/Buff

				if("Reset buff icon") buff_icon=null

				if("Reset buff hair") buff_hair=null

				if("Reset buff aura") buff_aura=null

				if("Choose buff icon")
					var/icon/I=input("Choose the icon that you buff will change you to") as icon|null

					if(findtext("[I]",".jpg") || findtext("[I]",".jpeg"))
						alert("jpegs are not allowed until BYOND fixes the crashing bug that occurs from jpegs now in BYOND v510")
						return

					if(!IconTooBig(I)) buff_icon=I

				if("Choose buff hair")
					var/icon/I=input("Choose the hair icon that your buff will change you to") as icon|null
					if(!IconTooBig(I)) buff_hair=I

				if("Choose buff aura")
					var/icon/I=input("Choose the aura your buff will have when powering up") as icon|null
					if(!IconTooBig(I)) buff_aura=I

				if("Add buff overlay")
					var/icon/I=input("Choose the overlay the buff will add to you") as icon|null

					if(findtext("[I]",".jpg") || findtext("[I]",".jpeg"))
						alert("jpegs are not allowed until BYOND fixes the crashing bug that occurs from jpegs now in BYOND v510")
						return

					if(!IconTooBig(I)) buff_overlays+=I

				if("Remove buff overlay")
					var/V=input("Choose an overlay to remove from the buff") in buff_overlays
					if(V!="Cancel") buff_overlays-=V

				if("Create opening transformation graphics")
					buff_opening=usr.Add_Trans_Effects(buff_opening)
					last_trans=0

				if("Remove opening transformation graphic")
					buff_opening=usr.Remove_Trans_Effects(buff_opening)
					last_trans=0
		being_edited=0

mob/var/tmp/obj/Buff/current_buff
mob/proc
	Buffless_recovery()
		if(!current_buff||current_buff.buff_rec<=1) return recov
		return recov/current_buff.buff_rec

	BufflessKiMod()
		if(!current_buff||current_buff.buff_ki<=1) return Eff
		return Eff/current_buff.buff_ki

	revert_all_buffs() for(var/obj/Buff/b in src) Buff_Disable(b)

	Buff_Enable(obj/Buff/O) if(!O.being_edited&&!Redoing_Stats)

		if(rebuff_timer)
			src<<"You can not buff again for another [rebuff_timer] seconds (buff cooldown)"
			return
		/*for(var/obj/God_Fist/k in src) if(k.Using)
			src<<"Buffs can not be combined with God_Fist"
			return*/
		for(var/obj/Limit_Breaker/lb in src) if(lb.Using)
			src<<"Buffs can not be combined with Limit breaker"
			return

		for(var/obj/Buff/B in src) Buff_Disable(B)
		O.suffix="Active"
		if(O.trans_graphics&&world.realtime-O.last_trans>2*600) spawn if(src)
			Trans_Graphics(O.buff_opening)
			for(var/obj/Buff/B in src) B.last_trans=world.realtime

		if(O.buff_icon)
			O.prebuff_icon=icon
			icon=O.buff_icon
		if(O.buff_hair)
			overlays.Remove(hair,ssjhair,ussjhair,ssjfphair,ssj2hair,ssj3hair,ssj4hair, ssj_blue_hair)
			overlays+=O.buff_hair
		if(O.buff_aura&&Auras)
			O.prebuff_aura=Auras.icon
			Auras.icon=O.buff_aura
		for(var/V in O.buff_overlays) if(V!="Cancel") overlays+=V

		for(var/v in O.buff_attributes)
			active_buff_attributes-=v
			active_buff_attributes+=v
			switch(v)
				if("transformation")
					buff_transform_bp=Avg_Base*bp_mod
					if(buff_transform_bp>(base_bp+hbtc_bp)*4) buff_transform_bp=(base_bp+hbtc_bp)*4
					if(buff_transform_bp<(base_bp+hbtc_bp)*0.25) buff_transform_bp=(base_bp+hbtc_bp)*0.25

		Buff_Drain_Loop()
		buff_transform_drain()

		bp_mult+=O.buff_bp-1
		Ki*=O.buff_ki
		max_ki*=O.buff_ki
		Eff*=O.buff_ki
		Str*=O.buff_str
		strmod*=O.buff_str
		End*=O.buff_dur
		endmod*=O.buff_dur
		Spd*=O.buff_spd
		spdmod*=O.buff_spd
		Pow*=O.buff_for
		formod*=O.buff_for
		Res*=O.buff_res
		resmod*=O.buff_res
		Off*=O.buff_off
		offmod*=O.buff_off
		Def*=O.buff_def
		defmod*=O.buff_def
		regen*=O.buff_reg
		recov*=O.buff_rec

		current_buff=O
		if(!rebuff_timer) Rebuff_timer_countdown()
		rebuff_timer = 2
		src << "<font color=cyan>You have activated [O]"
		if(O.name == initial(O.name)) src << "<font color=cyan>But it appears you have not set it up yet. To customize a custom buff use the Buff Options \
		command found in the Other tab"


	Rebuff_timer_countdown()
		set waitfor=0
		sleep(1) //necessary
		while(src)
			if(!rebuff_timer) return
			rebuff_timer--
			if(!rebuff_timer) break
			else sleep(10)

	Buff_Disable(obj/Buff/O) if(O&&O.suffix)
		O.suffix=null

		if(O.buff_hair)
			overlays-=O.buff_hair
			SSj_Hair()
		if(O.buff_icon) icon=O.prebuff_icon
		if(O.buff_aura&&Auras) Auras.icon=O.prebuff_aura
		for(var/V in O.buff_overlays) if(V!="Cancel") overlays-=V

		for(var/v in O.buff_attributes)
			active_buff_attributes-=v
			switch(v)
				if("transformation")
					buff_transform_bp=0

		bp_mult-=O.buff_bp-1
		Ki/=O.buff_ki
		max_ki/=O.buff_ki
		Eff/=O.buff_ki
		Str/=O.buff_str
		strmod/=O.buff_str
		End/=O.buff_dur
		endmod/=O.buff_dur
		Spd/=O.buff_spd
		spdmod/=O.buff_spd
		Pow/=O.buff_for
		formod/=O.buff_for
		Res/=O.buff_res
		resmod/=O.buff_res
		Off/=O.buff_off
		offmod/=O.buff_off
		Def/=O.buff_def
		defmod/=O.buff_def
		regen/=O.buff_reg
		recov/=O.buff_rec

		src << "<font color=[rgb(0,255,0)]>You have deactivated [O]"

		current_buff=null

mob/verb/buff_point(posneg as text, buff_stat as text) //posneg = "-1" | "1". verb called thru skin
	set name = ".buff_point"
	set hidden = 1

	var/obj/Buff/B
	for(B in src) if(B.being_edited) break
	if(!B)
		buff_done()
		return
	posneg = text2num(posneg)

	//security
	if(!(winget(src,"buffstats","is-visible") == "true")) return
	if(!(posneg in list(-1, 1))) return
	if(posneg >= 1 && B.points < posneg) return

	var/per_point = posneg * 0.1
	var/stat_min = 0.7

	switch(buff_stat)
		if("buff_bp")
			if(B.vars[buff_stat] >= max_buff_bp && posneg == 1) return
		if("buff_ki")
			if(B.vars[buff_stat] >= 1.5 && posneg==1) return
		if("buff_str")
			if(B.vars[buff_stat] >= 2&&posneg==1) return
		if("buff_dur")
		if("buff_spd")
			if(B.vars[buff_stat] >= 2 && posneg==1) return
		if("buff_for")
			if(B.vars[buff_stat] >= 2 && posneg==1) return
		if("buff_res")
		if("buff_off")
		if("buff_def")
		if("buff_reg")
			if(B.vars[buff_stat] >= 1.3 && posneg == 1) return
			stat_min = 1
		if("buff_rec")
			if(B.vars[buff_stat] >= 1.3 && posneg == 1) return
			stat_min = 1

	if(posneg < 0 && B.vars[buff_stat] <= stat_min) return //stat can not go any lower

	B.vars[buff_stat] += per_point
	B.points -= posneg

	Refresh_Buff_Window(B)

mob/verb/buff_done() //verb called thru skin
	set name=".buff_done"
	set hidden=1
	winshow(src,"buffstats",0)
	for(var/obj/Buff/B in src) B.being_edited=0

mob/proc/Refresh_Buff_Window(obj/Buff/B) if(client)
	winset(src,"buffstats.BPmult","text=[B.buff_bp]")
	winset(src,"buffstats.Efficiency","text=[B.buff_ki]")
	winset(src,"buffstats.Strength","text=[B.buff_str]")
	winset(src,"buffstats.Endurance","text=[B.buff_dur]")
	winset(src,"buffstats.Speed","text=[B.buff_spd]")
	winset(src,"buffstats.Force","text=[B.buff_for]")
	winset(src,"buffstats.Resistance","text=[B.buff_res]")
	winset(src,"buffstats.Offense","text=[B.buff_off]")
	winset(src,"buffstats.Defense","text=[B.buff_def]")
	winset(src,"buffstats.Regeneration","text=[B.buff_reg]")
	winset(src,"buffstats.Recovery","text=[B.buff_rec]")
	winset(src,"buffstats.points","text=[B.points]")

mob/proc
	Trans_Graphics(list/L) if(L) for(var/V in L)
		var/list/EA=L[V] //Effect Attributes
		var/I=EA["Icon"] //icon
		var/Timer=EA["Time"] //timer
		var/N=EA["Amount"] //amount of effects
		if(!N) N=1
		spawn for(var/O in 1 to N)
			switch(V)
				if("Shockwave")
					Make_Shockwave(src,7,I,sw_icon_size=256)
					sleep(rand(3,15))
				if("Shaking")
					for(var/mob/M in player_view(20,src)) if(M.client) M.ScreenShake()
					sleep(rand(3,15))
				if("Damaged Ground")
					for(var/turf/T in TurfCircle(EA["Range"],src))
						T.Make_Damaged_Ground(1)
						if(prob(25)) sleep(1)
					sleep(rand(5,15))
				if("Dust")
					var/turf/t = base_loc()
					if(t)
						Dust(t, end_size = 1, time = 35)
					sleep(rand(5,15))
				if("Explosions")
					var/list/Temp=new
					for(var/turf/T in view(10,src)) Temp+=T
					if(Temp.len)
						var/turf/Turf=pick(Temp)
						if(isturf(Turf)) Explosion_Graphics(Turf,rand(1,5))
					sleep(rand(10,30))
				if("Big Crater")
					BigCrater(loc)
					sleep(20)
				if("Little Craters")
					var/list/Temp=new
					for(var/turf/T in view(6,src)) Temp+=T
					if(Temp.len != 0)
						var/turf/Turf = pick(Temp)
						if(isturf(Turf)) Small_crater(Turf)
					sleep(5)
				if("Lightning")
					var/obj/Lightning_Strike/LS=Get_lightning_strike()
					LS.SafeTeleport(loc)
					LS.y+=12
					LS.x+=rand(-10,10)
					if(LS&&I)
						LS.icon=I
						LS.overlays-=LS.overlays
					sleep(rand(0,10))
		sleep(Timer)
	Add_Trans_Effects(list/L)
		if(!L) L=new/list
		var/max_effects=5
		while(L.len>=max_effects)
			switch(alert(src,"Your transformation effects list exceeds the maximum amount of entries \
			([L.len] / [max_effects]). You must remove the excess entries before you can add more. \
			Remove entries now?","Options","Yes","No"))
				if("No") return L
				if("Yes") L=Remove_Trans_Effects(L)
		while(src)
			if(L.len>=max_effects) break
			else switch(input(src,"What effect do you want to add? They will be executed in the order chosen. \
			You can choose [max_effects-L.len] more entries") in list("Done","Shockwaves","Shaking",\
			"Damaged Ground","Dust","Explosions","Big Crater","Little Craters","Lightning"))
				if("Done") break
				if("Shockwaves")
					var/icon/I
					switch(alert(src,"Custom icon?","Options","Default","Custom"))
						if("Custom")
							I=input(src,"Choose an icon") as icon|null
							if(IconTooBig(I)) I=null
					var/T=input(src,"Enter the delay between this effect and the next in seconds. 0.1-10","Options"\
					,0.5) as num
					if(T<0.1) T=0.1
					if(T>10) T=10
					var/N=input(src,"Enter amount of effects before effect finishes. 1-10","Options",3) as num
					if(N<1) N=1
					if(N>10) N=10
					L["Shockwave"]=list("Icon"=I,"Time"=T*10,"Amount"=round(N))
				if("Shaking")
					var/T=input(src,"Enter the delay between this effect and the next in seconds. 0.1-10","Options"\
					,0.5) as num
					if(T<0.1) T=0.1
					if(T>10) T=10
					var/N=input(src,"Enter amount of this effects before effect finishes. 1-10","Options",3) as num
					if(N<1) N=1
					if(N>10) N=10
					L["Shaking"]=list("Time"=T*10,"Amount"=round(N))
				if("Damaged Ground")
					var/T=input(src,"Enter the delay between this effect and the next in seconds. 0.1-10","Options"\
					,0.5) as num
					if(T<0.1) T=0.1
					if(T>10) T=10
					var/N=input(src,"Enter the range of this effect. 1-10","Options",3) as num
					if(N<1) N=1
					if(N>10) N=10
					L["Damaged Ground"]=list("Time"=T*10,"Range"=round(N))
				if("Dust")
					var/T=input(src,"Enter the delay between this effect and the next in seconds. 0.1-10","Options"\
					,0.5) as num
					if(T<0.1) T=0.1
					if(T>10) T=10
					L["Dust"]=list("Time"=T*10)
				if("Explosions")
					var/T=input(src,"Enter the delay between this effect and the next in seconds. 0.1-10","Options"\
					,0.5) as num
					if(T<0.1) T=0.1
					if(T>10) T=10
					var/N=input(src,"Enter amount of this effects before effect finishes. 1-5","Options",3) as num
					if(N<1) N=1
					if(N>5) N=5
					L["Explosions"]=list("Time"=T*10,"Amount"=round(N))
				if("Big Crater")
					var/T=input(src,"Enter the delay between this effect and the next in seconds. 0.1-10","Options"\
					,0.5) as num
					if(T<0.1) T=0.1
					if(T>10) T=10
					var/N=input(src,"Enter amount of this effects before effect finishes. 1-5","Options",1) as num
					if(N<1) N=1
					if(N>5) N=5
					L["Big Crater"]=list("Time"=T*10,"Amount"=round(N))
				if("Little Craters")
					var/T=input(src,"Enter the delay between this effect and the next in seconds. 0.1-10","Options"\
					,0.5) as num
					if(T<0.1) T=0.1
					if(T>10) T=10
					var/N=input(src,"Enter amount of this effects before effect finishes. 1-10","Options",5) as num
					if(N<1) N=1
					if(N>10) N=10
					L["Little Craters"]=list("Time"=T*10,"Amount"=round(N))
				if("Lightning")
					var/icon/I
					switch(alert(src,"Custom icon?","Options","Default","Custom"))
						if("Custom")
							I=input(src,"Choose an icon") as icon|null
							if(IconTooBig(I)) I=null
					var/T=input(src,"Enter the delay between this effect and the next in seconds. 0.1-10","Options"\
					,0.5) as num
					if(T<0.1) T=0.1
					if(T>10) T=10
					var/N=input(src,"Enter amount of this effects before effect finishes. 1-20","Options",10) as num
					if(N<1) N=1
					if(N>20) N=20
					L["Lightning"]=list("Icon"=I,"Time"=T*10,"Amount"=round(N))
		return L
	Remove_Trans_Effects(list/L)
		if(!L||!L.len) alert(src,"There are no effects to remove")
		else while(src)
			var/list/Options=list("Done")
			for(var/V in L) Options+=V
			var/V=input(src,"Which effect do you want to remove?") in Options
			if(!V||V=="Done") break
			else L-=V
		return L
var/buff_attribute_guide={"<html><head><body><body bgcolor="#000000"><font size=5><font color="#CCCCCC">

Here are all the attributes and what they do:<ul>

<li>Transform: This attributes causes the buff to be like a transformation, for example, an alien
transformation. The buff will add some static bp on top of your normal bp. The amount it adds is based
on the average bp of the server. There will be energy drain.

<li>Giant: This has no stat effects but just causes you to grow into a giant.

<li>God_Fist: This attribute  will cause you to power up much faster than normal, but
instead of just your energy draining from powering up, your health drains as well. Speed increases.
Defense and regeneration decrease.

<li>Limit breaker: This attribute increases bp, regeneration, and recovery greatly. The downside is
that you could randomly get knocked out while using the buff.

</ul>

"}
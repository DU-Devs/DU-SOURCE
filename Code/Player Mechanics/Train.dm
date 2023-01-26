var/NORMALIZE_GAINS = 0.1

mob/var/tmp/mob/Opponent
mob/var/tmp/list/opponent_gains

var/last_input=1

mob/var/BPResetAtTime = 0
var/resetBP = 0
var/lastBPReset = 0

mob/Admin5/verb/Reset_BP_To_Amount(n as num)
	if(!n) return
	lastBPReset = world.realtime
	resetBP = n
	Tech_BP = 100
	highest_base_bp = Math.Min(highest_base_bp, resetBP)
	highestBPTier = 1
	SetAvgBase()
	sleep(1)
	SetAvgTotalBP()
	sleep(1)
	SetUpgradeCap()
	sleep(1)
	SetHighestBP()
	sleep(1)
	for(var/mob/M in players)
		spawn M.ResetBPToAmount()
	usr << "BP reset to [Commas(resetBP)]."

mob/proc/ResetBPToAmount()
	if(lastBPReset && src.base_bp > resetBP && src.BPResetAtTime < lastBPReset)
		src.base_bp = Math.Min(base_bp, resetBP)
		src.unlockedBP = Math.Min(unlockedBP, resetBP)
		src.cyber_bp = Math.Min(cyber_bp, Get_max_cyber_bp_upgrade(Race))
		src.gravity_mastered = Math.Min(src.gravity_mastered, Limits.GetSettingValue("Maximum Gravity"))
		RemoveInvalidForms()
		alert(src, "Your BP has been reset to [Commas(resetBP)] because it was above that amount.")
	src.BPResetAtTime = world.realtime

mob/proc/Majin_attack_gain(n=1,mob/o,apply_hbtc_gains=1,include_weights=1)
	if(!o) o = Opponent(65)
	n=ToOne(n)
	RecordHighestBPEverGotten()
	while(n)
		n--
		if(o && o.max_ki / o.Eff * 0.6 > max_ki / Eff) max_ki = o.max_ki / o.Eff * 0.6 * Eff
		if(o) LeechOpponent(o)

mob/proc/Attack_Gain(N = 1, mob/leech, apply_hbtc_gains = 1, include_weights = 1, skip_leech, skipBPGains, partyGains = 1)
	if(!leech) leech = Opponent(65)
	while(N > 0)
		var/mod = min(N, 1)
		if(partyGains)
			mod /= PartySize()
			for(var/mob/M in PartyMembers())
				if(!skipBPGains) M.GainBP(GetBaseBPGain(bp_mod + mod))
				M.Raise_Ki(4 * mod)
				if(leech && !skip_leech)
					M.LeechOpponent(leech)
		else
			if(!skipBPGains) GainBP(GetBaseBPGain(4 * mod))
			Raise_Ki(4 * mod)
			if(leech && !skip_leech)
				LeechOpponent(leech)
		N--
		sleep(0)

//=========================

var/mob/player_with_highest_base_bp
var/highest_base_and_hbtc_bp=1
var/mob/highest_base_and_hbtc_bp_mob
mob/var/highest_bp_ever_had=1


mob/var/tmp
	report_bp_gains
	reporter_looping

mob/verb/Show_BP_Gains()
	set category = "Other"
	report_bp_gains = !report_bp_gains
	if(report_bp_gains)
		src << "<font color=cyan>You will now get messages telling you how much BP you gained every 5 seconds"
		reporter_loop()
	else
		src << "<font color=cyan>BP gain messages off"

mob/proc/reporter_loop()
	set waitfor=0
	if(reporter_looping) return
	reporter_looping=1
	var/old_bp = base_bp
	while(report_bp_gains)
		sleep(50)
		var/gained = base_bp - old_bp
		old_bp = base_bp
		src << "Gained [gained >= 0 ? "+" : ""][gained > 1000 ? Commas(gained) : round(gained, 0.01)] base bp."
	reporter_looping=0

mob/proc/GravityGainsMult()
	return 1 + Math.Log10(gravity_mastered)

mob/proc/RecordHighestBPEverGotten()
	if(IsFusion())
		highest_bp_ever_had = 1
		return
	if(base_bp + static_bp > highest_bp_ever_had) highest_bp_ever_had = base_bp + static_bp

mob/var
	tmp
		lastRaiseBP = 0 //world.time
	baseGainAmount = 0.0005
	coreGainsTimer = 36000
	coreTimerRefilling = 0
	timeOutPrompt = 1

mob/var/wellGains = 0

mob/proc/Raise_Ki(Amount=1)
	Amount *= 7 //it was too low and there is no longer a stat focus on energy so here we go
	if(Safezone) Amount*=0.25
	//if(ultra_pack) Amount*=1.2
	var/scale_mod = (1400 / (max_ki / Eff))**2
	if(scale_mod>1) scale_mod=1
	Amount*=scale_mod
	var/ki_pct = Ki / max_ki
	max_ki+=Amount*Eff*Decline_Energy_Gain()*0.01*Progression.GetSettingValue("Energy Gain Rate")
	Ki = Math.Max(Ki, max_ki * ki_pct)

var/Max_Speed=1 //The speed of the person with the highest speed online
var/mob/max_speed_mob

var/speedDelayMultMod = 2.3

mob/proc/Speed_delay_mult(severity = 1)
	var
		ratio = getSpeedRatio()
		mod = GetSpeedMod(ratio, severity)
	//if(ckey == "khunkurisu") src << "Speed_delay_mult() returns [InvertSpeedMod(mod) * speedDelayMultMod]"
	return InvertSpeedMod(mod) * speedDelayMultMod

mob/proc/InvertSpeedMod(spd = 1)
	//if(ckey == "khunkurisu") src << "InvertSpeedMod() returns [1 / spd]"
	return 1 / spd

mob/proc/GetSpeedMod(spd = 1, severity = 1)
	var
		mod = 1
		minMod = 0.35
		maxMod = 2.35
	if(spd > 1)
		mod = spd**severity
	else
		mod *= spd**severity
	if(mod < minMod) mod = minMod
	if(mod > maxMod) mod = maxMod
	//if(ckey == "khunkurisu") src << "GetSpeedMod() returns [mod]"
	return mod


mob/proc/Decline_Energy_Gain()
	var/Amount=1
	//Amount*=decline_gains()
	return Amount

var/Stat_Record=1
var/lastStatRecordRefresh = 0
proc/RefreshStatRecord()
	set waitfor = 0
	if(lastStatRecordRefresh + 600 > world.time) return
	lastStatRecordRefresh = world.time

	Stat_Record=1
	for(var/mob/P in players)
		P.Stat_Avg()

mob/proc/Is_Lowest_Stat(N=1)
	if(N==min(Str,End,Spd,Pow,Res,Off,Def)) return 1

var/mob/stat_record_mob

mob/proc/Stat_Avg() //The max stats someone has reached on the server
	var/Total=0
	Total+=Str/(strmod ? strmod : 1)
	Total+=End/(endmod ? endmod : 1)
	Total+=Pow/(formod ? formod : 1)
	Total+=Res/(resmod ? resmod : 1)
	Total+=Spd/(spdmod ? spdmod : 1)
	Total+=Off/(offmod ? offmod : 1)
	Total+=Def/(defmod ? defmod : 1)
	Total/=7
	Total/=(Modless_Gain ? Modless_Gain : 1)
	if(client) if(Total>Stat_Record)
		Stat_Record=Total
		stat_record_mob=src
	if(!player_with_highest_base_bp || base_bp > player_with_highest_base_bp.base_bp)
		if(!src.IsFusion()) player_with_highest_base_bp = src
	if(!playerWithHighestTier || bpTier > highestBPTier)
		if(!src.IsFusion()) playerWithHighestTier = src
	return Total

mob/proc/Can_Train()
	if(KO || attacking || !move) return
	return 1

mob/var/Action //What the person is currently doing, can be training, meditating, flying
mob/verb
	Train_verb()
		set name="Train"
		set category = "Skills"
		Train()
	Med_verb()
		set name="Meditate"
		set category = "Skills"
		Meditate()
	Shadow_Spar_verb()
		set name = "Shadow Spar"
		set category = "Skills"
		Shadow_Spar()

mob/proc/Meditate(from_ai_train)
	if(Can_Train())
		Land()
		if(Action!="Meditating")
			if(!from_ai_train) Cease_training()
			if(IsRoundFighter())
				src<<"You can not meditate when it is your turn to fight"
				return
			God_FistStop()
			if(powerup_obj && powerup_obj.Powerup == 1) powerup_obj.Powerup = 0
			Action="Meditating"
			if(trainState != "Med") trainState = "Med"
			dir=SOUTH
			icon_state="Meditate"
			ReleaseGrab()
			Auto_Attack=0
			if(anger>100) Calm()
			Stop_Powering_Up()
		else
			Action=null
			icon_state=""
			if(trainState == "Med") trainState = null
			if(Flying && !ultra_instinct) icon_state="Flight"

mob/proc/Train(from_ai_train)

	if(Race=="Majin")
		src<<"Majins can not train. They do not gain any power from training."
		return

	if(Can_Train())
		Land()
		if(Action!="Training")
			if(!from_ai_train) Cease_training()
			if(trainState != "Self") trainState = "Self"
			Action="Training"
			dir=SOUTH
			icon_state="Train"
			ReleaseGrab()
			Auto_Attack=0
		else
			StopTraining()

mob/proc/StopTraining()
	if(trainState == "Self") trainState = null
	if(Action == "Training") Action = null
	if(icon_state == "Train") icon_state = ""
	if(Flying && !ultra_instinct) icon_state="Flight"


obj/Peebag
	desc="Punching this only gives BP nothing else"
	icon='Punching Bag.dmi'
	Cost=3000
	dir=WEST
	density=1
	pixel_x=-6
	takes_gradual_damage=1
	verb/Upgrade()
		set name="Repair/Upgrade health"
		set src in view(1)
		if(usr in view(1,src))
			var/max_health=usr.Knowledge*usr.Intelligence()
			if(Health<max_health)
				player_view(15,usr)<<"[usr] repairs/upgrades the [src]'s health to [Commas(max_health)] BP"
				Health=max_health
			else usr<<"The [src] is beyond your upgrading abilities"
	verb/Bolt()
		set src in oview(1)
		usr.Bolt(src)
//Skill training. Press the right directional key to face an imaginary opponent and strike them.
mob/var/tmp/Shadow_Sparring

mob/proc/Shadow_Spar()
	if(Shadow_Sparring)
		src.SendMsg("You stop shadow sparring.", CHAT_IC)
		Shadow_Sparring=0
	else if(Can_Train())
		Cease_training()
		Shadow_Sparring=1
		Shadow_Spar_Loop()

mob/proc/Stop_Shadow_Sparring()
	Shadow_Sparring = 0

mob/var/tmp/missed_shadow_spar

mob/var/tmp/shadow_spar_loop_running
mob/var/last_ss_time

obj/Shadow_Spar_Overlay
	icon = 'White.dmi'
	layer = 7

proc/RandomSSColor()
	return rgb(rand(0,255),rand(0,255),rand(0,255),rand(4,8))

mob/proc/Shadow_Spar_Loop()
	if(shadow_spar_loop_running) return
	shadow_spar_loop_running=1
	Auto_Attack=0
	src.SendMsg("Face the direction of the shadow each time it appears.", CHAT_IC)

	var/mob/O=new
	O.name="Shadow Spar Guy"
	O.icon=icon

	if(client) client.screen+=O

	while(src && client && Shadow_Sparring)
		trainState = "Shadow"
		while(O)
			O.dir=pick(NORTH,SOUTH,EAST,WEST)
			if(dir!=turn(O.dir,180)) break
			sleep(1)

		var/matrix/m = matrix() * (rand(95,105) / 100)
		m.Turn(rand(-4,4))
		O.transform = m

		O.alpha = 140
		O.step_x = step_x
		O.step_y = step_y

		O.icon_state = icon_state

		if(O.dir==SOUTH) O.screen_loc="CENTER,CENTER+1"
		if(O.dir==NORTH) O.screen_loc="CENTER,CENTER-1"
		if(O.dir==WEST) O.screen_loc="CENTER+1,CENTER"
		if(O.dir==EAST) O.screen_loc="CENTER-1,CENTER"

		client.screen += O

		O.PunchGraphics()

		sleep(TickMult(6))
		if(src&&O) dir=turn(O.dir,180)
		PunchGraphics()
		
		if(client && O) client.screen -= O
		sleep(TickMult(2))
	if(trainState == "Shadow") trainState = null
	spawn(10) if(src) shadow_spar_loop_running=0
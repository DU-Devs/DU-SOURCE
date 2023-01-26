mob/proc/GetPowerRollMod()
	var/n = 0
	n += GetStatMod("Str")
	n += GetStatMod("Spd")
	n += GetStatMod("Dur")
	n += GetStatMod("Res")
	n += GetStatMod("For")
	n += GetStatMod("Acc")
	n += GetStatMod("Ref")
	n = n / 7
	n += bpTier / 3 + 1
	return Math.Ceil(n)

mob/proc/AttemptEscape()
	var/n = GetPowerRollMod()
	n += GetTraitRank("Escape Artist") * 2
	return Math.Rand(1, 20) + n

mob/proc/AttemptPursue()
	var/n = GetPowerRollMod()
	n += GetTraitRank("Pursuer")
	return Math.Rand(1, 20) + n

mob/verb/Escape_Roll()
	set category = "Other"
	var/escapeRoll = AttemptEscape()
	for(var/mob/M in Say_Recipients())
		M.SendMsg("<span style='font-size:10pt;color:[TextColor];font-family:Walk The Moon'>-[name] is attempting to flee...<br>Roll: [escapeRoll]</span>", CHAT_IC)

mob/verb/Pursue_Roll()
	set category = "Other"
	var/pursueRoll = AttemptPursue()
	for(var/mob/M in Say_Recipients())
		M.SendMsg("<span style='font-size:10pt;color:[TextColor];font-family:Walk The Moon'>-[name] is attempting pursuit!<br>Roll: [pursueRoll]</span>", CHAT_IC)
/*
with pix moving since the map will seem so much bigger just imagine all the extra landmarks we
can add to the map without it seeming "right next to each other"
since travel time will be increased. We could add Roshi's house, procedural dungeons entrances, and so on. Each separate ecosystem and village
and town would seem more legitimate instead of being able to reach anything in 12 seconds max. We could make Earth the best map ever for
starters.
*/

world/fps = 40

mob/var
	tmp
		next_input_move_time = 0
		last_input_move = 0
		input_disabled = 0 //+1 for each thing disabling input

var/epsilon = 0.0001

mob/proc
	GetInputMoveDelay(d = NORTH, raw_mult_only)
		var/t = Limits.GetSettingValue("Base Move Delay")
		if(!d) return t
		//t += 0.25 * (Speed_delay_mult(severity = 0.2) - 1)

		/*if(Being_chased())
			if(t < 1) t = 1
			t += 0.35*/
		//if(senzu_overload) t += 0.35
		if(sight) t += 0.5
		if(stun_level) t += stun_level * 4

		if(d && (d in list(NORTHEAST,NORTHWEST,SOUTHEAST,SOUTHWEST)))
			t *= 1.15

		if(!raw_mult_only)
			t *= world.tick_lag
			t = TickMult(t) //so we can add decimals above. such as +0.5 move delay
			t -= epsilon //get rid of floating point errors

		return t

	UpdateNextInputMoveTime(d = NORTH)
		next_input_move_time = world.time + GetInputMoveDelay(d)

	CanInputMove()
		if(input_disabled) return
		if(in_dragon_rush) return
		else return 1 //and remove this line if you enable the above line

	AlterInputDisabled(n = 1)
		input_disabled += n
		if(input_disabled < 0) input_disabled = 0
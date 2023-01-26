/*
with pix moving since the map will seem so much bigger just imagine all the extra landmarks we
can add to the map without it seeming "right next to each other"
since travel time will be increased. We could add Roshi's house, procedural dungeons entrances, and so on. Each separate ecosystem and village
and town would seem more legitimate instead of being able to reach anything in 12 seconds across the map. We could make Earth the best map ever for
starters.
*/

world/fps = 20


mob/Admin4/verb/Set_Movement_Speed()
	set category="Admin"
	Limits.baseMoveDelay = input(src,"Set a number for base move delay","Options",Limits.baseMoveDelay) as num

mob/var
	tmp
		next_input_move_time = 0 //in certain cases we are not allowed to move our character using input (WASD or arrow keys) every tick like would normally be allowed, such as
			//when we are kikoho stunned or something
		last_input_move = 0 //the timestamp of when we last successfully moved using input alone. (any non-input forces moving us will not affect this, such as getting knockbacked)
		input_disabled = 0 //+1 for each thing disabling input. can only move using input if this is ZERO

var/epsilon = 0.0001 //our attempt for avoiding floating point errors by comparing if any two floats are "within epsilon" of each other, and if they are then we consider them
//"equal". although im pretty sure byond automatically handles floating point errors to some extent so if this is unneccessary idk but better to be safe

mob/proc
	//return a delay modifier for how fast our character should be moving, based on various status effects currently affecting them, such as blindness or leg injuries etc
	//then somewhere else our pixel move speed will be multiplied by this modifier.
	GetInputMoveDelay(d = NORTH, raw_mult_only)
		var/t = Limits.baseMoveDelay
		if(!d) return t
		//t += 0.25 * (Speed_delay_mult(severity = 0.2) - 1)

		/*if(Being_chased())
			if(t < 1) t = 1
			t += 0.35*/
		//if(senzu_overload) t += 0.35
		if(sight) t += 0.5
		if(!Flying) for(var/obj/Injuries/Leg/i in injury_list) t += 0.5
		if(stun_level) t += stun_level * 4

		if(d && (d in list(NORTHEAST,NORTHWEST,SOUTHEAST,SOUTHWEST)))
			t *= 1.15 //this is somewhat arbitrary, but i slowed them down if they are moving diagonal, because if you dont slow it down, it appears as if you move faster
			//diagonally than you do horizontally or vertically, because in terms of screen space you kind of are, since going northeast is +1 x pixel and +1 y pixel, whereas
			//going east is just +1 x pixel. either way, without this, moving diagonally just looks faster and thats not nice since all directions should "appear" to be moving
			//at the same speed

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
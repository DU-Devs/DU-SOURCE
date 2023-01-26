mob/var
	new_decline_system

	decline_gain=0.1
	lifespan_gain=0.3

	decline_slowdown_start_age=30
	lifespan_slowdown_start_age=80

	decline_gain_slowdown_exponent=1
	lifespan_gain_slowdown_exponent=1

	max_age_bp_penalty=0.6
	age_power_loss_exponent=1

mob/proc/Apply_racial_aging_variables()
	switch(Race)
		if("Yasai")
		if("Human")
			decline_gain=0.1
			lifespan_gain=0.3
			decline_slowdown_start_age=20

		if("Puranto")
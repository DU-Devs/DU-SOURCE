// This library handles a large number of time-related functions, such as converting between
// different measurements, recording time from different points, and comparing
// a given timestamp to the current time to see if a given cooldown would have subsided.

var/global/time/Time = new

time
	var/const
		SECONDS = 10
		MINUTES = 60
		HOURS = 60
		DAYS = 24
		WEEKS = 7
		MONTHS = 4
		YEARS = 12

	proc
		//These take common units of time and convert them to the DM standard timestep (decisecond).
		//As the units get larger the accuracy starts to decline slightly- however the loss of precision is worth the ease of calculation.
		FromSeconds(t)
			return t * SECONDS
		
		FromMinutes(t)
			return FromSeconds(t) * MINUTES
		
		FromHours(t)
			return FromMinutes(t) * HOURS
		
		FromDays(t)
			return FromHours(t) * DAYS
		
		FromWeeks(t)
			return FromDays(t) * WEEKS
		
		FromMonths(t)
			return FromWeeks(t) * MONTHS
		
		FromYears(t)
			return FromMonths(t) * YEARS
		
		//These take the standard timestep in DM (decisecond) and convert them to other units of time.
		//As the units get larger the accuracy starts to decline slightly- however the loss of precision is worth the ease of calculation.
		ToSeconds(t)
			return t / SECONDS
		
		ToMinutes(t)
			return t / (MINUTES * SECONDS)
		
		ToHours(t)
			return t / (HOURS * MINUTES * SECONDS)
		
		ToDays(t)
			return t / (DAYS * HOURS * MINUTES * SECONDS)
		
		ToWeeks(t)
			return t / (WEEKS * DAYS * HOURS * MINUTES * SECONDS)
		
		ToMonths(t)
			return t / (MONTHS * WEEKS * DAYS * HOURS * MINUTES * SECONDS)
		
		ToYears(t)
			return t / (YEARS * MONTHS * WEEKS * DAYS * HOURS * MINUTES * SECONDS)
		
		//These take the standard timestep in DM (decisecond) and convert them to other units of time, rounded to the nearest whole unit.
		//As the units get larger the accuracy starts to decline slightly- however the loss of precision is worth the ease of calculation.
		ToRoundedSeconds(t)
			return Math.Floor(ToSeconds(t))
		
		ToRoundedMinutes(t)
			return Math.Floor(ToMinutes(t))
		
		ToRoundedHours(t)
			return Math.Floor(ToHours(t))
		
		ToRoundedDays(t)
			return Math.Floor(ToDays(t))
		
		ToRoundedWeeks(t)
			return Math.Floor(ToWeeks(t))
		
		ToRoundedMonths(t)
			return Math.Floor(ToMonths(t))
		
		ToRoundedYears(t)
			return Math.Floor(ToYears(t))

		GetRoundedTime(t)
			var/outputText = "", list/timesteps = new
			timesteps["Year"] = ToRoundedYears(t)
			if(timesteps["Year"] >= 1)
				t -= FromYears(timesteps["Year"])
				outputText += " [timesteps["Year"]] Years"
				
			timesteps["Month"] = ToRoundedMonths(t)
			if(timesteps["Month"] >= 1)
				t -= FromMonths(timesteps["Month"])
				outputText += " [timesteps["Month"]] Months"
				
			timesteps["Week"] = ToRoundedMonths(t)
			if(timesteps["Week"] >= 1)
				t -= FromWeeks(timesteps["Week"])
				outputText += " [timesteps["Week"]] Weeks"
				
			timesteps["Day"] = ToRoundedDays(t)
			if(timesteps["Day"] >= 1)
				t -= FromDays(timesteps["Day"])
				outputText += " [timesteps["Day"]] Days"
				
			timesteps["Hour"] = ToRoundedHours(t)
			if(timesteps["Hour"] >= 1)
				t -= FromHours(timesteps["Hour"])
				outputText += " [timesteps["Hour"]] Hours"
				
			timesteps["Minute"] = ToRoundedMinutes(t)
			if(timesteps["Minute"] >= 1)
				t -= FromMinutes(timesteps["Minute"])
				outputText += " [timesteps["Minute"]] Minutes"
				
			timesteps["Second"] = ToRoundedSeconds(t)
			if(timesteps["Second"] >= 1)
				t -= FromSeconds(timesteps["Second"])
				outputText += " [timesteps["Second"]] Seconds"
			
			return outputText

		// Checks if the cooldown given has passed since saved timestamp in world time.
		CheckCooldownWorld(savedTime, cooldown)
			return world.time >= savedTime + cooldown

		// Subtracts a saved timestamp from world time and returns the value.
		GetTimeElapsedWorld(savedTime)
			return world.time - savedTime

		GetTimeRemainingWorld(savedTime, cooldown)
			return savedTime + cooldown - world.time

		// Checks if the cooldown given has passed since the saved timestamp in time since 00:00:00 GMT today.
		CheckCooldownGMT(savedTime, cooldown)
			return world.timeofday >= savedTime + cooldown

		// Subtracts a saved timestamp from world time and returns the value.
		GetTimeElapsedGMT(savedTime)
			return world.timeofday - savedTime

		GetTimeRemainingGMT(savedTime, cooldown)
			return savedTime + cooldown - world.timeofday

		// Checks if the cooldown given has passed since the saved timestamp in time since 00:00:00 GMT 1/1/2000.
		CheckCooldownGlobal(savedTime, cooldown)
			return world.realtime >= savedTime + cooldown

		// Subtracts a saved timestamp from world time and returns the value.
		GetTimeElapsedGlobal(savedTime)
			return world.realtime - savedTime

		GetTimeRemainingGlobal(savedTime, cooldown)
			return savedTime + cooldown - world.realtime

		// Checks if the cooldown given has passed since the saved timestamp.  Has optional parameter indicating which timebase to compare to.
		CheckCooldown(savedTime, cooldown, timebase = 0)
			if(timebase == 1) return CheckCooldownGMT(savedTime, cooldown)
			if(timebase == 2) return CheckCooldownGlobal(savedTime, cooldown)
			return CheckCooldownWorld(savedTime, cooldown)

		GetTimeElapsed(savedTime, timebase = 0)
			if(timebase == 1) return GetTimeElapsedGMT(savedTime)
			if(timebase == 2) return GetTimeElapsedGlobal(savedTime)
			return GetTimeElapsedWorld(savedTime)

		GetTimeRemaining(savedTime, cooldown, timebase = 0)
			if(timebase == 1) return GetTimeRemainingGMT(savedTime, cooldown)
			if(timebase == 2) return GetTimeRemainingGlobal(savedTime, cooldown)
			return GetTimeRemainingWorld(savedTime, cooldown)

		// Returns the current world.time value.
		RecordWorld()
			return world.time

		// Returns the current world.timeofday value.
		RecordGMT()
			return world.timeofday

		// Returns the current world.realtime value.
		RecordGlobal()
			return world.realtime

		// Returns the current time.  Has optional parameter indicating which timebase to record.
		Record(timebase = 0)
			if(timebase == 1) return RecordGMT()
			if(timebase == 2) return RecordGlobal()
			return RecordWorld()
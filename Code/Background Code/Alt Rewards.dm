var/alt_rewards = 0
var/alt_bp_reward = 1.25
var/alts_needed_for_bp_reward = 2
var/alt_res_reward = 100000

proc
	AltRewardsLoop()
		set waitfor=0
		if(!alt_rewards) return
		while(1)
			for(var/mob/m in players) m.AltResourceReward()
			sleep(600)

mob
	var
		tmp
			last_logon = 0 //world.time
	proc
		AltCount()
			if(!client) return 0
			var/count = 0
			for(var/client/c in clients)
				if(c != client && c.address == client.address) count++
			return count

		GetNewestAlt()
			if(!client) return
			var/mob/m2
			for(var/mob/m in players)
				if(m.client && m.client.address == client.address)
					if(m.last_logon > last_logon)
						m2 = m
			return m2

		AltResourceReward()
			set waitfor=0
			if(!client || !AltCount()) return
			var/mob/m = GetNewestAlt()
			if(!m) return
			bank_list[m.key] += alt_res_reward * Resource_Multiplier
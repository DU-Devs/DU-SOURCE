/*
this is a thing, that may be exclusively for good people, i dont really know, where if someone does certain things against you, you get a revenge buff
against them. for example if you are good and an evil person binds you, you can have a revenge buff against them for a certain period of time
*/

mob
	var
		list
			revengeList = new

	proc
		GetRevengeInfo(mob/m)
			if(!m || !m.key || !(m.ckey in revengeList)) return
			return revengeList[m.ckey]

		GetRevengeDmgMod(mob/m)
			if(!m || !m.client) return 1
			var/info = GetRevengeInfo(m)
			if(info)
				var/timeout = info["timeout"]
				if(world.realtime < timeout)
					var/mod = info["mod"]
					var/dmg = 1 + (0.3 * mod)
					return dmg
			return 1

		TryGiveRevengeAgainst(mob/m, effectMod = 1, timer = 12000)
			if(alignment_on && alignment != "Good") return //currently we reserve revenge system only for good people
			GiveRevengeAgainst(m, effectMod, timer)

		GiveRevengeAgainst(mob/m, effectMod = 1, timer = 12000)
			if(!m || !m.client) return
			var/info = GetRevengeInfo(m)
			if(!info)
				info = list("timeout" = 0, "mod" = 1)
			var/timeout = info["timeout"]
			var/mod = info["mod"]
			if(timeout < world.realtime + timer) timeout = world.realtime + timer
			if(mod < effectMod) mod = effectMod
			info["timeout"] = timeout
			info["mod"] = mod
			revengeList -= m.ckey
			revengeList.Insert(1, m.ckey)
			revengeList[m.ckey] = info
			if(revengeList.len > 7) revengeList.len = 7
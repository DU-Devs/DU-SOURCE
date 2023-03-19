var
	teach_time_mod = 0.5

obj/var
	Teach_Timer = 0.5
	Next_Teach = 0
	teachable
	race_teach_only
	student_point_cost = 0

mob/var
	next_knowledge_teach=0
	list
		student_points = new
		spent_student_points = new

mob/proc
	RaiseStudentPoints(mob/m, amount=0)
		if(!m || !m.client || !m.key) return
		if(m.Race in list("Human", "Puranto")) amount *= 1.5
		if(!(m.ckey in student_points))
			student_points += m.ckey //attempt to fix a weird bad index error
			student_points[m.ckey] = 0
		student_points[m.ckey] = student_points[m.ckey] + amount
		while(student_points.len > 35)
			student_points -= student_points[1]
			//student_points.len = 35
		while(spent_student_points.len > 50)
			spent_student_points -= spent_student_points[1]
			//spent_student_points.len = 50

	set_next_knowledge_teach(n=1)
		next_knowledge_teach = world.realtime + (1 * 60 * 60 * 10 * n)

	CanTeachGlobal(msg)
		if(body_swapped())
			if(msg) src<<"You can not teach while body swapped"
			return

		/*for(var/obj/Injuries/Brain/i in injury_list)
			if(msg) src << "You can not teach because you have a brain injury"
			return*/

		return 1

	CanTeachMob(mob/m, msg)
		if(!m)
			if(msg) src<<"There must be a player in front of you to teach"
			return

		/*for(var/obj/Injuries/Brain/i in m.injury_list)
			if(msg)
				src << "[m] has a brain injury and cannot learn anything now"
				m << "[src] tries to teach you but you have a brain injury so they can't"
			return*/

		if(alignment_on && m.alignment=="Evil" && alignment=="Good")
			if(msg) src<<"Good people can not teach evil people"
			return

		if(!(ckey in m.student_points))
			if(msg) src<<"[m] has no student points from you. To teach them you must train them."
			return

		return 1

	TeachProc()

		if(!next_knowledge_teach) set_next_knowledge_teach(1)

		if(!CanTeachGlobal(msg = 1)) return
		var/mob/m = locate(/mob) in Get_step(src,dir)
		if(!CanTeachMob(m, msg = 1)) return

		TeachMob(m)

	TeachMob(mob/m)

		while(m && client)

			if(!(ckey in m.student_points)) m.student_points[ckey] = 0
			if(!(ckey in m.spent_student_points)) m.spent_student_points[ckey] = 0

			var/list
				teachable = new
				unteachable = new

			if(Knowledge > m.Knowledge)
				if(world.realtime > next_knowledge_teach) teachable += "Knowledge of Technology"
				else
					var/hours = (next_knowledge_teach - world.realtime) / 10 / 60 / 60
					hours = round(hours, 0.01)
					unteachable += "Knowledge (Teach in [hours] hours)"

			for(var/obj/o in src) if(o.teachable && (o.Reteachable || !(locate(o.type) in m)))
				if(CanTeachSkillTo(m, o))
					if(m.HasEnoughStudentPointsFrom(o, src))
						teachable += o
					else
						unteachable += o

			if(!teachable.len && !unteachable.len)
				src<<"[m] knows every skill that you know"
				return

			if(!teachable.len)
				src<<"[m] needs more student points to learn from you"
				return

			var/list/l = new
			for(var/obj/v in teachable) l["[v] ([m.StudentPointCost(v)])"] = v
			if(unteachable.len)
				l += "SKILLS BELOW HERE REQUIRE MORE POINTS"
				for(var/obj/v in unteachable) l["[v] ([m.StudentPointCost(v)])"] = v
			l += "Cancel"

			var/points = 0
			if(ckey in m.student_points) points = m.student_points[ckey]
			var/obj/o = input(src, "Teach Skill. [m] has [points] student points.") in l

			if(o == "Cancel") return

			if(o && (l[o] in teachable))
				if(o == "Knowledge of Technology")
					if(m.Knowledge < Knowledge)
						player_view(15,src)<<"[src] has taught [m] their knowledge of technology"
						m.Knowledge = Knowledge
				else
					var/obj/s = l[o]
					if(!m.HasEnoughStudentPointsFrom(s, src)) return

					m.student_points[ckey] = m.student_points[ckey] - m.StudentPointCost(s)
					m.spent_student_points[ckey] = m.spent_student_points[ckey] + m.StudentPointCost(s)

					CheckStudentFeat(m)

					player_view(15,src) << "<font size=3><font color=[rgb(255,150,0)]>[src] has taught [m] the [s]"

					var/obj/s2
					if(s.type == /obj/Buff)
						Save_Obj(s)
						s2 = GetCachedObject(s.type)
						Load_Obj(s2)
						s2.suffix = null
					else s2 = GetCachedObject(s.type)

					s2.Taught=1
					if(istype(s2,/obj/Attacks)) s2.icon=s.icon

					m.contents += s2
					m.Restore_hotbar_from_IDs()

	HasEnoughStudentPointsFrom(obj/o, mob/teacher)
		if(!teacher.key) return
		if(!(teacher.ckey in student_points)) return
		var/points = student_points[teacher.ckey]
		if(points < StudentPointCost(o)) return
		return 1

	CanTeachSkillTo(mob/m, obj/o)
		if(!m) return
		if(o.type == /obj/Buff && m.Buff_count() >= max_buffs) return
		if(Race != m.Race && o.race_teach_only) return
		if(o.type == /obj/Teleport && m.Race != "Kai") return
		if(o.type == /obj/Demon_Contract && m.Race != "Demon") return
		if(o.type == /obj/Unlock_Potential && !RaceCanHaveUnlockPotential(m.Race)) return
		if(o.type == /obj/Attacks/Piercer && m.Race != "Puranto") return

		return 1

	StudentPointCost(obj/o)
		return o.student_point_cost * RaceSkillLearnDifficultyMod(o)

proc/RaceCanHaveUnlockPotential(r)
	if(r in list("Puranto", "Human")) return 1

mob/verb
	Teach()
		//set category = "Skills"
		TeachProc()

obj/proc/update_teach_timer()
	return
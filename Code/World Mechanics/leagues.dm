mob/verb/Create_League()
	set category="Other"
	var/obj/League/L=new(src)
	L.league_leader=key
	L.league_id="[name] [key] #[rand(0,999999)]"
	L.name=input(src,"Name the league") as text
	if(!L.name||L.name=="") L.name="League #[rand(0,999999)]"
	L.update_league()

var/list/all_leagues=new

proc/Same_league_cant_kill(mob/a,mob/b)
	for(var/obj/League/l in a.league_list)
		for(var/obj/League/l2 in b.league_list)
			if(l.league_id==l2.league_id && !l.can_harm_members) return 1

mob/proc/League_turret_IDs()
	var/list/IDs=new
	for(var/obj/League/L in league_list) IDs+=L.turret_id
	return IDs

mob/proc/Get_league_drone_IDs()
	var/list/IDs=new
	for(var/obj/League/L in league_list) IDs+=L.drone_id
	return IDs

mob/proc/Get_league_nully_IDs()
	var/list/IDs=new
	for(var/obj/League/L in league_list) IDs+=L.nully_id
	return IDs

obj/League
	icon='FactionBadge.dmi'
	can_blueprint=0
	Duplicates_Allowed=1
	clonable=0
	desc="In the tab that opened up you can see all the info for this league. Click the symbol in that tab \
	to view league options"
	New()
		all_leagues+=src
		spawn(10) if(src)
			var/mob/m=loc
			if(m&&ismob(m))
				m<<desc
				if(can_harm_members) m<<"Killing other league members is allowed for this league"
				else m<<"Killing other league members is NOT allowed for this league"
				m.league_list+=src
		league_update_loop()
	var
		league_leader
		league_id
		leaders_name
		league_rank=1
		turret_id
		drone_id
		nully_id
		tmp
			can_invite
			can_expel
			can_announce
			can_write_notes
			can_change_desc
			can_harm_members
		var/league_notes={"<html><head><title>league notes</title><body><body bgcolor="#000000"><font size=2><font color="#CCCCCC">

		Put text here<p>

		"}
	proc
		league_update_loop()
			set waitfor=0
			var/mob/m=loc
			if(!m||!ismob(m)||league_leader!=m.key) return
			while(src&&m&&league_leader==m.key)
				update_league()
				sleep(600)
		is_league_member(mob/m) for(var/obj/League/L in m.league_list) if(L.league_id==league_id) return L
		update_league()
			var/mob/m=loc
			if(!m||!ismob(m)) return
			if(league_leader==m.key)
				league_rank=7
				leaders_name=m.name
				for(var/mob/p in players) if(is_league_member(p))
					var/obj/League/L=is_league_member(p)
					L.league_leader=league_leader
					L.leaders_name=leaders_name
					L.desc=desc
					L.name=name
					L.league_notes=league_notes
					L.turret_id=turret_id
					L.drone_id=drone_id
					L.nully_id=nully_id
		league_announce(msg)
			for(var/mob/m in players) if(is_league_member(m)) m<<msg
	verb/league_chat(msg as text)
		set category="Other"
		msg=html_encode(msg)
		for(var/mob/m in players) if(is_league_member(m))
			m<<"<font size=[m.TextSize]>([name])<font color=[usr.TextColor]>[usr]: [msg]"
	Click() if(src in usr)
		var/list/options=list("cancel","leave league","read league notes","send resources")
		if(league_rank>=2) options+="invite someone"
		if(league_rank>=3) options+="expel someone"
		if(league_rank>=4) options+="league announce"
		if(league_rank>=5)
			options+="change login message"
			options+="promote / demote"
			options+="toggle harming of league members"
		if(league_rank>=6) options+="write league notes"
		if(league_rank>=7)
			options+="change leader"
			options+="Set turrets of a certain ID to not attack members"
			options+="Set drones of a certain ID to not attack members"
			options+="Set nullifiers of a certain ID to not block members"
		switch(input("choose an option") in options)
			if("cancel") return
			if("Set nullifiers of a certain ID to not block members")
				nully_id=input("Set this to the password of any nullifiers that you don't want to block members of this league") as text
			if("Set turrets of a certain ID to not attack members")
				turret_id=input("Set this to the password of any turrets that you don't want to attack members of this league") as text
			if("Set drones of a certain ID to not attack members")
				turret_id=input("Set this to the password of any drones that you don't want to attack members of this league") as text
			if("toggle harming of league members")
				can_harm_members=!can_harm_members
				if(can_harm_members) alert("League members can now harm each other (kill/steal/etc)")
				else alert("League members are now unable to harm each other (kill/steal/etc)")
			if("change leader")
				var/list/mobs=list("cancel")
				for(var/mob/m in players) if(is_league_member(m)) mobs+=m
				var/mob/m=input("choose the new leader. they will replace you as leader of the league") in mobs
				if(!m||m=="cancel") return
				var/obj/League/L=is_league_member(m)
				L.league_rank=7
				league_rank-=1
				league_announce("<font color=yellow>[name]: [usr] has made [m] the leader of the league")
				update_league()
			if("promote / demote")
				var/max=league_rank-1
				var/list/mobs=list("cancel")
				for(var/mob/m in players)
					var/obj/League/L=is_league_member(m)
					if(L&&L.league_rank<=max) mobs+=m
				var/mob/m=input("pick who to promote / demote") in mobs
				if(!m||m=="cancel"||!is_league_member(m)) return
				var/obj/League/L=is_league_member(m)
				var/new_rank=input(usr,"what rank do they have? 1 has is just a member. 2 can invite. 3 can expel. \
				4 can announce. 5 can change the league login message and promote/demote to lv4. 6 can write \
				league notes. 7 is the leader. there can be only 1 leader. you can promote up to \
				level [max].","options",L.league_rank) as num
				if(new_rank<1) new_rank=1
				if(new_rank>max) new_rank=max
				if(!m||!L) return
				league_announce("<font color=yellow>[name]: [m] was promoted/demoted from level [L.league_rank] \
				to [new_rank]")
				L.league_rank=new_rank
				update_league()
			if("send resources")
				if(usr.Health<100)
					usr<<"You can not do this while in a fight (reach full health first)"
					return
				if(usr.KO)
					usr<<"You can not do this while knocked out"
					return
				var/n=input("how much resources do you want to send?") as num
				if(n>usr.Res()) n=usr.Res()
				if(n<1)
					usr<<"You must send at least 1"
					return
				var/res_options=list("cancel","im done choosing","all online")
				for(var/mob/m in players) if(is_league_member(m)) res_options+=m
				var/list/mobs=new
				while(usr)
					var/mob/m=input("choose who you want to send [Commas(n)] resources to") in res_options
					mobs+=m
					res_options-=m
					switch(m)
						if("cancel") return
						if("im done choosing"||"all online") break
				if(usr.Res()<n)
					usr<<"Transaction cancelled because you do not have enough resources"
					return
				if(usr.KO)
					usr<<"You can not do this while knocked out"
					return
				if("all online" in mobs)
					for(var/mob/m in players)
						if(usr.Res()<n)
							usr<<"You do not have the resources to send [Commas(n)]$ to anyone else"
							return
						if(is_league_member(m))
							usr<<"[Commas(n)]$ sent to [m]"
							usr.Alter_Res(-n)
							m.Alter_Res(n)
							m<<"[name]: [usr] sent you [Commas(n)] resources"
				else for(var/mob/m in mobs)
					if(usr.Res()<n)
						usr<<"You do not have the resources to send [Commas(n)]$ to anyone else"
						return
					if(is_league_member(m))
						usr<<"[Commas(n)]$ sent to [m]"
						usr.Alter_Res(-n)
						m.Alter_Res(n)
						m<<"[name]: [usr] sent you [Commas(n)] resources"
			if("write league notes")
				league_notes=input("make the changes you want here","options",league_notes) as message
				league_announce("[name] league notes updated")
				update_league()
			if("read league notes")
				usr<<browse(league_notes,"window=[name]_league_notes;size=700x600")
			if("change login message")
				desc=input("change the login message to whatever you want","options",desc) as text
				update_league()
			if("leave league")
				league_announce("[usr.key] has left the [name] league")
				if(sagas&&villain_league_id&&league_id==villain_league_id)
					usr.left_villain_league_time=world.realtime
				del(src)
			if("invite someone")
				var/list/players=list("cancel")
				for(var/mob/m in Get_step(usr,usr.dir))
					if(m.client) players+=m
					if(istype(m, /mob/new_troll)) players += m
				if(players.len == 1)
					usr<<"There is no player in front of you to invite"
					return
				var/mob/m=input("who do you want to invite?") in players
				if(ismob(m)&&is_league_member(m))
					usr<<"[m] is already a member of this league"
					return
				if(ismob(m)&&m.ignore_leagues&&league_leader!=villain)
					usr<<"[m] is ignoring league invites"
					return
				if(m=="cancel"||!m) return

				if(istype(m, /mob/new_troll))
					var/mob/new_troll/nt = m
					nt.LeagueInviteTroll(usr, name)
					return

				var/t="[usr] has invited you to join the league called [name]. accept?"
				var/button3
				if(league_leader==villain)
					t="You have been invited to join the main villain's league, this will provide benefits to you such as \
					[Commas(Villain_league_paycheck_amount())] resources every [villain_paycheck_loop_timer] minutes \
					and possibly more (see Sagas/Alignment Guide). The more people the villain gets in the league the better \
					things become for those in the league, but the worse things become for those out of the league. Join?"
					button3="View Sagas Guide"

				while(m)
					switch(alert(m,t,"options","No","Yes",button3))
						if("No")
							usr<<"[m] has refused to join the [name]"
							return
						if("Yes")
							player_view(15,usr)<<"[m] has joined the [name]"
							var/obj/League/L=new(m)
							L.league_id=league_id
							update_league()
							return
						if("View Sagas Guide") m.Sagas_Guide()
			if("expel someone")
				var/list/leaguers=list("cancel")
				for(var/mob/m in players)
					var/obj/League/L=is_league_member(m)
					if(L&&L.league_rank<league_rank) leaguers+=m
				var/mob/m=input("who do you want to expel from the league? only people with ranks lower than \
				yours can be expelled.") in leaguers
				if(!m||m=="cancel") return
				league_announce("[m] has been expelled from the [name] by [usr]")

				if(sagas&&villain_league_id&&league_id==villain_league_id)
					m.left_villain_league_time=world.realtime

				var/obj/League/L=is_league_member(m)
				del(L)
			if("league announce")
				var/msg=input("what do you want to announce to the league?") as text
				msg="<font size=2><font color=yellow>[name] announcement: [msg] ~[usr.name]"
				league_announce(msg)
/*
add league chat
*/
mob/verb/Form_League()
	set category="Other"
	var/obj/League/L=new(src)
	L.league_leader=key
	L.league_id="[name] [key] #[rand(0,999999)]"
	L.name=input(src,"Name the league") as text
	if(!L.name||L.name=="") L.name="League #[rand(0,999999)]"
	L.update_league()
obj/League
	icon='FactionBadge.dmi'
	Blueprintable=0
	clonable=0
	desc="In the tab that opened up you can see all the info for this league. Click the symbol in that tab \
	to view league options"
	New()
		spawn(10) if(src)
			var/mob/m=loc
			if(m&&ismob(m)) m<<desc
		league_update_loop()
	var
		league_leader
		league_id
		leaders_name
		league_rank=1
		tmp
			can_invite
			can_expel
			can_announce
			can_write_notes
			can_change_desc
		var/league_notes={"<html><head><title>league notes</title><body><body bgcolor="#000000"><font size=2><font color="#CCCCCC">

		Put text here<p>

		"}
	proc
		league_update_loop() spawn if(src)
			var/mob/m=loc
			if(!m||!ismob(m)||league_leader!=m.key) return
			while(src&&league_leader==m.key)
				update_league()
				sleep(600)
		is_league_member(mob/m) for(var/obj/League/L in m) if(L.league_id==league_id) return L
		update_league()
			var/mob/m=loc
			if(!m||!ismob(m)) return
			if(league_leader==m.key)
				league_rank=7
				leaders_name=m.name
				for(var/mob/p in Players) if(is_league_member(p))
					var/obj/League/L=is_league_member(p)
					L.league_leader=league_leader
					L.leaders_name=leaders_name
					L.desc=desc
					L.name=name
					L.league_notes=league_notes
		league_announce(msg)
			for(var/mob/m in Players) if(is_league_member(m)) m<<msg
	verb/league_chat(msg as text)
		set category="Other"
		msg=html_encode(msg)
		for(var/mob/m in Players) if(is_league_member(m))
			m<<"<font size=[m.TextSize]>([name])<font color=[usr.TextColor]>[usr]: [msg]"
	Click() if(src in usr)
		var/list/options=list("cancel","leave league","read league notes","send resources")
		if(league_rank>=2) options+="invite someone"
		if(league_rank>=3) options+="expel someone"
		if(league_rank>=4) options+="league announce"
		if(league_rank>=5)
			options+="change login message"
			options+="promote / demote"
		if(league_rank>=6) options+="write league notes"
		if(league_rank>=7) options+="change leader"
		switch(input("choose an option") in options)
			if("cancel") return
			if("change leader")
				var/list/mobs=list("cancel")
				for(var/mob/m in Players) if(is_league_member(m)) mobs+=m
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
				for(var/mob/m in Players)
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
				if(usr.KO)
					usr<<"You can not do this while knocked out"
					return
				var/n=input("how much resources do you want to send?") as num
				if(n>usr.Res()) n=usr.Res()
				if(n<1)
					usr<<"You must send at least 1"
					return
				var/res_options=list("cancel","im done choosing","all online")
				for(var/mob/m in Players) if(is_league_member(m)) res_options+=m
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
					for(var/mob/m in Players)
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
				del(src)
			if("invite someone")
				var/list/players=list("cancel")
				for(var/mob/m in get_step(usr,usr.dir)) if(m.client) players+=m
				if(players.len==1)
					usr<<"There is no player in front of you to invite"
					return
				var/mob/m=input("who do you want to invite?") in players
				if(ismob(m)&&is_league_member(m))
					usr<<"[m] is already a member of this league"
					return
				if(ismob(m)&&m.ignore_leagues)
					usr<<"[m] is ignoring league invites"
					return
				if(m=="cancel"||!m) return
				switch(alert(m,"[usr] has invited you to join the league called [name]. accept?","options","no","yes"))
					if("no")
						usr<<"[m] has refused to join the [name]"
						return
					if("yes")
						view(usr)<<"[m] has joined the [name]"
						var/obj/League/L=new(m)
						L.league_id=league_id
						update_league()
			if("expel someone")
				var/list/players=list("cancel")
				for(var/mob/m in Players)
					var/obj/League/L=is_league_member(m)
					if(L&&L.league_rank<league_rank) players+=m
				var/mob/m=input("who do you want to expel from the league? only people with ranks lower than \
				yours can be expelled.") in players
				if(!m||m=="cancel") return
				league_announce("[m] has been expelled from the [name] by [usr]")
				var/obj/League/L=is_league_member(m)
				del(L)
			if("league announce")
				var/msg=input("what do you want to announce to the league?") as text
				msg="<font size=2><font color=yellow>[name] announcement: [msg] ~[usr.name]"
				league_announce(msg)
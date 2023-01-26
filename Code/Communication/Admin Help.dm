ticket
	var
		id
		name
		desc
		details
		status = "Open"
		creator
		list/tags = new
		list/timestamps = new
		list/responses = new
	
	proc
		Initialize(_name, _desc, _details, _creator)
			src.id = GetBase64ID()
			src.name = _name
			src.desc = _desc
			src.details = _details
			src.creator = _creator
			if(!tags) tags = new/list
			if(!timestamps) timestamps = new/list
			if(!responses) responses = new/list
			AddTimestamp("[creator] created ticket.")
		
		AddResponse(_user, _text)
			if(!_text || !_user) return
			responses[_text] = list(_user, "[world.realtime]")
			AddTimestamp("[_user] added response \[[_text]\].")
		
		GetResponse(index)
			if(!index || index > responses.len) return
			var/text = responses[index]
			var/user = responses[text][1]
			var/timestamp = responses[text][2]
			return list(user, text, timestamp)
		
		AddTag(_user, tag)
			if(!_user || !tag) return
			tags += tag
			AddTimestamp("[_user] added tag '[tag]'.")
		
		RemoveTag(_user, tag)
			if(!_user || !tag) return
			tags -= tag
			AddTimestamp("[_user] removed tag '[tag]'.")
		
		ModifyDetails(_user, _text)
			if(!_user || !_text) return
			AddTimestamp("[_user] edited details \[[details]\] to \[[_text]\].")
			src.details = _text
		
		SetStatus(_user, _status)
			if(!_user || !_status) return
			src.status = _status
			AddTimestamp("[_user] set status '[status]'")
		
		AddTimestamp(text = "[creator] modified ticket.")
			timestamps["[world.realtime]"] = text
		
		GetTimestampByText(_text)
		 if(!_text) return
		
		GetChangelog()
			var/text = "<h1>Changelog</h1>"
			for(var/i in timestamps)
				var/action = timestamps[i]
				text += "([time2text(text2num(i), "hh:mm:ss DD MMM YYYY")]) -> [action]<hr>"
			return text
		
		GetTimestampByID(_id)
			if(!_id || !timestamps[_id]) return
			return timestamps[_id]
		
		ReadableTimestamp(_id)
			if(!_id) return
			var/timestamp = text2num(GetTimestampByID(_id))
			return time2text(timestamp, "YYYY MMM DD \[hh:mm\]")

var/list/tickets = new
var/list/ticketFilter = list("tag", "type", "parent_type", "vars")
var/list/AllTags = list("Enforcement", "Roleplay", "Event", "Suggestion", "Bug", "Other")

proc/DisplayTickets(mob/M)
	if(!M || !M.client) return
	var/html = "<html><head>[KHU_HTML_HEADER]<title>Tickets</title>"
	html += "<style>table{font-family: arial, sans-serif; border-collapse: collapse; width: 100%;}"
	html += "td,th{border: 1px solid #dddddd; text-align: left; padding: 8px;}"
	html += "tr:nth-child(even){background-color: #575757;}</style>"
	html += "</head><body bgcolor=#000000 text=#339999 link=#99FFFF>"
	html += "<table>"
	html += "<tr><th>Name</th><th>Description</th><th>Creator</th><th>Status</th><th>Date Opened</th></tr>"
	for(var/ticket/t in tickets)
		if((M.key != t.creator && !M.IsAdmin()) || t.status == "Closed") continue
		html += "<tr><td><a href=byond://?src=\ref[t]&action=view>[t.name]</a></td>"
		html += "<td>[copytext(t.desc,1,20)]</td><td>[t.creator]</td><td>[t.status]</td><td>[t.ReadableTimestamp(1)]</td></tr>"
	for(var/ticket/t in tickets)
		if((M.key != t.creator && !M.IsAdmin()) || t.status == "Open") continue
		html += "<tr><td><a href=byond://?src=\ref[t]&action=view>[t.name]</a></td>"
		html += "<td>[copytext(t.desc,1,20)]</td><td>[t.creator]</td><td>[t.status]</td><td>[t.ReadableTimestamp(1)]</td></tr>"
	html += "</table></body></html>"
	if(!M.savedBrowserPos["Tickets"]) M.savedBrowserPos["Tickets"] = "0x0"
	if(!M.savedBrowserSize["Tickets"]) M.savedBrowserSize["Tickets"] = "480x1024"
	M << browse(html, "window=Tickets;pos=[M.savedBrowserPos["Tickets"]];size=[M.savedBrowserSize["Tickets"]];can_close=1")
	winset(M, "Tickets", "on-close='save-pos \"Tickets\"'")

mob/Admin4/verb/Manage_Tickets()
	set category = "Admin"
	DisplayTickets(src)

ticket/Topic(href, hrefs[])
	. = ..()
	if(hrefs["action"] == "view")
		ViewTicket(usr)
	if(hrefs["action"] == "submit")
		Initialize(hrefs["tname"],hrefs["tdesc"],hrefs["tdetails"],usr.key)
		usr << browse(null, "window=Tickets")
		ViewTicket(usr)
	if(hrefs["action"] == "delete")
		switch(alert(usr, "Are you sure?","Delete Ticket", "Yes", "No"))
			if("No") return
		tickets -= src
		usr << browse(null, "window=Tickets")
		del(src)
	if(hrefs["action"] == "respond")
		var/response = input(usr, "What would you like to say?", "Respond to Ticket") as text|null
		if(!response) return
		AddResponse(usr.key, response)
		ViewTicket(usr)
	if(hrefs["action"] == "open")
		switch(alert(usr, "Really reopen this ticket?",,"Yes","No"))
			if("No") return
		SetStatus(usr.key, "Open")
		ViewTicket(usr)
	if(hrefs["action"] == "close")
		switch(alert(usr, "Really close this ticket?",,"Yes","No"))
			if("No") return
		SetStatus(usr.key, "Closed")
		ViewTicket(usr)
	if(hrefs["action"] == "log")
		ViewLog(usr)
	if(hrefs["action"] == "tag")
		while(1)
			switch(alert(usr, "What do you need to do?", "Edit Tags", "Cancel", "Add", "Remove"))
				if("Cancel") break
				if("Remove")
					while(1)
						var/tag = input(usr, "Remove which tag?") in list("Cancel") + tags
						if(!tag || tag == "Cancel") break
						RemoveTag(usr.key, tag)
				if("Add")
					while(1)
						var/tag = input(usr, "Add which tag?") in list("Cancel") + (AllTags - tags)
						if(!tag || tag == "Cancel") break
						AddTag(usr.key, tag)
			ViewTicket(usr)

ticket/proc/ViewLog(mob/M)
	if(!M || !M.client || !M.IsAdmin()) return
	M << browse(null, "window=[src.name]")
	var/html = "<html><head>[KHU_HTML_HEADER]<title>Ticket Changelog</title></head><body bgcolor=#000000 text=#339999 link=#99FFFF>"
	html += GetChangelog()
	html += "<a href=byond://?src=\ref[src]&action=view>\[Return\]</a>"
	html += "</body></html>"

ticket/proc/ViewTicket(mob/M)
	if(!M || !M.client || (M.key != creator && !M.IsAdmin())) return
	M << browse(null, "window=[src.name]")
	var/html = "<html><head>[KHU_HTML_HEADER]<title>View Ticket</title></head><body bgcolor=#000000 text=#339999 link=#99FFFF>"
	if(tags.len)
		html += "<p>"
		for(var/i in tags) html += "\[[i]\]"
		html += "</p>"
	html += "<p>Name: [name]</p>"
	html += "<p>Description: [desc]</p><hr>"
	html += "<p>[details]</p><hr>"
	for(var/i = 1, i <= responses.len, i++)
		var/list/response = GetResponse(i)
		html+= "<p>[response[1]] -- [time2text(text2num(response[3]))]:</p><p>[response[2]]</p><hr>"
	if(M.IsAdmin())
		html += "<a href=byond://?src=\ref[src]&action=tag>\[Edit Tags\]</a> | "
		if(src.status != "Closed") html += "<a href=byond://?src=\ref[src]&action=close>\[Close Ticket\]</a> | "
		if(src.status != "Open") html += "<a href=byond://?src=\ref[src]&action=open>\[Reopen Ticket\]</a> | "
		html += "<a href=byond://?src=\ref[src]&action=log>\[View Changelog\]</a> | "
	html += "<a href=byond://?src=\ref[src]&action=respond&val=[M.key]>\[Add Response\]</a> | "
	html += "</body></html>"
	if(!M.savedBrowserPos["Tickets"]) M.savedBrowserPos["Tickets"] = "0x0"
	if(!M.savedBrowserSize["Tickets"]) M.savedBrowserSize["Tickets"] = "480x1024"
	M << browse(html, "window=Tickets;pos=[M.savedBrowserPos["Tickets"]];size=[M.savedBrowserSize["Tickets"]];can_close=1")
	winset(M, "Tickets", "on-close='save-pos \"Tickets\"'")

mob/verb/Admin_Help()
	set category = "Other"
	switch(input("What do you need?") in list("Cancel", "New Ticket", "View My Tickets"))
		if("New Ticket") CreateTicket()
		if("View My Tickets") DisplayTickets(src)

mob/proc/CreateTicket()
	if(!src || !src.client) return
	var/ticket/t = new
	tickets += t
	src << browse(null, "window=Tickets")
	var/html = "<html><head>[KHU_HTML_HEADER]<title>New Ticket</title></head><body bgcolor=#000000 text=#339999 link=#99FFFF>"
	html += "<a href=byond://?\ref[t]&action=delete>\[Cancel\]</a>"
	html += "<h1>Enter all relevant information about the issue you're having.</h1>"
	html += "<form action='byond://'>"
	html += "<input type='hidden' name='src' value='\ref[t]' />"
	html += "<input type='hidden' name='action' value='submit' />"
	html += "<label for='tname'>Title</label><br>"
	html += "<input type='text' id='tname' name='tname'><br><br>"
	html += "<label for='tdesc'>Short Description</label><br>"
	html += "<input type='text' id='tdesc' name='tdesc'><br><br>"
	html += "<label for='tdetails'>Full Details</label><br>"
	html += "<textarea id='tdetails' name='tdetails' rows='4' cols='30'></textarea><br><br>"
	html += "<input type='submit' value='Submit'>"
	html += "</form>"
	html += "</body></html>"
	if(!savedBrowserPos["Tickets"]) savedBrowserPos["Tickets"] = "0x0"
	if(!savedBrowserSize["Tickets"]) savedBrowserSize["Tickets"] = "480x1024"
	src << browse(html, "window=Tickets;pos=[savedBrowserPos["Tickets"]];size=[savedBrowserSize["Tickets"]];can_close=0")
	winset(src, "Tickets", "on-close='save-pos \"Tickets\"'")
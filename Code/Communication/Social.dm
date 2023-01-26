profile
	var
		owner
		icon/picture
		desc
		css = defaultCSS
	
	proc
		ViewProfile(mob/M)
			if(!M || !M.client) return
			M << browse(null, "window=Profile")
			var/html = "<html><head>[KHU_HTML_HEADER]<title>View Profile</title>"
			html += "<style>[css]</style>"
			html += "</head><body>"
			if(picture)
				html += "<p><img class='face' style='width: 350px; height: 500px;' src='[owner].png'><p>"
				M << browse_rsc(icon(picture), "[owner].png")
			html += "<p class='name'>Name: [GetOwnerName()]</p>"
			html += "<p class='age'>Age: [GetOwnerAge()]</p>"
			if(M.IsAdmin() || M.key == owner || M.CanSenseRace())
				html += "<p class='race'>Race: [GetOwnerClass() ? GetOwnerClass() : GetOwnerRace()]</p>"
			if(desc) html += "<p class='desc'>Description:<br><pre>[desc]</pre></p>"
			if(M.IsAdmin() || M.key == owner || M.CanSenseStats())
				html += "<br><hr><h1>Stats</h1>"
				html += "<table class='stats'>"
				var/list/ownerStats = GetOwnerStats()
				for(var/statName in ownerStats)
					html += "<tr><td>[statName]</td><td>[ownerStats[statName]]</td></tr>"
				var/list/ownerTraits = GetOwnerTraits()
				for(var/traitName in ownerTraits)
					html += "<tr><td>[traitName]</td><td>[ownerTraits[traitName]]</td></tr>"
				html += "</table>"
			if(M.key == owner || M.IsAdmin())
				html += "<br><hr><a href=byond://?\ref[src]&action=edit><button type=button>Edit</button></a>"
			html += "</body></html>"
			if(!M.savedBrowserPos["Profile"]) M.savedBrowserPos["Profile"] = "0x0"
			if(!M.savedBrowserSize["Profile"]) M.savedBrowserSize["Profile"] = "480x1024"
			M << browse(html, "window=Profile;pos=[M.savedBrowserPos["Profile"]];size=[M.savedBrowserSize["Profile"]];can_close=1")
			winset(M, "Profile", "on-close='save-pos \"Profile\"'")

		EditProfile(mob/M)
			if(!M || !M.client || (M.key != owner && !M.IsAdmin())) return
			M << browse(null, "window=Profile")
			var/html = "<html><head>[KHU_HTML_HEADER]<title>Edit Profile</title>"
			html += "<style>[css]</style>"
			html += "</head><body>"
			html += "<a href=byond://?\ref[src]&action=view>\[Cancel\]</a>"
			if(picture)
				html += "<p><img class='face' style='width: 350px; height: 500px;' src='[owner].png'><p>"
				M << browse_rsc(icon(picture), "[owner].png")
			html += "<p><a href=byond://?\ref[src]&action=image><button type='button'>Choose Image</button></a></p>"
			html += "<p class='name'>Name: [GetOwnerName()]</p>"
			html += "<p class='age'>Age: [GetOwnerAge()]</p>"
			html += "<form action='byond://'>"
			html += "<input type='hidden' name='src' value='\ref[src]' />"
			html += "<input type='hidden' name='action' value='submit' />"
			html += "<label for='desc'>Character Description</label><br>"
			html += "<textarea id='desc' name='desc' rows='20' cols='40'>[desc]</textarea><br><br>"
			html += "<input type='submit' value='Submit'>"
			html += "</form>"
			html += "</body></html>"
			if(!M.savedBrowserPos["Profile"]) M.savedBrowserPos["Profile"] = "0x0"
			if(!M.savedBrowserSize["Profile"]) M.savedBrowserSize["Profile"] = "480x1024"
			M << browse(html, "window=Profile;pos=[M.savedBrowserPos["Profile"]];size=[M.savedBrowserSize["Profile"]];can_close=0")
			winset(M, "Profile", "on-close='save-pos \"Profile\"'")
		
		SetDescription(_desc)
			desc = html_encode(_desc)
		
		SetImage()
			var/icon/F = input("Choose an image. Must be a jpg, jpeg, or png.") as null|icon
			if(!F)
				switch(alert("No image selected.  Clear current image?",,"No", "Yes"))
					if("Yes") picture = null
				return
			for(var/ext in ImageFiles)
				if(findlasttext("[F]", ext, 0, -length(ext)))
					picture = F
					break
				else
		
		GetOwnerName()
			. = "n/a"
			if(!owner) return
			for(var/mob/M in players)
				if(M.key && M.key == owner)
					return M.name
		
		GetOwnerAge()
			. = "n/a"
			if(!owner) return
			for(var/mob/M in players)
				if(M.key && M.key == owner)
					return Math.Floor(M.Age)
		
		GetOwnerRace()
			. = "n/a"
			if(!owner) return
			for(var/mob/M in players)
				if(M.key && M.key == owner)
					return M.Race
		
		GetOwnerClass()
			. = "n/a"
			if(!owner) return
			for(var/mob/M in players)
				if(M.key && M.key == owner)
					var/outText
					switch(M.Class)
						if("Spirit Doll") outText = M.Class
						if("Elite") outText = "[M.Class] [M.Race]"
						if("Low Class") outText = "[M.Class] [M.Race]"
						if("Legendary") outText = "[M.Class] [M.Race]"
						if("Cyborg") outText = "[M.Race] [M.Class]"
					return outText
		
		GetOwnerStats()
			. = new/list
			if(!owner) return
			for(var/mob/M in players)
				if(M.key && M.key == owner)
					return list("Battle Power" = Commas(Scouter_Reading(M)), "Power Tier" = M.effectiveBPTier,\
								"Health" = "[M.Health] / 100", "Energy" = "[Math.Floor(M.Ki)]/[Math.Floor(M.max_ki)] (x[M.Eff])",\
								"Determination" = "[Math.Floor(M.determination)] / [Math.Floor(M.GetMaxDetermination())]",\
								"Strength" = "[M.Str] ([M.GetReadableStatMod("Str")])",\
								"Durability" = "[M.End] ([M.GetReadableStatMod("Dur")])", "Speed" = "[M.Spd] ([M.GetReadableStatMod("Spd")])",\
								"Force" = "[M.Pow] ([M.GetReadableStatMod("For")])", "Resistance" = "[M.Res] ([M.GetReadableStatMod("Res")])",\
								"Accuracy" = "[M.Off] ([M.GetReadableStatMod("Acc")])",	"Reflex" = "[M.Def] ([M.GetReadableStatMod("Ref")])",\
								"Regeneration" = M.regen, "Recovery" = M.recov,\
								"Gravity Mastered" = "[Math.Round(M.gravity_mastered,0.01)]x", "Scientific Knowledge" = M.KnowledgeRating())
		
		GetOwnerTraits()
			. = new/list
			var/list/L = new/list
			if(!owner) return
			for(var/mob/M in players)
				if(M.key && M.key == owner)
					for(var/t in M.traits)
						var/trait/T = M.traits[t]
						if(!T) continue
						if(M.HasTrait(t))
							L[t] = "(Rank: [T.rank]/[T.maxRank]) | [T.desc]"
					return L
					
	
	Topic(href, hrefs[])
		. = ..()
		if(hrefs["action"] == "view")
			ViewProfile(usr)
		if(hrefs["action"] == "edit")
			EditProfile(usr)
		if(hrefs["action"] == "submit")
			SetDescription(hrefs["desc"])
			ViewProfile(usr)
		if(hrefs["action"] == "image")
			SetImage(usr)
			ViewProfile(usr)

var/list/ImageFiles = list(".jpg", ".jpeg", ".png")

mob/verb/View_Character(mob/M in players)
	set category = "Other"
	M.ViewProfile(src)

mob/var/profile/charProfile = new()

mob/proc/AssignProfile()
	if(!key || charProfile.owner) return
	charProfile.owner = key

mob/var
	savedProfilePos = "0x0"
	savedProfileSize = "480x1024"
	savedRankPos = "0x0"
	savedRankSize = "480x1024"

mob/var/list/savedBrowserPos = new
mob/var/list/savedBrowserSize = new

mob/verb/Save_Pos(window as text)
	set hidden = TRUE
	var/list/P = params2list(winget(usr, "[window]", "pos;size"))
	savedBrowserPos["[window]"] = P[P[1]]
	savedBrowserSize["[window]"] = P[P[2]]

mob/proc/ViewProfile(mob/M)
	AssignProfile()
	charProfile.ViewProfile(M)

mob/proc/CanSenseRace()
	if(!sense2_obj)
		sense2_obj = locate(/obj/Skills/Utility/Sense/Level2) in src
	if(sense2_obj)
		return 1

mob/proc/CanSenseStats()
	if(!sense3_obj)
		sense3_obj = locate(/obj/Skills/Utility/Sense/Level3) in src
	if(sense3_obj)
		return 1

mob/Admin3/verb/Reset_Player_Profile(mob/M in players)
	if(M && M.charProfile && M.key)
		M.charProfile = new
		M.AssignProfile()

var/const/defaultCSS = \
{"
body{
	background-color: #000000;
	color: #339999;
}
a:link{
	color: #99FFFF;
}
p{
	font-size: 14pt;
}
p.desc{
	width: 60%;
}
h1{
	text-align: center;
}
table{
	font-family: arial, sans-serif;
	border-collapse: collapse;
	width: 90%;
	margin-left: auto;
	margin-right: auto;
}
td,th{
	text-align: left;
	padding: 8px;
	border-left: 1px solid #247373;
}
tr{
	border: 3px solid #247373;
	padding: 2px;
}
"}
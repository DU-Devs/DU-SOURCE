proc/isboolean(test as num)
	if(test==0) return 1
	if(test==1) return 1
	if(test!=1&&test!=0) return 0

upForm/global_css = " body, table { font-family: Verdana; font-size: 10pt } "

var/upForm/playerlist

proc/Debug(m as mob,t)
	#ifdef DEBUG
	m << t
	#else
	return 0
	#endif


mob/proc
	ServerSettings()
		upForm(src.client, src, /upForm/admin_panel)

mob/Admin4/verb/Server_Control_Panel()
	set category = "Admin"
	set name = "Server Control Panel"
	src.ServerSettings()

mob/Admin5/verb/Test_Creation()
	set category = "Yeet"
	set name = "Test Creation Process"
	src.EditInfo()


upForm
	viewinfo
		window_title = "Player Info"
		window_size = "300x220"
		window_params = UPFORM_CANNOT_RESIZE
		form_type = UPFORM_WINDOW
		page_css = "body { background-color: #d0d0d0 }"

		Link(list/href_list, client/C)
			var/action = href_list["action"]
			switch(action)
				if("close")
					del(src)

		canDisplayForm(client/C)
			. = ..()
			if(C.upForm_isViewingForm(src.type))
				. = 0

		PreSettings()
			var/mob/M = src.getHost()
			window_title = "Player Info: [M.key]"

		GenerateBody()
			var/client/C = src.getOwner()
			var/mob/M = src.getHost()
			LoadResource(icon(M.icon, "face"), "face.png")

			var/page = {"
			<table width="100%" height="100%" border="0">
			<tr height="10px"><td colspan="2">
			  <table width="100%" height="100%" border="0">
			  <tr>
			    <td width="60%"><b>[M.name]</b></td>
			    <td width="40%" align="right">
			      [C.mob == M ? {"<a href="byond://?src=\ref[src]&action=edit">\[Edit\]</a>"} : ""]
			      <a href="byond://?src=\ref[src]&action=close">\[Close\]</a>
			    </td>
			  </tr>
			  </table>
			</tr></td>
			<tr valign="top" height="32px">
			  <td width="64px" align="center" valign="center">
			    <img src="face.png" width="32px" height="32px" />
			  </td>
			  <td>
			    <b>Key:</b>    [M.key] <br />
			    <b>Age:</b>    [M.Age] <br />
			    <b>Gender:</b> [M.gender]
			  </td>
			</tr>
			<tr valign="top">
			  <td colspan="2">
			  	<hr />
			    <b>User Description:</b> <br />
			    [M.desc]
			  </td>
			</tr>
			</table>
			"}

			UpdatePage(page)

	creation
		window_title = "Creation"
		window_size = "700x600"
		settings = UPFORM_SET_HANDLE_FORMS
		form_type = UPFORM_WINDOW
		page_css = {"
			body { background-color: #d0d0d0 }
			.form { width: 100% }
			span.error { color: #ff0000; font-size: 10pt }
		"}

		Link(list/href_list)
			if(href_list["action"] == "close")
				del(src)

		canDisplayForm(client/C)
			. = ..()
			if(C.upForm_isViewingForm(src.type))
				. = 0

		FormInitTempVars()
			var/mob/M = src.getHost()
			initFormVar("info", "decline", M.Decline)
			initFormVar("info", "name", M.name)
			initFormVar("info", "age", M.Age)
			initFormVar("info", "gender", M.gender)
			initFormVar("info", "desc", M.desc)

		FormSetTempVars(fname)
			var/mob/M = src.getHost()
			if(fname == "info")
				M.name = getFormVar("info", "name")
				M.Age = getFormVar("info", "age")
				M.gender = getFormVar("info", "gender")
				M.desc = getFormVar("info", "desc")

		ProcessVariable(fname, name, value)
			if(fname == "info")
				switch(name)
					if("name")
						setFormVar(fname, name, value)
						if(length(value) > 25 || length(value) < 3)
							return "Invalid name size"
					if("age")
						var/num = text2num(value)
						setFormVar(fname, name, num)
						if(num <= 0 || num > 99 || round(num) != num)
							return "Invalid age"
					if("gender")
						setFormVar(fname, name, value)
						if(value != "male" && value != "female")
							return "Invalid gender"
					if("desc")
						setFormVar(fname, name, value)
						if(length(value) > 300)
							return "Description too long"

			return null

		FormSubmitSuccess(fname, client/C)
			if(fname == "info")
				var/mob/M = src.getHost()
				M.name = html_encode(getFormVar("info","name"))
				del(src)

		GenerateBody(list/errors=list())
			var/page = {"
			<form name="info" action="byond://" method="get">
			  <input type="hidden" name="src" value="\ref[src]" />
			  <input type="hidden" name="form" value="info" />

			  <table width="100%" height="100%" border="0">
			  <tr height="12px"><td colspan="4">
			    <table width="100%" height="100%" border="0">
			    <tr>
			      <td width="60%"><b>Edit Info</b></td>
			      <td width="40%" align="right">
			        <a href="byond://?src=\ref[src]&action=close">\[Close\]</a>
			      </td>
			    </tr>
			    <tr><td colspan="2"><hr /></td></tr>
			    </table>
			  </tr></td>
			  <tr height="1em" valign="top">
			    <td width="20%"> <b>Name:</b> </td>
			    <td width="80%" colspan="3">
			      <input class="form" type="text" name="name"
			       value="[getFormVar("info","name")]" size="30" maxlength="25" />
			      <span class="error">[errors["name"]]</span>
			    </td>
			  </tr>
			  <tr height="1em" valign="top">
			    <td width="20%"> <b>Age: (Decline: [getFormVar("info","decline")]) </b> </td>
			    <td width="30%">
			      <input class="form" type="text" name="age"
			       value="[getFormVar("info","age")]" size="5" maxlength="2" />
			      <span class="error">[errors["age"]]</span>
			    </td>
			    <td width="20%"> <b>Gender:</b> </td>
			    <td width="30%">
			      <select class="form" name="gender">
			        <option[getFormVar("info","gender") == "male" ? " selected" : ""]
			         value="male"> Male </option>
			        <option[getFormVar("info","gender") == "female" ? " selected" : ""]
			         value="female"> Female </option>
			      </select>
			      <span class="error">[errors["gender"]]</span>
			    </td>
			  </tr>
			  <tr valign="top">
			    <td colspan="4">
			      <b>Description:</b> (up to 300 characters) <br />
			      <textarea class="form" name="desc"
			       rows="5" cols="30">[getFormVar("info","desc")]</textarea>
			      <span class="error">[errors["desc"]]</span>
			    </td>
			  </tr>
			  <tr height="1em">
			  	<td colspan="4" align="right"> <input type="submit" value="Submit" />
			  	<input type="reset" value="Reset" /> </td>
			  </tr>
			  </table>
			</form>
			"}

			UpdatePage(page)

	admin_panel
		window_title = "Admin Panel"
		window_size = "700x600"
		settings = UPFORM_SET_HANDLE_FORMS
		form_type = UPFORM_WINDOW
		page_css = {"
			body { background-color: #d0d0d0 }
			.tr.
			.form { width: 100% }
			span.error { color: #ff0000; font-size: 10pt }
		"}

		Link(list/href_list, client/C)
			var/mob/M = src.getHost()
			var/action = href_list["action"]
			switch(action)
				if("close")
					del(src)
				if("gains")
					if(C.mob == M)
						if(upForm(C, C.mob, /upForm/admin_gains))
							del(src)
				if("world")
					if(C.mob == M)
						if(upForm(C, C.mob, /upForm/admin_world))
							del(src)
				if("battlegrounds")
					if(C.mob == M)
						if(upForm(C, C.mob, /upForm/admin_battlegrounds))
							del(src)
				if("races")
					if(C.mob == M)
						if(upForm(C, C.mob, /upForm/admin_races))
							del(src)
				if("combat")
					if(C.mob == M)
						if(upForm(C, C.mob, /upForm/admin_combat))
							del(src)
				if("science")
					if(C.mob == M)
						if(upForm(C, C.mob, /upForm/admin_science))
							del(src)

		canDisplayForm(client/C)
			. = ..()
			if(C.upForm_isViewingForm(src.type))
				. = 0


		GenerateBody(list/errors=list())
			var/mob/M = src.getHost()
			if(errors.len>1)
				for(var/A in errors)
					M << "Error: [A]"
			var/page = {"
			<table width="100%" height="100%" border="0">
			<h1><a href="byond://?src=\ref[src]&action=gains">\[Gains & Progression\]</a></h1>
			<h1><a href="byond://?src=\ref[src]&action=world">\[World Settings\]</a></h1>
			<h1><a href="byond://?src=\ref[src]&action=battlegrounds">\[Battlegrounds\]</a></h1>
			<h1><a href="byond://?src=\ref[src]&action=races">\[Race Settings\]</a></h1>
			<h1><a href="byond://?src=\ref[src]&action=combat">\[Combat & Skills\]</a></h1>
			<h1><a href="byond://?src=\ref[src]&action=science">\[Building & Science\]</a></h1>
			<h1><a href="byond://?src=\ref[src]&action=close">\[Close\]</a></h1>
			</table>
			"}

			UpdatePage(page)

	admin_science

	admin_gains
		window_title = "Gains Panel"
		window_size = "700x600"
		settings = UPFORM_SET_HANDLE_FORMS
		form_type = UPFORM_WINDOW
		page_css = {"
			body { background-color: #d0d0d0 }
			.tr.
			.form { width: 100% }
			span.error { color: #ff0000; font-size: 10pt }
		"}

		Link(list/href_list, client/C)
			var/mob/M = src.getHost()
			var/action = href_list["action"]
			switch(action)
				if("close")
					del(src)
				if("menu")
					if(C.mob == M)
						if(upForm(C, C.mob, /upForm/admin_panel))
							del(src)

		canDisplayForm(client/C)
			. = ..()
			if(C.upForm_isViewingForm(src.type))
				. = 0

		FormInitTempVars()
			var/mob/M=src.getHost()
			Debug(M,"Loading form variables. [src.type]")
			initFormVar("admin", "adapt_mod", adapt_mod)
			initFormVar("admin", "alignment_on", alignment_on)
			initFormVar("admin", "allow_age_choosing", allow_age_choosing)
			initFormVar("admin", "Base_Stat_Gain", Base_Stat_Gain)
			initFormVar("admin", "BP_Cap", BP_Cap)
			initFormVar("admin", "bp_soft_cap", bp_soft_cap)
			initFormVar("admin", "death_anger_gives_ssj", death_anger_gives_ssj)
			initFormVar("admin", "energy_cap", energy_cap)
			initFormVar("admin", "feats_on", feats_on)
			initFormVar("admin", "Gain", Gain)
			initFormVar("admin", "godKiMasteryMod", godKiMasteryMod)
			initFormVar("admin", "gravity_mastery_mod", gravity_mastery_mod)
			initFormVar("admin", "incline_on", incline_on)
			initFormVar("admin", "inspire_allowed", inspire_allowed)
			initFormVar("admin", "Ki_Gain", Ki_Gain)
			initFormVar("admin", "Learn_Disabled", Learn_Disabled)
			initFormVar("admin", "leech_strongest", leech_strongest)
			initFormVar("admin", "max_auto_leech", max_auto_leech)
			initFormVar("admin", "npcs_give_hbtc_keys", npcs_give_hbtc_keys)
			initFormVar("admin", "offline_gains", offline_gains)
			initFormVar("admin", "old_age_on", old_age_on)
			initFormVar("admin", "race_stats_only_mode", race_stats_only_mode)
			initFormVar("admin", "Resource_Multiplier", Resource_Multiplier)
			initFormVar("admin", "server_zenkai", server_zenkai)
			initFormVar("admin", "SP_Multiplier", SP_Multiplier)
			initFormVar("admin", "ssj_easy", ssj_easy)
			initFormVar("admin", "SSj_Mastery", SSj_Mastery)
			initFormVar("admin", "Start_BP", Start_BP)
			initFormVar("admin", "Stat_Leech", Stat_Leech)
			initFormVar("admin", "strongest_bp_gain_penalty", strongest_bp_gain_penalty)
			initFormVar("admin", "Train_Disabled", Train_Disabled)
			initFormVar("admin", "trainingHours", trainingHours)
			initFormVar("admin", "trainingRestoreHours", trainingRestoreHours)
			initFormVar("admin", "Year", Year)
			Debug(M,"Variables loaded. [src.type]")

		ProcessVariable(fname, name, value)
			if(fname == "admin")
				var/mob/M=src.getHost()
				Debug(M,"Form: [fname] || Variable: [name] || Value: [value]")
				switch(name)
					if("adapt_mod") setFormVar(fname, name, text2num(value))
					if("alignment_on") setFormVar(fname, name, text2num(value))
					if("allow_age_choosing") setFormVar(fname, name, text2num(value))
					if("Base_Stat_Gain") setFormVar(fname, name, text2num(value))
					if("BP_Cap") setFormVar(fname, name, text2num(value))
					if("bp_soft_cap") setFormVar(fname, name, text2num(value))
					if("death_anger_gives_ssj") setFormVar(fname, name, text2num(value))
					if("energy_cap") setFormVar(fname, name, text2num(value))
					if("feats_on") setFormVar(fname, name, text2num(value))
					if("Gain") setFormVar(fname, name, text2num(value))
					if("godKiMasteryMod") setFormVar(fname, name, text2num(value))
					if("gravity_mastery_mod") setFormVar(fname, name, text2num(value))
					if("incline_on") setFormVar(fname, name, text2num(value))
					if("inspire_allowed") setFormVar(fname, name, text2num(value))
					if("Ki_Gain") setFormVar(fname, name, text2num(value))
					if("Learn_Disabled") setFormVar(fname, name, text2num(value))
					if("leech_strongest") setFormVar(fname, name, text2num(value))
					if("max_auto_leech") setFormVar(fname, name, text2num(value))
					if("npcs_give_hbtc_keys") setFormVar(fname, name, text2num(value))
					if("offline_gains") setFormVar(fname, name, text2num(value))
					if("old_age_on") setFormVar(fname, name, text2num(value))
					if("race_stats_only_mode") setFormVar(fname, name, text2num(value))
					if("Resource_Multiplier") setFormVar(fname, name, text2num(value))
					if("server_zenkai") setFormVar(fname, name, text2num(value))
					if("SP_Multiplier") setFormVar(fname, name, text2num(value))
					if("ssj_easy") setFormVar(fname, name, text2num(value))
					if("SSj_Mastery") setFormVar(fname, name, text2num(value))
					if("Start_BP") setFormVar(fname, name, text2num(value))
					if("Stat_Leech") setFormVar(fname, name, text2num(value))
					if("strongest_bp_gain_penalty") setFormVar(fname, name, text2num(value))
					if("Train_Disabled") setFormVar(fname, name, text2num(value))
					if("trainingHours") setFormVar(fname, name, text2num(value))
					if("trainingRestoreHours") setFormVar(fname, name, text2num(value))
					if("Year") setFormVar(fname, name, text2num(value))


		FormSetTempVars(fname)
			var/mob/M = src.getHost()
			if(fname == "admin")
				M << "Applying variable changes."
				if(Admins[M.key]>=4)
					adapt_mod= getFormVar("admin", "adapt_mod")
					alignment_on= getFormVar("admin", "alignment_on")
					allow_age_choosing= getFormVar("admin", "allow_age_choosing")
					Base_Stat_Gain= getFormVar("admin", "Base_Stat_Gain")
					BP_Cap= getFormVar("admin", "BP_Cap")
					bp_soft_cap= getFormVar("admin", "bp_soft_cap")
					death_anger_gives_ssj= getFormVar("admin", "death_anger_gives_ssj")
					energy_cap= getFormVar("admin", "energy_cap")
					feats_on= getFormVar("admin", "feats_on")
					Gain= getFormVar("admin", "Gain")
					godKiMasteryMod= getFormVar("admin", "godKiMasteryMod")
					gravity_mastery_mod= getFormVar("admin", "gravity_mastery_mod")
					incline_on= getFormVar("admin", "incline_on")
					inspire_allowed= getFormVar("admin", "inspire_allowed")
					Ki_Gain= getFormVar("admin", "Ki_Gain")
					Learn_Disabled= getFormVar("admin", "Learn_Disabled")
					leech_strongest= getFormVar("admin", "leech_strongest")
					max_auto_leech= getFormVar("admin", "max_auto_leech")
					npcs_give_hbtc_keys= getFormVar("admin", "npcs_give_hbtc_keys")
					offline_gains= getFormVar("admin", "offline_gains")
					old_age_on= getFormVar("admin", "old_age_on")
					race_stats_only_mode= getFormVar("admin", "race_stats_only_mode")
					Resource_Multiplier= getFormVar("admin", "Resource_Multiplier")
					server_zenkai= getFormVar("admin", "server_zenkai")
					SP_Multiplier= getFormVar("admin", "SP_Multiplier")
					ssj_easy= getFormVar("admin", "ssj_easy")
					SSj_Mastery= getFormVar("admin", "SSj_Mastery")
					Start_BP= getFormVar("admin", "Start_BP")
					Stat_Leech= getFormVar("admin", "Stat_Leech")
					strongest_bp_gain_penalty= getFormVar("admin", "strongest_bp_gain_penalty")
					Train_Disabled= getFormVar("admin", "Train_Disabled")
					trainingHours= getFormVar("admin", "trainingHours")
					trainingRestoreHours= getFormVar("admin", "trainingRestoreHours")
					Year= getFormVar("admin", "Year")


		FormSubmitSuccess(fname, client/C)
			if(fname == "admin")
				if(upForm(C, C.mob, /upForm/admin_panel))
					del(src)

		GenerateBody(list/errors=list())
			var/mob/M = src.getHost()
			if(errors.len>1)
				for(var/A in errors)
					M << "Error: [A]"
			var/page = {"
			<form name="info" action="byond://" method="get">
			  <input type="hidden" name="src" value="\ref[src]" />
			  <input type="hidden" name="form" value="admin" />

			  <table width="100%" height="100%" border="0">
			  <tr height="12px"><td colspan="4">
			    <table width="100%" height="100%" border="0">
			    <tr>
			      <td width="60%"><b>Progression Settings</b></td>
			      <td width="40%" align="right">
			      	<a href="byond://?src=\ref[src]&action=menu">\[Menu\]</a>
			        <a href="byond://?src=\ref[src]&action=close">\[Close\]</a>
			      </td>
			    </tr>
			    <tr><td colspan="2"><hr /></td></tr>
			    </table>
			  </tr></td>
				<tr height="1em" valign="top"><td width="30%"><b>adapt_mod: <td width="60%"><center>(Changes Adapt Mod)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="adapt_mod" value="[getFormVar("admin","adapt_mod")]" size="3" maxlength="20"/><span class="error">[errors["adapt_mod"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>alignment_on: <td width="60%"><center>(Toggles Alignment On)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="alignment_on" value="[getFormVar("admin","alignment_on")]" size="3" maxlength="1"/><span class="error">[errors["alignment_on"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>allow_age_choosing: <td width="60%"><center>(Toggles Allow Age Choosing)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="allow_age_choosing" value="[getFormVar("admin","allow_age_choosing")]" size="3" maxlength="1"/><span class="error">[errors["allow_age_choosing"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Base_Stat_Gain: <td width="60%"><center>(Changes Base Stat Gain)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="Base_Stat_Gain" value="[getFormVar("admin","Base_Stat_Gain")]" size="3" maxlength="20"/><span class="error">[errors["Base_Stat_Gain"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>BP_Cap: <td width="60%"><center>(Changes Bp Cap)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="BP_Cap" value="[getFormVar("admin","BP_Cap")]" size="3" maxlength="20"/><span class="error">[errors["BP_Cap"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>bp_soft_cap: <td width="60%"><center>(Changes Bp Soft Cap)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="bp_soft_cap" value="[getFormVar("admin","bp_soft_cap")]" size="3" maxlength="20"/><span class="error">[errors["bp_soft_cap"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>death_anger_gives_ssj: <td width="60%"><center>(Toggles Death Anger Gives Ssj)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="death_anger_gives_ssj" value="[getFormVar("admin","death_anger_gives_ssj")]" size="3" maxlength="1"/><span class="error">[errors["death_anger_gives_ssj"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>energy_cap: <td width="60%"><center>(Changes Energy Cap)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="energy_cap" value="[getFormVar("admin","energy_cap")]" size="3" maxlength="20"/><span class="error">[errors["energy_cap"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>feats_on: <td width="60%"><center>(Toggles Feats On)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="feats_on" value="[getFormVar("admin","feats_on")]" size="3" maxlength="1"/><span class="error">[errors["feats_on"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Gain: <td width="60%"><center>(Changes Gain)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="Gain" value="[getFormVar("admin","Gain")]" size="3" maxlength="20"/><span class="error">[errors["Gain"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>godKiMasteryMod: <td width="60%"><center>(Changes Godkimasterymod)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="godKiMasteryMod" value="[getFormVar("admin","godKiMasteryMod")]" size="3" maxlength="20"/><span class="error">[errors["godKiMasteryMod"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>gravity_mastery_mod: <td width="60%"><center>(Changes Gravity Mastery Mod)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="gravity_mastery_mod" value="[getFormVar("admin","gravity_mastery_mod")]" size="3" maxlength="20"/><span class="error">[errors["gravity_mastery_mod"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>incline_on: <td width="60%"><center>(Toggles Incline On)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="incline_on" value="[getFormVar("admin","incline_on")]" size="3" maxlength="1"/><span class="error">[errors["incline_on"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>inspire_allowed: <td width="60%"><center>(Toggles Inspire Allowed)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="inspire_allowed" value="[getFormVar("admin","inspire_allowed")]" size="3" maxlength="1"/><span class="error">[errors["inspire_allowed"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Ki_Gain: <td width="60%"><center>(Changes Ki Gain)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="Ki_Gain" value="[getFormVar("admin","Ki_Gain")]" size="3" maxlength="20"/><span class="error">[errors["Ki_Gain"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Learn_Disabled: <td width="60%"><center>(Toggles Learn Disabled)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="Learn_Disabled" value="[getFormVar("admin","Learn_Disabled")]" size="3" maxlength="1"/><span class="error">[errors["Learn_Disabled"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>leech_strongest: <td width="60%"><center>(Changes Leech Strongest)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="leech_strongest" value="[getFormVar("admin","leech_strongest")]" size="3" maxlength="20"/><span class="error">[errors["leech_strongest"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>max_auto_leech: <td width="60%"><center>(Changes Max Auto Leech)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="max_auto_leech" value="[getFormVar("admin","max_auto_leech")]" size="3" maxlength="20"/><span class="error">[errors["max_auto_leech"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>npcs_give_hbtc_keys: <td width="60%"><center>(Toggles Npcs Give Hbtc Keys)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="npcs_give_hbtc_keys" value="[getFormVar("admin","npcs_give_hbtc_keys")]" size="3" maxlength="1"/><span class="error">[errors["npcs_give_hbtc_keys"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>offline_gains: <td width="60%"><center>(Changes Offline Gains)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="offline_gains" value="[getFormVar("admin","offline_gains")]" size="3" maxlength="20"/><span class="error">[errors["offline_gains"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>old_age_on: <td width="60%"><center>(Toggles Old Age On)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="old_age_on" value="[getFormVar("admin","old_age_on")]" size="3" maxlength="1"/><span class="error">[errors["old_age_on"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>race_stats_only_mode: <td width="60%"><center>(Toggles Race Stats Only Mode)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="race_stats_only_mode" value="[getFormVar("admin","race_stats_only_mode")]" size="3" maxlength="1"/><span class="error">[errors["race_stats_only_mode"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Resource_Multiplier: <td width="60%"><center>(Changes Resource Multiplier)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="Resource_Multiplier" value="[getFormVar("admin","Resource_Multiplier")]" size="3" maxlength="20"/><span class="error">[errors["Resource_Multiplier"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>server_zenkai: <td width="60%"><center>(Changes Server Zenkai)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="server_zenkai" value="[getFormVar("admin","server_zenkai")]" size="3" maxlength="20"/><span class="error">[errors["server_zenkai"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>SP_Multiplier: <td width="60%"><center>(Changes Sp Multiplier)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="SP_Multiplier" value="[getFormVar("admin","SP_Multiplier")]" size="3" maxlength="20"/><span class="error">[errors["SP_Multiplier"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>ssj_easy: <td width="60%"><center>(Toggles Ssj Easy)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="ssj_easy" value="[getFormVar("admin","ssj_easy")]" size="3" maxlength="1"/><span class="error">[errors["ssj_easy"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>SSj_Mastery: <td width="60%"><center>(Changes Ssj Mastery)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="SSj_Mastery" value="[getFormVar("admin","SSj_Mastery")]" size="3" maxlength="20"/><span class="error">[errors["SSj_Mastery"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Start_BP: <td width="60%"><center>(Changes Start Bp)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="Start_BP" value="[getFormVar("admin","Start_BP")]" size="3" maxlength="20"/><span class="error">[errors["Start_BP"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Stat_Leech: <td width="60%"><center>(Changes Stat Leech)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="Stat_Leech" value="[getFormVar("admin","Stat_Leech")]" size="3" maxlength="20"/><span class="error">[errors["Stat_Leech"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>strongest_bp_gain_penalty: <td width="60%"><center>(Changes Strongest Bp Gain Penalty)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="strongest_bp_gain_penalty" value="[getFormVar("admin","strongest_bp_gain_penalty")]" size="3" maxlength="20"/><span class="error">[errors["strongest_bp_gain_penalty"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Train_Disabled: <td width="60%"><center>(Toggles Train Disabled)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="Train_Disabled" value="[getFormVar("admin","Train_Disabled")]" size="3" maxlength="1"/><span class="error">[errors["Train_Disabled"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>trainingHours: <td width="60%"><center>(Changes Traininghours)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="trainingHours" value="[getFormVar("admin","trainingHours")]" size="3" maxlength="20"/><span class="error">[errors["trainingHours"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>trainingRestoreHours: <td width="60%"><center>(Changes Trainingrestorehours)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="trainingRestoreHours" value="[getFormVar("admin","trainingRestoreHours")]" size="3" maxlength="20"/><span class="error">[errors["trainingRestoreHours"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Year: <td width="60%"><center>(Changes Year)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="Year" value="[getFormVar("admin","Year")]" size="3" maxlength="20"/><span class="error">[errors["Year"]]</span></td></tr>

			  <tr height="1em">
			  	<td colspan="4" align="right"> <input type="submit" value="Submit" />
			  	<input type="reset" value="Reset" /> </td>
			  </tr>
			  </table>
			</form>
			"}
			UpdatePage(page)

	admin_world
		window_title = "World Panel"
		window_size = "700x600"
		settings = UPFORM_SET_HANDLE_FORMS
		form_type = UPFORM_WINDOW
		page_css = {"
			body { background-color: #d0d0d0 }
			.tr.
			.form { width: 100% }
			span.error { color: #ff0000; font-size: 10pt }
		"}

		Link(list/href_list, client/C)
			var/mob/M = src.getHost()
			var/action = href_list["action"]
			switch(action)
				if("close")
					del(src)
				if("menu")
					if(C.mob == M)
						if(upForm(C, C.mob, /upForm/admin_panel))
							del(src)

		canDisplayForm(client/C)
			. = ..()
			if(C.upForm_isViewingForm(src.type))
				. = 0

		FormInitTempVars()
			var/mob/M=src.getHost()
			M << "Loading form variables. [src.type]"
			initFormVar("admin", "hostAllowsPacksOnRP", hostAllowsPacksOnRP)
			initFormVar("admin", "pack_KT_allowed", pack_KT_allowed)
			initFormVar("admin", "hellAltar", hellAltar)
			initFormVar("admin", "BraalGym", BraalGym)
			initFormVar("admin", "allow_good_bounties", allow_good_bounties)
			initFormVar("admin", "give_countdown_verb", give_countdown_verb)
			initFormVar("admin", "give_whisper_verb", give_whisper_verb)
			initFormVar("admin", "anyone_can_enter_hbtc", anyone_can_enter_hbtc)
			initFormVar("admin", "admins_build_free", admins_build_free)
			initFormVar("admin", "show_names_in_ooc", show_names_in_ooc)
			initFormVar("admin", "voting_allowed", voting_allowed)
			initFormVar("admin", "announce_dragon_balls", announce_dragon_balls)
			initFormVar("admin", "lose_resources_on_logout", lose_resources_on_logout)
			initFormVar("admin", "doors_kill", doors_kill)
			initFormVar("admin", "drop_items_on_death", drop_items_on_death)
			initFormVar("admin", "allow_guests", allow_guests)
			initFormVar("admin", "im_trapped_allowed", im_trapped_allowed)
			initFormVar("admin", "Safezones", Safezones)
			initFormVar("admin", "can_era_vote", can_era_vote)
			initFormVar("admin", "Can_Pwipe_Vote", Can_Pwipe_Vote)
			initFormVar("admin", "Allow_Ban_Votes", Allow_Ban_Votes)
			initFormVar("admin", "gta5_wasted", gta5_wasted)
			initFormVar("admin", "sagas", sagas)
			initFormVar("admin", "alts", alts)
			initFormVar("admin", "RP_President", RP_President)
			initFormVar("admin", "Tournament_Prize", Tournament_Prize)
			initFormVar("admin", "Safezone_Distance", Safezone_Distance)
			initFormVar("admin", "Max_Players", Max_Players)
			initFormVar("admin", "skill_tournament_chance", skill_tournament_chance)
			initFormVar("admin", "meteor_density", meteor_density)
			initFormVar("admin", "alt_limit", alt_limit)
			initFormVar("admin", "pwipe_vote_year", pwipe_vote_year)
			initFormVar("admin", "pwipe_vote_bp", pwipe_vote_bp)
			initFormVar("admin", "skill_tournament_bp_boost", skill_tournament_bp_boost)
			initFormVar("admin", "auto_reboot_hours", auto_reboot_hours)
			initFormVar("admin", "auto_reset_bp_at", auto_reset_bp_at)
			initFormVar("admin", "npcDensity", npcDensity)
			initFormVar("admin", "defaultScreenSize", defaultScreenSize)
			initFormVar("admin", "max_screen_size", max_screen_size)
			M << "Variables loaded. [src.type]"

		ProcessVariable(fname, name, value)
			if(fname == "admin")
				var/mob/M=src.getHost()
				Debug("Form: [fname] || Variable: [name] || Value: [value]")
				switch(name)
					if("hostAllowsPacksOnRP") setFormVar(fname, name, text2num(value))
					if("pack_KT_allowed") setFormVar(fname, name, text2num(value))
					if("hellAltar") setFormVar(fname, name, text2num(value))
					if("BraalGym") setFormVar(fname, name, text2num(value))
					if("allow_good_bounties") setFormVar(fname, name, text2num(value))
					if("give_countdown_verb") setFormVar(fname, name, text2num(value))
					if("give_whisper_verb") setFormVar(fname, name, text2num(value))
					if("anyone_can_enter_hbtc") setFormVar(fname, name, text2num(value))
					if("admins_build_free") setFormVar(fname, name, text2num(value))
					if("show_names_in_ooc") setFormVar(fname, name, text2num(value))
					if("voting_allowed") setFormVar(fname, name, text2num(value))
					if("announce_dragon_balls") setFormVar(fname, name, text2num(value))
					if("lose_resources_on_logout") setFormVar(fname, name, text2num(value))
					if("doors_kill") setFormVar(fname, name, text2num(value))
					if("drop_items_on_death") setFormVar(fname, name, text2num(value))
					if("allow_guests") setFormVar(fname, name, text2num(value))
					if("im_trapped_allowed") setFormVar(fname, name, text2num(value))
					if("Safezones") setFormVar(fname, name, text2num(value))
					if("can_era_vote") setFormVar(fname, name, text2num(value))
					if("Can_Pwipe_Vote") setFormVar(fname, name, text2num(value))
					if("Allow_Ban_Votes") setFormVar(fname, name, text2num(value))
					if("gta5_wasted") setFormVar(fname, name, text2num(value))
					if("sagas") setFormVar(fname, name, text2num(value))
					if("alts") setFormVar(fname, name, value)
					if("RP_President") setFormVar(fname, name, value)
					if("Tournament_Prize") setFormVar(fname, name, text2num(value))
					if("Safezone_Distance") setFormVar(fname, name, text2num(value))
					if("Max_Players") setFormVar(fname, name, text2num(value))
					if("skill_tournament_chance") setFormVar(fname, name, text2num(value))
					if("meteor_density") setFormVar(fname, name, text2num(value))
					if("alt_limit") setFormVar(fname, name, text2num(value))
					if("pwipe_vote_year") setFormVar(fname, name, text2num(value))
					if("pwipe_vote_bp") setFormVar(fname, name, text2num(value))
					if("skill_tournament_bp_boost") setFormVar(fname, name, text2num(value))
					if("auto_reboot_hours") setFormVar(fname, name, text2num(value))
					if("auto_reset_bp_at") setFormVar(fname, name, text2num(value))
					if("npcDensity") setFormVar(fname, name, text2num(value))
					if("defaultScreenSize") setFormVar(fname, name, text2num(value))
					if("max_screen_size") setFormVar(fname, name, text2num(value))


		FormSetTempVars(fname)
			var/mob/M = src.getHost()
			if(fname == "admin")
				M << "Applying variable changes."
				if(Admins[M.key]>=4)
					hostAllowsPacksOnRP= getFormVar("admin", "hostAllowsPacksOnRP")
					pack_KT_allowed= getFormVar("admin", "pack_KT_allowed")
					hellAltar= getFormVar("admin", "hellAltar")
					BraalGym= getFormVar("admin", "BraalGym")
					allow_good_bounties= getFormVar("admin", "allow_good_bounties")
					give_countdown_verb= getFormVar("admin", "give_countdown_verb")
					give_whisper_verb= getFormVar("admin", "give_whisper_verb")
					anyone_can_enter_hbtc= getFormVar("admin", "anyone_can_enter_hbtc")
					admins_build_free= getFormVar("admin", "admins_build_free")
					show_names_in_ooc= getFormVar("admin", "show_names_in_ooc")
					voting_allowed= getFormVar("admin", "voting_allowed")
					announce_dragon_balls= getFormVar("admin", "announce_dragon_balls")
					lose_resources_on_logout= getFormVar("admin", "lose_resources_on_logout")
					doors_kill= getFormVar("admin", "doors_kill")
					drop_items_on_death= getFormVar("admin", "drop_items_on_death")
					allow_guests= getFormVar("admin", "allow_guests")
					im_trapped_allowed= getFormVar("admin", "im_trapped_allowed")
					Safezones= getFormVar("admin", "Safezones")
					can_era_vote= getFormVar("admin", "can_era_vote")
					Can_Pwipe_Vote= getFormVar("admin", "Can_Pwipe_Vote")
					Allow_Ban_Votes= getFormVar("admin", "Allow_Ban_Votes")
					gta5_wasted= getFormVar("admin", "gta5_wasted")
					sagas= getFormVar("admin", "sagas")
					alts= getFormVar("admin", "alts")
					RP_President= getFormVar("admin", "RP_President")
					Tournament_Prize= getFormVar("admin", "Tournament_Prize")
					Safezone_Distance= getFormVar("admin", "Safezone_Distance")
					Max_Players= getFormVar("admin", "Max_Players")
					skill_tournament_chance= getFormVar("admin", "skill_tournament_chance")
					meteor_density= getFormVar("admin", "meteor_density")
					alt_limit= getFormVar("admin", "alt_limit")
					pwipe_vote_year= getFormVar("admin", "pwipe_vote_year")
					pwipe_vote_bp= getFormVar("admin", "pwipe_vote_bp")
					skill_tournament_bp_boost= getFormVar("admin", "skill_tournament_bp_boost")
					auto_reboot_hours= getFormVar("admin", "auto_reboot_hours")
					auto_reset_bp_at= getFormVar("admin", "auto_reset_bp_at")
					npcDensity= getFormVar("admin", "npcDensity")
					defaultScreenSize= getFormVar("admin", "defaultScreenSize")
					max_screen_size= getFormVar("admin", "max_screen_size")


		FormSubmitSuccess(fname, client/C)
			if(fname == "admin")
				if(hellAltar==0) spawn CheckDeleteHellAltar()
				if(BraalGym==0) spawn ToggleBraalGym()
				if(upForm(C, C.mob, /upForm/admin_panel))
					del(src)

		GenerateBody(list/errors=list())
			var/mob/M = src.getHost()
			if(errors.len>1)
				for(var/A in errors)
					M << "Error: [A]"
			var/page = {"
			<form name="info" action="byond://" method="get">
			  <input type="hidden" name="src" value="\ref[src]" />
			  <input type="hidden" name="form" value="admin" />

			  <table width="100%" height="100%" border="0">
			  <tr height="12px"><td colspan="4">
			    <table width="100%" height="100%" border="0">
			    <tr>
			      <td width="60%"><b>World Settings</b></td>
			      <td width="40%" align="right">
			      	<a href="byond://?src=\ref[src]&action=menu">\[Menu\]</a>
			        <a href="byond://?src=\ref[src]&action=close">\[Close\]</a>
			      </td>
			    </tr>
			    <tr><td colspan="2"><hr /></td></tr>
			    </table>
			  </tr></td>
				<tr height="1em" valign="top"><td width="30%"><b>RP Server Packs: <td width="60%"><center>(0=Off for RP,1=On for RP)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="hostAllowsPacksOnRP" value="[getFormVar("admin","hostAllowsPacksOnRP")]" size="3" maxlength="1"/><span class="error">[errors["hostAllowsPacksOnRP"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Pack KT Toggle: <td width="60%"><center>(0=No KT, 1=Pack KT)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="pack_KT_allowed" value="[getFormVar("admin","pack_KT_allowed")]" size="3" maxlength="1"/><span class="error">[errors["pack_KT_allowed"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Hell Altar: <td width="60%"><center>(0=Off, 1=On)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="hellAltar" value="[getFormVar("admin","hellAltar")]" size="3" maxlength="1"/><span class="error">[errors["hellAltar"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Braal Gym: <td width="60%"><center>(0=Off, 1=On)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="BraalGym" value="[getFormVar("admin","BraalGym")]" size="3" maxlength="1"/><span class="error">[errors["BraalGym"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Bounties on Good People: <td width="60%"><center>(0=Off, 1=On)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="allow_good_bounties" value="[getFormVar("admin","allow_good_bounties")]" size="3" maxlength="1"/><span class="error">[errors["allow_good_bounties"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Countdown Toggle: <td width="60%"><center>(0=Off, 1=On)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="give_countdown_verb" value="[getFormVar("admin","give_countdown_verb")]" size="3" maxlength="1"/><span class="error">[errors["give_countdown_verb"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Whisper Toggle: <td width="60%"><center>(0=Off, 1=On)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="give_whisper_verb" value="[getFormVar("admin","give_whisper_verb")]" size="3" maxlength="1"/><span class="error">[errors["give_whisper_verb"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Unlock HBTC: <td width="60%"><center>(0=Locked, 1=Unlocked)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="anyone_can_enter_hbtc" value="[getFormVar("admin","anyone_can_enter_hbtc")]" size="3" maxlength="1"/><span class="error">[errors["anyone_can_enter_hbtc"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Admin Free Building: <td width="60%"><center>(0=Off, 1=On)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="admins_build_free" value="[getFormVar("admin","admins_build_free")]" size="3" maxlength="1"/><span class="error">[errors["admins_build_free"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Character Names in OOC: <td width="60%"><center>(0=Off, 1=On)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="show_names_in_ooc" value="[getFormVar("admin","show_names_in_ooc")]" size="3" maxlength="1"/><span class="error">[errors["show_names_in_ooc"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Voting Toggle: <td width="60%"><center>(0=Off, 1=On)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="voting_allowed" value="[getFormVar("admin","voting_allowed")]" size="3" maxlength="1"/><span class="error">[errors["voting_allowed"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Lizard Sphere Announcements: <td width="60%"><center>(0=Off, 1=On)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="announce_dragon_balls" value="[getFormVar("admin","announce_dragon_balls")]" size="3" maxlength="1"/><span class="error">[errors["announce_dragon_balls"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Offline Resource Deprecation: <td width="60%"><center>(0=Off, 1=On)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="lose_resources_on_logout" value="[getFormVar("admin","lose_resources_on_logout")]" size="3" maxlength="1"/><span class="error">[errors["lose_resources_on_logout"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Lethal Doors: <td width="60%"><center>(0=Off, 1=On)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="doors_kill" value="[getFormVar("admin","doors_kill")]" size="3" maxlength="1"/><span class="error">[errors["doors_kill"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Drop Items on Death: <td width="60%"><center>(0=No, 1=Yes)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="drop_items_on_death" value="[getFormVar("admin","drop_items_on_death")]" size="3" maxlength="1"/><span class="error">[errors["drop_items_on_death"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Guest Key Toggle: <td width="60%"><center>(0=Banned, 1=Allowed)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="allow_guests" value="[getFormVar("admin","allow_guests")]" size="3" maxlength="1"/><span class="error">[errors["allow_guests"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Im Trapped Toggle: <td width="60%"><center>(0=Off, 1=On)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="im_trapped_allowed" value="[getFormVar("admin","im_trapped_allowed")]" size="3" maxlength="1"/><span class="error">[errors["im_trapped_allowed"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Safezones: <td width="60%"><center>(0=Off, 1=On)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="Safezones" value="[getFormVar("admin","Safezones")]" size="3" maxlength="1"/><span class="error">[errors["Safezones"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Era Voting: <td width="60%"><center>(0=Off, 1=On)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="can_era_vote" value="[getFormVar("admin","can_era_vote")]" size="3" maxlength="1"/><span class="error">[errors["can_era_vote"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Player Wipe Voting: <td width="60%"><center>(0=Off, 1=On)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="Can_Pwipe_Vote" value="[getFormVar("admin","Can_Pwipe_Vote")]" size="3" maxlength="1"/><span class="error">[errors["Can_Pwipe_Vote"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Ban Voting: <td width="60%"><center>(0=Off, 1=On)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="Allow_Ban_Votes" value="[getFormVar("admin","Allow_Ban_Votes")]" size="3" maxlength="1"/><span class="error">[errors["Allow_Ban_Votes"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Wasted Transition: <td width="60%"><center>(0=Off, 1=On)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="gta5_wasted" value="[getFormVar("admin","gta5_wasted")]" size="3" maxlength="1"/><span class="error">[errors["gta5_wasted"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Saga Toggle: <td width="60%"><center>(0=Off, 1=On)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="sagas" value="[getFormVar("admin","sagas")]" size="3" maxlength="1"/><span class="error">[errors["sagas"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Alts: <td width="60%"><center>(Allow or Disallow Alts)</center></td></b></td><td width="10%" colspan="3"><select class="form" name="alts" value="[getFormVar("admin","alts")]" size="3" /><option value="allowed" selected>Allowed</option><option value="disallowed">Disallowed</option><option value="allowed only if seperate computers">Seperate PCs</option></select><span class="error">[errors["alts"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>RP President: <td width="60%"><center>(Key of RP President)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="RP_President" value="[getFormVar("admin","RP_President")]" size="3" maxlength="30"/><span class="error">[errors["RP_President"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Tournament Prize: <td width="60%"><center>(Tournament Prize Amount)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="Tournament_Prize" value="[getFormVar("admin","Tournament_Prize")]" size="3" maxlength="20"/><span class="error">[errors["Tournament_Prize"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Safezone_Distance: <td width="60%"><center>(Safezone Radius)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="Safezone_Distance" value="[getFormVar("admin","Safezone_Distance")]" size="3" maxlength="20"/><span class="error">[errors["Safezone_Distance"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Max_Players: <td width="60%"><center>(Player Limit)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="Max_Players" value="[getFormVar("admin","Max_Players")]" size="3" maxlength="20"/><span class="error">[errors["Max_Players"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Skill Tournament Chance: <td width="60%"><center>(Percent Chance of Skill Tournament)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="skill_tournament_chance" value="[getFormVar("admin","skill_tournament_chance")]" size="3" maxlength="20"/><span class="error">[errors["skill_tournament_chance"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Meteor Density: <td width="60%"><center>(Multiplier for Meteor Spawning)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="meteor_density" value="[getFormVar("admin","meteor_density")]" size="3" maxlength="20"/><span class="error">[errors["meteor_density"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Alt Limit: <td width="60%"><center>(Max Number of Alts per Person)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="alt_limit" value="[getFormVar("admin","alt_limit")]" size="3" maxlength="20"/><span class="error">[errors["alt_limit"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>P-Wipe Vote Year: <td width="60%"><center>(Minimum Year for P-Wipe Vote)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="pwipe_vote_year" value="[getFormVar("admin","pwipe_vote_year")]" size="3" maxlength="20"/><span class="error">[errors["pwipe_vote_year"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>P-Wipe Vote BP <td width="60%"><center>(Minimum BP for P-Wipe Vote)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="pwipe_vote_bp" value="[getFormVar("admin","pwipe_vote_bp")]" size="3" maxlength="20"/><span class="error">[errors["pwipe_vote_bp"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Skill Tournament BP Bonus: <td width="60%"><center>(Changes Skill Tournament Bp Boost)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="skill_tournament_bp_boost" value="[getFormVar("admin","skill_tournament_bp_boost")]" size="3" maxlength="20"/><span class="error">[errors["skill_tournament_bp_boost"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Auto Reboot Time: <td width="60%"><center>(Hours between Auto Reboots)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="auto_reboot_hours" value="[getFormVar("admin","auto_reboot_hours")]" size="3" maxlength="20"/><span class="error">[errors["auto_reboot_hours"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Auto Reset BP: <td width="60%"><center>(Triggers Era Reset at set BP)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="auto_reset_bp_at" value="[getFormVar("admin","auto_reset_bp_at")]" size="3" maxlength="20"/><span class="error">[errors["auto_reset_bp_at"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>NPC Spawn Density: <td width="60%"><center>(Multiplier for NPC Spawn Density)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="npcDensity" value="[getFormVar("admin","npcDensity")]" size="3" maxlength="20"/><span class="error">[errors["npcDensity"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Default View Radius: <td width="60%"><center>(Default View Radius)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="defaultScreenSize" value="[getFormVar("admin","defaultScreenSize")]" size="3" maxlength="20"/><span class="error">[errors["defaultScreenSize"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Max View Radius: <td width="60%"><center>(Changes Max Screen Size)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="max_screen_size" value="[getFormVar("admin","max_screen_size")]" size="3" maxlength="20"/><span class="error">[errors["max_screen_size"]]</span></td></tr>
			  <tr height="1em">
			  	<td colspan="4" align="right"> <input type="submit" value="Submit" />
			  	<input type="reset" value="Reset" /> </td>
			  </tr>
			  </table>
			</form>
			"}
			UpdatePage(page)

	admin_battlegrounds
		window_title = "Battlegrounds Panel"
		window_size = "700x600"
		settings = UPFORM_SET_HANDLE_FORMS
		form_type = UPFORM_WINDOW
		page_css = {"
			body { background-color: #d0d0d0 }
			.tr.
			.form { width: 100% }
			span.error { color: #ff0000; font-size: 10pt }
		"}

		Link(list/href_list, client/C)
			var/mob/M = src.getHost()
			var/action = href_list["action"]
			switch(action)
				if("close")
					del(src)
				if("menu")
					if(C.mob == M)
						if(upForm(C, C.mob, /upForm/admin_panel))
							del(src)

		canDisplayForm(client/C)
			. = ..()
			if(C.upForm_isViewingForm(src.type))
				. = 0

		FormInitTempVars()
			var/mob/M=src.getHost()
			M << "Loading form variables. [src.type]"
			initFormVar("admin", "battlegroundSystem", battlegroundSystem)
			initFormVar("admin", "battleground_spawn_choice_on", battleground_spawn_choice_on)
			initFormVar("admin", "battleground_master_bp_mult", battleground_master_bp_mult)
			M << "Variables loaded. [src.type]"

		ProcessVariable(fname, name, value)
			if(fname == "admin")
				var/mob/M=src.getHost()
				M << "Form: [fname] || Variable: [name] || Value: [value]"
				switch(name)
					if("battlegroundSystem") setFormVar(fname, name, text2num(value))
					if("battleground_spawn_choice_on") setFormVar(fname, name, text2num(value))
					if("battleground_master_bp_mult") setFormVar(fname, name, text2num(value))


		FormSetTempVars(fname)
			var/mob/M = src.getHost()
			if(fname == "admin")
				M << "Applying variable changes."
				if(Admins[M.key]>=4)
					battlegroundSystem= getFormVar("admin", "battlegroundSystem")
					battleground_spawn_choice_on= getFormVar("admin", "battleground_spawn_choice_on")
					battleground_master_bp_mult= getFormVar("admin", "battleground_master_bp_mult")


		FormSubmitSuccess(fname, client/C)
			if(fname == "admin")
				if(upForm(C, C.mob, /upForm/admin_panel))
					del(src)

		GenerateBody(list/errors=list())
			var/mob/M = src.getHost()
			if(errors.len>1)
				for(var/A in errors)
					M << "Error: [A]"
			var/page = {"
			<form name="info" action="byond://" method="get">
			  <input type="hidden" name="src" value="\ref[src]" />
			  <input type="hidden" name="form" value="admin" />

			  <table width="100%" height="100%" border="0">
			  <tr height="12px"><td colspan="4">
			    <table width="100%" height="100%" border="0">
			    <tr>
			      <td width="60%"><b>Battlegrounds Settings</b></td>
			      <td width="40%" align="right">
			      	<a href="byond://?src=\ref[src]&action=menu">\[Menu\]</a>
			        <a href="byond://?src=\ref[src]&action=close">\[Close\]</a>
			      </td>
			    </tr>
			    <tr><td colspan="2"><hr /></td></tr>
			    </table>
			  </tr></td>
				<tr height="1em" valign="top"><td width="30%"><b>Battlgrounds: <td width="60%"><center>(0=Off, 1=On)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="battlegroundSystem" value="[getFormVar("admin","battlegroundSystem")]" size="3" maxlength="1"/><span class="error">[errors["battlegroundSystem"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Battlegrounds Spawn: <td width="60%"><center>(0=Off, 1=On)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="battleground_spawn_choice_on" value="[getFormVar("admin","battleground_spawn_choice_on")]" size="3" maxlength="1"/><span class="error">[errors["battleground_spawn_choice_on"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Battleground Master Boost: <td width="60%"><center>(BP Multiplier for Battleground Master)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="battleground_master_bp_mult" value="[getFormVar("admin","battleground_master_bp_mult")]" size="3" maxlength="20"/><span class="error">[errors["battleground_master_bp_mult"]]</span></td></tr>

		  <tr height="1em">
			  	<td colspan="4" align="right"> <input type="submit" value="Submit" />
			  	<input type="reset" value="Reset" /> </td>
			  </tr>
			  </table>
			</form>
			"}
			UpdatePage(page)

	admin_races
		window_title = "Races Panel"
		window_size = "700x600"
		settings = UPFORM_SET_HANDLE_FORMS
		form_type = UPFORM_WINDOW
		page_css = {"
			body { background-color: #d0d0d0 }
			.tr.
			.form { width: 100% }
			span.error { color: #ff0000; font-size: 10pt }
		"}

		Link(list/href_list, client/C)
			var/mob/M = src.getHost()
			var/action = href_list["action"]
			switch(action)
				if("close")
					del(src)
				if("illegal")
					M.Illegal_Races()
				if("menu")
					if(C.mob == M)
						if(upForm(C, C.mob, /upForm/admin_panel))
							del(src)

		canDisplayForm(client/C)
			. = ..()
			if(C.upForm_isViewingForm(src.type))
				. = 0

		FormInitTempVars()
			var/mob/M=src.getHost()
			M << "Loading form variables. [src.type]"
			initFormVar("admin", "lssj_common_race", lssj_common_race)
			initFormVar("admin", "icer_common_race", icer_common_race)
			initFormVar("admin", "majin_auto_learn", majin_auto_learn)
			initFormVar("admin", "imitate_allowed", imitate_allowed)
			initFormVar("admin", "max_Yasai_percent", max_Yasai_percent)
			M << "Variables loaded. [src.type]"

		ProcessVariable(fname, name, value)
			if(fname == "admin")
				var/mob/M=src.getHost()
				M << "Form: [fname] || Variable: [name] || Value: [value]"
				switch(name)
					if("lssj_common_race") setFormVar(fname, name, text2num(value))
					if("icer_common_race") setFormVar(fname, name, text2num(value))
					if("majin_auto_learn") setFormVar(fname, name, text2num(value))
					if("imitate_allowed") setFormVar(fname, name, text2num(value))
					if("max_Yasai_percent") setFormVar(fname, name, text2num(value))


		FormSetTempVars(fname)
			var/mob/M = src.getHost()
			if(fname == "admin")
				M << "Applying variable changes."
				if(Admins[M.key]>=4)
					lssj_common_race= getFormVar("admin", "lssj_common_race")
					icer_common_race= getFormVar("admin", "icer_common_race")
					majin_auto_learn= getFormVar("admin", "majin_auto_learn")
					imitate_allowed= getFormVar("admin", "imitate_allowed")
					max_Yasai_percent= getFormVar("admin", "max_Yasai_percent")


		FormSubmitSuccess(fname, client/C)
			if(fname == "admin")
				if(upForm(C, C.mob, /upForm/admin_panel))
					del(src)

		GenerateBody(list/errors=list())
			var/mob/M = src.getHost()
			if(errors.len>1)
				for(var/A in errors)
					M << "Error: [A]"
			var/page = {"
			<form name="info" action="byond://" method="get">
			  <input type="hidden" name="src" value="\ref[src]" />
			  <input type="hidden" name="form" value="admin" />

			  <table width="100%" height="100%" border="0">
			  <tr height="12px"><td colspan="4">
			    <table width="100%" height="100%" border="0">
			    <tr>
			      <td width="30%"><b>Race Settings</b></td>
			      <td width="70%" align="right">
			      	<a href="byond://?src=\ref[src]&action=menu">\[Menu\]</a>
			      	<a href="byond://?src=\ref[src]&action=illegal">\[Illegal Races\]</a>
			        <a href="byond://?src=\ref[src]&action=close">\[Close\]</a>
			      </td>
			    </tr>
			    <tr><td colspan="2"><hr /></td></tr>
			    </table>
			  </tr></td>
				<tr height="1em" valign="top"><td width="30%"><b>Make Legendary Yasai Common: <td width="60%"><center>(0=Rare, 1=Common)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="lssj_common_race" value="[getFormVar("admin","lssj_common_race")]" size="3" maxlength="1"/><span class="error">[errors["lssj_common_race"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Make Icer Common: <td width="60%"><center>(0=Rare, 1=Common)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="icer_common_race" value="[getFormVar("admin","icer_common_race")]" size="3" maxlength="1"/><span class="error">[errors["icer_common_race"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Enable Majin Auto-Learning: <td width="60%"><center>(0=Off, 1=On)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="majin_auto_learn" value="[getFormVar("admin","majin_auto_learn")]" size="3" maxlength="1"/><span class="error">[errors["majin_auto_learn"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Enable Imitate: <td width="60%"><center>(0=Off, 1=On)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="imitate_allowed" value="[getFormVar("admin","imitate_allowed")]" size="3" maxlength="1"/><span class="error">[errors["imitate_allowed"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Max Yasai Percentage: <td width="60%"><center>(Limit on Yasai Population)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="max_Yasai_percent" value="[getFormVar("admin","max_Yasai_percent")]" size="3" maxlength="20"/><span class="error">[errors["max_Yasai_percent"]]</span></td></tr>

		  <tr height="1em">
			  	<td colspan="4" align="right"> <input type="submit" value="Submit" />
			  	<input type="reset" value="Reset" /> </td>
			  </tr>
			  </table>
			</form>
			"}
			UpdatePage(page)


	admin_combat
		window_title = "Combat Panel"
		window_size = "700x600"
		settings = UPFORM_SET_HANDLE_FORMS
		form_type = UPFORM_WINDOW
		page_css = {"
			body { background-color: #d0d0d0 }
			.tr.
			.form { width: 100% }
			span.error { color: #ff0000; font-size: 10pt }
		"}

		Link(list/href_list, client/C)
			var/mob/M = src.getHost()
			var/action = href_list["action"]
			switch(action)
				if("close")
					del(src)
				if("menu")
					if(C.mob == M)
						if(upForm(C, C.mob, /upForm/admin_panel))
							del(src)

		canDisplayForm(client/C)
			. = ..()
			if(C.upForm_isViewingForm(src.type))
				. = 0

		FormInitTempVars()
			var/mob/M=src.getHost()
			M << "Loading form variables. [src.type]"
			initFormVar("admin", "hide_energy_enabled", hide_energy_enabled)
			initFormVar("admin", "allow_god_ki", allow_god_ki)
			initFormVar("admin", "stun_stops_movement", stun_stops_movement)
			initFormVar("admin", "shockwaves_off", shockwaves_off)
			initFormVar("admin", "explosions_off", explosions_off)
			initFormVar("admin", "dust_off", dust_off)
			initFormVar("admin", "allow_ultra_instinct", allow_ultra_instinct)
			initFormVar("admin", "force_32_pix_movement", force_32_pix_movement)
			initFormVar("admin", "allow_dragon_rush", allow_dragon_rush)
			initFormVar("admin", "lower_stats_off", lower_stats_off)
			initFormVar("admin", "limit_bind", limit_bind)
			initFormVar("admin", "can_cyber_KOd_people", can_cyber_KOd_people)
			initFormVar("admin", "custom_buffs_allowed", custom_buffs_allowed)
			initFormVar("admin", "can_ignore_SI", can_ignore_SI)
			initFormVar("admin", "allow_diagonal_movement", allow_diagonal_movement)
			initFormVar("admin", "forced_injections", forced_injections)
			initFormVar("admin", "Perma_Death", Perma_Death)
			initFormVar("admin", "Ki_Disabled", Ki_Disabled)
			initFormVar("admin", "hakai_wipes_character", hakai_wipes_character)
			initFormVar("admin", "death_setting", death_setting)
			initFormVar("admin", "Server_Regeneration", Server_Regeneration)
			initFormVar("admin", "Server_Recovery", Server_Recovery)
			initFormVar("admin", "KO_Time", KO_Time)
			initFormVar("admin", "reincarnation_loss", reincarnation_loss)
			initFormVar("admin", "reincarnation_recovery", reincarnation_recovery)
			initFormVar("admin", "melee_power", melee_power)
			initFormVar("admin", "ki_power", ki_power)
			initFormVar("admin", "max_buff_bp", max_buff_bp)
			initFormVar("admin", "global_stun_mod", global_stun_mod)
			initFormVar("admin", "God_FistMod", God_FistMod)
			initFormVar("admin", "knockback_mod", knockback_mod)
			initFormVar("admin", "demon_hell_boost", demon_hell_boost)
			initFormVar("admin", "kai_heaven_boost", kai_heaven_boost)
			initFormVar("admin", "dead_power_loss", dead_power_loss)
			initFormVar("admin", "keep_body_loss", keep_body_loss)
			initFormVar("admin", "hakai_cooldown", hakai_cooldown)
			initFormVar("admin", "hakai_bp_advantage_needed", hakai_bp_advantage_needed)
			initFormVar("admin", "BASE_MOVE_DELAY", BASE_MOVE_DELAY)
			initFormVar("admin", "planet_destroy_immunity_time", planet_destroy_immunity_time)
			initFormVar("admin", "planet_destroy_bp_requirement", planet_destroy_bp_requirement)
			M << "Variables loaded. [src.type]"

		ProcessVariable(fname, name, value)
			if(fname == "admin")
				var/mob/M=src.getHost()
				M << "Form: [fname] || Variable: [name] || Value: [value]"
				switch(name)
					if("hide_energy_enabled") setFormVar(fname, name, text2num(value))
					if("allow_god_ki") setFormVar(fname, name, text2num(value))
					if("stun_stops_movement") setFormVar(fname, name, text2num(value))
					if("shockwaves_off") setFormVar(fname, name, text2num(value))
					if("explosions_off") setFormVar(fname, name, text2num(value))
					if("dust_off") setFormVar(fname, name, text2num(value))
					if("allow_ultra_instinct") setFormVar(fname, name, text2num(value))
					if("force_32_pix_movement") setFormVar(fname, name, text2num(value))
					if("allow_dragon_rush") setFormVar(fname, name, text2num(value))
					if("lower_stats_off") setFormVar(fname, name, text2num(value))
					if("limit_bind") setFormVar(fname, name, text2num(value))
					if("can_cyber_KOd_people") setFormVar(fname, name, text2num(value))
					if("custom_buffs_allowed") setFormVar(fname, name, text2num(value))
					if("can_ignore_SI") setFormVar(fname, name, text2num(value))
					if("allow_diagonal_movement") setFormVar(fname, name, text2num(value))
					if("forced_injections") setFormVar(fname, name, text2num(value))
					if("Perma_Death") setFormVar(fname, name, text2num(value))
					if("Ki_Disabled") setFormVar(fname, name, text2num(value))
					if("hakai_wipes_character") setFormVar(fname, name, text2num(value))
					if("death_setting") setFormVar(fname, name, value)
					if("Server_Regeneration") setFormVar(fname, name, text2num(value))
					if("Server_Recovery") setFormVar(fname, name, text2num(value))
					if("KO_Time") setFormVar(fname, name, text2num(value))
					if("reincarnation_loss") setFormVar(fname, name, text2num(value))
					if("reincarnation_recovery") setFormVar(fname, name, text2num(value))
					if("melee_power") setFormVar(fname, name, text2num(value))
					if("ki_power") setFormVar(fname, name, text2num(value))
					if("max_buff_bp") setFormVar(fname, name, text2num(value))
					if("global_stun_mod") setFormVar(fname, name, text2num(value))
					if("God_FistMod") setFormVar(fname, name, text2num(value))
					if("knockback_mod") setFormVar(fname, name, text2num(value))
					if("demon_hell_boost") setFormVar(fname, name, text2num(value))
					if("kai_heaven_boost") setFormVar(fname, name, text2num(value))
					if("dead_power_loss") setFormVar(fname, name, text2num(value))
					if("keep_body_loss") setFormVar(fname, name, text2num(value))
					if("hakai_cooldown") setFormVar(fname, name, text2num(value))
					if("hakai_bp_advantage_needed") setFormVar(fname, name, text2num(value))
					if("BASE_MOVE_DELAY") setFormVar(fname, name, text2num(value))
					if("planet_destroy_immunity_time") setFormVar(fname, name, text2num(value))
					if("planet_destroy_bp_requirement") setFormVar(fname, name, text2num(value))


		FormSetTempVars(fname)
			var/mob/M = src.getHost()
			if(fname == "admin")
				M << "Applying variable changes."
				if(Admins[M.key]>=4)
					hide_energy_enabled= getFormVar("admin", "hide_energy_enabled")
					allow_god_ki= getFormVar("admin", "allow_god_ki")
					stun_stops_movement= getFormVar("admin", "stun_stops_movement")
					shockwaves_off= getFormVar("admin", "shockwaves_off")
					explosions_off= getFormVar("admin", "explosions_off")
					dust_off= getFormVar("admin", "dust_off")
					allow_ultra_instinct= getFormVar("admin", "allow_ultra_instinct")
					force_32_pix_movement= getFormVar("admin", "force_32_pix_movement")
					allow_dragon_rush= getFormVar("admin", "allow_dragon_rush")
					lower_stats_off= getFormVar("admin", "lower_stats_off")
					limit_bind= getFormVar("admin", "limit_bind")
					can_cyber_KOd_people= getFormVar("admin", "can_cyber_KOd_people")
					custom_buffs_allowed= getFormVar("admin", "custom_buffs_allowed")
					can_ignore_SI= getFormVar("admin", "can_ignore_SI")
					allow_diagonal_movement= getFormVar("admin", "allow_diagonal_movement")
					forced_injections= getFormVar("admin", "forced_injections")
					Perma_Death= getFormVar("admin", "Perma_Death")
					Ki_Disabled= getFormVar("admin", "Ki_Disabled")
					hakai_wipes_character= getFormVar("admin", "hakai_wipes_character")
					death_setting= getFormVar("admin", "death_setting")
					Server_Regeneration= getFormVar("admin", "Server_Regeneration")
					Server_Recovery= getFormVar("admin", "Server_Recovery")
					KO_Time= getFormVar("admin", "KO_Time")
					reincarnation_loss= getFormVar("admin", "reincarnation_loss")
					reincarnation_recovery= getFormVar("admin", "reincarnation_recovery")
					melee_power= getFormVar("admin", "melee_power")
					ki_power= getFormVar("admin", "ki_power")
					max_buff_bp= getFormVar("admin", "max_buff_bp")
					global_stun_mod= getFormVar("admin", "global_stun_mod")
					God_FistMod= getFormVar("admin", "God_FistMod")
					knockback_mod= getFormVar("admin", "knockback_mod")
					demon_hell_boost= getFormVar("admin", "demon_hell_boost")
					kai_heaven_boost= getFormVar("admin", "kai_heaven_boost")
					dead_power_loss= getFormVar("admin", "dead_power_loss")
					keep_body_loss= getFormVar("admin", "keep_body_loss")
					hakai_cooldown= getFormVar("admin", "hakai_cooldown")
					hakai_bp_advantage_needed= getFormVar("admin", "hakai_bp_advantage_needed")
					BASE_MOVE_DELAY= getFormVar("admin", "BASE_MOVE_DELAY")
					planet_destroy_immunity_time= getFormVar("admin", "planet_destroy_immunity_time")
					planet_destroy_bp_requirement= getFormVar("admin", "planet_destroy_bp_requirement")


		FormSubmitSuccess(fname, client/C)
			if(fname == "admin")
				if(upForm(C, C.mob, /upForm/admin_panel))
					del(src)

		GenerateBody(list/errors=list())
			var/mob/M = src.getHost()
			if(errors.len>1)
				for(var/A in errors)
					M << "Error: [A]"
			var/page = {"
			<form name="info" action="byond://" method="get">
			  <input type="hidden" name="src" value="\ref[src]" />
			  <input type="hidden" name="form" value="admin" />

			  <table width="100%" height="100%" border="0">
			  <tr height="12px"><td colspan="4">
			    <table width="100%" height="100%" border="0">
			    <tr>
			      <td width="60%"><b>Combat Settings</b></td>
			      <td width="40%" align="right">
			      	<a href="byond://?src=\ref[src]&action=menu">\[Menu\]</a>
			        <a href="byond://?src=\ref[src]&action=close">\[Close\]</a>
			      </td>
			    </tr>
			    <tr><td colspan="2"><hr /></td></tr>
			    </table>
			  </tr></td>
				<tr height="1em" valign="top"><td width="30%"><b>Hide Energy Toggle: <td width="60%"><center>(0=Off, 1=On)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="hide_energy_enabled" value="[getFormVar("admin","hide_energy_enabled")]" size="3" maxlength="1"/><span class="error">[errors["hide_energy_enabled"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>God Ki Toggle: <td width="60%"><center>(0=Off, 1=On)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="allow_god_ki" value="[getFormVar("admin","allow_god_ki")]" size="3" maxlength="1"/><span class="error">[errors["allow_god_ki"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Stun Stops Movement: <td width="60%"><center>(0=No, 1=Yes)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="stun_stops_movement" value="[getFormVar("admin","stun_stops_movement")]" size="3" maxlength="1"/><span class="error">[errors["stun_stops_movement"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Disable Shockwaves: <td width="60%"><center>(0=On, 1=Off)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="shockwaves_off" value="[getFormVar("admin","shockwaves_off")]" size="3" maxlength="1"/><span class="error">[errors["shockwaves_off"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Disable Explosions: <td width="60%"><center>(0=On, 1=Off)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="explosions_off" value="[getFormVar("admin","explosions_off")]" size="3" maxlength="1"/><span class="error">[errors["explosions_off"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Disable Dust: <td width="60%"><center>(0=On, 1=Off)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="dust_off" value="[getFormVar("admin","dust_off")]" size="3" maxlength="1"/><span class="error">[errors["dust_off"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Allow Ultra Instinct: <td width="60%"><center>(0=Off, 1=On)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="allow_ultra_instinct" value="[getFormVar("admin","allow_ultra_instinct")]" size="3" maxlength="1"/><span class="error">[errors["allow_ultra_instinct"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Force 32px Movement: <td width="60%"><center>(0=Off, 1=On)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="force_32_pix_movement" value="[getFormVar("admin","force_32_pix_movement")]" size="3" maxlength="1"/><span class="error">[errors["force_32_pix_movement"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Allow Dragon Rush: <td width="60%"><center>(0=Off, 1=On)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="allow_dragon_rush" value="[getFormVar("admin","allow_dragon_rush")]" size="3" maxlength="1"/><span class="error">[errors["allow_dragon_rush"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Disable Stat Lowering: <td width="60%"><center>(0=On, 1=Off)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="lower_stats_off" value="[getFormVar("admin","lower_stats_off")]" size="3" maxlength="1"/><span class="error">[errors["lower_stats_off"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Bind Limit: <td width="60%"><center>(0=No Limit, 1=Limit)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="limit_bind" value="[getFormVar("admin","limit_bind")]" size="3" maxlength="1"/><span class="error">[errors["limit_bind"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Force Cyber BP on KOd: <td width="60%"><center>(0=Disallowed, 1=Allowed)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="can_cyber_KOd_people" value="[getFormVar("admin","can_cyber_KOd_people")]" size="3" maxlength="1"/><span class="error">[errors["can_cyber_KOd_people"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Allow Custom Buffs: <td width="60%"><center>(0=Off, 1=On)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="custom_buffs_allowed" value="[getFormVar("admin","custom_buffs_allowed")]" size="3" maxlength="1"/><span class="error">[errors["custom_buffs_allowed"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Enable Ignore SI: <td width="60%"><center>(0=Off, 1=On)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="can_ignore_SI" value="[getFormVar("admin","can_ignore_SI")]" size="3" maxlength="1"/><span class="error">[errors["can_ignore_SI"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Diagonal Movement: <td width="60%"><center>(0=Off, 1=On)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="allow_diagonal_movement" value="[getFormVar("admin","allow_diagonal_movement")]" size="3" maxlength="1"/><span class="error">[errors["allow_diagonal_movement"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Forced Injections: <td width="60%"><center>(0=Off, 1=On)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="forced_injections" value="[getFormVar("admin","forced_injections")]" size="3" maxlength="1"/><span class="error">[errors["forced_injections"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Perma-Death: <td width="60%"><center>(0=Off, 1=On)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="Perma_Death" value="[getFormVar("admin","Perma_Death")]" size="3" maxlength="1"/><span class="error">[errors["Perma_Death"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Disable Ki: <td width="60%"><center>(0=On, 1=Off)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="Ki_Disabled" value="[getFormVar("admin","Ki_Disabled")]" size="3" maxlength="1"/><span class="error">[errors["Ki_Disabled"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Hakai Wipes Save: <td width="60%"><center>(0=Off, 1=On)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="hakai_wipes_character" value="[getFormVar("admin","hakai_wipes_character")]" size="3" maxlength="1"/><span class="error">[errors["hakai_wipes_character"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Death Setting:<td width="60%"><center>(Changes Death Mode)</center></td></b></td><td width="10%" colspan="3"><select class="form" name="death_setting" value="[getFormVar("admin","death_setting")]" size="3" /><option value="default">Default</option><option value="Rebirth upon death">Auto Reincarnate</option></select><span class="error">[errors["death_setting"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Server Regeneration: <td width="60%"><center>(Changes Server Regeneration)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="Server_Regeneration" value="[getFormVar("admin","Server_Regeneration")]" size="3" maxlength="20"/><span class="error">[errors["Server_Regeneration"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Server Recovery: <td width="60%"><center>(Changes Server Recovery)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="Server_Recovery" value="[getFormVar("admin","Server_Recovery")]" size="3" maxlength="20"/><span class="error">[errors["Server_Recovery"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>KO Time Multiplier: <td width="60%"><center>(1x Timer = 80 Seconds w/ 1x Regen)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="KO_Time" value="[getFormVar("admin","KO_Time")]" size="3" maxlength="20"/><span class="error">[errors["KO_Time"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Reincarnation BP Retention Ratio: <td width="60%"><center>(0.01 = 1% Retention, 1=100% Retention)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="reincarnation_loss" value="[getFormVar("admin","reincarnation_loss")]" size="3" maxlength="20"/><span class="error">[errors["reincarnation_loss"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Reincarnation BP Recovery: <td width="60%"><center>(Multiplies rate at which you regain BP after Reincarnation)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="reincarnation_recovery" value="[getFormVar("admin","reincarnation_recovery")]" size="3" maxlength="20"/><span class="error">[errors["reincarnation_recovery"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Melee Power: <td width="60%"><center>(Melee Damage Multiplier)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="melee_power" value="[getFormVar("admin","melee_power")]" size="3" maxlength="20"/><span class="error">[errors["melee_power"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Ki Power: <td width="60%"><center>(Ki Damage Multiplier)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="ki_power" value="[getFormVar("admin","ki_power")]" size="3" maxlength="20"/><span class="error">[errors["ki_power"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Max Custom Buff BP Multi: <td width="60%"><center>(Limit of max multiplier for BP setting in Buffs)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="max_buff_bp" value="[getFormVar("admin","max_buff_bp")]" size="3" maxlength="20"/><span class="error">[errors["max_buff_bp"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Stun Time Multiplier: <td width="60%"><center>(Multiplies Stun Duration)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="global_stun_mod" value="[getFormVar("admin","global_stun_mod")]" size="3" maxlength="20"/><span class="error">[errors["global_stun_mod"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>God-Fist Damage Multiplier: <td width="60%"><center>(Changes God-Fist Damage)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="God_FistMod" value="[getFormVar("admin","God_FistMod")]" size="3" maxlength="20"/><span class="error">[errors["God_FistMod"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Knockback Multiplier: <td width="60%"><center>(Changes Knockback Mod)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="knockback_mod" value="[getFormVar("admin","knockback_mod")]" size="3" maxlength="20"/><span class="error">[errors["knockback_mod"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Demon Boost in Hell: <td width="60%"><center>(BP Multiplier for Demons in Hell)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="demon_hell_boost" value="[getFormVar("admin","demon_hell_boost")]" size="3" maxlength="20"/><span class="error">[errors["demon_hell_boost"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Kai Boost in Heaven: <td width="60%"><center>(BP Multiplier for Kais in Heaven)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="kai_heaven_boost" value="[getFormVar("admin","kai_heaven_boost")]" size="3" maxlength="20"/><span class="error">[errors["kai_heaven_boost"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Dead BP Retention Ratio: <td width="60%"><center>(0.5 = 50% Power, 1=100% Power)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="dead_power_loss" value="[getFormVar("admin","dead_power_loss")]" size="3" maxlength="20"/><span class="error">[errors["dead_power_loss"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Keep Body BP Retention Ratio: <td width="60%"><center>(0.5 = 50% Power, 1=100% Power)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="keep_body_loss" value="[getFormVar("admin","keep_body_loss")]" size="3" maxlength="20"/><span class="error">[errors["keep_body_loss"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Hakai Cooldown: <td width="60%"><center>(300 = 30 Seconds, 10 = 1 Second)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="hakai_cooldown" value="[getFormVar("admin","hakai_cooldown")]" size="3" maxlength="20"/><span class="error">[errors["hakai_cooldown"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Hakai BP Requirement: <td width="60%"><center>(2.2 = 2.2x Target's BP Required)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="hakai_bp_advantage_needed" value="[getFormVar("admin","hakai_bp_advantage_needed")]" size="3" maxlength="20"/><span class="error">[errors["hakai_bp_advantage_needed"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Base Movement Delay: <td width="60%"><center>(Changes Base Move Delay)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="BASE_MOVE_DELAY" value="[getFormVar("admin","BASE_MOVE_DELAY")]" size="3" maxlength="20"/><span class="error">[errors["BASE_MOVE_DELAY"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Planet Destroy Immunity Timer: <td width="60%"><center>(Changes Planet Destroy Immunity Time)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="planet_destroy_immunity_time" value="[getFormVar("admin","planet_destroy_immunity_time")]" size="3" maxlength="20"/><span class="error">[errors["planet_destroy_immunity_time"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Planet Destroy BP Requirement: <td width="60%"><center>(Changes Planet Destroy Bp Requirement)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="planet_destroy_bp_requirement" value="[getFormVar("admin","planet_destroy_bp_requirement")]" size="3" maxlength="20"/><span class="error">[errors["planet_destroy_bp_requirement"]]</span></td></tr>

		  <tr height="1em">
			  	<td colspan="4" align="right"> <input type="submit" value="Submit" />
			  	<input type="reset" value="Reset" /> </td>
			  </tr>
			  </table>
			</form>
			"}
			UpdatePage(page)

	admin_science
		window_title = "Races Panel"
		window_size = "700x600"
		settings = UPFORM_SET_HANDLE_FORMS
		form_type = UPFORM_WINDOW
		page_css = {"
			body { background-color: #d0d0d0 }
			.tr.
			.form { width: 100% }
			span.error { color: #ff0000; font-size: 10pt }
		"}

		Link(list/href_list, client/C)
			var/mob/M = src.getHost()
			var/action = href_list["action"]
			switch(action)
				if("close")
					del(src)
				if("illegal")
					M.Illegal_Science()
				if("menu")
					if(C.mob == M)
						if(upForm(C, C.mob, /upForm/admin_panel))
							del(src)

		canDisplayForm(client/C)
			. = ..()
			if(C.upForm_isViewingForm(src.type))
				. = 0

		FormInitTempVars()
			var/mob/M=src.getHost()
			M << "Loading form variables. [src.type]"
			initFormVar("admin", "drone_genocide_off", drone_genocide_off)
			initFormVar("admin", "death_cures_vampires", death_cures_vampires)
			initFormVar("admin", "customBuildAllowed", customBuildAllowed)
			initFormVar("admin", "toxic_waste_on", toxic_waste_on)
			initFormVar("admin", "Max_Zombies", Max_Zombies)
			initFormVar("admin", "max_gravity", max_gravity)
			initFormVar("admin", "cyber_bp_mod", cyber_bp_mod)
			initFormVar("admin", "percent_of_wall_breakers", percent_of_wall_breakers)
			initFormVar("admin", "wall_INT_scaling", wall_INT_scaling)
			initFormVar("admin", "minimum_bounty", minimum_bounty)
			initFormVar("admin", "knowledge_cap_mod", knowledge_cap_mod)
			initFormVar("admin", "zombie_power_mult", zombie_power_mult)
			initFormVar("admin", "drone_power", drone_power)
			initFormVar("admin", "building_price_mult", building_price_mult)
			initFormVar("admin", "checkpointBuildDist", checkpointBuildDist)
			initFormVar("admin", "drone_limit", drone_limit)
			initFormVar("admin", "body_swap_time_limit", body_swap_time_limit)
			initFormVar("admin", "Turf_Strength", Turf_Strength)
			initFormVar("admin", "max_turf_str", max_turf_str)
			initFormVar("admin", "zombie_reproduce_mod", zombie_reproduce_mod)
			initFormVar("admin", "Prison_Money", Prison_Money)
			initFormVar("admin", "Gun_Power", Gun_Power)
			M << "Variables loaded. [src.type]"

		ProcessVariable(fname, name, value)
			if(fname == "admin")
				var/mob/M=src.getHost()
				M << "Form: [fname] || Variable: [name] || Value: [value]"
				switch(name)
					if("drone_genocide_off") setFormVar(fname, name, text2num(value))
					if("death_cures_vampires") setFormVar(fname, name, text2num(value))
					if("customBuildAllowed") setFormVar(fname, name, text2num(value))
					if("toxic_waste_on") setFormVar(fname, name, text2num(value))
					if("Max_Zombies") setFormVar(fname, name, text2num(value))
					if("max_gravity") setFormVar(fname, name, text2num(value))
					if("cyber_bp_mod") setFormVar(fname, name, text2num(value))
					if("percent_of_wall_breakers") setFormVar(fname, name, text2num(value))
					if("wall_INT_scaling") setFormVar(fname, name, text2num(value))
					if("minimum_bounty") setFormVar(fname, name, text2num(value))
					if("knowledge_cap_mod") setFormVar(fname, name, text2num(value))
					if("zombie_power_mult") setFormVar(fname, name, text2num(value))
					if("drone_power") setFormVar(fname, name, text2num(value))
					if("building_price_mult") setFormVar(fname, name, text2num(value))
					if("checkpointBuildDist") setFormVar(fname, name, text2num(value))
					if("drone_limit") setFormVar(fname, name, text2num(value))
					if("body_swap_time_limit") setFormVar(fname, name, text2num(value))
					if("Turf_Strength") setFormVar(fname, name, text2num(value))
					if("max_turf_str") setFormVar(fname, name, text2num(value))
					if("zombie_reproduce_mod") setFormVar(fname, name, text2num(value))
					if("Prison_Money") setFormVar(fname, name, text2num(value))
					if("Gun_Power") setFormVar(fname, name, text2num(value))


		FormSetTempVars(fname)
			var/mob/M = src.getHost()
			if(fname == "admin")
				M << "Applying variable changes."
				if(Admins[M.key]>=4)
					drone_genocide_off= getFormVar("admin", "drone_genocide_off")
					death_cures_vampires= getFormVar("admin", "death_cures_vampires")
					customBuildAllowed= getFormVar("admin", "customBuildAllowed")
					toxic_waste_on= getFormVar("admin", "toxic_waste_on")
					Max_Zombies= getFormVar("admin", "Max_Zombies")
					max_gravity= getFormVar("admin", "max_gravity")
					cyber_bp_mod= getFormVar("admin", "cyber_bp_mod")
					percent_of_wall_breakers= getFormVar("admin", "percent_of_wall_breakers")
					wall_INT_scaling= getFormVar("admin", "wall_INT_scaling")
					minimum_bounty= getFormVar("admin", "minimum_bounty")
					knowledge_cap_mod= getFormVar("admin", "knowledge_cap_mod")
					zombie_power_mult= getFormVar("admin", "zombie_power_mult")
					drone_power= getFormVar("admin", "drone_power")
					building_price_mult= getFormVar("admin", "building_price_mult")
					checkpointBuildDist= getFormVar("admin", "checkpointBuildDist")
					drone_limit= getFormVar("admin", "drone_limit")
					body_swap_time_limit= getFormVar("admin", "body_swap_time_limit")
					Turf_Strength= getFormVar("admin", "Turf_Strength")
					max_turf_str= getFormVar("admin", "max_turf_str")
					zombie_reproduce_mod= getFormVar("admin", "zombie_reproduce_mod")
					Prison_Money= getFormVar("admin", "Prison_Money")
					Gun_Power= getFormVar("admin", "Gun_Power")


		FormSubmitSuccess(fname, client/C)
			if(fname == "admin")
				if(upForm(C, C.mob, /upForm/admin_panel))
					del(src)

		GenerateBody(list/errors=list())
			var/mob/M = src.getHost()
			if(errors.len>1)
				for(var/A in errors)
					M << "Error: [A]"
			var/page = {"
			<form name="info" action="byond://" method="get">
			  <input type="hidden" name="src" value="\ref[src]" />
			  <input type="hidden" name="form" value="admin" />

			  <table width="100%" height="100%" border="0">
			  <tr height="12px"><td colspan="4">
			    <table width="100%" height="100%" border="0">
			    <tr>
			      <td width="30%"><b>Race Settings</b></td>
			      <td width="70%" align="right">
			      	<a href="byond://?src=\ref[src]&action=menu">\[Menu\]</a>
			      	<a href="byond://?src=\ref[src]&action=illegal">\[Illegal Science\]</a>
			        <a href="byond://?src=\ref[src]&action=close">\[Close\]</a>
			      </td>
			    </tr>
			    <tr><td colspan="2"><hr /></td></tr>
			    </table>
			  </tr></td>
				<tr height="1em" valign="top"><td width="30%"><b>drone_genocide_off: <td width="60%"><center>(Toggles Drone Genocide Off)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="drone_genocide_off" value="[getFormVar("admin","drone_genocide_off")]" size="3" maxlength="1"/><span class="error">[errors["drone_genocide_off"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>death_cures_vampires: <td width="60%"><center>(Toggles Death Cures Vampires)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="death_cures_vampires" value="[getFormVar("admin","death_cures_vampires")]" size="3" maxlength="1"/><span class="error">[errors["death_cures_vampires"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>customBuildAllowed: <td width="60%"><center>(Toggles Custombuildallowed)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="customBuildAllowed" value="[getFormVar("admin","customBuildAllowed")]" size="3" maxlength="1"/><span class="error">[errors["customBuildAllowed"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>toxic_waste_on: <td width="60%"><center>(Toggles Toxic Waste On)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="toxic_waste_on" value="[getFormVar("admin","toxic_waste_on")]" size="3" maxlength="1"/><span class="error">[errors["toxic_waste_on"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Max_Zombies: <td width="60%"><center>(Changes Max Zombies)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="Max_Zombies" value="[getFormVar("admin","Max_Zombies")]" size="3" maxlength="20"/><span class="error">[errors["Max_Zombies"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>max_gravity: <td width="60%"><center>(Changes Max Gravity)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="max_gravity" value="[getFormVar("admin","max_gravity")]" size="3" maxlength="20"/><span class="error">[errors["max_gravity"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>cyber_bp_mod: <td width="60%"><center>(Changes Cyber Bp Mod)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="cyber_bp_mod" value="[getFormVar("admin","cyber_bp_mod")]" size="3" maxlength="20"/><span class="error">[errors["cyber_bp_mod"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>percent_of_wall_breakers: <td width="60%"><center>(Changes Percent Of Wall Breakers)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="percent_of_wall_breakers" value="[getFormVar("admin","percent_of_wall_breakers")]" size="3" maxlength="20"/><span class="error">[errors["percent_of_wall_breakers"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>wall_INT_scaling: <td width="60%"><center>(Changes Wall Int Scaling)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="wall_INT_scaling" value="[getFormVar("admin","wall_INT_scaling")]" size="3" maxlength="20"/><span class="error">[errors["wall_INT_scaling"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>minimum_bounty: <td width="60%"><center>(Changes Minimum Bounty)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="minimum_bounty" value="[getFormVar("admin","minimum_bounty")]" size="3" maxlength="20"/><span class="error">[errors["minimum_bounty"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>knowledge_cap_mod: <td width="60%"><center>(Changes Knowledge Cap Mod)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="knowledge_cap_mod" value="[getFormVar("admin","knowledge_cap_mod")]" size="3" maxlength="20"/><span class="error">[errors["knowledge_cap_mod"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>zombie_power_mult: <td width="60%"><center>(Changes Zombie Power Mult)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="zombie_power_mult" value="[getFormVar("admin","zombie_power_mult")]" size="3" maxlength="20"/><span class="error">[errors["zombie_power_mult"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>drone_power: <td width="60%"><center>(Changes Drone Power)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="drone_power" value="[getFormVar("admin","drone_power")]" size="3" maxlength="20"/><span class="error">[errors["drone_power"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>building_price_mult: <td width="60%"><center>(Changes Building Price Mult)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="building_price_mult" value="[getFormVar("admin","building_price_mult")]" size="3" maxlength="20"/><span class="error">[errors["building_price_mult"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>checkpointBuildDist: <td width="60%"><center>(Changes Checkpointbuilddist)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="checkpointBuildDist" value="[getFormVar("admin","checkpointBuildDist")]" size="3" maxlength="20"/><span class="error">[errors["checkpointBuildDist"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>drone_limit: <td width="60%"><center>(Changes Drone Limit)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="drone_limit" value="[getFormVar("admin","drone_limit")]" size="3" maxlength="20"/><span class="error">[errors["drone_limit"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>body_swap_time_limit: <td width="60%"><center>(Changes Body Swap Time Limit)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="body_swap_time_limit" value="[getFormVar("admin","body_swap_time_limit")]" size="3" maxlength="20"/><span class="error">[errors["body_swap_time_limit"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Turf_Strength: <td width="60%"><center>(Changes Turf Strength)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="Turf_Strength" value="[getFormVar("admin","Turf_Strength")]" size="3" maxlength="20"/><span class="error">[errors["Turf_Strength"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>max_turf_str: <td width="60%"><center>(Changes Max Turf Str)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="max_turf_str" value="[getFormVar("admin","max_turf_str")]" size="3" maxlength="20"/><span class="error">[errors["max_turf_str"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>zombie_reproduce_mod: <td width="60%"><center>(Changes Zombie Reproduce Mod)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="zombie_reproduce_mod" value="[getFormVar("admin","zombie_reproduce_mod")]" size="3" maxlength="20"/><span class="error">[errors["zombie_reproduce_mod"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Prison_Money: <td width="60%"><center>(Changes Prison Money)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="Prison_Money" value="[getFormVar("admin","Prison_Money")]" size="3" maxlength="20"/><span class="error">[errors["Prison_Money"]]</span></td></tr>
				<tr height="1em" valign="top"><td width="30%"><b>Gun_Power: <td width="60%"><center>(Changes Gun Power)</center></td></b></td><td width="10%" colspan="3"><input class="form" type="text" name="Gun_Power" value="[getFormVar("admin","Gun_Power")]" size="3" maxlength="20"/><span class="error">[errors["Gun_Power"]]</span></td></tr>

		  <tr height="1em">
			  	<td colspan="4" align="right"> <input type="submit" value="Submit" />
			  	<input type="reset" value="Reset" /> </td>
			  </tr>
			  </table>
			</form>
			"}
			UpdatePage(page)
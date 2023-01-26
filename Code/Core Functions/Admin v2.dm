proc/isboolean(test as num)
	if(test==0) return 1
	if(test==1) return 1
	if(test!=1&&test!=0) return 0

upForm/global_css = " body, table { font-family: Verdana; font-size: 10pt } "

var/upForm/playerlist

upForm
	viewinfo
		window_title = "Player Info"
		window_size = "700x600"
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
				M.Age = Math.Max(getFormVar("info", "age"), M.incline_age * 0.8)
				M.real_age = M.Age
				M.BirthYear = GetGlobalYear() - M.Age
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
						if(length(value) > 1200)
							return "Description too long!"

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
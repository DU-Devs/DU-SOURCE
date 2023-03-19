proc
	Initialise_Race(mob/M, T)
		if(!M.client) return
		if(!M) return
		if(!T) return
		if(!T in Illegal_Races)
			switch(T)

upForm
	race_options
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
				. = 0f

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
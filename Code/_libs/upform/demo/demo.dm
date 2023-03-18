
upForm/global_css = " body, table { font-family: Verdana; font-size: 10pt } "

var/upForm/playerlist

world
	New()
		..()
		playerlist = upForm(null, /upForm/playerlist)
	Del()
		del(playerlist)
		..()

mob
	icon = 'stickman.dmi'
	desc = "I have not entered a description"
	var
		age = 18

	Login()
		..()

		var/icon/I = new /icon (src.icon)
		I.SwapColor("#FFFFFF", rgb(rand(0,255),rand(0,255),rand(0,255)))
		src.icon = I

		src << browse("<style>body { background-color: #d0d0d0 }</style>")

		playerlist.AddViewer(src.client)

		src.intro()

	Logout()
		playerlist.RemoveViewer(src.client)
		..()

	proc
		ViewInfo(mob/M)
			upForm(src, M, /upForm/viewinfo)

		EditInfo()
			upForm(src, null, /upForm/editinfo)

	verb
		intro()
			upForm(src, /upForm/intro)

		timed()
			if(!upForm(src, /upForm/timed))
				src << "This page can't be displayed because another form that is \
						being displayed to the default interface is still on the screen."

		default()
			if(!upForm(src, /upForm/default))
				src << "This page can't be displayed because another form that is \
						being displayed to the default interface is still on the screen."

// Form Definitions

upForm
	interface_bgstyle = "background-color: #d0d0d0"
	intro
		// A closewindow is a window designed to be Xed out by the viewers
		// The instance is deleted right after it displays the page to the viewers
		form_type = UPFORM_CLOSEWINDOW
		GenerateBody()
			var/page = {"
				<b>Welcome to FormLand</b> <br />
				<br />
				This demo world is meant to demonstrate the functions of the
				upForm library.  It shows concepts commonly used with browser
				forms and demonstrates how it would be implemented in code
				using the library. <br />
				<br />
				This window is a window with the type of <tt>UPFORM_CLOSEWINDOW</tt>.  It
				exists for the purpose of displaying information that is
				free to be discarded (in this case, closed) at any point
				without needing any links to close the form.
			"}

			UpdatePage(page)


	timed
		time_left = 50
		time_update = 1

		GenerateBody()
			UpdatePage("This page will close in [time_left / 10] seconds <br />\
						<br /> \
						You also may notice after the time runs out that the interface \
						will go dark grey because of what was supplied for <tt>interface_bgstyle</tt>.")

	default
		Link(list/href_list)
			if(href_list["action"] == "close")
				del(src)

		GenerateBody()
			UpdatePage("This form was displayed to the default browser form, which is \
						on the interface.  By default, a form will display to the default \
						browser interface if a <tt>form_type</tt> is not specified. <br /> \
						<br /> \
						This form is also manually closed by a link.  <tt>Link()</tt> is  \
						implemented in the form to catch the link that is specified to \
						delete the form.  See for yourself! <br />\
						<br /> \
						<a href=\"byond://?src=\ref[src]&action=close\">\[Close\]</a>")

	playerlist
		form_name = "playerlist"
		form_type = UPFORM_INTERFACE
		settings = UPFORM_SET_RELOAD_ON_VIEWER_UPDATE | UPFORM_SET_GLOBAL
		page_css = {"
			body { background-color: #d0d0d0 }
			table { width: 100%; border: 1px solid #aaaaaa;
			  border-collapse: collapse; cellspacing: 10px }
		"}

		Link(list/href_list, client/C)
			if(href_list["action"] == "info")
				var/client/target = locate(href_list["target"])
				if(isViewer(target))
					var/mob/M = C.mob
					M.ViewInfo(target.mob)

		GenerateBody()
			var/playertext = ""
			var/page = ""

			for(var/client/C in src.viewers)
				playertext += {"
					<tr style="background-color: [src.viewers.Find(C) % 2 ? "#cccccc" : "#c0c0c0"];">
					  <td><a href="byond://?src=\ref[src]&action=info&target=\ref[C]">[C.mob.name]</a> ([C.key])</td>
					</tr>
				"}

			page = {"
				<b>Players Online:</b>
				<hr />
				<table>[playertext]</table>
				<br />
				This player list is a global interface that updates when a new player joins.
				The player is added when the client logs in, so it will know when to update. <br />
				<br />
				Click the player's name to view the player's statistics.
			"}

			UpdatePage(page)


	viewinfo
		window_title = "Player Info"
		window_size = "300x220"
		window_params = UPFORM_CANNOT_RESIZE
		form_type = UPFORM_WINDOW
		page_css = "body { background-color: #d0d0d0 }"

		Link(list/href_list, client/C)
			var/mob/M = src.getHost()
			var/action = href_list["action"]
			switch(action)
				if("close")
					del(src)
				if("edit")
					if(C.mob == M)
						if(upForm(C, C.mob, /upForm/editinfo))
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
			    <b>Age:</b>    [M.age] <br />
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

	editinfo
		window_title = "Edit Info"
		window_size = "350x300"
		window_params = UPFORM_CANNOT_RESIZE
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
			initFormVar("info", "name", M.name)
			initFormVar("info", "age", M.age)
			initFormVar("info", "gender", M.gender)
			initFormVar("info", "desc", M.desc)

		FormSetTempVars(fname)
			var/mob/M = src.getHost()
			if(fname == "info")
				M.name = getFormVar("info", "name")
				M.age = Math.Max(getFormVar("info", "age"), M.incline_age)
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
				upForm_UpdateForms(playerlist)
				if(upForm(C, C.mob, /upForm/viewinfo))
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
			    <td width="20%"> <b>Age:</b> </td>
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



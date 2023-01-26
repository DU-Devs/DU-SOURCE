
/*

	upForm
	======
	*By: Wen-Hao Lue*

	upForm is a library for the DM Programming Language that handles a variety of
	HTML interfaces through the datum `/upForm`. Common functionality between
	forms are all defined for you, and the library maintains a set of critical and
	useful features while being easily extendable.

	### Feature List
	* Declare new interfaces by defining a child of the /upForm datum, and display it
	  by simply calling `upForm()`
	* Handles BYOND 4.0 browser control interfaces, and windows
	* Easy definition of CSS and JavaScript code
	* Handles multiple viewers at the same time
	* Handles predefined and dynamic resources
	* Easy implementation of HTML forms
	* Contains basic time-keeping functions

	## Example Usage

		upForm/helloworld
		  GenerateBody()
		    UpdatePage("Hello")

		mob/Login()
			..()
			upForm(src, /upForm/helloworld)

	## Release History

	Version 1.0 (January 21st, 2008)
	- Library released

	Version 1.1 (January 22nd, 2008)
	- Fixed demo errors, and added more comments to demo code (Gughunter)
	- Documentation proofread for accuracy (Gughunter)

	Version 1.2 (March 21st, 2008)
	- Fixed demo interface anchor for text box, and modified demo code
	- Removed unneccessary assertion text being sent to the default
	   output interface (old testing code)
	- Renamed javascript functions for quick linking to be shorter (all links
	  are now prefixed with 'upF_' rather than 'upForm_')
	- Added new javascript function `upF_sAction()`, which allows a link to be sent
	  with an action and value param

	Version 1.3 (May 17th, 2008)
	- `upForm_formatViewerList()` was not completly formatting all objects
	  in the list

	------------------------------------------------------------------------------------

	The MIT Licence

	Copyright (C) 2008-2011 by Wen-Hao Lue

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	THE SOFTWARE.

	------------------------------------------------------------------------------------
*/

#define upForm_ERROR(msg) CRASH("upForm assertion: " + msg)
#define UPFORM_VERSION "1.3"

client
	var
		list/upForms = list()	// list of active forms

	Del()
		for(var/upForm/F in src.upForms)
			F.RemoveViewer(src)
		..()

	proc
		upForm_isViewingForm(form)
			if(istype(form, /upForm)) // form is an instance
				return (form in src.upForms)
			// form may be tag text, or path.  otherwise, return 0 anyway if neither
			return (locate(form) in src.upForms) ? TRUE : FALSE

proc
	upForm_isValidHost(datum/host)
		// is this a valid host?  hosts may be any datum, but not a form
		return istype(host, /datum)

	upForm_isValidFormPath(path)
		// is this a valid path for a form?
		return (path in typesof(/upForm))

	upForm_getClientTarget(_target)
		// returns the client of a mob, or null if non-existant
		var/mob/target = _target
		if(istype(target, /client))
			return target
		return ismob(target) ? target.client : null

	upForm_formatViewerList(list/viewers)
		// modifies a given list to convert any mobs into clients
		// returns 0 if an invalid item was found in the list, otherwise 1
		for(var/i=1, i<=length(viewers), i++)
			viewers[i] = upForm_getClientTarget(viewers[i])
			if(!viewers[i]) return 0
		return 1

	upForm_UpdateForms(form)
		// Regenerates the form instance, or all forms of the type
		// Arg can be an instance, a string (tag), or a path
		var/upForm/F
		if(istype(form, /upForm))
			F = form
			F.RefreshPage()
		else if(istext(form))
			F = locate(form)
			if(F) F.RefreshPage()
		else if(ispath(form))
			for(F)
				if(F.type == form)
					F.RefreshPage()
		else
			upForm_ERROR("Invalid arg type")

	upForm(arg1, arg2, arg3, arg4)

		// Cases:
		// upForm(target, form_path)
		// upForm(target, form_path, tag)
		// upForm(target, host, form_path)
		// upForm(target, host, form_path, tag)
		// target may be either a client/mob, or a list of clients/mobs

		if(length(args) != 2 && length(args) != 3 && length(args) != 4)
			upForm_ERROR("Invalid amount of arguments passed through upForm()")

		var/client/owner = null
		var/datum/host = null
		var/list/viewers = null
		var/form_path
		var/form_tag = ""

		if(!arg1 || istype(arg1, /list))
			viewers = arg1
			if(istype(viewers, /list))
				if(!upForm_formatViewerList(viewers))
					upForm_ERROR("Form target may only contain instances of /mob or /client")
		else
			owner = upForm_getClientTarget(arg1)
			if(!owner)
				upForm_ERROR("Invalid target type")
			viewers = list(owner)

		if(ispath(arg2))
			if(!upForm_isValidFormPath(arg2))
				upForm_ERROR("Invalid form path ([arg2])")

			form_path = arg2

			if(istext(arg3))
				form_tag = arg3
		else
			if(!upForm_isValidFormPath(arg3))
				upForm_ERROR("Invalid form path ([arg2])")

			host = arg2
			form_path = arg3

			if(istext(arg4))
				form_tag = arg4

		var/upForm/F = new form_path (owner, host, viewers)
		if(F) F.tag = form_tag
		return F

// constants
var/const
	// form types
	UPFORM_BROWSER 		= 0		// output of browser interface sent to default browser control
	UPFORM_INTERFACE 	= 1		// sent to specified browser control (named form_type)
	UPFORM_WINDOW 		= 2		// sent as popup window (named form_type).
	UPFORM_CLOSEWINDOW	= 3		// to take into consideration the fact that popup windows cannot be tracked when
								// Xed out manually, links are ignored, and object is deleted instantly after page is sent
	// form setting flags
	UPFORM_SET_HANDLE_FORMS				= 1		// form object should handle the supported form functions only if flag is set
	UPFORM_SET_GLOBAL					= 2		// the form is global/shared and therefore should not be deleted when the viewers list is empty
	UPFORM_SET_RELOAD_ON_VIEWER_UPDATE 	= 4		// the form's body should be regenerated when a viewer has been added or removed
	UPFORM_SET_SELF_REFERENCE 			= 16	// self reference the form so it won't be deleted by the garbage collector if unreferenced

	// form window param flags
	UPFORM_CANNOT_CLOSE	 	= 1
	UPFORM_CANNOT_RESIZE 	= 2
	UPFORM_CANNOT_MINIMIZE 	= 4
	UPFORM_NO_TITLEBAR 		= 8

upForm/var
	global_css = "" // to be redefined if necessary

upForm
	var
		form_name = ""
		form_type = UPFORM_BROWSER
		settings = 0	// setting flags

		// only applicable when the page is sent as a window
		window_title = ""
		window_size = "300x300"
		window_params = 0

		page_css = ""
		page_js = ""
		interface_bgstyle = ""

		time_left = -1
		time_interval = 10
		time_update = 0

		list/form_vars
		list/resources

		// internal, do not directly modify
		client/owner
		datum/host
		list/viewers

		body = ""
		window_params_text = ""
		self
		predef_js

		global/refcount = 0
		refnum


	New(client/_owner, datum/_host, list/_viewers)
		..()

		refnum = ++refcount

		src.owner = _owner
		src.host = _host
		src.viewers = list()

		InitViewers(_viewers)
		InitSettings()
		InitPredefinedScript()
		InitTimer()

		RefreshPage()

		if(src.form_type == UPFORM_CLOSEWINDOW)
			del(src)

	Del()
		if(src.form_type != UPFORM_CLOSEWINDOW)
			ClosePages()
			for(var/client/C in src.viewers)
				C.upForms -= src

		..()

	Topic(href, list/href_list)
		// ensure a valid viewer is sending a link
		var/client/C = usr.client
		if(!isViewer(C)) return

		if(settings & UPFORM_SET_HANDLE_FORMS)
			src.HandleFormLinks(href_list, C)

		src.Link(href_list, C)

	proc
		getOwner()
			if(!src.owner)
				upForm_ERROR("Undefined owner")
			return src.owner

		getHost()
			return src.host

		// Viewer Handling

		InitViewers(list/viewer_list)

			if(istype(viewer_list, /list))

				for(var/client/C in viewer_list)
					if(canDisplayForm(C))
						SetViewer(C)

				if(!length(viewers))
					del(src)

		SetViewer(client/C)
			src.viewers += C
			InitResources(C)
			if(src.form_type != UPFORM_CLOSEWINDOW)
				C.upForms += src

		AddViewer(client/C)
			C = upForm_getClientTarget(C)
			if(!C || !canBeViewer(C)) return

			SetViewer(C)

			if(settings & UPFORM_SET_RELOAD_ON_VIEWER_UPDATE)
				RefreshPage()
			else
				DisplayBrowserText(src.body, C)

		RemoveViewer(client/C)
			C = upForm_getClientTarget(C)
			if(!C || !isViewer(C)) return

			src.viewers -= C
			C.upForms -= src
			RemovePage(C)

			if(!length(src.viewers) && !(settings & UPFORM_SET_GLOBAL))
				del(src)
			else
				if(settings & UPFORM_SET_RELOAD_ON_VIEWER_UPDATE)
					RefreshPage()

		// General

		isViewer(client/C) // is this client a current viewer?
			return (C in src.viewers)

		canBeViewer(client/C) // is this client capable of being a viewer
			return canDisplayForm(C)

		canDisplayForm(client/C)
			// can this form be displayed to a certain client?
			// may be overridable, and reimplemented for certain form's needs (ie. form only
			// allowed to open when another form is open)

			// form cannot be displayed if it is an interface, and another interface form with the
			// same form name is in the form list.  form also cannot be displayed if there is another
			// browser form that is being displayed

			if(src.form_type == UPFORM_INTERFACE || src.form_type == UPFORM_BROWSER)
				for(var/upForm/F in C.upForms)
					if((src.type == F.type) || \
					  (F.form_type == UPFORM_INTERFACE && src.form_name == F.form_name) || \
					  (F.form_type == UPFORM_BROWSER))
						return 0

			return 1

		InitSettings()

			if(src.settings & UPFORM_SET_SELF_REFERENCE)
				src.self = src

			if(src.settings & UPFORM_SET_HANDLE_FORMS)
				src.form_vars = list()
				FormInitTempVars()

			if(src.form_type >= UPFORM_WINDOW)
				if(!src.window_title)
					src.window_title = world.name

				if(src.form_type == UPFORM_WINDOW && !(src.window_params & UPFORM_NO_TITLEBAR))
					// regular windows may not be Xed out
					src.window_params |= UPFORM_CANNOT_CLOSE

				src.window_params_text = "window=[refnum]\ref[src]&size=[src.window_size]\
					[src.window_params & UPFORM_CANNOT_CLOSE 	? "&can_close=0" : ""]\
					[src.window_params & UPFORM_CANNOT_RESIZE 	? "&can_resize=0" : ""]\
					[src.window_params & UPFORM_CANNOT_MINIMIZE	? "&can_minimize=0" : ""]\
					[src.window_params & UPFORM_NO_TITLEBAR 	? "&titlebar=0" : ""]"

		InitPredefinedScript()
			src.predef_js = {"
function upF_sendData(data) {
  window.location="byond://?src=\ref[src]&"+data;
}
function upF_action(action) {
  window.location="byond://?src=\ref[src]&action="+action;
}
function upF_sAction(action, value) {
  window.location="byond://?src=\ref[src]&action="+action+"&value="+value;
}
function upF_send(name, value) {
  window.location="byond://?src=\ref[src]&name="+name+"&value="+value;
}
function upF_set(input) {
  window.location="byond://?src=\ref[src]&name="+input.name+"&value="+input.value;
}
function upF_check(input) {
  window.location="byond://?src=\ref[src]&name="+input.name+"&value="+input.checked;
}
			"}

		PreSettings()
			// called right before the page is displayed for the first time
			// overridable for the programmer to adjust any last-minute variables such as
			// window name


		// Time Handling

		hasTimeStarted()
			return (time_left > 0)

		InitTimer()
			if(hasTimeStarted())
				StartTimer(src.time_left)

		StartTimer(time)
			// Called when the time should be started
			// May be called at any time if the time hasn't already been started
			// Timer hasn't started when time_left < 0

//			if(!hasTimeStarted())
//				return

			spawn()
				src.time_left = time
				TimeStarted(time)

				while(src.time_left > 0)
					sleep(src.time_interval)
					src.time_left -= src.time_interval
					if(src.time_update) RefreshPage()

				src.time_left = -1
				TimeUp()

		TimeStarted(time)
			// Called when the timer has started

		TimeUp()
			// Called when time has reached zero
			// Closes form by default
			del(src)

		// Resource Handling

		SendResource(target, rsc, rsc_name)
			// send a resource to a specific target
			if(rsc_name)
				target << browse_rsc(rsc, rsc_name)
			else
				target << browse_rsc(rsc)

		LoadResource(rsc, rsc_name)
			// send new resource to all viewers
			SendResource(src.viewers, rsc, rsc_name)

		InitResources(target)
			// load initially defined resources to target
			if(!src.resources || !length(src.resources)) return
			if(!target) target = src.viewers
			for(var/rsc in src.resources)
				var/rsc_name = src.resources[rsc]
				SendResource(target, rsc, rsc_name)

		// Topic Handling

		Link(list/href_list, client/C)
			// called by Topic(), link sent and verified by C
			// write any functionality that will occur when a link is sent, given params as href_list

		// Form Handling

		isValidForm(fname)
			return (fname in form_vars)

		isValidFormVar(fname, fvar)
			return isValidForm(fname) && (fvar in form_vars[fname])

		getFormVar(fname, fvar)
			if(!isValidFormVar(fname, fvar))
				upForm_ERROR("Invalid form name and/or var (\"[fname]\",\"[fvar]\")")
			return form_vars[fname][fvar]

		setFormVar(fname, fvar, fval)
			if(!isValidFormVar(fname, fvar))
				upForm_ERROR("Invalid form name and/or var (\"[fname]\",\"[fvar]\")")
			form_vars[fname][fvar] = fval

		initFormVar(fname, fvar, fval)
			if(!isValidForm(fname))
				form_vars[fname] = list()
			form_vars[fname][fvar] = fval

		FormSubmitSuccess(fname, client/C)
			// Called when a form is successfully submitted by C
			RefreshPage()

		FormSubmitError(fname, list/errors, client/C)
			// Called when a form has been submitted, but failed verification
			RefreshPage(errors)

		FormInitTempVars()
			// Must be overridden if form support is used
			// Declare and set the form_vars list for all forms
			// Call initFormVar() for every form variable

			upForm_ERROR("FormInitTempVars() must be implemented when handling forms")

		FormSetTempVars(fname)
			// Must be overridden if form support is used
			// Called on submission success of form named fname
			// Set variables returned by getFormVar()

			upForm_ERROR("FormSetTempVars() must be implemented when handling forms")

		ProcessVariable(fname, name, value, client/C)
			// Sets a temp variable for a form using setFormVar().  Returns a text string of
			// the error message if there is a validation error, otherwise null if there are no errors.
			// Form was sent by C

			upForm_ERROR("ProcessVariable() must be implemented when handling forms")

		HandleFormLinks(list/params, client/C)
			if("form" in params)
				var/fname = params["form"]
				var/list/data = params.Copy(params.Find("form") + 1)
				var/errors = ProcessForm(fname, data, C) // process data

				if(istype(errors, /list) && length(errors))
					FormSubmitError(fname, errors, C)
				else
					FormSetTempVars(fname)
					FormSubmitSuccess(fname, C)

		ProcessForm(fname, list/params, client/C)
			// Processes a single form on the event the submit button was pressed by C
			var/list/errors = list()

			for(var/fvar in params) // loop through each name=value item individually
				var/alert = ProcessVariable(fname, fvar, params[fvar], C)
				if(alert) errors[fvar] = alert

			if(!length(errors))
				// send empty list on case of no errors
				return list()

			return errors

		// Page Handling

		GenerateBody(list/errors)
			// Must be implemented in children types, and call UpdagePage() with the generated body
			// If a form has been submitted with errors, a list will be sent through the param containing
			// a name=value associative list for each control with an error defined in the form

			upForm_ERROR("GenerateBody() must be implemented")


		RefreshPage(list/errors)
			GenerateBody(errors)
			DisplayPage()

		DisplayPage()
			DisplayBrowserText(src.body)

		RemovePage(client/C)
			// rid of the page for C
			if(src.form_type >= UPFORM_WINDOW)
				// interface is a window, send null
				DisplayBrowserText(null, C)
			else
				// interface type is embedded in the skin, send a blank page
				// players may want to customize the colour of the blank page send page with style data
				// as a background if it matches with the interface

				DisplayBrowserText("<html><head><meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" /><style type=\"text/css\">\
					body{[interface_bgstyle]}</style></head></html>", C)

		DisplayBrowserText(text, target)
			if(!target) target = src.viewers
			switch(src.form_type)
				if(UPFORM_BROWSER)
					target << browse(text)
				if(UPFORM_INTERFACE)
					target << output(text, src.form_name)
				if(UPFORM_WINDOW, UPFORM_CLOSEWINDOW)
					target << browse(text, src.window_params_text)

		UpdatePage(bodyText, jsText)
			src.body = \
			{"

<html>
<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
  [form_type >= UPFORM_WINDOW ? "<title> [src.window_title] </title>" : ""]
  <style type="text/css"> [global_css] [page_css] </style>
  <script language="javascript">
	[predef_js] [page_js] [jsText]
  </script>
</head>
<body>
  [bodyText]
</body>
</html>
			"}

		ClosePages()
			for(var/client/C in src.viewers)
				RemovePage(C)

		DeleteForm()
			del(src)
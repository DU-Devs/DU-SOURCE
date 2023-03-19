/*
this is a system that guides a player on how to achieve a certain goal.
like if their goal is to be really strong it will analyze their character and give them tips on anything critical they need to do to get stronger.
such as train their gravity mastery.

scrap most of this code this is not the structure it should have dont proceed any further with this flawed architecture
*/

var
	helperQuestsOn = 0

mob/var
	powerQuestIntroShown

/*mob/verb/testhelpalert()
	set category = "test"
	HelpAlert("Want to gain battle power faster? Then try gravity training. Mastering higher gravity gives a permanent increase in BP gains, \
	even when you aren't in the gravity. (This tip was generated for you because you have low gravity mastery)", 100)*/

mob/verb
	HideHelpAlert()
		set hidden = 1
		//winshow(src, "helpAlertWindow", 0)
		winset(src, "mainwindow.helpAlert", "is-visible=false")
		client.helpAlertShowing = 0

mob/proc
	//the HelpAlert "label" is actually a BUTTON and you can assign a command to be run when it is clicked
	HelpAlert(txt, duration = 999, command)
		set waitfor=0
		//if(classic_ui) return
		while(client && client.helpAlertShowing) sleep(5) //wait for any previous alerts to go away
		if(!client) return
		if(!command) command = "HideHelpAlert"
		client.helpAlertShowing = 1
		winset(src, "mainwindow.helpAlert", "text=\"[txt]\"")
		winset(src, "mainwindow.helpAlert", "command=[command]")
		//sleep(10) //apparently it needs some time to refresh from the old text to the new text, its not nice to see the old text there for a split second
		client.helpAlertCount++
		var/count_id = client.helpAlertCount
		//winshow(src, "helpAlertWindow", 1)
		winset(src, "mainwindow.helpAlert", "is-visible=true")
		if(duration < 5 * 600) //presumed to be an "infinite duration alert" so we stop here instead of wasting sleep() code forever
			sleep(duration)
			if(client && client.helpAlertCount == count_id)
				//winshow(src, "helpAlertWindow", 0)
				winset(src, "mainwindow.helpAlert", "is-visible=false")
				client.helpAlertShowing = 0

	InitHelperQuests()
		set waitfor=0

		return //disabled for now because we are gonna have to redo this it isnt a good structure

		sleep(150) //just wait til theyre loaded in for a bit
		if(!helperQuestsOn) return
		InitPowerQuest() //this is the only quest right now so just do this

	InitPowerQuest()
		if(!helperQuestsOn) return
		PowerQuestLoop()

	PowerQuestLoop()
		if(!helperQuestsOn) return
		TryPowerQuestIntro()
		sleep(150)

	TryPowerQuestIntro()
		if(powerQuestIntroShown) return
		powerQuestIntroShown = 1
		HelpAlert("This box will analyze your character and give tips on how to get stronger. You can turn this off in the Options tab by \
		clicking 'Toggle Help Alerts'", 100)
		sleep(200)
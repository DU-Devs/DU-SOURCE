mob/var/tmp/obj/screen_object/maptext_holder/waitText
mob/var/tmp/waitScreenShown = 0
mob/proc/ShowWaitingScreen()
	set waitfor = FALSE
	set background = TRUE
	client.screen -= waitText
	waitText = new(client)
	waitText.screen_loc = "CENTER,CENTER"
	waitText.alpha = 0
	waitText.text_align = "left"
	waitText.pixel_x = -(waitText.maptext_width / 2) + TILE_WIDTH / 2

	waitText.text_size = "14pt"
	waitText.text_color = "#00968cff"
	waitText.outline_color = "#d1d1d1"

	waitText.SetText("PLEASE WAIT")
	client.screen += waitText
	animate(waitText, time = 10, alpha = 255, loop = -1)
	animate(time = 10, alpha = 0)
	client.eye = null
	AlterInputDisabled(1)

	waitScreenShown = 1
	while(waitScreenShown)
		waitText.SetText("PLEASE WAIT")
		sleep(15)
		waitText.SetText("PLEASE WAIT .")
		sleep(15)
		waitText.SetText("PLEASE WAIT . .")
		sleep(15)
		waitText.SetText("PLEASE WAIT . . .")
		sleep(15)
	client.screen -= waitText
	waitText = null

mob/proc/HideWaitingScreen()
	animate(waitText, time = 5, alpha = 0)
	waitScreenShown = 0
	AlterInputDisabled(-1)
	client.eye = src
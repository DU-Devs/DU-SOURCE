/*
last char name
aura/blast/charging icon
ssj1/2/3/4 opening graphics
*/
mob/proc
	save_player_settings()
		if(!client || !z) return
		if(client.connection != "seeker") return //i think web connections and such are corrupting their file and erasing their hotkeys
		var/savefile/f = new()
		f["ViewX"]<<ViewX
		f["ViewY"]<<ViewY
		f["ignore_votes"]<<ignore_votes
		f["OOCon"]<<OOCon
		f["Fullscreen"]<<Fullscreen
		f["See_Logins"]<<See_Logins
		f["AdminOn"]<<AdminOn
		f["Build"]<<Build
		f["TechTab"]<<TechTab
		f["ignore_leagues"]<<ignore_leagues
		f["ignore_contracts"]<<ignore_contracts
		f["TextSize"]<<TextSize
		f["TextColor"]<<TextColor
		f["sort_sense_by"]<<sort_sense_by
		f["block_music"] << block_music

		//if(hotbar_ids.len && client.connection == "seeker")
		//	f["hotbar_ids"]<<hotbar_ids
		Hotkey_server_backup_save()

		f["tab_font_size"]<<tab_font_size
		client.Export(f)

	load_player_settings()
		if(!client) return

		var/file_exists = client.Import()
		if(!file_exists)
			for(var/v in 1 to 5)
				if(!file_exists && client)
					file_exists = client.Import()
					sleep(20)
				else break
		if(!file_exists || !client) return
		var/savefile/f = new(file_exists)
		if(!f) return

		f["ViewX"]>>ViewX
		f["ViewY"]>>ViewY
		f["ignore_votes"]>>ignore_votes
		f["OOCon"]>>OOCon
		f["Fullscreen"]>>Fullscreen
		f["See_Logins"]>>See_Logins
		f["AdminOn"]>>AdminOn
		f["Build"]>>Build
		f["TechTab"]>>TechTab
		f["ignore_leagues"]>>ignore_leagues
		f["ignore_contracts"]>>ignore_contracts
		f["TextSize"]>>TextSize
		f["TextColor"]>>TextColor
		if("tab_font_size" in f) f["tab_font_size"]>>tab_font_size
		if("sort_sense_by" in f) f["sort_sense_by"]>>sort_sense_by
		if("block_music" in f) f["block_music"] >> block_music

		//if("hotbar_ids" in f)
		//	f["hotbar_ids"] >> hotbar_ids

		DetermineViewSize()
		Fullscreen_Check()

		Restore_hotbar_from_IDs()
		Set_tab_font_size(tab_font_size)
/*
last char name
aura/blast/charging icon
ssj1/2/3/4 opening graphics
*/
mob/proc
	save_player_settings()
		if(!client||!z) return
		var/savefile/f=new()
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

		if(hotbar_ids.len)
			f["hotbar_ids"]<<hotbar_ids
			Hotkey_server_backup_save()

		f["tab_font_size"]<<tab_font_size
		client.Export(f)
	load_player_settings()
		if(!client) return

		var/file_exists=client.Import()
		if(!file_exists)
			for(var/v in 1 to 5)
				if(!file_exists&&client)
					file_exists=client.Import()
					sleep(20)
				else break
		if(!file_exists||!client) return
		var/savefile/f=new(file_exists)
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

		if("hotbar_ids" in f)
			f["hotbar_ids"]>>hotbar_ids

		if(ViewX>max_screen_size) ViewX=max_screen_size
		if(ViewY>max_screen_size) ViewY=max_screen_size

		if(ViewX&&ViewY&&client) client.view="[ViewX]x[ViewY]"
		Fullscreen_Check()
		Restore_hotbar_from_IDs()
		Set_tab_font_size(tab_font_size)



mob/proc
	Has_hotkey_server_backup()
		if(!client) return
		if(fexists("Hotkey backups/[key]")) return 1

	Hotkey_server_backup_load()
		if(!client || !fexists("Hotkey backups/[key]"))
			src<<"ERROR: Hotkey backup NOT FOUND. Report this."
			return
		var/savefile/f=new("Hotkey backups/[key]")
		f["hotbar_ids"]>>hotbar_ids

	Hotkey_server_backup_save()
		if(!client) return
		var/savefile/f=new("Hotkey backups/[key]")
		f["hotbar_ids"]<<hotbar_ids
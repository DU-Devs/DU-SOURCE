/*
last char name
aura/blast/charging icon
ssj1/2/3/4 opening graphics
*/
client/var/settings_version = 1
mob/proc
	save_player_settings()
		if(!client || !z) return

		var/savefile/f = new()
		f["[ckey]/settings_version"]<<client.settings_version
		f["[ckey]/ViewX"]<<ViewX
		f["[ckey]/ViewY"]<<ViewY
		f["[ckey]/ignore_votes"]<<ignore_votes
		f["[ckey]/Fullscreen"]<<Fullscreen
		f["[ckey]/See_Logins"]<<See_Logins
		f["[ckey]/AdminOn"]<<AdminOn
		f["[ckey]/Build"]<<Build
		f["[ckey]/TechTab"]<<TechTab
		f["[ckey]/ignore_leagues"]<<ignore_leagues
		f["[ckey]/ignore_contracts"]<<ignore_contracts
		f["[ckey]/TextSize"]<<TextSize
		f["[ckey]/TextColor"]<<TextColor
		f["[ckey]/sort_sense_by"]<<sort_sense_by
		f["[ckey]/block_music"] << block_music
		f["[ckey]/minHUDOpacity"] << client.minHUDOpacity
		f["[ckey]/maxHUDOpacity"] << client.maxHUDOpacity
		f["[ckey]/hudFadeTime"] << client.hudFadeTime
		f["[ckey]/hudScale"] << client.hudScale
		f["[ckey]/floatingText"] << client.floatingText
		f["[ckey]/fallingText"] << client.fallingText

		if(hotbar_ids.len)
			f["[ckey]/hotbar_ids"] << hotbar_ids
		Hotkey_server_backup_save()

		f["[ckey]/tab_font_size"]<<tab_font_size
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
		if(f["[ckey]/settings_version"]) f["[ckey]/settings_version"] >> client.settings_version
		if(client.settings_version < 1)
			if(f["[key]/ViewX"]) f["[key]/ViewX"]>>ViewX
			if(f["[key]/ViewY"]) f["[key]/ViewY"]>>ViewY
			if(f["[key]/ignore_votes"]) f["[key]/ignore_votes"]>>ignore_votes
			if(f["[key]/Fullscreen"]) f["[key]/Fullscreen"]>>Fullscreen
			if(f["[key]/See_Logins"]) f["[key]/See_Logins"]>>See_Logins
			if(f["[key]/AdminOn"]) f["[key]/AdminOn"]>>AdminOn
			if(f["[key]/ignore_leagues"]) f["[key]/ignore_leagues"]>>ignore_leagues
			if(f["[key]/ignore_contracts"]) f["[key]/ignore_contracts"]>>ignore_contracts
			if(f["[key]/TextSize"]) f["[key]/TextSize"]>>TextSize
			if(f["[key]/TextColor"]) f["[key]/TextColor"]>>TextColor
			if(f["[key]/minHUDOpacity"]) f["[key]/minHUDOpacity"] >> client.minHUDOpacity
			if(f["[key]/maxHUDOpacity"]) f["[key]/maxHUDOpacity"] >> client.maxHUDOpacity
			if(f["[key]/hudFadeTime"]) f["[key]/hudFadeTime"] >> client.hudFadeTime
			if(f["[key]/hudScale"]) f["[key]/hudScale"] >> client.hudScale
			if(f["[key]/tab_font_size"])
				f["[key]/tab_font_size"] >> tab_font_size
				Set_tab_font_size(tab_font_size)
			if(f["[key]/sort_sense_by"]) f["[key]/sort_sense_by"] >> sort_sense_by
			if(f["[key]/block_music"]) f["[key]/block_music"] >> block_music
			if(f["[key]/hotbar_ids"])
				f["[key]/hotbar_ids"] >> hotbar_ids
		else
			if(f["[ckey]/ViewX"]) f["[ckey]/ViewX"]>>ViewX
			if(f["[ckey]/ViewY"]) f["[ckey]/ViewY"]>>ViewY
			if(f["[ckey]/ignore_votes"]) f["[ckey]/ignore_votes"]>>ignore_votes
			if(f["[ckey]/Fullscreen"]) f["[ckey]/Fullscreen"]>>Fullscreen
			if(f["[ckey]/See_Logins"]) f["[ckey]/See_Logins"]>>See_Logins
			if(f["[ckey]/AdminOn"]) f["[ckey]/AdminOn"]>>AdminOn
			if(f["[ckey]/ignore_leagues"]) f["[ckey]/ignore_leagues"]>>ignore_leagues
			if(f["[ckey]/ignore_contracts"]) f["[ckey]/ignore_contracts"]>>ignore_contracts
			if(f["[ckey]/TextSize"]) f["[ckey]/TextSize"]>>TextSize
			if(f["[ckey]/TextColor"]) f["[ckey]/TextColor"]>>TextColor
			if(f["[ckey]/minHUDOpacity"]) f["[ckey]/minHUDOpacity"] >> client.minHUDOpacity
			if(f["[ckey]/maxHUDOpacity"]) f["[ckey]/maxHUDOpacity"] >> client.maxHUDOpacity
			if(f["[ckey]/hudFadeTime"]) f["[ckey]/hudFadeTime"] >> client.hudFadeTime
			if(f["[ckey]/hudScale"]) f["[ckey]/hudScale"] >> client.hudScale
			if(f["[ckey]/floatingText"]) f["[ckey]/floatingText"] >> client.floatingText
			if(f["[ckey]/fallingText"]) f["[ckey]/fallingText"] >> client.fallingText
			if(f["[ckey]/tab_font_size"])
				f["[ckey]/tab_font_size"] >> tab_font_size
				Set_tab_font_size(tab_font_size)
			if(f["[ckey]/sort_sense_by"]) f["[ckey]/sort_sense_by"] >> sort_sense_by
			if(f["[ckey]/block_music"]) f["[ckey]/block_music"] >> block_music
			if(f["[ckey]/hotbar_ids"])
				f["[ckey]/hotbar_ids"] >> hotbar_ids

		Fullscreen_Check()
/*mob/Admin4/verb/Toggle_DB_Character_Mode()
	set category = "Admin"
	dbz_character_mode = !dbz_character_mode
	if(dbz_character_mode)
		src << "DBZ Character Mode is now on. This means that at the log on screen people will be able to \
		choose a prebuilt DBZ character if someone online is not already playing it. When a person loads \
		the character it will be exactly the same as the last person who played it with all the gained \
		BP and stats and so on."
	else
		src << "DBZ Character Mode is now off"

mob/Admin4/verb/Disable_DB_Character()
	set category="Admin"
	switch(alert(src,"Enable or disable a Wish Orbs character?","Options","Enable","Disable"))
		if("Enable")
			while(src)
				var/list/l=disabled_dbz_characters
				l.Insert(1,"Cancel")
				if(l.len<=1)
					src<<"There are no db characters disabled"
					return
				var/n=input(src,"Which character to enable?") in l
				if(!n||n=="Cancel") return
				disabled_dbz_characters-=n
		if("Disable")
			while(src)
				var/list/l=playable_db_characters
				for(var/v in l) if(v in disabled_dbz_characters) l-=v
				l.Insert(1,"Cancel")
				if(l.len<=1)
					src<<"There are no enabled db characters"
					return
				var/n=input(src,"Which character to disable?") in l
				if(!n||n=="Cancel") return
				disabled_dbz_characters+=n
	RefreshDBCharacterMenuAll()*/
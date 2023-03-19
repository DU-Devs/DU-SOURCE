/*
ability to add custom characters

add Human Techy to list, infinite amount of them. you can play them if no z char is available

BUG: it doesnt give evil chars proper evil alignment
*/

var
	dbz_character_mode=0
	tmp
		list
			db_menu_avatars = new
	list
		dbz_characters = new
		disabled_dbz_characters = new

mob/var
	dbz_character
	tmp
		choosing_db_character

mob/proc
	DBCharacterMenu()
		choosing_db_character = 1

		winset(src, "DBCharacterMenu", "is-visible=true")

		RefreshDBCharacterMenu()

		while(choosing_db_character)
			sleep(3)
		winset(src, "DBCharacterMenu", "is-visible=false")

		stat_version = cur_stat_ver
		majin_stat_version = cur_majin_stat_version
		era = era_resets

	RefreshDBCharacterMenu()
		if(!dbz_character_mode) return
		var/win = "DBCharacterMenu"
		winset(src, "[win].grid1", "is-list=true")
		winset(src, "[win].grid1", "cells=0") //clears grid
		var/added = 0
		for(var/obj/DBZ_Character/o in db_menu_avatars)
			if(!(o.name in disabled_dbz_characters))
				if(o.can_pick)
					added++
					winset(src, "[win].grid1", "current-cell=[added]")
					src << output(o, "[win].grid1")
		winset(src, "[win].grid1", "cells=[added]")

proc
	RefreshDBCharacterMenuAll()
		set waitfor=0
		if(!dbz_character_mode) return
		for(var/mob/m in players) if(m.choosing_db_character) m.RefreshDBCharacterMenu()

proc/Initialize_db_menu_avatars()
	if(!dbz_character_mode) return
	for(var/v in playable_db_characters)
		Add_dbz_avatar(v)

proc/Add_dbz_avatar(n, bypass_exist_check)
	set waitfor=0
	if(!dbz_character_mode) return
	if(bypass_exist_check) sleep(10)
	if(!bypass_exist_check && DBZ_character_exists(n)) return
	for(var/obj/DBZ_Character/o in db_menu_avatars) if(o.name == n)
		o.can_pick = 1
		RefreshDBCharacterMenuAll()
		return
	db_menu_avatars.len = playable_db_characters.len
	var/index = 1
	if(n in playable_db_characters) index = playable_db_characters.Find(n)
	var/obj/DBZ_Character/a = new
	a.name = n
	var/mob/dbz = Generate_dbz_character(n, for_avatar = 1, new_only = bypass_exist_check)
	a.icon = dbz.icon
	a.overlays = dbz.overlays
	if(!dbz.client) del(dbz)
	db_menu_avatars.Insert(index, a)
	RefreshDBCharacterMenuAll()

proc/Remove_dbz_avatar(n)
	if(n=="Greenster") return
	for(var/obj/DBZ_Character/o in db_menu_avatars) if(o.name == n)
		o.can_pick = 0
	RefreshDBCharacterMenuAll()

mob/proc/DBZ_character_del()
	if(!dbz_character) return
	Add_dbz_avatar(n = dbz_character, bypass_exist_check = 1)

obj/DBZ_Character
	var
		tmp
			next_can_be_clicked_time = 0
			can_pick = 1
	Click()
		if(name in disabled_dbz_characters) return
		if(!can_pick) return
		if(DBZ_character_exists(name))
			usr<<"[name] is already being played"
			return
		if(world.time < next_can_be_clicked_time) return
		next_can_be_clicked_time = world.time + 50
		usr.choosing_db_character=0
		usr.Load_dbz_character(name)

proc/Get_playable_db_characters()
	var/list/L=new
	for(var/obj/DBZ_Character/o in db_menu_avatars)
		if(!DBZ_character_exists(o.name) && !(o.name in disabled_dbz_characters))
			if(o.can_pick)
				L+=o
	return L

proc/DBZ_character_exists(n)
	if(n=="Greenster") return
	for(var/mob/m in dbz_characters) if(m.dbz_character == n) return m

mob/proc/Load_dbz_character(n, for_generation)
	if(!dbz_character_mode) return
	if(fexists("DBZ Character Saves/[n]") && !DBZ_character_exists(n))
		var/savefile/f = new("DBZ Character Saves/[n]")
		Read(f)
		SafeTeleport(locate(saved_x,saved_y,saved_z))
		dbz_characters += src
		Remove_dbz_avatar(dbz_character)
		Other_Load_Stuff()

	else if(!for_generation) //dont run any generation code if we are already doing this as part of generation already
		var/mob/dbz = Generate_dbz_character(n)
		dbz.Save_dbz_character(first_time=1)
		if(!dbz.client) del(dbz)
		sleep(10)
		Load_dbz_character(n)

mob/proc/Save_dbz_character(first_time)
	if(!dbz_character) return
	if(!dbz_character_mode) return
	if(!first_time) Record_offline_gains()
	if(z && !Regenerating)
		saved_x = x
		saved_y = y
		saved_z = z
	if(Ship&&Ship.z)
		saved_x = Ship.x
		saved_y = Ship.y
		saved_z = Ship.z

	var/mob/m = Duplicate(include_unclonables=1)
	m.key=null
	m.displaykey=null

	var/savefile/F=new("DBZ Character Saves/[dbz_character]")
	F["Last_Used"]<<world.realtime
	m.Write(F)
	m.dbz_character=null
	UpdateDBZAvatar()
	del(m)

mob/proc/UpdateDBZAvatar()
	for(var/obj/DBZ_Character/o in db_menu_avatars)
		if(o.name == name)
			o.overlays = overlays
			o.icon = icon
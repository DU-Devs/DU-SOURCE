mob/proc/Player_Rename_List()
	var/list/L=new
	for(var/obj/A in view(10,src)) if(!istype(A,/obj/items/Lizard_Sphere)&&!istype(A,/obj/Spawn)&&\
	!istype(A,/obj/Planets)) L+=A
	for(var/mob/A in view(10,src)) L+=A
	return L
obj/Colorfy/verb/Color(obj/O as obj in view(usr))
	set src=usr.contents
	set category="Other"
	if(ismob(O)) switch(input(O,"[usr] wants to colorize you, accept?") in list("No","Yes"))
		if("No") return
	usr.Colorize(O)
mob/Admin2/verb/Color(obj/O as obj|mob|turf in view(usr))
	set category="Other"
	usr.Colorize(O)
mob/proc/Colorize(obj/O)
	if(!O.icon) return
	switch(input(src,"") in list("Add","Subtract","Multiply"))
		if("Multiply") if(O)
			var/B=input(src,"Choose a color") as color|null
			if(B&&O) O.Multiply_Color(B)
		if("Add") if(O) O.icon+=rgb(input(src,"Red (0-255 for all entries)") as num,input(src,"Green") as num,input(src,"Blue") as num)
		if("Subtract") if(O) O.icon-=rgb(input(src,"Red (0-255 for all entries)") as num,input(src,"Green") as num,input(src,"Blue") as num)
atom/proc/Multiply_Color(B)
	var/icon/A=new(icon)
	if(B&&A) A.MapColors(B,"#ffffff","#000000")
	icon=A
mob/proc/Change_Icon_List()
	var/list/L=list("Cancel")
	for(var/mob/P in view(src)) L+=P
	for(var/obj/O in view(src)) if(!istype(O,/obj/items/Lizard_Sphere)&&!istype(O,/obj/Spawn)&&!istype(O,/obj/Drill))
		L+=O
	return L
proc/Icon_too_big(icon/I)
	if(!I||!isicon(I)) return 1
	if(length(I)/1024/1024>0.5)
		usr<<"You can not use icons greater than 0.5 mb"
		return 1
	if(Get_Width(I)>224||Get_Height(I)>224)
		usr<<"You can not use icons exceeding 224 pixels in either direction"
		return 1
obj/Crandal
	verb/Custom_Overlay(icon/I as icon)
		set category="Other"
		if(Icon_too_big(I)) return
		var/list/States=new
		States+="None"
		for(var/A in icon_states(I)) States+=A
		var/State=input("This verb allows you to make multi tile icons, first, you choose the icon you want, then \
		you pick an icon state within that icon, then you offset the chosen icon's pixels however you want, then \
		it is added to your character. Each tile is 32 pixels, so +32 is one tile away.") in States
		if(State=="None") State=""
		var/X_Offset=input("Choose pixel_x offset, each tile is 32 pixels.") as num
		var/Y_Offset=input("Choose pixel_y offset") as num
		var/image/A=image(icon=I,icon_state=State,pixel_x=X_Offset,pixel_y=Y_Offset)
		usr.overlays+=A
	verb/Send_File(M as mob in Players,F as file)
		set src=usr.contents
		set category="Other"
		if(length(F)/1024/1024>2)
			usr<<"You can not send files greater than 2 mb"
			return
		switch(alert(M,"[usr] is trying to send you [F]. Accept?","","Yes","No"))
			if("Yes")
				usr<<"[M] accepted the file"
				M<<ftp(F)
			if("No") if(usr) usr<<"[M] declined the file"
	verb/Change_Icon(atom/O in usr.Change_Icon_List())
		set category="Other"
		if(!O||O=="Cancel") return
		var/icon/I=input("Choose an icon file") as icon
		if(!I||!O||!isicon(I)) return
		if(Icon_too_big(I)) return
		if(ismob(O)&&O:client) switch(input(O,"[usr] wants to change your icon into [I], allow?") in list("No","Yes"))
			if("No")
				usr<<"[O] denied the icon change to [I]"
				return
		if(!O) return
		O.icon=I
		if(!ismob(O)) O.icon_state=input("Icon State?") as text
		Center_Icon(O)
	verb/Rename(atom/O in usr.Player_Rename_List())
		set src=usr.contents
		set category="Other"
		if(!isobj(O)&&!ismob(O)) return
		if(!O) return
		if(usr)
			usr<<"Do not use this to give yourself a name that is against the rules. Or somehow blank names."
			var/ID=input(usr,"Name?","Options",O.name) as text
			if(!ID) return
			if(O!=usr&&ismob(O)&&O:client) switch(input(O,"[usr] wants to change your name to [ID], accept?") in list("No","Yes"))
				if("No")
					usr<<"[O] declined the name change to [ID]"
					return
			if(!O) return
			if(findtext(ID,"://")||findtext(ID,"\n"))
				usr<<"No links in names"
				return
			O.name=html_encode(copytext(ID,1,50))
	verb/Copy_Icon(mob/A in world)
		set src=usr.contents
		set category="Other"
		usr.icon=A.icon
obj/Sonku_Planet
	var/X
	var/Y
	var/Z
	Givable=0
	Makeable=0
	verb/Go_To_Planet()
		set category="Skills"
		var/On_Planet
		for(var/area/Sonku/S in range(40,usr)) On_Planet=1
		if(!On_Planet)
			for(var/mob/P in view(1,usr)) if(P!=usr) P.loc=locate(125,375,9)
			X=usr.x
			Y=usr.y
			Z=usr.z
			usr.loc=locate(125,375,9)
		else
			for(var/mob/P in view(1,usr)) if(P!=usr) P.loc=locate(X,Y,Z)
			usr.loc=locate(X,Y,Z)
obj/SSX_Planet
	Givable=0
	Makeable=0
	var/X
	var/Y
	var/Z
	verb/Go_To_Planet()
		set category="Skills"
		var/On_Planet
		for(var/area/SSX/S in range(40,usr)) On_Planet=1
		if(!On_Planet)
			for(var/mob/P in view(1,usr)) if(P!=usr) P.loc=locate(375,463,9)
			X=usr.x
			Y=usr.y
			Z=usr.z
			usr.loc=locate(375,463,9)
		else
			for(var/mob/P in view(1,usr)) if(P!=usr) P.loc=locate(X,Y,Z)
			usr.loc=locate(X,Y,Z)
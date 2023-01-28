/*
Ideas for attributes:
	Shuriken, bounces off walls or whatever
	Homing. For each point it homes in 5 tiles, after it uses up the tiles it just goes straight
	Range. 10 tiles per point perhaps? Sniping applications?
	Beam. Fire a constant beam for possibly heavy ammo drain.
	Charge. Increased damage by adding a charging period before firing.
	Piercing attribute, not only does this make it peirce through a person, but also gives it an edge in piercing through
	other bullets in its way even if they are more powerful
*/
obj/var/Customization_Points=10
obj/items/Gun
	hotbar_type="Combat item"
	era_reset_immune=0
	clonable = 0
	can_hotbar=1
	can_change_icon=1
	Customization_Points=35
	verb/Hotbar_use()
		set hidden=1
		Shoot()
mob/var/tmp/obj/items/Gun/Gun //The gun being customized currently.
mob/proc/Customize_Gun_Stats(obj/items/Gun/G)
	Gun=G
	G.Set_Default_Gun_Stats()
	Gun_Window_Refresh(G)
	winshow(src,"gunstats",1)
	while(src&&(winget(src,"gunstats","is-visible")=="true")) sleep(1)
	Gun=null
mob/proc/Gun_Window_Refresh(obj/items/Gun/G)
	winset(src,"GunPoints","text=[G.Customization_Points]")
	winset(src,"GunDamageVal","text=[G.bp_mod]")
	winset(src,"GunAmmoVal","text=[G.Max_Ammo]")
	winset(src,"GunVelocityVal","text=[G.Velocity]")
	winset(src,"GunRefireVal","text=[G.Delay]")
	winset(src,"GunPrecisionVal","text=[G.Precision]")
	winset(src,"GunExplosionVal","text=[G.Explodes]")
	winset(src,"GunSpreadVal","text=[G.Spread]")
	winset(src,"GunKnockbackVal","text=[G.Knockbacks]")
	winset(src,"GunStunVal","text=[G.Stun]")
	winset(src,"GunReloadVal","text=[G.Reload_Speed]")
	winset(src,"GunRangeVal","text=[G.Range]")
	if(G.Bullet) winset(src,"GunType","text='Ballistic Projectiles'")
	else winset(src,"GunType","text='Energy Projectiles'")
obj/items/Gun/proc/Set_Default_Gun_Stats()
	Customization_Points=initial(Customization_Points)
	bp_mod=initial(bp_mod)
	Max_Ammo=initial(Max_Ammo)
	Velocity=initial(Velocity)
	Delay=initial(Delay)
	Precision=initial(Precision)
	Explodes=initial(Explodes)
	Spread=initial(Spread)
	Knockbacks=initial(Knockbacks)
	Stun=initial(Stun)
	Bullet=initial(Bullet)
	Reload_Speed=initial(Reload_Speed)
	Range=initial(Range)
obj/items/Gun/proc/Gun_Stat_Lowest(A)
	switch(A)
		if("Damage") if(bp_mod<=initial(bp_mod)) return 1
		if("Ammo") if(Max_Ammo<=initial(Max_Ammo)) return 1
		if("Velocity") if(Velocity<=initial(Velocity)) return 1
		if("Refire") if(Delay<=initial(Delay)) return 1
		if("Precision") if(Precision<=initial(Precision)) return 1
		if("Explosion") if(Explodes<=initial(Explodes)) return 1
		if("Spread") if(Spread<=initial(Spread)) return 1
		if("Knockback") if(Knockbacks<=initial(Knockbacks)) return 1
		if("Stun") if(Stun<=initial(Stun)) return 1
		if("Reload") if(Reload_Speed<=initial(Reload_Speed)) return 1
		if("Range") if(Range<=initial(Range)) return 1
mob/verb/Customize_Gun(O as text,S as text) //O=Operator (+ or -), S=Stat
	set hidden=1
	set name=".Customize_Gun"

	if(!Gun) return //5/5/2012

	//security
	if(!(winget(src,"gunstats","is-visible")=="true")) return
	if(!(O in list("+","-"))) return
	if(!(S in list("Range","Damage","Ammo","Velocity","Refire","Precision","Explosion","Spread","Knockback",\
	"Stun","Reload","Type"))) return

	//if(S=="Stun")
		//alert("Stun guns are disabled due to players voting it off")
		//return

	if(S=="Type")
		Gun.Bullet=!Gun.Bullet
		Gun_Window_Refresh(Gun)
		return
	var/Amount=1
	if(O=="-")
		Amount=-1
		if(Gun.Customization_Points>=initial(Gun.Customization_Points)||Gun.Gun_Stat_Lowest(S)) return
	if(O=="+") if(Gun.Customization_Points<1) return
	switch(S)
		if("Range") Gun.Range+=Amount*1
		if("Damage") Gun.bp_mod+=Amount*0.25
		if("Ammo") Gun.Max_Ammo+=Amount*0.25
		if("Velocity")
			if(O=="+"&&Gun.Velocity>=10) return
			Gun.Velocity+=Amount*1
		if("Refire")
			if(O=="+"&&Gun.Delay>=10) return
			Gun.Delay+=Amount*1
		if("Precision") Gun.Precision+=Amount*0.25
		if("Explosion")
			if(O=="+"&&Gun.Explodes>=5) return
			Gun.Explodes+=Amount
		if("Spread")
			if(O=="+"&&Gun.Spread>=1) return
			Gun.Spread+=Amount
		if("Knockback") Gun.Knockbacks+=Amount
		if("Stun") Gun.Stun+=Amount
		if("Reload") Gun.Reload_Speed+=Amount*1
	Gun.Customization_Points-=Amount
	Gun_Window_Refresh(Gun)
mob/verb/Gun_Points_Done()
	set name=".Gun_Points_Done"
	set hidden=1
	if(!Gun||!Gun.Customization_Points) winshow(src,"gunstats",0)
//GUN APPEARANCES
obj/Gun_Icon/Click() if(usr.Gun)
	usr.Gun.icon=icon
	usr.Gun.icon_state=icon_state
obj/Bullet_Icons/Click() if(usr.Gun)
	usr.Gun.Bullet_Icon=icon
	var/C=input("Choose a color. Hit cancel to have default color.") as color|null
	if(C) usr.Gun.Bullet_Icon+=C
var/list/Gun_Icons=new
var/list/Bullet_Icons=new
proc/Initialize_Gun_Icons()
	var/Gun_Name=1
	var/obj/Gun_Icon/G=new
	G.name=Gun_Name
	G.icon='Item, Blaster.dmi'
	Gun_Icons+=G
	for(var/A in icon_states('GUNS.dmi')) if(!(A in list("Rocket Middle","Rocket Right","Ammo 1","Ammo 2",\
	"Ammo 3","Ammo Box")))
		Gun_Name+=1
		var/obj/Gun_Icon/B=new
		B.name=Gun_Name
		B.icon='GUNS.dmi'
		B.icon_state=A
		Gun_Icons+=B
	var/list/Bullets=list('Bullet 1.dmi','Bullet 2.dmi','Bullet 3.dmi','Bullet 4.dmi','Bullet.dmi','Missile Small.dmi',\
	'Missile.dmi','Grenade.dmi')
	for(var/A in Bullets)
		var/obj/Bullet_Icons/B=new
		B.icon=A
		Bullet_Icons+=B
	for(var/obj/A in Blasts)
		var/obj/Bullet_Icons/B=new
		B.icon=A.icon
		B.icon_state=A.icon_state
		Bullet_Icons+=B

mob/proc/Grid(list/L, obj/items/Gun/G, update_only, show_names = 0)
	if(!client) return

	if(show_names) winset(src,"Grid1.Main Grid","show-names=true")
	else winset(src,"Grid1.Main Grid","show-names=false")

	winset(src,"Grid1.Main Grid","is-list=true")
	winset(src,"Grid1.Main Grid","cells=0") //clear the grid
	if(!L) if(winget(src,"Grid1","is-visible")=="true") return 1
	else
		if(G&&istype(G,/obj/items/Gun)) Gun=G
		var/Cell=1
		for(var/obj/O in L)
			winset(src,"Grid1.Main Grid","current-cell=[Cell]")
			src<<output(O,"Grid1.Main Grid")
			Cell++
		winset(src,"Grid1.Main Grid","cells=[Cell]")
		winset(src,"Grid1","is-visible=true")
		if(!update_only) while(src&&client&&(winget(src,"Grid1","is-visible")=="true")) sleep(1)
		if(istype(G,/obj/items/Gun)) Gun=null
		if(!update_only) winset(src,"Grid1.Main Grid","cells=0") //clear the grid

mob/verb/Hide_Main_Grid()
	set hidden=1
	set name=".Hide_Main_Grid"
	winset(src,"Grid1.Main Grid","show-names=false")
	winset(src,"Grid1.Main Grid","cells=0") //clear the grid
	winset(src,"Grid1","is-visible=false")
	winset(src,"Grid1","title=\"\"")


var/list/weights_icons=new
mob/var/tmp/obj/weights_icon_obj
obj/weights_icon
	Click()
		if(!usr.weights_icon_obj) return
		usr.weights_icon_obj.icon=icon
		var/RGB=input(usr,"Choose color. Hit Cancel to have default color.") as color|null
		if(RGB) usr.weights_icon_obj.icon+=RGB
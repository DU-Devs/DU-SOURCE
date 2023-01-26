var/Map_Loaded

mob/Admin4/verb/Load_External_Map_File()
	set category = "Admin"
	var/savefile/f = input("Choose a map file to load into the game on top of whatever is already here") as file|null
	if(!f)
		clients << "No file was chosen"
		return
	LoadMap(f)

mob/proc/max_turf_upgrade()
	var/n = Knowledge * Mechanics.GetSettingValue("Turf Health Multiplier") * (Intelligence() ** 0.1)
	n *= 1 //arbitrary
	return n

mob/var/tmp/last_wall_upgrade=0 //world.time

var/list/Turfs=new
var/list/built_turfs=new //newer, includes directories by key
turf/var/FlyOverAble=1
atom/var/Buildable=1

var/list/Builds=new

proc/ClearObjectsFromPlayerTiles()
	set waitfor = FALSE
	set background = TRUE

	for(var/obj/Turfs/O)
		if(!O?.loc) continue
		var/turf/T = O.loc
		if(!HasCreator(O) && (HasCreator(T)))
			del(O)
	sleep(1)
	for(var/obj/Trees/O)
		if(!O?.loc) continue
		var/turf/T = O.loc
		if(!HasCreator(O) && (HasCreator(T)))
			del(O)
	sleep(1)
	for(var/obj/map_object/O)
		if(!O?.loc) continue
		var/turf/T = O.loc
		if(!HasCreator(O) && (HasCreator(T)))
			del(O)
	sleep(1)

mob/var/tmp/turf_lay_cost=0
mob/var/tmp/obj/Build/BuildTarget
mob/var/tmp/isBuilding = 0

mob/proc/turf_lay_cost()
	var/n = 1000 * 1.6**(Turfs.len/10000)
	n=round(n,1000)
	if(n>100000) n=100000
	n *= 0.3
	if(IsAdmin() && Social.GetSettingValue("Admins Build Free")) return 0
	return n * Mechanics.GetSettingValue("Building Price Multiplier")

proc/IsInVoid(mob/m)
	if(!m) return
	var/turf/t = m.base_loc()
	if(!t) return 1
	if(t.type == /turf/Other/Blank) return 1

var/list/Built_Objs

proc/Initialize_Built_Objs()
	Built_Objs = new/list
	for(var/obj/Turfs/T)
		if(T.Builder && T.Savable)
			if(!(ckey(T.Builder) in Built_Objs)) Built_Objs[ckey(T.Builder)] = new/list
			var/list/L = Built_Objs[ckey(T.Builder)]
			L += T
			Built_Objs[ckey(T.Builder)] = L
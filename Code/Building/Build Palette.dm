#ifdef DEBUG
mob/Admin5/verb/ExposePalettes()
	set category = "DEBUG"
	. = "var/list/groundPalette = list(\n"
	for(var/build_proxy/turf/B in groundPalette)
		var/turf/T = B.Print(1,1,1)
		B.Copy(T)
		. += "\t[B.Expose()],"
	. += ")"
	. = replacetext(., "},)", "}\n)")
	world.log << replacetext(., "},", "},\n")
	
	. = "var/list/roofPalette = list(\n"
	for(var/build_proxy/turf/B in roofPalette)
		var/turf/T = B.Print(1,1,1)
		B.Copy(T)
		. += "\t[B.Expose()],"
	. += ")"
	. = replacetext(., "},)", "}\n)")
	world.log << replacetext(., "},", "},\n")
	
	. = "var/list/wallPalette = list(\n"
	for(var/build_proxy/turf/B in wallPalette)
		var/turf/T = B.Print(1,1,1)
		B.Copy(T)
		. += "\t[B.Expose()],"
	. += ")"
	. = replacetext(., "},)", "}\n)")
	world.log << replacetext(., "},", "},\n")
	
	. = "var/list/liquidPalette = list(\n"
	for(var/build_proxy/turf/B in liquidPalette)
		var/turf/T = B.Print(1,1,1)
		B.Copy(T)
		. += "\t[B.Expose()],"
	. += ")"
	. = replacetext(., "},)", "}\n)")
	world.log << replacetext(., "},", "},\n")
	
	. = "var/list/otherPalette = list(\n"
	for(var/build_proxy/turf/B in otherPalette)
		var/turf/T = B.Print(1,1,1)
		B.Copy(T)
		. += "\t[B.Expose()],"
	. += ")"
	. = replacetext(., "},)", "}\n)")
	world.log << replacetext(., "},", "},\n")
	
	. = "var/list/objPalette = list(\n"
	for(var/build_proxy/map_object/B in objPalette)
		var/obj/map_object/O = B.Print(1,1,1)
		B.Copy(O)
		del(O)
		. += "\t[B.Expose()],"
	. += ")"
	. = replacetext(., "},)", "}\n)")
	world.log << replacetext(., "},", "},\n")
#endif

var/list/groundPalette = list(
	"{/build_proxy/turf}/turf/ground:(Grass1)" = new/build_proxy/turf{name = "Grass1"; icon = 'Turfs 12.dmi'; icon_state = "grass2"; density = 0; opacity = 0; build_type = /turf/ground; dirtOverlays = 1; grassOverlays = 1},
	"{/build_proxy/turf}/turf/ground:(Grass2)" = new/build_proxy/turf{name = "Grass2"; icon = 'Turfs 5.dmi'; icon_state = "grass"; density = 0; opacity = 0; build_type = /turf/ground; dirtOverlays = 1; grassOverlays = 1},
	"{/build_proxy/turf}/turf/ground:(Grass3)" = new/build_proxy/turf{name = "Grass3"; icon = 'Turfs 96.dmi'; icon_state = "grass b"; density = 0; opacity = 0; build_type = /turf/ground; dirtOverlays = 1; grassOverlays = 1},
	"{/build_proxy/turf}/turf/ground:(Grass4)" = new/build_proxy/turf{name = "Grass4"; icon = 'Turfs 96.dmi'; icon_state = "grass c"; density = 0; opacity = 0; build_type = /turf/ground; dirtOverlays = 1; grassOverlays = 1},
	"{/build_proxy/turf}/turf/ground:(Grass5)" = new/build_proxy/turf{name = "Grass5"; icon = 'Big Grass.dmi'; density = 0; opacity = 0; build_type = /turf/ground; dirtOverlays = 1; grassOverlays = 1},
	"{/build_proxy/turf}/turf/ground:(Grass7)" = new/build_proxy/turf{name = "Grass7"; icon = 'Turfs 1.dmi'; icon_state = "grass"; density = 0; opacity = 0; build_type = /turf/ground; dirtOverlays = 1; grassOverlays = 1},
	"{/build_proxy/turf}/turf/ground:(Grass8)" = new/build_proxy/turf{name = "Grass8"; icon = 'Big Grass and Dirt Turf.dmi'; icon_state = "0,0"; density = 0; opacity = 0; build_type = /turf/ground; dirtOverlays = 1; grassOverlays = 1; oversizedIconX = 6; oversizedIconY = 6},
	"{/build_proxy/turf}/turf/ground:(Grass9)" = new/build_proxy/turf{name = "Grass9"; icon = 'Turfs 96.dmi'; icon_state = "grass d"; density = 0; opacity = 0; build_type = /turf/ground; dirtOverlays = 1; grassOverlays = 1; oversizedIconX = 6; oversizedIconY = 6},
	"{/build_proxy/turf}/turf/ground:(Grass10)" = new/build_proxy/turf{name = "Grass10"; icon = 'Turfs 1.dmi'; icon_state = "Grass!"; density = 0; opacity = 0; build_type = /turf/ground; dirtOverlays = 1; grassOverlays = 1},
	"{/build_proxy/turf}/turf/ground:(Grass11)" = new/build_proxy/turf{name = "Grass11"; icon = 'Turfs 1.dmi'; icon_state = "Grass 50"; density = 0; opacity = 0; build_type = /turf/ground; dirtOverlays = 1; grassOverlays = 1},
	"{/build_proxy/turf}/turf/ground:(Grass12)" = new/build_proxy/turf{name = "Grass12"; icon = 'jungle grass tile.dmi'; density = 0; opacity = 0; build_type = /turf/ground; dirtOverlays = 1; grassOverlays = 1},
	"{/build_proxy/turf}/turf/ground:(Grass13)" = new/build_proxy/turf{name = "Grass13"; icon = 'Big Grass Turf 2.dmi'; density = 0; opacity = 0; build_type = /turf/ground; dirtOverlays = 1; grassOverlays = 1},
	"{/build_proxy/turf}/turf/ground:(Grass14)" = new/build_proxy/turf{name = "Grass14"; icon = 'Turfs 96.dmi'; icon_state = "grass a"; density = 0; opacity = 0; build_type = /turf/ground; dirtOverlays = 1; grassOverlays = 1},
	"{/build_proxy/turf}/turf/ground:(Ground3)" = new/build_proxy/turf{name = "Ground3"; icon = 'vegeta turf 2016.dmi'; icon_state = "1"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(Ground4)" = new/build_proxy/turf{name = "Ground4"; icon = 'Turfs 12.dmi'; icon_state = "desert"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(Ground10)" = new/build_proxy/turf{name = "Ground10"; icon = 'Turf1.dmi'; icon_state = "light desert"; density = 0; opacity = 0; build_type = /turf/ground; dirtOverlays = 1},
	"{/build_proxy/turf}/turf/ground:(Ground11)" = new/build_proxy/turf{name = "Ground11"; icon = 'Turfs 1.dmi'; icon_state = "crack"; density = 1; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(Ground12)" = new/build_proxy/turf{name = "Ground12"; icon = 'Turfs 1.dmi'; icon_state = "dirt"; density = 0; opacity = 0; build_type = /turf/ground; dirtOverlays = 1},
	"{/build_proxy/turf}/turf/ground:(Ground13)" = new/build_proxy/turf{name = "Ground13"; icon = 'Turfs 1.dmi'; icon_state = "rock"; density = 1; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(Ground14)" = new/build_proxy/turf{name = "Ground14"; icon = 'Big Sand Turf.dmi'; icon_state = "0,0"; density = 0; opacity = 0; build_type = /turf/ground; oversizedIconX = 4; oversizedIconY = 4},
	"{/build_proxy/turf}/turf/ground:(Ground16)" = new/build_proxy/turf{name = "Ground16"; icon = 'FloorsLAWL.dmi'; icon_state = "Flagstone"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(Ground17)" = new/build_proxy/turf{name = "Ground17"; icon = 'Hell Ground 2017.dmi'; icon_state = "0,0"; density = 0; opacity = 0; build_type = /turf/ground; oversizedIconX = 6; oversizedIconY = 6},
	"{/build_proxy/turf}/turf/ground:(Ground18)" = new/build_proxy/turf{name = "Ground18"; icon = 'Big Dirt Turf 2.dmi'; icon_state = "0,0"; density = 0; opacity = 0; build_type = /turf/ground; oversizedIconX = 4; oversizedIconY = 4},
	"{/build_proxy/turf}/turf/ground:(Ground19)" = new/build_proxy/turf{name = "Ground19"; icon = 'Turfs 96.dmi'; icon_state = "darktile"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(Ground Wasteland)" = new/build_proxy/turf{name = "Ground Wasteland"; icon = 'wasteland ground.dmi'; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(GroundPebbles)" = new/build_proxy/turf{name = "GroundPebbles"; icon = 'Turfs 7.dmi'; icon_state = "Sand"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(GroundSnow)" = new/build_proxy/turf{name = "GroundSnow"; icon = 'Big Snow Turf.dmi'; icon_state = "0,0"; density = 0; opacity = 0; build_type = /turf/ground; oversizedIconX = 6; oversizedIconY = 6},
	"{/build_proxy/turf}/turf/ground:(SnowAndRocks)" = new/build_proxy/turf{name = "SnowAndRocks"; icon = 'Big Snow and Rock Turf.dmi'; icon_state = "0,0"; density = 0; opacity = 0; build_type = /turf/ground; oversizedIconX = 6; oversizedIconY = 6},
	"{/build_proxy/turf}/turf/ground:(GroundIce1)" = new/build_proxy/turf{name = "GroundIce1"; icon = 'Big Ice Turf 3.dmi'; icon_state = "0,0"; density = 0; opacity = 0; build_type = /turf/ground; oversizedIconX = 6; oversizedIconY = 6},
	"{/build_proxy/turf}/turf/ground:(GroundIce2)" = new/build_proxy/turf{name = "GroundIce2"; icon = 'Big Ice Turf 2.dmi'; icon_state = "0,0"; density = 0; opacity = 0; build_type = /turf/ground; oversizedIconX = 6; oversizedIconY = 6},
	"{/build_proxy/turf}/turf/ground:(GroundIce3)" = new/build_proxy/turf{name = "GroundIce3"; icon = 'Big Ice Turf.dmi'; icon_state = "0,0"; density = 0; opacity = 0; build_type = /turf/ground; oversizedIconX = 4; oversizedIconY = 4},
	"{/build_proxy/turf}/turf/ground:(GroundDirt)" = new/build_proxy/turf{name = "GroundDirt"; icon = 'Icons/Map/Big Dirt Turfs.dmi'; icon_state = "0,0"; density = 0; opacity = 0; build_type = /turf/ground; oversizedIconX = 4; oversizedIconY = 4},
	"{/build_proxy/turf}/turf/ground:(GroundSandDark)" = new/build_proxy/turf{name = "GroundSandDark"; icon = 'Turf1.dmi'; icon_state = "dark desert"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(GroundDirtSand)" = new/build_proxy/turf{name = "GroundDirtSand"; icon = 'Turfs 96.dmi'; icon_state = "dirt"; density = 0; opacity = 0; build_type = /turf/ground; dirtOverlays = 1},
	"{/build_proxy/turf}/turf/ground:(GroundHell)" = new/build_proxy/turf{name = "GroundHell"; icon = 'Turf 57.dmi'; icon_state = "hellturf1"; density = 0; opacity = 0; build_type = /turf/ground; dirtOverlays = 1},
	"{/build_proxy/turf}/turf/ground:(GrassSluggo)" = new/build_proxy/turf{name = "GrassSluggo"; icon = 'NamekTiles.dmi'; icon_state = "A 1"; variants = list("A 2","A 3","B 1","B 2","A 4","A 5","A 6","F 1","F 2","F 3","F 4","F 5","F 6","F 7","F 8","F 9"); density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground/connector:(Asphalt Road)" = new/build_proxy/turf{name = "Asphalt Road"; icon = 'asphaltroad.dmi'; density = 0; opacity = 0; build_type = /turf/ground/connector},
	"{/build_proxy/turf}/turf/ground:(Grass A)" = new/build_proxy/turf{name = "Grass A"; icon = 'Ground Tiles.dmi'; build_type = /turf/ground; edgeInterior = 0; edgePriority = 10; classification = "grass"; identifier = "a"; variantRange = 3},
	"{/build_proxy/turf}/turf/ground:(Grass B)" = new/build_proxy/turf{name = "Grass B"; icon = 'Ground Tiles.dmi'; build_type = /turf/ground; edgeInterior = 0; edgePriority = 10; classification = "grass"; identifier = "b"; variantRange = 3},
	"{/build_proxy/turf}/turf/ground:(Grass C)" = new/build_proxy/turf{name = "Grass C"; icon = 'Ground Tiles.dmi'; build_type = /turf/ground; edgeInterior = 0; edgePriority = 10; classification = "grass"; identifier = "c"; variantRange = 3},
	"{/build_proxy/turf}/turf/ground:(Grass D)" = new/build_proxy/turf{name = "Grass D"; icon = 'Ground Tiles.dmi'; build_type = /turf/ground; edgeInterior = 0; edgePriority = 10; classification = "grass"; identifier = "d"; variantRange = 3},
	"{/build_proxy/turf}/turf/ground:(Grass E)" = new/build_proxy/turf{name = "Grass E"; icon = 'Ground Tiles.dmi'; build_type = /turf/ground; edgeInterior = 0; edgePriority = 10; classification = "grass"; identifier = "e"; variantRange = 3},
	"{/build_proxy/turf}/turf/ground:(Mud A)" = new/build_proxy/turf{name = "Mud A"; icon = 'Ground Tiles.dmi'; build_type = /turf/ground; edgeInterior = 0; edgePriority = 5; classification = "mud"; identifier = "a"; variantRange = 4},
	"{/build_proxy/turf}/turf/ground:(Snow A)" = new/build_proxy/turf{name = "Snow A"; icon = 'Ground Tiles.dmi'; build_type = /turf/ground; edgeInterior = 0; edgePriority = 5; classification = "snow"; identifier = "a"; variantRange = 3},
	"{/build_proxy/turf}/turf/ground:(Snow B)" = new/build_proxy/turf{name = "Snow B"; icon = 'Ground Tiles.dmi'; build_type = /turf/ground; edgeInterior = 0; edgePriority = 5; classification = "snow"; identifier = "b"; variantRange = 3},
	"{/build_proxy/turf}/turf/ground:(Snow C)" = new/build_proxy/turf{name = "Snow C"; icon = 'Ground Tiles.dmi'; build_type = /turf/ground; edgeInterior = 0; edgePriority = 5; classification = "snow"; identifier = "c"; variantRange = 3},
	"{/build_proxy/turf}/turf/ground:(Ice A)" = new/build_proxy/turf{name = "Ice A"; icon = 'Ground Tiles.dmi'; build_type = /turf/ground; edgeInterior = 0; classification = "ice"; identifier = "a"; variantRange = 3},
	"{/build_proxy/turf}/turf/ground:(Ice B)" = new/build_proxy/turf{name = "Ice B"; icon = 'Ground Tiles.dmi'; build_type = /turf/ground; edgeInterior = 0; classification = "ice"; identifier = "b"; variantRange = 3},
	"{/build_proxy/turf}/turf/ground:(Ice C)" = new/build_proxy/turf{name = "Ice C"; icon = 'Ground Tiles.dmi'; build_type = /turf/ground; edgeInterior = 0; classification = "ice"; identifier = "c"; variantRange = 3},
	"{/build_proxy/turf}/turf/ground:(Sand A)" = new/build_proxy/turf{name = "Sand A"; icon = 'Ground Tiles.dmi'; build_type = /turf/ground; edgeInterior = 0; classification = "sand"; identifier = "a"; variantRange = 3},
	"{/build_proxy/turf}/turf/ground:(Sand B)" = new/build_proxy/turf{name = "Sand B"; icon = 'Ground Tiles.dmi'; build_type = /turf/ground; edgeInterior = 0; classification = "sand"; identifier = "b"; variantRange = 3},
	"{/build_proxy/turf}/turf/ground:(Cobble A)" = new/build_proxy/turf{name = "Cobble A"; icon = 'Ground Tiles.dmi'; build_type = /turf/ground; edgeInterior = 0; classification = "cobble"; identifier = "a"; variantRange = 3},
	"{/build_proxy/turf}/turf/ground:(Cobble B)" = new/build_proxy/turf{name = "Cobble B"; icon = 'Ground Tiles.dmi'; build_type = /turf/ground; edgeInterior = 0; classification = "cobble"; identifier = "b"; variantRange = 1}
)
var/list/stairsPalette = list(
	"{/build_proxy/turf}/turf/ground:(Stairs1)" = new/build_proxy/turf{name = "Stairs1"; icon = 'Turfs 96.dmi'; icon_state = "steps"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(Stairs2)" = new/build_proxy/turf{name = "Stairs2"; icon = 'Turfs 12.dmi'; icon_state = "Steps"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(Stairs3)" = new/build_proxy/turf{name = "Stairs3"; icon = 'Turfs 1.dmi'; icon_state = "stairs2"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(Stairs4)" = new/build_proxy/turf{name = "Stairs4"; icon = 'Turfs 1.dmi'; icon_state = "stairs1"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(Stairs5)" = new/build_proxy/turf{name = "Stairs5"; icon = 'Turfs 1.dmi'; icon_state = "earthstairs"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(Stairs6)" = new/build_proxy/turf{name = "Stairs6"; icon = 'Turfs Temple.dmi'; icon_state = "council"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(Stairs Grass)" = new/build_proxy/turf{name = "Stairs Grass"; icon = 'celianna_farmnature_tileset.dmi'; icon_state = "Grass_Stairs"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(StairsHell)" = new/build_proxy/turf{name = "StairsHell"; icon = 'Turf 57.dmi'; icon_state = "hellstairs"; density = 0; opacity = 0; build_type = /turf/ground}
)
var/list/tilePalette = list(
	"{/build_proxy/turf}/turf/ground:(Tile Landing Bay)" = new/build_proxy/turf{name = "Tile Landing Bay"; icon = 'Tech Bay Floor.dmi'; icon_state = "0,0"; density = 0; opacity = 0; build_type = /turf/ground; oversizedIconX = 8; oversizedIconY = 8},
	"{/build_proxy/turf}/turf/ground:(Tile Tech Floor)" = new/build_proxy/turf{name = "Tile Tech Floor"; icon = 'tech floor.dmi'; icon_state = "0,0"; density = 0; opacity = 0; build_type = /turf/ground; oversizedIconX = 10; oversizedIconY = 10},
	"{/build_proxy/turf}/turf/ground:(Tile16)" = new/build_proxy/turf{name = "Tile16"; icon = 'Turfs 14.dmi'; icon_state = "Stone"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(Tile Tech Dark)" = new/build_proxy/turf{name = "Tile Tech Dark"; icon = 'Tech Floor Dark.dmi'; icon_state = "0,0"; density = 0; opacity = 0; build_type = /turf/ground; oversizedIconX = 8; oversizedIconY = 8},
	"{/build_proxy/turf}/turf/ground:(Tile Tech Grate)" = new/build_proxy/turf{name = "Tile Tech Grate"; icon = 'tech floor grate.dmi'; icon_state = "0,0"; density = 0; opacity = 0; build_type = /turf/ground; oversizedIconX = 2; oversizedIconY = 2},
	"{/build_proxy/turf}/turf/ground:(Tile40)" = new/build_proxy/turf{name = "Tile40"; icon = 'metaltiles1.dmi'; icon_state = "gratingfloora"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(Tile Hell1)" = new/build_proxy/turf{name = "Tile Hell1"; icon = 'Hell turf.dmi'; icon_state = "h1"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(Tile Hell2)" = new/build_proxy/turf{name = "Tile Hell2"; icon = 'Hell turf.dmi'; icon_state = "h3"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(Tile Hell4)" = new/build_proxy/turf{name = "Tile Hell4"; icon = 'Hell turf.dmi'; icon_state = "h5"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(Tile54)" = new/build_proxy/turf{name = "Tile54"; icon = 'Tiles 1.21.2011.dmi'; icon_state = "25"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(Tile43)" = new/build_proxy/turf{name = "Tile43"; icon = 'Tiles 1.21.2011.dmi'; icon_state = "a 1"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(Tile32)" = new/build_proxy/turf{name = "Tile32"; icon = 'Turfs Temple.dmi'; icon_state = "tile"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(Tile33)" = new/build_proxy/turf{name = "Tile33"; icon = 'Turfs Temple.dmi'; icon_state = "tile2"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(Tile34)" = new/build_proxy/turf{name = "Tile34"; icon = 'Turfs Temple.dmi'; icon_state = "tile3"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(Tile35)" = new/build_proxy/turf{name = "Tile35"; icon = 'Turfs Temple.dmi'; icon_state = "tile4"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(TileWhite)" = new/build_proxy/turf{name = "TileWhite"; icon = 'White.dmi'; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(Tile3)" = new/build_proxy/turf{name = "Tile3"; icon = 'Turfs 12.dmi'; icon_state = "Stones"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(Tile26)" = new/build_proxy/turf{name = "Tile26"; icon = 'turfs.dmi'; icon_state = "tile9"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(Tile2)" = new/build_proxy/turf{name = "Tile2"; icon = 'Turfs 12.dmi'; icon_state = "Stone Crystal Path"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(Tile21)" = new/build_proxy/turf{name = "Tile21"; icon = 'Turfs 12.dmi'; icon_state = "Girly Carpet"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(TileStone)" = new/build_proxy/turf{name = "TileStone"; icon = 'Turf 57.dmi'; icon_state = "55"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(Tile14)" = new/build_proxy/turf{name = "Tile14"; icon = 'turfs.dmi'; icon_state = "tile10"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(Tile12)" = new/build_proxy/turf{name = "Tile12"; icon = 'Turfs 15.dmi'; icon_state = "floor7"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(Tile52)" = new/build_proxy/turf{name = "Tile52"; icon = 'Tiles 1.21.2011.dmi'; icon_state = "19"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(Tile24)" = new/build_proxy/turf{name = "Tile24"; icon = 'turfs.dmi'; icon_state = "bridgemid2"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(Tile22)" = new/build_proxy/turf{name = "Tile22"; icon = 'FloorsLAWL.dmi'; icon_state = "SS Floor"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(Tile18)" = new/build_proxy/turf{name = "Tile18"; icon = 'Turfs 12.dmi'; icon_state = "Aluminum Floor"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(Tile46)" = new/build_proxy/turf{name = "Tile46"; icon = 'Tiles 1.21.2011.dmi'; icon_state = "3"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(Tile25)" = new/build_proxy/turf{name = "Tile25"; icon = 'Turfs 4.dmi'; icon_state = "cooltiles"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(Tile23)" = new/build_proxy/turf{name = "Tile23"; icon = 'Turfs 12.dmi'; icon_state = "Wood_Floor"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(Tile17)" = new/build_proxy/turf{name = "Tile17"; icon = 'turfs.dmi'; icon_state = "roof4"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(Tile10)" = new/build_proxy/turf{name = "Tile10"; icon = 'FloorsLAWL.dmi'; icon_state = "Flagstone Vegeta"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(TileGold)" = new/build_proxy/turf{name = "TileGold"; icon = 'Turf 55.dmi'; icon_state = "goldfloor"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(Tile15)" = new/build_proxy/turf{name = "Tile15"; icon = 'Turfs 12.dmi'; icon_state = "stonefloor"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(Tile13)" = new/build_proxy/turf{name = "Tile13"; icon = 'Turfs 15.dmi'; icon_state = "floor6"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(Tile20)" = new/build_proxy/turf{name = "Tile20"; icon = 'turfs.dmi'; icon_state = "tile4"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(Tile4)" = new/build_proxy/turf{name = "Tile4"; icon = 'Turfs 12.dmi'; icon_state = "Black Tile"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(Tile6)" = new/build_proxy/turf{name = "Tile6"; icon = 'Turfs 12.dmi'; icon_state = "floor4"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(Tile51)" = new/build_proxy/turf{name = "Tile51"; icon = 'Tiles 1.21.2011.dmi'; icon_state = "18"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(Tile5)" = new/build_proxy/turf{name = "Tile5"; icon = 'Turfs 12.dmi'; icon_state = "Dirty Brick"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(TileBlue)" = new/build_proxy/turf{name = "TileBlue"; icon = 'turfs.dmi'; icon_state = "tile11"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(Porcelain Plank Vertical)" = new/build_proxy/turf{name = "Porcelain Plank Vertical"; icon = 'Floor Tiles.dmi'; build_type = /turf/ground; classification = "porcelain"; identifier = "vertical"; variantRange = 1},
	"{/build_proxy/turf}/turf/ground:(Porcelain Plank Horizontal)" = new/build_proxy/turf{name = "Porcelain Plank Horizontal"; icon = 'Floor Tiles.dmi'; build_type = /turf/ground; classification = "porcelain"; identifier = "horizontal"; variantRange = 1},
	"{/build_proxy/turf}/turf/ground:(Horizontal Wood Planks A)" = new/build_proxy/turf{name = "Horizontal Wood Planks A"; icon = 'Floor Tiles.dmi'; build_type = /turf/ground; classification = "wood"; identifier = "a1"; variantRange = 1},
	"{/build_proxy/turf}/turf/ground:(Vertical Wood Planks A)" = new/build_proxy/turf{name = "Vertical Wood Planks A"; icon = 'Floor Tiles.dmi'; build_type = /turf/ground; classification = "wood"; identifier = "a2"; variantRange = 1},
	"{/build_proxy/turf}/turf/ground:(Horizontal Wood Planks B)" = new/build_proxy/turf{name = "Horizontal Wood Planks B"; icon = 'Floor Tiles.dmi'; build_type = /turf/ground; classification = "wood"; identifier = "b1"; variantRange = 1},
	"{/build_proxy/turf}/turf/ground:(Vertical Wood Planks B)" = new/build_proxy/turf{name = "Vertical Wood Planks B"; icon = 'Floor Tiles.dmi'; build_type = /turf/ground; classification = "wood"; identifier = "b2"; variantRange = 1},
	"{/build_proxy/turf}/turf/ground:(Horizontal Wood Planks C)" = new/build_proxy/turf{name = "Horizontal Wood Planks C"; icon = 'Floor Tiles.dmi'; build_type = /turf/ground; classification = "wood"; identifier = "c1"; variantRange = 1},
	"{/build_proxy/turf}/turf/ground:(Vertical Wood Planks C)" = new/build_proxy/turf{name = "Vertical Wood Planks C"; icon = 'Floor Tiles.dmi'; build_type = /turf/ground; classification = "wood"; identifier = "c2"; variantRange = 1},
	"{/build_proxy/turf}/turf/ground:(Horizontal Wood Planks D)" = new/build_proxy/turf{name = "Horizontal Wood Planks D"; icon = 'Floor Tiles.dmi'; build_type = /turf/ground; classification = "wood"; identifier = "d1"; variantRange = 1},
	"{/build_proxy/turf}/turf/ground:(Vertical Wood Planks D)" = new/build_proxy/turf{name = "Vertical Wood Planks D"; icon = 'Floor Tiles.dmi'; build_type = /turf/ground; classification = "wood"; identifier = "d2"; variantRange = 1},
	"{/build_proxy/turf}/turf/ground:(Horizontal Wood Planks E)" = new/build_proxy/turf{name = "Horizontal Wood Planks E"; icon = 'Floor Tiles.dmi'; build_type = /turf/ground; classification = "wood"; identifier = "e1"; variantRange = 1},
	"{/build_proxy/turf}/turf/ground:(Vertical Wood Planks E)" = new/build_proxy/turf{name = "Vertical Wood Planks E"; icon = 'Floor Tiles.dmi'; build_type = /turf/ground; classification = "wood"; identifier = "e2"; variantRange = 1},
	"{/build_proxy/turf}/turf/ground:(Horizontal Wood Planks F)" = new/build_proxy/turf{name = "Horizontal Wood Planks F"; icon = 'Floor Tiles.dmi'; build_type = /turf/ground; classification = "wood"; identifier = "f1"; variantRange = 1},
	"{/build_proxy/turf}/turf/ground:(Vertical Wood Planks F)" = new/build_proxy/turf{name = "Vertical Wood Planks F"; icon = 'Floor Tiles.dmi'; build_type = /turf/ground; classification = "wood"; identifier = "f2"; variantRange = 1},
	"{/build_proxy/turf}/turf/ground:(Quad Tile A)" = new/build_proxy/turf{name = "Quad Tile A"; icon = 'Floor Tiles.dmi'; build_type = /turf/ground; classification = "tile"; identifier = "quad1"; variantRange = 1},
	"{/build_proxy/turf}/turf/ground:(Quad Tile B)" = new/build_proxy/turf{name = "Quad Tile B"; icon = 'Floor Tiles.dmi'; build_type = /turf/ground; classification = "tile"; identifier = "quad2"; variantRange = 1},
	"{/build_proxy/turf}/turf/ground:(Quad Tile C)" = new/build_proxy/turf{name = "Quad Tile C"; icon = 'Floor Tiles.dmi'; build_type = /turf/ground; classification = "tile"; identifier = "quad3"; variantRange = 1},
	"{/build_proxy/turf}/turf/ground:(Quad Tile D)" = new/build_proxy/turf{name = "Quad Tile D"; icon = 'Floor Tiles.dmi'; build_type = /turf/ground; classification = "tile"; identifier = "quad4"; variantRange = 1},
	"{/build_proxy/turf}/turf/ground:(Quad Tile E)" = new/build_proxy/turf{name = "Quad Tile E"; icon = 'Floor Tiles.dmi'; build_type = /turf/ground; classification = "tile"; identifier = "quad5"; variantRange = 1},
	"{/build_proxy/turf}/turf/ground:(Quad Tile F)" = new/build_proxy/turf{name = "Quad Tile F"; icon = 'Floor Tiles.dmi'; build_type = /turf/ground; classification = "tile"; identifier = "quad6"; variantRange = 1},
	"{/build_proxy/turf}/turf/ground:(Quad Tile G)" = new/build_proxy/turf{name = "Quad Tile G"; icon = 'Floor Tiles.dmi'; build_type = /turf/ground; classification = "tile"; identifier = "quad7"; variantRange = 1},
	"{/build_proxy/turf}/turf/ground:(Full Tile A)" = new/build_proxy/turf{name = "Full Tile A"; icon = 'Floor Tiles.dmi'; build_type = /turf/ground; classification = "tile"; identifier = "whole1"; variantRange = 1},
	"{/build_proxy/turf}/turf/ground:(Full Tile B)" = new/build_proxy/turf{name = "Full Tile B"; icon = 'Floor Tiles.dmi'; build_type = /turf/ground; classification = "tile"; identifier = "whole2"; variantRange = 1},
	"{/build_proxy/turf}/turf/ground:(Full Tile C)" = new/build_proxy/turf{name = "Full Tile C"; icon = 'Floor Tiles.dmi'; build_type = /turf/ground; classification = "tile"; identifier = "whole3"; variantRange = 1},
	"{/build_proxy/turf}/turf/ground:(Full Tile D)" = new/build_proxy/turf{name = "Full Tile D"; icon = 'Floor Tiles.dmi'; build_type = /turf/ground; classification = "tile"; identifier = "whole4"; variantRange = 1},
	"{/build_proxy/turf}/turf/ground:(Full Tile E)" = new/build_proxy/turf{name = "Full Tile E"; icon = 'Floor Tiles.dmi'; build_type = /turf/ground; classification = "tile"; identifier = "whole5"; variantRange = 1},
	"{/build_proxy/turf}/turf/ground:(Carpet A)" = new/build_proxy/turf{name = "Carpet A"; icon = 'Floor Tiles.dmi'; build_type = /turf/ground; classification = "carpet"; identifier = "textured"; variantRange = 4}
)
var/list/roofPalette = list(
	"{/build_proxy/turf}/turf/wall/roof:(Roof1)" = new/build_proxy/turf{name = "Roof1"; icon = 'Turfs 96.dmi'; icon_state = "roof3"; density = 1; opacity = 1; build_type = /turf/wall/roof},
	"{/build_proxy/turf}/turf/wall/roof:(Roof2)" = new/build_proxy/turf{name = "Roof2"; icon = 'turfs.dmi'; icon_state = "roof2"; density = 1; opacity = 1; build_type = /turf/wall/roof},
	"{/build_proxy/turf}/turf/wall/roof:(Roof3)" = new/build_proxy/turf{name = "Roof3"; icon = 'Turfs 96.dmi'; icon_state = "roof4"; density = 1; opacity = 1; build_type = /turf/wall/roof},
	"{/build_proxy/turf}/turf/wall/roof:(Roof4)" = new/build_proxy/turf{name = "Roof4"; icon = 'metaltiles1.dmi'; icon_state = "metalroofa"; density = 1; opacity = 1; build_type = /turf/wall/roof},
	"{/build_proxy/turf}/turf/wall/roof:(Roof5)" = new/build_proxy/turf{name = "Roof5"; icon = 'metaltiles1.dmi'; icon_state = "metalroofb"; density = 1; opacity = 1; build_type = /turf/wall/roof},
	"{/build_proxy/turf}/turf/wall/roof:(Roof6)" = new/build_proxy/turf{name = "Roof6"; icon = 'metaltiles1.dmi'; icon_state = "metalroofc"; density = 1; opacity = 1; build_type = /turf/wall/roof},
	"{/build_proxy/turf}/turf/wall/roof:(Roof7)" = new/build_proxy/turf{name = "Roof7"; icon = 'Tiles 1.21.2011.dmi'; icon_state = "Roof"; density = 1; opacity = 1; build_type = /turf/wall/roof},
	"{/build_proxy/turf}/turf/wall/roof:(Roof8)" = new/build_proxy/turf{name = "Roof8"; icon = 'Tiles 1.21.2011.dmi'; icon_state = "Roof-5"; density = 1; opacity = 1; build_type = /turf/wall/roof},
	"{/build_proxy/turf}/turf/wall/roof:(Roof9)" = new/build_proxy/turf{name = "Roof9"; icon = 'Tiles 1.21.2011.dmi'; icon_state = "Roof-1"; density = 1; opacity = 1; build_type = /turf/wall/roof},
	"{/build_proxy/turf}/turf/wall/roof:(Roof10)" = new/build_proxy/turf{name = "Roof10"; icon = 'Tiles 1.21.2011.dmi'; icon_state = "Roof-2"; density = 1; opacity = 1; build_type = /turf/wall/roof},
	"{/build_proxy/turf}/turf/wall/roof:(Roof 11)" = new/build_proxy/turf{name = "Roof 11"; icon = 'TileA3.dmi'; icon_state = "BlueRoof3"; density = 1; opacity = 1; build_type = /turf/wall/roof},
	"{/build_proxy/turf}/turf/wall/roof:(RoofWhite)" = new/build_proxy/turf{name = "RoofWhite"; icon = 'turfs.dmi'; icon_state = "block_wall1"; density = 1; opacity = 1; build_type = /turf/wall/roof},
	"{/build_proxy/turf}/turf/wall/roof:(Roof Purple Plain)" = new/build_proxy/turf{name = "Roof Purple Plain"; icon = 'purple block.dmi'; density = 1; opacity = 1; build_type = /turf/wall/roof},
	"{/build_proxy/turf}/turf/wall/roof:(RoofTech)" = new/build_proxy/turf{name = "RoofTech"; icon = 'Space.dmi'; icon_state = "top"; density = 1; opacity = 1; build_type = /turf/wall/roof},
	"{/build_proxy/turf}/turf/wall/roof:(Tech Roof)" = new/build_proxy/turf{name = "Tech Roof"; icon = 'sci fi roof.dmi'; density = 1; opacity = 1; build_type = /turf/wall/roof},
	"{/build_proxy/turf}/turf/wall/roof:(Prison Wall)" = new/build_proxy/turf{name = "Prison Wall"; icon = 'Space.dmi'; icon_state = "top"; density = 1; opacity = 1; build_type = /turf/wall/roof},
	"{/build_proxy/turf}/turf/wall/roof:(Hell Roof)" = new/build_proxy/turf{name = "Hell Roof"; icon = 'Hell turf.dmi'; density = 1; opacity = 1; build_type = /turf/wall/roof},
	"{/build_proxy/turf}/turf/wall/roof:(Roof Shingled A)" = new/build_proxy/turf{name = "Roof Shingled A"; icon = 'Roof Tiles.dmi'; build_type = /turf/wall/roof; classification = "shingle"; identifier = "a"; variantRange = 1; density = 1; opacity = 1; },
	"{/build_proxy/turf}/turf/wall/roof:(Roof Shingled B)" = new/build_proxy/turf{name = "Roof Shingled B"; icon = 'Roof Tiles.dmi'; build_type = /turf/wall/roof; classification = "shingle"; identifier = "b"; variantRange = 1; density = 1; opacity = 1; },
	"{/build_proxy/turf}/turf/wall/roof:(Roof Shingled C)" = new/build_proxy/turf{name = "Roof Shingled C"; icon = 'Roof Tiles.dmi'; build_type = /turf/wall/roof; classification = "shingle"; identifier = "c"; variantRange = 1; density = 1; opacity = 1; },
	"{/build_proxy/turf}/turf/wall/roof:(Roof Tin A)" = new/build_proxy/turf{name = "Roof Tin A"; icon = 'Roof Tiles.dmi'; build_type = /turf/wall/roof; classification = "tin"; identifier = "a"; variantRange = 1; density = 1; opacity = 1; },
	"{/build_proxy/turf}/turf/wall/roof:(Roof Thatched A)" = new/build_proxy/turf{name = "Roof Thatched A"; icon = 'Roof Tiles.dmi'; build_type = /turf/wall/roof; classification = "thatch"; identifier = "a"; variantRange = 1; density = 1; opacity = 1; }
)
var/list/wallPalette = list(
	"{/build_proxy/turf}/turf/wall:(Wall1)" = new/build_proxy/turf{name = "Wall1"; icon = 'turfs.dmi'; icon_state = "tile5"; density = 1; opacity = 0; build_type = /turf/wall},
	"{/build_proxy/turf}/turf/wall:(Wall2)" = new/build_proxy/turf{name = "Wall2"; icon = 'Turfs 1.dmi'; icon_state = "wall6"; density = 1; opacity = 0; build_type = /turf/wall},
	"{/build_proxy/turf}/turf/wall:(Wall3)" = new/build_proxy/turf{name = "Wall3"; icon = 'Turfs 4.dmi'; icon_state = "wall"; density = 1; opacity = 0; build_type = /turf/wall},
	"{/build_proxy/turf}/turf/wall:(Wall5)" = new/build_proxy/turf{name = "Wall5"; icon = 'turfs.dmi'; icon_state = "tile1"; density = 1; opacity = 0; build_type = /turf/wall},
	"{/build_proxy/turf}/turf/wall:(Wall6)" = new/build_proxy/turf{name = "Wall6"; icon = 'Turfs 2.dmi'; icon_state = "brick2"; density = 1; opacity = 0; build_type = /turf/wall},
	"{/build_proxy/turf}/turf/wall:(Wall7)" = new/build_proxy/turf{name = "Wall7"; icon = 'Turfs 1.dmi'; icon_state = "cliff"; density = 1; opacity = 0; build_type = /turf/wall},
	"{/build_proxy/turf}/turf/wall:(Wall8)" = new/build_proxy/turf{name = "Wall8"; icon = 'Turfs 15.dmi'; icon_state = "wall2"; density = 1; opacity = 0; build_type = /turf/wall},
	"{/build_proxy/turf}/turf/wall:(Wall10)" = new/build_proxy/turf{name = "Wall10"; icon = 'Turfs 4.dmi'; icon_state = "ice cliff"; density = 1; opacity = 0; build_type = /turf/wall},
	"{/build_proxy/turf}/turf/wall:(Wall11)" = new/build_proxy/turf{name = "Wall11"; icon = 'Turfs 18.dmi'; icon_state = "stone"; density = 1; opacity = 0; build_type = /turf/wall},
	"{/build_proxy/turf}/turf/wall:(Wall12)" = new/build_proxy/turf{name = "Wall12"; icon = 'Turfs 3.dmi'; icon_state = "cliff"; density = 1; opacity = 0; build_type = /turf/wall},
	"{/build_proxy/turf}/turf/wall:(Wall13)" = new/build_proxy/turf{name = "Wall13"; icon = 'turfs.dmi'; icon_state = "wall8"; density = 1; opacity = 0; build_type = /turf/wall},
	"{/build_proxy/turf}/turf/wall:(Wall15)" = new/build_proxy/turf{name = "Wall15"; icon = 'Turf1.dmi'; icon_state = "1"; density = 1; opacity = 0; build_type = /turf/wall},
	"{/build_proxy/turf}/turf/wall:(Wall16)" = new/build_proxy/turf{name = "Wall16"; icon = 'Turf 50.dmi'; icon_state = "2.6"; density = 1; opacity = 0; build_type = /turf/wall},
	"{/build_proxy/turf}/turf/wall:(Wall17)" = new/build_proxy/turf{name = "Wall17"; icon = 'Turf 57.dmi'; icon_state = "1"; density = 1; opacity = 0; build_type = /turf/wall},
	"{/build_proxy/turf}/turf/wall:(Wall18)" = new/build_proxy/turf{name = "Wall18"; icon = 'Turf 57.dmi'; icon_state = "2"; density = 1; opacity = 0; build_type = /turf/wall},
	"{/build_proxy/turf}/turf/wall:(Wall19)" = new/build_proxy/turf{name = "Wall19"; icon = 'Turf 57.dmi'; icon_state = "3"; density = 1; opacity = 0; build_type = /turf/wall},
	"{/build_proxy/turf}/turf/wall:(Wall20)" = new/build_proxy/turf{name = "Wall20"; icon = 'Turfs Temple.dmi'; icon_state = "wall2"; density = 1; opacity = 0; build_type = /turf/wall},
	"{/build_proxy/turf}/turf/wall:(MetalWallA)" = new/build_proxy/turf{name = "MetalWallA"; icon = 'metaltiles1.dmi'; icon_state = "metalwalla"; density = 1; opacity = 0; build_type = /turf/wall},
	"{/build_proxy/turf}/turf/wall:(MetalWallB)" = new/build_proxy/turf{name = "MetalWallB"; icon = 'metaltiles1.dmi'; icon_state = "metalwallb"; density = 1; opacity = 0; build_type = /turf/wall},
	"{/build_proxy/turf}/turf/wall:(WallStone1)" = new/build_proxy/turf{name = "WallStone1"; icon = 'Turf 57.dmi'; icon_state = "stonewall2"; density = 1; opacity = 0; build_type = /turf/wall},
	"{/build_proxy/turf}/turf/wall:(WallStone2)" = new/build_proxy/turf{name = "WallStone2"; icon = 'Turf 57.dmi'; icon_state = "stonewall4"; density = 1; opacity = 0; build_type = /turf/wall},
	"{/build_proxy/turf}/turf/wall:(WallStone3)" = new/build_proxy/turf{name = "WallStone3"; icon = 'Turf 57.dmi'; icon_state = "wall3"; density = 1; opacity = 0; build_type = /turf/wall},
	"{/build_proxy/turf}/turf/wall:(WallSand)" = new/build_proxy/turf{name = "WallSand"; icon = 'Turf 50.dmi'; icon_state = "3.2"; density = 1; opacity = 0; build_type = /turf/wall},
	"{/build_proxy/turf}/turf/wall:(WallTan)" = new/build_proxy/turf{name = "WallTan"; icon = 'tan block.dmi'; density = 1; opacity = 0; build_type = /turf/wall},
	"{/build_proxy/turf}/turf/wall:(BrickWall)" = new/build_proxy/turf{name = "BrickWall"; icon = 'brickwall.dmi'; density = 1; opacity = 0; build_type = /turf/wall},
	"{/build_proxy/turf}/turf/wall:(DarkStoneWall)" = new/build_proxy/turf{name = "DarkStoneWall"; icon = 'darkstonewall.dmi'; density = 1; opacity = 0; build_type = /turf/wall},
	"{/build_proxy/turf}/turf/wall:(WallTech)" = new/build_proxy/turf{name = "WallTech"; icon = 'Space.dmi'; icon_state = "bottom"; density = 1; opacity = 0; build_type = /turf/wall},
	"{/build_proxy/turf}/turf/wall/patterned:(Wall Wood)" = new/build_proxy/turf{name = "Wall Wood"; icon = 'celianna_clutter_walls2.dmi'; states = list("Dark_Wood_Wall_1", "Dark_Wood_Wall_2"); density = 1; opacity = 0; build_type = /turf/wall/patterned},
	"{/build_proxy/turf}/turf/wall/patterned:(Wall Wood 2)" = new/build_proxy/turf{name = "Wall Wood 2"; icon = 'celianna_clutter_walls2.dmi'; states = list("Dark_Wood_Wall_3", "Dark_Wood_Wall_4"); density = 1; opacity = 0; build_type = /turf/wall/patterned},
	"{/build_proxy/turf}/turf/wall/patterned:(Wall Rock Panels)" = new/build_proxy/turf{name = "Wall Rock Panels"; icon = 'celianna_clutter_walls2_Part2.dmi'; states = list("Paneled_Wall_3", "Paneled_Wall_4"); density = 1; opacity = 0; build_type = /turf/wall/patterned},
	"{/build_proxy/turf}/turf/wall/patterned:(Wall Framed)" = new/build_proxy/turf{name = "Wall Framed"; icon = 'celianna_clutter_walls2.dmi'; states = list("Framed_Wall_1", "Framed_Wall_2"); density = 1; opacity = 0; build_type = /turf/wall/patterned},
	"{/build_proxy/turf}/turf/wall/patterned:(Wall Blue)" = new/build_proxy/turf{name = "Wall Blue"; icon = 'celianna_clutter_walls2_Part2.dmi'; states = list("Blue_Wall_3", "Blue_Wall_4"); density = 1; opacity = 0; build_type = /turf/wall/patterned},
	"{/build_proxy/turf}/turf/wall:(Wall Striped A)" = new/build_proxy/turf{name = "Wall Striped A"; icon = 'Wall Tiles.dmi'; build_type = /turf/wall; classification = "interior"; identifier = "striped1"; variantRange = 1},
	"{/build_proxy/turf}/turf/wall:(Wall Striped B)" = new/build_proxy/turf{name = "Wall Striped B"; icon = 'Wall Tiles.dmi'; build_type = /turf/wall; classification = "interior"; identifier = "striped2"; variantRange = 1},
	"{/build_proxy/turf}/turf/wall:(Wall Striped C)" = new/build_proxy/turf{name = "Wall Striped C"; icon = 'Wall Tiles.dmi'; build_type = /turf/wall; classification = "interior"; identifier = "striped3"; variantRange = 1},
	"{/build_proxy/turf}/turf/wall:(Wall Striped D)" = new/build_proxy/turf{name = "Wall Striped D"; icon = 'Wall Tiles.dmi'; build_type = /turf/wall; classification = "interior"; identifier = "striped4"; variantRange = 1},
	"{/build_proxy/turf}/turf/wall:(Wall Striped E)" = new/build_proxy/turf{name = "Wall Striped E"; icon = 'Wall Tiles.dmi'; build_type = /turf/wall; classification = "interior"; identifier = "striped5"; variantRange = 1},
	"{/build_proxy/turf}/turf/wall:(Wall Striped F)" = new/build_proxy/turf{name = "Wall Striped F"; icon = 'Wall Tiles.dmi'; build_type = /turf/wall; classification = "interior"; identifier = "striped6"; variantRange = 1},
	"{/build_proxy/turf}/turf/wall:(Wall Drywall A)" = new/build_proxy/turf{name = "Wall Drywall A"; icon = 'Wall Tiles.dmi'; build_type = /turf/wall; classification = "interior"; identifier = "textured"; variantRange = 2},
	"{/build_proxy/turf}/turf/wall:(Wall Drywall B)" = new/build_proxy/turf{name = "Wall Drywall B"; icon = 'Wall Tiles.dmi'; build_type = /turf/wall; classification = "interior"; identifier = "textured3"; variantRange = 1},
	"{/build_proxy/turf}/turf/wall:(Wall Drywall C)" = new/build_proxy/turf{name = "Wall Drywall C"; icon = 'Wall Tiles.dmi'; build_type = /turf/wall; classification = "interior"; identifier = "smooth1"; variantRange = 1},
	"{/build_proxy/turf}/turf/wall:(Wall Wood A)" = new/build_proxy/turf{name = "Wall Wood A"; icon = 'Wall Tiles.dmi'; build_type = /turf/wall; classification = "interior"; identifier = "wood1"; variantRange = 1},
	"{/build_proxy/turf}/turf/wall:(Wall Wood B)" = new/build_proxy/turf{name = "Wall Wood B"; icon = 'Wall Tiles.dmi'; build_type = /turf/wall; classification = "interior"; identifier = "wood2"; variantRange = 1},
	"{/build_proxy/turf}/turf/wall:(Wall Wood C)" = new/build_proxy/turf{name = "Wall Wood C"; icon = 'Wall Tiles.dmi'; build_type = /turf/wall; classification = "interior"; identifier = "wood3"; variantRange = 1},
	"{/build_proxy/turf}/turf/wall:(Wall Wood D)" = new/build_proxy/turf{name = "Wall Wood D"; icon = 'Wall Tiles.dmi'; build_type = /turf/wall; classification = "interior"; identifier = "wood4"; variantRange = 1},
	"{/build_proxy/turf}/turf/wall:(Wall Wood E)" = new/build_proxy/turf{name = "Wall Wood E"; icon = 'Wall Tiles.dmi'; build_type = /turf/wall; classification = "interior"; identifier = "wood5"; variantRange = 1},
	"{/build_proxy/turf}/turf/wall:(Wall Wood F)" = new/build_proxy/turf{name = "Wall Wood F"; icon = 'Wall Tiles.dmi'; build_type = /turf/wall; classification = "interior"; identifier = "wood6"; variantRange = 1},
	"{/build_proxy/turf}/turf/wall:(Wall Slatted A)" = new/build_proxy/turf{name = "Wall Slatted A"; icon = 'Wall Tiles.dmi'; build_type = /turf/wall; classification = "exterior"; identifier = "slatted"; variantRange = 1},
	"{/build_proxy/turf}/turf/wall:(Wall Brick A)" = new/build_proxy/turf{name = "Wall Brick A"; icon = 'Wall Tiles.dmi'; build_type = /turf/wall; classification = "exterior"; identifier = "brick"; variantRange = 1},
	"{/build_proxy/turf}/turf/wall:(Wall Stone A)" = new/build_proxy/turf{name = "Wall Stone A"; icon = 'Wall Tiles.dmi'; build_type = /turf/wall; classification = "exterior"; identifier = "stone1"; variantRange = 1},
	"{/build_proxy/turf}/turf/wall:(Wall Stone B)" = new/build_proxy/turf{name = "Wall Stone B"; icon = 'Wall Tiles.dmi'; build_type = /turf/wall; classification = "exterior"; identifier = "stone2"; variantRange = 1},
	"{/build_proxy/turf}/turf/wall:(Wall Stone C)" = new/build_proxy/turf{name = "Wall Stone C"; icon = 'Wall Tiles.dmi'; build_type = /turf/wall; classification = "exterior"; identifier = "stone3"; variantRange = 1},
	"{/build_proxy/turf}/turf/wall:(Wall Rock A)" = new/build_proxy/turf{name = "Wall Rock A"; icon = 'Wall Tiles.dmi'; build_type = /turf/wall; classification = "exterior"; identifier = "rock1"; variantRange = 1},
	"{/build_proxy/turf}/turf/wall:(Wall Rock B)" = new/build_proxy/turf{name = "Wall Rock B"; icon = 'Wall Tiles.dmi'; build_type = /turf/wall; classification = "exterior"; identifier = "rock2"; variantRange = 1},
	"{/build_proxy/turf}/turf/wall:(Wall Rock C)" = new/build_proxy/turf{name = "Wall Rock C"; icon = 'Wall Tiles.dmi'; build_type = /turf/wall; classification = "exterior"; identifier = "rock3"; variantRange = 1},
	"{/build_proxy/turf}/turf/wall:(Wall Glass A)" = new/build_proxy/turf{name = "Wall Glass A"; icon = 'Wall Tiles.dmi'; build_type = /turf/wall; classification = "exterior"; identifier = "glass1"; variantRange = 1},
	"{/build_proxy/turf}/turf/wall:(Wall Glass B)" = new/build_proxy/turf{name = "Wall Glass B"; icon = 'Wall Tiles.dmi'; build_type = /turf/wall; classification = "exterior"; identifier = "glass2"; variantRange = 1},
	"{/build_proxy/turf}/turf/wall:(Wall Glass C)" = new/build_proxy/turf{name = "Wall Glass C"; icon = 'Wall Tiles.dmi'; build_type = /turf/wall; classification = "exterior"; identifier = "glass3"; variantRange = 1},
	"{/build_proxy/turf}/turf/wall:(Wall Glass D)" = new/build_proxy/turf{name = "Wall Glass D"; icon = 'Wall Tiles.dmi'; build_type = /turf/wall; classification = "exterior"; identifier = "glass4"; variantRange = 1},
	"{/build_proxy/turf}/turf/wall:(Wall Glass E)" = new/build_proxy/turf{name = "Wall Glass E"; icon = 'Wall Tiles.dmi'; build_type = /turf/wall; classification = "exterior"; identifier = "glass5"; variantRange = 1},
	"{/build_proxy/turf}/turf/wall:(Wall Glass F)" = new/build_proxy/turf{name = "Wall Glass F"; icon = 'Wall Tiles.dmi'; build_type = /turf/wall; classification = "exterior"; identifier = "glass6"; variantRange = 1},
	"{/build_proxy/turf}/turf/wall:(Wall Glass G)" = new/build_proxy/turf{name = "Wall Glass G"; icon = 'Wall Tiles.dmi'; build_type = /turf/wall; classification = "exterior"; identifier = "glass7"; variantRange = 1},
	"{/build_proxy/turf}/turf/wall:(Wall Glass H)" = new/build_proxy/turf{name = "Wall Glass H"; icon = 'Wall Tiles.dmi'; build_type = /turf/wall; classification = "exterior"; identifier = "glass8"; variantRange = 1}
)
var/list/liquidPalette = list(
	"{/build_proxy/turf}/turf/liquid:(Water2)" = new/build_proxy/turf{name = "Water2"; icon = 'Turfs 96.dmi'; icon_state = "stillwater"; density = 0; opacity = 0; build_type = /turf/liquid},
	"{/build_proxy/turf}/turf/liquid:(WaterFall)" = new/build_proxy/turf{name = "WaterFall"; icon = 'Turfs 1.dmi'; icon_state = "waterfall"; density = 1; opacity = 0; build_type = /turf/liquid},
	"{/build_proxy/turf}/turf/liquid:(Water5)" = new/build_proxy/turf{name = "Water5"; icon = 'Turfs 4.dmi'; icon_state = "kaiowater"; density = 0; opacity = 0; build_type = /turf/liquid},
	"{/build_proxy/turf}/turf/liquid:(Water6)" = new/build_proxy/turf{name = "Water6"; icon = 'Turfs 1.dmi'; icon_state = "water"; density = 0; opacity = 0; build_type = /turf/liquid},
	"{/build_proxy/turf}/turf/liquid:(Water7)" = new/build_proxy/turf{name = "Water7"; icon = 'Lava 2017.dmi'; icon_state = "0,0"; density = 0; opacity = 0; build_type = /turf/liquid; oversizedIconX = 4; oversizedIconY = 4},
	"{/build_proxy/turf}/turf/liquid:(WaterFast)" = new/build_proxy/turf{name = "WaterFast"; icon = 'Water Blue 2, 2017.dmi'; icon_state = "0,0"; density = 0; opacity = 0; build_type = /turf/liquid; oversizedIconX = 4; oversizedIconY = 4},
	"{/build_proxy/turf}/turf/liquid:(Water11)" = new/build_proxy/turf{name = "Water11"; icon = 'Cartoon Water 2017.dmi'; icon_state = "0,0"; density = 0; opacity = 0; build_type = /turf/liquid; oversizedIconX = 4; oversizedIconY = 4},
	"{/build_proxy/turf}/turf/liquid:(Water1)" = new/build_proxy/turf{name = "Water1"; icon = 'Turfs 12.dmi'; icon_state = "water3"; density = 0; opacity = 0; build_type = /turf/liquid},
	"{/build_proxy/turf}/turf/liquid:(Water8)" = new/build_proxy/turf{name = "Water8"; icon = 'turfs.dmi'; icon_state = "nwater"; density = 0; opacity = 0; build_type = /turf/liquid},
	"{/build_proxy/turf}/turf/liquid:(Water3)" = new/build_proxy/turf{name = "Water3"; icon = 'Misc.dmi'; icon_state = "Water"; density = 0; opacity = 0; build_type = /turf/liquid},
	"{/build_proxy/turf}/turf/liquid:(Lava)" = new/build_proxy/turf{name = "Lava"; icon = 'Lava 2017.dmi'; icon_state = "0,0"; density = 0; opacity = 0; build_type = /turf/liquid; oversizedIconX = 4; oversizedIconY = 4},
	"{/build_proxy/turf}/turf/liquid:(Water9)" = new/build_proxy/turf{name = "Water9"; icon = 'Turfs 12.dmi'; icon_state = "water1"; density = 0; opacity = 0; build_type = /turf/liquid},
	"{/build_proxy/turf}/turf/liquid:(WaterReal)" = new/build_proxy/turf{name = "WaterReal"; icon = 'Water Blue 2017.dmi'; icon_state = "0,0"; density = 0; opacity = 0; build_type = /turf/liquid; oversizedIconX = 6; oversizedIconY = 6},
	"{/build_proxy/turf}/turf/liquid:(Water A)" = new/build_proxy/turf{name = "Water A"; icon = 'Fluid Tiles.dmi'; build_type = /turf/liquid; classification = "water"; identifier = "a1"; variantRange = 1},
	"{/build_proxy/turf}/turf/liquid:(Water B)" = new/build_proxy/turf{name = "Water B"; icon = 'Fluid Tiles.dmi'; build_type = /turf/liquid; classification = "water"; identifier = "a2"; variantRange = 1},
	"{/build_proxy/turf}/turf/liquid:(Water C)" = new/build_proxy/turf{name = "Water C"; icon = 'Fluid Tiles.dmi'; build_type = /turf/liquid; classification = "water"; identifier = "a3"; variantRange = 1},
	"{/build_proxy/turf}/turf/liquid:(Water D)" = new/build_proxy/turf{name = "Water D"; icon = 'Fluid Tiles.dmi'; build_type = /turf/liquid; classification = "water"; identifier = "b1"; variantRange = 1},
	"{/build_proxy/turf}/turf/liquid:(Water E)" = new/build_proxy/turf{name = "Water E"; icon = 'Fluid Tiles.dmi'; build_type = /turf/liquid; classification = "water"; identifier = "b2"; variantRange = 1},
	"{/build_proxy/turf}/turf/liquid:(Water F)" = new/build_proxy/turf{name = "Water F"; icon = 'Fluid Tiles.dmi'; build_type = /turf/liquid; classification = "water"; identifier = "b3"; variantRange = 1},
	"{/build_proxy/turf}/turf/liquid:(Water G)" = new/build_proxy/turf{name = "Water G"; icon = 'Fluid Tiles.dmi'; build_type = /turf/liquid; classification = "water"; identifier = "c1"; variantRange = 1},
	"{/build_proxy/turf}/turf/liquid:(Water H)" = new/build_proxy/turf{name = "Water H"; icon = 'Fluid Tiles.dmi'; build_type = /turf/liquid; classification = "water"; identifier = "c2"; variantRange = 1},
	"{/build_proxy/turf}/turf/liquid:(Water J)" = new/build_proxy/turf{name = "Water J"; icon = 'Fluid Tiles.dmi'; build_type = /turf/liquid; classification = "water"; identifier = "c3"; variantRange = 1}
)
var/list/otherPalette = list(
	"{/build_proxy/turf}/turf/ground:(bridge1H)" = new/build_proxy/turf{name = "bridge1H"; icon = 'Turf 50.dmi'; icon_state = "3.3"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(bridge1V)" = new/build_proxy/turf{name = "bridge1V"; icon = 'Turf 50.dmi'; icon_state = "1.8"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(bridge2H)" = new/build_proxy/turf{name = "bridge2H"; icon = 'Turf 57.dmi'; icon_state = "26"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/ground:(bridge2V)" = new/build_proxy/turf{name = "bridge2V"; icon = 'Turf 57.dmi'; icon_state = "123"; density = 0; opacity = 0; build_type = /turf/ground},
	"{/build_proxy/turf}/turf/sky:(Sky1)" = new/build_proxy/turf{name = "Sky1"; icon = 'Misc.dmi'; icon_state = "Sky"; density = 0; opacity = 0; build_type = /turf/sky},
	"{/build_proxy/turf}/turf/sky:(Sky2)" = new/build_proxy/turf{name = "Sky2"; icon = 'Misc.dmi'; icon_state = "Clouds"; density = 0; opacity = 0; build_type = /turf/sky}
)
var/list/objPalette = list(
	"{/build_proxy/map_object}/obj/map_object:(Ladder)" = new/build_proxy/map_object{name = "Ladder"; icon = 'Turf1.dmi'; icon_state = "ladder"; density = 0; opacity = 0; build_type = /obj/map_object},
	"{/build_proxy/map_object}/obj/map_object/tree:(Tree 2019-4)" = new/build_proxy/map_object{name = "Tree 2019-4"; icon = 'celianna_farmnature_tilesetPartLarge.dmi'; icon_state = "Largetree2"; density = 1; opacity = 0; build_type = /obj/map_object/tree; pixel_x = -58; pixel_y = 0; step_x = 0; step_y = 0; dir = 2},
	"{/build_proxy/map_object}/obj/map_object/tree:(Tree 2019-3)" = new/build_proxy/map_object{name = "Tree 2019-3"; icon = 'celianna_farmnature_tilesetPartLarge.dmi'; icon_state = "Pine_Tree"; density = 1; opacity = 0; build_type = /obj/map_object/tree; pixel_x = -58; pixel_y = 0; step_x = 0; step_y = 0; dir = 2},
	"{/build_proxy/map_object}/obj/map_object/tree:(Tree 2019-2)" = new/build_proxy/map_object{name = "Tree 2019-2"; icon = 'celianna_farmnature_tilesetPartLarge.dmi'; icon_state = "Tree2"; density = 1; opacity = 0; build_type = /obj/map_object/tree; pixel_x = -58; pixel_y = 0; step_x = 0; step_y = 0; dir = 2},
	"{/build_proxy/map_object}/obj/map_object/tree:(Tree 2019-1)" = new/build_proxy/map_object{name = "Tree 2019-1"; icon = 'celianna_farmnature_tilesetPartLarge.dmi'; icon_state = "Tree1"; density = 1; opacity = 0; build_type = /obj/map_object/tree; pixel_x = -58; pixel_y = 0; step_x = 0; step_y = 0; dir = 2},
	"{/build_proxy/map_object}/obj/map_object/tree:(Big Generic Nice Tree)" = new/build_proxy/map_object{name = "Big Generic Nice Tree"; icon = 'big generic nice tree.png'; density = 1; opacity = 0; build_type = /obj/map_object/tree; pixel_x = -70; pixel_y = -15; step_x = 0; step_y = 0; dir = 2},
	"{/build_proxy/map_object}/obj/map_object/tree:(Small Pine Tree)" = new/build_proxy/map_object{name = "Small Pine Tree"; icon = 'tree small pine.png'; density = 1; opacity = 0; build_type = /obj/map_object/tree; pixel_x = -23; pixel_y = 0; step_x = 0; step_y = 0; dir = 2},
	"{/build_proxy/map_object}/obj/map_object/tree:(Palm Tree 2)" = new/build_proxy/map_object{name = "Palm Tree 2"; icon = 'palm tree 2016.png'; density = 1; opacity = 0; build_type = /obj/map_object/tree; pixel_x = -17; pixel_y = 0; step_x = 0; step_y = 0; dir = 2},
	"{/build_proxy/map_object}/obj/map_object/tree:(Palm Tree 3)" = new/build_proxy/map_object{name = "Palm Tree 3"; icon = 'palm tree 2016 2.png'; density = 1; opacity = 0; build_type = /obj/map_object/tree; pixel_x = -14; pixel_y = 0; step_x = 0; step_y = 0; dir = 2},
	"{/build_proxy/map_object}/obj/map_object/tree:(Medium Pine Tree)" = new/build_proxy/map_object{name = "Medium Pine Tree"; icon = 'tree medium pine.png'; density = 1; opacity = 0; build_type = /obj/map_object/tree; pixel_x = -21; pixel_y = 0; step_x = 0; step_y = 0; dir = 2},
	"{/build_proxy/map_object}/obj/map_object/tree:(Large Pine Tree)" = new/build_proxy/map_object{name = "Large Pine Tree"; icon = 'tree large pine.png'; density = 1; opacity = 0; build_type = /obj/map_object/tree; pixel_x = -35; pixel_y = 0; step_x = 0; step_y = 0; dir = 2},
	"{/build_proxy/map_object}/obj/map_object/tree:(Pink Pine Tree)" = new/build_proxy/map_object{name = "Pink Pine Tree"; icon = 'low res pink tree.png'; density = 1; opacity = 0; build_type = /obj/map_object/tree; pixel_x = -35; pixel_y = 0; step_x = 0; step_y = 0; dir = 2},
	"{/build_proxy/map_object}/obj/map_object/tree:(Dead Tree 2)" = new/build_proxy/map_object{name = "Dead Tree 2"; icon = 'dead tree 2016.png'; density = 1; opacity = 0; build_type = /obj/map_object/tree; pixel_x = -26; pixel_y = 0; step_x = 0; step_y = 0; dir = 2},
	"{/build_proxy/map_object}/obj/map_object/tree:(Dead Tree 3)" = new/build_proxy/map_object{name = "Dead Tree 3"; icon = 'dead tree 2016 2.png'; density = 1; opacity = 0; build_type = /obj/map_object/tree; pixel_x = -29; pixel_y = 0; step_x = 0; step_y = 0; dir = 2},
	"{/build_proxy/map_object}/obj/map_object/tree:(Jungle Tree 4)" = new/build_proxy/map_object{name = "Jungle Tree 4"; icon = 'jungle tree 4.dmi'; density = 1; opacity = 0; build_type = /obj/map_object/tree; pixel_x = -78; pixel_y = 0; step_x = 0; step_y = 0; dir = 2},
	"{/build_proxy/map_object}/obj/map_object/tree:(Jungle Tree 1)" = new/build_proxy/map_object{name = "Jungle Tree 1"; icon = 'jungle tree.png'; density = 1; opacity = 0; build_type = /obj/map_object/tree; pixel_x = -32; pixel_y = 0; step_x = 0; step_y = 0; dir = 2},
	"{/build_proxy/map_object}/obj/map_object/tree:(Jungle Tree 3)" = new/build_proxy/map_object{name = "Jungle Tree 3"; icon = 'jungle tree 3.png'; density = 1; opacity = 0; build_type = /obj/map_object/tree; pixel_x = -29; pixel_y = 0; step_x = 0; step_y = 0; dir = 2},
	"{/build_proxy/map_object}/obj/map_object/tree:(Snowy Pine Tree)" = new/build_proxy/map_object{name = "Snowy Pine Tree"; icon = 'snowy pine tree.png'; density = 1; opacity = 0; build_type = /obj/map_object/tree; pixel_x = -30; pixel_y = 0; step_x = 0; step_y = 0; dir = 2},
	"{/build_proxy/map_object}/obj/map_object/tree:(Dead Snowy Tree)" = new/build_proxy/map_object{name = "Dead Snowy Tree"; icon = 'dead tree snow.png'; density = 1; opacity = 0; build_type = /obj/map_object/tree; pixel_x = -26; pixel_y = 0; step_x = 0; step_y = 0; dir = 2},
	"{/build_proxy/map_object}/obj/map_object/decor/door:(Door 2)" = new/build_proxy/map_object{name = "Door 2"; icon = 'Door2.dmi'; icon_state = "Closed"; density = 1; opacity = 1; build_type = /obj/map_object/decor/door; pixel_x = 0; pixel_y = 0; step_x = 0; step_y = 0; dir = 2},
	"{/build_proxy/map_object}/obj/map_object/decor/door:(Door 4)" = new/build_proxy/map_object{name = "Door 4"; icon = 'Door4.dmi'; icon_state = "Closed"; density = 1; opacity = 1; build_type = /obj/map_object/decor/door; pixel_x = 0; pixel_y = 0; step_x = 0; step_y = 0; dir = 2},
	"{/build_proxy/map_object}/obj/map_object/edge:(Edge3)" = new/build_proxy/map_object{name = "Edge3"; icon = 'Edges3.dmi'; icon_state = "N"; density = 0; opacity = 0; build_type = /obj/map_object/edge; pixel_x = 0; pixel_y = 0; step_x = 0; step_y = 0; dir = 1},
	"{/build_proxy/map_object}/obj/map_object/edge:(Edge4)" = new/build_proxy/map_object{name = "Edge4"; icon = 'Edges4.dmi'; icon_state = "W"; density = 0; opacity = 0; build_type = /obj/map_object/edge; pixel_x = 0; pixel_y = 0; step_x = 0; step_y = 0; dir = 8},
	"{/build_proxy/map_object}/obj/map_object/edge:(Edge6)" = new/build_proxy/map_object{name = "Edge6"; icon = 'Edges6.dmi'; icon_state = "W"; density = 0; opacity = 0; build_type = /obj/map_object/edge; pixel_x = 0; pixel_y = 0; step_x = 0; step_y = 0; dir = 8},
	"{/build_proxy/map_object}/obj/map_object/edge:(Edge7)" = new/build_proxy/map_object{name = "Edge7"; icon = 'Edges7.dmi'; icon_state = "W"; density = 0; opacity = 0; build_type = /obj/map_object/edge; pixel_x = 0; pixel_y = 0; step_x = 0; step_y = 0; dir = 8},
	"{/build_proxy/map_object}/obj/map_object/edge:(Edge Grass A)" = new/build_proxy/map_object{name = "Edge Grass A"; icon = 'Edge Tiles.dmi'; build_type = /obj/map_object/edge; classification = "grass"; identifier = "a"; variantRange = 1},
	"{/build_proxy/map_object}/obj/map_object/edge:(Edge Grass B)" = new/build_proxy/map_object{name = "Edge Grass B"; icon = 'Edge Tiles.dmi'; build_type = /obj/map_object/edge; classification = "grass"; identifier = "b"; variantRange = 1},
	"{/build_proxy/map_object}/obj/map_object/edge:(Edge Grass C)" = new/build_proxy/map_object{name = "Edge Grass C"; icon = 'Edge Tiles.dmi'; build_type = /obj/map_object/edge; classification = "grass"; identifier = "c"; variantRange = 1},
	"{/build_proxy/map_object}/obj/map_object/edge:(Edge Grass D)" = new/build_proxy/map_object{name = "Edge Grass D"; icon = 'Edge Tiles.dmi'; build_type = /obj/map_object/edge; classification = "grass"; identifier = "d"; variantRange = 1},
	"{/build_proxy/map_object}/obj/map_object/edge:(Edge Grass E)" = new/build_proxy/map_object{name = "Edge Grass E"; icon = 'Edge Tiles.dmi'; build_type = /obj/map_object/edge; classification = "grass"; identifier = "e"; variantRange = 1},
	"{/build_proxy/map_object}/obj/map_object/edge:(Edge Mud A)" = new/build_proxy/map_object{name = "Edge Mud A"; icon = 'Edge Tiles.dmi'; build_type = /obj/map_object/edge; classification = "mud"; identifier = "a"; variantRange = 1},
	"{/build_proxy/map_object}/obj/map_object/edge:(Edge Snow A)" = new/build_proxy/map_object{name = "Edge Snow A"; icon = 'Edge Tiles.dmi'; build_type = /obj/map_object/edge; classification = "snow"; identifier = "a"; variantRange = 1},
	"{/build_proxy/map_object}/obj/map_object/edge:(Edge Snow B)" = new/build_proxy/map_object{name = "Edge Snow B"; icon = 'Edge Tiles.dmi'; build_type = /obj/map_object/edge; classification = "snow"; identifier = "b"; variantRange = 1},
	"{/build_proxy/map_object}/obj/map_object/edge:(Edge Sand A)" = new/build_proxy/map_object{name = "Edge Sand A"; icon = 'Edge Tiles.dmi'; build_type = /obj/map_object/edge; classification = "sand"; identifier = "a"; variantRange = 1},
	"{/build_proxy/map_object}/obj/map_object/edge:(Edge Sand B)" = new/build_proxy/map_object{name = "Edge Sand B"; icon = 'Edge Tiles.dmi'; build_type = /obj/map_object/edge; classification = "sand"; identifier = "b"; variantRange = 1},
	"{/build_proxy/map_object}/obj/map_object/edge:(Edge Trim A)" = new/build_proxy/map_object{name = "Edge Trim A"; icon = 'Edge Tiles.dmi'; build_type = /obj/map_object/edge; classification = "trim"; identifier = "a"; variantRange = 1},
	"{/build_proxy/map_object}/obj/map_object/edge:(Edge Trim B)" = new/build_proxy/map_object{name = "Edge Trim B"; icon = 'Edge Tiles.dmi'; build_type = /obj/map_object/edge; classification = "trim"; identifier = "b"; variantRange = 1},
	"{/build_proxy/map_object}/obj/map_object/edge:(Edge Metal A)" = new/build_proxy/map_object{name = "Edge Metal A"; icon = 'Edge Tiles.dmi'; build_type = /obj/map_object/edge; classification = "metal"; identifier = "a"; variantRange = 1},
	"{/build_proxy/map_object}/obj/map_object/edge:(Edge Metal B)" = new/build_proxy/map_object{name = "Edge Metal B"; icon = 'Edge Tiles.dmi'; build_type = /obj/map_object/edge; classification = "metal"; identifier = "b"; variantRange = 1},
	"{/build_proxy/map_object}/obj/map_object/edge:(Edge Metal C)" = new/build_proxy/map_object{name = "Edge Metal C"; icon = 'Edge Tiles.dmi'; build_type = /obj/map_object/edge; classification = "metal"; identifier = "c"; variantRange = 1},
	"{/build_proxy/map_object}/obj/map_object/edge:(Edge Metal D)" = new/build_proxy/map_object{name = "Edge Metal D"; icon = 'Edge Tiles.dmi'; build_type = /obj/map_object/edge; classification = "metal"; identifier = "d"; variantRange = 1}
)
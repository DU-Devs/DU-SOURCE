mob/var/tmp/obj/items/Equipment/Weapon/equippedWeapon

mob/proc/GetWeaponDamage()
	var/obj/items/Equipment/Weapon/W = GetEquippedWeapon()
	return W && W.damageBonus

mob/proc/GetCritBonus()
	var/obj/items/Equipment/Weapon/W = GetEquippedWeapon()
	return W && W.critBonus

mob/proc/IsWeaponSilvered()
	var/obj/items/Equipment/Weapon/W = GetEquippedWeapon()
	return W && W.silvered

mob/proc/DoesWeaponStun()
	var/obj/items/Equipment/Weapon/W = GetEquippedWeapon()
	return W && W.stunning

mob/proc/IsWeaponBladed()
	var/obj/items/Equipment/Weapon/W = GetEquippedWeapon()
	return W && istype(W, /obj/items/Equipment/Weapon/Bladed)

mob/proc/GetWeaponFracture()
	var/n = 1, obj/items/Equipment/Weapon/W = GetEquippedWeapon()
	if(W)
		n = W.fractureMod
	return n

mob/proc/GetWeaponLacerate()
	var/n = 1, obj/items/Equipment/Weapon/W = GetEquippedWeapon()
	if(W)
		n = W.lacerationMod
	return n

mob/proc/GetWeaponBruise()
	var/n = 1, obj/items/Equipment/Weapon/W = GetEquippedWeapon()
	if(W)
		n = W.bruiseMod
	return n

mob/proc/GetWeaponTortion()
	var/n = 1, obj/items/Equipment/Weapon/W = GetEquippedWeapon()
	if(W)
		n = W.tortionMod
	return n

mob/proc/GetWeaponInternal()
	var/n = 1, obj/items/Equipment/Weapon/W = GetEquippedWeapon()
	if(W)
		n = W.internalMod
	return n

mob/proc/GetWeaponBurn()
	var/n = 1, obj/items/Equipment/Weapon/W = GetEquippedWeapon()
	if(W)
		n = W.burnMod
	return n

mob/proc/GetWeaponKnockback()
	var/kb = 1, obj/items/Equipment/Weapon/W = GetEquippedWeapon()
	if(W)
		kb = W.baseKnockback
	return kb

mob/proc/GetWeaponAccuracy()
	var/acc = 60, obj/items/Equipment/Weapon/W = GetEquippedWeapon()
	if(W)
		acc = W.baseAccuracy
	return acc

mob/proc/GetWeaponDelayMod()
	var/delay = 1, obj/items/Equipment/Weapon/W = GetEquippedWeapon()
	if(W) delay = W.delayMult
	return delay

mob/proc/GetWeaponBleed()
	var/bleed = 0, obj/items/Equipment/Weapon/W = GetEquippedWeapon()
	if(W) bleed = W.bleed
	return bleed

mob/proc/GetWeaponRegen()
	var/regen = 0, obj/items/Equipment/Weapon/W = GetEquippedWeapon()
	if(W) regen = W.regenBonus
	return regen

mob/proc/GetWeaponRecov()
	var/recov = 0, obj/items/Equipment/Weapon/W = GetEquippedWeapon()
	if(W) recov = W.recovBonus
	return recov

mob/proc/GetEquippedWeapon()
	return equippedWeapon

mob/proc/FindEquippedWeapons()
	for(var/obj/items/Equipment/Weapon/W in src)
		if(W.equipped && !equippedWeapon)
			equippedWeapon = W
		else W.equipped = 0
	
obj/items/Equipment
	var
		equipped = 0
		rarity = 0
		variance = 0
		image/overlayIcon
	Stealable = 0
	can_hotbar = 1
	can_change_icon = 1

	proc/UpdateIcon()
		overlayIcon = image(icon = src.icon, pixel_x = src.pixel_x, pixel_y = src.pixel_y)

	proc/ApplyStatVariance(variance = 0)

	proc/UpdateValues()

var/currentWeaponVersion = 2
var/currentArmorVersion = 2

obj/items/Equipment/Weapon
	var
		weaponVersion = 1
		damageBonus = 3
		baseAccuracy = 50
		bleed = 0
		delayMult = 1
		baseKnockback = 1
		silvered = 0
		stunning = 0
		inhibiting = 0
		reach = 1
		critBonus = 0
		regenBonus = 0
		recovBonus = 0
		lacerationMod = 1
		bruiseMod = 1
		tortionMod = 1
		internalMod = 1
		fractureMod = 1
		burnMod = 0
	
	icon = 'Sword_Trunks.dmi'
	can_change_icon = 1

	New()
		..()
		desc = "\
Damage Bonus: [damageBonus]<br>\
Base Accuracy: [baseAccuracy]%<br>\
Bleed Amount: [bleed]<br>\
Base Knockback: [baseKnockback]x<br>\
"

	ApplyStatVariance(variance = 0)
		if(variance <= 0) return
		damageBonus = Math.Rand((1 - variance) * damageBonus, (1 + variance) * damageBonus)
		delayMult = Math.Rand((1 - variance) * delayMult, (1 + variance) * delayMult)
		baseAccuracy = Math.Rand((1 - variance) * baseAccuracy, (1 + variance) * baseAccuracy)
		bleed = Math.Rand((1 - variance) * bleed, (1 + variance) * bleed)
		baseKnockback = Math.Rand((1 - variance) * baseKnockback, (1 + variance) * baseKnockback)
	
	UpdateValues()
		if(weaponVersion < currentWeaponVersion)
			var/obj/items/Equipment/Weapon/W = new type
			damageBonus = W.damageBonus
			baseAccuracy = W.baseAccuracy
			bleed = W.bleed
			delayMult = W.delayMult
			baseKnockback = W.baseKnockback
			weaponVersion = currentWeaponVersion
	
	proc/Equip(mob/M)
		if(!M) return
		var/obj/items/Equipment/Weapon/W = M.GetEquippedWeapon()
		if(W) W.Unequip(M)
		src.equipped = 1
		src.suffix = "Equipped"
		M.equippedWeapon = src
		UpdateIcon()
		M.overlays.Add(src.overlayIcon)
	
	proc/Unequip(mob/M)
		if(!M) return
		M.equippedWeapon = null
		src.suffix = null
		src.equipped = 0
		M.overlays.Remove(src.icon)
		M.overlays.Remove(src.overlayIcon)

	verb/Hotbar_use()
		set hidden=1
		Click()
	
	Click()
		if(!equipped) Equip(usr)
		else Unequip(usr)
	
	Bladed
		bruiseMod = 0
		tortionMod = 0
		Short_Sword
			damageBonus = 0
			baseAccuracy = 50
			delayMult = 1
			bleed = 1
			lacerationMod = 1.2
			baseKnockback = 0.5
			reach = 0.8
			critBonus = 0.5
			Cost = 2500
		
		Long_Sword
			damageBonus = 1
			baseAccuracy = 50
			delayMult = 1.1
			bleed = 0.8
			lacerationMod = 0.95
			baseKnockback = 1
			Cost = 2500
		
		Dagger
			damageBonus = -1.5
			baseAccuracy = 60
			delayMult = 0.6
			bleed = 1.5
			lacerationMod = 1.8
			baseKnockback = 0.6
			reach = 0.6
			critBonus = 3
			Cost = 2500
		
		Spear
			damageBonus = 1.5
			baseAccuracy = 55
			delayMult = 1.2
			bleed = 1.25
			lacerationMod = 1.5
			bruiseMod = 0.1
			tortionMod = 0.1
			baseKnockback = 0.9
			reach = 1.5
			critBonus = 1
			Cost = 2500
	
	Blunt
		lacerationMod = 0
		Light_Hammer
			damageBonus = 2
			baseAccuracy = 40
			delayMult = 1.3
			baseKnockback = 1.4
			bruiseMod = 1.3
			tortionMod = 0.8
			internalMod = 1.1
			fractureMod = 1.8
			reach = 0.8
			critBonus = 1
			Cost = 2500
		
		Mace
			damageBonus = 1.2
			baseAccuracy = 45
			delayMult = 0.65
			baseKnockback = 1.8
			bruiseMod = 1.3
			tortionMod = 0.3
			internalMod = 1.8
			fractureMod = 1.5
			lacerationMod = 0.1
			critBonus = 1.5
			Cost = 2500
		
		Quarterstaff
			damageBonus = 0.5
			baseAccuracy = 55
			delayMult = 0.75
			baseKnockback = 1.1
			bruiseMod = 1.5
			tortionMod = 1.8
			internalMod = 0.7
			fractureMod = 0.85
			reach = 1.4
			Cost = 2500

		Nunchaku
			damageBonus = -1
			baseAccuracy = 65
			delayMult = 0.5
			baseKnockback = 0.8
			bruiseMod = 1.8
			tortionMod = 1.5
			internalMod = 0.9
			fractureMod = 0.3
			critBonus = 2
			Cost = 2500
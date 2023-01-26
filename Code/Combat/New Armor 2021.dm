mob/var/tmp/obj/items/Equipment/Armor/equippedArmor

mob/proc/GetArmorBonus()
	var/bonus = 0, obj/items/Equipment/Armor/A = GetEquippedArmor()
	if(Race != "Android" && A)
		bonus = A.damageThresholdBonus
	return bonus

mob/proc/GetArmorKnockbackMod()
	var/kb = 1, obj/items/Equipment/Armor/A = GetEquippedArmor()
	if(Race != "Android" && A)
		kb = A.knockbackResistance
	return kb

mob/proc/GetArmorDodgeMod()
	var/acc = 1, obj/items/Equipment/Armor/A = GetEquippedArmor()
	if(Race != "Android" && A)
		var/inc = 0
		if(CheckForInjuries())
			inc += GetInjuryTypeCount(/injury/burn) * 0.05
		acc = A.reflexDivider + inc
	return acc

mob/proc/GetArmorDelayMod()
	var/delay = 1, obj/items/Equipment/Armor/A = GetEquippedArmor()
	if(Race != "Android" && A)
		var/inc = 0
		if(CheckForInjuries())
			inc += GetInjuryTypeCount(/injury/burn) * 0.05
		delay = A.delayMod + inc
	return delay

mob/proc/GetArmorBleedDivider()
	var/bleed = 1, obj/items/Equipment/Armor/A = GetEquippedArmor()
	if(Race != "Android" && A) bleed = A.bleedDivider
	return bleed

mob/proc/GetEquippedArmor()
	return equippedArmor

mob/proc/FindEquippedArmors()
	for(var/obj/items/Equipment/Armor/A in src)
		if(A.equipped && !equippedArmor)
			equippedArmor = A
		else A.equipped = 0

obj/items/Equipment/Armor
	var
		armorVersion = 1
		damageThresholdBonus = 1
		delayMod = 1
		reflexDivider = 1
		bleedDivider = 1
		knockbackResistance = 1

	icon = 'Armor1.dmi'


	New()
		..()
		desc = "\
Damage Reduction: [damageThresholdBonus]<br>\
Speed Reduction: [delayMod]x<br>\
Reflex Reduction: [reflexDivider]x<br>\
Knockback Reduction: [knockbackResistance]x<br>\
"

	ApplyStatVariance(variance = 0)
		if(variance <= 0) return
		damageThresholdBonus = Math.Rand((1 - variance) * damageThresholdBonus, (1 + variance) * damageThresholdBonus)
		delayMod = Math.Rand((1 - variance) * delayMod, (1 + variance) * delayMod)
		reflexDivider = Math.Rand((1 - variance) * reflexDivider, (1 + variance) * reflexDivider)
		bleedDivider = Math.Rand((1 - variance) * bleedDivider, (1 + variance) * bleedDivider)
		knockbackResistance = Math.Rand((1 - variance) * knockbackResistance, (1 + variance) * knockbackResistance)
	
	UpdateValues()
		if(armorVersion < currentArmorVersion)
			var/obj/items/Equipment/Armor/A = new src.type
			damageThresholdBonus = A.damageThresholdBonus
			delayMod = A.delayMod
			reflexDivider = A.reflexDivider
			bleedDivider = A.bleedDivider
			knockbackResistance = A.knockbackResistance
			armorVersion = currentArmorVersion
	
	proc/Equip(mob/M)
		if(!M) return
		var/obj/items/Equipment/Armor/W = M.GetEquippedArmor()
		if(W) W.Unequip(M)
		src.equipped = 1
		src.suffix = "Equipped"
		M.equippedArmor = src
		UpdateIcon()
		M.overlays.Add(src.overlayIcon)
	
	proc/Unequip(mob/M)
		if(!M) return
		M.equippedArmor = null
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
	
	Light_Armor
		damageThresholdBonus = 1
		delayMod = 1.2
		reflexDivider = 1.2
		knockbackResistance = 1
		Cost = 2500
	
	Medium_Armor
		damageThresholdBonus = 2
		delayMod = 1.4
		reflexDivider = 1.4
		knockbackResistance = 1.3
		Cost = 2500
	
	Heavy_Armor
		damageThresholdBonus = 4
		delayMod = 1.6
		reflexDivider = 1.6
		knockbackResistance = 2
		Cost = 2500
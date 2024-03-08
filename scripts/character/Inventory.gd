extends Node

var currentWeapon = -1
var currentArmor = -1

var weapons = []
var armors = []
var potions = []
var lockpicks = 0 setget updateLockpicks

func init():
	updateLockpicks(5)

func updateLockpicks(newValue):
	lockpicks = newValue
	Ref.ui.updateStat(Data.ST_LOCK, newValue)

func getWeaponRows():
	var result = []
	for w in weapons:
		var current = GLOBAL.items[w]
		var equiped = w == currentWeapon
		result.append([GLOBAL.WP_TYPE, w, current[GLOBAL.IT_NAME], equiped, current[GLOBAL.IT_ICON]])
	return result

func getArmorRows():
	var result = []
	for a in armors:
		var current = GLOBAL.items[a]
		var equiped = a == currentArmor
		result.append([GLOBAL.AR_TYPE, a, current[GLOBAL.IT_NAME], equiped, current[GLOBAL.IT_ICON]])
	return result

func getPotionRows():
	var dict:Dictionary = {}
	for p in potions:
		var current = GLOBAL.items[p]
		if !dict.has(current[GLOBAL.IT_STACK]):
			dict[current[GLOBAL.IT_STACK]] = [GLOBAL.PO_TYPE, current[GLOBAL.IT_NAME], current[GLOBAL.IT_ICON], [p]]
		else:
			dict[current[GLOBAL.IT_STACK]][2].append(p)
	var result = []
	for d in dict.keys():
		result.append(dict[d])
	return result
	

func switchWeapon(idx):
	if currentWeapon == idx:
		unequipWeapon(idx)
	else:
		equipWeapon(idx)

func unequipWeapon(idx):
	if currentWeapon != idx:
		return
	var stats = get_parent().stats
	stats.dmgDices = Vector2(1, 1)
	stats.hitDices = Vector2(1, 1)
	currentWeapon = -1

func equipWeapon(idx):
	unequipWeapon(idx)
	currentWeapon = idx
	var stats = get_parent().stats
	stats.dmgDices = GLOBAL.items[idx][GLOBAL.IT_DMG]
	stats.hitDices = GLOBAL.items[idx][GLOBAL.IT_HIT]

func switchArmor(idx):
	if currentArmor == idx:
		unequipArmor(idx)
	else:
		equipArmor(idx)

func unequipArmor(idx):
	if currentArmor != idx:
		return
	var stats = get_parent().stats
	stats.ca = 4
	stats.prot = 0
	currentArmor = -1

func equipArmor(idx):
	unequipArmor(idx)
	currentArmor = idx
	var stats = get_parent().stats
	stats.ca = GLOBAL.items[idx][GLOBAL.IT_CA]
	stats.prot = GLOBAL.items[idx][GLOBAL.IT_PROT]

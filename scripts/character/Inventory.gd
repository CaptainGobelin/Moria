extends Node

# X is Weapon Y is Shield
var currentWeapon = Vector2(-1, -1)
var currentArmor = -1
var currentTalismans = Vector2(-1, -1)

var weapons = []
var armors = []
var potions = []
var scrolls = []
var throwings = []
var talismans = []
var lockpicks = 0 setget updateLockpicks
var golds = 0 setget updateGolds

func init():
	updateLockpicks(5)
	updateGolds(0)

func updateLockpicks(newValue):
	lockpicks = newValue
	Ref.ui.updateStat(Data.CHAR_LOCK, newValue)

func updateGolds(newValue):
	golds = newValue
	Ref.ui.updateStat(Data.CHAR_GOLD, newValue)

func getWeaponRows():
	var result = []
	for w in weapons:
		var current = GLOBAL.items[w]
		var equiped = (w == currentWeapon.x) or (w == currentWeapon.y)
		var key = Ref.character.shortcuts.getKey(w, GLOBAL.WP_TYPE)
		result.append([GLOBAL.WP_TYPE, w, current[GLOBAL.IT_NAME], equiped, key, current[GLOBAL.IT_ICON]])
	return result

func getArmorRows():
	var result = []
	for a in armors:
		var current = GLOBAL.items[a]
		var equiped = a == currentArmor
		result.append([GLOBAL.AR_TYPE, a, current[GLOBAL.IT_NAME], equiped, null, current[GLOBAL.IT_ICON]])
	return result

func getPotionRows():
	var dict:Dictionary = {}
	for p in potions:
		var current = GLOBAL.items[p]
		if !dict.has(current[GLOBAL.IT_STACK]):
			var key = Ref.character.shortcuts.getKey(p, GLOBAL.PO_TYPE)
			dict[current[GLOBAL.IT_STACK]] = [GLOBAL.PO_TYPE, current[GLOBAL.IT_NAME], key, current[GLOBAL.IT_ICON], [p]]
		else:
			dict[current[GLOBAL.IT_STACK]][4].append(p)
	var result = []
	for d in dict.keys():
		result.append(dict[d])
	return result

func getScrollRows():
	var dict:Dictionary = {}
	for s in scrolls:
		var current = GLOBAL.items[s]
		if !dict.has(current[GLOBAL.IT_STACK]):
			var key = Ref.character.shortcuts.getKey(s, GLOBAL.SC_TYPE)
			dict[current[GLOBAL.IT_STACK]] = [GLOBAL.SC_TYPE, current[GLOBAL.IT_NAME], key, current[GLOBAL.IT_ICON], [s]]
		else:
			dict[current[GLOBAL.IT_STACK]][4].append(s)
	var result = []
	for d in dict.keys():
		result.append(dict[d])
	return result

func getThrowingRows():
	var dict:Dictionary = {}
	for t in throwings:
		var current = GLOBAL.items[t]
		if !dict.has(current[GLOBAL.IT_STACK]):
			var key = Ref.character.shortcuts.getKey(t, GLOBAL.TH_TYPE)
			dict[current[GLOBAL.IT_STACK]] = [GLOBAL.TH_TYPE, current[GLOBAL.IT_NAME], key, current[GLOBAL.IT_ICON], [t]]
		else:
			dict[current[GLOBAL.IT_STACK]][4].append(t)
	var result = []
	for d in dict.keys():
		result.append(dict[d])
	return result

func getTalismanRows():
	var result = []
	for t in talismans:
		var current = GLOBAL.items[t]
		var equiped = currentTalismans.x == t or currentTalismans.y == t
		result.append([GLOBAL.TA_TYPE, t, current[GLOBAL.IT_NAME], equiped, null, current[GLOBAL.IT_ICON]])
	return result

func switchWeapon(idx):
	if (currentWeapon.x == idx) or (currentWeapon.y == idx):
		unequipWeapon(idx)
	else:
		equipWeapon(idx)

func unequipWeapon(idx):
	var item = GLOBAL.items[idx]
	# Weapon
	if item[GLOBAL.IT_CA] == null:
		if currentWeapon.x != idx:
			return
		var stats = get_parent().stats
		stats.dmgDices = Vector2(1, 1)
		stats.hitDices = Vector2(1, 1)
		currentWeapon.x = -1
	# Shield
	else:
		if currentWeapon.y != idx:
			return
		var stats = get_parent().stats
		stats.ca -= item[GLOBAL.IT_CA]
		stats.prot -= item[GLOBAL.IT_PROT]
		currentWeapon.y = -1

func equipWeapon(idx):
	unequipWeapon(idx)
	var item = GLOBAL.items[idx]
	# Weapon
	if item[GLOBAL.IT_CA] == null:
		currentWeapon.x = idx
		var stats = get_parent().stats
		stats.dmgDices = item[GLOBAL.IT_DMG]
		stats.hitDices = item[GLOBAL.IT_HIT]
	# Shield
	else:
		currentWeapon.y = idx
		var stats = get_parent().stats
		stats.ca += item[GLOBAL.IT_CA]
		stats.prot += item[GLOBAL.IT_PROT]

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

func switchTalisman(idx):
	if currentTalismans.x == idx:
		currentTalismans.x = currentTalismans.y
		currentTalismans.y = -1
	elif currentTalismans.y == idx:
		currentTalismans.y = -1
	elif currentTalismans.x == -1:
		currentTalismans.x = idx
	elif currentTalismans.y == -1:
		currentTalismans.y = idx
	else:
		currentTalismans.x = currentTalismans.y
		currentTalismans.y = idx

extends Node

# X is Weapon Y is Shield
var currentWeapon = Vector2(-1, -1)
var currentArmor = Vector2(-1, -1)
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
	weapons = []
	armors = []
	potions = []
	scrolls = []
	throwings = []
	talismans = []
	updateLockpicks(0)
	updateGolds(0)

func getWeapon():
	return int(currentWeapon.x)

func getShield():
	return int(currentWeapon.y)

func getHelmet():
	return int(currentArmor.y)

func getArmor():
	return int(currentArmor.x)

func getTalisman1():
	return int(currentTalismans.x)

func getTalisman2():
	return int(currentTalismans.y)

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
		var equiped = (a == currentArmor.x) or (a == currentArmor.y)
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

func unequipWeapon(idx: int, renewStats: bool = true):
	var item = GLOBAL.items[idx]
	# Weapon
	if item[GLOBAL.IT_CA] == null:
		if currentWeapon.x != idx:
			return
		currentWeapon.x = -1
		EnchantEngine.removeEnchant(get_parent(), idx)
	# Shield
	else:
		if currentWeapon.y != idx:
			return
		currentWeapon.y = -1
	if renewStats:
		get_parent().stats.computeStats()

func equipWeapon(idx):
	var item = GLOBAL.items[idx]
	# Weapon
	if item[GLOBAL.IT_CA] == null:
		if currentWeapon.x != -1:
			unequipWeapon(currentWeapon.x, false)
		currentWeapon.x = idx
		for e in item[GLOBAL.IT_SPEC]:
			EnchantEngine.applyEffect(get_parent(), e, idx)
	# Shield
	else:
		if currentWeapon.y != -1:
			unequipWeapon(currentWeapon.x, false)
		currentWeapon.y = idx
	get_parent().stats.computeStats()

func switchArmor(idx):
	if (currentArmor.x == idx) or (currentArmor.y == idx):
		unequipArmor(idx)
	else:
		equipArmor(idx)

func unequipArmor(idx):
	if GLOBAL.items[idx][GLOBAL.IT_2H]:
		if currentArmor.y != idx:
			return
		currentArmor.y = -1
	else:
		if currentArmor.x != idx:
			return
		currentArmor.x = -1
	get_parent().stats.computeStats()

func equipArmor(idx):
	unequipArmor(idx)
	if GLOBAL.items[idx][GLOBAL.IT_2H]:
		currentArmor.y = idx
	else:
		currentArmor.x = idx
	get_parent().stats.computeStats()

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

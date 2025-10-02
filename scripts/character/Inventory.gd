extends Node

var rests: int = GLOBAL.CHAR_RESTS

# X is Weapon Y is Shield
var currentWeapon = Vector2(-1, -1)
# X is Qrmor Y is Helemt
var currentArmor = Vector2(-1, -1)
var currentTalismans = Vector2(-1, -1)

var weapons = []
var armors = []
var potions = []
var scrolls = []
var throwings = []
var talismans = []
var lockpicks = 0 setget updateLockpicks
var golds = 100 setget updateGolds

func init(charClass: int):
	var classKit = Data.CLASS_KITS[charClass]
	if classKit[Data.KIT_WP] != -1:
		var items = Ref.game.itemGenerator.getWeapon(classKit[Data.KIT_WP])
		weapons = items
		equipWeapon(items[0])
	else:
		weapons = []
	if classKit[Data.KIT_SH] != -1:
		var items = Ref.game.itemGenerator.getShield(classKit[Data.KIT_SH])
		weapons.append_array(items)
		equipWeapon(items[0])
	if classKit[Data.KIT_AR] != -1:
		var items = Ref.game.itemGenerator.getArmor(classKit[Data.KIT_AR])
		armors = items
		equipArmor(items[0])
	else:
		armors = []
	if not classKit[Data.KIT_PO].empty():
		for p in classKit[Data.KIT_PO]:
			var items = Ref.game.itemGenerator.getPotion(p)
			potions.append_array(items)
	else:
		potions = []
	if not classKit[Data.KIT_SC].empty():
		for s in classKit[Data.KIT_SC]:
			var items = Ref.game.itemGenerator.getScroll(s)
			scrolls.append_array(items)
	else:
		scrolls = []
	if not classKit[Data.KIT_TH].empty():
		for t in classKit[Data.KIT_TH]:
			var items = Ref.game.itemGenerator.getThrowable(t)
			throwings.append_array(items)
	else:
		throwings = []
	talismans = []
	updateLockpicks(classKit[Data.KIT_LO])
	updateGolds(classKit[Data.KIT_GO] + 30)

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

func updateLockpicks(newValue: int):
	lockpicks = newValue
	Ref.ui.updateStat(Data.CHAR_LOCK, newValue)

func updateGolds(newValue: int):
	golds = newValue
	Ref.ui.updateStat(Data.CHAR_GOLD, newValue)

func pay(amount: int):
	updateGolds(max(0, golds - amount))

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
			var key = Ref.character.shortcuts.getKey(current[GLOBAL.IT_STACK], GLOBAL.PO_TYPE)
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
			var key = Ref.character.shortcuts.getKey(current[GLOBAL.IT_STACK], GLOBAL.SC_TYPE)
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
			var key = Ref.character.shortcuts.getKey(current[GLOBAL.IT_STACK], GLOBAL.TH_TYPE)
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

func switchWeapon(idx: int):
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
		EnchantEngine.removeEnchant(get_parent(), idx)
	if renewStats:
		get_parent().stats.computeStats()

func equipWeapon(idx: int):
	var item = GLOBAL.items[idx]
	if !Skills.canEquipWeapon(item[GLOBAL.IT_BASE]):
		Ref.ui.writeCannotEquipWeapon()
		return
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
			unequipWeapon(currentWeapon.y, false)
		currentWeapon.y = idx
		for e in item[GLOBAL.IT_SPEC]:
			EnchantEngine.applyEffect(get_parent(), e, idx)
	get_parent().stats.computeStats()

func switchArmor(idx: int):
	if (currentArmor.x == idx) or (currentArmor.y == idx):
		unequipArmor(idx)
	else:
		equipArmor(idx)

func unequipArmor(idx: int, renewStats: bool = true):
	# Helmet
	if GLOBAL.items[idx][GLOBAL.IT_2H]:
		if currentArmor.y != idx:
			return
		currentArmor.y = -1
		EnchantEngine.removeEnchant(get_parent(), idx)
	# Armor
	else:
		if currentArmor.x != idx:
			return
		currentArmor.x = -1
		EnchantEngine.removeEnchant(get_parent(), idx)
	if renewStats:
		get_parent().stats.computeStats()

func equipArmor(idx: int):
	var item = GLOBAL.items[idx]
	# Helmet
	if item[GLOBAL.IT_2H]:
		if currentArmor.y != -1:
			unequipArmor(currentArmor.y, false)
		currentArmor.y = idx
		for e in item[GLOBAL.IT_SPEC]:
			EnchantEngine.applyEffect(get_parent(), e, idx)
	# Armor
	else:
		if currentArmor.x != -1:
			unequipArmor(currentArmor.x, false)
		currentArmor.x = idx
		for e in item[GLOBAL.IT_SPEC]:
			EnchantEngine.applyEffect(get_parent(), e, idx)
	get_parent().stats.computeStats()

func switchTalisman(idx: int):
	var item = GLOBAL.items[idx]
	if currentTalismans.x == idx:
		EnchantEngine.removeEnchant(get_parent(), currentTalismans.x)
		currentTalismans.x = currentTalismans.y
		currentTalismans.y = -1
	elif currentTalismans.y == idx:
		EnchantEngine.removeEnchant(get_parent(), currentTalismans.y)
		currentTalismans.y = -1
	elif currentTalismans.x == -1:
		currentTalismans.x = idx
		for e in item[GLOBAL.IT_SPEC]:
			EnchantEngine.applyEffect(get_parent(), e, idx)
	elif currentTalismans.y == -1:
		currentTalismans.y = idx
		for e in item[GLOBAL.IT_SPEC]:
			EnchantEngine.applyEffect(get_parent(), e, idx)
	else:
		EnchantEngine.removeEnchant(get_parent(), currentTalismans.x)
		currentTalismans.x = currentTalismans.y
		currentTalismans.y = idx
		for e in item[GLOBAL.IT_SPEC]:
			EnchantEngine.applyEffect(get_parent(), e, idx)
	get_parent().stats.computeStats()

func getTotalArmorMalus() -> int:
	var result = 0
	if getArmor() != -1:
		var armor = Data.armors[GLOBAL.items[getArmor()][GLOBAL.IT_BASE]]
		result = max(result, armor[Data.A_SKILL])
	if getHelmet() != -1:
		var armor = Data.armors[GLOBAL.items[getHelmet()][GLOBAL.IT_BASE]]
		result = max(result, armor[Data.A_SKILL])
	return int(max(0, result - Skills.getAmorMalusReduction()))

func getItemAmount(type: int, stack: int) -> int:
	var list = []
	var result: int = 0
	match type:
		GLOBAL.TH_TYPE: list = throwings
		GLOBAL.PO_TYPE: list = potions
		GLOBAL.SC_TYPE: list = scrolls
		_: return result
	for i in list:
		if GLOBAL.items[i][GLOBAL.IT_STACK] == stack:
			result += 1
	return result

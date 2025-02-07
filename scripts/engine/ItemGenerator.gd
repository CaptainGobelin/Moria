extends Node
class_name ItemGenerator

const WP_IDX = 0
const AR_IDX = 1
const TA_IDX = 2
const TH_IDX = 3
const SC_IDX = 4
const PO_IDX = 5
const LO_IDX = 6
const GO_IDX = 7
const TYPE_PROB = [0.22, 0.14, 0.06, 0.08, 0.1, 0.13, 0.12, 0.15]

var id = -1

func _ready():
#	randomize()
#	for i in range(0, 5):
#		print("-------------- " + String(i) + " --------------")
#		for _j in range(0, 30):
#			var item = generateItem(i)
#			if !item.empty():
#				print(GLOBAL.items[item[0]][GLOBAL.IT_NAME])
	pass

func getItemType(forSell: bool = false):
	var rnd = randf()
	var result = 0
	while rnd >= TYPE_PROB[result]:
		rnd -= TYPE_PROB[result]
		result = (result + 1) % TYPE_PROB.size()
	if forSell and result == GO_IDX:
		return getItemType(forSell)
	return result

func generateItem(rarity: int, type: int = -1, forSell: bool = false):
	if type == -1:
		type = getItemType(forSell)
	match type:
		WP_IDX: return generateWeapon(rarity)
		AR_IDX: return generateArmor(rarity)
		TH_IDX: return generateThrowing(rarity)
		PO_IDX: return generatePotion(rarity)
		SC_IDX: return generateScroll(rarity)
		TA_IDX: return generateTalisman(rarity)
		LO_IDX: return generateLockpicks()
		GO_IDX: return generateGolds(rarity)
		_: return []

func generateWeapon(rarity: int):
	if rarity >= Data.shields[0][Data.SH_RAR] and randf() < 0.125:
		return generateShield(rarity)
	var localRarity = randi() % (rarity + 1)
	while !Data.weaponsByRarity.has(localRarity):
		localRarity -= 1
		if localRarity < 0:
			return []
	var rnd = randi() % Data.weaponsByRarity[localRarity].size()
	var baseIdx = Data.weaponsByRarity[localRarity][rnd]
	var base = Data.weapons[baseIdx].duplicate()
	id += 1
	var enchants = generateWeaponEnchant(rarity)
	if baseIdx == Data.W_STAFF:
		enchants = generateStaffEnchant(rarity)
	base[Data.W_NAME] = addEnchantsAffixes(enchants, base[Data.W_NAME])
	base[Data.W_NAME][0] = base[Data.W_NAME][0].capitalize()
	GLOBAL.items[id] = mapWeaponToItem(base, baseIdx, enchants)
	return [id]

func generateWeaponEnchant(rarity: int):
	var wpType = 0
	if (rarity > 4) and (randf() < 0.25):
		wpType = 1
	var result = []
	if rarity > 1:
		if randf() < ((rarity-1) * 0.075):
			result.append(Utils.chooseRandom(Data.enchantsByRarity[wpType][Data.EN_SLOT_WP][rarity]))
			if (rarity > 4) and (randf() < 0.3125):
				result.append(Utils.chooseRandom(Data.enchantsByRarity[0][Data.EN_SLOT_WP][rarity]))
		if randf() < ((rarity) * 0.075):
			if (rarity > 4) and (randf() < 0.25):
				result.append(Data.ENCH_PLUS_2)
			else:
				result.append(Data.ENCH_PLUS_1)
	return result

func generateStaffEnchant(rarity: int):
	var result = []
	if rarity < 1:
		return result
	if randf() < (1.5 * (rarity-1) * 0.075):
		result.append(Utils.chooseRandom(Data.enchantsByRarity[0][Data.EN_SLOT_ST][rarity]))
	if randf() < ((rarity) * 0.075):
		if (rarity > 4) and (randf() < 0.25):
			result.append(Data.ENCH_PLUS_2)
		else:
			result.append(Data.ENCH_PLUS_1)
	return result

func mapWeaponToItem(weapon, baseIdx: int, enchants: Array = []):
	var item = []
	item.resize(GLOBAL.IT_STACK + 1)
	item[GLOBAL.IT_ICON] = weapon[Data.W_ICON]
	item[GLOBAL.IT_NAME] = weapon[Data.W_NAME]
	item[GLOBAL.IT_SPEC] = enchants.duplicate()
	var dmgDice = GeneralEngine.basicDice(weapon[Data.W_DMG])
	var dmgType = Data.DMG_SLASH
	if weapon[Data.W_TYPE] == "B":
		dmgType = Data.DMG_BLUNT
	item[GLOBAL.IT_DMG] = GeneralEngine.dmgFromDice(dmgDice, dmgType)
	if item[GLOBAL.IT_SPEC].has(Data.ENCH_PLUS_1):
		item[GLOBAL.IT_HIT] = 1
		item[GLOBAL.IT_DMG].dice.b += 1
	elif item[GLOBAL.IT_SPEC].has(Data.ENCH_PLUS_2):
		item[GLOBAL.IT_HIT] = 2
		item[GLOBAL.IT_DMG].dice.b += 2
	elif item[GLOBAL.IT_SPEC].has(Data.ENCH_PLUS_3):
		item[GLOBAL.IT_HIT] = 3
		item[GLOBAL.IT_DMG].dice.b += 3
	else:
		item[GLOBAL.IT_HIT] = 0
	item[GLOBAL.IT_2H] = weapon[Data.W_2H]
	item[GLOBAL.IT_TYPE] = GLOBAL.WP_TYPE
	item[GLOBAL.IT_SUBTYPE] = GLOBAL.SUB_WP
	item[GLOBAL.IT_BASE] = baseIdx
	return item

func generateShield(rarity: int):
	var shieldList = Data.shields.keys()
	shieldList.invert()
	var ratio = 1.0/float(shieldList.size())
	var baseIdx = 0
	for k in shieldList:
		if rarity >= Data.shields[k][Data.SH_RAR] and randf() < ratio:
			baseIdx = k
			break
	var base = Data.shields[baseIdx].duplicate()
	var enchants = generateShieldEnchant(rarity)
	base[Data.W_NAME] = addEnchantsAffixes(enchants, base[Data.W_NAME])
	id += 1
	base[Data.SH_NAME][0] = base[Data.SH_NAME][0].capitalize()
	GLOBAL.items[id] = mapShieldToItem(base, baseIdx, enchants)
	return [id]

func generateShieldEnchant(rarity: int):
	var result = []
	if rarity > 1:
		if randf() < ((rarity) * 0.075):
			if (rarity > 4) and (randf() < 0.25):
				result.append(Data.ENCH_PLUS_2)
			else:
				result.append(Data.ENCH_PLUS_1)
	return result

func mapShieldToItem(shield, baseIdx: int, enchants: Array = []):
	var item = []
	item.resize(GLOBAL.IT_STACK + 1)
	item[GLOBAL.IT_ICON] = shield[Data.SH_ICON]
	item[GLOBAL.IT_NAME] = shield[Data.SH_NAME]
	item[GLOBAL.IT_SPEC] = enchants.duplicate()
	item[GLOBAL.IT_CA] = shield[Data.SH_AC]
	item[GLOBAL.IT_PROT] = shield[Data.SH_PROT]
	if item[GLOBAL.IT_SPEC].has(Data.ENCH_PLUS_1):
		item[GLOBAL.IT_PROT] += 1
	elif item[GLOBAL.IT_SPEC].has(Data.ENCH_PLUS_2):
		item[GLOBAL.IT_PROT] += 2
	elif item[GLOBAL.IT_SPEC].has(Data.ENCH_PLUS_3):
		item[GLOBAL.IT_PROT] += 3
	item[GLOBAL.IT_SKILL] = shield[Data.SH_SKILL]
	item[GLOBAL.IT_TYPE] = GLOBAL.WP_TYPE
	item[GLOBAL.IT_SUBTYPE] = GLOBAL.SUB_SH
	item[GLOBAL.IT_BASE] = baseIdx
	return item

func generateArmor(rarity: int):
	var localRarity = randi() % (rarity + 1)
	while !Data.armorsByRarity.has(localRarity):
		localRarity -= 1
		if localRarity < 0:
			return []
	var rnd = randi() % Data.armorsByRarity[localRarity].size()
	var baseIdx = Data.armorsByRarity[localRarity][rnd]
	var base = Data.armors[baseIdx].duplicate()
	var enchants = generateArmorEnchant(rarity, baseIdx >= Data.A_CAP)
	base[Data.A_NAME] = addEnchantsAffixes(enchants, base[Data.A_NAME])
	id += 1
	base[Data.A_NAME][0] = base[Data.A_NAME][0].capitalize()
	GLOBAL.items[id] = mapArmorToItem(base, baseIdx, enchants)
	return [id]

func generateArmorEnchant(rarity: int, isHelmet: bool):
	var result = []
	if rarity < 1:
		return result
	if randf() < ((rarity-1) * 0.075):
		if !isHelmet and randf() < 0.25:
			result.append(Utils.chooseRandom(Data.enchantsByRarity[1][Data.EN_SLOT_AR][rarity]))
		else:
			result.append(Utils.chooseRandom(Data.enchantsByRarity[0][Data.EN_SLOT_AR][rarity]))
	if randf() < ((rarity) * 0.075):
		if (rarity > 4) and (randf() < 0.25):
			result.append(Data.ENCH_PLUS_2)
		else:
			result.append(Data.ENCH_PLUS_1)
	return result

func mapArmorToItem(armor, baseIdx: int, enchants: Array = []):
	var item = []
	item.resize(GLOBAL.IT_STACK + 1)
	item[GLOBAL.IT_ICON] = armor[Data.A_ICON]
	item[GLOBAL.IT_NAME] = armor[Data.A_NAME]
	item[GLOBAL.IT_SPEC] = enchants.duplicate()
	item[GLOBAL.IT_CA] = armor[Data.A_CA]
	item[GLOBAL.IT_PROT] = armor[Data.A_PROT]
	if item[GLOBAL.IT_SPEC].has(Data.ENCH_PLUS_1):
		item[GLOBAL.IT_CA] += 1
		item[GLOBAL.IT_PROT] += 1
	elif item[GLOBAL.IT_SPEC].has(Data.ENCH_PLUS_2):
		item[GLOBAL.IT_CA] += 2
		item[GLOBAL.IT_PROT] += 2
	elif item[GLOBAL.IT_SPEC].has(Data.ENCH_PLUS_3):
		item[GLOBAL.IT_CA] += 3
		item[GLOBAL.IT_PROT] += 3
	item[GLOBAL.IT_TYPE] = GLOBAL.AR_TYPE
	item[GLOBAL.IT_2H] = armor[Data.A_HELM]
	if armor[Data.A_HELM]:
		item[GLOBAL.IT_SUBTYPE] = GLOBAL.SUB_HE
		item[GLOBAL.IT_CA] = 0
	else:
		item[GLOBAL.IT_SUBTYPE] = GLOBAL.SUB_AR
	item[GLOBAL.IT_BASE] = baseIdx
	return item

func generateThrowing(rarity: int):
	var localRarity = randi() % (rarity + 1)
	while !Data.throwingsByRarity.has(localRarity):
		localRarity -= 1
		if localRarity < 0:
			return []
	var rnd = randi() % Data.throwingsByRarity[localRarity].size()
	var baseIdx = Data.throwingsByRarity[localRarity][rnd]
	for upgrade in Data.throwings[Data.throwingsByRarity[localRarity][rnd]][Data.TH_UPGRADES]:
		if Data.throwings[upgrade][Data.TH_RAR] <= rarity:
			baseIdx = upgrade
	var base = Data.throwings[baseIdx].duplicate()
	var result = []
	var quantity = 1 + (randi() % 5)
	for _i in range(quantity):
		id += 1
		result.append(id)
		GLOBAL.items[id] = mapThrowingToItem(base, baseIdx)
	return result

func mapThrowingToItem(throwing, baseIdx):
	var item = []
	item.resize(GLOBAL.IT_STACK + 1)
	item[GLOBAL.IT_ICON] = throwing[Data.TH_ICON]
	item[GLOBAL.IT_NAME] = throwing[Data.TH_NAME]
	if throwing[Data.W_DMG] != null:
		var dmgDice = GeneralEngine.basicDice(throwing[Data.W_DMG])
		item[GLOBAL.IT_DMG] = GeneralEngine.dmgFromDice(dmgDice, Data.DMG_SLASH)
	item[GLOBAL.IT_SPEC] = throwing[Data.TH_EFFECT]
	item[GLOBAL.IT_TYPE] = GLOBAL.TH_TYPE
	item[GLOBAL.IT_STACK] = throwing[Data.TH_STACK]
	item[GLOBAL.IT_BASE] = baseIdx
	return item

func generatePotion(rarity: int):
	var baseIdx = Data.PO_HEALING
	if randf() > 0.4:
		rarity = randi() % (rarity + 1)
		while !Data.potionsByRarity.has(rarity):
			rarity -= 1
			if rarity < 0:
				return []
		var rnd = randi() % Data.potionsByRarity[rarity].size()
		baseIdx = Data.potionsByRarity[rarity][rnd]
	var base = Data.potions[baseIdx].duplicate()
	var result = []
	var quantity = 1 + (randi() % 3)
	for _i in range(quantity):
		id += 1
		result.append(id)
		GLOBAL.items[id] = mapPotionToItem(base, baseIdx)
	return result

func mapPotionToItem(potion, baseIdx):
	var item = []
	item.resize(GLOBAL.IT_STACK + 1)
	item[GLOBAL.IT_ICON] = potion[Data.PO_ICON]
	item[GLOBAL.IT_NAME] = potion[Data.PO_NAME]
	item[GLOBAL.IT_TYPE] = GLOBAL.PO_TYPE
	item[GLOBAL.IT_STACK] = potion[Data.PO_STACK]
	item[GLOBAL.IT_BASE] = baseIdx
	return item

func generateScroll(rarity: int):
	rarity = randi() % (rarity + 1)
	while !Data.scrollsByRarity.has(rarity):
		rarity -= 1
		if rarity < 0:
			return []
	var rnd = randi() % Data.scrollsByRarity[rarity].size()
	var baseIdx = Data.scrollsByRarity[rarity][rnd]
	var base = Data.scrolls[baseIdx].duplicate()
	id += 1
	GLOBAL.items[id] = mapScrollToItem(base, baseIdx)
	return [id]

func mapScrollToItem(scroll, baseIdx):
	var item = []
	item.resize(GLOBAL.IT_STACK + 1)
	item[GLOBAL.IT_ICON] = Data.SC_ICON_ALL
	item[GLOBAL.IT_NAME] = scroll[Data.SC_NAME]
	item[GLOBAL.IT_SPEC] = scroll[Data.SC_SP]
	item[GLOBAL.IT_TYPE] = GLOBAL.SC_TYPE
	item[GLOBAL.IT_STACK] = scroll[Data.SC_STACK]
	item[GLOBAL.IT_BASE] = baseIdx
	return item

func generateTalisman(rarity: int):
	if rarity < 1:
		return []
	var baseIdx = 0
	var rnd = randf()
	for i in Data.talismans.keys():
		if rnd < Data.talismans[i][Data.TA_PROB]:
			baseIdx = i
			break
	var base = Data.talismans[baseIdx].duplicate()
	id += 1
	var item = mapTalismanToItem(base)
	var enchant = generateTalismanEnchant(rarity)
	item[GLOBAL.IT_NAME] = addEnchantsAffixes(enchant, item[GLOBAL.IT_NAME])
	item[GLOBAL.IT_SPEC] = enchant.duplicate()
	GLOBAL.items[id] = item
	return [id]

func generateTalismanEnchant(rarity: int):
	var result = []
	if rarity < 1:
		return result
	result.append(Utils.chooseRandom(Data.enchantsByRarity[0][Data.EN_SLOT_TA][rarity]))
	return result

func mapTalismanToItem(talisman):
	var item  = []
	item.resize(GLOBAL.IT_STACK + 1)
	item[GLOBAL.IT_ICON] = Utils.chooseRandom(talisman[Data.TA_ICONS])
	item[GLOBAL.IT_NAME] = Utils.chooseRandom(talisman[Data.TA_NAMES])
	item[GLOBAL.IT_TYPE] = GLOBAL.TA_TYPE
	return item

func generateLockpicks(count = null):
	id += 1
	var item  = []
	item.resize(GLOBAL.IT_STACK + 1)
	item[GLOBAL.IT_ICON] = Data.LOCKPICK_ICON
	item[GLOBAL.IT_NAME] = Data.LOCKPICK_NAME
	item[GLOBAL.IT_TYPE] = GLOBAL.LO_TYPE
	if count == null:
		item[GLOBAL.IT_SPEC] = 1 + (randi() % 3)
	else:
		item[GLOBAL.IT_SPEC] = count
	GLOBAL.items[id] = item
	return [id]

func generateGolds(rarity: int, count = null):
	id += 1
	var item  = []
	item.resize(GLOBAL.IT_STACK + 1)
	item[GLOBAL.IT_ICON] = Data.GOLD_ICON
	item[GLOBAL.IT_NAME] = Data.GOLD_NAME
	item[GLOBAL.IT_TYPE] = GLOBAL.GO_TYPE
	if count == null:
		item[GLOBAL.IT_SPEC] = (rarity + 2) * 3 + (randi() % 5)
	else:
		item[GLOBAL.IT_SPEC] = count
	GLOBAL.items[id] = item
	return [id]

func addEnchantsAffixes(enchants: Array, base: String) -> String:
	var hasPrefix = false
	for e in enchants:
		if Data.enchants[e][Data.EN_SUFFIX] == null:
			base = Data.enchants[e][Data.EN_PREFIX] + " " + base
			hasPrefix = true
		elif Data.enchants[e][Data.EN_PREFIX] != null and !hasPrefix and (randf() < 0.5):
			base = Data.enchants[e][Data.EN_PREFIX] + " " + base
			hasPrefix = true
		else:
			base = base + " " + Data.enchants[e][Data.EN_SUFFIX]
	return base

func getWeapon(idx: int):
	var base = Data.weapons[idx].duplicate()
	id += 1
	base[Data.W_NAME][0] = base[Data.W_NAME][0].capitalize()
	GLOBAL.items[id] = mapWeaponToItem(base, idx)
	GLOBAL.items[id][GLOBAL.IT_SPEC] = []
	return [id]

func getShield(idx: int):
	var base = Data.shields[idx].duplicate()
	id += 1
	GLOBAL.items[id] = mapShieldToItem(base, idx)
	GLOBAL.items[id][GLOBAL.IT_SPEC] = []
	return [id]

func getArmor(idx: int):
	var base = Data.armors[idx].duplicate()
	id += 1
	GLOBAL.items[id] = mapArmorToItem(base, idx)
	GLOBAL.items[id][GLOBAL.IT_SPEC] = []
	return [id]

func getPotion(idx: int):
	var base = Data.potions[idx].duplicate()
	id += 1
	GLOBAL.items[id] = mapPotionToItem(base, idx)
	return [id]

func getScroll(idx: int):
	var base = Data.scrolls[idx].duplicate()
	id += 1
	GLOBAL.items[id] = mapScrollToItem(base, idx)
	return [id]

func getThrowable(idx: int):
	var base = Data.throwings[idx].duplicate()
	id += 1
	GLOBAL.items[id] = mapThrowingToItem(base, idx)
	return [id]

func getTalisman(idx: int):
	var base  = Data.talismans[idx].duplicate()
	id += 1
	GLOBAL.items[id] = mapTalismanToItem(base)
	var enchant  = generateTalismanEnchant(0)
	GLOBAL.items[id][GLOBAL.IT_NAME] = addEnchantsAffixes(enchant, GLOBAL.items[id][GLOBAL.IT_NAME])
	GLOBAL.items[id][GLOBAL.IT_NAME][0] = GLOBAL.items[id][GLOBAL.IT_NAME][0].capitalize()
	GLOBAL.items[id][GLOBAL.IT_SPEC] = enchant
	return [id]

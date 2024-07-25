extends Node
class_name ItemGenerator

const RARITY_ENCH = [0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1]

const QU_NORM = 0
const QU_FINE = 1
const QU_HIGH = 2
const QU_PERF = 3
const QU_PROB = [1.0, 0.2, 0.08, 0.02]
const QU_ENCH = [0.0, 0.12, 0.28, 0.5]

const WP_IDX = 0
const AR_IDX = 1
const TA_IDX = 2
const TH_IDX = 3
const SC_IDX = 4
const PO_IDX = 5
const LO_IDX = 6
const GO_IDX = 7
const TYPE_PROB = [10.19, 0.23, 0.07, 0.05, 0.1, 0.1, 0.1, 0.16]

var id = -1

func getItemType():
	var rnd = randf()
	var result = 0
	while rnd >= TYPE_PROB[result]:
		rnd -= TYPE_PROB[result]
		result = (result + 1) % TYPE_PROB.size()
	return result

func generateItem(rarity: int):
	match getItemType():
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
	if rarity >= Data.shields[0][Data.SH_RAR] and randf() < 0.1:
		return generateShield(rarity)
	var localRarity = 0
	for _i in range(2):
		localRarity = max(localRarity, randi() % (rarity+1))
	while !Data.weaponsByRarity.has(localRarity):
		localRarity -= 1
		if localRarity < 0:
			return []
	var rnd = randi() % Data.weaponsByRarity[localRarity].size()
	var baseIdx = Data.weaponsByRarity[localRarity][rnd]
	var base = Data.weapons[baseIdx].duplicate()
	id += 1
	var quality = generateItemQuality(rarity)
	var enchants = generateWeaponEnchant(rarity, quality)
	var hasPrefix = false
	if enchants.size() == 1 or (enchants.size() == 2 and (enchants.has(0) or enchants.has(1))):
		hasPrefix = true
	for e in enchants:
		if Data.wpEnchants[e][Data.WP_EN_SUF] == null:
			base[Data.W_NAME] = Data.wpEnchants[e][Data.WP_EN_PRE] + " " + base[Data.W_NAME]
			hasPrefix = true
		elif Data.wpEnchants[e][Data.WP_EN_PRE] != null and !hasPrefix:
			base[Data.W_NAME] = Data.wpEnchants[e][Data.WP_EN_PRE] + " " + base[Data.W_NAME]
			hasPrefix = true
		else:
			base[Data.W_NAME] = base[Data.W_NAME] + " " + Data.wpEnchants[e][Data.WP_EN_SUF]
	match quality:
		1: base[Data.W_NAME] = "sturdy " + base[Data.W_NAME]
		2: base[Data.W_NAME] = "superior " + base[Data.W_NAME]
		3: base[Data.W_NAME] = "flawless " + base[Data.W_NAME]
	base[Data.W_NAME][0] = base[Data.W_NAME][0].capitalize()
	GLOBAL.items[id] = mapWeaponToItem(base, baseIdx)
	GLOBAL.items[id][GLOBAL.IT_SPEC] = enchants.duplicate()
	var count = 0
	for e in enchants:
		GLOBAL.items[id][GLOBAL.IT_SPEC][count] = Data.wpEnchants[e][Data.WP_EN_ID]
	return [id]

func mapWeaponToItem(weapon, baseIdx: int):
	var item = []
	item.resize(GLOBAL.IT_STACK + 1)
	item[GLOBAL.IT_ICON] = weapon[Data.W_ICON]
	item[GLOBAL.IT_NAME] = weapon[Data.W_NAME]
	var dmgDice = GeneralEngine.basicDice(weapon[Data.W_DMG])
	var dmgType = Data.DMG_SLASH
	if weapon[Data.W_TYPE] == "B":
		dmgType = Data.DMG_BLUNT
	item[GLOBAL.IT_DMG] = GeneralEngine.dmgFromDice(dmgDice, dmgType)
	var hitDice = GeneralEngine.basicDice(weapon[Data.W_HIT])
	item[GLOBAL.IT_HIT] = hitDice
	item[GLOBAL.IT_2H] = weapon[Data.W_2H]
	item[GLOBAL.IT_TYPE] = GLOBAL.WP_TYPE
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
	id += 1
	GLOBAL.items[id] = mapShieldToItem(base, baseIdx)
	return [id]

func mapShieldToItem(shield, baseIdx: int):
	var item = []
	item.resize(GLOBAL.IT_STACK + 1)
	item[GLOBAL.IT_ICON] = shield[Data.SH_ICON]
	item[GLOBAL.IT_NAME] = shield[Data.SH_NAME]
	item[GLOBAL.IT_CA] = shield[Data.SH_AC]
	item[GLOBAL.IT_PROT] = shield[Data.SH_PROT]
	item[GLOBAL.IT_SKILL] = shield[Data.SH_MALUS]
	item[GLOBAL.IT_TYPE] = GLOBAL.WP_TYPE
	item[GLOBAL.IT_BASE] = baseIdx
	return item

func generateArmor(rarity: int):
	while !Data.armorsByRarity.has(rarity):
		rarity -= 1
		if rarity < 0:
			return []
	var rnd = randi() % Data.armorsByRarity[rarity].size()
	var baseIdx = Data.armorsByRarity[rarity][rnd]
	var base = Data.armors[baseIdx]
	id += 1
	GLOBAL.items[id] = mapArmorToItem(base, baseIdx)
	return [id]

func mapArmorToItem(armor, baseIdx: int):
	var item = []
	item.resize(GLOBAL.IT_STACK + 1)
	item[GLOBAL.IT_ICON] = armor[Data.A_ICON]
	item[GLOBAL.IT_NAME] = armor[Data.A_NAME]
	item[GLOBAL.IT_CA] = armor[Data.A_CA]
	item[GLOBAL.IT_PROT] = armor[Data.A_PROT]
	item[GLOBAL.IT_TYPE] = GLOBAL.AR_TYPE
	item[GLOBAL.IT_2H] = armor[Data.A_HELM]
	item[GLOBAL.IT_BASE] = baseIdx
	return item

func generateThrowing(rarity: int):
	var quality = rarity / 2
	# Proba, item type, quantity
	var typeChances = [[0.64, quality, 5], [0.12, 3, 3], [0.12, 4, 5], [0.12, 5, 3]]
	var rnd = randf()
	var idx = quality
	var quantity = 1 + (randi() % 5)
	for i in typeChances:
		if rnd < i[0]:
			idx = i[1]
			quality = 1 + (randi() % i[2])
			break
		rnd -= i[0]
	var base = Data.throwings[idx]
	var result = []
	for _i in range(quantity):
		id += 1
		result.append(id)
		GLOBAL.items[id] = mapThrowingToItem(base, idx)
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
	while !Data.potionsByRarity.has(rarity):
		rarity -= 1
		if rarity < 0:
			return null
	var rnd = randi() % Data.potionsByRarity[rarity].size()
	var baseIdx = Data.potionsByRarity[rarity][rnd]
	var base = Data.potions[baseIdx]
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
	item[GLOBAL.IT_SPEC] = potion[Data.PO_EF]
	item[GLOBAL.IT_TYPE] = GLOBAL.PO_TYPE
	item[GLOBAL.IT_STACK] = potion[Data.PO_STACK]
	item[GLOBAL.IT_BASE] = baseIdx
	return item

func generateScroll(rarity: int):
	while !Data.scrollsByRarity.has(rarity):
		rarity -= 1
		if rarity < 0:
			return null
	var rnd = randi() % Data.scrollsByRarity[rarity].size()
	var baseIdx = Data.scrollsByRarity[rarity][rnd]
	var base = Data.scrolls[baseIdx]
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
	var baseIdx = 0
	var rnd = randf()
	for i in Data.talismans.keys():
		if rnd < Data.talismans[i][Data.TA_PROB]:
			baseIdx = i
			break
	var base  = Data.talismans[baseIdx]
	id += 1
	GLOBAL.items[id] = mapTalismanToItem(base)
	var enchant  = generateTalismanEnchant(rarity)
	if enchant[0] == GLOBAL.AR_TYPE:
		GLOBAL.items[id][GLOBAL.IT_NAME] += (" " + Data.arEnchants[enchant[1]][Data.AR_EN_SUF])
	else:
		GLOBAL.items[id][GLOBAL.IT_NAME] += (" " + Data.taEnchants[enchant[1]][Data.TA_EN_SUF])
	GLOBAL.items[id][GLOBAL.IT_NAME][0] = GLOBAL.items[id][GLOBAL.IT_NAME][0].capitalize()
	GLOBAL.items[id][GLOBAL.IT_SPEC] = enchant
	return [id]

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
		item[GLOBAL.IT_SPEC] = 5 + rarity * 5 + (randi() % 10)
	else:
		item[GLOBAL.IT_SPEC] = count
	GLOBAL.items[id] = item
	return [id]

func generateItemQuality(rarity: int):
	var rnd = randf()
	for i in range(0, 3):
		if rnd < pow(QU_PROB[3-i], (6.0/float(rarity+1))):
			return 3-i
	return 0 

func generateWeaponEnchant(rarity: int, quality: int):
	return [100]
	var enchantValue = randf() * RARITY_ENCH[rarity] + QU_ENCH[quality]
	if enchantValue > 0.96:
		var first = rndWeaponEnchant()
		var second = lowValueWeaponEnchant(first)
		return [first, second, 1]
	if enchantValue > 0.91:
		var first = rndWeaponEnchant()
		var second = lowValueWeaponEnchant(first)
		return [first, second, 0]
	if enchantValue > 0.85:
		return [rndWeaponEnchant(), 1]
	if enchantValue > 0.815:
		return [1]
	if enchantValue > 0.78:
		return [lowValueWeaponEnchant(), 0]
	if enchantValue > 0.70:
		return [lowValueWeaponEnchant()]
	if enchantValue > 0.61:
		return [0]
	return []

func generateTalismanEnchant(rarity: int):
	if randf() < 0.5:
		return rndArmorEnchant()
	else:
		return rndTalismanEnchant()

func lowValueWeaponEnchant(forbidden = -1):
	var result = forbidden
	while result == forbidden:
		result = randi() % 7 + 100
	return result

func rndWeaponEnchant(forbidden = -1):
	var result = forbidden
	if randf() < 0.5:
		while result == forbidden:
			result = randi() % 5 + 200
	else:
		while result == forbidden:
			result = randi() % 7 + 100
	return result

func rndArmorEnchant():
	return [GLOBAL.AR_TYPE, Utils.chooseRandom(Data.arEnchants.keys())]

func rndTalismanEnchant():
	return [GLOBAL.TA_TYPE, Utils.chooseRandom(Data.taEnchants.keys())]

func getWeapon(idx: int):
	var base = Data.weapons[idx].duplicate()
	id += 1
	base[Data.W_NAME][0] = base[Data.W_NAME][0].capitalize()
	GLOBAL.items[id] = mapWeaponToItem(base, idx)
	return [id]

func getShield(idx: int):
	var base = Data.shields[idx].duplicate()
	id += 1
	GLOBAL.items[id] = mapShieldToItem(base, idx)
	return [id]

func getArmor(idx: int):
	var base = Data.armors[idx]
	id += 1
	GLOBAL.items[id] = mapArmorToItem(base, idx)
	return [id]

func getPotion(idx: int):
	var base = Data.potions[idx]
	id += 1
	GLOBAL.items[id] = mapPotionToItem(base, idx)
	return [id]

func getScroll(idx: int):
	var base = Data.scrolls[idx]
	id += 1
	GLOBAL.items[id] = mapScrollToItem(base, idx)
	return [id]

func getThrowable(idx: int):
	var base = Data.throwings[idx]
	id += 1
	GLOBAL.items[id] = mapThrowingToItem(base, idx)
	return [id]

func getTalisman(idx: int):
	var base  = Data.talismans[idx]
	id += 1
	GLOBAL.items[id] = mapTalismanToItem(base)
	var enchant  = generateTalismanEnchant(0)
	if enchant[0] == GLOBAL.AR_TYPE:
		GLOBAL.items[id][GLOBAL.IT_NAME] += (" " + Data.arEnchants[enchant[1]][Data.AR_EN_SUF])
	else:
		GLOBAL.items[id][GLOBAL.IT_NAME] += (" " + Data.taEnchants[enchant[1]][Data.TA_EN_SUF])
	GLOBAL.items[id][GLOBAL.IT_NAME][0] = GLOBAL.items[id][GLOBAL.IT_NAME][0].capitalize()
	GLOBAL.items[id][GLOBAL.IT_SPEC] = enchant
	return [id]

extends Node
class_name ItemGenerator

const TYPE_PROB = [1.2, 0.2, 0.0, 0.0, 0.0, 0.5]
const WP_IDX = 0
const AR_IDX = 1
const TA_IDX = 2
const TH_IDX = 3
const SC_IDX = 4
const PO_IDX = 5

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
		PO_IDX: return generatePotion(rarity)
		_: return null

func generateWeapon(rarity: int):
	while !Data.weaponsByRarity.has(rarity):
		rarity -= 1
		if rarity < 0:
			return null
	var rnd = randi() % Data.weaponsByRarity[rarity].size()
	var base = Data.weapons[Data.weaponsByRarity[rarity][rnd]]
	id += 1
	GLOBAL.items[id] = mapWeaponToItem(base)
	return id

func mapWeaponToItem(weapon):
	var item = []
	item.resize(GLOBAL.IT_STACK + 1)
	item[GLOBAL.IT_ICON] = weapon[Data.W_ICON]
	item[GLOBAL.IT_NAME] = weapon[Data.W_NAME]
	item[GLOBAL.IT_DMG] = weapon[Data.W_DMG]
	item[GLOBAL.IT_HIT] = weapon[Data.W_HIT]
	item[GLOBAL.IT_2H] = weapon[Data.W_2H]
	item[GLOBAL.IT_TYPE] = GLOBAL.WP_TYPE
	return item

func generateArmor(rarity: int):
	while !Data.armorsByRarity.has(rarity):
		rarity -= 1
		if rarity < 0:
			return null
	var rnd = randi() % Data.armorsByRarity[rarity].size()
	var base = Data.armors[Data.armorsByRarity[rarity][rnd]]
	id += 1
	GLOBAL.items[id] = mapArmorToItem(base)
	return id

func mapArmorToItem(armor):
	var item = []
	item.resize(GLOBAL.IT_STACK + 1)
	item[GLOBAL.IT_ICON] = armor[Data.A_ICON]
	item[GLOBAL.IT_NAME] = armor[Data.A_NAME]
	item[GLOBAL.IT_CA] = armor[Data.A_CA]
	item[GLOBAL.IT_PROT] = armor[Data.A_PROT]
	item[GLOBAL.IT_TYPE] = GLOBAL.AR_TYPE
	return item

func generatePotion(rarity: int):
	while !Data.potionsByRarity.has(rarity):
		rarity -= 1
		if rarity < 0:
			return null
	var rnd = randi() % Data.potionsByRarity[rarity].size()
	var base = Data.potions[Data.potionsByRarity[rarity][rnd]]
	id += 1
	GLOBAL.items[id] = mapPotionToItem(base)
	return id

func mapPotionToItem(potion):
	var item = []
	item.resize(GLOBAL.IT_STACK + 1)
	item[GLOBAL.IT_ICON] = potion[Data.PO_ICON]
	item[GLOBAL.IT_NAME] = potion[Data.PO_NAME]
	item[GLOBAL.IT_SPEC] = potion[Data.PO_EF]
	item[GLOBAL.IT_TYPE] = GLOBAL.PO_TYPE
	item[GLOBAL.IT_STACK] = potion[Data.PO_STACK]
	return item

extends Node2D

onready var nameLabel = get_node("TextContainer/Name")
onready var descriptionLabel = get_node("TextContainer/Description")
onready var icon = get_node("Icon")

const NO_ENCHANTS = "It has no special properties."

const WEAPON_SKILL = [
	"It requires no Fighting skills to wield.",
	"It requires *.... Fighting skills to wield.",
	"It requires **... Fighting skills to wield.",
	"It requires ***.. Fighting skills to wield.",
	"It requires ****. Fighting skills to wield.",
	"It requires ***** Fighting skills to wield."
]

const THROWING_SKILL = [
	"It requires no Fighting skills to use.",
	"It requires *.... Fighting skills to use.",
	"It requires **... Fighting skills to use.",
	"It requires ***.. Fighting skills to use.",
	"It requires ****. Fighting skills to use.",
	"It requires ***** Fighting skills to use."
]

const WEAPON_1_HAND = "It is a one-handed weapon."
const WEAPON_2_HAND = "It is a two-handed weapon."

const ARMOR_SKILL = [
	"It requires no Armor skills to wear.",
	"It requires *.... Armor skills to wear.",
	"It requires **... Armor skills to wear.",
	"It requires ***.. Armor skills to wear.",
	"It requires ****. Armor skills to wear.",
	"It requires ***** Armor skills to wear."
]

func weaponDamages(id: int) -> String:
	return "It deals " + GeneralEngine.dmgDicesToString([GLOBAL.items[id][GLOBAL.IT_DMG]], true, true) + "."

func armorStats(id: int) -> String:
	var result = "It provides +" + String(GLOBAL.items[id][GLOBAL.IT_CA]) + " to your Armor Class"
	if GLOBAL.items[id][GLOBAL.IT_PROT] == 0:
		return result + "."
	return result + " and +" + String(GLOBAL.items[id][GLOBAL.IT_PROT]) + " to your Protection."

#TODO talsiman + enchants
func fill(id: int):
	var des = ""
	var item = GLOBAL.items[id]
	nameLabel.text = item[GLOBAL.IT_NAME]
	icon.frame = item[GLOBAL.IT_ICON]
	match item[GLOBAL.IT_TYPE]:
		GLOBAL.WP_TYPE:
			if item[GLOBAL.IT_SUBTYPE] == GLOBAL.SUB_SH:
				des = Data.shieldDescriptions[item[GLOBAL.IT_BASE]]
				des += " " + WEAPON_SKILL[item[GLOBAL.IT_SKILL]]
				des += "\n\n" + armorStats(id)
			else:
				des = Data.weaponDescriptions[item[GLOBAL.IT_BASE]]
				if item[GLOBAL.IT_2H]:
					des += " " + WEAPON_2_HAND
				else:
					des += " " + WEAPON_1_HAND
				des += " " + WEAPON_SKILL[item[GLOBAL.IT_SKILL]]
				des += "\n\n" + weaponDamages(id)
				des += "\n\n" + NO_ENCHANTS
		GLOBAL.AR_TYPE:
			des = Data.armorDescriptions[item[GLOBAL.IT_BASE]]
			des += " " + ARMOR_SKILL[item[GLOBAL.IT_SKILL]]
			des += "\n\n" + armorStats(id)
			des += "\n\n" + NO_ENCHANTS
		GLOBAL.TH_TYPE:
			des = Data.throwingDescriptions[item[GLOBAL.IT_BASE]]
			if item[GLOBAL.IT_DMG] == null:
				des += "\n\n" + SpellDescription.replacePlaceholders(Data.throwingEffects[item[GLOBAL.IT_BASE]], Data.throwings[item[GLOBAL.IT_BASE]][Data.TH_EFFECT])
			else:
				des += " " + THROWING_SKILL[item[GLOBAL.IT_SKILL]]
				des += "\n\n" + weaponDamages(id)
				des += "\n\n" + NO_ENCHANTS
	descriptionLabel.bbcode_text = des

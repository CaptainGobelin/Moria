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

#func scrollSpell(id: int) -> String:
#	var spell = Data.spells[GLOBAL.items[id][GLOBAL.IT_SPEC]]
#	var scroll = Data.scrolls[GLOBAL.items[id][GLOBAL.IT_BASE]]
#	var result = "Use to cast " + spell[Data.SP_NAME]
#	if scroll[Data.SC_RANK] > spell[Data.SP_LVL]:
#		 result += " " + Utils.toRoman(scroll[Data.SC_RANK] + 1)
#	result += ".\n\n"
#	result += SpellDescription.replacePlaceholders(Data.scrollDescriptions[GLOBAL.items[id][GLOBAL.IT_BASE]] ,GLOBAL.items[id][GLOBAL.IT_SPEC])
#	match spell[Data.SP_SAVE]:
#		Data.SAVE_NO:
#			result += " No saving throw."
#		Data.SAVE_PHY:
#			result += " Physics saving throw."
#		Data.SAVE_WIL:
#			result += " Willpower saving throw."
#	return result

#TODO shield, armor, helmet, scroll, potion, throwing, talsiman + enchants
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
				des += "\n\n" + NO_ENCHANTS
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
#		GLOBAL.SC_TYPE:
#			des = scrollSpell(id)
	descriptionLabel.bbcode_text = des

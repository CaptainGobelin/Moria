extends Node2D

onready var nameLabel = get_node("TitleContainer/Name")
onready var infoLabel = get_node("TitleContainer/Info")
onready var effectsLabel = get_node("TitleContainer/Effects")
onready var icon = get_node("Icon")

func fillDescription(id: int):
	clearDescription()
	if not GLOBAL.items.has(id):
		return null
	var item = GLOBAL.items[id]
	match item[GLOBAL.IT_TYPE]:
		GLOBAL.WP_TYPE:
			weaponDescription(item)
			return item[GLOBAL.IT_SUBTYPE]
		GLOBAL.AR_TYPE:
			armorDescription(item)
			return item[GLOBAL.IT_SUBTYPE]
	return null

func clearDescription():
	nameLabel.text = ""
	infoLabel.text = ""
	effectsLabel.text = ""
	icon.visible = false

func weaponDescription(item):
	icon.frame = item[GLOBAL.IT_ICON]
	icon.visible = true
	nameLabel.text = item[GLOBAL.IT_NAME]
	var dmg = "Damage: "
	dmg += item[GLOBAL.IT_DMG].dice.toString()
	dmg += " " + Data.DMG_NAMES[item[GLOBAL.IT_DMG].type]
	infoLabel.text = dmg
	effectsLabel.text = "- No special effect."

func armorDescription(item):
	icon.frame = item[GLOBAL.IT_ICON]
	icon.visible = true
	nameLabel.text = item[GLOBAL.IT_NAME]
	var info = "AC: " + String(item[GLOBAL.IT_CA])
	info += " Prot: " + String(item[GLOBAL.IT_PROT])
	infoLabel.text = info
	effectsLabel.text = "- No special effect."

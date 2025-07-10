extends Node2D

#3 for triple 4 for double and 13 for simple
export (int) var size = 4

onready var nameLabel = get_node("TitleContainer/Name")
onready var infoLabel = get_node("TitleContainer/Info")
onready var effectsLabel = get_node("TitleContainer/Effects")
onready var icon = get_node("Icon")

func _ready():
	if size < 4:
		effectsLabel.margin_top -= (4 - size) * 36
	effectsLabel.margin_bottom = effectsLabel.margin_top + (36 * size)

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
		GLOBAL.TA_TYPE:
			talismanDescription(item)
			return item[GLOBAL.IT_TYPE]
		GLOBAL.SC_TYPE:
			scrollDescription(item)
			return item[GLOBAL.IT_TYPE]
		GLOBAL.PO_TYPE:
			potionDescription(item)
			return item[GLOBAL.PO_TYPE]
		GLOBAL.TH_TYPE:
			throwingDescription(item)
			return item[GLOBAL.TH_TYPE]
	return null

func clearDescription():
	nameLabel.text = ""
	infoLabel.text = ""
	effectsLabel.text = ""
	icon.visible = false

func weaponDescription(item):
	if item[GLOBAL.IT_SUBTYPE] == GLOBAL.SUB_SH:
		shieldDescription(item)
		return
	icon.frame = item[GLOBAL.IT_ICON]
	icon.visible = true
	nameLabel.text = item[GLOBAL.IT_NAME]
	var dmg = "Damage: "
	dmg += item[GLOBAL.IT_DMG].dice.toString()
	dmg += " " + Data.DMG_NAMES[item[GLOBAL.IT_DMG].type]
	infoLabel.text = dmg
	effectsLabel.text = "- No special effect."

func shieldDescription(item):
	#TODO
	pass

func armorDescription(item):
	icon.frame = item[GLOBAL.IT_ICON]
	icon.visible = true
	nameLabel.text = item[GLOBAL.IT_NAME]
	var info = "AC: " + String(item[GLOBAL.IT_CA])
	info += " Prot: " + String(item[GLOBAL.IT_PROT])
	infoLabel.text = info
	effectsLabel.text = "- No special effect."

func talismanDescription(item):
	icon.frame = item[GLOBAL.IT_ICON]
	icon.visible = true
	nameLabel.text = item[GLOBAL.IT_NAME]
	infoLabel.text = ""
	effectsLabel.text = "- No special effect."

func scrollDescription(item):
	icon.frame = item[GLOBAL.IT_ICON]
	icon.visible = true
	nameLabel.text = item[GLOBAL.IT_NAME]
	var scroll = Data.scrolls[item[GLOBAL.IT_BASE]]
	var spell = Data.spells[scroll[Data.SC_SP]]
	infoLabel.text = "Casts "
	infoLabel.text += spell[Data.SP_NAME] + " " + Utils.toRoman(scroll[Data.SC_RANK] + 1)
	infoLabel.text += "."
	if Data.scrollDescriptions.has(item[GLOBAL.IT_BASE]):
		effectsLabel.text = SpellDescription.replacePlaceholders(Data.scrollDescriptions[item[GLOBAL.IT_BASE]], scroll[Data.SC_SP])

func potionDescription(item):
	icon.frame = item[GLOBAL.IT_ICON]
	icon.visible = true
	nameLabel.text = item[GLOBAL.IT_NAME]
	infoLabel.text = ""
	effectsLabel.text = Data.potionDescriptions[item[GLOBAL.IT_BASE]]

func throwingDescription(item):
	icon.frame = item[GLOBAL.IT_ICON]
	icon.visible = true
	nameLabel.text = item[GLOBAL.IT_NAME]
#	var info = "AC: " + String(item[GLOBAL.IT_CA])
#	info += " Prot: " + String(item[GLOBAL.IT_PROT])
#	infoLabel.text = info
	effectsLabel.text = "- No special effect."

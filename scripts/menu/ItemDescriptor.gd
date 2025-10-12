extends Node2D

export (bool) var adaptableSize = false

onready var nameLabel = get_node("TitleContainer/Name")
onready var infoLabel = get_node("TitleContainer/Info")
onready var effectsLabel = get_node("TitleContainer/Effects")
onready var icon = get_node("Icon")
onready var singleTileMap = get_node("SingleTileMap")

func fillDescription(id: int):
	clearDescription()
	if not GLOBAL.items.has(id):
		return null
	var item = GLOBAL.items[id]
	match item[GLOBAL.IT_TYPE]:
		GLOBAL.WP_TYPE:
			weaponDescription(item)
			adaptTileMap()
			return item[GLOBAL.IT_SUBTYPE]
		GLOBAL.AR_TYPE:
			armorDescription(item)
			adaptTileMap()
			return item[GLOBAL.IT_SUBTYPE]
		GLOBAL.TA_TYPE:
			talismanDescription(item)
			adaptTileMap()
			return item[GLOBAL.IT_TYPE]
		GLOBAL.SC_TYPE:
			scrollDescription(item)
			adaptTileMap()
			return item[GLOBAL.IT_TYPE]
		GLOBAL.PO_TYPE:
			potionDescription(item)
			adaptTileMap()
			return item[GLOBAL.PO_TYPE]
		GLOBAL.TH_TYPE:
			throwingDescription(item)
			adaptTileMap()
			return item[GLOBAL.TH_TYPE]
	return null

func adaptTileMap():
	if not adaptableSize:
		return
	singleTileMap.visible = true
	singleTileMap.clear()
	effectsLabel.visible = false
	effectsLabel.visible = true
	var height = float(effectsLabel.rect_position.y + effectsLabel.rect_size.y)
	height *= $TitleContainer.scale.y
	height = int(ceil(height / 9.0))
	for i in range(-1, 12):
		for j in range(-1, height + 1):
			singleTileMap.set_cell(i, j, 3)
	singleTileMap.update_bitmask_region()

func clearDescription():
	nameLabel.text = ""
	infoLabel.text = ""
	effectsLabel.text = ""
	effectsLabel.margin_top = 144
	effectsLabel.margin_bottom = 180
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
	effectsLabel.text = "No magical property."

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
	effectsLabel.text = "No magical property."

func talismanDescription(item):
	effectsLabel.margin_top = 108
	effectsLabel.margin_bottom = 144
	icon.frame = item[GLOBAL.IT_ICON]
	icon.visible = true
	nameLabel.text = item[GLOBAL.IT_NAME]
	infoLabel.text = ""
	effectsLabel.text = "No magical property."

func scrollDescription(item):
	icon.frame = item[GLOBAL.IT_ICON]
	icon.visible = true
	nameLabel.text = item[GLOBAL.IT_NAME]
	var scroll = Data.scrolls[item[GLOBAL.IT_BASE]]
	var spell = Data.spells[scroll[Data.SC_SP]]
	infoLabel.text = "Casts "
	infoLabel.text += spell[Data.SP_NAME]
	if (scroll[Data.SC_RANK] + 1) > spell[Data.SP_LVL]:
		 infoLabel.text += " " + Utils.toRoman(scroll[Data.SC_RANK] + 1)
	infoLabel.text += "."
	if Data.scrollDescriptions.has(item[GLOBAL.IT_BASE]):
		effectsLabel.text = SpellDescription.replacePlaceholders(Data.scrollDescriptions[item[GLOBAL.IT_BASE]], scroll[Data.SC_SP])
	match spell[Data.SP_SAVE]:
		Data.SAVE_NO:
			effectsLabel.text += " No saving throw."
		Data.SAVE_PHY:
			effectsLabel.text += " Physics saving throw."
		Data.SAVE_WIL:
			effectsLabel.text += " Willpower saving throw."

func potionDescription(item):
	effectsLabel.margin_top = 108
	effectsLabel.margin_bottom = 144
	icon.frame = item[GLOBAL.IT_ICON]
	icon.visible = true
	nameLabel.text = item[GLOBAL.IT_NAME]
	infoLabel.text = ""
	effectsLabel.text = Data.potionDescriptions[item[GLOBAL.IT_BASE]]

func throwingDescription(item):
	icon.frame = item[GLOBAL.IT_ICON]
	icon.visible = true
	nameLabel.text = item[GLOBAL.IT_NAME]
	if item[GLOBAL.IT_DMG] == null:
		effectsLabel.margin_top = 108
		effectsLabel.margin_bottom = 144
		effectsLabel.text = SpellDescription.replacePlaceholders(Data.throwingEffects[item[GLOBAL.IT_BASE]], Data.throwings[item[GLOBAL.IT_BASE]][Data.TH_EFFECT])
	else:
		weaponDescription(item)

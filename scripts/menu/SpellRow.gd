extends Node2D

onready var selected = get_node("Selected")
onready var extended = get_node("Selected/Extended")
onready var icon = get_node("Icon")
onready var shortcut = get_node("TextContainer/Shortcut")
onready var spellName = get_node("TextContainer/Name")
onready var remaining = get_node("TextContainer/Remaining")
onready var uses = get_node("TextContainer/Uses")

var spell: int

func setSimpleContent(spellId: int):
	spell = spellId
	self.spellName.text = Data.spells[spell][Data.SP_NAME]
	icon.frame = Data.spells[spell][Data.SP_ICON]
	remaining.text = Utils.toRoman(Data.spells[spell][Data.SP_LVL])
	remaining.align = Label.ALIGN_CENTER
	uses.text = ""
	shortcut.text = ""
	extended.visible = false

func setContent(spellRow):
	spell = spellRow[0]
	spellName.text = spellRow[1]
	icon.frame = spellRow[2]
	remaining.text = String(spellRow[3])
	remaining.align = Label.ALIGN_RIGHT
	uses.text = "/" + String(spellRow[4])
	if spellRow[5] != null:
		shortcut.text = String(spellRow[5])
	else:
		shortcut.text = ""
	extended.visible = true

tool
extends Node2D

onready var selected = get_node("Selected")
onready var extended = get_node("Selected/Extended")
onready var icon = get_node("Icon")
onready var shortcut = get_node("TextContainer/Shortcut")
onready var spellName = get_node("TextContainer/Name")
onready var uses = get_node("TextContainer/Uses")

var spell: int

func _ready():
	selected.visible = false

func setSimpleContent(spellId: int):
	spell = spellId
	self.spellName.text = Data.spells[spell][Data.SP_NAME]
	icon.frame = Data.spells[spell][Data.SP_ICON]
	uses.align = Label.ALIGN_LEFT
	uses.text = Utils.toRoman(Data.spells[spell][Data.SP_LVL])
	shortcut.visible = false
	extended.visible = false

func setContent(spellRow):
	spell = spellRow[0]
	spellName.text = spellRow[1]
	icon.frame = spellRow[2]
	uses.align = Label.ALIGN_CENTER
	uses.text = String(spellRow[3]) + "/" + String(spellRow[4])
	if spellRow[5] != null:
		shortcut.text = String(spellRow[5])
	else:
		shortcut.text = ""
	shortcut.visible = true
	extended.visible = true

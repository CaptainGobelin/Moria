extends Node2D

onready var selected = get_node("Selected")
onready var icon = get_node("Icon")
onready var shortcut = get_node("TextContainer/Shortcut")
onready var spellName = get_node("TextContainer/Name")
onready var remaining = get_node("TextContainer/Remaining")
onready var uses = get_node("TextContainer/Uses")

var spell

func setContent(spellRow):
	spell = spellRow[0]
	spellName.text = spellRow[1]
	icon.frame = spellRow[2]
	remaining.text = String(spellRow[3])
	uses.text = "/" + String(spellRow[4])

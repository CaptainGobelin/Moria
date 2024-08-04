extends Node2D

onready var nameLabel = get_node("Description/TextContainer/Name")
onready var descriptor = get_node("Description/TextContainer/SpellDescription")
onready var icon = get_node("Description/Icon")

var currentId = 0
var currentSpell = Data.SP_MAGIC_MISSILE

# Called when the node enters the scene tree for the first time.
func _ready():
	descriptor.generateDescription(currentSpell, 2)
	set_process_input(true)

func _input(event):
	if event.is_action_released("ui_down"):
		currentId += 1
		currentId = currentId % Data.spellDescriptions.keys().size()
		currentSpell = Data.spellDescriptions.keys()[currentId]
		selectSpell(currentSpell)
	elif event.is_action_released("ui_up"):
		currentId -= 1
		currentId = currentId % Data.spellDescriptions.keys().size()
		currentSpell = Data.spellDescriptions.keys()[currentId]
		selectSpell(currentSpell)

func selectSpell(idx: int):
	descriptor.generateDescription(idx, 2)
	nameLabel.text = Data.spells[idx][Data.SP_NAME]
	icon.frame = Data.spells[idx][Data.SP_ICON]

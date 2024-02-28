extends Node2D

onready var spellList = get_node("TileMap/SpellList")

var currentRow = -1

func _ready():
	set_process_input(false)

func _input(event):
	if (event.is_action_pressed("ui_up")):
		spellList.selectPrevious()
	elif (event.is_action_pressed("ui_down")):
		spellList.selectNext()
	elif (event.is_action_released("spellMenu")):
		close()
	elif (event.is_action_released("ui_cancel")):
		close()

func open():
	spellList.init(Ref.character.spells.getSpellsRows())
	visible = true
	Ref.currentLevel.visible = false
	Ref.game.set_process_input(false)
	set_process_input(true)

func close():
	visible = false
	Ref.currentLevel.visible = true
	Ref.game.set_process_input(true)
	set_process_input(false)

func fillList():
	spellList = Ref.character.spells.getSpellsRows()

func setRow(row: int):
	currentRow = posmod(row, spellList.size())

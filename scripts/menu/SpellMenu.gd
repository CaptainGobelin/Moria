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
	elif (event.is_action_released("castSpell") or event.is_action_released("ui_accept")):
		var spell = spellList.getSelected()
		if spell == null:
			return
		if Ref.character.spells.spellsUses[spell] == 0:
			Ref.ui.writeNoSpell(Data.spells[spell][Data.SP_NAME])
			return
		close()
		Ref.game.spellHandler.castSpellAsync(spell)
	elif (event.is_action_released("assignShortcut")):
		var spell = spellList.getSelected()
		if spell == null:
			return
		Ref.ui.askForNumber(9, self, "Assign to which key?")
		var coroutineReturn = yield(Ref.ui, "coroutine_signal")
		if coroutineReturn == null or !(coroutineReturn is int):
			return
		Ref.character.shortcuts.assign(coroutineReturn, GLOBAL.SP_TYPE, spell)
		Ref.ui.writeAssignedKey(coroutineReturn, Data.spells[spell][Data.SP_NAME])
		spellList.init(Ref.character.spells.getSpellsRows(), spellList.currentIndex)

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

extends Node2D

onready var spellList = get_node("SpellList")
onready var descriptor = get_node("SpellDescription")
onready var scroller = get_node("MenuScroller")
onready var commandLabel = get_node("TextContainer/Commands")
onready var emptyListLabel = get_node("TextContainer/EmptyList")

var currentRow = -1

func _ready():
	set_process_input(false)
	commandLabel.bbcode_text = "[center]"
	commandLabel.bbcode_text += "Cast spell:" + Ref.ui.color("Enter", "yellow")
	commandLabel.bbcode_text += "   Assign:" + Ref.ui.color("A", "yellow")
	commandLabel.bbcode_text += "   Close:" + Ref.ui.color("Esc", "yellow")
	commandLabel.bbcode_text += "[/center]"

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
		Ref.character.castSpell(spell)
	elif (event.is_action_released("assignShortcut")):
		var spell = spellList.getSelected()
		if spell == null:
			return
		Ref.ui.askForNumber(9, self, "Assign to which key?")
		var coroutineReturn = yield(Ref.ui, "coroutine_signal")
		GLOBAL.currentMode = GLOBAL.MODE_SPELL
		if coroutineReturn == null or !(coroutineReturn is int):
			return
		Ref.character.shortcuts.assign(coroutineReturn, GLOBAL.SP_TYPE, spell)
		Ref.ui.writeAssignedKey(coroutineReturn, Data.spells[spell][Data.SP_NAME])
		spellList.init(Ref.character.spells.getSpellsRows(), spellList.currentIndex)

func open():
	spellList.init(Ref.character.spells.getSpellsRows())
	visible = true
	descriptor.spellUses.visible = false
	descriptor.spellSchool.visible = true
	emptyListLabel.visible = spellList.spellList.empty()
	Ref.currentLevel.visible = false
	GLOBAL.currentMode = GLOBAL.MODE_SPELL
	MasterInput.setMaster(self)

func close():
	visible = false
	Ref.currentLevel.visible = true
	GLOBAL.currentMode = GLOBAL.MODE_NORMAL
	MasterInput.setMaster(Ref.game)

func fillList():
	spellList = Ref.character.spells.getSpellsRows()

func setRow(row: int):
	currentRow = posmod(row, spellList.size())

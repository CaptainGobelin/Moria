extends Node2D

onready var descriptor = get_node("SpellDescription")
onready var rows = get_node("SpellList")

var selected: int = 0
var currentList: Array = []
var source = null

func _ready():
	set_process_input(false)

func open(school: int, level: int, caller):
	selected = 0
	source = caller
	visible = true
	Ref.currentLevel.visible = false
	Ref.game.set_process_input(false)
	set_process_input(true)
	var rank = Ref.character.spells.getSpellRank(school)
	var list = Data.classes[Ref.character.charClass][Data.CL_LIST]
	currentList = []
	for i in range(1, level+1):
		if !Data.spellsPerSchool[list].has(school):
			continue
		if !Data.spellsPerSchool[list][school].has(i):
			continue
		for s in Data.spellsPerSchool[list][school][i]:
			if !Ref.character.spells.spells.has(s):
				currentList.append(s)
	if currentList.empty():
		close()
	loadSpellList(rank)

func close():
	visible = false
	Ref.currentLevel.visible = true
	Ref.game.set_process_input(true)
	set_process_input(false)
	if source != null:
		source.open()

func loadSpellList(rank: int):
	var count = 0
	for s in currentList:
		if count > 6:
			return
		rows.get_child(count).setSimpleContent(s)
		count += 1
	for i in range(count, 6):
		rows.get_child(i).visible = false
	refreshSelection()

func refreshSelection():
	var count = 0
	for row in rows.get_children():
		if count == selected:
			row.selected.visible = true
			selectSpell(row.spell)
		else:
			row.selected.visible = false
		count += 1

func _input(event):
	if event.is_action_released("ui_down"):
		selected = Utils.modulo(selected+1, currentList.size())
		refreshSelection()
	elif event.is_action_released("ui_up"):
		selected = Utils.modulo(selected-1, currentList.size())
		refreshSelection()
	elif event.is_action_released("ui_accept"):
		var spell = rows.get_child(selected).spell
		Ref.character.spells.learnSpell(spell)
		close()
	return

func selectSpell(idx: int):
	var school = Data.spells[idx][Data.SP_SCHOOL]
	var saveCap = Ref.character.spells.getSavingThrow(school)
	var rank = Ref.character.spells.getSpellRank(school)
	descriptor.selectSpell(idx, rank, saveCap)

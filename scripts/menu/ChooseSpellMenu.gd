extends Node2D

onready var descriptor = get_node("SpellDescription")
onready var rows = get_node("SpellList")

var selected: int = 0
var currentList: Array = []

func open(school: int):
	visible = true
	set_process_input(true)
#	var level = Ref.character.spells.getSchoolRank(school)
#	var rank = Ref.character.spells.getSpellRank(school)
#	var list = Data.classes[Ref.character.charClass][Data.CL_LIST]
	var level = 3
	var rank = 3
	var list = Data.SP_LIST_ARCANE
	currentList = []
	for i in range(1, level+1):
		if !Data.spellsPerSchool[list].has(school):
			continue
		if !Data.spellsPerSchool[list][school].has(i):
			continue
		currentList.append_array(Data.spellsPerSchool[list][school][i])
	loadSpellList(rank)

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

func _ready():
	open(Data.SC_EVOCATION)

func _input(event):
	if event.is_action_released("ui_down"):
		selected = Utils.modulo(selected+1, currentList.size())
		refreshSelection()
	elif event.is_action_released("ui_up"):
		selected = Utils.modulo(selected-1, currentList.size())
		refreshSelection()
	return

func selectSpell(idx: int):
#	var school = Data.spells[idx][Data.SP_SCHOOL]
#	var saveCap = Ref.character.spells.getSavingThrow(school)
#	var rank = Ref.character.spells.getSpellRank(school)
	var saveCap = 5
	var rank = 1
	descriptor.selectSpell(idx, rank, saveCap)

extends Node2D

onready var scroller = get_node("MenuScroller")
onready var descriptor = get_node("SpellDescription")
onready var rows = get_node("SpellList")

var selected: int = 0
var currentList: Array = []
var source = null
var startRow = 0

func _ready():
	set_process_input(false)

func open(school: int, level: int, caller):
	selected = 0
	startRow = 0
	source = caller
	visible = true
	Ref.currentLevel.visible = false
	MasterInput.setMaster(self)
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
	loadSpellList()

func close():
	visible = false
	Ref.currentLevel.visible = true
	MasterInput.setMaster(Ref.game)
	if source != null:
		source.open()

func loadSpellList():
	var count = startRow
	for row in rows.get_children():
		if count > (currentList.size() - 1):
			row.visible = false
			continue
		row.setSimpleContent(currentList[count])
		row.visible = true
		if count == selected:
			row.selected.visible = true
			selectSpell(row.spell)
		else:
			row.selected.visible = false
		count += 1
	scroller.setArrows(startRow, currentList.size())

func _input(event):
	if event.is_action_released("ui_down"):
		selected = selected + 1
		if selected > startRow + 5:
			startRow += 1
		if selected >= currentList.size():
			selected = 0
			startRow = 0
		loadSpellList()
	elif event.is_action_released("ui_up"):
		selected = selected - 1
		if selected < startRow:
			startRow -= 1
		if selected < 0:
			selected = currentList.size() - 1
			startRow = max(0, currentList.size() - 6)
		loadSpellList()
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

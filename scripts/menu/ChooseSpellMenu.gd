extends Node2D

signal selected

onready var prompt = get_node("TextContainer/Prompt")
onready var scroller = get_node("MenuScroller")
onready var descriptor = get_node("SpellDescription")
onready var rows = get_node("SpellList")

var selected: int = 0
var currentList: Array = []
var startRow = 0

func _ready():
	set_process_input(false)

func open(school: int, list: int = -1):
	selected = 0
	startRow = 0
	visible = true
	MasterInput.setMaster(self)
	if list == -1:
		list = Data.classes[Ref.character.charClass][Data.CL_LIST]
	currentList = []
	var schools = [school]
	if school == -1:
		schools = [Data.SC_EVOCATION, Data.SC_ENCHANTMENT, Data.SC_ABJURATION,
			Data.SC_DIVINATION, Data.SC_CONJURATION]
	for s in schools:
		if Ref.character.spells.getSchoolSkillLevel(s) == 0:
			continue
		for i in range(1, Ref.character.spells.getSpellRank(s)+2):
			if !Data.spellsPerSchool[list].has(s):
				continue
			if !Data.spellsPerSchool[list][s].has(i):
				continue
			for spell in Data.spellsPerSchool[list][s][i]:
				if !Ref.character.spells.spells.has(spell):
					currentList.append(spell)
	if currentList.empty():
		close()
		emit_signal("selected", null)
	var promptText = "Choose a new "
	match school:
		Data.SC_EVOCATION:
			promptText += "Evocation"
		Data.SC_ENCHANTMENT:
			promptText += "Enchantment"
		Data.SC_ABJURATION:
			promptText += "Abjuration"
		Data.SC_DIVINATION:
			promptText += "Divination"
		Data.SC_CONJURATION:
			promptText += "Conjuration"
	promptText += " spell to add to your spellbook"
	prompt.text = promptText
	rows.init(currentList)

func close():
	visible = false
	MasterInput.eraseInputStack()

func _input(event):
	if event.is_action_released("ui_down"):
		selected = selected + 1
		if selected > startRow + 5:
			startRow += 1
		if selected >= currentList.size():
			selected = 0
			startRow = 0
		rows.selectNext()
	elif event.is_action_released("ui_up"):
		selected = selected - 1
		if selected < startRow:
			startRow -= 1
		if selected < 0:
			selected = currentList.size() - 1
			startRow = max(0, currentList.size() - 6)
		rows.selectPrevious()
	elif event.is_action_released("ui_accept"):
		var spell = rows.get_child(selected).spell
		Ref.character.spells.learnSpell(spell)
		close()
		emit_signal("selected", spell)
	return

func selectSpell(idx: int):
	var school = Data.spells[idx][Data.SP_SCHOOL]
	var saveCap = Ref.character.spells.getSavingThrow(school)
	var rank = Ref.character.spells.getSpellRank(school)
	descriptor.selectSpell(idx, rank, saveCap)

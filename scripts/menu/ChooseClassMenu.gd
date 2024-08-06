extends Node2D

onready var selected = get_node("Selected")
onready var skills = get_node("TextContainer/Skills/Values")
onready var spellList = get_node("TextContainer/SpellList")
onready var hp = get_node("TextContainer/HP")

var selectedClass = 0

func _ready():
	set_process_input(true)
	setSelected()

func _input(event):
	if event.is_action_released("ui_right"):
		selectedClass = Utils.modulo(selectedClass + 1, 8)
		setSelected()
	elif event.is_action_released("ui_left"):
		selectedClass = Utils.modulo(selectedClass - 1, 8)
		setSelected()

func setSelected():
	selected.rect_position.x = 96 + selectedClass * 36
	setSpellList()
	setHp()
	setSkills()

func setSpellList():
	var msg = "Spell list: "
	match Data.classes[selectedClass][Data.CL_LIST]:
		Data.SP_LIST_ARCANE:
			spellList.text = msg + "Arcane"
		Data.SP_LIST_DIVINE:
			spellList.text = msg + "Divine"
		Data.SP_LIST_NATURE:
			spellList.text = msg + "Nature"

func setHp():
	var msg = "HP: " + String(Data.classes[selectedClass][Data.CL_HP])
	msg += " + " + String(Data.classes[selectedClass][Data.CL_HPLVL]) + "/lvl"
	hp.text = msg

func setSkills():
	var msg = ""
	for i in range(11):
		var rank = Data.classes[selectedClass][Data.CL_SK][i]
		var mastery = Data.classes[selectedClass][Data.CL_SKMAS][i]
		if mastery == -1:
			msg += "Special\n"
			continue
		var result = "."
		if mastery > 0:
			result += ".."
		if mastery > 1:
			result += ".."
		for r in range(rank):
			result[r] = '*'
		msg += result + "\n"
	skills.text = msg

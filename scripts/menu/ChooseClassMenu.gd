extends Node2D

onready var selected = get_node("Selected")
onready var skills = get_node("TextContainer/Skills/Values")
onready var gear = get_node("TextContainer/Gear")
onready var feat = get_node("TextContainer/Feat")
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
	setGear()
	setFeat()

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

func setGear():
	var msg = "Starting kit:\n"
	var kit = Data.CLASS_KITS[selectedClass]
	if kit[Data.KIT_WP] != -1:
		msg += "\n- " + Data.weapons[kit[Data.KIT_WP]][Data.W_NAME]
	if kit[Data.KIT_SH] != -1:
		msg += "\n- " + Data.shields[kit[Data.KIT_SH]][Data.SH_NAME]
	if kit[Data.KIT_AR] != -1:
		msg += "\n- " + Data.armors[kit[Data.KIT_AR]][Data.A_NAME]
	var potions = {}
	for i in kit[Data.KIT_PO]:
		if potions.has(i):
			potions[i] += 1
		else:
			potions[i] = 1
	for p in potions.keys():
		if potions[p] > 1:
			msg += "\n- " + Utils.addArticle(Data.potions[p][Data.PO_NAME], potions[p])
		else:
			msg += "\n- " + Data.potions[p][Data.PO_NAME]
	var scrolls = {}
	for i in kit[Data.KIT_SC]:
		if scrolls.has(i):
			scrolls[i] += 1
		else:
			scrolls[i] = 1
	for s in scrolls.keys():
		if scrolls[s] > 1:
			msg += "\n- " + Utils.addArticle(Data.scrolls[s][Data.SC_NAME], scrolls[s])
		else:
			msg += "\n- " + Data.scrolls[s][Data.SC_NAME]
	if kit[Data.KIT_LO] > 0:
		msg += "\n- " + String(kit[Data.KIT_LO]) + " lockpicks"
	if kit[Data.KIT_GO] > 0:
		msg += "\n- " + String(kit[Data.KIT_GO]) + " golds"
	gear.text = msg

func setFeat():
	var msg = "Starting feat: "
	msg += Data.feats[selectedClass][Data.FE_NAME] + "\n"
	msg += Data.featDescriptions[selectedClass]
	feat.text = msg

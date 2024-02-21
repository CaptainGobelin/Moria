extends Node2D

onready var game = get_parent()
onready var tabs = get_node("Tabs").get_children()
onready var skillsScreen = get_node("SkillsScreen")
onready var skills = get_node("SkillsScreen/SkillsList").get_children()
onready var skp = get_node("SkillsScreen/TextContainer/RemainingPoints")

var currentTab = 0
var currentRow = 0

func _ready():
	set_process_input(false)

func open():
	setTab(currentTab)
	visible = true
	game.currentLevel.visible = false
	game.set_process_input(false)
	set_process_input(true)

func close():
	visible = false
	game.currentLevel.visible = true
	game.set_process_input(true)
	set_process_input(false)

func _input(event):
	if (event.is_action_pressed("ui_left")):
		currentTab = max(currentTab-1, 0)
		setTab(currentTab)
	elif (event.is_action_pressed("ui_right")):
		currentTab = min(currentTab+1, tabs.size()-1)
		setTab(currentTab)
	elif (event.is_action_pressed("ui_up")):
		match currentTab:
			GLOBAL.CHAR_SKILLS:
				selectSkill(currentRow - 1)
	elif (event.is_action_pressed("ui_down")):
		match currentTab:
			GLOBAL.CHAR_SKILLS:
				selectSkill(currentRow + 1)
	elif (event.is_action_released("characterMenu")):
		close()
	elif (event.is_action_released("ui_cancel")):
		close()
	elif (event.is_action_released("ui_accept")):
		match currentTab:
			GLOBAL.CHAR_SKILLS:
				buySkill(currentRow)

func buySkill(row):
	var charSkp = game.character.stats.skp
	if charSkp == 0:
		game.ui.writeNoSkp()
		return
	var skill = game.character.stats.skills[row]
	var mastery = game.character.stats.masteries[row]
	if skill == (mastery*2 + 1):
		game.ui.writeNoMastery()
		return
	game.character.stats.skills[row] += 1
	game.character.stats.skp -= 1
	setTab(currentTab, currentRow)

func setTab(tab, row = 0):
	for t in tabs:
		t.setInactive()
	tabs[tab].setActive()
	match tab:
		GLOBAL.CHAR_SKILLS:
			skillsScreen.visible = true
			var count = 0
			for s in skills:
				s.setValue(game.character.stats.skills[count], game.character.stats.masteries[count])
				count += 1
			skp.text = String(game.character.stats.skp)
			selectSkill(max(min(row, skills.size()-1), 0))
		GLOBAL.CHAR_FEATS:
			skillsScreen.visible = false
			currentRow = row
		GLOBAL.CHAR_STATUSES:
			skillsScreen.visible = false
			currentRow = row
		_:
			currentRow = row

func selectSkill(row: int):
	currentRow = posmod(row, skills.size())
	for s in skills:
		s.unselect()
	skills[currentRow].select()

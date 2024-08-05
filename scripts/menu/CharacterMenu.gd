extends Node2D

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
	Ref.currentLevel.visible = false
	Ref.game.set_process_input(false)
	set_process_input(true)

func close():
	visible = false
	Ref.currentLevel.visible = true
	Ref.game.set_process_input(true)
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
	var charSkp = Ref.character.skills.skp
	if charSkp == 0:
		Ref.ui.writeNoSkp()
		return
	var skill = Ref.character.skills.skills[row]
	var mastery = Ref.character.skills.masteries[row]
	if skill == (mastery*2 + 1):
		Ref.ui.writeNoMastery()
		return
	var event = Ref.character.skills.improve(row)
	if event == null:
		setTab(currentTab, currentRow)
		return
	match event[0]:
		"chooseSpell":
			close()
			Ref.game.chooseSpellMenu.open(event[1], event[2], self)

func setTab(tab, row = 0):
	for t in tabs:
		t.setInactive()
	tabs[tab].setActive()
	match tab:
		GLOBAL.CHAR_SKILLS:
			skillsScreen.visible = true
			var count = 0
			for s in skills:
				s.setValue(Ref.character.skills.skills[count], Ref.character.skills.masteries[count])
				count += 1
			skp.text = String(Ref.character.skills.skp)
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

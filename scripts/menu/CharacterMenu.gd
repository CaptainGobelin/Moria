extends Node2D

onready var tabs = get_node("Tabs").get_children()
onready var descriptor = get_node("TextContainer/Description")
onready var skillsScreen = get_node("SkillsScreen")
onready var skills = get_node("SkillsScreen/SkillsList").get_children()
onready var skp = get_node("SkillsScreen/TextContainer/RemainingPoints")
onready var featsScreen = get_node("FeatsScreen")
onready var featList = get_node("FeatsScreen/FeatsList")
onready var chooseFeat = get_node("FeatsScreen/TextContainer/ChooseFeat")
onready var statusesScreen = get_node("StatusesScreen")
onready var statusesList = get_node("StatusesScreen/StatusesList")
onready var scroller = get_node("StatusesScreen/MenuScroller")

var currentTab = 0
var currentRow = 0
var startRow = 0

func _ready():
	set_process_input(false)

func open():
	setTab(currentTab)
	visible = true
	Ref.currentLevel.visible = false
	MasterInput.setMaster(self)

func close():
	visible = false
	Ref.currentLevel.visible = true
	MasterInput.setMaster(Ref.game)

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
			GLOBAL.CHAR_FEATS:
				if Ref.character.skills.feats.size() == 0:
					return
				currentRow = Utils.modulo(currentRow - 1, Ref.character.skills.feats.size())
				setTab(currentTab, currentRow)
			GLOBAL.CHAR_STATUSES:
				var statusesSize = Ref.character.statuses.keys().size()
				if statusesSize == 0:
					currentRow = 0
				else:
					currentRow = Utils.modulo(currentRow - 1, Ref.character.statuses.keys().size())
				setTab(currentTab, currentRow)
	elif (event.is_action_pressed("ui_down")):
		match currentTab:
			GLOBAL.CHAR_SKILLS:
				selectSkill(currentRow + 1)
			GLOBAL.CHAR_FEATS:
				if Ref.character.skills.feats.size() == 0:
					return
				currentRow = Utils.modulo(currentRow + 1, Ref.character.skills.feats.size())
				setTab(currentTab, currentRow)
			GLOBAL.CHAR_STATUSES:
				var statusesSize = Ref.character.statuses.keys().size()
				if statusesSize == 0:
					currentRow = 0
				else:
					currentRow = Utils.modulo(currentRow + 1, Ref.character.statuses.keys().size())
				setTab(currentTab, currentRow)
	elif (event.is_action_released("characterMenu")):
		close()
	elif (event.is_action_released("ui_cancel")):
		close()
	elif (event.is_action_released("ui_accept")):
		match currentTab:
			GLOBAL.CHAR_SKILLS:
				buySkill(currentRow)
			GLOBAL.CHAR_FEATS:
				if Ref.character.skills.ftp > 0:
					visible = false
					Ref.game.chooseFeatMenu.open([], null, true)
					yield(Ref.game.chooseFeatMenu, "selected")
					setTab(currentTab, currentRow)
					visible = true
					MasterInput.setMaster(self)

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
			visible = false
			Ref.game.chooseSpellMenu.open(event[1], event[2])
			if Ref.game.chooseSpellMenu.visible:
				yield(Ref.game.chooseSpellMenu, "selected")
			setTab(currentTab, currentRow)
			visible = true
			MasterInput.setMaster(self)

func setTab(tab, row = 0):
	for t in tabs:
		t.setInactive()
	tabs[tab].setActive()
	descriptor.text = ""
	match tab:
		GLOBAL.CHAR_SKILLS:
			skillsScreen.visible = true
			featsScreen.visible = false
			statusesScreen.visible = false
			var count = 0
			for s in skills:
				s.setValue(Ref.character.skills.skills[count], Ref.character.skills.masteries[count])
				count += 1
			skp.text = String(Ref.character.skills.skp)
			selectSkill(max(min(row, skills.size()-1), 0))
		GLOBAL.CHAR_FEATS:
			descriptor.text = "No feat selected"
			skillsScreen.visible = false
			featsScreen.visible = true
			statusesScreen.visible = false
			currentRow = row
			var count = 0
			for f in featList.get_children():
				if count < Ref.character.skills.feats.size():
					f.setSimpleContent(Ref.character.skills.feats[count])
					f.visible = true
					f.selected.visible = false
					if count == currentRow:
						f.selected.visible = true
						descriptor.text = Data.featDescriptions[f.feat]
				else:
					f.visible = false
				count += 1
			chooseFeat.visible = Ref.character.skills.ftp > 0
		GLOBAL.CHAR_STATUSES:
			descriptor.text = "No status selected"
			if row == 0:
				startRow = 0
			skillsScreen.visible = false
			featsScreen.visible = false
			statusesScreen.visible = true
			currentRow = row
			var statuses = Ref.character.statuses.keys()
			startRow = min(currentRow, max(currentRow-6, startRow))
			scroller.setArrows(startRow, statuses.size())
			var count = 0
			for s in statusesList.get_children():
				if count < statuses.size():
					s.setSimpleContent(Ref.character.statuses[statuses[count+startRow]][0])
					s.visible = true
					s.selected.visible = false
					if (count+startRow) == currentRow:
						s.selected.visible = true
				else:
					s.visible = false
				count += 1
		_:
			currentRow = row
	if descriptor.text.find("\n") > 0:
		descriptor.align = Label.ALIGN_LEFT
	else:
		descriptor.align = Label.ALIGN_CENTER

func selectSkill(row: int):
	currentRow = posmod(row, skills.size())
	for s in skills:
		s.unselect()
	skills[currentRow].select()

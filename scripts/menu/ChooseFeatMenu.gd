extends Node2D

signal selected

onready var prompt = get_node("TextContainer/Prompt")
onready var rows = get_node("Feats")
onready var scroller = get_node("MenuScroller")
onready var cancelLabel = get_node("TextContainer/Cancel")
onready var description = get_node("TextContainer/Description")

var featList: Array = []
var selected: int = 0
var startRow: int = 0
var canCancel: bool = true
var masterFeat = null

func _ready():
	set_process_input(false)

func open(feats: Array = [], masterFeatId = null, canCancelChoice: bool = true):
	masterFeat = masterFeatId
	if feats.empty():
		feats = Data.feats.keys()
		featList = []
		for f in feats:
			if Data.feats[f][Data.FE_CHOOSE] and !Ref.character.skills.feats.has(f):
				featList.append(f)
	else:
		featList = feats
	featList = Skills.removeForbiddenFeats(featList)
	if featList.empty():
		close()
		return
	if masterFeat == null:
		prompt.text = "Choose a feat"
	else:
		match masterFeat:
			Data.FEAT_MAGE:
				prompt.text = "Choose a specialization"
			Data.FEAT_CLERIC:
				prompt.text = "Choose a sphere"
			Data.FEAT_SKILLED:
				prompt.text = "Choose a skill"
			_:
				prompt.text = "Choose a feat"
	visible = true
	selected = 0
	startRow = 0
	canCancel = canCancelChoice
	loadFeatList()
	MasterInput.setMaster(self)

func close():
	visible = false

func loadFeatList():
	var count = startRow
	for row in rows.get_children():
		if count > (featList.size() - 1):
			row.visible = false
			continue
		row.setSimpleContent(featList[count])
		row.visible = true
		row.selected.visible = (count == selected)
		count += 1
	selectFeat(featList[selected])
	scroller.setArrows(startRow, featList.size())

func selectFeat(feat: int):
	description.text = Data.featDescriptions[feat]
	if description.text.find("\n") > 0:
		description.align = Label.ALIGN_LEFT
	else:
		description.align = Label.ALIGN_CENTER

func _input(event):
	if event.is_action_released("ui_down"):
		selected = selected + 1
		if selected > startRow + 5:
			startRow += 1
		if selected >= featList.size():
			selected = 0
			startRow = 0
		loadFeatList()
	elif event.is_action_released("ui_up"):
		selected = selected - 1
		if selected < startRow:
			startRow -= 1
		if selected < 0:
			selected = featList.size() - 1
			startRow = max(0, featList.size() - 6)
		loadFeatList()
	elif event.is_action_released("ui_accept"):
		var subFeats = Data.feats[featList[selected]][Data.FE_SUBS]
		if subFeats.size() > 0:
			open(subFeats, featList[selected], true)
			return
		if is_instance_valid(Ref.game.chooseClassMenu):
			close()
			emit_signal("selected", featList[selected])
			return
		else:
			visible = false
			var featResult = Ref.character.skills.addFeat(featList[selected])
			if featResult != null:
				match featResult[0]:
					"chooseSpell":
						Ref.game.chooseSpellMenu.open(featResult[1], featResult[2])
						if Ref.game.chooseSpellMenu.visible:
							yield(Ref.game.chooseSpellMenu, "selected")
			Ref.character.skills.ftp -= 1
			close()
			emit_signal("selected", featList[selected])
	elif event.is_action_released("ui_cancel"):
		if canCancel:
			if masterFeat == null:
				close()
				emit_signal("selected", null)
			else:
				open([], null, Data.feats[masterFeat][Data.FE_CHOOSE])
		else:
			close()
			emit_signal("selected", null)

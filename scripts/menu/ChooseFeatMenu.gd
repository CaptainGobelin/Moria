extends Node2D

signal selected

onready var rows = get_node("Feats")
onready var scroller = get_node("MenuScroller")
onready var cancelLabel = get_node("TextContainer/Cancel")
onready var description = get_node("TextContainer/Description")

var featList: Array = []
var selected: int = 0
var startRow: int = 0
var canCancel: bool = true

func _ready():
	open(Data.feats.keys())

func open(feats: Array, masterFeat = null, canCancel: bool = true):
	if feats.empty():
		close()
	visible = true
	selected = 0
	startRow = 0
	featList = feats
	self.canCancel = canCancel
	cancelLabel.visible = canCancel
	loadFeatList()
	set_process_input(true)

func close(selectedFeat = null):
	visible = false
	set_process_input(false)
	emit_signal("selected", selectedFeat)

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
		close()
	elif canCancel and event.is_action_released("ui_cancel"):
		close()

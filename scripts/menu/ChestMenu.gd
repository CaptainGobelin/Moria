extends Node2D

onready var items = get_node("ChestItems")
onready var animator = get_node("AnimationPlayer")

var currentTab = 0

func _ready():
	set_process_input(false)

func open(id: int):
	animator.play("Open")
	var itemList = GLOBAL.chests[id][GLOBAL.CH_CONTENT]
	items.init(getSimpleItemRows(itemList), 0)
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
	if (event.is_action_pressed("ui_up")):
		items.selectPrevious()
	elif (event.is_action_pressed("ui_down")):
		items.selectNext()
	elif (event.is_action_released("ui_cancel")):
		close()

func getSimpleItemRows(itemList: Array):
	var result = []
	for id in itemList:
		var item = GLOBAL.items[id]
		match item[GLOBAL.IT_TYPE]:
			GLOBAL.WP_TYPE:
				result.append([GLOBAL.WP_TYPE, id, item[GLOBAL.IT_NAME], false, item[GLOBAL.IT_ICON]])
			GLOBAL.AR_TYPE:
				result.append([GLOBAL.AR_TYPE, id, item[GLOBAL.IT_NAME], false, item[GLOBAL.IT_ICON]])
			GLOBAL.PO_TYPE:
				result.append([GLOBAL.PO_TYPE, item[GLOBAL.IT_NAME], item[GLOBAL.IT_ICON], [item]])
	return result

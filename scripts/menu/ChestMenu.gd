extends Node2D

onready var items = get_node("ChestItems")
onready var animator = get_node("AnimationPlayer")

var chestId: int

func _ready():
	set_process_input(false)

func open(id: int):
	chestId = id
	if !GLOBAL.chests[id][GLOBAL.CH_OPENED]:
		animator.play("Open")
		GLOBAL.chests[id][GLOBAL.CH_OPENED] = true
	else:
		animator.play("Skip")
	var itemList = GLOBAL.chests[id][GLOBAL.CH_CONTENT]
	items.init(getSimpleItemRows(itemList), 0)
	visible = true
	Ref.currentLevel.visible = false
	GLOBAL.currentMode = GLOBAL.MODE_CHEST
	Ref.game.set_process_input(false)
	set_process_input(true)

func close():
	if GLOBAL.chests[chestId][GLOBAL.CH_CONTENT].size() == 0:
		instance_from_id(chestId).queue_free()
		GLOBAL.chests.erase(chestId)
	visible = false
	Ref.currentLevel.visible = true
	GLOBAL.currentMode = GLOBAL.MODE_NORMAL
	Ref.game.set_process_input(true)
	set_process_input(false)

func _input(event):
	if (event.is_action_pressed("ui_up")):
		items.selectPrevious()
	elif (event.is_action_pressed("ui_down")):
		items.selectNext()
	elif (event.is_action_released("ui_cancel")):
		close()
	elif (event.is_action_released("ui_accept") or event.is_action_released("pickLoot")):
		var selected = items.getSelected()
		if selected == null:
			return
		if selected.size() == 1:
			Ref.character.pickItem(selected)
			GLOBAL.chests[chestId][GLOBAL.CH_CONTENT].erase(selected[0])
		else:
			Ref.ui.askForNumber(selected.size(), self)
			var coroutineReturn = yield(Ref.ui, "coroutine_signal")
			GLOBAL.currentMode = GLOBAL.MODE_CHEST
			if coroutineReturn != null and coroutineReturn is int:
				var subSelected = selected.slice(0, coroutineReturn-1)
				Ref.character.pickItem(selected.slice(0, coroutineReturn-1))
				for s in subSelected:
					GLOBAL.chests[chestId][GLOBAL.CH_CONTENT].erase(s)
		var itemList = GLOBAL.chests[chestId][GLOBAL.CH_CONTENT]
		items.init(getSimpleItemRows(itemList), items.currentIndex)

func getSimpleItemRows(itemList: Array):
	var itemDict = {}
	for id in itemList:
		var item = GLOBAL.items[id]
		if item[GLOBAL.IT_STACK] != null:
			if itemDict.has(item[GLOBAL.IT_STACK]):
				itemDict[item[GLOBAL.IT_STACK]].append(id)
			else:
				itemDict[item[GLOBAL.IT_STACK]] = [id]
		else:
			itemDict[id + 10000] = [id]
	var result = []
	for stackId in itemDict.keys():
		var id = itemDict[stackId][0]
		var item = GLOBAL.items[id]
		match item[GLOBAL.IT_TYPE]:
			GLOBAL.WP_TYPE:
				result.append([GLOBAL.WP_TYPE, id, item[GLOBAL.IT_NAME], false, item[GLOBAL.IT_ICON]])
			GLOBAL.AR_TYPE:
				result.append([GLOBAL.AR_TYPE, id, item[GLOBAL.IT_NAME], false, item[GLOBAL.IT_ICON]])
			GLOBAL.PO_TYPE:
				result.append([GLOBAL.PO_TYPE, item[GLOBAL.IT_NAME], item[GLOBAL.IT_ICON], itemDict[stackId]])
			GLOBAL.SC_TYPE:
				result.append([GLOBAL.SC_TYPE, item[GLOBAL.IT_NAME], item[GLOBAL.IT_ICON], itemDict[stackId]])
			GLOBAL.TH_TYPE:
				result.append([GLOBAL.TH_TYPE, item[GLOBAL.IT_NAME], item[GLOBAL.IT_ICON], itemDict[stackId]])
			GLOBAL.TA_TYPE:
				result.append([GLOBAL.TA_TYPE, id, item[GLOBAL.IT_NAME], false, item[GLOBAL.IT_ICON]])
			GLOBAL.LO_TYPE:
				var itemName = Utils.addArticle(item[GLOBAL.IT_NAME], item[GLOBAL.IT_SPEC])
				result.append([GLOBAL.LO_TYPE, id, itemName, false, item[GLOBAL.IT_ICON]])
			GLOBAL.GO_TYPE:
				var itemName = Utils.addArticle(item[GLOBAL.IT_NAME], item[GLOBAL.IT_SPEC])
				result.append([GLOBAL.GO_TYPE, id, itemName, false, item[GLOBAL.IT_ICON]])
	return result

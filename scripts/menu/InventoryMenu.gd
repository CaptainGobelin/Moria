extends Node2D

onready var inventory = get_node("Tabs")
onready var description = get_node("Description")
onready var currentItem = get_node("CurrentItem")
onready var itemList = get_node("ItemList")
onready var scroller = get_node("MenuScroller")
onready var keyLabel = get_node("TextContainer/Key")
onready var tabs = inventory.get_children()
const weaponsTab = 0
const armorsTab = 1
const scrollsTab = 2
const potionsTab = 3
const throwingsTab = 4

var currentTab = 0

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
		itemList.selectPrevious()
	elif (event.is_action_pressed("ui_down")):
		itemList.selectNext()
	elif (event.is_action_released("inventory")):
		close()
	elif (event.is_action_released("ui_cancel")):
		close()
	elif (event.is_action_released("ui_accept")):
		var selected = itemList.getSelected()
		if selected == null:
			return
		if GLOBAL.items[selected][GLOBAL.IT_TYPE] == GLOBAL.PO_TYPE:
			Ref.character.quaffPotion(selected)
		else:
			Ref.character.switchItem(selected)
		setTab(currentTab, itemList.currentIndex, itemList.currentStartRow)
	elif (event.is_action_released("dropItem")):
		var selected = itemList.getSelected()
		if selected == null:
			return
		Ref.character.dropItem(selected)
		setTab(currentTab, itemList.currentIndex, itemList.currentStartRow)
	elif (event.is_action_released("quaffPotion")):
		if currentTab != GLOBAL.INV_POTIONS:
			return
		var selected = itemList.getSelected()
		if selected == null:
			return
		Ref.character.quaffPotion(selected)
		setTab(currentTab, itemList.currentIndex, itemList.currentStartRow)
	elif (event.is_action_released("throw")):
		if currentTab != GLOBAL.INV_THROWINGS:
			return
		var selected = itemList.getSelected()
		if selected == null:
			return
		close()
		Ref.game.throwHandler.throwAsync(selected)
	elif (event.is_action_released("assignShortcut")):
		if currentTab == GLOBAL.INV_ARMORS or currentTab == GLOBAL.INV_TALSMANS:
			return
		var selected = itemList.getSelected()
		if selected == null:
			return
		Ref.ui.askForNumber(9, self, "Assign to which key?")
		var coroutineReturn = yield(Ref.ui, "coroutine_signal")
		if coroutineReturn == null or !(coroutineReturn is int):
			return
		match currentTab:
			GLOBAL.INV_WEAPONS:
				Ref.character.shortcuts.assign(coroutineReturn, GLOBAL.WP_TYPE, selected)
			GLOBAL.INV_POTIONS:
				Ref.character.shortcuts.assign(coroutineReturn, GLOBAL.PO_TYPE, selected)
			GLOBAL.INV_THROWINGS:
				Ref.character.shortcuts.assign(coroutineReturn, GLOBAL.TH_TYPE, selected)
		Ref.ui.writeAssignedKey(coroutineReturn, GLOBAL.items[selected][GLOBAL.IT_NAME])
		setTab(currentTab, itemList.currentIndex, itemList.currentStartRow)

func setTab(tab, row = 0, startRow = 0):
	for t in tabs:
		t.setInactive()
	tabs[tab].setActive()
	match tab:
		GLOBAL.INV_WEAPONS:
			keyLabel.visible = true
			itemList.init(Ref.character.inventory.getWeaponRows(), row, GLOBAL.WP_TYPE, startRow)
		GLOBAL.INV_ARMORS:
			keyLabel.visible = false
			itemList.init(Ref.character.inventory.getArmorRows(), row, GLOBAL.AR_TYPE, startRow)
		GLOBAL.INV_POTIONS:
			keyLabel.visible = true
			itemList.init(Ref.character.inventory.getPotionRows(), row, GLOBAL.PO_TYPE, startRow)
		GLOBAL.INV_THROWINGS:
			keyLabel.visible = true
			itemList.init(Ref.character.inventory.getThrowingRows(), row, GLOBAL.TH_TYPE, startRow)
		GLOBAL.INV_TALSMANS:
			keyLabel.visible = false
			itemList.init(Ref.character.inventory.getTalismanRows(), row, GLOBAL.TA_TYPE, startRow)
		_:
			itemList.init([], row, 0)

extends Node2D

onready var inventory = get_node("Tabs")
onready var description = get_node("Description")
onready var currentItem = get_node("CurrentItem")
onready var itemList = get_node("ItemList")
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
		Ref.character.switchItem(selected)
		setTab(currentTab, itemList.currentIndex)
	elif (event.is_action_released("dropItem")):
		var selected = itemList.getSelected()
		if selected == null:
			return
		Ref.character.dropItem(selected)
		setTab(currentTab, itemList.currentIndex)
	elif (event.is_action_released("quaffPotion")):
		if currentTab != GLOBAL.INV_POTIONS:
			return
		var selected = itemList.getSelected()
		if selected == null:
			return
		Ref.character.quaffPotion(selected)
		setTab(currentTab, itemList.currentIndex)

func setTab(tab, row = 0):
	for t in tabs:
		t.setInactive()
	tabs[tab].setActive()
	match tab:
		GLOBAL.INV_WEAPONS:
			itemList.init(Ref.character.inventory.getWeaponRows(), row, GLOBAL.WP_TYPE)
		GLOBAL.INV_ARMORS:
			itemList.init(Ref.character.inventory.getArmorRows(), row, GLOBAL.AR_TYPE)
		GLOBAL.INV_POTIONS:
			itemList.init(Ref.character.inventory.getPotionRows(), row, GLOBAL.PO_TYPE)
		_:
			itemList.init([], row, 0)

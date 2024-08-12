extends Node2D

onready var inventory = get_node("Tabs")
onready var description = get_node("Description")
onready var currentItem = get_node("CurrentItem")
onready var itemList = get_node("ItemList")
onready var scroller = get_node("MenuScroller")
onready var keyLabel = get_node("TextContainer/Key")
onready var tabs = inventory.get_children()

var currentTab = 0

func _ready():
	set_process_input(false)

func open():
	setTab(currentTab)
	visible = true
	Ref.currentLevel.visible = false
	GLOBAL.currentMode = GLOBAL.MODE_INVENTORY
	MasterInput.setMaster(self)

func close():
	visible = false
	Ref.currentLevel.visible = true
	GLOBAL.currentMode = GLOBAL.MODE_NORMAL
	MasterInput.setMaster(Ref.game)

func _input(event):
	if (event.is_action_pressed("ui_left")):
		currentTab = Utils.modulo(currentTab-1, tabs.size())
		setTab(currentTab)
	elif (event.is_action_pressed("ui_right")):
		currentTab = Utils.modulo(currentTab+1, tabs.size())
		setTab(currentTab)
	elif (event.is_action_pressed("ui_up")):
		itemList.selectPrevious()
	elif (event.is_action_pressed("ui_down")):
		itemList.selectNext()
	elif (event.is_action_released("inventory")):
		close()
	elif (event.is_action_released("ui_cancel")):
		close()
	elif (event.is_action_released("ui_accept")) \
	and (currentTab == GLOBAL.INV_WEAPONS or currentTab == GLOBAL.INV_ARMORS \
	or currentTab == GLOBAL.INV_TALSMANS):
		var selected = itemList.getSelected()
		if selected == null:
			return
		Ref.character.switchItem(selected)
		setTab(currentTab, itemList.currentIndex, itemList.currentStartRow)
	elif (event.is_action_released("dropItem")):
		var selected = itemList.getSelected()
		if selected == null:
			return
		Ref.character.dropItem(selected)
		setTab(currentTab, itemList.currentIndex, itemList.currentStartRow)
	elif (event.is_action_released("quaffPotion") or event.is_action_released("ui_accept")) \
	and currentTab == GLOBAL.INV_POTIONS:
		var selected = itemList.getSelected()
		if selected == null:
			return
		Ref.character.quaffPotion(selected)
		setTab(currentTab, itemList.currentIndex, itemList.currentStartRow)
	elif (event.is_action_released("readScroll") or event.is_action_released("ui_accept")) \
	and currentTab == GLOBAL.INV_SCROLLS:
		var selected = itemList.getSelected()
		if selected == null:
			return
		var spellId = GLOBAL.items[selected][GLOBAL.IT_SPEC]
		if Data.spells[spellId][Data.SP_TARGET] == Data.SP_TARGET_TARGET:
			if GLOBAL.targets.size() == 0:
				Ref.ui.noTarget()
				return
		close()
		Ref.game.spellHandler.castSpellAsync(spellId, selected)
	elif (event.is_action_released("throw") or event.is_action_released("ui_accept")) \
	and currentTab == GLOBAL.INV_THROWINGS:
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
		GLOBAL.currentMode = GLOBAL.MODE_INVENTORY
		if coroutineReturn == null or !(coroutineReturn is int):
			return
		match currentTab:
			GLOBAL.INV_WEAPONS:
				Ref.character.shortcuts.assign(coroutineReturn, GLOBAL.WP_TYPE, selected)
			GLOBAL.INV_POTIONS:
				Ref.character.shortcuts.assign(coroutineReturn, GLOBAL.PO_TYPE, selected)
			GLOBAL.INV_SCROLLS:
				Ref.character.shortcuts.assign(coroutineReturn, GLOBAL.SC_TYPE, selected)
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
		GLOBAL.INV_SCROLLS:
			keyLabel.visible = true
			itemList.init(Ref.character.inventory.getScrollRows(), row, GLOBAL.SC_TYPE, startRow)
		GLOBAL.INV_THROWINGS:
			keyLabel.visible = true
			itemList.init(Ref.character.inventory.getThrowingRows(), row, GLOBAL.TH_TYPE, startRow)
		GLOBAL.INV_TALSMANS:
			keyLabel.visible = false
			itemList.init(Ref.character.inventory.getTalismanRows(), row, GLOBAL.TA_TYPE, startRow)
		_:
			itemList.init([], row, 0)

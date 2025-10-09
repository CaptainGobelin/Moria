extends Node2D

onready var inventory = get_node("Tabs")
onready var itemList = get_node("ItemList")
onready var scroller = get_node("MenuScroller")
onready var keyLabel = get_node("TextContainer/Key")
onready var simpleDescriptor = get_node("SimpleDescription")
onready var simpleDescriptor1 = get_node("SimpleDescription/Description/ItemDescriptor")
onready var doubleDescriptor = get_node("DoubleDescription")
onready var doubleDescriptor1 = get_node("DoubleDescription/Description/ItemDescriptor")
onready var doubleDescriptor2 = get_node("DoubleDescription/CurrentItem/ItemDescriptor")
onready var tripleDescriptor = get_node("TripleDescription")
onready var tripleDescriptor1 = get_node("TripleDescription/Description/ItemDescriptor")
onready var tripleDescriptor2 = get_node("TripleDescription/CurrentItem/ItemDescriptor1")
onready var tripleDescriptor3 = get_node("TripleDescription/CurrentItem/ItemDescriptor2")
onready var detailPanel = get_node("DetailPanel")
onready var tabs = inventory.get_children()
onready var weaponsCommandsLabel = get_node("Tabs/Weapons/TextContainer2/Commands")
onready var armorsCommandsLabel = get_node("Tabs/Armors/TextContainer2/Commands")
onready var scrollsCommandsLabel = get_node("Tabs/Scrolls/TextContainer2/Commands")
onready var potionsCommandsLabel = get_node("Tabs/Potions/TextContainer2/Commands")
onready var throwingsCommandsLabel = get_node("Tabs/Throwings/TextContainer2/Commands")
onready var talismansCommandsLabel = get_node("Tabs/Talismans/TextContainer2/Commands")

const INVENTORY_MODE = 0
const DETAILS_MODE = 1

var currentMode = INVENTORY_MODE
var currentTab = 0

var weaponCommands = [
	["Equip", "Enter"],
	["Assign", "A"],
	["Details", "Tab"],
	["Drop", "D"],
	["Close", "Esc"]
]

var armorCommands = [
	["Equip", "Enter"],
	["Details", "Tab"],
	["Drop", "D"],
	["Close", "Esc"]
]

var itemCommands = [
	["Use", "Enter"],
	["Assign", "A"],
	["Details", "Tab"],
	["Drop", "D"],
	["Close", "Esc"]
]

func _ready():
	set_process_input(false)
	weaponsCommandsLabel.bbcode_text = Utils.cmdString(weaponCommands)
	armorsCommandsLabel.bbcode_text = Utils.cmdString(armorCommands)
	scrollsCommandsLabel.bbcode_text = Utils.cmdString(itemCommands)
	potionsCommandsLabel.bbcode_text = Utils.cmdString(itemCommands)
	throwingsCommandsLabel.bbcode_text = Utils.cmdString(itemCommands)
	talismansCommandsLabel.bbcode_text = Utils.cmdString(armorCommands)

func open():
	currentMode = INVENTORY_MODE
	simpleDescriptor.visible = false
	doubleDescriptor.visible = false
	tripleDescriptor.visible = false
	detailPanel.visible = false
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
	if currentMode == DETAILS_MODE:
		if (event.is_action_released("inventory")):
			close()
		elif (event.is_action_released("ui_cancel")):
			detailPanel.visible = false
			currentMode = INVENTORY_MODE
		elif (event.is_action_released("ui_tab")):
			detailPanel.visible = false
			currentMode = INVENTORY_MODE
	elif (event.is_action_released("ui_tab")):
		detailPanel.visible = true
		currentMode = DETAILS_MODE
	elif (event.is_action_pressed("ui_left")):
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
		Ref.character.readScroll(selected)
	elif (event.is_action_released("throw") or event.is_action_released("ui_accept")) \
	and currentTab == GLOBAL.INV_THROWINGS:
		var selected = itemList.getSelected()
		if selected == null:
			return
		close()
		Ref.character.throw(selected)
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

func _on_ItemList_itemSelected(itemId):
	simpleDescriptor.visible = false
	doubleDescriptor.visible = false
	tripleDescriptor.visible = false
	match currentTab:
		GLOBAL.INV_WEAPONS:
			doubleDescriptor.visible = true
		GLOBAL.INV_ARMORS:
			doubleDescriptor.visible = true
		GLOBAL.INV_POTIONS:
			simpleDescriptor.visible = true
		GLOBAL.INV_SCROLLS:
			simpleDescriptor.visible = true
		GLOBAL.INV_THROWINGS:
			simpleDescriptor.visible = true
		GLOBAL.INV_TALSMANS:
			tripleDescriptor.visible = true
	if itemId != null:
		var itemType = null
		match GLOBAL.items[itemId][GLOBAL.IT_TYPE]:
			GLOBAL.WP_TYPE:
				itemType = doubleDescriptor1.fillDescription(itemId)
			GLOBAL.AR_TYPE:
				itemType = doubleDescriptor1.fillDescription(itemId)
			GLOBAL.TA_TYPE:
				itemType = tripleDescriptor1.fillDescription(itemId)
			GLOBAL.SC_TYPE:
				itemType = simpleDescriptor1.fillDescription(itemId)
			GLOBAL.PO_TYPE:
				itemType = simpleDescriptor1.fillDescription(itemId)
			GLOBAL.TH_TYPE:
				itemType = simpleDescriptor1.fillDescription(itemId)
		match itemType:
			GLOBAL.SUB_WP:
				doubleDescriptor2.fillDescription(Ref.character.inventory.getWeapon())
			GLOBAL.SUB_SH:
				doubleDescriptor2.fillDescription(Ref.character.inventory.getShield())
			GLOBAL.SUB_AR:
				doubleDescriptor2.fillDescription(Ref.character.inventory.getArmor())
			GLOBAL.SUB_HE:
				doubleDescriptor2.fillDescription(Ref.character.inventory.getHelmet())
			GLOBAL.TA_TYPE:
				tripleDescriptor2.fillDescription(Ref.character.inventory.getTalisman1())
				tripleDescriptor3.fillDescription(Ref.character.inventory.getTalisman2())
	else:
		simpleDescriptor1.clearDescription()
		doubleDescriptor1.clearDescription()
		doubleDescriptor2.clearDescription()
		tripleDescriptor1.clearDescription()
		tripleDescriptor2.clearDescription()
		tripleDescriptor3.clearDescription()

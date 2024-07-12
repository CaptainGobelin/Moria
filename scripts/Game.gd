extends Node2D

class_name Game

onready var inventoryMenu = get_node("InventoryMenu")
onready var characterMenu = get_node("CharacterMenu")
onready var spellMenu = get_node("SpellMenu")
onready var chestMenu = get_node("ChestMenu")
onready var dungeonGenerator = get_node("Utils/DungeonGenerator_v2")
onready var pathfinder = get_node("Utils/Pathfinder")
onready var itemGenerator = get_node("Utils/ItemGenerator") as ItemGenerator
onready var pickupLootHandler = get_node("Utils/PickupLootHandler")
onready var spellHandler = get_node("Utils/SpellHandler")
onready var throwHandler = get_node("Utils/ThrowHandler")

func _ready():
	randomize()
	Ref.game = self
	testFloor()
	set_process_input(true)
	GLOBAL.currentMode = GLOBAL.MODE_NORMAL
	Tests.runAll()

func cleanFloor():
	GLOBAL.traps.clear()
	GLOBAL.hiddenDoors.clear()
	GLOBAL.lockedDoors.clear()
	for i in range(GLOBAL.FLOOR_SIZE_X):
		Ref.currentLevel.searched.append([])
		for _j in range(GLOBAL.FLOOR_SIZE_Y):
			Ref.currentLevel.searched[i].append(false)
	for m in Ref.currentLevel.monsters.get_children():
		m.free()
	for c in Ref.currentLevel.chests.get_children():
		c.free()
	GLOBAL.chests.clear()
	for t in Ref.currentLevel.traps.get_children():
		t.free()
	GLOBAL.traps.clear()
	for l in Ref.currentLevel.loots.get_children():
		l.free()
	for i in GLOBAL.itemsOnFloor.keys():
		GLOBAL.items.erase(i)
	GLOBAL.itemsOnFloor.clear()

func testFloor():
	cleanFloor()
	dungeonGenerator.simpleFloor()
	Ref.currentLevel.initShadows()

func newFloor():
	cleanFloor()
	var spawnPos = dungeonGenerator.generate()
	Ref.currentLevel.initShadows()
	Ref.currentLevel.placeCharacter(spawnPos)
	for _i in range(5):
		Ref.currentLevel.spawnMonster()
	for _i in range(randi() % 4):
		Ref.currentLevel.createChest()
	for _i in range(3 + (randi() % 4)):
		Ref.currentLevel.dropItem()

func _input(event):
	if (event.is_action_pressed("ui_up")):
		Ref.character.moveAsync(Vector2(0,-1))
	elif (event.is_action_pressed("ui_down")):
		Ref.character.moveAsync(Vector2(0,1))
	elif (event.is_action_pressed("ui_left")):
		Ref.character.moveAsync(Vector2(-1,0))
	elif (event.is_action_pressed("ui_right")):
		Ref.character.moveAsync(Vector2(1,0))
	elif (event.is_action_released("inventory")):
		inventoryMenu.open()
	elif (event.is_action_released("characterMenu")):
		characterMenu.open()
	elif (event.is_action_released("spellMenu")):
		spellMenu.open()
	elif (event.is_action_released("pickLoot")):
		pickupLootHandler.pickupLootAsync()
	elif (event.is_action_released("castSpell")):
		var choices = Ref.character.shortcuts.getShortcutList(GLOBAL.SP_TYPE)
		if choices == null:
			Ref.ui.writeNoSpellAssigned()
		else:
			Ref.ui.writeWhichSpell(choices)
			Ref.ui.askForChoice(choices, self)
			var coroutineReturn = yield(Ref.ui, "coroutine_signal")
			if coroutineReturn > 0:
				var spell = Ref.character.shortcuts.getItem(coroutineReturn, GLOBAL.SP_TYPE)
				spellHandler.castSpellAsync(spell)
	elif (event.is_action_released("throw")):
		var choices = Ref.character.shortcuts.getShortcutList(GLOBAL.TH_TYPE)
		if choices == null:
			Ref.ui.writeNoThrowingAssigned()
		else:
			Ref.ui.writeWhichThrowing(choices)
			Ref.ui.askForChoice(choices, self)
			var coroutineReturn = yield(Ref.ui, "coroutine_signal")
			if coroutineReturn > 0:
				var item = Ref.character.shortcuts.getItem(coroutineReturn, GLOBAL.TH_TYPE)
				Ref.game.throwHandler.throwAsync(item)
	elif (event.is_action_released("readScroll")):
		var choices = Ref.character.shortcuts.getShortcutList(GLOBAL.SC_TYPE)
		if choices == null:
			Ref.ui.writeNoScrollAssigned()
		else:
			Ref.ui.writeWhichScroll(choices)
			Ref.ui.askForChoice(choices, self)
			var coroutineReturn = yield(Ref.ui, "coroutine_signal")
			if coroutineReturn > 0:
				var item = Ref.character.shortcuts.getItem(coroutineReturn, GLOBAL.SC_TYPE)
				Ref.game.spellHandler.castSpellAsync(GLOBAL.items[item][GLOBAL.IT_SPEC], item)
	elif (event.is_action_released("quaffPotion")):
		var choices = Ref.character.shortcuts.getShortcutList(GLOBAL.PO_TYPE)
		if choices == null:
			Ref.ui.writeNoPotionAssigned()
		else:
			Ref.ui.writeWhichPotion(choices)
			Ref.ui.askForChoice(choices, self)
			var coroutineReturn = yield(Ref.ui, "coroutine_signal")
			if coroutineReturn > 0:
				var item = Ref.character.shortcuts.getItem(coroutineReturn, GLOBAL.PO_TYPE)
				Ref.character.quaffPotion(item)
	elif (event.is_action_released("search")):
		Ref.character.search()
	elif (event.is_action_released("debug_new_floor")):
		newFloor()

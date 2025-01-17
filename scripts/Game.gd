extends Node2D

class_name Game

export (int, "Normal, Fast, Tests, Dungeon, Menu") var start = 0

onready var inventoryMenu = get_node("InventoryMenu")
onready var characterMenu = get_node("CharacterMenu")
onready var spellMenu = get_node("SpellMenu")
onready var chestMenu = get_node("ChestMenu")
onready var chooseClassMenu = get_node("ChooseClassMenu")
onready var chooseNameMenu = get_node("ChooseNameMenu")
onready var chooseSpellMenu = get_node("ChooseSpellMenu")
onready var chooseFeatMenu = get_node("ChooseFeatMenu")
onready var dungeonGenerator = get_node("Utils/DungeonGenerator_v2")
onready var pathfinder = get_node("Utils/Pathfinder")
onready var itemGenerator = get_node("Utils/ItemGenerator") as ItemGenerator
onready var pickupLootHandler = get_node("Utils/PickupLootHandler")
onready var spellHandler = get_node("Utils/SpellHandler")
onready var throwHandler = get_node("Utils/ThrowHandler")
onready var restHandler = get_node("Utils/RestHandler")
onready var saveSystem = get_node("Utils/SaveSystem")

var random_seed: int
var autoexplore = false setget setAutoExplore

func _ready():
	if GLOBAL.startingMode != null:
		start = GLOBAL.startingMode
	if start == 4:
		get_tree().change_scene("res://scenes/UI/TitleScreen.tscn")
	randomize()
	var randomSeed = randi()
	seed(randomSeed)
	Ref.game = self
	set_process_input(false)
	set_process(false)
	match start:
		0:
			chooseClassMenu.open()
		1:
			chooseClassMenu.queue_free()
			Ref.character.init(Data.CL_FIGHTER)
			startGame()
		3:
			Ref.currentLevel.fog.visible = false
			Ref.currentLevel.shadows.visible = false
			Ref.character.setPosition(dungeonGenerator.newFloor())
			set_process_input(true)
		_:
			Ref.character.init(Data.CL_FIGHTER)
			startGame()

func _process(delta):
	if autoexplore:
		if !GLOBAL.targets.empty():
			Ref.ui.write("You cannot explore there are enemies on sight.")
			autoexplore = false
			return
		var dir = pathfinder.findNextStep(pathfinder.exploreMap, Ref.character.pos)
		if dir == null:
			pathfinder.dijkstraCompute()
			dir = pathfinder.findNextStep(pathfinder.exploreMap, Ref.character.pos)
			if dir == null:
				Ref.ui.write("Nothing to explore.")
				return
		Ref.character.moveAsync(dir)
	else:
		GeneralEngine.newTurn()

func setAutoExplore(value: bool):
	autoexplore = value
	set_process(autoexplore)
	if autoexplore:
		pathfinder.dijkstraCompute()

func startGame():
	match start:
		2:
			testFloor()
		_:
			newFloor()
			Ref.currentLevel.setLocation(1, Data.BIOME_DUNGEON)
	Ref.currentLevel.refresh_view()
	MasterInput.setMaster(self)
	GLOBAL.currentMode = GLOBAL.MODE_NORMAL
	if start == 2:
		Tests.runAll()

func nextFloor():
	if !Ref.currentLevel.getNextLocation():
		#TODO add a final screen
		pass
	newFloor()

func cleanFloor():
	GLOBAL.trapsByPos.clear()
	GLOBAL.hiddenDoors.clear()
	GLOBAL.lockedDoors.clear()
	GLOBAL.testedDoors.clear()
	for i in range(GLOBAL.FLOOR_SIZE_X):
		Ref.currentLevel.searched.append([])
		for _j in range(GLOBAL.FLOOR_SIZE_Y):
			Ref.currentLevel.searched[i].append(false)
	for m in Ref.currentLevel.monsters.get_children():
		GLOBAL.monstersByPosition.erase(m.pos)
		m.free()
	for n in Ref.currentLevel.npcs.get_children():
		n.free()
	for c in Ref.currentLevel.chests.get_children():
		c.free()
	GLOBAL.chests.clear()
	for t in Ref.currentLevel.traps.get_children():
		t.free()
	GLOBAL.trapsByPos.clear()
	for l in Ref.currentLevel.loots.get_children():
		l.free()
	for i in GLOBAL.itemsOnFloor.keys():
		GLOBAL.items.erase(i)
	GLOBAL.itemsOnFloor.clear()

func testFloor():
	Ref.currentLevel.levelBuffer.flush()
	cleanFloor()
	dungeonGenerator.simpleFloor()
	Ref.currentLevel.initShadows()

func merchantFloor():
	Ref.currentLevel.levelBuffer.saveLevel()
	if Ref.currentLevel.levelBuffer.savedLevels.has("merchant"):
		Ref.currentLevel.levelBuffer.loadLevel("merchant")
	else:
		cleanFloor()
		var spawnPos = dungeonGenerator.newFloor(3)
		Ref.currentLevel.initShadows()
		Ref.currentLevel.placeCharacter(spawnPos)
		Ref.currentLevel.levelBuffer.currentLevel = "merchant"
		Ref.currentLevel.levelBuffer.saveLevel()

func newFloor():
	Ref.currentLevel.levelBuffer.flush()
	cleanFloor()
	var spawnPos: Vector2
	match Ref.currentLevel.currentBiome:
		Data.BIOME_DUNGEON:
			spawnPos = dungeonGenerator.dungeonFloor()
		Data.BIOME_CAVERN:
			spawnPos = dungeonGenerator.cavernFloor()
		_:
			spawnPos = dungeonGenerator.newFloor()
	Ref.currentLevel.initShadows()
	Ref.currentLevel.placeCharacter(spawnPos)
	for a in Ref.currentLevel.allies.get_children():
		var cell = Ref.character.getRandomCloseCell()
		if cell == null:
			a.die()
		a.setPosition(cell)
	for i in range(9):
		Ref.currentLevel.spawnMonster(i)
	for _i in range(randi() % 4):
		Ref.currentLevel.createChest()
	for _i in range(3 + (randi() % 4)):
		Ref.currentLevel.dropItem()

func _input(event):
	if event.is_pressed() and autoexplore:
		setAutoExplore(false)
	elif (event.is_action_pressed("autoexplore")):
		setAutoExplore(not autoexplore)
	for i in range(1, 10):
		if (event.is_action_released("shortcut" + String(i))):
			var item = Ref.character.shortcuts.getItem(i)
			if item != null:
				match Ref.character.shortcuts.shortcutsType[i]:
					GLOBAL.WP_TYPE:
						pass
					GLOBAL.PO_TYPE:
						Ref.character.quaffPotion(item)
					GLOBAL.SC_TYPE:
						spellHandler.castSpellAsync(GLOBAL.items[item][GLOBAL.IT_SPEC], item)
					GLOBAL.TH_TYPE:
						throwHandler.throwAsync(item)
					GLOBAL.SP_TYPE:
						spellHandler.castSpellAsync(item)
				return
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
	elif (event.is_action_released("search")):
		Ref.character.search()
	elif event.is_action_released("rest"):
		restHandler.askrForRest()
	elif (event.is_action_released("debug_new_floor")):
		Ref.character.setPosition(dungeonGenerator.newFloor())
	elif (event.is_action_released("save")):
		saveSystem.saveGame()
	elif (event.is_action_released("load")):
		saveSystem.loadGame(Ref.character.stats.charName)
	elif (event.is_action_released("no")):
		Ref.ui.askForContinue(self)
		var coroutineReturn = yield(Ref.ui, "coroutine_signal")
		if coroutineReturn:
			pass

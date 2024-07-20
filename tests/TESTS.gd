extends Node

onready var tests_move = get_node("TESTS_MOVE")
onready var tests_inventory = get_node("TESTS_INVENTORY")

signal tested
signal done

var TEST_SPEED = 0.05

const TEST_NAME = 0
const TEST_POS = 1
const TEST_INIT = 2
const TEST_INPUTS = 3

var spawnedItems: Array = []

func runAll():
	for c in get_children():
		if not c.toTest:
			continue
		prints("Testing collection", c.name)
		runCollection(c)
		yield(self, "done")
	get_tree().quit()

func runCollection(tester: Node):
	var time_start = Time.get_unix_time_from_system()
	for testId in tester.tests.keys():
		runTest(tester, testId)
		yield(self, "tested")
	var time_elapsed = Time.get_unix_time_from_system() - time_start
	prints("Tested", tester.tests.size(), "/", tester.tests.size(), "in", time_elapsed, "seconds")
	emit_signal("done")

func runTest(tester: Node, testId: int):
	Ref.game.testFloor()
	GLOBAL.items.empty()
	Ref.game.itemGenerator.id = -1
	spawnedItems = []
	var test = tester.tests[testId]
	prints('\t', "Testing", test[TEST_NAME], "...")
	GeneralEngine.isFaking = true
	yield(get_tree(), "idle_frame")
	Ref.character.init()
	Ref.currentLevel.placeCharacter(test[TEST_POS])
	yield(get_tree(), "idle_frame")
	for step in test[TEST_INIT]:
		if step.size() == 2:
			call(step[0], step[1])
		if step.size() == 3:
			call(step[0], step[1], step[2])
	yield(get_tree(), "idle_frame")
	for input in test[TEST_INPUTS]:
		yield(get_tree().create_timer(TEST_SPEED), "timeout")
		if input is Array:
			tester.call(input[0], testId, input[1])
		elif input.begins_with("assert"):
			tester.call(input, testId)
		elif input.begins_with("fake"):
			call(input, testId)
		else:
			var a = InputEventAction.new()
			a.action = input
			a.pressed = true
			Input.parse_input_event(a)
			yield(get_tree(), "idle_frame")
			a.pressed = false
			Input.parse_input_event(a)
			yield(get_tree(), "idle_frame")
	emit_signal("tested")

func fake_dice(value: int):
	GeneralEngine.fakedValue = value

func fake_low_dice(_testId: int):
	GeneralEngine.fakedValue = 1

func fake_high_dice(_testId: int):
	GeneralEngine.fakedValue = 6

func spawn_locked_door(pos: Vector2):
	Ref.currentLevel.dungeon.set_cellv(pos, GLOBAL.DOOR_ID, false, false, false, Vector2(0,1))
	GLOBAL.lockedDoors.append(pos)

func spawn_hidden_door(pos: Vector2):
	Ref.currentLevel.dungeon.set_cellv(pos, GLOBAL.WALL_ID)
	GLOBAL.hiddenDoors.append(pos)

func set_lockpicks(value: int):
	Ref.character.inventory.updateLockpicks(value)

func spawn_weapon(id: int, pos):
	var items = Ref.game.itemGenerator.getWeapon(id)
	if pos != null:
		for item in items:
			GLOBAL.dropItemOnFloor(item, pos)
	else:
		Ref.character.pickItem(items)
	spawnedItems.append_array(items)

func spawn_shield(id: int, pos):
	var items = Ref.game.itemGenerator.getShield(id)
	if pos != null:
		for item in items:
			GLOBAL.dropItemOnFloor(item, pos)
	else:
		Ref.character.pickItem(items)
	spawnedItems.append_array(items)

func spawn_armor(id: int, pos):
	var items = Ref.game.itemGenerator.getArmor(id)
	if pos != null:
		for item in items:
			GLOBAL.dropItemOnFloor(item, pos)
	else:
		Ref.character.pickItem(items)
	spawnedItems.append_array(items)

func spawn_talisman(id: int, pos):
	var items = Ref.game.itemGenerator.getTalisman(id)
	if pos != null:
		for item in items:
			GLOBAL.dropItemOnFloor(item, pos)
	else:
		Ref.character.pickItem(items)
	spawnedItems.append_array(items)

func spawn_potion(id: int, pos):
	var items = Ref.game.itemGenerator.getPotion(id)
	if pos != null:
		for item in items:
			GLOBAL.dropItemOnFloor(item, pos)
	else:
		Ref.character.pickItem(items)
	spawnedItems.append_array(items)

func spawn_scroll(id: int, pos):
	var items = Ref.game.itemGenerator.getScroll(id)
	if pos != null:
		for item in items:
			GLOBAL.dropItemOnFloor(item, pos)
	else:
		Ref.character.pickItem(items)
	spawnedItems.append_array(items)

func spawn_throwable(id: int, pos):
	var items = Ref.game.itemGenerator.getThrowable(id)
	if pos != null:
		for item in items:
			GLOBAL.dropItemOnFloor(item, pos)
	else:
		Ref.character.pickItem(items)
	spawnedItems.append_array(items)

func spawn_lockpicks(pos: Vector2, count: int):
	var items = Ref.game.itemGenerator.generateLockpicks(count)
	for item in items:
		GLOBAL.dropItemOnFloor(item, pos)

func spawn_golds(pos: Vector2, count: int):
	var items = Ref.game.itemGenerator.generateGolds(0, count)
	for item in items:
		GLOBAL.dropItemOnFloor(item, pos)

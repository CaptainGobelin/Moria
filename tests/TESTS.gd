extends Node

onready var tests_move = get_node("TESTS_MOVE")
onready var tests_inventory = get_node("TESTS_INVENTORY")

signal tested
signal done

var TEST_SPEED = 0.1

const TEST_NAME = 0
const TEST_POS = 1
const TEST_INIT = 2
const TEST_INPUTS = 3

func runAll():
#	prints("Testing collection MOVE")
#	runCollection(tests_move)
#	yield(self, "done")
	prints("Testing collection INVENTORY")
	runCollection(tests_inventory)
	yield(self, "done")
	#get_tree().quit()

func runCollection(tester: Node):
	for testId in tester.tests.keys():
		runTest(tester, testId)
		yield(self, "tested")
	prints("Tested", tester.tests.size(), "/", tester.tests.size())
	emit_signal("done")

func runTest(tester: Node, testId: int):
	Ref.game.testFloor()
	var test = tester.tests[testId]
	prints('\t', "Testing", test[TEST_NAME], "...")
	GeneralEngine.isFaking = true
	yield(get_tree(), "idle_frame")
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
		if input.begins_with("assert"):
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
	if pos != null:
		for item in Ref.game.itemGenerator.getWeapon(id):
			GLOBAL.dropItemOnFloor(item, pos)
	else:
		Ref.character.pickItem(Ref.game.itemGenerator.getWeapon(id))

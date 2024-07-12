extends Node

onready var tests_move = get_node("TESTS_MOVE")

signal tested

var TEST_SPEED = 0.1

const TEST_NAME = 0
const TEST_POS = 1
const TEST_INIT = 2
const TEST_INPUTS = 3
const TEST_NEXT = 4

func runAll():
	runTest(tests_move, 0)
	yield(self, "tested")
	get_tree().quit()

func runTest(tester: Node, testId: int):
	Ref.game.testFloor()
	var test = tester.tests[testId]
	GeneralEngine.isFaking = true
	yield(get_tree(), "idle_frame")
	Ref.currentLevel.placeCharacter(test[TEST_POS])
	yield(get_tree(), "idle_frame")
	for step in test[TEST_INIT]:
		call(step[0], step[1])
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
	if test[TEST_NEXT] != null:
		runTest(tester, test[TEST_NEXT])
	else:
		emit_signal("tested")

func fake_dice(value: int):
	GeneralEngine.fakedValue = value

func fake_low_dice(testId: int):
	GeneralEngine.fakedValue = 1

func fake_high_dice(testId: int):
	GeneralEngine.fakedValue = 6

func spawn_locked_door(pos: Vector2):
	Ref.currentLevel.dungeon.set_cellv(pos, GLOBAL.DOOR_ID, false, false, false, Vector2(0,1))
	GLOBAL.lockedDoors.append(pos)

func spawn_hidden_door(pos: Vector2):
	Ref.currentLevel.dungeon.set_cellv(pos, GLOBAL.WALL_ID)
	GLOBAL.hiddenDoors.append(pos)

func set_lockpicks(value: int):
	Ref.character.inventory.updateLockpicks(value)

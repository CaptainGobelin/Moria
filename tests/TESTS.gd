extends Node

const TEST_POS = 0
const TEST_INPUTS = 1
const TEST_NEXT = 2

const tests = {
	0: [
		Vector2(10, 10),
		["ui_left", "ui_down", "ui_right", "ui_up", "assert_no_move"],
		1
	],
	1: [
		Vector2(3, 3),
		["ui_left", "assert_no_move", 
		"ui_down", "assert_no_move", 
		"ui_right", "assert_no_move",
		"ui_up", "assert_no_move"],
		null
	],
}

func loadTest(testId):
	GeneralEngine.isFaking = true
	yield(get_tree(), "idle_frame")
	var test = tests[testId]
	Ref.currentLevel.placeCharacter(test[TEST_POS])
	yield(get_tree(), "idle_frame")
	for input in test[TEST_INPUTS]:
		if (input.begins_with("assert")):
			call(input, testId)
		else:
			yield(get_tree().create_timer(0.1), "timeout")
			var a = InputEventAction.new()
			a.action = input
			a.pressed = true
			Input.parse_input_event(a)
			yield(get_tree(), "idle_frame")
	if test[TEST_NEXT] != null:
		loadTest(test[TEST_NEXT])
	else:
		get_tree().quit()

func assert_no_move(testId):
	assert(Ref.character.pos == tests[testId][TEST_POS])

extends Node

const tests = {
	0: [
		"Move",
		Vector2(10, 10),
		[
			["spawn_weapon", 0, null],
		],
		["ui_left", "ui_down", "ui_right", "ui_up", "assert_no_move"]
	],
}

func assert_no_move(testId: int):
	assert(Ref.character.pos == tests[testId][get_parent().TEST_POS])

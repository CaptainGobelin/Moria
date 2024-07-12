extends Node

var TEST_SPEED = 0.1

const TES_NAME = 0
const TEST_POS = 1
const TEST_INIT = 2
const TEST_INPUTS = 3
const TEST_NEXT = 4

const tests = {
	0: [
		"Move",
		Vector2(10, 10),
		[],
		["ui_left", "ui_down", "ui_right", "ui_up", "assert_no_move"],
		1
	],
	1: [
		"Move against wall",
		Vector2(3, 3),
		[],
		["ui_left", "assert_no_move", 
		"ui_down", "assert_no_move", 
		"ui_right", "assert_no_move",
		"ui_up", "assert_no_move"],
		2
	],
	2: [
		"Open a door",
		Vector2(3, 5),
		[],
		["ui_right", "assert_no_move",
		"ui_right", "assert_move_right"],
		3
	],
	3: [
		"Move against a locked door",
		Vector2(10, 10),
		[
			["spawn_locked_door", Vector2(11,10)],
			["set_lockpicks", 0]
		],
		["ui_right", "assert_no_move"],
		4
	],
	4: [
		"Fail unlocking a door",
		Vector2(10, 10),
		[
			["spawn_locked_door", Vector2(11,10)],
			["set_lockpicks", 1],
			["fake_dice", 1],
		],
		["ui_right", "yes", "assert_no_move", "assert_no_lockpicks",
		"ui_right", "assert_no_move"],
		5
	],
	5: [
		"Unlock a locked door",
		Vector2(10, 10),
		[
			["spawn_locked_door", Vector2(11,10)],
			["set_lockpicks", 1],
			["fake_dice", 6],
		],
		["ui_right", "yes", "assert_no_move", "assert_one_lockpicks",
		"ui_right", "assert_move_right", "assert_no_locked_door"],
		6
	],
	6: [
		"Automatically discover a hidden door",
		Vector2(10, 12),
		[
			["spawn_hidden_door", Vector2(10,3)],
			["fake_dice", 6],
		],
		["ui_up", "ui_up", "ui_up", "ui_up", "assert_one_hidden_door",
		"ui_up", "assert_no_hidden_door"],
		7
	],
	7: [
		"Manually discover a hidden door",
		Vector2(10, 12),
		[
			["spawn_hidden_door", Vector2(10,3)],
			["fake_dice", 1],
		],
		["ui_up", "ui_up", "ui_up", "ui_up",
		"ui_up", "assert_one_hidden_door", "search",
		"fake_high_dice", "search", "assert_no_hidden_door"],
		8
	],
	8: [
		"Move against a hidden door",
		Vector2(10, 12),
		[
			["spawn_hidden_door", Vector2(10,11)],
			["fake_dice", 1],
		],
		["search", "assert_one_hidden_door", "ui_up", "assert_no_move"],
		9
	],
	9: [
		"Move against a hidden  locked door",
		Vector2(10, 12),
		[
			["spawn_hidden_door", Vector2(10,11)],
			["set_lockpicks", 1],
			["fake_dice", 1],
		],
		["search", "assert_one_hidden_door", "ui_up", "assert_no_move"],
		null
	],
}

func assert_no_move(testId: int):
	assert(Ref.character.pos == tests[testId][TEST_POS])

func assert_move_right(testId: int):
	assert(Ref.character.pos.x == tests[testId][TEST_POS].x+1)
	assert(Ref.character.pos.y == tests[testId][TEST_POS].y)

# warning-ignore:unused_argument
func assert_no_lockpicks(testId: int):
	assert(Ref.character.inventory.lockpicks == 0)

# warning-ignore:unused_argument
func assert_one_lockpicks(testId: int):
	assert(Ref.character.inventory.lockpicks == 1)

# warning-ignore:unused_argument
func assert_no_locked_door(testId: int):
	assert(GLOBAL.lockedDoors.empty())

# warning-ignore:unused_argument
func assert_no_hidden_door(testId: int):
	assert(GLOBAL.hiddenDoors.empty())

# warning-ignore:unused_argument
func assert_one_hidden_door(testId: int):
	assert(GLOBAL.hiddenDoors.size() == 1)

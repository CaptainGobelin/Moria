extends Node

export var toTest = true

const tests = {
	0: [
		"Move",
		Vector2(10, 10),
		[],
		["ui_left", "ui_down", "ui_right", "ui_up", "assert_no_move"]
	],
	1: [
		"Move against wall",
		Vector2(3, 3),
		[],
		["ui_left", "assert_no_move", 
		"ui_down", "assert_no_move", 
		"ui_right", "assert_no_move",
		"ui_up", "assert_no_move"]
	],
	2: [
		"Open a door",
		Vector2(3, 5),
		[],
		["ui_right", "assert_no_move",
		"ui_right", "assert_move_right"]
	],
	3: [
		"Move against a locked door",
		Vector2(10, 10),
		[
			["spawn_locked_door", Vector2(11,10)],
			["set_lockpicks", 0]
		],
		["ui_right", "assert_no_move"]
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
		"ui_right", "assert_no_move"]
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
		"ui_right", "assert_move_right", "assert_no_locked_door"]
	],
	6: [
		"Automatically discover a hidden door",
		Vector2(10, 12),
		[
			["spawn_hidden_door", Vector2(10,3)],
			["fake_dice", 6],
		],
		["ui_up", "ui_up", "ui_up", "ui_up", "assert_one_hidden_door",
		"ui_up", "assert_no_hidden_door"]
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
		"fake_high_dice", "search", "assert_no_hidden_door"]
	],
	8: [
		"Move against a hidden door",
		Vector2(10, 12),
		[
			["spawn_hidden_door", Vector2(10,11)],
			["fake_dice", 1],
		],
		["search", "assert_one_hidden_door", "ui_up", "assert_no_move"]
	],
	9: [
		"Move against a hidden locked door",
		Vector2(10, 12),
		[
			["spawn_hidden_door", Vector2(10,11)],
			["set_lockpicks", 1],
			["fake_dice", 1],
		],
		["search", "assert_one_hidden_door", "ui_up", "assert_no_move"]
	],
	10: [
		"Automatically discover trap",
		Vector2(10, 12),
		[
			["spawn_trap", 0, Vector2(10, 3)],
			["fake_dice", 6],
		],
		[["assert_trap_hidden", Vector2(10, 3)], "ui_up",
		"ui_up", "ui_up", "ui_up", "ui_up", "ui_up", "ui_up", "ui_up",
		["assert_trap_revealed", Vector2(10, 3)],
		"fake_last_printed", "ui_up", ["assert_last_printed", ""]]
	],
	11: [
		"Manually discover trap",
		Vector2(10, 12),
		[
			["spawn_trap", 0, Vector2(10, 3)],
			["fake_dice", 1],
		],
		["ui_up", "ui_up", "ui_up", "ui_up", "ui_up", "ui_up", "ui_up", "ui_up",
		["assert_trap_hidden", Vector2(10, 3)], "search",
		["assert_trap_hidden", Vector2(10, 3)], "fake_high_dice",
		"search", ["assert_last_printed", "writeHiddenTrapDetected"],
		["assert_trap_revealed", Vector2(10, 3)],
		"fake_last_printed", "ui_up", ["assert_last_printed", ""],
		["assert_trap_revealed", Vector2(10, 3)]]
	],
	12: [
		"Trigger trap",
		Vector2(10, 12),
		[
			["spawn_trap", 0, Vector2(10, 3)],
			["fake_dice", 1],
		],
		["ui_up", "ui_up", "ui_up", "ui_up", "ui_up", "ui_up", "ui_up", "ui_up",
		["assert_trap_hidden", Vector2(10, 3)], "ui_up",
		["assert_last_printed", "writeCharacterTakeHit"],
		["assert_no_trap", Vector2(10, 3)]]
	],
	13: [
		"Attack contact creature",
		Vector2(10, 12),
		[
			["spawn_monster", Data.MO_DUMMY, Vector2(10, 9)],
			["fake_dice", 6],
		],
		["ui_up", "ui_up",
		["assert_last_printed", "writeCharacterTakeHit"],
		"fake_last_printed", "search",
		["assert_last_printed", "writeCharacterTakeHit"],
		"ui_up"]
	],
	14: [
		"Awake creature",
		Vector2(10, 12),
		[
			["spawn_monster", Data.MO_DUMMY, Vector2(10, 3)],
			["fake_dice", 6],
		],
		[["assert_creature_sleep", Vector2(10, 3)],
		"ui_up", "ui_up", "ui_up", "ui_up",
		["assert_creature_awake", Vector2(10, 3)]]
	],
}

func assert_last_printed(testId: int, msg: String):
	assert(Ref.ui.lastPrinted == msg)

func assert_no_move(testId: int):
	assert(Ref.character.pos == tests[testId][get_parent().TEST_POS])

func assert_move_right(testId: int):
	assert(Ref.character.pos.x == tests[testId][get_parent().TEST_POS].x+1)
	assert(Ref.character.pos.y == tests[testId][get_parent().TEST_POS].y)

func assert_no_lockpicks(testId: int):
	assert(Ref.character.inventory.lockpicks == 0)

func assert_one_lockpicks(testId: int):
	assert(Ref.character.inventory.lockpicks == 1)

func assert_no_locked_door(testId: int):
	assert(GLOBAL.lockedDoors.empty())

func assert_no_hidden_door(testId: int):
	assert(GLOBAL.hiddenDoors.empty())

func assert_one_hidden_door(testId: int):
	assert(GLOBAL.hiddenDoors.size() == 1)

func assert_trap_hidden(testId: int, pos: Vector2):
	assert(GLOBAL.getTrapByPos(pos).hidden)

func assert_no_trap(testId: int, pos: Vector2):
	assert(!GLOBAL.trapsByPos.has(pos))

func assert_trap_revealed(testId: int, pos: Vector2):
	assert(!GLOBAL.getTrapByPos(pos).hidden)

func assert_creature_sleep(testId: int, pos: Vector2):
	assert(GLOBAL.getMonsterByPos(pos).status == "sleep")

func assert_creature_awake(testId: int, pos: Vector2):
	assert(GLOBAL.getMonsterByPos(pos).status == "awake")

extends Node

export var toTest = true

var tests = {
}

func init():
	var count = 0
	for s in Data.spells.keys():
		var spell = Data.spells[s]
		if spell[Data.SP_SCHOOL] != null:
			Ref.character.spells.learnSpell(s)
			tests[s] = []
			tests[s].append("Cast " + spell[Data.SP_NAME])
			tests[s].append(Vector2(10, 10))
			var conditions = []
			conditions.append(["fake_dice", 1])
			match spell[Data.SP_TARGET]:
				Data.SP_TARGET_TARGET:
					conditions.append(["spawn_monster", Data.MO_DUMMY, Vector2(10, 5)])
			tests[s].append(conditions)
			var instructions = []
			instructions.append("assert_normal_mode")
			instructions.append("search")
			instructions.append("spellMenu")
			for _i in range(count):
				instructions.append("ui_down")
			instructions.append("ui_accept")
			match spell[Data.SP_TARGET]:
				Data.SP_TARGET_TARGET:
					instructions.append("assert_target_mode")
					instructions.append("ui_accept")
				Data.SP_TARGET_DIRECT:
					instructions.append("assert_direct_mode")
					instructions.append("ui_up")
				Data.SP_TARGET_ITEM_CHOICE:
					instructions.append("assert_choice_mode")
					instructions.append("shortcut1")
			instructions.append("assert_test_statuses")
			instructions.append("wait")
			tests[s].append(instructions)
			count += 1

func assert_test_statuses(testId: int):
	Utils.printDict(GLOBAL.statuses)

func assert_choice_mode(testId: int):
	assert(GLOBAL.currentMode == GLOBAL.MODE_CHOICE)

func assert_number_mode(testId: int):
	assert(GLOBAL.currentMode == GLOBAL.MODE_NUMBER)

func assert_target_mode(testId: int):
	assert(GLOBAL.currentMode == GLOBAL.MODE_TARGET)

func assert_direct_mode(testId: int):
	assert(GLOBAL.currentMode == GLOBAL.MODE_DIRECT)

func assert_normal_mode(testId: int):
	assert(GLOBAL.currentMode == GLOBAL.MODE_NORMAL)

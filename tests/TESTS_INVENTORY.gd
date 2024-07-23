extends Node

export var toTest = true

const tests = {
	0: [
		"Pickup single item",
		Vector2(10, 10),
		[
			["spawn_weapon", 0, Vector2(11, 10)],
		],
		[["assert_one_loot", Vector2(11, 10)], "ui_right", "pickLoot",
		"assert_last_printed_pickup", ["assert_no_loot", Vector2(11, 10)],
		["assert_weapon_in_bag", 0]]
	],
	1: [
		"Pickup pile of single item",
		Vector2(10, 10),
		[
			["spawn_weapon", 0, Vector2(11, 10)],
			["spawn_weapon", 0, Vector2(11, 10)],
		],
		["ui_right", "pickLoot", "assert_choice_mode", "shortcut0",
		"assert_choice_mode", "shortcut3", "assert_choice_mode", "ui_cancel",
		"assert_normal_mode", ["assert_two_loots", Vector2(11, 10)],
		"pickLoot", "shortcut2", "assert_normal_mode", ["assert_weapon_in_bag", 1],
		["assert_one_loot", Vector2(11, 10)], "pickLoot",
		"assert_last_printed_pickup", ["assert_no_loot", Vector2(11, 10)],
		"assert_normal_mode", ["assert_weapon_in_bag", 0]]
	],
	2: [
		"Pickup stack of items",
		Vector2(10, 10),
		[
			["spawn_potion", 0, Vector2(11, 10)],
			["spawn_potion", 0, Vector2(11, 10)],
			["spawn_potion", 0, Vector2(11, 10)],
			["spawn_potion", 0, Vector2(11, 10)],
			["spawn_potion", 0, Vector2(11, 10)],
		],
		["ui_right", "pickLoot", "assert_number_mode", "shortcut0", "ui_accept",
		["assert_potions_in_bag", 0], "pickLoot", "shortcut3", "ui_accept",
		["assert_potions_in_bag", 3], "pickLoot", "shortcut2", "ui_accept",
		["assert_potions_in_bag", 5], ["assert_no_loot", Vector2(11, 10)]]
	],
	3: [
		"Item categories",
		Vector2(10, 10),
		[
			["spawn_weapon", 0, null],
			["spawn_shield", 0, null],
			["spawn_armor", 0, null],
			["spawn_armor", 10, null],
			["spawn_talisman", 0, null],
			["spawn_potion", 0, null],
			["spawn_scroll", 0, null],
			["spawn_throwable", 0, null],
		],
		[
			"inventory", ["assert_item_in_item_list", 0], ["assert_item_in_item_list", 1],
			"ui_right", ["assert_item_in_item_list", 2], ["assert_item_in_item_list", 3],
			"ui_right", ["assert_stackable_in_item_list", 6],
			"ui_right", ["assert_stackable_in_item_list", 5],
			"ui_right", ["assert_stackable_in_item_list", 7],
			"ui_right", ["assert_item_in_item_list", 4], "ui_right", "ui_cancel"
		]
	],
	4: [
		"Inventory scrolling",
		Vector2(10, 10),
		[
			["spawn_weapon", 0, null],
			["spawn_weapon", 0, null],
			["spawn_weapon", 0, null],
			["spawn_weapon", 0, null],
			["spawn_weapon", 0, null],
			["spawn_weapon", 0, null],
			["spawn_weapon", 0, null],
		],
		["inventory", ["assert_inventory_tab_size", 7],
		["assert_selected_item_index", 0], "ui_up", 
		["assert_selected_item_index", 5], "ui_down",
		["assert_selected_item_index", 0], "ui_down",
		["assert_selected_item_index", 1], "ui_cancel"]
	],
	5: [
		"Pickup lockpicks",
		Vector2(10, 10),
		[
			["spawn_lockpicks", Vector2(11, 10), 2],
			["spawn_lockpicks", Vector2(11, 10), 3],
		],
		["ui_right", "pickLoot", "assert_five_lockpicks", ["assert_no_loot", Vector2(11, 10)]]
	],
	6: [
		"Pickup golds",
		Vector2(10, 10),
		[
			["spawn_golds", Vector2(11, 10), 2],
			["spawn_golds", Vector2(11, 10), 3],
		],
		["ui_right", "pickLoot", "assert_five_golds", ["assert_no_loot", Vector2(11, 10)]]
	],
	7: [
		"Drop single item",
		Vector2(10, 10),
		[

		],
		[]
	],
	8: [
		"Drop stackable items",
		Vector2(10, 10),
		[

		],
		[]
	],
	9: [
		"Wear weapon",
		Vector2(10, 10),
		[

		],
		[]
	],
	10: [
		"Wear armor",
		Vector2(10, 10),
		[

		],
		[]
	],
	11: [
		"Wear talisman",
		Vector2(10, 10),
		[

		],
		[]
	],
	12: [
		"Quaff potion",
		Vector2(10, 10),
		[
			["spawn_potion", 0, Vector2(11, 10)],
		],
		[
			"inventory", "ui_right", "ui_right", "ui_right", "quaffPotion",
			"assert_last_printed_null", "assert_inventory_mode", "ui_cancel",
			"ui_right", "pickLoot", "inventory", "quaffPotion",
			"assert_last_printed_quaffed", "ui_cancel"
		]
	],
	13: [
		"Read scroll",
		Vector2(10, 10),
		[
			["spawn_scroll", 0, Vector2(11, 10)],
			["spawn_monster", 1000, Vector2(11, 6)],
		],
		[
			"inventory", "ui_right", "ui_right", "readScroll",
			"assert_last_printed_null", "assert_inventory_mode", "ui_cancel",
			"ui_right", "pickLoot", "inventory", "readScroll",
			"assert_target_mode", "ui_cancel"
		]
	],
	14: [
		"Throw item",
		Vector2(10, 10),
		[
			["spawn_throwable", 0, Vector2(11, 10)],
			["spawn_monster", 1000, Vector2(11, 6)],
		],
		[
			"inventory", "ui_right", "ui_right", "ui_right", "ui_right", "throw",
			"assert_last_printed_null", "assert_inventory_mode", "ui_cancel",
			"ui_right", "pickLoot", "inventory", "throw",
			"assert_target_mode", "ui_cancel"
		]
	],
}
func assert_choice_mode(testId: int):
	assert(GLOBAL.currentMode == GLOBAL.MODE_CHOICE)

func assert_number_mode(testId: int):
	assert(GLOBAL.currentMode == GLOBAL.MODE_NUMBER)

func assert_target_mode(testId: int):
	assert(GLOBAL.currentMode == GLOBAL.MODE_TARGET)

func assert_normal_mode(testId: int):
	assert(GLOBAL.currentMode == GLOBAL.MODE_NORMAL)

func assert_inventory_mode(testId: int):
	assert(GLOBAL.currentMode == GLOBAL.MODE_INVENTORY)

func assert_no_move(testId: int):
	assert(Ref.character.pos == tests[testId][get_parent().TEST_POS])

func assert_last_printed_pickup(testId: int):
	assert(Ref.ui.lastPrinted == "writePickupLoot")

func assert_last_printed_quaffed(testId: int):
	assert(Ref.ui.lastPrinted == "writeQuaffedPotion")

func assert_last_printed_null(testId: int):
	assert(Ref.ui.lastPrinted == "")

func assert_selected_item_index(testId: int, index: int):
	assert(Ref.game.inventoryMenu.itemList.currentIndex == index)

func assert_no_loot(testId: int, cell: Vector2):
	assert(not GLOBAL.itemsOnFloor.has(cell))

func assert_one_loot(testId: int, cell: Vector2):
	assert(GLOBAL.itemsOnFloor[cell][GLOBAL.FLOOR_IDS].size() == 1)

func assert_two_loots(testId: int, cell: Vector2):
	assert(GLOBAL.itemsOnFloor[cell][GLOBAL.FLOOR_IDS].size() == 2)

func assert_weapon_in_bag(testId: int, id: int):
	assert(Ref.character.inventory.weapons.has(get_parent().spawnedItems[id]))

func assert_potions_in_bag(testId: int, count: int):
	assert(Ref.character.inventory.potions.size() == count)

func assert_inventory_tab_size(testId: int, size: int):
	assert(Ref.game.inventoryMenu.itemList.currentItems.size() == size)

func assert_five_lockpicks(testId: int):
	assert(Ref.character.inventory.lockpicks == 5)

func assert_five_golds(testId: int):
	assert(Ref.character.inventory.golds == 5)

func assert_item_in_item_list(testId:int, id: int):
	var result = false
	for item in Ref.game.inventoryMenu.itemList.currentItems:
		if item[1] == id:
			result = true
	assert(result)

func assert_stackable_in_item_list(testId:int, id: int):
	var result = false
	for item in Ref.game.inventoryMenu.itemList.currentItems:
		if item[4][0] == id:
			result = true
	assert(result)

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
		"pickLoot", "shortcut2", "assert_normal_mode", ["assert_weapon_in_bag", 2],
		["assert_one_loot", Vector2(11, 10)], "pickLoot",
		"assert_last_printed_pickup", ["assert_no_loot", Vector2(11, 10)],
		"assert_normal_mode", ["assert_weapon_in_bag", 1]]
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
		["assert_potions_in_bag", 0]]
	],
	3: [
		"Item gategories",
		Vector2(10, 10),
		[
			
		],
		[]
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
		["assert_selected_item_index", 6], "ui_down",
		["assert_selected_item_index", 0], "ui_down",
		["assert_selected_item_index", 0], "ui_cancel"]
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
		"Wear armour",
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
}
func assert_choice_mode(testId: int):
	assert(GLOBAL.currentMode == GLOBAL.MODE_CHOICE)

func assert_number_mode(testId: int):
	assert(GLOBAL.currentMode == GLOBAL.MODE_NUMBER)

func assert_normal_mode(testId: int):
	assert(GLOBAL.currentMode == GLOBAL.MODE_NORMAL)

func assert_no_move(testId: int):
	assert(Ref.character.pos == tests[testId][get_parent().TEST_POS])

func assert_last_printed_pickup(testId: int):
	assert(Ref.ui.lastPrinted == "writePickupLoot")

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
	assert(Ref.character.inventory.potions.count() == count)

func assert_inventory_tab_size(testId: int, size: int):
	assert(Ref.game.inventoryMenu.itemList.currentItems.size() == size)

func assert_five_lockpicks(testId: int):
	assert(Ref.character.inventory.lockpicks == 5)

func assert_five_golds(testId: int):
	assert(Ref.character.inventory.golds == 5)

extends Node

onready var lootScene = preload("res://scenes/Loot.tscn")

# Game modes
const MODE_NONE = 0
const MODE_NORMAL = 1
const MODE_TARGET = 10
const MODE_CHOICE = 11
const MODE_YESNO = 12
const MODE_NUMBER = 13
const MODE_INVENTORY = 20
const MODE_SPELL = 21
const MODE_CHEST = 30

var currentMode: int = MODE_NONE

# Dungeon
const FLOOR_SIZE_X = 37
const FLOOR_SIZE_Y = 19
const FULLNESS_THRESHOLD = 0.44
const DOOR_REDUCTION_RATIO = 0.25
const HIDDEN_DOORS_RATIO = 0.16
const LOCKED_DOORS_RATIO = 0.2
const TRAPPED_ROOMS_RATIO = 0.2
const TRAPS_PER_ROOM = 3
const LOOTS_PER_TREASURE = 4

# Cells
const WALL_ID = 1
const DOOR_ID = 2
const PILLAR_ID = 3
const FLOOR_ID = 4
const GRID_ID = 5
const PASS_ID = 6

# Character
const VIEW_RANGE = 8
const CHAR_SKILLS = 0
const CHAR_FEATS = 1
const CHAR_STATUSES = 2
const CHAR_RESTS = 2

# Inventory
const INV_WEAPONS = 0
const INV_ARMORS = 1
const INV_SCROLLS = 2
const INV_POTIONS = 3
const INV_THROWINGS = 4
const INV_TALSMANS = 5

# Items
const WP_TYPE = 0
const AR_TYPE = 1
const PO_TYPE = 2
const TA_TYPE = 3
const TH_TYPE = 4
const SC_TYPE = 5
const LO_TYPE = 6
const GO_TYPE = 7
const SP_TYPE = 8

const IT_TYPE = 0
const IT_NAME = 1
const IT_ICON = 2
const IT_DMG = 3
const IT_HIT = 4
# 2H is true for 2 handed weapon of helmets
const IT_2H = 5
const IT_CA = 6
const IT_PROT = 7
# Special is enchants, talisman effect, scroll spell, quantity or potion effect
const IT_SPEC = 8
# Skill is for weapon and armor to see if you can use it
const IT_SKILL = 9
const IT_BASE = 10
const IT_STACK = 11
var items: Dictionary = {}

# Index is pos content is a list of item ID
const FLOOR_IDS = 0
const FLOOR_INST = 1
const FLOOR_EXP = 2
var itemsOnFloor: Dictionary = {}

func getItemList(cell: Vector2) -> Dictionary:
	if !itemsOnFloor.has(cell):
		return {}
	var result = {}
	for idx in itemsOnFloor[cell][FLOOR_IDS]:
		var stackId = items[idx][IT_STACK]
		if stackId == null:
			stackId = 10000 + idx
		if result.has(stackId):
			result[stackId].append(idx)
		else:
			result[stackId] = [idx]
	return result

func dropItemOnFloor(idx: int, cell: Vector2):
	if itemsOnFloor.has(cell):
		if items[idx][IT_TYPE] == LO_TYPE or items[idx][IT_TYPE] == GO_TYPE:
			for i in itemsOnFloor[cell][0]:
				if items[i][IT_TYPE] == items[idx][IT_TYPE]:
					items[i][IT_SPEC] += items[idx][IT_SPEC]
					return
		itemsOnFloor[cell][FLOOR_IDS].append(idx)
	else:
		var loot = lootScene.instance()
		Ref.currentLevel.loots.add_child(loot)
		loot.init(idx, cell)
		itemsOnFloor[cell] = [[idx], loot.get_instance_id(), false]

func removeItemFromFloor(idx: int):
	for cell in itemsOnFloor.keys():
		if itemsOnFloor[cell][FLOOR_IDS].has(idx):
			itemsOnFloor[cell][FLOOR_IDS].erase(idx)
			if itemsOnFloor[cell][FLOOR_IDS].size() == 0:
				var scene = instance_from_id(itemsOnFloor[cell][FLOOR_INST])
				scene.queue_free()
				itemsOnFloor.erase(cell)
				break

# Chests
const CH_POS = 0
const CH_CONTENT = 1
const CH_OPENED = 2
const CH_LOCKED = 3
var chests: Dictionary = {}

func getChestByPos(cell: Vector2):
	for chest in chests.values():
		if chest[CH_POS] == cell:
			return chest
	return null

# Statuses
const ST_NAME = 0
const ST_ICON = 1
const ST_TURNS = 2
const ST_TIMING = 3
const TIMING_TIMER = 0
const TIMING_FLOOR = 1
const TIMING_REST = 2
const TIMING_UNDEF = 3
const ST_TYPE = 4
const ST_RANK = 5
const ST_ID = 6
const ST_HIDDEN = 7
var statuses: Dictionary = {}

# Traps
var trapsByPos: Dictionary = {}

func getTrapByPos(cell: Vector2) -> Trap:
	return instance_from_id(trapsByPos[cell]) as Trap

# Doors
var hiddenDoors: Array = []
var lockedDoors: Array = []
var testedDoors: Array = []

func testDoor(pos: Vector2):
	if testedDoors.has(pos):
		return
	testedDoors.append(pos)
	Ref.game.pathfinder.dijkstraCompute()

# Monsters
var targets: Dictionary = {}

var monstersByPosition: Dictionary = {}

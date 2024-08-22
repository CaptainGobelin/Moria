extends Node

onready var game = get_parent().get_parent()
onready var normalBiome = get_node("NormalBiome")
onready var cavernBiome = get_node("CavernBiome")
onready var dungeon: TileMap

export (int, "Normal, Cavern, Arena") var biome = 0

# Door: [position:Vector2, direction:String]
var waitingDoors:Array = []
var validatedDoors:Array = []
var array:Array = []
var arrayFullness = 0
var trapList: Dictionary = {}

func _ready():
	set_process_input(false)

func _input(event):
	if event.is_action_released("ui_accept"):
		newFloor()

func newFloor():
	Ref.game.cleanFloor()
	match biome:
		0:
			return normalBiome.newFloor()
		1:
			return cavernBiome.newFloor()
		2:
			return simpleFloor()

func simpleFloor():
	for i in range(GLOBAL.FLOOR_SIZE_X):
		array.append([])
		for j in range(GLOBAL.FLOOR_SIZE_Y):
			if i < 3 or i > GLOBAL.FLOOR_SIZE_X - 4:
				array[i].append(GLOBAL.WALL_ID)
			elif j < 3 or j > GLOBAL.FLOOR_SIZE_Y - 4:
				array[i].append(GLOBAL.WALL_ID)
			else:
				array[i].append(GLOBAL.FLOOR_ID)
	array[4][3] = GLOBAL.WALL_ID
	array[4][4] = GLOBAL.WALL_ID
	array[4][5] = GLOBAL.DOOR_ID
	array[4][6] = GLOBAL.WALL_ID
	array[3][4] = GLOBAL.WALL_ID
	array[3][6] = GLOBAL.WALL_ID
	drawFloor(array)
	return Vector2(int(GLOBAL.FLOOR_SIZE_X/2), int(GLOBAL.FLOOR_SIZE_Y/2))

func drawFloor(array: Array):
	dungeon = Ref.currentLevel.dungeon as TileMap
	dungeon.clear()
	for i in range(GLOBAL.FLOOR_SIZE_X):
		for j in range(GLOBAL.FLOOR_SIZE_Y):
			if array[i][j] == -1:
				dungeon.set_cell(i, j, 1)
			else:
				dungeon.set_cell(i, j, array[i][j])
	dungeon.update_bitmask_region()
	for cell in dungeon.get_used_cells_by_id(GLOBAL.DOOR_ID):
		dungeon.set_cellv(cell, GLOBAL.DOOR_ID, false, false, false, Vector2(0,1))

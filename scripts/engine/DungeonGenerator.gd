extends Node

onready var game = get_parent().get_parent()
onready var analyzer = get_node("GeneratorAnalyzer")
onready var encounterHandler = get_node("EncounterHandler")
onready var normalBiome = get_node("NormalBiome")
onready var cavernBiome = get_node("CavernBiome")
onready var merchantRoom = get_node("MerchantRoom")
onready var trollRoom = get_node("TrollRoom")
onready var dungeon: TileMap

export (int, "Normal, Cavern, Arena, Merchant, Debug, Troll") var biome = 0

var textures = [
	"res://sprites/walls.png",
	"res://sprites/walls-cavern.png"
]

# Door: [position:Vector2, direction:String]
var waitingDoors:Array = []
var validatedDoors:Array = []
var array:Array = []
var enemyCells: Array = []
var arrayFullness = 0
var trapList: Dictionary = {}
var retries: int = 0
var startCell: Vector2

func _ready():
	set_process_input(false)

func _input(event):
	if event.is_action_released("ui_accept"):
		newFloor()

func dungeonFloor():
	return newFloor(0)

func cavernFloor():
	return newFloor(1)

func newFloor(specialBiome = biome):
	Ref.game.cleanFloor()
	match specialBiome:
		0:
			changeTilesetTexture(0)
			return normalBiome.newFloor()
		1:
			changeTilesetTexture(1)
#			changeTilesetTexture(1)
			return cavernBiome.newFloor()
		2:
			return simpleFloor()
		3:
			return merchantRoom.newFloor()
		4:
			var result = simpleFloor()
			loadAllItems()
			return result
		5:
			changeTilesetTexture(1)
			return trollRoom.newFloor()

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
	array[25][9] = GLOBAL.WALL_ID
	array[25][10] = GLOBAL.WALL_ID
	array[25][11] = GLOBAL.WALL_ID
	array[27][9] = GLOBAL.WALL_ID
	array[27][10] = GLOBAL.WALL_ID
	array[27][11] = GLOBAL.WALL_ID
	startCell = Vector2(int(GLOBAL.FLOOR_SIZE_X/2), int(GLOBAL.FLOOR_SIZE_Y/2))
	drawFloor(array)
	flagEnemyCells()
	return startCell

func drawFloor(floorArray: Array):
	dungeon = Ref.currentLevel.dungeon as TileMap
	dungeon.clear()
	for i in range(GLOBAL.FLOOR_SIZE_X):
		for j in range(GLOBAL.FLOOR_SIZE_Y):
			if floorArray[i][j] == -1:
				dungeon.set_cell(i, j, 1)
			else:
				dungeon.set_cell(i, j, floorArray[i][j])
	dungeon.update_bitmask_region()
	for cell in dungeon.get_used_cells_by_id(GLOBAL.DOOR_ID):
		dungeon.set_cellv(cell, GLOBAL.DOOR_ID, false, false, false, Vector2(0,1))

func changeTilesetTexture(index: int):
	var texture = load(textures[index])
	for id in Ref.currentLevel.dungeon.tile_set.get_tiles_ids():
		Ref.currentLevel.dungeon.tile_set.tile_set_texture(id, texture)

func loadAllItems():
	var cells = dungeon.get_used_cells_by_id(GLOBAL.FLOOR_ID)
	cells.invert()
	var idx = 0
	for e in Data.enchants.keys():
		var slot = Data.enchants[e][Data.EN_SLOTS][0]
		var item
		match slot:
			Data.EN_SLOT_WP:
				item = Ref.game.itemGenerator.getWeapon(Data.W_CLUB, [e])
			Data.EN_SLOT_AR:
				item = Ref.game.itemGenerator.getArmor(Data.A_ROBE, [e])
			Data.EN_SLOT_TA:
				item = Ref.game.itemGenerator.getTalisman(0, [e])
		if item != null:
			GLOBAL.dropItemOnFloor(item[0], cells[idx])
			idx = (idx + 1) % cells.size()

# Call after drawFloor
func flagEnemyCells():
	enemyCells.clear()
	for c in dungeon.get_used_cells_by_id(GLOBAL.FLOOR_ID):
		if Utils.squareDist(c, startCell) < (GLOBAL.VIEW_RANGE + 3):
			if Ref.currentLevel.canTarget(startCell, c):
				continue
		var valid: int = 0
		for d in Utils.neighbours:
			if dungeon.get_cellv(c + d) != GLOBAL.FLOOR_ID:
				valid += 1
		if valid < 7:
			enemyCells.append(c)
			#DEBUG
			Ref.currentLevel.get_node("Debug/Enemies").set_cellv(c, 2)

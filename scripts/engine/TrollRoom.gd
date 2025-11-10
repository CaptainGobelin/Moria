extends Node2D

onready var npcScene = preload("res://scenes/Npc.tscn")

onready var map = get_node("Walls")
onready var masks = get_node("Masks")

onready var dungeon: TileMap

var array:Array = []

const EXIT = 0
const BOSS = 1
const ENTRY = 2
const ADD = 3
const SPECIAL = 4
const SPAWN = 5
const roomOffset = Vector2(9, 4)

func newFloor():
	dungeon = Ref.currentLevel.dungeon as TileMap
	array = []
	for i in range(GLOBAL.FLOOR_SIZE_X):
		array.append([])
		for _j in range(GLOBAL.FLOOR_SIZE_Y):
			array[i].append(GLOBAL.WALL_ID)
	for c in map.get_used_cells():
		array[c.x+roomOffset.x][c.y+roomOffset.y] = map.get_cellv(c)
		Ref.currentLevel.shadows.set_cellv(c + roomOffset, 1)
		Ref.currentLevel.shadows.update_bitmask_area(c + roomOffset)
		Ref.currentLevel.underShadows.set_cellv(c + roomOffset, 1)
	for c in masks.get_used_cells_by_id(ADD+1):
		Ref.currentLevel.spawnMonster(Data.MO_GOBLIN, c + roomOffset)
	for c in masks.get_used_cells_by_id(BOSS+1):
		Ref.currentLevel.spawnMonster(Data.MO_BO_TROLL, c + roomOffset)
	Ref.currentLevel.specialCells = masks.get_used_cells_by_id(SPECIAL+1)
	get_parent().drawFloor(array)
	var exit = masks.get_used_cells_by_id(EXIT+1)[0] + roomOffset
	dungeon.set_cellv(exit, GLOBAL.PASS_ID, false, false, false, Vector2(0, 1))
	var entry = masks.get_used_cells_by_id(ENTRY+1)[0] + roomOffset
	dungeon.set_cellv(entry, GLOBAL.PASS_ID, false, false, false, Vector2(3, 0))
	return masks.get_used_cells_by_id(SPAWN+1)[0] + roomOffset


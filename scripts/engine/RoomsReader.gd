extends Node2D

onready var walls = get_node("Walls")
onready var doors = get_node("Doors")
onready var limits = get_node("Limits")
onready var traps = get_node("Traps")

const START_ID = 1
const END_ID = 2
const DOOR_ID = 3
const GRID_ID = 5
const DOOR_DIR = ["N", "E", "S", "W"]
const WALL_ID = 1

var isInitialized = false

var roomsList = {}
var trapsList = {}
var doorsList = {}

func read():
	var currentPos = 0
	var ends = limits.get_used_cells_by_id(END_ID)
	for start in limits.get_used_cells_by_id(START_ID):
		var end = ends[currentPos/4]
		var size = end - start
		roomsList[currentPos] = []
		trapsList[currentPos] = []
		doorsList[currentPos] = []
		roomsList[currentPos+1] = []
		trapsList[currentPos+1] = []
		doorsList[currentPos+1] = []
		roomsList[currentPos+2] = []
		trapsList[currentPos+2] = []
		doorsList[currentPos+2] = []
		roomsList[currentPos+3] = []
		trapsList[currentPos+3] = []
		doorsList[currentPos+3] = []
		for i in range(start.x, end.x+1):
			for j in range(start.y, end.y+1):
				var cellPosition = Vector2(i, j) - start
				var doorTile = doors.get_cell(i, j) - DOOR_ID
				if doorTile >= 0:
					var doorCodes = getDoorsSymetrics(DOOR_DIR[doorTile])
					var pos = cellPosition
					doorsList[currentPos].append([pos, doorCodes[0]])
					pos = cellPosition*Vector2(-1, 1) + Vector2(size.x, 0)
					doorsList[currentPos+1].append([pos, doorCodes[1]])
					pos = cellPosition*Vector2(1, -1) + Vector2(0, size.y)
					doorsList[currentPos+2].append([pos, doorCodes[2]])
					pos = cellPosition*Vector2(-1, -1) + size
					doorsList[currentPos+3].append([pos, doorCodes[3]])
				var tile = walls.get_cell(i, j)
				var isTrapped = traps.get_cell(i, j) != -1
				if tile != -1:
					var pos = cellPosition
					roomsList[currentPos].append([pos, tile])
					trapsList[currentPos].append([pos, isTrapped])
					pos = cellPosition*Vector2(-1, 1) + Vector2(size.x, 0)
					roomsList[currentPos+1].append([pos, tile])
					trapsList[currentPos+1].append([pos, isTrapped])
					pos = cellPosition*Vector2(1, -1) + Vector2(0, size.y)
					roomsList[currentPos+2].append([pos, tile])
					trapsList[currentPos+2].append([pos, isTrapped])
					pos = cellPosition*Vector2(-1, -1) + size
					roomsList[currentPos+3].append([pos, tile])
					trapsList[currentPos+3].append([pos, isTrapped])
		currentPos += 4
	isInitialized = true

func getDoorsSymetrics(door):
	match door:
		"N": return "NNSS"
		"S": return "SSNN"
		"E": return "EWEW"
		"W": return "WEWE"

extends Node

onready var reader = get_node("RoomsReader")
onready var dungeon = get_parent().get_node("Map") as TileMap

onready var neighbours = [Vector2(0,-1), Vector2(1,0), Vector2(0,1), Vector2(-1,0)]
onready var near1x1 = [Vector2(0,-1), Vector2(1,0), Vector2(0,1), Vector2(-1,0)]
onready var near2x2 = [Vector2(0,-1), Vector2(1,-1), Vector2(2,0), Vector2(2,1),
						Vector2(1,2), Vector2(0,2), Vector2(-1,1), Vector2(-1,0)]
onready var cells1x1 = [Vector2(0,0)]
onready var cells2x2 = [Vector2(0,0), Vector2(1,0), Vector2(0,1), Vector2(1,1)]
onready var doorsMapper1x1 = [[Vector2(0,0), Vector2(1,1), Vector2(2,2), Vector2(3,3)]]
onready var doorsMapper2x2 = [
	[Vector2(0,0), Vector2(7,3)],
	[Vector2(1,0), Vector2(2,1)],
	[Vector2(3,1), Vector2(4,2)],
	[Vector2(5,2), Vector2(6,3)]]

func _ready():
	reader.read()
	newGenerate()
	set_process_input(true)

func _input(event):
	if (event.is_action_released("ui_accept")):
		newGenerate()

func initialize():
	dungeon.clear()
	for i in range(GLOBAL.SIZE_X):
		for j in range(GLOBAL.SIZE_Y):
			for x in range(7):
				for y in range(7):
					dungeon.set_cell(i*6+x,j*6+y, 1)

func generate():
	if (not GLOBAL.roomsInitialized):
		reader.read()
	initialize()
	for i in range(GLOBAL.SIZE_X):
		for j in range(GLOBAL.SIZE_Y):
			var choice = randi() % GLOBAL.rooms.keys().size()
			for x in range(1,6):
				for y in range(1,6):
					dungeon.set_cell(i*6+x,j*6+y, GLOBAL.rooms[choice][x][y])

func newGenerate():
	if (not GLOBAL.roomsInitialized):
		reader.read()
	initialize()
	var array = getDungeonArray()
	var failures = 0
	while (array == null):
		failures += 1
		if (failures >= 100):
			print("Error !")
			return
		array = getDungeonArray()
	fillDungeon(array)
	print("Success after: ", failures, " tries.")
	
func getDungeonArray():
	var array:Array = []
	for i in range(GLOBAL.SIZE_X):
		array.append([])
		for j in range(GLOBAL.SIZE_Y):
			array[i].append([-1, "0000", false, ""])
	var randomCell = Vector2(1+randi()%(GLOBAL.SIZE_X-2), 1+randi()%(GLOBAL.SIZE_Y-2))
	array[randomCell.x][randomCell.y] = [-2, "0100", false, ""]
	while (true):
		var list = checkCandidates(array)
		array[randomCell.x][randomCell.y] = [-1, "0000", false, ""]
		if (list.empty()):
			if (checkIsFull(array)):
				return array
			else:
				return null
		var index = randi()%list.size()
		var roomIndex = randi()%GLOBAL.roomsByDoors[list[index][1]].size()
		match list[index][2]:
			"1x1":
				var cellPos = 0
				for c in cells1x1:
					var doorCode = mapDoorsCode(list[index][1], doorsMapper1x1[cellPos])
					var cell = list[index][0] + c
					array[cell.x][cell.y][0] = GLOBAL.roomsByDoors[list[index][1]][roomIndex]
					array[cell.x][cell.y][1] = doorCode
					array[cell.x][cell.y][2] = (cellPos == 0)
					array[cell.x][cell.y][3] = list[index][2]
					cellPos += 1
			"2x2":
				var cellPos = 0
				for c in cells2x2:
					var doorCode = mapDoorsCode(list[index][1], doorsMapper2x2[cellPos])
					var cell = list[index][0] + c
					array
					[cell.x][cell.y][0] = GLOBAL.roomsByDoors[list[index][1]][roomIndex]
					array[cell.x][cell.y][1] = doorCode
					array[cell.x][cell.y][2] = (cellPos == 0)
					array[cell.x][cell.y][3] = list[index][2]
					cellPos += 1

func fillDungeon(array):
	for i in range(GLOBAL.SIZE_X):
		for j in range(GLOBAL.SIZE_Y):
			if (array[i][j][0] == -1):
				continue
			if (!array[i][j][2]):
				continue
			var room = GLOBAL.rooms[array[i][j][0]]
			var n = Vector2(1, 1)
			match array[i][j][3]:
				"1x1": n = Vector2(7, 7)
				"2x2": n = Vector2(13, 13)
			for x in range(1,n.x):
				for y in range(1,n.y):
					dungeon.set_cell(i*6+x, j*6+y, room[x][y])

func checkIsFull(array):
	var count = 0
	for i in range(GLOBAL.SIZE_X):
		for j in range(GLOBAL.SIZE_Y):
			if (array[i][j][0] == -1):
				count += 1
	return count < 40

func checkCandidates(array):
	var candidates = []
	for i in range(GLOBAL.SIZE_X):
		for j in range(GLOBAL.SIZE_Y):
			for r in GLOBAL.roomsByDoors.keys():
				var nearCells = []; var requiredCells = []; var mapper = []; var size = ""
				match r.length():
					4:
						nearCells = near1x1
						requiredCells = cells1x1
						mapper = doorsMapper1x1
						size = "1x1"
					8:
						nearCells = near2x2
						requiredCells = cells2x2
						mapper = doorsMapper2x2
						size = "2x2"
					_:
						continue
				var cellPos = -1
				var totalChecks = 0
				var toBreak = false
				for c in requiredCells:
					cellPos += 1
					if (!checkCell(Vector2(i,j) + c, array)):
						break
					for dir in range(4):
						var doorCode = mapDoorsCode(r, mapper[cellPos])
						var check = checkDoors(Vector2(i,j) + c, dir, array, doorCode)
						if (check == -1):
							toBreak = true
							break
						totalChecks += check
					if (toBreak):
						totalChecks = -1
						break
				if (totalChecks > 0):
					candidates.append([Vector2(i,j), r, size])
	return candidates

func mapDoorsCode(code, mapper):
	var result = "****"
	for i in range(mapper.size()):
		result[mapper[i].y] = code[mapper[i].x]
	return result

func checkCell(cell, array):
	if (cell.x < 0 or cell.x >= GLOBAL.SIZE_X):
		return false
	if (cell.y < 0 or cell.y >= GLOBAL.SIZE_Y):
		return false
	return (array[cell.x][cell.y][0] <= -1)

func checkDoors(cell, direction, array, doorCode):
	var near = cell + neighbours[direction]
	if (near.x < 0 or near.x >= GLOBAL.SIZE_X):
		return -1
	if (near.y < 0 or near.y >= GLOBAL.SIZE_Y):
		return -1
	if (array[near.x][near.y][0] == -1):
		return 0
	match doorCode[direction]:
		"0":
			if (array[near.x][near.y][1][(direction+2)%4] == "0"):
				return 0
			if (array[near.x][near.y][1][(direction+2)%4] == "*"):
				return 0
			else:
				return -1
		"1":
			if (array[near.x][near.y][1][(direction+2)%4] == "1"):
				return 1
			if (array[near.x][near.y][1][(direction+2)%4] == "*"):
				return 0
			else:
				return -1
		_:
			return -1

extends Node

onready var game = get_parent().get_parent()
onready var roomsReader = get_node("RoomsReader")
onready var decorator = get_node("DungeonDecorator")
onready var dungeon: TileMap

# Door: [position:Vector2, direction:String]
var waitingDoors:Array = []
var validatedDoors:Array = []
var array:Array = []
var arrayFullness = 0
var trapList: Dictionary = {}

func simpleFloor():
	dungeon = Ref.currentLevel.dungeon as TileMap
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
	drawFloor()
	return Vector2(int(GLOBAL.FLOOR_SIZE_X/2), int(GLOBAL.FLOOR_SIZE_Y/2))

func newFloor():
	dungeon = Ref.currentLevel.dungeon as TileMap
	var retries = 0
	generate()
	while !isFloorFull():
		generate()
		retries += 1
	fuseDoorsAndWalls()
	decorator.init(array)
	var exits = decorator.placeExits()
	drawFloor()
	var criticalPath = Ref.game.pathfinder.a_star(exits[0], exits[2], 9999)
	decorator.flagCriticalPath(criticalPath)
	var rooms = decorator.getTreasuresCandidates()
	decorator.flagMap()
	# Place tresor rooms
	var treasureThreshold = 0.215
	var nTreasures = randf() - treasureThreshold
	while nTreasures > 0:
		if rooms[1].size() == 0:
			break
		var room = Utils.chooseRandom(rooms[1])
		rooms[1].erase(room)
		var cells = decorator.getChestCells(rooms[0][room][0])
		for _j in range(1 + (randi() % GLOBAL.LOOTS_PER_TREASURE)):
			if cells.size() == 0:
				break
			var cell = Utils.chooseRandom(cells)
			if randf() < 0.5:
				Ref.currentLevel.addLoot(cell, 1)
			else:
				Ref.currentLevel.addChest(cell, 1)
			decorator.flags[cell.x][cell.y] = 0
			cells.erase(cell)
		for d in rooms[0][room][1]:
			if randf() < (1 - 2 * GLOBAL.HIDDEN_DOORS_RATIO):
				GLOBAL.hiddenDoors.append(d)
				array[d.x][d.y] = GLOBAL.WALL_ID
			if randf() < (1 - 2 * GLOBAL.LOCKED_DOORS_RATIO):
				GLOBAL.lockedDoors.append(d)
			if validatedDoors.has(d):
				validatedDoors.erase(d)
		nTreasures -= (2 * treasureThreshold)
		treasureThreshold /= 2.0
	# Hide doors
	for r in rooms[0].values():
		for d in r[1]:
			if randf() < GLOBAL.HIDDEN_DOORS_RATIO:
				GLOBAL.hiddenDoors.append(d)
				array[d.x][d.y] = GLOBAL.WALL_ID
				if validatedDoors.has(d):
					validatedDoors.erase(d)
	# Lock doors
	for r in rooms[0].values():
		for d in r[1]:
			if randf() < GLOBAL.LOCKED_DOORS_RATIO:
				GLOBAL.lockedDoors.append(d)
				if validatedDoors.has(d):
					validatedDoors.erase(d)
	# Place traps
	for t in trapList.values():
		if randf() < GLOBAL.TRAPPED_ROOMS_RATIO:
			for _i in range(randi() % GLOBAL.TRAPS_PER_ROOM):
				if t.size() == 0:
					break
				var pos = t[randi() % t.size()]
				for cell in decorator.getTrapPattern():
					var trapPos = pos + cell
					if t.has(trapPos):
						if array[trapPos.x][trapPos.y] == GLOBAL.FLOOR_ID:
							Ref.currentLevel.placeTrap(trapPos)
						t.erase(trapPos)
	deleteCorridorDoors()
	drawFloor()
	# Draw entry
	dungeon.set_cellv(exits[1], GLOBAL.PASS_ID, false, false, false, Vector2(2, 0))
	print("Generated after ", retries, " retires.")
	return exits[0]

func generate():
	if !roomsReader.isInitialized:
		roomsReader.read()
	waitingDoors = []
	validatedDoors = []
	arrayFullness = 0
	array = []
	trapList.clear()
	for i in range(GLOBAL.FLOOR_SIZE_X):
		array.append([])
		for _j in range(GLOBAL.FLOOR_SIZE_Y):
			array[i].append(GLOBAL.WALL_ID)
	# Place first room
	var x = randi() % (GLOBAL.FLOOR_SIZE_X)
	var y = randi() % (GLOBAL.FLOOR_SIZE_Y)
	var roomId = randi() % roomsReader.roomsList.size()
	while !isRoomFits(roomId, Vector2(x, y)):
		x = randi() % (GLOBAL.FLOOR_SIZE_X)
		y = randi() % (GLOBAL.FLOOR_SIZE_Y)
		roomId = randi() % roomsReader.roomsList.size()
	placeFirstRoom(roomId, Vector2(x, y))
	# Until floor is full:
	while (!waitingDoors.empty()):
		# Take a door from list
		var doorIndex = randi() % waitingDoors.size()
		var door = waitingDoors[doorIndex]
		# Take a random room, try to place it
		roomId = randi() % roomsReader.roomsList.size()
		# If it fits place it otherwise test another one
		var roomDoorIndex = getRoomOppositeDoor(roomId, door[1])
		if (roomDoorIndex == -1):
			continue
		var roomDoor = roomsReader.doorsList[roomId][roomDoorIndex]
		var position = door[0] - roomDoor[0]
		var retries = roomsReader.roomsList.size() / 2
		var placeRoom = false
		while (!placeRoom and retries > 0):
			roomId = (roomId + 1) % roomsReader.roomsList.size()
			# If it fits place it otherwise test another one
			roomDoorIndex = getRoomOppositeDoor(roomId, door[1])
			if (roomDoorIndex == -1):
				retries -= 1
				continue
			roomDoor = roomsReader.doorsList[roomId][roomDoorIndex]
			position = door[0] - roomDoor[0]
			if isRoomFits(roomId, position):
				placeRoom = true
			retries -= 1
		if placeRoom:
			placeRoom(roomId, position, roomDoorIndex)
			# Validate door
			validatedDoors.append(door[0])
		# Remove the door from list
		waitingDoors.remove(doorIndex)

func drawFloor():
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

func getRoomOppositeDoor(roomId, doorDirection):
	var resultList = []
	var count = 0
	for d in roomsReader.doorsList[roomId]:
		if isDoorsOpposites(d[1], doorDirection):
			resultList.append(count) 
		count += 1
	if resultList.empty():
		return -1
	var resultIndex = randi() % resultList.size()
	return resultList[resultIndex]

func isRoomFits(roomId, position):
	for c in roomsReader.roomsList[roomId]:
		var p = c[0] + position
		if (p.x < 0 or p.y < 0):
			return false
		if (p.x >= GLOBAL.FLOOR_SIZE_X or p.y >= GLOBAL.FLOOR_SIZE_Y):
			return false
		if array[p.x][p.y] != GLOBAL.WALL_ID:
			return false
	return true

func isFloorFull():
	return arrayFullness > GLOBAL.FULLNESS_THRESHOLD * (GLOBAL.FLOOR_SIZE_X * GLOBAL.FLOOR_SIZE_Y)

func placeFirstRoom(roomId, position):
	# Place room tiles
	for c in roomsReader.roomsList[roomId]:
		if (c[1] == 1):
			continue
		var p = c[0] + position
		array[p.x][p.y] = c[1]
		arrayFullness += 1
	# Place doors
	for d in roomsReader.doorsList[roomId]:
		waitingDoors.append([d[0] + position, d[1]])
	# Place traps
	var trapPos = []
	for t in roomsReader.trapsList[roomId]:
		if t[1]:
			var p = t[0] + position
			trapPos.append(p)
	if trapPos.size() != 0:
		trapList[trapList.keys().size()] = trapPos

func placeRoom(roomId, position, roomDoorIndex):
	# Place room tiles
	for c in roomsReader.roomsList[roomId]:
		if (c[1] == 1):
			continue
		var p = c[0] + position
		array[p.x][p.y] = c[1]
		arrayFullness += 1
	# Place doors
	var count = 0
	for d in roomsReader.doorsList[roomId]:
		if count != roomDoorIndex:
			waitingDoors.append([d[0] + position, d[1]])
		count += 1
	# Place traps
	var trapPos = []
	for t in roomsReader.trapsList[roomId]:
		if t[1]:
			var p = t[0] + position
			trapPos.append(p)
	if trapPos.size() != 0:
		trapList[trapList.keys().size()] = trapPos

func isDoorsOpposites(a, b):
	match a:
		"N": return b == "S"
		"E": return b == "W"
		"S": return b == "N"
		"W": return b == "E"
	return false

func deleteCorridorDoors():
	var doorsToRemove = []
	for d in validatedDoors:
		if GLOBAL.hiddenDoors.has(d):
			continue
		if randf() < GLOBAL.DOOR_REDUCTION_RATIO:
			continue
		var count = 0
		for di in range(-1, 2):
			for dj in range(-1, 2):
				if array[d.x+di][d.y+dj] != GLOBAL.FLOOR_ID:
					count += 1
		if count <= 3:
			for di in range(-1, 2):
				for dj in range(-1, 2):
					array[d.x+di][d.y+dj] = GLOBAL.FLOOR_ID
			doorsToRemove.append(d)
		if count >= 7:
			array[d.x][d.y] = GLOBAL.FLOOR_ID
			doorsToRemove.append(d)
	for d in doorsToRemove:
		validatedDoors.erase(d)
 
func fuseDoorsAndWalls():
	for d in validatedDoors:
		array[d.x][d.y] = GLOBAL.DOOR_ID
	for i in range(GLOBAL.FLOOR_SIZE_X):
		for j in range(GLOBAL.FLOOR_SIZE_Y):
			if array[i][j] == -1:
				array[i][j] = GLOBAL.WALL_ID

extends Node

onready var decorator = get_node("../DungeonDecorator")
onready var dungeon: TileMap

export (int, "Normal, Cavern, Arena") var biome = 0

# Door: [position:Vector2, direction:String]
var waitingDoors:Array = []
var validatedDoors:Array = []
var array:Array = []
var arrayFullness = 0
var trapList: Dictionary = {}

func newFloor():
	dungeon = Ref.currentLevel.dungeon as TileMap
	var retries = 0
	generate()
	get_parent().drawFloor(array)
	decorator.init(array)
	var rooms = decorator.getTreasuresCandidates(1)
	while rooms[0].keys().size() > 1:
		var roomList = rooms[0].values().duplicate()
		roomList.sort_custom(RoomSorter, "sort_by_size")
		connectRoom(roomList[0][0])
		decorator.init(array)
		rooms = decorator.getTreasuresCandidates(1)
	fuseDoorsAndWalls()
	decorator.init(array)
	var exits = decorator.placeExits()
	get_parent().drawFloor(array)
	var criticalPath = Ref.game.pathfinder.a_star(exits[0], exits[2], 9999, true)
	decorator.flagCriticalPath(criticalPath, true)
	get_parent().drawFloor(array)
	rooms = decorator.getTreasuresCandidates(50)
	decorator.flagMap()
	# Place tresor rooms
	var treasureThreshold = 0.215
	var nTreasures = randf()
	while nTreasures > 0:
		if rooms[1].size() == 0:
			break
		var room = Utils.chooseRandom(rooms[1])
		rooms[1].erase(room)
		var cells = decorator.getChestCells(rooms[0][room][0])
		for _j in range(2 + (randi() % GLOBAL.LOOTS_PER_TREASURE)):
			if cells.size() == 0:
				break
			var cell = Utils.chooseRandom(cells)
			if randf() < 0.75:
				Ref.currentLevel.addLoot(cell, 1)
			else:
				Ref.currentLevel.addChest(cell, 1)
			decorator.flags[cell.x][cell.y] = 0
			cells.erase(cell)
		for d in rooms[0][room][1]:
			# In caverns all doors are hidden
#			if randf() < (1 - 2 * GLOBAL.HIDDEN_DOORS_RATIO):
#				GLOBAL.hiddenDoors.append(d)
#				array[d.x][d.y] = GLOBAL.WALL_ID
			if randf() < (1 - 2 * GLOBAL.LOCKED_DOORS_RATIO):
				GLOBAL.lockedDoors.append(d)
#			if validatedDoors.has(d):
#				validatedDoors.erase(d)
		nTreasures -= (2 * treasureThreshold)
		treasureThreshold /= 2.0
	hideAllDoors()
	get_parent().drawFloor(array)
	# Draw entry
	dungeon.set_cellv(exits[1], GLOBAL.PASS_ID, false, false, false, Vector2(2, 0))
	print("Generated after ", retries, " retires.")
	return exits[0]

func generate():
	validatedDoors = []
	array = []
	for i in range(GLOBAL.FLOOR_SIZE_X):
		array.append([])
		for j in range(GLOBAL.FLOOR_SIZE_Y):
			if i < 1 or i > GLOBAL.FLOOR_SIZE_X - 2:
				array[i].append(GLOBAL.WALL_ID)
			elif j < 1 or j > GLOBAL.FLOOR_SIZE_Y - 2:
				array[i].append(GLOBAL.WALL_ID)
			elif randf() < 0.38:
				array[i].append(GLOBAL.WALL_ID)
			else:
				array[i].append(GLOBAL.FLOOR_ID)
	var rooms = placeRoom()
	placeObstacles()
	for _x in range(2):
		var tArray = array.duplicate(true)
		for i in range(1, GLOBAL.FLOOR_SIZE_X-1):
			for j in range(1, GLOBAL.FLOOR_SIZE_Y-1):
				if array[i][j] == -1:
					continue
				var count = 0
				for di in range(-1, 2):
					for dj in range(-1, 2):
						if tArray[i+di][j+dj] == GLOBAL.WALL_ID:
							count += 1
						if tArray[i+di][j+dj] == -1:
							count += 1
				if count > 4:
					array[i][j] = GLOBAL.WALL_ID
				else:
					array[i][j] = GLOBAL.FLOOR_ID
	for room in rooms:
		for i in range(room[1].x):
			for j in range(room[1].y):
				if i == 0:
					if j == 0 or j == (room[1].y-1):
						continue
				if i == (room[1].x-1):
					if j == 0 or j == (room[1].y-1):
						continue
				array[room[0].x+i][room[0].y+j] = GLOBAL.FLOOR_ID
	for i in range(1, GLOBAL.FLOOR_SIZE_X-1):
		for j in range(1, GLOBAL.FLOOR_SIZE_Y-1):
			if array[i][j] == -1:
				array[i][j] = GLOBAL.WALL_ID
	while removeIsolatedWalls():
		continue

func placeRoom() -> Array:
	var rooms = []
	var nb = randi() % 3 + 4
	for _x in range(nb):
		var roomSizeX = randi() % 3 + 3
		var roomSizeY = randi() % 3 + 3
		var i = randi() % (GLOBAL.FLOOR_SIZE_X-2-roomSizeX) + 1
		var j = randi() % (GLOBAL.FLOOR_SIZE_Y-2-roomSizeY) + 1
		for di in range(2+roomSizeX):
			for dj in range(2+roomSizeY):
				if di == 0:
					if dj == 0 or dj == (roomSizeY+1):
						continue
				if di == (roomSizeX+1):
					if dj == 0 or dj == (roomSizeY+1):
						continue
				array[i+di][j+dj] = -1
		rooms.append([Vector2(i+1, j+1), Vector2(roomSizeX, roomSizeY)])
	return rooms

func placeObstacles():
	var obsCount = randi() % 3 + 4
	for _x in range(obsCount):
		var direction = Utils.chooseRandom(Utils.directons.duplicate())
		var size = randi() % 3 + 2
		var i = randi() % (GLOBAL.FLOOR_SIZE_X-2) + 1
		var j = randi() % (GLOBAL.FLOOR_SIZE_Y-2) + 1
		for dx in range(size):
			var di = i + direction.x * dx
			var dj = j + direction.y * dx
			if di < 1 or dj < 1:
				continue
			if di > GLOBAL.FLOOR_SIZE_X-2 or dj > GLOBAL.FLOOR_SIZE_Y-2:
				continue
			array[di][dj] = -1

func removeIsolatedWalls() -> bool:
	var result = false
	for i in range(1, GLOBAL.FLOOR_SIZE_X-1):
		for j in range(1, GLOBAL.FLOOR_SIZE_Y-1):
			if array[i][j] != GLOBAL.WALL_ID:
				continue
			result = result or checkWallCell(i, j)
	return result

func checkWallCell(i: int, j: int) -> bool:
	var checks = [
		[Vector2(-1, 0), Vector2(0, -1), Vector2(-1, -1)],
		[Vector2(-1, 0), Vector2(0, 1), Vector2(-1, 1)],
		[Vector2(1, 0), Vector2(0, -1), Vector2(1, -1)],
		[Vector2(1, 0), Vector2(0, 1), Vector2(1, 1)]
	]
	for c in checks:
		if array[i+c[0].x][j+c[0].y] != GLOBAL.FLOOR_ID:
			continue
		if array[i+c[1].x][j+c[1].y] != GLOBAL.FLOOR_ID:
			continue
		if array[i+c[2].x][j+c[2].y] == GLOBAL.WALL_ID:
			array[i][j] = GLOBAL.FLOOR_ID
			return true
	return false

func connectRoom(cells: Array):
	var tArray = array.duplicate(true)
	for i in range(GLOBAL.FLOOR_SIZE_X):
		for j in range(GLOBAL.FLOOR_SIZE_Y):
			if tArray[i][j] == GLOBAL.FLOOR_ID:
				tArray[i][j] = 0
			else:
				tArray[i][j] = 9999
	for cell in cells:
		tArray[cell.x][cell.y] = 9999
	var stop = false
	while !stop:
		stop = true
		for i in range(1, GLOBAL.FLOOR_SIZE_X-1):
			for j in range(1, GLOBAL.FLOOR_SIZE_Y-1):
				if (tArray[i][j] - tArray[i-1][j]) > 1:
					tArray[i][j] = tArray[i-1][j] + 1
					stop = false
				if (tArray[i][j] - tArray[i+1][j]) > 1:
					tArray[i][j] = tArray[i+1][j] + 1
					stop = false
				if (tArray[i][j] - tArray[i][j-1]) > 1:
					tArray[i][j] = tArray[i][j-1] + 1
					stop = false
				if (tArray[i][j] - tArray[i][j+1]) > 1:
					tArray[i][j] = tArray[i][j+1] + 1
					stop = false
	var cell = Utils.chooseRandom(cells)
	var doors = []
	while array[cell.x][cell.y] != GLOBAL.FLOOR_ID or cells.has(cell):
		doors.append(cell)
		array[cell.x][cell.y] = GLOBAL.FLOOR_ID
		var minDist = 99999
		var newCell = cell
		for d in Utils.directons:
			if tArray[cell.x+d.x][cell.y+d.y] < minDist:
				minDist = tArray[cell.x+d.x][cell.y+d.y]
				newCell = cell + d
		cell = newCell
	validatedDoors.append(doors)

func isDoorPlace(i: int, j: int) -> bool:
	if array[i-1][j] == GLOBAL.WALL_ID and array[i+1][j] == GLOBAL.WALL_ID:
		return (array[i][j-1] == GLOBAL.FLOOR_ID and array[i][j+1] == GLOBAL.FLOOR_ID)
	if array[i][j-1] == GLOBAL.WALL_ID and array[i][j+1] == GLOBAL.WALL_ID:
		return (array[i-1][j] == GLOBAL.FLOOR_ID and array[i+1][j] == GLOBAL.FLOOR_ID)
	return false

func fuseDoorsAndWalls():
	for doors in validatedDoors:
		for d in doors:
			if isDoorPlace(d.x, d.y):
				array[d.x][d.y] = GLOBAL.DOOR_ID
				break
	for i in range(GLOBAL.FLOOR_SIZE_X):
		for j in range(GLOBAL.FLOOR_SIZE_Y):
			if array[i][j] == -1:
				array[i][j] = GLOBAL.WALL_ID

class RoomSorter:
	static func sort_by_size(a, b):
		if a[0].size() < b[0].size():
			return true
		return false

func hideAllDoors():
	for i in range(GLOBAL.FLOOR_SIZE_X):
		for j in range(GLOBAL.FLOOR_SIZE_Y):
			if array[i][j] == GLOBAL.DOOR_ID:
				GLOBAL.hiddenDoors.append(Vector2(i, j))
				array[i][j] = GLOBAL.WALL_ID

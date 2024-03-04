extends Node

var borders: Dictionary
var floorsArray: Array

# Detect possible treasure rooms return dict of [roomCells, doorCell]
func getTreasuresCandidates(array: Array):
	var rooms = {}
	var roomId = 0
	var analyzed = []
	for i in range(GLOBAL.FLOOR_SIZE_X):
		analyzed.append([])
		for _j in range(GLOBAL.FLOOR_SIZE_Y):
			analyzed[i].append(false)
	for i in range(GLOBAL.FLOOR_SIZE_X):
		for j in range(GLOBAL.FLOOR_SIZE_Y):
			if analyzed[i][j]:
				continue
			if array[i][j] == GLOBAL.FLOOR_ID:
				var floodResult = flood(array, analyzed, i, j)
				if floodResult[0].size() != 0 and floodResult[1].size() == 1:
					rooms[roomId] = floodResult
					roomId += 1
	return rooms

# Recursive function to return a room with [roomCells, doorsCell]
func flood(array: Array, analyzed: Array, i: int, j: int):
	if analyzed[i][j]:
		return [[], []]
	if array[i][j] == GLOBAL.DOOR_ID or array[i][j] == GLOBAL.PASS_ID:
		return [[], [Vector2(i, j)]]
	analyzed[i][j] = true
	if array[i][j] != GLOBAL.FLOOR_ID:
		return [[], []]
	var result = [[Vector2(i, j)], []]
	for n in getNeighbours(i, j):
		var floodResult = flood(array, analyzed, n.x, n.y)
		result[0].append_array(floodResult[0])
		result[1].append_array(floodResult[1])
	return result

# Place entry and exit in floor and return spawn location
func placeExits(array: Array):
	for i in range(6):
		borders[i] = []
	for i in range(GLOBAL.FLOOR_SIZE_X):
		for j in range(GLOBAL.FLOOR_SIZE_Y):
			if array[i][j] == GLOBAL.WALL_ID:
				var count = 0
				for c in getNeighbours(i, j):
					if isOutOfBounds(c.x, c.y):
						continue
					if array[c.x][c.y] == GLOBAL.FLOOR_ID:
						count += 1
				if count > 1 or count == 0:
					continue
				for c in getDiagonals(i, j):
					if isOutOfBounds(c.x, c.y):
						continue
					if array[c.x][c.y] == GLOBAL.FLOOR_ID:
						count += 1
				if count > 2:
					continue
				borders[getQuadrant(i, j)].append(Vector2(i, j))
	var exitQuadrant = randi() % 6
	var p = borders[exitQuadrant][randi() % borders[exitQuadrant].size()]
	array[p.x][p.y] = GLOBAL.PASS_ID
	var entryQuadrant = (exitQuadrant+3)%6
	p = borders[entryQuadrant][randi() % borders[entryQuadrant].size()]
	array[p.x][p.y] = GLOBAL.PASS_ID
	for n in getNeighbours(p.x, p.y):
		if array[n.x][n.y] != GLOBAL.WALL_ID and array[n.x][n.y] >= 0:
			array[n.x][n.y] = GLOBAL.FLOOR_ID
			return n

func isOutOfBounds(x, y):
	if x <= 0: return true
	if y <= 0: return true
	if x >= GLOBAL.FLOOR_SIZE_X: return true
	if y >= GLOBAL.FLOOR_SIZE_Y: return true

func getNeighbours(x, y):
	return [Vector2(x-1, y), Vector2(x, y-1), Vector2(x, y+1), Vector2(x+1, y)]

func getDiagonals(x, y):
	return [Vector2(x-1, y-1), Vector2(x-1, y+1), Vector2(x+1, y-1), Vector2(x+1, y+1)]

func getQuadrant(x, y):
	if y < GLOBAL.FLOOR_SIZE_Y/2:
		if x < GLOBAL.FLOOR_SIZE_X/3:
			return 0
		if x < 2*GLOBAL.FLOOR_SIZE_X/3:
			return 1
		return 2
	if x < GLOBAL.FLOOR_SIZE_X/3:
		return 5
	if x < 2*GLOBAL.FLOOR_SIZE_X/3:
		return 4
	return 3

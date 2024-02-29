extends Node

var borders: Dictionary
var floorsArray: Array

func analyseDungeon(array: TileMap):
	for i in range(6):
		borders[i] = []
	for i in range(GLOBAL.FLOOR_SIZE_X):
		for j in range(GLOBAL.FLOOR_SIZE_Y):
			if array.get_cell(i, j) == GLOBAL.WALL_ID:
				var count = 0
				for c in getNeighbours(i, j):
					if isOutOfBounds(c.x, c.y):
						continue
					if array.get_cellv(c) != GLOBAL.WALL_ID:
						count += 1
				if count > 1 or count == 0:
					continue
				for c in getDiagonals(i, j):
					if isOutOfBounds(c.x, c.y):
						continue
					if array.get_cellv(c) != GLOBAL.WALL_ID:
						count += 1
				if count > 2:
					continue
				borders[getQuadrant(i, j)].append(Vector2(i, j))
	var exitQuadrant = randi() % 6
	var p = borders[exitQuadrant][randi() % borders[exitQuadrant].size()]
	array.set_cellv(p, GLOBAL.PASS_ID)
	var entryQuadrant = (exitQuadrant+3)%6
	p = borders[entryQuadrant][randi() % borders[entryQuadrant].size()]
	array.set_cellv(p, GLOBAL.PASS_ID,false, false, false, Vector2(2, 0))
	for n in getNeighbours(p.x, p.y):
		if array.get_cellv(n) != GLOBAL.WALL_ID and array.get_cellv(n) >= 0:
			array.set_cellv(n, GLOBAL.FLOOR_ID)
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
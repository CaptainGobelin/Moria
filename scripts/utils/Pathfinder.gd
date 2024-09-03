extends Node

var exploreMap: Array = []

func dijkstraCompute():
	exploreMap.clear()
	for i in range(GLOBAL.FLOOR_SIZE_X+1):
		exploreMap.append([])
		for _j in range(GLOBAL.FLOOR_SIZE_Y+1):
			exploreMap[i].append(9999)
	for cell in Ref.currentLevel.shadows.get_used_cells_by_id(0):
		if cell.x < 0 or cell.y < 0:
			continue
		var value = Ref.currentLevel.dungeon.get_cellv(cell)
		if value != GLOBAL.FLOOR_ID and value != GLOBAL.DOOR_ID:
			continue
		exploreMap[cell.x][cell.y] = 0
	for itemCell in GLOBAL.itemsOnFloor.keys():
		if !GLOBAL.itemsOnFloor[itemCell][GLOBAL.FLOOR_EXP]:
			exploreMap[itemCell.x][itemCell.y] = 0
	var cells = Ref.currentLevel.dungeon.get_used_cells_by_id(GLOBAL.FLOOR_ID)
	cells.append_array(Ref.currentLevel.dungeon.get_used_cells_by_id(GLOBAL.DOOR_ID))
	for chest in GLOBAL.chests.values():
		cells.erase(chest[GLOBAL.CH_POS])
	for door in GLOBAL.testedDoors:
		cells.erase(door)
	var stop = false
	while !stop:
		stop = true
		for cell in cells:
			if (exploreMap[cell.x][cell.y] - exploreMap[cell.x-1][cell.y]) > 1:
				exploreMap[cell.x][cell.y] = exploreMap[cell.x-1][cell.y] + 1
				stop = false
			if (exploreMap[cell.x][cell.y] - exploreMap[cell.x+1][cell.y]) > 1:
				exploreMap[cell.x][cell.y] = exploreMap[cell.x+1][cell.y] + 1
				stop = false
			if (exploreMap[cell.x][cell.y] - exploreMap[cell.x][cell.y-1]) > 1:
				exploreMap[cell.x][cell.y] = exploreMap[cell.x][cell.y-1] + 1
				stop = false
			if (exploreMap[cell.x][cell.y] - exploreMap[cell.x][cell.y+1]) > 1:
				exploreMap[cell.x][cell.y] = exploreMap[cell.x][cell.y+1] + 1
				stop = false

func findNextStep(map: Array, pos: Vector2):
	var dist = map[pos.x][pos.y] 
	var result = null
	for d in Utils.directons:
		if map[pos.x+d.x][pos.y+d.y] < dist:
			dist = map[pos.x+d.x][pos.y+d.y]
			result = d
	return result

func checkRange(start: Vector2, end: Vector2):
	return abs(start.x - end.x) + abs(start.y - end.y)

func check_line_of_sight(start, end): 
	var result = []
	var e1 = 10000.0
	var current = start
	if (start.x != end.x):
		e1 = float(end.y - start.y) / float(end.x - start.x)
	var e = e1
	result.append(current)
	check_cell_vision(current)
	while (current != end):
		if (abs(e) < 0.999):
			check_cell_vision(current + Vector2(0,sign(end.y-start.y)))
			current = current + Vector2(sign(end.x-start.x),0)
			e += e1
		else:
			check_cell_vision(current + Vector2(sign(end.x-start.x),0))
			current = current + Vector2(0,sign(end.y-start.y))
			e -= sign(e)
		result.append(current)
		if(!check_cell_vision(current)):
			return [false, result]
	return [true, result]

func check_cell_vision(position):
	var cellState = Ref.currentLevel.isCellFree(position)
	if (!cellState[0]):
		return false
	return true

func dist(a, b):
	return sqrt(pow(b.x-a.x, 2) + pow(b.y-a.y, 2))

func get_neighbors(cell, end, length, ignoreDoors: bool):
	var result = []
	var pos = cell[0]
	var cost = cell[1] + 1
	for i in [Vector2(-1, 0), Vector2(0, -1), Vector2(0, 1), Vector2(1, 0)]:
		if (pos + i) == end:
			result.append([pos + Vector2(i.x, i.y), cost, cell])
		var cellState = Ref.currentLevel.isCellFree(pos+i)
		if (pos + i) == Ref.character.pos:
			continue
		if !cellState[0] and (cellState[1] != "door" or !ignoreDoors) and cellState[1] != "pass":
			continue
		if (cost + dist(pos + Vector2(i.x, i.y), end) <= length):
			result.append([pos + Vector2(i.x, i.y), cost, cell])
	return result

func path_to(cell):
	var result = [cell[0]]
	while not cell[2] == null:
		cell = cell[2]
		result.append(cell[0])
	result.invert()
	return result

func shorter_in(cell, list):
	for i in list:
		if (cell[0].x == i[0].x and cell[0].y == i[0].y):
			if (cell[1] >= i[1]):
				return true
	return false

func add_sorted(cell, list):
	var k = 0
	for i in list:
		if (cell[1] < i[1]):
			list.insert(k, cell)
			return
		k += 1
	list.insert(k, cell)

func a_star(start, end, length, ignoreDoors: bool = false):
	if (end == null):
		return null
	if (dist(start, end) > length) or (dist(start, end) == 0):
		return null
	var closedList = []
	var openList = [[start, 0, null]]
	while (openList.size() > 0):
		var u = openList.pop_front()
		if (u[0].x == end.x and u[0].y == end.y):
			return path_to(u)
		for v in get_neighbors(u, end, length, ignoreDoors):
			if (shorter_in(v, openList) or shorter_in(v, closedList)):
				continue
			add_sorted(v, openList)
		closedList.append(u)
	return null

# Bresenham's Line Algorithm
func get_line(start:Vector2, end:Vector2):
	# Setup initial conditions
	var x1: float = start.x
	var y1: float = start.y
	var x2: float = end.x
	var y2: float = end.y
	var dx: float = x2 - x1
	var dy: float = y2 - y1

	# Determine how steep the line is
	var is_steep = abs(dy) > abs(dx)
	var swap_var = 0.0
	
	# Rotate line
	if is_steep:
		swap_var = x1
		x1 = y1
		y1 = swap_var
		
		swap_var = x2
		x2 = y2
		y2 = swap_var

	# Swap start and end points if necessary and store swap state
	var swapped := false
	if x1 > x2:
		swap_var = x1
		x1 = x2
		x2 = swap_var
		swap_var = y1
		y1 = y2
		y2 = swap_var
		swapped = true

	# Recalculate differentials
	dx = x2 - x1
	dy = y2 - y1

	# Calculate error
	var error: float = floor(dx / 2.0)  # Try int
	var ystep = 1 if y1 < y2 else -1

	# Iterate over bounding box generating points between start and end
	var y = y1
	var points: Array = []
	for x in range(x1, x2 + 1):
		var coord = Vector2(y, x) if is_steep else Vector2(x, y)
		points.append(coord)
		error -= abs(dy)
		if error < 0:
			y += ystep
			error += dx

	# Reverse the list if the coordinates were swapped
	if swapped:
		points.invert()
	return points

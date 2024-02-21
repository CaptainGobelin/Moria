extends Node2D

const WALL_TILE = 1

func read():
	print("Reading rooms...")
	var currentID = 0
	GLOBAL.rooms.clear()
	for c in get_children():
		print("Reading ", c.name)
		var walls:TileMap = c.get_node('Walls')
		var masks:TileMap = c.get_node('Masks')
		assert (walls != null, "Walls is null")
		assert (masks != null, "Masks is null")
		var i = 0; var j = 0
		var xStep; var yStep; var doors; var next
		if (c.name.find("1x1") != -1):
			xStep = 7; yStep = 7; doors = "----"
			next = [Vector2(3, 0), Vector2(6, 3), Vector2(3, 6), Vector2(0, 3)]
		elif (c.name.find("2x2") != -1):
			xStep = 13; yStep = 13; doors = "--------"
			next = [Vector2(3, 0), Vector2(9, 0), Vector2(12, 3), Vector2(12, 9),
			Vector2(9, 12), Vector2(3, 12), Vector2(0, 9), Vector2(0, 3)]
		else:
			assert (false, "Error in room size reading")
		while walls.get_cell(i, j) == WALL_TILE:
			while walls.get_cell(i, j) == WALL_TILE:
				var currentRoom:Array = []
				for x in range(xStep):
					currentRoom.append([])
					for y in range(yStep):
						currentRoom[x].append(walls.get_cell(i+x, j+y))
				GLOBAL.rooms[currentID] = currentRoom
				var count = 0
				for n in next:
					doors[count] = String(masks.get_cell(i+n.x, j+n.y) + 1)
					count += 1
				GLOBAL.roomsDoors[currentID] = doors
				if (GLOBAL.roomsByDoors.has(doors)):
					GLOBAL.roomsByDoors[doors].append(currentID)
				else:
					GLOBAL.roomsByDoors[doors] = [currentID]
				currentID += 1
				i += xStep
			i = 0
			j += yStep
		GLOBAL.roomsInitialized = true

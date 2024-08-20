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
	decorator.init(array)
	var exits = decorator.placeExits()
	get_parent().drawFloor(array)
	# Draw entry
	dungeon.set_cellv(exits[1], GLOBAL.PASS_ID, false, false, false, Vector2(2, 0))
	print("Generated after ", retries, " retires.")
	return exits[0]

func generate():
	array = []
	for i in range(GLOBAL.FLOOR_SIZE_X):
		array.append([])
		for j in range(GLOBAL.FLOOR_SIZE_Y):
			if i < 1 or i > GLOBAL.FLOOR_SIZE_X - 2:
				array[i].append(GLOBAL.WALL_ID)
			elif j < 1 or j > GLOBAL.FLOOR_SIZE_Y - 2:
				array[i].append(GLOBAL.WALL_ID)
			elif randf() < 0.45:
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
				if count > 4:
					array[i][j] = GLOBAL.WALL_ID
				else:
					array[i][j] = GLOBAL.FLOOR_ID
	for room in rooms:
		for i in range(room[1].x):
			for j in range(room[1].y):
				array[room[0].x+i][room[0].y+j] = GLOBAL.FLOOR_ID
	for i in range(1, GLOBAL.FLOOR_SIZE_X-1):
		for j in range(1, GLOBAL.FLOOR_SIZE_Y-1):
			if array[i][j] == -1:
				array[i][j] = GLOBAL.WALL_ID

func placeRoom() -> Array:
	var rooms = []
	for _x in range(3):
		var roomSizeX = randi() % 2 + 2
		var roomSizeY = randi() % 2 + 2
		var i = randi() % (GLOBAL.FLOOR_SIZE_X-2-roomSizeX) + 1
		var j = randi() % (GLOBAL.FLOOR_SIZE_Y-2-roomSizeY) + 1
		for di in range(2+roomSizeX):
			for dj in range(2+roomSizeY):
				array[i+di][j+dj] = -1
		rooms.append([Vector2(i+1, j+1), Vector2(roomSizeX, roomSizeY)])
	return rooms

func placeObstacles():
	var obsCount = randi() % 3 + 3
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

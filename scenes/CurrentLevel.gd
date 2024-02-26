extends Node2D

class_name CurrentLevel

onready var monsterScene = preload("res://scenes/Monster.tscn")
onready var lootScene = preload("res://scenes/Loot.tscn")

onready var dungeon = get_node("Map")
onready var fog = get_node("Fog")
onready var shadows = get_node("Shadows")
onready var monsters = get_node("Monsters")
onready var loots = get_node("Loots")
onready var effects = get_node("Effects")

func _ready():
	Ref.currentLevel = self

func refresh_view():
	clearFog()
	GLOBAL.targets.clear()
	for i in range(-GLOBAL.VIEW_RANGE+1, GLOBAL.VIEW_RANGE):
		for j in range(-GLOBAL.VIEW_RANGE+1, GLOBAL.VIEW_RANGE):
			if (pow(i,2)+pow(j,2) <= pow(GLOBAL.VIEW_RANGE,2)):
				var pos = Ref.character.pos
				var points = Ref.game.pathfinder.get_line(pos, pos+Vector2(i,j))
				for p in points:
					fog.set_cellv(p, 0)
					fog.update_bitmask_area(p)
					shadows.set_cellv(p, 1)
					shadows.update_bitmask_area(p)
					for m in monsters.get_children():
						if m.pos == p:
							m.awake()
							GLOBAL.targets.append(m.get_instance_id())
					var vision = isCellFree(p)
					if !vision[3]:
						break

func initShadows():
	for i in range(-1, GLOBAL.FLOOR_SIZE_X+1):
		for j in range(-1, GLOBAL.FLOOR_SIZE_Y+1):
			shadows.set_cell(i, j, 0)
			shadows.update_bitmask_area(Vector2(i, j))

func clearFog():
	for i in range(GLOBAL.FLOOR_SIZE_X):
		for j in range(GLOBAL.FLOOR_SIZE_Y):
			fog.set_cell(i, j, 1)

# [isFree, code, entity, isVisible]
func isCellFree(cell):
	if cell.x < 0 or cell.x >= GLOBAL.FLOOR_SIZE_X:
		return [false, "OOB", null, false]
	if cell.y < 0 or cell.y >= GLOBAL.FLOOR_SIZE_Y:
		return [false, "OOB", null, false]
	for m in monsters.get_children():
		if cell == m.pos:
			return [false, "monster", m, true]
	if dungeon.get_cellv(cell) == GLOBAL.GRID_ID:
		return [false, "grid", null, true]
	if dungeon.get_cellv(cell) == GLOBAL.PASS_ID:
		if dungeon.get_cell_autotile_coord(cell.x, cell.y) == Vector2(0, 0):
			return [false, "pass", null, false]
		elif dungeon.get_cell_autotile_coord(cell.x, cell.y) == Vector2(2, 0):
			return [false, "entry", null, false]
	if dungeon.get_cellv(cell) == GLOBAL.DOOR_ID:
		if dungeon.get_cell_autotile_coord(cell.x, cell.y) == Vector2(0, 0):
			return [true, "floor", null, true]
		else:
			return [false, "door", null, false]
	if dungeon.get_cellv(cell) == GLOBAL.FLOOR_ID:
		return [true, "floor", null, true]
	return [false, "unknown", null, false]

func getRandomFreeCell():
	while(true):
		var x = randi() % GLOBAL.FLOOR_SIZE_X
		var y = randi() % GLOBAL.FLOOR_SIZE_Y
		var cell = Vector2(x, y)
		if isCellFree(cell)[0]:
			return cell

func placeCharacter(pos: Vector2 = Vector2(-1,-1)):
	if pos == Vector2(-1, -1):
		pos = getRandomFreeCell()
	Ref.character.init()
	Ref.character.setPosition(pos)

func spawnMonster():
	var cell = getRandomFreeCell()
	var monster = monsterScene.instance()
	monsters.add_child(monster)
	monster.spawn(0)
	monster.setPosition(cell)

func dropItem():
	var cell = getRandomFreeCell()
	var rarity = randi() % 2
	var item = Ref.game.itemGenerator.generateItem(rarity)
	if item == null:
		return
	var loot = lootScene.instance()
	loots.add_child(loot)
	loot.init(item, cell)

func checkForLoot(cell):
	var dict:Dictionary = {}
	var currentId = 100000
	for idx in GLOBAL.itemsOnFloor.keys():
		if GLOBAL.itemsOnFloor[idx][0] != cell:
			continue
		var current = GLOBAL.items[idx]
		if current[GLOBAL.IT_STACK] == null:
			dict[currentId] = [idx]
			currentId += 1
			continue
		if !dict.has(current[GLOBAL.IT_STACK]):
			dict[current[GLOBAL.IT_STACK]] = [idx]
		else:
			dict[current[GLOBAL.IT_STACK]].append(idx)
	var result = []
	for d in dict.keys():
		result.append(dict[d])
	return result

func getLootMessage(cell):
	var lootList = checkForLoot(cell)
	if lootList.size() == 0:
		return null
	var msg = "You see "
	var list = []
	for l in lootList:
		list.append(Utils.addArticle(GLOBAL.items[l[0]][GLOBAL.IT_NAME], l.size()))
	msg += Utils.makeList(list) + "."
	return msg

func getLootChoice(lootList):
	var msg = "Pick what?"
	var count = 1
	for l in lootList:
		msg += " [" + Ref.ui.color(String(count), "yellow") + "] "
		msg += Utils.addArticle(GLOBAL.items[l[0]][GLOBAL.IT_NAME], l.size())
		count += 1
	return msg

func openDoor(pos):
	if dungeon.get_cellv(pos) != GLOBAL.DOOR_ID:
		return
	dungeon.set_cellv(pos, GLOBAL.DOOR_ID, false, false, false, Vector2(0, 0))

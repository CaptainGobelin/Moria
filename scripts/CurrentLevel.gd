extends Node2D

class_name CurrentLevel

onready var auraScene = preload("res://scenes/Aura.tscn")
onready var monsterScene = preload("res://scenes/Monster.tscn")
onready var lootScene = preload("res://scenes/Loot.tscn")
onready var chestScene = preload("res://scenes/Chest.tscn")
onready var secretScene = preload("res://scenes/Secret.tscn")
onready var trapScene = preload("res://scenes/Trap.tscn")
onready var effectScene = preload("res://scenes/Effect.tscn")

onready var dungeon = get_node("Map")
onready var fog = get_node("Fog")
onready var shadows = get_node("Shadows")
onready var underShadows = shadows.get_node("Under")
onready var auras = get_node("Auras")
onready var traps = get_node("Traps")
onready var monsters = get_node("Monsters")
onready var allies = get_node("Allies")
onready var npcs = get_node("Npcs")
onready var loots = get_node("Loots")
onready var chests = get_node("Chests")
onready var secrets = get_node("Secrets")
onready var effects = get_node("Effects")
onready var targetArrow = get_node("TargetArrow")
onready var levelBuffer = get_node("LevelBuffer")
onready var debugLayer = get_node("Debug")

var searched: Array
var specialEntries: Array = [null, null]

func _ready():
	Ref.currentLevel = self

func refresh_view():
	clearFog()
	GLOBAL.targets.clear()
	Ref.character.currentVision.clear()
	for i in range(-GLOBAL.VIEW_RANGE+1, GLOBAL.VIEW_RANGE):
		for j in range(-GLOBAL.VIEW_RANGE+1, GLOBAL.VIEW_RANGE):
			if pow(i, 2) + pow(j, 2) <= pow(GLOBAL.VIEW_RANGE, 2):
				var pos = Ref.character.pos
				var points = Ref.game.pathfinder.get_line(pos, pos+Vector2(i,j))
				var currentPath = []
				for p in points:
					currentPath.append(p)
					fog.set_cellv(p, 0)
					fog.update_bitmask_area(p)
					shadows.set_cellv(p, 1)
					shadows.update_bitmask_area(p)
					underShadows.set_cellv(p, 1)
					if pow(i, 2) + pow(j, 2) <= 16:
						if !searched[p.x][p.y]:
							Ref.character.rollPerception(p)
							searched[p.x][p.y] = true
					#todo use monsterbypos dict
					for m in monsters.get_children():
						if m.pos == p and m.status != "dead":
							m.awake()
							if !GLOBAL.targets.has(m.get_instance_id()):
								GLOBAL.targets[m.get_instance_id()] = currentPath.duplicate()
					var vision = isCellFree(p)
					if !vision[3]:
						break
					if vision[0] and not Ref.character.currentVision.has(p):
						Ref.character.currentVision.append(p)
	for m in monsters.get_children():
		if fog.get_cellv(m.pos) == 0:
			m.bodySprite.visible = true
			m.mask.visible = false
		else:
			if Data.hasTag(m, Data.TAG_EVIL):
				if Ref.character.statuses.has(Data.STATUS_DETECT_EVIL):
					m.mask.visible = true
	for a in allies.get_children():
		if fog.get_cellv(a.pos) == 0:
			a.bodySprite.visible = true
		else:
			a.bodySprite.visible = false
	for t in traps.get_children():
		t.mask.visible = false
		if Ref.character.statuses.has(Data.STATUS_REVEAL_TRAPS):
			if fog.get_cellv(t.pos) == 0:
				TrapEngine.reveal(t.pos)
			elif t.hidden:
				t.mask.visible = true
	for l in loots.get_children():
		l.mask.visible = false
		if Ref.character.statuses.has(Data.STATUS_LOCATE_OBJECTS):
			if fog.get_cellv(l.pos) != 0:
				l.mask.visible = true
	for c in chests.get_children():
		c.mask.visible = false
		if Ref.character.statuses.has(Data.STATUS_LOCATE_OBJECTS):
			if fog.get_cellv(c.pos) != 0:
				c.mask.visible = true
	if Ref.character.statuses.has(Data.STATUS_REVEAL_HIDDEN):
		secrets.visible = true
		for s in secrets.get_children():
			if fog.get_cellv(s.pos) != 0:
				s.visible = true
			else:
				discoverDoor(s.pos)
	else:
		secrets.visible = false
	Ref.character.currentVision.erase(Ref.character.pos)

func initShadows():
	shadows.clear()
	underShadows.clear()
	for i in range(-1, GLOBAL.FLOOR_SIZE_X+1):
		for j in range(-1, GLOBAL.FLOOR_SIZE_Y+1):
			shadows.set_cell(i, j, 0)
			shadows.update_bitmask_area(Vector2(i, j))
			underShadows.set_cell(i, j, 2)

func initSecrets():
	for cell in GLOBAL.hiddenDoors:
		var secret = secretScene.instance()
		secrets.add_child(secret)
		secret.init(cell)

func discoverDoor(cell: Vector2):
	if !GLOBAL.hiddenDoors.has(cell):
		return
	GLOBAL.hiddenDoors.erase(cell)
	for s in Ref.currentLevel.secrets.get_children():
		if s.pos == cell:
			s.queue_free()
	Ref.currentLevel.dungeon.set_cellv(cell, GLOBAL.DOOR_ID, false, false, false, Vector2(0,1))
	var effect = effectScene.instance()
	effects.add_child(effect)
	effect.play(cell, Effect.CIRCLE, 5, 0.5)
	Ref.ui.writeHiddenDoorDetected()

func clearFog():
	for i in range(GLOBAL.FLOOR_SIZE_X):
		for j in range(GLOBAL.FLOOR_SIZE_Y):
			fog.set_cell(i, j, 1)

# Return empty array if you cannot see target, return path if you can
func canTarget(source: Vector2, target: Vector2) -> Array:
	var points = Ref.game.pathfinder.get_line(source, target)
	for p in points:
		if isCellFree(p)[4]:
			return []
	return points

# [isFree, code, entity, isVisible, blockEffect]
func isCellFree(cell):
	if cell.x < 0 or cell.x >= GLOBAL.FLOOR_SIZE_X:
		return [false, "OOB", null, false, true]
	if cell.y < 0 or cell.y >= GLOBAL.FLOOR_SIZE_Y:
		return [false, "OOB", null, false, true]
	#todo use monsterbypos dict
	for m in monsters.get_children():
		if cell == m.pos:
			return [false, "monster", m, true, false]
	for n in npcs.get_children():
		if cell == n.pos:
			return [false, "npc", n, true, false]
	for m in allies.get_children():
		if cell == m.pos:
			return [false, "monster", m, true, false]
	for cIdx in GLOBAL.chests.keys():
		var chest = GLOBAL.chests[cIdx]
		if cell == chest[GLOBAL.CH_POS]:
			return [false, "chest", cIdx, true, false]
	if dungeon.get_cellv(cell) == GLOBAL.GRID_ID:
		return [false, "grid", null, true, true]
	if dungeon.get_cellv(cell) == GLOBAL.PASS_ID:
		if dungeon.get_cell_autotile_coord(cell.x, cell.y) == Vector2(0, 0):
			return [false, "pass", null, false, true]
		elif dungeon.get_cell_autotile_coord(cell.x, cell.y) == Vector2(2, 0):
			return [false, "entry", null, false, true]
		elif dungeon.get_cell_autotile_coord(cell.x, cell.y) == Vector2(1, 0):
			return [false, "passage", null, false, true]
	if dungeon.get_cellv(cell) == GLOBAL.DOOR_ID:
		if dungeon.get_cell_autotile_coord(cell.x, cell.y) == Vector2(0, 0):
			return [true, "floor", null, true, false]
		else:
			return [false, "door", null, false, true]
	if dungeon.get_cellv(cell) == GLOBAL.FLOOR_ID:
		return [true, "floor", null, true, false]
	return [false, "unknown", null, false, true]

func getRandomFreeCell():
	while(true):
		var x = randi() % GLOBAL.FLOOR_SIZE_X
		var y = randi() % GLOBAL.FLOOR_SIZE_Y
		var cell = Vector2(x, y)
		if isCellFree(cell)[0]:
			return cell

func isBlockingCell(cell: Vector2) -> bool:
	var isInBlock: bool = false
	var firstBlockEncountered: bool = false
	for n in Utils.neighbours:
		if not isCellFree(cell + n)[0]:
			isInBlock = true
		else:
			if isInBlock and firstBlockEncountered:
				return false
			if isInBlock:
				firstBlockEncountered = true
				isInBlock = false
	return false

func placeCharacter(pos: Vector2 = Vector2(-1,-1)):
	if pos == Vector2(-1, -1):
		pos = getRandomFreeCell()
	Ref.character.setPosition(pos)

func spawnMonster(idx: int = 0, pos = null, isAllied: bool = false):
	var cell = pos
	if cell == null:
		cell = getRandomFreeCell()
	var monster = monsterScene.instance()
	if isAllied:
		allies.add_child(monster)
		monster.status = "help"
	else:
		monsters.add_child(monster)
	monster.spawn(idx, cell)

func addLoot(cell: Vector2, isSecret: bool = false):
	var rarity = WorldHandler.currentCR
	var rand = randf()
	if isSecret:
		if rand < 0.4:
			rarity += 1
		elif rand < 0.5:
			rarity -= 1
	else:
		if rand < 0.1:
			rarity += 1
		elif rand < 0.6:
			rarity -= 1
	rarity += Skills.getLootRarityBonus()
	for item in Ref.game.itemGenerator.generateItem(rarity):
		GLOBAL.dropItemOnFloor(item, cell)

func dropItem():
	var cell = getRandomFreeCell()
	addLoot(cell, false)

func addChest(cell: Vector2, rarityBonus: int):
	var chest = chestScene.instance()
	chests.add_child(chest)
	chest.init(cell)
	GLOBAL.chests[chest.get_instance_id()] = [cell, [], false, 0]
	if randf() < 0.35:
		GLOBAL.chests[chest.get_instance_id()][GLOBAL.CH_LOCKED] = 3
	var quantity = randi() % 3 + 1
	for _i in range(quantity):
		var rarity = 1 + rarityBonus
		for item in Ref.game.itemGenerator.generateItem(rarity):
			GLOBAL.chests[chest.get_instance_id()][GLOBAL.CH_CONTENT].append(item)

func createChest():
	for _i in range(5):
		var cell = getRandomFreeCell()
		if not isBlockingCell(cell):
			addChest(cell, 0)
			return

func placeTrap(pos: Vector2, idx: int = Data.TR_DART):
	if GLOBAL.trapsByPos.has(pos):
		return
	var trap = trapScene.instance()
	traps.add_child(trap)
	trap.init(idx, pos)

func getLootMessage(cell):
	var lootList = GLOBAL.getItemList(cell)
	var forSell = GLOBAL.isForSell(cell)
	if lootList.keys().size() == 0:
		return null
	GLOBAL.itemsOnFloor[cell][GLOBAL.FLOOR_EXP] = true
	var msg = "You see "
	if forSell:
		msg = "It's "
	var list = []
	for l in lootList.keys():
		var items = lootList[l]
		var item = GLOBAL.items[items[0]]
		if item[GLOBAL.IT_TYPE] == GLOBAL.LO_TYPE or item[GLOBAL.IT_TYPE] == GLOBAL.GO_TYPE:
			list.append(Utils.addArticle(item[GLOBAL.IT_NAME], item[GLOBAL.IT_SPEC]))
		else:
			list.append(Utils.addArticle(item[GLOBAL.IT_NAME], items.size()))
	msg += Utils.makeList(list)
	if forSell:
		var price = GLOBAL.itemsOnFloor[cell][GLOBAL.FLOOR_PRICE]
		# Thievery price reduction
		price = int(ceil(price * Skills.getMerchantDiscount()))
		msg += " for " + String(price) + " golds"
		if lootList.values()[0].size() > 1:
			msg += " each"
	msg += "."
	return msg

func getLootChoice(lootList):
	var msg = "Pick what?"
	var count = 1
	for l in lootList.keys():
		var items = lootList[l]
		var item = GLOBAL.items[items[0]]
		msg += " [" + Ref.ui.color(String(count), "yellow") + "] "
		if item[GLOBAL.IT_TYPE] == GLOBAL.LO_TYPE or item[GLOBAL.IT_TYPE] == GLOBAL.GO_TYPE:
			msg += Utils.addArticle(item[GLOBAL.IT_NAME], item[GLOBAL.IT_SPEC])
		else:
			msg += Utils.addArticle(item[GLOBAL.IT_NAME], items.size())
		count += 1
	return msg

func openDoor(pos):
	if dungeon.get_cellv(pos) != GLOBAL.DOOR_ID:
		return
	if GLOBAL.testedDoors.has(pos):
		GLOBAL.testedDoors.erase(pos)
		Ref.game.pathfinder.dijkstraCompute()
	dungeon.set_cellv(pos, GLOBAL.DOOR_ID, false, false, false, Vector2(0, 0))

func target(pos):
	targetArrow.visible = true
	targetArrow.position = pos * 9

func untarget():
	targetArrow.visible = false

extends Node

onready var monsterScene = preload("res://scenes/Monster.tscn")
onready var lootScene = preload("res://scenes/Loot.tscn")
onready var chestScene = preload("res://scenes/Chest.tscn")
onready var trapScene = preload("res://scenes/Trap.tscn")

var filePath = "res://usr/"

func createFolder():
	var directory = Directory.new()
	if not directory.dir_exists(filePath):
		directory.make_dir(filePath)

func saveGame():
	createFolder()
	var file = File.new()
	file.open(filePath + Ref.character.stats.charName + ".sav", File.WRITE)
	#todo if file already exists copy it before erasing content
	file.store_var(saveItemGenerator(), true)
	file.store_var(saveStatusEngine(), true)
	file.store_var(saveGlobals(), true)
	file.store_var(savemap(), true)
	file.store_var(saveMonsters(), true)
	file.store_var(saveCharacter(), true)
	file.store_var(saveTraps(), true)
	file.store_var(saveEngine(), true)
	file.store_var(saveUI(), true)
	file.close()

func loadGame(charName: String):
	Ref.game.cleanFloor()
	var file = File.new()
	if not file.file_exists(filePath + charName + ".sav"):
		return
	file.open(filePath + Ref.character.stats.charName + ".sav", File.READ)
	loadItemGenerator(file.get_var(true))
	loadStatusEngine(file.get_var(true))
	loadGlobals(file.get_var(true))
	loadMap(file.get_var(true))
	loadMonsters(file.get_var(true))
	loadCharacter(file.get_var(true))
	loadTraps(file.get_var(true))
	loadEngine(file.get_var(true))
	loadUI(file.get_var(true))
	file.close()

func saveItemGenerator() -> Dictionary:
	return {
		"id": Ref.game.itemGenerator.id
	}

func loadItemGenerator(dict: Dictionary):
	Ref.game.itemGenerator.id = dict["id"]

func saveStatusEngine() -> Dictionary:
	return {
		"id": StatusEngine.id
	}

func loadStatusEngine(dict: Dictionary):
	StatusEngine.id = dict["id"]

func savemap() -> Dictionary:
	var dungeonInfo = []
	var cells = Ref.currentLevel.dungeon.get_used_cells()
	for c in cells:
		dungeonInfo.append([c, Ref.currentLevel.dungeon.get_cellv(c), Ref.currentLevel.dungeon.get_cell_autotile_coord(c.x, c.y)])
	return {
		"dungeon": tileMapToArray(Ref.currentLevel.dungeon),
		"fog": tileMapToArray(Ref.currentLevel.fog),
		"shadows": tileMapToArray(Ref.currentLevel.shadows),
		"under": tileMapToArray(Ref.currentLevel.underShadows),
		"searched": Ref.currentLevel.searched
	}

func loadMap(dict: Dictionary):
	arrayToTilemap(dict["dungeon"], Ref.currentLevel.dungeon)
	arrayToTilemap(dict["fog"], Ref.currentLevel.fog)
	arrayToTilemap(dict["shadows"], Ref.currentLevel.shadows)
	arrayToTilemap(dict["under"], Ref.currentLevel.underShadows)
	Ref.currentLevel.searched = dict["searched"]

func saveCharacter() -> Dictionary:
	return {
		"pos": Ref.character.pos,
		"class": Ref.character.charClass,
		"enchants": Ref.character.enchants,
		"statuses": Ref.character.statuses,
		"inventory": {
			"rests": Ref.character.inventory.rests,
			"currentWeapon": Ref.character.inventory.currentWeapon,
			"currentArmor": Ref.character.inventory.currentArmor,
			"currentTalismans": Ref.character.inventory.currentTalismans,
			"weapons": Ref.character.inventory.weapons,
			"armors": Ref.character.inventory.rests,
			"potions": Ref.character.inventory.potions,
			"scrolls": Ref.character.inventory.scrolls,
			"throwings": Ref.character.inventory.throwings,
			"talismans": Ref.character.inventory.talismans,
			"lockpicks": Ref.character.inventory.lockpicks,
			"golds": Ref.character.inventory.golds,
		},
		"stats": {
			"name": Ref.character.stats.charName,
			"xp": Ref.character.stats.xp,
			"level": Ref.character.stats.level,
		},
		"spells": {
			"spells": Ref.character.spells.spells,
			"spellsUses": Ref.character.spells.spellsUses,
		},
		"skills": {
			"feats": Ref.character.skills.feats,
			"ftp": Ref.character.skills.ftp,
			"skills": Ref.character.skills.skills,
			"masteries": Ref.character.skills.masteries,
			"skp": Ref.character.skills.skp,
		},
		"shortcuts": {
			"weapons": Ref.character.shortcuts.weapons,
			"scrolls": Ref.character.shortcuts.scrolls,
			"potions": Ref.character.shortcuts.potions,
			"throwings": Ref.character.shortcuts.throwings,
			"spells": Ref.character.shortcuts.spells,
		}
	}

func loadCharacter(dict: Dictionary):
	Ref.character.init(dict["class"], false)
	Ref.character.enchants = dict["enchants"]
	Ref.character.statuses = dict["statuses"]
	Ref.character.inventory.rests = dict["inventory"]["rests"]
	Ref.character.inventory.currentWeapon = dict["inventory"]["currentWeapon"]
	Ref.character.inventory.currentArmor = dict["inventory"]["currentArmor"]
	Ref.character.inventory.currentTalismans = dict["inventory"]["currentTalismans"]
	Ref.character.inventory.weapons = dict["inventory"]["weapons"]
	Ref.character.inventory.rests = dict["inventory"]["armors"]
	Ref.character.inventory.potions = dict["inventory"]["potions"]
	Ref.character.inventory.scrolls = dict["inventory"]["scrolls"]
	Ref.character.inventory.throwings = dict["inventory"]["throwings"]
	Ref.character.inventory.talismans = dict["inventory"]["talismans"]
	Ref.character.inventory.lockpicks = dict["inventory"]["lockpicks"]
	Ref.character.inventory.golds = dict["inventory"]["golds"]
	Ref.character.stats.charName = dict["stats"]["name"]
	Ref.character.stats.xp = dict["stats"]["xp"]
	Ref.character.stats.level = dict["stats"]["level"]
	Ref.character.spells.spells = dict["spells"]["spells"]
	Ref.character.spells.spellsUses = dict["spells"]["spellsUses"]
	Ref.character.skills.feats = dict["skills"]["feats"]
	Ref.character.skills.ftp = dict["skills"]["ftp"]
	Ref.character.skills.skills = dict["skills"]["skills"]
	Ref.character.skills.masteries = dict["skills"]["masteries"]
	Ref.character.skills.skp = dict["skills"]["skp"]
	Ref.character.shortcuts.weapons = dict["shortcuts"]["weapons"]
	Ref.character.shortcuts.scrolls = dict["shortcuts"]["scrolls"]
	Ref.character.shortcuts.potions = dict["shortcuts"]["potions"]
	Ref.character.shortcuts.throwings = dict["shortcuts"]["throwings"]
	Ref.character.shortcuts.spells = dict["shortcuts"]["spells"]
	Ref.character.stats.computeStats()
	Ref.character.setPosition(dict["pos"])

func saveMonsters() -> Dictionary:
	var result = []
	for m in Ref.currentLevel.monsters.get_children():
		result.append({
			"id": m.get_instance_id(),
			"type": m.type,
			"status": m.status,
			"statuses": m.statuses,
			"pos": m.pos,
			"skipNextTurn": m.skipNextTurn,
			"allies": m.allies,
			"buffCD": m.buffCD,
			"actions": {
				"throwings": m.actions.throwings,
				"spells": m.actions.spells,
				"buffs": m.actions.buffs,
				"debuffs": m.actions.debuffs,
				"heals": m.actions.heals,
				"selfBuffs": m.actions.selfBuffs,
				"selfHeals": m.actions.selfHeals,
			}
		})
	return {
		"monsters": result
	}

func loadMonsters(dict: Dictionary):
	var alliesOldIds: Dictionary = {}
	var reverseIds: Dictionary = {}
	for m in dict["monsters"]:
		var monster = monsterScene.instance()
		Ref.currentLevel.monsters.add_child(monster)
		monster.spawn(m["type"], m["pos"], true)
		monster.stats.type = m["type"]
		monster.allies = []
		monster.status = m["status"]
		monster.statuses = m["statuses"]
		monster.skipNextTurn = m["skipNextTurn"]
		monster.buffCD = m["buffCD"]
		monster.actions.throwings = m["actions"]["throwings"]
		monster.actions.spells = m["actions"]["spells"]
		monster.actions.buffs = m["actions"]["buffs"]
		monster.actions.debuffs = m["actions"]["debuffs"]
		monster.actions.heals = m["actions"]["heals"]
		monster.actions.selfBuffs = m["actions"]["selfBuffs"]
		monster.actions.selfHeals = m["actions"]["selfHeals"]
		monster.stats.computeStats()
		alliesOldIds[monster.get_instance_id()] = m["allies"]
		reverseIds[m["id"]] = monster.get_instance_id()
	for monster in Ref.currentLevel.monsters.get_children():
		for allyId in alliesOldIds[monster.get_instance_id()]:
			monster.allies.append(reverseIds[allyId])

func saveAllies() -> Dictionary:
	return {
		
	}

func loadAllies(dict: Dictionary):
	pass

func saveTraps() -> Dictionary:
	var result = []
	for t in Ref.currentLevel.traps.get_children():
		result.append([t.type, t.pos, t.hidden, t.disabled])
	return {
		"traps": result
	}

func loadTraps(dict: Dictionary):
	GLOBAL.trapsByPos.clear()
	for t in dict["traps"]:
		var trap = trapScene.instance()
		Ref.currentLevel.traps.add_child(trap)
		trap.init(t[0], t[1])
		if not t[2]:
			trap.reveal()
		elif t[3]:
			trap.disable()

func saveGlobals() -> Dictionary:
	var items: Dictionary = {}
	for i in GLOBAL.items.keys():
		items[i] = itemToVar(GLOBAL.items[i])
	return {
		"items": items,
		"itemsOnFloor": GLOBAL.itemsOnFloor,
		"chests": GLOBAL.chests,
		"statuses": GLOBAL.statuses,
		"hiddenDoors": GLOBAL.hiddenDoors,
		"lockedDoors": GLOBAL.lockedDoors,
		"testedDoors": GLOBAL.testedDoors,
	}

func loadGlobals(dict: Dictionary):
	var items: Dictionary = {}
	for i in dict["items"].keys():
		GLOBAL.items[i] = varToItem(dict["items"][i])
	for pilePos in dict["itemsOnFloor"].keys():
		for itemId in dict["itemsOnFloor"][pilePos][GLOBAL.FLOOR_IDS]:
			GLOBAL.dropItemOnFloor(itemId, pilePos)
		GLOBAL.itemsOnFloor[pilePos][GLOBAL.FLOOR_EXP] = dict["itemsOnFloor"][pilePos][GLOBAL.FLOOR_EXP]
	GLOBAL.chests.clear()
	for c in dict["chests"].values():
		var chest = chestScene.instance()
		Ref.currentLevel.chests.add_child(chest)
		chest.position = c[0] * 9
		GLOBAL.chests[chest.get_instance_id()] = c
	GLOBAL.statuses = dict["statuses"]
	GLOBAL.hiddenDoors = dict["hiddenDoors"]
	GLOBAL.lockedDoors = dict["lockedDoors"]
	GLOBAL.testedDoors = dict["testedDoors"]

func saveEngine() -> Dictionary:
	return {
		"turn": GeneralEngine.turn
	}

func loadEngine(dict: Dictionary):
	GeneralEngine.turn = dict["turn"]

func saveUI() -> Dictionary:
	return {
		"diary": Ref.ui.diaryContent
	}

func loadUI(dict: Dictionary):
	Ref.ui.diary.clear()
	Ref.ui.diary.append_bbcode(dict["diary"])
	Ref.ui.monsterPanelList.fillList()
	Ref.ui.statusBar.refreshStatuses(Ref.character)

func tileMapToArray(tilemap: TileMap) -> Array:
	var result = []
	var cells = tilemap.get_used_cells()
	for c in cells:
		result.append([vecToJson(c), tilemap.get_cellv(c), vecToJson(tilemap.get_cell_autotile_coord(c.x, c.y))])
	return result

func arrayToTilemap(array: Array, tilemap: TileMap):
	tilemap.clear()
	for a in array:
		tilemap.set_cellv(jsonToVec(a[0]), a[1], false, false, false, jsonToVec(a[2]))

func vecToJson(v: Vector2) -> Array:
	return [v.x, v.y]

func jsonToVec(array: Array) -> Vector2:
	return Vector2(array[0], array[1])

func itemToVar(item: Array) -> Array:
	var result = item.duplicate(true)
	if result[GLOBAL.IT_DMG] != null:
		result[GLOBAL.IT_DMG] = result[GLOBAL.IT_DMG].toVec()
	if result[GLOBAL.IT_HIT] != null:
		result[GLOBAL.IT_HIT] = result[GLOBAL.IT_HIT].toVec()
	return result

func varToItem(item: Array) -> Array:
	var result = item.duplicate(true)
	if result[GLOBAL.IT_DMG] != null:
		result[GLOBAL.IT_DMG] = GeneralEngine.DmgDice.fromVec(result[GLOBAL.IT_DMG])
	if result[GLOBAL.IT_HIT] != null:
		result[GLOBAL.IT_HIT] = GeneralEngine.Dice.fromVec(result[GLOBAL.IT_HIT])
	return result

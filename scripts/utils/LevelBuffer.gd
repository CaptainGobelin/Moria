extends Node

var currentLevel = "main"
var savedLevels: Dictionary = {}

func flush():
	savedLevels.clear()

func saveLevel():
	var result = {}
	result["map"] = Ref.game.saveSystem.saveMap()
	result["traps"] = Ref.game.saveSystem.saveTraps()
	result["monsters"] = Ref.game.saveSystem.saveMonsters()
	result["globals"] = Ref.game.saveSystem.saveGlobals()
	result["pos"] = Ref.character.pos
	savedLevels[currentLevel] = result

func loadLevel(level: String):
	clearLevel()
	var data = savedLevels[level]
	Ref.game.saveSystem.loadMap(data["map"])
	Ref.game.saveSystem.loadTraps(data["traps"])
	Ref.game.saveSystem.loadMonsters(data["monsters"])
	Ref.game.saveSystem.loadGlobals(data["globals"])
	Ref.character.setPosition(data["pos"])
	savedLevels.erase(level)
	currentLevel = level

func clearLevel():
	GLOBAL.hiddenDoors.clear()
	GLOBAL.lockedDoors.clear()
	GLOBAL.testedDoors.clear()
	for i in range(GLOBAL.FLOOR_SIZE_X):
		Ref.currentLevel.searched.append([])
		for _j in range(GLOBAL.FLOOR_SIZE_Y):
			Ref.currentLevel.searched[i].append(false)
	for m in Ref.currentLevel.monsters.get_children():
		GLOBAL.monstersByPosition.erase(m.pos)
		m.free()
	for c in Ref.currentLevel.chests.get_children():
		c.free()
	GLOBAL.chests.clear()
	for t in Ref.currentLevel.traps.get_children():
		t.free()
	GLOBAL.trapsByPos.clear()
	GLOBAL.itemsOnFloor.clear()

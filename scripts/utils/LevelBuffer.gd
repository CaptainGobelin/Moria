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
	result["npcs"] = Ref.game.saveSystem.saveNpcs()
	result["globals"] = Ref.game.saveSystem.saveGlobals()
	result["pos"] = Ref.character.pos
	savedLevels[currentLevel] = result

func loadLevel(level: String):
	clearLevel()
	var data = savedLevels[level]
	Ref.game.saveSystem.loadMap(savedLevels[level]["map"])
	Ref.game.saveSystem.loadTraps(savedLevels[level]["traps"])
	Ref.game.saveSystem.loadMonsters(savedLevels[level]["monsters"])
	Ref.game.saveSystem.loadNpcs(savedLevels[level]["npcs"])
	Ref.game.saveSystem.loadGlobals(savedLevels[level]["globals"])
	Ref.character.setPosition(savedLevels[level]["pos"])
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
	for n in Ref.currentLevel.npcs.get_children():
		n.free()
	for c in Ref.currentLevel.chests.get_children():
		c.free()
	GLOBAL.chests.clear()
	for t in Ref.currentLevel.traps.get_children():
		t.free()
	GLOBAL.trapsByPos.clear()
	GLOBAL.itemsOnFloor.clear()

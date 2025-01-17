extends Node

var currentLevel = "main"
var savedLevels: Dictionary = {}

func flush():
	savedLevels.clear()

func saveLevel():
	var result = {}
	result["map"] = Ref.game.saveSystem.saveMap().duplicate(true)
	result["traps"] = Ref.game.saveSystem.saveTraps().duplicate(true)
	result["monsters"] = Ref.game.saveSystem.saveMonsters().duplicate(true)
	result["npcs"] = Ref.game.saveSystem.saveNpcs().duplicate(true)
	result["globals"] = Ref.game.saveSystem.saveGlobals().duplicate(true)
	result["pos"] = Ref.character.pos
	savedLevels[currentLevel] = result

func loadLevel(level: String):
	Ref.game.cleanFloor()
	Ref.game.saveSystem.loadMap(savedLevels[level]["map"].duplicate(true))
	Ref.game.saveSystem.loadTraps(savedLevels[level]["traps"].duplicate(true))
	Ref.game.saveSystem.loadMonsters(savedLevels[level]["monsters"].duplicate(true))
	Ref.game.saveSystem.loadNpcs(savedLevels[level]["npcs"].duplicate(true))
	Ref.game.saveSystem.loadGlobals(savedLevels[level]["globals"].duplicate(true))
	Ref.character.setPosition(savedLevels[level]["pos"])
	savedLevels.erase(level)
	currentLevel = level

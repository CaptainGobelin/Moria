extends Node

const neighbours = [
	Vector2(0, 0),
	Vector2(1, 0), Vector2(1, 1), Vector2(0, 1),
	Vector2(-1, 1), Vector2(-1, 0), Vector2(-1, -1),
	Vector2(0, -1), Vector2(1, -1),
	Vector2(1, 0), Vector2(1, 1), Vector2(0, 1),
	Vector2(-1, 1), Vector2(-1, 0), Vector2(-1, -1),
	Vector2(-2, -2), Vector2(-2, -1), Vector2(-2, 0), Vector2(-2, 1),Vector2(-2, 2),
	Vector2(-1, -2), Vector2(0, -2), Vector2(1, -2),
	Vector2(-1, 2), Vector2(0, 2), Vector2(1, 2),
	Vector2(2, -2), Vector2(2, -1), Vector2(2, 0), Vector2(2, 1),Vector2(2, 2),
]

var exclusions: Array = []

func createEncounters() -> float:
	var totalCR: float = 0.0
	print("Start")
	exclusions = []
	var encounterPool = Data.encounters[WorldHandler.currentBiome]
	var nb = 3 + (randi() % 4)
	for _i in range(nb):
		var encounter = chooseEncounter(encounterPool)
		print("Choose encounter: " + String(encounterPool.find(encounter)))
		var cell = Utils.chooseRandom(get_parent().enemyCells)
		for _c in range(10):
			if exclusions.has(cell):
				cell = Utils.chooseRandom(get_parent().enemyCells)
		var CRmult = 1.0
		var encounterCR: float = 0.0
		for m in encounter[Data.ENC_MONSTERS]:
			var monsters = []
			var k = m[Data.ENC_MO_MIN]
			if m[Data.ENC_MO_MAX] != m[Data.ENC_MO_MIN]:
				k += (randi() % (m[Data.ENC_MO_MAX] - m[Data.ENC_MO_MIN]))
			for _j in range(k):
				var nearCell = getNearFreeCell(cell)
				if nearCell != null:
					monsters.append(Ref.currentLevel.spawnMonster(m[Data.ENC_MO_TYPE], nearCell))
					encounterCR += CRmult * Data.monsters[Data.ENC_MO_TYPE][Data.MO_CR]
					CRmult *= 0.75
			for monster in monsters:
				var allies = monsters.duplicate()
				allies.erase(monster)
				monster.allies = allies
			WorldHandler.diffCR += (encounterCR - (WorldHandler.getLevelNormalCR()/float(nb)))
			totalCR += encounterCR
		for i in range(-3, 4):
			for j in range(-3, 4):
				exclusions.append(Vector2(cell.x+i, cell.y+j))
				#DEBUG
				Ref.currentLevel.get_node("Debug/Enemies").set_cellv(Vector2(cell.x+i, cell.y+j), 1)
	print("CR: " + String(totalCR) + " (Diff: " + String(WorldHandler.diffCR) + ")")
	return totalCR

func chooseEncounter(encounterPool: Array) -> Array:
	var encounter = Utils.chooseRandom(encounterPool)
	var stopChoice = false
	var rerolls = 10
	while not stopChoice or rerolls > 0:
		rerolls -= 1
		# On first floor we want only easy encounters
		if WorldHandler.currentFloor == 1:
			if not encounter[Data.ENC_IS_LOW]:
				encounter = Utils.chooseRandom(encounterPool)
				continue
		if WorldHandler.diffCR < 0:
			if encounter[Data.ENC_IS_LOW] and randf() < Data.ENC_BAD_CR_DISMISS:
				encounter = Utils.chooseRandom(encounterPool)
				continue
		if WorldHandler.diffCR > 0:
			if not encounter[Data.ENC_IS_LOW] and randf() < Data.ENC_BAD_CR_DISMISS:
				encounter = Utils.chooseRandom(encounterPool)
				continue
		if encounter[Data.ENC_IS_RARE] and randf() < Data.ENC_RARE_DISMISS:
			encounter = Utils.chooseRandom(encounterPool)
			continue
		stopChoice = true
	return encounter

func getNearFreeCell(cell: Vector2):
	for _i in range(15):
		var n = Utils.chooseRandom(neighbours)
		if get_parent().enemyCells.has(cell + n):
			if not exclusions.has(cell + n):
				#TODO exclude if cannot see
				return cell + n
	return null

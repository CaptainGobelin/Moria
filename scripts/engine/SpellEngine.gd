extends Node

onready var effectScene = preload("res://scenes/Effect.tscn")

onready var throwings = get_node("Throwings")

func playEffect(pos: Vector2, type: int, length: int, speed: float):
	var effect = effectScene.instance()
	Ref.currentLevel.effects.add_child(effect)
	effect.play(pos, type, length, speed)

func applyEffect(entity, spell: int, direction: Vector2 = Vector2(0, 0)):
	match spell:
		Data.SP_MAGIC_MISSILE:
			magicMissile(entity)
		Data.SP_ELECTRIC_GRASP:
			electricGrasp(entity, direction)
		Data.SP_HEAL:
			heal(entity)
		Data.SP_SMITE:
			smite(entity, direction)
		Data.SP_FIREBOLT:
			firebolt(entity)
		Data.SP_BLESS:
			bless(entity)
		Data.SP_FIREBALL:
			fireball(entity)
		Data.SP_TH_FIREBOMB:
			throwings.firebomb(entity)
		Data.SP_TH_POISON:
			throwings.poisonFlask(entity)
		Data.SP_TH_SLEEP:
			throwings.sleepFlask(entity)

func magicMissile(entity):
	entity.takeHit(GeneralEngine.dice(2, 1, 1).roll())

func electricGrasp(entity, direction):
	var targetCell = entity.pos + direction
	playEffect(targetCell, 5, 5, 1.1)
	if GLOBAL.monstersByPosition.has(targetCell):
		var target = instance_from_id(GLOBAL.monstersByPosition[targetCell])
		var dmgDice = [GeneralEngine.dmgDice(1, 12, 0, Data.DMG_LIGHTNING)]
		var dmg = GeneralEngine.computeDamages(dmgDice, target.stats.resists)
		target.takeHit(dmg)

func heal(entity):
	playEffect(entity.pos, 7, 5, 0.6)
	var result:float = entity.stats.hpMax * 0.5
	entity.stats.hp += ceil(result)

func smite(entity, direction):
	var targetCell = entity.pos + direction
	for _i in range(GLOBAL.VIEW_RANGE) :
		if Ref.currentLevel.isCellFree(targetCell)[4]:
			return
		if Ref.currentLevel.fog.get_cellv(targetCell) == 1:
			return
		playEffect(targetCell, 6, 5, 0.8)
		if GLOBAL.monstersByPosition.has(targetCell):
			var target = instance_from_id(GLOBAL.monstersByPosition[targetCell])
			var dmgDice = [GeneralEngine.dmgDice(1, 8, 0, Data.DMG_RADIANT)]
			var dmg = GeneralEngine.computeDamages(dmgDice, target.stats.resists)
			target.takeHit(dmg)
		targetCell += direction

func firebolt(entity):
	var dmgDice = [GeneralEngine.dmgDice(1, 10, 0, Data.DMG_FIRE)]
	var dmg = GeneralEngine.computeDamages(dmgDice, entity.stats.resists)
	entity.takeHit(dmg)

func bless(entity):
	var status = Data.statusPrefabs[Data.STATUS_BLESSED]
	status[GLOBAL.ST_TIMING] = GLOBAL.TIMING_TIMER
	status[GLOBAL.ST_TURNS] = 21
	status[GLOBAL.ST_RANK] = 1
	StatusEngine.addStatus(entity, status)
	Ref.character.stats.computeStats()

func fireball(entity):
	var targetedCells = getArea(entity.pos, 4)
	targetedCells.append(Vector2(0, 0))
	for cell in targetedCells:
		var pos = entity.pos + cell
		playEffect(pos, 0, 5, 0.1)
		if GLOBAL.monstersByPosition.has(pos):
			var target = instance_from_id(GLOBAL.monstersByPosition[pos])
			target.takeHit(GeneralEngine.dice(3, 6, 0).roll())

func getArea(pos: Vector2, size: int):
	var result = []
	var toCheck = [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]
	var cells = {
		Vector2(-1, 0): [[2, Vector2(-1, -1)], [2, Vector2(-1, 1)], [3, Vector2(-2, 0)]],
		Vector2(1, 0): [[2, Vector2(1, -1)], [2, Vector2(1, 1)], [3, Vector2(2, 0)]],
		Vector2(0, -1): [[2, Vector2(-1, -1)], [2, Vector2(1, -1)], [3, Vector2(0, -2)]],
		Vector2(0, 1): [[2, Vector2(-1, 1)], [2, Vector2(1, 1)], [3, Vector2(0, 2)]],
		Vector2(-1, -1): [[4, Vector2(-2, -1)], [4, Vector2(-1, -2)]],
		Vector2(-1, 1): [[4, Vector2(-2, 1)], [4, Vector2(-1, 2)]],
		Vector2(1, -1): [[4, Vector2(2, -1)], [4, Vector2(1, -2)]],
		Vector2(1, 1): [[4, Vector2(2, 1)], [4, Vector2(1, 2)]]
	}
	for c in toCheck:
		if Ref.currentLevel.isCellFree(c + pos)[4]:
			continue
		if !result.has(c):
			result.append(c)
		if !cells.has(c):
			continue
		for cell in cells[c]:
			if cell[0] > size:
				continue
			toCheck.append(cell[1])
	return result
